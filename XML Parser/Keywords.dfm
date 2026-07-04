object Form2: TForm2
  Left = 648
  Top = 122
  BorderStyle = bsDialog
  Caption = 'Keywords'
  ClientHeight = 411
  ClientWidth = 253
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 153
    Height = 26
    Caption = 'Default color for commands that '#13#10'are not highlighted.'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 56
    Width = 233
    Height = 65
    Caption = ' None Highlight Data Color '
    TabOrder = 0
    object Label1: TLabel
      Left = 36
      Top = 32
      Width = 30
      Height = 13
      Caption = 'Color :'
    end
    object ComboBox1: TComboBox
      Left = 72
      Top = 29
      Width = 145
      Height = 22
      Style = csOwnerDrawVariable
      DropDownCount = 25
      ItemHeight = 16
      TabOrder = 0
      TabStop = False
      OnDrawItem = ComboBox1DrawItem
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 128
    Width = 233
    Height = 225
    TabStop = False
    BorderStyle = bsNone
    Ctl3D = True
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 1
    OnChange = Memo1Change
  end
  object Button1: TButton
    Left = 8
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 2
    TabStop = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 88
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    TabStop = False
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 168
    Top = 360
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    TabStop = False
    OnClick = Button3Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 392
    Width = 253
    Height = 19
    Panels = <
      item
        Text = 'Commands :'
        Width = 75
      end
      item
        Width = 50
      end>
  end
end
