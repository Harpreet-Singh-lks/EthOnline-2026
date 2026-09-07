// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPermissionedRegistry} from "@ensdomains/contracts-v2/registry/interfaces/IPermissionedRegistry.sol";
import {IRegistry} from "@ensdomains/contracts-v2/registry/interfaces/IRegistry.sol";
import {RegistryRolesLib} from "@ensdomains/contracts-v2/registry/libraries/RegistryRolesLib.sol";

uint256 constant REGISTRATION_ROLE_BITMAP =
    RegistryRolesLib.ROLE_SET_SUBREGISTRY
    | RegistryRolesLib.ROLE_SET_SUBREGISTRY_ADMIN
    | RegistryRolesLib.ROLE_SET_RESOLVER
    | RegistryRolesLib.ROLE_SET_RESOLVER_ADMIN
    | RegistryRolesLib.ROLE_CAN_TRANSFER_ADMIN;

contract AgentSubnameRegistrar is Ownable {
    error NameNotAvailable(string label);
    error InvalidOwner();
    error DurationTooShort(uint64 duration, uint64 minimum);

    event AgentNameRegistered(
        uint256 indexed tokenId, string label, address owner, uint64 duration
    );

    IPermissionedRegistry public immutable REGISTRY;
    uint64 public immutable MIN_DURATION;

    constructor(IPermissionedRegistry registry, uint64 minDuration) Ownable(msg.sender) {
        REGISTRY = registry;
        MIN_DURATION = minDuration;
    }

    function isAvailable(string calldata label) public view returns (bool) {
        IPermissionedRegistry.State memory state =
            REGISTRY.getState(uint256(keccak256(bytes(label))));
        return state.status == IPermissionedRegistry.Status.AVAILABLE;
    }

    // Only YOUR backend (the contract owner) can call this —
    // your backend should only call it after World Selfie Check passes.
    function register(
        string calldata label,
        address owner,
        address resolver,
        uint64 duration
    ) external onlyOwner returns (uint256 tokenId) {
        if (!isAvailable(label)) revert NameNotAvailable(label);
        if (owner == address(0)) revert InvalidOwner();
        if (duration < MIN_DURATION) revert DurationTooShort(duration, MIN_DURATION);

        tokenId = REGISTRY.register(
            label,
            owner,
            IRegistry(address(0)),
            resolver,
            REGISTRATION_ROLE_BITMAP,
            uint64(block.timestamp) + duration
        );

        emit AgentNameRegistered(tokenId, label, owner, duration);
    }
}
