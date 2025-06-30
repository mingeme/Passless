# Passless

Passless 是一个用 Swift 构建的简单的 macOS 密码管理器。它旨在提供一种轻量级且方便的方式来存储和访问您的密码，而无需复杂的设置。

## 功能

- **快速搜索:** 通过一个简单的界面即时搜索您的账户。
- **一键粘贴:** 轻松将密码复制到剪贴板，以便快速登录。
- **菜单栏访问:** 可通过菜单栏图标方便地访问您的密码。
- **开机自启** 可选择配置应用在登录时自动启动。

## 如何构建和运行

1.  **克隆仓库:**

```bash
git clone https://github.com/mingeme/Passless.git
cd Passless
```

2.  **打开项目:**

使用 Xcode 打开 `Passless.xcodeproj` 文件。

3.  **运行应用:**

在 Xcode 中，选择 `Product` > `Run` (或按下 `Cmd+R`) 来构建和运行该应用程序。

## 技术栈

- **Swift:** 项目的主要编程语言。
- **SwiftUI:** 用于构建用户界面。
- **AppKit:** 与 macOS 原生功能集成。
