# Notepad4 增强定制版 (x64 简体中文)

本项目是在原生便携版 **Notepad4 (x64 zh-Hans)** 的基础上，针对现代开发者的高频需求进行深度定制与扩展的增强版本。

在完全保留原生 Notepad4 **“极速启动、毫秒级响应、零侵入单文件、极低内存占用”** 优势的前提下，补齐了原生软件在脚本代码运行、现代深色主题和 Windows 系统集成等方面的短板，打造出轻快型“一键运行”文本与代码编辑器。主要方便学习不同脚本语言的语法，立刻执行打开的测试脚本查看结果，也能兼顾代替系统的记事本功能。



默认字体：Cousine Nerd  [字体下载](https://www.nerdfonts.com/font-downloads)
不同主题截图
![银色主题](https://github.com/sywoon/notepad4-runner/blob/master/docs/theme-silver.jpg)
![onedark主题](https://github.com/sywoon/notepad4-runner/blob/master/docs/theme-onedark.jpg)


---

## 🚀 核心扩展功能一览

### 1. `Ctrl + L` 通用多语言即时运行器 (Polyglot Runner)
- **原生痛点**：原生 Notepad4 的 `Ctrl + L`（运行文件）仅调用 Windows 系统关联打开文件，无法直接运行脚本。
- **扩展实现**：
  - 对 [Notepad4.exe](file:///C:/cinside/Notepad4_zh-Hans_x64_v26.08r6282/Notepad4.exe) 底层 `WM_COMMAND` 分发机制进行了汇编级安全 Patch，将 `Ctrl + L` 的执行流直接重定向至同目录下的调度核心 [run.bat](file:///C:/cinside/Notepad4_zh-Hans_x64_v26.08r6282/run.bat)。
  - 执行时**自动保存当前已修改文件**，并完整传递当前文件的绝对全路径。
  - **工作目录自适应**：在执行前自动切换至当前编辑文件所在目录（`cd /d "%TARGET_DIR%"`），确保代码内部读取相对路径配置或资源文件时绝对正常。
  - **智能防闪退控制台**：运行完毕后统一捕获并打印进程退出码（`[进程已结束，退出代码: %EXIT_CODE%]`），并通过 `pause` 稳定悬停窗口，便于排查错误与查看输出。
  - **进程返回链保护**：全面使用 `call` 保护调度包装脚本（如 `tsx.cmd`、`ts-node.cmd`、`npx.cmd` 等），防止 Windows CMD 控制权提前移交导致的控制台意外早退。

#### 📊 多语言调度支持矩阵

| 语言类型 | 识别扩展名 | 运行时 / 编译器探测与调用链路 |
| :--- | :--- | :--- |
| **Python** | `.py` | 自动显示 `python -V` 版本，执行 `python "%TARGET_FILE%"` |
| **TypeScript** | `.ts` | 级联探测：`tsx` -> `bun run` -> `ts-node` -> `npx -y tsx` |
| **TSX (React)** | `.tsx` | 级联探测：`tsx` -> `bun run` -> `npx -y tsx` |
| **JavaScript** | `.js`, `.mjs`, `.jsx` | 自动显示 `node -v` 版本，执行 `node "%TARGET_FILE%"` |
| **Lua** | `.lua`, `.wlua` | 优先探测本地 Lua 5.3 定制链，次级探测系统 `lua` / `luajit` |
| **CoffeeScript** | `.coffee` | 调用 `coffee "%TARGET_FILE%"` |
| **C 语言** | `.c` | 智能探测 `gcc` / `clang` 原地编译为同名 `.exe` 并执行 |
| **C++** | `.cpp`, `.cxx` | 智能探测 `g++` / `clang++` 原地编译为同名 `.exe` 并执行 |
| **Rust** | `.rs` | 调用 `rustc "%TARGET_FILE%"` 编译并立即启动对应二进制 |
| **Go** | `.go` | 调用 `go run "%TARGET_FILE%"` 即时编译运行 |
| **PowerShell** | `.ps1` | `powershell -ExecutionPolicy Bypass -File "%TARGET_FILE%"` |
| **Shell / Bash** | `.sh` | 调用 `bash "%TARGET_FILE%"` |
| **批处理** | `.bat`, `.cmd` | 调用 `call "%TARGET_FILE%"` 原地安全执行 |
| **其他类型** | 任意扩展名 | 默认策略：以系统预设方式直接调度执行并停留控制台 |

---

### 2. 精调 OneDark / Notepad2 现代语法高亮配色
- **配置载体**：[Notepad4.ini](file:///C:/cinside/Notepad4_zh-Hans_x64_v26.08r6282/Notepad4.ini)
- **配色特点**：
  - 融合了经典 **Notepad2 护眼方案** 与流行 **Atom/VS Code OneDark 配色**。
  - 对 20+ 种常用语法词法分析器（Scintilla Lexers）进行了全量精细调优（包括 JavaScript、TypeScript、Python、Lua、C/C++、Markdown、JSON、SQL、Batch、Ini、TOML、YAML 等）。
  - 背景色调柔和防视觉疲劳，关键字、字符串、函数名、注释与运算符具有高可辨识度的对比层次。
- **切换方式**：重命名Notepad4-onedark.ini / Notepad4-silver.ini 为Notepad4.ini替换它

---

### 3. Windows 任务栏跳转列表 (Jump List) 深度激活
- **原生痛点**：便携绿色版解压即用时，Windows 任务栏右键图标无法显示“最近打开的文件”列表。
- **系统级打通**：
  - 在当前用户注册表（`HKCU`，**无需管理员提权**）注册了合规的 `AppUserModelID`（`Notepad4 Text Editor`）及默认启动命令。
  - 批量注册登记了 30+ 种主流代码后缀关联（`SupportedTypes`），被系统合法认可进入最近列表。
  - 配合 [Notepad4.ini](file:///C:/cinside/Notepad4_zh-Hans_x64_v26.08r6282/Notepad4.ini) 中 `ShellAppUserModelID` 与 `ShellUseSystemMRU=1`，每次编辑与保存均自动通过 `SHAddToRecentDocs` 触达系统记录，体验完全对齐系统原生软件。

---

### 4. 完备的测试验证套件 (`test/`)
项目根目录内置了多语言验证用例，便于拉取仓库后或更换电脑时一键测试执行链路：
- `test/note4-test.ts`：测试 TypeScript 执行链路及控制台停留。
- `test/note4-test.js`：测试 Node.js 运行与版本显示。
- `test/note4-test.py`：测试 Python 运行与参数解析提示。
- `test/lua_test.lua`：测试 Lua 协程与复杂对象输出。
- `test/note4-test.coffee`：测试 CoffeeScript 解释执行。

---



---

## ⌨️ 常用快捷键速查

| 快捷键 | 功能描述 | 说明 |
| :--- | :--- | :--- |
| **`Ctrl + L`** | **一键运行当前文件** | **[核心增强]** 自动保存并通过 `run.bat` 调度控制台执行 |
| **`Ctrl + R`** | **运行命令弹窗** | 原生运行对话框，支持手动输入任意参数与命令 |
| **`Ctrl + N`** | **新建空白文档** | 原生极速新建 |
| **`Ctrl + O`** | **打开文件** | 标准打开文件对话框 |
| **`Ctrl + S`** | **保存文件** | 快速保存修改 |
| **`Ctrl + Shift + S`** | **另存为** | 另存为新文件 |
| **`F7`** | **切换文件视图** | 打开 matepath 文件浏览器 |
| **`Ctrl + F` / `Ctrl + H`** | **查找 / 替换** | 支持高亮查找、正则与多行匹配 |
| **`F12`** | **默认代码方案** | 切换当前文档对应的语法方案 |
| **`Ctrl + F12`** | **自定义语法方案** | 打开语法方案定制界面 |

---

## 🛠️ 自定义与二次扩展

如果需要为你喜爱的其他语言添加执行支持，只需用 Notepad4 打开 [run.bat](file:///C:/cinside/Notepad4_zh-Hans_x64_v26.08r6282/run.bat)，在扩展名路由区增加对应分支：

```bat
if /i "%EXT%"==".your_ext" goto RUN_YOUR_LANG

:RUN_YOUR_LANG
call your_compiler_or_runtime "%TARGET_FILE%"
goto FINISH
```

保存后直接按下 `Ctrl + L` 即可立即生效！
