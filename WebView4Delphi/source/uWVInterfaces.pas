unit uWVInterfaces;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  {$IFDEF FPC}
  ActiveX,
  {$ELSE}
  Winapi.ActiveX,
  {$ENDIF}
  uWVTypeLibrary, uWVTypes;

type
  IWVLoaderEvents = Interface
    ['{5B91E1BB-CA98-476E-A2F0-10BDED27A916}']

    // ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
    function EnvironmentCompletedHandler_Invoke(errorCode: HResult; const createdEnvironment: ICoreWebView2Environment): HResult;

    // ICoreWebView2NewBrowserVersionAvailableEventHandler
    function NewBrowserVersionAvailableEventHandler_Invoke(const sender: ICoreWebView2Environment; const args: IUnknown): HResult;

    // ICoreWebView2BrowserProcessExitedEventHandler
    function BrowserProcessExitedEventHandler_Invoke(const sender: ICoreWebView2Environment; const args: ICoreWebView2BrowserProcessExitedEventArgs): HResult;

    // ICoreWebView2ProcessInfosChangedEventHandler
    function ProcessInfosChangedEventHandler_Invoke(const sender: ICoreWebView2Environment; const args: IUnknown): HResult;
  end;

  IWVBrowserEvents = Interface
    ['{4E06D91F-1213-46C1-ABB8-D41D8CC19E81}']

    // ICoreWebView2CreateCoreWebView2EnvironmentCompletedHandler
    function EnvironmentCompletedHandler_Invoke(errorCode: HResult; const createdEnvironment: ICoreWebView2Environment): HResult;

    // ICoreWebView2CreateCoreWebView2ControllerCompletedHandler
    function ControllerCompletedHandler_Invoke(errorCode: HResult; const createdController: ICoreWebView2Controller): HResult;

    // ICoreWebView2ExecuteScriptCompletedHandler
    function ExecuteScriptCompletedHandler_Invoke(errorCode: HResult; resultObjectAsJson: PWideChar; aExecutionID : integer): HResult;

    // ICoreWebView2CapturePreviewCompletedHandler
    function CapturePreviewCompletedHandler_Invoke(errorCode: HResult): HResult;

    // ICoreWebView2NavigationStartingEventHandler
    function NavigationStartingEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2NavigationStartingEventArgs): HResult;

    // ICoreWebView2NavigationCompletedEventHandler
    function NavigationCompletedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2NavigationCompletedEventArgs): HResult;

    // ICoreWebView2SourceChangedEventHandler
    function SourceChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2SourceChangedEventArgs): HResult;

    // ICoreWebView2HistoryChangedEventHandler
    function HistoryChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2ContentLoadingEventHandler
    function ContentLoadingEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2ContentLoadingEventArgs): HResult;

    // ICoreWebView2DocumentTitleChangedEventHandler
    function DocumentTitleChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2NewWindowRequestedEventHandler
    function NewWindowRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2NewWindowRequestedEventArgs): HResult;

    // ICoreWebView2NavigationStartingEventHandler (Frame navigation)
    function FrameNavigationStartingEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2NavigationStartingEventArgs): HResult;

    // ICoreWebView2NavigationCompletedEventArgs (Frame navigation)
    function FrameNavigationCompletedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2NavigationCompletedEventArgs): HResult;

    // ICoreWebView2WebResourceRequestedEventHandler
    function WebResourceRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2WebResourceRequestedEventArgs): HResult;

    // ICoreWebView2ScriptDialogOpeningEventHandler
    function ScriptDialogOpeningEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2ScriptDialogOpeningEventArgs): HResult;

    // ICoreWebView2PermissionRequestedEventHandler
    function PermissionRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2PermissionRequestedEventArgs): HResult;

    // ICoreWebView2ProcessFailedEventHandler
    function ProcessFailedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2ProcessFailedEventArgs): HResult;

    // ICoreWebView2WebMessageReceivedEventHandler
    function WebMessageReceivedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2WebMessageReceivedEventArgs): HResult;

    // ICoreWebView2ContainsFullScreenElementChangedEventHandler
    function ContainsFullScreenElementChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2WindowCloseRequestedEventHandler
    function WindowCloseRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2ZoomFactorChangedEventHandler
    function ZoomFactorChangedEventHandler_Invoke(const sender: ICoreWebView2Controller; const args: IUnknown): HResult;

    // ICoreWebView2MoveFocusRequestedEventHandler
    function MoveFocusRequestedEventHandler_Invoke(const sender: ICoreWebView2Controller; const args: ICoreWebView2MoveFocusRequestedEventArgs): HResult;

    // ICoreWebView2AcceleratorKeyPressedEventHandler
    function AcceleratorKeyPressedEventHandler_Invoke(const sender: ICoreWebView2Controller; const args: ICoreWebView2AcceleratorKeyPressedEventArgs): HResult;

    // ICoreWebView2FocusChangedEventHandler
    function GotFocusEventHandler_Invoke(const sender: ICoreWebView2Controller; const args: IUnknown): HResult;

    // ICoreWebView2FocusChangedEventHandler
    function LostFocusEventHandler_Invoke(const sender: ICoreWebView2Controller; const args: IUnknown): HResult;

    // ICoreWebView2DevToolsProtocolEventReceivedEventHandler
    function DevToolsProtocolEventReceivedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2DevToolsProtocolEventReceivedEventArgs; const aEventName : wvstring; aEventID : integer): HResult;

    // ICoreWebView2CreateCoreWebView2CompositionControllerCompletedHandler
    function CreateCoreWebView2CompositionControllerCompletedHandler_Invoke(errorCode: HResult; const webView: ICoreWebView2CompositionController): HResult;

    // ICoreWebView2CursorChangedEventHandler
    function CursorChangedEventHandler_Invoke(const sender: ICoreWebView2CompositionController; const args: IUnknown): HResult;

    // ICoreWebView2BrowserProcessExitedEventHandler
    function BrowserProcessExitedEventHandler_Invoke(const sender: ICoreWebView2Environment; const args: ICoreWebView2BrowserProcessExitedEventArgs): HResult;

    // ICoreWebView2RasterizationScaleChangedEventHandler
    function RasterizationScaleChangedEventHandler_Invoke(const sender: ICoreWebView2Controller; const args: IUnknown): HResult;

    // ICoreWebView2WebResourceResponseReceivedEventHandler
    function WebResourceResponseReceivedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2WebResourceResponseReceivedEventArgs): HResult;

    // ICoreWebView2DOMContentLoadedEventHandler
    function DOMContentLoadedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2DOMContentLoadedEventArgs): HResult;

    // ICoreWebView2WebResourceResponseViewGetContentCompletedHandler
    function WebResourceResponseViewGetContentCompletedHandler_Invoke(errorCode: HResult; const Content: IStream; aResourceID : integer): HResult;

    // ICoreWebView2GetCookiesCompletedHandler
    function GetCookiesCompletedHandler_Invoke(aResult : HResult; const aCookieList : ICoreWebView2CookieList): HResult;

    // ICoreWebView2TrySuspendCompletedHandler
    function TrySuspendCompletedHandler_Invoke(errorCode: HResult; isSuccessful: Integer): HResult;

    // ICoreWebView2FrameCreatedEventHandler
    function FrameCreatedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2FrameCreatedEventArgs): HResult;

    // ICoreWebView2DownloadStartingEventHandler
    function DownloadStartingEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2DownloadStartingEventArgs): HResult;

    // ICoreWebView2ClientCertificateRequestedEventHandler
    function ClientCertificateRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2ClientCertificateRequestedEventArgs): HResult;

    // ICoreWebView2PrintToPdfCompletedHandler
    function PrintToPdfCompletedHandler_Invoke(errorCode: HResult; isSuccessful: Integer): HResult;

    // ICoreWebView2BytesReceivedChangedEventHandler
    function BytesReceivedChangedEventHandler_Invoke(const sender: ICoreWebView2DownloadOperation; const args: IUnknown; aDownloadID : integer): HResult;

    // ICoreWebView2EstimatedEndTimeChangedEventHandler
    function EstimatedEndTimeChangedEventHandler_Invoke(const sender: ICoreWebView2DownloadOperation; const args: IUnknown; aDownloadID : integer): HResult;

    // ICoreWebView2StateChangedEventHandler
    function StateChangedEventHandler_Invoke(const sender: ICoreWebView2DownloadOperation; const args: IUnknown; aDownloadID : integer): HResult;

    // ICoreWebView2FrameNameChangedEventHandler
    function FrameNameChangedEventHandler_Invoke(const sender: ICoreWebView2Frame; const args: IUnknown; aFrameID : integer): HResult;

    // ICoreWebView2FrameDestroyedEventHandler
    function FrameDestroyedEventHandler_Invoke(const sender: ICoreWebView2Frame; const args: IUnknown; aFrameID : integer): HResult;

    // ICoreWebView2CallDevToolsProtocolMethodCompletedHandler
    function CallDevToolsProtocolMethodCompletedHandler_Invoke(errorCode: HResult; returnObjectAsJson: PWideChar; aExecutionID : integer): HResult;

    // ICoreWebView2AddScriptToExecuteOnDocumentCreatedCompletedHandler
    function AddScriptToExecuteOnDocumentCreatedCompletedHandler_Invoke(errorCode: HResult; id: PWideChar): HResult;

    // ICoreWebView2IsMutedChangedEventHandler
    function IsMutedChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2IsDocumentPlayingAudioChangedEventHandler
    function IsDocumentPlayingAudioChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2IsDefaultDownloadDialogOpenChangedEventHandler
    function IsDefaultDownloadDialogOpenChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2ProcessInfosChangedEventHandler
    function ProcessInfosChangedEventHandler_Invoke(const sender: ICoreWebView2Environment; const args: IUnknown): HResult;

    // ICoreWebView2NavigationStartingEventHandler (Frame navigation)
    function FrameNavigationStartingEventHandler2_Invoke(const sender: ICoreWebView2Frame; const args: ICoreWebView2NavigationStartingEventArgs; aFrameID: integer): HResult;

    // ICoreWebView2NavigationCompletedEventArgs (Frame navigation)
    function FrameNavigationCompletedEventHandler2_Invoke(const sender: ICoreWebView2Frame; const args: ICoreWebView2NavigationCompletedEventArgs; aFrameID: integer): HResult;

    // ICoreWebView2FrameContentLoadingEventHandler
    function FrameContentLoadingEventHandler_Invoke(const sender: ICoreWebView2Frame; const args: ICoreWebView2ContentLoadingEventArgs; aFrameID: integer): HResult;

    // ICoreWebView2FrameDOMContentLoadedEventHandler
    function FrameDOMContentLoadedEventHandler_Invoke(const sender: ICoreWebView2Frame; const args: ICoreWebView2DOMContentLoadedEventArgs; aFrameID: integer): HResult;

    // ICoreWebView2FrameWebMessageReceivedEventHandler
    function FrameWebMessageReceivedEventHandler_Invoke(const sender: ICoreWebView2Frame; const args: ICoreWebView2WebMessageReceivedEventArgs; aFrameID: integer): HResult;

    // ICoreWebView2BasicAuthenticationRequestedEventHandler
    function BasicAuthenticationRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2BasicAuthenticationRequestedEventArgs): HResult;

    // ICoreWebView2ContextMenuRequestedEventHandler
    function ContextMenuRequestedEventHandler_Invoke(const sender: ICoreWebView2; const args: ICoreWebView2ContextMenuRequestedEventArgs): HResult;

    // ICoreWebView2CustomItemSelectedEventHandler
    function CustomItemSelectedEventHandler_Invoke(const sender: ICoreWebView2ContextMenuItem; const args: IUnknown): HResult;

    // ICoreWebView2StatusBarTextChangedEventHandler
    function StatusBarTextChangedEventHandler_Invoke(const sender: ICoreWebView2; const args: IUnknown): HResult;

    // ICoreWebView2FramePermissionRequestedEventHandler
    function FramePermissionRequestedEventHandler_Invoke(const sender: ICoreWebView2Frame; const args: ICoreWebView2PermissionRequestedEventArgs2; aFrameID: integer): HResult;
  end;

implementation

end.
