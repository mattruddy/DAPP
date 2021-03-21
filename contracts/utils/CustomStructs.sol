// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library CustomStructs {

    struct Dimensions {
        uint256 height;
        uint256 width;
    }

    struct DartMeta {
        uint8[] rgbaArray;
        Dimensions dimensions;
        bytes32 name;
    }

    struct DartResp {
        uint256 dartId;
        bytes32 name;
        address owner;
        uint8[] rgbaArray;
        Dimensions dimensions;
    }
    
}