unit StockListUnit;
(*
  股票列表
  数据获取接口 http://quote.eastmoney.com/stock_list.html
  创业板
    创业板的代码是300打头的股票代码
  沪市A股
    沪市A股的代码是以600、601或603打头
  沪市B股
    沪市B股的代码是以900打头
  科创板
    科创板的代码是688打头
  深市A股
    深市A股的代码是以000打头
  中小板
    中小板的代码是002打头
  深圳B股
    深圳B股的代码是以200打头
  新股申购
    沪市新股申购的代码是以730打头
    深市新股申购的代码与深市股票买卖代码一样
  配股代码
    沪市以700打头，深市以080打头 权证，沪市是580打头 深市是031打头

  000  002 200 300
  深市A股 中小板 创业板 深圳B股 属于深圳股票
  600 601 603 900 688
  沪市A股 沪市B股  科创板
*)
interface

uses
  System.Classes, System.Generics.Collections, FireDAC.Comp.Client, uRestClientServiceUnit;

type
  TStockType = (stNone, stCY, stLA, stLB, stKC, stSA, stZXB, stSB, stNew, stPG);

  TStock = record
    Code: string;
    Name: string;
    &Type: TStockType;
  end;
  TStocks = TDictionary<string, TStock>;

  TStockList = class(TObject)
  private
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
    FStocks: TDictionary<TStockType, TStocks>;
    FREST: TRESTClientService;
    // 刷新成功
    FOnRefreshSuccess: TNotifyEvent;
    // 刷新失败
    FOnRefreseError: TNotifyEvent;
  private
    procedure DoRefreshed(StatusCode:Integer; StatusText:String; Content:String);
    procedure DecodeStock(HTML: string);
    function CheckStockType(StockCode: string): TStockType;
    procedure AddStock(Stock: TStock);
    procedure SaveStock(Stock: TStock);
  public
    constructor Create(Database: string);
    destructor Destroy; override;

    // 刷新列表从远程获取
    function Refresh: Boolean;
    // 从本地加载
    function Load: Boolean;

    property Stocks: TDictionary<TStockType, TStocks> read FStocks;
  end;


implementation

uses
  System.SysUtils, REST.Types, System.RegularExpressions;

{ TStockList }

procedure TStockList.AddStock(Stock: TStock);
var
  Stocks: TStocks;
begin
  if not FStocks.TryGetValue(Stock.&Type, Stocks) then
  begin
    Stocks := TStocks.Create;
    FStocks.Add(Stock.&Type, Stocks);
  end;
  Stocks.Add(Stock.Code, Stock);
end;

function TStockList.CheckStockType(StockCode: string): TStockType;
var
  SubCode: string;
begin
  // 截取前三位
  SubCode := StockCode.Substring(0, 3);
  if SubCode = '300' then
    Result := TStockType.stCY
  else
  if (SubCode = '600') or (SubCode = '601') or (SubCode = '603') then
    Result := TStockType.stLA
  else
  if SubCode = '900' then
    Result := TStockType.stLB
  else
  if SubCode = '688' then
    Result := TStockType.stKC
  else
  if SubCode = '000' then
    Result := TStockType.stSA
  else
  if SubCode = '002' then
    Result := TStockType.stZXB
  else
  if SubCode = '200' then
    Result := TStockType.stSB
  else
  if SubCode = '730' then
    Result := TStockType.stNew
  else
  if (SubCode = '700') or (SubCode = '080') or (SubCode = '580') or (SubCode = '031')  then
    Result := TStockType.stPG
  else
    Result := TStockType.stNone;
end;

constructor TStockList.Create(Database: string);
begin
  inherited Create;

  FDConnection := TFDConnection.Create(nil);
  FDQuery := TFDQuery.Create(nil);

  FDConnection.DriverName := 'SQLite';
  FDConnection.Params.Database := Database;
  FDQuery.Connection := FDConnection;

  FStocks := TDictionary<TStockType, TStocks>.Create;

  FREST := TRESTClientService.Create(nil);
end;

procedure TStockList.DecodeStock(HTML: string);
var
  Pattern: string;
  Match: TMatch;
  Matchs: TMatchCollection;
  Stock: TStock;

begin
  Pattern := '\<li\>.*\<a target="_blank" href=".*\.html"\>(.*)\((.*)\)\</a\>\</li\>';
  Matchs := TRegEx.Matches(HTML, Pattern);
  for Match in Matchs do
  begin
    Stock.Name := Match.Groups.Item[1].Value;
    Stock.Code := Match.Groups.Item[2].Value;
    Stock.&Type := CheckStockType(Stock.Code);
    if Stock.&Type <> TStockType.stNone then
    begin
      AddStock(Stock);
      SaveStock(Stock);
    end;
  end;
end;

destructor TStockList.Destroy;
begin
  FDQuery.Close;
  FDQuery.Free;

  FDConnection.Close;
  FDConnection.Free;

  FStocks.Free;
  FREST.Free;
  inherited;
end;

procedure TStockList.DoRefreshed(StatusCode: Integer; StatusText,
  Content: String);
begin
  // 刷新完成 解析数据
  if StatusCode = 200 then
  begin
    DecodeStock(Content);
    if Assigned(FOnRefreshSuccess) then
      FOnRefreshSuccess(Self);
  end else
  begin
    if Assigned(FOnRefreseError) then
      FOnRefreseError(Self);
  end;
end;

function TStockList.Load: Boolean;
var
  sSql: String;
  Stock: TStock;
begin
  // 从数据库抓取
  sSql := 'SELECT * FROM stock_list';
  FDConnection.Open();
  try
    FDQuery.Close;
    FDQuery.SQL.Clear;
    FDQuery.SQL.Add(sSql);
    FDQuery.Open();

    FDQuery.First;
    while not FDQuery.Eof do
    begin
      Stock.Name := FDQuery.FieldByName('name').AsString;
      Stock.Code := FDQuery.FieldByName('code').AsString;
      Stock.&Type := TStockType(FDQuery.FieldByName('type').AsInteger);
      AddStock(Stock);
      FDQuery.Next;
    end;

  finally
    FDQuery.Close;
    FDConnection.Close;
  end;
end;

function TStockList.Refresh: Boolean;
begin
  // 从远程获取
  // <li><a target="_blank" href="http://quote.eastmoney.com/sz000510.html">新金路(000510)</a></li>
  FREST.Client.BaseURL := 'http://quote.eastmoney.com/stock_list.html';
  FREST.Client.FallbackCharsetEncoding :=  'gb2312';
  FREST.Request.Method := TRESTRequestMethod.rmGET;
  FREST.Execute(DoRefreshed);
end;

procedure TStockList.SaveStock(Stock: TStock);
var
  sSql: String;
begin
  sSql := 'INSERT OR REPLACE INTO stock_list(code, name, type) VALUES(';
  sSql := sSql + QuotedStr(Stock.Code) + ',';
  sSql := sSql + QuotedStr(Stock.Name) + ',';
  sSql := sSql + InttoStr(Ord(Stock.&Type)) + ')';
  FDConnection.Open();
  try
    FDQuery.Close;
    FDQuery.SQL.Clear;
    FDQuery.SQL.Add(sSql);
    FDQuery.ExecSQL;
  finally
    FDQuery.Close;
    FDConnection.Close;
  end;

end;

end.

