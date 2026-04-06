# 安装 npm（Node.js）

npm 随 **Node.js** 一起安装，任选下面一种方式即可。

---

## 方式一：Homebrew（macOS 推荐）

本机已有 Homebrew（`/opt/homebrew/bin/brew`）。在**终端**中执行：

```bash
# 若曾出现 /opt/homebrew 不可写，先修复权限（需输入本机密码）：
sudo chown -R $(whoami) /opt/homebrew

# 安装 Node.js（含 npm）
brew install node
```

安装完成后执行 `node -v` 和 `npm -v` 检查。

---

## 方式二：官网安装包（macOS / Windows）

1. 打开 [Node.js 官网](https://nodejs.org/)
2. 下载 **LTS** 版本安装包并安装
3. 安装完成后**重新打开终端**，执行 `npm -v` 检查

---

## 方式三：nvm（多版本 Node 时使用）

```bash
# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# 重新打开终端后：
nvm install --lts
nvm use --lts
```

---

安装好 Node.js/npm 后，在项目里构建前端即可：

```bash
cd /Users/hai/Desktop/singularity/workspace/daily_stock_analysis/apps/dsa-web
npm install
npm run build
```

或直接运行 `./scripts/setup-troye-stock.sh`，脚本会调用 npm 构建前端。
