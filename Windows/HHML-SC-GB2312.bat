@echo off
rem Language config
set prd=。
set lb=（
set gb=）
set cma=，
set cln=：
set txt000=Hello HMCL! Launcher v3.5.3.229 Update 1
set txt001=（排除
set txt002=正在从当前目录下寻找 HMCL（JAR）文件
set txt003=当前目录下找不到可用的 HMCL，请确保它位于此批处理下的同一目录且名称为“HMCL-^^^<版本号^^^>.jar”。
set txt004=已找到 HMCL，名为
set txt005=，版本号为
set txt006=（已转换为整数）
set txt100=Java 路径为
set txt101=正在从系统中寻找 Java
set txt102=正在从当前目录下寻找 Java
set txt103=已检测到
set txt104=正在从自定义路径下寻找 Java
set txt105=位 
set txt201=
set txt202=找不到可用的 Java
set txt203=
set txt301=将被使用，版本号为
set txt302=，路径为
set txt501=正在还原全局配置
set txt502=正在还原外置登录依赖
set txt503=正在还原运行时组件
set txt504=找不到适用于当前 HMCL 版本的运行时组件，将由 HMCL 自动下载（就这一次）。当 HMCL 退出时，会自动将其复制到此以备下次启动。
set txt505=无法自动备份/还原/删除运行时组件，因为未知 Java 的位宽。
set txt506=请检查 Java 的位宽（32位/64位）并在“config.txt”文件中配置“use64java”参数为0/1。
set txt701=正在尝试隐藏 Shell...
set txt702=（错误）
set txt703=按任意键退出
set txt704=按任意键备份全局配置，关闭窗口则取消
set txt705=正在复制全局配置以备下次启动
set txt706=正在复制运行时组件以备下次启动


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
set searchInCustPath=2
set searchInCD=2
set searchInSysPath=1
set searchInJavaReg=1
set searchInInstApp=1
rem Default Java check configuration
set checkJava=2
set useJava8First=0
set use64java=x
set verBlackList=none


rem Show excluded items
for /f "tokens=*" %%a in (config.txt) do if "%%a" neq "" set %%a
set excStatus=0
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
set subVer8=0
set javaNewPath=none
set javaNewVer=0
set jv1=0
set jv2=0
set jv3=0
set removeJavaFX=0
set removeAuthLib=0


set scp=%searchInCustPath%
set scd=%searchInCD%
set ssp=%searchInSysPath%
set sjr=%searchInJavaReg%
set sia=%searchInInstApp%
call :checkPath
if %scp% == 2 call :findCustJava
if %scd% == 2 call :findCDJava
if %sia% == 2 call :findInstJava
if %checkJava% == 1 call :testJava
if %checkJava% geq 1 (goto checkOther) else (
    echo %txt100% "%javaPath%"%prd%
    set jv1=11
    if "%javaPath%" == "none" goto notFind
    goto loadOther
)


:checkPath
set jnf=0
if %checkJava% == 2 (if "%javaNewPath%" == "none" (set jnf=1)) else if "%javaPath%" == "none" (set jnf=1)
if %jnf% == 1 (
    if %searchInCustPath% == 1 set scp=2
    if %searchInCD% == 1 set scd=2
    if %searchInSysPath% == 1 set ssp=2
    if %searchInJavaReg% == 1 set sjr=2
    if %searchInInstApp% == 1 set sia=2
) else (
    set scp=%searchInCustPath%
    set scd=%searchInCD%
    set ssp=%searchInSysPath%
    set sjr=%searchInJavaReg%
    set sia=%searchInInstApp%
)
goto :eof


rem Find Java in custom path
:findCustJava
echo %txt104%...
set lastcd="%cd%"
for /f "tokens=*" %%i in (customPath.txt) do (
    if exist "%%i\bin\java.exe" (
        set javaPath=%%i
        call :addPath
        if %checkJava% == 2 call :testJava
    )
)
if "%cd%" neq %lastcd% cd %lastcd%
call :checkPath
goto :eof


rem Find Java in system
:findInstJava
echo %txt101%...
set lastcd="%cd%"
rem Software installation list registry location
set rp=HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall
call :findInstWork
set rp=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
call :findInstWork
set rp=HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall
call :findInstWork
if "%cd%" neq %lastcd% cd %lastcd%
call :checkPath
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
    for /f "tokens=*" %%l in ('reg query "%rp%\%%~na" /v "DisplayName" 2^>nul ^|findstr /i "jre"') do (
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
    set javaPath=%instPath:~29%
    call :addPath
    if %checkJava% == 2 call :testJava
)
goto :eof


rem Find Java in the current directory
:findCDJava
echo %txt102%...
set FileName=java.exe
set lastcd="%cd%"
for /r %%b in (*%FileName%) do (
    if /i "%%~nxb" equ "%FileName%" (
        set sPath=%%b
        call :testCDJava
    )
)
if "%cd%" neq %lastcd% cd %lastcd%
call :checkPath
goto :eof

:testCDJava
cd %sPath%\..\..\
set javaPath=%cd%
call :addPath
if %checkJava% == 2 call :testJava
goto :eof


:addPath
set PATH=%javaPath%\bin;%PATH%
goto :eof


rem Check Java and pick out the latest version
:testJava
rem Get Java bitness and version
if not exist "%javaPath%\release" goto :eof
cd "%javaPath%"
for /f "tokens=*" %%a in (release) do if "%%a" neq "" set %%a
set use64java=0
if %OS_ARCH% == "amd64" set use64java=1
if %OS_ARCH% == "x86_64" set use64java=1
rem Check version
if %use64java% == 1 (set txtbit=64) else (set txtbit=32)
echo %txt103% %txtbit% %txt105%Java%cln%%JAVA_VERSION%%prd%
for /f "tokens=*" %%b in ('echo %verBlackList% ^|findstr /i %JAVA_VERSION%') do goto :eof
set ver=%JAVA_VERSION:_= %
set ver=%ver:"=%
rem Get subversion number behind the underline of old version number format（1.x.0_xxx）
set sv8=0
for /f "tokens=2" %%i in ("%ver%") do set sv8=%%i
set sv8=%sv8:-= %
for /f "tokens=1" %%i in ("%sv8%") do set sv8=%%i
rem If enable %useJava8First% and found Java 8
if %useJava8First% == 1 if %subVer8% lss %sv8% (
    set subVer8=%sv8%
    set java8Ver=%JAVA_VERSION%
    set "java8Path=%javaPath%"
    set use64java8=%use64java%
)


rem Get Newer version number
for /f "tokens=1" %%i in ("%ver%") do set ver=%%i
set verl=%ver:.= %
set v1=0
for /f "tokens=1" %%i in ("%verl%") do set v1=%%i
set v2=0
for /f "tokens=2" %%i in ("%verl%") do set v2=%%i
set v3=0
for /f "tokens=3" %%i in ("%verl%") do set v3=%%i

set verSet=0
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
if %verSet% == 1 (
    set javaNewVer=%JAVA_VERSION%
    set "javaNewPath=%javaPath%"
    set use64javaNew=%use64java%
)
goto :eof


rem Java not found
:notFind
set txten=0
if %searchInInstApp% neq 0 (
    set txten=1
    set txt604=系统中
    set txt607=已安装
)
if %searchInCD% neq 0 (
    set txten=1
    set txt606=当前目录下
    set txt608=位于此批处理下的同一目录下
)
if %searchInCustPath% neq 0 (
    set txten=1
    set txt601=自定义路径
    set txt602=在自定义路径中
)
if %txten% == 1 (
    set txt603=in 
    set txt609=make sure it's 
) else set txt609=所有寻找 Java 的功能均已关闭，请检查配置文件“config.txt”
if %searchInInstApp% neq 0 if %searchInCD% neq 0 set txt605= or 
if %searchInCustPath% neq 0 if %searchInInstApp% neq 0 set txt600= or 
if %searchInCustPath% neq 0 if %searchInCD% neq 0 set txt600= or 
echo %txt201%%exclude%%txt603%%txt601%%txt600%%txt604%%txt605%%txt606%%txt202%%cma%%txt203%%txt609%%txt602%%txt600%%txt607%%txt605%%txt608%%prd%
goto baterror


:checkOther
if "%java8Path%" == "none" (
    if "%javaNewPath%" == "none" (goto notFind) else (
        echo Java %txt301% %javaNewVer%%txt302% "%javaNewPath%"%prd%
        set "javaPath=%javaNewPath%"
        set use64java=%use64javaNew%
    )
) else (
    echo Java 8 %txt301% %java8Ver%%txt302% "%java8Path%"%prd%
    set "javaPath=%java8Path%"
    set use64java=%use64java8%
)


:loadOther
set rth1=dependencies\windows-x86
set rth2=\openjfx\
set conDir=%userprofile%\AppData\Roaming\.hmcl\
if %restoreGlobalConfig% geq 1 if not exist %conDir%config.json if not exist %conDir%accounts.json set restoreGlobalConfig=2
if %restoreGlobalConfig% == 2 (if exist .\globalConfig\ (
    echo %txt501%...
    xcopy /s /y .\globalConfig\accounts.json %conDir%
    xcopy /s /y .\globalConfig\config.json %conDir%
    if %backupGlobalConfig% == 1 set backupGlobalConfig=2
    if %removeGlobalConfig% == 1 set removeGlobalConfig=2
))


if %restoreRunTime% geq 1 (
    echo %txt502%...
    if exist .\dependencies\authlib-injector.jar if not exist %conDir%authlib-injector.jar (
        xcopy /s .\dependencies\authlib-injector.jar %conDir%
        if %removeRunTime% == 1 set removeAuthLib=1
    )
    if not exist .\dependencies\authlib-injector.jar (
        if not exist %conDir%authlib-injector.jar if %removeRunTime% == 1 set removeAuthLib=1
        if %backupRunTime% == 1 set backupRunTime=2
    )
    if %java8Ver% == 0 if %jv1% geq 11 if %hmclVer% geq 33183000 set restoreRunTime=2
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
    if %removeRunTime% == 1 set removeJavaFX=1
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
"%javaPath%\bin\java.exe" -jar %hmclPath%
start %~nx0 j
color
exit


:backup
if %backupRunTime% == 2 (
    echo %txt706%...
    if %srcQuantity% neq %fileQuantity% xcopy /s /y %trgPath%%fileName% %srcPath%
    if not exist .\dependencies\authlib-injector.jar xcopy /s %conDir%authlib-injector.jar .\dependencies\
)
if %backupGlobalConfig% == 2 call :backupGC
if %backupGlobalConfig% == 1 (
    mode con cols=90 lines=5
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
    set removeJavaFX=1
    set removeAuthLib=1
)
if %removeJavaFX% == 1 del %trgPath%%fileName%
if %removeAuthLib% == 1 del %conDir%authlib-injector.jar
exit


:backupGC
echo %txt705%...
xcopy /s /y %conDir%accounts.json .\globalConfig\
xcopy /s /y %conDir%config.json .\globalConfig\
goto :eof