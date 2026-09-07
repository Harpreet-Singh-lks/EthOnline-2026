// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {RegistryRolesLib} from "@ensdomains/contracts-v2/registry/libraries/RegistryRolesLib.sol";

contract PrintRoleBitmap is Script {
    function run() external view {
        uint256 registrationRoleBitmap =
            RegistryRolesLib.ROLE_SET_SUBREGISTRY
            | RegistryRolesLib.ROLE_SET_SUBREGISTRY_ADMIN
            | RegistryRolesLib.ROLE_SET_RESOLVER
            | RegistryRolesLib.ROLE_SET_RESOLVER_ADMIN
            | RegistryRolesLib.ROLE_CAN_TRANSFER_ADMIN;

        console.log("REGISTRATION_ROLE_BITMAP:", registrationRoleBitmap);

        // Also print each individual role value, useful for sanity-checking
        console.log("ROLE_SET_SUBREGISTRY:", RegistryRolesLib.ROLE_SET_SUBREGISTRY);
        console.log("ROLE_SET_SUBREGISTRY_ADMIN:", RegistryRolesLib.ROLE_SET_SUBREGISTRY_ADMIN);
        console.log("ROLE_SET_RESOLVER:", RegistryRolesLib.ROLE_SET_RESOLVER);
        console.log("ROLE_SET_RESOLVER_ADMIN:", RegistryRolesLib.ROLE_SET_RESOLVER_ADMIN);
        console.log("ROLE_CAN_TRANSFER_ADMIN:", RegistryRolesLib.ROLE_CAN_TRANSFER_ADMIN);
    }
}