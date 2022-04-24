# DRT
A better Delphi runtime.

Combine with librarys in C code.

- Update 2022/04/24: Add WebView2Loader Support for FMX Edge, no more DLL needed for FMX Win App. and Add a lot WebView2 Related Units from https://github.com/salvadordf/WebView4Delphi

- Update 2022/04/23:
Add WebView2Loader PASCAL implementation, so no more WebView2Loader.DLL needed.
Translated from https://github.com/jchv/OpenWebView2Loader


Usage: 
Extract the C library files from BIN.7z
Put the DLL files to Windows's search path.
Put the .A files to Delphi's library search path.

解压BIN.7Z压缩包
其中的DLL文件放置在Windows的path搜索路径上
其中的.A文件放置在Delphi的Library搜索路径上(注意每个编译平台的路径是单独设置的)

- 更新 2022/04/24 支持FMX WebBrowser使用Edge引擎时去除WebView2Loader.DLL依赖，添加一堆WebView2相关接口定义单元，贡献自https://github.com/salvadordf/WebView4Delphi

- 更新 2022/04/23:
添加DRT.WIN.WebView2Loader单元，PASCAL代码实现WebView2Loader.DLL的功能，嵌入EdgeBrowser控件不再需要附带那个DLL了(但是WebVew2 Runtime还是要安装的)
实现方法来自 https://github.com/jchv/OpenWebView2Loader
