pragma solidity 0.6.2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract America is ERC1155 {

    address proxyRegistryAddress;
    uint256 private _currentTokenID = 0;
    mapping (uint256 => address) public creators;
    mapping (uint256 => uint256) public tokenSupply;

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;


    modifier creatorOnly(uint256 _id) {
        require(creators[_id] == msg.sender, "Creator Only");
        _;
    }

    constructor() public ERC1155("") {
        name = "Land";
        symbol = "LD";
        proxyRegistryAddress = msg.sender;
    }

    function create(address _initialOwner, uint256 _initialSupply) external returns(uint256) {
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();
        creators[_id] = msg.sender;

        _mint(_initialOwner, _id, _initialSupply, "");
        tokenSupply[_id] = _initialSupply;
        return _id;
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }

}