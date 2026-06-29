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

unit uAbout;

interface

uses
{$IFDEF FPC}
  LCLIntf,
  LCLType,
  LMessages,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  SysUtils,
  Variants,
  Classes
{$ELSE}
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  SysUtils,
  Variants,
  Classes
{$ENDIF}
  ;

type
  TfrmAbout = class(TForm)
    Label1: TLabel;
    Label3: TLabel;
    lbProgrammer: TLabel;
    lbTesters: TLabel;
    lbTranslators: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lbLicense: TLabel;
    lbVersion: TLabel;
    Label11: TLabel;
    pnlAbout: TPanel;
    pnlLog: TPanel;
    meLog: TMemo;
    lbLog: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

implementation

uses uUtilities, uLanguages;

{$IFDEF FPC}{$R *.lfm}{$ELSE}{$R *.dfm}{$ENDIF}

procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  if Util.LangStr <> 'pl' then
    TLang.ChangeLanguage(Self,Util.LangStr);

  lbVersion.Caption := Util.FileVersion;
end;

end.
