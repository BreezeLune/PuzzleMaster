# 项目结构说明

```
puzzle-master/                 # 项目根目录
│
├── frontend/                  # 前端代码 (纯HTML/CSS/JS)
│   ├── assets/               # 静态资源目录
│   │   ├── css/
│   │   │   └── style.css     # 全局样式表
│   │   ├── js/
│   │   │   ├── app.js        # 应用主逻辑，路由切换等
│   │   │   ├── game.js       # 游戏核心逻辑(拼图生成、拖拽、验证)
│   │   │   └── utils.js      # 通用工具函数
│   │   └── images/           # 图片素材库
│   │       ├── puzzle-1.jpg  # 示例图片1
│   │       ├── puzzle-2.jpg  # 示例图片2
│   │       └── ...           # 其他图片资源
│   ├── levels/               # 关卡数据定义(JSON格式)
│   │   └── default.json      # 默认关卡配置
│   ├── index.html            # 主页面/首页
│   ├── game.html             # 游戏界面
│   └── editor.html           # 拼图编辑器界面
│
├── backend/                   # 后端代码 (Flask)
│   ├── data/                 # 数据存储目录(前期使用JSON文件)
│   │   ├── users.json        # 用户数据(后期使用)
│   │   └── saves.json        # 存档数据(后期使用)
│   ├── app.py                # Flask应用主文件
│   ├── models.py             # 数据模型定义
│   └── utils.py              # 后端工具函数
│
├── docs/                     # 项目文档
│   ├── API.md                # API接口文档
│   └── AI-USAGE.md           # AI使用记录(老师要求)
│
├── .gitignore                # Git忽略规则
├── LICENSE                   # MIT许可证
└── README.md                 # 项目说明文档
```

## 前端详细说明

### HTML文件
- `index.html` - 应用入口，包含主菜单和导航到其他页面
- `game.html` - 游戏主界面，包含拼图区域和控制元素
- `editor.html` - 拼图编辑器界面，用于创建自定义拼图

### JavaScript模块
- `app.js` - 处理页面路由和全局状态管理
- `game.js` - 核心游戏逻辑:
  - 拼图分割算法
  - 拖拽交互处理
  - 完成验证逻辑
  - 计时和步数统计
- `utils.js` - 通用辅助函数:
  - 图片加载器
  - 随机数生成
  - 本地存储操作

### 资源文件
- `images/` - 存放所有拼图使用的图片素材
- `levels/` - 关卡配置文件(JSON格式)，定义:
  - 使用的图片路径
  - 难度级别(块数)
  - 其他关卡特定参数

## 后端详细说明(后期开发)

### Flask应用
- `app.py` - 主应用文件，定义API路由:
  - GET /api/levels - 获取关卡列表
  - POST /api/save - 保存游戏进度
  - GET /api/load/:id - 加载特定存档
- `models.py` - 数据模型定义(用户、关卡、存档)
- `data/` - 数据存储目录(前期使用JSON文件模拟数据库)

## 开发工作流

1. 前端开发: 主要集中在 `frontend/` 目录
2. 后端开发: 主要集中在 `backend/` 目录
3. 数据交互: 通过预定义的API接口(在docs/API.md中说明)
4. 版本控制: 遵循Git分支策略，功能开发在特性分支