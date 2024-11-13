unit LocalCache4D;

interface

uses
  LocalCache4D.Interfaces,
  System.Generics.Collections;

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
      function GetItem(aItem: string): string; overload;
      function GetItemAsBoolean(aItem: string): Boolean; overload;
      function GetItemAsInteger(aItem: string): Integer; overload;
      function Instance(aValue: string): ILocalCache4D;
      function ListInstances: TDictionary<string, TDictionary<string, string>>;
      function ListItens: TDictionary<string, string>;
      function LoadDatabase(aDabaseName: string = ''): ILocalCache4D;
      function RemoveInstance(aValue: string): ILocalCache4D;
      function RemoveItem(aKey: string): ILocalCache4D;
      function SaveToStorage(aDabaseName: string = ''): ILocalCache4D;
      function SetItem(aKey: string; aValue: Boolean): ILocalCache4D; overload;
      function SetItem(aKey: string; aValue: Integer): ILocalCache4D; overload;
      function SetItem(aKey, aValue: string): ILocalCache4D; overload;
      function TryGetItem(aItem: string; out aResult: Boolean): Boolean; overload;
      function TryGetItem(aItem: string; out aResult: Integer): Boolean; overload;
      function TryGetItem(aItem: string; out aResult: string): Boolean; overload;
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

function TLocalCache4D.GetItem(aItem: string): string;
begin
  if Trim(FInstance) = '' then
    FInstance := 'default';

  Result := FInstanceList.Items[FInstance].Items[aItem];
end;

function TLocalCache4D.GetItemAsBoolean(aItem: string): Boolean;
begin
  Result := StrToBool(GetItem(aItem));
end;

function TLocalCache4D.GetItemAsInteger(aItem: string): Integer;
var
  LItem: string;
begin
  LItem := GetItem(aItem);
  Result := StrToIntDef(LItem, 0);
end;

function TLocalCache4D.Instance(aValue: string): ILocalCache4D;
begin
  Result := Self;
  FInstance := aValue;
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

function TLocalCache4D.LoadDatabase(aDabaseName: string = ''): ILocalCache4D;
var
  i: Integer;
  JSONValue: TJSONObject;
  LFileName: string;
  X: Integer;
begin
  Result := Self;

  if aDabaseName = '' then
    LFileName := ChangeFileExt(ParamStr(0), '.lc4')
  else
    LFileName := aDabaseName;

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

function TLocalCache4D.RemoveInstance(aValue: string): ILocalCache4D;
begin
  Result := Self;
  FInstanceList.Items[aValue].Free;
  FInstanceList.Remove(aValue);
end;

function TLocalCache4D.RemoveItem(aKey: string): ILocalCache4D;
begin
  Result := Self;

  if Trim(FInstance) = '' then
    FInstance := 'default';

  FInstanceList.Items[FInstance].Remove(aKey);
end;

function TLocalCache4D.SaveToStorage(aDabaseName: string = ''): ILocalCache4D;
var
  LFileName: string;
  LJsonFile: TJsonObject;
  StrList: TStringList;
begin
  Result := Self;

  if aDabaseName = '' then
    LFileName := ChangeFileExt(ParamStr(0), '.lc4')
  else
    LFileName := aDabaseName;

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

function TLocalCache4D.SetItem(aKey: string; aValue: Boolean): ILocalCache4D;
begin
  Result := SetItem(aKey, BoolToStr(aValue));
end;

function TLocalCache4D.SetItem(aKey: string; aValue: Integer): ILocalCache4D;
begin
  Result := SetItem(aKey, IntToStr(aValue));
end;

function TLocalCache4D.SetItem(aKey, aValue: string): ILocalCache4D;
begin
  Result := Self;

  if Trim(FInstance) = '' then
    FInstance := 'default';

  if not FInstanceList.ContainsKey(FInstance) then
    FInstanceList.Add(FInstance, TDictionary<string, string>.Create);

  if not FInstanceList.Items[FInstance].TryAdd(aKey, aValue) then
    FInstanceList.Items[FInstance].Items[aKey] := aValue;
end;

function TLocalCache4D.TryGetItem(aItem: string; out aResult: Boolean): Boolean;
var
  LTemp: string;
begin
  Result := TryGetItem(aItem, LTemp);

  if Result then
     aResult := StrToBoolDef(LTemp, False);
end;

function TLocalCache4D.TryGetItem(aItem: string; out aResult: Integer): Boolean;
var
  LTemp: string;
begin
  Result := TryGetItem(aItem, LTemp);

  if Result then
     aResult := StrToIntDef(LTemp, 0);
end;

function TLocalCache4D.TryGetItem(aItem: string; out aResult: string): Boolean;
begin
  Result := False;
  aResult := '';

  if Trim(FInstance) = '' then
    FInstance := 'default';

  if FInstanceList.ContainsKey(FInstance) then
    Result := FInstanceList.Items[FInstance].TryGetValue(aItem, aResult);
end;

initialization
  LocalCache := TLocalCache4D.New;

end.
