pragma solidity 0.6.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract America is ERC1155 {

    uint256 public constant NJ = 0;
    uint256 public constant NY = 1;

    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
        _mint(msg.sender, NJ, 10**18, "");
        _mint(msg.sender, NY, 10**27, "");
    }
}