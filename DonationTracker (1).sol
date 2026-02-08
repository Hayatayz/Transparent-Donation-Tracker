// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract TransparentCharity {
    address public owner;
    string public ownerName;
    string public ownerIDHash;
    string public campaignName;
    uint public totalDonations;
    mapping(address => uint) public donations;
    address[] public donors;

    struct WithdrawalRecord {
        uint amount;
        uint timestamp;
    }
    WithdrawalRecord[] public withdrawals;

    event DonationReceived(address indexed donor, uint amount);
    event FundsWithdrawn(uint amount, uint timestamp);

    constructor(
        string memory _campaignName,
        string memory _ownerName,
        string memory _ownerIDHash
    ) {
        owner = msg.sender;
        campaignName = _campaignName;
        ownerName = _ownerName;
        ownerIDHash = _ownerIDHash;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function donate() public payable {
        require(msg.value > 0, "Send some ETH");
        if(donations[msg.sender] == 0) {
            donors.push(msg.sender);
        }
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public onlyOwner {
        require(_amount <= address(this).balance, "Not enough funds");
        payable(owner).transfer(_amount);
        withdrawals.push(WithdrawalRecord({
            amount: _amount,
            timestamp: block.timestamp
        }));
        emit FundsWithdrawn(_amount, block.timestamp);
    }

    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getTotalDonors() public view returns(uint) {
        return donors.length;
    }
}
