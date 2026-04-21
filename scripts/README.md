# scripts/

同步脚本：把各项目 `docs/` 单向强制同步到 `mirror/<project>/`。

## 文件

| 文件 | 说明 |
|------|------|
| `vault-config.example.yml` | 配置模板。**不编辑它**——拷贝到 `vault-config.yml` 再编辑 |
| `vault-config.yml` | 你的本地配置（gitignored，不会 push 到 repo） |
| `sync.sh` | Unix/macOS 同步脚本，需要 `rsync` |
| `sync.ps1` | Windows PowerShell 同步脚本，用内置的 `robocopy` |

## 首次使用

```bash
cp scripts/vault-config.example.yml scripts/vault-config.yml
# 编辑 scripts/vault-config.yml，把示例项目换成你自己的
```

`vault-config.yml` 格式：

```yaml
projects:
  - name: my-backend                         # 会出现在 mirror/my-backend/
    source: /home/me/code/my-backend/docs    # 绝对路径

  - name: my-frontend
    source: /home/me/code/my-frontend/docs
```

## 跑同步

```bash
# Unix / macOS
./scripts/sync.sh

# Windows PowerShell
.\scripts\sync.ps1
```

输出示例：

```
→ my-backend: /home/me/code/my-backend/docs → mirror/my-backend/
→ my-frontend: /home/me/code/my-frontend/docs → mirror/my-frontend/

Synced 2 project(s). Now tell Claude Code:
  "mirror/<project>/ 同步完了，开始整理"
```

## 同步语义

- **单向**：源 → mirror，不反向
- **强制覆盖**：`rsync --delete` / `robocopy /MIR`，mirror 里的手动修改会被**覆盖掉**（包括删除）
- **幂等**：跑多次效果一样
- **按项目独立**：每个项目的同步互不影响，一个源目录不存在只会 warn 跳过

## 添加项目

在 `vault-config.yml` 加一条：

```yaml
  - name: my-new-project
    source: /path/to/my-new-project/docs
```

再跑一次同步。

## 移除项目

**两步**：

1. 从 `vault-config.yml` 删掉对应条目
2. 手动删除 `mirror/<name>/` 目录

同步脚本**不会自动删**已从配置里移除的项目（这是刻意的——避免误删）。

## 故障排查

**Windows 上 `robocopy` 报找不到源**：
确认 `vault-config.yml` 里的路径用**正斜杠** `C:/Users/...` 或**双反斜杠** `C:\\Users\\...`（单反斜杠 YAML 会吃掉）。

**Unix 上 `rsync: command not found`**：
- macOS: `brew install rsync`
- Ubuntu/Debian: `apt install rsync`

**同步完 mirror/ 里没东西**：
可能是源路径指向了项目根目录而不是 `docs/`——确认 `source:` 指向的就是你想镜像的那层。

## 自定义

脚本里的 YAML 解析是最简实现，**不支持**嵌套字段、多行字符串、复杂类型。如果你需要更多配置字段（比如 per-project 的 include/exclude 规则），建议引入 `yq` 或替换成 Python 脚本。
