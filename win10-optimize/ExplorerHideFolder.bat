@echo off
chcp 65001
setlocal enabledelayedexpansion

:: 以管理员身份运行

:: 定义注册表路径
set "regPath=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace"

:: 定义 GUID 数组
set "guids[1]={088e3905-0323-4b02-9826-5d99428e115f}"  :: 下载
set "guids[2]={24ad3ad4-a569-4530-98e1-ab02f9417aa8}"  :: 图片
set "guids[3]={3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}"  :: 音乐
set "guids[4]={B4BFCC3A-DB2C-424C-B029-7FE99A87C641}"  :: 桌面
set "guids[5]={d3162b92-9365-467a-956b-92703aca08af}"  :: 文档
set "guids[6]={f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}"  :: 视频
set "guids[7]={0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"  :: 3D对象

set "name[1]=Download"
set "name[2]=Picture "
set "name[3]=Music   "
set "name[4]=Desktop "
set "name[5]=Document"
set "name[6]=Video   "
set "name[7]=3DObject"

:menu
cls
echo -------------------------------------
echo Win10隐藏资源管理器上面额外的7个文件夹
echo -------------------------------------
echo 检查注册表项存在性
for /L %%i in (1,1,7) do (
    reg query "!regPath!\!guids[%%i]!" >nul 2>&1
    if errorlevel 1 (
        echo %%i. !name[%%i]! 不存在
    ) else (
        echo %%i. !name[%%i]! 存在
    )
)
echo -------------------------------------
echo 选择删除操作
echo 1. 下载 (Download)
echo 2. 图片 (Picture)
echo 3. 音乐 (Music)
echo 4. 桌面 (Desktop)
echo 5. 文档 (Document)
echo 6. 视频 (Video)
echo 7. 3D对象 (3DObject)
echo 8. 删除所有.
echo 9. 恢复所有.
echo 0. 退出.
echo -------------------------------------
set /p choice="请输入选项: "

if "%choice%"=="1" goto :deleteDownload
if "%choice%"=="2" goto :deletePicture
if "%choice%"=="3" goto :deleteMusic
if "%choice%"=="4" goto :deleteDesktop
if "%choice%"=="5" goto :deleteDocument
if "%choice%"=="6" goto :deleteVideo
if "%choice%"=="7" goto :delete3DObject
if "%choice%"=="8" goto :deleteAll
if "%choice%"=="9" goto :createAll
if "%choice%"=="0" goto :exitProgram
echo 输入无效
goto menu

:deleteDownload
reg delete "!regPath!\{088e3905-0323-4b02-9826-5d99428e115f}" /f
pause
goto menu

:deletePicture
reg delete "!regPath!\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
pause
goto menu

:deleteMusic
reg delete "!regPath!\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
pause
goto menu

:deleteDesktop
reg delete "!regPath!\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
pause
goto menu

:deleteDocument
reg delete "!regPath!\{d3162b92-9365-467a-956b-92703aca08af}" /f
pause
goto menu

:deleteVideo
reg delete "!regPath!\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
pause
goto menu

:delete3DObject
reg delete "!regPath!\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f
pause
goto menu

:createAll
echo 正在创建: 下载、图片、音乐、桌面、文档、视频、3D对象
reg add "!regPath!\{088e3905-0323-4b02-9826-5d99428e115f}" /f
reg add "!regPath!\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
reg add "!regPath!\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
reg add "!regPath!\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
reg add "!regPath!\{d3162b92-9365-467a-956b-92703aca08af}" /f
reg add "!regPath!\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
reg add "!regPath!\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f
pause
goto menu

:deleteAll
echo 正在删除: 下载、图片、音乐、桌面、文档、视频、3D对象
reg delete "!regPath!\{088e3905-0323-4b02-9826-5d99428e115f}" /f
reg delete "!regPath!\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
reg delete "!regPath!\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
reg delete "!regPath!\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
reg delete "!regPath!\{d3162b92-9365-467a-956b-92703aca08af}" /f
reg delete "!regPath!\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
reg delete "!regPath!\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f
pause
goto menu

:exitProgram
exit