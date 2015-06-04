unit Gen2MP;
{$include Gen2MP.inc}
{$if defined(G2Cpu386)}
  {$message 'CPU i386'}
{$endif}
{$if defined(G2Target_Windows)}
  {$message 'Target Windows'}
{$elseif defined(G2Target_Linux)}
  {$message 'Target Linux'}
{$elseif defined(G2Target_OSX)}
  {$message 'Target OSX'}
{$elseif defined(G2Target_Android)}
  {$message 'Target Android'}
{$elseif defined(G2Target_iOS)}
  {$message 'Target iOS'}
  {$modeswitch objectivec1}
  {$linkframework OpenGLES}
  {$linkframework QuartzCore}
  {$linkframework UIKit}
  {$linkframework Foundation}
{$else}
  {$message 'Target Undefined'}
{$endif}
{$if defined(G2Gfx_D3D9)}
  {$message 'Graphics API Direct3D9'}
{$elseif defined(G2Gfx_OGL)}
  {$message 'Graphics API OpenGL'}
{$elseif defined(G2Gfx_GLES)}
  {$message 'Graphics API OpenGL ES'}
{$else}
  {$message 'Graphics API Undefined'}
{$endif}
{$if defined(G2Snd_DS)}
  {$message 'Sound API DirectSound'}
{$elseif defined(G2Snd_OAL)}
  {$message 'Sound API OpenAL'}
{$else}
  {$message 'Sound API Undefined'}
{$endif}
{$if defined(G2RM_FF)}
  {$message 'Render Mode FF'}
{$elseif defined(G2RM_SM2)}
  {$message 'Render Mode SM2'}
{$endif}
interface

uses
  {$if defined(UNIX) and defined(G2Threading)}
    cthreads,
  {$endif}
  {$if defined(G2Target_Windows)}
    Windows,
  {$elseif defined(G2Target_Linux)}
    X,
    XLib,
    XUtil,
    gdk2,
    pango,
  {$elseif defined(G2Target_OSX)}
    MacOSAll,
  {$elseif defined(G2Target_Android)}
    G2AndroidJNI,
    G2AndroidBinding,
  {$elseif defined(G2Target_iOS)}
    iPhoneAll,
    CGGeometry,
  {$endif}
  {$if defined(G2Gfx_D3D9)}
    G2DirectX9,
  {$elseif defined(G2Gfx_OGL)}
    G2OpenGL,
  {$elseif defined(G2Gfx_GLES)}
    {$if defined(G2RM_FF)}
      {$if defined(G2Target_Android)}
        G2OpenGLES11,
      {$elseif defined(G2Target_iOS)}
        OpenGLES11_iOS,
      {$endif}
    {$elseif defined(G2RM_SM2)}
      {$if defined(G2Target_Android)}
        G2OpenGLES20,
      {$elseif defined(G2Target_iOS)}
        OpenGLES20_iOS,
      {$endif}
    {$endif}
  {$endif}
  {$if defined(G2Snd_OAL)}
    {$ifdef G2Target_Android}
      G2OpenALTypes,
      G2OpenAL_Android,
    {$else}
    G2OpenAL,
  {$endif}
  {$elseif defined(G2Snd_DS)}
    G2DirectSound,
    ActiveX,
  {$endif}
  G2Types,
  G2Math,
  G2Utils,
  G2DataManager,
  G2Image,
  G2ImagePNG,
  G2Audio,
  G2AudioWAV,
  G2MeshData,
  {$if defined(G2RM_SM2)}
    G2Shaders,
  {$endif}
  Types,
  Classes,
  SysUtils;

type
  TG2Core = class;
  TG2Window = class;
  TG2Params = class;
  TG2Sys = class;
  TG2Gfx = class;
  {$if defined(G2Gfx_D3D9)}
  TG2GfxD3D9 = class;
  {$elseif defined(G2Gfx_OGL)}
  TG2GfxOGL = class;
  {$endif}
  TG2Snd = class;
  {$if defined(G2Snd_OAL)}
  TG2SndOAL = class;
  {$elseif defined(G2Snd_DS)}
  TG2SndDS = class;
  {$elseif defined(G2Snd_OSL)}
  TG2SndOSL = class;
  {$endif}
  {$ifdef G2Threading}
  TG2Updater = class;
  TG2Renderer = class;
  {$endif}
  TG2Res = class;
  TG2Mgr = class;
  TG2TextureBase = class;
  TG2Texture2DBase = class;
  TG2Texture2D = class;
  TG2Texture2DRT = class;
  TG2Font = class;
  {$if defined(G2RM_SM2)}
  TG2ShaderGroup = class;
  {$endif}
  TG2RenderControl = class;
  TG2RenderControlStateChange = class;
  TG2RenderControlManaged = class;
  TG2RenderControlBuffer = class;
  TG2RenderControlPic2D = class;
  TG2RenderControlPrim2D = class;
  TG2RenderControlPoly2D = class;
  TG2Display2D = class;
  TG2S2DObject = class;
  TG2S2DFrame = class;
  TG2S2DCollider = class;
  TG2S3DMesh = class;
  TG2S3DMeshInst = class;
  TG2S3DParticle = class;
  TG2Scene2D = class;
  TG2Scene3D = class;

  TG2Proc = procedure;
  TG2ProcObj = procedure of Object;
  TG2ProcPtr = procedure (const Ptr: Pointer);
  TG2ProcPtrObj = procedure (const Ptr: Pointer) of Object;
  TG2ProcWndMessage = procedure (const Param1, Param2, Param3: TG2IntS32) of Object;
  TG2ProcChar = procedure (const Char: AnsiChar);
  TG2ProcCharObj = procedure (const Char: AnsiChar) of Object;
  TG2ProcKey = procedure (const Key: TG2IntS32);
  TG2ProcKeyObj = procedure (const Key: TG2IntS32) of Object;
  TG2ProcMouse = procedure (const Button, x, y: TG2IntS32);
  TG2ProcMouseObj = procedure (const Button, x, y: TG2IntS32) of Object;
  TG2ProcScroll = procedure (const y: TG2IntS32);
  TG2ProcScrollObj = procedure (const y: TG2IntS32) of Object;

  CG2RenderControl = class of TG2RenderControl;

  TG2TextureUsage = (
    tuDefault,
    tuUsage2D,
    tuUsage3D
  );

  TG2Filter = (
    tfNone = 0,
    tfPoint = 1,
    tfLinear = 2
  );

  TG2PrimType = (
    ptNone,
    ptLines,
    ptTriangles
  );

  {$ifdef G2Target_Android}
  TG2AndroidMessageType = (
    amConnect = 0,
    amInit = 1,
    amQuit = 2,
    amResize = 3,
    amDraw = 4,
    amTouchDown = 5,
    amTouchUp = 6,
    amTouchMove = 7
  );
  {$endif}

  {$if defined(G2Target_iOS)}
  TG2OpenGLView = objcclass(UIView)
  public
    class function layerClass: Pobjc_class; override;
    function initWithFrame(frame: CGRect): id; override;
    procedure dealloc; override;
    procedure setupLayer; message 'setupLayer';
    procedure setupContext; message 'setupContext';
    procedure setupRenderBuffer; message 'setupRenderBuffer';
    procedure setupFrameBuffer; message 'setupFrameBuffer';
    procedure render; message 'render';
  end;

  TG2AppDelegate = objcclass(UIResponder, UIApplicationDelegateProtocol)
  private
    _Window: UIWindow;
  public
    procedure Loop; message 'Loop';
    function applicationDidFinishLaunchingWithOptions(application: UIApplication; launchOptions: NSDictionary): Boolean; message 'application:didFinishLaunchingWithOptions:';
    procedure applicationWillResignActive(application: UIApplication); message 'applicationWillResignActive:';
    procedure applicationDidEnterBackground(application: UIApplication); message 'applicationDidEnterBackground:';
    procedure applicationWillEnterForeground(application: UIApplication); message 'applicationWillEnterForeground:';
    procedure applicationDidBecomeActive(application: UIApplication); message 'applicationDidBecomeActive:';
    procedure applicationWillTerminate(application: UIApplication); message 'applicationWillTerminate:';
    procedure dealloc; override;
  end;

  TG2ViewController = objcclass(UIViewController)
  public
    function initWithNibName_bundle(nibNameOrNil: NSString; nibBundleOrNil: NSBundle): id; override;
    procedure dealloc; override;
    procedure didReceiveMemoryWarning; override;
    procedure loadView; override;
    //procedure viewDidLoad; override;
    procedure viewDidUnload; override;
    function shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation): Boolean; override;
  end;
  {$endif}

  TG2LinkProc = record
    Obj: Boolean;
    Proc: TG2Proc;
    ProcObj: TG2ProcObj;
  end;

  TG2LinkPrint = record
    Obj: Boolean;
    Proc: TG2ProcChar;
    ProcObj: TG2ProcCharObj;
  end;

  TG2LinkKey = record
    Obj: Boolean;
    Proc: TG2ProcKey;
    ProcObj: TG2ProcKeyObj;
  end;

  TG2LinkMouse = record
    Obj: Boolean;
    Proc: TG2ProcMouse;
    ProcObj: TG2ProcMouseObj;
  end;

  TG2LinkScroll = record
    Obj: Boolean;
    Proc: TG2ProcScroll;
    ProcObj: TG2ProcScrollObj;
  end;

  TG2TargetPlatform = (tpUndefined, tpWindows, tpLinux, tpMacOSX, tpAndroid, tpiOS);

  { TG2Core }

  TG2Core = class
  private
    _Started: Boolean;
    _Window: TG2Window;
    _Params: TG2Params;
    _Sys: TG2Sys;
    _Gfx: TG2Gfx;
    _Snd: TG2Snd;
    _PackLinker: TG2PackLinker;
    {$ifdef G2Threading}
    _Updater: TG2Updater;
    _Renderer: TG2Renderer;
    {$endif}
    _FPS: TG2IntS32;
    _UpdatePrevTime: TG2IntU32;
    _UpdateCount: TG2Float;
    _TargetUPS: TG2IntS32;
    _MaxFPS: TG2IntS32;
    _RenderPrevTime: TG2IntU32;
    _FrameCount: TG2IntS32;
    _FPSUpdateTime: TG2IntU32;
    _CanRender: Boolean;
    _Platform: TG2TargetPlatform;
    _LinkInitialize: array of TG2LinkProc;
    _LinkInitializeCount: TG2IntS32;
    _LinkFinalize: array of TG2LinkProc;
    _LinkFinalizeCount: TG2IntS32;
    _LinkUpdate: array of TG2LinkProc;
    _LinkUpdateCount: TG2IntS32;
    _LinkRender: array of TG2LinkProc;
    _LinkRenderCount: TG2IntS32;
    _LinkPrint: array of TG2LinkPrint;
    _LinkPrintCount: TG2IntS32;
    _LinkKeyDown: array of TG2LinkKey;
    _LinkKeyDownCount: TG2IntS32;
    _LinkKeyUp: array of TG2LinkKey;
    _LinkKeyUpCount: TG2IntS32;
    _LinkMouseDown: array of TG2LinkMouse;
    _LinkMouseDownCount: TG2IntS32;
    _LinkMouseUp: array of TG2LinkMouse;
    _LinkMouseUpCount: TG2IntS32;
    _LinkScroll: array of TG2LinkScroll;
    _LinkScrollCount: TG2IntS32;
    _KeyDown: array[0..255] of Boolean;
    _MBDown: array[0..31] of Boolean;
    _MDPos: array[0..31] of TPoint;
    _ShowCursor: Boolean;
    _MgrGeneral: TG2Mgr;
    _AppPath: FileString;
    _Pause: Boolean;
    {$if defined(G2Target_iOS)}
    _PoolInitialized: Boolean;
    _Delegate: TG2AppDelegate;
    _ViewController: TG2ViewController;
    {$endif}
    {$if defined(G2Target_Android) or defined(G2Target_iOS)}
    _CursorPos: TPoint;
    {$endif}
    procedure Render;
    procedure Update;
    procedure UpdateRender;
    procedure OnRender;
    procedure OnUpdate;
    procedure OnStart;
    procedure OnStop;
    procedure OnPrint(const Char: AnsiChar);
    procedure OnKeyDown(const Key: TG2IntS32);
    procedure OnKeyUp(const Key: TG2IntS32);
    procedure OnMouseDown(const Button: TG2IntS32; const x, y: TG2IntS32);
    procedure OnMouseUp(const Button: TG2IntS32; const x, y: TG2IntS32);
    procedure OnScroll(const y: TG2IntS32);
    function GetKeyDown(const Index: TG2IntS32): Boolean; inline;
    function GetMouseDown(const Index: TG2IntS32): Boolean; inline;
    function GetMouseDownPos(const Index: TG2IntS32): TPoint; inline;
    function GetMousePos: TPoint;
    function GetAppPath: FileString;
    procedure SetShowCursor(const Value: Boolean);
    procedure SetPause(const Value: Boolean);
    function GetDeltaTime: TG2Float;
  public
    property Window: TG2Window read _Window;
    property Params: TG2Params read _Params;
    property Sys: TG2Sys read _Sys;
    property Gfx: TG2Gfx read _Gfx;
    property Snd: TG2Snd read _Snd;
    property PackLinker: TG2PackLinker read _PackLinker;
    property FPS: TG2IntS32 read _FPS;
    property AppPath: FileString read _AppPath;
    property TargetPlatform: TG2TargetPlatform read _Platform;
    property KeyDown[const Index: TG2IntS32]: Boolean read GetKeyDown;
    property MouseDown[const Index: TG2IntS32]: Boolean read GetMouseDown;
    property MouseDownPos[const Index: TG2IntS32]: TPoint read GetMouseDownPos;
    property MousePos: TPoint read GetMousePos;
    property ShowCursor: Boolean read _ShowCursor write SetShowCursor;
    property Pause: Boolean read _Pause write SetPause;
    property DeltaTime: TG2Float read GetDeltaTime;
    {$if defined(G2Target_iOS)}
    property Delegate: TG2AppDelegate read _Delegate write _Delegate;
    {$endif}
    procedure Start;
    procedure Stop;
    {$if defined(G2Target_Android)}
    class procedure AndroidMessage(const Env: PJNIEnv; const Obj: JObject; const MessageType, Param0, Param1, Param2: TG2IntS32);
    {$endif}
    procedure CallbackInitializeAdd(const ProcInitialize: TG2Proc); overload;
    procedure CallbackInitializeAdd(const ProcInitialize: TG2ProcObj); overload;
    procedure CallbackInitializeRemove(const ProcInitialize: TG2Proc); overload;
    procedure CallbackInitializeRemove(const ProcInitialize: TG2ProcObj); overload;
    procedure CallbackFinalizeAdd(const ProcFinalize: TG2Proc); overload;
    procedure CallbackFinalizeAdd(const ProcFinalize: TG2ProcObj); overload;
    procedure CallbackFinalizeRemove(const ProcFinalize: TG2Proc); overload;
    procedure CallbackFinalizeRemove(const ProcFinalize: TG2ProcObj); overload;
    procedure CallbackUpdateAdd(const ProcUpdate: TG2Proc); overload;
    procedure CallbackUpdateAdd(const ProcUpdate: TG2ProcObj); overload;
    procedure CallbackUpdateRemove(const ProcUpdate: TG2Proc); overload;
    procedure CallbackUpdateRemove(const ProcUpdate: TG2ProcObj); overload;
    procedure CallbackRenderAdd(const ProcRender: TG2Proc); overload;
    procedure CallbackRenderAdd(const ProcRender: TG2ProcObj); overload;
    procedure CallbackRenderRemove(const ProcRender: TG2Proc); overload;
    procedure CallbackRenderRemove(const ProcRender: TG2ProcObj); overload;
    procedure CallbackPrintAdd(const ProcPrint: TG2ProcChar); overload;
    procedure CallbackPrintAdd(const ProcPrint: TG2ProcCharObj); overload;
    procedure CallbackPrintRemove(const ProcPrint: TG2ProcChar); overload;
    procedure CallbackPrintRemove(const ProcPrint: TG2ProcCharObj); overload;
    procedure CallbackKeyDownAdd(const ProcKeyDown: TG2ProcKey); overload;
    procedure CallbackKeyDownAdd(const ProcKeyDown: TG2ProcKeyObj); overload;
    procedure CallbackKeyDownRemove(const ProcKeyDown: TG2ProcKey); overload;
    procedure CallbackKeyDownRemove(const ProcKeyDown: TG2ProcKeyObj); overload;
    procedure CallbackKeyUpAdd(const ProcKeyUp: TG2ProcKey); overload;
    procedure CallbackKeyUpAdd(const ProcKeyUp: TG2ProcKeyObj); overload;
    procedure CallbackKeyUpRemove(const ProcKeyUp: TG2ProcKey); overload;
    procedure CallbackKeyUpRemove(const ProcKeyUp: TG2ProcKeyObj); overload;
    procedure CallbackMouseDownAdd(const ProcMouseDown: TG2ProcMouse); overload;
    procedure CallbackMouseDownAdd(const ProcMouseDown: TG2ProcMouseObj); overload;
    procedure CallbackMouseDownRemove(const ProcMouseDown: TG2ProcMouse); overload;
    procedure CallbackMouseDownRemove(const ProcMouseDown: TG2ProcMouseObj); overload;
    procedure CallbackMouseUpAdd(const ProcMouseUp: TG2ProcMouse); overload;
    procedure CallbackMouseUpAdd(const ProcMouseUp: TG2ProcMouseObj); overload;
    procedure CallbackMouseUpRemove(const ProcMouseUp: TG2ProcMouse); overload;
    procedure CallbackMouseUpRemove(const ProcMouseUp: TG2ProcMouseObj); overload;
    procedure CallbackScrollAdd(const ProcScroll: TG2ProcScroll); overload;
    procedure CallbackScrollAdd(const ProcScroll: TG2ProcScrollObj); overload;
    procedure CallbackScrollRemove(const ProcScroll: TG2ProcScroll); overload;
    procedure CallbackScrollRemove(const ProcScroll: TG2ProcScrollObj); overload;
    procedure PicQuadCol(
      const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase; const BlendMode: TG2IntU32 = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicQuadCol(
      const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicQuad(
      const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicQuad(
      const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const TexRect: TG2Vec4;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const tu0, tv0, tu1, tv1: TG2Float;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const Pos: TG2Vec2; const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const x, y: TG2Float; const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const x, y: TG2Float;
      const Width, Height: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const TexRect: TG2Vec4;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const x, y: TG2Float;
      const Width, Height: TG2Float;
      const tu0, tv0, tu1, tv1: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const x, y: TG2Float;
      const Width, Height: TG2Float;
      const Col: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PrimBegin(const PrimType: TG2PrimType; const BlendMode: TG2BlendMode); inline;
    procedure PrimEnd; inline;
    procedure PrimAdd(const x, y: TG2Float; const Color: TG2Color); inline;
    procedure PrimAdd(const Pos: TG2Vec2; const Color: TG2Color); inline;
    procedure PrimLineCol(const Pos0, Pos1: TG2Vec2; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimLineCol(const x0, y0, x1, y1: TG2Float; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimLine(const Pos0, Pos1: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimLine(const x0, y0, x1, y1: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuad(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuad(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimRectCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimRect(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimRectHollowCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimRectHollow(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimCircleCol(const Pos: TG2Vec2; const Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimCircleCol(const x, y, Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriHollowCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriHollowCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadHollowCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadHollowCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimCircleHollow(const Pos: TG2Vec2; const Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimCircleHollow(const x, y, Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    constructor Create;
    destructor Destroy; override;
  end;

  TG2WindowMessage = record
    MessageProc: TG2ProcWndMessage;
    Param1: TG2IntS32;
    Param2: TG2IntS32;
    Param3: TG2IntS32;
  end;

  {$if defined(G2Target_Windows)}
  TG2Cursor = HCursor;
  {$endif}

  { TG2Window }

  TG2Window = class
  private
    {$if defined(G2Target_Windows)}
    _Handle: THandle;
    {$elseif defined(G2Target_Linux)}
    _Display: PDisplay;
    _Handle: TWindow;
    _WMDelete: TAtom;
    _VisualInfo: PXVisualInfo;
    {$elseif defined(G2Target_OSX)}
    _Handle: WindowRef;
    {$elseif defined(G2Target_iOS)}
    _View: TG2OpenGLView;
    {$endif}
    _CursorArrow: TG2Cursor;
    _CursorText: TG2Cursor;
    _CursorHand: TG2Cursor;
    _CursorSizeNS: TG2Cursor;
    _CursorSizeWE: TG2Cursor;
    _Cursor: TG2Cursor;
    _Loop: Boolean;
    _Caption: AnsiString;
    _MessageStack: array of TG2WindowMessage;
    _MessageCount: TG2IntS32;
    procedure AddMessage(const MessageProc: TG2ProcWndMessage; const Param1, Param2, Param3: TG2IntS32);
    procedure ProcessMessages;
    {$Hints off}
    procedure OnPrint(const Key, Param2, Param3: TG2IntS32);
    procedure OnKeyDown(const Key, Param2, Param3: TG2IntS32);
    procedure OnKeyUp(const Key, Param2, Param3: TG2IntS32);
    procedure OnMouseDown(const Button, x, y: TG2IntS32);
    procedure OnMouseUp(const Button, x, y: TG2IntS32);
    procedure OnScroll(const y, Param2, Param3: TG2IntS32);
    {$Hints on}
    procedure Stop; inline;
    procedure SetCaption(const Value: AnsiString); inline;
    procedure SetCursor(const Value: TG2Cursor);
  public
    {$if defined(G2Target_Windows)}
    property Handle: THandle read _Handle;
    {$elseif defined(G2Target_Linux)}
    property Display: PDisplay read _Display;
    property Handle: TWindow read _Handle;
    property VisualInfo: PXVisualInfo read _VisualInfo;
    {$elseif defined(G2Target_OSX)}
    property Handle: WindowRef read _Handle;
    {$elseif defined(G2Target_iOS)}
    property View: TG2OpenGLView read _View write _View;
    {$endif}
    property Cursor: TG2Cursor read _Cursor write SetCursor;
    property CursorArrow: TG2Cursor read _CursorArrow;
    property CursorText: TG2Cursor read _CursorText;
    property CursorHand: TG2Cursor read _CursorHand;
    property CursorSizeNS: TG2Cursor read _CursorSizeNS;
    property CursorSizeWE: TG2Cursor read _CursorSizeWE;
    property Caption: AnsiString read _Caption write SetCaption;
    property IsLooping: Boolean read _Loop;
    procedure Loop;
    constructor Create(const Width: TG2IntS32 = 0; const Height: TG2IntS32 = 0; const NewCaption: AnsiString = 'Gen2MP');
    destructor Destroy; override;
  end;

  TG2ScreenMode = (smWindow, smMaximized, smFullscreen);

  TG2Params = class
  private
    _ScreenWidth: TG2IntS32;
    _ScreenHeight: TG2IntS32;
    _Width: TG2IntS32;
    _Height: TG2IntS32;
    _WidthRT: TG2IntS32;
    _HeightRT: TG2IntS32;
    _ScreenMode: TG2ScreenMode;
    _TargetUPS: TG2IntS32;
    _MaxFPS: TG2IntS32;
  public
    property ScreenWidth: TG2IntS32 read _ScreenWidth;
    property ScreenHeight: TG2IntS32 read _ScreenHeight;
    property Width: TG2IntS32 read _Width write _Width;
    property Height: TG2IntS32 read _Height write _Height;
    property WidthRT: TG2IntS32 read _WidthRT;
    property HeightRT: TG2IntS32 read _HeightRT;
    property ScreenMode: TG2ScreenMode read _ScreenMode write _ScreenMode;
    property TargetUPS: TG2IntS32 read _TargetUPS write _TargetUPS;
    property MaxFPS: TG2IntS32 read _MaxFPS write _MaxFPS;
    constructor Create;
    destructor Destroy; override;
  end;

  TG2Sys = class
  private
    _MMX: Boolean;
    _SSE: Boolean;
    _SSE2: Boolean;
    _SSE3: Boolean;
  public
    property MMX: Boolean read _MMX;
    property SSE: Boolean read _SSE;
    property SSE2: Boolean read _SSE2;
    property SSE3: Boolean read _SSE3;
    constructor Create;
    destructor Destroy; override;
  end;

  TG2RenderQueueItem = record
    RenderControl: TG2RenderControl;
    RenderData: Pointer;
  end;

  {$if defined(G2RM_SM2)}
  PG2ShaderMethod = ^TG2ShaderMethod;
  {$endif}

  TG2Gfx = class
  private
    _RenderControls: TG2QuickList;
    _RenderQueue: array[0..1] of array of TG2RenderQueueItem;
    _RenderQueueCapacity: array[0..1] of TG2IntS32;
    _RenderQueueCount: array[0..1] of TG2IntS32;
    _QueueFill: TG2IntS32;
    _QueueDraw: TG2IntS32;
    _NeedToSwap: Boolean;
    _CanSwap: Boolean;
    _ControlStateChange: TG2RenderControlStateChange;
    _ControlBuffer: TG2RenderControlBuffer;
    _ControlPic2D: TG2RenderControlPic2D;
    _ControlPrim2D: TG2RenderControlPrim2D;
    _ControlPoly2D: TG2RenderControlPoly2D;
    _ControlManaged: TG2RenderControlManaged;
    {$if defined(G2RM_SM2)}
    _Shaders: TG2QuickList;
    _ShaderMethod: PG2ShaderMethod;
    procedure AddShader(const Name: AnsiString; const Prog: Pointer; const ProgSize: TG2IntS32);
    procedure InitShaders;
    procedure FreeShaders;
    {$endif}
    function AddRenderControl(const ControlClass: CG2RenderControl): TG2RenderControl;
  protected
    _BlendMode: TG2BlendMode;
    _Filter: TG2Filter;
    _RenderTarget: TG2Texture2DRT;
    _ClearColor: TG2Color;
    _DepthEnable: Boolean;
    _DepthWriteEnable: Boolean;
    _BlendEnable: Boolean;
    _BlendSeparate: Boolean;
    procedure ProcessRenderQueue;
    procedure SetRenderTarget(const Value: TG2Texture2DRT); virtual; abstract;
    procedure SetBlendMode(const Value: TG2BlendMode); virtual; abstract;
    procedure SetFilter(const Value: TG2Filter); virtual; abstract;
    procedure SetScissor(const Value: PRect); virtual; abstract;
    procedure SetDepthEnable(const Value: Boolean); virtual; abstract;
    procedure SetDepthWriteEnable(const Value: Boolean); virtual; abstract;
    {$if defined(G2RM_SM2)}
    procedure SetShaderMethod(const Value: PG2ShaderMethod); virtual; abstract;
    {$endif}
  public
    SizeRT: TPoint;
    property StateChange: TG2RenderControlStateChange read _ControlStateChange;
    property Buffer: TG2RenderControlBuffer read _ControlBuffer;
    property Pic2D: TG2RenderControlPic2D read _ControlPic2D;
    property Prim2D: TG2RenderControlPrim2D read _ControlPrim2D;
    property Poly2D: TG2RenderControlPoly2D read _ControlPoly2D;
    property Managed: TG2RenderControlManaged read _ControlManaged;
    property RenderTarget: TG2Texture2DRT read _RenderTarget write SetRenderTarget;
    property BlendMode: TG2BlendMode read _BlendMode write SetBlendMode;
    property Filter: TG2Filter read _Filter write SetFilter;
    property ClearColor: TG2Color read _ClearColor write _ClearColor;
    property DepthEnable: Boolean read _DepthEnable write SetDepthEnable;
    property DepthWriteEnable: Boolean read _DepthWriteEnable write SetDepthWriteEnable;
    {$if defined(G2RM_SM2)}
    property ShaderMethod: PG2ShaderMethod read _ShaderMethod write SetShaderMethod;
    {$endif}
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure Reset;
    procedure Swap;
    procedure RenderStart;
    procedure RenderStop;
    procedure Render; virtual; abstract;
    procedure AddRenderQueueItem(const Control: TG2RenderControl; const Data: Pointer);
    procedure Clear(const Color: TG2Color); virtual; abstract;
    {$if defined(G2RM_SM2)}
    function RequestShader(const Name: AnsiString): TG2ShaderGroup;
    {$endif}
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  {$if defined(G2RM_SM2)}
  TG2ShaderItem = record
    Name: AnsiString;
    ShaderGroup: TG2ShaderGroup;
  end;
  PG2ShaderItem = ^TG2ShaderItem;
  {$endif}

  {$ifdef G2Gfx_D3D9}
  TG2GfxD3D9 = class (TG2Gfx)
  private
    _D3D9: IDirect3D9;
    _Device: IDirect3DDevice9;
    _DefRenderTarget: IDirect3DSurface9;
    _DefDepthStencil: IDirect3DSurface9;
  protected
    procedure SetRenderTarget(const Value: TG2Texture2DRT); override;
    procedure SetBlendMode(const Value: TG2BlendMode); override;
    procedure SetFilter(const Value: TG2Filter); override;
    procedure SetScissor(const Value: PRect); override;
    procedure SetDepthEnable(const Value: Boolean); override;
    procedure SetDepthWriteEnable(const Value: Boolean); override;
    {$if defined(G2RM_SM2)}
    procedure SetShaderMethod(const Value: PG2ShaderMethod); override;
    {$endif}
  public
    Caps: TD3DCaps9;
    property Device: IDirect3DDevice9 read _Device;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Render; override;
    procedure Clear(const Color: TG2Color); override;
    constructor Create; override;
    destructor Destroy; override;
  end;
  {$endif}

  {$ifdef G2Gfx_OGL}
  TG2GfxOGL = class (TG2Gfx)
  private
    {$if defined(G2Target_Windows)}
    _Context: HGLRC;
    _DC: HDC;
    {$elseif defined(G2Target_Linux)}
    _Context: GLXContext;
    {$elseif defined(G2Target_OSX)}
    _Context: TAGLContext;
    {$endif}
  protected
    procedure SetRenderTarget(const Value: TG2Texture2DRT); override;
    procedure SetBlendMode(const Value: TG2BlendMode); override;
    procedure SetFilter(const Value: TG2Filter); override;
    procedure SetScissor(const Value: PRect); override;
    procedure SetDepthEnable(const Value: Boolean); override;
    procedure SetDepthWriteEnable(const Value: Boolean); override;
    {$if defined(G2RM_SM2)}
    procedure SetShaderMethod(const Value: PG2ShaderMethod); override;
    {$endif}
  public
    {$if defined(G2Target_Windows)}
    property Context: HGLRC read _Context;
    property DC: HDC read _DC;
    {$elseif defined(G2Target_Linux)}
    property Context: GLXContext read _Context;
    {$elseif defined(G2Target_OSX)}
    property Context: TAGLContext read _Context;
    {$endif}
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Render; override;
    procedure Clear(const Color: TG2Color); override;
    procedure SetProj2D;
    procedure SetDefaults;
    constructor Create; override;
    destructor Destroy; override;
  end;
  {$endif}

  {$ifdef G2Gfx_GLES}
  TG2GfxGLES = class (TG2Gfx)
  private
    {$if defined(G2Target_iOS)}
    _EAGLLayer: CAEAGLLayer;
    _Context: EAGLContext;
    _RenderBuffer: GLUInt;
    {$endif}
  protected
    procedure SetRenderTarget(const Value: TG2Texture2DRT); override;
    procedure SetBlendMode(const Value: TG2BlendMode); override;
    procedure SetFilter(const Value: TG2Filter); override;
    procedure SetScissor(const Value: PRect); override;
    procedure SetDepthEnable(const Value: Boolean); override;
    procedure SetDepthWriteEnable(const Value: Boolean); override;
  public
    {$if defined(G2Target_iOS)}
    property Context: EAGLContext read _Context;
    {$endif}
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Render; override;
    procedure Clear(const Color: TG2Color); override;
    procedure SetProj2D;
    procedure SetDefaults;
    procedure SwapBlendMode;
    procedure MaskAll;
    procedure MaskColor;
    procedure MaskAlpha;
    constructor Create; override;
    destructor Destroy; override;
  end;
  {$endif}

  TG2Snd = class
  protected
    _ListenerPos: TG2Vec3;
    _ListenerVel: TG2Vec3;
    _ListenerDir: TG2Vec3;
    _ListenerUp: TG2Vec3;
    procedure SetListenerPos(const Value: TG2Vec3); virtual; abstract;
    procedure SetListenerVel(const Value: TG2Vec3); virtual; abstract;
    procedure SetListenerDir(const Value: TG2Vec3); virtual; abstract;
    procedure SetListenerUp(const Value: TG2Vec3); virtual; abstract;
  public
    property ListenerPos: TG2Vec3 read _ListenerPos write SetListenerPos;
    property ListenerVel: TG2Vec3 read _ListenerVel write SetListenerVel;
    property ListenerDir: TG2Vec3 read _ListenerDir write SetListenerDir;
    property ListenerUp: TG2Vec3 read _ListenerUp write SetListenerUp;
    procedure Initialize; virtual; abstract;
    procedure Finalize; virtual; abstract;
    constructor Create;
    destructor Destroy; override;
  end;

  {$ifdef G2Snd_OAL}
  TG2SndOAL = class (TG2Snd)
  protected
    _Context: PALCcontext;
    _Device: PALCdevice;
    procedure SetListenerPos(const Value: TG2Vec3); override;
    procedure SetListenerVel(const Value: TG2Vec3); override;
    procedure SetListenerDir(const Value: TG2Vec3); override;
    procedure SetListenerUp(const Value: TG2Vec3); override;
  public
    procedure Initialize; override;
    procedure Finalize; override;
  end;
  {$endif}

  {$ifdef G2Snd_DS}
  TG2SndDS = class (TG2Snd)
  protected
    _Device: IDirectSound8;
    _Listener: IDirectSound3DListener8;
    procedure SetListenerPos(const Value: TG2Vec3); override;
    procedure SetListenerVel(const Value: TG2Vec3); override;
    procedure SetListenerDir(const Value: TG2Vec3); override;
    procedure SetListenerUp(const Value: TG2Vec3); override;
  public
    procedure Initialize; override;
    procedure Finalize; override;
  end;
  {$endif}

  {$ifdef G2Threading}
  TG2Updater = class (TThread)
  protected
    procedure Execute; override;
  end;

  TG2Renderer = class (TThread)
  protected
    procedure Execute; override;
  end;
  {$endif}

  TG2Res = class
  private
    _Mgr: TG2Mgr;
  protected
    function GetMgr: TG2Mgr; virtual;
    procedure Initialize; virtual; abstract;
    procedure Finalize; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TG2Mgr = class
  private
    _Items: TG2QuickList;
    procedure FreeItems;
  public
    procedure ItemAdd(const Item: TG2Res);
    procedure ItemRemove(const Item: TG2Res);
    constructor Create;
    destructor Destroy; override;
  end;

  TG2TextureBase = class (TG2Res)
  protected
    _Gfx: {$if defined(G2Gfx_D3D9)}TG2GfxD3D9{$elseif defined(G2Gfx_OGL)}TG2GfxOGL{$elseif defined(G2Gfx_GLES)}TG2GfxGLES{$endif};
    _Texture: {$ifdef G2Gfx_D3D9}IDirect3DBaseTexture9{$else}GLUInt{$endif};
    _Usage: TG2TextureUsage;
    procedure Release; virtual;
    procedure Initialize; override;
    procedure Finalize; override;
  public
    function BaseTexture: {$ifdef G2Gfx_D3D9}IDirect3DBaseTexture9{$else}GLUInt{$endif}; inline;
    property Usage: TG2TextureUsage read _Usage;
  end;

  TG2Texture2DBase = class (TG2TextureBase)
  protected
    _RealWidth: TG2IntS32;
    _RealHeight: TG2IntS32;
    _Width: TG2IntS32;
    _Height: TG2IntS32;
    _SizeTU: TG2Float;
    _SizeTV: TG2Float;
  public
    function GetTexture: {$ifdef G2Gfx_D3D9}IDirect3DTexture9{$else}GLUInt{$endif}; inline;
    property RealWidth: TG2IntS32 read _RealWidth;
    property RealHeight: TG2IntS32 read _RealHeight;
    property Width: TG2IntS32 read _Width;
    property Height: TG2IntS32 read _Height;
    property SizeTU: TG2Float read _SizeTU;
    property SizeTV: TG2Float read _SizeTV;
  end;

  TG2Texture2D = class (TG2Texture2DBase)
  public
    function Load(const FileName: FileString; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
    function Load(const Stream: TStream; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
    function Load(const Buffer: Pointer; const Size: TG2IntS32; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
    function Load(const DataManager: TG2DataManager; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
    function Load(const Image: TG2Image; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
  end;

  {$ifdef G2Gfx_OGL}
  TG2TexRTMode = (
    rtmNone,
    rtmPBuffer,
    rtmPBufferTex,
    rtmFBO
  );
  {$endif}

  TG2Texture2DRT = class (TG2Texture2DBase)
  private
    {$if defined(G2Gfx_D3D9)}
    _Surface: IDirect3DSurface9;
    {$elseif defined(G2Gfx_OGL)}
    _Mode: TG2TexRTMode;
    _FrameBuffer: GLuint;
    _RenderBuffer: GLuint;
    {$if defined(G2Target_Windows)}
    _PBufferHandle: HPBuffer;
    _PBufferDC: HDC;
    _PBufferRC: HGLRC;
    {$elseif defined(G2Target_Linux)}
    _PBufferContext: GLXContext;
    _PBuffer: GLXPBuffer;
    {$elseif defined(G2Target_OSX)}
    _PBufferContext: TAGLContext;
    _PBuffer: TAGLPBuffer;
    {$endif}
    {$elseif defined(G2Gfx_GLES)}
    _FrameBuffer: GLuint;
    _RenderBuffer: GLuint;
    {$endif}
  protected
    procedure Release; override;
  public
    function Make(const NewWidth, NewHeight: TG2IntS32): Boolean;
  end;

  TG2SoundBuffer = class (TG2Res)
  protected
    {$if defined(G2Snd_DS)}
    _Buffer: IDirectSoundBuffer;
    property GetBuffer: IDirectSoundBuffer read _Buffer;
    {$elseif defined(G2Snd_OAL)}
    _Buffer: TALUInt;
    property GetBuffer: TALUInt read _Buffer;
    {$endif}
    procedure Release;
    procedure Initialize; override;
    procedure Finalize; override;
  public
    function Load(const Stream: TStream): Boolean; overload;
    function Load(const FileName: FileString): Boolean; overload;
    function Load(const Buffer: Pointer; const Size: TG2IntS32): Boolean; overload;
    function Load(const Audio: TG2Audio): Boolean; overload;
  end;

  TG2SoundInst = class
  protected
    {$if defined(G2Snd_DS)}
    _SoundBuffer: IDirectSoundBuffer;
    _SoundBuffer3D: IDirectSound3DBuffer;
    {$elseif defined(G2Snd_OAL)}
    _Source: TALUInt;
    {$endif}
    _Buffer: TG2SoundBuffer;
    _Pos: TG2Vec3;
    _Vel: TG2Vec3;
    _Loop: Boolean;
    procedure SetBuffer(const Value: TG2SoundBuffer);
    procedure SetPos(const Value: TG2Vec3);
    procedure SetVel(const Value: TG2Vec3);
    procedure SetLoop(const Value: Boolean);
  public
    property Buffer: TG2SoundBuffer read _Buffer write SetBuffer;
    property Pos: TG2Vec3 read _Pos write SetPos;
    property Vel: TG2Vec3 read _Vel write SetVel;
    property Loop: Boolean read _Loop write SetLoop;
    procedure Play;
    procedure Pause;
    procedure Stop;
    function IsPlaying: Boolean;
    constructor Create(const SoundBuffer: TG2SoundBuffer);
    destructor Destroy; override;
  end;

  TG2Buffer = class (TG2Res)
  protected
    _Allocated: Boolean;
    _Data: Pointer;
    _DataSize: TG2IntU32;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Allocate(const Size: TG2IntU32);
    procedure Release;
  public
    property Data: Pointer read _Data;
    property DataSize: TG2IntU32 read _DataSize;
  end;

  TG2VBElement = (vbNone, vbPosition, vbDiffuse, vbNormal, vbTangent, vbBinormal, vbTexCoord, vbVertexWeight, vbVertexIndex);

  TG2VBVertex = record
    Element: TG2VBElement;
    Count: TG2IntS32;
  end;

  TG2VBDecl = array of TG2VBVertex;

  TG2BufferUsage = (buNone, buWriteOnly, buReadWrite);
  TG2BufferLockMode = (lmNone, lmReadOnly, lmReadWrite);

  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_FF)}
  TG2D3DVertexMapping = record
    Enabled: Boolean;
    Count: TG2IntS32;
    SizeSrc: TG2IntS32;
    SizeDst: TG2IntS32;
    ProcWrite: procedure (const Src, Dst: Pointer) of Object;
    StridePos: TG2IntS32;
  end;
  {$endif}

  TG2VertexBuffer = class (TG2Buffer)
  private
    _Gfx: TG2GfxD3D9;
    _VertexSize: TG2IntU32;
    _VertexCount: TG2IntU32;
    _Decl: TG2VBDecl;
    _VB: IDirect3DVertexBuffer9;
    {$if defined(G2RM_FF)}
    _FVF: TG2IntU32;
    _VertexMapping: array of TG2D3DVertexMapping;
    _VertexStride: TG2IntU32;
    {$elseif defined(G2RM_SM2)}
    _DeclD3D: IDirect3DVertexDeclaration9;
    {$endif}
    _LockMode: TG2BufferLockMode;
    _Locked: Boolean;
    procedure WriteBufferData;
    {$if defined(G2RM_FF)}
    procedure InitFVF;
    procedure CopyFloatToFloat(const Src, Dst: Pointer);
    procedure CopyFloatToByte(const Src, Dst: Pointer);
    procedure CopyFloatToByteScale(const Src, Dst: Pointer);
    {$elseif defined(G2RM_SM2)}
    procedure InitDecl;
    {$endif}
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property VB: IDirect3DVertexBuffer9 read _VB;
    property VertexCount: TG2IntU32 read _VertexCount;
    property VertexSize: TG2IntU32 read _VertexSize;
    {$if defined(G2RM_FF)}
    property VertexStride: TG2IntU32 read _VertexStride;
    property FVF: TG2IntU32 read _FVF;
    {$elseif defined(G2RM_SM2)}
    property DeclD3D: IDirect3DVertexDeclaration9 read _DeclD3D;
    {$endif}
    procedure Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
    procedure UnLock;
    procedure Bind;
    procedure Unbind;
    constructor Create(const Decl: TG2VBDecl; const Count: TG2IntU32);
  end;
  {$elseif defined(G2Gfx_OGL)}
  TG2VertexBuffer = class (TG2Buffer)
  private
    _Gfx: TG2GfxOGL;
    _VertexSize: TG2IntU32;
    _VertexCount: TG2IntU32;
    _Decl: TG2VBDecl;
    _VB: GLUInt;
    _LockMode: TG2BufferLockMode;
    _Locked: Boolean;
    _TexCoordIndex: array[0..31] of Pointer;
    {$if defined(G2RM_SM2)}
    _BoundAttribs: TG2QuickListIntS32;
    {$endif}
    function GetTexCoordIndex(const Index: TG2IntS32): Pointer; inline;
    procedure WriteBufferData;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property VB: GLUInt read _VB;
    property VertexCount: TG2IntU32 read _VertexCount;
    property VertexSize: TG2IntU32 read _VertexSize;
    property TexCoordIndex[const Index: TG2IntS32]: Pointer read GetTexCoordIndex;
    procedure Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
    procedure UnLock;
    procedure Bind;
    procedure Unbind;
    constructor Create(const Decl: TG2VBDecl; const Count: TG2IntU32);
  end;
  {$elseif defined(G2Gfx_GLES)}
  TG2VertexBuffer = class (TG2Buffer)
  private
    _Gfx: TG2GfxGLES;
    _VertexSize: TG2IntU32;
    _VertexCount: TG2IntU32;
    _Decl: TG2VBDecl;
    _VB: GLUInt;
    _LockMode: TG2BufferLockMode;
    _Locked: Boolean;
    _TexCoordIndex: array[0..31] of Pointer;
    function GetTexCoordIndex(const Index: TG2IntS32): Pointer; inline;
    procedure WriteBufferData;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property VB: GLUInt read _VB;
    property VertexCount: TG2IntU32 read _VertexCount;
    property VertexSize: TG2IntU32 read _VertexSize;
    property TexCoordIndex[const Index: TG2IntS32]: Pointer read GetTexCoordIndex;
    procedure Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
    procedure UnLock;
    procedure Bind;
    procedure Unbind;
    constructor Create(const Decl: TG2VBDecl; const Count: TG2IntU32);
  end;
  {$endif}

  {$if defined(G2Gfx_D3D9)}
  TG2IndexBuffer = class (TG2Buffer)
  private
    _Gfx: TG2GfxD3D9;
    _IndexCount: TG2IntU32;
    _IB: IDirect3DIndexBuffer9;
    _LockMode: TG2BufferLockMode;
    _Locked: Boolean;
    procedure WriteBufferData;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property IB: IDirect3DIndexBuffer9 read _IB;
    property IndexCount: TG2IntU32 read _IndexCount;
    procedure Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
    procedure UnLock;
    procedure Bind;
    procedure Unbind;
    constructor Create(const Count: TG2IntU32);
  end;
  {$elseif defined(G2Gfx_OGL)}
  TG2IndexBuffer = class (TG2Buffer)
  private
    _Gfx: TG2GfxOGL;
    _IndexCount: TG2IntU32;
    _IB: GLUInt;
    _LockMode: TG2BufferLockMode;
    _Locked: Boolean;
    procedure WriteBufferData;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property IndexCount: TG2IntU32 read _IndexCount;
    procedure Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
    procedure UnLock;
    procedure Bind;
    procedure Unbind;
    constructor Create(const Count: TG2IntU32);
  end;
  {$elseif defined(G2Gfx_GLES)}
  TG2IndexBuffer = class (TG2Buffer)
  private
    _Gfx: TG2GfxGLES;
    _IndexCount: TG2IntU32;
    _IB: GLUInt;
    _LockMode: TG2BufferLockMode;
    _Locked: Boolean;
    procedure WriteBufferData;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property IndexCount: TG2IntU32 read _IndexCount;
    procedure Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
    procedure UnLock;
    procedure Bind;
    procedure Unbind;
    constructor Create(const Count: TG2IntU32);
  end;
  {$endif}

  TG2FontCharProps = record
    Width: TG2IntS32;
    Height: TG2IntS32;
    OffsetX: TG2IntS32;
    OffsetY: TG2IntS32;
  end;

  TG2Font = class (TG2Res)
  protected
    _Props: array[TG2IntU8] of TG2FontCharProps;
    _CharSpaceX: TG2IntS32;
    _CharSpaceY: TG2IntS32;
    _Texture: TG2Texture2D;
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property Texture: TG2Texture2D read _Texture;
    function TextWidth(const Text: AnsiString): TG2IntS32; overload;
    function TextWidth(const Text: AnsiString; const PosStart, PosEnd: TG2IntS32): TG2IntS32; overload;
    function TextHeight(const Text: AnsiString): TG2IntS32;
    procedure Make(const Size: TG2IntS32; const Face: AnsiString = {$ifdef G2Target_Linux}'Serif'{$else}'Times New Roman'{$endif});
    procedure Load(const Stream: TStream); overload;
    procedure Load(const FileName: FileString); overload;
    procedure Load(const Buffer: Pointer; const Size: TG2IntS32); overload;
    procedure Load(const DataManager: TG2DataManager); overload;
    procedure Print(
      const x, y, ScaleX, ScaleY: TG2Float;
      const Color: TG2Color;
      const Text: AnsiString;
      const BlendMode: TG2BlendMode;
      const Filter: TG2Filter;
      const Display: TG2Display2D = nil
    ); overload;
    procedure Print(
      const x, y, ScaleX, ScaleY: TG2Float;
      const Text: AnsiString;
      const BlendMode: TG2BlendMode;
      const Filter: TG2Filter;
      const Display: TG2Display2D = nil
    ); overload;
    procedure Print(
      const x, y, ScaleX, ScaleY: TG2Float;
      const Text: AnsiString;
      const Display: TG2Display2D = nil
    ); overload;
    procedure Print(
      const x, y: TG2Float;
      const Text: AnsiString;
      const Display: TG2Display2D = nil
    ); overload;
  end;

  {$if defined(G2RM_SM2)}
  {$if defined(G2Gfx_D3D9)}
  TG2ShaderParam = record
    ParamType: TG2IntU8;
    Name: AnsiString;
    Pos: TG2IntS32;
    Size: TG2IntS32;
  end;
  TG2ShaderParams = array of TG2ShaderParam;
  {$endif}

  TG2VertexShader = record
    Name: AnsiString;
    {$if defined(G2Gfx_D3D9)}
    Prog: IDirect3DVertexShader9;
    Params: TG2ShaderParams;
    {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    Prog: GLHandle;
    {$endif}
  end;
  PG2VertexShader = ^TG2VertexShader;

  TG2PixelShader = record
    Name: AnsiString;
    {$if defined(G2Gfx_D3D9)}
    Prog: IDirect3DPixelShader9;
    Params: TG2ShaderParams;
    {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    Prog: GLHandle;
    {$endif}
  end;
  PG2PixelShader = ^TG2PixelShader;

  TG2ShaderMethod = record
    Name: AnsiString;
    VertexShader: PG2VertexShader;
    PixelShader: PG2PixelShader;
    {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    ShaderProgram: GLHandle;
    {$endif}
  end;

  TG2ShaderGroup = class (TG2Res)
  private
    _Gfx: {$if defined(G2Gfx_D3D9)}TG2GfxD3D9{$elseif defined(G2Gfx_OGL)}TG2GfxOGL{$elseif defined(G2Gfx_GLES)}TG2GfxGLES{$endif};
    _VertexShaders: TG2QuickList;
    _PixelShaders: TG2QuickList;
    _Methods: TG2QuickList;
    _Method: TG2IntS32;
    function GetMethod: AnsiString;
    procedure SetMethod(const Value: AnsiString);
    {$if defined(G2Gfx_D3D9)}
    function ParamVS(const Name: AnsiString): TG2IntS32;
    function ParamPS(const Name: AnsiString): TG2IntS32;
    {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    function Param(const Name: AnsiString): GLInt;
    {$endif}
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property Method: AnsiString read GetMethod write SetMethod;
    procedure Load(const Stream: TStream); overload;
    procedure Load(const FileName: FileString); overload;
    procedure Load(const Buffer: Pointer; const Size: TG2IntS32); overload;
    procedure Load(const DataManager: TG2DataManager); overload;
    procedure UniformMatrix4x4(const Name: AnsiString; const m: TG2Mat);
    procedure UniformMatrix4x4Arr(const Name: AnsiString; const m: PG2Mat; const ArrPos, Count: TG2IntS32);
    procedure UniformMatrix4x3(const Name: AnsiString; const m: TG2Mat);
    procedure UniformMatrix4x3Arr(const Name: AnsiString; const m: PG2Mat; const ArrPos, Count: TG2IntS32);
    procedure UniformFloat4(const Name: AnsiString; const v: TG2Vec4);
    procedure UniformInt1(const Name: AnsiString; const i: TG2IntS32);
    procedure Sampler(const Name: AnsiString; const Texture: TG2TextureBase{$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}; const Stage: TG2IntS32 = 0{$endif});
    {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    function Attribute(const Name: AnsiString): GLInt;
    {$endif}
    procedure Clear;
  end;
  {$endif}

  TG2RenderControl = class
  protected
    _Gfx: {$if defined(G2Gfx_D3D9)}TG2GfxD3D9{$elseif defined(G2Gfx_OGL)}TG2GfxOGL{$elseif defined(G2Gfx_GLES)}TG2GfxGLES{$endif};
    _FillID: PG2IntS32;
    _DrawID: PG2IntS32;
    procedure RenderBegin; virtual; abstract;
    procedure RenderEnd; virtual; abstract;
    procedure RenderData(const Data: Pointer); virtual; abstract;
    procedure Reset; virtual; abstract;
  public
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TG2StateChageType = (
    stClear,
    stRenderTarget,
    stScissor,
    stDepthEnable
  );

  TG2StateChange = record
    StateType: TG2StateChageType;
    Data: Pointer;
    DataSize: TG2IntS32;
  end;
  PG2StateChange = ^TG2StateChange;

  TG2RenderControlStateChange = class (TG2RenderControl)
  private
    _Queue: array[0..1] of array of PG2StateChange;
    _QueueCapacity: array[0..1] of TG2IntS32;
    _QueueCount: array[0..1] of TG2IntS32;
    procedure CheckCapacity;
  public
    procedure StateRenderTargetTexture2D(const RenderTarget: TG2Texture2DRT);
    procedure StateRenderTargetDefault;
    procedure StateClear(const Color: TG2Color);
    procedure StateScissor(const ScissorRect: PRect);
    procedure StateDepthEnable(const Enable: Boolean);
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderData(const Data: Pointer); override;
    procedure Reset; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TG2PrimitiveType = (
    ptPointList = 1,
    ptLineList = 2,
    ptLineStrip = 3,
    ptTriangleList = 4,
    ptTriangleStrip = 5,
    ptTriangleFan = 6
  );

  TG2ManagedRenderObject = class
  protected
    _DrawID: PG2IntS32;
    _FillID: PG2IntS32;
    procedure DoRender; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Render;
  end;

  TG2RenderControlManaged = class (TG2RenderControl)
  private
    _Queue: array[0..1] of array of TG2ManagedRenderObject;
    _QueueCapacity: array[0..1] of TG2IntS32;
    _QueueCount: array[0..1] of TG2IntS32;
    procedure CheckCapacity;
  public
    procedure RenderObject(const Obj: TG2ManagedRenderObject);
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderData(const Data: Pointer); override;
    procedure Reset; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TG2BufferRenderData = record
    VertexBuffer: TG2VertexBuffer;
    IndexBuffer: TG2IndexBuffer;
    PrimitiveType: TG2PrimitiveType;
    VertexStart: TG2IntS32;
    VertexCount: TG2IntS32;
    IndexStart: TG2IntS32;
    IndexCount: TG2IntS32;
    PrimitiveCount: TG2IntS32;
    Texture: TG2Texture2DBase;
    W, V, P: TG2Mat;
  end;
  PG2BufferRenderData = ^TG2BufferRenderData;

  TG2RenderControlBuffer = class (TG2RenderControl)
  private
    _Queue: array[0..1] of array of PG2BufferRenderData;
    _QueueCapacity: array[0..1] of TG2IntS32;
    _QueueCount: array[0..1] of TG2IntS32;
    {$if defined(G2RM_SM2)}
    _ShaderGroup: TG2ShaderGroup;
    {$endif}
    procedure CheckCapacity;
  public
    procedure RenderPrimitive(
      const VB: TG2VertexBuffer;
      const PrimitiveType: TG2PrimitiveType;
      const VertexStart: TG2IntS32;
      const PrimitiveCount: TG2IntS32;
      const Texture: TG2Texture2DBase;
      const W, V, P: TG2Mat
    ); overload;
    procedure RenderPrimitive(
      const VB: TG2VertexBuffer;
      const IB: TG2IndexBuffer;
      const PrimitiveType: TG2PrimitiveType;
      const VertexStart: TG2IntS32;
      const VertexCount: TG2IntS32;
      const IndexStart: TG2IntS32;
      const PrimitiveCount: TG2IntS32;
      const Texture: TG2Texture2DBase;
      const W, V, P: TG2Mat
    );
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderData(const Data: Pointer); override;
    procedure Reset; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TG2Pic2D = record
    Pos0, Pos1, Pos2, Pos3: TG2Vec2;
    Tex0, Tex1, Tex2, Tex3: TG2Vec2;
    c0, c1, c2, c3: TG2Color;
    Texture: TG2Texture2DBase;
    BlendMode: TG2BlendMode;
    Filter: TG2Filter;
  end;
  PG2Pic2D = ^TG2Pic2D;

  {$ifdef G2Gfx_D3D9}
  {$if defined(G2RM_FF)}
  TG2Pic2DVertex = packed record
    x, y, z, rhw: TG2Float;
    Color: TG2Color;
    tu, tv: TG2Float;
  end;
  {$elseif defined(G2RM_SM2)}
  TG2Pic2DVertex = packed record
    x, y, z: TG2Float;
    Color: TG2Color;
    tu, tv: TG2Float;
  end;
  {$endif}
  PG2Pic2DVertex = ^TG2Pic2DVertex;
  TG2Pic2DVertexArr = array[Word] of TG2Pic2DVertex;
  PG2Pic2DVertexArr = ^TG2Pic2DVertexArr;
  {$endif}

  TG2RenderControlPic2D = class(TG2RenderControl)
  private
    _Queue: array[0..1] of array of PG2Pic2D;
    _QueueCapacity: array[0..1] of TG2IntS32;
    _QueueCount: array[0..1] of TG2IntS32;
    _MaxQuads: TG2IntS32;
    _CurTexture: TG2Texture2DBase;
    _CurBlendMode: TG2BlendMode;
    _CurFilter: TG2Filter;
    _CurQuad: TG2IntS32;
    {$if defined(G2RM_SM2)}
    _ShaderGroup: TG2ShaderGroup;
    {$endif}
    {$if defined(G2Gfx_D3D9)}
    {$if defined(G2RM_SM2)}
    _Decl: IDirect3DVertexDeclaration9;
    {$endif}
    _Vertices: array of TG2Pic2DVertex;
    _Indices: array of TG2IntU16;
    {$elseif defined(G2Gfx_OGL)}
    {$if defined(G2RM_SM2)}
    _AttribPosition: GLInt;
    _AttribColor: GLInt;
    _AttribTexCoord: GLInt;
    {$endif}
    {$elseif defined(G2Gfx_GLES)}
    _Indices: array of TG2IntU16;
    _VertPositions: array of TG2Vec3;
    _VertColors: array of TG2Vec4;
    _VertTexCoords: array of TG2Vec2;
    {$endif}
    procedure CheckCapacity;
    procedure Flush;
  public
    procedure DrawQuad(
      const Pos0, Pos1, Pos2, Pos3: TG2Vec2;
      const Tex0, Tex1, Tex2, Tex3: TG2Vec2;
      const c0, c1, c2, c3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filter: TG2Filter = tfPoint
    );
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderData(const Data: Pointer); override;
    procedure Reset; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TG2Prim2DPoint = record
    x, y: TG2Float;
    Color: TG2Color;
  end;

  TG2Prim2D = record
    Points: array of TG2Prim2DPoint;
    Count: TG2IntS32;
    PrimType: TG2PrimType;
    BlendMode: TG2BlendMode;
  end;
  PG2Prim2D = ^TG2Prim2D;

  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_FF)}
  TG2Prim2DVertex = packed record
    x, y, z, rhw: TG2Float;
    Color: TG2Color;
  end;
  {$elseif defined(G2RM_SM2)}
  TG2Prim2DVertex = packed record
    x, y, z: TG2Float;
    Color: TG2Color;
  end;
  {$endif}
  PG2Prim2DVertex = ^TG2Prim2DVertex;
  TG2Prim2DVertexArr = array[Word] of TG2Prim2DVertex;
  PG2Prim2DVertexArr = ^TG2Prim2DVertexArr;
  {$endif}

  TG2RenderControlPrim2D = class(TG2RenderControl)
  private
    _Queue: array[0..1] of array of PG2Prim2D;
    _QueueCapacity: array[0..1] of TG2IntS32;
    _QueueCount: array[0..1] of TG2IntS32;
    _CurPoint: TG2IntS32;
    _CurPrim: PG2Prim2D;
    _CurPrimType: TG2PrimType;
    _CurBlendMode: TG2BlendMode;
    _MaxPoints: TG2IntS32;
    {$if defined(G2RM_SM2)}
    _ShaderGroup: TG2ShaderGroup;
    {$endif}
    {$if defined(G2Gfx_D3D9)}
    {$if defined(G2RM_SM2)}
    _Decl: IDirect3DVertexDeclaration9;
    {$endif}
    _Vertices: array of TG2Prim2DVertex;
    {$elseif defined(G2Gfx_OGL)}
    {$if defined(G2RM_SM2)}
    _AttribPosition: GLInt;
    _AttribColor: GLInt;
    {$endif}
    {$elseif defined(G2Gfx_GLES)}
    _VertPositions: array of TG2Vec3;
    _VertColors: array of TG2Vec4;
    _Indices: array of TG2IntU16;
    {$endif}
    procedure CheckCapacity;
    procedure Flush;
  public
    procedure PrimBegin(const PrimType: TG2PrimType; const BlendMode: TG2BlendMode); inline;
    procedure PrimEnd; inline;
    procedure PrimAdd(const x, y: TG2Float; const Color: TG2Color); inline;
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderData(const Data: Pointer); override;
    procedure Reset; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TG2Poly2DPoint = record
    x, y: TG2Float;
    Color: TG2Color;
    u, v: TG2Float;
  end;

  TG2Poly2D = record
    PolyType: TG2PrimType;
    Points: array of TG2Poly2DPoint;
    Count: TG2IntS32;
    Texture: TG2Texture2DBase;
    BlendMode: TG2BlendMode;
    Filter: TG2Filter;
  end;
  PG2Poly2D = ^TG2Poly2D;

  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_FF)}
  TG2Poly2DVertex = packed record
    x, y, z, rhw: TG2Float;
    Color: TG2Color;
    tu, tv: TG2Float;
  end;
  {$elseif defined(G2RM_SM2)}
  TG2Poly2DVertex = packed record
    x, y, z: TG2Float;
    Color: TG2Color;
    tu, tv: TG2Float;
  end;
  {$endif}
  PG2Poly2DVertex = ^TG2Poly2DVertex;
  TG2Poly2DVertexArr = array[Word] of TG2Poly2DVertex;
  PG2Poly2DVertexArr = ^TG2Poly2DVertexArr;
  {$endif}

  TG2RenderControlPoly2D = class(TG2RenderControl)
  private
    _Queue: array[0..1] of array of PG2Poly2D;
    _QueueCapacity: array[0..1] of TG2IntS32;
    _QueueCount: array[0..1] of TG2IntS32;
    _CurPoint: TG2IntS32;
    _CurIndex: TG2IntS32;
    _CurPoly: PG2Poly2D;
    _CurPolyType: TG2PrimType;
    _CurTexture: TG2Texture2DBase;
    _CurBlendMode: TG2BlendMode;
    _CurFilter: TG2Filter;
    _MaxPoints: TG2IntS32;
    {$if defined(G2RM_SM2)}
    _ShaderGroup: TG2ShaderGroup;
    {$endif}
    {$if defined(G2Gfx_D3D9)}
    {$if defined(G2RM_SM2)}
    _Decl: IDirect3DVertexDeclaration9;
    {$endif}
    _Vertices: array of TG2Poly2DVertex;
    {$elseif defined(G2Gfx_OGL)}
    {$if defined(G2RM_SM2)}
    _AttribPosition: GLInt;
    _AttribColor: GLInt;
    _AttribTexCoord: GLInt;
    {$endif}
    {$elseif defined(G2Gfx_GLES)}
    _VertPositions: array of TG2Vec3;
    _VertColors: array of TG2Vec4;
    _VertTexCoords: array of TG2Vec2;
    _Indices: array of TG2IntU16;
    {$endif}
    procedure CheckCapacity;
    procedure Flush;
  public
    procedure PolyBegin(const PolyType: TG2PrimType; const Texture: TG2Texture2DBase; const BlendMode: TG2BlendMode = bmNormal; const Filter: TG2Filter = tfPoint);
    procedure PolyEnd;
    procedure PolyAdd(const x, y, u, v: TG2Float; const Color: TG2Color); overload;
    procedure PolyAdd(const Pos, TexCoord: TG2Vec2; const Color: TG2Color); overload;
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderData(const Data: Pointer); override;
    procedure Reset; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TG2Display2DMode = (d2dStretch, d2dFit, d2dOversize, d2dCenter);

  TG2Display2D = class
  private
    _Pos: TG2Vec2;
    _Rotation: TG2Float;
    _rs, _rc: TG2Float;
    _Width: TG2IntS32;
    _Height: TG2IntS32;
    _WidthScr: TG2IntS32;
    _HeightScr: TG2IntS32;
    _Mode: TG2Display2DMode;
    _Zoom: TG2Float;
    _ScreenScaleX: Single;
    _ScreenScaleY: Single;
    _ScreenScaleMin: Single;
    _ScreenScaleMax: Single;
    _ConvertCoord: TG2Vec4;
    procedure SetMode(const Value: TG2Display2DMode); inline;
    procedure SetWidth(const Value: TG2IntS32); inline;
    procedure SetHeight(const Value: TG2IntS32); inline;
    procedure SetZoom(const Value: TG2Float); inline;
    procedure SetRotation(const Value: TG2Float); inline;
    procedure UpdateMode;
    function GetRotationVector: TG2Vec2; inline;
    function ConvertCoord(const Coord: TG2Vec2): TG2Vec2; inline;
  public
    property Position: TG2Vec2 read _Pos write _Pos;
    property Rotation: TG2Float read _Rotation write SetRotation;
    property Width: TG2IntS32 read _Width write SetWidth;
    property Height: TG2IntS32 read _Height write SetHeight;
    property WidthScr: TG2IntS32 read _WidthScr;
    property HeightScr: TG2IntS32 read _HeightScr;
    property Zoom: TG2Float read _Zoom write SetZoom;
    property Mode: TG2Display2DMode read _Mode write SetMode;
    property RotationVector: TG2Vec2 read GetRotationVector;
    property ScreenScaleX: Single read _ScreenScaleX;
    property ScreenScaleY: Single read _ScreenScaleY;
    property ScreenScaleMin: Single read _ScreenScaleMin;
    property ScreenScaleMax: Single read _ScreenScaleMax;
    constructor Create;
    destructor Destroy; override;
    function TransformCoord(const Coord: TG2Vec2): TG2Vec2;
    procedure PicQuadCol(
      const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase; const BlendMode: TG2IntU32 = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicQuadCol(
      const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicQuad(
      const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicQuad(
      const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const w, h: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const TexRect: TG2Vec4;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const w, h: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const tu0, tv0, tu1, tv1: TG2Float;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const w, h: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const w, h: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const Pos: TG2Vec2;
      const w, h: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRectCol(
      const x, y: TG2Float;
      const w, h: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); overload;
    procedure PicRect(
      const Pos: TG2Vec2; const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const x, y: TG2Float; const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const Pos: TG2Vec2;
      const w, h: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const x, y: TG2Float;
      const w, h: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const Pos: TG2Vec2;
      const w, h: TG2Float;
      const TexRect: TG2Vec4;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const x, y: TG2Float;
      const w, h: TG2Float;
      const tu0, tv0, tu1, tv1: TG2Float;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const Pos: TG2Vec2;
      const w, h: TG2Float;
      const Col: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PicRect(
      const x, y: TG2Float;
      const w, h: TG2Float;
      const Col: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
    ); inline; overload;
    procedure PrimBegin(const PrimType: TG2PrimType; const BlendMode: TG2BlendMode); inline;
    procedure PrimEnd; inline;
    procedure PrimAdd(const x, y: TG2Float; const Color: TG2Color); inline; overload;
    procedure PrimAdd(const v: TG2Vec2; const Color: TG2Color); inline; overload;
    procedure PrimLineCol(const Pos0, Pos1: TG2Vec2; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimLineCol(const x0, y0, x1, y1: TG2Float; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuad(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuad(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimRectCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimRect(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimRectHollowCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimRectHollow(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
    procedure PrimCircleCol(const Pos: TG2Vec2; const Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimCircleCol(const x, y, Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriHollowCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimTriHollowCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadHollowCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimQuadHollowCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimCircleHollow(const Pos: TG2Vec2; const Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimCircleHollow(const x, y, Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimLine(const Pos0, Pos1: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
    procedure PrimLine(const x0, y0, x1, y1: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal); overload;
  end;

  TG2S2DObject = class
  protected
    _Scene: TG2Scene2D;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
  public
    constructor Create(const Scene: TG2Scene2D);
    destructor Destroy; override;
  end;

  TG2S2DCollisionGroup = record
    Bounds: TRect;
    Collisions: TG2QuickList;
    MergeCheckTime: TG2IntU32;
    Freed: Boolean;
  end;
  PG2S2DCollisionGroup = ^TG2S2DCollisionGroup;

  TG2S2DPointVerlet = record
    Pos: TG2Vec2;
    PosPrev: TG2Vec2;
  end;
  PG2S2DPointVerlet = ^TG2S2DPointVerlet;

  TG2S2DEdge = record
    Pos: array[0..1] of PG2S2DPointVerlet;
  end;
  PG2S2DEdge = ^TG2S2DEdge;

  TG2S2DSpring = record
    Pos: array[0..1] of PG2S2DPointVerlet;
    Dist: TG2Float;
    Hardness: TG2Float;
  end;
  PG2S2DSpring = ^TG2S2DSpring;

  TG2S2DCollider = class (TG2S2DObject)
  protected
    _Group: PG2S2DCollisionGroup;
    _Points: TG2QuickList;
    _Edges: TG2QuickList;
    _Springs: TG2QuickList;
    _Bounds: TRect;
    _Center: TG2Vec2;
    _Active: Boolean;
    _Force: TG2Vec2;
    _Mass: TG2Float;
    _Friction: TG2Float;
    _IsStatic: Boolean;
    _BindRotation: TG2Float;
    _BindPoint: PG2S2DPointVerlet;
    procedure UpdateBounds;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Reset;
    function GetPoint(const Index: TG2IntS32): PG2S2DPointVerlet; inline;
    function GetEdge(const Index: TG2IntS32): PG2S2DEdge; inline;
    function GetSpring(const Index: TG2IntS32): PG2S2DSpring; inline;
    function GetPointCount: TG2IntS32; inline;
    function GetEdgeCount: TG2IntS32; inline;
    function GetSpringCount: TG2IntS32; inline;
    function GetRotation: TG2Float;
    procedure SetActive(const Value: Boolean);
  public
    property Group: PG2S2DCollisionGroup read _Group write _Group;
    property Bounds: TRect read _Bounds;
    property Center: TG2Vec2 read _Center;
    property Points[const Index: TG2IntS32]: PG2S2DPointVerlet read GetPoint;
    property Edges[const Index: TG2IntS32]: PG2S2DEdge read GetEdge;
    property Springs[const Index: TG2IntS32]: PG2S2DSpring read GetSpring;
    property PointCount: TG2IntS32 read GetPointCount;
    property EdgeCount: TG2IntS32 read GetEdgeCount;
    property SpringCount: TG2IntS32 read GetSpringCount;
    property Mass: TG2Float read _Mass write _Mass;
    property Friction: TG2Float read _Friction write _Friction;
    property Rotation: TG2Float read GetRotation;
    property Position: TG2Vec2 read _Center;
    property IsStatic: Boolean read _IsStatic write _IsStatic;
    property Active: Boolean read _Active write SetActive;
    procedure EditBegin;
    procedure EditEnd;
    procedure AddPoint(const x, y: TG2Float);
    procedure AddEdge(const p0, p1: TG2IntS32);
    procedure AddSpring(const p0, p1: TG2IntS32; const Hardness: TG2Float = 0.9);
    procedure AutoSprings;
    procedure AutoEdges;
    procedure MakeBox(const x, y, w, h: TG2Float);
    procedure Project(const Axis: TG2Vec2; var ProjMin, ProjMax: TG2Float);
    procedure AddForce(const f: TG2Vec2);
    procedure Update;
    procedure Render;
  end;

  TG2S2DFrame = class (TG2S2DObject)
  protected
    _Collider: TG2S2DCollider;
    _Pos: TG2Vec2;
    _Ang: TG2Float;
    _Active: Boolean;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure SetActive(const Value: Boolean);
    procedure SetPos(const Value: TG2Vec2);
    procedure SetAng(const Value: TG2Float);
  public
    property Collider: TG2S2DCollider read _Collider write _Collider;
    property Pos: TG2Vec2 read _Pos write SetPos;
    property Ang: TG2Float read _Ang write SetAng;
    property Active: Boolean read _Active write SetActive;
    procedure Render; virtual;
    procedure Update; virtual;
  end;

  TG2S2DSprite = class (TG2S2DFrame)
  protected
    _Texture: TG2Texture2D;
    procedure Activate; override;
    procedure Deactivate; override;
  public
    property Texture: TG2Texture2D read _Texture write _Texture;
    procedure Render; override;
    procedure Update; override;
  end;

  TG2S2DShape = class (TG2S2DFrame)
  protected
    _Texture: TG2Texture2D;
    _Pts: array of TG2Poly2DPoint;
    procedure Initialize; override;
    procedure Finalize; override;
    procedure Activate; override;
    procedure Deactivate; override;
  public
    property Texture: TG2Texture2D read _Texture write _Texture;
    procedure EditBegin;
    procedure EditEnd;
    procedure EditAddPoint(const x, y, u, v: TG2Float; const Color: TG2Color);
    procedure Render; override;
    procedure Update; override;
  end;

  TG2Scene2D = class (TG2Res)
  private
    _Objects: TG2QuickList;
    _Frames: TG2QuickList;
    _FramesActive: TG2QuickList;
    _CollidersActive: TG2QuickList;
    _CollisionGroups: TG2QuickList;
    _CollisionGroupsFree: TG2QuickList;
    _MaxCollisionGroupSize: TG2IntS32;
    _Gravity: TG2Vec2;
    _Debug: Boolean;
    function CollisionGroupNew(const R: TRect): PG2S2DCollisionGroup;
    procedure CollisionGroupFree(const g: PG2S2DCollisionGroup);
    function CollisionGroupGet(const R: TRect): PG2S2DCollisionGroup;
    procedure CollisionGroupAdd(const g: PG2S2DCollisionGroup; const c: TG2S2DCollider);
    procedure CollisionGroupRemove(const g: PG2S2DCollisionGroup; const c: TG2S2DCollider);
    procedure CollisionGroupSplit(const g: PG2S2DCollisionGroup);
    procedure CollisionGroupMerge(const g0, g1: PG2S2DCollisionGroup);
    procedure CollisionGroupUpdate(const g: PG2S2DCollisionGroup);
  protected
    procedure Initialize; override;
    procedure Finalize; override;
  public
    property Debug: Boolean read _Debug write _Debug;
    property Gravity: TG2Vec2 read _Gravity write _Gravity;
    procedure Collide(const c0, c1: TG2S2DCollider);
    procedure Render;
    procedure Update;
  end;

  TG2S3DNode = class
  protected
    _Scene: TG2Scene3D;
    _Transform: TG2Mat;
    procedure SetTransform(const Value: TG2Mat); virtual;
  public
    property Transform: TG2Mat read _Transform write SetTransform;
    constructor Create(const Scene: TG2Scene3D); virtual;
    destructor Destroy; override;
  end;

  TG2S3DFrame = class (TG2S3dNode)
  protected
    function GetAABox: TG2AABox; virtual; abstract;
  public
    property AABox: TG2AABox read GetAABox;
    constructor Create(const Scene: TG2Scene3D); override;
    destructor Destroy; override;
  end;

  TG2S3DMeshVertex = record
    Position: TG2Vec3;
    Normal: TG2Vec3;
    TexCoord: TG2Vec2;
  end;
  PG2S3DMeshVertex = ^TG2S3DMeshVertex;

  TG2S3DMeshFace = record
    Indices: array[0..2] of TG2IntU16;
    MaterialID: TG2IntS32;
  end;
  PG2S3DMeshFace = ^TG2S3DMeshFace;

  TG2S3DMeshBuilder = object
  public
    Vertices: TG2QuickList;
    Faces: TG2QuickList;
    Materials: TG2QuickList;
    LastMaterial: TG2IntS32;
    procedure Init;
    procedure Clear;
  end;
  PG2S3DMeshBuilder = ^TG2S3DMeshBuilder;

  TG2S3DMeshNode = object
    OwnerID: TG2IntS32;
    Name: AnsiString;
    Transform: TG2Mat;
    SubNodesID: array of TG2IntS32;
  end;
  PG2S3DMeshNode = ^TG2S3DMeshNode;

  TG2S3DGeomDataStatic = object
    BBox: TG2Box;
    VB: TG2VertexBuffer;
  end;
  PG2S3DGeomDataStatic = ^TG2S3DGeomDataStatic;

  TG2S3DGeomDataSkinned = object
    MaxWeights: Word;
    BoneCount: TG2IntS32;
    Bones: array of record
      NodeID: TG2IntS32;
      Bind: TG2Mat;
      BBox: TG2Box;
      VCount: TG2IntS32;
    end;
    {$if defined(G2RM_FF)}
    Vertices: array of record
      Position: TG2Vec3;
      Normal: TG2Vec3;
      TexCoord: array of TG2Vec2;
      BoneWeightCount: TG2IntS32;
      Bones: array of TG2IntS32;
      Weights: array of TG2Float;
    end;
    {$elseif defined(G2RM_SM2)}
    VB: TG2VertexBuffer;
    {$endif}
  end;
  PG2S3DGeomDataSkinned = ^TG2S3DGeomDataSkinned;

  TG2S3DMeshGeom = object
    NodeID: TG2IntS32;
    Decl: TG2VBDecl;
    Skinned: Boolean;
    Data: Pointer;
    VCount: TG2IntS32;
    FCount: TG2IntS32;
    GCount: TG2IntS32;
    TCount: TG2IntS32;
    IB: TG2IndexBuffer;
    Groups: array of record
      Material: TG2IntS32;
      VertexStart: TG2IntS32;
      VertexCount: TG2IntS32;
      FaceStart: TG2IntS32;
      FaceCount: TG2IntS32;
    end;
    Visible: Boolean;
  end;
  PG2S3DMeshGeom = ^TG2S3DMeshGeom;

  TG2S3DMeshAnim = object
    Name: AnsiString;
    FrameRate: TG2IntS32;
    FrameCount: TG2IntS32;
    NodeCount: TG2IntS32;
    Nodes: array of record
      NodeID: TG2IntS32;
      Frames: array of record
        Scaling: TG2Vec3;
        Rotation: TG2Quat;
        Translation: TG2Vec3;
      end;
    end;
  end;
  PG2S3DMeshAnim = ^TG2S3DMeshAnim;

  TG2S3DMeshMaterial = object
    ChannelCount: TG2IntS32;
    Channels: array of record
      Name: AnsiString;
      TwoSided: Boolean;
      MapDiffuse: TG2Texture2D;
      MapLight: TG2Texture2D;
    end;
  end;
  PG2S3DMeshMaterial = ^TG2S3DMeshMaterial;

  TG2S3DMesh = class
  private
    _Scene: TG2Scene3D;
    _Instances: TG2QuickList;
    _NodeCount: TG2IntS32;
    _GeomCount: TG2IntS32;
    _AnimCount: TG2IntS32;
    _MaterialCount: TG2IntS32;
    _Nodes: array of TG2S3DMeshNode;
    _Geoms: array of TG2S3DMeshGeom;
    _Anims: array of TG2S3DMeshAnim;
    _Materials: array of TG2S3DMeshMaterial;
    _Loaded: Boolean;
    function GetNode(const Index: TG2IntS32): PG2S3DMeshNode; inline;
    function GetGeom(const Index: TG2IntS32): PG2S3DMeshGeom; inline;
    function GetAnim(const Index: TG2IntS32): PG2S3DMeshAnim; inline;
    function GetMaterial(const Index: TG2IntS32): PG2S3DMeshMaterial; inline;
  public
    property NodeCount: TG2IntS32 read _NodeCount;
    property GeomCount: TG2IntS32 read _GeomCount;
    property AnimCount: TG2IntS32 read _AnimCount;
    property MaterialCount: TG2IntS32 read _MaterialCount;
    property Nodes[const Index: TG2IntS32]: PG2S3DMeshNode read GetNode;
    property Geoms[const Index: TG2IntS32]: PG2S3DMeshGeom read GetGeom;
    property Anims[const Index: TG2IntS32]: PG2S3DMeshAnim read GetAnim;
    property Materials[const Index: TG2IntS32]: PG2S3DMeshMaterial read GetMaterial;
    constructor Create(const Scene: TG2Scene3D);
    destructor Destroy; override;
    procedure Load(const MeshData: TG2MeshData);
    function AnimIndex(const Name: AnsiString): TG2IntS32;
    function NewInst: TG2S3DMeshInst;
  end;

  TG2S3DMeshInstSkin = object
    {$if defined(G2RM_FF)}
    VB: TG2VertexBuffer;
    {$endif}
    Transforms: array of TG2Mat;
  end;
  PG2S3DMeshInstSkin = ^TG2S3DMeshInstSkin;

  TG2S3DMeshInst = class (TG2S3DFrame)
  private
    _Mesh: TG2S3DMesh;
    _RootNodes: array of TG2IntS32;
    _Skins: array of PG2S3DMeshInstSkin;
    _AutoComputeTransforms: Boolean;
    procedure SetMesh(const Value: TG2S3DMesh);
    function GetBBox: TG2Box;
    function GetGeomBBox(const Index: TG2IntS32): TG2Box;
    function GetSkin(const Index: TG2IntS32): PG2S3DMeshInstSkin; inline;
    procedure ComputeSkinTransforms;
  protected
    function GetAABox: TG2AABox; override;
  public
    Transforms: array of record
      TransformDef: TG2Mat;
      TransformCur: TG2Mat;
      TransformCom: TG2Mat;
    end;
    Materials: array of PG2S3DMeshMaterial;
    property Mesh: TG2S3DMesh read _Mesh write SetMesh;
    property BBox: TG2Box read GetBBox;
    property AutoComputeTransforms: Boolean read _AutoComputeTransforms write _AutoComputeTransforms;
    property GeomBBox[const Index: TG2IntS32]: TG2Box read GetGeomBBox;
    property Skins[const Index: TG2IntS32]: PG2S3DMeshInstSkin read GetSkin;
    constructor Create(const Scene: TG2Scene3D); override;
    destructor Destroy; override;
    procedure FrameSetFast(const AnimName: AnsiString; const Frame: TG2IntS32);
    procedure FrameSet(const AnimName: AnsiString; const Frame: TG2Float);
    procedure ComputeTransforms;
  end;

  TG2S3DParticleRender = class
  protected
    _Scene: TG2Scene3D;
  public
    constructor Create(const Scene: TG2Scene3D); virtual;
    destructor Destroy; override;
    procedure RenderBegin; virtual; abstract;
    procedure RenderEnd; virtual; abstract;
    procedure RenderParticle(const Particle: TG2S3DParticle); virtual; abstract;
  end;

  {$if defined(G2RM_FF)}
  TG2S3DParticleRenderFlat = class (TG2S3DParticleRender)
  private
    _VB: array of TG2VertexBuffer;
    _IB: TG2IndexBuffer;
    _MaxQuads: TG2IntS32;
    _VBCount: TG2IntS32;
    _CurVB: TG2IntS32;
    _CurQuad: TG2IntS32;
    _CurTexture: TG2Texture2D;
    _CurFilter: TG2Filter;
    _CurBlendMode: TG2BlendMode;
    procedure RenderFlush;
  public
    constructor Create(const Scene: TG2Scene3D); override;
    destructor Destroy; override;
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderParticle(const Particle: TG2S3DParticle); override;
  end;
  {$elseif defined(G2RM_SM2)}
  TG2S3DParticleRenderFlat = class (TG2S3DParticleRender)
  private
    _VB: TG2VertexBuffer;
    _IB: TG2IndexBuffer;
    _MaxQuads: TG2IntS32;
    _CurQuad: TG2IntS32;
    _CurTexture: TG2Texture2D;
    _CurFilter: TG2Filter;
    _CurBlendMode: TG2BlendMode;
    _ShaderGroup: TG2ShaderGroup;
    procedure RenderFlush;
  public
    constructor Create(const Scene: TG2Scene3D); override;
    destructor Destroy; override;
    procedure RenderBegin; override;
    procedure RenderEnd; override;
    procedure RenderParticle(const Particle: TG2S3DParticle); override;
  end;
  {$endif}

  CG2S3DParticleRender = class of TG2S3DParticleRender;

  TG2S3DParticleGroup = record
    AABox: TG2AABox;
    Items: TG2QuickList;
    MinSize: TG2Float;
    MaxSize: TG2Float;
  end;
  PG2S3DParticleGroup = ^TG2S3DParticleGroup;

  TG2S3DParticle = class
  private
    _Group: PG2S3DParticleGroup;
  protected
    _Size: TG2Float;
    _Pos: TG2Vec3;
    _DepthSorted: Boolean;
    _RenderClass: CG2S3DParticleRender;
    _ParticleRender: TG2S3DParticleRender;
    _Dead: Boolean;
    function GetAABox: TG2AABox; inline;
  public
    property Size: TG2Float read _Size;
    property Pos: TG2Vec3 read _Pos write _Pos;
    property DepthSorted: Boolean read _DepthSorted write _DepthSorted;
    property RenderClass: CG2S3DParticleRender read _RenderClass;
    property ParticleRender: TG2S3DParticleRender read _ParticleRender write _ParticleRender;
    property Group: PG2S3DParticleGroup read _Group write _Group;
    property AABox: TG2AABox read GetAABox;
    property Dead: Boolean read _Dead;
    procedure Update; virtual; abstract;
    procedure Die; inline;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  TG2S3DParticleFlat = class (TG2S3DParticle)
  private
    _Texture: TG2Texture2D;
    _Color: TG2Color;
    _VecX: TG2Vec3;
    _VecY: TG2Vec3;
    _Filter: TG2Filter;
    _BlendMode: TG2BlendMode;
    procedure SetVecX(const Value: TG2Vec3); inline;
    procedure SetVecY(const Value: TG2Vec3); inline;
    procedure UpdateSize;
  public
    property Texture: TG2Texture2D read _Texture write _Texture;
    property Color: TG2Color read _Color write _Color;
    property Filter: TG2Filter read _Filter write _Filter;
    property BlendMode: TG2BlendMode read _BlendMode write _BlendMode;
    property VecX: TG2Vec3 read _VecX write SetVecX;
    property VecY: TG2Vec3 read _VecY write SetVecY;
    procedure MakeBillboard(const View: TG2Mat; const Width, Height, Rotation: TG2Float);
    procedure MakeAxis(const View: TG2Mat; const Pos0, Pos1: TG2Vec3; const Width: TG2Float);
    procedure Update; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  PG2S3DOcTreeNode = ^TG2S3DOcTreeNode;
  TG2S3DOcTreeNode = object
  public
    Parent: PG2S3DOcTreeNode;
    SubNodes: array of array of array of PG2S3DOcTreeNode;
    DivX, DivY, DivZ: TG2IntS32;
    AABox: TG2AABox;
    Frames: TG2QuickList;
  end;

  TG2S3DTexture = record
    Name: AnsiString;
    Texture: TG2Texture2D;
  end;
  PG2S3DTexture = ^TG2S3DTexture;

  TG2Scene3D = class (TG2ManagedRenderObject)
  private
    {$if defined(G2RM_SM2)}
    _ShaderGroup: TG2ShaderGroup;
    {$endif}
    _Textures: TG2QuickList;
    _Nodes: TG2QuickList;
    _Frames: TG2QuickList;
    _MeshInst: TG2QuickList;
    _Meshes: TG2QuickList;
    _Particles: TG2QuickList;
    _NewParticles: TG2QuickList;
    _ParticleGroups: TG2QuickList;
    _ParticlesSorted: TG2QuickSortList;
    _ParticleRenders: TG2QuickList;
    _Frustum: TG2Frustum;
    _OcTreeRoot: PG2S3DOcTreeNode;
    _UpdatingParticles: Boolean;
    _StatParticlesRendered: TG2IntS32;
    _Ambient: TG2Color;
    procedure OcTreeBuild(const MinV, MaxV: TG2Vec3; const Depth: TG2IntS32);
    procedure OcTreeBreak;
    function GetStatParticleGroupCount: TG2IntS32; inline;
    function GetStatParticleCount: TG2IntS32; inline;
  protected
    {$if defined(G2Gfx_D3D9)}
    _Gfx: TG2GfxD3D9;
    procedure RenderD3D9;
    {$elseif defined(G2Gfx_OGL)}
    _Gfx: TG2GfxOGL;
    procedure RenderOGL;
    {$elseif defined(G2Gfx_GLES)}
    _Gfx: TG2GfxGLES;
    procedure RenderGLES;
    {$endif}
    procedure RenderParticles;
    procedure DoRender; override;
  public
    V: TG2Mat;
    P: TG2Mat;
    property Nodes: TG2QuickList read _Nodes;
    property Frames: TG2QuickList read _Frames;
    property MeshInst: TG2QuickList read _MeshInst;
    property Meshes: TG2QuickList read _Meshes;
    property Ambient: TG2Color read _Ambient write _Ambient;
    property StatParticleGroupCount: TG2IntS32 read GetStatParticleGroupCount;
    property StatParticleCount: TG2IntS32 read GetStatParticleCount;
    property StatParticlesRendered: TG2IntS32 read _StatParticlesRendered;
    procedure Update;
    procedure Build;
    procedure ParticleAdd(const Particle: TG2S3DParticle);
    function FindTexture(const TextureName: AnsiString; const Usage: TG2TextureUsage = tuDefault): TG2Texture2D;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

var g2: TG2Core;

function G2Time: TG2IntU32;
function G2PiTime(Amp: TG2Float = 1000): TG2Float; overload;
function G2PiTime(Amp: TG2Float; Time: TG2IntU32): TG2Float; overload;
function G2TimeInterval(Interval: TG2IntU32 = 1000): TG2Float; overload;
function G2TimeInterval(Interval: TG2IntU32; Time: TG2IntU32): TG2Float; overload;
function G2RandomPi: TG2Float;
function G2Random2Pi: TG2Float;
function G2RandomCirclePoint: TG2Vec2;
function G2RandomSpherePoint: TG2Vec3;
function G2RectInRect(const R0, R1: TRect): Boolean; overload;
function G2RectInRect(const R0, R1: TG2Rect): Boolean; overload;
function G2KeyName(const Key: TG2IntS32): AnsiString;
procedure G2TraceBegin;
function G2TraceEnd: TG2IntU32;
{$if defined(G2Cpu386)}
procedure G2BreakPoint; assembler;
{$endif}
procedure SafeRelease(var i);

implementation

{$ifdef G2Target_Windows}
var G2WndClassName: AnsiString;
{$endif}

var SysMMX: Boolean = False;
var SysSSE: Boolean = False;
var SysSSE2: Boolean = False;
var SysSSE3: Boolean = False;
var TraceTime: TG2IntU32;

{$if defined(G2Cpu386) and (defined(G2Target_Windows) or defined(G2Target_Linux))}
procedure CPUExtensions; assembler;
asm
  push ebx
  mov eax, 1
  cpuid
  test ecx, 00000001h
  jz @CheckSSE2
  mov [SysSSE3], 1
@CheckSSE2:
  test edx, 04000000h
  jz @CheckSSE
  mov [SysSSE2], 1
@CheckSSE:
  test edx, 02000000h
  jz @CheckMMX
  mov [SysSSE], 1
@CheckMMX:
  test edx, 00800000h
  jz @Done
  mov [SysMMX], 1
@Done:
  pop ebx
end;
{$endif}

{$if defined(G2Target_Windows)}
function G2MessageHandler(Wnd: HWnd; Msg: UInt; wParam: WPARAM; lParam: LPARAM): LResult; stdcall;
begin
  case Msg of
    WM_DESTROY, WM_QUIT, WM_CLOSE:
    begin
      PostQuitMessage(0);
      Result := 0;
      Exit;
    end;
    WM_CHAR:
    begin
      g2.Window.AddMessage(@g2.Window.OnPrint, wParam, 0, 0);
    end;
    WM_KEYDOWN:
    begin
      g2.Window.AddMessage(@g2.Window.OnKeyDown, wParam, 0, 0);
    end;
    WM_KEYUP:
    begin
      g2.Window.AddMessage(@g2.Window.OnKeyUp, wParam, 0, 0);
    end;
    WM_LBUTTONDOWN:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Left, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_LBUTTONDBLCLK:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Left, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_LBUTTONUP:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Left, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_RBUTTONDOWN:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Right, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_RBUTTONDBLCLK:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Right, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_RBUTTONUP:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Right, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_MBUTTONDOWN:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Middle, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_MBUTTONDBLCLK:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Middle, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_MBUTTONUP:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Middle, lParam and $ffff, (lParam shr 16) and $ffff);
    end;
    WM_MOUSEWHEEL:
    begin
      g2.Window.AddMessage(@g2.Window.OnScroll, SmallInt((LongWord(wParam) shr 16) and $ffff), 0, 0);
    end;
    WM_SETCURSOR:
    begin
      Exit;
    end;
  end;
  Result := DefWindowProcA(Wnd, Msg, wParam, lParam);
end;
{$elseif defined(G2Target_Linux)}
procedure G2MessageHandler(Event: TXEvent);
begin
  case Event._type of
    ConfigureNotify:
    begin
      if (Event.xconfigure.width <> g2.Params.Width)
      or (Event.xconfigure.height <> g2.Params.Height) then
      begin
        g2.Params.Width := Event.xconfigure.width;
        g2.Params.Height := Event.xconfigure.height;
      end;
    end;
    KeyPress:
    begin
      g2.Window.AddMessage(@g2.Window.OnKeyDown, Event.xkey.keycode, 0, 0);
    end;
    KeyRelease:
    begin
      g2.Window.AddMessage(@g2.Window.OnKeyUp, Event.xkey.keycode, 0, 0);
    end;
    ButtonPress:
    begin
      case Event.xbutton.button of
        1: g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Left, Event.xbutton.x, Event.xbutton.y);
        2: g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Middle, Event.xbutton.x, Event.xbutton.y);
        3: g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Right, Event.xbutton.x, Event.xbutton.y);
      end;
    end;
    ButtonRelease:
    begin
      case Event.xbutton.button of
        1: g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Left, Event.xbutton.x, Event.xbutton.y);
        2: g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Middle, Event.xbutton.x, Event.xbutton.y);
        3: g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Right, Event.xbutton.x, Event.xbutton.y);
      end;
    end;
  end;
end;
{$elseif defined(G2Target_OSX)}
function G2MessageHandler(inHandlerCallRef: EventHandlerCallRef; inEvent: EventRef; inUserData: UnivPtr ): OSStatus; cdecl;
  var EventClass: MacOSAll.OSType;
  var EventKind: MacOSAll.UInt32;
  var Command: MacOSAll.HICommand;
  var Key: IntU32;
  var Button: EventMouseButton;
  var CursorPos: TPoint;
begin
  EventClass := GetEventClass(inEvent);
  EventKind := GetEventKind(inEvent);
  case EventClass of
    kEventClassCommand:
    begin
      case EventKind of
        kEventProcessCommand:
        begin
          GetEventParameter(
            inEvent,
            kEventParamDirectObject,
            kEventParamHICommand,
            nil, SizeOf(Command),
            nil, @Command
          );
          if Command.commandID = kHICommandQuit then g2.Window.Stop;
        end;
      end;
    end;
    kEventClassWindow:
    begin
      case EventKind of
        kEventWindowClosed:
        begin
          g2.Window.Stop;
        end;
      end;
    end;
    kEventClassKeyboard:
    begin
      GetEventParameter(inEvent, kEventParamKeyCode, typeUInt32, nil, SizeOf(Key), nil, @Key);
      case EventKind of
        kEventRawKeyDown, kEventRawKeyRepeat: g2.Window.AddMessage(@g2.Window.OnKeyDown, Key, 0, 0);
        kEventRawKeyUp: g2.Window.AddMessage(@g2.Window.OnKeyUp, Key, 0, 0);
      end;
    end;
    kEventClassMouse:
    begin
      GetEventParameter(inEvent, kEventParamMouseButton, typeMouseButton, nil, SizeOf(Button), nil, @Button);
      case EventKind of
        kEventMouseDown:
        begin
          CursorPos := g2.MousePos;
          case Button of
            1: g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Left, CursorPos.x, CursorPos.y);
            2: g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Right, CursorPos.x, CursorPos.y);
            3: g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Middle, CursorPos.x, CursorPos.y);
          end;
        end;
        kEventMouseUp:
        begin
          CursorPos := g2.MousePos;
          case Button of
            1: g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Left, CursorPos.x, CursorPos.y);
            2: g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Right, CursorPos.x, CursorPos.y);
            3: g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Middle, CursorPos.x, CursorPos.y);
          end;
        end;
      end;
    end;
  end;
end;
{$endif}

{$Hints off}
{$ifdef G2Target_Windows}
var WndClass: TWndClassExA;
{$endif}
procedure G2Initialize;
begin
  {$ifdef G2Target_Windows}
  G2WndClassName := 'Gen2MP';
  FillChar(WndClass, SizeOf(TWndClassExA), 0);
  WndClass.cbSize := SizeOf(TWndClassExA);
  WndClass.hIconSm := LoadIcon(MainInstance, 'MAINICON');
  WndClass.hIcon := LoadIcon(MainInstance, 'MAINICON');
  WndClass.hInstance := HInstance;
  WndClass.hCursor := LoadCursor(0, IDC_ARROW);
  WndClass.lpszClassName := PAnsiChar(G2WndClassName);
  WndClass.style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC or CS_DBLCLKS;
  WndClass.lpfnWndProc := @G2MessageHandler;
  if RegisterClassExA(WndClass) = 0 then
  G2WndClassName := 'Static';
  {$endif}
  g2 := TG2Core.Create;
  {$if defined(G2Cpu386) and (defined(G2Target_Windows) or defined(G2Target_Linux))}
  CPUExtensions;
  {$endif}
  g2.Sys._MMX := SysMMX;
  g2.Sys._SSE := SysSSE;
  g2.Sys._SSE2 := SysSSE2;
  g2.Sys._SSE3 := SysSSE3;
  {$if defined(G2Target_Android) or defined(G2Target_iOS)}
  G2DataManagerChachedRead := True;
  {$endif}
end;
{$Hints on}

procedure G2Finalize;
begin
  {$ifdef G2Target_Windows}
  if G2WndClassName = 'Gen2MP' then
  UnregisterClassA(PAnsiChar(G2WndClassName), WndClass.hInstance);
  DestroyIcon(WndClass.hIconSm);
  DestroyIcon(WndClass.hIcon);
  DestroyCursor(WndClass.hCursor);
  {$endif}
  g2.Free;
  g2 := nil;
end;

function KeyRemap(const Key: TG2IntS32): TG2IntS32;
{$if defined(G2Target_Windows)}
  const Remap: array[0..222] of TG2IntS32 = (
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, G2K_Back, G2K_Tab,
    $ff, $ff, $ff, G2K_Return, $ff, $ff, G2K_ShiftL, G2K_CtrlL, G2K_AltL, G2K_Pause,
    G2K_CapsLock, $ff, $ff, $ff, $ff, $ff, $ff, G2K_Escape, $ff, $ff,
    $ff, $ff, G2K_Space, G2K_PgUp, G2K_PgDown, G2K_End, G2K_Home, G2K_Left, G2K_Up, G2K_Right,
    G2K_Down, $ff, $ff, $ff, $ff, G2K_Insert, G2K_Delete, $ff, G2K_0, G2K_1,
    G2K_2, G2K_3, G2K_4, G2K_5, G2K_6, G2K_7, G2K_8, G2K_9, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, G2K_A, G2K_B, G2K_C, G2K_D, G2K_E,
    G2K_F, G2K_G, G2K_H, G2K_I, G2K_J, G2K_K, G2K_L, G2K_M, G2K_N, G2K_O,
    G2K_P, G2K_Q, G2K_R, G2K_S, G2K_T, G2K_U, G2K_V, G2K_W, G2K_X, G2K_Y,
    G2K_Z, G2K_WinL, G2K_WinR, G2K_Menu, $ff, $ff, G2K_Num0, G2K_Num1, G2K_Num2, G2K_Num3,
    G2K_Num4, G2K_Num5, G2K_Num6, G2K_Num7, G2K_Num8, G2K_Num9, G2K_NumMul, G2K_NumPlus, $ff, G2K_NumMinus,
    G2K_NumPeriod, G2K_NumDiv, G2K_F1, G2K_F2, G2K_F3, G2K_F4, G2K_F5, G2K_F6, G2K_F7, G2K_F8,
    G2K_F9, G2K_F10, G2K_F11, G2K_F12, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, G2K_NumLock, G2K_ScrlLock, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    G2K_ShiftL, G2K_ShiftR, G2K_CtrlL, G2K_CtrlR, G2K_AltL, G2K_AltR, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, G2K_SemiCol, G2K_Plus, G2K_Comma, G2K_Minus,
    G2K_Period, G2K_Slash, G2K_Tilda, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, G2K_BrktL,
    G2K_SlashR, G2K_BrktR, G2K_Quote
  );
{$elseif defined(G2Target_Linux)}
  const Remap: array[0..135] of IntS32 = (
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, G2K_Escape,
    G2K_1, G2K_2, G2K_3, G2K_4, G2K_5, G2K_6, G2K_7, G2K_8, G2K_9, G2K_0,
    G2K_Minus, G2K_Plus, G2K_Back, G2K_Tab, G2K_Q, G2K_W, G2K_E, G2K_R, G2K_T, G2K_Y,
    G2K_U, G2K_I, G2K_O, G2K_P, G2K_BrktL, G2K_BrktR, G2K_Return, G2K_CtrlL, G2K_A, G2K_S,
    G2K_D, G2K_F, G2K_G, G2K_H, G2K_J, G2K_K, G2K_L, G2K_SemiCol, G2K_Quote, G2K_Tilda,
    G2K_ShiftL, G2K_SlashR, G2K_Z, G2K_X, G2K_C, G2K_V, G2K_B, G2K_N, G2K_M, G2K_Comma,
    G2K_Period, G2K_Slash, G2K_ShiftR, G2K_NumMul, G2K_AltL, G2K_Space, G2K_CapsLock, G2K_F1, G2K_F2, G2K_F3,
    G2K_F4, G2K_F5, G2K_F6, G2K_F7, G2K_F8, G2K_F9, G2K_F10, G2K_NumLock, G2K_ScrlLock, G2K_Num7,
    G2K_Num8, G2K_Num9, G2K_NumMinus, G2K_Num4, G2K_Num5, G2K_Num6, G2K_NumPlus, G2K_Num1, G2K_Num2, G2K_Num3,
    G2K_Num0, G2K_NumPeriod, $ff, $ff, $ff, G2K_F11, G2K_F12, $ff, $ff, $ff,
    $ff, $ff, $ff, $ff, G2K_NumReturn, $ff, G2K_NumDiv, $ff, G2K_AltR, $ff,
    G2K_Home, G2K_Up, G2K_PgUp, G2K_Left, G2K_Right, G2K_End, G2K_Down, G2K_PgDown, G2K_Insert, G2K_Delete,
    $ff, $ff, $ff, $ff, $ff, $ff, $ff, G2K_Pause, $ff, $ff,
    $ff, $ff, $ff, G2K_WinL, G2K_WinR, G2K_Menu
  );
{$elseif defined(G2Target_OSX)}
  const Remap: array[0..126] of IntS32 = (
    G2K_A, G2K_S, G2K_D, G2K_F, G2K_H, G2K_G, G2K_Z, G2K_X, G2K_C, G2K_V,
    $ff, G2K_B, G2K_Q, G2K_W, G2K_E, G2K_R, G2K_Y, G2K_T, G2K_1, G2K_2,
    G2K_3, G2K_4, G2K_6, G2K_5, G2K_Plus, G2K_9, G2K_7, G2K_Minus, G2K_8, G2K_0,
    G2K_BrktR, G2K_O, G2K_U, G2K_BrktL, G2K_I, G2K_P, G2K_Return, G2K_L, G2K_J, G2K_Quote,
    G2K_K, G2K_SemiCol, G2K_SlashR, G2K_Comma, G2K_Slash, G2K_N, G2K_M, G2K_Period, G2K_Tab, G2K_Space,
    G2K_Tilda, G2K_Back, $ff, G2K_Escape, $ff, G2K_WinL, G2K_Shift, G2K_CapsLock, G2K_Alt, G2K_Ctrl,
    $ff, $ff, $ff, $ff, $ff, G2K_NumPeriod, $ff, G2K_NumMul, $ff, G2K_NumPlus,
    $ff, G2K_NumLock, $ff, $ff, $ff, G2K_NumDiv, G2K_NumReturn, $ff, G2K_NumMinus, $ff,
    $ff, $ff, G2K_Num0, G2K_Num1, G2K_Num2, G2K_Num3, G2K_Num4, G2K_Num5, G2K_Num6, G2K_Num7,
    $ff, G2K_Num8, G2K_Num9, $ff, $ff, $ff, G2K_F5, G2K_F6, G2K_F7, G2K_F3,
    G2K_F8, G2K_F9, $ff, G2K_F11, $ff, $ff, $ff, G2K_ScrlLock, G2K_Pause, G2K_F10,
    G2K_Menu, G2K_F12, $ff, $ff, G2K_Insert, G2K_Home, G2K_PgUp, G2K_Delete, G2K_F4, G2K_End,
    G2K_F2, G2K_PgDown, G2K_F1, G2K_Left, G2K_Right, G2K_Down, G2K_Up
  );
{$elseif defined(G2Target_Android)}
  const Remap: array[0..255] of IntS32 = (
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
    100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
    110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
    120, 121, 122, 123, 124, 125, 126, 127, 128, 129,
    130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
    140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
    150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
    160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
    170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
    180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
    190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
    200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
    210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
    220, 221, 222, 223, 224, 225, 226, 227, 228, 229,
    230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
    240, 241, 242, 243, 244, 245, 246, 247, 248, 249,
    250, 251, 252, 253, 254, 255
  );
{$elseif defined(G2Target_iOS)}
      const Remap: array[0..255] of TG2IntS32 = (
        0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
        10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
        30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
        40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
        50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
        60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
        70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
        80, 81, 82, 83, 84, 85, 86, 87, 88, 89,
        90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
        100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
        110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
        120, 121, 122, 123, 124, 125, 126, 127, 128, 129,
        130, 131, 132, 133, 134, 135, 136, 137, 138, 139,
        140, 141, 142, 143, 144, 145, 146, 147, 148, 149,
        150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
        160, 161, 162, 163, 164, 165, 166, 167, 168, 169,
        170, 171, 172, 173, 174, 175, 176, 177, 178, 179,
        180, 181, 182, 183, 184, 185, 186, 187, 188, 189,
        190, 191, 192, 193, 194, 195, 196, 197, 198, 199,
        200, 201, 202, 203, 204, 205, 206, 207, 208, 209,
        210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
        220, 221, 222, 223, 224, 225, 226, 227, 228, 229,
        230, 231, 232, 233, 234, 235, 236, 237, 238, 239,
        240, 241, 242, 243, 244, 245, 246, 247, 248, 249,
        250, 251, 252, 253, 254, 255
      );
{$endif}
begin
  if Key <= High(Remap) then Result := Remap[Key] else Result := $ff;
end;

{$if defined(G2Target_iOS)}
class function TG2OpenGLView.layerClass : Pobjc_class;
begin
  Result := CAEAGLLayer.classClass;
end;

function TG2OpenGLView.initWithFrame(frame: CGRect): id;
begin
  Self := inherited initWithFrame(frame);
  if Assigned(Self) then
  begin
    //g2.Start;
    setupLayer;
    setupContext;
    setupRenderBuffer;
    setupFrameBuffer;
    //render;
    g2.Start;
  end;
  Result := Self;
end;

procedure TG2OpenGLView.dealloc;
begin
  TG2GfxGLES(g2.Gfx)._Context.release;
  TG2GfxGLES(g2.Gfx)._Context := nil;
  inherited dealloc;
end;

procedure TG2OpenGLView.setupLayer;
begin
  TG2GfxGLES(g2.Gfx)._EAGLLayer := CAEAGLLayer(self.layer);
  TG2GfxGLES(g2.Gfx)._EAGLLayer.setOpaque(True);
  TG2GfxGLES(g2.Gfx)._EAGLLayer.setDrawableProperties(
    NSDictionary.dictionaryWithObjectsAndKeys(
      NSNumber.numberWithBool(False),
      NSStr('kEAGLDrawablePropertyRetainedBacking'),
      NSStr('kEAGLColorFormatRGBA8'),
      NSStr('kEAGLDrawablePropertyColorFormat'),
      nil
    )
  );
end;

procedure TG2OpenGLView.setupContext;
  var OpenGLVersion: EAGLRenderingAPI;
begin
  OpenGLVersion := kEAGLRenderingAPIOpenGLES1;
  TG2GfxGLES(g2.Gfx)._Context := EAGLContext.alloc.initWithAPI(OpenGLVersion);
  EAGLContext.setCurrentContext(TG2GfxGLES(g2.Gfx)._Context);
end;

procedure TG2OpenGLView.setupRenderBuffer;
begin
  glGenRenderbuffers(1, @TG2GfxGLES(g2.Gfx)._RenderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, TG2GfxGLES(g2.Gfx)._RenderBuffer);
  TG2GfxGLES(g2.Gfx)._Context.renderbufferStorage_fromDrawable(GL_RENDERBUFFER, TG2GfxGLES(g2.Gfx)._EAGLLayer);
end;

procedure TG2OpenGLView.setupFrameBuffer;
  var FrameBuffer: GLUInt;
begin
  glGenFramebuffers(1, @FrameBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, FrameBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, TG2GfxGLES(g2.Gfx)._RenderBuffer);
end;

procedure TG2OpenGLView.render;
begin
  glClearColor(1, 1, 1, 1);
  glClear(GL_COLOR_BUFFER_BIT);
  TG2GfxGLES(g2.Gfx)._Context.presentRenderbuffer(GL_RENDERBUFFER);
end;

procedure TG2AppDelegate.Loop;
begin
  g2.Window.Loop;
end;

function TG2AppDelegate.applicationDidFinishLaunchingWithOptions(application: UIApplication; launchOptions: NSDictionary): Boolean;
  var ctrl: TG2ViewController;
begin
  g2.Delegate := Self;
  _Window := UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds);
  _Window.setBackgroundColor(UIColor.blackColor);
  ctrl := TG2ViewController.alloc().init();
  _Window.setRootViewController(ctrl);
  _Window.makeKeyAndVisible;
  Result := True;
end;

procedure TG2AppDelegate.applicationWillResignActive(application: UIApplication);
begin
end;

procedure TG2AppDelegate.applicationDidEnterBackground(application: UIApplication);
begin
end;

procedure TG2AppDelegate.applicationWillEnterForeground(application: UIApplication);
begin
end;

procedure TG2AppDelegate.applicationDidBecomeActive(application: UIApplication);
begin
end;

procedure TG2AppDelegate.applicationWillTerminate(application: UIApplication);
begin
end;

procedure TG2AppDelegate.dealloc;
begin
  g2.Stop;
  _Window.release;
  inherited dealloc;
end;

function TG2ViewController.initWithNibName_bundle(nibNameOrNil: NSString; nibBundleOrNil: NSBundle): id;
begin
  Self := inherited initWithNibName_bundle(nibNameOrNil, nibBundleOrNil);
  if Assigned(Self) then
  begin
  end;
  Result := Self;
end;

procedure TG2ViewController.dealloc;
begin
  inherited dealloc;
end;

procedure TG2ViewController.didReceiveMemoryWarning;
begin
  inherited didReceiveMemoryWarning;
end;

procedure TG2ViewController.loadView;
begin
  g2.Window.View := TG2OpenGLView.alloc().initWithFrame(UIScreen.mainScreen.bounds);
  setView(g2.Window.View);
end;

//procedure TG2ViewController.viewDidLoad;
//begin
//  inherited viewDidLoad;
//end;

procedure TG2ViewController.viewDidUnload;
begin
  inherited viewDidUnload;
end;

function TG2ViewController.shouldAutorotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation): Boolean;
begin
  Result := toInterfaceOrientation = UIInterfaceOrientationPortrait;
end;
{$endif}

//TG2Core BEGIN
procedure TG2Core.Render;
begin
  if _CanRender then
  begin
    Gfx.RenderStart;
    Gfx.Render;
    Gfx.RenderStop;
    _CanRender := False;
  end;
end;

procedure TG2Core.Update;
  var i: TG2IntS32;
begin
  for i := 0 to _LinkUpdateCount - 1 do
  if _LinkUpdate[i].Obj then
  _LinkUpdate[i].ProcObj
  else
  _LinkUpdate[i].Proc;
end;

procedure TG2Core.UpdateRender;
  var i: TG2IntS32;
begin
  Gfx.Reset;
  Gfx.StateChange.StateRenderTargetDefault;
  for i := 0 to _LinkRenderCount - 1 do
  if _LinkRender[i].Obj then
  _LinkRender[i].ProcObj
  else
  _LinkRender[i].Proc;
  Gfx.StateChange.StateRenderTargetDefault;
  if not _CanRender then
  begin
    Gfx.Swap;
    _CanRender := True;
  end;
end;

procedure TG2Core.OnRender;
  var CurTime: TG2IntU32;
begin
  CurTime := G2Time;
  if (_MaxFPS = 0)
  or (CurTime - _RenderPrevTime >= 1000 / _MaxFPS) then
  begin
    Render;
    _RenderPrevTime := CurTime;
    Inc(_FrameCount);
  end;
  if (CurTime - _FPSUpdateTime >= 1000) then
  begin
    _FPS := _FrameCount;
    _FPSUpdateTime := CurTime;
    _FrameCount := 0;
  end;
end;

procedure TG2Core.OnUpdate;
  var CurTime: TG2IntU32;
  var i, NumUpdates: TG2IntS32;
begin
  if not _Pause then
  begin
    _Window.ProcessMessages;
    CurTime := G2Time;
    _UpdateCount := _UpdateCount + TG2Float(CurTime - _UpdatePrevTime) * _TargetUPS * 0.001;
    NumUpdates := Trunc(_UpdateCount);
    _UpdateCount := _UpdateCount - NumUpdates;
    for i := 0 to NumUpdates - 1 do
    begin
      Update;
      {$if not defined(G2Target_Android)}if not _Window.IsLooping then Break;{$endif}
    end;
    {$if not defined(G2Target_Android)}if _Window.IsLooping then{$endif}
    g2.UpdateRender;
    _UpdatePrevTime := CurTime;
  end;
end;

procedure TG2Core.OnStart;
  var i: TG2IntS32;
begin
  _Window := TG2Window.Create(_Params.Width, _Params.Height);
  _Gfx.Initialize;
  _Snd.Initialize;
  for i := 0 to _LinkInitializeCount - 1 do
  if _LinkInitialize[i].Obj then
  _LinkInitialize[i].ProcObj()
  else
  _LinkInitialize[i].Proc();
  {$ifdef G2Threading}
  _Updater := TG2Updater.Create(True);
  _Updater.FreeOnTerminate := False;
  _Updater.Resume;
  _Renderer := TG2Renderer.Create(True);
  _Renderer.FreeOnTerminate := False;
  _Renderer.Resume;
  {$endif}
  _CanRender := False;
  _Started := True;
  {$if defined(G2Target_Windows) or defined(G2Target_Linux) or defined(G2Target_OSX)}
  _Window.Loop;
  {$elseif defined(G2Target_iOS)}
  NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats(1 / 60, _Delegate, objcselector('Loop'), nil, True);
  {$endif}
end;

procedure TG2Core.OnStop;
  var i: TG2IntS32;
begin
  {$ifdef G2Threading}
  _Renderer.Terminate;
  _Renderer.WaitFor;
  _Renderer.Free;
  _Renderer := nil;
  _Updater.Terminate;
  _Updater.WaitFor;
  _Updater.Free;
  _Updater := nil;
  {$endif}
  for i := 0 to _LinkFinalizeCount - 1 do
  if _LinkFinalize[i].Obj then
  _LinkFinalize[i].ProcObj
  else
  _LinkFinalize[i].Proc;
  _Snd.Finalize;
  _Gfx.Finalize;
  _Window.Free;
  _Window := nil;
  _Started := False;
end;

procedure TG2Core.OnPrint(const Char: AnsiChar);
  var i: TG2IntS32;
begin
  for i := 0 to _LinkPrintCount - 1 do
  if _LinkPrint[i].Obj then
  _LinkPrint[i].ProcObj(Char)
  else
  _LinkPrint[i].Proc(Char);
end;

procedure TG2Core.OnKeyDown(const Key: TG2IntS32);
  var i: TG2IntS32;
begin
  for i := 0 to _LinkKeyDownCount - 1 do
  if _LinkKeyDown[i].Obj then
  _LinkKeyDown[i].ProcObj(Key)
  else
  _LinkKeyDown[i].Proc(Key);
  _KeyDown[Key] := True;
end;

procedure TG2Core.OnKeyUp(const Key: TG2IntS32);
  var i: TG2IntS32;
begin
  for i := 0 to _LinkKeyUpCount - 1 do
  if _LinkKeyUp[i].Obj then
  _LinkKeyUp[i].ProcObj(Key)
  else
  _LinkKeyUp[i].Proc(Key);
  _KeyDown[Key] := False;
end;

procedure TG2Core.OnMouseDown(const Button: TG2IntS32; const x, y: TG2IntS32);
  var i: TG2IntS32;
begin
  for i := 0 to _LinkMouseDownCount - 1 do
  if _LinkMouseDown[i].Obj then
  _LinkMouseDown[i].ProcObj(Button, x, y)
  else
  _LinkMouseDown[i].Proc(Button, x, y);
  _MDPos[Button] := Point(x, y);
  _MBDown[Button] := True;
end;

procedure TG2Core.OnMouseUp(const Button: TG2IntS32; const x, y: TG2IntS32);
  var i: TG2IntS32;
begin
  for i := 0 to _LinkMouseUpCount - 1 do
  if _LinkMouseUp[i].Obj then
  _LinkMouseUp[i].ProcObj(Button, x, y)
  else
  _LinkMouseUp[i].Proc(Button, x, y);
  _MBDown[Button] := False;
end;

procedure TG2Core.OnScroll(const y: TG2IntS32);
  var i: TG2IntS32;
begin
  for i := 0 to _LinkScrollCount - 1 do
  if _LinkScroll[i].Obj then
  _LinkScroll[i].ProcObj(y)
  else
  _LinkScroll[i].Proc(y);
end;

function TG2Core.GetKeyDown(const Index: TG2IntS32): Boolean;
begin
  if Index > High(_KeyDown) then
  begin
    Result := False;
    Exit;
  end;
  Result := _KeyDown[Index];
end;

function TG2Core.GetMouseDown(const Index: TG2IntS32): Boolean;
begin
  if Index > High(_MBDown) then
  begin
    Result := False;
    Exit;
  end;
  Result := _MBDown[Index];
end;

function TG2Core.GetMouseDownPos(const Index: TG2IntS32): TPoint;
begin
  Result := _MDPos[Index];
end;

{$Hints off}
function TG2Core.GetMousePos: TPoint;
{$if defined(G2Target_Windows)}
begin
  GetCursorPos(Result);
  if _Started then
  ScreenToClient(_Window.Handle, Result);
end;
{$elseif defined(G2Target_Linux)}
  var e: TXEvent;
begin
  XQueryPointer(
    _Window.Display, _Window.Handle,
    @e.xbutton.root, @e.xbutton.window,
    @e.xbutton.x_root, @e.xbutton.y_root,
    @Result.x, @Result.y,
    @e.xbutton.state
  );
end;
{$elseif defined(G2Target_OSX)}
  var CursorPos: MacOSAll.Point;
  var WindowRect: MacOSAll.Rect;
begin
  GetMouse(CursorPos);
  GetWindowBounds(_Window.Handle, kWindowContentRgn, WindowRect);
  Result := Point(CursorPos.h - WindowRect.left, CursorPos.v - WindowRect.top);
end;
{$elseif defined(G2Target_Android)}
begin
  Result := _CursorPos;
end;
{$elseif defined(G2Target_iOS)}
begin
  Result := _CursorPos;
end;
{$endif}
{$Hints on}

function TG2Core.GetAppPath: FileString;
begin
  Result := G2GetAppPath;
end;

procedure TG2Core.SetShowCursor(const Value: Boolean);
begin
  if _ShowCursor <> Value then
  begin
    _ShowCursor := Value;
    {$if defined(G2Target_Windows)}
    Windows.ShowCursor(_ShowCursor);
    {$endif}
  end;
end;

procedure TG2Core.SetPause(const Value: Boolean);
begin
  if _Pause <> Value then
  begin
    _Pause := Value;
    if not _Pause then
    _UpdatePrevTime := G2Time;
  end;
end;

function TG2Core.GetDeltaTime: TG2Float;
begin
  Result := 1000 / _TargetUPS;
end;

procedure TG2Core.Start;
  var CurTime: TG2IntU32;
  {$if defined(G2Target_iOS)}
  var Pool: NSAutoreleasePool;
  {$endif}
begin
  {$if defined(G2Target_iOS)}
  if not _PoolInitialized then
  begin
    Pool := NSAutoreleasePool.alloc.init;
    _PoolInitialized := True;
    ExitCode := UIApplicationMain(argc, argv, nil, NSStr('TG2AppDelegate'));
    Pool.release;
    Exit;
  end;
  {$endif}
  if _Started then Exit;
  CurTime := G2Time;
  _UpdatePrevTime := CurTime;
  _UpdateCount := 1;
  _TargetUPS := g2.Params.TargetUPS;
  _MaxFPS := g2.Params.MaxFPS;
  _RenderPrevTime := CurTime;
  _FrameCount := 0;
  _FPSUpdateTime := CurTime;
  FillChar(_KeyDown, SizeOf(_KeyDown), 0);
  FillChar(_MBDown, SizeOf(_MBDown), 0);
  OnStart;
  _UpdatePrevTime := CurTime;
end;

procedure TG2Core.Stop;
begin
  if _Started then
  begin
    {$ifdef G2Target_Android}
    OnStop;
    AndroidBinding.AppClose;
    {$else}
    _Window.Stop;
    {$endif}
  end;
end;

{$ifdef G2Target_Android}
{$Hints off}
class procedure TG2Core.AndroidMessage(const Env: PJNIEnv; const Obj: JObject; const MessageType, Param0, Param1, Param2: TG2IntS32);
begin
  case TG2AndroidMessageType(MessageType) of
    amConnect:
    begin
      AndroidBinding.Init(Env, Obj);
    end;
    amInit:
    begin
      G2InitializeMath;
      G2Initialize;
      g2.Params._ScreenWidth := Param0;
      g2.Params._ScreenHeight := Param1;
      g2.Params.Width := Param0;
      g2.Params.Height := Param1;
    end;
    amQuit:
    begin
      g2.Stop;
      G2Finalize;
    end;
    amResize:
    begin
      g2.Params.Width := Param0;
      g2.Params.Height := Param1;
      glViewport(0, 0, Param0, Param1);
    end;
    amDraw:
    begin
      g2.OnUpdate;
      g2.OnRender;
    end;
    amTouchDown:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseDown, G2MB_Left, Param0, Param1);
      g2._CursorPos := Point(Param0, Param1);
    end;
    amTouchUp:
    begin
      g2.Window.AddMessage(@g2.Window.OnMouseUp, G2MB_Left, Param0, Param1);
      g2._CursorPos := Point(Param0, Param1);
    end;
    amTouchMove:
    begin
      g2._CursorPos := Point(Param0, Param1);
    end;
  end;
end;
{$Hints on}
{$endif}

procedure TG2Core.CallbackInitializeAdd(const ProcInitialize: TG2Proc);
begin
  if _LinkInitializeCount >= Length(_LinkInitialize) then
  SetLength(_LinkInitialize, _LinkInitializeCount + 32);
  _LinkInitialize[_LinkInitializeCount].Obj := False;
  _LinkInitialize[_LinkInitializeCount].Proc := ProcInitialize;
  Inc(_LinkInitializeCount);
end;

procedure TG2Core.CallbackInitializeAdd(const ProcInitialize: TG2ProcObj);
begin
  if _LinkInitializeCount >= Length(_LinkInitialize) then
  SetLength(_LinkInitialize, _LinkInitializeCount + 32);
  _LinkInitialize[_LinkInitializeCount].Obj := True;
  _LinkInitialize[_LinkInitializeCount].ProcObj := ProcInitialize;
  Inc(_LinkInitializeCount);
end;

procedure TG2Core.CallbackInitializeRemove(const ProcInitialize: TG2Proc);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkInitializeCount - 1 do
  if not _LinkInitialize[i].Obj and (_LinkInitialize[i].Proc = ProcInitialize) then
  begin
    for j := i to _LinkInitializeCount - 2 do
    begin
      _LinkInitialize[i].Obj := _LinkInitialize[i + 1].Obj;
      _LinkInitialize[i].Proc := _LinkInitialize[i + 1].Proc;
      _LinkInitialize[i].ProcObj := _LinkInitialize[i + 1].ProcObj;
    end;
    _LinkInitializeCount := _LinkInitializeCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackInitializeRemove(const ProcInitialize: TG2ProcObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkInitializeCount - 1 do
  if _LinkInitialize[i].Obj and (_LinkInitialize[i].ProcObj = ProcInitialize) then
  begin
    for j := i to _LinkInitializeCount - 2 do
    begin
      _LinkInitialize[i].Obj := _LinkInitialize[i + 1].Obj;
      _LinkInitialize[i].Proc := _LinkInitialize[i + 1].Proc;
      _LinkInitialize[i].ProcObj := _LinkInitialize[i + 1].ProcObj;
    end;
    _LinkInitializeCount := _LinkInitializeCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackFinalizeAdd(const ProcFinalize: TG2Proc);
begin
  if _LinkFinalizeCount >= Length(_LinkFinalize) then
  SetLength(_LinkFinalize, _LinkFinalizeCount + 32);
  _LinkFinalize[_LinkFinalizeCount].Obj := False;
  _LinkFinalize[_LinkFinalizeCount].Proc := ProcFinalize;
  Inc(_LinkFinalizeCount);
end;

procedure TG2Core.CallbackFinalizeAdd(const ProcFinalize: TG2ProcObj);
begin
  if _LinkFinalizeCount >= Length(_LinkFinalize) then
  SetLength(_LinkFinalize, _LinkFinalizeCount + 32);
  _LinkFinalize[_LinkFinalizeCount].Obj := True;
  _LinkFinalize[_LinkFinalizeCount].ProcObj := ProcFinalize;
  Inc(_LinkFinalizeCount);
end;

procedure TG2Core.CallbackFinalizeRemove(const ProcFinalize: TG2Proc);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkFinalizeCount - 1 do
  if not _LinkFinalize[i].Obj and (_LinkFinalize[i].Proc = ProcFinalize) then
  begin
    for j := i to _LinkFinalizeCount - 2 do
    begin
      _LinkFinalize[i].Obj := _LinkFinalize[i + 1].Obj;
      _LinkFinalize[i].Proc := _LinkFinalize[i + 1].Proc;
      _LinkFinalize[i].ProcObj := _LinkFinalize[i + 1].ProcObj;
    end;
    _LinkFinalizeCount := _LinkFinalizeCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackFinalizeRemove(const ProcFinalize: TG2ProcObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkFinalizeCount - 1 do
  if _LinkFinalize[i].Obj and (_LinkFinalize[i].ProcObj = ProcFinalize) then
  begin
    for j := i to _LinkFinalizeCount - 2 do
    begin
      _LinkFinalize[i].Obj := _LinkFinalize[i + 1].Obj;
      _LinkFinalize[i].Proc := _LinkFinalize[i + 1].Proc;
      _LinkFinalize[i].ProcObj := _LinkFinalize[i + 1].ProcObj;
    end;
    _LinkFinalizeCount := _LinkFinalizeCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackUpdateAdd(const ProcUpdate: TG2Proc);
begin
  if _LinkUpdateCount >= Length(_LinkUpdate) then
  SetLength(_LinkUpdate, _LinkUpdateCount + 32);
  _LinkUpdate[_LinkUpdateCount].Obj := False;
  _LinkUpdate[_LinkUpdateCount].Proc := ProcUpdate;
  Inc(_LinkUpdateCount);
end;

procedure TG2Core.CallbackUpdateAdd(const ProcUpdate: TG2ProcObj);
begin
  if _LinkUpdateCount >= Length(_LinkUpdate) then
  SetLength(_LinkUpdate, _LinkUpdateCount + 32);
  _LinkUpdate[_LinkUpdateCount].Obj := True;
  _LinkUpdate[_LinkUpdateCount].ProcObj := ProcUpdate;
  Inc(_LinkUpdateCount);
end;

procedure TG2Core.CallbackUpdateRemove(const ProcUpdate: TG2Proc);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkUpdateCount - 1 do
  if not _LinkUpdate[i].Obj and (_LinkUpdate[i].Proc = ProcUpdate) then
  begin
    for j := i to _LinkUpdateCount - 2 do
    begin
      _LinkUpdate[i].Obj := _LinkUpdate[i + 1].Obj;
      _LinkUpdate[i].Proc := _LinkUpdate[i + 1].Proc;
      _LinkUpdate[i].ProcObj := _LinkUpdate[i + 1].ProcObj;
    end;
    _LinkUpdateCount := _LinkUpdateCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackUpdateRemove(const ProcUpdate: TG2ProcObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkUpdateCount - 1 do
  if _LinkUpdate[i].Obj and (_LinkUpdate[i].ProcObj = ProcUpdate) then
  begin
    for j := i to _LinkUpdateCount - 2 do
    begin
      _LinkUpdate[i].Obj := _LinkUpdate[i + 1].Obj;
      _LinkUpdate[i].Proc := _LinkUpdate[i + 1].Proc;
      _LinkUpdate[i].ProcObj := _LinkUpdate[i + 1].ProcObj;
    end;
    _LinkUpdateCount := _LinkUpdateCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackRenderAdd(const ProcRender: TG2Proc);
begin
  if _LinkRenderCount >= Length(_LinkRender) then
  SetLength(_LinkRender, _LinkRenderCount + 32);
  _LinkRender[_LinkRenderCount].Obj := False;
  _LinkRender[_LinkRenderCount].Proc := ProcRender;
  Inc(_LinkRenderCount);
end;

procedure TG2Core.CallbackRenderAdd(const ProcRender: TG2ProcObj);
begin
  if _LinkRenderCount >= Length(_LinkRender) then
  SetLength(_LinkRender, _LinkRenderCount + 32);
  _LinkRender[_LinkRenderCount].Obj := True;
  _LinkRender[_LinkRenderCount].ProcObj := ProcRender;
  Inc(_LinkRenderCount);
end;

procedure TG2Core.CallbackRenderRemove(const ProcRender: TG2Proc);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkRenderCount - 1 do
  if not _LinkRender[i].Obj and (_LinkRender[i].Proc = ProcRender) then
  begin
    for j := i to _LinkRenderCount - 2 do
    begin
      _LinkRender[i].Obj := _LinkRender[i + 1].Obj;
      _LinkRender[i].Proc := _LinkRender[i + 1].Proc;
      _LinkRender[i].ProcObj := _LinkRender[i + 1].ProcObj;
    end;
    _LinkRenderCount := _LinkRenderCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackRenderRemove(const ProcRender: TG2ProcObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkRenderCount - 1 do
  if _LinkRender[i].Obj and (_LinkRender[i].ProcObj = ProcRender) then
  begin
    for j := i to _LinkRenderCount - 2 do
    begin
      _LinkRender[i].Obj := _LinkRender[i + 1].Obj;
      _LinkRender[i].Proc := _LinkRender[i + 1].Proc;
      _LinkRender[i].ProcObj := _LinkRender[i + 1].ProcObj;
    end;
    _LinkRenderCount := _LinkRenderCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackPrintAdd(const ProcPrint: TG2ProcChar);
begin
  if _LinkPrintCount >= Length(_LinkPrint) then
  SetLength(_LinkPrint, _LinkPrintCount + 32);
  _LinkPrint[_LinkPrintCount].Obj := False;
  _LinkPrint[_LinkPrintCount].Proc := ProcPrint;
  Inc(_LinkPrintCount);
end;

procedure TG2Core.CallbackPrintAdd(const ProcPrint: TG2ProcCharObj);
begin
  if _LinkPrintCount >= Length(_LinkPrint) then
  SetLength(_LinkPrint, _LinkPrintCount + 32);
  _LinkPrint[_LinkPrintCount].Obj := True;
  _LinkPrint[_LinkPrintCount].ProcObj := ProcPrint;
  Inc(_LinkPrintCount);
end;

procedure TG2Core.CallbackPrintRemove(const ProcPrint: TG2ProcChar);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkPrintCount - 1 do
  if not _LinkPrint[i].Obj and (_LinkPrint[i].Proc = ProcPrint) then
  begin
    for j := i to _LinkPrintCount - 2 do
    begin
      _LinkPrint[i].Obj := _LinkPrint[i + 1].Obj;
      _LinkPrint[i].Proc := _LinkPrint[i + 1].Proc;
      _LinkPrint[i].ProcObj := _LinkPrint[i + 1].ProcObj;
    end;
    _LinkPrintCount := _LinkPrintCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackPrintRemove(const ProcPrint: TG2ProcCharObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkPrintCount - 1 do
  if _LinkPrint[i].Obj and (_LinkPrint[i].ProcObj = ProcPrint) then
  begin
    for j := i to _LinkPrintCount - 2 do
    begin
      _LinkPrint[i].Obj := _LinkPrint[i + 1].Obj;
      _LinkPrint[i].Proc := _LinkPrint[i + 1].Proc;
      _LinkPrint[i].ProcObj := _LinkPrint[i + 1].ProcObj;
    end;
    _LinkPrintCount := _LinkPrintCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackKeyDownAdd(const ProcKeyDown: TG2ProcKey);
begin
  if _LinkKeyDownCount >= Length(_LinkKeyDown) then
  SetLength(_LinkKeyDown, _LinkKeyDownCount + 32);
  _LinkKeyDown[_LinkKeyDownCount].Obj := False;
  _LinkKeyDown[_LinkKeyDownCount].Proc := ProcKeyDown;
  Inc(_LinkKeyDownCount);
end;

procedure TG2Core.CallbackKeyDownAdd(const ProcKeyDown: TG2ProcKeyObj);
begin
  if _LinkKeyDownCount >= Length(_LinkKeyDown) then
  SetLength(_LinkKeyDown, _LinkKeyDownCount + 32);
  _LinkKeyDown[_LinkKeyDownCount].Obj := True;
  _LinkKeyDown[_LinkKeyDownCount].ProcObj := ProcKeyDown;
  Inc(_LinkKeyDownCount);
end;

procedure TG2Core.CallbackKeyDownRemove(const ProcKeyDown: TG2ProcKey);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkKeyDownCount - 1 do
  if not _LinkKeyDown[i].Obj and (_LinkKeyDown[i].Proc = ProcKeyDown) then
  begin
    for j := i to _LinkKeyDownCount - 2 do
    begin
      _LinkKeyDown[i].Obj := _LinkKeyDown[i + 1].Obj;
      _LinkKeyDown[i].Proc := _LinkKeyDown[i + 1].Proc;
      _LinkKeyDown[i].ProcObj := _LinkKeyDown[i + 1].ProcObj;
    end;
    _LinkKeyDownCount := _LinkKeyDownCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackKeyDownRemove(const ProcKeyDown: TG2ProcKeyObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkKeyDownCount - 1 do
  if _LinkKeyDown[i].Obj and (_LinkKeyDown[i].ProcObj = ProcKeyDown) then
  begin
    for j := i to _LinkKeyDownCount - 2 do
    begin
      _LinkKeyDown[i].Obj := _LinkKeyDown[i + 1].Obj;
      _LinkKeyDown[i].Proc := _LinkKeyDown[i + 1].Proc;
      _LinkKeyDown[i].ProcObj := _LinkKeyDown[i + 1].ProcObj;
    end;
    _LinkKeyDownCount := _LinkKeyDownCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackKeyUpAdd(const ProcKeyUp: TG2ProcKey);
begin
  if _LinkKeyUpCount >= Length(_LinkKeyUp) then
  SetLength(_LinkKeyUp, _LinkKeyUpCount + 32);
  _LinkKeyUp[_LinkKeyUpCount].Obj := False;
  _LinkKeyUp[_LinkKeyUpCount].Proc := ProcKeyUp;
  Inc(_LinkKeyUpCount);
end;

procedure TG2Core.CallbackKeyUpAdd(const ProcKeyUp: TG2ProcKeyObj);
begin
  if _LinkKeyUpCount >= Length(_LinkKeyUp) then
  SetLength(_LinkKeyUp, _LinkKeyUpCount + 32);
  _LinkKeyUp[_LinkKeyUpCount].Obj := True;
  _LinkKeyUp[_LinkKeyUpCount].ProcObj := ProcKeyUp;
  Inc(_LinkKeyUpCount);
end;

procedure TG2Core.CallbackKeyUpRemove(const ProcKeyUp: TG2ProcKey);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkKeyUpCount - 1 do
  if not _LinkKeyUp[i].Obj and (_LinkKeyUp[i].Proc = ProcKeyUp) then
  begin
    for j := i to _LinkKeyUpCount - 2 do
    begin
      _LinkKeyUp[i].Obj := _LinkKeyUp[i + 1].Obj;
      _LinkKeyUp[i].Proc := _LinkKeyUp[i + 1].Proc;
      _LinkKeyUp[i].ProcObj := _LinkKeyUp[i + 1].ProcObj;
    end;
    _LinkKeyUpCount := _LinkKeyUpCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackKeyUpRemove(const ProcKeyUp: TG2ProcKeyObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkKeyUpCount - 1 do
  if _LinkKeyUp[i].Obj and (_LinkKeyUp[i].ProcObj = ProcKeyUp) then
  begin
    for j := i to _LinkKeyUpCount - 2 do
    begin
      _LinkKeyUp[i].Obj := _LinkKeyUp[i + 1].Obj;
      _LinkKeyUp[i].Proc := _LinkKeyUp[i + 1].Proc;
      _LinkKeyUp[i].ProcObj := _LinkKeyUp[i + 1].ProcObj;
    end;
    _LinkKeyUpCount := _LinkKeyUpCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackMouseDownAdd(const ProcMouseDown: TG2ProcMouse);
begin
  if _LinkMouseDownCount >= Length(_LinkMouseDown) then
  SetLength(_LinkMouseDown, _LinkMouseDownCount + 32);
  _LinkMouseDown[_LinkMouseDownCount].Obj := False;
  _LinkMouseDown[_LinkMouseDownCount].Proc := ProcMouseDown;
  Inc(_LinkMouseDownCount);
end;

procedure TG2Core.CallbackMouseDownAdd(const ProcMouseDown: TG2ProcMouseObj);
begin
  if _LinkMouseDownCount >= Length(_LinkMouseDown) then
  SetLength(_LinkMouseDown, _LinkMouseDownCount + 32);
  _LinkMouseDown[_LinkMouseDownCount].Obj := True;
  _LinkMouseDown[_LinkMouseDownCount].ProcObj := ProcMouseDown;
  Inc(_LinkMouseDownCount);
end;

procedure TG2Core.CallbackMouseDownRemove(const ProcMouseDown: TG2ProcMouse);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkMouseDownCount - 1 do
  if not _LinkMouseDown[i].Obj and (_LinkMouseDown[i].Proc = ProcMouseDown) then
  begin
    for j := i to _LinkMouseDownCount - 2 do
    begin
      _LinkMouseDown[i].Obj := _LinkMouseDown[i + 1].Obj;
      _LinkMouseDown[i].Proc := _LinkMouseDown[i + 1].Proc;
      _LinkMouseDown[i].ProcObj := _LinkMouseDown[i + 1].ProcObj;
    end;
    _LinkMouseDownCount := _LinkMouseDownCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackMouseDownRemove(const ProcMouseDown: TG2ProcMouseObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkMouseDownCount - 1 do
  if _LinkMouseDown[i].Obj and (_LinkMouseDown[i].ProcObj = ProcMouseDown) then
  begin
    for j := i to _LinkMouseDownCount - 2 do
    begin
      _LinkMouseDown[i].Obj := _LinkMouseDown[i + 1].Obj;
      _LinkMouseDown[i].Proc := _LinkMouseDown[i + 1].Proc;
      _LinkMouseDown[i].ProcObj := _LinkMouseDown[i + 1].ProcObj;
    end;
    _LinkMouseDownCount := _LinkMouseDownCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackMouseUpAdd(const ProcMouseUp: TG2ProcMouse);
begin
  if _LinkMouseUpCount >= Length(_LinkMouseUp) then
  SetLength(_LinkMouseUp, _LinkMouseUpCount + 32);
  _LinkMouseUp[_LinkMouseUpCount].Obj := False;
  _LinkMouseUp[_LinkMouseUpCount].Proc := ProcMouseUp;
  Inc(_LinkMouseUpCount);
end;

procedure TG2Core.CallbackMouseUpAdd(const ProcMouseUp: TG2ProcMouseObj);
begin
  if _LinkMouseUpCount >= Length(_LinkMouseUp) then
  SetLength(_LinkMouseUp, _LinkMouseUpCount + 32);
  _LinkMouseUp[_LinkMouseUpCount].Obj := True;
  _LinkMouseUp[_LinkMouseUpCount].ProcObj := ProcMouseUp;
  Inc(_LinkMouseUpCount);
end;

procedure TG2Core.CallbackMouseUpRemove(const ProcMouseUp: TG2ProcMouse);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkMouseUpCount - 1 do
  if not _LinkMouseUp[i].Obj and (_LinkMouseUp[i].Proc = ProcMouseUp) then
  begin
    for j := i to _LinkMouseUpCount - 2 do
    begin
      _LinkMouseUp[i].Obj := _LinkMouseUp[i + 1].Obj;
      _LinkMouseUp[i].Proc := _LinkMouseUp[i + 1].Proc;
      _LinkMouseUp[i].ProcObj := _LinkMouseUp[i + 1].ProcObj;
    end;
    _LinkMouseUpCount := _LinkMouseUpCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackMouseUpRemove(const ProcMouseUp: TG2ProcMouseObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkMouseUpCount - 1 do
  if _LinkMouseUp[i].Obj and (_LinkMouseUp[i].ProcObj = ProcMouseUp) then
  begin
    for j := i to _LinkMouseUpCount - 2 do
    begin
      _LinkMouseUp[i].Obj := _LinkMouseUp[i + 1].Obj;
      _LinkMouseUp[i].Proc := _LinkMouseUp[i + 1].Proc;
      _LinkMouseUp[i].ProcObj := _LinkMouseUp[i + 1].ProcObj;
    end;
    _LinkMouseUpCount := _LinkMouseUpCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackScrollAdd(const ProcScroll: TG2ProcScroll);
begin
  if _LinkScrollCount >= Length(_LinkScroll) then
  SetLength(_LinkScroll, _LinkScrollCount + 32);
  _LinkScroll[_LinkScrollCount].Obj := False;
  _LinkScroll[_LinkScrollCount].Proc := ProcScroll;
  Inc(_LinkScrollCount);
end;

procedure TG2Core.CallbackScrollAdd(const ProcScroll: TG2ProcScrollObj);
begin
  if _LinkScrollCount >= Length(_LinkScroll) then
  SetLength(_LinkScroll, _LinkScrollCount + 32);
  _LinkScroll[_LinkScrollCount].Obj := True;
  _LinkScroll[_LinkScrollCount].ProcObj := ProcScroll;
  Inc(_LinkScrollCount);
end;

procedure TG2Core.CallbackScrollRemove(const ProcScroll: TG2ProcScroll);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkScrollCount - 1 do
  if not _LinkScroll[i].Obj and (_LinkScroll[i].Proc = ProcScroll) then
  begin
    for j := i to _LinkScrollCount - 2 do
    begin
      _LinkScroll[i].Obj := _LinkScroll[i + 1].Obj;
      _LinkScroll[i].Proc := _LinkScroll[i + 1].Proc;
      _LinkScroll[i].ProcObj := _LinkScroll[i + 1].ProcObj;
    end;
    _LinkScrollCount := _LinkScrollCount - 1;
    Break;
  end;
end;

procedure TG2Core.CallbackScrollRemove(const ProcScroll: TG2ProcScrollObj);
  var i, j: TG2IntS32;
begin
  for i := 0 to _LinkScrollCount - 1 do
  if _LinkScroll[i].Obj and (_LinkScroll[i].ProcObj = ProcScroll) then
  begin
    for j := i to _LinkScrollCount - 2 do
    begin
      _LinkScroll[i].Obj := _LinkScroll[i + 1].Obj;
      _LinkScroll[i].Proc := _LinkScroll[i + 1].Proc;
      _LinkScroll[i].ProcObj := _LinkScroll[i + 1].ProcObj;
    end;
    _LinkScrollCount := _LinkScrollCount - 1;
    Break;
  end;
end;

procedure TG2Core.PicQuadCol(
  const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2IntU32 = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  _Gfx.Pic2D.DrawQuad(
    Pos0, Pos1, Pos2, Pos3,
    Tex0, Tex1, Tex2, Tex3,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Core.PicQuadCol(
  const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  _Gfx.Pic2D.DrawQuad(
    G2Vec2(x0, y0), G2Vec2(x1, y1), G2Vec2(x2, y2), G2Vec2(x3, y3),
    G2Vec2(tu0, tv0), G2Vec2(tu1, tv1), G2Vec2(tu2, tv2), G2Vec2(tu3, tv3),
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Core.PicQuad(
  const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase; const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicQuadCol(
    Pos0, Pos1, Pos2, Pos3,
    Tex0, Tex1, Tex2, Tex3,
    Col, Col, Col, Col,
    Texture, BlendMode,
    Filtering
  );
end;

procedure TG2Core.PicQuad(
  const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase; const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicQuadCol(
    x0, y0, x1, y1, x2, y2, x3, y3,
    tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3,
    Col, Col, Col, Col,
    Texture, BlendMode,
    Filtering
  );
end;

procedure TG2Core.PicRectCol(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col0, Col1, Col2, Col3: TG2Color;
      const TexRect: TG2Vec4;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
); overload;
begin
  PicRectCol(Pos.x, Pos.y, Width, Height, Col0, Col1, Col2, Col3, TexRect.x, TexRect.y, TexRect.z, TexRect.w, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRectCol(
  const x, y: TG2Float;
  const Width, Height: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const tu0, tv0, tu1, tv1: TG2Float;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
); overload;
  var x0, y0, x1, y1: TG2Float;
begin
  x0 := x; y0 := y;
  x1 := x0 + Width;
  y1 := y0 + Height;
  PicQuadCol(
    x0, y0, x1, y0, x0, y1, x1, y1,
    tu0, tv0, tu1, tv0, tu0, tv1, tu1, tv1,
    Col0, Col1, Col2, Col3,
    Texture,
    BlendMode,
    Filtering
  );
end;

procedure TG2Core.PicRectCol(
  const Pos: TG2Vec2;
  const Width, Height: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos.x, Pos.y, Width, Height, Col0, Col1, Col2, Col3, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRectCol(
  const x, y: TG2Float;
  const Width, Height: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, Width, Height, Col0, Col1, Col2, Col3, 0, 0, Texture.SizeTU, Texture.SizeTV, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRectCol(
  const Pos: TG2Vec2;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos.x, Pos.y, Texture.Width, Texture.Height, Col0, Col1, Col2, Col3, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRectCol(
  const x, y: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, Texture.Width, Texture.Height, Col0, Col1, Col2, Col3, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRectCol(
  const Pos: TG2Vec2;
  const Width, Height: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(
    Pos.x, Pos.y, Width, Height,
    Col0, Col1, Col2, Col3,
    CenterX, CenterY, ScaleX, ScaleY, Rotation,
    FlipU, FlipV, Texture,
    FrameWidth, FrameHeight, FrameID,
    BlendMode, Filtering
  );
end;

procedure TG2Core.PicRectCol(
  const x, y: TG2Float;
  const Width, Height: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var Pts: array[0..3] of TG2Vec2;
  var w, h: TG2Float;
  var mr: TG2Mat;
  var pc, py, px: TG2IntS32;
  var tu, tv: TG2Float;
  var tr0, tr1, tc0, tc1, tc2, tc3: TG2Vec2;
begin
  mr := G2MatRotationZ(Rotation);
  w := Width * ScaleX; h := Height * ScaleY;
  {$Warnings off}
  Pts[0].SetValue(-w * CenterX, -h * CenterY);
  Pts[1].SetValue(Pts[0].x + w, Pts[0].y);
  Pts[2].SetValue(Pts[0].x, Pts[0].y + h);
  Pts[3].SetValue(Pts[0].x + w, Pts[0].y + h);
  {$Warnings on}
  G2Vec2MatMul3x3(@Pts[0], @Pts[0], @mr);
  G2Vec2MatMul3x3(@Pts[1], @Pts[1], @mr);
  G2Vec2MatMul3x3(@Pts[2], @Pts[2], @mr);
  G2Vec2MatMul3x3(@Pts[3], @Pts[3], @mr);
  Pts[0].x := Pts[0].x + x; Pts[0].y := Pts[0].y + y;
  Pts[1].x := Pts[1].x + x; Pts[1].y := Pts[1].y + y;
  Pts[2].x := Pts[2].x + x; Pts[2].y := Pts[2].y + y;
  Pts[3].x := Pts[3].x + x; Pts[3].y := Pts[3].y + y;
  tu := (FrameWidth / Texture.Width) * Texture.SizeTU;
  tv := (FrameHeight / Texture.Height) * Texture.SizeTV;
  pc := Texture.Width div FrameWidth;
  px := FrameID mod pc;
  py := FrameID div pc;
  tr0.SetValue(px * tu, py * tv);
  tr1.SetValue(px * tu + tu, py * tv + tv);
  if FlipU then
  begin
    tc0.x := tr1.x; tc1.x := tr0.x;
    tc2.x := tr1.x; tc3.x := tr0.x;
  end
  else
  begin
    tc0.x := tr0.x; tc1.x := tr1.x;
    tc2.x := tr0.x; tc3.x := tr1.x;
  end;
  if FlipV then
  begin
    tc0.y := tr1.y; tc2.y := tr0.y;
    tc1.y := tr1.y; tc3.y := tr0.y;
  end
  else
  begin
    tc0.y := tr0.y; tc2.y := tr1.y;
    tc1.y := tr0.y; tc3.y := tr1.y;
  end;
  _Gfx.Pic2D.DrawQuad(
    Pts[0], Pts[1], Pts[2], Pts[3],
    tc0, tc1, tc2, tc3,
    Col0, Col1, Col2, Col3,
    Texture,
    BlendMode,
    Filtering
  );
end;

procedure TG2Core.PicRect(
  const Pos: TG2Vec2; const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos.x, Pos.y, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
  const x, y: TG2Float; const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
  const Pos: TG2Vec2;
  const Width, Height: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos, Width, Height, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
  const x, y: TG2Float;
  const Width, Height: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, Width, Height, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const TexRect: TG2Vec4;
      const Col: TG2Color;
      const Texture: TG2Texture2DBase;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
); overload;
begin
  PicRectCol(Pos, Width, Height, Col, Col, Col, Col, TexRect, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
  const x, y: TG2Float;
  const Width, Height: TG2Float;
  const tu0, tv0, tu1, tv1: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
); overload;
begin
  PicRectCol(x, y, Width, Height, Col, Col, Col, Col, tu0, tv0, tu1, tv1, Texture, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
      const Pos: TG2Vec2;
      const Width, Height: TG2Float;
      const Col: TG2Color;
      const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
      const FlipU, FlipV: Boolean;
      const Texture: TG2Texture2DBase;
      const FrameWidth, FrameHeight: TG2IntS32;
      const FrameID: TG2IntS32;
      const BlendMode: TG2BlendMode = bmNormal;
      const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos, Width, Height, Col, Col, Col, Col, CenterX, CenterY, ScaleX, ScaleY, Rotation, FlipU, FlipV, Texture, FrameWidth, FrameHeight, FrameID, BlendMode, Filtering);
end;

procedure TG2Core.PicRect(
  const x, y: TG2Float;
  const Width, Height: TG2Float;
  const Col: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Rotation: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, Width, Height, Col, Col, Col, Col, CenterX, CenterY, ScaleX, ScaleY, Rotation, FlipU, FlipV, Texture, FrameWidth, FrameHeight, FrameID, BlendMode, Filtering);
end;

procedure TG2Core.PrimBegin(const PrimType: TG2PrimType; const BlendMode: TG2BlendMode);
begin
  _Gfx.Prim2D.PrimBegin(PrimType, BlendMode);
end;

procedure TG2Core.PrimEnd;
begin
  _Gfx.Prim2D.PrimEnd;
end;

procedure TG2Core.PrimAdd(const x, y: TG2Float; const Color: TG2Color);
begin
  _Gfx.Prim2D.PrimAdd(x, y, Color);
end;

procedure TG2Core.PrimAdd(const Pos: TG2Vec2; const Color: TG2Color);
begin
  _Gfx.Prim2D.PrimAdd(Pos.x, Pos.y, Color);
end;

procedure TG2Core.PrimLineCol(const Pos0, Pos1: TG2Vec2; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimEnd;
end;

procedure TG2Core.PrimLineCol(const x0, y0, x1, y1: TG2Float; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimEnd;
end;

procedure TG2Core.PrimLine(const Pos0, Pos1: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col);
  PrimAdd(Pos1, Col);
  PrimEnd;
end;

procedure TG2Core.PrimLine(const x0, y0, x1, y1: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col);
  PrimAdd(x1, y1, Col);
  PrimEnd;
end;

procedure TG2Core.PrimTriCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimEnd;
end;

procedure TG2Core.PrimTriCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimEnd;
end;

procedure TG2Core.PrimQuadCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos3, Col3);
  PrimEnd;
end;

procedure TG2Core.PrimQuadCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x3, y3, Col3);
  PrimEnd;
end;

procedure TG2Core.PrimQuad(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos0, Col);
  PrimAdd(Pos1, Col);
  PrimAdd(Pos2, Col);
  PrimAdd(Pos2, Col);
  PrimAdd(Pos1, Col);
  PrimAdd(Pos3, Col);
  PrimEnd;
end;

procedure TG2Core.PrimQuad(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x0, y0, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x2, y2, Col);
  PrimAdd(x2, y2, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x3, y3, Col);
  PrimEnd;
end;

procedure TG2Core.PrimRectCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x, y, Col0);
  PrimAdd(x1, y, Col1);
  PrimAdd(x, y1, Col2);
  PrimAdd(x, y1, Col2);
  PrimAdd(x1, y, Col1);
  PrimAdd(x1, y1, Col3);
  PrimEnd;
end;

procedure TG2Core.PrimRect(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x, y, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x1, y1, Col);
  PrimEnd;
end;

procedure TG2Core.PrimRectHollowCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x, y, Col0);
  PrimAdd(x1, y, Col1);
  PrimAdd(x1, y, Col1);
  PrimAdd(x1, y1, Col3);
  PrimAdd(x1, y1, Col3);
  PrimAdd(x, y1, Col2);
  PrimAdd(x, y1, Col2);
  PrimAdd(x, y, Col0);
  PrimEnd;
end;

procedure TG2Core.PrimRectHollow(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x, y, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x, y, Col);
  PrimEnd;
end;

procedure TG2Core.PrimCircleCol(const Pos: TG2Vec2; const Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c: TG2Float;
  var v, v2: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos, Col0);
  PrimAdd(v + Pos, Col1);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    v2 := v + Pos;
    PrimAdd(v2, Col1);
    PrimAdd(Pos, Col0);
    PrimAdd(v2, Col1);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  PrimAdd(v + Pos, Col1);
  PrimEnd;
end;

procedure TG2Core.PrimCircleCol(const x, y, Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c, cx, cy: TG2Float;
  var v: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x, y, Col0);
  PrimAdd(v.x + x, v.y + y, Col1);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    cx := v.x + x; cy := v.y + y;
    PrimAdd(cx, cy, Col1);
    PrimAdd(x, y, Col0);
    PrimAdd(cx, cy, Col1);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  PrimAdd(v.x + x, v.y + y, Col1);
  PrimEnd;
end;

procedure TG2Core.PrimTriHollowCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos0, Col0);
  PrimEnd;
end;

procedure TG2Core.PrimTriHollowCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x0, y0, Col0);
  PrimEnd;
end;

procedure TG2Core.PrimQuadHollowCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos3, Col3);
  PrimAdd(Pos3, Col3);
  PrimAdd(Pos0, Col0);
  PrimEnd;
end;

procedure TG2Core.PrimQuadHollowCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x3, y3, Col3);
  PrimAdd(x3, y3, Col3);
  PrimAdd(x0, y0, Col0);
  PrimEnd;
end;

procedure TG2Core.PrimCircleHollow(const Pos: TG2Vec2; const Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c: TG2Float;
  var v, v2: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  PrimBegin(ptLines, BlendMode);
  PrimAdd(v + Pos, Col);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    v2 := v + Pos;
    PrimAdd(v2, Col);
    PrimAdd(v2, Col);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  PrimAdd(v + Pos, Col);
  PrimEnd;
end;

procedure TG2Core.PrimCircleHollow(const x, y, Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c, cx, cy: TG2Float;
  var v: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  PrimBegin(ptLines, BlendMode);
  PrimAdd(v.x + x, v.y + y, Col);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    cx := v.x + x; cy := v.y + y;
    PrimAdd(cx, cy, Col);
    PrimAdd(cx, cy, Col);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  PrimAdd(v.x + x, v.y + y, Col);
  PrimEnd;
end;

constructor TG2Core.Create;
begin
  inherited Create;
  {$if defined(G2Target_Windows)}
  _Platform := tpWindows;
  {$elseif defined(G2Target_Linux)}
  _Platform := tpLinux;
  {$elseif defined(G2Target_OSX)}
  _Platform := tpMacOSX;
  {$elseif defined(G2Target_Android)}
  _Platform := tpAndroid;
  G2DataManagerChachedRead := True;
  {$elseif defined(G2Target_iOS)}
  _Platform := tpiOS;
  _PoolInitialized := False;
  {$endif}
  _AppPath := GetAppPath;
  _Started := False;
  _Window := nil;
  _Params := TG2Params.Create;
  _Sys := TG2Sys.Create;
  {$if defined(G2Gfx_D3D9)}
  _Gfx := TG2GfxD3D9.Create;
  {$elseif defined(G2Gfx_OGL)}
  _Gfx := TG2GfxOGL.Create;
  {$elseif defined(G2Gfx_GLES)}
  _Gfx := TG2GfxGLES.Create;
  {$endif}
  {$if defined(G2Snd_DS)}
  _Snd := TG2SndDS.Create;
  {$elseif defined(G2Snd_OAL)}
  _Snd := TG2SndOAL.Create;
  {$elseif defined(G2Snd_OSL)}
  _Snd := TG2SndOSL.Create;
  {$endif}
  _PackLinker := TG2PackLinker.Create;
  G2PackLinker := _PackLinker;
  _MgrGeneral := nil;
  _FPS := 0;
  _LinkInitializeCount := 0;
  _LinkFinalizeCount := 0;
  _LinkUpdateCount := 0;
  _LinkRenderCount := 0;
  _LinkKeyDownCount := 0;
  _LinkKeyUpCount := 0;
  _LinkMouseDownCount := 0;
  _LinkMouseUpCount := 0;
  _ShowCursor := True;
  {$if defined(G2Target_Android) or defined(G2Target_iOS)}
  _CursorPos := Point(0, 0);
  {$endif}
end;

destructor TG2Core.Destroy;
begin
  if _Started then Stop;
  if _MgrGeneral <> nil then _MgrGeneral.Free;
  _PackLinker.Free;
  G2PackLinker := nil;
  _Snd.Free;
  _Gfx.Free;
  _Sys.Free;
  _Sys := nil;
  _Params.Free;
  _Params := nil;
  inherited Destroy;
end;
//TG2Core END

//TG2Window BEGIN
procedure TG2Window.AddMessage(const MessageProc: TG2ProcWndMessage; const Param1, Param2, Param3: TG2IntS32);
begin
  if _MessageCount >= Length(_MessageStack) then
  SetLength(_MessageStack, _MessageCount + 32);
  _MessageStack[_MessageCount].MessageProc := MessageProc;
  _MessageStack[_MessageCount].Param1 := Param1;
  _MessageStack[_MessageCount].Param2 := Param2;
  _MessageStack[_MessageCount].Param3 := Param3;
  Inc(_MessageCount);
end;

procedure TG2Window.ProcessMessages;
  var i: TG2IntS32;
begin
  if _MessageCount > 0 then
  begin
    for i := 0 to _MessageCount - 1 do
    _MessageStack[i].MessageProc(_MessageStack[i].Param1, _MessageStack[i].Param2, _MessageStack[i].Param3);
    _MessageCount := 0;
  end;
end;

{$Hints off}
procedure TG2Window.OnPrint(const Key, Param2, Param3: TG2IntS32);
begin
  g2.OnPrint(AnsiChar(PG2IntU8Arr(@Key)^[0]));
end;

procedure TG2Window.OnKeyDown(const Key, Param2, Param3: TG2IntS32);
begin
  g2.OnKeyDown(KeyRemap(Key));
end;

procedure TG2Window.OnKeyUp(const Key, Param2, Param3: TG2IntS32);
begin
  g2.OnKeyUp(KeyRemap(Key));
end;

procedure TG2Window.OnMouseDown(const Button, x, y: TG2IntS32);
begin
  g2.OnMouseDown(Button, x, y);
end;

procedure TG2Window.OnMouseUp(const Button, x, y: TG2IntS32);
begin
  g2.OnMouseUp(Button, x, y);
end;

procedure TG2Window.OnScroll(const y, Param2, Param3: TG2IntS32);
begin
  g2.OnScroll(y);
end;
{$Hints on}

procedure TG2Window.Stop;
begin
  {$if defined(G2Target_iOS)}
  if _Loop then
  begin
    _Loop := False;
    g2.OnStop;
  end;
  {$else}
  _Loop := False;
  {$endif}
end;

procedure TG2Window.SetCaption(const Value: AnsiString);
begin
  if _Caption <> Value then
  begin
    _Caption := Value;
    {$if defined(G2Target_Windows)}
    SetWindowTextA(_Handle, PAnsiChar(_Caption));
    {$elseif defined(G2Target_Linux)}
    XStoreName(_Display, _Handle, PAnsiChar(_Caption));
    {$elseif defined(G2Target_OSX)}
    SetWindowTitleWithCFString(
      _Handle, CFStringCreateWithPascalString(nil, _Caption, kCFStringEncodingASCII)
    );
    {$endif}
  end;
end;

procedure TG2Window.SetCursor(const Value: TG2Cursor);
begin
  if _Cursor <> Value then
  begin
    _Cursor := Value;
    {$if defined(G2Target_Windows)}
    Windows.SetCursor(_Cursor);
    {$endif}
  end;
end;

{$Hints off}
procedure TG2Window.Loop;
{$if defined(G2Target_Windows)}
  var msg: TMsg;
{$elseif defined(G2Target_Linux)}
  var Event: TXEvent;
{$elseif defined(G2Target_OSX)}
  var EvMask: MacOSAll.EventMask;
  var Event: MacOSAll.EventRecord;
{$endif}
begin
  {$if defined(G2Target_iOS)}
  g2.OnUpdate;
  g2.OnRender;
  {$else}
  _Loop := True;
  {$if defined(G2Target_Windows)}
  FillChar(msg, SizeOf(msg), 0);
  while _Loop
  and (msg.message <> WM_QUIT)
  and (msg.message <> WM_DESTROY)
  and (msg.message <> WM_CLOSE) do
  begin
    if PeekMessage(msg, 0, 0, 0, PM_REMOVE) then
    begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end
    {$ifndef G2Threading}
    else
    begin
      g2.OnUpdate;
      g2.OnRender;
    end
    {$endif};
  end;
  ExitCode := 0;
  {$elseif defined(G2Target_Linux)}
  FillChar(Event, SizeOf(Event), 0);
  while _Loop
  and not (
    (Event._type = ClientMessage)
    and (Event.xclient.data.l[0] = _WMDelete)
  )do
  begin
    if XPending(_Display) > 0 then
    begin
      XNextEvent(_Display, @Event);
      G2MessageHandler(Event);
    end
    {$ifndef G2Threading}
    else
    begin
      g2.OnUpdate;
      g2.OnRender;
    end
    {$endif};
  end;
  {$elseif defined(G2Target_OSX)}
  EvMask := everyEvent;
  while _Loop do
  begin
    if GetNextEvent(EvMask, Event) then begin ; end
    {$ifndef G2Threading}
    else
    begin
      g2.OnUpdate;
      g2.OnRender;
    end
    {$endif};
  end;
  {$endif}
  g2.OnStop;
  {$endif}
end;
{$Hints on}

{$if defined(G2Target_Android)}
{$Hints off}
{$endif}
constructor TG2Window.Create(const Width: TG2IntS32 = 0; const Height: TG2IntS32 = 0; const NewCaption: AnsiString = 'Gen2MP');
{$if defined(G2Target_Windows)}
  var w, h: TG2IntS32;
  var R: TRect;
  var WndStyle: TG2IntU32;
{$elseif defined(G2Target_Linux)}
  type THints = record
    Flags: IntU32;
    Functions: IntU32;
    Decorations: IntU32;
    InputMode: IntS32;
    Status: IntU32;
  end;
  var w, h: IntS32;
  var WndParams: TXWindowChanges;
  var WndHints: THints;
  var WndProps: TAtom;
  var WndState: TAtom;
  var WndFullscreen: TAtom;
  var WndAbove: TAtom;
  var WndMaxV: TAtom;
  var WndMaxH: TAtom;
  var WndAttribs: TXSetWindowAttributes;
  var WndGetAttr: TXWindowAttributes;
  var WndValueMask: IntU32;
  var event: TXEvent;
  var VisualAttribs: array[0..17] of IntS32;
{$elseif defined(G2Target_OSX)}
  var w, h: IntS32;
  var R: MacOSAll.Rect;
  var WndAttribs: MacOSAll.WindowAttributes;
  var WndEvents: array[0..5] of MacOSAll.EventTypeSpec;
{$endif}
begin
  inherited Create;
  _Caption := NewCaption;
  _MessageCount := 0;
  {$if defined(G2Target_Windows)}
  _CursorArrow := LoadCursor(0, IDC_ARROW);
  _CursorText := LoadCursor(0, IDC_IBEAM);
  _CursorHand := LoadCursor(0, IDC_HAND);
  _CursorSizeNS := LoadCursor(0, IDC_SIZENS);
  _CursorSizeWE := LoadCursor(0, IDC_SIZEWE);
  case g2.Params.ScreenMode of
    smWindow:
    begin
      if Width < 128 then w := 128 else w := Width;
      if Height < 32 then h := 32 else h := Height;
      WndStyle := (
        WS_CAPTION or
        WS_POPUP or
        WS_VISIBLE or
        WS_EX_TOPMOST or
        WS_MINIMIZEBOX or
        WS_SYSMENU
      );
      R.Left := (GetSystemMetrics(SM_CXSCREEN) - w) div 2;
      R.Right := R.Left + w;
      R.Top := (GetSystemMetrics(SM_CYSCREEN) - h) div 2;
      R.Bottom := R.Top + h;
      AdjustWindowRect(R, WndStyle, False);
      _Handle := CreateWindowExA(
        0, PAnsiChar(G2WndClassName), PAnsiChar(Caption),
        WndStyle,
        R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top,
        0, 0, HInstance, nil
      );
    end;
    smMaximized:
    begin
      w := GetSystemMetrics(SM_CXMAXIMIZED);
      h := GetSystemMetrics(SM_CYMAXIMIZED);
      WndStyle := (
        WS_CAPTION or
        WS_POPUP or
        WS_VISIBLE or
        WS_EX_TOPMOST or
        WS_MINIMIZEBOX or
        WS_MAXIMIZEBOX or
        WS_MAXIMIZE or
        WS_SYSMENU
      );
      R.Left := 0;
      R.Right := w;
      R.Top := 0;
      R.Bottom := h;
      _Handle := CreateWindowExA(
        0, PAnsiChar(G2WndClassName), PAnsiChar(Caption),
        WndStyle,
        R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top,
        0, 0, HInstance, nil
      );
      GetClientRect(_Handle, R);
      g2.Params.Width := R.Right - R.Left;
      g2.Params.Height := R.Bottom - R.Top;
    end;
    smFullscreen:
    begin
      w := GetSystemMetrics(SM_CXSCREEN);
      h := GetSystemMetrics(SM_CYSCREEN);
      WndStyle := (
        WS_POPUP or
        WS_VISIBLE or
        WS_EX_TOPMOST
      );
      _Handle := CreateWindowExA(
        0, PAnsiChar(G2WndClassName), PAnsiChar(Caption),
        WndStyle,
        (GetSystemMetrics(SM_CXSCREEN) - w) div 2,
        (GetSystemMetrics(SM_CYSCREEN) - h) div 2,
        w, h, 0, 0, HInstance, nil
      );
      GetClientRect(_Handle, R);
      g2.Params.Width := R.Right - R.Left;
      g2.Params.Height := R.Bottom - R.Top;
    end;
  end;
  BringWindowToTop(_Handle);
  {$elseif defined(G2Target_Linux)}
  _Display := XOpenDisplay(nil);
  {$Hints off}
  FillChar(VisualAttribs, SizeOf(VisualAttribs), 0);
  {$Hints on}
  VisualAttribs[0] := GLX_RGBA; VisualAttribs[1] := 1;
  VisualAttribs[2] := GLX_RED_SIZE; VisualAttribs[3] := 8;
  VisualAttribs[4] := GLX_GREEN_SIZE; VisualAttribs[5] := 8;
  VisualAttribs[6] := GLX_BLUE_SIZE; VisualAttribs[7] := 8;
  VisualAttribs[8] := GLX_ALPHA_SIZE; VisualAttribs[9] := 8;
  VisualAttribs[10] := GLX_DEPTH_SIZE; VisualAttribs[11] := 24;
  VisualAttribs[12] := GLX_STENCIL_SIZE; VisualAttribs[13] := 8;
  VisualAttribs[14] := GLX_DOUBLEBUFFER; VisualAttribs[15] := 1;
  _VisualInfo := glXChooseVisual(_Display, 0, @VisualAttribs);
  {$Hints off}
  FillChar(WndAttribs, SizeOf(WndAttribs), 0);
  {$Hints on}
  WndAttribs.colormap := XCreateColormap(_Display, RootWindow(_Display, 0), _VisualInfo^.visual, AllocNone);
  WndAttribs.event_mask := (
    ExposureMask or
    StructureNotifyMask or
    FocusChangeMask or
    ButtonPressMask or
    ButtonReleaseMask or
    KeyPressMask or
    KeyReleaseMask or
    PointerMotionMask
  );
  WndValueMask := CWColormap or CWEventMask or CWOverrideRedirect or CWBorderPixel or CWBackPixel;
  case g2.Params.ScreenMode of
    smFullscreen:
    begin
      XGetWindowAttributes(_Display, DefaultRootWindow(display), @WndGetAttr);
      w := WndGetAttr.width;
      h := WndGetAttr.height;
      _Handle := XCreateWindow(
        _Display, RootWindow(_Display, 0), 0, 0, w, h,
        0, _VisualInfo^.depth, InputOutput,
        _VisualInfo^.visual, WndValueMask, @WndAttribs
      );
      XMapRaised(_Display, _Handle);
      {$Hints off}
      FillChar(WndHints, SizeOf(WndHints), 0);
      {$Hints on}
      WndHints.Decorations := 0;
      WndHints.Flags := 2;
      WndProps := XInternAtom(_Display, '_MOTIF_WM_HINTS', True);
      XChangeProperty(_Display, _Handle, WndProps, WndProps, 32, PropModeReplace, @WndHints, 5);
      WndParams.x := 0;
      WndParams.y := 0;
      XConfigureWindow(_Display, _Handle, CWX or CWY, @WndParams);

      WndState := XInternAtom(_Display, '_NET_WM_STATE', False);
      WndFullscreen := XInternAtom(_Display, '_NET_WM_STATE_FULLSCREEN', False);
      WndMaxH := XInternAtom(_Display, '_NET_WM_STATE_MAXIMIZED_HORZ', False);
      WndMaxV := XInternAtom(_Display, '_NET_WM_STATE_MAXIMIZED_VERT', False);

      FillChar(event, SizeOf(event), 0);
      event._type := ClientMessage;
      event.xclient.window := _Handle;
      event.xclient.message_type := WndState;
      event.xclient.format := 32;
      event.xclient.data.l[0] := 1;
      event.xclient.data.l[1] := WndFullscreen;
      event.xclient.data.l[2] := 0;

      XSendEvent(_Display, DefaultRootWindow(_Display), False, SubstructureNotifyMask, @event);

      XSync(_Display, False);
      Sleep(1000);
      XGetWindowAttributes(_Display, _Handle, @WndGetAttr);
      g2.Params.Width := WndGetAttr.width;
      g2.Params.Height := WndGetAttr.height;
    end;
    smMaximized:
    begin
      XGetWindowAttributes(_Display, DefaultRootWindow(display), @WndGetAttr);
      w := WndGetAttr.width;
      h := WndGetAttr.height;
      _Handle := XCreateWindow(
        _Display, RootWindow(_Display, 0), 0, 0, w, h,
        0, _VisualInfo^.depth, InputOutput,
        _VisualInfo^.visual, WndValueMask, @WndAttribs
      );
      XMapRaised(_Display, _Handle);
      WndParams.x := 0;
      WndParams.y := 0;
      XConfigureWindow(_Display, _Handle, CWX or CWY, @WndParams);

      WndState := XInternAtom(_Display, '_NET_WM_STATE', False);
      WndMaxH := XInternAtom(_Display, '_NET_WM_STATE_MAXIMIZED_HORZ', False);
      WndMaxV := XInternAtom(_Display, '_NET_WM_STATE_MAXIMIZED_VERT', False);

      FillChar(event, SizeOf(event), 0);
      event._type := ClientMessage;
      event.xclient.window := _Handle;
      event.xclient.message_type := WndState;
      event.xclient.format := 32;
      event.xclient.data.l[0] := 1;
      event.xclient.data.l[1] := WndMaxH;
      event.xclient.data.l[2] := WndMaxV;

      XSendEvent(_Display, DefaultRootWindow(_Display), False, SubstructureNotifyMask, @event);

      XSync(_Display, False);
      Sleep(1000);
      XGetWindowAttributes(_Display, _Handle, @WndGetAttr);
      g2.Params.Width := WndGetAttr.width;
      g2.Params.Height := WndGetAttr.height;
    end;
    smWindow:
    begin
      if Width < 128 then w := 128 else w := Width;
      if Height < 32 then h := 32 else h := Height;
      _Handle := XCreateWindow(
        _Display, RootWindow(_Display, 0), 0, 0, w, h,
        0, _VisualInfo^.depth, InputOutput,
        _VisualInfo^.visual, WndValueMask, @WndAttribs
      );
      XMapRaised(_Display, _Handle);
      WndParams.x := (XDisplayWidth(_Display, 0) - w) div 2;
      WndParams.y := (XDisplayHeight(_Display, 0) - h) div 2;
      XConfigureWindow(_Display, _Handle, CWX or CWY, @WndParams);
    end;
  end;
  _WMDelete := XInternAtom(_Display, 'WM_DELETE_WINDOW', False);
  XSetWMProtocols(_Display, _Handle, @_WMDelete, 1);
  XStoreName(_Display, _Handle, PAnsiChar(_Caption));
  XFlush(_Display);
  gdk_init_check(@argc, argv);
  {$elseif defined(G2Target_OSX)}
  case g2.Params.ScreenMode of
    smFullscreen:
    begin
      GetAvailableWindowPositioningBounds(GetMainDevice, R);
      //w := CGDisplayPixelsWide(kCGDirectMainDisplay);
      w := R.right - R.left;
      h := R.bottom - R.top;
      g2.Params.Width := w; g2.Params.Height := h;
      WndAttribs := (
        (
          kWindowStandardHandlerAttribute or
          kWindowNoTitleBarAttribute or
          kWindowNoShadowAttribute
        ) and not kWindowResizableAttribute
      );
      CreateNewWindow(kDocumentWindowClass, WndAttribs, R, _Handle);
    end;
    smMaximized:
    begin
      GetAvailableWindowPositioningBounds(GetMainDevice, R);
      w := R.right - R.left;
      h := R.bottom - R.top;
      g2.Params.Width := w; g2.Params.Height := h;
      WndAttribs := (
        (
          kWindowCloseBoxAttribute or
          kWindowCollapseBoxAttribute or
          kWindowStandardHandlerAttribute or
          kWindowNoShadowAttribute
        ) and not kWindowResizableAttribute
      );
      CreateNewWindow(kDocumentWindowClass, WndAttribs, R, _Handle);
    end;
    smWindow:
    begin
      if Width < 128 then w := 128 else w := Width;
      if Height < 32 then h := 32 else h := Height;
      g2.Params.Width := w; g2.Params.Height := h;
      R.left := (CGDisplayPixelsWide(kCGDirectMainDisplay) - w) div 2;
      R.top := (CGDisplayPixelsHigh(kCGDirectMainDisplay) - h) div 2;
      R.right := R.left + w;
      R.bottom := R.top + h;
      WndAttribs := (
        (
          kWindowCloseBoxAttribute or
          kWindowCollapseBoxAttribute or
          kWindowStandardHandlerAttribute
        ) and not kWindowResizableAttribute
      );
      CreateNewWindow(kDocumentWindowClass, WndAttribs, R, _Handle);
    end;
  end;
  SetWindowTitleWithCFString(
    _Handle, CFStringCreateWithPascalString(nil, _Caption, kCFStringEncodingASCII)
  );
  WndEvents[0].eventClass := kEventClassCommand;
  WndEvents[0].eventKind := kEventProcessCommand;
  WndEvents[1].eventClass := kEventClassWindow;
  WndEvents[1].eventKind := kEventWindowClosed;
  WndEvents[2].eventClass := kEventClassKeyboard;
  WndEvents[2].eventKind := kEventRawKeyDown;
  WndEvents[3].eventClass := kEventClassKeyboard;
  WndEvents[3].eventKind := kEventRawKeyUp;
  WndEvents[4].eventClass := kEventClassMouse;
  WndEvents[4].eventKind := kEventMouseDown;
  WndEvents[5].eventClass := kEventClassMouse;
  WndEvents[5].eventKind := kEventMouseUp;
  InstallEventHandler(GetApplicationEventTarget, EventHandlerUPP(@G2MessageHandler), 6, @WndEvents, nil, nil);
  ShowWindow(_Handle);
  SelectWindow(_Handle);
  {$elseif defined(G2Target_iOS)}
  _Loop := True;
  {$endif}
  _Cursor := 0;
  Cursor := _CursorArrow;
end;
{$if defined(G2Target_Android)}
{$Hints on}
{$endif}

destructor TG2Window.Destroy;
begin
  {$if defined(G2Target_Windows)}
  DestroyWindow(_Handle);
  {$elseif defined(G2Target_Linux)}
  XFree(_VisualInfo);
  XDestroyWindow(_Display, _Handle);
  XCloseDisplay(_Display);
  {$elseif defined(G2Target_OSX)}
  ReleaseWindow(_Handle);
  {$endif}
  inherited Destroy;
end;
//TG2Window END

//TG2Params BEGIN
constructor TG2Params.Create;
{$if defined(G2Target_Linux)}
  var Display: PXDisplay;
{$endif}
begin
  inherited Create;
  {$if defined(G2Target_Windows)}
  _ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  _ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  _Width := 800;
  _Height := 600;
  {$elseif defined(G2Target_Linux)}
  Display := XOpenDisplay(nil);
  _ScreenWidth := XDisplayWidth(Display, 0);
  _ScreenHeight := XDisplayHeight(Display, 0);
  XCloseDisplay(Display);
  _Width := 800;
  _Height := 600;
  {$elseif defined(G2Target_OSX)}
  _ScreenWidth := CGDisplayPixelsWide(kCGDirectMainDisplay);
  _ScreenHeight := CGDisplayPixelsHigh(kCGDirectMainDisplay);
  _Width := 800;
  _Height := 600;
  {$elseif defined(G2Target_iOS)}
  _ScreenWidth := Round(UIScreen.mainScreen.bounds.size.width);
  _ScreenHeight := Round(UIScreen.mainScreen.bounds.size.height);
  _Width := _ScreenWidth;
  _Height := _ScreenHeight;
  {$endif}
  _WidthRT := _Width;
  _HeightRT := _Height;
  _ScreenMode := smWindow;
  _TargetUPS := 50;
  _MaxFPS := 0;
end;

destructor TG2Params.Destroy;
begin
  inherited Destroy;
end;
//TG2Params END

//TG2Sys BEGIN
constructor TG2Sys.Create;
begin
  inherited Create;
end;

destructor TG2Sys.Destroy;
begin
  inherited Destroy;
end;
//TG2Sys END

//TG2Gfx BEGIN
{$if defined(G2RM_SM2)}
procedure TG2Gfx.AddShader(const Name: AnsiString; const Prog: Pointer; const ProgSize: TG2IntS32);
  var ShaderGroup: TG2ShaderGroup;
  var ShaderItem: PG2ShaderItem;
begin
  ShaderGroup := TG2ShaderGroup.Create;
  ShaderGroup.Load(Prog, ProgSize);
  New(ShaderItem);
  ShaderItem^.Name := Name;
  ShaderItem^.ShaderGroup := ShaderGroup;
  _Shaders.Add(ShaderItem);
end;

procedure TG2Gfx.InitShaders;
begin
  AddShader('StandardShaders', @G2Bin_StandardShaders, SizeOf(G2Bin_StandardShaders));
end;

procedure TG2Gfx.FreeShaders;
  var i: TG2IntS32;
begin
  for i := 0 to _Shaders.Count - 1 do
  begin
    PG2ShaderItem(_Shaders[i])^.ShaderGroup.Free;
    Dispose(PG2ShaderItem(_Shaders[i]));
  end;
  _Shaders.Clear;
end;
{$endif}

function TG2Gfx.AddRenderControl(const ControlClass: CG2RenderControl): TG2RenderControl;
begin
  Result := ControlClass.Create;
  _RenderControls.Add(Result);
end;

procedure TG2Gfx.ProcessRenderQueue;
  var CurRenderControl: TG2RenderControl;
  var i: TG2IntS32;
begin
  CurRenderControl := nil;
  for i := 0 to _RenderQueueCount[_QueueDraw] - 1 do
  begin
    if _RenderQueue[_QueueDraw][i].RenderControl <> CurRenderControl then
    begin
      if CurRenderControl <> nil then
      CurRenderControl.RenderEnd;
      CurRenderControl := _RenderQueue[_QueueDraw][i].RenderControl;
      CurRenderControl.RenderBegin;
    end;
    CurRenderControl.RenderData(_RenderQueue[_QueueDraw][i].RenderData);
  end;
  if CurRenderControl <> nil then
  CurRenderControl.RenderEnd;
end;

procedure TG2Gfx.Initialize;
begin
  {$if defined(G2RM_SM2)}
  InitShaders;
  {$endif}
  _ControlStateChange := TG2RenderControlStateChange(AddRenderControl(TG2RenderControlStateChange));
  _ControlBuffer := TG2RenderControlBuffer(AddRenderControl(TG2RenderControlBuffer));
  _ControlPic2D := TG2RenderControlPic2D(AddRenderControl(TG2RenderControlPic2D));
  _ControlPrim2D := TG2RenderControlPrim2D(AddRenderControl(TG2RenderControlPrim2D));
  _ControlPoly2D := TG2RenderControlPoly2D(AddRenderControl(TG2RenderControlPoly2D));
  _ControlManaged := TG2RenderControlManaged(AddRenderControl(TG2RenderControlManaged));
  _RenderTarget := nil;
  _ClearColor := $ff808080;
  _DepthEnable := False;
  _DepthWriteEnable := True;
  _BlendEnable := True;
  _BlendSeparate := False;
  BlendMode := bmNormal;
  Filter := tfPoint;
end;

procedure TG2Gfx.Finalize;
  var i: TG2IntS32;
begin
  for i := 0 to _RenderControls.Count - 1 do
  TG2RenderControl(_RenderControls[i]).Free;
  {$if defined(G2RM_SM2)}
  FreeShaders;
  {$endif}
end;

procedure TG2Gfx.Reset;
  var i: TG2IntS32;
begin
  _RenderQueueCount[_QueueFill] := 0;
  for i := 0 to _RenderControls.Count - 1 do
  TG2RenderControl(_RenderControls[i]).Reset;
end;

procedure TG2Gfx.Swap;
  var t: TG2IntS32;
begin
  _NeedToSwap := True;
  while not _CanSwap do;
  t := _QueueFill;
  _QueueFill := _QueueDraw;
  _QueueDraw := t;
  _NeedToSwap := False;
end;

procedure TG2Gfx.RenderStart;
begin
  while _NeedToSwap do;
  _CanSwap := False;
end;

procedure TG2Gfx.RenderStop;
begin
  _CanSwap := True;
end;

procedure TG2Gfx.AddRenderQueueItem(const Control: TG2RenderControl; const Data: Pointer);
begin
  if _RenderQueueCount[_QueueFill] >= _RenderQueueCapacity[_QueueFill] then
  begin
    _RenderQueueCapacity[_QueueFill] := _RenderQueueCapacity[_QueueFill] + 128;
    SetLength(_RenderQueue[_QueueFill], _RenderQueueCapacity[_QueueFill]);
  end;
  _RenderQueue[_QueueFill][_RenderQueueCount[_QueueFill]].RenderControl := Control;
  _RenderQueue[_QueueFill][_RenderQueueCount[_QueueFill]].RenderData := Data;
  Inc(_RenderQueueCount[_QueueFill]);
end;

{$if defined(G2RM_SM2)}
function TG2Gfx.RequestShader(const Name: AnsiString): TG2ShaderGroup;
  var i: TG2IntS32;
begin
  for i := 0 to _Shaders.Count - 1 do
  if PG2ShaderItem(_Shaders[i])^.Name = Name then
  begin
    Result := PG2ShaderItem(_Shaders[i])^.ShaderGroup;
    Exit;
  end;
  Result := nil;
end;
{$endif}

constructor TG2Gfx.Create;
begin
  _RenderControls.Clear;
  _RenderQueueCapacity[0] := 0;
  _RenderQueueCapacity[1] := 0;
  _RenderQueueCount[0] := 0;
  _RenderQueueCount[1] := 0;
  _QueueFill := 0;
  _QueueDraw := 1;
  _NeedToSwap := False;
  _CanSwap := True;
  inherited Create;
end;

destructor TG2Gfx.Destroy;
begin
  inherited Destroy;
end;
//TG2Gfx END

{$ifdef G2Gfx_D3D9}
//TG2GfxD3D9 BEGIN
procedure TG2GfxD3D9.SetRenderTarget(const Value: TG2Texture2DRT);
begin
  if _RenderTarget <> Value then
  begin
    _RenderTarget := Value;
    if _RenderTarget = nil then
    begin
      _Device.SetRenderTarget(0, _DefRenderTarget);
      SizeRT.x := g2.Params.Width;
      SizeRT.y := g2.Params.Height;
    end
    else
    begin
      _Device.SetRenderTarget(0, _RenderTarget._Surface);
      SizeRT.x := _RenderTarget.RealWidth;
      SizeRT.y := _RenderTarget.RealHeight;
    end;
  end;
end;

procedure TG2GfxD3D9.SetBlendMode(const Value: TG2BlendMode);
  var be: Boolean;
  var bs: Boolean absolute be;
  const BlendMap: array[0..10] of TG2IntU32 = (
    D3DBLEND_ZERO,
    D3DBLEND_ZERO,
    D3DBLEND_ONE,
    D3DBLEND_SRCCOLOR,
    D3DBLEND_INVSRCCOLOR,
    D3DBLEND_DESTCOLOR,
    D3DBLEND_INVDESTCOLOR,
    D3DBLEND_SRCALPHA,
    D3DBLEND_INVSRCALPHA,
    D3DBLEND_DESTALPHA,
    D3DBLEND_INVDESTALPHA
  );
begin
  if _BlendMode <> Value then
  begin
    _BlendMode := Value;
    be := _BlendMode.BlendEnable;
    if be <> _BlendEnable then
    begin
      _BlendEnable := be;
      if _BlendEnable then
      _Device.SetRenderState(D3DRS_ALPHABLENDENABLE, 1)
      else
      _Device.SetRenderState(D3DRS_ALPHABLENDENABLE, 0);
    end;
    bs := _BlendMode.BlendSeparate and _BlendEnable;
    if bs <> _BlendSeparate then
    begin
      _BlendSeparate := bs;
      if _BlendSeparate then
      _Device.SetRenderState(D3DRS_SEPARATEALPHABLENDENABLE, 1)
      else
      _Device.SetRenderState(D3DRS_SEPARATEALPHABLENDENABLE, 0);
    end;
    if _BlendEnable then
    begin
      _Device.SetRenderState(D3DRS_SRCBLEND, BlendMap[TG2IntU8(_BlendMode.ColorSrc)]);
      _Device.SetRenderState(D3DRS_DESTBLEND, BlendMap[TG2IntU8(_BlendMode.ColorDst)]);
      if _BlendSeparate then
      begin
        _Device.SetRenderState(D3DRS_SRCBLENDALPHA, BlendMap[TG2IntU8(_BlendMode.AlphaSrc)]);
        _Device.SetRenderState(D3DRS_DESTBLENDALPHA, BlendMap[TG2IntU8(_BlendMode.AlphaDst)]);
      end;
    end
    else
    begin
      _Device.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ONE);
      _Device.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ZERO);
    end;
  end;
end;

procedure TG2GfxD3D9.SetFilter(const Value: TG2Filter);
begin
  if _Filter <> Value then
  begin
    _Filter := Value;
    case _Filter of
      tfPoint:
      begin
        _Device.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_POINT);
        _Device.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
        _Device.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_POINT);
      end;
      tfLinear:
      begin
        _Device.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
        _Device.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
        _Device.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
      end;
    end;
  end;
end;

procedure TG2GfxD3D9.SetScissor(const Value: PRect);
begin
  if Value <> nil then
  begin
    _Device.SetRenderState(D3DRS_SCISSORTESTENABLE, 1);
    _Device.SetScissorRect(Value);
  end
  else
  _Device.SetRenderState(D3DRS_SCISSORTESTENABLE, 0);
end;

procedure TG2GfxD3D9.SetDepthEnable(const Value: Boolean);
begin
  if Value = _DepthEnable then Exit;
  _DepthEnable := Value;
  _Device.SetRenderState(D3DRS_ZENABLE, TG2IntU32(Value));
  if _DepthEnable then
  _Device.SetDepthStencilSurface(_DefDepthStencil)
  else
  _Device.SetDepthStencilSurface(nil);
end;

procedure TG2GfxD3D9.SetDepthWriteEnable(const Value: Boolean);
begin
  if Value = _DepthWriteEnable then Exit;
  _DepthWriteEnable := Value;
  _Device.SetRenderState(D3DRS_ZWRITEENABLE, TG2IntU32(Value));
end;

{$if defined(G2RM_SM2)}
procedure TG2GfxD3D9.SetShaderMethod(const Value: PG2ShaderMethod);
begin
  if Value = _ShaderMethod then Exit;
  _ShaderMethod := Value;
  if _ShaderMethod = nil then
  begin
    _Device.SetVertexShader(nil);
    _Device.SetPixelShader(nil);
  end
  else
  begin
    _Device.SetVertexShader(_ShaderMethod^.VertexShader^.Prog);
    _Device.SetPixelShader(_ShaderMethod^.PixelShader^.Prog);
  end;
end;
{$endif}

procedure TG2GfxD3D9.Initialize;
  var pp: TD3DPresentParameters;
begin
  ZeroMemory(@pp, SizeOf(pp));
  pp.BackBufferWidth := g2.Params.Width;
  pp.BackBufferHeight := g2.Params.Height;
  pp.BackBufferFormat := D3DFMT_X8R8G8B8;
  pp.BackBufferCount := 1;
  pp.MultiSampleType := D3DMULTISAMPLE_NONE;
  pp.SwapEffect := D3DSWAPEFFECT_DISCARD;
  pp.hDeviceWindow := g2.Window.Handle;
  pp.Windowed := True;
  pp.EnableAutoDepthStencil := False;
  pp.AutoDepthStencilFormat := D3DFMT_D16;
  pp.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  _D3D9.CreateDevice(
    0, D3DDEVTYPE_HAL,
    g2.Window.Handle,
    //D3DCREATE_SOFTWARE_VERTEXPROCESSING
    D3DCREATE_HARDWARE_VERTEXPROCESSING
    or D3DCREATE_MULTITHREADED,
    @pp,
    _Device
  );
  _Device.GetRenderTarget(0, _DefRenderTarget);
  _Device.CreateDepthStencilSurface(
    g2.Params.Width,
    g2.Params.Height,
    D3DFMT_D16,
    D3DMULTISAMPLE_NONE,
    0,
    True,
    _DefDepthStencil,
    nil
  );
  SizeRT.x := g2.Params.Width;
  SizeRT.y := g2.Params.Height;
  _Device.SetRenderState(D3DRS_NORMALIZENORMALS, 1);
  _Device.SetRenderState(D3DRS_LIGHTING, 0);
  _Device.SetRenderState(D3DRS_ALPHABLENDENABLE, 1);
  _Device.SetRenderState(D3DRS_BLENDOP, D3DBLENDOP_ADD);
  _Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  _Device.SetRenderState(D3DRS_SEPARATEALPHABLENDENABLE, 0);
  _Device.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
  _Device.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
  _Device.SetRenderState(D3DRS_SRCBLENDALPHA, D3DBLEND_ONE);
  _Device.SetRenderState(D3DRS_DESTBLENDALPHA, D3DBLEND_ONE);
  _Device.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
  _Device.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
  _Device.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
  _Device.SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_MODULATE);
  _Device.SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
  _Device.SetTextureStageState(0, D3DTSS_ALPHAARG2, D3DTA_TEXTURE);
  inherited Initialize;
end;

procedure TG2GfxD3D9.Finalize;
begin
  inherited Finalize;
  {$if defined(G2RM_SM2)}
  FreeShaders;
  {$endif}
  SafeRelease(_DefDepthStencil);
  SafeRelease(_DefRenderTarget);
  SafeRelease(_Device);
end;

procedure TG2GfxD3D9.Render;
begin
  Clear(ClearColor);
  _Device.BeginScene;
  ProcessRenderQueue;
  _Device.EndScene;
  _Device.Present(nil, nil, 0, nil);
end;

procedure TG2GfxD3D9.Clear(const Color: TG2Color);
  var Target: TG2IntU32;
begin
  if _DepthEnable then
  Target := D3DCLEAR_TARGET or D3DCLEAR_ZBUFFER
  else
  Target := D3DCLEAR_TARGET;
  _Device.Clear(0, nil, Target, TD3DColor(Color), 1, 0);
end;

constructor TG2GfxD3D9.Create;
begin
  inherited Create;
  _D3D9 := Direct3DCreate9(D3D_SDK_VERSION);
  _D3D9.GetDeviceCaps(0, D3DDEVTYPE_HAL, Caps);
end;

destructor TG2GfxD3D9.Destroy;
begin
  SafeRelease(_D3D9);
  inherited Destroy;
end;
//TG2GfxD3D9 END
{$endif}

{$ifdef G2Gfx_OGL}
//TG2GfxOGL BEGIN
procedure TG2GfxOGL.SetRenderTarget(const Value: TG2Texture2DRT);
  var RTMode: TG2TexRTMode;
begin
  if _RenderTarget <> Value then
  begin
    if (_RenderTarget <> nil) then
    begin
      RTMode := _RenderTarget._Mode;
      if RTMode = rtmFBO then
      begin
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
      end
      else if RTMode = rtmPBuffer then
      begin
        glBindTexture(GL_TEXTURE_2D, _RenderTarget._Texture);
        glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, _RenderTarget.RealWidth, _RenderTarget.RealHeight);
        {$ifdef G2Target_OSX}
        aglSwapBuffers(_RenderTarget._PBufferContext);
        {$endif}
      end;
    end
    else
    RTMode := rtmNone;
    _RenderTarget := Value;
    if _RenderTarget = nil then
    begin
      if RTMode = rtmFBO then
      SetDefaults
      else if RTMode = rtmPBuffer then
      {$if defined(G2Target_Windows)}
      wglMakeCurrent(_DC, _Context);
      {$elseif defined(G2Target_Linux)}
      glXMakeCurrent(g2.Window.Display, g2.Window.Handle, _Context);
      {$elseif defined(G2Target_OSX)}
      aglSetCurrentContext(_Context);
      {$endif}
      SizeRT.x := g2.Params.Width;
      SizeRT.y := g2.Params.Height;
    end
    else
    begin
      if _RenderTarget._Mode = rtmFBO then
      begin
        glBindFramebuffer(GL_FRAMEBUFFER, _RenderTarget._FrameBuffer);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _RenderTarget._Texture, 0);
        SetDefaults;
      end
      else if _RenderTarget._Mode = rtmPBuffer then
      begin
        {$if defined(G2Target_Windows)}
        wglMakeCurrent(_RenderTarget._PBufferDC, _RenderTarget._PBufferRC);
        {$elseif defined(G2Target_Linux)}
        glXMakeCurrent(g2.Window.Display, _RenderTarget._PBuffer, _RenderTarget._PBufferContext);
        {$elseif defined(G2Target_OSX)}
        aglSetCurrentContext(_RenderTarget._PBufferContext);
        aglSetPBuffer(_RenderTarget._PBufferContext, _RenderTarget._PBuffer, 0, 0, aglGetVirtualScreen(_Context));
        {$endif}
        SetDefaults;
      end;
      SizeRT.x := _RenderTarget.RealWidth;
      SizeRT.y := _RenderTarget.RealHeight;
    end;
  end;
end;

procedure TG2GfxOGL.SetBlendMode(const Value: TG2BlendMode);
  var be: Boolean;
  const BlendMap: array[0..10] of TGLEnum = (
    GL_ZERO,
    GL_ZERO,
    GL_ONE,
    GL_SRC_COLOR,
    GL_ONE_MINUS_SRC_COLOR,
    GL_DST_COLOR,
    GL_ONE_MINUS_DST_COLOR,
    GL_SRC_ALPHA,
    GL_ONE_MINUS_SRC_ALPHA,
    GL_DST_ALPHA,
    GL_ONE_MINUS_DST_ALPHA
  );
begin
  if _BlendMode <> Value then
  begin
    _BlendMode := Value;
    be := _BlendMode.BlendEnable;
    if be <> _BlendEnable then
    begin
      _BlendEnable := be;
      if _BlendEnable then
      glEnable(GL_BLEND)
      else
      glDisable(GL_BLEND);
    end;
    _BlendSeparate := _BlendMode.BlendSeparate and _BlendEnable;
    if _BlendEnable then
    begin
      if _BlendSeparate then
      glBlendFuncSeparate(
        BlendMap[TG2IntU8(_BlendMode.ColorSrc)], BlendMap[TG2IntU8(_BlendMode.ColorDst)],
        BlendMap[TG2IntU8(_BlendMode.AlphaSrc)], BlendMap[TG2IntU8(_BlendMode.AlphaDst)]
      )
      else
      glBlendFunc(BlendMap[TG2IntU8(_BlendMode.ColorSrc)], BlendMap[TG2IntU8(_BlendMode.ColorDst)]);
    end
    else
    glBlendFunc(GL_ONE, GL_ZERO);
  end;
end;

procedure TG2GfxOGL.SetFilter(const Value: TG2Filter);
begin
  _Filter := Value;
  if _Filter <> tfNone then
  begin
    case _Filter of
      tfPoint:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      end;
      tfLinear:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      end;
    end;
  end;
end;

procedure TG2GfxOGL.SetScissor(const Value: PRect);
begin
  if Value <> nil then
  begin
    glEnable(GL_SCISSOR_TEST);
    glScissor(Value^.Left, g2.Params.Height - Value^.Bottom, Value^.Right - Value^.Left, Value^.Bottom - Value^.Top);
  end
  else
  glDisable(GL_SCISSOR_TEST);
end;

procedure TG2GfxOGL.SetDepthEnable(const Value: Boolean);
begin
  if Value = _DepthEnable then Exit;
  _DepthEnable := Value;
  if _DepthEnable then
  glEnable(GL_DEPTH_TEST)
  else
  glDisable(GL_DEPTH_TEST);
end;

procedure TG2GfxOGL.SetDepthWriteEnable(const Value: Boolean);
begin
  if Value = _DepthWriteEnable then Exit;
  _DepthWriteEnable := Value;
  glDepthMask(_DepthWriteEnable);
end;

{$if defined(G2RM_SM2)}
procedure TG2GfxOGL.SetShaderMethod(const Value: PG2ShaderMethod);
begin
  if Value = _ShaderMethod then Exit;
  _ShaderMethod := Value;
  glUseProgram(_ShaderMethod^.ShaderProgram);
end;
{$endif}

procedure TG2GfxOGL.Initialize;
  {$if defined(G2Target_Windows)}
  var pfd: TPixelFormatDescriptor;
  var pf: TG2IntS32;
  {$elseif defined(G2Target_Linux)}
  {$elseif defined(G2Target_OSX)}
  var OglAttribs: array[0..5] of IntS32;
  var PixelFormat: TAGLPixelFormat;
  {$endif}
begin
  {$if defined(G2Target_Windows)}
  {$Hints off}
  FillChar(pfd, SizeOf(pfd), 0);
  {$Hints on}
  pfd.nSize := SizeOf(pfd);
  pfd.nVersion := 1;
  pfd.dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  pfd.iPixelType := PFD_TYPE_RGBA;
  pfd.cColorBits := 24;
  pfd.cAlphaBits := 8;
  pfd.cDepthBits := 16;
  pfd.iLayerType := PFD_MAIN_PLANE;
  _DC := GetDC(g2.Window.Handle);
  pf := ChoosePixelFormat(_DC, @pfd);
  SetPixelFormat(_DC, pf, @pfd);
  _Context := wglCreateContext(_DC);
  wglMakeCurrent(_DC, _Context);
  {$elseif defined(G2Target_Linux)}
  _Context := glXCreateContext(g2.Window.Display, g2.Window.VisualInfo, nil, True);
  glXMakeCurrent(g2.Window.Display, g2.Window.Handle, _Context);
  {$elseif defined(G2Target_OSX)}
  OglAttribs[0] := AGL_RGBA;
  OglAttribs[1] := AGL_DOUBLEBUFFER;
  OglAttribs[2] := AGL_NO_RECOVERY;
  OglAttribs[3] := AGL_DEPTH_SIZE; OglAttribs[4] := 16;
  OglAttribs[5] := AGL_NONE;
  PixelFormat := aglChoosePixelFormat(nil, 0, @OglAttribs);
  _Context := aglCreateContext(PixelFormat, nil);
  aglDestroyPixelFormat(PixelFormat);
  aglSetWindowRef(_Context, g2.Window.Handle);
  aglSetCurrentContext(_Context);
  {$endif}
  InitOpenGL;
  SetDefaults;
  SizeRT.x := g2.Params.Width;
  SizeRT.y := g2.Params.Height;
  inherited Initialize;
end;

procedure TG2GfxOGL.Finalize;
begin
  UnInitOpenGL;
  {$if defined(G2Target_Windows)}
  wglMakeCurrent(_DC, _Context);
  wglDeleteContext(_Context);
  ReleaseDC(g2.Window.Handle, _DC);
  {$elseif defined(G2Target_Linux)}
  glXDestroyContext(g2.Window.Display, _Context);
  {$elseif defined(G2Target_OSX)}
  aglDestroyContext(_Context);
  {$endif}
end;

procedure TG2GfxOGL.Render;
begin
  Clear(ClearColor);
  ProcessRenderQueue;
  {$if defined(G2Target_Windows)}
  SwapBuffers(_DC);
  {$elseif defined(G2Target_Linux)}
  glXSwapBuffers(g2.Window.Display, g2.Window.Handle);
  {$elseif defined(G2Target_OSX)}
  aglSwapBuffers(_Context);
  {$endif}
end;

procedure TG2GfxOGL.Clear(const Color: TG2Color);
begin
  glClearColor(Color.r * Rcp255, Color.g * Rcp255, Color.b * Rcp255, Color.a * Rcp255);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;

procedure TG2GfxOGL.SetProj2D;
  var m: TG2Mat;
begin
  glMatrixMode(GL_PROJECTION);
  if _RenderTarget = nil then
  m := G2MatOrth2D(g2.Params.Width, g2.Params.Height, 0, 1)
  else
  m := G2MatOrth2D(_RenderTarget.RealWidth, _RenderTarget.RealHeight, 0, 1, False, False);
  glLoadMatrixf(@m);
end;

procedure TG2GfxOGL.SetDefaults;
begin
  if _RenderTarget = nil then
  glViewport(0, 0, g2.Params.Width, g2.Params.Height)
  else
  glViewport(0, 0, _RenderTarget.RealWidth, _RenderTarget.RealHeight);
  glClearColor(0.5, 0.5, 0.5, 1);
  glClearDepth(1);
  glEnable(GL_TEXTURE_2D);
  glShadeModel(GL_SMOOTH);
  glCullFace(GL_FRONT);
  glDisable(GL_CULL_FACE);
  _BlendSeparate := False;
  _BlendEnable := False;
  glDisable(GL_BLEND);
  _BlendMode := bmInvalid;
  BlendMode := bmNormal;
end;

constructor TG2GfxOGL.Create;
begin
  inherited Create;
end;

destructor TG2GfxOGL.Destroy;
begin
  inherited Destroy;
end;
//TG2GfxOGL END
{$endif}

{$ifdef G2Gfx_GLES}
//TG2GfxGLES BEGIN
procedure TG2GfxGLES.SetRenderTarget(const Value: TG2Texture2DRT);
begin
  if _RenderTarget <> Value then
  begin
    if (_RenderTarget <> nil) then
    begin
      glFramebufferTexture2D(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, 0, 0);
      glBindFramebuffer(GL_FRAMEBUFFER_OES, 0);
    end;
    _RenderTarget := Value;
    if _RenderTarget = nil then
    begin
      SetDefaults;
    end
    else
    begin
      glBindFramebuffer(GL_FRAMEBUFFER_OES, _RenderTarget._FrameBuffer);
      glFramebufferTexture2D(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _RenderTarget._Texture, 0);
      SetDefaults;
    end;
  end;
end;

procedure TG2GfxGLES.SetBlendMode(const Value: TG2BlendMode);
  var be: Boolean;
  const BlendMap: array[0..10] of TGLEnum = (
    GL_ZERO,
    GL_ZERO,
    GL_ONE,
    GL_SRC_COLOR,
    GL_ONE_MINUS_SRC_COLOR,
    GL_DST_COLOR,
    GL_ONE_MINUS_DST_COLOR,
    GL_SRC_ALPHA,
    GL_ONE_MINUS_SRC_ALPHA,
    GL_DST_ALPHA,
    GL_ONE_MINUS_DST_ALPHA
  );
begin
  if _BlendMode <> Value then
  begin
    _BlendMode := Value;
    be := _BlendMode.BlendEnable;
    if be <> _BlendEnable then
    begin
      _BlendEnable := be;
      if _BlendEnable then
      glEnable(GL_BLEND)
      else
      glDisable(GL_BLEND);
    end;
    _BlendSeparate := _BlendMode.BlendSeparate and _BlendEnable;
    if _BlendEnable then
    begin
      {if _BlendSeparate then
      glBlendFuncSeparate(
        BlendMap[IntU8(_BlendMode.ColorSrc)], BlendMap[IntU8(_BlendMode.ColorDst)],
        BlendMap[IntU8(_BlendMode.AlphaSrc)], BlendMap[IntU8(_BlendMode.AlphaDst)]
      )
      else}
      glBlendFunc(BlendMap[TG2IntU8(_BlendMode.ColorSrc)], BlendMap[TG2IntU8(_BlendMode.ColorDst)]);
    end
    else
    glBlendFunc(GL_ONE, GL_ZERO);
  end;
end;

procedure TG2GfxGLES.SetFilter(const Value: TG2Filter);
begin
  _Filter := Value;
  if _Filter <> tfNone then
  begin
    case _Filter of
      tfPoint:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      end;
      tfLinear:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      end;
    end;
  end;
end;

procedure TG2GfxGLES.SetScissor(const Value: PRect);
begin
  if Value <> nil then
  begin
    glEnable(GL_SCISSOR_TEST);
    glScissor(Value^.Left, g2.Params.Height - Value^.Bottom, Value^.Right - Value^.Left, Value^.Bottom - Value^.Top);
  end
  else
  glDisable(GL_SCISSOR_TEST);
end;

procedure TG2GfxGLES.SetDepthEnable(const Value: Boolean);
begin
  if Value = _DepthEnable then Exit;
  _DepthEnable := Value;
  if _DepthEnable then
  glEnable(GL_DEPTH_TEST)
  else
  glDisable(GL_DEPTH_TEST);
end;

procedure TG2GfxGLES.SetDepthWriteEnable(const Value: Boolean);
begin
  if Value = _DepthWriteEnable then Exit;
  _DepthWriteEnable := Value;
  glDepthMask(_DepthWriteEnable);
end;

procedure TG2GfxGLES.Initialize;
  {$if defined(G2Target_iOS)}
  var FrameBuffer: GLUInt;
  {$endif}
begin
  {$if defined(G2Target_Android)}
  InitOpenGLES;
  {$elseid defined(G2Target_iOS)}
  _EAGLLayer := CAEAGLLayer(g2.Delegate.View.layer);
  _EAGLLayer.setOpaque(True);
  _EAGLLayer.setDrawableProperties(
    NSDictionary.dictionaryWithObjectsAndKeys(
      NSNumber.numberWithBool(False),
      G2NSStr('kEAGLDrawablePropertyRetainedBacking'),
      G2NSStr('kEAGLColorFormatRGBA8'),
      G2NSStr('kEAGLDrawablePropertyColorFormat'),
      nil
    )
  );
  _Context := EAGLContext.alloc.initWithAPI(kEAGLRenderingAPIOpenGLES1);
  EAGLContext.setCurrentContext(_Context);
  glGenRenderbuffers(1, @_RenderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _RenderBuffer);
  _Context.renderbufferStorage_fromDrawable(GL_RENDERBUFFER, _EAGLLayer);
  glGenFramebuffers(1, @FrameBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, FrameBuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _RenderBuffer);
  {$endif}
  SetDefaults;
  inherited Initialize;
end;

procedure TG2GfxGLES.Finalize;
begin
  {$if defined(G2Target_iOS)}

  {$elseif defined(G2Target_Android)}
  UnInitOpenGLES;
  {$endif}
end;

procedure TG2GfxGLES.Render;
begin
  Clear(ClearColor);
  ProcessRenderQueue;
  {$if defined(G2Target_iOS)}
  _Context.presentRenderbuffer(GL_RENDERBUFFER);
  {$endif}
end;

procedure TG2GfxGLES.Clear(const Color: TG2Color);
begin
  glClearColor(Color.r * Rcp255, Color.g * Rcp255, Color.b * Rcp255, Color.a * Rcp255);
  glClear(GL_DEPTH_BUFFER_BIT or GL_COLOR_BUFFER_BIT);
end;

procedure TG2GfxGLES.SetProj2D;
  var m: TG2Mat;
begin
  glMatrixMode(GL_PROJECTION);
  if _RenderTarget = nil then
  m := G2MatOrth2D(g2.Params.Width, g2.Params.Height, 0, 1)
  else
  m := G2MatOrth2D(_RenderTarget.RealWidth, _RenderTarget.RealHeight, 0, 1, False, False);
  glLoadMatrixf(@m);
end;

procedure TG2GfxGLES.SetDefaults;
begin
  if _RenderTarget = nil then
  glViewport(0, 0, g2.Params.Width, g2.Params.Height)
  else
  glViewport(0, 0, _RenderTarget.RealWidth, _RenderTarget.RealHeight);
  glClearColor(0.5, 0.5, 0.5, 1);
  glClearDepthf(1);
  glEnable(GL_TEXTURE_2D);
  glShadeModel(GL_SMOOTH);
  glCullFace(GL_FRONT);
  glDisable(GL_CULL_FACE);
  _BlendSeparate := False;
  _BlendEnable := False;
  glEnable(GL_BLEND);
  _BlendMode := bmInvalid;
  BlendMode := bmNormal;
end;

procedure TG2GfxGLES.SwapBlendMode;
  var bm: TG2BlendMode;
begin
  bm := _BlendMode;
  bm.SwapColorAlpha;
  BlendMode := bm;
end;

procedure TG2GfxGLES.MaskAll;
begin
  glColorMask(True, True, True, True);
end;

procedure TG2GfxGLES.MaskColor;
begin
  glColorMask(True, True, True, False);
end;

procedure TG2GfxGLES.MaskAlpha;
begin
  glColorMask(False, False, False, True);
end;

constructor TG2GfxGLES.Create;
begin
  inherited Create;
end;

destructor TG2GfxGLES.Destroy;
begin
  inherited Destroy;
end;
//TG2GfxGLES END
{$endif}

//TG2Snd BEGIN
constructor TG2Snd.Create;
begin
  inherited Create;
end;

destructor TG2Snd.Destroy;
begin
  inherited Destroy;
end;
//TG2Snd END

{$ifdef G2Snd_OAL}
//TG2SndOAL BEGIN
procedure TG2SndOAL.SetListenerPos(const Value: TG2Vec3);
  var v: TG2Vec3;
begin
  _ListenerPos := Value;
  v.x := _ListenerPos.x; v.y := _ListenerPos.y; v.z := -_ListenerPos.z;
  alListenerfv(AL_POSITION, @v);
end;

procedure TG2SndOAL.SetListenerVel(const Value: TG2Vec3);
  var v: TG2Vec3;
begin
  _ListenerVel := Value;
  v.x := _ListenerVel.x; v.y := _ListenerVel.y; v.z := -_ListenerVel.z;
  AlListenerfv(AL_VELOCITY, @v);
end;

procedure TG2SndOAL.SetListenerDir(const Value: TG2Vec3);
  var Orientation: array[0..5] of TG2Float;
begin
  _ListenerDir := Value;
  Orientation[0] := _ListenerDir.x;
  Orientation[1] := _ListenerDir.y;
  Orientation[2] := -_ListenerDir.z;
  Orientation[3] := _ListenerUp.x;
  Orientation[4] := _ListenerUp.y;
  Orientation[5] := -_ListenerUp.z;
  AlListenerfv(AL_ORIENTATION, @Orientation);
end;

procedure TG2SndOAL.SetListenerUp(const Value: TG2Vec3);
  var Orientation: array[0..5] of TG2Float;
begin
  _ListenerUp := Value;
  Orientation[0] := _ListenerDir.x;
  Orientation[1] := _ListenerDir.y;
  Orientation[2] := -_ListenerDir.z;
  Orientation[3] := _ListenerUp.x;
  Orientation[4] := _ListenerUp.y;
  Orientation[5] := -_ListenerUp.z;
  AlListenerfv(AL_ORIENTATION, @Orientation);
end;

procedure TG2SndOAL.Initialize;
begin
  _Device := alcOpenDevice(nil);
  _Context := alcCreateContext(_Device, nil);
  alcMakeContextCurrent(_Context);
  ListenerPos := G2Vec3(0, 0, 0);
  ListenerVel := G2Vec3(0, 0, 0);
  ListenerDir := G2Vec3(0, 0, 1);
  ListenerUp := G2Vec3(0, 1, 0);
end;

procedure TG2SndOAL.Finalize;
begin
  alcMakeContextCurrent(nil);
  alcDestroyContext(_Context);
  alcCloseDevice(_Device);
end;
//TG2SndOAL END
{$endif}

{$ifdef G2Snd_DS}
//TG2SndDS BEGIN
procedure TG2SndDS.SetListenerPos(const Value: TG2Vec3);
begin
  _ListenerPos := Value;
  _Listener.SetPosition(_ListenerPos.x, _ListenerPos.y, _ListenerPos.z, DS3D_IMMEDIATE);
end;

procedure TG2SndDS.SetListenerVel(const Value: TG2Vec3);
begin
  _ListenerVel := Value;
  _Listener.SetVelocity(_ListenerVel.x, _ListenerVel.y, _ListenerVel.z, DS3D_IMMEDIATE);
end;

procedure TG2SndDS.SetListenerDir(const Value: TG2Vec3);
begin
  _ListenerDir := Value;
  _Listener.SetOrientation(_ListenerDir.x, _ListenerDir.y, _ListenerDir.z, _ListenerUp.x, _ListenerUp.y, _ListenerUp.z, DS3D_IMMEDIATE);
end;

procedure TG2SndDS.SetListenerUp(const Value: TG2Vec3);
begin
  _ListenerUp := Value;
  _Listener.SetOrientation(_ListenerDir.x, _ListenerDir.y, _ListenerDir.z, _ListenerUp.x, _ListenerUp.y, _ListenerUp.z, DS3D_IMMEDIATE);
end;

procedure TG2SndDS.Initialize;
  var PrimaryBuffer: IDirectSoundBuffer;
  var Desc: TDSBufferDesc;
begin
  CoInitialize(nil);
  DirectSoundCreate8(nil, _Device, nil);
  {$Hints off}
  FillChar(Desc, SizeOf(Desc), 0);
  {$Hints on}
  Desc.dwSize := SizeOf(Desc);
  Desc.dwFlags := DSBCAPS_CTRL3D or DSBCAPS_PRIMARYBUFFER;
  _Device.CreateSoundBuffer(Desc, PrimaryBuffer, nil);
  PrimaryBuffer.QueryInterface(IID_IDirectSound3DListener8, _Listener);
  _Device.SetCooperativeLevel(g2.Window.Handle, DSSCL_NORMAL);
  ListenerPos := G2Vec3(0, 0, 0);
  ListenerVel := G2Vec3(0, 0, 0);
  ListenerDir := G2Vec3(0, 0, 1);
  ListenerUp := G2Vec3(0, 1, 0);
  SafeRelease(PrimaryBuffer);
end;

procedure TG2SndDS.Finalize;
begin
  SafeRelease(_Listener);
  SafeRelease(_Device);
  CoUninitialize;
end;
//TG2SndDS END
{$endif}

{$ifdef G2Threading}
//TG2Updater BEGIN
procedure TG2Updater.Execute;
begin
  while not Terminated do
  begin
    g2.OnUpdate;
  end;
end;
//TG2Updater END

//TG2Renderer BEGIN
procedure TG2Renderer.Execute;
begin
  while not Terminated do
  begin
    g2.OnRender;
  end;
end;
//TG2Renderer END
{$endif}

//TG2Res BEGIN
function TG2Res.GetMgr: TG2Mgr;
begin
  if g2._MgrGeneral = nil then
  g2._MgrGeneral := TG2Mgr.Create;
  Result := g2._MgrGeneral;
end;

constructor TG2Res.Create;
begin
  inherited Create;
  _Mgr := GetMgr;
  _Mgr.ItemAdd(Self);
  Initialize;
end;

destructor TG2Res.Destroy;
begin
  Finalize;
  _Mgr.ItemRemove(Self);
  inherited Destroy;
end;
//TG2Res END

//TG2Mgr BEGIN
procedure TG2Mgr.FreeItems;
begin
  while _Items.Count > 0 do
  TG2Res(_Items[0]).Free;
end;

procedure TG2Mgr.ItemAdd(const Item: TG2Res);
begin
  _Items.Add(Item);
end;

procedure TG2Mgr.ItemRemove(const Item: TG2Res);
begin
  _Items.Remove(Item);
end;

constructor TG2Mgr.Create;
begin
  inherited Create;
  _Items.Clear;
end;

destructor TG2Mgr.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;
//TG2Mgr END

//TG2TextureBase BEGIN
procedure TG2TextureBase.Release;
begin
  {$if defined(G2Gfx_D3D9)}
  SafeRelease(_Texture);
  {$else}
  if _Texture <> 0 then
  begin
    glDeleteTextures(1, @_Texture);
    _Texture := 0;
  end;
  {$endif}
end;

procedure TG2TextureBase.Initialize;
begin
  {$if defined(G2Gfx_D3D9)}
  _Gfx := TG2GfxD3D9(g2.Gfx);
  {$elseif defined(G2Gfx_OGL)}
  _Gfx := TG2GfxOGL(g2.Gfx);
  _Texture := 0;
  {$elseif defined(Gfx_GLES)}
  _Gfx := TG2GfxGLES(g2.Gfx);
  _Texture := 0;
  {$endif}
end;

procedure TG2TextureBase.Finalize;
begin
  Release;
end;

function TG2TextureBase.BaseTexture: {$ifdef G2Gfx_D3D9}IDirect3DBaseTexture9{$else}GLUInt{$endif};
begin
  Result := {$ifdef G2Gfx_D3D9}IDirect3DBaseTexture9(_Texture){$else}_Texture{$endif};
end;
//TG2TextureBase END

//TG2Texture2DBase BEGIN
function TG2Texture2DBase.GetTexture: {$ifdef G2Gfx_D3D9}IDirect3DTexture9{$else}GLUInt{$endif};
begin
  Result := {$ifdef G2Gfx_D3D9}IDirect3DTexture9(_Texture){$else}_Texture{$endif};
end;
//TG2Texture2DBase END

//TG2Texture2D BEGIN
function TG2Texture2D.Load(const FileName: FileString; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
  var Image: TG2Image;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2ImageFormats) do
  if G2ImageFormats[i].CanLoad(FileName) then
  begin
    Image := G2ImageFormats[i].Create;
    try
      Image.Load(FileName);
      Result := Load(Image, TextureUsage);
    finally
      Image.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2Texture2D.Load(const Stream: TStream; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
  var Image: TG2Image;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2ImageFormats) do
  if G2ImageFormats[i].CanLoad(Stream) then
  begin
    Image := G2ImageFormats[i].Create;
    try
      Image.Load(Stream);
      Result := Load(Image, TextureUsage);
    finally
      Image.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2Texture2D.Load(const Buffer: Pointer; const Size: TG2IntS32; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
  var Image: TG2Image;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2ImageFormats) do
  if G2ImageFormats[i].CanLoad(Buffer, Size) then
  begin
    Image := G2ImageFormats[i].Create;
    try
      Image.Load(Buffer, Size);
      Result := Load(Image, TextureUsage);
    finally
      Image.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2Texture2D.Load(const DataManager: TG2DataManager; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
  var Image: TG2Image;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2ImageFormats) do
  if G2ImageFormats[i].CanLoad(DataManager) then
  begin
    Image := G2ImageFormats[i].Create;
    try
      Image.Load(DataManager);
      Result := Load(Image, TextureUsage);
    finally
      Image.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2Texture2D.Load(const Image: TG2Image; const TextureUsage: TG2TextureUsage = tuDefault): Boolean;
  function MaxMipLevel(const w, h: TG2IntS32): TG2IntS32;
    var rw, rh, mipu, mipv: TG2IntS32;
  begin
    rw := 1;
    rh := 1;
    mipu := 1;
    mipv := 1;
    while rw < w do
    begin
      rw := rw shl 1;
      Inc(mipu);
    end;
    while rh < h do
    begin
      rh := rh shl 1;
      Inc(mipv);
    end;
    if mipu > mipv then Result := mipu else Result := mipv;
  end;
  {$ifdef G2Gfx_D3D9}
  var SurfLock, ParSurfLock: TD3DLockedRect;
  {$else}
  var TexData, MipData, Mip0, Mip1, Ptr: Pointer;
  var px, py, px4: TG2IntS32;
  var ds: TG2IntU32;
  {$endif}
  var op00, op01, op10, op11, oc: TG2IntS32;
  var i, j, x, y, l: TG2IntS32;
  var Levels: TG2IntU32;
begin
  Release;
  Result := False;
  _Usage := TextureUsage;
  if (Image.Width <= 0) or (Image.Height <= 0) or (Image.Data = nil) then Exit;
  _Width := Image.Width;
  _Height := Image.Height;
  _RealWidth := 1; while _RealWidth < _Width do _RealWidth := _RealWidth shl 1;
  _RealHeight := 1; while _RealHeight < _Height do _RealHeight := _RealHeight shl 1;
  {$if defined(G2Gfx_D3D9)}
  if _Usage = tuUsage3D then
  Levels := MaxMipLevel(_RealWidth, _RealHeight)
  else
  Levels := 1;
  _Gfx.Device.CreateTexture(
    _RealWidth, _RealHeight, Levels, 0,
    D3DFMT_A8R8G8B8, D3DPOOL_MANAGED,
    IDirect3DTexture9(_Texture), nil
  );
  GetTexture.LockRect(0, SurfLock, nil, D3DLOCK_DISCARD);
  case _Usage of
    tuDefault, tuUsage3D:
    begin
      for j := 0 to _RealHeight - 1 do
      for i := 0 to _RealWidth - 1 do
      begin
        x := Round((i / _RealWidth) * _Width);
        y := Round((j / _RealHeight) * _Height);
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 0)^ := Image.Pixels[x, y].b;
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 1)^ := Image.Pixels[x, y].g;
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 2)^ := Image.Pixels[x, y].r;
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 3)^ := Image.Pixels[x, y].a;
      end;
    end;
    tuUsage2D:
    begin
      for j := 0 to _Height - 1 do
      for i := 0 to _Width - 1 do
      begin
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 0)^ := Image.Pixels[i, j].b;
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 1)^ := Image.Pixels[i, j].g;
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 2)^ := Image.Pixels[i, j].r;
        PG2IntU8(SurfLock.pBits + j * SurfLock.Pitch + i * 4 + 3)^ := Image.Pixels[i, j].a;
      end;
    end;
  end;
  GetTexture.UnlockRect(0);
  if _Usage = tuUsage3D then
  begin
    x := _RealWidth div 2; if x < 1 then x := 1;
    y := _RealHeight div 2; if y < 1 then y := 1;
    for l := 1 to Levels - 1 do
    begin
      GetTexture.LockRect(l - 1, ParSurfLock, nil, D3DLOCK_READONLY);
      GetTexture.LockRect(l, SurfLock, nil, D3DLOCK_DISCARD);
      oc := 0;
      op00 := 0;
      op01 := op00 + ParSurfLock.Pitch;
      for j := 0 to y - 1 do
      begin
        op10 := op00 + 4;
        op11 := op01 + 4;
        for i := 0 to x - 1 do
        begin
          PG2IntU8(SurfLock.pBits + oc + 0)^ := (
            PG2IntU8(ParSurfLock.pBits + op00 + 0)^ +
            PG2IntU8(ParSurfLock.pBits + op10 + 0)^ +
            PG2IntU8(ParSurfLock.pBits + op01 + 0)^ +
            PG2IntU8(ParSurfLock.pBits + op11 + 0)^
          ) div 4;
          PG2IntU8(SurfLock.pBits + oc + 1)^ := (
            PG2IntU8(ParSurfLock.pBits + op00 + 1)^ +
            PG2IntU8(ParSurfLock.pBits + op10 + 1)^ +
            PG2IntU8(ParSurfLock.pBits + op01 + 1)^ +
            PG2IntU8(ParSurfLock.pBits + op11 + 1)^
          ) div 4;
          PG2IntU8(SurfLock.pBits + oc + 2)^ := (
            PG2IntU8(ParSurfLock.pBits + op00 + 2)^ +
            PG2IntU8(ParSurfLock.pBits + op10 + 2)^ +
            PG2IntU8(ParSurfLock.pBits + op01 + 2)^ +
            PG2IntU8(ParSurfLock.pBits + op11 + 2)^
          ) div 4;
          PG2IntU8(SurfLock.pBits + oc + 3)^ := (
            PG2IntU8(ParSurfLock.pBits + op00 + 3)^ +
            PG2IntU8(ParSurfLock.pBits + op10 + 3)^ +
            PG2IntU8(ParSurfLock.pBits + op01 + 3)^ +
            PG2IntU8(ParSurfLock.pBits + op11 + 3)^
          ) div 4;
          oc := oc + 4;
          op00 := op00 + 8;
          op01 := op01 + 8;
          op10 := op10 + 8;
          op11 := op11 + 8;
        end;
        op00 := op00 + ParSurfLock.Pitch;
        op01 := op01 + ParSurfLock.Pitch;
      end;
      x := x div 2; if x < 1 then x := 1;
      y := y div 2; if y < 1 then y := 1;
      GetTexture.UnlockRect(l);
      GetTexture.UnlockRect(l - 1);
    end;
  end;
  {$else}
  GetMem(TexData, _RealWidth * _RealHeight * 4);
  FillChar(TexData^, _RealWidth * _RealHeight * 4, 0);
  case _Usage of
    tuDefault, tuUsage3D:
    begin
      for j := 0 to _RealHeight - 1 do
      for i := 0 to _RealWidth - 1 do
      begin
        x := Round((i / _RealWidth) * _Width);
        y := Round((j / _RealHeight) * _Height);
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 0)^ := Image.Pixels[x, y].r;
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 1)^ := Image.Pixels[x, y].g;
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 2)^ := Image.Pixels[x, y].b;
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 3)^ := Image.Pixels[x, y].a;
      end;
    end;
    tuUsage2D:
    begin
      for j := 0 to _Height - 1 do
      for i := 0 to _Width - 1 do
      begin
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 0)^ := Image.Pixels[i, j].r;
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 1)^ := Image.Pixels[i, j].g;
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 2)^ := Image.Pixels[i, j].b;
        PG2IntU8(TexData + (j * _RealWidth + i) * 4 + 3)^ := Image.Pixels[i, j].a;
      end;
    end;
  end;
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, @_Texture);
  glBindTexture(GL_TEXTURE_2D, _Texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA,
    _RealWidth,
    _RealHeight,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    TexData
  );
  if _Usage = tuUsage3D then
  begin
    Mip0 := TexData;
    px := _RealWidth; py := _RealHeight;
    x := px div 2; if x < 1 then x := 1;
    y := py div 2; if y < 1 then y := 1;
    ds := x * y * 4;
    GetMem(MipData, ds);
    Mip1 := MipData;
    Levels := MaxMipLevel(_RealWidth, _RealHeight);
    for l := 1 to Levels - 1 do
    begin
      oc := 0;
      px4 := px * 4;
      op00 := 0;
      op01 := op00 + px4;
      for j := 0 to y - 1 do
      begin
        op10 := op00 + 4;
        op11 := op01 + 4;
        for i := 0 to x - 1 do
        begin
          PG2IntU8(Mip1 + oc + 0)^ := (
            PG2IntU8(Mip0 + op00 + 0)^ +
            PG2IntU8(Mip0 + op01 + 0)^ +
            PG2IntU8(Mip0 + op10 + 0)^ +
            PG2IntU8(Mip0 + op11 + 0)^
          ) div 4;
          PG2IntU8(Mip1 + oc + 1)^ := (
            PG2IntU8(Mip0 + op00 + 1)^ +
            PG2IntU8(Mip0 + op01 + 1)^ +
            PG2IntU8(Mip0 + op10 + 1)^ +
            PG2IntU8(Mip0 + op11 + 1)^
          ) div 4;
          PG2IntU8(Mip1 + oc + 2)^ := (
            PG2IntU8(Mip0 + op00 + 2)^ +
            PG2IntU8(Mip0 + op01 + 2)^ +
            PG2IntU8(Mip0 + op10 + 2)^ +
            PG2IntU8(Mip0 + op11 + 2)^
          ) div 4;
          PG2IntU8(Mip1 + oc + 3)^ := (
            PG2IntU8(Mip0 + op00 + 3)^ +
            PG2IntU8(Mip0 + op01 + 3)^ +
            PG2IntU8(Mip0 + op10 + 3)^ +
            PG2IntU8(Mip0 + op11 + 3)^
          ) div 4;
          oc := oc + 4;
          op00 := op00 + 8;
          op01 := op01 + 8;
          op10 := op10 + 8;
          op11 := op11 + 8;
        end;
        op00 := op00 + px4;
        op01 := op01 + px4;
      end;
      glTexImage2D(
        GL_TEXTURE_2D,
        l,
        GL_RGBA,
        x,
        y,
        0,
        GL_RGBA,
        GL_UNSIGNED_BYTE,
        Mip1
      );
      Ptr := Mip0;
      Mip0 := Mip1;
      Mip1 := Ptr;
      px := x; py := y;
      x := px div 2; if x < 1 then x := 1;
      y := py div 2; if y < 1 then y := 1;
    end;
    FreeMem(MipData, ds);
  end;
  FreeMem(TexData, _RealWidth * _RealHeight * 4);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glBindTexture(GL_TEXTURE_2D, 0);
  {$endif}
  case _Usage of
    tuDefault, tuUsage3D:
    begin
      _SizeTU := 1;
      _SizeTV := 1;
    end;
    tuUsage2D:
    begin
      _SizeTU := _Width / _RealWidth;
      _SizeTV := _Height / _RealHeight;
    end;
  end;
  Result := True;
end;
//TG2Texture2D END

//TG2Texture2DRT BEGIN
procedure TG2Texture2DRT.Release;
begin
  inherited Release;
  {$if defined(G2Gfx_D3D9)}
  SafeRelease(_Surface);
  {$elseif defined(G2Gfx_OGL)}
  case _Mode of
    rtmFBO:
    begin
      glDeleteRenderbuffers(1, @_RenderBuffer);
      glDeleteFramebuffers(1, @_FrameBuffer);
    end;
    rtmPBuffer:
    begin
      {$if defined(G2Target_Windows)}
      if (_PBufferRC <> 0) then
      begin
        wglDeleteContext(_PBufferRC);
        _PBufferRC := 0;
      end;
      if (_PBufferDC <> 0) then
      begin
        wglReleasePbufferDC(_PBufferHandle, _PBufferDC);
        _PBufferDC := 0;
      end;
      if (_PBufferHandle <> 0) then
      begin
        wglDestroyPbuffer(_PBufferHandle);
        _PBufferHandle := 0;
      end;
      {$elseif defined(G2Target_Linux)}
      if (_PBufferContext <> nil) then
      begin
        glXDestroyContext(g2.Window.Display, _PBufferContext);
        _PBufferContext := nil;
      end;
      if (_PBuffer <> 0) then
      begin
        glXDestroyPBuffer(g2.Window.Display, _PBuffer);
        _PBuffer := 0;
      end;
      {$elseif defined(G2Target_OSX)}
      if (_PBufferContext <> nil) then
      begin
        aglDestroyContext(_PBufferContext);
        _PBufferContext := nil;
      end;
      if (_PBuffer <> nil) then
      begin
        aglDestroyPBuffer(_PBuffer);
        _PBuffer := nil;
      end;
      {$endif}
    end;
  end;
  _Mode := rtmNone;
  {$elseif defined(G2Gfx_GLES)}
  glDeleteRenderbuffers(1, @_RenderBuffer);
  glDeleteFramebuffers(1, @_FrameBuffer);
  {$endif}
end;

function TG2Texture2DRT.Make(const NewWidth, NewHeight: TG2IntS32): Boolean;
{$ifdef G2Gfx_OGL}
{$if defined(G2Target_Windows)}
  var pbufferiAttr: array[0..21] of TG2IntS32;
  var pbufferfAttr: array[0..3] of TG2Float;
  var pixelFormat: TG2IntS32;
  var nPixelFormat: TG2IntU32;
{$elseif defined(G2Target_Linux)}
  var AttrCount: TG2IntS32;
  var FBConfig: GLXFBConfig;
  var VisualInfo: PXVisualInfo;
  var PBufferAttr: array[0..9] of TG2IntS32;
  var FBConfigAttr: array[0..31] of TG2IntS32;
{$elseif defined(G2Target_OSX)}
  var PBufferAttr: array[0..31] of TG2IntU32;
  var PixelFormat: TAGLPixelFormat;
  var Device: GDHandle;
{$endif}
{$endif}
begin
  Release;
  Result := False;
  _Width := NewWidth;
  _Height := NewHeight;
  _RealWidth := 1; while _RealWidth < _Width do _RealWidth := _RealWidth shl 1;
  _RealHeight := 1; while _RealHeight < _Height do _RealHeight := _RealHeight shl 1;
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.CreateTexture(
    _RealWidth, _RealHeight, 1, D3DUSAGE_RENDERTARGET,
    D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT,
    IDirect3DTexture9(_Texture), nil
  );
  IDirect3DTexture9(_Texture).GetSurfaceLevel(0, _Surface);
  {$elseif defined(G2Gfx_OGL)}
  if gl_FBO_Cap then _Mode := rtmFBO
  else if gl_PBuffer_Cap then _Mode := rtmPBuffer
  else _Mode := rtmNone;
  if (_Mode <> rtmNone) then
  begin
    glGenTextures(1, @_Texture);
    if _Texture = 0 then Exit;
    glBindTexture(GL_TEXTURE_2D, _Texture);
    glTexImage2D(
      GL_TEXTURE_2D,
      0,
      GL_RGBA,
      _RealWidth,
      _RealHeight,
      0,
      GL_RGBA,
      GL_UNSIGNED_BYTE,
      nil
    );
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  end;
  if _Mode = rtmFBO then
  begin
    glGenFramebuffers(1, @_FrameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _FrameBuffer);
    glGenRenderbuffers(1, @_RenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _RenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, _RealWidth, _RealHeight);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _RealWidth, _RealHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _RenderBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
  end
  else
  if (_Mode = rtmPBuffer) then
  begin
    {$if defined(G2Target_Windows)}
    {$Hints off}
    FillChar(pbufferiAttr, SizeOf(pbufferiAttr), 0);
    FillChar(pbufferfAttr, SizeOf(pbufferfAttr), 0);
    {$Hints on}
    pbufferiAttr[0] := WGL_DRAW_TO_PBUFFER; pbufferiAttr[1] := 1;
    pbufferiAttr[2] := WGL_DOUBLE_BUFFER; pbufferiAttr[3] := 1;
    pbufferiAttr[4] := WGL_COLOR_BITS; pbufferiAttr[5] := 32;
    pbufferiAttr[6] := WGL_RED_BITS; pbufferiAttr[7] := 8;
    pbufferiAttr[8] := WGL_GREEN_BITS; pbufferiAttr[9] := 8;
    pbufferiAttr[10] := WGL_BLUE_BITS; pbufferiAttr[11] := 8;
    pbufferiAttr[12] := WGL_ALPHA_BITS; pbufferiAttr[13] := 8;
    pbufferiAttr[14] := WGL_DEPTH_BITS; pbufferiAttr[15] := 16;
    pbufferiAttr[16] := WGL_STENCIL_BITS; pbufferiAttr[17] := 0;
    if not wglChoosePixelFormat(_Gfx.DC, @pbufferiAttr, @pbufferfAttr, 1, @pixelFormat, @nPixelFormat) then Exit;
    _PBufferHandle := wglCreatePbuffer(_Gfx.DC, pixelFormat, _RealWidth, _RealHeight, nil);
    if _PBufferHandle = 0 then Exit;
    _PBufferDC := wglGetPbufferDC(_PBufferHandle);
    _PBufferRC := wglCreateContext(_PBufferDC);
    wglShareLists(_Gfx.Context, _PBufferRC);
    {$elseif defined(G2Target_Linux)}
    {$Hints off}
    FillChar(PBufferAttr, SizeOf(PBufferAttr), 0);
    FillChar(FBConfigAttr, SizeOf(FBConfigAttr), 0);
    {$Hints on}
    FBConfigAttr[0] := GLX_DRAWABLE_TYPE;
    FBConfigAttr[1] := GLX_PBUFFER_BIT;
    FBConfigAttr[2] := GLX_DOUBLEBUFFER;
    FBConfigAttr[3] := 1;
    FBConfigAttr[4] := GLX_RENDER_TYPE;
    FBConfigAttr[5] := GLX_RGBA_BIT;
    FBConfigAttr[6] := GLX_RED_SIZE;
    FBConfigAttr[7] := 8;
    FBConfigAttr[8] := GLX_GREEN_SIZE;
    FBConfigAttr[9] := 8;
    FBConfigAttr[10] := GLX_BLUE_SIZE;
    FBConfigAttr[11] := 8;
    FBConfigAttr[12] := GLX_ALPHA_SIZE;
    FBConfigAttr[13] := 8;
    FBConfigAttr[14] := GLX_DEPTH_SIZE;
    FBConfigAttr[15] := 16;
    AttrCount := 16;
    FBConfig := glXChooseFBConfig(g2.Window.Display, 0, @FBConfigAttr, @AttrCount);
    PBufferAttr[0] := GLX_PBUFFER_WIDTH;
    PBufferAttr[1] := _RealWidth;
    PBufferAttr[2] := GLX_PBUFFER_HEIGHT;
    PBufferAttr[3] := _RealHeight;
    PBufferAttr[4] := GLX_PRESERVED_CONTENTS;
    PBufferAttr[5] := 1;
    PBufferAttr[6] := GLX_LARGEST_PBUFFER;
    PBufferAttr[7] := 1;
    _PBuffer := glXCreatePBuffer(g2.Window.Display, PG2IntS32(FBConfig)^, @PBufferAttr);
    VisualInfo := glXGetVisualFromFBConfig(g2.Window.Display, PG2IntS32(FBConfig)^);
    _PBufferContext := glXCreateContext(g2.Window.Display, VisualInfo, _Gfx.Context, True);
    XFree(FBConfig);
    XFree(VisualInfo);
    {$elseif defined(G2Target_OSX)}
    FillChar(PBufferAttr, SizeOf(PBufferAttr), 0);
    PBufferAttr[0] := AGL_DOUBLEBUFFER;
    PBufferAttr[1] := AGL_RGBA;
    PBufferAttr[2] := 1;
    PBufferAttr[3] := AGL_RED_SIZE;
    PBufferAttr[4] := 8;
    PBufferAttr[5] := AGL_GREEN_SIZE;
    PBufferAttr[6] := 8;
    PBufferAttr[7] := AGL_BLUE_SIZE;
    PBufferAttr[8] := 8;
    PBufferAttr[9] := AGL_ALPHA_SIZE;
    PBufferAttr[10] := 8;
    PBufferAttr[11] := AGL_DEPTH_SIZE;
    PBufferAttr[12] := 16;
    DMGetGDeviceByDisplayID(DisplayIDType(kCGDirectMainDisplay), Device, False);
    PixelFormat := aglChoosePixelFormat(@Device, 1, @PBufferAttr);
    _PBufferContext := aglCreateContext(PixelFormat, _Gfx.Context);
    aglDestroyPixelFormat(PixelFormat);
    aglCreatePBuffer(_RealWidth, _RealHeight, GL_TEXTURE_2D, GL_RGBA, 0, @_PBuffer);
    {$endif}
  end;
  {$elseif defined(G2Gfx_GLES)}
  glGenTextures(1, @_Texture);
  if _Texture = 0 then Exit;
  glBindTexture(GL_TEXTURE_2D, _Texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA,
    _RealWidth,
    _RealHeight,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    nil
  );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glGenFramebuffers(1, @_FrameBuffer);
  glBindFramebuffer(GL_FRAMEBUFFER_OES, _FrameBuffer);
  glGenRenderbuffers(1, @_RenderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER_OES, _RenderBuffer);
  glRenderbufferStorage(GL_RENDERBUFFER_OES, GL_RGBA, _RealWidth, _RealHeight);
  glRenderbufferStorage(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, _RealWidth, _RealHeight);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, _RenderBuffer);
  glFramebufferTexture2D(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, 0, 0);
  glBindFramebuffer(GL_FRAMEBUFFER_OES, 0);
  {$endif}
  _SizeTU := _Width / _RealWidth;
  _SizeTV := _Height / _RealHeight;
  Result := True;
end;

//TG2Texture2DRT END

//TG2SoundBuffer BEGIN
procedure TG2SoundBuffer.Release;
begin
  {$if defined(G2Snd_DS)}
  SafeRelease(_Buffer);
  {$elseif defined(G2Snd_OAL)}
  if _Buffer <> 0 then
  begin
    alDeleteBuffers(1, @_Buffer);
    _Buffer := 0;
  end;
  {$endif}
end;

procedure TG2SoundBuffer.Initialize;
begin
  {$ifdef G2Snd_OAL}
  _Buffer := 0;
  {$endif}
end;

procedure TG2SoundBuffer.Finalize;
begin
  Release;
end;

function TG2SoundBuffer.Load(const Stream: TStream): Boolean;
  var Audio: TG2Audio;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2AudioFormats) do
  if G2AudioFormats[i].CanRead(Stream) then
  begin
    Audio := G2AudioFormats[i].Create;
    try
      Audio.Load(Stream);
      Result := Load(Audio);
    finally
      Audio.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2SoundBuffer.Load(const FileName: FileString): Boolean;
  var Audio: TG2Audio;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2AudioFormats) do
  if G2AudioFormats[i].CanRead(FileName) then
  begin
    Audio := G2AudioFormats[i].Create;
    try
      Audio.Load(FileName);
      Result := Load(Audio);
    finally
      Audio.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2SoundBuffer.Load(const Buffer: Pointer; const Size: TG2IntS32): Boolean;
  var Audio: TG2Audio;
  var i: TG2IntS32;
begin
  for i := 0 to High(G2AudioFormats) do
  if G2AudioFormats[i].CanRead(Buffer, Size) then
  begin
    Audio := G2AudioFormats[i].Create;
    try
      Audio.Load(Buffer, Size);
      Result := Load(Audio);
    finally
      Audio.Free;
    end;
    Exit;
  end;
  Result := False;
end;

function TG2SoundBuffer.Load(const Audio: TG2Audio): Boolean;
{$if defined(G2Snd_DS)}
  var Desc: TDSBufferDesc;
  var Format: TWaveFormatEx;
  var Ptr: Pointer;
  var LockBytes: TG2IntU32;
  var hr: HResult;
begin
  Result := False;
  Release;
  {$Hints off}
  FillChar(Format, SizeOf(Format), 0);
  {$Hints on}
  Format.cbSize := SizeOf(Format);
  Format.nChannels := Audio.ChannelCount;
  Format.nSamplesPerSec := Audio.SampleRate;
  Format.wBitsPerSample := Audio.SampleSize * 8;
  Format.wFormatTag := 1;
  Format.nAvgBytesPerSec := Audio.SampleRate * Audio.SampleSize;
  Format.nBlockAlign := Audio.SampleSize * Audio.ChannelCount;
  {$Hints off}
  FillChar(Desc, SizeOf(Desc), 0);
  {$Hints on}
  Desc.dwSize := SizeOf(Desc);
  Desc.dwFlags := DSBCAPS_CTRL3D;
  Desc.dwBufferBytes := Audio.DataSize;
  Desc.lpwfxFormat := @Format;
  hr := TG2SndDS(g2.Snd)._Device.CreateSoundBuffer(
    Desc, _Buffer, nil
  );
  if Failed(hr) then Exit;
  _Buffer.Lock(0, 0, @Ptr, @LockBytes, nil, nil, DSBLOCK_ENTIREBUFFER);
  try
    Move(Audio.Data^, Ptr^, Audio.DataSize);
  finally
    _Buffer.Unlock(Ptr, LockBytes, nil, 0);
  end;
  Result := True;
end;
{$elseif defined(G2Snd_OAL)}
  var Format: TALEnum;
begin
  Result := False;
  Release;
  case Audio.Format of
    afMono8: Format := AL_FORMAT_MONO8;
    afMono16: Format := AL_FORMAT_MONO16;
    afStereo8: Format := AL_FORMAT_STEREO8;
    afStereo16: Format := AL_FORMAT_STEREO16;
    else Format := AL_FORMAT_MONO8;
  end;
  alGenBuffers(1, @_Buffer);
  if _Buffer = 0 then Exit;
  alBufferData(_Buffer, Format, Audio.Data, Audio.DataSize, Audio.SampleRate);
  Result := True;
end;
{$endif}
//TG2SoundBuffer END

//TG2SoundInst BEGIN
procedure TG2SoundInst.SetBuffer(const Value: TG2SoundBuffer);
begin
  if _Buffer <> Value then
  begin
    _Buffer := Value;
    {$if defined(G2Snd_DS)}
    SafeRelease(_SoundBuffer3D);
    SafeRelease(_SoundBuffer);
    TG2SndDS(g2.Snd)._Device.DuplicateSoundBuffer(
      _Buffer.GetBuffer, _SoundBuffer
    );
    _SoundBuffer.QueryInterface(IID_IDirectSound3DBuffer8, _SoundBuffer3D);
    _SoundBuffer3D.SetMode(DS3DMODE_HEADRELATIVE, DS3D_IMMEDIATE);
    {$elseif defined(G2Snd_OAL)}
    alSourcei(_Source, AL_BUFFER, _Buffer.GetBuffer);
    {$endif}
  end;
end;

procedure TG2SoundInst.SetPos(const Value: TG2Vec3);
{$ifdef G2Snd_OAL}
  var v: TG2Vec3;
{$endif}
begin
  _Pos := Value;
  {$if defined(G2Snd_DS)}
  _SoundBuffer3D.SetPosition(_Pos.x, _Pos.y, _Pos.z, DS3D_IMMEDIATE);
  {$elseif defined(G2Snd_OAL)}
  v.x := _Pos.x; v.y := _Pos.y; v.z := -_Pos.z;
  alSourcefv(_Source, AL_POSITION, @v);
  {$endif}
end;

procedure TG2SoundInst.SetVel(const Value: TG2Vec3);
{$ifdef G2Snd_OAL}
  var v: TG2Vec3;
{$endif}
begin
  _Vel := Value;
  {$if defined(G2Snd_DS)}
  _SoundBuffer3D.SetVelocity(_Vel.x, _Vel.y, _Vel.z, DS3D_IMMEDIATE);
  {$elseif defined(G2Snd_OAL)}
  v.x := _Pos.x; v.y := _Pos.y; v.z := -_Pos.z;
  alSourcefv(_Source, AL_VELOCITY, @v);
  {$endif}
end;

procedure TG2SoundInst.SetLoop(const Value: Boolean);
{$ifdef G2Snd_DS}
  var Flags: TG2IntU32;
{$endif}
begin
  if _Loop <> Value then
  begin
    _Loop := Value;
    {$if defined(G2Snd_DS)}
    if IsPlaying then
    begin
      if _Loop then Flags := DSBPLAY_LOOPING else Flags := 0;
      _SoundBuffer.Play(0, 0, Flags);
    end;
    {$elseif defined(G2Snd_OAL)}
    alSourcei(_Source, AL_LOOPING, TG2IntS32(loop));
    {$endif}
  end;
end;

procedure TG2SoundInst.Play;
{$ifdef G2Snd_DS}
  var Flags: TG2IntU32;
{$endif}
begin
  {$if defined(G2Snd_DS)}
  if _Loop then Flags := DSBPLAY_LOOPING else Flags := 0;
  if IsPlaying then Stop;
  _SoundBuffer.Play(0, 0, Flags);
  {$elseif defined(G2Snd_OAL)}
  alSourcePlay(_Source);
  {$endif}
end;

procedure TG2SoundInst.Pause;
begin
  {$if defined(G2Snd_DS)}
  _SoundBuffer.Stop;
  {$elseif defined(G2Snd_OAL)}
  alSourcePause(_Source);
  {$endif}
end;

procedure TG2SoundInst.Stop;
begin
  {$if defined(G2Snd_DS)}
  _SoundBuffer.Stop;
  _SoundBuffer.SetCurrentPosition(0);
  {$elseif defined(G2Snd_OAL)}
  alSourceStop(_Source);
  {$endif}
end;

function TG2SoundInst.IsPlaying: Boolean;
{$if defined(G2Snd_DS)}
  var Status: TG2IntU32;
{$elseif defined(G2Snd_OAL)}
  var Param: TALInt;
{$endif}
begin
  {$if defined(G2Snd_DS)}
  _SoundBuffer.GetStatus(Status);
  Result := Status and DSBSTATUS_PLAYING > 0;
  {$elseif defined(G2Snd_OAL)}
  alGetSourcei(_Source, AL_SOURCE_STATE, @Param);
  Result := Param = AL_PLAYING;
  {$endif}
end;

constructor TG2SoundInst.Create(const SoundBuffer: TG2SoundBuffer);
begin
  inherited Create;
  _Buffer := nil;
  _Pos := g2.Snd.ListenerPos;
  _Vel := g2.Snd.ListenerVel;
  _Loop := False;
  {$if defined(G2Snd_DS)}
  Buffer := SoundBuffer;
  {$elseif defined(G2Snd_OAL)}
  alGenSources(1, @_Source);
  Buffer := SoundBuffer;
  alSourcef(_Source, AL_PITCH, 1.0 );
  alSourcef(_Source, AL_GAIN, 1.0 );
  alSourcefv(_Source, AL_POSITION, @_Pos);
  alSourcefv(_Source, AL_VELOCITY, @_Vel);
  alSourcei(_Source, AL_LOOPING, TG2IntS32(_Loop));
  {$endif}
end;

destructor TG2SoundInst.Destroy;
begin
  Stop;
  {$if defined(G2Snd_DS)}
  SafeRelease(_SoundBuffer3D);
  SafeRelease(_SoundBuffer);
  {$elseif defined(G2Snd_OAL)}
  alDeleteSources(1, @_Source);
  {$endif}
  inherited Destroy;
end;
//TG2SoundInst END

//TG2Buffer BEGIN
procedure TG2Buffer.Initialize;
begin
  _Allocated := False;
  _Data := nil;
  _DataSize := 0;
end;

procedure TG2Buffer.Finalize;
begin
  Release;
end;

procedure TG2Buffer.Allocate(const Size: TG2IntU32);
begin
  Release;
  _Data := G2MemAlloc(Size);
  _Allocated := True;
  _DataSize := Size;
end;

procedure TG2Buffer.Release;
begin
  if _Allocated then
  begin
    G2MemFree(_Data, _DataSize);
    _Allocated := False;
  end;
end;
//TG2Buffer END

//TG2VertexBuffer BEGIN
{$if defined(G2Gfx_d3d9)}
procedure TG2VertexBuffer.WriteBufferData;
{$if defined(G2RM_FF)}
  var i, j, n: TG2IntS32;
  var p0, p1: PG2IntU8Arr;
begin
  p0 := Data;
  _VB.Lock(0, _VertexStride * _VertexCount, Pointer(p1), D3DLOCK_DISCARD);
  for i := 0 to _VertexCount - 1 do
  begin
    for j := 0 to High(_Decl) do
    begin
      if _VertexMapping[j].Enabled then
      begin
        for n := 0 to _VertexMapping[j].Count - 1 do
        _VertexMapping[j].ProcWrite(
          @p0^[n * _VertexMapping[j].SizeSrc],
          @p1^[_VertexMapping[j].StridePos + n * _VertexMapping[j].SizeDst]
        );
      end;
      p0 := PG2IntU8Arr(Pointer(p0) + _Decl[j].Count * 4);
    end;
    p1 := PG2IntU8Arr(Pointer(p1) + _VertexStride);
  end;
  _VB.Unlock;
end;
{$elseif defined(G2RM_SM2)}
  var p0: Pointer;
begin
  _VB.Lock(0, _VertexSize * _VertexCount, p0, D3DLOCK_DISCARD);
  Move(_Data^, p0^, _VertexSize * _VertexCount);
  _VB.Unlock;
end;
{$endif}
{$if defined(G2RM_FF)}
procedure TG2VertexBuffer.InitFVF;
  var i, tc, bi, bw: TG2IntS32;
  var CurPos, VDiffuseID, VNormalID, VIndexID, VWeightID: TG2IntS32;
  var PosFVF, PosSize, DiffuseSize, NormalSize: TG2IntU32;
  var TexCoordSize: array[0..7] of TG2IntU32;
  var VTexCoordID: array[0..7] of TG2IntS32;
begin
  _FVF := 0; _VertexStride := 0; PosFVF := 0;
  tc := 0; bi := 0; bw := 0;
  PosSize := 0;
  DiffuseSize := 0;
  NormalSize := 0;
  for i := 0 to High(TexCoordSize) do TexCoordSize[i] := 0;
  VDiffuseID := -1;
  VNormalID := -1;
  for i := 0 to High(VTexCoordID) do VTexCoordID[i] := -1;
  VIndexID := -1;
  VWeightID := -1;
  for i := 0 to High(_Decl) do
  case _Decl[i].Element of
    vbPosition:
    begin
      case _Decl[i].Count of
        3:
        begin
          PosFVF := D3DFVF_XYZ;
          PosSize := 12;
          _VertexMapping[i].Enabled := True;
          _VertexMapping[i].ProcWrite := @CopyFloatToFloat;
          _VertexMapping[i].StridePos := 0;
          _VertexMapping[i].Count := _Decl[i].Count;
          _VertexMapping[i].SizeDst := 4;
          _VertexMapping[i].SizeSrc := 4;
        end;
      end;
    end;
    vbDiffuse:
    begin
      case _Decl[i].Count of
        4:
        begin
          _FVF := _FVF or D3DFVF_DIFFUSE;
          _VertexStride := _VertexStride + 4;
          _VertexMapping[i].Enabled := True;
          _VertexMapping[i].ProcWrite := @CopyFloatToByteScale;
          _VertexMapping[i].Count := _Decl[i].Count;
          _VertexMapping[i].SizeDst := 1;
          _VertexMapping[i].SizeSrc := 4;
          DiffuseSize := 4;
          VDiffuseID := i;
        end;
      end;
    end;
    vbTexCoord:
    begin
      case _Decl[i].Count of
        1:
        begin
          _FVF := _FVF or D3DFVF_TEXCOORDSIZE1(tc);
          TexCoordSize[tc] := 4;
        end;
        2:
        begin
          _FVF := _FVF or D3DFVF_TEXCOORDSIZE2(tc);
          TexCoordSize[tc] := 8;
        end;
        3:
        begin
          _FVF := _FVF or D3DFVF_TEXCOORDSIZE3(tc);
          TexCoordSize[tc] := 12;
        end;
        4:
        begin
          _FVF := _FVF or D3DFVF_TEXCOORDSIZE4(tc);
          TexCoordSize[tc] := 16;
        end;
      end;
      if TexCoordSize[tc] > 0 then
      begin
        _VertexStride := _VertexStride + TexCoordSize[tc];
        _VertexMapping[i].Enabled := True;
        _VertexMapping[i].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[i].Count := _Decl[i].Count;
        _VertexMapping[i].SizeDst := 4;
        _VertexMapping[i].SizeSrc := 4;
        VTexCoordID[tc] := i;
        Inc(tc);
      end;
    end;
    vbNormal:
    begin
      case _Decl[i].Count of
        3:
        begin
          _FVF := _FVF or D3DFVF_NORMAL;
          _VertexStride := _VertexStride + 12;
          _VertexMapping[i].Enabled := True;
          _VertexMapping[i].ProcWrite := @CopyFloatToFloat;
          _VertexMapping[i].Count := _Decl[i].Count;
          _VertexMapping[i].SizeDst := 4;
          _VertexMapping[i].SizeSrc := 4;
          NormalSize := 12;
          VNormalID := i;
        end;
      end;
    end;
    vbVertexIndex:
    begin
      bi := _Decl[i].Count;
      VIndexID := i;
      _VertexMapping[i].Count := _Decl[i].Count;
      _VertexMapping[i].SizeDst := 1;
      _VertexMapping[i].SizeSrc := 4;
    end;
    vbVertexWeight:
    begin
      bw := _Decl[i].Count;
      VWeightID := i;
      _VertexMapping[i].Count := _Decl[i].Count;
      _VertexMapping[i].SizeDst := 4;
      _VertexMapping[i].SizeSrc := 4;
    end;
  end;
  if tc > 0 then
  _FVF := _FVF or TG2IntU32(1 shl (tc + 7));
  if bw > 0 then
  begin
    case bw of
      1: if bi > 0 then
      begin
        PosFVF := PosFVF or D3DFVF_XYZB2 or D3DFVF_LASTBETA_UBYTE4;
        _VertexMapping[VIndexID].Enabled := True;
        _VertexMapping[VIndexID].ProcWrite := @CopyFloatToByte;
        _VertexMapping[VIndexID].StridePos := PosSize + 4;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 20;
      end
      else
      begin
        PosFVF := D3DFVF_XYZB1;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 16;
      end;
      2: if bi > 0 then
      begin
        PosFVF := PosFVF or D3DFVF_XYZB3 or D3DFVF_LASTBETA_UBYTE4;
        _VertexMapping[VIndexID].Enabled := True;
        _VertexMapping[VIndexID].ProcWrite := @CopyFloatToByte;
        _VertexMapping[VIndexID].StridePos := PosSize + 8;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 24;
      end
      else
      begin
        PosFVF := D3DFVF_XYZB2;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 20;
      end;
      3: if bi > 0 then
      begin
        PosFVF := PosFVF or D3DFVF_XYZB4 or D3DFVF_LASTBETA_UBYTE4;
        _VertexMapping[VIndexID].Enabled := True;
        _VertexMapping[VIndexID].ProcWrite := @CopyFloatToByte;
        _VertexMapping[VIndexID].StridePos := PosSize + 12;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 28;
      end
      else
      begin
        PosFVF := D3DFVF_XYZB3;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 24;
      end;
      4: if bi > 0 then
      begin
        PosFVF := PosFVF or D3DFVF_XYZB5 or D3DFVF_LASTBETA_UBYTE4;
        _VertexMapping[VIndexID].Enabled := True;
        _VertexMapping[VIndexID].ProcWrite := @CopyFloatToByte;
        _VertexMapping[VIndexID].StridePos := PosSize + 16;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 32;
      end
      else
      begin
        PosFVF := D3DFVF_XYZB4;
        _VertexMapping[VWeightID].Enabled := True;
        _VertexMapping[VWeightID].ProcWrite := @CopyFloatToFloat;
        _VertexMapping[VWeightID].StridePos := PosSize;
        PosSize := 28;
      end;
    end;
  end;
  _FVF := _FVF or PosFVF;
  _VertexStride := _VertexStride + PosSize;
  CurPos := PosSize;
  if VDiffuseID > -1 then _VertexMapping[VDiffuseID].StridePos := CurPos;
  CurPos := CurPos + TG2IntS32(DiffuseSize);
  if VNormalID > -1 then _VertexMapping[VNormalID].StridePos := CurPos;
  CurPos := CurPos + TG2IntS32(NormalSize);
  for i := 0 to High(VTexCoordID) do
  begin
    if VTexCoordID[i] = -1 then Break;
    _VertexMapping[VTexCoordID[i]].StridePos := CurPos;
    CurPos := CurPos + TG2IntS32(TexCoordSize[i]);
  end;
end;

procedure TG2VertexBuffer.CopyFloatToFloat(const Src, Dst: Pointer);
begin
  PG2Float(Dst)^ := PG2Float(Src)^;
end;

procedure TG2VertexBuffer.CopyFloatToByte(const Src, Dst: Pointer);
begin
  PG2IntU8(Dst)^ := Round(PG2Float(Src)^);
end;

procedure TG2VertexBuffer.CopyFloatToByteScale(const Src, Dst: Pointer);
begin
  PG2IntU8(Dst)^ := Round(PG2Float(Src)^ * 255);
end;
{$elseif defined(G2RM_SM2)}
procedure TG2VertexBuffer.InitDecl;
  var i, n, VBPos: TG2IntS32;
  var ve: array of TD3DVertexElement9;
  var IndPosition, IndColor, IndTexCoord, IndNormal, IndBinormal, IndTangent, IndSkinWeight, IndSkinIndex: TG2IntS32;
begin
  IndPosition := 0;
  IndColor := 0;
  IndTexCoord := 0;
  IndNormal := 0;
  IndBinormal := 0;
  IndTangent := 0;
  IndSkinWeight := 0;
  IndSkinIndex := 0;
  SetLength(ve, Length(_Decl) + 1);
  n := 0;
  VBPos := 0;
  for i := 0 to High(_Decl) do
  case _Decl[i].Element of
    vbPosition:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_POSITION, IndPosition);
          Inc(n); Inc(VBPos, 4); Inc(IndPosition);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_POSITION, IndPosition);
          Inc(n); Inc(VBPos, 8); Inc(IndPosition);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_POSITION, IndPosition);
          Inc(n); Inc(VBPos, 12); Inc(IndPosition);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_POSITION, IndPosition);
          Inc(n); Inc(VBPos, 16); Inc(IndPosition);
        end;
      end;
    end;
    vbDiffuse:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_COLOR, IndColor);
          Inc(n); Inc(VBPos, 4); Inc(IndColor);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_COLOR, IndColor);
          Inc(n); Inc(VBPos, 8); Inc(IndColor);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_COLOR, IndColor);
          Inc(n); Inc(VBPos, 12); Inc(IndColor);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_COLOR, IndColor);
          Inc(n); Inc(VBPos, 16); Inc(IndColor);
        end;
      end;
    end;
    vbTexCoord:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_TEXCOORD, IndTexCoord);
          Inc(n); Inc(VBPos, 4); Inc(IndTexCoord);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_TEXCOORD, IndTexCoord);
          Inc(n); Inc(VBPos, 8); Inc(IndTexCoord);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_TEXCOORD, IndTexCoord);
          Inc(n); Inc(VBPos, 12); Inc(IndTexCoord);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_TEXCOORD, IndTexCoord);
          Inc(n); Inc(VBPos, 16); Inc(IndTexCoord);
        end;
      end;
    end;
    vbNormal:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_NORMAL, IndNormal);
          Inc(n); Inc(VBPos, 4); Inc(IndNormal);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_NORMAL, IndNormal);
          Inc(n); Inc(VBPos, 8); Inc(IndNormal);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_NORMAL, IndNormal);
          Inc(n); Inc(VBPos, 12); Inc(IndNormal);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_NORMAL, IndNormal);
          Inc(n); Inc(VBPos, 16); Inc(IndNormal);
        end;
      end;
    end;
    vbBinormal:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_BINORMAL, IndBinormal);
          Inc(n); Inc(VBPos, 4); Inc(IndBinormal);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_BINORMAL, IndBinormal);
          Inc(n); Inc(VBPos, 8); Inc(IndBinormal);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_BINORMAL, IndBinormal);
          Inc(n); Inc(VBPos, 12); Inc(IndBinormal);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_BINORMAL, IndBinormal);
          Inc(n); Inc(VBPos, 16); Inc(IndBinormal);
        end;
      end;
    end;
    vbTangent:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_TANGENT, IndTangent);
          Inc(n); Inc(VBPos, 4); Inc(IndTangent);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_TANGENT, IndTangent);
          Inc(n); Inc(VBPos, 8); Inc(IndTangent);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_TANGENT, IndTangent);
          Inc(n); Inc(VBPos, 12); Inc(IndTangent);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_TANGENT, IndTangent);
          Inc(n); Inc(VBPos, 16); Inc(IndTangent);
        end;
      end;
    end;
    vbVertexWeight:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_BLENDWEIGHT, IndSkinWeight);
          Inc(n); Inc(VBPos, 4); Inc(IndSkinWeight);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_BLENDWEIGHT, IndSkinWeight);
          Inc(n); Inc(VBPos, 8); Inc(IndSkinWeight);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_BLENDWEIGHT, IndSkinWeight);
          Inc(n); Inc(VBPos, 12); Inc(IndSkinWeight);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_BLENDWEIGHT, IndSkinWeight);
          Inc(n); Inc(VBPos, 16); Inc(IndSkinWeight);
        end;
      end;
    end;
    vbVertexIndex:
    begin
      case _Decl[i].Count of
        1:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT1, D3DDECLUSAGE_BLENDINDICES, IndSkinIndex);
          Inc(n); Inc(VBPos, 4); Inc(IndSkinIndex);
        end;
        2:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_BLENDINDICES, IndSkinIndex);
          Inc(n); Inc(VBPos, 8); Inc(IndSkinIndex);
        end;
        3:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_BLENDINDICES, IndSkinIndex);
          Inc(n); Inc(VBPos, 12); Inc(IndSkinIndex);
        end;
        4:
        begin
          ve[n] := D3DVertexElement(VBPos, D3DDECLTYPE_FLOAT4, D3DDECLUSAGE_BLENDINDICES, IndSkinIndex);
          Inc(n); Inc(VBPos, 16); Inc(IndSkinIndex);
        end;
      end;
    end;
  end;
  if Length(ve) <> n + 1 then
  SetLength(ve, n + 1);
  ve[n] := D3DDECL_END;
  _Gfx.Device.CreateVertexDeclaration(@ve[0], _DeclD3D);
end;
{$endif}

procedure TG2VertexBuffer.Initialize;
  var i: TG2IntS32;
begin
  inherited Initialize;
  _VertexSize := 0;
  for i := 0 to High(_Decl) do
  begin
    if _Decl[i].Element <> vbNone then
    _VertexSize := _VertexSize + TG2IntU32(_Decl[i].Count * 4);
  end;
  Allocate(_VertexSize * _VertexCount);
  {$if defined(G2RM_FF)}
  SetLength(_VertexMapping, Length(_Decl));
  for i := 0 to High(_VertexMapping) do
  _VertexMapping[i].Enabled := False;
  InitFVF;
  _Gfx.Device.CreateVertexBuffer(
    _VertexStride * _VertexCount,
    D3DUSAGE_WRITEONLY, _FVF, D3DPOOL_MANAGED,
    _VB, nil
  );
  {$elseif defined(G2RM_SM2)}
  InitDecl;
  _Gfx.Device.CreateVertexBuffer(
    _VertexSize * _VertexCount,
    D3DUSAGE_WRITEONLY, 0, D3DPOOL_MANAGED,
    _VB, nil
  );
  {$endif}
  _Locked := False;
end;

procedure TG2VertexBuffer.Finalize;
begin
  {$if defined(G2RM_SM2)}
  SafeRelease(_DeclD3D);
  {$endif}
  SafeRelease(_VB);
  Release;
  inherited Finalize;
end;

procedure TG2VertexBuffer.Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
begin
  if _Locked then UnLock;
  _LockMode := LockMode;
  _Locked := True;
end;

procedure TG2VertexBuffer.UnLock;
begin
  if not _Locked then Exit;
  case _LockMode of
    lmReadWrite: WriteBufferData;
  end;
  _Locked := False;
end;

procedure TG2VertexBuffer.Bind;
begin
  {$if defined(G2RM_FF)}
  _Gfx.Device.SetFVF(_FVF);
  _Gfx.Device.SetStreamSource(0, _VB, 0, _VertexStride);
  {$elseif defined(G2RM_SM2)}
  _Gfx.Device.SetVertexDeclaration(_DeclD3D);
  _Gfx.Device.SetStreamSource(0, _VB, 0, _VertexSize);
  {$endif}
end;

procedure TG2VertexBuffer.Unbind;
begin

end;

constructor TG2VertexBuffer.Create(const Decl: TG2VBDecl; const Count: TG2IntU32);
begin
  _Gfx := TG2GfxD3D9(g2.Gfx);
  _Decl := Decl;
  _VertexCount := Count;
  inherited Create;
end;
{$elseif defined(G2Gfx_OGL)}
function TG2VertexBuffer.GetTexCoordIndex(const Index: TG2IntS32): Pointer;
begin
  Result := _TexCoordIndex[Index];
end;

procedure TG2VertexBuffer.WriteBufferData;
begin
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  glBufferSubData(GL_ARRAY_BUFFER, 0, _VertexCount * _VertexSize, Data);
end;

procedure TG2VertexBuffer.Initialize;
  var i, ti: TG2IntS32;
begin
  inherited Initialize;
  _VertexSize := 0;
  ti := 0;
  for i := 0 to High(_Decl) do
  if _Decl[i].Element <> vbNone then
  begin
    if _Decl[i].Element = vbTexCoord then
    begin
      {$Hints off}
      _TexCoordIndex[ti] := Pointer(_VertexSize);
      {$Hints on}
      Inc(ti);
    end;
    _VertexSize := _VertexSize + TG2IntU32(_Decl[i].Count * 4);
  end;
  for i := ti to High(_TexCoordIndex) do
  _TexCoordIndex[i] := nil;
  Allocate(_VertexCount * _VertexSize);
  glGenBuffers(1, @_VB);
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  glBufferData(GL_ARRAY_BUFFER, _VertexCount * _VertexSize, nil, GL_STATIC_DRAW);
  {$if defined(G2RM_SM2)}
  _BoundAttribs.Clear;
  {$endif}
  _Locked := False;
end;

procedure TG2VertexBuffer.Finalize;
begin
  glDeleteBuffers(1, @_VB);
  Release;
  inherited Finalize;
end;

procedure TG2VertexBuffer.Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
begin
  if _Locked then UnLock;
  _LockMode := LockMode;
  _Locked := True;
end;

procedure TG2VertexBuffer.UnLock;
begin
  if not _Locked then Exit;
  case _LockMode of
    lmReadWrite: WriteBufferData;
  end;
  _Locked := False;
end;

procedure TG2VertexBuffer.Bind;
{$if defined(G2RM_FF)}
  var i: TG2IntS32;
  var BufferPos: TG2IntU32;
  var CurTexture: TG2IntU32;
begin
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  BufferPos := 0;
  CurTexture := GL_TEXTURE0;
  for i := 0 to High(_Decl) do
  begin
    case _Decl[i].Element of
      vbPosition:
      begin
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(_Decl[i].Count, GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      vbNormal:
      begin
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      vbDiffuse:
      begin
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(_Decl[i].Count, GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      vbTexCoord:
      begin
        glClientActiveTexture(CurTexture);
        Inc(CurTexture);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(_Decl[i].Count, GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      else
      begin
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
    end;
  end;
  glClientActiveTexture(GL_TEXTURE0);
end;
{$elseif defined(G2RM_SM2)}
  function GetAttribIndex(const Attrib: AnsiString): GLInt;
  begin
    if _Gfx.ShaderMethod = nil then
    begin
      Result := -1;
      Exit;
    end;
    Result := glGetAttribLocation(_Gfx.ShaderMethod^.ShaderProgram, PAnsiChar(Attrib));
  end;
  var i: TG2IntS32;
  var VBPos: TG2IntU32;
  var IndPosition, IndColor, IndTexCoord, IndNormal, IndBinormal, IndTangent, IndBlendWeight, IndBlendIndex: TG2IntS32;
  var ai: GLInt;
begin
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  VBPos := 0;
  IndPosition := 0;
  IndColor := 0;
  IndTexCoord := 0;
  IndNormal := 0;
  IndBinormal := 0;
  IndTangent := 0;
  IndBlendWeight := 0;
  IndBlendIndex := 0;
  for i := 0 to High(_Decl) do
  case _Decl[i].Element of
    vbPosition:
    begin
      ai := GetAttribIndex('a_Position' + IntToStr(IndPosition));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndPosition);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbDiffuse:
    begin
      ai := GetAttribIndex('a_Color' + IntToStr(IndColor));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndPosition);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbTexCoord:
    begin
      ai := GetAttribIndex('a_TexCoord' + IntToStr(IndTexCoord));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndTexCoord);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbNormal:
    begin
      ai := GetAttribIndex('a_Normal' + IntToStr(IndNormal));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndNormal);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbBinormal:
    begin
      ai := GetAttribIndex('a_Binormal' + IntToStr(IndBinormal));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndBinormal);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbTangent:
    begin
      ai := GetAttribIndex('a_Tangent' + IntToStr(IndTangent));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndTangent);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbVertexWeight:
    begin
      ai := GetAttribIndex('a_BlendWeight' + IntToStr(IndBlendWeight));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndBlendWeight);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    vbVertexIndex:
    begin
      ai := GetAttribIndex('a_BlendIndex' + IntToStr(IndBlendIndex));
      if ai > -1 then
      begin
        _BoundAttribs.Add(ai);
        glEnableVertexAttribArray(ai);
        glVertexAttribPointer(ai, _Decl[i].Count, GL_FLOAT, False, _VertexSize, Pointer(VBPos));
      end;
      Inc(IndBlendIndex);
      Inc(VBPos, _Decl[i].Count * 4);
    end;
    else
    begin
      Inc(VBPos, _Decl[i].Count * 4);
    end;
  end;
end;
{$endif}

procedure TG2VertexBuffer.Unbind;
{$if defined(G2RM_FF)}
  var i: TG2IntS32;
  var CurTexture: TG2IntU32;
begin
  CurTexture := GL_TEXTURE0;
  for i := 0 to High(_Decl) do
  begin
    case _Decl[i].Element of
      vbPosition:
      begin
        glDisableClientState(GL_VERTEX_ARRAY);
      end;
      vbNormal:
      begin
        glDisableClientState(GL_NORMAL_ARRAY);
      end;
      vbDiffuse:
      begin
        glDisableClientState(GL_COLOR_ARRAY);
      end;
      vbTexCoord:
      begin
        glClientActiveTexture(CurTexture);
        Inc(CurTexture);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      end;
    end;
  end;
  glClientActiveTexture(GL_TEXTURE0);
end;
{$elseif defined(G2RM_SM2)}
  var i: TG2IntS32;
begin
  for i := 0 to _BoundAttribs.Count - 1 do
  glDisableVertexAttribArray(_BoundAttribs[i]);
  _BoundAttribs.Clear;
end;
{$endif}

constructor TG2VertexBuffer.Create(const Decl: TG2VBDecl; const Count: TG2IntU32);
begin
  _Gfx := TG2GfxOGL(g2.Gfx);
  _Decl := Decl;
  _VertexCount := Count;
  inherited Create;
end;
{$elseif defined(G2Gfx_GLES)}
function TG2VertexBuffer.GetTexCoordIndex(const Index: TG2IntS32): Pointer;
begin
  Result := _TexCoordIndex[Index];
end;

procedure TG2VertexBuffer.WriteBufferData;
begin
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  glBufferSubData(GL_ARRAY_BUFFER, PGLInt(0), _VertexCount * _VertexSize, Data);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
end;

procedure TG2VertexBuffer.Initialize;
  var i, ti: TG2IntS32;
begin
  inherited Initialize;
  _VertexSize := 0;
  ti := 0;
  for i := 0 to High(_Decl) do
  if _Decl[i].Element <> vbNone then
  begin
    if _Decl[i].Element = vbTexCoord then
    begin
      {$Hints off}
      _TexCoordIndex[ti] := Pointer(_VertexSize);
      {$Hints on}
      Inc(ti);
    end;
    _VertexSize := _VertexSize + TG2IntU32(_Decl[i].Count * 4);
  end;
  for i := ti to High(_TexCoordIndex) do
  _TexCoordIndex[i] := nil;
  Allocate(_VertexCount * _VertexSize);
  glGenBuffers(1, @_VB);
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  glBufferData(GL_ARRAY_BUFFER, _VertexCount * _VertexSize, nil, GL_STATIC_DRAW);
  _Locked := False;
end;

procedure TG2VertexBuffer.Finalize;
begin
  glDeleteBuffers(1, @_VB);
  Release;
  inherited Finalize;
end;

procedure TG2VertexBuffer.Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
begin
  if _Locked then UnLock;
  _LockMode := LockMode;
  _Locked := True;
end;

procedure TG2VertexBuffer.UnLock;
begin
  if not _Locked then Exit;
  case _LockMode of
    lmReadWrite: WriteBufferData;
  end;
  _Locked := False;
end;

procedure TG2VertexBuffer.Bind;
  var i: TG2IntS32;
  var BufferPos: TG2IntU32;
  var CurTexture: TG2IntU32;
begin
  glBindBuffer(GL_ARRAY_BUFFER, _VB);
  BufferPos := 0;
  CurTexture := GL_TEXTURE0;
  for i := 0 to High(_Decl) do
  begin
    case _Decl[i].Element of
      vbPosition:
      begin
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(_Decl[i].Count, GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      vbNormal:
      begin
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      vbDiffuse:
      begin
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(_Decl[i].Count, GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      vbTexCoord:
      begin
        glClientActiveTexture(CurTexture);
        Inc(CurTexture);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(_Decl[i].Count, GL_FLOAT, _VertexSize, {$Hints off}PGLVoid(BufferPos){$Hints on});
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
      else
      begin
        Inc(BufferPos, _Decl[i].Count * 4);
      end;
    end;
  end;
  glClientActiveTexture(GL_TEXTURE0);
end;

procedure TG2VertexBuffer.Unbind;
  var i: TG2IntS32;
  var CurTexture: TG2IntU32;
begin
  CurTexture := GL_TEXTURE0;
  for i := 0 to High(_Decl) do
  begin
    case _Decl[i].Element of
      vbPosition:
      begin
        glDisableClientState(GL_VERTEX_ARRAY);
      end;
      vbNormal:
      begin
        glDisableClientState(GL_NORMAL_ARRAY);
      end;
      vbDiffuse:
      begin
        glDisableClientState(GL_COLOR_ARRAY);
      end;
      vbTexCoord:
      begin
        glClientActiveTexture(CurTexture);
        Inc(CurTexture);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      end;
    end;
  end;
  glClientActiveTexture(GL_TEXTURE0);
  glBindBuffer(GL_ARRAY_BUFFER, 0);
end;

constructor TG2VertexBuffer.Create(const Decl: TG2VBDecl; const Count: TG2IntU32);
begin
  _Gfx := TG2GfxGLES(g2.Gfx);
  _Decl := Decl;
  _VertexCount := Count;
  inherited Create;
end;
{$endif}
//TG2VertexBuffer END

//TG2IndexBuffer BEGIN
{$if defined(G2Gfx_D3D9)}
procedure TG2IndexBuffer.WriteBufferData;
  var IBData: Pointer;
begin
  _IB.Lock(0, _IndexCount * 2, IBData, D3DLOCK_DISCARD);
  Move(Data^, IBData^, _IndexCount * 2);
  _IB.Unlock;
end;

procedure TG2IndexBuffer.Initialize;
begin
  _Locked := False;
  _LockMode := lmNone;
  Allocate(_IndexCount * 2);
  _Gfx.Device.CreateIndexBuffer(
    _IndexCount * 2, D3DUSAGE_WRITEONLY,
    D3DFMT_INDEX16, D3DPOOL_MANAGED,
    _IB, nil
  );
end;

procedure TG2IndexBuffer.Finalize;
begin
  SafeRelease(_IB);
  Release;
end;

procedure TG2IndexBuffer.Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
begin
  if _Locked then UnLock;
  _LockMode := LockMode;
  _Locked := True;
end;

procedure TG2IndexBuffer.UnLock;
begin
  if not _Locked then Exit;
  case _LockMode of
    lmReadWrite: WriteBufferData;
  end;
  _Locked := False;
end;

procedure TG2IndexBuffer.Bind;
begin
  _Gfx.Device.SetIndices(_IB);
end;

procedure TG2IndexBuffer.Unbind;
begin

end;

constructor TG2IndexBuffer.Create(const Count: TG2IntU32);
begin
  _Gfx := TG2GfxD3D9(g2.Gfx);
  _IndexCount := Count;
  inherited Create;
end;
{$elseif defined(G2Gfx_OGL)}
procedure TG2IndexBuffer.WriteBufferData;
begin
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _IB);
  glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, _IndexCount * 2, Data);
end;

procedure TG2IndexBuffer.Initialize;
begin
  inherited Initialize;
  _Locked := False;
  _LockMode := lmNone;
  Allocate(_IndexCount * 2);
  glGenBuffers(1, @_IB);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _IB);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, _IndexCount * 2, nil, GL_STATIC_DRAW);
end;

procedure TG2IndexBuffer.Finalize;
begin
  glDeleteBuffers(1, @_IB);
  Release;
  inherited Finalize;
end;

procedure TG2IndexBuffer.Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
begin
  if _Locked then UnLock;
  _LockMode := LockMode;
  _Locked := True;
end;

procedure TG2IndexBuffer.UnLock;
begin
  if not _Locked then Exit;
  case _LockMode of
    lmReadWrite: WriteBufferData;
  end;
  _Locked := False;
end;

procedure TG2IndexBuffer.Bind;
begin
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _IB);
end;

procedure TG2IndexBuffer.Unbind;
begin

end;

constructor TG2IndexBuffer.Create(const Count: TG2IntU32);
begin
  _Gfx := TG2GfxOGL(g2.Gfx);
  _IndexCount := Count;
  inherited Create;
end;
{$elseif defined(G2Gfx_GLES)}
procedure TG2IndexBuffer.WriteBufferData;
begin
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _IB);
  glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, PGLInt(0), _IndexCount * 2, Data);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
end;

procedure TG2IndexBuffer.Initialize;
begin
  inherited Initialize;
  _Locked := False;
  _LockMode := lmNone;
  Allocate(_IndexCount * 2);
  glGenBuffers(1, @_IB);
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _IB);
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, _IndexCount * 2, nil, GL_STATIC_DRAW);
end;

procedure TG2IndexBuffer.Finalize;
begin
  glDeleteBuffers(1, @_IB);
  Release;
  inherited Finalize;
end;

procedure TG2IndexBuffer.Lock(const LockMode: TG2BufferLockMode = lmReadWrite);
begin
  if _Locked then UnLock;
  _LockMode := LockMode;
  _Locked := True;
end;

procedure TG2IndexBuffer.UnLock;
begin
  if not _Locked then Exit;
  case _LockMode of
    lmReadWrite: WriteBufferData;
  end;
  _Locked := False;
end;

procedure TG2IndexBuffer.Bind;
begin
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _IB);
end;

procedure TG2IndexBuffer.Unbind;
begin
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
end;

constructor TG2IndexBuffer.Create(const Count: TG2IntU32);
begin
  _Gfx := TG2GfxGLES(g2.Gfx);
  _IndexCount := Count;
  inherited Create;
end;
{$endif}
//TG2IndexBuffer END

//TG2Font BEGIN
procedure TG2Font.Initialize;
begin
  _Texture := TG2Texture2D.Create;
end;

procedure TG2Font.Finalize;
begin
  _Texture.Free;
end;

function TG2Font.TextWidth(const Text: AnsiString): TG2IntS32;
  var i: TG2IntS32;
begin
  Result := 0;
  for i := 1 to Length(Text) do
  Result := Result + _Props[Ord(Text[i])].Width;
end;

function TG2Font.TextWidth(const Text: AnsiString; const PosStart, PosEnd: TG2IntS32): TG2IntS32;
  var i: TG2IntS32;
begin
  Result := 0;
  for i := PosStart to G2Min(PosEnd, Length(Text)) do
  Result := Result + _Props[Ord(Text[i])].Width;
end;

function TG2Font.TextHeight(const Text: AnsiString): TG2IntS32;
  var i: TG2IntS32;
  var b: TG2IntU8;
begin
  Result := 0;
  for i := 1 to Length(Text) do
  begin
    b := Ord(Text[i]);
    if _Props[b].Height > Result then
    Result := _Props[b].Height;
  end;
end;

procedure TG2Font.Make(const Size: TG2IntS32; const Face: AnsiString = {$ifdef G2Target_Linux}'Serif'{$else}'Times New Roman'{$endif});
{$if defined(G2Target_Windows)}
  type TARGB = packed record
    b, g, r, a: TG2IntU8;
  end;
  type TARGBArr = array[Word] of TARGB;
  type PARGBArr = ^TARGBArr;
  var dc: HDC;
  var Font: HFont;
  var Bitmap: HBitmap;
  var bmi: TBitmapInfo;
  var BitmapBits: Pointer;
  var i, x, y: TG2IntS32;
  var MapWidth, MapHeight: TG2IntS32;
  var TexWidth, TexHeight: TG2IntS32;
  var MaxWidth, MaxHeight: TG2IntS32;
  var CharSize: TSize;
  {$ifdef G2Gfx_D3D9}
  var lr: TD3DLockedRect;
  {$else}
  var TextureData: Pointer;
  {$endif}
begin
  {$ifdef G2Gfx_D3D9}
  MaxWidth := TG2GfxD3D9(g2.Gfx).Caps.MaxTextureWidth; if MaxWidth > 2048 then MaxWidth := 2048;
  MaxHeight := TG2GfxD3D9(g2.Gfx).Caps.MaxTextureHeight; if MaxHeight > 2048 then MaxHeight := 2048;
  {$else}
  MaxWidth := 2048; MaxHeight := 2048;
  {$endif}
  dc := CreateCompatibleDC(0);
  SetMapMode(dc, MM_TEXT);
  Font := CreateFontA(
    Size, 0, 0, 0,
    FW_NORMAL, 0, 0, 0,
    DEFAULT_CHARSET,
    OUT_DEFAULT_PRECIS,
    CLIP_DEFAULT_PRECIS,
    ANTIALIASED_QUALITY,
    VARIABLE_PITCH,
    PAnsiChar(Face)
  );
  SelectObject(dc, Font);
  _CharSpaceX := 0;
  _CharSpaceY := 0;
  for i := 0 to 255 do
  begin
    {$Hints off}
    GetTextExtentPoint32A(dc, PAnsiChar(@i), 1, CharSize);
    {$Hints on}
    if CharSize.cx > _CharSpaceX then _CharSpaceX := CharSize.cx;
    if CharSize.cy > _CharSpaceY then _CharSpaceY := CharSize.cy;
  end;
  MapWidth := TG2IntS32(_CharSpaceX * 16);
  MapHeight := TG2IntS32(_CharSpaceY * 16);
  TexWidth := 1; while TexWidth < MapWidth do TexWidth := TexWidth shl 1; if TexWidth > MaxWidth then TexWidth := MaxWidth;
  TexHeight := 1; while TexHeight < MapHeight do TexHeight := TexHeight shl 1; if TexHeight > MaxHeight then TexHeight := MaxHeight;
  _CharSpaceX := TexWidth div 16;
  _CharSpaceY := TexHeight div 16;
  ZeroMemory(@bmi.bmiHeader, SizeOf(TBitmapInfoHeader));
  bmi.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  bmi.bmiHeader.biWidth :=  TexWidth;
  bmi.bmiHeader.biHeight := -TexHeight;
  bmi.bmiHeader.biPlanes := 1;
  bmi.bmiHeader.biCompression := BI_RGB;
  bmi.bmiHeader.biBitCount := 32;
  {$Hints off}
  Bitmap := CreateDIBSection(
    dc,
    bmi,
    DIB_RGB_COLORS,
    Pointer(BitmapBits),
    0, 0
  );
  {$Hints on}
  SelectObject(dc, Bitmap);
  SetTextColor(dc, $ffffff);
  SetBkColor(dc, $00000000);
  SetTextAlign(dc, TA_TOP);
  for y := 0 to 15 do
  for x := 0 to 15 do
  begin
    i := x + y * 16;
    GetTextExtentPoint32A(dc, PAnsiChar(@i), 1, CharSize);
    _Props[i].Width := CharSize.cx;
    _Props[i].Height := CharSize.cy;
    _Props[i].OffsetX := (_CharSpaceX - _Props[i].Width) div 2;
    _Props[i].OffsetY := (_CharSpaceY - _Props[i].Height) div 2;
    ExtTextOut(
      dc,
      x * _CharSpaceX + _Props[i].OffsetX,
      y * _CharSpaceY + _Props[i].OffsetY,
      ETO_OPAQUE,
      nil,
      PAnsiChar(@i),
      1,
      nil
    );
  end;
  {$ifdef G2Gfx_D3D9}
  TG2GfxD3D9(g2.Gfx).Device.CreateTexture(
    TexWidth, TexHeight, 1, 0,
    D3DFMT_A8R8G8B8,
    D3DPOOL_MANAGED,
    IDirect3DTexture9(_Texture._Texture),
    nil
  );
  _Texture.GetTexture.LockRect(0, lr, nil, D3DLOCK_DISCARD);
  for y := 0 to TexWidth - 1 do
  for x := 0 to TexHeight - 1 do
  begin
    i := y * TexWidth + x;
    PARGBArr(lr.pBits)^[i].a := PARGBArr(BitmapBits)^[i].r;
    PARGBArr(lr.pBits)^[i].r := $ff;
    PARGBArr(lr.pBits)^[i].g := $ff;
    PARGBArr(lr.pBits)^[i].b := $ff;
  end;
  _Texture.GetTexture.UnlockRect(0);
  {$else}
  GetMem(TextureData, TexWidth * TexHeight * 4);
  for y := 0 to TexWidth - 1 do
  for x := 0 to TexHeight - 1 do
  begin
    i := y * TexWidth + x;
    PARGBArr(TextureData)^[i].a := PARGBArr(BitmapBits)^[i].r;
    PARGBArr(TextureData)^[i].r := $ff;
    PARGBArr(TextureData)^[i].g := $ff;
    PARGBArr(TextureData)^[i].b := $ff;
  end;
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, @_Texture._Texture);
  glBindTexture(GL_TEXTURE_2D, _Texture._Texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA,
    TexWidth,
    TexHeight,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    TextureData
  );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  FreeMem(TextureData, TexWidth * TexHeight * 4);
  {$endif}
  DeleteObject(Font);
  DeleteObject(Bitmap);
  DeleteDC(dc);
{$elseif defined(G2Target_Linux)}
  type TARGB = packed record
    b, g, r, a: TG2IntU8;
  end;
  type PARGB = ^TARGB;
  type TARGBArr = array[Word] of TARGB;
  type PARGBArr = ^TARGBArr;
  var TexWidth, TexHeight: TG2IntS32;
  var MaxWidth, MaxHeight: TG2IntS32;
  var MapWidth, MapHeight: TG2IntS32;
  var Pixmap: PGdkPixmap;
  var Image: PGdkImage;
  var Context: PPangoContext;
  var FontDesc: PPangoFontDescription;
  var Layout: PPangoLayout;
  var fg, bg: PGdkGC;
  var TextureData: Pointer;
  var x, y, i: TG2IntS32;
  var p: TG2IntU32;
  function MakeColor(const r, g, b: Word): PGdkGC;
    var Values: TGdkGCValues;
    var Color: TGdkColor;
  begin
    Color.pixel := 0; Color.red := r; Color.green := g; Color.blue := b;
    gdk_colormap_alloc_color(gdk_colormap_get_system(), @Color, False, True);
    Values.foreground := color;
    Result := gdk_gc_new_with_values(Pixmap, @Values, GDK_GC_FOREGROUND);
  end;
begin
  FontDesc := pango_font_description_from_string(PAnsiChar(Face + ' ' + IntToStr(Size)));
  Context := gdk_pango_context_get;
  Layout := pango_layout_new(Context);
  pango_layout_set_font_description(Layout, FontDesc);
  _CharSpaceX := 0;
  _CharSpaceY := 0;
  for i := 0 to 255 do
  begin
    pango_layout_set_text(Layout, PAnsiChar(@i), 1);
    pango_layout_get_size(Layout, @_Props[i].Width, @_Props[i].Height);
    _Props[i].Width := _Props[i].Width div (PANGO_SCALE);
    _Props[i].Height := _Props[i].Height div (PANGO_SCALE);
    if _CharSpaceX < _Props[i].Width then _CharSpaceX := _Props[i].Width;
    if _CharSpaceY < _Props[i].Height then _CharSpaceY := _Props[i].Height;
  end;
  MaxWidth := 2048; MaxHeight := 2048;
  MapWidth := TG2IntS32(_CharSpaceX * 16);
  MapHeight := TG2IntS32(_CharSpaceY * 16);
  TexWidth := 1; while TexWidth < MapWidth do TexWidth := TexWidth shl 1; if TexWidth > MaxWidth then TexWidth := MaxWidth;
  TexHeight := 1; while TexHeight < MapHeight do TexHeight := TexHeight shl 1; if TexHeight > MaxHeight then TexHeight := MaxHeight;
  _CharSpaceX := TexWidth div 16;
  _CharSpaceY := TexHeight div 16;
  Pixmap := gdk_pixmap_new(nil, TexWidth, TexHeight, 24);
  bg := MakeColor(0, 0, 0);
  fg := MakeColor($ffff, $ffff, $ffff);
  gdk_draw_rectangle(Pixmap, bg, 1, 0, 0, TexWidth, TexHeight);
  for y := 0 to 15 do
  for x := 0 to 15 do
  begin
    i := x + y * 16;
    _Props[i].OffsetX := (_CharSpaceX - _Props[i].Width) div 2;
    _Props[i].OffsetY := (_CharSpaceY - _Props[i].Height) div 2;
    pango_layout_set_text(Layout, PAnsiChar(@i), 1);
    gdk_draw_layout(
      Pixmap, fg,
      x * _CharSpaceX + _Props[i].OffsetX,
      y * _CharSpaceY + _Props[i].OffsetY,
      Layout
    );
  end;
  Image := gdk_image_get(Pixmap, 0, 0, TexWidth, TexHeight);
  GetMem(TextureData, TexWidth * TexHeight * 4);
  for y := 0 to TexHeight - 1 do
  for x := 0 to TexWidth - 1 do
  begin
    i := y * TexWidth + x;
    p := gdk_image_get_pixel(Image, x, y);
    PARGBArr(TextureData)^[i].a := PARGB(@p)^.r;
    PARGBArr(TextureData)^[i].r := $ff;
    PARGBArr(TextureData)^[i].g := $ff;
    PARGBArr(TextureData)^[i].b := $ff;
  end;
  gdk_image_destroy(Image);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, @_Texture._Texture);
  glBindTexture(GL_TEXTURE_2D, _Texture._Texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA,
    TexWidth,
    TexHeight,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    TextureData
  );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  FreeMem(TextureData, TexWidth * TexHeight * 4);
{$elseif defined(G2Target_OSX)}
  type TARGB = packed record
    b, g, r, a: TG2IntU8;
  end;
  type TARGBArr = array[Word] of TARGB;
  type PARGBArr = ^TARGBArr;
  var MaxWidth, MaxHeight: TG2IntS32;
  var TexWidth, TexHeight: TG2IntS32;
  var MapWidth, MapHeight: TG2IntS32;
  var Context: CGContextRef;
  var ContextData: Pointer;
  var ContextDataSize: TG2IntS32;
  var Font: CTFontRef;
  var ColorSpace: CGColorSpaceRef;
  var Chars: array [0..255] of UniChar;
  var Glyphs: array[0..255] of CGGlyph;
  var GlyphRects: array[0..255] of CGRect;
  var x, y, i, MaxCharHeight: TG2IntS32;
begin
  for i := 0 to 255 do
  Chars[i] := i;
  Font := CTFontCreateWithName(CFSTR(PAnsiChar(Face)), Size, nil);
  CTFontGetGlyphsForCharacters(Font, @Chars, @Glyphs, 256);
  CTFontGetBoundingRectsForGlyphs(Font, kCTFontDefaultOrientation, @Glyphs, @GlyphRects, 256);
  CFRelease(Font);
  _CharSpaceX := 0;
  _CharSpaceY := 0;
  for i := 0 to 255 do
  begin
    _Props[i].Width := Round(GlyphRects[i].size.width + 2);
    _Props[i].Height := Round(GlyphRects[i].size.height + 2);
    if _CharSpaceX < _Props[i].Width then _CharSpaceX := _Props[i].Width;
    if _CharSpaceY < _Props[i].Height then _CharSpaceY := _Props[i].Height;
  end;
  MaxWidth := 2048; MaxHeight := 2048;
  MaxCharHeight := _CharSpaceY;
  MapWidth := TG2IntS32(_CharSpaceX * 16);
  MapHeight := TG2IntS32(_CharSpaceY * 16);
  TexWidth := 1; while TexWidth < MapWidth do TexWidth := TexWidth shl 1; if TexWidth > MaxWidth then TexWidth := MaxWidth;
  TexHeight := 1; while TexHeight < MapHeight do TexHeight := TexHeight shl 1; if TexHeight > MaxHeight then TexHeight := MaxHeight;
  _CharSpaceX := TexWidth div 16;
  _CharSpaceY := TexHeight div 16;
  ContextDataSize := TexWidth * 4 * TexHeight;
  Getmem(ContextData, ContextDataSize);
  ColorSpace := CGColorSpaceCreateDeviceRGB;
  Context := CGBitmapContextCreate(
    ContextData, TexWidth, TexHeight, 8, TexWidth * 4,
    ColorSpace, kCGImageAlphaNoneSkipLast
  );
  FillChar(ContextData^, ContextDataSize, $ff);
  for i := 0 to ContextDataSize div 4 do
  PARGBArr(ContextData)^[i].a := 0;
  CGContextSetRGBFillColor(Context, 1, 1, 1, 1);
  CGContextSelectFont(Context, PAnsiChar(Face), Size, kCGEncodingMacRoman);
  for y := 0 to 15 do
  for x := 0 to 15 do
  begin
    i := x + y * 16;
    _Props[i].OffsetX := (_CharSpaceX - _Props[i].Width) div 2;
    _Props[i].OffsetY := (_CharSpaceY - _Props[i].Height) div 2;
    CGContextShowTextAtPoint(
      Context,
      x * _CharSpaceX + _Props[i].OffsetX,
      TexHeight - (y + 1) * _CharSpaceY + MaxCharHeight div 8,
      PAnsiChar(@i), 1
    );
  end;
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, @_Texture._Texture);
  glBindTexture(GL_TEXTURE_2D, _Texture._Texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA,
    TexWidth,
    TexHeight,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    ContextData
  );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  CGContextRelease(Context);
  CGColorSpaceRelease(ColorSpace);
  Freemem(ContextData, ContextDataSize);
{$elseif defined(G2Target_Android)}
{$Hints off}
  type TARGB = packed record
    b, g, r, a: TG2IntU8;
  end;
  type TARGBArr = array[Word] of TARGB;
  type PARGBArr = ^TARGBArr;
  var TexWidth, TexHeight: TG2IntS32;
  var Data: Pointer;
  var CharWidths: array[0..255] of TG2IntS32;
  var CharHeights: array[0..255] of TG2IntS32;
  var i: TG2IntS32;
begin
  {$Hints off}
  AndroidBinding.FontMake(Data, TexWidth, TexHeight, Size, @CharWidths, @CharHeights);
  {$Hints on}
  for i := 0 to TexWidth * TexHeight - 1 do
  begin
    PARGBArr(Data)^[i].a := PARGBArr(Data)^[i].r;
    PARGBArr(Data)^[i].r := 255;
    PARGBArr(Data)^[i].g := 255;
    PARGBArr(Data)^[i].b := 255;
  end;
  _CharSpaceX := TexWidth div 16;
  _CharSpaceY := TexHeight div 16;
  for i := 0 to 255 do
  begin
    _Props[i].Width := CharWidths[i];
    _Props[i].Height := CharHeights[i];
    _Props[i].OffsetX := (_CharSpaceX - _Props[i].Width) div 2;
    _Props[i].OffsetY := (_CharSpaceY - _Props[i].Height) div 2;
  end;
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, @_Texture._Texture);
  glBindTexture(GL_TEXTURE_2D, _Texture._Texture);
  glTexImage2D(
    GL_TEXTURE_2D,
    0,
    GL_RGBA,
    TexWidth,
    TexHeight,
    0,
    GL_RGBA,
    GL_UNSIGNED_BYTE,
    Data
  );
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  FreeMem(Data, TexWidth * TexHeight * 4);
{$Hints on}
{$elseif defined(G2Target_iOS)}
  var TexWidth, TexHeight: TG2IntS32;
begin
  TexWidth := 0;
  TexHeight := 0;
{$else}
begin
{$endif}
  _Texture._RealWidth := TexWidth;
  _Texture._RealHeight := TexHeight;
  _Texture._Width := TexWidth;
  _Texture._Height := TexHeight;
  _Texture._SizeTU := 1;
  _Texture._SizeTV := 1;
end;

procedure TG2Font.Load(const Stream: TStream);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(Stream);
  try
    Load(dm);
  finally
    dm.Free;
  end;
end;

procedure TG2Font.Load(const FileName: FileString);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(FileName, dmAsset);
  try
    Load(dm);
  finally
    dm.Free;
  end;
end;

procedure TG2Font.Load(const Buffer: Pointer; const Size: TG2IntS32);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(Buffer, Size);
  try
    Load(dm);
  finally
    dm.Free;
  end;
end;

procedure TG2Font.Load(const DataManager: TG2DataManager);
  type TCharProp = packed record
    Width: TG2IntU8;
    Height: TG2IntU8;
  end;
  type TG2FontFile = packed record
    Definition: array[0..3] of AnsiChar;
    Version: TG2IntU32;
    FontFace: AnsiString;
    FontSize: TG2IntS32;
    DataSize: TG2IntS64;
    Chars: array[0..255] of TCharProp;
  end;
  const Definition: array[0..3] of AnsiChar = 'G2F ';
  const Version = $00010001;
  var Header: TG2FontFile;
  var b: TG2IntU8;
  var i: TG2IntS32;
begin
  if DataManager.Size - DataManager.Position < 8 then Exit;
  {$Hints off}
  DataManager.ReadBuffer(@Header.Definition, 4);
  if (Header.Definition <> Definition) then Exit;
  DataManager.ReadBuffer(@Header.Version, 4);
  if Header.Version <> Version then Exit;
  Header.FontFace := '';
  repeat b := DataManager.ReadIntU8; Header.FontFace := Header.FontFace + Chr(b) until b = 0;
  DataManager.ReadBuffer(@Header.FontSize, SizeOf(Header.FontSize));
  DataManager.ReadBuffer(@Header.DataSize, SizeOf(Header.DataSize));
  DataManager.ReadBuffer(@Header.Chars, SizeOf(Header.Chars));
  {$Hints on}
  Texture.Load(DataManager);
  _CharSpaceX := _Texture.Width div 16;
  _CharSpaceY := _Texture.Height div 16;
  for i := 0 to 255 do
  begin
    _Props[i].Width := Header.Chars[i].Width;
    _Props[i].Height := Header.Chars[i].Height;
    _Props[i].OffsetX := (_CharSpaceX - _Props[i].Width) div 2;
    _Props[i].OffsetY := (_CharSpaceY - _Props[i].Height) div 2;
  end;
end;

procedure TG2Font.Print(
  const x, y, ScaleX, ScaleY: TG2Float;
  const Color: TG2Color;
  const Text: AnsiString;
  const BlendMode: TG2BlendMode;
  const Filter: TG2Filter;
  const Display: TG2Display2D = nil
);
  var i: TG2IntS32;
  var c: TG2IntU8;
  var tu1, tv1, tu2, tv2: TG2Float;
  var x1, y1, x2, y2: TG2Float;
  var CharTU, CharTV, CurPos: TG2Float;
begin
  CharTU := _CharSpaceX / _Texture.RealWidth;
  CharTV := _CharSpaceY / _Texture.RealHeight;
  CurPos := x;
  for i := 0 to Length(Text) - 1 do
  begin
    c := Ord(Text[i + 1]);
    tu1 := (c mod 16) * CharTU;
    tv1 := (c div 16) * CharTV;
    tu2 := tu1 + CharTU;
    tv2 := tv1 + CharTV;
    x1 := CurPos - _Props[c].OffsetX * ScaleX;
    y1 := y - _Props[c].OffsetY * ScaleY;
    x2 := x1 + _CharSpaceX * ScaleX;
    y2 := y1 + _CharSpaceY * ScaleY;
    CurPos := CurPos + _Props[c].Width * ScaleX;
    if Display <> nil then
    Display.PicQuadCol(
      x1, y1, x2, y1,
      x1, y2, x2, y2,
      tu1, tv1, tu2, tv1,
      tu1, tv2, tu2, tv2,
      Color, Color, Color, Color,
      _Texture,
      BlendMode, Filter
    )
    else
    g2.PicQuadCol(
      x1, y1, x2, y1,
      x1, y2, x2, y2,
      tu1, tv1, tu2, tv1,
      tu1, tv2, tu2, tv2,
      Color, Color, Color, Color,
      _Texture,
      BlendMode, Filter
    );
  end;
end;

procedure TG2Font.Print(
  const x, y, ScaleX, ScaleY: TG2Float;
  const Text: AnsiString;
  const BlendMode: TG2BlendMode;
  const Filter: TG2Filter;
  const Display: TG2Display2D = nil
);
begin
  Print(x, y, ScaleX, ScaleY, $ffffffff, Text, BlendMode, Filter, Display);
end;

procedure TG2Font.Print(
  const x, y, ScaleX, ScaleY: TG2Float;
  const Text: AnsiString;
  const Display: TG2Display2D = nil
);
begin
  Print(x, y, ScaleX, ScaleY, Text, bmNormal, tfPoint, Display);
end;

procedure TG2Font.Print(
  const x, y: TG2Float;
  const Text: AnsiString;
  const Display: TG2Display2D = nil
);
begin
  Print(x, y, 1, 1, Text, Display);
end;
//TG2Font END

{$if defined(G2RM_SM2)}
//TG2ShaderGroup BEGIN
function TG2ShaderGroup.GetMethod: AnsiString;
begin
  if (_Method > -1) and (_Method < _Methods.Count) then
  Result := PG2ShaderMethod(_Methods[_Method])^.Name;
end;

procedure TG2ShaderGroup.SetMethod(const Value: AnsiString);
  var i, n: TG2IntS32;
  {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
  var p: GLHandle;
  {$endif}
begin
  n := -1;
  for i := 0 to _Methods.Count - 1 do
  if PG2ShaderMethod(_Methods[i])^.Name = Value then
  begin
    n := i;
    Break;
  end;
  _Method := n;
  if _Method > -1 then
  begin
    _Gfx.ShaderMethod := PG2ShaderMethod(_Methods[_Method]);
  end
  else
  begin
    _Gfx.ShaderMethod := nil;
  end;
end;

{$if defined(G2RM_SM2)}
{$if defined(G2Gfx_D3D9)}
function TG2ShaderGroup.ParamVS(const Name: AnsiString): TG2IntS32;
  var i: TG2IntS32;
begin
  if _Method = -1 then Exit;
  for i := 0 to High(PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params) do
  if PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[i].Name = Name then
  begin
    Result := i;
    Exit;
  end;
  Result := -1;
end;

function TG2ShaderGroup.ParamPS(const Name: AnsiString): TG2IntS32;
  var i: TG2IntS32;
begin
  if _Method = -1 then Exit;
  for i := 0 to High(PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params) do
  if PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[i].Name = Name then
  begin
    Result := i;
    Exit;
  end;
  Result := -1;
end;
{$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
function TG2ShaderGroup.Param(const Name: AnsiString): GLInt;
begin
  Result := glGetUniformLocation(PG2ShaderMethod(_Methods[_Method])^.ShaderProgram, PAnsiChar(Name));
end;
{$endif}
{$endif}

procedure TG2ShaderGroup.Initialize;
begin
  _Gfx := {$if defined(G2Gfx_D3D9)}TG2GfxD3D9{$elseif defined(G2Gfx_OGL)}TG2GfxOGL{$elseif defined(G2Gfx_GLES)}TG2GfxGLES{$endif}(g2.Gfx);
  _Methods.Clear;
  _VertexShaders.Clear;
  _PixelShaders.Clear;
  _Method := -1;
end;

procedure TG2ShaderGroup.Finalize;
begin
  Clear;
end;

procedure TG2ShaderGroup.Load(const Stream: TStream);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(Stream, dmRead);
  try
    Load(dm);
  finally
    dm.Free;
  end;
end;

procedure TG2ShaderGroup.Load(const FileName: FileString);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(FileName, dmAsset);
  try
    Load(dm);
  finally
    dm.Free;
  end;
end;

procedure TG2ShaderGroup.Load(const Buffer: Pointer; const Size: TG2IntS32);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(Buffer, Size, dmRead);
  try
    Load(dm);
  finally
    dm.Free;
  end;
end;

procedure TG2ShaderGroup.Load(const DataManager: TG2DataManager);
  {$if defined(G2Gfx_D3D9)}
  procedure ReadParams(var Params: TG2ShaderParams);
    var i: TG2IntS32;
  begin
    SetLength(Params, DataManager.ReadIntS32);
    for i := 0 to High(Params) do
    begin
      Params[i].ParamType := DataManager.ReadIntU8;
      Params[i].Name := DataManager.ReadStringA;
      Params[i].Pos := DataManager.ReadIntS32;
      Params[i].Size := DataManager.ReadIntS32;
    end;
  end;
  {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
  procedure SkipParams;
    var i, n: TG2IntS32;
    var Str: AnsiString;
  begin
    n := DataManager.ReadIntS32;
    for i := 0 to n - 1 do
    begin
      DataManager.Skip(1);
      Str := DataManager.ReadStringA;
      DataManager.Skip(8);
    end;
  end;
  {$endif}
  type THeader = packed record
    Definition: array[0..3] of AnsiChar;
    Version: TG2IntU16;
    MethodCount: TG2IntS32;
    VertexShaderCount: TG2IntS32;
    PixelShaderCount: TG2IntS32;
  end;
  var Header: THeader;
  var i, n: TG2IntS32;
  var VS: PG2VertexShader;
  var PS: PG2PixelShader;
  var MTD: PG2ShaderMethod;
  var Source: AnsiString;
  {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
  var SourcePtr: Pointer;
  var Errors: AnsiString;
  {$endif}
begin
  Clear;
  DataManager.ReadBuffer(@Header, SizeOf(Header));
  if (Header.Definition <> 'G2SG') or (Header.Version > $0100) then Exit;
  DataManager.Codec := cdZLib;
  for i := 0 to Header.VertexShaderCount - 1 do
  begin
    New(VS);
    VS^.Name := DataManager.ReadStringA;
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    {$if defined(G2Gfx_D3D9)}
    n := DataManager.ReadIntS32;
    SetLength(Source, n);
    DataManager.ReadBuffer(@Source[1], n);
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    _Gfx.Device.CreateVertexShader(@Source[1], VS^.Prog);
    ReadParams(VS^.Params);
    {$elseif defined(G2Gfx_OGL)}
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    n := DataManager.ReadIntS32;
    SetLength(Source, n);
    DataManager.ReadBuffer(@Source[1], n);
    VS^.Prog := glCreateShader(GL_VERTEX_SHADER);
    SourcePtr := @Source[1];
    glShaderSource(VS^.Prog, 1, @SourcePtr, @n);
    glCompileShader(VS^.Prog);
    SkipParams;
    {$endif}
    _VertexShaders.Add(VS);
  end;
  for i := 0 to Header.PixelShaderCount - 1 do
  begin
    New(PS);
    PS^.Name := DataManager.ReadStringA;
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    {$if defined(G2Gfx_D3D9)}
    n := DataManager.ReadIntS32;
    SetLength(Source, n);
    DataManager.ReadBuffer(@Source[1], n);
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    _Gfx.Device.CreatePixelShader(@Source[1], PS^.Prog);
    ReadParams(PS^.Params);
    {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    n := DataManager.ReadIntS32;
    DataManager.Skip(n);
    n := DataManager.ReadIntS32;
    SetLength(Source, n);
    DataManager.ReadBuffer(@Source[1], n);
    PS^.Prog := glCreateShader(GL_FRAGMENT_SHADER);
    SourcePtr := @Source[1];
    glShaderSource(PS^.Prog, 1, @SourcePtr, @n);
    glCompileShader(PS^.Prog);
    SkipParams;
    {$endif}
    _PixelShaders.Add(PS);
  end;
  for i := 0 to Header.MethodCount - 1 do
  begin
    New(MTD);
    MTD^.Name := DataManager.ReadStringA;
    n := DataManager.ReadIntS32;
    MTD^.VertexShader := PG2VertexShader(_VertexShaders[n]);
    n := DataManager.ReadIntS32;
    MTD^.PixelShader := PG2PixelShader(_PixelShaders[n]);
    {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    MTD^.ShaderProgram := glCreateProgram();
    glAttachShader(MTD^.ShaderProgram, MTD^.VertexShader^.Prog);
    glAttachShader(MTD^.ShaderProgram, MTD^.PixelShader^.Prog);
    glLinkProgram(MTD^.ShaderProgram);
    SetLength(Errors, 2048);
    glGetProgramInfoLog(MTD^.ShaderProgram, 2048, n, PAnsiChar(Errors));
    {$endif}
    _Methods.Add(MTD);
  end;
  DataManager.Codec := cdNone;
end;

{$if defined(G2Gfx_D3D9)}
procedure TG2ShaderGroup.UniformMatrix4x4(const Name: AnsiString; const m: TG2Mat);
  var psid, vsid, Size: TG2IntS32;
  var mt: TG2Mat;
begin
  mt := G2MatTranspose(m);
  vsid := ParamVS(Name);
  if vsid > -1 then
  begin
    Size := Min(4, PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Size);
    _Gfx.Device.SetVertexShaderConstantF(PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Pos, @mt, Size);
  end;
  psid := ParamPS(Name);
  if psid > -1 then
  begin
    Size := Min(4, PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Size);
    _Gfx.Device.SetPixelShaderConstantF(PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos, @mt, Size);
  end;
end;

procedure TG2ShaderGroup.UniformMatrix4x4Arr(const Name: AnsiString; const m: PG2Mat; const ArrPos, Count: TG2IntS32);
  var psid, vsid, Pos, i: TG2IntS32;
  var mt: TG2Mat;
  var pm: PG2Mat;
begin
  vsid := ParamVS(Name);
  if vsid > -1 then
  begin
    pm := m;
    Pos := PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Pos + ArrPos * 4;
    for i := 0 to Count - 1 do
    begin
      mt := G2MatTranspose(pm^);
      _Gfx.Device.SetVertexShaderConstantF(Pos, @mt, 4);
      Inc(Pos, 4);
      Inc(pm);
    end;
  end;
  psid := ParamPS(Name);
  if psid > -1 then
  begin
    pm := @m;
    Pos := PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos + ArrPos * 4;
    for i := 0 to Count - 1 do
    begin
      mt := G2MatTranspose(pm^);
      _Gfx.Device.SetPixelShaderConstantF(Pos, @mt, 4);
      Inc(Pos, 4);
      Inc(pm);
    end;
  end;
end;

procedure TG2ShaderGroup.UniformMatrix4x3(const Name: AnsiString; const m: TG2Mat);
  var psid, vsid, Size: TG2IntS32;
  var mt: TG2Mat;
begin
  mt := G2MatTranspose(m);
  vsid := ParamVS(Name);
  if vsid > -1 then
  begin
    Size := Min(3, PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Size);
    _Gfx.Device.SetVertexShaderConstantF(PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Pos, @mt, Size);
  end;
  psid := ParamPS(Name);
  if psid > -1 then
  begin
    Size := Min(3, PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Size);
    _Gfx.Device.SetPixelShaderConstantF(PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos, @mt, Size);
  end;
end;

procedure TG2ShaderGroup.UniformMatrix4x3Arr(const Name: AnsiString; const m: PG2Mat; const ArrPos, Count: TG2IntS32);
  var psid, vsid, Pos, i: TG2IntS32;
  var mt: TG2Mat;
  var pm: PG2Mat;
begin
  vsid := ParamVS(Name);
  if vsid > -1 then
  begin
    pm := m;
    Pos := PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Pos + ArrPos * 3;
    for i := 0 to Count - 1 do
    begin
      mt := G2MatTranspose(pm^);
      _Gfx.Device.SetVertexShaderConstantF(Pos, @mt, 3);
      Inc(Pos, 3);
      Inc(pm);
    end;
  end;
  psid := ParamPS(Name);
  if psid > -1 then
  begin
    pm := m;
    Pos := PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos + ArrPos * 3;
    for i := 0 to Count - 1 do
    begin
      mt := G2MatTranspose(pm^);
      _Gfx.Device.SetPixelShaderConstantF(Pos, @mt, 3);
      Inc(Pos, 3);
      Inc(pm);
    end;
  end;
end;

procedure TG2ShaderGroup.UniformFloat4(const Name: AnsiString; const v: TG2Vec4);
  var psid, vsid, Size: TG2IntS32;
begin
  vsid := ParamVS(Name);
  if vsid > -1 then
  begin
    Size := Min(1, PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Size);
    _Gfx.Device.SetVertexShaderConstantF(PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Pos, @v, Size);
  end;
  psid := ParamPS(Name);
  if psid > -1 then
  begin
    Size := Min(1, PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Size);
    _Gfx.Device.SetPixelShaderConstantF(PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos, @v, Size);
  end;
end;

procedure TG2ShaderGroup.UniformInt1(const Name: AnsiString; const i: TG2IntS32);
  var psid, vsid: TG2IntS32;
  var IntArr: array[0..3] of TG2IntS32;
begin
  {$Hints off}FillChar(IntArr[1], 12, 0);{$Hints on}
  IntArr[0] := i;
  vsid := ParamVS(Name);
  if vsid > -1 then
  begin
    _Gfx.Device.SetVertexShaderConstantI(PG2ShaderMethod(_Methods[_Method])^.VertexShader^.Params[vsid].Pos, @IntArr, 1);
  end;
  psid := ParamPS(Name);
  if psid > -1 then
  begin
    _Gfx.Device.SetPixelShaderConstantI(PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos, @IntArr, 1);
  end;
end;
{$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
procedure TG2ShaderGroup.UniformMatrix4x4(const Name: AnsiString; const m: TG2Mat);
  var shid: GLInt;
begin
  shid := Param(Name);
  if shid > -1 then
  glUniformMatrix4fv(shid, 1, True, @m);
end;

procedure TG2ShaderGroup.UniformMatrix4x4Arr(const Name: AnsiString; const m: PG2Mat; const ArrPos, Count: TG2IntS32);
  var shid: GLInt;
begin
  shid := Param(Name + '[' + IntToStr(ArrPos) + ']');
  if shid > -1 then
  glUniformMatrix4fv(shid, Count, True, PG2Float(m));
end;

procedure TG2ShaderGroup.UniformMatrix4x3(const Name: AnsiString; const m: TG2Mat);
begin
  UniformMatrix4x4(Name, m);
end;

procedure TG2ShaderGroup.UniformMatrix4x3Arr(const Name: AnsiString; const m: PG2Mat; const ArrPos, Count: TG2IntS32);
begin
  UniformMatrix4x4Arr(Name, m, ArrPos, Count);
end;

procedure TG2ShaderGroup.UniformFloat4(const Name: AnsiString; const v: TG2Vec4);
  var shid: GLInt;
begin
  shid := Param(Name);
  if shid > -1 then
  glUniform4fv(shid, 1, @v);
end;

procedure TG2ShaderGroup.UniformInt1(const Name: AnsiString; const i: TG2IntS32);
  var shid: GLInt;
begin
  shid := Param(Name);
  if shid > -1 then
  glUniform1i(shid, i);
end;
{$endif}

procedure TG2ShaderGroup.Sampler(const Name: AnsiString; const Texture: TG2TextureBase{$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}; const Stage: TG2IntS32 = 0{$endif});
{$if defined(G2Gfx_D3D9)}
  var psid: TG2IntS32;
begin
  psid := ParamPS(Name);
  if (psid > -1)
  and (PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].ParamType = 3) then
  begin
    _Gfx.Device.SetTexture(
      PG2ShaderMethod(_Methods[_Method])^.PixelShader^.Params[psid].Pos,
      Texture.BaseTexture
    );
  end;
end;
{$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
  var shid: GLInt;
begin
  shid := Param(Name);
  if shid > -1 then
  begin
    glActiveTexture(GL_TEXTURE0 + Stage);
    glBindTexture(GL_TEXTURE_2D, Texture.BaseTexture);
    glUniform1i(shid, Stage);
  end;
end;
{$endif}

{$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
function TG2ShaderGroup.Attribute(const Name: AnsiString): GLInt;
begin
  if _Method > -1 then
  Result := glGetAttribLocation(PG2ShaderMethod(_Methods[_Method])^.ShaderProgram, Name)
  else
  Result := -1;
end;
{$endif}

procedure TG2ShaderGroup.Clear;
  var i: TG2IntS32;
begin
  for i := 0 to _VertexShaders.Count - 1 do
  begin
    {$if defined(G2Gfx_D3D9)}
    SafeRelease(PG2VertexShader(_VertexShaders[i])^.Prog);
    {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    glDeleteShader(PG2VertexShader(_VertexShaders[i])^.Prog);
    {$endif}
    Dispose(PG2VertexShader(_VertexShaders[i]));
  end;
  _VertexShaders.Clear;
  for i := 0 to _PixelShaders.Count - 1 do
  begin
    {$if defined(G2Gfx_D3D9)}
    SafeRelease(PG2PixelShader(_PixelShaders[i])^.Prog);
    {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    glDeleteShader(PG2PixelShader(_PixelShaders[i])^.Prog);
    {$endif}
    Dispose(PG2PixelShader(_PixelShaders[i]));
  end;
  _PixelShaders.Clear;
  for i := 0 to _Methods.Count - 1 do
  begin
    {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
    glDeleteProgram(PG2ShaderMethod(_Methods[i])^.ShaderProgram);
    {$endif}
    Dispose(PG2ShaderMethod(_Methods[i]));
  end;
  _Methods.Clear;
end;
//TG2ShaderGroup END
{$endif}

//TG2RenderControl BEGIN
constructor TG2RenderControl.Create;
begin
  inherited Create;
  _Gfx := {$if defined(G2Gfx_D3D9)}TG2GfxD3D9{$elseif defined(G2Gfx_OGL)}TG2GfxOGL{$elseif defined(G2Gfx_GLES)}TG2GfxGLES{$endif}(g2.Gfx);
  _FillID := @_Gfx._QueueFill;
  _DrawID := @_Gfx._QueueDraw;
end;

destructor TG2RenderControl.Destroy;
begin
  inherited Destroy;
end;
//TG2RenderControl END

//TG2RenderControlStateChange BEGIN
procedure TG2RenderControlStateChange.CheckCapacity;
  var n, i: TG2IntS32;
begin
  if _QueueCount[_FillID^] >= _QueueCapacity[_FillID^] then
  begin
    n := _QueueCapacity[_FillID^];
    _QueueCapacity[_FillID^] := _QueueCapacity[_FillID^] + 128;
    SetLength(_Queue[_FillID^], _QueueCapacity[_FillID^]);
    for i := n to _QueueCapacity[_FillID^] - 1 do
    begin
      New(_Queue[_FillID^][i]);
      _Queue[_FillID^][i]^.DataSize := 0;
    end;
  end;
end;

procedure TG2RenderControlStateChange.StateRenderTargetTexture2D(const RenderTarget: TG2Texture2DRT);
  var StateChange: PG2StateChange;
begin
  CheckCapacity;
  StateChange := _Queue[_FillID^][_QueueCount[_FillID^]];
  StateChange^.StateType := stRenderTarget;
  if StateChange^.DataSize < 4 then
  begin
    if StateChange^.DataSize > 0 then
    FreeMem(StateChange^.Data, StateChange^.DataSize);
    StateChange^.DataSize := 4;
    GetMem(StateChange^.Data, 4);
  end;
  PPointer(StateChange^.Data)^ := RenderTarget;
  _Gfx.AddRenderQueueItem(Self, StateChange);
  g2.Params._WidthRT := RenderTarget.RealWidth;
  g2.Params._HeightRT := RenderTarget.RealHeight;
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlStateChange.StateRenderTargetDefault;
  var StateChange: PG2StateChange;
begin
  CheckCapacity;
  StateChange := _Queue[_FillID^][_QueueCount[_FillID^]];
  StateChange^.StateType := stRenderTarget;
  if StateChange^.DataSize < 4 then
  begin
    if StateChange^.DataSize > 0 then
    FreeMem(StateChange^.Data, StateChange^.DataSize);
    StateChange^.DataSize := 4;
    GetMem(StateChange^.Data, 4);
  end;
  PPointer(StateChange^.Data)^ := nil;
  _Gfx.AddRenderQueueItem(Self, StateChange);
  g2.Params._WidthRT := g2.Params.Width;
  g2.Params._HeightRT := g2.Params.Height;
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlStateChange.StateClear(const Color: TG2Color);
  var StateChange: PG2StateChange;
begin
  CheckCapacity;
  StateChange := _Queue[_FillID^][_QueueCount[_FillID^]];
  StateChange^.StateType := stClear;
  if StateChange^.DataSize < 4 then
  begin
    if StateChange^.DataSize > 0 then
    FreeMem(StateChange^.Data, StateChange^.DataSize);
    StateChange^.DataSize := 4;
    GetMem(StateChange^.Data, 4);
  end;
  PG2Color(StateChange^.Data)^ := Color;
  _Gfx.AddRenderQueueItem(Self, StateChange);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlStateChange.StateScissor(const ScissorRect: PRect);
  var StateChange: PG2StateChange;
begin
  CheckCapacity;
  StateChange := _Queue[_FillID^][_QueueCount[_FillID^]];
  StateChange^.StateType := stScissor;
  if StateChange^.DataSize < SizeOf(TRect) + 1 then
  begin
    if StateChange^.DataSize > 0 then
    FreeMem(StateChange^.Data, StateChange^.DataSize);
    StateChange^.DataSize := SizeOf(TRect) + 1;
    GetMem(StateChange^.Data, SizeOf(TRect) + 1);
  end;
  PG2Bool(StateChange^.Data)^ := ScissorRect <> nil;
  if ScissorRect <> nil then
  PRect(StateChange^.Data + 1)^ := ScissorRect^;
  _Gfx.AddRenderQueueItem(Self, StateChange);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlStateChange.StateDepthEnable(const Enable: Boolean);
  var StateChange: PG2StateChange;
begin
  CheckCapacity;
  StateChange := _Queue[_FillID^][_QueueCount[_FillID^]];
  StateChange^.StateType := stDepthEnable;
  if StateChange^.DataSize < 1 then
  begin
    if StateChange^.DataSize > 0 then
    FreeMem(StateChange^.Data, StateChange^.DataSize);
    StateChange^.DataSize := 1;
    GetMem(StateChange^.Data, 1);
  end;
  PG2Bool(StateChange^.Data)^ := Enable;
  _Gfx.AddRenderQueueItem(Self, StateChange);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlStateChange.RenderBegin;
begin

end;

procedure TG2RenderControlStateChange.RenderEnd;
begin

end;

procedure TG2RenderControlStateChange.RenderData(const Data: Pointer);
  var StateChange: PG2StateChange;
begin
  StateChange := PG2StateChange(Data);
  case StateChange^.StateType of
    stClear:
    begin
      _Gfx.Clear(PG2Color(StateChange^.Data)^);
    end;
    stRenderTarget:
    begin
      _Gfx.SetRenderTarget(TG2Texture2DRT(StateChange^.Data^));
    end;
    stScissor:
    begin
      if PG2Bool(StateChange^.Data)^ then
      _Gfx.SetScissor(PRect(StateChange^.Data + 1))
      else
      _Gfx.SetScissor(nil);
    end;
    stDepthEnable:
    begin
      _Gfx.DepthEnable := PG2Bool(StateChange^.Data)^;
    end;
  end;
end;

procedure TG2RenderControlStateChange.Reset;
begin
  _QueueCount[_FillID^] := 0;
end;

constructor TG2RenderControlStateChange.Create;
begin
  inherited Create;
  _QueueCapacity[0] := 0;
  _QueueCapacity[1] := 0;
  _QueueCount[0] := 0;
  _QueueCount[1] := 0;
end;

destructor TG2RenderControlStateChange.Destroy;
  var n, i: TG2IntS32;
begin
  for n := 0 to 1 do
  for i := 0 to _QueueCapacity[n] - 1 do
  begin
    if _Queue[n][i]^.DataSize > 0 then
    FreeMem(_Queue[n][i]^.Data, _Queue[n][i]^.DataSize);
    Dispose(_Queue[n][i]);
  end;
  inherited Destroy;
end;
//TG2RenderControlStateChange END

//TG2ManagedRenderObject BEGIN
constructor TG2ManagedRenderObject.Create;
begin
  inherited Create;
  _DrawID := g2.Gfx.Managed._DrawID;
  _FillID := g2.Gfx.Managed._FillID;
end;

destructor TG2ManagedRenderObject.Destroy;
begin
  inherited Destroy;
end;

procedure TG2ManagedRenderObject.Render;
begin
  g2.Gfx.Managed.RenderObject(Self);
end;
//TG2ManagedRenderObject END

//TG2RenderControlManaged BEGIN
procedure TG2RenderControlManaged.CheckCapacity;
begin
  if _QueueCount[_FillID^] >= _QueueCapacity[_FillID^] then
  begin
    _QueueCapacity[_FillID^] := _QueueCapacity[_FillID^] + 128;
    SetLength(_Queue[_FillID^], _QueueCapacity[_FillID^]);
  end;
end;

procedure TG2RenderControlManaged.RenderObject(const Obj: TG2ManagedRenderObject);
begin
  CheckCapacity;
  _Gfx.AddRenderQueueItem(Self, Obj);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlManaged.RenderBegin;
begin

end;

procedure TG2RenderControlManaged.RenderEnd;
begin

end;

procedure TG2RenderControlManaged.RenderData(const Data: Pointer);
begin
  TG2ManagedRenderObject(Data).DoRender;
end;

procedure TG2RenderControlManaged.Reset;
begin
  _QueueCount[_FillID^] := 0;
end;

constructor TG2RenderControlManaged.Create;
begin
  inherited Create;
  _QueueCapacity[0] := 0;
  _QueueCapacity[1] := 0;
  _QueueCount[0] := 0;
  _QueueCount[1] := 0;
end;

destructor TG2RenderControlManaged.Destroy;
begin
  inherited Destroy;
end;
//TG2RenderControlManaged END

//TG2RenderControlBuffer BEGIN
procedure TG2RenderControlBuffer.CheckCapacity;
  var n, i: TG2IntS32;
begin
  if _QueueCount[_FillID^] >= _QueueCapacity[_FillID^] then
  begin
    n := _QueueCapacity[_FillID^];
    _QueueCapacity[_FillID^] := _QueueCapacity[_FillID^] + 128;
    SetLength(_Queue[_FillID^], _QueueCapacity[_FillID^]);
    for i := n to _QueueCapacity[_FillID^] - 1 do
    New(_Queue[_FillID^][i]);
  end;
end;

procedure TG2RenderControlBuffer.RenderPrimitive(
  const VB: TG2VertexBuffer;
  const PrimitiveType: TG2PrimitiveType;
  const VertexStart: TG2IntS32;
  const PrimitiveCount: TG2IntS32;
  const Texture: TG2Texture2DBase;
  const W, V, P: TG2Mat
);
  var BufferRenderData: PG2BufferRenderData;
begin
  CheckCapacity;
  BufferRenderData := _Queue[_FillID^][_QueueCount[_FillID^]];
  BufferRenderData^.VertexBuffer := VB;
  BufferRenderData^.IndexBuffer := nil;
  BufferRenderData^.PrimitiveType := PrimitiveType;
  BufferRenderData^.VertexStart := VertexStart;
  BufferRenderData^.PrimitiveCount := PrimitiveCount;
  BufferRenderData^.Texture := Texture;
  BufferRenderData^.W := W;
  BufferRenderData^.V := V;
  BufferRenderData^.P := P;
  _Gfx.AddRenderQueueItem(Self, BufferRenderData);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlBuffer.RenderPrimitive(
  const VB: TG2VertexBuffer;
  const IB: TG2IndexBuffer;
  const PrimitiveType: TG2PrimitiveType;
  const VertexStart: TG2IntS32;
  const VertexCount: TG2IntS32;
  const IndexStart: TG2IntS32;
  const PrimitiveCount: TG2IntS32;
  const Texture: TG2Texture2DBase;
  const W, V, P: TG2Mat
);
  var BufferRenderData: PG2BufferRenderData;
begin
  CheckCapacity;
  BufferRenderData := _Queue[_FillID^][_QueueCount[_FillID^]];
  BufferRenderData^.VertexBuffer := VB;
  BufferRenderData^.IndexBuffer := IB;
  BufferRenderData^.PrimitiveType := PrimitiveType;
  BufferRenderData^.VertexStart := VertexStart;
  BufferRenderData^.VertexCount := VertexCount;
  BufferRenderData^.IndexStart := IndexStart;
  BufferRenderData^.PrimitiveCount := PrimitiveCount;
  BufferRenderData^.Texture := Texture;
  BufferRenderData^.W := W;
  BufferRenderData^.V := V;
  BufferRenderData^.P := P;
  _Gfx.AddRenderQueueItem(Self, BufferRenderData);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlBuffer.RenderBegin;
begin
  {$if defined(G2RM_SM2)}
  _ShaderGroup.Method := 'Pic';
  {$endif}
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  {$elseif defined(G2Gfx_OGL)}

  {$elseif defined(G2Gfx_GLES)}

  {$endif}
end;

procedure TG2RenderControlBuffer.RenderEnd;
begin
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
  {$elseif defined(G2Gfx_OGL)}

  {$elseif defined(G2Gfx_GLES)}

  {$endif}
end;

procedure TG2RenderControlBuffer.RenderData(const Data: Pointer);
  var BufferRenderData: PG2BufferRenderData;
  {$if defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
  var m: TG2Mat;
  {$endif}
  {$if defined(G2RM_SM2)}
  var WVP: TG2Mat;
  {$endif}
begin
  BufferRenderData := PG2BufferRenderData(Data);
  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_FF)}
  _Gfx.Device.SetTexture(0, BufferRenderData^.Texture.GetTexture);
  _Gfx.Device.SetTransform(D3DTS_WORLD, BufferRenderData^.W);
  _Gfx.Device.SetTransform(D3DTS_VIEW, BufferRenderData^.V);
  _Gfx.Device.SetTransform(D3DTS_PROJECTION, BufferRenderData^.P);
  {$elseif defined(G2RM_SM2)}
  _ShaderGroup.Sampler('Tex0', BufferRenderData^.Texture);
  WVP := BufferRenderData^.W * BufferRenderData^.V * BufferRenderData^.P;
  _ShaderGroup.UniformMatrix4x4('WVP', WVP);
  {$endif}
  BufferRenderData^.VertexBuffer.Bind;
  if BufferRenderData^.IndexBuffer <> nil then
  begin
    BufferRenderData^.IndexBuffer.Bind;
    _Gfx.Device.DrawIndexedPrimitive(
      TD3DPrimitiveType(BufferRenderData^.PrimitiveType),
      0,
      BufferRenderData^.VertexStart, BufferRenderData^.VertexCount,
      BufferRenderData^.IndexStart, BufferRenderData^.PrimitiveCount
    );
    BufferRenderData^.IndexBuffer.Unbind;
  end
  else
  _Gfx.Device.DrawPrimitive(
    TD3DPrimitiveType(BufferRenderData^.PrimitiveType),
    BufferRenderData^.VertexStart,
    BufferRenderData^.PrimitiveCount
  );
  BufferRenderData^.VertexBuffer.Unbind;
  {$elseif defined(G2Gfx_OGL)}
  {$if defined(G2RM_FF)}
  glBindTexture(GL_TEXTURE_2D, BufferRenderData^.Texture.GetTexture);
  glMatrixMode(GL_MODELVIEW);
  m := BufferRenderData^.W * BufferRenderData^.V;
  glLoadMatrixf(@m);
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf(@BufferRenderData^.P);
  {$elseif defined(G2RM_SM2)}
  _ShaderGroup.Sampler('Tex0', BufferRenderData^.Texture);
  WVP := BufferRenderData^.W * BufferRenderData^.V * BufferRenderData^.P;
  _ShaderGroup.UniformMatrix4x4('WVP', WVP);
  {$endif}
  BufferRenderData^.VertexBuffer.Bind;
  if BufferRenderData^.IndexBuffer <> nil then
  begin
    BufferRenderData^.IndexBuffer.Bind;
    glDrawElements(GL_TRIANGLES, BufferRenderData^.PrimitiveCount * 3, GL_UNSIGNED_SHORT, PGLVoid(0));
    BufferRenderData^.IndexBuffer.Unbind;
  end
  else
  glDrawArrays(GL_TRIANGLES, BufferRenderData^.VertexStart, BufferRenderData^.PrimitiveCount * 3);
  BufferRenderData^.VertexBuffer.Unbind;
  {$elseif defined(G2Gfx_GLES)}
  glBindTexture(GL_TEXTURE_2D, BufferRenderData^.Texture.GetTexture);
  _Gfx.Filter := tfPoint;
  glMatrixMode(GL_PROJECTION);
  m := BufferRenderData^.V * BufferRenderData^.P;
  glLoadMatrixf(@m);
  glMatrixMode(GL_MODELVIEW);
  glLoadMatrixf(@BufferRenderData^.W);
  BufferRenderData^.VertexBuffer.Bind;
  if BufferRenderData^.IndexBuffer <> nil then
  begin
    BufferRenderData^.IndexBuffer.Bind;
    glDrawElements(GL_TRIANGLES, BufferRenderData^.PrimitiveCount * 3, GL_UNSIGNED_SHORT, PGLVoid(0));
    BufferRenderData^.IndexBuffer.Unbind;
  end
  else
  glDrawArrays(GL_TRIANGLES, BufferRenderData^.VertexStart, BufferRenderData^.PrimitiveCount * 3);
  BufferRenderData^.VertexBuffer.Unbind;
  {$endif}
end;

procedure TG2RenderControlBuffer.Reset;
begin
  _QueueCount[_FillID^] := 0;
end;

constructor TG2RenderControlBuffer.Create;
begin
  inherited Create;
  _QueueCapacity[0] := 0;
  _QueueCapacity[1] := 0;
  _QueueCount[0] := 0;
  _QueueCount[1] := 0;
  {$if defined(G2RM_SM2)}
  _ShaderGroup := _Gfx.RequestShader('StandardShaders');
  {$endif}
end;

destructor TG2RenderControlBuffer.Destroy;
  var n, i: TG2IntS32;
begin
  for n := 0 to 1 do
  for i := 0 to _QueueCapacity[n] - 1 do
  Dispose(_Queue[n][i]);
  inherited Destroy;
end;
//TG2RenderControlBuffer END

//TG2RenderControlPic2D BEGIN
procedure TG2RenderControlPic2D.CheckCapacity;
  var n, i: TG2IntS32;
begin
  if _QueueCount[_FillID^] >= _QueueCapacity[_FillID^] then
  begin
    n := _QueueCapacity[_FillID^];
    _QueueCapacity[_FillID^] := _QueueCapacity[_FillID^] + 128;
    SetLength(_Queue[_FillID^], _QueueCapacity[_FillID^]);
    for i := n to _QueueCapacity[_FillID^] - 1 do
    New(_Queue[_FillID^][i]);
  end;
end;

procedure TG2RenderControlPic2D.Flush;
begin
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST, 0, _CurQuad * 4, _CurQuad * 2, _Indices[0], D3DFMT_INDEX16, _Vertices[0], SizeOf(TG2Pic2DVertex));
  {$elseif defined(G2Gfx_OGL)}
  glEnd;
  {$elseif defined(G2Gfx_GLES)}
  glVertexPointer(3, GL_FLOAT, 0, @_VertPositions[0]);
  glColorPointer(4, GL_FLOAT, 0, @_VertColors[0]);
  glTexCoordPointer(2, GL_FLOAT, 0, @_VertTexCoords[0]);
  if _Gfx.BlendMode.BlendSeparate then
  begin
    _Gfx.MaskColor;
    glDrawElements(GL_TRIANGLES, _CurQuad * 6, GL_UNSIGNED_SHORT, @_Indices[0]);
    _Gfx.MaskAlpha;
    _Gfx.SwapBlendMode;
    glDrawElements(GL_TRIANGLES, _CurQuad * 6, GL_UNSIGNED_SHORT, @_Indices[0]);
    _Gfx.MaskAll;
    _Gfx.SwapBlendMode;
  end
  else
  glDrawElements(GL_TRIANGLES, _CurQuad * 6, GL_UNSIGNED_SHORT, @_Indices[0]);
  {$endif}
  _CurQuad := 0;
end;

procedure TG2RenderControlPic2D.DrawQuad(
  const Pos0, Pos1, Pos2, Pos3: TG2Vec2;
  const Tex0, Tex1, Tex2, Tex3: TG2Vec2;
  const c0, c1, c2, c3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode;
  const Filter: TG2Filter = tfPoint
);
  var p: PG2Pic2D;
begin
  CheckCapacity;
  p := _Queue[_FillID^][_QueueCount[_FillID^]];
  p^.Pos0 := Pos0; p^.Pos1 := Pos1; p^.Pos2 := Pos2; p^.Pos3 := Pos3;
  p^.Tex0 := Tex0; p^.Tex1 := Tex1; p^.Tex2 := Tex2; p^.Tex3 := Tex3;
  p^.c0 := c0; p^.c1 := c1; p^.c2 := c2; p^.c3 := c3;
  p^.Texture := Texture;
  p^.BlendMode := BlendMode;
  p^.Filter := Filter;
  _Gfx.AddRenderQueueItem(Self, p);
  Inc(_QueueCount[_FillID^]);
end;

procedure TG2RenderControlPic2D.RenderBegin;
{$if defined(G2RM_SM2)}
  var WVP: TG2Mat;
{$endif}
begin
  _CurTexture := nil;
  _CurBlendMode := bmInvalid;
  _CurFilter := tfNone;
  _CurQuad := 0;
  {$if defined(G2RM_FF)}
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetFVF(D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1);
  {$elseif defined(G2Gfx_OGL)}
  _Gfx.SetProj2D;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glEnable(GL_TEXTURE_2D);
  {$elseif defined(G2Gfx_GLES)}
  _Gfx.SetProj2D;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  {$endif}
  {$elseif defined(G2RM_SM2)}
  _ShaderGroup.Method := 'Pic';
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetVertexDeclaration(_Decl);
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1);
  {$elseif defined(G2Gfx_OGL)}
  glEnable(GL_TEXTURE_2D);
  _AttribPosition := _ShaderGroup.Attribute('a_Position0');
  _AttribColor := _ShaderGroup.Attribute('a_Color0');
  _AttribTexCoord := _ShaderGroup.Attribute('a_TexCoord0');
  if _Gfx.RenderTarget = nil then
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1)
  else
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1, False, False);
  {$endif}
  _ShaderGroup.UniformMatrix4x4('WVP', WVP);
  {$endif}
end;

procedure TG2RenderControlPic2D.RenderEnd;
begin
  if _CurQuad > 0 then Flush;
  {$if defined(G2RM_FF)}
  {$ifdef G2Gfx_GLES}
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  {$endif}
  {$elseif defined(G2RM_SM2)}

  {$endif}
end;

procedure TG2RenderControlPic2D.RenderData(const Data: Pointer);
  var p: PG2Pic2D;
  {$if defined(G2Gfx_D3D9)}
  var v: PG2Pic2DVertex;
  {$elseif defined(G2Gfx_GLES)}
  var v: TG2IntS32;
  {$endif}
begin
  p := PG2Pic2D(Data);
  if (p^.Texture <> _CurTexture)
  or (p^.BlendMode <> _CurBlendMode)
  or (p^.Filter <> _CurFilter)
  or (_CurQuad >= _MaxQuads)then
  begin
    if _CurQuad > 0 then Flush;
    if (p^.Texture <> _CurTexture) then
    begin
      _CurTexture := p^.Texture;
      {$if defined(G2Gfx_D3D9)}
      {$if defined(G2RM_FF)}
      _Gfx.Device.SetTexture(0, _CurTexture.GetTexture);
      {$elseif defined(G2RM_SM2)}
      _ShaderGroup.Sampler('Tex0', _CurTexture);
      {$endif}
      {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
      {$if defined(G2RM_FF)}
      glBindTexture(GL_TEXTURE_2D, _CurTexture.GetTexture);
      {$elseif defined(G2RM_SM2)}
      _ShaderGroup.Sampler('Tex0', _CurTexture);
      {$endif}
      _CurFilter := p^.Filter;
      _Gfx.Filter := _CurFilter;
      {$endif}
    end;
    if (p^.BlendMode <> _CurBlendMode) then
    begin
      _CurBlendMode := p^.BlendMode;
      _Gfx.BlendMode := _CurBlendMode;
    end;
    if (p^.Filter <> _CurFilter) then
    begin
      _CurFilter := p^.Filter;
      _Gfx.Filter := _CurFilter;
    end;
    {$if defined(G2Gfx_OGL)}
    glBegin(GL_QUADS);
    {$endif}
  end;
  {$if defined(G2Gfx_D3D9)}
  v := @_Vertices[_CurQuad * 4];
  {$if defined(G2RM_FF)}
  v^.x := p^.Pos0.x - 0.5; v^.y := p^.Pos0.y - 0.5; v^.z := 0; v^.rhw := 1;
  v^.Color := p^.c0; v^.tu := p^.Tex0.x; v^.tv := p^.Tex0.y; Inc(v);
  v^.x := p^.Pos1.x - 0.5; v^.y := p^.Pos1.y - 0.5; v^.z := 0; v^.rhw := 1;
  v^.Color := p^.c1; v^.tu := p^.Tex1.x; v^.tv := p^.Tex1.y; Inc(v);
  v^.x := p^.Pos2.x - 0.5; v^.y := p^.Pos2.y - 0.5; v^.z := 0; v^.rhw := 1;
  v^.Color := p^.c2; v^.tu := p^.Tex2.x; v^.tv := p^.Tex2.y; Inc(v);
  v^.x := p^.Pos3.x - 0.5; v^.y := p^.Pos3.y - 0.5; v^.z := 0; v^.rhw := 1;
  v^.Color := p^.c3; v^.tu := p^.Tex3.x; v^.tv := p^.Tex3.y;
  {$elseif defined(G2RM_SM2)}
  v^.x := p^.Pos0.x - 0.5; v^.y := p^.Pos0.y - 0.5; v^.z := 0;
  v^.Color := p^.c0; v^.tu := p^.Tex0.x; v^.tv := p^.Tex0.y; Inc(v);
  v^.x := p^.Pos1.x - 0.5; v^.y := p^.Pos1.y - 0.5; v^.z := 0;
  v^.Color := p^.c1; v^.tu := p^.Tex1.x; v^.tv := p^.Tex1.y; Inc(v);
  v^.x := p^.Pos2.x - 0.5; v^.y := p^.Pos2.y - 0.5; v^.z := 0;
  v^.Color := p^.c2; v^.tu := p^.Tex2.x; v^.tv := p^.Tex2.y; Inc(v);
  v^.x := p^.Pos3.x - 0.5; v^.y := p^.Pos3.y - 0.5; v^.z := 0;
  v^.Color := p^.c3; v^.tu := p^.Tex3.x; v^.tv := p^.Tex3.y;
  {$endif}
  {$elseif defined(G2Gfx_OGL)}
  {$if defined(G2RM_FF)}
  glColor4f(p^.c0.r * Rcp255, p^.c0.g * Rcp255, p^.c0.b * Rcp255, p^.c0.a * Rcp255);
  glTexCoord2f(p^.Tex0.x, p^.Tex0.y); glVertex3f(p^.Pos0.x - 0.5, p^.Pos0.y - 0.5, 0);
  glColor4f(p^.c1.r * Rcp255, p^.c1.g * Rcp255, p^.c1.b * Rcp255, p^.c1.a * Rcp255);
  glTexCoord2f(p^.Tex1.x, p^.Tex1.y); glVertex3f(p^.Pos1.x - 0.5, p^.Pos1.y - 0.5, 0);
  glColor4f(p^.c3.r * Rcp255, p^.c3.g * Rcp255, p^.c3.b * Rcp255, p^.c3.a * Rcp255);
  glTexCoord2f(p^.Tex3.x, p^.Tex3.y); glVertex3f(p^.Pos3.x - 0.5, p^.Pos3.y - 0.5, 0);
  glColor4f(p^.c2.r * Rcp255, p^.c2.g * Rcp255, p^.c2.b * Rcp255, p^.c2.a * Rcp255);
  glTexCoord2f(p^.Tex2.x, p^.Tex2.y); glVertex3f(p^.Pos2.x - 0.5, p^.Pos2.y - 0.5, 0);
  {$elseif defined(G2RM_SM2)}
  glVertexAttrib4f(_AttribColor, p^.c0.r * Rcp255, p^.c0.g * Rcp255, p^.c0.b * Rcp255, p^.c0.a * Rcp255);
  glVertexAttrib2f(_AttribTexCoord, p^.Tex0.x, p^.Tex0.y); glVertexAttrib3f(_AttribPosition, p^.Pos0.x - 0.5, p^.Pos0.y - 0.5, 0);
  glVertexAttrib4f(_AttribColor, p^.c1.r * Rcp255, p^.c1.g * Rcp255, p^.c1.b * Rcp255, p^.c1.a * Rcp255);
  glVertexAttrib2f(_AttribTexCoord, p^.Tex1.x, p^.Tex1.y); glVertexAttrib3f(_AttribPosition, p^.Pos1.x - 0.5, p^.Pos1.y - 0.5, 0);
  glVertexAttrib4f(_AttribColor, p^.c3.r * Rcp255, p^.c3.g * Rcp255, p^.c3.b * Rcp255, p^.c3.a * Rcp255);
  glVertexAttrib2f(_AttribTexCoord, p^.Tex3.x, p^.Tex3.y); glVertexAttrib3f(_AttribPosition, p^.Pos3.x - 0.5, p^.Pos3.y - 0.5, 0);
  glVertexAttrib4f(_AttribColor, p^.c2.r * Rcp255, p^.c2.g * Rcp255, p^.c2.b * Rcp255, p^.c2.a * Rcp255);
  glVertexAttrib2f(_AttribTexCoord, p^.Tex2.x, p^.Tex2.y); glVertexAttrib3f(_AttribPosition, p^.Pos2.x - 0.5, p^.Pos2.y - 0.5, 0);
  {$endif}
  {$elseif defined(G2Gfx_GLES)}
  v := _CurQuad * 4;
  _VertPositions[v].SetValue(p^.Pos0.x - 0.5, p^.Pos0.y - 0.5, 0);
  _VertColors[v].SetValue(p^.c0.r * Rcp255, p^.c0.g * Rcp255, p^.c0.b * Rcp255, p^.c0.a * Rcp255);
  _VertTexCoords[v] := p^.Tex0; Inc(v);
  _VertPositions[v].SetValue(p^.Pos1.x - 0.5, p^.Pos1.y - 0.5, 0);
  _VertColors[v].SetValue(p^.c1.r * Rcp255, p^.c1.g * Rcp255, p^.c1.b * Rcp255, p^.c1.a * Rcp255);
  _VertTexCoords[v] := p^.Tex1; Inc(v);
  _VertPositions[v].SetValue(p^.Pos2.x - 0.5, p^.Pos2.y - 0.5, 0);
  _VertColors[v].SetValue(p^.c2.r * Rcp255, p^.c2.g * Rcp255, p^.c2.b * Rcp255, p^.c2.a * Rcp255);
  _VertTexCoords[v] := p^.Tex2; Inc(v);
  _VertPositions[v].SetValue(p^.Pos3.x - 0.5, p^.Pos3.y - 0.5, 0);
  _VertColors[v].SetValue(p^.c3.r * Rcp255, p^.c3.g * Rcp255, p^.c3.b * Rcp255, p^.c3.a * Rcp255);
  _VertTexCoords[v] := p^.Tex3; Inc(v);
  {$endif}
  Inc(_CurQuad);
end;

procedure TG2RenderControlPic2D.Reset;
begin
  _QueueCount[_FillID^] := 0;
end;

constructor TG2RenderControlPic2D.Create;
{$if defined(G2Gfx_D3D9)}
  var i: TG2IntS32;
{$if defined(G2RM_SM2)}
  var ve: array [0..3] of TD3DVertexElement9;
{$endif}
{$elseif defined(G2Gfx_GLES)}
  var i: TG2IntS32;
{$endif}
begin
  inherited Create;
  _QueueCapacity[0] := 0;
  _QueueCapacity[1] := 0;
  _QueueCount[0] := 0;
  _QueueCount[1] := 0;
  _MaxQuads := 8000;
  {$if defined(G2RM_SM2)}
  _ShaderGroup := _Gfx.RequestShader('StandardShaders');
  {$endif}
  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_SM2)}
  ve[0] := D3DVertexElement(0, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_POSITION);
  ve[1] := D3DVertexElement(12, D3DDECLTYPE_D3DCOLOR, D3DDECLUSAGE_COLOR);
  ve[2] := D3DVertexElement(16, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_TEXCOORD);
  ve[3] := D3DDECL_END;
  _Gfx.Device.CreateVertexDeclaration(@ve, _Decl);
  {$endif}
  SetLength(_Vertices, _MaxQuads * 4);
  SetLength(_Indices, _MaxQuads * 6);
  for i := 0 to _MaxQuads - 1 do
  begin
    _Indices[i * 6 + 0] := i * 4 + 0;
    _Indices[i * 6 + 1] := i * 4 + 1;
    _Indices[i * 6 + 2] := i * 4 + 2;
    _Indices[i * 6 + 3] := i * 4 + 2;
    _Indices[i * 6 + 4] := i * 4 + 1;
    _Indices[i * 6 + 5] := i * 4 + 3;
  end;
  {$elseif defined(G2Gfx_GLES)}
  SetLength(_VertPositions, _MaxQuads * 4);
  SetLength(_VertColors, _MaxQuads * 4);
  SetLength(_VertTexCoords, _MaxQuads * 4);
  SetLength(_Indices, _MaxQuads * 6);
  for i := 0 to _MaxQuads - 1 do
  begin
    _Indices[i * 6 + 0] := i * 4 + 0;
    _Indices[i * 6 + 1] := i * 4 + 1;
    _Indices[i * 6 + 2] := i * 4 + 2;
    _Indices[i * 6 + 3] := i * 4 + 2;
    _Indices[i * 6 + 4] := i * 4 + 1;
    _Indices[i * 6 + 5] := i * 4 + 3;
  end;
  {$endif}
end;

destructor TG2RenderControlPic2D.Destroy;
  var n, i: TG2IntS32;
begin
  for n := 0 to 1 do
  for i := 0 to _QueueCapacity[n] - 1 do
  Dispose(_Queue[n][i]);
  {$ifdef G2Gfx_D3D9}
  _Vertices := nil;
  _Indices := nil;
  {$if defined(G2RM_SM2)}
  SafeRelease(_Decl);
  {$endif}
  {$endif}
  inherited Destroy;
end;
//TG2RenderControlPic2D END

//TG2RenderControlPrim2D BEGIN
procedure TG2RenderControlPrim2D.CheckCapacity;
  var n, i: TG2IntS32;
begin
  if _QueueCount[_FillID^] >= _QueueCapacity[_FillID^] then
  begin
    n := _QueueCapacity[_FillID^];
    _QueueCapacity[_FillID^] := _QueueCapacity[_FillID^] + 128;
    SetLength(_Queue[_FillID^], _QueueCapacity[_FillID^]);
    for i := n to _QueueCapacity[_FillID^] - 1 do
    begin
      New(_Queue[_FillID^][i]);
      _Queue[_FillID^][i]^.Count := 0;
      _Queue[_FillID^][i]^.PrimType := ptNone;
      SetLength(_Queue[_FillID^][i]^.Points, 32);
    end;
  end;
end;

procedure TG2RenderControlPrim2D.Flush;
begin
  {$if defined(G2Gfx_D3D9)}
  case _CurPrimType of
    ptLines:
    begin
      if _CurPoint mod 2 = 0 then
      _Gfx.Device.DrawPrimitiveUP(D3DPT_LINELIST, _CurPoint div 2, _Vertices[0], SizeOf(TG2Prim2DVertex));
    end;
    ptTriangles:
    begin
      if _CurPoint mod 3 = 0 then
      _Gfx.Device.DrawPrimitiveUP(D3DPT_TRIANGLELIST, _CurPoint div 3, _Vertices[0], SizeOf(TG2Prim2DVertex));
    end;
  end;
  {$elseif defined(G2Gfx_OGL)}
  glEnd;
  {$elseif defined(G2Gfx_GLES)}
  glVertexPointer(3, GL_FLOAT, 0, @_VertPositions[0]);
  glColorPointer(4, GL_FLOAT, 0, @_VertColors[0]);
  case _CurPrimType of
    ptLines:
    begin
      if _CurPoint mod 2 = 0 then
      begin
        if _Gfx.BlendMode.BlendSeparate then
        begin
          _Gfx.MaskColor;
          glDrawElements(GL_LINES, _CurPoint, GL_UNSIGNED_SHORT, @_Indices[0]);
          _Gfx.MaskAlpha;
          _Gfx.SwapBlendMode;
          glDrawElements(GL_LINES, _CurPoint, GL_UNSIGNED_SHORT, @_Indices[0]);
          _Gfx.MaskAll;
          _Gfx.SwapBlendMode;
        end
        else
        glDrawElements(GL_LINES, _CurPoint, GL_UNSIGNED_SHORT, @_Indices[0]);
      end;
    end;
    ptTriangles:
    begin
      if _CurPoint mod 3 = 0 then
      glDrawElements(GL_TRIANGLES, _CurPoint, GL_UNSIGNED_SHORT, @_Indices[0]);
    end;
  end;
  {$endif}
  _CurPoint := 0;
end;

procedure TG2RenderControlPrim2D.PrimBegin(const PrimType: TG2PrimType; const BlendMode: TG2BlendMode);
begin
  if _CurPrim <> nil then PrimEnd;
  CheckCapacity;
  _CurPrim := _Queue[_FillID^][_QueueCount[_FillID^]];
  _CurPrim^.Count := 0;
  _CurPrim^.PrimType := PrimType;
  _CurPrim^.BlendMode := BlendMode;
end;

procedure TG2RenderControlPrim2D.PrimEnd;
begin
  if _CurPrim = nil then Exit;
  _Gfx.AddRenderQueueItem(Self, _CurPrim);
  Inc(_QueueCount[_FillID^]);
  _CurPrim := nil;
end;

procedure TG2RenderControlPrim2D.PrimAdd(const x, y: TG2Float; const Color: TG2Color);
begin
  if _CurPrim = nil then Exit;
  if _CurPrim^.Count >= Length(_CurPrim^.Points) then
  SetLength(_CurPrim^.Points, Length(_CurPrim^.Points) + 32);
  _CurPrim^.Points[_CurPrim^.Count].x := x - 0.5;
  _CurPrim^.Points[_CurPrim^.Count].y := y - 0.5;
  _CurPrim^.Points[_CurPrim^.Count].Color := Color;
  Inc(_CurPrim^.Count);
end;

procedure TG2RenderControlPrim2D.RenderBegin;
{$if defined(G2RM_SM2)}
  var WVP: TG2Mat;
{$endif}
begin
  _CurPoint := 0;
  _CurPrimType := ptNone;
  _CurBlendMode := bmInvalid;
  {$if defined(G2RM_FF)}
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetFVF(D3DFVF_XYZRHW or D3DFVF_DIFFUSE);
  _Gfx.Device.SetTexture(0, nil);
  {$elseif defined(G2Gfx_OGL)}
  _Gfx.SetProj2D;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glDisable(GL_TEXTURE_2D);
  {$elseif defined(G2Gfx_GLES)}
  _Gfx.SetProj2D;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glDisable(GL_TEXTURE_2D);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  {$endif}
  {$elseif defined(G2RM_SM2)}
  _ShaderGroup.Method := 'Prim';
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetVertexDeclaration(_Decl);
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1);
  {$elseif defined(G2Gfx_OGL)}
  _AttribPosition := _ShaderGroup.Attribute('a_Position0');
  _AttribColor := _ShaderGroup.Attribute('a_Color0');
  if _Gfx.RenderTarget = nil then
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1)
  else
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1, False, False);
  glDisable(GL_TEXTURE_2D);
  {$endif}
  _ShaderGroup.UniformMatrix4x4('WVP', WVP);
  {$endif}
  _Gfx.BlendMode := bmNormal;
end;

procedure TG2RenderControlPrim2D.RenderEnd;
begin
  if _CurPoint > 0 then Flush;
  {$if defined(G2RM_FF)}
  {$if defined(G2Gfx_OGL)}
  glEnable(GL_TEXTURE_2D);
  {$elseif defined(G2Gfx_GLES)}
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glEnable(GL_TEXTURE_2D);
  {$endif}
  {$elseif defined(G2RM_SM2)}
  {$if defined(G2Gfx_OGL)}
  glEnable(GL_TEXTURE_2D);
  {$endif}
  {$endif}
end;

procedure TG2RenderControlPrim2D.RenderData(const Data: Pointer);
  var p: PG2Prim2D;
  var i: TG2IntS32;
begin
  p := PG2Prim2D(Data);
  if p^.Count = 0 then Exit;
  if (p^.PrimType <> _CurPrimType)
  or (p^.BlendMode <> _CurBlendMode)
  or (p^.Count + _CurPoint > _MaxPoints) then
  begin
    if _CurPoint > 0 then Flush;
    _CurPrimType := p^.PrimType;
    if (p^.BlendMode <> _CurBlendMode) then
    begin
      _CurBlendMode := p^.BlendMode;
      _Gfx.BlendMode := _CurBlendMode;
    end;
    {$if defined(G2Gfx_OGL)}
    case _CurPrimType of
      ptLines: glBegin(GL_LINES);
      ptTriangles: glBegin(GL_TRIANGLES);
    end;
    {$endif}
  end;
  {$if defined(G2Gfx_D3D9)}
  for i := 0 to p^.Count - 1 do
  begin
    _Vertices[_CurPoint].x := p^.Points[i].x;
    _Vertices[_CurPoint].y := p^.Points[i].y;
    _Vertices[_CurPoint].z := 0;
    {$if defined(G2RM_FF)}
    _Vertices[_CurPoint].rhw := 1;
    {$endif}
    _Vertices[_CurPoint].Color := p^.Points[i].Color;
    Inc(_CurPoint);
  end;
  {$elseif defined(G2Gfx_OGL)}
  for i := 0 to p^.Count - 1 do
  begin
    {$if defined(G2RM_FF)}
    glColor4f(p^.Points[i].Color.r * Rcp255, p^.Points[i].Color.g * Rcp255, p^.Points[i].Color.b * Rcp255, p^.Points[i].Color.a * Rcp255);
    glVertex3f(p^.Points[i].x, p^.Points[i].y, 0);
    {$elseif defined(G2RM_SM2)}
    glVertexAttrib4f(_AttribColor, p^.Points[i].Color.r * Rcp255, p^.Points[i].Color.g * Rcp255, p^.Points[i].Color.b * Rcp255, p^.Points[i].Color.a * Rcp255);
    glVertexAttrib3f(_AttribPosition, p^.Points[i].x, p^.Points[i].y, 0);
    {$endif}
    Inc(_CurPoint);
  end;
  {$elseif defined(G2Gfx_GLES)}
  for i := 0 to p^.Count - 1 do
  begin
    _VertPositions[_CurPoint].x := p^.Points[i].x;
    _VertPositions[_CurPoint].y := p^.Points[i].y;
    _VertPositions[_CurPoint].z := 0;
    _VertColors[_CurPoint].SetValue(
      p^.Points[i].Color.r * Rcp255,
      p^.Points[i].Color.g * Rcp255,
      p^.Points[i].Color.b * Rcp255,
      p^.Points[i].Color.a * Rcp255
    );
    Inc(_CurPoint);
  end;
  {$endif}
end;

procedure TG2RenderControlPrim2D.Reset;
begin
  _QueueCount[_FillID^] := 0;
  _CurPrim := nil;
end;

constructor TG2RenderControlPrim2D.Create;
{$if defined(G2Gfx_D3D9)}
{$if defined(G2RM_SM2)}
  var ve: array[0..2] of TD3DVertexElement9;
{$endif}
{$elseif defined(G2Gfx_GLES)}
  var i: TG2IntS32;
{$endif}
begin
  inherited Create;
  _QueueCapacity[0] := 0;
  _QueueCapacity[1] := 0;
  _QueueCount[0] := 0;
  _QueueCount[1] := 0;
  _MaxPoints := 2048;
  {$if defined(G2RM_SM2)}
  _ShaderGroup := _Gfx.RequestShader('StandardShaders');
  {$endif}
  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_SM2)}
  ve[0] := D3DVertexElement(0, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_POSITION);
  ve[1] := D3DVertexElement(12, D3DDECLTYPE_D3DCOLOR, D3DDECLUSAGE_COLOR);
  ve[2] := D3DDECL_END;
  _Gfx.Device.CreateVertexDeclaration(@ve, _Decl);
  {$endif}
  SetLength(_Vertices, _MaxPoints);
  {$elseif defined(G2Gfx_GLES)}
  SetLength(_VertPositions, _MaxPoints);
  SetLength(_VertColors, _MaxPoints);
  SetLength(_Indices, _MaxPoints);
  for i := 0 to _MaxPoints - 1 do
  _Indices[i] := i;
  {$endif}
end;

destructor TG2RenderControlPrim2D.Destroy;
  var n, i: TG2IntS32;
begin
  for n := 0 to 1 do
  for i := 0 to _QueueCapacity[n] - 1 do
  Dispose(_Queue[n][i]);
  {$ifdef G2Gfx_D3D9}
  _Vertices := nil;
  {$if defined(G2RM_SM2)}
  SafeRelease(_Decl);
  {$endif}
  {$endif}
  inherited Destroy;
end;
//TG2RenderControlPrim2D END

//TG2RenderControlPoly2D BEGIN
procedure TG2RenderControlPoly2D.CheckCapacity;
  var n, i: TG2IntS32;
begin
  if _QueueCount[_FillID^] >= _QueueCapacity[_FillID^] then
  begin
    n := _QueueCapacity[_FillID^];
    _QueueCapacity[_FillID^] := _QueueCapacity[_FillID^] + 128;
    SetLength(_Queue[_FillID^], _QueueCapacity[_FillID^]);
    for i := n to _QueueCapacity[_FillID^] - 1 do
    begin
      New(_Queue[_FillID^][i]);
      _Queue[_FillID^][i]^.Count := 0;
      SetLength(_Queue[_FillID^][i]^.Points, 32);
    end;
  end;
end;

procedure TG2RenderControlPoly2D.Flush;
begin
  {$if defined(G2Gfx_D3D9)}
  case _CurPolyType of
    ptLines: _Gfx.Device.DrawPrimitiveUP(D3DPT_LINELIST, _CurPoint div 2, _Vertices[0], SizeOf(TG2Poly2DVertex));
    ptTriangles: _Gfx.Device.DrawPrimitiveUP(D3DPT_TRIANGLELIST, _CurPoint div 3, _Vertices[0], SizeOf(TG2Poly2DVertex));
  end;
  {$elseif defined(G2Gfx_OGL)}
  glEnd;
  {$elseif defined(G2Gfx_GLES)}
  glVertexPointer(3, GL_FLOAT, 0, @_VertPositions[0]);
  glColorPointer(4, GL_FLOAT, 0, @_VertColors[0]);
  glTexCoordPointer(2, GL_FLOAT, 0, @_VertTexCoords[0]);
  if _Gfx.BlendMode.BlendSeparate then
  begin
    _Gfx.MaskColor;
    case _CurPolyType of
      ptLines: glDrawElements(GL_LINES, _CurIndex, GL_UNSIGNED_SHORT, @_Indices[0]);
      ptTriangles: glDrawElements(GL_TRIANGLES, _CurIndex, GL_UNSIGNED_SHORT, @_Indices[0]);
    end;
    _Gfx.MaskAlpha;
    _Gfx.SwapBlendMode;
    case _CurPolyType of
      ptLines: glDrawElements(GL_LINES, _CurIndex, GL_UNSIGNED_SHORT, @_Indices[0]);
      ptTriangles: glDrawElements(GL_TRIANGLES, _CurIndex, GL_UNSIGNED_SHORT, @_Indices[0]);
    end;
    _Gfx.MaskAll;
    _Gfx.SwapBlendMode;
  end
  else
  case _CurPolyType of
    ptLines: glDrawElements(GL_LINES, _CurIndex, GL_UNSIGNED_SHORT, @_Indices[0]);
    ptTriangles: glDrawElements(GL_TRIANGLES, _CurIndex, GL_UNSIGNED_SHORT, @_Indices[0]);
  end;
  {$endif}
  _CurPoint := 0;
  _CurIndex := 0;
end;

procedure TG2RenderControlPoly2D.PolyBegin(const PolyType: TG2PrimType; const Texture: TG2Texture2DBase; const BlendMode: TG2BlendMode = bmNormal; const Filter: TG2Filter = tfPoint);
begin
  if _CurPoly <> nil then PolyEnd;
  CheckCapacity;
  _CurPoly := _Queue[_FillID^][_QueueCount[_FillID^]];
  _CurPoly^.PolyType := PolyType;
  _CurPoly^.Texture := Texture;
  _CurPoly^.BlendMode := BlendMode;
  _CurPoly^.Filter := Filter;
  _CurPoly^.Count := 0;
end;

procedure TG2RenderControlPoly2D.PolyEnd;
begin
  if _CurPoly = nil then Exit;
  _Gfx.AddRenderQueueItem(Self, _CurPoly);
  Inc(_QueueCount[_FillID^]);
  _CurPoly := nil;
end;

procedure TG2RenderControlPoly2D.PolyAdd(const x, y, u, v: TG2Float; const Color: TG2Color);
begin
  if _CurPoly = nil then Exit;
  if _CurPoly^.Count + 4 > _MaxPoints then
  begin
    if ((_CurPoly^.PolyType = ptLines) and (_CurPoly^.Count mod 2 = 0))
    or ((_CurPoly^.PolyType = ptTriangles) and (_CurPoly^.Count mod 3 = 0)) then
    PolyBegin(_CurPoly^.PolyType, _CurPoly^.Texture, _CurPoly^.BlendMode, _CurPoly^.Filter);
  end;
  if _CurPoly^.Count >= Length(_CurPoly^.Points) then
  SetLength(_CurPoly^.Points, Length(_CurPoly^.Points) + 32);
  _CurPoly^.Points[_CurPoly^.Count].x := x - 0.5;
  _CurPoly^.Points[_CurPoly^.Count].y := y - 0.5;
  _CurPoly^.Points[_CurPoly^.Count].Color := Color;
  _CurPoly^.Points[_CurPoly^.Count].u := u;
  _CurPoly^.Points[_CurPoly^.Count].v := v;
  Inc(_CurPoly^.Count);
end;

procedure TG2RenderControlPoly2D.PolyAdd(const Pos, TexCoord: TG2Vec2; const Color: TG2Color);
begin
  PolyAdd(Pos.x, Pos.y, TexCoord.x, TexCoord.y, Color);
end;

procedure TG2RenderControlPoly2D.RenderBegin;
{$if defined(G2RM_SM2)}
  var WVP: TG2Mat;
{$endif}
begin
  _CurPoint := 0;
  _CurIndex := 0;
  _CurPolyType := ptNone;
  _CurTexture := nil;
  _CurBlendMode := bmInvalid;
  _CurFilter := tfNone;
  {$if defined(G2RM_FF)}
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetFVF(D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1);
  {$elseif defined(G2Gfx_OGL)}
  _Gfx.SetProj2D;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glEnable(GL_TEXTURE_2D);
  {$elseif defined(G2Gfx_GLES)}
  _Gfx.SetProj2D;
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  {$endif}
  {$elseif defined(G2RM_SM2)}
  _ShaderGroup.Method := 'Pic';
  {$if defined(G2Gfx_D3D9)}
  _Gfx.Device.SetVertexDeclaration(_Decl);
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1);
  {$elseif defined(G2Gfx_OGL)}
  _AttribPosition := _ShaderGroup.Attribute('a_Position0');
  _AttribColor := _ShaderGroup.Attribute('a_Color0');
  _AttribTexCoord := _ShaderGroup.Attribute('a_TexCoord0');
  if _Gfx.RenderTarget = nil then
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1)
  else
  WVP := G2MatOrth2D(_Gfx.SizeRT.x, _Gfx.SizeRT.y, 0, 1, False, False);
  {$endif}
  _ShaderGroup.UniformMatrix4x4('WVP', WVP);
  {$endif}
  _Gfx.BlendMode := bmNormal;
end;

procedure TG2RenderControlPoly2D.RenderEnd;
begin
  if _CurPoint > 0 then Flush;
  {$if defined(G2RM_FF)}
  {$if defined(G2Gfx_GLES)}
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  {$endif}
  {$elseif defined(G2RM_SM2)}

  {$endif}
end;

procedure TG2RenderControlPoly2D.RenderData(const Data: Pointer);
  var p: PG2Poly2D;
  var i: TG2IntS32;
begin
  p := PG2Poly2D(Data);
  if p^.Count = 0 then Exit;
  if (p^.Count + _CurPoint >= _MaxPoints)
  or (p^.PolyType <> _CurPolyType)
  or (p^.Texture <> _CurTexture)
  or (p^.BlendMode <> _CurBlendMode)
  or (p^.Filter <> _CurFilter) then
  begin
    if _CurPoint > 0 then Flush;
    if (p^.Texture <> _CurTexture) then
    begin
      _CurPolyType := p^.PolyType;
      _CurTexture := p^.Texture;
      {$if defined(G2Gfx_D3D9)}
      {$if defined(G2RM_FF)}
      _Gfx.Device.SetTexture(0, _CurTexture.GetTexture);
      {$elseif defined(G2RM_SM2)}
      _ShaderGroup.Sampler('Tex0', _CurTexture);
      {$endif}
      {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
      {$if defined(G2RM_FF)}
      glBindTexture(GL_TEXTURE_2D, _CurTexture.GetTexture);
      {$elseif defined(G2RM_SM2)}
      _ShaderGroup.Sampler('Tex0', _CurTexture, 0);
      {$endif}
      _CurFilter := p^.Filter;
      _Gfx.Filter := _CurFilter;
      {$endif}
    end;
    if (p^.BlendMode <> _CurBlendMode) then
    begin
      _CurBlendMode := p^.BlendMode;
      _Gfx.BlendMode := _CurBlendMode;
    end;
    if (p^.Filter <> _CurFilter) then
    begin
      _CurFilter := p^.Filter;
      _Gfx.Filter := _CurFilter;
    end;
    {$if defined(G2Gfx_OGL)}
    case _CurPolyType of
      ptLines: glBegin(GL_LINES);
      ptTriangles: glBegin(GL_TRIANGLES);
    end;
    {$endif}
  end;
  {$if defined(G2Gfx_D3D9)}
  for i := 0 to p^.Count - 1 do
  begin
    _Vertices[_CurPoint].x := p^.Points[i].x;
    _Vertices[_CurPoint].y := p^.Points[i].y;
    _Vertices[_CurPoint].z := 0;
    {$if defined(G2RM_FF)}
    _Vertices[_CurPoint].rhw := 1;
    {$endif}
    _Vertices[_CurPoint].Color := p^.Points[i].Color;
    _Vertices[_CurPoint].tu := p^.Points[i].u;
    _Vertices[_CurPoint].tv := p^.Points[i].v;
    Inc(_CurPoint);
  end;
  {$elseif defined(G2Gfx_OGL)}
  for i := 0 to p^.Count - 1 do
  begin
    {$if defined(G2RM_FF)}
    glColor4f(p^.Points[i].Color.r * Rcp255, p^.Points[i].Color.g * Rcp255, p^.Points[i].Color.b * Rcp255, p^.Points[i].Color.a * Rcp255);
    glTexCoord2f(p^.Points[i].u, p^.Points[i].v); glVertex3f(p^.Points[i].x, p^.Points[i].y, 0);
    {$elseif defined(G2RM_SM2)}
    glVertexAttrib4f(_AttribColor, p^.Points[i].Color.r * Rcp255, p^.Points[i].Color.g * Rcp255, p^.Points[i].Color.b * Rcp255, p^.Points[i].Color.a * Rcp255);
    glVertexAttrib2f(_AttribTexCoord, p^.Points[i].u, p^.Points[i].v); glVertexAttrib3f(_AttribPosition, p^.Points[i].x, p^.Points[i].y, 0);
    {$endif}
  end;
  Inc(_CurPoint, p^.Count);
  {$elseif defined(G2Gfx_GLES)}
  for i := 0 to p^.Count - 1 do
  _Indices[_CurIndex + i] := _CurPoint + i;
  Inc(_CurIndex, p^.Count);
  for i := 0 to p^.Count - 1 do
  begin
    _VertPositions[_CurPoint].x := p^.Points[i].x;
    _VertPositions[_CurPoint].y := p^.Points[i].y;
    _VertPositions[_CurPoint].z := 0;
    _VertColors[_CurPoint].SetValue(p^.Points[i].Color.r * Rcp255, p^.Points[i].Color.g * Rcp255, p^.Points[i].Color.b * Rcp255, p^.Points[i].Color.a * Rcp255);
    _VertTexCoords[_CurPoint].x := p^.Points[i].u;
    _VertTexCoords[_CurPoint].y := p^.Points[i].v;
    Inc(_CurPoint);
  end;
  {$endif}
end;

procedure TG2RenderControlPoly2D.Reset;
begin
  _QueueCount[_FillID^] := 0;
  _CurPoly := nil;
end;

constructor TG2RenderControlPoly2D.Create;
{$if defined(G2Gfx_D3D9)}
{$if defined(G2RM_SM2)}
  var ve: array[0..3] of TD3DVertexElement9;
{$endif}
{$endif}
begin
  inherited Create;
  _QueueCapacity[0] := 0;
  _QueueCapacity[1] := 0;
  _QueueCount[0] := 0;
  _QueueCount[1] := 0;
  _MaxPoints := 2048;
  {$if defined(G2RM_SM2)}
  _ShaderGroup := _Gfx.RequestShader('StandardShaders');
  {$endif}
  {$if defined(G2Gfx_D3D9)}
  {$if defined(G2RM_SM2)}
  ve[0] := D3DVertexElement(0, D3DDECLTYPE_FLOAT3, D3DDECLUSAGE_POSITION);
  ve[1] := D3DVertexElement(12, D3DDECLTYPE_D3DCOLOR, D3DDECLUSAGE_COLOR);
  ve[2] := D3DVertexElement(16, D3DDECLTYPE_FLOAT2, D3DDECLUSAGE_TEXCOORD);
  ve[3] := D3DDECL_END;
  _Gfx.Device.CreateVertexDeclaration(@ve, _Decl);
  {$endif}
  SetLength(_Vertices, _MaxPoints);
  {$elseif defined(G2Gfx_GLES)}
  SetLength(_VertPositions, _MaxPoints);
  SetLength(_VertColors, _MaxPoints);
  SetLength(_VertTexCoords, _MaxPoints);
  SetLength(_Indices, _MaxPoints);
  {$endif}
end;

destructor TG2RenderControlPoly2D.Destroy;
  var n, i: TG2IntS32;
begin
  for n := 0 to 1 do
  for i := 0 to _QueueCapacity[n] - 1 do
  Dispose(_Queue[n][i]);
  {$ifdef G2Gfx_D3D9}
  _Vertices := nil;
  {$endif}
  inherited Destroy;
end;
//TG2RenderControlPoly2D END

//TG2Display2D BEGIN
procedure TG2Display2D.SetMode(const Value: TG2Display2DMode);
begin
  if _Mode = Value then Exit;
  _Mode := Value;
  UpdateMode;
end;

procedure TG2Display2D.SetWidth(const Value: TG2IntS32);
begin
  if _Width = Value then Exit;
  _Width := Value;
  UpdateMode;
end;

procedure TG2Display2D.SetHeight(const Value: TG2IntS32);
begin
  if _Height = Value then Exit;
  _Height := Value;
  UpdateMode;
end;

procedure TG2Display2D.SetZoom(const Value: TG2Float);
begin
  _Zoom := Value;
  UpdateMode;
end;

procedure TG2Display2D.SetRotation(const Value: TG2Float);
begin
  _Rotation := Value;
  G2SinCos(-_Rotation, _rs, _rc);
end;

procedure TG2Display2D.UpdateMode;
begin
  case _Mode of
    d2dStretch:
    begin
      _ConvertCoord.z := g2.Params.Width / _Width * _Zoom;
      _ConvertCoord.w := g2.Params.Height / _Height * _Zoom;
      _ConvertCoord.x := g2.Params.Width * 0.5;
      _ConvertCoord.y := g2.Params.Height * 0.5;
    end;
    d2dFit:
    begin
      _ConvertCoord.z := g2.Params.Width / _Width * _Zoom;
      _ConvertCoord.w := g2.Params.Height / _Height * _Zoom;
      if _ConvertCoord.z < _ConvertCoord.w then
      _ConvertCoord.w := _ConvertCoord.z
      else
      _ConvertCoord.z := _ConvertCoord.w;
      _ConvertCoord.x := g2.Params.Width * 0.5;
      _ConvertCoord.y := g2.Params.Height * 0.5;
    end;
    d2dOversize:
    begin
      _ConvertCoord.z := g2.Params.Width / _Width * _Zoom;
      _ConvertCoord.w := g2.Params.Height / _Height * _Zoom;
      if _ConvertCoord.z > _ConvertCoord.w then
      _ConvertCoord.w := _ConvertCoord.z
      else
      _ConvertCoord.z := _ConvertCoord.w;
      _ConvertCoord.x := g2.Params.Width * 0.5;
      _ConvertCoord.y := g2.Params.Height * 0.5;
    end;
    d2dCenter:
    begin
      _ConvertCoord.z := _Zoom;
      _ConvertCoord.w := _Zoom;
      _ConvertCoord.x := g2.Params.Width * 0.5;
      _ConvertCoord.y := g2.Params.Height * 0.5;
    end;
  end;
  _WidthScr := Round(g2.Params.Width / _ConvertCoord.z);
  _HeightScr := Round(g2.Params.Height / _ConvertCoord.w);
  _ScreenScaleX := _WidthScr / g2.Params.Width;
  _ScreenScaleY := _HeightScr / g2.Params.Height;
  if _ScreenScaleX < _ScreenScaleY then
  begin
    _ScreenScaleMin := _ScreenScaleX;
    _ScreenScaleMax := _ScreenScaleY;
  end
  else
  begin
    _ScreenScaleMin := _ScreenScaleY;
    _ScreenScaleMax := _ScreenScaleX;
  end;
end;

function TG2Display2D.GetRotationVector: TG2Vec2;
begin
{$Warnings off}
  Result.SetValue(_rc, _rs);
{$Warnings on}
end;

function TG2Display2D.ConvertCoord(const Coord: TG2Vec2): TG2Vec2;
  var v: TG2Vec2;
begin
  v.SetValue(Coord.x - _Pos.x, Coord.y - _Pos.y);
  Result.x := (_rc * v.x - _rs * v.y) * _ConvertCoord.z + _ConvertCoord.x;
  Result.y := (_rs * v.x + _rc * v.y) * _ConvertCoord.w + _ConvertCoord.y;
end;

constructor TG2Display2D.Create;
begin
  inherited Create;
  _Width := 800;
  _Height := 600;
  _Mode := d2dFit;
  _Zoom := 1;
  _Rotation := 0;
  _rs := 0; _rc := 1;
  UpdateMode;
  _Pos := G2Vec2(_Width * 0.5, _Height * 0.5);
end;

destructor TG2Display2D.Destroy;
begin
  inherited Destroy;
end;

function TG2Display2D.TransformCoord(const Coord: TG2Vec2): TG2Vec2;
  var rc_rcp, rs_rcp: Single;
  var v: TG2Vec2;
begin
  v.SetValue((Coord.x - _ConvertCoord.x) / _ConvertCoord.z, (Coord.y - _ConvertCoord.y) / _ConvertCoord.w);
  v.y := (v.y * _rc - v.x * _rs) / (_rs * _rs + _rc * _rc);
  Result.x := (v.x + _rs * v.y) / _rc + _Pos.x;
  Result.y := v.y + _Pos.y;
end;

procedure TG2Display2D.PicQuadCol(
  const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2IntU32 = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  g2.PicQuadCol(
    ConvertCoord(Pos0), ConvertCoord(Pos1),
    ConvertCoord(Pos2), ConvertCoord(Pos3),
    Tex0, Tex1, Tex2, Tex3,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicQuadCol(
  const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  g2.PicQuadCol(
    ConvertCoord(G2Vec2(x0, y0)), ConvertCoord(G2Vec2(x1, y1)),
    ConvertCoord(G2Vec2(x2, y2)), ConvertCoord(G2Vec2(x3, y3)),
    G2Vec2(tu0, tv0), G2Vec2(tu1, tv1),
    G2Vec2(tu2, tv2), G2Vec2(tu3, tv3),
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicQuad(
  const Pos0, Pos1, Pos2, Pos3, Tex0, Tex1, Tex2, Tex3: TG2Vec2;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicQuadCol(
    Pos0, Pos1, Pos2, Pos3,
    Tex0, Tex1, Tex2, Tex3,
    Col, Col, Col, Col,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicQuad(
  const x0, y0, x1, y1, x2, y2, x3, y3, tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicQuadCol(
    x0, y0, x1, y1, x2, y2, x3, y3,
    tu0, tv0, tu1, tv1, tu2, tv2, tu3, tv3,
    Col, Col, Col, Col,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const Pos: TG2Vec2;
  const w, h: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const TexRect: TG2Vec4;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var Pos2: TG2Vec2;
begin
  Pos2.x := Pos.x + w; Pos2.y := Pos.y + h;
  PicQuadCol(
    Pos.x, Pos.y, Pos2.x, Pos.y, Pos.x, Pos2.y, Pos2.x, Pos2.y,
    TexRect.x, TexRect.y, TexRect.z, TexRect.y,
    TexRect.x, TexRect.w, TexRect.z, TexRect.w,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const x, y: TG2Float;
  const w, h: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const tu0, tv0, tu1, tv1: TG2Float;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var x2, y2: TG2Float;
begin
  x2 := x + w; y2 := y + h;
  PicQuadCol(
    x, y, x2, y, x, y2, x2, y2,
    tu0, tv0, tu1, tv0, tu0, tv1, tu1, tv1,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const Pos: TG2Vec2;
  const w, h: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var Pos2: TG2Vec2;
begin
  Pos2.x := Pos.x + w; Pos2.y := Pos.y + h;
  PicQuadCol(
    Pos.x, Pos.y, Pos2.x, Pos.y, Pos.x, Pos2.y, Pos2.x, Pos2.y,
    0, 0, Texture.SizeTU, 0,
    0, Texture.SizeTV, Texture.SizeTU, Texture.SizeTV,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const x, y: TG2Float;
  const w, h: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var x2, y2: TG2Float;
begin
  x2 := x + w; y2 := y + h;
  PicQuadCol(
    x, y, x2, y, x, y2, x2, y2,
    0, 0, Texture.SizeTU, 0,
    0, Texture.SizeTV, Texture.SizeTU, Texture.SizeTV,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const Pos: TG2Vec2;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var Pos2: TG2Vec2;
begin
  Pos2.x := Pos.x + Texture.Width; Pos2.y := Pos.y + Texture.Height;
  PicQuadCol(
    Pos.x, Pos.y, Pos2.x, Pos.y, Pos.x, Pos2.y, Pos2.x, Pos2.y,
    0, 0, Texture.SizeTU, 0,
    0, Texture.SizeTV, Texture.SizeTU, Texture.SizeTV,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const x, y: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var x2, y2: TG2Float;
begin
  x2 := x + Texture.Width; y2 := y + Texture.Height;
  PicQuadCol(
    x, y, x2, y, x, y2, x2, y2,
    0, 0, Texture.SizeTU, 0,
    0, Texture.SizeTV, Texture.SizeTU, Texture.SizeTV,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const Pos: TG2Vec2;
  const w, h: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(
    Pos.x, Pos.y, w, h,
    Col0, Col1, Col2, Col3,
    CenterX, CenterY, ScaleX, ScaleY, Angle,
    FlipU, FlipV, Texture,
    FrameWidth, FrameHeight, FrameID,
    BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRectCol(
  const x, y: TG2Float;
  const w, h: TG2Float;
  const Col0, Col1, Col2, Col3: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
  var v0, v1, v2, v3: TG2Vec2;
  var tr0, tr1, tc0, tc1, tc2, tc3: TG2Vec2;
  var wl, wh, hl, hh, s, c, tu, tv: TG2Float;
  var pc, px, py: TG2IntS32;
begin
  wl := -w * CenterX * ScaleX; wh := w * ScaleX + wl;
  hl := -h * CenterY * ScaleY; hh := h * ScaleY + hl;
  {$Hints off}
  G2SinCos(Angle, s, c);
  {$Hints on}
  v0.x := c * wl - s * hl + x; v0.y := s * wl + c * hl + y;
  v1.x := c * wh - s * hl + x; v1.y := s * wh + c * hl + y;
  v2.x := c * wl - s * hh + x; v2.y := s * wl + c * hh + y;
  v3.x := c * wh - s * hh + x; v3.y := s * wh + c * hh + y;
  tu := (FrameWidth / Texture.Width) * Texture.SizeTU;
  tv := (FrameHeight / Texture.Height) * Texture.SizeTV;
  pc := Texture.Width div FrameWidth;
  px := FrameID mod pc;
  py := FrameID div pc;
  tr0.SetValue(px * tu, py * tv);
  tr1.SetValue(px * tu + tu, py * tv + tv);
  if FlipU then
  begin
    tc0.x := tr1.x; tc1.x := tr0.x;
    tc2.x := tr1.x; tc3.x := tr0.x;
  end
  else
  begin
    tc0.x := tr0.x; tc1.x := tr1.x;
    tc2.x := tr0.x; tc3.x := tr1.x;
  end;
  if FlipV then
  begin
    tc0.y := tr1.y; tc2.y := tr0.y;
    tc1.y := tr1.y; tc3.y := tr0.y;
  end
  else
  begin
    tc0.y := tr0.y; tc2.y := tr1.y;
    tc1.y := tr0.y; tc3.y := tr1.y;
  end;
  PicQuadCol(
    v0, v1, v2, v3,
    tc0, tc1, tc2, tc3,
    Col0, Col1, Col2, Col3,
    Texture, BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRect(
  const Pos: TG2Vec2; const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Display2D.PicRect(
  const x, y: TG2Float; const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Display2D.PicRect(
  const Pos: TG2Vec2;
  const w, h: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos, w, h, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Display2D.PicRect(
  const x, y: TG2Float;
  const w, h: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, w, h, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Display2D.PicRect(
  const Pos: TG2Vec2;
  const w, h: TG2Float;
  const TexRect: TG2Vec4;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(Pos, w, h, TexRect, Col, Col, Col, Col, Texture, BlendMode, Filtering);
end;

procedure TG2Display2D.PicRect(
  const x, y: TG2Float;
  const w, h: TG2Float;
  const tu0, tv0, tu1, tv1: TG2Float;
  const Col: TG2Color;
  const Texture: TG2Texture2DBase;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(x, y, w, h, Col, Col, Col, Col, tu0, tv0, tu1, tv1, Texture, BlendMode, Filtering);
end;

procedure TG2Display2D.PicRect(
  const Pos: TG2Vec2;
  const w, h: TG2Float;
  const Col: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(
    Pos, w, h,
    Col, Col, Col, Col,
    CenterX, CenterY, ScaleX, ScaleY, Angle,
    FlipU, FlipV, Texture,
    FrameWidth, FrameHeight, FrameID,
    BlendMode, Filtering
  );
end;

procedure TG2Display2D.PicRect(
  const x, y: TG2Float;
  const w, h: TG2Float;
  const Col: TG2Color;
  const CenterX, CenterY, ScaleX, ScaleY, Angle: TG2Float;
  const FlipU, FlipV: Boolean;
  const Texture: TG2Texture2DBase;
  const FrameWidth, FrameHeight: TG2IntS32;
  const FrameID: TG2IntS32;
  const BlendMode: TG2BlendMode = bmNormal;
  const Filtering: TG2Filter = tfPoint
);
begin
  PicRectCol(
    x, y, w, h,
    Col, Col, Col, Col,
    CenterX, CenterY, ScaleX, ScaleY, Angle,
    FlipU, FlipV, Texture,
    FrameWidth, FrameHeight, FrameID,
    BlendMode, Filtering
  );
end;

procedure TG2Display2D.PrimBegin(const PrimType: TG2PrimType; const BlendMode: TG2BlendMode);
begin
  g2.PrimBegin(PrimType, BlendMode);
end;

procedure TG2Display2D.PrimEnd;
begin
  g2.PrimEnd;
end;

procedure TG2Display2D.PrimAdd(const x, y: TG2Float; const Color: TG2Color);
begin
  g2.PrimAdd(ConvertCoord(G2Vec2(x, y)), Color);
end;

procedure TG2Display2D.PrimAdd(const v: TG2Vec2; const Color: TG2Color);
begin
  g2.PrimAdd(ConvertCoord(v), Color);
end;

procedure TG2Display2D.PrimLineCol(const Pos0, Pos1: TG2Vec2; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimEnd;
end;

procedure TG2Display2D.PrimLineCol(const x0, y0, x1, y1: TG2Float; const Col0, Col1: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimEnd;
end;

procedure TG2Display2D.PrimTriCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimEnd;
end;

procedure TG2Display2D.PrimTriCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimEnd;
end;

procedure TG2Display2D.PrimQuadCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos3, Col3);
  PrimEnd;
end;

procedure TG2Display2D.PrimQuadCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x3, y3, Col3);
  PrimEnd;
end;

procedure TG2Display2D.PrimQuad(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos0, Col);
  PrimAdd(Pos1, Col);
  PrimAdd(Pos2, Col);
  PrimAdd(Pos2, Col);
  PrimAdd(Pos1, Col);
  PrimAdd(Pos3, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimQuad(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x0, y0, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x2, y2, Col);
  PrimAdd(x2, y2, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x3, y3, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimRectCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x, y, Col0);
  PrimAdd(x1, y, Col1);
  PrimAdd(x, y1, Col2);
  PrimAdd(x, y1, Col2);
  PrimAdd(x1, y, Col1);
  PrimAdd(x1, y1, Col3);
  PrimEnd;
end;

procedure TG2Display2D.PrimRect(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x, y, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x1, y1, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimRectHollowCol(const x, y, w, h: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x, y, Col0);
  PrimAdd(x1, y, Col1);
  PrimAdd(x1, y, Col1);
  PrimAdd(x1, y1, Col3);
  PrimAdd(x1, y1, Col3);
  PrimAdd(x, y1, Col2);
  PrimAdd(x, y1, Col2);
  PrimAdd(x, y, Col0);
  PrimEnd;
end;

procedure TG2Display2D.PrimRectHollow(const x, y, w, h: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
  var x1, y1: TG2Float;
begin
  x1 := x + w;
  y1 := y + h;
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x, y, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x1, y, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x1, y1, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x, y1, Col);
  PrimAdd(x, y, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimCircleCol(const Pos: TG2Vec2; const Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c: TG2Float;
  var v, v2: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(Pos, Col0);
  PrimAdd(v + Pos, Col1);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    v2 := v + Pos;
    PrimAdd(v2, Col1);
    PrimAdd(Pos, Col0);
    PrimAdd(v2, Col1);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  PrimAdd(v + Pos, Col1);
  PrimEnd;
end;

procedure TG2Display2D.PrimCircleCol(const x, y, Radius: TG2Float; const Col0, Col1: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c, cx, cy: TG2Float;
  var v: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  PrimBegin(ptTriangles, BlendMode);
  PrimAdd(x, y, Col0);
  PrimAdd(v.x + x, v.y + y, Col1);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    cx := v.x + x; cy := v.y + y;
    PrimAdd(cx, cy, Col1);
    PrimAdd(x, y, Col0);
    PrimAdd(cx, cy, Col1);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  PrimAdd(v.x + x, v.y + y, Col1);
  PrimEnd;
end;

procedure TG2Display2D.PrimTriHollowCol(const Pos0, Pos1, Pos2: TG2Vec2; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos0, Col0);
  PrimEnd;
end;

procedure TG2Display2D.PrimTriHollowCol(const x0, y0, x1, y1, x2, y2: TG2Float; const Col0, Col1, Col2: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x0, y0, Col0);
  PrimEnd;
end;

procedure TG2Display2D.PrimQuadHollowCol(const Pos0, Pos1, Pos2, Pos3: TG2Vec2; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col0);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos1, Col1);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos2, Col2);
  PrimAdd(Pos3, Col3);
  PrimAdd(Pos3, Col3);
  PrimAdd(Pos0, Col0);
  PrimEnd;
end;

procedure TG2Display2D.PrimQuadHollowCol(const x0, y0, x1, y1, x2, y2, x3, y3: TG2Float; const Col0, Col1, Col2, Col3: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col0);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x1, y1, Col1);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x2, y2, Col2);
  PrimAdd(x3, y3, Col3);
  PrimAdd(x3, y3, Col3);
  PrimAdd(x0, y0, Col0);
  PrimEnd;
end;

procedure TG2Display2D.PrimCircleHollow(const Pos: TG2Vec2; const Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c: TG2Float;
  var v, v2: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  v2 := v + Pos;
  PrimBegin(ptLines, BlendMode);
  PrimAdd(v2, Col);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    v2 := v + Pos;
    PrimAdd(v2, Col);
    PrimAdd(v2, Col);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  v2 := v + Pos;
  PrimAdd(v2, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimCircleHollow(const x, y, Radius: TG2Float; const Col: TG2Color; const Segments: TG2IntS32 = 16; const BlendMode: TG2BlendMode = bmNormal);
  var a, s, c, cx, cy: TG2Float;
  var v: TG2Vec2;
  var i: TG2IntS32;
begin
  a := TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v.SetValue(Radius, 0);
  cx := v.x + x; cy := v.y + y;
  PrimBegin(ptLines, BlendMode);
  PrimAdd(cx, cy, Col);
  for i := 0 to Segments - 2 do
  begin
    v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
    cx := v.x + x; cy := v.y + y;
    PrimAdd(cx, cy, Col);
    PrimAdd(cx, cy, Col);
  end;
  v.SetValue(c * v.x - s * v.y, s * v.x + c * v.y);
  cx := v.x + x; cy := v.y + y;
  PrimAdd(cx, cy, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimLine(const Pos0, Pos1: TG2Vec2; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(Pos0, Col);
  PrimAdd(Pos1, Col);
  PrimEnd;
end;

procedure TG2Display2D.PrimLine(const x0, y0, x1, y1: TG2Float; const Col: TG2Color; const BlendMode: TG2BlendMode = bmNormal);
begin
  PrimBegin(ptLines, BlendMode);
  PrimAdd(x0, y0, Col);
  PrimAdd(x1, y1, Col);
  PrimEnd;
end;
//TG2Display2D END

//TG2S2DObject BEGIN
procedure TG2S2DObject.Initialize;
begin

end;

procedure TG2S2DObject.Finalize;
begin

end;

constructor TG2S2DObject.Create(const Scene: TG2Scene2D);
begin
  inherited Create;
  _Scene := Scene;
  _Scene._Objects.Add(Self);
  Initialize;
end;

destructor TG2S2DObject.Destroy;
begin
  Finalize;
  _Scene._Objects.Remove(Self);
  inherited Destroy;
end;
//TG2S2DObject END

//TG2S2DCollider BEGIN
procedure TG2S2DCollider.UpdateBounds;
  var i: TG2IntS32;
begin
  _Center := PG2S2DPointVerlet(_Points[0])^.Pos;
  _Bounds.Left := Round(_Center.x) - 1;
  _Bounds.Top := Round(_Center.y) - 1;
  _Bounds.Right := _Bounds.Left + 2;
  _Bounds.Bottom := _Bounds.Top + 2;
  for i := 1 to _Points.Count - 1 do
  begin
    _Center := _Center + PG2S2DPointVerlet(_Points[i])^.Pos;
    if PG2S2DPointVerlet(_Points[i])^.Pos.x < _Bounds.Left then _Bounds.Left := Round(PG2S2DPointVerlet(_Points[i])^.Pos.x) - 1;
    if PG2S2DPointVerlet(_Points[i])^.Pos.y < _Bounds.Top then _Bounds.Top := Round(PG2S2DPointVerlet(_Points[i])^.Pos.y) - 1;
    if PG2S2DPointVerlet(_Points[i])^.Pos.x > _Bounds.Right then _Bounds.Right := Round(PG2S2DPointVerlet(_Points[i])^.Pos.x) + 1;
    if PG2S2DPointVerlet(_Points[i])^.Pos.y > _Bounds.Bottom then _Bounds.Bottom := Round(PG2S2DPointVerlet(_Points[i])^.Pos.y) + 1;
  end;
  _Center := _Center / _Points.Count;
end;

procedure TG2S2DCollider.Initialize;
begin
  _Points.Clear;
  _Edges.Clear;
  _Springs.Clear;
  _Mass := 1;
  _Friction := 1;
  _BindPoint := nil;
  _IsStatic := False;
  _Active := False;
end;

procedure TG2S2DCollider.Finalize;
begin
  Reset;
end;

procedure TG2S2DCollider.Reset;
  var i: TG2IntS32;
begin
  Active := False;
  for i := 0 to _Edges.Count - 1 do
  Dispose(PG2S2DEdge(_Edges[i]));
  _Edges.Clear;
  for i := 0 to _Springs.Count - 1 do
  Dispose(PG2S2DSpring(_Springs[i]));
  _Springs.Clear;
  for i := 0 to _Points.Count - 1 do
  Dispose(PG2S2DPointVerlet(_Points[i]));
  _Points.Clear;
  _Mass := 1;
  _Friction := 1;
  _BindPoint := nil;
  _IsStatic := False;
end;

function TG2S2DCollider.GetPoint(const Index: TG2IntS32): PG2S2DPointVerlet;
begin
  Result := PG2S2DPointVerlet(_Points[Index]);
end;

function TG2S2DCollider.GetEdge(const Index: TG2IntS32): PG2S2DEdge;
begin
  Result := PG2S2DEdge(_Edges[Index]);
end;

function TG2S2DCollider.GetSpring(const Index: TG2IntS32): PG2S2DSpring;
begin
  Result := PG2S2DSpring(_Springs[Index]);
end;

function TG2S2DCollider.GetPointCount: TG2IntS32;
begin
  Result := _Points.Count;
end;

function TG2S2DCollider.GetEdgeCount: TG2IntS32;
begin
  Result := _Edges.Count;
end;

function TG2S2DCollider.GetSpringCount: TG2IntS32;
begin
  Result := _Springs.Count;
end;

function TG2S2DCollider.GetRotation: TG2Float;
begin
  if _BindPoint = nil then Exit;
  Result := (_BindPoint^.Pos - _Center).AngleOX - _BindRotation;
end;

procedure TG2S2DCollider.SetActive(const Value: Boolean);
begin
  if _Active <> Value then
  begin
    _Active := Value;
    if _Active then
    begin
      _Group := _Scene.CollisionGroupGet(_Bounds);
      _Scene.CollisionGroupAdd(_Group, Self);
      _Scene._CollidersActive.Add(Self);
    end
    else
    begin
      _Scene._CollidersActive.Remove(Self);
      _Scene.CollisionGroupRemove(_Group, Self);
    end;
  end;
end;

procedure TG2S2DCollider.EditBegin;
begin
  Reset;
end;

procedure TG2S2DCollider.EditEnd;
  var i: TG2IntS32;
  var d, md: TG2Float;
begin
  UpdateBounds;
  _BindPoint := PG2S2DPointVerlet(_Points[0]);
  md := (_Center - _BindPoint^.Pos).Len;
  for i := 1 to _Points.Count - 1 do
  begin
    d := (_Center - PG2S2DPointVerlet(_Points[i])^.Pos).Len;
    if d > md then
    begin
      md := d;
      _BindPoint := PG2S2DPointVerlet(_Points[i]);
    end;
  end;
  _BindRotation := (_BindPoint^.Pos - _Center).AngleOX;
end;

procedure TG2S2DCollider.AddPoint(const x, y: TG2Float);
  var pv: PG2S2DPointVerlet;
begin
  New(pv);
  pv^.Pos.SetValue(x, y);
  pv^.PosPrev.SetValue(x, y);
  _Points.Add(pv);
end;

procedure TG2S2DCollider.AddEdge(const p0, p1: TG2IntS32);
  var e: PG2S2DEdge;
begin
  New(e);
  e^.Pos[0] := _Points[p0];
  e^.Pos[1] := _Points[p1];
  _Edges.Add(e);
end;

procedure TG2S2DCollider.AddSpring(const p0, p1: TG2IntS32; const Hardness: TG2Float = 0.9);
  var s: PG2S2DSpring;
begin
  New(s);
  s^.Pos[0] := _Points[p0];
  s^.Pos[1] := _Points[p1];
  s^.Dist := (s^.Pos[0]^.Pos - s^.Pos[1]^.Pos).Len;
  s^.Hardness := Hardness;
  _Springs.Add(s);
end;

procedure TG2S2DCollider.AutoSprings;
  var i, j: TG2IntS32;
begin
  for i := 0 to _Points.Count - 1 do
  for j := i + 1 to _Points.Count - 1 do
  AddSpring(i, j);
end;

procedure TG2S2DCollider.AutoEdges;
  var i: TG2IntS32;
begin
  for i := 0 to _Points.Count - 2 do
  AddEdge(i, i + 1);
  AddEdge(_Points.Count - 1, 0);
end;

procedure TG2S2DCollider.MakeBox(const x, y, w, h: TG2Float);
begin
  EditBegin;
  AddPoint(x, y);
  AddPoint(x + w, y);
  AddPoint(x + w, y + h);
  AddPoint(x, y + h);
  AutoEdges;
  AutoSprings;
  EditEnd;
end;

procedure TG2S2DCollider.Project(const Axis: TG2Vec2; var ProjMin, ProjMax: TG2Float);
  var i: TG2IntS32;
  var d: TG2Float;
begin
  d := Axis.Dot(PG2S2DPointVerlet(_Points[0])^.Pos);
  ProjMin := d;
  ProjMax := d;
  for i := 1 to _Points.Count - 1 do
  begin
    d := Axis.Dot(PG2S2DPointVerlet(_Points[i])^.Pos);
    if d < ProjMin then ProjMin := d
    else if d > ProjMax then ProjMax := d;
  end;
end;

procedure TG2S2DCollider.AddForce(const f: TG2Vec2);
begin
  _Force := _Force + f;
end;

procedure TG2S2DCollider.Update;
  var i, n: TG2IntS32;
  var v: TG2Vec2;
  var d: TG2Float;
  var p0, p1: PG2S2DPointVerlet;
  var s: PG2S2DSpring;
begin
  if not _IsStatic then
  begin
    for i := 0 to _Points.Count - 1 do
    begin
      p0 := PG2S2DPointVerlet(_Points[i]);
      v := p0^.Pos - p0^.PosPrev + _Force + _Scene.Gravity;
      p0^.PosPrev := p0^.Pos;
      p0^.Pos := p0^.Pos + v;
    end;
    _Force.SetValue(0, 0);
    for n := 0 to 3 do
    for i := 0 to _Springs.Count - 1 do
    begin
      s := PG2S2DSpring(_Springs[i]);
      p0 := s^.Pos[0]; p1 := s^.Pos[1];
      v := p1^.Pos - p0^.Pos;
      d := v.Len; d := (s^.Dist - d) * 0.5 * s^.Hardness;
      v := v.Norm * d;
      p0^.Pos := p0^.Pos - v; p1^.Pos := p1^.Pos + v;
    end;
  end;
  UpdateBounds;
end;

procedure TG2S2DCollider.Render;
  var i: TG2IntS32;
begin
  g2.PrimQuadHollowCol(
    _Bounds.Left, _Bounds.Top, _Bounds.Right, _Bounds.Top,
    _Bounds.Left, _Bounds.Bottom, _Bounds.Right, _Bounds.Bottom,
    $ffffff00, $ffffff00, $ffffff00, $ffffff00
  );
  for i := 0 to _Springs.Count - 1 do
  g2.PrimLine(PG2S2DSpring(_Springs[i])^.Pos[0]^.Pos, PG2S2DSpring(_Springs[i])^.Pos[1]^.Pos, $ff00ff00);
  for i := 0 to _Edges.Count - 1 do
  g2.PrimLine(PG2S2DEdge(_Edges[i])^.Pos[0]^.Pos, PG2S2DEdge(_Edges[i])^.Pos[1]^.Pos, $ffff0000);
end;
//TG2S2DCollider END

//TG2S2DFrame BEGIN
procedure TG2S2DFrame.Initialize;
begin
  _Active := False;
  _Scene._Frames.Add(Self);
  _Collider := nil;
end;

procedure TG2S2DFrame.Finalize;
begin
  Active := False;
  _Scene._Frames.Remove(Self);
end;

procedure TG2S2DFrame.Activate;
begin

end;

procedure TG2S2DFrame.Deactivate;
begin

end;

procedure TG2S2DFrame.SetActive(const Value: Boolean);
begin
  if Value <> _Active then
  begin
    _Active := Value;
    if _Active then
    begin
      _Scene._Frames.Remove(Self);
      _Scene._FramesActive.Add(Self);
      Activate;
    end
    else
    begin
      Deactivate;
      _Scene._FramesActive.Remove(Self);
      _Scene._Frames.Add(Self);
    end;
  end;
end;

procedure TG2S2DFrame.SetPos(const Value: TG2Vec2);
begin
  _Pos := Value;
end;

procedure TG2S2DFrame.SetAng(const Value: TG2Float);
begin
  _Ang := Value;
end;

procedure TG2S2DFrame.Render;
begin

end;

procedure TG2S2DFrame.Update;
begin
  if _Collider <> nil then
  begin
    _Pos := _Collider.Position;
    _Ang := _Collider.Rotation;
  end;
end;
//TG2S2DFrame END

//TG2S2DSprite BEGIN
procedure TG2S2DSprite.Activate;
begin
  Collider := TG2S2DCollider.Create(_Scene);
  Collider.MakeBox(_Pos.x - _Texture.Width div 2, _Pos.y - _Texture.Height div 2, _Texture.Width, _Texture.Height);
  Collider.Active := True;
end;

procedure TG2S2DSprite.Deactivate;
begin
  if _Collider <> nil then
  _Collider.Free;
end;

procedure TG2S2DSprite.Render;
begin
  inherited Render;
  g2.PicRectCol(
    Pos, Texture.Width, Texture.Height,
    $ffffffff, $ffffffff, $ffffffff, $ffffffff,
    0.5, 0.5, 1, 1, Ang, False, False,
    Texture, Texture.Width, Texture.Height, 0,
    bmNormal, tfLinear
  );
end;

procedure TG2S2DSprite.Update;
begin
  inherited Update;
end;
//TG2S2DSprite END

//TG2S2DShape BEGIN
procedure TG2S2DShape.Initialize;
begin
  Collider := TG2S2DCollider.Create(_Scene);
end;

procedure TG2S2DShape.Finalize;
begin
  Collider.Free;
end;

procedure TG2S2DShape.Activate;
begin
  Collider.Active := True;
end;

procedure TG2S2DShape.Deactivate;
begin
  Collider.Active := False;
end;

procedure TG2S2DShape.EditBegin;
begin
  Collider.EditBegin;
  _Pts := nil;
end;

procedure TG2S2DShape.EditEnd;
begin
  Collider.AutoSprings;
  Collider.AutoEdges;
  Collider.EditEnd;
end;

procedure TG2S2DShape.EditAddPoint(const x, y, u, v: TG2Float; const Color: TG2Color);
begin
  SetLength(_Pts, Length(_Pts) + 1);
  _Pts[High(_Pts)].x := x;
  _Pts[High(_Pts)].y := y;
  _Pts[High(_Pts)].u := u;
  _Pts[High(_Pts)].v := v;
  _Pts[High(_Pts)].Color := Color;
  Collider.AddPoint(x, y);
end;

procedure TG2S2DShape.Render;
  var i, j: TG2IntS32;
begin
  g2.Gfx.Poly2D.PolyBegin(ptTriangles, _Texture);
  for i := 1 to High(_Pts) - 1 do
  begin
    j := i + 1;
    g2.Gfx.Poly2D.PolyAdd(_Pts[0].x, _Pts[0].y, _Pts[0].u, _Pts[0].v, _Pts[0].Color);
    g2.Gfx.Poly2D.PolyAdd(_Pts[i].x, _Pts[i].y, _Pts[i].u, _Pts[i].v, _Pts[i].Color);
    g2.Gfx.Poly2D.PolyAdd(_Pts[j].x, _Pts[j].y, _Pts[j].u, _Pts[j].v, _Pts[j].Color);
  end;
  g2.Gfx.Poly2D.PolyEnd;
end;

procedure TG2S2DShape.Update;
  var i: TG2IntS32;
begin
  for i := 0 to High(_Pts) do
  begin
    _Pts[i].x := Collider.Points[i]^.Pos.x;
    _Pts[i].y := Collider.Points[i]^.Pos.y;
  end;
end;
//TG2S2DShape END

//TG2Scene2D BEGIN
function TG2Scene2D.CollisionGroupNew(const R: TRect): PG2S2DCollisionGroup;
begin
  New(Result);
  Result^.Bounds := R;
  Result^.Collisions.Clear;
  Result^.MergeCheckTime := G2Time();
  Result^.Freed := False;
  _CollisionGroups.Add(Result);
end;

procedure TG2Scene2D.CollisionGroupFree(const g: PG2S2DCollisionGroup);
begin
  _CollisionGroups.Remove(g);
  Dispose(g);
end;

function TG2Scene2D.CollisionGroupGet(const R: TRect): PG2S2DCollisionGroup;
  var i: TG2IntS32;
begin
  for i := 0 to _CollisionGroups.Count - 1 do
  begin
    Result := PG2S2DCollisionGroup(_CollisionGroups[i]);
    if G2RectInRect(
      Rect(Result^.Bounds.Left - 1, Result^.Bounds.Top - 1, Result^.Bounds.Right + 1, Result^.Bounds.Bottom + 1),
      R
    ) then Exit;
  end;
  Result := CollisionGroupNew(R);
end;

procedure TG2Scene2D.CollisionGroupAdd(const g: PG2S2DCollisionGroup; const c: TG2S2DCollider);
begin
  g^.Collisions.Add(c);
  c.Group := g;
  if c.Bounds.Left < g^.Bounds.Left then g^.Bounds.Left := c.Bounds.Left;
  if c.Bounds.Right > g^.Bounds.Right then g^.Bounds.Right := c.Bounds.Right;
  if c.Bounds.Top < g^.Bounds.Top then g^.Bounds.Top := c.Bounds.Top;
  if c.Bounds.Bottom > g^.Bounds.Bottom then g^.Bounds.Bottom := c.Bounds.Bottom;
end;

procedure TG2Scene2D.CollisionGroupRemove(const g: PG2S2DCollisionGroup; const c: TG2S2DCollider);
begin
  c.Group := nil;
  g^.Collisions.Remove(c);
end;

procedure TG2Scene2D.CollisionGroupSplit(const g: PG2S2DCollisionGroup);
  var g1: PG2S2DCollisionGroup;
  var R0, R1: TRect;
  var x, y, w, h, i: TG2IntS32;
  var c: TG2S2DCollider;
begin
  w := g^.Bounds.Right - g^.Bounds.Left;
  h := g^.Bounds.Bottom - g^.Bounds.Top;
  if w > h then
  begin
    w := w div 2;
    x := g^.Bounds.Left + w;
    R0 := Rect(g^.Bounds.Left, g^.Bounds.Top, x, g^.Bounds.Bottom);
    R1 := Rect(x, g^.Bounds.Top, g^.Bounds.Right, g^.Bounds.Bottom);
    g^.Bounds := R0;
    g1 := CollisionGroupNew(R1);
    for i := g^.Collisions.Count - 1 downto 0 do
    if TG2S2DCollider(g^.Collisions[i]).Center.x > x then
    begin
      c := TG2S2DCollider(g^.Collisions[i]);
      CollisionGroupRemove(g, c);
      CollisionGroupAdd(g1, c);
    end;
  end
  else
  begin
    h := h div 2;
    y := g^.Bounds.Top + h;
    R0 := Rect(g^.Bounds.Left, g^.Bounds.Top, g^.Bounds.Right, y);
    R1 := Rect(g^.Bounds.Left, y, g^.Bounds.Right, g^.Bounds.Bottom);
    g^.Bounds := R0;
    g1 := CollisionGroupNew(R1);
    for i := g^.Collisions.Count - 1 downto 0 do
    if TG2S2DCollider(g^.Collisions[i]).Center.y > y then
    begin
      c := TG2S2DCollider(g^.Collisions[i]);
      CollisionGroupRemove(g, c);
      CollisionGroupAdd(g1, c);
    end;
  end;
end;

procedure TG2Scene2D.CollisionGroupMerge(const g0, g1: PG2S2DCollisionGroup);
  var i: TG2IntS32;
  var c: TG2S2DCollider;
begin
  for i := g1^.Collisions.Count - 1 downto 0 do
  begin
    c := TG2S2DCollider(g1^.Collisions[i]);
    CollisionGroupRemove(g1, c);
    CollisionGroupAdd(g0, c);
  end;
  g1^.Freed := True;
  _CollisionGroupsFree.Add(g1);
end;

procedure TG2Scene2D.CollisionGroupUpdate(const g: PG2S2DCollisionGroup);
  var i: TG2IntS32;
  var t: TG2IntU32;
  var r: TRect;
  var g1: PG2S2DCollisionGroup;
begin
  if g^.Collisions.Count > 0 then
  begin
    g^.Bounds := TG2S2DCollider(g^.Collisions[0]).Bounds;
    for i := 1 to g^.Collisions.Count - 1 do
    begin
      if TG2S2DCollider(g^.Collisions[i]).Bounds.Left < g^.Bounds.Left then g^.Bounds.Left := TG2S2DCollider(g^.Collisions[i]).Bounds.Left;
      if TG2S2DCollider(g^.Collisions[i]).Bounds.Top < g^.Bounds.Top then g^.Bounds.Top := TG2S2DCollider(g^.Collisions[i]).Bounds.Top;
      if TG2S2DCollider(g^.Collisions[i]).Bounds.Right > g^.Bounds.Right then g^.Bounds.Right := TG2S2DCollider(g^.Collisions[i]).Bounds.Right;
      if TG2S2DCollider(g^.Collisions[i]).Bounds.Bottom > g^.Bounds.Bottom then g^.Bounds.Bottom := TG2S2DCollider(g^.Collisions[i]).Bounds.Bottom;
    end;
    t := G2Time();
    if (g^.Collisions.Count > 64)
    or (
      (g^.Collisions.Count > 8)
      and (
        (g^.Bounds.Right - g^.Bounds.Left > _MaxCollisionGroupSize)
        or (g^.Bounds.Bottom - g^.Bounds.Top > _MaxCollisionGroupSize)
      )
    )then
    CollisionGroupSplit(g)
    else if (t - g^.MergeCheckTime > 2000) then
    begin
      g^.MergeCheckTime := t;
      for i := 0 to _CollisionGroups.Count - 1  do
      if PG2S2DCollisionGroup(_CollisionGroups[i]) <> g then
      begin
        g1 := PG2S2DCollisionGroup(_CollisionGroups[i]);
        if (g^.Collisions.Count + g1^.Collisions.Count < 64)
        and G2RectInRect(g^.Bounds, g1^.Bounds) then
        begin
          if g^.Bounds.Left < g1^.Bounds.Left then r.Left := g^.Bounds.Left else r.Left := g1^.Bounds.Left;
          if g^.Bounds.Right > g1^.Bounds.Right then r.Right := g^.Bounds.Right else r.Right := g1^.Bounds.Right;
          if g^.Bounds.Top < g1^.Bounds.Top then r.Top := g^.Bounds.Top else r.Top := g1^.Bounds.Top;
          if g^.Bounds.Bottom > g1^.Bounds.Bottom then r.Bottom := g^.Bounds.Bottom else r.Bottom := g1^.Bounds.Bottom;
          if (r.Right - r.Left < _MaxCollisionGroupSize - 100)
          and (r.Bottom - r.Top < _MaxCollisionGroupSize - 100) then
          begin
            CollisionGroupMerge(g, g1);
            Break;
          end;
        end;
      end;
    end;
  end
  else
  begin
    g^.Freed := True;
    _CollisionGroupsFree.Add(g);
  end;
end;

procedure TG2Scene2D.Initialize;
begin
  _Objects.Clear;
  _Frames.Clear;
  _FramesActive.Clear;
  _CollidersActive.Clear;
  _CollisionGroups.Clear;
  _CollisionGroupsFree.Clear;
  _MaxCollisionGroupSize := 512;
  _Gravity.SetValue(0, 0);
  _Debug := False;
end;

procedure TG2Scene2D.Finalize;
begin
  while _Objects.Count > 0 do
  TG2S2DObject(_Objects[0]).Free;
  while _CollisionGroups.Count > 0 do
  CollisionGroupFree(PG2S2DCollisionGroup(_CollisionGroups[0]));
end;

procedure TG2Scene2D.Collide(const c0, c1: TG2S2DCollider);
  function Overlap(const MinA, MaxA, MinB, MaxB: TG2Float): TG2Float;
  begin
    if MaxA > MaxB then
    Result := MaxB - MinA
    else
    Result := MaxA - MinB;
  end;
  var TmpEdge, Edge: PG2S2DEdge;
  var Point: PG2S2DPointVerlet;
  var nt, n: TG2Vec2;
  var i: TG2IntS32;
  var mtd, d, md, MinA, MaxA, MinB, MaxB, dx, dy, ev0, ev1: TG2Float;
  var TmpColEdge, TmpColPoint, ColEdge, ColPoint: TG2S2DCollider;
  var EdgeMassBias, PointMassBias: TG2Float;
  var PointFriction: TG2Vec2;
  var EdgeFriction: array[0..1] of TG2Vec2;
  var PointVel: TG2Vec2;
  var EdgeVel: array[0..1] of TG2Vec2;
  var TotalFriction: TG2Vec2;
begin
  if c0.IsStatic and c1.IsStatic then Exit;
  md := 1000000;
  if G2RectInRect(c0.Bounds, c1.Bounds) then
  begin
    for i := 0 to c0.EdgeCount + c1.EdgeCount - 1 do
    begin
      if i < c0.EdgeCount then
      begin
        TmpEdge := c0.Edges[i];
        TmpColEdge := c0;
        TmpColPoint := c1;
      end
      else
      begin
        TmpEdge := c1.Edges[i - c0.EdgeCount];
        TmpColEdge := c1;
        TmpColPoint := c0;
      end;
      nt := -(TmpEdge^.Pos[1]^.Pos - TmpEdge^.Pos[0]^.Pos).Norm.Perp;
      {$Hints off}
      TmpColEdge.Project(nt, MinA, MaxA);
      TmpColPoint.Project(nt, MinB, MaxB);
      {$Hints on}
      d := Overlap(MinA, MaxA, MinB, MaxB);
      if d <= 0 then Exit;
      if d < md then
      begin
        Edge := TmpEdge;
        ColEdge := TmpColEdge;
        ColPoint := TmpColPoint;
        n := nt;
        md := d;
      end;
    end;
    mtd := md;
    if n.Dot(ColPoint.Center - ColEdge.Center) < 0 then n := -n;
    nt := n.Perp;
    Point := ColPoint.Points[0];
    md := n.Dot(Point^.Pos);
    for i := 1 to ColPoint.PointCount - 1 do
    begin
      d := n.Dot(ColPoint.Points[i]^.Pos);
      if d < md then
      begin
        md := d;
        Point := ColPoint.Points[i];
      end;
    end;
    d := 1 / (ColEdge.Mass + ColPoint.Mass);
    if ColEdge.IsStatic then
    begin
      EdgeMassBias := 0;
      PointMassBias := 1;
    end
    else if ColPoint.IsStatic then
    begin
      EdgeMassBias := 1;
      PointMassBias := 0;
    end
    else
    begin
      PointMassBias := ColEdge.Mass * d;
      EdgeMassBias := ColPoint.Mass * d;
    end;
    n := n * mtd;
    dx := Edge^.Pos[1]^.Pos.x - Edge^.Pos[0]^.Pos.x;
    dy := Edge^.Pos[1]^.Pos.y - Edge^.Pos[0]^.Pos.y;
    if Abs(dx) > Abs(dy) then
    d := (Point^.Pos.x - n.x - Edge^.Pos[0]^.Pos.x) / dx
    else
    d := (Point^.Pos.y - n.y - Edge^.Pos[0]^.Pos.y) / dy;
    md := 1 / (Sqr(d) + Sqr(1 - d));
    ev0 := (1 - d);
    ev1 := d;

    EdgeVel[0] := Edge^.Pos[0]^.Pos - Edge^.Pos[0]^.PosPrev;
    EdgeVel[1] := Edge^.Pos[1]^.Pos - Edge^.Pos[1]^.PosPrev;
    PointVel := Point^.Pos - Point^.PosPrev;
    d := nt.Dot(PointVel);
    PointFriction := -nt * nt.Dot(PointVel);
    EdgeFriction[0] := -nt * (nt.Dot(EdgeVel[0]) * ev0);
    EdgeFriction[1] := -nt * (nt.Dot(EdgeVel[1]) * ev1);
    TotalFriction := (PointFriction - EdgeFriction[0] - EdgeFriction[1]) * (c0.Friction * c1.Friction);
    PointVel := PointVel + TotalFriction * PointMassBias;
    EdgeVel[0] := EdgeVel[0] - TotalFriction * (EdgeMassBias * ev0);
    EdgeVel[1] := EdgeVel[1] - TotalFriction * (EdgeMassBias * ev1);

    Point^.PosPrev := Point^.Pos - PointVel;
    Edge^.Pos[0]^.PosPrev := Edge^.Pos[0]^.Pos - EdgeVel[0];
    Edge^.Pos[1]^.PosPrev := Edge^.Pos[1]^.Pos - EdgeVel[1];

    Point^.Pos := Point^.Pos + n * PointMassBias;
    Edge^.Pos[0]^.Pos := Edge^.Pos[0]^.Pos - n * (ev0 * md * EdgeMassBias);
    Edge^.Pos[1]^.Pos := Edge^.Pos[1]^.Pos - n * (ev1 * md * EdgeMassBias);
  end;
end;

procedure TG2Scene2D.Render;
  var i: TG2IntS32;
begin
  for i := 0 to _FramesActive.Count - 1 do
  TG2S2DFrame(_FramesActive[i]).Render;
  if _Debug then
  begin
    for i := 0 to _CollidersActive.Count - 1 do
    TG2S2DCollider(_CollidersActive[i]).Render;
    for i := 0 to _CollisionGroups.Count - 1 do
    g2.PrimQuadHollowCol(
      PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Left, PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Top,
      PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Right, PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Top,
      PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Left, PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Bottom,
      PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Right, PG2S2DCollisionGroup(_CollisionGroups[i])^.Bounds.Bottom,
      $ff0000ff, $ff0000ff, $ff0000ff, $ff0000ff
    );
  end;
end;

procedure TG2Scene2D.Update;
  var t, i, j, k, n: TG2IntS32;
  var g: PG2S2DCollisionGroup;
begin
  i := 0;
  while i < _CollisionGroups.Count do
  begin
    if not PG2S2DCollisionGroup(_CollisionGroups[i])^.Freed then
    CollisionGroupUpdate(PG2S2DCollisionGroup(_CollisionGroups[i]));
    Inc(i);
  end;
  for i := 0 to _CollisionGroupsFree.Count - 1 do
  CollisionGroupFree(PG2S2DCollisionGroup(_CollisionGroupsFree[i]));
  _CollisionGroupsFree.Clear;
  for i := 0 to _CollidersActive.Count - 1 do
  TG2S2DCollider(_CollidersActive[i]).Update;
  for t := 0 to 1 do
  for i := 0 to _CollisionGroups.Count - 1 do
  begin
    g := PG2S2DCollisionGroup(_CollisionGroups[i]);
    for j := 0 to g^.Collisions.Count - 1 do
    begin
      for k := j + 1 to g^.Collisions.Count - 1 do
      Collide(TG2S2DCollider(g^.Collisions[j]), TG2S2DCollider(g^.Collisions[k]));
      for k := i + 1 to _CollisionGroups.Count - 1 do
      if G2RectInRect(g^.Bounds, PG2S2DCollisionGroup(_CollisionGroups[k])^.Bounds) then
      for n := 0 to PG2S2DCollisionGroup(_CollisionGroups[k])^.Collisions.Count - 1 do
      Collide(TG2S2DCollider(g^.Collisions[j]), TG2S2DCollider(PG2S2DCollisionGroup(_CollisionGroups[k])^.Collisions[n]));
    end;
  end;
  for i := 0 to _FramesActive.Count - 1 do
  TG2S2DFrame(_FramesActive[i]).Update;
end;
//TG2Scene2D END

//TG2S3DNode BEGIN
procedure TG2S3DNode.SetTransform(const Value: TG2Mat);
begin
  _Transform := Value;
end;

constructor TG2S3DNode.Create(const Scene: TG2Scene3D);
begin
  inherited Create;
  _Scene := Scene;
  _Scene.Nodes.Add(Self);
  _Transform := G2MatIdentity;
end;

destructor TG2S3DNode.Destroy;
begin
  _Scene.Nodes.Remove(Self);
  inherited Destroy;
end;
//TG2S3DNode END

//TG2S3DFrame BEGIN
constructor TG2S3DFrame.Create(const Scene: TG2Scene3D);
begin
  inherited Create(Scene);
  _Scene.Frames.Add(Self);
end;

destructor TG2S3DFrame.Destroy;
begin
  _Scene.Frames.Remove(Self);
  inherited Destroy;
end;
//TG2S3DFrame END

//TG2S3DMeshBuilder BEGIN
procedure TG2S3DMeshBuilder.Init;
begin
  Vertices.Clear;
  Faces.Clear;
  Materials.Clear;
  LastMaterial := -1;
end;

procedure TG2S3DMeshBuilder.Clear;
  var i: TG2IntS32;
begin
  for i := 0 to Vertices.Count - 1 do
  Dispose(PG2S3DMeshVertex(Vertices[i]));
  Vertices.Clear;
  for i := 0 to Faces.Count - 1 do
  Dispose(PG2S3DMeshFace(Faces[i]));
  Faces.Clear;
  for i := 0 to Materials.Count - 1 do
  Dispose(PG2S3DMeshMaterial(Materials[i]));
  Materials.Clear;
  LastMaterial := -1;
end;
//TG2S3DMeshBuilder END

//TG2S3DMesh BEGIN
function TG2S3DMesh.GetNode(const Index: TG2IntS32): PG2S3DMeshNode;
begin
  Result := @_Nodes[Index];
end;

function TG2S3DMesh.GetGeom(const Index: TG2IntS32): PG2S3DMeshGeom;
begin
  Result := @_Geoms[Index];
end;

function TG2S3DMesh.GetAnim(const Index: TG2IntS32): PG2S3DMeshAnim;
begin
  Result := @_Anims[Index];
end;

function TG2S3DMesh.GetMaterial(const Index: TG2IntS32): PG2S3DMeshMaterial;
begin
  Result := @_Materials[Index];
end;

constructor TG2S3DMesh.Create(const Scene: TG2Scene3D);
begin
  inherited Create;
  _Loaded := False;
  _NodeCount := 0;
  _GeomCount := 0;
  _AnimCount := 0;
  _MaterialCount := 0;
  _Instances.Clear;
  _Scene := Scene;
  _Scene.Meshes.Add(Self);
end;

destructor TG2S3DMesh.Destroy;
  var i: TG2IntS32;
begin
  _Scene.Meshes.Remove(Self);
  if _Loaded then
  begin
    while _Instances.Count > 0 do
    TG2S3DMeshInst(_Instances[0]).Free;
    for i := 0 to _GeomCount - 1 do
    begin
      _Geoms[i].IB.Free;
      if _Geoms[i].Skinned then
      Dispose(PG2S3DGeomDataSkinned(_Geoms[i].Data))
      else
      begin
        PG2S3DGeomDataStatic(_Geoms[i].Data)^.VB.Free;
        Dispose(PG2S3DGeomDataStatic(_Geoms[i].Data));
      end;
    end;
    _Loaded := False;
  end;
  inherited Destroy;
end;

procedure TG2S3DMesh.Load(const MeshData: TG2MeshData);
  {$if defined(G2RM_FF)}
  type TVertex = packed record
    Position: TG2Vec3;
    Normal: TG2Vec3;
  end;
  {$elseif defined(G2RM_SM2)}
  type TVertex = packed record
    Position: TG2Vec3;
    Normal: TG2Vec3;
    Tangent: TG2Vec3;
    Binormal: TG2Vec3;
  end;
  {$endif}
  type PVertex = ^TVertex;
  var i, j, n: TG2IntS32;
  var MinV, MaxV, v: TG2Vec3;
  var Vertex: PVertex;
  var TexCoords: PG2Vec2;
  {$if defined(G2RM_SM2)}
  var BlendWeights: PG2Float;
  var BlendIndices: PG2Float;
  {$endif}
  var DataStatic: PG2S3DGeomDataStatic;
  var DataSkinned: PG2S3DGeomDataSkinned;
begin
  _NodeCount := MeshData.NodeCount;
  SetLength(_Nodes, _NodeCount);
  for i := 0 to _NodeCount - 1 do
  begin
    _Nodes[i].Name := MeshData.Nodes[i].Name;
    _Nodes[i].OwnerID := MeshData.Nodes[i].OwnerID;
    _Nodes[i].Transform := MeshData.Nodes[i].Transform;
    _Nodes[i].SubNodesID := nil;
  end;
  for i := 0 to _NodeCount - 1 do
  if _Nodes[i].OwnerID > -1 then
  begin
    SetLength(_Nodes[_Nodes[i].OwnerID].SubNodesID, Length(_Nodes[_Nodes[i].OwnerID].SubNodesID) + 1);
    _Nodes[_Nodes[i].OwnerID].SubNodesID[High(_Nodes[_Nodes[i].OwnerID].SubNodesID)] := i;
  end;
  _GeomCount := MeshData.GeomCount;
  SetLength(_Geoms, _GeomCount);
  for i := 0 to _GeomCount - 1 do
  begin
    _Geoms[i].NodeID := MeshData.Geoms[i].NodeID;
    _Geoms[i].VCount := MeshData.Geoms[i].VCount;
    _Geoms[i].FCount := MeshData.Geoms[i].FCount;
    _Geoms[i].GCount := MeshData.Geoms[i].MCount;
    _Geoms[i].TCount := MeshData.Geoms[i].TCount;
    _Geoms[i].Visible := True;
    _Geoms[i].Skinned := MeshData.Geoms[i].SkinID > -1;
    {$if defined(G2RM_FF)}
    SetLength(_Geoms[i].Decl, 2 + _Geoms[i].TCount);
    _Geoms[i].Decl[0].Element := vbPosition; _Geoms[i].Decl[0].Count := 3;
    _Geoms[i].Decl[1].Element := vbNormal; _Geoms[i].Decl[1].Count := 3;
    for j := 2 to 2 + _Geoms[i].TCount - 1 do
    begin
      _Geoms[i].Decl[j].Element := vbTexCoord;
      _Geoms[i].Decl[j].Count := 2;
    end;
    {$elseif defined(G2RM_SM2)}
    SetLength(_Geoms[i].Decl, 4 + _Geoms[i].TCount);
    _Geoms[i].Decl[0].Element := vbPosition; _Geoms[i].Decl[0].Count := 3;
    _Geoms[i].Decl[1].Element := vbNormal; _Geoms[i].Decl[1].Count := 3;
    _Geoms[i].Decl[2].Element := vbTangent; _Geoms[i].Decl[2].Count := 3;
    _Geoms[i].Decl[3].Element := vbBinormal; _Geoms[i].Decl[3].Count := 3;
    for j := 4 to 4 + _Geoms[i].TCount - 1 do
    begin
      _Geoms[i].Decl[j].Element := vbTexCoord;
      _Geoms[i].Decl[j].Count := 2;
    end;
    {$endif}
    if _Geoms[i].Skinned then
    begin
      New(DataSkinned);
      _Geoms[i].Data := DataSkinned;
      DataSkinned^.MaxWeights := MeshData.Skins[MeshData.Geoms[i].SkinID].MaxWeights;
      DataSkinned^.BoneCount := MeshData.Skins[MeshData.Geoms[i].SkinID].BoneCount;
      SetLength(DataSkinned^.Bones, DataSkinned^.BoneCount);
      for j := 0 to DataSkinned^.BoneCount - 1 do
      begin
        DataSkinned^.Bones[j].NodeID := MeshData.Skins[MeshData.Geoms[i].SkinID].Bones[j].NodeID;
        DataSkinned^.Bones[j].Bind := MeshData.Skins[MeshData.Geoms[i].SkinID].Bones[j].Bind;
        DataSkinned^.Bones[j].BBox := MeshData.Skins[MeshData.Geoms[i].SkinID].Bones[j].BBox;
        DataSkinned^.Bones[j].VCount := MeshData.Skins[MeshData.Geoms[i].SkinID].Bones[j].VCount;
      end;
      {$if defined(G2RM_FF)}
      SetLength(DataSkinned^.Vertices, _Geoms[i].VCount);
      for j := 0 to _Geoms[i].VCount - 1 do
      begin
        SetLength(DataSkinned^.Vertices[j].TexCoord, _Geoms[i].TCount);
        SetLength(DataSkinned^.Vertices[j].Bones, PG2S3DGeomDataSkinned(_Geoms[i].Data)^.MaxWeights);
        SetLength(DataSkinned^.Vertices[j].Weights, PG2S3DGeomDataSkinned(_Geoms[i].Data)^.MaxWeights);
        DataSkinned^.Vertices[j].Position := MeshData.Geoms[i].Vertices[j].Position;
        DataSkinned^.Vertices[j].Normal := MeshData.Geoms[i].Vertices[j].Position;
        for n := 0 to _Geoms[i].TCount - 1 do
        DataSkinned^.Vertices[j].TexCoord[n] := MeshData.Geoms[i].Vertices[j].TexCoords[n];
        DataSkinned^.Vertices[j].BoneWeightCount := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].WeightCount;
        for n := 0 to MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].WeightCount - 1 do
        begin
          DataSkinned^.Vertices[j].Bones[n] := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].Weights[n].BoneID;
          DataSkinned^.Vertices[j].Weights[n] := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].Weights[n].Weight;
        end;
        for n := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].WeightCount to PG2S3DGeomDataSkinned(_Geoms[i].Data)^.MaxWeights - 1 do
        begin
          DataSkinned^.Vertices[j].Bones[n] := 0;
          DataSkinned^.Vertices[j].Weights[n] := 0;
        end;
      end;
      {$elseif defined(G2RM_SM2)}
      n := Length(_Geoms[i].Decl);
      if DataSkinned^.MaxWeights = 1 then
      begin
        SetLength(_Geoms[i].Decl, Length(_Geoms[i].Decl) + 1);
        _Geoms[i].Decl[n].Element := vbVertexIndex; _Geoms[i].Decl[n].Count := 1;
      end
      else
      begin
        SetLength(_Geoms[i].Decl, Length(_Geoms[i].Decl) + 2 * DataSkinned^.MaxWeights);
        _Geoms[i].Decl[n].Element := vbVertexIndex; _Geoms[i].Decl[n].Count := DataSkinned^.MaxWeights;
        Inc(n);
        _Geoms[i].Decl[n].Element := vbVertexWeight; _Geoms[i].Decl[n].Count := DataSkinned^.MaxWeights;
      end;
      DataSkinned^.VB := TG2VertexBuffer.Create(_Geoms[i].Decl, _Geoms[i].VCount);
      DataSkinned^.VB.Lock;
      for j := 0 to _Geoms[i].VCount - 1 do
      begin
        Vertex := PVertex(DataSkinned^.VB.Data + TG2IntS32(DataSkinned^.VB.VertexSize) * j);
        TexCoords := PG2Vec2(Pointer(Vertex) + TG2IntS32(SizeOf(TVertex)));
        BlendIndices := PG2Float(Pointer(TexCoords) + _Geoms[i].TCount * 8);
        BlendWeights := PG2Float(Pointer(BlendIndices) + DataSkinned^.MaxWeights * 4);
        Vertex^.Position := MeshData.Geoms[i].Vertices[j].Position;
        Vertex^.Normal := MeshData.Geoms[i].Vertices[j].Normal;
        Vertex^.Tangent := MeshData.Geoms[i].Vertices[j].Tangent;
        Vertex^.Binormal := MeshData.Geoms[i].Vertices[j].Binormal;
        for n := 0 to _Geoms[i].TCount - 1 do
        begin
          TexCoords^ := MeshData.Geoms[i].Vertices[j].TexCoords[n];
          Inc(TexCoords);
        end;
        if DataSkinned^.MaxWeights = 1 then
        BlendIndices^ := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].Weights[0].BoneID
        else
        for n := 0 to DataSkinned^.MaxWeights - 1 do
        begin
          BlendIndices^ := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].Weights[n].BoneID;
          Inc(BlendIndices);
          BlendWeights^ := MeshData.Skins[MeshData.Geoms[i].SkinID].Vertices[j].Weights[n].Weight;
          Inc(BlendWeights);
        end;
      end;
      DataSkinned^.VB.UnLock;
      {$endif}
    end
    else
    begin
      New(DataStatic);
      _Geoms[i].Data := DataStatic;
      DataStatic^.VB := TG2VertexBuffer.Create(_Geoms[i].Decl, _Geoms[i].VCount);
      DataStatic^.VB.Lock;
      MinV := MeshData.Geoms[i].Vertices[0].Position;
      MaxV := MinV;
      for j := 0 to _Geoms[i].VCount - 1 do
      begin
        Vertex := PVertex(DataStatic^.VB.Data + TG2IntS32(DataStatic^.VB.VertexSize) * j);
        TexCoords := PG2Vec2(DataStatic^.VB.Data + TG2IntS32(DataStatic^.VB.VertexSize) * j + TG2IntS32(SizeOf(TVertex)));
        Vertex^.Position := MeshData.Geoms[i].Vertices[j].Position;
        Vertex^.Normal := MeshData.Geoms[i].Vertices[j].Normal;
        {$if defined(G2RM_SM2)}
        Vertex^.Tangent := MeshData.Geoms[i].Vertices[j].Tangent;
        Vertex^.Binormal := MeshData.Geoms[i].Vertices[j].Binormal;
        {$endif}
        for n := 0 to _Geoms[i].TCount - 1 do
        begin
          TexCoords^ := MeshData.Geoms[i].Vertices[j].TexCoords[n];
          Inc(TexCoords);
        end;
        if MeshData.Geoms[i].Vertices[j].Position.x > MaxV.x then MaxV.x := MeshData.Geoms[i].Vertices[j].Position.x
        else if MeshData.Geoms[i].Vertices[j].Position.x < MinV.x then MinV.x := MeshData.Geoms[i].Vertices[j].Position.x;
        if MeshData.Geoms[i].Vertices[j].Position.y > MaxV.y then MaxV.y := MeshData.Geoms[i].Vertices[j].Position.y
        else if MeshData.Geoms[i].Vertices[j].Position.y < MinV.y then MinV.y := MeshData.Geoms[i].Vertices[j].Position.y;
        if MeshData.Geoms[i].Vertices[j].Position.z > MaxV.z then MaxV.z := MeshData.Geoms[i].Vertices[j].Position.z
        else if MeshData.Geoms[i].Vertices[j].Position.z < MinV.z then MinV.z := MeshData.Geoms[i].Vertices[j].Position.z;
      end;
      DataStatic^.VB.UnLock;
      DataStatic^.BBox.c := (MinV + MaxV) * 0.5;
      v := (MaxV - MinV) * 0.5;
      DataStatic^.BBox.vx.SetValue(v.x, 0, 0);
      DataStatic^.BBox.vy.SetValue(0, v.y, 0);
      DataStatic^.BBox.vz.SetValue(0, 0, v.z);
    end;
    _Geoms[i].IB := TG2IndexBuffer.Create(_Geoms[i].FCount * 3);
    _Geoms[i].IB.Lock;
    for j := 0 to _Geoms[i].FCount - 1 do
    begin
      PG2IntU16Arr(_Geoms[i].IB.Data)^[j * 3 + 0] := MeshData.Geoms[i].Faces[j][0];
      PG2IntU16Arr(_Geoms[i].IB.Data)^[j * 3 + 1] := MeshData.Geoms[i].Faces[j][1];
      PG2IntU16Arr(_Geoms[i].IB.Data)^[j * 3 + 2] := MeshData.Geoms[i].Faces[j][2];
    end;
    _Geoms[i].IB.UnLock;
    SetLength(_Geoms[i].Groups, _Geoms[i].GCount);
    for j := 0 to _Geoms[i].GCount - 1 do
    begin
      _Geoms[i].Groups[j].Material := MeshData.Geoms[i].Groups[j].MaterialID;
      _Geoms[i].Groups[j].VertexStart := MeshData.Geoms[i].Groups[j].VertexStart;
      _Geoms[i].Groups[j].VertexCount := MeshData.Geoms[i].Groups[j].VertexCount;
      _Geoms[i].Groups[j].FaceStart := MeshData.Geoms[i].Groups[j].FaceStart;
      _Geoms[i].Groups[j].FaceCount := MeshData.Geoms[i].Groups[j].FaceCount;
    end;
  end;
  _MaterialCount := MeshData.MaterialCount;
  SetLength(_Materials, _MaterialCount);
  for i := 0 to _MaterialCount - 1 do
  begin
    _Materials[i].ChannelCount := MeshData.Materials[i].ChannelCount;
    SetLength(_Materials[i].Channels, _Materials[i].ChannelCount);
    for j := 0 to _Materials[i].ChannelCount - 1 do
    begin
      _Materials[i].Channels[j].Name := MeshData.Materials[i].Channels[j].Name;
      _Materials[i].Channels[j].TwoSided := MeshData.Materials[i].Channels[j].TwoSided;
      {$if defined(G2Target_Android)}
      if Length(MeshData.Materials[i].Channels[j].DiffuseMap) > 0 then
      {$else}
      if G2FileExists(MeshData.Materials[i].Channels[j].DiffuseMap) then
      {$endif}
      begin
        _Materials[i].Channels[j].MapDiffuse := _Scene.FindTexture(MeshData.Materials[i].Channels[j].DiffuseMap, {$if defined(G2Target_Android)}tuDefault{$else}tuUsage3D{$endif});
      end
      else
      _Materials[i].Channels[j].MapDiffuse := nil;
      {$if defined(G2Target_Android)}
      if Length(MeshData.Materials[i].Channels[j].LightMap) > 0 then
      {$else}
      if G2FileExists(MeshData.Materials[i].Channels[j].LightMap) then
      {$endif}
      begin
        _Materials[i].Channels[j].MapLight := _Scene.FindTexture(MeshData.Materials[i].Channels[j].LightMap, tuDefault);
      end
      else
      _Materials[i].Channels[j].MapLight := nil;
    end;
  end;
  _AnimCount := MeshData.AnimCount;
  SetLength(_Anims, _AnimCount);
  for i := 0 to _AnimCount - 1 do
  begin
    _Anims[i].Name := MeshData.Anims[i].Name;
    _Anims[i].FrameCount := MeshData.Anims[i].FrameCount;
    _Anims[i].FrameRate := MeshData.Anims[i].FrameRate;
    _Anims[i].NodeCount := MeshData.Anims[i].NodeCount;
    SetLength(_Anims[i].Nodes, _Anims[i].NodeCount);
    for j := 0 to _Anims[i].NodeCount - 1 do
    begin
      _Anims[i].Nodes[j].NodeID := MeshData.Anims[i].Nodes[j].NodeID;
      SetLength(_Anims[i].Nodes[j].Frames, _Anims[i].FrameCount);
      for n := 0 to _Anims[i].FrameCount - 1 do
      begin
        _Anims[i].Nodes[j].Frames[n].Scaling := MeshData.Anims[i].Nodes[j].Frames[n].Scaling;
        _Anims[i].Nodes[j].Frames[n].Rotation := MeshData.Anims[i].Nodes[j].Frames[n].Rotation;
        _Anims[i].Nodes[j].Frames[n].Translation := MeshData.Anims[i].Nodes[j].Frames[n].Translation;
      end;
    end;
  end;
  _Loaded := True;
end;

function TG2S3DMesh.AnimIndex(const Name: AnsiString): TG2IntS32;
  var i: TG2IntS32;
begin
  for i := 0 to _AnimCount - 1 do
  if _Anims[i].Name = Name then
  begin
    Result := i;
    Exit;
  end;
  Result := -1;
end;

function TG2S3DMesh.NewInst: TG2S3DMeshInst;
begin
  Result := TG2S3DMeshInst.Create(_Scene);
  Result.Mesh := Self;
end;
//TG2S3DMesh END

//TG2S3DMeshInst BEGIN
procedure TG2S3DMeshInst.SetMesh(const Value: TG2S3DMesh);
  var i, r: TG2IntS32;
begin
  if Value = _Mesh then Exit;
  _Mesh := Value;
  for i := 0 to High(_Skins) do
  if _Skins[i] <> nil then
  begin
    {$if defined(G2RM_FF)}
    _Skins[i]^.VB.Free;
    {$endif}
    Dispose(_Skins[i]);
    _Skins[i] := nil;
  end;
  if _Mesh <> nil then
  begin
    SetLength(Materials, _Mesh.MaterialCount);
    for i := 0 to _Mesh.MaterialCount - 1 do
    Materials[i] := _Mesh.Materials[i];
    SetLength(Transforms, _Mesh.NodeCount);
    r := 0;
    SetLength(_RootNodes, _Mesh.NodeCount);
    for i := 0 to _Mesh.NodeCount - 1 do
    begin
      if _Mesh.Nodes[i]^.OwnerID = -1 then
      begin
        _RootNodes[i] := i;
        Inc(r);
      end;
      Transforms[i].TransformDef := _Mesh.Nodes[i]^.Transform;
      Transforms[i].TransformCur := Transforms[i].TransformDef;
      Transforms[i].TransformCom := G2MatIdentity;
    end;
    SetLength(_Skins, _Mesh.GeomCount);
    for i := 0 to _Mesh.GeomCount - 1 do
    if _Mesh.Geoms[i]^.Skinned then
    begin
      New(_Skins[i]);
      SetLength(_Skins[i]^.Transforms, PG2S3DGeomDataSkinned(_Mesh.Geoms[i]^.Data)^.BoneCount);
      {$if defined(G2RM_FF)}
      _Skins[i]^.VB := TG2VertexBuffer.Create(_Mesh.Geoms[i]^.Decl, _Mesh.Geoms[i]^.VCount);
      {$endif}
    end;
    if r < Length(_RootNodes) then
    SetLength(_RootNodes, r);
    ComputeTransforms;
  end;
end;

function TG2S3DMeshInst.GetBBox: TG2Box;
  var i: TG2IntS32;
  var b: TG2AABox;
begin
  if _Mesh.GeomCount < 1 then
  begin
    {$Warnings off}
    Result.SetValue(G2Vec3(0, 0, 0), G2Vec3(0, 0, 0), G2Vec3(0, 0, 0), G2Vec3(0, 0, 0));
    {$Warnings on}
    Exit;
  end;
  b := GetGeomBBox(0);
  for i := 1 to _Mesh.GeomCount - 1 do
  b.Merge(GetGeomBBox(i));
  Result := b;
end;

function TG2S3DMeshInst.GetGeomBBox(const Index: TG2IntS32): TG2Box;
  var DataSkinned: PG2S3DGeomDataSkinned;
  var i, j: TG2IntS32;
  var b: TG2AABox;
begin
  if _Mesh.Geoms[Index]^.Skinned then
  begin
    DataSkinned := PG2S3DGeomDataSkinned(_Mesh.Geoms[Index]^.Data);
    for i := 0 to DataSkinned^.BoneCount - 1 do
    if DataSkinned^.Bones[i].VCount > 0 then
    begin
      b := DataSkinned^.Bones[i].BBox.Transform(_Skins[Index]^.Transforms[i]);
      Break;
    end;
    for j := i + 1 to DataSkinned^.BoneCount - 1 do
    if DataSkinned^.Bones[j].VCount > 0 then
    b.Merge(DataSkinned^.Bones[j].BBox.Transform(_Skins[Index]^.Transforms[j]));
    Result := b;
  end
  else
  Result := PG2S3DGeomDataStatic(_Mesh.Geoms[Index]^.Data)^.BBox.Transform(Transforms[_Mesh.Geoms[Index]^.NodeID].TransformCom);
end;

function TG2S3DMeshInst.GetSkin(const Index: TG2IntS32): PG2S3DMeshInstSkin;
begin
  Result := _Skins[Index];
end;

{$Notes off}
procedure TG2S3DMeshInst.ComputeSkinTransforms;
  type TVertex = packed record
    Position: TG2Vec3;
    Normal: TG2Vec3;
  end;
  type PVertex = ^TVertex;
  var i, j, n: TG2IntS32;
  var DataSkinned: PG2S3DGeomDataSkinned;
  var vp, vn: TG2Vec3;
  var Vertex: PVertex;
  var TexCoords: PG2Vec2;
begin
  for i := 0 to _Mesh.GeomCount - 1 do
  if _Mesh.Geoms[i]^.Skinned then
  begin
    DataSkinned := PG2S3DGeomDataSkinned(_Mesh.Geoms[i]^.Data);
    for j := 0 to DataSkinned^.BoneCount - 1 do
    _Skins[i]^.Transforms[j] := DataSkinned^.Bones[j].Bind * Transforms[DataSkinned^.Bones[j].NodeID].TransformCom;
    {$if defined(G2RM_FF)}
    _Skins[i]^.VB.Lock;
    for j := 0 to _Mesh.Geoms[i]^.VCount - 1 do
    begin
      Vertex := PVertex(_Skins[i]^.VB.Data + TG2IntS32(_Skins[i]^.VB.VertexSize) * j);
      TexCoords := PG2Vec2(Pointer(Vertex) + SizeOf(TVertex));
      vp.SetValue(0, 0, 0);
      vn.SetValue(0, 0, 0);
      for n := 0 to DataSkinned^.Vertices[j].BoneWeightCount - 1 do
      begin
        vp := vp + DataSkinned^.Vertices[j].Position.Transform4x3(
          _Skins[i]^.Transforms[DataSkinned^.Vertices[j].Bones[n]]
        ) * DataSkinned^.Vertices[j].Weights[n];
        vn := vn + DataSkinned^.Vertices[j].Normal.Transform3x3(
          _Skins[i]^.Transforms[DataSkinned^.Vertices[j].Bones[n]]
        ) * DataSkinned^.Vertices[j].Weights[n];
      end;
      Vertex^.Position := vp;
      Vertex^.Normal := vn;
      for n := 0 to _Mesh.Geoms[i]^.TCount - 1 do
      begin
        TexCoords^ := DataSkinned^.Vertices[j].TexCoord[n];
        Inc(TexCoords);
      end;
    end;
    _Skins[i]^.VB.UnLock;
    {$endif}
  end;
end;
{$Notes on}

function TG2S3DMeshInst.GetAABox: TG2AABox;
begin
  Result := GetBBox;
end;

constructor TG2S3DMeshInst.Create(const Scene: TG2Scene3D);
begin
  inherited Create(Scene);
  _Mesh := nil;
  _AutoComputeTransforms := True;
  _Scene.MeshInst.Add(Self);
end;

destructor TG2S3DMeshInst.Destroy;
begin
  if _Mesh <> nil then
  _Mesh._Instances.Remove(Self);
  Mesh := nil;
  _Scene.MeshInst.Remove(Self);
  inherited Destroy;
end;

procedure TG2S3DMeshInst.FrameSetFast(const AnimName: AnsiString; const Frame: TG2IntS32);
  var AnimIndex, i, f0: TG2IntS32;
  var ms, mr, mt: TG2Mat;
begin
  AnimIndex := _Mesh.AnimIndex(AnimName);
  if AnimIndex > -1 then
  begin
    if Frame < 0 then
    f0 := _Mesh.Anims[AnimIndex]^.FrameCount - (Abs(Frame) mod _Mesh.Anims[AnimIndex]^.FrameCount)
    else
    f0 := Frame mod _Mesh.Anims[AnimIndex]^.FrameCount;
    for i := 0 to _Mesh.Anims[AnimIndex]^.NodeCount - 1 do
    begin
      ms := G2MatScaling(_Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Scaling);
      mr := G2MatRotation(_Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Rotation);
      mt := G2MatTranslation(_Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Translation);
      Transforms[_Mesh.Anims[AnimIndex]^.Nodes[i].NodeID].TransformCur := ms * mr * mt;
    end;
    if _AutoComputeTransforms then ComputeTransforms;
  end;
end;

procedure TG2S3DMeshInst.FrameSet(const AnimName: AnsiString; const Frame: TG2Float);
  var AnimIndex, i, f0, f1: TG2IntS32;
  var f: TG2Float;
  var s0: TG2Vec3;
  var r0: TG2Quat;
  var t0: TG2Vec3;
  var ms, mr, mt: TG2Mat;
begin
  AnimIndex := _Mesh.AnimIndex(AnimName);
  if AnimIndex > -1 then
  begin
    if Frame < 0 then
    f := _Mesh.Anims[AnimIndex]^.FrameCount - (Trunc(Abs(Frame)) mod _Mesh.Anims[AnimIndex]^.FrameCount) + Frac(Frame)
    else
    f := Frame;
    f0 := Trunc(f) mod _Mesh.Anims[AnimIndex]^.FrameCount;
    f1 := (f0 + 1) mod _Mesh.Anims[AnimIndex]^.FrameCount;
    f := Frac(f);
    for i := 0 to _Mesh.Anims[AnimIndex]^.NodeCount - 1 do
    begin
      s0 := G2LerpVec3(
        _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Scaling,
        _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f1].Scaling,
        f
      );
      r0 := G2QuatSlerp(
        _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Rotation,
        _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f1].Rotation,
        f
      );
      //r0 := G2QuatSlerp(
      //  _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Rotation,
      //  _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f1].Rotation,
      //  f
      //);
      t0 := G2LerpVec3(
        _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f0].Translation,
        _Mesh.Anims[AnimIndex]^.Nodes[i].Frames[f1].Translation,
        f
      );
      ms := G2MatScaling(s0);
      mr := G2MatRotation(r0);
      mt := G2MatTranslation(t0);
      Transforms[_Mesh.Anims[AnimIndex]^.Nodes[i].NodeID].TransformCur := ms * mr * mt;
    end;
    if _AutoComputeTransforms then ComputeTransforms;
  end;
end;

procedure TG2S3DMeshInst.ComputeTransforms;
  procedure ComputeNode(const NodeID: TG2IntS32);
    var i: TG2IntS32;
  begin
    if _Mesh.Nodes[NodeID]^.OwnerID > -1 then
    Transforms[NodeID].TransformCom := Transforms[NodeID].TransformCur * Transforms[_Mesh.Nodes[NodeID]^.OwnerID].TransformCom
    else
    Transforms[NodeID].TransformCom := Transforms[NodeID].TransformCur;
    for i := 0 to High(_Mesh.Nodes[NodeID]^.SubNodesID) do
    ComputeNode(_Mesh.Nodes[NodeID]^.SubNodesID[i]);
  end;
  var i: TG2IntS32;
begin
  for i := 0 to High(_RootNodes) do
  ComputeNode(_RootNodes[i]);
  ComputeSkinTransforms;
end;
//TG2S3DMeshInst END

//TG2S3DParticleRender BEGIN
constructor TG2S3DParticleRender.Create(const Scene: TG2Scene3D);
begin
  inherited Create;
  _Scene := Scene;
end;

destructor TG2S3DParticleRender.Destroy;
begin
  inherited Destroy;
end;
//TG2S3DParticleRender END

//TG2S3DParticleRenderFlat BEGIN
{$if defined(G2RM_FF)}
procedure TG2S3DParticleRenderFlat.RenderFlush;
begin
  {$if defined(G2Gfx_D3D9)}
  g2.Gfx.Filter := _CurFilter;
  g2.Gfx.BlendMode := _CurBlendMode;
  TG2GfxD3D9(g2.Gfx).Device.SetTexture(0, _CurTexture.GetTexture);
  TG2GfxD3D9(g2.Gfx).Device.DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, _CurQuad * 4, 0, _CurQuad * 2);
  {$elseif defined(G2Gfx_OGL)}
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, _CurTexture.GetTexture);
  if _CurTexture.Usage = tuUsage3D then
  begin
    case _CurFilter of
      tfPoint:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      end;
      tfLinear:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      end;
    end;
  end
  else
  begin
    case _CurFilter of
      tfPoint:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
      end;
      tfLinear:
      begin
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
      end;
    end;
  end;
  g2.Gfx.BlendMode := _CurBlendMode;
  glDrawElements(
    GL_TRIANGLES,
    _CurQuad * 6,
    GL_UNSIGNED_SHORT,
    GLvoid(0)
  );
  {$elseif defined(G2Gfx_GLES)}
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, _CurTexture.GetTexture);
  g2.Gfx.Filter := _CurFilter;
  g2.Gfx.BlendMode := _CurBlendMode;
  glDrawElements(
    GL_TRIANGLES,
    _CurQuad * 6,
    GL_UNSIGNED_SHORT,
    GLvoid(0)
  );
  {$endif}
  _CurQuad := 0;
  _VB[_CurVB].Unbind;
  _CurVB := (_CurVB + 1) mod _VBCount;
  _VB[_CurVB].Bind;
end;

constructor TG2S3DParticleRenderFlat.Create(const Scene: TG2Scene3D);
  var Decl: TG2VBDecl;
  var i, n0, n1: TG2IntS32;
begin
  inherited Create(Scene);
  _MaxQuads := 64;
  _VBCount := 16;
  SetLength(_VB, _VBCount);
  _CurVB := 0;
  SetLength(Decl, 3);
  Decl[0].Element := vbPosition; Decl[0].Count := 3;
  Decl[1].Element := vbDiffuse; Decl[1].Count := 4;
  Decl[2].Element := vbTexCoord; Decl[2].Count := 2;
  for i := 0 to _VBCount - 1 do
  _VB[i] := TG2VertexBuffer.Create(Decl, 4 * _MaxQuads);
  _IB := TG2IndexBuffer.Create(6 * _MaxQuads);
  _IB.Lock;
  for i := 0 to _MaxQuads - 1 do
  begin
    n0 := i * 6;
    n1 := i * 4;
    PG2IntU16Arr(_IB.Data)^[n0 + 0] := n1 + 0;
    PG2IntU16Arr(_IB.Data)^[n0 + 1] := n1 + 1;
    PG2IntU16Arr(_IB.Data)^[n0 + 2] := n1 + 2;
    PG2IntU16Arr(_IB.Data)^[n0 + 3] := n1 + 2;
    PG2IntU16Arr(_IB.Data)^[n0 + 4] := n1 + 1;
    PG2IntU16Arr(_IB.Data)^[n0 + 5] := n1 + 3;
  end;
  _IB.UnLock;
end;

destructor TG2S3DParticleRenderFlat.Destroy;
begin
  inherited Destroy;
end;

procedure TG2S3DParticleRenderFlat.RenderBegin;
  var m: TG2Mat;
begin
  m := G2MatIdentity;
  {$if defined(G2Gfx_D3D9)}
  TG2GfxD3D9(g2.Gfx).Device.SetTransform(D3DTS_WORLD, m);
  {$elseif defined(G2Gfx_OGL) or defined(G2Gfx_GLES)}
  glMatrixMode(GL_MODELVIEW);
  glLoadMatrixf(@m);
  {$endif}
  g2.Gfx.DepthEnable := True;
  g2.Gfx.DepthWriteEnable := False;
  _CurQuad := 0;
  _CurTexture := nil;
  _CurFilter := tfNone;
  _CurBlendMode := bmInvalid;
  _VB[_CurVB].Bind;
  _IB.Bind;
  _VB[_CurVB].Lock;
end;

procedure TG2S3DParticleRenderFlat.RenderEnd;
begin
  _VB[_CurVB].UnLock;
  if _CurQuad > 0 then
  RenderFlush;
  _IB.Unbind;
  _VB[_CurVB].Unbind;
  g2.Gfx.DepthEnable := False;
  g2.Gfx.DepthWriteEnable := True;
end;

procedure TG2S3DParticleRenderFlat.RenderParticle(const Particle: TG2S3DParticle);
  type TVertex = packed record
    Position: TG2Vec3;
    Color: TG2Vec4;
    TexCoords: TG2Vec2;
  end;
  type TVertexArr = array[Word] of TVertex;
  type PVertexArr = ^TVertexArr;
  var p: TG2S3DParticleFlat;
  var q: TG2IntS32;
  var vc: TG2Vec4;
  var vx, vy: TG2Vec3;
begin
  p := TG2S3DParticleFlat(Particle);
  if (p.Texture <> _CurTexture)
  or (p.Filter <> _CurFilter)
  or (p.BlendMode <> _CurBlendMode)
  or (_CurQuad >= _MaxQuads - 1)
  then
  begin
    if (_CurQuad > 0) then
    begin
      _VB[_CurVB].UnLock;
      RenderFlush;
      _VB[_CurVB].Lock;
    end;
    _CurTexture := p.Texture;
    _CurFilter := p.Filter;
    _CurBlendMode := p.BlendMode;
  end;
  q := _CurQuad * 4;
  {$if defined(G2Gfx_D3D9)}
  vc.SetValue(p.Color.b * Rcp255, p.Color.g * Rcp255, p.Color.r * Rcp255, p.Color.a * Rcp255);
  {$else}
  vc.SetValue(p.Color.r * Rcp255, p.Color.g * Rcp255, p.Color.b * Rcp255, p.Color.a * Rcp255);
  {$endif}
  vx := p.VecX * 0.5; vy := p.VecY * 0.5;
  PVertexArr(_VB[_CurVB].Data)^[q].Position := p.Pos - vx + vy;
  PVertexArr(_VB[_CurVB].Data)^[q].Color := vc;
  PVertexArr(_VB[_CurVB].Data)^[q].TexCoords.SetValue(0, 0);
  Inc(q);
  PVertexArr(_VB[_CurVB].Data)^[q].Position := p.Pos + vx + vy;
  PVertexArr(_VB[_CurVB].Data)^[q].Color := vc;
  PVertexArr(_VB[_CurVB].Data)^[q].TexCoords.SetValue(1, 0);
  Inc(q);
  PVertexArr(_VB[_CurVB].Data)^[q].Position := p.Pos - vx - vy;
  PVertexArr(_VB[_CurVB].Data)^[q].Color := vc;
  PVertexArr(_VB[_CurVB].Data)^[q].TexCoords.SetValue(0, 1);
  Inc(q);
  PVertexArr(_VB[_CurVB].Data)^[q].Position := p.Pos + vx - vy;
  PVertexArr(_VB[_CurVB].Data)^[q].Color := vc;
  PVertexArr(_VB[_CurVB].Data)^[q].TexCoords.SetValue(1, 1);
  Inc(_CurQuad);
end;
{$elseif defined(G2RM_SM2)}
procedure TG2S3DParticleRenderFlat.RenderFlush;
begin
  if _CurQuad = 0 then Exit;
  {$if defined(G2Gfx_D3D9)}
  TG2GfxD3D9(g2.Gfx).Device.DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, _CurQuad * 4, 0, _CurQuad * 2);
  {$elseif defined(G2Gfx_OGL)}
  glDrawElements(GL_TRIANGLES, _CurQuad * 6, GL_UNSIGNED_SHORT, GLvoid(0));
  {$endif}
  _CurQuad := 0;
end;

constructor TG2S3DParticleRenderFlat.Create(const Scene: TG2Scene3D);
  type TVertex = packed record
    Position: TG2Vec3;
    TexCoord: TG2Vec2;
    TransformIndex: TG2Float;
  end;
  type TVertexArr = array[Word] of TVertex;
  type PVertexArr = ^TVertexArr;
  var Decl: TG2VBDecl;
  var i: TG2IntS32;
begin
  inherited Create(Scene);
  {$if defined(G2Gfx_D3D9)}
  _MaxQuads := 60;
  {$elseif defined(G2Gfx_OGL)}
  _MaxQuads := 45;
  {$endif}
  _ShaderGroup := g2.Gfx.RequestShader('StandardShaders');
  SetLength(Decl, 3);
  Decl[0].Element := vbPosition; Decl[0].Count := 3;
  Decl[1].Element := vbTexCoord; Decl[1].Count := 2;
  Decl[2].Element := vbVertexIndex; Decl[2].Count := 1;
  _VB := TG2VertexBuffer.Create(Decl, _MaxQuads * 4);
  _VB.Lock;
  for i := 0 to _MaxQuads - 1 do
  begin
    PVertexArr(_VB.Data)^[i * 4 + 0].Position := G2Vec3(-0.5, 0.5, 0);
    PVertexArr(_VB.Data)^[i * 4 + 1].Position := G2Vec3(0.5, 0.5, 0);
    PVertexArr(_VB.Data)^[i * 4 + 2].Position := G2Vec3(-0.5, -0.5, 0);
    PVertexArr(_VB.Data)^[i * 4 + 3].Position := G2Vec3(0.5, -0.5, 0);
    PVertexArr(_VB.Data)^[i * 4 + 0].TexCoord := G2Vec2(0, 0);
    PVertexArr(_VB.Data)^[i * 4 + 1].TexCoord := G2Vec2(1, 0);
    PVertexArr(_VB.Data)^[i * 4 + 2].TexCoord := G2Vec2(0, 1);
    PVertexArr(_VB.Data)^[i * 4 + 3].TexCoord := G2Vec2(1, 1);
    PVertexArr(_VB.Data)^[i * 4 + 0].TransformIndex := i;
    PVertexArr(_VB.Data)^[i * 4 + 1].TransformIndex := i;
    PVertexArr(_VB.Data)^[i * 4 + 2].TransformIndex := i;
    PVertexArr(_VB.Data)^[i * 4 + 3].TransformIndex := i;
  end;
  _VB.UnLock;
  _IB := TG2IndexBuffer.Create(_MaxQuads * 6);
  _IB.Lock;
  for i := 0 to _MaxQuads - 1 do
  begin
    PG2IntU16Arr(_IB.Data)^[i * 6 + 0] := i * 4 + 0;
    PG2IntU16Arr(_IB.Data)^[i * 6 + 1] := i * 4 + 1;
    PG2IntU16Arr(_IB.Data)^[i * 6 + 2] := i * 4 + 2;
    PG2IntU16Arr(_IB.Data)^[i * 6 + 3] := i * 4 + 2;
    PG2IntU16Arr(_IB.Data)^[i * 6 + 4] := i * 4 + 1;
    PG2IntU16Arr(_IB.Data)^[i * 6 + 5] := i * 4 + 3;
  end;
  _IB.UnLock;
end;

destructor TG2S3DParticleRenderFlat.Destroy;
begin
  _VB.Free;
  _IB.Free;
  inherited Destroy;
end;

procedure TG2S3DParticleRenderFlat.RenderBegin;
  var WVP: TG2Mat;
begin
  g2.Gfx.DepthEnable := True;
  g2.Gfx.DepthWriteEnable := False;
  {$if defined(G2Gfx_D3D9)}

  {$elseif defined(G2Gfx_OGL)}

  {$endif}
  _ShaderGroup.Method := 'SceneParticles';
  WVP := _Scene.V * _Scene.P;
  _ShaderGroup.UniformMatrix4x4('WVP', WVP);
  _VB.Bind;
  _IB.Bind;
  _CurQuad := 0;
  _CurTexture := nil;
  _CurBlendMode := bmInvalid;
  _CurFilter := tfNone;
end;

procedure TG2S3DParticleRenderFlat.RenderEnd;
begin
  if _CurQuad > 0 then
  RenderFlush;
  _IB.Unbind;
  _VB.Unbind;
  g2.Gfx.DepthEnable := False;
  g2.Gfx.DepthWriteEnable := True;
end;

procedure TG2S3DParticleRenderFlat.RenderParticle(const Particle: TG2S3DParticle);
  var p: TG2S3DParticleFlat;
  var m: TG2Mat;
begin
  p := TG2S3DParticleFlat(Particle);
  if (p.Texture <> _CurTexture)
  or (p.Filter <> _CurFilter)
  or (p.BlendMode <> _CurBlendMode)
  or (_CurQuad >= _MaxQuads - 1)
  then
  begin
    if (_CurQuad > 0) then
    RenderFlush;
    if (p.Texture <> _CurTexture) then
    begin
      _CurTexture := p.Texture;
      _ShaderGroup.Sampler('Tex0', _CurTexture);
    end;
    {$if defined(G2Gfx_D3D9)}
    if (p.Filter <> _CurFilter) then
    {$endif}
    begin
      _CurFilter := p.Filter;
      {$if defined(G2Gfx_D3D9)}
      g2.Gfx.Filter := _CurFilter;
      {$elseif defined(G2Gfx_OGL)}
      if _CurTexture.Usage = tuUsage3D then
      begin
        case _CurFilter of
          tfPoint:
          begin
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
          end;
          tfLinear:
          begin
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
          end;
        end;
      end
      else
      begin
        case _CurFilter of
          tfPoint:
          begin
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
          end;
          tfLinear:
          begin
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
          end;
        end;
      end;
      {$endif}
    end;
    if (p.BlendMode <> _CurBlendMode) then
    begin
      _CurBlendMode := p.BlendMode;
      g2.Gfx.BlendMode := _CurBlendMode;
    end;
  end;
  m := G2Mat(p.VecX, p.VecY, G2Vec3(0, 0, 0), p.Pos);
  m.e03 := p.Color.r * Rcp255;
  m.e13 := p.Color.g * Rcp255;
  m.e23 := p.Color.b * Rcp255;
  m.e33 := p.Color.a * Rcp255;
  _ShaderGroup.UniformMatrix4x4Arr('TransformPallete', @m, _CurQuad, 1);
  //_ShaderGroup.UniformMatrix4x4Arr('TransformPallete', @m, _CurQuad, 1);
  Inc(_CurQuad);
end;
{$endif}
//TG2S3DParticleRenderFlat END

//TG2S3DParticle BEGIN
function TG2S3DParticle.GetAABox: TG2AABox;
begin
  Result.MinV.x := _Pos.x - _Size;
  Result.MinV.y := _Pos.y - _Size;
  Result.MinV.z := _Pos.z - _Size;
  Result.MaxV.x := _Pos.x + _Size;
  Result.MaxV.y := _Pos.y + _Size;
  Result.MaxV.z := _Pos.z + _Size;
end;

procedure TG2S3DParticle.Die;
begin
  _Dead := True;
end;

constructor TG2S3DParticle.Create;
begin
  inherited Create;
  _ParticleRender := nil;
  _RenderClass := nil;
  _Size := 0;
  _Pos.SetValue(0, 0, 0);
  _Dead := False;
end;

destructor TG2S3DParticle.Destroy;
begin
  inherited Destroy;
end;
//TG2S3DParticle END

//TG2S3DParticleFlat BEGIN
procedure TG2S3DParticleFlat.SetVecX(const Value: TG2Vec3);
begin
  _VecX := Value;
  UpdateSize;
end;

procedure TG2S3DParticleFlat.SetVecY(const Value: TG2Vec3);
begin
  _VecY := Value;
  UpdateSize;
end;

procedure TG2S3DParticleFlat.UpdateSize;
begin
  _Size := Sqrt(Sqr(_VecX.Len) + Sqr(_VecY.Len));
end;

procedure TG2S3DParticleFlat.MakeBillboard(const View: TG2Mat; const Width, Height, Rotation: TG2Float);
  var s, c: TG2Float;
  var vx, vy: TG2Vec3;
begin
  {$Hints off}
  G2SinCos(Rotation, s, c);
  {$Hints on}
  vx := G2Vec3(View.e00, View.e10, View.e20).Norm * (Width * 0.5);
  vy := G2Vec3(View.e01, View.e11, View.e21).Norm * (Height * 0.5);
  VecX := (vx * s) - (vy * c);
  VecY := (vy * s) + (vx * c);
end;

procedure TG2S3DParticleFlat.MakeAxis(const View: TG2Mat; const Pos0, Pos1: TG2Vec3; const Width: TG2Float);
begin
  Pos := (Pos0 + Pos1) * 0.5;
  VecY := (Pos1 - Pos0) * 0.5;
  VecX := VecY.Cross(G2Vec3(View.e02, View.e12, View.e22)).Norm * (Width * 0.5);
end;

procedure TG2S3DParticleFlat.Update;
begin

end;

constructor TG2S3DParticleFlat.Create;
begin
  inherited Create;
  _RenderClass := TG2S3DParticleRenderFlat;
  _VecX.SetValue(1, 0, 0);
  _VecY.SetValue(0, 1, 0);
  UpdateSize;
  _Texture := nil;
  _Color := $ffffffff;
  _Filter := tfLinear;
  _BlendMode := bmNormal;
  DepthSorted := True;
end;

destructor TG2S3DParticleFlat.Destroy;
begin
  inherited Destroy;
end;
//TG2S3DParticleFlat END

//TG2Scene3D BEGIN
{$Hints off}
procedure TG2Scene3D.OcTreeBuild(const MinV, MaxV: TG2Vec3; const Depth: TG2IntS32);
begin
  if _OcTreeRoot <> nil then OcTreeBreak;
end;
{$Hints on}

procedure TG2Scene3D.OcTreeBreak;
begin

end;

function TG2Scene3D.GetStatParticleGroupCount: TG2IntS32;
begin
  Result := _ParticleGroups.Count;
end;

function TG2Scene3D.GetStatParticleCount: TG2IntS32;
begin
  Result := _Particles.Count;
end;

{$if defined(G2Gfx_D3D9)}
{$if defined(G2RM_FF)}
procedure TG2Scene3D.RenderD3D9;
  var i, g, m, CurStage: TG2IntS32;
  var W: TG2Mat;
  var Mesh: TG2S3DMesh;
  var Inst: TG2S3DMeshInst;
  var Geom: PG2S3DMeshGeom;
  var Material: PG2S3DMeshMaterial;
  var PrevDepthEnable: Boolean;
  var VB: TG2VertexBuffer;
begin
  _Frustum.Update;
  PrevDepthEnable := _Gfx.DepthEnable;
  //_Gfx.DepthEnable := True;
  _Gfx.Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
  _Gfx.Device.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(2, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(2, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(2, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetTransform(D3DTS_VIEW, V);
  _Gfx.Device.SetTransform(D3DTS_PROJECTION, P);
  for i := 0 to _MeshInst.Count - 1 do
  begin
    Inst := TG2S3DMeshInst(_MeshInst[i]);
    Mesh := Inst.Mesh;
    if _Frustum.CheckBox(Inst.BBox) <> fcOutside then
    for g := 0 to Mesh.GeomCount - 1 do
    begin
      Geom := Mesh.Geoms[g];
      if Geom^.Skinned then
      begin
        VB := Inst.Skins[g]^.VB;
        W := Inst.Transform;
      end
      else
      begin
        VB := PG2S3DGeomDataStatic(Geom^.Data)^.VB;
        W := Inst.Transforms[Geom^.NodeID].TransformCom * Inst.Transform;
      end;
      _Gfx.Device.SetTransform(D3DTS_WORLD, W);
      VB.Bind;
      Geom^.IB.Bind;
      for m := 0 to Geom^.GCount - 1 do
      begin
        Material := Inst.Materials[Geom^.Groups[m].Material];
        if Material^.ChannelCount > 0 then
        begin
          if Material^.Channels[0].MapLight <> nil then
          begin
            _Gfx.Device.SetTexture(0, Material^.Channels[0].MapLight.GetTexture);
            _Gfx.Device.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
            _Gfx.Device.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
            _Gfx.Device.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
            _Gfx.Device.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_ADD);
            _Gfx.Device.SetTextureStageState(1, D3DTSS_COLORARG1, D3DTA_CURRENT);
            _Gfx.Device.SetTextureStageState(1, D3DTSS_COLORARG2, D3DTA_CONSTANT);
            _Gfx.Device.SetTextureStageState(1, D3DTSS_CONSTANT, _Ambient);
            _Gfx.Device.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
            _Gfx.Device.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
            _Gfx.Device.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, 1);
            _Gfx.Device.SetTextureStageState(2, D3DTSS_TEXCOORDINDEX, 0);
            CurStage := 2;
            _Gfx.Device.SetTextureStageState(3, D3DTSS_COLOROP, D3DTOP_DISABLE);
          end
          else
          begin
            CurStage := 0;
            _Gfx.Device.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, 0);
            _Gfx.Device.SetTextureStageState(2, D3DTSS_TEXCOORDINDEX, 2);
            _Gfx.Device.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
          end;
          if Material^.Channels[0].MapDiffuse <> nil then
          begin
            _Gfx.Device.SetTexture(CurStage, Material^.Channels[0].MapDiffuse.GetTexture);
            _Gfx.Device.SetTextureStageState(CurStage, D3DTSS_COLOROP, D3DTOP_MODULATE);
            if CurStage = 0 then
            _Gfx.Device.SetTextureStageState(CurStage, D3DTSS_COLORARG1, D3DTA_DIFFUSE)
            else
            _Gfx.Device.SetTextureStageState(CurStage, D3DTSS_COLORARG1, D3DTA_CURRENT);
            _Gfx.Device.SetTextureStageState(CurStage, D3DTSS_COLORARG2, D3DTA_TEXTURE);
            _Gfx.Device.SetSamplerState(CurStage, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
            _Gfx.Device.SetSamplerState(CurStage, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
          end;
        end;
        _Gfx.Device.DrawIndexedPrimitive(
          D3DPT_TRIANGLELIST,
          0,
          Geom^.Groups[m].VertexStart, Geom^.Groups[m].VertexCount,
          Geom^.Groups[m].FaceStart * 3, Geom^.Groups[m].FaceCount
        );
      end;
      Geom^.IB.Unbind;
      VB.Unbind;
    end;
  end;
  _Gfx.Device.SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_MODULATE);
  _Gfx.Device.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
  _Gfx.Device.SetTextureStageState(0, D3DTSS_COLORARG2, D3DTA_TEXTURE);
  _Gfx.Device.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, 0);
  _Gfx.Device.SetTextureStageState(1, D3DTSS_COLOROP, D3DTOP_DISABLE);
  _Gfx.Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  _Gfx.DepthEnable := PrevDepthEnable;
end;
{$elseif defined(G2RM_SM2)}
procedure TG2Scene3D.RenderD3D9;
  var i, g, m: TG2IntS32;
  var PrevDepthEnable: Boolean;
  var W, VP, WVP: TG2Mat;
  var Mesh: TG2S3DMesh;
  var Inst: TG2S3DMeshInst;
  var Geom: PG2S3DMeshGeom;
  var Material: PG2S3DMeshMaterial;
  var VB: TG2VertexBuffer;
  var Method: AnsiString;
  var Tex: array[0..1] of TG2TextureBase;
begin
  _Frustum.Update;
  PrevDepthEnable := _Gfx.DepthEnable;
  _Gfx.DepthEnable := True;
  _Gfx.Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);
  _Gfx.Device.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(0, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
  _Gfx.Device.SetSamplerState(1, D3DSAMP_MIPFILTER, D3DTEXF_LINEAR);
  VP := V * P;
  Tex[0] := nil;
  Tex[1] := nil;
  for i := 0 to _MeshInst.Count - 1 do
  begin
    Inst := TG2S3DMeshInst(_MeshInst[i]);
    Mesh := Inst.Mesh;
    if _Frustum.CheckBox(Inst.BBox) <> fcOutside then
    for g := 0 to Mesh.GeomCount - 1 do
    begin
      Geom := Mesh.Geoms[g];
      if Geom^.Skinned then
      begin
        VB := PG2S3DGeomDataSkinned(Geom^.Data)^.VB;
        W := Inst.Transform;
        Method := 'SceneB' + IntToStr(PG2S3DGeomDataSkinned(Geom^.Data)^.MaxWeights);
      end
      else
      begin
        VB := PG2S3DGeomDataStatic(Geom^.Data)^.VB;
        W := Inst.Transforms[Geom^.NodeID].TransformCom * Inst.Transform;
        Method := 'SceneB0';
      end;
      WVP := W * VP;
      VB.Bind;
      Geom^.IB.Bind;
      for m := 0 to Geom^.GCount - 1 do
      begin
        Material := Inst.Materials[Geom^.Groups[m].Material];
        if Material^.ChannelCount > 0 then
        begin
          if Material^.Channels[0].MapLight <> nil then
          begin
            _ShaderGroup.Method := Method + 'L';
            if Tex[1] <> Material^.Channels[0].MapLight then
            begin
              Tex[1] := Material^.Channels[0].MapLight;
              _ShaderGroup.Sampler('Tex1', Tex[1]);
            end;
          end
          else
          begin
            _ShaderGroup.Method := Method;
          end;
          if Material^.Channels[0].MapDiffuse <> nil then
          begin
            if Tex[0] <> Material^.Channels[0].MapDiffuse then
            begin
              Tex[0] := Material^.Channels[0].MapDiffuse;
              _ShaderGroup.Sampler('Tex0', Tex[0]);
            end;
          end;
        end;
        if Geom^.Skinned then
        _ShaderGroup.UniformMatrix4x3Arr('SkinPallete', @Inst.Skins[g]^.Transforms[0], 0, PG2S3DGeomDataSkinned(Geom^.Data)^.BoneCount);
        _ShaderGroup.UniformMatrix4x4('WVP', WVP);
        _ShaderGroup.UniformFloat4('LightAmbient', _Ambient);
        _Gfx.Device.DrawIndexedPrimitive(
          D3DPT_TRIANGLELIST,
          0,
          Geom^.Groups[m].VertexStart, Geom^.Groups[m].VertexCount,
          Geom^.Groups[m].FaceStart * 3, Geom^.Groups[m].FaceCount
        );
      end;
      Geom^.IB.Unbind;
      VB.Unbind;
    end;
  end;
  _Gfx.Device.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
  _Gfx.DepthEnable := PrevDepthEnable;
end;
{$endif}
{$elseif defined(G2Gfx_OGL)}
{$if defined(G2RM_FF)}
procedure TG2Scene3D.RenderOGL;
  var i, g, m: TG2IntS32;
  var f: TG2Float;
  var CurStage: TG2IntU32;
  var W, VP: TG2Mat;
  var Mesh: TG2S3DMesh;
  var Inst: TG2S3DMeshInst;
  var Geom: PG2S3DMeshGeom;
  var Material: PG2S3DMeshMaterial;
  var PrevDepthEnable: Boolean;
  var VB: TG2VertexBuffer;
  var EnvColor: TG2Vec4;
begin
  _Frustum.Update;
  PrevDepthEnable := _Gfx.DepthEnable;
  _Gfx.DepthEnable := True;
  glEnable(GL_CULL_FACE);
  VP := V * P;
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf(@VP);
  glMatrixMode(GL_MODELVIEW);
  for i := 0 to _MeshInst.Count - 1 do
  begin
    Inst := TG2S3DMeshInst(_MeshInst[i]);
    Mesh := Inst.Mesh;
    if _Frustum.CheckBox(Inst.BBox) <> fcOutside then
    for g := 0 to Mesh.GeomCount - 1 do
    begin
      Geom := Mesh.Geoms[g];
      if Geom^.Skinned then
      begin
        VB := Inst.Skins[g]^.VB;
        W := Inst.Transform;
      end
      else
      begin
        VB := PG2S3DGeomDataStatic(Geom^.Data)^.VB;
        W := Inst.Transforms[Geom^.NodeID].TransformCom * Inst.Transform;
      end;
      glLoadMatrixf(@W);
      VB.Bind;
      Geom^.IB.Bind;
      for m := 0 to Geom^.GCount - 1 do
      begin
        Material := Inst.Materials[Geom^.Groups[m].Material];
        if Material^.ChannelCount > 0 then
        begin
          if Material^.Channels[0].MapLight <> nil then
          begin
            glActiveTexture(GL_TEXTURE0);
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, Material^.Channels[0].MapLight.GetTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
            glClientActiveTexture(GL_TEXTURE0);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2, GL_FLOAT, VB.VertexSize, VB.TexCoordIndex[1]);
            glActiveTexture(GL_TEXTURE1);
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, Material^.Channels[0].MapLight.GetTexture);
            _Gfx.Filter := tfLinear;
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_CONSTANT);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_REPLACE);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
            EnvColor.SetValue(_Ambient.r * Rcp255, _Ambient.g * Rcp255, _Ambient.b * Rcp255, 1);
            glTexEnvfv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, @EnvColor);
            glClientActiveTexture(GL_TEXTURE1);
            glDisableClientState(GL_TEXTURE_COORD_ARRAY);
            CurStage := GL_TEXTURE2;
          end
          else
          begin
            CurStage := GL_TEXTURE0;
            glActiveTexture(GL_TEXTURE1);
            glDisable(GL_TEXTURE_2D);
          end;
          if Material^.Channels[0].MapDiffuse <> nil then
          begin
            glActiveTexture(CurStage);
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, Material^.Channels[0].MapDiffuse.GetTexture);
            if Material^.Channels[0].MapDiffuse.Usage = tuUsage3D then
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
            else
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
            if CurStage = GL_TEXTURE0 then
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR)
            else
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
            if CurStage = GL_TEXTURE0 then
            glTexEnvi(GL_TEXTURE_2D, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR)
            else
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
            glClientActiveTexture(CurStage);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2, GL_FLOAT, VB.VertexSize, VB.TexCoordIndex[0]);
          end;
        end;
        glDrawElements(
          GL_TRIANGLES,
          Geom^.Groups[m].FaceCount * 3,
          GL_UNSIGNED_SHORT,
          {$Hints off}PGLVoid(Geom^.Groups[m].FaceStart * 6){$Hints on}
        );
      end;
      Geom^.IB.Unbind;
      VB.Unbind;
    end;
  end;
  glActiveTexture(GL_TEXTURE2);
  glDisable(GL_TEXTURE_2D);
  glActiveTexture(GL_TEXTURE1);
  glDisable(GL_TEXTURE_2D);
  glClientActiveTexture(GL_TEXTURE2);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glClientActiveTexture(GL_TEXTURE1);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glClientActiveTexture(GL_TEXTURE0);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
  glDisable(GL_CULL_FACE);
  _Gfx.DepthEnable := PrevDepthEnable;
end;
{$elseif defined(G2RM_SM2)}
procedure TG2Scene3D.RenderOGL;
  var i, g, m: TG2IntS32;
  var f: TG2Float;
  var CurStage: TG2IntU32;
  var W, VP, WVP: TG2Mat;
  var Mesh: TG2S3DMesh;
  var Inst: TG2S3DMeshInst;
  var Geom: PG2S3DMeshGeom;
  var Material: PG2S3DMeshMaterial;
  var PrevDepthEnable: Boolean;
  var VB: TG2VertexBuffer;
  var Method: AnsiString;
  var Tex: array[0..1] of TG2TextureBase;
begin
  _Frustum.Update;
  PrevDepthEnable := _Gfx.DepthEnable;
  _Gfx.DepthEnable := True;
  glEnable(GL_CULL_FACE);
  VP := V * P;
  Tex[0] := nil;
  Tex[1] := nil;
  for i := 0 to _MeshInst.Count - 1 do
  begin
    Inst := TG2S3DMeshInst(_MeshInst[i]);
    Mesh := Inst.Mesh;
    if _Frustum.CheckBox(Inst.BBox) <> fcOutside then
    for g := 0 to Mesh.GeomCount - 1 do
    begin
      Geom := Mesh.Geoms[g];
      if Geom^.Skinned then
      begin
        VB := PG2S3DGeomDataSkinned(Geom^.Data)^.VB;
        W := Inst.Transform;
        Method := 'SceneB' + IntToStr(PG2S3DGeomDataSkinned(Geom^.Data)^.MaxWeights);
      end
      else
      begin
        VB := PG2S3DGeomDataStatic(Geom^.Data)^.VB;
        W := Inst.Transforms[Geom^.NodeID].TransformCom * Inst.Transform;
        Method := 'SceneB0';
      end;
      WVP := W * VP;
      Geom^.IB.Bind;
      for m := 0 to Geom^.GCount - 1 do
      begin
        Material := Inst.Materials[Geom^.Groups[m].Material];
        _ShaderGroup.Method := 'SceneB0';
        if Material^.ChannelCount > 0 then
        begin
          if Material^.Channels[0].MapLight <> nil then
          begin
            _ShaderGroup.Method := Method + 'L';
            if Tex[1] <> Material^.Channels[0].MapLight then
            begin
              Tex[1] := Material^.Channels[0].MapLight;
              _ShaderGroup.Sampler('Tex1', Tex[1], 1);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            end
            else
            _ShaderGroup.UniformInt1('Tex1', 1);
          end
          else
          begin
            _ShaderGroup.Method := Method;
          end;
          if Material^.Channels[0].MapDiffuse <> nil then
          begin
            if Tex[0] <> Material^.Channels[0].MapDiffuse then
            begin
              Tex[0] := Material^.Channels[0].MapDiffuse;
              _ShaderGroup.Sampler('Tex0', Tex[0], 0);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            end
            else
            _ShaderGroup.UniformInt1('Tex0', 0);
          end;
        end;
        if Geom^.Skinned then
        _ShaderGroup.UniformMatrix4x4Arr('SkinPallete', @Inst.Skins[g]^.Transforms[0], 0, PG2S3DGeomDataSkinned(Geom^.Data)^.BoneCount);
        _ShaderGroup.UniformMatrix4x4('WVP', WVP);
        _ShaderGroup.UniformFloat4('LightAmbient', _Ambient);
        VB.Bind;
        glDrawElements(
          GL_TRIANGLES,
          Geom^.Groups[m].FaceCount * 3,
          GL_UNSIGNED_SHORT,
          {$Hints off}PGLVoid(Geom^.Groups[m].FaceStart * 6){$Hints on}
        );
        VB.Unbind;
      end;
      Geom^.IB.Unbind;
    end;
  end;
  glDisable(GL_CULL_FACE);
  _Gfx.DepthEnable := PrevDepthEnable;
end;
{$endif}
{$elseif defined(G2Gfx_GLES)}
{$if defined(G2RM_FF)}
procedure TG2Scene3D.RenderGLES;
  var i, g, m: TG2IntS32;
  var f: TG2Float;
  var CurStage: TG2IntU32;
  var W, VP: TG2Mat;
  var Mesh: TG2S3DMesh;
  var Inst: TG2S3DMeshInst;
  var Geom: PG2S3DMeshGeom;
  var Material: PG2S3DMeshMaterial;
  var PrevDepthEnable: Boolean;
  var VB: TG2VertexBuffer;
  var EnvColor: TG2Vec4;
begin
  _Frustum.Update;
  PrevDepthEnable := _Gfx.DepthEnable;
  _Gfx.DepthEnable := True;
  glEnable(GL_CULL_FACE);
  VP := V * P;
  glMatrixMode(GL_PROJECTION);
  glLoadMatrixf(@VP);
  glMatrixMode(GL_MODELVIEW);
  EnvColor.SetValue(_Ambient.r * Rcp255, _Ambient.g * Rcp255, _Ambient.b * Rcp255, 1);
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @EnvColor);
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, @EnvColor);
  for i := 0 to _MeshInst.Count - 1 do
  begin
    Inst := TG2S3DMeshInst(_MeshInst[i]);
    Mesh := Inst.Mesh;
    if _Frustum.CheckBox(Inst.BBox) <> fcOutside then
    for g := 0 to Mesh.GeomCount - 1 do
    begin
      Geom := Mesh.Geoms[g];
      if Geom^.Skinned then
      begin
        VB := Inst.Skins[g]^.VB;
        W := Inst.Transform;
      end
      else
      begin
        VB := PG2S3DGeomDataStatic(Geom^.Data)^.VB;
        W := Inst.Transforms[Geom^.NodeID].TransformCom * Inst.Transform;
      end;
      glLoadMatrixf(@W);
      VB.Bind;
      Geom^.IB.Bind;
      for m := 0 to Geom^.GCount - 1 do
      begin
        Material := Inst.Materials[Geom^.Groups[m].Material];
        glActiveTexture(GL_TEXTURE0);
        glDisable(GL_TEXTURE_2D);
        if Material^.ChannelCount > 0 then
        begin
          CurStage := GL_TEXTURE0;
          if Material^.Channels[0].MapLight <> nil then
          begin
            glEnable(GL_LIGHTING);
            glActiveTexture(CurStage);
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, Material^.Channels[0].MapLight.GetTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_ADD);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
            glClientActiveTexture(CurStage);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2, GL_FLOAT, VB.VertexSize, VB.TexCoordIndex[1]);
            Inc(CurStage);
          end
          else
          glDisable(GL_LIGHTING);
          if Material^.Channels[0].MapDiffuse <> nil then
          begin
            glActiveTexture(CurStage);
            glEnable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D, Material^.Channels[0].MapDiffuse.GetTexture);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
            glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
            if CurStage = GL_TEXTURE0 then
            begin
              glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
              glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
            end
            else
            begin
              glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PREVIOUS);
              glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PREVIOUS);
            end;
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
            glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
            glClientActiveTexture(CurStage);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glTexCoordPointer(2, GL_FLOAT, VB.VertexSize, VB.TexCoordIndex[0]);
            Inc(CurStage);
          end;
        end;
        glDrawElements(
          GL_TRIANGLES,
          Geom^.Groups[m].FaceCount * 3,
          GL_UNSIGNED_SHORT,
          {$Hints off}PGLVoid(Geom^.Groups[m].FaceStart * 6){$Hints on}
        );
      end;
      Geom^.IB.Unbind;
      VB.Unbind;
    end;
  end;
  glDisable(GL_LIGHTING);
  glActiveTexture(GL_TEXTURE2);
  glDisable(GL_TEXTURE_2D);
  glActiveTexture(GL_TEXTURE1);
  glDisable(GL_TEXTURE_2D);
  glClientActiveTexture(GL_TEXTURE2);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glClientActiveTexture(GL_TEXTURE1);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glClientActiveTexture(GL_TEXTURE0);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glActiveTexture(GL_TEXTURE0);
  glEnable(GL_TEXTURE_2D);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_RGB, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_RGB, GL_TEXTURE);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_RGB, GL_SRC_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_RGB, GL_SRC_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_COMBINE_ALPHA, GL_MODULATE);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE0_ALPHA, GL_PRIMARY_COLOR);
  glTexEnvi(GL_TEXTURE_ENV, GL_SOURCE1_ALPHA, GL_TEXTURE);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND0_ALPHA, GL_SRC_ALPHA);
  glTexEnvi(GL_TEXTURE_ENV, GL_OPERAND1_ALPHA, GL_SRC_ALPHA);
  glDisable(GL_CULL_FACE);
  _Gfx.DepthEnable := PrevDepthEnable;
end;
{$elseif defined(G2RM_SM2)}
procedure TG2Scene3D.RenderGLES;
  var i, g, m: TG2IntS32;
  var f: TG2Float;
  var CurStage: IntU32;
  var W, VP, WVP: TG2Mat;
  var Mesh: TG2S3DMesh;
  var Inst: TG2S3DMeshInst;
  var Geom: PG2S3DMeshGeom;
  var Material: PG2S3DMeshMaterial;
  var PrevDepthEnable: Boolean;
  var VB: TG2VertexBuffer;
  var Method: AnsiString;
  var Tex: array[0..1] of TG2TextureBase;
begin
  _Frustum.Update;
  PrevDepthEnable := _Gfx.DepthEnable;
  _Gfx.DepthEnable := True;
  glEnable(GL_CULL_FACE);
  VP := V * P;
  Tex[0] := nil;
  Tex[1] := nil;
  for i := 0 to _MeshInst.Count - 1 do
  begin
    Inst := TG2S3DMeshInst(_MeshInst[i]);
    Mesh := Inst.Mesh;
    if _Frustum.CheckBox(Inst.BBox) <> fcOutside then
    for g := 0 to Mesh.GeomCount - 1 do
    begin
      Geom := Mesh.Geoms[g];
      if Geom^.Skinned then
      begin
        VB := PG2S3DGeomDataSkinned(Geom^.Data)^.VB;
        W := Inst.Transform;
        Method := 'SceneB' + IntToStr(PG2S3DGeomDataSkinned(Geom^.Data)^.MaxWeights);
      end
      else
      begin
        VB := PG2S3DGeomDataStatic(Geom^.Data)^.VB;
        W := Inst.Transforms[Geom^.NodeID].TransformCom * Inst.Transform;
        Method := 'SceneB0';
      end;
      WVP := W * VP;
      Geom^.IB.Bind;
      for m := 0 to Geom^.GCount - 1 do
      begin
        Material := Inst.Materials[Geom^.Groups[m].Material];
        _ShaderGroup.Method := 'SceneB0';
        if Material^.ChannelCount > 0 then
        begin
          if Material^.Channels[0].MapLight <> nil then
          begin
            _ShaderGroup.Method := Method + 'L';
            if Tex[1] <> Material^.Channels[0].MapLight then
            begin
              Tex[1] := Material^.Channels[0].MapLight;
              _ShaderGroup.Sampler('Tex1', Tex[1], 1);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            end
            else
            _ShaderGroup.UniformInt1('Tex1', 1);
          end
          else
          begin
            _ShaderGroup.Method := Method;
          end;
          if Material^.Channels[0].MapDiffuse <> nil then
          begin
            if Tex[0] <> Material^.Channels[0].MapDiffuse then
            begin
              Tex[0] := Material^.Channels[0].MapDiffuse;
              _ShaderGroup.Sampler('Tex0', Tex[0], 0);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            end
            else
            _ShaderGroup.UniformInt1('Tex0', 0);
          end;
        end;
        if Geom^.Skinned then
        _ShaderGroup.UniformMatrix4x4Arr('SkinPallete', @Inst.Skins[g]^.Transforms[0], 0, PG2S3DGeomDataSkinned(Geom^.Data)^.BoneCount);
        _ShaderGroup.UniformMatrix4x4('WVP', WVP);
        _ShaderGroup.UniformFloat4('LightAmbient', _Ambient);
        VB.Bind;
        glDrawElements(
          GL_TRIANGLES,
          Geom^.Groups[m].FaceCount * 3,
          GL_UNSIGNED_SHORT,
          {$Hints off}PGLVoid(Geom^.Groups[m].FaceStart * 6){$Hints on}
        );
        VB.Unbind;
      end;
      Geom^.IB.Unbind;
    end;
  end;
  glDisable(GL_CULL_FACE);
  _Gfx.DepthEnable := PrevDepthEnable;
end;
{$endif}
{$endif}

procedure TG2Scene3D.RenderParticles;
  var gi, i: TG2IntS32;
  var ViewDir: TG2Vec3;
  var g: PG2S3DParticleGroup;
  var pt: TG2S3DParticle;
  var CurRender: TG2S3DParticleRender;
begin
  if _ParticleGroups.Count = 0 then Exit;
  _StatParticlesRendered := 0;
  CurRender := nil;
  ViewDir := G2Vec3(V.e02, V.e12, V.e22).Norm;
  _ParticlesSorted.Clear;
  for gi := 0 to _ParticleGroups.Count - 1 do
  begin
    g := PG2S3DParticleGroup(_ParticleGroups[gi]);
    if _Frustum.CheckBox(g^.AABox) <> fcOutside then
    begin
      for i := 0 to g^.Items.Count - 1 do
      begin
        pt := TG2S3DParticle(g^.Items[i]);
        if pt.DepthSorted then
        _ParticlesSorted.Add(pt, ViewDir.Dot(pt.Pos))
        else
        begin
          if CurRender <> pt.ParticleRender then
          begin
            if CurRender <> nil then
            CurRender.RenderEnd;
            CurRender := pt.ParticleRender;
            CurRender.RenderBegin;
          end;
          CurRender.RenderParticle(pt);
          Inc(_StatParticlesRendered);
        end;
      end;
    end;
  end;
  for i := _ParticlesSorted.Count - 1 downto 0 do
  begin
    pt := TG2S3DParticle(_ParticlesSorted[i]);
    if CurRender <> pt.ParticleRender then
    begin
      if CurRender <> nil then
      CurRender.RenderEnd;
      CurRender := pt.ParticleRender;
      CurRender.RenderBegin;
    end;
    CurRender.RenderParticle(pt);
    Inc(_StatParticlesRendered);
  end;
  if CurRender <> nil then
  CurRender.RenderEnd;
end;

procedure TG2Scene3D.DoRender;
begin
  {$if defined(G2Gfx_D3D9)}
  RenderD3D9;
  {$elseif defined(G2Gfx_OGL)}
  RenderOGL;
  {$elseif defined(G2Gfx_GLES)}
  RenderGLES;
  {$endif}
  RenderParticles;
end;

procedure TG2Scene3D.Update;
  var i, n: TG2IntS32;
  var pt: TG2S3DParticle;
  var g: PG2S3DParticleGroup;
begin
  _UpdatingParticles := True;
  for i := 0 to _ParticleGroups.Count - 1 do
  begin
    g := PG2S3DParticleGroup(_ParticleGroups[i]);
    g^.AABox := TG2S3DParticle(g^.Items[0]).AABox;
    g^.MaxSize := 0;
  end;
  n := _Particles.Count;
  i := 0;
  while i < n do
  begin
    pt := TG2S3DParticle(_Particles[i]);
    pt.Update;
    g := TG2S3DParticle(_Particles[i]).Group;
    if pt.Dead then
    begin
      g^.Items.Remove(pt);
      pt.Free;
      _Particles.Delete(i);
      if g^.Items.Count < 1 then
      begin
        _ParticleGroups.Remove(g);
        Dispose(g);
      end;
      Dec(n);
    end
    else
    begin
      g^.MaxSize := g^.MaxSize + pt.Size;
      g^.AABox.Include(pt.AABox);
      Inc(i);
    end;
  end;
  for i := 0 to _ParticleGroups.Count - 1 do
  begin
    g := PG2S3DParticleGroup(_ParticleGroups[i]);
    g^.MaxSize := g^.MaxSize / g^.Items.Count;
    g^.MinSize := g^.MaxSize * 0.1;
    g^.MaxSize := g^.MaxSize * 10;
  end;
  _UpdatingParticles := False;
  for i := 0 to _NewParticles.Count - 1 do
  ParticleAdd(TG2S3DParticle(_NewParticles[i]));
  _NewParticles.Clear;
end;

procedure TG2Scene3D.Build;
begin

end;

procedure TG2Scene3D.ParticleAdd(const Particle: TG2S3DParticle);
  var i, n: TG2IntS32;
  var Bounds: TG2AABox;
  var g: PG2S3DParticleGroup;
  var ps: TG2Float;
begin
  if _UpdatingParticles then
  begin
    _NewParticles.Add(Particle);
    Exit;
  end;
  _Particles.Add(Particle);
  n := -1;
  for i := 0 to _ParticleRenders.Count - 1 do
  if TG2S3DParticleRender(_ParticleRenders[i]) is Particle.RenderClass then
  begin
    n := i;
    Break;
  end;
  if n = -1 then
  begin
    n := _ParticleRenders.Count;
    _ParticleRenders.Add(Particle.RenderClass.Create(Self));
  end;
  Particle.ParticleRender := TG2S3DParticleRender(_ParticleRenders[n]);
  ps := Particle.Size * 2;
  Bounds.MinV.x := Particle.Pos.x - ps;
  Bounds.MinV.y := Particle.Pos.y - ps;
  Bounds.MinV.z := Particle.Pos.z - ps;
  Bounds.MaxV.x := Particle.Pos.x + ps;
  Bounds.MaxV.y := Particle.Pos.y + ps;
  Bounds.MaxV.z := Particle.Pos.z + ps;
  g := nil;
  for i := 0 to _ParticleGroups.Count - 1 do
  if (Particle.Size >= PG2S3DParticleGroup(_ParticleGroups[i])^.MinSize)
  and (Particle.Size <= PG2S3DParticleGroup(_ParticleGroups[i])^.MaxSize)
  and (Bounds.Intersect(PG2S3DParticleGroup(_ParticleGroups[i])^.AABox)) then
  begin
    g := PG2S3DParticleGroup(_ParticleGroups[i]);
    g^.MaxSize := (g^.MaxSize * 0.1 * g^.Items.Count + Particle.Size) / (g^.Items.Count + 1);
    g^.MinSize := g^.MaxSize * 0.1;
    g^.MaxSize := g^.MaxSize * 10;
    g^.Items.Add(Particle);
    g^.AABox.Include(Particle.AABox);
    Particle.Group := g;
    Exit;
  end;
  New(g);
  _ParticleGroups.Add(g);
  g^.Items.Clear;
  g^.Items.Add(Particle);
  g^.AABox := Particle.AABox;
  g^.MinSize := Particle.Size * 0.1;
  g^.MaxSize := Particle.Size * 0.1;
  Particle.Group := g;
end;

function TG2Scene3D.FindTexture(const TextureName: AnsiString; const Usage: TG2TextureUsage = tuDefault): TG2Texture2D;
  var i: TG2IntS32;
  var pt: PG2S3DTexture;
begin
  for i := 0 to _Textures.Count - 1 do
  if PG2S3DTexture(_Textures[i])^.Name = TextureName then
  begin
    Result := PG2S3DTexture(_Textures[i])^.Texture;
    Exit;
  end;
  New(pt);
  pt^.Name := TextureName;
  pt^.Texture := TG2Texture2D.Create;
  pt^.Texture.Load(TextureName, Usage);
  Result := pt^.Texture;
  _Textures.Add(pt);
end;

constructor TG2Scene3D.Create;
begin
  inherited Create;
  {$if defined(G2Gfx_D3D9)}
  _Gfx := TG2GfxD3D9(g2.Gfx);
  {$elseif defined(G2Gfx_OGL)}
  _Gfx := TG2GfxOGL(g2.Gfx);
  {$elseif defined(G2Gfx_GLES)}
  _Gfx := TG2GfxGLES(g2.Gfx);
  {$endif}
  {$if defined(G2RM_SM2)}
  _ShaderGroup := _Gfx.RequestShader('StandardShaders');
  {$endif}
  _Textures.Clear;
  _Nodes.Clear;
  _Frames.Clear;
  _MeshInst.Clear;
  _Meshes.Clear;
  _Particles.Clear;
  _NewParticles.Clear;
  _ParticleGroups.Clear;
  _ParticleRenders.Clear;
  _Frustum.RefV := @V;
  _Frustum.RefP := @P;
  _OcTreeRoot := nil;
  _UpdatingParticles := False;
  _StatParticlesRendered := 0;
  _Ambient := $ff141414;
end;

destructor TG2Scene3D.Destroy;
  var i: TG2IntS32;
begin
  for i := 0 to _NewParticles.Count - 1 do
  TG2S3DParticle(_NewParticles[i]).Free;
  _NewParticles.Clear;
  for i := 0 to _Particles.Count - 1 do
  TG2S3DParticle(_Particles[i]).Free;
  _Particles.Clear;
  for i := 0 to _ParticleGroups.Count - 1 do
  Dispose(PG2S3DParticleGroup(_ParticleGroups[i]));
  _ParticleGroups.Clear;
  for i := 0 to _ParticleRenders.Count - 1 do
  TG2S3DParticleRender(_ParticleRenders[i]).Free;
  _ParticleRenders.Clear;
  while _Nodes.Count > 0 do
  TG2S3DNode(_Nodes[0]).Free;
  while _Meshes.Count > 0 do
  TG2S3DMesh(_Meshes[0]).Free;
  for i := 0 to _Textures.Count - 1 do
  begin
    PG2S3DTexture(_Textures[i])^.Texture.Free;
    Dispose(PG2S3DTexture(_Textures[i]));
  end;
  _Textures.Clear;
  inherited Destroy;
end;
//TG2Scene3D END

{$if defined(G2Target_Android)}
type timeval = packed record
 tv_sec: TG2IntU32;
 tv_usec: TG2IntU32;
end;
function gettimeofday(timeval, timezone: Pointer): TG2IntS32; cdecl; external 'libc';
{$endif}

function G2Time: TG2IntU32;
{$if defined(G2Target_Android)}
  var CurTimeVal: timeval;
{$endif}
begin
  {$if defined(G2Target_Windows)}
  Result := GetTickCount;
  {$elseif defined(G2Target_Linux) or defined(G2Target_OSX)}
  Result := TG2IntU32(Trunc(Now * 24 * 60 * 60 * 1000));
  {$elseif defined(G2Target_Android)}
  gettimeofday(@CurTimeVal, nil);
  Result := CurTimeVal.tv_sec * 1000 + CurTimeVal.tv_usec div 1000;
  {$elseif defined(G2Target_iOS)}
  Result := TG2IntU32(Trunc(CACurrentMediaTime * 1000));
  {$endif}
end;

function G2PiTime(Amp: TG2Float = 1000): TG2Float;
begin
  Result := (G2Time mod Round(TwoPi * Amp)) / (Amp);
end;

function G2PiTime(Amp: TG2Float; Time: TG2IntU32): TG2Float;
begin
  Result := (Time mod Round(TwoPi * Amp)) / (Amp);
end;

function G2TimeInterval(Interval: TG2IntU32 = 1000): TG2Float;
begin
  Result := (G2Time mod Interval) / Interval;
end;

function G2TimeInterval(Interval: TG2IntU32; Time: TG2IntU32): TG2Float;
begin
  Result := (Time mod Interval) / Interval;
end;

function G2RandomPi: TG2Float;
begin
  {$ifdef G2Target_OSX}
  Result := Random * Pi;
  {$else}
  Result := Random(Round(Pi * 1000)) / 1000;
  {$endif}
end;

function G2Random2Pi: TG2Float;
begin
  Result := System.Random(Round(TwoPi * 1000)) / 1000;
end;

function G2RandomCirclePoint: TG2Vec2;
  var a: TG2Float;
begin
  a := G2Random2Pi;
  {$Hints off}
  G2SinCos(a, Result.y, Result.x);
  {$Hints on}
end;

function G2RandomSpherePoint: TG2Vec3;
  var a1, a2, s1, s2, c1, c2: TG2Float;
begin
  a1 := G2Random2Pi;
  a2 := G2Random2Pi;
  {$Hints off}
  G2SinCos(a1, s1, c1);
  G2SinCos(a2, s2, c2);
  {$Hints on}
  {$Warnings off}
  Result.SetValue(c1 * c2, s2, s1 * c2);
  {$Warnings on}
end;

function G2RectInRect(const R0, R1: TRect): Boolean;
begin
  Result := (
    (R0.Left <= R1.Right)
    and (R0.Right >= R1.Left)
    and (R0.Top <= R1.Bottom)
    and (R0.Bottom >= R1.Top)
  );
end;

function G2RectInRect(const R0, R1: TG2Rect): Boolean;
begin
  Result := (
    (R0.l <= R1.r)
    and (R0.r >= R1.l)
    and (R0.t <= R1.b)
    and (R0.b >= R1.t)
  );
end;

function G2KeyName(const Key: TG2IntS32): AnsiString;
  const NameMap: array[0..102] of AnsiString = (
    'Escape', 'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9',
    'F10', 'F11', 'F12', 'Scroll Lock', 'Pause', 'Tilda', '1', '2', '3', '4',
    '5', '6', '7', '8', '9', '0', 'Minus', 'Plus', 'Backspace', 'Tab',
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z', 'Left Braket', 'Right Braket', 'Semicolon', 'Quote',
    'Comma', 'Period', 'Slash', 'Reverse Slash', 'Caps Lock', 'Shift', 'Shift', 'Control', 'Control', 'Win',
    'Win', 'Alt', 'Alt', 'Menu', 'Return', 'Space', 'Insert', 'Home', 'Page Up', 'Delete',
    'End', 'Page Down', 'Up', 'Down', 'Left', 'Right', 'Num Lock', 'NumDiv', 'NumMul', 'NumMinus',
    'NumPlus', 'NumReturn', 'NumPeriod', 'Num0', 'Num1', 'Num2', 'Num3', 'Num4', 'Num5', 'Num6',
    'Num7', 'Num8', 'Num9'
  );
begin
  if (Key >= 0) and (Key <= High(NameMap)) then Result := NameMap[Key] else Result := 'Undefined';
end;

procedure G2TraceBegin;
begin
  TraceTime := G2Time;
end;

function G2TraceEnd: TG2IntU32;
begin
  Result := G2Time - TraceTime;
end;

{$if defined(G2Cpu386)}
procedure G2BreakPoint;
asm
  int 3;
end;
{$endif}

procedure SafeRelease(var i);
begin
  if IUnknown(i) <> nil then IUnknown(i) := nil;
end;

initialization
begin
  G2Initialize;
end;

finalization
begin
  G2Finalize;
end;

end.