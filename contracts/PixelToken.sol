pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract PixelToken is ERC1155 {

    address payable owner;
    uint256 transactionFee;

    struct Creator {
        uint256 id;
        address owner;
        bytes32[] pixelIds;
    }

    struct Pixel {
        address owner;
        uint256 creatorId;
        bytes32 id;
        string hexColor;
        uint256 x;
        uint256 y;
    }

    Pixel[] public pixels;

    uint256 private _currentTokenID = 0;
    mapping (uint256 => Creator) public creators;


    string public name;
    string public symbol;

    modifier creatorOnly(uint256 _id) {
        require(creators[_id].owner == msg.sender, "Creator Only");
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Owner Only");
        _;
    }

    constructor() public ERC1155("https://github.com/mattruddy/DAPP/blob/master/item/{id}.json") {
        name = "PixelToken";
        symbol = "PXT";
        owner = 0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6;
    }

    function getPixels() public returns(Pixel[] memory) {
        return pixels;
    }

    // Owner Functionality
    function changeOwner(address payable _owner) public isOwner {
        owner = _owner;
    }

    function changeFee(uint256 _amount) public isOwner {
        transactionFee = _amount;
    }

    // Public Functionality
    function create(Pixel[] memory _pixels) public payable {
        require(msg.sender.balance >= msg.value, "Not enough funds");

        Creator memory creator = Creator({
            id: _currentTokenID,
            owner: msg.sender,
            pixelIds: new bytes32[](_pixels.length)
        });

        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory p = _pixels[i];
            p.id = getHashFromCords(p.x, p.y);
            p.creatorId = _currentTokenID;
            p.owner = msg.sender;
            creator.pixelIds[i] = p.id;
            pixels.push(p);
        }

        creators[_currentTokenID] = creator;
        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID, 1, "");
        _incrementTokenTypeId();
    }

    function addPixels(uint256 _id, Pixel[] memory _pixels) creatorOnly(_id) public payable {
        Creator memory c = creators[_id];

        bytes32[] memory _pixelIds = new bytes32[](c.pixelIds.length + _pixels.length);

        uint256 count = 0;
        for (uint256 i = 0; i < c.pixelIds.length; i++) {
            _pixelIds[i] = c.pixelIds[i];
            count++;
        }

        for (uint256 i = 0; i <  _pixels.length; i++) {
            Pixel memory p = _pixels[i];
            p.id = getHashFromCords(p.x, p.y);
            p.owner = msg.sender;
            _pixelIds[count] = p.id;
            pixels.push(p);
        }

        c.pixelIds = _pixelIds;
    }

    // function sellBlock(address to, uint256 _id) external creatorOnly(_id) returns(Pixel[] memory){
    //     Meta memory currentMeta = blocks[_id];
    //     Meta memory newMeta = Meta({
    //         account: to,
    //         hexColor: currentMeta.hexColor,
    //         x: currentMeta.x,
    //         y: currentMeta.y
    //     });
    //     blocks[_id] = newMeta;

    //     safeTransferFrom(msg.sender, to, _id, 1, "");
    //     return getAllPixels();
    // }


    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }

    function getHashFromCords(uint256 x, uint256 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }
}