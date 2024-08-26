unit UDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client, Data.DB, ProcMethods, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.FB, FireDAC.Phys.FBDef, System.ImageList, Vcl.ImgList, Vcl.Controls, frxClass,
  frxDBSet, Vcl.Dialogs;

type
  TDM = class(TDataModule)
    FDConnection: TFDConnection;
    FDTransaction: TFDTransaction;
    SQLGeneral: TFDQuery;
    SQLPerson: TFDQuery;
    DSPerson: TDataSource;
    FDTransactionData: TFDTransaction;
    SQLData: TFDQuery;
    ImageListIcons: TImageList;
    DSUser: TDataSource;
    SQLUser: TFDQuery;
    SQLFinancialTransaction: TFDQuery;
    DSFinancialTransaction: TDataSource;
    frxReportGeral: TfrxReport;
    frxDBDatasetFinancial: TfrxDBDataset;
    frxDBDatasetPerson: TfrxDBDataset;
    frxDBDatasetUser: TfrxDBDataset;
    OpenDialog: TOpenDialog;

  Public
    PKUser: string;

  end;

var
  DM: TDM;
  PM: TProcMethods;


implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
