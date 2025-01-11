@echo off
:: 对文件进行两层压缩
:: 右键文件或者文件夹显示的名称，不要加空格
set myName=二重压缩
:: 设置 7z.exe 的路径，请按实际路径修改
set Z_PATH="C:\Program Files\7-Zip\7z.exe"
:: 内层密码，不要加空格
set "pw1=acg18"
:: 外层密码，不要加空格
set "pw2=acg18"

if "%1"=="" (
    :: 获取当前批处理文件的完整路径
    set "batchPath=%~f0"
    :: 获取当前批处理文件所在的目录
    set "batchDir=%~dp0"
    :: 如果是双击（右键管理员身份运行）则执行此部分代码
    echo 正在注入右键菜单...
    :: 检查是否以管理员身份运行
    net.exe session 1>NUL 2>NUL && (
        goto as_admin
    ) || (
        goto not_admin
    )
    :not_admin
        echo 请求管理员权限
        echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
        echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
        "%temp%\getadmin.vbs" 
        exit /B 
    :as_admin
    :: 注入文件夹右键菜单
        reg add "HKCR\Directory\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d " """%batchPath%""" %%1 " /f
    :: 注入文件右键菜单
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d " """%batchPath%""" %%1 " /f
        echo "%batchPath%注入成功"
        pause
        exit /B 
) else (
:: 如果是右键文件或者文件夹则执行此部分代码
    :: 启用延迟变量扩展
    setlocal enabledelayedexpansion
    :: 显示提示信息
    echo 正在运行 %myName%...
    :: 获取被压缩对象的路径
    set comPath=%*
    echo "当前执行的文件夹为!comPath!"


    ::使用 7z.exe 第一次压缩文件夹
    !Z_PATH! a -sfx7z.sfx "!comPath!.7z.exe" "!comPath!" -p!pw1! -mx0 -y
    ::使用 7z.exe 第二次压缩文件夹
    !Z_PATH! a "!comPath!.7z" "!comPath!.7z.exe" -p!pw2! -mx0 -sdel -v500m -y
    pause
)