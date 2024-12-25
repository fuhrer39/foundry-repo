// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // Addrress  0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI

        //AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFedd); //this the pricefeed from chainlink that converts eth to usd eth/usd in the sepolia network
        (, int256 price, , , ) = priceFeed.latestRoundData(); //we name the answer in the original code the price here
        // the price is gonna be like 2000. 00000000 with 8 zeros add to it so we gonna multiple it by 10
        return (uint256(price) * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        AggregatorV3Interface priceFeed;
        uint256 ethPrice = getPrice(priceFeed); // eth price is gonna be something like 2000. 000000000000000000 10 zero
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18; // because ethprice have 18 zero and also the ethamount like 1 eth so we have 36 zeros so we need to divide by 18 zero so we have 18 zeros in the ethAmountInUsd
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        AggregatorV3Interface priceFedd;
        return AggregatorV3Interface(priceFedd).version();
    }
}
