{
  Starter
  Copyright (C) 2019 Damian Skrzek (szczawik)

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

unit uUtilities;

interface

uses Classes, uStructures, Graphics;

type
  TRunInfo = record
    EXE         : string;
    SceneryName : string;
    Vehicle     : string;
    Logo        : string;
  end;

  TUtil = class
    Dir     : string;
    INIDir  : string;
    LangStr : string;
    InitSCN : string;
    Log     : TStringList;
    FileVersion : string;
    FileDateStr : string;
    StartApp : TDateTime;

    constructor Create;
    function Ask(const Text: string): Boolean;
    procedure CheckInstallation(const EXECount:Integer);
    procedure EmptyTextures;
    function GetFileVersion(const FileName:string;StrFormat:string='%d.%d.%d'): string;
    procedure OpenFile(const Path:string);
    procedure PrepareLoadingScreen(const LogoPath:string);
    procedure LogAdd(const S:string;const ShowInfo:Boolean=False);
    function MiniPath(const Model: TModel): string;
  end;

procedure FlipBitmap(Bitmap: TBitmap; const Flip: Boolean);
function Clamp(const Value, Min, Max:Integer):Integer;
procedure OpenDir(const Path:string);
procedure OpenURL(const URL:string);
function IsParameter(const Name:string):Boolean;

procedure RemoveOldVersion;

procedure RunSimulator(const RunInfo:TRunInfo);
procedure SetFormatSettings;
//procedure FlipBitmap(Bitmap:TBitmap;const Flip:Boolean);

function CompareVehicleNames(const Item1, Item2: Pointer): Integer;
function CompareTrainNames(const Item1, Item2: Pointer): Integer;

function OmitAccents(const aStr: String): String;
function ContainsOmitAccents(const S1,S2:string):Boolean;
function SameTextOmitAccents(const S1,S2:string):Boolean;
function RandomBoolean:Boolean;
function EnsureUTF8(const S: string): string;
function ReadFileRaw(const FileName: string): string;

var
  Util  : TUtil;

implementation

uses SysUtils, Dialogs, uMain,
    uData, StrUtils, uSettingsAdv, StdCtrls, Controls, uLanguages
{$IFDEF FPC}
    , Forms, LCLIntf, LCLType, process, LazUTF8, LConvEncoding
{$ELSE}
    , Vcl.Forms, JPEG
{$ENDIF}
{$IFDEF MSWINDOWS}
    , Windows, ShellApi
{$ENDIF}
    {, RTTI};

function INIPath:string;
{$IFNDEF MSWINDOWS}
var
  Home : string;
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  Result := SysUtils.GetEnvironmentVariable('APPDATA');

  if Result <> '' then
    Result := IncludeTrailingPathDelimiter(Result) + 'MaSzyna/'
  else
    Result := Util.Dir;
{$ELSE}
  // Mirror the engine's user_config_path (../maszyna, utilities/utilities.cpp):
  //   macOS -> $HOME/Library/Application Support/MaSzyna/
  //   other -> $HOME/.config/MaSzyna/
  // so the launcher reads/writes eu07.ini where the simulator actually reads it.
  Home := SysUtils.GetEnvironmentVariable('HOME');

  if Home <> '' then
    {$IFDEF DARWIN}
    Result := IncludeTrailingPathDelimiter(Home) + 'Library/Application Support/MaSzyna/'
    {$ELSE}
    Result := IncludeTrailingPathDelimiter(Home) + '.config/MaSzyna/'
    {$ENDIF}
  else
    Result := Util.Dir;
{$ENDIF}
end;

function Clamp(const Value, Min, Max:Integer):Integer;
begin
  Result := Value;
  if Value < Min then
    Result := Min
  else
    if Value > Max then
      Result := Max;
end;

procedure OpenDir(const Path:string);
begin
{$IFDEF MSWINDOWS}
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(Path),
    nil,
    nil,
    SW_SHOWNORMAL);
{$ELSE}
  OpenDocument(Path);
{$ENDIF}
end;

procedure OpenURL(const URL:string);
begin
{$IFDEF MSWINDOWS}
  ShellExecute(Application.Handle,'open',PChar(URL),nil,nil, SW_SHOWNORMAL);
{$ELSE}
  LCLIntf.OpenURL(URL);
{$ENDIF}
end;

function IsParameter(const Name:string):Boolean;
var
  i : Integer;
begin
  Result := False;

  for i := 1 to ParamCount do
    if ParamStr(i) = Name then
      Result := True;
end;

procedure TUtil.OpenFile(const Path:string);
begin
  if FileExists(Util.DIR + Path) then
{$IFDEF MSWINDOWS}
    ShellExecute(Application.Handle,'open',PChar(Util.DIR + Path),nil,nil, SW_SHOWNORMAL)
{$ELSE}
    OpenDocument(Util.DIR + Path)
{$ENDIF}
  else
    ShowMessage(Lang.LabelStr(TEXT_FILE_NOT_FOUND,[Path]));
end;

function TUtil.MiniPath(const Model:TModel):string;
begin
  try
    Result := '';

    if FileExists(DIR + 'textures/mini/' + Model.MiniD + '.bmp') then
      Result := DIR + 'textures/mini/' + Model.MiniD + '.bmp'
    else
      if FileExists(DIR + 'textures/mini/' + Model.Mini + '.bmp') then
        Result := DIR + 'textures/mini/' + Model.Mini + '.bmp';

    if Result.IsEmpty then
      if FileExists(DIR + 'textures/mini/other.bmp') then
        Result := DIR + 'textures/mini/other.bmp';
  except
    LogAdd(Lang.LabelStr(TEXT_LOAD_MINI_FAULT,[Model.Model]));
  end;
end;

procedure RemoveOldVersion;
begin
  try
    if FileExists(Util.DIR + 'StarterOld.exe') then
      DeleteFile(Util.DIR + 'StarterOld.exe');
  except
    on E: Exception do
      Util.Log.Add(Lang.LabelStr(TEXT_REMOVE_OLD_VER_FAULT,[E.Message]));
  end;
end;

function TUtil.Ask(const Text:string):Boolean;
begin
{$IFDEF FPC}
  with CreateMessageDialog(Text, mtCustom, [mbYes, mbNo]) do
{$ELSE}
  with CreateMessageDialog(Text, mtCustom, [mbYes, mbNo], mbNo) do
{$ENDIF}
    begin
      try
        if FindComponent('Yes') <> nil then
          TButton(FindComponent('Yes')).Caption:= Lang.LabelStr(TEXT_YES);
        if FindComponent('No') <> nil then
          TButton(FindComponent('No')).Caption:= Lang.LabelStr(TEXT_NO);
        ShowModal;
      finally
        Result := ModalResult = mrYes;
        Free;
      end;
    end;
end;

procedure TUtil.CheckInstallation(const EXECount:Integer);
var
  Err : string;
begin
  if DirectoryExists(Util.DIR + 'dynamic') = False then
    Err := Err + Lang.LabelStr(TEXT_NO_DIR,['/dynamic']) + #13#10;

  if DirectoryExists(Util.DIR + 'sounds') = False then
    Err := Err + Lang.LabelStr(TEXT_NO_DIR,['/sounds']) + #13#10;

  if DirectoryExists(Util.DIR + 'models') = False then
    Err := Err + Lang.LabelStr(TEXT_NO_DIR,['/models']) + #13#10;

  if DirectoryExists(Util.DIR + 'scenery') = False then
    Err := Err + Lang.LabelStr(TEXT_NO_DIR,['/scenery']) + #13#10;

  if DirectoryExists(Util.DIR + 'textures') = False then
    Err := Err + Lang.LabelStr(TEXT_NO_DIR,['/textures']) + #13#10;

  if FileExists(Util.DIR + 'data/load_weights.txt') = False then
    Err := Err + Lang.LabelStr(TEXT_NO_WEIGHTS) + #13#10;

  if Data.Scenarios.Count = 0 then
    Err := Err + Lang.LabelStr(TEXT_NO_SCN) + #13#10;

  if Data.Textures.Count = 0 then
    Err := Err + Lang.LabelStr(TEXT_NO_FOUND_VEHICLES) + #13#10;

  if Data.Physics.Count = 0 then
    Err := Err + Lang.LabelStr(TEXT_NO_PHYSICS) + #13#10;

  if EXECount = 0 then
    Err := Err + Lang.LabelStr(TEXT_NO_EXE) + #13#10;

  if Err.Length > 0 then
    ShowMessage(Err + Lang.LabelStr(TEXT_ERRORS));

  if Pos('\Program Files',Util.DIR) > 0 then
    Err := Err + Lang.LabelStr(TEXT_PROGRAM_FILES);

  if not Err.IsEmpty then
    Util.Log.Add(Err);
end;

procedure TUtil.EmptyTextures;
var
  MyFile: THandle;
begin
  try
    if not FileExists(Util.Dir + 'dynamic/textures.ini') then
    begin
      MyFile := FileCreate(Util.Dir + 'dynamic/textures.ini');
      FileClose(MyFile);
      Util.Log.Add('Utworzono plik dynamic/textures.ini');
    end;
  except
    Util.Log.Add(Lang.LabelStr(TEXT_CREATE_FILE_FAULT,['dynamic/textures.ini']));
  end;
end;

procedure TUtil.PrepareLoadingScreen(const LogoPath:string);
var
  SR : TSearchRec;
  FoundFiles : Integer;
  FilesList : TStringList;
  JPG : TJPEGImage;
  BMP: TBitmap;
begin
  JPG := TJPEGImage.Create;
  FilesList := TStringList.Create;
  Bmp := TBitmap.Create;
  try
    try
      if FileExists(Util.DIR + 'textures/logo/' + LogoPath + '.jpg') then
        JPG.LoadFromFile(Util.DIR + 'textures/logo/' + LogoPath + '.jpg')
      else
      begin
        FoundFiles := FindFirst(Util.DIR + 'textures/logo/logo*.jpg',faAnyFile,SR);
        while (FoundFiles = 0) do
        begin
          if (SR.Name <> '.') and (SR.Name <> '..') then
            FilesList.Add(SR.Name);

          FoundFiles := FindNext(SR);
        end;
        FindClose(SR);

        JPG.LoadFromFile(Util.DIR + 'textures/logo/' + FilesList[Random(FilesList.Count)]);
      end;

      Bmp.PixelFormat := pf32bit;
      Bmp.Assign(JPG);
      Bmp.SaveToFile(Util.DIR + 'textures/logo.bmp');
    except
      on E: Exception do
        Util.Log.Add(Lang.LabelStr(TEXT_LOGO_FAULT,[E.Message]));
    end;
  finally
    JPG.Free;
    BMP.Free;
    FilesList.Free;
  end;
end;

procedure RunSimulator(const RunInfo:TRunInfo);
var
  Parameters : string;
{$IFDEF MSWINDOWS}
  SEI : TShellExecuteInfo;
{$ELSE}
  Proc : TProcess;
{$ENDIF}
begin
  if RunInfo.Logo.Length > 0 then
    Util.PrepareLoadingScreen(RunInfo.Logo)
  else
    Util.PrepareLoadingScreen(RunInfo.SceneryName);

  try
    Parameters := '-s ' + '$' + RunInfo.SceneryName + '.scn';
    Parameters := Parameters + ' -v ' + RunInfo.Vehicle;
{$IFDEF MSWINDOWS}
    ZeroMemory(@SEI, SizeOf(SEI));
    SEI.cbSize := SizeOf(SEI);
    SEI.lpFile := PChar(RunInfo.EXE);
    SEI.lpParameters := PChar(Parameters);
    SEI.lpDirectory := PChar( ExtractFileDir(RunInfo.EXE));
    SEI.nShow := SW_SHOWNORMAL;
    ShellExecuteEx(@SEI);
{$ELSE}
    Proc := TProcess.Create(nil);
    try
      Proc.Executable := RunInfo.EXE;
      Proc.Parameters.Add('-s');
      Proc.Parameters.Add('$' + RunInfo.SceneryName + '.scn');
      Proc.Parameters.Add('-v');
      Proc.Parameters.Add(RunInfo.Vehicle);
      Proc.CurrentDirectory := ExtractFileDir(RunInfo.EXE);
      Proc.Execute;
    finally
      Proc.Free;
    end;
{$ENDIF}
  except
    on E: Exception do ShowMessage(E.Message);
  end;
end;

function CompareVehicleNames(const Item1, Item2: Pointer): Integer;
begin
  if (TTrain(Item1).Vehicles.Count > 0) and (TTrain(Item2).Vehicles.Count > 0) then
    Result := CompareText(TTrain(Item1).Vehicles[0].Name, TTrain(Item2).Vehicles[0].Name)
  else
    Result := -1;
end;

function CompareTrainNames(const Item1, Item2: Pointer): Integer;
begin
  if (TTrain(Item1).Vehicles.Count > 0) and (TTrain(Item2).Vehicles.Count > 0) then
    Result := CompareText(TTrain(Item1).TrainName, TTrain(Item2).TrainName)
  else
    Result := -1;
end;

procedure SetFormatSettings;
begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.TimeSeparator    := ':';
  FormatSettings.ShortTimeFormat  := 'GG:mm';
  FormatSettings.LongTimeFormat   := 'GG:mm:ss';
end;

function OmitAccents(const aStr: String): String;
type
  ASCIIString = type AnsiString(1251);
begin
  Result := string(ASCIIString(aStr));
end;

function ContainsOmitAccents(const S1,S2:string):Boolean;
begin
  Result := ContainsText(OmitAccents(S1),OmitAccents(S2));
end;

function SameTextOmitAccents(const S1,S2:string):Boolean;
begin
  Result := SameText(OmitAccents(S1),OmitAccents(S2));
end;

function RandomBoolean:Boolean;
var
  i : Integer;
begin
  i := Random(100);
  Result := i mod 2 = 0;
end;

function ReadFileRaw(const FileName: string): string;
var
  FS: TFileStream;
begin
  Result := '';
  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    if FS.Size > 0 then
    begin
      SetLength(Result, FS.Size);
      FS.ReadBuffer(Result[1], FS.Size);
    end;
  finally
    FS.Free;
  end;
end;

function EnsureUTF8(const S: string): string;
begin
{$IFDEF FPC}
  // MaSzyna data files are CP1250; the LCL/Cocoa text controls require valid
  // UTF-8. Leave already-valid UTF-8 untouched, otherwise transcode from CP1250.
  if (S = '') or (FindInvalidUTF8Codepoint(PChar(S), Length(S)) < 0) then
    Result := S
  else
    Result := CP1250ToUTF8(S);
{$ELSE}
  Result := S;
{$ENDIF}
end;

{ TUtil }

constructor TUtil.Create;
var
  FileDate : TDateTime;
begin
{$IFDEF MSWINDOWS}
  DIR := 'C:\MaSzyna\';
{$ELSE}
  DIR := IncludeTrailingPathDelimiter(GetCurrentDir);
{$ENDIF}
  INIDir := INIPath;
  Log := TStringList.Create;

  SetFormatSettings;

  {$IFDEF WIN64}
    FileVersion := GetFileVersion(ParamStr(0)) + ' 64-bit' + ' beta';
  {$ELSE}
    FileVersion := GetFileVersion(ParamStr(0)) + ' beta';
  {$ENDIF}

  FileAge(ParamStr(0),FileDate);
  FileDateStr := FormatDateTime(' dd.mm.yyyy',FileDate);
end;

procedure FlipBitmap(Bitmap: TBitmap; const Flip: Boolean);
var
  Width, Height : Integer;
  SrcRect, DstRect: TRect;
begin
  if Flip then
  begin
    Width   := Bitmap.Width;
    Height  := Bitmap.Height;
    SrcRect := Rect(0, 0, Width, Height);
    DstRect := Rect(Width, 0, 0, Height);
  end;

  with Bitmap do
  begin
    Canvas.CopyRect(DstRect,Canvas,SrcRect);
    Canvas.Font.Name := 'Webdings';
    Canvas.Font.Size := 16;
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Color := clWhite;
    Canvas.TextOut(5,5,'q');
  end;
end;

function TUtil.GetFileVersion(const FileName: string;StrFormat:string='%d.%d.%d'): string;
{$IFDEF MSWINDOWS}
var
  iBufferSize, iDummy: DWORD;
  pBuffer, pFileInfo: Pointer;
  iVer: array[1..3] of word;
{$ENDIF}
begin
  Result := '';
{$IFDEF MSWINDOWS}

  iBufferSize := GetFileVersionInfoSize(PChar(FileName), iDummy);
  if (iBufferSize > 0) then
  begin
    Getmem(pBuffer, iBufferSize);
    try
      GetFileVersionInfo(PChar(FileName), 0, iBufferSize, pBuffer);
      VerQueryValue(pBuffer, '/', pFileInfo, iDummy);

      iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
      iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
      iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
    finally
      Freemem(pBuffer);
    end;
    Result := Format(StrFormat, [iVer[1], iVer[2], iVer[3]]);
  end;
{$ENDIF}
end;

procedure TUtil.LogAdd(const S:string;const ShowInfo:Boolean=False);
begin
  Log.Add(S);

  if ShowInfo then
    ShowMessage(S);
end;

end.
