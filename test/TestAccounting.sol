pragma solidity ^0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Accounting.sol";



contract TestAccounting {
	Accounting accounting = Accounting(DeployedAddresses.Accounting());


	function testNoAccountForUnexistedNick() public {
		address account = accounting.getAccount("unexisted");
		Assert.equal(account, address(0), "return zero account for unexisted nick");
	}

	function testEmptyNickForUnexistedAccount() public {
		string memory nick = accounting.getNick(address(0x5A0b54D5dc17e0AadC383d2db43B0a0D3E029c4c));
		Assert.equal(bytes(nick).length, 0, "return zero nick for unexisted account");
	}

	function testZeroSpendIsNotThrows() public {
		accounting.subscribe("testNick", 0);
	}


	function testChangeToEmptyNickThrows() public {
		accounting.subscribe("testNick", 0);
		bool r;
        (r, ) = address(accounting).call(abi.encodeWithSelector(accounting.changeNick.selector, ""));
		Assert.isFalse(r, "Should be false, as it should throw");

        (r, ) = address(accounting).call(abi.encodeWithSelector(accounting.changeNick.selector, "1qaz"));
		Assert.isTrue(r, "Should be true");

        (r, ) = address(accounting).call(abi.encodeWithSelector(accounting.changeNick.selector, ""));
		Assert.isFalse(r, "Should be false, as it should throw");
	}

	function testShouldSubscribeWithNoTokens() public {
		accounting.subscribe("testNick1", 0);
		bool r;
        (r, ) = address(accounting).call(abi.encodeWithSelector(accounting.subscribe.selector, "testNick1", 10));
		Assert.isFalse(r, "Should be false, as it should throw");
	}


}