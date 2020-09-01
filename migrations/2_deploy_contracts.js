var Accounting = artifacts.require("Accounting");
var Ping = artifacts.require("PING");


module.exports = async (deployer, network, accounts) => {
	console.log(accounts);

	await deployer.deploy(Ping, "PING", "CryptoPing");
	await deployer.deploy(Accounting);


	var AccountingC = await Accounting.deployed();
	var pingC	= await Ping.deployed();

	await AccountingC.setupToken(pingC.address);
	await AccountingC.setupTreasure(accounts[1]);
	console.log("treasure " + await AccountingC._treasure());
	console.log("ping token " + await AccountingC._token());

	await AccountingC.setupPlansAmount(1);
	await AccountingC.setupPlan(0, parseInt(10000000000/2592000, 10), 0);

	let plan = await AccountingC._plans(0).valueOf();
	console.log("plan _minAddSec:" + plan._minAddSec);
	console.log("plan _pricePerSec:" + plan._pricePerSec);
};