# =============================================================================
# Claude Code 环境复现脚本 (Windows PowerShell)
# 用法: powershell -ExecutionPolicy Bypass -File setup.ps1
# =============================================================================
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Claude Code 环境自动配置 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# ---- 1. 安装 Claude Code CLI ----
Write-Host "`n[1/7] 安装 Claude Code CLI..." -ForegroundColor Yellow
$claudePath = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudePath) {
    Write-Host "  正在安装 Claude Code..."
    irm https://claude.ai/install.ps1 | iex
    Write-Host "  ✓ Claude Code 安装完成" -ForegroundColor Green
} else {
    Write-Host "  ✓ Claude Code 已安装: $($claudePath.Source)" -ForegroundColor Green
}

# ---- 2. DeepSeek API 配置 ----
Write-Host "`n[2/7] 配置 API 后端 (DeepSeek V4)..." -ForegroundColor Yellow
$apiKey = $env:DEEPSEEK_API_KEY
if ($apiKey) {
    $env:ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $apiKey
    $env:ANTHROPIC_MODEL = "deepseek-v4-pro[1m]"
    $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro[1m]"
    $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro[1m]"
    $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash"
    $env:CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-v4-flash"
    $env:CLAUDE_CODE_EFFORT_LEVEL = "max"
    Write-Host "  ✓ DeepSeek V4 已配置 (通过 DEEPSEEK_API_KEY 环境变量)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需永久生效，请运行以下命令 (管理员权限):"
    Write-Host '  setx ANTHROPIC_BASE_URL "https://api.deepseek.com/anthropic"'
    Write-Host '  setx ANTHROPIC_MODEL "deepseek-v4-pro[1m]"'
    Write-Host '  setx ANTHROPIC_DEFAULT_OPUS_MODEL "deepseek-v4-pro[1m]"'
    Write-Host '  setx ANTHROPIC_DEFAULT_SONNET_MODEL "deepseek-v4-pro[1m]"'
    Write-Host '  setx ANTHROPIC_DEFAULT_HAIKU_MODEL "deepseek-v4-flash"'
    Write-Host '  setx CLAUDE_CODE_SUBAGENT_MODEL "deepseek-v4-flash"'
    Write-Host '  setx CLAUDE_CODE_EFFORT_LEVEL "max"'
    Write-Host '  setx ANTHROPIC_AUTH_TOKEN "<你的 DeepSeek API Key>"'
} else {
    Write-Host "  ⚠ 未检测到 `$env:DEEPSEEK_API_KEY` 环境变量" -ForegroundColor DarkYellow
    Write-Host "  请在 DeepSeek Platform (https://platform.deepseek.com/) 获取 API Key"
    Write-Host "  然后设置环境变量:"
    Write-Host ""
    Write-Host '  `$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"'
    Write-Host '  `$env:ANTHROPIC_AUTH_TOKEN="<你的 DeepSeek API Key>"'
    Write-Host '  `$env:ANTHROPIC_MODEL="deepseek-v4-pro[1m]"'
    Write-Host '  `$env:ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"'
    Write-Host '  `$env:ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"'
    Write-Host '  `$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"'
    Write-Host '  `$env:CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"'
    Write-Host '  `$env:CLAUDE_CODE_EFFORT_LEVEL="max"'
    Write-Host ""
    Write-Host "  或重新运行: `$env:DEEPSEEK_API_KEY='sk-xxx'; .\setup.ps1" -ForegroundColor DarkYellow
}

# ---- 3. 检查前置依赖 ----
Write-Host "`n[3/7] 检查前置依赖..." -ForegroundColor Yellow

# Node.js (chrome-devtools MCP, office-mcp)
$nodePath = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodePath) {
    Write-Host "  ⚠ Node.js 未安装，请手动安装: https://nodejs.org/" -ForegroundColor Red
    Write-Host "    推荐使用 winget: winget install OpenJS.NodeJS.LTS"
} else {
    Write-Host "  ✓ Node.js: $(node --version)" -ForegroundColor Green
}

# Python & pip
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host "  ⚠ Python 未安装，请手动安装: https://www.python.org/" -ForegroundColor Red
} else {
    Write-Host "  ✓ Python: $(python --version)" -ForegroundColor Green
}

# uv/uvx
$uvxPath = Get-Command uvx -ErrorAction SilentlyContinue
if (-not $uvxPath) {
    Write-Host "  ⚠ uv 未安装，正在安装..."
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    Write-Host "  ✓ uv 安装完成" -ForegroundColor Green
} else {
    Write-Host "  ✓ uvx 可用" -ForegroundColor Green
}

# ---- 4. 安装插件市场 ----
Write-Host "`n[4/7] 安装官方插件市场..." -ForegroundColor Yellow
claude plugins marketplace add anthropics/claude-plugins-official 2>$null
Write-Host "  ✓ 官方插件市场已添加" -ForegroundColor Green

# ---- 5. 安装独立 Skills ----
Write-Host "`n[5/7] 安装独立 Skills..." -ForegroundColor Yellow

$skills = @(
    "ustc-ai4science/academic-search",
    "blader/humanizer",
    "zechenzhangAGI/AI-research-SKILLs/academic-plotting",
    "wanboyang/wos-search-skill",
    "wanboyang/wos-paper-detail-skill",
    "wanboyang/wos-navigate-pages-skill",
    "wanboyang/wos-parse-results-skill",
    "wanboyang/wos-download-skill",
    "wanboyang/wos-export-skill",
    "wanboyang/wos-reference",
    "wanboyang/literature-survey-skill",
    "wanboyang/paper-harvest-skill"
)

foreach ($skill in $skills) {
    Write-Host "  安装 $skill ..."
    claude plugins install $skill 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "    ⚠ 请手动安装: claude plugins install $skill" -ForegroundColor DarkYellow
    }
}
Write-Host "  ✓ 独立 Skills 安装完成" -ForegroundColor Green

# ---- 6. 配置 MCP 服务器 ----
Write-Host "`n[6/7] 配置 MCP 服务器..." -ForegroundColor Yellow

# 5a. alphaXiv
Write-Host "  配置 alphaxiv..."
claude mcp add --transport http alphaxiv https://api.alphaxiv.org/mcp/v1 2>$null
Write-Host "  注意: alphaxiv 首次使用需要浏览器 OAuth 认证" -ForegroundColor DarkYellow

# 5b. arxiv-latex-mcp
Write-Host "  配置 arxiv-latex-mcp..."
claude mcp add arxiv-latex-mcp -- uvx arxiv-latex-mcp 2>$null

# 5c. chrome-devtools
Write-Host "  配置 chrome-devtools..."
claude mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest 2>$null

# 5d. zotero (本地服务)
Write-Host "  配置 zotero..."
claude mcp add --transport http zotero http://127.0.0.1:23120/mcp 2>$null
Write-Host "  注意: zotero MCP 需要 Zotero 运行 + zotero-mcp 插件" -ForegroundColor DarkYellow

# 5e. markitdown
Write-Host "  配置 markitdown..."
pip install markitdown-mcp 2>$null
claude mcp add markitdown -- python -m markitdown_mcp 2>$null

# 5f. office-mcp
Write-Host "  配置 office-mcp..."
$officeMcpDir = "$env:USERPROFILE\claude-office-skills\mcp-servers\office-mcp"
if (-not (Test-Path $officeMcpDir)) {
    Write-Host "  ⚠ office-mcp 目录不存在，请手动安装 office-mcp" -ForegroundColor DarkYellow
    Write-Host "    克隆后放置到: $officeMcpDir"
} else {
    claude mcp add office-mcp -- node "$officeMcpDir\dist\index.js" 2>$null
}

Write-Host "  ✓ MCP 服务器配置完成" -ForegroundColor Green

# ---- 7. 权限配置 ----
Write-Host "`n[7/7] 配置权限..." -ForegroundColor Yellow

$permissions = @(
    "mcp__alphaxiv__*",
    "mcp__zotero__*",
    "mcp__arxiv-latex-mcp__*",
    "mcp__markitdown__*",
    "mcp__office-mcp__*",
    "mcp__chrome-devtools__*",
    "WebSearch"
)

foreach ($perm in $permissions) {
    claude config add allow "$perm" 2>$null
}
claude config set skipDangerousModePermissionPrompt true 2>$null

Write-Host "  ✓ 权限配置完成" -ForegroundColor Green

# ---- 完成 ----
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " 安装完成!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "手动检查清单:"
Write-Host "  □ 在 DeepSeek Platform 获取 API Key: https://platform.deepseek.com/"
Write-Host "  □ 设置 DEEPSEEK_API_KEY 环境变量，或手动设置 ANTHROPIC_* 变量"
Write-Host "  □ 确保 Node.js >= 18 已安装"
Write-Host "  □ 确保 Python >= 3.9 + pip 已安装"
Write-Host "  □ 确保 uv/uvx 已安装并可用 (重启终端后生效)"
Write-Host "  □ alphaxiv 首次使用会自动弹出浏览器进行 OAuth 认证"
Write-Host "  □ Zotero MCP 需要: Zotero 客户端 + zotero-mcp 插件"
Write-Host "  □ 运行 'claude mcp list' 检查所有 MCP 服务器状态"
Write-Host ""
