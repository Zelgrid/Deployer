//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IUtilityContract.sol";

contract ERC20Airdroper is IUtilityContract, Ownable{

    IERC20 public token;
    uint256 public amount;
    bool private isInitilialized = false;

    error AlreadyInitiliaized();
    error LenghtMissmatch();
    error NotEnoghtFunds();
    error TransferFailed();
    
    constructor(address _tokenAddress, uint256 _airdropAmount) Ownable(msg.sender){}

    function initialize(bytes memory _initData) external returns(bool){
        require(!isInitilialized, AlreadyInitiliaized());

        (uint256 _amount, address _tokenAddress) = abi.decode(_initData, (uint256, address));
        amount = _amount;
        token = IERC20(_tokenAddress);
        isInitilialized = true;
        return true;
    }

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) onlyOwner() external {
        require(receivers.length == amounts.length, LenghtMissmatch());
        require(token.allowance(msg.sender, address(this)) >= amount, NotEnoghtFunds());

        for (uint256 i = 0; i < receivers.length; i++) {
            require(token.transferFrom(msg.sender, receivers[i], amounts[i]), TransferFailed());
        }

    }

}