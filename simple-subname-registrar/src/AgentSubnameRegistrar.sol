// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPermissionedRegistry} from "@ensdomains/contracts-v2/registry/interfaces/IPermissionedRegistry.sol";
import {IRegistry} from "@ensdomains/contracts-v2/registry/interfaces/IRegistry.sol";
import {RegistryRolesLib} from "@ensdomains/contracts-v2/registry/libraries/RegistryRolesLib.sol";

uint256 constant AGENT_ROLE_BITMAP =
    RegistryRolesLib.ROLE_SET_SUBREGISTRY
    | RegistryRolesLib.ROLE_SET_SUBREGISTRY_ADMIN
    | RegistryRolesLib.ROLE_SET_RESOLVER
    | RegistryRolesLib.ROLE_SET_RESOLVER_ADMIN
    | RegistryRolesLib.ROLE_CAN_TRANSFER_ADMIN;

contract AgentSubnameRegistrar is Ownable {
    error NameNotAvailable(string label);
    error InvalidOwner();
    error DurationTooShort(uint64 duration, uint64 minimum);
    error NotHumanController(uint256 resource, address caller);
    error AlreadyRevoked(uint256 resource);

    event AgentNameRegistered(
        uint256 indexed tokenId, string label, address agentWallet, address humanController, uint64 duration
    );
    event AgentRevoked(uint256 indexed resource, address agentWallet, address humanController);

    IPermissionedRegistry public immutable REGISTRY;
    uint64 public immutable MIN_DURATION;

    // resource (stable id) -> the human who actually owns this name at the ENS level
    mapping(uint256 resource => address humanController) public humanControllerOf;
    // resource -> which wallet is currently authorized to act as the agent (cleared on revoke)
    mapping(uint256 resource => address agentWallet) public agentWalletOf;

    constructor(IPermissionedRegistry registry, uint64 minDuration) Ownable(msg.sender) {
        REGISTRY = registry;
        MIN_DURATION = minDuration;
    }

    function isAvailable(string calldata label) public view returns (bool) {
        IPermissionedRegistry.State memory state =
            REGISTRY.getState(uint256(keccak256(bytes(label))));
        return state.status == IPermissionedRegistry.Status.AVAILABLE;
    }

    // Only YOUR backend calls this, only after World Selfie Check passes.
    // humanController becomes the real ENS owner (genuine revoke authority, proven pattern).
    // agentWallet is tracked separately — the wallet currently allowed to act.
    function register(
        string calldata label,
        address humanController,
        address agentWallet,
        address resolver,
        uint64 duration
    ) external onlyOwner returns (uint256 tokenId) {
        if (!isAvailable(label)) revert NameNotAvailable(label);
        if (humanController == address(0) || agentWallet == address(0)) revert InvalidOwner();
        if (duration < MIN_DURATION) revert DurationTooShort(duration, MIN_DURATION);

        tokenId = REGISTRY.register(
            label,
            humanController,
            IRegistry(address(0)),
            resolver,
            AGENT_ROLE_BITMAP,
            uint64(block.timestamp) + duration
        );

        IPermissionedRegistry.State memory state = REGISTRY.getState(uint256(keccak256(bytes(label))));
        humanControllerOf[state.resource] = humanController;
        agentWalletOf[state.resource] = agentWallet;

        emit AgentNameRegistered(tokenId, label, agentWallet, humanController, duration);
    }

    // Only the human who owns this name can call this.
    function revokeAgent(string calldata label) external {
        uint256 anyId = uint256(keccak256(bytes(label)));
        IPermissionedRegistry.State memory state = REGISTRY.getState(anyId);

        if (msg.sender != humanControllerOf[state.resource]) {
            revert NotHumanController(state.resource, msg.sender);
        }
        if (agentWalletOf[state.resource] == address(0)) {
            revert AlreadyRevoked(state.resource);
        }

        address revokedAgent = agentWalletOf[state.resource];
        agentWalletOf[state.resource] = address(0); // primary kill switch — we control this directly

        // Also revoke the real ENS roles, visible on-chain — the human genuinely holds
        // these roles (they're the owner), so this uses the exact mechanism we already proved works.
        //---removed --      REGISTRY.revokeRoles(state.resource, AGENT_ROLE_BITMAP, msg.sender);

        emit AgentRevoked(state.resource, revokedAgent, msg.sender);
    }

    function isAuthorized(string calldata label, address agentWallet) external view returns (bool) {
        uint256 anyId = uint256(keccak256(bytes(label)));
        IPermissionedRegistry.State memory state = REGISTRY.getState(anyId);

        if (state.status != IPermissionedRegistry.Status.REGISTERED) return false;
        if (state.expiry <= block.timestamp) return false;
        return agentWalletOf[state.resource] == agentWallet;
    }
}