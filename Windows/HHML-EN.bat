@echo off
if "%1" == "up" goto launch
if "%1" == "backup" goto afterExit

setlocal enabledelayedexpansion

rem Language config
set prd=.
set lb=^^(
set gb=^^)
set cma=, 
set cln=: 
set txt000=Hello HMCL! Launcher v3.5.3.229 Update 5
set txt001= ^^(exclude
set txt002=Looking for HMCL ^^(JAR^^) file in the current directory
set txt003=No available HMCL found in the current directory, make sure it's in the same directory under this batch file and the name format is ^"HMCL-^<Version number^>.jar^".
set txt004=HMCL was found, named
set txt005=, version number is
set txt006= ^(Converted to an integer^).
set txt100=Java path is
set txt101=Looking for installed Java in system
set txt102=Looking for Java in the current directory
set txt103=Detected
set txt104=Looking for Java in the custom path
set txt105=bit 
set txt201=No available Java found
set txt202=
set txt203=
set txt301=will be used, version is
set txt302=, path is
set txt501=Restoring global config
set txt502=Restoring external login dependencies
set txt503=Restoring runtime module
set txt504=The runtime module is not found for the current HMCL version, will download automatically by HMCL ^^(just this once^^). when HMCL exiting, It is automatically backed up here for the next boot.
set txt505=Unable to automatically backup/restore/remove the runtime because the Java bit width is unknown.
set txt506=Please check the Java bit width ^^(32bit/64bit^^) and configure the ^"use64java^" ^^(Whether to use 64bit Java^^) parameter to 0/1 in ^"config.txt^" file.
set txt701=trying to hide shell...
set txt702= ^^(Error^^)
set txt703=Press any key to exit
set txt704=Press any key to backup the current global config, close the window to cancel.
set txt705=Backing up login status for next boot
set txt706=Backing up runtime module for next boot

set txt106=Looking for Java in JavaSoft registry
set txt109=Looking for Java in %%PATH%% environment variable
set txt107=Version 
set txt108= is in the black list, will skip it. ^^(If it is installed in system, HMCL may bypass the blacklist and detect it^^)
set txt707=If you want to backup the current global config, input ^"y^" and press Enter key: 
set txt708=Will not backup the current global config this time.
set txt709=HMCL has exited.


echo %txt000%
title %txt000%

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
set searchInSysPath=2
set searchInJavaReg=2
set searchInInstApp=1
rem Default Java check configuration
set checkJava=2
set useJava8First=0
set use64java=x
set verBlackList=none
rem Default HMCL log display configuration
set showHMCLlog=0


rem Show excluded items
for /f "tokens=*" %%a in (config.txt) do if "%%a" neq "" set %%a
if "%verBlackList%" neq "none" set exclude=%txt001% %verBlackList%%gb%


rem Search HMCL in the current directory
echo %txt002%...
set hmclLatestPath=none
for /f "tokens=*" %%i in ('dir /b HMCL*.jar') do (
    set g=n
    set "hmclPath=%%i"
    set "cnt=4"
    set "vaildCnt=0"
    set "olderHMCL=0"
    call :testHMCL
)
if %hmclLatestPath% == none (
    echo %txt003%
    goto error
) else set hmclPath=%hmclLatestPath%
set hmclVer=%hv1%%hv2%%hv3%%hv4%%hv5%
if %hmclVer% lss 1000 set hmclVer=%hmclVer%0
if %hmclVer% lss 10000 set hmclVer=%hmclVer%0
if %hmclVer% lss 100000 set hmclVer=%hmclVer%0
if %hmclVer% lss 1000000 set hmclVer=%hmclVer%0
if %hmclVer% lss 10000000 set hmclVer=%hmclVer%0
echo %txt004% %hmclPath%%txt005% "%hmclVer%"%txt006%
goto findJava
:testHMCL
set string=!hmclPath:~%cnt%,1!
set gtr=0
echo %string%|findstr "[^0-9]">nul&&(
    set g=g
    if !hv%vaildCnt%! lss !lv%vaildCnt%! (
        set hv%vaildCnt%=!lv%vaildCnt%!
        set hmclLatestPath=%hmclPath%
        set /a resetCnt=%vaildCnt%+1
        call :resetHMCLVer
    ) else if !hv%vaildCnt%! gtr !lv%vaildCnt%! set olderHMCL=1
    set lv%vaildCnt%=
)||if %olderHMCL% equ 0 call :setHMCLVer
if "%string%" neq "" (
    set /a cnt+=1
    goto testHMCL
)
goto :eof
:setHMCLVer
if %g% equ g (
    set g=n
    set /a vaildcnt+=1
)
if "!hv%vaildCnt%!" equ "" set hv%vaildCnt%=0
set lv%vaildCnt%=!lv%vaildCnt%!%string%
goto :eof
:resetHMCLVer
if "!hv%resetCnt%!" neq "" (
    set /a resetCnt+=1
    set hv%resetCnt%=0
    goto resetHMCLVer
)
goto :eof


:findJava
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
if %ssp% == 2 call :findPathJava
if %sjr% == 2 call :findJavaReg
if %scp% == 2 call :findCustJava
if %scd% == 2 call :findCDJava
if %sia% == 2 call :findInstJava
if %checkJava% == 1 call :testJava
if %checkJava% geq 1 (
    goto selectJava
) else (
    echo %txt100% "%javaPath%"%prd%
    set jv1=11
    if "%javaPath%" == "none" goto javaNotFound
    goto restoreSomething
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
        if %checkJava% == 2 (call :testJava) else (call :addPath)
        cd /d %lastcd%
    )
)
call :checkPath
goto :eof


rem Find Java under the current directory
:findCDJava
echo %txt102%...
set lastcd="%cd%"
for /r %%b in (*java.exe) do (
    if /i "%%~nxb" equ "java.exe" (
        set sPath=%%b
        call :testCDJava
    )
)
if "%cd%" neq %lastcd% cd /d %lastcd%
call :checkPath
goto :eof
rem Test Java under the current directory
:testCDJava
cd /d "%sPath%\..\..\"
set javaPath=%cd%
if %checkJava% == 2 (call :testJava) else (call :addPath)
goto :eof


rem Find Java in PATH value
:findPathJava
echo %txt109%...
set lastcd="%cd%"
set pcnt=0
:findPathWork
set /a pcnt+=1
for /f "delims=; tokens=%pcnt%" %%p in ("%PATH%") do (
    if exist "%%p\java.exe" (
        cd /d "%%p\..\"
        call :existPathJava
    )
    goto findPathWork
)
if "%cd%" neq %lastcd% cd /d %lastcd%
goto :eof
:existPathJava
set javaPath=%cd%
set inPathvar=6
if %checkJava% == 2 call :testJava
set inPathvar=
goto :eof


rem Find Java in JavaSoft registry
:findJavaReg
echo %txt106%...
set lastcd="%cd%"
for /f "tokens=*" %%a in ('reg query "HKLM\SOFTWARE\JavaSoft"') do (
    for /f "tokens=*" %%i in ('reg query "%%a" ^| findstr /i "%%a"') do (
        for /f "tokens=*" %%j in ('reg query "%%i" ^| findstr /i "%%i"') do (
            for /f "tokens=*" %%l in ('reg query "%%j" ^| findstr /i "JavaHome"') do (
                set "instPath=%%l"
                call :getJavaRegPath
            )
        )
    )
)
if "%cd%" neq %lastcd% cd /d %lastcd%
call :checkPath
goto :eof
rem Test Java in JavaSoft registry
:getJavaRegPath
if exist "%instPath:~22%\bin\java.exe" (
    set javaPath=%instPath:~22%
    if %checkJava% == 2 (call :testJava) else (call :addPath)
)
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
if "%cd%" neq %lastcd% cd /d %lastcd%
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
rem Get installation path
:getInstInfo
for /f "tokens=*" %%b in ('reg query "%rp%\%1" /v "InstallLocation" 2^>nul ^|findstr /i "InstallLocation"') do (
  set instPath=%%b
  call :getInstPath
)
goto :eof
rem Test Java under the installation path
:getInstPath
if exist "%instPath:~29%bin\java.exe" (
    set javaPath=%instPath:~29%
    if %checkJava% == 2 (call :testJava) else (call :addPath)
)
goto :eof


rem Add Java bin directory to %PATH% value
:addPath
set PATH=%javaPath%\bin;%PATH%
goto :eof


rem Check Java and pick out the latest version
:testJava
rem Get Java bitness and version
if not exist "%javaPath%\release" goto :eof
cd /d "%javaPath%"
for /f "tokens=*" %%a in (release) do if "%%a" neq "" set %%a
rem Check bitness
set use64java=0
if %OS_ARCH% == "amd64" set use64java=1
if %OS_ARCH% == "x86_64" set use64java=1
rem Check version
if %use64java% == 1 (set txtbit=64) else (set txtbit=32)
echo %txt103% %txtbit% %txt105%Java%cln%%JAVA_VERSION%%prd%
set cnt=1
set inBlackList=0
call :getBlackList
if %inBlackList% equ 1 goto :eof
if %checkJava% == 2 if "%inPathvar%" == "" call :addPath
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
set lv1=0
for /f "tokens=1" %%i in ("%verl%") do set lv1=%%i
set lv2=0
for /f "tokens=2" %%i in ("%verl%") do set lv2=%%i
set lv3=0
for /f "tokens=3" %%i in ("%verl%") do set lv3=%%i
set verSet=0
if %jv1% leq %lv1% (
    if %jv1% lss %lv1% (
        set jv1=%lv1%
        set verSet=1
    )
    if %jv2% leq %lv2% (
        if %jv2% lss %lv2% (
            set jv2=%lv2%
            set verSet=1
        )
        if %jv3% lss %lv3% (
            set jv3=%lv3%
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
:getBlackList
for /f "delims=, tokens=%cnt%" %%b in ("%verBlackList%") do (
    if "%%b" equ %JAVA_VERSION% (
        echo %txt107%%JAVA_VERSION%%txt108%
        set inBlackList=1
    ) else (
        set /a cnt+=1
        goto getBlackList
    )
)
goto :eof


rem Java not found
:javaNotFound
echo %txt201%%exclude%%prd%
goto error


:selectJava
if "%java8Path%" == "none" (
    if "%javaNewPath%" == "none" (goto javaNotFound) else (
        echo Java %txt301% %javaNewVer%%txt302% "%javaNewPath%"%prd%
        set "javaPath=%javaNewPath%"
        set use64java=%use64javaNew%
    )
) else (
    echo Java 8 %txt301% %java8Ver%%txt302% "%java8Path%"%prd%
    set "javaPath=%java8Path%"
    set use64java=%use64java8%
)


:restoreSomething
set rth1=dependencies\windows-x86
set rth2=\openjfx\
set conDir=%userprofile%\AppData\Roaming\.hmcl\
rem if %restoreGlobalConfig% geq 1 if not exist %conDir%config.json if not exist %conDir%accounts.json set restoreGlobalConfig=2
if %restoreGlobalConfig% geq 1 if not exist %conDir%config.json set restoreGlobalConfig=2
if %restoreGlobalConfig% == 2 (
    if exist .\globalConfig\ (
        echo %txt501%...
        rem xcopy /s /y .\globalConfig\accounts.json %conDir%
        xcopy /s /y .\globalConfig\config.json %conDir%
    )
    if %backupGlobalConfig% == 1 set backupGlobalConfig=2
    if %removeGlobalConfig% == 1 set removeGlobalConfig=2
)


if %restoreRunTime% geq 1 (
    echo %txt502%...
    if not exist %conDir%authlib-injector.jar (
        if exist .\dependencies\authlib-injector.jar xcopy /s .\dependencies\authlib-injector.jar %conDir%
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
    goto error
)
set srcPath=.\%rth1%%rthw%%rth2%
set trgPath=%conDir%%rth1%%rthw%%rth2%
if %hmclVer% LSS 35322900 (
    set fileQuantity=6
    if %hmclVer% LSS 35221700 (
        set srcPath=.\%rth1%%rthw%\
        set trgPath=%conDir%dependencies\
        if %hmclVer% LSS 34202000 (set fileName=javafx-*-16-win%rthm%.jar) else (set fileName=javafx-*-17-win%rthm%.jar)
    ) else (set fileName=javafx-*-17.0.2-win%rthm%.jar)
) else (
    set fileQuantity=5
    set fileName=javafx-*-19.0.2.1-win%rthm%.jar
)
set srcQuantity=0
for /f "tokens=*" %%i in ('dir /b %srcPath%%fileName%') do set /a srcQuantity+=1
set trgQuantity=0
for /f "tokens=*" %%i in ('dir /b %trgPath%%fileName%') do set /a trgQuantity+=1
if %restoreRunTime% == 2 call :restoreRT
if %showHMCLlog% == 0 goto beforeStart
"%javaPath%\bin\java.exe" -jar %hmclPath%
goto afterExit


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
mshta vbscript:createobject("wscript.shell").run("""%~nx0"" up",0)(window.close)
goto end


:launch
"%javaPath%\bin\java.exe" -jar %hmclPath%
start %~nx0 backup
goto end


:afterExit
echo .
echo %txt709%
if %backupRunTime% == 2 (
    echo %txt706%...
    if %srcQuantity% neq %fileQuantity% xcopy /s /y %trgPath%%fileName% %srcPath%
    if not exist .\dependencies\authlib-injector.jar xcopy /s %conDir%authlib-injector.jar .\dependencies\
)
if %backupGlobalConfig% == 2 call :backupGC
rem if %backupGlobalConfig% == 1 (
rem     if %showHMCLlog% == 0 (
rem         mode con cols=90 lines=5
rem         echo .
rem         echo .
rem         echo %txt704%...
rem         pause>nul
rem         call :backupGC
rem     ) else call :backupGCSelect
rem )
if %removeGlobalConfig% == 2 (
    rem del %conDir%accounts.json
    del %conDir%config.json
)
if %removeRunTime% == 2 (
    set removeJavaFX=1
    set removeAuthLib=1
)
if %removeJavaFX% == 1 del %trgPath%%fileName%
if %removeAuthLib% == 1 del %conDir%authlib-injector.jar
if %showHMCLlog% == 0 exit
goto end


:backupGCSelect
set gc=n
set /p gc=%txt707%
if %gc% neq y (
    echo %txt708%
    goto :eof
)
:backupGC
echo %txt705%...
rem xcopy /s /y %conDir%accounts.json .\globalConfig\
xcopy /s /y %conDir%config.json .\globalConfig\
goto :eof


rem When cause error
:error
title %txt000%%txt702%
color 4e
echo %txt703%...
pause>nul
color


:end