unit StockDaylineUnit;

//http://push2his.eastmoney.com/api/qt/stock/fflow/daykline/get?lmt=2&secid=0.300033&fields1=f1,f2,f3,f7&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61,f62,f63,f64,f65&ut=b2884a393a59ad64002292a3e90d46a5

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, FireDAC.Comp.Client, System.Generics.Collections,
  uRestClientServiceUnit, StockBaseUnit;

type
  TDayline = record
    HDDATE: string;         // ����
    SCODE: string;         // ��Ʊ����
    SNAME: string;         // ��Ʊ����
    CLOSEPRICE: Double;   // �������̼�
    ZDF: Double;          // �����Ƿ�
    MAININFLOW: Double;   // �������뾻��
    MAININFLOWPRESENT: Double;   // �������뾻��ռ��
    SUPERINFLOW: Double;   // �������뾻��
    SUPERINFLOWPRESENT: Double;   // �������뾻��ռ��
    LARGEINFLOW: Double;   // �����뾻��
    LARGEFLOWPRESENT: Double;   // �����뾻��ռ��
    MEDIUMINFLOW: Double;   // �е����뾻��
    MEDIUMINFLOWPRESENT: Double;   // �е����뾻��ռ��
    SMALLINFLOW: Double;   // �е����뾻��
    SMALLINFLOWPRESENT: Double;   // �е����뾻��ռ��
    // 2020-02-25,-492836.0,2014790.0,-1521953.0,-492836.0,0.0,-1.31,5.34,-4.04,-1.31,0.00,6.66,-1.04,0.00,0.00
  end;


  TStockDayline= class(TStockBase)
  private
    function DoGetDate(StockCode: string): TDateTime;
    procedure DoGetDayline(StatusCode:Integer; StatusText:String; Content:String);
    function DoDecodeDayline(JSONStr: string): TDayline;
    procedure DoSaveDayline(HSGTHDSTA: TDayline);
  protected
    procedure DoGetStockByCode(REST: TRESTClientService; StockCode: string); override;
    function DoCheckDate(StockCode: string): Boolean; override;
  end;

implementation

uses
  REST.Types, System.JSON;


{ TStockDayline }

function TStockDayline.DoCheckDate(StockCode: string): Boolean;
begin
  // �����ʽ���Ҫ ���̺󼴿�ץȡ
  SqliteCS.Enter;
  try
    Result := DoGetDate(StockCode) < trunc(Now + 0.4);
  finally
    SqliteCS.Leave;
  end;
end;

function TStockDayline.DoDecodeDayline(JSONStr: string): TDayline;
var
  JSONArray: TJSONArray;
  JSON, Data: TJSONValue;
  ItemText: string;
  Items: TStrings;
  function GetString(JSONValue: TJSONValue; Key: string): string;  overload;
  var
    tmpStr: string;
  begin
    if JSONValue.TryGetValue<string>(Key, tmpStr) then
      Result := tmpStr
    else
      Result := '';
  end;
  function GetDouble(JSONValue: TJSONValue; Key: string): Double; overload;
  var
    tmpDouble: Double;
  begin
    if JSONValue.TryGetValue<Double>(Key, tmpDouble) then
      Result := tmpDouble
    else
      Result := 0;
  end;

  function GetString(Strs: TStrings; Index: Integer): string; overload;
  begin
    Result := '';
    if Index < 0 then exit;
    if Index >= Strs.Count then  exit;

    Result := Strs[Index];
  end;
  function GetDouble(Strs: TStrings; Index: Integer): Double; overload;
  var
    tmpStr: string;
  begin
    tmpStr := GetString(Strs, Index);
    if tmpStr <> '' then
    begin
      try
        Result := StrToFloat(tmpStr);
      except
      end;
    end;
  end;

begin
  Result.HDDATE := '';
  Result.SCODE := '';

  JSON := TJSONObject.ParseJSONValue(JSONStr);
  if (JSON <> nil) then
  begin
    try
      if not JSON.TryGetValue('data', Data) then exit;

      Result.SCODE := GetString(Data, 'code');
      Result.SNAME := GetString(Data, 'name');

      if not Data.TryGetValue<TJSONArray>('klines', JSONArray) then exit;
      if JSONArray.Count < 1 then exit;
      ItemText := JSONArray.Items[JSONArray.Count - 1].Value;
      if ItemText = '' then exit;
      Items := TStringList.Create;
      Items.Delimiter := ',';
      Items.DelimitedText := ItemText;

      try
        Result.HDDATE := Getstring(Items, 0);
        Result.CLOSEPRICE := GetDouble(Items, 11);
        Result.ZDF := GetDouble(Items, 12);
        Result.MAININFLOW := GetDouble(Items, 1);
        Result.MAININFLOWPRESENT := GetDouble(Items, 6);
        Result.SUPERINFLOW := GetDouble(Items, 5);
        Result.SUPERINFLOWPRESENT := GetDouble(Items, 10);
        Result.LARGEINFLOW := GetDouble(Items, 4);
        Result.LARGEFLOWPRESENT := GetDouble(Items, 9);
        Result.MEDIUMINFLOW := GetDouble(Items, 3);
        Result.MEDIUMINFLOWPRESENT := GetDouble(Items, 8);
        Result.SMALLINFLOW := GetDouble(Items, 2);
        Result.SMALLINFLOWPRESENT := GetDouble(Items, 7);
      finally
        Items.Free;
      end;
    finally
      JSON.Free;
    end;
  end;

end;

function TStockDayline.DoGetDate(StockCode: string): TDateTime;
var
  sSql: String;
  Date: string;
begin
  Result := 0;
  sSql := 'SELECT MAX(HDDATE) as DATE from stock_dayline where SCODE=''' + StockCode + '''';
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

procedure TStockDayline.DoGetDayline(StatusCode: Integer; StatusText,
  Content: String);
var
  Dayline: TDayline;
begin
 // ��������
 if StatusCode = 200 then
 begin
  Dayline := DoDecodeDayline(Content);
  if (Dayline.HDDATE <> '') and (Dayline.SCODE <> '') then
  begin
    SqliteCS.Enter;
    try
      DoSaveDayline(Dayline);
    finally
      SqliteCS.Leave;
    end;
  end else
    Dayline.SCODE := '';
 end;

end;

procedure TStockDayline.DoGetStockByCode(REST: TRESTClientService;
  StockCode: string);
const
  BASEURL = 'http://push2his.eastmoney.com/api/qt/stock/fflow/daykline/get?lmt=2&secid=%d.%s&fields1=f1,f2,f3,f7&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61,f62,f63,f64,f65&ut=b2884a393a59ad64002292a3e90d46a5';

var
  SubCode: string;
  Market: Integer;
begin
  // ��ȡǰ��λ   ����ǰ��λ �ж��г�
  //000  002 200 300
  //����A�� ��С�� ��ҵ�� ����B�� �������ڹ�Ʊ
  //600 601 603 900 688
  //����A�� ����B��  �ƴ���
  SubCode := StockCode.Substring(0, 3);
  if (SubCode = '000') or (SubCode = '002') or (SubCode = '200') or (SubCode = '300') then
    Market := 0
  else
  if (SubCode = '600') or (SubCode = '601') or (SubCode = '603') or (SubCode = '900') or (SubCode = '688') then
    Market := 1
  else
    exit;

  REST.Client.BaseURL := Format(BASEURL, [Market, StockCode]);
  REST.Client.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36';
  REST.Request.Accept := '*/*';
  REST.Request.AcceptEncoding := 'gzip, deflate';
  REST.Request.Params.AddHeader('Cache-Control', 'no-cache');
  REST.Request.Method := TRESTRequestMethod.rmGET;
  REST.Execute(DoGetDayline);

end;


procedure TStockDayline.DoSaveDayline(HSGTHDSTA: TDayline);
var
  sSql: String;
begin
  sSql := 'INSERT OR REPLACE INTO stock_dayline(HDDATE, SCODE, SNAME, CLOSEPRICE, ZDF'
    +', MAININFLOW, MAININFLOWPRESENT, SUPERINFLOW, SUPERINFLOWPRESENT, LARGEINFLOW, LARGEFLOWPRESENT'
    +', MEDIUMINFLOW, MEDIUMINFLOWPRESENT, SMALLINFLOW, SMALLINFLOWPRESENT) VALUES(';
  sSql := sSql + QuotedStr(HSGTHDSTA.HDDATE) + ',';
  sSql := sSql + QuotedStr(HSGTHDSTA.SCODE) + ',';
  sSql := sSql + QuotedStr(HSGTHDSTA.SNAME) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.CLOSEPRICE) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.ZDF) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.MAININFLOW) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.MAININFLOWPRESENT) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SUPERINFLOW) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SUPERINFLOWPRESENT) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.LARGEINFLOW) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.LARGEFLOWPRESENT) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.MEDIUMINFLOW) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.MEDIUMINFLOWPRESENT) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SMALLINFLOW) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SMALLINFLOW) + ')';
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
