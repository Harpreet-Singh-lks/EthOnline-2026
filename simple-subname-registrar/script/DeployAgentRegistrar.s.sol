// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AgentSubnameRegistrar} from "../src/AgentSubnameRegistrar.sol";
import {IPermissionedRegistry} from "@ensdomains/contracts-v2/registry/interfaces/IPermissionedRegistry.sol";

contract DeployAgentRegistrar is Script {
    function run() external {
        vm.startBroadcast();

        AgentSubnameRegistrar registrar = new AgentSubnameRegistrar(
            IPermissionedRegistry(0x91b12938384B6946179310f35046e19d49B11643), // your UserRegistry
            3600 // minDuration: 1 hour, generous enough for a demo
        );

        console.log("AgentSubnameRegistrar deployed at:", address(registrar));

        vm.stopBroadcast();
    }
}
