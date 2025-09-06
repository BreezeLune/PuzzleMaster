# PuzzleMaster

## Quick Start

### 1) 准备环境变量
- 复制 `.env.example` 为 `.env`，填入实际数据库与密钥（`.env` 不要提交到仓库）。

### 2) 初始化数据库
- 确保已安装并能访问 MySQL。
- 在目标数据库实例上执行建表脚本（只需一次）：
  - Windows PowerShell 示例：
    mysql -h 127.0.0.1 -P 3306 -u root -p puzzlemaster < backend\schema.sql
  - 或登录 mysql 控制台后：
    SOURCE /absolute/path/to/backend/schema.sql;

### 3) 启动后端（Flask）
cd backend
python -m venv .venv
# Windows
.\.venv\Scripts\Activate.ps1
# macOS/Linux
# source .venv/bin/activate
pip install -r requirements.txt
set FLASK_APP=app.main:app  # PowerShell 可用 $env:FLASK_APP = "app.main:app"
flask run  # 默认 http://127.0.0.1:5000

- 健康检查：访问 http://127.0.0.1:5000/health 应返回 { ok: true }

### 4) 预览前端
- 直接用浏览器打开 frontend/assets/html/index.html（或 VS Code Live Server）。
- 前端请求的 API 基地址可通过环境变量/配置指定，如 http://127.0.0.1:5000/api。

### 5) 目录结构（简）
backend/
  app/
    main.py        # Flask 最小骨架与健康检查
  requirements.txt
  schema.sql       # MySQL 建表脚本
frontend/
  assets/
    html/ css/ js/
docs/
  软件需求规格说明书.md
  API.md

### 6) 常见问题
- `.env` 是否需要提交？不要，把 `.env.example` 提交即可。
- schema.sql 何时执行？对每个数据库实例初始化时执行一次（云库/测试库）；本地自测时也可执行一遍。
- API 前缀用什么？小项目可用 /api，后续需要版本时再升级到 /api/v1。
# PuzzleMaster