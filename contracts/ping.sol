// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;


import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PING is ERC20, Ownable {

    /**
     *
     * See {ERC20-constructor}.
     */
    constructor(string memory name, string memory symbol) public ERC20(name, symbol) {
        _setupDecimals(8);
        _mint(msg.sender, 10000000*10**8);
    }


    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20) {
        super._beforeTokenTransfer(from, to, amount);
    }
}