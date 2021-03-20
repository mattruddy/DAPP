// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;

import { OwnableDelegateProxy } from "./OwnableDelegateProxy.sol";

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}