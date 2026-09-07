// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {PermissionedRegistry} from "@ensdomains/contracts-v2/registry/PermissionedRegistry.sol";
import {ILabelStore} from "@ensdomains/contracts-v2/utils/interfaces/ILabelStore.sol";
import {RegistryRolesLib} from "@ensdomains/contracts-v2/registry/libraries/RegistryRolesLib.sol";

contract DeployUserRegistry is Script {
    function run() external {
        vm.startBroadcast();

        uint256 roleBitmap = RegistryRolesLib.ROLE_REGISTRAR_ADMIN | RegistryRolesLib.ROLE_RENEW_ADMIN;

        PermissionedRegistry registry = new PermissionedRegistry(
            ILabelStore(0xD7351F76866123A7E49381F38a30a96AdBa7E855), // cast address -> interface
            msg.sender,
            roleBitmap
        );

        console.log("UserRegistry deployed at:", address(registry));

        vm.stopBroadcast();
    }
}