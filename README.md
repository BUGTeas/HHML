# Hello HMCL! Launcher (HHML)
A best solution to run HMCL (Hello Minecraft! Launcher) on flash drive\
English [简体中文](README-SC.md) [Documents](https://bugteas.github.io/item.html?proFile=1919810/HHMLDocs/en.js)\
Latest version：3.5.3.229 Update 3 (Tested 3.5.5 can be use)
## HHML introduce
Hello HMCL! Launcher（below referred to as HHML）is a command script (support Windows only now), look from the name, this is a launcher written for the launcher.\
This script use to resolve the HMCL launcher (Hello Minecraft! Launcher) put some related config file and runtime to user directory in system, resulting in the need for reconfiguration on another system. The script will restore the downloaded runtime and global to user directory in system and back it up when exiting.\
in addition, the HHML can also make HMCL detect and auto select Java under the current diredtory, needn't install or add manually
## Simple usage
1. Download a Java archive (not the installer, can be OpenJDK) of the required version of the MC version you are playing and unzip it, and download latest version of HMCL in JAR format on the [HMCL official webside](https://hmcl.huangyuhui.net/download/)or the [official GitHub releases](https://github.com/huanghongxun/HMCL/releases/), an download Latest HHML script from Github Pages：\
Windows Chinese simplified editon: [HHML-SC-GB2312.bat](https://bugteas.github.io/HHML/Windows/HHML-SC-GB2312.bat)\
Windows English editon: [HHML-EN.bat](https://bugteas.github.io/HHML/Windows/HHML-EN.bat)\
if you using a non-Chinese simplified Windows or UTF-8 global language support has been enabled, please select the English edition, Otherwise garbled characters will appear, even cause errors!
2. put the HMCL JAR file and HHML script and unzipped java archive (multiple different versions can be placed) in the same directory (can be on a flash drive or hard disk)
3. run the HHML script, the script will secrch all Java archive in current directory automatic and pick the latest Java version to launch HMCL JAR file, soon the interface of HMCL will appear, but sometime also it's download runtimes (JavaFX) automatic, it puts it in the system by default, it is very troublesome to download it again after changing computers. So HHML can back it up to current directory in preparation for restoring to the system on another computer, saving time to download again.
4. With the help of HHML script, the HMCL not only can search installed Java in the system automatic, but also can search unzipped Java in current directory automatic. This mains you don't need to manually add a non-installed Java version path to custom path (unlike PCL2, only one custom Java path can be added in HMCL)
5. After that, you should launch HMCL via the HHML script instead of opening the JAR file directly. To speed up the game startup, you can enable "Do not check game integrity" option in advanced settings, because the intergrity check before the game launch requires a large amount of data to be copied to the system disk, if the game is on a flash disk, it will take a lot of time to complete this step.
## Advanced usage
### Custom Java path (relative path can be used)
Create a text file under the same directory as the script and named "customPath.txt". The text content is one Java path per line, like this:
```
C:\Users\Administrator\Desktop\jdk\archive\openlogic-openjdk-8u372-b07-windows-64
.\..\..\jdk\jdk-11.0.12
\software\jdk\archive\jdk-17.0.8+7
```
note: The Java path is not the directory where the Java binary is located, but the directory where the "bin" folder is located, which is equivalent to the JAVA_HOME variable.
### Config file
create a text file and named "config.txt". There can be no comments or blank lines in the file, and the format is "configuration=parameter", like this:
```
searchInCustPath=2
backupGlobalConfig=0
checkJava=0
use64java=1
```
### Auto backup/restore/remove configuration
Note: runtime here refers to AuthLib-Injector (external login dependencies) and Java FX (graphic interface dependencies), while global config here refers to config.json (user license) and accounts.json (global user list).\
If you want to use HHML script in hard disk, you definitely don't want HHML auto backup/restore/remove the runtime and the globel configuration. They are all located at user directory in system, since it's all on the hard drive, and don't have to change computers, is it still need to backup?\
So I provided some option about backup/restore/remove (they all parameter is 1):\
\
**Restore runtime**\
Configuration name: restoreRunTime\
parameter:
```
0: Never restore
1: Restore AuthLib，restore JavaFX if Java version is 11 or later and HMCL version is 3.3.183 or later
2: Always restore authlib and JavaFX (ignore the Java and HMCL version)
```
\
**Backup runtime**\
Configuration name: backupRunTime\
parameter:
```
0: Never backup
1: backup when "restoreRunTime" is enabled and need download runtime by HMCL. 
2: Always backup (even if it has been backed up)
```
\
**Remove runtime**\
Configuration name: removeRunTime\
parameter:
```
0: Never remove
1: Remove if they are both restored
2: Always remove (even if they are not restored)
```
\
**Restore global config**\
Configuration name: restoreRunTime\
parameter:
```
0: Never restore
1: Restore if they are both found in user directory in system
2: Always restore (even if it already exists before launch)
```
\
**Backup global config**\
Configuration name: backupRunTime\
parameter:
```
0: Never backup
1: If they already exist before launch, a pop-up window after the HMCL is closed allows the user to confirm whether to backup, otherwise the backup is automatically available
2: Always backup without user confirm  (even if it already exists before launch)
```
\
**Remove global config**\
Configuration name: removeRunTime\
parameter:
```
0: Never remove
1: Remove if it already restore
2: Always remove (even if it already exists before launch)
```

### Default Java search range configuration
You can set up script search in some range through this configuration, all parameter are follow:
```
0: Never search in this range
1: Search this range if Java are not found at previous range
2: Always search (even if Java has been found)
```
**Search custom path**\
Configuration name: searchInCustPath\
Default parameter: 2\
Java found in this range will add to temporary environment variable so that HMCL to detect it.\
\
**Search current directory**\
Configuration name: searchInCD\
Default parameter: 2\
Java found in this range will add to temporary environment variable so that HMCL to detect it.\
\
**Search %PATH% environment variable**\
Configuration name: searchInSysPath\
Default parameter: 1\
If you installed Java that can't be detected by HMCL, you can set the parameter of this configuration to 2.\
\
**Search JavaSoft registry**\
Configuration name: searchInSysPath\
Default parameter: 1\
Note: This is specific registry item of Oricle official Java, so OpenJDK may can't be found in this range.\
If you installed Java that can't be detected by HMCL, you can set the parameter of this configuration to 2, Java found in this range will add to temporary environment variable so that HMCL to detect it.\
\
**Search list of installed application**\
Configuration name: searchInInstApp
Default parameter: 1
Note: by default, search Java this range is only because it is not found at previous range, because it need traverse a lot of registry, it is too slow.
If you installed Java that can't be detected by HMCL, you can set the parameter of this configuration to 2, Java found in this range will add to temporary environment variable so that HMCL to detect it.
### Default Java detect & exclude configuration
You can set the Java detection rules with this option:\
\
**Detect Java version**\
Configuration name: checkJava\
Default parameter: 2\
Parameter:
```
0: Select last Java in the file order, not check Java version and bitness (not recommended, you need set bitness through "use64Java" configuration, the Java version will be proposed as 11)
1: Select last Java in the file order, and check its version and bitness
2: detect version and bitness of any founded Java and pick the latest version
```
\
**Use Java 8 preferred (only valid when parameter of checkJava is 2)**\
Default parameter: 0\
Configuration name: useJava8First\
Parameter:
```
0: pick latest version Java by version order
1: pick Java 8 preferred by version order, pick latest version if its not found
```
\
**Set Java bitness (only valid when parameter of checkJava is 0)**\
Configuration name: use64java\
Default parameter: x\
Parameter:
```
0: 32 Bit Java（X86）
1: 64 Bit Java（X64）
```
\
**Exclude some versions of Java (only valid when parameter of checkJava is 2)**\
Configuration name: verBlackList\
Usage: enter unwanted version number in the parameter (can be multiple, use comma "," to separated between each version), corresponding version will be excluded during version detecting.\
Default parameter: none\
Parameter demo:
```
verBlackList=1.8.0_272,17.0.1,11.0.2
```
