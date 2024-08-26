program Financeiro;

uses
  Vcl.Forms,
  UDM in 'UDM.pas' {DM: TDataModule},
  ProcMethods in 'ProcMethods.pas',
  UFinancialTransaction in 'Forms\UFinancialTransaction.pas' {FFinancialTransaction},
  ULogin in 'Forms\ULogin.pas' {FLogin},
  UMain in 'Forms\UMain.pas' {FMain},
  UPerson in 'Forms\UPerson.pas' {FPerson},
  UUser in 'Forms\UUser.pas' {FUser},
  UPreviewFR in 'Forms\UPreviewFR.pas' {FPreviewFR};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFLogin, FLogin);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TFPreviewFR, FPreviewFR);
  Application.Run;
end.
