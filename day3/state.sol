// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

contract StateMachine {
    enum State {PENDING, ACTIVE, CLOSED}

    State state = State.PENDING;

    uint256 amount;
    uint256 interest;
    uint256 duration;
    uint256 end;
    address payable public borrower; // only can transfer to a payable address
    address payable public lender;

    constructor(
        uint256 _amount,
        uint256 _interest,
        uint256 _duration,
        address payable _borrower,
        address payable _lender
    ) {
        amount = _amount;
        interest = _interest;
        duration = _duration;
        borrower = _borrower;
        lender = _lender;
    }

    function fund() external onlyBorrower() {
        // address(this).balance built-in property to get the smart contract balance
        require(
            address(this).balance == amount,
            "can only lend the exact amount"
        );
        _transitionTo(State.ACTIVE);
        borrower.transfer(amount);
    }

    function reimburse() external payable onlyBorrower() {
        // msg.value can be only called in a payable function
        require(
            msg.value == amount + interest,
            "borrower need to reimburse exactly amount + interest"
        );
        _transitionTo(State.CLOSED);
        lender.transfer(amount + interest);
    }

    function _transitionTo(State to) internal {
        require(to != State.PENDING, "cannot rollback to PENDING");
        require(to != state, "cannot transition to the same state");

        if (to == State.ACTIVE) {
            require(
                state == State.PENDING,
                "can only go to ACTIVE from PENDING"
            );
            state = State.ACTIVE;
            end = block.timestamp + duration;
        }

        if (to == State.CLOSED) {
            require(state == State.ACTIVE, "can only go to CLOSED from ACTIVE");
            require(block.timestamp >= end, "loan hasnot matured yet");
            state = State.CLOSED;
        }
    }

    modifier onlyBorrower() {
        require(msg.sender == borrower, "only borrower allowed");
        _; // placeholder
    }

    // smart contract can receive eth
    // legacy version
    // function() external payable {}

    // with this function, we can send eth to the smart contract and smart conctract itself will have a balance.
    // I just sent 0.1 eth there: https://kovan.etherscan.io/address/0xf1a5dc5fb5933d8165691382cc42b31d9668da7e
    receive() external payable {}
}
