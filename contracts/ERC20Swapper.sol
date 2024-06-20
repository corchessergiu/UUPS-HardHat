// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IERC20Swapper.sol";
import "./interfaces/IWETH9Minimal.sol";
import "./interfaces/ISwapRouterMinimal.sol";

/// @title ERC20Swapper
/// @dev This contract allows swapping Ether for ERC20 tokens using Uniswap V3 and is upgradeable using UUPS proxy pattern.
contract ERC20Swapper is Initializable, IERC20Swapper, OwnableUpgradeable, UUPSUpgradeable {
    /// @notice Address of the Uniswap V3 Swap Router
    address public SWAP_ROUTER;

    /// @notice Address of the WETH9 token
    address public WETH9;

    /// @notice Counter to keep track of the number of interactions
    uint256 public numberOfInteraction;

    /// @notice Initializes the contract with the Swap Router and WETH addresses
    /// @param _swapRouter Address of the Uniswap V3 Swap Router
    /// @param _WETH Address of the WETH9 token
    function initialize(address _swapRouter, address _WETH) public initializer {
        SWAP_ROUTER = _swapRouter;
        WETH9 = _WETH;
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    /// @notice Swaps Ether to a specified ERC20 token using Uniswap V3
    /// @param token Address of the ERC20 token to receive
    /// @param minAmount Minimum amount of tokens expected to receive
    /// @return amountOut Amount of tokens received from the swap
    function swapEtherToToken(address token, uint minAmount) public payable returns (uint) {
        require(msg.value > 0, "Insufficient ETH amount");
        require(msg.sender == tx.origin, "Call from EOA not from contract!");

        IWETH9Minimal(WETH9).deposit{value: msg.value}();
        IWETH9Minimal(WETH9).approve(address(SWAP_ROUTER), msg.value);

        ISwapRouterMinimal.ExactInputSingleParams memory params = ISwapRouterMinimal.ExactInputSingleParams({
            tokenIn: address(WETH9),
            tokenOut: token,
            fee: 3000,
            recipient: msg.sender,
            deadline: block.timestamp,
            amountIn: msg.value,
            amountOutMinimum: minAmount,
            sqrtPriceLimitX96: 0
        });

        uint amountOut = ISwapRouterMinimal(SWAP_ROUTER).exactInputSingle(params);
        require(amountOut >= minAmount, "Minimum amount not met");
        return amountOut;
    }

    /// @notice Authorizes an upgrade to the contract. Only callable by the owner.
    /// @param newImplementation Address of the new contract implementation
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// @notice Sets the address of the Swap Router
    /// @param _swapRouter Address of the new Swap Router
    function setSwapRouter(address _swapRouter) external onlyOwner {
        SWAP_ROUTER = _swapRouter;
    }

    /// @notice Increases the interaction counter by 1
    function increase() public {
        numberOfInteraction = numberOfInteraction + 1;
    }
}
