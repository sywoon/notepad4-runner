@echo off
setlocal enabledelayedexpansion
title Notepad4 Runner - %~nx1

:: 检查是否传入了文件路径
if "%~1"=="" (
    echo [ERROR] 未传入任何文件路径！
    echo 用法: run.bat "文件全路径"
    echo.
    pause
    exit /b 1
)

:: 提前捕获文件的绝对路径与元信息（防止cd后相对路径二次解析错位）
set "TARGET_FILE=%~f1"
set "TARGET_DIR=%~dp1"
set "TARGET_NAME=%~nx1"
set "EXT=%~x1"

:: 切换工作目录至当前打开的文件所在目录
cd /d "%TARGET_DIR%"

echo ======================================================================
echo [Notepad4 Runner]
echo 当前文件: %TARGET_NAME%
echo 全路径  : %TARGET_FILE%
echo 所在目录: %TARGET_DIR%
echo 扩展名  : %EXT%
echo ======================================================================
echo.

:: 根据文件后缀名进行调度执行
if /i "%EXT%"==".bat" goto RUN_BAT
if /i "%EXT%"==".cmd" goto RUN_BAT
if /i "%EXT%"==".py" goto RUN_PYTHON
if /i "%EXT%"==".lua" goto RUN_LUA
if /i "%EXT%"==".wlua" goto RUN_LUA
if /i "%EXT%"==".js" goto RUN_NODE
if /i "%EXT%"==".mjs" goto RUN_NODE
if /i "%EXT%"==".jsx" goto RUN_NODE
if /i "%EXT%"==".ts" goto RUN_TS
if /i "%EXT%"==".tsx" goto RUN_TSX
if /i "%EXT%"==".coffee" goto RUN_COFFEE
if /i "%EXT%"==".c" goto RUN_C
if /i "%EXT%"==".cpp" goto RUN_CPP
if /i "%EXT%"==".cxx" goto RUN_CPP
if /i "%EXT%"==".rs" goto RUN_RUST
if /i "%EXT%"==".go" goto RUN_GO
if /i "%EXT%"==".ps1" goto RUN_POWERSHELL
if /i "%EXT%"==".sh" goto RUN_BASH

:: 默认策略：直接调用系统默认方式执行
goto RUN_DEFAULT

:RUN_BAT
call "%TARGET_FILE%"
goto FINISH

:RUN_PYTHON
python -V 2>nul
echo ----------------------------------------------------------------------
echo.
python "%TARGET_FILE%"
goto FINISH

:RUN_LUA
if exist "C:\cinside\lua5.3\runlua.bat" (
    set "path=C:\cinside\lua5.3;%path%"
    call "C:\cinside\lua5.3\runlua.bat" "%TARGET_FILE%"
    goto FINISH
)
where lua >nul 2>nul
if %ERRORLEVEL% equ 0 (
    lua -v 2>nul
    lua "%TARGET_FILE%"
) else (
    where luajit >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        luajit "%TARGET_FILE%"
    ) else (
        echo [ERROR] 未找到 lua 或 luajit 解释器！
    )
)
goto FINISH

:RUN_NODE
echo nodejs version:
node -v 2>nul
echo ----------------------------------------------------------------------
echo.
node "%TARGET_FILE%"
goto FINISH

:RUN_TS
where tsx >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call tsx "%TARGET_FILE%"
) else (
    where bun >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        call bun run "%TARGET_FILE%"
    ) else (
        where ts-node >nul 2>nul
        if !ERRORLEVEL! equ 0 (
            call ts-node "%TARGET_FILE%"
        ) else (
            call npx -y tsx "%TARGET_FILE%"
        )
    )
)
goto FINISH

:RUN_TSX
where tsx >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call tsx "%TARGET_FILE%"
) else (
    where bun >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        call bun run "%TARGET_FILE%"
    ) else (
        call npx -y tsx "%TARGET_FILE%"
    )
)
goto FINISH

:RUN_COFFEE
call coffee "%TARGET_FILE%"
goto FINISH

:RUN_C
where gcc >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [GCC] 正在编译 %TARGET_NAME% ...
    gcc "%TARGET_FILE%" -o "%~n1.exe"
    if !ERRORLEVEL! equ 0 (
        echo [GCC] 编译成功，启动运行:
        echo ----------------------------------------------------------------------
        "%~n1.exe"
    ) else (
        echo [GCC] 编译失败！
    )
) else (
    where clang >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        echo [Clang] 正在编译 %TARGET_NAME% ...
        clang "%TARGET_FILE%" -o "%~n1.exe"
        if !ERRORLEVEL! equ 0 (
            echo [Clang] 编译成功，启动运行:
            echo ----------------------------------------------------------------------
            "%~n1.exe"
        ) else (
            echo [Clang] 编译失败！
        )
    ) else (
        echo [WARN] 未找到 gcc 或 clang 编译器，尝试直接执行...
        "%TARGET_FILE%"
    )
)
goto FINISH

:RUN_CPP
where g++ >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [G++] 正在编译 %TARGET_NAME% ...
    g++ "%TARGET_FILE%" -o "%~n1.exe"
    if !ERRORLEVEL! equ 0 (
        echo [G++] 编译成功，启动运行:
        echo ----------------------------------------------------------------------
        "%~n1.exe"
    ) else (
        echo [G++] 编译失败！
    )
) else (
    where clang++ >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        echo [Clang++] 正在编译 %TARGET_NAME% ...
        clang++ "%TARGET_FILE%" -o "%~n1.exe"
        if !ERRORLEVEL! equ 0 (
            echo [Clang++] 编译成功，启动运行:
            echo ----------------------------------------------------------------------
            "%~n1.exe"
        ) else (
            echo [Clang++] 编译失败！
        )
    ) else (
        echo [WARN] 未找到 g++ 或 clang++ 编译器，尝试直接执行...
        "%TARGET_FILE%"
    )
)
goto FINISH

:RUN_RUST
rustc "%TARGET_FILE%" && "%~n1.exe"
goto FINISH

:RUN_GO
go run "%TARGET_FILE%"
goto FINISH

:RUN_POWERSHELL
powershell -ExecutionPolicy Bypass -File "%TARGET_FILE%"
goto FINISH

:RUN_BASH
bash "%TARGET_FILE%"
goto FINISH

:RUN_DEFAULT
echo 正在执行: "%TARGET_FILE%" ...
echo ----------------------------------------------------------------------
call "%TARGET_FILE%"
goto FINISH

:FINISH
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ======================================================================
echo [进程已结束，退出代码: %EXIT_CODE%]
echo ======================================================================
pause