@echo off
:: ���ļ���������ѹ��
:: �Ҽ��ļ������ļ�����ʾ�����ƣ���Ҫ�ӿո�
set myName=����ѹ��
:: �ڲ����룬��Ҫ�ӿո�
set "pw1=pw"
:: ������룬��Ҫ�ӿո�
set "pw2=pw"
:: ������С�־�MB�������������ֵ���־��������ֵ���Ϊ2��ѹ������
set minSize=200
:: �������־�MB�������������ֵ���Դ˴�С�־�
set maxSize=2000
:: �����ӳٱ�����չ
setlocal enabledelayedexpansion
if "%1"=="" (
    :: �����˫�������Ҽ��Թ���Ա������У���ִ�д˲��ִ���
    echo ��ӭʹ��"%myName%"��װ��ж�س���
    :: ��ȡ��ǰ�������ļ�������·��
    set "batchPath=%~f0"
    :: ��ȡ��ǰ�������ļ����ڵ�Ŀ¼
    set "batchDir=%~dp0"
    echo ����Ƿ��Թ���Ա�������...
    net.exe session 1>NUL 2>NUL && (
        goto as_admin
    ) || (
        goto not_admin
    )
    :not_admin
        echo �������ԱȨ��...
        echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
        echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
        "%temp%\getadmin.vbs" 
        exit /B 
    :as_admin
        :menu
        echo ��ѡ�������
        echo 1. ��װ"%myName%"
        echo 2. ж��"%myName%"
        set /p choice=���������֣�1��2�����س���
        if "%choice%"=="1" goto install
        if "%choice%"=="2" goto uninstall
        echo ������Ч�����������롣
        goto menu

    :install
        echo ���밲װ����
        echo ��ѡ��7z��װ·��...
        set diaParam="& {Add-Type -AssemblyName System.Windows.Forms;$FileDialog = New-Object System.Windows.Forms.OpenFileDialog;$FileDialog.Filter = '7z.exe|7z.exe';$FileDialog.InitialDirectory = '$env:ProgramFiles\7-Zip';if ($FileDialog.ShowDialog() -eq 'OK') {$FileDialog.FileName}}"
        :: ʹ��PowerShell�����ļ�ѡ�����Ի���ȷ��7zip·��
        for /f "delims=" %%i in ('powershell -command %diaParam%') do set "selectedFile=%%i"
        if defined selectedFile (
            set "Z_PATH=%selectedFile%"
            echo ����7z��������...
            setx 7Z_PATH "!Z_PATH!"
        )
        echo ע���ļ����Ҽ��˵�...
        reg add "HKCR\Directory\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo ע���ļ��Ҽ��˵�...
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo ɾ����secCompreע����ɺ�����һ����ϵͳ�Ҳ���ָ����ע������ֵ��...
        reg delete "HKCR\Folder\shell\secCompre" /f
        pause
        exit

    :uninstall
        echo ɾ���ļ����Ҽ��˵�...
        reg delete "HKCR\Directory\shell\secCompre" /f
        echo ɾ���ļ��Ҽ��˵�...
        reg delete "HKCR\*\shell\secCompre" /f
        echo ɾ��7z��������...
        reg delete "HKCU\Environment" /v 7Z_PATH /f
        pause
        exit

) else (
:: ������Ҽ��ļ������ļ�����ִ�д˲��ִ���
    echo �������� %myName%...
    :: ��ȡ��ѹ�������·��
    set comPath=%*
    echo "��ǰѹ���Ķ���Ϊ!comPath!"
    ::ʹ�� 7z.exe ��һ��ѹ���ļ����ļ���
    "!7Z_PATH!" a "!comPath!.7z.7z" "!comPath!" -p!pw1! -mx0 -y
    :: ���ѹ���ļ���С
    set fileSize=0
    for %%F in ("!comPath!.7z.7z") do (
        set fileSize=%%~zF
    )
    set /a fileSize=!fileSize!/1048576
    echo �ļ���С: !fileSize! MB
    ::ʹ�� 7z.exe �����ļ���С�ڶ���ѹ���ļ�
    if !fileSize! lss %minSize% (
        echo ��ǰ�ļ�С��%minSize%MB����ִ�з־�
        "!7Z_PATH!" a "!comPath!.7z" "!comPath!.7z.7z" -p!pw2! -mx0 -sdel -y
    ) else (
        if !fileSize! lss %maxSize% (
            echo ��ǰ�ļ�����%minSize%MB������Ϊ2��
            set /a result=!fileSize!/2 + 1
            "!7Z_PATH!" a "!comPath!.7z" "!comPath!.7z.7z" -p!pw2! -mx0 -sdel -v!result!m -y
        ) else (
            echo ��ǰ�ļ�����%maxSize%MB���з־�
            "!7Z_PATH!" a "!comPath!.7z" "!comPath!.7z.7z" -p!pw2! -mx0 -sdel -v%maxSize%m -y
        )
    )
)