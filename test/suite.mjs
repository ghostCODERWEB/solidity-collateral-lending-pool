export async function suite(h) {
  const token = await h.token();
  const c = await h.deploy("CollateralPool", [
    token.target,
    2n * 10n ** 18n,
    100,
    h.addresses[0],
  ]);
  await h.tx(token.approve(c.target, 100000));
  await h.tx(c.deposit(10000));
  await h.tx(c.connect(h.signers[1]).addCollateral({ value: 1000 }));
  await h.test("borrow respects collateral cap", async () => {
    await h.tx(c.connect(h.signers[1]).borrow(500));
    h.eq(await c.debt(h.addresses[1]), 500n);
  });
  await h.test("overborrow rejected", () =>
    h.revert(() => c.connect(h.signers[1]).borrow(1000)),
  );
  await h.test("unsafe collateral withdrawal rejected", () =>
    h.revert(() => c.connect(h.signers[1]).removeCollateral(900)),
  );
  await h.test("oracle updates require admin", () =>
    h.revert(() => c.connect(h.signers[2]).setPrice(1)),
  );
  await h.test("stale oracle blocks new debt", async () => {
    await h.mine(101);
    await h.revert(() => c.connect(h.signers[1]).borrow(1));
    await h.tx(c.setPrice(4n * 10n ** 17n));
  });
  await h.test("liquidation repays pool and reduces collateral", async () => {
    await h.tx(c.liquidate(h.addresses[1], 300));
    h.ok((await c.debt(h.addresses[1])) < 500n);
    h.ok((await c.collateral(h.addresses[1])) < 1000n);
  });
}
