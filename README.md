
# A. 需求落盘与信息架构（iOS / SwiftUI）

## 已确认决策（简表）

* **平台**：iOS（SwiftUI）
* **登录**：Sign in with Apple + WeChat（登录页提供双入口）
* **主导航**：**拍照为主 + 辅助抽屉**（主屏相机；右侧滑出抽屉含：地图、历史、设置）
* **定位**：默认精确，可切换模糊
* **播放**：支持**流式 TTS**、倍速、跳句、回听 15s
* **语言/声音**：默认跟随系统；支持中/英/日切换与偏好记忆
* **文本编辑**：**不支持**
* **缓存**：允许离线；上限 **500MB**
* **回退**：生成失败时展示文字草稿并提示稍后补音频
* **反馈**：播放页支持「有用/无用 + 重新生成」
* **后台**：上传/生成在后台继续，完成**本地通知**
* **地图**：展示附近热门卡片（评分、播放次数、距离）
* **来源标识**：**不显示**
* **隐私**：允许用于改进服务（默认开）
* **埋点**：全链路事件 + 崩溃日志
* **性能目标**：命中 < 3s 首帧；新生成 < 8s 首帧

## 信息架构（IA）

* **主屏（相机）**

  * 全屏相机预览 + 大快门
  * 顶部定位条（国家/城市/POI，右侧“精准/模糊”切换）
  * 快门左侧 gallary thumbnail button
  * 快门右侧 a chat bubble button (💬) at bottom-right which opens a chat overlay
  * **右缘滑出抽屉**：地图、历史、设置（亦可长按屏幕右缘唤出）
* **地图**（抽屉或独立页呈现，保留“返回相机”浮钮）
* **历史/离线**（列表 + 搜索/筛选 + 管理缓存）
* **播放结果**（卡片播放器 + 流式进度 + 反馈）
* **设置**（语言/声音、缓存、网络策略、隐私开关、关于）
* **登录**（首启或在设置中进入：Apple/WeChat）

---

# B. 交互方案与技术落地

## 关键用户流（状态机）

1. **Capture 流**
   `idle → locating → preview → capture → upload → matching → generating → tts → ready`

* 顶部**分段进度条**复用一条进度：上传 ▸ 检索 ▸ 生成 ▸ 语音
* 任一环节失败 → toast + 回退策略（可展示文字草稿）

3. **播放流（流式）**
   命中：收到 `audio_url` 或音频分片即**先声后图**（先播、后补封面）
   新生成：先展示**加载波形**与秒表，首帧可播即启动

4. **后台与通知**
   上传/生成进入后台：使用 `BackgroundTasks` + 本地通知「讲解已准备就绪，点此播放」

## 主要页面交互要点

* **相机页**：快门点击拍照；右缘滑动 16–24pt 触发抽屉；弱网时顶部黄条“将以文字回退”
* **播放页**：倍速 0.8/1.0/1.25/1.5；**回退 15s**、**下一句**；「👍/👎/重新生成」在控制区旁
* **地图页**：底部半屏卡片（可上拉全屏），横向滑卡片切换附近点；卡片内直接「播放」
* **历史页**：按地点/时间/是否离线筛选；右上“管理”→批量删除缓存
* **登录**：首次可跳过；设置中可随时绑定

## 设计系统（Design Tokens）

* 主色 `#0A84FF`（iOS 蓝）；辅色 `#34C759`；警示 `#FF3B30`
* 圆角：12 / 16 / 24；阴影：iOS 原生 + 毛玻璃
* 字体：SF Pro（Title Semibold、Body Regular）；支持 Dynamic Type
* 图标：SF Symbols（播放、暂停、下载、定位、相册、速度、返回 15s）

## iOS 技术选型与结构

* **框架**：SwiftUI + Combine / Swift Concurrency (async/await)
* **相机**：AVFoundation（自定义 `UIViewRepresentable` 预览层）
* **定位/地图**：CoreLocation + MapKit
* **音频**：`AVPlayer`（支持 HLS/分段流），波形可后续加
* **网络**：`URLSession` + `URLSessionStreamTask` 或 HTTP/2 SSE；弱网重试（指数退避）
* **后台**：`BGProcessingTaskRequest` / `BGAppRefreshTaskRequest`
* **缓存**：音频/图片落地 `FileManager` + 索引 DB（可用 `SQLite.swift` 或 Core Data）
* **登录**：AuthenticationServices（Sign in with Apple），WeChat SDK（通过 URL Scheme）
* **埋点**：Apple `MetricKit` + 自建事件上报（见下表）

### 目录与 MVVM 组织（建议）
TBD

## 客户端-服务端接口（对齐）
TBD

> 说明：如果采用 SSE/流式，客户端优先走单连接监听任务状态；否则轮询 500ms–1s，异常退避。

## 缓存与网络策略

* 图片上传前本地压缩：最长边 1280px，JPEG 0.85
* LRU 缓存上限 500MB（音频优先级高于缩略图）
* 开关：“仅 Wi-Fi 下载音频”（默认跟随系统蜂窝/流量状态）

## 回退与错误

* **匹配失败**：展示“无匹配，正在生成…”；若 GPT/TTS 失败 → 展示文字草稿，可稍后补音频
* **权限拒绝**：相机/定位空态页 + 去设置
* **登录失败**：可离线匿名继续，但收藏/历史同步与多端同步受限

## 埋点（事件名建议）
TBD

* 关键 KPI：**首帧可播时长**、命中率、生成失败率、离线命中率

---

# C. Figma 提示词包

> 统一规范：iOS 18 风格；iPhone 15 Pro 画板；SF Pro；主色 #0A84FF；圆角 16；毛玻璃与柔和阴影；Auto Layout + 约束；支持浅/深色；**导航为“拍照主屏 + 右侧滑出抽屉”**。

## 1) 主屏（相机 + 右侧抽屉）   
Design an iOS camera home screen for a travel narration app. Elements: full-screen camera preview; centered circular shutter at bottom; gallery thumbnail at bottom-left; aand a chat bubble button (💬) at bottom-right which opens a chat overlay.; a top location pill (country/city/POI with a “Precise/Reduced” toggle on the right); a “Import from Photos” button at top-right. Add a right-edge slide-out drawer handle (16px) that reveals three items: Map, Settings (icon + label, large rounded list). After capture, show a segmented progress bar at the top with states (Upload, Match, Generate, TTS). Clean, native feel, 16-radius, glassmorphism, light/dark.

---

Chat overlay
One page in a IOS app: Design a semi-transparent Chat Overlay sitting above the live camera view.
Rounded 24, glassmorphic background.
Header: “AI Travel Guide Chat” with a close arrow.
Scrollable conversation area with grouped histories — each group shows a small photo thumbnail, location title, and chat bubbles (user: gray, AI: blue).
Bottom input bar: mic 🎙️, text field, send ➤.
Supports swipe-down to dismiss. Keep the layout clean, minimal, and native.

## 2) 播放结果页（流式播放器）  

Design an “Audio Playback” screen: cover image at top (captured photo); title with place name, subtitle with city and date; progress bar with timestamps; controls: Play/Pause, Back 15s, Next sentence, Speed (0.8/1.0/1.25/1.5). Top-right “Download for offline” icon; beside controls, show “👍 Useful / 👎 Not useful / Regenerate”. If audio not ready, show waveform skeleton and “Preparing first frame”. Card over blurred background, 16-radius.

---

## 3) 地图页（底部半屏卡片）

Design a map screen: full-screen map with user location; a **pull-up bottom sheet** listing nearby narration spots as horizontally scrollable cards (cover, title, **distance**, Play button, popularity/rating). Keep a small round “Back to Camera” button at top-right. Prioritize native look and smooth gestures.

---

## 4) 历史与离线库

Design a library screen: rows include cover, place name, date, duration, and an offline badge. A top search bar and filters (location/time/offline). A “Manage” button on top-right for bulk cache deletion. Include an empty state illustration and hint text. Native, card-based style.

---

## 5) 首次启动与权限引导

Design a 3-step onboarding: value proposition → camera permission → location permission. Each step has an illustration and a one-line explanation with the “While Using the App” option. If denied, show an empty state with an “Open Settings” button.

---

## 6) 登录页（Apple + WeChat）

Design a sign-in screen: brand header; two large buttons “Continue with Apple” and “Continue with WeChat”; a secondary “Continue as Guest” at the bottom. Include brief privacy text and a consent toggle (default on, for service improvement).

---

## 7) 设置页

Design a settings screen: Language & TTS voice (CN/EN/JP + Voice A/B); Playback preferences (auto play, default speed, auto play on headphones); Network & Cache (Wi-Fi only, 500MB cap, clear cache); Privacy (Improve service toggle, default on); About & Feedback.

---

## 8) 错误/回退与通知

Design error/fallback components: yellow info banner (poor network / text fallback), red error banner (upload/generation failed) with a “Retry” button; a local notification preview card (“Your narration is ready — tap to play”).

---

## 9) 抽屉（右侧滑出）

Design the right slide-out drawer: large rounded list items for “Map”, “Library”, and “Settings”; each with icon + title + short description. Show user sign-in status at the top (avatar with Apple/WeChat badge). At the bottom, display cache usage (progress bar) with a “Clear Cache” button.

---

## 10) 分段进度条（上传 ▸ 检索 ▸ 生成 ▸ 语音）

Design a horizontal segmented progress bar with 4 steps and icons/labels (Upload, Match, Generate, TTS). Support states: active (highlighted), done (solid), pending (muted). Provide as a reusable component for both home and playback screens.


