
unit uPSR_std;
{$I PascalScript.inc}
interface
uses
  uPSRuntime, uPSUtils;


procedure RIRegisterTObject(CL: TPSRuntimeClassImporter);
procedure RIRegisterTPersistent(Cl: TPSRuntimeClassImporter);
procedure RIRegisterTComponent(Cl: TPSRuntimeClassImporter);
procedure RIRegister_Std(Cl: TPSRuntimeClassImporter);

implementation
uses
  Classes;

{$IFDEF DELPHI10UP}{$REGION 'TObject'}{$ENDIF}
procedure RIRegisterTObject(CL: TPSRuntimeClassImporter);
begin
  with cl.Add(TObject) do
  begin
    RegisterConstructor(@TObject.Create, 'Create');
    RegisterMethod(@TObject.Free, 'Free');
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TPersistent'}{$ENDIF}
procedure RIRegisterTPersistent(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TPersistent) do
  begin
    RegisterVirtualMethod(@TPersistent.Assign, 'Assign');
  end;
end;
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}

{$IFDEF DELPHI10UP}{$REGION 'TComponent'}{$ENDIF}
{$IFDEF class_helper_present}
type
  TComponent_PSHelper = class helper for TComponent
  public
    procedure OwnerR(var T: TComponent);
    procedure COMPONENTS_R(var T: TCOMPONENT; t1: INTEGER);
    procedure COMPONENTCOUNT_R(var T: INTEGER);
    procedure COMPONENTINDEX_R(var T: INTEGER);
    procedure COMPONENTINDEX_W(T: INTEGER);
    procedure COMPONENTSTATE_R(var T: TCOMPONENTSTATE);
    procedure DESIGNINFO_R(var T: LONGINT);
    procedure DESIGNINFO_W(T: LONGINT);
  end;

procedure TComponent_PSHelper.OwnerR(var T: TComponent); begin T := Self.Owner; end;
procedure TComponent_PSHelper.COMPONENTS_R(var T: TCOMPONENT; t1: INTEGER); begin T := Self.COMPONENTS[t1]; end;
procedure TComponent_PSHelper.COMPONENTCOUNT_R(var T: INTEGER); begin t := Self.COMPONENTCOUNT; end;
procedure TComponent_PSHelper.COMPONENTINDEX_R(var T: INTEGER); begin t := Self.COMPONENTINDEX; end;
procedure TComponent_PSHelper.COMPONENTINDEX_W(T: INTEGER); begin Self.COMPONENTINDEX := t; end;
procedure TComponent_PSHelper.COMPONENTSTATE_R(var T: TCOMPONENTSTATE); begin t := Self.COMPONENTSTATE; end;
procedure TComponent_PSHelper.DESIGNINFO_R(var T: LONGINT); begin t := Self.DESIGNINFO; end;
procedure TComponent_PSHelper.DESIGNINFO_W(T: LONGINT); begin Self.DESIGNINFO := t; end;


procedure RIRegisterTComponent(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TComponent) do
  begin
    RegisterMethod(@TComponent.FindComponent, 'FindComponent');
    RegisterVirtualConstructor(@TComponent.Create, 'Create');
    RegisterPropertyHelper(@TComponent.OwnerR, nil, 'Owner');

    RegisterMethod(@TComponent.DESTROYCOMPONENTS, 'DestroyComponents');
    RegisterPropertyHelper(@TComponent.COMPONENTS_R, nil, 'Components');
    RegisterPropertyHelper(@TComponent.COMPONENTCOUNT_R, nil, 'ComponentCount');
    RegisterPropertyHelper(@TComponent.COMPONENTINDEX_R, @TComponent.COMPONENTINDEX_W, 'ComponentIndex');
    RegisterPropertyHelper(@TComponent.COMPONENTSTATE_R, nil, 'ComponentState');
    RegisterPropertyHelper(@TComponent.DESIGNINFO_R, @TComponent.DESIGNINFO_W, 'DesignInfo');
  end;
end;

{$ELSE}
procedure TComponentOwnerR(Self: TComponent; var T: TComponent); begin T := Self.Owner; end;
procedure TCOMPONENTCOMPONENTS_R(Self: TCOMPONENT; var T: TCOMPONENT; t1: INTEGER); begin T := Self.COMPONENTS[t1]; end;
procedure TCOMPONENTCOMPONENTCOUNT_R(Self: TCOMPONENT; var T: INTEGER); begin t := Self.COMPONENTCOUNT; end;
procedure TCOMPONENTCOMPONENTINDEX_R(Self: TCOMPONENT; var T: INTEGER); begin t := Self.COMPONENTINDEX; end;
procedure TCOMPONENTCOMPONENTINDEX_W(Self: TCOMPONENT; T: INTEGER); begin Self.COMPONENTINDEX := t; end;
procedure TCOMPONENTCOMPONENTSTATE_R(Self: TCOMPONENT; var T: TCOMPONENTSTATE); begin t := Self.COMPONENTSTATE; end;
procedure TCOMPONENTDESIGNINFO_R(Self: TCOMPONENT; var T: LONGINT); begin t := Self.DESIGNINFO; end;
procedure TCOMPONENTDESIGNINFO_W(Self: TCOMPONENT; T: LONGINT); begin Self.DESIGNINFO := t; end;


procedure RIRegisterTComponent(Cl: TPSRuntimeClassImporter);
begin
  with Cl.Add(TComponent) do
  begin
    RegisterMethod(@TComponent.FindComponent, 'FindComponent');
    RegisterVirtualConstructor(@TComponent.Create, 'Create');
    RegisterPropertyHelper(@TComponentOwnerR, nil, 'Owner');

    RegisterMethod(@TCOMPONENT.DESTROYCOMPONENTS, 'DestroyComponents');
    RegisterPropertyHelper(@TCOMPONENTCOMPONENTS_R, nil, 'Components');
    RegisterPropertyHelper(@TCOMPONENTCOMPONENTCOUNT_R, nil, 'ComponentCount');
    RegisterPropertyHelper(@TCOMPONENTCOMPONENTINDEX_R, @TCOMPONENTCOMPONENTINDEX_W, 'ComponentIndex');
    RegisterPropertyHelper(@TCOMPONENTCOMPONENTSTATE_R, nil, 'ComponentState');
    RegisterPropertyHelper(@TCOMPONENTDESIGNINFO_R, @TCOMPONENTDESIGNINFO_W, 'DesignInfo');
  end;
end;

{$ENDIF class_helper_present}
{$IFDEF DELPHI10UP}{$ENDREGION}{$ENDIF}
procedure RIRegister_Std(Cl: TPSRuntimeClassImporter);
begin
  RIRegisterTObject(CL);
  RIRegisterTPersistent(Cl);
  RIRegisterTComponent(Cl);
end;
// PS_MINIVCL changes by Martijn Laan

end.





