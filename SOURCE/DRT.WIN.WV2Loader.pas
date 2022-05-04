unit DRT.WIN.WV2Loader;

interface

implementation
uses Winapi.Windows, Winapi.WebView2,Winapi.EdgeUtils,DRT.WIN.WebView2Loader;

type
  TCreateCoreWebView2EnvironmentWithOptions = function(
    browserExecutableFolder, userDataFolder: LPCWSTR; const environmentOptions: ICoreWebView2EnvironmentOptions;
    const environment_created_handler: ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler): HRESULT; stdcall;
  TCreateCoreWebView2Environment = function(
    const environment_created_handler: ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler): HRESULT; stdcall;
  TGetCoreWebView2BrowserVersionInfo = function(browserExecutableFolder: LPCWSTR;
    var versionInfo: LPWSTR): HRESULT; stdcall;
  TCompareBrowserVersions = function (version1, version2: LPCWSTR; var result: Integer): HRESULT; stdcall;
  THack = record
    hWebView2: THandle;
    _CreateCoreWebView2EnvironmentWithOptions: TCreateCoreWebView2EnvironmentWithOptions;
    _CreateCoreWebView2Environment: TCreateCoreWebView2Environment;
    _GetCoreWebView2BrowserVersionString: TGetCoreWebView2BrowserVersionInfo;
    _CompareBrowserVersions: TCompareBrowserVersions;
  end;
  PHack = ^THack;
const

//************************************************************************
//
//Hack for install our own Webview2Loader, only tested in DELPHI 11.0update1
//Should work on other versions but DO YOUR OWN TEST!
//
//************************************************************************
{$IFDEF WIN32}
  offset1 = $2;
{$ELSE}
  offset1 = $7;
  offset2 = $C;
{$ENDIF}
var PH : PHack;
procedure install;
var A : NativeInt;
    B : Pinteger;
begin
  {$IFDEF WIN32}
  PH :=PHack(PCardinal(NativeInt(@Winapi.EdgeUtils.CheckWebView2Loaded)+offset1)^);
  {$ELSE}
  B := Pinteger(NativeInt(@Winapi.EdgeUtils.CheckWebView2Loaded)+offset1);
  A := NativeInt(B^);
  PH := PHack(NativeInt(@Winapi.EdgeUtils.CheckWebView2Loaded)+A+offset2);
  {$ENDIF}
  PH.hWebView2 := THandle(-1);
  PH._CreateCoreWebView2EnvironmentWithOptions := @CreateCoreWebView2EnvironmentWithOptions;
  PH._CreateCoreWebView2Environment := @CreateCoreWebView2Environment;
  PH._GetCoreWebView2BrowserVersionString := @GetCoreWebView2BrowserVersionString;
  PH._CompareBrowserVersions := @CompareBrowserVersions
end;

initialization
  install;
finalization
  PH.hWebView2 := 0;
  PH._CreateCoreWebView2EnvironmentWithOptions := nil;
  PH._CreateCoreWebView2Environment := nil;
  PH._GetCoreWebView2BrowserVersionString := nil;
  PH._CompareBrowserVersions := nil;
end.
