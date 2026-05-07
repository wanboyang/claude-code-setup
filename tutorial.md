# 自动化科研教程：以蛋白质亚细胞定位为例

本教程演示如何用 Claude Code 学术研究环境，全程自动化完成一个真实的研究任务——**蛋白质亚细胞定位** 方向的文献调研。

## 目录

1. [场景设定](#场景设定)
2. [第一步：论文搜索](#第一步论文搜索)
3. [第二步：批量筛选与下载](#第二步批量筛选与下载)
4. [第三步：文献综述与对比分析](#第三步文献综述与对比分析)
5. [第四步：WoS 补充检索](#第四步wos-补充检索)
6. [第五步：撰写初稿](#第五步撰写初稿)
7. [第六步：去 AI 味与润色](#第六步去-ai-味与润色)
8. [第七步：生成图表](#第七步生成图表)
9. [完整流程速览](#完整流程速览)

---

## 场景设定

> 你是一名生物信息学研究者，计划写一篇关于 **蛋白质亚细胞定位预测方法** (Protein Subcellular Localization Prediction) 的综述。你需要：
> 1. 找到近 5 年该领域的关键论文
> 2. 下载全文并提取核心方法
> 3. 对比不同方法的效果和思路
> 4. 整理成综述大纲
> 5. 撰写初稿

整个流程用 Claude Code 自动化完成。

---

## 第一步：论文搜索

### 1.1 用 academic-search 大范围搜索

在 Claude Code 对话中，调用学术搜索 Skill：

```
/academic-search "protein subcellular localization prediction deep learning"
```

Claude Code 会同时查询多个数据源（arXiv, Semantic Scholar, Crossref 等），返回结构化结果，包含标题、作者、年份、引用数、OA 状态。

### 1.2 发现关键文献

假设 search 返回了以下代表性论文：

| # | 论文 | 年份 | 方法 | 引用 |
|---|------|------|------|------|
| 1 | DeepLoc 2.0 (Thumuluri et al.) | 2022 | Transformer + Attention | 200+ |
| 2 | Light-Attention (Stärk et al.) | 2021 | Light Attention (LA) | 150+ |
| 3 | MULTiPly (Mistry et al.) | 2024 | Multi-task + ProtBERT | 8 |
| 4 | GPSite (Xia et al.) | 2025 | GNN + Protein LMs | 3 |
| 5 | LAProt (Shi et al.) | 2024 | Light Attention + Seq-only | 5 |

### 1.3 用 alphaXiv MCP 获取论文详情

直接在对话中请求：

> 帮我查看 2210.06546 (DeepLoc 2.0) 的 AI 结构化摘要

Claude Code 通过 alphaXiv MCP 调用 `get_paper_content`，返回：

```
DeepLoc 2.0: Protein Subcellular Localization Prediction
  - 问题: 预测蛋白质在细胞内的亚细胞定位（10+ 个区室）
  - 方法: Transformer 编码器 + 多标签注意力机制，从氨基酸序列直接预测
  - 数据集: DeepLoc 2.0 数据集（~14,000 蛋白，10 个类别）
  - 性能: 在多个基准上达到 SOTA
  - 代码: github.com/username/deeploc2
  - 局限: 仅基于序列，未使用结构信息
```

---

## 第二步：批量筛选与下载

### 2.1 用 paper-harvest 批量下载 arXiv 论文

对于 arXiv 上的论文，使用 `paper-harvest` Skill 一步完成搜索和下载：

```
/paper-harvest

paper-harvest pipeline "cat:q-bio.BM AND all:subcellular localization" -n 50 -c 10 -o ~/papers/protein-loc
```

**发生了什么？**
1. `paper-harvest` 通过 arXiv API 搜索匹配论文
2. 并发下载 PDF（`-c 10` = 10 个并发线程）
3. 自动提取 BibTeX
4. PDF 保存到 `~/papers/protein-loc/`

### 2.2 分流处理：arXiv vs 出版商

对于包含出版商论文（Nature, Cell 等）的混合结果：

```bash
# 搜索
paper-harvest search "protein subcellular localization" -n 100 -o papers.json

# 自动分流为 arXiv 和 VPN 下载两组
paper-harvest split papers.json -o ~/papers/protein-loc/

# arXiv 论文直接并发下载
paper-harvest download ~/papers/protein-loc/papers-arxiv.json -c 10

# 出版商论文通过 chrome-devtools + VPN 逐篇下载
# Claude Code 自动操控浏览器完成下载
```

### 2.3 下载后导入 Zotero

```bash
# 将所有论文元数据导入 Zotero
paper-harvest zotero papers.json --pdf-dir ~/papers/protein-loc/
```

Zotero 中自动出现 50 篇论文，附带 PDF 附件。

---

## 第三步：文献综述与对比分析

### 3.1 启动 literature-survey

下载完成后，调用文献综述 Skill：

```
/literature-survey

帮我做蛋白质亚细胞定位预测方向的文献综述。
这是 paper-harvest 下载的论文列表：~/papers/protein-loc/papers.json
```

### 3.2 Phase 1: 批量提取

Claude Code 逐批调用 alphaXiv MCP 提取每篇论文的结构化内容：

```
📊 已提取 35 篇论文:

  方法分类:
  - Transformer-based (12): DeepLoc 2.0, Light-Attention, ...
  - GNN-based (8): GPSite, GraphPart, ...
  - CNN-based (5): DeepLoc 1.0, pLoc-mDeep, ...
  - LLM-embedding (6): MULTiPly, ProtTrans-SubLoc, ...
  - Hybrid (4): Meta-approach, ensemble methods, ...

  主要数据集:
  - DeepLoc 2.0 (14): 哺乳动物蛋白，10类，实验验证
  - BaCELiPo (8): 细菌蛋白，4类
  - HPA (6): 人类蛋白质图谱，显微镜图像
  - UniProt-KB (15): 通用数据库，用作训练/测试

  年份分布:
  2021(5) 2022(8) 2023(7) 2024(10) 2025(5)

  代码开源率: 71% (25/35)
```

### 3.3 Phase 2-3: 对比矩阵生成

Claude Code 自动提取每个论文的统一 schema 并生成对比矩阵：

```csv
Paper,Year,Method,Category,Dataset,Accuracy,F1,vs Best,Code
DeepLoc 2.0,2022,Transformer+Attention,Transformer,DeepLoc2.0,0.872,0.858,+2.3%,github
Light-Attention,2021,LA+CNN,Transformer,DeepLoc2.0,0.854,0.841,baseline,github
MULTiPly,2024,ProtBERT+Multi-task,LLM-Embed,DeepLoc2.0,0.881,0.867,+1.1%,github
GPSite,2025,GNN+ESM-2,GNN,DeepLoc2.0,0.892,0.879,+2.1%,github
LAProt,2024,Light-Attn+Seq-only,Transformer,DeepLoc2.0,0.861,0.848,-1.3%,github
```

### 3.4 Phase 4: 趋势与空白分析

Claude Code 生成分析报告 (`gap-analysis.md`)：

```markdown
## 方法演化路径
DeepLoc 1.0 (2017, CNN) → Light-Attention (2021, LA) → DeepLoc 2.0 (2022, Transformer)
  → MULTiPly (2024, ProtBERT) → GPSite (2025, GNN+ESM-2)

## 当前热点
- 蛋白质语言模型嵌入 (ESM-2, ProtBERT, ProtT5) 替代传统序列特征
- 图神经网络建模蛋白质 3D 结构信息
- 多任务学习联合预测定位 + 功能

## 研究空白
1. 膜蛋白的动态定位预测（大多数方法只预测稳态定位）
2. 多定位蛋白的条件概率建模（一个蛋白可能位于多个区室）
3. 跨物种泛化：大多方法在哺乳动物上训练，在细菌/植物上泛化差
4. 与单细胞空间转录组数据的融合（空间信息 + 序列预测）
5. 不确定度量化：预测置信度很少被报告
```

### 3.5 Phase 5: 综述大纲

Claude Code 生成完整综述大纲 (`survey-outline.md`)：

```markdown
# 蛋白质亚细胞定位预测方法综述

## Abstract
- 亚细胞定位对蛋白质功能至关重要
- 深度学习方法已取代传统序列特征方法
- 综述从方法学角度分类: Transformer/GNN/LLM-embedding/Hybrid
- 关键发现和未来方向

## 1. Introduction
- 1.1 生物学背景：亚细胞定位与蛋白质功能
- 1.2 技术演进：从信号肽预测到深度神经网络
- 1.3 本综述的范围与贡献

## 2. 背景与基础
- 2.1 蛋白质亚细胞定位的生物学分类
- 2.2 传统方法回顾（PSORT, TargetP, SignalP）
- 2.3 深度学习基础（CNN, RNN, Transformer, GNN）

## 3. 分类体系与方法详解
- 3.1 Transformer 类方法（DeepLoc 2.0, LAProt, Light-Attention）
- 3.2 GNN 类方法（GPSite, GraphPart）
- 3.3 LLM-Embedding 类方法（MULTiPly, ProtTrans-SubLoc）
- 3.4 混合与集成方法
- 3.5 图像驱动方法（基于显微镜图像）

## 4. 数据集与评测基准
- 4.1 常用数据集
- 4.2 评测指标
- 4.3 跨方法性能对比

## 5. 趋势与洞见
- 5.1 从序列到结构的范式转移
- 5.2 蛋白质语言模型成为通用特征提取器
- 5.3 多任务与多模态融合

## 6. 挑战与未来方向
- 6.1 动态定位预测
- 6.2 跨物种泛化
- 6.3 多定位建模
- 6.4 与空间组学数据整合

## 7. 结论
```

---

## 第四步：WoS 补充检索

对于需要正式引用指标（JIF, JCR 分区）的场景，使用 WoS 工具链补充检索。

### 4.1 搜索 WoS

```
/wos-search protein subcellular localization deep learning --edition SCI --sort citations
```

返回：

```
Found **2,847** results in WoS Core Collection (SCI).
Sorted by: citations.

| # | Title | Authors | Source | Year | Cited | WoS ID |
|---|-------|---------|--------|------|-------|--------|
| 1 | DeepLoc: prediction of protein subcellular localization... | Almagro Armenteros, JJ | BIOINFORMATICS | 2017 | 1,245 | WOS:000412435900016 |
| 2 | Light-Attention predicts protein... | Stärk, H | NATURE MACH INTELL | 2021 | 892 | WOS:000779183600001 |
| ... |
```

### 4.2 获取论文详细信息

```
/wos-paper-detail WOS:000779183600001
```

返回完整元数据：JIF (25.8), JCR Q1, 所有作者、关键词、引用详情、全文链接。

### 4.3 导出到 Zotero

```
/wos-export zotero WOS:000412435900016 WOS:000779183600001 ...
```

论文直接推送到 Zotero，附带 WoS 引用指标。

---

## 第五步：撰写初稿

### 5.1 用 doc-coauthoring 或 ml-paper-writing 撰写

```
/doc-coauthoring

基于 survey-output/survey-outline.md 的结构，帮我写 Introduction 章节。
需要引用以下论文: [论文列表]。
要求: 学术风格，目标期刊 Bioinformatics，2000 字以内。
```

Claude Code 逐步生成各章节，用户可以交互式修正：

> 生成 Introduction 草稿 → 用户审阅 → 修改 → 确认
> 生成 Methods 章节 → 用户审阅 → ...

### 5.2 用 ml-paper-writing 写完整论文

```
/ml-paper-writing

根据 survey-output/ 下的所有材料，用 Bioinformatics 模板写一篇完整综述。
- 需要 LaTeX 格式
- 引用格式为 BibTeX
- 表格数据来自 comparison-matrix.csv
```

---

## 第六步：去 AI 味与润色

```
/humanizer

帮我润色这篇综述的 Introduction 和 Discussion，去掉 AI 写作痕迹。
```

humanizer 会检测并修复：
- 夸张的象征性表达（"revolutionized the field"）
- 模板化结构（"Not only... but also..."）
- AI 高频词汇（"delve into", "unveil", "showcase"）
- 破折号滥用
- 空洞的定性描述

---

## 第七步：生成图表

### 7.1 性能对比柱状图

```
/academic-plotting

根据 comparison-matrix.csv 生成方法对比柱状图。
X 轴: 方法名称, Y 轴: Accuracy 和 F1 双指标
配色: Nature 配色方案
输出: PDF (适合 LaTeX)
```

### 7.2 分类体系图

```
/academic-plotting

生成蛋白质亚细胞定位预测方法的分类体系架构图:
- 四大类方法 (Transformer/GNN/LLM-embedding/Hybrid)
- 每类下列举 2-3 代表方法
- 标注时间线 (2017 → 2025)
```

---

## 完整流程速览

```
     ┌──────────────────────────────────────────────────────────┐
     │                  自动化科研流水线                          │
     │           蛋白质亚细胞定位预测综述                          │
     └──────────────────────────────────────────────────────────┘

  阶段1: 搜索                    阶段2: 下载
  ┌──────────────┐           ┌──────────────┐
  │academic-search│  ──────→ │ paper-harvest │
  │   (搜索)      │  论文列表 │   (批量下载)   │
  │              │           │              │
  │ /wos-search   │   WoS ID │ chrome-       │
  │   (补充检索)  │  ──────→ │ devtools+VPN  │
  └──────────────┘           └──────┬───────┘
                                    │ PDF + BibTeX
                          ┌─────────▼─────────┐
                          │    Zotero         │
                          │   (文献管理)       │
                          └─────────┬─────────┘
                                    │
  阶段3: 分析                        │
  ┌──────────────┐                   │
  │literature-    │ ←────────────────┘
  │  survey       │  structured data
  │ (对比+综述大纲) │
  └──────┬───────┘
         │ survey-output/
         │ ├── extraction/*.yaml
         │ ├── comparison-matrix.csv
         │ ├── gap-analysis.md
         │ └── survey-outline.md
         │
  阶段4: 撰写          阶段5: 润色          阶段6: 图表
  ┌──────────────┐  ┌──────────────┐  ┌────────────────┐
  │ml-paper-     │  │  humanizer   │  │academic-       │
  │  writing     │→ │  (去AI味)    │  │  plotting      │
  │doc-coauthoring│  │              │  │  (生成图表)     │
  └──────────────┘  └──────────────┘  └────────────────┘
```

### 各阶段花费时间对比

| 阶段 | 传统人工 | Claude Code 自动化 | 节省 |
|------|----------|-------------------|------|
| 搜索 + 筛选 (50篇) | 2-3 小时 | 5 分钟 | ~96% |
| 下载 PDF (50篇) | 1-2 小时 | 10 分钟 (含 VPN) | ~90% |
| 文献综述对比 (30篇) | 2-3 天 | 30 分钟 | ~93% |
| 撰写初稿 (8000字) | 3-5 天 | 1-2 小时 | ~95% |
| 润色 + 去AI味 | 2-4 小时 | 10 分钟 | ~95% |
| 生成图表 (5张) | 3-5 小时 | 5 分钟 | ~97% |
| **总计** | **7-12 天** | **约 3 小时** | **~95%** |

> 自动化并非完全取代研究者。关键的判断——研究方向选择、分类维度设计、空白点验证、论文信度评估——仍需要领域专业知识。自动化节省的是机械劳动时间，让研究者聚焦于创造性思考。

---

## 与研究方向适配

如果你想对其他研究方向使用此流水线，只需将"蛋白质亚细胞定位"替换为你的研究主题：

```
# 示例 1: NLP — RLHF 对齐方法综述
/academic-search "RLHF alignment large language models"
paper-harvest pipeline "cat:cs.CL AND all:RLHF" -n 100 -c 10 -o ~/papers/rlhf

# 示例 2: CV — 扩散模型综述
/academic-search "diffusion models image generation survey"
paper-harvest pipeline "cat:cs.CV AND all:diffusion model" -n 80 -o ~/papers/diffusion

# 示例 3: 生物 — 单细胞 RNA-seq 分析
/academic-search "single cell RNA-seq analysis deep learning"
```

流程完全一致：搜索 → 下载 → 综述 → 撰写 → 润色 → 图表。
