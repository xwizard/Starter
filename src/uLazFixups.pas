{
  uLazFixups - FPC/Lazarus-only helper.

  Registers VCL-only published properties that exist in Delphi .dfm but not in
  the LCL, so the shared form resources load without EReadError. Skipping a
  property only drops a (cosmetic) design-time setting; it never affects logic.

  Call ApplyLazFixups once at program start, before any form is created.
}
unit uLazFixups;

{$mode delphi}{$H+}

interface

procedure ApplyLazFixups;

implementation

uses
  Classes, LResources, Controls, ExtCtrls, StdCtrls, ComCtrls, Forms, DateTimePicker;

procedure Skip(AClass: TPersistentClass; const Names: array of string);
var
  i: Integer;
begin
  for i := Low(Names) to High(Names) do
    RegisterPropertyToSkip(AClass, Names[i], 'VCL-only property, ignored by LCL', '');
end;

procedure ApplyLazFixups;
begin
  // TScrollBox in the VCL has Bevel* / Ctl3D that LCL's TScrollBox lacks.
  // VCL bevel/Ctl3D props exist on these controls but not in the LCL.
  // NOTE: TPanel keeps BevelOuter/BevelInner (valid in LCL) - do not skip there.
  Skip(TScrollBox, ['BevelInner', 'BevelOuter', 'BevelKind', 'BevelEdges',
                    'Ctl3D', 'ParentCtl3D']);
  Skip(TTreeView, ['BevelInner', 'BevelOuter', 'BevelKind', 'BevelEdges',
                   'Ctl3D', 'ParentCtl3D']);
  Skip(TListBox, ['BevelInner', 'BevelOuter', 'BevelKind', 'BevelEdges',
                  'Ctl3D', 'ParentCtl3D']);
  // VCL TDateTimePicker.Format has no LCL equivalent.
  Skip(TDateTimePicker, ['Format']);
end;

end.
