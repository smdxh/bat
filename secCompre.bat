@echo off
:: ���ļ���������ѹ��
:: �Ҽ��ļ������ļ�����ʾ�����ƣ���Ҫ�ӿո�
set myName=����ѹ��
:: �ڲ����룬��Ҫ�ӿո�
set pw1=smdxh
:: ������룬��Ҫ�ӿո�
set pw2=smdxh
:: ������С�־�MB�������������ֵ���־��������ֵ���Ϊ2��ѹ������
set minSize=100
:: �������־�MB�������������ֵ���Դ˴�С�־�
set maxSize=2000
:: ���ѹ�������ƽ�β���֡�����ѹ���ļ��������ǡ���ס����ڲ�ѹ�����������ǡ����.7z�������ѹ���������ǡ���׸�.7z�����û���ѹʱѡ��2�Ρ���ѹ����ǰ�ļ��С���õ����ϴ����ļ���ͬ�����ļ��С�
:: ע�⣺���ѹ��������β������Ϊ��.7z����������ڲ���ͬ������ѹ�������������ѹ������������.����7-zip������Զ��ӡ�.7z��
set endWith="��"
:: �����ӳٱ�����չ
setlocal enabledelayedexpansion
set "Z_PATH=%~dp0\7z.exe"
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
        echo ע���ļ����Ҽ��˵�...
        reg add "HKCR\Directory\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo ע���ļ��Ҽ��˵�...
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d """"%batchPath%""" %%1 " /f
        echo ɾ����secCompreע���
        reg delete "HKCR\Folder\shell\secCompre" /f >nul 2>&1
        echo ѹ�����ڲ������ǡ�%pw1%��
        echo ѹ������������ǡ�%pw2%��
        echo ��Ҫ�޸��������Ҽ��������ű���ѡ�񡰱༭�����޸Ķ�Ӧλ�õȺź����ֵ
        pause
        exit

    :uninstall
        echo ɾ���ļ����Ҽ��˵�...
        reg delete "HKCR\Directory\shell\secCompre" /f
        echo ɾ���ļ��Ҽ��˵�...
        reg delete "HKCR\*\shell\secCompre" /f
        pause
        exit

) else (
:: ������Ҽ��ļ������ļ�����ִ�д˲��ִ���
    echo �������� %myName%...
    :: ��ȡ��ѹ�������·��
    set comPath=%*
    echo "��ǰѹ���Ķ���Ϊ!comPath!"
    ::ʹ�� 7z.exe ��һ��ѹ���ļ����ļ���
    "%Z_PATH%" a "!comPath!.7z" "!comPath!" -p!pw1! -mx0 -y -mhe=on
    :: ���ѹ���ļ���С
    set fileSize=0
    for %%F in ("!comPath!.7z") do (
        set fileSize=%%~zF
    )
    set /a fileSize=!fileSize!/1048576
    echo �ļ���С: !fileSize! MB
    ::ʹ�� 7z.exe �����ļ���С�ڶ���ѹ���ļ�
    if !fileSize! lss %minSize% (
        echo ��ǰ�ļ�С��%minSize%MB����ִ�з־�
        "%Z_PATH%" a "!comPath!%endWith%.7z" "!comPath!.7z" -p!pw2! -mx0 -sdel -y -mhe=on
    ) else (
        if !fileSize! lss %maxSize% (
            echo ��ǰ�ļ�����%minSize%MB������Ϊ2��
            set /a result=!fileSize!/2 + 1
            "%Z_PATH%" a "!comPath!%endWith%" "!comPath!.7z" -p!pw2! -mx0 -sdel -v!result!m -y -mhe=on
        ) else (
            echo ��ǰ�ļ�����%maxSize%MB���з־�
            "%Z_PATH%" a "!comPath!%endWith%" "!comPath!.7z" -p!pw2! -mx0 -sdel -v%maxSize%m -y -mhe=on
        )
    )
)
