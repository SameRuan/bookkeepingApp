# 记账本 App（HarmonyOS + Flask 后端）

一个基于 HarmonyOS / ArkTS 前端 + Flask 后端的记账应用，配套 Pytest 接口自动化测试框架。支持账单管理、条件查询、收支统计，以及可复用的多层次自动化测试方案。

---

## 项目组成

| 组成部分 | 技术栈 | 说明 |
|---|---|---|
| **前端** | HarmonyOS + ArkTS | 记账 App，通过 HTTP 调用后端 API |
| **后端** | Flask 3.0.3 + SQLite | 提供 6 个 RESTful API |
| **接口测试** | Pytest + Requests + Allure | 33 条用例，覆盖 4 类场景 |

---

## 项目特色

- **前后端分离架构**：前端通过 HTTP 调用后端 RESTful API，实现业务逻辑与 UI 的彻底解耦。
- **零注册、零登录门槛**：内置默认账号，打开即用，不采集任何用户身份信息。
- **完整业务闭环**：登录、账本、记一笔、查询、统计五大模块，前端后端数据实时同步。
- **面向测试的设计**：接口清晰、职责单一，便于单元测试与接口测试；HTTP 工具类统一封装请求，便于扩展。
- **自动化测试友好**：测试框架采用独立数据库隔离机制，跑测试不会污染真实数据。
- **多层次测试框架**：涵盖接口层测试与 UI 层测试，符合论文"多层次自动化测试"要求。

---

## 功能模块

| 模块 | 页面/组件 | 说明 |
| --- | --- | --- |
| 登录 | `LoginPage.ets` | 默认账号 `admin`，密码 `123456`，登录后进入主页面 |
| 账本 | `Index.ets`（`Index_ShowAccounts`） | 按日期分组展示账单，统计每日收支，支持预算设置与修改 |
| 查询 | `One_SelectAccounts.ets` | 按收支类型、日期范围、金额区间、关键词筛选账单 |
| 记一笔 | `Two_KeepAccounts.ets` | 选择支出/收入分类，填写金额与备注，保存到后端 |
| 统计 | `Three_ShowAccounts.ets` | 汇总总收入、总支出、结余，计算支出/收入分类占比 |
| 主框架 | `EntryPage.ets` | 底部导航栏，承载以上四个 Tab |
| HTTP工具 | `utils/HttpUtil.ets` | 封装 HTTP 请求，提供泛型接口 + 类型定义 |
| 公共组件 | `components/top.ets` | 顶部标题栏 `Top` / `TopBack`，以及 `KeepAccountsModel` 接口 |

---

## 技术栈

### 前端

- **平台**：HarmonyOS
- **语言**：ArkTS
- **UI 框架**：ArkUI 声明式开发范式
- **网络请求**：`@kit.NetworkKit` 中的 `http`
- **路由**：`@kit.ArkUI` 中的 `router` / `UIContext.getRouter()`
- **日志**：`@kit.PerformanceAnalysisKit` 中的 `hilog`

### 后端

- **框架**：Flask 3.0.3
- **跨域**：Flask-CORS 4.0.1
- **数据库**：SQLite 3（Python 内置）
- **语言**：Python 3.8.6

### 测试

- **测试框架**：Pytest 8.3.4
- **HTTP 客户端**：Requests 2.32.3
- **数据驱动**：PyYAML 6.0.2
- **报告工具**：Allure 2.46.1

---

## 目录结构（核心部分）

```
D:\bookkeepingAppTest\
├── bookkeepingApp\              # HarmonyOS 前端
│   └── entry/src/main/ets/
│       ├── entryability/
│       │   └── EntryAbility.ets           # 应用入口
│       ├── pages/
│       │   ├── LoginPage.ets              # 登录页
│       │   ├── EntryPage.ets              # 主页面（底部导航）
│       │   ├── Index.ets                  # 账本
│       │   ├── One_SelectAccounts.ets     # 查询
│       │   ├── Two_KeepAccounts.ets       # 记一笔
│       │   └── Three_ShowAccounts.ets     # 统计
│       ├── components/
│       │   └── top.ets                    # 顶部标题栏组件
│       └── utils/
│           └── HttpUtil.ets               # HTTP 工具类 + 类型定义
│
├── backend\                     # Flask 后端
│   ├── app.py                             # Flask 主程序
│   ├── database.py                        # 数据库操作
│   ├── requirements.txt                   # 后端依赖
│   ├── jizhang.db                         # 正式数据库（App使用）
│   └── test_jizhang.db                    # 测试数据库（跑测试时临时创建）
│
├── api_test\                    # 接口自动化测试
│   ├── conftest.py                        # Pytest 全局配置
│   ├── test_login.py                      # 登录模块（6条）
│   ├── test_bills.py                      # 账单模块（14条）
│   ├── test_query.py                      # 查询模块（9条）
│   ├── test_statistics.py                 # 统计模块（3条）
│   ├── test_full_flow.py                  # 业务链路（1条）
│   └── data\
│       └── login_data.yaml                # 登录测试数据
│
├── utils\
│   └── yaml_util.py                       # YAML 读取工具
│
├── report\
│   └── allure-results\                    # Allure 原始结果
│
└── requirements.txt                       # 测试依赖
```

---

## 快速开始

### 一、环境要求

| 项目 | 版本 |
|---|---|
| Windows | 10 / 11 |
| Python | 3.8+ |
| Java | JDK 17+（Allure 依赖） |
| DevEco Studio | HarmonyOS NEXT 版本 |
| Allure | 2.46.1 |

### 二、启动后端

```bash
# 1. 安装依赖
cd /d D:\bookkeepingAppTest\backend
pip install -r requirements.txt

# 2. 启动服务（默认端口 5000，数据库 jizhang.db）
python app.py
```

启动成功输出：
```
数据库文件: D:\bookkeepingAppTest\backend\jizhang.db
服务端口: 5000    调试模式: True
服务启动中...
 * Running on http://0.0.0.0:5000
```

**这个窗口保持运行**，不要关闭。

### 三、运行 App

1. 使用 **DevEco Studio** 打开 `bookkeepingApp` 项目
2. 在 **Device Manager** 中启动模拟器（或用真机）
3. 在 `utils/HttpUtil.ets` 中确认后端地址：
   - **模拟器**：`http://10.0.2.2:5000`
   - **真机**：`http://电脑局域网IP:5000`（如 `http://192.168.1.5:5000`）
4. 点顶部 ▶️ 按钮运行 App
5. 使用默认账号登录：**admin / 123456**

### 四、运行接口测试

```bash
# 只需要一条命令（不需要手动启动测试服务）
cd /d D:\bookkeepingAppTest\api_test
pytest -v -s
```

**预期输出**：
```
[setup] 启动测试服务 http://127.0.0.1:5001
[setup] 测试服务已就绪（用时1秒）
...33条用例全部 PASSED...
[teardown] 关闭测试服务
[teardown] 已删除测试数据库: test_jizhang.db

========================= 33 passed in 8.5s =========================
```

**说明**：
- 测试框架会**自动启动一个独立的后端服务**（端口 5001，数据库 `test_jizhang.db`）
- 测试结束后**自动关闭服务并删除测试数据库**
- 正式数据库 `jizhang.db` **不受任何影响**

### 五、生成 Allure 报告

```bash
# 1. 执行测试并生成原始结果
cd /d D:\bookkeepingAppTest\api_test
pytest --alluredir=../report/allure-results

# 2. 启动 Allure 服务并打开报告
allure serve ../report/allure-results
```

浏览器自动打开报告页面，展示用例通过率、用例分组、执行时长等信息。

---

## API 接口清单

| 接口路径 | 方法 | 功能 | 参数 |
|---|---|---|---|
| `/api/login` | POST | 登录 | `username`, `password` |
| `/api/bills` | GET | 获取账单列表 | 无 |
| `/api/bills` | POST | 新增账单 | `text`, `name`, `price`, `isIncome`, `date`, `imageName` |
| `/api/bills/<id>` | DELETE | 删除账单 | URL 中的 id |
| `/api/bills/query` | GET | 条件查询 | `type`, `startDate`, `endDate`, `minAmount`, `maxAmount`, `keyword` |
| `/api/statistics` | GET | 统计汇总 | 无 |

**统一响应格式**：

```json
{
  "code": 200,
  "msg": "成功",
  "data": { }
}
```

---

## 测试用例分布

| 测试文件 | 用例数 | 覆盖场景 |
|---|---|---|
| `test_login.py` | 6 | 登录正常流程、密码错误、用户名错误、用户名/密码为空、请求体为空 |
| `test_bills.py` | 14 | 账单增删正常、字段为空、金额非数字、金额为0/负数/极小值/极大值/超限 |
| `test_query.py` | 9 | 查询全部/类型/关键词/金额区间、日期格式错误、日期颠倒、非法金额、空结果 |
| `test_statistics.py` | 3 | 获取统计数据、记账后统计同步、余额公式验证 |
| `test_full_flow.py` | 1 | 登录→记账→查询→统计 端到端链路 |
| **合计** | **33** | **正常流程 + 异常场景 + 边界值 + 业务流程链路** |

---

## 数据隔离机制

测试框架采用**独立数据库 + 独立端口**的隔离策略：

| 项 | 正式服务 | 测试服务 |
|---|---|---|
| 端口 | 5000 | 5001 |
| 数据库 | `jizhang.db` | `test_jizhang.db` |
| 触发方式 | 手动 `python app.py` | 跑 pytest 时自动启停 |
| 生命周期 | 长期运行 | 测试开始创建，结束删除 |

**原理**：后端 `database.py` 和 `app.py` 支持环境变量控制：

```python
DB_PATH = os.path.join(os.path.dirname(__file__),
                       os.environ.get('JIZHANG_DB', 'jizhang.db'))
```

```python
port = int(os.environ.get('JIZHANG_PORT', '5000'))
```

测试框架通过设置环境变量 `JIZHANG_DB=test_jizhang.db` 和 `JIZHANG_PORT=5001` 启动独立的测试服务，与正式服务完全隔离。

---

## 数据库设计

### users 表

| 字段 | 类型 | 说明 |
|---|---|---|
| id | INTEGER | 主键，自增 |
| username | TEXT | 用户名，唯一 |
| password | TEXT | 密码 |

**初始数据**：`admin / 123456`

### bills 表

| 字段 | 类型 | 说明 |
|---|---|---|
| id | INTEGER | 主键，自增 |
| text | TEXT | 类型（餐饮、购物等） |
| name | TEXT | 备注 |
| price | REAL | 金额 |
| isIncome | INTEGER | 0=支出，1=收入 |
| date | TEXT | 账单日期（YYYY-MM-DD） |
| imageName | TEXT | 图标名 |
| createTime | TEXT | 创建时间（YYYY-MM-DD HH:MM:SS） |
| user_id | INTEGER | 用户ID（预留） |

---

## 默认账号

- 用户名：**admin**
- 密码：**123456**

---

## 开发约定

1. **前端地址配置**：切换模拟器/真机时，只需修改 `HttpUtil.ets` 中的 `BASE_URL`。
2. **数据库清理**：修改表结构后，需删除 `jizhang.db` 让后端重建。
3. **测试隔离**：跑测试无需手动启动测试服务，框架自动管理。
4. **端口约定**：正式服务 5000，测试服务 5001。



本项目为景德镇艺术职业大学 2023 级计算机科学与技术专业毕业设计作品，仅供学习交流使用。


## 致谢

感谢指导教师黄佳豪老师的悉心指导，感谢学院提供的学习环境。
