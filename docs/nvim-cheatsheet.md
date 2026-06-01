# Neovim Cheatsheet

For a kickstart.nvim setup. Leader key = **Space**.

---

## Panic exit

If I'm ever lost or stuck:

1. Press **Esc** (gets me to Normal mode, always safe)
2. Type `:qa!` and press Enter (quit everything, discard changes)

That's the emergency exit. Nothing breaks.

---

## The Four Modes

Vim is **modal** — what each key does depends on which mode I'm in. Press **Esc** to always return to Normal.

| Mode | What it's for | How to enter |
|---|---|---|
| **Normal** | Navigation, deleting, copying. The home base. | Esc (always works) |
| **Insert** | Actually typing text into the file. | `i` (before cursor), `a` (after), `o` (new line below), `O` (new line above) |
| **Visual** | Selecting text. | `v` (char), `V` (line), `Ctrl+v` (block) |
| **Command** | Running `:` commands like `:w`, `:q`. | `:` from Normal |

Mnemonic: **i** = insert, **a** = append, **o** = open new line, **v** = visual.

---

## Essential Motions (Normal mode)

Move the cursor without leaving Normal mode.

| Keys | Where it goes |
|---|---|
| `h` `j` `k` `l` | Left / Down / Up / Right (one char) |
| `w` | Next word start |
| `b` | Previous word start |
| `e` | Next word end |
| `0` | Start of line |
| `$` | End of line |
| `gg` | Top of file |
| `G` | Bottom of file |
| `:42` Enter | Jump to line 42 |
| `f<char>` | Jump to next `<char>` on current line (e.g. `f(`) |
| `%` | Jump between matching brackets/parens |

---

## Operators — the Verbs

Operators act on something. Combine with a motion or text object.

| Op | What it does |
|---|---|
| `d` | Delete (cuts to clipboard) |
| `c` | Change (delete + enter Insert mode) |
| `y` | Yank (copy) |
| `p` | Paste after cursor |
| `P` | Paste before cursor |

**The grammar that makes vim click**: `[count] operator motion`

- `dw` = delete word
- `d2w` = delete 2 words
- `cc` = change whole line
- `yy` = yank line
- `dd` = delete line
- `d$` = delete to end of line
- `c0` = change to start of line

---

## Text Objects — operate on semantic units

Pattern: `[operator] i/a [object]`. `i` = **inside**, `a` = **around** (includes the delimiters).

| Keys | Meaning |
|---|---|
| `iw` / `aw` | Inside / around word |
| `i"` / `a"` | Inside / around double quotes |
| `i'` / `a'` | Inside / around single quotes |
| `i(` / `a(` | Inside / around parentheses (also `i)`, `ib`) |
| `i{` / `a{` | Inside / around curly braces (also `i}`, `iB`) |
| `i[` / `a[` | Inside / around square brackets |
| `it` / `at` | Inside / around HTML/XML tag |

Examples that pay for themselves:

- `ciw` — change inner word (replace the word my cursor is on)
- `da"` — delete around quotes (deletes the string AND the quotes)
- `yi{` — yank inside braces (copy a function body)
- `ci(` — change inside parens (rewrite function arguments)

---

## Search & Replace

| Keys | What |
|---|---|
| `/foo` Enter | Search forward for "foo" |
| `?foo` Enter | Search backward |
| `n` / `N` | Next / previous match |
| `*` | Search for word under cursor |
| `:%s/foo/bar/g` | Replace all "foo" with "bar" in file |
| `:%s/foo/bar/gc` | Same, but ask confirmation for each |

---

## Editing Basics

| Keys | What |
|---|---|
| `u` | Undo |
| `Ctrl+r` | Redo |
| `x` | Delete char under cursor |
| `r<char>` | Replace char under cursor |
| `J` | Join current line with next |
| `>>` / `<<` | Indent / unindent line |
| `==` | Auto-indent line |
| `.` | Repeat last change (super powerful) |

---

## Files & Buffers (Command mode)

| Command | What |
|---|---|
| `:w` | Save |
| `:w <newname>` | Save as |
| `:q` | Quit (refuses if unsaved) |
| `:q!` | Quit, discard changes |
| `:wq` | Save + quit |
| `:qa` | Quit all windows |
| `:qa!` | Force quit all (panic button) |
| `:e <path>` | Open file |
| `:e .` | Open file browser at cwd |
| `:bd` | Close current buffer |
| `:bn` / `:bp` | Next / previous buffer |
| `:ls` | List open buffers |

---

## Kickstart Keybinds — Telescope (fuzzy finder)

All start with **Space** (the leader).

| Keys | What |
|---|---|
| `Space sf` | Search **f**iles |
| `Space sg` | Search by **g**rep (text content across project) |
| `Space sw` | Search **w**ord under cursor |
| `Space sh` | Search **h**elp docs |
| `Space sk` | Search **k**eymaps |
| `Space sd` | Search **d**iagnostics |
| `Space sr` | **R**esume last search |
| `Space s.` | Recent files |
| `Space sc` | Search **c**ommands |
| `Space sn` | Search **n**eovim config |
| `Space /` | Fuzzy search inside current buffer |
| `Space s/` | Grep in open files only |
| `Space Space` | Switch between open buffers |

---

## Kickstart Keybinds — LSP (when on a code file)

These are the new Neovim 0.11+ defaults that kickstart uses.

| Keys | What |
|---|---|
| `K` | Show hover docs (type info, function signature) |
| `grd` | **G**o to definition |
| `grD` | Go to **d**eclaration |
| `grr` | Show **r**eferences (Telescope picker) |
| `gri` | Go to **i**mplementation |
| `grt` | Go to **t**ype definition |
| `grn` | Re**n**ame symbol (across entire project) |
| `gra` | Code **a**ctions (autofix, refactor menu) |
| `gO` | Document symbols (outline) |
| `gW` | Workspace symbols (project-wide) |
| `[d` / `]d` | Previous / next diagnostic |

---

## Other Useful Keybinds

| Keys | What |
|---|---|
| `Space f` | Format buffer (prettier for TS/TSX/JSON/etc) |
| `Space q` | Open diagnostic quickfix list |
| `Space th` | Toggle LSP inlay hints |
| `Ctrl+d` / `Ctrl+u` | Scroll half-page down / up |
| `Ctrl+o` | Jump back (after `grd` go-to-def) |
| `Ctrl+i` | Jump forward |
| `:Lazy` | Plugin manager UI (was `:Lazy` in old kickstart; this version uses `vim.pack`) |
| `:Mason` | LSP/formatter installer UI |
| `:checkhealth` | Diagnose plugin/dependency issues |

---

## Splits & Windows

| Command | What |
|---|---|
| `:vs <file>` | Vertical split with file |
| `:sp <file>` | Horizontal split |
| `Ctrl+w h/j/k/l` | Move to split in direction |
| `Ctrl+w c` | Close current split |
| `Ctrl+w =` | Equalize split sizes |

---

## 2-Week Learning Plan

10–20 min of *actual practice* each day on real code beats reading.

| Day | Learn | Time |
|---|---|---|
| **Day 1** | Run `:Tutor` (built-in 30-min tutorial) | 30 min |
| **Day 1** | Quit reflex: Esc → `:qa!` | 5 min |
| **Day 2** | `dd`, `yy`, `p`, `x`, `u`, `Ctrl+r` | 15 min |
| **Day 3** | `w`, `b`, `0`, `$`, `gg`, `G` | 15 min |
| **Day 4** | Operators + counts: `dw`, `2dd`, `c$`, `5yy` | 20 min |
| **Day 5** | `/pattern`, `?pattern`, `n`, `N`, `*` | 15 min |
| **Day 6** | Text objects: `ciw`, `da"`, `yi{` | 20 min |
| **Day 7** | Review — notice when I use arrow keys instead of `hjkl` | 10 min |
| **Week 2 Day 1–2** | Kickstart `Space s*` Telescope pickers | 20 min |
| **Week 2 Day 3–4** | LSP nav: `K`, `grd`, `grr`, `grn`, `gra` | 20 min |
| **Week 2 Day 5–7** | Precision motions: `f<char>`, `t<char>`, `%`, text-object variants | 30 min |

---

## Things easy to forget (and Where to Look)

- All keybinds: press **Space**, wait — **which-key** popup shows what's available
- LSP keybinds: `:Telescope keymaps` or `Space sk`
- Help on anything: `:help <topic>` (e.g. `:help motion`, `:help text-objects`)
- My own config: `~/.config/nvim/init.lua` (it's documented top-to-bottom)

---

## Mental Model

> **Vim is modal.** Most apps you've used are insert-mode-by-default. Vim is normal-mode-by-default. That feels alien for a week, then it becomes faster than anything else because navigation and editing don't fight for the same keys.

> **Composition over memorization.** I don't memorize 300 commands. I memorize ~10 verbs + ~10 nouns and compose them. `d` + `i` + `w` = "delete inside word." `c` + `a` + `"` = "change around quotes." That grammar is the whole point.

> **The cursor stays on the home row.** If I find myself reaching for arrow keys or the mouse during editing, I'm not in vim yet. That'll click around day 5.
