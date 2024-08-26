unit UPerson;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.Mask;

type
  TFPerson = class(TForm)
    PButtons: TPanel;
    BtnDelete: TBitBtn;
    BtnClose: TBitBtn;
    PData: TPanel;
    PTitle: TPanel;
    StatusBar1: TStatusBar;
    BtnEdit: TBitBtn;
    BtnNew: TBitBtn;
    ImageLoc: TImage;
    GData: TDBGrid;
    MemoMensagem: TMemo;
    CBFilter: TComboBox;
    BtnSearch: TBitBtn;
    Panel1: TPanel;
    EdtFilter: TEdit;
    PPerson: TPanel;
    Label1: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    PSubTitle: TPanel;
    EdtPKPerson: TEdit;
    EdtPersonName: TEdit;
    EdtPersonBalance: TEdit;
    BtnSavePerson: TBitBtn;
    BtnCancelPerson: TBitBtn;
    Label2: TLabel;
    BtnReport: TBitBtn;
    procedure BtnCloseClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    procedure EdtFilterKeyPress(Sender: TObject; var Key: Char);
    procedure BtnNewClick(Sender: TObject);
    procedure BtnSavePersonClick(Sender: TObject);
    procedure EdtPersonBalanceKeyPress(Sender: TObject; var Key: Char);
    procedure BtnCancelPersonClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure BtnReportClick(Sender: TObject);
    procedure GDataDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
  private
    PersonControl : Integer;

    { Private declarations }
    procedure ClearFields;
    procedure ShowPerson(ControlIndex: integer);
    procedure SavePerson(ControlIndex: integer);
    procedure ButtonControl;
    function VerifyFields: Boolean;
  public

    { Public declarations }

  end;

var
  FPerson: TFPerson;

implementation

{$R *.dfm}

uses
  UDM, UPreviewFR;

procedure TFPerson.BtnCancelPersonClick(Sender: TObject);
begin
  PPerson.Visible := False;
  PData.Enabled := True;
  PButtons.Enabled := True;
end;

procedure TFPerson.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFPerson.BtnDeleteClick(Sender: TObject);
var
  temp: string;
begin
  if Application.MessageBox('Deseja confirmar a exclus�o do registro?',
    'Exclus�o', MB_YESNO + MB_ICONWARNING) = IDYES then
  begin
    try
      Temp := '';

      if DM.FDTransactionData.TransactionIntf.Active then
        DM.FDTransactionData.Rollback;
      DM.FDTransactionData.StartTransaction;

      temp:= 'DELETE FROM TB_PERSON WHERE PK_PERSON = ' + dm.SQLPerson.FieldByName('PK_PERSON').AsString;

      PM.RunSQL(temp, DM.SQLData);
      DM.FDTransactionData.Commit;
    Except
      if DM.FDTransactionData.TransactionIntf.Active then
        DM.FDTransactionData.Rollback;
      ShowMessage('Ocorreu um erro ao excluir!');
      Exit;
    end;

    ShowMessage('Registro exclu�do com sucesso!');

    EdtFilter.Text := '';
    BtnSearchClick(nil);
  end;


end;

procedure TFPerson.BtnEditClick(Sender: TObject);
begin
  PPerson.Visible := True;
  PM.CentralizePanel(Self, PPerson);
  ShowPerson(1);
  PData.Enabled := False;
  PButtons.Enabled := False;
end;

procedure TFPerson.BtnNewClick(Sender: TObject);
begin
  PPerson.Visible := True;
  PM.CentralizePanel(Self, PPerson);
  ShowPerson(0);
  PData.Enabled := False;
  PButtons.Enabled := False;
end;

procedure TFPerson.BtnReportClick(Sender: TObject);
begin
  DM.frxReportGeral.Clear;
  if (FileExists(ExtractFilePath(ParamStr(0)) + 'Report\Person.Listing.fr3')) then
    DM.frxReportGeral.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Report\Person.Listing.fr3')
  else
    Application.MessageBox('O arquivo do relat�rio n�o foi encontrado! Tente atualizar seu relat�rio','Arquivo n�o encontrado',0);


  DM.frxDBDatasetPerson.DataSource:= DM.DSPerson;
  DM.frxReportGeral.PrepareReport();

  if FPreviewFR = nil then
    Application.CreateForm(TFPreviewFR, FPreviewFR);
  DM.frxReportGeral.Preview:= FPreviewFR.frxPreview;
  FPreviewFR.ShowModal;
  Exit;
end;

procedure TFPerson.BtnSavePersonClick(Sender: TObject);
begin
  if VerifyFields = False then
  begin
    ShowMessage('H� campos que precisam ser preenchidos. Todos os campos s�o obrigat�rios!');
    Exit;
  end;

  if Application.MessageBox('Deseja salvar os dados?', 'Salvar', MB_YESNO +
    MB_ICONQUESTION) = IDNO then
  begin
    exit;
  end;

  SavePerson(PersonControl);
  PersonControl := -1;
end;

procedure TFPerson.BtnSearchClick(Sender: TObject);
var
  temp, where: string;
begin
  temp := 'SELECT * FROM TB_PERSON P';
  where := '';

  if EdtFilter.Text <> '' then
  begin
    case CBFilter.ItemIndex of
      0:
        where := ' WHERE P.PK_PERSON = ' + EdtFilter.Text;
      1:
        where := ' WHERE UPPER(P.Person_Name) like UPPER(' + QuotedStr('%' + EdtFilter.Text + '%') + ')';
    end;
  end;

  temp := temp + where;

  PM.RunSQL(temp, dm.SQLPerson);
  ButtonControl;
end;

procedure TFPerson.ButtonControl;
begin
  if DM.SQLPerson.Active = True then
  begin
    if DM.SQLPerson.FieldByName('PK_Person').AsString <> '' then
    begin
      BtnEdit.Enabled := True;
      BtnDelete.Enabled := True;
      BtnReport.Enabled := True;
    end
  end
  else
  begin
    BtnEdit.Enabled := False;
    BtnDelete.Enabled := False;
    BtnReport.Enabled := False;
  end;
end;

procedure TFPerson.ClearFields;
begin
  EdtPKPerson.Text := '';
  EdtPersonName.Text := '';
  EdtPersonBalance.Text := '';
end;

procedure TFPerson.EdtFilterKeyPress(Sender: TObject; var Key: Char);
begin
  if CBFilter.ItemIndex = 0 then
    Key := PM.ClearEdit(Sender as TCustomEdit, Key);
end;

procedure TFPerson.EdtPersonBalanceKeyPress(Sender: TObject; var Key: Char);
begin
  Key:= PM.ClearEdit(Sender as TCustomEdit, Key, ',');
end;

procedure TFPerson.FormActivate(Sender: TObject);
begin
  ButtonControl;
end;

procedure TFPerson.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DM.SQLPerson.Close;

  FPerson:= nil;
  Action:= caFree;
end;

procedure TFPerson.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if PPerson.Visible = False then
  begin
    case Key of
      VK_INSERT : if BtnNew.Enabled then
                    BtnNewClick(nil);
          VK_F2 : if BtnEdit.Enabled then
                    BtnEditClick(nil);
      VK_DELETE : if BtnDelete.Enabled then
                    BtnDeleteClick(nil);
          VK_F3 : if PButtons.Enabled then
                    BtnSearchClick(nil);
    end;
  end;
end;

procedure TFPerson.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    Key:= #0;
    if PPerson.Visible then
      BtnCancelPersonClick(nil)
    else
      Close;
  end;

  if Key = #13 then
  begin
    Key:= #0;

    if PPerson.Visible then
    begin
      if ((EdtPersonName.Text <> '') and (EdtPersonBalance.Text <> '')) then
      begin
        BtnSavePersonClick(nil);
      end
    end
    else
      Perform(Wm_NextDlgCtl,0,0);
  end;
end;

procedure TFPerson.GDataDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
begin
  if DM.SQLPerson.Active = False then
    Exit;

  with (Sender as TDBGrid) do
  begin
    Options:= Options + [dgRowSelect];
    DefaultDrawColumnCell(Rect, DataCol, Column, State);
  end;
end;

procedure TFPerson.SavePerson(ControlIndex: integer);
var
  temp: string;
begin
  try
    Temp := '';

    if DM.FDTransactionData.TransactionIntf.Active then
      DM.FDTransactionData.Rollback;
    DM.FDTransactionData.StartTransaction;

    case PersonControl of
      0 : begin
            temp:= 'INSERT INTO TB_PERSON (PERSON_NAME, BALANCE) VALUES ('
                 +  QuotedStr(EdtPersonName.Text) + ','
                 +  PM.SaveNumeric(EdtPersonBalance.Text) + ')'
          end;
      1 : begin
            temp:= 'UPDATE TB_PERSON SET'
                 + ' PERSON_NAME = ' + QuotedStr(EdtPersonName.Text)
                 + ' WHERE PK_PERSON = ' + EdtPkPerson.Text;
          end;
    end;

    PM.RunSQL(temp, DM.SQLData);
    DM.FDTransactionData.Commit;
  Except
    if DM.FDTransactionData.TransactionIntf.Active then
      DM.FDTransactionData.Rollback;
    ShowMessage('Ocorreu um erro ao salvar os dados!');
    Exit;
  end;

  ShowMessage('Dados salvos com sucesso!');
  ClearFields;
  BtnCancelPersonClick(nil);
  EdtFilter.Text := '';
  BtnSearchClick(nil);
end;

procedure TFPerson.ShowPerson(ControlIndex: integer);
begin
  PersonControl := ControlIndex;
  ClearFields;
  case ControlIndex of
    0:  begin
          EdtPKPerson.Text := 'N�o Registrado';
          EdtPersonBalance.Enabled := True;
          EdtPersonBalance.Color := clWhite;
          PSubTitle.Caption := 'CADASTRAR PESSOA';
        end;
    1:  begin
          EdtPKPerson.Text := DM.SQLPerson.FieldByName('pk_person').AsString;
          EdtPersonName.Text := DM.SQLPerson.FieldByName('person_name').AsString;
          EdtPersonBalance.Text := DM.SQLPerson.FieldByName('Balance').AsString;
          EdtPersonBalance.Enabled := False;
          EdtPersonBalance.Color := cl3DLight;
          PSubTitle.Caption := 'EDITAR PESSOA';
        end;
  end;
end;

function TFPerson.VerifyFields: Boolean;
begin
  Result := True;

  if ((EdtPersonName.Text = '') or (EdtPersonBalance.Text = '')) then
    Result:= False;

end;

end.

