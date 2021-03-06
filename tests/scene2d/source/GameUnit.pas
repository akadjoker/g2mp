unit GameUnit;

interface

uses
  Gen2MP,
  G2Types,
  G2Math,
  G2Utils,
  G2DataManager,
  G2Scene2D,
  Types,
  Classes;

type
  TGame = class
  protected
  public
    var Scene: TG2Scene2D;
    var Disp: TG2Display2D;
    var Ground, Box, Box1: TG2Scene2DEntity;
    var TexBox: TG2Texture2D;
    var TexStone: TG2Texture2D;
    constructor Create;
    destructor Destroy; override;
    procedure Initialize;
    procedure Finalize;
    procedure Update;
    procedure Render;
    procedure KeyDown(const Key: Integer);
    procedure KeyUp(const Key: Integer);
    procedure MouseDown(const Button, x, y: Integer);
    procedure MouseUp(const Button, x, y: Integer);
    procedure Scroll(const y: Integer);
    procedure Print(const c: AnsiChar);
  end;

var
  Game: TGame;

implementation

//TGame BEGIN
constructor TGame.Create;
begin
  g2.CallbackInitializeAdd(@Initialize);
  g2.CallbackFinalizeAdd(@Finalize);
  g2.CallbackUpdateAdd(@Update);
  g2.CallbackRenderAdd(@Render);
  g2.CallbackKeyDownAdd(@KeyDown);
  g2.CallbackKeyUpAdd(@KeyUp);
  g2.CallbackMouseDownAdd(@MouseDown);
  g2.CallbackMouseUpAdd(@MouseUp);
  g2.CallbackScrollAdd(@Scroll);
  g2.CallbackPrintAdd(@Print);
  g2.Params.MaxFPS := 100;
  g2.Params.Width := 1024;
  g2.Params.Height := 768;
  g2.Params.ScreenMode := smWindow;
end;

destructor TGame.Destroy;
begin
  g2.CallbackInitializeRemove(@Initialize);
  g2.CallbackFinalizeRemove(@Finalize);
  g2.CallbackUpdateRemove(@Update);
  g2.CallbackRenderRemove(@Render);
  g2.CallbackKeyDownRemove(@KeyDown);
  g2.CallbackKeyUpRemove(@KeyUp);
  g2.CallbackMouseDownRemove(@MouseDown);
  g2.CallbackMouseUpRemove(@MouseUp);
  g2.CallbackScrollRemove(@Scroll);
  g2.CallbackPrintRemove(@Print);
  inherited Destroy;
end;

procedure TGame.Initialize;
  var RigidBody: TG2Scene2DComponentRigidBody;
  var EdgeShape: TG2Scene2DComponentCollisionShapeEdge;
  var PolyShape: TG2Scene2DComponentCollisionShapePoly;
  var CircleShape: TG2Scene2DComponentCollisionShapeCircle;
  var Sprite: TG2Scene2DComponentSprite;
  var Background: TG2Scene2DComponentBackground;
  var fs: TG2DataManager;
  var jd: TG2Scene2DDistanceJoint;
  var jr: TG2Scene2DRevoluteJoint;
  var pm: TG2Scene2DComponentPoly;
  var varr: TG2QuickListVec2;
  var i: Integer;
begin
  Disp := TG2Display2D.Create;
  Disp.Height := 10;
  Disp.Width := Round(g2.Params.Width / g2.Params.Height) * Disp.Height;
  Disp.Zoom := 0.5;
  Scene := TG2Scene2D.Create;
  if True then
  begin
    Ground := TG2Scene2DEntity.Create(Scene);
    RigidBody := TG2Scene2DComponentRigidBody.Create(Scene);
    RigidBody.Attach(Ground);
    RigidBody.MakeStatic;
    RigidBody.Position := G2Vec2(0, 5);
    RigidBody.Enabled := True;
    PolyShape := TG2Scene2DComponentCollisionShapeBox.Create(Scene);
    PolyShape.SetUpBox(10, 0.2);
    PolyShape.Attach(Ground);
    //EdgeShape := TG2Scene2DComponentCollisionShapeEdge.Create(Scene);
    //EdgeShape.SetUp(G2Vec2(5, 0), G2Vec2(-5, 0));
    //EdgeShape.Attach(Ground);
    Box := TG2Scene2DEntity.Create(Scene);
    //Sprite := TG2Scene2DComponentSprite.Create(Scene);
    //Sprite.Texture := TexBox;
    //Sprite.TexCoords := TexBox.TexCoords;
    //Sprite.Width := TexBox.SizeTU * 0.5;
    //Sprite.Height := TexBox.SizeTV * 0.5;
    //Sprite.Scale := 5;
    //Sprite.Filter := tfLinear;
    //Sprite.Attach(Box);
    //Sprite.Layer := 1;
    //Background := TG2Scene2DComponentBackground.Create(Scene);
    //Background.Texture := TexStone;
    //Background.Scale.SetValue(5, 5);
    //Background.Attach(Box);

    //RigidBody := TG2Scene2DComponentRigidBody.Create(Scene);
    //RigidBody.Attach(Box);
    //RigidBody.Enabled := True;
    //RigidBody.MakeDynamic;
    //PolyShape := TG2Scene2DComponentCollisionShapePoly.Create(Scene);
    //PolyShape.SetUpBox(0.25, 0.25);
    //PolyShape.Attach(Box);
    Box1 := TG2Scene2DEntity.Create(Scene);
    Sprite := TG2Scene2DComponentSprite.Create(Scene);
    Sprite.Picture := TG2Picture.SharedAsset('Wall.png', tu3D);
    Sprite.Width := Sprite.Picture.TexCoords.w * 0.5;
    Sprite.Height := Sprite.Picture.TexCoords.h * 0.5;
    Sprite.Filter := tfLinear;
    Sprite.Attach(Box1);
    Sprite.Layer := 2;
    RigidBody := TG2Scene2DComponentRigidBody.Create(Scene);
    RigidBody.Attach(Box1);
    RigidBody.Position := G2Vec2(0.1, -3);
    RigidBody.Enabled := True;
    RigidBody.MakeDynamic;
    CircleShape := TG2Scene2DComponentCollisionShapeCircle.Create(Scene);
    CircleShape.SetUp(G2Vec2(0, 0.25), 0.25);
    CircleShape.Attach(Box1);
    PolyShape := TG2Scene2DComponentCollisionShapeBox.Create(Scene);
    PolyShape.SetUpBox(0.5, 0.5, G2Vec2(0.125, 0), 0);
    PolyShape.Attach(Box1);

    Box := TG2Scene2DEntity.Create(Scene);
    Sprite := TG2Scene2DComponentSprite.Create(Scene);
    Sprite.Picture := TG2Picture.SharedAsset('Stone2.png', tu3D);
    Sprite.Width := Sprite.Picture.TexCoords.w * 0.5;
    Sprite.Height := Sprite.Picture.TexCoords.h * 0.5;
    Sprite.Filter := tfLinear;
    Sprite.Attach(Box);
    Sprite.Layer := 2;
    //Sprite.Transform.p.SetValue(2, -5);
    RigidBody := TG2Scene2DComponentRigidBody.Create(Scene);
    RigidBody.Attach(Box);
    RigidBody.Position := G2Vec2(2, -5);
    RigidBody.Enabled := True;
    RigidBody.MakeDynamic;
    PolyShape := TG2Scene2DComponentCollisionShapeBox.Create(Scene);
    PolyShape.SetUpBox(0.5, 0.5, G2Vec2(0, 0), 0);
    PolyShape.Attach(Box);

    //j := TG2Scene2DDistanceJoint.Create(Scene);
    //j.RigidBodyA := TG2Scene2DComponentRigidBody(Box.ComponentOfType[TG2Scene2DComponentRigidBody]);
    //j.RigidBodyB := TG2Scene2DComponentRigidBody(Ground.ComponentOfType[TG2Scene2DComponentRigidBody]);
    //j.AnchorB.SetValue(0, -10);
    //j.Distnace := 3;
    //j.Enabled := True;

    jr := TG2Scene2DRevoluteJoint.Create(Scene);
    jr.RigidBodyA := TG2Scene2DComponentRigidBody(Box.ComponentOfType[TG2Scene2DComponentRigidBody]);
    jr.RigidBodyB := TG2Scene2DComponentRigidBody(Box1.ComponentOfType[TG2Scene2DComponentRigidBody]);
    jr.Anchor := (jr.RigidBodyA.Position + jr.RigidBodyB.Position) * 0.5;
    jr.Enabled := True;

    varr.Clear;
    varr.Add(G2Vec2(-2, -2));
    varr.Add(G2Vec2(1, -1));
    varr.Add(G2Vec2(-1, 1));
    varr.Add(G2Vec2(-1, 1));
    varr.Add(G2Vec2(1, -1));
    varr.Add(G2Vec2(1, 1));
    pm := TG2Scene2DComponentPoly.Create(Scene);
    pm.SetUp(PG2Vec2Arr(varr.Data), 2);
    pm.LayerCount := 1;
    pm.Layers[0].Texture := TexBox;
    for i := 0 to pm.VertexCount - 1 do
    pm.Layers[0].Color[i].a := 1;
    pm.Layers[0].Color[1].a := 0;
    pm.Layers[0].Layer := 40;
    pm.Layers[0].Visible := True;
    pm.Layers[0].Scale.SetValue(0.5, 0.5);
    pm.Attach(Ground);

    fs := TG2DataManager.Create('scene.g2s2d', dmWrite);
    try
      Scene.Save(fs);
    finally
      fs.Free;
    end;
  end
  else
  begin
    fs := TG2DataManager.Create('scene.g2s2d', dmAsset);
    try
      Scene.Load(fs);
    finally
      fs.Free;
    end;
  end;
  Scene.Simulate := True;
  Disp.Position.SetValue(0, 0);
end;

procedure TGame.Finalize;
begin
  Scene.Free;
  Disp.Free;
end;

procedure TGame.Update;
begin

end;

procedure TGame.Render;
begin
  g2.Clear($ff808080);
  Scene.Render(Disp);
  Scene.DebugDraw(Disp);
end;

procedure TGame.KeyDown(const Key: Integer);
begin

end;

procedure TGame.KeyUp(const Key: Integer);
begin

end;

procedure TGame.MouseDown(const Button, x, y: Integer);
begin

end;

procedure TGame.MouseUp(const Button, x, y: Integer);
begin

end;

procedure TGame.Scroll(const y: Integer);
begin

end;

procedure TGame.Print(const c: AnsiChar);
begin

end;
//TGame END

end.
