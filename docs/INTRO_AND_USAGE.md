# 仓库介绍与使用说明

本文档基于代码梳理，提供本仓库的**项目介绍**、**代码结构**与**使用说明**，便于快速了解与上手。快速入门请参考 [README.md](../README.md)，完整配置见 [完整配置与部署指南](full-guide.md)。

---

## 一、仓库介绍

### 1.1 项目定位

**daily_stock_analysis** 是一个基于 AI 大模型的 **A 股 / 港股 / 美股自选股智能分析系统**，主要能力包括：

- **每日自动分析**：对自选股执行技术面、筹码、舆情、实时行情等多维度分析，并生成「决策仪表盘」式报告。
- **多渠道推送**：将分析结果推送到企业微信、飞书、Telegram、钉钉、邮件、Pushover、Discord 等。
- **大盘复盘**：按交易日生成市场概览、板块涨跌，支持 A 股 / 美股 / 双市场切换。
- **Agent 策略问股**：多轮策略对话，支持均线金叉、缠论、波浪理论等 11 种内置策略，可通过 Web、Bot、API 触发。
- **回测验证**：对历史分析结果做准确率评估（方向胜率、止盈止损命中率等）。

运行方式支持：**GitHub Actions 定时执行**（零服务器）、**本地/Docker 部署**、**Web 管理界面**、**Bot 命令触发**。

### 1.2 技术栈与数据来源


| 类型    | 支持                                                                  |
| ----- | ------------------------------------------------------------------- |
| 运行环境  | Python 3.10+                                                        |
| 后端    | FastAPI，SQLite（可选迁移其他 DB）                                           |
| 前端    | React（Vite），位于 `apps/dsa-web`                                       |
| AI 模型 | AIHubMix、Gemini、OpenAI 兼容、DeepSeek、通义千问、Claude、Ollama、LiteLLM Proxy |
| 行情数据  | AkShare、Tushare、Pytdx、Baostock、efinance、YFinance（美股/美股指数）           |
| 新闻搜索  | Tavily、SerpAPI、Bocha、Brave                                          |


### 1.3 内置交易纪律

- **严禁追高**：乖离率超过阈值（默认 5%，可配置）自动提示风险；强势趋势股自动放宽。
- **趋势交易**：MA5 > MA10 > MA20 多头排列。
- **精确点位**：买入价、止损价、目标价。
- **检查清单**：每项条件以「满足 / 注意 / 不满足」标记。
- **新闻时效**：可配置新闻最大时效（默认 3 天），避免使用过时信息。

---

## 二、代码结构

### 2.1 目录概览

```
daily_stock_analysis/
├── main.py                 # 主入口：CLI 解析、调度模式（单次/定时/回测/仅大盘/Web 服务）
├── analyzer_service.py     # 兼容入口（可选）
├── webui.py                # WebUI 兼容入口（可选）
├── requirements.txt       # Python 依赖
├── pyproject.toml         # 项目元数据与工具配置
├── .env.example            # 环境变量模板（复制为 .env 后配置）
│
├── src/                    # 核心业务逻辑
│   ├── config.py           # 配置加载与校验（从 .env 等）
│   ├── analyzer.py         # AI 分析器（GeminiAnalyzer，多厂商 LLM 适配）
│   ├── stock_analyzer.py   # 趋势分析（MA 多头排列、乖离率等）
│   ├── notification.py    # 多渠道推送（企业微信/飞书/邮件/Telegram 等）
│   ├── search_service.py   # 新闻/舆情搜索（Tavily、SerpAPI、Bocha、Brave）
│   ├── storage.py         # SQLite 存储（行情、分析历史、回测结果、会话消息）
│   ├── feishu_doc.py      # 飞书云文档生成
│   ├── auth.py            # Web 登录与密码校验
│   ├── scheduler.py        # 定时任务调度
│   ├── logging_config.py  # 日志配置
│   │
│   ├── core/               # 核心流程与领域
│   │   ├── pipeline.py    # 分析流水线（StockAnalysisPipeline：数据→分析→通知）
│   │   ├── market_review.py   # 大盘复盘
│   │   ├── market_profile.py  # 市场画像（指数、板块）
│   │   ├── trading_calendar.py # 交易日历（A/H/US）
│   │   ├── backtest_engine.py  # 回测引擎
│   │   ├── config_registry.py  # 系统配置项注册（Web 设置页）
│   │   └── config_manager.py   # 配置管理
│   │
│   ├── agent/              # Agent 策略问股
│   │   ├── executor.py    # AgentExecutor（ReAct 循环）
│   │   ├── llm_adapter.py # 多厂商 LLM 适配
│   │   ├── factory.py     # 构建 executor、skill、tool 注册
│   │   ├── tools/         # 工具：行情、K 线、技术指标、新闻等
│   │   └── skills/       # 策略技能（加载 strategies/*.yaml）
│   │
│   ├── repositories/      # 数据访问层
│   │   ├── stock_repo.py
│   │   ├── analysis_repo.py
│   │   └── backtest_repo.py
│   │
│   └── services/           # 应用服务层
│       ├── analysis_service.py   # 分析触发与结果封装
│       ├── history_service.py   # 历史报告查询
│       ├── backtest_service.py  # 回测调度
│       ├── stock_service.py     # 股票列表与从图片提取
│       ├── system_config_service.py # 系统配置读写与校验
│       ├── task_queue.py        # 分析任务队列
│       └── image_stock_extractor.py # 从截图识别股票代码（Vision）
│
├── data_provider/          # 多数据源适配
│   ├── base.py            # BaseFetcher、DataFetcherManager（优先级与故障切换）
│   ├── efinance_fetcher.py
│   ├── akshare_fetcher.py
│   ├── tushare_fetcher.py
│   ├── pytdx_fetcher.py
│   ├── baostock_fetcher.py
│   ├── yfinance_fetcher.py # 美股/美股指数
│   └── us_index_mapping.py # 美股指数代码映射
│
├── api/                    # FastAPI 后端
│   ├── app.py             # 应用工厂、CORS、静态文件、生命周期
│   ├── deps.py            # 依赖注入
│   ├── middlewares/       # 认证、错误处理
│   └── v1/
│       ├── router.py      # 聚合 v1 路由（/api/v1/...）
│       ├── endpoints/    # auth, agent, analysis, history, stocks, backtest, system_config
│       └── schemas/      # Pydantic 模型
│
├── bot/                    # 机器人命令与平台适配
│   ├── models.py          # BotMessage、BotResponse 等
│   ├── dispatcher.py      # 命令分发
│   ├── handler.py         # Webhook 入口
│   ├── commands/          # /analyze, /market, /batch, /help, /status, /chat, /ask
│   └── platforms/         # 飞书、钉钉、企业微信、Telegram、Discord 等
│
├── strategies/             # Agent 策略 YAML（自然语言，无需写代码）
│   ├── README.md          # 策略编写说明
│   └── *.yaml             # bull_trend, ma_golden_cross, volume_breakout 等
│
├── apps/
│   ├── dsa-web/           # React 前端（Vite）
│   └── dsa-desktop/       # 桌面端 Electron 壳
│
├── scripts/               # 构建与运行脚本（后端/前端/桌面）
├── tests/                 # 单元测试
├── docs/                  # 文档（本文件、FAQ、CHANGELOG、部署等）
└── .github/workflows/     # CI、每日分析、自动打 tag 等
```

### 2.2 核心流程简述

1. **主入口**：`main.py` 解析命令行（如 `--webui`、`--backtest`、`--market-review`、`--stocks` 等），根据模式决定是启动 Web 服务、定时任务、单次分析、仅大盘复盘或回测。
2. **分析流水线**：`StockAnalysisPipeline`（`src/core/pipeline.py`）协调：
  - 通过 `DataFetcherManager` 拉取行情与筹码数据；
  - 使用 `StockTrendAnalyzer` 做趋势判断；
  - 使用 `SearchService` 拉取新闻/舆情；
  - 调用 `GeminiAnalyzer` 生成决策仪表盘；
  - 通过 `NotificationService` 推送；
  - 可选写入飞书云文档、触发自动回测。
3. **交易日过滤**：非交易日（按 A/H/US 日历）可跳过执行，可用 `--force-run` 或 `TRADING_DAY_CHECK_ENABLED=false` 覆盖。
4. **Agent 问股**：当 `AGENT_MODE=true` 时，单股分析可走 Agent 分支（`AgentExecutor` + 策略 YAML + 工具调用），Web/Bot/API 共用同一套 Agent 能力。

---

## 三、使用说明

### 3.1 环境要求

- **Python**：3.10+
- **Node.js**：若使用 Web 界面或需本地构建前端，需安装 npm（用于 `apps/dsa-web`）
- **配置**：复制 `.env.example` 为 `.env`，按需填写（见 [完整配置指南](full-guide.md) 或 `.env.example` 内注释）

### 3.2 安装

```bash
git clone https://github.com/ZhuLinsen/daily_stock_analysis.git
cd daily_stock_analysis
pip install -r requirements.txt
cp .env.example .env
# 编辑 .env，至少配置：STOCK_LIST、至少一种 AI Key、至少一种通知渠道
```

### 3.3 运行方式


| 方式       | 命令                                             | 说明                                  |
| -------- | ---------------------------------------------- | ----------------------------------- |
| 单次分析     | `python main.py`                               | 使用 `.env` 中的 `STOCK_LIST` 执行一次分析并推送 |
| 指定股票     | `python main.py --stocks 600519,300750`        | 仅分析指定代码，覆盖配置                        |
| 不推送      | `python main.py --no-notify`                   | 只分析不发送通知                            |
| 单股推送     | `python main.py --single-notify`               | 每分析完一只立即推送                          |
| 仅拉数据     | `python main.py --dry-run`                     | 只获取数据，不做 AI 分析                      |
| 仅大盘复盘    | `python main.py --market-review`               | 只运行大盘复盘并推送                          |
| 跳过大盘     | `python main.py --no-market-review`            | 只做个股分析                              |
| 强制执行     | `python main.py --force-run`                   | 跳过交易日检查，强制执行                        |
| 定时任务     | `python main.py --schedule`                    | 按配置时间每日执行（需配置 `SCHEDULE_TIME` 等）    |
| Web 界面   | `python main.py --webui`                       | 启动 FastAPI + 前端，并执行一次分析             |
| 仅 Web 服务 | `python main.py --webui-only` 或 `--serve-only` | 只启动服务，不自动分析                         |
| 回测       | `python main.py --backtest`                    | 对历史分析做回测评估                          |
| 指定端口     | `python main.py --webui --port 8080`           | 指定服务端口（默认 8000）                     |


启动 Web 时，默认会在 `apps/dsa-web` 执行 `npm install && npm run build`；若需关闭自动构建，设置 `WEBUI_AUTO_BUILD=false` 并手动构建前端。

### 3.4 配置要点

- **必配**：`STOCK_LIST`（自选股代码，逗号分隔）。
- **AI**：至少一种：`AIHUBMIX_KEY`、`GEMINI_API_KEY`、`ANTHROPIC_API_KEY` 或 `OPENAI_API_KEY`（及可选 `OPENAI_BASE_URL`、`OPENAI_MODEL`）。
- **通知**：至少一个渠道（如 `WECHAT_WEBHOOK_URL`、`FEISHU_WEBHOOK_URL`、`EMAIL_SENDER`+`EMAIL_PASSWORD` 等）。
- **可选**：新闻搜索（`TAVILY_API_KEYS`、`SERPAPI_API_KEYS`、`BOCHA_API_KEYS`、`BRAVE_API_KEYS`）、`TUSHARE_TOKEN`、交易日检查 `TRADING_DAY_CHECK_ENABLED`、Agent 相关 `AGENT_MODE`/`AGENT_SKILLS` 等。  
完整列表见 [full-guide.md](full-guide.md) 与 `.env.example`。

### 3.5 Web 界面与 API

- **访问**：启动 Web 后打开 `http://127.0.0.1:8000`（或所配 `--host`/`--port`）。
- **功能**：配置管理、任务监控、手动触发分析、历史报告、Agent 问股（`/chat`）、从图片添加股票等。
- **可选登录**：`.env` 中设置 `ADMIN_AUTH_ENABLED=true` 可启用 Web 登录，首次访问在页面设置初始密码。
- **API 文档**：`http://127.0.0.1:8000/docs`（Swagger）。

主要 API 分组（前缀 `/api/v1`）：


| 分组           | 前缀          | 说明            |
| ------------ | ----------- | ------------- |
| Auth         | `/auth`     | 登录、改密等        |
| Agent        | `/agent`    | 策略列表、流式对话等    |
| Analysis     | `/analysis` | 触发单股/批量分析     |
| History      | `/history`  | 历史报告列表与详情     |
| Stocks       | `/stocks`   | 股票列表、从图片提取代码等 |
| Backtest     | `/backtest` | 回测相关          |
| SystemConfig | `/system`   | 系统配置读写        |


### 3.6 Bot 命令

在飞书/钉钉等平台配置 Webhook 后，可向机器人发送：


| 命令                  | 说明         |
| ------------------- | ---------- |
| `/analyze <股票代码>`   | 分析指定股票     |
| `/market`           | 大盘复盘       |
| `/batch`            | 批量分析自选股    |
| `/ask <股票代码> [策略名]` | Agent 策略问股 |
| `/chat`             | 进入多轮对话     |
| `/help`             | 帮助信息       |
| `/status`           | 系统状态       |


详见 [Bot 命令与配置](bot-command.md)、[飞书 Bot 配置](bot/feishu-bot-config.md)、[Discord 配置](bot/discord-bot-config.md) 等。

### 3.7 Agent 策略问股

- 在 `.env` 中设置 `AGENT_MODE=true` 后启动服务，访问 Web 的 `/chat` 页面即可进行多轮策略问答。
- 可选择均线金叉、缠论、波浪理论等内置策略，用自然语言提问（如「用缠论分析 600519」），Agent 会调用行情、K 线、技术指标、新闻等工具并返回结论。
- 内置策略在 `strategies/*.yaml`，可通过 `AGENT_SKILLS` 选择启用，或通过 `AGENT_STRATEGY_DIR` 使用自定义策略目录。编写方式见 [strategies/README.md](../strategies/README.md)。

### 3.8 回测

- 单次运行：`python main.py --backtest`；可选 `--backtest-code 600519`、`--backtest-days 10`、`--backtest-force`。
- 自动回测：在 `.env` 中开启 `BACKTEST_ENABLED=true`，每次分析完成后会自动执行回测（配置项见 `.env.example`）。

### 3.9 部署方式摘要

- **GitHub Actions**：Fork 仓库 → 配置 Secrets（`STOCK_LIST`、AI Key、通知等）→ 启用 Actions → 使用「每日股票分析」工作流；详见 README 与 [full-guide.md](full-guide.md)。
- **Docker**：见 [full-guide.md](full-guide.md) 与 [Zeabur 部署](docker/zeabur-deployment.md)。
- **桌面端**：见 [桌面端打包说明](desktop-package.md)。

---

## 四、文档与规范索引


| 文档                                              | 说明                           |
| ----------------------------------------------- | ---------------------------- |
| [README.md](../README.md)                       | 项目概览、快速开始、功能特性、推送效果          |
| [full-guide.md](full-guide.md)                  | 完整配置与部署、环境变量、Docker、定时任务     |
| [CHANGELOG.md](CHANGELOG.md)                    | 版本变更记录                       |
| [FAQ.md](FAQ.md)                                | 常见问题                         |
| [CONTRIBUTING.md](CONTRIBUTING.md)              | 贡献指南                         |
| [AGENTS.md](../AGENTS.md)                       | 开发/Issue/PR 行为准则（含代码风格、门禁命令） |
| [bot-command.md](bot-command.md)                | Bot 命令与架构                    |
| [strategies/README.md](../strategies/README.md) | Agent 策略 YAML 编写说明           |


本地门禁（建议提交前执行）：

```bash
./test.sh syntax
# 或
python -m py_compile main.py src/*.py data_provider/*.py
flake8 main.py src/ --max-line-length=120
```

---

## 五、免责声明

本项目仅供学习与研究使用，不构成任何投资建议。股市有风险，投资需谨慎。作者不对使用本项目产生的任何损失负责。