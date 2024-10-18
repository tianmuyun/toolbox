@echo off
chcp 65001

echo 该命令将更新暂停的最大天数设置为 350 天
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v FlightSettingsMaxPauseDays /t reg_dword /d 350 /f
pause