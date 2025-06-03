//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IUtilityContract.sol";

contract ERC1155Airdroper is IUtilityContract, Ownable{

    IERC1155 tokensAddress;
    address treasure;
    bool private isInitilialized;

    error InvalidArrays(uint256, uint256, uint256);
    error DontApprove();
    error AlreadyInitiliaized();

    constructor(address _tokensAddress) Ownable(msg.sender){}

    modifier nonInitilaized() {
        require(!isInitilialized, AlreadyInitiliaized());
        _;
    }


    function initialize(bytes memory _initData) nonInitilaized() onlyOwner() external returns(bool){
        
        (address _tokenAddress, address _treasure) = abi.decode(_initData, (address, address));

        tokensAddress = IERC1155(_tokenAddress);
        treasure = _treasure;
        isInitilialized = true;
        return true;
    }




    function airdrop(address[] calldata _usersAddress, uint256[] calldata _tokenId, uint256[] calldata _tokenAmount) onlyOwner() external {
        require(_usersAddress.length + _tokenAmount.length == 2 * _tokenId.length, InvalidArrays(_usersAddress.length, _tokenId.length, _tokenAmount.length));
        require(tokensAddress.isApprovedForAll(treasure, address(this)), DontApprove());

        for(uint256 i = 0; i < _usersAddress.length; i++){
            tokensAddress.safeTransferFrom(address(this), _usersAddress[i], _tokenId[i], _tokenAmount[i], bytes("0"));
        }

    }

}
