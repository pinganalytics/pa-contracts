var Accounting = artifacts.require("Accounting");
var Ping = artifacts.require("PING");


contract("1nd Accounting test", async accounts => {
  it("should put 10000000 Ping in the owner account and zero to treasure", async () => {
    let accounting = await Accounting.deployed();
    let ping = await Ping.deployed();
    let pingOwner = await accounting.owner();

    let balance = await ping.balanceOf.call(pingOwner);
    assert.equal(balance.valueOf(), 1000000000000000, "balance " + balance);


    let treasure = await accounting._treasure.call();

    let balance1 = await ping.balanceOf.call(treasure);
    assert.equal(balance1.valueOf(), 0, "balance " + balance1 + " addr:" + treasure);
  });

  it("setup plans", async () => {
    let accounting = await Accounting.deployed();

    await accounting.setupPlansAmount(1);
    await accounting.setupPlan(0, parseInt(10000000000/2592000, 10), 0);
    await accounting.checkPlans();

  });



  it("move to acc2 and use it", async () => {
    let accounting = await Accounting.deployed();
    let ping = await Ping.deployed();
    let pingOwner = await accounting.owner();

    let accounts2 = accounts[2];

    let price = (await accounting._plans(0).valueOf())._pricePerSec;
	let toMove = 1000000000000;
	let toSpend = (100000000000/price|0)*price
	let remain = toMove-toSpend
	let nick = "testNick1";
    await ping.transfer(accounts2, toMove, { from: pingOwner });


    let balance = await ping.balanceOf.call(accounts2);
    assert.equal(balance.valueOf(), toMove, "balance " + balance);

    await ping.approve(accounting.address, toMove, { from: accounts2 });

    assert.equal(await accounting.getAccount(nick).valueOf(), 0);
    assert.equal(await accounting.getNick(accounts2).valueOf(), "");

    let now = Date.now() / 1000 | 0;

    await accounting.subscribe(nick, toSpend/price|0, { from: accounts2 });

    assert.equal(await accounting.getAccount(nick).valueOf(), accounts2);
    assert.equal(await accounting.getNick(accounts2).valueOf(), nick);



    let expectedActiveTill = (now+(toSpend/price|0))/60 | 0;
    assert.equal(await accounting.getActiveTillByNick(nick).valueOf()/60 | 0, expectedActiveTill);
    assert.equal(await accounting.getActiveTill(accounts2).valueOf()/60 | 0, expectedActiveTill);

    let balanceAfter = (await ping.balanceOf.call(accounts2)).valueOf();
    assert.equal(balanceAfter, remain, "balance:" + balanceAfter);

	let treasure = await accounting._treasure.call();
    let balanceTreasure = await ping.balanceOf.call(treasure);
    assert.equal(balanceTreasure.valueOf(), toSpend, "balance " + balanceTreasure + " addr:" + treasure);

////////////////

	let toSpend2 = (200000000000/price|0)*price
	remain -= toSpend2

    await accounting.subscribe(nick, toSpend2/price|0, { from: accounts2 });
    assert.equal(await accounting.getAccount.call(nick).valueOf(), accounts2);
    assert.equal(await accounting.getNick.call(accounts2).valueOf(), nick);

    // expectedActiveTill = ((toSpend2+toSpend)/price|0)/3600 | 0;
    expectedActiveTill += (toSpend2/price|0)/60 | 0;

    let tillByNick = await accounting.getActiveTillByNick.call(nick).valueOf();
    let till = await accounting.getActiveTill.call(accounts2).valueOf();

    assert.equal(tillByNick.toString(), till.toString());

    assert.isAtMost((tillByNick/60 | 0) - expectedActiveTill, 1);
    // assert.equal(till/3600 | 0, expectedActiveTill);

    balanceAfter = await ping.balanceOf.call(accounts2);
    assert.equal(balanceAfter.valueOf(), remain, "balance " + balanceAfter);

	treasure = await accounting._treasure.call();
    balanceTreasure = await ping.balanceOf.call(treasure);
    assert.equal(balanceTreasure.valueOf(), toSpend2+toSpend, "balance " + balanceTreasure + " addr:" + treasure);

////////////////

    assert.equal(await accounting.getAccount.call(nick).valueOf(), accounts2);
    assert.equal(await accounting.getNick.call(accounts2).valueOf(), nick);

    let nick2 = "testNick2";

    assert.equal(await accounting.getAccount(nick2).valueOf(), 0);
    assert.equal(await accounting.getActiveTillByNick(nick2).valueOf(), 0);

    await accounting.changeNick(nick2, { from: accounts2 });
    assert.equal(await accounting.getAccount(nick2).valueOf(), accounts2);
    assert.equal(await accounting.getNick(accounts2).valueOf(), nick2);

    assert.equal(await accounting.getAccount(nick).valueOf(), 0);

    assert.equal(await accounting.getActiveTillByNick(nick).valueOf(), 0);
    assert.isAtMost((await accounting.getActiveTillByNick(nick2).valueOf()/60 | 0) - expectedActiveTill, 1);

  });
});


contract("zero spend test", async accounts => {
  it("should work", async () => {
  	let accounting = await Accounting.deployed();
  	let ping = await Ping.deployed();
  	let accounts2 = accounts[2];

    let balance = await ping.balanceOf.call(accounts2);
    assert.equal(balance.valueOf(), 0, "balance " + balance);
    let nick = "testNick1";

    await accounting.subscribe(nick, 0, { from: accounts2 });

    let tillByNick = await accounting.getActiveTillByNick.call(nick).valueOf();
    let till = await accounting.getActiveTill.call(accounts2).valueOf();
    assert.equal(tillByNick.toString(), till.toString());

    let now = Date.now() / 1000 | 0;
    assert.isAbove(now+1, till|0);

  });
});