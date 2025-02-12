object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 325
  ClientWidth = 448
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object nxSession1: TnxSession
    ActiveRuntime = True
    ServerEngine = nxServerEngine1
    Left = 120
    Top = 24
  end
  object nxServerEngine1: TnxServerEngine
    ActiveRuntime = True
    SqlEngine = nxSqlEngine1
    ServerName = 'NexusDB@DESKTOP-TS56AQA'
    Options = []
    TableExtension = 'nx1'
    Left = 96
    Top = 128
  end
  object DispenseDB: TnxDatabase
    ActiveRuntime = True
    Session = nxSession1
    AliasPath = 'C:\MtntopDispense\DispenseDB'
    Left = 40
    Top = 32
  end
  object SelectQuery: TnxQuery
    ActiveRuntime = True
    Database = DispenseDB
    SQL.Strings = (
      ' SELECT * FROM VMedChartPbscode;')
    Left = 256
    Top = 120
  end
  object UpdateQuery: TnxQuery
    Database = DispenseDB
    Left = 272
    Top = 200
  end
  object nxSqlEngine1: TnxSqlEngine
    ActiveRuntime = True
    ActiveDesigntime = True
    StmtLogging = False
    StmtLogTableName = 'QueryLog'
    UseFieldCache = False
    Left = 136
    Top = 232
  end
end
