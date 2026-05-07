# Automated Research Tutorial: Protein Subcellular Localization

[**中文**](tutorial.md) | **English**

A step-by-step guide to running an automated research pipeline with Claude Code, using **protein subcellular localization prediction** as an example.

---

## Scenario

> You are a bioinformatics researcher planning a survey on **protein subcellular localization prediction methods**. You need to:
> 1. Find key papers from the past 5 years
> 2. Download full texts and extract core methods
> 3. Compare approaches and performance
> 4. Organize findings into a survey outline
> 5. Write a draft

All automated with Claude Code.

---

## Step 1: Literature Search

### 1.1 Broad Search

```
/academic-search "protein subcellular localization prediction deep learning"
```

Claude Code queries multiple sources simultaneously (arXiv, Semantic Scholar, Crossref) and returns structured results with titles, authors, years, citations, and OA status.

### 1.2 Representative Papers Found

| # | Paper | Year | Method | Citations |
|---|-------|------|--------|-----------|
| 1 | DeepLoc 2.0 (Thumuluri et al.) | 2022 | Transformer + Attention | 200+ |
| 2 | Light-Attention (Stärk et al.) | 2021 | Light Attention (LA) | 150+ |
| 3 | MULTiPly (Mistry et al.) | 2024 | Multi-task + ProtBERT | 8 |
| 4 | GPSite (Xia et al.) | 2025 | GNN + Protein LMs | 3 |
| 5 | LAProt (Shi et al.) | 2024 | Light Attention + Seq-only | 5 |

### 1.3 AI-Structured Summaries

> Show me the AI-structured summary for 2210.06546 (DeepLoc 2.0)

Claude Code calls alphaXiv MCP `get_paper_content`:

```
DeepLoc 2.0: Protein Subcellular Localization Prediction
  - Problem: Predicting subcellular localization across 10+ compartments
  - Method: Transformer encoder + multi-label attention, sequence-only
  - Dataset: DeepLoc 2.0 (~14,000 proteins, 10 classes)
  - Performance: SOTA on multiple benchmarks
  - Code: github.com/username/deeploc2
  - Limitation: No structural information used
```

---

## Step 2: Batch Download

### 2.1 arXiv Papers

```
/paper-harvest

paper-harvest pipeline "cat:q-bio.BM AND all:subcellular localization" -n 50 -c 10 -o ~/papers/protein-loc
```

**What happens:**
1. Paper-harvest queries the arXiv API
2. Downloads PDFs concurrently (10 threads)
3. Extracts BibTeX automatically
4. Saves to `~/papers/protein-loc/`

### 2.2 Split by Source

For mixed results (arXiv + publisher papers):

```bash
# Search
paper-harvest search "protein subcellular localization" -n 100 -o papers.json

# Split
paper-harvest split papers.json -o ~/papers/protein-loc/

# arXiv: concurrent download
paper-harvest download ~/papers/protein-loc/papers-arxiv.json -c 10

# Publisher: chrome-devtools + Web VPN, one by one
# Claude Code automatically drives the browser
```

### 2.3 Import to Zotero

```bash
paper-harvest zotero papers.json --pdf-dir ~/papers/protein-loc/
```

All 50 papers appear in Zotero with PDF attachments.

---

## Step 3: Literature Survey

### 3.1 Launch

```
/literature-survey

Run a literature survey on protein subcellular localization.
Paper list: ~/papers/protein-loc/papers.json
```

### 3.2 Phase 1: Batch Extraction

Claude Code extracts structured content from every paper via alphaXiv:

```
📊 Analyzed 35 papers:

  Method Categories:
  - Transformer-based (12): DeepLoc 2.0, Light-Attention, ...
  - GNN-based (8): GPSite, GraphPart, ...
  - CNN-based (5): DeepLoc 1.0, pLoc-mDeep, ...
  - LLM-embedding (6): MULTiPly, ProtTrans-SubLoc, ...
  - Hybrid (4): Ensemble methods, ...

  Key Datasets:
  - DeepLoc 2.0 (14): Mammalian proteins, 10 classes
  - BaCELiPo (8): Bacterial proteins, 4 classes
  - HPA (6): Human Protein Atlas, microscopy images
  - UniProt-KB (15): General-purpose

  Year Distribution: 2021(5) 2022(8) 2023(7) 2024(10) 2025(5)
  Open Source Rate: 71% (25/35)
```

### 3.3 Phase 2-3: Comparison Matrix

Claude Code generates a structured comparison:

```csv
Paper,Year,Method,Category,Dataset,Accuracy,F1,vs Best,Code
DeepLoc 2.0,2022,Transformer+Attention,Transformer,DeepLoc2.0,0.872,0.858,+2.3%,github
Light-Attention,2021,LA+CNN,Transformer,DeepLoc2.0,0.854,0.841,baseline,github
MULTiPly,2024,ProtBERT+Multi-task,LLM-Embed,DeepLoc2.0,0.881,0.867,+1.1%,github
GPSite,2025,GNN+ESM-2,GNN,DeepLoc2.0,0.892,0.879,+2.1%,github
LAProt,2024,Light-Attn+Seq-only,Transformer,DeepLoc2.0,0.861,0.848,-1.3%,github
```

### 3.4 Phase 4: Gap Analysis

Claude Code produces `gap-analysis.md`:

```markdown
## Method Evolution
DeepLoc 1.0 (2017, CNN) → Light-Attention (2021, LA) → DeepLoc 2.0 (2022, Transformer)
  → MULTiPly (2024, ProtBERT) → GPSite (2025, GNN+ESM-2)

## Hot Topics
- Protein language model embeddings replacing traditional sequence features
- Graph neural networks for 3D structure modeling
- Multi-task learning for joint localization + function prediction

## Research Gaps
1. Dynamic localization (most methods predict only steady-state)
2. Multi-location conditional probability modeling
3. Cross-species generalization
4. Integration with single-cell spatial transcriptomics
5. Uncertainty quantification
```

### 3.5 Phase 5: Survey Outline

Claude Code generates `survey-outline.md` with 7 chapters, each with key points and must-cite papers.

---

## Step 4: WoS Supplementary Search

### 4.1 Search

```
/wos-search protein subcellular localization deep learning --edition SCI --sort citations
```

Returns 2,847 results with WoS IDs and citation counts.

### 4.2 Paper Details

```
/wos-paper-detail WOS:000779183600001
```

Returns full metadata: JIF (25.8), JCR Q1, all authors, keywords, citation details.

### 4.3 Export to Zotero

```
/wos-export zotero WOS:000412435900016 WOS:000779183600001 ...
```

Papers push directly to Zotero with WoS citation metrics.

---

## Step 5: Draft Writing

```
/doc-coauthoring

Write the Introduction based on survey-output/survey-outline.md.
Cite these papers: [list].
Style: academic, target journal Bioinformatics, ~2000 words.
```

Or for full LaTeX:

```
/ml-paper-writing

Write a complete survey using Bioinformatics template.
Data from comparison-matrix.csv. BibTeX references.
```

---

## Step 6: Polish

```
/humanizer

Polish the Introduction and Discussion. Remove AI-writing traces.
```

Detects and fixes: inflated symbolism, promotional language, formulaic structures, AI vocabulary, em-dash overuse.

---

## Step 7: Generate Figures

```
/academic-plotting

Generate a performance comparison bar chart from comparison-matrix.csv.
Nature color scheme. PDF output for LaTeX.
```

```
/academic-plotting

Generate a taxonomy architecture diagram for subcellular localization prediction methods.
Four categories: Transformer / GNN / LLM-embedding / Hybrid.
Timeline annotation: 2017 → 2025.
```

---

## Full Pipeline

```
     ┌──────────────────────────────────────────────────────────┐
     │              Automated Research Pipeline                  │
     │       Protein Subcellular Localization Survey             │
     └──────────────────────────────────────────────────────────┘

  Phase 1: Search                Phase 2: Download
  ┌──────────────┐           ┌──────────────┐
  │academic-search│  ──────→ │ paper-harvest │
  │              │  papers   │  (batch DL)   │
  │ /wos-search   │  WoS IDs │ chrome-       │
  │              │  ──────→ │ devtools+VPN  │
  └──────────────┘           └──────┬───────┘
                                    │ PDF + BibTeX
                          ┌─────────▼─────────┐
                          │      Zotero       │
                          └─────────┬─────────┘
                                    │
  Phase 3: Survey                   │
  ┌──────────────┐                   │
  │literature-    │ ←────────────────┘
  │  survey       │
  │(compare+outline)│
  └──────┬───────┘
         │ survey-output/
         │ ├── extraction/*.yaml
         │ ├── comparison-matrix.csv
         │ ├── gap-analysis.md
         │ └── survey-outline.md
         │
  Phase 4: Write       Phase 5: Polish       Phase 6: Figures
  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐
  │ml-paper-     │  │  humanizer   │  │academic-       │
  │  writing     │→ │  (polish)    │  │  plotting      │
  │doc-coauthoring│  │              │  │                │
  └──────────────┘  └──────────────┘  └────────────────┘
```

### Time Comparison

| Phase | Manual | Automated | Savings |
|-------|--------|-----------|---------|
| Search + filter (50 papers) | 2–3 hrs | 5 min | ~96% |
| Download PDFs (50 papers) | 1–2 hrs | 10 min | ~90% |
| Literature survey (30 papers) | 2–3 days | 30 min | ~93% |
| Draft writing (8,000 words) | 3–5 days | 1–2 hrs | ~95% |
| Polish | 2–4 hrs | 10 min | ~95% |
| Generate figures (5) | 3–5 hrs | 5 min | ~97% |
| **Total** | **7–12 days** | **~3 hrs** | **~95%** |

> Automation doesn't replace the researcher. Critical decisions—direction, taxonomy design, gap validation, paper credibility assessment—still require domain expertise. Automation saves mechanical labor, freeing you to focus on creative thinking.

---

## Adapt to Your Domain

Replace the query for any research field:

```bash
# NLP: RLHF Alignment
/academic-search "RLHF alignment large language models"
paper-harvest pipeline "cat:cs.CL AND all:RLHF" -n 100 -o ~/papers/rlhf

# CV: Diffusion Models
/academic-search "diffusion models image generation"
paper-harvest pipeline "cat:cs.CV AND all:diffusion model" -n 80 -o ~/papers/diffusion

# Bio: Single-cell RNA-seq
/academic-search "single cell RNA-seq deep learning"
```

Pipeline stays the same: Search → Download → Survey → Write → Polish → Figures.
