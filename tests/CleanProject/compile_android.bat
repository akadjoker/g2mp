@echo off
pushd %~dp0
set PATH_NDK=D:\android\ndk\
set COMPILE_DIR=%~dp0
set COMPILE_TARGET=CleanProjectAndroid.lpr
set COMPILER_DIR=%COMPILE_DIR%..\..\tools\Toolkit\fpc\3.0.0\
set COMPILER_EXE=bin\i386-win32\ppcrossarm.exe
set PATH_G2MP=%COMPILE_DIR%..\..\source\
set PATH_ZLIB=%COMPILER_DIR%source\packages\paszlib\src\
set PATH_OPENAL_LIB=%COMPILER_DIR%..\..\..\..\libs\OpenAL\Android\
call %COMPILER_DIR%%COMPILER_EXE% %COMPILE_DIR%%COMPILE_TARGET%^
 -Tandroid^
 -Parm^
 -MObjFPC^
 -Scghi^
 -O1^
 -Xs^
 -XX^
 -Xd^
 -CpARMV6^
 -FLlibdl.so^
 -l^
 -vewnhibq^
 -Fi"%COMPILE_DIR%obj"^
 -Fl"%PATH_NDK%platforms\android-8\arch-arm\usr\lib"^
 -Fl"%PATH_NDK%toolchains\arm-linux-androideabi-4.6\prebuilt\windows\lib\gcc\arm-linux-androideabi\4.6"^
 -Fl"%PATH_OPENAL_LIB%"^
 -FU"%COMPILE_DIR%obj"^
 -Fu"%COMPILE_DIR%"^
 -Fu"%COMPILE_DIR%source\"^
 -Fu"%COMPILE_DIR%obj"^
 -Fu"%COMPILER_DIR%units\arm-android"^
 -Fu"%COMPILER_DIR%units\arm-android\rtl"^
 -Fi"%PATH_G2MP%"^
 -Fu"%PATH_G2MP%"^
 -Fu"%PATH_ZLIB%"^
 -FE"%COMPILE_DIR%bin"^
 -oCleanProjectAndroid.so
pause
:exit
popd