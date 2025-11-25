@echo off
echo 正在设置Harvester App开发环境...

REM 设置Java环境变量
setx JAVA_HOME "C:\Program Files\Eclipse Adoptium\jdk-11.0.25-hotspot"
setx PATH "%PATH%;%JAVA_HOME%\bin"

REM 设置Android环境变量
setx ANDROID_HOME "%USERPROFILE%\AppData\Local\Android\Sdk"
setx ANDROID_SDK_ROOT "%USERPROFILE%\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\36.0.0"

echo 环境变量设置完成！
echo 请重新启动命令行工具以使更改生效。
pause