# Toolbox

## mpv-config

MPV播放器配置文件

添加到portable_config目录

脚本：
[autoload](https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua)
[misc](https://github.com/stax76/mpv-scripts/blob/main/misc.lua)

## win10-optimize

Windows优化

### DisableSuggestionSearchbar

禁用 Windows 搜索框中的建议功能

```
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\explorer" /v DisableSearchBoxSuggestions /t reg_dword /d 1 /f
```

### ExtendUpdateTime

注：以管理员身份运行

将 windows 更新暂停的最大天数设置为350天，可以修改天数

```
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v FlightSettingsMaxPauseDays /t reg_dword /d 350 /f
```

### ExplorerHideFolder

注：以管理员身份运行

隐藏 Windows 资源管理器导航栏中的特定文件夹（下载、图片、音乐、桌面、文档、视频、3D对象）。

通过注册表操作，添加或删除这些文件夹的项，来隐藏或显示这些特定文件夹。

```
# 注册表位置
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\
# 文件夹项目
{088e3905-0323-4b02-9826-5d99428e115f} # 下载
{24ad3ad4-a569-4530-98e1-ab02f9417aa8} # 图片
{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de} # 音乐
{B4BFCC3A-DB2C-424C-B029-7FE99A87C641} # 桌面
{d3162b92-9365-467a-956b-92703aca08af} # 文档
{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a} # 视频
{0DB7E03F-FC29-4DC6-9020-FF41B59E513A} # 3D对象

```