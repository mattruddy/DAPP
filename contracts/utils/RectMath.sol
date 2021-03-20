// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import { CustomStructs } from "./CustomStructs.sol";

library RectMath {
   function validLength(uint256 length, CustomStructs.Dimensions memory _dimensions) internal pure returns(bool) {
       return length == (_dimensions.height * _dimensions.width);
   }
}