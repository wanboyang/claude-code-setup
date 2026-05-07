# Claude Code Academic Research Environment

[**中文**](README.md) | **English**

A pre-configured Claude Code environment for academic research, covering the full pipeline: **Paper Search → Batch Download → Literature Survey → Manuscript Writing → Polish & Publish**.

---

## Overview

```
                    ┌──────────────────────────────────┐
                    │         DeepSeek V4 Pro          │
                    │   (Anthropic-compatible API)     │
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
   │Official  │   │3rd-party │   │Custom    │
   │Skills    │   │Skills (3)│   │Skills (8)│
   │(~100)    │   │          │   │+Agent(1) │
   └──────────┘   └──────────┘   └──────────┘
```

## Research Pipeline

This environment extends Claude Code from a "programming assistant" into an "academic research workstation":

```
academic-search ──→ paper-harvest ──→ literature-survey ──→ ml-paper-writing ──→ humanizer
  Search+Filter      Batch Download     Compare+Outline         Draft            Polish

                    WoS Toolkit (Web of Science):
                    wos-search ──→ wos-paper-detail ──→ wos-download
                        │                                    │
                        └──→ wos-navigate-pages              └──→ wos-export → Zotero
```

- **arXiv Track**: Fast access to the latest AI/CS/ML papers
- **WoS Track**: Formal academic scenarios requiring JIF/JCR/SCI metrics

> 📖 **Hands-on tutorial**: [Automated Research with Protein Subcellular Localization](tutorial_EN.md)

---

## Installation

### Prerequisites

| Dependency | Min Version | Purpose |
|------------|-------------|---------|
| Node.js | 18+ | chrome-devtools MCP runtime |
| Python | 3.9+ | markitdown MCP runtime |
| uv / uvx | latest | arxiv-latex-mcp runtime |
| Git | 2.x | Clone and version control |

### One-Command Setup

**macOS / Linux:**
```bash
git clone https://github.com/wanboyang/claude-code-setup.git
cd claude-code-setup

# With API key auto-config
DEEPSEEK_API_KEY=sk-xxx bash setup.sh

# Without API key (script prints instructions)
bash setup.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/wanboyang/claude-code-setup.git
cd claude-code-setup

# With API key auto-config
$env:DEEPSEEK_API_KEY = "sk-xxx"
powershell -ExecutionPolicy Bypass -File setup.ps1
```

The script executes 7 steps:

| Step | Task |
|:----:|------|
| 1 | Install Claude Code CLI |
| 2 | Configure DeepSeek V4 API backend |
| 3 | Check dependencies (Node.js, Python, uv) |
| 4 | Add official plugin marketplace |
| 5 | Install 15 independent Skills |
| 6 | Configure 6 MCP servers |
| 7 | Set tool permissions |

---

## API Backend

Uses **DeepSeek V4 Pro** as the model backend via the Anthropic-compatible API. Get your API key at [DeepSeek Platform](https://platform.deepseek.com/).

### Environment Variables

**macOS / Linux (`~/.bashrc` or `~/.zshrc`):**
```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=<your-deepseek-api-key>
export ANTHROPIC_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
```

**Windows PowerShell:**
```powershell
$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="<your-deepseek-api-key>"
$env:ANTHROPIC_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro[1m]"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_EFFORT_LEVEL="max"
```

**Windows permanent (admin):**
```powershell
setx ANTHROPIC_BASE_URL "https://api.deepseek.com/anthropic"
setx ANTHROPIC_MODEL "deepseek-v4-pro[1m]"
setx ANTHROPIC_DEFAULT_OPUS_MODEL "deepseek-v4-pro[1m]"
setx ANTHROPIC_DEFAULT_SONNET_MODEL "deepseek-v4-pro[1m]"
setx ANTHROPIC_DEFAULT_HAIKU_MODEL "deepseek-v4-flash"
setx CLAUDE_CODE_SUBAGENT_MODEL "deepseek-v4-flash"
setx CLAUDE_CODE_EFFORT_LEVEL "max"
setx ANTHROPIC_AUTH_TOKEN "<your-deepseek-api-key>"
```

> To use **Anthropic's official API**, set only `ANTHROPIC_AUTH_TOKEN` to your Anthropic key and remove `ANTHROPIC_BASE_URL`.

### Model Map

| Variable | Value | Role |
|----------|-------|------|
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` | Default model |
| `*_OPUS_MODEL` / `*_SONNET_MODEL` | `deepseek-v4-pro[1m]` | Claude Opus/Sonnet equivalent |
| `*_HAIKU_MODEL` | `deepseek-v4-flash` | Claude Haiku equivalent |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` | Sub-agent model |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` | Reasoning depth |

---

## MCP Servers

MCP (Model Context Protocol) servers provide external tool capabilities to Claude Code. This environment includes 6 servers:

### 1. alphaXiv — Academic Paper Search

| Property | Value |
|----------|-------|
| **Type** | HTTP (cloud) |
| **Endpoint** | `https://api.alphaxiv.org/mcp/v1` |
| **Auth** | OAuth (browser auto-opens on first use) |

- Search 2.5M+ arXiv papers
- AI-structured summaries (methods, contributions, limitations)
- Full PDF text access
- Citation and related-work graphs

### 2. arxiv-latex-mcp — arXiv LaTeX Tools

| Property | Value |
|----------|-------|
| **Type** | stdio |
| **Command** | `uvx arxiv-latex-mcp` |

- Access LaTeX source of arXiv papers
- Extract specific sections (Methods, Experiments)
- Compile and preview locally

### 3. chrome-devtools — Browser Automation

| Property | Value |
|----------|-------|
| **Type** | stdio |
| **Command** | `npx -y chrome-devtools-mcp@latest` |

- Control Chrome for automated web operations
- Navigate, fill forms, inject JavaScript
- Network request interception
- Download paywalled PDFs via institutional Web VPN

### 4. Zotero — Reference Management

| Property | Value |
|----------|-------|
| **Type** | HTTP (local) |
| **Endpoint** | `http://127.0.0.1:23120/mcp` |
| **Prerequisite** | Zotero client + zotero-mcp plugin |

- Push paper metadata directly to Zotero
- Batch import with content-hash dedup
- WoS field mapping (JIF, JCR quartile, citations)

### 5. markitdown — File Format Conversion

| Property | Value |
|----------|-------|
| **Type** | stdio |
| **Command** | `python -m markitdown_mcp` |

- Convert files to Markdown: PDF, DOCX, PPTX, XLSX, HTML, CSV, JSON, XML
- Preserves document structure

### 6. office-mcp — Office File Operations

| Property | Value |
|----------|-------|
| **Type** | stdio |
| **Command** | `node <path>/office-mcp/dist/index.js` |

- Create/edit Word, PowerPoint, Excel files
- PDF operations: merge, split, compress, OCR, form-fill
- Format interconversion: MD↔DOCX, PDF↔DOCX, CSV↔XLSX

---

## Skills

Skills are knowledge modules that encapsulate domain-specific workflows. Invoked via `/skill-name`.

### Core Research Skills

| Skill | Source | Description |
|-------|--------|-------------|
| `academic-search` | ustc-ai4science | Unified search: arXiv, Semantic Scholar, Crossref, CNKI |
| `paper-harvest` | wanboyang | Batch download with arXiv/VPN split, Zotero integration |
| `literature-survey` | wanboyang | 5-phase pipeline: extract → compare → gap analysis → outline |
| `academic-plotting` | zechenzhangAGI | Publication-quality figures (architecture diagrams, data charts) |
| `humanizer` | blader | Detect and remove AI-writing patterns, naturalize text |
| `ml-paper-writing` | marketplace | Draft papers for NeurIPS/ICML/ICLR/ACL/AAAI |

### WoS Toolkit

| Skill | Source | Description |
|-------|--------|-------------|
| `wos-search` | wanboyang | WoS search by topic/author/DOI/SCIE/SSCI filtering |
| `wos-paper-detail` | wanboyang | Full metadata: JIF, JCR quartile, citations |
| `wos-navigate-pages` | wanboyang | API-based pagination |
| `wos-parse-results` | wanboyang | Internal: parse WoS to structured data |
| `wos-download` | wanboyang | Follow publisher links, handle login/paywall |
| `wos-export` | wanboyang | Push to Zotero or export RIS/BibTeX/Excel |
| `wos-reference` | wanboyang | Shared knowledge: WoS DOM, API, CSS selectors |
| `wos-researcher` | wanboyang | Agent orchestrating all WoS skills |

### Document Production

| Skill | Source | Description |
|-------|--------|-------------|
| `pptx` | marketplace | PowerPoint creation and editing |
| `docx` | marketplace | Word document creation and editing |
| `pdf` | marketplace | Merge, split, rotate, OCR, watermark PDFs |
| `xlsx` | marketplace | Spreadsheets with formulas, charts, pivot tables |

---

## Manual Setup

| Item | Action |
|------|--------|
| **DeepSeek API Key** | Register at [platform.deepseek.com](https://platform.deepseek.com/) |
| **alphaXiv OAuth** | Auto-opens browser on first use |
| **Zotero** | Install [Zotero](https://www.zotero.org/) + [zotero-mcp plugin](https://github.com/cookjohn/zotero-mcp/releases) |
| **Chrome** | Required for chrome-devtools. Log into institutional Web VPN for paywalled PDFs |

---

## Verify

```bash
claude mcp list         # All 6 servers should show ✓ Connected
claude plugins list     # Check installed plugins
```

## Adapt to Your Field

Replace the search query for any research domain:

```bash
# NLP: RLHF alignment
/academic-search "RLHF alignment large language models"

# CV: Diffusion models
paper-harvest pipeline "cat:cs.CV AND all:diffusion model" -n 80 -o ~/papers/diffusion

# Bio: Single-cell RNA-seq
/academic-search "single cell RNA-seq deep learning"
```

Pipeline remains identical: Search → Download → Survey → Write → Polish.

---

## Notes

- MCP configurations use `claude mcp add`, adapting paths across platforms automatically
- Set `HTTP_PROXY` / `HTTPS_PROXY` if accessing GitHub via proxy
- Skills auto-install on first `/skill-name` invocation
