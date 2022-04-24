unit uWVFMXBrowser;

{$I webview2.inc}

interface

uses
  System.Classes, System.Types, WinApi.Windows, WinApi.Messages, System.Math,
  FMX.Platform.Win, FMX.Types, FMX.Platform, FMX.Forms, FMX.Controls,
  {$IFDEF DELPHI19_UP}
  FMX.Graphics,
  {$ENDIF}
  uWVBrowserBase;

type
  {$IFNDEF FPC}[ComponentPlatformsAttribute(pidWin32 or pidWin64)]{$ENDIF}
  TWVFMXBrowser = class(TWVBrowserBase)
    protected
      function  GetParentForm : TCustomForm;

    public
      procedure MoveFormTo(const x, y: Integer); override;
      procedure MoveFormBy(const x, y: Integer); override;
      procedure ResizeFormWidthTo(const x : Integer); override;
      procedure ResizeFormHeightTo(const y : Integer); override;
      procedure SetFormLeftTo(const x : Integer); override;
      procedure SetFormTopTo(const y : Integer); override;

    published
      property BrowserExecPath;
      property UserDataFolder;
      property DefaultURL;
      property AdditionalBrowserArguments;
      property Language;
      property TargetCompatibleBrowserVersion;
      property AllowSingleSignOnUsingOSPrimaryAccount;
      property OnInitializationError;
      property OnEnvironmentCompleted;
      property OnControllerCompleted;
      property OnAfterCreated;
      property OnExecuteScriptCompleted;
      property OnCapturePreviewCompleted;
      property OnNavigationStarting;
      property OnNavigationCompleted;
      property OnFrameNavigationStarting;
      property OnFrameNavigationCompleted;
      property OnSourceChanged;
      property OnHistoryChanged;
      property OnContentLoading;
      property OnDocumentTitleChanged;
      property OnNewWindowRequested;
      property OnWebResourceRequested;
      property OnScriptDialogOpening;
      property OnPermissionRequested;
      property OnProcessFailed;
      property OnWebMessageReceived;
      property OnContainsFullScreenElementChanged;
      property OnWindowCloseRequested;
      property OnDevToolsProtocolEventReceived;
      property OnZoomFactorChanged;
      property OnMoveFocusRequested;
      property OnAcceleratorKeyPressed;
      property OnGotFocus;
      property OnLostFocus;
      property OnCursorChanged;
      property OnBrowserProcessExited;
      property OnRasterizationScaleChanged;
      property OnWebResourceResponseReceived;
      property OnDOMContentLoaded;
      property OnWebResourceResponseViewGetContentCompleted;
      property OnGetCookiesCompleted;
      property OnTrySuspendCompleted;
      property OnFrameCreated;
      property OnDownloadStarting;
      property OnClientCertificateRequested;
      property OnPrintToPdfCompleted;
      property OnBytesReceivedChanged;
      property OnEstimatedEndTimeChanged;
      property OnDownloadStateChanged;
      property OnFrameNameChanged;
      property OnFrameDestroyed;
      property OnCompositionControllerCompleted;
      property OnCallDevToolsProtocolMethodCompleted;
      property OnAddScriptToExecuteOnDocumentCreatedCompleted;
      property OnWidget0CompMsg;
      property OnWidget1CompMsg;
      property OnRenderCompMsg;
      property OnD3DWindowCompMsg;
      property OnPrintCompleted;
      property OnRetrieveHTMLCompleted;
      property OnRetrieveTextCompleted;
      property OnRetrieveMHTMLCompleted;
      property OnClearCacheCompleted;
      property OnClearDataForOriginCompleted;
      property OnOfflineCompleted;
      property OnIgnoreCertificateErrorsCompleted;
      property OnRefreshIgnoreCacheCompleted;
      property OnSimulateKeyEventCompleted;
      property OnIsMutedChanged;
      property OnIsDocumentPlayingAudioChanged;
      property OnIsDefaultDownloadDialogOpenChanged;
      property OnProcessInfosChanged;
      property OnFrameNavigationStarting2;
      property OnFrameNavigationCompleted2;
      property OnFrameContentLoading;
      property OnFrameDOMContentLoaded;
      property OnFrameWebMessageReceived;
      property OnBasicAuthenticationRequested;
      property OnContextMenuRequested;
      property OnCustomItemSelected;
      property OnStatusBarTextChanged;
      property OnFramePermissionRequested;
  end;

implementation

uses
  uWVLoader;

function TWVFMXBrowser.GetParentForm : TCustomForm;
var
  TempComp : TComponent;
begin
  Result   := nil;
  TempComp := Owner;

  while (TempComp <> nil) do
    if (TempComp is TCustomForm) then
      begin
        Result := TCustomForm(TempComp);
        exit;
      end
     else
      TempComp := TempComp.owner;
end;

procedure TWVFMXBrowser.MoveFormTo(const x, y: Integer);
var
  TempForm : TCustomForm;
  {$IFDEF DELPHI21_UP}
  TempRect : TRect;
  {$ENDIF}
begin
  TempForm := GetParentForm;

  {$IFDEF DELPHI21_UP}
  if (TempForm <> nil) then
    begin
      TempRect.Left   := min(max(x, max(round(screen.DesktopLeft), 0)), round(screen.DesktopWidth)  - TempForm.Width);
      TempRect.Top    := min(max(y, max(round(screen.DesktopTop),  0)), round(screen.DesktopHeight) - TempForm.Height);
      TempRect.Right  := TempRect.Left + TempForm.Width  - 1;
      TempRect.Bottom := TempRect.Top  + TempForm.Height - 1;

      TempForm.SetBounds(TempRect.Left, TempRect.Top, TempRect.Right - TempRect.Left + 1, TempRect.Bottom - TempRect.Top + 1);
    end;
  {$ELSE}
  TempForm.SetBounds(x, y, TempForm.Width, TempForm.Height);
  {$ENDIF}
end;

procedure TWVFMXBrowser.MoveFormBy(const x, y: Integer);
var
  TempForm : TCustomForm;
  {$IFDEF DELPHI21_UP}
  TempRect : TRect;
  {$ENDIF}
begin
  TempForm := GetParentForm;

  {$IFDEF DELPHI21_UP}
  if (TempForm <> nil) then
    begin
      TempRect.Left   := min(max(TempForm.Left + x, max(round(screen.DesktopLeft), 0)), round(screen.DesktopWidth)  - TempForm.Width);
      TempRect.Top    := min(max(TempForm.Top  + y, max(round(screen.DesktopTop),  0)), round(screen.DesktopHeight) - TempForm.Height);
      TempRect.Right  := TempRect.Left + TempForm.Width  - 1;
      TempRect.Bottom := TempRect.Top  + TempForm.Height - 1;

      TempForm.SetBounds(TempRect.Left, TempRect.Top, TempRect.Right - TempRect.Left + 1, TempRect.Bottom - TempRect.Top + 1);
    end;
  {$ELSE}
  TempForm.SetBounds(TempForm.Left + x, TempForm.Top + y, TempForm.Width, TempForm.Height);
  {$ENDIF}
end;

procedure TWVFMXBrowser.ResizeFormWidthTo(const x : Integer);
var
  TempForm : TCustomForm;
  TempX, TempDeltaX : integer;
begin
  TempForm := GetParentForm;

  if (TempForm <> nil) then
    begin
      TempX          := max(x, 100);
      TempDeltaX     := TempForm.Width  - TempForm.ClientWidth;
      TempForm.Width := TempX + TempDeltaX;
    end;
end;

procedure TWVFMXBrowser.ResizeFormHeightTo(const y : Integer);
var
  TempForm : TCustomForm;
  TempY, TempDeltaY : integer;
begin
  TempForm := GetParentForm;

  if (TempForm <> nil) then
    begin
      TempY           := max(y, 100);
      TempDeltaY      := TempForm.Height - TempForm.ClientHeight;
      TempForm.Height := TempY + TempDeltaY;
    end;
end;

procedure TWVFMXBrowser.SetFormLeftTo(const x : Integer);
var
  TempForm : TCustomForm;
begin
  TempForm := GetParentForm;

  if (TempForm <> nil) then
    {$IFDEF DELPHI21_UP}
    TempForm.Left := min(max(x, max(round(screen.DesktopLeft), 0)), round(screen.DesktopWidth) - TempForm.Width);
    {$ELSE}
    TempForm.Left := x;
    {$ENDIF}
end;

procedure TWVFMXBrowser.SetFormTopTo(const y : Integer);
var
  TempForm : TCustomForm;
begin
  TempForm := GetParentForm;

  if (TempForm <> nil) then
    {$IFDEF DELPHI21_UP}
    TempForm.Top := min(max(y, max(round(screen.DesktopTop), 0)), round(screen.DesktopHeight) - TempForm.Height);
    {$ELSE}
    TempForm.Top := y;
    {$ENDIF}
end;

end.
