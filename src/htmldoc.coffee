_ = require "underscore"
rules = (require "./coffeelint").RULES

render = () ->
    rulesHTML = ""

    for ruleName in _.sortBy (_.keys rules), ((s) -> s)
        rule = rules[ruleName]
        rule.name = ruleName
        rule.description = "[no description provided]" unless rule.description
        console.log ruleTemplate rule

ruleTemplate = _.template """
    <tr>
    <td class="rule"><%= name %></td>
    <td class="description">
        <%= description %>
        <p><em>default level: <%= level %></em></p>
    </td>
    </tr>
    """

render()
