# Model Assignment

Use neutral task tiers in reusable commands and skills. Translate those tiers to the current platform's model or reasoning controls only at dispatch time.

## Tier Table

| Task | Tier | Claude mapping | Codex mapping | Why |
|------|------|----------------|---------------|-----|
| Deterministic pre-flight classifier over shell output | Light | Haiku | Mini / low effort | Structured table classification, little judgment |
| Trivial cherry-pick or mechanical batch worker | Standard | Sonnet | Standard / medium effort | Bounded code movement with a tight contract |
| Standard implementation worker | Standard | Sonnet | Standard / medium-high effort | Most coding work with known patterns |
| Review lane for meaningful code or plan changes | Standard / Heavy | Sonnet or Opus by risk | Standard/frontier, high effort by risk | Needs independence and judgment |
| Conflict resolution, architecture, RCA synthesis, security-sensitive review | Heavy | Opus | Frontier / high or xhigh effort | Multi-constraint reasoning and higher blast radius |
| Main orchestrator for long-running workflow | Orchestrator | User-selected, default Opus when available | User-selected, default frontier when available | Owns ordering, state, user decisions, and final synthesis |

## Rules

- Prefer the cheapest tier that can do the specific task safely.
- Keep deterministic discovery in shell and files before asking any model to reason.
- Do not hard-code provider model names in reusable skill contracts unless the file is provider-specific.
- The dispatching skill or runtime chooses the concrete model/reasoning setting from the tier; provider-specific startup docs such as `CLAUDE.md` or `AGENTS.md` own the tier-to-model mapping.
- Subagent prompts should say `Tier: Light/Standard/Heavy` plus the concrete task, exit criteria, and compact handoff format.
- Escalate a worker from Standard to Heavy when it hits conflicts, unclear ownership, security-sensitive code, cross-cutting APIs, migrations, auth, generated artifacts, or a low-confidence gate.
- The orchestrator owns final branch mutation, shared-state updates, and push decisions unless a command explicitly grants those actions to an isolated worker.
