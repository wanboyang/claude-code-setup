#!/usr/bin/env bash
# =============================================================================
# Claude Code 环境复现脚本 (macOS / Linux)
# 用法: bash setup.sh
# =============================================================================
set -euo pipefail

echo "========================================"
echo " Claude Code 环境自动配置"
echo "========================================"

# ---- 1. 安装 Claude Code CLI ----
echo ""
echo "[1/7] 安装 Claude Code CLI..."
if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | bash
  echo "  ✓ Claude Code 安装完成"
else
  echo "  ✓ Claude Code 已安装: $(claude --version 2>&1 | head -1)"
fi

# ---- 2. DeepSeek API 配置 ----
echo ""
echo "[2/7] 配置 API 后端 (DeepSeek V4)..."
if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
  export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
  export ANTHROPIC_AUTH_TOKEN="$DEEPSEEK_API_KEY"
  export ANTHROPIC_MODEL=deepseek-v4-pro[1m]
  export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
  export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]
  export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
  export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
  export CLAUDE_CODE_EFFORT_LEVEL=max
  echo "  ✓ DeepSeek V4 已配置 (通过 DEEPSEEK_API_KEY 环境变量)"
  echo ""
  echo "  如需永久生效，请将以下内容追加到 ~/.bashrc 或 ~/.zshrc:"
  echo "  export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic"
  echo "  export ANTHROPIC_AUTH_TOKEN=<你的 DeepSeek API Key>"
  echo "  export ANTHROPIC_MODEL=deepseek-v4-pro[1m]"
  echo "  export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]"
  echo "  export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]"
  echo "  export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash"
  echo "  export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash"
  echo "  export CLAUDE_CODE_EFFORT_LEVEL=max"
else
  echo "  ⚠ 未检测到 DEEPSEEK_API_KEY 环境变量"
  echo "  请在 DeepSeek Platform (https://platform.deepseek.com/) 获取 API Key"
  echo "  然后设置环境变量:"
  echo ""
  echo "  export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic"
  echo "  export ANTHROPIC_AUTH_TOKEN=<你的 DeepSeek API Key>"
  echo "  export ANTHROPIC_MODEL=deepseek-v4-pro[1m]"
  echo "  export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]"
  echo "  export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]"
  echo "  export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash"
  echo "  export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash"
  echo "  export CLAUDE_CODE_EFFORT_LEVEL=max"
  echo ""
  echo "  或重新运行: DEEPSEEK_API_KEY=sk-xxx bash setup.sh"
fi

# ---- 3. 检查前置依赖 ----
echo ""
echo "[3/7] 检查前置依赖..."

# Node.js (chrome-devtools MCP, office-mcp 需要)
if ! command -v node &>/dev/null; then
  echo "  ⚠ Node.js 未安装，请手动安装: https://nodejs.org/"
  echo "    macOS: brew install node"
  echo "    Linux: curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && apt-get install -y nodejs"
else
  echo "  ✓ Node.js: $(node --version)"
fi

# uv/uvx (arxiv-latex-mcp, markitdown 需要)
if ! command -v uvx &>/dev/null; then
  echo "  ⚠ uv 未安装，正在安装..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  echo "  ✓ uv 安装完成"
else
  echo "  ✓ uvx 可用"
fi

# Python (markitdown 需要)
PYTHON_CMD=""
if command -v python3 &>/dev/null; then
  PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
  PYTHON_CMD="python"
fi

if [ -z "$PYTHON_CMD" ]; then
  echo "  ⚠ Python 未安装，请手动安装: https://www.python.org/"
else
  PYTHON_VERSION=$("$PYTHON_CMD" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || echo "0.0")
  PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
  PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)
  if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 9 ] 2>/dev/null; then
    echo "  ✓ Python $PYTHON_VERSION ($PYTHON_CMD)"
  else
    echo "  ⚠ Python $PYTHON_VERSION < 3.9，请升级: https://www.python.org/"
  fi
fi

# ---- 3. 安装插件市场 ----
echo ""
echo "[4/7] 安装官方插件市场..."
claude plugins marketplace add anthropics/claude-plugins-official 2>/dev/null || true
echo "  ✓ 官方插件市场已添加"

# ---- 4. 安装独立 Skills (来自 GitHub) ----
echo ""
echo "[5/7] 安装独立 Skills..."

# academic-search (学术搜索引擎)
claude plugins install ustc-ai4science/academic-search 2>/dev/null || \
  echo "  提示: 手动安装 academic-search: claude plugins install ustc-ai4science/academic-search"

# humanizer (去AI味)
claude plugins install blader/humanizer 2>/dev/null || \
  echo "  提示: 手动安装 humanizer: claude plugins install blader/humanizer"

# academic-plotting (学术图表)
claude plugins install zechenzhangAGI/AI-research-SKILLs/academic-plotting 2>/dev/null || \
  echo "  提示: 手动安装 academic-plotting: claude plugins install zechenzhangAGI/AI-research-SKILLs/academic-plotting"

# ---- WoS 研究工具链 (Web of Science) ----
echo "  安装 WoS 研究工具链..."
WOS_SKILLS=(
  "wanboyang/wos-search-skill"
  "wanboyang/wos-paper-detail-skill"
  "wanboyang/wos-navigate-pages-skill"
  "wanboyang/wos-parse-results-skill"
  "wanboyang/wos-download-skill"
  "wanboyang/wos-export-skill"
  "wanboyang/wos-reference"
)
for skill in "${WOS_SKILLS[@]}"; do
  claude plugins install "$skill" 2>/dev/null || \
    echo "  提示: 手动安装 $skill"
done

# literature-survey (文献综述)
claude plugins install wanboyang/literature-survey-skill 2>/dev/null || \
  echo "  提示: 手动安装 literature-survey"

# paper-harvest (批量论文下载)
claude plugins install wanboyang/paper-harvest-skill 2>/dev/null || \
  echo "  提示: 手动安装 paper-harvest"

echo "  ✓ 独立 Skills 安装完成"

# ---- 5. 配置 MCP 服务器 ----
echo ""
echo "[6/7] 配置 MCP 服务器..."

# 5a. alphaXiv (学术论文检索)
echo "  配置 alphaxiv..."
claude mcp add --transport http alphaxiv https://api.alphaxiv.org/mcp/v1 2>/dev/null || true
echo "  注意: alphaxiv 首次使用需要浏览器 OAuth 认证"

# 5b. arxiv-latex-mcp (arXiv LaTeX 工具)
echo "  配置 arxiv-latex-mcp..."
claude mcp add arxiv-latex-mcp -- uvx arxiv-latex-mcp 2>/dev/null || true

# 5c. chrome-devtools (浏览器自动化)
echo "  配置 chrome-devtools..."
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest 2>/dev/null || true

# 5d. zotero (文献管理, 需要本地 Zotero 运行)
echo "  配置 zotero..."
claude mcp add --transport http zotero http://127.0.0.1:23120/mcp 2>/dev/null || true
echo "  注意: zotero MCP 需要 Zotero 客户端运行 + zotero-mcp 插件"

# 5e. markitdown (格式转换)
echo "  配置 markitdown..."
pip install markitdown-mcp 2>/dev/null || pip3 install markitdown-mcp 2>/dev/null || true
claude mcp add markitdown -- python -m markitdown_mcp 2>/dev/null || \
  claude mcp add markitdown -- python3 -m markitdown_mcp 2>/dev/null || true

# 5f. office-mcp (Office 文件操作)
echo "  配置 office-mcp..."
OFFICE_MCP_DIR="${HOME}/claude-office-skills/mcp-servers/office-mcp"
if [ ! -d "$OFFICE_MCP_DIR" ]; then
  echo "  正在克隆 office-mcp..."
  git clone https://github.com/anthropics/claude-code.git /tmp/claude-code 2>/dev/null || true
  # 如果 office-mcp 有独立仓库，替换为实际 URL
  echo "  ⚠ office-mcp 需要手动配置，请参考: https://github.com/anthropics/claude-plugins-official"
fi
claude mcp add office-mcp -- node "${HOME}/claude-office-skills/mcp-servers/office-mcp/dist/index.js" 2>/dev/null || true

echo "  ✓ MCP 服务器配置完成"

# ---- 6. 权限配置 ----
echo ""
echo "[7/7] 配置权限..."
# 常用 MCP 工具自动允许
claude config add allow "mcp__alphaxiv__*" 2>/dev/null || true
claude config add allow "mcp__zotero__*" 2>/dev/null || true
claude config add allow "mcp__arxiv-latex-mcp__*" 2>/dev/null || true
claude config add allow "mcp__markitdown__*" 2>/dev/null || true
claude config add allow "mcp__office-mcp__*" 2>/dev/null || true
claude config add allow "mcp__chrome-devtools__*" 2>/dev/null || true
claude config add allow "WebSearch" 2>/dev/null || true
claude config set skipDangerousModePermissionPrompt true 2>/dev/null || true
echo "  ✓ 权限配置完成"

echo ""
echo "========================================"
echo " 安装完成!"
echo "========================================"
echo ""
echo "手动检查清单:"
echo "  □ 在 DeepSeek Platform 获取 API Key: https://platform.deepseek.com/"
echo "  □ 设置 DEEPSEEK_API_KEY 环境变量，或手动设置 ANTHROPIC_* 变量"
echo "  □ 确保 Node.js >= 18 已安装"
echo "  □ 确保 Python >= 3.9 已安装"
echo "  □ 确保 uv/uvx 已安装并可用"
echo "  □ alphaxiv 首次使用会自动弹出浏览器进行 OAuth 认证"
echo "  □ Zotero MCP 需要: Zotero 客户端 + zotero-mcp 插件"
echo "  □ 运行 'claude mcp list' 检查所有 MCP 服务器状态"
echo ""
