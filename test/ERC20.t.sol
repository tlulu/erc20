// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ERC20} from "../src/ERC20.sol";
import {MonadToken} from "../src/MonadToken.sol";

contract ERC20Test is Test {
    MonadToken public token;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        token = new MonadToken();
        token.mint(alice, 1000);
    }

    function test_mint() public {
        assertEq(token.totalSupply(), 1000);
        token.mint(100);
        assertEq(token.totalSupply(), 1100);
    }

    function test_mint_fails_to_zero_address() public {
        vm.expectRevert("Cannot mint to the zero address");
        token.mint(address(0x0), 100);
    }

    function test_name() public {
        assertEq(token.name(), "MonadToken");
    }

    function test_symbol() public {
        assertEq(token.symbol(), "MON");
    }

    function test_balance() public {
        assertEq(token.balanceOf(alice), 1000);
        assertEq(token.balanceOf(bob), 0);
    }

    function test_transfer() public {
        vm.prank(alice); // Pretend to be Alice for the next call
        token.transfer(bob, 500);
        assertEq(token.balanceOf(alice), 500);
        assertEq(token.balanceOf(bob), 500);
    }

    function test_transfer_fails_insufficient_balance() public {
        vm.prank(bob);
        vm.expectRevert("Insufficient balance");
        token.transfer(alice, 500);
    }

    function test_approve_and_allowance() public {
        assertEq(token.allowance(alice, bob), 0);
        vm.prank(alice);
        token.approve(bob, 300);
        assertEq(token.allowance(alice, bob), 300);
    }

    function test_approve_race_condition() public {
        vm.prank(alice);
        token.approve(bob, 300);
        assertEq(token.allowance(alice, bob), 300);

        vm.prank(alice); // Need to pretend to be Alice again because the previous call has already reverted
        vm.expectRevert("Need to set existing allowance to zero first");
        token.approve(bob, 400);

        vm.prank(alice);
        token.approve(bob, 0);
        assertEq(token.allowance(alice, bob), 0);

        vm.prank(alice);
        token.approve(bob, 400);
        assertEq(token.allowance(alice, bob), 400);
    }

    function test_transferFrom() public {
        vm.prank(alice);
        token.approve(bob, 300);

        vm.prank(bob);
        token.transferFrom(alice, bob, 200);

        assertEq(token.balanceOf(alice), 800);
        assertEq(token.balanceOf(bob), 200);
        assertEq(token.allowance(alice, bob), 100);
    }

    function test_transferFrom_fails_without_approval() public {
        vm.prank(bob);
        vm.expectRevert("Allowance exceeded");
        token.transferFrom(alice, bob, 200);
    }
}
