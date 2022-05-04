unit uWVCoreWebView2CompositionController;

{$IFDEF FPC}{$MODE Delphi}{$ENDIF}

interface

uses
  {$IFDEF FPC}
  Classes, Windows, ActiveX,
  {$ELSE}
  System.Classes, System.Types, Winapi.Windows, Winapi.ActiveX,
  {$ENDIF}
  uWVTypeLibrary, uWVTypes;

type
  TCoreWebView2CompositionController = class
    protected
      FBaseIntf           : ICoreWebView2CompositionController;
      FBaseIntf2          : ICoreWebView2CompositionController2;
      FCursorChangedToken : EventRegistrationToken;

      function  GetInitialized : boolean;
      function  GetRootVisualTarget : IUnknown;
      function  GetCursor : HCURSOR;
      function  GetSystemCursorID : cardinal;
      function  GetAutomationProvider : IUnknown;

      procedure SetRootVisualTarget(const aValue : IUnknown);

      procedure InitializeFields;
      procedure InitializeTokens;
      procedure RemoveAllEvents;

      function  AddCursorChangedEvent(const aBrowserComponent : TComponent) : boolean;

    public
      constructor Create(const aBaseIntf : ICoreWebView2CompositionController); reintroduce;
      destructor  Destroy; override;
      function    AddAllBrowserEvents(const aBrowserComponent : TComponent) : boolean;
      function    SendMouseInput(aEventKind : TWVMouseEventKind; aVirtualKeys : TWVMouseEventVirtualKeys; aMouseData : cardinal; aPoint : TPoint) : boolean;
      function    SendPointerInput(aEventKind : TWVPointerEventKind; const aPointerInfo : ICoreWebView2PointerInfo) : boolean;

      property Initialized        : boolean                              read GetInitialized;
      property BaseIntf           : ICoreWebView2CompositionController   read FBaseIntf;
      property RootVisualTarget   : IUnknown                             read GetRootVisualTarget     write SetRootVisualTarget;
      property Cursor             : HCURSOR                              read GetCursor;
      property SystemCursorID     : cardinal                             read GetSystemCursorID;
      property AutomationProvider : IUnknown                             read GetAutomationProvider;
  end;

implementation

uses
  uWVBrowserBase, uWVCoreWebView2Delegates;

constructor TCoreWebView2CompositionController.Create(const aBaseIntf: ICoreWebView2CompositionController);
begin
  inherited Create;

  InitializeFields;

  FBaseIntf := aBaseIntf;

  if Initialized then
    FBaseIntf.QueryInterface(IID_ICoreWebView2CompositionController2, FBaseIntf2);
end;

destructor TCoreWebView2CompositionController.Destroy;
begin
  try
    RemoveAllEvents;
    InitializeFields;
  finally
    inherited Destroy;
  end;
end;

procedure TCoreWebView2CompositionController.InitializeFields;
begin
  FBaseIntf  := nil;
  FBaseIntf2 := nil;

  InitializeTokens;
end;

procedure TCoreWebView2CompositionController.InitializeTokens;
begin
  FCursorChangedToken.value := 0;
end;

function TCoreWebView2CompositionController.GetInitialized : boolean;
begin
  Result := assigned(FBaseIntf);
end;

function TCoreWebView2CompositionController.GetRootVisualTarget : IUnknown;
var
  TempResult : IUnknown;
begin
  Result     := nil;
  TempResult := nil;

  if Initialized and
     succeeded(FBaseIntf.Get_RootVisualTarget(TempResult)) and
     assigned(TempResult) then
    Result := TempResult;
end;

function TCoreWebView2CompositionController.GetCursor : HCURSOR;
var
  TempResult : HCURSOR;
begin
  if Initialized and
     succeeded(FBaseIntf.Get_Cursor(TempResult)) then
    Result := TempResult
   else
    Result := 0;
end;

function TCoreWebView2CompositionController.GetSystemCursorID : cardinal;
var
  TempResult : SYSUINT;
begin
  if Initialized and
     succeeded(FBaseIntf.Get_SystemCursorId(TempResult)) then
    Result := TempResult
   else
    Result := 0;
end;

function TCoreWebView2CompositionController.GetAutomationProvider : IUnknown;
var
  TempResult : IUnknown;
begin
  Result     := nil;
  TempResult := nil;

  if assigned(FBaseIntf2) and
     succeeded(FBaseIntf2.Get_AutomationProvider(TempResult)) and
     assigned(TempResult) then
    Result := TempResult;
end;

procedure TCoreWebView2CompositionController.SetRootVisualTarget(const aValue : IUnknown);
begin
  if Initialized then
    FBaseIntf.Set_RootVisualTarget(aValue);
end;

procedure TCoreWebView2CompositionController.RemoveAllEvents;
begin
  if Initialized then
    begin
      if (FCursorChangedToken.value <> 0) then
        FBaseIntf.remove_CursorChanged(FCursorChangedToken);

      InitializeTokens;
    end;
end;

function TCoreWebView2CompositionController.AddAllBrowserEvents(const aBrowserComponent : TComponent) : boolean;
begin
  Result := AddCursorChangedEvent(aBrowserComponent);
end;

function TCoreWebView2CompositionController.AddCursorChangedEvent(const aBrowserComponent : TComponent) : boolean;
var
  TempHandler : ICoreWebView2CursorChangedEventHandler;
begin
  Result := False;

  if Initialized and (FCursorChangedToken.value = 0) then
    try
      TempHandler := TCoreWebView2CursorChangedEventHandler.Create(TWVBrowserBase(aBrowserComponent));
      Result      := succeeded(FBaseIntf.add_CursorChanged(TempHandler, FCursorChangedToken));
    finally
      TempHandler := nil;
    end;
end;

function TCoreWebView2CompositionController.SendMouseInput(aEventKind   : TWVMouseEventKind;
                                                           aVirtualKeys : TWVMouseEventVirtualKeys;
                                                           aMouseData   : cardinal;
                                                           aPoint       : TPoint) : boolean;
begin
  Result := Initialized and
            succeeded(FBaseIntf.SendMouseInput(aEventKind, aVirtualKeys, aMouseData, tagPOINT(aPoint)));
end;

function TCoreWebView2CompositionController.SendPointerInput(      aEventKind   : TWVPointerEventKind;
                                                             const aPointerInfo : ICoreWebView2PointerInfo) : boolean;
begin
  Result := Initialized and
            succeeded(FBaseIntf.SendPointerInput(aEventKind, aPointerInfo));
end;

end.
