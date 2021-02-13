unit ray_sprite;

{$mode objfpc}{$H+}
{$WARN 5024 off : Parameter "$1" not used}
interface

uses
 ray_headers, Classes, SysUtils;

type
 TCollideMode = (cmRecs, cmCircles, cmCircleRec, cmPointRec, cmPointCircle, cmPointTriangle, cmLines);

 TCircle = record
    Center: TVector2;
    Radius: single;
 end;

 { TRay2DEngine }
 TRay2DEngine = class
  private
   FList: TList;
   FDeadList: TList;
   FVisibleHeight: Integer;
   FVisibleWidth: Integer;
   FWorld: TVector3;
   procedure SetWorldX(Value: Single);
   procedure SetWorldY(Value: Single);
  public
   procedure Draw();
   procedure ClearDeadSprites;
   procedure Move(TimeGap: Double);
   procedure SetZOrder();
   constructor Create;
   destructor Destroy; override;
   property VisibleWidth: Integer read FVisibleWidth write FVisibleWidth;
   property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
   property WorldX: Single read FWorld.X write SetWorldX;
   property WorldY: Single read FWorld.Y write SetWorldY;
  end;

 { TRay2DEngineHex }
 type TPointType = (ptRowCol,ptXY); { Used in the Convertcoords function }

  TRay2DEngineHex = class (TRay2DEngine)
   private
     FCamera: TCamera2d;
     FHexColor: TColor;
     FHexColumns: Integer;
     FHexMapOn: Boolean;
     FHexRadius: Integer;
     FHexRows: Integer;
     FHexShowLabels: Boolean;
     FLineColor: TColor;
     FXorRow: Integer;
     FYorCol: Integer;

     Rise:integer; {Distance from center to top of hex, need to compute each}
     function findrange(Bpoint:Tpoint;Epoint:TPoint):Integer;
     procedure SetHexColor(AValue: TColor);
     procedure SetHexColumns(AValue: Integer);
     procedure SetHexGrid(AValue: Boolean);
     procedure SetHexRadius(AValue: Integer);
     procedure SetHexRows(AValue: Integer);
     procedure SetHexShowLabels(AValue: Boolean);
     procedure MakeSolidMap;
     procedure SetLineColor(AValue: TColor);
     procedure DrawSolidHex(Fillcolor : TColor;      { Color to fill it }
                            LineColor : Tcolor;      { What color for lines }
                            x,y,radius: integer);     { Position and size of Hex }

   public
     constructor Create;
     destructor Destroy; override;
     procedure Draw();
     procedure Move(TimeGap: Double);
          {returns the range in hexes from Bpoint to EPoint}
     function RangeInHexes(Bpoint:Tpoint;Epoint:TPoint):Integer;
     procedure PaintAHex(HexColorWanted : TColor;MapLocation:TPoint);
     function ConvertCoords(point:Tpoint; pointtype:Tpointtype):Tpoint;


     property HexColor: TColor read FHexColor write SetHexColor;
     property LineColor: TColor read FLineColor write SetLineColor;

     property XorRow: Integer read FXorRow write FXorRow;
     property YorCol: Integer read FYorCol write FYorCol;

     property Camera: TCamera2d read FCamera write FCamera;

   published

     property MapGridOn: Boolean read FHexMapOn write SetHexGrid;
     property HexColumns: Integer read FHexColumns write SetHexColumns;
     property HexRows: Integer read FHexRows write SetHexRows;
     property HexRadius: Integer read FHexRadius write SetHexRadius;
     property HexShowLabels: Boolean read FHexShowLabels write SetHexShowLabels;


 end;

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

   { TRaySprite }

   TRaySprite = class
  private
    FDoCollision: Boolean;
    FAnimated: Boolean;
    FCollideCircle: TCircle;
    FCollideMode: TCollideMode;
    FCollidePoint: TVector2;
    FCollideRecs: TRectangle;
    FCollisioned: Boolean;
    FdbgCollide: Boolean;
    FVector: TVector3;
    FZ: Single;
    FScale: Single;
  protected
    FEngine: TRay2DEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
    procedure DoCollision(const Sprite: TRaySprite); virtual;
  public
    FTexture: TRayTexture;
    Alpha: Byte;
    Angle: Single;
    IsSpriteDead: Boolean;
    Visible: Boolean;
    Pattern: TRectangle;
    procedure Draw();
    procedure DoMove(TimeGap: Double); virtual;
    procedure Dead();
    procedure SetOrder(Value: Single);
    procedure SetScale(Value: Single);
    procedure Collision(const Other: TRaySprite); overload; virtual;
    procedure Collision; overload; virtual;


    constructor Create(Engine: TRay2DEngine; Texture: TRayTexture); virtual;
    destructor Destroy; override;
    property dbgCollide: Boolean read FdbgCollide write FdbgCollide;
    property CollideRecs: TRectangle read FCollideRecs write FCollideRecs;
    property CollideCircle: TCircle read FCollideCircle write FCollideCircle;
    property CollidePoint: TVector2 read FCollidePoint write FCollidePoint;
    property CollideMode: TCollideMode read FCollideMode write FCollideMode;
    property Collisioned: Boolean read FCollisioned write FCollisioned;

    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FZ write SetOrder;
    property Scale: Single read FScale write SetScale;
  end;


  { TRayAnimatedSprite }
  TRayAnimatedSprite = class(TRaySprite)
  protected
    FDoAnimated: Boolean;
   // FSplited: array of TRect;
    FPatternIndex: Integer;
    FPatternHeight: Integer;
    FPatternWidth: Integer;
    procedure SetPatternHeight(Value: Integer);
    procedure SetPatternWidth(Value: Integer);
  public
    AnimLooped: Boolean;
    AnimStart: Integer;
    AnimCount: Integer;
    AnimSpeed: Single;
    AnimPos: Single;

    procedure Draw();
    procedure DoMove(TimeGap: Double); override;
    procedure DoAnim(Looped: Boolean; Start: Integer; Count: Integer; Speed: Single);

    constructor Create(Engine: TRay2DEngine; Texture: TRayTexture); override;
    destructor Destroy; override;

    property PatternHeight: Integer read FPatternHeight write SetPatternHeight;
    property PatternWidth: Integer read FPatternWidth write SetPatternWidth;
  end;


implementation

{ TRay2DEngineHex }

procedure TRay2DEngineHex.SetHexColumns(AValue: Integer);
begin
  if FHexColumns=AValue then Exit;
  FHexColumns:=AValue;
end;

function TRay2DEngineHex.findrange(Bpoint: Tpoint; Epoint: TPoint): Integer;
 var
  bdx, bdy:integer;
  edx, edy:integer;
  AddToX:Boolean;
  HexCount:Integer;
  GoalReached:Boolean;
  loopcount:integer;
  StopX, StopY:Boolean;
 begin
  loopcount:=HexColumns * Hexrows;
  AddToX:=False;
  HexCount:=0;
  GoalReached := False;
  StopX:=False;
  StopY:=False;
  {bpoint is position you clicked on}
  if Bpoint.y>Epoint.y
   then
    begin
     bdy:=Bpoint.y;
     bdx:=Bpoint.x;
     edy:=Epoint.y;
     edx:=Epoint.x;
     if bdx<edx then AddToX := True;
    end
   else
    begin
     bdy:=Epoint.y;
     bdx:=Epoint.x;
     edy:=Bpoint.y;
     edx:=Bpoint.x;
     if bdx<edx then AddToX := True;
    end;
  Repeat
   begin
    dec(loopcount);
    if not odd(bdx) then
     begin
      inc(HexCount);
      if bdx<>edx then
       begin
        if addtox = true then bdx:=bdx+1;
        if addtox = false then bdx:=bdx-1;
        if bdx=edx then StopX:=True;
       end
      else
       if bdy<>edy then bdy:=bdy-1;
     end
    else
     begin
      inc(HexCount);
      if bdx<>edx then
       begin
        if addtox = true then bdx:=bdx+1;
        if addtox = false then bdx:=bdx-1;
        if bdx=edx then StopX:=True;
       end;
      if bdy<>edy then bdy:=bdy-1;
      if bdy=edy then StopY:=True;
     end;
   end;
  if (bdx=edx) and (bdy=edy) then GoalReached:=True;
  until (GoalReached = True) or (loopcount<=0);
  findrange:=abs(HexCount);
 end;


procedure TRay2DEngineHex.SetHexColor(AValue: TColor);
begin
 // if FHexColor=AValue then Exit;
  FHexColor:=AValue;
end;

procedure TRay2DEngineHex.SetHexGrid(AValue: Boolean);
begin
  if FHexMapOn=AValue then Exit;
  FHexMapOn:=AValue;
end;

procedure TRay2DEngineHex.SetHexRadius(AValue: Integer);
begin
  if FHexRadius=AValue then Exit;
  FHexRadius:=AValue;
end;

procedure TRay2DEngineHex.SetHexRows(AValue: Integer);
begin
  if FHexRows=AValue then Exit;
  FHexRows:=AValue;
end;

procedure TRay2DEngineHex.SetHexShowLabels(AValue: Boolean);
begin
  if FHexShowLabels=AValue then Exit;
  FHexShowLabels:=AValue;
end;

procedure TRay2DEngineHex.MakeSolidMap;
var
 p0:tpoint;
 looprow,loopcol:integer;
 hex_id : string;
begin

  {draw hexes left to right / top to bottom}
     for looprow := 1 to HexRows do
      begin
       for loopcol := 1 to HexColumns do
        begin
         {compute center coordinates}
        p0 := convertcoords(point(Loopcol,Looprow),ptROWCOL);
         {draw the hex}
         if MapGridOn = True then drawsolidhex(hexcolor,linecolor,p0.x,p0.y,hexradius);
         {If desired, draw label for hex}
         if HexShowLabels = true then
         begin
           hex_id := format('%.2d%.2d',[loopcol,looprow]);
           DrawText(PChar(hex_id),P0.x - Round(TextLength(Pchar(hex_id)) div 2)  ,
           P0.Y - Round(TextLength(Pchar(hex_id)) div 2),
           10, Red);
         end;
        end;
      end;
end;
{******************************************************************************}
{  This function will return the Row / Col pair based on a given X/Y
   for a using application that calls it}
function TRay2DEngineHex.ConvertCoords(point: Tpoint; pointtype: Tpointtype
  ): Tpoint;
var
  temp:TPoint;
begin
  case PointType of
     ptXY: {Convert from x/y to Row/Col}
     Begin
       temp.x:= round( (point.x + (HexRadius/2) ) / (1.5 * Hexradius));
       if odd(temp.x) then
          temp.y := round( (point.y + rise) / (rise*2))
       else
          temp.y := round( point.y  / (2*rise));

       { This section insures row / col is good}
      if (temp.x < 1) or (temp.y < 1) then
         begin
           temp.x := 0;
           temp.y := 0;
          end
       else if (temp.y > HexRows) or (temp.x > HexColumns) then
         begin
           temp.y := 0;
           temp.x := 0;
         end;
       ConvertCoords := temp;
     end;

     ptRowCol:  { Converts Row/Col to X/Y }
     begin
       if point.x=1 then
        temp.x:= HexRadius
       else
        temp.x := HexRadius+(point.x-1) * (round(1.5 * hexradius));
       if odd(point.x) then
        if point.y=1 then
           temp.y:= rise
        else
           temp.y := rise+(point.y-1) * (2 * rise)
       else
         temp.y := (point.y * (2*rise));
      ConvertCoords := temp;
     end;

   end;
end;

procedure TRay2DEngineHex.DrawSolidHex(Fillcolor: TColor; LineColor: Tcolor; x,
  y, radius: integer);
var
  p0:TVector2;
begin
   p0 := Vector2create(x,y);
   DrawPoly(Vector2create(x,y), 6, Radius, 30, FHexColor);
   DrawPolyLines(P0, 6, Radius, 30, FLineColor);
end;

procedure TRay2DEngineHex.SetLineColor(AValue: TColor);
begin
  FLineColor := AValue;
end;

constructor TRay2DEngineHex.Create;
begin
  inherited Create;
   FHexMapOn := True;
   FHexColumns := 9;
   FHexRows := 9;
   FHexRadius := 64;
   FHexShowLabels := False;
   FHexColor := Gray;
   FLineColor := Black;

   rise := round(Sqrt(sqr(FHexRadius)-sqr(FhexRadius/2)));

   MakeSolidMap;
end;

destructor TRay2DEngineHex.Destroy;
begin
  inherited Destroy;
end;

procedure TRay2DEngineHex.Draw();
var position :tpoint;
begin
  MakeSolidMap;

end;

procedure TRay2DEngineHex.Move(TimeGap: Double);
var position :tpoint;
    posVec:TVector2;
begin
//   FCamera

   position := self.convertcoords(point(GetMouseX+Round(Self.WorldX),
   GetMouseY+Round(Self.WorldY)),ptXY);


   FXorRow:= Position.X;
   FYorCol:= Position.Y;
end;

{******************************************************************************}
{This function will return the range in hexes between a starting hex
 point and a ending hex point for a using application that calls it}
function TRay2DEngineHex.RangeInHexes(Bpoint: Tpoint; Epoint: TPoint): Integer;
var
 dx, tdx, tempdx:integer;
 dy:integer;
 dist:integer;
begin
  {if it's in the same column or row}
  if (Epoint.x-Bpoint.x = 0) or (Epoint.y-Bpoint.y = 0)
  then
   Begin
    dx:=Epoint.x-Bpoint.x;
    dy:=Epoint.y-Bpoint.y;
    dist:=abs(dx)+abs(dy);
   end
 else
  begin
    {it's not in the same column or row}
    dist:=findrange(Bpoint, Epoint);
  end;
 RangeInHexes := dist;
end;


procedure TRay2DEngineHex.PaintAHex(HexColorWanted: TColor; MapLocation: TPoint
  );
var
 p0:tpoint;
begin
 if FHexMapOn then
  begin
   p0 := convertcoords(point(MapLocation.x,MapLocation.y),ptROWCOL);
   drawsolidhex(GREEN,linecolor,P0.X,P0.Y,hexradius div 2);
  end;
end;

{ TRayAnimatedSprite }

procedure TRayAnimatedSprite.SetPatternHeight(Value: Integer);
begin
  FPatternHeight := Value;
  Pattern.Height := Value;
end;

procedure TRayAnimatedSprite.SetPatternWidth(Value: Integer);
begin
  FPatternWidth := Value;
  Pattern.Width := Value;
end;

function SetPattern(ATexture: TTexture2D; PatternIndex, PatternWidth, PatternHeight: Integer): TRectangle;
var  FTexWidth,FTexHeight:integer;
  ColCount, RowCount, FPatternIndex:integer;
  Left,Right, Top, Bottom:integer;
  FWidth,FHeight:integer;
  X1,Y1,X2,Y2:integer;
begin

   FTexWidth := ATexture.Width;
   FTexHeight := ATexture.Height;

   ColCount := FTexWidth div PatternWidth;
   RowCount := FTexHeight div PatternHeight;

   FPatternIndex := PatternIndex;

  if FPatternIndex < 0 then
    FPatternIndex := 0;

  if FPatternIndex >= RowCount * ColCount then
    FPatternIndex := RowCount * ColCount - 1;

   Left := (FPatternIndex mod ColCount) * PatternWidth;
   Right := Left + PatternWidth;
   Top := (FPatternIndex div ColCount) * PatternHeight;
   Bottom := Top + PatternHeight;

   FWidth := Right - Left;
   FHeight := Bottom - Top;
   X1 := Left;
   Y1 := Top;
   X2 := (Left + FWidth);
   Y2 := (Top + FHeight);
  Result :=RectangleCreate(Round(X1), Round(Y1), Round(X2), Round(Y2));
end;

procedure TRayAnimatedSprite.Draw();
var Scales: Single;
    Origin: TVector2;
    Source: TRectangle;
    Dest: TRectangle;
begin
 if Visible then
   if (FEngine <> nil) and (TextureIndex <> -1) then
    begin
      if (X > FEngine.WorldX - FTexture.Pattern[FTextureIndex].Width) and
      (Y > FEngine.WorldY - FTexture.Pattern[FTextureIndex].Height) and
      (X < FEngine.WorldX + FEngine.VisibleWidth) and
      (Y < FEngine.WorldY + FEngine.VisibleHeight) then
    begin
     Origin:=Vector2Create (FPatternWidth/2,FPatternHeight/2);
      Scales:=FScale;

      Source:=SetPattern(FTexture.Texture[FTextureIndex],FPatternIndex,
     Round(FPatternWidth), Round(FPatternHeight));

      Dest:=RectangleCreate(
      X+FPatternWidth/2*scale,
      Y+FPatternHeight/2*scale,
      FPatternWidth*scale,FPatternHeight*scale);

            if FdbgCollide then
    case CollideMode of
      cmRecs:DrawRectanglePro(Dest,Origin,Angle,RED);
    end;
       DrawTextureTiled(FTexture.Texture[FTextureIndex],Source,Dest,Origin,Angle,Scales,White);
//       DrawLineBezier(Origin,GetMousePosition,2,RED);
    end;



    end;
end;

procedure TRayAnimatedSprite.DoMove(TimeGap: Double);
begin
  inherited DoMove(TimeGap);
    if AnimSpeed > 0 then
  begin
    AnimPos := AnimPos + AnimSpeed;
    FPatternIndex := Trunc(AnimPos);
    if (Round(AnimPos) > AnimStart + AnimCount) then
    begin
      if (Round(AnimPos)) = AnimStart + AnimCount then
        if AnimLooped then
        begin
          AnimPos := AnimStart;
          FPatternIndex := Round(AnimPos);
        end
        else
        begin
          AnimPos := AnimStart + AnimCount - 2;
          FPatternIndex := Round(AnimPos);
        end;
    end;
    if FDoAnimated = True then
    begin
      if Round(AnimPos) >= AnimCount  then
      begin
        FDoAnimated := False;
        AnimLooped := False;
        AnimSpeed := 0;
        AnimCount := 0;
        AnimPos := AnimStart;
        FPatternIndex := Round(AnimPos);
      end;
    end;
    if Round(AnimPos) < AnimStart then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Trunc(AnimPos);
    end;
    if Round(AnimPos) > AnimCount then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Round(AnimPos);
    end;
  end; // if AnimSpeed > 0
end;

procedure TRayAnimatedSprite.DoAnim(Looped: Boolean; Start: Integer;
  Count: Integer; Speed: Single);
begin
  FDoAnimated := True;
  AnimLooped := Looped;
  AnimStart := Start;
  AnimCount := Count;
  AnimSpeed := Speed;
end;

constructor TRayAnimatedSprite.Create(Engine: TRay2DEngine; Texture: TRayTexture
  );
begin
  inherited Create(Engine, Texture);
  FAnimated := True;
end;

destructor TRayAnimatedSprite.Destroy;
begin
  inherited Destroy;
end;

{ TRaySprite }

procedure TRaySprite.SetTextureName(Value: string);
var i: Integer;
begin
  FTextureName := Value;
  for i := 0 to Length(FTexture.TextureName) - 1 do
  begin
   if LowerCase(FTextureName) = LowerCase(FTexture.TextureName[i]) then
    begin
      TextureIndex := i;
      Pattern.Height := FTexture.Pattern[i].Height;
      Pattern.Width := FTexture.Pattern[i].Width;
      Exit;
    end;
  end;
  TextureIndex := -1;
end;

procedure TRaySprite.SetTextureIndex(Value: Integer);
begin
  FTextureIndex := Value;
  Pattern.Height := FTexture.Pattern[FTextureIndex].Height;
  Pattern.Width := FTexture.Pattern[FTextureIndex].Width;
end;

procedure TRaySprite.DoCollision(const Sprite: TRaySprite);
begin

end;

procedure TRaySprite.Draw();
var Scales: Single;
    Origin: TVector2;
    Source: TRectangle;
    Dest: TRectangle;
begin
 if Visible then
   if (FEngine <> nil) and (TextureIndex <> -1) then
    begin
      if (X > FEngine.WorldX - FTexture.Pattern[FTextureIndex].Width) and
      (Y > FEngine.WorldY - FTexture.Pattern[FTextureIndex].Height) and
      (X < FEngine.WorldX + FEngine.VisibleWidth) and
      (Y < FEngine.WorldY + FEngine.VisibleHeight) then
      begin



      Scales:=FScale;
      Origin:=Vector2Create(FTexture.Texture[FTextureIndex].Width/2*scale,FTexture.Texture[FTextureIndex].Height/2*scale);
      Source:=RectangleCreate(0,0,FTexture.Texture[FTextureIndex].Width*scale,  FTexture.Texture[FTextureIndex].Height*scale);

      Dest:=RectangleCreate(
      X+FTexture.Texture[FTextureIndex].Width/2*scale,
      Y+FTexture.Texture[FTextureIndex].Height/2*scale,
      FTexture.Texture[FTextureIndex].Width*scale,FTexture.Texture[FTextureIndex].Height*scale);
      DrawTextureTiled(FTexture.Texture[FTextureIndex],Source,Dest,Origin,Angle,Scales,White);
      end;

          if FdbgCollide then
     case CollideMode of
      cmRecs:DrawRectangleRec(Self.CollideRecs,RED);
    end;
   end;

end;

procedure TRaySprite.DoMove(TimeGap: Double);
begin

end;

procedure TRaySprite.Dead();
begin
   if IsSpriteDead = False then
  begin
    IsSpriteDead := True;
    FEngine.FDeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure TRaySprite.SetOrder(Value: Single);
begin
   if FZ <> Value then FZ := Value;
  FEngine.SetZOrder;
end;

procedure TRaySprite.SetScale(Value: Single);
begin
 If Value >=1.0 then
 FScale := Value;
end;

procedure TRaySprite.Collision(const Other: TRaySprite);
var
  IsCollide: Boolean;
begin
 IsCollide := False;
 if (FCollisioned) and (Other.FCollisioned) and (not IsSpriteDead) and (not Other.IsSpriteDead) then
  begin
   case FCollideMode of
    cmRecs: isCollide := CheckCollisionRecs(Self.CollideRecs,Other.CollideRecs);
    cmCircles: isCollide := CheckCollisionCircles(Self.CollideCircle.Center,Self.CollideCircle.Radius,Other.CollideCircle.Center,Other.CollideCircle.Radius);
    cmCircleRec: isCollide:= CheckCollisionCircleRec(Self.CollideCircle.Center,Self.CollideCircle.Radius,Other.CollideRecs);
    cmPointRec: isCollide := CheckCollisionPointRec(Self.CollidePoint,Other.CollideRecs);
    cmPointCircle: isCollide := CheckCollisionPointCircle(Self.CollidePoint,Other.CollideCircle.Center,Other.CollideCircle.Radius);

   end;

    if IsCollide then
    begin
      DoCollision(Other);
      Other.DoCollision(Self);
    end;
  end;

  //TCollideMode = (cmRecs, cmCircles, cmCircleRec, cmPointRec, cmPointCircle, cmPointTriangle, cmLines);
end;

procedure TRaySprite.Collision;
var
  I: Integer;
begin
  if (FEngine <> nil) and (not IsSpriteDead) and (Collisioned) then
  begin
 for I := 0 to FEngine.Flist.Count - 1 do

   Self.Collision(TRaySprite(FEngine.FList.Items[I]));
 //Self.Collision(FEngine.Items[I]);

// TRayAnimatedSprite(FList.Items[i]).Draw;
  end;
end;

constructor TRaySprite.Create(Engine: TRay2DEngine; Texture: TRayTexture);
begin
  FAnimated := False;
  FEngine := Engine;
  FEngine.FList.Add(Self);
  FTexture := Texture;
  Alpha := 255;
  Visible := True;
  Scale:=1.0;
  FDoCollision := False;
  FCollideMode := cmRecs;
  FdbgCollide:= False;
end;

destructor TRaySprite.Destroy;
begin
  inherited Destroy;
end;

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
//
end;

destructor TRayTexture.Destroy;
var  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TextureName[i] := '';
    UnloadTexture(Texture[i]);// := //nil;
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  inherited Destroy;
end;

{ TRay2DEngine }
procedure TRay2DEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure TRay2DEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure TRay2DEngine.Draw();
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if TRaySprite(FList.Items[i]).FAnimated = False then
      TRaySprite(FList.Items[i]).Draw
    else
     TRayAnimatedSprite(FList.Items[i]).Draw;



  end;
end;

procedure TRay2DEngine.ClearDeadSprites;
var i: Integer;
begin
 for i := 0 to FDeadList.Count - 1 do
  begin
    if FDeadList.Count >= 1 then
      if TRaySprite(FDeadList.Items[i]).IsSpriteDead = True then
      TRaySprite(FDeadList.Items[i]).FEngine.FList.Remove(FDeadList.Items[i]);
  end;
  FDeadList.Clear;
end;

procedure TRay2DEngine.Move(TimeGap: Double);
var i: Integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if TRaySprite(FList.Items[i]).FAnimated = False then
       TRaySprite(FList.Items[i]).DoMove(TimeGap)
    else
      TRayAnimatedSprite(FList.Items[i]).DoMove(TimeGap);
  end;
end;

procedure TRay2DEngine.SetZOrder();
var i: Integer; Done: Boolean;
begin
  Done := False;
  repeat
    for i := FList.Count - 1 downto 0 do
    begin
      if i = 0 then
      begin
        Done := True;
        Break;
      end;
      if TRaySprite(FList.Items[i]).Z < TRaySprite(FList.Items[i - 1]).Z then
      begin
       FList.Move(i, i - 1);
       Break;
      end;
    end;
  until Done;
end;

constructor TRay2DEngine.Create;
begin
  FList := TList.Create;
  FDeadList := TList.Create;
end;

destructor TRay2DEngine.Destroy;
var  i: Integer;
begin
 for i := 0 to FList.Count - 1 do
  TRaySprite(FList.Items[i]).Destroy;
  FList.Destroy;
  FDeadList.Destroy;
 // inherited Destroy;
end;

end.

