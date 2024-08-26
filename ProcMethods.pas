unit ProcMethods;

interface

uses

  FireDAC.Comp.Client, FireDAC.Stan.Error, FireDAC.Stan.Option,IdHashMessageDigest, IdGlobal,
  shlobj, Vcl.Dialogs, Vcl.Controls, Vcl.Menus, HTTPApp, Winapi.Windows, SysUtils, Vcl.StdCtrls, Vcl.Mask, Vcl.Forms,
  System.Classes, Vcl.ExtCtrls, Winapi.WinInet, System.Win.Registry, Winapi.ShellAPI, Vcl.Themes, DBGrids, Vcl.Graphics,
   Data.DB,System.DateUtils,NetEncoding, IdCoderMIME;

const
  fmtSavedate = 'dd.mm.yyyy';

type

  TProcMethods = Class
  private
    function ReturnSQLType(sSQL: String): Integer;

  public
    function GetMD5(AValue: String): String;
    procedure RunSQL(sSQL: String; Query: TFDQuery);
    procedure CentralizePanel(Form: TForm; Panel: TPanel);
    function ClearEdit(Edt: TCustomEdit; K: Char; C: Char = '#'; Signal: Char = '+'): Char;
    function SaveNumeric(Value: string; Decimals: Integer = 2; DecimalSeparator: String = '.'): String; overload;
    function FormatDecimals(value: String) : String;
    function ClearValue(Value: String): String;
    function SaveDate(Date: String): String; overload;
    function SaveDate(Date: TDateTime): String; overload;
    function ValidateDate(Date: String): Boolean;

  end;


implementation

{ TProcMethods }

procedure TProcMethods.CentralizePanel(Form: TForm; Panel: TPanel);
begin
  Panel.Left:= (Form.ClientWidth - Panel.Width) div 2;
  Panel.Top:= (Form.ClientHeight - Panel.Height) div 2;
  Panel.BringToFront;
  Panel.Visible:=True;
end;

function TProcMethods.ClearEdit(Edt: TCustomEdit; K, C, Signal: Char): Char;
var
  B, I: integer;
begin
  if Signal = '-' then
  begin
    if not(K in['0'..'9', #8,Signal, C, #13]) then
    begin
      ClearEdit := #0;
      Exit;
    end
  end
  else
    if not(K in['0'..'9', #8, C, #13]) then
    begin
      ClearEdit := #0;
      Exit;
    end;

  B:= 0;
  for I:= 1 to Length(Edt.Text) do
    if Edt.Text[I] = c then
      B:= B + 1;

  if (B > 0) then
    if ((K in['0'..'9', #8])) then
      ClearEdit:= K
    else
    begin
      k:= #0;
      ClearEdit:= (#0);
    end;

  if (Signal = '-') and (Edt.Text <> '') and (K = '-') then
    ClearEdit:= (#0)
  else
    ClearEdit:= K;
end;

function TProcMethods.ClearValue(Value: String): String;
var
  y: String;
  I: Integer;
begin
  if Value = '' then
    Value:= '0';

  Y:= '';
  for I:= 1 to length(Value) do
    if Value[I] <> '.' then
      y:= y + Value[i];
  Result:= Y;
end;

function TProcMethods.FormatDecimals(value: String): String;
Var
  resultvalue: Real;
  fraction: Real;
  thirdChar : integer;
  eNegative: Boolean;
begin
  resultvalue:= trunc(StrToFloatDef(ClearValue(value), 0));
  fraction:= frac(StrToFloatDef(ClearValue(value), 0));
  eNegative:=False;
  if (resultvalue < 0) then
  begin
    eNegative:=True;
    resultvalue:= resultvalue * -1;
    fraction:= fraction * -1;
  end;

  thirdChar:= StrtoIntDef(Copy(FloatToStr(fraction), 5, 1), 0);
  resultvalue:= resultvalue + StrToFloat('0,' + (Copy(FloatToStr(fraction), 3, 2)));

  if (thirdChar > 5) then
    resultvalue:= resultvalue + 0.01;

  if (eNegative) then
    resultvalue:=resultvalue * -1;

  Result:= FormatFloat('#0.00', resultvalue);
end;

function TProcMethods.GetMD5(AValue: String): String;
var
  hashMessageDigest5: TIdHashMessageDigest5;
begin
  hashMessageDigest5:= nil;
  try
    hashMessageDigest5:= TIdHashMessageDigest5.Create;
    Result:= IdGlobal.IndyLowerCase(hashMessageDigest5.HashStringAsHex(AValue));
  finally
    hashMessageDigest5.Free;
  end;
end;

function TProcMethods.ReturnSQLType(sSQL: String): Integer;
var
  I: Integer;
begin
  Result:= 0;

  for I:= 1 to Length(sSQL) do
  begin
    if (UpperCase(Copy(sSQL, I, 14)) = 'CREATE TRIGGER') then
    begin Result:= 0; Exit; end;
    if (UpperCase(Copy(sSQL, I, 13)) = 'ALTER TRIGGER') then
    begin Result:= 0; Exit; end;
    if (UpperCase(Copy(sSQL, I, 23)) = 'CREATE OR ALTER TRIGGER') then
    begin Result:= 0; Exit; end;
    if (UpperCase(Copy(sSQL, I, 6)) = 'SELECT') then
    begin Result:= 1; Exit; end;
    if (UpperCase(Copy(sSQL, I, 6)) = 'UPDATE') then
    begin Result:= 0; Exit; end;
    if (UpperCase(Copy(sSQL, I, 6)) = 'INSERT') then
    begin Result:= 0; Exit; end;
    if (UpperCase(Copy(sSQL, I, 6)) = 'DELETE') then
    begin Result:= 0; Exit; end;
    if (UpperCase(Copy(sSQL, I, 5)) = 'ALTER') then
    begin Result:= 0; Exit; end;
  end;
end;

procedure TProcMethods.RunSQL(sSQL: String; Query: TFDQuery);
begin
  with Query do
  begin
    ResourceOptions.EscapeExpand:=False;
    ResourceOptions.MacroCreate:=False;
    ResourceOptions.ParamCreate:=False;
    ResourceOptions.ParamExpand:=False;
    ResourceOptions.DirectExecute:=True;
    ResourceOptions.AssignedValues:=[];

    Close;
    SQL.Clear;
    SQL.Add(sSQL);

    if ReturnSQLType(sSQL) = 0 then
      ExecSQL
    else
      Open;
  end;
end;

function TProcMethods.SaveDate(Date: String): String;
var
  Res: TDate;
begin
  try
    if Date = '' then
    begin
      Result := 'null';
      exit;
    end;

    Res:= StrToDate(Date);
    if Res = StrToDate('30/12/1899') then
    begin
      Result:= 'null';
      Exit;
    end;
  except
    Result:= 'null';
    Exit;
  end;

  Result:= QuotedStr(FormatDateTime(fmtSaveDate, Res));
end;

function TProcMethods.SaveDate(Date: TDateTime): String;
begin
  Result:= QuotedStr(FormatDateTime(fmtSavedate, Date));
end;

function TProcMethods.SaveNumeric(Value: string; Decimals: Integer; DecimalSeparator: String): String;
var
  X, Y: String;
  I, II: Integer;
begin
     If (Decimals < 3) then
    Value:= FormatDecimals(Value);

  X:= FormatFloat('#0.'+StringOfChar('0',Decimals), StrToFloat(ClearValue(Value)));

  II:= 0;
  for I:= 1 to Length(X) do
  begin
    if (X[I] in ['-', ',', '0'..'9']) then
    begin
      if X[I] = ',' then
      begin
        II:= II + 1;
        if II <= 1 then
          Y:= Y + DecimalSeparator;
      end
      else
        Y:= Y + X[I];
    end;
  end;

  if Y = '' then
    Y:= '0';
  Result:= Y;
end;

function TProcMethods.ValidateDate(Date: String): Boolean;
var
  DateTemp: TDateTime;
begin
  if (Date = '00/00/0000') then
  begin
    Result:= False;
    Exit;
  end;

  try
    if (StrToDate(Date) <= StrToDate('30/12/1899')) then
    begin
      Result:= False;
      Exit;
    end;

    if (Date = '  /  /    ') or (Date = '  /  /  ') then
    begin
      Result:= True;
      Exit;
    end;
    DateTemp:= StrToDate(Date);
    Result:= True;
  except
    Result:= False;
  end;
end;

end.
