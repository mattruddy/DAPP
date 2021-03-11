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

    struct Bid {
        address payable fromAddress;
        uint256 amount;
    }

    struct HighestBidResponse {
        uint256 exhibitId;
        address fromAddress;
        uint256 amount;
    }

    struct PixelResponse {
        uint256 exhibitId;
        address owner;
        bytes32 pixelId;
        string hexColor;
        uint256 x;
        uint256 y;
    }

    address payable owner;
    uint256 public pixelFee;
    uint256 private _currentTokenID;
    bytes32[] pixelIds;
    mapping (bytes32 => Pixel) public pixelMap;
    mapping (bytes32 => uint256) public pixelExhibit;
    mapping (uint256 => Exhibit) exhibits;
    mapping (uint256 => Bid) highestBid;
    mapping (uint256 => Bid[]) bidHistory;
    uint256 public maxXPixel;
    uint256 public maxYPixel;
    uint256 public maxPixelsPerExhibit;
    
    mapping (bytes32 => bool) tempPixelMap;

    modifier exhibitCreatorOnly(uint256 _id) {
        require(exhibits[_id].owner == msg.sender, "Creator Only");
        _;
    }

    modifier notExhibitCreator(uint256 _id) {
        require(exhibits[_id].owner != msg.sender, "Cannot be Creator");
        _;
    }

    modifier isContractOwner() {
        require(msg.sender == owner, "Owner Only");
        _;
    }

    constructor(address payable _owner, uint256 _maxCoords, 
                uint256 _maxPixels, uint256 _pixelfee) ERC721("PixelToken", "PXT") {
        owner = _owner;
        maxXPixel = _maxCoords;
        maxYPixel = _maxCoords;
        maxPixelsPerExhibit = _maxPixels;
        pixelFee = _pixelfee;
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
        require(_pixels.length <= maxPixelsPerExhibit, "Too many pixels");
        require(isFullRect(_pixels), "Invalid rectangle");
        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory p = _pixels[i];
            require(p.x <= maxXPixel && p.y <= maxYPixel, "Coordinates are out of bounce");
            p.id = getHashFromCords(p.x, p.y);
            require(pixelMap[p.id].id == 0, "Pixel already taken");
            // Remove from tempPixelMap as it is only
            // used for full rect validation
            delete tempPixelMap[p.id];
            pixelMap[p.id] = p;
            pixelExhibit[p.id] = _currentTokenID;
            pixelIds.push(p.id);
        }

        Exhibit memory exhibit = Exhibit({
            id: _currentTokenID,
            owner: msg.sender
        });
        exhibits[_currentTokenID] = exhibit;
        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID);
        _incrementTokenTypeId();
    }

    function changePixels(uint256 _id, Pixel[] memory _pixels) public exhibitCreatorOnly(_id) {
        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory _pixel = _pixels[i];
            require(pixelExhibit[_pixel.id] == _id);
            Pixel memory map = pixelMap[_pixel.id];
            map.hexColor = _pixel.hexColor;
            pixelMap[_pixel.id] = map;
        } 
    }

    function placeBid(uint256 _id) notExhibitCreator(_id) public payable {
        Bid memory prevHighest = highestBid[_id];
        require(msg.sender.balance >= msg.value);
        require(msg.value > 0 && msg.value > prevHighest.amount);

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

    function acceptBid(uint256 _id) exhibitCreatorOnly(_id) public payable {
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

    function getBidHistoryForExhibit(uint256 _id) public view returns(Bid[] memory) {
        return bidHistory[_id];
    }

    function getAllHighestBids() public view returns(HighestBidResponse[] memory) {
        HighestBidResponse[] memory highestBids = new HighestBidResponse[](_currentTokenID);
        uint256 index = 0;
        for (uint256 i = 0; i < _currentTokenID; i++) {
            if (highestBid[i].amount != 0) {
                Bid memory _bid = highestBid[i];
                HighestBidResponse memory resp = HighestBidResponse({
                    exhibitId: i,
                    fromAddress: _bid.fromAddress,
                    amount: _bid.amount
                });
                highestBids[index] = resp;
                index++;
            }
        }
        return highestBids;
    }

    function _incrementTokenTypeId() private  {
        _currentTokenID++;
    }

    function getHashFromCords(uint256 x, uint256 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }

   function isFullRect(Pixel[] memory _pixels) internal returns(bool) {
        uint256 xMax = 0;
        uint256 yMax = 0;
        uint256 xMin = maxXPixel;
        uint256 yMin = maxYPixel;
        
        for (uint256 i = 0; i < _pixels.length; i++) {
            Pixel memory _pixel = _pixels[i];
            if (_pixel.x > xMax) {
                xMax = _pixel.x;
            }
            if (_pixel.y > yMax) {
                yMax = _pixel.y;
            }
            if (_pixel.x < xMin) {
                xMin = _pixel.x;
            }
            if (_pixel.y < yMin) {
                yMin = _pixel.y;
            }
            bytes32 _id = getHashFromCords(_pixel.x, _pixel.y);
            if (!tempPixelMap[_id]) {
                tempPixelMap[_id] = true;
            } else {
                return false;
            }
        }
        if (_pixels.length < (xMax - xMin + 1) * (yMax - yMin + 1)) {
            return false;
        }
        return true;
   }


    // Admin
    function changeContactOwner(address payable _owner) public isContractOwner {
        owner = _owner;
    }

    function changeMaxXYPixel(uint256 _maxX, uint256 _maxY) public isContractOwner {
        require(_maxX > maxXPixel && _maxY > maxYPixel);
        maxXPixel = _maxX;
        maxYPixel = _maxY;
    }

    function changePixelFee(uint256 _pixelFee) public isContractOwner {
        pixelFee = _pixelFee;
        // $0.50 / pixel; Use chainlink to update pixelFee as the price of ETH changes
    }

    function changeMaxPixelsPerExhibit(uint256 _max) public isContractOwner {
        maxPixelsPerExhibit = _max;
    }
}