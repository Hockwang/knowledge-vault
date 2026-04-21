# mirror/

**【只读】** 各项目 `docs/` 的镜像区。

## 关键约束

- 本目录由 `scripts/sync.sh` / `scripts/sync.ps1` **单向强制覆盖**
- 任何手动修改会在下次同步时**全部丢失**
- agent 绝不能在这里写文件（见 `AGENT-GUIDE.md` 三条硬规则）

## 同步后的结构

每个项目一个子目录，结构由项目自己的 `docs/` 决定。推荐约定：

```
mirror/<your-project>/
├── architecture/     ← 系统架构文档
├── concepts/         ← 领域概念 / 格式规范
├── decisions/        ← ADR 架构决策
├── gotchas/          ← 踩坑记录
└── index.md          ← 项目文档入口
```

但 agent 不强制这个结构——你的项目 `docs/` 长什么样，镜像进来就长什么样。

## 配置同步源

编辑 `scripts/vault-config.yml`（从 `scripts/vault-config.example.yml` 拷贝）：

```yaml
projects:
  - name: my-backend
    source: /home/user/code/my-backend/docs

  - name: my-frontend
    source: /home/user/code/my-frontend/docs
```

然后跑 `./scripts/sync.sh`（Unix）或 `.\scripts\sync.ps1`（Windows），本目录下会出现 `my-backend/` 和 `my-frontend/`。

## 添加/移除项目

- **添加**：在 `vault-config.yml` 加一条 `- name:` + `source:`，跑同步
- **移除**：从 `vault-config.yml` 删掉对应条目 **并**手动删 `mirror/<name>/`（同步脚本不会自动删已移除的项目）

## 为什么是只读

两个理由：

1. **同步是强制覆盖**。mirror 存在的意义是"项目 docs 的权威副本"，不是让你在这里编辑。真正要改文档去源项目改。
2. **agent 的工作契约**。agent 在 `mirror/` 里找原料，在 `notes/` 里写产出。这个职责分离让 agent 的输出可追溯、可审计——每个 `notes/` 笔记都用 `[[mirror/...]]` 双链指回原料。
