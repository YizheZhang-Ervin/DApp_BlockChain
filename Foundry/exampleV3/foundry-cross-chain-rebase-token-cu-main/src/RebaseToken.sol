// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/*
* @title RebaseToken
* @author Ciara Nightingale
* @notice This is a cross-chain rebase token that incentivises users to deposit into a vault and gain interest in rewards.
* @notice The interest rate in the smart contract can only decrease 
* @notice Each will user will have their own interest rate that is the global interest rate at the time of depositing.
*/
contract RebaseToken is ERC20, Ownable, AccessControl {
    error RebaseToken__InterestRateCanOnlyDecrease(uint256 currentInterestRate, uint256 newInterestRate);

    /////////////////////
    // State Variables
    /////////////////////

    uint256 private constant PRECISION_FACTOR = 1e18; // Used to handle fixed-point calculations
    bytes32 private constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE"); // Role for minting and burning tokens (the pool and vault contracts)
    mapping(address => uint256) private s_userInterestRate; // Keeps track of the interest rate of the user at the time they last deposited, bridged or were transferred tokens.
    mapping(address => uint256) private s_userLastUpdatedTimestamp; // the last time a user balance was updated to mint accrued interest.
    uint256 private s_interestRate = 5e10; // this is the global interest rate of the token - when users mint (or receive tokens via transferral), this is the interest rate they will get.

    /////////////////////
    // Events
    /////////////////////
    event InterestRateSet(uint256 newInterestRate);

    /////////////////////
    // Constructor
    /////////////////////

    constructor() Ownable(msg.sender) ERC20("RebaseToken", "RBT") {}

    /////////////////////
    // Functions
    /////////////////////

    /**
     * @dev grants the mint and burn role to an address. This is only called by the protocol owner.
     * @param _address the address to grant the role to
     *
     */
    function grantMintAndBurnRole(address _address) external onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _address);
    }

    /**
     * @dev sets the interest rate of the token. This is only called by the protocol owner.
     * @param _interestRate the new interest rate
     * @notice only allow the interest rate to decrease but we don't want it to revert in case it's the destination chain that is updating the interest rate (in which case it'll either be the same or larger so it won't update)
     *
     */
    /**
     * @notice Set the interest rate in the contract
     * @param _newInterestRate The new interest rate to set
     * @dev The interest rate can only decrease
     */
    function setInterestRate(uint256 _newInterestRate) external onlyOwner {
        // Set the interest rate
        if (_newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }
    /**
     * @dev returns the principal balance of the user. The principal balance is the last
     * updated stored balance, which does not consider the perpetually accruing interest that has not yet been minted.
     * @param _user the address of the user
     * @return the principal balance of the user
     *
     */

    function principalBalanceOf(address _user) external view returns (uint256) {
        return super.balanceOf(_user);
    }

    /// @notice Mints new tokens for a given address. Called when a user either deposits or bridges tokens to this chain.
    /// @param _to The address to mint the tokens to.
    /// @param _value The number of tokens to mint.
    /// @param _userInterestRate The interest rate of the user. This is either the contract interest rate if the user is depositing or the user's interest rate from the source token if the user is bridging.
    /// @dev this function increases the total supply.
    function mint(address _to, uint256 _value, uint256 _userInterestRate) public onlyRole(MINT_AND_BURN_ROLE) {
        // Mints any existing interest that has accrued since the last time the user's balance was updated.
        _mintAccruedInterest(_to);
        // Sets the users interest rate to either their bridged value if they are bridging or to the current interest rate if they are depositing.
        s_userInterestRate[_to] = _userInterestRate;
        _mint(_to, _value);
    }

    /// @notice Burns tokens from the sender.
    /// @param _from The address to burn the tokens from.
    /// @param _value The number of tokens to be burned
    /// @dev this function decreases the total supply.
    function burn(address _from, uint256 _value) public onlyRole(MINT_AND_BURN_ROLE) {
        // Mints any existing interest that has accrued since the last time the user's balance was updated.
        _mintAccruedInterest(_from);
        _burn(_from, _value);
    }

    /**
     * @dev calculates the balance of the user, which is the
     * principal balance + interest generated by the principal balance
     * @param _user the user for which the balance is being calculated
     * @return the total balance of the user
     *
     */
    function balanceOf(address _user) public view override returns (uint256) {
        //current principal balance of the user
        uint256 currentPrincipalBalance = super.balanceOf(_user);
        if (currentPrincipalBalance == 0) {
            return 0;
        }
        // shares * current accumulated interest for that user since their interest was last minted to them.
        return (currentPrincipalBalance * _calculateUserAccumulatedInterestSinceLastUpdate(_user)) / PRECISION_FACTOR;
    }

    /**
     * @dev transfers tokens from the sender to the recipient. This function also mints any accrued interest since the last time the user's balance was updated.
     * @param _recipient the address of the recipient
     * @param _amount the amount of tokens to transfer
     * @return true if the transfer was successful
     *
     */
    function transfer(address _recipient, uint256 _amount) public override returns (bool) {
        // accumulates the balance of the user so it is up to date with any interest accumulated.
        if (_amount == type(uint256).max) {
            _amount = balanceOf(msg.sender);
        }
        _mintAccruedInterest(msg.sender);
        _mintAccruedInterest(_recipient);
        if (balanceOf(_recipient) == 0) {
            // Update the users interest rate only if they have not yet got one (or they tranferred/burned all their tokens). Otherwise people could force others to have lower interest.
            s_userInterestRate[_recipient] = s_userInterestRate[msg.sender];
        }
        return super.transfer(_recipient, _amount);
    }

    /**
     * @dev transfers tokens from the sender to the recipient. This function also mints any accrued interest since the last time the user's balance was updated.
     * @param _sender the address of the sender
     * @param _recipient the address of the recipient
     * @param _amount the amount of tokens to transfer
     * @return true if the transfer was successful
     *
     */
    function transferFrom(address _sender, address _recipient, uint256 _amount) public override returns (bool) {
        if (_amount == type(uint256).max) {
            _amount = balanceOf(_sender);
        }
        // accumulates the balance of the user so it is up to date with any interest accumulated.
        _mintAccruedInterest(_sender);
        _mintAccruedInterest(_recipient);
        if (balanceOf(_recipient) == 0) {
            // Update the users interest rate only if they have not yet got one (or they tranferred/burned all their tokens). Otherwise people could force others to have lower interest.
            s_userInterestRate[_recipient] = s_userInterestRate[_sender];
        }
        return super.transferFrom(_sender, _recipient, _amount);
    }

    /**
     * @dev returns the interest accrued since the last update of the user's balance - aka since the last time the interest accrued was minted to the user.
     * @return linearInterest the interest accrued since the last update
     *
     */
    function _calculateUserAccumulatedInterestSinceLastUpdate(address _user)
        internal
        view
        returns (uint256 linearInterest)
    {
        uint256 timeDifference = block.timestamp - s_userLastUpdatedTimestamp[_user];
        // represents the linear growth over time = 1 + (interest rate * time)
        linearInterest = (s_userInterestRate[_user] * timeDifference) + PRECISION_FACTOR;
    }

    /**
     * @dev accumulates the accrued interest of the user to the principal balance. This function mints the users accrued interest since they last transferred or bridged tokens.
     * @param _user the address of the user for which the interest is being minted
     *
     */
    function _mintAccruedInterest(address _user) internal {
        // Get the user's previous principal balance. The amount of tokens they had last time their interest was minted to them.
        uint256 previousPrincipalBalance = super.balanceOf(_user);

        // Calculate the accrued interest since the last accumulation
        // `balanceOf` uses the user's interest rate and the time since their last update to get the updated balance
        uint256 currentBalance = balanceOf(_user);
        uint256 balanceIncrease = currentBalance - previousPrincipalBalance;

        // Mint an amount of tokens equivalent to the interest accrued
        _mint(_user, balanceIncrease);
        // Update the user's last updated timestamp to reflect this most recent time their interest was minted to them.
        s_userLastUpdatedTimestamp[_user] = block.timestamp;
    }

    /**
     * @dev returns the global interest rate of the token for future depositors
     * @return s_interestRate
     *
     */
    function getInterestRate() external view returns (uint256) {
        return s_interestRate;
    }

    /**
     * @dev returns the interest rate of the user
     * @param _user the address of the user
     * @return s_userInterestRate[_user] the interest rate of the user
     *
     */
    function getUserInterestRate(address _user) external view returns (uint256) {
        return s_userInterestRate[_user];
    }
}
