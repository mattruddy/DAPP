// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library CustomStructs {

    struct Dimensions {
        uint16 height;
        uint16 width;
    }

    struct DartResp {
        uint16 dartId;
        address owner;
        uint8[] rgbArray;
        Dimensions dimensions;
    }
    
}