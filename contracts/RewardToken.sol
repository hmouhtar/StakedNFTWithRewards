// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20Capped, Ownable {
    uint256 public constant MAX_SUPPLY = 1_000_000e18;

    constructor() ERC20("RewardToken", "RT") ERC20Capped(MAX_SUPPLY) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
