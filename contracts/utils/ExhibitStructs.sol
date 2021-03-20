// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

library ExhibitStructs {

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
    
}