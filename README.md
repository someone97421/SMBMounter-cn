![Hero Screenshot](images/SMBMounter-Banner.jpg)

# SMBMounter for macOS

[![Download SMBMounter](https://img.shields.io/badge/Download-SMBMounter-blue)](https://github.com/KeepCoolCH/SMBMounter/releases/tag/V.1.5)

**Automatically mount, reconnect, and manage SMB/WebDAV network drives** – directly from your macOS menu bar.  
Version **1.5** – developed by **Kevin Tobler** 🌐 [www.kevintobler.ch](https://www.kevintobler.ch)

---

## 界面语言

应用默认使用**简体中文**。点击菜单栏中的 SMBMounter 图标，在主界面顶部点击**地球图标**，即可切换为 **English** 或**简体中文**。

语言切换即时生效，无需重启；应用会保存选择，并在下次启动时继续使用。主界面、共享编辑表单、连接状态、提示和连接成功通知均支持中英文。

## 自动构建与发布

推送 `main` 后，GitHub Actions 会构建 Apple Silicon + Intel 通用版 DMG，并上传名为 `SMBMounter-macOS-universal` 的构建产物（保留 30 天）。也可在 Actions 中手动运行“构建与发布 DMG”。

推送 `v*` 标签时，工作流会在构建成功后自动创建 GitHub Release，上传 DMG 和 SHA-256 校验文件。发布前请更新工程版本与 `docs/发布说明.md`。仅推送 `main` 不会创建 Release。

构建使用 `macos-15` 与 Xcode 26.3，无需额外配置密钥；Release 使用工作流自带的 `GITHUB_TOKEN`。当前为临时签名，包含访达自动化权限，未进行 Developer ID 签名和 Apple 公证。

本地也可执行 `bash scripts/package-dmg.sh`，产物保存在 `dist/`，该目录不提交到 Git。

**已知问题：** 以 IP 配置服务器、但系统以主机名挂载时，可能误判为未连接；本地挂载路径带 `-1` 等后缀时，打开和断开操作可能使用错误路径。这部分尚未修复。


---

## 🔄 Changelog

### 🆕 Version 1.x
- **1.5**
  - 🔐 Added support for UPN-style usernames such as `abc@mydomain.local`
  - 🔗 SMB/WebDAV credentials are now percent-encoded correctly when creating Finder mount URLs
  - ↕️ Mount entries can now be reordered via drag and drop, with the chosen order saved automatically
- **1.4**
  - ✅ Fixed mounted-volume detection for shares whose names are substrings of existing volumes
  - 🔎 Mount status checks now compare remount URL host and share path exactly instead of using substring matching
  - 🧭 Shares with the same name on different servers can now be detected independently
- **1.3**
  - ✅ Fixed mounted-volume detection for share names containing spaces, e.g. `Emby Media`
  - 🔎 Mount status checks now handle percent-encoded remount URLs such as `Emby%20Media`
  - 🔐 Improved SMB/WebDAV credential popup handling by allowing longer interactive Finder mount sessions
  - ⚡ Interactive mount sessions now stop early as soon as the share is detected as mounted
- **1.2**
  - 🌐 Added **WebDAV** support alongside SMB
  - 🔐 WebDAV supports **HTTP/HTTPS** selection with automatic default ports
  - 🔌 Added configurable WebDAV port field for custom NAS/server setups
  - 🧭 WebDAV host handling supports plain hosts like `server.local`
  - 🔁 WebDAV connections use the same preflight, mount verification, disconnect, and auto-reconnect flow as SMB
  - 🧰 Improved menu bar icon fallback for menu bar manager compatibility
- **1.1**
  - 🔧 Reworked mount pipeline for higher reliability (clean preflight -> mount -> verify flow)
  - ⏱ Finder mount now runs with hard timeout handling to prevent hanging mount jobs
  - 🧵 Mount attempts are processed sequentially to avoid race conditions between parallel connects
  - 🌐 Improved host resolution with stable SMB reachability checks and Bonjour/local fallback logic
  - 🔁 Added extra retry passes after a failed/disconnected attempt for better wake/reconnect behavior
  - 🛑 Manual disconnect now cancels pending retry/mount flow for that share more consistently
  - 🙈 No more Finder error popups on mount timeout (timeouts are handled silently in-app)
- **1.0**
  - 💾 Auto-mount saved network shares at login  
  - 🔁 Auto-Reconnect after connection loss or sleep/wake events  
  - 🖥️ Modern SwiftUI menu bar interface with status indicators  
  - 🧭 Protocol support: **SMB**
  - ⚙️ Secure Keychain storage for credentials  

---

## 🚀 Features

- 🧠 **Auto-Reconnect** on network loss or after system sleep  
- 🔒 **Keychain Integration** – credentials are stored securely  
- 🌐 **SMB + WebDAV Support** – mount classic SMB shares and WebDAV targets  
- 🔐 **HTTP/HTTPS WebDAV Options** – choose scheme and custom port per connection  
- 💡 **Status Monitoring** – shows mount state in the menu bar  
- 💾 **Auto-Mount at Login** – keep all shares ready automatically  
- 🧩 **SwiftUI Interface** optimized for macOS Sonoma 14.6+ 
- 🌙 **Sleep/Wake Detection** for stable mounts  

---

## 📸 Screenshots

![Screenshot](images/SMBMounterV1-addshare.png)  
![Screenshot](images/SMBMounterV1-editor.png)  
![Screenshot](images/SMBMounterV1-overview.png)  

---

## ⚙️ How It Works

1. Add your **network targets** (SMB or WebDAV)  
2. Credentials are stored securely in the **macOS Keychain**   
3. The **menu bar** shows live status for all connections  

---

## 🔧 Installation

[![Download SMBMounter](https://img.shields.io/badge/Download-SMBMounter-blue)](https://github.com/KeepCoolCH/SMBMounter/releases/tag/V.1.5)

1. Download the latest **SMBMounter.app** release  
2. Move **SMBMounter.app** to your **Applications** folder  
3. Launch the app
4. Add your network drives and credentials  
5. Done — your shares will mount automatically!  

> 🧱 Requires macOS 14.6 Sonoma or newer

---

## 🧑‍💻 Developer

**Kevin Tobler**  
🌐 [www.kevintobler.ch](https://www.kevintobler.ch)  

---

## 📜 License

This project is licensed under the **MIT License** – feel free to use, modify, and distribute.
