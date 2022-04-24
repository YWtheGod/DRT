unit testwv2ldmain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Edge, Vcl.ExtCtrls, Vcl.StdCtrls,DRT.VCL.WV2Loader;

type
  TMain = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    W: TEdgeBrowser;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

{$R *.dfm}

procedure TMain.Button1Click(Sender: TObject);
begin
  W.Navigate('https://www.baidu.com');
  W.WebViewCreated;
end;

procedure TMain.Button2Click(Sender: TObject);
begin
  (W.DefaultInterface as ICoreWebView2).Navigate('https://www.163.com');
end;

end.
