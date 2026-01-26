# /explain - Explain Code (Codex)

Have Codex explain code sections.

## Usage
```
/explain <file>                     # Explain entire file
/explain <file> --function <name>   # Explain specific function
/explain <file> --lines <start>-<end>  # Explain line range
/explain --diff                     # Explain recent changes
```

## Steps

1. **Determine Scope**

   Use native tools to gather code:
   - **Entire file**: Use `Read` tool
   - **Specific function**: Use `Grep` tool with pattern `function <name>|def <name>`
   - **Line range**: Use `Read` tool with `offset` and `limit` parameters
   - **Recent changes**: Use `git diff` via Bash

2. **Codex Explain**
   ```
   codex exec --sandbox read-only "Explain this code clearly.
   
   CODE:
   ---
   [insert code]
   ---
   
   Provide:
   
   ## Overview
   [1-2 sentence summary of what this code does]
   
   ## Step-by-Step Breakdown
   1. [First thing that happens]
   2. [Next step]
   3. [Continue...]
   
   ## Key Concepts
   - **[Concept 1]**: [Explanation]
   - **[Concept 2]**: [Explanation]
   
   ## Data Flow
   [How data moves through this code]
   Input → [transform] → [transform] → Output
   
   ## Dependencies
   - [What this code depends on]
   - [External libraries/modules used]
   
   ## Potential Issues
   - [Any edge cases or gotchas]
   - [Error conditions to be aware of]
   
   ## Usage Example
   ```
   [How to call/use this code]
   ```"
   ```

3. **Present Explanation**
   
   Show Codex output directly to user.

4. **Optional Follow-ups**
   
   Offer to:
   - Explain related code
   - Show usage examples
   - Identify potential improvements
   - Generate tests for this code (`/suggest-tests`)

## For Diff Explanations

When explaining changes (`--diff`):
```
codex exec --sandbox read-only "Explain what these code changes do.

DIFF:
---
[git diff output]
---

Provide:
## Summary
[What this change accomplishes]

## Changes Made
1. [Change 1 and why]
2. [Change 2 and why]

## Impact
- [What behavior changes]
- [What stays the same]

## Risks
- [Any potential issues introduced]"
```

## Notes
- Codex does read-only analysis
- Good for onboarding/understanding unfamiliar code
- Use before modifying complex code
- Can chain: /explain → /suggest-tests → /implement
