unit StockListUnit;
(*
  ��Ʊ�б�
  ���ݻ�ȡ�ӿ� http://quote.eastmoney.com/stock_list.html
  ��ҵ��
    ��ҵ��Ĵ�����300��ͷ�Ĺ�Ʊ����
  ����A��
    ����A�ɵĴ�������600��601��603��ͷ
  ����B��
    ����B�ɵĴ�������900��ͷ
  �ƴ���
    �ƴ���Ĵ�����688��ͷ
  ����A��
    ����A�ɵĴ�������000��ͷ
  ��С��
    ��С��Ĵ�����002��ͷ
  ����B��
    ����B�ɵĴ�������200��ͷ
  �¹��깺
    �����¹��깺�Ĵ�������730��ͷ
    �����¹��깺�Ĵ��������й�Ʊ��������һ��
  ��ɴ���
    ������700��ͷ��������080��ͷ Ȩ֤��������580��ͷ ������031��ͷ

  000  002 200 300
  ����A�� ��С�� ��ҵ�� ����B�� �������ڹ�Ʊ
  600 601 603 900 688
  ����A�� ����B��  �ƴ���
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
    // ˢ�³ɹ�
    FOnRefreshSuccess: TNotifyEvent;
    // ˢ��ʧ��
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

    // ˢ���б��Զ�̻�ȡ
    function Refresh: Boolean;
    // �ӱ��ؼ���
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
  // ��ȡǰ��λ
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
  // ˢ����� ��������
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
  // �����ݿ�ץȡ
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
  // ��Զ�̻�ȡ
  // <li><a target="_blank" href="http://quote.eastmoney.com/sz000510.html">�½�·(000510)</a></li>
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

