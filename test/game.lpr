program game;

{$mode objfpc}{$H+}

uses cmem, ray_headers, math;

const
 screenWidth = 800;
 screenHeight = 450;

begin
{$IFDEF DARWIN}
SetExceptionMask([exDenormalized,exInvalidOp,exOverflow,exPrecision,exUnderflow,exZeroDivide]);
{$IFEND}

 InitWindow(screenWidth, screenHeight, 'raylib pascal - basic window');
 SetTargetFPS(60);

 while not WindowShouldClose() do 
 begin
  BeginDrawing();
  ClearBackground(RAYWHITE);

  DrawText('raylib in lazarus !!!', 20, 20, 10, SKYBLUE);

  EndDrawing(); 
 end;
CloseWindow(); 

end.

