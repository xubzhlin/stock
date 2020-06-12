unit StockBaseUnit;
// 获取数据基类

// DoGetStockByCode 中 请求远程数据


interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, FireDAC.Comp.Client, System.Generics.Collections,
  uRestClientServiceUnit;

type
  TStockBase = class;

  TGetDataThread = class(TThread)
  private
    [weak]FOwner: TStockBase;
    FREST: TRESTClientService;
  protected
    procedure Execute; override;
  public
    constructor Create(Owner: TStockBase);
    destructor Destroy; override;
  end;

  TStockBase = class(TObject)
  private
    FDate: TDateTime;
    FSqliteCS: TCriticalSection;
    FListCS: TCriticalSection;
    FStockList: TStrings;
    FDConnection: TFDConnection;
    FDQuery: TFDQuery;
    FThreadList: TList<TGetDataThread>;
    FOnRefreshStatus: TNotifyEvent;
    FOnFinished: TNotifyEvent;
  private
    procedure DoThreadFinished(Thread: TGetDataThread);
    function DoGetStockCode: string;

  protected
    property SqliteCS: TCriticalSection read FSqliteCS;
    property ListCS: TCriticalSection read FListCS;
    property Connection: TFDConnection read FDConnection;
    property Query: TFDQuery read FDQuery;

    procedure DoGetStockByCode(REST: TRESTClientService; StockCode: string); virtual; abstract;
    function DoCheckDate(StockCode: string): Boolean; virtual; abstract;
  public
    constructor Create(Database: string);
    destructor Destroy; override;
    procedure Start(NumberofThread: Integer; Stocks: TStrings);
    property StockList: TStrings read FStockList;
    property OnRefreshStatus: TNotifyEvent read FOnRefreshStatus write FOnRefreshStatus;
    property OnFinished: TNotifyEvent read FOnFinished write FOnFinished;


  end;



implementation

{ TGetDataThread }

constructor TGetDataThread.Create(Owner: TStockBase);
begin
  inherited Create(False);
  FOwner := Owner;
  FreeOnTerminate := True;
  FREST := TRESTClientService.Create(nil);
end;

destructor TGetDataThread.Destroy;
begin
  FOwner.DoThreadFinished(Self);
  FREST.Free;
  FOwner:= nil;
  inherited;
end;

procedure TGetDataThread.Execute;
var
  StockCode: string;
  Date: TDateTime;
  NeedSleep: Boolean;
begin

  while not Terminated do
  begin
    NeedSleep := False;
    // 从列表里面取一个
    StockCode := FOwner.DoGetStockCode;
    // 需要到凌晨才能采集到数据
    if FOwner.DoCheckDate(StockCode) then
    begin
      if StockCode <> '' then
      begin
        NeedSleep := True;
        FOwner.DoGetStockByCode(FREST, StockCode);
      end
      else
        Break;
    end;
    if Assigned(FOwner.FOnRefreshStatus) then
      FOwner.FOnRefreshStatus(FOwner);
    if NeedSleep then
      Sleep(500);
  end;

end;

{ TStockBase }

constructor TStockBase.Create(Database: string);
begin
  inherited Create;

  FStockList := TStringList.Create;
  FThreadList := TList<TGetDataThread>.Create;

  FDConnection := TFDConnection.Create(nil);
  FDQuery := TFDQuery.Create(nil);

  FDConnection.DriverName := 'SQLite';
  FDConnection.Params.Database := Database;
  FDQuery.Connection := FDConnection;

  FSqliteCS := TCriticalSection.Create;
  FListCS := TCriticalSection.Create;
end;

destructor TStockBase.Destroy;
var
  i: Integer;
begin

  for i := 0 to FThreadList.Count - 1 do
    FThreadList[i].Terminate;

  while FThreadList.Count <> 0 do
    Sleep(100);

  FDQuery.Close;
  FDQuery.Free;

  FDConnection.Close;
  FDConnection.Close;

  FSqliteCS.Free;
  FListCS.Free;

  FStockList.Free;
  inherited;
end;

function TStockBase.DoGetStockCode: string;
var
  Index: Integer;
begin
  FListCS.Enter;
  try
    if FStockList.Count > 0 then
    begin
      // 随机一个
      Index := Random(FStockList.Count);
      Result := FStockList[Index];
      FStockList.Delete(Index);
    end else
      Result := '';
  finally
    FListCS.Leave;
  end;

end;

procedure TStockBase.DoThreadFinished(Thread: TGetDataThread);
var
  i: Integer;
begin
  FListCS.Enter;
  try
    for I := 0 to FThreadList.Count - 1 do
    begin
      if(FThreadList[i] = Thread) then
        FThreadList.Delete(i);
    end;
    if FThreadList.Count = 0 then
    begin
      if Assigned(FOnFinished) then
        FOnFinished(Self);
    end;
  finally
    FListCS.Leave;
  end;

end;


procedure TStockBase.Start(NumberofThread: Integer; Stocks: TStrings);
var
  i: Integer;
  Thread: TGetDataThread;
begin
  //if (Now - FDate) < 2 then exit;

  FListCS.Enter;
  try
    FStockList.AddStrings(Stocks);

    if FThreadList.Count < NumberofThread then
    begin
      for i := FThreadList.Count to NumberofThread - 1 do
      begin
        Thread := TGetDataThread.Create(Self);
        FThreadList.Add(Thread);
      end;
    end else
    if FThreadList.Count > NumberofThread then
    begin
      for i := FThreadList.Count - 1 downto NumberofThread do
      begin
        FThreadList[i].Terminate;
      end;
    end;
  finally
    FListCS.Leave;
  end;

end;

initialization
  FormatSettings.LongDateFormat := 'yyyy-MM-dd';
  FormatSettings.ShortDateFormat := 'yyyy-MM-dd';
  FormatSettings.LongTimeFormat := 'hh:nn:ss';
  FormatSettings.ShortTimeFormat := 'hh:nn:ss';
  FormatSettings.DateSeparator := '-';
  FormatSettings.timeSeparator := ':';

end.
