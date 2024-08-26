unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin;

type
  TFMain = class(TForm)
    MainMenu1: TMainMenu;
    Movimentaes1: TMenuItem;
    MIFinancial: TMenuItem;
    Cadastros1: TMenuItem;
    MIPerson: TMenuItem;
    MIUser: TMenuItem;
    N2: TMenuItem;
    MIShutdown: TMenuItem;
    Image1: TImage;
    procedure MIPersonClick(Sender: TObject);
    procedure MIUserClick(Sender: TObject);
    procedure MIShutdownClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MIFinancialClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FMain: TFMain;

implementation

uses
  UPerson, UDM, UUser, UFinancialTransaction;

{$R *.dfm}

procedure TFMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TFMain.MIFinancialClick(Sender: TObject);
begin
  if FFinancialTransaction = nil then
    Application.CreateForm(TFFinancialTransaction, FFinancialTransaction);
  FFinancialTransaction.ShowModal;
end;

procedure TFMain.MIPersonClick(Sender: TObject);
begin
  if FPerson = nil then
    Application.CreateForm(TFPerson, FPerson);
  FPerson.ShowModal;
end;

procedure TFMain.MIShutdownClick(Sender: TObject);
begin
  Close;
end;

procedure TFMain.MIUserClick(Sender: TObject);
begin
  if FUSer = nil then
    Application.CreateForm(TFUSer, FUSer);
  FUSer.ShowModal;
end;

end.
