// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ExhibitToken is ERC721 {

    struct Bounds {
        Coord topLeft;
        Coord bottomRight;
    }

    struct Coord {
        uint16 x;
        uint16 y;
    }

    struct ExhibitResp {
        uint16 exhibitId;
        address owner;
        uint8[] rgbArray;
        Bounds bounds;
    }

    address payable owner;
    uint16 public pixelFee;
    uint16 public maxXPixel;
    uint16 public maxYPixel;
    uint16 public maxPixelsPerExhibit;
    uint16 private _currentTokenID;
    mapping (uint16 => Bounds) bounds;
    mapping (uint16 => uint8[]) rgbArray;
    uint16[] allBounds;
    address public auctionAddress;

    modifier exhibitCreatorOnly(uint16 _id) {
        require(ownerOf(_id) == msg.sender, "Creator Only");
        _;
    }

    modifier isContractOwner() {
        require(msg.sender == owner, "Owner Only");
        _;
    }

    modifier isValidLength(uint256 length, Bounds memory _bounds) {
        require(length == (_bounds.bottomRight.x - _bounds.topLeft.x + 1) * (_bounds.bottomRight.y - _bounds.topLeft.y + 1), "Invalid pixels within bounds");
        _;
    }

    modifier isInBounds(Bounds memory _bounds) {
        require(!validBounds(allBounds, _bounds), "Bounds overlap with another");
        _;
    }

    modifier isPixelsValid(uint8[] memory _pixels) {
        require(_pixels.length <= maxPixelsPerExhibit * 3, "Too many pixels");
        _;
    }

    modifier isOnCanvas(Bounds memory _newBounds) {
        require(_newBounds.topLeft.x <= maxXPixel && _newBounds.topLeft.y <= maxYPixel 
            && _newBounds.bottomRight.x <= maxXPixel && _newBounds.bottomRight.y <= maxYPixel, "Y or X is too large");
        _;
    }

    constructor(address payable _owner, uint16 _maxCoords, 
                uint16 _maxPixels, uint16 _pixelfee, address _auctionAddress) ERC721("Exhibit", "XBT") {
        owner = _owner;
        maxXPixel = _maxCoords;
        maxYPixel = _maxCoords;
        maxPixelsPerExhibit = _maxPixels;
        pixelFee = _pixelfee;
        auctionAddress = _auctionAddress;
    }

    function getPixels() public view returns(ExhibitResp[] memory) {
        ExhibitResp[] memory _exhibit = new ExhibitResp[](_currentTokenID);
        for (uint16 i = 0; i < _currentTokenID; i++) {
            uint8[] memory _rgbArray = rgbArray[i];
            Bounds memory _bounds = bounds[i];
            ExhibitResp memory resp = ExhibitResp({
                exhibitId: i,
                owner: ownerOf(i),
                rgbArray: _rgbArray,
                bounds: _bounds
            });
             _exhibit[i] = resp;
        }
        return _exhibit;
    }

    function create(uint8[] memory _pixels, Bounds memory _bounds) public payable 
                isValidLength(uint16((_pixels.length / 3)), _bounds)
                isInBounds(_bounds)
                isPixelsValid(_pixels)
                isOnCanvas(_bounds) {
        require(msg.sender.balance >= msg.value, "Not enough funds");
        bounds[_currentTokenID] = _bounds;
        rgbArray[_currentTokenID] = _pixels;
        allBounds.push(_bounds.topLeft.x);
        allBounds.push(_bounds.topLeft.y);
        allBounds.push(_bounds.bottomRight.x);
        allBounds.push(_bounds.bottomRight.y);
        owner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID);
        _incrementTokenTypeId();
    }

    function changePixels(uint16 _id, uint8[] memory _rgbArray) public exhibitCreatorOnly(_id) {
        rgbArray[_id] = _rgbArray;
    }

    // Helpers
    function _incrementTokenTypeId() internal {
        _currentTokenID++;
    }

    function getHashFromCords(uint16 x, uint16 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }

   function validBounds(uint16[] memory _bounds, Bounds memory _newBounds) internal pure returns(bool) {
       for (uint256 i = 0; i < _bounds.length; i += 4) {
           uint16 _topLeftX = _bounds[i];
           uint16 _topLeftY = _bounds[i+1];
           uint16 _bottomRightX = _bounds[i+2];
           uint16 _bottomRightY = _bounds[i+3];

           if (_topLeftX <= _newBounds.topLeft.x 
                    && _topLeftY <= _newBounds.topLeft.y
                    && _bottomRightX > _newBounds.topLeft.x
                    && _bottomRightY > _newBounds.topLeft.y) {
                return true;
           } else if (_topLeftX <= _newBounds.bottomRight.x 
                    && _topLeftY <= _newBounds.bottomRight.y
                    && _bottomRightX > _newBounds.bottomRight.x
                    && _bottomRightY > _newBounds.bottomRight.y) {
                return true;
           } 
       }
       return false;
   }

    // Admin
    function changeContactOwner(address payable _owner) public isContractOwner {
        owner = _owner;
    }

    function changeMaxXYPixel(uint16 _maxX, uint16 _maxY) public isContractOwner {
        require(_maxX > maxXPixel && _maxY > maxYPixel);
        maxXPixel = _maxX;
        maxYPixel = _maxY;
    }

    function changePixelFee(uint16 _pixelFee) public isContractOwner {
        pixelFee = _pixelFee;
    }

    function changeMaxPixelsPerExhibit(uint16 _max) public isContractOwner {
        maxPixelsPerExhibit = _max;
    }
}