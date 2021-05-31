unit Main.View;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  Data.Cloud.CloudAPI, Data.Cloud.AmazonAPI, System.JSON, Msys.Util.Archives;

type
  TFileLoaded = record
    id: string;
    fileName: string;
    extension: string;
    content: TStringStream;
  end;

  TMainView = class(TForm)
    btnSelectFile: TButton;
    AwsConnection: TAmazonConnectionInfo;
    cbOnlyImages: TCheckBox;
    procedure btnSelectFileClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure ConfigureAWSConnection;
    function LoadFile(const defaultExtension: string = ''): TFileLoaded;
    function UploadLoadFile(const &file: TFileLoaded; const headers: TStrings): TCloudResponseInfo;
  public
    { Public declarations }
  end;

var
  MainView: TMainView;

implementation

const
  AWS_ENDPOINT = 's3.us-east-2.amazonaws.com';
  S3_BUCKET = 'your_bucket';
  ACCOUNT_KEY = 'your_account_key';
  ACCOUNT_NAME = 'your_account_name';

  {$R *.dfm}

procedure TMainView.ConfigureAWSConnection;
begin
  AwsConnection.StorageEndpoint := AWS_ENDPOINT;
  AwsConnection.AccountKey := ACCOUNT_KEY;
  AwsConnection.AccountName := ACCOUNT_NAME;
end;

procedure TMainView.FormCreate(Sender: TObject);
begin
  ConfigureAWSConnection;
end;

procedure TMainView.btnSelectFileClick(Sender: TObject);
var
  headers: TStrings;
  &file: TFileLoaded;
  response: TCloudResponseInfo;
begin
  headers := TStringList.Create;
  try
    if cbOnlyImages.Checked then
    begin
      &file := LoadFile('Images file |*.JPEG; *.JPG; *.PNG; *.BMP');
      headers.Add('Content-Type=image/' + StringReplace(&file.extension, '.', '', [rfReplaceAll]));
    end
    else
      &file := LoadFile();

    if &file.content.Size > 0 then
    begin
      response := UploadLoadFile(&file, headers);
      try
        Application.MessageBox(PWideChar('Send to Amazon S3, response: ' + response.StatusMessage), 'Amazon S3 Upload')
      finally
        response.Free;
      end;
    end;
  finally
    headers.Free;
    &file.content.Free;
  end;
end;

function TMainView.LoadFile(const defaultExtension: string): TFileLoaded;
var
  dialog: TOpenDialog;
  uid: TGUID;
begin
  dialog := TOpenDialog.Create(nil);
  try
    Result.content := TStringStream.Create;
    dialog.Title := 'Select file to upload';
    dialog.DefaultExt := defaultExtension;
    dialog.Filter := defaultExtension;
    if dialog.Execute then
    begin
      CreateGUID(uid);
      Result.extension := ExtractFileExt(dialog.FileName);
      Result.id := GUIDToString(uid) + Result.extension;
      Result.fileName := dialog.FileName;
      Result.content.LoadFromFile(dialog.FileName);
      Result.content.Seek(0, TSeekOrigin.soBeginning);
      Result.content.Position := 0;
    end;
  finally
    dialog.Free;
  end;
end;

function TMainView.UploadLoadFile(const &file: TFileLoaded; const headers: TStrings): TCloudResponseInfo;
var
  AmazonS3: TAmazonStorageService;
begin
  Result := TCloudResponseInfo.Create;
  AmazonS3 := TAmazonStorageService.Create(AwsConnection);
  try
    Cursor := crHourGlass;
    AmazonS3.UploadObject(S3_BUCKET, &file.id, &file.content.Bytes, false, nil, headers, amzbaPublicRead, Result);
  finally
    Cursor := crDefault;
    AmazonS3.Free;
  end;
end;


end.
