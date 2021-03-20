// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library CustomStructs {

    struct Dimensions {
        uint256 height;
        uint256 width;
    }

    struct DartResp {
        uint256 dartId;
        address owner;
        uint8[] rgbArray;
        Dimensions dimensions;
    }
    
}