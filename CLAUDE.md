[English](CLAUDE.en.md) | **中文**

# Vault Agent 入口

你现在在 **knowledge-vault**，这是一个 Obsidian vault，作用是聚合多个代码项目的知识库并提炼跨项目洞察。

## 必读

**[AGENT-GUIDE.md](AGENT-GUIDE.md)** — 你的完整工作手册，包含：
- 你的定位（知识提炼层，不是文档管理员）
- 目录结构（`mirror/` 只读镜像 + `notes/` 工作区）
- 收到同步后的 5 步工作流程
- 必须/禁止的规则清单
- 笔记模板

## 当前 vault 状态速览

```
knowledge-vault/
├── README.md / README.zh-CN.md         ← 仓库主页（英主中变）
├── AGENT-GUIDE.md / AGENT-GUIDE.en.md  ← 完整工作手册（中主英变）
├── CLAUDE.md / CLAUDE.en.md            ← 本文件（中主英变）
├── mirror/                   ← 【只读】各项目 docs/ 的镜像
│   ├── <project-a>/          ← 示例：MotionForge（动画编辑器）
│   └── <project-b>/          ← 示例：autorigging（AI 打关节研究）
├── notes/                    ← 【可写】你的产出区
│   ├── index.md
│   ├── log.md
│   ├── synthesized/          ← 单项目提炼
│   └── cross-project/        ← 跨项目模式（最高价值）
│       ├── patterns/
│       ├── gotchas/
│       └── decisions/
└── scripts/                  ← 同步脚本（用户跑，不是你跑）
    ├── sync.sh / sync.ps1
    └── vault-config.yml      ← 用户本地配置（gitignored）
```

## 典型触发命令

用户会这样给你任务：

- "mirror/<project>/ 同步完了，开始整理" → 按 AGENT-GUIDE.md 的 5 步流程执行
- "vault 健康度怎样" → 做自检（见 AGENT-GUIDE.md 末尾"健康度自检"段落）
- "找一下 X 和 Y 之间的共性" → 跨项目模式提取

## 三条硬规则（违反必错）

1. ❌ **不改 `mirror/` 下任何文件**（下次同步会覆盖，改了也白改）
2. ❌ **不直接复制 `mirror/` 原文到 `notes/`**（你的工作是提炼，不是搬运）
3. ❌ **冲突或歧义时停下来问用户**（不要自作主张合并）

完整规则请读 [AGENT-GUIDE.md](AGENT-GUIDE.md)。
