# 🧩 Link2AutoIt

**Link2AutoIt** is a high-performance bridge between Mozilla Firefox and AutoIt. It allows you to capture browser events (Hovers and Clicks) on links and images, sending the data directly to an AutoIt script in real-time.

🔗 link to AutoIt forum: https://www.autoitscript.com/forum/topic/213483-link2autoit-firefox-add-on

## 🧐 How it Works
The project uses **Native Messaging** combined with **Shared Memory (IPC)**. This architecture ensures that the AutoIt Listener remains lightweight and persistent, bypassing the limitation where the browser would normally close the host process after every message.

1. **Firefox Extension**: Monitors mouse events and sends JSON payloads.
2. **LinkHost.exe**: A tiny relay that writes data to Shared Memory.
3. **L2A_Proxy.exe**: The memory "anchor" that keeps the IPC bridge alive.
4. **Listener.au3**: Your custom script that reacts to the incoming data (e.g., displaying tooltips, logging, or automating tasks).

## 🚀 Key Features (v3.0.5)
- Sub-millisecond Latency: Uses Windows Shared Memory (IPC) for instant data transfer.
- Smart Logging: LinkHost automatically caps log files at 5KB to prevent disk bloat.
- Zero-CPU Proxy: L2A_Proxy.exe acts as a silent memory anchor with 0% resource impact.
- Automated Lifecycle: The UDF includes OnAutoItExitRegister to ensure all proxy processes are cleaned up when your script exits.
- Context-Aware Metadata: Captures Action (Hover/Click), Media Type (Link/Image), Domain, and Link Text.

## 🛠 Manual Troubleshooting
If the bridge seems inactive:
   - Check if L2A_Proxy.exe is visible in the System Tray.
   - Inspect %LocalAppData%\Link2AutoIt\LinkHost.log (it captures the first 5KB of every session for easy debugging).
   - Ensure the Firefox Extension is enabled in about:addons.

## 🛠 Installation
1. Download the latest release.
2. Run `Link2AutoIt_Installer.exe` as Administrator.
3. The installer will:
   - Copy all necessary binaries to `%LocalAppData%\Link2AutoIt`.
   - Register the Native Messaging host in the Windows Registry.
   - Install the signed Firefox Extension (XPI).
4. Restart Firefox and you are ready!

## 📂 Project Structure
- `/bin`: Compiled binaries and the signed `.xpi` file.
- `/extension`: JavaScript source for the WebExtension.
- `/Icons`: Icons files for the compiled files.
- `/src`: AutoIt source code.

## ⚖ License
This project is open-source and available under the MIT License.

