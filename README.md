# DRT
A better Delphi runtime.

Combine with librarys in C code.
Now contains:
- Zlib 1.2.12 from https://github.com/jtkukunas/zlib
- XXHASH 0.8.1 from https://github.com/Cyan4973/xxHash
- LZ4 from https://github.com/lz4/lz4
- zstd from https://github.com/facebook/zstd
- fastmm5 from https://github.com/pleriche/FastMM5 (used in windows platforms)
- mimalloc from https://github.com/microsoft/mimalloc (used in non windows platforms)
-
- Update 2022/05/02: Add FastMM5(for Windows) and mimalloc(for other platforms), and Patch move function to use MSVCRT's memmove implement(Windows only, other platforms already use CRT's memmove)

- Update 2022/04/24: Add WebView2Loader Support for FMX Edge, no more DLL needed for FMX Win App. and Add a lot WebView2 Related Units from https://github.com/salvadordf/WebView4Delphi

- Update 2022/04/23:
Add WebView2Loader PASCAL implementation, so no more WebView2Loader.DLL needed.
Translated from https://github.com/jchv/OpenWebView2Loader


Usage: 
Extract the C library files from BIN.7z
Put the DLL files to Windows's search path.
Put the .A files to Delphi's library search path.
Add DRT.Init unit in your project's uses list's first place.
For non-Windows platform, add the mimalloc.o(extract from the bin.7z archie) file's absolute path(with file name) to your Project Options->Delphi Compiler->Linking->Options pass to the LD Linker

And, if you failed with linking linux project, copy two files from your android SDK's buil-tools' lld-bin folder(like 'C:\android\build-tools\33.0.0-rc2\lld-bin\*') to your delphi's bin folder, rename the lld.exe to ld-linux.exe replace the old one(which you should back up first)

解压BIN.7Z压缩包
其中的DLL文件放置在Windows的path搜索路径上
其中的.A文件放置在Delphi的Library搜索路径上(注意每个编译平台的路径是单独设置的)
要使用DRT库请将DRT.Init单元放在你项目uses列表的第一个单元当中(如同FASTMM的惯例)
开发LINUX项目时，将BIN.7Z内的mimalloc.o文件的带绝对路径文件名，填写到Project Options->Delphi Compiler->Linking->Options pass to the LD Linker栏目中
另，如果你链接LINUX项目失败，从android SDK的build-tool 目录的lld-bin目录(例如 'C:\android\build-tools\33.0.0-rc2\lld-bin\*'), 复制全部2个文件到DELPHI安装路径的BIN目录下，将lld.exe改名为ld-linux.exe取代原来的(记得先备份) 

-更新 2022/05/02 添加FASTMM5(Windows)和mimalloc(非WINDOWS)两个优化内存管理器，大幅度提升多线程环境下的内存管理性能，替换WINDOWS下的MOVE函数为系统C运行库的memmove函数(只对WINDOWS有效，非WINDOWS平台已经用的是memmove没有修改必要)

- 更新 2022/04/24 支持FMX WebBrowser使用Edge引擎时去除WebView2Loader.DLL依赖，添加一堆WebView2相关接口定义单元，贡献自https://github.com/salvadordf/WebView4Delphi

- 更新 2022/04/23:
添加DRT.WIN.WebView2Loader单元，PASCAL代码实现WebView2Loader.DLL的功能，嵌入EdgeBrowser控件不再需要附带那个DLL了(但是WebVew2 Runtime还是要安装的)
实现方法来自 https://github.com/jchv/OpenWebView2Loader
