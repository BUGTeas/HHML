@echo off
rem Language config
set prd=��
set lb=��
set gb=��
set cma=��
set cln=��
set txt000=Hello HMCL! Launcher v3.5.3.229 Update 0
set txt001=���ų�
set txt002=���ڴӵ�ǰĿ¼��Ѱ�� HMCL��JAR���ļ�
set txt003=��ǰĿ¼���Ҳ������õ� HMCL����ȷ����λ�ڴ��������µ�ͬһĿ¼������Ϊ��HMCL-^^^<�汾��^^^>.jar����
set txt004=���ҵ� HMCL����Ϊ
set txt005=���汾��Ϊ
set txt006=����ת��Ϊ������
set txt100=Java ·��Ϊ
set txt101=���ڴ�ϵͳ��Ѱ�� Java
set txt102=���ڴӵ�ǰĿ¼��Ѱ�� Java
set txt103=�Ѽ�⵽
set txt104=���ڴ��Զ���·����Ѱ�� Java
set txt105=λ 
set txt201=
set txt202=�Ҳ������õ� Java
set txt203=
set txt301=����ʹ�ã��汾��Ϊ
set txt302=��·��Ϊ
set txt501=���ڻ�ԭȫ������
set txt502=���ڻ�ԭ���õ�¼����
set txt503=���ڻ�ԭ����ʱ���
set txt504=�Ҳ��������ڵ�ǰ HMCL �汾������ʱ��������� HMCL �Զ����أ�����һ�Σ����� HMCL �˳�ʱ�����Զ����临�Ƶ����Ա��´�������
set txt505=�޷��Զ�����/��ԭ/ɾ������ʱ�������Ϊδ֪ Java ��λ��
set txt506=���� Java ��λ��32λ/64λ�����ڡ�config.txt���ļ������á�use64java������Ϊ0/1��
set txt701=���ڳ������� Shell...
set txt702=������
set txt703=��������˳�
set txt704=�����������ȫ�����ã��رմ�����ȡ��
set txt705=���ڸ���ȫ�������Ա��´�����
set txt706=���ڸ�������ʱ����Ա��´�����


echo %txt000%
title %txt000%
color 0f
if "%1" == "h" goto begin
if "%1" == "j" goto backup


rem default backup/restore/remove configuration
set backupRunTime=1
set restoreRunTime=1
set removeRunTime=1
set backupGlobalConfig=1
set restoreGlobalConfig=1
set removeGlobalConfig=1
rem Default Java lookup configuration
set disableCustPath=0
set disableSearchCD=0
set disableSearchInst=1
rem Default Java check configuration
set checkJava=2
set disableOpenJDK=0
set priorityUseJava8=0
set use64java=x
set verBlackList=none


rem Show excluded items
for /f "tokens=*" %%a in (config.txt) do if "%%a" neq "" set %%a
set excStatus=0
if %disableOpenJDK% == 1 (
    set /a excStatus+=1
    echo %excStatus%
    set txt011=OpenJDK
)
if %verBlackList% neq none (
    set /a excStatus+=1
    echo %excStatus%
    set txt013=%verBlackList%
)
if %excStatus% == 2 set txt012= and 
if %excStatus% neq 0 set exclude=%txt001% %txt011%%txt012%%txt013%%gb% 


rem Search HMCL in the current directory
echo %txt002%...
set hmclPath=none
for /f "tokens=*" %%i in ('dir /b HMCL*.jar') do (
    set hmclPath="%%i"
)
if %hmclPath% == none (
    echo %txt003%
    goto baterror
)
set cnt=0
set sstr=%hmclPath:~5,-5%
:loop
set str=^%%sstr:~%cnt%,1^%%
echo set str="%str%" > tmp.bat
call tmp.bat
if %str% neq "" (
    set /a cnt+=1
    echo %str:~1,1%|findstr "[^0-9]">nul&&set hmclVer=%hmclVer%||set hmclVer=%hmclVer%%str:~1,1%
    goto loop
)
del tmp.bat
if %hmclVer% lss 1000 set hmclVer=%hmclVer%0
if %hmclVer% lss 10000 set hmclVer=%hmclVer%0
if %hmclVer% lss 100000 set hmclVer=%hmclVer%0
if %hmclVer% lss 1000000 set hmclVer=%hmclVer%0
if %hmclVer% lss 10000000 set hmclVer=%hmclVer%0
echo %txt004% %hmclPath%%txt005% "%hmclVer%"%txt006%


set triedInstJava=0
set triedCDJava=0
set javaPath=none
set java8Path=none
set java8Ver=0
set javaNewPath=none
set javaNewVer=0
set jv1=0
set jv2=0
set jv3=0


if %disableSearchCD% neq 1 call :findCDJava
if %disableSearchInst% neq 1 call :findInstJava
if %disableCustPath% neq 1 call :findCustJava
if %checkJava% == 1 call :testJava
if %checkJava% geq 1 (goto checkOther) else (
    echo %txt100% %javaPath%%prd%
    goto loadOther
)


rem Find Java in custom path
:findCustJava
echo %txt104%...
if exist customPath.txt for /f "tokens=*" %%i in (customPath.txt) do (
    if exist "%%i\java.exe" (
        set javaPath="%%i\java.exe"
        if %checkJava% == 2 call :testJava
    )
)
goto :eof


rem Find Java in system
:findInstJava
echo %txt101%...
rem Software installation list registry location
set rp=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
call :findInstWork
set rp=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
call :findInstWork
set rp=HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall
call :findInstWork
goto :eof
:findInstWork
rem Find installation name %dn%
for /f "tokens=*" %%a in ('reg query "%rp%"') do (
    for /f "tokens=*" %%l in ('reg query "%rp%\%%~na" /v "DisplayName" 2^>nul ^|findstr /i "java"') do (
        echo %%l |findstr /i "DisplayName" >nul &&call :getInstInfo %%~na
    )
    for /f "tokens=*" %%l in ('reg query "%rp%\%%~na" /v "DisplayName" 2^>nul ^|findstr /i "jdk"') do (
        echo %%l |findstr /i "DisplayName" >nul &&call :getInstInfo %%~na
    )
)
goto :eof
:getInstInfo
rem cls
rem Get installation path
for /f "tokens=*" %%b in ('reg query "%rp%\%1" /v "InstallLocation" 2^>nul ^|findstr /i "InstallLocation"') do (
  set instPath=%%b
  call :getInstPath
)
goto :eof
rem Test Java under the installation path
:getInstPath
if exist "%instPath:~29%bin\java.exe" (
    set javaPath="%instPath:~29%bin\java.exe"
    if %checkJava% == 2 call :testJava
)
goto :eof


rem Find Java in the current directory
:findCDJava
echo %txt102%...
set FileName=java.exe
for /r %%b in (*%FileName%) do (
    if /i "%%~nxb" equ "%FileName%" (
        set JavaPath="%%b"
        if %checkJava% == 2 call :testJava
    )
)
goto :eof


rem Check Java and pick out the latest version
:testJava
rem Get Java type and version
%JavaPath% -version 2>&1 | findstr "version" > tmp
for /f "tokens=1" %%i in (tmp) do set javaType=%%i
for /f "tokens=3" %%i in (tmp) do set javaVer=%%i
rem Get JVM bit width
set use64java=0
%JavaPath% -version 2>&1 | findstr VM > tmp
for /f "tokens=*" %%b in ('type tmp ^|findstr /i 64-Bit') do set use64java=1
rem Check version
if %use64java% == 1 (set txtbit=64) else (set txtbit=32)
echo %txt103% %txtbit% %txt105%%javaType%%cln%%javaVer%%prd%
if %javaType% == openjdk if %disableOpenJDK% == 1 goto :eof
for /f "tokens=*" %%b in ('echo %verBlackList% ^|findstr /i %javaVer%') do goto :eof
set ver=%javaVer:_= %
set ver=%ver:"=%
rem Get subversion number behind the underline of old version number format��1.x.0_xxx��
set subVer8=0
for /f "tokens=2" %%i in ('echo %ver%') do set subVer8=%%i
set subVer8=%subVer8:-= %
for /f "tokens=1" %%i in ('echo %subVer8%') do set subVer8=%%i
rem Get version number
for /f "tokens=1" %%i in ('echo %ver%') do set ver=%%i
set verl=%ver:.= %
set v1=0
for /f "tokens=1" %%i in ('echo %verl%') do set v1=%%i
set v2=0
for /f "tokens=2" %%i in ('echo %verl%') do set v2=%%i
set v3=0
for /f "tokens=3" %%i in ('echo %verl%') do set v3=%%i
set verSet=0
rem If enable %priorityUseJava8% and found Java 8
set is8=0
if %priorityUseJava8% == 1 (if %ver% == 1.8.0 (set is8=1))
if %priorityUseJava8% == 0 (if %ver% == 1.8.0 (set java8Ver=%javaVer%) else (set java8Ver=0))


if %is8% == 1 (
    set verSet=2
) else (
    if %jv1% leq %v1% (
        if %jv1% lss %v1% (
            set jv1=%v1%
            set verSet=1
        )
        if %jv2% leq %v2% (
            if %jv2% lss %v2% (
                set jv2=%v2%
                set verSet=1
            )
            if %jv3% lss %v3% (
                set jv3=%v3%
                set verSet=1
            )
        )
    )
)
if %verSet% == 1 (
    set javaNewType=%javaType%
    set javaNewVer=%javaVer%
    set javaNewPath=%javaPath%
    set use64javaNew=%use64java%
) else if %verSet% == 2 (
    set java8Type=%javaType%
    set java8Ver=%javaVer%
    set java8Path=%javaPath%
    set use64java8=%use64java%
)
goto :eof


rem Java not found
:notFind
set txten=0
if %disableSearchInst% neq 1 (
    set txten=1
    set txt604=ϵͳ��
    set txt607=�Ѱ�װ
)
if %disableSearchCD% neq 1 (
    set txten=1
    set txt606=��ǰĿ¼��
    set txt608=λ�ڴ��������µ�ͬһĿ¼��
)
if %disableCustPath% neq 1 (
    set txten=1
    set txt601=�Զ���·��
    set txt602=���Զ���·����
)
if %txten% == 1 (
    set txt603=��
    set txt609=��ȷ����
) else set txt609=����Ѱ�� Java �Ĺ��ܾ��ѹرգ����������ļ���config.txt����
if %disableSearchInst% neq 1 if %disableSearchCD% neq 1 set txt605=��
if %disableCustPath% neq 1 if %disableSearchInst% neq 1 set txt600=��
if %disableCustPath% neq 1 if %disableSearchCD% neq 1 set txt600=��
echo %txt201%%exclude%%txt603%%txt601%%txt600%%txt604%%txt605%%txt606%%txt202%%cma%%txt203%%txt609%%txt602%%txt600%%txt607%%txt605%%txt608%%prd%
goto baterror


:checkOther
if %java8Path% == none (
    if %javaNewPath% == none (
        goto notFind
    ) else (
        echo %javaNewType% %txt301% %javaNewVer%%txt302% %javaNewPath%.
        set javaPath=%javaNewPath%
        set use64java=%use64javaNew%
    )
) else (
    echo %java8Type% 8 %txt301% %java8Ver%%txt302% %java8Path%
    set javaPath=%java8Path%
    set use64java=%use64java8%
)


if %java8Ver% == 0 (
    if %jv1% lss 11 (set java8Ver=1) else if %hmclVer% LSS 33183000 (set java8Ver=1)
)


:loadOther
if %javaPath% == none goto notFind
set rth1=dependencies\windows-x86
set rth2=\openjfx\
set conDir=%userprofile%\AppData\Roaming\.hmcl\
set rgcEnable=0
if %restoreGlobalConfig% geq 1 if not exist %conDir%config.json if not exist %conDir%accounts.json set rgcEnable=1
if %rgcEnable% == 1 (
    set restoreGlobalConfig=2
    if %backupGlobalConfig% == 1 set backupGlobalConfig=2
    if %removeGlobalConfig% == 1 set removeGlobalConfig=2
)
if %restoreGlobalConfig% == 2 (if exist .\globalConfig\ (
    echo %txt501%...
    xcopy /s /y .\globalConfig\accounts.json %conDir%
    xcopy /s /y .\globalConfig\config.json %conDir%
))


if %restoreRunTime% geq 1 (
    echo %txt502%...
    if not exist %conDir%authlib-injector.jar (xcopy /s /y .\dependencies\authlib-injector.jar %conDir%)
    if %java8Ver% == 0 set restoreRunTime=2
)
if %use64java% == 1 (set rthw=_64) else if %use64java% == 0 (set rthm=-x86) else (
    echo %txt505%
    echo %txt506%
    goto baterror
)
set fileQuantity=5
set srcPath=.\%rth1%%rthw%%rth2%
set trgPath=%conDir%%rth1%%rthw%%rth2%
if %hmclVer% LSS 35322900 (
    set fileQuantity=6
    if %hmclVer% LSS 35221700 (
        set srcPath=.\%rth1%%rthw%\
        set trgPath=%conDir%dependencies\
        if %hmclVer% LSS 34202000 (set fileName=javafx-*-16-win%rthm%.jar) else (set fileName=javafx-*-17-win%rthm%.jar)
    ) else (set fileName=javafx-*-17.0.2-win%rthm%.jar)
) else (set fileName=javafx-*-19.0.2.1-win%rthm%.jar)
set srcQuantity=0
for /f "tokens=*" %%i in ('dir /b %srcPath%%fileName%') do set /a srcQuantity+=1
set trgQuantity=0
for /f "tokens=*" %%i in ('dir /b %trgPath%%fileName%') do set /a trgQuantity+=1
if %restoreRunTime% == 2 call :restoreRT
goto beforeStart


:restoreRT
echo %txt503%...
if %trgQuantity% neq %fileQuantity% (
    if %srcQuantity% neq %fileQuantity% (
        echo %txt504%
        if %backupRunTime% == 1 set backupRunTime=2
    ) else (
        xcopy /s /y %srcPath%%fileName% %trgPath%
    )
    if %removeRunTime% == 1 set removeRunTime=2
)
goto :eof


:beforeStart
echo %txt701%
mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)
exit


:baterror
title %txt000%%txt702%
color 4e
echo %txt703%...
if exist .\tmp del .\tmp
pause>nul
color
exit


:begin
if exist .\tmp del .\tmp
%javaPath% -jar %hmclPath%
start %~nx0 j
color
exit


:backup
if %backupRunTime% == 2 call :backupRT
if %backupRunTime% geq 1 if not exist .\dependencies\authlib-injector.jar xcopy /s /y %conDir%authlib-injector.jar .\dependencies\
if %backupGlobalConfig% == 2 call :backupGC
if %backupGlobalConfig% == 1 (
    mode con cols=60 lines=5
    echo .
    echo .
    echo %txt704%...
    pause>nul
    call :backupGC
)
if %removeGlobalConfig% == 2 (
    del %conDir%accounts.json
    del %conDir%config.json
)
if %removeRunTime% == 2 (
    del %trgPath%%fileName%
    del %conDir%authlib-injector.jar
)
exit


:backupGC
echo %txt705%...
xcopy /s /y %conDir%accounts.json .\globalConfig\
xcopy /s /y %conDir%config.json .\globalConfig\
goto :eof


:backupRT
echo %txt706%...
if %srcQuantity% neq %fileQuantity% xcopy /s %trgPath%%fileName% %srcPath%
goto :eof