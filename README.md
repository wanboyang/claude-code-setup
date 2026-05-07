# Claude Code 学术研究环境

[**English**](README_EN.md) | **中文**

一套面向学术研究场景的 Claude Code 环境配置，覆盖**论文搜索 → 批量下载 → 文献综述 → 论文撰写 → 润色发布**的完整研究流水线。

## 项目概览

```
                    ┌──────────────────────────────────┐
                    │         DeepSeek V4 Pro          │
                    │   (Anthropic 兼容 API 后端)       │
                    └──────────────┬───────────────────┘
                                   │
                    ┌──────────────▼───────────────────┐
                    │          Claude Code CLI          │
                    └──────────────┬───────────────────┘
                                   │
          ┌────────────┬───────────┼───────────┬────────────┐
          ▼            ▼           ▼           ▼            ▼
   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
   │   MCP    │ │   MCP    │ │   MCP    │ │   MCP    │ │   MCP    │
   │ alphaxiv │ │ arxiv-   │ │ chrome-  │ │ zotero   │ │ markit-  │
   │          │ │ latex    │ │ devtools │ │          │ │ down     │
   └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   ┌──────────┐   ┌──────────┐   ┌──────────┐
   │ 官方市场  │   │ 独立     │   │ 自定义   │
   │ Skills   │   │ Skills   │   │ Skills   │
   │ (~100个) │   │ (3个)    │   │ (8个)    │
   └──────────┘   └──────────┘   └──────────┘
```

## 研究流水线

本环境将 Claude Code 从"编程助手"扩展为"学术研究工作站"。各组件串联形成完整的研究工作流：

```
academic-search ──→ paper-harvest ──→ literature-survey ──→ ml-paper-writing ──→ humanizer
   搜索+筛选           批量下载           对比+综述大纲           分节撰写            去AI味

                    WoS 工具链 (Web of Science 数据库):
                    wos-search ──→ wos-paper-detail ──→ wos-download
                        │                                    │
                        └──→ wos-navigate-pages              └──→ wos-export → Zotero
```

- **arXiv 路径**: 适合快速获取 AI/CS/ML 领域最新论文
- **WoS 路径**: 适合需要引用数据 (JIF/JCR/SCI分区) 的正式学术场景

> 📖 **实操教程**: [自动化科研教程：以蛋白质亚细胞定位为例](tutorial.md)

---

## 安装

### 前提

| 依赖 | 最低版本 | 用途 |
|------|----------|------|
| Node.js | 18+ | chrome-devtools MCP 运行环境 |
| Python | 3.9+ | markitdown MCP 运行环境 |
| uv / uvx | 最新 | arxiv-latex-mcp 运行环境 |
| Git | 2.x | 克隆仓库与版本控制 |

### 一键安装

**macOS / Linux:**
```bash
git clone https://github.com/wanboyang/claude-code-setup.git
cd claude-code-setup

# 自动配置（含 API Key）
DEEPSEEK_API_KEY=sk-xxx bash setup.sh

# 或不含 API Key（脚本会打印配置指引）
bash setup.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/wanboyang/claude-code-setup.git
cd claude-code-setup

# 自动配置（含 API Key）
$env:DEEPSEEK_API_KEY = "sk-xxx"
powershell -ExecutionPolicy Bypass -File setup.ps1
```

安装脚本执行 7 个步骤：

| 步骤 | 内容 |
|------|------|
| 1 | 安装 Claude Code CLI |
| 2 | 配置 DeepSeek V4 API 后端 |
| 3 | 检查前置依赖 (Node.js, Python, uv) |
| 4 | 添加官方插件市场 |
| 5 | 安装独立 Skills (15个) |
| 6 | 配置 MCP 服务器 (6个) |
| 7 | 配置工具权限 |

---

## API 后端配置

本环境使用 **DeepSeek V4 Pro** 作为模型后端，通过 Anthropic 兼容 API 接入。在 [DeepSeek Platform](https://platform.deepseek.com/) 获取 API Key。

### 环境变量

**macOS / Linux (`~/.bashrc` 或 `~/.zshrc`):**
```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=<你的 DeepSeek API Key>
export ANTHROPIC_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
```

**Windows PowerShell (系统环境变量或 `$profile`):**
```powershell
$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="<你的 DeepSeek API Key>"
$env:ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_EFFORT_LEVEL="max"
```

**Windows 永久生效（管理员权限）:**
```powershell
setx ANTHROPIC_BASE_URL "https://api.deepseek.com/anthropic"
setx ANTHROPIC_MODEL "deepseek-v4-pro[1m]"
setx ANTHROPIC_DEFAULT_OPUS_MODEL "deepseek-v4-pro[1m]"
setx ANTHROPIC_DEFAULT_SONNET_MODEL "deepseek-v4-pro[1m]"
setx ANTHROPIC_DEFAULT_HAIKU_MODEL "deepseek-v4-flash"
setx CLAUDE_CODE_SUBAGENT_MODEL "deepseek-v4-flash"
setx CLAUDE_CODE_EFFORT_LEVEL "max"
setx ANTHROPIC_AUTH_TOKEN "<你的 DeepSeek API Key>"
```

> 如果使用 **Anthropic 官方 API**，只需设置 `ANTHROPIC_AUTH_TOKEN` 为 Anthropic API Key，删除 `ANTHROPIC_BASE_URL` 即可恢复默认。

### 模型说明

| 环境变量 | 值 | 说明 |
|----------|-----|------|
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` | 默认模型 |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `deepseek-v4-pro[1m]` | 对应 Claude Opus 级能力 |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `deepseek-v4-pro[1m]` | 对应 Claude Sonnet 级能力 |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `deepseek-v4-flash` | 对应 Claude Haiku 级能力 |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` | Sub-agent 使用轻量模型 |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` | 推理深度 (low/medium/high/xhigh/max) |

---

## MCP 服务器详解

MCP (Model Context Protocol) 服务器为 Claude Code 提供外部工具能力。本环境配置了 6 个 MCP 服务器：

### 1. alphaXiv — 学术论文检索

| 属性 | 值 |
|------|-----|
| **类型** | HTTP (云端服务) |
| **连接** | `https://api.alphaxiv.org/mcp/v1` |
| **认证** | OAuth (首次自动弹出浏览器) |

**功能**：
- 搜索 arXiv 上 250 万+ 学术论文
- 获取论文的 AI 结构化摘要（比原始摘要更详细，包含方法/贡献/局限）
- 获取论文完整 PDF 文本（`fullText=true`）
- 查看论文引用关系和相关工作

**典型用法**：
```
帮我找 5 篇 RLHF 相关的最新论文
这篇论文 (2305.18290) 的主要贡献是什么？
```

### 2. arxiv-latex-mcp — arXiv LaTeX 源码工具

| 属性 | 值 |
|------|-----|
| **类型** | stdio (本地进程) |
| **命令** | `uvx arxiv-latex-mcp` |

**功能**：
- 获取 arXiv 论文的 LaTeX 源码
- 提取特定章节内容（如 Method, Experiment）
- 在本地编译预览论文

**典型用法**：
```
提取 2305.18290 的 Method 章节
这篇论文的实验部分用了什么数据集？
```

### 3. chrome-devtools — 浏览器自动化

| 属性 | 值 |
|------|-----|
| **类型** | stdio (本地进程) |
| **命令** | `npx -y chrome-devtools-mcp@latest` |

**功能**：
- 控制 Chrome 浏览器实现自动化操作
- 页面导航、表单填写、截图
- JavaScript 注入执行（`evaluate_script`）
- 网络请求拦截和分析
- 配合 Web VPN 下载付费论文 PDF

**典型用法**：
```
打开 Web of Science 搜索 "value co-creation"
从这个出版商页面下载 PDF
```

### 4. Zotero — 文献管理集成

| 属性 | 值 |
|------|-----|
| **类型** | HTTP (本地服务) |
| **连接** | `http://127.0.0.1:23120/mcp` |
| **前提** | Zotero 客户端运行 + zotero-mcp 插件 |

**功能**：
- 将论文元数据直接推送到 Zotero 文献库
- 支持批量导入和去重（通过内容哈希）
- 自动映射 WoS 字段到 Zotero schema
- 保留引用次数、JIF、JCR 分区等 WoS 特有数据

**典型用法**：
```
把当前搜索结果导入 Zotero
导出这 10 篇论文到我的 Zotero 库
```

### 5. markitdown — 文件格式转换

| 属性 | 值 |
|------|-----|
| **类型** | stdio (本地进程) |
| **命令** | `python -m markitdown_mcp` |

**功能**：
- 将各种文件格式转换为 Markdown
- 支持: PDF, DOCX, PPTX, XLSX, HTML, CSV, JSON, XML 等
- 保留文档结构（标题、列表、表格）

**典型用法**：
```
把这个 PDF 转成 Markdown
提取这个 Excel 表格的内容
```

### 6. office-mcp — Office 文件操作

| 属性 | 值 |
|------|-----|
| **类型** | stdio (本地进程) |
| **命令** | `node <path>/office-mcp/dist/index.js` |

**功能**：
- 创建和编辑 Word 文档 (.docx)
- 创建和编辑 PowerPoint 演示文稿 (.pptx)
- 创建和编辑 Excel 电子表格 (.xlsx)
- PDF 操作（合并、拆分、压缩、OCR、表单填写）
- 文件格式互转（MD↔DOCX, PDF↔DOCX, CSV↔XLSX 等）

**典型用法**：
```
根据这个 Markdown 生成 Word 文档
合并这些 PDF 文件
提取 PDF 中的表格数据
```

---

## Skills 详解

Skills 是 Claude Code 的知识模块，每个 Skill 封装了特定领域的操作指南、工作流和工具使用方法。通过 `/skill-name` 调用。

### 学术研究工具链

#### academic-search — 学术论文搜索

| 属性 | 值 |
|------|-----|
| **来源** | `ustc-ai4science/academic-search` |
| **调用** | `/academic-search` |

统一的学术论文搜索入口，整合多个数据源：
- arXiv (物理/CS/数学)
- Semantic Scholar (全学科)
- Crossref / OpenAlex
- Google Scholar, ACM DL, IEEE Xplore
- CNKI (中国知网)

支持按关键词、作者、DOI、年份范围搜索，返回结构化论文列表（含引用数、OA 状态、PDF 可用性）。

#### paper-harvest — 大规模论文搜索与批量下载

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/paper-harvest-skill` |
| **调用** | `/paper-harvest` |

批量下载学术论文的完整解决方案：

- **arXiv 批量下载**: `paper-harvest pipeline "关键词" -n 100` 直接搜索+下载
- **混合来源分流**: 自动区分 arXiv 论文和出版商论文，分别处理
- **Web VPN 下载**: 通过 chrome-devtools MCP 操控浏览器，经机构 VPN 下载付费论文
- **Zotero 集成**: 下载后自动导入 Zotero 文献库

```
工作流:
paper-harvest search "RLHF" -n 50 → papers.json
paper-harvest split papers.json         → arxiv / vpn 分流
paper-harvest download papers-arxiv.json → 并发下载
→ chrome-devtools 逐篇下载 vpn 论文
→ 导入 Zotero
```

#### literature-survey — 文献综述向导

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/literature-survey-skill` |
| **调用** | `/literature-survey` |

将多篇论文进行结构化对比和综合分析，自动生成综述大纲。填补"搜索下载"和"论文撰写"之间的关键空白。

**5 个阶段**：
1. **论文内容提取** — 通过 alphaxiv MCP 批量获取 AI 结构化报告
2. **结构化信息抽取** — 提取 method/dataset/metrics/claims/limitations 等维度的统一 schema
3. **对比矩阵生成** — 自动生成 CSV + Markdown 格式的跨论文对比表
4. **趋势与空白分析** — 识别方法演化路径、研究热点、未被解决的空白点
5. **综述大纲生成** — 输出包含 8 个章节的完整综述框架

**输出目录** (`survey-output/`):
```
extraction/          # 每篇论文的结构化提取 (YAML)
comparison-matrix.csv  # Excel 对比矩阵
comparison-matrix.md    # Markdown 对比矩阵
gap-analysis.md         # 趋势 + 空白分析
survey-outline.md       # 综述大纲（含必引论文）
taxonomy.md             # 分类体系
```

#### academic-plotting — 论文图表生成

| 属性 | 值 |
|------|-----|
| **来源** | `zechenzhangAGI/AI-research-SKILLs` |
| **调用** | `/academic-plotting` |

从研究上下文生成出版级图表：

- **架构图**: 根据论文描述自动生成系统架构图
- **数据图**: 根据实验数据自动选择图表类型并生成 (matplotlib/seaborn)
- **支持格式**: PDF, PNG, SVG (适合 LaTeX 论文嵌入)

#### ml-paper-writing — 机器学习论文撰写

| 属性 | 值 |
|------|-----|
| **来源** | 官方市场 |
| **调用** | `/ml-paper-writing` |

面向 NeurIPS / ICML / ICLR / ACL / AAAI 的论文撰写指南。从研究仓库生成论文草稿，结构化论证，验证引用完整性。

#### humanizer — 文本去 AI 味

| 属性 | 值 |
|------|-----|
| **来源** | `blader/humanizer` |
| **调用** | `/humanizer` |

基于 Wikipedia "Signs of AI writing" 指南，检测并修复 AI 生成文本的典型模式：
- 夸张的象征性表达
- 过度营销化的语言
- 模板化的三段式结构
- AI 高频词汇和短语
- 破折号滥用

---

### Web of Science 工具链

针对 WoS 数据库的专属工具套件，通过 chrome-devtools MCP 操控浏览器自动化操作 WoS 网站。

#### wos-search — WoS 搜索

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-search-skill` |
| **调用** | `/wos-search` |

通过 WoS 内部 API 搜索论文，支持：
- 按主题/作者/标题/DOI/期刊/年份/基金号搜索
- 数据库选择 (Core Collection / All / MEDLINE / Preprint)
- 版本过滤 (SCI / SSCI / CPCI-S)
- 排序 (引用次数/日期/相关性)
- 中文关键词自动翻译为英文

#### wos-paper-detail — WoS 论文详情

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-paper-detail-skill` |
| **调用** | `/wos-paper-detail` |

提取论文的完整元数据：
- 标题、作者、摘要、关键词
- 期刊来源、卷/期/页码
- 引用次数 (WoS Core / All DB)
- JIF (影响因子)、JCR 分区
- 研究领域和 WoS 分类
- 全文链接

#### wos-navigate-pages — WoS 翻页

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-navigate-pages-skill` |
| **调用** | `/wos-navigate-pages` |

浏览 WoS 搜索结果的多页数据。支持 API 翻页（1 次工具调用）和 URL 翻页（2 次工具调用）。

#### wos-parse-results — WoS 结果解析 (内部 skill)

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-parse-results-skill` |
| **用户可调用** | 否 (被其他 skill 自动使用) |

从 WoS 搜索结果页面或 API 响应中提取结构化数据。Mode A (API 解析) 和 Mode B (DOM 提取) 两种方式。

#### wos-download — WoS 论文 PDF 下载

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-download-skill` |
| **调用** | `/wos-download` |

通过 WoS 的出版商链接下载 PDF 全文：
- 自动跟随 DOI 链接到出版商页面
- 检测 PDF 可用性（直接 PDF / 需点击下载按钮 / 登录墙 / 付费墙）
- 智能处理 Wiley / Elsevier / Springer / IEEE 等不同出版商的 PDF 查找策略
- 文件命名: `{第一作者}_{年份}_{短标题}.pdf`

#### wos-export — WoS 导出

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-export-skill` |
| **调用** | `/wos-export` |

两种导出模式：

- **Mode A — 推送到 Zotero** (推荐): 直接从对话上下文中的论文数据推送到 Zotero，无需浏览器交互。自动去重，支持批量导入。
- **Mode B — 文件导出**: 通过 WoS 网页 UI 导出为 RIS / BibTeX / Excel / 纯文本。

附带 `push_to_zotero.py` 脚本：通过 Zotero Connector API 将 WoS 论文元数据自动映射到 Zotero schema。

#### wos-reference — WoS 参考文档

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-reference` |
| **调用** | 无 (被 WoS skills 依赖) |

WoS 网站的 DOM 结构和 API 参考文档。包含：URL 模式、CSS 选择器、内部 API 端点和参数说明、字段标签映射。是 WoS 工具链的共享知识库。

#### wos-researcher — WoS 研究助手 Agent

| 属性 | 值 |
|------|-----|
| **来源** | `wanboyang/wos-researcher-agent` |
| **类型** | Agent (协调多个 skills) |

协调所有 WoS skills 的 Agent，封装了完整的 WoS 研究流程：
- 搜索 → 浏览结果 → 查看详情 → 下载 PDF → 导出
- 自动注入反爬虫脚本
- 维护 API 优先、DOM 回退的执行原则
- 最小化工具调用次数

---

### 文档与演示工具

#### pptx — PowerPoint 操作

| 属性 | 值 |
|------|-----|
| **来源** | 官方市场 |
| **调用** | `/pptx` |

创建、读取、编辑 .pptx 文件。支持：模板填充、幻灯片生成、文本提取、备注编辑。

#### docx — Word 文档操作

| 属性 | 值 |
|------|-----|
| **来源** | 官方市场 |
| **调用** | `/docx` |

创建、读取、编辑 .docx 文件。支持：模板填充、格式保留、内容提取、注释/修订。

#### pdf — PDF 操作

| 属性 | 值 |
|------|-----|
| **来源** | 官方市场 |
| **调用** | `/pdf` |

PDF 文件的全套操作：读取/提取文本和表格、合并/拆分、旋转页面、添加水印、OCR 扫描件、加密/解密。

#### xlsx — Excel 操作

| 属性 | 值 |
|------|-----|
| **来源** | 官方市场 |
| **调用** | `/xlsx` |

读取和创建 .xlsx 文件，支持公式、图表、数据透视表。

#### frontend-design — 前端设计

| 属性 | 值 |
|------|-----|
| **来源** | 官方市场 |
| **调用** | `/frontend-design` |

创建高质量的前端界面：网页、仪表盘、HTML 邮件、React 组件等。

---

### 其他 Skills (来自官方市场)

安装官方市场后可用 100+ skills，覆盖 ML 训练、部署、多模态、语音等方向。常用部分：

| Skill | 用途 |
|-------|------|
| `llamaindex` | 构建 RAG 应用 |
| `langchain` | LLM 应用开发框架 |
| `transformers` | HuggingFace 模型训练/推理 |
| `vllm` | 高性能 LLM 推理部署 |
| `peft` | LoRA/QLoRA 参数高效微调 |
| `trl-fine-tuning` | RLHF / DPO 对齐训练 |
| `deepseek` | DeepSeek 模型训练指南 |
| `pytorch-lightning` | PyTorch 训练框架 |
| `tensorboard` | 训练指标可视化 |
| `stable-diffusion` | 文生图模型 |
| `whisper` | 语音识别 |
| `mcp-builder` | 开发自定义 MCP 服务器 |
| `skill-creator` | 开发和优化 Skills |

---

## 手动配置项

| 配置 | 说明 |
|------|------|
| **DeepSeek API Key** | 在 [platform.deepseek.com](https://platform.deepseek.com/) 获取，设置为 `DEEPSEEK_API_KEY` 或直接配置 `ANTHROPIC_AUTH_TOKEN` |
| **alphaXiv OAuth** | 首次使用 alphaXiv MCP 时自动弹出浏览器完成认证 |
| **Zotero 客户端** | 安装 [Zotero](https://www.zotero.org/) + [zotero-mcp 插件](https://github.com/cookjohn/zotero-mcp/releases)，运行后 MCP 端口 23120 自动开启 |
| **Chrome 浏览器** | chrome-devtools MCP 需要 Chrome 运行。如需 VPN 下载论文，提前在 Chrome 中登录机构 Web VPN |

---

## 验证安装

```bash
# 检查 MCP 服务器状态
claude mcp list
# 应显示 6 个服务器均为 ✓ Connected

# 检查已安装的插件
claude plugins list

# 测试一个 skill
# 在 Claude Code 中输入: /literature-survey
```

---

## 注意事项

- **跨平台**: MCP 配置使用 `claude mcp add` 命令，自动适配 Windows/macOS/Linux 路径差异
- **代理**: 如果使用代理访问 GitHub，设置 `HTTP_PROXY` 和 `HTTPS_PROXY` 环境变量
- **首次运行**: Claude Code 首次启动会自动同步插件市场，Skills 在首次 `/skill-name` 调用时自动安装
- **权限**: 脚本配置了全部 MCP 工具的 Auto-Allow 权限。如需更严格策略，手动编辑 `~/.claude/settings.json`
