unit testmfxedgemain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.WebBrowser, FMX.Layouts;

type
  TMain = class(TForm)
    Layout1: TLayout;
    W: TWebBrowser;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation
uses DRT.WIN.WV2Loader;

{$R *.fmx}

procedure TMain.Button1Click(Sender: TObject);
begin
  W.Navigate('https://www.baidu.com');
end;

end.
