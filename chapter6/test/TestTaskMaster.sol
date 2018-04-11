pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TaskMaster.sol";

contract TestTaskMaster {
  function testInitialBalance() {
    TaskMaster taskMaster = TaskMaster(DeployedAddresses.TaskMaster());
    uint expectedBalance = 10000;
    uint actualBalance = taskMaster.getBalance(tx.origin);
    Assert.equal(actualBalance, expectedBalance, "Owner should have 10000 wei");
}

/* contract TestMetacoin {

  function testInitialBalanceUsingDeployedContract() {
    MetaCoin meta = MetaCoin(DeployedAddresses.MetaCoin());

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

  function testInitialBalanceWithNewMetaCoin() {
    MetaCoin meta = new MetaCoin();

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

} */
