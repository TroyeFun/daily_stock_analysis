# 使用 Conda 配置 troye_stock 环境

项目已提供 `.env`（AIHubMix、飞书、自选股、Tavily）。按下面任一种方式用 **conda** 配置环境并跑通 WebUI。

---

## 方式一：一键脚本（推荐）

在**已安装 conda** 的终端中执行（若刚安装 conda，需先执行 `conda init zsh` 或 `conda init bash`，再**重新打开终端**）：

```bash
cd /Users/hai/Desktop/singularity/workspace/daily_stock_analysis
chmod +x scripts/setup-troye-stock.sh
./scripts/setup-troye-stock.sh
```

脚本会依次：

1. 尝试加载 conda（常见安装路径）
2. 创建 conda 环境 `troye_stock`（Python 3.10），若已存在则跳过
3. 在该环境中 `pip install -r requirements.txt`
4. 在 `apps/dsa-web` 执行 `npm install && npm run build`
5. 执行 `python main.py --webui-only --port 8000` 启动 WebUI

启动后浏览器访问：**http://127.0.0.1:8000**。

---

## 方式二：手动执行（便于排查问题）

在项目根目录打开终端，**先激活 conda**，再依次执行：

```bash
cd /Users/hai/Desktop/singularity/workspace/daily_stock_analysis

# 1. 创建 conda 环境（Python 3.10）
conda create -n troye_stock python=3.10 -y

# 2. 激活环境
conda activate troye_stock

# 3. 安装 Python 依赖
pip install -r requirements.txt

# 4. 构建前端（需已安装 Node.js / npm）
cd apps/dsa-web && npm install && npm run build && cd ../..

# 5. 启动 WebUI（仅服务，不立即跑分析）
python main.py --webui-only --port 8000
```

然后打开 **http://127.0.0.1:8000**。

之后每次启动 WebUI，只需：

```bash
conda activate troye_stock
cd /Users/hai/Desktop/singularity/workspace/daily_stock_analysis
python main.py --webui-only --port 8000
```

---

## 若本机尚未安装 conda

1. 安装 [Miniconda](https://docs.conda.io/en/latest/miniconda.html)（推荐）或 Anaconda。
2. 安装完成后在终端执行一次：
   - macOS/Linux (zsh)：`conda init zsh`
   - macOS/Linux (bash)：`conda init bash`
3. **关闭并重新打开终端**，再按上面「方式一」或「方式二」操作。

---

## 已写入的 .env 摘要

| 变量 | 说明 |
|------|------|
| `STOCK_LIST` | PONY,02026（港股） |
| `AIHUBMIX_KEY` | 已配置 |
| `OPENAI_MODEL` | gpt-4o-mini |
| `FEISHU_WEBHOOK_URL` | 飞书机器人 Webhook |
| `TAVILY_API_KEYS` | 新闻搜索 |
| `RUN_IMMEDIATELY` | false（仅启动 Web 时不自动分析） |

如需启动时顺带跑一次分析，可改为 `RUN_IMMEDIATELY=true` 并执行 `python main.py --webui`。
