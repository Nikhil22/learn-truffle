pragma solidity ^0.4.17;


contract Organization {
    mapping (address => uint) public balances; // balances of everyone
    uint public totalBalance; // total balance of the contract
    address public owner; // owner of the contract

    event LogTransfer(address indexed _from, address indexed _to, uint256 _value);

    function Organization() public {
        balances[msg.sender] = 10000;
    }

    function reward(address receiver, uint amount) public returns(bool sufficient) {
        if (balances[msg.sender] < amount) return false;
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        LogTransfer(msg.sender, receiver, amount);
        return true;
    }

    function getBalance(address addr) public view returns(uint) {
        return balances[addr];
    }
}
