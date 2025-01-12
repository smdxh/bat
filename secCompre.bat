@echo off
:: 对文件进行两层压缩
:: 右键文件或者文件夹显示的名称，不要加空格
set myName=二重压缩
:: 内层密码，不要加空格
set "pw1=pw"
:: 外层密码，不要加空格
set "pw2=pw"
:: 设置最小分卷（MB），低于这个数值不分卷，高于这个值则分为2个压缩包。
set minSize=200
:: 设置最大分卷（MB），高于这个数值均以此大小分卷
set maxSize=2000
:: 启用延迟变量扩展
setlocal enabledelayedexpansion
if "%1"=="" (
    :: 如果是双击或者右键以管理员身份运行，则执行此部分代码
    echo 欢迎使用"%myName%"安装、卸载程序
    :: 获取当前批处理文件的完整路径
    set "batchPath=%~f0"
    :: 获取当前批处理文件所在的目录
    set "batchDir=%~dp0"
    echo 检查是否以管理员身份运行...
    net.exe session 1>NUL 2>NUL && (
        goto as_admin
    ) || (
        goto not_admin
    )
    :not_admin
        echo 请求管理员权限...
        echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
        echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
        "%temp%\getadmin.vbs" 
        exit /B 
    :as_admin
        :menu
        echo 请选择操作：
        echo 1. 安装"%myName%"
        echo 2. 卸载"%myName%"
        set /p choice=请输入数字（1或2）按回车：
        if "%choice%"=="1" goto install
        if "%choice%"=="2" goto uninstall
        echo 输入无效，请重新输入。
        goto menu

    :install
        echo 进入安装程序
        echo 请选择7z安装路径...
        set diaParam="& {Add-Type -AssemblyName System.Windows.Forms;$FileDialog = New-Object System.Windows.Forms.OpenFileDialog;$FileDialog.Filter = '7z.exe|7z.exe';$FileDialog.InitialDirectory = '$env:ProgramFiles\7-Zip';if ($FileDialog.ShowDialog() -eq 'OK') {$FileDialog.FileName}}"
        :: 使用PowerShell弹出文件选择器对话框，确定7zip路径
        for /f "delims=" %%i in ('powershell -command %diaParam%') do set "selectedFile=%%i"
        if defined selectedFile (
            set "Z_PATH=%selectedFile%"
            echo 保存7z环境变量...
            setx 7Z_PATH "!Z_PATH!"
        )
        echo 注入文件夹右键菜单...
        reg add "HKCR\Directory\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo 注入文件右键菜单...
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo 删除旧secCompre注册表，可忽略下一条“系统找不到指定的注册表项或值”...
        reg delete "HKCR\Folder\shell\secCompre" /f
        pause
        exit

    :uninstall
        echo 删除文件夹右键菜单...
        reg delete "HKCR\Directory\shell\secCompre" /f
        echo 删除文件右键菜单...
        reg delete "HKCR\*\shell\secCompre" /f
        echo 删除7z环境变量...
        reg delete "HKCU\Environment" /v 7Z_PATH /f
        pause
        exit

) else (
:: 如果是右键文件或者文件夹则执行此部分代码
    echo 正在运行 %myName%...
    :: 获取被压缩对象的路径
    set comPath=%*
    echo "当前压缩的对象为!comPath!"
    ::使用 7z.exe 第一次压缩文件或文件夹
    "!7Z_PATH!" a "!comPath!.7z.7z" "!comPath!" -p!pw1! -mx0 -y
    :: 获得压缩文件大小
    set fileSize=0
    for %%F in ("!comPath!.7z.7z") do (
        set fileSize=%%~zF
    )
    set /a fileSize=!fileSize!/1048576
    echo 文件大小: !fileSize! MB
    ::使用 7z.exe 根据文件大小第二次压缩文件
    if !fileSize! lss %minSize% (
        echo 当前文件小于%minSize%MB，不执行分卷
        "!7Z_PATH!" a "!comPath!.7z" "!comPath!.7z.7z" -p!pw2! -mx0 -sdel -y
    ) else (
        if !fileSize! lss %maxSize% (
            echo 当前文件大于%minSize%MB，将分为2卷
            set /a result=!fileSize!/2 + 1
            "!7Z_PATH!" a "!comPath!.7z" "!comPath!.7z.7z" -p!pw2! -mx0 -sdel -v!result!m -y
        ) else (
            echo 当前文件将以%maxSize%MB进行分卷
            "!7Z_PATH!" a "!comPath!.7z" "!comPath!.7z.7z" -p!pw2! -mx0 -sdel -v%maxSize%m -y
        )
    )
)