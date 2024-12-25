// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner(); //this saves gas then require

contract Fund {
    using PriceConverter for uint256;
    address private immutable owner; // immutable like constant but we write them in variable which they were not assigned in their declaration

    uint256 public constant MINIMUM_USD = 5e18; //constant save gas
    AggregatorV3Interface private s_priceFeed;

    address[] private funders;
    mapping(address => uint256) private addressToAmountFunded;

    constructor(address priceFeed) {
        owner = msg.sender; //msg.sender in the constructor the one who deployed the contract
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "didn't send enough eth"
        ); // msg.value in wei 1eth = 1e18 wei 1 and 18 zero
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] =
            addressToAmountFunded[msg.sender] +
            msg.value; //in the first addresstoamou[msg.sender] = 0 but if the sender add money its gonna add to the previous amount
    }
    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;

            // Reset the array
            funders = new address[](0);
            //send eth with 3 different ways
            //transfer
            payable(msg.sender).transfer(address(this).balance); //if it failed then the function gets reverted or you get error
            //send
            bool sendSuccess = payable(msg.sender).send(address(this).balance);
            require(sendSuccess, "Send Failed");
            //call
            (bool callSuccess /*bytes memory dataReturned*/, ) = payable(
                msg.sender
            ).call{value: address(this).balance}("");
            require(callSuccess, "Call Failed");
        }
    }

    modifier onlyOwner() {
        //require(msg.sender == owner, "Must be the owner");
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        //receive function gets called whenever you send money to the contract without the fund function or in general in a different way then the one that exists in the contract
        fund();
    }

    fallback() external payable {
        //like receive but it gets called wharever data is transfered with money or without money
        fund();
    }

    function getAddressToAmountFunded(address fundingAddress) external view returns(uint256) {
        return addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns(address) {
        return funders[index];
    }

    function getOwner() external view returns(address){
        return owner;
    }
}
