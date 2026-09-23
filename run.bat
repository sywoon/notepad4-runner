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

:: 切换工作目录至当前打开的文件所在目录
cd /d "%~dp1"

echo ======================================================================
echo [Notepad4 Runner]
echo 当前文件: %~nx1
echo 全路径  : %~1
echo 所在目录: %~dp1
echo 扩展名  : %~x1
echo ======================================================================
echo.

:: 根据文件后缀名进行调度执行
set "EXT=%~x1"

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
call "%~1"
goto FINISH

:RUN_PYTHON
python -V 2>nul
python "%~1"
goto FINISH

:RUN_LUA
if exist "C:\cinside\lua5.3\runlua.bat" (
    set "path=C:\cinside\lua5.3;%path%"
    call "C:\cinside\lua5.3\runlua.bat" "%~1"
    goto FINISH
)
where lua >nul 2>nul
if %ERRORLEVEL% equ 0 (
    lua -v 2>nul
    lua "%~1"
) else (
    where luajit >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        luajit "%~1"
    ) else (
        echo [ERROR] 未找到 lua 或 luajit 解释器！
    )
)
goto FINISH

:RUN_NODE
node -v 2>nul
node "%~1"
goto FINISH

:RUN_TS
where tsx >nul 2>nul
if %ERRORLEVEL% equ 0 (
    tsx "%~1"
) else (
    where bun >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        bun run "%~1"
    ) else (
        where ts-node >nul 2>nul
        if !ERRORLEVEL! equ 0 (
            ts-node "%~1"
        ) else (
            npx -y tsx "%~1"
        )
    )
)
goto FINISH

:RUN_TSX
where tsx >nul 2>nul
if %ERRORLEVEL% equ 0 (
    tsx "%~1"
) else (
    where bun >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        bun run "%~1"
    ) else (
        npx -y tsx "%~1"
    )
)
goto FINISH

:RUN_COFFEE
call coffee "%~1"
goto FINISH

:RUN_C
where gcc >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [GCC] 正在编译 %~nx1 ...
    gcc "%~1" -o "%~n1.exe"
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
        echo [Clang] 正在编译 %~nx1 ...
        clang "%~1" -o "%~n1.exe"
        if !ERRORLEVEL! equ 0 (
            echo [Clang] 编译成功，启动运行:
            echo ----------------------------------------------------------------------
            "%~n1.exe"
        ) else (
            echo [Clang] 编译失败！
        )
    ) else (
        echo [WARN] 未找到 gcc 或 clang 编译器，尝试直接执行...
        "%~1"
    )
)
goto FINISH

:RUN_CPP
where g++ >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [G++] 正在编译 %~nx1 ...
    g++ "%~1" -o "%~n1.exe"
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
        echo [Clang++] 正在编译 %~nx1 ...
        clang++ "%~1" -o "%~n1.exe"
        if !ERRORLEVEL! equ 0 (
            echo [Clang++] 编译成功，启动运行:
            echo ----------------------------------------------------------------------
            "%~n1.exe"
        ) else (
            echo [Clang++] 编译失败！
        )
    ) else (
        echo [WARN] 未找到 g++ 或 clang++ 编译器，尝试直接执行...
        "%~1"
    )
)
goto FINISH

:RUN_RUST
rustc "%~1" && "%~n1.exe"
goto FINISH

:RUN_GO
go run "%~1"
goto FINISH

:RUN_POWERSHELL
powershell -ExecutionPolicy Bypass -File "%~1"
goto FINISH

:RUN_BASH
bash "%~1"
goto FINISH

:RUN_DEFAULT
echo 正在执行: "%~1" ...
echo ----------------------------------------------------------------------
call "%~1"
goto FINISH

:FINISH
set "EXIT_CODE=%ERRORLEVEL%"
echo.
echo ======================================================================
echo [进程已结束，退出代码: %EXIT_CODE%]
echo ======================================================================
pause
