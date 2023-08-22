@echo off
rem Language config
set prd=.
set lb=^^(
set gb=^^)
set cma=, 
set cln=: 
set txt000=Hello HMCL! Launcher v3.5.3.229 Update 1
set txt001=^^(exclude
set txt002=Looking for HMCL ^^(JAR^^) file in the current directory
set txt003=No available HMCL found in the current directory, make sure it's in the same directory under this batch file and the name is ^"HMCL-^<Version number^>.jar^".
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
    set txt604=system
    set txt607=installed
)
if %searchInCD% neq 0 (
    set txten=1
    set txt606=the current directory
    set txt608=in the same directory under this batch file
)
if %searchInCustPath% neq 0 (
    set txten=1
    set txt601=the custom path
    set txt602=in the custom path
)
if %txten% == 1 (
    set txt603=in 
    set txt609=make sure it's 
) else set txt609=All search for Java have been disabled, please check the "config.txt"
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