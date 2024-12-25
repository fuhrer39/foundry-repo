// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol"; //this makes us know whats the latest contract that has benen deployed without knownig its address
import {Fund} from "../src/FundMe.sol";
contract FundFundMe is Script {
    uint256 constant SEND_VALUE  = 0.1 ether;
    function fundFundMe(address mostRecentDeployed) public {
        
        Fund(payable(mostRecentDeployed)).fund{value: SEND_VALUE}(); //you can do it like this or create a new instance of it
        
        console.log("Funded fundMe with %s", SEND_VALUE);

    }
    
    
    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); //it works by looking at the broadcast folder and based on the chain id it grappes the latest deployed contract
        vm.startBroadcast();
        fundFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script{

    function withdrawFundMe(address mostRecentDeployed) public {
        vm.startBroadcast();
        Fund(payable(mostRecentDeployed)).withdraw(); //you can do it like this or create a new instance of it
        vm.stopBroadcast();
        

    }
    
    
    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); //it works by looking at the broadcast folder and based on the chain id it grappes the latest deployed contract
        vm.startBroadcast();
        withdrawFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}