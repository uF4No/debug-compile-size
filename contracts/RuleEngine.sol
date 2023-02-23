//SPDX-License-Identifier: MPL-2.0

pragma solidity ^0.8.17;

// required OZ imports here
import "./interfaces/IRuleEngine.sol";
import "./interfaces/IRule.sol";
import "./Rule.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./modules/LocalListModule.sol";
import "./GlobalList.sol";

contract RuleEngine is IRuleEngine, Ownable {
    IRule[] private _rules;

    constructor(GlobalList globalList, LocalListModule localList) {
        _rules.push(new Rule(globalList, localList));
    }

    function setRules(IRule[] calldata rules_) external onlyOwner {
        _rules = rules_;
    }

    function addRule(IRule rule_) external onlyOwner {
        _rules.push(rule_);
    }

    function ruleLength() external view returns (uint256) {
        return _rules.length;
    }

    /**
     * @dev returns address of rule given a ruleId. starts with 1.
     */
    function rule(uint256 ruleId) external view returns (IRule) {
        require(
            _rules.length >= ruleId && ruleId > 0,
            "RuleEngine: invalid ruleID"
        );
        return _rules[ruleId - 1];
    }

    function rules() external view returns (IRule[] memory) {
        return _rules;
    }

    function detectTransferRestriction(
        address _from,
        address _to,
        uint256 _value
    ) public view returns (uint8) {
        uint256 len = _rules.length;
        for (uint256 i = 0; i < len; i++) {
            uint8 restriction = _rules[i].detectTransferRestriction(
                _from,
                _to,
                _value
            );
            if (restriction > 0) {
                return restriction;
            }
        }
        return 0;
    }

    function validateTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external view returns (bool) {
        return detectTransferRestriction(_from, _to, _amount) == 0;
    }

    function messageForTransferRestriction(
        uint8 _restrictionCode
    ) external view returns (string memory) {
        for (uint256 i = 0; i < _rules.length; i++) {
            IRule _rule = _rules[i];
            if (_rule.canReturnTransferRestrictionCode(_restrictionCode)) {
                return _rule.messageForTransferRestriction(_restrictionCode);
            }
        }
        return "Unknown restriction code";
    }
}
