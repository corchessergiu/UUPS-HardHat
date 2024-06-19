// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./interfaces/IERC20Swapper.sol";
import "./interfaces/IWETH9Minimal.sol";
import "./interfaces/ISwapRouterMinimal.sol";

contract ERC20Swapper is Initializable, IERC20Swapper, OwnableUpgradeable, UUPSUpgradeable {
    address public SWAP_ROUTER;
    address public WETH9;
    uint256 public numberOfInteraction;

    function initialize(address _swapRouter, address _WETH) public initializer {
        SWAP_ROUTER = _swapRouter;
        WETH9 = _WETH;
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

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

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setSwapRouter(address _swapRouter) external onlyOwner {
        SWAP_ROUTER = _swapRouter;
    }

    function increase() public {
        numberOfInteraction = numberOfInteraction + 1;
    }
}


