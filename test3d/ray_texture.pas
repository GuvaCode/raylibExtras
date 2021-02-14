unit ray_texture;

{$mode objfpc}{$H+}

interface

uses
  ray_headers;//,Classes, SysUtils;

type
   TPattern = record
    Height, Width: Integer;
  end;

   { TRayTexture }

   TRayTexture = class
  public
    Count: Integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TRayTexture }

function TRayTexture.LoadFromFile(FileName: String; Width, Height: Integer
  ): Boolean;
begin
   if not FileExists(PChar(FileName)) then
  begin
    Result := False;
    Exit;
  end;
  SetLength(Texture, Count + 1);
  SetLength(TextureName, Count + 1);
  SetLength(Pattern, Count + 1);
  Inc(Count);
  TextureName[Count - 1] := FileName;
  Pattern[Count - 1].Height := Height;
  Pattern[Count - 1].Width := Width;
  Texture[Count - 1] := LoadTexture(PChar(FileName));
  Result := True;
end;

constructor TRayTexture.Create;
begin

end;

destructor TRayTexture.Destroy;
var  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TextureName[i] := '';
    UnloadTexture(Texture[i]);
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
    MemFree(@Texture[i]);
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  inherited Destroy;
end;

end.

