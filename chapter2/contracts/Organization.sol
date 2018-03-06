pragma solidity ^0.4.17;


contract Organization {
    uint public totalBalance; // total balance of the contract
    address public owner; // owner of the contract

    // all possibles statuses for a task
    enum TaskStatus {
        TODO,
        INPROGESS,
        FINISHED,
        ACCEPTED,
        REJECTED
    }

    struct Task {
        string name; // name of the task, i.e "Website Logo"
        string desc; // description of the task, i.e "Make website logo using etc"
        address doer; // doer of the task
        address issuer; // issuer of the task
        address reviewer; // reviewer of the task
        uint reward; // reward of the task
        TaskStatus status; // status of the task
        bytes32 id; // id of the task
    }

    bytes32[] private tasksIDs; // array of tasks IDs
    mapping (bytes32 => Task) private taskMapping; // mapping: {Task ID => Task}

    address[] public doers; // an array of task doers
    mapping (address => bool) private doerActiveMapping; // mapping: {Doer Address => Active State}
    mapping (address => uint) private doerPayablesMapping; // mapping : {Doer Address => Amount Owed To Doer}

    event LogDoerAdded(address doer); // emitted when a doer is added
    event LogEtherAdded(uint amount); // emitted when ETH is added to the contract

    event LogTaskAdded(
        string name,
        string desc,
        uint _reward,
        address issuer,
        uint status,
        bytes32 id
    );  // emitted when a task is added

    event LogTaskStarted(bytes32 taskId, address doer); // emitted when a task is staretd by a doer
    event LogTaskFinished(bytes32 taskId, address doer); // emitted when a task is finished by a doer

    event LogTaskAccepted(
        bytes32 taskId,
        address doer,
        uint reward
    ); // emitted when a task is accepted by the owner

    event LogTaskRejected(
        bytes32 taskId,
        address doer
    ); // emitted when a task is rejected by the owner

    event LogRewardsWithdrawn(address doer, uint rewards); // emitted when a doer withdraws their rewards

    function Organization()
        public
        payable
        someETH()
    {
        owner = msg.sender;
        totalBalance = msg.value;
    }

    /*
      @action: add doer
      @performer: owner
    */
    function addDoer(address doer)
        public
        newDoer(doer)
        isOwner()
        returns (bool success)
    {
        doers.push(doer);
        doerActiveMapping[doer] = true;
        LogDoerAdded(doer);
        return success;
    }

    /*
      @action: add ether to contract
      @performer: owner
    */
    function addEther()
        public
        payable
        someETH()
        isOwner()
        returns (bool success)
    {
        totalBalance += msg.value;
        LogEtherAdded(msg.value);
        return success;
    }

    /*
      @action: start task
      @performer: doer
    */
    function startTask(bytes32 taskId)
        public
        isDoer()
        returns (bool success)
    {
        Task storage task = taskMapping[taskId];
        task.status = TaskStatus.INPROGESS;
        task.doer = msg.sender;
        LogTaskStarted(taskId, msg.sender);
        return success;
    }

    /*
      @action: finish task
      @performer: owner
    */
    function finishTask(bytes32 taskId)
        public
        isDoer()
        returns (bytes32 _taskId)
    {
        Task storage task = taskMapping[taskId];
        require(task.status == TaskStatus.INPROGESS);
        require(msg.sender == task.doer);
        task.status = TaskStatus.FINISHED;
        LogTaskStarted(taskId, msg.sender);
        return taskId;
    }

    /*
      @action: accept task
      @performer: owner
    */
    function acceptTask(bytes32 taskId)
        public
        isOwner()
        returns (bytes32 _taskId)
    {
        Task storage task = taskMapping[taskId];
        require(task.status == TaskStatus.FINISHED);
        task.status = TaskStatus.ACCEPTED;
        task.reviewer = msg.sender;
        doerPayablesMapping[task.doer] += task.reward;
        LogTaskAccepted(taskId, task.doer, task.reward);
        return taskId;
    }

    /*
      @action: reject task
      @performer: owner
    */
    function rejectTask(bytes32 taskId)
        public
        isOwner()
        returns (bytes32 _taskId)
    {
        Task storage task = taskMapping[taskId];
        require(task.status == TaskStatus.FINISHED);
        task.status = TaskStatus.REJECTED;
        task.reviewer = msg.sender;
        LogTaskRejected(taskId, task.doer);
        return taskId;
    }

    /*
      @action: withdraw owed ETH rewards
      @performer: doer
    */
    function withdrawRewards()
        public
        isDoer()
        returns (bool success)
    {
        uint amountToWithdraw = doerPayablesMapping[msg.sender];
        doerPayablesMapping[msg.sender] = 0;
        require(amountToWithdraw > 0);
        require(totalBalance >= amountToWithdraw);
        msg.sender.transfer(amountToWithdraw);
        LogRewardsWithdrawn(msg.sender, amountToWithdraw);
        return true;
    }

    /*
      @action: create task
      @performer: owner
    */
    function createTask(uint _reward, string name, string desc)
        public
        sufficientETH(_reward)
        returns (bytes32 _taskId)
    {
        bytes32 taskId = keccak256(msg.sender, name, desc, block.timestamp);

        Task memory task = Task({
            name: name,
            desc: desc,
            reward: _reward,
            doer: address(0),
            issuer: msg.sender,
            reviewer: address(0),
            status: TaskStatus.TODO,
            id: taskId
        });

        tasksIDs.push(taskId);
        taskMapping[taskId] = task;
        LogTaskAdded(name, desc, _reward, msg.sender, 0, taskId);
        return taskId;
    }

    // ensure at least 1 wei
    modifier someETH() {
        require(msg.value > 0);
        _;
    }

    // ensure contract has enough balance to pay rewards
    modifier sufficientETH(uint _reward) {
        require(totalBalance >= _reward);
        _;
    }

    // ensure doer does not already exist
    modifier newDoer(address _doer) {
        require(doerActiveMapping[_doer] == false);
        _;
    }

    // ensure active doer
    modifier isDoer() {
        require(doerActiveMapping[msg.sender]);
        _;
    }

    // ensure owner
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}
