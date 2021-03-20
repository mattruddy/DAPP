// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { RectMath } from "./utils/RectMath.sol";
import { CustomStructs } from "./utils/CustomStructs.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ProxyRegistry } from "./ProxyRegistry.sol";

contract DARToken is ERC721, Ownable {

    address payable contractOwner;
    address proxyRegistryAddress;
    uint256 private _currentTokenID;
    uint256 public maxPixelsPerExhibit;
    uint256 public fee;
    mapping (uint256 => uint8[]) rgbArray;
    mapping (uint256 => CustomStructs.Dimensions) dartDimension;

    constructor(address payable _owner, uint256 _fee, address _proxyRegistryAddress) ERC721("DecentralizedArt", "DRT") {
        contractOwner = _owner;
        fee = _fee;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function getDarts() public view returns(CustomStructs.DartResp[] memory) {
        CustomStructs.DartResp[] memory _darts = new CustomStructs.DartResp[](_currentTokenID);
        for (uint16 i = 0; i < _currentTokenID; i++) {
            uint8[] memory _rgbArray = rgbArray[i];
            CustomStructs.Dimensions memory _dimensions = dartDimension[i];
            CustomStructs.DartResp memory resp = CustomStructs.DartResp({
                dartId: i,
                owner: ownerOf(i),
                rgbArray: _rgbArray,
                dimensions: _dimensions
            });
             _darts[i] = resp;
        }
        return _darts;
    }

    function getDart(uint256 _tokenId) public view returns(CustomStructs.DartResp memory) {
        return CustomStructs.DartResp({
            dartId: _tokenId,
            owner: ownerOf(_tokenId),
            rgbArray: rgbArray[_tokenId],
            dimensions: dartDimension[_tokenId]
        });
    }

    function createDart(uint8[] memory _pixels, CustomStructs.Dimensions memory _dimensions) public payable 
                                                                    isValidLength(uint256((_pixels.length / 4)), _dimensions) 
                                                                    isPixelsValid(_pixels) { 

        require(msg.sender.balance >= msg.value, "Not enough funds");
        rgbArray[_currentTokenID] = _pixels;
        dartDimension[_currentTokenID] = _dimensions;
        contractOwner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID);
        _incrementTokenId();
    }

    // Helpers
    function _incrementTokenId() internal {
        _currentTokenID++;
    }

    function getHashFromCords(uint256 x, uint256 y) internal pure returns (bytes32) {
        return sha256(abi.encodePacked(x, y));
   }

    // Admin
    function changeContactOwner(address payable _owner) public isContractOwner {
        contractOwner = _owner;
    }

    function changeMaxPixelsPerExhibit(uint16 _max) public isContractOwner {
        maxPixelsPerExhibit = _max;
    }

    modifier isContractOwner() {
        require(msg.sender == contractOwner, "Owner Only");
        _;
    }

    modifier isValidLength(uint256 length, CustomStructs.Dimensions memory _dimensions) {
        require(RectMath.validLength(length, _dimensions), "Invalid pixel dimensions");
        _;
    }

    modifier isPixelsValid(uint8[] memory _pixels) {
        require(_pixels.length <= maxPixelsPerExhibit * 4, "Too many pixels");
        _;
    }

    // Overrides
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }
}