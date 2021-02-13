program game;

{$mode objfpc}{$H+}

uses cmem, ray_headers,ray_sprite, math, sysutils,classes;

const
 screenWidth = 800;
 screenHeight = 600;

 var Engine:TRay2DEngineHex;
     Background:TTexture2D;
     position, eposition:TPoint;
     dist:integer;
     Camera:TCamera2d;
begin
{$IFDEF DARWIN}
SetExceptionMask([exDenormalized,exInvalidOp,exOverflow,exPrecision,exUnderflow,exZeroDivide]);
{$IFEND}

 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');
 SetTargetFPS(60);
 background := LoadTexture('space1.png');

 Engine:=TRay2DEngineHex.Create;
 Engine.HexShowLabels:=true;

 Engine.HexColor:=BLANK;

 ENGINE.LineColor:=DARKBLUE;


 // camera.offset := Vector2Create(screenWidth / 2.0, screenHeight / 2.0);
  camera.rotation := 0.0;
  camera.zoom := 1.0;
  Engine.Camera:=Camera;


  while not WindowShouldClose() do
 begin
//  camera.target:=GetMousePosition();
  if IsKeyDown(KEY_RIGHT) then
     camera.target.x:=camera.target.x+10
    else if IsKeyDown(KEY_LEFT) then
      camera.target.x:=camera.target.x-10;
    Engine.WorldX:=Camera.target.x;
   if IsKeyDown(KEY_UP) then
     camera.target.Y:=camera.target.Y-10
    else if IsKeyDown(KEY_DOWN) then
      camera.target.y:=camera.target.y+10;
    Engine.WorldY:=Camera.target.Y;

     camera.zoom := camera.zoom + Single(GetMouseWheelMove) * 0.05;

    if camera.zoom > 1.0 then camera.zoom := 1.0
    else if camera.zoom < 0.5 then camera.zoom := 0.5;


  if IsMouseButtonPressed(MOUSE_LEFT_BUTTON) then
  begin
    position := Engine.convertcoords(point(GetMouseX+Round(Engine.WorldX),GetMouseY+Round(Engine.WorldY)),ptXY);
  end;
  Engine.Move(1);
 // Engine.WorldX:=Camera.offset.x;
  //Engine.WorldY:=Camera.offset.Y;

  BeginDrawing();

  ClearBackground(BLACK);
  BeginMode2D(camera);
 // DrawTextureRec(background,RectangleCreate(0,0,screenWidth,screenHeight),Vector2Create(0,0),WHITE);
 DrawTexture(background,0,0,WHITE);

 Engine.Draw();
 if (position.x <> 0) and (position.y <> 0) then
      begin
        eposition.X:=Engine.XorRow;
        Eposition.Y:=Engine.YorCol;

        EnGINE.HexColor:=SKYBLUE;
        Engine.PaintAHex(SKYBLUE,position);
        Engine.HexColor:=BLANK;
      end;

   dist := Engine.RangeInHexes(position, eposition);
  EndMode2D;

  DrawText('raylib in lazarus !!!', 20, 20, 16, SKYBLUE);

  DrawText(PChar(IntToStr(Engine.XorRow)+' '+Pchar(IntToStr(Engine.YorCol))),20,50,20,Green);
  if (position.x = 0) or (position.y = 0)
  then
   DrawText('Out of Range',20,75,20,GREEN)
  else
   DrawText(Pchar(inttostr(dist)),20,95,20,GREEN);

  EndDrawing();
 end;
CloseWindow(); 

end.

