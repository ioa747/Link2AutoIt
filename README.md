# 🧩 Link2AutoIt

**Link2AutoIt** is a high-performance bridge between Mozilla Firefox and AutoIt. It allows you to capture browser events (Hovers and Clicks) on links and images, sending the data directly to an AutoIt script in real-time.

## 🧐 How it Works
The project uses **Native Messaging** combined with **Shared Memory (IPC)**. This architecture ensures that the AutoIt Listener remains lightweight and persistent, bypassing the limitation where the browser would normally close the host process after every message.

1. **Firefox Extension**: Monitors mouse events and sends JSON payloads.
2. **LinkHost.exe**: A tiny relay that writes data to Shared Memory.
3. **Proxy.exe**: The memory "anchor" that keeps the IPC bridge alive.
4. **Listener.au3**: Your custom script that reacts to the incoming data (e.g., displaying tooltips, logging, or automating tasks).

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
