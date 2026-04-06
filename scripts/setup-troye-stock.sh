#!/usr/bin/env bash
# ===================================
# 使用 conda 配置 troye_stock 环境并跑通 WebUI
# 请在已安装 conda 的终端中执行（若 conda 未加入 PATH，请先执行 conda init zsh/bash）
# ===================================
set -e
cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

# 尝试从常见路径加载 conda（非交互式终端可能未自动加载）
source /opt/miniconda3/bin/activate

echo "[1/4] conda 环境 troye_stock (Python 3.10)..."
if conda env list | grep -q '^troye_stock '; then
  echo "      环境已存在，跳过创建"
else
  conda create -n troye_stock python=3.10 -y
fi

echo "[2/4] 安装 Python 依赖..."
conda run -n troye_stock pip install -r requirements.txt

echo "[3/4] 构建前端 (apps/dsa-web)..."
if command -v npm >/dev/null 2>&1; then
  (cd apps/dsa-web && npm install && npm run build)
else
  echo "      [WARN] 未检测到 npm，跳过。可设置 WEBUI_AUTO_BUILD=true 由 main.py 自动构建。"
fi

echo "[4/4] 启动 WebUI（仅服务模式）..."
echo "      访问: http://127.0.0.1:8000"
echo "      按 Ctrl+C 停止"
(cd "$REPO_ROOT" && conda run -n troye_stock python main.py --webui-only --port 8000)
