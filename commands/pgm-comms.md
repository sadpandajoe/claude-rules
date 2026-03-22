# /pgm-comms — Format for Audience

@/Users/joeli/opt/code/claude-rules/skills/pgm/comms/SKILL.md

> **When**: After generating a report or gathering program data, format it for a specific audience.
> **Produces**: Audience-formatted output (executive, delivery, eng+QA, cross-functional, broad stakeholder, or escalation).

## Usage

```
/pgm-comms executive           # Format recent report/context for execs
/pgm-comms delivery            # Format for delivery team
/pgm-comms escalation "auth"   # Escalation about a specific topic
```

## Steps

1. **Identify source data**: Use the most recent report, status update, or program data in the current conversation. If none exists, tell the user to run `/create-report` or `/velocity-report` first. If a trailing argument is provided after the audience (e.g., `"auth"`), use it as a topic filter — focus the formatted output on that topic/epic/area.
2. **Determine audience**: From the argument, or infer from context (see SKILL.md rules).
3. **Format**: Apply the audience template and rules from the loaded `pgm-comms` skill.
4. **Present**: Output the formatted content, ready to copy/paste.
