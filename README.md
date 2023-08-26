# Hello HMCL! Launcher (HHML)
A best solution to run HMCL (Hello Minecraft! Launcher) on flash drive
Latest version：3.5.3.229 Update 1
## HHML introduce
Hello HMCL! Launcher（below referred to as HHML）is a command script (support Windows only now), look from the name, this is a launcher written for the launcher.\
This script use to resolve the HMCL launcher (Hello Minecraft! Launcher) put some related config file and runtime to user directory in system, resulting in the need for reconfiguration on another system. The script will restore the downloaded runtime and global to user directory in system and back it up when exiting.\
in addition, the HHML can also make HMCL detect and auto select Java under the current diredtory, needn't install or add manually
## Simple usage
1. Download a Java archive (can be OpenJDK) of the required version of the MC version you are playing (not the installer) and unzip it, and download latest version of HMCL in JAR format on the [HMCL official webside](https://hmcl.huangyuhui.net/download/), and download latest version HHML script in release or Github pages.\
(if you using a non-Chinese simplified Windows or UTF-8 global language support has been enabled, please select the English edition, Otherwise garbled characters will appear, even cause errors!)
2. put the HMCL JAR file and HHML script and unzipped java archive (multiple different versions can be placed) in the same directory (can be on a flash drive or hard disk)
3. run the HHML script, the script will secrch all Java archive in current directory automatic and pick the latest Java version to launch HMCL JAR file, soon the interface of HMCL will appear, but sometime also it's download runtimes (JavaFX) automatic, it puts it in the system by default, it is very troublesome to download it again after changing computers. So HHML can back it up to current directory in preparation for restoring to the system on another computer, saving time to download again.
4. With the help of HHML script, the HMCL not only can search installed Java in the system automatic, but also can search unzipped Java in current directory automatic. This mains you don't need to manually add a non-installed Java version path to custom path (unlike PCL2, only one custom Java path can be added in HMCL)
5. After that, HMCL should be launched via the HHML script instead of opening the JAR file directly. To speed up the game startup, you can enable "Do not check game integrity" option in advanced settings, because the intergrity check before the game launch requires a large amount of data to be copied to the system disk, if the game is on a flash disk, it will take a lot of time to complete this step.
## Advanced usage
### Custom Java path (relative path can be used)
Create a text file and named "customPath.txt". The text content is one Java path per line, like this:
```
C:\Users\Administrator\Desktop\jdk\archive\openlogic-openjdk-8u372-b07-windows-64
.\..\..\jdk\jdk-11.0.12
\software\jdk\archive\jdk-17.0.8+7
```
note: The Java path is not the directory where the Java binary is located, but the directory where the "bin" folder is located, which is equivalent to the JAVA_HOME variable.
### Config file
create a text file and named "config.txt". There can be no comments or blank lines in the file, and the format is "option=parameter", like this:
```
searchInCustPath=2
backupGlobalConfig=0
checkJava=0
use64java=1
```
### Auto backup/restore/remove configuration
If you want to use HHML script in hard disk, you definitely don't want HHML auto backup/restore/remove the runtime and the globel configuration. They are all located at "%userprofile%\AppData\Roaming\.hmcl" (windows), since it's all on the hard drive, and don't have to change computers, is it still need to backup?\
So I provided some option about backup/restore/remove:\
\
Restore runtime:\
option: "restoreRunTime"\
parameter:
```
0: Never restore
1: Restore authlib (external login dependencies) and decide whether to restore the JavaFX based on the Java and HMCL versions (if selected Java version earlier than 11 or selected HMCL version earlier then 3.3.183, the JavaFX is not resumed)
2: Force restore authlib and JavaFX (ignore the Java and HMCL version)
```
\
backup runtime:\
option: "backupRunTime"\
parameter:
```
0: Never backup
1: backup authlib (external login dependencies) and JavaFX when "restoreRunTime" is enabled and need download runtime by HMCL. 
2: Always backup authlib and JavaFX (even if it has been backed up)
```
\
remove runtime:\
option: "removeRunTime"\
parameter:
```
0: Never remove
1: Remove authlib (external login dependencies) and JavaFX. (if they are both restored)
2: Always remove authlib and JavaFX (even if they are not restored)
```
\
