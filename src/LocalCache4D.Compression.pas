unit LocalCache4D.Compression;

interface

uses
  System.ZLib;

type
  TLocalCache4DCompreesion = class
  private
      class function Base256Decode(const Text: string): string;
      class function Base256Encode(const Text: string): string;
      class function ZCompressString(const Text: string): string;
      class function ZDecompressString(const Text: string): string;
  public
      class function Decode(const Text: string): string;
      class function Encode(const Text: string): string;
  end;

implementation

uses
  System.Classes,
  System.NetEncoding;

class function TLocalCache4DCompreesion.Base256Decode(const Text: string): string;
begin
  Result := TNetEncoding.Base64.Decode(
              TNetEncoding.Base64.Decode(
                TNetEncoding.Base64.Decode(
                  TNetEncoding.Base64.Decode(Text))));
end;

class function TLocalCache4DCompreesion.Base256Encode(const Text: string): string;
begin
  Result := TNetEncoding.Base64.Encode(
              TNetEncoding.Base64.Encode(
                TNetEncoding.Base64.Encode(
                  TNetEncoding.Base64.Encode(Text))));
end;

class function TLocalCache4DCompreesion.Decode(const Text: string): string;
begin
  Result := TLocalCache4DCompreesion.Base256Decode(TLocalCache4DCompreesion.ZDecompressString(Text));
end;

class function TLocalCache4DCompreesion.Encode(const Text: string): string;
begin
  Result := TLocalCache4DCompreesion.ZCompressString(TLocalCache4DCompreesion.Base256Encode(Text));
end;

class function TLocalCache4DCompreesion.ZCompressString(const Text: string): string;
var
  strInput: TStringStream;
  strOutput: TStringStream;
  Zipper: TZCompressionStream;
begin
  Result := '';
  strInput := TStringStream.Create(Text);
  strOutput := TStringStream.Create;
  try
    Zipper := TZCompressionStream.Create(strOutput);
    try
      Zipper.CopyFrom(strInput, strInput.Size);
    finally
      Zipper.Free;
    end;

    Result:= strOutput.DataString;
  finally
    strInput.Free;
    strOutput.Free;
  end;
end;

class function TLocalCache4DCompreesion.ZDecompressString(const Text: string): string;
var
  strInput: TStringStream;
  strOutput: TStringStream;
  Unzipper: TZDecompressionStream;
begin
  Result := '';
  strInput := TStringStream.Create(Text);
  strOutput := TStringStream.Create;
  try
    Unzipper:= TZDecompressionStream.Create(strInput);
    try
      strOutput.CopyFrom(Unzipper, Unzipper.Size);
    finally
      Unzipper.Free;
    end;

    Result := strOutput.DataString;
  finally
    strInput.Free;
    strOutput.Free;
  end;
end;

end.
