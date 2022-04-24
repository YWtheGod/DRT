object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 482
  ClientWidth = 716
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 716
    Height = 49
    Align = alTop
    TabOrder = 0
    object Button1: TButton
      Left = 8
      Top = 9
      Width = 73
      Height = 33
      Caption = 'Test!'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 432
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Button2'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object W: TEdgeBrowser
    Left = 0
    Top = 49
    Width = 716
    Height = 433
    Align = alClient
    TabOrder = 1
  end
end
