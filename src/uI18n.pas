unit uI18n;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  System.IOUtils;

type
  TI18n = class
  private
    FLang: string;
    FSceneryId: string;
    FMap: TDictionary<string, string>;
    function LoadJsonFile(const FileName: string): Boolean;
    procedure LoadJsonObject(const Prefix: string; Obj: TJSONObject);
    class function NormalizeLang(const Lang: string): string; static;
  public
    constructor Create;
    destructor Destroy; override;


    function Load(const BaseDir, SceneryId, Lang: string; const FallbackLang: string = 'en'): Boolean;

    function T(const Key: string): string;

    property Lang: string read FLang;
    property SceneryId: string read FSceneryId;
  end;

implementation

{ TI18n }

constructor TI18n.Create;
begin
  inherited Create;
  FMap := TDictionary<string, string>.Create;
end;

destructor TI18n.Destroy;
begin
  FMap.Free;
  inherited;
end;

class function TI18n.NormalizeLang(const Lang: string): string;
begin
  Result := LowerCase(Trim(Lang));
  if Result = '' then
    Result := 'en';
end;

procedure TI18n.LoadJsonObject(const Prefix: string; Obj: TJSONObject);
var
  Pair: TJSONPair;
  Key, FullKey: string;
  V: TJSONValue;
begin
  for Pair in Obj do
  begin
    Key := Pair.JsonString.Value;
    V := Pair.JsonValue;

    if Prefix = '' then
      FullKey := Key
    else
      FullKey := Prefix + '.' + Key;

    if V is TJSONString then
    begin
      FMap.AddOrSetValue(FullKey, TJSONString(V).Value);
    end
    else if V is TJSONObject then
    begin
      LoadJsonObject(FullKey, TJSONObject(V));
    end
    else if V is TJSONNumber then
    begin
      FMap.AddOrSetValue(FullKey, TJSONNumber(V).ToString);
    end
    else if V is TJSONBool then
    begin
      if TJSONBool(V).AsBoolean then
        FMap.AddOrSetValue(FullKey, 'true')
      else
        FMap.AddOrSetValue(FullKey, 'false');
    end
    else if V is TJSONArray then
    begin
      // future-proof: array handling
    end;
  end;
end;

function TI18n.LoadJsonFile(const FileName: string): Boolean;
var
  S: string;
  Root: TJSONValue;
begin
  Result := False;
  if not FileExists(FileName) then
    Exit;

  S := TFile.ReadAllText(FileName, TEncoding.UTF8);
  Root := TJSONObject.ParseJSONValue(S);
  try
    if Root is TJSONObject then
    begin
      LoadJsonObject('', TJSONObject(Root));
      Result := True;
    end;
  finally
    Root.Free;
  end;
end;

function TI18n.Load(const BaseDir, SceneryId, Lang: string; const FallbackLang: string): Boolean;
var
  L, FB: string;
  FileLang, FileFallback: string;
begin
  Result := False;

  FMap.Clear;
  FSceneryId := SceneryId;
  L := NormalizeLang(Lang);
  FB := NormalizeLang(FallbackLang);
  FLang := L;

  FileLang := IncludeTrailingPathDelimiter(BaseDir) + 'i18n\' + SceneryId + '_' + L + '.json';
  FileFallback := IncludeTrailingPathDelimiter(BaseDir) + 'i18n\' + SceneryId + '_' + FB + '.json';

  if (FB <> '') and LoadJsonFile(FileFallback) then
    Result := True;

  if (L <> FB) and LoadJsonFile(FileLang) then
    Result := True;
end;

function TI18n.T(const Key: string): string;
var
  K: string;
begin
  K := Trim(Key);
  if (K <> '') and (K[1] = '@') then
    Delete(K, 1, 1);

  if not FMap.TryGetValue(K, Result) then
    Result := Key;
end;

end.

