// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { RectMath } from "./utils/RectMath.sol";
import { CustomStructs } from "./utils/CustomStructs.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract OwnableDelegateProxy {}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

contract DARToken is ERC721, Ownable {

    address payable contractOwner;
    address proxyRegistryAddress;
    uint16 private _currentTokenID;
    uint16 public maxPixelsPerExhibit;
    uint16 public fee;
    mapping (uint16 => uint8[]) rgbArray;
    mapping (uint16 => CustomStructs.Dimentions) dartDimention;

    constructor(address payable _owner, uint16 _fee, address _proxyRegistryAddress) ERC721("DecentralizedArt", "DRT") {
        contractOwner = _owner;
        fee = _fee;
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function getDarts() public view returns(CustomStructs.DartResp[] memory) {
        CustomStructs.DartResp[] memory _darts = new CustomStructs.DartResp[](_currentTokenID);
        for (uint16 i = 0; i < _currentTokenID; i++) {
            uint8[] memory _rgbArray = rgbArray[i];
            CustomStructs.Dimentions memory _dimentions = dartDimention[i];
            CustomStructs.DartResp memory resp = CustomStructs.DartResp({
                dartId: i,
                owner: ownerOf(i),
                rgbArray: _rgbArray,
                dimentions: _dimentions
            });
             _darts[i] = resp;
        }
        return _darts;
    }

    function create(uint8[] memory _pixels, 
            CustomStructs.Dimentions memory _dimentions) 
                    public payable 
                    isValidLength(uint16((_pixels.length / 3)), _dimentions) 
                    isPixelsValid(_pixels) { 
                             
        require(msg.sender.balance >= msg.value, "Not enough funds");
        rgbArray[_currentTokenID] = _pixels;
        dartDimention[_currentTokenID] = _dimentions;
        contractOwner.transfer(msg.value);
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

    modifier isValidLength(uint256 length, CustomStructs.Dimentions memory _dimentions) {
        require(RectMath.validLength(length, _dimentions), "Invalid pixel dimentions");
        _;
    }

    modifier isPixelsValid(uint8[] memory _pixels) {
        require(_pixels.length <= maxPixelsPerExhibit * 3, "Too many pixels");
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