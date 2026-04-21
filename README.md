**English** | [中文](README.zh-CN.md)

# Knowledge Vault — AI-agent-operated cross-project knowledge system

> An Obsidian vault template designed to be operated by Claude Code as an agent.
> Mirrors docs from multiple code projects into a read-only area, then distills
> cross-project patterns into a writeable notes area. Ships with sync scripts
> and a behavior contract ([`AGENT-GUIDE.md`](AGENT-GUIDE.md)) for the agent.
> Methodology only — no real project docs included; bring your own.

---

## Why this vault exists

Every code project has its own `docs/`. But cross-project insight has no home:

- The **same class of bug** that multiple projects independently stepped on (missing
  format conversions at boundaries, baseline contamination…)
- **Engineering consensus** that multiple projects independently arrived at
  ("use name, not UUID, for cross-roundtrip identity")
- **Evolution asymmetries** — one project solved it, another hasn't hit it yet

These cross-project insights are worth more than any single-project doc, but
nobody maintains them by hand — unless there's a stable place for them and
someone whose job is to distill.

**This vault gives cross-project insight a home and puts an AI agent in charge of
distilling it — so you don't have to copy-paste it by hand.**

---

## How it works

```
┌────────────────────┐  sync (one-way force overwrite)  ┌─────────────────────┐
│ your project/docs/ │ ────────────────────────────────→│ vault/mirror/<name>/│  ← read-only
└────────────────────┘                                  └─────────────────────┘
                                                                  │
                                                                  │ agent reads + distills
                                                                  ↓
                                                        ┌─────────────────────┐
                                                        │ vault/notes/        │  ← agent's only
                                                        │  ├── synthesized/   │    writeable area
                                                        │  └── cross-project/ │
                                                        └─────────────────────┘
```

Three pieces:

- **`mirror/`** — read-only mirror. Each subdir is a snapshot of one project's `docs/`.
  The sync script overwrites it in one direction; **manual edits are lost on the
  next sync**.
- **`notes/`** — the agent's only writeable area. Holds single-project distillations
  (`synthesized/`) and cross-project patterns (`cross-project/`).
- **[`CLAUDE.md`](CLAUDE.md) + [`AGENT-GUIDE.md`](AGENT-GUIDE.md)** — the behavior
  contract Claude Code loads: what it can touch, what it can't, how to diff a new
  sync, when to extract a cross-project pattern, what format to write notes in.

Your role: run the sync + send the agent a "start processing" trigger + review output.
Agent's role: diff, distill, connect, abstract, write notes.

---

## Value proposition

**Single-project docs are necessary but not sufficient.**

Concrete example from the template author's own use: two unrelated projects (a 3D
animation editor and an AI joint-rigging study) each, in their own ADRs, arrived
at "use name, not UUID, for cross-roundtrip identity" — but each project recorded
it as a one-off.

Only once the agent connected the two in `cross-project/decisions/` did it become
clear: **this is an engineering signal independently validated by two distinct
projects** — far more convincing than either alone.

**Recognizing patterns is the agent's primary value-add.** Without that step, you
might as well skip Obsidian.

---

## Quick start

### Prerequisites

- Obsidian (any version — purely for rendering and wiki-link navigation)
- Claude Code CLI (the agent that distills `mirror/` — see https://claude.com/claude-code)
- `rsync` (Unix/macOS) or `robocopy` (built into Windows)

### 5-step setup

```bash
# 1. Clone
git clone https://github.com/Hockwang/knowledge-vault.git
cd knowledge-vault

# 2. Fill out the sync config (tell the script which projects' docs/ to mirror)
cp scripts/vault-config.example.yml scripts/vault-config.yml
# Edit scripts/vault-config.yml with your own project paths

# 3. Run the first sync
./scripts/sync.sh           # Unix / macOS
# or
.\scripts\sync.ps1          # Windows PowerShell

# 4. Open the vault ROOT in Obsidian (not notes/! — see AGENT-GUIDE.md's
#    "Vault root convention" section for why this matters)

# 5. Start Claude Code in the vault root, then tell it:
#    "mirror/<your-project>/ is synced, start processing"
#    (or the Chinese equivalent: "mirror/<project>/ 同步完了，开始整理")
#    It will follow the 5-step workflow in AGENT-GUIDE.md:
#    diff → decide action → cross-project connect → update index → report
```

---

## Repo layout

```
knowledge-vault/
├── README.md / README.zh-CN.md     ← EN primary, CN variant
├── LICENSE                         ← MIT
├── CLAUDE.md / CLAUDE.en.md        ← Agent entry (CN primary, EN mirror)
├── AGENT-GUIDE.md / AGENT-GUIDE.en.md  ← Agent manual (CN primary, EN mirror)
├── .gitignore
├── .obsidian/                      ← minimal Obsidian config
├── mirror/                         ← [READ-ONLY] project docs mirrors; sync overwrites
│   └── <your-project>/             ← appears after sync
├── notes/                          ← [WRITEABLE] agent's output area
│   ├── index.md                    ← master index
│   ├── log.md                      ← work log
│   ├── synthesized/                ← per-project distillations
│   └── cross-project/              ← cross-project patterns (highest value)
│       ├── patterns/
│       ├── decisions/
│       └── gotchas/
└── scripts/
    ├── sync.sh / sync.ps1          ← sync scripts
    ├── vault-config.example.yml
    └── README.md                   ← script usage
```

> **Agent docs**: `CLAUDE.md` and `AGENT-GUIDE.md` are **Chinese by default**
> because Claude Code auto-loads them at session start and the template
> author's workflow is Chinese. English mirrors live at `CLAUDE.en.md` and
> `AGENT-GUIDE.en.md`. If your workflow is English, rename the `.en.md` files
> to take their slot (or point Claude Code at them explicitly).

---

## Customize

Core invariants (don't break these):

- `mirror/` is read-only, `notes/` is the only writeable area, the agent's job
  is to **distill**, not to copy-paste
- Cross-roundtrip / cross-system / cross-project identifiers use **names, not
  UUIDs** (human-readable, stable across serialization)
- On conflict or ambiguity the agent must **stop and ask** rather than decide
  unilaterally

Everything else is fair game:

- The 5-step workflow in `AGENT-GUIDE.md` (add/remove steps to taste)
- Note frontmatter fields
- `synthesized/` and `cross-project/` subcategories (`patterns/decisions/gotchas/`
  is just one partition)
- The sync tool (swap rsync/robocopy for whatever you prefer)

After any change to agent behavior, **update `AGENT-GUIDE.md` and bump its
`updated:` frontmatter** — that file is the contract Claude Code re-reads on
every session.

---

## Why Obsidian + Claude Code

**Obsidian** provides:
- `[[wiki-link]]` navigation (the backbone of cross-project note interlinking)
- Frontmatter support (structured metadata: `tags`, `sources`, `updated`)
- Local plain markdown (no lock-in, git-friendly)

**Claude Code** provides:
- Automatic `CLAUDE.md` loading (behavior contract picked up on every session)
- File read/write + codebase search (agent scans `mirror/` for cross-project links)
- Plan mode / todo tracking (agent can diff first, get user confirmation, then act)

Neither is strictly required — the methodology works with other tools — but this
is the smoothest combination right now.

---

## License

[MIT](LICENSE)
