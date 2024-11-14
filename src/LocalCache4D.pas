unit LocalCache4D;

interface

uses
  System.Generics.Collections,
  LocalCache4D.Interfaces;

type
  TLocalCache4D = class(TInterfacedObject, ILocalCache4D)
  private
      FCacheList: TDictionary<string, string>;
      FInstance: string;
      FInstanceList: TDictionary<string, TDictionary<string, string>>;
  public
      constructor Create;
      destructor Destroy; override;
      class function New : ILocalCache4D;
      function GetItem(const Item: string): string; overload;
      function GetItemAsBoolean(const Item: string): Boolean; overload;
      function GetItemAsInteger(const Item: string): Int32; overload;
      function Instance(const Value: string): ILocalCache4D;
      function ListInstances: TDictionary<string, TDictionary<string, string>>;
      function ListItens: TDictionary<string, string>;
      function LoadDatabase(const DabaseName: string = ''): ILocalCache4D;
      function RemoveInstance(const Value: string): ILocalCache4D;
      function RemoveItem(const Key: string): ILocalCache4D;
      function SaveToStorage(const DabaseName: string = ''): ILocalCache4D;
      function SetItem(const Key: string; const Value: Boolean): ILocalCache4D; overload;
      function SetItem(const Key: string; const Value: Int32): ILocalCache4D; overload;
      function SetItem(const Key, Value: string): ILocalCache4D; overload;
      function TryGetItem(const Key: string; out Value: Boolean): Boolean; overload;
      function TryGetItem(const Key: string; out Value: Int32): Boolean; overload;
      function TryGetItem(const Key: string; out Value: string): Boolean; overload;
  end;

var
  LocalCache : ILocalCache4D;

implementation

uses
  System.IniFiles,
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.IOUtils, LocalCache4D.Compression;

const
  C_SECTION = 'LOCALCACHEDATABASE';


constructor TLocalCache4D.Create;
begin
  FCacheList := TDictionary<string, string>.Create;
  FInstanceList := TDictionary<string, TDictionary<string, string>>.Create;
  FInstance := 'default';
end;

destructor TLocalCache4D.Destroy;
begin
  FCacheList.DisposeOf;

  for var ListCache in FInstanceList do
    ListCache.Value.DisposeOf;

  FInstanceList.DisposeOf;

  inherited;
end;

class function TLocalCache4D.New: ILocalCache4D;
begin
  if not Assigned(LocalCache) then
    LocalCache := Self.Create;

  Result := LocalCache;
end;

function TLocalCache4D.GetItem(const Item: string): string;
begin
  if Trim(FInstance) = '' then
    FInstance := 'default';

  Result := FInstanceList.Items[FInstance].Items[Item];
end;

function TLocalCache4D.GetItemAsBoolean(const Item: string): Boolean;
begin
  Result := StrToBool(GetItem(Item));
end;

function TLocalCache4D.GetItemAsInteger(const Item: string): Int32;
var
  LItem: string;
begin
  LItem := GetItem(Item);
  Result := StrToIntDef(LItem, 0);
end;

function TLocalCache4D.Instance(const Value: string): ILocalCache4D;
begin
  Result := Self;
  FInstance := Value;
end;

function TLocalCache4D.ListInstances: TDictionary<string, TDictionary<string, string>>;
begin
  Result := FInstanceList;
end;

function TLocalCache4D.ListItens: TDictionary<string, string>;
begin
  if Trim(FInstance) = '' then
    FInstance := 'default';

  Result := FInstanceList.Items[FInstance];
end;

function TLocalCache4D.LoadDatabase(const DabaseName: string = ''): ILocalCache4D;
var
  i: Integer;
  JSONValue: TJSONObject;
  LFileName: string;
  X: Integer;
begin
  Result := Self;

  if DabaseName = '' then
    LFileName := ChangeFileExt(ParamStr(0), '.lc4')
  else
    LFileName := DabaseName;

  if FileExists(LFileName) then
  begin
    JSONValue :=  TJSONObject.ParseJSONValue(TLocalCache4DCompreesion.Decode(TFile.ReadAllText(LFileName))) as TJSONObject;
    try
       for i := 0 to Pred(JSONValue.Count) do
       begin
         if not FInstanceList.ContainsKey(JSONValue.Pairs[i].JsonString.Value) then
            FInstanceList.Add(JSONValue.Pairs[i].JsonString.Value, TDictionary<string, string>.Create);

         for X := 0 to Pred((JSONValue.Pairs[i].JsonValue as TJsonObject).Count) do
         begin
           if not FInstanceList.Items[JSONValue.Pairs[i].JsonString.Value].ContainsKey((JSONValue.Pairs[i].JsonValue as TJsonObject).Pairs[X].JsonString.Value) then
            FInstanceList
              .Items[JSONValue.Pairs[i].JsonString.Value]
                .Add((JSONValue.Pairs[i].JsonValue as TJsonObject).Pairs[X].JsonString.Value,
                     (JSONValue.Pairs[i].JsonValue as TJsonObject).Pairs[X].JsonValue.Value);
         end;
       end;
    finally
      JSONValue.DisposeOf;
    end;
  end;
end;

function TLocalCache4D.RemoveInstance(const Value: string): ILocalCache4D;
begin
  Result := Self;
  FInstanceList.Items[Value].Free;
  FInstanceList.Remove(Value);
end;

function TLocalCache4D.RemoveItem(const Key: string): ILocalCache4D;
begin
  Result := Self;

  if Trim(FInstance) = '' then
    FInstance := 'default';

  FInstanceList.Items[FInstance].Remove(Key);
end;

function TLocalCache4D.SaveToStorage(const DabaseName: string = ''): ILocalCache4D;
var
  LFileName: string;
  LJsonFile: TJsonObject;
  StrList: TStringList;
begin
  Result := Self;

  if DabaseName = '' then
    LFileName := ChangeFileExt(ParamStr(0), '.lc4')
  else
    LFileName := DabaseName;

  if FileExists(LFileName) then
    DeleteFile(LFileName);

  LJsonFile := TJSONObject.Create;
  try
    for var Instances in FInstanceList do
    begin
      LJsonFile.AddPair(Instances.Key, TJSONObject.Create);

      for var CacheList in Instances.Value do
        LJsonFile.GetValue<TJsonObject>(Instances.Key).AddPair(CacheList.Key, CacheList.Value);
    end;

    StrList := TStringList.Create;
    try
      StrList.Add(TLocalCache4DCompreesion.Encode(LJsonFile.ToString));
      StrList.SaveToFile(LFileName, TEncoding.Unicode);
    finally
      StrList.DisposeOf;
    end;

  finally
    LJsonFile.DisposeOf;
  end;
end;

function TLocalCache4D.SetItem(const Key: string; const Value: Boolean): ILocalCache4D;
begin
  Result := SetItem(Key, BoolToStr(Value));
end;

function TLocalCache4D.SetItem(const Key: string; const Value: Int32): ILocalCache4D;
begin
  Result := SetItem(Key, IntToStr(Value));
end;

function TLocalCache4D.SetItem(const Key, Value: string): ILocalCache4D;
begin
  Result := Self;

  if Trim(FInstance) = '' then
    FInstance := 'default';

  if not FInstanceList.ContainsKey(FInstance) then
    FInstanceList.Add(FInstance, TDictionary<string, string>.Create);

  if not FInstanceList.Items[FInstance].TryAdd(Key, Value) then
    FInstanceList.Items[FInstance].Items[Key] := Value;
end;

function TLocalCache4D.TryGetItem(const Key: string; out Value: Boolean): Boolean;
var
  LTemp: string;
begin
  Result := TryGetItem(Key, LTemp);

  if Result then
     Value := StrToBoolDef(LTemp, False);
end;

function TLocalCache4D.TryGetItem(const Key: string; out Value: Int32): Boolean;
var
  LTemp: string;
begin
  Result := TryGetItem(Key, LTemp);

  if Result then
     Value := StrToIntDef(LTemp, 0);
end;

function TLocalCache4D.TryGetItem(const Key: string; out Value: string): Boolean;
begin
  Result := False;
  Value := '';

  if Trim(FInstance) = '' then
    FInstance := 'default';

  if FInstanceList.ContainsKey(FInstance) then
    Result := FInstanceList.Items[FInstance].TryGetValue(Key, Value);
end;

initialization
  LocalCache := TLocalCache4D.New;

end.
