// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import { CustomStructs } from "./CustomStructs.sol";

library RectMath {
   function validLength(uint256 length, CustomStructs.Dimentions memory _dimentions) internal pure returns(bool) {
       return length == (_dimentions.height * _dimentions.width);
   }
}