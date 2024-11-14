unit LocalCache4D.Interfaces;

interface

uses
  System.Generics.Collections;

type
  ILocalCache4D = interface(IInterface)
    ['{1E1C947B-3DD3-4693-9D20-7C06D2AA0DCF}']
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

implementation

end.
