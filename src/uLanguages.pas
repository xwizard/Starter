{
  Starter
  Copyright (C) 2019-2020 Damian Skrzek (szczawik)
  This file is part of Starter.

  Starter is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.

  Starter is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Starter.  If not, see <http://www.gnu.org/licenses/>.
}

unit uLanguages;

interface

uses VCL.Forms;

type
  TLabels = (TEXT_CAR_NO,TEXT_AI_TRAIN,TEXT_KEY,TEXT_KEY_DESC,
      TEXT_WRONG_CONNECTION,TEXT_TRAIN_NAME,TEXT_TRAIN_NAME_CHANGE,
      TEXT_SAVE_PRESET,TEXT_SET_PRESET_NAME,TEXT_RANDOM_TEX_EXCEPT,

      TEXT_LOAD_SETTINGS,TEXT_LOAD_SCENERIES,TEXT_START_NO_EXE,
      TEXT_START_NO_SCN,TEXT_START_GO_SEL_TRAIN,TEXT_START_SEL_TRAIN,
      TEXT_START_SEL_VEHICLE,TEXT_START_NO_STAFF,TEXT_NO_VEHICLES,

      TEXT_NOT_FOUND_EXE,TEXT_INTERNAL_ERROR,TEXT_DEPO_LOAD_EXCEPT,TEXT_SCN_MINI_LOAD_FAULT,

      TEXT_TEX_NO_FILE,TEXT_TEX_NO_MODEL,TEXT_TEX_NO_PHYSICS,TEXT_TEX_NO_MULTIMEDIA,

      TEXT_LOAD_SCN,TEXT_PARSE_SCN,

      TEXT_NO_FILE,TEXT_NO_MODEL,TEXT_NO_PHYSICS,TEXT_NO_MULTIMEDIA,TEXT_CHECK_VALUE_FAULT,
      TEXT_CHECK_PHYSICS_FILE,TEXT_UNSUPPORTED_LOAD,

      TEXT_DEPO_PARSE_FAULT,TEXT_DEPO_SAVE_FAULT,TEXT_PHYSICS_PARSE_FAULT,

      TEXT_LOAD_SETTINGS_FAULT,TEXT_PARAMETER,TEXT_INVALID_VALUE,TEXT_FAULT_DETAIL,
      TEXT_ALGORITHM_FAULT,TEXT_SET_CHANGED, TEXT_FILE_NOT_FOUND, TEXT_LOAD_MINI_FAULT,
      TEXT_REMOVE_OLD_VER_FAULT,
      TEXT_YES,TEXT_NO,TEXT_NO_DIR,TEXT_NO_WEIGHTS,TEXT_NO_SCN,TEXT_NO_FOUND_VEHICLES,
      TEXT_NO_EXE,TEXT_ERRORS,TEXT_PROGRAM_FILES,TEXT_CREATE_FILE_FAULT,TEXT_LOGO_FAULT,
      TEXT_CURRENT_VERSION,TEXT_NEWER_VERSION_ASK,TEXT_UPDATE_FAULT,TEXT_UPDATE_FAULT_EXT,
      TEXT_UPDATED_PROGRAM,TEXT_UPDATING, TEXT_OPERATION_FAULT, TEXT_REMOVE_ALL_VEHICLES,
      TEXT_LOADING_DEPOT,TEXT_LOADING_PHYSICS,TEXT_LOADING_SCN,TEXT_LOADING_WEIGHTS,
      TEXT_LOAD_MODELS_FAULT,TEXT_LOAD_SCN_FAULT,TEXT_PARSE_TRAIN_FAULT,TEXT_VEHICLE_FAULT,
      TEXT_LOAD_WEIGHTS_FAULT,TEXT_VEHICLE_SYNTAX_FAULT,TEXT_VEHICLE_PARSE_FAULT,TEXT_STRINT_SYNTAX_FAULT,
      TEXT_STRFLOAT_SYNTAX_FAULT,TEXT_CONFIG_PARSE_FAULT,TEXT_ATMO_PARSE_FAULT,
      TEXT_PARSE_SCN_FAULT,TEXT_PARSE_TRAINSET_FAULT,TEXT_PARSE_TEXTURES_FAULT,
      TEXT_PARSE_TEX_DESC_FAULT,TEXT_PARSE_PHYSICS_FAULT,
      TEXT_RENDERER_CHANGE,
      TEXT_NAMEISINRULE,TEXT_REMOVERULEELEMENT,TEXT_SAVERULE,TEXT_NUMBEROFPROCESSORS,
      TEXT_LOADRULESFAULT,TEXT_FINDSIMILARTEXFAULT,TEXT_MULTIPLEASSIGNFAULT,
      TEXT_LP,TEXT_TEX,TEXT_MINI,TEXT_PREVIEW,TEXT_MODEL,TEXT_OPERATOR,TEXT_STATION,
      TEXT_REVDATE,TEXT_AUTHOR,TEXT_PHOTO,TEXT_CATEGORY,TEXT_PATH,
      TEXT_LOADMODELS_FAULT,TEXT_LOADSCENERY_FAULT,TEXT_PARSETRAIN_FAULT,TEXT_VEHICLE_INVALID,
      TEXT_LOADWEIGHTS_FAULT,TEXT_VEHICLESYNTAXFAULT,TEXT_VEHICLEPARSE_FAULT,
      TEXT_PARSING_FAULT,TEXT_PARSESECTIONFAULT,
      TEXT_PARSEFAULTDETAIL, TEXT_PARSETRAINSETFAULT,TEXT_PARSETEXMODELFAULT,
      TEXT_PARSETEXTURESFAULT,TEXT_PARSE_TEXDESCFAULT,TEXT_PARSEPHYSICSFAULT);

      LabelsSet = set of TLabels;

  TLang = class
  var
      LabelsArray : array[0..124,0..1] of String;
  private
    class procedure ChangeLabels(const LangStr: string); static;
    procedure FillLangLabels;
    //class procedure SaveLanguage(Form:TForm;const Lang:string); static;
  public
    function LabelStr(const ID: TLabels): string; overload;
    function LabelStr(const ID: TLabels; const Args: array of const): string; overload;
    procedure StringsLoad;
    class function LoadLanguages:string;
    class procedure ChangeLoads(const LangStr: string); static;
    class procedure ChangeLanguage(Form:TForm;const LangStr: string); overload;
    class procedure ChangeIniLanguage(const LangStr: string);

  end;

var
  Lang  : TLang;

implementation

uses System.SysUtils, uMain, System.Classes, StrUtils,
     VCL.StdCtrls, VCL.ActnList, VCL.ComCtrls, VCL.CheckLst, ExtCtrls, typinfo, uUtilities, uData, uStructures, RTTI;

{ TLanguages }

procedure TLang.FillLangLabels;
var
  i : Integer;
begin
  for i := 0 to High(LabelsArray) do
    LabelsArray[i,0] := TRttiEnumerationType.GetName<TLabels>(TLabels(i));
end;

procedure TLang.StringsLoad;
begin
  FillLangLabels;

  LabelsArray[Ord(TEXT_TRAIN_NAME),1]          := 'Nazwa poci¹gu';
  LabelsArray[Ord(TEXT_TRAIN_NAME_CHANGE),1]   := 'Zmiana nazwy poci¹gu';
  LabelsArray[Ord(TEXT_CAR_NO),1]              := 'Numer wagonu:';
  LabelsArray[Ord(TEXT_AI_TRAIN),1]            := 'Poci¹g prowadzony przez komputer.';
  LabelsArray[Ord(TEXT_KEY),1]                 := 'Przycisk %s';
  LabelsArray[Ord(TEXT_KEY_DESC),1]            := 'Opis funkcji';
  LabelsArray[Ord(TEXT_WRONG_CONNECTION),1]    := 'Niedopuszczalny rodzaj po³¹czenia miêdzy tymi pojazdami.';
  LabelsArray[Ord(TEXT_SAVE_PRESET),1]         := 'Zapis presetu ustawieñ';
  LabelsArray[Ord(TEXT_SET_PRESET_NAME),1]     := 'Nadaj nazwê zestawu ustawieñ:';
  LabelsArray[Ord(TEXT_RANDOM_TEX_EXCEPT),1]   := 'Wyst¹pi³ b³¹d przy losowaniu tekstur. Szczegó³y b³êdu:';

  LabelsArray[Ord(TEXT_LOAD_SETTINGS),1]       := 'Wczytywanie ustawieñ...';
  LabelsArray[Ord(TEXT_LOAD_SCENERIES),1]      := 'Tworzenie listy scenariuszy...';

  LabelsArray[Ord(TEXT_START_NO_EXE),1]        := 'Brak wybranego exe w ustawieniach';
  LabelsArray[Ord(TEXT_START_NO_SCN),1]        := 'Brak wybranego scenariusza';
  LabelsArray[Ord(TEXT_START_GO_SEL_TRAIN),1]  := 'PrzejdŸ do wyboru sk³adu';
  LabelsArray[Ord(TEXT_START_SEL_TRAIN),1]     := 'Wybierz sk³ad do prowadzenia';
  LabelsArray[Ord(TEXT_START_SEL_VEHICLE),1]   := 'Wybierz pojazd do prowadzenia';
  LabelsArray[Ord(TEXT_START_NO_STAFF),1]      := 'Brak obsady pojazdu';
  LabelsArray[Ord(TEXT_NO_VEHICLES),1]         := 'Wpis bez pojazdów. (Tor: %s)';

  LabelsArray[Ord(TEXT_NOT_FOUND_EXE),1]       := 'Nie znaleziono pliku wykonywalnego (%s) symulatora.';
  LabelsArray[Ord(TEXT_INTERNAL_ERROR),1]      := 'B³¹d wewnêtrzny Startera.';
  LabelsArray[Ord(TEXT_DEPO_LOAD_EXCEPT),1]    := 'B³¹d wczytywania magazynu. Szczegó³y b³êdu:';
  LabelsArray[Ord(TEXT_SCN_MINI_LOAD_FAULT),1] := 'Nie uda³o siê wczytaæ miniaturki scenariusza';

  LabelsArray[Ord(TEXT_TEX_NO_FILE),1]         := 'Brak pliku';
  LabelsArray[Ord(TEXT_TEX_NO_MODEL),1]        := 'Brak modelu dla tekstury';
  LabelsArray[Ord(TEXT_TEX_NO_PHYSICS),1]      := 'Brak fizyki dla tekstury';
  LabelsArray[Ord(TEXT_TEX_NO_MULTIMEDIA),1]   := 'Brak pliku mulitmediów dla tekstury';

  LabelsArray[Ord(TEXT_LOAD_SCN),1]            := '£adowanie scenerii';
  LabelsArray[Ord(TEXT_PARSE_SCN),1]           := 'Parsowanie scenerii';

  LabelsArray[Ord(TEXT_NO_FILE),1]             := 'brak pliku tekstury.';
  LabelsArray[Ord(TEXT_NO_MODEL),1]            := 'brak pliku modelu.';
  LabelsArray[Ord(TEXT_NO_PHYSICS),1]          := 'brak pliku/ów fizyki.';
  LabelsArray[Ord(TEXT_NO_MULTIMEDIA),1]       := 'brak pliku multimediów.';
  LabelsArray[Ord(TEXT_CHECK_VALUE_FAULT),1]   := 'B³¹d sprawdzania wartoœci';
  LabelsArray[Ord(TEXT_CHECK_PHYSICS_FILE),1]  := 'Nale¿y sprawdziæ plik .fiz dla';
  LabelsArray[Ord(TEXT_UNSUPPORTED_LOAD),1]    := 'zastosowany nieobs³ugiwany ³adunek przez pojazd';

  LabelsArray[Ord(TEXT_DEPO_PARSE_FAULT),1]    := 'B³¹d parsowania magazynu. Linia:';
  LabelsArray[Ord(TEXT_DEPO_SAVE_FAULT),1]     := 'B³¹d zapisu magazynu.';
  LabelsArray[Ord(TEXT_PHYSICS_PARSE_FAULT),1] := 'B³¹d prztwarzania elementu fizyki. Token:';

  LabelsArray[Ord(TEXT_LOAD_SETTINGS_FAULT),1] := 'B³¹d wczytywania ustawieñ (plik %s).';
  LabelsArray[Ord(TEXT_PARAMETER),1]           := 'Parametr:';
  LabelsArray[Ord(TEXT_INVALID_VALUE),1]       := 'B³êdna wartoœæ:';
  LabelsArray[Ord(TEXT_FAULT_DETAIL),1]        := 'Szczegó³y b³êdu:';
  LabelsArray[Ord(TEXT_ALGORITHM_FAULT),1]     := 'Wyst¹pi³ b³¹d przy próbie zmiany algorytmu. Szczegó³y b³êdu:';
  LabelsArray[Ord(TEXT_SET_CHANGED),1]         := 'Wykryto zewnêtrzne zmiany w ustawieniach symulatora. Czy wczytaæ ustawienia ponownie?';

  LabelsArray[Ord(TEXT_FILE_NOT_FOUND),1]      := 'Nie znaleziono pliku: %s';
  LabelsArray[Ord(TEXT_LOAD_MINI_FAULT),1]     := 'Nie uda³o siê wczytaæ miniaturki pojazdu %s';
  LabelsArray[Ord(TEXT_REMOVE_OLD_VER_FAULT),1]:= 'Nie uda³o siê usun¹æ poprzedniej wersji Startera. Szczegó³y b³êdu: %s';


  LabelsArray[Ord(TEXT_YES),1]                 := 'Tak';
  LabelsArray[Ord(TEXT_NO),1]                  := 'Nie';
  LabelsArray[Ord(TEXT_NO_DIR),1]              := 'Brak katalogu %s';
  LabelsArray[Ord(TEXT_NO_WEIGHTS),1]          := 'Brak informacji o wagach ³adunków.';
  LabelsArray[Ord(TEXT_NO_SCN),1]              := 'Nie znaleziono scenariuszy.';
  LabelsArray[Ord(TEXT_NO_FOUND_VEHICLES),1]   := 'Nie znaleziono pojazdów.';
  LabelsArray[Ord(TEXT_NO_EXE),1]              := 'Nie znaleziono pliku wykonywalnego symulatora.';
  LabelsArray[Ord(TEXT_ERRORS),1]              := 'Mo¿liwa b³êdna instalacja symulatora.';
  LabelsArray[Ord(TEXT_PROGRAM_FILES),1]       := 'Program zainstalowany w katalogu Program Files.';
  LabelsArray[Ord(TEXT_CREATE_FILE_FAULT),1]   := 'Nie uda³o siê utworzyæ pliku: %s';
  LabelsArray[Ord(TEXT_LOGO_FAULT),1]          := 'B³¹d obs³ugi logo. Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_CURRENT_VERSION),1]     := 'Posiadasz najnowsz¹ wersjê.';
  LabelsArray[Ord(TEXT_NEWER_VERSION_ASK),1]   := 'Dostêpna jest nowsza wersja. Zaktualizowaæ program?';
  LabelsArray[Ord(TEXT_UPDATE_FAULT),1]        := 'B³¹d aktualizacji';
  LabelsArray[Ord(TEXT_UPDATE_FAULT_EXT),1]    := 'Wyst¹pi³ b³¹d podczas aktualizacji programu.';
  LabelsArray[Ord(TEXT_UPDATED_PROGRAM),1]     := 'Program zosta³ zaktualizowany.';
  LabelsArray[Ord(TEXT_UPDATING),1]            := 'Aktualizujê...';
  LabelsArray[Ord(TEXT_OPERATION_FAULT),1]     := 'Wyst¹pi³ b³¹d podczas operacji.';
  LabelsArray[Ord(TEXT_REMOVE_ALL_VEHICLES),1] := 'Usun¹æ wszystkie pojazdy na scenerii?';

  LabelsArray[Ord(TEXT_LOADING_DEPOT),1]       := 'Wczytywanie taboru...';
  LabelsArray[Ord(TEXT_LOADING_PHYSICS),1]     := 'Wczytywanie fizyki...';
  LabelsArray[Ord(TEXT_LOADING_SCN),1]         := 'Wczytywanie scenerii...';
  LabelsArray[Ord(TEXT_LOADING_WEIGHTS),1]     := 'Wczytywanie ³adunków...';

  LabelsArray[Ord(TEXT_RENDERER_CHANGE),1]     := 'Renderer eksperymentalny jako testowy mo¿e nie dzia³aæ stabilnie na wszystkich komputerach.'
                                                  + #13#10
                                                  + 'Przywróciæ poprzedni wybór?';

  LabelsArray[Ord(TEXT_NAMEISINRULE),1]        := 'Taki pojazd jest ju¿ w tej regule.';

  LabelsArray[Ord(TEXT_REMOVERULEELEMENT),1]   := 'Usun¹æ wybrany element regu³y?';
  LabelsArray[Ord(TEXT_SAVERULE),1]            := 'Zapisaæ ustalone regu³y?';
  LabelsArray[Ord(TEXT_NUMBEROFPROCESSORS),1]  := 'Nieudane pobranie dostêpnej iloœci w¹tków komputera.';

  LabelsArray[Ord(TEXT_LOADRULESFAULT),1]      := 'B³¹d wczytywania regu³ (starter\reguly.txt). Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_FINDSIMILARTEXFAULT),1] := 'B³¹d wyszukiwania tekstur. Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_MULTIPLEASSIGNFAULT),1] := 'B³¹d edycji pojazdu. Szczegó³y b³êdu: %s';

  LabelsArray[Ord(TEXT_LP),1]                  := 'Lp.';
  LabelsArray[Ord(TEXT_TEX),1]                 := 'Tekstura';
  LabelsArray[Ord(TEXT_MINI),1]                := 'Miniatura';
  LabelsArray[Ord(TEXT_PREVIEW),1]             := 'Podgl¹d';
  LabelsArray[Ord(TEXT_MODEL),1]               := 'Model';
  LabelsArray[Ord(TEXT_OPERATOR),1]            := 'Operator';
  LabelsArray[Ord(TEXT_STATION),1]             := 'Stacja';
  LabelsArray[Ord(TEXT_REVDATE),1]             := 'Data rewizji';
  LabelsArray[Ord(TEXT_AUTHOR),1]              := 'Autor';
  LabelsArray[Ord(TEXT_PHOTO),1]               := 'Zdjêcia';
  LabelsArray[Ord(TEXT_CATEGORY),1]            := 'Kategoria';
  LabelsArray[Ord(TEXT_PATH),1]                := 'Œcie¿ka dostêpu';
  LabelsArray[Ord(TEXT_LOADMODELS_FAULT),1]    := 'B³¹d wczytywania taboru. Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_LOADSCENERY_FAULT),1]   := 'B³¹d wczytywania scenerii %s';
  LabelsArray[Ord(TEXT_PARSETRAIN_FAULT),1]    := '# B³¹d parsowania sk³adu. Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_VEHICLE_INVALID),1]     := '# Braki dla pojazdu: %s tekstura: %s [%s]';
  LabelsArray[Ord(TEXT_LOADWEIGHTS_FAULT),1]   := 'B³¹d wczytywania wag jednostek ³adunków.';
  LabelsArray[Ord(TEXT_VEHICLESYNTAXFAULT),1]  := 'B³¹d sk³adniowy wpisu pojazdu %s, wyra¿enie %s';
  LabelsArray[Ord(TEXT_VEHICLEPARSE_FAULT),1]  := '# B³¹d parsowania wpisu pojazdu %s . Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_PARSING_FAULT),1]       := 'B³¹d podczas parsowania wyra¿enia %s %s';
  LabelsArray[Ord(TEXT_PARSESECTIONFAULT),1]   := '# B³¹d parsowania sekcji %S. Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_PARSEFAULTDETAIL),1]    := '# B³¹d parsowania %s, linia: %s Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_PARSETRAINSETFAULT),1]  := '# B³¹d parsowania sk³adu. Szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_PARSETEXMODELFAULT),1]  := 'B³¹d parsowania textures.txt dla %s\%s, linia: %s';
  LabelsArray[Ord(TEXT_PARSETEXTURESFAULT),1]  := 'B³¹d parsowania %s, szczegó³y b³êdu: %s';
  LabelsArray[Ord(TEXT_PARSE_TEXDESCFAULT),1]  := 'B³¹d przetwarzania opisu tekstury: %s';
  LabelsArray[Ord(TEXT_PARSEPHYSICSFAULT),1]   := 'B³¹d parsowania %s\%s.fiz, linia: %s';
end;

function TLang.LabelStr(const ID:TLabels):string;
begin
  Result := LabelsArray[Ord(ID),1];
end;

function TLang.LabelStr(const ID:TLabels; const Args: array of const):string;
begin
  Result := Format(LabelsArray[Ord(ID),1],Args);
end;

class procedure TLang.ChangeLoads(const LangStr:string);
var
  LangFile : TStringList;
  i, y : Integer;
  s : string;
  Load : TLoad;
begin
  if FileExists(Util.DIR + 'starter\lang-' + LangStr + '.txt') then
  begin
    LangFile := TStringList.Create;
    LangFile.LoadFromFile(Util.DIR + 'starter\lang-' + LangStr + '.txt');

    i := 0;
    while (Pos('<loads>',LangFile[i]) = 0) and (i < LangFile.Count-1) do
        Inc(i);

    if Pos('<loads>',LangFile[i]) > 0 then
    begin
      Inc(i);

      while (Pos('=',LangFile[i]) > 0) and (i < LangFile.Count-1) do
      begin
        s := Copy(LangFile[i],0,Pos('=',LangFile[i])-1);

        y := 0;
        while (Pos(s,Data.Loads[y].Name) = 0) and (Pos('=',LangFile[i]) > 0) and (y < Data.Loads.Count-1) do
          Inc(y);

        if (Pos(s,Data.Loads[y].Name) > 0) then
          Data.Loads[y].Desc := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length)
        else
        begin
          Load      := TLoad.Create;
          Load.Name := s;
          Load.Desc := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
          Data.Loads.Add(Load);
        end;

        Inc(i);
      end;

    end;
  end;
end;

class procedure TLang.ChangeLabels(const LangStr:string);
var
  LangFile : TStringList;
  i, y : Integer;
  s : string;
begin
  if FileExists(Util.DIR + 'starter\lang-' + LangStr + '.txt') then
  begin
    LangFile := TStringList.Create;
    LangFile.LoadFromFile(Util.DIR + 'starter\lang-' + LangStr + '.txt');

    i := 0;
    while (Pos('<labels>',LangFile[i]) = 0) and (i < LangFile.Count-1) do
        Inc(i);

    if Pos('<labels>',LangFile[i]) > 0 then
    begin
      Inc(i);

      while (Pos('=',LangFile[i]) > 0) and (i < LangFile.Count-1) do
      begin
        s := Copy(LangFile[i],0,Pos('=',LangFile[i])-1);

        y := 0;
        while (Pos(s,Lang.LabelsArray[y,0]) = 0) and (Pos('=',LangFile[i]) > 0) do
          Inc(y);

        if (Pos(s,Lang.LabelsArray[y,0]) > 0) then
          Lang.LabelsArray[y,1] := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);

        Inc(i);
      end;

    end;
  end;
end;

class procedure TLang.ChangeLanguage(Form:TForm;const LangStr: string);
var
  Comp : TComponent;
  LangFile : TStringList;
  Value, Prop : string;
  i : Integer;
begin
  ChangeLabels(LangStr);
  ChangeLoads(LangStr);

  if FileExists(Util.DIR + 'starter\lang-' + LangStr + '.txt') then
  begin
    LangFile := TStringList.Create;
    LangFile.LoadFromFile(Util.DIR + 'starter\lang-' + LangStr + '.txt');

    i := 0;
    while (Pos('[' + Form.Name,LangFile[i]) = 0) and (i < LangFile.Count-1) do
        Inc(i);

    if Pos('[' + Form.Name,LangFile[i]) > 0 then
    begin
      Inc(i);
      Form.Caption := LangFile[i];
      Inc(i);

      while (i < LangFile.Count) and (Pos('=',LangFile[i]) > 0) do
      begin
        Comp := Form.FindComponent(Copy(LangFile[i],0,Pos('.',LangFile[i])-1));
        if Comp <> nil then
        begin
          Prop := Copy(LangFile[i],Pos('.',LangFile[i])+1,PosEx('=',LangFile[i],Pos('.',LangFile[i])+1) - Pos('.',LangFile[i])-1  );
          if Prop = 'Items.Text' then
          begin
            if Comp is TComboBox then
            begin
              Value := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
              (Comp as TComboBox).Items.Text := StringReplace(Value,'|',#13#10,[rfReplaceAll]);
            end
            else
            if Comp is TListBox then
            begin
              Value := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
              (Comp as TListBox).Items.Text := StringReplace(Value,'|',#13#10,[rfReplaceAll]);
            end
            else
            if Comp is TRadioGroup then
            begin
              Value := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
              (Comp as TRadioGroup).Items.Text := StringReplace(Value,'|',#13#10,[rfReplaceAll]);
            end
            else
            if Comp is TCheckListBox then
            begin
              Value := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
              (Comp as TCheckListBox).Items.Text := StringReplace(Value,'|',#13#10,[rfReplaceAll]);
            end
          end
          else
          begin
            Value := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
            SetStrProp(Comp,Prop,Value);
          end;
        end;
        //else
        //  Value := Copy(LangFile[i],0,Pos('.',LangFile[i])-1);
        Inc(i);
      end;
    end;
  end;
end;

class procedure TLang.ChangeIniLanguage(const LangStr:string);
var
  LangFile : TStringList;
  Prop : string;
  i, y : Integer;
begin
  if FileExists(Util.DIR + 'starter\lang-' + LangStr + '.txt') then
  begin
    LangFile := TStringList.Create;
    LangFile.LoadFromFile(Util.DIR + 'starter\lang-' + LangStr + '.txt');

    i := 0;
    while (Pos('<' + 'eu07_input-keyboard.ini',LangFile[i]) = 0) and (i < LangFile.Count-1) do
        Inc(i);

    if Pos('<' + 'eu07_input-keyboard.ini',LangFile[i]) > 0 then
    begin
      Inc(i);

      while (i <= LangFile.Count-1) and (Pos('=',LangFile[i]) > 0) do
      begin
        Prop := Copy(LangFile[i],0,Pos('=',LangFile[i])-1);

        for y := 0 to Main.Settings.KeyParams.Count-1 do
          if Main.Settings.KeyParams[y].Name = Prop then
          begin
            Main.Settings.KeyParams[y].Desc := Copy(LangFile[i],Pos('=',LangFile[i])+1,LangFile[i].Length);
            Break;
          end;

        Inc(i);
      end;

    end;
  end;
end;

class function TLang.LoadLanguages:string;
var
  SR : TSearchRec;
  Count : Integer;
begin
  Result := '';

  Count := FindFirst(Util.DIR + '\starter\lang-*.txt',faDirectory,SR);
  while (Count = 0) do
  begin
    if FileExists(Util.DIR + '\starter\' + SR.Name) then
      Result := Result + '|' + Util.DIR + '\starter\' + SR.Name;
    Count := FindNext(SR);
  end;
end;

{class procedure TLanguages.SaveLanguage(Form:TForm;const Lang:string);
var
  i : integer;
  sl : tstringlist;
begin
  sl := tstringlist.Create;

  for i := 0 to Form.ComponentCount-1 do
  begin
    if Form.Components[i] is TLabel then
    begin
      sl.Add( Form.Components[i].Name + '.Caption=' + (Form.Components[i] as TLabel).Caption);
      if (Form.Components[i] as TLabel).Hint.Length > 0 then
        sl.Add( Form.Components[i].Name + '.Hint=' + (Form.Components[i] as TLabel).Hint);
    end;
    if Form.Components[i] is TAction then
    begin
      sl.Add( Form.Components[i].Name + '.Caption=' + (Form.Components[i] as TAction).Caption);
      if (Form.Components[i] as TAction).Hint.Length > 0 then
        sl.Add( Form.Components[i].Name + '.Hint=' + (Form.Components[i] as TAction).Hint);
    end;
    if Form.Components[i] is TTabSheet then
    begin
      sl.Add( Form.Components[i].Name + '.Caption=' + (Form.Components[i] as TTabSheet).Caption);
    end;
    if Form.Components[i] is TCheckBox then
    begin
      sl.Add( Form.Components[i].Name + '.Caption=' + (Form.Components[i] as TCheckBox).Caption);
      if (Form.Components[i] as TCheckBox).Hint.Length > 0 then
        sl.Add( Form.Components[i].Name + '.Hint=' + (Form.Components[i] as TCheckBox).Hint);
    end;
    if Form.Components[i] is TComboBox then
    begin
      if (Form.Components[i] as TComboBox).Items.Count > 0 then
        sl.Add( Form.Components[i].Name + '.Items.Text=' + StringReplace((Form.Components[i] as TComboBox).Items.Text,#13#10,'|',[rfReplaceAll]));
    end;
    if Form.Components[i] is TCheckListBox then
    begin
      if (Form.Components[i] as TCheckListBox).Items.Count > 0 then
        sl.Add( Form.Components[i].Name + '.Items.Text=' + StringReplace((Form.Components[i] as TCheckListBox).Items.Text,#13#10,'|',[rfReplaceAll]));
    end;
    if Form.Components[i] is TRadioGroup then
    begin
      if (Form.Components[i] as TRadioGroup).Items.Count > 0 then
        sl.Add( Form.Components[i].Name + '.Items.Text=' + StringReplace((Form.Components[i] as TRadioGroup).Items.Text,#13#10,'|',[rfReplaceAll]));
    end;
    if Form.Components[i] is TPanel then
    begin
      if ((Form.Components[i] as TPanel).ShowCaption) and (Length((Form.Components[i] as TPanel).Caption)>0) then
      begin
        sl.Add( Form.Components[i].Name + '.Caption=' + (Form.Components[i] as TPanel).Caption);
        if (Form.Components[i] as TPanel).Hint.Length > 0 then
          sl.Add( Form.Components[i].Name + '.Hint=' + (Form.Components[i] as TPanel).Hint);
      end;
    end;
    if Form.Components[i] is TListBox then
    begin
      if (Form.Components[i] as TListBox).Items.Count > 0 then
        sl.Add( Form.Components[i].Name + '.Items.Text=' + StringReplace((Form.Components[i] as TListBox).Items.Text,#13#10,'|',[rfReplaceAll]));
    end;
  end;

  sl.SaveToFile(DIR + '\starter\' + Lang + '.txt');
end;}

end.
