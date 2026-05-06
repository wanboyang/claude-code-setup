# Claude Code 环境复现指南

## 一键安装

### macOS / Linux

```bash
git clone https://github.com/<your-username>/claude-code-setup.git
cd claude-code-setup
bash setup.sh
```

### Windows

```powershell
git clone https://github.com/<your-username>/claude-code-setup.git
cd claude-code-setup
powershell -ExecutionPolicy Bypass -File setup.ps1
```

## 安装内容

### MCP 服务器 (6个)

| MCP | 用途 | 依赖 |
|-----|------|------|
| **alphaxiv** | 学术论文检索 | 无 (HTTP, 需 OAuth) |
| **arxiv-latex-mcp** | arXiv LaTeX 工具 | uvx |
| **chrome-devtools** | 浏览器自动化 | Node.js + npx |
| **zotero** | 文献管理 | Zotero 客户端 + zotero-mcp 插件 |
| **markitdown** | 文件格式转换 | Python + markitdown-mcp |
| **office-mcp** | Office 文件操作 | Node.js + office-mcp |

### Skills (来自官方市场)

安装官方插件市场后，Claude Code 会在用户首次调用 `/skill-name` 时自动安装对应 skill。无需手动安装所有 skills。

### 独立 Skills (来自 GitHub)

| Skill | 来源 |
|-------|------|
| academic-search | github.com/ustc-ai4science/academic-search |
| humanizer | github.com/blader/humanizer |
| academic-plotting | github.com/zechenzhangAGI/AI-research-SKILLs |

## 前置依赖

| 依赖 | 用途 | 安装 |
|------|------|------|
| **Node.js >= 18** | chrome-devtools MCP, office-mcp | `brew install node` / `winget install OpenJS.NodeJS.LTS` |
| **Python >= 3.9** | markitdown MCP | `brew install python` / `winget install Python.Python.3.12` |
| **uv / uvx** | arxiv-latex-mcp | `curl -LsSf https://astral.sh/uv/install.sh | sh` |

## 需要手动配置的部分

### 1. Zotero MCP (文献管理)

需要 Zotero 客户端运行并安装 zotero-mcp 插件:
- 安装 Zotero: https://www.zotero.org/
- 安装 zotero-mcp 插件: https://github.com/cookjohn/zotero-mcp/releases
- 在 Zotero 中启用 MCP 服务 (端口 23120)

### 2. alphaXiv OAuth 认证

首次使用 alphaXiv 时，Claude Code 会自动打开浏览器进行 OAuth 认证。需要登录 alphaXiv 账号。

### 3. office-mcp (可选)

如果你的环境已安装 office-mcp，脚本会自动配置。否则从官方市场安装：
```bash
claude plugins install office-mcp
```

## 自定义 Skills (来自 GitHub)

| Skill | 来源 |
|-------|------|
| wos-search | github.com/wanboyang/wos-search-skill |
| wos-paper-detail | github.com/wanboyang/wos-paper-detail-skill |
| wos-navigate-pages | github.com/wanboyang/wos-navigate-pages-skill |
| wos-parse-results | github.com/wanboyang/wos-parse-results-skill |
| wos-download | github.com/wanboyang/wos-download-skill |
| wos-export | github.com/wanboyang/wos-export-skill |
| literature-survey | github.com/wanboyang/literature-survey-skill |
| paper-harvest | github.com/wanboyang/paper-harvest-skill |
| wos-reference | github.com/wanboyang/wos-reference |
| wos-researcher (agent) | github.com/wanboyang/wos-researcher-agent |

## 验证安装

```bash
# 检查 MCP 服务器状态
claude mcp list

# 检查已安装的 plugins
claude plugins list
```

## 注意事项

- **跨平台兼容**: MCP 配置使用 `claude mcp add` 命令，会自动适配 Windows/macOS/Linux 路径差异
- **权限**: 脚本配置了 MCP 工具的自动允许权限。如果需要更严格的权限策略，请手动修改 `~/.claude/settings.json`
- **首次运行**: Claude Code 首次启动时会自动同步插件市场，skills 会在首次使用时自动安装
