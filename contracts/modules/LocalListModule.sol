//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

abstract contract LocalListModule is Initializable {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet internal _localWhitelist;
    EnumerableSet.AddressSet internal _localBlacklist;

    /**
     * @dev Emitted when addresses are added to local whitelist
     */
    event AddToLocalWhitelist(address[] wallets);

    /**
     * @dev Emitted when addresses are added to local blacklist. wallets[i] == address(0) means an address that was supossed to be added was already on the whitelist.
     */
    event AddToLocalBlacklist(address[] wallets);

    /**
     * @dev Emitted when addresses are added/removed from local blacklist
     */
    event RemoveFromLocalBlacklist(address[] wallets);

    /* Initializers */
    function __LocalList_init() internal onlyInitializing {}

    function __LocalList_init_unchained() internal onlyInitializing {}

    function isWhitelistedLocally(address wallet) external view returns (bool) {
        return _localWhitelist.contains(wallet);
    }

    function isBlacklistedLocally(address wallet) external view returns (bool) {
        return _localBlacklist.contains(wallet);
    }

    function getLocalWhitelist() external view returns (address[] memory) {
        return _localWhitelist.values();
    }

    function getLocalBlacklist() external view returns (address[] memory) {
        return _localBlacklist.values();
    }

    /**
     *@dev Add wallets to local whitelist
     *@param wallets wallet addresses to add to whitelist
     */
    function addToLocalWhitelist(address[] memory wallets) external virtual {}

    /**
     *@dev Add wallets to local blacklist
     *@param wallets wallets addresses to add to blacklist
     */
    function addToLocalBlacklist(address[] memory wallets) external virtual {}

    /**
     *@dev Add wallets to local blacklist
     *@param wallets wallets addresses to add to blacklist/remove from blacklist
     */
    function removeFromLocalBlacklist(
        address[] memory wallets
    ) external virtual {}

    uint256[50] private __gap;
}
