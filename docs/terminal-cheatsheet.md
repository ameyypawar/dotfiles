# Terminal Cheatsheet

Last updated: 2026-05-03

---

## Daily terminal entry

1. Open **Ghostty** (cmd+space, type "ghostty", enter)
2. Run `tmux a` (attach to last session)
   - First time ever? Run `tmux` instead (creates a new session)
   - If `tmux a` says "no sessions", run `tmux` to start one
3. You're in. Status bar at the bottom = tmux is alive.

**Important rule**: never close panes with `exit` if you want them to keep running. Use `prefix d` (detach) to leave the session alive in the background. Then close Ghostty whenever — your work survives.

---

## Tmux — the multi-pane thing

**Prefix key** = `Ctrl+b` (I use Caps Lock as Ctrl, so it's Caps + b)

Press prefix, **release**, then press the next key. Don't chord all three.

### Splits and navigation

| What I want | Press |
|---|---|
| Split right | `prefix` then `\|` |
| Split down | `prefix` then `-` |
| Move to left/down/up/right pane | `prefix` then `h` / `j` / `k` / `l` |
| Resize pane (do it many times) | `prefix` then `H` / `J` / `K` / `L` |
| Make current pane fullscreen (toggle) | `prefix` then `z` |
| Close current pane (asks confirm) | `prefix` then `x` |

### Windows (think: tabs)

| What I want | Press |
|---|---|
| New window | `prefix` then `c` |
| Next / previous window | `prefix` then `n` / `p` |
| Jump to window N | `prefix` then number (e.g. `1`, `2`) |

### Sessions

| What I want | Type |
|---|---|
| Detach from session (leave it running) | `prefix` then `d` |
| Reattach last session | `tmux a` |
| List all sessions | `tmux ls` |
| New named session | `tmux new -s tubio` |
| Attach to specific session | `tmux a -t tubio` |

### If something breaks

| Problem | Fix |
|---|---|
| `prefix I` (capital i) doesn't install plugins | Make sure you're INSIDE tmux first (`echo $TMUX` should not be empty) |
| Theme didn't change | Run `prefix r` to reload, or kill server: `tmux kill-server` then `tmux` again |
| Ctrl+b does nothing | You're not in tmux yet OR your terminal is intercepting (use Ghostty, not Warp) |

---

## Worktrunk (`wt`) — git worktrees made easy

A "worktree" = a separate folder for each branch. Lets you work on multiple features at once without `git stash` mess.

### Basic flow

```bash
# inside any git repo:
wt switch -c feat/themes        # creates branch + folder + cd's into it
                                # folder lands at ../<repo>.feat-themes

wt list                         # show all my worktrees and their state

wt switch feat/themes           # jump to that worktree
wt switch main                  # jump back to main

wt merge                        # squash + commit (auto msg via Claude) +
                                # merge to main + delete branch + cd back

wt remove feat/themes           # nuke a worktree manually if needed
```

### What `wt merge` does for me (so I don't have to)

1. Stages everything I changed
2. Generates a commit message using Claude
3. Stashes anything dirty on main
4. Merges my worktree into main
5. Restores the stash on main
6. Deletes the worktree folder + branch
7. Drops me back on main

I literally just type `wt merge` when a feature is done. That's it.

### Copying ignored files into worktrees

Worktrees don't include `.env` or `node_modules` by default. To copy them:

```bash
wt step copy-ignored
```

Or set up a hook in `.wt/config.toml` so it happens automatically on `wt switch -c`.

---

## Shell shortcuts worth using

These are the muscle-memory shortcuts that make terminal life fast.

### Inside the prompt

| Press | What it does |
|---|---|
| `Ctrl+R` | Fuzzy search shell history (atuin) — the single most useful shortcut on this list |
| `Ctrl+T` | Fuzzy pick a file (fzf) — picks file path and pastes it |
| `Alt+C` | Fuzzy `cd` into a subdir (fzf) |
| `Ctrl+A` / `Ctrl+E` | Jump to start / end of line |
| `Ctrl+W` | Delete previous word |
| `Ctrl+U` | Delete from cursor to start of line |
| `Ctrl+L` | Clear screen (same as `clear`) |

### Smart `cd` — zoxide

Instead of `cd ~/Projects/my-repo`, just:

```bash
z tubio        # jumps to tubio (it learns paths I visit)
zi             # interactive picker via fzf
```

The more I `cd` to a place, the higher it ranks. After a week, `z whatever` just works.

### Tools to run inside the terminal

| Type | Get |
|---|---|
| `ll` | Better `ls` (eza, with icons + git status) |
| `la` | Like `ll` but shows hidden files |
| `lt` | Tree view (2 levels deep) |
| `lg` | Lazygit — full git TUI (stage, commit, branch, diff, all keyboard) |
| `gd` | gh dash — GitHub PR/issue dashboard |
| `top` | btop — system process viewer |
| `bat <file>` | Like `cat` but with syntax highlighting |
| `cat ~/.zshrc` | Plain `cat` still works for scripts that pipe stdout |

---

## Lazygit — git GUI in the terminal

Just type `lg`. Inside:

| Press | What it does |
|---|---|
| `space` | Stage / unstage selected file or hunk |
| `c` | Commit (opens editor for message) |
| `P` | Push to remote |
| `p` (lowercase) | Pull from remote |
| `b` | Branch menu |
| `s` | Stash menu |
| `?` | Show all keybindings (best feature) |
| `q` | Quit |

When I'm confused about git state, `lg` shows me everything visually. Use it when stuck.

---

## Git commands worth running by hand

### Daily

```bash
git status                      # what's changed
git diff                        # show unstaged changes
git diff --staged               # show staged changes
git add <file>                  # stage a specific file
git add -p                      # stage hunk-by-hunk (great for learning)
git commit -m "message"         # commit
git push                        # push current branch to origin
git pull                        # fetch + merge from origin
git log --oneline -20           # last 20 commits, one line each
```

### Branches

```bash
git branch                      # list local branches
git branch -avv                 # list ALL branches with last commit + tracking
git checkout main               # switch to main
git checkout -b feat/name       # create AND switch to new branch
git branch -d feat/name         # delete merged branch (-D forces)
```

### Recovery (use when scared)

```bash
git reflog                      # shows everything I've done — find lost commits here
git reset --soft HEAD~1         # undo last commit, keep changes staged
git reset --hard <sha>          # WARNING: nukes back to commit, lose unstaged work
git stash                       # tuck dirty changes away
git stash pop                   # bring them back
```

### Tags = save points before scary stuff

```bash
git tag pre-something-2026-05-03         # tag where I am right now
git push origin pre-something-2026-05-03 # push tag to GitHub
git checkout pre-something-2026-05-03    # go back to that exact state
```

If I'm about to do anything I'm unsure about, **tag first**. Free insurance.

---

## Starship prompt — what those symbols mean

Look at my prompt:

```
~/Projects/tubio  on  main [!?]  with 󰎙 v18.20.0
❯
```

| Symbol | Meaning |
|---|---|
|  | Folder icon |
|  | Branch icon (next to branch name) |
| `[!]` | I have unstaged changes |
| `[?]` | I have untracked files |
| `[+]` | I have staged changes |
| `[$]` | I have stashed changes |
| `[=]` | Local and remote in sync |
| `󰎙 v18` | Node version (shows up in JS projects) |
| `❯` | The actual prompt |

If I see something weird in my prompt, it's usually telling me about git state — git status will explain.

---

## Ghostty — the terminal window itself

| Press | What it does |
|---|---|
| `cmd+t` | New tab |
| `cmd+d` | Split current pane right |
| `cmd+shift+d` | Split current pane down |
| `cmd+w` | Close pane / tab |
| `cmd+shift+enter` | Zoom focused pane (toggle) |
| `cmd+,` | Open Ghostty config in editor |
| `cmd+shift+,` | Reload config (after editing) |
| `cmd+shift+i` | Show Ghostty info / version |

**Tmux vs Ghostty splits — when to use which?**

- **Use tmux splits** when you want the layout to survive. Inside tmux, even if Ghostty quits, panes come back when you `tmux a`.
- **Use Ghostty splits** for quick, throwaway extra terminals (e.g. "I just need to run a one-off command and close it").

I default to tmux 99% of the time.

---

## Files this affects

| File | What's in it |
|---|---|
| `~/.zshrc` | Shell config — starship, fzf, zoxide, atuin, aliases |
| `~/.config/ghostty/config` | Ghostty terminal — theme, font, keybinds reference |
| `~/.tmux.conf` | tmux config — prefix, splits, plugins |
| `~/.config/starship.toml` | Prompt theme (catppuccin-powerline preset) |
| `~/.claude/settings.json` | Claude Code config — model, plugins, statusline |
| `~/.tmux/plugins/` | Tmux plugins installed by TPM |

If I want to change something, edit the right file, then reload:

| Tool | How to reload |
|---|---|
| zsh | New shell, or `exec zsh` |
| Ghostty | `cmd+shift+,` |
| Tmux | `prefix r` |

---

## Common gotchas

1. **"My alias isn't working"** → I edited `.zshrc` but didn't restart the shell. Run `exec zsh` or open a new terminal.
2. **"Tmux says no sessions"** → No tmux running. Type `tmux` to start one.
3. **"Catppuccin theme isn't loaded in tmux"** → I forgot `prefix I` to install plugins. Run it.
4. **"Ctrl+b does nothing"** → Either I'm not in tmux (`echo $TMUX`), or my terminal is eating the keystroke (use Ghostty, not Warp).
5. **"`wt switch` says not a worktree repo"** → Worktrees need git. `cd` into a real git repo first.
6. **"Editor opens for git commit but I can't save"** → Editor is `cursor --wait`. Save in Cursor with cmd+s, then close the file tab. Git sees it saved.

---

## Suggested learning order

1. **Use `lazygit` (lg) for a week**. Watch every action it takes. Learn the keybindings. This builds git intuition fast.
2. **Force myself to use `Ctrl+R`** for command history instead of arrow keys. Atuin's fuzzy search is faster.
3. **Start a real merge conflict on purpose** in a scratch repo, resolve it by hand. This is the senior-dev muscle.
4. **Try `wt switch -c feat/test`** in any repo, make a tiny change, `wt merge`. Feel the magic.
5. **Read the `wt config plugins claude install`** output once — understand what the plugin does.
6. **Make a tmux session per project**: `tmux new -s tubio`, `tmux new -s gitfix`. Switch with `tmux a -t <name>`.

---

## Recovery ladder (when something feels broken)

```
1. Reload the relevant tool (prefix r in tmux, cmd+shift+, in ghostty, exec zsh in shell)
2. Check the docs:    `man <tool>` or `<tool> --help`
3. Restart the tool:  quit and relaunch Ghostty
4. Worst case:        `tmux kill-server` then `tmux` to fully reset tmux
5. If git is scared:  `git reflog` shows my last 100 actions — I can always find a way back
```

Tags are my friend. Tag before scary git ops. Tags are free.
