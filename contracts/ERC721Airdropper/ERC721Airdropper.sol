//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../IUtilityContract.sol";

contract ERC721Airdroper is IUtilityContract, Ownable{

    IERC721 tokensAddress;
    address treasure;
    bool private isInitilialized;

    error InvalidArrays(uint256, uint256);
    error DontApprove();
    error AlreadyInitiliaized();

    constructor(address _tokensAddress) Ownable(msg.sender){}

    modifier nonInitilaized() {
        require(!isInitilialized, AlreadyInitiliaized());
        _;
    }


    function initialize(bytes memory _initData) nonInitilaized() onlyOwner() external returns(bool){
        
        (address _tokenAddress, address _treasure) = abi.decode(_initData, (address, address));

        tokensAddress = IERC721(_tokenAddress);
        treasure = _treasure;
        isInitilialized = true;
        return true;
    }




    function airdrop(address[] calldata _usersAddress, uint256[] calldata _tokenId) onlyOwner() external {
        require(_usersAddress.length == _tokenId.length, InvalidArrays(_usersAddress.length, _tokenId.length));
        require(tokensAddress.isApprovedForAll(treasure, address(this)), DontApprove());

        for(uint256 i = 0; i < _usersAddress.length; i++){
            tokensAddress.safeTransferFrom(address(this), _usersAddress[i], _tokenId[i], bytes("0"));
        }

    }

}