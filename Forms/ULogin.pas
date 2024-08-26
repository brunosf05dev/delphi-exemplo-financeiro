unit ULogin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ExtCtrls;

type
  TFLogin = class(TForm)
    PMain: TPanel;
    BackgroundImage: TImage;
    MainIcon: TImage;
    BtnClose: TBitBtn;
    BtnLogin: TBitBtn;
    EdtPassword: TEdit;
    EdtLogin: TEdit;
    PasswordIcon: TImage;
    UserIcon: TImage;
    BtnSettings: TBitBtn;
    PSettings: TPanel;
    CONFIGURA��ES: TPanel;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    EdtDatabasePath: TEdit;
    EdtPort: TEdit;
    EdtDatabaseUser: TEdit;
    EdtDatabasePassword: TEdit;
    Label2: TLabel;
    BtnSaveSettings: TBitBtn;
    BtnCancelSettings: TBitBtn;
    BtnArquivo: TBitBtn;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnLoginClick(Sender: TObject);
    procedure BtnSettingsClick(Sender: TObject);
    procedure BtnCancelSettingsClick(Sender: TObject);
    procedure BtnSaveSettingsClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure BtnArquivoClick(Sender: TObject);
  private
    procedure ConnectDatabase;
    procedure SaveConfig;
    procedure ShowSettings;

    { Private declarations }
  public
    { Public declarations }
  end;

var
  FLogin: TFLogin;
  ArqIni: TIniFile;

implementation

uses
  ProcMethods, UDM, UMain;

{$R *.dfm}

procedure TFLogin.BtnArquivoClick(Sender: TObject);
begin
  DM.OpenDialog.execute;
  EdtDatabasePath.Text:= DM.OpenDialog.FileName;
end;

procedure TFLogin.BtnCancelSettingsClick(Sender: TObject);
begin
  PSettings.Visible := False;
  PMain.Enabled := True;
end;

procedure TFLogin.BtnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFLogin.BtnLoginClick(Sender: TObject);
var
  temp: string;
begin
  ConnectDatabase;

  temp := 'SELECT U.PK_USER, U.USER_NAME FROM TB_USER U '
    + ' WHERE Upper(U.USER_NAME) = upper(' + QuotedStr(EdtLogin.Text)  + ')'
    + ' AND U.USER_PASSWORD = ' + QuotedStr(PM.GetMD5(EdtPassword.Text)); //QuotedStr(PM.GetMD5(EdtPassword.Text));
  PM.RunSQL(temp, DM.SQLGeneral);
  if DM.SQLGeneral.FieldByName('PK_USER').AsString = '' then
  begin
    Application.MessageBox(PChar('Usu�rio "' + EdtLogin.Text + '" n�o esta cadastrado ou senha inv�lida. Tente novamente.'), 'Login ou senha inv�lidos', MB_ICONEXCLAMATION);
    if EdtLogin.CanFocus then
      EdtLogin.SetFocus;
    EdtPassword.Text:= '';
    Exit;
  end;

  DM.PKUser := DM.SQLGeneral.FieldByName('PK_USER').AsString;

  //  FLogin.Hide;

  if FMain = nil then
    Application.CreateForm(TFMain, FMain);
  FMain.ShowModal;

end;

procedure TFLogin.BtnSaveSettingsClick(Sender: TObject);
begin
  SaveConfig;
  BtnCancelSettingsClick(nil);
end;

procedure TFLogin.BtnSettingsClick(Sender: TObject);
begin
  PSettings.Visible := True;
  PM.CentralizePanel(Self, PSettings);
  ShowSettings;
  PMain.Enabled := False;
end;

procedure TFLogin.ConnectDatabase;
var
  temp: string;
begin
  //Testa Conex�o
  try
    temp:= ExtractFilePath(ParamStr(0)) + 'Config.ini';
    ArqIni := TIniFile.Create(temp);

    DM.FDConnection.Params.Values['Database'] := ArqIni.ReadString('Dados', 'DatabasePath', '');
    DM.FDConnection.Params.Values['User_name'] := ArqIni.ReadString('Dados', 'DatabaseUser', '');
    DM.FDConnection.Params.Values['Password'] := ArqIni.ReadString('Dados', 'DatabasePassword', '');
    DM.FDConnection.Params.Values['Port'] := ArqIni.ReadString('Dados', 'Port', '');
    DM.FDConnection.Params.Values['Server'] := '127.0.0.1';
    DM.FDConnection.Connected := true;
  except
    showmessage('Banco n�o configurado corretamente! Verifique os par�metros de configura��o');
    exit;
  end;
end;

procedure TFLogin.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    Key:= #0;
    if PSettings.Visible then
      BtnCancelSettingsClick(nil)
  end;

  if Key = #13 then
  begin
    Key:= #0;

    if PSettings.Visible then
    begin
      if ((EdtDatabasePath.Text <> '') and (EdtPort.Text <> '') and (EdtDatabaseUser.Text <> '') and (EdtDatabasePassword.Text <> '')) then
        BtnSaveSettingsClick(nil)
      else
         Perform(Wm_NextDlgCtl,0,0);
    end
    else if ((EdtLogin.Text <> '') and (EdtPassword.Text <> '')) then
    begin
      BtnLoginClick(nil);
    end
    else
      Perform(Wm_NextDlgCtl,0,0);
  end;
end;

procedure TFLogin.SaveConfig;
var
  ArqIni: TIniFile;
  temp: string;
begin
  ArqIni := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  try
    temp:= EdtDatabasePath.Text;
    ArqIni.WriteString('Dados', 'DatabasePath', temp);
    temp:= EdtPort.Text;
    ArqIni.WriteString('Dados', 'Port', temp);
    temp:= EdtDatabaseUser.Text;
    ArqIni.WriteString('Dados', 'DatabaseUser', temp);
    temp:= EdtDatabasePassword.Text;
    ArqIni.WriteString('Dados', 'DatabasePassword', temp);


    showmessage('Configura��es salvas com sucesso');
    ConnectDatabase;
  finally
    ArqIni.Free;
  end;

end;


procedure TFLogin.ShowSettings;
var
  temp : string;
begin
  temp:= ExtractFilePath(ParamStr(0)) + 'Config.ini';
  ArqIni := TIniFile.Create(temp);

  EdtDatabasePath.Text := ArqIni.ReadString('Dados', 'DatabasePath', '');
  EdtDatabaseUser.Text := ArqIni.ReadString('Dados', 'DatabaseUser', '');
  EdtDatabasePassword.Text := ArqIni.ReadString('Dados', 'DatabasePassword', '');
  EdtPort.Text := ArqIni.ReadString('Dados', 'Port', '');

  if EdtDatabaseUser.Text = '' then
    EdtDatabaseUser.Text := 'SYSDBA';
  if EdtPort.Text = '' then
    EdtPort.Text := '3050';

end;

end.
