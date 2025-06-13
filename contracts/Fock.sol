// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title Fock
 * @notice Fixed-supply ERC20 meme coin with an optional liquidity fee.
 * The token has no owner and all tokens are minted once at deployment.
 */
contract Fock is ERC20, ERC20Burnable {
    /// @notice Fee percentage in basis points forwarded to the liquidity address.
    uint256 public immutable liquidityFee;

    /// @notice Address receiving liquidity fees.
    address public immutable liquidityAddress;

    uint256 private constant FEE_DENOMINATOR = 10_000;

    /// @param _liquidityAddress Address that will collect the liquidity fee.
    /// @param _feeBasisPoints Fee in basis points (1/100 of a percent). Max 10%.
    constructor(address _liquidityAddress, uint256 _feeBasisPoints) ERC20("Fock", "FCKY") {
        require(_liquidityAddress != address(0), "invalid liquidity address");
        require(_feeBasisPoints <= 1000, "fee too high");
        liquidityAddress = _liquidityAddress;
        liquidityFee = _feeBasisPoints;

        _mint(msg.sender, 5_000_000 * 10 ** decimals());
    }

    /// @dev Internal transfer with immutable liquidity fee.
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        if (liquidityFee == 0 || sender == liquidityAddress || recipient == liquidityAddress) {
            super._transfer(sender, recipient, amount);
            return;
        }

        uint256 fee = (amount * liquidityFee) / FEE_DENOMINATOR;
        uint256 remainder = amount - fee;
        super._transfer(sender, liquidityAddress, fee);
        super._transfer(sender, recipient, remainder);
    }
}
