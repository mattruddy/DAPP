pragma solidity 0.6.2;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract PixelToken is ERC1155, ChainlinkClient {

    struct Creator {
        uint256 id;
        address payable owner;
    }

    struct Pixel {
        bytes32 id;
        string hexColor;
        uint256 x;
        uint256 y;
    }

    struct PixelResponse {
        uint256 blockId;
        address owner;
        bytes32 pixelId;
        string hexColor;
        uint256 x;
        uint256 y;
    }

    struct Bid {
        address payable fromAddress;
        uint256 amount;
    }

    string public name;
    string public symbol;
    address payable owner;
    uint256 private _currentTokenID;
    bytes32[] pixelIds;
    mapping (bytes32 => Pixel) public pixelMap;
    mapping (bytes32 => uint256) public pixelCreator;
    mapping (uint256 => Creator) creators;
    mapping (uint256 => Bid) highestBid;
    mapping (uint256 => Bid[]) bidHistory;

    // Modifiers
    modifier creatorOnly(uint256 _id) {
        require(creators[_id].owner == msg.sender, "Creator Only");
        _;
    }

    modifier notCreator(uint256 _id) {
        require(creators[_id].owner != msg.sender, "Cannot be Creator");
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

    function getPixels() public view returns(PixelResponse[] memory) {
        PixelResponse[] memory _pixels = new PixelResponse[](pixelIds.length);
        for (uint256 i = 0; i <= _pixels.length; i++) {
            Pixel memory _pixel = pixelMap[pixelIds[i]];
            Creator memory creator = creators[pixelCreator[_pixel.id]];
            PixelResponse memory resp = PixelResponse({
                blockId: i,
                owner: creator.owner,
                pixelId: _pixel.id,
                hexColor: _pixel.hexColor,
                x: _pixel.x,
                y: _pixel.y
            });
             _pixels[i] = resp;
        }
        return _pixels;
    }

    // Public Functionality
    function create(Pixel[] memory _pixels) public payable {
        require(msg.sender.balance >= msg.value, "Not enough funds");

        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory p = _pixels[i];
            p.id = getHashFromCords(p.x, p.y);
            pixelMap[p.id] = p;
            pixelCreator[p.id] = _currentTokenID;
            pixelIds.push(p.id);
        }

        Creator memory creator = Creator({
            id: _currentTokenID,
            owner: msg.sender
        });
        creators[_currentTokenID] = creator;
        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID, 1, "");
        _incrementTokenTypeId();
    }

    function changePixels(uint256 _id, Pixel[] memory _pixels) public creatorOnly(_id) {
        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory _pixel = _pixels[i];
            require(pixelCreator[_pixel.id] == _id);
            Pixel memory map = pixelMap[_pixel.id];
            map.hexColor = _pixel.hexColor;
            pixelMap[_pixel.id] = map;
        }
    }

    function placeBid(uint256 _id) notCreator(_id) public payable {
        Bid memory prevHighest = highestBid[_id];
        require(msg.value > prevHighest.amount);

        if (prevHighest.fromAddress != address(0)) {
            prevHighest.fromAddress.transfer(prevHighest.amount);
            bidHistory[_id].push(prevHighest);
        }

        Bid memory newHighestBidder = Bid({
            amount: msg.value,
            fromAddress: msg.sender
        });
        highestBid[_id] = newHighestBidder;
    }

    function acceptBid(uint256 _id) creatorOnly(_id) public payable {
        Creator memory c = creators[_id];
        c.owner.transfer(highestBid[_id].amount);
        safeTransferFrom(c.owner, highestBid[_id].fromAddress, _id, 1, "");
        c.owner = highestBid[_id].fromAddress;
        creators[_id] = c;
    }

    function getBid(uint256 _id) public view returns(Bid memory) {
        return highestBid[_id];
    }

    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }

    function getHashFromCords(uint256 x, uint256 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }

       // Owner Functionality
    function changeOwner(address payable _owner) public isOwner {
        owner = _owner;
    }
}