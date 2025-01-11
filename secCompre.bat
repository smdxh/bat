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
:: 设置最小分卷（MB），低于这个数值不分卷，高于这个值则分为2个压缩包。
set minSize=200
:: 设置最大分卷（MB），高于这个数值均以此大小分卷
set maxSize=2000

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
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        :: 注入文件右键菜单
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        :: 删除之前的secCompre右键菜单
        reg delete "HKCR\Folder\shell\secCompre" /f
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
    echo "当前压缩的对象为!comPath!"

    ::使用 7z.exe 第一次压缩文件夹
    !Z_PATH! a -sfx7z.sfx "!comPath!.7z.exe" "!comPath!" -p!pw1! -mx0 -y
    :: 获得压缩文件大小
    set fileSize=0
    for %%F in ("!comPath!.7z.exe") do (
        set fileSize=%%~zF
    )
    set /a fileSize=!fileSize!/1048576
    echo 文件大小: !fileSize! MB
    ::使用 7z.exe 根据文件大小第二次压缩文件夹
    if !fileSize! lss %minSize% (
        echo 当前文件小于%minSize%MB，不执行分卷
        !Z_PATH! a "!comPath!.7z" "!comPath!.7z.exe" -p!pw2! -mx0 -sdel -y
    ) else (
        if !fileSize! lss %maxSize% (
            echo 当前文件大于%minSize%MB，将分为2份
            set /a result=!fileSize!/2 + 1
            !Z_PATH! a "!comPath!.7z" "!comPath!.7z.exe" -p!pw2! -mx0 -sdel -v!result!m -y
        ) else (
            echo 当前文件将以%maxSize%MB进行分卷
            !Z_PATH! a "!comPath!.7z" "!comPath!.7z.exe" -p!pw2! -mx0 -sdel -v%maxSize%m -y
        )
    )
    
)