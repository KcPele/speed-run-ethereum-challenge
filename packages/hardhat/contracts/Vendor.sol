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
    function buyTokens() public payable returns(uint256){
      
      uint256 amountConvertedToBuy = msg.value * tokensPerEth;

     
       uint256 vendorBalance = yourToken.balanceOf(address(this));
      

    //transfering 
      (bool sent) = yourToken.transfer(msg.sender, amountConvertedToBuy);
      //emit
      emit BuyTokens(msg.sender, msg.value, amountConvertedToBuy);
      return amountConvertedToBuy;
    }
  // ToDo: create a withdraw() function that lets the owner withdraw ETH

function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    
    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 tokenAmountToSell) public {
    
    uint256 userBalance = yourToken.balanceOf(msg.sender);
    
    // Check that the Vendor's balance is enough to do the swap
    uint256 amountOfETHToTransfer = tokenAmountToSell / tokensPerEth;
    uint256 ownerETHBalance = address(this).balance;
    
    (bool sent) = yourToken.transferFrom(msg.sender, address(this), tokenAmountToSell);
    

    (sent,) = msg.sender.call{value: amountOfETHToTransfer}("");
   
  }

}
