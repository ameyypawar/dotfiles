# delta + difftastic — Pretty and Smart Git Diffs

For reading code changes in the terminal. Daily-use cheatsheet for PR review and personal git work.

---

## What They Are (Plain English)

### delta

A **pretty printer for git diff**. It takes the boring monochrome output git produces and shows it with colors, line numbers, file headers, and search. You still use normal git commands (`git diff`, `git log -p`, `git show`) — delta just makes them look good.

Think of it as Instagram filter for git diff.

### difftastic (`difft`)

A **smarter diff that understands code structure**. While regular diff compares lines of text, difft parses the code into a tree (AST) and compares meaning.

Use it when a PR is a rename, a reformat, or a refactor — regular diff makes those look huge, difft shows the real change.

---

## When to Use Which

| Situation | Tool |
|---|---|
| Daily `git diff` while coding | **delta** (it's the default now) |
| Reading any PR locally | **delta** |
| PR is just a rename across 20 files | **difft** |
| PR ran prettier / black / rustfmt and you can't tell what real code changed | **difft** |
| Wrapping existing code in a new if/loop/function | **difft** |
| Small 1-line bug fix | GitHub web UI is fine, no need to pull |

Rule of thumb: **delta is your daily reader; difft is your "wait, what actually changed?" debugger.**

---

## Commands worth using daily

### Daily

```
git diff                Shows uncommitted changes. delta renders it pretty.
git diff main           Show all my changes vs main branch.
git diff HEAD~1         Show what the last commit changed.
git show <sha>          Show a specific commit's changes.
git log -p              History + diffs of every commit, paginated.
```

All of these now go through delta automatically. Colors, line numbers, file navigation included.

### Inside delta (when paging)

```
n                       Jump to next changed file
N                       Jump to previous changed file
/pattern                Search forward for "pattern"
?pattern                Search backward
q                       Quit pager
```

### Semantic diff with difft (use git aliases I set)

```
git dft                 Same as git diff but with semantic difft view
git dft main            Compare branch to main, semantic view
git dfts <sha>          Show a commit, semantic view
git dftl                Log with semantic per-commit diff
```

The `dft` is short for "difftastic." Treat these as my "I don't understand this PR" backup view.

---

## Concrete Examples — Why difft Pays Off

### Example 1: Variable rename

Code change: rename `count` to `counter` in 10 places.

**Regular delta diff**:
```
- const count = useState(0)
+ const counter = useState(0)
- setCount(count + 1)
+ setCounter(counter + 1)
- return <button>{count}</button>
+ return <button>{counter}</button>
```
Looks like a big change. I'd squint for a while.

**difft (`git dft`) output**:
```
[rename] count → counter
```
I get it instantly.

### Example 2: Reformat with prettier

The PR ran `pnpm prettier --write src/`. Every file looks fully rewritten in regular diff because indentation, quotes, trailing commas changed.

**delta** shows hundreds of changed lines.
**difft** shows: *"no semantic change in src/file.ts"* — I know to skip and trust the formatter.

### Example 3: Wrapping in an if-block

Existing function gets wrapped:
```js
// before:
saveUser(data)

// after:
if (user.isPremium) {
  saveUser(data)
}
```

**delta** marks every line of saveUser as modified (indentation changed).
**difft** marks only the *added* if-wrapper. Clear intent.

---

## PR Review Workflow

When reviewing someone's PR (mine or open-source):

```bash
# 1. Pull the PR locally
gh pr checkout 123

# 2. Quick look — what files changed?
git diff main --stat

# 3. Read the actual changes
git diff main                       # delta-pretty diff

# 4. If it looks like a refactor, also check semantic view
git dft main                         # difft semantic diff

# 5. Run their tests locally before commenting
pnpm test                            # or cargo test / pytest / etc.

# 6. Go to GitHub and comment inline
gh pr view 123 --web                 # open in browser, comment there
```

For my own PRs before pushing:

```bash
git diff main                        # delta — make sure I see what I'm shipping
git dft main                         # difft — verify intent matches what AST sees
git status                           # any files I forgot?
```

---

## Useful aliases configured

| Alias | Runs |
|---|---|
| `git dft` | `GIT_EXTERNAL_DIFF=difft git diff` — semantic diff |
| `git dfts <sha>` | `GIT_EXTERNAL_DIFF=difft git show <sha>` — semantic view of a commit |
| `git dftl` | `git log --ext-diff -p` with difft — semantic log |

All other git commands stay the same. delta auto-applies; difft only when I ask.

---

## Files this affects

These were the configured changes (already done, just for my reference):

```ini
# ~/.gitconfig (added under [core], [interactive], [delta], [alias])
[core]
  pager = delta
[interactive]
  diffFilter = delta --color-only
[delta]
  navigate = true
  line-numbers = true
  syntax-theme = Catppuccin Mocha
[alias]
  dft  = !GIT_EXTERNAL_DIFF=difft git diff
  dfts = !GIT_EXTERNAL_DIFF=difft git show
  dftl = !git log --ext-diff -p
```

To undo all of this if I ever want plain old git back:
```bash
git config --global --unset core.pager
git config --global --unset interactive.diffFilter
git config --global --remove-section delta
git config --global --unset alias.dft
git config --global --unset alias.dfts
git config --global --unset alias.dftl
brew uninstall git-delta difftastic
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Colors look wrong | Confirm terminal supports true color: `echo $COLORTERM` should say `truecolor` |
| `delta` not found after install | Restart shell: `exec zsh` (PATH refresh) |
| Theme "Catppuccin Mocha" not found | Already installed via bat earlier; re-run `bat cache --build` if missing |
| difft is slow on huge files | It's parsing the whole AST — that's expected for files >5k lines. Use delta for those. |
| Want to disable delta temporarily for one command | `git --no-pager diff` |
| Want plain `git diff` output (no delta) | `git config --global --unset core.pager` (revert) |

---

## Mental model

> **delta** = my eyes. Daily reader. Pretty colors, navigate fast, search.
> **difft** = my brain. Semantic check. "What actually changed beyond formatting?"

> Both are pagers — they don't change git, they change how I *see* git. Reversible in one command.

> For open-source PR review: pull the PR (`gh pr checkout N`), skim with delta, sanity-check refactors with difft, run their tests, comment on GitHub.
