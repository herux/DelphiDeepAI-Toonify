unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ExtCtrls, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, REST.Types,
  REST.Client, FMX.MultiResBitmap, System.JSON, IpPeerClient, FMX.Edit;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Label2: TLabel;
    Label1: TLabel;
    btnToonify: TButton;
    OpenDialog1: TOpenDialog;
    lblPlaceHolder: TLabel;
    Line1: TLine;
    edtApiKey: TEdit;
    procedure btnToonifyClick(Sender: TObject);
    procedure Image1DblClick(Sender: TObject);
  private
    FOriginalFilename: string;
    procedure Toonify;
  public
    property OriginalFilename: string read FOriginalFilename write FOriginalFilename;
  end;

const
  TOONIFY_API_URL = 'https://api.deepai.org/api/toonify';

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.btnToonifyClick(Sender: TObject);
begin
  if edtApiKey.Text <> '' then
    Toonify
  else
    ShowMessage('Set your Api Key!.');
end;

procedure TForm2.Image1DblClick(Sender: TObject);
var
  LBitmapItem: TFixedBitmapItem;
begin
  if OpenDialog1.Execute then begin
    LBitmapItem := Image1.MultiResBitmap.Add;
    LBitmapItem.Bitmap.LoadFromFile(OpenDialog1.FileName);
    lblPlaceHolder.Visible := False;
    OriginalFilename := OpenDialog1.FileName;
  end;
end;

procedure TForm2.Toonify;
var
  LRestClient: TRESTClient;
  LRestRequest: TRESTRequest;
  LImageDownload: TDownloadURL;
  LResponse: TJSONObject;
  LMemStream: TMemoryStream;
  LBitmapItem: TFixedBitmapItem;
begin
  LRestClient := TRESTClient.Create(TOONIFY_API_URL);
  LRestRequest:= TRESTRequest.Create(nil);
  try
    LRestRequest.Method := rmPOST;
    LRestRequest.AddParameter('api-key', edtApiKey.Text, TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
    LRestRequest.AddFile('image', OriginalFilename);
    LRestRequest.Client := LRestClient;
    LRestRequest.Execute;
    LResponse := LRestRequest.Response.JSONValue as TJSONObject;
    LImageDownload := TDownloadURL.Create;
    LMemStream := TMemoryStream.Create();
    try
      LImageDownload.DownloadRawBytes(LResponse.GetValue('output_url').Value, LMemStream);  
      LBitmapItem := Image2.MultiResBitmap.Add;
      LBitmapItem.Bitmap.LoadFromStream(LMemStream);
    except on E: Exception do
    end;
    LImageDownload.Free;
    LMemStream.Free;
  finally
    LRestRequest.Free;
    LRestClient.Free;
  end;

end;

end.
