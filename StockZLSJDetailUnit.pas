unit StockZLSJDetailUnit;

// �����ʽ� �ֲ�
// ����	QFII	�籣 ����	 ȯ��	����  �Ȼ���
// http://data.eastmoney.com/zlsj/detail/%s.html

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, FireDAC.Comp.Client, System.Generics.Collections,
  uRestClientServiceUnit, StockBaseUnit;

type
  TZLSJDetail = record
    SCODE: string;     //��Ʊ����
    ShareCnt: Integer; //�ֹɼ���
    ShareNum: Double;  //�ֹ�����(���)
    SharePrice: Double;//�ֹ���ֵ(��Ԫ)
    TabRate: Double;   //�ܹɱ���(%)
    TabProRate: Double;//��ͨ����(%)
  end;

  TStockZLSJDetail = class(TStockBase)
  private
    function DoGetDate(StockCode: string): TDateTime;
    function DoDecodeZLSJDetail(StockCode: string; HTML: string): TZLSJDetail;
    procedure DoSaveZLSJDetail(DateTime: TDateTime; ZLSJDetail: TZLSJDetail);
  protected
    procedure DoGetStockByCode(REST: TRESTClientService; StockCode: string); override;
    function DoCheckDate(StockCode: string): Boolean; override;
  end;

implementation

uses
  REST.Types, System.RegularExpressions;

{ TStockZLSJDetail }

function TStockZLSJDetail.DoCheckDate(StockCode: string): Boolean;
begin
  // �����ʽ���Ҫ ���̺󼴿�ץȡ
  SqliteCS.Enter;
  try
    Result := DoGetDate(StockCode) < trunc(Now + 0.4);
  finally
    SqliteCS.Leave;
  end;
end;

function TStockZLSJDetail.DoDecodeZLSJDetail(StockCode: string; HTML: string): TZLSJDetail;
var
  Pattern, PatternValue: string;
  Match: TMatch;
  Matchs: TMatchCollection;
  function MatchToString(Index: Integer): string;
  begin
    Result := '';
    if Index < 0 then Exit;
    if Index >= Matchs.Count then Exit;
    Result := Matchs.Item[Index].Groups[1].Value;
  end;
  function MatchToFloat(Index: Integer): Double;
  var
    Str: string;
  begin
    Result := 0;
    Str := MatchToString(Index);
    try
      Result := StrToFloat(Str);
    except
    end;
  end;
begin
  Result.SCODE := '';
  Pattern := '\<td\>��������\</td\>\<td\>.*\</td\>';
  PatternValue := '\<td\>(.*?)\</td\>';
  if TRegEx.IsMatch(HTML, Pattern) then
  begin
    Match := TRegEx.Match(HTML, Pattern);
    Matchs := TRegEx.Matches(Match.Groups.Item[0].Value, PatternValue);
    Result.SCODE := StockCode;
    Result.ShareCnt := Trunc(MatchToFloat(1));
    Result.ShareNum := MatchToFloat(2);
    Result.SharePrice := MatchToFloat(3);
    Result.TabRate := MatchToFloat(4);
    Result.TabProRate := MatchToFloat(5);
  end;

end;

function TStockZLSJDetail.DoGetDate(StockCode: string): TDateTime;
var
  sSql: String;
  Date: string;
begin
  Result := 0;
  sSql := 'SELECT MAX(HDDATE) as DATE from stock_zlsjdetail where SCODE=''' + StockCode + '''';
  Connection.Open();
  try
    Query.Close;
    Query.SQL.Clear;
    Query.SQL.Add(sSql);
    Query.Open();

    Query.First;
    Date := Query.FieldByName('DATE').AsString;
    if (Date <> '') then
    begin
      Date := Date.Replace('T', ' ');
      Result := StrToDateTime(Date);
    end;
  finally
    Query.Close;
    Connection.Close;
  end;

end;

procedure TStockZLSJDetail.DoGetStockByCode(REST: TRESTClientService;
  StockCode: string);
const
  BASEURL = 'http://data.eastmoney.com/zlsj/detail/%s.html';
var
  ZLSJDetail: TZLSJDetail;
begin
  REST.Client.BaseURL := Format(BASEURL, [StockCode]);
  REST.Client.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36';
  REST.Request.Accept := '*/*';
  REST.Request.AcceptEncoding := 'gzip, deflate';
  REST.Request.Params.AddHeader('Cache-Control', 'no-cache');
  REST.Request.Method := TRESTRequestMethod.rmGET;
  REST.Execute(nil);
  if REST.Response.StatusCode = 200 then
  begin
    ZLSJDetail := DoDecodeZLSJDetail(StockCode, REST.Response.Content);
    if ZLSJDetail.SCODE <> '' then
    begin
      DoSaveZLSJDetail(Now - 1, ZLSJDetail);
      //DoSaveZLSJDetail(Now, ZLSJDetail);
    end;
  end;

end;


procedure TStockZLSJDetail.DoSaveZLSJDetail(DateTime: TDateTime; ZLSJDetail: TZLSJDetail);
var
  sSql: String;
begin
//    SCODE: string;     //��Ʊ����
//    ShareCnt: Integer; //�ֹɼ���
//    ShareNum: Double;  //�ֹ�����(���)
//    SharePrice: Double;//�ֹ���ֵ(��Ԫ)
//    TabRate: Double;   //�ܹɱ���(%)
//    TabProRate: Double;//��ͨ����(%)
  sSql := 'INSERT OR REPLACE INTO stock_zlsjdetail(HDDATE, SCODE, ShareCnt, ShareNum'
    +', SharePrice, TabRate, TabProRate) VALUES(';
  sSql := sSql + QuotedStr(FormatDateTime('YYYY-MM-DD', DateTime)) + ',';
  sSql := sSql + QuotedStr(ZLSJDetail.SCODE) + ',';
  sSql := sSql + FloatToStr(ZLSJDetail.ShareCnt) + ',';
  sSql := sSql + FloatToStr(ZLSJDetail.ShareNum) + ',';
  sSql := sSql + FloatToStr(ZLSJDetail.SharePrice) + ',';
  sSql := sSql + FloatToStr(ZLSJDetail.TabRate) + ',';
  sSql := sSql + FloatToStr(ZLSJDetail.TabProRate) + ')';
  Connection.Open();
  try
    Query.Close;
    Query.SQL.Clear;
    Query.SQL.Add(sSql);
    Query.ExecSQL;
  finally
    Query.Close;
    Connection.Close;
  end;

end;

end.
