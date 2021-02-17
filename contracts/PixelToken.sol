pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PixelToken is ERC1155 {

    address payable owner;
    uint256 transactionFee;

    struct Pixel {
        uint256 id;
        Meta meta;
    }

    struct Meta {
        address account;
        string hexColor;
        uint256 x;
        uint256 y;
    }

    event PixelTransaction(address _from, Meta data);

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

    modifier isOwner() {
        require(msg.sender == owner, "Creator Only");
        _;
    }

    constructor() public ERC1155("https://github.com/mattruddy/DAPP/blob/master/item/{id}.json") {
        name = "PixelToken";
        symbol = "PXT";
        owner = 0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6;
        transactionFee = 1000000000000000000;
    }

    function changeOwner(address payable _owner) public isOwner {
        owner = _owner;
    }

    function create(uint256 x, uint256 y, string calldata hexColor) external payable {
        //require(msg.value == transactionFee, 'Value is not enough');
        Meta memory meta = Meta({
            account: msg.sender, 
            hexColor: hexColor,
            x: x,
            y: y           
        });

        creators[_currentTokenID] = meta;

        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID, 1, "");
        emit PixelTransaction(msg.sender, meta);
        _incrementTokenTypeId();
    }

    function send(address to, uint256 _id) external creatorOnly(_id) returns(Pixel[] memory){

        Meta memory currentMeta = creators[_id];
        Meta memory newMeta = Meta({
            account: to,
            hexColor: currentMeta.hexColor,
            x: currentMeta.x,
            y: currentMeta.y
        });
        creators[_id] = newMeta;

        safeTransferFrom(msg.sender, to, _id, 1, "");
        return getAllPixels();
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

    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }
}