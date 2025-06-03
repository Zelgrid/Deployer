//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IUtilityContract.sol";

contract ERC20Airdroper is IUtilityContract, Ownable{

    IERC20 public token;
    uint256 public amount;
    address treasure;
    bool private isInitilialized;

    error AlreadyInitiliaized();
    error LenghtMissmatch();
    error NotEnoghtFunds();
    error TransferFailed();
    
    constructor() Ownable(msg.sender){}

    modifier nonInitilaized() {
        require(!isInitilialized, AlreadyInitiliaized());
        _;
    }

    function initialize(bytes memory _initData) nonInitilaized() onlyOwner() external returns(bool){
        
        (uint256 _amount, address _tokenAddress, address _treasure) = abi.decode(_initData, (uint256, address, address));

        amount = _amount;
        token = IERC20(_tokenAddress);
        treasure = _treasure;
        isInitilialized = true;
        return true;
    }

    function airdrop(address[] calldata receivers, uint256[] calldata amounts) onlyOwner() external {
        require(receivers.length == amounts.length, LenghtMissmatch());
        require(token.allowance(treasure, address(this)) >= amount, NotEnoghtFunds());

        for (uint256 i = 0; i < receivers.length; i++) {
            require(token.transferFrom(treasure, receivers[i], amounts[i]), TransferFailed());
        }

    }

}