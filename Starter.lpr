{
  Starter
  Copyright (C) 2019-2021 Damian Skrzek (szczawik)

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

  Lazarus/FPC program file.
}
program Starter;

{$mode delphi}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces,
  uLazFixups,
  Forms,
  SysUtils,
  Classes,
  uMain,
  CastaliaPasLex,
  CastaliaPasLexTypes,
  uParser,
  uStructures,
  uSettings,
  uLanguages,
  uStart,
  uSearch,
  uTextureBase,
  uAbout,
  uUART,
  uSettingsAdv,
  uTexRandomizer,
  uDepot,
  uLexer,
  uUtilities,
  uData,
  uI18n,
  uI18nCtx,
  uKeyboard,
  uRules
  {$IFDEF ENABLE_UPDATER}
  , uUpdater
  {$ENDIF}
  ;

{$IFDEF MSWINDOWS}
{$R *.res}
{$ENDIF}

begin
  try
  ApplyLazFixups;
  Application.Initialize;
  Application.Title := 'Starter MaSzyna';

  TfrmStart.GetInstance.Show;
  TfrmStart.GetInstance.Update;

  Util := TUtil.Create;
  Lang := TLang.Create;
  Lang.StringsLoad;
  Data := TData.Create;
  TLexParser.LoadData;
  TfrmStart.GetInstance.UpdateLabel('Tworzenie okna programu...');

  Application.CreateForm(TMain, Main);
  Application.CreateForm(TfrmSettingsAdv, frmSettingsAdv);
  Application.Run;
  except
    on E: Exception do
      with TStringList.Create do
      try
        Add(E.ClassName + ': ' + E.Message);
        SaveToFile('startup_error.log');
      finally
        Free;
      end;
  end;
end.
