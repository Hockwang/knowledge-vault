# Knowledge Vault — AI-agent-operated cross-project knowledge system

> **TL;DR (English)**: An Obsidian vault template designed to be operated by
> Claude Code as an agent. Mirrors docs from multiple code projects into a
> read-only area, then distills cross-project patterns into a writeable notes
> area. Ships with sync scripts and a behavior contract (`AGENT-GUIDE.md`) for
> the agent. Methodology-only — no real project docs are included; bring your own.

---

## 为什么要这个 vault

每个代码项目都有自己的 `docs/`，但跨项目的模式没有家：

- 不同项目**重复踩过的同一类坑**（边界格式没转换、基准态被污染…）
- 不同项目**独立得出的同一个工程共识**（"跨 roundtrip 用 name 不用 UUID"）
- 一个项目解决了、另一个还没遇到的**演进对照**

这些"跨项目洞察"的价值远大于单项目 docs，但没人会手动去维护它们——除非有个稳定的地方放、有人专门负责提炼。

**这个 vault 给跨项目洞察一个家，并让 AI agent 负责提炼，而不是你人肉搬运。**

---

## 工作原理

```
┌────────────────────┐  sync (单向强制覆盖)  ┌─────────────────────┐
│ your project/docs/ │ ─────────────────────→ │ vault/mirror/<name>/│  ← 只读
└────────────────────┘                        └─────────────────────┘
                                                        │
                                                        │  agent 读取 + 提炼
                                                        ↓
                                              ┌─────────────────────┐
                                              │ vault/notes/        │  ← agent 唯一可写
                                              │  ├── synthesized/   │    单项目提炼
                                              │  └── cross-project/ │    跨项目模式
                                              └─────────────────────┘
```

三个组成部分：

- **`mirror/`** — 只读镜像区。每个子目录是一个项目 `docs/` 的快照。同步脚本单向强制覆盖，**任何手动修改都会在下次同步时丢失**。
- **`notes/`** — agent 唯一可写区。存放单项目提炼（`synthesized/`）+ 跨项目抽象模式（`cross-project/`）。
- **`CLAUDE.md` + `AGENT-GUIDE.md`** — 给 Claude Code 的行为契约：什么能动、什么不能动、遇到新同步怎么 diff、跨项目模式什么时候抽出来、笔记用什么格式写。

你的角色：跑同步脚本 + 给 agent 发"开始整理"指令 + 审阅产出。
Agent 的角色：diff、提炼、连接、抽象、写笔记。

---

## 价值主张

**单项目 docs 是必要的但不够。**

举个本模板作者实际遇到的例子：两个独立开发的项目（一个是 3D 动画编辑器，一个是 AI 打关节研究）各自在自己的 docs 里得出"跨 roundtrip 标识用 name 不用 UUID"的决策——但各自只是在单项目 ADR 里记了一笔。

直到 agent 在 `cross-project/decisions/` 下把这两笔连起来，才浮现出"这是一个**两个独立项目共同验证过的强工程信号**"——远比任何一方单独记录更有说服力。

**认识到这是模式，是 agent 的主要价值。** 没有这一步，你完全可以不用 Obsidian。

---

## 快速开始

### 前提

- Obsidian（任意版本，纯用来渲染和双链导航）
- Claude Code CLI（给 `mirror/` 做提炼的 agent——见 https://claude.com/claude-code）
- `rsync`（Unix/macOS）或 `robocopy`（Windows 自带）

### 5 步启动

```bash
# 1. Clone
git clone <this-repo-url> knowledge-vault
cd knowledge-vault

# 2. 填同步配置（告诉脚本你要镜像哪些项目的 docs/）
cp scripts/vault-config.example.yml scripts/vault-config.yml
# 编辑 scripts/vault-config.yml，填你自己的项目路径

# 3. 跑第一次同步
./scripts/sync.sh           # Unix/macOS
# 或
.\scripts\sync.ps1          # Windows PowerShell

# 4. 用 Obsidian 打开 vault 根目录（注意是 knowledge-vault/，不是 notes/！）
#    见 AGENT-GUIDE.md 里的 "Vault 根目录约定" 一节

# 5. 在 vault 根目录启动 Claude Code，告诉它：
#    "mirror/<your-project>/ 同步完了，开始整理"
#    它会按 AGENT-GUIDE.md 的 5 步流程走：diff → 决定动作 → 跨项目连接 → 更新索引 → 汇报
```

---

## 仓库结构

```
knowledge-vault/
├── README.md                   ← 本文件
├── LICENSE                     ← MIT
├── CLAUDE.md                   ← agent 入口（Claude Code 启动时自动加载）
├── AGENT-GUIDE.md              ← 完整 agent 工作手册
├── .gitignore
├── .obsidian/                  ← 最小 Obsidian 配置
├── mirror/                     ← 【只读】项目 docs/ 镜像区，sync 脚本覆盖
│   └── <your-project>/         ← sync 后出现
├── notes/                      ← 【可写】agent 产出区
│   ├── index.md                ← 总索引
│   ├── log.md                  ← 工作日志
│   ├── synthesized/            ← 单项目提炼
│   └── cross-project/          ← 跨项目模式（最高价值）
│       ├── patterns/
│       ├── decisions/
│       └── gotchas/
└── scripts/
    ├── sync.sh / sync.ps1      ← 同步脚本
    ├── vault-config.example.yml
    └── README.md               ← 脚本使用说明
```

---

## 定制

核心不变量：

- `mirror/` 只读、`notes/` 唯一可写、agent 的工作是**提炼**不是搬运
- 跨 roundtrip / 跨系统 / 跨项目的引用用 name 不用 UUID（便于人类可读 + 跨序列化稳定）
- 冲突或歧义时 agent 必须停下来问用户，不要武断合并

除此之外都可以按自己的需求改：

- `AGENT-GUIDE.md` 里的 5 步工作流（你可以加/减步骤）
- 笔记模板的 frontmatter 字段
- `synthesized/` 和 `cross-project/` 的子分类（`patterns/decisions/gotchas/` 只是一个起点）
- 同步脚本（你可以用别的工具代替 rsync/robocopy）

改完如果对 agent 的行为有新要求，**更新 `AGENT-GUIDE.md` 并标 `updated: YYYY-MM-DD`**——这是 agent 下次启动时会重新读的契约。

---

## 为什么是 Obsidian + Claude Code

**Obsidian** 提供：
- 双链 `[[...]]` 导航（跨项目笔记互链的核心）
- frontmatter 支持（agent 用 `tags`/`sources`/`updated` 结构化元数据）
- 本地纯 markdown（不锁死在某个工具里，git 友好）

**Claude Code** 提供：
- `CLAUDE.md` 自动加载机制（行为契约在新 session 自动生效）
- 文件读写 + 代码库搜索（agent 扫描 `mirror/` 找跨项目关联）
- Plan 模式 / Todo 管理（agent 整理时可以 diff-first，用户确认后再动手）

两者都不是"必须"——方法论本身可以用其它工具实现——但这是目前最顺手的组合。

---

## License

[MIT](LICENSE)
