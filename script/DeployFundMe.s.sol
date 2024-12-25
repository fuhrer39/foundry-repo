// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {Fund} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (Fund) {
        //Before startBroadcast => not a real transaction happens just a simulation
        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig(); //we make in () because it returns a struct
        
        // after startBroadcast => real transaction happens
        vm.startBroadcast();
        Fund fundMe = new Fund(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
