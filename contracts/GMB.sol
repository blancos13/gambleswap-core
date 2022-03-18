// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IGMB.sol";

contract GMBToken is ERC20, IGMBToken {

    address public admin;
    address public gamblingContract;
    address[] public override authorisedPools;

    constructor(uint256 initialSupply) public ERC20("GMB Token", "GMB") {
        admin = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    modifier onlyGamblingContract {
        require(msg.sender == gamblingContract, "Only the GambleContract can call this function");
        _;
    }

    modifier onlyAuthorizedPools {
        bool isAuthorized = false;
        for(uint i=0; i<authorisedPools.length; i++) {
            if(authorisedPools[i] == msg.sender) {
                isAuthorized = true;
            }
        }
        require(isAuthorized == true, "Only authorized pool can call mint");
        _;
    }

    function setGamblingContractAddess(address addr) external onlyAdmin {
        gamblingContract = addr;
    }

    function mint(address account, uint256 amount) external onlyAuthorizedPools {
        _mint(account, amount);
    }

    function burn(uint amount) external onlyGamblingContract {
        address gamblingContractAddr = msg.sender;
        _burn(gamblingContractAddr, amount);
    }

    function addNewPool(address poolAddr) onlyAdmin override external {
        authorisedPools.push(poolAddr);
        emit NewPool(poolAddr);
    }

    function getAuthorisedPoolsLength() external view returns (uint256) {
        return authorisedPools.length;
    }
}