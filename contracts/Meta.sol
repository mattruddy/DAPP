pragma solidity 0.6.2;

contract Meta {

    string name;

    function setName(string memory _name) public {
        name = _name;
    }

}