pragma solidity ^0.6.0;

import "truffle/Assert.sol";
import "../contracts/Accounting.sol";



contract TestAccountingPlans {
	function testPlansUnderconfigured() public {
		Accounting accountingNew = new Accounting();

		accountingNew.setupPlansAmount(2);
    	accountingNew.setupPlan(0, 3000, 1000);

    	bool r;

        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "Should be false, as it should throw");

		accountingNew.setupPlansAmount(1);
    	accountingNew.setupPlan(0, 3000, 1000);

        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "Should be false, as it should throw");

        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.setupPlan.selector, 1, 3000, 1000));
		Assert.isFalse(r, "idx out of range");
	}

	function testPlansPricePriority2() public {
		Accounting accountingNew = new Accounting();

		accountingNew.setupPlansAmount(2);
    	accountingNew.setupPlan(0, 3000, 1000);

    	bool r;

		accountingNew.setupPlan(1, 1000, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "price of plan should be greater of price of prev plan 1");

		accountingNew.setupPlan(1, 3001, 500);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "price of plan should be greater of price of prev plan 2");

		accountingNew.setupPlan(1, 3001, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "price of plan should be greater of price of prev plan 3");
	}

	function testPlansPricePriority3() public {
		Accounting accountingNew = new Accounting();

		accountingNew.setupPlansAmount(3);
    	accountingNew.setupPlan(0, 3000, 1000);

    	bool r;


		accountingNew.setupPlan(1, 1000, 500);
		accountingNew.setupPlan(2, 1000, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "price of plan should be greater of price of prev plan 1");

		accountingNew.setupPlan(1, 3001, 500);
		accountingNew.setupPlan(2, 3001, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "price of plan should be greater of price of prev plan 2");


		accountingNew.setupPlan(1, 3001, 500);
		accountingNew.setupPlan(2, 3002, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "price of plan should be greater of price of prev plan 3 ");
	}

	function testPlansPrice3() public {
		Accounting accountingNew = new Accounting();

		accountingNew.setupPlansAmount(3);
    	accountingNew.setupPlan(0, 3000, 1000);
		accountingNew.setupPlan(1, 6000, 500);
		accountingNew.setupPlan(2, 8000, 0);
        accountingNew.checkPlans();

        Assert.equal(accountingNew.getPriceForPlan(2000000), 3000, "price 3000, as 2000000");
        Assert.equal(accountingNew.getPriceForPlan(1001), 3000, "price 3000, as 1001");
        Assert.equal(accountingNew.getPriceForPlan(1000), 3000, "price 3000, as 1000");
        Assert.equal(accountingNew.getPriceForPlan(999), 6000, "price 6000, as 999");
        Assert.equal(accountingNew.getPriceForPlan(500), 6000, "price 6000, as 500");
        Assert.equal(accountingNew.getPriceForPlan(499), 8000, "price 8000, as 499");
        Assert.equal(accountingNew.getPriceForPlan(1), 8000, "price 8000, as 1");
        Assert.equal(accountingNew.getPriceForPlan(0), 8000, "price 8000, as 0");
    }

}