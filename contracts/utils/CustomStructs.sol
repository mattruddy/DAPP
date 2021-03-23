// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library CustomStructs {

    struct Dimensions {
        uint256 height;
        uint256 width;
    }

    struct Meta {
        bytes32 name;
        uint256 createDate;
    }

    struct Content {
        uint8[] rgbaArray;
        Dimensions dimensions;
    }

    struct MetaResp {
        uint256 dartId;
        bytes32 name;
        address owner;
        uint256 createDate;
    }
    
}