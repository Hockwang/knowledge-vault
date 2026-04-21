# mirror/

**[READ-ONLY]** Mirror area for each project's `docs/`.

## Hard constraints

- This directory is **one-way force-overwritten** by `scripts/sync.sh` / `scripts/sync.ps1`
- Any manual edits here will be **lost on the next sync**
- The agent must never write files here (see the three hard rules in `AGENT-GUIDE.md`)

## Layout after sync

One subdirectory per project. Internal structure mirrors whatever the source project's `docs/` looks like. Recommended convention:

```
mirror/<your-project>/
├── architecture/     ← system architecture docs
├── concepts/         ← domain concepts / format specs
├── decisions/        ← architecture decision records (ADRs)
├── gotchas/          ← battle scars / pitfalls
└── index.md          ← project docs entry point
```

The agent doesn't enforce this structure — whatever shape your project `docs/` has, that's what gets mirrored in.

## Configuring sync sources

Edit `scripts/vault-config.yml` (copy from `scripts/vault-config.example.yml`):

```yaml
projects:
  - name: my-backend
    source: /home/user/code/my-backend/docs

  - name: my-frontend
    source: /home/user/code/my-frontend/docs
```

Then run `./scripts/sync.sh` (Unix) or `.\scripts\sync.ps1` (Windows). `my-backend/` and `my-frontend/` will appear under this directory.

## Adding / removing projects

- **Add**: add a `- name:` + `source:` entry to `vault-config.yml`, run sync
- **Remove**: remove the entry from `vault-config.yml` **and** manually delete `mirror/<name>/`. The sync script does not auto-remove projects that are no longer in the config.

## Why read-only

Two reasons:

1. **Sync is a forced overwrite**. `mirror/` exists to be "the authoritative copy of each project's docs", not a place for you to edit. If you actually want to change a doc, change it in the source project.
2. **Agent's working contract**. The agent reads raw material from `mirror/` and writes output to `notes/`. This separation of duties keeps the agent's output traceable and auditable — every `notes/` note cites its source via `[[mirror/...]]` wiki-links.
