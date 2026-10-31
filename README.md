# PadPlay（打击垫）

iPhone / iPad 横屏专用的 SwiftUI 打击垫 App（仅 Landscape Left / Right）：左侧保持旋钮 + 小圆钮 + 圆形走带的硬件感布局，右侧 **固定 4×4 正方形垫格**，内置鼓组采样，无需外接电脑即可发声。

**PadPlay** 自有品牌；布局仅作常见 Pad 控制器致敬，与任何硬件商标无关。

## 面向谁

完全新手：只想敲鼓听声。默认中文，左上品牌旁 / 控制区右上 **中 / EN** 切换界面语言。

## 环境要求

- macOS + Xcode 15 或更高（iOS 17+ SDK）
- 可选：Apple Developer 账号（真机安装）

建议路径：`~/projects/PadPlay/`

## 打开与运行

1. 打开 `PadPlay.xcodeproj`
2. 目标 **PadPlay**，设备选 **iPhone** 或 **iPad**（系统会锁定横屏）
3. Signing 使用工程内已填 Team（`T626DDUR47`）→ **Run (⌘R)**
4. 点右侧垫格应立即有鼓声

## 左侧控件（新手文案）

| 中文 | English | 作用 |
|------|---------|------|
| 音量 / 回响 / 音色 / 音调 | Volume / Reverb / Tone / Pitch | 四个旋钮 |
| 鼓组 | Kit | 切换原声鼓 / 电子鼓 / 打击乐 |
| 力度 | Touch | 轻 / 中 / 重 / 固定 |
| 节拍器 | Click | 开关嘀嗒声 |
| 打拍子 | Tap Beat | 连点设定速度 |
| 连击 | Hold-Repeat | 按住垫自动连敲 |
| 清轨 | Clear | 清空已录循环 |
| 开头 / 停止 / 快进 / 录音 / 播放 / 循环 | Start / Stop / Skip / Record / Play / Loop | 圆形走带 |

## 说明

- 云端 Linux 无法跑 iOS Simulator，请在 Mac Xcode 编译。
- Bundle ID 默认 `com.padplay.app`。
