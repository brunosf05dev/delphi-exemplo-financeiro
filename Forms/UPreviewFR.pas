unit UPreviewFR;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, frxClass, frxPreview;

type
  TFPreviewFR = class(TForm)
    frxPreview: TfrxPreview;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FPreviewFR: TFPreviewFR;

implementation

{$R *.dfm}

end.
