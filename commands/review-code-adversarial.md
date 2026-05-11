# /review-code-adversarial - Adversarial Red-Team Review


> **When**: You want to stress-test changes for security holes, edge cases, race conditions, and failure modes.
> **Produces**: Merged adversarial findings, fixes, verification, and an adversarial Review Gate block.

## Usage

```bash
/review-code-adversarial
/review-code-adversarial --committed
/review-code-adversarial src/api/
```

## Step Routing

Load [skills/review/references/adversarial-orchestration.md](../skills/review/references/adversarial-orchestration.md) when the review starts. It coordinates changed-file discovery, reviewer launch, finding merge, fix/verify, and re-review.

Within that flow:

- Use [skills/review/references/adversarial.md](../skills/review/references/adversarial.md) for the primary adversarial reviewer.
- Use an optional second-opinion adversarial reviewer only when available.
- Use `/review-code` style Review Gate semantics for final status.

## Gates

- Every finding needs a concrete failure scenario.
- Do not claim second-opinion coverage unless both lanes ran.
- Run `/verify` or equivalent pre-flight checks before final Review Gate when fixes are applied.
- Fix, reject with evidence, or surface each finding as a user decision.
- Emit the adversarial Review Gate before the final summary.

## Summary Contract

End with:

```markdown
## Review-Code-Adversarial Complete
Rating: [Hardened/Adequate/Vulnerable/Critical] | Rounds: [N] | Status: [clean/blocked]
Reviewers: [primary + second opinion | primary only]

### Findings
- [...]

### Fixed
- [...]

### Accepted Risks
- [...]
```
