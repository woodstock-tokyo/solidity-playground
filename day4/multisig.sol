// SPDX-License-Identifier: ISC
pragma solidity ^0.7.0;

contract Wallet {
    address[] approvers;
    uint256 quorum;

    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }

    mapping(uint256 => Transfer) transfers;
    uint256 nextId; // 0 as default
    /*transfer id*/
    mapping(address => mapping(uint256 => bool)) approvals;

    Transfer public result;

    constructor(address[] memory _approvers, uint256 _quorum) {
        approvers = _approvers;
        quorum = _quorum;
    }

    function createTransfer(uint256 amount, address payable to)
        external
        onlyApprover()
    {
        transfers[nextId] = Transfer(nextId, amount, to, 0, false);
        nextId++;
    }

    function sendTransfer(uint256 id) external onlyApprover() {
        // todo
        Transfer storage transfer = transfers[id];
        require(transfer.sent == false, "transfer has already been sent");

        if (approvals[msg.sender][id] == false) {
            approvals[msg.sender][id] = true;
            transfer.approvals++;
        }

        if (transfer.approvals >= quorum) {
            transfer.sent = true;

            address payable to = transfer.to;
            uint256 amount = transfer.amount;
            // fire
            to.transfer(amount);
        }

        //// bad practice
        // if (transfer.approvals >= quorum) {
        //    address payable to = transfer.to;
        //    uint amount = transfer.amount;
        //    // fire
        //    to.transfer(amount);
        //    transfer.sent = true;
        // }
    }

    function approve(uint256 id) external onlyApprover() {
        approvals[msg.sender][id] = true;
    }

    function testStorage(uint256 id) external {
        Transfer storage transfer = transfers[id];
        transfer.amount = 99999;

        result = transfers[id];
    }

    function testMemory(uint256 id) external {
        Transfer memory transfer = transfers[id];
        transfer.amount = 66666;

        result = transfers[id];
    }

    modifier onlyApprover() {
        bool isApprover = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                isApprover = true;
            }
        }

        require(isApprover, "must be approver");
        _;
    }
}
