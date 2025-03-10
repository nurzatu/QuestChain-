// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract QuestChain {
    address public owner;
    IERC20 public rewardToken;

    enum Stage { NotStarted, Stage1, Stage2, Stage3, Completed }
    mapping(address => Stage) public playerProgress;

    event StageCompleted(address indexed player, uint256 stage);
    event RewardClaimed(address indexed player, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier canProgress() {
        require(playerProgress[msg.sender] != Stage.Completed, "Quest already completed");
        _;
    }

    constructor(address _rewardToken) {
        owner = msg.sender;
        rewardToken = IERC20(_rewardToken);
    }

    // Stage 1: Complete an action (e.g., send tokens)
    function completeStage1() external canProgress {
        require(playerProgress[msg.sender] == Stage.NotStarted || playerProgress[msg.sender] == Stage1, "Invalid progress");

        // Your custom logic for Stage 1, e.g., transferring tokens, etc.
        playerProgress[msg.sender] = Stage.Stage1;

        emit StageCompleted(msg.sender, 1);
    }

    // Stage 2: Sign a message (example check)
    function completeStage2(string memory _secret) external canProgress {
        require(playerProgress[msg.sender] == Stage.Stage1, "You must complete Stage 1 first");

        // Logic for verifying the signature or secret (this could be more complex)
        require(keccak256(abi.encodePacked(_secret)) == keccak256(abi.encodePacked("mysecret")), "Invalid secret");

        playerProgress[msg.sender] = Stage.Stage2;

        emit StageCompleted(msg.sender, 2);
    }

    // Stage 3: Interact with another contract (example: send tokens)
    function completeStage3(uint256 amount) external canProgress {
        require(playerProgress[msg.sender] == Stage.Stage2, "You must complete Stage 2 first");

        // Example: Transfer tokens as part of the quest
        require(rewardToken.transferFrom(msg.sender, address(this), amount), "Token transfer failed");

        playerProgress[msg.sender] = Stage.Stage3;

        emit StageCompleted(msg.sender, 3);
    }

    // Final Stage: Claim the reward
    function claimReward() external canProgress {
        require(playerProgress[msg.sender] == Stage.Stage3, "You must complete Stage 3 first");

        uint256 rewardAmount = 100 * 10**18; // Example reward amount (adjust based on your token's decimals)
        require(rewardToken.transfer(msg.sender, rewardAmount), "Reward transfer failed");

        playerProgress[msg.sender] = Stage.Completed;

        emit RewardClaimed(msg.sender, rewardAmount);
    }

    // Admin function to change the reward token contract address
    function setRewardToken(address _rewardToken) external onlyOwner {
        rewardToken = IERC20(_rewardToken);
    }

    // Check the current progress of the player
    function getPlayerProgress(address player) external view returns (Stage) {
        return playerProgress[player];
    }
}
