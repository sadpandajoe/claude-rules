# /cherry-pick - Cross-Branch Work

Cherry-pick commits between branches safely.

## Prerequisites

**Read these rules first:**
1. `rules/universal.md` - Core principles
2. `rules/cherry-picking.md` - Cherry-pick-specific rules

Do not proceed until rules are read and understood.

---

## Steps

1. **Identify What to Cherry-Pick**
   
   Ask user:
   - Source commit(s)?
   - Target branch?
   - Why cherry-picking vs merge?

2. **Pre-Analysis**
   ```bash
   # Understand the commit
   git show <commit-hash>
   git show --stat <commit-hash>
   
   # Context
   git log --oneline <commit>~5..<commit>+5
   ```

3. **Dependency Check**
   ```bash
   # Compare dependencies
   git diff <target>..<source> -- package.json requirements.txt go.mod
   
   # Check if modules exist in target
   git ls-tree <target> -- <path/to/module>
   
   # Compare imports
   git show <source>:<file> | grep "import\|require"
   git show <target>:<file> | grep "import\|require"
   ```

4. **Risk Assessment**
   ```markdown
   ## Cherry-Pick Assessment
   
   ### Commit: `<hash>`
   
   ### Classification
   - [ ] Functional (logic, algorithms) → Usually safe
   - [ ] Structural (architecture) → Usually reject
   - [ ] Dependencies → Verify exist
   
   ### Compatibility
   - [ ] Dependencies exist in target
   - [ ] Import paths valid
   - [ ] APIs compatible
   
   ### Risk: [Low/Medium/High]
   ```

5. **Create Safety Branch**
   ```bash
   git checkout <target-branch>
   git checkout -b cherry-pick-<feature>-backup
   ```

6. **Execute Cherry-Pick**
   ```bash
   git cherry-pick <commit-hash>
   ```

7. **Handle Conflicts** (if any)
   
   For each conflict:
   ```bash
   # Check what's conflicting
   git status
   git diff
   ```
   
   Decision framework:
   - **Import conflict**: Module exists? Keep target if not
   - **Structure conflict**: Extract functional only
   - **API conflict**: Adapt to target's API
   
   ```bash
   # Keep target version (safe)
   git checkout --ours <file>
   
   # Or resolve manually, then:
   git add <file>
   ```

8. **Validation**
   ```bash
   # No conflict markers
   grep -rE "<<<|===|>>>" .
   
   # Builds
   [language-specific build]
   
   # Tests pass
   [language-specific tests]
   ```

9. **Document**
    ```markdown
    ## Cherry-Pick: [Feature]
    
    ### Source
    - **Commit**: `<hash>`
    - **Branch**: <source>
    
    ### Accepted
    - [What was taken]
    
    ### Adapted
    - [What was modified]
    
    ### Rejected
    - [What was excluded and why]
    ```

10. **Commit**
    ```bash
    git commit -m "chore: cherry-pick <feature> from <source>
    
    - Accepted: [what]
    - Adapted: [what]
    - Rejected: [what]
    
    Original commit: <hash>"
    ```

## Accept vs Reject

| ✅ Accept | ❌ Reject |
|-----------|----------|
| Bug fixes | Architecture changes |
| Isolated features | Unverified imports |
| Algorithm improvements | Breaking API changes |
| Data additions | Build system changes |

## Notes
- Verify dependencies exist first
- Prefer functional over structural
- When in doubt, reject
- Document everything
