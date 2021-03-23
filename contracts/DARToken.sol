// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { CustomStructs } from "./utils/CustomStructs.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ProxyRegistry } from "./ProxyRegistry.sol";

contract DARToken is ERC721, Ownable {

    address payable contractOwner;
    address proxyRegistryAddress;
    uint256 private _currentTokenID;
    uint256 public fee;
    mapping (uint256 => CustomStructs.Meta) dartMeta;
    mapping (uint256 => CustomStructs.Content) dartContent;

    constructor(address payable _owner, uint256 _fee, address _proxyRegistryAddress, string memory _baseUri) ERC721("DecentralizedArt", "DRT") {
        contractOwner = _owner;
        fee = _fee;
        proxyRegistryAddress = _proxyRegistryAddress;
        _setBaseURI(_baseUri);
    }

    function getDartsMeta() public view returns(CustomStructs.MetaResp[] memory) {
        CustomStructs.MetaResp[] memory _metas = new CustomStructs.MetaResp[](_currentTokenID);
        for (uint16 i = 0; i < _currentTokenID; i++) {
            CustomStructs.Meta memory _meta = dartMeta[i];
            CustomStructs.MetaResp memory resp = CustomStructs.MetaResp({
                dartId: i,
                owner: ownerOf(i),
                name: _meta.name,
                createDate: _meta.createDate
            });
             _metas[i] = resp;
        }
        return _metas;
    }

    function getDartMeta(uint256 _tokenId) public view returns(CustomStructs.MetaResp memory) {
        CustomStructs.Meta memory _meta = dartMeta[_tokenId];
        return CustomStructs.MetaResp({
            dartId: _tokenId,
            owner: ownerOf(_tokenId),
            name: _meta.name,
            createDate: _meta.createDate
        });
    }

    function getDartContent(uint256 _tokenId) public view returns(CustomStructs.Content memory) {
        return dartContent[_tokenId];
    }

    function createDart(uint8[] memory _pixels, CustomStructs.Dimensions memory _dimensions, bytes32 _name) public payable { 
        require(msg.sender.balance >= msg.value, "Not enough funds");

        CustomStructs.Content memory _content = CustomStructs.Content({
            rgbaArray: _pixels,
            dimensions: _dimensions
        });

        CustomStructs.Meta memory _meta = CustomStructs.Meta({
            name: _name,
            createDate: block.timestamp
        });

        dartContent[_currentTokenID] = _content;
        dartMeta[_currentTokenID] = _meta;
        contractOwner.transfer(msg.value);
        _mint(msg.sender, _currentTokenID);
        _incrementTokenId();
    }

    // Helpers
    function _incrementTokenId() internal {
        _currentTokenID++;
    }

    // Admin
    function changeContactOwner(address payable _owner) public isContractOwner {
        contractOwner = _owner;
    }

    function changeBaseUri(string memory _uri) public isContractOwner {
        // API which is used to grab pixels from blockchain and then generate image
       _setBaseURI(_uri);
    }

    // Modifiers
    modifier isContractOwner() {
        require(msg.sender == contractOwner, "Owner Only");
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