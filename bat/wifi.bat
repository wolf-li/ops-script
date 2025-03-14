:: date: 2025-03-13
:: auth: wolf-li
:: env: win10
:: 获取 wifi 记录
@echo off

chcp 65001 >nul

echo 正在获取所有连接过的 Wi-Fi 信息...
echo.

echo 正在查询中...存放到wifi文件中
for /f "skip=9 tokens=1,2 delims=:" %%i in ('netsh wlan show profiles') do (
    if "%%j" NEQ "" (
        set "profile=%%j"
        setlocal enabledelayedexpansion
        set "profile=!profile:~1!"
        echo wi-fi 名称: !profile! >> wifi
        netsh wlan show profile name="!profile!" key=clear | findstr /c:"Authentication" /c:"Key Content" | sort /unique >> wifi
        endlocal
    )
)

echo.
echo Wi-Fi 信息获取完成
