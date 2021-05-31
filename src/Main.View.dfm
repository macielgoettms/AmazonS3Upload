object MainView: TMainView
  Left = 0
  Top = 0
  Caption = 'Amazon S3 Upload'
  ClientHeight = 158
  ClientWidth = 406
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnSelectFile: TButton
    Left = 140
    Top = 75
    Width = 129
    Height = 41
    Caption = 'Select file to upload'
    TabOrder = 0
    OnClick = btnSelectFileClick
  end
  object cbOnlyImages: TCheckBox
    Left = 125
    Top = 31
    Width = 180
    Height = 17
    Caption = 'Only images (png, jpeg, bmp)'
    TabOrder = 1
  end
  object AwsConnection: TAmazonConnectionInfo
    TableEndpoint = 'sdb.amazonaws.com'
    QueueEndpoint = 'queue.amazonaws.com'
    StorageEndpoint = 's3.amazonaws.com'
    Left = 32
    Top = 16
  end
end
