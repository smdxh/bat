@echo off
:: ���ļ���������ѹ��
:: �Ҽ��ļ������ļ�����ʾ�����ƣ���Ҫ�ӿո�
set myName=����ѹ��
:: ���� 7z.exe ��·�����밴ʵ��·���޸�
set Z_PATH="C:\Program Files\7-Zip\7z.exe"
:: �ڲ����룬��Ҫ�ӿո�
set "pw1=acg18"
:: ������룬��Ҫ�ӿո�
set "pw2=acg18"

if "%1"=="" (
    :: ��ȡ��ǰ�������ļ�������·��
    set "batchPath=%~f0"
    :: ��ȡ��ǰ�������ļ����ڵ�Ŀ¼
    set "batchDir=%~dp0"
    :: �����˫�����Ҽ�����Ա������У���ִ�д˲��ִ���
    echo ����ע���Ҽ��˵�...
    :: ����Ƿ��Թ���Ա�������
    net.exe session 1>NUL 2>NUL && (
        goto as_admin
    ) || (
        goto not_admin
    )
    :not_admin
        echo �������ԱȨ��
        echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs" 
        echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs" 
        "%temp%\getadmin.vbs" 
        exit /B 
    :as_admin
    :: ע���ļ����Ҽ��˵�
        reg add "HKCR\Directory\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\Directory\shell\secCompre\command" /ve /d " """%batchPath%""" %%1 " /f
    :: ע���ļ��Ҽ��˵�
        reg add "HKCR\*\shell\secCompre" /ve /d "%myName%" /f
        reg add "HKCR\*\shell\secCompre\command" /ve /d " """%batchPath%""" %%1 " /f
        echo "%batchPath%ע��ɹ�"
        pause
        exit /B 
) else (
:: ������Ҽ��ļ������ļ�����ִ�д˲��ִ���
    :: �����ӳٱ�����չ
    setlocal enabledelayedexpansion
    :: ��ʾ��ʾ��Ϣ
    echo �������� %myName%...
    :: ��ȡ��ѹ�������·��
    set comPath=%*
    echo "��ǰִ�е��ļ���Ϊ!comPath!"


    ::ʹ�� 7z.exe ��һ��ѹ���ļ���
    !Z_PATH! a -sfx7z.sfx "!comPath!.7z.exe" "!comPath!" -p!pw1! -mx0 -y
    ::ʹ�� 7z.exe �ڶ���ѹ���ļ���
    !Z_PATH! a "!comPath!.7z" "!comPath!.7z.exe" -p!pw2! -mx0 -sdel -v500m -y
    pause
)