// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/// @custom:security-contact info@zypdo.com
contract ZYPToken is ERC20, ERC20Burnable, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("ZYPToken", "ZYP") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _mint(msg.sender, 200000000 * 10 ** decimals());
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    mapping (address => uint) private userLastAction;
    uint throttleTime = 30 seconds; 

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);

         if (userLastAction[msg.sender].length == 0) {
            userLastAction[msg.sender] = 0;
        }
        require(block.timestamp - throttleTime >= userLastAction[msg.sender]);
        userLastAction[msg.sender] = block.timestamp; // now == block.timestamp
        
    }

    
    //Attach this to critical functions, such as balance withdrawals
    modifier speedBump() { 

            
       if (userLastAction[msg.sender].length == 0) {
           userLastAction[msg.sender] = 0;
       }
       require(block.timestamp - throttleTime >= userLastAction[msg.sender]);
       userLastAction[msg.sender] = block.timestamp; // now == block.timestamp
       _;
    }
}
