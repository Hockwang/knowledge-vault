**English** | [中文](CLAUDE.md)

# Vault agent entry point

You are in **knowledge-vault** — an Obsidian vault whose purpose is to aggregate
knowledge from multiple code projects and distill cross-project insights.

## Required reading

**[AGENT-GUIDE.en.md](AGENT-GUIDE.en.md)** — your full operating manual. Covers:
- Your role (knowledge-distillation layer, not document manager)
- Directory layout (`mirror/` read-only + `notes/` workspace)
- The 5-step workflow after receiving a sync
- Must / must-not rules
- Note templates

## Vault structure at a glance

```
knowledge-vault/
├── README.md / README.zh-CN.md         ← Repo landing page (EN primary, CN variant)
├── AGENT-GUIDE.md / AGENT-GUIDE.en.md  ← Full operating manual (CN primary, EN variant)
├── CLAUDE.md / CLAUDE.en.md            ← This file (CN primary, EN variant)
├── mirror/                   ← [READ-ONLY] mirror of each project's docs/
│   ├── <project-a>/          ← example: MotionForge (animation editor)
│   └── <project-b>/          ← example: autorigging (AI rigging research)
├── notes/                    ← [WRITEABLE] your output area
│   ├── index.md
│   ├── log.md
│   ├── synthesized/          ← per-project distillations
│   └── cross-project/        ← cross-project patterns (highest value)
│       ├── patterns/
│       ├── gotchas/
│       └── decisions/
└── scripts/                  ← sync scripts (the user runs them, not you)
    ├── sync.sh / sync.ps1
    └── vault-config.yml      ← user's local config (gitignored)
```

## Typical trigger phrases

The user will invoke you like this:

- "mirror/\<project\>/ is synced, start processing" → run the 5-step workflow in AGENT-GUIDE
- "how's the vault health" → run the self-check (see the "Health self-check" section at the bottom of AGENT-GUIDE)
- "find the commonality between X and Y" → cross-project pattern extraction

(Chinese equivalents: "mirror/\<project\>/ 同步完了，开始整理" / "vault 健康度怎样" /
"找一下 X 和 Y 之间的共性" — the user may speak either language.)

## Three hard rules (break any → you are wrong)

1. ❌ **Do not modify anything under `mirror/`** (the next sync overwrites it — any edit is wasted)
2. ❌ **Do not copy `mirror/` content verbatim into `notes/`** (your job is to distill, not to relay)
3. ❌ **Stop and ask the user on conflicts or ambiguity** (don't merge unilaterally)

Full ruleset: [AGENT-GUIDE.en.md](AGENT-GUIDE.en.md).
