pragma solidity ^0.6.0;

import "truffle/Assert.sol";
import "../contracts/Accounting.sol";



contract TestAccountingPlansAddSecs {

	function testPlansAddSecsPriority3() public {
		Accounting accountingNew = new Accounting();

		accountingNew.setupPlansAmount(3);
    	accountingNew.setupPlan(0, 3000, 1000);

    	bool r;

		accountingNew.setupPlan(1, 3001, 1000);
		accountingNew.setupPlan(2, 3002, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "addsecs of plan should be less of addsecs of prev plan 1 ");

		accountingNew.setupPlan(1, 3001, 1001);
		accountingNew.setupPlan(2, 3002, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "addsecs of plan should be less of addsecs of prev plan 2 ");

		accountingNew.setupPlan(1, 3001, 999);
		accountingNew.setupPlan(2, 3002, 998);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "addsecs of plan should be less of addsecs of prev plan 3 ");


		accountingNew.setupPlan(1, 3001, 999);
		accountingNew.setupPlan(2, 3002, 999);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "addsecs of plan should be less of addsecs of prev plan 4 ");

		accountingNew.setupPlan(1, 3001, 999);
		accountingNew.setupPlan(2, 3002, 1999);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isFalse(r, "addsecs of plan should be less of addsecs of prev plan 5 ");


		accountingNew.setupPlan(1, 3001, 500);
		accountingNew.setupPlan(2, 3002, 0);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "addsecs of plan should be less of addsecs of prev plan 6 ");

		accountingNew.setupPlan(1, 3001, 500);
		accountingNew.setupPlan(2, 3002, 200);
        (r, ) = address(accountingNew).call(abi.encodeWithSelector(accountingNew.checkPlans.selector));
		Assert.isTrue(r, "addsecs of plan should be less of addsecs of prev plan 7 ");

    }

}