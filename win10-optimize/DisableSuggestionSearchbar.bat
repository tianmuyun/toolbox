@echo off
chcp 65001

:: 以管理员身份运行

echo 禁用 Windows 搜索框中的建议功能
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\explorer" /v DisableSearchBoxSuggestions /t reg_dword /d 1 /f
pause