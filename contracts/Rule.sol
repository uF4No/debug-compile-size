//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

import "./interfaces/IRule.sol";
import "./modules/LocalListModule.sol";
import "./GlobalList.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rule is IRule, Ownable {
    uint8 public constant SUCCESS_CODE = 0;
    uint8 public constant NOT_WHITELISTED_CODE = 1;
    uint8 public constant GLOBALLY_BLACKLISTED_CODE = 2;
    uint8 public constant LOCALLY_BLACKLISTED_CODE = 3;

    string public constant UNKNOWN_MESSAGE = "Unknown restriction code";

    GlobalList public globalList;
    LocalListModule public localList;
    mapping(uint8 => string) public transferRestrictionMessages;

    constructor(GlobalList globalList_, LocalListModule locallist_) {
        transferRestrictionMessages[SUCCESS_CODE] = "SUCCESS";
        transferRestrictionMessages[
            NOT_WHITELISTED_CODE
        ] = "Address not on whitelist";
        transferRestrictionMessages[
            GLOBALLY_BLACKLISTED_CODE
        ] = "Address on global blacklist";
        transferRestrictionMessages[
            LOCALLY_BLACKLISTED_CODE
        ] = "Address on local blacklist";
        globalList = globalList_;
        localList = locallist_;
    }

    function setGlobalList(GlobalList globalList_) external onlyOwner {
        globalList = globalList_;
    }

    function setLocalList(LocalListModule localList_) external onlyOwner {
        localList = localList_;
    }

    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool isValid) {
        return detectTransferRestriction(_from, _to, _amount) == 0;
    }

    function canReturnTransferRestrictionCode(
        uint8 _restrictionCode
    ) external view returns (bool) {
        return bytes(transferRestrictionMessages[_restrictionCode]).length != 0;
    }

    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _amount
    ) public view returns (uint8) {
        GlobalList _globalList = globalList;
        LocalListModule _localList = localList;
        if (_globalList.isBlacklisted(_to) || _globalList.isBlacklisted(_from))
            return GLOBALLY_BLACKLISTED_CODE;
        if (
            _localList.isBlacklistedLocally(_to) ||
            _localList.isBlacklistedLocally(_from)
        ) return LOCALLY_BLACKLISTED_CODE;
        if (
            (!_globalList.isWhitelisted(_to) &&
                !_localList.isWhitelistedLocally(_to)) ||
            (!_globalList.isWhitelisted(_from) &&
                !_localList.isWhitelistedLocally(_from))
        ) return NOT_WHITELISTED_CODE;
        return SUCCESS_CODE;
    }

    function messageForTransferRestriction(
        uint8 restrictionCode
    ) public view returns (string memory message) {
        message = transferRestrictionMessages[restrictionCode];
        if (bytes(message).length != 0) {
            return message;
        } else return UNKNOWN_MESSAGE;
    }
}
