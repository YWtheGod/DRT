object Main: TMain
  Left = 0
  Top = 0
  Caption = 'Main'
  ClientHeight = 582
  ClientWidth = 849
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  DesignSize = (
    849
    582)
  TextHeight = 21
  object M: TMemo
    Left = 8
    Top = 8
    Width = 641
    Height = 566
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Button1: TButton
    Left = 648
    Top = 32
    Width = 177
    Height = 33
    Anchors = [akTop, akRight]
    Caption = 'Object AutoRef Demo'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 648
    Top = 80
    Width = 177
    Height = 33
    Anchors = [akTop, akRight]
    Caption = 'Pointer AutoRef Demo'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 648
    Top = 128
    Width = 177
    Height = 33
    Anchors = [akTop, akRight]
    Caption = 'Task Syncer Demo'
    TabOrder = 3
    OnClick = Button3Click
  end
end
