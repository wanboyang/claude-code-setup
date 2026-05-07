# AI4SCIENCE Research Environment

> 将 Claude Code 扩展为 AI 驱动的学术研究工作站。一套配置，覆盖 **Search → Download → Survey → Write → Polish** 全流程。

[![Setup](https://img.shields.io/badge/setup-one--command-blue)](#quick-start)
[![Skills](https://img.shields.io/badge/skills-15-green)](https://github.com/wanboyang?tab=repositories&q=skill)
[![MCPs](https://img.shields.io/badge/MCPs-6-orange)](#mcp-servers)
[![Tutorial](https://img.shields.io/badge/📖-tutorial-purple)](tutorial.md)
[![Backend](https://img.shields.io/badge/backend-DeepSeek%20V4-brightgreen)](https://platform.deepseek.com/)

---

## What is this?

A **pre-configured Claude Code environment** purpose-built for academic research. It chains 6 MCP servers and 15 specialized skills into an automated pipeline that takes you from a research idea to a polished manuscript.

```
Research Idea  ──→  Literature Search  ──→  Batch Download  ──→  Comparative Survey
                                                                        │
                                                         ┌──────────────┘
                                                         ▼
                    Polished Draft  ←──  AI-Polish  ←──  Draft Writing
```

**Why:** A typical literature survey takes 7–12 days of manual work. This environment automates the mechanical parts, cutting it down to roughly 3 hours while you focus on creative decisions.

> 📖 **New to this? Start with the [Tutorial: Automated Research with Protein Subcellular Localization](tutorial.md).**

---

## Quick Start

### Prerequisites

- **Node.js** ≥ 18 · **Python** ≥ 3.9 · **uv** (latest) · **Git** 2.x

### One Command

```bash
# macOS / Linux
git clone https://github.com/wanboyang/claude-code-setup.git && cd claude-code-setup
DEEPSEEK_API_KEY=sk-xxx bash setup.sh

# Windows PowerShell
git clone https://github.com/wanboyang/claude-code-setup.git; cd claude-code-setup
$env:DEEPSEEK_API_KEY="sk-xxx"; powershell -ExecutionPolicy Bypass -File setup.ps1
```

The script runs 7 steps automatically: install CLI → configure API → check deps → add marketplace → install 15 skills → configure 6 MCPs → set permissions.

Get your API key at [platform.deepseek.com](https://platform.deepseek.com/).

---

## Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    DeepSeek V4 Pro                          │
│             (Anthropic-compatible API backend)              │
└────────────────────────┬───────────────────────────────────┘
                         │
┌────────────────────────▼───────────────────────────────────┐
│                    Claude Code CLI                          │
└────────┬───────┬───────┬───────┬───────┬──────────────────┘
         │       │       │       │       │
    ┌────▼──┐┌──▼───┐┌──▼───┐┌──▼───┐┌──▼──────┐
    │alphaXiv││arxiv ││Chrome││Zotero││markitdown│
    │  MCP   ││latex ││DevTools││MCP  ││office-mcp│
    │        ││ MCP  ││ MCP  ││     ││   MCP    │
    └────┬──┘└──┬───┘└──┬───┘└──┬──┘└────┬─────┘
         │      │       │       │        │
         └──────┴───────┴───────┴────────┘
                        │
         ┌──────────────┼──────────────┐
         ▼              ▼              ▼
    ┌─────────┐   ┌─────────┐   ┌──────────┐
    │Official │   │ 3rd-Party│   │Custom    │
    │Marketplace│  │Skills (3)│   │Skills (8)│
    │(~100)   │   │         │   │+ Agent(1)│
    └─────────┘   └─────────┘   └──────────┘
```

---

## The Pipeline

### arXiv Track _(fast, for AI/CS/ML)_

```
/academic-search  →  /paper-harvest  →  /literature-survey  →  /ml-paper-writing  →  /humanizer
     search             download            compare + outline        draft             polish
```

### WoS Track _(formal, with citation metrics)_

```
/wos-search  →  /wos-paper-detail  →  /wos-download  →  /wos-export  →  Zotero
                       │
                       └──  /wos-navigate-pages  (browse results)
```

| Step | Skill | What it does |
|:----:|-------|--------------|
| 1 | `/academic-search` | Multi-source search (arXiv, Semantic Scholar, Crossref, CNKI) |
| 2 | `/paper-harvest` | Batch download PDFs — arXiv direct + Web VPN for paywalled |
| 3 | `/literature-survey` | Extract → Compare → Gap Analysis → Survey Outline |
| 4 | `/wos-search` | WoS search with SCI/SSCI filtering, citation sorting |
| 5 | `/wos-paper-detail` | Full metadata: JIF, JCR quartile, citations |
| 6 | `/wos-export` | Push to Zotero or export RIS/BibTeX/Excel |
| 7 | `/ml-paper-writing` | Structured draft for NeurIPS/ICML/ICLR/ACL |
| 8 | `/humanizer` | Remove AI-writing patterns, naturalize text |
| 9 | `/academic-plotting` | Generate publication-ready figures |

---

## Component Catalog

### MCP Servers

| Server | Type | What it gives you |
|--------|------|-------------------|
| **alphaXiv** | HTTP cloud | Search 2.5M+ arXiv papers; AI-structured summaries with method/contribution/limitation breakdown |
| **arxiv-latex-mcp** | stdio (uvx) | Extract LaTeX source and specific sections from arXiv papers |
| **chrome-devtools** | stdio (npx) | Browser automation — navigate publisher sites, execute JS, download paywalled PDFs via Web VPN |
| **Zotero** | HTTP local | Push paper metadata directly into Zotero with dedup, WoS field mapping, citation counts |
| **markitdown** | stdio (python) | Convert PDF/DOCX/PPTX/XLSX/HTML to Markdown, preserving structure |
| **office-mcp** | stdio (node) | Create/edit Word, PowerPoint, Excel; PDF merge/split/OCR; format interconversion |

### Core Research Skills

| Skill | Source | One-line |
|-------|--------|----------|
| `academic-search` | ustc-ai4science | Unified search across arXiv, Semantic Scholar, Crossref, CNKI |
| `paper-harvest` | wanboyang | Batch download with arXiv/VPN split, auto-import to Zotero |
| `literature-survey` | wanboyang | 5-phase pipeline: extract → compare matrix → gap analysis → survey outline |
| `academic-plotting` | zechenzhangAGI | Publication-quality architecture diagrams and data charts |
| `humanizer` | blader | Detect and fix AI-generated writing patterns |

### WoS Toolkit

| Skill | Source | One-line |
|-------|--------|----------|
| `wos-search` | wanboyang | Search WoS by topic/author/DOI with SCI/SSCI filtering |
| `wos-paper-detail` | wanboyang | Extract full metadata: JIF, JCR quartile, citation counts |
| `wos-navigate-pages` | wanboyang | API-based pagination (1 tool call per page) |
| `wos-parse-results` | wanboyang | Internal: parse WoS API/HTML to structured data |
| `wos-download` | wanboyang | Follow publisher links, detect PDFs, handle login/paywall |
| `wos-export` | wanboyang | Push to Zotero (direct) or export RIS/BibTeX/Excel via WoS UI |
| `wos-reference` | wanboyang | Shared knowledge base: WoS DOM selectors, API docs, URL patterns |
| `wos-researcher` | wanboyang | Agent orchestrating all WoS skills with anti-detection |

### Document Production

| Skill | Source | One-line |
|-------|--------|----------|
| `pptx` | marketplace | Create and edit PowerPoint presentations |
| `docx` | marketplace | Create and edit Word documents with templates |
| `pdf` | marketplace | Merge, split, rotate, OCR, watermark PDFs |
| `xlsx` | marketplace | Create spreadsheets with formulas, charts, pivot tables |
| `ml-paper-writing` | marketplace | LaTeX paper drafting for NeurIPS/ICML/ICLR/ACL/AAAI |
| `systems-paper-writing` | marketplace | LaTeX paper drafting for OSDI/SOSP/ASPLOS/NSDI |
| `presenting-conference-talks` | marketplace | Generate Beamer slides with speaker notes |
| `frontend-design` | marketplace | Build web UIs, dashboards, HTML artifacts |

---

## API Backend

This environment routes Claude Code through **DeepSeek V4 Pro** via the Anthropic-compatible endpoint.

### Environment Config

Add to `~/.bashrc`, `~/.zshrc`, or Windows system environment:

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

| Variable | Value | Role |
|----------|-------|------|
| `ANTHROPIC_MODEL` | `deepseek-v4-pro[1m]` | Default model |
| `*_OPUS_MODEL` / `*_SONNET_MODEL` | `deepseek-v4-pro[1m]` | Equivalent to Opus/Sonnet tier |
| `*_HAIKU_MODEL` | `deepseek-v4-flash` | Lightweight for fast tasks |
| `CLAUDE_CODE_SUBAGENT_MODEL` | `deepseek-v4-flash` | Sub-agent model |
| `CLAUDE_CODE_EFFORT_LEVEL` | `max` | Reasoning depth |

> **Using Anthropic's official API instead?** Simply omit `ANTHROPIC_BASE_URL` and set `ANTHROPIC_AUTH_TOKEN` to your Anthropic key.

---

## Manual Setup Items

Some components need one-time manual configuration:

| Item | What to do |
|------|-------------|
| **DeepSeek API Key** | Register at [platform.deepseek.com](https://platform.deepseek.com/) |
| **alphaXiv OAuth** | Auto-opens browser on first use — log in once |
| **Zotero** | Install [Zotero](https://www.zotero.org/) + [zotero-mcp plugin](https://github.com/cookjohn/zotero-mcp/releases), keep it running |
| **Chrome** | Required for chrome-devtools MCP. Log into your institutional Web VPN for paywalled PDFs |

---

## Verify

```bash
claude mcp list         # All 6 servers should show ✓ Connected
claude plugins list     # Check installed skills

# Try a skill in Claude Code:
# /literature-survey
```

## Adapt to Your Field

This pipeline is domain-agnostic. Replace the search query:

```bash
# NLP: RLHF alignment
/academic-search "RLHF alignment large language models"

# CV: Diffusion models
paper-harvest pipeline "cat:cs.CV AND all:diffusion model" -n 80 -o ~/papers/diffusion

# Bio: Single-cell RNA-seq
/academic-search "single cell RNA-seq deep learning"
```

The flow is identical: Search → Download → Survey → Write → Polish.

---

## Notes

- MCP configs use `claude mcp add` — paths adapt automatically across Windows/macOS/Linux
- Set `HTTP_PROXY` / `HTTPS_PROXY` if you access GitHub through a proxy
- Skills install on first `/skill-name` invocation — no need to pre-install all 100+ marketplace skills
- Sub-agent model uses `deepseek-v4-flash` to reduce cost on background tasks
