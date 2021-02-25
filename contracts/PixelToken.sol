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
        bytes32 id;
        string hexColor;
        uint256 x;
        uint256 y;
    }

    Pixel[] public pixels;

    uint256 private _currentTokenID = 0;
    mapping (uint256 => Creator) public creators;


    // Contract name
    string public name;
    // Contract symbol
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

    // Admin
    function changeOwner(address payable _owner) public isOwner {
        owner = _owner;
    }

    function changeFee(uint256 _amount) public isOwner {
        transactionFee = _amount;
    }

    // Public
    function create(Pixel[] memory _pixels) public payable {
        //require(msg.value == transactionFee, 'Value is not enough');
       // require(x >= 0 && x <= maxX, "X must be between 0 and 7000");
       // require(y >= 0 && y <= maxY, "Y must be between 0 and 4000");
        require(msg.sender.balance >= msg.value, "Not enough funds");

        Creator memory creator = Creator({
            id: _currentTokenID,
            owner: msg.sender,
            pixelIds: new bytes32[](_pixels.length)
        });

        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory p = _pixels[i];
            p.id = getHashFromCords(p.x, p.y);
            creator.pixelIds[i] = p.id;
        }

        creators[_currentTokenID] = creator;
        // for (uint256 i = 0; i < _pixels.length; i++) {

        //     creator.pixels[i] = _pixels[i];
        // }

        // creators[_currentTokenID] = blk;
        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID, 1, "");
        _incrementTokenTypeId();
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

    // function getAllPixels() public view returns(mapping (bytes32 => Pixel)) {
    //     return pixels;
    // }

    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }

    function getHashFromCords(uint256 x, uint256 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }
}