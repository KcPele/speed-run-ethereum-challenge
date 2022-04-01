pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
  uint256 public constant tokensPerEth = 100;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokensTobuy);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }
 


  // ToDo: create a payable buyTokens() function:
    function buyTokens(uint256 _amoount) public payable returns(uint256){
      if(msg.value <= 0){
        revert("Amount of ETH is too small");
      }
      uint256 amountConvertedToBuy = msg.value * tokensPerEth;

     
       uint256 vendorBalance = yourToken.balanceOf(address(this));
      if(vendorBalance < amountConvertedToBuy){
        revert("Vendor does not have enough tokens");
      }

    //transfering 
      (bool sent) = yourToken.transfer(msg.sender, amountConvertedToBuy);
      //emit
      emit BuyTokens(msg.sender, msg.value, amountConvertedToBuy);
      return amountConvertedToBuy;
    }
  // ToDo: create a withdraw() function that lets the owner withdraw ETH

function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has not balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenAmountToSell) public {
    // Check that the requested amount of tokens to sell is more than 0
    require(tokenAmountToSell > 0, "Specify an amount of token greater than zero");

    // Check that the user's token balance is enough to do the swap
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= tokenAmountToSell, "Your balance is lower than the amount of tokens you want to sell");

    // Check that the Vendor's balance is enough to do the swap
    uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    require(ownerETHBalance >= amountOfETHToTransfer, "Vendor has not enough funds to accept the sell request");

    (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    require(sent, "Failed to transfer tokens from user to vendor");


    (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
    require(sent, "Failed to send ETH to the user");
  }

}
