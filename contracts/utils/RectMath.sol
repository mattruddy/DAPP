// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import { ExhibitStructs } from "./ExhibitStructs.sol";

library RectMath {

    function validBounds(uint16[] memory _bounds, ExhibitStructs.Bounds memory _newBounds) internal pure returns(bool) {
       for (uint256 i = 0; i < _bounds.length; i += 4) {
           uint16 _topLeftX = _bounds[i];
           uint16 _topLeftY = _bounds[i+1];
           uint16 _bottomRightX = _bounds[i+2];
           uint16 _bottomRightY = _bounds[i+3];

           if (_topLeftX <= _newBounds.topLeft.x 
                    && _topLeftY <= _newBounds.topLeft.y
                    && _bottomRightX > _newBounds.topLeft.x
                    && _bottomRightY > _newBounds.topLeft.y) {
                return true;
           } else if (_topLeftX <= _newBounds.bottomRight.x 
                    && _topLeftY <= _newBounds.bottomRight.y
                    && _bottomRightX > _newBounds.bottomRight.x
                    && _bottomRightY > _newBounds.bottomRight.y) {
                return true;
           } 
       }
       return false;
   }

   function validLength(uint256 length, ExhibitStructs.Bounds memory _bounds) internal pure returns(bool) {
       return length == (_bounds.bottomRight.x - _bounds.topLeft.x + 1) * (_bounds.bottomRight.y - _bounds.topLeft.y + 1);
   }

    function onCanvas(ExhibitStructs.Bounds memory _newBounds, uint16 maxXPixel, uint16 maxYPixel) internal pure returns(bool) {
        return _newBounds.topLeft.x <= maxXPixel && _newBounds.topLeft.y <= maxYPixel 
            && _newBounds.bottomRight.x <= maxXPixel && _newBounds.bottomRight.y <= maxYPixel;
    }
}