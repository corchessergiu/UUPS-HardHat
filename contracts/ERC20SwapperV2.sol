// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IWETH9Minimal.sol";
import "./interfaces/ISwapRouterMinimal.sol";
import "./interfaces/IERC20Swapper.sol";
import "./ERC20Swapper.sol";

/// @title ERC20SwapperV2
/// @dev This contract is an upgradeable version of ERC20Swapper with additional functionality.
contract ERC20SwapperV2 is ERC20Swapper {
    /// @notice Increases the interaction counter by 2
    function increaseBy2() public {
        numberOfInteraction = numberOfInteraction + 2;
    }
}
