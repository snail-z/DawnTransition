# DawnTransition 企业级落地指南（草案）

## 1. 背景与目标

- 背景
  - DawnTransition 是一个轻量、可扩展的 iOS 自定义转场框架。采用 Driver + 描述式动画（Producer/Stage/Modifier）分层设计，支持导航/模态转场、手势交互、常见过渡效果（push/pull/pageIn/pageOut/zoomSlide/fade 等）。
- 目标
  - 在功能不变化的前提下，确保在千万级用户规模下的稳定性、可观测性、可控性与可维护性。
  - 提供工程实践指南，使框架以“可灰度、可回退、可监控”的方式上线，降低与业务/第三方的冲突风险。

## 2. 架构概览

- 核心组件
  - `DawnDriver`（Sources/DawnTransition/DawnDriver.swift:31）：单例状态机，统一承接 `UIViewControllerTransitioningDelegate` 和 `UINavigationControllerDelegate`。
  - 描述式动画流水线：
    - `DawnAnimationType`（Sources/DawnTransition/DawnAnimationType.swift）将抽象动画类型映射为 `DawnModifierStage`。
    - `DawnModifier`/`DawnTargetState`（Sources/DawnTransition/DawnTransitionModifiers.swift）以“目标状态（位置、透明、圆角、阴影、变换、overlay、blur）”描述动画关键帧。
    - `DawnAnimationProducer`（Sources/DawnTransition/DawnAnimationProducer.swift）负责执行 Stage，结合 `DawnTransitionAdjustable`（Sources/DawnTransition/DawnTransitionAdjustable.swift）提供 `duration/curve/spring/snapshot` 等参数。
  - 手势交互（Sources/DawnTransition/UIView+DawnPanGestureRecognizer.swift）：方向/边缘识别、与 `UIScrollView` 冲突调度（`trackingView`）、阈值判定与 `finish/cancel`。
  - 交互线性化（Sources/DawnTransition/DawnTransition+Interactive.swift）：`Producer.regenerate`（线性 + 无弹性）；自定义动画通过 `DawnInteractiveConvertible` 临时切 `Producer`。
  - 控制器扩展（Sources/DawnTransition/UIViewController+Dawn.swift）：`isModalEnabled/isNavigationEnabled/transitionCapable/transitionAnimationType`；ObjC 桥接（ObjcDawnTransition.swift）。
- 转场流程
  - Modal：由 `transitioningDelegate` 进入 → `animateTransition` → `start` → `animate` → `complete`；
  - Navigation：通过 `push/pop` 的 swizzling + `UINavigationControllerDelegate` 注入 Driver。
- 稳定性增强（当前仓库已具备）
  - 转场期间禁用 containerView 交互，完成后恢复（Sources/DawnTransition/DawnTransition+UIViewControllerTransitioningDelegate.swift:55；Sources/DawnTransition/DawnTransition+Complete.swift:16）。
  - 导航期间禁用系统侧滑返回手势，完成后恢复（Sources/DawnTransition/DawnTransition+UINavigationControllerDelegate.swift:33–35；Sources/DawnTransition/DawnDriver.swift:62；Sources/DawnTransition/DawnTransition+Complete.swift:19–23）。
  - 手势 `prepare/begin` 时若正在转场则拒绝（Sources/DawnTransition/UIView+DawnPanGestureRecognizer.swift:173、295）。
  - 自定义动画的交互阶段可退化为 Producer，获得线性手感（Sources/DawnTransition/DawnTransition+Interactive.swift:13、74）。

## 3. 使用规范（建议）

- Modal 优先使用
  - `vc.dawn.isModalEnabled = true`
  - `vc.dawn.transitionCapable = DawnAnimationProducer.using(type: .pageIn(direction: .up))` 或者自定义 `DawnAnimationCapable`
- Navigation 接入
  - `page.dawn.isNavigationEnabled = true` → 自动 swizzle 接入
  - 对关键业务（对稳定性要求极高）建议提供“无 swizzle 模式”（只通过 `UINavigationControllerDelegate` 注入，见第 8 节改造建议）
- 交互手势
  - 使用 `DawnPanGestureRecognizer`；设置 `recognizeDirection`、`isRecognizeWhenEdges`；必要时用 `shouldPrioritize(by:)` 指定 `UIScrollView`
  - 拖拽中线性贴手指（已内置 `regenerate`）；交互结束根据进度/速度自动 `finish/cancel`
- 动画参数（默认推荐）
  - `duration`: 0.28~0.35；`curve`: `.easeInOut`
  - `spring`: 仅 present 使用；dismiss 视页面观感决定
  - `cornerRadius`: 6（可按需增大）
  - `overlay/阴影`：仅动画过程中显示，结束清理
  - `snapshotType`：优先 `.noSnapshot`；遇 Nav 白屏/blur 诉求时再用 `.slowSnapshot`

## 4. 风险点与规避

- 运行时 swizzling（高风险）
  - 风险：与其它库或业务自定义 swizzle 冲突，难排查。
  - 规避：
    - 仅在 `isNavigationEnabled` 时开启 swizzle（已实现）。
    - 提供“无 swizzle 导航接入模式”（第 8 节）。
    - 运行时检测/埋点：swizzle 前后方法 `IMP` 差异。
- 并发/多窗口
  - 单 Driver 限制，不支持并发/嵌套转场；文档明确约束；必要时断言提醒。
- 快照与特殊视图
  - `slowSnapshot` 使用 `layer.render` 不支持 blur；`WKWebView/Map/Metal` 显示或性能可能不佳。
  - 建议提供“自定义快照回调”或“降级策略”（第 8 节）。
- 方向/旋转/尺寸变更
  - 多依赖 `containerView.bounds`；建议配套 UI 测试覆盖横竖屏切换。

## 5. 可观测性（强烈建议）

- 埋点维度（最小集合）
  - 事件：转场开始/完成/取消（`isPresenting`、动画类型/类名、`from/to` VC、`duration`、是否交互、是否异常）
  - 错误：快照失败、上下文缺失、重复 `start/complete`、状态异常
  - 性能：耗时分布；卡顿帧（可选）
  - 冲突：swizzle 冲突检测
- 日志
  - DEBUG：打印关键事件/参数
  - Release：仅关键错误与监控埋点

## 6. 回退与降级

- Feature Flag（远端配置控制）：全局开关/页面白名单/黑名单
- 转场失败/异常自动 fallback：在 `transitioningDelegate` 返回 `nil`，退回系统默认转场
- 低端机/高负载降级：关闭阴影/blur，使用 `.noSnapshot`，延长 `duration`

## 7. 灰度与发布流程

- 分阶段灰度：单页 → 模块 → 全量
- 监控指标：Crash/ANR、页面停留异常（转场未完成超时）、转场失败率、卡顿
- 回滚：关闭 Feature Flag 即可

## 8. 改造建议（后续增量）

- 无 swizzle 的导航接入模式
  - 提供 `DawnNavigationProxy`（实现 `UINavigationControllerDelegate`），仅对指定 `UINavigationController` 注入，不对 `push/pop` 做 swizzle。
  - 业务选择：关键模块使用 Proxy；其它模块继续 swizzle，兼顾稳定与易用。
- 自定义快照回调
  - 在 `DawnAnimationProducer` 预处理（`preprocessFrom/ToModifiers`）加可选 `snapshotProvider(view) -> UIView?`；返回 `nil` 时走默认方案。
  - 针对 `WKWebView/Map/Metal` 进行专项处理或降级。
- 统一子视图管理收口
  - 动画类尽量不直接 `add/remove` from/to，统一交由 `complete(automated)` 收口，减少每个动画类的收尾差异。
- Fallback/埋点接口
  - 暴露 `DawnDelegate`（可选协议）：`willStartTransition/didCompleteTransition/didFail/shouldFallback`；
  - 内置埋点回调，业务注册实现。
- UI 自动化测试样例（XCUITest）
  - Push/Pop、Present/Dismiss：交互与非交互、取消与完成、横竖屏、滚动边缘
  - 特殊视图：`WKWebView/Map/Metal`

## 9. 维护与协作

- 代码规范
  - 新动画宜走 `Producer/Modifier` 路径；避免手写 `add/remove`；结束必须复位 corner/transform/overlay/shadow。
- 文档与示例
  - 输出：接入指南、常见问题（Nav 白屏、手势冲突）、参数推荐、性能建议
  - 示例：展示常见动画与手势组合配置

## 10. 附录：关键文件与行号索引

- DawnDriver 与状态机：`Sources/DawnTransition/DawnDriver.swift:31`
- Modal 接入：`Sources/DawnTransition/DawnTransition+UIViewControllerTransitioningDelegate.swift:11`
- Nav 接入与 swizzling：`Sources/DawnTransition/UINavigationController+DawnSwizzling.swift:13,31`；代理：`Sources/DawnTransition/DawnTransition+UINavigationControllerDelegate.swift:25`
- 动画流水线：
  - Type/Stage：`Sources/DawnTransition/DawnAnimationType.swift`
  - Modifier/TargetState：`Sources/DawnTransition/DawnTransitionModifiers.swift`
  - Producer 执行：`Sources/DawnTransition/DawnAnimationProducer.swift`
  - Adjustable 参数：`Sources/DawnTransition/DawnTransitionAdjustable.swift`
- 手势交互：
  - 识别与冲突：`Sources/DawnTransition/UIView+DawnPanGestureRecognizer.swift`
  - 线性化与临时 Producer：`Sources/DawnTransition/DawnTransition+Interactive.swift`
- 稳定性增强（已加）：
  - 禁容器交互：`Sources/DawnTransition/DawnTransition+UIViewControllerTransitioningDelegate.swift:55`
  - 禁系统侧滑：`Sources/DawnTransition/DawnTransition+UINavigationControllerDelegate.swift:33`
  - 手势 `isTransitioning` 防御：`Sources/DawnTransition/UIView+DawnPanGestureRecognizer.swift:173,295`
- 新动画示例（ElasticSlide）：`Sources/DawnTransition/DawnAnimationElasticSlide.swift`

---

> 备注：本文为工程化落地草案，建议结合业务现状分阶段实施（先“埋点+灰度+禁交互”，再“无 swizzle 模式 + 统一收口 + 自定义快照”），并配合 UI 自动化测试与远端配置平台逐步放量上线。
