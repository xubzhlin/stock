unit Unit19;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  StockListUnit, StockHSGTHDSTAUnit, StockDaylineUnit, StockZLSJDetailUnit;

type


  TForm19 = class(TForm)
    FDQuery1: TFDQuery;
    FDConnection1: TFDConnection;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Panel1: TPanel;
    ckbZDF: TCheckBox;
    ckbMain: TCheckBox;
    ckbTen: TCheckBox;
    ckbFive: TCheckBox;
    ckbOne: TCheckBox;
    Panel2: TPanel;
    Button1: TButton;
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    Button2: TButton;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    DateTimePicker1: TDateTimePicker;
    Button3: TButton;
    ProgressBar3: TProgressBar;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid1DrawDataCell(Sender: TObject; const Rect: TRect;
      Field: TField; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    StockList: TStockList;
    StockHSGTHDSTA: TStockHSGTHDSTA;
    StockDayline: TStockDayline;
    StockZLSJDetail: TStockZLSJDetail;
    procedure ShowData(Date: TDateTime);
    procedure RefreshColumn;
    procedure CheckClick(Sender: TObject);
    procedure OnRefreshStatus(Sender: TObject);
    procedure OnFinished(Sender: TObject);
    procedure DateTimeChange(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form19: TForm19;

implementation

uses
  System.IOUtils;

{$R *.dfm}

procedure TForm19.Button1Click(Sender: TObject);
var
  Stocks: TStrings;
  Stock: TStocks;

begin
  //
  FDQuery1.Close;
  FDConnection1.Close;


  Stocks := TStringList.Create;
  if StockList.Stocks.TryGetValue(TStockType.stCY, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stLA, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stKC, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stSA, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stZXB, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);

  ProgressBar1.Max := Stocks.Count;
  ProgressBar1.Min := 0;
  ProgressBar1.Position := 0;

  StockHSGTHDSTA.OnFinished := OnFinished;
  StockHSGTHDSTA.OnRefreshStatus := OnRefreshStatus;
  StockHSGTHDSTA.Start(1, Stocks);

  Stocks.Free;


end;

procedure TForm19.Button2Click(Sender: TObject);
var
  Stocks: TStrings;
  Stock: TStocks;
begin
  //
  FDQuery1.Close;
  FDConnection1.Close;


  Stocks := TStringList.Create;
  if StockList.Stocks.TryGetValue(TStockType.stCY, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stLA, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stKC, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stSA, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stZXB, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);

  ProgressBar2.Max := Stocks.Count;
  ProgressBar2.Min := 0;
  ProgressBar2.Position := 0;

  StockHSGTHDSTA.OnFinished := OnFinished;
  StockDayline.OnRefreshStatus := OnRefreshStatus;
  StockDayline.Start(1, Stocks);

  Stocks.Free;


end;

procedure TForm19.Button3Click(Sender: TObject);
var
  Stocks: TStrings;
  Stock: TStocks;
begin
  //
  FDQuery1.Close;
  FDConnection1.Close;


  Stocks := TStringList.Create;
  if StockList.Stocks.TryGetValue(TStockType.stCY, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stLA, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stKC, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stSA, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);
  if StockList.Stocks.TryGetValue(TStockType.stZXB, Stock) then
    Stocks.AddStrings(Stock.Keys.ToArray);

  ProgressBar3.Max := Stocks.Count;
  ProgressBar3.Min := 0;
  ProgressBar3.Position := 0;

  StockZLSJDetail.OnFinished := OnFinished;
  StockZLSJDetail.OnRefreshStatus := OnRefreshStatus;
  StockZLSJDetail.Start(1, Stocks);



  Stocks.Free;

end;

procedure TForm19.CheckClick(Sender: TObject);
var
  Filter: string;
  TextFilter: string;
  function AddFilter(Str: string): string;
  begin
    if Filter = '' then
      Filter := Str
    else
      Filter := Filter + ' and ' + Str;
  end;
begin
  FDQuery1.Filtered := False;
  Filter := '';
  TextFilter := Trim(Edit1.Text);
  if TextFilter <> '' then
  begin
    Filter := '(SCODE like ''%' + TextFilter + '%'' or SNAME like ''%' + TextFilter + '%'')';
  end;
  if ckbZDF.Checked then
    AddFilter('ZDF>0');
  if ckbOne.Checked then
    AddFilter('SHAREHOLDPRICEONE>0');
  if ckbFive.Checked then
    AddFilter('SHAREHOLDPRICEFIVE>0');
  if ckbTEN.Checked then
    AddFilter('SHAREHOLDPRICETEN>0');
  if ckbMain.Checked then
    AddFilter('MAININFLOW>0');
  if Filter <> '' then
  begin
    FDQuery1.Filter := Filter;
    FDQuery1.Filtered := True;
  end
end;

procedure TForm19.DateTimeChange(Sender: TObject);
begin
  ShowData(DateTimePicker1.DateTime);
  CheckClick(Sender);
end;

procedure TForm19.DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  
  if Column.Title.Caption = 'HDDATE' then
    Column.Title.Caption := '日期'
  else
  if Column.Title.Caption = 'SCODE' then
    Column.Title.Caption := '代码'
  else
  if Column.Title.Caption = 'SNAME' then
    Column.Title.Caption := '名称'
  else
  if Column.Title.Caption = 'SHAREHOLDSUM' then
    Column.Title.Caption := '持有金额'
  else
  if Column.Title.Caption = 'SHARESRATE' then
    Column.Title.Caption := '持有比例'
  else
  if Column.Title.Caption = 'CLOSEPRICE' then
    Column.Title.Caption := '当日收盘价'
  else
  if Column.Title.Caption = 'ZDF' then
    Column.Title.Caption := '当日涨幅'
  else
  if Column.Title.Caption = 'SHAREHOLDPRICE' then
    Column.Title.Caption := '持股市值'
  else
  if Column.Title.Caption = 'SHAREHOLDPRICEONE' then
    Column.Title.Caption := '1日变化'
  else
  if Column.Title.Caption = 'SHAREHOLDPRICEFIVE' then
    Column.Title.Caption := '5日变化'
  else
  if Column.Title.Caption = 'SHAREHOLDPRICETEN' then
    Column.Title.Caption := '10日变化'
  else
  if Column.Title.Caption = 'ShareHoldSumChg' then
    Column.Title.Caption := '持股总额变动'
  else
  if Column.Title.Caption = 'MAININFLOW' then
    Column.Title.Caption := '主力净额'
  else
  if Column.Title.Caption = 'MAININFLOWPRESENT' then
    Column.Title.Caption := '主力净占比'
  else
  if Column.Title.Caption = 'ShareCnt' then
    Column.Title.Caption := '机构数量'
  else
  if Column.Title.Caption = 'SharePrice' then
    Column.Title.Caption := '持股总数(万股)'
  else
  if Column.Title.Caption = 'ShareNum' then
    Column.Title.Caption := '持股市值(亿元)'
  else
  if Column.Title.Caption = 'TabRate' then
    Column.Title.Caption := '总股比例(%)'
  else
  if Column.Title.Caption = 'TabProRate' then
    Column.Title.Caption := '流通比例(%)';
end;

procedure TForm19.DBGrid1DrawDataCell(Sender: TObject; const Rect: TRect;
  Field: TField; State: TGridDrawState);
var
  i: Integer;
begin
  if not Field.IsNull then
  begin
    if Field.FieldName = 'CLOSEPRICE' then
    begin
      if TDBGrid(Sender).DataSource.DataSet.FieldByName('ZDF').AsFloat > 0 then
        TDBGrid(Sender).Canvas.Font.Color:=clRed
      else
        TDBGrid(Sender).Canvas.Font.Color:=clGreen;
    end else
    if (Field.FieldName = 'ZDF') or (Field.FieldName = 'SHAREHOLDPRICEONE') or
      (Field.FieldName = 'SHAREHOLDPRICEFIVE') or (Field.FieldName = 'SHAREHOLDPRICETEN') or
      (Field.FieldName = 'ShareHoldSumChg') or (Field.FieldName = 'MAININFLOW') or
      (Field.FieldName = 'MAININFLOWPRESENT') then
    begin
      TDBGrid(Sender).Canvas.Brush.Style:=bsClear;
      if Field.AsFloat > 0 then
        TDBGrid(Sender).Canvas.Font.Color:=clRed
      else
        TDBGrid(Sender).Canvas.Font.Color:=clGreen;
    end else
      TDBGrid(Sender).Canvas.Font.Color:=clBlack;
  end else
    TDBGrid(Sender).Canvas.Font.Color:=clBlack;
  TDBGrid(Sender).DefaultDrawDataCell(Rect,Field,State);
//  if Column.FieldName = 'HDDATE' then
//    Column.Title.Caption := '日期';  
//  if Column.FieldName = 'SCODE' then
//    Column.Title.Caption := '代码';
//  if Column.FieldName = 'SNAME' then
//    Column.Title.Caption := '名称';
//  if Column.FieldName = 'SHAREHOLDSUM' then
//    Column.Title.Caption := '持有金额';
//  if Column.FieldName = 'SHARESRATE' then
//    Column.Title.Caption := '持有比例';
//  if Column.FieldName = 'CLOSEPRICE' then
//    Column.Title.Caption := '当日收盘价';
//  if Column.FieldName = 'ZDF' then
//    Column.Title.Caption := '当日涨幅';  
//  if Column.FieldName = 'SHAREHOLDPRICE' then
//    Column.Title.Caption := '持股市值'; 
//  if Column.FieldName = 'SHAREHOLDPRICEONE' then
//    Column.Title.Caption := '1日变化'; 
//  if Column.FieldName = 'SHAREHOLDPRICEFIVE' then
//    Column.Title.Caption := '5日变化'; 
//  if Column.FieldName = 'SHAREHOLDPRICETEN' then
//    Column.Title.Caption := '10日变化';
//  if Column.FieldName = 'ShareHoldSumChg' then
//    Column.Title.Caption := '持股总额变动'; 
end;

procedure TForm19.DBGrid1TitleClick(Column: TColumn);
var
  FDIndex: TFDIndex;
  i: Integer;
  Title: string;
begin
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    if DBGrid1.Columns.Items[i] <> Column then
    begin
      Title:=DBGrid1.Columns.Items[i].Title.Caption;
      if (pos('▼',Title)=1) or (pos('▲',Title)=1) then
      begin
        DBGrid1.Columns.Items[i].Title.Caption := Title.Substring(1, MAXInt);
      end;
    end;
  end;
  Title:=Column.Title.Caption;
  if pos('▼',Title)=1 then
  begin 
    FDIndex := FDQuery1.Indexes.FindIndex('ASC');
    if(FDIndex <> nil) then
    begin
      FDIndex.Fields := Column.FieldName;
    end else
      FDQuery1.AddIndex('ASC', Column.FieldName, '', []);
    Title := Title.Replace('▼', '▲'); 
    FDQuery1.IndexName  := 'ASC';
  end else
  if pos('▲',Title)=1 then
  begin
    FDIndex := FDQuery1.Indexes.FindIndex('DES');
    if(FDIndex <> nil) then
    begin
      FDIndex.Fields := Column.FieldName;
    end else
      FDQuery1.AddIndex('DES', Column.FieldName, '', [soDescending]);
    Title := Title.Replace('▲', '▼'); 
    FDQuery1.IndexName  := 'DES';
  end else
  begin
    FDIndex := FDQuery1.Indexes.FindIndex('DES');
    if(FDIndex <> nil) then
    begin
      FDIndex.Fields := Column.FieldName;
    end else
      FDQuery1.AddIndex('DES', Column.FieldName, '', [soDescending]);
    Title := '▼' + Title; 
    FDQuery1.IndexName  := 'DES';
  end;
  Column.Title.Caption := Title;
  if FDQuery1.RecordCount > 0 then
    FDQuery1.First;
end;

procedure TForm19.FormCreate(Sender: TObject);
var
  DBPath: string;
begin
  ckbZDF.OnClick := CheckClick;
  ckbOne.OnClick := CheckClick;
  ckbFive.OnClick := CheckClick;
  ckbTen.OnClick := CheckClick;
  ckbMain.OnClick := CheckClick;
  Edit1.OnChange := CheckClick;
  DateTimePicker1.DateTime := Now;
  DateTimePicker1.OnChange := DateTimeChange;

  DBPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'stock.sdb');

  StockList := TStockList.Create(DBPath);
  StockList.Load;

  StockDayline := TStockDayline.Create(DBPath);
  StockHSGTHDSTA := TStockHSGTHDSTA.Create(DBPath);
  StockZLSJDetail := TStockZLSJDetail.Create(DBPath);

  FDConnection1.DriverName := 'SQLite';
  FDConnection1.Params.Database := DBPath;

  ShowData(DateTimePicker1.DateTime);
end;

procedure TForm19.FormResize(Sender: TObject);
begin
  RefreshColumn;
end;


procedure TForm19.OnFinished(Sender: TObject);
begin
  TThread.Synchronize(nil, procedure
  begin
    ShowData(DateTimePicker1.DateTime);
  end);

end;

procedure TForm19.OnRefreshStatus(Sender: TObject);
begin
  if Sender is TStockHSGTHDSTA then
  begin
    ProgressBar1.Position := ProgressBar1.Max - TStockHSGTHDSTA(Sender).StockList.Count;
    Label3.Caption := InttoStr(ProgressBar1.Position) + '/' +  InttoStr(ProgressBar1.Max);
  end else
  if Sender is TStockDayline then
  begin
    ProgressBar2.Position := ProgressBar2.Max - TStockDayline(Sender).StockList.Count;
    Label4.Caption := InttoStr(ProgressBar2.Position) + '/' +  InttoStr(ProgressBar2.Max);
  end else
  if Sender is TStockZLSJDetail then
  begin
    ProgressBar3.Position := ProgressBar3.Max - TStockZLSJDetail(Sender).StockList.Count;
    Label6.Caption := InttoStr(ProgressBar3.Position) + '/' +  InttoStr(ProgressBar3.Max);
  end;


end;

procedure TForm19.RefreshColumn;
var
  i, cWidth: Integer;
begin
  cWidth := Trunc((DBGrid1.Width - 27) / DBGrid1.Columns.Count) - 2;
  for i := 0 to DBGrid1.Columns.Count - 1 do
  begin
    DBGrid1.Columns.Items[i].Width :=  cWidth;
  end;
end;

procedure TForm19.ShowData(Date: TDateTime);
var
  sSql: String;
  Stock: TStock;
  i: Integer;
  cWidth: Integer;
  DateTimeStr: string;
  Field: TField;
begin
  // 从数据库抓取
//  sSql := 'SELECT HDDATE as 日期, SCODE as 代码, SNAME as 名称, SHAREHOLDSUM as 股份持有金额, SHARESRATE as 股份持有比例'
//    +', CLOSEPRICE as 当日收盘价, ZDF as 当日涨幅, SHAREHOLDPRICE as 持股市值, SHAREHOLDPRICEONE as 一日变化, SHAREHOLDPRICEFIVE as 五日变化, SHAREHOLDPRICETEN as 十日变化'
//    +', ShareHoldSumChg as 持股总额变动, Zb, Zzb FROM stock_hsgthdsta';
  // 筛选条件
  // 北上资金占比
  // 北上资金1日 +
  // 北上资金1日 -
  DateTimeStr := FormatDateTime('YYYY-MM-DD HH:MM:SS', trunc(Date) - 1);
  DateTimeStr := DateTimeStr.Replace(' ', 'T', [rfReplaceAll]);
  sSql := ' select stock_hsgthdsta.HDDATE,stock_hsgthdsta.SCODE,stock_hsgthdsta.SNAME,stock_hsgthdsta.CLOSEPRICE,stock_hsgthdsta.ZDF,stock_hsgthdsta.SHAREHOLDSUM,'
    +' stock_hsgthdsta.SHARESRATE,stock_hsgthdsta.SHAREHOLDPRICE, stock_hsgthdsta.SHAREHOLDPRICEONE, stock_hsgthdsta.SHAREHOLDPRICEFIVE, stock_hsgthdsta.SHAREHOLDPRICETEN,ShareHoldSumChg,'
    +' stock_dayline.MAININFLOW,stock_dayline.MAININFLOWPRESENT,'
    +' stock_zlsjdetail.ShareCnt,stock_zlsjdetail.ShareNum,stock_zlsjdetail.SharePrice,stock_zlsjdetail.TabRate,stock_zlsjdetail.TabProRate'
    +' from stock_hsgthdsta  left join stock_dayline  on stock_dayline.SCODE = stock_hsgthdsta.SCODE '
    +' left join (select MAX(HDDATE) as HDDATE,SCODE,ShareCnt,SharePrice,ShareNum,TabRate,TabProRate from stock_zlsjdetail group by SCODE) as stock_zlsjdetail'
    +' on stock_dayline.SCODE = stock_zlsjdetail.SCODE where stock_hsgthdsta.HDDATE=''' + DateTimeStr + ''' and  stock_dayline.HDDATE = ''' + FormatDateTime('YYYY-MM-DD', trunc(Date- 1)) + '''';
  FDConnection1.Open();
  try
    FDQuery1.Close;
    FDQuery1.SQL.Clear;
    FDQuery1.SQL.Add(sSql);
    FDQuery1.Open();
    if FDQuery1.RecordCount > 0 then
      FDQuery1.First;

    for Field in FDQuery1.Fields do
    begin
      if Field is TNumericField then
        TNumericField(Field).DisplayFormat := '###,###,##0.##';
    end;

    RefreshColumn;
    //
  finally
    //FDQuery1.Close;
    //FDConnection1.Close;
  end;

end;


//让Delphi程序不受Windows日期格式的影响
procedure SetSysDateFormat;
begin
  // 设定程序本身所使用的日期时间格式
  FormatSettings.LongDateFormat := 'yyyy-MM-dd';
  FormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  FormatSettings.LongTimeFormat := 'hh:nn:ss';
  FormatSettings.ShortTimeFormat := 'hh:nn:ss';
  FormatSettings.DateSeparator := '-';
  FormatSettings.timeSeparator := ':';
end;

initialization
  SetSysDateFormat;

end.
