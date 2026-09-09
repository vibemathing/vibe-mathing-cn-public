# vibe-mathing-cn：可信 AI 数学研究与验证工作台

[![CI](https://github.com/vibemathing/vibe-mathing-cn-public/actions/workflows/ci.yml/badge.svg)](https://github.com/vibemathing/vibe-mathing-cn-public/actions/workflows/ci.yml)
[![Python](https://img.shields.io/badge/Python-3.12-3776AB)](requirements.txt)
[![Lean fixture](https://img.shields.io/badge/Lean-fixture-4B69FF)](fixtures/lean-proof/README.md)
[![License](https://img.shields.io/badge/license-MIT-0B7A75)](LICENSE)
[![Solution index](https://img.shields.io/badge/solutions-empty-orange)](result-library/indexes/solutions.json)
[![GEO](https://img.shields.io/badge/GEO-fact--bounded-7C3AED)](GEO.md)
[![Metamodel](https://img.shields.io/badge/metamodel-Point--Line--Face--Body-0B7A75)](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md)

> **非可信候选生成器 + 受信验证链：从问题空间构造候选，经验证后派生解空间。**

`vibe-mathing-cn` 把数学问题、文献、推导、计算、证明与形式化检查组织成可追溯的研究系统。生成器可以不完备、出错或不终止；只有满足明确验收谓词的候选结果，才能出现在解库派生视图中。

💬 中文交流群：[Telegram · Vibe Mathing 中文社区](https://t.me/vibe_mathing_cn)

本仓库自有代码与文档按 [MIT License](LICENSE) 发布；`vendor/` 中的第三方材料以各自许可证和来源锁为准。

> **当前公共状态（核验于 2026-09-09）：** canonical Problem、Attempt、Result 记录和 `result-library/indexes/solutions.json` 当前均为空；本仓库不声称解决 Riemann 假设、P vs NP 或任何其他开放数学问题。公开内容是可移植的 Schema、验证规则、owner skills、合成 Fixture、CLI 和 CI。

公共仓库地址：<https://github.com/vibemathing/vibe-mathing-cn-public>

### 公开入口索引

| 入口 | 用途 |
| --- | --- |
| [问题仓库总览 · GitHub Project #1](https://github.com/users/vibemathing/projects/1) | 浏览公开单问题仓库；Project、字段和卡片是运营索引，不是数学证据 |
| [赏金问题地图 · GitHub Project #2 View 3](https://github.com/users/vibemathing/projects/2/views/3) | 浏览带日期的赏金排序；金额和 Project 状态是来源元数据，不是数学证据或可领取余额 |
| [赏金问题仓库 Top 146 快照](problem-library/BOUNTY_PROJECT_2_TOP146.md) | 阅读去重后的公共仓库清单及机器可读快照 |
| [公共 ProblemContract 问题库](https://github.com/vibemathing/vibe-mathing-problem-library-public) | 查找公开问题合同、catalog 和仓库 locator |
| [单问题研究模板仓库](https://github.com/vibemathing/vibe-mathing-problem-public-template) | 查看固定 Web research Harness、候选写入边界与启动文件 |
| [全部 `vibemathing` 公开仓库](https://github.com/vibemathing?tab=repositories) | 查找具体 `problem-*` 仓库及其他公共工程仓库 |
| [本仓库的详细公共问题索引](problem-library/VIBEMATHING_PUBLIC_INDEX.md) | 阅读 catalog、模板、查询命令和准入边界 |

### 关键问题仓库与赏金地图

> 以下均为 ProblemContract/候选研究入口。仓库、Issue、PR、CI 或 checkpoint 的存在不表示问题已解决，也不自动产生 Evidence、Result 或 Solution；secp256k1 条目不属于千禧年问题。

带日期的 [`Project #2 View 3 快照`](problem-library/BOUNTY_PROJECT_2_TOP146.md) 收录美元等值赏金视图中前 146 个唯一仓库 URL，并保留原币种、来源状态、Award 状态和来源信息。其 [`机器可读快照`](problem-library/registry/bounty-project-2-top146.v1.json) 只是 pointer-only 运营元数据，不导入 ProblemContract，也不把金额相加。由于目标单位是 146 个仓库，末端保留了 USD 100.00 的边界行；这不是“每一行都严格大于 USD 100”的声明。

六个千禧年条目仍单独归类。密码学 `secp256k1` 条目是独立的复杂性审计问题，不属于千禧年问题。

| 类别 | 问题 | 公开单问题仓库 |
| --- | --- | --- |
| 千禧年问题 | 黎曼猜想 | [`problem-millennium-riemann-hypothesis`](https://github.com/vibemathing/problem-millennium-riemann-hypothesis) |
| 千禧年问题 | P 与 NP 问题 | [`problem-millennium-p-vs-np`](https://github.com/vibemathing/problem-millennium-p-vs-np) |
| 千禧年问题 | Navier–Stokes 方程存在性与光滑性 | [`problem-millennium-navier-stokes`](https://github.com/vibemathing/problem-millennium-navier-stokes) |
| 千禧年问题 | Yang–Mills 理论存在性与质量间隙 | [`problem-millennium-yang-mills-mass-gap`](https://github.com/vibemathing/problem-millennium-yang-mills-mass-gap) |
| 千禧年问题 | 霍奇猜想 | [`problem-millennium-hodge-conjecture`](https://github.com/vibemathing/problem-millennium-hodge-conjecture) |
| 千禧年问题 | Birch–Swinnerton-Dyer 猜想 | [`problem-millennium-birch-swinnerton-dyer`](https://github.com/vibemathing/problem-millennium-birch-swinnerton-dyer) |
| 独立密码学问题 | secp256k1 离散对数经典多项式时间性审计 | [`problem-secp256k1-ecdlog-polytime`](https://github.com/vibemathing/problem-secp256k1-ecdlog-polytime) |

## 30 秒理解

| 你想知道 | 直接答案 |
| --- | --- |
| 这是什么？ | 一个把 AI 数学探索组织为 ProblemContract、Attempt、Result 和证据账本的研究与验证工作台 |
| 它解决什么问题？ | 防止候选、证明草稿、有限计算或模型自评直接变成数学结论 |
| 输入是什么？ | 冻结陈述、定义域、量词、假设、来源、验收策略和资源约束的 ProblemContract |
| 输出是什么？ | 可追溯的 ResearchBundle，以及由合格 Result 派生的只读 Solution View |
| 当前有新数学解吗？ | 没有；canonical ledger 和解库索引为空，合成 Fixture 只验证工程链路 |
| 它明确不是什么？ | 不是保证解决任意开放问题的通用求解器，也不是外部数学认证机构 |
| 唯一概念根是什么？ | `Point → Line → Face → Body`；PWTSJ 是 F05 过程面，OSPS 是 F04 结果空间面 |
| 顶层生命周期怎么组织？ | F05 中使用 `Project → Workflow → Task → Step → Job`；Job 是 Step 的一次有界执行，不等于问题已解决 |
| 具体开放问题在哪里？ | 见 [Vibe Mathing 公共问题索引](problem-library/VIBEMATHING_PUBLIC_INDEX.md)；远端 catalog 与单问题仓库不会自动成为本地 Result |

## 架构总览

![vibe-mathing-cn 双层架构总览](assets/architecture.svg)

上图是静态视觉总览，也是阅读和路由模型：PLFB 是唯一概念根；F05/PWTSJ 组织执行，F04/OSPS 维护结果空间，F09/F10 裁决证据与 Result。各面通过显式 Line 连接，但不能互相越权闭合。纯文本客户端可阅读 [`POINT-LINE-FACE-BODY-METAMODEL-v0.1.md`](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md)；F05 细节见 [`RESEARCH-LIFECYCLE-MODEL-v0.1.md`](governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md)。

## 快速导航

- [架构总览](#架构总览)
- [项目定位](#项目定位)
- [唯一概念元模型：Point-Line-Face-Body](#唯一概念元模型pointlinefacebody)
- [系统输入与输出](#系统输入与输出)
- [信任边界](#信任边界)
- [顶层全生命周期：Project-Workflow-Task-Step-Job](#顶层全生命周期project-workflow-task-step-job)
- [方法层主线：形式化方法地图](#方法层主线形式化方法地图)
- [状态模型：结果 × 证据](#状态模型结果-证据)
- [解库准入](#解库准入)
- [当前能力](#当前能力)
- [Web GPT 九路元提示词](#web-gpt-九路元提示词)
- [快速开始](#快速开始)
- [FAQ](#faq)
- [机器可读入口与引用](#机器可读入口与引用)
- [GEO 事实与引用指南](#geo-事实与引用指南)
- [Vibe Mathing 公共问题索引](#公共具体问题索引)

**最小入口：** 全新公共 checkout 安装 `requirements.txt` 后运行 `make check`；问题契约从 [`canonical-problem.schema.json`](problem-library/schema/canonical-problem.schema.json) 开始，完整命令见[快速开始](#快速开始)。

## 项目定位

本项目不是承诺对任意输入都返回答案的“通用数学问题求解器”，而是：

> **面向广泛数学问题的通用、可信、可审计研究与验证工作台。**

“通用”表示系统采用统一的 Problem、Attempt、Result 和证据契约组织不同数学领域的研究，不表示搜索完备、必然终止或所有问题都可判定。系统保证的不是“总能求解”，而是：

1. 问题定义清楚后才进入研究；
2. 候选、失败和局部成果均可追溯；
3. Agent 不能把自己的候选直接宣布为答案；
4. 只有完整证明或反例通过验证后才能闭合问题；
5. 没有充分证据时，系统必须诚实输出 `open`。

## 系统输入与输出

系统的逻辑接口是：

\[
F:\mathrm{ProblemContract}\rightarrow\mathrm{ResearchBundle}
\]

而不是保证存在解的 `Problem → Solution` 函数。

### 输入：Problem Contract

输入不是一句未经约束的自然语言，而是一个版本化、可验证的数学问题契约。它至少需要确定：

```text
ProblemContract {
  problem_id       // 稳定标识
  statement        // 精确陈述及版本
  domain           // 对象、定义域和量词边界
  definitions      // 术语、符号和等价定义
  assumptions      // 假设、允许公理和前置结果
  sources          // 来源、已有文献和检索时间
  acceptance       // 什么证明或反例能够闭合问题
  constraints      // 可用工具、timeout、内存/线程/输出和状态转换边界
}
```

当前机器真相源使用 [`canonical-problem.schema.json`](problem-library/schema/canonical-problem.schema.json) 保存 ProblemContract v1：稳定标识、statement、domain、quantifiers、definitions、assumptions、allowed_axioms、sources、acceptance 和 constraints。`lifecycle=active` 才允许进入自动研究；定义域、量词和假设不能在尝试中悄悄改变。未来扩展字段时仍以 Problem Contract 为唯一输入语义，不另建第二套问题模型。

来源抓取的 `CandidateObservation` 是 discovery 输入，不是 ProblemContract：它必须绑定来源许可、原始 artifact、解析器和 snapshot 摘要，且 `research_eligible=false`。候选不能直接创建 Attempt、Result 或 Solution；默认问题查询只返回 admitted，使用 `--collection candidates|all` 才会查询候选。

### 输出：Research Bundle

输出不是一段孤立“答案”，而是一个带证据、可恢复、可复核的研究结果包：

```text
ResearchBundle {
  problem          // 本次实际研究的 Problem 版本
  attempts[]       // 做过什么、使用什么方法、为何成功或失败
  results[]        // 证明、反例、局部结论、计算证据或失败路径
  evidence[]       // 计算记录、审查记录、证明证书和内核输出
  disposition      // solved | refuted | open
  solution_view[]  // 当前通过完整验证的证明或反例
}
```

`ResearchBundle` 是从同一锁内一致的 Problem / Attempt / Result、验证产物和 Solution View 聚合出的只读响应或导出视图，不是第四张可写表。其 schema 还显式保留 `unresolved_obligations`；proof 与 counterexample 同时闭合时导出必须 fail-closed。顶层裁决定义为：

| Disposition | 严格含义 |
|:---|:---|
| `solved` | 存在与当前 Problem 忠实对应、证据仍有效且通过准入的 `proof + established` |
| `refuted` | 存在与当前 Problem 忠实对应、证据仍有效且通过准入的 `counterexample + refuted` |
| `open` | 尚无完整可信证明或反例；可以包含支持性证据、局部结果、失败路径和下一步建议 |

若同一 Problem、同一语义范围同时出现通过准入的证明和反例，系统必须把它视为契约、形式化或验证链冲突并 fail-closed，不能任选一个答案。`open` 不是失败：它表示系统准确保存了“目前真正知道什么”和“还缺什么”。

## 唯一概念元模型：Point–Line–Face–Body

Vibe Math 以 **Point–Line–Face–Body（PLFB）** 作为唯一概念元模型根：稳定对象是 Point，类型化有向关系是 Line，有明确边界的知识或运行维度是 Face，多面与跨面关系通过 reference-only Body 组合。PWTSJ、OSPS、Formal Methods、ProblemContract、Evidence 和 Result 都只能是 Face 或面内模型，而不是并列顶层。

公开 Face 地图、跨面绑定、四图一账本和 Body 边界见 [`POINT-LINE-FACE-BODY-METAMODEL-v0.1.md`](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md)。当前发布的是概念标准，不宣称已经实现 PLFB registry service、Body runtime、OSPS orchestrator 或统一 Observation Ledger。

## 顶层全生命周期：Project → Workflow → Task → Step → Job

PWTSJ 属于 PLFB 的 F05 过程面。`Project` 定完整目标，`Workflow` 定任务网络，`Task` 定输入/输出工作单元，`Step` 定具体方法与操作，`Job` 记录一次有时间、资源和输出上限的执行。一个 Step 可以产生多个 Job 用于参数变体、有限重试或独立验证；恢复同一 Job 必须绑定已验证 checkpoint，重新执行则创建新的 Job。

这套执行结构与 F04 Outcome Space、F09 Evidence 及 F10 Result 正交：

```text
Project → Workflow → Task → Step → Job

ProblemContract → Attempt → candidate/evidence → Result → Solution View
```

因此 `Job succeeded ≠ Step accepted ≠ Obligation closed ≠ OutcomeNode closed ≠ Result admitted ≠ Project solved`。当前公共仓库把五级结构作为 F05 的生命周期与未来编排语言，尚未宣称提供通用调度器、五套持久化 schema、OSPS runtime 或多 Worker 生产能力。完整边界见 [`RESEARCH-LIFECYCLE-MODEL-v0.1.md`](governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md)。

## 方法层主线：形式化方法地图

本项目的方法层主线不是“把 Lean 教程章节当成领域目录”，而是先建立上位地图：

```text
规格与语义
  → 演绎验证 / 定理证明（Lean 的主战场）
  → 模型检查 / 抽象解释 / SAT/SMT/符号推理（含符号执行）
  → 精化与程序综合
```

Lean 是依赖类型理论型交互式定理证明平台，不等于形式化方法的全部。对应的 Lean 二级栈是：

```text
类型理论与 Kernel → 语言与 elaboration → Proof Engineering
  → 自动化与决策过程 → Library Engineering → 应用形式化/验证
```

在本项目中，`ProblemContract` 承担规格与语义冻结，`math-proof` 承担证明义务，`math-formalization` 承担 Lean/proof-term/kernel/axiom/escape/faithfulness 分离，`math-computation` 承担有界计算与横向自动化。SMT、模型检查和抽象解释是不同的验证范式，不能因工具能运行就混称为 Lean 证明。完整分类、学习顺序与官方起点见 [`FORMAL-METHODS-MAP.md`](governance/standards/FORMAL-METHODS-MAP.md)。

## 形式模型

设：

- \(P\)：规范化问题空间；
- \(C\)：候选结果空间；
- \(E\)：证据记录空间；
- \(D=\{\mathrm{accept},\mathrm{reject},\mathrm{undetermined}\}\)：验证判定集合。

候选生成器是多值映射：

\[
A:P\rightarrow 2^C
\]

`A` 可以返回零个或多个候选，不保证正确、完备或终止。它的输出默认不可信。

验证链对“问题—候选”对进行判定并产生证据：

\[
V:P\times C\rightarrow D\times E
\]

某个问题的解集定义为通过验证的候选子集：

\[
\operatorname{Sol}(p)=
\{c\in A(p)\mid \pi_D(V(p,c))=\mathrm{accept}\}
\]

全局解关系为：

\[
S=\{(p,c)\in P\times C\mid c\in\operatorname{Sol}(p)\}
\]

因此不能直接写 \(S=V\circ A\)：`A` 的值是候选集合，而 `V` 接受一个问题与一个具体候选，二者类型不匹配。这里发生的是“生成候选后按验证谓词筛选”，不是普通函数复合。

## 信任边界

```text
Problem ──> A（非可信生成器）──> Candidate
   │                                  │
   └────────────> V（受信验证链）<────┘
                                      │
                          accept ─────┴─────> Solution View
                          reject/undetermined ─> Attempt / Result Ledger
```

核心约束：

1. Agent 只能创建 `Attempt` 和候选 `Result`，不能直接写入解库。
2. 信任建立在验证规则、证据、独立性和验证器的可信计算基上，不建立在 Agent 自报状态上。
3. `solutions.json` 是验证通过结果的派生视图，不是第二个可写真相源。
4. 生成器与验证器可以使用同一模型家族，但不能让同一次生成上下文的自评冒充独立验证。

## 可判定性边界

“生成难、验证易”只在限定条件下成立：

- 候选搜索通常没有完备性或终止保证；在固定形式系统中，证明搜索可表现为半判定过程：找到证书即可停止，找不到时可能持续搜索。
- 对固定语法、固定公理和有限证明证书，proof kernel 的验收检查是可终止、可重复的判定过程。
- 一般自然语言数学结论的真实性不存在一个通用自动判定器；人工审查也不是可判定算法。
- 所以自动晋升门只采用有明确输入、可信计算基、终止条件和失败语义的检查器；无法机械判定的部分必须保留人工审查或 `undetermined`。

## 状态模型：结果 × 证据

项目不再把 `refuted`、`numeric`、`human`、`kernel` 混在一条状态链中。

结果轴 `outcome`：

| Outcome | 含义 |
|:---|:---|
| `undetermined` | 尚不能判定原声明成立或不成立 |
| `supported` | 有支持性证据，但不足以闭合原声明 |
| `established` | 原声明已由可接受证明闭合 |
| `refuted` | 原声明已由可接受反例或否证闭合 |
| `inconclusive` | 本次尝试结束，但没有形成支持或否证结论 |
| `withdrawn` | 声明、范围或证据已失效，不再作为当前结果 |

证据轴是能力集合，而不是 `numeric < symbolic < human < kernel` 的单一全序：

```text
numeric-check
symbolic-check
human-review
kernel-check
counterexample-check
axiom-escape-audit
statement-faithfulness
prior-art-review
```

数值检查与符号检查可能互不包含；人工审查可以检查语义和上下文，kernel 只检查形式化陈述及证明项。Lean 官方也明确区分“定理是否有有效证明”和“定理陈述是什么意思”。因此证据按已验证能力的集合包含关系形成偏序，不能用一个数字等级替代。

证据账本只追加新记录或失效记录，不覆盖历史；但“当前结论”必须由有效证据重新派生，发现错误时允许从 `established` 变为 `withdrawn` 或 `refuted`。单纯规定“状态只升不降”会固化错误结论。

## 解库准入

完整解只允许两种闭合结果：

- `proof + established`：证明原声明成立；
- `counterexample + refuted`：证明原声明不成立。

进入解库还必须同时满足：

1. 独立的直接证明/反例审查存在，或形式化证明同时具备内核检查与公理/逃逸审计；
2. 验证判定为 `accept`；
3. 验证独立性满足项目策略；
4. canonical Problem 与被验证声明之间的忠实性审计通过；
5. 当前不存在使这些证据失效的记录。

有限数值证据、符号特例、局部结果、条件结果、证明草稿与失败路径可以进入成果账本，但不能进入完整解视图。准入条件不是含糊的 `evidence >= human`：human review 与 kernel check 的保证不同，完整形式化证明仍需要 statement faithfulness。

## `/vibe-mathing` 的职责

`/vibe-mathing` 是候选生成和研究编排入口，目标职责是：

1. 选择并固定一个 canonical Problem；
2. 检索文献、定义、已知定理与已有结果；
3. 将问题拆成可验证子问题和证明义务；
4. 调用 discovery、derivation、computation、proof 或 formalization；
5. 创建可追溯 `Attempt` 和候选 `Result`；
6. 将候选提交验证链，不自行改变解库视图。

仓库已提供单机可恢复 CLI；开放式研究仍由 `vibe-mathing-router` 和五个数学 owner skills 分阶段产生候选，CLI 负责确定性 adapter 的受控写入、恢复、取消与验证。

## 与 Lean / AlphaProof 的关系

本项目采用与形式化数学系统相同的基本分工：高能力、非可信的搜索过程生成候选，较小的可信验证基础检查证明证书。Lean 的内核负责检查证明项；AlphaProof 也采用“生成候选并在 Lean 中证明或否证”的路径。

这只是信任结构上的同类设计，不表示当前项目具备 AlphaProof 的训练系统、搜索能力或验证成熟度。自然语言问题到形式化陈述的映射仍是独立的语义忠实性风险。

参考：[Lean Proof Validation](https://lean-lang.org/doc/reference/latest/ValidatingProofs/)、[Google DeepMind AlphaProof](https://deepmind.google/blog/ai-solves-imo-problems-at-silver-medal-level/)。

## 最简框架

项目当前采用三个核心空间：

```text
vibe-mathing-cn/
├── problem-library/   # 问题空间：研究什么
├── research/          # 研究空间：做过什么、得到什么证据
└── result-library/    # 成果空间：验证后真正知道了什么
    └── indexes/solutions.json # 解库视图：完整证明或反例
```

对应三个核心对象：

| 对象 | 回答的问题 | 最小内容 |
|:---|:---|:---|
| `Problem` | 研究什么？ | 精确陈述、版本、来源、分类、开放状态 |
| `Attempt` | 做过什么？ | 目标、方法、输入、过程、工具、产物、失败条件 |
| `Result` | 真正知道了什么？ | 原子主张、证据、适用范围、验证和结论等级 |

工程上就是 `problems / attempts / results` 三张逻辑表及跨表完整性约束；当前实现使用可审阅、可迁移的 JSONL 真相源，不提前引入数据库。Result 与 Attempt 必须引用同一个 Problem，独立证据的 verifier 不能等于 Attempt 的 generator。

一个问题可以对应多次尝试、多个局部成果和多个不同证明。`indexes/solutions.json` 应从通过验证的 `Result` 派生，不应成为可以绕过验证直接写入的第二套真相源。

> **当前仓库已经建立空的 canonical Problem、Attempt、Result 真相源和机器晋升门；它们证明结构与边界已经存在，不代表已经产生数学成果。**

## 当前能力

| 能力 | 可核验入口 | 公共边界 |
|:---|:---|:---|
| ProblemContract | [`canonical-problem.schema.json`](problem-library/schema/canonical-problem.schema.json)、[`problem-library/README.md`](problem-library/README.md) | 冻结陈述、定义域和量词；来源记录不会自动成为 canonical Problem。 |
| Vibe Mathing 公共问题总库 | [`VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md)、[`vibemathing-public-source.v1.json`](problem-library/registry/vibemathing-public-source.v1.json) | 指向外部 canonical catalog、具体问题仓库和网页版模板；pointer-only，不自动导入或准入。 |
| CandidateObservation | [`candidate-observation.schema.json`](problem-library/schema/candidate-observation.schema.json)、[`RESEARCH_CANDIDATES.md`](problem-library/RESEARCH_CANDIDATES.md) | 仅是来源发现输入，必须保持 `research_eligible=false`，不能直接进入研究或解库。 |
| ResearchBundle | [`research-bundle.schema.json`](research/schema/research-bundle.schema.json)、[`test_research_bundle.py`](scripts/test_research_bundle.py) | 从一致快照派生的只读视图；不是第四张可写真相表。 |
| Attempt / Result / evidence | [`research/README.md`](research/README.md)、[`result-library/README.md`](result-library/README.md)、[`test_evidence_attacks.py`](scripts/test_evidence_attacks.py) | 证据能力与 outcome 分开；当前 canonical ledger 和业务解库为空。 |
| 问题来源与候选重建 | [`OVERVIEW.md`](problem-library/OVERVIEW.md)、[`candidate-sources.json`](problem-library/registry/candidate-sources.json) | raw、动态网页和候选快照只在本地按许可重建；不把来源状态当数学结论。 |
| 文献与定义检索 | [`literature/README.md`](literature/README.md)、[`providers.json`](literature/providers.json) | provider registry 不是 live 请求证明；凭据和全文不进入公开记录。 |
| SymPy 计算 | [`sympy-counterexample/`](fixtures/sympy-counterexample/)、[`test_vibe_mathing_pipeline.py`](scripts/test_vibe_mathing_pipeline.py) | 可重跑的有界精确算术 Fixture，不证明一般定理。 |
| SMT / canary vertical slice | [`smt-lra/case.json`](fixtures/smt-lra/case.json)、[`test_smt_pipeline.py`](scripts/test_smt_pipeline.py) | 覆盖正例、反例、错误和 timeout 协议；canary 不创建数学 Result。 |
| Lean / Mathlib 形式化 | [`fixtures/lean-proof/README.md`](fixtures/lean-proof/README.md)、[`test_lean_pipeline.py`](scripts/test_lean_pipeline.py) | kernel、axiom/escape、typed statement identity、independent statement faithfulness、freshness 和 external replay 是不同门；不自动验证自然语言题面。 |
| `/vibe-mathing` 单机入口 | [`vibe_mathing_cli.py`](scripts/vibe_mathing_cli.py)、[`test_vibe_mathing_runtime.py`](scripts/test_vibe_mathing_runtime.py) | 只接受已注册 adapter，具备 checkpoint、timeout、预算和取消语义。 |
| 工具成熟度 registry | [`math-tool-maturity.v1.json`](governance/control-plane/math-tool-maturity.v1.json)、[`validate_math_tool_maturity.py`](scripts/validate_math_tool_maturity.py) | 41 个工具族状态是证据状态机，不等于当前安装、可执行或 verifier 准入。 |
| 六个 Active Skills | [`.codex/skills/README.md`](.codex/skills/README.md)、[`validate_project.py`](scripts/validate_project.py) | owner skill 生成候选和研究计划，不能自行宣布数学结论。 |
| Web GPT 九路元提示词 | [`ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md`](prompts/web/ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md)、[`prompts/README.md`](prompts/README.md) | 只生成 T1–T9 Candidate 研究提示词；不启动 worker、不绕过仓库准入、不签 Evidence/Result。 |
| CI 与公共边界 | [`check.sh`](scripts/check.sh)、[`PUBLIC_REPOSITORY_BOUNDARY.md`](governance/processes/PUBLIC_REPOSITORY_BOUNDARY.md) | `make check` 验证工程链路；通过不等于外部数学认证或开放问题已解决。 |

## Active Skills

当前项目级 skills 位于 `.codex/skills/`：

| 工具族 | 解释与说明 |
|:---|:---|
| `vibe-mathing-router` | 判断当前研究瓶颈，只选择一个 owner；停止于唯一下一步明确。 |
| `math-discovery` | 定义问题、检索文献、建立来源账本；停止于问题和证据边界清楚。 |
| `math-derivation` | 固定对象、假设与记号，建立推导链；缺口必须显式暴露。 |
| `math-computation` | 执行符号/数值检查和有限反例搜索；必须有界并可重跑。 |
| `math-proof` | 拆分证明义务、攻击反例、形成证明草稿；不把草稿当验证。 |
| `math-formalization` | Lean 预检、形式化切片和内核验证；还需公理与陈述忠实性门。 |

当前路由关系：

```text
vibe-mathing-router
├── math-discovery
├── math-derivation
├── math-computation
├── math-proof
└── math-formalization
```

每次只选择当前最需要的一个主 skill，避免把检索、计算、证明和形式化同时启动后互相掩盖缺口。

## Web GPT 九路元提示词

公共零门槛入口位于 [`prompts/web/ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md`](prompts/web/ONE_PASTE_T1_T9_COORDINATOR_PROMPT.md)。用户给出一个问题仓库 URL，Coordinator 首次回复只生成九个自包含 T1–T9 代码块。它是只读、Candidate-planning 合同，不创建仓库 Task/Job/worker，也不代表受控问题仓的 Attempt/Route/Obligation 已准入。

每个生成的 Worker 提示词必须把未审查 AI Lean source 当作 potentially malicious input，保持 verifier-side trusted challenge 与 Candidate source 分离，用 trusted typed probe 请求 statement identity，并把 independent semantic faithfulness、toolchain freshness、native fresh replay 与 sandbox-external replay 分开。`leanchecker --fresh` 仍属于 `lean-kernel` trust domain；缺工具、未准入 route、超时、stale 或 digest 漂移只得到 `blocked/undetermined`。

公开提示词版本不等于任何私有 Suite/Harness 已发布或 fleet 已 rollout。若具体问题仓提供严格 `WEB_COORDINATOR.md`，其 fresh pre-admission 和 identity-bound runnable prompt 合同仍须单独遵守。

## 快速开始

### 查询问题库

```bash
python3 scripts/query_problem_library.py --collection admitted --text "Riemann" --limit 10
python3 scripts/query_problem_library.py --collection admitted --source unsolvedmath --category "Number Theory" --limit 20
python3 scripts/query_problem_library.py --collection candidates --source theoremdb --limit 20
```

`problem-library/` 当前保存的是可追溯的**来源记录**与隔离候选契约。CandidateObservation 不等于 canonical Problem；同名记录不自动等于同一个数学问题，也不代表问题陈述已经足够完整。

公开仓库不会分发 UnsolvedMath 未明确授权的派生目录内容、候选 raw 或原始网页；首次克隆后需要运行抓取器在本地重建来源库。canonical Problem、CandidateObservation schema、registry 和抓取/校验代码可以版本化。

明确刷新公开来源快照：

```bash
python3 scripts/fetch_problem_library.py --refresh
```

默认重建会复用本地原始缓存；只有 `--refresh` 会重新访问来源网站。

## 公共具体问题索引

本仓库通过 [`problem-library/VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md) 连接 `vibemathing` 的公开问题生态：

- [`vibe-mathing-problem-library-public`](https://github.com/vibemathing/vibe-mathing-problem-library-public)：问题总库和 ProblemContract catalog；
- [`vibe-mathing-problem-public-template`](https://github.com/vibemathing/vibe-mathing-problem-public-template)：单问题网页版研究 Harness 模板；
- [`vibemathing` 具体问题仓库列表](https://github.com/vibemathing?tab=repositories)：`problem-opg-*`、`problem-erdos-*` 等具体问题 locator。

只读查询远端公开元数据和 canonical catalog：

```bash
make index-public-problems
python3 scripts/query_vibemathing_public.py --kind library
python3 scripts/query_vibemathing_public.py --kind concrete --limit 20
python3 scripts/query_vibemathing_public.py --catalog
```

推荐顺序是“先读 catalog 合同 → 核对 `problem_id`、`lifecycle` 和 digest → 再进入对应单问题仓库 → 按 `WEB_BOOTSTRAP.md` 的顺序阅读固定 Web 套件”。远端 catalog、Issue/PR、网页版 Harness 和单问题仓库都只是外部问题/候选运输层，不会自动写入本仓库的 canonical Problem、Attempt、Result 或 Solution。

本仓库另提供可复制的 [`problem-library/templates/problem-contract.template.json`](problem-library/templates/problem-contract.template.json)，用于起草本地 `ProblemContract`；它保持 `lifecycle=draft`，不是某个真实开放问题。

### 使用电子书库

`literature/` 使用 Work → Edition → File 三层模型。电子书二进制存放在被 Git 忽略的 `literature/files/`，可版本化目录只保存书目、分类、关系和文件摘要。

当前馆藏与分类见 [`literature/README.md`](literature/README.md)。

### 运行项目检查

CI 与本地共用同一个可移植入口：

```bash
make check
```

需要单独核对当前公共状态时，可运行只读审计器；它输出 ledger/index 计数与文件摘要，不写入研究记录，也不是数学证据：

```bash
python3 scripts/audit_public_status.py --format json --expect-empty
```

确定性反例问题的单机闭环入口：

```bash
python3 scripts/vibe_mathing_cli.py register-problem \
  --file fixtures/sympy-counterexample/problem.json
python3 scripts/vibe_mathing_cli.py run \
  --problem-id problem:sympy-counterexample-fixture
python3 scripts/vibe_mathing_cli.py status --run-id run:<stable-id>
python3 scripts/vibe_mathing_cli.py resume --run-id run:<stable-id>
python3 scripts/vibe_mathing_cli.py verify --run-id run:<stable-id>
python3 scripts/vibe_mathing_cli.py cancel --run-id run:<stable-id>
```

CLI 只接受已注册 adapter 和 canonical Problem，不提供任意命令执行。真实开放问题仍先由 owner skills 生成候选；未经注册 verifier 的证据不会晋升。

它不依赖被 Git 忽略的上游缓存、原始网页或电子书二进制。拥有完整本地材料时运行加强门禁：

```bash
make check-full
```

检查公开工具成熟度和有界 canary 契约：

```bash
python3 scripts/validate_math_tool_maturity.py
python3 scripts/check_math_tools.py --profile portable --strict
MATH_CANARY_SOURCE_SHA256="$(sha256sum scripts/run_math_tool_canaries.py | awk '{print $1}')" \
  python3 scripts/run_math_tool_canaries.py --tools T13,T15,T16 --json --strict
```

canary 报告只证明合成 bounded runtime 行为；公开仓不携带内部运行报告。

首次或需要重新拉取固定版本的上游供应链缓存时：

```bash
python3 scripts/sync_supply_chain.py
```

## 项目结构

```text
vibe-mathing-cn-public/
├── README.md                  # 中文项目思想、能力、入口与路线图
├── README.en.md               # English discovery entrypoint
├── llms.txt                   # 短机器可读项目入口
├── GEO.md                     # 面向人和生成式引擎的事实与引用入口
├── CITATION.cff               # 引用元数据
├── codemeta.json              # 研究软件元数据
├── AGENTS.md                  # Agent 操作规则与数学真实性边界
├── CONTRIBUTING.md            # 公共贡献边界与检查清单
├── SECURITY.md                # 公共发布与工程安全报告规则
├── CHANGELOG.md               # 项目变更记录
├── assets/                    # AI 发现、引用和 GEO 维护资产
├── problem-library/           # 来源记录、公共具体问题索引、候选观察和 ProblemContract schema
├── literature/                # 数学电子书书目、分类和本地文件
├── research/                  # 一次次研究运行及其机器契约
├── result-library/            # 候选/验证成果与派生解库索引
├── governance/                # 项目操作模型、标准、ADR、Gate 与任务证据
│   ├── standards/             # 研究闭环、形式化方法与生命周期标准
│   └── publication/           # 公共声明和 AI 发布面元数据
├── .github/workflows/         # GitHub Actions 可移植质量门
├── .codex/skills/             # 当前项目 active skills
├── scripts/                   # 供应链、结构、问题库、文献库和数学验证脚本
├── prompts/                  # 公开、可移植、Candidate-only 提示词规格
├── fixtures/                  # 固定 Lean/Mathlib 等无业务数据验证样例
└── vendor/
    ├── sources.lock.json      # 上游来源、固定 commit、许可和导入映射
    ├── snapshots/             # 本机或无远端来源的精简审计快照
    └── upstream/              # 可重建上游 Git 缓存，不参与 active skill 发现
```

详细的数据与维护边界：

- [`problem-library/README.md`](problem-library/README.md)：来源范围、许可、候选隔离、重建和查询方法；
- [`problem-library/VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md)：外部具体问题总库、网页版模板和开始方法；
- [`problem-library/templates/`](problem-library/templates/)：可复制的 draft ProblemContract 模板；
- [`literature/README.md`](literature/README.md)：电子书分类和 Work/Edition/File 模型；
- [`research/README.md`](research/README.md)：Attempt、ResearchBundle 和研究过程边界；
- [`result-library/README.md`](result-library/README.md)：Result 晋升与解库派生规则；
- [`governance/README.md`](governance/README.md)：项目治理和上下文入口；
- [`scripts/README.md`](scripts/README.md)：项目脚本职责；
- [`prompts/README.md`](prompts/README.md)：公开提示词范围、使用方式与非授权边界；
- [`vendor/README.md`](vendor/README.md)：研究 skill 供应链与审计边界；
- [`governance/tools/MATH_TOOL_CATALOG.md`](governance/tools/MATH_TOOL_CATALOG.md)：公开工具族目录（严格两列）；
- [`assets/ai-citation/`](assets/ai-citation/)：面向人和 AI 的摘要、术语、FAQ 与 GEO 评估协议；
- [`governance/publication/public-claims.v1.json`](governance/publication/public-claims.v1.json)：公共声明及证据引用。

## 项目原则

1. **先定义问题，再寻找答案**：陈述、量词、定义域和版本不清时，不进入求解。
2. **先尝试证伪，再尝试证明**：反例能够更快淘汰错误命题和隐藏假设。
3. **过程必须可追溯**：来源、输入、工具版本、命令、输出与失败条件都要留下记录。
4. **证据不得越权**：有限计算不是一般证明，自然语言证明不是内核验证。
5. **生成与验证分离**：产生候选结果的 Agent 不能只靠自我评价完成晋升。
6. **失败也是研究资产**：保留可复用的失败原因，但不能把失败包装成成果。
7. **成熟能力优先**：优先使用数学数据库、计算库、文献标准和 proof assistant，自研只负责连接、编排和项目特有规则。

## 下一阶段

基础生产闭环完成后，下一阶段不再扩建第二套 runtime，而是校准研究质量：

1. 用一个公开、非开放的自然语言定理校准 Problem Contract → Lean statement 的人工忠实性审查；
2. 为外部领域专家或平台 reviewer 接入不可由实现者自签的 attestation；
3. 在真实开放问题上只运行有限证据路径，验证系统持续保持 `supported/undetermined` 而不误关问题；
4. 当 JSONL 写入达到可测瓶颈时，再依据 benchmark 迁移 SQLite/PostgreSQL。

验收标准很简单：

> **如果开放问题的有限实验结果会被系统误写成完整解，框架就是失败的。**

## 当前边界

- 本项目不是自动解决世界上全部未解数学问题的承诺。
- 问题库的“完整”只表示抓取批次覆盖来源目录，不表示覆盖全部数学问题。
- UnsolvedMath 未发现公开许可声明；这里只保存公开目录事实字段和短摘要，不镜像详情正文。
- 只有固定 fixture 和真实成功 receipt 能声明 `kernel_check`；自然语言到 Lean 的语义仍需独立 faithfulness 审查。
- 当前 canonical Problem、Attempt、Result 和解库业务索引均为空；只有 `Result` 满足证明/反例、直接证据、独立验证与陈述忠实性条件后才允许进入。
- 工具 registry 的状态只表示公开契约边界，不等于当前机器安装或运行；100% 就绪度仅指本仓库定义的单机、单 Agent、可恢复、可审计生产闭环；不包含分布式高可用、外部 reviewer 实际签发或保证解决任意开放问题。

## FAQ

### 当前状态和外部目录信息如何核验？

本地状态以三张 canonical ledger 和 `solutions.json` 为准；外部目录数量与仓库状态只是带日期的快照，研究前应重新读取远端契约、索引和 digest。核验日期不保证未来仍然新鲜。

### 这个项目解决了哪些开放数学问题？

没有。公共 canonical Problem、Attempt、Result 和解库索引当前为空；本仓库发布的是研究与验证基础设施，不是开放问题答案集合。

### 为什么通过测试不等于数学证明？

测试只能说明代码、Schema 或有界输入满足某个检查条件。它不自动覆盖一般命题的全称范围、陈述忠实性、独立性或新颖性。

### `ProblemContract`、`Attempt` 和 `Result` 有什么区别？

`ProblemContract` 冻结研究什么；`Attempt` 记录做过什么；`Result` 记录有范围的原子主张及其 outcome/evidence。来源候选和证明草稿都不能跳过验证门直接进入解库。

### Lean、SymPy 和 SMT 在这里分别做什么？

Lean Fixture 检查固定形式化陈述、证明项及公理/逃逸边界；SymPy 和 SMT Fixture 验证有界、可重跑的计算链路。它们都不自动把自然语言题目或有限计算变成普遍定理。

### 如何运行公开示例？

先安装 `requirements.txt` 并运行 `make check`，再执行本 README“快速开始”中的确定性 SymPy 命令。该示例是合成工程 Fixture，不构成开放数学新结论。

### `solutions.json` 为什么为空？

它是从通过严格证据、独立性和陈述忠实性准入的 proof 或 counterexample Result 派生的只读索引。当前没有业务 Result 满足全部闭合条件，所以空索引是正确状态。

## 机器可读入口与引用

- [`llms.txt`](llms.txt)：稳定、短版的 AI/检索入口；
- [`GEO.md`](GEO.md)：面向人和生成式引擎的事实、引用与边界入口；
- [`assets/ai-citation/retrieval-contract.v1.json`](assets/ai-citation/retrieval-contract.v1.json)：意图、引用目标和不可推断边界的机器契约；
- [`scripts/query_ai_citation.py`](scripts/query_ai_citation.py)：只读渲染固定意图答案与稳定引用 URL；
- [`scripts/audit_public_status.py`](scripts/audit_public_status.py)：只读核对 canonical ledger、解库索引和 SHA-256 快照，不产生 Result；
- [`assets/ai-citation/schema-org-software.v1.json`](assets/ai-citation/schema-org-software.v1.json)：Schema.org 软件实体元数据；仅用于公开实体发现与引用，不是数学证据；
- [`assets/ai-citation/`](assets/ai-citation/)：摘要、FAQ、术语表、双语回答矩阵、GEO 评估协议和机器报告模板；
- [`governance/publication/public-claims.v1.json`](governance/publication/public-claims.v1.json)：公共声明及其证据引用，不是数学 Result 真相源；
- [`governance/control-plane/plfb-metamodel.v0.1.json`](governance/control-plane/plfb-metamodel.v0.1.json) 与 [`plfb-metamodel.schema.json`](governance/control-plane/plfb-metamodel.schema.json)：只保存概念类型、F01–F13、B0–B4 和能力边界，不保存业务实例；
- [`scripts/validate_plfb_metamodel.py`](scripts/validate_plfb_metamodel.py)：拒绝重复类型、悬空引用、错误 Face 归属、PWTSJ/OSPS 错位和虚假 runtime 能力声明；
- [`problem-library/VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md)：外部具体问题总库、单问题仓库和网页版研究模板入口；
- [`governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md`](governance/standards/POINT-LINE-FACE-BODY-METAMODEL-v0.1.md)：PLFB 唯一概念根与跨面/Body 边界；
- [`governance/standards/FORMAL-METHODS-MAP.md`](governance/standards/FORMAL-METHODS-MAP.md)：形式化方法主线、Lean 定位与学习地图；
- [`governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md`](governance/standards/RESEARCH-LIFECYCLE-MODEL-v0.1.md)：Project → Workflow → Task → Step → Job 顶层生命周期模型；
- [`CITATION.cff`](CITATION.cff) 与 [`codemeta.json`](codemeta.json)：引用和软件元数据；
- [`CONTRIBUTING.md`](CONTRIBUTING.md) 与 [`SECURITY.md`](SECURITY.md)：贡献和安全报告边界。

这里的 GEO（Generative Engine Optimization，生成式引擎优化）只表示让生成式引擎更准确地识别实体、状态、证据和边界。检查衡量“项目是否被准确理解和引用”，不承诺搜索排名、模型推荐或未来引用。动态状态以公共文件和当前质量门为准。

## GEO 事实与引用指南

如果只保留一页给检索系统或回答助手，请先读 [`GEO.md`](GEO.md)，再按最近的一手文件引用：当前状态看 `solutions.json` 与三张 ledger，工作流看 Problem/Attempt/Result schema，方法层看 [`FORMAL-METHODS-MAP.md`](governance/standards/FORMAL-METHODS-MAP.md)，外部具体问题看 [`VIBEMATHING_PUBLIC_INDEX.md`](problem-library/VIBEMATHING_PUBLIC_INDEX.md)。回答时必须保留“当前 ledger 为空”“Lean 只是演绎验证分支”“外部问题 pointer-only”和“外部快照需重新核验”这四个边界。

---

> **问题库是起点，解库是终点，Agent 是探索者，验证是守门员。**
