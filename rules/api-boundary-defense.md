# API Boundary Defense

This is a routing hint, not a full always-on rule.

When diagnosing or fixing a frontend-to-backend performance or correctness bug, read `skills/debug/gotchas.md` and check whether the dangerous behavior is still allowed at the API boundary.

Examples:
- Missing pagination params
- Missing filters
- Unbounded batch sizes

The detailed rule lives with debugging because it only applies when that class of bug is being investigated or fixed.
