# 记账本 App（bookkeepingApp）

一个基于 HarmonyOS / ArkTS 的纯本地记账应用。无需注册、无需联网，所有账单数据保存在设备本地，强调隐私友好与可测试性。

## 项目特色

- **零注册、零登录门槛**：打开即用，不采集手机号、邮箱、实名等任何用户身份信息。
- **纯本地存储**：所有账单通过 HarmonyOS 分布式键值数据库（`distributedKVStore`）保存在设备本地，不上传任何服务端。
- **隐私友好**：不存在服务端拖库、账号撞库、中间人攻击等云端记账应用常见的威胁，攻击面由“客户端 + 网络 + 服务端 + 数据库”缩减为“客户端本地”单一层。
- **面向测试的设计**：数据访问层（`KVStoreUtils`）接口清晰、职责单一，便于单元测试；页面状态集中在 `@State`，数据流单向，便于集成测试与边界测试。

## 功能模块

| 模块 | 页面/组件 | 说明 |
| --- | --- | --- |
| 登录 | `LoginPage.ets` | 默认账号 `admin`，密码 `123456`，登录后进入主页面 |
| 账本 | `Index.ets`（`Index_ShowAccounts`） | 按日期分组展示账单，统计每日收支，支持预算设置与修改 |
| 查询 | `One_SelectAccounts.ets` | 按收支类型、日期范围、金额区间、关键词筛选账单 |
| 记一笔 | `Two_KeepAccounts.ets` | 选择支出/收入分类，填写金额与备注，保存到本地 |
| 统计 | `Three_ShowAccounts.ets` | 汇总总收入、总支出、结余，计算支出/收入分类占比 |
| 主框架 | `EntryPage.ets` | 底部导航栏，承载以上四个 Tab |
| 数据层 | `common/KVStoreUtils.ets` | 封装 `distributedKVStore` 的初始化、读写、删除 |
| 公共组件 | `components/top.ets` | 顶部标题栏 `Top` / `TopBack`，以及 `KeepAccountsModel` 接口 |

## 技术栈

- **平台**：HarmonyOS
- **语言**：ArkTS
- **UI 框架**：ArkUI 声明式开发范式
- **本地存储**：`@kit.ArkData` 中的 `distributedKVStore`
- **路由**：`@kit.ArkUI` 中的 `router` / `UIContext.getRouter()`
- **日志**：`@kit.PerformanceAnalysisKit` 中的 `hilog`

## 目录结构（核心部分）
entry/src/main/ets/
├── entryability/
│ ├── EntryAbility.ets # 应用入口，启动 LoginPage
│ └── EntryBackupAbility.ets # 备份扩展 Ability
├── pages/
│ ├── LoginPage.ets # 登录页
│ ├── EntryPage.ets # 主页面（底部导航）
│ ├── Index.ets # 账本（账单列表）
│ ├── One_SelectAccounts.ets # 查询
│ ├── Two_KeepAccounts.ets # 记一笔
│ └── Three_ShowAccounts.ets # 统计
├── common/
│ └── KVStoreUtils.ets # 本地键值存储工具类
└── components/
└── top.ets # 顶部标题栏等公共组件

**
## 快速开始

1. 使用 DevEco Studio 打开项目。
2. 确保项目路径为纯英文（例如 `D:\DevEcoProjects\bookkeepingApp`），避免构建工具因中文路径报错。
3. 在 `entry/src/main/resources/base/profile/main_pages.json` 中确认已注册以下页面：
   ```json
   {
     "src": [
       "pages/LoginPage",
       "pages/EntryPage",
       "pages/Index",
       "pages/One_SelectAccounts",
       "pages/Two_KeepAccounts",
       "pages/Three_ShowAccounts"
     ]
   }**
