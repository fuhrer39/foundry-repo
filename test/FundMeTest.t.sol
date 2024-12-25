// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Fund} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    Fund fundMe;
    address USER = makeAddr("USER"); // this will make an address for us 
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new Fund(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);//this gives the user address any fake money we pass it
    }

    /*function test() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }*/

    function testVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line should revert
        fundMe.fund(); // it sends with it the value of 0 because if we want to send some eth we do fundMe.fund{value: 1e18}() this is 5 eth

    }

    function testFundUpdatesFundedDataStructure() public {
        vm.startPrank(USER); //hey the next transaction is sent by the user address
        fundMe.fund{value: 1e18}();
        vm.stopPrank();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 1e18);
    }

    function testAddsFubderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: 1e18}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    
    
    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: 1e18}();

        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleDunder() public {
        vm.prank(USER);
        fundMe.fund{value: 1e18}();
        uint256 startingOwnerBalance = fundMe.getOwner().balance; //.balance makes you get the balance of an address
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner()); //it should work cause only the owner can withdraw
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingOwnerBalance - startingOwnerBalance, 3e18);
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testMultipleFunders() public {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i =startingFunderIndex; i< numberOfFunders; i++) { //hoax is a combination between vm.deal and vm.prank it prank its first argument and give it soma money with the second argument
            hoax(address(i), 3e18); //here we converter a number to address this only possible if the number is in uint160 because 160 bytes is the size of an address
            fundMe.fund{value: 1e18}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


        vm.startPrank(USER);
        fundMe.fund{value: 1e18}();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);

        
    }
}
