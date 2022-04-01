// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  // Balances of the user's stacked funds
  mapping(address => uint256) public balances;

  // Staking threshold
  uint256 public constant threshold = 1 ether;

  // Staking deadline
  uint256 public deadline = block.timestamp + 72 hours;

  // Contract's Events
  event Stake(address indexed sender, uint256 amount);

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }
  
  function stake() public payable{ 
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }
  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )


  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }
  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  bool public openForWithdraw;
function execute() public  notCompleted{
    uint256 contractBalance = address(this).balance;
    require(contractBalance >= threshold);
    exampleExternalContract.complete{value: contractBalance}();
    openForWithdraw = true;
    
  }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function

function withdraw() public  notCompleted{
  require(openForWithdraw == true);
    uint256 userBalance = balances[msg.sender];

    balances[msg.sender] = 0;

    (bool sent,) = msg.sender.call{value: userBalance}("");
    
  }
  
/**
  * @notice The number of seconds remaining until the deadline is reached
  */
   function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }

}
}
