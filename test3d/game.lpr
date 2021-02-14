program game;

{$mode objfpc}{$H+}

uses cmem, ray_headers, math, ray_engine3d, ray_texture;

const
 screenWidth = 800;
 screenHeight = 600;
var
 cam: TCamera;
 engine:TRayEngine3d;
 model: TRayModel;
 texture_: TTexture2d;
 texture_n: TTexture2d;
begin
{$IFDEF DARWIN}
SetExceptionMask([exDenormalized,exInvalidOp,exOverflow,exPrecision,exUnderflow,exZeroDivide]);
{$IFEND}

 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');
 SetTargetFPS(60);
   SetConfigFlags(FLAG_MSAA_4X_HINT);

  cam.position := Vector3Create(3.0, 3.0, 3.0);
  cam.target := Vector3Create(0.0, 1.0, 0.0);
  cam.up := Vector3Create(0.0, 1.0, 0.0);
  cam.fovy := 45.0;
  cam._type := CAMERA_PERSPECTIVE;

  engine:=TRayEngine3D.Create;
  engine.Camera:=Cam;

  texture_ := LoadTexture('cobra/griff_cobra_mk3_mainhull_diffuse_spec.png');
  texture_n := LoadTexture('Griff_Wolf MkIII/Texture/Engine&Laser_Glows_Mask.png');

  model:=TRayModel.Create(Engine);
  model.FileName:='cobra/oolite_cobra3.obj';
  model.SetMaterialTexture(0,MAP_DIFFUSE,texture_);
  model.Scale:=0.05;

//  texture_ := LoadTexture('models/dwarf_specular.png');
//  model.SetMaterialTexture(0,MAP_ROUGHNESS,texture_n);


  SetCameraMode(cam, CAMERA_THIRD_PERSON); // Set an orbital camera mode




  while not WindowShouldClose() do
 begin
  Engine.Move(1);

  BeginDrawing();
  ClearBackground(RAYWHITE);

  Engine.Draw();

  DrawText('raylib in lazarus !!!', 20, 20, 20, SKYBLUE);

  EndDrawing(); 
 end;
CloseWindow(); 

end.

