# scripts/

Sync scripts: one-way force-sync each project's `docs/` into `mirror/<project>/`.

## Files

| File | Purpose |
|------|---------|
| `vault-config.example.yml` | Config template. **Don't edit it directly** — copy it to `vault-config.yml` and edit that |
| `vault-config.yml` | Your local config (gitignored, won't be pushed) |
| `sync.sh` | Unix/macOS sync script, needs `rsync` |
| `sync.ps1` | Windows PowerShell sync script, uses built-in `robocopy` |

## First-time setup

```bash
cp scripts/vault-config.example.yml scripts/vault-config.yml
# Edit scripts/vault-config.yml and replace the example projects with your own
```

`vault-config.yml` format:

```yaml
projects:
  - name: my-backend                         # appears as mirror/my-backend/
    source: /home/me/code/my-backend/docs    # absolute path

  - name: my-frontend
    source: /home/me/code/my-frontend/docs
```

## Running sync

```bash
# Unix / macOS
./scripts/sync.sh

# Windows PowerShell
.\scripts\sync.ps1
```

Example output:

```
-> my-backend: /home/me/code/my-backend/docs -> mirror/my-backend/
-> my-frontend: /home/me/code/my-frontend/docs -> mirror/my-frontend/

Synced 2 project(s). Now tell Claude Code to start processing.
```

## Sync semantics

- **One-way**: source → mirror, not the reverse
- **Force-overwrite**: `rsync --delete` / `robocopy /MIR` — manual edits in `mirror/` are **overwritten** (including deleted if the source no longer has them)
- **Idempotent**: running it multiple times gives the same result
- **Per-project isolation**: each project's sync is independent; a missing source directory only warns and skips

## Adding a project

Add a new entry to `vault-config.yml`:

```yaml
  - name: my-new-project
    source: /path/to/my-new-project/docs
```

Then rerun sync.

## Removing a project

**Two steps**:

1. Remove the entry from `vault-config.yml`
2. Manually delete `mirror/<name>/`

The sync script **will not auto-delete** projects that have been removed from the config. This is intentional — to avoid accidental data loss.

## Troubleshooting

**Windows: `robocopy` can't find the source**
Check that paths in `vault-config.yml` use **forward slashes** (`C:/Users/...`) or **double backslashes** (`C:\\Users\\...`). YAML strips single backslashes.

**Unix: `rsync: command not found`**
- macOS: `brew install rsync`
- Ubuntu/Debian: `apt install rsync`

**Sync finishes but `mirror/` is empty**
The `source:` path probably points at the project root instead of `docs/`. Confirm you're pointing at the layer you actually want to mirror.

## Customizing

The YAML parsing in both scripts is minimal — it **does not** support nested fields, multi-line strings, or complex types. If you need more config options (e.g. per-project include/exclude rules), introduce `yq` or replace these with a Python script.
