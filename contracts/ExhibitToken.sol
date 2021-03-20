// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { RectMath } from "./utils/RectMath.sol";
import { ExhibitStructs } from "./utils/ExhibitStructs.sol";

contract ExhibitToken is ERC721 {

    address payable owner;
    uint16 public maxXPixel;
    uint16 public maxYPixel;
    uint16 public maxPixelsPerExhibit;
    uint16 private _currentTokenID;
    mapping (uint16 => ExhibitStructs.Bounds) bounds;
    mapping (uint16 => uint8[]) rgbArray;
    uint16[] allBounds;

    constructor(address payable _owner, uint16 _maxCoords, uint16 _maxPixels) ERC721("Exhibit", "XBT") {
        owner = _owner;
        maxXPixel = _maxCoords;
        maxYPixel = _maxCoords;
        maxPixelsPerExhibit = _maxPixels;
    }

    function getPixels() public view returns(ExhibitStructs.ExhibitResp[] memory) {
        return pixelConverter();
    }

    function create(uint8[] memory _pixels, ExhibitStructs.Bounds memory _bounds) public payable 
        isValidLength(uint16((_pixels.length / 3)), _bounds)
        isInBounds(_bounds)
        isPixelsValid(_pixels)
        isOnCanvas(_bounds) 
{      
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

    // Helpers

    function _incrementTokenTypeId() internal {
        _currentTokenID++;
    }

    function getHashFromCords(uint16 x, uint16 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }

   function pixelConverter() internal view returns (ExhibitStructs.ExhibitResp[] memory) {
        ExhibitStructs.ExhibitResp[] memory _exhibit = new ExhibitStructs.ExhibitResp[](_currentTokenID);
        for (uint16 i = 0; i < _currentTokenID; i++) {
            uint8[] memory _rgbArray = rgbArray[i];
            ExhibitStructs.Bounds memory _bounds = bounds[i];
            ExhibitStructs.ExhibitResp memory resp = ExhibitStructs.ExhibitResp({
                exhibitId: i,
                owner: ownerOf(i),
                rgbArray: _rgbArray,
                bounds: _bounds
            });
             _exhibit[i] = resp;
        }
        return _exhibit;
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

    function changeMaxPixelsPerExhibit(uint16 _max) public isContractOwner {
        maxPixelsPerExhibit = _max;
    }

    // Modifiers

    modifier exhibitCreatorOnly(uint16 _id) {
        require(ownerOf(_id) == msg.sender, "Creator Only");
        _;
    }

    modifier isContractOwner() {
        require(msg.sender == owner, "Owner Only");
        _;
    }

    modifier isValidLength(uint256 length, ExhibitStructs.Bounds memory _bounds) {
        require(RectMath.validLength(length, _bounds), "Invalid pixels within bounds");
        _;
    }

    modifier isInBounds(ExhibitStructs.Bounds memory _bounds) {
        require(!RectMath.validBounds(allBounds, _bounds), "Bounds overlap with another");
        _;
    }

    modifier isPixelsValid(uint8[] memory _pixels) {
        require(_pixels.length <= maxPixelsPerExhibit * 3, "Too many pixels");
        _;
    }

    modifier isOnCanvas(ExhibitStructs.Bounds memory _newBounds) {
        require(RectMath.onCanvas(_newBounds, maxXPixel, maxYPixel), "Y or X is too large");
        _;
    }
}