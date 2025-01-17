@echo off
:: 对文件进行两层压缩
:: 右键文件或者文件夹显示的名称，不要加空格
set myName=二重压缩
:: 内层密码，不要加空格
set pw1=smdxh
:: 外层密码，不要加空格
set pw2=smdxh
:: 设置最小分卷（MB），低于这个数值不分卷，高于这个值则分为2个压缩包。
set minSize=100
:: 设置最大分卷（MB），高于这个数值均以此大小分卷
set maxSize=2000
:: 外层压缩包名称结尾文字。比如压缩文件夹名字是“申鹤”，内层压缩包名字则是“申鹤.7z”，外层压缩包名字是“申鹤港.7z”，用户解压时选中2次“解压到当前文件夹”会得到与上传者文件夹同名的文件夹。
:: 注意：外层压缩包名结尾不可设为“.7z”，这会与内层相同，导致压缩不正常。外层压缩包名不带“.”，7-zip软件会自动加“.7z”
set endWith="港"
:: 启用延迟变量扩展
setlocal enabledelayedexpansion
set "Z_PATH=%~dp0\7z.exe"
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
        echo 注入文件夹右键菜单...
        reg add "HKCR\Directory\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo 注入文件右键菜单...
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo 删除旧secCompre注册表
        reg delete "HKCR\Folder\shell\secCompre" /f >nul 2>&1
        echo 压缩包内层密码是“%pw1%”
        echo 压缩包外层密码是“%pw2%”
        echo 需要修改密码请右键单击本脚本，选择“编辑”，修改对应位置等号后面的值
        pause
        exit

    :uninstall
        echo 删除文件夹右键菜单...
        reg delete "HKCR\Directory\shell\secCompre" /f
        echo 删除文件右键菜单...
        reg delete "HKCR\*\shell\secCompre" /f
        pause
        exit

) else (
:: 如果是右键文件或者文件夹则执行此部分代码
    echo 正在运行 %myName%...
    :: 获取被压缩对象的路径
    set comPath=%*
    echo "当前压缩的对象为!comPath!"
    ::使用 7z.exe 第一次压缩文件或文件夹
    "%Z_PATH%" a "!comPath!.7z" "!comPath!" -p!pw1! -mx0 -y -mhe=on
    :: 获得压缩文件大小
    set fileSize=0
    for %%F in ("!comPath!.7z") do (
        set fileSize=%%~zF
    )
    set /a fileSize=!fileSize!/1048576
    echo 文件大小: !fileSize! MB
    ::使用 7z.exe 根据文件大小第二次压缩文件
    if !fileSize! lss %minSize% (
        echo 当前文件小于%minSize%MB，不执行分卷
        "%Z_PATH%" a "!comPath!%endWith%.7z" "!comPath!.7z" -p!pw2! -mx0 -sdel -y -mhe=on
    ) else (
        if !fileSize! lss %maxSize% (
            echo 当前文件大于%minSize%MB，将分为2卷
            set /a result=!fileSize!/2 + 1
            "%Z_PATH%" a "!comPath!%endWith%" "!comPath!.7z" -p!pw2! -mx0 -sdel -v!result!m -y -mhe=on
        ) else (
            echo 当前文件将以%maxSize%MB进行分卷
            "%Z_PATH%" a "!comPath!%endWith%" "!comPath!.7z" -p!pw2! -mx0 -sdel -v%maxSize%m -y -mhe=on
        )
    )
)
