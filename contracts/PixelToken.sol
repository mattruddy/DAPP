pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PixelToken is ERC1155 {

    struct Pixel {
        uint256 id;
        Meta meta;
    }

    struct Meta {
        address account;
        string name;
    }

    address proxyRegistryAddress;
    uint256 private _currentTokenID = 0;
    mapping (uint256 => Meta) public creators;

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    modifier creatorOnly(uint256 _id) {
        require(creators[_id].account == msg.sender, "Creator Only");
        _;
    }

    constructor() public ERC1155("https://github.com/mattruddy/DAPP/blob/master/item/{id}.json") {
        name = "PixelToken";
        symbol = "PXT";
        proxyRegistryAddress = msg.sender;

        // create 100 pixel items
        for (uint i=0; i<10; i++) {
            _mint(msg.sender, i, 1, "");
            Meta memory meta = Meta({
                account: msg.sender,
                name: "Test Name"
            });
            creators[i] = meta;
            _incrementTokenTypeId();
        }
    }

    function create(string calldata itemName) external returns(uint256) {
        uint256 _id = _getNextTokenID();
        _incrementTokenTypeId();

        Meta memory meta = Meta({
            account: msg.sender,
            name: itemName
        });
        creators[_id] = meta;

        _mint(msg.sender, _id, 1, "");
        return _id;
    }

    function getAllPixels() public view returns(Pixel[] memory) {
        Pixel[] memory pixels = new Pixel[](_currentTokenID);
        for(uint i =0; i < _currentTokenID; i++) {
            pixels[i] = Pixel({
                id: i,
                meta: creators[i]
            });
        }
        return pixels;
    }

    function _getNextTokenID() private view returns (uint256) {
        return _currentTokenID.add(1);
    }

    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }
}