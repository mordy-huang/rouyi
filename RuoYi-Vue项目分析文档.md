# RuoYi-Vue 项目分析文档

## 一、项目概述

RuoYi（若依）是一套全部开源的 Java 快速开发平台，当前版本为 **v3.9.2**。项目采用前后端分离架构，后端基于 Spring Boot，前端基于 Vue，没有任何功能限制，面向个人和企业免费使用。该项目是 RuoYi 生态中 Vue 2.x 版本的主仓库，当前保持对 Spring Boot 4.x（JDK 17+）的适配和维护。

项目仓库：[https://gitee.com/y_project/RuoYi-Vue](https://gitee.com/y_project/RuoYi-Vue)  
官方文档：[http://doc.ruoyi.vip](http://doc.ruoyi.vip)  
在线演示：[http://vue.ruoyi.vip](http://vue.ruoyi.vip)（账号: admin / admin123）

---

## 二、技术栈总览

### 后端技术栈

| 分类 | 技术 | 版本 |
|------|------|------|
| 核心框架 | Spring Boot | 4.0.3 |
| 编程语言 | Java | 17+ |
| 安全框架 | Spring Security | 随 Spring Boot 4.0.3 |
| 认证方式 | JWT (JSON Web Token) | 0.9.1 (io.jsonwebtoken/jjwt) |
| ORM 框架 | MyBatis | 随 mybatis-spring-boot 4.0.1 |
| 数据库连接池 | Druid (Alibaba) | 1.2.28 |
| 分页插件 | PageHelper | 2.1.1 |
| 缓存 | Redis + Lettuce 连接池 | 随 Spring Boot |
| 接口文档 | SpringDoc (OpenAPI 3.0) | 3.0.2 |
| JSON 解析 | Fastjson2 (Alibaba) | 2.0.61 |
| Excel 操作 | Apache POI | 4.1.2 |
| 模板引擎 | Apache Velocity | 2.3 |
| 系统监控 | OSHI | 6.10.0 |
| 验证码 | Kaptcha | 2.3.3 |
| 定时任务 | Quartz | 随 ruoyi-quartz 模块 |
| 客户端解析 | Yauaa | 8.1.0 |
| 工具库 | Commons IO | 2.21.0 |

### 前端技术栈

| 分类 | 技术 | 版本 |
|------|------|------|
| 前端框架 | Vue.js | 2.6.12 |
| UI 组件库 | Element UI | 2.15.14 |
| 路由 | Vue Router | 3.4.9 |
| 状态管理 | Vuex | 3.6.0 |
| HTTP 客户端 | Axios | 0.30.3 |
| 图表 | ECharts | 5.4.0 |
| 富文本编辑器 | Quill | 2.0.2 |
| 构建工具 | Vue CLI | 4.4.6 |
| 样式预处理 | Sass/SCSS | 1.32.13 |
| 进度条 | NProgress | 0.2.0 |
| 树形选择器 | @riophae/vue-treeselect | 0.4.0 |
| 拖拽 | vuedraggable + sortablejs | - |
| 加密 | jsencrypt | 3.0.0-rc.1 |
| 代码高亮 | highlight.js | 9.18.5 |
| 图片裁剪 | vue-cropper | 0.5.5 |
| 全屏 | screenfull | 5.0.2 |

---

## 三、项目模块架构

项目根目录为 Maven 多模块聚合工程，由 6 个子模块组成：

```
RuoYi-Vue-master/
├── ruoyi-admin          # 管理后台 Web 入口模块（应用启动入口）
├── ruoyi-framework      # 框架核心模块（安全、配置、切面、过滤器等）
├── ruoyi-system         # 系统业务模块（用户、角色、菜单、部门等业务）
├── ruoyi-common          # 通用工具模块（注解、工具类、异常、过滤器等）
├── ruoyi-quartz         # 定时任务模块（基于 Quartz）
├── ruoyi-generator      # 代码生成模块（基于 Velocity 模板）
├── ruoyi-ui/            # 前端项目（Vue 2 + Element UI，独立于 Maven）
├── sql/                 # 数据库初始化 SQL 脚本
├── bin/                 # 打包/运行的批处理脚本
├── doc/                 # 文档资料
└── pom.xml              # 父 POM，统一依赖管理
```

### 模块依赖关系图

```
ruoyi-admin（入口层：Controller）
    ├── ruoyi-framework（框架层：安全、配置、AOP）
    │       ├── ruoyi-system（业务层：Service + Mapper）
    │       └── ruoyi-common（基础层：注解、工具、常量、异常）
    ├── ruoyi-quartz（定时任务层）
    └── ruoyi-generator（代码生成层）
```

**分层职责说明：**

- **ruoyi-admin**：应用唯一的启动模块，包含所有 Controller 和 Spring 启动类。依赖所有其他模块。
- **ruoyi-framework**：框架核心，包含安全配置（Spring Security + JWT）、AOP 切面（日志、数据权限、限流）、全局异常处理、服务监控、Token 管理等，是系统运行的基础框架。
- **ruoyi-system**：系统业务模块，包含用户、角色、菜单、部门、岗位、字典、参数、通知公告、操作日志、登录日志等核心业务逻辑，采用 Service + Mapper 标准三层架构。
- **ruoyi-common**：通用模块，被所有模块依赖。包含自定义注解（`@Log`、`@DataScope`、`@RateLimiter`、`@RepeatSubmit` 等）、枚举类、常量类、基础实体、通用工具类（字符串、文件、Excel、IP、JSON 等）、异常体系、请求过滤器（XSS、Referer）等。
- **ruoyi-quartz**：定时任务模块，基于 Quartz 实现，支持在线的任务添加、修改、删除、暂停、恢复及执行日志查看。
- **ruoyi-generator**：代码生成模块，基于 Apache Velocity 模板引擎，可根据数据库表结构自动生成前后端 CRUD 代码，大幅提升开发效率。

---

## 四、后端架构详解

### 4.1 ruoyi-admin — Web 控制层

ruoyi-admin 是整个应用的唯一启动入口，`RuoYiApplication` 位于 `com.ruoyi` 包下。Controller 按功能域分组组织：

**common（通用）**
- `CaptchaController`：图形验证码生成与校验
- `CommonController`：文件上传、下载、预览等通用接口

**monitor（监控管理）**
- `ServerController`：服务器监控（CPU、内存、JVM、磁盘等）
- `CacheController`：Redis 缓存监控
- `SysOperlogController`：操作日志管理
- `SysLogininforController`：登录日志管理
- `SysUserOnlineController`：在线用户管理

**system（系统管理）**
- `SysLoginController`：用户登录
- `SysRegisterController`：用户注册
- `SysIndexController`：首页信息
- `SysUserController`：用户管理
- `SysRoleController`：角色管理
- `SysMenuController`：菜单管理
- `SysDeptController`：部门管理
- `SysPostController`：岗位管理
- `SysConfigController`：参数配置
- `SysDictTypeController` / `SysDictDataController`：字典管理
- `SysNoticeController`：通知公告
- `SysProfileController`：个人中心

**tool（工具）**
- `TestController`：Swagger 接口测试模块

### 4.2 ruoyi-framework — 框架核心层

#### 安全机制（security 包）

- `SecurityConfig`：Spring Security 核心配置，采用无状态 Session 模式 + JWT Token 认证，禁用 CSRF，配置 URL 白名单（登录、注册、验证码、静态资源、Swagger、Druid 监控等可匿名访问，其余全部需要认证）
- `JwtAuthenticationTokenFilter`：JWT Token 认证过滤器，每个请求从请求头 `Authorization` 中提取并校验 Token
- `TokenService`：Token 的生成、刷新、验证及 Redis 存储管理
- `UserDetailsServiceImpl`：从数据库加载用户信息及权限
- `SysLoginService`：登录业务处理（验证码校验、密码校验、记录登录日志）
- `SysRegisterService`：注册业务处理
- `SysPasswordService`：密码错误次数限制及账号锁定
- `SysPermissionService`：用户权限信息获取
- `PermissionService`：权限校验服务（`@RequiresPermissions` 注解支持）

#### 切面/拦截器（aspectj 包 & interceptor 包）

- `LogAspect`：操作日志记录切面（`@Log` 注解），记录操作人、IP、请求参数、返回结果、耗时等
- `DataScopeAspect`：数据权限切面（`@DataScope` 注解），自动在 SQL 中注入数据权限过滤条件
- `DataSourceAspect`：多数据源切面（`@DataSource` 注解），支持动态切换数据源
- `RateLimiterAspect`：接口限流切面（`@RateLimiter` 注解），基于 Redis 实现
- `RepeatSubmitInterceptor`：防重复提交拦截器（`@RepeatSubmit` 注解），基于 Redis 实现

#### 其他

- `GlobalExceptionHandler`：全局异常处理器，统一处理各类业务异常并返回标准 JSON 响应
- `AsyncManager` / `AsyncFactory`：异步任务管理器，用于异步记录日志等非核心操作
- `Server.java`：服务器硬件信息采集（基于 OSHI），可监控 CPU、内存、JVM、磁盘、网络等
- `DynamicDataSource`：动态数据源，支持运行时切换

### 4.3 ruoyi-system — 业务服务层

采用标准的三层架构：Mapper（数据访问） -> Service（业务逻辑） -> Controller（由 ruoyi-admin 调用）。

核心业务模块包括：

| 业务模块 | 主要类 | 说明 |
|----------|--------|------|
| 用户管理 | SysUserMapper / SysUserServiceImpl | 用户增删改查、密码重置、状态管理、角色分配 |
| 角色管理 | SysRoleMapper / SysRoleServiceImpl | 角色增删改查、菜单权限分配、数据权限范围 |
| 菜单管理 | SysMenuMapper / SysMenuServiceImpl | 菜单增删改查、动态路由构建 |
| 部门管理 | SysDeptMapper / SysDeptServiceImpl | 组织架构树管理，支持数据权限 |
| 岗位管理 | SysPostMapper / SysPostServiceImpl | 岗位增删改查 |
| 字典管理 | SysDictTypeMapper / SysDictDataMapper | 系统字典数据的分类与维护 |
| 参数配置 | SysConfigMapper | 系统动态参数管理 |
| 通知公告 | SysNoticeMapper / SysNoticeReadMapper | 公告管理与已读记录 |
| 操作日志 | SysOperLogMapper | 操作日志存储 |
| 登录日志 | SysLogininforMapper | 登录记录存储 |
| 在线用户 | SysUserOnlineServiceImpl | 在线用户状态管理 |

### 4.4 ruoyi-common — 通用基础层

#### 自定义注解

| 注解 | 功能 | 作用域 |
|------|------|--------|
| `@Anonymous` | 标记匿名访问接口 | Spring Security URL 白名单自动收集 |
| `@Log` | 操作日志记录 | AOP 自动记录操作类型、模块、参数 |
| `@DataScope` | 数据权限控制 | AOP 自动拼接数据过滤 SQL |
| `@DataSource` | 多数据源切换 | AOP 动态切换数据源 |
| `@RateLimiter` | 接口限流 | 基于 Redis 的令牌桶限流 |
| `@RepeatSubmit` | 防重复提交 | 基于 Redis 去重 |
| `@Sensitive` | 数据脱敏 | JSON 序列化时自动脱敏 |
| `@Excel` / `@Excels` | Excel 导入导出 | 标记实体字段与 Excel 列的映射关系 |
| `@Log` | 操作日志标记 | 标记需要记录操作日志的接口 |

#### 工具类

- **字符串处理**：`Convert`、`StrFormatter`、`CharsetKit`、`EscapeUtil`
- **文件操作**：`FileUtils`、`FileUploadUtils`、`FileTypeUtils`、`ImageUtils`、`MimeTypeUtils`
- **Excel 操作**：`ExcelUtil`（基于注解驱动的 Excel 导入导出）
- **IP 与地址**：`IpUtils`、`AddressUtils`
- **HTTP 工具**：`HttpUtils`、`HttpHelper`、`UserAgentUtils`
- **Bean 工具**：`BeanUtils`、`BeanValidators`
- **反射工具**：`ReflectUtils`
- **JSON 工具**：基于 Fastjson2
- **安全工具**：`SecurityUtils`（获取当前登录用户）
- **其他**：`DateUtils`、`PageUtils`、`MessageUtils`、`DictUtils`、`DesensitizedUtil` 等

#### 异常体系

```
BaseException                    # 基础异常
├── UtilException               # 工具类异常
├── ServiceException            # 业务层异常
├── GlobalException             # 全局异常
├── DemoModeException           # 演示模式异常
├── file/                       # 文件相关异常
│   ├── FileException
│   ├── FileUploadException
│   ├── FileSizeLimitExceededException
│   ├── FileNameLengthLimitExceededException
│   └── InvalidExtensionException
├── job/TaskException           # 定时任务异常
└── user/                       # 用户相关异常
    ├── UserException
    ├── UserNotExistsException
    ├── UserPasswordNotMatchException
    ├── UserPasswordRetryLimitExceedException
    ├── CaptchaException
    ├── CaptchaExpireException
    └── BlackListException
```

#### 请求过滤器

- `XssFilter`：XSS 攻击防护过滤
- `RefererFilter`：防盗链过滤
- `RepeatableFilter`：支持请求体多次读取
- `PropertyPreExcludeFilter`：属性预排除（JSON 序列化时过滤敏感字段）

### 4.5 ruoyi-quartz — 定时任务模块

基于 Quartz 实现，提供以下核心能力：

- 在线任务管理（添加、修改、删除、暂停、恢复、立即执行一次）
- 支持 Cron 表达式
- 支持并发执行与禁止并发执行
- 完整的执行日志记录
- 支持调用目标字符串（Bean 方法调用）

### 4.6 ruoyi-generator — 代码生成模块

基于 Apache Velocity 模板引擎，通过读取数据库表结构元数据，自动生成：

- Java Entity 实体类
- Java Mapper 接口与 XML 映射文件
- Java Service 接口与实现类
- Java Controller 控制器
- Vue 前端页面（列表页、新增/编辑弹窗）
- SQL 菜单初始化脚本

支持单表、树表的一键生成，是目前若依框架中最受关注的特色功能之一。

---

## 五、前端架构详解

### 5.1 目录结构

```
ruoyi-ui/src/
├── api/                    # API 接口定义（按模块分组）
│   ├── login.js           # 登录相关接口
│   ├── menu.js            # 菜单相关接口
│   ├── system/            # 系统管理接口
│   │   ├── user.js        #    用户管理
│   │   ├── role.js        #    角色管理
│   │   ├── menu.js        #    菜单管理
│   │   ├── dept.js        #    部门管理
│   │   ├── post.js        #    岗位管理
│   │   ├── config.js      #    参数配置
│   │   ├── dict/          #    字典管理
│   │   └── notice.js      #    通知公告
│   ├── monitor/           # 监控管理接口
│   │   ├── server.js      #    服务监控
│   │   ├── cache.js       #    缓存监控
│   │   ├── job.js         #    定时任务
│   │   ├── operlog.js     #    操作日志
│   │   ├── logininfor.js  #    登录日志
│   │   └── online.js      #    在线用户
│   └── tool/gen.js        # 代码生成接口
├── assets/                # 静态资源（图标、图片、样式）
│   ├── icons/svg/         # SVG 图标（170+ 个）
│   └── 401_images/、404_images/
├── components/            # 公共组件
├── directive/             # 自定义指令（权限、角色等）
├── layout/                # 布局组件
├── plugins/               # 插件
├── router/                # 路由配置（常量路由 + 动态路由 + 权限路由）
├── store/                 # Vuex 状态管理
├── utils/                 # 工具函数（请求封装、权限判断等）
└── views/                 # 页面视图
    ├── login.vue          # 登录页
    ├── register.vue       # 注册页
    ├── index.vue          # 首页（仪表盘）
    ├── system/            # 系统管理页面
    ├── monitor/           # 监控管理页面
    └── tool/              # 工具页面（代码生成、在线构建器、Swagger）
```

### 5.2 核心设计

**路由设计**：采用静态路由 + 动态路由的双层模型。静态路由（constantRoutes）包含登录、注册、404、首页等无需权限的基础页面；动态路由（dynamicRoutes）根据后端返回的菜单权限数据动态加载，实现菜单与权限的联动。

**权限控制**：前端通过 Vue 自定义指令 `v-hasPermi` 和 `v-hasRole` 实现按钮级权限控制，权限标识从后端菜单表同步。路由守卫在每次页面跳转时验证 Token 有效性。

**请求封装**：基于 Axios 的 `request.js` 统一封装了请求拦截器（自动附加 Token）和响应拦截器（统一错误处理、Token 过期自动刷新）。

**状态管理**：Vuex Store 管理用户信息、权限、路由、全局设置等状态。

---

## 六、安全机制详解

### 6.1 认证流程

1. 用户提交登录表单（用户名 + 密码 + 验证码 + UUID）
2. 后端校验验证码有效性（Redis 存储，有过期时间）
3. 调用 `UserDetailsServiceImpl` 从数据库加载用户信息
4. 使用 BCryptPasswordEncoder 校验密码
5. 校验通过后生成 JWT Token，将用户信息存入 Redis
6. 返回 Token 给前端，前端存入 Cookie
7. 后续每个请求在 Header 中携带 `Authorization: Bearer {token}`
8. `JwtAuthenticationTokenFilter` 拦截请求，从 Redis 中获取对应用户信息并设置到 SecurityContext

### 6.2 安全防护措施

- **CSRF 防护**：使用无状态 Token 认证，Session 禁用，天然免疫 CSRF
- **XSS 防护**：内置 XssFilter，对请求参数进行 HTML 转义
- **SQL 注入防护**：MyBatis 参数化查询（`#{}`）
- **密码安全**：BCrypt 强哈希加密存储，支持密码错误次数限制和账号锁定
- **验证码**：支持数学计算和字符两种验证码类型
- **接口限流**：`@RateLimiter` 注解，基于 Redis 实现接口访问频率限制
- **防重复提交**：`@RepeatSubmit` 注解，基于 Redis 实现防抖
- **数据脱敏**：`@Sensitive` 注解，JSON 序列化时自动对手机号、邮箱、身份证等脱敏
- **防盗链**：RefererFilter 可配置允许的域名白名单

### 6.3 权限模型

采用 **RBAC（基于角色的访问控制）** 模型：

- **用户** ↔ **角色**：多对多关系（SysUserRole）
- **角色** ↔ **菜单**：多对多关系（SysRoleMenu）
- **角色** ↔ **部门**：多对多关系（SysRoleDept，用于数据权限）

权限粒度：
- **菜单权限**：控制菜单可见性
- **按钮权限**：控制页面按钮（增删改查等）的可见性，通过权限标识实现
- **数据权限**：控制数据可见范围（全部数据、本部门、本部门及以下、仅本人、自定义）

---

## 七、内置功能清单

| 序号 | 功能模块 | 说明 |
|------|----------|------|
| 1 | 用户管理 | 系统用户配置，支持状态、角色、岗位管理 |
| 2 | 部门管理 | 组织机构树（公司 → 部门 → 小组），支持数据权限 |
| 3 | 岗位管理 | 用户职务配置 |
| 4 | 菜单管理 | 菜单、按钮权限标识配置 |
| 5 | 角色管理 | 菜单权限分配 + 数据范围权限划分 |
| 6 | 字典管理 | 固定数据维护（如性别、状态等枚举值） |
| 7 | 参数管理 | 系统动态参数配置 |
| 8 | 通知公告 | 系统通知信息发布与已读管理 |
| 9 | 操作日志 | 操作记录查询（含异常信息） |
| 10 | 登录日志 | 登录记录查询（含异常登录） |
| 11 | 在线用户 | 活跃用户状态实时监控 |
| 12 | 定时任务 | 在线 Cron 任务调度（基于 Quartz） |
| 13 | 代码生成 | 一键生成前后端 CRUD 代码（基于 Velocity） |
| 14 | 系统接口 | 基于 SpringDoc 自动生成 API 文档（Swagger UI） |
| 15 | 服务监控 | CPU、内存、JVM、磁盘使用率实时监控 |
| 16 | 缓存监控 | Redis 信息查询、命令统计 |
| 17 | 在线构建器 | 拖拽表单元素生成 HTML 代码 |
| 18 | 连接池监控 | Druid 数据库连接池状态监控与 SQL 分析 |

---

## 八、数据库设计

数据库为 MySQL，初始化 SQL 脚本位于 `sql/` 目录下：

- `ry_20260417.sql`：主业务数据表（用户、角色、菜单、部门、字典等系统核心表及初始数据）
- `quartz.sql`：Quartz 定时任务框架所需的持久化表

核心业务表包含（从代码中推断）：

- `sys_user`：系统用户表
- `sys_role`：角色表
- `sys_menu`：菜单权限表
- `sys_dept`：部门表
- `sys_post`：岗位表
- `sys_user_role`：用户角色关联表
- `sys_user_post`：用户岗位关联表
- `sys_role_menu`：角色菜单关联表
- `sys_role_dept`：角色部门关联表（数据权限）
- `sys_config`：参数配置表
- `sys_dict_type`：字典类型表
- `sys_dict_data`：字典数据表
- `sys_notice`：通知公告表
- `sys_notice_read`：通知已读记录表
- `sys_oper_log`：操作日志表
- `sys_logininfor`：登录日志表
- `gen_table`：代码生成表
- `gen_table_column`：代码生成字段表
- `sys_job`：定时任务表
- `sys_job_log`：定时任务日志表

---

## 九、开发与部署

### 9.1 环境要求

- **JDK**：17+
- **MySQL**：5.7+
- **Redis**：默认配置即可
- **Maven**：3.6+
- **Node.js**：8.9+

### 9.2 后端开发

```bash
# 1. 导入数据库
# 在 MySQL 中依次执行 sql/ry_20260417.sql 和 sql/quartz.sql

# 2. 修改配置
# 编辑 ruoyi-admin/src/main/resources/application.yml
#   - 数据库连接（spring.datasource.druid）
#   - Redis 连接（spring.data.redis）

# 3. 启动应用
# 运行 ruoyi-admin/src/main/java/com/ruoyi/RuoYiApplication.java
# 服务端口默认 8080
```

### 9.3 前端开发

```bash
cd ruoyi-ui
npm install --registry=https://registry.npmmirror.com
npm run dev
# 前端默认端口 80，代理后端 8080
```

### 9.4 构建与部署

```bash
# 后端打包
mvn clean package

# 前端构建
cd ruoyi-ui
npm run build:prod        # 生产环境
npm run build:stage       # 测试环境
```

### 9.5 关键配置项

- **令牌有效期**：默认 30 分钟（`token.expireTime`）
- **密码最大错误次数**：5 次（`user.password.maxRetryCount`）
- **密码锁定时间**：10 分钟（`user.password.lockTime`）
- **验证码类型**：默认数学计算（`ruoyi.captchaType: math`）
- **文件上传路径**：支持自定义（`ruoyi.profile`）
- **XSS 防护**：默认开启（`xss.enabled: true`）
- **防盗链**：默认关闭（`referer.enabled: false`）

---

## 十、版本分支说明

RuoYi-Vue 多版本并行维护以满足不同的技术栈需求：

| 后端版本 | 说明 |
|----------|------|
| master 分支 | Spring Boot 4.x + JDK 17+（当前项目） |
| springboot3 分支 | Spring Boot 3.x + JDK 17+ |
| springboot2 分支 | Spring Boot 2.x + JDK 8+ |

| 前端版本 | Vue 版本 | 脚本语言 | 构建工具 |
|----------|----------|----------|----------|
| RuoYi-Vue（本仓库） | Vue 2 | JavaScript | Vue CLI |
| RuoYi-Vue3 | Vue 3 | JavaScript | Vite |
| RuoYi-Vue3-TypeScript | Vue 3 | TypeScript | Vite |

---

## 十一、总结

RuoYi-Vue 是一个成熟、稳定的企业级快速开发框架，具备以下突出特点：

**优势**

- 技术栈经典且稳定，社区资料丰富，学习成本低
- 模块化设计清晰，各模块职责分明，便于维护与扩展
- 完善的 RBAC 权限体系，覆盖菜单权限、按钮权限和数据权限三个层级
- 丰富的安全防护机制（XSS、CSRF、限流、防重复提交、数据脱敏等）
- 代码生成器是核心亮点，能显著提升 CRUD 类功能的开发效率
- 内置系统监控面板，运维友好
- 全部开源，文档完备，社区活跃

**适用场景**：适合作为企业内部管理系统、后台管理平台的开发基座，特别是需求中包含大量标准 CRUD 功能的场景。

**当前版本**：v3.9.2（Spring Boot 4.x + JDK 17 + Vue 2），持续维护中。
