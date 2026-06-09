# RuoYi-Vue 学习路线：从入门到精通

> 目标：通过 RuoYi-Vue 项目，系统提升 Java 后端开发能力

---

## 阶段一：项目认知与环境搭建（1-2 天）

### 1.1 认识项目全貌

浏览项目顶层目录，理解 6 个模块的分工：

| 模块 | 角色 | 关键依赖 |
|------|------|---------|
| `ruoyi-admin` | Web 层（启动入口 + Controller） | Spring Boot 自动配置 |
| `ruoyi-framework` | 框架核心层 | Spring Security, JWT, Redis |
| `ruoyi-system` | 业务服务层 | MyBatis, PageHelper |
| `ruoyi-common` | 公共工具层 | 无外部依赖 |
| `ruoyi-quartz` | 定时任务层 | Quartz |
| `ruoyi-generator` | 代码生成器 | Velocity 模板引擎 |

要读的文件：**`pom.xml`** — 看依赖管理和模块组织方式，注意 Spring Boot 4.0 + JDK 17。

### 1.2 本地启动

准备环境：
- JDK 17+
- MySQL（创建 `ry-vue` 数据库，导入 `sql/` 下的脚本）
- Redis（默认 localhost:6379）
- 运行 `RuoYiApplication.java`

---

## 阶段二：阅读入口 & 配置（2 天）

### 2.1 启动入口

> **`ruoyi-admin/.../RuoYiApplication.java`**

关键知识点：
- `@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})` — 为什么要排除数据源自动配置？（因为多数据源需要手动配）
- Spring Boot 的自动配置原理

### 2.2 核心配置文件

> **`ruoyi-admin/src/main/resources/application.yml`**

逐行阅读，关注：
- `server.tomcat.threads` — Tomcat 线程池调优
- `spring.data.redis` — Redis 配置
- `token` 配置段 — JWT 令牌的 header 名称、密钥、过期时间
- `mybatis` — typeAliasesPackage 和 mapperLocations 的约定
- `pagehelper` — 分页插件的方言配置
- `springdoc` — API 文档配置

---

## 阶段三：深入理解请求处理流程（3-4 天）

这是最重要的阶段。按以下顺序阅读代码，**追踪一个完整的请求流程**。

### 3.1 从 Controller 开始

> **`SysLoginController.java`** — 登录接口
> **`SysUserController.java`** — 用户 CRUD

**要学习的设计模式：**
1. **RESTful 风格** — 观察 `@GetMapping` / `@PostMapping` / `@PutMapping` / `@DeleteMapping` 的用法
2. **参数接收** — `@RequestBody`、`@PathVariable`、`@Validated` 校验
3. **权限控制** — `@PreAuthorize("@ss.hasPermi('system:user:list')")` 的 SpEL 表达式

动手练习题：
- 找到 `SysUserController` 的 `list()` 方法，追踪完整的调用链：`list() → userService.selectUserList() → userMapper.selectUserList() → UserMapper.xml`

### 3.2 理解统一响应模型

> **`AjaxResult.java`** — 统一响应类
> **`BaseController.java`** — 控制器基类

**要学习的关键模式：**
- **继承 `HashMap`** 实现动态 JSON 响应 — `AjaxResult` 直接继承 `HashMap`，利用 `put()` 构造 JSON
- **静态工厂方法** — `success()` / `error()` / `warn()` 方法
- **模板方法模式** — `BaseController` 提供 `startPage()`、`getDataTable()`、`toAjax()` 等通用方法

动手问题：
- 为什么 `AjaxResult` 要继承 `HashMap` 而不是用 `@Data` 注解的 POJO？

### 3.3 理解 BaseEntity 基类

> **`BaseEntity.java`**

所有实体类的父类，定义了 `createBy`、`createTime`、`updateBy`、`updateTime` 和 `params`（扩展参数 Map）。

关键设计：
- `@JsonIgnore` 在 `searchValue` 上 — 搜索值不返回前端
- `@JsonInclude(Include.NON_EMPTY)` 在 `params` 上 — 空参数不序列化
- `params` 字段 — 用于传递查询条件，避免修改实体类

### 3.4 理解分页机制

> **`PageDomain.java`**、**`TableSupport.java`**、**`TableDataInfo.java`**

RuoYi 的通用分页流程：
1. 前端传 `pageNum` 和 `pageSize`
2. Controller 调用 `startPage()` → `PageHelper.startPage(pageNum, pageSize)`
3. MyBatis 查询时自动拼接 `LIMIT` 语句
4. Controller 调用 `getDataTable(list)` → 包装成 `TableDataInfo` 响应

---

## 阶段四：深入框架核心（5-7 天）

这是项目最有价值的部分，包含大量企业级实践。

### 4.1 认证与授权流程

> 文件路径: `ruoyi-framework/src/main/java/com/ruoyi/framework/web/service/`
> **`SysLoginService.java`** — 登录服务
> **`TokenService.java`** — JWT Token 服务

**核心流程：**
```
登录请求 → SysLoginController.login()
  → SysLoginService.login()  // 校验验证码、用户名密码
    → AuthenticationManager.authenticate()  // Spring Security 认证
    → TokenService.createToken()  // 生成 JWT Token
    → Redis 存储用户信息（login_user:token）
```

**要理解的关键技术：**
1. **JWT 无状态认证** — Token 中存储 userId，用户信息存 Redis
2. **Token 刷新机制** — 每次请求自动刷新过期时间
3. **SecurityUtils** — 封装 SecurityContextHolder 的操作

### 4.2 数据权限（DataScope）

> **`@DataScope` 注解** + **DataScopeAspect 切面**

这是 RuoYi 最有特色的设计之一。

**核心思路：**
1. 在 Service 方法上加 `@DataScope(deptAlias = "d", userAlias = "u")`
2. AOP 切面拦截方法执行，根据当前用户的角色自动拼接 SQL 过滤条件
3. 最终 MyBatis 的 SQL 中多出 `AND d.dept_id IN (...)` 或 `AND u.user_id = ...`

**5 种数据权限级别：**
- 仅本人数据
- 本部门数据
- 本部门及以下数据
- 自定义数据
- 全部数据

### 4.3 操作日志（AOP 切面）

> **`@Log` 注解** + **LogAspect 切面**

**核心流程：**
1. Controller 方法上加 `@Log(title = "用户管理", businessType = BusinessType.INSERT)`
2. LogAspect 在方法执行前后记录请求参数、响应结果、执行时间
3. 异步写入数据库（通过 AsyncManager）

**要学习的点：**
- **AOP 环绕通知** `@Around`
- **异步处理** — 使用线程池异步写日志，避免阻塞主流程
- **Log 注解的设计** — 注解属性的默认值、枚举类型使用

### 4.4 验证码 & 限流 & 防重复提交

> **`@RateLimiter`** — 基于 Redis 的接口限流
> **`@RepeatSubmit`** — 防止表单重复提交
> **`CaptchaController`** — 验证码生成

---

## 阶段五：MyBatis 实战（2-3 天）

### 5.1 实体类与数据库映射

> **`SysUser.java`** — 实体示例

要观察的点：
- `@Excel` 注解 — 自定义导出/导入注解
- `@Xss` 注解 — 防止 XSS 攻击
- `@JsonProperty(access = WRITE_ONLY)` — 密码字段只写不读
- `@JsonFormat` — 日期格式化

### 5.2 Mapper 接口与 XML

查找 `ruoyi-system/src/main/resources/mapper/system/SysUserMapper.xml`，观察：
- 动态 SQL 的构建（`<if>`、`<where>`、`<foreach>`）
- 结果映射 `<resultMap>` 的关联映射（用户 → 部门）
- 分页语句的生成

### 5.3 代码生成器

> **`ruoyi-generator`** 模块

这是 RuoYi 生产力的核心：
1. 连接数据库读取表结构
2. Velocity 模板引擎渲染（Java Controller / Service / Mapper + Vue 页面）
3. 一键生成完整 CRUD

---

## 阶段六：动手实践（持续进行）

### 练习 1：为现有模块加一个字段

以用户管理为例：
1. 在 `sys_user` 表加字段（如 `id_card` 身份证号）
2. `SysUser.java` 加字段 + `@Excel` 注解
3. `SysUserMapper.xml` 的 SQL 加字段
4. 前端列表加列（如果有前端项目的话）

### 练习 2：新增一个业务模块

用代码生成器完成（也可以手动写）：
1. 建表（如 `t_product` 产品表）
2. 运行代码生成器
3. 配菜单 / 配权限
4. 启动看效果

### 练习 3：理解并修改权限

1. 给某个接口换一个权限标识
2. 新建一个角色，分配新权限
3. 验证数据权限过滤是否正确

### 练习 4：调试认证流程

1. 在 `SysLoginService.login()` 打断点
2. 跟踪 JWT Token 的生成和校验过程
3. 查看 Redis 中的 `login_tokens` 数据

### 练习 5：自定义注解

仿照 `@Log`，写一个 `@OperationTime` 注解记录方法执行时间：
1. 定义注解
2. 写 AOP 切面
3. 加到某个方法上测试

---

## 各阶段 Java 技术点速查表

| 阶段 | 技术点 | 核心类/文件 |
|------|--------|------------|
| 三 | 泛型与集合 | `AjaxResult extends HashMap` |
| 三 | 枚举 | `BusinessType`, `OperatorType` |
| 三 | 日期处理 | `DateUtils` |
| 四 | 注解 | `@Log`, `@DataScope`, `@RateLimiter` |
| 四 | AOP 切面 | `LogAspect`, `DataScopeAspect` |
| 四 | SpEL 表达式 | `@PreAuthorize("@ss.hasPermi(...)")` |
| 四 | 线程池 | `AsyncManager`, `AsyncFactory` |
| 四 | Redis 操作 | `RedisCache` |
| 四 | JWT | `TokenService` |
| 五 | MyBatis 动态 SQL | `SysUserMapper.xml` |
| 五 | Lambda & Stream | `roles.stream().filter().collect()` |
| 所有 | 日志 | SLF4J + Logback (`logger.info/debug/error`) |
| 所有 | 校验 | Bean Validation (`@NotBlank`, `@Email`, `@Size`) |
| 所有 | 异常处理 | `GlobalExceptionHandler`, `BaseException` |

---

## 推荐学习顺序（每天 1-2 小时，共 2-3 周）

| 天数 | 学习内容 | 阅读文件 |
|------|---------|---------|
| 第 1-2 天 | 配置入口 + 启动 | `pom.xml`, `application.yml`, `RuoYiApplication.java` |
| 第 3-4 天 | 实体 + 统一响应 | `AjaxResult`, `BaseEntity`, `SysUser`, `BaseController` |
| 第 5-6 天 | Controller 层 | `SysUserController`, `SysLoginController` |
| 第 7-8 天 | Service + Mapper | `ISysUserService`, `SysUserMapper.xml` |
| 第 9-10 天 | 认证授权 | `SysLoginService`, `TokenService`, `SecurityUtils` |
| 第 11 天 | AOP 切面 | `LogAspect`, `DataScopeAspect` |
| 第 12 天 | 工具类 | `StringUtils`, `DateUtils`, `ExcelUtil` |
| 第 13 天 | 代码生成器 | `ruoyi-generator` 模块 |
| 第 14+ 天 | 实践练习 | 按阶段六的练习题动手 |

---

## 推荐的学习方法

1. **不要通读源码** — 有目的性地追踪一条请求链路
2. **打断点调试** — Eclipse/IDEA 下 F8/F9 一步步跟
3. **先看测试再读代码** — JUnit 测试是最好的文档
4. **思考"为什么这么设计"** — 比"它做了什么"更重要
5. **动手改造** — 不理解的部分自己改一改看效果
6. **对比框架** — 和 Spring Boot 官方示例对比，理解框架做了哪些封装

---

> *Java 学习的核心不是背 API，而是理解代码的组织方式和设计取舍。RuoYi 作为一个生产级项目，每一个设计决策背后都有其考量 —— 读懂了这些"为什么"，你就真正进步了。*
