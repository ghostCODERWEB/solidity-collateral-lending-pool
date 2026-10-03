// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Collateralized token lending pool
/// @notice Pooled ERC20 loans against native collateral with stale-oracle checks, bounded liquidation and share accounting.
/// @dev Reference implementation; independent audit required before production.

contract CollateralPool is ERC20, SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable loanToken;
    uint256 public price;
    uint256 public priceUpdated;
    uint256 public immutable maxOracleAge;
    uint256 public totalDebt;
    uint256 public badDebt;
    uint16 public constant LTV = 6000;
    uint16 public constant LIQUIDATION = 7500;
    uint16 public constant BONUS = 500;
    mapping(address => uint256) public collateral;
    mapping(address => uint256) public debt;
    event OracleUpdated(uint256 price);
    event Borrowed(address indexed borrower, uint256 amount);
    event Repaid(address indexed borrower, uint256 amount);
    event Liquidated(
        address indexed borrower,
        uint256 repaid,
        uint256 collateralSeized,
        uint256 writtenOff
    );
    constructor(
        address asset,
        uint256 initialPrice,
        uint256 oracleAge,
        address admin
    ) ERC20("Lending Pool Share", "LPS") SuiteBase(admin) {
        require(
            asset.code.length > 0 && initialPrice > 0 && oracleAge > 0,
            "config"
        );
        loanToken = IERC20(asset);
        price = initialPrice;
        priceUpdated = block.timestamp;
        maxOracleAge = oracleAge;
    }
    receive() external payable {
        revert("use addCollateral");
    }
    function setPrice(uint256 value) external onlyOwner {
        require(value > 0, "price");
        price = value;
        priceUpdated = block.timestamp;
        emit OracleUpdated(value);
    }
    function _fresh() internal view {
        require(block.timestamp - priceUpdated <= maxOracleAge, "stale oracle");
    }
    function totalAssets() public view returns (uint256) {
        return loanToken.balanceOf(address(this)) + totalDebt;
    }
    function deposit(
        uint256 assets
    ) external nonReentrant whenNotPaused returns (uint256 shares) {
        shares = Math.mulDiv(assets, totalSupply() + 1000, totalAssets() + 1);
        require(shares > 0, "dust");
        AssetFlow.pullExact(loanToken, msg.sender, assets);
        _mint(msg.sender, shares);
    }
    function redeem(
        uint256 shares
    ) external nonReentrant returns (uint256 assets) {
        require(shares > 0, "shares");
        assets = Math.mulDiv(shares, totalAssets() + 1, totalSupply() + 1000);
        require(
            assets > 0 && assets <= loanToken.balanceOf(address(this)),
            "liquidity"
        );
        _burn(msg.sender, shares);
        loanToken.safeTransfer(msg.sender, assets);
    }
    function addCollateral() external payable whenNotPaused {
        require(msg.value > 0, "amount");
        collateral[msg.sender] += msg.value;
    }
    function collateralValue(address account) public view returns (uint256) {
        return Math.mulDiv(collateral[account], price, 1e18);
    }
    function borrow(uint256 amount) external nonReentrant whenNotPaused {
        _fresh();
        require(
            amount > 0 &&
                debt[msg.sender] + amount <=
                    Math.mulDiv(collateralValue(msg.sender), LTV, 10000),
            "ltv"
        );
        debt[msg.sender] += amount;
        totalDebt += amount;
        loanToken.safeTransfer(msg.sender, amount);
        emit Borrowed(msg.sender, amount);
    }
    function repay(address account, uint256 amount) external nonReentrant {
        require(amount > 0 && amount <= debt[account], "debt");
        AssetFlow.pullExact(loanToken, msg.sender, amount);
        debt[account] -= amount;
        totalDebt -= amount;
        emit Repaid(account, amount);
    }
    function removeCollateral(uint256 amount) external nonReentrant {
        _fresh();
        require(amount > 0 && amount <= collateral[msg.sender], "collateral");
        uint256 remaining = collateral[msg.sender] - amount;
        require(
            debt[msg.sender] <=
                Math.mulDiv(Math.mulDiv(remaining, price, 1e18), LTV, 10000),
            "ltv"
        );
        collateral[msg.sender] = remaining;
        AssetFlow.sendNative(msg.sender, amount);
    }
    function liquidate(
        address account,
        uint256 maxRepay
    ) external nonReentrant {
        _fresh();
        uint256 owed = debt[account];
        require(
            owed > Math.mulDiv(collateralValue(account), LIQUIDATION, 10000) &&
                maxRepay > 0,
            "healthy"
        );
        uint256 covered = Math.mulDiv(
            collateralValue(account),
            10000,
            10000 + BONUS
        );
        uint256 repaid = Math.min(Math.min(maxRepay, owed), covered);
        require(repaid > 0, "dust");
        uint256 seized = Math.mulDiv(
            Math.mulDiv(repaid, 10000 + BONUS, 10000),
            1e18,
            price
        );
        require(seized > 0 && seized <= collateral[account], "seize");
        AssetFlow.pullExact(loanToken, msg.sender, repaid);
        collateral[account] -= seized;
        debt[account] -= repaid;
        totalDebt -= repaid;
        uint256 writtenOff;
        if (collateralValue(account) < 2 && debt[account] > 0) {
            writtenOff = debt[account];
            badDebt += writtenOff;
            totalDebt -= writtenOff;
            debt[account] = 0;
        }
        AssetFlow.sendNative(msg.sender, seized);
        emit Liquidated(account, repaid, seized, writtenOff);
    }
}
