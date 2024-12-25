// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil deploy mocks
    //otherwise grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }else {
            activeNetworkConfig = getAnvilConfig();
        }
    }
    
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306); // NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;   
    }

    function getMainnetEthConfig() public pure returns(NetworkConfig memory) {
        //price feed address
        NetworkConfig memory ethConfig = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); // NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;   
        
    }

    function getAnvilConfig() public returns(NetworkConfig memory){
        //price feed address
        if (activeNetworkConfig.priceFeed != address(0)) { //here basically not every time we need to create the mock contact and get the price feed we saying if the address != 0 so there is an address than its fine keep that address
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(8, 2000e8); //8 because the price of eth in usd has 8 decimals
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(address(mockV3Aggregator)); // NetworkConfig({priceFeed: address(mockV3Aggregator)}); we change the type of it to an address
        return anvilConfig;
    }

}