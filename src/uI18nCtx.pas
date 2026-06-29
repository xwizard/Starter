unit uI18nCtx;

interface

uses
  SysUtils,
  uI18n,
  uUtilities;

var
  GI18n: TI18n = nil;

procedure LoadScenarioI18n(const SceneryBaseDir, SceneryId: string);
function TrToken(const S: string): string;

implementation

procedure LoadScenarioI18n(const SceneryBaseDir, SceneryId: string);
begin
  // ZERO zgadywania — jêzyk jest ustawiony wczeœniej
  FreeAndNil(GI18n);
  GI18n := TI18n.Create;

  // Jeœli plik nie istnieje, Load zwróci False — to nas nie obchodzi
  GI18n.Load(SceneryBaseDir, SceneryId, Util.LangStr, '');
end;

function TrToken(const S: string): string;
var
  T: string;
begin
  T := TrimLeft(S);
  if (GI18n <> nil) and (T <> '') and (T[1] = '@') then
    Result := GI18n.T(T)
  else
    Result := S;
end;

end.
