pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PixelToken is ERC721 {

    struct Exhibit {
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
        uint256 exhibitId;
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

    address payable owner;
    uint256 private _currentTokenID;
    bytes32[] pixelIds;
    mapping (bytes32 => Pixel) public pixelMap;
    mapping (bytes32 => uint256) public pixelExhibit;
    mapping (bytes32 => Exhibit) exhibitHash; 
    mapping (uint256 => Exhibit) exhibits;
    mapping (uint256 => Bid) highestBid;
    mapping (uint256 => Bid[]) bidHistory;

    event PixelsChanged(Pixel[] _pixels);

    modifier creatorOnly(uint256 _id) {
        require(exhibits[_id].owner == msg.sender, "Creator Only");
        _;
    }

    modifier notCreator(uint256 _id) {
        require(exhibits[_id].owner != msg.sender, "Cannot be Creator");
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, "Owner Only");
        _;
    }

    constructor() ERC721("PixelToken", "PXT") {
        owner = 0x16Fb96a5fa0427Af0C8F7cF1eB4870231c8154B6;
    }

    function getPixels() public view returns(PixelResponse[] memory) {
        PixelResponse[] memory _pixels = new PixelResponse[](pixelIds.length);
        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory _pixel = pixelMap[pixelIds[i]];
            Exhibit memory creator = exhibits[pixelExhibit[_pixel.id]];
            PixelResponse memory resp = PixelResponse({
                exhibitId: creator.id,
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

    function create(Pixel[] memory _pixels) public payable {
        require(msg.sender.balance >= msg.value, "Not enough funds");

        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory p = _pixels[i];
            p.id = getHashFromCords(p.x, p.y);
            pixelMap[p.id] = p;
            pixelExhibit[p.id] = _currentTokenID;
            pixelIds.push(p.id);
        }

        Exhibit memory creator = Exhibit({
            id: _currentTokenID,
            owner: msg.sender
        });
        exhibits[_currentTokenID] = creator;
        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID);
        _incrementTokenTypeId();
    }

    function changePixels(uint256 _id, Pixel[] memory _pixels) public creatorOnly(_id) {
        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory _pixel = _pixels[i];
            require(pixelExhibit[_pixel.id] == _id);
            Pixel memory map = pixelMap[_pixel.id];
            map.hexColor = _pixel.hexColor;
            pixelMap[_pixel.id] = map;
        } 
        emit PixelsChanged(_pixels);
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
        Exhibit memory c = exhibits[_id];
        c.owner.transfer(highestBid[_id].amount);
        safeTransferFrom(c.owner, highestBid[_id].fromAddress, _id);
        c.owner = highestBid[_id].fromAddress;
        exhibits[_id] = c;

        bidHistory[_id].push(highestBid[_id]);
        delete highestBid[_id];
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

    function changeOwner(address payable _owner) public isOwner {
        owner = _owner;
    }
}