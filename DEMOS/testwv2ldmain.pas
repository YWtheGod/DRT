unit testwv2ldmain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Edge, Vcl.ExtCtrls, Vcl.StdCtrls,DRT.WIN.WebView2Loader;

type
  TMain = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    W: TEdgeBrowser;
    procedure Button1Click(Sender: TObject);
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
end;

end.
