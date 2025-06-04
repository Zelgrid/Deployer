// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../IUtilityContract.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";


contract Croudfunding is IUtilityContract, Ownable{

    address private fundraiser;
    address public wallet;
    uint256 public goal;
    uint256 public duration;
    bool public initialized;
    bool public locked;

    mapping (address => uint256) public payLog;


    error AlreadyInitialized();
    error AlreadyLocked();
    error GoalCantBeZero();
    error FundraiserCantBeZeroAddress();
    error ZeroDonation();
    error ZeroToRefund();

    event GoalReached(address _vestingWallet, uint256 _startTime);
    event TransferSuccess(address _sender, uint256 _value, uint256 _operationTime);
    event RefundSuccess(address _sender, uint256 _value, uint256 _operationTime);

    constructor() Ownable(msg.sender){}

    modifier notInitialized() {
        require(!initialized, AlreadyInitialized());
        _;
    }

    modifier notLocked() {
        require(!locked, AlreadyLocked());
        _;
    }

    function initialize(bytes memory _initData) external notInitialized onlyOwner returns(bool){
        (address _fundraiser, uint256 _goal, uint256 _duration) = abi.decode(_initData, (address, uint256, uint256));
        
        require(_goal != 0, GoalCantBeZero());
        require(_fundraiser != address(0), FundraiserCantBeZeroAddress());

        fundraiser = _fundraiser;
        goal = _goal;
        duration = _duration;
        initialized = true;

        return true;
    }

    function contribute() external notLocked payable{
        require(msg.value != 0, ZeroDonation());

        if (address(this).balance >= goal){
            locked = true;
            VestingWallet vesting = new VestingWallet(fundraiser, uint64(block.timestamp), uint64(duration));
            wallet = address(vesting); 
            payable(wallet).transfer(address(this).balance);

            emit GoalReached(wallet, block.timestamp);
        }
        else
            payLog[msg.sender] += msg.value;

        emit TransferSuccess(msg.sender, msg.value, block.timestamp);   
    }

    function refund() external notLocked{
        require(payLog[msg.sender] != 0, ZeroToRefund());
        
        payable(msg.sender).transfer(payLog[msg.sender]);

        emit RefundSuccess(msg.sender, payLog[msg.sender], block.timestamp);

        payLog[msg.sender] = 0;
    }

}