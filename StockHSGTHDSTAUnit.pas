unit StockHSGTHDSTAUnit;

// 获取沪深港（北上资金流向信息）
// 接口 http://dcfm.eastmoney.com//em_mutisvcexpandinterface/api/js/get?type=HSGTHDSTA&token=70f12f2f4f091e459a279469fe49eca5&filter=(SCODE='600105')&st={sortType}&sr={sortRule}&p={page}&ps={pageSize}&js=var {jsname}={pages:(tp),data:(x)}{param}
// 例子 http://dcfm.eastmoney.com//em_mutisvcexpandinterface/api/js/get?type=HSGTHDSTA&token=70f12f2f4f091e459a279469fe49eca5&filter=(SCODE=%27600105%27)&st=HDDATE&sr=-1&p=1&ps=1&js=var%20HhpNNGBj={pages:(tp),data:(x)}&rt=52753326

// 获取机构资金流向
// http://push2his.eastmoney.com/api/qt/stock/fflow/daykline/get?lmt=1&klt=101&secid=1.600273&fields1=f1,f2,f3,f7&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61,f62,f63,f64,f65&ut=b2884a393a59ad64002292a3e90d46a5&_=1582630526494
interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, FireDAC.Comp.Client, System.Generics.Collections,
  uRestClientServiceUnit, StockBaseUnit;

  (*
    {
      "HDDATE":"2020-02-24T00:00:00",
      "HKCODE":"1000002329",
      "SCODE":"600105",
      "SNAME":"永鼎股份",
      "SHAREHOLDSUM":17932479.0,
      "SHARESRATE":1.44,
      "CLOSEPRICE":5.1,
      "ZDF":9.9138,
      "SHAREHOLDPRICE":91455642.899999976,
      "SHAREHOLDPRICEONE":6667164.3399999738,
      "SHAREHOLDPRICEFIVE":19377631.949999973,
      "SHAREHOLDPRICETEN":45549896.899999976,
      "MARKET":"001",
      "ShareHoldSumChg":-340900.0,
      "Zb":0.014481385895892904,
      "Zzb":0.014398423409932847
      }
  *)

type

  THSGTHDSTA = record
    HDDATE: string;    // 日期
    HKCODE: string;    // HK代码
    SCODE: string;     // 股票代码
    SNAME: string;     // 股票名称
    SHAREHOLDSUM: Double; // 股份持有金额,
    SHARESRATE: Double;   // 股份持有比例
    CLOSEPRICE: Double;   // 当日收盘价
    ZDF: Double;          // 当日涨幅
    SHAREHOLDPRICE: Double; //持股市值
    SHAREHOLDPRICEONE: Double;  // 1日变化
    SHAREHOLDPRICEFIVE: Double; // 5日变化
    SHAREHOLDPRICETEN: Double;  // 10日变化
    MARKET: string;
    ShareHoldSumChg: Double;    //持股总额变动
    Zb: Double;
    Zzb: Double;
  end;

  TStockHSGTHDSTA = class(TStockBase)
  private
    function DoGetDate(StockCode: string): TDateTime;
    procedure DoGetHSGTHDSTA(StatusCode:Integer; StatusText:String; Content:String);
    function DoDecodeHSGTHDSTA(JSONStr: string): THSGTHDSTA;
    procedure DoSaveHSGTHDSTA(HSGTHDSTA: THSGTHDSTA);
  protected
    procedure DoGetStockByCode(REST: TRESTClientService; StockCode: string); override;
    function DoCheckDate(StockCode: string): Boolean; override;
  end;


implementation

uses
  REST.Types, System.JSON;



{ TStockHSGTHDSTA }

function TStockHSGTHDSTA.DoCheckDate(StockCode: string): Boolean;
begin
  // 北上资金需要 第二天凌晨才能抓取
  SqliteCS.Enter;
  try
    Result := DoGetDate(StockCode) < trunc(Now - 1.3);
  finally
    SqliteCS.Leave;
  end;

end;

function TStockHSGTHDSTA.DoDecodeHSGTHDSTA(JSONStr: string): THSGTHDSTA;
var
  JSONArray: TJSONArray;
  JSON: TJSONValue;
  function GetString(JSONValue: TJSONValue; Key: string): string;
  var
    tmpStr: string;
  begin
    if JSONValue.TryGetValue<string>(Key, tmpStr) then
      Result := tmpStr
    else
      Result := '';
  end;
  function GetDouble(JSONValue: TJSONValue; Key: string): Double;
  var
    tmpDouble: Double;
  begin
    if JSONValue.TryGetValue<Double>(Key, tmpDouble) then
      Result := tmpDouble
    else
      Result := 0;
  end;
begin
  Result.HDDATE := '';
  Result.SCODE := '';
  JSONArray := TJSONObject.ParseJSONValue(JSONStr) as TJSONArray;
  if (JSONArray <> nil) then
  begin
    try
      if JSONArray.Count < 1 then exit;
      JSON := JSONArray.Items[0];

      Result.HDDATE := GetString(JSON, 'HDDATE');
      Result.HKCODE := GetString(JSON, 'HKCODE');
      Result.SCODE := GetString(JSON, 'SCODE');
      Result.SNAME := GetString(JSON, 'SNAME');
      Result.SHAREHOLDSUM := GetDouble(JSON, 'SHAREHOLDSUM');
      Result.SHARESRATE := GetDouble(JSON, 'SHARESRATE');
      Result.CLOSEPRICE := GetDouble(JSON, 'CLOSEPRICE');
      Result.ZDF := GetDouble(JSON, 'ZDF');
      Result.SHAREHOLDPRICE := GetDouble(JSON, 'SHAREHOLDPRICE');
      Result.SHAREHOLDPRICEONE := GetDouble(JSON, 'SHAREHOLDPRICEONE');
      Result.SHAREHOLDPRICEFIVE := GetDouble(JSON, 'SHAREHOLDPRICEFIVE');
      Result.SHAREHOLDPRICETEN := GetDouble(JSON, 'SHAREHOLDPRICETEN');
      Result.MARKET := GetString(JSON, 'MARKET');
      Result.ShareHoldSumChg := GetDouble(JSON, 'ShareHoldSumChg');
      Result.Zb := GetDouble(JSON, 'Zb');
      Result.Zzb := GetDouble(JSON, 'Zzb');
    finally
      JSONArray.Free;
    end;
  end;

end;

function TStockHSGTHDSTA.DoGetDate(StockCode: string): TDateTime;
var
  sSql: String;
  Date: string;
begin
  Result := 0;
  sSql := 'SELECT MAX(HDDATE) as DATE from stock_hsgthdsta where SCODE=''' + StockCode + '''';
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

procedure TStockHSGTHDSTA.DoGetHSGTHDSTA(StatusCode: Integer; StatusText,
  Content: String);
var
  JSONStr: string;
  HSGTHDSTA: THSGTHDSTA;
begin
  // 解析数据
  if StatusCode = 200 then
  begin
    // 去掉头
    JSONStr := Content.Replace('var HhpNNGBj=', '', [rfReplaceAll]);
    HSGTHDSTA := DoDecodeHSGTHDSTA(JSONStr);
    if (HSGTHDSTA.HDDATE <> '') and (HSGTHDSTA.SCODE <> '') then
    begin
      SqliteCS.Enter;
      try
        DoSaveHSGTHDSTA(HSGTHDSTA);
      finally
        SqliteCS.Leave;
      end;
    end;
  end;

end;


procedure TStockHSGTHDSTA.DoSaveHSGTHDSTA(HSGTHDSTA: THSGTHDSTA);
var
  sSql: String;
begin
  sSql := 'INSERT OR REPLACE INTO stock_hsgthdsta(HDDATE, HKCODE, SCODE, SNAME, SHAREHOLDSUM, SHARESRATE'
    +', CLOSEPRICE, ZDF, SHAREHOLDPRICE, SHAREHOLDPRICEONE, SHAREHOLDPRICEFIVE, SHAREHOLDPRICETEN, MARKET'
    +', ShareHoldSumChg, Zb, Zzb) VALUES(';
  sSql := sSql + QuotedStr(HSGTHDSTA.HDDATE) + ',';
  sSql := sSql + QuotedStr(HSGTHDSTA.HKCODE) + ',';
  sSql := sSql + QuotedStr(HSGTHDSTA.SCODE) + ',';
  sSql := sSql + QuotedStr(HSGTHDSTA.SNAME) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SHAREHOLDSUM) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SHARESRATE) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.CLOSEPRICE) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.ZDF) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SHAREHOLDPRICE) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SHAREHOLDPRICEONE) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SHAREHOLDPRICEFIVE) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.SHAREHOLDPRICETEN) + ',';
  sSql := sSql + QuotedStr(HSGTHDSTA.MARKET) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.ShareHoldSumChg) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.Zb) + ',';
  sSql := sSql + FloatToStr(HSGTHDSTA.Zzb) + ')';
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



procedure TStockHSGTHDSTA.DoGetStockByCode(REST: TRESTClientService;
  StockCode: string);
const
  BASEURL = 'http://dcfm.eastmoney.com//em_mutisvcexpandinterface/api/js/get?type=HSGTHDSTA&token=70f12f2f4f091e459a279469fe49eca5&filter=(SCODE=''%s'')&st=HDDATE&sr=-1&p=1&ps=1';
begin

//  while(trunc(Now - 0.3) <> trunc(Now)) do
//  begin
//    Sleep(1000 * 60);
//  end;

  REST.Client.BaseURL := Format(BASEURL, [StockCode]);
  REST.Client.UserAgent := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36';
  REST.Request.Accept := '*/*';
  REST.Request.AcceptEncoding := 'gzip, deflate';
  REST.Request.Params.AddHeader('Cache-Control', 'no-cache');
  REST.Request.Method := TRESTRequestMethod.rmGET;
  REST.Execute(DoGetHSGTHDSTA);

end;



end.


