unit ray_engine3d;

{$mode objfpc}{$H+}
interface

uses
  ray_headers, Classes;//, SysUtils;

type

  { TRayEngine3D }
 TRayEngine3D = class
  private
    FCamera: TCamera;
    FList: TList;
    FDeadList: TList;
    FVisibleHeight: Integer;
    FVisibleWidth: Integer;
    FWorld: TVector3;
    function GetCamera: TCamera;
    procedure SetCamera(AValue: TCamera);
    procedure SetWorld(AValue: TVector3);
 public
    procedure Draw();
    procedure ClearDeadModel;
    procedure Move(TimeGap: Double);
    constructor Create;
    destructor Destroy; override;
    property VisibleWidth: Integer read FVisibleWidth write FVisibleWidth;
    property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
    property World: TVector3 read FWorld write SetWorld;
    property Camera: TCamera read FCamera write SetCamera;
  end;

  { TRayModel }

  TRayModel = class
    private
     FAngle: Single;
     FFileName: String;
     FModel:TModel;
     FPosition: TVector3;
     FRotationAxis: TVector3;
     FScale: Single;
     FScaleV: TVector3;
     procedure SetAngle(AValue: Single);
     procedure SetFileName(AValue: String);
     procedure SetPosition(AValue: TVector3);
     procedure SetRotationAxis(AValue: TVector3);
     procedure SetScale(AValue: Single);
    protected
     FEngine: TRayEngine3D;
     FModelDead: Boolean;
    public
     constructor Create(Engine: TRayEngine3D); virtual;
     destructor Destroy; override;

     procedure Draw();
     procedure DoMove(TimeGap: Double); virtual;
     procedure SetMaterialTexture(MatNumber: integer; MapType: integer; Texture: TTexture2D);
     property Position : TVector3 read FPosition write SetPosition;
     property RotationAxis: TVector3 read FRotationAxis write SetRotationAxis;
     property FileName : String read FFileName write SetFileName;
     property Scale:Single read FScale write SetScale;
     property Angle:Single read FAngle write SetAngle;
  end;

implementation

{ TRayModel }

procedure TRayModel.SetPosition(AValue: TVector3);
begin
 FPosition:=AValue;
end;

procedure TRayModel.SetRotationAxis(AValue: TVector3);
begin
  FRotationAxis:=AValue;
end;

procedure TRayModel.SetScale(AValue: Single);
begin
  if FScale=AValue then Exit;
  FScale:=AValue;
  Vector3Set(@FScaleV,FScale,FScale,FScale);
end;

procedure TRayModel.SetFileName(AValue: String);
begin
  if FFileName=AValue then Exit;
  FFileName:=AValue;
  FModel := LoadModel(PChar(FFileName));
end;

procedure TRayModel.SetAngle(AValue: Single);
begin
  if FAngle=AValue then Exit;
  FAngle:=AValue;
end;

procedure TRayModel.Draw();
begin
  DrawModelEX(FModel, FPosition, FRotationAxis, FAngle, FScaleV, WHITE); // Draw 3d model with texture
end;

procedure TRayModel.DoMove(TimeGap: Double);
begin
 // FPosition.z:=FPosition.z+0.01;
  FrotationAxis.x:=FrotationAxis.x+1;
  FrotationAxis.z:=FrotationAxis.z+1;
  self.Angle:=Angle+0.5;
end;

procedure TRayModel.SetMaterialTexture(MatNumber: integer; MapType: integer;
  Texture: TTexture2D);
begin
// SetMaterialTexture(@dwarf.materials[0], MAP_DIFFUSE, texture);
  ray_headers.SetMaterialTexture(@FModel.materials[MatNumber], MapType , Texture);
end;

constructor TRayModel.Create(Engine: TRayEngine3D);
begin
  FEngine := Engine;
  FEngine.FList.Add(Self);
end;

destructor TRayModel.Destroy;
begin
  inherited Destroy;
end;

{ TRayEngine3D }
procedure TRayEngine3D.SetWorld(AValue: TVector3);
begin
  FWorld:=AValue;
end;

function TRayEngine3D.GetCamera: TCamera;
begin
  result:=FCamera;
end;

procedure TRayEngine3D.SetCamera(AValue: TCamera);
begin
  FCamera:=AValue;
end;

procedure TRayEngine3D.Draw();
var
  i: Integer;
begin
  BeginMode3d(FCamera);
  DrawGrid(10, 0.5); // Draw a grid

  for i := 0 to FList.Count - 1 do
  begin
     TRayModel(FList.Items[i]).Draw;
  end;
  EndMode3d();
end;

procedure TRayEngine3D.ClearDeadModel;
var i: Integer;
begin
 for i := 0 to FDeadList.Count - 1 do
  begin
    if FDeadList.Count >= 1 then
      if TRayModel(FDeadList.Items[i]).FModelDead = True then
      TRayModel(FDeadList.Items[i]).FEngine.FList.Remove(FDeadList.Items[i]);
  end;
  FDeadList.Clear;
end;

procedure TRayEngine3D.Move(TimeGap: Double);
var i: Integer;
begin
 UpdateCamera(@FCamera);
 for i := 0 to FList.Count - 1 do
  begin
   TRayModel(FList.Items[i]).DoMove(TimeGap)
  end;
end;

constructor TRayEngine3D.Create;
begin
  FList := TList.Create;
  FDeadList := TList.Create;
end;

destructor TRayEngine3D.Destroy;
var  i: Integer;
begin
 for i := 0 to FList.Count - 1 do
  TRayModel(FList.Items[i]).Destroy;
  FList.Destroy;
  FDeadList.Destroy;
  inherited Destroy;
end;

end.

