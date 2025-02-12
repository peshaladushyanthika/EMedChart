unit EMedChartU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, nxdb, nxsdServerEngine,
  nxsrServerEngine, nxllComponent, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client,System.Generics.Collections,
  nxsrSqlEngineBase, nxsqlEngine, nxseAllEngines ;

type
  TForm1 = class(TForm)
    nxSession1: TnxSession;
    nxServerEngine1: TnxServerEngine;
    DispenseDB: TnxDatabase;
    SelectQuery: TnxQuery;
    UpdateQuery: TnxQuery;
    nxSqlEngine1: TnxSqlEngine;
    procedure FormCreate(Sender: TObject);
    procedure AddFieldAndPopulate;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
try
    nxSession1.Active := True;  // Ensure session is active
    DispenseDB.Session := nxSession1;  // Assign session
    DispenseDB.Connected := True;  // Connect to the database

    ShowMessage('Connected to NexusDB successfully!');
  except
    on E: Exception do
      ShowMessage('Database connection failed: ' + E.Message);
  end;
  AddFieldAndPopulate;
end;

procedure TForm1.AddFieldAndPopulate;
var
  Query: TnxQuery;
  TextFile: TStringList;
  PBS_Dictionary: TDictionary<string, Boolean>;
  FilePath, Line, PBSCode, Value: string;
  i: Integer;
  TransactionStarted: Boolean; // Flag to track transaction status
begin
  if not DispenseDB.Connected then
    DispenseDB.Connected := True;

  PBS_Dictionary := TDictionary<string, Boolean>.Create;
  try
    // Load .txt file
    TextFile := TStringList.Create;
    try
      FilePath := 'C:\Users\ashan\Documents\Embarcadero\Studio\Projects\New folder\med-chart-electronic.txt';
      if not FileExists(FilePath) then
        raise Exception.Create('File not found: ' + FilePath);

      TextFile.LoadFromFile(FilePath);

      // Read and store values in the dictionary
      for i := 1 to TextFile.Count - 1 do
      begin
        Line := TextFile[i];
        PBSCode := Copy(Line, 1, Pos(#9, Line) - 1);
        Value := Copy(Line, Pos(#9, Line) + 1, MaxInt);

        if not PBS_Dictionary.ContainsKey(PBSCode) then
          PBS_Dictionary.Add(PBSCode, Value = 'Y')
        else
          PBS_Dictionary[PBSCode] := Value = 'Y';
      end;
    finally
      TextFile.Free;
    end;

    SelectQuery := TnxQuery.Create(nil);
    UpdateQuery := TnxQuery.Create(nil);

    SelectQuery.Database := DispenseDB;
    UpdateQuery.Database := DispenseDB;

    TransactionStarted := False; // Initialize flag

    try
      // Start transaction before updating records
      DispenseDB.StartTransaction;
      TransactionStarted := True; // Mark transaction as started

      SelectQuery.SQL.Text := 'SELECT PBSCode FROM VMedChartPbscode';
      SelectQuery.Open;

      while not SelectQuery.Eof do
      begin
        PBSCode := SelectQuery.FieldByName('PBSCode').AsString;

        if PBS_Dictionary.ContainsKey(PBSCode) then
        begin
          UpdateQuery.SQL.Text := 'UPDATE VMedChartPbscode SET Emedchart = :Value WHERE PBSCode = :PBSCode';
          UpdateQuery.ParamByName('Value').AsBoolean := PBS_Dictionary[PBSCode];
          UpdateQuery.ParamByName('PBSCode').AsString := PBSCode;
          UpdateQuery.ExecSQL;
        end;

        SelectQuery.Next;
      end;

      DispenseDB.Commit;
      TransactionStarted := False;

      ShowMessage('Field & Value added successfully!');

    except
      on E: Exception do
      begin
        if TransactionStarted then
          DispenseDB.Rollback;

        ShowMessage('Error: ' + E.Message);
      end;
    end;

  finally
    PBS_Dictionary.Free;
    SelectQuery.Free;
    UpdateQuery.Free;
  end;
end;

end.
