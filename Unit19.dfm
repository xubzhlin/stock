object Form19: TForm19
  Left = 0
  Top = 0
  Caption = 'stock'
  ClientHeight = 425
  ClientWidth = 895
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    Left = 0
    Top = 56
    Width = 895
    Height = 259
    Align = alClient
    DataSource = DataSource1
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDrawDataCell = DBGrid1DrawDataCell
    OnDrawColumnCell = DBGrid1DrawColumnCell
    OnTitleClick = DBGrid1TitleClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 895
    Height = 56
    Align = alTop
    Padding.Top = 15
    Padding.Bottom = 15
    TabOrder = 1
    object ckbZDF: TCheckBox
      Left = 1
      Top = 16
      Width = 102
      Height = 24
      Align = alLeft
      Caption = #24403#26085#28072#24133
      TabOrder = 0
    end
    object ckbMain: TCheckBox
      Left = 409
      Top = 16
      Width = 102
      Height = 24
      Align = alLeft
      Caption = #20027#21147#20928#39069
      TabOrder = 1
    end
    object ckbTen: TCheckBox
      Left = 307
      Top = 16
      Width = 102
      Height = 24
      Align = alLeft
      Caption = '10'#26085#21464#21270
      TabOrder = 2
    end
    object ckbFive: TCheckBox
      Left = 205
      Top = 16
      Width = 102
      Height = 24
      Align = alLeft
      Caption = '5'#26085#21464#21270
      TabOrder = 3
    end
    object ckbOne: TCheckBox
      Left = 103
      Top = 16
      Width = 102
      Height = 24
      Align = alLeft
      Caption = '1'#26085#21464#21270
      TabOrder = 4
    end
    object Edit1: TEdit
      Left = 517
      Top = 17
      Width = 148
      Height = 21
      TabOrder = 5
    end
    object DateTimePicker1: TDateTimePicker
      Left = 688
      Top = 17
      Width = 137
      Height = 21
      Date = 43890.000000000000000000
      Time = 0.513023055558733200
      TabOrder = 6
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 315
    Width = 895
    Height = 110
    Align = alBottom
    TabOrder = 2
    object Label1: TLabel
      Left = 688
      Top = 6
      Width = 164
      Height = 13
      Caption = #21271#19978#36164#37329'('#31532#20108#22825#20940#26216#25165#33021#37319#38598')'
    end
    object Label2: TLabel
      Left = 688
      Top = 42
      Width = 140
      Height = 13
      Caption = #20027#21147#36164#37329'('#25910#30424#21518#21363#21487#37319#38598')'
    end
    object Label3: TLabel
      Left = 581
      Top = 7
      Width = 3
      Height = 13
    end
    object Label4: TLabel
      Left = 581
      Top = 42
      Width = 3
      Height = 13
    end
    object Label5: TLabel
      Left = 688
      Top = 75
      Width = 176
      Height = 13
      Caption = #20027#21147#25345#20179'('#25968#25454#28304#27599#23395#24230#26356#26032#19968#27425')'
    end
    object Label6: TLabel
      Left = 581
      Top = 77
      Width = 3
      Height = 13
    end
    object Button1: TButton
      Left = 19
      Top = 3
      Width = 84
      Height = 27
      Caption = #24320#22987#37319#38598
      TabOrder = 0
      OnClick = Button1Click
    end
    object ProgressBar1: TProgressBar
      Left = 144
      Top = 8
      Width = 431
      Height = 17
      TabOrder = 1
    end
    object ProgressBar2: TProgressBar
      Left = 144
      Top = 42
      Width = 431
      Height = 17
      TabOrder = 2
    end
    object Button2: TButton
      Left = 19
      Top = 36
      Width = 84
      Height = 27
      Caption = #24320#22987#37319#38598
      TabOrder = 3
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 19
      Top = 69
      Width = 84
      Height = 27
      Caption = #24320#22987#37319#38598
      TabOrder = 4
      OnClick = Button3Click
    end
    object ProgressBar3: TProgressBar
      Left = 144
      Top = 75
      Width = 431
      Height = 17
      TabOrder = 5
    end
  end
  object FDQuery1: TFDQuery
    Connection = FDConnection1
    Left = 160
    Top = 96
  end
  object FDConnection1: TFDConnection
    Left = 248
    Top = 96
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 352
    Top = 88
  end
  object DataSource1: TDataSource
    DataSet = FDQuery1
    Left = 104
    Top = 112
  end
end
