unit Toolkit;

{$mode objfpc}{$H+}
interface

uses
  Gen2MP,
  {$ifdef windows}
  Windows,
  {$endif}
  G2Utils,
  G2Types,
  G2Math,
  G2Scene2D,
  G2DataManager,
  G2Image,
  G2ImagePNG,
  Types,
  SysUtils,
  Classes,
  Math,
  Interfaces,
  LCLType,
  Clipbrd,
  Dialogs,
  Process,
  UTF8Process,
  FileUtil,
  res,
  box2d,
  Spine,
  G2Spine;

type
  TUIWorkspace = class;
  TUIWorkspaceFrame = class;
  TUIWorkspaceCustom = class;
  TCodeInsightSymbol = class;
  TCodeInsightSymbolFile = class;
  TUIWorkspaceScene2DStructure = class;
  TUIWorkspaceParticles2DEditor = class;
  TUIWorkspaceParticles2DViewport = class;
  TAsset = class;
  TAssetImage = class;
  TAssetTexture = class;
  TAssetEffect2D = class;
  TParticleObject = class;
  TParticleEmitter = class;
  TUIWorkspaceConstructor = class;
  CAsset = class of TAsset;

  TCharSet = set of AnsiChar;

  TVec2List = specialize TG2QuickListG<TG2Vec2>;
  TVec3List = specialize TG2QuickListG<TG2Vec3>;

//TScrollBox BEGIN
  TScrollBoxOrientation = (sbVertical, sbHorizontal);
  TScrollBox = object
  private
    _Enabled: Boolean;
    _Frame: TG2Rect;
    _Orientation: TScrollBoxOrientation;
    _ParentSize: Single;
    _ContentSize: Single;
    _Pos: Single;
    _MDown: Boolean;
    _MDPos: Single;
    _ProcOnChange: TG2ProcObj;
    function GetSliderRect: TG2Rect;
    function GetPosAbsolute: Single;
    procedure SetPosAbsolute(const Value: Single);
  public
    property Enabled: Boolean read _Enabled write _Enabled;
    property ParentSize: Single read _ParentSize write _ParentSize;
    property ContentSize: Single read _ContentSize write _ContentSize;
    property Orientation: TScrollBoxOrientation read _Orientation write _Orientation;
    property Frame: TG2Rect read _Frame write _Frame;
    property PosRelative: Single read _Pos write _Pos;
    property PosAbsolute: Single read GetPosAbsolute write SetPosAbsolute;
    property OnChange: TG2ProcObj read _ProcOnChange write _ProcOnChange;
    procedure Initialize;
    procedure Render;
    procedure Update;
    procedure MouseDown(const Button, x, y: Integer);
    procedure MouseUp(const Button, x, y: Integer);
    procedure Scroll(const Amount: Integer);
  end;
//TScrollBox END

//TOverlayObject BEGIN
  TOverlayObject = class
  public
    procedure Render; virtual;
    procedure Update; virtual;
    procedure MouseDown(const Button, x, y: Integer); virtual;
    procedure MouseUp(const Button, x, y: Integer); virtual;
    procedure Scroll(const y: Integer); virtual;
    constructor Create; virtual;
    destructor Destroy; override;
  end;
//TOverlayObject END

//TOverlayWorkspaceList BEGIN
  TOverlayWorkspaceList = class (TOverlayObject)
  private
    type TWorkspaceListItem = class
    public
      var Name: AnsiString;
      var Pos: TG2Vec2;
      var Size: TG2Vec2;
      var ParentList: PG2QuickList;
    end;
    type TWorkspaceListItemPath = class (TWorkspaceListItem)
    public
      var Open: Boolean;
      var Items: TG2QuickList;
    end;
    type TWorkspaceListItemConstructor = class (TWorkspaceListItem)
    public
      var WorkspaceClassConstructor: TUIWorkspaceConstructor;
    end;
    var _Root: TWorkspaceListItemPath;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadWorkspaces;
    procedure Initialize(const NewPos: TG2Vec2);
    procedure Clear;
    procedure Render; override;
    procedure Update; override;
    procedure MouseDown(const Button, x, y: Integer); override;
    procedure MouseUp(const Button, x, y: Integer); override;
  end;
//TOverlayWorkspaceList END

//TOverlayWorkspace BEGIN
  TOverlayWorkspace = class (TOverlayObject)
  private
    var _Workspace: TUIWorkspace;
    var _Size: TG2Vec2;
    procedure SetWorkspace(const Value: TUIWorkspace);
  public
    property Workspace: TUIWorkspace read _Workspace write SetWorkspace;
    procedure Render; override;
    procedure Update; override;
    procedure MouseUp(const Button, x, y: Integer); override;
  end;
//TOverlayWorkspace END

//TOverlayPopUp BEGIN
  TOverlayPopUp = class (TOverlayObject)
  private
    type TPopUpItem = class
    public
      var Parent: TPopUpItem;
      var Name: String;
    end;
    type TItemList = specialize TG2QuickListG<TPopUpItem>;
    type TPopUpGroup = class (TPopUpItem)
    public
      var ItemList: TItemList;
      var Open: Boolean;
      var Pos: TG2Vec2;
      var Size: TG2Vec2;
    end;
    type TPopUpButton = class (TPopUpItem)
    public
      var Callback: TG2ProcObj;
    end;
    var _Root: TPopUpGroup;
    var _ItemHeight: Single;
    var _MdValid: array[0..2] of Boolean;
    function PtInItem(const x, y: Single): TPopUpItem;
    function GetPosition: TG2Vec2; inline;
  public
    property Position: TG2Vec2 read GetPosition;
    constructor Create; override;
    destructor Destroy; override;
    function IsEmpty: Boolean;
    procedure Show(const Pos: TG2Vec2);
    procedure AddButton(const Path: String; const Callback: TG2ProcObj);
    procedure Clear;
    procedure Render; override;
    procedure Update; override;
    procedure MouseDown(const Button, x, y: Integer); override;
    procedure MouseUp(const Button, x, y: Integer); override;
  end;
//TOverlayPopUp END

//TOverlayAssetSelect BEGIN
  TOverlayAssetSelect = class (TOverlayObject)
  private
    type TFileList = TG2QuickListString;
    type TAssetType = record
      AssetClass: CAsset;
      Files: TFileList;
    end;
    type PAssetType = ^TAssetType;
    type TAssetTypes = specialize TG2QuickListG<PAssetType>;
    var _AssetTypes: TAssetTypes;
    var _Frame: TG2Rect;
    var _TypeListFrame: TG2Rect;
    var _ListFrame: TG2Rect;
    var _BtnCancelFrame: TG2Rect;
    var _BtnSelectFrame: TG2Rect;
    var _TypeIndex: Integer;
    var _FileIndex: Integer;
    var _Callback: TG2ProcStringObj;
    var _ScrollV: TScrollBox;
    var _ItemSize: Integer;
    procedure AddAssetType(const AssetClass: CAsset);
    function GetFileFrame(const Index: Integer): TG2Rect;
    function GetFileContentSize: TG2Float;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Open(const AssetClass: CAsset; const Callback: TG2ProcStringObj);
    procedure Render; override;
    procedure Update; override;
    procedure MouseDown(const Button, x, y: Integer); override;
    procedure MouseUp(const Button, x, y: Integer); override;
    procedure Scroll(const y: Integer); override;
  end;
//TOverlayAssetSelect END

//TOverlayDropList BEGIN
  TOverlayDropList = class (TOverlayObject)
  private
    var _ItemHeight: TG2Float;
  public
    var Frame: TG2Rect;
    var Items: TG2QuickListString;
    var ScrollV: TScrollBox;
    var Scrolling: Boolean;
    var OnChange: TG2ProcIntObj;
    procedure Initialize(const OwnerFrame: TG2Rect);
    procedure Render; override;
    procedure Update; override;
    procedure MouseDown(const Button, x, y: Integer); override;
    procedure MouseUp(const Button, x, y: Integer); override;
    procedure Scroll(const y: Integer); override;
  end;
//TOverlayDropList END

//TOverlayDrop BEGIN
  TOverlayDrop = class (TOverlayObject)
  private
    var _Name: String;
    var _Icon: TG2Texture2D;
    var _CurWorkspace: TUIWorkspace;
    var _CanDrop: Boolean;
  public
    property Name: String read _Name write _Name;
    property Icon: TG2Texture2D read _Icon write _Icon;
    procedure Initialzie; virtual;
    procedure Render; override;
    procedure Update; override;
    procedure MouseUp(const Button, x, y: Integer); override;
  end;
//TOverlayDrop END

//TOverlayDropScene2DStructureItem BEGIN
  TOverlayDropScene2DStructureItem = class (TOverlayDrop)
  public
  end;
//TOverlayDropScene2DStructureItem END

//THint BEGIN
  THint = object
  public
    Pos: TG2Vec2;
    Alpha: Single;
  end;
//THint END

//TUndoItem BEGIN
  TUndoItem = record
    UndoProc: TG2ProcPtrObj;
    UndoInfo: Pointer;
    UndoSize: Integer;
    RedoProc: TG2ProcPtrObj;
    RedoInfo: Pointer;
    RedoSize: Integer;
  end;
  PUndoItem = ^TUndoItem;
//TUndoItem END

//TUndoQueue BEGIN
  TUndoQueue = object
  private
    _Queue: array[0..63] of TUndoItem;
    _CurItem: Integer;
    _QueueStart: Integer;
    _QueueEnd: Integer;
    procedure Clear(const Start, Finish: Integer);
  public
    procedure Initialize;
    procedure Finalize;
    procedure Add(
      UndoProc: TG2ProcPtrObj;
      UndoInfo: Pointer;
      UndoSize: Integer;
      RedoProc: TG2ProcPtrObj;
      RedoInfo: Pointer;
      RedoSize: Integer
    );
    procedure Undo;
    procedure Redo;
    function CanUndo: Boolean; inline;
    function CanRedo: Boolean; inline;
  end;
//TUndoQueue END

//TCodeUndoAction BEGIN
  TCodeUndoAction = record
    CursorStart: TPoint;
    CursorEnd: TPoint;
    StrLength: Integer;
  end;
  PCodeUndoAction = ^TCodeUndoAction;
//TCodeUndoAction END

//TCodeUndoAction BEGIN
  TCodeUndoActionMultiline = record
    LineStart, LineEnd: Integer;
  end;
  PCodeUndoActionMultiline = ^TCodeUndoActionMultiline;
//TCodeUndoAction END

//TCodeFile BEGIN
  TCodeFile = object
  private
    var _Modified: Boolean;
    procedure SetModified(const Value: Boolean);
  public
    FileName: String;
    FilePath: String;
    Lines: TG2StrArrA;
    TextPos: TG2Vec2;
    Undo: TUndoQueue;
    property Modified: Boolean read _Modified write SetModified;
    function IsSaved: Boolean;
    function GetCaption: AnsiString;
    function GetCode: AnsiString;
    procedure SetCode(const Code: AnsiString);
    procedure Reset;
    procedure Initialize;
    procedure Finalize;
    procedure AddLine(const Line: AnsiString);
    procedure AddUndoActionInsert(
      const UndoCursorStart, UndoCursorEnd: TPoint;
      const UndoString: AnsiString;
      const RedoCursorStart, RedoCursorEnd: TPoint;
      const RedoString: AnsiString
    );
    procedure AddUndoActionComment(
      const LineStart, LineEnd: Integer
    );
    procedure AddUndoActionUnComment(
      const LineStart, LineEnd: Integer
    );
    procedure AddUndoActionIndent(
      const LineStart, LineEnd: Integer
    );
    procedure AddUndoActionUnIndent(
      const LineStart, LineEnd: Integer
    );
    procedure Save(const f: String);
    procedure Load(const f: String);
  end;
  PCodeFile = ^TCodeFile;
  TCodeFileList = specialize TG2QuickListG<PCodeFile>;
//TCodeFile END

//TCodeHighlight BEGIN
  TCodeHighlight = class
  private
    var _Parser: TG2Parser;
    var _ColorKernel: array of array of TG2Color;
    var _ColorText: TG2Color;
    var _ColorComment: TG2Color;
    var _ColorString: TG2Color;
    var _ColorKeyword: TG2Color;
    var _ColorSymbol: TG2Color;
    function GetColor(const x, y: Integer): TG2Color; inline;
  protected
    property Parser: TG2Parser read _Parser;
    property ColorText: TG2Color read _ColorText write _ColorText;
    property ColorComment: TG2Color read _ColorComment write _ColorComment;
    property ColorString: TG2Color read _ColorString write _ColorString;
    property ColorKeyword: TG2Color read _ColorKeyword write _ColorKeyword;
    property ColorSymbol: TG2Color read _ColorSymbol write _ColorSymbol;
  public
    property Color[const x, y: Integer]: TG2Color read GetColor;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Scan(const CodeFile: PCodeFile; const LineStart, LineEnd: Integer); virtual;
  end;
//TCodeHighlight END

//TCodeHighlightPascal BEGIN
  TCodeHighlightPascal = class (TCodeHighlight)
  public
    constructor Create; override;
    procedure Scan(const CodeFile: PCodeFile; const LineStart, LineEnd: Integer); override;
  end;
//TCodeHighlightPascal END

//TCodeHighlightG2ML BEGIN
  TCodeHighlightG2ML = class (TCodeHighlight)
  public
    constructor Create; override;
    procedure Scan(const CodeFile: PCodeFile; const LineStart, LineEnd: Integer); override;
  end;
//TCodeHighlightG2ML END

//TPropertySet BEGIN
  PPropertySet = ^TPropertySet;
  TPropertySet = class
  public
    type TProperty = class;
    type TQuickListProperty = specialize TG2QuickListG<TProperty>;
    type PQuickListProperty = ^TQuickListProperty;
    type TPropertyType = (
      pt_none,
      pt_path,
      pt_button,
      pt_bool,
      pt_int,
      pt_float,
      pt_string,
      pt_vec2,
      pt_vec3,
      pt_enum,
      pt_blend_mode,
      pt_component
    );
    type TProperty = class
    private
      function GetChildren: PQuickListProperty; inline;
    protected
      var _PropertyType: TPropertyType;
      var _OnChangeProc: TG2ProcPtrObj;
      var _Name: String;
      var _Open: Boolean;
      var _Children: TQuickListProperty;
    public
      property PropertyType: TPropertyType read _PropertyType;
      property OnChange: TG2ProcPtrObj read _OnChangeProc write _OnChangeProc;
      property Name: String read _Name write _Name;
      property Open: Boolean read _Open write _Open;
      property Children: PQuickListProperty read GetChildren;
      constructor Create; virtual;
      destructor Destroy; override;
      procedure Clear;
    end;
    type TPropertyPath = class (TProperty)
    protected
      var _AssetClass: CAsset;
      var _ValuePtr: PString;
    public
      property AssetClass: CAsset read _AssetClass write _AssetClass;
      property ValuePtr: PString read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyButton = class (TProperty)
    protected
      var _Proc: TG2ProcObj;
    public
      property Proc: TG2ProcObj read _Proc write _Proc;
      constructor Create; override;
    end;
    type TPropertyBool = class (TProperty)
    protected
      var _ValuePtr: PG2Bool;
    public
      property ValuePtr: PG2Bool read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyInt = class (TProperty)
    protected
      var _ValuePtr: PG2IntS32;
    public
      property ValuePtr: PG2IntS32 read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyFloat = class (TProperty)
    protected
      var _ValuePtr: PG2Float;
    public
      property ValuePtr: PG2Float read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyString = class (TProperty)
    protected
      var _ValuePtr: PString;
      var _Editable: Boolean;
      var _AllowEmpty: Boolean;
    public
      property ValuePtr: PString read _ValuePtr write _ValuePtr;
      property Editable: Boolean read _Editable write _Editable;
      property AllowEmpty: Boolean read _AllowEmpty write _AllowEmpty;
      constructor Create; override;
    end;
    type TPropertyVec2 = class (TProperty)
    protected
      var _ValuePtr: PG2Vec2;
      procedure ComponentChangeProc(const Ptr: Pointer);
    public
      property ValuePtr: PG2Vec2 read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyVec3 = class (TProperty)
    protected
      var _ValuePtr: PG2Vec3;
      procedure ComponentChangeProc(const Ptr: Pointer);
    public
      property ValuePtr: PG2Vec3 read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyEnum = class (TProperty)
    public
      type TValueType = record
        Name: String;
        Value: Byte;
      end;
    private
      function GetValueCount: Integer; inline;
      function GetValue(const Index: Integer): TValueType; inline;
    protected
      var _ValuePtr: Pointer;
      var _Values: array of TValueType;
      var _Selection: Integer;
    public
      property ValuePtr: Pointer read _ValuePtr write _ValuePtr;
      property ValueCount: Integer read GetValueCount;
      property Values[const Index: Integer]: TValueType read GetValue; default;
      property Selection: Integer read _Selection write _Selection;
      constructor Create; override;
      procedure AddValue(const ValueName: String; const Value: Byte);
      procedure SetValue(const Value: Byte);
      procedure Clear;
    end;
    type TPropertyBlendMode = class (TProperty)
    protected
      var _ValuePtr: PG2BlendMode;
      procedure ComponentChangeProc(const Ptr: Pointer);
    public
      property ValuePtr: PG2BlendMode read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
    type TPropertyComponent = class (TProperty)
    protected
      var _ValuePtr: TG2Scene2DComponent;
    public
      property ValuePtr: TG2Scene2DComponent read _ValuePtr write _ValuePtr;
      constructor Create; override;
    end;
  private
    var _Root: TProperty;
  public
    property Root: TProperty read _Root;
    constructor Create;
    destructor Destroy; override;
    function PropGroup(
      const Name: String;
      const Parent: TProperty = nil
    ): TProperty;
    function PropPath(
      const Name: String;
      const ValuePtr: PString;
      const AssetClass: CAsset;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyPath;
    function PropButton(
      const Name: String;
      const OnClick: TG2ProcObj;
      const Parent: TProperty = nil
    ): TPropertyButton;
    function PropBool(
      const Name: String;
      const ValuePtr: PG2Bool;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyBool;
    function PropInt(
      const Name: String;
      const ValuePtr: PG2IntS32;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyInt;
    function PropFloat(
      const Name: String;
      const ValuePtr: PG2Float;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyFloat;
    function PropString(
      const Name: String;
      const ValuePtr: PString;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyString;
    function PropVec2(
      const Name: String;
      const ValuePtr: PG2Vec2;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyVec2;
    function PropVec3(
      const Name: String;
      const ValuePtr: PG2Vec3;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyVec3;
    function PropEnum(
      const Name: String;
      const ValuePtr: Pointer;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyEnum;
    function PropBlendMode(
      const Name: String;
      const ValuePtr: PG2BlendMode;
      const Parent: TProperty = nil;
      const OnChangeProc: TG2ProcPtrObj = nil
    ): TPropertyBlendMode;
    function PropComponent(
      const Name: String;
      const Component: TG2Scene2DComponent;
      const Parent: TProperty = nil
    ): TPropertyComponent;
    procedure Clear;
  end;
//TPropertySet END

//TSpinner BEGIN
  TSpinner = object
  private
    var _Frame: TG2Rect;
    var _Spinning: Boolean;
    var _SpinPos: Integer;
    var _Value: Integer;
    var _OnSpinProc: TG2ProcIntObj;
  public
    property Frame: TG2Rect read _Frame write _Frame;
    property OnSpinProc: TG2ProcIntObj read _OnSpinProc write _OnSpinProc;
    procedure Initialize;
    procedure Render;
    procedure Update;
    procedure MouseDown(const Button, x, y: Integer);
    procedure MouseUp(const Button, x, y: Integer);
    procedure Scroll(const Amount: Integer);
  end;
//TSpinner END

  TUIWorkspaceInsertPosition = (
    ipNone, ipLeft, ipTop, ipRight, ipBottom, ipMiddle
  );

//TUIWorkspace BEGIN
  TUIWorkspace = class
  private
    var _Frame: TG2Rect;
    var _HeaderFrame: TG2Rect;
    var _Parent: TUIWorkspace;
    var _Children: array of TUIWorkspace;
    var _CustomHeader: Boolean;
    function GetChildCount: Integer; inline;
    function GetChild(const Index: Integer): TUIWorkspace; inline;
    procedure SetChild(const Index: Integer; const Value: TUIWorkspace); inline;
    procedure SetParent(const NewParent: TUIWorkspace);
    procedure SetFrame(const NewFrame: TG2Rect); inline;
    function GetFocused: Boolean; inline;
  protected
    property CustomHeader: Boolean read _CustomHeader write _CustomHeader;
    property HeaderFrame: TG2Rect read _HeaderFrame write _HeaderFrame;
    procedure OnInitialize; virtual;
    procedure OnFinalize; virtual;
    procedure OnBeforeFinalize; virtual;
    procedure OnAdjust; virtual;
    procedure OnUpdate; virtual;
    procedure OnRender; virtual;
    procedure OnMouseDown(const Button, x, y: Integer); virtual;
    procedure OnMouseUp(const Button, x, y: Integer); virtual;
    procedure OnKeyDown(const Key: Integer); virtual;
    procedure OnKeyUp(const Key: Integer); virtual;
    procedure OnScroll(const y: Integer); virtual;
    procedure OnChildAdd(const Child: TUIWorkspace); virtual;
    procedure OnChildRemove(const Child: TUIWorkspace); virtual;
    procedure OnTabInsert(const TabParent: TUIWorkspaceFrame); virtual;
    procedure OnHeaderRender; virtual;
    procedure OnHeaderMouseDown(const Button, x, y: Integer); virtual;
    procedure OnHeaderMouseUp(const Button, x, y: Integer); virtual;
    procedure OnDragDropBegin(const Drop: TOverlayDrop); virtual;
    procedure OnDragDropEnd(const Drop: TOverlayDrop); virtual;
    procedure OnDragDropRelase(const Drop: TOverlayDrop); virtual;
  public
    class var Focus: TUIWorkspace;
    class function GetWorkspaceName: AnsiString; virtual;
    class function GetWorkspacePath: AnsiString; virtual;
    property Focused: Boolean read GetFocused;
    property Parent: TUIWorkspace read _Parent write SetParent;
    property Frame: TG2Rect read _Frame write SetFrame;
    property ChildCount: Integer read GetChildCount;
    property Children[const Index: Integer]: TUIWorkspace read GetChild write SetChild;
    procedure ChildAdd(const Child: TUIWorkspace);
    procedure ChildRemove(const Child: TUIWorkspace);
    procedure ChildReplace(const ChildOld, ChildNew: TUIWorkspace);
    procedure ChildReposition(const OldChildIndex, NewChildIndex: Integer);
    procedure Update; virtual;
    procedure Render; virtual;
    procedure MouseDown(const Button, x, y: Integer); virtual;
    procedure MouseUp(const Button, x, y: Integer); virtual;
    procedure KeyDown(const Key: Integer); virtual;
    procedure KeyUp(const Key: Integer); virtual;
    procedure Scroll(const y: Integer); virtual;
    function GetMinWidth: Single; virtual;
    function GetMinHeight: Single; virtual;
    function CanDragDrop(const Drop: TOverlayDrop): Boolean; virtual;
    class constructor CreateClass;
    constructor Create;
    destructor Destroy; override;
  end;
//TUIWorkspace END

//TUIWorkspaceSplitter BEGIN
  TUIWorkspaceSplitter = class (TUIWorkspace)
  private
    type TOrientation = (soNone, soVertical, soHorizontal);
    var _Orientation: TOrientation;
    var _SplitPos: Single;
    var _Resizing: Boolean;
    procedure SetOrientation(const Value: TOrientation);
    procedure SetSplitPos(const Value: Single);
    function GetSplitRect: TG2Rect;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnUpdate; override;
    procedure OnAdjust; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnChildAdd(const Child: TUIWorkspace); override;
    procedure OnChildRemove(const Child: TUIWorkspace); override;
  public
    property Orientation: TOrientation read _Orientation write SetOrientation;
    property SplitPos: Single read _SplitPos write SetSplitPos;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceSplitter END

//TUIWorkspaceFrame BEGIN
  TUIWorkspaceFrame = class (TUIWorkspace)
  private
    var _ChildIndex: Integer;
    var _ClientFrame: TG2Rect;
    var _Padding: Single;
    var _BorderSize: Single;
    var _HeaderHeight: Single;
    var _FootterSize: Single;
    var _TextSpacing: Single;
    var _Dragging: Boolean;
    procedure SetChildIndex(const Value: Integer);
    function PointInChild(const x, y: Single; var ChildFrame: TG2Rect): Integer; overload;
    function PointInChild(const x, y: Single): Integer; overload;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnUpdate; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnChildAdd(const Child: TUIWorkspace); override;
    procedure OnChildRemove(const Child: TUIWorkspace); override;
    function PtInClose(const x, y: Integer): Boolean;
    function PtInDrag(const x, y: Integer): Boolean;
  public
    property ChildIndex: Integer read _ChildIndex write SetChildIndex;
    procedure Update; override;
    procedure Render; override;
    procedure MouseDown(const Button, x, y: Integer); override;
    procedure MouseUp(const Button, x, y: Integer); override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    function GetInsertPositon(const x, y: Single): TUIWorkspaceInsertPosition;
    function CanInsert(const Workspace: TUIWorkspace; const InsertPosition: TUIWorkspaceInsertPosition): Boolean;
  end;
//TUIWorkspaceFrame END

//TUIWorkspaceEmpty BEGIN
  TUIWorkspaceEmpty = class (TUIWorkspace)
  protected
    procedure OnRender; override;
  public
    class function GetWorkspaceName: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceEmpty END

//TUIWorkspaceLog BEGIN
  TUIWorkspaceLog = class (TUIWorkspace)
  private
    var _ScrollV: TSCrollBox;
    procedure OnSlide;
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    class function GetWorkspaceName: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceLog END

//TUIWorkspaceConsole BEGIN
  TUIWorkspaceConsole = class (TUIWorkspace)
  private
    var _TextPos: TG2Vec2;
    var _CommandHeight: Single;
    var _SeparatorHeight: Single;
    var _Command: AnsiString;
    var _ScrollV: TSCrollBox;
    procedure OnCommandUpdate;
    procedure OnCommandEnter;
    procedure OnCommandCursorMove;
    procedure OnSlide;
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    class function GetWorkspaceName: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceConsole END

//TUIWorkspaceCode BEGIN
  TUIWorkspaceCode = class (TUIWorkspace)
  private
    type TToolItem = record
      Icon: TG2Texture2D;
      OnClick: TG2ProcObj;
    end;
    type PToolItem = ^TToolItem;
    type TToolItemList = specialize TG2QuickListG<PToolItem>;
    var _ToolItemList: TToolItemList;
    var _LineNumberFrame: TG2Rect;
    var _CodeFrame: TG2Rect;
    var _Font: TG2Font;
    var _FontB: TG2Font;
    var _FontI: TG2Font;
    var _FontSize: TPoint;
    var _FileSpacing: Single;
    var _FileTabBorders: Single;
    var _FileIconSize: Single;
    var _FileIconCloseScale: Single;
    var _ToolItemsOffset: Single;
    var _ToolItemsSpacing: Single;
    var _ToolItemsSeparator: Single;
    var _TextOffset: Single;
    var _ScrollSize: Single;
    var _FileIndex: Integer;
    var _Files: TCodeFileList;
    var _TextPos: TG2Vec2;
    var _ScrollV: TScrollBox;
    var _ScrollH: TScrollBox;
    var _HighlightPascal: TCodeHighlightPascal;
    var _HighlightG2ML: TCodeHighlightG2ML;
    var _HighlightPlain: TCodeHighlight;
    var _Highlight: TCodeHighlight;
    var _HighlightRescan: Boolean;
    var _HighlightLineStart: Integer;
    var _HighlightLineEnd: Integer;
    var _Dragging: Boolean;
    procedure OnCodeChange;
    procedure OnCodeCursorMove;
    procedure OnTextPosChange;
    procedure OnSliderV;
    procedure OnSliderH;
    procedure OnMouseScroll(const y: Integer);
    procedure UpdateTextPos;
    procedure UpdateScrollBarV;
    procedure UpdateScrollBarH;
    procedure UpdateCodeFrames;
    function GetCodeFile(const Index: Integer): PCodeFile; inline;
    function GetCodeFileCount: Integer; inline;
    procedure SetFileIndex(const Value: Integer);
    function PtInFile(const x, y: Single; var InDrag, InClose: Boolean; var FileFrame: TG2Rect): Integer; overload;
    function PtInFile(const x, y: Single; var InDrag, InClose: Boolean): Integer; overload;
    function PtInFile(const x, y: Single; var FileFrame: TG2Rect): Integer; overload;
    function PtInFile(const x, y: Single): Integer; overload;
    procedure AddToolItem(const Icon: TG2Texture2D; const OnClick: TG2ProcObj = nil);
    procedure BtnDocEmpty;
    procedure BtnDocSave;
    procedure BtnDocLoad;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnTabInsert(const TabParent: TUIWorkspaceFrame); override;
    procedure OnHeaderRender; override;
    procedure OnHeaderMouseDown(const Button, x, y: Integer); override;
    procedure OnHeaderMouseUp(const Button, x, y: Integer); override;
  public
    property FileIndex: Integer read _FileIndex write SetFileIndex;
    property CodeFiles[const Index: Integer]: PCodeFile read GetCodeFile;
    property CodeFileCount: Integer read GetCodeFileCount;
    function NewCodeFile: PCodeFile;
    procedure AddCodeFile(const CodeFile: PCodeFile);
    procedure RemoveCodeFile(const CodeFile: PCodeFile);
    procedure SelectCodeFile(const CodeFile: PCodeFile);
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCode END

//TUIWorkspaceCodeBrowser BEGIN
  TUIWorkspaceCodeBrowser = class (TUIWorkspace)
  public type
    PNode = ^TNode;
    TNode = object
    private
      var _LastNode: PNode;
    public
      var Name: AnsiString;
      var LineInterface: Integer;
      var LineImplementation: Integer;
      var Children: TG2QuickList;
      var Open: Boolean;
      function AddNode(const NodeName: AnsiString): PNode;
      function LastNode: PNode;
    end;
  private
    var _Root: TNode;
    var _ParsedTime: TG2IntU32;
    var _NodesOffset: Single;
    var _CurFile: String;
    var _ScrollV: TSCrollBox;
    function GetContentHeight: Single;
    function PtInItem(const x, y: Single; var InExpand: Boolean; var InImplementation: Boolean): PNode;
    procedure ProcessFile(const FileSymbol: TCodeInsightSymbolFile);
    procedure OnSlide;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    procedure Clear;
  end;
//TUIWorkspaceCodeBrowser END

//TUIWorkspaceProjectBrowser BEGIN
  TUIWorkspaceProjectBrowser = class (TUIWorkspace)
  public type
    PNode = ^TNode;
    TNode = object
    private
      var _LastNode: PNode;
    public
      var Name: AnsiString;
      var Children: TG2QuickList;
      var IsDir: Boolean;
      var Open: Boolean;
      var Path: String;
      function AddNode(const NodeName: AnsiString; const NodeIsDir: Boolean): PNode;
      function LastNode: PNode;
    end;
  private
    var _Root: TNode;
    var _NodesOffset: Single;
    var _ScrollV: TSCrollBox;
    var _ProjectOpen: Boolean;
    var _RefreshCS: TG2CriticalSection;
    var _RefreshThread: TG2Thread;
    var _LastScan: TG2IntU32;
    function GetContentHeight: Single;
    function PtInItem(const x, y: Single; var InExpand: Boolean): PNode;
    procedure OnSlide;
    procedure Refresh;
    procedure Scan;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    class function GetWorkspaceName: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    procedure Clear;
  end;
//TUIWorkspaceProjectBrowser END

  TUIWorkspaceCustomSizing = (csFixed, csStretch);
  TUIWorkspaceCustomAlignment = (caLeft, caRight, caCenter, caTop, caBottom, caMiddle);
  TUIWorkspaceCustomAlignmentSet = set of TUIWorkspaceCustomAlignment;

//TUIWorkspaceCustomObject BEGIN
  TUIWorkspaceCustomObject = class (TUIWorkspace)
  private
    var _SizingH: TUIWorkspaceCustomSizing;
    var _SizingV: TUIWorkspaceCustomSizing;
    var _Width: Single;
    var _Height: Single;
    var _PaddingLeft: Single;
    var _PaddingTop: Single;
    var _PaddingRight: Single;
    var _PaddingBottom: Single;
  protected
    procedure OnInitialize; override;
  public
    class function GetWorkspaceName: AnsiString; override;
    property SizingH: TUIWorkspaceCustomSizing read _SizingH write _SizingH;
    property SizingV: TUIWorkspaceCustomSizing read _SizingV write _SizingV;
    property Width: Single read _Width write _Width;
    property Height: Single read _Height write _Height;
    property PaddingTop: Single read _PaddingTop write _PaddingTop;
    property PaddingLeft: Single read _PaddingLeft write _PaddingLeft;
    property PaddingRight: Single read _PaddingRight write _PaddingRight;
    property PaddingBottom: Single read _PaddingBottom write _PaddingBottom;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomObject END

//TUIWorkspaceFixedSplitterV BEGIN
  TUIWorkspaceFixedSplitterV = class (TUIWorkspaceCustomObject)
  private
    var _SplitPos: Single;
    function GetUpper: TUIWorkspaceCustom; inline;
    function GetLower: TUIWorkspaceCustom; inline;
    procedure SetSplitPos(const Value: Single); inline;
  protected
    procedure OnAdjust; override;
    procedure OnInitialize; override;
  public
    property SplitPos: Single read _SplitPos write SetSplitPos;
    property Upper: TUIWorkspaceCustom read GetUpper;
    property Lower: TUIWorkspaceCustom read GetLower;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceFixedSplitterV END

//TUIWorkspaceFixedSplitterH BEGIN
  TUIWorkspaceFixedSplitterH = class (TUIWorkspaceCustomObject)
  private
    var _SplitPos: Single;
    function GetLeft: TUIWorkspaceCustom; inline;
    function GetRight: TUIWorkspaceCustom; inline;
    procedure SetSplitPos(const Value: Single); inline;
  protected
    procedure OnAdjust; override;
    procedure OnInitialize; override;
  public
    property SplitPos: Single read _SplitPos write SetSplitPos;
    property Left: TUIWorkspaceCustom read GetLeft;
    property Right: TUIWorkspaceCustom read GetRight;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceFixedSplitterH END

//TUIWorkspaceFixedSplitterMulti BEGIN
  TUIWorkspaceFixedSplitterMulti = class (TUIWorkspaceCustomObject)
  private
    var _SplitRatio: Single;
    var _EqualSized: Boolean;
    var _SubsetCount: Integer;
    var _Subsets: array of TUIWorkspaceCustom;
    procedure SetSubsetCount(const Value: Integer); inline;
    function GetSubset(const Index: Integer): TUIWorkspaceCustom; inline;
  protected
    procedure OnAdjust; override;
    procedure OnInitialize; override;
  public
    property EqualSized: Boolean read _EqualSized write _EqualSized;
    property SubsetCount: Integer read _SubsetCount write SetSubsetCount;
    property Subset[const Index: Integer]: TUIWorkspaceCustom read GetSubset;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceFixedSplitterMulti END

//TUIWorkspaceCustomPanel BEGIN
  TUIWorkspaceCustomPanel = class (TUIWorkspaceCustomObject)
  private
    var _Visible: Boolean;
    procedure SetVisible(const Value: Boolean);
    function GetClient: TUIWorkspaceCustom; inline;
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
  public
    property Visible: Boolean read _Visible write SetVisible;
    property Client: TUIWorkspaceCustom read GetClient;
    procedure Render; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomPanel END

//TUIWorkspaceCustomGroup BEGIN
  TUIWorkspaceCustomGroup = class (TUIWorkspaceCustomObject)
  private
    function GetClient: TUIWorkspaceCustom; inline;
  protected
    var _Caption: AnsiString;
    var _HeaderSize: Single;
    var _BorderSize: Single;
    function GetClientFrame: TG2Rect;
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
  public
    property Caption: AnsiString read _Caption write _Caption;
    property Client: TUIWorkspaceCustom read GetClient;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomGroup END

//TUIWorkspaceCustomButton BEGIN
  TUIWorkspaceCustomButton = class (TUIWorkspaceCustomObject)
  private
    var _Caption: AnsiString;
    var _Hint: AnsiString;
    var _ShowHint: Single;
    var _Enabled: Boolean;
    var _Icon: TG2Texture2D;
    var _IconFilter: TG2Filter;
    var _ProcOnClick: TG2ProcObj;
    var _ProcOnClickSender: TG2ProcPtrObj;
    var _MdInButton: Boolean;
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Caption: AnsiString read _Caption write _Caption;
    property Hint: AnsiString read _Hint write _Hint;
    property Enabled: Boolean read _Enabled write _Enabled;
    property Icon: TG2Texture2D read _Icon write _Icon;
    property IconFilter: TG2Filter read _IconFilter write _IconFilter;
    property OnClick: TG2ProcObj read _ProcOnClick write _ProcOnClick;
    property OnClickSender: TG2ProcPtrObj read _ProcOnClickSender write _ProcOnClickSender;
    function GetMinWidth: Single; override;
  end;
//TUIWorkspaceCustomButton END

//TUIWorkspaceCustomLabel BEGIN
  TUIWorkspaceCustomLabel = class (TUIWorkspaceCustomObject)
  private
    var _Caption: AnsiString;
    var _Color: TG2Color;
    var _Align: TUIWorkspaceCustomAlignmentSet;
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
  public
    property Caption: AnsiString read _Caption write _Caption;
    property Color: TG2Color read _Color write _Color;
    property Align: TUIWorkspaceCustomAlignmentSet read _Align write _Align;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomLabel END

//TUIWorkspaceCustomEdit BEGIN
  TUIWorkspaceCustomEdit = class (TUIWorkspaceCustomObject)
  private
    var _Text: AnsiString;
    var _TextPos: TG2Vec2;
    var _OnFinishProc: TG2ProcObj;
    procedure OnTextCursorMove;
    procedure AdjustTextPos;
    procedure OnFinishEdit;
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Text: AnsiString read _Text write _Text;
    property OnFinishProc: TG2ProcObj read _OnFinishProc write _OnFinishProc;
  end;
//TUIWorkspaceCustomEdit END

//TUIWorkspaceCustomNumberInt BEGIN
  TUIWorkspaceCustomNumberInt = class (TUIWorkspaceCustomObject)
  private
    var _Text: AnsiString;
    var _TextPos: TG2Vec2;
    var _Number: Integer;
    var _NumberMin: Integer;
    var _NumberMax: Integer;
    var _Spinner: TSpinner;
    var _Increment: Integer;
    var _OnChangeProc: TG2ProcObj;
    procedure OnTextCursorMove;
    procedure OnTextChange;
    procedure SetNumber(const Value: Integer);
    procedure AdjustTextPos;
    procedure OnSpin(const Amount: Integer);
    procedure SetNumberMax(const Value: Integer);
    procedure SetNumberMin(const Value: Integer);
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnUpdate; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property NumberMin: Integer read _NumberMin write SetNumberMin;
    property NumberMax: Integer read _NumberMax write SetNumberMax;
    property Number: Integer read _Number write SetNumber;
    property Increment: Integer read _Increment write _Increment;
    property OnChange: TG2ProcObj read _OnChangeProc write _OnChangeProc;
  end;
//TUIWorkspaceCustomNumberInt END

//TUIWorkspaceCustomNumberFloat BEGIN
  TUIWorkspaceCustomNumberFloat = class (TUIWorkspaceCustomObject)
  private
    var _Text: AnsiString;
    var _TextPos: TG2Vec2;
    var _Number: TG2Float;
    var _NumberMin: TG2Float;
    var _NumberMax: TG2Float;
    var _Spinner: TSpinner;
    var _Increment: TG2Float;
    var _OnChangeProc: TG2ProcObj;
    procedure OnTextCursorMove;
    procedure OnTextChange;
    procedure SetNumber(const Value: TG2Float);
    procedure AdjustTextPos;
    procedure OnSpin(const Amount: Integer);
    procedure SetNumberMax(const Value: TG2Float);
    procedure SetNumberMin(const Value: TG2Float);
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnUpdate; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property NumberMin: TG2Float read _NumberMin write SetNumberMin;
    property NumberMax: TG2Float read _NumberMax write SetNumberMax;
    property Number: TG2Float read _Number write SetNumber;
    property Increment: TG2Float read _Increment write _Increment;
    property OnChange: TG2ProcObj read _OnChangeProc write _OnChangeProc;
  end;
//TUIWorkspaceCustomNumberFloat END

//TUIWorkspaceCustomSlider BEGIN
  TUIWorkspaceCustomSlider = class (TUIWorkspaceCustomObject)
  private
    var _Drag: Boolean;
    var _DragOffset: TG2Float;
    var _SliderSize: TG2Float;
    var _Position: TG2Float;
    var _OnChange: TG2ProcObj;
    procedure SetPosition(const Value: TG2Float);
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Position: TG2Float read _Position write SetPosition;
    property OnChange: TG2ProcObj read _OnChange write _OnChange;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomSlider END

//TUIWorkspaceCustomFile BEGIN
  TUIWorkspaceCustomFile = class (TUIWorkspaceCustomObject)
  private
    var _FileName: AnsiString;
    var _FilePath: AnsiString;
    var _OnSelect: TG2ProcObj;
    var _ShowHint: Single;
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property FileName: AnsiString read _FileName write _FileName;
    property FilePath: AnsiString read _FilePath write _FilePath;
    property OnSelect: TG2ProcObj read _OnSelect write _OnSelect;
  end;
//TUIWorkspaceCustomFile END

//TUIWorkspaceCustomColor BEGIN
  TUIWorkspaceCustomColor = class (TUIWorkspaceCustomObject)
  private
    var _Color: TG2Color;
    var _OnSelect: TG2ProcObj;
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Color: TG2Color read _Color write _Color;
    property OnSelect: TG2ProcObj read _OnSelect write _OnSelect;
  end;
//TUIWorkspaceCustomColor END

//TUIWorkspaceCustomComboBox BEGIN
  TUIWorkspaceCustomComboBox = class (TUIWorkspaceCustomObject)
  private
    type TOverlayWorkspaceList = class (TOverlayObject)
    public
      var ComboBox: TUIWorkspaceCustomComboBox;
      var Frame: TG2Rect;
      var Items: TG2QuickListIntS32;
      var ScrollV: TScrollBox;
      var Scrolling: Boolean;
      procedure Initialize;
      procedure Render; override;
      procedure Update; override;
      procedure MouseDown(const Button, x, y: Integer); override;
      procedure MouseUp(const Button, x, y: Integer); override;
      procedure Scroll(const y: Integer); override;
    end;
    var _Overlay: TOverlayWorkspaceList;
    var _Items: TG2QuickListAnsiString;
    var _ItemIndex: Integer;
    var _OnChange: TG2ProcIntObj;
    function GetItem(const Index: Integer): AnsiString;
    procedure SetItem(const Index: Integer; const Value: AnsiString);
    function GetItemCount: Integer;
    procedure SetItemIndex(const Value: Integer);
    function GetText: AnsiString;
    procedure SetText(const Value: AnsiString);
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Items[const Index: Integer]: AnsiString read GetItem write SetItem;
    property ItemCount: Integer read GetItemCount;
    property ItemIndex: Integer read _ItemIndex write SetItemIndex;
    property Text: AnsiString read GetText write SetText;
    property OnChange: TG2ProcIntObj read _OnChange write _OnChange;
    procedure Clear;
    procedure Add(const Item: AnsiString);
  end;
//TUIWorkspaceCustomComboBox END

//TUIWorkspaceCustomCheckbox BEGIN
  TUIWorkspaceCustomCheckbox = class (TUIWorkspaceCustomObject)
  private
    var _Checked: Boolean;
    var _Caption: AnsiString;
    var _OnChange: TG2ProcObj;
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Checked: Boolean read _Checked write _Checked;
    property Caption: AnsiString read _Caption write _Caption;
    property OnChange: TG2ProcObj read _OnChange write _OnChange;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomCheckbox END

//TUIWorkspaceCustomRadio BEGIN
  TUIWorkspaceCustomRadio = class (TUIWorkspaceCustomObject)
  private
    var _Checked: Boolean;
    var _Caption: AnsiString;
    var _Group: Integer;
    procedure SetChecked(const Value: Boolean);
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Checked: Boolean read _Checked write SetChecked;
    property Caption: AnsiString read _Caption write _Caption;
    property Group: Integer read _Group write _Group;
  end;
//TUIWorkspaceCustomRadio END

//TUIWorkspaceCustomPages BEGIN
  TUIWorkspaceCustomPages = class (TUIWorkspaceCustomObject)
  private
    var _PageIndex: Integer;
    function GetPage(const Index: Integer): TUIWorkspaceCustom; inline;
    procedure SetPageIndex(const Value: Integer);
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
  public
    property PageIndex: Integer read _PageIndex write SetPageIndex;
    property Pages[const Index: Integer]: TUIWorkspaceCustom read GetPage;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    procedure Update; override;
    procedure Render; override;
    procedure MouseDown(const Button, x, y: Integer); override;
    procedure MouseUp(const Button, x, y: Integer); override;
    function AddPage: TUIWorkspaceCustom;
  end;
//TUIWorkspaceCustomPages END

//TUIWorkspaceCustomGraph BEGIN
  TUIWorkspaceCustomGraph = class (TUIWorkspaceCustomObject)
  private
    var _RullerSize: TG2Float;
    var _FrameRullerTop: TG2Rect;
    var _FrameRullerLeft: TG2Rect;
    var _FrameGraph: TG2Rect;
    var _ScaleXMin: TG2Float;
    var _ScaleXMax: TG2Float;
    var _ScaleYMin: TG2Float;
    var _ScaleYMax: TG2Float;
    var _Points: TG2QuickListVec2;
    var _EditPoint: Integer;
    function GetScaleX: TG2Float; inline;
    function GetScaleY: TG2Float; inline;
    function PointToScreen(const v: TG2Vec2): TG2Vec2;
    function PointToGraph(const v: TG2Vec2): TG2Vec2;
    function PtInPoint(const v: TG2Vec2): Integer;
    function GetPoint(const Index: Integer): TG2Vec2; inline;
    procedure SetPoint(const Index: Integer; const Value: TG2Vec2); inline;
    function GetPointCount: Integer; inline;
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnUpdate; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Points[const Index: Integer]: TG2Vec2 read GetPoint write SetPoint;
    property PointCount: Integer read GetPointCount;
    property ScaleX: TG2Float read GetScaleX;
    property ScaleY: TG2Float read GetScaleY;
    property ScaleXMin: TG2Float read _ScaleXMin write _ScaleXMin;
    property ScaleXMax: TG2Float read _ScaleXMax write _ScaleXMax;
    property ScaleYMin: TG2Float read _ScaleYMin write _ScaleYMin;
    property ScaleYMax: TG2Float read _ScaleYMax write _ScaleYMax;
    procedure Clear;
    function GetYAt(const x: TG2Float): TG2Float;
    function AddPoint(const v: TG2Vec2): Integer;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    procedure WriteG2ML(const g2ml: TG2MLWriter);
  end;
//TUIWorkspaceCustomGraph END

//TUIWorkspaceCustomColorGraph BEGIN
  TUIWorkspaceCustomColorGraph = class (TUIWorkspaceCustomObject)
  public
    type TSectionColor = record
      Time: TG2Float;
      Color: TG2Color;
    end;
    PSectionColor = ^TSectionColor;
  private
    var _Colors: TG2QuickList;
    var _SliderSize: TG2Float;
    var _Selection: PSectionColor;
    var _LastSelection: PSectionColor;
    var _LastSelectionTime: TG2IntU32;
    var _MdOffset: TG2Float;
    function GetColor(const Index: Integer): PSectionColor; inline;
    function GetColorCount: Integer; inline;
    procedure InsertColor(const c: PSectionColor);
    function PtInColor(const v: TG2Vec2): PSectionColor;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnUpdate; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Colors[const Index: Integer]: PSectionColor read GetColor;
    property ColorCount: Integer read GetColorCount;
    procedure Clear;
    procedure AddColor(const Color: TG2Color; const Time: TG2Float);
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceCustomColorGraph END

//TUIWorkspaceCustom BEGIN
  TUIWorkspaceCustom = class (TUIWorkspace)
  private
    var _Alignment: TUIWorkspaceCustomAlignmentSet;
    var _SpacingLeft: Single;
    var _SpacingTop: Single;
    var _SpacingRight: Single;
    var _SpacingBottom: Single;
    var _ScrollV: TSCrollBox;
    var _Scrollable: Boolean;
    procedure SetAlignment(const Value: TUIWorkspaceCustomAlignmentSet); inline;
    procedure SetScrollable(const Value: Boolean);
    procedure SetSpacingBottom(const Value: Single);
    procedure SetSpacingLeft(const Value: Single);
    procedure SetSpacingRight(const Value: Single);
    procedure SetSpacingTop(const Value: Single);
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
    procedure OnSlide;
  public
    class function GetWorkspaceName: AnsiString; override;
    property Alignemnt: TUIWorkspaceCustomAlignmentSet read _Alignment write SetAlignment;
    property Scrollable: Boolean read _Scrollable write SetScrollable;
    property SpacingLeft: Single read _SpacingLeft write SetSpacingLeft;
    property SpacingTop: Single read _SpacingTop write SetSpacingTop;
    property SpacingRight: Single read _SpacingRight write SetSpacingRight;
    property SpacingBottom: Single read _SpacingBottom write SetSpacingBottom;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    function SplitterV(const Ratio: Single = 0.5): TUIWorkspaceFixedSplitterV;
    function SplitterH(const Ratio: Single = 0.5): TUIWorkspaceFixedSplitterH;
    function SplitterM(const Count: Integer): TUIWorkspaceFixedSplitterMulti;
    function Panel: TUIWorkspaceCustomPanel;
    function Text(const Caption: AnsiString = 'Label'): TUIWorkspaceCustomLabel;
    function Button(const Caption: AnsiString = 'Button'): TUIWorkspaceCustomButton;
    function Edit: TUIWorkspaceCustomEdit;
    function NumberInt: TUIWorkspaceCustomNumberInt;
    function NumberFloat: TUIWorkspaceCustomNumberFloat;
    function FileDialog: TUIWorkspaceCustomFile;
    function ColorDialog: TUIWorkspaceCustomColor;
    function ComboBox: TUIWorkspaceCustomComboBox;
    function CheckBox(const Caption: AnsiString = 'CheckBox'): TUIWorkspaceCustomCheckbox;
    function Radio(const Caption: AnsiString = 'Radio'): TUIWorkspaceCustomRadio;
    function Pages: TUIWorkspaceCustomPages;
    function Group(const Caption: AnsiString = 'Group'): TUIWorkspaceCustomGroup;
    function Slider: TUIWorkspaceCustomSlider;
    procedure SetSpacing(const Spacing: Single);
  end;
//TUIWorkspaceCustom END

//TUIWorkspaceCustomTest BEGIN
  TUIWorkspaceCustomTest = class (TUIWorkspaceCustom)
  private
    var _Pages: TUIWorkspaceCustomPages;
    procedure OnSetPage0;
    procedure OnSetPage1;
  protected
    procedure OnInitialize; override;
  public
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class function GetWorkspaceName: AnsiString; override;
  end;
//TUIWorkspaceCustomTest END

//TUIWorkspaceProject BEGIN
  TUIWorkspaceProject = class (TUIWorkspaceCustom)
  private
    _BtnNew: TUIWorkspaceCustomButton;
    _BtnLoad: TUIWorkspaceCustomButton;
    _BtnClose: TUIWorkspaceCustomButton;
    _BtnBuild: TUIWorkspaceCustomButton;
    _BtnBuildHTML5: TUIWorkspaceCustomButton;
    _BtnLpr: TUIWorkspaceCustomButton;
    _Options: TUIWorkspaceCustomPages;
    _OptEmpty: TUIWorkspaceCustom;
    _OptBuild: TUIWorkspaceCustom;
    _LabelProjectPath: TUIWorkspaceCustomLabel;
    procedure OnBtnNew;
    procedure OnBtnLoad;
    procedure OnBtnClose;
    procedure OnBtnBuild;
    procedure OnBtnBuildHTML5;
    procedure OnBtnLpr;
  protected
    procedure OnInitialize; override;
    procedure OnUpdate; override;
  public
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class function GetWorkspaceName: AnsiString; override;
  end;
//TUIWorkspaceProject END

//TUIWorkspaceSettings BEGIN
  TUIWorkspaceSettings = class (TUIWorkspaceCustom)
  private
    procedure OnBtnSaveDefaultLayout;
    procedure OnBtnLoadDefaultLayout;
    procedure OnBtnSaveLayout;
    procedure OnBtnLoadLayout;
  protected
    procedure OnInitialize; override;
    procedure OnUpdate; override;
  public
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class function GetWorkspaceName: AnsiString; override;
  end;
//TUIWorkspaceSettings END

//TUIWorkspaceProperties BEGIN
  TUIWorkspaceProperties = class (TUIWorkspace)
  private
    var _OverlayDropList: TOverlayDropList;
    var _EditProperty: TPropertySet.TProperty;
    var _TextPos: TG2Vec2;
    var _EditText: String;
    var _AdjustingSplitter: Boolean;
    var _Splitter: TG2Float;
    var _PropertySetPtr: PPropertySet;
    var _AdjustSplitterPropertySet: set of TPropertySet.TPropertyType;
    var _ScrollV: TSCrollBox;
    var _ItemsHeight: Integer;
    procedure OnEditFinish;
    procedure OnPathSelect(const Path: String);
    procedure OnEnumChage(const Index: Integer);
    procedure RenderPath(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyPath
    );
    procedure RenderButton(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyButton
    );
    procedure RenderGroup(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TProperty
    );
    procedure RenderBool(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyBool
    );
    procedure RenderInt(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyInt
    );
    procedure RenderFloat(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyFloat
    );
    procedure RenderString(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyString
    );
    procedure RenderVec2(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyVec2
    );
    procedure RenderVec3(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyVec3
    );
    procedure RenderEnum(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyEnum
    );
    procedure RenderBlendMode(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyBlendMode
    );
    procedure RenderComponent(
      const r: TG2Rect;
      const Offset: Integer;
      const Prop: TPropertySet.TPropertyComponent
    );
    function PtInProperty(const x, y: Integer; var InExpand, InEdit: Boolean; var PropertyRect: TG2Rect): TPropertySet.TProperty;
    function GetContentSize: TG2Float;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnUpdate; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    property PropertySetPtr: PPropertySet read _PropertySetPtr write _PropertySetPtr;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class function GetWorkspaceName: AnsiString; override;
  end;
//TUIWorkspaceProperties END

//TUIWorkspaceAtlasPacker BEGIN
  TUIWorkspaceAtlasPacker = class (TUIWorkspace)
  private
    type TListImage = class
    public
      var Texture: TG2Texture2D;
      var Name: String;
      var FileName: String;
      var AliasImage: TListImage;
      var FileMD5: TG2MD5;
    end;
    type TQuickListImage = specialize TG2QuickListG<TListImage>;
    type PQuickListImage = ^TQuickListImage;
    type TListFolder = class
    public
      var Path: String;
      var Images: TQuickListImage;
    end;
    type TQuickListFolder = specialize TG2QuickListG<TListFolder>;
    type PQuickListFolder = ^TQuickListFolder;
    type TAtlasFrame = class
    public
      var FilePath: String;
      var FileName: String;
      var Image: TListImage;
      var PosX: Integer;
      var PosY: Integer;
      var Width: Integer;
      var Height: Integer;
      var Page: Pointer;
    end;
    type TAtlasFrameList = specialize TG2QuickListG<TAtlasFrame>;
    type TAtlasPage = class
    public
      var TextureRT: TG2Texture2DRT;
      var Rendered: Boolean;
      var Width: Integer;
      var Height: Integer;
      var TextureWidth: Integer;
      var TextureHeight: Integer;
      var Frames: TAtlasFrameList;
    end;
    type TAtlasPageList = specialize TG2QuickListG<TAtlasPage>;
    type TAtlas = class
    public
      var Pages: TAtlasPageList;
    end;
    type TWorkspaceImageListToolbar = class (TUIWorkspaceCustom)
    protected
      procedure OnInitialize; override;
    public
      var BtnAddImages: TUIWorkspaceCustomButton;
      var BtnAddFolder: TUIWorkspaceCustomButton;
      var BtnExport: TUIWorkspaceCustomButton;
      var BtnClear: TUIWorkspaceCustomButton;
      var BtnSave: TUIWorkspaceCustomButton;
      var BtnLoad: TUIWorkspaceCustomButton;
      class function GetWorkspaceName: AnsiString; override;
    end;
    type TWorkspaceImageList = class (TUIWorkspace)
    private
      var _ItemSize: Single;
      var _ItemSpacing: Single;
      var _ScrollV: TSCrollBox;
      var _CloseButtonSize: Single;
      procedure OnSlide;
      function GetContentSize: Single;
      function PtInItem(const x, y: Single; var InClose: Boolean): Integer;
      procedure DeleteItem(const ItemIndex: Integer);
    protected
      procedure OnInitialize; override;
      procedure OnAdjust; override;
      procedure OnRender; override;
      procedure OnUpdate; override;
      procedure OnMouseDown(const Button, x, y: Integer); override;
      procedure OnMouseUp(const Button, x, y: Integer); override;
      procedure OnScroll(const y: Integer); override;
    public
      var Images: PQuickListImage;
      var Folders: PQuickListFolder;
      class function GetWorkspaceName: AnsiString; override;
      function GetMinWidth: Single; override;
      function GetMinHeight: Single; override;
    end;
    type TWorkspacePreview = class (TUIWorkspace)
    private
      var _Atlas: TAtlas;
      var _CamPos: TG2Vec2;
      var _Scale: Single;
      var _CurPage: Integer;
      procedure SetAtlas(const Value: TAtlas);
    protected
      procedure OnInitialize; override;
      procedure OnAdjust; override;
      procedure OnRender; override;
      procedure OnScroll(const y: Integer); override;
    public
      property Atlas: TAtlas read _Atlas write SetAtlas;
      class function GetWorkspaceName: AnsiString; override;
      function GetMinWidth: Single; override;
      function GetMinHeight: Single; override;
    end;
    type TWorkspaceControls = class (TUIWorkspaceCustom)
    protected
      procedure OnInitialize; override;
    public
      var MaxPageWidth: TUIWorkspaceCustomNumberInt;
      var MaxPageHeight: TUIWorkspaceCustomNumberInt;
      var BorderSize: TUIWorkspaceCustomNumberInt;
      var TransparentBorders: TUIWorkspaceCustomCheckbox;
      var ForcePOT: TUIWorkspaceCustomCheckbox;
      var FormatList: TUIWorkspaceCustomComboBox;
      var BtnExport: TUIWorkspaceCustomButton;
      class function GetWorkspaceName: AnsiString; override;
    end;
    var _ImageListToolbar: TWorkspaceImageListToolbar;
    var _ImageList: TWorkspaceImageList;
    var _Controls: TWorkspaceControls;
    var _Preview: TWorkspacePreview;
    var _Images: TQuickListImage;
    var _Folders: TQuickListFolder;
    var _Atlas: TAtlas;
    var _UpdateTime: TG2IntU32;
    procedure FreeAtlas;
    procedure ClearImages;
    procedure GenerateAtlas;
    procedure RenderAtlasPage(const Page: TAtlasPage);
    procedure SaveAtlas(const FilePath: String; const FormatFile: String);
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
  public
    class function GetWorkspaceName: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    procedure FuncImageAdd;
    procedure FuncFolderAdd;
    procedure FuncGenerate;
    procedure FuncExport;
    procedure FuncSave;
    procedure FuncLoad;
  end;
//TUIWorkspaceAtlasPacker END

//TUIWorkspaceStructure BEGIN
  TUIWorkspaceStructure = class (TUIWorkspace)
  public
    type TItem = class;
    type TItemList = specialize TG2QuickListG<TItem>;
    type TItem = class
      var Workspace: TUIWorkspaceStructure;
      var Name: String;
      var Parent: TItem;
      var Children: TItemList;
      var Open: Boolean;
      var UserData: Pointer;
      var Selected: Boolean;
      function Add(const NewName: String): TItem;
      procedure Remove(var Item: TItem);
    end;
  private
    var _Root: TItem;
    var _Selection: TItemList;
    procedure SelectionUpdateStart;
    procedure SelectionUpdateEnd;
    class procedure FreeItem(const Item: TItem);
    function PtInItem(const pt: TG2Vec2; var InExpand: Boolean): TItem;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property Root: TItem read _Root;
    class function GetWorkspaceName: AnsiString; override;
    procedure Clear;
  end;
//TUIWorkspaceStructure END

//TUIWorkspaceScene2DProperties BEIGN
  TUIWorkspaceScene2DProperties = class (TUIWorkspaceProperties)
  protected
    procedure OnInitialize; override;
  public
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
  end;
//TUIWorkspaceScene2DProperties END

//TUIWorkspaceScene2DStructure BEGIN
  TUIWorkspaceScene2DStructure = class (TUIWorkspace)
  public
    type TWorkspaceList = specialize TG2QuickListG<TUIWorkspaceScene2DStructure>;
    class var WorkspaceList: TWorkspaceList;
  private
    var _ScrollV: TSCrollBox;
    var _ListFrame: TG2Rect;
    var _MenuFrame: TG2Rect;
    var _Menu: TUIWorkspaceCustom;
    var _BtnSimulate: TUIWorkspaceCustomButton;
    var _ItemHeight: TG2Float;
    var _PopUp: TOverlayPopUp;
    function PtInItem(const pt: TG2Vec2; var InExpand: Boolean): TG2Scene2DEntity;
    function ItemOpen(const Item: TG2Scene2DEntity): Boolean;
    function GetContentSize: TG2Float;
    procedure BtnSaveScene;
    procedure BtnSaveSceneAs;
    procedure BtnLoadScene;
    procedure BtnClearScene;
    procedure BtnSimulate;
    procedure UpdatePopUp;
    procedure OnCopyEntity;
    procedure OnDeleteEntity;
    procedure OnSavePrefab;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
    procedure OnDragDropRelase(const Drop: TOverlayDrop); override;
  public
    class constructor Create;
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    procedure OnCreateEntity(const Entity: TG2Scene2DEntity);
    procedure OnDeleteEntity(const Entity: TG2Scene2DEntity);
    function CanDragDrop(const Drop: TOverlayDrop): Boolean; override;
  end;
//TUIWorkspaceScene2DStructure END

//TUIWorkspaceScene2D BEGIN
  TUIWorkspaceScene2D = class (TUIWorkspace)
  private
    var _Display: TG2Display2D;
    var _PopUp: TOverlayPopUp;
    var _Dragging: Boolean;
    var _DraggingSelectionPosX: Boolean;
    var _DraggingSelectionPosY: Boolean;
    var _DraggingSelectionRot: Boolean;
    var _DraggingSelectionPos: TG2Vec2;
    var _DraggingSelectionOffset: TG2Vec2;
    var _DraggingSelectionAngle: TG2Float;
    var _DragPos: TG2Vec2;
    var _TargetZoom: Single;
    var _PrefabCreatePos: TG2Vec2;
    var _ResetCamFrame: TG2Rect;
    procedure OnCreateEntity;
    procedure OnCreatePrefab;
    procedure OnSelectPrefab(const PrefabName: String);
    procedure OnCreateJointDistance;
    procedure OnCreateJointRevolute;
    procedure OnSavePrefab;
    procedure OnCopyEntity;
    procedure OnPasteEntity;
    procedure OnDeleteEntity;
    function PtInSelRotate(const pt: TG2Vec2): Boolean;
    function PtInSelDrag(const pt: TG2Vec2): Boolean;
    function PtInSelDragX(const pt: TG2Vec2): Boolean;
    function PtInSelDragY(const pt: TG2Vec2): Boolean;
    procedure UpdatePopUp;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnKeyDown(const Key: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
  end;
//TUIWorkspaceScene2D END

//TUIWorkspaceParticles2DList BEIGN
  TUIWorkspaceParticles2DList = class (TUIWorkspace)
  private
    var _ScrollV: TSCrollBox;
    var _ListFrame: TG2Rect;
    var _MenuFrame: TG2Rect;
    var _Menu: TUIWorkspaceCustom;
    var _PopUp: TOverlayPopUp;
    var _ItemHeight: TG2Float;
    var _ItemSpacing: TG2Float;
    function GetContentSize: TG2Float;
    procedure BtnSaveLib;
    procedure BtnLoadLib;
    procedure BtnClearLib;
    procedure BtnNewEffect;
    procedure BtnDeleteEffect;
    procedure BtnNewEmitter;
    procedure BtnDeleteEmitter;
    procedure BtnMoveEffectUp;
    procedure BtnMoveEffectDown;
    procedure BtnMoveEmitterUp;
    procedure BtnMoveEmitterDown;
    procedure BtnExportEffect;
    function PtInItem(const v: TG2Vec2): TParticleObject;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
  end;
//TUIWorkspaceParticles2DList END

//TUIWorkspaceParticles2DEditor BEIGN
  TUIWorkspaceParticles2DEditor = class (TUIWorkspaceCustom)
  public
    type TWorkspaceList = specialize TG2QuickListG<TUIWorkspaceParticles2DEditor>;
    class var WorkspaceList: TWorkspaceList;
  private
    var _Pages: TUIWorkspaceCustomPages;
    var _EmitterShapePropertyPages: TUIWorkspaceCustomPages;
    var _EffectNameEdit: TUIWorkspaceCustomEdit;
    var _EffectScale: TUIWorkspaceCustomNumberFloat;
    var _EmitterNameEdit: TUIWorkspaceCustomEdit;
    var _EmitterTimelineStart: TUIWorkspaceCustomNumberFloat;
    var _EmitterTimelineEnd: TUIWorkspaceCustomNumberFloat;
    var _EmitterOrientation: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeCombo: TUIWorkspaceCustomComboBox;
    var _EmitterShapeRadius0: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeRadius1: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeAngle: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeWidth0: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeWidth1: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeHeight0: TUIWorkspaceCustomNumberFloat;
    var _EmitterShapeHeight1: TUIWorkspaceCustomNumberFloat;
    var _EmitterEmission: TUIWorkspaceCustomNumberInt;
    var _EmitterLayer: TUIWorkspaceCustomNumberInt;
    var _EmitterInfinite: TUIWorkspaceCustomCheckbox;
    var _ParticleTextureFile: TUIWorkspaceCustomFile;
    var _ParticleCenterX: TUIWorkspaceCustomNumberFloat;
    var _ParticleCenterY: TUIWorkspaceCustomNumberFloat;
    var _ParticleWidthMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleWidthMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleHeightMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleHeightMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleScaleMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleScaleMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleRotationMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleRotationMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleRotationLocal: TUIWorkspaceCustomCheckbox;
    var _ParticleOrientationMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleOrientationMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleDurationMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleDurationMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleVelocityMin: TUIWorkspaceCustomNumberFloat;
    var _ParticleVelocityMax: TUIWorkspaceCustomNumberFloat;
    var _ParticleColor0: TUIWorkspaceCustomColor;
    var _ParticleColor1: TUIWorkspaceCustomColor;
    var _ParticleOpacity: TUIWorkspaceCustomNumberFloat;
    var _ParticleBlend: TUIWorkspaceCustomComboBox;
    var _ParticleBlendCustom: TUIWorkspaceCustomPanel;
    var _ParticleBlendColorSrc: TUIWorkspaceCustomComboBox;
    var _ParticleBlendColorDst: TUIWorkspaceCustomComboBox;
    var _ParticleBlendAlphaSrc: TUIWorkspaceCustomComboBox;
    var _ParticleBlendAlphaDst: TUIWorkspaceCustomComboBox;
    var _Modifiers: TUIWorkspaceCustomGroup;
    var _ModAdd: TUIWorkspaceCustomButton;
    var _ModCancel: TUIWorkspaceCustomButton;
    var _Mods: array of TUIWorkspaceCustomButton;
    procedure OnEffectNameChange;
    procedure OnEffectScaleChange;
    procedure OnEmitterNameChange;
    procedure OnEmitterTimeStartChange;
    procedure OnEmitterTimeEndChange;
    procedure OnEmitterOrientationChange;
    procedure OnEmitterShapeChange(const PrevIndex: Integer);
    procedure OnEmitterShapeRadius0Change;
    procedure OnEmitterShapeRadius1Change;
    procedure OnEmitterShapeAngleChange;
    procedure OnEmitterShapeWidth0Change;
    procedure OnEmitterShapeWidth1Change;
    procedure OnEmitterShapeHeight0Change;
    procedure OnEmitterShapeHeight1Change;
    procedure OnEmitterEmissionChange;
    procedure OnEmitterLayerChange;
    procedure OnEmitterInfiniteChange;
    procedure OnParticleTextureChange;
    procedure OnParticleWidthMinChanage;
    procedure OnParticleWidthMaxChanage;
    procedure OnParticleCenterXChange;
    procedure OnParticleCenterYChange;
    procedure OnParticleHeightMinChange;
    procedure OnParticleHeightMaxChange;
    procedure OnParticleScaleMinChange;
    procedure OnParticleScaleMaxChange;
    procedure OnParticleDurationMinChange;
    procedure OnParticleDurationMaxChange;
    procedure OnParticleRotationMinChange;
    procedure OnParticleRotationMaxChange;
    procedure OnParticleRotationLocalChange;
    procedure OnParticleOrientationMinChange;
    procedure OnParticleOrientationMaxChange;
    procedure OnParticleVelocityMinChange;
    procedure OnParticleVelocityMaxChange;
    procedure OnParticleColor0Change;
    procedure OnParticleColor1Change;
    procedure OnParticleOpacityChange;
    procedure OnParticleBlendChange(const PrevIndex: Integer);
    procedure OnParticleBlendColorSrcChange(const PrevIndex: Integer);
    procedure OnParticleBlendColorDstChange(const PrevIndex: Integer);
    procedure OnParticleBlendAlphaSrcChange(const PrevIndex: Integer);
    procedure OnParticleBlendAlphaDstChange(const PrevIndex: Integer);
    procedure OnModifierAdd(const Sender: Pointer);
    procedure ModsClear;
    procedure ModsShow;
    procedure ModsAdd;
    procedure CallAdjust;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnBeforeFinalize; override;
  public
    procedure SelectionChanged;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class constructor CreateClass;
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
  end;
//TUIWorkspaceParticles2DEditor END

//TUIWorkspaceParticles2DViewport BEIGN
  TUIWorkspaceParticles2DViewport = class (TUIWorkspace)
  public
    type TWorkspaceList = specialize TG2QuickListG<TUIWorkspaceParticles2DViewport>;
    class var WorkspaceList: TWorkspaceList;
  private
    var _Display: TG2Display2D;
    var _SettingsSize: TG2Float;
    var _FrameSettings: TG2Rect;
    var _Settings: TUIWorkspaceCustom;
    var _Background: TUIWorkspaceCustomColor;
    var _Checker: TUIWorkspaceCustomSlider;
    var _Zoom: TUIWorkspaceCustomLabel;
    var _TargetZoom: TG2Float;
    procedure OnBackgroundChange;
  protected
    procedure OnInitialize; override;
    procedure OnFinalize; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnAdjust; override;
    procedure OnScroll(const y: Integer); override;
  public
    procedure SelectionChanged;
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class constructor CreateClass;
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
  end;
//TUIWorkspaceParticles2DViewport END

//TUIWorkspaceParticles2DTimeline BEIGN
  TUIWorkspaceParticles2DTimeline = class (TUIWorkspace)
  private
    var _ScrollV: TScrollBox;
    var _ScrollH: TScrollBox;
    var _RullerHeight: TG2Float;
    var _RullerScale: TG2Float;
    var _TrackHeight: TG2Float;
    var _TrackSpacing: TG2Float;
    var _ScrollBoxSize: TG2Float;
    var _TrackFrame: TG2Rect;
    var _RullerFrame: TG2Rect;
    var _NamesFrame: TG2Rect;
    var _DragEmitter: TParticleEmitter;
    var _DragEdge: Integer;
    var _DragOffset: TG2Float;
    function GetContentSize: TG2Float;
    procedure CalculateNamesFrame;
    function GetEmitterRect(const Emitter: TParticleEmitter): TG2Rect;
  protected
    procedure OnInitialize; override;
    procedure OnRender; override;
    procedure OnUpdate; override;
    procedure OnAdjust; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
  public
    function GetMinWidth: Single; override;
    function GetMinHeight: Single; override;
    class function GetWorkspaceName: AnsiString; override;
    class function GetWorkspacePath: AnsiString; override;
  end;
//TUIWorkspaceParticles2DTimeline END

  TUIWorkspaceScriptProc = procedure (Workspace: TUIWorkspace) of Object;

  CUIWorkspace = class of TUIWorkspace;

  TView = object
  public
    var Name: AnsiString;
    var Workspace: TUIWorkspace;
    var CaptionTextPos: TG2Vec2;
  end;
  PView = ^TView;

//TUIViews BEGIN
  TUIViews = object
  private
    var TabSpacing: Integer;
    var TabSeparatorSize: Integer;
    var OffsetX: Integer;
    var ShadingSize: Integer;
    var ShadingOffset: Integer;
    var MouseDownView: Integer;
    var CloseRect: TRect;
    var NewTabRect: TRect;
    var WorkspaceRect: TRect;
    var EditView: PView;
    var ViewTextClickTime: TG2IntU32;
    var Dragging: Boolean;
    procedure OnTextEditUpdate;
    function GetCurView: PView; inline;
  public
    var Views: TG2QuickList;
    var ViewIndex: Integer;
    var Height: Integer;
    property CurView: PView read GetCurView;
    procedure Initialize;
    procedure Finalize;
    procedure Adjust;
    procedure AdjustWorkspaces;
    procedure Render;
    procedure Update;
    procedure RenderTabs;
    function ViewTextPos(const View: PView): TG2Vec2;
    function PointInView(const x, y: Integer; var InClose: Boolean; var InList: Boolean; var InText: Boolean; var TabFrame: TG2Rect): Integer; overload;
    function PointInView(const x, y: Integer; var InClose: Boolean; var InList: Boolean; var InText: Boolean): Integer; overload;
    function PointInView(const x, y: Integer; var TabFrame: TG2Rect): Integer; overload;
    function FindFrameWorkpace(const x, y: Single): TUIWorkspace;
    procedure OnMouseDown(const Button, x, y: Integer);
    procedure OnMouseUp(const Button, x, y: Integer);
    procedure OnScroll(const y: Integer);
    function AddView(const Name: AnsiString): PView;
    procedure DeleteView(const Name: AnsiString); overload;
    procedure DeleteView(const Index: Integer); overload;
    procedure SelectView(const Name: AnsiString); overload;
    procedure SelectView(const Index: Integer); overload;
    procedure Clear;
    function FindView(const Name: AnsiString): Integer;
    procedure ReplaceWorkspace(const WorkspaceOld, WorkspaceNew: TUIWorkspace);
    procedure ExtractWorkspace(const Workspace: TUIWorkspace);
    procedure CloseWorkspace(const Workspace: TUIWorkspace);
    function InsertWorkspace(const Workspace: TUIWorkspace; const Pos: TG2Vec2): Boolean;
  end;
//TUIViews END

//TUITextEditImplementation BEGIN
  TUITextEditImplementation = class
  private
    var _CursorFlickerTime: LongWord;
  public
    var DisableProc: TG2ProcObj;
    function GetCursorFlicker: Boolean;
    procedure ResetCursorFlicker;
    procedure Render; virtual;
    procedure Update; virtual;
    procedure OnEnable; virtual;
    procedure OnDisable; virtual;
    procedure AdjustCursor(const ScrX, ScrY: Single); virtual;
    procedure OnMouseDown(const x, y: Integer); virtual;
    procedure OnMouseUp(const x, y: Integer); virtual;
    procedure OnScroll(const y: Integer); virtual;
    procedure OnPrint(const Char: AnsiChar); virtual;
    procedure OnKeyDown(const Key: TG2IntS32); virtual;
    procedure OnKeyUp(const Key: TG2IntS32); virtual;
    procedure TextUpdated; virtual;
    function GetCursorPos: TG2Vec2; virtual;
  end;
//TUITextEditImplementation END

//TUITextEditSingleLine BEGIN
  TUITextEditSingleLine = class (TUITextEditImplementation)
  private
    function HaveSelection: Boolean; inline;
    procedure CursorMove;
  public
    var AllowEmpty: Boolean;
    var AutoAdjustTextPos: Boolean;
    var Text: PAnsiString;
    var Font: TG2Font;
    var Frame: PG2Rect;
    var TextPos: PG2Vec2;
    var CursorStart: Integer;
    var CursorEnd: Integer;
    var Selection: PInteger;
    var MaxLength: PInteger;
    var OnChangeProc: TG2ProcObj;
    var OnEnterProc: TG2ProcObj;
    var OnCursorMoveProc: TG2ProcObj;
    var DefaultText: AnsiString;
    function FindCursorPos(const ScrPos: Single): Integer;
    procedure CheckSelection;
    procedure Render; override;
    procedure Update; override;
    procedure OnEnable; override;
    procedure OnDisable; override;
    procedure AdjustCursor(const ScrX, ScrY: Single); override;
    procedure OnMouseDown(const x, y: Integer); override;
    procedure OnMouseUp(const x, y: Integer); override;
    procedure OnPrint(const Char: AnsiChar); override;
    procedure OnKeyDown(const Key: TG2IntS32); override;
    procedure OnKeyUp(const Key: TG2IntS32); override;
    procedure TextUpdated; override;
    function GetCursorPos: TG2Vec2; override;
    constructor Create;
  end;
//TUITextEditSingleLine END

//TUITextEditCode BEGIN
  TUITextEditCode = class (TUITextEditImplementation)
  private
    procedure MergeCursor; inline;
    procedure JumpCursor(const Dir: Integer);
    procedure DoCopy;
    procedure DoPaste;
    procedure DoMultiComment(const SaveUndo: Boolean = False);
    procedure DoMultiUnComment(const SaveUndo: Boolean = False);
    procedure DoIndent(const SaveUndo: Boolean = False);
    procedure DoUnIndent(const SaveUndo: Boolean = False);
    function HaveSelection: Boolean; inline;
    function MakeSpaces(const Count: Integer): AnsiString;
    function StrCut(const Line, PosStart, PosEnd: Integer): AnsiString;
    function GetSelectionStr: AnsiString;
    procedure DeleteLine(const Index: Integer; const Count: Integer = 1);
    procedure InsertLine(const Index: Integer);
    procedure StripSpaces(const Index: Integer);
    procedure InsertStr(const Str: AnsiString);
    procedure InsertStrSaveUndo(const Str: AnsiString);
    function GetIndentation(const Line, Pos: Integer): Integer;
  public
    var FontSize: TPoint;
    var Text: PCodeFile;
    var Font: TG2Font;
    var FontB: TG2Font;
    var FontI: TG2Font;
    var Frame: PG2Rect;
    var TextPos: PG2Vec2;
    var CursorStart: TPoint;
    var CursorEnd: TPoint;
    var Selection: PPoint;
    var MaxLength: PInteger;
    var OnChangeProc: TG2ProcObj;
    var OnEnterProc: TG2ProcObj;
    var OnCursorMoveProc: TG2ProcObj;
    var OnScrollProc: TG2ProcScrollObj;
    var OnTextPosChange: TG2ProcObj;
    var OnCmdSave: TG2ProcObj;
    var OnCmdLoad: TG2ProcObj;
    function FindCursorPos(const ScrX, ScrY: Single): TPoint;
    procedure CheckSelection;
    procedure Render; override;
    procedure Update; override;
    procedure OnEnable; override;
    procedure OnDisable; override;
    procedure AdjustCursor(const ScrX, ScrY: Single); override;
    procedure OnMouseDown(const x, y: Integer); override;
    procedure OnMouseUp(const x, y: Integer); override;
    procedure OnScroll(const y: Integer); override;
    procedure OnPrint(const Char: AnsiChar); override;
    procedure OnKeyDown(const Key: TG2IntS32); override;
    procedure OnKeyUp(const Key: TG2IntS32); override;
    procedure TextUpdated; override;
    function GetCursorPos: TG2Vec2; override;
    procedure UndoActionInsert(const Ptr: Pointer);
    procedure UndoActionComment(const Ptr: Pointer);
    procedure UndoActionUnComment(const Ptr: Pointer);
    procedure UndoActionIndent(const Ptr: Pointer);
    procedure UndoActionUnIndent(const Ptr: Pointer);
    constructor Create;
  end;
//TUITextEditCode END

//TUITextEdit BEGIN
  TUITextEdit = object
  private
    var _SingleLine: TUITextEditSingleLine;
    var _Code: TUITextEditCode;
    var _Implementation: TUITextEditImplementation;
    var _ViewIndex: Integer;
    var _Enabled: Boolean;
    var _Frame: TG2Rect;
    var _MaxLength: Integer;
    var _AllowedChars: TCharSet;
    var _AllowSymbols: Boolean;
    var _JumpBreakers: TCharSet;
    var _OnFinishProc: TG2ProcObj;
    procedure SetAllowSymbols(const Value: Boolean);
  public
    property Enabled: Boolean read _Enabled;
    property Frame: TG2Rect read _Frame write _Frame;
    property MaxLength: Integer read _MaxLength write _MaxLength;
    property AllowSymbols: Boolean read _AllowSymbols write SetAllowSymbols;
    property AllowedChars: TCharSet read _AllowedChars write _AllowedChars;
    property Impl: TUITextEditImplementation read _Implementation;
    property ImplSingleLine: TUITextEditSingleLine read _SingleLine;
    property ImplCode: TUITextEditCode read _Code;
    property JumpBreakers: TCharSet read _JumpBreakers;
    property OnFinishProc: TG2ProcObj read _OnFinishProc write _OnFinishProc;
    procedure Initialize;
    procedure Finalize;
    procedure Enable(
      const TextPtr: PAnsiString;
      const TextPosPtr: PG2Vec2;
      const Font: TG2Font;
      const OnChangeProc: TG2ProcObj;
      const DefaultText: AnsiString = '';
      const OnEnterProc: TG2ProcObj = nil;
      const OnCursorMoveProc: TG2ProcObj = nil;
      const AllowEmpty: Boolean = False
    );
    procedure EnableCode(
      const CodePtr: PCodeFile;
      const TextPosPtr: PG2Vec2;
      const OnChangeProc: TG2ProcObj;
      const OnScrollProc: TG2ProcScrollObj;
      const OnCursorMoveProc: TG2ProcObj = nil;
      const OnTextPosChange: TG2ProcObj = nil;
      const OnCmdSave: TG2ProcObj = nil;
      const OnCmdLoad: TG2ProcObj = nil
    );
    procedure Disable;
    procedure Render;
    procedure Update;
    procedure AdjustCursor(const ScrX, ScrY: Single);
    procedure OnMouseDown(const x, y: Integer);
    procedure OnMouseUp(const x, y: Integer);
    procedure OnScroll(const y: Integer);
    procedure OnPrint(const Char: AnsiChar);
    procedure OnKeyDown(const Key: TG2IntS32);
    procedure OnKeyUp(const Key: TG2IntS32);
    procedure TextUpdated;
    function GetCursorPos: TG2Vec2;
  end;
//TUITextEdit

//TUIWorkspaceConstructor BEGIN
  TUIWorkspaceConstructor = class
  private
    _WorkspaceClass: CUIWorkspace;
  public
    property WorkspaceClass: CUIWorkspace read _WorkspaceClass write _WorkspaceClass;
    function GetName: AnsiString; virtual;
    procedure OnCreateWorkspace(const Workspace: TUIWorkspace); virtual;
  end;
//TUIWorkspaceConstructor END

//TUIWorkspaceConstructorCode BEGIN
  TUIWorkspaceConstructorCode = class (TUIWorkspaceConstructor)
  public
    constructor Create;
    procedure OnCreateWorkspace(const Workspace: TUIWorkspace); override;
  end;
//TUIWorkspaceConstructorCode END

  TWorkspaceList = specialize TG2QuickListG<TUIWorkspaceConstructor>;

  TUIMessageType = (
    mtInsertWorkspace,
    mtExtractWorkspace,
    mtCloseWorkspace,
    mtReplaceWorkspace,
    mtResizeWorkspace,
    mtMouseDown,
    mtMouseUp,
    mtLoadLayout,
    mtOpenProject,
    mtCallProc,
    mtCallProcPtr
  );

  TUIMessageDataInsertWorkspace = record
    Workspace: TUIWorkspace;
    InsertPos: TG2Vec2;
    CanDelete: Boolean;
  end;
  PUIMessageDataInsertWorkspace = ^TUIMessageDataInsertWorkspace;

  TUIMessageDataExtractWorkspace = record
    Workspace: TUIWorkspace;
  end;
  PUIMessageDataExtractWorkspace = ^TUIMessageDataExtractWorkspace;

  TUIMessageDataCloseWorkspace = record
    Workspace: TUIWorkspace;
  end;
  PUIMessageDataCloseWorkspace = ^TUIMessageDataCloseWorkspace;

  TUIMessageDataReplaceWorkspace = record
    WorkspaceOld: TUIWorkspace;
    WorkspaceNew: TUIWorkspace;
  end;
  PUIMessageDataReplaceWorkspace = ^TUIMessageDataReplaceWorkspace;

  TUIMessageDataResizeWorkspace = record
    Workspace: TUIWorkspace;
    Frame: TG2Rect;
  end;
  PUIMessageDataResizeWorkspace = ^TUIMessageDataResizeWorkspace;

  TUIMessageDataMouseInput = record
    Button: Integer;
    x, y: Integer;
  end;
  PUIMessageDataMouseInput = ^TUIMessageDataMouseInput;

  TUIMessageDataLoadLayout = record
    FileName: array[0..511] of AnsiChar;
  end;
  PUIMessageDataLoadLayout = ^TUIMessageDataLoadLayout;

  TUIMessageDataOpenProject = record
    FileName: array[0..511] of AnsiChar;
  end;
  PUIMessageDataOpenProject = ^TUIMessageDataOpenProject;

  TUIMessageDataCallProc = record
    Proc: TG2ProcObj;
  end;
  PUIMessageDataCallProc = ^TUIMessageDataCallProc;

  TUIMessageDataCallProcPtr = record
    Proc: TG2ProcPtrObj;
    Ptr: Pointer;
  end;
  PUIMessageDataCallProcPtr = ^TUIMessageDataCallProcPtr;

  TUIMessage = record
    MessageType: TUIMessageType;
    Data: Pointer;
    DataSize: Integer;
  end;
  PUIMessage = ^TUIMessage;

  TUIMessageList = specialize TG2QuickListG<PUIMessage>;

  TUIHint = object
  private
    var _Alpha: Single;
  public
    var Text: AnsiString;
    var Pos: TG2Vec2;
    var Enabled: Boolean;
    var BorderSize: TG2Vec2;
    procedure Initialize;
    procedure Update;
    procedure Render;
  end;

  TUI = object
  public
    var Font1: TG2Font;
    var FontCode: TG2Font;
    var FontCodeB: TG2Font;
    var FontCodeI: TG2Font;
    var TextEdit: TUITextEdit;
    var Overlay: TOverlayObject;
    var TexCarbon: TG2Texture2D;
    var TexChecker: TG2Texture2D;
    var TexDocEmpty: TG2Texture2D;
    var TexFileOpen: TG2Texture2D;
    var TexFileSave: TG2Texture2D;
    var TexFileSaveAs: TG2Texture2D;
    var TexDocExport: TG2Texture2D;
    var TexDocPlus: TG2Texture2D;
    var TexFolderPlus: TG2Texture2D;
    var TexFolder: TG2Texture2D;
    var TexPlus: TG2Texture2D;
    var TexGear: TG2Texture2D;
    var TexDelete: TG2Texture2D;
    var TexPlay: TG2Texture2D;
    var TexStop: TG2Texture2D;
    var TexDots: TG2Texture2D;
    var TexLink: TG2Texture2D;
    var TexPin: TG2Texture2D;
    var TexRoundMinus: TG2Texture2D;
    var TexRoundPlus: TG2Texture2D;
    var TexSpot: TG2Texture2D;
    var Views: TUIViews;
    var WorkspaceFrame: TG2Rect;
    var WorkspaceClasses: TWorkspaceList;
    var OverlayWorkspaceList: TOverlayWorkspaceList;
    var OverlayWorkspace: TOverlayWorkspace;
    var OverlayAssetSelect: TOverlayAssetSelect;
    var Messages, MessagesDumped: TUIMessageList;
    var Cursor: TG2Cursor;
    var ColorPrimary: TG2Color;
    var ColorSecondary: TG2Color;
    var ClipRects: array of TRect;
    var Hint: TUIHint;
    procedure RegisterWorkspace(const WorkspaceClass: CUIWorkspace);
    procedure RegisterWorkspaceConstructor(const WorkspaceConstructor: TUIWorkspaceConstructor);
    procedure Initialize;
    procedure Finalize;
    procedure Render;
    procedure Update;
    procedure Resize;
    procedure MsgInsertWorkspace(
      const Workspace: TUIWorkspace;
      const InsertPos: TG2Vec2;
      const CanDelete: Boolean = True;
      const Push: Boolean = False
    );
    procedure LoadWorkspaces;
    procedure MsgExtractWorkspace(const Workspace: TUIWorkspace; const Push: Boolean = False);
    procedure MsgCloseWorkspace(const Workspace: TUIWorkspace; const Push: Boolean = False);
    procedure MsgReplaceWorkspace(const WorkspaceOld, WorkspaceNew: TUIWorkspace; const Push: Boolean = False);
    procedure MsgResizeWorkspace(const Workspace: TUIWorkspace; const Frame: TG2Rect; const Push: Boolean = False);
    procedure MsgMouseDown(const Button, x, y: Integer; const Push: Boolean = False);
    procedure MsgMouseUp(const Button, x, y: Integer; const Push: Boolean = False);
    procedure MsgLoadLayout(const FileName: String; const Push: Boolean = False);
    procedure MsgOpenProject(const FileName: String; const Push: Boolean = False);
    procedure MsgCallProc(const Proc: TG2ProcObj; const Push: Boolean = False);
    procedure MsgCallProcPtr(const Proc: TG2ProcPtrObj; const Ptr: Pointer; const Push: Boolean = False);
    function CreateMessage(const MessageType: TUIMessageType; const Data: Pointer; const DataSize: Integer): PUIMessage;
    procedure PushMessage(const MessageType: TUIMessageType; const Data: Pointer; const DataSize: Integer);
    procedure StackMessage(const MessageType: TUIMessageType; const Data: Pointer; const DataSize: Integer);
    procedure ProcessMessages;
    procedure OnMouseDown(const Button, x, y: Integer);
    procedure OnMouseUp(const Button, x, y: Integer);
    procedure OnScroll(const y: Integer);
    procedure OnPrint(const Char: AnsiChar);
    procedure OnKeyDown(const Key: TG2IntS32);
    procedure OnKeyUp(const Key: TG2IntS32);
    function GetColorPrimary(const Brightness: Single; const Alpha: Single = 1): TG2Color;
    function GetColorSecondary(const Brightness: Single; const Alpha: Single = 1): TG2Color;
    procedure DrawCross(const R: TRect; const Color: TG2Color);
    procedure DrawRects(const R: TRect; const Color: TG2Color);
    procedure DrawCircles(const R: TRect; const Color: TG2Color);
    procedure DrawRectBorder(const R: TRect; const Border: Integer; const Color: TG2Color);
    procedure DrawPlus(const R: TRect; const Color: TG2Color);
    procedure DrawSmoothCircle(const Center: TG2Vec2; const Radius0, Radius1: Single; const Segments: Integer; const Color0, Color1, Color2: TG2Color);
    procedure DrawCircleBorder(const Center: TG2Vec2; const Radius, Border: TG2Float; const Segments: Integer; const Color: TG2Color);
    procedure DrawCheckbox(const R: TRect; const Color0, Color1: TG2Color; const Checked: Boolean);
    procedure DrawRadio(const R: TRect; const Color0, Color1: TG2Color; const Checked: Boolean);
    procedure DrawArrow(const Origin, Target: TG2Vec2; const Size: TG2Float; const Color: TG2Color);
    procedure DrawSpotFrame(const R: TRect; const FrameSize: TG2Float; const Color: TG2Color);
    procedure PushClipRect(const R: TRect);
    procedure PopClipRect;
    procedure LayoutSave(const FileName: String);
    procedure LayoutLoad(const FileName: String);
  end;

//TLog BEGIN
  TLog = object
  private
    _TimeStamp: LongWord;
    _Lines: array[0..49] of AnsiString;
    _LineCount: Integer;
    _CurLine: Integer;
    function GetLine(const Index: Integer): AnsiString; inline;
  public
    property Lines[const Index: Integer]: AnsiString read GetLine;
    property LineCount: Integer read _LineCount;
    procedure Initialize;
    procedure Finalize;
    procedure Clear;
    procedure Log(const Text: AnsiString);
    procedure AssertLog(const Value: Boolean; const LogMessage: AnsiString = 'Error');
    procedure ProfileBegin;
    function ProfileEnd: LongWord;
  end;
//TLog END

//TConsole BEGIN
  TConsole = object
  private
    _Parser: TG2Parser;
    _Lines: array[0..249] of AnsiString;
    _LineCount: Integer;
    _CurLine: Integer;
    function GetLine(const Index: Integer): AnsiString; inline;
    procedure AddLine(const Line: AnsiString);
  public
    property Lines[const Index: Integer]: AnsiString read GetLine;
    property LineCount: Integer read _LineCount;
    procedure Initialize;
    procedure Finalize;
    procedure Clear;
    procedure Command(const Text: AnsiString);
  end;
//TConsole END

//TProject BEGIN
  TProject = object
  private
    _Open: Boolean;
    _FilePath: String;
    _FileName: String;
    _LastModifyCheck: TG2IntU32;
    _LastModified: Integer;
    _md5: TG2MD5;
    _ProjectCode: AnsiString;
    _ProjectIncludeSource: TG2StrArrA;
    function GetProjectName: AnsiString;
    function GetProjectPath: AnsiString;
    function GetProjectIncludeSource(const Index: Integer): AnsiString; inline;
    function GetProjectIncludeSourceCount: Integer; inline;
  public
    property Open: Boolean read _Open;
    property FilePath: String read _FilePath;
    property FileName: String read _FileName;
    property ProjectPath: AnsiString read GetProjectPath;
    property ProjectName: AnsiString read GetProjectName;
    property ProjectCode: AnsiString read _ProjectCode;
    property ProjectIncludeSource[const Index: Integer]: AnsiString read GetProjectIncludeSource;
    property ProjectIncludeSourceCount: Integer read GetProjectIncludeSourceCount;
    procedure Initialize;
    procedure Finalize;
    procedure Update;
    procedure New;
    procedure Load; overload;
    procedure Load(const f: String); overload;
    procedure Close;
    procedure ReLoad;
    procedure Build;
    procedure BuildHTML5;
    procedure CreateLPR;
    procedure UpdateSettings;
  end;
//TProject END

//TParticleData BEGIN
  TParticleMod = class;
  TParticleModList = specialize TG2QuickListG<TParticleMod>;
  TParticleEffect = class;
  TParticleEmitterList = specialize TG2QuickListG<TParticleEmitter>;
  TParticleObject = class
  public
    var Name: String;
    var Emitters: TParticleEmitterList;
  end;

  TParticleEmitterShape = (es_radial = 0, es_rectangle = 1);

  TParticleEmitter = class (TParticleObject)
  public
    var ParentEffect: TParticleEffect;
    var ParentEmitter: TParticleEmitter;
    var Texture: TG2Texture2D;
    var TimeStart: TG2Float;
    var TimeEnd: TG2Float;
    var Orientation: TG2Float;
    var Shape: TParticleEmitterShape;
    var ShapeRadius0: TG2Float;
    var ShapeRadius1: TG2Float;
    var ShapeAngle: TG2Float;
    var ShapeWidth0: TG2Float;
    var ShapeWidth1: TG2Float;
    var ShapeHeight0: TG2Float;
    var ShapeHeight1: TG2Float;
    var Emission: Integer;
    var Layer: Integer;
    var Infinite: Boolean;
    var ParticleCenterX: TG2Float;
    var ParticleCenterY: TG2Float;
    var ParticleWidthMin: TG2Float;
    var ParticleWidthMax: TG2Float;
    var ParticleHeightMin: TG2Float;
    var ParticleHeightMax: TG2Float;
    var ParticleScaleMin: TG2Float;
    var ParticleScaleMax: TG2Float;
    var ParticleDurationMin: TG2Float;
    var ParticleDurationMax: TG2Float;
    var ParticleRotationMin: TG2Float;
    var ParticleRotationMax: TG2Float;
    var ParticleRotationLocal: Boolean;
    var ParticleOrientationMin: TG2Float;
    var ParticleOrientationMax: TG2Float;
    var ParticleVelocityMin: TG2Float;
    var ParticleVelocityMax: TG2Float;
    var ParticleColor0: TG2Color;
    var ParticleColor1: TG2Color;
    var ParticleBlend: TG2BlendMode;
    var Mods: TParticleModList;
    constructor Create;
    destructor Destroy; override;
    function IsSelected: Boolean;
    function IsOpen: Boolean;
    procedure Save(const dm: TG2DataManager);
    procedure Load(const dm: TG2DataManager);
  end;

  TParticleEffect = class (TParticleObject)
  private
  public
    var Scale: TG2Float;
    constructor Create;
    destructor Destroy; override;
    function IsSelected: Boolean;
    function IsOpen: Boolean;
    procedure Save(const dm: TG2DataManager);
    procedure Load(const dm: TG2DataManager);
  end;
  TParticleEffectList = specialize TG2QuickListG<TParticleEffect>;

  type TParticleLayer = class
  public
    var Index: Integer;
    var Particles: TG2QuickList;
    var Ref: Integer;
  end;

  type TParticle = class
  public
    var Data: TParticleEmitter;
    var Layer: TParticleLayer;
    var OrientationInit: TG2Float;
    var xf: TG2Transform2;
    var Duration: TG2Float;
    var DurationTotal: TG2Float;
    var CenterX: TG2Float;
    var CenterY: TG2Float;
    var WidthInit: TG2Float;
    var Width: TG2Float;
    var HeightInit: TG2Float;
    var Height: TG2Float;
    var ScaleInit: TG2Float;
    var Scale: TG2Float;
    var VelocityInit: TG2Float;
    var Velocity: TG2Float;
    var RotationInit: TG2Float;
    var Rotation: TG2Float;
    var RotationLocal: Boolean;
    var ColorInit: TG2Color;
    var Color: TG2Color;
    var BlendMode: TG2BlendMode;
  end;

  type TEmitter = class
  public
    var Data: TParticleEmitter;
    var Parent: TParticle;
    var Delay: TG2Float;
    var Duration: TG2Float;
    var DurationTotal: TG2Float;
    var ParticlesToEmitt: Integer;
    var Layer: Integer;
    var Orientation: TG2Float;
    var Radius0, Radius1: TG2Float;
    var Width0, Width1: TG2Float;
    var Height0, Height1: TG2Float;
  end;

  TWorkspaceParticleMod = class (TUIWorkspaceCustomGroup)
  private
    var _FrameClose: TG2Rect;
    var _MdInClose: Boolean;
    var _OnClose: TG2ProcObj;
  protected
    procedure OnInitialize; override;
    procedure OnAdjust; override;
    procedure OnRender; override;
    procedure OnMouseDown(const Button, x, y: Integer); override;
    procedure OnMouseUp(const Button, x, y: Integer); override;
  public
    property OnClose: TG2ProcObj read _OnClose write _OnClose;
  end;

  TParticleMod = class
  public
    var Group: TWorkspaceParticleMod;
    class function GetGUID: AnsiString; virtual;
    class function GetName: AnsiString; virtual;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure OnModClose;
    procedure OnParticleCreate(const Particle: TParticle); virtual;
    procedure OnParticleDestroy(const Particle: TParticle); virtual;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); virtual;
    procedure OnEmitterUpdate(const Emitter: TEmitter; const t: TG2Float); virtual;
    procedure Save(const dm: TG2DataManager); virtual;
    procedure Load(const dm: TG2DataManager); virtual;
    procedure WriteG2ML(const g2ml: TG2MLWriter); virtual;
  end;

  TParticleModOpacityGraph = class (TParticleMod)
  public
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModScaleGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModColorGraph = class (TParticleMod)
  public
    var Graph: TUIWorkspaceCustomColorGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModWidthGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModHeightGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModRotationGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModOrientationGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModVelocityGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleModAcceleration = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var Direction: TUIWorkspaceCustomNumberFloat;
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Local: TUIWorkspaceCustomCheckbox;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnParticleUpdate(const Particle: TParticle; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleEmitterModOrientationGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnEmitterUpdate(const Emitter: TEmitter; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  TParticleEmitterModScaleGraph = class (TParticleMod)
  private
    procedure OnGraphScaleChange;
  public
    var GraphScale: TUIWorkspaceCustomNumberFloat;
    var Graph: TUIWorkspaceCustomGraph;
    constructor Create; override;
    class function GetGUID: AnsiString; override;
    class function GetName: AnsiString; override;
    destructor Destroy; override;
    procedure OnEmitterUpdate(const Emitter: TEmitter; const t: TG2Float); override;
    procedure Save(const dm: TG2DataManager); override;
    procedure Load(const dm: TG2DataManager); override;
    procedure WriteG2ML(const g2ml: TG2MLWriter); override;
  end;

  CParticleMod = class of TParticleMod;
  TParticleModClassList = specialize TG2QuickListG<CParticleMod>;

  TParticlePlayback = class
  private
    var EmittersAlive: Integer;
    var ParticlesAlive: Integer;
    var Emitters: TG2QuickList;
    var Layers: TG2QuickList;
    var _Playing: Boolean;
    var _Time: TG2Float;
    function FindLayer(const Index: Integer): TParticleLayer;
    function CreateEmitter(const Data: TParticleEmitter; const Parent: TParticle = nil): TEmitter;
  public
    property Playing: Boolean read _Playing;
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    procedure Stop;
    procedure Update;
    procedure Render(const Display: TG2Display2D);
  end;

  TParticleData = object
  private
    type TExportState = (es_none, es_initiate, es_render);
    var _ChangedTime: TG2Float;
    var _ExportState: TExportState;
    var _ExportEffect: TParticleEffect;
    var _ExportAtlas: TG2Atlas;
  public
    const Version = $1000;
    var Playback: TParticlePlayback;
    var Effects: TParticleEffectList;
    var Selection: TParticleObject;
    var Mods: TParticleModClassList;
    procedure Initialize;
    procedure Finalize;
    procedure Update;
    procedure Render; overload;
    procedure EffectChanged;
    procedure Render(const Display: TG2Display2D); overload;
    function CurrentEffect: TParticleEffect;
    function EffectAdd: TParticleEffect;
    procedure EffectSelect(const Effect: TParticleEffect);
    procedure EffectDelete(const Effect: TParticleEffect);
    function EmitterAdd: TParticleEmitter;
    procedure EmitterSelect(const Emitter: TParticleEmitter);
    procedure EmitterDelete(const Emitter: TParticleEmitter);
    procedure UpdateEditors;
    procedure SaveLib(const FileName: String);
    procedure LoadLib(const FileName: String);
    procedure ExportEffect(const Effect: TParticleEffect);
    procedure Clear;
    function FindEffectByName(const Name: String): TParticleEffect;
    function UniqueEffectName(const Name: String): String;
    function FindEmitterByName(const Parent: TParticleObject; const Name: String): TParticleEmitter;
    function UniqueEmitterName(const Parent: TParticleObject; const Name: String): String;
  end;
//TParticleData END

//TAtlasPackerData BEGIN
  TAtlasPackerData = object
  private
    var _WorkspaceCount: Integer;
    var _TimeToUpdate: Single;
    var _LastUpdateTime: TG2IntU32;
    var _FormatList, _UpdateList: TG2QuickListString;
    function GetFormat(const Index: Integer): String;
    function GetFormatCount: Integer;
  public
    property WorkspaceCount: Integer read _WorkspaceCount write _WorkspaceCount;
    property UpdateTime: TG2IntU32 read _LastUpdateTime;
    property Formats[const Index: Integer]: String read GetFormat;
    property FormatCount: Integer read GetFormatCount;
    procedure Initailize;
    procedure Finalize;
    procedure Update;
  end;
//TAtlasPackerData END

//TScene2DEditor BEGIN
  TScene2DEditor = class
  private
    var _Ref: Integer;
  public
    property Ref: Integer read _Ref;
    procedure RefInc;
    procedure RefDec;
    procedure Update; virtual;
    procedure Update(const Display: TG2Display2D); virtual;
    procedure Render(const Display: TG2Display2D); virtual;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); virtual;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); virtual;
    procedure KeyDown(const Key: Integer); virtual;
    procedure KeyUp(const Key: Integer); virtual;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
  end;
//TScene2DEditor END

//TScene2DEditorShape BEIGN
  TScene2DEditorShape = class (TScene2DEditor)
  protected
    function GetOwner: TG2Scene2DEntity; virtual;
    function GetTransform: TG2Transform2; inline;
    procedure DrawEditPoint(const Display: TG2Display2D; const v: TG2Vec2; const c: TG2Color);
  public
  end;
//TScene2DEditorShape END

  TScene2DComponentDataShapeEdge = class;

//TScene2DEditorEdge BEGIN
  TScene2DEditorEdge = class (TScene2DEditorShape)
  private
    var _Component: TScene2DComponentDataShapeEdge;
    var VSelect: Integer;
  protected
    function GetOwner: TG2Scene2DEntity; override;
  public
    class var Instance: TScene2DEditorEdge;
    property Component: TScene2DComponentDataShapeEdge read _Component write _Component;
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Display: TG2Display2D); override;
    procedure Render(const Display: TG2Display2D); override;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure Initialize; override;
  end;
//TScene2DEditorEdge END

  TScene2DComponentDataShapeChain = class;

//TScene2DEditorChain BEGIN
  TScene2DEditorChain = class (TScene2DEditorShape)
  private
    var _Component: TScene2DComponentDataShapeChain;
    var VLast, VSelect: Integer;
  protected
    function GetOwner: TG2Scene2DEntity; override;
  public
    class var Instance: TScene2DEditorChain;
    property Component: TScene2DComponentDataShapeChain read _Component write _Component;
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Display: TG2Display2D); override;
    procedure Render(const Display: TG2Display2D); override;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure Initialize; override;
  end;
//TScene2DEditorChain END

  TScene2DComponentDataShapePoly = class;

//TScene2DEditorShapePoly BEGIN
  TScene2DEditorShapePoly = class (TScene2DEditorShape)
  private
    var _Component: TScene2DComponentDataShapePoly;
    var _Limits: TVec3List;
    var VSelect: Integer;
    procedure SetLimits;
  protected
    function GetOwner: TG2Scene2DEntity; override;
  public
    class var Instance: TScene2DEditorShapePoly;
    property Component: TScene2DComponentDataShapePoly read _Component write _Component;
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Display: TG2Display2D); override;
    procedure Render(const Display: TG2Display2D); override;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure Initialize; override;
  end;
//TScene2DEditorShapePoly END

  TScene2DComponentDataPoly = class;
  TScene2DComponentDataPolyVertex = class;
  TScene2DComponentDataPolyEdge = class;
  TScene2DComponentDataPolyFace = class;
  TScene2DComponentDataPolyVertexList = specialize TG2QuickListG<TScene2DComponentDataPolyVertex>;
  TScene2DComponentDataPolyEdgeList = specialize TG2QuickListG<TScene2DComponentDataPolyEdge>;
  TScene2DComponentDataPolyFaceList = specialize TG2QuickListG<TScene2DComponentDataPolyFace>;
  TScene2DComponentDataPolyLayer = class;
  TScene2DComponentDataPolyLayerList = specialize TG2QuickListG<TScene2DComponentDataPolyLayer>;

//TScene2DEditorPoly BEGIN
  TScene2DEditorPoly = class (TScene2DEditor)
  public
    type TEditMode = (em_vertex, em_tex_coord, em_edge, em_face, em_layer);
  private
    type TSelectList = class (TOverlayObject)
    public
      var List: TG2QuickListAnsiString;
      var f: TG2Rect;
      var bs, ItemSize: TG2Float;
      var OnSelect: TG2ProcIntObj;
      constructor Create; override;
      procedure Clear;
      procedure AddItem(const ItemName: AnsiString);
      procedure Initialize(const Frame: TG2Rect; const BorderSize: TG2Float);
      procedure Render; override;
      procedure MouseDown(const Button, x, y: Integer); override;
      procedure MouseUp(const Button, x, y: Integer); override;
    end;
    type TBtn = class
    public
      var OnClick: TG2ProcPtrObj;
      var Name: String;
      var Visible: Boolean;
      var MdInButton: Boolean;
      var Frame: TG2Rect;
    end;
    type TBtnColor = record
      MdInButton: Boolean;
      Frame: TG2Rect;
      Visible: Boolean;
    end;
    var Buttons: array of TBtn;
    var _BtnColor: TBtnColor;
    var _BrushSizeFrame: TG2Rect;
    var _BtnMode: TBtn;
    var _BtnFlipEdge: TBtn;
    var _BtnCollapse: TBtn;
    var _BtnSplit: TBtn;
    var _BtnDelete: TBtn;
    var _PrevDebugRender: Boolean;
    var _Component: TScene2DComponentDataPoly;
    var _PopUp: TSelectList;
    var _MOverEdge: TScene2DComponentDataPolyEdge;
    var _MOverVertex: TScene2DComponentDataPolyVertex;
    var _MOverFace: TScene2DComponentDataPolyFace;
    var _MdInEdge: TScene2DComponentDataPolyEdge;
    var _MdInVertex: TScene2DComponentDataPolyVertex;
    var _MdInFace: TScene2DComponentDataPolyFace;
    var _SelectVertex: TScene2DComponentDataPolyVertexList;
    var _SelectEdge: TScene2DComponentDataPolyEdgeList;
    var _SelectFace: TScene2DComponentDataPolyFaceList;
    var _Drag: Boolean;
    var _VDrag: TScene2DComponentDataPolyVertexList;
    var _VOffset: array of TG2Vec2;
    var _BrushColor: TG2Color;
    var _BrushSize: TG2Float;
    var _BrushSizeVisible: Boolean;
    var _BrushSizeMd: Boolean;
    var _MdInButton: Boolean;
    procedure StartDrag(const mc: TG2Vec2);
    procedure SetUpPopUpModes;
    procedure OnSelectMode(const Index: Integer);
    procedure OnModeLayer(const Index: Integer);
    procedure OnModeVertices;
    procedure OnModeEdges;
    procedure OnModeFaces;
    procedure OnModeTexCoords;
    procedure OnModeClick(const Display: Pointer);
    procedure OnFlipEdgeClick(const Display: Pointer);
    procedure OnCollapseClick(const Display: Pointer);
    procedure OnSplitClick(const Display: Pointer);
    procedure OnDeleteClick(const Display: Pointer);
    procedure DeleteVertex(const v: TScene2DComponentDataPolyVertex);
    procedure DeleteEdge(const e: TScene2DComponentDataPolyEdge);
    procedure DeleteFace(const f: TScene2DComponentDataPolyFace);
    function CheckVertices: Integer;
    function CheckEdges: Integer;
    function CheckFaces: Integer;
    function CheckMesh: Integer;
    procedure VerifyMesh;
    function IsSelecting: Boolean;
    function SelectRect: TG2Rect; overload;
    function SelectRect(const Display: TG2Display2D; var ClipRect: TG2Rect): Boolean; overload;
    function AddButton(const Name: String): TBtn;
  public
    var EditMode: TEditMode;
    var EditLayer: Integer;
    class var Instance: TScene2DEditorPoly;
    property Component: TScene2DComponentDataPoly read _Component write _Component;
    constructor Create;
    destructor Destroy; override;
    procedure Update; override;
    procedure Update(const Display: TG2Display2D); override;
    procedure Render(const Display: TG2Display2D); override;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure KeyDown(const Key: Integer); override;
    procedure Initialize; override;
    procedure Finalize; override;
  end;
//TScene2DEditorPoly END

  TScene2DJointDataDistance = class;

//TScene2DEditorJointDistance BEGIN
  TScene2DEditorJointDistance = class (TScene2DEditor)
  private
    type TJDActionType = (jdat_idle, jdat_drag_joint, jdat_drag_anchor_a, jdat_drag_anchor_b);
    var _Joint: TScene2DJointDataDistance;
    var _ActionType: TJDActionType;
    var _CanConnect: Boolean;
    var _PopUp: TOverlayPopUp;
    function GetJointDrawPos(const Display: TG2Display2D): TG2Vec2;
    procedure OnDeleteJoint;
    procedure OnDetachA;
    procedure OnDetachB;
  public
    class var Instance: TScene2DEditorJointDistance;
    property Joint: TScene2DJointDataDistance read _Joint write _Joint;
    property ActionType: TJDActionType read _ActionType;
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Display: TG2Display2D); override;
    procedure Render(const Display: TG2Display2D); override;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure KeyDown(const Key: Integer); override;
    procedure Initialize; override;
  end;
//TScene2DEditorJointDistance END

  TScene2DJointDataRevolute = class;

//TScene2DEditorJointRevolute BEGIN
  TScene2DEditorJointRevolute = class (TScene2DEditor)
  private
    type TJRActionType = (jrat_idle, jrat_drag_joint, jrat_drag_anchor_a, jrat_drag_anchor_b);
    var _Joint: TScene2DJointDataRevolute;
    var _ActionType: TJRActionType;
    var _CanConnect: Boolean;
    var _PopUp: TOverlayPopUp;
    function GetJointDrawPos(const Display: TG2Display2D): TG2Vec2;
    procedure OnDeleteJoint;
    procedure OnDetachA;
    procedure OnDetachB;
  public
    class var Instance: TScene2DEditorJointRevolute;
    property Joint: TScene2DJointDataRevolute read _Joint write _Joint;
    property ActionType: TJRActionType read _ActionType;
    constructor Create;
    destructor Destroy; override;
    procedure Update(const Display: TG2Display2D); override;
    procedure Render(const Display: TG2Display2D); override;
    procedure MouseDown(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure MouseUp(const Display: TG2Display2D; const Button, x, y: Integer); override;
    procedure KeyDown(const Key: Integer); override;
    procedure Initialize; override;
  end;
//TScene2DEditorJointRevolute END

//TScene2DEntityData BEGIN
  TScene2DEntityData = class
  public
    var oxf: TG2Transform2;
    var Entity: TG2Scene2DEntity;
    var Selected: Boolean;
    var OpenStructure: TG2QuickList;
    var Properties: TPropertySet;
    var EditName: String;
    var EditTags: AnsiString;
    var EditPosition: TG2Vec2;
    var EditRotation: TG2Float;
    constructor Create(const AEntity: TG2Scene2DEntity);
    destructor Destroy; override;
    procedure SyncTags;
    procedure SyncProperties;
    procedure OnNameChange(const Sender: Pointer);
    procedure OnPositionChange(const Sender: Pointer);
    procedure OnRotationChange(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
    procedure UpdateProperties;
  end;
//TScene2DEntityData END

//TScene2DComponentData BEGIN
  TScene2DComponentData = class
  protected
    Tags: AnsiString;
    procedure SyncTags(const Cmp: TG2Scene2DComponent);
  public
    class function GetName: String; virtual;
    constructor Create; virtual;
    destructor Destroy; override;
    function PickLayer: Integer; virtual;
    function Pick(const x, y: TG2Float): Boolean; virtual;
    procedure DebugDraw(const Display: TG2Display2D); virtual;
    function PtInComponent(const pt: TG2Vec2): Integer; virtual;
    procedure AddToProperties(const PropertySet: TPropertySet); virtual;
  end;
  CScene2DComponentData = class of TScene2DComponentData;
//TScene2DComponentData END

//TScene2DComponentDataSprite BEIGN
  TScene2DComponentDataSprite = class (TScene2DComponentData)
  private
    var Layer: TG2IntS32;
    var ImagePath: String;
    var Position: TG2Vec2;
    var Rotation: TG2Float;
  public
    var Component: TG2Scene2DComponentSprite;
    class function GetName: String; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeLayer(const Sender: Pointer);
    procedure OnChangeImage(const Sender: Pointer);
    procedure OnChangePosition(const Sender: Pointer);
    procedure OnChangeRotation(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataSprite END

//TScene2DComponentDataText BEIGN
  TScene2DComponentDataText = class (TScene2DComponentData)
  private
    var Layer: TG2IntS32;
    var FontPath: String;
    var Position: TG2Vec2;
    var Rotation: TG2Float;
  public
    var Component: TG2Scene2DComponentText;
    class function GetName: String; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeLayer(const Sender: Pointer);
    procedure OnChangeFont(const Sender: Pointer);
    procedure OnChangePosition(const Sender: Pointer);
    procedure OnChangeRotation(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataText END

//TScene2DComponentDataSpineAnimation BEGIN
  TScene2DComponentDataSpineAnimation = class (TScene2DComponentData)
  private
    var SkeletonPath: String;
    var Layer: Integer;
    var Offset: TG2Vec2;
    var Scale: TG2Vec2;
    var AnimIndex: Byte;
    var AnimList: TPropertySet.TPropertyEnum;
    var Loop: Boolean;
    var FlipX: Boolean;
    var FlipY: Boolean;
    var TimeScale: TG2Float;
    procedure UpdateAnimList;
  public
    var Component: TG2Scene2DComponentSpineAnimation;
    class function GetName: String; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnSkeletonPathChange(const Sender: Pointer);
    procedure OnLayerChange(const Sender: Pointer);
    procedure OnOffsetChange(const Sender: Pointer);
    procedure OnScaleChange(const Sender: Pointer);
    procedure OnAnimationChange(const Sender: Pointer);
    procedure OnLoopChange(const Sender: Pointer);
    procedure OnFlipXChange(const Sender: Pointer);
    procedure OnFlipYChange(const Sender: Pointer);
    procedure OnTimeScaleChange(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataSpineAnimation END

//TScene2DComponentDataBackground BEIGN
  TScene2DComponentDataBackground = class (TScene2DComponentData)
  private
    var Layer: TG2IntS32;
    var TexturePath: String;
  public
    var Component: TG2Scene2DComponentBackground;
    class function GetName: String; override;
    destructor Destroy; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeLayer(const Sender: Pointer);
    procedure OnChangeTexture(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataBackground END

//TScene2DComponentDataPoly BEIGN
  TScene2DComponentDataPolyVertex = class
  public
    var v: TG2Vec2;
    var t: TG2Vec2;
    var c: TG2QuickListColor;
    var e: TScene2DComponentDataPolyEdgeList;
    var f: TScene2DComponentDataPolyFaceList;
    var ind: TG2IntU16;
    constructor Create;
    function IsEnclosed: Boolean;
  end;

  TScene2DComponentDataPolyEdge = class
  public
    var v: array[0..1] of TScene2DComponentDataPolyVertex;
    var f: array[0..1] of TScene2DComponentDataPolyFace;
    constructor Create;
    function Contains(const Vertex: TScene2DComponentDataPolyVertex): Boolean;
  end;

  TScene2DComponentDataPolyFace = class
  public
    var v: array[0..2] of TScene2DComponentDataPolyVertex;
    var e: array[0..2] of TScene2DComponentDataPolyEdge;
    constructor Create;
    function Contains(const Vertex: TScene2DComponentDataPolyVertex): Boolean;
    function Contains(const Edge: TScene2DComponentDataPolyEdge): Boolean;
    function VertexOpposite(const Vertex0, Vertex1: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyVertex;
    function VertexOppositeEdge(const Edge: TScene2DComponentDataPolyEdge): TScene2DComponentDataPolyVertex;
  end;

  TScene2DComponentDataPolyLayer = class
  private
    var _Texture: TG2Texture2DBase;
    procedure SetTexture(const Value: TG2Texture2DBase);
  public
    property Texture: TG2Texture2DBase read _Texture write SetTexture;
    var TexturePath: String;
    var Scale: TG2Vec2;
    var Layer: TG2IntS32;
    var PathProp: TPropertySet.TPropertyPath;
    var ScaleProp: TPropertySet.TPropertyVec2;
    var LayerProp: TPropertySet.TPropertyInt;
    var Index: TG2IntS32;
    constructor Create;
  end;

  TScene2DComponentDataPoly = class (TScene2DComponentData)
  private
    var Group: TPropertySet.TPropertyComponent;
    var Vertices: TScene2DComponentDataPolyVertexList;
    var Edges: TScene2DComponentDataPolyEdgeList;
    var Faces: TScene2DComponentDataPolyFaceList;
    var Layers: TScene2DComponentDataPolyLayerList;
    function FindEdge(const v0, v1: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyEdge;
    function FindFace(const v0, v1, v2: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyFace;
    procedure UpdateGroup;
    procedure UpdateComponent;
  public
    var Component: TG2Scene2DComponentPoly;
    class function GetName: String; override;
    constructor Create; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnAddLayer;
    procedure OnEdit;
    procedure GenerateData;
    procedure CompleteData;
    procedure Clear;
    procedure OnChangeLayerTexture(const Sender: Pointer);
    procedure OnChangeParam(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataPoly END

//TScene2DComponentDataEffect BEIGN
  TScene2DComponentDataEffect = class (TScene2DComponentData)
  private
    var Layer: TG2IntS32;
    var Scale: TG2Float;
    var Speed: TG2Float;
    var Repeating: Boolean;
    var LocalSpace: Boolean;
    var FixedOrientation: Boolean;
    var EffectPath: String;
  public
    var Component: TG2Scene2DComponentEffect;
    class function GetName: String; override;
    destructor Destroy; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeLayer(const Sender: Pointer);
    procedure OnChangeScale(const Sender: Pointer);
    procedure OnChangeSpeed(const Sender: Pointer);
    procedure OnChangeRepeating(const Sender: Pointer);
    procedure OnChangeLocalSpace(const Sender: Pointer);
    procedure OnChangeFixedOrientation(const Sender: Pointer);
    procedure OnChangeEffect(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
    procedure OnPlay;
    procedure OnStop;
  end;
//TScene2DComponentDataEffect END

//TScene2DComponentDataRigidBody BEGIN
  TScene2DComponentDataRigidBody = class (TScene2DComponentData)
  private
    var _Position: TG2Vec2;
    var _Rotation: TG2Float;
    var _LinearDamping: TG2Float;
    var _AngularDamping: TG2Float;
    var _FixedRotation: Boolean;
    var _BodyType: TG2Scene2DComponentRigidBodyType;
  public
    var Component: TG2Scene2DComponentRigidBody;
    class function GetName: String; override;
    destructor Destroy; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    function GetLocalPoint(const WorldPoint: TG2Vec2): TG2Vec2;
    function GetWorldPoint(const LocalPoint: TG2Vec2): TG2Vec2;
    procedure OnChangePosition(const Sender: Pointer);
    procedure OnChangeRotation(const Sender: Pointer);
    procedure OnChangeLinearDamping(const Sender: Pointer);
    procedure OnChangeAngularDamping(const Sender: Pointer);
    procedure OnChangeFixedRotation(const Sender: Pointer);
    procedure OnChangeBodyType(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataRigidBody END

//TScene2DComponentDataCharacter BEGIN
  TScene2DComponentDataCharacter = class (TScene2DComponentData)
  public
    var Component: TG2Scene2DComponentCharacter;
    class function GetName: String; override;
    destructor Destroy; override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure DebugDraw(const Display: TG2Display2D); override;
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataCharacter END

//TScene2DComponentDataShapePoly BEGIN
  TScene2DComponentDataShapePoly = class (TScene2DComponentData)
  private
    var _Friction: TG2Float;
    var _Density: TG2Float;
    var _Restitution: TG2Float;
    var _Sensor: Boolean;
  public
    var Component: TG2Scene2DComponentCollisionShapePoly;
    class function GetName: String; override;
    constructor Create; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeFriction(const Sender: Pointer);
    procedure OnChangeDensity(const Sender: Pointer);
    procedure OnChangeRestitution(const Sender: Pointer);
    procedure OnChangeSensor(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
    procedure OnEdit;
  end;
//TScene2DComponentDataShapePoly END

//TScene2DComponentDataShapeBox BEGIN
  TScene2DComponentDataShapeBox = class (TScene2DComponentData)
  private
    var _Offset: TG2Vec2;
    var _Angle: TG2Float;
    var _Width: TG2Float;
    var _Height: TG2Float;
    var _Friction: TG2Float;
    var _Density: TG2Float;
    var _Restitution: TG2Float;
    var _Sensor: Boolean;
  public
    var Component: TG2Scene2DComponentCollisionShapeBox;
    class function GetName: String; override;
    constructor Create; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeWidth(const Sender: Pointer);
    procedure OnChangeHeight(const Sender: Pointer);
    procedure OnChangeOffset(const Sender: Pointer);
    procedure OnChangeAngle(const Sender: Pointer);
    procedure OnChangeFriction(const Sender: Pointer);
    procedure OnChangeDensity(const Sender: Pointer);
    procedure OnChangeRestitution(const Sender: Pointer);
    procedure OnChangeSensor(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataShapeBox END

//TScene2DComponentDataShapeCircle BEGIN
  TScene2DComponentDataShapeCircle = class (TScene2DComponentData)
  private
    var _Offset: TG2Vec2;
    var _Radius: TG2Float;
    var _Friction: TG2Float;
    var _Density: TG2Float;
    var _Restitution: TG2Float;
    var _Sensor: Boolean;
  public
    var Component: TG2Scene2DComponentCollisionShapeCircle;
    class function GetName: String; override;
    destructor Destroy; override;
    function PickLayer: Integer; override;
    function Pick(const x, y: TG2Float): Boolean; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnChangeOffset(const Sender: Pointer);
    procedure OnChangeRadius(const Sender: Pointer);
    procedure OnChangeFriction(const Sender: Pointer);
    procedure OnChangeDensity(const Sender: Pointer);
    procedure OnChangeRestitution(const Sender: Pointer);
    procedure OnChangeSensor(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataShapeCircle END

//TScene2DComponentDataShapeEdge BEGIN
  TScene2DComponentDataShapeEdge = class (TScene2DComponentData)
  private
    var _Friction: TG2Float;
    var _Density: TG2Float;
    var _Restitution: TG2Float;
    var _Sensor: Boolean;
  public
    var Component: TG2Scene2DComponentCollisionShapeEdge;
    class function GetName: String; override;
    constructor Create; override;
    destructor Destroy; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnEdit;
    procedure OnChangeFriction(const Sender: Pointer);
    procedure OnChangeDensity(const Sender: Pointer);
    procedure OnChangeRestitution(const Sender: Pointer);
    procedure OnChangeSensor(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataShapeEdge END

//TScene2DComponentDataShapeChain BEGIN
  TScene2DComponentDataShapeChain = class (TScene2DComponentData)
  private
    var _Friction: TG2Float;
    var _Density: TG2Float;
    var _Restitution: TG2Float;
    var _Sensor: Boolean;
  public
    var Component: TG2Scene2DComponentCollisionShapeChain;
    class function GetName: String; override;
    constructor Create; override;
    destructor Destroy; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
    procedure AddToProperties(const PropertySet: TPropertySet); override;
    procedure OnEdit;
    procedure OnChangeFriction(const Sender: Pointer);
    procedure OnChangeDensity(const Sender: Pointer);
    procedure OnChangeRestitution(const Sender: Pointer);
    procedure OnChangeSensor(const Sender: Pointer);
    procedure OnTagsChange(const Sender: Pointer);
  end;
//TScene2DComponentDataShapeChain END

//TScene2DJointData BEGIN
  TScene2DJointData = class
  protected
    var _Joint: TG2Scene2DJoint;
    var _Position: TG2Vec2;
    function GetEditor: TScene2DEditor; virtual;
    function GetPosition: TG2Vec2; virtual;
    procedure SetPosition(const Value: TG2Vec2); virtual;
  public
    property Position: TG2Vec2 read GetPosition write SetPosition;
    property Editor: TScene2DEditor read GetEditor;
    constructor Create; virtual;
    destructor Destroy; override;
    procedure DebugDraw(const Display: TG2Display2D); virtual;
    function IsSelected: Boolean; inline;
    function Select(const Display: TG2Display2D; const x, y: TG2Float): Boolean; virtual;
    procedure AddToProperties(const PropertySet: TPropertySet); virtual;
  end;
//TScene2DJointData END

//TScene2DJointDataDistance BEIGN
  TScene2DJointDataDistance = class (TScene2DJointData)
  private
    function GetJoint: TG2Scene2DDistanceJoint; inline;
    procedure SetJoint(const Value: TG2Scene2DDistanceJoint); inline;
    function GetRigidBodyA: TScene2DComponentDataRigidBody;
    procedure SetRigidBodyA(const Value: TScene2DComponentDataRigidBody);
    function GetRigidBodyB: TScene2DComponentDataRigidBody;
    procedure SetRigidBodyB(const Value: TScene2DComponentDataRigidBody);
    function GetAnchorA: TG2Vec2; inline;
    procedure SetAnchorA(const Value: TG2Vec2); inline;
    function GetAnchorB: TG2Vec2; inline;
    procedure SetAnchorB(const Value: TG2Vec2); inline;
  protected
    function GetEditor: TScene2DEditor; override;
  public
    property Joint: TG2Scene2DDistanceJoint read GetJoint write SetJoint;
    property RigidBodyA: TScene2DComponentDataRigidBody read GetRigidBodyA write SetRigidBodyA;
    property RigidBodyB: TScene2DComponentDataRigidBody read GetRigidBodyB write SetRigidBodyB;
    property AnchorA: TG2Vec2 read GetAnchorA write SetAnchorA;
    property AnchorB: TG2Vec2 read GetAnchorB write SetAnchorB;
    constructor Create; override;
    destructor Destroy; override;
    function Select(const Display: TG2Display2D; const x, y: TG2Float): Boolean; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
  end;
//TScene2DJointDataDistance END

//TScene2DJointDataRevolute BEGIN
  TScene2DJointDataRevolute = class (TScene2DJointData)
  private
    function GetJoint: TG2Scene2DRevoluteJoint;
    procedure SetJoint(const Value: TG2Scene2DRevoluteJoint);
    function GetRigidBodyA: TScene2DComponentDataRigidBody;
    procedure SetRigidBodyA(const Value: TScene2DComponentDataRigidBody);
    function GetRigidBodyB: TScene2DComponentDataRigidBody;
    procedure SetRigidBodyB(const Value: TScene2DComponentDataRigidBody);
    function GetAnchor: TG2Vec2; inline;
    procedure SetAnchor(const Value: TG2Vec2); inline;
  protected
    function GetPosition: TG2Vec2; override;
    procedure SetPosition(const Value: TG2Vec2); override;
    function GetEditor: TScene2DEditor; override;
  public
    property Joint: TG2Scene2DRevoluteJoint read GetJoint write SetJoint;
    property RigidBodyA: TScene2DComponentDataRigidBody read GetRigidBodyA write SetRigidBodyA;
    property RigidBodyB: TScene2DComponentDataRigidBody read GetRigidBodyB write SetRigidBodyB;
    property Anchor: TG2Vec2 read GetAnchor write SetAnchor;
    constructor Create; override;
    destructor Destroy; override;
    function Select(const Display: TG2Display2D; const x, y: TG2Float): Boolean; override;
    procedure DebugDraw(const Display: TG2Display2D); override;
  end;
//TScene2DJointDataRevolute END

//TScene2DData BEGIN
  TComponentTypePair = record
    Component: CG2Scene2DComponent;
    ComponentData: CScene2DComponentData;
    AddProc: TG2ProcObj;
  end;
  PComponentTypePair = ^TComponentTypePair;
  TComponentList = specialize TG2QuickListG<PComponentTypePair>;

  TScene2DData = object
  private
    var _GridSizeX: TG2Float;
    var _GridSizeY: TG2Float;
    var _PropGravity: TG2Vec2;
    var _SavedStream: TMemoryStream;
    var _Scene: TG2Scene2D;
    var _PropertySet: TPropertySet;
    var _ComponentSet: TPropertySet;
    var _Editor: TScene2DEditor;
    procedure UpdateProperties;
    procedure AddComponentTypePair(const ComponentClass: CG2Scene2DComponent; const ComponentDataClass: CScene2DComponentData; const AddProc: TG2ProcObj);
    procedure SetEditor(const Value: TScene2DEditor); inline;
    procedure OnGravityChange(const Sender: Pointer);
    procedure OnGridSizeXChange(const Sender: Pointer);
    procedure OnGridSizeYChange(const Sender: Pointer);
    procedure FindSelectedJoints(var JointList: TG2Scene2DJointList);
  public
    var ComponentList: TComponentList;
    var Selection: TG2Scene2DEntityList;
    var SelectJoint: TScene2DJointData;
    var sxf: TG2Transform2;
    var SceneProperties: TPropertySet;
    var ScenePath: String;
    property PropertySet: TPropertySet read _PropertySet write _PropertySet;
    property Scene: TG2Scene2D read _Scene write _Scene;
    property Editor: TScene2DEditor read _Editor write SetEditor;
    function FindEntity(const Name: AnsiString; const IgnoreEntity: TG2Scene2DEntity = nil): TG2Scene2DEntity;
    function CreateEntity(const Transform: TG2Transform2): TG2Scene2DEntity;
    procedure DeleteEntity(var Entity: TG2Scene2DEntity);
    procedure CopySelectedEntity;
    procedure PasteEntity(const Pos: TG2Vec2);
    procedure SavePrefab;
    function CreatePrefab(const Transform: TG2Transform2; const PrefabName: String): TG2Scene2DEntity;
    procedure CreateEntityData(const Entity: TG2Scene2DEntity);
    procedure CreateJointData(const Joint: TG2Scene2DJoint);
    procedure VerifyEntityName(const Entity: TG2Scene2DEntity);
    function CreateJointDistance(const Position: TG2Vec2): TG2Scene2DDistanceJoint;
    function CreateJointRevolute(const Position: TG2Vec2): TG2Scene2DRevoluteJoint;
    procedure DeleteJoint(var Joint: TG2Scene2DJoint);
    function CreateComponentSprite: TG2Scene2DComponentSprite;
    function CreateComponentText: TG2Scene2DComponentText;
    function CreateComponentBackground: TG2Scene2DComponentBackground;
    function CreateComponentSpineAnimation: TG2Scene2DComponentSpineAnimation;
    function CreateComponentEffect: TG2Scene2DComponentEffect;
    function CreateComponentRigidBody: TG2Scene2DComponentRigidBody;
    function CreateComponentCharacter: TG2Scene2DComponentCharacter;
    function CreateComponentShapePoly: TG2Scene2DComponentCollisionShapePoly;
    function CreateComponentShapeBox: TG2Scene2DComponentCollisionShapeBox;
    function CreateComponentShapeCircle: TG2Scene2DComponentCollisionShapeCircle;
    function CreateComponentShapeEdge: TG2Scene2DComponentCollisionShapeEdge;
    function CreateComponentShapeChain: TG2Scene2DComponentCollisionShapeChain;
    function CreateComponentPoly: TG2Scene2DComponentPoly;
    function Pick(const ScenePos: TG2Vec2): TG2Scene2DEntity;
    procedure DeleteComponent(var Component: TG2Scene2DComponent);
    procedure SelectionUpdateStart;
    procedure SelectionUpdateEnd;
    procedure UpdateSelectionPos;
    procedure BtnAddComponent;
    procedure BtnComponentSprite;
    procedure BtnComponentText;
    procedure BtnComponentBackground;
    procedure BtnComponentSpineAnimation;
    procedure BtnComponentEffect;
    procedure BtnComponentRigidBody;
    procedure BtnComponentCharacter;
    procedure BtnComponentShapePoly;
    procedure BtnComponentShapeBox;
    procedure BtnComponentShapeCircle;
    procedure BtnComponentShapeEdge;
    procedure BtnComponentShapeChain;
    procedure BtnComponentPoly;
    procedure BtnComponentCancel;
    procedure LoadScene(const SceneName: String);
    procedure ClearScene;
    procedure Simulate;
    procedure OnLoad;
    procedure Initialize;
    procedure Finalize;
    procedure KeyDown(const Key: Integer);
    procedure KeyUp(const Key: Integer);
    procedure Update;
    procedure MouseClick(const Display: TG2Display2D; const Button: Integer; const x, y: TG2Float);
    procedure Render(const Display: TG2Display2D);
  end;
//TScene2DData END

//TAsset BEGIN
  TAsset = class
  private
    var _Ref: Integer;
    var Prev: TAsset;
    var Next: TAsset;
    var _md5: TG2MD5;
    var _Path: String;
  protected
    procedure OnInitialize; virtual;
    procedure OnFinalize; virtual;
  public
    class var List: TAsset;
    property md5: TG2MD5 read _md5 write _md5;
    property Ref: Integer read _Ref;
    property Path: String read _Path;
    class constructor CreateClass;
    class destructor DestroyClass;
    class function GetAssetName: String; virtual;
    class function CheckExtension(const Ext: String): Boolean; virtual;
    class function ProcessFile(const FilePath: String): TG2QuickListString; virtual;
    constructor Create(const FileName: String);
    destructor Destroy; override;
    procedure RefInc; inline;
    procedure RefDec; inline;
  end;
//TAsset END

//TAssetAny BEGIN
  TAssetAny = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
  end;
//TAssetAny END

//TAssetTexture BEGIN
  TAssetTexture = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
    class function ProcessFile(const FilePath: String): TG2QuickListString; override;
  end;
//TAssetTexture END

//TAssetImage BEGIN
  TAssetImage = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
    class function ProcessFile(const FilePath: String): TG2QuickListString; override;
  end;
//TAssetImage END

//TAssetImage BEGIN
  TAssetFont = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
    class function ProcessFile(const FilePath: String): TG2QuickListString; override;
  end;
//TAssetImage END

//TAssetEffect2D BEGIN
  TAssetEffect2D = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
    class function ProcessFile(const FilePath: String): TG2QuickListString; override;
  end;
//TAssetEffect2D END

//TAssetScene2D BEGIN
  TAssetScene2D = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
    class function ProcessFile(const FilePath: String): TG2QuickListString; override;
  end;
//TAssetScene2D END

//TAssetPrefab2D BEGIN
  TAssetPrefab2D = class (TAsset)
  public
    class function GetAssetName: String; override;
    class function CheckExtension(const Ext: String): Boolean; override;
    class function ProcessFile(const FilePath: String): TG2QuickListString; override;
  end;
//TAssetPrefab2D END

//TAssetManager BEGIN
  TAssetManager = object
  private
    type TAssetData = record
      Path: String;
      Asset: TAsset;
    end;
    type PAssetData = ^TAssetData;
    type TAssetDataList = specialize TG2QuickListG<PAssetData>;
    type TAssetPath = record
      Path: String;
      Assets: TAssetDataList;
    end;
    type PAssetPath = ^TAssetPath;
    type TAssetPathList = specialize TG2QuickListG<PAssetPath>;
    var _AssetPaths: TAssetPathList;
    function VerifyPath(const Path: String): String;
  public
    function GetTexture(const Path: String): TG2Texture2D;
    function GetFont(const Path: String): TG2Font;
    function GetImage(const Path: String): TG2Picture;
    function GetEffect(const Path: String): TG2Effect2D;
    procedure Initialize;
    procedure Finalize;
    procedure Update;
  end;
//TAssetManager END

//TCodeInsightSymbol BEGIN
  TCodeInsightSymbolList = specialize TG2QuickListG<TCodeInsightSymbol>;
  TCodeInsightSymbolType = (stNone, stFile, stFileLink);
  TCodeInsightSymbol = class
  private
    var _Path: String;
    var _LineInterface: Integer;
    var _LineImplementation: Integer;
  protected
    procedure SetPath(const Value: String); virtual;
  public
    SymbolType: TCodeInsightSymbolType;
    Name: AnsiString;
    Children: TCodeInsightSymbolList;
    property Path: String read _Path write SetPath;
    property LineInterface: Integer read _LineInterface write _LineInterface;
    property LineImplementation: Integer read _LineImplementation write _LineImplementation;
    constructor Create;
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    procedure Clear; virtual;
    function FindChild(const ChildName: String): TCodeInsightSymbol;
  end;
//TCodeInsightSymbol END

//TCodeInsightSymbolFile BEGIN
  TCodeInsightSymbolFile = class (TCodeInsightSymbol)
  private
    _Modified: Boolean;
    _ModifiedTime: TG2IntU32;
    _ParsedTime: TG2IntU32;
    procedure SetModified(const Value: Boolean);
  public
    property Modified: Boolean read _Modified write SetModified;
    property ModifiedTime: TG2IntU32 read _ModifiedTime;
    property ParsedTime: TG2IntU32 read _ParsedTime write _ParsedTime;
    procedure Initialize; override;
    procedure Finalize; override;
  end;
//TCodeInsightSymbolFile END

//TCodeInsightSymbolFileLink BEGIN
  TCodeInsightSymbolFileLink = class (TCodeInsightSymbol)
  public
    procedure Initialize; override;
    procedure Finalize; override;
  end;
//TCodeInsightSymbolFile END

//TCodeInsightScanThread BEGIN
  TCodeInsightScanThread = class (TG2Thread)
  protected
    procedure Execute; override;
  public
    var FileSymbol: TCodeInsightSymbolFile;
  end;
//TCodeInsightScanThread END

//TCodeInsight BEGIN
  TCodeInsight = object
  private
    var _SearchPaths: array of String;
    var _Root: TCodeInsightSymbolFile;
    var _Files: TCodeInsightSymbolList;
    var _Parser: TG2Parser;
    var _CurCodeFile: PCodeFile;
    var _ScanThread: TCodeInsightScanThread;
    function SearchFile(const f: String): String;
    function FileLoaded(const f: String): Boolean;
    function FilesToParse: Integer;
  public
    property CurCodeFile: PCodeFile read _CurCodeFile write _CurCodeFile;
    property Root: TCodeInsightSymbolFile read _Root;
    procedure Initialize;
    procedure Finalize;
    procedure Update;
    procedure AddSearchPath(const Path: String);
    procedure Clear;
    procedure ScanFile(const f: TCodeInsightSymbolFile);
    procedure Scan;
    function FindFile(const Path: String): TCodeInsightSymbolFile;
    function FindSymbol(const Path: String): TCodeInsightSymbol;
  end;
//TCodeInsight END

//TG2Toolkit BEGIN
  TG2Toolkit = object
  public
    var UI: TUI;
    var Project: TProject;
    var Log: TLog;
    var Console: TConsole;
    var AtlasPackerData: TAtlasPackerData;
    var ParticleData: TParticleData;
    var Scene2DData: TScene2DData;
    var CodeInsight: TCodeInsight;
    var AssetManager: TAssetManager;
    var cbf_scene2d_object: TClipboardFormat;
    procedure Initialize;
    procedure Finalize;
    procedure Update;
    procedure Render;
    procedure KeyDown(const Key: Integer);
    procedure KeyUp(const Key: Integer);
    procedure MouseDown(const Button, x, y: Integer);
    procedure MouseUp(const Button, x, y: Integer);
    procedure Scroll(const y: Integer);
    procedure Print(const Char: AnsiChar);
    procedure Resize(const OldWidth, OldHeight, NewWidth, NewHeight: Integer);
    function LoadFile(const f: String): AnsiString;
  end;
//TG2Toolkit END

var App: TG2Toolkit;

implementation

const FloatPrintFormat = '0.0####';

function G2ColorToSysColor(const c: TG2Color): LongWord;
begin
  Result := c.r or (c.g shl 8) or (c.b shl 16);
end;

function SysColorToG2Color(const c: LongWord): TG2Color;
begin
  Result.r := c and $ff;
  Result.g := (c shr 8) and $ff;
  Result.b := (c shr 16) and $ff;
  Result.a := $ff
end;

//TScrollBox BEGIN
function TScrollBox.GetSliderRect: TG2Rect;
  var vs: Single;
begin
  case _Orientation of
    sbVertical:
    begin
      vs := (ParentSize / ContentSize) * (Frame.h - 4);
      if vs < 16 then vs := G2Min(16, Frame.h - 4);
      if vs < 0 then vs := 0;
      Result.l := Frame.x + 2;
      Result.t := Frame.y + 2 + _Pos * (Frame.h - 4 - vs);
      Result.r := Frame.r - 2;
      Result.h := vs;
    end;
    sbHorizontal:
    begin
      vs := (ParentSize / ContentSize) * (Frame.w - 4);
      if vs < 16 then vs := G2Min(16, Frame.w - 4);
      if vs < 0 then vs := 0;
      Result.t := Frame.y + 2;
      Result.l := Frame.x + 2 + _Pos * (Frame.w - 4 - vs);
      Result.b := Frame.b - 2;
      Result.w := vs;
    end;
  end;
end;

function TScrollBox.GetPosAbsolute: Single;
begin
  if ContentSize > ParentSize then
  Result := (ContentSize - ParentSize) * _Pos
  else
  Result := 0;
end;

procedure TScrollBox.SetPosAbsolute(const Value: Single);
  var d: Single;
begin
  d := ContentSize - ParentSize;
  if d > 0 then
  _Pos := Value / d
  else
  _Pos := 0;
  if _Pos < 0 then _Pos := 0;
end;

procedure TScrollBox.Initialize;
begin
  _Pos := 0;
  _MDown := False;
  _Orientation := sbVertical;
end;

procedure TScrollBox.Render;
  var c: TG2Color;
  var r: TG2Rect;
begin
  g2.PrimRect(Frame.x, Frame.y, Frame.w, Frame.h, App.UI.GetColorPrimary(0.1));
  if _ContentSize > _ParentSize then
  begin
    r := GetSliderRect;
    if (r.h > 0) and (r.w > 0) then
    begin
      if _MDown or r.Contains(g2.MousePos) then
      c := App.UI.GetColorPrimary(0.6)
      else
      c := App.UI.GetColorPrimary(0.4);
      g2.PrimRect(r.x, r.y, r.w, r.h, c);
    end;
  end;
end;

procedure TScrollBox.Update;
  var x, y: Single;
  var r: TG2Rect;
begin
  if _ContentSize > _ParentSize then
  begin
    if _MDown then
    begin
      if not g2.MouseDown[G2MB_Left] then
      _MDown := False
      else
      begin
        case _Orientation of
          sbVertical:
          begin
            y := g2.MousePos.y + _MDPos;
            r := GetSliderRect;
            _Pos := (y - (Frame.t + 2)) / (Frame.h - 4 - r.h);
            if _Pos < 0 then
            _Pos := 0
            else if _Pos > 1 then
            _Pos := 1;
          end;
          sbHorizontal:
          begin
            x := g2.MousePos.x + _MDPos;
            r := GetSliderRect;
            _Pos := (x - (Frame.l + 2)) / (Frame.w - 4 - r.w);
            if _Pos < 0 then
            _Pos := 0
            else if _Pos > 1 then
            _Pos := 1;
          end;
        end;
        if Assigned(_ProcOnChange) then
        _ProcOnChange;
      end;
    end;
  end
  else
  _Pos := 0;
end;

procedure TScrollBox.MouseDown(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  if _ContentSize > _ParentSize then
  begin
    r := GetSliderRect;
    if r.Contains(x, y) then
    begin
      _MDown := True;
      case _Orientation of
        sbVertical: _MDPos := r.y - y;
        sbHorizontal: _MDPos := r.x - x;
      end;
    end;
  end;
end;

procedure TScrollBox.MouseUp(const Button, x, y: Integer);
begin
  _MDown := False;
  if _ContentSize > _ParentSize then
  begin
    if Assigned(_ProcOnChange) then
    _ProcOnChange;
  end;
end;

procedure TScrollBox.Scroll(const Amount: Integer);
begin
  PosAbsolute := G2Min(PosAbsolute - Amount, ContentSize - ParentSize);
  if PosAbsolute < 0 then
  PosAbsolute := 0;
  if Assigned(_ProcOnChange) then
  _ProcOnChange;
end;
//TScrollBox END

//TOverlayObject BEGIN
procedure TOverlayObject.Render;
begin

end;

procedure TOverlayObject.Update;
begin

end;

procedure TOverlayObject.MouseDown(const Button, x, y: Integer);
begin

end;

procedure TOverlayObject.MouseUp(const Button, x, y: Integer);
begin

end;

procedure TOverlayObject.Scroll(const y: Integer);
begin

end;

constructor TOverlayObject.Create;
begin

end;

destructor TOverlayObject.Destroy;
begin
  if App.UI.Overlay = Self then App.UI.Overlay := nil;
end;
//TOverlayObject END

//TOverlayWorkspaceList BEGIN
constructor TOverlayWorkspaceList.Create;
begin
  inherited Create;
  Clear;
end;

destructor TOverlayWorkspaceList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TOverlayWorkspaceList.LoadWorkspaces;
  procedure InitializeFolder(const Folder: TWorkspaceListItemPath);
    var i: Integer;
    var Size: TG2Vec2;
    var w: TG2Float;
  begin
     Size.y := App.UI.Font1.TextHeight('A') + 16;
     Size.x := 0;
     for i := 0 to Folder.Items.Count - 1 do
     begin
       TWorkspaceListItem(Folder.Items[i]).ParentList := @Folder.Items;
       w := App.UI.Font1.TextWidth(TWorkspaceListItem(Folder.Items[i]).Name) + 64;
       if w > Size.x then Size.x := w;
       if TWorkspaceListItem(Folder.Items[i]) is TWorkspaceListItemPath then
       InitializeFolder(TWorkspaceListItemPath(Folder.Items[i]));
     end;
     if Folder = _Root then
     Folder.Size := Size;
     for i := 0 to Folder.Items.Count - 1 do
     TWorkspaceListItem(Folder.Items[i]).Size := Size;
  end;
  var i, j, n: Integer;
  var c: TUIWorkspaceConstructor;
  var ListItem: TWorkspaceListItemConstructor;
  var Path: AnsiString;
  var PathArr: TG2StrArrA;
  var Folder, ParentFolder: TWorkspaceListItemPath;
  var FolderFound: Boolean;
begin
  Clear;
  _Root := TWorkspaceListItemPath.Create;
  _Root.Items.Clear;
  _Root.Name := 'Root';
  _Root.Open := False;
  for i := 0 to App.UI.WorkspaceClasses.Count - 1 do
  begin
    c := App.UI.WorkspaceClasses[i];
    Path := c.WorkspaceClass.GetWorkspacePath;
    ListItem := TWorkspaceListItemConstructor.Create;
    ListItem.Name := c.GetName;
    ListItem.WorkspaceClassConstructor := c;
    if Length(Path) = 0 then
    begin
      _Root.Items.Add(ListItem);
    end
    else
    begin
      ParentFolder := _Root;
      Folder := _Root;
      PathArr := G2StrExplode(Path, '/');
      for n := 0 to High(PathArr) do
      begin
        FolderFound := False;
        for j := 0 to ParentFolder.Items.Count - 1 do
        if (TWorkspaceListItem(ParentFolder.Items[j]) is TWorkspaceListItemPath)
        and (TWorkspaceListItem(ParentFolder.Items[j]).Name = PathArr[n]) then
        begin
          FolderFound := True;
          Folder := TWorkspaceListItemPath(ParentFolder.Items[j]);
        end;
        if not FolderFound then
        begin
          Folder := TWorkspaceListItemPath.Create;
          Folder.Name := PathArr[n];
          Folder.Items.Clear;
          ParentFolder.Items.Add(Folder);
        end;
        ParentFolder := Folder;
      end;
      Folder.Items.Add(ListItem);
    end;
  end;
  InitializeFolder(_Root);
end;

procedure TOverlayWorkspaceList.Initialize(const NewPos: TG2Vec2);
  var i: Integer;
  var CurPos: TG2Vec2;
  var Item: TWorkspaceListItem;
begin
  CurPos := NewPos;
  CurPos.x := CurPos.x - _Root.Size.x * 0.5;
  if CurPos.x + _Root.Size.x > g2.Params.Width then
  CurPos.x := g2.Params.Width - _Root.Size.x;
  if CurPos.x < 0 then CurPos.x := 0;
  for i := 0 to _Root.Items.Count - 1 do
  begin
     Item := TWorkspaceListItem(_Root.Items[i]);
     Item.Pos := CurPos;
     CurPos.y := CurPos.y + Item.Size.y;
     if Item is TWorkspaceListItemPath then
     TWorkspaceListItemPath(Item).Open := False;
  end;
  _Root.Open := True;
end;

procedure TOverlayWorkspaceList.Clear;
  procedure FreeItem(const Item: TWorkspaceListItem);
    var i: Integer;
  begin
    if Item is TWorkspaceListItemPath then
    for i := 0 to TWorkspaceListItemPath(Item).Items.Count - 1 do
    FreeItem(TWorkspaceListItem(TWorkspaceListItemPath(Item).Items[i]));
    Item.Free;
  end;
begin
  if _Root <> nil then
  FreeItem(_Root);
  _Root := nil;
end;

procedure TOverlayWorkspaceList.Render;
  procedure RenderFolder(const Folder: TWorkspaceListItemPath);
    var i: Integer;
    var r: TG2Rect;
    var rs, rx: TG2Float;
    var Item: TWorkspaceListItem;
    var c: TG2Color;
  begin
    rs := App.UI.Font1.TextHeight('A') + 12;
    rx := (32 - rs) * 0.5;
    for i := 0 to Folder.Items.Count - 1 do
    begin
      Item := TWorkspaceListItem(Folder.Items[i]);
      g2.PrimRectCol(
        Item.Pos.x, Item.Pos.y, Item.Size.x, Item.Size.y,
        App.UI.GetColorPrimary(0.8), App.UI.GetColorPrimary(0.8),
        App.UI.GetColorPrimary(0.5), App.UI.GetColorPrimary(0.5)
      );
      App.UI.Font1.Print(
        Item.Pos.x + (Item.Size.x - App.UI.Font1.TextWidth(Item.Name)) * 0.5,
        Item.Pos.y + (Item.Size.y - App.UI.Font1.TextHeight('A')) * 0.5,
        1, 1, App.UI.GetColorPrimary(1), Item.Name, bmNormal, tfPoint
      );
      if Item is TWorkspaceListItemConstructor then
      begin
        r.l := Item.Pos.x + rx;
        r.t := Item.Pos.y + (Item.Size.y - rs) * 0.5;
        r.w := rs; r.h := rs;
        App.UI.DrawCircles(r, App.UI.GetColorPrimary(1));
        r.x := Item.Pos.x + Item.Size.x - rx - rs;
        App.UI.DrawCircles(r, App.UI.GetColorPrimary(1));
      end
      else if Item is TWorkspaceListItemPath then
      begin
        if TWorkspaceListItemPath(Item).Open then
        c := App.UI.GetColorSecondary(0.8)
        else
        c := App.UI.GetColorPrimary(0.9);
        g2.PrimTriCol(
          Item.Pos.x + Item.Size.x - 22, Item.Pos.y + Item.Size.y * 0.5 - 10,
          Item.Pos.x + Item.Size.x - 6, Item.Pos.y + Item.Size.y * 0.5,
          Item.Pos.x + Item.Size.x - 22, Item.Pos.y  + Item.Size.y * 0.5 + 10,
          c, c, c
        );
      end;
    end;
    for i := 0 to Folder.Items.Count - 1 do
    if (TWorkspaceListItem(Folder.Items[i]) is TWorkspaceListItemPath)
    and (TWorkspaceListItemPath(Folder.Items[i]).Open) then
    begin
      RenderFolder(TWorkspaceListItemPath(Folder.Items[i]));
    end;
  end;
begin
  RenderFolder(_Root);
end;

procedure TOverlayWorkspaceList.Update;
begin

end;

procedure TOverlayWorkspaceList.MouseDown(const Button, x, y: Integer);
  function ClickFolder(const Folder: TWorkspaceListItemPath): Boolean;
    var i, j: Integer;
    var p, s: TG2Vec2;
    var f: TWorkspaceListItemPath;
    var Item: TWorkspaceListItem;
  begin
    Result := False;
    for i := 0 to Folder.Items.Count - 1 do
    if TWorkspaceListItem(Folder.Items[i]) is TWorkspaceListItemPath then
    begin
      f := TWorkspaceListItemPath(Folder.Items[i]);
      if f.Open then
      begin
        Result := ClickFolder(f);
        if Result then Exit;
      end;
    end;
    for i := 0 to Folder.Items.Count - 1 do
    begin
      Item := TWorkspaceListItem(Folder.Items[i]);
      if G2Rect(Item.Pos.x, Item.Pos.y, Item.Size.x, Item.Size.y).Contains(x, y) then
      begin
        if Item is TWorkspaceListItemConstructor then
        begin
          App.UI.OverlayWorkspace.Workspace := TWorkspaceListItemConstructor(Item).WorkspaceClassConstructor.WorkspaceClass.Create;
          TWorkspaceListItemConstructor(Item).WorkspaceClassConstructor.OnCreateWorkspace(App.UI.OverlayWorkspace.Workspace);
          App.UI.Overlay := App.UI.OverlayWorkspace;
          Result := True;
          Exit;
        end
        else if Item is TWorkspaceListItemPath then
        begin
          f := TWorkspaceListItemPath(Item);
          f.Open := not f.Open;
          if f.Open then
          begin
            for j := 0 to Item.ParentList^.Count - 1 do
            begin
              if (TWorkspaceListItem(Item.ParentList^[j]) is TWorkspaceListItemPath)
              and (TWorkspaceListItemPath(Item.ParentList^[j]) <> f) then
              TWorkspaceListItemPath(Item.ParentList^[j]).Open := False;
            end;
            p := f.Pos; p.x := p.x + f.Size.x;
            if f.Items.Count > 0 then s := TWorkspaceListItem(f.Items[0]).Size else s.SetZero;
            if p.x + s.x > g2.Params.Width then p.x := f.Pos.x - s.x;
            if p.x < 0 then p.x := 0;
            if p.y + s.y * f.Items.Count > g2.Params.Height then p.y := g2.Params.Height - s.y * f.Items.Count;
            for j := 0 to f.Items.Count - 1 do
            begin
              TWorkspaceListItem(f.Items[j]).Pos := p;
              p.y := p.y + s.y;
            end;
          end;
        end;
        Result := True;
        Exit;
      end;
    end;
  end;
begin
  if not ClickFolder(_Root) then App.UI.Overlay := nil;
end;

procedure TOverlayWorkspaceList.MouseUp(const Button, x, y: Integer);
begin

end;
//TOverlayWorkspaceList END

//TOverlayWorkspace BEGIN
procedure TOverlayWorkspace.SetWorkspace(const Value: TUIWorkspace);
begin
  _Workspace := Value;
  _Size.x := App.UI.Font1.TextWidth(_Workspace.GetWorkspaceName) + 64;
  _Size.y := App.UI.Font1.TextHeight('A') + 16;
end;

procedure TOverlayWorkspace.Render;
  var mc: TPoint;
  var View: PView;
  var w: TUIWorkspace;
  var InsertPos: TUIWorkspaceInsertPosition;
  var y, rx, rs: Single;
  var r: TG2Rect;
  var Str: AnsiString;
begin
  mc := g2.MousePos;

  View := App.UI.Views.CurView;
  if View <> nil then
  begin
    w := App.UI.Views.FindFrameWorkpace(mc.x, mc.y);
    if (w <> nil) then
    begin
      InsertPos := TUIWorkspaceFrame(w).GetInsertPositon(mc.x, mc.y);
      r := w.Frame;
      case InsertPos of
        ipLeft: r.r := G2LerpFloat(r.l, r.r, 0.3);
        ipTop: r.b := G2LerpFloat(r.t, r.b, 0.3);
        ipRight: r.l := G2LerpFloat(r.l, r.r, 0.7);
        ipBottom: r.t := G2LerpFloat(r.t, r.b, 0.7);
      end;
      if TUIWorkspaceFrame(w).CanInsert(_Workspace, InsertPos) then
      g2.PrimRect(r.x, r.y, r.w, r.h, $4000cc00)
      else
      g2.PrimRect(r.x, r.y, r.w, r.h, $40cc0000);
    end
    else if App.UI.WorkspaceFrame.Contains(mc.x, mc.y) then
    begin
      r := App.UI.WorkspaceFrame;
      g2.PrimRect(r.x, r.y, r.w, r.h, $4000cc00);
    end;
  end;

  y := mc.y;
  rs := App.UI.Font1.TextHeight('A') + 12;
  rx := (32 - rs) * 0.5;
  g2.PrimRectCol(
    mc.x, y, _Size.x, _Size.y,
    App.UI.GetColorPrimary(0.8), App.UI.GetColorPrimary(0.8),
    App.UI.GetColorPrimary(0.5), App.UI.GetColorPrimary(0.5)
  );
  Str := _Workspace.GetWorkspaceName;
  App.UI.Font1.Print(
    mc.x + (_Size.x - App.UI.Font1.TextWidth(Str)) * 0.5,
    y + (_Size.y - App.UI.Font1.TextHeight('A')) * 0.5,
    1, 1, App.UI.GetColorPrimary(1), Str, bmNormal, tfPoint
  );
  r.l := mc.x + rx;
  r.t := mc.y + (_Size.y - rs) * 0.5;
  r.w := rs; r.h := rs;
  App.UI.DrawCircles(
    r, App.UI.GetColorPrimary(1)
  );
  r.x := mc.x + _Size.x - rx - rs;
  App.UI.DrawCircles(
    r, App.UI.GetColorPrimary(1)
  );
end;

procedure TOverlayWorkspace.Update;
begin

end;

procedure TOverlayWorkspace.MouseUp(const Button, x, y: Integer);
begin
  App.UI.MsgInsertWorkspace(_Workspace, G2Vec2(x, y), True);
  App.UI.Overlay := nil;
end;
//TOverlayWorkspace END

//TOverlayPopUp BEGIN
function TOverlayPopUp.PtInItem(const x, y: Single): TPopUpItem;
  procedure CheckGroup(const Group: TPopUpGroup);
    var i: Integer;
    var Open: Boolean;
    var ix, iy: Single;
  begin
    ix := Group.Pos.x;
    iy := Group.Pos.y;
    Open := False;
    for i := 0 to Group.ItemList.Count - 1 do
    begin
      if (Group.ItemList[i] is TPopUpGroup)
      and (TPopUpGroup(Group.ItemList[i]).Open) then
      begin
        CheckGroup(TPopUpGroup(Group.ItemList[i]));
        Open := True;
        Break;
      end;
      iy += _ItemHeight;
    end;
    if Open then Exit;
    iy := Group.Pos.y;
    for i := 0 to Group.ItemList.Count - 1 do
    begin
      if G2Rect(ix, iy, Group.Size.x, _ItemHeight).Contains(x, y) then
      begin
        Result := Group.ItemList[i];
        Exit;
      end;
      iy += _ItemHeight;
    end;
  end;
begin
  Result := nil;
  CheckGroup(_Root);
end;

function TOverlayPopUp.GetPosition: TG2Vec2;
begin
  Result := _Root.Pos;
end;

constructor TOverlayPopUp.Create;
begin
  _Root := TPopUpGroup.Create;
  _Root.ItemList.Clear;
  _Root.Open := True;
  _Root.Size.SetZero;
  _Root.Pos.SetZero;
  _Root.Parent := nil;
  _ItemHeight := App.UI.Font1.TextHeight('A') + 12;
  FillChar(_MdValid, SizeOf(_MdValid), 0);
end;

destructor TOverlayPopUp.Destroy;
begin
  Clear;
  _Root.Free;
end;

function TOverlayPopUp.IsEmpty: Boolean;
begin
  Result := _Root.ItemList.Count = 0;
end;

procedure TOverlayPopUp.Show(const Pos: TG2Vec2);
  var i: Integer;
begin
  FillChar(_MdValid, SizeOf(_MdValid), 0);
  if _Root.ItemList.Count = 0 then Exit;
  _Root.Pos := Pos;
  if _Root.Pos.x + _Root.Size.x >= g2.Params.Width then
  _Root.Pos.x := _Root.Pos.x - _Root.Size.x;
  if _Root.Pos.y + _Root.Size.y >= g2.Params.Height then
  _Root.Pos.y := _Root.Pos.y - _Root.Size.y;
  for i := 0 to _Root.ItemList.Count - 1 do
  if _Root.ItemList[i] is TPopUpGroup then
  TPopUpGroup(_Root.ItemList[i]).Open := False;
  App.UI.Overlay := Self;
end;

procedure TOverlayPopUp.AddButton(const Path: String; const Callback: TG2ProcObj);
  function FindItem(const Parent: TPopUpGroup; const ItemName: String): TPopUpGroup;
    var i: Integer;
  begin
    for i := 0 to Parent.ItemList.Count - 1 do
    if (Parent.ItemList[i] is TPopUpGroup)
    and (LowerCase(Parent.ItemList[i].Name) = LowerCase(ItemName)) then
    Exit(TPopUpGroup(Parent.ItemList[i]));
    Result := TPopUpGroup.Create;
    Result.Name := ItemName;
    Result.ItemList.Clear;
    Result.Open := False;
    Result.Size.SetZero;
    Result.Parent := Parent;
    Parent.ItemList.Add(Result);
    Parent.Size.y += _ItemHeight;
    Parent.Size.x := G2Max(Parent.Size.x, App.UI.Font1.TextWidth(ItemName) + 32);
  end;
  var PathArr: TG2StrArrA;
  var i: Integer;
  var ParentGroup: TPopUpGroup;
  var Button: TPopUpButton;
begin
  PathArr := G2StrExplode(Path, '/');
  ParentGroup := _Root;
  for i := 0 to High(PathArr) - 1 do
  ParentGroup := FindItem(ParentGroup, PathArr[i]);
  Button := TPopUpButton.Create;
  Button.Name := PathArr[High(PathArr)];
  Button.Callback := Callback;
  Button.Parent := ParentGroup;
  ParentGroup.Size.y += _ItemHeight;
  ParentGroup.Size.x := G2Max(ParentGroup.Size.x, App.UI.Font1.TextWidth(Button.Name) + 32);
  ParentGroup.ItemList.Add(Button);
end;

procedure TOverlayPopUp.Clear;
  procedure FreeItem(const Item: TPopUpItem);
    var i: Integer;
  begin
    if Item is TPopUpGroup then
    for i := 0 to TPopUpGroup(Item).ItemList.Count - 1 do
    FreeItem(TPopUpGroup(Item).ItemList[i]);
    Item.Free;
  end;
  var i: Integer;
begin
  for i := 0 to _Root.ItemList.Count - 1 do
  FreeItem(_Root.ItemList[i]);
  _Root.ItemList.Clear;
  _Root.Size.SetZero;
end;

procedure TOverlayPopUp.Render;
  var h: Single;
  procedure RenderGroup(const Group: TPopUpGroup);
    var x, y: Single;
    var i: Integer;
    var Str: String;
    var Open: Boolean;
  begin
    x := Group.Pos.x;
    y := Group.Pos.y;
    g2.PrimRect(
      x - 1, y - 1, Group.Size.x + 2, Group.Size.y + 2, $ff606060
    );
    Open := False;
    for i := 0 to Group.ItemList.Count - 1 do
    if Group.ItemList[i] is TPopUpGroup then
    Open := Open or TPopUpGroup(Group.ItemList[i]).Open;
    for i := 0 to Group.ItemList.Count - 1 do
    begin
      if (Group.ItemList[i] is TPopUpGroup)
      and TPopUpGroup(Group.ItemList[i]).Open then
      g2.PrimRect(
        x, y, Group.Size.x, h,
        $ff808080
      )
      else if not Open and G2Rect(x, y, Group.Size.x, h).Contains(g2.MousePos) then
      g2.PrimRect(
        x, y, Group.Size.x, h,
        $ffff8080
      )
      else
      g2.PrimRectCol(
        x, y, Group.Size.x, h,
        App.UI.GetColorPrimary(1), App.UI.GetColorPrimary(0.8),
        App.UI.GetColorPrimary(0.6), App.UI.GetColorPrimary(0.4)
      );
      if Group.ItemList[i] is TPopUpGroup then
      begin
        g2.PrimTriCol(
          x + Group.Size.x - 18, y + 8,
          x + Group.Size.x - 6, y + h * 0.5,
          x + Group.Size.x - 18, y + h - 8,
          $ff000000, $ff000000, $ff000000
        );
      end;
      Str := Group.ItemList[i].Name;
      App.UI.Font1.Print(
        x + 8,
        y + (h - App.UI.Font1.TextHeight('A')) * 0.5,
        1, 1, $ff000000, Str, bmNormal, tfPoint
      );
      y += h;
    end;
    if Open then
    for i := 0 to Group.ItemList.Count - 1 do
    if (Group.ItemList[i] is TPopUpGroup)
    and TPopUpGroup(Group.ItemList[i]).Open then
    begin
      RenderGroup(TPopUpGroup(Group.ItemList[i]));
      Break;
    end;
  end;
begin
  h := _ItemHeight;
  RenderGroup(_Root);
end;

procedure TOverlayPopUp.Update;
begin

end;

procedure TOverlayPopUp.MouseDown(const Button, x, y: Integer);
begin
  _MdValid[Button] := True;
end;

procedure TOverlayPopUp.MouseUp(const Button, x, y: Integer);
  function CheckGroup(const Group: TPopUpGroup): TPopUpGroup;
    var i: Integer;
  begin
    Result := nil;
    for i := 0 to Group.ItemList.Count - 1 do
    if (Group.ItemList[i] is TPopUpGroup)
    and TPopUpGroup(Group.ItemList[i]).Open then
    begin
      Result := CheckGroup(TPopUpGroup(Group.ItemList[i]));
      Break;
    end;
    if (Result = nil)
    and G2Rect(Group.Pos.x, Group.Pos.y, Group.Size.x, Group.Size.y).Contains(x, y) then
    Result := Group;
  end;
  var Item, PrevItem: TPopUpItem;
  var Group: TPopUpGroup;
  var i: Integer;
  var iy: Single;
begin
  if not _MdValid[Button] then Exit;
  _MdValid[Button] := False;
  Item := PtInItem(x, y);
  PrevItem := PtInItem(g2.MouseDownPos[Button].x, g2.MouseDownPos[Button].y);
  if (Item <> nil)
  and (Item = PrevItem) then
  begin
    if Item is TPopUpButton then
    begin
      App.UI.Overlay := nil;
      if Assigned(TPopUpButton(Item).Callback) then
      TPopUpButton(Item).Callback;
    end
    else if Item is TPopUpGroup then
    begin
      TPopUpGroup(Item).Open := True;
      for i := 0 to TPopUpGroup(Item).ItemList.Count - 1 do
      if TPopUpGroup(Item).ItemList[i] is TPopUpGroup then
      TPopUpGroup(TPopUpGroup(Item).ItemList[i]).Open := False;
      iy := TPopUpGroup(Item.Parent).Pos.y;
      for i := 0 to TPopUpGroup(Item.Parent).ItemList.Count - 1 do
      begin
        if TPopUpGroup(Item.Parent).ItemList[i] = Item then Break
        else iy += _ItemHeight;
      end;
      TPopUpGroup(Item).Pos.x := TPopUpGroup(Item.Parent).Pos.x + TPopUpGroup(Item.Parent).Size.x;
      if TPopUpGroup(Item).Pos.x + TPopUpGroup(Item).Size.x > g2.Params.Width then
      TPopUpGroup(Item).Pos.x := TPopUpGroup(Item.Parent).Pos.x - TPopUpGroup(Item).Size.x;
      TPopUpGroup(Item).Pos.y := iy;
      if TPopUpGroup(Item).Pos.y + TPopUpGroup(Item).Size.y > g2.Params.Height then
      TPopUpGroup(Item).Pos.y := iy + _ItemHeight - TPopUpGroup(Item).Size.y;
    end;
  end
  else
  begin
    Group := CheckGroup(_Root);
    if Group <> nil then
    begin
      for i := 0 to Group.ItemList.Count - 1 do
      if Group.ItemList[i] is TPopUpGroup then
      TPopUpGroup(Group.ItemList[i]).Open := False;
    end
    else
    Begin
      App.UI.Overlay := nil;
    end;
  end;
end;
//TOverlayPopUp END

//TOverlayAssetSelect BEGIN
procedure TOverlayAssetSelect.AddAssetType(const AssetClass: CAsset);
  var AssetType: PAssetType;
begin
  New(AssetType);
  AssetType^.AssetClass := AssetClass;
  AssetType^.Files.Clear;
  _AssetTypes.Add(AssetType);
end;

function TOverlayAssetSelect.GetFileFrame(const Index: Integer): TG2Rect;
begin
  Result.l := _ListFrame.l;
  Result.t := _ListFrame.t + 4 + _ItemSize * Index;
  Result.r := _ScrollV.Frame.l;
  Result.h := _ItemSize;
  Result.y := Result.y - _ScrollV.PosAbsolute;
end;

function TOverlayAssetSelect.GetFileContentSize: TG2Float;
begin
  Result := _AssetTypes[_TypeIndex]^.Files.Count * _ItemSize + 4;
end;

constructor TOverlayAssetSelect.Create;
begin
  _ScrollV.Initialize;
  _AssetTypes.Clear;
  AddAssetType(TAssetAny);
  AddAssetType(TAssetImage);
  AddAssetType(TAssetTexture);
  AddAssetType(TAssetFont);
  AddAssetType(TAssetEffect2D);
  AddAssetType(TAssetScene2D);
  AddAssetType(TAssetPrefab2D);
  _ItemSize := App.UI.Font1.TextHeight('A') + 4;
end;

destructor TOverlayAssetSelect.Destroy;
  var i: Integer;
begin
  for i := 0 to _AssetTypes.Count - 1 do
  Dispose(_AssetTypes[i]);
  _AssetTypes.Clear;
end;

procedure TOverlayAssetSelect.Open(
  const AssetClass: CAsset;
  const Callback: TG2ProcStringObj
);
  var i, j: Integer;
  var AssetPath, ext: String;
  var sr: TSearchRec;
  var fl: TFileList;
  var r: TG2Rect;
begin
  if not App.Project.Open then Exit;
  _Callback := Callback;
  _TypeIndex := 0;
  for i := 0 to _AssetTypes.Count - 1 do
  if _AssetTypes[i]^.AssetClass = AssetClass then
  begin
    _AssetTypes[i]^.Files.Clear;
    _TypeIndex := i;
  end;
  _Frame := G2Rect(100, 100, g2.Params.Width - 200, g2.Params.Height - 200);
  _TypeListFrame := _Frame;
  _TypeListFrame.l := _TypeListFrame.l + 4; _TypeListFrame.t := _TypeListFrame.t + 4; _TypeListFrame.b := _TypeListFrame.b - 4; _TypeListFrame.r := _TypeListFrame.l + 200;
  _ListFrame := _Frame;
  _ListFrame.t := _ListFrame.t + 36; _ListFrame.r := _ListFrame.r - 4; _ListFrame.b := _ListFrame.b - 4; _ListFrame.l := _TypeListFrame.r + 4;
  _BtnCancelFrame := G2Rect(_Frame.r - 84, _Frame.t + 4, 80, 28);
  _BtnSelectFrame := G2Rect(_BtnCancelFrame.l - 84, _BtnCancelFrame.t, 80, 28);
  AssetPath := App.Project.FilePath + 'assets' + G2PathSep;
  if FindFirst(AssetPath + '*.*', 0, sr) = 0 then
  begin
    repeat
      ext := ExtractFileExt(sr.Name);
      Delete(ext, 1, 1);
      for i := 0 to _AssetTypes.Count - 1 do
      begin
        fl.Clear;
        if _AssetTypes[i]^.AssetClass.CheckExtension(ext) then
        fl := _AssetTypes[i]^.AssetClass.ProcessFile({AssetPath + }sr.Name);
        for j := 0 to fl.Count - 1 do
        _AssetTypes[i]^.Files.Add(fl[j]);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  _FileIndex := -1;
  App.UI.Overlay := Self;
  r := _ListFrame;
  r.l := r.r - 16;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetFileContentSize;
  _ScrollV.ParentSize := _ListFrame.h;
end;

procedure TOverlayAssetSelect.Render;
  procedure DrawButton(const f: TG2Rect; const Text: String; const Enabled: Boolean = True);
    var r: TG2Rect;
    var c0, c1: TG2Color;
    var a: Single;
  begin
    if Enabled then a := 1 else a := 0.5;
    c0 := App.UI.GetColorPrimary(0.5, a);
    if Enabled and f.Contains(g2.MousePos) then
    begin
      if g2.MouseDown[G2MB_Left] and f.Contains(g2.MouseDownPos[G2MB_Left]) then
      c1 := App.UI.GetColorPrimary(0.4, a)
      else
      c1 := App.UI.GetColorPrimary(0.7, a);
    end
    else
    c1 := App.UI.GetColorPrimary(0.6, a);
    r := f;
    g2.PrimRect(r.l, r.t, r.w, r.h, c0); r := r.Expand(-2, -2);
    g2.PrimRect(r.l, r.t, r.w, r.h, c1);
    App.UI.Font1.Print(
      Round(f.x + (f.w - App.UI.Font1.TextWidth(Text)) * 0.5),
      Round(f.y + (f.h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, $ffffffff, Text, bmNormal, tfPoint
    );
  end;
  var i, h: Integer;
  var r: TG2Rect;
  var b: Boolean;
begin
  g2.PrimRect(_Frame.x, _Frame.y, _Frame.w, _Frame.h, App.UI.GetColorPrimary(0.4));
  g2.PrimRect(_TypeListFrame.x, _TypeListFrame.y, _TypeListFrame.w, _TypeListFrame.h, App.UI.GetColorPrimary(0.2));
  g2.PrimRect(_ListFrame.x, _ListFrame.y, _ListFrame.w, _ListFrame.h, App.UI.GetColorPrimary(0.2));
  DrawButton(_BtnCancelFrame, 'Cancel');
  if _FileIndex > -1 then b := True else b := False;
  DrawButton(_BtnSelectFrame, 'Select', b);
  App.UI.PushClipRect(_TypeListFrame);
  h := App.UI.Font1.TextHeight('A');
  for i := 0 to _AssetTypes.Count - 1 do
  begin
    if i = _TypeIndex then
    g2.PrimRect(
      _TypeListFrame.l, _TypeListFrame.t + 4 + h * i,
      _TypeListFrame.w, h,
      App.UI.GetColorPrimary(0.4)
    );
    App.UI.Font1.Print(
      Round(_TypeListFrame.l + 8),
      Round(_TypeListFrame.t + 4 + h * i),
      1, 1, $ffffffff,
      _AssetTypes[i]^.AssetClass.GetAssetName, bmNormal, tfPoint
    );
  end;
  App.UI.PopClipRect;
  App.UI.PushClipRect(_ListFrame);
  for i := 0 to _AssetTypes[_TypeIndex]^.Files.Count - 1 do
  begin
    r := GetFileFrame(i);
    if i = _FileIndex then
    g2.PrimRect(
      r.l, r.t, r.w, r.h,
      App.UI.GetColorSecondary(0.4)
    );
    App.UI.Font1.Print(
      Round(r.l + 8), Round(r.t + (r.h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, $ffffffff,
      _AssetTypes[_TypeIndex]^.Files[i], bmNormal, tfPoint
    );
  end;
  App.UI.PopClipRect;
  _ScrollV.Render;
end;

procedure TOverlayAssetSelect.Update;
begin
  _ScrollV.Update;
end;

procedure TOverlayAssetSelect.MouseDown(const Button, x, y: Integer);
  var i: Integer;
  var r: TG2Rect;
begin
  case Button of
    G2MB_Left:
    begin
      if _ListFrame.Contains(x, y)
      and _ListFrame.Contains(g2.MouseDownPos[Button]) then
      begin
        for i := 0 to _AssetTypes[_TypeIndex]^.Files.Count - 1 do
        begin
          r := GetFileFrame(i);
          if r.Contains(x, y)
          and r.Contains(g2.MouseDownPos[Button]) then
          begin
            _FileIndex := i;
            Break;
          end;
        end;
      end;
    end;
  end;
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TOverlayAssetSelect.MouseUp(const Button, x, y: Integer);
begin
  case Button of
    G2MB_Left:
    begin
      if _BtnCancelFrame.Contains(x, y)
      and _BtnCancelFrame.Contains(g2.MouseDownPos[Button]) then
      begin
        App.UI.Overlay := nil;
      end
      else if _BtnSelectFrame.Contains(x, y)
      and _BtnSelectFrame.Contains(g2.MouseDownPos[Button]) then
      begin
        if (_FileIndex > -1)
        and Assigned(_Callback) then
        _Callback(_AssetTypes[_TypeIndex]^.Files[_FileIndex]);
        App.UI.Overlay := nil;
      end;
    end;
  end;
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TOverlayAssetSelect.Scroll(const y: Integer);
begin
  if _ListFrame.Contains(g2.MousePos) then
  begin
    _ScrollV.Scroll(y);
  end;
end;
//TOverlayAssetSelect END

//TOverlayDropList BEGIN
procedure TOverlayDropList.Initialize(const OwnerFrame: TG2Rect);
  var i: Integer;
begin
  OnChange := nil;
  _ItemHeight := OwnerFrame.h;
  Frame := OwnerFrame;
  Frame.t := Frame.b;
  Frame.h := G2Min(Items.Count, 6) * _ItemHeight;
  if Frame.b > g2.Params.Height then
  Frame.y := OwnerFrame.t - Frame.h;
  if Items.Count > 6 then
  begin
    Scrolling := True;
    ScrollV.Initialize;
    ScrollV.Orientation := sbVertical;
    ScrollV.Enabled := True;
    ScrollV.PosRelative := 0;
    ScrollV.Frame := Frame;
    ScrollV.Frame.l := Frame.r - 18;
    ScrollV.ContentSize := Items.Count * _ItemHeight;
    ScrollV.ParentSize := Frame.h;
    Frame.r := ScrollV.Frame.l;
  end
  else
  begin
    Scrolling := False;
    ScrollV.PosRelative := 0;
    ScrollV.Enabled := False;
  end;
  App.UI.Overlay := Self;
end;

procedure TOverlayDropList.Render;
  var i: Integer;
  var r: TG2Rect;
  var c: TG2Color;
begin
  g2.PrimRect(Frame.x, Frame.y, Frame.w, Frame.h, App.UI.GetColorPrimary(0.2));
  App.UI.PushClipRect(Frame);
  r := Frame;
  r.b := r.t + _ItemHeight;
  r.y := r.y - ScrollV.PosAbsolute;
  for i := 0 to Items.Count - 1 do
  begin
    if Frame.Contains(g2.MousePos)
    and r.Contains(g2.MousePos) then
    begin
      g2.PrimRect(r.l + 2, r.t + 2, r.w - 4, r.h - 4, App.UI.GetColorPrimary(0.3));
      c := $ffffffff;
    end
    else
    c := $ffcccccc;
    App.UI.Font1.Print(
      r.l + 4, r.t + (r.h - App.UI.Font1.TextHeight('A')) * 0.5,
      1, 1, c, Items[i], bmNormal, tfPoint
    );
    r.y := r.y + r.h;
  end;
  App.UI.PopClipRect;
  if Scrolling then ScrollV.Render;
end;

procedure TOverlayDropList.Update;
begin
  if Scrolling then ScrollV.Update;
end;

procedure TOverlayDropList.MouseDown(const Button, x, y: Integer);
begin
  if Scrolling then ScrollV.MouseDown(Button, x, y);
end;

procedure TOverlayDropList.MouseUp(const Button, x, y: Integer);
  var i: Integer;
  var r: TG2Rect;
begin
  if Scrolling and ScrollV.Frame.Contains(g2.MouseDownPos[Button]) then
  begin
    ScrollV.MouseUp(Button, x, y);
    Exit;
  end;
  if Frame.Contains(x, y) and Frame.Contains(g2.MouseDownPos[Button]) then
  begin
    r := Frame;
    r.h := _ItemHeight;
    r.y := r.y - ScrollV.PosAbsolute;
    for i := 0 to Items.Count - 1 do
    begin
      if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
      begin
        if Assigned(OnChange) then OnChange(i);
        Break;
      end;
      r.y := r.y + r.h;
    end;
  end;
  App.UI.Overlay := nil;
end;

procedure TOverlayDropList.Scroll(const y: Integer);
begin
  if Scrolling then ScrollV.Scroll(y);
end;
//TOverlayDropList END

//TOverlayDrop BEGIN
procedure TOverlayDrop.Initialzie;
begin
  _Name := '';
  _Icon := nil;
  _CurWorkspace := nil;
  _CanDrop := False;
  App.UI.Overlay := Self;
end;

procedure TOverlayDrop.Render;
  var x0, x1, x2, x3, y0, y1, y2, y3, w, h: TG2Float;
  var cp: TG2Vec2;
  var c0, c1: TG2Color;
begin
  cp := g2.MousePos;
  w := 32 + App.UI.Font1.TextWidth(_Name);
  h := 8 + App.UI.Font1.TextHeight('A');
  x0 := cp.x + 8; x1 := x0 + 8; x2 := x1 + w; x3 := x2 + 8;
  y0 := cp.y + 8; y1 := y0 + 8; y2 := y1 + h; y3 := y2 + 8;
  if _CanDrop then c0 := $ff00ff00 else c0 := $ffff0000; c1 := c0; c1.a := 0;
  g2.PrimBegin(ptTriangles, bmNormal);
  g2.PrimAdd(x0, y1, c1); g2.PrimAdd(x1, y0, c1); g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x1, y0, c1); g2.PrimAdd(x2, y0, c1); g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x1, y1, c0); g2.PrimAdd(x2, y0, c1); g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x2, y0, c1); g2.PrimAdd(x3, y1, c1); g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x3, y1, c1); g2.PrimAdd(x3, y2, c1); g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x2, y1, c0); g2.PrimAdd(x3, y2, c1); g2.PrimAdd(x2, y2, c0);
  g2.PrimAdd(x3, y2, c1); g2.PrimAdd(x2, y3, c1); g2.PrimAdd(x2, y2, c0);
  g2.PrimAdd(x2, y3, c1); g2.PrimAdd(x1, y3, c1); g2.PrimAdd(x2, y2, c0);
  g2.PrimAdd(x2, y2, c0); g2.PrimAdd(x1, y3, c1); g2.PrimAdd(x1, y2, c0);
  g2.PrimAdd(x1, y3, c1); g2.PrimAdd(x0, y2, c1); g2.PrimAdd(x1, y2, c0);
  g2.PrimAdd(x0, y2, c1); g2.PrimAdd(x0, y1, c1); g2.PrimAdd(x1, y2, c0);
  g2.PrimAdd(x1, y2, c0); g2.PrimAdd(x0, y1, c1); g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x1, y1, c0); g2.PrimAdd(x2, y1, c0); g2.PrimAdd(x1, y2, c0);
  g2.PrimAdd(x1, y2, c0); g2.PrimAdd(x2, y1, c0); g2.PrimAdd(x2, y2, c0);
  g2.PrimEnd;
  g2.PrimRectCol(x1, y1, w, h, $ffcccccc, $00cccccc, $ffcccccc, $00cccccc);
  App.UI.Font1.Print(x1 + 16, y1 + 4, 1, 1, $ff000000, _Name, bmNormal, tfPoint);
end;

procedure TOverlayDrop.Update;
  var cp: TG2Vec2;
  var Workspace: TUIWorkspace;
begin
  cp := g2.MousePos;
  Workspace := App.UI.Views.FindFrameWorkpace(cp.x, cp.y);
  if Workspace <> nil then
  begin
    if Workspace.ChildCount > 1 then
    Workspace := Workspace.Children[TUIWorkspaceFrame(Workspace).ChildIndex]
    else
    Workspace := Workspace.Children[0];
  end;
  if Workspace = _CurWorkspace then Exit;
  if _CurWorkspace <> nil then
  begin
    if _CurWorkspace.CanDragDrop(Self) then
    _CurWorkspace.OnDragDropEnd(Self);
  end;
  _CanDrop := False;
  _CurWorkspace := Workspace;
  if _CurWorkspace <> nil then
  begin
    if _CurWorkspace.CanDragDrop(Self) then
    begin
      _CurWorkspace.OnDragDropBegin(Self);
      _CanDrop := True;
    end;
  end;
end;

procedure TOverlayDrop.MouseUp(const Button, x, y: Integer);
begin
  if _CurWorkspace <> nil then
  begin
    if _CurWorkspace.CanDragDrop(Self) then
    _CurWorkspace.OnDragDropRelase(Self);
  end;
  App.UI.Overlay := nil;
  Free;
end;
//TOverlayDrop END

//TUndoQueue BEGIN
procedure TUndoQueue.Clear(const Start, Finish: Integer);
  var i: Integer;
  var Item: PUndoItem;
begin
  i := Start;
  while i <> Finish do
  begin
    Item := @_Queue[i];
    G2MemFree(Item^.UndoInfo, Item^.UndoSize);
    G2MemFree(Item^.RedoInfo, Item^.RedoSize);
    i := (i + 1) mod Length(_Queue);
  end;
end;

procedure TUndoQueue.Initialize;
begin
  _CurItem := 0;
  _QueueStart := High(_Queue);
  _QueueEnd := 0;
end;

procedure TUndoQueue.Finalize;
begin
  Clear((_QueueStart + 1) mod Length(_Queue), _QueueEnd);
end;

procedure TUndoQueue.Add(
  UndoProc: TG2ProcPtrObj;
  UndoInfo: Pointer;
  UndoSize: Integer;
  RedoProc: TG2ProcPtrObj;
  RedoInfo: Pointer;
  RedoSize: Integer
);
  var Item: PUndoItem;
begin
  if ((_QueueEnd <> _CurItem) or (_QueueEnd = _QueueStart)) and (_QueueEnd <> (_CurItem + 1) mod Length(_Queue)) then
  begin
    Clear((_CurItem + 1) mod Length(_Queue), _QueueEnd);
    _QueueEnd := (_CurItem + 1) mod Length(_Queue);
    if _CurItem = _QueueStart then
    _CurItem := _QueueEnd;
  end;
  if _QueueEnd = _QueueStart then
  begin
    _QueueStart := (_QueueStart + 1) mod Length(_Queue);
    Clear(_QueueStart, (_QueueStart + 1) mod Length(_Queue));
  end;
  _CurItem := _QueueEnd;
  _QueueEnd := (_QueueEnd + 1) mod Length(_Queue);
  Item := @_Queue[_CurItem];
  Item^.UndoProc := UndoProc;
  Item^.UndoInfo := UndoInfo;
  Item^.UndoSize := UndoSize;
  Item^.RedoProc := RedoProc;
  Item^.RedoInfo := RedoInfo;
  Item^.RedoSize := RedoSize;
end;

procedure TUndoQueue.Undo;
  var Item: PUndoItem;
begin
  if CanUndo then
  begin
    Item := @_Queue[_CurItem];
    Item^.UndoProc(Item^.UndoInfo);
    _CurItem := _CurItem - 1; if _CurItem < 0 then _CurItem := Length(_Queue) + _CurItem;
  end;
end;

procedure TUndoQueue.Redo;
  var Item: PUndoItem;
begin
  if CanRedo then
  begin
    _CurItem := (_CurItem + 1) mod Length(_Queue);
    Item := @_Queue[_CurItem];
    Item^.RedoProc(Item^.RedoInfo);
  end;
end;

function TUndoQueue.CanUndo: Boolean;
begin
  Result := (_CurItem <> _QueueEnd) and (_CurItem <> _QueueStart);
end;

function TUndoQueue.CanRedo: Boolean;
begin
  Result := ((_CurItem <> _QueueEnd) or (_QueueEnd = _QueueStart)) and ((_CurItem + 1) mod Length(_Queue) <> _QueueEnd);
end;
//TUndoQueue END

//TCodeFile BEGIN
procedure TCodeFile.SetModified(const Value: Boolean);
begin
  _Modified := Value;
end;

function TCodeFile.IsSaved: Boolean;
begin
  Result := (Length(FileName) > 0) and (FileExists(FilePath + FileName));
end;

function TCodeFile.GetCaption: AnsiString;
begin
  if Length(FileName) > 0 then
  Result := FileName
  else
  Result := 'Unsaved';
  if Modified then
  Result += ' *';
end;

function TCodeFile.GetCode: AnsiString;
  var i: Integer;
begin
  Result := '';
  for i := 0 to High(Lines) do
  begin
    Result := Result + Lines[i];
    if i < High(Lines) then
    Result := Result + #$D#$A;
  end;
end;

procedure TCodeFile.SetCode(const Code: AnsiString);
begin
  Lines := G2StrExplode(G2StrReplace(G2StrReplace(Code, #$D#$A, #$D), #$A, #$D), #$D);
end;

procedure TCodeFile.Reset;
begin
  FileName := '';
  FilePath := '';
  _Modified := False;
  Lines := nil;
  TextPos.SetValue(0, 0);
end;

procedure TCodeFile.Initialize;
begin
  Reset;
  Undo.Initialize;
end;

procedure TCodeFile.Finalize;
begin
  if App.CodeInsight.CurCodeFile = @Self then
  App.CodeInsight.CurCodeFile := nil;
  Reset;
  Undo.Finalize;
end;

procedure TCodeFile.AddLine(const Line: AnsiString);
begin
  SetLength(Lines, Length(Lines) + 1);
  Lines[High(Lines)] := Line;
end;

procedure TCodeFile.AddUndoActionInsert(
  const UndoCursorStart, UndoCursorEnd: TPoint;
  const UndoString: AnsiString;
  const RedoCursorStart, RedoCursorEnd: TPoint;
  const RedoString: AnsiString
);
  var UndoAction, RedoAction: TCodeUndoAction;
  var UndoBuffer, RedoBuffer: PG2IntU8Arr;
  var UndoSize, RedoSize: Integer;
begin
  UndoAction.CursorStart := UndoCursorStart;
  UndoAction.CursorEnd := UndoCursorEnd;
  UndoAction.StrLength := Length(UndoString);
  UndoSize := SizeOf(UndoAction) + UndoAction.StrLength;
  UndoBuffer := G2MemAlloc(UndoSize);
  Move(UndoAction, UndoBuffer^, SizeOf(UndoAction));
  Move(UndoString[1], UndoBuffer^[SizeOf(UndoAction)], Length(UndoString));
  RedoAction.CursorStart := RedoCursorStart;
  RedoAction.CursorEnd := RedoCursorEnd;
  RedoAction.StrLength := Length(RedoString);
  RedoSize := SizeOf(RedoAction) + RedoAction.StrLength;
  RedoBuffer := G2MemAlloc(RedoSize);
  Move(RedoAction, RedoBuffer^, SizeOf(RedoAction));
  Move(RedoString[1], RedoBuffer^[SizeOf(RedoAction)], Length(RedoString));
  Undo.Add(
    @App.UI.TextEdit.ImplCode.UndoActionInsert,
    UndoBuffer,
    UndoSize,
    @App.UI.TextEdit.ImplCode.UndoActionInsert,
    RedoBuffer,
    RedoSize
  );
end;

procedure TCodeFile.AddUndoActionComment(const LineStart, LineEnd: Integer);
  var ActionMultilineUndo, ActionMultilineRedo: PCodeUndoActionMultiline;
begin
  ActionMultilineUndo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineUndo^.LineStart := LineStart;
  ActionMultilineUndo^.LineEnd := LineEnd;
  ActionMultilineRedo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineRedo^.LineStart := LineStart;
  ActionMultilineRedo^.LineEnd := LineEnd;
  Undo.Add(
    @App.UI.TextEdit.ImplCode.UndoActionUnComment,
    ActionMultilineUndo, SizeOf(ActionMultilineUndo),
    @App.UI.TextEdit.ImplCode.UndoActionComment,
    ActionMultilineRedo, SizeOf(ActionMultilineRedo)
  );
end;

procedure TCodeFile.AddUndoActionUnComment(const LineStart, LineEnd: Integer);
  var ActionMultilineUndo, ActionMultilineRedo: PCodeUndoActionMultiline;
begin
  ActionMultilineUndo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineUndo^.LineStart := LineStart;
  ActionMultilineUndo^.LineEnd := LineEnd;
  ActionMultilineRedo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineRedo^.LineStart := LineStart;
  ActionMultilineRedo^.LineEnd := LineEnd;
  Undo.Add(
    @App.UI.TextEdit.ImplCode.UndoActionComment,
    ActionMultilineUndo, SizeOf(ActionMultilineUndo),
    @App.UI.TextEdit.ImplCode.UndoActionUnComment,
    ActionMultilineRedo, SizeOf(ActionMultilineRedo)
  );
end;

procedure TCodeFile.AddUndoActionIndent(const LineStart, LineEnd: Integer);
  var ActionMultilineUndo, ActionMultilineRedo: PCodeUndoActionMultiline;
begin
  ActionMultilineUndo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineUndo^.LineStart := LineStart;
  ActionMultilineUndo^.LineEnd := LineEnd;
  ActionMultilineRedo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineRedo^.LineStart := LineStart;
  ActionMultilineRedo^.LineEnd := LineEnd;
  Undo.Add(
    @App.UI.TextEdit.ImplCode.UndoActionUnIndent,
    ActionMultilineUndo, SizeOf(ActionMultilineUndo),
    @App.UI.TextEdit.ImplCode.UndoActionIndent,
    ActionMultilineRedo, SizeOf(ActionMultilineRedo)
  );
end;

procedure TCodeFile.AddUndoActionUnIndent(const LineStart, LineEnd: Integer);
  var ActionMultilineUndo, ActionMultilineRedo: PCodeUndoActionMultiline;
begin
  ActionMultilineUndo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineUndo^.LineStart := LineStart;
  ActionMultilineUndo^.LineEnd := LineEnd;
  ActionMultilineRedo := G2MemAlloc(SizeOf(TCodeUndoActionMultiline));
  ActionMultilineRedo^.LineStart := LineStart;
  ActionMultilineRedo^.LineEnd := LineEnd;
  Undo.Add(
    @App.UI.TextEdit.ImplCode.UndoActionIndent,
    ActionMultilineUndo, SizeOf(ActionMultilineUndo),
    @App.UI.TextEdit.ImplCode.UndoActionUnIndent,
    ActionMultilineRedo, SizeOf(ActionMultilineRedo)
  );
end;

procedure TCodeFile.Save(const f: String);
  var fs: TFileStream;
  var FileData: AnsiString;
  var cif: TCodeInsightSymbolFile;
begin
  fs := TFileStream.Create(f, fmCreate);
  try
    FileData := GetCode;
    fs.WriteBuffer(FileData[1], Length(FileData));
    FilePath := ExtractFilePath(f);
    FileName := ExtractFileName(f);
    if _Modified then
    begin
      cif := App.CodeInsight.FindFile(FilePath + FileName);
      if cif <> nil then
      cif.Modified := True;
    end;
    Modified := False;
  finally
    fs.Free;
  end;
end;

procedure TCodeFile.Load(const f: String);
  var fs: TFileStream;
  var FileData: AnsiString;
begin
  fs := TFileStream.Create(f, fmOpenRead);
  try
    SetLength(FileData, fs.Size);
    fs.ReadBuffer(FileData[1], Length(FileData));
    SetCode(FileData);
    FilePath := ExtractFilePath(f);
    FileName := ExtractFileName(f);
    Modified := False;
  finally
    fs.Free;
  end;
end;
//TCodeFile END

//TCodeHighlight BEGIN
function TCodeHighlight.GetColor(const x, y: Integer): TG2Color;
begin
  Result := _ColorKernel[y][x];
end;

constructor TCodeHighlight.Create;
begin
  _ColorText := $1000000;
  _ColorString := $10000cc;
  _ColorComment := $1006000;
  _ColorKeyword := $20040c0;
  _ColorSymbol := $1aa0000;
  _Parser := TG2Parser.Create;
end;

destructor TCodeHighlight.Destroy;
begin
  _Parser.Free;
end;

procedure TCodeHighlight.Scan(
  const CodeFile: PCodeFile;
  const LineStart, LineEnd: Integer
);
  var Line, i, le, kl: Integer;
begin
  if LineStart > High(CodeFile^.Lines) then Exit;
  le := G2Min(LineEnd, High(CodeFile^.Lines));
  if Length(_ColorKernel) < le - LineStart + 1 then
  SetLength(_ColorKernel, le - LineStart + 1);
  kl := 0;
  for Line := LineStart to G2Min(LineEnd, High(CodeFile^.Lines)) do
  begin
    if Length(_ColorKernel[kl]) < Length(CodeFile^.Lines[Line]) then
    SetLength(_ColorKernel[kl], Length(CodeFile^.Lines[Line]));
    for i := 0 to Length(CodeFile^.Lines[Line]) - 1 do
    _ColorKernel[kl][i] := $1000000;
    Inc(kl);
  end;
end;
//TCodeHighlight END

//TCodeHighlightPascal BEGIN
constructor TCodeHighlightPascal.Create;
begin
  inherited Create;
  Parser.AddSymbol('''');
  Parser.AddSymbol('{$');
  Parser.AddSymbol('{');
  Parser.AddSymbol('}');
  Parser.AddSymbol('(*');
  Parser.AddSymbol('*)');
  Parser.AddSymbol('//');
  Parser.AddSymbol('/');
  Parser.AddSymbol('+');
  Parser.AddSymbol('*');
  Parser.AddSymbol('-');
  Parser.AddSymbol(':');
  Parser.AddSymbol(';');
  Parser.AddSymbol(',');
  Parser.AddSymbol('.');
  Parser.AddSymbol('=');
  Parser.AddSymbol('(');
  Parser.AddSymbol(')');
  Parser.AddSymbol('[');
  Parser.AddSymbol(']');
  Parser.AddSymbol('<');
  Parser.AddSymbol('>');
  Parser.AddSymbol('@');
  Parser.AddSymbol('^');
  Parser.AddKeyWord('as');
  Parser.AddKeyWord('dispinterface');
  Parser.AddKeyWord('except');
  Parser.AddKeyWord('exports');
  Parser.AddKeyWord('finalization');
  Parser.AddKeyWord('finally');
  Parser.AddKeyWord('initialization');
  Parser.AddKeyWord('inline');
  Parser.AddKeyWord('library');
  Parser.AddKeyWord('on');
  Parser.AddKeyWord('out');
  Parser.AddKeyWord('packed');
  Parser.AddKeyWord('property');
  Parser.AddKeyWord('raise');
  Parser.AddKeyWord('resourcestring');
  Parser.AddKeyWord('threadvar');
  Parser.AddKeyWord('try');
  Parser.AddKeyWord('absolute');
  Parser.AddKeyWord('abstract');
  Parser.AddKeyWord('alias');
  Parser.AddKeyWord('assembler');
  Parser.AddKeyWord('cdecl');
  Parser.AddKeyWord('cppdecl');
  Parser.AddKeyWord('default');
  Parser.AddKeyWord('export');
  Parser.AddKeyWord('external');
  Parser.AddKeyWord('far');
  Parser.AddKeyWord('far16');
  Parser.AddKeyWord('forward');
  Parser.AddKeyWord('index');
  Parser.AddKeyWord('local');
  Parser.AddKeyWord('near');
  Parser.AddKeyWord('nostackframe');
  Parser.AddKeyWord('oldfpccall');
  Parser.AddKeyWord('override');
  Parser.AddKeyWord('overload');
  Parser.AddKeyWord('pascal');
  Parser.AddKeyWord('private');
  Parser.AddKeyWord('protected');
  Parser.AddKeyWord('public');
  Parser.AddKeyWord('published');
  Parser.AddKeyWord('read');
  Parser.AddKeyWord('register');
  Parser.AddKeyWord('reintroduce');
  Parser.AddKeyWord('safecall');
  Parser.AddKeyWord('softfloat');
  Parser.AddKeyWord('stdcall');
  Parser.AddKeyWord('virtual');
  Parser.AddKeyWord('write');
  Parser.AddKeyWord('and');
  Parser.AddKeyWord('array');
  Parser.AddKeyWord('asm');
  Parser.AddKeyWord('div');
  Parser.AddKeyWord('downto');
  Parser.AddKeyWord('file');
  Parser.AddKeyWord('goto');
  Parser.AddKeyWord('implementation');
  Parser.AddKeyWord('in');
  Parser.AddKeyWord('inherited');
  Parser.AddKeyWord('inline');
  Parser.AddKeyWord('interface');
  Parser.AddKeyWord('label');
  Parser.AddKeyWord('mod');
  Parser.AddKeyWord('nil');
  Parser.AddKeyWord('not');
  Parser.AddKeyWord('object');
  Parser.AddKeyWord('operator');
  Parser.AddKeyWord('or');
  Parser.AddKeyWord('packed');
  Parser.AddKeyWord('reintroduce');
  Parser.AddKeyWord('repeat');
  Parser.AddKeyWord('set');
  Parser.AddKeyWord('shl');
  Parser.AddKeyWord('shr');
  Parser.AddKeyWord('type');
  Parser.AddKeyWord('unit');
  Parser.AddKeyWord('uses');
  Parser.AddKeyWord('with');
  Parser.AddKeyWord('xor');
  Parser.AddKeyWord('begin');
  Parser.AddKeyWord('end');
  Parser.AddKeyWord('program');
  Parser.AddKeyWord('procedure');
  Parser.AddKeyWord('function');
  Parser.AddKeyWord('class');
  Parser.AddKeyWord('record');
  Parser.AddKeyWord('object');
  Parser.AddKeyWord('var');
  Parser.AddKeyWord('const');
  Parser.AddKeyWord('if');
  Parser.AddKeyWord('then');
  Parser.AddKeyWord('else');
  Parser.AddKeyWord('while');
  Parser.AddKeyWord('do');
  Parser.AddKeyWord('for');
  Parser.AddKeyWord('repeat');
  Parser.AddKeyWord('until');
  Parser.AddKeyWord('array');
  Parser.AddKeyWord('of');
  Parser.AddKeyWord('is');
  Parser.AddKeyWord('to');
  Parser.AddKeyWord('case');
  Parser.AddKeyWord('constructor');
  Parser.AddKeyWord('destructor');
  Parser.AddKeyWord('objcclass');
  Parser.AddKeyWord('message');
  Parser.AddKeyWord('specialize');
end;

procedure TCodeHighlightPascal.Scan(const CodeFile: PCodeFile; const LineStart, LineEnd: Integer);
  function CheckStr(const PosL, PosC: Integer; const Str: AnsiString): Boolean;
    var i: Integer;
  begin
    if PosC + Length(Str) - 1 > Length(CodeFile^.Lines[PosL]) then
    begin
      Result := False;
      Exit;
    end;
    for i := 1 to Length(Str) do
    if CodeFile^.Lines[PosL][PosC + i - 1] <> Str[i] then
    begin
      Result := False;
      Exit;
    end;
    Result := True;
  end;
  procedure SetColor(const PosL, PosS, PosE: Integer; const Color: TG2Color);
    var i: Integer;
  begin
    for i := PosS to PosE do
    _ColorKernel[PosL][i] := Color;
  end;
  var Line, i, le, kl, tps, tpe: Integer;
  var IsString: Boolean;
  var IsComment: array[0..1] of Boolean;
  var IsPrePro: Boolean;
  var tt: TG2TokenType;
  var Token: AnsiString;
begin
  if LineStart > High(CodeFile^.Lines) then Exit;
  IsString := False;
  IsComment[0] := False;
  IsComment[1] := False;
  IsPrePro := False;
  for Line := 0 to LineStart - 1 do
  begin
    IsString := False;
    for i := 1 to Length(CodeFile^.Lines[Line]) do
    begin
      if IsPrePro then
      begin
        if CodeFile^.Lines[Line][i] = '}' then
        IsPrePro := False;
      end
      else if IsString then
      begin
        if CodeFile^.Lines[Line][i] = '''' then
        IsString := False;
      end
      else if IsComment[0] then
      begin
        if CodeFile^.Lines[Line][i] = '}' then
        IsComment[0] := False;
      end
      else if IsComment[1] then
      begin
        if CheckStr(Line, i, '*)') then
        IsComment[1] := False;
      end
      else if CheckStr(Line, i, '{$') then
      IsPrePro := True
      else if CodeFile^.Lines[Line][i] = '''' then
      IsString := True
      else if CodeFile^.Lines[Line][i] = '{' then
      IsComment[0] := True
      else if CheckStr(Line, i, '(*') then
      IsComment[1] := True
      else if CheckStr(Line, i, '//') then
      Break;
    end;
  end;
  le := G2Min(LineEnd, High(CodeFile^.Lines));
  if Length(_ColorKernel) < le - LineStart + 1 then
  SetLength(_ColorKernel, le - LineStart + 1);
  kl := 0;
  for Line := LineStart to G2Min(LineEnd, High(CodeFile^.Lines)) do
  begin
    IsString := False;
    if Length(_ColorKernel[kl]) < Length(CodeFile^.Lines[Line]) then
    SetLength(_ColorKernel[kl], Length(CodeFile^.Lines[Line]));
    _Parser.Parse(CodeFile^.Lines[Line]);
    repeat
      tps := _Parser.Position;
      Token := _Parser.NextToken(tt);
      tpe := _Parser.Position - 1;
      case tt of
        ttSymbol:
        begin
          if IsPrePro then
          begin
            if Token = '}' then
            IsPrePro := False;
            SetColor(kl, tps, tpe, _ColorSymbol);
          end
          else if IsString then
          begin
            if Token = '''' then
            IsString := False;
            SetColor(kl, tps, tpe, _ColorString);
          end
          else if IsComment[0] then
          begin
            if Token = '}' then
            IsComment[0] := False;
            SetColor(kl, tps, tpe, _ColorComment);
          end
          else if IsComment[1] then
          begin
            if Token = '*)' then
            IsComment[1] := False;
            SetColor(kl, tps, tpe, _ColorComment);
          end
          else if Token = '{$' then
          begin
            IsPrePro := True;
            SetColor(kl, tps, tpe, _ColorSymbol);
          end
          else if Token = '''' then
          begin
            IsString := True;
            SetColor(kl, tps, tpe, _ColorString);
          end
          else if Token = '{' then
          begin
            IsComment[0] := True;
            SetColor(kl, tps, tpe, _ColorComment);
          end
          else if Token = '(*' then
          begin
            IsComment[1] := True;
            SetColor(kl, tps, tpe, _ColorComment);
          end
          else if Token = '//' then
          begin
            SetColor(kl, tps, Length(CodeFile^.Lines[Line]) - 1, _ColorComment);
            Break;
          end
          else
          begin
            SetColor(kl, tps, tpe, _ColorSymbol);
          end;
        end;
        else
        begin
          if IsPrePro then
          SetColor(kl, tps, tpe, _ColorSymbol)
          else if IsString then
          SetColor(kl, tps, tpe, _ColorString)
          else if IsComment[0] or IsComment[1] then
          SetColor(kl, tps, tpe, _ColorComment)
          else
          begin
            if tt = ttKeyword then
            SetColor(kl, tps, tpe, _ColorKeyword)
            else
            SetColor(kl, tps, tpe, _ColorText);
          end;
        end;
      end;
    until tt = ttEOF;
    Inc(kl);
  end;
end;

//TCodeHighlightPascal END

//TCodeHighlightG2ML BEGIN
constructor TCodeHighlightG2ML.Create;
begin
  inherited Create;
  Parser.AddSymbol('{#');
  Parser.AddSymbol('#}');
  Parser.AddSymbol('=');
  Parser.AddSymbol('"');
  ColorSymbol := $1aa0000;
  ColorString := $10040cc;
end;

procedure TCodeHighlightG2ML.Scan(const CodeFile: PCodeFile; const LineStart, LineEnd: Integer);
  function CheckStr(const PosL, PosC: Integer; const Str: AnsiString): Boolean;
    var i: Integer;
  begin
    if PosC + Length(Str) - 1 > Length(CodeFile^.Lines[PosL]) then
    begin
      Result := False;
      Exit;
    end;
    for i := 1 to Length(Str) do
    if CodeFile^.Lines[PosL][PosC + i - 1] <> Str[i] then
    begin
      Result := False;
      Exit;
    end;
    Result := True;
  end;
  procedure SetColor(const PosL, PosS, PosE: Integer; const Color: TG2Color);
    var i: Integer;
  begin
    for i := PosS to PosE do
    _ColorKernel[PosL][i] := Color;
  end;
  var Line, i, le, kl, tps, tpe: Integer;
  var IsString: Boolean;
  var IsObject: Boolean;
  var tt: TG2TokenType;
  var Token: AnsiString;
begin
  if LineStart > High(CodeFile^.Lines) then Exit;
  IsString := False;
  for Line := 0 to LineStart - 1 do
  begin
    for i := 1 to Length(CodeFile^.Lines[Line]) do
    begin
      if IsString then
      begin
        if CodeFile^.Lines[Line][i] = '"' then
        IsString := False;
      end
      else if CodeFile^.Lines[Line][i] = '"' then
      IsString := True;
    end;
  end;
  le := G2Min(LineEnd, High(CodeFile^.Lines));
  if Length(_ColorKernel) < le - LineStart + 1 then
  SetLength(_ColorKernel, le - LineStart + 1);
  kl := 0;
  IsObject := False;
  for Line := LineStart to G2Min(LineEnd, High(CodeFile^.Lines)) do
  begin
    if Length(_ColorKernel[kl]) < Length(CodeFile^.Lines[Line]) then
    SetLength(_ColorKernel[kl], Length(CodeFile^.Lines[Line]));
    _Parser.Parse(CodeFile^.Lines[Line]);
    repeat
      tps := _Parser.Position;
      Token := _Parser.NextToken(tt);
      tpe := _Parser.Position - 1;
      case tt of
        ttSymbol:
        begin
          if IsString then
          begin
            if Token = '"' then
            IsString := False;
            SetColor(kl, tps, tpe, ColorString);
          end
          else if Token = '"' then
          begin
            IsString := True;
            SetColor(kl, tps, tpe, ColorString);
          end
          else if Token = '{#' then
          begin
            SetColor(kl, tps, tpe, ColorSymbol);
            IsObject := True;
          end
          else
          begin
            SetColor(kl, tps, tpe, ColorSymbol);
          end;
        end;
        else
        begin
          if IsString then
          SetColor(kl, tps, tpe, ColorString)
          else if IsObject then
          begin
            IsObject := False;
            SetColor(kl, tps, tpe, ColorSymbol);
          end
          else
          begin
            IsObject := False;
            SetColor(kl, tps, tpe, ColorText);
          end;
        end;
      end;
    until tt = ttEOF;
    Inc(kl);
  end;
end;
//TCodeHighlightG2ML END

//TPropertySet BEGIN
function TPropertySet.TProperty.GetChildren: PQuickListProperty;
begin
  Result := @_Children;
end;

constructor TPropertySet.TProperty.Create;
begin
  inherited Create;
  _PropertyType := pt_none;
  _OnChangeProc := nil;
  _Children.Clear;
  _Open := false;
  _Name := '';
end;

destructor TPropertySet.TProperty.Destroy;
begin
  inherited Destroy;
end;

procedure TPropertySet.TProperty.Clear;
  procedure FreeProperty(const Prop: TProperty);
    var i: Integer;
  begin
    for i := 0 to Prop.Children^.Count - 1 do
    FreeProperty(Prop.Children^[i]);
    Prop.Free;
  end;
  var i: Integer;
begin
  for i := 0 to _Children.Count - 1 do
  FreeProperty(_Children[i]);
  _Children.Clear;
end;

constructor TPropertySet.TPropertyPath.Create;
begin
  inherited Create;
  _AssetClass := TAsset;
  _PropertyType := pt_path;
end;

constructor TPropertySet.TPropertyButton.Create;
begin
  inherited Create;
  _PropertyType := pt_button;
end;

constructor TPropertySet.TPropertyBool.Create;
begin
  inherited Create;
  _PropertyType := pt_bool;
end;

constructor TPropertySet.TPropertyInt.Create;
begin
  inherited Create;
  _PropertyType := pt_int;
end;

constructor TPropertySet.TPropertyFloat.Create;
begin
  inherited Create;
  _PropertyType := pt_float;
end;

constructor TPropertySet.TPropertyString.Create;
begin
  inherited Create;
  _PropertyType := pt_string;
  _Editable := True;
  _AllowEmpty := False;
end;

procedure TPropertySet.TPropertyVec2.ComponentChangeProc(const Ptr: Pointer);
begin
  if Assigned(OnChange) then OnChange(Self);
end;

constructor TPropertySet.TPropertyVec2.Create;
begin
  inherited Create;
  _PropertyType := pt_vec2;
end;

procedure TPropertySet.TPropertyVec3.ComponentChangeProc(const Ptr: Pointer);
begin
  if Assigned(OnChange) then OnChange(Self);
end;

constructor TPropertySet.TPropertyVec3.Create;
begin
  inherited Create;
  _PropertyType := pt_vec3;
end;


function TPropertySet.TPropertyEnum.GetValueCount: Integer;
begin
  Result := Length(_Values);
end;

function TPropertySet.TPropertyEnum.GetValue(const Index: Integer): TValueType;
begin
  Result := _Values[Index];
end;

constructor TPropertySet.TPropertyEnum.Create;
begin
  inherited Create;
  _PropertyType := pt_enum;
  _Selection := -1;
  SetLength(_Values, 0);
end;

procedure TPropertySet.TPropertyEnum.AddValue(
  const ValueName: String;
  const Value: Byte
);
begin
  SetLength(_Values, Length(_Values) + 1);
  _Values[High(_Values)].Name := ValueName;
  _Values[High(_Values)].Value := Value;
  if _Selection = -1 then _Selection := 0;
end;

procedure TPropertySet.TPropertyEnum.SetValue(const Value: Byte);
  var i: Integer;
begin
  for i := 0 to High(_Values) do
  if _Values[i].Value = Value then
  begin
    _Selection := i;
    Exit;
  end;
end;

procedure TPropertySet.TPropertyEnum.Clear;
begin
  SetLength(_Values, 0);
end;

procedure TPropertySet.TPropertyBlendMode.ComponentChangeProc(const Ptr: Pointer);
begin
  if Assigned(OnChange) then OnChange(Ptr);
end;

constructor TPropertySet.TPropertyBlendMode.Create;
begin
  inherited Create;
  _PropertyType := pt_blend_mode;
end;

constructor TPropertySet.TPropertyComponent.Create;
begin
  inherited Create;
  _PropertyType := pt_component;
end;

constructor TPropertySet.Create;
begin
  inherited Create;
  _Root := TProperty.Create;
  _Root.Name := 'Root';
end;

destructor TPropertySet.Destroy;
begin
  Clear;
  _Root.Free;
  inherited Destroy;
end;

function TPropertySet.PropGroup(
  const Name: String;
  const Parent: TProperty
): TProperty;
begin
  Result := TProperty.Create;
  Result.Name := Name;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropPath(
  const Name: String;
  const ValuePtr: PString;
  const AssetClass: CAsset;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyPath;
begin
  Result := TPropertyPath.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.AssetClass := AssetClass;
  Result.OnChange := OnChangeProc;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropButton(
  const Name: String;
  const OnClick: TG2ProcObj;
  const Parent: TProperty
): TPropertyButton;
begin
  Result := TPropertyButton.Create;
  Result.Name := Name;
  Result.Proc := OnClick;
  Result.OnChange := nil;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropBool(
  const Name: String;
  const ValuePtr: PG2Bool;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyBool;
begin
  Result := TPropertyBool.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropInt(
  const Name: String;
  const ValuePtr: PG2IntS32;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyInt;
begin
  Result := TPropertyInt.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropFloat(
  const Name: String;
  const ValuePtr: PG2Float;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyFloat;
begin
  Result := TPropertyFloat.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropString(
  const Name: String;
  const ValuePtr: PString;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyString;
begin
  Result := TPropertyString.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropVec2(
  const Name: String;
  const ValuePtr: PG2Vec2;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyVec2;
begin
  Result := TPropertyVec2.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  PropFloat('x', @ValuePtr^.x, Result, @Result.ComponentChangeProc);
  PropFloat('y', @ValuePtr^.y, Result, @Result.ComponentChangeProc);
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropVec3(
  const Name: String;
  const ValuePtr: PG2Vec3;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyVec3;
begin
  Result := TPropertyVec3.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  PropFloat('x', @ValuePtr^.x, Result, @Result.ComponentChangeProc);
  PropFloat('y', @ValuePtr^.y, Result, @Result.ComponentChangeProc);
  PropFloat('z', @ValuePtr^.z, Result, @Result.ComponentChangeProc);
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropEnum(
  const Name: String;
  const ValuePtr: Pointer;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyEnum;
begin
  Result := TPropertyEnum.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropBlendMode(
  const Name: String;
  const ValuePtr: PG2BlendMode;
  const Parent: TProperty;
  const OnChangeProc: TG2ProcPtrObj
): TPropertyBlendMode;
  var e: TPropertyEnum;
  procedure SetupEnum;
  begin
    e.AddValue('Disable', Byte(boDisable));
    e.AddValue('Zero', Byte(boZero));
    e.AddValue('One', Byte(boOne));
    e.AddValue('Src Color', Byte(boSrcColor));
    e.AddValue('Inv Src Color', Byte(boInvSrcColor));
    e.AddValue('Dst Color', Byte(boDstColor));
    e.AddValue('Inv Dst Color', Byte(boInvDstColor));
    e.AddValue('Src Alpha', Byte(boSrcAlpha));
    e.AddValue('Inv Src Alpha', Byte(boInvSrcAlpha));
    e.AddValue('Dst Alpha', Byte(boDstAlpha));
    e.AddValue('Inv Dst Alpha', Byte(boInvDstAlpha));
  end;
begin
  Result := TPropertyBlendMode.Create;
  Result.Name := Name;
  Result.ValuePtr := ValuePtr;
  Result.OnChange := OnChangeProc;
  e := PropEnum('Color Src', @ValuePtr^.ColorSrc, Result, @Result.ComponentChangeProc);
  SetupEnum; e.SetValue(Byte(ValuePtr^.ColorSrc));
  e := PropEnum('Color Dst', @ValuePtr^.ColorDst, Result, @Result.ComponentChangeProc);
  SetupEnum; e.SetValue(Byte(ValuePtr^.ColorDst));
  e := PropEnum('Alpha Src', @ValuePtr^.AlphaSrc, Result, @Result.ComponentChangeProc);
  SetupEnum; e.SetValue(Byte(ValuePtr^.AlphaSrc));
  e := PropEnum('Alpha Dst', @ValuePtr^.AlphaDst, Result, @Result.ComponentChangeProc);
  SetupEnum; e.SetValue(Byte(ValuePtr^.AlphaDst));
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

function TPropertySet.PropComponent(
  const Name: String;
  const Component: TG2Scene2DComponent;
  const Parent: TProperty
): TPropertyComponent;
begin
  Result := TPropertyComponent.Create;
  Result.Name := Name;
  Result.ValuePtr := Component;
  if Parent <> nil then
  Parent.Children^.Add(Result)
  else
  Root.Children^.Add(Result);
end;

procedure TPropertySet.Clear;
  procedure FreeProperty(const Prop: TProperty);
    var i: Integer;
  begin
    for i := 0 to Prop.Children^.Count - 1 do
    FreeProperty(Prop.Children^[i]);
    Prop.Free;
  end;
  var i: Integer;
begin
  for i := 0 to _Root.Children^.Count - 1 do
  FreeProperty(_Root.Children^[i]);
  _Root.Children^.Clear;
end;
//TPropertySet END

//TSpinner BEGIN
procedure TSpinner.Initialize;
begin
  _Spinning := False;
  _OnSpinProc := nil;
end;

procedure TSpinner.Render;
  var c0, c1: TG2Color;
  var x0, x1, x2, y0, y1, y2, y3: Single;
begin
  c0 := App.UI.GetColorPrimary(0.5);
  if _Spinning then
  c1 := App.UI.GetColorPrimary(0.4)
  else if Frame.Contains(g2.MousePos) then
  c1 := App.UI.GetColorPrimary(0.7)
  else
  c1 := App.UI.GetColorPrimary(0.6);
  g2.PrimRect(
    _Frame.x, _Frame.y, _Frame.w, _Frame.h,
    c0
  );
  g2.PrimRect(
    _Frame.x + 2, _Frame.y + 2, _Frame.w - 4, _Frame.h - 4,
    c1
  );
  x0 := G2LerpFloat(_Frame.l, _Frame.r, 0.1);
  x1 := G2LerpFloat(_Frame.l, _Frame.r, 0.5);
  x2 := G2LerpFloat(_Frame.l, _Frame.r, 0.9);
  y0 := G2LerpFloat(_Frame.t, _Frame.b, 0.1);
  y1 := G2LerpFloat(_Frame.t, _Frame.b, 0.45);
  y2 := G2LerpFloat(_Frame.t, _Frame.b, 0.55);
  y3 := G2LerpFloat(_Frame.t, _Frame.b, 0.9);
  c0 := $ff000000;
  g2.PrimBegin(ptTriangles, bmNormal);
  g2.PrimAdd(x0, y1, c0);
  g2.PrimAdd(x1, y0, c0);
  g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x0, y2, c0);
  g2.PrimAdd(x2, y2, c0);
  g2.PrimAdd(x1, y3, c0);
  g2.PrimEnd;
end;

procedure TSpinner.Update;
  var NewValue: Integer;
begin
  if _Spinning then
  begin
    NewValue := _SpinPos - g2.MousePos.y;
    if Assigned(_OnSpinProc) and (NewValue <> _Value) then
    begin
      _OnSpinProc(NewValue - _Value);
      _Value := NewValue;
    end;
  end;
end;

procedure TSpinner.MouseDown(const Button, x, y: Integer);
begin
  if (Button = G2MB_Left) and _Frame.Contains(x, y) then
  begin
    _SpinPos := y;
    _Value := 0;
    _Spinning := True;
  end;
end;

procedure TSpinner.MouseUp(const Button, x, y: Integer);
begin
  _Spinning := False;
end;

procedure TSpinner.Scroll(const Amount: Integer);
begin

end;
//TSpinner END

//TUIWorkspaceSplitter BEGIN
procedure TUIWorkspaceSplitter.SetOrientation(const Value: TOrientation);
begin
  if _Orientation = Value then Exit;
  _Orientation := Value;
  _SplitPos := 0.5;
  OnAdjust;
end;

procedure TUIWorkspaceSplitter.SetSplitPos(const Value: Single);
begin
  _SplitPos := Value;
  OnAdjust;
end;

function TUIWorkspaceSplitter.GetSplitRect: TG2Rect;
begin
  case Orientation of
    soHorizontal:
    begin
      Result.l := G2LerpFloat(Frame.l, Frame.r, _SplitPos) - 3;
      Result.w := 6;
      Result.t := Frame.t;
      Result.b := Frame.b;
    end;
    soVertical:
    begin
      Result.l := Frame.l;
      Result.r := Frame.r;
      Result.t := G2LerpFloat(Frame.t, Frame.b, _SplitPos) - 3;
      Result.h := 6;
    end;
  end;
end;

procedure TUIWorkspaceSplitter.OnInitialize;
begin
  _Resizing := False;
end;

procedure TUIWorkspaceSplitter.OnFinalize;
begin

end;

procedure TUIWorkspaceSplitter.OnUpdate;
  var r: TG2Rect;
  var NewSplit, s: Single;
begin
  r := GetSplitRect;
  case Orientation of
    soHorizontal:
    begin
      if (_Resizing or r.Contains(g2.MousePos)) and (App.UI.Overlay = nil) then
      App.UI.Cursor := g2.Window.CursorSizeWE;
    end;
    soVertical:
    begin
      if _Resizing or r.Contains(g2.MousePos) and (App.UI.Overlay = nil) then
      App.UI.Cursor := g2.Window.CursorSizeNS;
    end;
  end;
  if _Resizing then
  begin
    case Orientation of
      soHorizontal:
      begin
        NewSplit := G2SmoothStep(g2.MousePos.x, Frame.l, Frame.r);
        if NewSplit < _SplitPos then
        begin
          s := NewSplit * Frame.w;
          if s < Children[0].GetMinWidth then
          NewSplit := Children[0].GetMinWidth / Frame.w;
        end
        else
        begin
          s := (1 - NewSplit) * Frame.w;
          if s < Children[1].GetMinWidth then
          NewSplit := 1 - Children[1].GetMinWidth / Frame.w;
        end;
        _SplitPos := NewSplit;
      end;
      soVertical:
      begin
        NewSplit := G2SmoothStep(g2.MousePos.y, Frame.t, Frame.b);
        if NewSplit < _SplitPos then
        begin
          s := NewSplit * Frame.h;
          if s < Children[0].GetMinHeight then
          NewSplit := Children[0].GetMinHeight / Frame.h;
        end
        else
        begin
          s := (1 - NewSplit) * Frame.h;
          if s < Children[1].GetMinHeight then
          NewSplit := 1 - Children[1].GetMinHeight / Frame.h;
        end;
        _SplitPos := NewSplit;
      end;
    end;
    OnAdjust;
  end;
end;

procedure TUIWorkspaceSplitter.OnAdjust;
  var ms, s, s0, s1, s2: Single;
  var f: TG2Rect;
begin
  if ChildCount < 2 then Exit;
  case _Orientation of
    soVertical:
    begin
      s := _SplitPos * Frame.h;
      ms := Children[0].GetMinHeight;
      if s < ms then
      _SplitPos := ms / Frame.h;
      s := (1 - _SplitPos) * Frame.h;
      ms := Children[1].GetMinHeight;
      if s < ms then
      _SplitPos := 1 - ms / Frame.h;
      s0 := Frame.t;
      s1 := Round(G2LerpFloat(Frame.t, Frame.b, _SplitPos));
      s2 := Frame.b;
      f.t := s0;
      f.b := s1;
      f.l := Frame.l;
      f.r := Frame.r;
      Children[0].Frame := f;
      f.t := s1;
      f.b := s2;
      Children[1].Frame := f;
    end;
    soHorizontal:
    begin
      s := _SplitPos * Frame.w;
      ms := Children[0].GetMinWidth;
      if s < ms then
      _SplitPos := ms / Frame.w;
      s := (1 - _SplitPos) * Frame.w;
      ms := Children[1].GetMinWidth;
      if s < ms then
      _SplitPos := 1 - ms / Frame.w;
      s0 := Frame.l;
      s1 := Round(G2LerpFloat(Frame.l, Frame.r, _SplitPos));
      s2 := Frame.r;
      f.l := s0;
      f.r := s1;
      f.t := Frame.t;
      f.b := Frame.b;
      Children[0].Frame := f;
      f.l := s1;
      f.r := s2;
      Children[1].Frame := f;
    end;
  end;
end;

procedure TUIWorkspaceSplitter.OnMouseDown(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  r := GetSplitRect;
  if r.Contains(x, y) then
  _Resizing := True;
end;

procedure TUIWorkspaceSplitter.OnMouseUp(const Button, x, y: Integer);
begin
  _Resizing := False;
end;

procedure TUIWorkspaceSplitter.OnChildAdd(const Child: TUIWorkspace);
begin
  OnAdjust;
end;

procedure TUIWorkspaceSplitter.OnChildRemove(const Child: TUIWorkspace);
begin
  OnAdjust;
end;

function TUIWorkspaceSplitter.GetMinWidth: Single;
begin
  case _Orientation of
    soVertical:
    begin
      Result := G2Max(Children[0].GetMinWidth, Children[1].GetMinWidth);
    end;
    soHorizontal:
    begin
      Result := Children[0].GetMinWidth + Children[1].GetMinWidth;
    end;
  end;
end;

function TUIWorkspaceSplitter.GetMinHeight: Single;
begin
  case _Orientation of
    soVertical:
    begin
      Result := Children[0].GetMinHeight + Children[1].GetMinHeight;
    end;
    soHorizontal:
    begin
      Result := G2Max(Children[0].GetMinHeight, Children[1].GetMinHeight);
    end;
  end;
end;
//TUIWorkspaceSplitter END

//TUIWorkspaceFrame BEGIN
procedure TUIWorkspaceFrame.SetChildIndex(const Value: Integer);
begin
  if _ChildIndex = Value then Exit;
  _ChildIndex := Value;
  OnAdjust;
end;

function TUIWorkspaceFrame.PointInChild(const x, y: Single; var ChildFrame: TG2Rect): Integer;
  var r: TG2Rect;
  var i: Integer;
begin
  if ChildCount > 1 then
  begin
    r.l := Frame.l + _Padding + _BorderSize;
    r.t := Frame.b - _Padding - _BorderSize - _FootterSize;
    r.b := r.t + _FootterSize;
    for i := 0 to ChildCount - 1 do
    begin
      r.w := App.UI.Font1.TextWidth(Children[i].GetWorkspaceName) + _TextSpacing * 2;
      r.r := G2Min(r.r, Frame.r - _Padding - _BorderSize);
      if r.Contains(x, y) then
      begin
        ChildFrame := r;
        Result := i;
        Exit;
      end;
      r.l := r.r;
    end;
    Result := -1;
  end
  else
  Result := -1;
end;

function TUIWorkspaceFrame.PointInChild(const x, y: Single): Integer;
  var ChildFrame: TG2Rect;
begin
  Result := PointInChild(x, y, ChildFrame);
end;

procedure TUIWorkspaceFrame.OnInitialize;
begin
  _Dragging := False;
  _ChildIndex := -1;
  _Padding := 2;
  _BorderSize := 4;
  _HeaderHeight := 22;
  _FootterSize := 22;
  _TextSpacing := 4;
end;

procedure TUIWorkspaceFrame.OnFinalize;
begin

end;

procedure TUIWorkspaceFrame.OnAdjust;
  var i: Integer;
begin
  _ClientFrame.l := Frame.l + _BorderSize + _Padding;
  _ClientFrame.t := Frame.t + _BorderSize + _HeaderHeight + _Padding;
  _ClientFrame.r := Frame.r - _BorderSize - _Padding;
  _ClientFrame.b := Frame.b - _BorderSize - _Padding;
  if ChildCount > 1 then
  _ClientFrame.b := _ClientFrame.b - _FootterSize;
  if (_ChildIndex > -1) and (Children[_ChildIndex].CustomHeader) then
  Children[_ChildIndex].HeaderFrame := G2Rect(
    Frame.x + _Padding + _BorderSize + _HeaderHeight,
    Frame.y + _Padding + _BorderSize,
    Frame.w - (_Padding + _BorderSize + _HeaderHeight) * 2,
    _HeaderHeight
  );
  for i := 0 to ChildCount - 1 do
  Children[i].Frame := _ClientFrame;
end;

procedure TUIWorkspaceFrame.OnUpdate;
  var ci, NewChildPos: Integer;
  var ChildFrame: TG2Rect;
  var mc: TPoint;
  var Ratio: Single;
begin
  if ChildCount > 1 then
  begin
    if g2.MouseDown[G2MB_Left] then
    begin
      if not _Dragging
      and (PointInChild(g2.MouseDownPos[G2MB_Left].x, g2.MouseDownPos[G2MB_Left].y) = _ChildIndex)
      and ((G2Vec2(g2.MousePos) - G2Vec2(g2.MouseDownPos[G2MB_Left])).Len > 8) then
      _Dragging := True;
    end
    else
    _Dragging := False;
    if _Dragging then
    begin
      mc := g2.MousePos;
      ci := PointInChild(mc.x, mc.y, ChildFrame);
      if (ci > -1) and (ci <> _ChildIndex) then
      begin
        Ratio := (mc.x - ChildFrame.l) / ChildFrame.w;
        if (Ratio < 0.5) then
        NewChildPos := ci - 1
        else
        NewChildPos := ci + 1;
        if (NewChildPos <> _ChildIndex) then
        begin
          if NewChildPos > _ChildIndex then
          NewChildPos := NewChildPos - 1
          else
          NewChildPos := NewChildPos + 1;
          ChildReposition(_ChildIndex, NewChildPos);
          _ChildIndex := NewChildPos;
        end;
      end;
    end;
  end
  else
  _Dragging := False;
end;

procedure TUIWorkspaceFrame.OnRender;
  var x0, x1, x2, x3, y0, y1, y2, y3, w, h: Single;
  var c0, c1: TG2Color;
  var r: TG2Rect;
  var mc: TPoint;
  var i, mcw: Integer;
begin
  x0 := Frame.l + _Padding;
  x1 := Frame.l + _BorderSize + _Padding;
  x2 := Frame.r - _BorderSize - _Padding;
  x3 := Frame.r - _Padding;
  y0 := Frame.t + _Padding;
  y1 := Frame.t + _BorderSize + _Padding;
  y2 := Frame.b - _BorderSize - _Padding;
  y3 := Frame.b - _Padding;
  if ChildCount > 1 then
  y2 := y2 - _FootterSize;
  c0 := App.UI.GetColorPrimary(0.4);
  g2.PrimBegin(ptTriangles, bmNormal);
  g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x3, y0, c0); g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x1, y1, c0); g2.PrimAdd(x3, y0, c0); g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x3, y0, c0); g2.PrimAdd(x3, y3, c0); g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x2, y1, c0); g2.PrimAdd(x3, y3, c0); g2.PrimAdd(x2, y2, c0);
  g2.PrimAdd(x3, y3, c0); g2.PrimAdd(x0, y3, c0); g2.PrimAdd(x2, y2, c0);
  g2.PrimAdd(x2, y2, c0); g2.PrimAdd(x0, y3, c0); g2.PrimAdd(x1, y2, c0);
  g2.PrimAdd(x0, y3, c0); g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x1, y2, c0);
  g2.PrimAdd(x1, y2, c0); g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x1, y1, c0);

  x0 := x1; x1 := x0 + _HeaderHeight; x3 := x2; x2 := x3 - _HeaderHeight;
  y0 := y1; y1 := y1 + _HeaderHeight;
  g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x1, y0, c0); g2.PrimAdd(x0, y1, c0);
  g2.PrimAdd(x0, y1, c0); g2.PrimAdd(x1, y0, c0); g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x2, y0, c0); g2.PrimAdd(x3, y0, c0); g2.PrimAdd(x2, y1, c0);
  g2.PrimAdd(x2, y1, c0); g2.PrimAdd(x3, y0, c0); g2.PrimAdd(x3, y1, c0);
  c0 := App.UI.GetColorPrimary(0.13);
  g2.PrimAdd(x1, y0, c0); g2.PrimAdd(x2, y0, c0); g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x1, y1, c0); g2.PrimAdd(x2, y0, c0); g2.PrimAdd(x2, y1, c0);
  r.l := x2 + 4; r.t := y0; r.r := x3; r.b := y1 - 4;
  if r.Contains(g2.MousePos) then
  App.UI.DrawCross(r, App.UI.GetColorSecondary(0.8))
  else
  App.UI.DrawCross(r, App.UI.GetColorPrimary(0.8));
  g2.PrimEnd;
  r.l := x0; r.r := x1 - 2; r.b := y1 - 2;
  if r.Contains(g2.MousePos) then
  App.UI.DrawCircles(r, App.UI.GetColorSecondary(0.8))
  else
  App.UI.DrawCircles(r, App.UI.GetColorPrimary(0.8));

  if _ChildIndex > -1 then
  begin
    if Children[_ChildIndex].CustomHeader then
    begin
      App.UI.PushClipRect(Children[_ChildIndex].HeaderFrame);
      Children[_ChildIndex].OnHeaderRender;
      App.UI.PopClipRect;
    end
    else
    App.UI.Font1.Print(
      Round(x1 + _TextSpacing), Round(y0 + (_HeaderHeight - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, App.UI.GetColorPrimary(1), Children[_ChildIndex].GetWorkspaceName, bmNormal, tfPoint
    );
  end;

  if ChildCount > 1 then
  begin
    mc := g2.MousePos;
    mcw := PointInChild(mc.x, mc.y);
    x0 := Frame.l + _Padding + _BorderSize;
    y0 := Frame.b - _Padding - _BorderSize - _FootterSize;
    App.UI.PushClipRect(G2Rect(x0, y0, Frame.w - (_Padding + _BorderSize) * 2, _FootterSize));
    for i := 0 to ChildCount - 1 do
    begin
      w := App.UI.Font1.TextWidth(Children[i].GetWorkspaceName);
      h := App.UI.Font1.TextHeight('A');
      if i = _ChildIndex then
      begin
        if _Dragging then
        c1 := $ff004080
        else
        c1 := c0;
        g2.PrimRect(
          x0, y0, w + _TextSpacing * 2, _FootterSize,
          c1, bmNormal
        );
        c1 := App.UI.GetColorPrimary(1);
      end
      else
      begin
        if mcw = i then
        c1 := App.UI.GetColorSecondary(1)
        else
        c1 := App.UI.GetColorPrimary(0.8);
      end;
      App.UI.Font1.Print(
        x0 + _TextSpacing,
        y0 + (_FootterSize - h) * 0.5,
        1, 1, c1,
        Children[i].GetWorkspaceName,
        bmNormal, tfPoint
      );
      x0 := x0 + _TextSpacing * 2 + w;
    end;
    App.UI.PopClipRect;
  end;
end;

procedure TUIWorkspaceFrame.OnMouseDown(const Button, x, y: Integer);
begin
  if _ChildIndex > -1 then
  begin
    if PtInDrag(x, y) then
    begin
      App.UI.OverlayWorkspace.Workspace := Children[_ChildIndex];
      App.UI.Overlay := App.UI.OverlayWorkspace;
      App.UI.MsgExtractWorkspace(Children[_ChildIndex]);
    end
    else if Children[_ChildIndex].CustomHeader and Children[_ChildIndex].HeaderFrame.Contains(x, y) then
    begin
      Children[_ChildIndex].OnHeaderMouseDown(Button, x, y);
    end;
  end;
end;

procedure TUIWorkspaceFrame.OnMouseUp(const Button, x, y: Integer);
  var i: Integer;
begin
  if ChildCount > 1 then
  begin
    i := PointInChild(x, y);
    if (i > -1)
    and (i = PointInChild(g2.MouseDownPos[Button].x, g2.MouseDownPos[Button].y)) then
    begin
      _ChildIndex := i;
      App.UI.MsgResizeWorkspace(Self, Frame, True);
      Exit;
    end;
  end;
  if (PtInClose(x, y) and PtInClose(g2.MouseDownPos[Button].x, g2.MouseDownPos[Button].y)) then
  begin
    if ChildCount > 1 then
    begin
      App.UI.MsgCloseWorkspace(Children[_ChildIndex], True);
    end
    else
    App.UI.MsgCloseWorkspace(Self, True);
    Exit;
  end;
  if (_ChildIndex > -1) and Children[_ChildIndex].CustomHeader then
  Children[_ChildIndex].OnHeaderMouseUp(Button, x, y);
end;

procedure TUIWorkspaceFrame.OnChildAdd(const Child: TUIWorkspace);
begin
  if _ChildIndex = -1 then
  begin
    _ChildIndex := 0;
    Children[_ChildIndex].Frame := _ClientFrame;
  end;
  OnAdjust;
end;

procedure TUIWorkspaceFrame.OnChildRemove(const Child: TUIWorkspace);
  var i: Integer;
begin
  for i := 0 to ChildCount - 1 do
  if Child = Children[i] then
  begin
    if i < _ChildIndex then
    begin
      _ChildIndex := G2Max(0, _ChildIndex - 1);
    end
    else
    begin
      _ChildIndex := G2Min(ChildCount - 2, _ChildIndex);
    end;
    Break;
  end;
  if ChildCount > 1 then
  App.UI.MsgResizeWorkspace(Self, Frame, True);
end;

function TUIWorkspaceFrame.PtInClose(const x, y: Integer): Boolean;
  var r: TG2Rect;
begin
  r.l := Frame.r - _BorderSize - _Padding - _HeaderHeight;
  r.t := Frame.t + _BorderSize + _Padding;
  r.r := r.l + _HeaderHeight;
  r.b := r.t + _HeaderHeight;
  Result := r.Contains(G2Vec2(x, y));
end;

function TUIWorkspaceFrame.PtInDrag(const x, y: Integer): Boolean;
  var r: TG2Rect;
begin
  r.l := Frame.l + _BorderSize + _Padding;
  r.t := Frame.t + _BorderSize + _Padding;
  r.r := r.l + _HeaderHeight;
  r.b := r.t + _HeaderHeight;
  Result := r.Contains(G2Vec2(x, y));
end;

procedure TUIWorkspaceFrame.Update;
begin
  if _ChildIndex > -1 then
  Children[_ChildIndex].Update;
  OnUpdate;
end;

procedure TUIWorkspaceFrame.Render;
  var r: TRect;
begin
  if _ChildIndex > -1 then
  begin
    r := _ClientFrame;
    App.UI.PushClipRect(r);
    Children[_ChildIndex].Render;
    App.UI.PopClipRect;
  end;
  OnRender;
end;

procedure TUIWorkspaceFrame.MouseDown(const Button, x, y: Integer);
begin
  if (_ChildIndex > -1) and (_ClientFrame.Contains(x, y)) then
  Children[_ChildIndex].MouseDown(Button, x, y);
  OnMouseDown(Button, x, y);
end;

procedure TUIWorkspaceFrame.MouseUp(const Button, x, y: Integer);
begin
  if _ChildIndex > -1 then
  Children[_ChildIndex].MouseUp(Button, x, y);
  OnMouseUp(Button, x, y);
end;

function TUIWorkspaceFrame.GetMinWidth: Single;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to ChildCount - 1 do
  Result := G2Max(Children[i].GetMinWidth, Result);
  Result := Result + _BorderSize * 2 + _Padding * 2 + _HeaderHeight * 2;
end;

function TUIWorkspaceFrame.GetMinHeight: Single;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to ChildCount - 1 do
  Result := G2Max(Children[i].GetMinHeight, Result);
  Result := Result + _BorderSize * 2 + _Padding * 2 + _HeaderHeight;// + _FootterSize;
  if ChildCount > 1 then Result := Result + _FootterSize;
end;

function TUIWorkspaceFrame.GetInsertPositon(const x, y: Single): TUIWorkspaceInsertPosition;
  var gx, gy: Single;
begin
  if not Frame.Contains(x, y) then
  begin
    Result := ipNone;
    Exit;
  end;
  Result := ipMiddle;
  gx := (x - Frame.x) / Frame.w;
  gy := (y - Frame.y) / Frame.h;
  if gx < 0.3 then
  begin
    if gy < gx then
    Result := ipTop
    else if 1 - gy < gx then
    Result := ipBottom
    else
    Result := ipLeft;
  end
  else if gx > 0.6 then
  begin
    if gy < 1 - gx then
    Result := ipTop
    else if gy > gx then
    Result := ipBottom
    else
    Result := ipRight
  end
  else
  begin
    if gy < 0.3 then
    Result := ipTop
    else if gy > 0.6 then
    Result := ipBottom;
  end;
end;

function TUIWorkspaceFrame.CanInsert(const Workspace: TUIWorkspace; const InsertPosition: TUIWorkspaceInsertPosition): Boolean;
begin
  case InsertPosition of
    ipTop, ipBottom:
    begin
      Result := (_ClientFrame.h - GetMinHeight > Workspace.GetMinHeight) and (_ClientFrame.w > Workspace.GetMinWidth);
      Exit;
    end;
    ipLeft, ipRight:
    begin
      Result := (_ClientFrame.w - GetMinWidth > Workspace.GetMinWidth) and (_ClientFrame.h > Workspace.GetMinHeight);
      Exit;
    end;
    ipMiddle:
    begin
      Result := (_ClientFrame.w > Workspace.GetMinWidth) and (_ClientFrame.h > Workspace.GetMinHeight);
      Exit;
    end;
  end;
  Result := False;
end;

//TUIWorkspaceFrame END

//TUIWorkspaceEmpty BEGIN
procedure TUIWorkspaceEmpty.OnRender;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    $808080ff
  );
end;

class function TUIWorkspaceEmpty.GetWorkspaceName: AnsiString;
begin
  Result := 'Empty';
end;

function TUIWorkspaceEmpty.GetMinWidth: Single;
begin
  Result := 64;
end;

function TUIWorkspaceEmpty.GetMinHeight: Single;
begin
  Result := 64;
end;
//TUIWorkspaceEmpty END

//TUIWorkspaceLog BEGIN
procedure TUIWorkspaceLog.OnSlide;
begin

end;

procedure TUIWorkspaceLog.OnInitialize;
begin
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _ScrollV.OnChange := @OnSlide;
end;

procedure TUIWorkspaceLog.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame; r.l := r.r - 18;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := App.UI.Font1.TextHeight('A') * App.Log.LineCount;
  _ScrollV.ParentSize := r.h;
end;

procedure TUIWorkspaceLog.OnRender;
  var x, y, h: Single;
  var i: Integer;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.25)
  );
  x := Frame.l + 4;
  y := Frame.t + 4 - _ScrollV.GetPosAbsolute;
  h := App.UI.Font1.TextHeight('A');
  for i := 0 to App.Log.LineCount - 1 do
  begin
    App.UI.Font1.Print(x, y, 1, 1, App.UI.GetColorPrimary(1), App.Log.Lines[i], bmNormal, tfPoint);
    y := y + h;
  end;
  _ScrollV.Render;
end;

procedure TUIWorkspaceLog.OnUpdate;
begin
  _ScrollV.ContentSize := App.UI.Font1.TextHeight('A') * App.Log.LineCount + 4;
  _ScrollV.Update;
end;

procedure TUIWorkspaceLog.OnMouseDown(const Button, x, y: Integer);
begin
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceLog.OnMouseUp(const Button, x, y: Integer);
begin
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceLog.OnScroll(const y: Integer);
begin
  _ScrollV.PosAbsolute := G2Min(_ScrollV.PosAbsolute - y, _ScrollV.ContentSize - _ScrollV.ParentSize);
  if _ScrollV.PosAbsolute < 0 then
  _ScrollV.PosAbsolute := 0;
  OnSlide;
end;

class function TUIWorkspaceLog.GetWorkspaceName: AnsiString;
begin
  Result := 'Log';
end;

function TUIWorkspaceLog.GetMinWidth: Single;
begin
  Result := 100;
end;

function TUIWorkspaceLog.GetMinHeight: Single;
begin
  Result := 80;
end;
//TUIWorkspaceLog END

//TUIWorkspaceConsole BEGIN
procedure TUIWorkspaceConsole.OnCommandUpdate;
begin
  if App.UI.TextEdit.Enabled then
  begin
    App.UI.TextEdit.Frame := G2Rect(
      Frame.l, Frame.b - _CommandHeight, Frame.w, _CommandHeight
    );
  end;
end;

procedure TUIWorkspaceConsole.OnCommandEnter;
begin
  App.Console.Command(_Command);
  _Command := '';
  App.UI.TextEdit.TextUpdated;
  OnCommandUpdate;
end;

procedure TUIWorkspaceConsole.OnCommandCursorMove;
  var cp: TG2Vec2;
  var s: Single;
  var r: TG2Rect;
begin
  cp := App.UI.TextEdit.GetCursorPos;
  s := App.UI.TextEdit.Frame.w * 0.25;
  r := App.UI.TextEdit.Frame;
  while cp.x < r.l + 2 do
  begin
    _TextPos.x := G2Min(r.l + 2, _TextPos.x + s);
    cp.x := cp.x + s;
  end;
  while cp.x > r.r do
  begin
    _TextPos.x := _TextPos.x - s;
    cp.x := cp.x - s;
  end;
end;

procedure TUIWorkspaceConsole.OnSlide;
begin

end;

procedure TUIWorkspaceConsole.OnInitialize;
begin
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _ScrollV.OnChange := @OnSlide;
  _CommandHeight := App.UI.Font1.TextHeight('A') + 4;
  _SeparatorHeight := 4;
  _Command := '';
end;

procedure TUIWorkspaceConsole.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame; r.l := r.r - 18; r.b := r.b - _CommandHeight - _SeparatorHeight;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := (App.UI.Font1.TextHeight('A') + 2) * App.Console.LineCount + 4;
  _ScrollV.ParentSize := r.h;
end;

procedure TUIWorkspaceConsole.OnRender;
  var x, y, h: Single;
  var i: Integer;
  var r: TG2Rect;
begin
  g2.PrimRect(Frame.x, Frame.y, Frame.w, Frame.h, App.UI.GetColorPrimary(0.25));
  g2.PrimRect(Frame.l, Frame.b - _CommandHeight - _SeparatorHeight, Frame.w, _SeparatorHeight, App.UI.GetColorPrimary(0.4), bmNormal);
  if Length(_Command) > 0 then
  App.UI.Font1.Print(
    _TextPos.x,
    _TextPos.y,
    1, 1, $ffffffff,
    _Command, bmNormal, tfPoint
  );
  h := App.UI.Font1.TextHeight('A');
  x := Frame.l + 4;
  y := Frame.t + 4 + ((App.Console.LineCount - 1) * (h + 2)) - _ScrollV.GetPosAbsolute;
  r := Frame;
  r.b := r.b - _CommandHeight - _SeparatorHeight;
  App.UI.PushClipRect(r);
  for i := 0 to App.Console.LineCount - 1 do
  begin
    App.UI.Font1.Print(x, y, 1, 1, App.UI.GetColorPrimary(1), App.Console.Lines[i], bmNormal, tfPoint);
    y := y - h - 2;
  end;
  _ScrollV.Render;
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceConsole.OnUpdate;
begin
  _ScrollV.ContentSize := (App.UI.Font1.TextHeight('A') + 2) * App.Console.LineCount + 4;
  _ScrollV.Update;
end;

procedure TUIWorkspaceConsole.OnMouseDown(const Button, x, y: Integer);
begin
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceConsole.OnMouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  r.l := Frame.l;
  r.r := Frame.r;
  r.b := Frame.b;
  r.t := Frame.b - _CommandHeight;
  if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
  begin
    App.UI.TextEdit.Enable(@_Command, @_TextPos, App.UI.Font1, @OnCommandUpdate, '', @OnCommandEnter, @OnCommandCursorMove);
    App.UI.TextEdit.AllowSymbols := True;
    App.UI.TextEdit.MaxLength := 0;
    _TextPos := G2Vec2(Frame.l + 2, Frame.b - _CommandHeight + 2);
    OnCommandUpdate;
    App.UI.TextEdit.AdjustCursor(x, y);
  end;
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceConsole.OnScroll(const y: Integer);
begin
  _ScrollV.PosAbsolute := G2Min(_ScrollV.PosAbsolute - y, _ScrollV.ContentSize - _ScrollV.ParentSize);
  if _ScrollV.PosAbsolute < 0 then
  _ScrollV.PosAbsolute := 0;
  OnSlide;
end;

class function TUIWorkspaceConsole.GetWorkspaceName: AnsiString;
begin
  Result := 'Console';
end;

function TUIWorkspaceConsole.GetMinWidth: Single;
begin
  Result := 100;
end;

function TUIWorkspaceConsole.GetMinHeight: Single;
begin
  Result := 50;
end;
//TUIWorkspaceConsole END

//TUIWorkspaceCode BEGIN
procedure TUIWorkspaceCode.OnCodeChange;
begin
  _HighlightRescan := True;
  UpdateScrollBarV;
  UpdateScrollBarH;
end;

procedure TUIWorkspaceCode.OnCodeCursorMove;
  var CursorPos: TG2Vec2;
  var d: Single;
begin
  if _FileIndex > -1 then
  begin
    CursorPos := App.UI.TextEdit.GetCursorPos;
    while CursorPos.x < _CodeFrame.l do
    begin
      d := _CodeFrame.l - CursorPos.x;
      CursorPos.x := CursorPos.x + d;
      _Files[_FileIndex]^.TextPos.x := G2Min(_Files[_FileIndex]^.TextPos.x + d, 0);
      _ScrollH.PosAbsolute := -_Files[_FileIndex]^.TextPos.x;
    end;
    while CursorPos.x > _CodeFrame.r do
    begin
      d := CursorPos.x - _CodeFrame.r;
      CursorPos.x := CursorPos.x - d;
      _Files[_FileIndex]^.TextPos.x := _Files[_FileIndex]^.TextPos.x - d;
      _ScrollH.PosAbsolute := -_Files[_FileIndex]^.TextPos.x;
    end;
    while CursorPos.y - _FontSize.y < _CodeFrame.t do
    begin
      d := _CodeFrame.t - (CursorPos.y - _FontSize.y);
      CursorPos.y := CursorPos.y + d;
      _Files[_FileIndex]^.TextPos.y := G2Min(_Files[_FileIndex]^.TextPos.y + d, 0);
      _ScrollV.PosAbsolute := -_Files[_FileIndex]^.TextPos.y;
    end;
    while CursorPos.y > _CodeFrame.b do
    begin
      d := CursorPos.y - _CodeFrame.b;
      CursorPos.y := CursorPos.y - d;
      _Files[_FileIndex]^.TextPos.y := _Files[_FileIndex]^.TextPos.y - d;
      _ScrollV.PosAbsolute := -_Files[_FileIndex]^.TextPos.y;
    end;
    UpdateCodeFrames;
    UpdateScrollBarV;
    UpdateScrollBarH;
    UpdateTextPos;
  end;
end;

procedure TUIWorkspaceCode.OnTextPosChange;
  var tp: TG2Vec2;
begin
  tp.x := _CodeFrame.l + _TextOffset;
  tp.y := _CodeFrame.t;
  if _FileIndex > -1 then
  tp := tp + _Files[_FileIndex]^.TextPos;
  tp := _TextPos - tp;
  if _FileIndex > -1 then
  _Files[_FileIndex]^.TextPos := _Files[_FileIndex]^.TextPos + tp;
  UpdateCodeFrames;
  UpdateScrollBarV;
  UpdateScrollBarH;
  UpdateTextPos;
end;

procedure TUIWorkspaceCode.OnSliderV;
begin
  if _FileIndex > -1 then
  begin
    _Files[_FileIndex]^.TextPos.y := -_ScrollV.PosAbsolute;
    UpdateCodeFrames;
    UpdateScrollBarV;
    UpdateTextPos;
  end;
end;

procedure TUIWorkspaceCode.OnSliderH;
begin
  if _FileIndex > -1 then
  begin
    _Files[_FileIndex]^.TextPos.x := -_ScrollH.PosAbsolute;
    UpdateScrollBarH;
    UpdateTextPos;
  end;
end;

procedure TUIWorkspaceCode.OnMouseScroll(const y: Integer);
begin
  if _FileIndex > -1 then
  begin
    _Files[_FileIndex]^.TextPos.y := G2Min(_Files[_FileIndex]^.TextPos.y + y, 0);
    OnAdjust;
  end;
end;

procedure TUIWorkspaceCode.UpdateTextPos;
begin
  _TextPos.x := _CodeFrame.l + _TextOffset;
  _TextPos.y := _CodeFrame.t;
  if _FileIndex > -1 then
  _TextPos := _TextPos + _Files[_FileIndex]^.TextPos;
end;

procedure TUIWorkspaceCode.UpdateScrollBarV;
  var LinesSize: Single;
begin
  _ScrollV.ParentSize := _CodeFrame.h;
  if _FileIndex > -1 then
  begin
    LinesSize := (G2Max(Length(_Files[_FileIndex]^.Lines), 16)) * _FontSize.y;
    _ScrollV.ContentSize := G2Max(-_Files[_FileIndex]^.TextPos.y + _CodeFrame.h, LinesSize);
    _ScrollV.PosAbsolute := -_Files[_FileIndex]^.TextPos.y;
  end
  else
  _ScrollV.ContentSize := 16 * _FontSize.y;
end;

procedure TUIWorkspaceCode.UpdateScrollBarH;
  var LinesSize: Single;
begin
  _ScrollH.ParentSize := _CodeFrame.w;
  LinesSize := 1024 * _FontSize.x + _TextOffset;
  if _FileIndex > -1 then
  begin
    _ScrollH.ContentSize := G2Max(LinesSize, -_Files[_FileIndex]^.TextPos.x + _CodeFrame.w);
    _ScrollH.PosAbsolute := -_Files[_FileIndex]^.TextPos.x;
  end
  else
  _ScrollH.ContentSize := LinesSize;
end;

procedure TUIWorkspaceCode.UpdateCodeFrames;
  var LineCount: Integer;
begin
  _CodeFrame := Frame;
  _CodeFrame.l := HeaderFrame.l;
  _CodeFrame.b := _CodeFrame.b - _ScrollSize;
  _CodeFrame.r := _CodeFrame.r - _ScrollSize;
  if (_FileIndex > -1) then
  LineCount := G2Max(Round((-_Files[_FileIndex]^.TextPos.y + _CodeFrame.h) / _FontSize.y) + 1, 1000)
  else
  LineCount := 1000;
  _LineNumberFrame := _CodeFrame;
  _LineNumberFrame.w := Length(IntToStr(LineCount)) * _FontSize.x + 8;
  _CodeFrame.l := _LineNumberFrame.r;
end;

function TUIWorkspaceCode.GetCodeFile(const Index: Integer): PCodeFile;
begin
  Result := _Files[Index];
end;

function TUIWorkspaceCode.GetCodeFileCount: Integer;
begin
  Result := _Files.Count;
end;

procedure TUIWorkspaceCode.SetFileIndex(const Value: Integer);
begin
  if _FileIndex = Value then Exit;
  _FileIndex := Value;
  if (_FileIndex > -1) then
  begin
    if (App.CodeInsight.CurCodeFile <> _Files[_FileIndex]) then
    App.CodeInsight.CurCodeFile := _Files[_FileIndex];
  end
  else
  App.CodeInsight.CurCodeFile := nil;
  UpdateTextPos;
end;

function TUIWorkspaceCode.PtInFile(const x, y: Single; var InDrag, InClose: Boolean; var FileFrame: TG2Rect): Integer;
  var i: Integer;
  var r, ri: TG2Rect;
  var cx, w, ics: Single;
begin
  InDrag := False;
  InClose := False;
  r := HeaderFrame;
  if (y < r.y + _FileSpacing) or (y > r.b) or (x < r.l) or (x > r.r) then
  begin
    Result := -1;
    Exit;
  end;
  cx := r.x + _FileSpacing;
  for i := 0 to _Files.Count - 1 do
  begin
    w := App.UI.Font1.TextWidth(_Files[i]^.GetCaption) + _FileTabBorders * 2;
    if (x > cx) and (x < cx + w) then
    begin
      FileFrame := HeaderFrame;
      FileFrame.l := cx;
      FileFrame.r := cx + w;
      ics := _FileIconSize * _FileIconCloseScale;
      ri := G2Rect(cx + (_FileTabBorders - _FileIconSize) * 0.5, r.y + (r.h - _FileIconSize) * 0.5, _FileIconSize, _FileIconSize);
      if ri.Contains(x, y) then
      InDrag := True;
      ri.x := cx + w - _FileTabBorders + (_FileTabBorders - ics) * 0.5;
      ri.y := r.y + (r.h - ics) * 0.5;
      ri.w := ics;
      ri.h := ics;
      if ri.Contains(x, y) then
      InClose := True;
      Result := i;
      Exit;
    end;
    cx := cx + w + _FileSpacing;
  end;
  Result := -1;
end;

function TUIWorkspaceCode.PtInFile(const x, y: Single; var InDrag, InClose: Boolean): Integer;
  var FileFrame: TG2Rect;
begin
  Result := PtInFile(x, y, InDrag, InClose, FileFrame);
end;

function TUIWorkspaceCode.PtInFile(const x, y: Single; var FileFrame: TG2Rect): Integer;
  var InDrag, InClose: Boolean;
begin
  Result := PtInFile(x, y, InDrag, InClose, FileFrame);
end;

function TUIWorkspaceCode.PtInFile(const x, y: Single): Integer;
  var InDrag, InClose: Boolean;
  var FileFrame: TG2Rect;
begin
  Result := PtInFile(x, y, InDrag, InClose, FileFrame);
end;

procedure TUIWorkspaceCode.AddToolItem(const Icon: TG2Texture2D; const OnClick: TG2ProcObj = nil);
  var ToolItem: PToolItem;
begin
  if Icon <> nil then
  begin
    New(ToolItem);
    ToolItem^.Icon := Icon;
    ToolItem^.OnClick := OnClick;
    _ToolItemList.Add(ToolItem);
  end
  else
  _ToolItemList.Add(nil);
end;

procedure TUIWorkspaceCode.BtnDocEmpty;
begin
  NewCodeFile;
end;

procedure TUIWorkspaceCode.BtnDocSave;
  var sd: TSaveDialog;
begin
  if _FileIndex > -1 then
  begin
    if _Files[_FileIndex]^.IsSaved then
    _Files[_FileIndex]^.Save(_Files[_FileIndex]^.FilePath + _Files[_FileIndex]^.FileName)
    else
    begin
      sd := TSaveDialog.Create(nil);
      sd.DefaultExt := '.pas';
      g2.Pause := True;
      if sd.Execute then
      begin
        _HighlightRescan := True;
        _Files[_FileIndex]^.Save(sd.FileName);
      end;
      g2.Pause := False;
      sd.Free;
    end;
  end;
end;

procedure TUIWorkspaceCode.BtnDocLoad;
  var od: TOpenDialog;
  var cf: PCodeFile;
begin
  od := TOpenDialog.Create(nil);
  g2.Pause := True;
  if od.Execute then
  begin
    cf := NewCodeFile;
    cf^.Load(od.FileName);
    SelectCodeFile(cf);
  end;
  g2.Pause := False;
  od.Free;
end;

procedure TUIWorkspaceCode.OnInitialize;
begin
  _Font := App.UI.FontCode;
  _FontB := App.UI.FontCodeB;
  _FontI := App.UI.FontCodeI;
  _FontSize.x := _Font.TextWidth('A');
  _FontSize.y := _Font.TextHeight('A');
  _ScrollSize := 18;
  _FileIconSize := 16;
  _FileIconCloseScale := 0.8;
  _FileSpacing := 2;
  _FileTabBorders := 4 + _FileIconSize;
  _ToolItemsOffset := 4;
  _ToolItemsSeparator := 6;
  _ToolItemsSpacing := 4;
  _TextOffset := 4;
  _ScrollH.Initialize;
  _ScrollH.Orientation := sbHorizontal;
  _ScrollH.OnChange := @OnSliderH;
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _ScrollV.OnChange := @OnSliderV;
  _ToolItemList.Clear;
  AddToolItem(App.UI.TexDocEmpty, @BtnDocEmpty);
  AddToolItem(nil);
  AddToolItem(App.UI.TexFileSave, @BtnDocSave);
  AddToolItem(App.UI.TexFileOpen, @BtnDocLoad);
  _Files.Clear;
  _HighlightPascal := TCodeHighlightPascal.Create;
  _HighlightG2ML := TCodeHighlightG2ML.Create;
  _HighlightPlain := TCodeHighlight.Create;
  _Highlight := _HighlightPascal;
  _HighlightRescan := False;
  _HighlightLineStart := -1;
  _HighlightLineEnd := -1;
  CustomHeader := True;
  _FileIndex := -1;
end;

procedure TUIWorkspaceCode.OnFinalize;
  var i: Integer;
begin
  _HighlightPlain.Free;
  _HighlightPascal.Free;
  _HighlightG2ML.Free;
  for i := 0 to _Files.Count - 1 do
  begin
    _Files[i]^.Finalize;
    Dispose(_Files[i]);
  end;
  _Files.Clear;
  for i := 0 to _ToolItemList.Count - 1 do
  if _ToolItemList[i] <> nil then
  Dispose(_ToolItemList[i]);
  _ToolItemList.Clear;
end;

procedure TUIWorkspaceCode.OnAdjust;
  var r: TG2Rect;
begin
  UpdateCodeFrames;
  r := Frame;
  r.l := r.r - _ScrollSize;
  r.b := r.b - _ScrollSize;
  _ScrollV.Frame := r;
  UpdateScrollBarV;
  r := Frame;
  r.l := HeaderFrame.l;
  r.r := r.r - _ScrollSize;
  r.t := r.b - _ScrollSize;
  _ScrollH.Frame := r;
  UpdateScrollBarH;
  UpdateTextPos;
end;

procedure TUIWorkspaceCode.OnRender;
  var ToolRect, IconRect: TG2Rect;
  var y, h: Single;
  var i, j, ln_begin, ln_end: Integer;
  var c: TG2Color;
  var f: PCodeFile;
  var Font: TG2Font;
  var str, ext: AnsiString;
begin
  ToolRect := Frame;
  ToolRect.r := HeaderFrame.l;
  g2.PrimRect(
    ToolRect.x, ToolRect.y, ToolRect.w, ToolRect.h,
    App.UI.GetColorPrimary(0.4)
  );
  g2.PrimRect(
    _LineNumberFrame.x, _CodeFrame.y, _CodeFrame.w + _LineNumberFrame.w, _CodeFrame.h,
    App.UI.GetColorPrimary(1)
  );
  g2.PrimLine(
    _CodeFrame.l, _CodeFrame.t,
    _CodeFrame.l, _CodeFrame.b,
    App.UI.GetColorPrimary(0.2)
  );
  if _FileIndex > -1 then
  begin
    h := _FontSize.y;
    ln_begin := G2Max(Round(-_Files[_FileIndex]^.TextPos.y / _FontSize.y) - 1, 0);
    ln_end := Round((-_Files[_FileIndex]^.TextPos.y + _CodeFrame.h) / _FontSize.y) + 1;
    if (_HighlightLineStart <> ln_begin) or (_HighlightLineEnd <> ln_end) then
    _HighlightRescan := True;
    if _HighlightRescan then
    begin
      if Length(_Files[_FileIndex]^.FileName) > 0 then
      begin
        ext := LowerCase(ExtractFileExt(_Files[_FileIndex]^.FileName));
        if (ext = '.pas')
        or (ext = '.pp')
        or (ext = '.g2pr') then
        _Highlight := _HighlightPascal
        else if ext = '.g2ml' then
        _Highlight := _HighlightG2ML
        else
        _Highlight := _HighlightPlain;
      end
      else
      begin
        _Highlight := _HighlightPlain;
      end;
      _Highlight.Scan(_Files[_FileIndex], ln_begin, ln_end);
      _HighlightRescan := False;
      _HighlightLineStart := ln_begin;
      _HighlightLineEnd := ln_end;
    end;
    y := _LineNumberFrame.t + ln_begin * _FontSize.y + _Files[_FileIndex]^.TextPos.y;
    for i := ln_begin to ln_end do
    begin
      str := IntToStr(i + 1);
      App.UI.FontCode.Print(
        _LineNumberFrame.r - Length(str) * _FontSize.x - 4,
        y, 1, 1,
        $ff000000,
        str,
        bmNormal, tfPoint
      );
      y := y + _FontSize.y;
    end;
    App.UI.PushClipRect(_CodeFrame);
    f := _Files[_FileIndex];
    for i := ln_begin to G2Min(ln_end, High(f^.Lines)) do
    begin
      for j := 0 to Length(f^.Lines[i]) - 1 do
      begin
        c := _Highlight.Color[j, i - ln_begin];
        case c.a of
          2: Font := App.UI.FontCodeB;
          3: Font := App.UI.FontCodeI;
          else Font := App.UI.FontCode;
        end;
        c.a := $ff;
        Font.Print(
          _TextPos.x + j * _FontSize.x,
          _TextPos.y + i * h, 1, 1,
          c,
          f^.Lines[i][j + 1],
          bmNormal, tfPoint
        );
      end;
    end;
    App.UI.PopClipRect;
  end;
  y := ToolRect.y + _ToolItemsOffset;
  for i := 0 to _ToolItemList.Count - 1 do
  begin
    if _ToolItemList[i] <> nil then
    begin
      IconRect := G2Rect(ToolRect.x, y, ToolRect.w, _ToolItemList[i]^.Icon.Height);
      if IconRect.Contains(g2.MousePos) then
      begin
        if g2.MouseDown[G2MB_Left] and IconRect.Contains(g2.MouseDownPos[G2MB_Left]) then
        c := App.UI.GetColorSecondary(0.6)
        else
        c := App.UI.GetColorSecondary(0.9);
      end
      else
      c := $ffffffff;
      g2.PicRect(ToolRect.x, y, c, _ToolItemList[i]^.Icon);
      y := y + _ToolItemList[i]^.Icon.Height + _ToolItemsSpacing;
    end
    else
    y := y + _ToolItemsSeparator;
  end;
  g2.PrimRect(Frame.r - _ScrollSize, Frame.b - _ScrollSize, _ScrollSize, _ScrollSize, App.UI.GetColorPrimary(0.4));
  _ScrollV.Render;
  _ScrollH.Render;
end;

procedure TUIWorkspaceCode.OnUpdate;
  var fi, NewFilePos: Integer;
  var FileFrame: TG2Rect;
  var mc: TPoint;
  var Ratio: Single;
  var cf: PCodeFile;
begin
  if _Files.Count > 1 then
  begin
    if g2.MouseDown[G2MB_Left] then
    begin
      if not _Dragging
      and (PtInFile(g2.MouseDownPos[G2MB_Left].x, g2.MouseDownPos[G2MB_Left].y) = _FileIndex)
      and ((G2Vec2(g2.MousePos) - G2Vec2(g2.MouseDownPos[G2MB_Left])).Len > 8) then
      _Dragging := True;
    end
    else
    _Dragging := False;
    if _Dragging then
    begin
      mc := g2.MousePos;
      fi := PtInFile(mc.x, mc.y, FileFrame);
      if (fi > -1) and (fi <> _FileIndex) then
      begin
        Ratio := (mc.x - FileFrame.l) / FileFrame.w;
        if (Ratio < 0.5) then
        NewFilePos := fi - 1
        else
        NewFilePos := fi + 1;
        if (NewFilePos <> _FileIndex) then
        begin
          if NewFilePos > _FileIndex then
          NewFilePos := NewFilePos - 1
          else
          NewFilePos := NewFilePos + 1;
          cf := _Files[_FileIndex];
          _Files.Delete(_FileIndex);
          _Files.Insert(NewFilePos, cf);
          _FileIndex := NewFilePos;
        end;
      end;
    end;
  end
  else
  _Dragging := False;
  _ScrollV.Update;
  _ScrollH.Update;
end;

procedure TUIWorkspaceCode.OnMouseDown(const Button, x, y: Integer);
begin
  if _ScrollV.Frame.Contains(x, y) then
  _ScrollV.MouseDown(Button, x, y)
  else if _ScrollH.Frame.Contains(x, y) then
  _ScrollH.MouseDown(Button, x, y)
  else if _FileIndex > -1 then
  begin
    if _CodeFrame.Contains(x, y) then
    begin
      UpdateTextPos;
      App.UI.TextEdit.EnableCode(
        _Files[_FileIndex],
        @_TextPos,
        @OnCodeChange,
        @OnMouseScroll,
        @OnCodeCursorMove,
        @OnTextPosChange,
        @BtnDocSave,
        @BtnDocLoad
      );
      App.UI.TextEdit.Frame := _CodeFrame;
      App.UI.TextEdit.AdjustCursor(x, y);
      if (_FileIndex > -1)
      and (App.CodeInsight.CurCodeFile <> _Files[_FileIndex]) then
      App.CodeInsight.CurCodeFile := _Files[_FileIndex];
    end;
  end;
end;

procedure TUIWorkspaceCode.OnMouseUp(const Button, x, y: Integer);
  var cy: Single;
  var ToolRect, IconRect: TG2Rect;
  var i: Integer;
begin
  ToolRect := Frame;
  ToolRect.r := HeaderFrame.l;
  cy := ToolRect.y + _ToolItemsOffset;
  for i := 0 to _ToolItemList.Count - 1 do
  begin
    if _ToolItemList[i] <> nil then
    begin
      IconRect := G2Rect(ToolRect.x, cy, ToolRect.w, _ToolItemList[i]^.Icon.Height);
      if Assigned(_ToolItemList[i]^.OnClick)
      and IconRect.Contains(x, y)
      and IconRect.Contains(g2.MouseDownPos[Button]) then
      begin
        _ToolItemList[i]^.OnClick;
      end;
      cy := cy + _ToolItemList[i]^.Icon.Height + _ToolItemsSpacing;
    end
    else
    cy := cy + _ToolItemsSeparator;
  end;
  _ScrollV.MouseUp(Button, x, y);
  _ScrollH.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceCode.OnTabInsert(const TabParent: TUIWorkspaceFrame);
  var i, j: Integer;
begin
  for i := 0 to TabParent.ChildCount - 1 do
  if TabParent.Children[i] is TUIWorkspaceCode then
  begin
    for j := 0 to _Files.Count - 1 do
    TUIWorkspaceCode(TabParent.Children[i]).AddCodeFile(_Files[j]);
    if _FileIndex > -1 then
    for j := 0 to TUIWorkspaceCode(TabParent.Children[i]).CodeFileCount - 1 do
    if TUIWorkspaceCode(TabParent.Children[i]).CodeFiles[j] = _Files[_FileIndex] then
    begin
      TUIWorkspaceCode(TabParent.Children[i]).FileIndex := j;
      Break;
    end;
    _Files.Clear;
    Free;
    Exit;
  end;
  inherited OnTabInsert(TabParent);
end;

procedure TUIWorkspaceCode.OnHeaderRender;
  var i: Integer;
  var x, w, ics: Single;
  var r, ri: TG2Rect;
  var c0, c1, c2: TG2Color;
  var Text: AnsiString;
begin
  c0 := App.UI.GetColorPrimary(0.7);
  c1 := App.UI.GetColorPrimary(1);
  r := HeaderFrame;
  x := r.x + _FileSpacing;
  for i := 0 to _Files.Count - 1 do
  begin
    Text := _Files[i]^.GetCaption;
    w := App.UI.Font1.TextWidth(Text) + _FileTabBorders * 2;
    if i = _FileIndex then
    begin
      if _Dragging then
      c2 := $ff004080
      else
      c2 := c0;
      g2.PrimRectCol(x, r.y + _FileSpacing, w, r.h - _FileSpacing, c2, c2, c1, c1);
      c2 := $ff000000;
    end
    else
    c2 := App.UI.GetColorPrimary(0.9);
    App.UI.Font1.Print(
      Round(x + (w - App.UI.Font1.TextWidth(Text)) * 0.5),
      Round(r.y + _FileSpacing + ((r.h - _FileSpacing) - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, c2, Text, bmNormal, tfPoint
    );
    if (i = _FileIndex)
    and not _Dragging then
    begin
      ics := _FileIconSize * _FileIconCloseScale;
      ri := G2Rect(x + (_FileTabBorders - _FileIconSize) * 0.5, r.y + (r.h - _FileIconSize) * 0.5, _FileIconSize, _FileIconSize);
      if ri.Contains(g2.MousePos) then
      App.UI.DrawCircles(ri, App.UI.GetColorSecondary(0.7))
      else
      App.UI.DrawCircles(ri, App.UI.GetColorPrimary(0.2));
      ri.x := x + w - _FileTabBorders + (_FileTabBorders - ics) * 0.5;
      ri.y := r.y + (r.h - ics) * 0.5;
      ri.w := ics;
      ri.h := ics;
      g2.PrimBegin(ptTriangles, bmNormal);
      if ri.Contains(g2.MousePos) then
      App.UI.DrawCross(ri, App.UI.GetColorSecondary(0.7))
      else
      App.UI.DrawCross(ri, App.UI.GetColorPrimary(0.2));
      g2.PrimEnd;
    end;
    x := x + w + _FileSpacing;
  end;
end;

procedure TUIWorkspaceCode.OnHeaderMouseDown(const Button, x, y: Integer);
  var mdf: Integer;
  var InDrag, InClose: Boolean;
  var Code: TUIWorkspaceCode;
  var CodeConstructor: TUIWorkspaceConstructorCode;
begin
  mdf := PtInFile(x, y, InDrag, InClose);
  if _FileIndex = mdf then
  begin
    if InDrag then
    begin
      Code := TUIWorkspaceCode.Create;
      App.UI.OverlayWorkspace.Workspace := Code;
      CodeConstructor := TUIWorkspaceConstructorCode.Create;
      CodeConstructor.OnCreateWorkspace(App.UI.OverlayWorkspace.Workspace);
      CodeConstructor.Free;
      App.UI.Overlay := App.UI.OverlayWorkspace;
      Code.AddCodeFile(_Files[_FileIndex]);
      RemoveCodeFile(_Files[_FileIndex]);
    end;
  end;
end;

procedure TUIWorkspaceCode.OnHeaderMouseUp(const Button, x, y: Integer);
  var MDFile: Integer;
  var md: TPoint;
  var MdInDrag, MdInClose, InDrag, InClose: Boolean;
  var cf: PCodeFile;
begin
  md := g2.MouseDownPos[G2MB_Left];
  MDFile := PtInFile(md.x, md.y, MdInDrag, MdInClose);
  if (MDFile > -1) and (PtInFile(x, y, InDrag, InClose) = MDFile) then
  begin
    _HighlightRescan := True;
    if MDFile = _FileIndex then
    begin
      if InClose and MdInClose then
      begin
        cf := _Files[_FileIndex];
        RemoveCodeFile(cf);
        cf^.Finalize;
        Dispose(cf);
      end;
    end
    else
    begin
      FileIndex := MDFile;
      OnAdjust;
    end;
  end;
end;

function TUIWorkspaceCode.NewCodeFile: PCodeFile;
begin
  New(Result);
  Result^.Initialize;
  AddCodeFile(Result);
end;

procedure TUIWorkspaceCode.AddCodeFile(const CodeFile: PCodeFile);
begin
  _Files.Add(CodeFile);
  if _FileIndex = -1 then
  FileIndex := 0;
  OnAdjust;
end;

procedure TUIWorkspaceCode.RemoveCodeFile(const CodeFile: PCodeFile);
  var i: Integer;
begin
  i := _Files.Find(CodeFile);
  if i > -1 then
  begin
    _Files.Delete(i);
    if i = _FileIndex then
    FileIndex := G2Min(_FileIndex, _Files.Count - 1)
    else if _FileIndex > i then
    FileIndex := _FileIndex - 1;
  end;
  OnAdjust;
end;

procedure TUIWorkspaceCode.SelectCodeFile(const CodeFile: PCodeFile);
  var i: Integer;
begin
  for i := 0 to _Files.Count - 1 do
  if _Files[i] = CodeFile then
  begin
    FileIndex := i;
    _HighlightRescan := True;
    Exit;
  end;
end;

class function TUIWorkspaceCode.GetWorkspaceName: AnsiString;
begin
  Result := 'Code Editor';
end;

class function TUIWorkspaceCode.GetWorkspacePath: AnsiString;
begin
  Result := 'Code';
end;

function TUIWorkspaceCode.GetMinWidth: Single;
begin
  Result := 256;
end;

function TUIWorkspaceCode.GetMinHeight: Single;
begin
  Result := 64;
end;
//TUIWorkspaceCode END

//TUIWorkspaceCodeBrowser BEGIN
function TUIWorkspaceCodeBrowser.TNode.AddNode(const NodeName: AnsiString): PNode;
begin
  New(Result);
  Result^._LastNode := nil;
  Result^.Name := NodeName;
  Result^.Children.Clear;
  Result^.Open := False;
  Children.Add(Result);
  _LastNode := Result;
end;

function TUIWorkspaceCodeBrowser.TNode.LastNode: PNode;
begin
  Result := _LastNode;
end;

function TUIWorkspaceCodeBrowser.GetContentHeight: Single;
  function GetNodeHeight(const n: PNode): Single;
    var i: Integer;
  begin
    Result := App.UI.Font1.TextHeight('A');
    if n^.Open and (n^.Children.Count > 0) then
    for i := 0 to n^.Children.Count - 1 do
    Result += GetNodeHeight(PNode(n^.Children[i]));
  end;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to _Root.Children.Count - 1 do
  Result += GetNodeHeight(PNode(_Root.Children[i]));
end;

function TUIWorkspaceCodeBrowser.PtInItem(
  const x, y: Single;
  var InExpand: Boolean;
  var InImplementation: Boolean
): PNode;
  function CheckItem(const n: PNode; var varx, vary: Single; var VarInExpand: Boolean; var VarInImplementation: Boolean): PNode;
    var r: TG2Rect;
    var i: Integer;
  begin
    Result := nil;
    r.l := varx - _NodesOffset;
    r.t := vary;
    r.b := vary + App.UI.Font1.TextHeight('A');
    r.r := varx + App.UI.Font1.TextWidth(n^.Name);
    if n^.LineImplementation > -1 then
    r.r := r.r + App.UI.Font1.TextWidth(' ->');
    if r.Contains(x, y) then
    Result := n;
    if Result <> nil then
    begin
      if n^.LineImplementation > -1 then
      begin
        r.l := r.r - App.UI.Font1.TextWidth(' ->');
        VarInImplementation := r.Contains(x, y);
      end
      else
      VarInImplementation := False;
      r.r := varx; r.l := varx - _NodesOffset;
      VarInExpand := (n^.Children.Count > 0) and r.Contains(x, y);
      Exit;
    end;
    vary += App.UI.Font1.TextHeight('A');
    if n^.Open and (n^.Children.Count > 0) then
    begin
      varx += _NodesOffset;
      for i := 0 to n^.Children.Count - 1 do
      begin
        Result := CheckItem(PNode(n^.Children[i]), varx, vary, VarInExpand, VarInImplementation);
        if Result <> nil then
        Exit;
      end;
      varx -= _NodesOffset;
    end;
  end;
  var varx, vary: Single;
  var i: Integer;
begin
  varx := Frame.l + _NodesOffset;
  vary := Frame.t - _ScrollV.PosAbsolute;
  for i := 0 to _Root.Children.Count - 1 do
  begin
    Result := CheckItem(PNode(_Root.Children[i]), varx, vary, InExpand, InImplementation);
    if Result <> nil then
    Exit;
  end;
end;

procedure TUIWorkspaceCodeBrowser.ProcessFile(const FileSymbol: TCodeInsightSymbolFile);
  procedure ProcessNode(const Node: PNode; const Symbol: TCodeInsightSymbol);
    var i: Integer;
    var n: PNode;
    var sf: TCodeInsightSymbolFile;
  begin
    n := Node^.AddNode(Symbol.Name);// + ' (' + IntToStr(Symbol.LineInterface) + ':' + IntToStr(Symbol.LineImplementation) + ') ' + Symbol.Path);
    n^.LineInterface := Symbol.LineInterface;
    n^.LineImplementation := Symbol.LineImplementation;
    if Symbol.SymbolType <> stFileLink then
    for i := 0 to Symbol.Children.Count - 1 do
    begin
      ProcessNode(n, Symbol.Children[i]);
    end;
  end;
  var i: Integer;
begin
  _ParsedTime := FileSymbol.ParsedTime;
  Clear;
  ProcessNode(@_Root, FileSymbol);
  for i := 0 to _Root.Children.Count - 1 do
  PNode(_Root.Children[i])^.Open := True;
  OnAdjust;
end;

procedure TUIWorkspaceCodeBrowser.OnSlide;
begin

end;

procedure TUIWorkspaceCodeBrowser.OnInitialize;
  procedure ProcessNode(const Node: PNode; const Symbol: TCodeInsightSymbol);
    var i: Integer;
    var n: PNode;
    var sf: TCodeInsightSymbolFile;
  begin
    n := Node^.AddNode(Symbol.Name);
    for i := 0 to Symbol.Children.Count - 1 do
    begin
      if Symbol.Children[i].SymbolType = stFileLink then
      begin
        sf := App.CodeInsight.FindFile(Symbol.Children[i].Path);
        if sf <> nil then
        ProcessNode(n, sf);
      end
      else
      ProcessNode(n, Symbol.Children[i]);
    end;
  end;
begin
  _ParsedTime := 0;
  _ScrollV.OnChange := @OnSlide;
  _ScrollV.Enabled := True;
  _ScrollV.PosRelative := 0;
  _CurFile := '';
  _NodesOffset := 16;
  Clear;
end;

procedure TUIWorkspaceCodeBrowser.OnFinalize;
begin
  Clear;
end;

procedure TUIWorkspaceCodeBrowser.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame; r.l := r.r - 18;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetContentHeight;
  _ScrollV.ParentSize := Frame.h;
end;

procedure TUIWorkspaceCodeBrowser.OnRender;
  procedure RenderNode(const n: PNode; var x, y: Single);
    var i, l: Integer;
    var s: AnsiString;
    var r: TG2Rect;
    var c: TG2Color;
  begin
    r := G2Rect(x, y, App.UI.Font1.TextWidth(n^.Name), App.UI.Font1.TextHeight('A'));
    if r.Contains(g2.MousePos) then
    c := $ffff8080
    else
    c := $ffffffff;
    App.UI.Font1.Print(x, y, 1, 1, c, n^.Name, bmNormal, tfPoint);
    if n^.Children.Count > 0 then
    begin
      if n^.Open then
      s := '-'
      else
      s := '+';
      r := G2Rect(x - _NodesOffset, y, _NodesOffset, App.UI.Font1.TextHeight('A'));
      if r.Contains(g2.MousePos) then
      c := $ffff8080
      else
      c := $ffffffff;
      App.UI.Font1.Print(x - _NodesOffset + (_NodesOffset - App.UI.Font1.TextWidth(s)) * 0.5, y, 1, 1, c, s, bmNormal, tfPoint);
    end;
    if n^.LineImplementation > -1 then
    begin
      s := ' ->';
      l := App.UI.Font1.TextWidth(n^.Name);
      r := G2Rect(x + l, y, App.UI.Font1.TextWidth(s), App.UI.Font1.TextHeight('A'));
      if r.Contains(g2.MousePos) then
      c := $ffff8080
      else
      c := $ffffffff;
      App.UI.Font1.Print(x + l, y, 1, 1, c, s, bmNormal, tfPoint);
    end;
    x += _NodesOffset;
    y += App.UI.Font1.TextHeight('A');
    if (n^.Children.Count > 0) and (n^.Open) then
    for i := 0 to n^.Children.Count - 1 do
    RenderNode(PNode(n^.Children[i]), x, y);
    x -= _NodesOffset;
  end;
  var x, y: Single;
  var i: Integer;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.2)
  );
  x := Frame.l + _NodesOffset;
  y := Frame.t - _ScrollV.PosAbsolute;
  for i := 0 to _Root.Children.Count - 1 do
  RenderNode(PNode(_Root.Children[i]), x, y);
  _ScrollV.Render;
end;

procedure TUIWorkspaceCodeBrowser.OnUpdate;
  var FileSymbol: TCodeInsightSymbolFile;
begin
  _ScrollV.Update;
  if (App.CodeInsight.CurCodeFile <> nil) then
  begin
    if (App.CodeInsight.CurCodeFile^.FilePath + App.CodeInsight.CurCodeFile^.FileName <> _CurFile) then
    begin
      _CurFile := App.CodeInsight.CurCodeFile^.FilePath + App.CodeInsight.CurCodeFile^.FileName;
      if Length(_CurFile) > 0 then
      begin
        FileSymbol := App.CodeInsight.FindFile(_CurFile);
        if FileSymbol <> nil then
        ProcessFile(FileSymbol)
        else
        Clear;
      end
      else
      Clear;
    end
    else
    begin
      FileSymbol := App.CodeInsight.FindFile(_CurFile);
      if (FileSymbol <> nil)
      and (FileSymbol.ParsedTime <> _ParsedTime) then
      ProcessFile(FileSymbol);
    end;
  end
  else
  begin
    if FileSymbol <> nil then
    begin
      FileSymbol := nil;
      _CurFile := '';
      Clear;
    end;
  end;
end;

procedure TUIWorkspaceCodeBrowser.OnMouseDown(const Button, x, y: Integer);
  var n: PNode;
  var InExpand, InImplementation: Boolean;
begin
  n := PtInItem(x, y, InExpand, InImplementation);
  if (n <> nil) and InExpand then
  begin
    n^.Open := not n^.Open;
    OnAdjust;
  end;
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceCodeBrowser.OnMouseUp(const Button, x, y: Integer);
  var NodeMD, NodeMC: PNode;
  var InExpandMD, InExpandMC, InImplementationMD, InImplementationMC: Boolean;
begin
  NodeMD := PtInItem(g2.MouseDownPos[Button].x, g2.MouseDownPos[Button].y, InExpandMD, InImplementationMD);
  NodeMC := PtInItem(x, y, InExpandMC, InImplementationMC);
  if (NodeMD <> nil)
  and (NodeMD = NodeMC)
  and (App.CodeInsight.CurCodeFile <> nil)
  and not InExpandMD
  and not InExpandMC then
  begin
    if InImplementationMC
    and InImplementationMD then
    begin
      if (NodeMC^.LineImplementation > -1) then
      begin
        App.CodeInsight.CurCodeFile^.TextPos := G2Vec2(
          0, -NodeMC^.LineImplementation * App.UI.FontCode.TextHeight('A')
        );
        if (App.UI.Views.CurView <> nil)
        and (App.UI.Views.CurView^.Workspace <> nil) then
        App.UI.MsgResizeWorkspace(App.UI.Views.CurView^.Workspace, App.UI.Views.CurView^.Workspace.Frame, True);
      end;
    end
    else if (NodeMC^.LineInterface > -1)
    and not InImplementationMC
    and not InImplementationMD then
    begin
      App.CodeInsight.CurCodeFile^.TextPos := G2Vec2(
        0, -NodeMC^.LineInterface * App.UI.FontCode.TextHeight('A')
      );
      if (App.UI.Views.CurView <> nil)
      and (App.UI.Views.CurView^.Workspace <> nil) then
      App.UI.MsgResizeWorkspace(App.UI.Views.CurView^.Workspace, App.UI.Views.CurView^.Workspace.Frame, True);
    end;
  end;
  _ScrollV.MouseUp(Button, x, y)
end;

procedure TUIWorkspaceCodeBrowser.OnScroll(const y: Integer);
begin
  _ScrollV.Scroll(y);
end;

class function TUIWorkspaceCodeBrowser.GetWorkspaceName: AnsiString;
begin
  Result := 'Code Browser';
end;

class function TUIWorkspaceCodeBrowser.GetWorkspacePath: AnsiString;
begin
  Result := 'Code';
end;

function TUIWorkspaceCodeBrowser.GetMinWidth: Single;
begin
  Result := 128;
end;

function TUIWorkspaceCodeBrowser.GetMinHeight: Single;
begin
  Result := 64;
end;

procedure TUIWorkspaceCodeBrowser.Clear;
  procedure ClearNode(const n: PNode);
    var i: Integer;
  begin
    for i := 0 to n^.Children.Count - 1 do
    ClearNode(PNode(n^.Children[i]));
    Dispose(n);
  end;
  var i: Integer;
begin
  for i := 0 to _Root.Children.Count - 1 do
  ClearNode(PNode(_Root.Children[i]));
  _Root.Name := 'root';
  _Root.Open := True;
  _Root.Children.Clear;
  _Root._LastNode := nil;
end;
//TUIWorkspaceCodeBrowser END

//TUIWorkspaceProjectBrowser BEGIN
function TUIWorkspaceProjectBrowser.TNode.AddNode(const NodeName: AnsiString; const NodeIsDir: Boolean): PNode;
  var l, h, m, c: TG2IntS32;
begin
  l := 0;
  h := Children.Count - 1;
  while l <= h do
  begin
    m := (l + h) div 2;
    c := 0;
    if PNode(Children[m])^.IsDir and not NodeIsDir then
    c := -1
    else if not PNode(Children[m])^.IsDir and NodeIsDir then
    c := 1
    else
    c := CompareFilenamesIgnoreCase(PNode(Children[m])^.Name, NodeName);
    if c < 0 then
    l := m + 1 else h := m - 1;
  end;
  New(Result);
  Result^._LastNode := nil;
  Result^.Name := NodeName;
  Result^.Children.Clear;
  Result^.IsDir := NodeIsDir;
  Result^.Open := False;
  Children.Insert(l, Result);
  _LastNode := Result;
end;

function TUIWorkspaceProjectBrowser.TNode.LastNode: PNode;
begin
  Result := _LastNode;
end;

function TUIWorkspaceProjectBrowser.GetContentHeight: Single;
  function GetNodeHeight(const n: PNode): Single;
    var i: Integer;
  begin
    Result := App.UI.Font1.TextHeight('A');
    if n^.Open and (n^.Children.Count > 0) then
    for i := 0 to n^.Children.Count - 1 do
    Result += GetNodeHeight(PNode(n^.Children[i]));
  end;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to _Root.Children.Count - 1 do
  Result += GetNodeHeight(PNode(_Root.Children[i]));
end;

function TUIWorkspaceProjectBrowser.PtInItem(
  const x, y: Single;
  var InExpand: Boolean
): PNode;
  function CheckItem(const n: PNode; var varx, vary: Single; var VarInExpand: Boolean): PNode;
    var r: TG2Rect;
    var i: Integer;
  begin
    Result := nil;
    r.l := varx - _NodesOffset;
    r.t := vary;
    r.b := vary + App.UI.Font1.TextHeight('A');
    r.r := varx + App.UI.Font1.TextWidth(n^.Name);
    if r.Contains(x, y) then
    Result := n;
    if Result <> nil then
    begin
      r.r := varx; r.l := varx - _NodesOffset;
      VarInExpand := (n^.Children.Count > 0) and r.Contains(x, y);
      Exit;
    end;
    vary += App.UI.Font1.TextHeight('A');
    if n^.Open and (n^.Children.Count > 0) then
    begin
      varx += _NodesOffset;
      for i := 0 to n^.Children.Count - 1 do
      begin
        Result := CheckItem(PNode(n^.Children[i]), varx, vary, VarInExpand);
        if Result <> nil then
        Exit;
      end;
      varx -= _NodesOffset;
    end;
  end;
  var varx, vary: Single;
  var i: Integer;
begin
  varx := Frame.l + _NodesOffset;
  vary := Frame.t - _ScrollV.PosAbsolute;
  for i := 0 to _Root.Children.Count - 1 do
  begin
    Result := CheckItem(PNode(_Root.Children[i]), varx, vary, InExpand);
    if Result <> nil then
    Exit;
  end;
end;

procedure TUIWorkspaceProjectBrowser.OnSlide;
begin

end;

procedure TUIWorkspaceProjectBrowser.Refresh;
  procedure ProcessDir(const ParentNode: PNode; const Directory: String);
    var i: Integer;
    var n: PNode;
    var sr: TSearchRec;
    var PathArr: TG2StrArrA;
    var NodeName: String;
  begin
    if FindFirstUTF8(Directory + '*', faDirectory, sr) = 0 then
    begin
      repeat
        if (sr.Name <> '.')
        and (sr.Name <> '..') then
        begin
          n := ParentNode^.AddNode(sr.Name, (sr.Attr and faDirectory) = faDirectory);
          n^.Path := Directory + G2PathSep + sr.Name;
          if n^.IsDir then
          begin
            n^.Path += G2PathSep;
            ProcessDir(n, Directory + G2PathSep + sr.Name + G2PathSep);
          end;
        end;
      until FindNextUTF8(sr) <> 0;
      FindCloseUTF8(sr);
    end;
  end;
  var i: Integer;
begin
  Clear;
  _Root.IsDir := True;
  _Root.Path := App.Project.FilePath;
  ProcessDir(@_Root, App.Project.FilePath);
  OnAdjust;
  _LastScan := G2Time;
end;

procedure TUIWorkspaceProjectBrowser.Scan;
  var Verified: Boolean;
  procedure VerifyNode(const Node: PNode);
    var i, n: Integer;
    var v, b: Boolean;
    var sr: TSearchRec;
  begin
    n := 0;
    v := True;
    if FindFirstUTF8(Node^.Path + '*', faDirectory, sr) = 0 then
    begin
      repeat
        if (sr.Name <> '.')
        and (sr.Name <> '..') then
        begin
          n += 1;
          b := False;
          for i := 0 to Node^.Children.Count - 1 do
          if PNode(Node^.Children[i])^.Name = sr.Name then
          begin
            b := True;
            Break;
          end;
          v := v and b;
          if not v then
          Break;
        end;
      until FindNextUTF8(sr) <> 0;
      FindCloseUTF8(sr);
    end;
    v := v and (n = Node^.Children.Count);
    if v then
    begin
      for i := 0 to Node^.Children.Count - 1 do
      if PNode(Node^.Children[i])^.IsDir then
      VerifyNode(PNode(Node^.Children[i]));
    end;
    Verified := Verified and v;
  end;
begin
  _LastScan := G2Time;
  Verified := True;
  VerifyNode(@_Root);
  if not Verified then
  _ProjectOpen := False;
end;

procedure TUIWorkspaceProjectBrowser.OnInitialize;
begin
  _RefreshThread := nil;
  _RefreshCS.Initialize;
  _ScrollV.OnChange := @OnSlide;
  _ScrollV.Enabled := True;
  _ScrollV.PosRelative := 0;
  _NodesOffset := 16;
  _ProjectOpen := False;
  _LastScan := G2Time;
  Clear;
end;

procedure TUIWorkspaceProjectBrowser.OnFinalize;
begin
  if (_RefreshThread <> nil) then
  begin
    _RefreshThread.WaitFor;
    _RefreshThread.Free;
    _RefreshThread := nil;
  end;
  Clear;
  _RefreshCS.Finalize;
end;

procedure TUIWorkspaceProjectBrowser.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame; r.l := r.r - 18;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetContentHeight;
  _ScrollV.ParentSize := Frame.h;
end;

procedure TUIWorkspaceProjectBrowser.OnRender;
  procedure RenderNode(const n: PNode; var x, y: Single);
    var i, l: Integer;
    var s: AnsiString;
    var r: TG2Rect;
    var c: TG2Color;
  begin
    r := G2Rect(x, y, App.UI.Font1.TextWidth(n^.Name), App.UI.Font1.TextHeight('A'));
    if r.Contains(g2.MousePos) then
    c := $ffff8080
    else
    c := $ffffffff;
    App.UI.Font1.Print(x, y, 1, 1, c, n^.Name, bmNormal, tfPoint);
    if n^.Children.Count > 0 then
    begin
      if n^.Open then
      s := '-'
      else
      s := '+';
      r := G2Rect(x - _NodesOffset, y, _NodesOffset, App.UI.Font1.TextHeight('A'));
      if r.Contains(g2.MousePos) then
      c := $ffff8080
      else
      c := $ffffffff;
      App.UI.Font1.Print(x - _NodesOffset + (_NodesOffset - App.UI.Font1.TextWidth(s)) * 0.5, y, 1, 1, c, s, bmNormal, tfPoint);
    end;
    x += _NodesOffset;
    y += App.UI.Font1.TextHeight('A');
    if (n^.Children.Count > 0) and (n^.Open) then
    for i := 0 to n^.Children.Count - 1 do
    RenderNode(PNode(n^.Children[i]), x, y);
    x -= _NodesOffset;
  end;
  var x, y: Single;
  var i: Integer;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.2)
  );
  x := Frame.l + _NodesOffset;
  y := Frame.t - _ScrollV.PosAbsolute;
  for i := 0 to _Root.Children.Count - 1 do
  RenderNode(PNode(_Root.Children[i]), x, y);
  _ScrollV.Render;
end;

procedure TUIWorkspaceProjectBrowser.OnUpdate;
begin
  if App.Project.Open then
  begin
    if not _ProjectOpen then
    begin
      Refresh;
      _ProjectOpen := True;
    end
    else if (G2Time - _LastScan > 3000)
    and (_RefreshThread = nil) then
    begin
      _RefreshThread := TG2Thread.Create;
      _RefreshThread.Proc := @Scan;
      _RefreshThread.Start;
    end;
  end
  else if _ProjectOpen then
  begin
    Clear;
  end;
  if (_RefreshThread <> nil)
  and (_RefreshThread.State = tsFinished) then
  begin
    _RefreshThread.Free;
    _RefreshThread := nil;
  end;
  _ScrollV.Update;
end;

procedure TUIWorkspaceProjectBrowser.OnMouseDown(const Button, x, y: Integer);
  var n: PNode;
  var InExpand: Boolean;
begin
  n := PtInItem(x, y, InExpand);
  if (n <> nil) and InExpand then
  begin
    n^.Open := not n^.Open;
    OnAdjust;
  end;
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceProjectBrowser.OnMouseUp(const Button, x, y: Integer);
  var NodeMD, NodeMC: PNode;
  var InExpandMD, InExpandMC: Boolean;
begin
  NodeMD := PtInItem(g2.MouseDownPos[Button].x, g2.MouseDownPos[Button].y, InExpandMD);
  NodeMC := PtInItem(x, y, InExpandMC);
  if (NodeMD <> nil)
  and (NodeMD = NodeMC)
  and (App.CodeInsight.CurCodeFile <> nil)
  and not InExpandMD
  and not InExpandMC then
  begin
    if (True) then
    begin
      //Do something here
    end;
  end;
  _ScrollV.MouseUp(Button, x, y)
end;

procedure TUIWorkspaceProjectBrowser.OnScroll(const y: Integer);
begin
  _ScrollV.PosAbsolute := G2Min(_ScrollV.PosAbsolute - y, _ScrollV.ContentSize - _ScrollV.ParentSize);
  if _ScrollV.PosAbsolute < 0 then
  _ScrollV.PosAbsolute := 0;
  OnSlide;
end;

class function TUIWorkspaceProjectBrowser.GetWorkspaceName: AnsiString;
begin
  Result := 'Project Browser';
end;

function TUIWorkspaceProjectBrowser.GetMinWidth: Single;
begin
  Result := 128;
end;

function TUIWorkspaceProjectBrowser.GetMinHeight: Single;
begin
  Result := 64;
end;

procedure TUIWorkspaceProjectBrowser.Clear;
  procedure ClearNode(const n: PNode);
    var i: Integer;
  begin
    for i := 0 to n^.Children.Count - 1 do
    ClearNode(PNode(n^.Children[i]));
    Dispose(n);
  end;
  var i: Integer;
begin
  for i := 0 to _Root.Children.Count - 1 do
  ClearNode(PNode(_Root.Children[i]));
  _Root.Name := 'root';
  _Root.Open := True;
  _Root.Children.Clear;
  _Root._LastNode := nil;
end;
//TUIWorkspaceProjectBrowser END

//TUIWorkspaceCustomObject BEGIN
procedure TUIWorkspaceCustomObject.OnInitialize;
begin
  _SizingH := csStretch;
  _SizingV := csStretch;
  _Width := 28;
  _Height := 28;
  _PaddingLeft := 0;
  _PaddingTop := 0;
  _PaddingRight := 0;
  _PaddingBottom := 0;
end;

class function TUIWorkspaceCustomObject.GetWorkspaceName: AnsiString;
begin
  Result := 'Custom Object';
end;

function TUIWorkspaceCustomObject.GetMinWidth: Single;
begin
  Result := _Width;
end;

function TUIWorkspaceCustomObject.GetMinHeight: Single;
begin
  Result := _Height;
end;
//TUIWorkspaceCustomObject END

//TUIWorkspaceFixedSplitterV BEIGN
function TUIWorkspaceFixedSplitterV.GetUpper: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[0]);
end;

function TUIWorkspaceFixedSplitterV.GetLower: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[1]);
end;

procedure TUIWorkspaceFixedSplitterV.SetSplitPos(const Value: Single);
begin
  _SplitPos := Value;
  OnAdjust;
end;

procedure TUIWorkspaceFixedSplitterV.OnAdjust;
  var i: Integer;
  var s0, s1, s2: Single;
  var f: TG2Rect;
begin
  if ChildCount < 2 then Exit;
  s0 := Frame.t;
  s1 := G2LerpFloat(Frame.t, Frame.b, _SplitPos);
  s2 := Frame.b;
  f.t := s0;
  f.b := s1;
  f.l := Frame.l;
  f.r := Frame.r;
  Children[0].Frame := f;
  f.t := s1;
  f.b := s2;
  Children[1].Frame := f;
end;

procedure TUIWorkspaceFixedSplitterV.OnInitialize;
  var c: TUIWorkspaceCustom;
begin
  inherited OnInitialize;
  _SplitPos := 0.5;
  c := TUIWorkspaceCustom.Create;
  c.Parent := Self;
  c := TUIWorkspaceCustom.Create;
  c.Parent := Self;
  OnAdjust;
end;

function TUIWorkspaceFixedSplitterV.GetMinWidth: Single;
begin
  Result := G2Max(Children[0].GetMinWidth, Children[1].GetMinWidth);
end;

function TUIWorkspaceFixedSplitterV.GetMinHeight: Single;
begin
  Result := G2Max(Children[0].GetMinHeight / G2Max(_SplitPos, 0.01), Children[1].GetMinHeight / G2Max(1 - _SplitPos, 0.01));
end;
//TUIWorkspaceFixedSplitterV END

//TUIWorkspaceFixedSplitterH BEGIN
function TUIWorkspaceFixedSplitterH.GetLeft: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[0]);
end;

function TUIWorkspaceFixedSplitterH.GetRight: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[1]);
end;

procedure TUIWorkspaceFixedSplitterH.SetSplitPos(const Value: Single);
begin
  _SplitPos := Value;
  OnAdjust;
end;

procedure TUIWorkspaceFixedSplitterH.OnAdjust;
  var i: Integer;
  var s0, s1, s2: Single;
  var f: TG2Rect;
begin
  if ChildCount < 2 then Exit;
  s0 := Frame.l;
  s2 := Frame.r;
  s1 := G2LerpFloat(Frame.l, Frame.r, _SplitPos);

  f.l := s0 + Left.SpacingLeft;
  f.r := s1 - Left.SpacingRight;
  f.t := Frame.t + Left.SpacingTop;
  f.b := Frame.b - Left.SpacingBottom;
  Children[0].Frame := f;
  f.l := s1 + Right.SpacingLeft;
  f.r := s2 - Right.SpacingRight;
  f.t := Frame.t + Right.SpacingTop;
  f.b := Frame.b - Right.SpacingBottom;
  Children[1].Frame := f;
end;

procedure TUIWorkspaceFixedSplitterH.OnInitialize;
  var c: TUIWorkspaceCustom;
begin
  inherited OnInitialize;
  _SplitPos := 0.5;
  SizingV := csFixed;
  c := TUIWorkspaceCustom.Create;
  c.Parent := Self;
  c := TUIWorkspaceCustom.Create;
  c.Parent := Self;
  OnAdjust;
end;

function TUIWorkspaceFixedSplitterH.GetMinWidth: Single;
begin
  Result := G2Max(Children[0].GetMinWidth / G2Max(_SplitPos, 0.01), Children[1].GetMinWidth / G2Max(1 - _SplitPos, 0.01));
end;

function TUIWorkspaceFixedSplitterH.GetMinHeight: Single;
begin
  Result := G2Max(Children[0].GetMinHeight, Children[1].GetMinHeight);
end;
//TUIWorkspaceFixedSplitterH END

//TUIWorkspaceFixedSplitterMulti BEGIN
procedure TUIWorkspaceFixedSplitterMulti.SetSubsetCount(const Value: Integer);
  var i: Integer;
begin
  if _SubsetCount <> Value then
  begin
    for i := Value to _SubsetCount - 1 do
    begin
      _Subsets[i].Parent := nil;
      _Subsets[i].Free;
    end;
    SetLength(_Subsets, Value);
    for i := _SubsetCount to Value - 1 do
    begin
      _Subsets[i] := TUIWorkspaceCustom.Create;
      _Subsets[i].Parent := Self;
    end;
    _SubsetCount := Value;
    _SplitRatio := 1 / _SubsetCount;
    OnAdjust;
  end;
end;

function TUIWorkspaceFixedSplitterMulti.GetSubset(const Index: Integer): TUIWorkspaceCustom;
begin
  Result := _Subsets[Index];
end;

procedure TUIWorkspaceFixedSplitterMulti.OnAdjust;
  var i: Integer;
  var w: Single;
  var f, r: TG2Rect;
begin
  if _SubsetCount < 1 then Exit;
  f := Frame;
  w := _SplitRatio * f.w;
  f.w := w;
  for i := 0 to _SubsetCount - 1 do
  begin
    if not _EqualSized then
    f.w := _Subsets[i].GetMinWidth + _Subsets[i].SpacingLeft + _Subsets[i].SpacingRight;
    _Subsets[i].Frame := f;
    f.x := f.x + f.w;
  end;
end;

procedure TUIWorkspaceFixedSplitterMulti.OnInitialize;
begin
  inherited OnInitialize;
  SizingV := csFixed;
  _Subsets := nil;
  _SubsetCount := 0;
  _SplitRatio := 0;
  _EqualSized := True;
end;

function TUIWorkspaceFixedSplitterMulti.GetMinWidth: Single;
  var i: Integer;
begin
  if not _EqualSized then
  begin
    for i := 0 to _SubsetCount - 1 do
    Result := G2Max(Result, _Subsets[i].GetMinWidth / G2Max(_SplitRatio, 0.01));
  end
  else
  begin
    Result := 0;
    for i := 0 to _SubsetCount - 1 do
    Result += _Subsets[i].GetMinWidth + _Subsets[i].SpacingLeft + _Subsets[i].SpacingRight;
  end;
  Result := G2Max(Result, 8);
end;

function TUIWorkspaceFixedSplitterMulti.GetMinHeight: Single;
  var i: Integer;
begin
  Result := G2Max(inherited GetMinHeight, 8);
  for i := 0 to _SubsetCount - 1 do
  Result := G2Max(Result, _Subsets[i].GetMinHeight);
end;
//TUIWorkspaceFixedSplitterMulti END

//TUIWorkspaceCustomPanel BEGIN
procedure TUIWorkspaceCustomPanel.SetVisible(const Value: Boolean);
  procedure CallAdjust(const Workspace: TUIWorkspace);
  begin
    if Workspace.Parent = nil then
    Workspace.OnAdjust
    else
    CallAdjust(Workspace.Parent);
  end;
begin
  if _Visible = Value then Exit;
  _Visible := Value;
  CallAdjust(Self);
end;

function TUIWorkspaceCustomPanel.GetClient: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[0]);
end;

procedure TUIWorkspaceCustomPanel.OnInitialize;
  var c: TUIWorkspaceCustom;
begin
  inherited OnInitialize;
  _Visible := True;
  c := TUIWorkspaceCustom.Create;
  c.Parent := Self;
end;

procedure TUIWorkspaceCustomPanel.OnAdjust;
begin
  if not _Visible then
  begin
    Frame.w := 0;
    Frame.h := 0;
  end;
  if ChildCount < 1 then Exit;
  Children[0].Frame := Frame;
end;

procedure TUIWorkspaceCustomPanel.OnRender;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.4)
  );
end;

procedure TUIWorkspaceCustomPanel.Render;
begin
  if _Visible then
  inherited Render;
end;

function TUIWorkspaceCustomPanel.GetMinWidth: Single;
begin
  if _Visible then Result := _Children[0].GetMinWidth
  else Result := 0;
end;

function TUIWorkspaceCustomPanel.GetMinHeight: Single;
begin
  if _Visible then Result := _Children[0].GetMinHeight
  else Result := 0;
end;
//TUIWorkspaceCustomPanel END

//TUIWorkspaceCustomGroup BEGIN
function TUIWorkspaceCustomGroup.GetClient: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[0]);
end;

function TUIWorkspaceCustomGroup.GetClientFrame: TG2Rect;
begin
  Result.l := Frame.l + _BorderSize;
  Result.t := Frame.t + _BorderSize + _HeaderSize;
  Result.r := Frame.r - _BorderSize;
  Result.b := Frame.b - _BorderSize;
end;

procedure TUIWorkspaceCustomGroup.OnInitialize;
  var c: TUIWorkspaceCustom;
begin
  inherited OnInitialize;
  c := TUIWorkspaceCustom.Create;
  c.Parent := Self;
  _Caption := 'Group';
  _HeaderSize := 24;
  _BorderSize := 2;
  SizingV := csFixed;
end;

procedure TUIWorkspaceCustomGroup.OnAdjust;
begin
  if ChildCount < 1 then Exit;
  Children[0].Frame := GetClientFrame;
end;

procedure TUIWorkspaceCustomGroup.OnRender;
  var f, cf: TG2Rect;
  var x0, x1, x2, x3, y0, y1, y2, y3: Single;
  var c: TG2Color;
begin
  f := Frame;
  cf := GetClientFrame;
  c := App.UI.GetColorPrimary(0.6);
  x0 := f.l; x1 := f.l + _BorderSize; x2 := f.r - _BorderSize; x3 := f.r;
  y0 := f.t; y1 := f.t + _BorderSize; y2 := f.b - _BorderSize; y3 := f.b;
  g2.PrimBegin(ptTriangles, bmNormal);
  g2.PrimAdd(x0, y0, c); g2.PrimAdd(x1, y1, c); g2.PrimAdd(x0, y3, c);
  g2.PrimAdd(x0, y3, c); g2.PrimAdd(x1, y1, c); g2.PrimAdd(x1, y2, c);
  g2.PrimAdd(x0, y0, c); g2.PrimAdd(x3, y0, c); g2.PrimAdd(x1, y1, c);
  g2.PrimAdd(x1, y1, c); g2.PrimAdd(x3, y0, c); g2.PrimAdd(x2, y1, c);
  g2.PrimAdd(x2, y1, c); g2.PrimAdd(x3, y0, c); g2.PrimAdd(x2, y2, c);
  g2.PrimAdd(x2, y2, c); g2.PrimAdd(x3, y0, c); g2.PrimAdd(x3, y3, c);
  g2.PrimAdd(x1, y2, c); g2.PrimAdd(x2, y2, c); g2.PrimAdd(x0, y3, c);
  g2.PrimAdd(x0, y3, c); g2.PrimAdd(x2, y2, c); g2.PrimAdd(x3, y3, c);
  g2.PrimEnd;
  g2.PrimRect(cf.x, f.y + _BorderSize, cf.w, _HeaderSize, App.UI.GetColorPrimary(0.3));
  g2.PrimRect(
    cf.x, cf.y, cf.w, cf.h,
    App.UI.GetColorPrimary(0.4)
  );
  App.UI.Font1.Print(
    cf.l + (cf.w - App.UI.Font1.TextWidth(_Caption)) * 0.5,
    f.t + _BorderSize + (_HeaderSize - App.UI.Font1.TextHeight('A')) * 0.5,
    1, 1, $ffffffff, _Caption, bmNormal, tfPoint
  );
end;

function TUIWorkspaceCustomGroup.GetMinWidth: Single;
begin
  Result := _BorderSize * 2 + G2Max(_Children[0].GetMinWidth, App.UI.Font1.TextWidth(_Caption));
end;

function TUIWorkspaceCustomGroup.GetMinHeight: Single;
begin
  Result := _Children[0].GetMinHeight + _BorderSize * 2 + _HeaderSize;
end;
//TUIWorkspaceCustomGroup END

//TUIWorkspaceCustomButton BEGIN
procedure TUIWorkspaceCustomButton.OnInitialize;
begin
  inherited OnInitialize;
  _Caption := 'Button';
  _Hint := '';
  _Enabled := True;
  _Icon := nil;
  _IconFilter := tfPoint;
  _ShowHint := 0;
  _ProcOnClick := nil;
  _ProcOnClickSender := nil;
  _MdInButton := False;
  SizingV := csFixed;
end;

procedure TUIWorkspaceCustomButton.OnRender;
  var c0, c1: TG2Color;
  var a: Single;
  var tx, ty: Single;
begin
  if _Enabled then
  a := 1
  else
  a := 0.5;
  c0 := App.UI.GetColorPrimary(0.5, a);
  if _Enabled
  and Frame.Contains(g2.MousePos) then
  begin
    if g2.MouseDown[G2MB_Left] and Frame.Contains(g2.MouseDownPos[G2MB_Left]) then
    c1 := App.UI.GetColorPrimary(0.4, a)
    else
    c1 := App.UI.GetColorPrimary(0.7, a);
  end
  else
  c1 := App.UI.GetColorPrimary(0.6, a);
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    c0
  );
  g2.PrimRect(
    Frame.x + 2, Frame.y + 2, Frame.w - 4, Frame.h - 4,
    c1
  );
  tx := Frame.l + (Frame.w - App.UI.Font1.TextWidth(_Caption)) * 0.5;
  ty := Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  if _Icon <> nil then
  begin
    tx -= _Icon.Width * 0.5;
    g2.PicRect(
      Round(tx), Round((Frame.t + Frame.b - _Icon.Height) * 0.5),
      _Icon.Width, _Icon.Height, $ffffffff, _Icon, bmNormal, _IconFilter
    );
    tx += _Icon.Width;
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _Caption,
    bmNormal, tfPoint
  );
end;

procedure TUIWorkspaceCustomButton.OnUpdate;
begin
  if (Length(_Hint) > 0)
  and Frame.Contains(g2.MousePos) then
  _ShowHint += 0.05
  else
  _ShowHint := 0;
  if _ShowHint > 1 then
  begin
    App.UI.Hint.Enabled := True;
    App.UI.Hint.Text := _Hint;
    App.UI.Hint.Pos.x := Frame.Center.x;
    App.UI.Hint.Pos.y := Frame.t - App.UI.Font1.TextHeight('A') * 0.5 - App.UI.Hint.BorderSize.y;
  end;
end;

procedure TUIWorkspaceCustomButton.OnMouseDown(const Button, x, y: Integer);
begin
  if (Button = G2MB_Left) then
  begin
    if (App.UI.Overlay = nil)
    and (_Enabled)
    and (Frame.Contains(x, y)) then
    begin
      _MdInButton := True;
    end
    else
    begin
      _MdInButton := False;
    end;
  end;
end;

procedure TUIWorkspaceCustomButton.OnMouseUp(const Button, x, y: Integer);
begin
  if (Button = G2MB_Left)
  and _Enabled
  and _MdInButton
  and Frame.Contains(x, y) then
  begin
    if Assigned(_ProcOnClick) then App.UI.MsgCallProc(_ProcOnClick); //_ProcOnClick;
    if Assigned(_ProcOnClickSender) then App.UI.MsgCallProcPtr(_ProcOnClickSender, Self); //_ProcOnClickSender(Self);
  end;
end;

function TUIWorkspaceCustomButton.GetMinWidth: Single;
begin
  Result := App.UI.Font1.TextWidth(_Caption);
  if _Icon <> nil then
  Result += _Icon.Width;
  Result := G2Max(inherited GetMinWidth, Result);
end;
//TUIWorkspaceCustomButton END

//TUIWorkspaceCustomLabel BEGIN
procedure TUIWorkspaceCustomLabel.OnInitialize;
begin
  inherited OnInitialize;
  _Caption := 'Label';
  _Color := $ff000000;
  SizingV := csFixed;
  _Align := [caLeft, caTop];
end;

procedure TUIWorkspaceCustomLabel.OnRender;
  var TextSize: TG2Vec2;
  var TextPos: TG2Vec2;
begin
  TextSize.x := App.UI.Font1.TextWidth(_Caption);
  TextSize.y := App.UI.Font1.TextHeight('A');
  if caLeft in _Align then
  TextPos.x := Frame.l
  else if caRight in _Align then
  TextPos.x := Frame.r - TextSize.x
  else
  TextPos.x := Frame.l + (Frame.w - TextSize.x) * 0.5;
  if caTop in _Align then
  TextPos.y := Frame.t
  else if caBottom in _Align then
  TextPos.y := Frame.b - TextSize.y
  else
  TextPos.y := Frame.t + (Frame.h - TextSize.y) * 0.5;
  App.UI.Font1.Print(Round(TextPos.x), Round(TextPos.y), 1, 1, _Color, _Caption, bmNormal, tfPoint);
end;

function TUIWorkspaceCustomLabel.GetMinWidth: Single;
begin
  Result := App.UI.Font1.TextWidth(_Caption);
end;

function TUIWorkspaceCustomLabel.GetMinHeight: Single;
begin
  Result := G2Max(inherited GetMinHeight, App.UI.Font1.TextHeight('A'));
end;
//TUIWorkspaceCustomLabel END

//TUIWorkspaceCustomEdit BEGIN
procedure TUIWorkspaceCustomEdit.OnTextCursorMove;
  var cp: TG2Vec2;
  var s: Single;
begin
  cp := App.UI.TextEdit.GetCursorPos;
  s := App.UI.TextEdit.Frame.w * 0.25;
  if s > 0 then
  begin
    while cp.x < App.UI.TextEdit.Frame.l + 4 do
    begin
      _TextPos.x := G2Min(App.UI.TextEdit.Frame.l + 4, _TextPos.x + s);
      cp.x := cp.x + s;
    end;
    while cp.x > App.UI.TextEdit.Frame.r do
    begin
      _TextPos.x := _TextPos.x - s;
      cp.x := cp.x - s;
    end;
  end;
end;

procedure TUIWorkspaceCustomEdit.AdjustTextPos;
begin
  _TextPos := G2Vec2(Frame.l + 4, Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5);
end;

procedure TUIWorkspaceCustomEdit.OnFinishEdit;
begin
  if Assigned(_OnFinishProc) then _OnFinishProc;
end;

procedure TUIWorkspaceCustomEdit.OnInitialize;
begin
  inherited OnInitialize;
  _Text := '';
  SizingV := csFixed;
  _OnFinishProc := nil;
end;

procedure TUIWorkspaceCustomEdit.OnAdjust;
begin
  inherited OnAdjust;
  AdjustTextPos;
  if App.UI.TextEdit.Enabled then
  OnTextCursorMove;
end;

procedure TUIWorkspaceCustomEdit.OnRender;
  var tx, ty: Single;
  var r: TRect;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - 2, Frame.h - 2,
    App.UI.GetColorPrimary(0.3)
  );
  tx := _TextPos.x;//Frame.l + 4;
  ty := _TextPos.y;//Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  r := Frame.Expand(-2, -2);
  App.UI.PushClipRect(r);
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _Text,
    bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceCustomEdit.OnMouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  r := Frame;
  if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
  begin
    App.UI.TextEdit.Enable(@_Text, @_TextPos, App.UI.Font1, nil, '', nil, @OnTextCursorMove);
    App.UI.TextEdit.AllowSymbols := True;
    App.UI.TextEdit.MaxLength := 0;
    App.UI.TextEdit.Frame := r;
    App.UI.TextEdit.OnFinishProc := @OnFinishEdit;
    AdjustTextPos;
    App.UI.TextEdit.AdjustCursor(x, y);
  end;
end;
//TUIWorkspaceCustomEdit END

//TUIWorkspaceCustomNumberInt BEGIN
procedure TUIWorkspaceCustomNumberInt.OnTextCursorMove;
  var cp: TG2Vec2;
  var s: Single;
begin
  cp := App.UI.TextEdit.GetCursorPos;
  s := App.UI.TextEdit.Frame.w * 0.25;
  if s > 0 then
  begin
    while cp.x < App.UI.TextEdit.Frame.l + 4 do
    begin
      _TextPos.x := G2Min(App.UI.TextEdit.Frame.l + 4, _TextPos.x + s);
      cp.x := cp.x + s;
    end;
    while cp.x > App.UI.TextEdit.Frame.r do
    begin
      _TextPos.x := _TextPos.x - s;
      cp.x := cp.x - s;
    end;
  end;
end;

procedure TUIWorkspaceCustomNumberInt.OnTextChange;
begin
  if not App.UI.TextEdit.Enabled then
  begin
    Number := StrToIntDef(_Text, _Number);
  end;
end;

procedure TUIWorkspaceCustomNumberInt.SetNumber(const Value: Integer);
begin
  _Number := Value;
  if _NumberMin <> _NumberMax then
  _Number := G2Min(G2Max(_Number, _NumberMin), _NumberMax);
  _Text := IntToStr(_Number);
  if Assigned(_OnChangeProc) then _OnChangeProc;
end;

procedure TUIWorkspaceCustomNumberInt.AdjustTextPos;
begin
  _TextPos := G2Vec2(Frame.l + 4, Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5);
end;

procedure TUIWorkspaceCustomNumberInt.OnSpin(const Amount: Integer);
begin
  Number := Number + Amount * _Increment;
end;

procedure TUIWorkspaceCustomNumberInt.SetNumberMax(const Value: Integer);
begin
  if _NumberMax = Value then Exit;
  _NumberMax := Value;
  Number := _Number;
end;

procedure TUIWorkspaceCustomNumberInt.SetNumberMin(const Value: Integer);
begin
  if _NumberMin = Value then Exit;
  _NumberMin := Value;
  Number := _Number;
end;

procedure TUIWorkspaceCustomNumberInt.OnInitialize;
begin
  inherited OnInitialize;
  _NumberMin := 0;
  _NumberMax := 0;
  _Increment := 1;
  _OnChangeProc := nil;
  Number := 0;
  SizingV := csFixed;
  Height := 24;
  _Spinner.Initialize;
  _Spinner.OnSpinProc := @OnSpin;
end;

procedure TUIWorkspaceCustomNumberInt.OnAdjust;
  var r: TG2Rect;
begin
  inherited OnAdjust;
  r := Frame;
  r.l := r.r - Height;
  _Spinner.Frame := r;
  AdjustTextPos;
  if App.UI.TextEdit.Enabled then
  OnTextCursorMove;
end;

procedure TUIWorkspaceCustomNumberInt.OnUpdate;
begin
  _Spinner.Update;
end;

procedure TUIWorkspaceCustomNumberInt.OnRender;
  var tx, ty: Single;
  var r: TRect;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w - _Spinner.Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - _Spinner.Frame.w - 2, Frame.h - 2,
    App.UI.GetColorPrimary(0.3)
  );
  tx := _TextPos.x;//Frame.l + 4;
  ty := _TextPos.y;//Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  r := Frame.Expand(-2, -2);
  r.Right := Round(r.Right - _Spinner.Frame.w);
  App.UI.PushClipRect(r);
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _Text,
    bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  _Spinner.Render;
end;

procedure TUIWorkspaceCustomNumberInt.OnMouseDown(const Button, x, y: Integer);
begin
  _Spinner.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceCustomNumberInt.OnMouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  _Spinner.MouseUp(Button, x, y);
  r := Frame;
  r.r := r.r - _Spinner.Frame.w;
  if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
  begin
    App.UI.TextEdit.Enable(@_Text, @_TextPos, App.UI.Font1, @OnTextChange, IntToStr(_Number), nil, @OnTextCursorMove);
    App.UI.TextEdit.AllowedChars := ['0'..'9', '-'];
    App.UI.TextEdit.MaxLength := 0;
    App.UI.TextEdit.Frame := r;
    AdjustTextPos;
    App.UI.TextEdit.AdjustCursor(x, y);
  end;
end;
//TUIWorkspaceCustomNumberInt END

//TUIWorkspaceCustomNumberFloat BEGIN
procedure TUIWorkspaceCustomNumberFloat.OnTextCursorMove;
  var cp: TG2Vec2;
  var s: Single;
begin
  cp := App.UI.TextEdit.GetCursorPos;
  s := App.UI.TextEdit.Frame.w * 0.25;
  if s > 0 then
  begin
    while cp.x < App.UI.TextEdit.Frame.l + 4 do
    begin
      _TextPos.x := G2Min(App.UI.TextEdit.Frame.l + 4, _TextPos.x + s);
      cp.x := cp.x + s;
    end;
    while cp.x > App.UI.TextEdit.Frame.r do
    begin
      _TextPos.x := _TextPos.x - s;
      cp.x := cp.x - s;
    end;
  end;
end;

procedure TUIWorkspaceCustomNumberFloat.OnTextChange;
begin
  if not App.UI.TextEdit.Enabled then
  begin
    Number := StrToFloatDef(_Text, _Number);
  end;
end;

procedure TUIWorkspaceCustomNumberFloat.SetNumber(const Value: TG2Float);
begin
  _Number := Value;
  if _NumberMin <> _NumberMax then
  _Number := G2Min(G2Max(_Number, _NumberMin), _NumberMax);
  _Text := FormatFloat(FloatPrintFormat, _Number);
  if Assigned(_OnChangeProc) then _OnChangeProc;
end;

procedure TUIWorkspaceCustomNumberFloat.AdjustTextPos;
begin
  _TextPos := G2Vec2(Frame.l + 4, Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5);
end;

procedure TUIWorkspaceCustomNumberFloat.OnSpin(const Amount: Integer);
begin
  Number := Number + Amount * _Increment;
end;

procedure TUIWorkspaceCustomNumberFloat.SetNumberMax(const Value: TG2Float);
begin
  if _NumberMax = Value then Exit;
  _NumberMax := Value;
  Number := _Number;
end;

procedure TUIWorkspaceCustomNumberFloat.SetNumberMin(const Value: TG2Float);
begin
  if _NumberMin = Value then Exit;
  _NumberMin := Value;
  Number := _Number;
end;

procedure TUIWorkspaceCustomNumberFloat.OnInitialize;
begin
  inherited OnInitialize;
  _NumberMin := 0;
  _NumberMax := 0;
  _Increment := 0.5;
  _OnChangeProc := nil;
  Number := 0;
  SizingV := csFixed;
  Height := 24;
  _Spinner.Initialize;
  _Spinner.OnSpinProc := @OnSpin;
end;

procedure TUIWorkspaceCustomNumberFloat.OnAdjust;
  var r: TG2Rect;
begin
  inherited OnAdjust;
  r := Frame;
  r.l := r.r - Height;
  _Spinner.Frame := r;
  AdjustTextPos;
  if App.UI.TextEdit.Enabled then
  OnTextCursorMove;
end;

procedure TUIWorkspaceCustomNumberFloat.OnUpdate;
begin
  _Spinner.Update;
end;

procedure TUIWorkspaceCustomNumberFloat.OnRender;
  var tx, ty: Single;
  var r: TRect;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w - _Spinner.Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - _Spinner.Frame.w - 2, Frame.h - 2,
    App.UI.GetColorPrimary(0.3)
  );
  tx := _TextPos.x;//Frame.l + 4;
  ty := _TextPos.y;//Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  r := Frame.Expand(-2, -2);
  r.Right := Round(r.Right - _Spinner.Frame.w);
  App.UI.PushClipRect(r);
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _Text,
    bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  _Spinner.Render;
end;

procedure TUIWorkspaceCustomNumberFloat.OnMouseDown(const Button, x, y: Integer);
begin
  _Spinner.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceCustomNumberFloat.OnMouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  _Spinner.MouseUp(Button, x, y);
  r := Frame;
  r.r := r.r - _Spinner.Frame.w;
  if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
  begin
    App.UI.TextEdit.Enable(@_Text, @_TextPos, App.UI.Font1, @OnTextChange, FormatFloat(FloatPrintFormat, _Number), nil, @OnTextCursorMove);
    App.UI.TextEdit.AllowedChars := ['0'..'9', '.', '-'];
    App.UI.TextEdit.MaxLength := 0;
    App.UI.TextEdit.Frame := r;
    AdjustTextPos;
    App.UI.TextEdit.AdjustCursor(x, y);
  end;
end;
//TUIWorkspaceCustomNumberFloat END

//TUIWorkspaceCustomSlider BEGIN
procedure TUIWorkspaceCustomSlider.SetPosition(const Value: TG2Float);
  var p: TG2Float;
begin
  p := Value;
  if p < 0 then p := 0
  else if p > 1 then p := 1;
  if p = _Position then Exit;
  _Position := p;
  if Assigned(_OnChange) then _OnChange;
end;

procedure TUIWorkspaceCustomSlider.OnInitialize;
begin
  inherited OnInitialize;
  _SliderSize := 8;
  SizingV := csFixed;
  Height := 24;
  Width := 128;
  _Position := 0;
  _OnChange := nil;
  _Drag := False;
end;

procedure TUIWorkspaceCustomSlider.OnRender;
  var r: TG2Rect;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - 2, Frame.h - 2,
    App.UI.GetColorPrimary(0.3)
  );
  r.l := G2LerpFloat(Frame.l + 1, Frame.r - 1 - _SliderSize, _Position);
  r.t := Frame.t + 1;
  r.w := _SliderSize;
  r.b := Frame.b - 1;
  g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.6));
  if (App.UI.Overlay = nil)
  and (
    r.Contains(g2.MousePos)
    or _Drag
  ) then
  g2.PrimRect(r.x + 1, r.y + 1, r.w - 2, r.h - 2, App.UI.GetColorPrimary(0.9))
  else
  g2.PrimRect(r.x + 1, r.y + 1, r.w - 2, r.h - 2, App.UI.GetColorPrimary(0.7));
  g2.PrimRectCol(
    Frame.l + 1, Frame.t + 1, r.l - (Frame.l + 1), Frame.h - 2,
    App.UI.GetColorSecondary(0.5), App.UI.GetColorSecondary(0.5),
    App.UI.GetColorSecondary(0.3), App.UI.GetColorSecondary(0.3)
  );
end;

procedure TUIWorkspaceCustomSlider.OnUpdate;
  var p: TG2Float;
begin
  if _Drag then
  begin
    p := g2.MousePos.x + _DragOffset;
    Position := (p - (Frame.l + 1)) / (Frame.w - 2 - _SliderSize);
  end;
end;

procedure TUIWorkspaceCustomSlider.OnMouseDown(const Button, x, y: Integer);
  var r: TG2Rect;
begin
  if Button = G2MB_Left then
  begin
    r.l := G2LerpFloat(Frame.l + 1, Frame.r - 1 - _SliderSize, _Position);
    r.t := Frame.t + 1;
    r.w := _SliderSize;
    r.b := Frame.b - 1;
    if r.Contains(x, y) then
    begin
      _Drag := True;
      _DragOffset := r.l - x;
    end;
  end;
end;

procedure TUIWorkspaceCustomSlider.OnMouseUp(const Button, x, y: Integer);
begin
  _Drag := False;
end;

function TUIWorkspaceCustomSlider.GetMinWidth: Single;
begin
  Result:=inherited GetMinWidth;
end;

function TUIWorkspaceCustomSlider.GetMinHeight: Single;
begin
  Result:=inherited GetMinHeight;
end;
//TUIWorkspaceCustomSlider END

//TUIWorkspaceCustomFile BEGIN
procedure TUIWorkspaceCustomFile.OnInitialize;
begin
  inherited OnInitialize;
  _FileName := '';
  _FilePath := '';
  SizingV := csFixed;
  Height := 24;
  _OnSelect := nil;
end;

procedure TUIWorkspaceCustomFile.OnRender;
  var tx, ty: Single;
  var r: TRect;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - 2, Frame.h - 2,
    App.UI.GetColorPrimary(0.3)
  );
  tx := Frame.l + 4;
  ty := Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  r := Frame.Expand(-2, -2);
  App.UI.PushClipRect(r);
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _FileName,
    bmNormal, tfPoint
  );
  if (App.UI.Overlay = nil) and Frame.Contains(g2.MousePos) then
  begin
    g2.PrimRect(
      Frame.x, Frame.y, Frame.w, Frame.h,
      $ff404040, bmAdd
    );
  end;
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceCustomFile.OnUpdate;
begin
  inherited OnUpdate;
  if (Length(_FilePath) > 0)
  and Frame.Contains(g2.MousePos) then
  _ShowHint += 0.05
  else
  _ShowHint := 0;
  if _ShowHint > 1 then
  begin
    App.UI.Hint.Enabled := True;
    App.UI.Hint.Text := _FilePath;
    App.UI.Hint.Pos.x := Frame.Center.x;
    App.UI.Hint.Pos.y := Frame.t - App.UI.Font1.TextHeight('A') * 0.5 - App.UI.Hint.BorderSize.y;
  end;
end;

procedure TUIWorkspaceCustomFile.OnMouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
  var od: TOpenDialog;
  var OldPath: String;
  var PrevPause: Boolean;
begin
  r := Frame;
  if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
  begin
    od := TOpenDialog.Create(nil);
    PrevPause := g2.Pause;
    try
      g2.Pause := True;
      if od.Execute then
      begin
        OldPath := _FilePath;
        _FilePath := od.FileName;
        _FileName := ExtractFileName(_FilePath);
        if Assigned(_OnSelect)
        and (_FilePath <> OldPath) then
        _OnSelect;
      end;
    finally
      g2.Pause := PrevPause;
      od.Free;
    end;
  end;
end;
//TUIWorkspaceCustomFile END

//TUIWorkspaceCustomColor BEGIN
procedure TUIWorkspaceCustomColor.OnInitialize;
begin
  inherited OnInitialize;
  _Color := $ffffffff;
  SizingV := csFixed;
  Height := 24;
  _OnSelect := nil;
end;

procedure TUIWorkspaceCustomColor.OnRender;
  var tx, ty: Single;
  var r: TRect;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - 2, Frame.h - 2,
    App.UI.GetColorPrimary(0.3)
  );
  tx := Frame.l + 4;
  ty := Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  r := Frame.Expand(-2, -2);
  App.UI.PushClipRect(r);
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    _Color,
    IntToHex(LongWord(_Color) and $ffffff, 6),
    bmNormal, tfPoint
  );
  if (App.UI.Overlay = nil) and Frame.Contains(g2.MousePos) then
  begin
    g2.PrimRect(
      Frame.x, Frame.y, Frame.w, Frame.h,
      $ff404040, bmAdd
    );
  end;
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceCustomColor.OnUpdate;
begin
  inherited OnUpdate;
end;

procedure TUIWorkspaceCustomColor.OnMouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
  var cd: TColorDialog;
  var OldColor: TG2Color;
  var PrevPause: Boolean;
begin
  r := Frame;
  if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
  begin
    cd := TColorDialog.Create(nil);
    PrevPause := g2.Pause;
    try
      g2.Pause := True;
      cd.Color := RGB(_Color.r, _Color.g, _Color.b);
      if cd.Execute then
      begin
        OldColor := _Color;
        _Color.r := cd.Color and $ff;
        _Color.g := (cd.Color shr 8) and $ff;
        _Color.b := (cd.Color shr 16) and $ff;
        if Assigned(_OnSelect)
        and (_Color <> OldColor) then
        _OnSelect;
      end;
    finally
      g2.Pause := PrevPause;
      cd.Free;
    end;
  end;
end;
//TUIWorkspaceCustomColor END

//TUIWorkspaceCustomComboBox BEGIN
procedure TUIWorkspaceCustomComboBox.TOverlayWorkspaceList.Initialize;
  var i: Integer;
begin
  Items.Clear;
  for i := 0 to ComboBox.ItemCount - 1 do
  if i <> ComboBox.ItemIndex then
  Items.Add(i);
  Frame := ComboBox.Frame;
  Frame.t := Frame.b;
  if ComboBox.ItemIndex > -1 then
  Frame.h := G2Min(ComboBox.ItemCount - 1, 6) * ComboBox.Frame.h
  else
  Frame.h := G2Min(ComboBox.ItemCount, 6) * ComboBox.Frame.h;
  if Frame.b > g2.Params.Height then
  Frame.y := ComboBox.Frame.t - Frame.h;
  if Items.Count > 6 then
  begin
    Scrolling := True;
    ScrollV.Initialize;
    ScrollV.Orientation := sbVertical;
    ScrollV.Enabled := True;
    ScrollV.PosRelative := 0;
    ScrollV.Frame := Frame;
    ScrollV.Frame.l := Frame.r - 18;
    ScrollV.ContentSize := Items.Count * ComboBox.Frame.h;
    ScrollV.ParentSize := Frame.h;
    Frame.r := ScrollV.Frame.l;
  end
  else
  Scrolling := False;
  App.UI.Overlay := Self;
end;

procedure TUIWorkspaceCustomComboBox.TOverlayWorkspaceList.Render;
  var i: Integer;
  var r: TG2Rect;
  var c: TG2Color;
begin
  g2.PrimRect(Frame.x, Frame.y, Frame.w, Frame.h, App.UI.GetColorPrimary(0.2));
  App.UI.PushClipRect(Frame);
  r := Frame;
  r.b := r.t + ComboBox.Frame.h;
  r.y := r.y - ScrollV.PosAbsolute;
  for i := 0 to Items.Count - 1 do
  begin
    if Frame.Contains(g2.MousePos)
    and r.Contains(g2.MousePos) then
    begin
      g2.PrimRect(r.l + 2, r.t + 2, r.w - 4, r.h - 4, App.UI.GetColorPrimary(0.3));
      c := $ffffffff;
    end
    else
    c := $ffcccccc;
    App.UI.Font1.Print(
      Round(r.l + 4), Round(r.t + (r.h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, c, ComboBox.Items[Items[i]], bmNormal, tfPoint
    );
    r.y := r.y + r.h;
  end;
  App.UI.PopClipRect;
  ScrollV.Render;
end;

procedure TUIWorkspaceCustomComboBox.TOverlayWorkspaceList.Update;
begin
  ScrollV.Update;
end;

procedure TUIWorkspaceCustomComboBox.TOverlayWorkspaceList.MouseDown(const Button, x, y: Integer);
begin
  ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceCustomComboBox.TOverlayWorkspaceList.MouseUp(const Button, x, y: Integer);
  var i: Integer;
  var r: TG2Rect;
begin
  if ScrollV.Frame.Contains(g2.MouseDownPos[Button]) then
  begin
    ScrollV.MouseUp(Button, x, y);
    Exit;
  end;
  if Frame.Contains(x, y) and Frame.Contains(g2.MouseDownPos[Button]) then
  begin
    r := Frame;
    r.h := ComboBox.Frame.h;
    r.y := r.y - ScrollV.PosAbsolute;
    for i := 0 to Items.Count - 1 do
    begin
      if r.Contains(x, y) and r.Contains(g2.MouseDownPos[Button]) then
      begin
        ComboBox.ItemIndex := Items[i];
        Break;
      end;
      r.y := r.y + r.h;
    end;
  end;
  App.UI.Overlay := nil;
end;

procedure TUIWorkspaceCustomComboBox.TOverlayWorkspaceList.Scroll(const y: Integer);
begin
  ScrollV.Scroll(y);
end;

function TUIWorkspaceCustomComboBox.GetItem(const Index: Integer): AnsiString;
begin
  Result := _Items[Index];
end;

procedure TUIWorkspaceCustomComboBox.SetItem(const Index: Integer; const Value: AnsiString);
begin
  _Items[Index] := Value;
end;

function TUIWorkspaceCustomComboBox.GetItemCount: Integer;
begin
  Result := _Items.Count;
end;

procedure TUIWorkspaceCustomComboBox.SetItemIndex(const Value: Integer);
  var PrevIndex: Integer;
begin
  if (Value = _ItemIndex) or (Value < -1) or (Value > _Items.Count - 1 ) then Exit;
  PrevIndex := _ItemIndex;
  _ItemIndex := Value;
  if Assigned(_OnChange) then
  _OnChange(PrevIndex);
end;

function TUIWorkspaceCustomComboBox.GetText: AnsiString;
begin
  if (_Items.Count > 0) and (_ItemIndex >= 0) and (_ItemIndex < _Items.Count) then
  Result := _Items[_ItemIndex]
  else
  Result := '';
end;

procedure TUIWorkspaceCustomComboBox.SetText(const Value: AnsiString);
  var i: Integer;
begin
  for i := 0 to _Items.Count - 1 do
  if LowerCase(Value) = LowerCase(_Items[i]) then
  begin
    _ItemIndex := i;
    Exit;
  end;
end;

procedure TUIWorkspaceCustomComboBox.OnInitialize;
begin
  inherited OnInitialize;
  _ItemIndex := -1;
  SizingV := csFixed;
  Height := 24;
  _Overlay := TOverlayWorkspaceList.Create;
  _Overlay.ComboBox := Self;
  _OnChange := nil;
end;

procedure TUIWorkspaceCustomComboBox.OnFinalize;
begin
  if App.UI.Overlay = _Overlay then
  App.UI.Overlay := nil;
  _Overlay.Free;
  inherited OnFinalize;
end;

procedure TUIWorkspaceCustomComboBox.OnAdjust;
begin
  inherited OnAdjust;
end;

procedure TUIWorkspaceCustomComboBox.OnRender;
  var tx, ty: Single;
  var r: TRect;
  var Str: AnsiString;
  var c: TG2Color;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.1)
  );
  if Frame.Contains(g2.MousePos)
  and (App.UI.Overlay = nil) then
  c := App.UI.GetColorPrimary(0.5)
  else
  c := App.UI.GetColorPrimary(0.3);
  g2.PrimRect(
    Frame.x + 1, Frame.y + 1, Frame.w - 2, Frame.h - 2, c
  );
  if _ItemIndex > -1 then
  begin
    Str := _Items[_ItemIndex];
    r := Frame.Expand(-2, -2);
    tx := Frame.l + 4;
    ty := Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
    App.UI.PushClipRect(r);
    App.UI.Font1.Print(
      tx, ty, 1, 1,
      App.UI.GetColorPrimary(1),
      Str,
      bmNormal, tfPoint
    );
    App.UI.PopClipRect;
  end;
end;

procedure TUIWorkspaceCustomComboBox.OnMouseUp(const Button, x, y: Integer);
begin
  if Frame.Contains(g2.MouseDownPos[Button])
  and Frame.Contains(x, y)
  and ((_Items.Count > 1) or ((_Items.Count = 1) and (_ItemIndex = -1))) then
  begin
    _Overlay.Initialize;
  end;
end;

procedure TUIWorkspaceCustomComboBox.Clear;
begin
  _Items.Clear;
  ItemIndex := -1;
end;

procedure TUIWorkspaceCustomComboBox.Add(const Item: AnsiString);
begin
  _Items.Add(Item);
  if _ItemIndex = -1 then
  _ItemIndex := 0;
end;
//TUIWorkspaceCustomComboBox END

//TUIWorkspaceCustomCheckbox BEGIN
procedure TUIWorkspaceCustomCheckbox.OnInitialize;
begin
  inherited OnInitialize;
  _Caption := 'CheckBox';
  _Checked := False;
  _OnChange := nil;
  SizingV := csFixed;
  SizingH := csFixed;
end;

procedure TUIWorkspaceCustomCheckbox.OnRender;
  var r: TG2Rect;
  var tx, ty: Single;
begin
  r.l := Frame.l + 4;
  r.t := (Frame.b + Frame.t) * 0.5 - 12;
  r.w := 24;
  r.h := 24;
  App.UI.DrawCheckbox(r, App.UI.GetColorPrimary(1), App.UI.GetColorSecondary(1), _Checked);
  tx := r.r + 4;
  ty := Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _Caption,
    bmNormal, tfPoint
  );
end;

procedure TUIWorkspaceCustomCheckbox.OnMouseUp(const Button, x, y: Integer);
begin
  if Frame.Contains(x, y) and Frame.Contains(g2.MouseDownPos[Button]) then
  begin
    _Checked := not _Checked;
    if Assigned(_OnChange) then _OnChange;
  end;
end;

function TUIWorkspaceCustomCheckbox.GetMinWidth: Single;
begin
  Result := 36 + App.UI.Font1.TextWidth(_Caption);
end;

function TUIWorkspaceCustomCheckbox.GetMinHeight: Single;
begin
  Result := G2Max(App.UI.Font1.TextHeight('A'), 24);
end;
//TUIWorkspaceCustomCheckbox END

//TUIWorkspaceCustomRadio BEIGN
procedure TUIWorkspaceCustomRadio.SetChecked(const Value: Boolean);
  var i: Integer;
begin
  if Value = _Checked then Exit;
  _Checked := Value;
  if _Checked and (Parent <> nil) then
  begin
    for i := 0 to Parent.ChildCount - 1 do
    if (Parent.Children[i] <> Self)
    and (Parent.Children[i] is TUIWorkspaceCustomRadio)
    and (TUIWorkspaceCustomRadio(Parent.Children[i]).Group = _Group) then
    begin
      TUIWorkspaceCustomRadio(Parent.Children[i]).Checked := False;
    end;
  end;
end;

procedure TUIWorkspaceCustomRadio.OnInitialize;
begin
  inherited OnInitialize;
  _Caption := 'Radio';
  _Checked := False;
  _Group := 0;
  SizingV := csFixed;
end;

procedure TUIWorkspaceCustomRadio.OnRender;
  var r: TG2Rect;
  var tx, ty: Single;
begin
  r.l := Frame.l + 4;
  r.t := (Frame.b + Frame.t) * 0.5 - 12;
  r.w := 24;
  r.h := 24;
  App.UI.DrawRadio(r, App.UI.GetColorPrimary(1), App.UI.GetColorSecondary(1), _Checked);
  tx := r.r + 4;
  ty := Frame.t + (Frame.h - App.UI.Font1.TextHeight('A')) * 0.5;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    App.UI.GetColorPrimary(1),
    _Caption,
    bmNormal, tfPoint
  );
end;

procedure TUIWorkspaceCustomRadio.OnMouseUp(const Button, x, y: Integer);
begin
  if Frame.Contains(x, y) and Frame.Contains(g2.MouseDownPos[Button]) then
  begin
    Checked := True;
  end;
end;
//TUIWorkspaceCustomRadio END

//TUIWorkspaceCustomPages BEGIN
function TUIWorkspaceCustomPages.GetPage(const Index: Integer): TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom(Children[Index]);
end;

procedure TUIWorkspaceCustomPages.SetPageIndex(const Value: Integer);
begin
  if _PageIndex = Value then Exit;
  _PageIndex := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustomPages.OnInitialize;
begin
  inherited OnInitialize;
  _PageIndex := -1;
end;

procedure TUIWorkspaceCustomPages.OnAdjust;
begin
  if _PageIndex > -1 then
  Children[_PageIndex].Frame := Frame;
end;

procedure TUIWorkspaceCustomPages.Update;
begin
  if _PageIndex > -1 then
  Children[_PageIndex].Update;
  OnUpdate;
end;

procedure TUIWorkspaceCustomPages.Render;
  var r: TRect;
begin
  if _PageIndex > -1 then
  begin
    r := Frame;
    App.UI.PushClipRect(r);
    Children[_PageIndex].Render;
    App.UI.PopClipRect;
  end;
  OnRender;
end;

procedure TUIWorkspaceCustomPages.MouseDown(const Button, x, y: Integer);
begin
  if (_PageIndex > -1) and (Frame.Contains(x, y)) then
  Children[_PageIndex].MouseDown(Button, x, y);
  OnMouseDown(Button, x, y);
end;

procedure TUIWorkspaceCustomPages.MouseUp(const Button, x, y: Integer);
begin
  if _PageIndex > -1 then
  Children[_PageIndex].MouseUp(Button, x, y);
  OnMouseUp(Button, x, y);
end;

function TUIWorkspaceCustomPages.AddPage: TUIWorkspaceCustom;
begin
  Result := TUIWorkspaceCustom.Create;
  Result.Parent := Self;
  if _PageIndex = -1 then
  PageIndex := 0;
end;

function TUIWorkspaceCustomPages.GetMinWidth: Single;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to ChildCount - 1 do
  Result := G2Max(Result, Children[i].GetMinWidth);
  Result := G2Max(Result, 32);
end;

function TUIWorkspaceCustomPages.GetMinHeight: Single;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to ChildCount - 1 do
  Result := G2Max(Result, Children[i].GetMinHeight);
  Result := G2Max(Result, 32);
end;
//TUIWorkspaceCustomPages END

//TUIWorkspaceCustomGraph BEGIN
function TUIWorkspaceCustomGraph.GetScaleX: TG2Float;
begin
  Result := _ScaleXMax - _ScaleXMin;
end;

function TUIWorkspaceCustomGraph.GetScaleY: TG2Float;
begin
  Result := _ScaleYMax - _ScaleYMin;
end;

function TUIWorkspaceCustomGraph.PointToScreen(const v: TG2Vec2): TG2Vec2;
begin
  Result.x := _FrameGraph.l + (v.x - _ScaleXMin) * (_FrameGraph.w / ScaleX);
  Result.y := _FrameGraph.b - (v.y - _ScaleYMin) * (_FrameGraph.h / ScaleY);
end;

function TUIWorkspaceCustomGraph.PointToGraph(const v: TG2Vec2): TG2Vec2;
begin
  Result.x := (v.x - _FrameGraph.l) * (ScaleX / _FrameGraph.w) + _ScaleXMin;
  Result.y := (_FrameGraph.b - v.y) * (ScaleY / _FrameGraph.h) + _ScaleYMin;
end;

function TUIWorkspaceCustomGraph.PtInPoint(const v: TG2Vec2): Integer;
  var i: Integer;
  var v0, ss: TG2Vec2;
begin
  for i := 0 to _Points.Count - 1 do
  begin
    v0 := PointToScreen(_Points[i]);
    if G2Rect(v0.x - 4, v0.y - 4, 8, 8).Contains(v) then
    begin
      Result := i;
      Exit;
    end;
  end;
  Result := -1;
end;

function TUIWorkspaceCustomGraph.GetPoint(const Index: Integer): TG2Vec2;
begin
  Result := _Points[Index];
end;

procedure TUIWorkspaceCustomGraph.SetPoint(const Index: Integer; const Value: TG2Vec2);
begin
  _Points[Index] := Value;
end;

function TUIWorkspaceCustomGraph.GetPointCount: Integer;
begin
  Result := _Points.Count;
end;

procedure TUIWorkspaceCustomGraph.OnInitialize;
begin
  inherited OnInitialize;
  _RullerSize := 24;
  _SizingV := csFixed;
  Width := 180;
  Height := 200;
  _ScaleXMin := 0;
  _ScaleXMax := 1;
  _ScaleYMin := -1;
  _ScaleYMax := 1;
  _EditPoint := -1;
  _Points.Clear;
  _Points.Add(G2Vec2(0, 0.5));
end;

procedure TUIWorkspaceCustomGraph.OnAdjust;
  var r: TG2Rect;
begin
  inherited OnAdjust;
  r := Frame;
  r.l := r.l + _RullerSize;
  r.b := r.t + _RullerSize;
  _FrameRullerTop := r;
  r := Frame;
  r.t := r.t + _RullerSize;
  r.r := r.l + _RullerSize;
  _FrameRullerLeft := r;
  r := Frame;
  r.l := r.l + _RullerSize;
  r.t := r.t + _RullerSize;
  _FrameGraph := r;
end;

procedure TUIWorkspaceCustomGraph.OnUpdate;
  var v: TG2Vec2;
  var r: TG2Rect;
begin
  inherited OnUpdate;
  if _EditPoint > -1 then
  begin
    v := PointToGraph(g2.MousePos);
    r.t := _ScaleYMin;
    r.b := _ScaleYMax;
    if _EditPoint = 0 then
    begin
      r.l := _ScaleXMin;
      r.r := _ScaleXMin;
    end
    else
    begin
      r.l := _Points[_EditPoint - 1].x;
      if _EditPoint = _Points.Count - 1 then
      r.r := _ScaleXMax
      else
      r.r := _Points[_EditPoint + 1].x;
    end;
    if v.x < r.l then v.x := r.l else if v.x > r.r then v.x := r.r;
    if v.y < r.t then v.y := r.t else if v.y > r.b then v.y := r.b;
    _Points[_EditPoint] := v;
  end;
end;

procedure TUIWorkspaceCustomGraph.OnRender;
  var r: TG2Rect;
  var s: TG2Float;
  var i, st, w: Integer;
  var v0, v1, ss: TG2Vec2;
  var str: AnsiString;
begin
  if Abs(_ScaleYMax - _ScaleYMin) < G2EPS then Exit;
  if Abs(_ScaleXMax - _ScaleXMin) < G2EPS then Exit;
  r := Frame;
  g2.PrimRect(r.x, r.y, _RullerSize, _RullerSize, App.UI.GetColorPrimary(0.8));
  r := _FrameRullerTop;
  g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.8));
  r := _FrameRullerLeft;
  g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.8));
  r := _FrameGraph;
  g2.PrimRect(r.x, r.y, r.w, r.h, $ffeeeeee);
  i := Trunc(_ScaleYMin);
  st := (Trunc(_ScaleYMax) - Trunc(_ScaleYMin)) div 4;
  if st = 0 then st := 1;
  while i <= Trunc(_ScaleYMax) do
  begin
    s := (i - _ScaleYMin) / (_ScaleYMax - _ScaleYMin);
    v0 := G2Vec2(r.l, r.b - s * r.h);
    v1 := G2Vec2(r.r, v0.y);
    g2.PolyBegin(ptLines, App.UI.TexDots);
    g2.PolyAdd(v0, G2Vec2(0, 0.5), $ff404040);
    g2.PolyAdd(v1, G2Vec2(r.w * 0.25, 0.5), $ff404040);
    g2.PolyEnd;
    g2.PrimLine(v0.x - 8, v0.y, v0.x, v0.y, $ff202020);
    str := IntToStr(i);
    w := App.UI.FontCode.TextWidth(str);
    v0.x := _FrameRullerLeft.r - w - 2;
    if v0.y + App.UI.FontCode.TextHeight('A') > _FrameRullerLeft.b then
    v0.y := v0.y - App.UI.FontCode.TextHeight('A');
    App.UI.FontCode.Print(
      Round(v0.x), Round(v0.y), 1, 1,
      $ff000000, str, bmNormal, tfPoint
    );
    i += st;
  end;
  for i := Trunc(_ScaleXMin) to Trunc(_ScaleXMax) do
  begin
    s := (i - _ScaleXMin) / (_ScaleXMax - _ScaleXMin);
    v0 := G2Vec2(r.l + s * r.w, r.t);
    v1 := G2Vec2(v0.x, r.b);
    g2.PolyBegin(ptLines, App.UI.TexDots);
    g2.PolyAdd(v0, G2Vec2(0, 0.5), $ff404040);
    g2.PolyAdd(v1, G2Vec2(r.h * 0.25, 0.5), $ff404040);
    g2.PolyEnd;
    g2.PrimLine(v0.x, v0.y - 8, v0.x, v0.y, $ff202020);
    v0.x := v0.x + 2;
    v0.y := _FrameRullerTop.b - App.UI.FontCode.TextHeight('A');
    str := IntToStr(i);
    w := App.UI.FontCode.TextWidth(str);
    if v0.x + w > _FrameRullerTop.r then
    v0.x := v0.x - w - 4;
    App.UI.FontCode.Print(
      Round(v0.x), Round(v0.y), 1, 1,
      $ff000000, str, bmNormal, tfPoint
    );
  end;
  ss.x := 1 / ScaleX * _FrameGraph.w;
  ss.y := 1 / ScaleY * _FrameGraph.h;
  App.UI.PushClipRect(_FrameGraph);
  for i := 0 to _Points.Count - 1 do
  begin
    v0 := PointToScreen(_Points[i]);
    if i = _Points.Count - 1 then
    begin
      v1 := v0;
      v1.x := _FrameGraph.r;
    end
    else
    begin
      v1 := PointToScreen(_Points[i + 1]);
    end;
    g2.PrimLine(v0, v1, $ffff0000);
    g2.PrimRect(v0.x - 4, v0.y - 4, 8, 8, $ffff0000);
    if G2Rect(v0.x - 4, v0.y - 4, 8, 8).Contains(g2.MousePos) then
    g2.PrimRect(v0.x - 2, v0.y - 2, 4, 4, $80ffff00);
  end;
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceCustomGraph.OnMouseDown(const Button, x, y: Integer);
  var Ind: Integer;
begin
  case Button of
    G2MB_Left:
    begin
      Ind := PtInPoint(G2Vec2(x, y));
      if Ind > -1 then
      _EditPoint := Ind
      else
      _EditPoint := AddPoint(PointToGraph(G2Vec2(x, y)));
    end;
    G2MB_Right:
    begin
      Ind := PtInPoint(G2Vec2(x, y));
      if Ind > 0 then
      begin
        _EditPoint := -1;
        _Points.Delete(Ind);
      end;
    end;
  end;
end;

procedure TUIWorkspaceCustomGraph.OnMouseUp(const Button, x, y: Integer);
begin
  case Button of
    G2MB_Left:
    begin
      _EditPoint := -1;
    end;
    G2MB_Right:
    begin
      _EditPoint := -1;
    end;
  end;
end;

procedure TUIWorkspaceCustomGraph.Clear;
begin
  _Points.Clear;
end;

function TUIWorkspaceCustomGraph.GetYAt(const x: TG2Float): TG2Float;
  var n, i: Integer;
  var p: TG2Vec2;
  var td, t0: TG2Float;
begin
  n := PointCount - 1;
  for i := 0 to PointCount - 1 do
  if Points[i].x >= x then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = PointCount - 1 then
  Result := Points[PointCount - 1].y
  else
  begin
    td := Points[n + 1].x - Points[n].x;
    t0 := x - Points[n].x;
    Result := G2LerpFloat(Points[n].y, Points[n + 1].y, t0 / td);
  end;
end;

function TUIWorkspaceCustomGraph.AddPoint(const v: TG2Vec2): Integer;
  var i: Integer;
  var v0: TG2Vec2;
begin
  v0 := v;
  if v0.x < _ScaleXMin then Exit(-1);
  if v0.x > _ScaleXMax then v0.x := _ScaleXMax;
  if v0.y < _ScaleYMin then v0.y := _ScaleYMin;
  if v0.y > _ScaleYMax then v0.y := _ScaleYMax;
  i := 0;
  while (v0.x >= _Points[i].x) and (i < _Points.Count) do Inc(i);
  Result := _Points.Insert(i, v0);
end;

function TUIWorkspaceCustomGraph.GetMinWidth: Single;
begin
  Result := inherited GetMinWidth;
end;

function TUIWorkspaceCustomGraph.GetMinHeight: Single;
begin
  Result := inherited GetMinHeight;
end;

procedure TUIWorkspaceCustomGraph.WriteG2ML(const g2ml: TG2MLWriter);
  var i: Integer;
begin
  g2ml.NodeOpen('graph');
  g2ml.NodeValue('x_min', _ScaleXMin);
  g2ml.NodeValue('x_max', _ScaleXMax);
  g2ml.NodeValue('y_min', _ScaleYMin);
  g2ml.NodeValue('y_max', _ScaleYMax);
  for i := 0 to _Points.Count - 1 do
  begin
    g2ml.NodeOpen('point');
    g2ml.NodeValue('x', Points[i].x);
    g2ml.NodeValue('y', Points[i].y);
    g2ml.NodeClose;
  end;
  g2ml.NodeClose;
end;
//TUIWorkspaceCustomGraph END

//TUIWorkspaceCustomColorGraph BEGIN
function TUIWorkspaceCustomColorGraph.GetColor(const Index: Integer): PSectionColor;
begin
  Result := PSectionColor(_Colors[Index]);
end;

function TUIWorkspaceCustomColorGraph.GetColorCount: Integer;
begin
  Result := _Colors.Count;
end;

procedure TUIWorkspaceCustomColorGraph.InsertColor(const c: PSectionColor);
  var i, n: Integer;
begin
  n := 0;
  for i := 0 to _Colors.Count - 1 do
  if PSectionColor(_Colors[i])^.Time <= c^.Time then n := i + 1;
  _Colors.Insert(n, c);
end;

function TUIWorkspaceCustomColorGraph.PtInColor(const v: TG2Vec2): PSectionColor;
  var r, rc: TG2Rect;
  var i: Integer;
  var c: PSectionColor;
begin
  r := Frame.Expand(-1, -1);
  if not r.Contains(v) then Exit(nil);
  rc := r;
  for i := 0 to _Colors.Count - 1 do
  begin
    c := PSectionColor(_Colors[i]);
    rc.l := G2LerpFloat(r.l, r.r - _SliderSize, c^.Time);
    rc.r := rc.l + _SliderSize;
    if rc.Contains(v) then Exit(c);
  end;
  Result := nil;
end;

procedure TUIWorkspaceCustomColorGraph.OnInitialize;
  var c: PSectionColor;
begin
  inherited OnInitialize;
  _SliderSize := 5;
  New(c);
  c^.Time := 0;
  c^.Color := $ffffffff;
  _Colors.Add(c);
  Height := 24;
  Width := 128;
  _Selection := nil;
end;

procedure TUIWorkspaceCustomColorGraph.OnFinalize;
begin
  Clear;
  inherited OnFinalize;
end;

procedure TUIWorkspaceCustomColorGraph.OnAdjust;
begin
  inherited OnAdjust;
end;

procedure TUIWorkspaceCustomColorGraph.OnUpdate;
  var r: TG2Rect;
  var v: TG2Vec2;
begin
  inherited OnUpdate;
  if _Selection <> nil then
  begin
    r := Frame.Expand(-1, -1);
    r.w := r.w - _SliderSize;
    r.x := r.x + _SliderSize * 0.5;
    v := g2.MousePos;
    v.x := v.x + _MdOffset + _SliderSize * 0.5;
    if v.x < r.l then v.x := r.l
    else if v.x > r.r then v.x := r.r;
    _Selection^.Time := (v.x - r.l) / r.w;
    _Colors.Remove(_Selection);
    InsertColor(_Selection);
  end;
end;

procedure TUIWorkspaceCustomColorGraph.OnRender;
  var r, rc: TG2Rect;
  var i, j: Integer;
  var c0, c1: PSectionColor;
begin
  r := Frame;
  g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.1));
  r := r.Expand(-1, -1);
  g2.PrimRect(r.x + 1, r.y + 1, r.w - 2, r.h - 2, App.UI.GetColorPrimary(0.3));
  rc := r;
  c0 := PSectionColor(_Colors[0]);
  c1 := c0;
  rc.l := r.l;
  rc.r := G2LerpFloat(r.l, r.r, c0^.Time);
  g2.PrimRectCol(
    rc.x, rc.y, rc.w, rc.h,
    c0^.Color, c1^.Color,
    c0^.Color, c1^.Color
  );
  for i := 0 to _Colors.Count - 2 do
  begin
      c0 := PSectionColor(_Colors[i]);
      c1 := PSectionColor(_Colors[i + 1]);
      rc.l := G2LerpFloat(r.l, r.r, c0^.Time);
      rc.r := G2LerpFloat(r.l, r.r, c1^.Time);
      g2.PrimRectCol(
        rc.x, rc.y, rc.w, rc.h,
        c0^.Color, c1^.Color,
        c0^.Color, c1^.Color
      );
  end;
  c0 := PSectionColor(_Colors[_Colors.Count - 1]);
  c1 := c0;
  rc.l := G2LerpFloat(r.l, r.r, c0^.Time);
  rc.r := r.r;
  g2.PrimRectCol(
    rc.x, rc.y, rc.w, rc.h,
    c0^.Color, c1^.Color,
    c0^.Color, c1^.Color
  );
  r.h := r.h - 1;
  for i := 0 to _Colors.Count - 1 do
  begin
    c0 := PSectionColor(_Colors[i]);
    rc := r;
    rc.l := G2LerpFloat(r.l, r.r - _SliderSize, c0^.Time);
    rc.w := _SliderSize;
    g2.PrimRectHollow(rc.x, rc.y, rc.w, rc.h, $ffffffff);
    rc := rc.Expand(-1, -1);
    g2.PrimRectHollow(rc.x, rc.y, rc.w, rc.h, $ff000000);
  end;
end;

procedure TUIWorkspaceCustomColorGraph.OnMouseDown(const Button, x, y: Integer);
  var r, rc: TG2Rect;
  var cd: TColorDialog;
  var c: PSectionColor;
begin
  inherited OnMouseDown(Button, x, y);
  case Button of
    G2MB_Left:
    begin
      r := Frame.Expand(-1, -1);
      if r.Contains(x, y) then
      begin
        c := PtInColor(G2Vec2(x, y));
        if c <> nil then
        begin
          _Selection := c;
          rc := r;
          rc.l := G2LerpFloat(r.l, r.r - _SliderSize, c^.Time);
          rc.w := _SliderSize;
          _MdOffset := rc.l - x;
          if (_Selection = _LastSelection)
          and (G2Time - _LastSelectionTime < 300) then
          begin
            _Selection := nil;
            _LastSelectionTime := G2Time - 300;
            cd := TColorDialog.Create(nil);
            cd.Color := rgb(c^.Color.r, c^.Color.g, c^.Color.b);
            g2.Pause := True;
            try
              if cd.Execute then
              begin
                c^.Color.r := cd.Color and $ff;
                c^.Color.g := (cd.Color shr 8) and $ff;
                c^.Color.b := (cd.Color shr 16) and $ff;
                c^.Color.a := $ff;
              end;
            finally
              g2.Pause := False;
              cd.Free;
            end;
          end
          else
          begin
            _LastSelection := _Selection;
            _LastSelectionTime := G2Time;
          end;
        end
        else
        begin
          cd := TColorDialog.Create(nil);
          cd.Color := $ffffff;
          g2.Pause := True;
          try
            if cd.Execute then
            begin
              New(c);
              c^.Color.r := cd.Color and $ff;
              c^.Color.g := (cd.Color shr 8) and $ff;
              c^.Color.b := (cd.Color shr 16) and $ff;
              c^.Color.a := $ff;
              c^.Time := G2Min(G2Max((x - r.l) / (r.w - _SliderSize), 0), 1);
              InsertColor(c);
            end;
          finally
            g2.Pause := False;
            cd.Free;
          end;
        end;
      end;
    end;
    G2MB_Right:
    begin
      c := PtInColor(G2Vec2(x, y));
      if (c <> nil) and (_Colors.Count > 1) then
      begin
        _Selection := nil;
        _Colors.Remove(c);
        Dispose(c);
      end;
    end;
  end;
end;

procedure TUIWorkspaceCustomColorGraph.OnMouseUp(const Button, x, y: Integer);
begin
  _Selection := nil;
end;

procedure TUIWorkspaceCustomColorGraph.Clear;
  var i: Integer;
begin
  for i := 0 to _Colors.Count - 1 do
  Dispose(PSectionColor(_Colors[i]));
  _Colors.Clear;
end;

procedure TUIWorkspaceCustomColorGraph.AddColor(const Color: TG2Color; const Time: TG2Float);
  var sc: PSectionColor;
begin
  New(sc);
  sc^.Color := Color;
  sc^.Time := Time;
  InsertColor(sc);
end;

function TUIWorkspaceCustomColorGraph.GetMinWidth: Single;
begin
  Result:=inherited GetMinWidth;
end;

function TUIWorkspaceCustomColorGraph.GetMinHeight: Single;
begin
  Result:=inherited GetMinHeight;
end;
//TUIWorkspaceCustomColorGraph END

//TUIWorkspaceCustom BEGIN
procedure TUIWorkspaceCustom.SetAlignment(const Value: TUIWorkspaceCustomAlignmentSet);
begin
  if Value = _Alignment then Exit;
  _Alignment := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustom.SetScrollable(const Value: Boolean);
begin
  if _Scrollable = Value then Exit;
  _Scrollable := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustom.SetSpacingBottom(const Value: Single);
begin
  _SpacingBottom := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustom.SetSpacingLeft(const Value: Single);
begin
  _SpacingLeft := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustom.SetSpacingRight(const Value: Single);
begin
  _SpacingRight := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustom.SetSpacingTop(const Value: Single);
begin
  _SpacingTop := Value;
  OnAdjust;
end;

procedure TUIWorkspaceCustom.OnInitialize;
begin
  _ScrollV.OnChange := @OnSlide;
  _Scrollable := False;
  _SpacingTop := 0;
  _SpacingLeft := 0;
  _SpacingRight := 0;
  _SpacingBottom := 0;
end;

procedure TUIWorkspaceCustom.OnAdjust;
  var i, vec: Integer;
  var ContentHeight, hf, hv, hpv: Single;
  var c: TUIWorkspaceCustomObject;
  var y: Single;
  var r: TG2Rect;
begin
  vec := 0;
  hf := 0;
  hv := 0;
  ContentHeight := _SpacingTop;
  for i := 0 to ChildCount - 1 do
  if Children[i] is TUIWorkspaceCustomObject then
  begin
    c := TUIWorkspaceCustomObject(Children[i]);
    if c.SizingV = csFixed then
    hf += c.GetMinHeight
    else
    begin
      hv += c.GetMinHeight;
      Inc(vec);
    end;
    hf += c.PaddingTop + c.PaddingBottom;
    ContentHeight := ContentHeight + c.GetMinHeight;
  end;
  y := Frame.t + _SpacingTop;
  if _Scrollable and (ContentHeight > Frame.h) then
  begin
    if not _ScrollV.Enabled then
    _ScrollV.PosRelative := 0;
    _ScrollV.Enabled := True;
    r := Frame; r.l := r.r - 18;
    _ScrollV.Frame := r;
    _ScrollV.ContentSize := ContentHeight;
    _ScrollV.ParentSize := Frame.h;
    y := y - _ScrollV.PosAbsolute;
  end
  else
  _ScrollV.Enabled := False;
  hpv := Frame.h - _SpacingTop - _SpacingBottom - hf;
  for i := 0 to ChildCount - 1 do
  if Children[i] is TUIWorkspaceCustomObject then
  begin
    c := TUIWorkspaceCustomObject(Children[i]);
    r.l := Frame.l + _SpacingLeft + c.PaddingLeft;
    r.t := y + c.PaddingTop;
    if c.SizingH = csStretch then
    r.r := Frame.r - _SpacingRight - c.PaddingRight
    else
    r.w := c.GetMinWidth;
    if _ScrollV.Enabled then
    r.r := r.r - _ScrollV.Frame.w;
    if c.SizingV = csStretch then
    begin
      r.h := G2Max(hpv / vec, c.GetMinHeight);
      hpv := hpv - r.h;
      Dec(vec);
    end
    else
    r.h := c.GetMinHeight;
    y += r.h + c.PaddingTop + c.PaddingBottom;
    c.Frame := r;
  end;
end;

procedure TUIWorkspaceCustom.OnRender;
begin
  if _ScrollV.Enabled then
  begin
    _ScrollV.Render;
  end;
end;

procedure TUIWorkspaceCustom.OnUpdate;
begin
  if _ScrollV.Enabled then
  _ScrollV.Update;
end;

procedure TUIWorkspaceCustom.OnMouseDown(const Button, x, y: Integer);
begin
  if _ScrollV.Enabled then
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceCustom.OnMouseUp(const Button, x, y: Integer);
begin
  if _ScrollV.Enabled then
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceCustom.OnScroll(const y: Integer);
begin
  if _ScrollV.Enabled then _ScrollV.Scroll(y)
  else if Parent <> nil then Parent.OnScroll(y);
end;

procedure TUIWorkspaceCustom.OnSlide;
begin
  OnAdjust;
end;

class function TUIWorkspaceCustom.GetWorkspaceName: AnsiString;
begin
  Result := 'Custom';
end;

function TUIWorkspaceCustom.GetMinWidth: Single;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to ChildCount - 1 do
  if Children[i] is TUIWorkspaceCustomObject then
  Result := G2Max(
    Result,
    Children[i].GetMinWidth +
    TUIWorkspaceCustomObject(Children[i]).PaddingLeft +
    TUIWorkspaceCustomObject(Children[i]).PaddingRight
  )
  else
  Result := G2Max(Result, Children[i].GetMinWidth);
  Result := G2Max(Result, 4);
end;

function TUIWorkspaceCustom.GetMinHeight: Single;
  var i: Integer;
begin
  if _Scrollable then
  Result := 4
  else
  begin
    Result := _SpacingTop + _SpacingBottom;
    for i := 0 to ChildCount - 1 do
    if Children[i] is TUIWorkspaceCustomObject then
    Result := (
      Result + Children[i].GetMinHeight +
      TUIWorkspaceCustomObject(Children[i]).PaddingTop +
      TUIWorkspaceCustomObject(Children[i]).PaddingBottom
    )
    else
    Result := Result + Children[i].GetMinHeight;
  end;
end;

function TUIWorkspaceCustom.SplitterV(const Ratio: Single = 0.5): TUIWorkspaceFixedSplitterV;
begin
  Result := TUIWorkspaceFixedSplitterV.Create;
  Result.SplitPos := Ratio;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.SplitterH(const Ratio: Single = 0.5): TUIWorkspaceFixedSplitterH;
begin
  Result := TUIWorkspaceFixedSplitterH.Create;
  Result.SplitPos := Ratio;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.SplitterM(const Count: Integer): TUIWorkspaceFixedSplitterMulti;
begin
  Result := TUIWorkspaceFixedSplitterMulti.Create;
  Result.SubsetCount := Count;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.Panel: TUIWorkspaceCustomPanel;
begin
  Result := TUIWorkspaceCustomPanel.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.Text(const Caption: AnsiString): TUIWorkspaceCustomLabel;
begin
  Result := TUIWorkspaceCustomLabel.Create;
  Result.Parent := Self;
  Result.Caption := Caption;
end;

function TUIWorkspaceCustom.Button(const Caption: AnsiString = 'Button'): TUIWorkspaceCustomButton;
begin
  Result := TUIWorkspaceCustomButton.Create;
  Result.Parent := Self;
  Result.Caption := Caption;
end;

function TUIWorkspaceCustom.Edit: TUIWorkspaceCustomEdit;
begin
  Result := TUIWorkspaceCustomEdit.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.NumberInt: TUIWorkspaceCustomNumberInt;
begin
  Result := TUIWorkspaceCustomNumberInt.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.NumberFloat: TUIWorkspaceCustomNumberFloat;
begin
  Result := TUIWorkspaceCustomNumberFloat.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.FileDialog: TUIWorkspaceCustomFile;
begin
  Result := TUIWorkspaceCustomFile.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.ColorDialog: TUIWorkspaceCustomColor;
begin
  Result := TUIWorkspaceCustomColor.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.ComboBox: TUIWorkspaceCustomComboBox;
begin
  Result := TUIWorkspaceCustomComboBox.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.CheckBox(const Caption: AnsiString = 'CheckBox'): TUIWorkspaceCustomCheckbox;
begin
  Result := TUIWorkspaceCustomCheckbox.Create;
  Result.Caption := Caption;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.Radio(const Caption: AnsiString = 'Radio'): TUIWorkspaceCustomRadio;
begin
  Result := TUIWorkspaceCustomRadio.Create;
  Result.Caption := Caption;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.Pages: TUIWorkspaceCustomPages;
begin
  Result := TUIWorkspaceCustomPages.Create;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.Group(const Caption: AnsiString): TUIWorkspaceCustomGroup;
begin
  Result := TUIWorkspaceCustomGroup.Create;
  Result.Caption := Caption;
  Result.Parent := Self;
end;

function TUIWorkspaceCustom.Slider: TUIWorkspaceCustomSlider;
begin
  Result := TUIWorkspaceCustomSlider.Create;
  Result.Parent := Self;
end;

procedure TUIWorkspaceCustom.SetSpacing(const Spacing: Single);
begin
  SpacingLeft := Spacing;
  SpacingRight := Spacing;
  SpacingTop := Spacing;
  SpacingBottom := Spacing;
end;
//TUIWorkspaceCustom END

//TUIWorkspaceCustomTest BEIGN
procedure TUIWorkspaceCustomTest.OnSetPage0;
begin
  _Pages.PageIndex := 0;
end;

procedure TUIWorkspaceCustomTest.OnSetPage1;
begin
  _Pages.PageIndex := 1;
end;

procedure TUIWorkspaceCustomTest.OnInitialize;
  var sh: TUIWorkspaceFixedSplitterH;
  var sv: TUIWorkspaceFixedSplitterV;
  var p: TUIWorkspaceCustomPanel;
  var g: TUIWorkspaceCustomGroup;
begin
  inherited OnInitialize;
  Scrollable := True;
  p := Panel;
  p.Client.SpacingTop := 2;
  p.Client.SpacingLeft := 2;
  p.Client.SpacingRight := 2;
  sv := p.Client.SplitterV;
  sh := sv.Upper.SplitterH;
  sh.Left.SpacingTop := 2;
  sh.Left.SpacingLeft := 5;
  sh.Left.SpacingRight := 5;
  sh.Left.Button;
  sh.Right.Edit;
  sh.Right.CheckBox.Checked := True;
  sh.Right.Radio.Checked := True;
  sh.Right.Radio;
  g := sh.Right.Group;
  g.Client.SpacingTop := 10;
  g.Client.SpacingLeft := 10;
  g.Client.SpacingRight := 10;
  g.Client.SpacingBottom := 10;
  g.Client.Button;
  g.Client.CheckBox;
  sh := sv.Lower.SplitterH(0.3);
  sh.Left.Button('Page0').OnClick := @OnSetPage0;
  sh.Left.Button('Page1').OnClick := @OnSetPage1;
  _Pages := sh.Right.Pages;
  _Pages.AddPage;
  _Pages.AddPage;
  _Pages.Pages[0].Button('Button0');
  _Pages.Pages[1].Button('Button1');
  _Pages.Pages[1].Edit;
end;

function TUIWorkspaceCustomTest.GetMinWidth: Single;
begin
  Result := G2Max(inherited GetMinWidth, 128);
end;

function TUIWorkspaceCustomTest.GetMinHeight: Single;
begin
  Result := G2Max(inherited GetMinHeight, 64);
end;

class function TUIWorkspaceCustomTest.GetWorkspaceName: AnsiString;
begin
  Result := 'Custom Test';
end;
//TUIWorkspaceCustomTest END

//TUIWorkspaceProject BEGIN
procedure TUIWorkspaceProject.OnBtnNew;
begin
  App.Project.New;
end;

procedure TUIWorkspaceProject.OnBtnLoad;
begin
  App.Project.Load;
end;

procedure TUIWorkspaceProject.OnBtnClose;
begin
  App.Project.Close;
end;

procedure TUIWorkspaceProject.OnBtnBuild;
begin
  App.Project.Build;
end;

procedure TUIWorkspaceProject.OnBtnBuildHTML5;
begin
  App.Project.BuildHTML5;
end;

procedure TUIWorkspaceProject.OnBtnLpr;
begin
  App.Project.CreateLPR;
end;

procedure TUIWorkspaceProject.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var sh: TUIWorkspaceFixedSplitterH;
  var sv: TUIWorkspaceFixedSplitterV;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited OnInitialize;
  Scrollable := True;
  p := Panel;
  p.Client.SetSpacing(8);
  sm := p.Client.SplitterM(3);
  _BtnNew := sm.Subset[0].Button('New');
  _BtnLoad := sm.Subset[1].Button('Open');
  _BtnClose := sm.Subset[2].Button('Close');
  _Options := p.Client.Pages;
  _OptEmpty := _Options.AddPage;
  _OptBuild := _Options.AddPage;
  _LabelProjectPath := _OptBuild.Text('Project Path:');
  sm := _OptBuild.SplitterM(3);
  _BtnBuild := sm.Subset[0].Button('Build');
  _BtnBuildHTML5 := sm.Subset[1].Button('Build HTML5');
  _BtnLpr := sm.Subset[2].Button('Create LPR');
  _BtnNew.OnClick := @OnBtnNew;
  _BtnLoad.OnClick := @OnBtnLoad;
  _BtnClose.OnClick := @OnBtnClose;
  _BtnBuild.OnClick := @OnBtnBuild;
  _BtnBuildHTML5.OnClick := @OnBtnBuildHTML5;
  _BtnLpr.OnClick := @OnBtnLpr;
  _LabelProjectPath.Color := $ffffffff;
  _LabelProjectPath.Align := [caLeft, caMiddle];
end;

procedure TUIWorkspaceProject.OnUpdate;
begin
  inherited OnUpdate;
  _BtnClose.Enabled := App.Project.Open;
  if App.Project.Open then
  begin
    _Options.PageIndex := 1;
    _LabelProjectPath.Caption := 'Project Path: ' + App.Project.GetProjectPath;
  end
  else
  begin
    _Options.PageIndex := 0;
    _LabelProjectPath.Caption := '';
  end;
end;

function TUIWorkspaceProject.GetMinWidth: Single;
begin
  Result := G2Max(inherited GetMinWidth, 256);
end;

function TUIWorkspaceProject.GetMinHeight: Single;
begin
  Result := G2Max(inherited GetMinHeight, 64);
end;

class function TUIWorkspaceProject.GetWorkspaceName: AnsiString;
begin
  Result := 'Project';
end;
//TUIWorkspaceProject END

//TUIWorkspaceSettings BEGIN
procedure TUIWorkspaceSettings.OnBtnSaveDefaultLayout;
begin
  App.UI.LayoutSave(g2.AppPath + 'DefaultLayout.g2ml');
end;

procedure TUIWorkspaceSettings.OnBtnLoadDefaultLayout;
begin
  if FileExists(g2.AppPath + 'DefaultLayout.g2ml') then
  App.UI.MsgLoadLayout(g2.AppPath + 'DefaultLayout.g2ml');
end;

procedure TUIWorkspaceSettings.OnBtnSaveLayout;
  var sd: TSaveDialog;
begin
  sd := TSaveDialog.Create(nil);
  g2.Pause := True;
  if sd.Execute then
  App.UI.LayoutSave(sd.FileName);
  g2.Pause := False;
  sd.Free;
end;

procedure TUIWorkspaceSettings.OnBtnLoadLayout;
  var od: TOpenDialog;
begin
  od := TOpenDialog.Create(nil);
  g2.Pause := True;
  if od.Execute then
  App.UI.MsgLoadLayout(od.FileName);
  g2.Pause := False;
  od.Free;
end;

procedure TUIWorkspaceSettings.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var g: TUIWorkspaceCustomGroup;
  var sh: TUIWorkspaceFixedSplitterH;
begin
  inherited OnInitialize;
  p := Panel;
  p.Client.SetSpacing(8);
  g := p.Client.Group('Layout');
  g.Client.SetSpacing(8);
  sh := g.Client.SplitterH;
  sh.Left.Button('Save Default Layout').OnClick := @OnBtnSaveDefaultLayout;
  sh.Right.Button('Save Layout').OnClick := @OnBtnSaveLayout;
  sh := g.Client.SplitterH;
  sh.Left.Button('Load Default Layout').OnClick := @OnBtnLoadDefaultLayout;
  sh.Right.Button('Load Layout').OnClick := @OnBtnLoadLayout;
end;

procedure TUIWorkspaceSettings.OnUpdate;
begin

end;

function TUIWorkspaceSettings.GetMinWidth: Single;
begin
  Result := G2Max(inherited GetMinWidth, 256);
end;

function TUIWorkspaceSettings.GetMinHeight: Single;
begin
  Result := G2Max(inherited GetMinHeight, 4);
end;

class function TUIWorkspaceSettings.GetWorkspaceName: AnsiString;
begin
  Result := 'Settings';
end;
//TUIWorkspaceSettings END

//TUIWorkspaceProperties BEGIN
procedure TUIWorkspaceProperties.OnEditFinish;
begin
  if _EditProperty = nil then Exit;
  case _EditProperty.PropertyType of
    TPropertySet.TPropertyType.pt_int:
    begin
      if StrToIntDef(_EditText, 0) = StrToIntDef(_EditText, 1) then
      begin
        TPropertySet.TPropertyInt(_EditProperty).ValuePtr^ := StrToIntDef(_EditText, 0);
        if Assigned(_EditProperty.OnChange) then _EditProperty.OnChange(_EditProperty);
      end;
    end;
    TPropertySet.TPropertyType.pt_float:
    begin
      if Abs(StrToFloatDef(_EditText, 1) - StrToFloatDef(_EditText, 0)) < 0.1 then
      begin
        TPropertySet.TPropertyFloat(_EditProperty).ValuePtr^ := StrToFloatDef(_EditText, 0);
        if Assigned(_EditProperty.OnChange) then _EditProperty.OnChange(_EditProperty);
      end;
    end;
    TPropertySet.TPropertyType.pt_string:
    begin
      TPropertySet.TPropertyString(_EditProperty).ValuePtr^ := _EditText;
      if Assigned(_EditProperty.OnChange) then _EditProperty.OnChange(_EditProperty);
    end;
  end;
  _EditProperty := nil;
end;

procedure TUIWorkspaceProperties.OnPathSelect(const Path: String);
begin
  TPropertySet.TPropertyPath(_EditProperty).ValuePtr^ := Path;
  if Assigned(TPropertySet.TPropertyPath(_EditProperty).OnChange) then
  TPropertySet.TPropertyPath(_EditProperty).OnChange(_EditProperty);
end;

procedure TUIWorkspaceProperties.OnEnumChage(const Index: Integer);
  var Prop: TPropertySet.TPropertyEnum;
begin
  Prop := TPropertySet.TPropertyEnum(_EditProperty);
  if Prop.Selection = Index then Exit;
  Prop.Selection := Index;
  PByte(Prop.ValuePtr)^ := Prop.Values[Prop.Selection].Value;
  if Assigned(Prop.OnChange) then Prop.OnChange(Prop);
end;

procedure TUIWorkspaceProperties.RenderPath(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyPath
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: String;
  var c: TG2Color;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  if (App.UI.Overlay = nil) and G2Rect(spx, r.y, spw, r.h).Contains(g2.MousePos) then
  c := App.UI.GetColorPrimary(1)
  else
  c := App.UI.GetColorPrimary(0.95);
  g2.PrimRect(spx, r.y, spw, r.h, c);
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  tx := spx + 4;
  ty := r.y + (r.h - h) * 0.5;
  Text := ExtractFileNameOnly(Prop.ValuePtr^);
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderButton(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyButton
);
  var br: TG2Rect;
  var h: Integer;
  var c0, c1: TG2Color;
begin
  br := r;
  g2.PrimRect(br.x, br.y, br.w, br.h, App.UI.GetColorPrimary(0.9));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(r);
  c0 := App.UI.GetColorPrimary(0.6);
  if (App.UI.Overlay = nil) and br.Contains(g2.MousePos) then
  begin
    if g2.MouseDown[G2MB_Left] and Frame.Contains(g2.MouseDownPos[G2MB_Left]) then
    c1 := App.UI.GetColorPrimary(0.7)
    else
    c1 := App.UI.GetColorPrimary(0.9);
  end
  else
  c1 := App.UI.GetColorPrimary(0.8);
  g2.PrimRect(br.x, br.y, br.w, br.h, c0);
  g2.PrimRect(br.x + 2, br.y + 2, br.w - 4, br.h - 4, c1);
  App.UI.Font1.Print(
    br.x + (br.w - App.UI.Font1.TextWidth(Prop.Name)) * 0.5, br.y + (br.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderGroup(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TProperty
);
  var h: Integer;
begin
  g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.9));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(r);
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderBool(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyBool
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: String;
  var c: TG2Color;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  if (App.UI.Overlay = nil) and G2Rect(spx, r.y, spw, r.h).Contains(g2.MousePos) then
  c := App.UI.GetColorPrimary(1)
  else
  c := App.UI.GetColorPrimary(0.95);
  g2.PrimRect(spx, r.y, spw, r.h, c);
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if Prop.ValuePtr^ then Text := 'Yes' else Text := 'No';
  tx := spx + (spw - App.UI.Font1.TextWidth(Text)) * 0.5;
  ty := r.y + (r.h - h) * 0.5;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderInt(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyInt
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: AnsiString;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(1));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if _EditProperty = Prop then
  begin
    tx := _TextPos.x;
    ty := _TextPos.y;
    Text := _EditText;
  end
  else
  begin
    tx := spx + 4;
    ty := r.y + (r.h - h) * 0.5;
    Text := IntToStr(Prop.ValuePtr^);
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderFloat(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyFloat
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: AnsiString;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(1));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if _EditProperty = Prop then
  begin
    tx := _TextPos.x;
    ty := _TextPos.y;
    Text := _EditText;
  end
  else
  begin
    tx := spx + 4;
    ty := r.y + (r.h - h) * 0.5;
    Text := FormatFloat(FloatPrintFormat, Prop.ValuePtr^);
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderString(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyString
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: AnsiString;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  if Prop.Editable then
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(1))
  else
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(0.9));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if _EditProperty = Prop then
  begin
    tx := _TextPos.x;
    ty := _TextPos.y;
    Text := _EditText;
  end
  else
  begin
    tx := spx + 4;
    ty := r.y + (r.h - h) * 0.5;
    Text := Prop.ValuePtr^;
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderVec2(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyVec2
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: AnsiString;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(1));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if _EditProperty = Prop then
  begin
    tx := _TextPos.x;
    ty := _TextPos.y;
    Text := _EditText;
  end
  else
  begin
    tx := spx + 4;
    ty := r.y + (r.h - h) * 0.5;
    Text := '(' + FormatFloat(FloatPrintFormat, Prop.ValuePtr^.x) + ', ' + FormatFloat(FloatPrintFormat, Prop.ValuePtr^.y) + ')';
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderVec3(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyVec3
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: AnsiString;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(1));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if _EditProperty = Prop then
  begin
    tx := _TextPos.x;
    ty := _TextPos.y;
    Text := _EditText;
  end
  else
  begin
    tx := spx + 4;
    ty := r.y + (r.h - h) * 0.5;
    Text := '(' + FormatFloat(FloatPrintFormat, Prop.ValuePtr^.x) + ', ' + FormatFloat(FloatPrintFormat, Prop.ValuePtr^.y) + ', ' + FormatFloat(FloatPrintFormat, Prop.ValuePtr^.z) + ')';
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderEnum(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyEnum
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: String;
  var c: TG2Color;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  if (App.UI.Overlay = nil) and G2Rect(spx, r.y, spw, r.h).Contains(g2.MousePos) then
  c := App.UI.GetColorPrimary(1)
  else
  c := App.UI.GetColorPrimary(0.95);
  g2.PrimRect(spx, r.y, spw, r.h, c);
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if Prop.Selection > -1 then
  Text := Prop.Values[Prop.Selection].Name
  else
  Text := '';
  tx := spx + (spw - App.UI.Font1.TextWidth(Text)) * 0.5;
  ty := r.y + (r.h - h) * 0.5;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderBlendMode(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyBlendMode
);
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: AnsiString;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  g2.PrimRect(spx, r.y, spw, r.h, App.UI.GetColorPrimary(1));
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  if _EditProperty = Prop then
  begin
    tx := _TextPos.x;
    ty := _TextPos.y;
    Text := _EditText;
  end
  else
  begin
    tx := spx + 4;
    ty := r.y + (r.h - h) * 0.5;
    if Prop.ValuePtr^ = bmInvalid then Text := 'Invalid'
    else if Prop.ValuePtr^ = bmDisable then Text := 'Disable'
    else if Prop.ValuePtr^ = bmNormal then Text := 'Normal'
    else if Prop.ValuePtr^ = bmAdd then Text := 'Add'
    else if Prop.ValuePtr^ = bmSub then Text := 'Subtract'
    else if Prop.ValuePtr^ = bmMul then Text := 'Multiply'
    else Text := 'Custom';
  end;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceProperties.RenderComponent(
  const r: TG2Rect;
  const Offset: Integer;
  const Prop: TPropertySet.TPropertyComponent
);
  var r1: TG2Rect;
  var h: Integer;
  var spx, spw: TG2Float;
  var tx, ty: TG2Float;
  var Text: String;
  var c0, c1: TG2Color;
begin
  spx := r.x + r.w * _Splitter + 1;
  spw := r.w * (1 - _Splitter) - 1;
  r1 := r; r1.l := spx;
  g2.PrimRect(r.x, r.y, r.w * _Splitter, r.h, App.UI.GetColorPrimary(0.9));
  c0 := App.UI.GetColorPrimary(0.6);
  if (App.UI.Overlay = nil) and r1.Contains(g2.MousePos) then
  begin
    if g2.MouseDown[G2MB_Left] and r1.Contains(g2.MouseDownPos[G2MB_Left]) then
    c1 := App.UI.GetColorPrimary(0.7)
    else
    c1 := App.UI.GetColorPrimary(0.9);
  end
  else
  c1 := App.UI.GetColorPrimary(0.8);
  g2.PrimRect(r1.x, r1.y, r1.w, r1.h, c0);
  g2.PrimRect(r1.x + 2, r1.y + 2, r1.w - 4, r1.h - 4, c1);
  h := App.UI.Font1.TextHeight('A');
  App.UI.PushClipRect(G2Rect(r.x, r.y, spx - r.x, r.h));
  App.UI.Font1.Print(
    r.x + 4 + Offset, r.y + (r.h - h) * 0.5, 1, 1,
    $ff000000, Prop.Name, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
  App.UI.PushClipRect(G2Rect(spx, r.y, spw, r.h));
  Text := 'Remove';
  tx := spx + (spw - App.UI.Font1.TextWidth(Text)) * 0.5;
  ty := r.y + (r.h - h) * 0.5;
  App.UI.Font1.Print(
    tx, ty, 1, 1,
    $ff000000, Text, bmNormal, tfPoint
  );
  App.UI.PopClipRect;
end;

function TUIWorkspaceProperties.PtInProperty(const x, y: Integer; var InExpand, InEdit: Boolean; var PropertyRect: TG2Rect): TPropertySet.TProperty;
  var r: TG2Rect;
  var px, py, pw, ph: Integer;
  function CheckProperty(const Prop: TPropertySet.TProperty; const Offset: Integer = 16): TPropertySet.TProperty;
    var pr: TG2Rect;
    var i: Integer;
  begin
    pr := G2Rect(px, py, pw, ph);
    if pr.Contains(x, y) then
    begin
      Result := Prop;
      PropertyRect := pr;
      if x < px + Offset then InExpand := True else InExpand := False;
      if x > px + pw * _Splitter then InEdit := True else InEdit := False;
      Exit;
    end
    else
    begin
      py := py + ph + 1;
      if Prop.Open then
      for i := 0 to Prop.Children^.Count - 1 do
      begin
        Result := CheckProperty(Prop.Children^[i], Offset + 16);
        if Result <> nil then Exit;
      end;
    end;
    Result := nil;
  end;
  var i: Integer;
begin
  if (_PropertySetPtr = nil)
  or (_PropertySetPtr^ = nil) then
  Exit(nil);
  r := Frame;
  r.r := r.r - _ScrollV.Frame.w;
  if not r.Contains(x, y) then Exit(nil);
  pw := Round(r.w);
  ph := _ItemsHeight;
  px := Round(r.x);
  py := Round(r.y + 1 - _ScrollV.PosAbsolute);
  for i := 0 to _PropertySetPtr^.Root.Children^.Count - 1 do
  begin
    Result := CheckProperty(_PropertySetPtr^.Root.Children^[i]);
    if Result <> nil then Exit;
  end;
  Result := nil;
end;

function TUIWorkspaceProperties.GetContentSize: TG2Float;
  procedure CheckSize(const Prop: TPropertySet.TProperty);
    var i: Integer;
  begin
    Result += _ItemsHeight + 1;
    if Prop.Open and (Prop.Children^.Count > 0) then
    for i := 0 to Prop.Children^.Count - 1 do
    CheckSize(Prop.Children^[i]);
  end;
  var i: Integer;
begin
  Result := 1;
  if (_PropertySetPtr = nil)
  or (_PropertySetPtr^ = nil) then Exit;
  for i := 0 to _PropertySetPtr^.Root.Children^.Count - 1 do
  CheckSize(_PropertySetPtr^.Root.Children^[i]);
end;

procedure TUIWorkspaceProperties.OnInitialize;
begin
  _EditProperty := nil;
  _AdjustSplitterPropertySet := [
    TPropertySet.TPropertyType.pt_bool,
    TPropertySet.TPropertyType.pt_int,
    TPropertySet.TPropertyType.pt_float,
    TPropertySet.TPropertyType.pt_string,
    TPropertySet.TPropertyType.pt_vec2,
    TPropertySet.TPropertyType.pt_vec3,
    TPropertySet.TPropertyType.pt_blend_mode,
    TPropertySet.TPropertyType.pt_path
  ];
  _AdjustingSplitter := false;
  _Splitter := 0.5;
  _PropertySetPtr := nil;
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _ItemsHeight := 24;
  _OverlayDropList := TOverlayDropList.Create;
end;

procedure TUIWorkspaceProperties.OnFinalize;
begin
  _OverlayDropList.Free;
end;

procedure TUIWorkspaceProperties.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame; r.l := r.r - 18;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.ParentSize := r.h;
end;

procedure TUIWorkspaceProperties.OnUpdate;
  var mc: TPoint;
  var r: TG2Rect;
  var Prop: TPropertySet.TProperty;
  var InExpand, InEdit: Boolean;
  var pr: TG2Rect;
begin
  mc := g2.MousePos;
  if _AdjustingSplitter then
  begin
    r := Frame;
    r.r := r.r - _ScrollV.Frame.w;
    _Splitter := G2Clamp((mc.x - r.l) / r.w, 0, 1);
    if _Splitter * r.w < 64 then _Splitter := 64 / r.w
    else if (1 - _Splitter) * r.w < 64 then _Splitter := (r.w - 64) / r.w;
    App.UI.Cursor := g2.Window.CursorSizeWE;
  end
  else
  begin
    r := Frame;
    r.r := r.r - _ScrollV.Frame.w;
    r.l := r.l + r.w * _Splitter - 3;
    r.r := r.l + 6;
    if (App.UI.Overlay = nil) and r.Contains(mc.x, mc.y) then
    begin
      Prop := PtInProperty(mc.x, mc.y, InExpand, InEdit, pr);
      if Prop <> nil then
      begin
        if Prop.PropertyType in _AdjustSplitterPropertySet then
        App.UI.Cursor := g2.Window.CursorSizeWE;
      end;
    end;
  end;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.Update;
end;

procedure TUIWorkspaceProperties.OnRender;
  var r: TG2Rect;
  var x, y, w, h: Integer;
  procedure RenderProperty(const Prop: TPropertySet.TProperty; const Offset: Integer = 16);
    var pr: TG2Rect;
    var i: Integer;
    var Str: String;
  begin
    pr := G2Rect(x, y, w, h);
    case Prop.PropertyType of
      TPropertySet.TPropertyType.pt_none: RenderGroup(pr, Offset, Prop);
      TPropertySet.TPropertyType.pt_path: RenderPath(pr, Offset, TPropertySet.TPropertyPath(Prop));
      TPropertySet.TPropertyType.pt_button: RenderButton(pr, Offset, TPropertySet.TPropertyButton(Prop));
      TPropertySet.TPropertyType.pt_bool: RenderBool(pr, Offset, TPropertySet.TPropertyBool(Prop));
      TPropertySet.TPropertyType.pt_int: RenderInt(pr, Offset, TPropertySet.TPropertyInt(Prop));
      TPropertySet.TPropertyType.pt_float: RenderFloat(pr, Offset, TPropertySet.TPropertyFloat(Prop));
      TPropertySet.TPropertyType.pt_string: RenderString(pr, Offset, TPropertySet.TPropertyString(Prop));
      TPropertySet.TPropertyType.pt_vec2: RenderVec2(pr, Offset, TPropertySet.TPropertyVec2(Prop));
      TPropertySet.TPropertyType.pt_vec3: RenderVec3(pr, Offset, TPropertySet.TPropertyVec3(Prop));
      TPropertySet.TPropertyType.pt_enum: RenderEnum(pr, Offset, TPropertySet.TPropertyEnum(Prop));
      TPropertySet.TPropertyType.pt_blend_mode: RenderBlendMode(pr, Offset, TPropertySet.TPropertyBlendMode(Prop));
      TPropertySet.TPropertyType.pt_component: RenderComponent(pr, Offset, TPropertySet.TPropertyComponent(Prop));
    end;
    if Prop.Children^.Count > 0 then
    begin
      if Prop.Open then Str := '-' else Str := '+';
      App.UI.Font1.Print(
        x + Offset - 16 + (16 - App.UI.Font1.TextWidth(Str)),
        y + (h - App.UI.Font1.TextHeight('A')) * 0.5,
        1, 1, $ff000000, Str, bmNormal, tfPoint
      );
    end;
    y := y + h + 1;
    if Prop.Open then
    for i := 0 to Prop.Children^.Count - 1 do
    RenderProperty(Prop.Children^[i], Offset + 16);
  end;
  var i: Integer;
  var Prop: TPropertySet.TProperty;
begin
  r := Frame;
  r.r := r.r - _ScrollV.Frame.w;
  g2.PrimRect(
    r.x, r.y, r.w, r.h,
    App.UI.GetColorPrimary(0.4)
  );
  if (_PropertySetPtr <> nil)
  and (_PropertySetPtr^ <> nil) then
  begin
    App.UI.PushClipRect(r);
    w := Round(r.w);
    h := _ItemsHeight;
    x := Round(r.x);
    y := Round(r.y + 1 - _ScrollV.PosAbsolute);
    for i := 0 to _PropertySetPtr^.Root.Children^.Count - 1 do
    RenderProperty(_PropertySetPtr^.Root.Children^[i]);
    App.UI.PopClipRect;
  end;
  _ScrollV.Render;
end;

procedure TUIWorkspaceProperties.OnMouseDown(const Button, x, y: Integer);
  var Prop: TPropertySet.TProperty;
  var PropInt: TPropertySet.TPropertyInt absolute Prop;
  var PropFloat: TPropertySet.TPropertyFloat absolute Prop;
  var PropString: TPropertySet.TPropertyString absolute Prop;
  var InExpand, InEdit: Boolean;
  var r, pr: TG2Rect;
  procedure StartEditing;
    var AllowEmpty: Boolean;
  begin
    _TextPos.x := pr.l + 4;
    _TextPos.y := pr.t + (pr.h - App.UI.Font1.TextHeight('A')) * 0.5;
    if Prop.PropertyType = TPropertySet.TPropertyType.pt_string then
    AllowEmpty := PropString.AllowEmpty
    else
    AllowEmpty := False;
    App.UI.TextEdit.Enable(@_EditText, @_TextPos, App.UI.Font1, nil, _EditText, nil, nil, AllowEmpty);
    App.UI.TextEdit.ImplSingleLine.AutoAdjustTextPos := True;
    App.UI.TextEdit.OnFinishProc := @OnEditFinish;
    App.UI.TextEdit.AllowSymbols := True;
    App.UI.TextEdit.MaxLength := 0;
    App.UI.TextEdit.Frame := pr;
    App.UI.TextEdit.AdjustCursor(x, y);
  end;
begin
  if Button <> G2MB_Left then Exit;
  r := Frame;
  r.r := r.r - _ScrollV.Frame.w;
  r.l := r.l + r.w * _Splitter - 3;
  r.r := r.l + 6;
  Prop := PtInProperty(x, y, InExpand, InEdit, pr);
  if r.Contains(x, y)
  and (Prop <> nil)
  and (Prop.PropertyType in _AdjustSplitterPropertySet) then
  begin
    _AdjustingSplitter := True;
  end
  else
  begin
    if Prop <> nil then
    begin
      if InExpand and (Prop.Children^.Count > 0) then Prop.Open := not Prop.Open;
      if InEdit then
      begin
        pr.l := pr.l + pr.w * _Splitter + 1;
        case Prop.PropertyType of
          TPropertySet.TPropertyType.pt_int:
          begin
            _EditProperty := Prop;
            _EditText := IntToStr(PropInt.ValuePtr^);
            StartEditing;
          end;
          TPropertySet.TPropertyType.pt_float:
          begin
            _EditProperty := Prop;
            _EditText := FormatFloat(FloatPrintFormat, PropFloat.ValuePtr^);
            StartEditing;
          end;
          TPropertySet.TPropertyType.pt_string:
          begin
            if PropString.Editable then
            begin
              _EditProperty := Prop;
              _EditText := PropString.ValuePtr^;
              StartEditing;
            end;
          end;
        end;
      end;
    end;
  end;
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceProperties.OnMouseUp(const Button, x, y: Integer);
  var PropPrev, Prop: TPropertySet.TProperty;
  var InExpandPrev, InExpand, InEditPrev, InEdit: Boolean;
  var md: TG2Vec2;
  var r: TG2Rect;
  var od: TOpenDialog;
  var i: Integer;
  var Component: TG2Scene2DComponent;
begin
  md := g2.MouseDownPos[Button];
  PropPrev := PtInProperty(Round(md.x), Round(md.y), InExpandPrev, InEditPrev, r);
  Prop := PtInProperty(x, y, InExpand, InEdit, r);
  if (Prop <> nil)
  and (Prop = PropPrev) then
  begin
    if (Prop is TPropertySet.TPropertyButton) then
    begin
      if not InExpand and Assigned(TPropertySet.TPropertyButton(Prop).Proc) then
      TPropertySet.TPropertyButton(Prop).Proc;
    end
    else if (Prop is TPropertySet.TPropertyPath) then
    begin
      if InEdit and InEditPrev then
      begin
        if not App.Project.Open
        or (TPropertySet.TPropertyPath(Prop).AssetClass = TAsset) then
        begin
          od := TOpenDialog.Create(nil);
          if od.Execute then
          begin
            TPropertySet.TPropertyPath(Prop).ValuePtr^ := od.FileName;
            if Assigned(TPropertySet.TPropertyPath(Prop).OnChange) then
            TPropertySet.TPropertyPath(Prop).OnChange(Prop);
          end;
          od.Free;
        end
        else
        begin
          _EditProperty := Prop;
          App.UI.OverlayAssetSelect.Open(TPropertySet.TPropertyPath(Prop).AssetClass, @OnPathSelect);
        end;
      end;
    end
    else if (Prop is TPropertySet.TPropertyBool) then
    begin
      TPropertySet.TPropertyBool(Prop).ValuePtr^ := not TPropertySet.TPropertyBool(Prop).ValuePtr^;
      if Assigned(TPropertySet.TPropertyBool(Prop).OnChange) then
      TPropertySet.TPropertyBool(Prop).OnChange(Prop);
    end
    else if (Prop is TPropertySet.TPropertyEnum) then
    begin
      _EditProperty := Prop;
      _OverlayDropList.Items.Clear;
      for i := 0 to TPropertySet.TPropertyEnum(Prop).ValueCount - 1 do
      _OverlayDropList.Items.Add(TPropertySet.TPropertyEnum(Prop).Values[i].Name);
      r.l := r.l + r.w * _Splitter;
      _OverlayDropList.Initialize(r);
      _OverlayDropList.OnChange := @OnEnumChage;
      App.UI.Overlay := _OverlayDropList;
    end
    else if (Prop is TPropertySet.TPropertyComponent) then
    begin
      if InEdit and InEditPrev then
      begin
        Component := TPropertySet.TPropertyComponent(Prop).ValuePtr;
        App.Scene2DData.SelectionUpdateStart;
        App.Scene2DData.DeleteComponent(Component);
        App.Scene2DData.SelectionUpdateEnd;
      end;
    end;
  end;
  _AdjustingSplitter := False;
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceProperties.OnScroll(const y: Integer);
begin
  _ScrollV.Scroll(y);
end;

function TUIWorkspaceProperties.GetMinWidth: Single;
begin
  Result := 140;
end;

function TUIWorkspaceProperties.GetMinHeight: Single;
begin
  Result := 64;
end;

class function TUIWorkspaceProperties.GetWorkspaceName: AnsiString;
begin
  Result := 'Properties';
end;
//TUIWorkspaceProperties END

//TUIWorkspaceAtlasPacker BEGIN
procedure TUIWorkspaceAtlasPacker.TWorkspaceImageListToolbar.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var b: TUIWorkspaceCustomButton;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  p := Panel;
  p.Client.SpacingTop := 2;
  p.Client.SpacingBottom := 2;
  sm := p.Client.SplitterM(6);
  sm.SizingH := csFixed;

  b := sm.Subset[0].Button('');
  b.Icon := App.UI.TexDocPlus;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Add Image';
  BtnAddImages := b;

  b := sm.Subset[1].Button('');
  b.Icon := App.UI.TexFolderPlus;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Add Folder';
  BtnAddFolder := b;

  b := sm.Subset[2].Button('');
  b.Icon := App.UI.TexDelete;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Clear';
  BtnClear := b;

  b := sm.Subset[3].Button('');
  b.Icon := App.UI.TexFileSave;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Save Atlas Project';
  BtnSave := b;

  b := sm.Subset[4].Button('');
  b.Icon := App.UI.TexFileOpen;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Load Atlas Project';
  BtnLoad := b;

  b := sm.Subset[5].Button('');
  b.Icon := App.UI.TexGear;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Generate Atlas';
  BtnExport := b;
end;

class function TUIWorkspaceAtlasPacker.TWorkspaceImageListToolbar.GetWorkspaceName: AnsiString;
begin
  Result := 'Toolbar';
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnSlide;
begin

end;

function TUIWorkspaceAtlasPacker.TWorkspaceImageList.GetContentSize: Single;
begin
  if Images <> nil then
  Result := (Images^.Count + Folders^.Count) * (_ItemSize + _ItemSpacing) + _ItemSpacing
  else
  Result := 0;
end;

function TUIWorkspaceAtlasPacker.TWorkspaceImageList.PtInItem(const x, y: Single; var InClose: Boolean): Integer;
  var r, cr: TG2Rect;
  var i: Integer;
begin
  r := Frame;
  r.l := r.l + 2;
  r.t := r.t + _ItemSpacing - _ScrollV.PosAbsolute;
  r.r := r.r - _ScrollV.Frame.w;
  r.b := r.t + _ItemSize;
  for i := 0 to Folders^.Count - 1 do
  begin
    if r.Contains(x, y) then
    begin
      cr.l := r.r - _CloseButtonSize + 4;
      cr.t := r.Center.y - _CloseButtonSize * 0.5 + 4;
      cr.r := r.r - 4;
      cr.b := r.Center.y + _CloseButtonSize * 0.5 - 4;
      InClose := cr.Contains(x, y);
      Result := i;
      Exit;
    end;
    r.t := r.b + _ItemSpacing;
    r.b := r.t + _ItemSize;
  end;
  for i := 0 to Images^.Count - 1 do
  begin
    if r.Contains(x, y) then
    begin
      cr.l := r.r - _CloseButtonSize + 4;
      cr.t := r.Center.y - _CloseButtonSize * 0.5 + 4;
      cr.r := r.r - 4;
      cr.b := r.Center.y + _CloseButtonSize * 0.5 - 4;
      InClose := cr.Contains(x, y);
      Result := i + Folders^.Count;
      Exit;
    end;
    r.t := r.b + _ItemSpacing;
    r.b := r.t + _ItemSize;
  end;
  Result := -1;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.DeleteItem(const ItemIndex: Integer);
  var i: Integer;
begin
  if Images <> nil then
  begin
    if ItemIndex < Folders^.Count then
    begin
      for i := 0 to Folders^[ItemIndex].Images.Count - 1 do
      begin
        Folders^[ItemIndex].Images[i].Texture.Free;
        Folders^[ItemIndex].Images[i].Free;
      end;
      Folders^[ItemIndex].Free;
      Folders^.Delete(ItemIndex);
    end
    else
    begin
      i := ItemIndex - Folders^.Count;
      Images^[i].Texture.Free;
      Images^[i].Free;
      Images^.Delete(i);
    end;
  end;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnInitialize;
begin
  _ItemSize := 32;
  _ItemSpacing := 2;
  _CloseButtonSize := 32;
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _ScrollV.OnChange := @OnSlide;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame; r.l := r.r - 18;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.ParentSize := r.h;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnRender;
  var r: TG2Rect;
  var cr: TRect;
  var c0, c1, c2: TG2Color;
  procedure DrawItem(const Texture: TG2Texture2D; const Name: AnsiString);
    var sw, sh, s: Single;
  begin
    App.UI.PushClipRect(r);
    if r.Contains(g2.MousePos) then
    begin
      c0 := App.UI.GetColorPrimary(0.8);
      c1 := $ff000000;
      c2 := App.UI.GetColorPrimary(0.2);
    end
    else
    begin
      c0 := App.UI.GetColorPrimary(0.6);
      c1 := $ffffffff;
      c2 := App.UI.GetColorPrimary(0.9);
    end;
    g2.PrimRect(r.x, r.y, r.w, r.h, c0);
    if Texture <> nil then
    begin
      sw := (_ItemSize - 8) / Texture.Width;
      sh := (_ItemSize - 8) / Texture.Height;
      s := G2Min(sw, sh);
      sw := Texture.Width * s;
      sh := Texture.Height * s;
      g2.PicRect(r.x + (_ItemSize - sw) * 0.5, r.y + (_ItemSize - sh) * 0.5, sw, sh, $ffffffff, Texture);
    end;
    r.r := r.r - _CloseButtonSize;
    App.UI.PushClipRect(r);
    App.UI.Font1.Print(r.x + _ItemSize, r.y + (_ItemSize - App.UI.Font1.TextHeight('A')) * 0.5, 1, 1, c1, Name, bmNormal, tfPoint);
    App.UI.PopClipRect;
    r.r := r.r + _CloseButtonSize;
    cr.Left := Round(r.r - _CloseButtonSize) + 4;
    cr.Top := Round(r.Center.y - _CloseButtonSize * 0.5) + 4;
    cr.Right := Round(r.r) - 4;
    cr.Bottom := Round(r.Center.y + _CloseButtonSize * 0.5) - 4;
    g2.PrimBegin(ptTriangles, bmNormal);
    if PtInRect(cr, g2.MousePos) then
    App.UI.DrawCross(cr, App.UI.GetColorSecondary(0.9))
    else
    App.UI.DrawCross(cr, c2);
    g2.PrimEnd;
    App.UI.PopClipRect;
    r.t := r.b + _ItemSpacing;
    r.b := r.t + _ItemSize;
  end;
  var i: Integer;
begin
  r := Frame;
  g2.PrimRect(
    r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.2)
  );
  r.l := r.l + 2;
  r.t := r.t + _ItemSpacing - _ScrollV.PosAbsolute;
  r.r := r.r - _ScrollV.Frame.w;
  r.b := r.t + _ItemSize;
  for i := 0 to Folders^.Count - 1 do
  begin
    DrawItem(App.UI.TexFolder, Folders^[i].Path);
  end;
  for i := 0 to Images^.Count - 1 do
  begin
    DrawItem(Images^[i].Texture, Images^[i].Name);
  end;
  _ScrollV.Render;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnUpdate;
begin
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.Update;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnMouseDown(const Button, x, y: Integer);
begin
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnMouseUp(const Button, x, y: Integer);
  var MdItem, McItem: Integer;
  var md, mc: TPoint;
  var MdInClose, McInClose: Boolean;
begin
  _ScrollV.MouseUp(Button, x, y);
  md := g2.MouseDownPos[Button];
  mc := Point(x, y);
  MdItem := PtInItem(md.x, md.y, MdInClose);
  McItem := PtInItem(mc.x, mc.y, McInClose);
  if (McItem > -1) and (McItem = MdItem) then
  begin
    if (McInClose) and (MdInClose) then
    begin
      DeleteItem(MdItem);
    end;
  end;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceImageList.OnScroll(const y: Integer);
begin
  _ScrollV.Scroll(y);
end;

class function TUIWorkspaceAtlasPacker.TWorkspaceImageList.GetWorkspaceName: AnsiString;
begin
  Result := 'Image List';
end;

function TUIWorkspaceAtlasPacker.TWorkspaceImageList.GetMinWidth: Single;
begin
  Result := 128;
end;

function TUIWorkspaceAtlasPacker.TWorkspaceImageList.GetMinHeight: Single;
begin
  Result := 64;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspacePreview.SetAtlas(const Value: TAtlas);
begin
  _Atlas := Value;
  if (_Atlas <> nil) and (_Atlas.Pages.Count > 0) then
  begin
    _CurPage := 0;
    _CamPos.SetValue(0, 0);
    _Scale := 1;
  end
  else
  begin
    _CurPage := -1;
    _CamPos.SetValue(0, 0);
    _Scale := 1;
  end;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspacePreview.OnInitialize;
begin
  _Atlas := nil;
  _CurPage := -1;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspacePreview.OnAdjust;
begin

end;

procedure TUIWorkspaceAtlasPacker.TWorkspacePreview.OnRender;
  var r: TG2Rect;
  var i, j: Integer;
  var AtlasFrame: TAtlasFrame;
begin
  r := Frame;
  g2.PrimRect(
    r.x, r.y, r.w, r.h, $ffc0c0c0
  );
  g2.PicRect(
    r.x, r.y, r.w, r.h,
    0, 0, r.w / App.UI.TexChecker.Width * 0.2, r.h / App.UI.TexChecker.Height * 0.2,
    $ff303030, App.UI.TexChecker, bmAdd
  );
  if (Atlas <> nil) and (_CurPage > -1)
  and (Atlas.Pages[_CurPage].Rendered) then
  begin
    g2.PicRect(
      r.x + r.w * 0.5 - _CamPos.x, r.y + r.h * 0.5 - _CamPos.y,
      Atlas.Pages[_CurPage].Width, Atlas.Pages[_CurPage].Height,
      $ffffffff, 0.5, 0.5, _Scale, _Scale, 0, False, False,
      Atlas.Pages[_CurPage].TextureRT,
      Atlas.Pages[_CurPage].Width, Atlas.Pages[_CurPage].Height,
      0
    );
  end;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspacePreview.OnScroll(const y: Integer);
begin
  if y > 0 then
  _Scale *= 1.1
  else
  _Scale *= 0.9;
end;

class function TUIWorkspaceAtlasPacker.TWorkspacePreview.GetWorkspaceName: AnsiString;
begin
  Result := 'Preview';
end;

function TUIWorkspaceAtlasPacker.TWorkspacePreview.GetMinWidth: Single;
begin
  Result := 128;
end;

function TUIWorkspaceAtlasPacker.TWorkspacePreview.GetMinHeight: Single;
begin
  Result := 128;
end;

procedure TUIWorkspaceAtlasPacker.TWorkspaceControls.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var g: TUIWorkspaceCustomGroup;
  var Int: TUIWorkspaceCustomNumberInt;
  var sh: TUIWorkspaceFixedSplitterH;
  var l: TUIWorkspaceCustomLabel;
  var cb: TUIWorkspaceCustomComboBox;
  var b: TUIWorkspaceCustomCheckbox;
  var btn: TUIWorkspaceCustomButton;
begin
  p := Panel;
  p.Client.SpacingLeft := 4;
  p.Client.SpacingTop := 4;
  g := p.Client.Group('Settings');
  g.Client.SetSpacing(4);

  sh := g.Client.SplitterH;
  sh.Left.SpacingRight := 8;
  l := sh.Left.Text('Max Page Width');
  l.Align := [caRight, caMiddle];
  l.Height := 24;
  l.Color := $ffffffff;
  Int := sh.Right.NumberInt;
  Int.NumberMin := 4;
  Int.NumberMax := 2048;
  Int.Number := 1024;
  MaxPageWidth := Int;

  sh := g.Client.SplitterH;
  sh.PaddingTop := 2;
  sh.Left.SpacingRight := 8;
  l := sh.Left.Text('Max Page Height');
  l.Align := [caRight, caMiddle];
  l.Height := 24;
  l.Color := $ffffffff;
  Int := sh.Right.NumberInt;
  Int.NumberMin := 4;
  Int.NumberMax := 2048;
  Int.Number := 1024;
  MaxPageHeight := Int;

  sh := g.Client.SplitterH;
  sh.PaddingTop := 2;
  sh.Left.SpacingRight := 8;
  l := sh.Left.Text('Frame Border Size');
  l.Align := [caRight, caMiddle];
  l.Height := 24;
  l.Color := $ffffffff;
  Int := sh.Right.NumberInt;
  Int.PaddingTop := 2;
  Int.NumberMin := 0;
  Int.NumberMax := 8;
  Int.Number := 2;
  BorderSize := Int;

  b := g.Client.CheckBox('Transparent Borders');
  b.PaddingTop := 8;
  TransparentBorders := b;

  b := g.Client.CheckBox('Force Power of 2');
  b.PaddingTop := 8;
  ForcePOT := b;

  l := g.Client.Text('Export Format:');
  l.Color := $ffffffff;
  l.Align := [caLeft, caBottom];

  sh := g.Client.SplitterH(0.87);
  sh.PaddingTop := 2;

  btn := sh.Right.Button('');
  btn.Icon := App.UI.TexDocExport;
  btn.SizingH := csFixed;
  btn.Width := 32;
  btn.Hint := 'Export Atlas';
  BtnExport := btn;

  cb := sh.Left.ComboBox;
  FormatList := cb;
end;

class function TUIWorkspaceAtlasPacker.TWorkspaceControls.GetWorkspaceName: AnsiString;
begin
  Result := 'Controls';
end;

procedure TUIWorkspaceAtlasPacker.FreeAtlas;
  var i, j: Integer;
begin
  if _Atlas = nil then Exit;
  for i := 0 to _Atlas.Pages.Count - 1 do
  begin
    for j := 0 to _Atlas.Pages[i].Frames.Count - 1 do
    _Atlas.Pages[i].Frames[j].Free;
    _Atlas.Pages[i].Frames.Clear;
    _Atlas.Pages[i].TextureRT.Free;
    _Atlas.Pages[i].Free;
  end;
  _Atlas.Free;
  _Atlas := nil;
  _Preview.Atlas := nil;;
end;

procedure TUIWorkspaceAtlasPacker.ClearImages;
  var i, j: Integer;
begin
  for i := 0 to _Folders.Count - 1 do
  begin
    for j := 0 to _Folders[i].Images.Count - 1 do
    begin
      _Folders[i].Images[j].Texture.Free;
      _Folders[i].Images[j].Free;
    end;
    _Folders[i].Free;
  end;
  _Folders.Clear;
  for i := 0 to _Images.Count - 1 do
  begin
    _Images[i].Texture.Free;
    _Images[i].Free;
  end;
  _Images.Clear;
end;

procedure TUIWorkspaceAtlasPacker.GenerateAtlas;
  function FileMD5(const FileName: String): TG2MD5;
    var fs: TFileStream;
    var Buffer: array of Byte;
  begin
    fs := TFileStream.Create(FileName, fmOpenRead);
    try
      SetLength(Buffer, fs.Size);
      fs.Read(Buffer[0], fs.Size);
      Result := G2MD5(@Buffer[0], Length(Buffer));
    finally
      fs.Free;
    end;
  end;
  function FindImageAlias(const FileMD5: TG2MD5): TListImage;
    var i, j: Integer;
  begin
    for i := 0 to _Images.Count - 1 do
    if FileMD5 = _Images[i].FileMD5 then
    begin
      Result := _Images[i];
      Exit;
    end;
    for i := 0 to _Folders.Count - 1 do
    begin
      for j := 0 to _Folders[i].Images.Count - 1 do
      if FileMD5 = _Folders[i].Images[j].FileMD5 then
      begin
        Result := _Folders[i].Images[j];
        Exit;
      end;
    end;
    Result := nil;
  end;
  var i, j, n, k, w, l, m, h, x, y, wpot, hpot: Integer;
  var AllocationBest: array[0..2] of Integer;
  var RatioBest, Ratio: Single;
  var OffsetBest, Offset, AreaBest, Area, AliasCount: Integer;
  var Image: TListImage;
  var AtlasFrame: TAtlasFrame;
  var AtlasPage: TAtlasPage;
  var FrameFit, CanAllocate, SelectAllocation, Done: Boolean;
  var PageAllocations: array of array of Integer;
  var ImagesSorted, Images: TQuickListImage;
  var BorderSize, BorderSize2: Integer;
  var sr: TSearchRec;
  var img: TListImage;
begin
  BorderSize := _Controls.BorderSize.Number;
  BorderSize2 := BorderSize * 2;
  FreeAtlas;
  if _Images.Count + _Folders.Count = 0 then Exit;
  ImagesSorted.Clear;
  Images.Clear;
  for i := 0 to _Images.Count - 1 do
  _Images[i].FileMD5.Clear;
  for i := 0 to _Images.Count - 1 do
  begin
    _Images[i].FileMD5 := FileMD5(_Images[i].FileName);
    Image := FindImageAlias(_Images[i].FileMD5);
    if Image <> _Images[i] then _Images[i].AliasImage := Image else _Images[i].AliasImage := nil
  end;
  for i := 0 to _Folders.Count - 1 do
  begin
    for j := 0 to _Folders[i].Images.Count - 1 do
    begin
      _Folders[i].Images[j].Texture.Free;
      _Folders[i].Images[j].Free;
    end;
    _Folders[i].Images.Clear;
    if FindFirst(_Folders[i].Path + G2PathSep + '*.png', 0, sr) = 0 then
    begin
      repeat
        img := TListImage.Create;
        img.AliasImage := nil;
        img.FileName := _Folders[i].Path + G2PathSep + sr.Name;
        img.FileMD5 := FileMD5(img.FileName);
        Image := FindImageAlias(img.FileMD5);
        if Image <> img then img.AliasImage := Image else img.AliasImage := Image;
        img.Name := ExtractFileName(img.FileName);
        img.Texture := TG2Texture2D.Create;
        img.Texture.Load(img.FileName, tu2D);
        _Folders[i].Images.Add(img);
        Images.Add(img);
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;
  for i := 0 to _Images.Count - 1 do
  Images.Add(_Images[i]);
  if Images.Count = 0 then Exit;
  for i := 0 to Images.Count - 1 do
  if Images[i].AliasImage = nil then
  begin
    if (Images[i].Texture.Width + BorderSize2 > _Controls.MaxPageWidth.Number)
    or (Images[i].Texture.Height + BorderSize2 > _Controls.MaxPageHeight.Number) then
    begin
      App.Console.AddLine(
        '[Atlas Packer] Texture size exceeds maximum limits ' + Images[i].Name +
        '(' + IntToStr(Images[i].Texture.Width + BorderSize2) + 'x' + IntToStr(Images[i].Texture.Height + BorderSize2) + '). Skipped.'
      );
      Continue;
    end;
    n := (Images[i].Texture.Width + BorderSize2) * (Images[i].Texture.Height + BorderSize2);
    l := 0;
    h := ImagesSorted.Count - 1;
    while l <= h do
    begin
      m := (l + h) div 2;
      k := (ImagesSorted[m].Texture.Width + BorderSize2) * (ImagesSorted[m].Texture.Height + BorderSize2);
      if k = n then
      j := CompareFilenamesIgnoreCase(Images[i].Name, ImagesSorted[m].Name)
      else
      j := n - k;
      if j < 0 then
      l := m + 1 else h := m - 1;
    end;
    ImagesSorted.Insert(l, Images[i]);
  end;
  _Atlas := TAtlas.Create;
  _Atlas.Pages.Clear;
  for i := 0 to ImagesSorted.Count - 1 do
  begin
    Image := ImagesSorted[i];
    AtlasFrame := TAtlasFrame.Create;
    AtlasFrame.Image := Image;
    AtlasFrame.FilePath := Image.FileName;
    AtlasFrame.FileName := ExtractFileName(Image.FileName);
    AtlasFrame.Width := Image.Texture.Width;
    AtlasFrame.Height := Image.Texture.Height;
    FrameFit := False;
    for j := 0 to _Atlas.Pages.Count - 1 do
    begin
      AtlasPage := _Atlas.Pages[j];
      wpot := 1; while wpot < AtlasPage.Width do wpot := wpot shl 1;
      hpot := 1; while hpot < AtlasPage.Height do hpot := hpot shl 1;
      for n := 0 to High(PageAllocations[j]) do
      begin
        x := PageAllocations[j][n];
        y := 0;
        while (y <= (AtlasPage.Height + BorderSize2) + 1) do
        begin
          w := G2Max(AtlasPage.Width, x + (AtlasFrame.Width + BorderSize2));
          h := G2Max(AtlasPage.Height, y + (AtlasFrame.Height + BorderSize2));
          CanAllocate := True;
          for k := 0 to AtlasPage.Frames.Count - 1 do
          if G2RectInRect(
            Rect(
              x, y,
              x + AtlasFrame.Width + BorderSize2, y + AtlasFrame.Height + BorderSize2
            ),
            Rect(
              AtlasPage.Frames[k].PosX - BorderSize, AtlasPage.Frames[k].PosY - BorderSize,
              AtlasPage.Frames[k].PosX + AtlasPage.Frames[k].Width - 1 + BorderSize,
              AtlasPage.Frames[k].PosY + AtlasPage.Frames[k].Height - 1 + BorderSize
            )
          ) then
          begin
            y := AtlasPage.Frames[k].PosY + AtlasPage.Frames[k].Height + BorderSize2 - 1;
            CanAllocate := False;
            Break;
          end;
          if (w <= _Controls.MaxPageWidth.Number) and (h <= _Controls.MaxPageHeight.Number) and (CanAllocate) then
          begin
            if w > h then Ratio := w / h else Ratio := h / w;
            if (w > wpot) then Ratio *= 10;
            if (h > hpot) then Ratio *= 10;
            Offset := x + y;
            Area := w * h;
            Ratio += Area * 0.0001;
            if Abs(Ratio - RatioBest) < 0.001 then
            SelectAllocation := Offset < OffsetBest
            else
            SelectAllocation := Ratio < RatioBest;
            if not FrameFit or SelectAllocation then
            begin
              FrameFit := True;
              AllocationBest[0] := j;
              AllocationBest[1] := x;
              AllocationBest[2] := y;
              RatioBest := Ratio;
              OffsetBest := Offset;
              AreaBest := Area;
            end;
          end;
          y += 1;
        end;
      end;
    end;
    if FrameFit then
    begin
      j := AllocationBest[0];
      AtlasFrame.PosX := AllocationBest[1] + BorderSize;
      AtlasFrame.PosY := AllocationBest[2] + BorderSize;
      AtlasPage := _Atlas.Pages[j];
      AtlasFrame.Page := AtlasPage;
      AtlasPage.Frames.Add(AtlasFrame);
      AtlasPage.Width := G2Max(AtlasPage.Width, AtlasFrame.PosX + AtlasFrame.Width + BorderSize);
      AtlasPage.Height := G2Max(AtlasPage.Height, AtlasFrame.PosY + AtlasFrame.Height + BorderSize);
      SetLength(PageAllocations[j], Length(PageAllocations[j]) + 1);
      PageAllocations[j][High(PageAllocations[j])] := AtlasFrame.PosX + AtlasFrame.Width + BorderSize;
    end
    else
    begin
      AtlasPage := TAtlasPage.Create;
      AtlasPage.Width := AtlasFrame.Width + BorderSize2;
      AtlasPage.Height := AtlasFrame.Height + BorderSize2;
      _Atlas.Pages.Add(AtlasPage);
      AtlasPage.Frames.Add(AtlasFrame);
      AtlasFrame.Page := AtlasPage;
      AtlasFrame.PosX := BorderSize;
      AtlasFrame.PosY := BorderSize;
      j := Length(PageAllocations);
      SetLength(PageAllocations, Length(PageAllocations) + 1);
      SetLength(PageAllocations[j], 2);
      PageAllocations[j][0] := 0;
      PageAllocations[j][1] := AtlasFrame.PosX + AtlasFrame.Width + BorderSize;
    end;
  end;
  AliasCount := 0;
  for i := 0 to Images.Count - 1 do
  if Images[i].AliasImage <> nil then
  begin
    Done := False;
    for j := 0 to _Atlas.Pages.Count - 1 do
    begin
      for n := 0 to _Atlas.Pages[j].Frames.Count - 1 do
      begin
        if _Atlas.Pages[j].Frames[n].Image = Images[i].AliasImage then
        begin
          AtlasFrame := TAtlasFrame.Create;
          AtlasFrame.Image := Images[i];
          AtlasFrame.FilePath := Images[i].FileName;
          AtlasFrame.FileName := ExtractFileName(Images[i].FileName);
          AtlasFrame.Width := Images[i].Texture.Width;
          AtlasFrame.Height := Images[i].Texture.Height;
          AtlasFrame.PosX := _Atlas.Pages[j].Frames[n].PosX;
          AtlasFrame.PosY := _Atlas.Pages[j].Frames[n].PosY;
          AtlasFrame.Page := _Atlas.Pages[j];
          _Atlas.Pages[j].Frames.Add(AtlasFrame);
          Done := True;
          Inc(AliasCount);
        end;
        if Done then Break;
      end;
      if Done then Break;
    end;
  end;
  for i := 0 to _Atlas.Pages.Count - 1 do
  begin
    _Atlas.Pages[i].TextureRT := TG2Texture2DRT.Create;
    if _Controls.ForcePOT.Checked then
    begin
      w := 1; while w < _Atlas.Pages[i].Width do w := w shl 1;
      h := 1; while h < _Atlas.Pages[i].Height do h := h shl 1;
      _Atlas.Pages[i].TextureRT.Make(w, h);
    end
    else
    _Atlas.Pages[i].TextureRT.Make(_Atlas.Pages[i].Width, _Atlas.Pages[i].Height);
    _Atlas.Pages[i].TextureWidth := _Atlas.Pages[i].TextureRT.Width;
    _Atlas.Pages[i].TextureHeight := _Atlas.Pages[i].TextureRT.Height;
    _Atlas.Pages[i].Rendered := False;
  end;
  App.Console.AddLine('[Atlas Packer] ' + IntToStr(ImagesSorted.Count) + ' images packed into ' + IntToStr(_Atlas.Pages.Count) + ' pages.');
  if AliasCount > 0 then
  App.Console.AddLine('[Atlas Packer] ' + IntToStr(AliasCount) + ' duplicate images.');
  _Preview.Atlas := _Atlas;
end;

procedure TUIWorkspaceAtlasPacker.RenderAtlasPage(const Page: TAtlasPage);
  var bm: TG2BlendMode;
  var i, bs: Integer;
  var f: TAtlasFrame;
  var px: TG2Vec2;
  var BorderColor: TG2Color;
  var ClipRect: TRect;
begin
  ClipRect := App.UI.ClipRects[High(App.UI.ClipRects)];
  g2.Gfx.StateChange.StateDepthEnable := False;
  g2.Gfx.StateChange.StateScissor := nil;
  bm := bmDisable;
  g2.Gfx.StateChange.StateRenderTarget := Page.TextureRT;
  g2.Gfx.StateChange.StateClear($00000000);
  for i := 0 to Page.Frames.Count - 1 do
  begin
    f := Page.Frames[i];
    px.x := 1 / f.Image.Texture.RealWidth;
    px.y := 1 / f.Image.Texture.RealHeight;
    if _Controls.BorderSize.Number > 0 then
    begin
      if _Controls.TransparentBorders.Checked then
      BorderColor := $00ffffff
      else
      BorderColor := $ffffffff;
      bs := _Controls.BorderSize.Number;
      g2.PicRect(
        f.PosX - bs, f.PosY - bs, bs, bs,
        0, 0, 0, 0,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX + f.Width, f.PosY - bs, bs, bs,
        f.Image.Texture.SizeTU - px.x, 0, f.Image.Texture.SizeTU - px.x, 0,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX + f.Width, f.PosY + f.Height, bs, bs,
        f.Image.Texture.SizeTU - px.x, f.Image.Texture.SizeTV - px.y, f.Image.Texture.SizeTU - px.x, f.Image.Texture.SizeTV - px.y,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX - bs, f.PosY + f.Height, bs, bs,
        0, f.Image.Texture.SizeTV - px.y, 0, f.Image.Texture.SizeTV - px.y,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX, f.PosY - bs, f.Width, bs,
        0, 0, f.Width / f.Image.Texture.RealWidth, 0,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX + f.Width, f.PosY, bs, f.Height,
        (f.Width - 1) / f.Image.Texture.RealWidth, 0, (f.Width - 1) / f.Image.Texture.RealWidth, f.Height / f.Image.Texture.RealHeight,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX, f.PosY + f.Height, f.Width, bs,
        0, (f.Height - 1) / f.Image.Texture.RealHeight, f.Width / f.Image.Texture.RealWidth, (f.Height - 1) / f.Image.Texture.RealHeight,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
      g2.PicRect(
        f.PosX - bs, f.PosY, bs, f.Height,
        0, 0, 0, f.Height / f.Image.Texture.RealHeight,
        BorderColor, f.Image.Texture, bm, tfPoint
      );
    end;
    g2.PicRect(
      f.PosX, f.PosY,
      f.Width, f.Height,
      $ffffffff, f.Image.Texture,
      bm, tfPoint
    );
  end;
  g2.Gfx.StateChange.StateRenderTarget := nil;
  g2.Gfx.StateChange.StateScissor := @ClipRect;
  Page.Rendered := True;
end;

procedure TUIWorkspaceAtlasPacker.SaveAtlas(const FilePath: String; const FormatFile: String);
  var OutputFormat: AnsiString;
  function CheckStr(const Pos: Integer; const Str: AnsiString): Boolean;
    var i: Integer;
  begin
    if Length(OutputFormat) < Pos + Length(Str) - 1 then
    begin
      Result := False;
      Exit;
    end;
    for i := 0 to Length(Str) - 1 do
    if OutputFormat[Pos + i] <> Str[i + 1] then
    begin
      Result := False;
      Exit;
    end;
    Result := True;
  end;
  var Pos: Integer;
  function ReadCommand: AnsiString;
  begin
    Result := '';
    if (Pos > Length(OutputFormat)) or (OutputFormat[Pos] <> '(') then Exit;
    Inc(Pos);
    while Pos <= Length(OutputFormat) do
    begin
      if OutputFormat[Pos] <> ')' then
      begin
        Result += OutputFormat[Pos];
        Inc(Pos);
      end
      else
      begin
        Inc(Pos);
        Break;
      end;
    end;
    Result := Trim(Result);
  end;
  var fs: TFileStream;
  var i, j, PagePos, CurPage, FramePos, CurFrame: Integer;
  var Output, Cmd: AnsiString;
  var IsInPage, IsInFrame: Boolean;
  var Frames: TAtlasFrameList;
  var UniformName, SaveDir: String;
  var f: TAtlasFrame;
  function GetCurPage: Integer;
    var n: Integer;
  begin
    if IsInPage then
    begin
      Result := CurPage;
    end
    else if IsInFrame then
    begin
      if CurFrame > -1 then
      begin
        Result := -1;
        for n := 0 to _Atlas.Pages.Count - 1 do
        if Pointer(_Atlas.Pages[n]) = Frames[CurFrame].Page then
        begin
          Result := n;
          Break;
        end;
      end;
    end;
  end;
  function GetCurFrame: TAtlasFrame;
  begin
    if IsInPage then
    begin
      if (CurPage > -1)
      and IsInFrame
      and (CurFrame > -1) then
      begin
        Result := _Atlas.Pages[CurPage].Frames[CurFrame];
      end
      else
      Result := nil;
    end
    else if IsInFrame then
    begin
      if CurFrame > -1 then
      Result := Frames[CurFrame]
      else
      Result := nil;
    end
    else
    Result := nil;
  end;
begin
  Frames.Clear;
  for i := 0 to _Atlas.Pages.Count - 1 do
  for j := 0 to _Atlas.Pages[i].Frames.Count - 1 do
  Frames.Add(_Atlas.Pages[i].Frames[j]);
  fs := TFileStream.Create(g2.AppPath + 'data' + G2PathSep + 'atlas_packer' + G2PathSep + FormatFile, fmOpenRead);
  try
    SetLength(OutputFormat, fs.Size);
    fs.Read(OutputFormat[1], fs.Size);
  finally
    fs.Free;
  end;
  OutputFormat := G2StrReplace(OutputFormat, #$D#$A, #$D);
  OutputFormat := G2StrReplace(OutputFormat, #$A, #$D);
  UniformName := ExtractFileNameWithoutExt(ExtractFileName(FilePath));
  SaveDir := ExtractFileDir(FilePath);
  for i := 0 to _Atlas.Pages.Count - 1 do
  _Atlas.Pages[i].TextureRT.Save(SaveDir + G2PathSep +  UniformName + '_' + IntToStr(i) + '.png');
  if Length(ExtractFileExt(FilePath)) = 0 then
  fs := TFileStream.Create(FilePath + '.atlas', fmCreate)
  else
  fs := TFileStream.Create(FilePath, fmCreate);
  try
    Output := '';
    Pos := 1;
    PagePos := -1;
    CurPage := -1;
    IsInPage := False;
    IsInFrame := False;
    while Pos <= Length(OutputFormat) do
    begin
      if CheckStr(Pos, '$') then
      begin
        Inc(Pos);
        Cmd := LowerCase(ReadCommand);
        if Cmd = 'page_begin' then
        begin
          if not IsInPage
          and not IsInFrame then
          begin
            CurPage := 0;
            PagePos := Pos;
            IsInPage := True;
            if CurPage >= _Atlas.Pages.Count then
            CurPage := -1;
          end;
        end
        else if Cmd = 'page_end' then
        begin
          if IsInPage then
          begin
            IsInPage := False;
            if CurPage > -1 then
            begin
              Inc(CurPage);
              if CurPage < _Atlas.Pages.Count then
              begin
                Pos := PagePos;
                IsInPage := True;
              end
              else
              begin
                CurPage := -1;
              end;
            end;
          end;
        end
        else if Cmd = 'frame_begin' then
        begin
          if not IsInFrame then
          begin
            CurFrame := 0;
            FramePos := Pos;
            if IsInPage then
            begin
              if (CurPage = -1)
              or (CurFrame >= _Atlas.Pages[CurPage].Frames.Count) then
              CurFrame := -1;
            end
            else
            begin
              if CurFrame >= Frames.Count then
              CurFrame := -1;
            end;
            IsInFrame := True;
          end;
        end
        else if Cmd = 'frame_end' then
        begin
          if IsInFrame then
          begin
            IsInFrame := False;
            if CurFrame > -1 then
            begin
              Inc(CurFrame);
              if IsInPage then
              begin
                if (CurPage > -1)
                and (CurFrame < _Atlas.Pages[CurPage].Frames.Count) then
                begin
                  Pos := FramePos;
                  IsInFrame := True;
                end;
              end
              else
              begin
                if CurFrame < Frames.Count then
                begin
                  Pos := FramePos;
                  IsInFrame := True;
                end;
              end;
            end;
          end;
        end
        else if Cmd = 'page_file' then
        begin
          i := GetCurPage;
          if i > -1 then
          Output += UniformName + '_' + IntToStr(i) + '.png';
        end
        else if Cmd = 'page_name' then
        begin
          i := GetCurPage;
          if i > -1 then
          Output += UniformName + '_' + IntToStr(i);
        end
        else if (Cmd = 'page_w')
        or (Cmd = 'page_width') then
        begin
          i := GetCurPage;
          if i > -1 then
          Output += IntToStr(_Atlas.Pages[i].TextureWidth);
        end
        else if (Cmd = 'page_h')
        or (Cmd = 'page_height') then
        begin
          i := GetCurPage;
          if i > -1 then
          Output += IntToStr(_Atlas.Pages[i].TextureHeight);
        end
        else if Cmd = 'frame_path' then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += f.FilePath;
        end
        else if Cmd = 'frame_file' then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += f.FileName;
        end
        else if Cmd = 'frame_name' then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += ExtractFileNameWithoutExt(f.FileName);
        end
        else if (Cmd = 'frame_l')
        or (Cmd = 'frame_left') then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += IntToStr(f.PosX);
        end
        else if (Cmd = 'frame_t')
        or (Cmd = 'frame_top') then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += IntToStr(f.PosY);
        end
        else if (Cmd = 'frame_r')
        or (Cmd = 'frame_right') then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += IntToStr(f.PosX + f.Width);
        end
        else if (Cmd = 'frame_b')
        or (Cmd = 'frame_bottom') then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += IntToStr(f.PosY + f.Height);
        end
        else if (Cmd = 'frame_w')
        or (Cmd = 'frame_width') then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += IntToStr(f.Width);
        end
        else if (Cmd = 'frame_h')
        or (Cmd = 'frame_height') then
        begin
          f := GetCurFrame;
          if f <> nil then
          Output += IntToStr(f.Height);
        end;
      end
      else
      begin
        Output += OutputFormat[Pos];
        Inc(Pos);
      end;
    end;
    fs.Write(Output[1], Length(Output));
  finally
    fs.Free;
  end;
end;

procedure TUIWorkspaceAtlasPacker.OnInitialize;
begin
  App.AtlasPackerData.WorkspaceCount := App.AtlasPackerData.WorkspaceCount + 1;
  _ImageListToolbar := TWorkspaceImageListToolbar.Create;
  _ImageListToolbar.Parent := Self;
  _ImageList := TWorkspaceImageList.Create;
  _ImageList.Parent := Self;
  _Controls := TWorkspaceControls.Create;
  _Controls.Parent := Self;
  _Controls.BtnExport.OnClick := @FuncExport;
  _Preview := TWorkspacePreview.Create;
  _Preview.Parent := Self;
  _Images.Clear;
  _Folders.Clear;
  _ImageList.Images := @_Images;
  _ImageList.Folders := @_Folders;
  _ImageListToolbar.BtnAddImages.OnClick := @FuncImageAdd;
  _ImageListToolbar.BtnAddFolder.OnClick := @FuncFolderAdd;
  _ImageListToolbar.BtnExport.OnClick := @FuncGenerate;
  _ImageListToolbar.BtnClear.OnClick := @ClearImages;
  _ImageListToolbar.BtnSave.OnClick := @FuncSave;
  _ImageListToolbar.BtnLoad.OnClick := @FuncLoad;
  _Atlas := nil;
  _UpdateTime := 0;
end;

procedure TUIWorkspaceAtlasPacker.OnFinalize;
  var i: Integer;
begin
  FreeAtlas;
  ClearImages;
  App.AtlasPackerData.WorkspaceCount := App.AtlasPackerData.WorkspaceCount - 1;
end;

procedure TUIWorkspaceAtlasPacker.OnAdjust;
  var r: TG2Rect;
begin
  r := Frame;
  r.w := 256;
  r.h := _ImageListToolbar.GetMinHeight;
  _ImageListToolbar.Frame := r;
  r.t := r.b;
  r.b := Frame.b;
  r.r := r.r - 4;
  _ImageList.Frame := r;
  r := Frame;
  r.t := r.t + 4;
  r.l := r.l + 256;
  r.r := r.r - 256;
  _Preview.Frame := r;
  r := Frame;
  r.l := r.r - 256;
  _Controls.Frame := r;
end;

procedure TUIWorkspaceAtlasPacker.OnRender;
  var r: TG2Rect;
  var i: Integer;
  var ClipRect: TRect;
begin
  r := Frame;
  g2.PrimRect(
    r.x, r.y, r.w, r.h,
    App.UI.GetColorPrimary(0.4)
  );
  if _Atlas <> nil then
  for i := 0 to _Atlas.Pages.Count - 1 do
  if not _Atlas.Pages[i].Rendered then
  RenderAtlasPage(_Atlas.Pages[i]);
end;

procedure TUIWorkspaceAtlasPacker.OnUpdate;
  var PrevSelection: String;
  var i: Integer;
begin
  if _UpdateTime <> App.AtlasPackerData.UpdateTime then
  begin
    PrevSelection := _Controls.FormatList.Text;
    _Controls.FormatList.Clear;
    for i := 0 to App.AtlasPackerData.FormatCount - 1 do
    _Controls.FormatList.Add(App.AtlasPackerData.Formats[i]);
    _Controls.FormatList.Text := PrevSelection;
    _UpdateTime := App.AtlasPackerData.UpdateTime;
  end;
end;

class function TUIWorkspaceAtlasPacker.GetWorkspaceName: AnsiString;
begin
  Result := 'Atlas Packer';
end;

function TUIWorkspaceAtlasPacker.GetMinWidth: Single;
begin
  Result := 600;
end;

function TUIWorkspaceAtlasPacker.GetMinHeight: Single;
begin
  Result := 200;
end;

procedure TUIWorkspaceAtlasPacker.FuncImageAdd;
  var od: TOpenDialog;
  var img: TListImage;
  var i: Integer;
begin
  od := TOpenDialog.Create(nil);
  od.Options := od.Options + [ofAllowMultiSelect];
  g2.Pause := True;
  if od.Execute then
  for i := 0 to od.Files.Count - 1 do
  begin
    img := TListImage.Create;
    img.FileName := od.Files[i];
    img.Name := ExtractFileName(img.FileName);
    img.Texture := TG2Texture2D.Create;
    img.Texture.Load(img.FileName, tu2D);
    _Images.Add(img);
  end;
  g2.Pause := False;
  od.Free;
end;

procedure TUIWorkspaceAtlasPacker.FuncFolderAdd;
  var od: TSelectDirectoryDialog;
  var fld: TListFolder;
  var i: Integer;
begin
  od := TSelectDirectoryDialog.Create(nil);
  g2.Pause := True;
  if od.Execute then
  begin
    fld := TListFolder.Create;
    fld.Path := od.FileName;
    fld.Images.Clear;
    _Folders.Add(fld);
  end;
  g2.Pause := False;
  od.Free;
end;

procedure TUIWorkspaceAtlasPacker.FuncGenerate;
begin
  GenerateAtlas;
end;

procedure TUIWorkspaceAtlasPacker.FuncExport;
  var sd: TSaveDialog;
begin
  if Assigned(_Atlas) then
  begin
    sd := TSaveDialog.Create(nil);
    sd.DefaultExt := '.atlas';
    g2.Pause := True;
    if sd.Execute then
    begin
      if (_Controls.FormatList.ItemIndex > -1)
      and FileExists(g2.AppPath + 'data' + G2PathSep + 'atlas_packer' + G2PathSep + _Controls.FormatList.Text) then
      begin
        SaveAtlas(sd.FileName, _Controls.FormatList.Text);
      end;
    end;
    g2.Pause := False;
    sd.Free;
  end;
end;

procedure TUIWorkspaceAtlasPacker.FuncSave;
  var sd: TSaveDialog;
  var g2ml: TG2MLWriter;
  var i: Integer;
  var fs: TFileStream;
begin
  sd := TSaveDialog.Create(nil);
  sd.DefaultExt := '.g2ap';
  g2.Pause := True;
  if sd.Execute then
  begin
    g2ml := TG2MLWriter.Create;
    g2ml.NodeOpen('g2ap');
    g2ml.NodeValue('max_page_width', _Controls.MaxPageWidth.Number);
    g2ml.NodeValue('max_page_height', _Controls.MaxPageHeight.Number);
    g2ml.NodeValue('border_size', _Controls.BorderSize.Number);
    g2ml.NodeValue('transparent_borders', _Controls.TransparentBorders.Checked);
    g2ml.NodeValue('force_pot', _Controls.ForcePOT.Checked);
    g2ml.NodeValue('export_format', _Controls.FormatList.Text);
    for i := 0 to _Folders.Count - 1 do
    begin
      g2ml.NodeOpen('folder');
      g2ml.NodeValue('path', _Folders[i].Path);
      g2ml.NodeClose;
    end;
    for i := 0 to _Images.Count - 1 do
    begin
      g2ml.NodeOpen('image');
      g2ml.NodeValue('path', _Images[i].FileName);
      g2ml.NodeClose;
    end;
    g2ml.NodeClose;
    fs := TFileStream.Create(sd.FileName, fmCreate);
    try
      fs.WriteBuffer(g2ml.G2ML[1], Length(g2ml.G2ML));
    finally
      fs.Free;
    end;
    g2ml.Free;
  end;
  g2.Pause := False;
  sd.Free;
end;

procedure TUIWorkspaceAtlasPacker.FuncLoad;
  var od: TOpenDialog;
  var g2ml: TG2ML;
  var r0, r1, r2, r3: PG2MLObject;
  var fs: TFileStream;
  var Data: AnsiString;
  var i0, i1: Integer;
  var img: TListImage;
  var fld: TListFolder;
begin
  od := TOpenDialog.Create(nil);
  od.Filter := 'Atlas Packer|*.g2ap;*.G2AP;';
  g2.Pause := True;
  if od.Execute then
  begin
    fs := TFileStream.Create(od.FileName, fmOpenRead);
    try
      SetLength(Data, fs.Size);
      fs.ReadBuffer(Data[1], fs.Size);
    finally
      fs.Free;
    end;
    g2ml := TG2ML.Create;
    r0 := g2ml.Read(Data);
    for i0 := 0 to r0^.Children.Count - 1 do
    begin
      r1 := r0^.Children[i0];
      if r1^.Name = 'g2ap' then
      begin
        ClearImages;
        for i1 := 0 to r1^.Children.Count - 1 do
        begin
          r2 := r1^.Children[i1];
          if r2^.Name = 'max_page_width' then
          _Controls.MaxPageWidth.Number := r2^.AsInt
          else if r2^.Name = 'max_page_height' then
          _Controls.MaxPageHeight.Number := r2^.AsInt
          else if r2^.Name = 'border_size' then
          _Controls.BorderSize.Number := r2^.AsInt
          else if r2^.Name = 'transparent_borders' then
          _Controls.TransparentBorders.Checked := r2^.AsBool
          else if r2^.Name = 'force_pot' then
          _Controls.ForcePOT.Checked := r2^.AsBool
          else if r2^.Name = 'export_format' then
          _Controls.FormatList.Text := r2^.AsString
          else if r2^.Name = 'folder' then
          begin
            r3 := r2^.FindNode('path');
            if (r3 <> nil)
            and (DirectoryExists(r3^.AsString)) then
            begin
              fld := TListFolder.Create;
              fld.Path := r3^.AsString;
              fld.Images.Clear;
              _Folders.Add(fld);
            end;
          end
          else if r2^.Name = 'image' then
          begin
            r3 := r2^.FindNode('path');
            if (r3 <> nil)
            and (FileExists(r3^.AsString)) then
            begin
              img := TListImage.Create;
              img.FileName := r3^.AsString;
              img.Name := ExtractFileName(img.FileName);
              img.Texture := TG2Texture2D.Create;
              img.Texture.Load(img.FileName, tu2D);
              _Images.Add(img);
            end;
          end;
        end;
      end;
    end;
    g2ml.FreeObject(r0);
    g2ml.Free;
  end;
  g2.Pause := False;
  od.Free;
end;
//TUIWorkspaceAtlasPacker END

//TUIWorkspaceStructure BEGIN
function TUIWorkspaceStructure.TItem.Add(const NewName: String): TItem;
begin
  Result := TItem.Create;
  Result.Workspace := Workspace;
  Result.Name := NewName;
  Result.Parent := Self;
  Result.Children.Clear;
  Result.Open := False;
  Result.UserData := nil;
  Result.Selected := False;
  Children.Add(Result);
end;

procedure TUIWorkspaceStructure.TItem.Remove(var Item: TItem);
begin
  if Item.Selected then
  Workspace._Selection.Remove(Item);
  Children.Remove(Item);
  FreeItem(Item);
  Item := nil;
end;

procedure TUIWorkspaceStructure.SelectionUpdateStart;
  var i: Integer;
begin
  for i := 0 to _Selection.Count - 1 do
  _Selection[i].Selected := False;
end;

procedure TUIWorkspaceStructure.SelectionUpdateEnd;
  var i: Integer;
begin
  for i := 0 to _Selection.Count - 1 do
  _Selection[i].Selected := True;
end;

class procedure TUIWorkspaceStructure.FreeItem(const Item: TItem);
  var i: Integer;
begin
  for i := 0 to Item.Children.Count - 1 do
  FreeItem(Item.Children[i]);
  Item.Free;
end;

function TUIWorkspaceStructure.PtInItem(const pt: TG2Vec2; var InExpand: Boolean): TItem;
  var x, y, w, h: Single;
  procedure CheckItem(const Item: TItem; const Offset: Integer);
    var i: Integer;
  begin
    if G2Rect(x, y, w, h).Contains(pt) then
    begin
      Result := Item;
      InExpand := pt.x < x + Offset;
      Exit;
    end;
    y += h;
    if Item.Open then
    for i := 0 to Item.Children.Count - 1 do
    begin
      CheckItem(Item.Children[i], Offset + 16);
      if Result <> nil then Exit;
    end;
  end;
  var i: Integer;
begin
  Result := nil;
  x := Frame.l;
  y := Frame.t;
  h := App.UI.Font1.TextHeight('A');
  w := Frame.w;
  for i := 0 to _Root.Children.Count - 1 do
  begin
    CheckItem(_Root.Children[i], 16);
    if Result <> nil then Exit;
  end;
end;

procedure TUIWorkspaceStructure.OnInitialize;
begin
  _Selection.Clear;
  _Root := TItem.Create;
  _Root.Workspace := Self;
  _Root.Name := 'Root';
  _Root.Parent := nil;
  _Root.Children.Clear;
  _Root.Open := True;
end;

procedure TUIWorkspaceStructure.OnFinalize;
begin
  Clear;
  _Root.Free;
end;

procedure TUIWorkspaceStructure.OnRender;
  var x, y, w, h: Single;
  procedure RenderItem(const Item: TItem; const Offset: Integer);
    var i: Integer;
    var s: String;
  begin
    if Item.Selected then
    g2.PrimRect(x, y, w, h, App.UI.GetColorSecondary(0.5, 0.5));
    App.UI.Font1.Print(x + Offset, y, 1, 1, $ffffffff, Item.Name, bmNormal, tfLinear);
    if Item.Children.Count > 0 then
    begin
      if Item.Open then s := '-' else s := '+';
      App.UI.Font1.Print(x + Offset - 8 - App.UI.Font1.TextWidth(s) * 0.5, y, 1, 1, $ffffffff, s, bmNormal, tfLinear);
    end;
    y += h;
    if Item.Open then
    for i := 0 to Item.Children.Count - 1 do
    RenderItem(Item.Children[i], Offset + 16);
  end;
  var i: Integer;
begin
  g2.PrimRect(
    Frame.x, Frame.y, Frame.w, Frame.h,
    App.UI.GetColorPrimary(0.2)
  );
  App.UI.PushClipRect(Frame);
  x := Frame.l;
  y := Frame.t;
  h := App.UI.Font1.TextHeight('A');
  w := Frame.w;
  for i := 0 to _Root.Children.Count - 1 do
  RenderItem(_Root.Children[i], 16);
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceStructure.OnMouseDown(const Button, x, y: Integer);
  var Item, ItemPrev: TItem;
  var InExpand, InExpandPrev: Boolean;
begin
  case Button of
    G2MB_Left:
    begin
      ItemPrev := PtInItem(g2.MouseDownPos[Button], InExpandPrev);
      Item := PtInItem(G2Vec2(x, y), InExpand);
      if (Item <> nil)
      and (Item = ItemPrev)
      and (InExpand = InExpandPrev) then
      begin
        if InExpand then Item.Open := not Item.Open
        else
        begin
          if g2.KeyDown[G2K_CtrlR] or g2.KeyDown[G2K_CtrlL] then
          begin
            if Item.Selected then
            begin
              SelectionUpdateStart;
              _Selection.Remove(Item);
              SelectionUpdateEnd;
            end
            else
            begin
              SelectionUpdateStart;
              _Selection.Add(Item);
              SelectionUpdateEnd;
            end;
          end
          else
          begin
            SelectionUpdateStart;
            _Selection.Clear;
            _Selection.Add(Item);
            SelectionUpdateEnd;
          end;
        end;
      end
      else
      begin
        SelectionUpdateStart;
        _Selection.Clear;
        SelectionUpdateEnd;
      end;
    end;
  end;
end;

procedure TUIWorkspaceStructure.OnMouseUp(const Button, x, y: Integer);
begin

end;

class function TUIWorkspaceStructure.GetWorkspaceName: AnsiString;
begin
  Result := 'Structure';
end;

procedure TUIWorkspaceStructure.Clear;
  var i: Integer;
begin
  for i := 0 to _Root.Children.Count - 1 do
  FreeItem(_Root.Children[i]);
  _Root.Children.Clear;
end;
//TUIWorkspaceStructure END

//TUIWorkspaceScene2DProperties BEGIN
procedure TUIWorkspaceScene2DProperties.OnInitialize;
begin
  inherited OnInitialize;
  PropertySetPtr := @App.Scene2DData.PropertySet;
end;

class function TUIWorkspaceScene2DProperties.GetWorkspaceName: AnsiString;
begin
  Result := 'Properties';
end;

class function TUIWorkspaceScene2DProperties.GetWorkspacePath: AnsiString;
begin
  Result := 'Scene2D';
end;
//TUIWorkspaceScene2DProperties END

//TUIWorkspaceScene2DStructure BEGIN
function TUIWorkspaceScene2DStructure.PtInItem(
  const pt: TG2Vec2;
  var InExpand: Boolean
): TG2Scene2DEntity;
  var x, y, w, h: Single;
  procedure CheckItem(const Item: TG2Scene2DEntity; const Offset: Integer);
    var i: Integer;
  begin
    if G2Rect(x, y, w, h).Contains(pt) then
    begin
      Result := Item;
      InExpand := pt.x < x + Offset;
      Exit;
    end;
    y += h;
    if ItemOpen(Item) then
    for i := 0 to Item.ChildCount - 1 do
    begin
      CheckItem(Item.Children[i], Offset + 16);
      if Result <> nil then Exit;
    end;
  end;
  var i: Integer;
  var r: TG2Rect;
begin
  Result := nil;
  r := _ListFrame;
  //r.r := r.r - _ScrollV.Frame.w;
  x := r.l;
  y := r.t - _ScrollV.GetPosAbsolute;
  h := _ItemHeight;
  w := r.w;
  for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
  if App.Scene2DData.Scene.Entities[i].Parent = nil then
  begin
    CheckItem(App.Scene2DData.Scene.Entities[i], 16);
    if Result <> nil then Exit;
  end;
end;

function TUIWorkspaceScene2DStructure.ItemOpen(
  const Item: TG2Scene2DEntity
): Boolean;
  var ItemData: TScene2DEntityData;
  var i: Integer;
begin
  ItemData := TScene2DEntityData(Item.UserData);
  for i := 0 to ItemData.OpenStructure.Count - 1 do
  if ItemData.OpenStructure[i] = Pointer(Self) then Exit(True);
  Result := False;
end;

function TUIWorkspaceScene2DStructure.GetContentSize: TG2Float;
  procedure CheckItem(const Item: TG2Scene2DEntity);
    var i: Integer;
  begin
    Result += _ItemHeight;
    if ItemOpen(Item) then
    for i := 0 to Item.ChildCount - 1 do
    CheckItem(Item.Children[i]);
  end;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
  if App.Scene2DData.Scene.Entities[i].Parent = nil then
  CheckItem(App.Scene2DData.Scene.Entities[i]);
end;

procedure TUIWorkspaceScene2DStructure.BtnSaveScene;
  var dm: TG2DataManager;
  var ScenePath: String;
begin
  if not App.Project.Open
  or App.Scene2DData.Scene.Simulate then Exit;
  ScenePath := App.Project.FilePath + G2PathSep + 'assets' + G2PathSep + App.Scene2DData.ScenePath;
  if (Length(App.Scene2DData.ScenePath) > 0)
  and FileExists(ScenePath) then
  begin
    dm := TG2DataManager.Create(ScenePath, dmWrite);
    try
      App.Scene2DData.Scene.Save(dm);
    finally
      dm.Free;
    end;
  end
  else
  begin
    BtnSaveSceneAs;
  end;
end;

procedure TUIWorkspaceScene2DStructure.BtnSaveSceneAs;
  var sd: TSaveDialog;
  var dm: TG2DataManager;
begin
  sd := TSaveDialog.Create(nil);
  sd.DefaultExt := '.g2s2d';
  try
    if sd.Execute then
    begin
      dm := TG2DataManager.Create(sd.FileName, dmWrite);
      try
        App.Scene2DData.ScenePath := ExtractFileName(sd.FileName);
        App.Scene2DData.Scene.Save(dm);
      finally
        dm.Free;
      end;
    end;
  finally
    sd.Free;
  end;
end;

procedure TUIWorkspaceScene2DStructure.BtnLoadScene;
begin
  App.UI.OverlayAssetSelect.Open(TAssetScene2D, @App.Scene2DData.LoadScene);
end;

procedure TUIWorkspaceScene2DStructure.BtnClearScene;
begin
  App.Scene2DData.ClearScene;
end;

procedure TUIWorkspaceScene2DStructure.BtnSimulate;
begin
  App.Scene2DData.Simulate;
  if App.Scene2DData.Scene.Simulate then
  _BtnSimulate.Icon := App.UI.TexStop
  else
  _BtnSimulate.Icon := App.UI.TexPlay;
end;

procedure TUIWorkspaceScene2DStructure.UpdatePopUp;
begin
  _PopUp.Clear;
  if App.Scene2DData.Selection.Count > 0 then
  begin
    if App.Scene2DData.Selection.Count = 1 then
    _PopUp.AddButton('Save Prefab', @OnSavePrefab);
    _PopUp.AddButton('Copy', @OnCopyEntity);
    _PopUp.AddButton('Delete', @OnDeleteEntity);
  end;
end;

procedure TUIWorkspaceScene2DStructure.OnCopyEntity;
begin
  App.Scene2DData.CopySelectedEntity;
end;

procedure TUIWorkspaceScene2DStructure.OnDeleteEntity;
  var i: Integer;
  var e: TG2Scene2DEntity;
begin
  for i := App.Scene2DData.Selection.Count - 1 downto 0 do
  begin
    e := App.Scene2DData.Selection[i];
    App.Scene2DData.DeleteEntity(e);
  end;
end;

procedure TUIWorkspaceScene2DStructure.OnSavePrefab;
begin
  App.Scene2DData.SavePrefab;
end;

procedure TUIWorkspaceScene2DStructure.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var sm: TUIWorkspaceFixedSplitterMulti;
  var b: TUIWorkspaceCustomButton;
begin
  inherited OnInitialize;
  WorkspaceList.Add(Self);
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _Menu := TUIWorkspaceCustom.Create;
  _Menu.Parent := Self;
  _ItemHeight := App.UI.Font1.TextHeight('A') + 8;

  p := _Menu.Panel;
  p.Client.SpacingTop := 2;
  sm := p.Client.SplitterM(7);
  sm.SizingH := csFixed;
  sm.EqualSized := False;

  b := sm.Subset[0].Button('');
  b.Icon := App.UI.TexFileSave;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Save Scene';
  b.OnClick := @BtnSaveScene;

  b := sm.Subset[1].Button('');
  b.Icon := App.UI.TexFileSaveAs;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Save Scene (Select File)';
  b.OnClick := @BtnSaveSceneAs;

  b := sm.Subset[2].Button('');
  b.Icon := App.UI.TexFileOpen;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Load Scene';
  b.OnClick := @BtnLoadScene;

  b := sm.Subset[3].Button('');
  b.Icon := App.UI.TexDelete;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Clear Scene';
  b.OnClick := @BtnClearScene;

  p := sm.Subset[4].Panel;
  p.SizingH := csFixed;
  p.Width := 8;

  b := sm.Subset[5].Button('');
  b.Icon := App.UI.TexPlay;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Simulate';
  b.OnClick := @BtnSimulate;
  _BtnSimulate := b;

  _PopUp := TOverlayPopUp.Create;
end;

procedure TUIWorkspaceScene2DStructure.OnFinalize;
  var i: Integer;
begin
  _PopUp.Free;
  if App.Scene2DData.Scene <> nil then
  for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
  TScene2DEntityData(App.Scene2DData.Scene.Entities[i].UserData).OpenStructure.Remove(Self);
  WorkspaceList.Remove(Self);
  inherited OnFinalize;
end;

procedure TUIWorkspaceScene2DStructure.OnAdjust;
  var r: TG2Rect;
begin
  _MenuFrame := Frame;
  _MenuFrame.b := _MenuFrame.t + 32;
  _ListFrame := Frame;
  _ListFrame.t := _ListFrame.t + _MenuFrame.h;
  r := _ListFrame; r.l := r.r - 18;
  _ListFrame.r := _ListFrame.r - r.w;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.ParentSize := r.h;
  _Menu.Frame := _MenuFrame;
end;

procedure TUIWorkspaceScene2DStructure.OnRender;
  var x, y, w, h: Single;
  procedure RenderItem(const Item: TG2Scene2DEntity; const Offset: Integer);
    var i: Integer;
    var s: String;
    var ItemData: TScene2DEntityData;
    var Open: Boolean;
  begin
    ItemData := TScene2DEntityData(Item.UserData);
    Open := ItemOpen(Item);
    if ItemData.Selected then
    g2.PrimRect(x, y, w, h, App.UI.GetColorSecondary(0.5, 0.5));
    App.UI.Font1.Print(
      Round(x + Offset),
      Round(y + (h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, $ffffffff, Item.Name, bmNormal, tfPoint
    );
    if Item.ChildCount > 0 then
    begin
      if Open then s := '-' else s := '+';
      App.UI.Font1.Print(
        Round(x + Offset - 8 - App.UI.Font1.TextWidth(s) * 0.5),
        Round(y + (h - App.UI.Font1.TextHeight('A')) * 0.5),
        1, 1, $ffffffff, s, bmNormal, tfPoint
      );
    end;
    y += h;
    if Open then
    for i := 0 to Item.ChildCount - 1 do
    RenderItem(Item.Children[i], Offset + 16);
  end;
  var i: Integer;
  var r: TG2Rect;
begin
  r := _ListFrame;
  //r.r := r.r - _ScrollV.Frame.w;
  g2.PrimRect(
    r.x, r.y, r.w, r.h,
    App.UI.GetColorPrimary(0.2)
  );
  App.UI.PushClipRect(r);
  x := r.l;
  y := r.t - _ScrollV.GetPosAbsolute;
  h := _ItemHeight;
  w := r.w;
  for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
  if App.Scene2DData.Scene.Entities[i].Parent = nil then
  RenderItem(App.Scene2DData.Scene.Entities[i], 16);
  App.UI.PopClipRect;
  _ScrollV.Render;
end;

procedure TUIWorkspaceScene2DStructure.OnUpdate;
  var Item0, Item1: TG2Scene2DEntity;
  var InExpand0, InExpand1: Boolean;
  var Drop: TOverlayDrop;
begin
  if (App.UI.Overlay = nil)
  and g2.MouseDown[G2MB_Left]
  and Frame.Contains(g2.MouseDownPos[G2MB_Left]) then
  begin
    Item0 := PtInItem(g2.MouseDownPos[G2MB_Left], InExpand0);
    Item1 := PtInItem(g2.MousePos, InExpand1);
    if (Item0 <> nil)
    and (Item0 <> Item1)
    and not InExpand0 then
    begin
      Drop := TOverlayDropScene2DStructureItem.Create;
      Drop.Initialzie;
      Drop.Name := Item0.Name;
    end;
  end;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.Update;
end;

procedure TUIWorkspaceScene2DStructure.OnMouseDown(const Button, x, y: Integer);
  var Item: TG2Scene2DEntity;
  var InExpand: Boolean;
  var ItemData: TScene2DEntityData;
  var r: TG2Rect;
  var i, ItemID, SelID: TG2IntS32;
begin
  r := _ListFrame;
  //r.r := r.r - _ScrollV.Frame.w;
  if r.Contains(x, y) then
  case Button of
    G2MB_Left:
    begin
      Item := PtInItem(G2Vec2(x, y), InExpand);
      if (Item <> nil) then
      begin
        ItemData := TScene2DEntityData(Item.UserData);
        if InExpand then
        begin
          if ItemOpen(Item) then
          ItemData.OpenStructure.Remove(Self)
          else
          ItemData.OpenStructure.Add(Self);
        end
        else
        begin
          if g2.KeyDown[G2K_CtrlR] or g2.KeyDown[G2K_CtrlL] then
          begin
            if ItemData.Selected then
            begin
              App.Scene2DData.SelectionUpdateStart;
              App.Scene2DData.Selection.Remove(Item);
              App.Scene2DData.SelectionUpdateEnd;
            end
            else
            begin
              App.Scene2DData.SelectionUpdateStart;
              App.Scene2DData.Selection.Add(Item);
              App.Scene2DData.SelectionUpdateEnd;
            end;
          end
          else if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
          begin
            if App.Scene2DData.Selection.Count > 0 then
            begin
              SelID := -1;
              for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
              if App.Scene2DData.Scene.Entities[i] = App.Scene2DData.Selection.Last then
              begin
                SelID := i;
                Break;
              end;
              for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
              if App.Scene2DData.Scene.Entities[i] = Item then
              begin
                ItemID := i;
                Break;
              end;
              if (SelID > -1) and (ItemID > -1) then
              begin
                App.Scene2DData.SelectionUpdateStart;
                if ItemID > SelID then
                begin
                  for i := SelID + 1 to ItemID do
                  begin
                    if not TScene2DEntityData(App.Scene2DData.Scene.Entities[i].UserData).Selected
                    and (App.Scene2DData.Scene.Entities[i].Parent = Item.Parent) then
                    App.Scene2DData.Selection.Add(App.Scene2DData.Scene.Entities[i]);
                  end;
                end
                else
                begin
                  for i := SelID - 1 downto ItemID do
                  begin
                    if not TScene2DEntityData(App.Scene2DData.Scene.Entities[i].UserData).Selected
                    and (App.Scene2DData.Scene.Entities[i].Parent = Item.Parent) then
                    App.Scene2DData.Selection.Add(App.Scene2DData.Scene.Entities[i]);
                  end;
                  App.Scene2DData.Selection.Add(Item);
                end;
                App.Scene2DData.SelectionUpdateEnd;
              end
              else
              begin
                if not ItemData.Selected then
                begin
                  App.Scene2DData.SelectionUpdateStart;
                  App.Scene2DData.Selection.Clear;
                  App.Scene2DData.Selection.Add(Item);
                  App.Scene2DData.SelectionUpdateEnd;
                end;
              end;
            end
            else
            begin
              App.Scene2DData.SelectionUpdateStart;
              App.Scene2DData.Selection.Clear;
              i := 0;
              while (App.Scene2DData.Scene.EntityCount > i)
              and (App.Scene2DData.Scene.Entities[i] <> Item) do
              begin
                if App.Scene2DData.Scene.Entities[i].Parent = Item.Parent then
                App.Scene2DData.Selection.Add(App.Scene2DData.Scene.Entities[i]);
                Inc(i);
              end;
              App.Scene2DData.Selection.Add(Item);
              App.Scene2DData.SelectionUpdateEnd;
            end;
          end
          else if not ItemData.Selected then
          begin
            App.Scene2DData.SelectionUpdateStart;
            App.Scene2DData.Selection.Clear;
            App.Scene2DData.Selection.Add(Item);
            App.Scene2DData.SelectionUpdateEnd;
          end;
        end;
      end
      else
      begin
        App.Scene2DData.SelectionUpdateStart;
        App.Scene2DData.Selection.Clear;
        App.Scene2DData.SelectionUpdateEnd;
      end;
    end;
  end;
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceScene2DStructure.OnMouseUp(const Button, x, y: Integer);
  var Item, ItemPrev: TG2Scene2DEntity;
  var InExpand, InExpandPrev: Boolean;
begin
  case Button of
    G2MB_Left:
    begin
      Item := PtInItem(G2Vec2(x, y), InExpand);
      ItemPrev := PtInItem(g2.MouseDownPos[Button], InExpandPrev);
      if (App.Scene2DData.Selection.Count > 1)
      and (not g2.KeyDown[G2K_CtrlL])
      and (not g2.KeyDown[G2K_CtrlR])
      and (not g2.KeyDown[G2K_ShiftL])
      and (not g2.KeyDown[G2K_ShiftR])
      and (Item <> nil)
      and (Item = ItemPrev)
      and (not InExpand)
      and (InExpand = InExpandPrev) then
      begin
        App.Scene2DData.SelectionUpdateStart;
        App.Scene2DData.Selection.Clear;
        App.Scene2DData.Selection.Add(Item);
        App.Scene2DData.SelectionUpdateEnd;
      end;
    end;
    G2MB_Right:
    begin
      Item := PtInItem(G2Vec2(x, y), InExpand);
      ItemPrev := PtInItem(g2.MouseDownPos[Button], InExpandPrev);
      if (Item <> nil)
      and (Item = ItemPrev)
      and (not InExpand)
      and (InExpand = InExpandPrev)
      and (App.Scene2DData.Selection.Count > 0)
      then
      begin
        UpdatePopUp;
        _PopUp.Show(G2Vec2(x, y));
      end;
    end;
  end;
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceScene2DStructure.OnScroll(const y: Integer);
begin
  _ScrollV.Scroll(y);
end;

procedure TUIWorkspaceScene2DStructure.OnDragDropRelase(
  const Drop: TOverlayDrop
);
  var Entity: TG2Scene2DEntity;
  var InExpand: Boolean;
  var i: Integer;
begin
  Entity := PtInItem(g2.MousePos, InExpand);
  if (Entity <> nil) then
  begin
    for i := 0 to App.Scene2DData.Selection.Count - 1 do
    if Entity = App.Scene2DData.Selection[i] then Exit;
    for i := 0 to App.Scene2DData.Selection.Count - 1 do
    App.Scene2DData.Selection[i].Parent := nil;
    for i := 0 to App.Scene2DData.Selection.Count - 1 do
    App.Scene2DData.Selection[i].Parent := Entity;
  end
  else
  begin
    for i := 0 to App.Scene2DData.Selection.Count - 1 do
    App.Scene2DData.Selection[i].Parent := nil;
  end;
end;

class constructor TUIWorkspaceScene2DStructure.Create;
begin
  WorkspaceList.Clear;
end;

class function TUIWorkspaceScene2DStructure.GetWorkspaceName: AnsiString;
begin
  Result := 'Structure';
end;

class function TUIWorkspaceScene2DStructure.GetWorkspacePath: AnsiString;
begin
  Result := 'Scene2D'
end;

function TUIWorkspaceScene2DStructure.GetMinWidth: Single;
begin
  Result := 160;
end;

function TUIWorkspaceScene2DStructure.GetMinHeight: Single;
begin
  Result := 64;
end;

procedure TUIWorkspaceScene2DStructure.OnCreateEntity(
  const Entity: TG2Scene2DEntity
);
begin

end;

procedure TUIWorkspaceScene2DStructure.OnDeleteEntity(
  const Entity: TG2Scene2DEntity
);
begin

end;

function TUIWorkspaceScene2DStructure.CanDragDrop(
  const Drop: TOverlayDrop
): Boolean;
begin
  Result := Drop is TOverlayDropScene2DStructureItem;
end;

//TUIWorkspaceScene2DStructure END

//TUIWorkspaceScene2D BEGIN
procedure TUIWorkspaceScene2D.OnCreateEntity;
  var e: TG2Scene2DEntity;
begin
  e := App.Scene2DData.CreateEntity(G2Transform2(_Display.CoordToDisplay(_PopUp.Position), G2Rotation2));
  if App.Scene2DData.Selection.Count = 0 then
  begin
    App.Scene2DData.SelectJoint := nil;
    App.Scene2DData.Editor := nil;
    App.Scene2DData.SelectionUpdateStart;
    App.Scene2DData.Selection.Add(e);
    App.Scene2DData.SelectionUpdateEnd;
  end;
end;

procedure TUIWorkspaceScene2D.OnCreatePrefab;
begin
  _PrefabCreatePos := _Display.CoordToDisplay(_PopUp.Position);
  App.UI.OverlayAssetSelect.Open(TAssetPrefab2D, @OnSelectPrefab);
end;

procedure TUIWorkspaceScene2D.OnSelectPrefab(const PrefabName: String);
begin
  App.Scene2DData.CreatePrefab(G2Transform2(_PrefabCreatePos, G2Rotation2), PrefabName);
end;

procedure TUIWorkspaceScene2D.OnCreateJointDistance;
begin
  App.Scene2DData.CreateJointDistance(_Display.CoordToDisplay(_PopUp.Position));
end;

procedure TUIWorkspaceScene2D.OnCreateJointRevolute;
begin
  App.Scene2DData.CreateJointRevolute(_Display.CoordToDisplay(_PopUp.Position));
end;

procedure TUIWorkspaceScene2D.OnSavePrefab;
begin
  App.Scene2DData.SavePrefab;
end;

procedure TUIWorkspaceScene2D.OnCopyEntity;
begin
  App.Scene2DData.CopySelectedEntity;
end;

procedure TUIWorkspaceScene2D.OnPasteEntity;
begin
  App.Scene2DData.PasteEntity(_Display.CoordToDisplay(g2.MousePos));
end;

procedure TUIWorkspaceScene2D.OnDeleteEntity;
  var i: Integer;
  var e: TG2Scene2DEntity;
begin
  for i := App.Scene2DData.Selection.Count - 1 downto 0 do
  begin
    e := App.Scene2DData.Selection[i];
    App.Scene2DData.DeleteEntity(e);
  end;
end;

function TUIWorkspaceScene2D.PtInSelRotate(const pt: TG2Vec2): Boolean;
  var p: TG2Vec2;
  var d: TG2Float;
begin
  if App.Scene2DData.Selection.Count = 0 then Exit(False);
  p := _Display.CoordToScreen(App.Scene2DData.sxf.p);
  d := (p - pt).Len;
  Result := (d > 100) and (d < 108);
end;

function TUIWorkspaceScene2D.PtInSelDrag(const pt: TG2Vec2): Boolean;
  var p: TG2Vec2;
begin
  if App.Scene2DData.Selection.Count = 0 then Exit(False);
  p := _Display.CoordToScreen(App.Scene2DData.sxf.p);
  Result := G2Rect(p.x + 4, p.y + 4, 46, 46).Contains(pt);
end;

function TUIWorkspaceScene2D.PtInSelDragX(const pt: TG2Vec2): Boolean;
  var p: TG2Vec2;
begin
  if App.Scene2DData.Selection.Count = 0 then Exit(False);
  p := _Display.CoordToScreen(App.Scene2DData.sxf.p);
  Result := G2Rect(p.x + 8, p.y - 5, 92, 10).Contains(pt);
end;

function TUIWorkspaceScene2D.PtInSelDragY(const pt: TG2Vec2): Boolean;
  var p: TG2Vec2;
begin
  if App.Scene2DData.Selection.Count = 0 then Exit(False);
  p := _Display.CoordToScreen(App.Scene2DData.sxf.p);
  Result := G2Rect(p.x - 5, p.y + 8, 10, 92).Contains(pt);
end;

procedure TUIWorkspaceScene2D.UpdatePopUp;
begin
  _PopUp.Clear;
  _PopUp.AddButton('Create/Entity', @OnCreateEntity);
  _PopUp.AddButton('Create/Prefab', @OnCreatePrefab);
  _PopUp.AddButton('Create/Joint/Distance Joint', @OnCreateJointDistance);
  _PopUp.AddButton('Create/Joint/Revolute Joint', @OnCreateJointRevolute);
  if App.Scene2DData.Selection.Count = 1 then
  _PopUp.AddButton('Save Prefab', @OnSavePrefab);
  if App.Scene2DData.Selection.Count > 0 then
  _PopUp.AddButton('Copy', @OnCopyEntity);
  if Clipboard.HasFormat(App.cbf_scene2d_object) then
  _PopUp.AddButton('Paste', @OnPasteEntity);
  if App.Scene2DData.Selection.Count > 0 then
  _PopUp.AddButton('Delete', @OnDeleteEntity);
end;

procedure TUIWorkspaceScene2D.OnInitialize;
begin
  _Dragging := False;
  _DraggingSelectionPosX := False;
  _DraggingSelectionPosY := False;
  _DraggingSelectionRot := False;
  _TargetZoom := 1;
  _Display := TG2Display2D.Create;
  _Display.Position := G2Vec2(0, 0);
  _Display.Width := 10;
  _Display.Height := 10;
  _PopUp := TOverlayPopUp.Create;
  _ResetCamFrame := G2Rect(-128 - 8, 8, 128, 24);
end;

procedure TUIWorkspaceScene2D.OnFinalize;
begin
  _PopUp.Free;
  _Display.Free;
end;

procedure TUIWorkspaceScene2D.OnAdjust;
begin
  _Display.ViewPort := Frame;
end;

procedure TUIWorkspaceScene2D.OnRender;
  var r: TG2Rect;
  var i: Integer;
  var pt0, pt1: TPoint;
  var e: TG2Scene2DEntity;
  var p, v0, v1: TG2Vec2;
  var c, c1: TG2Color;
  var d: TG2Float;
  var str: String;
begin
  r := Frame;
  g2.PrimRect(
    r.x, r.y, r.w, r.h, $ffc0c0c0
  );
  g2.PicRect(
    r.x, r.y, r.w, r.h,
    0, 0, r.w / App.UI.TexChecker.Width * 0.2, r.h / App.UI.TexChecker.Height * 0.2,
    $ff303030, App.UI.TexChecker, bmAdd
  );
  App.UI.PushClipRect(r);
  App.Scene2DData.Scene.Render(_Display);
  App.Scene2DData.Scene.DebugDraw(_Display);
  App.Scene2DData.Render(_Display);
  for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
  begin
    e := App.Scene2DData.Scene.Entities[i];
    p := _Display.CoordToScreen(e.Transform.p);
    App.UI.Font1.Print(p.x - App.UI.Font1.TextWidth(e.Name) * 0.5, p.y - App.UI.Font1.TextHeight('A'), 1, 1, $ff000000, e.Name, bmNormal, tfPoint);
  end;
  if (App.Scene2DData.Selection.Count > 0)
  and (App.Scene2DData.Editor = nil) then
  begin
    p := _Display.CoordToScreen(App.Scene2DData.sxf.p);
    if PtInSelRotate(g2.MousePos) then c := $ff20ff20 else c := $ff00cc00;
    App.UI.DrawCircleBorder(p, 104, 4, 64, c);
    if PtInSelDrag(g2.MousePos) then c := $80ffff00 else c := $40cccc00;
    g2.PrimRect(p.x, p.y, 50, 50, c);
    g2.PrimRectHollow(p.x, p.y, 50, 50, $ffffff00);
    if PtInSelDragX(g2.MousePos) then c := $ffff2020 else c := $ffcc0000;
    App.UI.DrawArrow(p, p + G2Vec2(100, 0), 6, c);
    if PtInSelDragY(g2.MousePos) then c := $ff4040ff else c := $ff0000cc;
    App.UI.DrawArrow(p, p + G2Vec2(0, 100), 6, c);
    g2.PrimRect(p.x - 4, p.y - 4, 8, 8, $ffffff00);
  end;
  if App.Scene2DData.Scene.GridEnable then
  begin
    r := Frame;
    r.h := 8;
    g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.2));
    r.y := Frame.b - r.h;
    g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.2));
    r := Frame;
    r.w := 8;
    g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.2));
    r.x := Frame.r - r.w;
    g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(0.2));
    c := App.UI.GetColorPrimary(0.8);
    c1 := App.UI.GetColorPrimary(0.4);
    v0 := _Display.CoordToDisplay(G2Vec2(Frame.l + 8, Frame.t + 8));
    v1 := _Display.CoordToDisplay(G2Vec2(Frame.r - 8, Frame.t + 8));
    v0 := App.Scene2DData.Scene.AdjustToGrid(v0);
    v1 := App.Scene2DData.Scene.AdjustToGrid(v1);
    pt0 := App.Scene2DData.Scene.GridPos(v0);
    pt1 := App.Scene2DData.Scene.GridPos(v1);
    v0 := _Display.CoordToScreen(v0);
    v1 := _Display.CoordToScreen(v1);
    if pt1.x >= pt0.x then
    begin
      while pt1.x > pt0.x + 100 do
      begin
        pt1.x := pt1.x div 10;
        pt0.x := pt0.x div 10;
      end;
      g2.PrimBegin(ptLines, bmNormal);
      for i := pt0.x to pt1.x do
      begin
        if pt1.x > pt0.x then
        d := (i - pt0.x) / (pt1.x - pt0.x) * (v1.x - v0.x) + v0.x
        else
        d := v0.x;
        if (d > Frame.l + 8) and (d < Frame.r - 8) then
        begin
          g2.PrimAdd(d, Frame.t, c);
          g2.PrimAdd(d, Frame.t + 8, c1);
          g2.PrimAdd(d, Frame.b - 8, c1);
          g2.PrimAdd(d, Frame.b, c);
        end;
      end;
      g2.PrimEnd;
    end;
    v0 := _Display.CoordToDisplay(G2Vec2(Frame.l + 8, Frame.t + 8));
    v1 := _Display.CoordToDisplay(G2Vec2(Frame.l + 8, Frame.b - 8));
    v0 := App.Scene2DData.Scene.AdjustToGrid(v0);
    v1 := App.Scene2DData.Scene.AdjustToGrid(v1);
    pt0 := App.Scene2DData.Scene.GridPos(v0);
    pt1 := App.Scene2DData.Scene.GridPos(v1);
    v0 := _Display.CoordToScreen(v0);
    v1 := _Display.CoordToScreen(v1);
    if pt1.y >= pt0.y then
    begin
      while pt1.y > pt0.y + 100 do
      begin
        pt1.y := pt1.y div 10;
        pt0.y := pt0.y div 10;
      end;
      g2.PrimBegin(ptLines, bmNormal);
      for i := pt0.y to pt1.y do
      begin
        if pt1.y > pt0.y then
        d := (i - pt0.y) / (pt1.y - pt0.y) * (v1.y - v0.y) + v0.y
        else
        d := v0.y;
        if (d > Frame.t + 8) and (d < Frame.b - 8) then
        begin
          g2.PrimAdd(Frame.l, d, c);
          g2.PrimAdd(Frame.l + 8, d, c1);
          g2.PrimAdd(Frame.r - 8, d, c1);
          g2.PrimAdd(Frame.r, d, c);
        end;
      end;
      g2.PrimEnd;
    end;
  end;
  if App.Scene2DData.Editor = nil then
  begin
    r := _ResetCamFrame;
    r.x := r.x + _Display.ViewPort.Right;
    r.y := r.y + _Display.ViewPort.Top;
    if r.Contains(g2.MousePos) then
    begin
      if g2.MouseDown[G2MB_Left]
      and r.Contains(g2.MouseDownPos[G2MB_Left]) then
      begin
        c := $ff404040;
      end
      else
      begin
        c := $ffa0a0a0;
      end;
    end
    else
    begin
      c := $ff808080;
    end;
    App.UI.DrawSpotFrame(r, 8, c);
    str := 'Reset Camera';
    App.UI.Font1.Print(
      r.x + (r.w - App.UI.Font1.TextWidth(str)) * 0.5,
      r.y + (r.h - App.UI.Font1.TextHeight(str)) * 0.5,
      1, 1, $ff000000, str, bmNormal, tfPoint
    );
  end;
  App.UI.PopClipRect;
end;

procedure TUIWorkspaceScene2D.OnUpdate;
  var cp: TG2Vec2;
  var xf, xf1: TG2Transform2;
  var r0: TG2Rotation2;
  var i: Integer;
begin
  _Display.Zoom := G2LerpFloat(_Display.Zoom, _TargetZoom, 0.2);
  cp := g2.MousePos;
  if _Dragging then
  begin
    _Display.Position := _Display.Position - (_Display.CoordToDisplay(cp) - _Display.CoordToDisplay(_DragPos));
    _DragPos := cp;
  end;
  if _DraggingSelectionRot
  or _DraggingSelectionPosX
  or _DraggingSelectionPosY then
  begin
    xf := G2Transform2;
    xf.p := _Display.CoordToScreen(App.Scene2DData.sxf.p);
    xf.r := App.Scene2DData.sxf.r;
    if _DraggingSelectionPosX then
    begin
      xf.p.x := cp.x + _DraggingSelectionOffset.x;
    end;
    if _DraggingSelectionPosY then
    begin
      xf.p.y := cp.y + _DraggingSelectionOffset.y;
    end;
    if _DraggingSelectionRot then
    begin
      r0.AxisX := (cp - xf.p).Norm;
      xf.r.Angle := r0.Angle - _DraggingSelectionAngle;
      App.Scene2DData.sxf.r := xf.r;
    end;
    xf.p := App.Scene2DData.Scene.AdjustToGrid(_Display.CoordToDisplay(xf.p));
    for i := 0 to App.Scene2DData.Selection.Count - 1 do
    if (App.Scene2DData.Selection[i].Parent = nil)
    or (not TScene2DEntityData(App.Scene2DData.Selection[i].Parent.UserData).Selected) then
    begin
      G2Transform2Mul(
        @xf1,
        @TScene2DEntityData(App.Scene2DData.Selection[i].UserData).oxf,
        @xf
      );
      App.Scene2DData.Selection[i].Transform := xf1;
    end;
    App.Scene2DData.UpdateSelectionPos;
  end;
  if (App.Scene2DData.Editor <> nil)
  and Frame.Contains(g2.MousePos) then
  App.Scene2DData.Editor.Update(_Display);
end;

procedure TUIWorkspaceScene2D.OnMouseDown(const Button, x, y: Integer);
  var r: TG2Rotation2;
begin
  case Button of
    G2MB_Left:
    begin
      if (App.Scene2DData.Selection.Count > 0)
      and (App.Scene2DData.Editor = nil) then
      begin
        if PtInSelDragX(G2Vec2(x, y)) then
        begin
          _DraggingSelectionPosX := True;
          _DraggingSelectionPos := G2Vec2(x, y);
          _DraggingSelectionOffset := _Display.CoordToScreen(App.Scene2DData.sxf.p) - _DraggingSelectionPos;
        end
        else if PtInSelDragY(G2Vec2(x, y)) then
        begin
          _DraggingSelectionPosY := True;
          _DraggingSelectionPos := G2Vec2(x, y);
          _DraggingSelectionOffset := _Display.CoordToScreen(App.Scene2DData.sxf.p) - _DraggingSelectionPos;
        end
        else if PtInSelDrag(G2Vec2(x, y)) then
        begin
          _DraggingSelectionPosX := True;
          _DraggingSelectionPosY := True;
          _DraggingSelectionPos := G2Vec2(x, y);
          _DraggingSelectionOffset := _Display.CoordToScreen(App.Scene2DData.sxf.p) - _DraggingSelectionPos;
        end
        else if PtInSelRotate(G2Vec2(x, y)) then
        begin
          _DraggingSelectionRot := True;
          _DraggingSelectionPos := G2Vec2(x, y);
          _DraggingSelectionOffset := _Display.CoordToScreen(App.Scene2DData.sxf.p) - _DraggingSelectionPos;
          if _DraggingSelectionOffset.LenSq > G2EPS then
          begin
            r.AxisX := -_DraggingSelectionOffset.Norm;
            _DraggingSelectionAngle := r.Angle - App.Scene2DData.sxf.r.Angle;
          end
          else
          begin
            _DraggingSelectionAngle := 0;
          end;
        end;
      end;
    end;
    G2MB_Middle:
    begin
      _Dragging := True;
      _DragPos := G2Vec2(x, y);
    end;
  end;
  if App.Scene2DData.Editor <> nil then
  App.Scene2DData.Editor.MouseDown(_Display, Button, x, y);
end;

procedure TUIWorkspaceScene2D.OnMouseUp(const Button, x, y: Integer);
  var v: TG2Vec2;
  var r: TG2Rect;
begin
  case Button of
    G2MB_Left:
    begin
      if App.Scene2DData.Editor = nil then
      begin
        if _DraggingSelectionPosX
        or _DraggingSelectionPosY
        or _DraggingSelectionRot then
        begin
          _DraggingSelectionPosX := False;
          _DraggingSelectionPosY := False;
          _DraggingSelectionRot := False;
        end
        else
        begin
          if Frame.Contains(x, y)
          and Frame.Contains(g2.MouseDownPos[Button]) then
          begin
            r := _ResetCamFrame;
            r.x := r.x + _Display.ViewPort.Right;
            r.y := r.y + _Display.ViewPort.Top;
            if r.Contains(x, y)
            and (r.Contains(g2.MouseDownPos[Button])) then
            begin
              _TargetZoom := 1;
              _Display.Position := G2Vec2(0, 0);
            end
            else if ((G2Vec2(x, y) - g2.MouseDownPos[Button]).Len < 2) then
            begin
              App.Scene2DData.MouseClick(_Display, Button, x, y);
            end;
          end;
        end;
      end;
    end;
    G2MB_Right:
    begin
      if App.Scene2DData.Editor = nil then
      begin
        if Frame.Contains(g2.MouseDownPos[Button])
        and Frame.Contains(x, y) then
        begin
          UpdatePopUp;
          _PopUp.Show(G2Vec2(x, y));
        end;
      end;
    end;
    G2MB_Middle:
    begin
      _Dragging := False;
    end;
  end;
  if (App.Scene2DData.Editor <> nil)
  and Frame.Contains(g2.MouseDownPos[Button]) then
  App.Scene2DData.Editor.MouseUp(_Display, Button, x, y);
end;

procedure TUIWorkspaceScene2D.OnKeyDown(const Key: Integer);
begin
  if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
  begin
    if Key = G2K_C then OnCopyEntity
    else if Key = G2K_V then OnPasteEntity;
  end;
end;

procedure TUIWorkspaceScene2D.OnScroll(const y: Integer);
begin
  if y > 0 then _TargetZoom *= 1.2 else _TargetZoom /= 1.2;
  _DraggingSelectionPosX := False;
  _DraggingSelectionPosY := False;
  _DraggingSelectionRot := False;
end;

class function TUIWorkspaceScene2D.GetWorkspaceName: AnsiString;
begin
  Result := 'Viewport';
end;

class function TUIWorkspaceScene2D.GetWorkspacePath: AnsiString;
begin
  Result := 'Scene2D';
end;

function TUIWorkspaceScene2D.GetMinWidth: Single;
begin
  Result := 64;
end;

function TUIWorkspaceScene2D.GetMinHeight: Single;
begin
  Result := 64;
end;
//TUIWorkspaceScene2D END

//TUIWorkspaceParticles2DList BEGIN
function TUIWorkspaceParticles2DList.GetContentSize: TG2Float;
  procedure CalculateParticleObjectSize(const e: TParticleObject);
    var i: Integer;
  begin
    Result += _ItemHeight + _ItemSpacing;
    if (
      (e is TParticleEffect) and (TParticleEffect(e).IsOpen)
    )
    or (
      (e is TParticleEmitter) and (TParticleEmitter(e).IsOpen)
    ) then
    for i := 0 to e.Emitters.Count - 1 do
    CalculateParticleObjectSize(e.Emitters[i]);
  end;
  var i: Integer;
begin
  Result := _ItemSpacing;
  for i := 0 to App.ParticleData.Effects.Count - 1 do
  CalculateParticleObjectSize(App.ParticleData.Effects[i]);
end;

procedure TUIWorkspaceParticles2DList.BtnSaveLib;
  var sd: TSaveDialog;
begin
  sd := TSaveDialog.Create(nil);
  sd.DefaultExt := 'g2fxl';
  g2.Pause := True;
  try
    if sd.Execute then
    App.ParticleData.SaveLib(sd.FileName);
  finally
    g2.Pause := False;
    sd.Free;
  end;
end;

procedure TUIWorkspaceParticles2DList.BtnLoadLib;
  var od: TOpenDialog;
begin
  od := TOpenDialog.Create(nil);
  od.DefaultExt := 'g2fxl';
  g2.Pause := True;
  try
    if od.Execute then
    App.ParticleData.LoadLib(od.FileName);
  finally
    g2.Pause := False;
    od.Free;
  end;
end;

procedure TUIWorkspaceParticles2DList.BtnClearLib;
begin
  App.ParticleData.Clear;
end;

procedure TUIWorkspaceParticles2DList.BtnNewEffect;
begin
  App.ParticleData.EffectAdd;
end;

procedure TUIWorkspaceParticles2DList.BtnDeleteEffect;
  var Effect: TParticleEffect;
begin
  if (App.ParticleData.Selection = nil)
  or not (App.ParticleData.Selection is TParticleEffect) then Exit;
  App.ParticleData.EffectDelete(TParticleEffect(App.ParticleData.Selection));
end;

procedure TUIWorkspaceParticles2DList.BtnNewEmitter;
begin
  App.ParticleData.EmitterAdd;
end;

procedure TUIWorkspaceParticles2DList.BtnDeleteEmitter;
  var Emitter: TParticleEmitter;
begin
  if (App.ParticleData.Selection = nil)
  or not (App.ParticleData.Selection is TParticleEmitter) then Exit;
  App.ParticleData.EmitterDelete(TParticleEmitter(App.ParticleData.Selection));
end;

procedure TUIWorkspaceParticles2DList.BtnMoveEffectUp;
  var i: Integer;
  var Effect, tmp: TParticleEffect;
begin
  Effect := App.ParticleData.CurrentEffect;
  if Effect <> nil then
  begin
    i := App.ParticleData.Effects.Find(Effect);
    tmp := App.ParticleData.Effects[i - 1];
    App.ParticleData.Effects[i - 1] := Effect;
    App.ParticleData.Effects[i] := tmp;
  end;
end;

procedure TUIWorkspaceParticles2DList.BtnMoveEffectDown;
  var i: Integer;
  var Effect, tmp: TParticleEffect;
begin
  Effect := App.ParticleData.CurrentEffect;
  if Effect <> nil then
  begin
    i := App.ParticleData.Effects.Find(Effect);
    tmp := App.ParticleData.Effects[i + 1];
    App.ParticleData.Effects[i + 1] := Effect;
    App.ParticleData.Effects[i] := tmp;
  end;
end;

procedure TUIWorkspaceParticles2DList.BtnMoveEmitterUp;
  var tmp, Emitter: TParticleEmitter;
  var p: TParticleObject;
  var i: Integer;
begin
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    Emitter := TParticleEmitter(App.ParticleData.Selection);
    if Emitter.ParentEmitter = nil then
    p := Emitter.ParentEffect
    else
    p := Emitter.ParentEmitter;
    i := p.Emitters.Find(Emitter);
    tmp := p.Emitters[i - 1];
    p.Emitters[i - 1] := Emitter;
    p.Emitters[i] := tmp;
  end;
end;

procedure TUIWorkspaceParticles2DList.BtnMoveEmitterDown;
  var tmp, Emitter: TParticleEmitter;
  var p: TParticleObject;
  var i: Integer;
begin
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    Emitter := TParticleEmitter(App.ParticleData.Selection);
    if Emitter.ParentEmitter = nil then
    p := Emitter.ParentEffect
    else
    p := Emitter.ParentEmitter;
    i := p.Emitters.Find(Emitter);
    tmp := p.Emitters[i + 1];
    p.Emitters[i + 1] := Emitter;
    p.Emitters[i] := tmp;
  end;
end;

procedure TUIWorkspaceParticles2DList.BtnExportEffect;
  var Effect: TParticleEffect;
begin
  Effect := App.ParticleData.CurrentEffect;
  if Effect <> nil then App.ParticleData.ExportEffect(Effect);
end;

function TUIWorkspaceParticles2DList.PtInItem(const v: TG2Vec2): TParticleObject;
  var r: TG2Rect;
  function CheckEffect(const Effect: TParticleEffect): TParticleObject;
    function CheckEmitter(const Emitter: TParticleEmitter): TParticleObject;
      var i: Integer;
    begin
      if r.Contains(v) then
      begin
        Result := Emitter;
        Exit;
      end;
      r.y := r.y + _ItemSpacing + _ItemHeight;
      if Emitter.IsOpen then
      begin
        for i := 0 to Emitter.Emitters.Count - 1 do
        begin
          Result := CheckEmitter(Emitter.Emitters[i]);
          if Result <> nil then Exit;
        end;
      end;
      Result := nil;
    end;
    var i: Integer;
  begin
    if r.Contains(v) then
    begin
      Result := Effect;
      Exit;
    end;
    r.y := r.y + _ItemSpacing + _ItemHeight;
    if Effect.IsOpen then
    begin
      for i := 0 to Effect.Emitters.Count - 1 do
      begin
        Result := CheckEmitter(Effect.Emitters[i]);
        if Result <> nil then Exit;
      end;
    end;
    Result := nil;
  end;
  var i: Integer;
begin
  Result := nil;
  r := _ListFrame;
  if not r.Contains(v) then Exit;
  r.t := r.t + _ItemSpacing;
  r.l := r.l + _ItemSpacing;
  r.r := r.r - _ItemSpacing;
  r.h := _ItemHeight;
  r.y := r.y - _ScrollV.PosAbsolute;
  for i := 0 to App.ParticleData.Effects.Count - 1 do
  begin
    Result := CheckEffect(App.ParticleData.Effects[i]);
    if Result <> nil then Exit;
  end;
end;

procedure TUIWorkspaceParticles2DList.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var b: TUIWorkspaceCustomButton;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited OnInitialize;
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _Menu := TUIWorkspaceCustom.Create;
  _Menu.Parent := Self;
  p := _Menu.Panel;
  p.Client.SpacingTop := 2;
  sm := p.Client.SplitterM(5);
  sm.SizingH := csFixed;
  sm.EqualSized := False;

  b := sm.Subset[0].Button('');
  b.Icon := App.UI.TexFileSave;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Save Effect Library';
  b.OnClick := @BtnSaveLib;

  b := sm.Subset[1].Button('');
  b.Icon := App.UI.TexFileOpen;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Load Effect Library';
  b.OnClick := @BtnLoadLib;

  b := sm.Subset[2].Button('');
  b.Icon := App.UI.TexDelete;
  b.SizingH := csFixed;
  b.Width := 32;
  b.Hint := 'Clear Effect Library';
  b.OnClick := @BtnClearLib;

  p := sm.Subset[3].Panel;
  p.SizingH := csFixed;
  p.Width := 8;

  b := sm.Subset[4].Button('');
  b.Icon := App.UI.TexRoundPlus;
  b.SizingH := csFixed;
  b.IconFilter := tfPoint;
  b.Width := 32;
  b.Hint := 'New Effect';
  b.OnClick := @BtnNewEffect;

  _PopUp := TOverlayPopUp.Create;
  _ItemHeight := 32;
  _ItemSpacing := 4;
end;

procedure TUIWorkspaceParticles2DList.OnFinalize;
begin
  _PopUp.Free;
  inherited OnFinalize;
end;

procedure TUIWorkspaceParticles2DList.OnAdjust;
  var r: TG2Rect;
begin
  _MenuFrame := Frame;
  _MenuFrame.b := _MenuFrame.t + 32;
  _ListFrame := Frame;
  _ListFrame.t := _ListFrame.t + _MenuFrame.h;
  r := _ListFrame; r.l := r.r - 18;
  _ListFrame.r := _ListFrame.r - r.w;
  _ScrollV.Frame := r;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.ParentSize := r.h;
  _Menu.Frame := _MenuFrame;
end;

procedure TUIWorkspaceParticles2DList.OnRender;
  function CountChildEmitters(const po: TParticleObject): Integer;
    function CountFull(const cpo: TParticleObject): Integer;
      var i: Integer;
    begin
      Result := cpo.Emitters.Count;
      for i := 0 to cpo.Emitters.Count - 1 do
      begin
        Result += CountFull(cpo.Emitters[i]);
      end;
    end;
    var i: Integer;
  begin
    Result := po.Emitters.Count;
    for i := 0 to po.Emitters.Count - 2 do
    begin
      Result += CountFull(po.Emitters[i]);
    end;
  end;
  const OffsetSize = 12;
  var r: TG2Rect;
  var Offset: Integer;
  procedure RenderEffect(const Effect: TParticleEffect);
    procedure RenderEmitter(const Emitter: TParticleEmitter);
      var i, ce: Integer;
      var v0, v1: TG2Vec2;
    begin
      if Emitter.IsSelected then
      begin
        g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(1, 0.25));
        g2.PrimRectHollow(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(1, 1));
      end
      else if (App.UI.Overlay = nil) and r.Contains(g2.MousePos) then
      begin
        g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(1, 0.125));
      end;
      App.UI.PushClipRect(r);
      App.UI.Font1.Print(
        Round(r.x + 12 + Offset), Round(r.y + (r.h - App.UI.Font1.TextHeight('A')) * 0.5),
        1, 1, $ffffffff, Emitter.Name, bmNormal, tfPoint
      );
      App.UI.PopClipRect;
      v0.SetValue(r.x + 8 + Offset - OffsetSize + 4, r.y + r.h * 0.5);
      v1.SetValue(r.x + 8 + Offset, r.y + r.h * 0.5);
      g2.PolyBegin(ptLines, App.UI.TexDots);
      g2.PolyAdd(v0, G2Vec2(0, 0.5), $80ffffff);
      g2.PolyAdd(v1, G2Vec2((v1.x - v0.x) * 0.5, 0.5), $80ffffff);
      g2.PolyEnd;
      ce := CountChildEmitters(Emitter);
      if Emitter.IsOpen and (ce > 0) then
      begin
        v0.SetValue(r.x + 8 + Offset + 4, r.y + r.h - 8);
        v1.SetValue(r.x + 8 + Offset + 4, r.y + r.h + (_ItemSpacing + _ItemHeight) * ce - _ItemHeight * 0.5 + 1);
        g2.PolyBegin(ptLines, App.UI.TexDots);
        g2.PolyAdd(v0, G2Vec2(0, 0.5), $80ffffff);
        g2.PolyAdd(v1, G2Vec2((v1.y - v0.y) * 0.5, 0.5), $80ffffff);
        g2.PolyEnd;
      end;
      r.y := r.y + _ItemSpacing + _ItemHeight;
      if Emitter.IsOpen then
      begin
        Offset += OffsetSize;
        for i := 0 to Emitter.Emitters.Count - 1 do
        RenderEmitter(Emitter.Emitters[i]);
        Offset -= OffsetSize;
      end;
    end;
    var i, ce: Integer;
    var v0, v1: TG2Vec2;
  begin
    if Effect.IsSelected then
    begin
      g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(1, 0.25));
      g2.PrimRectHollow(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(1, 1));
    end
    else if (App.UI.Overlay = nil) and r.Contains(g2.MousePos) then
    begin
      g2.PrimRect(r.x, r.y, r.w, r.h, App.UI.GetColorPrimary(1, 0.125));
    end;
    App.UI.PushClipRect(r);
    App.UI.Font1.Print(
      Round(r.x + 12), Round(r.y + (r.h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, $ffffffff, Effect.Name, bmNormal, tfPoint
    );
    App.UI.PopClipRect;
    ce := CountChildEmitters(Effect);
    if Effect.IsOpen and (ce > 0) then
    begin
      v0.SetValue(r.x + 8 + Offset + 4, r.y + r.h - 8);
      v1.SetValue(r.x + 8 + Offset + 4, r.y + r.h + (_ItemSpacing + _ItemHeight) * ce - _ItemHeight * 0.5 + 1);
      g2.PolyBegin(ptLines, App.UI.TexDots);
      g2.PolyAdd(v0, G2Vec2(0, 0.5), $80ffffff);
      g2.PolyAdd(v1, G2Vec2((v1.y - v0.y) * 0.5, 0.5), $80ffffff);
      g2.PolyEnd;
    end;
    r.y := r.y + _ItemSpacing + _ItemHeight;
    if Effect.IsOpen then
    begin
      Offset += OffsetSize;
      for i := 0 to Effect.Emitters.Count - 1 do
      RenderEmitter(Effect.Emitters[i]);
      Offset -= OffsetSize;
    end;
  end;
  var i: Integer;
begin
  r := _ListFrame;
  g2.PrimRect(
    r.x, r.y, r.w, r.h,
    App.UI.GetColorPrimary(0.2)
  );
  App.UI.PushClipRect(r);
  r.t := r.t + _ItemSpacing;
  r.l := r.l + _ItemSpacing;
  r.r := r.r - _ItemSpacing;
  r.h := _ItemHeight;
  Offset := 0;
  r.y := r.y - _ScrollV.PosAbsolute;
  for i := 0 to App.ParticleData.Effects.Count - 1 do
  RenderEffect(App.ParticleData.Effects[i]);
  App.UI.PopClipRect;
  _ScrollV.Render;
end;

procedure TUIWorkspaceParticles2DList.OnUpdate;
begin
  _ScrollV.ParentSize := _ListFrame.h;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.Update;
end;

procedure TUIWorkspaceParticles2DList.OnMouseDown(const Button, x, y: Integer);
  var obj, p: TParticleObject;
begin
  if _ListFrame.Contains(x, y) then
  begin
    if Button = G2MB_Left then
    begin
      obj := PtInItem(G2Vec2(x, y));
      if obj = nil then App.ParticleData.EffectSelect(nil)
      else if obj is TParticleEffect then App.ParticleData.EffectSelect(TParticleEffect(obj))
      else if obj is TParticleEmitter then App.ParticleData.EmitterSelect(TParticleEmitter(obj));
    end
    else if Button = G2MB_Right then
    begin
      obj := PtInItem(G2Vec2(x, y));
      if obj = nil then
      begin
        App.ParticleData.EffectSelect(nil);
        _PopUp.Clear;
        _PopUp.AddButton('New Effect', @BtnNewEffect);
        _PopUp.Show(G2Vec2(x, y));
      end
      else if obj is TParticleEffect then
      begin
        App.ParticleData.EffectSelect(TParticleEffect(obj));
        _PopUp.Clear;
        _PopUp.AddButton('New Emitter', @BtnNewEmitter);
        _PopUp.AddButton('Delete Effect', @BtnDeleteEffect);
        if obj <> App.ParticleData.Effects[0] then
        _PopUp.AddButton('Move Up', @BtnMoveEffectUp);
        if obj <> App.ParticleData.Effects[App.ParticleData.Effects.Count - 1] then
        _PopUp.AddButton('Move Down', @BtnMoveEffectDown);
        _PopUp.AddButton('Export', @BtnExportEffect);
        _PopUp.Show(G2Vec2(x, y));
      end
      else if obj is TParticleEmitter then
      begin
        App.ParticleData.EmitterSelect(TParticleEmitter(obj));
        if TParticleEmitter(obj).ParentEmitter = nil then p := TParticleEmitter(obj).ParentEffect
        else p := TParticleEmitter(obj).ParentEmitter;
        _PopUp.Clear;
        _PopUp.AddButton('New Emitter', @BtnNewEmitter);
        _PopUp.AddButton('Delete Emitter', @BtnDeleteEmitter);
        if obj <> p.Emitters[0] then
        _PopUp.AddButton('Move Up', @BtnMoveEmitterUp);
        if obj <> p.Emitters[p.Emitters.Count - 1] then
        _PopUp.AddButton('Move Down', @BtnMoveEmitterDown);
        _PopUp.Show(G2Vec2(x, y));
      end;
    end;
  end;
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceParticles2DList.OnMouseUp(const Button, x, y: Integer);
begin
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceParticles2DList.OnScroll(const y: Integer);
begin
  _ScrollV.Scroll(y);
end;

function TUIWorkspaceParticles2DList.GetMinWidth: Single;
begin
  Result := 200;
end;

function TUIWorkspaceParticles2DList.GetMinHeight: Single;
begin
  Result := 128;
end;

class function TUIWorkspaceParticles2DList.GetWorkspaceName: AnsiString;
begin
  Result := 'Effect List';
end;

class function TUIWorkspaceParticles2DList.GetWorkspacePath: AnsiString;
begin
  Result := 'Particles2D';
end;
//TUIWorkspaceParticles2DList END

//TUIWorkspaceParticles2DEditor BEGIN
procedure TUIWorkspaceParticles2DEditor.OnEffectNameChange;
begin
  if (App.ParticleData.Selection = nil)
  or not (App.ParticleData.Selection is TParticleEffect)
  or (_EffectNameEdit.Text = TParticleEffect(App.ParticleData.Selection).Name) then Exit;
  if Length(_EffectNameEdit.Text) < 1 then
  begin
    _EffectNameEdit.Text := TParticleEffect(App.ParticleData.Selection).Name;
    Exit;
  end;
  TParticleEffect(App.ParticleData.Selection).Name := '';
  TParticleEffect(App.ParticleData.Selection).Name := App.ParticleData.UniqueEffectName(_EffectNameEdit.Text);
end;

procedure TUIWorkspaceParticles2DEditor.OnEffectScaleChange;
begin
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEffect) then
  begin
    TParticleEffect(App.ParticleData.Selection).Scale := _EffectScale.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterNameChange;
begin
  if (App.ParticleData.Selection = nil)
  or not (App.ParticleData.Selection is TParticleEmitter)
  or (_EmitterNameEdit.Text = TParticleEmitter(App.ParticleData.Selection).Name) then Exit;
  if Length(_EmitterNameEdit.Text) < 1 then
  begin
    _EmitterNameEdit.Text := TParticleEmitter(App.ParticleData.Selection).Name;
    Exit;
  end;
  TParticleEmitter(App.ParticleData.Selection).Name := '';
  TParticleEmitter(App.ParticleData.Selection).Name := App.ParticleData.UniqueEmitterName(
    TParticleEmitter(App.ParticleData.Selection).ParentEffect, _EmitterNameEdit.Text
  );
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterTimeStartChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterTimelineStart.Number - G2EPS2 > Emitter.TimeEnd - 0.02 then
  _EmitterTimelineStart.Number := Emitter.TimeEnd - 0.02
  else
  begin
    Emitter.TimeStart := _EmitterTimelineStart.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterTimeEndChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterTimelineEnd.Number + G2EPS2 < Emitter.TimeStart + 0.02 then
  _EmitterTimelineEnd.Number := Emitter.TimeStart + 0.02
  else
  begin
    Emitter.TimeEnd := _EmitterTimelineEnd.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterOrientationChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.Orientation := _EmitterOrientation.Number * G2DegToRad;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeChange(const PrevIndex: Integer);
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  case _EmitterShapeCombo.ItemIndex of
    0:
    begin
      Emitter.Shape := es_radial;
      _EmitterShapePropertyPages.PageIndex := 0;
    end;
    1:
    begin
      Emitter.Shape := es_rectangle;
      _EmitterShapePropertyPages.PageIndex := 1;
    end;
  end;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeRadius0Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterShapeRadius0.Number - G2EPS2 > Emitter.ShapeRadius1 then
  _EmitterShapeRadius0.Number := Emitter.ShapeRadius1
  else
  begin
    Emitter.ShapeRadius0 := _EmitterShapeRadius0.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeRadius1Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterShapeRadius1.Number + G2EPS2 < Emitter.ShapeRadius0 then
  _EmitterShapeRadius1.Number := Emitter.ShapeRadius0
  else
  begin
    Emitter.ShapeRadius1 := _EmitterShapeRadius1.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeAngleChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ShapeAngle := _EmitterShapeAngle.Number * G2DegToRad;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeWidth0Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterShapeWidth0.Number - G2EPS2 > Emitter.ShapeWidth1 then
  _EmitterShapeWidth0.Number := Emitter.ShapeWidth1
  else
  begin
    Emitter.ShapeWidth0 := _EmitterShapeWidth0.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeWidth1Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterShapeWidth1.Number + G2EPS2 < Emitter.ShapeWidth0 then
  _EmitterShapeWidth1.Number := Emitter.ShapeWidth0
  else
  begin
    Emitter.ShapeWidth1 := _EmitterShapeWidth1.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeHeight0Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterShapeHeight0.Number - G2EPS2 > Emitter.ShapeHeight1 then
  _EmitterShapeHeight0.Number := Emitter.ShapeHeight1
  else
  begin
    Emitter.ShapeHeight0 := _EmitterShapeHeight0.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterShapeHeight1Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _EmitterShapeHeight1.Number + G2EPS2 < Emitter.ShapeHeight0 then
  _EmitterShapeHeight1.Number := Emitter.ShapeHeight0
  else
  begin
    Emitter.ShapeHeight1 := _EmitterShapeHeight1.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterEmissionChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.Emission := _EmitterEmission.Number;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterLayerChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.Layer := _EmitterLayer.Number;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnEmitterInfiniteChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.Infinite := _EmitterInfinite.Checked;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleTextureChange;
  var Emitter: TParticleEmitter;
begin
  if FileExists(_ParticleTextureFile.FilePath) then
  begin
    Emitter := TParticleEmitter(App.ParticleData.Selection);
    if Emitter = nil then Exit;
    if Emitter.Texture <> nil then Emitter.Texture.Free;
    Emitter.Texture := TG2Texture2D.Create;
    Emitter.Texture.Load(_ParticleTextureFile.FilePath);
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleWidthMinChanage;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleWidthMin.Number - G2EPS2 > Emitter.ParticleWidthMax then
  _ParticleWidthMin.Number := Emitter.ParticleWidthMax
  else
  begin
    Emitter.ParticleWidthMin := _ParticleWidthMin.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleWidthMaxChanage;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleWidthMax.Number + G2EPS2 < Emitter.ParticleWidthMin then
  _ParticleWidthMax.Number := Emitter.ParticleWidthMin
  else
  begin
    Emitter.ParticleWidthMax := _ParticleWidthMax.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleCenterXChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleCenterX := _ParticleCenterX.Number;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleCenterYChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleCenterY := _ParticleCenterY.Number;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleHeightMinChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleHeightMin.Number - G2EPS2 > Emitter.ParticleHeightMax then
  _ParticleHeightMin.Number := Emitter.ParticleHeightMax
  else
  begin
    Emitter.ParticleHeightMin := _ParticleHeightMin.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleHeightMaxChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleHeightMax.Number + G2EPS2 < Emitter.ParticleHeightMin then
  _ParticleHeightMax.Number := Emitter.ParticleHeightMin
  else
  begin
    Emitter.ParticleHeightMax := _ParticleHeightMax.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleScaleMinChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleScaleMin.Number - G2EPS2 > Emitter.ParticleScaleMax then
  _ParticleScaleMin.Number := Emitter.ParticleScaleMax
  else
  begin
    Emitter.ParticleScaleMin := _ParticleScaleMin.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleScaleMaxChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleScaleMax.Number + G2EPS2 < Emitter.ParticleScaleMin then
  _ParticleScaleMax.Number := Emitter.ParticleScaleMin
  else
  begin
    Emitter.ParticleScaleMax := _ParticleScaleMax.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleDurationMinChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleDurationMin.Number - G2EPS2 > Emitter.ParticleDurationMax then
  _ParticleDurationMin.Number := Emitter.ParticleDurationMax
  else
  begin
    Emitter.ParticleDurationMin := _ParticleDurationMin.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleDurationMaxChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleDurationMax.Number + G2EPS2 < Emitter.ParticleDurationMin then
  _ParticleDurationMax.Number := Emitter.ParticleDurationMin
  else
  begin
    Emitter.ParticleDurationMax := _ParticleDurationMax.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleRotationMinChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleRotationMin.Number - G2EPS2 > Emitter.ParticleRotationMax * G2RadToDeg then
  _ParticleRotationMin.Number := Emitter.ParticleRotationMax * G2RadToDeg
  else
  begin
    Emitter.ParticleRotationMin := _ParticleRotationMin.Number * G2DegToRad;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleRotationMaxChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleRotationMax.Number + G2EPS2 < Emitter.ParticleRotationMin * G2RadToDeg then
  _ParticleRotationMax.Number := Emitter.ParticleRotationMin * G2RadToDeg
  else
  begin
    Emitter.ParticleRotationMax := _ParticleRotationMax.Number * G2DegToRad;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleRotationLocalChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleRotationLocal := _ParticleRotationLocal.Checked;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleOrientationMinChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleOrientationMin.Number - G2EPS2 > Emitter.ParticleOrientationMax then
  _ParticleOrientationMin.Number := Emitter.ParticleOrientationMax
  else
  begin
    Emitter.ParticleOrientationMin := _ParticleOrientationMin.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleOrientationMaxChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleOrientationMax.Number + G2EPS2 < Emitter.ParticleOrientationMin then
  _ParticleOrientationMax.Number := Emitter.ParticleOrientationMin
  else
  begin
    Emitter.ParticleOrientationMax := _ParticleOrientationMax.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleVelocityMinChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleVelocityMin.Number - G2EPS2 > Emitter.ParticleVelocityMax then
  _ParticleVelocityMin.Number := Emitter.ParticleVelocityMax
  else
  begin
    Emitter.ParticleVelocityMin := _ParticleVelocityMin.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleVelocityMaxChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleVelocityMax.Number + G2EPS2 < Emitter.ParticleVelocityMin then
  _ParticleVelocityMax.Number := Emitter.ParticleVelocityMin
  else
  begin
    Emitter.ParticleVelocityMax := _ParticleVelocityMax.Number;
    App.ParticleData.EffectChanged;
  end;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleColor0Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleColor0.r := _ParticleColor0.Color.r;
  Emitter.ParticleColor0.g := _ParticleColor0.Color.g;
  Emitter.ParticleColor0.b := _ParticleColor0.Color.b;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleColor1Change;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleColor1.r := _ParticleColor1.Color.r;
  Emitter.ParticleColor1.g := _ParticleColor1.Color.g;
  Emitter.ParticleColor1.b := _ParticleColor1.Color.b;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleOpacityChange;
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleColor0.a := Round(_ParticleOpacity.Number * $ff);
  Emitter.ParticleColor1.a := Emitter.ParticleColor0.a;
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleBlendChange(const PrevIndex: Integer);
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  if _ParticleBlend.ItemIndex = 0 then Emitter.ParticleBlend := bmDisable
  else if _ParticleBlend.ItemIndex = 1 then Emitter.ParticleBlend := bmNormal
  else if _ParticleBlend.ItemIndex = 2 then Emitter.ParticleBlend := bmAdd
  else if _ParticleBlend.ItemIndex = 3 then Emitter.ParticleBlend := bmSub
  else if _ParticleBlend.ItemIndex = 4 then Emitter.ParticleBlend := bmMul;
  _ParticleBlendCustom.Visible := _ParticleBlend.ItemIndex = 5;
  _ParticleBlendColorSrc.ItemIndex := Ord(Emitter.ParticleBlend.ColorSrc);
  _ParticleBlendColorDst.ItemIndex := Ord(Emitter.ParticleBlend.ColorDst);
  _ParticleBlendAlphaSrc.ItemIndex := Ord(Emitter.ParticleBlend.AlphaSrc);
  _ParticleBlendAlphaDst.ItemIndex := Ord(Emitter.ParticleBlend.AlphaDst);
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleBlendColorSrcChange(const PrevIndex: Integer);
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleBlend.ColorSrc := TG2BlendOperation(_ParticleBlendColorSrc.ItemIndex);
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleBlendColorDstChange(const PrevIndex: Integer);
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleBlend.ColorDst := TG2BlendOperation(_ParticleBlendColorDst.ItemIndex);
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleBlendAlphaSrcChange(const PrevIndex: Integer);
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleBlend.AlphaSrc := TG2BlendOperation(_ParticleBlendAlphaSrc.ItemIndex);
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnParticleBlendAlphaDstChange(const PrevIndex: Integer);
  var Emitter: TParticleEmitter;
begin
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  if Emitter = nil then Exit;
  Emitter.ParticleBlend.AlphaDst := TG2BlendOperation(_ParticleBlendAlphaDst.ItemIndex);
  App.ParticleData.EffectChanged;
end;

procedure TUIWorkspaceParticles2DEditor.OnModifierAdd(const Sender: Pointer);
  var i: Integer;
  var m: CParticleMod;
  var Emitter: TParticleEmitter;
begin
  m := nil;
  for i := 0 to High(_Mods) do
  if Pointer(_Mods[i]) = Sender then
  begin
    m := App.ParticleData.Mods[i];
    Break;
  end;
  if m <> nil then
  begin
    Emitter := TParticleEmitter(App.ParticleData.Selection);
    Emitter.Mods.Add(m.Create);
    App.ParticleData.EffectChanged;
  end;
  ModsShow;
end;

procedure TUIWorkspaceParticles2DEditor.ModsClear;
  var i: Integer;
begin
  for i := _Modifiers.Client.ChildCount - 1 downto 0 do
  _Modifiers.Client.Children[i].Parent := nil;
end;

procedure TUIWorkspaceParticles2DEditor.ModsShow;
  var i: Integer;
  var Emitter: TParticleEmitter;
begin
  ModsClear;
  Emitter := TParticleEmitter(App.ParticleData.Selection);
  for i := 0 to Emitter.Mods.Count - 1 do
  Emitter.Mods[i].Group.Parent := _Modifiers.Client;
  _ModAdd.Parent := _Modifiers.Client;
  CallAdjust;
end;

procedure TUIWorkspaceParticles2DEditor.ModsAdd;
  var i: Integer;
begin
  ModsClear;
  for i := 0 to High(_Mods) do
  _Mods[i].Parent := _Modifiers.Client;
  _ModCancel.Parent := _Modifiers.Client;
  CallAdjust;
end;

procedure TUIWorkspaceParticles2DEditor.CallAdjust;
  procedure AdjustWorkspace(const Workspace: TUIWorkspace);
  begin
    if Workspace.Parent = nil then Workspace.OnAdjust
    else AdjustWorkspace(Workspace.Parent);
  end;
begin
  AdjustWorkspace(Self);
end;

procedure TUIWorkspaceParticles2DEditor.OnInitialize;
  var sh: TUIWorkspaceFixedSplitterH;
  var sv: TUIWorkspaceFixedSplitterV;
  var sm: TUIWorkspaceFixedSplitterMulti;
  var p: TUIWorkspaceCustomPanel;
  var g: TUIWorkspaceCustomGroup;
  var w: TUIWorkspaceCustom;
  var i: Integer;
begin
  inherited OnInitialize;
  WorkspaceList.Add(Self);
  Scrollable := True;
  p := Panel;
  p.Client.SpacingTop := 4;
  p.Client.SpacingLeft := 4;
  p.Client.SpacingRight := 4;
  p.SizingH := csStretch;
  _Pages := p.Client.Pages;
  _Pages.SizingH := csStretch;
  _Pages.AddPage;
  _Pages.AddPage;
  _Pages.AddPage;

  sh := _Pages.Pages[1].SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Name') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EffectNameEdit := sh.Right.Edit;
  _EffectNameEdit.Height := 24;
  _EffectNameEdit.OnFinishProc := @OnEffectNameChange;

  sh := _Pages.Pages[1].SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Scale') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EffectScale := sh.Right.NumberFloat;
  _EffectScale.NumberMin := 0.1;
  _EffectScale.NumberMax := 10;
  _EffectScale.Increment := 0.01;
  _EffectScale.OnChange := @OnEffectScaleChange;

  g := _Pages.Pages[2].Group('Emitter Settings');
  g.Client.SpacingTop := 4;
  g.Client.SpacingRight := 4;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Name') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EmitterNameEdit := sh.Right.Edit;
  _EmitterNameEdit.OnFinishProc := @OnEmitterNameChange;

  sh := g.Client.SplitterH(0.3);
  sh.PaddingTop := 4;
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Duration') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sm := sh.Right.SplitterM(3);
  _EmitterInfinite := sm.Subset[0].CheckBox('Infinite');
  _EmitterInfinite.OnChange := @OnEmitterInfiniteChange;
  _EmitterTimelineStart := sm.Subset[1].NumberFloat;
  _EmitterTimelineEnd := sm.Subset[2].NumberFloat;
  _EmitterTimelineStart.PaddingRight := 2;
  _EmitterTimelineStart.NumberMin := 0;
  _EmitterTimelineStart.NumberMax := 59.98;
  _EmitterTimelineStart.Increment := 0.02;
  _EmitterTimelineStart.OnChange := @OnEmitterTimeStartChange;
  _EmitterTimelineEnd.PaddingLeft := 2;
  _EmitterTimelineEnd.NumberMin := 0.02;
  _EmitterTimelineEnd.NumberMax := 60;
  _EmitterTimelineEnd.Increment := 0.02;
  _EmitterTimelineEnd.OnChange := @OnEmitterTimeEndChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Orientation') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EmitterOrientation := sh.Right.NumberFloat;
  _EmitterOrientation.NumberMin := -360;
  _EmitterOrientation.NumberMax := 360;
  _EmitterOrientation.Increment := 360 / 50;
  _EmitterOrientation.OnChange := @OnEmitterOrientationChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Shape') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EmitterShapeCombo := sh.Right.ComboBox;
  _EmitterShapeCombo.Add('Radial');
  _EmitterShapeCombo.Add('Rectangle');
  _EmitterShapeCombo.OnChange := @OnEmitterShapeChange;
  _EmitterShapePropertyPages := g.Client.Pages;

  w := _EmitterShapePropertyPages.AddPage;
  sh := w.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Radius') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _EmitterShapeRadius0 := sh.Left.NumberFloat;
  _EmitterShapeRadius0.PaddingRight := 2;
  _EmitterShapeRadius1 := sh.Right.NumberFloat;
  _EmitterShapeRadius1.PaddingLeft := 2;
  _EmitterShapeRadius0.NumberMin := 0;
  _EmitterShapeRadius0.NumberMax := 10000;
  _EmitterShapeRadius0.Increment := 0.1;
  _EmitterShapeRadius0.OnChange := @OnEmitterShapeRadius0Change;
  _EmitterShapeRadius1.NumberMin := 0;
  _EmitterShapeRadius1.NumberMax := 10000;
  _EmitterShapeRadius1.Increment := 0.1;
  _EmitterShapeRadius1.OnChange := @OnEmitterShapeRadius1Change;
  sh := w.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Angle') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EmitterShapeAngle := sh.Right.NumberFloat;
  _EmitterShapeAngle.NumberMin := 0;
  _EmitterShapeAngle.NumberMax := 360;
  _EmitterShapeAngle.Increment := 360 / 50;
  _EmitterShapeAngle.OnChange := @OnEmitterShapeAngleChange;
  w := _EmitterShapePropertyPages.AddPage;
  sh := w.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Width') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _EmitterShapeWidth0 := sh.Left.NumberFloat;
  _EmitterShapeWidth0.PaddingRight := 2;
  _EmitterShapeWidth1 := sh.Right.NumberFloat;
  _EmitterShapeWidth1.PaddingLeft := 2;
  _EmitterShapeWidth0.NumberMin := 0;
  _EmitterShapeWidth0.NumberMax := 10000;
  _EmitterShapeWidth0.Increment := 0.1;
  _EmitterShapeWidth0.OnChange := @OnEmitterShapeWidth0Change;
  _EmitterShapeWidth1.NumberMin := 0;
  _EmitterShapeWidth1.NumberMax := 10000;
  _EmitterShapeWidth1.Increment := 0.1;
  _EmitterShapeWidth1.OnChange := @OnEmitterShapeWidth1Change;
  sh := w.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Height') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _EmitterShapeHeight0 := sh.Left.NumberFloat;
  _EmitterShapeHeight0.PaddingRight := 2;
  _EmitterShapeHeight1 := sh.Right.NumberFloat;
  _EmitterShapeHeight1.PaddingLeft := 2;
  _EmitterShapeHeight0.NumberMin := 0;
  _EmitterShapeHeight0.NumberMax := 10000;
  _EmitterShapeHeight0.Increment := 0.1;
  _EmitterShapeHeight0.OnChange := @OnEmitterShapeHeight0Change;
  _EmitterShapeHeight1.NumberMin := 0;
  _EmitterShapeHeight1.NumberMax := 10000;
  _EmitterShapeHeight1.Increment := 0.1;
  _EmitterShapeHeight1.OnChange := @OnEmitterShapeHeight1Change;
  _EmitterShapePropertyPages.PageIndex := 0;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Emission') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EmitterEmission := sh.Right.NumberInt;
  _EmitterEmission.NumberMin := 0;
  _EmitterEmission.NumberMax := 60000;
  _EmitterEmission.OnChange := @OnEmitterEmissionChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Layer') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _EmitterLayer := sh.Right.NumberInt;
  _EmitterLayer.OnChange := @OnEmitterLayerChange;

  g := _Pages.Pages[2].Group('Particle Settings');
  g.PaddingTop := 4;
  g.Client.SpacingTop := 4;
  g.Client.SpacingRight := 4;
  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Image') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _ParticleTextureFile := sh.Right.FileDialog;
  _ParticleTextureFile.OnSelect := @OnParticleTextureChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Center') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleCenterX := sh.Left.NumberFloat;
  _ParticleCenterX.PaddingRight := 2;
  _ParticleCenterX.Increment := 0.01;
  _ParticleCenterX.OnChange := @OnParticleCenterXChange;
  _ParticleCenterY := sh.Right.NumberFloat;
  _ParticleCenterY.PaddingLeft := 2;
  _ParticleCenterY.Increment := 0.01;
  _ParticleCenterY.OnChange := @OnParticleCenterYChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Width') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleWidthMin := sh.Left.NumberFloat;
  _ParticleWidthMin.PaddingRight := 2;
  _ParticleWidthMin.NumberMin := 0;
  _ParticleWidthMin.NumberMax := 1000;
  _ParticleWidthMin.Increment := 0.1;
  _ParticleWidthMin.OnChange := @OnParticleWidthMinChanage;
  _ParticleWidthMax := sh.Right.NumberFloat;
  _ParticleWidthMax.PaddingLeft := 2;
  _ParticleWidthMax.NumberMin := 0;
  _ParticleWidthMax.NumberMax := 1000;
  _ParticleWidthMax.Increment := 0.1;
  _ParticleWidthMax.OnChange := @OnParticleWidthMaxChanage;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Height') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleHeightMin := sh.Left.NumberFloat;
  _ParticleHeightMin.PaddingRight := 2;
  _ParticleHeightMin.NumberMin := 0;
  _ParticleHeightMin.NumberMax := 1000;
  _ParticleHeightMin.Increment := 0.1;
  _ParticleHeightMin.OnChange := @OnParticleHeightMinChange;
  _ParticleHeightMax := sh.Right.NumberFloat;
  _ParticleHeightMax.PaddingLeft := 2;
  _ParticleHeightMax.NumberMin := 0;
  _ParticleHeightMax.NumberMax := 1000;
  _ParticleHeightMax.Increment := 0.1;
  _ParticleHeightMax.OnChange := @OnParticleHeightMaxChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Scale') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleScaleMin := sh.Left.NumberFloat;
  _ParticleScaleMin.PaddingRight := 2;
  _ParticleScaleMin.NumberMin := 0;
  _ParticleScaleMin.NumberMax := 1000;
  _ParticleScaleMin.Increment := 0.1;
  _ParticleScaleMin.OnChange := @OnParticleScaleMinChange;
  _ParticleScaleMax := sh.Right.NumberFloat;
  _ParticleScaleMax.PaddingLeft := 2;
  _ParticleScaleMax.NumberMin := 0;
  _ParticleScaleMax.NumberMax := 1000;
  _ParticleScaleMax.Increment := 0.1;
  _ParticleScaleMax.OnChange := @OnParticleScaleMaxChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Duration') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleDurationMin := sh.Left.NumberFloat;
  _ParticleDurationMax := sh.Right.NumberFloat;
  _ParticleDurationMin.PaddingRight := 2;
  _ParticleDurationMin.NumberMin := 0;
  _ParticleDurationMin.NumberMax := 60;
  _ParticleDurationMin.Increment := 0.02;
  _ParticleDurationMin.OnChange := @OnParticleDurationMinChange;
  _ParticleDurationMax.PaddingLeft := 2;
  _ParticleDurationMax.NumberMin := 0;
  _ParticleDurationMax.NumberMax := 60;
  _ParticleDurationMax.Increment := 0.02;
  _ParticleDurationMax.OnChange := @OnParticleDurationMaxChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Orientation') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleOrientationMin := sh.Left.NumberFloat;
  _ParticleOrientationMax := sh.Right.NumberFloat;
  _ParticleOrientationMin.PaddingRight := 2;
  _ParticleOrientationMin.NumberMin := -360;
  _ParticleOrientationMin.NumberMax := 360;
  _ParticleOrientationMin.Increment := 360 / 50;
  _ParticleOrientationMin.OnChange := @OnParticleOrientationMinChange;
  _ParticleOrientationMax.PaddingLeft := 2;
  _ParticleOrientationMax.NumberMin := -360;
  _ParticleOrientationMax.NumberMax := 360;
  _ParticleOrientationMax.Increment := 360 / 50;
  _ParticleOrientationMax.OnChange := @OnParticleOrientationMaxChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Rotation') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sm := sh.Right.SplitterM(3);
  _ParticleRotationLocal := sm.Subset[0].CheckBox('Local');
  _ParticleRotationLocal.OnChange := @OnParticleRotationLocalChange;
  _ParticleRotationMin := sm.Subset[1].NumberFloat;
  _ParticleRotationMax := sm.Subset[2].NumberFloat;
  _ParticleRotationMin.PaddingRight := 2;
  _ParticleRotationMin.NumberMin := -360;
  _ParticleRotationMin.NumberMax := 360;
  _ParticleRotationMin.Increment := 360 / 50;
  _ParticleRotationMin.OnChange := @OnParticleRotationMinChange;
  _ParticleRotationMax.PaddingLeft := 2;
  _ParticleRotationMax.NumberMin := -360;
  _ParticleRotationMax.NumberMax := 360;
  _ParticleRotationMax.Increment := 360 / 50;
  _ParticleRotationMax.OnChange := @OnParticleRotationMaxChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Velocity') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sh := sh.Right.SplitterH(0.5);
  _ParticleVelocityMin := sh.Left.NumberFloat;
  _ParticleVelocityMax := sh.Right.NumberFloat;
  _ParticleVelocityMin.PaddingRight := 2;
  _ParticleVelocityMin.Increment := 0.02;
  _ParticleVelocityMin.OnChange := @OnParticleVelocityMinChange;
  _ParticleVelocityMax.PaddingLeft := 2;
  _ParticleVelocityMax.Increment := 0.02;
  _ParticleVelocityMax.OnChange := @OnParticleVelocityMaxChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Color') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  sm := sh.Right.SplitterM(3);
  _ParticleColor0 := sm.Subset[0].ColorDialog;
  _ParticleColor1 := sm.Subset[1].ColorDialog;
  _ParticleOpacity := sm.Subset[2].NumberFloat;
  _ParticleColor0.PaddingRight := 2;
  _ParticleColor0.OnSelect := @OnParticleColor0Change;
  _ParticleColor1.PaddingRight := 2;
  _ParticleColor1.OnSelect := @OnParticleColor1Change;
  _ParticleOpacity.NumberMin := 0;
  _ParticleOpacity.NumberMax := 1;
  _ParticleOpacity.Increment := 0.01;
  _ParticleOpacity.PaddingLeft := 2;
  _ParticleOpacity.OnChange := @OnParticleOpacityChange;

  sh := g.Client.SplitterH(0.3);
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Blend') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _ParticleBlend := sh.Right.ComboBox;
  _ParticleBlend.Add('Disable');
  _ParticleBlend.Add('Normal');
  _ParticleBlend.Add('Add');
  _ParticleBlend.Add('Subtract');
  _ParticleBlend.Add('Multiply');
  _ParticleBlend.Add('Custom');
  _ParticleBlend.ItemIndex := 1;
  _ParticleBlend.OnChange := @OnParticleBlendChange;

  _ParticleBlendCustom := g.Client.Panel;
  sh := _ParticleBlendCustom.Client.SplitterH(0.3);
  sh.PaddingLeft := 32;
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Color Src') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _ParticleBlendColorSrc := sh.Right.ComboBox;
  _ParticleBlendColorSrc.Add('Disable');
  _ParticleBlendColorSrc.Add('Zero');
  _ParticleBlendColorSrc.Add('One');
  _ParticleBlendColorSrc.Add('SrcColor');
  _ParticleBlendColorSrc.Add('InvSrcColor');
  _ParticleBlendColorSrc.Add('DstColor');
  _ParticleBlendColorSrc.Add('InvDstColor');
  _ParticleBlendColorSrc.Add('SrcAlpha');
  _ParticleBlendColorSrc.Add('InvSrcAlpha');
  _ParticleBlendColorSrc.Add('DstAlpha');
  _ParticleBlendColorSrc.Add('InvDstAlpha');
  _ParticleBlendColorSrc.OnChange := @OnParticleBlendColorSrcChange;
  sh := _ParticleBlendCustom.Client.SplitterH(0.3);
  sh.PaddingLeft := 32;
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Color Dst') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _ParticleBlendColorDst := sh.Right.ComboBox;
  _ParticleBlendColorDst.Add('Disable');
  _ParticleBlendColorDst.Add('Zero');
  _ParticleBlendColorDst.Add('One');
  _ParticleBlendColorDst.Add('SrcColor');
  _ParticleBlendColorDst.Add('InvSrcColor');
  _ParticleBlendColorDst.Add('DstColor');
  _ParticleBlendColorDst.Add('InvDstColor');
  _ParticleBlendColorDst.Add('SrcAlpha');
  _ParticleBlendColorDst.Add('InvSrcAlpha');
  _ParticleBlendColorDst.Add('DstAlpha');
  _ParticleBlendColorDst.Add('InvDstAlpha');
  _ParticleBlendColorDst.OnChange := @OnParticleBlendColorDstChange;
  sh := _ParticleBlendCustom.Client.SplitterH(0.3);
  sh.PaddingLeft := 32;
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Alpha Src') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _ParticleBlendAlphaSrc := sh.Right.ComboBox;
  _ParticleBlendAlphaSrc.Add('Disable');
  _ParticleBlendAlphaSrc.Add('Zero');
  _ParticleBlendAlphaSrc.Add('One');
  _ParticleBlendAlphaSrc.Add('SrcColor');
  _ParticleBlendAlphaSrc.Add('InvSrcColor');
  _ParticleBlendAlphaSrc.Add('DstColor');
  _ParticleBlendAlphaSrc.Add('InvDstColor');
  _ParticleBlendAlphaSrc.Add('SrcAlpha');
  _ParticleBlendAlphaSrc.Add('InvSrcAlpha');
  _ParticleBlendAlphaSrc.Add('DstAlpha');
  _ParticleBlendAlphaSrc.Add('InvDstAlpha');
  _ParticleBlendAlphaSrc.OnChange := @OnParticleBlendAlphaSrcChange;
  sh := _ParticleBlendCustom.Client.SplitterH(0.3);
  sh.PaddingLeft := 32;
  sh.Left.SpacingRight := 8;
  with sh.Left.Text('Alpha Dst') do
  begin
    Color := $ffffffff;
    Align := [caRight, caMiddle];
  end;
  _ParticleBlendAlphaDst := sh.Right.ComboBox;
  _ParticleBlendAlphaDst.Add('Disable');
  _ParticleBlendAlphaDst.Add('Zero');
  _ParticleBlendAlphaDst.Add('One');
  _ParticleBlendAlphaDst.Add('SrcColor');
  _ParticleBlendAlphaDst.Add('InvSrcColor');
  _ParticleBlendAlphaDst.Add('DstColor');
  _ParticleBlendAlphaDst.Add('InvDstColor');
  _ParticleBlendAlphaDst.Add('SrcAlpha');
  _ParticleBlendAlphaDst.Add('InvSrcAlpha');
  _ParticleBlendAlphaDst.Add('DstAlpha');
  _ParticleBlendAlphaDst.Add('InvDstAlpha');
  _ParticleBlendAlphaDst.OnChange := @OnParticleBlendAlphaDstChange;
  _ParticleBlendCustom.Visible := False;

  _Modifiers := _Pages.Pages[2].Group('Modifiers');
  _Modifiers.PaddingTop := 4;
  _Modifiers.Client.SetSpacing(4);
  _ModAdd := TUIWorkspaceCustomButton.Create;
  _ModAdd.Caption := 'Add Modifier';
  _ModAdd.OnClick := @ModsAdd;
  _ModCancel := TUIWorkspaceCustomButton.Create;
  _ModCancel.Caption := 'Cancel';
  _ModCancel.OnClick := @ModsShow;
  SetLength(_Mods, App.ParticleData.Mods.Count);
  for i := 0 to App.ParticleData.Mods.Count - 1 do
  begin
    _Mods[i] := TUIWorkspaceCustomButton.Create;
    _Mods[i].Caption := App.ParticleData.Mods[i].GetName;
    _Mods[i].OnClickSender := @OnModifierAdd;
  end;

  _Pages.PageIndex := 0;
end;

procedure TUIWorkspaceParticles2DEditor.OnFinalize;
begin
  WorkspaceList.Remove(Self);
  inherited OnFinalize;
end;

procedure TUIWorkspaceParticles2DEditor.OnBeforeFinalize;
begin
  ModsClear;
  _ModAdd.Free;
  _ModCancel.Free;
  inherited OnBeforeFinalize;
end;

procedure TUIWorkspaceParticles2DEditor.SelectionChanged;
  var Effect: TParticleEffect;
  var Emitter: TParticleEmitter;
begin
  if App.ParticleData.Selection = nil then
  begin
    _Pages.PageIndex := 0;
  end
  else if App.ParticleData.Selection is TParticleEffect then
  begin
    _Pages.PageIndex := 1;
    Effect := TParticleEffect(App.ParticleData.Selection);
    _EffectNameEdit.Text := Effect.Name;
    _EffectScale.Number := Effect.Scale;
  end
  else if App.ParticleData.Selection is TParticleEmitter then
  begin
    _Pages.PageIndex := 2;
    Emitter := TParticleEmitter(App.ParticleData.Selection);
    _EmitterNameEdit.Text := Emitter.Name;
    if Emitter.Texture <> nil then
    begin
      _ParticleTextureFile.FilePath := Emitter.Texture.AssetName;
      _ParticleTextureFile.FileName := ExtractFileName(_ParticleTextureFile.FilePath);
    end
    else
    begin
      _ParticleTextureFile.FilePath := '';
      _ParticleTextureFile.FileName := '';
    end;
    _EmitterTimelineStart.Number := Emitter.TimeStart;
    _EmitterTimelineEnd.Number := Emitter.TimeEnd;
    _EmitterOrientation.Number := Emitter.Orientation * G2RadToDeg;
    case Emitter.Shape of
      es_radial: _EmitterShapeCombo.ItemIndex := 0;
      es_rectangle: _EmitterShapeCombo.ItemIndex := 1;
    end;
    _EmitterShapeRadius0.Number := Emitter.ShapeRadius0;
    _EmitterShapeRadius1.Number := Emitter.ShapeRadius1;
    _EmitterShapeAngle.Number := Emitter.ShapeAngle * G2RadToDeg;
    _EmitterShapeWidth0.Number := Emitter.ShapeWidth0;
    _EmitterShapeWidth1.Number := Emitter.ShapeWidth1;
    _EmitterShapeHeight0.Number := Emitter.ShapeHeight0;
    _EmitterShapeHeight1.Number := Emitter.ShapeHeight1;
    _EmitterEmission.Number := Emitter.Emission;
    _EmitterLayer.Number := Emitter.Layer;
    _EmitterInfinite.Checked := Emitter.Infinite;
    _ParticleCenterX.Number := Emitter.ParticleCenterX;
    _ParticleCenterY.Number := Emitter.ParticleCenterY;
    _ParticleWidthMin.Number := Emitter.ParticleWidthMin;
    _ParticleWidthMax.Number := Emitter.ParticleWidthMax;
    _ParticleHeightMin.Number := Emitter.ParticleHeightMin;
    _ParticleHeightMax.Number := Emitter.ParticleHeightMax;
    _ParticleScaleMin.Number := Emitter.ParticleScaleMin;
    _ParticleScaleMax.Number := Emitter.ParticleScaleMax;
    _ParticleDurationMin.Number := Emitter.ParticleDurationMin;
    _ParticleDurationMax.Number := Emitter.ParticleDurationMax;
    _ParticleOrientationMin.Number := Emitter.ParticleOrientationMin * G2RadToDeg;
    _ParticleOrientationMax.Number := Emitter.ParticleOrientationMax * G2RadToDeg;
    _ParticleRotationLocal.Checked := Emitter.ParticleRotationLocal;
    _ParticleRotationMin.Number := Emitter.ParticleRotationMin * G2RadToDeg;
    _ParticleRotationMax.Number := Emitter.ParticleRotationMax * G2RadToDeg;
    _ParticleVelocityMin.Number := Emitter.ParticleVelocityMin;
    _ParticleVelocityMax.Number := Emitter.ParticleVelocityMax;
    _ParticleColor0.Color := G2Color(Emitter.ParticleColor0.r, Emitter.ParticleColor0.g, Emitter.ParticleColor0.b, $ff);
    _ParticleColor1.Color := G2Color(Emitter.ParticleColor1.r, Emitter.ParticleColor1.g, Emitter.ParticleColor1.b, $ff);
    _ParticleOpacity.Number := Emitter.ParticleColor0.a * G2Rcp255;
    if Emitter.ParticleBlend = bmDisable then _ParticleBlend.ItemIndex := 0
    else if Emitter.ParticleBlend = bmNormal then _ParticleBlend.ItemIndex := 1
    else if Emitter.ParticleBlend = bmAdd then _ParticleBlend.ItemIndex := 2
    else if Emitter.ParticleBlend = bmSub then _ParticleBlend.ItemIndex := 3
    else if Emitter.ParticleBlend = bmMul then _ParticleBlend.ItemIndex := 4
    else _ParticleBlend.ItemIndex := 5;
    _ParticleBlendColorSrc.ItemIndex := Ord(Emitter.ParticleBlend.ColorSrc);
    _ParticleBlendColorDst.ItemIndex := Ord(Emitter.ParticleBlend.ColorDst);
    _ParticleBlendAlphaSrc.ItemIndex := Ord(Emitter.ParticleBlend.AlphaSrc);
    _ParticleBlendAlphaDst.ItemIndex := Ord(Emitter.ParticleBlend.AlphaDst);
    _ParticleBlendCustom.Visible := _ParticleBlend.ItemIndex = 5;
    ModsShow;
  end;
end;

function TUIWorkspaceParticles2DEditor.GetMinWidth: Single;
begin
  Result := 380;
end;

function TUIWorkspaceParticles2DEditor.GetMinHeight: Single;
begin
  Result := inherited GetMinHeight;
end;

class constructor TUIWorkspaceParticles2DEditor.CreateClass;
begin
  WorkspaceList.Clear;
end;

class function TUIWorkspaceParticles2DEditor.GetWorkspaceName: AnsiString;
begin
  Result := 'Editor';
end;

class function TUIWorkspaceParticles2DEditor.GetWorkspacePath: AnsiString;
begin
  Result := 'Particles2D';
end;
//TUIWorkspaceParticles2DEditor END

//TUIWorkspaceParticles2DViewport BEGIN
procedure TUIWorkspaceParticles2DViewport.OnBackgroundChange;
begin

end;

procedure TUIWorkspaceParticles2DViewport.OnInitialize;
  var p: TUIWorkspaceCustomPanel;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited OnInitialize;
  WorkspaceList.Add(Self);
  _TargetZoom := 1;
  _SettingsSize := 32;
  _Display := TG2Display2D.Create;
  _Display.Position := G2Vec2(0, 0);
  _Display.Width := 10;
  _Display.Height := 10;
  _Settings := TUIWorkspaceCustom.Create;
  _Settings.Parent := Self;
  p := _Settings.Panel;
  p.Client.SetSpacing(4);
  sm := p.Client.SplitterM(5);
  sm.EqualSized := False;
  with sm.Subset[0].Text('Background') do
  begin
    PaddingRight := 4;
    Color := $ffffffff;
    Align := [caMiddle];
  end;
  _Background := sm.Subset[1].ColorDialog;
  _Background.OnSelect := @OnBackgroundChange;
  _Background.Color := $ffc0c0c0;
  _Background.PaddingRight := 12;
  _Background.Width := 128;
  with sm.Subset[2].Text('Checker') do
  begin
    PaddingRight := 4;
    Color := $ffffffff;
    Align := [caMiddle];
  end;
  _Checker := sm.Subset[3].Slider;
  _Checker.Position := 0.19;
  _Checker.PaddingRight := 12;
  _Zoom := sm.Subset[4].Text('Zoom: 10000%');
  _Zoom.Color := $ffffffff;
  _Zoom.Align := [caMiddle, caLeft];
end;

procedure TUIWorkspaceParticles2DViewport.OnFinalize;
begin
  _Display.Free;
  WorkspaceList.Remove(Self);
  inherited OnFinalize;
end;

procedure TUIWorkspaceParticles2DViewport.OnRender;
  var r: TG2Rect;
  var c: TG2Color;
  var b: Byte;
begin
  r := Frame;
  g2.PrimRect(
    r.x, r.y, r.w, r.h, _Background.Color
  );
  b := Round(_Checker.Position * $ff);
  c := G2Color(b, b, b, $ff);
  g2.PicRect(
    r.x, r.y, r.w, r.h,
    0, 0, r.w / App.UI.TexChecker.Width * 0.2, r.h / App.UI.TexChecker.Height * 0.2,
    c, App.UI.TexChecker, bmAdd
  );
  App.ParticleData.Render(_Display);
end;

procedure TUIWorkspaceParticles2DViewport.OnUpdate;
begin
  inherited OnUpdate;
  _Display.Zoom := G2LerpFloat(_Display.Zoom, _TargetZoom, 0.2);
  _Zoom.Caption := 'Zoom: ' + IntToStr(Round(_Display.Zoom * 100)) + '%';
end;

procedure TUIWorkspaceParticles2DViewport.OnAdjust;
  var r: TG2Rect;
begin
  inherited OnAdjust;
  r := Frame;
  r.b := r.t + _SettingsSize;
  _FrameSettings := r;
  _Settings.Frame := _FrameSettings;
  r := Frame;
  r.t := _FrameSettings.b;
  _Display.ViewPort := r;
end;

procedure TUIWorkspaceParticles2DViewport.OnScroll(const y: Integer);
begin
  inherited OnScroll(y);
  if y > 0 then
  _TargetZoom *= 1.1
  else
  _TargetZoom /= 1.1;
end;

procedure TUIWorkspaceParticles2DViewport.SelectionChanged;
begin
  _Display.Zoom := 1;
  _TargetZoom := 1;
end;

function TUIWorkspaceParticles2DViewport.GetMinWidth: Single;
begin
  Result := 360;
end;

function TUIWorkspaceParticles2DViewport.GetMinHeight: Single;
begin
  Result := 160;
end;

class constructor TUIWorkspaceParticles2DViewport.CreateClass;
begin
  WorkspaceList.Clear;
end;

class function TUIWorkspaceParticles2DViewport.GetWorkspaceName: AnsiString;
begin
  Result := 'Viewport';
end;

class function TUIWorkspaceParticles2DViewport.GetWorkspacePath: AnsiString;
begin
  Result := 'Particles2D';
end;
//TUIWorkspaceParticles2DViewport END

//TUIWorkspaceParticles2DTimeline BEGIN
function TUIWorkspaceParticles2DTimeline.GetContentSize: TG2Float;
  var ParentObject: TParticleObject;
  var i: Integer;
begin
  Result := 0;
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    if TParticleEmitter(App.ParticleData.Selection).ParentEmitter = nil then
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEffect
    else
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEmitter;
    for i := 0 to ParentObject.Emitters.Count - 1 do
    Result += _TrackHeight + _TrackSpacing;
  end
end;

procedure TUIWorkspaceParticles2DTimeline.CalculateNamesFrame;
  var ParentObject: TParticleObject;
  var i, s, NamesSize: Integer;
begin
  NamesSize := 0;
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    if TParticleEmitter(App.ParticleData.Selection).ParentEmitter = nil then
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEffect
    else
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEmitter;
    for i := 0 to ParentObject.Emitters.Count - 1 do
    begin
      s := App.UI.Font1.TextWidth(ParentObject.Emitters[i].Name) + 16;
      if s > NamesSize then NamesSize := s;
    end;
  end;
  _NamesFrame := _TrackFrame;
  _NamesFrame.w := NamesSize;
end;

function TUIWorkspaceParticles2DTimeline.GetEmitterRect(const Emitter: TParticleEmitter): TG2Rect;
  var i: Integer;
begin
  if Emitter.ParentEmitter <> nil then
  i := Emitter.ParentEmitter.Emitters.Find(Emitter)
  else
  i := Emitter.ParentEffect.Emitters.Find(Emitter);
  Result := G2Rect(
    _NamesFrame.r - _ScrollH.PosAbsolute + Emitter.TimeStart * _RullerScale * 10 + 1,
    _NamesFrame.y + _TrackSpacing - _ScrollV.PosAbsolute + (_TrackHeight + _TrackSpacing) * i,
    (Emitter.TimeEnd - Emitter.TimeStart) * _RullerScale * 10 - 2, _TrackHeight
  );
end;

procedure TUIWorkspaceParticles2DTimeline.OnInitialize;
begin
  inherited OnInitialize;
  _DragEmitter := nil;
  _DragEdge := 0;
  _TrackHeight := 24;
  _TrackSpacing := 2;
  _RullerHeight := 16;
  _RullerScale := 50;
  _ScrollBoxSize := 18;
  _ScrollV.Initialize;
  _ScrollV.Orientation := sbVertical;
  _ScrollH.Initialize;
  _ScrollH.Orientation := sbHorizontal;
end;

procedure TUIWorkspaceParticles2DTimeline.OnRender;
  var i: Integer;
  var x, s, y: TG2Float;
  var ParentObject: TParticleObject;
  var r: TG2Rect;
begin
  inherited OnRender;
  g2.PrimRectCol(
    _RullerFrame.x, _RullerFrame.y, _RullerFrame.w, _RullerFrame.h,
    App.UI.GetColorPrimary(0.8), App.UI.GetColorPrimary(0.8),
    App.UI.GetColorPrimary(0.6), App.UI.GetColorPrimary(0.6)
  );
  App.UI.PushClipRect(_RullerFrame);
  for i := 0 to 600 do
  begin
    x := _NamesFrame.r + i * _RullerScale - _ScrollH.PosAbsolute;
    if x > _TrackFrame.r then Break
    else if x > Frame.l - 10 then
    begin
      if i mod 10 = 0 then
      begin
        s := 8;
        App.UI.FontCode.Print(Round(x + 2), Round(_RullerFrame.t), 1, 1, $ff000000, IntToStr(i div 10), bmNormal, tfPoint);
      end
      else
      begin
        s := 4;
      end;
      g2.PrimLine(x, _RullerFrame.b - s, x, _RullerFrame.b, $ff404040);
    end;
  end;
  App.UI.PopClipRect;
  g2.PrimRect(_NamesFrame.x, _NamesFrame.y, _NamesFrame.w, _NamesFrame.h, App.UI.GetColorPrimary(0.6));
  g2.PrimRect(_TrackFrame.x, _TrackFrame.y, _TrackFrame.w, _TrackFrame.h, App.UI.GetColorPrimary(0.7));
  g2.PrimLine(_NamesFrame.r, _NamesFrame.t, _NamesFrame.r, _NamesFrame.b, App.UI.GetColorPrimary(0.2));
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    if TParticleEmitter(App.ParticleData.Selection).ParentEmitter = nil then
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEffect
    else
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEmitter;
    y := _NamesFrame.y + _TrackSpacing - _ScrollV.PosAbsolute;
    App.UI.PushClipRect(_NamesFrame);
    for i := 0 to ParentObject.Emitters.Count - 1 do
    begin
      App.UI.Font1.Print(
        Round(_NamesFrame.x + 8),
        Round(y + (_TrackHeight - App.UI.Font1.TextHeight('A')) * 0.5),
        1, 1, $ff000000, ParentObject.Emitters[i].Name, bmNormal, tfPoint
      );
      g2.PrimLine(
        _NamesFrame.l, y + _TrackHeight,
        _NamesFrame.r, y + _TrackHeight,
        App.UI.GetColorPrimary(0.2)
      );
      y += _TrackHeight + _TrackSpacing;
    end;
    App.UI.PopClipRect;
    r := _TrackFrame;
    r.l := _NamesFrame.r;
    App.UI.PushClipRect(r);
    for i := 0 to ParentObject.Emitters.Count - 1 do
    begin
      r := GetEmitterRect(ParentObject.Emitters[i]).Expand(0, -4);
      if ((App.UI.Overlay = nil) and r.Contains(g2.MousePos)) or (_DragEmitter = ParentObject.Emitters[i]) then
      g2.PrimRect(r.x, r.y, r.w, r.h, $804040ff)
      else
      g2.PrimRect(r.x, r.y, r.w, r.h, $800000ff);
      g2.PrimRectHollow(r.x, r.y, r.w, r.h, $ff0000ff);
      g2.PolyBegin(ptLines, App.UI.TexDots);
      g2.PolyAdd(_NamesFrame.r, r.b + 4, 0, 0.5, $ff404040);
      g2.PolyAdd(_TrackFrame.r, r.b + 4, (_TrackFrame.r - _NamesFrame.r) * 0.25, 0.5, $ff404040);
      g2.PolyEnd;
    end;
    App.UI.PopClipRect;
  end;
  g2.PrimRect(
    Frame.r - _ScrollBoxSize, Frame.b - _ScrollBoxSize,
    _ScrollBoxSize, _ScrollBoxSize,
    App.UI.GetColorPrimary(0.4)
  );
  _ScrollH.Render;
  _ScrollV.Render;
end;

procedure TUIWorkspaceParticles2DTimeline.OnUpdate;
  var x, w: TG2Float;
  var i: Integer;
  var r: TG2Rect;
  var ParentObject: TParticleObject;
begin
  inherited OnUpdate;
  CalculateNamesFrame;
  _ScrollH.ParentSize := _TrackFrame.w;
  _ScrollH.ContentSize := 600 * _RullerScale + _NamesFrame.w;
  _ScrollH.Update;
  _ScrollV.ParentSize := _TrackFrame.h;
  _ScrollV.ContentSize := GetContentSize;
  _ScrollV.Update;
  if _DragEmitter <> nil then
  begin
    x := g2.MousePos.x;
    if _DragEdge = 0 then
    begin
      x -= _DragOffset;
      w := _DragEmitter.TimeEnd - _DragEmitter.TimeStart;
      _DragEmitter.TimeStart := (_ScrollH.PosAbsolute + x - _NamesFrame.r - 1) / (_RullerScale * 10);
      if _DragEmitter.TimeStart < 0 then
      _DragEmitter.TimeStart := 0;
      if _DragEmitter.TimeStart + w > 60 then
      _DragEmitter.TimeStart := 60 - w;
      _DragEmitter.TimeEnd := _DragEmitter.TimeStart + w;
    end
    else if _DragEdge = -1 then
    begin
      App.UI.Cursor := g2.Window.CursorSizeWE;
      _DragEmitter.TimeStart := (_ScrollH.PosAbsolute + x - _NamesFrame.r - 1) / (_RullerScale * 10);
      if _DragEmitter.TimeStart < 0 then
      _DragEmitter.TimeStart := 0;
      if _DragEmitter.TimeStart > _DragEmitter.TimeEnd - 0.02 then
      _DragEmitter.TimeStart := _DragEmitter.TimeEnd - 0.02;
    end
    else if _DragEdge = 1 then
    begin
      App.UI.Cursor := g2.Window.CursorSizeWE;
      _DragEmitter.TimeEnd := (_ScrollH.PosAbsolute + x - _NamesFrame.r - 1) / (_RullerScale * 10);
      if _DragEmitter.TimeEnd < _DragEmitter.TimeStart + 0.02 then
      _DragEmitter.TimeEnd := _DragEmitter.TimeStart + 0.02;
      if _DragEmitter.TimeEnd > 60 then
      _DragEmitter.TimeEnd := 60;
    end;
    if _DragEmitter = App.ParticleData.Selection then
    App.ParticleData.UpdateEditors;
  end
  else
  begin
    if (App.ParticleData.Selection <> nil)
    and (App.ParticleData.Selection is TParticleEmitter) then
    begin
      if TParticleEmitter(App.ParticleData.Selection).ParentEmitter = nil then
      ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEffect
      else
      ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEmitter;
      for i := 0 to ParentObject.Emitters.Count - 1 do
      begin
        r := GetEmitterRect(ParentObject.Emitters[i]);
        if r.Contains(g2.MousePos) then
        begin
          if r.w < 8 then
          begin
            App.UI.Cursor := g2.Window.CursorSizeWE;
          end
          else
          begin
            if G2Rect(r.x, r.y, 4, r.h).Contains(g2.MousePos)
            or G2Rect(r.r - 4, r.y, 4, r.h).Contains(g2.MousePos) then
            App.UI.Cursor := g2.Window.CursorSizeWE;
          end;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TUIWorkspaceParticles2DTimeline.OnAdjust;
  var r: TG2Rect;
begin
  inherited OnAdjust;
  _RullerFrame := Frame;
  _RullerFrame.h := _RullerHeight;
  _RullerFrame.r := _RullerFrame.r - _ScrollBoxSize;
  r := Frame;
  r.l := r.r - _ScrollBoxSize;
  r.b := r.b - _ScrollBoxSize;
  _ScrollV.Frame := r;
  r := Frame;
  r.t := r.b - _ScrollBoxSize;
  r.r := r.r - _ScrollBoxSize;
  _ScrollH.Frame := r;
  _TrackFrame := Frame;
  _TrackFrame.t := _RullerFrame.b;
  _TrackFrame.r := _TrackFrame.r - _ScrollBoxSize;
  _TrackFrame.b := _TrackFrame.b - _ScrollBoxSize;
  CalculateNamesFrame;
end;

procedure TUIWorkspaceParticles2DTimeline.OnMouseDown(const Button, x, y: Integer);
  var i: Integer;
  var ParentObject: TParticleObject;
  var r: TG2Rect;
begin
  if (Button = G2MB_Left)
  and (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    if TParticleEmitter(App.ParticleData.Selection).ParentEmitter = nil then
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEffect
    else
    ParentObject := TParticleEmitter(App.ParticleData.Selection).ParentEmitter;
    for i := 0 to ParentObject.Emitters.Count - 1 do
    begin
      r := GetEmitterRect(ParentObject.Emitters[i]);
      if r.Contains(x, y) then
      begin
        _DragEmitter := ParentObject.Emitters[i];
        _DragOffset := x - r.l;
        _DragEdge := 0;
        if r.w < 8 then
        begin
          if G2Rect(r.x, r.y, r.w * 0.5, r.h).Contains(x, y) then
          _DragEdge := -1
          else if G2Rect(r.x + r.w * 0.5, r.y, r.w * 0.5, r.h).Contains(x, y) then
          _DragEdge := 1;
        end
        else
        begin
          if G2Rect(r.x, r.y, 4, r.h).Contains(x, y) then
          _DragEdge := -1
          else if G2Rect(r.r - 4, r.y, 4, r.h).Contains(x, y) then
          _DragEdge := 1;
        end;
        Break;
      end;
    end;
  end;
  _ScrollH.MouseDown(Button, x, y);
  _ScrollV.MouseDown(Button, x, y);
end;

procedure TUIWorkspaceParticles2DTimeline.OnMouseUp(const Button, x, y: Integer);
begin
  _DragEmitter := nil;
  _ScrollH.MouseUp(Button, x, y);
  _ScrollV.MouseUp(Button, x, y);
end;

procedure TUIWorkspaceParticles2DTimeline.OnScroll(const y: Integer);
begin
  _ScrollV.Scroll(y);
end;

function TUIWorkspaceParticles2DTimeline.GetMinWidth: Single;
begin
  Result := 200;
end;

function TUIWorkspaceParticles2DTimeline.GetMinHeight: Single;
begin
  Result := 128;
end;

class function TUIWorkspaceParticles2DTimeline.GetWorkspaceName: AnsiString;
begin
  Result := 'Timeline';
end;

class function TUIWorkspaceParticles2DTimeline.GetWorkspacePath: AnsiString;
begin
  Result := 'Particles2D';
end;
//TUIWorkspaceParticles2DTimeline END

//TG2Toolkit BEGIN
procedure TG2Toolkit.Initialize;
begin
  g2.Window.Caption := 'g2mp toolkit v0.2';
  g2.AssetSourceManager.SourceFile.ClearPaths;
  cbf_scene2d_object := RegisterClipboardFormat('g2mp toolkit scene2d object');
  AssetManager.Initialize;
  UI.Initialize;
  Project.Initialize;
  Log.Initialize;
  Console.Initialize;
  AtlasPackerData.Initailize;
  ParticleData.Initialize;
  Scene2DData.Initialize;
  CodeInsight.Initialize;
  UI.RegisterWorkspace(TUIWorkspaceProject);
  UI.RegisterWorkspace(TUIWorkspaceProjectBrowser);
  UI.RegisterWorkspace(TUIWorkspaceSettings);
  //UI.RegisterWorkspace(TUIWorkspaceEmpty);
  UI.RegisterWorkspace(TUIWorkspaceLog);
  UI.RegisterWorkspace(TUIWorkspaceConsole);
  //UI.RegisterWorkspace(TUIWorkspaceCustomTest);
  UI.RegisterWorkspace(TUIWorkspaceAtlasPacker);
  UI.RegisterWorkspace(TUIWorkspaceCode);
  UI.RegisterWorkspace(TUIWorkspaceCodeBrowser);
  UI.RegisterWorkspace(TUIWorkspaceParticles2DList);
  UI.RegisterWorkspace(TUIWorkspaceParticles2DEditor);
  UI.RegisterWorkspace(TUIWorkspaceParticles2DViewport);
  UI.RegisterWorkspace(TUIWorkspaceParticles2DTimeline);
  UI.RegisterWorkspace(TUIWorkspaceScene2D);
  UI.RegisterWorkspace(TUIWorkspaceScene2DProperties);
  UI.RegisterWorkspace(TUIWorkspaceScene2DStructure);
  UI.LoadWorkspaces;
  if FileExists(g2.AppPath + 'DefaultLayout.g2ml') then
  App.UI.MsgLoadLayout(g2.AppPath + 'DefaultLayout.g2ml');
  if Length(ParamStr(1)) > 0 then
  begin
    if LowerCase(ExtractFileExt(ParamStr(1))) = '.g2pr' then
    App.UI.MsgOpenProject(ParamStr(1));
  end;
end;

procedure TG2Toolkit.Finalize;
begin
  CodeInsight.Finalize;
  Scene2DData.Finalize;
  ParticleData.Finalize;
  AtlasPackerData.Finalize;
  Console.Finalize;
  Log.Finalize;
  Project.Finalize;
  UI.Finalize;
  AssetManager.Finalize;
end;

procedure TG2Toolkit.Update;
begin
  ParticleData.Update;
  AtlasPackerData.Update;
  Project.Update;
  CodeInsight.Update;
  UI.Update;
  Scene2DData.Update;
  AssetManager.Update;
end;

procedure TG2Toolkit.Render;
begin
  g2.Gfx.StateChange.StateClear($ffffffff);
  ParticleData.Render;
  UI.Render;
end;

procedure TG2Toolkit.KeyDown(const Key: Integer);
begin
  case Key of
    G2K_F9: Project.Build;
    else
    begin
      Scene2DData.KeyDown(Key);
      UI.OnKeyDown(Key);
    end;
  end;
end;

procedure TG2Toolkit.KeyUp(const Key: Integer);
begin
  UI.OnKeyUp(Key);
end;

procedure TG2Toolkit.MouseDown(const Button, x, y: Integer);
begin
  UI.MsgMouseDown(Button, x, y);
end;

procedure TG2Toolkit.MouseUp(const Button, x, y: Integer);
begin
  UI.MsgMouseUp(Button, x, y);
end;

procedure TG2Toolkit.Scroll(const y: Integer);
begin
  UI.OnScroll(y);
end;

procedure TG2Toolkit.Print(const Char: AnsiChar);
begin
  UI.OnPrint(Char);
end;

procedure TG2Toolkit.Resize(const OldWidth, OldHeight, NewWidth, NewHeight: Integer);
begin
  UI.Resize;
end;

function TG2Toolkit.LoadFile(const f: String): AnsiString;
  var fs: TFileStream;
begin
  fs := TFileStream.Create(f, fmOpenRead);
  try
    SetLength(Result, fs.Size);
    fs.Read(Result[1], fs.Size);
  finally
    fs.Free;
  end;
end;
//TG2Toolkit END

//TUIWorkspace BEGIN
function TUIWorkspace.GetChildCount: Integer;
begin
  Result := Length(_Children);
end;

function TUIWorkspace.GetChild(const Index: Integer): TUIWorkspace;
begin
  Result := _Children[Index];
end;

procedure TUIWorkspace.SetChild(const Index: Integer; const Value: TUIWorkspace);
begin
  _Children[Index] := Value;
end;

procedure TUIWorkspace.SetParent(const NewParent: TUIWorkspace);
begin
  if _Parent <> nil then
  _Parent.ChildRemove(Self);
  _Parent := NewParent;
  if _Parent <> nil then
  _Parent.ChildAdd(Self)
  else
  _Frame := App.UI.WorkspaceFrame;
end;

procedure TUIWorkspace.SetFrame(const NewFrame: TG2Rect);
begin
  _Frame := NewFrame;
  OnAdjust;
end;

function TUIWorkspace.GetFocused: Boolean;
begin
  Result := Focus = Self;
end;

procedure TUIWorkspace.OnInitialize;
begin

end;

procedure TUIWorkspace.OnFinalize;
begin

end;

procedure TUIWorkspace.OnBeforeFinalize;
begin

end;

procedure TUIWorkspace.OnAdjust;
begin

end;

procedure TUIWorkspace.OnUpdate;
begin

end;

procedure TUIWorkspace.OnRender;
begin

end;

procedure TUIWorkspace.OnMouseDown(const Button, x, y: Integer);
begin

end;

procedure TUIWorkspace.OnMouseUp(const Button, x, y: Integer);
begin

end;

procedure TUIWorkspace.OnKeyDown(const Key: Integer);
begin

end;

procedure TUIWorkspace.OnKeyUp(const Key: Integer);
begin

end;

procedure TUIWorkspace.OnScroll(const y: Integer);
begin

end;

procedure TUIWorkspace.OnChildAdd(const Child: TUIWorkspace);
begin
  Child.Frame := _Frame;
end;

procedure TUIWorkspace.OnChildRemove(const Child: TUIWorkspace);
begin

end;

procedure TUIWorkspace.OnTabInsert(const TabParent: TUIWorkspaceFrame);
begin
  Parent := TabParent;
end;

procedure TUIWorkspace.OnHeaderRender;
begin

end;

procedure TUIWorkspace.OnHeaderMouseDown(const Button, x, y: Integer);
begin

end;

procedure TUIWorkspace.OnHeaderMouseUp(const Button, x, y: Integer);
begin

end;

procedure TUIWorkspace.OnDragDropBegin(const Drop: TOverlayDrop);
begin

end;

procedure TUIWorkspace.OnDragDropEnd(const Drop: TOverlayDrop);
begin

end;

procedure TUIWorkspace.OnDragDropRelase(const Drop: TOverlayDrop);
begin

end;

class function TUIWorkspace.GetWorkspaceName: AnsiString;
begin
  Result := 'Workspace';
end;

class function TUIWorkspace.GetWorkspacePath: AnsiString;
begin
  Result := '';
end;

procedure TUIWorkspace.ChildAdd(const Child: TUIWorkspace);
begin
  SetLength(_Children, Length(_Children) + 1);
  _Children[High(_Children)] := Child;
  OnChildAdd(Child);
end;

procedure TUIWorkspace.ChildRemove(const Child: TUIWorkspace);
  var i, j: Integer;
begin
  for i := 0 to High(_Children) do
  if _Children[i] = Child then
  begin
    OnChildRemove(Child);
    for j := i to High(_Children) - 1 do
    _Children[j] := _Children[j + 1];
    SetLength(_Children, High(_Children));
    Exit;
  end;
end;

procedure TUIWorkspace.ChildReplace(const ChildOld, ChildNew: TUIWorkspace);
  var i: Integer;
begin
  for i := 0 to ChildCount - 1 do
  if Children[i] = ChildOld then
  begin
    ChildOld._Parent := nil;
    ChildNew._Parent := Self;
    Children[i] := ChildNew;
    OnAdjust;
    Exit;
  end;
end;

procedure TUIWorkspace.ChildReposition(const OldChildIndex, NewChildIndex: Integer);
  var Child: TUIWorkspace;
  var i: Integer;
begin
  Child := _Children[OldChildIndex];
  for i := OldChildIndex to High(_Children) - 1 do
  _Children[i] := _Children[i + 1];
  for i := High(_Children) downto NewChildIndex + 1 do
  _Children[i] := _Children[i - 1];
  _Children[NewChildIndex] := Child;
  OnAdjust;
end;

procedure TUIWorkspace.Update;
  var i: Integer;
begin
  for i := 0 to High(_Children) do
  _Children[i].Update;
  OnUpdate;
end;

procedure TUIWorkspace.Render;
  var i: Integer;
  var r: TRect;
begin
  r := Frame;
  App.UI.PushClipRect(r);
  OnRender;
  for i := 0 to High(_Children) do
  _Children[i].Render;
  App.UI.PopClipRect;
end;

procedure TUIWorkspace.MouseDown(const Button, x, y: Integer);
  var i: Integer;
  var McInChild: Boolean;
begin
  McInChild := False;
  for i := High(_Children) downto 0 do
  if _Children[i].Frame.Contains(x, y) then
  begin
    _Children[i].MouseDown(Button, x, y);
    McInChild := True;
  end;
  if not McInChild then Focus := Self;
  OnMouseDown(Button, x, y);
end;

procedure TUIWorkspace.MouseUp(const Button, x, y: Integer);
  var i: Integer;
begin
  for i := High(_Children) downto 0 do
  _Children[i].MouseUp(Button, x, y);
  OnMouseUp(Button, x, y);
end;

procedure TUIWorkspace.KeyDown(const Key: Integer);
  var i: Integer;
begin
  if not Focused then Exit;
  for i := High(_Children) downto 0 do
  _Children[i].KeyDown(Key);
  OnKeyDown(Key);
end;

procedure TUIWorkspace.KeyUp(const Key: Integer);
  var i: Integer;
begin
  if not Focused then Exit;
  for i := High(_Children) downto 0 do
  _Children[i].KeyUp(Key);
  OnKeyUp(Key);
end;

procedure TUIWorkspace.Scroll(const y: Integer);
  var i: Integer;
begin
  for i := High(_Children) downto 0 do
  if _Children[i].Frame.Contains(g2.MousePos) then
  _Children[i].Scroll(y);
  OnScroll(y);
end;

function TUIWorkspace.GetMinWidth: Single;
begin
  Result := 1;
end;

function TUIWorkspace.GetMinHeight: Single;
begin
  Result := 1;
end;

function TUIWorkspace.CanDragDrop(const Drop: TOverlayDrop): Boolean;
begin
  Result := False;
end;

class constructor TUIWorkspace.CreateClass;
begin
  Focus := nil;
end;

constructor TUIWorkspace.Create;
begin
  inherited Create;
  _Parent := nil;
  _CustomHeader := False;
  OnInitialize;
end;

destructor TUIWorkspace.Destroy;
  var i: Integer;
begin
  OnBeforeFinalize;
  for i := 0 to High(_Children) do
  _Children[i].Free;
  OnFinalize;
  inherited Destroy;
end;
//TUIWorkspace END

//TUIViews BEGIN
procedure TUIViews.OnTextEditUpdate;
  var TextPos: TG2Vec2;
begin
  if App.UI.TextEdit.Enabled then
  begin
    TextPos := ViewTextPos(EditView);
    EditView^.CaptionTextPos := TextPos;
    App.UI.TextEdit.Frame := G2Rect(
      TextPos.x, TextPos.y,
      App.UI.Font1.TextWidth(EditView^.Name),
      App.UI.Font1.TextHeight('A')
    );
  end
  else
  begin
    EditView := nil;
  end;
end;

function TUIViews.GetCurView: PView;
begin
  if ViewIndex > -1 then
  Result := PView(Views[ViewIndex])
  else
  Result := nil;
end;

procedure TUIViews.Initialize;
begin
  ViewTextClickTime := G2Time - 1000;
  EditView := nil;
  MouseDownView := -1;
  Views.Clear;
  ViewIndex := -1;
  Dragging := False;
  Adjust;
  AddView('View');
  //AddView('View');
end;

procedure TUIViews.Finalize;
  var i: Integer;
begin
  for i := 0 to Views.Count - 1 do
  begin
    if PView(Views[i])^.Workspace <> nil then
    PView(Views[i])^.Workspace.Free;
    Dispose(PView(Views[i]));
  end;
  Views.Clear;
end;

procedure TUIViews.Adjust;
  var i: Integer;
begin
  Height := 48;
  TabSpacing := 32;
  TabSeparatorSize := 10;
  OffsetX := 16;
  ShadingSize := 24;
  ShadingOffset := 8;
  i := G2Min(G2Min(TabSpacing, Height), 16);
  CloseRect.Left := (TabSpacing - i) div 2;
  CloseRect.Top := (Height - i) div 2;
  CloseRect.Right := CloseRect.Left + i;
  CloseRect.Bottom := CloseRect.Top + i;
  WorkspaceRect.Left := (TabSpacing - i) div 2;
  WorkspaceRect.Top := (Height - i) div 2;
  WorkspaceRect.Right := WorkspaceRect.Left + i;
  WorkspaceRect.Bottom := WorkspaceRect.Top + i;
  i := Height - TabSeparatorSize * 2;
  NewTabRect.Right := g2.Params.Width - OffsetX;
  NewTabRect.Left := NewTabRect.Right - i;
  NewTabRect.Top := (Height - i) div 2;
  NewTabRect.Bottom := NewTabRect.Top + i;
end;

procedure TUIViews.AdjustWorkspaces;
  var i: Integer;
begin
  for i := 0 to Views.Count - 1 do
  begin
    if PView(Views[i])^.Workspace <> nil then
    PView(Views[i])^.Workspace.Frame := App.UI.WorkspaceFrame;
  end;
end;

procedure TUIViews.Render;
begin
  RenderTabs;
  if (ViewIndex > -1) and (PView(Views[ViewIndex])^.Workspace <> nil) then
  PView(Views[ViewIndex])^.Workspace.Render;
end;

procedure TUIViews.Update;
  var InClose, InList, InText: Boolean;
  var TabFrame: TG2Rect;
  var mc: TPoint;
  var Ratio: Single;
  var Tab, NewTabPos: Integer;
  var View: PView;
begin
  if (ViewIndex > -1) then
  begin
    if (Views.Count > 1)
    and g2.MouseDown[G2MB_Left] then
    begin
      if not Dragging
      and (PointInView(g2.MouseDownPos[G2MB_Left].x, g2.MouseDownPos[G2MB_Left].y, InClose, InList, InText) = ViewIndex)
      and ((G2Vec2(g2.MousePos) - G2Vec2(g2.MouseDownPos[G2MB_Left])).Len > 8) then
      Dragging := True;
    end
    else
    Dragging := False;
    if Dragging then
    begin
      mc := g2.MousePos;
      Tab := PointInView(mc.x, mc.y, TabFrame);
      if (Tab > -1) and (Tab <> ViewIndex) then
      begin
        Ratio := (mc.x - TabFrame.l) / TabFrame.w;
        if (Ratio < 0.5) then
        NewTabPos := Tab - 1
        else
        NewTabPos := Tab + 1;
        if (NewTabPos <> ViewIndex) then
        begin
          View := Views[ViewIndex];
          Views.Delete(ViewIndex);
          if ViewIndex < NewTabPos then
          NewTabPos := NewTabPos - 1
          else
          NewTabPos := NewTabPos + 1;
          Views.Insert(NewTabPos, View);
          ViewIndex := NewTabPos;
        end;
      end;
    end;
    if (PView(Views[ViewIndex])^.Workspace <> nil) then
    PView(Views[ViewIndex])^.Workspace.Update;
  end;
end;

procedure TUIViews.RenderTabs;
  var i, w, h, x, x0, x1, x2, x3, x4, x5, y0, y1, y2, y3, y4, y5: Integer;
  var mc: TPoint;
  var r: TRect;
  var c, c0, c1: TG2Color;
  var View: PView;
  var PreSelected, InClose, InText, InList: Boolean;
begin
  mc := g2.MousePos;
  x := OffsetX;
  PreSelected := True;
  y0 := 0;
  y1 := TabSeparatorSize;
  y2 := TabSeparatorSize * 2;
  y3 := Height - ShadingSize - ShadingOffset;
  y4 := Height - ShadingOffset;
  y5 := Height;
  g2.PrimBegin(ptTriangles, bmNormal);
  if Views.Count = 0 then
  begin
    g2.PrimAdd(0, y3, $0);
    g2.PrimAdd(g2.Params.Width, y3, $0);
    g2.PrimAdd(0, y4, $ff000000);
    g2.PrimAdd(0, y4, $ff000000);
    g2.PrimAdd(g2.Params.Width, y3, $0);
    g2.PrimAdd(g2.Params.Width, y4, $ff000000);

    g2.PrimAdd(0, y4, $ff000000);
    g2.PrimAdd(g2.Params.Width, y4, $ff000000);
    g2.PrimAdd(0, y5, $0);
    g2.PrimAdd(0, y5, $0);
    g2.PrimAdd(g2.Params.Width, y4, $ff000000);
    g2.PrimAdd(g2.Params.Width, y5, $0);
  end;
  for i := 0 to Views.Count - 1 do
  begin
    View := PView(Views[i]);
    w := App.UI.Font1.TextWidth(View^.Name);
    h := App.UI.Font1.TextHeight('A');
    x0 := x - TabSeparatorSize;
    x1 := x;
    x2 := x + TabSeparatorSize;
    x3 := x1 + w + TabSpacing * 2 - TabSeparatorSize;
    x4 := x3 + TabSeparatorSize;
    x5 := x4 + TabSeparatorSize;
    if i = ViewIndex then
    begin
      if Dragging then
      begin
        c0 := App.UI.GetColorPrimary(1, 0);
        c1 := App.UI.GetColorPrimary(1);
      end
      else
      begin
        c0 := App.UI.GetColorSecondary(1, 0);
        c1 := App.UI.GetColorSecondary(1);
      end;
      g2.PrimAdd(0, y3, $0);
      g2.PrimAdd(x1, y3, $0);
      g2.PrimAdd(0, y4, $ff000000);
      g2.PrimAdd(0, y4, $ff000000);
      g2.PrimAdd(x1, y3, $0);
      g2.PrimAdd(x1, y4, $ff000000);

      g2.PrimAdd(0, y4, $ff000000);
      g2.PrimAdd(x1, y4, $ff000000);
      g2.PrimAdd(0, y5, $0);
      g2.PrimAdd(0, y5, $0);
      g2.PrimAdd(x1, y4, $ff000000);
      g2.PrimAdd(x1, y5, $0);

      g2.PrimAdd(x4, y3, $0);
      g2.PrimAdd(g2.Params.Width, y3, $0);
      g2.PrimAdd(x4, y4, $ff000000);
      g2.PrimAdd(x4, y4, $ff000000);
      g2.PrimAdd(g2.Params.Width, y3, $0);
      g2.PrimAdd(g2.Params.Width, y4, $ff000000);

      g2.PrimAdd(x4, y4, $ff000000);
      g2.PrimAdd(g2.Params.Width, y4, $ff000000);
      g2.PrimAdd(x4, y5, $0);
      g2.PrimAdd(x4, y5, $0);
      g2.PrimAdd(g2.Params.Width, y4, $ff000000);
      g2.PrimAdd(g2.Params.Width, y5, $0);

      g2.PrimAdd(x1, y5, c0);
      g2.PrimAdd(x0, y1, c0);
      g2.PrimAdd(x1, y1, c1);

      g2.PrimAdd(x1, y1, c1);
      g2.PrimAdd(x0, y1, c0);
      g2.PrimAdd(x1, y0, c0);

      g2.PrimAdd(x1, y1, c1);
      g2.PrimAdd(x1, y0, c0);
      g2.PrimAdd(x4, y0, c0);

      g2.PrimAdd(x1, y1, c1);
      g2.PrimAdd(x4, y0, c0);
      g2.PrimAdd(x4, y1, c1);

      g2.PrimAdd(x1, y5, c0);
      g2.PrimAdd(x1, y1, c1);
      g2.PrimAdd(x2, y2, $0);

      g2.PrimAdd(x1, y1, c1);
      g2.PrimAdd(x4, y1, c1);
      g2.PrimAdd(x2, y2, $0);

      g2.PrimAdd(x2, y2, $0);
      g2.PrimAdd(x4, y1, c1);
      g2.PrimAdd(x3, y2, $0);

      g2.PrimAdd(x3, y2, $0);
      g2.PrimAdd(x4, y1, c1);
      g2.PrimAdd(x4, y5, c0);

      g2.PrimAdd(x4, y1, c1);
      g2.PrimAdd(x4, y0, c0);
      g2.PrimAdd(x5, y1, c0);
      g2.PrimAdd(x4, y1, c1);
      g2.PrimAdd(x5, y1, c0);
      g2.PrimAdd(x4, y5, c0);

      g2.PrimEnd;
      g2.PrimRectCol(x1, y1, w + TabSpacing * 2, (Height - TabSeparatorSize * 2) * 0.5, $ff000000, $ff000000, $ff404040, $ff404040, bmAdd);
      g2.PrimRectCol(x1, TabSeparatorSize + (Height - TabSeparatorSize * 2) * 0.5, w + TabSpacing * 2, (Height - TabSeparatorSize * 2) * 0.5, $ff404040, $ff404040, $ff000000, $ff000000, bmAdd);
      g2.PrimBegin(ptTriangles, bmNormal);

      if not Dragging
      and (PointInView(mc.x, mc.y, InClose, InList, InText) = i) then
      begin
        r := Rect(
          x1 + TabSpacing + w + CloseRect.Left,
          CloseRect.Top,
          x1 + TabSpacing + w + CloseRect.Right,
          CloseRect.Bottom
        );
        if PtInRect(r, mc) then
        c := App.UI.GetColorSecondary(0.8)
        else
        c := App.UI.GetColorPrimary(0.8);
        App.UI.DrawCross(r, c);
        r := Rect(
          x1 + WorkspaceRect.Left,
          WorkspaceRect.Top,
          x1 + WorkspaceRect.Right,
          WorkspaceRect.Bottom
        );
        if PtInRect(r, mc) then
        c := App.UI.GetColorSecondary(0.8)
        else
        c := App.UI.GetColorPrimary(0.8);
        App.UI.DrawRects(r, c);
      end;

      PreSelected := False;
    end
    else
    begin
      if not PreSelected then
      x := x + w + TabSpacing * 2;
      g2.PrimAdd(x - TabSeparatorSize, Height - ShadingOffset, $0);
      g2.PrimAdd(x, 0, $0);
      g2.PrimAdd(x, Height - ShadingOffset, $ff000000);
      g2.PrimAdd(x, Height - ShadingOffset, $ff000000);
      g2.PrimAdd(x, 0, $0);
      g2.PrimAdd(x + TabSeparatorSize, Height - ShadingOffset, $0);
      if PreSelected then
      x := x + w + TabSpacing * 2;
    end;
    x := x4;
  end;
  if PtInRect(NewTabRect, mc) then
  c := App.UI.GetColorSecondary(0.8)
  else
  c := App.UI.GetColorPrimary(0.8);
  App.UI.DrawRectBorder(NewTabRect, TabSeparatorSize, App.UI.GetColorPrimary(0.8));
  App.UI.DrawPlus(NewTabRect, c);
  g2.PrimEnd;
  x := OffsetX;
  for i := 0 to Views.Count - 1 do
  begin
    View := PView(Views[i]);
    w := App.UI.Font1.TextWidth(View^.Name);
    h := App.UI.Font1.TextHeight('A');
    x := x + TabSpacing;
    if i = ViewIndex then
    begin
      App.UI.Font1.Print(x, (Height - h) * 0.5, View^.Name);
    end
    else
    begin
      App.UI.Font1.Print(x, (Height - h) * 0.5, 1, 1, App.UI.GetColorPrimary(0.6), View^.Name, bmNormal, tfPoint);
    end;
    x := x + w + TabSpacing;
  end;
end;

function TUIViews.ViewTextPos(const View: PView): TG2Vec2;
  var i, x, w: Integer;
begin
  x := OffsetX;
  for i := 0 to Views.Count - 1 do
  begin
    x := x + TabSpacing;
    w := App.UI.Font1.TextWidth(PView(Views[i])^.Name);
    if Views[i] = View then
    begin
      Result.x := x;
      Result.y := (Height - App.UI.Font1.TextHeight('A')) * 0.5;
      Exit;
    end;
    x := x + w + TabSpacing;
  end;
end;

function TUIViews.PointInView(
  const x, y: Integer;
  var InClose: Boolean;
  var InList: Boolean;
  var InText: Boolean;
  var TabFrame: TG2Rect
): Integer;
  var i, w, h, x0, x1: Integer;
  var View: PView;
  var r: TRect;
begin
  if (y < 0) or (y > Height) then
  begin
    Result := -1;
    InClose := False;
    Exit;
  end;
  x1 := OffsetX;
  for i := 0 to Views.Count - 1 do
  begin
    View := PView(Views[i]);
    w := App.UI.Font1.TextWidth(View^.Name);
    h := App.UI.Font1.TextHeight('A');
    x0 := x1;
    x1 := x1 + w + TabSpacing * 2;
    if (x > x0) and (x < x1) then
    begin
      Result := i;
      TabFrame.l := x0;
      TabFrame.r := x1;
      TabFrame.t := 0;
      TabFrame.b := Height;
      r := Rect(
        x0 + WorkspaceRect.Left,
        WorkspaceRect.Top,
        x0 + WorkspaceRect.Right,
        WorkspaceRect.Bottom
      );
      InList := PtInRect(r, Point(x, y));
      r := Rect(
        x0 + TabSpacing + w + CloseRect.Left,
        CloseRect.Top,
        x0 + TabSpacing + w + CloseRect.Right,
        CloseRect.Bottom
      );
      InClose := PtInRect(r, Point(x, y));
      r := Rect(
        x0 + TabSpacing,
        (Height - h) div 2,
        x0 + TabSpacing + w,
        (Height + h) div 2
      );
      InText := PtInRect(r, Point(x, y));
      Exit;
    end;
  end;
  if PtInRect(NewTabRect, Point(x, y)) then
  begin
    Result := Views.Count;
    InClose := False;
    Exit;
  end;
  Result := -1;
  InClose := False;
end;

function TUIViews.PointInView(const x, y: Integer; var InClose: Boolean; var InList: Boolean; var InText: Boolean): Integer;
  var TabFrame: TG2Rect;
begin
  Result := PointInView(x, y, InClose, InList, InText, TabFrame);
end;

function TUIViews.PointInView(const x, y: Integer; var TabFrame: TG2Rect): Integer;
  var InClose, InList, InText: Boolean;
begin
  Result := PointInView(x, y, InClose, InList, InText, TabFrame);
end;

function TUIViews.FindFrameWorkpace(const x, y: Single): TUIWorkspace;
  var View: PView;
  var Workspace: TUIWorkspace;
  var i, j: Integer;
begin
  Result := nil;
  View := CurView;
  if View <> nil then
  begin
    if View^.Workspace = nil then Exit;
    if not View^.Workspace.Frame.Contains(x, y) then Exit;
    if View^.Workspace is TUIWorkspaceFrame then
    begin
      Result := View^.Workspace;
      Exit;
    end;
    Workspace := View^.Workspace;
    while (Workspace <> nil) and not (Workspace is TUIWorkspaceFrame) do
    begin
      j := -1;
      for i := 0 to Workspace.ChildCount - 1 do
      if Workspace.Children[i].Frame.Contains(x, y) then
      begin
        j := i;
        Break;
      end;
      if j > -1 then
      Workspace := Workspace.Children[j]
      else
      Exit;
    end;
    Result := Workspace;
  end;
end;

procedure TUIViews.OnMouseDown(const Button, x, y: Integer);
  var InClose, InList, InText: Boolean;
  var t: TG2IntU32;
begin
  t := G2Time;
  MouseDownView := PointInView(x, y, InClose, InList, InText);
  if (MouseDownView > -1) and (MouseDownView = ViewIndex) and (InText) then
  begin
    if (t - ViewTextClickTime < 1000) then
    begin
      EditView := PView(Views[ViewIndex]);
      App.UI.TextEdit.Enable(@EditView^.Name, @EditView^.CaptionTextPos, App.UI.Font1, @OnTextEditUpdate, EditView^.Name);
      App.UI.TextEdit.MaxLength := 32;
      OnTextEditUpdate;
      App.UI.TextEdit.AdjustCursor(x, y);
    end
    else
    ViewTextClickTime := t;
  end
  else
  begin
    ViewTextClickTime := t - 1000;
    if PtInRect(App.UI.WorkspaceFrame, Point(x, y)) then
    begin
      if (ViewIndex > -1) and (PView(Views[ViewIndex])^.Workspace <> nil) then
      PView(Views[ViewIndex])^.Workspace.MouseDown(Button, x, y);
    end
  end;
end;

procedure TUIViews.OnMouseUp(const Button, x, y: Integer);
  var InClose, InList, InText: Boolean;
  var Pos: TG2Vec2;
begin
  Dragging := False;
  if (MouseDownView > -1) and (MouseDownView = PointInView(x, y, InClose, InList, InText)) then
  begin
    if MouseDownView = Views.Count then
    begin
      AddView('View');
    end
    else
    begin
      if ViewIndex = MouseDownView then
      begin
        if InClose then
        begin
          DeleteView(ViewIndex);
        end
        else if InList then
        begin
          Pos := ViewTextPos(Views[ViewIndex]);
          Pos.x := Pos.x + App.UI.Font1.TextWidth(PView(Views[ViewIndex])^.Name) * 0.5;
          Pos.y := Height;
          App.UI.Overlay := App.UI.OverlayWorkspaceList;
          App.UI.OverlayWorkspaceList.Initialize(Pos);
        end;
      end
      else
      ViewIndex := MouseDownView;
    end;
  end;
  MouseDownView := -1;
  if (ViewIndex > -1) and (PView(Views[ViewIndex])^.Workspace <> nil) then
  PView(Views[ViewIndex])^.Workspace.MouseUp(Button, x, y);
end;

procedure TUIViews.OnScroll(const y: Integer);
begin
  if PtInRect(App.UI.WorkspaceFrame, g2.MousePos) then
  begin
    if (ViewIndex > -1) and (PView(Views[ViewIndex])^.Workspace <> nil) then
    PView(Views[ViewIndex])^.Workspace.Scroll(y);
  end
end;

function TUIViews.AddView(const Name: AnsiString): PView;
  var CurName: AnsiString;
  var i: Integer;
begin
  CurName := Name;
  i := 1;
  while FindView(CurName) > -1 do
  begin
    CurName := Name + IntToStr(i);
    Inc(i);
  end;
  MouseDownView := -1;
  New(Result);
  Result^.Name := CurName;
  Result^.Workspace := nil;
  Views.Add(Result);
  ViewIndex := Views.Count - 1;
  //App.UI.TextEdit.Enable(@View^.Name, App.UI.Font1, @OnTextEditUpdate, View^.Name);
  //App.UI.TextEdit.MaxLength := 32;
  //EditView := View;
  //OnTextEditUpdate;
end;

procedure TUIViews.DeleteView(const Name: AnsiString);
  var i: Integer;
begin
  i := FindView(Name);
  if i > -1 then
  DeleteView(i);
end;

procedure TUIViews.DeleteView(const Index: Integer);
begin
  if PView(Views[Index])^.Workspace <> nil then
  CloseWorkspace(PView(Views[Index])^.Workspace);
  Dispose(PView(Views[Index]));
  Views.Delete(Index);
  if Index = ViewIndex then
  ViewIndex := G2Min(G2Max(ViewIndex, -1), Views.Count - 1);
end;

procedure TUIViews.SelectView(const Name: AnsiString);
  var i: Integer;
begin
  i := FindView(Name);
  if i > -1 then
  SelectView(i);
end;

procedure TUIViews.SelectView(const Index: Integer);
begin
  ViewIndex := Index;
end;

procedure TUIViews.Clear;
begin
  while Views.Count > 0 do
  DeleteView(Views.Count - 1);
end;

function TUIViews.FindView(const Name: AnsiString): Integer;
  var i: Integer;
begin
  for i := 0 to Views.Count - 1 do
  if LowerCase(PView(Views[i])^.Name) = LowerCase(Name) then
  begin
    Result := i;
    Exit;
  end;
  Result := -1;
end;

procedure TUIViews.ReplaceWorkspace(const WorkspaceOld, WorkspaceNew: TUIWorkspace);
  var Parent: TUIWorkspace;
  var i: Integer;
begin
  if WorkspaceOld.Parent <> nil then
  begin
    Parent := WorkspaceOld.Parent;
    Parent.ChildReplace(WorkspaceOld, WorkspaceNew);
  end
  else
  begin
    for i := 0 to Views.Count - 1 do
    if PView(Views[i])^.Workspace = WorkspaceOld then
    begin
      PView(Views[i])^.Workspace := WorkspaceNew;
      WorkspaceOld.Parent := nil;
      WorkspaceNew.Parent := nil;
      PView(Views[i])^.Workspace.Frame := App.UI.WorkspaceFrame;
    end;
  end;
end;

procedure TUIViews.ExtractWorkspace(const Workspace: TUIWorkspace);
  var i: Integer;
  var Parent, Sibling: TUIWorkspace;
begin
  for i := 0 to Views.Count - 1 do
  if PView(Views[i])^.Workspace = Workspace then
  begin
    PView(Views[i])^.Workspace := nil;
    Break;
  end;
  Parent := Workspace.Parent;
  Workspace.Parent := nil;
  if Parent <> nil then
  begin
    if Parent is TUIWorkspaceSplitter then
    begin
      if Parent.ChildCount = 1 then
      begin
        Sibling := Parent.Children[0];
        Sibling.Parent := nil;
        ReplaceWorkspace(Parent, Sibling);
      end;
      Parent.Parent := nil;
      Parent.Free;
    end
    else if (Parent is TUIWorkspaceFrame) and (Parent.ChildCount = 0) then
    begin
      CloseWorkspace(Parent);
    end;
  end;
end;

procedure TUIViews.CloseWorkspace(const Workspace: TUIWorkspace);
begin
  ExtractWorkspace(Workspace);
  Workspace.Free;
end;

function TUIViews.InsertWorkspace(const Workspace: TUIWorkspace; const Pos: TG2Vec2): Boolean;
  var Parent, Sibling, Frame, Splitter: TUIWorkspace;
  var InsertionPos: TUIWorkspaceInsertPosition;
begin
  if PtInRect(App.UI.WorkspaceFrame, Pos) and (ViewIndex > -1) then
  begin
    if PView(Views[ViewIndex])^.Workspace = nil then
    begin
      PView(Views[ViewIndex])^.Workspace := TUIWorkspaceFrame.Create;
      PView(Views[ViewIndex])^.Workspace.Frame := App.UI.WorkspaceFrame;
      Workspace.Parent := PView(Views[ViewIndex])^.Workspace;
      Result := True;
    end
    else
    begin
      Sibling := FindFrameWorkpace(Pos.x, Pos.y);
      if Sibling <> nil then
      begin
        InsertionPos := TUIWorkspaceFrame(Sibling).GetInsertPositon(Pos.x, Pos.y);
        if TUIWorkspaceFrame(Sibling).CanInsert(Workspace, InsertionPos) then
        begin
          if InsertionPos = ipMiddle then
          begin
            Workspace.OnTabInsert(TUIWorkspaceFrame(Sibling));
            Result := True;
          end
          else
          begin
            Parent := Sibling.Parent;
            if Parent = nil then
            begin
              Splitter := TUIWorkspaceSplitter.Create;
              Splitter.Frame := App.UI.WorkspaceFrame;
              PView(Views[ViewIndex])^.Workspace := Splitter;
              Frame := TUIWorkspaceFrame.Create;
              Workspace.Parent := Frame;
              Sibling.Parent := nil;
              Result := True;
            end
            else if Parent is TUIWorkspaceSplitter then
            begin
              Splitter := TUIWorkspaceSplitter.Create;
              TUIWorkspaceSplitter(Parent).ChildReplace(Sibling, Splitter);
              Frame := TUIWorkspaceFrame.Create;
              Workspace.Parent := Frame;
              Sibling.Parent := nil;
              Result := True;
            end
            else
            Result := False;
            if Result then
            begin
              case InsertionPos of
                ipLeft:
                begin
                  TUIWorkspaceSplitter(Splitter).Orientation := soHorizontal;
                  Frame.Parent := Splitter;
                  Sibling.Parent := Splitter;
                end;
                ipRight:
                begin
                  TUIWorkspaceSplitter(Splitter).Orientation := soHorizontal;
                  Sibling.Parent := Splitter;
                  Frame.Parent := Splitter;
                end;
                ipTop:
                begin
                  TUIWorkspaceSplitter(Splitter).Orientation := soVertical;
                  Frame.Parent := Splitter;
                  Sibling.Parent := Splitter;
                end;
                ipBottom:
                begin
                  TUIWorkspaceSplitter(Splitter).Orientation := soVertical;
                  Sibling.Parent := Splitter;
                  Frame.Parent := Splitter;
                end;
              end;
            end;
          end;
        end
        else
        Result := False;
      end
      else
      Result := False;
    end;
  end
  else
  Result := False;
end;
//TUIViews END

//TUITextEditImplementation BEGIN
function TUITextEditImplementation.GetCursorFlicker: Boolean;
begin
  Result := (G2Time - _CursorFlickerTime) mod 1000 < 500;
end;

procedure TUITextEditImplementation.ResetCursorFlicker;
begin
  _CursorFlickerTime := G2Time;
end;

procedure TUITextEditImplementation.Render;
begin

end;

procedure TUITextEditImplementation.Update;
begin

end;

procedure TUITextEditImplementation.OnEnable;
begin

end;

procedure TUITextEditImplementation.OnDisable;
begin

end;

procedure TUITextEditImplementation.AdjustCursor(const ScrX, ScrY: Single);
begin

end;

procedure TUITextEditImplementation.OnMouseDown(const x, y: Integer);
begin

end;

procedure TUITextEditImplementation.OnMouseUp(const x, y: Integer);
begin

end;

procedure TUITextEditImplementation.OnScroll(const y: Integer);
begin

end;

procedure TUITextEditImplementation.OnPrint(const Char: AnsiChar);
begin

end;

procedure TUITextEditImplementation.OnKeyDown(const Key: TG2IntS32);
begin

end;

procedure TUITextEditImplementation.OnKeyUp(const Key: TG2IntS32);
begin

end;

procedure TUITextEditImplementation.TextUpdated;
begin

end;

function TUITextEditImplementation.GetCursorPos: TG2Vec2;
begin
  Result := G2Vec2(0, 0);
end;

//TUITextEditImplementation END

//TUITextEditSingleLine BEGIN
function TUITextEditSingleLine.HaveSelection: Boolean;
begin
  Result := CursorStart <> CursorEnd;
end;

procedure TUITextEditSingleLine.CursorMove;
  var cp: TG2Vec2;
  var s: Single;
begin
  if AutoAdjustTextPos then
  begin
    cp := GetCursorPos;
    s := Frame^.w * 0.25;
    if s > 0 then
    begin
      while cp.x < Frame^.l + 4 do
      begin
        TextPos^.x := G2Min(Frame^.l + 4, TextPos^.x + s);
        cp.x := cp.x + s;
      end;
      while cp.x > Frame^.r do
      begin
        TextPos^.x := TextPos^.x - s;
        cp.x := cp.x - s;
      end;
    end;
  end;
  if Assigned(OnCursorMoveProc) then
  OnCursorMoveProc;
end;

function TUITextEditSingleLine.FindCursorPos(const ScrPos: Single): Integer;
  var CurX, w: TG2Float;
  var i: Integer;
begin
  Result := -1;
  CurX := TextPos^.x;
  for i := 0 to Length(Text^) - 1 do
  begin
    w := Font.TextWidth(Text^[i + 1]);
    if ScrPos < CurX + w * 0.5 then
    begin
      Result := i;
      Break;
    end;
    CurX := CurX + w;
  end;
  if Result = -1 then
  Result := Length(Text^);
end;

procedure TUITextEditSingleLine.CheckSelection;
  var Tmp: Integer;
begin
  if (Selection = @CursorEnd) and (Selection^ < CursorStart) then
  begin
    Tmp := CursorEnd;
    CursorEnd := CursorStart;
    CursorStart := Tmp;
    Selection := @CursorStart;
    CursorMove;
  end
  else if (Selection = @CursorStart) and (Selection^ > CursorEnd) then
  begin
    Tmp := CursorEnd;
    CursorEnd := CursorStart;
    CursorStart := Tmp;
    Selection := @CursorEnd;
    CursorMove;
  end;
end;

procedure TUITextEditSingleLine.Render;
  var x, y, w, h: Single;
  var bm: TG2BlendMode;
begin
  if not HaveSelection and not GetCursorFlicker then Exit;
  x := TextPos^.x - 1 + Font.TextWidth(Text^, 1, CursorStart);
  y := TextPos^.y;
  w := Font.TextWidth(Text^, CursorStart + 1, CursorEnd) + 1;
  h := Font.TextHeight('A');
  bm.ColorDst := boZero;
  bm.ColorSrc := boInvDstColor;
  bm.AlphaDst := boOne;
  bm.AlphaDst := boZero;
  g2.PrimRect(x, y, w, h, $ffffffff, bm);
end;

procedure TUITextEditSingleLine.Update;
begin
  if g2.MouseDown[G2MB_Left] then
  begin
    Selection^ := FindCursorPos(g2.MousePos.x);
    CheckSelection;
  end;
end;

procedure TUITextEditSingleLine.OnEnable;
begin

end;

procedure TUITextEditSingleLine.OnDisable;
begin
  if not AllowEmpty and (Length(Text^) <= 0) then
  Text^ := DefaultText;
  if Assigned(OnChangeProc) then
  OnChangeProc;
end;

procedure TUITextEditSingleLine.AdjustCursor(const ScrX, ScrY: Single);
begin
  CursorStart := FindCursorPos(ScrX);
  CursorEnd := CursorStart;
end;

procedure TUITextEditSingleLine.OnMouseDown(const x, y: Integer);
begin
  CursorStart := FindCursorPos(x);
  CursorEnd := CursorStart;
  Selection := @CursorEnd;
  CursorMove;
  ResetCursorFlicker;
end;

procedure TUITextEditSingleLine.OnMouseUp(const x, y: Integer);
begin
  CheckSelection;
  CursorMove;
end;

procedure TUITextEditSingleLine.OnPrint(const Char: AnsiChar);
  var StrFirst, StrLast: AnsiString;
begin
  if (CursorStart <> CursorEnd) or ((MaxLength^ <= 0) or (Length(Text^) < MaxLength^)) then
  begin
    if (CursorStart > 0) then
    StrFirst := G2StrCut(Text^, 1, CursorStart)
    else
    StrFirst := '';
    if (CursorEnd < Length(Text^)) then
    StrLast := G2StrCut(Text^, CursorEnd + 1, Length(Text^))
    else
    StrLast := '';
    Text^ := StrFirst + Char + StrLast;
    CursorStart := CursorStart + 1;
    CursorEnd := CursorStart;
    if Assigned(OnChangeProc) then
    OnChangeProc;
    CursorMove;
    ResetCursorFlicker;
  end;
end;

procedure TUITextEditSingleLine.OnKeyDown(const Key: TG2IntS32);
  var StrFirst, StrLast, Str: AnsiString;
begin
  case Key of
    G2K_C:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) and (CursorEnd > CursorStart) then
      Clipboard.AsText := G2StrCut(Text^, CursorStart + 1, CursorEnd);
    end;
    G2K_V:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        Str := Clipboard.AsText;
        if Length(Str) > 0 then
        begin
          if (CursorStart > 0) then
          StrFirst := G2StrCut(Text^, 1, CursorStart)
          else
          StrFirst := '';
          if (CursorEnd < Length(Text^)) then
          StrLast := G2StrCut(Text^, CursorEnd + 1, Length(Text^))
          else
          StrLast := '';
          CursorStart := CursorStart + Length(Str);
          CursorEnd := CursorStart;
          Text^ := StrFirst + Str + StrLast;
          if Assigned(OnChangeProc) then
          OnChangeProc;
          CursorMove;
          ResetCursorFlicker;
        end;
      end;
    end;
    G2K_Left:
    begin
      if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
      begin
        if (Selection^ > 0) then
        begin
          Dec(Selection^);
          CheckSelection;
        end;
      end
      else
      begin
        if CursorStart <> CursorEnd then
        CursorEnd := CursorStart
        else if CursorStart > 0 then
        begin
          Dec(CursorStart);
          if (g2.KeyDown[G2K_CtrlL]) or (g2.KeyDown[G2K_CtrlR]) then
          begin
            while (CursorStart > 0) do
            begin
              if (CursorStart > 1) and (Text^[CursorStart] in App.UI.TextEdit.JumpBreakers) then
              Break
              else
              Dec(CursorStart);
            end;
          end;
          CursorEnd := CursorStart;
          CursorMove;
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Right:
    begin
      if (g2.KeyDown[G2K_ShiftL]) or g2.KeyDown[G2K_ShiftR] then
      begin
        if (Selection^ < Length(Text^)) then
        begin
          Inc(Selection^);
          CheckSelection;
        end;
      end
      else
      begin
        if CursorStart <> CursorEnd then
        CursorStart := CursorEnd
        else if CursorEnd < Length(Text^) then
        begin
          Inc(CursorEnd);
          if (g2.KeyDown[G2K_CtrlL]) or (g2.KeyDown[G2K_CtrlR]) then
          begin
            while (CursorEnd < Length(Text^)) do
            begin
              if (CursorEnd < Length(Text^) - 1) and (Text^[CursorEnd + 1] in App.UI.TextEdit.JumpBreakers) then
              Break
              else
              Inc(CursorEnd);
            end;
          end;
          CursorStart := CursorEnd;
          CursorMove;
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Back:
    begin
      if CursorStart <> CursorEnd then
      begin
        if (CursorStart > 0) then
        StrFirst := G2StrCut(Text^, 1, CursorStart)
        else
        StrFirst := '';
        if (CursorEnd < Length(Text^)) then
        StrLast := G2StrCut(Text^, CursorEnd + 1, Length(Text^))
        else
        StrLast := '';
        CursorEnd := CursorStart;
        Text^ := StrFirst + StrLast;
        if Assigned(OnChangeProc) then
        OnChangeProc;
        CursorMove;
      end
      else if CursorStart > 0 then
      begin
        Dec(CursorStart);
        if (CursorStart > 0) then
        StrFirst := G2StrCut(Text^, 1, CursorStart)
        else
        StrFirst := '';
        if (CursorEnd < Length(Text^)) then
        StrLast := G2StrCut(Text^, CursorEnd + 1, Length(Text^))
        else
        StrLast := '';
        CursorEnd := CursorStart;
        Text^ := StrFirst + StrLast;
        if Assigned(OnChangeProc) then
        OnChangeProc;
        CursorMove;
      end;
      ResetCursorFlicker;
    end;
    G2K_Delete:
    begin
      if CursorStart <> CursorEnd then
      begin
        if (CursorStart > 0) then
        StrFirst := G2StrCut(Text^, 1, CursorStart)
        else
        StrFirst := '';
        if (CursorEnd < Length(Text^)) then
        StrLast := G2StrCut(Text^, CursorEnd + 1, Length(Text^))
        else
        StrLast := '';
        CursorEnd := CursorStart;
        Text^ := StrFirst + StrLast;
        if Assigned(OnChangeProc) then
        OnChangeProc;
        CursorMove;
      end
      else if CursorEnd < Length(Text^) then
      begin
        Inc(CursorEnd);
        if (CursorStart > 0) then
        StrFirst := G2StrCut(Text^, 1, CursorStart)
        else
        StrFirst := '';
        if (CursorEnd < Length(Text^)) then
        StrLast := G2StrCut(Text^, CursorEnd + 1, Length(Text^))
        else
        StrLast := '';
        CursorEnd := CursorStart;
        Text^ := StrFirst + StrLast;
        if Assigned(OnChangeProc) then
        OnChangeProc;
        CursorMove;
      end;
      ResetCursorFlicker;
    end;
    G2K_Return:
    begin
      if Assigned(OnEnterProc) then
      OnEnterProc
      else
      DisableProc;
      ResetCursorFlicker;
    end;
    G2K_Escape:
    begin
      DisableProc;
    end;
  end;
end;

procedure TUITextEditSingleLine.OnKeyUp(const Key: TG2IntS32);
begin

end;

procedure TUITextEditSingleLine.TextUpdated;
begin
  if CursorStart > Length(Text^) then
  CursorStart := Length(Text^);
  if CursorEnd > Length(Text^) then
  CursorEnd := Length(Text^);
  CheckSelection;
end;

function TUITextEditSingleLine.GetCursorPos: TG2Vec2;
begin
  Result.y := TextPos^.y + Font.TextHeight('A');
  Result.x := TextPos^.x + Font.TextWidth(Text^, 1, Selection^);
end;

constructor TUITextEditSingleLine.Create;
begin
  inherited Create;
  AutoAdjustTextPos := False;
  Selection := @CursorEnd;
end;
//TUITextEditSingleLine END

//TUITextEditCode BEGIN
procedure TUITextEditCode.MergeCursor;
begin
  CursorStart := Selection^;
  CursorEnd := CursorStart;
end;

procedure TUITextEditCode.JumpCursor(const Dir: Integer);
  var JumpChar, c: AnsiChar;
begin
  if (Dir = -1)
  and (Selection^.x = 0) then
  begin
    if (Selection^.y > 0) then
    begin
      Dec(Selection^.y);
      if (Selection^.y < Length(Text^.Lines)) then
      Selection^.x := Length(Text^.Lines[Selection^.y]);
    end;
  end
  else if (Dir = -1)
  and (Selection^.y >= Length(Text^.Lines)) then
  begin
    Selection^.x := 0;
  end
  else if (Dir = 1)
  and (
    (
      (Selection^.y < Length(Text^.Lines))
      and (Selection^.x >= Length(Text^.Lines[Selection^.y]))
    )
    or (
      (Selection^.y > Length(Text^.Lines))
    )
  ) then
  begin
    Inc(Selection^.y);
    Selection^.x := 0;
  end
  else if Selection^.y < Length(Text^.Lines) then
  begin
    if Dir = -1 then
    begin
      if Selection^.x > Length(Text^.Lines[Selection^.y]) then
      JumpChar := ' '
      else
      JumpChar := Text^.Lines[Selection^.y][Selection^.x];
      Dec(Selection^.x);
      while Selection^.x > 0 do
      begin
        if Selection^.x > Length(Text^.Lines[Selection^.y]) then
        c := ' '
        else
        c := Text^.Lines[Selection^.y][Selection^.x];
        if (
          (JumpChar = ' ') and (c <> JumpChar)
        )
        or (
          (JumpChar <> ' ') and (c in App.UI.TextEdit.JumpBreakers)
        ) then
        Break
        else
        Dec(Selection^.x);
      end;
    end
    else if Dir = 1 then
    begin
      Inc(Selection^.x);
      JumpChar := Text^.Lines[Selection^.y][Selection^.x];
      while Selection^.x < Length(Text^.Lines[Selection^.y]) do
      begin
        c := Text^.Lines[Selection^.y][Selection^.x + 1];
        if (
          (JumpChar = ' ') and (c <> JumpChar)
        )
        or (
          (JumpChar <> ' ') and (c in App.UI.TextEdit.JumpBreakers)
        ) then
        Break
        else
        Inc(Selection^.x);
      end;
    end;
  end;
  CheckSelection;
end;

procedure TUITextEditCode.DoCopy;
begin
  Clipboard.AsText := GetSelectionStr;
end;

procedure TUITextEditCode.DoPaste;
begin
  InsertStrSaveUndo(Clipboard.AsText);
end;

procedure TUITextEditCode.DoMultiComment(const SaveUndo: Boolean);
  var i, ls, le: Integer;
begin
  ls := CursorStart.y;
  le := CursorEnd.y;
  if SaveUndo then
  Text^.AddUndoActionComment(ls, le);
  for i := ls to le do
  begin
    Selection^.x := 0;
    Selection^.y := i;
    MergeCursor;
    InsertStr('//');
  end;
  CursorStart.x := 0;
  CursorStart.y := ls;
  if le <= High(Text^.Lines) then
  CursorEnd.x :=  Length(Text^.Lines[le])
  else
  CursorEnd.x := 0;
  CursorEnd.y := le;
  Text^.Modified := True;
end;

procedure TUITextEditCode.DoMultiUnComment(const SaveUndo: Boolean);
  var i, j, n, ls, le: Integer;
begin
  ls := CursorStart.y;
  le := CursorEnd.y;
  if SaveUndo then
  Text^.AddUndoActionUnComment(ls, le);
  for i := ls to le do
  if i <= High(Text^.Lines) then
  begin
    n := G2StrInStr(Text^.Lines[i], '//');
    for j := 1 to n - 1 do
    if Text^.Lines[i][j] <> ' ' then
    begin
      n := 0;
      Break;
    end;
    if n > 0 then
    begin
      CursorStart.y := i;
      CursorStart.x := n - 1;
      CursorEnd.y := i;
      CursorEnd.x := n + 1;
      InsertStr('');
    end;
  end;
  CursorStart.x := 0;
  CursorStart.y := ls;
  if le <= High(Text^.Lines) then
  CursorEnd.x :=  Length(Text^.Lines[le])
  else
  CursorEnd.x := 0;
  CursorEnd.y := le;
  Text^.Modified := True;
end;

procedure TUITextEditCode.DoIndent(const SaveUndo: Boolean);
  var i, ls, le: Integer;
begin
  ls := CursorStart.y;
  le := CursorEnd.y;
  if SaveUndo then
  Text^.AddUndoActionIndent(ls, le);
  for i := ls to le do
  begin
    Selection^.x := 0;
    Selection^.y := i;
    MergeCursor;
    InsertStr('  ');
  end;
  CursorStart.x := 0;
  CursorStart.y := ls;
  if le <= High(Text^.Lines) then
  CursorEnd.x :=  Length(Text^.Lines[le])
  else
  CursorEnd.x := 0;
  CursorEnd.y := le;
  Text^.Modified := True;
end;

procedure TUITextEditCode.DoUnIndent(const SaveUndo: Boolean);
  var i, j, ls, le: Integer;
begin
  ls := CursorStart.y;
  le := CursorEnd.y;
  if SaveUndo then
  Text^.AddUndoActionUnIndent(ls, le);
  for i := ls to le do
  if i <= High(Text^.Lines) then
  begin
    for j := 0 to 1 do
    begin
      if (Length(Text^.Lines[i]) > 0)
      and (Text^.Lines[i][1] = ' ') then
      begin
        CursorStart.y := i;
        CursorStart.x := 0;
        CursorEnd.y := i;
        CursorEnd.x := 1;
        InsertStr('');
      end;
    end;
  end;
  CursorStart.x := 0;
  CursorStart.y := ls;
  if le <= High(Text^.Lines) then
  CursorEnd.x :=  Length(Text^.Lines[le])
  else
  CursorEnd.x := 0;
  CursorEnd.y := le;
  Text^.Modified := True;
end;

function TUITextEditCode.HaveSelection: Boolean;
begin
  Result := (CursorStart.x <> CursorEnd.x) or (CursorStart.y <> CursorEnd.y);
end;

function TUITextEditCode.MakeSpaces(const Count: Integer): AnsiString;
begin
  SetLength(Result, Count);
  FillChar(Result[1], Count, ' ');
end;

function TUITextEditCode.StrCut(const Line, PosStart, PosEnd: Integer): AnsiString;
  var i: Integer;
begin
  if Line < Length(Text^.Lines) then
  begin
    if PosStart <= Length(Text^.Lines[Line]) then
    begin
      if PosEnd <= Length(Text^.Lines[Line]) then
      begin
        Result := G2StrCut(Text^.Lines[Line], PosStart, PosEnd);
        Exit;
      end;
      SetLength(Result, PosEnd - PosStart + 1);
      Move(Text^.Lines[Line][PosStart], Result[1], Length(Text^.Lines[Line]) - PosStart + 1);
      for i := Length(Text^.Lines[Line]) - PosStart + 2 to Length(Result) do
      Result[i] := ' ';
      Exit;
    end;
  end;
  SetLength(Result, PosEnd - PosStart + 1);
  for i := 1 to Length(Result) do
  Result[i] := ' ';
end;

function TUITextEditCode.GetSelectionStr: AnsiString;
  var i: Integer;
begin
  if not HaveSelection then
  begin
    Result := '';
    Exit;
  end;
  if CursorStart.y = CursorEnd.y then
  Result := StrCut(Selection^.y, CursorStart.x + 1, CursorEnd.x)
  else
  begin
    if (CursorStart.y < Length(Text^.Lines))
    and (CursorStart.x < Length(Text^.Lines[CursorStart.y])) then
    Result := StrCut(CursorStart.y, CursorStart.x + 1, Length(Text^.Lines[CursorStart.y]))
    else
    Result := '';
    for i := CursorStart.y + 1 to CursorEnd.y - 1 do
    if i < Length(Text^.Lines) then
    Result := Result + #$D#$A + Text^.Lines[i]
    else
    Result := Result + #$D#$A;
    if CursorEnd.y < Length(Text^.Lines) then
    Result := Result + #$D#$A + StrCut(CursorEnd.y, 1, CursorEnd.x)
    else
    Result := Result + #$D#$A;
  end;
end;

procedure TUITextEditCode.DeleteLine(const Index: Integer; const Count: Integer);
  var i: Integer;
begin
  if (Count > 0) and (Index <= High(Text^.Lines)) then
  begin
    for i := Index to High(Text^.Lines) - Count do
    if i + Count <= High(Text^.Lines) then
    Text^.Lines[i] := Text^.Lines[i + Count];
    SetLength(Text^.Lines, Length(Text^.Lines) - G2Min(Count, Length(Text^.Lines) - Index));
  end;
end;

procedure TUITextEditCode.InsertLine(const Index: Integer);
  var i: Integer;
begin
  if Index > High(Text^.Lines) then
  begin
    SetLength(Text^.Lines, Index + 1);
  end
  else
  begin
    SetLength(Text^.Lines, Length(Text^.Lines) + 1);
    for i := High(Text^.Lines) downto Index + 1 do
    Text^.Lines[i] := Text^.Lines[i - 1];
  end;
  Text^.Lines[Index] := '';
end;

procedure TUITextEditCode.StripSpaces(const Index: Integer);
  var i, n: Integer;
begin
  if Index > High(Text^.Lines) then Exit;
  n := 0;
  for i := Length(Text^.Lines[Index]) downto 1 do
  if Text^.Lines[Index][i] = ' ' then
  Inc(n)
  else
  Break;
  if n > 0 then
  SetLength(Text^.Lines[Index], Length(Text^.Lines[Index]) - n);
end;

procedure TUITextEditCode.InsertStr(const Str: AnsiString);
  var StrPrev, StrNext, StrMid: AnsiString;
  var StrArr: TG2StrArrA;
  var n: Integer;
begin
  if (CursorStart.x > 0) then
  begin
    if CursorStart.y < Length(Text^.Lines) then
    StrPrev := StrCut(CursorStart.y, 1, CursorStart.x)
    else
    StrPrev := MakeSpaces(CursorStart.x);
  end
  else
  StrPrev := '';
  if (CursorEnd.y < Length(Text^.Lines)) and (CursorEnd.x < Length(Text^.Lines[CursorEnd.y])) then
  StrNext := StrCut(CursorEnd.y, CursorEnd.x + 1, Length(Text^.Lines[CursorEnd.y]))
  else
  StrNext := '';
  StrMid := '';
  StrMid := G2StrReplace(Str, #$D#$A, #$D);
  StrMid := G2StrReplace(StrMid, #$A, #$D);
  StrArr := G2StrExplode(StrMid, #$D);
  n := CursorEnd.y - CursorStart.y;
  if n > 0 then
  DeleteLine(CursorStart.y + 1, n);
  Selection^ := CursorStart;
  if Selection^.y > High(Text^.Lines) then
  InsertLine(Selection^.y);
  Text^.Lines[Selection^.y] := StrPrev;
  if Length(StrArr) > 0 then
  begin
    Text^.Lines[Selection^.y] := Text^.Lines[Selection^.y] + StrArr[0];
    Selection^.x := Selection^.x + Length(StrArr[0]);
    if Length(StrArr) > 1 then
    StripSpaces(Selection^.y);
    for n := 1 to High(StrArr) do
    begin
      Inc(Selection^.y);
      InsertLine(Selection^.y);
      Text^.Lines[Selection^.y] := StrArr[n];
      Selection^.x := Length(StrArr[n]);
      if n < High(StrArr) then
      StripSpaces(Selection^.y);
    end;
  end;
  Text^.Lines[Selection^.y] := Text^.Lines[Selection^.y] + StrNext;
  StripSpaces(Selection^.y);
  MergeCursor;
  if Assigned(OnCursorMoveProc) then
  OnCursorMoveProc;
  if Assigned(OnChangeProc) then
  OnChangeProc;
end;

procedure TUITextEditCode.InsertStrSaveUndo(const Str: AnsiString);
  var UndoCursorStart, UndoCursorEnd: TPoint;
  var UndoString: AnsiString;
  var RedoCursorStart, RedoCursorEnd: TPoint;
  var RedoString: AnsiString;
begin
  RedoCursorStart := CursorStart;
  RedoCursorEnd := CursorEnd;
  UndoString := GetSelectionStr;
  InsertStr(Str);
  UndoCursorStart := RedoCursorStart;
  UndoCursorEnd := CursorEnd;
  RedoString := Str;
  Text^.AddUndoActionInsert(
    UndoCursorStart, UndoCursorEnd,
    UndoString,
    RedoCursorStart, RedoCursorEnd,
    RedoString
  );
  Text^.Modified := True;
end;

function TUITextEditCode.GetIndentation(const Line, Pos: Integer): Integer;
  var l, i, n: Integer;
begin
  Result := 0;
  l := Line;
  while l >= 0 do
  begin
    if (l < Length(Text^.Lines)) then
    begin
      if l = Line then
      n := G2Min(Pos, Length(Text^.Lines[l]))
      else
      n := Length(Text^.Lines[l]);
      if (n > 0) then
      begin
        for i := 1 to n do
        if Text^.Lines[l][i] <> ' ' then
        begin
          Result := G2Min(Pos, i - 1);
          Exit;
        end;
      end;
    end;
    Dec(l);
  end;
end;

function TUITextEditCode.FindCursorPos(const ScrX, ScrY: Single): TPoint;
begin
  Result.x := G2Max(Round((ScrX - TextPos^.x) / FontSize.x), 0);
  Result.y := G2Max(Trunc((ScrY - TextPos^.y) / FontSize.y), 0);
end;

procedure TUITextEditCode.CheckSelection;
  var Tmp: TPoint;
begin
  if CursorStart.x < 0 then CursorStart.x := 0;
  if CursorEnd.x < 0 then CursorEnd.x := 0;
  if CursorStart.y < 0 then CursorStart.y := 0;
  if CursorEnd.y < 0 then CursorEnd.y := 0;
  if (Selection = @CursorEnd)
  and (
    (Selection^.y < CursorStart.y)
    or (
      (Selection^.y = CursorStart.y)
      and (Selection^.x < CursorStart.x)
    )
  ) then
  begin
    Tmp := CursorEnd;
    CursorEnd := CursorStart;
    CursorStart := Tmp;
    Selection := @CursorStart;
    if Assigned(OnCursorMoveProc) then
    OnCursorMoveProc;
  end
  else if (Selection = @CursorStart)
  and (
    (Selection^.y > CursorEnd.y)
    or (
      (Selection^.y = CursorEnd.y)
      and (Selection^.x > CursorEnd.x)
    )
  ) then
  begin
    Tmp := CursorEnd;
    CursorEnd := CursorStart;
    CursorStart := Tmp;
    Selection := @CursorEnd;
    if Assigned(OnCursorMoveProc) then
    OnCursorMoveProc;
  end;
end;

procedure TUITextEditCode.Render;
  var i: Integer;
  var x, y: Single;
  var bm: TG2BlendMode;
  var r: TG2Rect;
begin
  if not HaveSelection and not GetCursorFlicker then Exit;
  bm.ColorDst := boZero;
  bm.ColorSrc := boInvDstColor;
  bm.AlphaDst := boOne;
  bm.AlphaSrc := boZero;
  x := G2Max(TextPos^.x - 1 + FontSize.x * CursorStart.x, Frame^.l);
  y := TextPos^.y + FontSize.y * CursorStart.y;
  for i := CursorStart.y to CursorEnd.y do
  begin
    if i = CursorEnd.y then
    begin
      r.x := x;
      r.y := y;
      r.r := G2Min(TextPos^.x + FontSize.x * CursorEnd.x + 1, Frame^.r);
      r.h := FontSize.y;
    end
    else
    begin
      r.x := x;
      r.y := y;
      r.r := Frame^.r;
      r.h := FontSize.y;
    end;
    g2.PrimRect(r.x, r.y, r.w, r.h, $ffffffff, bm);
    x := G2Max(TextPos^.x - 1, Frame^.l);
    y := y + FontSize.y;
  end;
end;

procedure TUITextEditCode.Update;
  var PrevCursor: TPoint;
begin
  if g2.MouseDown[G2MB_Left]
  and Frame^.Contains(g2.MouseDownPos[G2MB_Left]) then
  begin
    PrevCursor := Selection^;
    Selection^ := FindCursorPos(g2.MousePos.x, g2.MousePos.y);
    CheckSelection;
    if Assigned(OnCursorMoveProc)
    and (
      (PrevCursor.x <> Selection^.x)
      or (PrevCursor.y <> Selection^.y)
    ) then
    OnCursorMoveProc;
  end;
end;

procedure TUITextEditCode.OnEnable;
begin

end;

procedure TUITextEditCode.OnDisable;
begin

end;

procedure TUITextEditCode.AdjustCursor(const ScrX, ScrY: Single);
begin
  CursorStart := FindCursorPos(ScrX, ScrY);
  CursorEnd := CursorStart;
end;

procedure TUITextEditCode.OnMouseDown(const x, y: Integer);
begin
  CursorStart := FindCursorPos(x, y);
  CursorEnd := CursorStart;
  Selection := @CursorEnd;
  if Assigned(OnCursorMoveProc) then
  OnCursorMoveProc;
  ResetCursorFlicker;
end;

procedure TUITextEditCode.OnMouseUp(const x, y: Integer);
begin
  CheckSelection;
  if Assigned(OnCursorMoveProc) then
  OnCursorMoveProc;
end;

procedure TUITextEditCode.OnScroll(const y: Integer);
begin
  if Assigned(OnScrollProc) then
  OnScrollProc(y);
end;

procedure TUITextEditCode.OnPrint(const Char: AnsiChar);
begin
  InsertStrSaveUndo(Char);
  if Assigned(OnChangeProc) then
  OnChangeProc;
  if Assigned(OnCursorMoveProc) then
  OnCursorMoveProc;
  ResetCursorFlicker;
end;

procedure TUITextEditCode.OnKeyDown(const Key: TG2IntS32);
  var Cur: TPoint;
  var i, n: Integer;
begin
  case Key of
    G2K_Left:
    begin
      if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
      begin
        JumpCursor(-1);
        if not g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
        MergeCursor
        else
        CheckSelection;
      end
      else
      if Selection^.x > 0 then
      begin
        if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
        begin
          Dec(Selection^.x);
          CheckSelection;
        end
        else
        begin
          Dec(Selection^.x);
          MergeCursor;
          if Assigned(OnCursorMoveProc) then
          OnCursorMoveProc;
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Right:
    begin
      if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
      begin
        JumpCursor(1);
        if not g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
        MergeCursor
        else
        CheckSelection;
      end
      else
      begin
        if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
        begin
          Inc(Selection^.x);
          CheckSelection;
        end
        else
        begin
          Inc(Selection^.x);
          MergeCursor;
          if Assigned(OnCursorMoveProc) then
          OnCursorMoveProc;
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Up:
    begin
      if Selection^.y > 0 then
      begin
        if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
        begin
          TextPos^.y := G2Min(Frame^.t, TextPos^.y + FontSize.y);
          if Assigned(OnTextPosChange) then
          OnTextPosChange;
        end
        else
        begin
          if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
          begin
            Dec(Selection^.y);
            CheckSelection;
          end
          else
          begin
            Dec(Selection^.y);
            MergeCursor;
            if Assigned(OnCursorMoveProc) then
            OnCursorMoveProc;
          end;
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Down:
    begin
      if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
      begin
        TextPos^.y := TextPos^.y - FontSize.y;
        if Assigned(OnTextPosChange) then
        OnTextPosChange;
      end
      else
      begin
        if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
        begin
          Inc(Selection^.y);
          CheckSelection;
        end
        else
        begin
          Inc(Selection^.y);
          MergeCursor;
          if Assigned(OnCursorMoveProc) then
          OnCursorMoveProc;
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Back:
    begin
      if HaveSelection then
      InsertStrSaveUndo('')
      else if Selection^.x > 0 then
      begin
        if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
        begin
          Cur := Selection^;
          JumpCursor(-1);
          CursorStart := Selection^;
          CursorEnd := Cur;
          CheckSelection;
        end
        else
        Dec(CursorStart.x);
        InsertStrSaveUndo('');
      end
      else if Selection^.y > 0 then
      begin
        CursorEnd := Selection^;
        CursorStart.y := Selection^.y - 1;
        if CursorStart.y < Length(Text^.Lines) then
        CursorStart.x := Length(Text^.Lines[CursorStart.y])
        else
        CursorStart.x := 0;
        InsertStrSaveUndo('');
      end;
      ResetCursorFlicker;
    end;
    G2K_Delete:
    begin
      if HaveSelection then
      InsertStrSaveUndo('')
      else if Selection^.y < Length(Text^.Lines) then
      begin
        if Selection^.x < Length(Text^.Lines[Selection^.y]) then
        begin
          if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
          begin
            Cur := Selection^;
            JumpCursor(1);
            CursorEnd := Selection^;
            CursorStart := Cur;
            CheckSelection;
          end
          else
          Inc(CursorEnd.x);
          InsertStrSaveUndo('');
        end
        else if Selection^.y < High(Text^.Lines) then
        begin
          CursorStart := Selection^;
          CursorEnd.y := Selection^.y + 1;
          CursorEnd.x := 0;
          InsertStrSaveUndo('');
        end;
      end;
      ResetCursorFlicker;
    end;
    G2K_Return:
    begin
      n := GetIndentation(CursorStart.y, CursorStart.x);
      InsertStrSaveUndo(#$D + MakeSpaces(n));
      MergeCursor;
      ResetCursorFlicker;
    end;
    G2K_A:
    begin
      if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
      begin
        CursorStart := Point(0, 0);
        CursorEnd.y := High(Text^.Lines);
        CursorEnd.x := Length(Text^.Lines[High(Text^.Lines)]);
      end;
    end;
    G2K_C:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) and HaveSelection then
      begin
        DoCopy;
      end;
    end;
    G2K_V:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        DoPaste;
        ResetCursorFlicker;
      end;
    end;
    G2K_X:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) and HaveSelection then
      begin
        DoCopy;
        InsertStrSaveUndo('');
        ResetCursorFlicker;
      end;
    end;
    G2K_Z:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        if (g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR]) then
        begin
          Text^.Undo.Redo;
          if Assigned(OnChangeProc) then
          OnChangeProc;
        end
        else
        begin
          Text^.Undo.Undo;
          if Assigned(OnChangeProc) then
          OnChangeProc;
        end;
        ResetCursorFlicker;
      end;
    end;
    G2K_Slash, G2K_SlashR:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        if (g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR]) then
        DoMultiUnComment(True)
        else
        DoMultiComment(True);
      end;
    end;
    G2K_I:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        if (g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR]) then
        DoUnIndent(True)
        else
        DoIndent(True);
      end;
    end;
    G2K_U:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        DoUnIndent(True);
      end;
    end;
    G2K_Tab:
    begin
      if (g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR]) then
      DoUnIndent(True)
      else
      DoIndent(True);
    end;
    G2K_Home:
    begin
      Selection^.x := 0;
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      Selection^.y := 0;
      if not ((g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR])) then
      MergeCursor;
      if Assigned(OnCursorMoveProc) then
      OnCursorMoveProc;
      ResetCursorFlicker;
    end;
    G2K_End:
    begin
      if Selection^.y <= High(Text^.Lines) then
      begin
        if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
        begin
          if Selection^.y < High(Text^.Lines) then
          Selection^.x := Length(Text^.Lines[High(Text^.Lines)])
          else
          Selection^.x := G2Max(Selection^.x, Length(Text^.Lines[High(Text^.Lines)]));
          Selection^.y := High(Text^.Lines);
        end
        else
        begin
          Selection^.x := G2Max(Selection^.x, Length(Text^.Lines[Selection^.y]));
        end;
        if not ((g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR])) then
        MergeCursor;
        if Assigned(OnCursorMoveProc) then
        OnCursorMoveProc;
        ResetCursorFlicker;
      end;
    end;
    G2K_PgDown:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        Selection^.y := Selection^.y + Round(Frame^.h / FontSize.y);
        CheckSelection;
        if not ((g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR])) then
        MergeCursor;
        if Assigned(OnCursorMoveProc) then
        OnCursorMoveProc;
        ResetCursorFlicker;
      end
      else
      begin
        TextPos^.y := TextPos^.y - Frame^.h;
        if Assigned(OnTextPosChange) then
        OnTextPosChange;
      end;
    end;
    G2K_PgUp:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then
      begin
        Selection^.y := G2Max(0, Selection^.y - Round(Frame^.h / FontSize.y));
        CheckSelection;
        if not ((g2.KeyDown[G2K_ShiftL]) or (g2.KeyDown[G2K_ShiftR])) then
        MergeCursor;
        if Assigned(OnCursorMoveProc) then
        OnCursorMoveProc;
        ResetCursorFlicker;
      end
      else
      begin
        TextPos^.y := G2Min(Frame^.t, TextPos^.y + Frame^.h);
        if Assigned(OnTextPosChange) then
        OnTextPosChange;
      end;
    end;
    G2K_S:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR])
      and Assigned(OnCmdSave) then
      OnCmdSave;
    end;
    G2K_D:
    begin
      if (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR])
      and Assigned(OnCmdLoad) then
      OnCmdLoad;
    end;
  end;
end;

procedure TUITextEditCode.OnKeyUp(const Key: TG2IntS32);
begin

end;

procedure TUITextEditCode.TextUpdated;
begin
  CheckSelection;
end;

function TUITextEditCode.GetCursorPos: TG2Vec2;
begin
  Result.x := TextPos^.x + Selection^.x * FontSize.x;
  Result.y := TextPos^.y + (Selection^.y + 1) * FontSize.y;
end;

procedure TUITextEditCode.UndoActionInsert(const Ptr: Pointer);
  var Action: TCodeUndoAction;
  var Buffer: PG2IntU8Arr absolute Ptr;
  var Str: AnsiString;
begin
  Move(Buffer^[0], Action, SizeOf(Action));
  SetLength(Str, Action.StrLength);
  Move(Buffer^[SizeOf(Action)], Str[1], Action.StrLength);
  CursorStart := Action.CursorStart;
  CursorEnd := Action.CursorEnd;
  Text^.Modified := True;
  InsertStr(Str);
end;

procedure TUITextEditCode.UndoActionComment(const Ptr: Pointer);
  var Action: PCodeUndoActionMultiline absolute Ptr;
begin
  CursorStart.x := 0;
  CursorStart.y := Action^.LineStart;
  CursorEnd.x := 0;
  CursorEnd.y := Action^.LineEnd;
  DoMultiComment;
  Text^.Modified := True;
end;

procedure TUITextEditCode.UndoActionUnComment(const Ptr: Pointer);
  var Action: PCodeUndoActionMultiline absolute Ptr;
begin
  CursorStart.x := 0;
  CursorStart.y := Action^.LineStart;
  CursorEnd.x := 0;
  CursorEnd.y := Action^.LineEnd;
  DoMultiUnComment;
  Text^.Modified := True;
end;

procedure TUITextEditCode.UndoActionIndent(const Ptr: Pointer);
  var Action: PCodeUndoActionMultiline absolute Ptr;
begin
  CursorStart.x := 0;
  CursorStart.y := Action^.LineStart;
  CursorEnd.x := 0;
  CursorEnd.y := Action^.LineEnd;
  DoIndent;
  Text^.Modified := True;
end;

procedure TUITextEditCode.UndoActionUnIndent(const Ptr: Pointer);
  var Action: PCodeUndoActionMultiline absolute Ptr;
begin
  CursorStart.x := 0;
  CursorStart.y := Action^.LineStart;
  CursorEnd.x := 0;
  CursorEnd.y := Action^.LineEnd;
  DoUnIndent;
  Text^.Modified := True;
end;

constructor TUITextEditCode.Create;
begin
  inherited Create;
  Font := App.UI.FontCode;
  FontB := App.UI.FontCodeB;
  FontI := App.UI.FontCodeI;
  FontSize.x := Font.TextWidth('A');
  FontSize.y := Font.TextHeight('A');
  Selection := @CursorEnd;
end;
//TUITextEditCode END

//TUITextEdit BEGIN
procedure TUITextEdit.SetAllowSymbols(const Value: Boolean);
begin
  if Value <> _AllowSymbols then
  begin
    _AllowSymbols := Value;
    if _AllowSymbols then
    _AllowedChars := [
      'A'..'Z', 'a'..'z', '0'..'9', ' ',
      '!', '@', '#', '$', '%', '^', '&',
      '*', '(', ')', '-', '+', '=', '_',
      '{', '}', '[', ']', ';', ':', '"',
      '''', ',', '.', '/', '?', '<', '>',
      '\', '|', '`', '~'
    ]
    else
    _AllowedChars := ['A'..'Z', 'a'..'z', '0'..'9', ' '];
  end;
end;

procedure TUITextEdit.Initialize;
begin
  _OnFinishProc := nil;
  _SingleLine := TUITextEditSingleLine.Create;
  _SingleLine.MaxLength := @_MaxLength;
  _SingleLine.Frame := @_Frame;
  _SingleLine.DisableProc := @Disable;
  _Code := TUITextEditCode.Create;
  _Code.MaxLength := @_MaxLength;
  _Code.Frame := @_Frame;
  _Code.DisableProc := @Disable;
  _Implementation := nil;
  _Enabled := False;
  _AllowSymbols := False;
  _AllowedChars := ['A'..'Z', 'a'..'z', '0'..'9', ' '];
  _JumpBreakers := [' ', ',', ';', '(', ')', '[', ']', '.'];
end;

procedure TUITextEdit.Finalize;
begin
  _Code.Free;
  _SingleLine.Free;
end;

procedure TUITextEdit.Enable(
  const TextPtr: PAnsiString;
  const TextPosPtr: PG2Vec2;
  const Font: TG2Font;
  const OnChangeProc: TG2ProcObj;
  const DefaultText: AnsiString;
  const OnEnterProc: TG2ProcObj;
  const OnCursorMoveProc: TG2ProcObj;
  const AllowEmpty: Boolean = False
);
begin
  _OnFinishProc := nil;
  _Enabled := True;
  _Implementation := _SingleLine;
  _SingleLine.AllowEmpty := AllowEmpty;
  _SingleLine.AutoAdjustTextPos := False;
  _SingleLine.Text := TextPtr;
  _SingleLine.TextPos := TextPosPtr;
  _SingleLine.Font := Font;
  _SingleLine.CursorStart := 0;
  _SingleLine.CursorEnd := Length(TextPtr^);
  _SingleLine.DefaultText := DefaultText;
  _SingleLine.OnChangeProc := OnChangeProc;
  _SingleLine.OnEnterProc := OnEnterProc;
  _SingleLine.OnCursorMoveProc := OnCursorMoveProc;
  _MaxLength := 0;
  _ViewIndex := App.UI.Views.ViewIndex;
  AllowSymbols := False;
  _Implementation.ResetCursorFlicker;
  _Implementation.OnEnable;
end;

procedure TUITextEdit.EnableCode(
  const CodePtr: PCodeFile;
  const TextPosPtr: PG2Vec2;
  const OnChangeProc: TG2ProcObj;
  const OnScrollProc: TG2ProcScrollObj;
  const OnCursorMoveProc: TG2ProcObj;
  const OnTextPosChange: TG2ProcObj;
  const OnCmdSave: TG2ProcObj;
  const OnCmdLoad: TG2ProcObj
);
begin
  _OnFinishProc := nil;
  _Enabled := True;
  _Implementation := _Code;
  _Code.Text := CodePtr;
  _Code.TextPos := TextPosPtr;
  _Code.OnChangeProc := OnChangeProc;
  _Code.OnScrollProc := OnScrollProc;
  _Code.OnCursorMoveProc := OnCursorMoveProc;
  _Code.OnTextPosChange := OnTextPosChange;
  _Code.OnCmdSave := OnCmdSave;
  _Code.OnCmdLoad := OnCmdLoad;
  _ViewIndex := App.UI.Views.ViewIndex;
  _MaxLength := 0;
  AllowSymbols := True;
  _Implementation.ResetCursorFlicker;
  _Implementation.OnEnable;
end;

procedure TUITextEdit.Disable;
begin
  if (_Enabled) then
  begin
    _Enabled := False;
    _Implementation.OnDisable;
    if Assigned(_OnFinishProc) then
    _OnFinishProc;
  end;
end;

procedure TUITextEdit.Render;
begin
  App.UI.PushClipRect(Frame.Expand(1, 1));
  _Implementation.Render;
  App.UI.PopClipRect;
end;

procedure TUITextEdit.Update;
begin
  _Implementation.Update;
  if _Frame.Contains(g2.MousePos) then
  App.UI.Cursor := g2.Window.CursorText;
  if App.UI.Views.ViewIndex <> _ViewIndex then
  Disable;
end;

procedure TUITextEdit.AdjustCursor(const ScrX, ScrY: Single);
begin
  _Implementation.AdjustCursor(ScrX, ScrY);
end;

procedure TUITextEdit.OnMouseDown(const x, y: Integer);
begin
  if _Frame.Contains(x, y) then
  begin
    _Implementation.OnMouseDown(x, y);
  end
  else
  begin
    Disable;
  end;
end;

procedure TUITextEdit.OnMouseUp(const x, y: Integer);
begin
  _Implementation.OnMouseUp(x, y);
end;

procedure TUITextEdit.OnScroll(const y: Integer);
begin
  _Implementation.OnScroll(y);
end;

procedure TUITextEdit.OnPrint(const Char: AnsiChar);
begin
  if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then Exit;
  if Char in _AllowedChars then
  _Implementation.OnPrint(Char);
end;

procedure TUITextEdit.OnKeyDown(const Key: TG2IntS32);
begin
  _Implementation.OnKeyDown(Key);
end;

procedure TUITextEdit.OnKeyUp(const Key: TG2IntS32);
begin
  _Implementation.OnKeyUp(Key);
end;

procedure TUITextEdit.TextUpdated;
begin
  _Implementation.TextUpdated;
end;

function TUITextEdit.GetCursorPos: TG2Vec2;
begin
  Result := _Implementation.GetCursorPos;
end;
//TUITextEdit END

//TUIWorkspaceConstructor BEGIN
function TUIWorkspaceConstructor.GetName: AnsiString;
begin
  Result := WorkspaceClass.GetWorkspaceName;
end;

procedure TUIWorkspaceConstructor.OnCreateWorkspace(const Workspace: TUIWorkspace);
begin

end;
//TUIWorkspaceConstructor END

//TUIWorkspaceConstructorCode BEGIN
constructor TUIWorkspaceConstructorCode.Create;
begin
  inherited Create;
  WorkspaceClass := TUIWorkspaceCode;
end;

procedure TUIWorkspaceConstructorCode.OnCreateWorkspace(const Workspace: TUIWorkspace);
  //var Code: TUIWorkspaceCode;
begin
  //Code := TUIWorkspaceCode(Workspace);
  //Code.NewCodeFile;
end;
//TUIWorkspaceConstructorCode END

//TUIHint BEGIN
procedure TUIHint.Initialize;
begin
  _Alpha := 0;
  Enabled := False;
  Pos.SetValue(0, 0);
  BorderSize.SetValue(12, 8);
  Text := '';
end;

procedure TUIHint.Update;
begin
  if Enabled then
  _Alpha := G2Min(_Alpha + 0.1, 1)
  else
  _Alpha := G2Max(_Alpha - 0.1, 0);
end;

procedure TUIHint.Render;
  var x, y, w, h: Single;
begin
  if (Length(Text) > 0)
  and (_Alpha > 0) then
  begin
    w := App.UI.Font1.TextWidth(Text);
    h := App.UI.Font1.TextHeight('A');
    x := Pos.x - w * 0.5;
    y := Pos.y - h * 0.5;
    if x - BorderSize.x < 0 then x := BorderSize.x
    else if x + w + BorderSize.x > g2.Params.Width then x := g2.Params.Width - w - BorderSize.x;
    if y - BorderSize.y < 0 then y := BorderSize.y
    else if y + h + BorderSize.y > g2.Params.Height then y := g2.Params.Height - h - BorderSize.y;
    g2.PrimRect(x - BorderSize.x, y - BorderSize.y, w + BorderSize.x * 2, h + BorderSize.y * 2, App.UI.GetColorPrimary(0, _Alpha));
    g2.PrimRect(x - (BorderSize.x - 1), y - (BorderSize.y - 1), w + (BorderSize.x - 1) * 2, h + (BorderSize.y - 1) * 2, App.UI.GetColorPrimary(0.95, _Alpha));
    App.UI.Font1.Print(Round(x), Round(y), 1, 1, G2Color(0, 0, 0, Round($ff * _Alpha)), Text, bmNormal, tfPoint);
  end;
end;
//TUIHint END

//TUI BEGIN
procedure TUI.RegisterWorkspace(const WorkspaceClass: CUIWorkspace);
  var wc: TUIWorkspaceConstructor;
begin
  wc := TUIWorkspaceConstructor.Create;
  wc.WorkspaceClass := WorkspaceClass;
  RegisterWorkspaceConstructor(wc);
end;

procedure TUI.RegisterWorkspaceConstructor(const WorkspaceConstructor: TUIWorkspaceConstructor);
begin
  WorkspaceClasses.Add(WorkspaceConstructor);
end;

procedure TUI.Initialize;
begin
  ColorPrimary := $ffffffff;
  ColorSecondary := $ffff0000;
  Font1 := TG2Font.Create;
  Font1.Make(16);
  FontCode := TG2Font.Create;
  FontCode.Load(@Bin_FontCourierNew_10, SizeOf(Bin_FontCourierNew_10));
  FontCodeB := TG2Font.Create;
  FontCodeB.Load(@Bin_FontCourierNewB_10, SizeOf(Bin_FontCourierNewB_10));
  FontCodeI := TG2Font.Create;
  FontCodeI.Load(@Bin_FontCourierNewI_10, SizeOf(Bin_FontCourierNewI_10));
  TextEdit.Initialize;
  Overlay := nil;
  TexCarbon := TG2Texture2D.Create;
  TexCarbon.Load(@Bin_Carbon, SizeOf(Bin_Carbon), tu2D);
  TexDocEmpty := TG2Texture2D.Create;
  TexDocEmpty.Load(@Bin_doc_empty_16, SizeOf(Bin_doc_empty_16), tu2D);
  TexFileOpen := TG2Texture2D.Create;
  TexFileOpen.Load(@Bin_file_open_16, SizeOf(Bin_file_open_16), tu2D);
  TexFileSave := TG2Texture2D.Create;
  TexFileSave.Load(@Bin_file_save_16, SizeOf(Bin_file_save_16), tu2D);
  TexFileSaveAs := TG2Texture2D.Create;
  TexFileSaveAs.Load(@Bin_file_save_as_16, SizeOf(Bin_file_save_as_16), tu2D);
  TexPlus := TG2Texture2D.Create;
  TexPlus.Load(@Bin_plus_icon_16, SizeOf(Bin_plus_icon_16), tu2D);
  TexGear := TG2Texture2D.Create;
  TexGear.Load(@Bin_cog_icon_16, SizeOf(Bin_cog_icon_16), tu2D);
  TexDelete := TG2Texture2D.Create;
  TexDelete.Load(@Bin_delete_icon_16, SizeOf(Bin_delete_icon_16), tu2D);
  TexDocExport := TG2Texture2D.Create;
  TexDocExport.Load(@Bin_doc_export_icon_16, SizeOf(Bin_doc_export_icon_16), tu2D);
  TexDocPlus := TG2Texture2D.Create;
  TexDocPlus.Load(@Bin_doc_plus_icon_16, SizeOf(Bin_doc_plus_icon_16), tu2D);
  TexFolderPlus := TG2Texture2D.Create;
  TexFolderPlus.Load(@Bin_folder_plus_icon_16, SizeOf(Bin_folder_plus_icon_16), tu2D);
  TexFolder := TG2Texture2D.Create;
  TexFolder.Load(@Bin_folder_icon_32, SizeOf(Bin_folder_icon_32), tu2D);
  TexChecker := TG2Texture2D.Create;
  TexChecker.Load(@Bin_Checker, SizeOf(Bin_Checker), tu2D);
  TexPlay := TG2Texture2D.Create;
  TexPlay.Load(@Bin_play_icon_16, SizeOf(Bin_play_icon_16), tu2D);
  TexStop := TG2Texture2D.Create;
  TexStop.Load(@Bin_stop_icon_16, SizeOf(Bin_stop_icon_16), tu2D);
  TexDots := TG2Texture2D.Create;
  TexDots.Load(@Bin_Dots, SizeOf(Bin_Dots), tu2D);
  TexLink := TG2Texture2D.Create;
  TexLink.Load(@Bin_link_icon_16, SizeOf(Bin_link_icon_16), tu2D);
  TexPin := TG2Texture2D.Create;
  TexPin.Load(@Bin_pin_icon_16, SizeOf(Bin_pin_icon_16), tu2D);
  TexRoundMinus := TG2Texture2D.Create;
  TexRoundMinus.Load(@Bin_round_minus_16, SizeOf(Bin_round_minus_16), tu2D);
  TexRoundPlus := TG2Texture2D.Create;
  TexRoundPlus.Load(@Bin_round_plus_16, SizeOf(Bin_round_plus_16), tu2D);
  TexSpot := TG2Texture2D.Create;
  TexSpot.Load(@Bin_spot, SizeOf(Bin_spot), tu2D);
  Views.Initialize;
  WorkspaceClasses.Clear;
  WorkspaceFrame.l := 0;
  WorkspaceFrame.t := Views.Height;
  WorkspaceFrame.r := g2.Params.Width;
  WorkspaceFrame.b := g2.Params.Height;
  OverlayWorkspaceList := TOverlayWorkspaceList.Create;
  OverlayWorkspace := TOverlayWorkspace.Create;
  OverlayAssetSelect := TOverlayAssetSelect.Create;
  Hint.Initialize;
  Messages.Clear;
  MessagesDumped.Clear;
end;

procedure TUI.Finalize;
  var i: Integer;
begin
  if (Overlay <> nil)
  and (Overlay is TOverlayDrop) then
  begin
    Overlay.Free;
    Overlay := nil;
  end;
  for i := 0 to MessagesDumped.Count - 1 do
  begin
    G2MemFree(MessagesDumped[i]^.Data, MessagesDumped[i]^.DataSize);
    Dispose(MessagesDumped[i]);
  end;
  MessagesDumped.Clear;
  for i := 0 to Messages.Count - 1 do
  begin
    G2MemFree(Messages[i]^.Data, Messages[i]^.DataSize);
    Dispose(Messages[i]);
  end;
  Messages.Clear;
  OverlayAssetSelect.Free;
  OverlayWorkspace.Free;
  OverlayWorkspaceList.Free;
  while WorkspaceClasses.Count > 0 do
  WorkspaceClasses.Pop.Free;
  Views.Finalize;
  Font1.Free;
  FontCode.Free;
  FontCodeB.Free;
  FontCodeI.Free;
  TexCarbon.Free;
  TexDocEmpty.Free;
  TexFileOpen.Free;
  TexFileSave.Free;
  TexPlus.Free;
  TexGear.Free;
  TexDelete.Free;
  TexDocExport.Free;
  TexDocPlus.Free;
  TexFolderPlus.Free;
  TexFolder.Free;
  TexChecker.Free;
  TexPlay.Free;
  TexStop.Free;
  TexDots.Free;
  TexLink.Free;
  TexPin.Free;
  TexRoundMinus.Free;
  TexRoundPlus.Free;
  TexSpot.Free;
end;

procedure TUI.Render;
begin
  g2.PicRectCol(
    0, 0, g2.Params.Width, g2.Params.Height * 0.5,
    $ff808080, $ff808080, $ffffffff, $ffffffff,
    0, 0, g2.Params.Width / TexCarbon.Width, g2.Params.Height * 0.5 / TexCarbon.Height,
    TexCarbon, bmDisable, tfLinear
  );
  g2.PicRectCol(
    0, g2.Params.Height * 0.5, g2.Params.Width, g2.Params.Height * 0.5,
    $ffffffff, $ffffffff, $ff000000, $ff000000,
    0, g2.Params.Height * 0.5 / TexCarbon.Height, g2.Params.Width / TexCarbon.Width, g2.Params.Height / TexCarbon.Height,
    TexCarbon, bmDisable, tfLinear
  );
  Views.Render;
  if Overlay <> nil then
  Overlay.Render;
  if TextEdit.Enabled then
  TextEdit.Render;
  Hint.Render;
  //Font1.Print(10, 10, 'FPS: ' + IntToStr(g2.FPS));
end;

procedure TUI.Update;
begin
  Hint.Enabled := False;
  Cursor := g2.Window.CursorArrow;
  if Overlay <> nil then
  Overlay.Update;
  if TextEdit.Enabled then
  TextEdit.Update;
  ProcessMessages;
  Views.Update;
  Hint.Update;
  g2.Window.Cursor := Cursor;
end;

procedure TUI.Resize;
begin
  WorkspaceFrame.l := 0;
  WorkspaceFrame.t := Views.Height;
  WorkspaceFrame.r := g2.Params.Width;
  WorkspaceFrame.b := g2.Params.Height;
  Views.Adjust;
  Views.AdjustWorkspaces;
end;

procedure TUI.MsgInsertWorkspace(
  const Workspace: TUIWorkspace;
  const InsertPos: TG2Vec2;
  const CanDelete: Boolean = True;
  const Push: Boolean = False
);
  var MsgData: TUIMessageDataInsertWorkspace;
begin
  MsgData.Workspace := Workspace;
  MsgData.InsertPos := InsertPos;
  MsgData.CanDelete := CanDelete;
  if Push then
  PushMessage(mtInsertWorkspace, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtInsertWorkspace, @MsgData, SizeOf(MsgData));
end;

procedure TUI.LoadWorkspaces;
begin
  OverlayWorkspaceList.LoadWorkspaces;
end;

procedure TUI.MsgExtractWorkspace(const Workspace: TUIWorkspace; const Push: Boolean = False);
  var MsgData: TUIMessageDataExtractWorkspace;
begin
  MsgData.Workspace := Workspace;
  if Push then
  PushMessage(mtExtractWorkspace, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtExtractWorkspace, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgCloseWorkspace(const Workspace: TUIWorkspace; const Push: Boolean = False);
  var MsgData: TUIMessageDataCloseWorkspace;
begin
  MsgData.Workspace := Workspace;
  if Push then
  PushMessage(mtCloseWorkspace, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtCloseWorkspace, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgReplaceWorkspace(const WorkspaceOld, WorkspaceNew: TUIWorkspace; const Push: Boolean = False);
  var MsgData: TUIMessageDataReplaceWorkspace;
begin
  MsgData.WorkspaceOld := WorkspaceOld;
  MsgData.WorkspaceNew := WorkspaceNew;
  if Push then
  PushMessage(mtReplaceWorkspace, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtReplaceWorkspace, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgResizeWorkspace(const Workspace: TUIWorkspace; const Frame: TG2Rect; const Push: Boolean = False);
  var MsgData: TUIMessageDataResizeWorkspace;
begin
  MsgData.Workspace := Workspace;
  MsgData.Frame := Frame;
  if Push then
  PushMessage(mtResizeWorkspace, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtResizeWorkspace, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgMouseDown(const Button, x, y: Integer; const Push: Boolean = False);
  var MsgData: TUIMessageDataMouseInput;
begin
  MsgData.Button := Button;
  MsgData.x := x;
  MsgData.y := y;
  if Push then
  PushMessage(mtMouseDown, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtMouseDown, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgMouseUp(const Button, x, y: Integer; const Push: Boolean = False);
  var MsgData: TUIMessageDataMouseInput;
begin
  MsgData.Button := Button;
  MsgData.x := x;
  MsgData.y := y;
  if Push then
  PushMessage(mtMouseUp, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtMouseUp, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgLoadLayout(const FileName: String; const Push: Boolean);
  var MsgData: TUIMessageDataLoadLayout;
begin
  MsgData.FileName := FileName;
  if Push then
  PushMessage(mtLoadLayout, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtLoadLayout, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgOpenProject(const FileName: String; const Push: Boolean);
  var MsgData: TUIMessageDataOpenProject;
begin
  MsgData.FileName := FileName;
  if Push then
  PushMessage(mtOpenProject, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtOpenProject, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgCallProc(const Proc: TG2ProcObj; const Push: Boolean);
  var MsgData: TUIMessageDataCallProc;
begin
  MsgData.Proc := Proc;
  if Push then
  PushMessage(mtCallProc, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtCallProc, @MsgData, SizeOf(MsgData));
end;

procedure TUI.MsgCallProcPtr(const Proc: TG2ProcPtrObj; const Ptr: Pointer; const Push: Boolean);
  var MsgData: TUIMessageDataCallProcPtr;
begin
  MsgData.Proc := Proc;
  MsgData.Ptr := Ptr;
  if Push then
  PushMessage(mtCallProcPtr, @MsgData, SizeOf(MsgData))
  else
  StackMessage(mtCallProcPtr, @MsgData, SizeOf(MsgData));
end;

function TUI.CreateMessage(const MessageType: TUIMessageType; const Data: Pointer; const DataSize: Integer): PUIMessage;
begin
  if MessagesDumped.Count > 0 then
  Result := MessagesDumped.Pop
  else
  begin
    New(Result);
    Result^.DataSize := 0;
  end;
  if Result^.DataSize < DataSize then
  begin
    if Result^.DataSize > 0 then
    G2MemFree(Result^.Data, Result^.DataSize);
    Result^.DataSize := DataSize;
    Result^.Data := G2MemAlloc(Result^.DataSize);
  end;
  Result^.MessageType := MessageType;
  Move(Data^, Result^.Data^, Result^.DataSize);
end;

procedure TUI.PushMessage(const MessageType: TUIMessageType; const Data: Pointer; const DataSize: Integer);
begin
  Messages.Insert(0, CreateMessage(MessageType, Data, DataSize));
end;

procedure TUI.StackMessage(const MessageType: TUIMessageType; const Data: Pointer; const DataSize: Integer);
begin
  Messages.Add(CreateMessage(MessageType, Data, DataSize));
end;

procedure TUI.ProcessMessages;
  var m: PUIMessage;
  var DataPtr: Pointer;
  var DataInsertWorkspace: PUIMessageDataInsertWorkspace absolute DataPtr;
  var DataExtractWorkspace: PUIMessageDataExtractWorkspace absolute DataPtr;
  var DataCloseWorkspace: PUIMessageDataCloseWorkspace absolute DataPtr;
  var DataReplaceWorkspace: PUIMessageDataReplaceWorkspace absolute DataPtr;
  var DataResizeWorkspace: PUIMessageDataResizeWorkspace absolute DataPtr;
  var DataMouseInput: PUIMessageDataMouseInput absolute DataPtr;
  var DataLoadLayput: PUIMessageDataLoadLayout absolute DataPtr;
  var DataOpenProject: PUIMessageDataOpenProject absolute DataPtr;
  var DataCallProc: PUIMessageDataCallProc absolute DataPtr;
  var DataCallProcPtr: PUIMessageDataCallProcPtr absolute DataPtr;
begin
  while Messages.Count > 0 do
  begin
    m := Messages.Extract(0);
    DataPtr := m^.Data;
    case m^.MessageType of
      mtInsertWorkspace:
      begin
        if (
           not Views.InsertWorkspace(DataInsertWorkspace^.Workspace, DataInsertWorkspace^.InsertPos)
           and DataInsertWorkspace^.CanDelete
        ) then
        begin
          DataInsertWorkspace^.Workspace.Free;
        end
      end;
      mtExtractWorkspace:
      begin
        Views.ExtractWorkspace(DataExtractWorkspace^.Workspace);
      end;
      mtCloseWorkspace:
      begin
        Views.CloseWorkspace(DataCloseWorkspace^.Workspace);
      end;
      mtReplaceWorkspace:
      begin
        Views.ReplaceWorkspace(DataReplaceWorkspace^.WorkspaceOld, DataReplaceWorkspace^.WorkspaceNew);
      end;
      mtResizeWorkspace:
      begin
        DataResizeWorkspace^.Workspace.Frame := DataResizeWorkspace^.Frame;
      end;
      mtMouseDown:
      begin
        OnMouseDown(DataMouseInput^.Button, DataMouseInput^.x, DataMouseInput^.y);
      end;
      mtMouseUp:
      begin
        OnMouseUp(DataMouseInput^.Button, DataMouseInput^.x, DataMouseInput^.y);
      end;
      mtLoadLayout:
      begin
        LayoutLoad(DataLoadLayput^.FileName);
      end;
      mtOpenProject:
      begin
        App.Project.Load(DataOpenProject^.FileName);
      end;
      mtCallProc:
      begin
        if Assigned(DataCallProc^.Proc) then DataCallProc^.Proc;
      end;
      mtCallProcPtr:
      begin
        if Assigned(DataCallProcPtr^.Proc) then DataCallProcPtr^.Proc(DataCallProcPtr^.Ptr);
      end;
    end;
    MessagesDumped.Add(m);
  end;
end;

procedure TUI.OnMouseDown(const Button, x, y: Integer);
begin
  if TextEdit.Enabled then
  TextEdit.OnMouseDown(x, y);
  if not TextEdit.Enabled then
  begin
    if Overlay <> nil then
    begin
      Overlay.MouseDown(Button, x, y);
    end
    else
    begin
      Views.OnMouseDown(Button, x, y);
    end;
  end;
end;

procedure TUI.OnMouseUp(const Button, x, y: Integer);
begin
  if TextEdit.Enabled then
  TextEdit.OnMouseUp(x, y);
  if not TextEdit.Enabled then
  begin
    if Overlay <> nil then
    begin
      Overlay.MouseUp(Button, x, y);
    end
    else
    begin
      Views.OnMouseUp(Button, x, y);
    end;
  end;
end;

procedure TUI.OnScroll(const y: Integer);
begin
  if TextEdit.Enabled then
  TextEdit.OnScroll(y);
  if not TextEdit.Enabled then
  begin
    if Overlay <> nil then
    begin
      Overlay.Scroll(y);
    end
    else
    begin
      Views.OnScroll(y);
    end;
  end;
end;

procedure TUI.OnPrint(const Char: AnsiChar);
begin
  if TextEdit.Enabled then
  begin
    TextEdit.OnPrint(Char);
  end
  else
  begin

  end;
end;

procedure TUI.OnKeyDown(const Key: TG2IntS32);
begin
  if TextEdit.Enabled then
  begin
    TextEdit.OnKeyDown(Key);
  end
  else
  begin
    if TUIWorkspace.Focus <> nil then
    TUIWorkspace.Focus.KeyDown(Key);
  end;
end;

procedure TUI.OnKeyUp(const Key: TG2IntS32);
begin
  if TextEdit.Enabled then
  begin
    TextEdit.OnKeyUp(Key);
  end
  else
  begin
    if TUIWorkspace.Focus <> nil then
    TUIWorkspace.Focus.KeyUp(Key);
  end;
end;

function TUI.GetColorPrimary(const Brightness: Single; const Alpha: Single): TG2Color;
begin
  Result.r := Round(ColorPrimary.r * Brightness);
  Result.g := Round(ColorPrimary.g * Brightness);
  Result.b := Round(ColorPrimary.b * Brightness);
  Result.a := Round(ColorPrimary.a * Alpha);
end;

function TUI.GetColorSecondary(const Brightness: Single; const Alpha: Single): TG2Color;
begin
  Result.r := Round(ColorSecondary.r * Brightness);
  Result.g := Round(ColorSecondary.g * Brightness);
  Result.b := Round(ColorSecondary.b * Brightness);
  Result.a := Round(ColorSecondary.a * Alpha);
end;

procedure TUI.DrawCross(const R: TRect; const Color: TG2Color);
  var x0, x1, x2, x3, y0, y1, y2, y3: Single;
begin
  x0 := R.Left;
  x1 := G2LerpFloat(R.Left, R.Right, 0.2);
  x2 := G2LerpFloat(R.Left, R.Right, 0.8);
  x3 := R.Right;
  y0 := R.Top;
  y1 := G2LerpFloat(R.Top, R.Bottom, 0.2);
  y2 := G2LerpFloat(R.Top, R.Bottom, 0.8);
  y3 := R.Bottom;
  g2.PrimAdd(x0, y1, Color);
  g2.PrimAdd(x1, y0, Color);
  g2.PrimAdd(x3, y2, Color);
  g2.PrimAdd(x0, y1, Color);
  g2.PrimAdd(x3, y2, Color);
  g2.PrimAdd(x2, y3, Color);
  g2.PrimAdd(x1, y3, Color);
  g2.PrimAdd(x0, y2, Color);
  g2.PrimAdd(x2, y0, Color);
  g2.PrimAdd(x1, y3, Color);
  g2.PrimAdd(x2, y0, Color);
  g2.PrimAdd(x3, y1, Color);
end;

procedure TUI.DrawRects(const R: TRect; const Color: TG2Color);
  var xl, xh, x0, x1, x2, x3, yl, yh, y0, y1, y2, y3: Single;
begin
  x0 := R.Left;
  x1 := G2LerpFloat(R.Left, R.Right, 0.45);
  x2 := G2LerpFloat(R.Left, R.Right, 0.55);
  x3 := R.Right;
  y0 := R.Top;
  y1 := G2LerpFloat(R.Top, R.Bottom, 0.45);
  y2 := G2LerpFloat(R.Top, R.Bottom, 0.55);
  y3 := R.Bottom;
  xl := x0; xh := x1;
  yl := y0; yh := y1;
  g2.PrimAdd(xl, yl, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xh, yh, Color);
  xl := x2; xh := x3;
  g2.PrimAdd(xl, yl, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xh, yh, Color);
  xl := x0; xh := x1;
  yl := y2; yh := y3;
  g2.PrimAdd(xl, yl, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xh, yh, Color);
  xl := x2; xh := x3;
  g2.PrimAdd(xl, yl, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xl, yh, Color);
  g2.PrimAdd(xh, yl, Color);
  g2.PrimAdd(xh, yh, Color);
end;

procedure TUI.DrawCircles(const R: TRect; const Color: TG2Color);
  var i, j: Integer;
  var w, h, Radius0, Radius1: Single;
begin
  w := (R.Right - R.Left) * 0.25;
  h := (R.Bottom - R.Top) * 0.25;
  Radius1 := G2Min(w * 0.3, h * 0.3);
  Radius0 := Radius1 * 1.5;
  for i := 0 to 2 do
  for j := 0 to 2 do
  begin
    g2.PrimCircleCol(
      R.Left + w + i * w,
      R.Top + h + j * h,
      Radius0, $ff000000, 0,
      8
    );
    g2.PrimCircleCol(
      R.Left + w + i * w,
      R.Top + h + j * h,
      Radius1, Color, Color,
      8
    );
  end;
end;

procedure TUI.DrawRectBorder(const R: TRect; const Border: Integer; const Color: TG2Color);
  var x0, x1, x2, x3, x4, x5, y0, y1, y2, y3, y4, y5: Single;
  var c0, c1: TG2Color;
begin
  c0 := Color;
  c1 := Color; c1.a := 0;
  x0 := R.Left - Border;
  x1 := R.Left;
  x2 := R.Left + Border;
  x3 := R.Right - Border;
  x4 := R.Right;
  x5 := R.Right + Border;
  y0 := R.Top - Border;
  y1 := R.Top;
  y2 := R.Top + Border;
  y3 := R.Bottom - Border;
  y4 := R.Bottom;
  y5 := R.Bottom + Border;
  g2.PrimAdd(x0, y1, c1);
  g2.PrimAdd(x1, y0, c1);
  g2.PrimAdd(x1, y1, c0);

  g2.PrimAdd(x1, y0, c1);
  g2.PrimAdd(x4, y0, c1);
  g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x4, y0, c1);
  g2.PrimAdd(x4, y1, c0);

  g2.PrimAdd(x4, y0, c1);
  g2.PrimAdd(x5, y1, c1);
  g2.PrimAdd(x4, y1, c0);

  g2.PrimAdd(x4, y1, c0);
  g2.PrimAdd(x5, y1, c1);
  g2.PrimAdd(x5, y4, c1);
  g2.PrimAdd(x4, y1, c0);
  g2.PrimAdd(x5, y4, c1);
  g2.PrimAdd(x4, y4, c0);

  g2.PrimAdd(x4, y4, c0);
  g2.PrimAdd(x5, y4, c1);
  g2.PrimAdd(x4, y5, c1);

  g2.PrimAdd(x4, y4, c0);
  g2.PrimAdd(x4, y5, c1);
  g2.PrimAdd(x1, y5, c1);
  g2.PrimAdd(x4, y4, c0);
  g2.PrimAdd(x1, y5, c1);
  g2.PrimAdd(x1, y4, c0);

  g2.PrimAdd(x1, y4, c0);
  g2.PrimAdd(x1, y5, c1);
  g2.PrimAdd(x0, y4, c1);

  g2.PrimAdd(x1, y4, c0);
  g2.PrimAdd(x0, y4, c1);
  g2.PrimAdd(x0, y1, c1);
  g2.PrimAdd(x1, y4, c0);
  g2.PrimAdd(x0, y1, c1);
  g2.PrimAdd(x1, y1, c0);

  g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x4, y1, c0);
  g2.PrimAdd(x3, y2, c1);
  g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x3, y2, c1);
  g2.PrimAdd(x2, y2, c1);

  g2.PrimAdd(x3, y2, c1);
  g2.PrimAdd(x4, y1, c0);
  g2.PrimAdd(x4, y4, c0);
  g2.PrimAdd(x3, y2, c1);
  g2.PrimAdd(x4, y4, c0);
  g2.PrimAdd(x3, y3, c1);

  g2.PrimAdd(x3, y3, c1);
  g2.PrimAdd(x4, y4, c0);
  g2.PrimAdd(x1, y4, c0);
  g2.PrimAdd(x3, y3, c1);
  g2.PrimAdd(x1, y4, c0);
  g2.PrimAdd(x2, y3, c1);

  g2.PrimAdd(x2, y3, c1);
  g2.PrimAdd(x1, y4, c0);
  g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x2, y3, c1);
  g2.PrimAdd(x1, y1, c0);
  g2.PrimAdd(x2, y2, c1);
end;

procedure TUI.DrawPlus(const R: TRect; const Color: TG2Color);
  var x0, x1, x2, x3, y0, y1, y2, y3: Single;
begin
  x0 := G2LerpFloat(R.Left, R.Right, 0.1);
  x1 := G2LerpFloat(R.Left, R.Right, 0.4);
  x2 := G2LerpFloat(R.Left, R.Right, 0.6);
  x3 := G2LerpFloat(R.Left, R.Right, 0.9);
  y0 := G2LerpFloat(R.Top, R.Bottom, 0.1);
  y1 := G2LerpFloat(R.Top, R.Bottom, 0.4);
  y2 := G2LerpFloat(R.Top, R.Bottom, 0.6);
  y3 := G2LerpFloat(R.Top, R.Bottom, 0.9);
  g2.PrimAdd(x0, y2, Color);
  g2.PrimAdd(x0, y1, Color);
  g2.PrimAdd(x3, y1, Color);
  g2.PrimAdd(x0, y2, Color);
  g2.PrimAdd(x3, y1, Color);
  g2.PrimAdd(x3, y2, Color);
  g2.PrimAdd(x1, y0, Color);
  g2.PrimAdd(x2, y0, Color);
  g2.PrimAdd(x2, y3, Color);
  g2.PrimAdd(x1, y0, Color);
  g2.PrimAdd(x2, y3, Color);
  g2.PrimAdd(x1, y3, Color);
end;

procedure TUI.DrawSmoothCircle(const Center: TG2Vec2; const Radius0, Radius1: Single; const Segments: Integer; const Color0, Color1, Color2: TG2Color);
  var a, s, c: Single;
  var v0, v1, v2, v3: TG2Vec2;
  var i: Integer;
begin
  a := G2TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  v0.SetValue(Radius0, 0);
  v1.SetValue(Radius1, 0);
  g2.PrimBegin(ptTriangles, bmNormal);
  for i := 0 to Segments - 1 do
  begin
    v2.SetValue(c * v0.x - s * v0.y, s * v0.x + c * v0.y);
    v3.SetValue(c * v1.x - s * v1.y, s * v1.x + c * v1.y);
    g2.PrimAdd(Center.x, Center.y, Color0);
    g2.PrimAdd(Center.x + v0.x, Center.y + v0.y, Color1);
    g2.PrimAdd(Center.x + v2.x, Center.y + v2.y, Color1);
    g2.PrimAdd(Center.x + v0.x, Center.y + v0.y, Color1);
    g2.PrimAdd(Center.x + v1.x, Center.y + v1.y, Color2);
    g2.PrimAdd(Center.x + v2.x, Center.y + v2.y, Color1);
    g2.PrimAdd(Center.x + v2.x, Center.y + v2.y, Color1);
    g2.PrimAdd(Center.x + v1.x, Center.y + v1.y, Color2);
    g2.PrimAdd(Center.x + v3.x, Center.y + v3.y, Color2);
    v0 := v2;
    v1 := v3;
  end;
  g2.PrimEnd;
end;

procedure TUI.DrawCircleBorder(
  const Center: TG2Vec2;
  const Radius, Border: TG2Float;
  const Segments: Integer;
  const Color: TG2Color
);
  var a, s, c: Single;
  var v0, v1, v2, p0, p1, p2: TG2Vec2;
  var c0, c1: TG2Color;
  var i: Integer;
begin
  a := G2TwoPi / Segments;
  {$Hints off}
  G2SinCos(a, s, c);
  {$Hints on}
  c0 := Color;
  c1 := c0; c1.a := 0;
  p0.SetValue(Radius - Border, 0);
  p1.SetValue(Radius, 0);
  p2.SetValue(Radius + Border, 0);
  g2.PrimBegin(ptTriangles, bmNormal);
  for i := 0 to Segments - 1 do
  begin
    v0.SetValue(c * p0.x - s * p0.y, s * p0.x + c * p0.y);
    v1.SetValue(c * p1.x - s * p1.y, s * p1.x + c * p1.y);
    v2.SetValue(c * p2.x - s * p2.y, s * p2.x + c * p2.y);
    g2.PrimAdd(Center + v0, c1); g2.PrimAdd(Center + p0, c1); g2.PrimAdd(Center + p1, c0);
    g2.PrimAdd(Center + v0, c1); g2.PrimAdd(Center + p1, c0); g2.PrimAdd(Center + v1, c0);
    g2.PrimAdd(Center + v1, c0); g2.PrimAdd(Center + p1, c0); g2.PrimAdd(Center + p2, c1);
    g2.PrimAdd(Center + v1, c0); g2.PrimAdd(Center + p2, c1); g2.PrimAdd(Center + v2, c1);
    p0 := v0; p1 := v1; p2 := v2;
  end;
  g2.PrimEnd;
end;

procedure TUI.DrawCheckbox(const R: TRect; const Color0, Color1: TG2Color; const Checked: Boolean);
  var x0, x1, x2, x3, x4, y0, y1, y2, y3, y4: Single;
  var c0, c1, c2, c3: TG2Color;
begin
  c0 := Color0; c0.a := 0;
  c1 := Color0;
  c2 := G2LerpColor(Color0, $ff000000, 0.5);
  c3 := G2LerpColor(Color1, $ff000000, 0.1);
  x0 := R.Left;
  x1 := G2LerpFloat(R.Left, R.Right, 0.15);
  x2 := G2LerpFloat(R.Left, R.Right, 0.5);
  x3 := G2LerpFloat(R.Left, R.Right, 0.85);
  x4 := R.Right;
  y0 := R.Top;
  y1 := G2LerpFloat(R.Top, R.Bottom, 0.15);
  y2 := G2LerpFloat(R.Top, R.Bottom, 0.5);
  y3 := G2LerpFloat(R.Top, R.Bottom, 0.85);
  y4 := R.Bottom;
  g2.PrimBegin(ptTriangles, bmNormal);
  g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x4, y0, c0); g2.PrimAdd(x1, y1, c1);
  g2.PrimAdd(x1, y1, c1); g2.PrimAdd(x4, y0, c0); g2.PrimAdd(x3, y1, c1);
  g2.PrimAdd(x4, y0, c0); g2.PrimAdd(x4, y4, c0); g2.PrimAdd(x3, y1, c1);
  g2.PrimAdd(x3, y1, c1); g2.PrimAdd(x4, y4, c0); g2.PrimAdd(x3, y3, c1);
  g2.PrimAdd(x4, y4, c0); g2.PrimAdd(x0, y4, c0); g2.PrimAdd(x3, y3, c1);
  g2.PrimAdd(x3, y3, c1); g2.PrimAdd(x0, y4, c0); g2.PrimAdd(x1, y3, c1);
  g2.PrimAdd(x0, y4, c0); g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x1, y3, c1);
  g2.PrimAdd(x1, y3, c1); g2.PrimAdd(x0, y0, c0); g2.PrimAdd(x1, y1, c1);

  g2.PrimAdd(x1, y1, c1); g2.PrimAdd(x3, y1, c1); g2.PrimAdd(x2, y2, c2);
  g2.PrimAdd(x3, y1, c1); g2.PrimAdd(x3, y3, c1); g2.PrimAdd(x2, y2, c2);
  g2.PrimAdd(x3, y3, c1); g2.PrimAdd(x1, y3, c1); g2.PrimAdd(x2, y2, c2);
  g2.PrimAdd(x1, y3, c1); g2.PrimAdd(x1, y1, c1); g2.PrimAdd(x2, y2, c2);
  g2.PrimEnd;

  if Checked then
  begin
    x0 := G2LerpFloat(R.Left, R.Right, 0.3);
    x1 := G2LerpFloat(R.Left, R.Right, 0.7);
    y0 := G2LerpFloat(R.Top, R.Bottom, 0.3);
    y1 := G2LerpFloat(R.Top, R.Bottom, 0.7);
    g2.PrimQuad(
      x0, y0, x1, y0,
      x0, y1, x1, y1,
      c3, bmNormal
    );
  end;
end;

procedure TUI.DrawRadio(const R: TRect; const Color0, Color1: TG2Color; const Checked: Boolean);
  var cx, cy, r0, r1: TG2Float;
  var c0, c1, c2, c3: TG2Color;
  const Segments = 32;
begin
  c0 := Color0; c0.a := 0;
  c1 := Color0;
  c2 := G2LerpColor(Color0, $ff000000, 0.5);
  c3 := G2LerpColor(Color1, $ff000000, 0.1);
  cx := (R.Left + R.Right) * 0.5;
  cy := (R.Top + R.Bottom) * 0.5;
  r1 := G2Min(R.Right - R.Left, R.Bottom - R.Top) * 0.5;
  r0 := r1 * 0.85;
  DrawSmoothCircle(G2Vec2(cx, cy), r0, r1, Segments, c2, c1, c0);
  if Checked then
  begin
    r1 := r1 * 0.6;
    r0 := r1 * 0.7;
    c0 := c3; c0.a := 0;
    c1 := c3;
    c2 := c3;
    DrawSmoothCircle(G2Vec2(cx, cy), r0, r1, Segments, c2, c1, c0);
  end;
end;

procedure TUI.DrawArrow(
  const Origin, Target: TG2Vec2;
  const Size: TG2Float;
  const Color: TG2Color
);
  var d, n: TG2Vec2;
  var o: TG2Vec2 absolute Origin;
  var t: TG2Vec2;
  var c0, c1: TG2Color;
  var w: TG2Float;
begin
  d := Target - Origin;
  if d.LenSq < 1 then Exit;
  c0 := Color;
  c1 := c0; c1.a := 0;
  d := d.Norm * (Size * 0.25);
  n := d.Perp;
  w := 2;
  t := Target - d * 8;
  g2.PrimQuad(o - n, t - n, o + n, t + n, c0);
  g2.PrimTriCol(t - n, t + d * 8, t + n, c0, c0, c0);
  g2.PrimTriCol(t - n, t - n * w, t + d * 8, c0, c0, c0);
  g2.PrimTriCol(t + n, t + d * 8, t + n * w, c0, c0, c0);
  g2.PrimQuadCol(o - n, o + n, o - n * 2 - d, o + n * 2 - d, c0, c0, c1, c1);
  g2.PrimQuadCol(t - n, o - n, t - n * 2 - d, o - n * 2 - d, c0, c0, c1, c1);
  g2.PrimQuadCol(o + n, t + n, o + n * 2 - d, t + n * 2 - d, c0, c0, c1, c1);
  g2.PrimQuadCol(t - n * w, t - n, t - n * (2 + w) - d, t - n * 2 - d, c0, c0, c1, c1);
  g2.PrimQuadCol(t + d * 8, t - n * w, t + d * 14, t - n * (2 + w) - d, c0, c0, c1, c1);
  g2.PrimQuadCol(t + n, t + n * w, t + n * 2 - d, t + n * (2 + w) - d, c0, c0, c1, c1);
  g2.PrimQuadCol(t + n * w, t + d * 8, t + n * (2 + w) - d, t + d * 14, c0, c0, c1, c1);
end;

procedure TUI.DrawSpotFrame(const R: TRect; const FrameSize: TG2Float; const Color: TG2Color);
  procedure AddQuad(const x0, y0, x1, y1: TG2Float; const u0, v0, u1, v1: TG2Float);
  begin
    g2.PolyAdd(x0, y0, u0, v0, Color); g2.PolyAdd(x1, y0, u1, v0, Color); g2.PolyAdd(x0, y1, u0, v1, Color);
    g2.PolyAdd(x0, y1, u0, v1, Color); g2.PolyAdd(x1, y0, u1, v0, Color); g2.PolyAdd(x1, y1, u1, v1, Color);
  end;
  var x0, x1, x2, x3, y0, y1, y2, y3: TG2Float;
begin
  g2.PolyBegin(ptTriangles, App.UI.TexSpot, bmNormal, tfLinear);
  x0 := R.Left; x1 := x0 + FrameSize; x2 := R.Right - FrameSize; x3 := R.Right;
  y0 := R.Top; y1 := y0 + FrameSize; y2 := R.Bottom - FrameSize; y3 := R.Bottom;
  AddQuad(x0, y0, x1, y1, 0, 0, 0.5, 0.5);
  AddQuad(x1, y0, x2, y1, 0.5, 0, 0.5, 0.5);
  AddQuad(x2, y0, x3, y1, 0.5, 0, 1, 0.5);
  AddQuad(x0, y1, x1, y2, 0, 0.5, 0.5, 0.5);
  AddQuad(x1, y1, x2, y2, 0.5, 0.5, 0.5, 0.5);
  AddQuad(x2, y1, x3, y2, 0.5, 0.5, 1, 0.5);
  AddQuad(x0, y2, x1, y3, 0, 0.5, 0.5, 1);
  AddQuad(x1, y2, x2, y3, 0.5, 0.5, 0.5, 1);
  AddQuad(x2, y2, x3, y3, 0.5, 0.5, 1, 1);
  g2.PolyEnd;
end;

procedure TUI.PushClipRect(const R: TRect);
  var cr: TRect;
begin
  if Length(ClipRects) > 0 then
  begin
    cr := ClipRects[High(ClipRects)];
    if R.Left > cr.Left then cr.Left := R.Left;
    if R.Top > cr.Top then cr.Top := R.Top;
    if R.Right < cr.Right then cr.Right := R.Right;
    if R.Bottom < cr.Bottom then cr.Bottom := R.Bottom;
  end
  else
  cr := R;
  SetLength(ClipRects, Length(ClipRects) + 1);
  ClipRects[High(ClipRects)] := cr;
  g2.Gfx.StateChange.StateScissor := @cr;
end;

procedure TUI.PopClipRect;
begin
  if Length(ClipRects) > 0 then
  SetLength(ClipRects, High(ClipRects));
  if Length(ClipRects) > 0 then
  g2.Gfx.StateChange.StateScissor := @ClipRects[High(ClipRects)]
  else
  g2.Gfx.StateChange.StateScissor := nil;
end;

procedure TUI.LayoutSave(const FileName: String);
  var g2ml: TG2MLWriter;
  procedure WriteWorkspace(const Workspace: TUIWorkspace);
    var i: Integer;
  begin
    g2ml.NodeOpen('workspace');
    if Workspace is TUIWorkspaceFrame then
    begin
      g2ml.NodeValue('type', Workspace.ClassName);
      for i := 0 to Workspace.ChildCount - 1 do
      WriteWorkspace(Workspace.Children[i]);
    end
    else if Workspace is TUIWorkspaceSplitter then
    begin
      g2ml.NodeValue('type', Workspace.ClassName);
      if TUIWorkspaceSplitter(Workspace).Orientation = soVertical then
      g2ml.NodeValue('orientation', 'vertical')
      else
      g2ml.NodeValue('orientation', 'horizontal');
      g2ml.NodeValue('split', TUIWorkspaceSplitter(Workspace).SplitPos);
      for i := 0 to Workspace.ChildCount - 1 do
      WriteWorkspace(Workspace.Children[i]);
    end
    else
    begin
      g2ml.NodeValue('type', Workspace.ClassName);
    end;
    g2ml.NodeClose;
  end;
  var i: Integer;
  var View: PView;
  var fs: TFileStream;
begin
  g2ml := TG2MLWriter.Create;
  g2ml.NodeOpen('g2mp_toolkit_layout');
  for i := 0 to Views.Views.Count - 1 do
  begin
    View := PView(Views.Views[i]);
    g2ml.NodeOpen('view');
    g2ml.NodeValue('name', View^.Name);
    if View^.Workspace <> nil then
    WriteWorkspace(View^.Workspace);
    g2ml.NodeClose;
  end;
  g2ml.NodeClose;
  fs := TFileStream.Create(FileName, fmCreate);
  try
    fs.WriteBuffer(g2ml.G2ML[1], Length(g2ml.G2ML));
  finally
    fs.Free;
  end;
  g2ml.Free;
end;

procedure TUI.LayoutLoad(const FileName: String);
  var g2ml: TG2ML;
  var Root: PG2MLObject;
  var fs: TFileStream;
  var Data: AnsiString;
  var View: PView;
  procedure ReadWorkspace(const Node: PG2MLObject; const Parent: TUIWorkspace);
    var Workspace: TUIWorkspace;
    var Splitter: TUIWorkspaceSplitter absolute Workspace;
    var NodeType, NodeOrientation, NodeSplit: PG2MLObject;
    var Split: Single;
    var i: Integer;
    var n: PG2MLObject;
  begin
    NodeType := Node^.FindNode('type');
    if NodeType <> nil then
    begin
      Workspace := nil;
      if NodeType^.AsString = TUIWorkspaceSplitter.ClassName then
      begin
        NodeOrientation := Node^.FindNode('orientation');
        NodeSplit := Node^.FindNode('split');
        if NodeOrientation <> nil then
        begin
          Splitter := TUIWorkspaceSplitter.Create;
          if NodeSplit <> nil then
          Split := NodeSplit^.AsFloat
          else
          Split := 0.5;
          for i := 0 to Node^.Children.Count - 1 do
          begin
            n := Node^.Children[i];
            if n^.Name = 'workspace' then
            ReadWorkspace(n, Workspace);
          end;
          if NodeOrientation^.AsString = 'vertical' then
          Splitter._Orientation := soVertical
          else
          Splitter._Orientation := soHorizontal;
          Splitter._SplitPos := Split;
        end
        else
        begin
          App.Console.AddLine('Error: corrupt layout data.');
          Exit;
        end;
      end
      else if NodeType^.AsString = TUIWorkspaceFrame.ClassName then
      begin
        Workspace := TUIWorkspaceFrame.Create;
        for i := 0 to Node^.Children.Count - 1 do
        begin
          n := Node^.Children[i];
          if n^.Name = 'workspace' then
          ReadWorkspace(n, Workspace);
        end;
      end
      else
      begin
        for i := 0 to App.UI.WorkspaceClasses.Count - 1 do
        if NodeType^.AsString = App.UI.WorkspaceClasses[i].WorkspaceClass.ClassName then
        begin
          Workspace := App.UI.WorkspaceClasses[i].WorkspaceClass.Create;
          Break;
        end;
      end;
      if Workspace <> nil then
      begin
        if Parent = nil then
        begin
          View^.Workspace := Workspace;
          Workspace.Frame := App.UI.WorkspaceFrame;
        end
        else
        begin
          Workspace.Parent := Parent;
        end;
      end;
    end
    else
    begin
      App.Console.AddLine('Error: corrupt layout data.');
      Exit;
    end;
  end;
  var i0, i1, i2: Integer;
  var n0, n1, n2, n: PG2MLObject;
begin
  fs := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(Data, fs.Size);
    fs.ReadBuffer(Data[1], Length(Data));
  finally
    fs.Free;
  end;
  g2ml := TG2ML.Create;
  Root := g2ml.Read(Data);
  for i0 := 0 to Root^.Children.Count - 1 do
  begin
    n0 := Root^.Children[i0];
    if n0^.Name = 'g2mp_toolkit_layout' then
    begin
      App.UI.Views.Clear;
      App.UI.Views.ViewIndex := -1;
      for i1 := 0 to n0^.Children.Count - 1 do
      begin
        n1 := n0^.Children[i1];
        if n1^.Name = 'view' then
        begin
          n := n1^.FindNode('name');
          if n <> nil then
          begin
            View := App.UI.Views.AddView(n^.AsString);
            for i2 := 0 to n1^.Children.Count - 1 do
            begin
              n2 := n1^.Children[i2];
              if n2^.Name = 'workspace' then
              begin
                ReadWorkspace(n2, nil);
              end;
            end;
          end
          else
          begin
            App.Console.AddLine('Error: corrupt layout data.');
            Exit;
          end;
        end;
      end;
      if App.UI.Views.Views.Count > 0 then
      begin
        App.UI.Views.ViewIndex := 0;
        if App.UI.Views.CurView^.Workspace <> nil then
        MsgResizeWorkspace(App.UI.Views.CurView^.Workspace, App.UI.WorkspaceFrame);
      end;
    end;
  end;
  g2ml.Free;
end;
//TUI END

//TLog BEGIN
function TLog.GetLine(const Index: Integer): AnsiString;
  var i: Integer;
begin
  i := _CurLine - Index - 1;
  while i < 0 do i := Length(_Lines) + i;
  Result := _Lines[i];
end;

procedure TLog.Initialize;
begin
  Clear;
end;

procedure TLog.Finalize;
begin

end;

procedure TLog.Clear;
begin
  _LineCount := 0;
  _CurLine := 0;
end;

procedure TLog.Log(const Text: AnsiString);
begin
  _Lines[_CurLine] := '[' + TimeToStr(Time) + '] ' + Text;
  _CurLine := (_CurLine + 1) mod Length(_Lines);
  if _LineCount < Length(_Lines) then
  Inc(_LineCount);
end;

procedure TLog.AssertLog(const Value: Boolean; const LogMessage: AnsiString = 'Error');
begin
  if not Value then
  Log(LogMessage);
end;

procedure TLog.ProfileBegin;
begin
  _TimeStamp := G2Time;
end;

function TLog.ProfileEnd: LongWord;
begin
  Result := G2Time - _TimeStamp;
  Log('Profile: ' + IntToStr(Result));
end;
//TLog END

//TConsole BEGIN
function TConsole.GetLine(const Index: Integer): AnsiString;
  var i: Integer;
begin
  i := _CurLine - Index - 1;
  while i < 0 do i := Length(_Lines) + i;
  Result := _Lines[i];
end;

procedure TConsole.AddLine(const Line: AnsiString);
begin
  _Lines[_CurLine] := Line;
  _CurLine := (_CurLine + 1) mod Length(_Lines);
  if _LineCount < Length(_Lines) then
  Inc(_LineCount);
end;

procedure TConsole.Initialize;
begin
  Clear;
  _Parser := TG2Parser.Create;
  _Parser.AddString('''');
  _Parser.AddString('"');
  _Parser.AddSymbol(',');
  _Parser.AddKeyWord('log');
  _Parser.AddKeyWord('view_add');
  _Parser.AddKeyWord('view_delete');
  _Parser.AddKeyWord('view_select');
  _Parser.AddKeyWord('test');
  _Parser.AddKeyWord('help');
  _Parser.AddKeyWord('thread_test');
end;

procedure TConsole.Finalize;
begin
  _Parser.Free;
end;

procedure TConsole.Clear;
begin
  _LineCount := 0;
  _CurLine := 0;
end;

procedure TConsole.Command(const Text: AnsiString);
  var Token: AnsiString;
  var tt: TG2TokenType;
  var i: Integer;
begin
  _Parser.Parse(Text);
  Token := _Parser.NextToken(tt);
  if tt = ttKeyword then
  begin
    if Token = 'log' then
    begin
      Token := _Parser.NextToken(tt);
      App.Log.Log(Token);
      AddLine('logged: ' + Token);
    end
    else if Token = 'view_add' then
    begin
      Token := _Parser.NextToken(tt);
      if tt = ttString then
      begin
        if Length(Token) > 0 then
        App.UI.Views.AddView(Token)
        else
        App.UI.Views.AddView('View');
      end
      else
      App.UI.Views.AddView('View');
    end
    else if Token = 'view_delete' then
    begin
      Token := _Parser.NextToken(tt);
      if tt = ttString then
      begin
        if Length(Token) > 0 then
        App.UI.Views.DeleteView(Token);
      end
      else
      AddLine('error: string parameter expected');
    end
    else if Token = 'view_select' then
    begin
      Token := _Parser.NextToken(tt);
      if tt = ttString then
      begin
        if Length(Token) > 0 then
        App.UI.Views.SelectView(Token);
      end
      else
      AddLine('error: string parameter expected');
    end
    else if Token = 'test' then
    begin
      Clipboard.AsText := 'test';
      AddLine(Clipboard.AsText);
    end
    else if Token = 'help' then
    begin
      AddLine('available commands:');
      for i := 0 to _Parser.KeyWordCount - 1 do
      AddLine(_Parser.KeyWords[i]);
    end;
  end
  else
  AddLine('unknown command: ' + Token);
end;
//TConsole END

//TProject BEGIN
function TProject.GetProjectPath: AnsiString;
begin
  Result := _FilePath + _FileName;
end;

function TProject.GetProjectIncludeSource(const Index: Integer): AnsiString;
begin
  Result := _ProjectIncludeSource[Index];
end;

function TProject.GetProjectIncludeSourceCount: Integer;
begin
  Result := Length(_ProjectIncludeSource);
end;

function TProject.GetProjectName: AnsiString;
  var Ext: AnsiString;
begin
  if _Open then
  begin
    Ext := ExtractFileExt(_FileName);
    Result := G2StrCut(_FileName, 1, Length(_FileName) - Length(Ext));
    Result := G2StrReplace(Result, ' ', '_');
  end
  else
  Result := '';
end;

procedure TProject.Initialize;
begin
  _Open := False;
  _FileName := '';
  _FilePath := '';
  _md5.Clear;
end;

procedure TProject.Finalize;
begin

end;

procedure TProject.Update;
  var fa: Integer;
  var t: TG2IntU32;
begin
  if _Open then
  begin
    t := G2Time;
    if t - _LastModifyCheck > 2000 then
    begin
      _LastModifyCheck := t;
      fa := FileAge(ProjectPath);
      if fa <> _LastModified then
      begin
        _LastModified := fa;
        UpdateSettings;
      end;
    end;
  end;
end;

procedure TProject.New;
  var sd: TSaveDialog;
  var cf: TCodeFile;
begin
  sd := TSaveDialog.Create(nil);
  sd.DefaultExt := '.g2pr';
  g2.Pause := True;
  if sd.Execute then
  begin
    _FileName := ExtractFileName(sd.FileName);
    _FilePath := ExtractFilePath(sd.FileName);
    CreateDirUTF8(_FilePath + 'source');
    CreateDirUTF8(_FilePath + 'assets');
    cf.Initialize;
    cf.AddLine('(* project settings:');
    cf.AddLine('  {#include');
    cf.AddLine('    source = "$(project_root)source"');
    cf.AddLine('  #}');
    cf.AddLine('*)');
    cf.AddLine('program {#project_name#};');
    cf.AddLine('');
    cf.AddLine('uses');
    cf.AddLine('  Gen2MP,');
    cf.AddLine('  GameUnit;');
    cf.AddLine('');
    cf.AddLine('begin');
    cf.AddLine('  Game := TGame.Create;');
    cf.AddLine('  g2.Start;');
    cf.AddLine('  Game.Free;');
    cf.AddLine('end.');
    cf.Save(ProjectPath);
    cf.Finalize;
    cf.Initialize;
    cf.AddLine('unit GameUnit;');
    cf.AddLine('');
    cf.AddLine('interface');
    cf.AddLine('');
    cf.AddLine('uses');
    cf.AddLine('  Gen2MP,');
    cf.AddLine('  G2Types,');
    cf.AddLine('  G2Math,');
    cf.AddLine('  G2Utils,');
    cf.AddLine('  G2DataManager,');
    cf.AddLine('  Types,');
    cf.AddLine('  Classes;');
    cf.AddLine('');
    cf.AddLine('type');
    cf.AddLine('  TGame = class');
    cf.AddLine('  protected');
    cf.AddLine('  public');
    cf.AddLine('    constructor Create;');
    cf.AddLine('    destructor Destroy; override;');
    cf.AddLine('    procedure Initialize;');
    cf.AddLine('    procedure Finalize;');
    cf.AddLine('    procedure Update;');
    cf.AddLine('    procedure Render;');
    cf.AddLine('    procedure KeyDown(const Key: Integer);');
    cf.AddLine('    procedure KeyUp(const Key: Integer);');
    cf.AddLine('    procedure MouseDown(const Button, x, y: Integer);');
    cf.AddLine('    procedure MouseUp(const Button, x, y: Integer);');
    cf.AddLine('    procedure Scroll(const y: Integer);');
    cf.AddLine('    procedure Print(const c: AnsiChar);');
    cf.AddLine('  end;');
    cf.AddLine('');
    cf.AddLine('var');
    cf.AddLine('  Game: TGame;');
    cf.AddLine('');
    cf.AddLine('implementation');
    cf.AddLine('');
    cf.AddLine('//TGame BEGIN');
    cf.AddLine('constructor TGame.Create;');
    cf.AddLine('begin');
    cf.AddLine('  g2.CallbackInitializeAdd(@Initialize);');
    cf.AddLine('  g2.CallbackFinalizeAdd(@Finalize);');
    cf.AddLine('  g2.CallbackUpdateAdd(@Update);');
    cf.AddLine('  g2.CallbackRenderAdd(@Render);');
    cf.AddLine('  g2.CallbackKeyDownAdd(@KeyDown);');
    cf.AddLine('  g2.CallbackKeyUpAdd(@KeyUp);');
    cf.AddLine('  g2.CallbackMouseDownAdd(@MouseDown);');
    cf.AddLine('  g2.CallbackMouseUpAdd(@MouseUp);');
    cf.AddLine('  g2.CallbackScrollAdd(@Scroll);');
    cf.AddLine('  g2.CallbackPrintAdd(@Print);');
    cf.AddLine('  g2.Params.MaxFPS := 100;');
    cf.AddLine('  g2.Params.Width := 1024;');
    cf.AddLine('  g2.Params.Height := 768;');
    cf.AddLine('  g2.Params.ScreenMode := smMaximized;');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('destructor TGame.Destroy;');
    cf.AddLine('begin');
    cf.AddLine('  g2.CallbackInitializeRemove(@Initialize);');
    cf.AddLine('  g2.CallbackFinalizeRemove(@Finalize);');
    cf.AddLine('  g2.CallbackUpdateRemove(@Update);');
    cf.AddLine('  g2.CallbackRenderRemove(@Render);');
    cf.AddLine('  g2.CallbackKeyDownRemove(@KeyDown);');
    cf.AddLine('  g2.CallbackKeyUpRemove(@KeyUp);');
    cf.AddLine('  g2.CallbackMouseDownRemove(@MouseDown);');
    cf.AddLine('  g2.CallbackMouseUpRemove(@MouseUp);');
    cf.AddLine('  g2.CallbackScrollRemove(@Scroll);');
    cf.AddLine('  g2.CallbackPrintRemove(@Print);');
    cf.AddLine('  inherited Destroy;');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.Initialize;');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.Finalize;');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.Update;');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.Render;');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.KeyDown(const Key: Integer);');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.KeyUp(const Key: Integer);');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.MouseDown(const Button, x, y: Integer);');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.MouseUp(const Button, x, y: Integer);');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.Scroll(const y: Integer);');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('');
    cf.AddLine('procedure TGame.Print(const c: AnsiChar);');
    cf.AddLine('begin');
    cf.AddLine('');
    cf.AddLine('end;');
    cf.AddLine('//TGame END');
    cf.AddLine('');
    cf.AddLine('end.');
    cf.Save(_FilePath + 'source' + G2PathSep + 'GameUnit.pas');
    cf.Finalize;
    _LastModifyCheck := G2Time;
    _Open := True;
    ReLoad;
  end;
  g2.Pause := False;
  sd.Free;
end;

procedure TProject.Load;
  var od: TOpenDialog;
begin
  od := TOpenDialog.Create(nil);
  g2.Pause := True;
  if od.Execute then
  Load(od.FileName);
  g2.Pause := False;
  od.Free;
end;

procedure TProject.Load(const f: String);
begin
  Close;
  _FileName := ExtractFileName(f);
  _FilePath := ExtractFilePath(f);
  G2AssetSourceManager.SourceFile.AddPath(_FilePath + 'assets');
  _Open := True;
  ReLoad;
end;

procedure TProject.Close;
begin
  if _Open then
  begin
    G2AssetSourceManager.SourceFile.RemovePath(_FilePath + 'assets');
    App.CodeInsight.Clear;
    _FileName := '';
    _FilePath := '';
    _Open := False;
  end;
end;

procedure TProject.ReLoad;
begin
  _md5.Clear;
  _LastModified := FileAge(ProjectPath);
  UpdateSettings;
  App.CodeInsight.Scan;
end;

procedure TProject.Build;
  var CommandLine: String;
  procedure AddUnit(const UnitPath: String);
  begin
    CommandLine := CommandLine + ' -Fu"' + UnitPath + '"';
  end;
  procedure AddOption(const Option: String);
  begin
    CommandLine := CommandLine + ' ' + Option;
  end;
  type TOutputProcess = record
    sl: TStringList;
    ProcOutput: TMemoryStream;
    Proc: TProcessUTF8;
    ReadBytes, NumBytes: Integer;
  end;
  var CompilerProcess, ExeProcess: TOutputProcess;
  var cf: TCodeFile;
  var CompilerPath: String;
  var i: Integer;
  const READ_BYTES = 2048;
begin
  if not _Open then Exit;
  UpdateSettings;
  App.Log.Log('Build Started');
  App.Console.AddLine('Build Started');
  CompilerPath := g2.AppPath + 'fpc' + G2PathSep + 'i386-win32' + G2PathSep + 'fpc.exe';
  if not DirectoryExists(_FilePath + 'build') then
  CreateDir(_FilePath + 'build');
  if not DirectoryExists(_FilePath + 'build' + G2PathSep + 'obj') then
  CreateDir(_FilePath + 'build' + G2PathSep + 'obj');
  if not DirectoryExists(_FilePath + 'bin') then
  CreateDir(_FilePath + 'bin');
  cf.Initialize;
  cf.SetCode(G2StrReplace(_ProjectCode, '{#project_name#}', GetProjectName));
  cf.Save(_FilePath + 'build' + G2PathSep + _FileName);
  cf.Finalize;
  CommandLine := '';
  AddOption('-Mobjfpc');
  AddOption('-Sc');
  AddOption('-XX');
  AddOption('-Xs');
  AddOption('-ve');
  AddOption('-dG2Output');
  AddOption('-dG2Debug');
  AddOption('-FE' + '"' + _FilePath + 'bin' + '"');
  AddOption('-FU' + '"' + _FilePath + 'build' + G2PathSep + 'obj' + '"');
  AddUnit(g2.AppPath + '\fpc\i386-win32\rtl');
  AddUnit(g2.AppPath + '\fpc\i386-win32\winunits-base');
  AddUnit(g2.AppPath + '\fpc\i386-win32\paszlib');
  AddUnit(g2.AppPath + '..\..\source');//g2mp
  AddUnit(g2.AppPath + '..\..\source\box2d');
  AddUnit(g2.AppPath + '..\..\source\spine');
  for i := 0 to High(_ProjectIncludeSource) do
  AddUnit(G2StrReplace(_ProjectIncludeSource[i], '$(project_root)', _FilePath));
  CommandLine := CommandLine + ' "' + _FilePath + 'build' + G2PathSep + _FileName + '"';
  CompilerProcess.sl := TStringList.Create;
  CompilerProcess.ProcOutput := TMemoryStream.Create;
  CompilerProcess.Proc := TProcessUTF8.Create(nil);
  CompilerProcess.Proc.Executable := CompilerPath;
  CompilerProcess.Proc.CommandLine := CompilerProcess.Proc.Executable + CommandLine;
  CompilerProcess.Proc.Options := CompilerProcess.Proc.Options + [poUsePipes];
  CompilerProcess.Proc.ShowWindow := swoHIDE;
  CompilerProcess.ReadBytes := 0;
  CompilerProcess.Proc.Execute;
  while True do
  begin
    CompilerProcess.ProcOutput.SetSize(CompilerProcess.ReadBytes + READ_BYTES);
    CompilerProcess.NumBytes := CompilerProcess.Proc.Output.Read((CompilerProcess.ProcOutput.Memory + CompilerProcess.ReadBytes)^, READ_BYTES);
    if CompilerProcess.NumBytes > 0 then
    begin
      Inc(CompilerProcess.ReadBytes, CompilerProcess.NumBytes);
    end
    else
    Break;
  end;
  CompilerProcess.Proc.WaitOnExit;
  CompilerProcess.ProcOutput.SetSize(CompilerProcess.ReadBytes);
  CompilerProcess.sl.LoadFromStream(CompilerProcess.ProcOutput);
  if CompilerProcess.Proc.ExitStatus = 0 then
  begin
    for i := 0 to CompilerProcess.sl.Count - 1 do
    App.Console.AddLine(CompilerProcess.sl[i]);
    App.Log.Log('Build Succeeded');
    App.Console.AddLine('Build Succeeded');
    if FileExists(_FilePath + 'bin' + G2PathSep + ProjectName + '.exe') then
    begin
      ExeProcess.sl := TStringList.Create;
      ExeProcess.ProcOutput := TMemoryStream.Create;
      ExeProcess.Proc := TProcessUTF8.Create(nil);
      ExeProcess.Proc.Executable := _FilePath + 'bin' + G2PathSep + ProjectName + '.exe';
      ExeProcess.Proc.CurrentDirectory := _FilePath + 'bin' + G2PathSep;
      ExeProcess.Proc.CommandLine := ExeProcess.Proc.Executable;
      ExeProcess.Proc.Options := ExeProcess.Proc.Options + [poUsePipes];
      ExeProcess.Proc.ShowWindow := swoShowDefault;
      ExeProcess.ReadBytes := 0;
      ExeProcess.Proc.Execute;
      while True do
      begin
        ExeProcess.ProcOutput.SetSize(ExeProcess.ReadBytes + READ_BYTES);
        ExeProcess.NumBytes := ExeProcess.Proc.Output.Read((ExeProcess.ProcOutput.Memory + ExeProcess.ReadBytes)^, READ_BYTES);
        if ExeProcess.NumBytes > 0 then
        begin
          Inc(ExeProcess.ReadBytes, ExeProcess.NumBytes);
        end
        else
        Break;
      end;
      ExeProcess.Proc.WaitOnExit;
      ExeProcess.ProcOutput.SetSize(ExeProcess.ReadBytes);
      ExeProcess.sl.LoadFromStream(ExeProcess.ProcOutput);
      for i := 0 to ExeProcess.sl.Count - 1 do
      App.Console.AddLine(ExeProcess.sl[i]);
      ExeProcess.Proc.Free;
      ExeProcess.ProcOutput.Free;
      ExeProcess.sl.Free;
      //SysUtils.ExecuteProcess(UTF8ToSys(_FilePath + 'bin' + G2PathSep + ProjectName + '.exe'), '', []);
    end;
  end
  else
  begin
    for i := 0 to CompilerProcess.sl.Count - 2 do
    App.Console.AddLine(CompilerProcess.sl[i]);
    App.Log.Log('Build Failed');
    App.Console.AddLine('Build Failed');
  end;
  CompilerProcess.Proc.Free;
  CompilerProcess.ProcOutput.Free;
  CompilerProcess.sl.Free;
  //App.Log.Log(Deploy.Build(CompilerPath, ProjectPath));
  G2RemoveDir(_FilePath + 'build');
end;

procedure TProject.BuildHTML5;
  var CommandLine: String;
  procedure AddOption(const Option: String);
  begin
    CommandLine := CommandLine + ' ' + Option;
  end;
  type TOutputProcess = record
    sl: TStringList;
    ProcOutput: TMemoryStream;
    Proc: TProcessUTF8;
    ReadBytes, NumBytes: Integer;
  end;
  var CompilerProcess, ExeProcess: TOutputProcess;
  var cf: TCodeFile;
  var CompilerPath, ExePath, UnitPaths: String;
  var i: Integer;
  const READ_BYTES = 2048;
begin
  if not _Open then Exit;
  UpdateSettings;
  App.Log.Log('Build for HTML5 Started');
  App.Console.AddLine('Build for HTML5 Started');
  CompilerPath := g2.AppPath + 'smsc' + G2PathSep + 'smsc.exe';
  if not DirectoryExists(_FilePath + 'build') then
  CreateDir(_FilePath + 'build');
  if not DirectoryExists(_FilePath + 'build' + G2PathSep + 'obj') then
  CreateDir(_FilePath + 'build' + G2PathSep + 'obj');
  if not DirectoryExists(_FilePath + 'build' + G2PathSep + 'data') then
  CreateDir(_FilePath + 'build' + G2PathSep + 'data');
  if not DirectoryExists(_FilePath + 'bin') then
  CreateDir(_FilePath + 'bin');
  cf.Initialize;
  cf.SetCode(G2StrReplace(_ProjectCode, '{#project_name#}', GetProjectName));
  cf.Save(_FilePath + 'build' + G2PathSep + 'data' + G2PathSep + _FileName);
  cf.Finalize;
  CommandLine := ' "' + _FilePath + 'build' + G2PathSep + 'data' + G2PathSep + _FileName + '"';
  AddOption('-output-name=index.html');
  UnitPaths := '"' + g2.AppPath + '..\..\source\g2web"';
  for i := 0 to High(_ProjectIncludeSource) do
  UnitPaths += ';"' + G2StrReplace(_ProjectIncludeSource[i], '$(project_root)', _FilePath) + '"';
  AddOption('-unit-path=' + UnitPaths);
  AddOption('-verbosity=verbose');
  AddOption('-hints=normal');
  AddOption('-compress-css=yes');
  AddOption('-inline=yes');
  AddOption('-optimization=yes');
  AddOption('-emit-manifest=no');
  AddOption('-emit-chrome-manifest=no');
  CompilerProcess.sl := TStringList.Create;
  CompilerProcess.ProcOutput := TMemoryStream.Create;
  CompilerProcess.Proc := TProcessUTF8.Create(nil);
  CompilerProcess.Proc.Executable := CompilerPath;
  CompilerProcess.Proc.CommandLine := CompilerProcess.Proc.Executable + CommandLine;
  CompilerProcess.Proc.Options := CompilerProcess.Proc.Options + [poUsePipes];
  CompilerProcess.Proc.ShowWindow := swoHIDE;
  CompilerProcess.ReadBytes := 0;
  CompilerProcess.Proc.Execute;
  while True do
  begin
    CompilerProcess.ProcOutput.SetSize(CompilerProcess.ReadBytes + READ_BYTES);
    CompilerProcess.NumBytes := CompilerProcess.Proc.Output.Read((CompilerProcess.ProcOutput.Memory + CompilerProcess.ReadBytes)^, READ_BYTES);
    if CompilerProcess.NumBytes > 0 then
    begin
      Inc(CompilerProcess.ReadBytes, CompilerProcess.NumBytes);
    end
    else
    Break;
  end;
  CompilerProcess.Proc.WaitOnExit;
  CompilerProcess.ProcOutput.SetSize(CompilerProcess.ReadBytes);
  CompilerProcess.sl.LoadFromStream(CompilerProcess.ProcOutput);
  for i := 0 to CompilerProcess.sl.Count - 2 do
  App.Console.AddLine(CompilerProcess.sl[i]);
  if CompilerProcess.Proc.ExitStatus = 0 then
  begin
    App.Log.Log('Build Succeeded');
    App.Console.AddLine('Build Succeeded');
    try
      CopyFile(g2.AppPath + 'http' + G2PathSep + 'start.jar', _FilePath + 'build' + G2PathSep + 'start.jar');
    except
      on e: Exception do
      begin
        App.Console.AddLine(e.Message);
      end;
    end;
    CommandLine := '-jar ' + _FilePath + 'build' + G2PathSep + 'start.jar';
    ExePath := _FilePath + 'build';
    try
      ShellExecute(
        0, nil, PChar('java'),
        PChar(CommandLine),
        PChar(ExePath), 0
      );
    except
      App.Console.AddLine('Failed to run HTML5 server.');
    end;
  end
  else
  begin
    App.Log.Log('Build Failed');
    App.Console.AddLine('Build Failed');
  end;
end;

procedure TProject.CreateLPR;
  var cf: TCodeFile;
  var sl: TStringList;
  var G2mpPath, Box2DPath, SpinePath, IncludePath: String;
  var StrArr: TG2StrArrA;
  var i: Integer;
begin
  G2mpPath := G2StrReplace(g2.AppPath, G2PathSepRev, G2PathSep);
  StrArr := G2StrExplode(G2mpPath, G2PathSep);
  G2mpPath := '';
  for i := 0 to High(StrArr) - 3 do
  G2mpPath += StrArr[i] + G2PathSep;
  G2mpPath += 'source';
  Box2DPath := G2mpPath + G2PathSep + 'box2d';
  SpinePath := G2mpPath + G2PathSep + 'spine';
  IncludePath := G2mpPath + ';' + Box2DPath + ';' + SpinePath;
  for i := 0 to High(_ProjectIncludeSource) do
  IncludePath += ';' + G2StrReplace(_ProjectIncludeSource[i], '$(project_root)', _FilePath);
  cf.Initialize;
  cf.SetCode(G2StrReplace(_ProjectCode, '{#project_name#}', GetProjectName));
  cf.Save(_FilePath + ProjectName + '.lpr');
  cf.Finalize;
  sl := TStringList.Create;
  sl.Add('<?xml version="1.0" encoding="UTF-8"?>');
  sl.Add('<CONFIG>');
  sl.Add('  <ProjectOptions>');
  sl.Add('    <Version Value="9"/>');
  sl.Add('    <PathDelim Value="\"/>');
  sl.Add('    <General>');
  sl.Add('      <Flags>');
  sl.Add('        <SaveClosedFiles Value="False"/>');
  sl.Add('        <SaveOnlyProjectUnits Value="True"/>');
  sl.Add('        <MainUnitHasCreateFormStatements Value="False"/>');
  sl.Add('        <MainUnitHasTitleStatement Value="False"/>');
  sl.Add('        <SaveJumpHistory Value="False"/>');
  sl.Add('        <SaveFoldState Value="False"/>');
  sl.Add('      </Flags>');
  sl.Add('      <MainUnit Value="0"/>');
  sl.Add('      <Title Value="' + ProjectName + '"/>');
  sl.Add('      <ResourceType Value="res"/>');
  sl.Add('      <UseXPManifest Value="True"/>');
  sl.Add('    </General>');
  sl.Add('    <i18n>');
  sl.Add('      <EnableI18N LFM="False"/>');
  sl.Add('    </i18n>');
  sl.Add('    <BuildModes Count="1" Active="Default">');
  sl.Add('      <Item1 Name="Default" Default="True"/>');
  sl.Add('    </BuildModes>');
  sl.Add('    <PublishOptions>');
  sl.Add('      <Version Value="2"/>');
  sl.Add('      <IncludeFileFilter Value="*.(pas|pp|inc|lfm|lpr|lrs|lpi|lpk|sh|xml)"/>');
  sl.Add('      <ExcludeFileFilter Value="*.(bak|ppu|o|so);*~;backup"/>');
  sl.Add('    </PublishOptions>');
  sl.Add('    <RunParams>');
  sl.Add('      <local>');
  sl.Add('        <FormatVersion Value="1"/>');
  sl.Add('      </local>');
  sl.Add('    </RunParams>');
  sl.Add('    <Units Count="1">');
  sl.Add('      <Unit0>');
  sl.Add('        <Filename Value="' + ProjectName + '.lpr"/>');
  sl.Add('        <IsPartOfProject Value="True"/>');
  sl.Add('        <Loaded Value="True"/>');
  sl.Add('      </Unit0>');
  sl.Add('    </Units>');
  sl.Add('  </ProjectOptions>');
  sl.Add('  <CompilerOptions>');
  sl.Add('    <Version Value="11"/>');
  sl.Add('    <PathDelim Value="\"/>');
  sl.Add('    <Target>');
  sl.Add('      <Filename Value="bin/' + ProjectName + '"/>');
  sl.Add('    </Target>');
  sl.Add('    <SearchPaths>');
  sl.Add('      <IncludeFiles Value="$(ProjOutDir)"/>');
  sl.Add('      <OtherUnitFiles Value="' + IncludePath + '\"/>');
  sl.Add('      <UnitOutputDirectory Value="lib\$(TargetCPU)-$(TargetOS)"/>');
  sl.Add('    </SearchPaths>');
  sl.Add('    <Linking>');
  sl.Add('      <Options>');
  sl.Add('        <Win32>');
  sl.Add('          <GraphicApplication Value="True"/>');
  sl.Add('        </Win32>');
  sl.Add('      </Options>');
  sl.Add('    </Linking>');
  sl.Add('  </CompilerOptions>');
  sl.Add('  <Debugging>');
  sl.Add('    <Exceptions Count="3">');
  sl.Add('      <Item1>');
  sl.Add('        <Name Value="EAbort"/>');
  sl.Add('      </Item1>');
  sl.Add('      <Item2>');
  sl.Add('        <Name Value="ECodetoolError"/>');
  sl.Add('      </Item2>');
  sl.Add('      <Item3>');
  sl.Add('        <Name Value="EFOpenError"/>');
  sl.Add('      </Item3>');
  sl.Add('    </Exceptions>');
  sl.Add('  </Debugging>');
  sl.Add('  <EditorMacros Count="0"/>');
  sl.Add('</CONFIG>');
  sl.SaveToFile(_FilePath + ProjectName + '.lpi');
  sl.Free;
end;

procedure TProject.UpdateSettings;
  var fd: AnsiString;
  var new_md5: TG2MD5;
  var g2ml: TG2ML;
  var Root, ProjSource, ProjInclude, ProjIncludeSource: PG2MLObject;
begin
  if not _Open then Exit;
  fd := App.LoadFile(GetProjectPath);
  new_md5 := G2MD5(fd);
  if (_md5 <> new_md5) then
  begin
    _ProjectIncludeSource := nil;
    g2ml := TG2ML.Create;
    Root := g2ml.Read(fd);
    ProjInclude := Root^.FindNode('include');
    if ProjInclude <> nil then
    begin
      ProjIncludeSource := ProjInclude^.FindNode('source');
      if (ProjIncludeSource <> nil)
      and (ProjIncludeSource^.DataType = dtString) then
      _ProjectIncludeSource := G2StrExplode(ProjIncludeSource^.AsString, ';');
    end;
    _ProjectCode := fd;
    g2ml.FreeObject(Root);
    g2ml.Free;
  end;
end;
//TProject END

//TParticleEmitter BEGIN
constructor TParticleEmitter.Create;
begin
  inherited Create;
  Name := '';
  Emitters.Clear;
  ParentEffect := nil;
  ParentEmitter := nil;
  Texture := nil;
  TimeStart := 0;
  TimeEnd := 1;
  Orientation := 0;
  Shape := es_radial;
  ShapeRadius0 := 0;
  ShapeRadius1 := 1;
  ShapeAngle := G2HalfPi;
  ShapeWidth0 := 0;
  ShapeWidth1 := 1;
  ShapeHeight0 := 0;
  ShapeHeight1 := 1;
  Emission := 1;
  Layer := 0;
  Infinite := False;
  ParticleCenterX := 0.5;
  ParticleCenterY := 0.5;
  ParticleWidthMin := 1;
  ParticleWidthMax := 1;
  ParticleHeightMin := 1;
  ParticleHeightMax := 1;
  ParticleScaleMin := 1;
  ParticleScaleMax := 1;
  ParticleDurationMin := 1;
  ParticleDurationMax := 1;
  ParticleRotationMin := 0;
  ParticleRotationMax := 0;
  ParticleRotationLocal := True;
  ParticleOrientationMin := 0;
  ParticleOrientationMax := 0;
  ParticleVelocityMin := 0;
  ParticleVelocityMax := 1;
  ParticleColor0 := $ffffffff;
  ParticleColor1 := $ffffffff;
  ParticleBlend := bmNormal;
  Mods.Clear;
end;

destructor TParticleEmitter.Destroy;
  var i: Integer;
begin
  for i := 0 to Emitters.Count - 1 do
  Emitters[i].Free;
  Emitters.Clear;
  if Texture <> nil then
  begin
    if Texture.IsShared then Texture.RefDec else Texture.Free;
  end;
  inherited Destroy;
end;

function TParticleEmitter.IsSelected: Boolean;
begin
  Result := App.ParticleData.Selection = Self;
end;

function TParticleEmitter.IsOpen: Boolean;
begin
  Result := (ParentEffect <> nil) and ParentEffect.IsOpen;
end;

procedure TParticleEmitter.Save(const dm: TG2DataManager);
  var Image: TG2Image;
  var i: Integer;
begin
  dm.WriteStringA(Name);
  dm.WriteBool(Texture <> nil);
  if Texture <> nil then
  begin
    dm.WriteStringA(Texture.AssetName);
    Image := Texture.CreateImage;
    Image.Save(dm);
    Image.Free;
  end;
  dm.WriteFloat(TimeStart);
  dm.WriteFloat(TimeEnd);
  dm.WriteFloat(Orientation);
  dm.WriteBuffer(@Shape, SizeOf(Shape));
  dm.WriteFloat(ShapeRadius0);
  dm.WriteFloat(ShapeRadius1);
  dm.WriteFloat(ShapeAngle);
  dm.WriteFloat(ShapeWidth0);
  dm.WriteFloat(ShapeWidth1);
  dm.WriteFloat(ShapeHeight0);
  dm.WriteFloat(ShapeHeight1);
  dm.WriteIntS32(Emission);
  dm.WriteIntS32(Layer);
  dm.WriteBool(Infinite);
  dm.WriteFloat(ParticleCenterX);
  dm.WriteFloat(ParticleCenterY);
  dm.WriteFloat(ParticleWidthMin);
  dm.WriteFloat(ParticleWidthMax);
  dm.WriteFloat(ParticleHeightMin);
  dm.WriteFloat(ParticleHeightMax);
  dm.WriteFloat(ParticleScaleMin);
  dm.WriteFloat(ParticleScaleMax);
  dm.WriteFloat(ParticleDurationMin);
  dm.WriteFloat(ParticleDurationMax);
  dm.WriteFloat(ParticleRotationMin);
  dm.WriteFloat(ParticleRotationMax);
  dm.WriteBool(ParticleRotationLocal);
  dm.WriteFloat(ParticleOrientationMin);
  dm.WriteFloat(ParticleOrientationMax);
  dm.WriteFloat(ParticleVelocityMin);
  dm.WriteFloat(ParticleVelocityMax);
  dm.WriteColor(ParticleColor0);
  dm.WriteColor(ParticleColor1);
  dm.WriteBuffer(@ParticleBlend, SizeOf(ParticleBlend));
  dm.WriteIntS32(Mods.Count);
  for i := 0 to Mods.Count - 1 do
  begin
    dm.WriteStringA(Mods[i].GetGUID);
    Mods[i].Save(dm);
  end;
  dm.WriteIntS32(Emitters.Count);
  for i := 0 to Emitters.Count - 1 do
  Emitters[i].Save(dm);
end;

procedure TParticleEmitter.Load(const dm: TG2DataManager);
  var b: Boolean;
  var guid: AnsiString;
  var n, i, j: Integer;
  var pm: TParticleMod;
  var Emitter: TParticleEmitter;
  var TexName: AnsiString;
begin
  Name := dm.ReadStringA;
  b := dm.ReadBool;
  if b then
  begin
    Texture := TG2Texture2D.Create;
    TexName := dm.ReadStringA;
    Texture.Load(dm);
    Texture.AssetName := TexName;
    Texture.RefInc;
  end;
  TimeStart := dm.ReadFloat;
  TimeEnd := dm.ReadFloat;
  Orientation := dm.ReadFloat;
  dm.ReadBuffer(@Shape, SizeOf(Shape));
  ShapeRadius0 := dm.ReadFloat;
  ShapeRadius1 := dm.ReadFloat;
  ShapeAngle := dm.ReadFloat;
  ShapeWidth0 := dm.ReadFloat;
  ShapeWidth1 := dm.ReadFloat;
  ShapeHeight0 := dm.ReadFloat;
  ShapeHeight1 := dm.ReadFloat;
  Emission := dm.ReadIntS32;
  Layer := dm.ReadIntS32;
  Infinite := dm.ReadBool;
  ParticleCenterX := dm.ReadFloat;
  ParticleCenterY := dm.ReadFloat;
  ParticleWidthMin := dm.ReadFloat;
  ParticleWidthMax := dm.ReadFloat;
  ParticleHeightMin := dm.ReadFloat;
  ParticleHeightMax := dm.ReadFloat;
  ParticleScaleMin := dm.ReadFloat;
  ParticleScaleMax := dm.ReadFloat;
  ParticleDurationMin := dm.ReadFloat;
  ParticleDurationMax := dm.ReadFloat;
  ParticleRotationMin := dm.ReadFloat;
  ParticleRotationMax := dm.ReadFloat;
  ParticleRotationLocal := dm.ReadBool;
  ParticleOrientationMin := dm.ReadFloat;
  ParticleOrientationMax := dm.ReadFloat;
  ParticleVelocityMin := dm.ReadFloat;
  ParticleVelocityMax := dm.ReadFloat;
  ParticleColor0 := dm.ReadColor;
  ParticleColor1 := dm.ReadColor;
  dm.ReadBuffer(@ParticleBlend, SizeOf(ParticleBlend));
  n := dm.ReadIntS32;
  Mods.Clear;
  for i := 0 to n - 1 do
  begin
    guid := dm.ReadStringA;
    for j := 0 to App.ParticleData.Mods.Count - 1 do
    if guid = App.ParticleData.Mods[j].GetGUID then
    begin
      pm := App.ParticleData.Mods[j].Create;
      pm.Load(dm);
      Mods.Add(pm);
    end;
  end;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  begin
    Emitter := TParticleEmitter.Create;
    Emitter.ParentEffect := ParentEffect;
    Emitter.ParentEmitter := Self;
    Emitter.Load(dm);
    Emitters.Add(Emitter);
  end;
end;
//TParticleEmitter END

//TParticleEffect BEGIN
constructor TParticleEffect.Create;
begin
  inherited Create;
  Name := '';
  Emitters.Clear;
  Scale := 1;
end;

destructor TParticleEffect.Destroy;
  var i: Integer;
begin
  for i := 0 to Emitters.Count - 1 do
  Emitters[i].Free;
  Emitters.Clear;
  inherited Destroy;
end;

function TParticleEffect.IsSelected: Boolean;
begin
  Result := App.ParticleData.Selection = Self;
end;

function TParticleEffect.IsOpen: Boolean;
begin
  Result := (
    (App.ParticleData.Selection <> nil)
    and (
      (App.ParticleData.Selection = Self)
      or (
        (App.ParticleData.Selection is TParticleEmitter)
        and (TParticleEmitter(App.ParticleData.Selection).ParentEffect = Self)
      )
    )
  );
end;

procedure TParticleEffect.Save(const dm: TG2DataManager);
  var i: Integer;
  var Emitter: TParticleEmitter;
begin
  dm.WriteStringA(Name);
  dm.WriteFloat(Scale);
  dm.WriteIntS32(Emitters.Count);
  for i := 0 to Emitters.Count - 1 do
  begin
    Emitter := Emitters[i];
    Emitter.Save(dm);
  end;
end;

procedure TParticleEffect.Load(const dm: TG2DataManager);
  var n, i: Integer;
  var Emitter: TParticleEmitter;
begin
  Name := dm.ReadStringA;
  Scale := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  begin
    Emitter := TParticleEmitter.Create;
    Emitter.ParentEffect := Self;
    Emitter.ParentEmitter := nil;
    Emitter.Load(dm);
    Emitters.Add(Emitter);
  end;
end;
//TParticleEffect END

//TWorkspaceParticleMod BEGIN
procedure TWorkspaceParticleMod.OnInitialize;
begin
  inherited OnInitialize;
  _MdInClose := False;
  _OnClose := nil;
  PaddingBottom := 4;
end;

procedure TWorkspaceParticleMod.OnAdjust;
  var r: TG2Rect;
begin
  inherited OnAdjust;
  r := Frame;
  r.r := r.r - _BorderSize - 4;
  r.t := r.t + _BorderSize + 4;
  r.l := r.r - _HeaderSize + 8;
  r.b := r.t + _HeaderSize - 8;
  _FrameClose := r;
end;

procedure TWorkspaceParticleMod.OnRender;
  var c: TG2Color;
begin
  inherited OnRender;
  if (App.UI.Overlay = nil)
  and (_FrameClose.Contains(g2.MousePos)) then
  c := App.UI.GetColorSecondary(0.9)
  else
  c := App.UI.GetColorPrimary(0.8);
  g2.PrimBegin(ptTriangles, bmNormal);
  App.UI.DrawCross(_FrameClose, c);
  g2.PrimEnd;
end;

procedure TWorkspaceParticleMod.OnMouseDown(const Button, x, y: Integer);
begin
  inherited OnMouseDown(Button, x, y);
  if (Button = G2MB_Left)
  and _FrameClose.Contains(x, y) then
  _MdInClose := True;
end;

procedure TWorkspaceParticleMod.OnMouseUp(const Button, x, y: Integer);
begin
  inherited OnMouseUp(Button, x, y);
  if (Button = G2MB_Left)
  and _FrameClose.Contains(x, y) then
  begin
    if Assigned(_OnClose) then App.UI.MsgCallProc(_OnClose);
  end;
end;
//TWorkspaceParticleMod END

//TParticleMod BEGIN
class function TParticleMod.GetGUID: AnsiString;
begin
  Result := '28ad0411-cecf-4b6f-9959-ee462f40541c';
end;

class function TParticleMod.GetName: AnsiString;
begin
  Result := 'Mod';
end;

constructor TParticleMod.Create;
begin
  inherited Create;
  Group := TWorkspaceParticleMod.Create;
  Group.Caption := GetName;
  Group.OnClose := @OnModClose;
end;

destructor TParticleMod.Destroy;
begin
  Group.Free;
  inherited Destroy;
end;

procedure TParticleMod.OnModClose;
  var Emitter: TParticleEmitter;
  var i: Integer;
begin
  if (App.ParticleData.Selection <> nil)
  and (App.ParticleData.Selection is TParticleEmitter) then
  begin
    Emitter := TParticleEmitter(App.ParticleData.Selection);
    Emitter.Mods.Remove(Self);
    for i := 0 to TUIWorkspaceParticles2DEditor.WorkspaceList.Count - 1 do
    TUIWorkspaceParticles2DEditor.WorkspaceList[i].ModsShow;
    Free;
  end;
end;

procedure TParticleMod.OnParticleCreate(const Particle: TParticle);
begin

end;

procedure TParticleMod.OnParticleDestroy(const Particle: TParticle);
begin

end;

procedure TParticleMod.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
begin

end;

procedure TParticleMod.OnEmitterUpdate(const Emitter: TEmitter; const t: TG2Float);
begin

end;

procedure TParticleMod.Save(const dm: TG2DataManager);
begin

end;

procedure TParticleMod.Load(const dm: TG2DataManager);
begin

end;

procedure TParticleMod.WriteG2ML(const g2ml: TG2MLWriter);
begin

end;
//TParticleMod END

//TParticleModOpacityGraph BEGIN
constructor TParticleModOpacityGraph.Create;
begin
  inherited Create;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := 0;
  Graph.Parent := Group.Client;
end;

class function TParticleModOpacityGraph.GetGUID: AnsiString;
begin
  Result := 'df171382-9708-47aa-84e6-728073083b92';
end;

class function TParticleModOpacityGraph.GetName: AnsiString;
begin
  Result := 'Opacity Graph';
end;

destructor TParticleModOpacityGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModOpacityGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.Color.a := Round(Particle.ColorInit.a * p.y);
end;

procedure TParticleModOpacityGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModOpacityGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModOpacityGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  Graph.WriteG2ML(g2ml);
end;

//TParticleModOpacityGraph END

//TParticleModScaleGraph BEGIN
procedure TParticleModScaleGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModScaleGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 5;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := 0;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 1);
end;

class function TParticleModScaleGraph.GetGUID: AnsiString;
begin
  Result := 'cc60e497-dce8-4682-81ef-cc0b1865ff8c';
end;

class function TParticleModScaleGraph.GetName: AnsiString;
begin
  Result := 'Scale Graph';
end;

destructor TParticleModScaleGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModScaleGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.Scale := Particle.ScaleInit * p.y;
end;

procedure TParticleModScaleGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModScaleGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModScaleGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModScaleGraph END

//TParticleModColorGraph BEGIN
constructor TParticleModColorGraph.Create;
begin
  inherited Create;
  Graph := TUIWorkspaceCustomColorGraph.Create;
  Graph.Parent := Group.Client;
end;

class function TParticleModColorGraph.GetGUID: AnsiString;
begin
  Result := 'b680c31b-b593-4bdd-9846-632b42d47c0c';
end;

class function TParticleModColorGraph.GetName: AnsiString;
begin
  Result := 'Color Graph';
end;

destructor TParticleModColorGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModColorGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var c: TG2Color;
  var t0, td: TG2Float;
begin
  n := Graph.ColorCount - 1;
  for i := 0 to Graph.ColorCount - 1 do
  if Graph.Colors[i]^.Time >= t then
  begin
    n := i - 1;
    Break;
  end;
  if n = -1 then
  c := Graph.Colors[0]^.Color
  else if n = Graph.ColorCount - 1 then
  c := Graph.Colors[Graph.ColorCount - 1]^.Color
  else
  begin
    td := Graph.Colors[n + 1]^.Time - Graph.Colors[n]^.Time;
    t0 := t - Graph.Colors[n]^.Time;
    c := G2LerpColor(Graph.Colors[n]^.Color, Graph.Colors[n + 1]^.Color, t0 / td);
  end;
  Particle.Color.r := Round(Particle.ColorInit.r * G2Rcp255 * c.r);
  Particle.Color.g := Round(Particle.ColorInit.g * G2Rcp255 * c.g);
  Particle.Color.b := Round(Particle.ColorInit.b * G2Rcp255 * c.b);
end;

procedure TParticleModColorGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteIntS32(Graph.ColorCount);
  for i := 0 to Graph.ColorCount - 1 do
  begin
    dm.WriteColor(Graph.Colors[i]^.Color);
    dm.WriteFloat(Graph.Colors[i]^.Time);
  end;
end;

procedure TParticleModColorGraph.Load(const dm: TG2DataManager);
  var i, n: Integer;
  var t: TG2Float;
  var c: TG2Color;
begin
  Graph.Clear;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  begin
    c := dm.ReadColor;
    t := dm.ReadFloat;
    Graph.AddColor(c, t);
  end;
end;

procedure TParticleModColorGraph.WriteG2ML(const g2ml: TG2MLWriter);
  var i: Integer;
begin
  for i := 0 to Graph.ColorCount - 1 do
  begin
    g2ml.NodeOpen('color_section');
    g2ml.NodeValue('color', IntToHex(TG2IntU32(Graph.Colors[i]^.Color) and $ffffff, 6));
    g2ml.NodeValue('position', Graph.Colors[i]^.Time);
    g2ml.NodeClose;
  end;
end;
//TParticleModColorGraph END

//TParticleModWidthGraph BEIGN
procedure TParticleModWidthGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModWidthGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 5;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := 0;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 1);
end;

class function TParticleModWidthGraph.GetGUID: AnsiString;
begin
  Result := '4b3cbb53-42b9-40f1-a639-5546a2193f78';
end;

class function TParticleModWidthGraph.GetName: AnsiString;
begin
  Result := 'Width Graph';
end;

destructor TParticleModWidthGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModWidthGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.Width := Particle.WidthInit * p.y;
end;

procedure TParticleModWidthGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModWidthGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModWidthGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModWidthGraph END

//TParticleModHeightGraph BEIGN
procedure TParticleModHeightGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModHeightGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 5;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := 0;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 1);
end;

class function TParticleModHeightGraph.GetGUID: AnsiString;
begin
  Result := '563235a5-0dc2-4dcb-9710-6127b7138123';
end;

class function TParticleModHeightGraph.GetName: AnsiString;
begin
  Result := 'Height Graph';
end;

destructor TParticleModHeightGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModHeightGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.Height := Particle.HeightInit * p.y;
end;

procedure TParticleModHeightGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModHeightGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModHeightGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModHeightGraph END

//TParticleModRotationGraph BEGIN
procedure TParticleModRotationGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModRotationGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 3;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 0);
end;

class function TParticleModRotationGraph.GetGUID: AnsiString;
begin
  Result := '69d28969-766a-4365-a560-d8f116cd4e1a';
end;

class function TParticleModRotationGraph.GetName: AnsiString;
begin
  Result := 'Rotation Graph';
end;

destructor TParticleModRotationGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModRotationGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.Rotation := Particle.RotationInit + p.y;
end;

procedure TParticleModRotationGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModRotationGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModRotationGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModRotationGraph END

//TParticleModOrientationGraph BEGIN
procedure TParticleModOrientationGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModOrientationGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 3;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 0);
end;

class function TParticleModOrientationGraph.GetGUID: AnsiString;
begin
  Result := 'fa779732-c3ec-4f79-9370-975547d787bb';
end;

class function TParticleModOrientationGraph.GetName: AnsiString;
begin
  Result := 'Orientation Graph';
end;

destructor TParticleModOrientationGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModOrientationGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.xf.r.Angle := Particle.OrientationInit + p.y;
end;

procedure TParticleModOrientationGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModOrientationGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModOrientationGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModOrientationGraph END

//TParticleModVelocityGraph BEGIN
procedure TParticleModVelocityGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModVelocityGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 3;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 1);
end;

class function TParticleModVelocityGraph.GetGUID: AnsiString;
begin
  Result := 'd75e2d11-68ab-494d-8d05-151fd4f0d69f';
end;

class function TParticleModVelocityGraph.GetName: AnsiString;
begin
  Result := 'Velocity Graph';
end;

destructor TParticleModVelocityGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModVelocityGraph.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p: TG2Vec2;
  var t0, td: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  Particle.Velocity := Particle.VelocityInit * p.y;
end;

procedure TParticleModVelocityGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModVelocityGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModVelocityGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModVelocityGraph END

//TParticleModAcceleration BEGIN
procedure TParticleModAcceleration.OnGraphScaleChange;
begin
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleModAcceleration.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(5);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Increment := 0.1;
  GraphScale.Number := 3;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  with sm.Subset[2].Text('Direction') do
  begin
    Color := $ffffffff;
    PaddingLeft := 16;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  Direction := sm.Subset[3].NumberFloat;
  Direction.NumberMin := -G2TwoPi;
  Direction.NumberMax := G2TwoPi;
  Direction.Increment := G2TwoPi / 50;
  Direction.Number := 0;
  Direction.Width := 64;
  Local := sm.Subset[4].CheckBox('Local');
  Local.Checked := False;
  Local.PaddingLeft := 16;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 0);
end;

class function TParticleModAcceleration.GetGUID: AnsiString;
begin
  Result := '9eb3a4ef-450a-403a-8515-3862e9991a77';
end;

class function TParticleModAcceleration.GetName: AnsiString;
begin
  Result := 'Acceleration';
end;

destructor TParticleModAcceleration.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleModAcceleration.OnParticleUpdate(const Particle: TParticle; const t: TG2Float);
  var i, n: Integer;
  var p, v, a: TG2Vec2;
  var r: TG2Rotation2;
  var t0, td, vl: TG2Float;
begin
  n := Graph.PointCount - 1;
  for i := 0 to Graph.PointCount - 1 do
  if Graph.Points[i].x >= t then
  begin
    n := i - 1;
    if n < 0 then n := 0;
    Break;
  end;
  if n = Graph.PointCount - 1 then
  p := Graph.Points[Graph.PointCount - 1]
  else
  begin
    td := Graph.Points[n + 1].x - Graph.Points[n].x;
    t0 := t - Graph.Points[n].x;
    p := G2LerpVec2(Graph.Points[n], Graph.Points[n + 1], t0 / td);
  end;
  r := G2Rotation2(Direction.Number);
  if Local.Checked then G2Rotation2Mul(@r, @r, @Particle.xf.r);
  a := r.AxisX * (p.y * g2.DeltaTimeSec);
  v := Particle.xf.r.AxisX * Particle.Velocity;
  v := v + a;
  vl := v.Len;
  Particle.Velocity := vl;
  if Abs(vl) > G2EPS then
  Particle.xf.r.AxisX := v.Norm;
end;

procedure TParticleModAcceleration.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(Direction.Number);
  dm.WriteFloat(GraphScale.Number);
  dm.WriteBool(Local.Checked);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleModAcceleration.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Direction.Number := dm.ReadFloat;
  GraphScale.Number := dm.ReadFloat;
  Local.Checked := dm.ReadBool;
  Graph.Clear;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleModAcceleration.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('direction', Direction.Number);
  g2ml.NodeValue('local', Local.Checked);
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleModAcceleration END

//TParticleEmitterModOrientationGraph BEGIN
procedure TParticleEmitterModOrientationGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleEmitterModOrientationGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 3;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := -GraphScale.Number;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 0);
end;

class function TParticleEmitterModOrientationGraph.GetGUID: AnsiString;
begin
  Result := '5b84cb78-4021-49be-9764-a9a7a5e09af8';
end;

class function TParticleEmitterModOrientationGraph.GetName: AnsiString;
begin
  Result := 'Emitter Orientation Graph';
end;

destructor TParticleEmitterModOrientationGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleEmitterModOrientationGraph.OnEmitterUpdate(const Emitter: TEmitter; const t: TG2Float);
  var d: TG2Float;
begin
  d := Graph.GetYAt(t);
  Emitter.Orientation := Emitter.Data.Orientation + d;
end;

procedure TParticleEmitterModOrientationGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleEmitterModOrientationGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleEmitterModOrientationGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleEmitterModOrientationGraph END

//TParticleEmitterModScaleGraph BEGIN
procedure TParticleEmitterModScaleGraph.OnGraphScaleChange;
begin
  Graph.ScaleYMax := GraphScale.Number;
end;

constructor TParticleEmitterModScaleGraph.Create;
  var sm: TUIWorkspaceFixedSplitterMulti;
begin
  inherited Create;
  sm := Group.Client.SplitterM(2);
  sm.PaddingLeft := 4;
  sm.PaddingTop := 4;
  sm.EqualSized := False;
  with sm.Subset[0].Text('Graph Scale') do
  begin
    Color := $ffffffff;
    PaddingRight := 8;
    Align := [caMiddle];
  end;
  GraphScale := sm.Subset[1].NumberFloat;
  GraphScale.NumberMin := 1;
  GraphScale.NumberMax := 100;
  GraphScale.Number := 5;
  GraphScale.Width := 64;
  GraphScale.OnChange := @OnGraphScaleChange;
  Graph := TUIWorkspaceCustomGraph.Create;
  Graph.ScaleYMin := 0;
  Graph.ScaleYMax := GraphScale.Number;
  Graph.Parent := Group.Client;
  Graph.Points[0] := G2Vec2(0, 1);
end;

class function TParticleEmitterModScaleGraph.GetGUID: AnsiString;
begin
  Result := 'a0156854-2d47-4d3b-8fc2-b127a9b6cddf';
end;

class function TParticleEmitterModScaleGraph.GetName: AnsiString;
begin
  Result := 'Emitter Scale Graph';
end;

destructor TParticleEmitterModScaleGraph.Destroy;
begin
  inherited Destroy;
end;

procedure TParticleEmitterModScaleGraph.OnEmitterUpdate(const Emitter: TEmitter; const t: TG2Float);
  var d: TG2Float;
begin
  d := Graph.GetYAt(t);
  Emitter.Width0 := Emitter.Data.ShapeWidth0 * d;
  Emitter.Width1 := Emitter.Data.ShapeWidth1 * d;
  Emitter.Height0 := Emitter.Data.ShapeHeight0 * d;
  Emitter.Height1 := Emitter.Data.ShapeHeight1 * d;
  Emitter.Radius0 := Emitter.Data.ShapeRadius0 * d;
  Emitter.Radius1 := Emitter.Data.ShapeRadius1 * d;
end;

procedure TParticleEmitterModScaleGraph.Save(const dm: TG2DataManager);
  var i: Integer;
begin
  dm.WriteFloat(GraphScale.Number);
  dm.WriteIntS32(Graph.PointCount);
  for i := 0 to Graph.PointCount - 1 do
  dm.WriteVec2(Graph.Points[i]);
end;

procedure TParticleEmitterModScaleGraph.Load(const dm: TG2DataManager);
  var n, i: Integer;
begin
  Graph.Clear;
  GraphScale.Number := dm.ReadFloat;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  Graph.AddPoint(dm.ReadVec2);
end;

procedure TParticleEmitterModScaleGraph.WriteG2ML(const g2ml: TG2MLWriter);
begin
  g2ml.NodeValue('graph_scale', GraphScale.Number);
  Graph.WriteG2ML(g2ml);
end;
//TParticleEmitterModScaleGraph END

//TParticlePlayback BEGIN
function TParticlePlayback.FindLayer(const Index: Integer): TParticleLayer;
  var i, n: Integer;
begin
  n := 0;
  for i := 0 to Layers.Count - 1 do
  begin
    if TParticleLayer(Layers[i]).Index = Index then
    begin
      Result := TParticleLayer(Layers[i]);
      Exit;
    end
    else if TParticleLayer(Layers[i]).Index < Index then n := i + 1;
  end;
  Result := TParticleLayer.Create;
  Result.Index := Index;
  Result.Ref := 0;
  Layers.Insert(n, Result);
end;

function TParticlePlayback.CreateEmitter(const Data: TParticleEmitter; const Parent: TParticle): TEmitter;
begin
  Result := TEmitter.Create;
  Result.Data := Data;
  Result.Parent := Parent;
  Result.DurationTotal := Data.TimeEnd - Data.TimeStart;
  Result.Duration := Result.DurationTotal;
  Result.Delay := Data.TimeStart;
  Result.ParticlesToEmitt := Data.Emission;
  Result.Orientation := Data.Orientation;
  Result.Radius0 := Data.ShapeRadius0;
  Result.Radius1 := Data.ShapeRadius1;
  Result.Width0 := Data.ShapeWidth0;
  Result.Width1 := Data.ShapeWidth1;
  Result.Height0 := Data.ShapeHeight0;
  Result.Height1 := Data.ShapeHeight1;
  Emitters.Add(Result);
  Inc(EmittersAlive);
end;

constructor TParticlePlayback.Create;
begin
  inherited Create;
end;

destructor TParticlePlayback.Destroy;
begin
  if Playing then Stop;
  inherited Destroy;
end;

procedure TParticlePlayback.Start;
  var i: Integer;
  var Effect: TParticleEffect;
begin
  Effect := App.ParticleData.CurrentEffect;
  if _Playing or (Effect = nil) then Exit;
  EmittersAlive := 0;
  ParticlesAlive := 0;
  _Playing := True;
  _Time := 0;
  if App.ParticleData.Selection is TParticleEmitter then
  CreateEmitter(TParticleEmitter(App.ParticleData.Selection))
  else
  begin
    for i := 0 to Effect.Emitters.Count - 1 do
    CreateEmitter(Effect.Emitters[i]);
  end;
end;

procedure TParticlePlayback.Stop;
  var i, j: Integer;
begin
  if not _Playing then Exit;
  _Playing := False;
  for i := 0 to Emitters.Count - 1 do
  TEmitter(Emitters[i]).Free;
  Emitters.Clear;
  for i := 0 to Layers.Count - 1 do
  begin
    for j := 0 to TParticleLayer(Layers[i]).Particles.Count - 1 do
    TParticle(TParticleLayer(Layers[i]).Particles[j]).Free;
    TParticleLayer(Layers[i]).Free;
  end;
  Layers.Clear;
  EmittersAlive := 0;
  ParticlesAlive := 0;
end;

procedure TParticlePlayback.Update;
  var dt: TG2Float;
  procedure ProcessEmitter(const Emitter: TEmitter);
    var xf, pxf: TG2Transform2;
    var t, aw, ah, at, rn: TG2Float;
    var i, j, ec: Integer;
    var p: TParticle;
    var v0: TG2Vec2;
    var r0: TG2Rotation2;
  begin
    if Emitter.DurationTotal <= 0 then
    begin
      Emitters.Remove(Emitter);
      Emitter.Free;
      Dec(EmittersAlive);
      Exit;
    end;
    if Emitter.Parent = nil then
    xf := G2Transform2
    else
    xf := Emitter.Parent.xf;
    if Emitter.Delay > 0 then
    begin
      Emitter.Delay -= dt;
      if Emitter.Delay < 0 then Emitter.Duration -= Emitter.Delay;
      if Emitter.Delay > 0 then Exit;
    end
    else
    Emitter.Duration -= dt;
    if Emitter.Data.Infinite
    and (Emitter.Duration <= 0) then
    begin
      Emitter.Duration := Emitter.DurationTotal + Emitter.Duration;
      Emitter.ParticlesToEmitt := Emitter.ParticlesToEmitt + Emitter.Data.Emission;
    end;
    t := 1 - (Emitter.Duration / Emitter.DurationTotal);
    if t < 0 then Exit
    else if (t > 1) then
    begin
      if (Emitter.ParticlesToEmitt > 0) then
      ec := Emitter.ParticlesToEmitt
      else
      begin
        Emitters.Remove(Emitter);
        Emitter.Free;
        Dec(EmittersAlive);
        Exit;
      end;
    end
    else
    ec := Emitter.ParticlesToEmitt - (Emitter.Data.Emission - Round(Emitter.Data.Emission * t));
    if ec <= 0 then Exit;
    if ec > Emitter.ParticlesToEmitt then ec := Emitter.ParticlesToEmitt;
    Emitter.ParticlesToEmitt := Emitter.ParticlesToEmitt - ec;
    for i := 0 to ec - 1 do
    begin
      p := TParticle.Create;
      p.xf := G2Transform2(G2Vec2, G2Rotation2(Emitter.Data.ParticleOrientationMin + Random * (Emitter.Data.ParticleOrientationMax - Emitter.Data.ParticleOrientationMin)));
      p.DurationTotal := Emitter.Data.ParticleDurationMin + Random * (Emitter.Data.ParticleDurationMax - Emitter.Data.ParticleDurationMin);
      p.Duration := p.DurationTotal;
      p.CenterX := Emitter.Data.ParticleCenterX;
      p.CenterY := Emitter.Data.ParticleCenterY;
      p.WidthInit := Emitter.Data.ParticleWidthMin + Random * (Emitter.Data.ParticleWidthMax - Emitter.Data.ParticleWidthMin);
      p.Width := p.WidthInit;
      p.HeightInit := Emitter.Data.ParticleHeightMin + Random * (Emitter.Data.ParticleHeightMax - Emitter.Data.ParticleHeightMin);
      p.Height := p.HeightInit;
      p.ScaleInit := Emitter.Data.ParticleScaleMin + Random * (Emitter.Data.ParticleScaleMax - Emitter.Data.ParticleScaleMin);
      p.Scale := p.ScaleInit;
      p.RotationLocal := Emitter.Data.ParticleRotationLocal;
      p.RotationInit := Emitter.Data.ParticleRotationMin + Random * (Emitter.Data.ParticleRotationMax - Emitter.Data.ParticleRotationMin);
      p.Rotation := p.RotationInit;
      p.VelocityInit := Emitter.Data.ParticleVelocityMin + Random * (Emitter.Data.ParticleVelocityMax - Emitter.Data.ParticleVelocityMin);
      p.Velocity := p.VelocityInit;
      p.ColorInit := G2LerpColor(Emitter.Data.ParticleColor0, Emitter.Data.ParticleColor1, Random);
      p.Color := p.ColorInit;
      p.BlendMode := Emitter.Data.ParticleBlend;
      p.Data := Emitter.Data;
      case Emitter.Data.Shape of
        es_radial:
        begin
          v0 := G2Vec2(G2LerpFloat(Emitter.Radius0, Emitter.Radius1, Random), 0);
          r0 := G2Rotation2(Emitter.Data.ShapeAngle * Random - Emitter.Data.ShapeAngle * 0.5 + Emitter.Orientation);
          v0 := r0.Transform(v0);
          pxf.p := v0;
          pxf.r := r0;
        end;
        es_rectangle:
        begin
          aw := Emitter.Width1 * (Emitter.Height1 - Emitter.Height0);
          if aw < 0.01 then aw := 0.01;
          ah := Emitter.Height0 * (Emitter.Width1 - Emitter.Width0);
          if ah < 0.01 then ah := 0.01;
          at := aw + ah;
          rn := Random * at;
          if rn <= aw * 0.5 then
          begin
            v0.x := G2LerpFloat(-Emitter.Width1 * 0.5, Emitter.Width1 * 0.5, Random);
            v0.y := G2LerpFloat(-Emitter.Height1 * 0.5, -Emitter.Height0 * 0.5, Random);
          end
          else if rn <= aw then
          begin
            v0.x := G2LerpFloat(-Emitter.Width1 * 0.5, Emitter.Width1 * 0.5, Random);
            v0.y := G2LerpFloat(Emitter.Height0 * 0.5, Emitter.Height1 * 0.5, Random);
          end
          else if rn <= aw + ah * 0.5 then
          begin
            v0.x := G2LerpFloat(-Emitter.Width1 * 0.5, -Emitter.Width0 * 0.5, Random);
            v0.y := G2LerpFloat(-Emitter.Height0 * 0.5, Emitter.Height0 * 0.5, Random);
          end
          else if rn <= at then
          begin
            v0.x := G2LerpFloat(Emitter.Width0 * 0.5, Emitter.Width1 * 0.5, Random);
            v0.y := G2LerpFloat(-Emitter.Height0 * 0.5, Emitter.Height0 * 0.5, Random);
          end;
          r0 := G2Rotation2(Emitter.Orientation);
          v0 := r0.Transform(v0);
          pxf.p := v0;
          pxf.r := r0;
        end;
      end;
      G2Transform2Mul(@p.xf, @pxf, @p.xf);
      G2Transform2Mul(@p.xf, @p.xf, @xf);
      p.OrientationInit := p.xf.r.Angle;
      for j := 0 to Emitter.Data.Emitters.Count - 1 do
      CreateEmitter(Emitter.Data.Emitters[j], p);
      p.Layer := FindLayer(p.Data.Layer);
      Inc(p.Layer.Ref);
      p.Layer.Particles.Add(p);
      for j := 0 to Emitter.Data.Mods.Count - 1 do
      Emitter.Data.Mods[j].OnParticleCreate(p);
      Inc(ParticlesAlive);
    end;
    for i := 0 to Emitter.Data.Mods.Count - 1 do
    Emitter.Data.Mods[i].OnEmitterUpdate(Emitter, t);
  end;
  procedure ProcessParticle(const Particle: TParticle);
    var i: Integer;
    var e: TEmitter;
    var t: TG2Float;
  begin
    Particle.Duration -= dt;
    if Particle.Duration <= 0 then
    begin
      for i := 0 to Particle.Data.Mods.Count - 1 do
      Particle.Data.Mods[i].OnParticleDestroy(Particle);
      Particle.Layer.Particles.Remove(Particle);
      Dec(Particle.Layer.Ref);
      if Particle.Layer.Ref <= 0 then
      begin
        Layers.Remove(Particle.Layer);
        Particle.Layer.Free;
      end;
      for i := Emitters.Count - 1 downto 0 do
      begin
        e := TEmitter(Emitters[i]);
        if e.Parent = Particle then
        begin
          e.Free;
          Emitters.Delete(i);
          Dec(EmittersAlive);
        end;
      end;
      Particle.Free;
      Dec(ParticlesAlive);
    end
    else
    begin
      t := 1 - (Particle.Duration / Particle.DurationTotal);
      for i := 0 to Particle.Data.Mods.Count - 1 do
      Particle.Data.Mods[i].OnParticleUpdate(Particle, t);
      Particle.xf.p := Particle.xf.p + Particle.xf.r.AxisX * Particle.Velocity * dt;
    end;
  end;
  var i, j: Integer;
begin
  if not _Playing then Exit;
  if (EmittersAlive = 0) and (ParticlesAlive = 0) then
  begin
    Stop;
    Start;
    Exit;
  end;
  dt := g2.DeltaTimeSec;
  _Time += dt;
  for i := Emitters.Count - 1 downto 0 do
  ProcessEmitter(TEmitter(Emitters[i]));
  for i := Layers.Count - 1 downto 0 do
  for j := TParticleLayer(Layers[i]).Particles.Count - 1 downto 0 do
  ProcessParticle(TParticle(TParticleLayer(Layers[i]).Particles[j]));
end;

procedure TParticlePlayback.Render(const Display: TG2Display2D);
  procedure RenderParticle(const Particle: TParticle);
    var i, j: Integer;
    var v0, v1, v2, v3: TG2Vec2;
    var px0, px1, py0, py1, a: TG2Float;
    var xf: TG2Transform2;
  begin
    if Particle.Data.Texture = nil then Exit;
    if Particle.Data.ParticleRotationLocal then
    begin
      xf := Particle.xf;
      a := xf.r.Angle;
      xf.r.Angle := a + Particle.Rotation;
    end
    else
    begin
      xf := G2Transform2(Particle.xf.p, G2Rotation2(Particle.Rotation));
    end;
    px0 := -(Particle.Width * Particle.Scale) * (Particle.CenterX);
    px1 := (Particle.Width * Particle.Scale) * (1 - Particle.CenterX);
    py0 := -(Particle.Height * Particle.Scale) * (Particle.CenterY);
    py1 := (Particle.Height * Particle.Scale) * (1 - Particle.CenterY);
    v0 := xf.Transform(G2Vec2(px0, py0)) * Particle.Data.ParentEffect.Scale;
    v1 := xf.Transform(G2Vec2(px1, py0)) * Particle.Data.ParentEffect.Scale;
    v2 := xf.Transform(G2Vec2(px0, py1)) * Particle.Data.ParentEffect.Scale;
    v3 := xf.Transform(G2Vec2(px1, py1)) * Particle.Data.ParentEffect.Scale;
    Display.PicQuad(
      v0, v1, v2, v3,
      Particle.Data.Texture.TexCoords.tl, Particle.Data.Texture.TexCoords.tr,
      Particle.Data.Texture.TexCoords.bl, Particle.Data.Texture.TexCoords.br,
      Particle.Color, Particle.Data.Texture, Particle.BlendMode, tfLinear
    );
  end;
  var i, j: Integer;
begin
  if not _Playing then Exit;
  for i := 0 to Layers.Count - 1 do
  for j := 0 to TParticleLayer(Layers[i]).Particles.Count - 1 do
  RenderParticle(TParticle(TParticleLayer(Layers[i]).Particles[j]));
end;
//TParticlePlayback END

//TParticleData BEGIN
procedure TParticleData.Initialize;
begin
  _ExportState := es_none;
  Effects.Clear;
  Selection := nil;
  Playback := TParticlePlayback.Create;
  Mods.Clear;
  Mods.Add(TParticleModOpacityGraph);
  Mods.Add(TParticleModColorGraph);
  Mods.Add(TParticleModScaleGraph);
  Mods.Add(TParticleModWidthGraph);
  Mods.Add(TParticleModHeightGraph);
  Mods.Add(TParticleModRotationGraph);
  Mods.Add(TParticleModOrientationGraph);
  Mods.Add(TParticleModVelocityGraph);
  Mods.Add(TParticleModAcceleration);
  Mods.Add(TParticleEmitterModOrientationGraph);
  Mods.Add(TParticleEmitterModScaleGraph);
end;

procedure TParticleData.Finalize;
begin
  Playback.Free;
  Clear;
end;

procedure TParticleData.Update;
begin
  if _ChangedTime > 0 then _ChangedTime -= g2.DeltaTimeSec;
  if (CurrentEffect <> nil) and not Playback.Playing and (_ChangedTime <= 0) then Playback.Start;
  Playback.Update;
end;

procedure TParticleData.Render;
  var g2ml: TG2MLWriter;
  procedure WriteEmitter(const e: TParticleEmitter);
    var BlendOpToStr: array[0..10] of String = (
      'Disable',
      'Zero',
      'One',
      'SrcColor',
      'InvSrcColor',
      'DstColor',
      'InvDstColor',
      'SrcAlpha',
      'InvSrcAlpha',
      'DstAlpha',
      'InvDstAlpha'
    );
    var i: Integer;
  begin
    g2ml.NodeOpen('emitter');
    g2ml.NodeValue('name', e.Name);
    if e.Texture <> nil then
    g2ml.NodeValue('frame', ExtractFileName(e.Texture.AssetName))
    else
    g2ml.NodeValue('frame', '');
    g2ml.NodeValue('time_start', e.TimeStart);
    g2ml.NodeValue('time_end', e.TimeEnd);
    g2ml.NodeValue('orientation', e.Orientation);
    g2ml.NodeValue('shape', Ord(e.Shape));
    g2ml.NodeValue('shape_radius_0', e.ShapeRadius0);
    g2ml.NodeValue('shape_radius_1', e.ShapeRadius1);
    g2ml.NodeValue('shape_angle', e.ShapeAngle);
    g2ml.NodeValue('shape_width_0', e.ShapeWidth0);
    g2ml.NodeValue('shape_width_1', e.ShapeWidth1);
    g2ml.NodeValue('shape_height_0', e.ShapeHeight0);
    g2ml.NodeValue('shape_height_1', e.ShapeHeight1);
    g2ml.NodeValue('emission', e.Emission);
    g2ml.NodeValue('layer', e.Layer);
    g2ml.NodeValue('infinite', e.Infinite);
    g2ml.NodeValue('particle_center_x', e.ParticleCenterX);
    g2ml.NodeValue('particle_center_y', e.ParticleCenterY);
    g2ml.NodeValue('particle_width_min', e.ParticleWidthMin);
    g2ml.NodeValue('particle_width_max', e.ParticleWidthMax);
    g2ml.NodeValue('particle_height_min', e.ParticleHeightMin);
    g2ml.NodeValue('particle_height_max', e.ParticleHeightMax);
    g2ml.NodeValue('particle_scale_min', e.ParticleScaleMin);
    g2ml.NodeValue('particle_scale_max', e.ParticleScaleMax);
    g2ml.NodeValue('particle_duration_min', e.ParticleDurationMin);
    g2ml.NodeValue('particle_duration_max', e.ParticleDurationMax);
    g2ml.NodeValue('particle_rotation_min', e.ParticleRotationMin);
    g2ml.NodeValue('particle_rotation_max', e.ParticleRotationMax);
    g2ml.NodeValue('particle_rotation_local', e.ParticleRotationLocal);
    g2ml.NodeValue('particle_orientation_min', e.ParticleOrientationMin);
    g2ml.NodeValue('particle_orientation_max', e.ParticleOrientationMax);
    g2ml.NodeValue('particle_velocity_min', e.ParticleVelocityMin);
    g2ml.NodeValue('particle_velocity_max', e.ParticleVelocityMax);
    g2ml.NodeValue('particle_color_0', IntToHex(TG2IntU32(e.ParticleColor0) and $ffffff, 6));
    g2ml.NodeValue('particle_color_1', IntToHex(TG2IntU32(e.ParticleColor1) and $ffffff, 6));
    g2ml.NodeValue('particle_opacity', e.ParticleColor0.a * G2Rcp255);
    g2ml.NodeOpen('blend_mode');
    g2ml.NodeValue('ColorSrc', BlendOpToStr[Ord(e.ParticleBlend.ColorSrc)]);
    g2ml.NodeValue('ColorDst', BlendOpToStr[Ord(e.ParticleBlend.ColorDst)]);
    g2ml.NodeValue('AlphaSrc', BlendOpToStr[Ord(e.ParticleBlend.AlphaSrc)]);
    g2ml.NodeValue('AlphaDst', BlendOpToStr[Ord(e.ParticleBlend.AlphaDst)]);
    g2ml.NodeClose;
    for i := 0 to e.Mods.Count - 1 do
    begin
      g2ml.NodeOpen('mod');
      g2ml.NodeValue('name', e.Mods[i].GetName);
      g2ml.NodeValue('guid', e.Mods[i].GetGUID);
      e.Mods[i].WriteG2ML(g2ml);
      g2ml.NodeClose;
    end;
    for i := 0 to e.Emitters.Count - 1 do
    WriteEmitter(e.Emitters[i]);
    g2ml.NodeClose;
  end;
  var Textures: TG2QuickList;
  procedure CollectTextures(const po: TParticleObject);
    var e: TParticleEmitter;
    var i: Integer;
  begin
    if po is TParticleEmitter then
    begin
      e := TParticleEmitter(po);
      if e.Texture <> nil then
      Textures.Add(e.Texture);
    end;
    for i := 0 to po.Emitters.Count - 1 do
    CollectTextures(po.Emitters[i]);
  end;
  var i, j: Integer;
  var fpath, fname, fext, data: String;
  var sd: TSaveDialog;
  var dm: TG2DataManager;
begin
  if _ExportState = es_initiate then
  begin
    Textures.Clear;
    CollectTextures(_ExportEffect);
    _ExportAtlas := TG2Atlas.Create;
    _ExportAtlas.RenderAtlas(
      PG2Texture2DBase(Textures.Data), nil, Textures.Count,
      1024, 1024, 2, False, False, nil
    );
    _ExportState := es_render;
  end
  else if _ExportState = es_render then
  begin
    sd := TSaveDialog.Create(nil);
    sd.DefaultExt := 'g2fx';
    g2.Pause := True;
    try
      if sd.Execute then
      begin
        fpath := ExtractFilePath(sd.FileName);
        fname := ExtractFileNameWithoutExt(ExtractFileName(sd.FileName));
        fext := ExtractFileExt(sd.FileName);
        for i := 0 to _ExportAtlas.Pages.Count - 1 do
        _ExportAtlas.Pages[i].Texture.Save(fpath + G2PathSep + fname + '_fx_atlas_' + IntToStr(i) + '.png');
        g2ml := TG2MLWriter.Create;
        g2ml.NodeOpen('g2fx');
        g2ml.NodeValue('name', _ExportEffect.Name);
        g2ml.NodeValue('scale', _ExportEffect.Scale);
        g2ml.NodeOpen('atlas');
        for i := 0 to _ExportAtlas.Pages.Count - 1 do
        begin
          g2ml.NodeOpen('page');
          g2ml.NodeValue('texture', fname + '_fx_atlas_' + IntToStr(i) + '.png');
          g2ml.NodeValue('width', _ExportAtlas.Pages[i].Width);
          g2ml.NodeValue('height', _ExportAtlas.Pages[i].Height);
          for j := 0 to _ExportAtlas.Frames.Count - 1 do
          if _ExportAtlas.Frames[j].Page = _ExportAtlas.Pages[i] then
          begin
            g2ml.NodeOpen('frame');
            g2ml.NodeValue('name', _ExportAtlas.Frames[j].Name);
            g2ml.NodeValue('pos_l', _ExportAtlas.Frames[j].PosL);
            g2ml.NodeValue('pos_t', _ExportAtlas.Frames[j].PosT);
            g2ml.NodeValue('width', _ExportAtlas.Frames[j].Width);
            g2ml.NodeValue('height', _ExportAtlas.Frames[j].Height);
            g2ml.NodeClose;
          end;
          g2ml.NodeClose;
        end;
        g2ml.NodeClose;
        for i := 0 to _ExportEffect.Emitters.Count - 1 do
        WriteEmitter(_ExportEffect.Emitters[i]);
        g2ml.NodeClose;
        dm := TG2DataManager.Create(sd.FileName, dmWrite);
        try
          data := g2ml.G2ML;
          dm.WriteBuffer(@data[1], Length(data));
        finally
          dm.Free;
          g2ml.Free;
        end;
      end;
    finally
      _ExportAtlas.Free;
      sd.Free;
      g2.Pause := False;
      _ExportState := es_none;
    end;
  end;
end;

procedure TParticleData.EffectChanged;
begin
  if Playback.Playing then Playback.Stop;
  _ChangedTime := 0.5;
end;

procedure TParticleData.Render(const Display: TG2Display2D);
  var Emitter: TParticleEmitter;
  var e: TEmitter;
  var v0, v1, v2, v3: TG2Vec2;
  var a0, hw, hh, radius: TG2Float;
  var rg, r0, r: TG2Rotation2;
  var d, i, j: Integer;
begin
  if CurrentEffect = nil then Exit;
  Playback.Render(Display);
  if not (Selection is TParticleEmitter) then Exit;
  Emitter := TParticleEmitter(Selection);
  e := nil;
  if Playback.Playing then
  for i := 0 to Playback.Emitters.Count - 1 do
  if TEmitter(Playback.Emitters[i]).Data = Emitter then
  begin
    e := TEmitter(Playback.Emitters[i]);
    Break;
  end;
  case Emitter.Shape of
    es_radial:
    begin
      for i := 0 to 1 do
      begin
        if e <> nil then
        begin
          if i = 0 then radius := e.Radius0
          else radius := e.Radius1;
        end
        else
        begin
          if i = 0 then radius := Emitter.ShapeRadius0
          else radius := Emitter.ShapeRadius1;
        end;
        radius *= Emitter.ParentEffect.Scale;
        a0 := -Emitter.ShapeAngle * 0.5;
        d := Round(Emitter.ShapeAngle / G2TwoPi * 64);
        if d = 0 then d := 1;
        r := G2Rotation2(Emitter.ShapeAngle / d);
        if e <> nil then
        r0 := G2Rotation2(a0 + e.Orientation)
        else
        r0 := G2Rotation2(a0 + Emitter.Orientation);
        v0 := G2Vec2(radius, 0);
        v0 := r0.Transform(v0);
        Display.PrimLine(0, 0, v0.x, v0.y, $ffff0000);
        for j := 0 to d - 1 do
        begin
          v1 := r.Transform(v0);
          Display.PrimLine(v0, v1, $ffff0000);
          v0 := v1;
        end;
        Display.PrimLine(0, 0, v0.x, v0.y, $ffff0000);
      end;
    end;
    es_rectangle:
    begin
      for i := 0 to 1 do
      begin
        if i = 0 then
        begin
          if e <> nil then
          begin
            hw := e.Width0 * 0.5;
            hh := e.Height0 * 0.5;
          end
          else
          begin
            hw := Emitter.ShapeWidth0 * 0.5;
            hh := Emitter.ShapeHeight0 * 0.5;
          end;
        end
        else
        begin
          if e <> nil then
          begin
            hw := e.Width1 * 0.5;
            hh := e.Height1 * 0.5;
          end
          else
          begin
            hw := Emitter.ShapeWidth1 * 0.5;
            hh := Emitter.ShapeHeight1 * 0.5;
          end;
        end;
        hw *= Emitter.ParentEffect.Scale;
        hh *= Emitter.ParentEffect.Scale;
        if e <> nil then
        r0 := G2Rotation2(e.Orientation)
        else
        r0 := G2Rotation2(Emitter.Orientation);
        v0 := r0.Transform(G2Vec2(-hw, -hh));
        v1 := r0.Transform(G2Vec2(hw, -hh));
        v2 := r0.Transform(G2Vec2(-hw, hh));
        v3 := r0.Transform(G2Vec2(hw, hh));
        Display.PrimQuadHollowCol(v0, v1, v2, v3, $ffff0000, $ffff0000, $ffff0000, $ffff0000);
      end;
    end;
  end;
end;

function TParticleData.CurrentEffect: TParticleEffect;
begin
  if Selection = nil then Result := nil
  else if Selection is TParticleEffect then Result := TParticleEffect(Selection)
  else if Selection is TParticleEmitter then Result := TParticleEmitter(Selection).ParentEffect
  else Result := nil;
end;

function TParticleData.EffectAdd: TParticleEffect;
begin
  Result := TParticleEffect.Create;
  Result.Name := UniqueEffectName('Effect');
  Effects.Add(Result);
  EffectSelect(Result);
end;

procedure TParticleData.EffectSelect(const Effect: TParticleEffect);
begin
  if Selection <> Effect then
  begin
    Selection := Effect;
    UpdateEditors;
    EffectChanged;
  end;
end;

procedure TParticleData.EffectDelete(const Effect: TParticleEffect);
begin
  if Selection = Effect then EffectSelect(nil);
  Effects.Remove(Effect);
  Effect.Free;
end;

function TParticleData.EmitterAdd: TParticleEmitter;
begin
  if Selection = nil then Exit(nil);
  Result := TParticleEmitter.Create;
  Result.Name := UniqueEmitterName(Selection, 'Emitter');
  Selection.Emitters.Add(Result);
  if Selection is TParticleEffect then
  Result.ParentEffect := TParticleEffect(Selection)
  else if Selection is TParticleEmitter then
  begin
    Result.ParentEffect := TParticleEmitter(Selection).ParentEffect;
    Result.ParentEmitter := TParticleEmitter(Selection);
  end;
  EmitterSelect(Result);
end;

procedure TParticleData.EmitterSelect(const Emitter: TParticleEmitter);
begin
  if Selection <> Emitter then
  begin
    if (Emitter = nil) or (CurrentEffect <> Emitter.ParentEffect) then EffectChanged;
    Selection := Emitter;
    UpdateEditors;
  end;
end;

procedure TParticleData.EmitterDelete(const Emitter: TParticleEmitter);
begin
  if Selection = Emitter then EffectSelect(Emitter.ParentEffect);
  if Emitter.ParentEmitter <> nil then
  Emitter.ParentEmitter.Emitters.Remove(Emitter)
  else
  Emitter.ParentEffect.Emitters.Remove(Emitter);
  Emitter.Free;
end;

procedure TParticleData.UpdateEditors;
  var i: Integer;
begin
  for i := 0 to TUIWorkspaceParticles2DEditor.WorkspaceList.Count - 1 do
  TUIWorkspaceParticles2DEditor.WorkspaceList[i].SelectionChanged;
  for i := 0 to TUIWorkspaceParticles2DViewport.WorkspaceList.Count - 1 do
  TUIWorkspaceParticles2DViewport.WorkspaceList[i].SelectionChanged;
end;

procedure TParticleData.SaveLib(const FileName: String);
  var dm: TG2DataManager;
  var i, j: Integer;
  var Effect: TParticleEffect;
begin
  dm := TG2DataManager.Create(FileName, dmWrite);
  try
    dm.WriteStringARaw('G2FXL');
    dm.WriteIntU16(Version);
    dm.WriteIntS32(Effects.Count);
    for i := 0 to Effects.Count - 1 do
    begin
      Effect := Effects[i];
      Effect.Save(dm);
    end;
  finally
    dm.Free;
  end;
end;

procedure TParticleData.LoadLib(const FileName: String);
  var dm: TG2DataManager;
  var i, n: Integer;
  var ver: TG2IntU16;
  var Effect: TParticleEffect;
  var Header: array[0..4] of AnsiChar;
begin
  dm := TG2DataManager.Create(FileName, dmRead);
  try
    dm.ReadBuffer(@Header, 5);
    if Header = 'G2FXL' then
    begin
      Clear;
      ver := dm.ReadIntU16;
      if ver = Version then
      begin
        n := dm.ReadIntS32;
        for i := 0 to n - 1 do
        begin
          Effect := TParticleEffect.Create;
          Effect.Load(dm);
          Effects.Add(Effect);
        end;
      end;
    end;
  finally
    dm.Free;
  end;
end;

procedure TParticleData.ExportEffect(const Effect: TParticleEffect);
begin
  _ExportEffect := Effect;
  _ExportState := es_initiate;
end;

procedure TParticleData.Clear;
  var i: Integer;
begin
  for i := 0 to Effects.Count - 1 do
  Effects[i].Free;
  Effects.Clear;
  EffectSelect(nil);
end;

function TParticleData.FindEffectByName(const Name: String): TParticleEffect;
  var i: Integer;
  var lc: String;
begin
  lc := LowerCase(Name);
  for i := 0 to Effects.Count - 1 do
  if LowerCase(Effects[i].Name) = lc then
  begin
    Result := Effects[i];
    Exit;
  end;
  Result := nil;
end;

function TParticleData.UniqueEffectName(const Name: String): String;
  var NewName: String;
  var Ind: Integer;
begin
  Ind := 0;
  NewName := Name;
  while FindEffectByName(NewName) <> nil do
  begin
    Inc(Ind);
    NewName := Name + IntToStr(Ind);
  end;
  Result := NewName;
end;

function TParticleData.FindEmitterByName(const Parent: TParticleObject; const Name: String): TParticleEmitter;
  var i: Integer;
  var lc: String;
begin
  lc := LowerCase(Name);
  for i := 0 to Parent.Emitters.Count - 1 do
  if LowerCase(Parent.Emitters[i].Name) = lc then
  begin
    Result := Parent.Emitters[i];
    Exit;
  end;
  Result := nil;
end;

function TParticleData.UniqueEmitterName(const Parent: TParticleObject; const Name: String): String;
  var NewName: String;
  var Ind: Integer;
begin
  Ind := 0;
  NewName := Name;
  while FindEmitterByName(Parent, NewName) <> nil do
  begin
    Inc(Ind);
    NewName := Name + IntToStr(Ind);
  end;
  Result := NewName;
end;
//TParticleData END

//TAtlasPackerData BEGIN
function TAtlasPackerData.GetFormat(const Index: Integer): String;
begin
  Result := _FormatList[Index];
end;

function TAtlasPackerData.GetFormatCount: Integer;
begin
  Result := _FormatList.Count;
end;

procedure TAtlasPackerData.Initailize;
begin
  _TimeToUpdate := 0;
  _LastUpdateTime := 0;
  _FormatList.Clear;
  _WorkspaceCount := 0;
end;

procedure TAtlasPackerData.Finalize;
begin

end;

procedure TAtlasPackerData.Update;
  var sr: TSearchRec;
  var NeedUpdate: Boolean;
  var i: Integer;
begin
  _TimeToUpdate -= g2.DeltaTimeMs;
  if (_TimeToUpdate < 0)
  and (_WorkspaceCount > 0) then
  begin
    _UpdateList.Clear;
    if FindFirst(g2.AppPath + G2PathSep + 'data' + G2PathSep + 'atlas_packer' + G2PathSep + '*.g2af', 0, sr) = 0 then
    begin
      repeat
        _UpdateList.Add(sr.Name);
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
    NeedUpdate := _FormatList.Count <> _UpdateList.Count;
    if not NeedUpdate then
    for i := 0 to _FormatList.Count - 1 do
    if _FormatList[i] <> _UpdateList[i] then
    begin
      NeedUpdate := True;
      Break;
    end;
    if NeedUpdate then
    begin
      _LastUpdateTime := G2Time;
      _FormatList.Clear;
      for i := 0 to _UpdateList.Count - 1 do
      _FormatList.Add(_UpdateList[i]);
    end;
    _TimeToUpdate := 5;
  end;
end;
//TAtlasPackerData END

//TScene2DEditor BEGIN
procedure TScene2DEditor.RefInc;
begin
  Inc(_Ref);
end;

procedure TScene2DEditor.RefDec;
begin
  Dec(_Ref);
  if _Ref <= 0 then Free;
end;

procedure TScene2DEditor.Update;
begin

end;

procedure TScene2DEditor.Update(const Display: TG2Display2D);
begin

end;

procedure TScene2DEditor.Render(const Display: TG2Display2D);
begin

end;

procedure TScene2DEditor.MouseDown(const Display: TG2Display2D; const Button, x, y: Integer);
begin

end;

procedure TScene2DEditor.MouseUp(const Display: TG2Display2D; const Button, x, y: Integer);
begin

end;

procedure TScene2DEditor.KeyDown(const Key: Integer);
begin

end;

procedure TScene2DEditor.KeyUp(const Key: Integer);
begin

end;

procedure TScene2DEditor.Initialize;
begin

end;

procedure TScene2DEditor.Finalize;
begin

end;
//TScene2DEditor END

//TScene2DEditorShape BEGIN
function TScene2DEditorShape.GetOwner: TG2Scene2DEntity;
begin
  Result := nil;
end;

function TScene2DEditorShape.GetTransform: TG2Transform2;
  var rb: TG2Scene2DComponentRigidBody;
  var rbxf, xf: TG2Transform2;
begin
  rb := TG2Scene2DComponentRigidBody(GetOwner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then
  begin
    Result := G2Transform2;
    Exit;
  end;
  xf := GetOwner.Transform;
  rbxf := rb.Transform;
  G2Transform2Mul(@Result, @rbxf, @xf);
end;

procedure TScene2DEditorShape.DrawEditPoint(
  const Display: TG2Display2D;
  const v: TG2Vec2;
  const c: TG2Color
);
  var vs: TG2Vec2;
begin
  vs := Display.CoordToScreen(v);
  g2.PrimRectHollow(vs.x - 4, vs.y - 4, 8, 8, c);
end;
//TScene2DEditorShape END

//TScene2DEditorEdge BEGIN
function TScene2DEditorEdge.GetOwner: TG2Scene2DEntity;
begin
  Result := Component.Component.Owner;
end;

constructor TScene2DEditorEdge.Create;
begin
  _Component := nil;
  Instance := Self;
end;

destructor TScene2DEditorEdge.Destroy;
begin
  Instance := nil;
  inherited Destroy;
end;

procedure TScene2DEditorEdge.Update(const Display: TG2Display2D);
  var xf: TG2Transform2;
  var v: TG2Vec2;
begin
  if VSelect > -1 then
  begin
    xf := GetTransform;
    v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
    v := xf.TransformInv(v);
    case VSelect of
      0: Component.Component.Vertex1 := v;
      1: Component.Component.Vertex2 := v;
    end;
  end;
end;

procedure TScene2DEditorEdge.Render(const Display: TG2Display2D);
  var xf: TG2Transform2;
  var v1, v2, vs1, vs2: TG2Vec2;
  var c1, c2: TG2Color;
begin
  xf := GetTransform;
  v1 := xf.Transform(Component.Component.Vertex1);
  v2 := xf.Transform(Component.Component.Vertex2);
  c1 := $ffff0000; c2 := $ffff0000;
  vs1 := Display.CoordToScreen(v1);
  vs2 := Display.CoordToScreen(v2);
  if VSelect > -1 then
  begin
    case VSelect of
      0: c1 := $ff80ff00;
      1: c2 := $ff80ff00;
    end;
  end
  else
  begin
    if G2Rect(vs1.x - 4, vs1.y - 4, 8, 8).Contains(g2.MousePos) then
    begin
      c1 := $ff0000ff;
    end
    else if G2Rect(vs2.x - 4, vs2.y - 4, 8, 8).Contains(g2.MousePos) then
    begin
      c2 := $ff0000ff;
    end;
  end;
  Display.PrimLineCol(v1, v2, c1, c2);
  DrawEditPoint(Display, v1, c1);
  DrawEditPoint(Display, v2, c2);
end;

procedure TScene2DEditorEdge.MouseDown(const Display: TG2Display2D; const Button, x, y: Integer);
  var xf: TG2Transform2;
  var v1, v2, vs1, vs2: TG2Vec2;
begin
  xf := GetTransform;
  v1 := xf.Transform(Component.Component.Vertex1);
  v2 := xf.Transform(Component.Component.Vertex2);
  vs1 := Display.CoordToScreen(v1);
  vs2 := Display.CoordToScreen(v2);
  if G2Rect(vs1.x - 4, vs1.y - 4, 8, 8).Contains(g2.MousePos) then
  begin
    VSelect := 0;
  end
  else if G2Rect(vs2.x - 4, vs2.y - 4, 8, 8).Contains(g2.MousePos) then
  begin
    VSelect := 1;
  end;
end;

procedure TScene2DEditorEdge.MouseUp(const Display: TG2Display2D; const Button, x, y: Integer);
begin
  VSelect := -1;
end;

procedure TScene2DEditorEdge.Initialize;
begin
  VSelect := -1;
end;
//TScene2DEditorEdge END

//TScene2DEditorChain BEIGN
function TScene2DEditorChain.GetOwner: TG2Scene2DEntity;
begin
  Result := Component.Component.Owner;
end;

constructor TScene2DEditorChain.Create;
begin
  _Component := nil;
  Instance := Self;
end;

destructor TScene2DEditorChain.Destroy;
begin
  Instance := nil;
  inherited Destroy;
end;

procedure TScene2DEditorChain.Update(const Display: TG2Display2D);
  var xf: TG2Transform2;
  var v: TG2Vec2;
begin
  if VSelect > -1 then
  begin
    xf := GetTransform;
    v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
    v := xf.TransformInv(v);
    Component.Component.Vertices^[VSelect] := v;
  end;
end;

procedure TScene2DEditorChain.Render(const Display: TG2Display2D);
  var xf: TG2Transform2;
  var v0, v1: TG2Vec2;
  var i: Integer;
  var c0, c1: TG2Color;
begin
  if Component.Component.VertexCount < 1 then Exit;
  xf := GetTransform;
  v0 := xf.Transform(Component.Component.Vertices^[0]);
  c0 := $ffff0000;
  if VSelect = 0 then c0 := $ff00ff00;
  for i := 1 to Component.Component.VertexCount - 1 do
  begin
    if VSelect = i then c1 := $ff00ff00 else c1 := $ffff0000;
    v1 := xf.Transform(Component.Component.Vertices^[i]);
    Display.PrimLineCol(v0, v1, c0, c1);
    v0 := v1;
    c0 := c1;
  end;
  for i := 0 to Component.Component.VertexCount - 1 do
  begin
    if VSelect = i then c0 := $ff00ff00 else if VLast = i then c0 := $ff8080ff else c0 := $ffff0000;
    v0 := xf.Transform(Component.Component.Vertices^[i]);
    DrawEditPoint(Display, v0, c0);
  end;
end;

procedure TScene2DEditorChain.MouseDown(const Display: TG2Display2D; const Button, x, y: Integer);
  var xf: TG2Transform2;
  var mc, v1: TG2Vec2;
  var v: array of TG2Vec2;
  var i, j, n: Integer;
  var VertexSelected: Boolean;
begin
  if Button <> G2MB_Left then Exit;
  xf := GetTransform;
  mc := xf.TransformInv(Display.CoordToDisplay(G2Vec2(x, y)));
  if g2.KeyDown[G2K_ShiftL]
  or g2.KeyDown[G2K_ShiftR] then
  begin
    for i := 0 to Component.Component.VertexCount - 1 do
    begin
      v1 := Display.CoordToScreen(xf.Transform(Component.Component.Vertices^[i]));
      if G2Rect(v1.x - 4, v1.y - 4, 8, 8).Contains(G2Vec2(x, y)) then
      begin
        if VLast = Component.Component.VertexCount - 1 then
        VLast := G2Max(Component.Component.VertexCount - 2, 0);
        VSelect := -1;
        SetLength(v, Component.Component.VertexCount - 1);
        n := 0;
        for j := 0 to Component.Component.VertexCount - 1 do
        if j <> i then
        begin
          v[n] := Component.Component.Vertices^[j];
          Inc(n);
        end;
        Component.Component.SetUp(@v[0], Length(v));
        Break;
      end;
    end;
  end
  else
  begin
    if Component.Component.VertexCount < 1 then
    begin
      VLast := 0;
      VSelect := 0;
      SetLength(v, 1);
      v[0] := mc;
      Component.Component.SetUp(@v[0], Length(v));
    end
    else
    begin
      VertexSelected := False;
      for i := 0 to Component.Component.VertexCount - 1 do
      begin
        v1 := Display.CoordToScreen(xf.Transform(Component.Component.Vertices^[i]));
        if G2Rect(v1.x - 4, v1.y - 4, 8, 8).Contains(G2Vec2(x, y)) then
        begin
          VSelect := i;
          if (i = 0) or (i = Component.Component.VertexCount - 1) then
          VLast := VSelect;
          VertexSelected := True;
          Break;
        end;
      end;
      if not VertexSelected then
      begin
        SetLength(v, Component.Component.VertexCount + 1);
        if VLast = 0 then
        begin
          v[0] := mc;
          for i := 0 to Component.Component.VertexCount - 1 do
          v[i + 1] := Component.Component.Vertices^[i];
          //Move(Component.Component.Vertices^[0], v[1], Component.Component.VertexCount * SizeOf(TG2Vec2));
          Component.Component.SetUp(@v[0], Length(v));
          VSelect := VLast;
        end
        else
        begin
          for i := 0 to Component.Component.VertexCount - 1 do
          v[i] := Component.Component.Vertices^[i];
          //Move(Component.Component.Vertices^[0], v[0], Component.Component.VertexCount * SizeOf(TG2Vec2));
          v[Component.Component.VertexCount] := mc;
          Component.Component.SetUp(@v[0], Length(v));
          VLast := Component.Component.VertexCount;
          VSelect := VLast;
        end;
      end;
    end;
  end;
end;

procedure TScene2DEditorChain.MouseUp(const Display: TG2Display2D; const Button, x, y: Integer);
begin
  VSelect := -1;
end;

procedure TScene2DEditorChain.Initialize;
begin
  VSelect := -1;
  VLast := G2Max(Component.Component.VertexCount - 1, 0);
end;
//TScene2DEditorChain END

//TScene2DEditorShapePoly BEGIN
procedure TScene2DEditorShapePoly.SetLimits;
  var i, i0, i1: Integer;
  var v0, v1, n: TG2Vec2;
  var l: TG2Vec3;
begin
  _Limits.Clear;
  if (Component.Component.VertexCount < 3) or (VSelect = -1) then Exit;
  if Component.Component.VertexCount = 3 then
  begin
    i0 := VSelect - 1; if i0 < 0 then i0 := Component.Component.VertexCount + i0;
    i1 := VSelect - 2; if i1 < 0 then i1 := Component.Component.VertexCount + i1;
    v0 := Component.Component.Vertices^[i0];
    v1 := Component.Component.Vertices^[i1];
    n := (v1 - v0).Perp.Norm;
    l.x := n.x; l.y := n.y; l.z := n.Dot(v0);
    _Limits.Add(l);
  end
  else
  begin
    i0 := VSelect - 1; if i0 < 0 then i0 := Component.Component.VertexCount + i0;
    i1 := VSelect - 2; if i1 < 0 then i1 := Component.Component.VertexCount + i1;
    v0 := Component.Component.Vertices^[i0];
    v1 := Component.Component.Vertices^[i1];
    n := (v1 - v0).Perp.Norm;
    l.x := n.x; l.y := n.y; l.z := n.Dot(v0);
    _Limits.Add(l);
    i0 := (VSelect + 2) mod Component.Component.VertexCount;
    i1 := (VSelect + 1) mod Component.Component.VertexCount;
    v0 := Component.Component.Vertices^[i0];
    v1 := Component.Component.Vertices^[i1];
    n := (v1 - v0).Perp.Norm;
    l.x := n.x; l.y := n.y; l.z := n.Dot(v0);
    _Limits.Add(l);
    i0 := (VSelect - 1); if i0 < 0 then i0 := Component.Component.VertexCount + i0;
    i1 := (VSelect + 1) mod Component.Component.VertexCount;
    v0 := Component.Component.Vertices^[i0];
    v1 := Component.Component.Vertices^[i1];
    n := (v1 - v0).Perp.Norm;
    l.x := n.x; l.y := n.y; l.z := n.Dot(v0);
    _Limits.Add(l);
  end;
end;

function TScene2DEditorShapePoly.GetOwner: TG2Scene2DEntity;
begin
  Result := _Component.Component.Owner;
end;

constructor TScene2DEditorShapePoly.Create;
begin
  _Component := nil;
  Instance := Self;
  _Limits.Clear;
end;

destructor TScene2DEditorShapePoly.Destroy;
begin
  Instance := nil;
  inherited Destroy;
end;

procedure TScene2DEditorShapePoly.Update(const Display: TG2Display2D);
  var xf: TG2Transform2;
  var mc, v, v0, v1, v2, v3: TG2Vec2;
  var l, l0, l1: TG2Vec3;
  var d: TG2Float;
  var i, r: Integer;
  var Limv: array[0..1] of Integer;
  var Limc: Integer;
  var b: Boolean;
begin
  if VSelect > -1 then
  begin
    xf := GetTransform;
    mc := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
    mc := xf.TransformInv(mc);
    Limc := 0;
    b := True;
    r := 0;
    while b and (r < 100) do
    begin
      b := False;
      for i := 0 to _Limits.Count - 1 do
      begin
        l := _Limits[i];
        v.x := l.x; v.y := l.y;
        d := v.Dot(mc) - l.z;
        if d > 0 then
        begin
          mc := mc - (d * v);
          b := True;
        end;
      end;
      Inc(r);
    end;
    Component.Component.Vertices^[VSelect] := mc;
  end;
end;

procedure TScene2DEditorShapePoly.Render(const Display: TG2Display2D);
  var xf: TG2Transform2;
  var i, n: Integer;
  var v0, v1: TG2Vec2;
  var c0, c1: TG2Color;
begin
  if Component.Component.VertexCount < 1 then Exit;
  xf := GetTransform;
  v0 := xf.Transform(Component.Component.Vertices^[0]);
  c0 := $ffff0000;
  if VSelect = 0 then c0 := $ff00ff00;
  for i := 1 to Component.Component.VertexCount do
  begin
    n := i mod Component.Component.VertexCount;
    if VSelect = n then c1 := $ff00ff00 else c1 := $ffff0000;
    v1 := xf.Transform(Component.Component.Vertices^[n]);
    Display.PrimLineCol(v0, v1, c0, c1);
    v0 := v1;
    c0 := c1;
  end;
  for i := 0 to Component.Component.VertexCount - 1 do
  begin
    if VSelect = i then c0 := $ff00ff00 else c0 := $ffff0000;
    v0 := xf.Transform(Component.Component.Vertices^[i]);
    DrawEditPoint(Display, v0, c0);
  end;
end;

procedure TScene2DEditorShapePoly.MouseDown(const Display: TG2Display2D; const Button, x, y: Integer);
  var xf: TG2Transform2;
  var i, j, i0, i1, e, iv: Integer;
  var v, v0, v1, n: TG2Vec2;
  var d, dm: TG2Float;
  var varr: array[0..b2_max_polygon_vertices] of TG2Vec2;
begin
  if Button <> G2MB_Left then Exit;
  xf := GetTransform;
  if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
  begin
    if Component.Component.VertexCount > 3 then
    for i := 0 to Component.Component.VertexCount - 1 do
    begin
      v := xf.Transform(Component.Component.Vertices^[i]);
      v := Display.CoordToScreen(v);
      if G2Rect(v.x - 4, v.y - 4, 8, 8).Contains(x, y) then
      begin
        iv := 0;
        for j := 0 to Component.Component.VertexCount - 1 do
        if i <> j then
        begin
          varr[iv] := Component.Component.Vertices^[j];
          Inc(iv);
        end;
        Component.Component.SetUp(@varr, iv);
        Break;
      end;
    end;
  end
  else
  begin
    for i := 0 to Component.Component.VertexCount - 1 do
    begin
      v := xf.Transform(Component.Component.Vertices^[i]);
      v := Display.CoordToScreen(v);
      if G2Rect(v.x - 4, v.y - 4, 8, 8).Contains(x, y) then
      begin
        VSelect := i;
        SetLimits;
        Break;
      end;
    end;
    v := Display.CoordToDisplay(G2Vec2(x, y));
    v := xf.TransformInv(v);
    if (VSelect = - 1)
    and (Component.Component.VertexCount < b2_max_polygon_vertices)
    and (
      (Component.Component.VertexCount < 3)
      or (not G2Vec2InPoly(v, @Component.Component.Vertices^[0], Component.Component.VertexCount))
    ) then
    begin
      dm := 0;
      e := -1;
      for i := 0 to Component.Component.VertexCount - 1 do
      begin
        i0 := i; i1 := (i + 1) mod Component.Component.VertexCount;
        v0 := Component.Component.Vertices^[i0];
        v1 := Component.Component.Vertices^[i1];
        n := (v0 - v1).Perp.Norm;
        d := n.Dot(v);
        if (d > dm) then
        begin
          e := i;
          dm := d;
        end;
      end;
      if e > -1 then
      begin
        iv := 0;
        for i := 0 to Component.Component.VertexCount - 1 do
        begin
          varr[iv] := Component.Component.Vertices^[i];
          Inc(iv);
          if i = e then
          begin
            varr[iv] := v;
            Inc(iv);
          end;
        end;
        Component.Component.SetUp(@varr, iv);
        iv := -1;
        for i := 0 to Component.Component.VertexCount - 1 do
        begin
          d := (Component.Component.Vertices^[i] - v).LenSq;
          if (iv = -1) or (d < dm) then
          begin
            iv := i;
            dm := d;
          end;
        end;
        if iv > -1 then
        begin
          VSelect := iv;
          SetLimits;
        end;
      end;
    end;
  end;
end;

procedure TScene2DEditorShapePoly.MouseUp(const Display: TG2Display2D; const Button, x, y: Integer);
  var varr: array[0..b2_max_polygon_vertices] of TG2Vec2;
  var c: Integer;
begin
  _Limits.Clear;
  if VSelect > -1 then
  begin
    c := Component.Component.VertexCount;
    Move(Component.Component.Vertices^[0], varr[0], SizeOf(TG2Vec2) * c);
    Component.Component.SetUp(@varr, c);
  end;
  VSelect := -1;
end;

procedure TScene2DEditorShapePoly.Initialize;
begin
  _Limits.Clear;
  VSelect := -1;
end;
//TScene2DEditorShapePoly END

//TScene2DEditorPoly BEGIN
constructor TScene2DEditorPoly.TSelectList.Create;
begin
  inherited Create;
  List.Clear;
end;

procedure TScene2DEditorPoly.TSelectList.Clear;
begin
  List.Clear;
end;

procedure TScene2DEditorPoly.TSelectList.AddItem(const ItemName: AnsiString);
begin
  List.Add(ItemName);
end;

procedure TScene2DEditorPoly.TSelectList.Initialize(const Frame: TG2Rect; const BorderSize: TG2Float);
  var i: Integer;
begin
  bs := BorderSize;
  f := Frame;
  ItemSize := Frame.h - bs * 2;
  f.t := f.t - ItemSize * (List.Count - 1);
  App.UI.Overlay := Self;
end;

procedure TScene2DEditorPoly.TSelectList.Render;
  var i: Integer;
  var r: TG2Rect;
  var c, c1: TG2Color;
  var mc: TPoint;
begin
  mc := g2.MousePos;
  App.UI.DrawSpotFrame(f, bs, $ff808080);
  r := f;
  r.t := r.t + bs;
  r.h := ItemSize;
  for i := 0 to List.Count - 1 do
  begin
    if r.Contains(mc) then
    begin
      if g2.MouseDown[G2MB_Left]
      and r.Contains(g2.MouseDownPos[G2MB_Left]) then
      begin
        c := $ff404040;
        c1 := $ffffffff;
      end
      else
      begin
        c := $ffa0a0a0;
        c1 := $ff000000;
      end;
      g2.PicRect(
        r.l, r.t, bs, ItemSize, 0, 0.5, 0.5, 0.5,
        c, App.UI.TexSpot, bmNormal, tfLinear
      );
      g2.PicRect(
        r.l + bs, r.t, r.w - bs * 2, ItemSize, 0.5, 0.5, 0.5, 0.5,
        c, App.UI.TexSpot, bmNormal, tfLinear
      );
      g2.PicRect(
        r.r - bs, r.t, bs, ItemSize, 0.5, 0.5, 1, 0.5,
        c, App.UI.TexSpot, bmNormal, tfLinear
      );
    end
    else
    begin
      c1 := $ffe0e0e0;
    end;
    App.UI.Font1.Print(
      Round(r.l + (r.w - App.UI.Font1.TextWidth(List[i])) * 0.5),
      Round(r.t + (r.h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, c1, List[i], bmNormal, tfPoint
    );
    r.y := r.y + ItemSize;
  end;
end;

procedure TScene2DEditorPoly.TSelectList.MouseDown(const Button, x, y: Integer);
begin
  if not f.Contains(x, y) then
  begin
    App.UI.Overlay := nil;
    Exit;
  end;
end;

procedure TScene2DEditorPoly.TSelectList.MouseUp(const Button, x, y: Integer);
  var r: TG2Rect;
  var i: Integer;
begin
  if (Button = G2MB_Left)
  and Assigned(OnSelect) then
  begin
    r := f;
    r.t := r.t + bs;
    r.h := ItemSize;
    for i := 0 to List.Count - 1 do
    begin
      if r.Contains(x, y)
      and r.Contains(g2.MouseDownPos[G2MB_Left]) then
      begin
        App.UI.Overlay := nil;
        OnSelect(i);
        Break;
      end;
      r.y := r.y + ItemSize;
    end;
  end;
end;

procedure TScene2DEditorPoly.StartDrag(const mc: TG2Vec2);
  type TVertexReplica = array[0..1] of TScene2DComponentDataPolyVertex;
  var VertexReplica: array of TVertexReplica;
  function ReplicateVertex(const v: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyVertex;
    var i, j: Integer;
  begin
    for i := 0 to High(VertexReplica) do
    if VertexReplica[i][0] = v then
    begin
      Result := VertexReplica[i][1];
      Exit;
    end;
    SetLength(VertexReplica, Length(VertexReplica) + 1);
    i := High(VertexReplica);
    VertexReplica[i][0] := v;
    VertexReplica[i][1] := TScene2DComponentDataPolyVertex.Create;
    VertexReplica[i][1].c.Allocate(Component.Layers.Count);
    for j := 0 to Component.Layers.Count - 1 do
    VertexReplica[i][1].c[j] := v.c[j];
    VertexReplica[i][1].v := v.v;
    VertexReplica[i][1].t := v.t;
    Component.Vertices.Add(VertexReplica[i][1]);
    Result := VertexReplica[i][1];
  end;
  var i, j: Integer;
  var Edges: TScene2DComponentDataPolyEdgeList;
  var e: TScene2DComponentDataPolyEdge;
  var f: TScene2DComponentDataPolyFace;
  var v: array[0..1] of TScene2DComponentDataPolyVertex;
begin
  _Drag := True;
  _VDrag.Clear;
  case EditMode of
    em_vertex,
    em_tex_coord:
    begin
      if Assigned(_MOverVertex) then
      begin
        for i := 0 to _SelectVertex.Count - 1 do
        _VDrag.Add(_SelectVertex[i]);
      end;
    end;
    em_edge:
    begin
      if Assigned(_MOverEdge) then
      begin
        if g2.KeyDown[G2K_ShiftL] or g2.KeyDown[G2K_ShiftR] then
        begin
          Edges.Clear;
          for i := 0 to _SelectEdge.Count - 1 do
          if (_SelectEdge[i].f[0] = nil) or (_SelectEdge[i].f[1] = nil) then
          begin
            v[0] := ReplicateVertex(_SelectEdge[i].v[0]);
            v[1] := ReplicateVertex(_SelectEdge[i].v[1]);
            e := TScene2DComponentDataPolyEdge.Create;
            e.v[0] := v[0];
            e.v[1] := v[1];
            Component.Edges.Add(e);
            Edges.Add(e);
            f := TScene2DComponentDataPolyFace.Create;
            f.v[0] := _SelectEdge[i].v[0];
            f.v[1] := v[0];
            f.v[2] := v[1];
            Component.Faces.Add(f);
            f := TScene2DComponentDataPolyFace.Create;
            f.v[0] := _SelectEdge[i].v[0];
            f.v[1] := v[1];
            f.v[2] := _SelectEdge[i].v[1];
            Component.Faces.Add(f);
            e := TScene2DComponentDataPolyEdge.Create;
            e.v[0] := _SelectEdge[i].v[0];
            e.v[1] := v[1];
            Component.Edges.Add(e);
          end;
          for i := 0 to High(VertexReplica) do
          begin
            e := TScene2DComponentDataPolyEdge.Create;
            e.v[0] := VertexReplica[i][0];
            e.v[1] := VertexReplica[i][1];
            Component.Edges.Add(e);
          end;
          _SelectEdge.Clear;
          for i := 0 to Edges.Count - 1 do
          _SelectEdge.Add(Edges[i]);
          Component.CompleteData;
        end;
        for i := 0 to _SelectEdge.Count - 1 do
        begin
          for j := 0 to 1 do
          if _VDrag.Find(_SelectEdge[i].v[j]) = -1 then
          _VDrag.Add(_SelectEdge[i].v[j]);
        end;
      end;
    end;
    em_face:
    begin
      if Assigned(_MOverFace) then
      begin
        for i := 0 to _SelectFace.Count - 1 do
        begin
          for j := 0 to 2 do
          if _VDrag.Find(_SelectFace[i].v[j]) = -1 then
          _VDrag.Add(_SelectFace[i].v[j]);
        end;
      end;
    end;
  end;
  SetLength(_VOffset, _VDrag.Count);
  if EditMode = em_tex_coord then
  begin
    for i := 0 to _VDrag.Count - 1 do
    _VOffset[i] := _VDrag[i].t - mc;
  end
  else
  begin
    for i := 0 to _VDrag.Count - 1 do
    _VOffset[i] := _VDrag[i].v - mc;
  end;
end;

procedure TScene2DEditorPoly.SetUpPopUpModes;
  var i: Integer;
begin
  _PopUp.Clear;
  for i := 0 to Component.Layers.Count - 1 do
  _PopUp.AddItem('Layer ' + IntToStr(i));
  _PopUp.AddItem('Vertices');
  _PopUp.AddItem('Edges');
  _PopUp.AddItem('Triangles');
  _PopUp.AddItem('TexCoords');
end;

procedure TScene2DEditorPoly.OnSelectMode(const Index: Integer);
  var n: Integer;
begin
  if Index < Component.Layers.Count then
  begin
    OnModeLayer(Index);
  end
  else
  begin
    n := Index - Component.Layers.Count;
    case n of
      0: OnModeVertices;
      1: OnModeEdges;
      2: OnModeFaces;
      3: OnModeTexCoords;
    end;
  end;
end;

procedure TScene2DEditorPoly.OnModeLayer(const Index: Integer);
begin
  EditMode := em_layer;
  EditLayer := Index;
end;

procedure TScene2DEditorPoly.OnModeVertices;
begin
  EditMode := em_vertex;
end;

procedure TScene2DEditorPoly.OnModeEdges;
begin
  EditMode := em_edge;
end;

procedure TScene2DEditorPoly.OnModeFaces;
begin
  EditMode := em_face;
end;

procedure TScene2DEditorPoly.OnModeTexCoords;
begin
  EditMode := em_tex_coord;
end;

procedure TScene2DEditorPoly.OnModeClick(const Display: Pointer);
  var r: TG2Rect;
begin
  SetUpPopUpModes;
  r := _BtnMode.Frame;
  r.x := TG2Display2D(Display).ViewPort.Left + r.x;
  r.y := TG2Display2D(Display).ViewPort.Bottom + r.y;
  _PopUp.Initialize(r, 8);
end;

procedure TScene2DEditorPoly.OnFlipEdgeClick(const Display: Pointer);
  var f: array[0..1] of TScene2DComponentDataPolyFace;
  var e: TScene2DComponentDataPolyEdge;
  var v: array[0..3] of TScene2DComponentDataPolyVertex;
  var i, j: Integer;
begin
  if not (EditMode = em_face) then Exit;
  if _SelectFace.Count <> 2 then Exit;
  f[0] := _SelectFace[0];
  f[1] := _SelectFace[1];
  e := nil;
  for i := 0 to 2 do
  for j := 0 to 2 do
  if f[0].e[i] = f[1].e[j] then e := f[0].e[i];
  if e = nil then Exit;
  v[0] := e.v[0];
  v[2] := e.v[1];
  for i := 0 to 2 do
  begin
    if (f[0].v[i] <> e.v[0]) and (f[0].v[i] <> e.v[1]) then
    v[1] := f[0].v[i];
    if (f[1].v[i] <> e.v[0]) and (f[1].v[i] <> e.v[1]) then
    v[3] := f[1].v[i];
  end;
  f[0].v[0] := v[1]; f[0].v[1] := v[2]; f[0].v[2] := v[3];
  f[1].v[0] := v[3]; f[1].v[1] := v[0]; f[1].v[2] := v[1];
  e.v[0] := v[1]; e.v[1] := v[3];
  Component.CompleteData;
end;

procedure TScene2DEditorPoly.OnCollapseClick(const Display: Pointer);
  type trgba = record
    r, g, b, a: Integer;
  end;
  var carr: array of trgba;
  var i, j, n: Integer;
  var f: TScene2DComponentDataPolyFace;
  var v: TScene2DComponentDataPolyVertex;
  var e, e0, e1: TScene2DComponentDataPolyEdge;
  var df, de: Boolean;
  var vp: TG2Vec2;
begin
  for i := Component.Faces.Count - 1 downto 0 do
  begin
    f := Component.Faces[i];
    for j := 0 to 2 do
    begin
      df := False;
      for n := 0 to _SelectVertex.Count - 1 do
      begin
        v := _SelectVertex[n];
        df := v = f.v[j];
        if df then Break;
      end;
      if not df then Break;
    end;
    if df then
    begin
      for j := 0 to 2 do
      if f.e[j] <> nil then DeleteEdge(f.e[j]);
      DeleteFace(f);
    end;
  end;
  for i := Component.Edges.Count - 1 downto 0 do
  begin
    e := Component.Edges[i];
    for j := 0 to 1 do
    begin
      de := False;
      for n := 0 to _SelectVertex.Count - 1 do
      begin
        de := e.v[j] = _SelectVertex[n];
        if de then Break;
      end;
      if not de then Break;
    end;
    if de then
    begin
      DeleteEdge(e);
    end;
  end;
  SetLength(carr, _SelectVertex[0].c.Count);
  vp := _SelectVertex[0].v;
  if Length(carr) > 0 then
  for i := 0 to High(carr) do
  begin
    carr[i].r := _SelectVertex[0].c[i].r;
    carr[i].g := _SelectVertex[0].c[i].g;
    carr[i].b := _SelectVertex[0].c[i].b;
    carr[i].a := _SelectVertex[0].c[i].a;
  end;
  for i := 1 to _SelectVertex.Count - 1 do
  begin
    vp := vp + _SelectVertex[i].v;
    for j := 0 to High(carr) do
    begin
      carr[j].r := carr[j].r + _SelectVertex[i].c[j].r;
      carr[j].g := carr[j].g + _SelectVertex[i].c[j].g;
      carr[j].b := carr[j].b + _SelectVertex[i].c[j].b;
      carr[j].a := carr[j].a + _SelectVertex[i].c[j].a;
    end;
  end;
  vp := vp * (1 / _SelectVertex.Count);
  CheckFaces;
  for i := 0 to High(carr) do
  begin
    _SelectVertex[0].c[i] := G2Color(
      carr[i].r div _SelectVertex.Count,
      carr[i].g div _SelectVertex.Count,
      carr[i].b div _SelectVertex.Count,
      carr[i].a div _SelectVertex.Count
    );
  end;
  _SelectVertex[0].v := vp;
  for i := _SelectVertex.Count - 1 downto 1 do
  begin
    v := _SelectVertex[i];
    for j := 0 to v.e.Count - 1 do
    begin
      for n := 0 to 1 do
      if v.e[j].v[n] = v then
      v.e[j].v[n] := _SelectVertex[0];
    end;
    for j := 0 to v.f.Count - 1 do
    begin
      for n := 0 to 2 do
      if v.f[j].v[n] = v then
      v.f[j].v[n] := _SelectVertex[0];
    end;
    DeleteVertex(v);
  end;
  for i := Component.Edges.Count - 1 downto 1 do
  begin
    e0 := Component.Edges[i];
    if (e0.v[0] = nil) or (e0.v[1] = nil) then Continue;
    for j := 0 to i - 1 do
    begin
      e1 := Component.Edges[j];
      if (e1.v[0] = nil) or (e1.v[1] = nil) then Continue;
      if e1.Contains(e0.v[0]) and e1.Contains(e0.v[1]) then
      begin
        DeleteEdge(e0);
        Break;
      end;
    end;
  end;
  v := _SelectVertex[0];
  _SelectVertex.Clear;
  _SelectFace.Clear;
  _SelectEdge.Clear;
  _SelectVertex.Add(v);
  Component.CompleteData;
  VerifyMesh;
end;

procedure TScene2DEditorPoly.OnSplitClick(const Display: Pointer);
  var e, e0, e1: TScene2DComponentDataPolyEdge;
  var f0, f1: TScene2DComponentDataPolyFace;
  var v, v0: TScene2DComponentDataPolyVertex;
  var i, j, n: Integer;
  var EdgesToSplit: array of TScene2DComponentDataPolyEdge;
begin
  if not (
    (EditMode = em_edge)
    and (_SelectEdge.Count > 0)
  ) then Exit;
  SetLength(EdgesToSplit, _SelectEdge.Count);
  for n := 0 to _SelectEdge.Count - 1 do
  EdgesToSplit[n] := _SelectEdge[n];
  for n := 0 to High(EdgesToSplit) do
  begin
    e0 := EdgesToSplit[n];
    v := TScene2DComponentDataPolyVertex.Create;
    v.c.Allocate(Component.Layers.Count);
    v.v := (e0.v[0].v + e0.v[1].v) * 0.5;
    for i := 0 to Component.Layers.Count - 1 do
    begin
      v.c[i] := G2Color(
        (e0.v[0].c[i].r + e0.v[1].c[i].r) shr 1,
        (e0.v[0].c[i].g + e0.v[1].c[i].g) shr 1,
        (e0.v[0].c[i].b + e0.v[1].c[i].b) shr 1,
        (e0.v[0].c[i].a + e0.v[1].c[i].a) shr 1
      );
    end;
    Component.Vertices.Add(v);
    e1 := TScene2DComponentDataPolyEdge.Create;
    e1.v[0] := v; e1.v[1] := e0.v[1];
    Component.Edges.Add(e1);
    e0.v[1] := v;
    for i := 0 to 1 do
    if e0.f[i] <> nil then
    begin
      f0 := e0.f[i];
      v0 := f0.VertexOpposite(e0.v[0], e1.v[1]);
      for j := 0 to 2 do
      if f0.v[j] = e1.v[1] then f0.v[j] := v;
      f1 := TScene2DComponentDataPolyFace.Create;
      f1.v[0] := v;
      f1.v[1] := v0;
      f1.v[2] := e1.v[1];
      Component.Faces.Add(f1);
      e := TScene2DComponentDataPolyEdge.Create;
      e.v[0] := v; e.v[1] := v0;
      Component.Edges.Add(e);
    end;
    _SelectEdge.Add(e1);
    Component.CompleteData;
  end;
end;

procedure TScene2DEditorPoly.OnDeleteClick(const Display: Pointer);
  var i: Integer;
begin
  if not (
    ((EditMode = em_vertex) and (_SelectVertex.Count > 0))
    or ((EditMode = em_edge) and (_SelectEdge.Count > 0))
    or ((EditMode = em_face) and (_SelectFace.Count > 0))
  ) then Exit;
  case EditMode of
    em_vertex:
    begin
      for i := 0 to _SelectVertex.Count - 1 do
      DeleteVertex(_SelectVertex[i]);
      VerifyMesh;
    end;
    em_edge:
    begin
      for i := 0 to _SelectEdge.Count - 1 do
      DeleteEdge(_SelectEdge[i]);
      VerifyMesh;
    end;
    em_face:
    begin
      for i := 0 to _SelectFace.Count - 1 do
      DeleteFace(_SelectFace[i]);
      VerifyMesh;
    end;
  end;
  _SelectVertex.Clear;
  _SelectEdge.Clear;
  _SelectFace.Clear;
end;

procedure TScene2DEditorPoly.DeleteVertex(const v: TScene2DComponentDataPolyVertex);
  var i, j: Integer;
begin
  Component.Vertices.Remove(v);
  for i := 0 to v.f.Count - 1 do
  for j := 0 to 2 do
  if v.f[i].v[j] = v then v.f[i].v[j] := nil;
  for i := 0 to v.e.Count - 1 do
  for j := 0 to 1 do
  if v.e[i].v[j] = v then v.e[i].v[j] := nil;
  v.Free;
end;

procedure TScene2DEditorPoly.DeleteEdge(const e: TScene2DComponentDataPolyEdge);
  var i, j: Integer;
begin
  Component.Edges.Remove(e);
  for i := 0 to 1 do
  begin
    if e.v[i] <> nil then e.v[i].e.Remove(e);
    if e.f[i] <> nil then
    for j := 0 to 2 do
    begin
      if e.f[i].e[j] = e then e.f[i].e[j] := nil;
    end;
  end;
  e.Free;
end;

procedure TScene2DEditorPoly.DeleteFace(const f: TScene2DComponentDataPolyFace);
  var i, j: Integer;
begin
  Component.Faces.Remove(f);
  for i := 0 to 2 do
  begin
    if f.v[i] <> nil then f.v[i].f.Remove(f);
    if f.e[i] <> nil then
    begin
      for j := 0 to 1 do
      if f.e[i].f[j] = f then f.e[i].f[j] := nil;
    end;
  end;
  f.Free;
end;

function TScene2DEditorPoly.CheckVertices: Integer;
  var i: Integer;
  var v: TScene2DComponentDataPolyVertex;
begin
  Result := 0;
  for i := Component.Vertices.Count - 1 downto 0 do
  begin
    v := Component.Vertices[i];
    if (v.e.Count < 1) or (v.f.Count < 1) then
    begin
      DeleteVertex(v);
      Inc(Result);
    end;
  end;
end;

function TScene2DEditorPoly.CheckEdges: Integer;
  var i: Integer;
  var e: TScene2DComponentDataPolyEdge;
begin
  Result := 0;
  for i := Component.Edges.Count - 1 downto 0 do
  begin
    e := Component.Edges[i];
    if (e.v[0] = nil)
    or (e.v[1] = nil)
    or ((e.f[0] = nil) and (e.f[1] = nil)) then
    begin
      DeleteEdge(e);
      Inc(Result);
    end;
  end;
end;

function TScene2DEditorPoly.CheckFaces: Integer;
  var i, j: Integer;
  var f: TScene2DComponentDataPolyFace;
begin
  Result := 0;
  for i := Component.Faces.Count - 1 downto 0 do
  begin
    f := Component.Faces[i];
    for j := 0 to 2 do
    if (f.v[j] = nil)
    or (f.e[j] = nil) then
    begin
      DeleteFace(f);
      Inc(Result);
      Break;
    end;
  end;
end;

function TScene2DEditorPoly.CheckMesh: Integer;
begin
  Result := CheckFaces + CheckEdges + CheckVertices;
end;

procedure TScene2DEditorPoly.VerifyMesh;
  var d: Integer;
begin
  repeat
    d := CheckMesh;
  until d = 0;
  Component.CompleteData;
end;

function TScene2DEditorPoly.IsSelecting: Boolean;
begin
  Result := _Drag and (_VDrag.Count = 0);//(_SelectVertex.Count = 0) and (_SelectEdge.Count = 0) and (_SelectFace.Count = 0);
end;

function TScene2DEditorPoly.SelectRect: TG2Rect;
begin
  Result.Left := G2Min(g2.MousePos.x, g2.MouseDownPos[G2MB_Left].x);
  Result.Top := G2Min(g2.MousePos.y, g2.MouseDownPos[G2MB_Left].y);
  Result.Right := G2Max(g2.MousePos.x, g2.MouseDownPos[G2MB_Left].x);
  Result.Bottom := G2Max(g2.MousePos.y, g2.MouseDownPos[G2MB_Left].y);
end;

function TScene2DEditorPoly.SelectRect(const Display: TG2Display2D; var ClipRect: TG2Rect): Boolean;
begin
  ClipRect := SelectRect();
  ClipRect.l := G2Max(ClipRect.l, Display.ViewPort.Left);
  ClipRect.t := G2Max(ClipRect.t, Display.ViewPort.Top);
  ClipRect.r := G2Min(ClipRect.r, Display.ViewPort.Right);
  ClipRect.b := G2Min(ClipRect.b, Display.ViewPort.Bottom);
  Result := (ClipRect.w > 0) and (ClipRect.h > 0);
end;

function TScene2DEditorPoly.AddButton(const Name: String): TBtn;
begin
  Result := TBtn.Create;
  Result.Name := Name;
  Result.OnClick := nil;
  Result.Visible := False;
  Result.MdInButton := False;
  SetLength(Buttons, Length(Buttons) + 1);
  Buttons[High(Buttons)] := Result;
end;

constructor TScene2DEditorPoly.Create;
begin
  inherited Create;
  _Component := nil;
  Instance := Self;
  _PopUp := TSelectList.Create;
  _PopUp.OnSelect := @OnSelectMode;
  _BtnMode := AddButton('vertex');
  _BtnMode.OnClick := @OnModeClick;
  _BtnFlipEdge := AddButton('flip edge');
  _BtnFlipEdge.OnClick := @OnFlipEdgeClick;
  _BtnCollapse := AddButton('collapse');
  _BtnCollapse.OnClick := @OnCollapseClick;
  _BtnSplit := AddButton('split');
  _BtnSplit.OnClick := @OnSplitClick;
  _BtnDelete := AddButton('delete');
  _BtnDelete.OnClick := @OnDeleteClick;
  _BtnColor.Frame := G2Rect(8, -96, 160, 40);
  _BtnColor.MdInButton := False;
  _BtnColor.Visible := False;
  _BrushSizeFrame := G2Rect(8, -144, 160, 40);
end;

destructor TScene2DEditorPoly.Destroy;
  var i: Integer;
begin
  for i := 0 to High(Buttons) do
  Buttons[i].Free;
  _PopUp.Free;
  Instance := nil;
  inherited Destroy;
end;

procedure TScene2DEditorPoly.Update;
begin

end;

procedure TScene2DEditorPoly.Update(const Display: TG2Display2D);
  var i: Integer;
  var d, bs_min, bs_max: TG2Float;
  var varr: array[0..2] of TG2Vec2;
  var v, v0, v1, pv0, pv1, mc, pmc, pn, n: TG2Vec2;
  var xf: TG2Transform2;
  var b: Boolean;
  var c, c1: TG2Color;
  var r, ButtonFrame: TG2Rect;
begin
  _BtnMode.Visible := True;
  case EditMode of
    em_layer: _BtnMode.Name := 'layer ' + IntToStr(EditLayer);
    em_vertex: _BtnMode.Name := 'vertices';
    em_edge: _BtnMode.Name := 'edges';
    em_face: _BtnMode.Name := 'triangles';
    em_tex_coord: _BtnMode.Name := 'tex coord';
  end;
  _BtnFlipEdge.Visible := False;
  if (EditMode = em_face)
  and (_SelectFace.Count = 2) then
  begin
    for i := 0 to 2 do
    if _SelectFace[1].Contains(_SelectFace[0].e[i]) then
    begin
      _BtnFlipEdge.Visible := True;
      Break;
    end;
  end;
  _BtnColor.Visible := EditMode = em_layer;
  _BrushSizeVisible := EditMode = em_layer;
  _BtnDelete.Visible := (
    ((EditMode = em_vertex) and (_SelectVertex.Count > 0))
    or ((EditMode = em_edge) and (_SelectEdge.Count > 0))
    or ((EditMode = em_face) and (_SelectFace.Count > 0))
  );
  _BtnCollapse.Visible := (
    (EditMode = em_vertex)
    and (_SelectVertex.Count > 1)
  );
  _BtnSplit.Visible := (
    (EditMode = em_edge)
    and (_SelectEdge.Count > 0)
  );
  ButtonFrame := G2Rect(8, -48, 160, 40);
  for i := 0 to High(Buttons) do
  if Buttons[i].Visible then
  begin
    Buttons[i].Frame := ButtonFrame;
    ButtonFrame.x := ButtonFrame.x + ButtonFrame.w + 8;
  end;
  pmc := g2.MousePos;
  if not TG2Rect(Display.ViewPort).Contains(pmc) then Exit;
  mc := Display.CoordToDisplay(pmc);
  xf := _Component.Component.Owner.Transform;
  if (EditMode = em_layer)
  and (App.UI.Overlay = nil) then
  begin
    if not _MdInButton
    and (
      g2.MouseDown[G2MB_Left]
      or g2.MouseDown[G2MB_Right]
    ) then
    for i := 0 to Component.Vertices.Count - 1 do
    begin
      v := xf.Transform(Component.Vertices[i].v);
      d := (v - mc).Len;
      if d < _BrushSize then
      begin
        c := Component.Vertices[i].c[EditLayer];
        if g2.MouseDown[G2MB_Left] then
        begin
          c1 := _BrushColor;
        end
        else
        begin
          c1 := c; c1.a := 0;
        end;
        c := G2LerpColor(c, c1, 0.2 * (1 - d / _BrushSize));
        Component.Vertices[i].c[EditLayer] := c;
      end;
    end;
    if g2.MouseDown[G2MB_Left] then
    begin
      if _BrushSizeMd then
      begin
        r := _BrushSizeFrame;
        r.x := Display.ViewPort.Left + r.x;
        r.y := Display.ViewPort.Bottom + r.y;
        r.l := r.l + 12; r.r := r.r - 12;
        bs_min := 0.1 / Display.Zoom;
        bs_max := 10 / Display.Zoom;
        d := bs_max - bs_min;
        _BrushSize := (g2.MousePos.x - r.x) / r.w * d + bs_min;
      end;
    end
    else
    _BrushSizeMd := False;
  end
  else if not _Drag
  and not _MdInButton
  and g2.MouseDown[G2MB_Left]
  and TG2Rect(Display.ViewPort).Contains(g2.MouseDownPos[G2MB_Left])
  and ((G2Vec2(g2.MouseDownPos[G2MB_Left]) - G2Vec2(g2.MousePos)).Len > 2) then
  begin
    StartDrag(xf.TransformInv(mc));
  end;
  if _Drag then
  begin
    if EditMode = em_tex_coord then
    begin
      for i := 0 to _VDrag.Count - 1 do
      _VDrag[i].t := xf.TransformInv(App.Scene2DData.Scene.AdjustToGrid(xf.Transform(xf.TransformInv(mc) + _VOffset[i])))
    end
    else
    begin
      for i := 0 to _VDrag.Count - 1 do
      _VDrag[i].v := xf.TransformInv(App.Scene2DData.Scene.AdjustToGrid(xf.Transform(xf.TransformInv(mc) + _VOffset[i])));
    end;
  end
  else
  begin
    _MOverEdge := nil;
    _MOverVertex := nil;
    _MOverFace := nil;
    if (EditMode = em_vertex)
    or (EditMode = em_tex_coord) then
    for i := 0 to _Component.Vertices.Count - 1 do
    begin
      v := _Component.Vertices[i].v;
      if EditMode = em_tex_coord then v := v + _Component.Vertices[i].t;
      v0 := xf.Transform(v);
      v1 := Display.CoordToScreen(v0);
      v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
      if G2Rect(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2).Contains(mc) then
      _MOverVertex := _Component.Vertices[i];
    end;
    if EditMode = em_edge then
    for i := 0 to _Component.Edges.Count - 1 do
    begin
      v0 := xf.Transform(_Component.Edges[i].v[0].v);
      v1 := xf.Transform(_Component.Edges[i].v[1].v);
      pv0 := Display.CoordToScreen(v0);
      pv1 := Display.CoordToScreen(v1);
      v := G2Project2DPointToLine(pv0, pv1, pmc, b);
      if b and ((pmc - v).LenSq <= 4 * 4) then
      _MOverEdge := _Component.Edges[i];
    end;
    if EditMode = em_face then
    for i := 0 to _Component.Faces.Count - 1 do
    begin
      varr[0] := xf.Transform(_Component.Faces[i].v[0].v);
      varr[1] := xf.Transform(_Component.Faces[i].v[1].v);
      varr[2] := xf.Transform(_Component.Faces[i].v[2].v);
      if G2Vec2InPoly(mc, @varr[0], 3) then
      _MOverFace := _Component.Faces[i];
    end;
  end;
end;

procedure TScene2DEditorPoly.Render(const Display: TG2Display2D);
  var i, j, l: Integer;
  var varr: array[0..2] of TG2Vec2;
  var v, v0, v1, pv0, pv1, mc, pmc, pn, n, t, xp0, xp1: TG2Vec2;
  var xf: TG2Transform2;
  var b: Boolean;
  var c, c1: TG2Color;
  var r: TG2Rect;
  var sr: TRect;
  var tc: array[0..4] of TG2Float;
  var d, bs_min, bs_max: TG2Float;
  var str: AnsiString;
  var bm: TG2BlendMode;
  var LayersSorted: TG2QuickSortList;
  var Layer: TScene2DComponentDataPolyLayer;
  var Sel: Boolean;
begin
  xf := _Component.Component.Owner.Transform;
  LayersSorted.Clear;
  for i := 0 to _Component.Layers.Count - 1 do
  if Assigned(_Component.Layers[i].Texture) then
  LayersSorted.Add(_Component.Layers[i], _Component.Layers[i].Layer);
  for l := 0 to LayersSorted.Count - 1 do
  begin
    Layer := TScene2DComponentDataPolyLayer(LayersSorted[l]);
    Display.PolyBegin(ptTriangles, Layer.Texture, bmNormal, tfLinear);
    for i := 0 to Component.Faces.Count - 1 do
    begin
      for j := 0 to 2 do
      begin
        v := Component.Faces[i].v[j].v;
        c := Component.Faces[i].v[j].c[Layer.Index];
        t := (v + Component.Faces[i].v[j].t) * Layer.Scale;
        v := xf.Transform(v);
        Display.PolyAdd(v, t, c);
      end;
    end;
    Display.PolyEnd;
  end;
  pmc := g2.MousePos;
  mc := Display.CoordToDisplay(pmc);
  for i := 0 to _Component.Edges.Count - 1 do
  begin
    v0 := xf.Transform(_Component.Edges[i].v[0].v);
    v1 := xf.Transform(_Component.Edges[i].v[1].v);
    Display.PrimLine(v0, v1, $ff0000ff);
  end;
  for i := 0 to _Component.Vertices.Count - 1 do
  begin
    v0 := xf.Transform(_Component.Vertices[i].v);
    v1 := Display.CoordToScreen(v0);
    v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
    Display.PrimRect(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ff0000ff);
  end;
  Sel := IsSelecting and SelectRect(Display, r);
  if EditMode = em_vertex then
  begin
    for i := 0 to _SelectVertex.Count - 1 do
    begin
      v0 := xf.Transform(_SelectVertex[i].v);
      v1 := Display.CoordToScreen(v0);
      v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
      Display.PrimRect(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ff008800);
    end;
    if (_MOverVertex <> nil) then
    begin
      v0 := xf.Transform(_MOverVertex.v);
      v1 := Display.CoordToScreen(v0);
      v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
      Display.PrimRectHollow(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ffff0000);
    end;
    if Sel then
    begin
      for i := 0 to _Component.Vertices.Count - 1 do
      begin
        v0 := xf.Transform(_Component.Vertices[i].v);
        v1 := Display.CoordToScreen(v0);
        if r.Contains(v1) then
        begin
          v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
          Display.PrimRectHollow(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ffff0000);
        end;
      end;
    end;
  end;
  if EditMode = em_tex_coord then
  begin
    for i := 0 to _Component.Vertices.Count - 1 do
    begin
      v0 := xf.Transform(_Component.Vertices[i].v);
      v1 := xf.Transform(_Component.Vertices[i].v + _Component.Vertices[i].t);
      Display.PolyBegin(ptLines, App.UI.TexDots);
      Display.PolyAdd(v0, G2Vec2(0, 0.5), $ff008000);
      Display.PolyAdd(v1, G2Vec2((Display.CoordToScreen(v1) - Display.CoordToScreen(v0)).Len * 0.125, 0.5), $80008000);
      Display.PolyEnd;
      v0 := xf.Transform(_Component.Vertices[i].v + _Component.Vertices[i].t);
      v1 := Display.CoordToScreen(v0);
      v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
      Display.PrimRect(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ff008000);
    end;
    for i := 0 to _SelectVertex.Count - 1 do
    begin
      v0 := xf.Transform(_SelectVertex[i].v + _SelectVertex[i].t);
      v1 := Display.CoordToScreen(v0);
      v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
      Display.PrimRect(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ff00ff00);
    end;
    if (_MOverVertex <> nil) then
    begin
      v0 := xf.Transform(_MOverVertex.v + _MOverVertex.t);
      v1 := Display.CoordToScreen(v0);
      v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
      Display.PrimRectHollow(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ffff0000);
    end;
    if Sel then
    begin
      for i := 0 to _Component.Vertices.Count - 1 do
      begin
        v0 := xf.Transform(_Component.Vertices[i].v + _Component.Vertices[i].t);
        v1 := Display.CoordToScreen(v0);
        if r.Contains(v1) then
        begin
          v1 := Display.CoordToDisplay(v1 + G2Vec2(4, 4)) - v0;
          Display.PrimRectHollow(v0.x - v1.x, v0.y - v1.y, v1.x * 2, v1.y * 2, $ffff0000);
        end;
      end;
    end;
  end;
  if (EditMode = em_edge) then
  begin
    for i := 0 to _SelectEdge.Count - 1 do
    begin
      v0 := xf.Transform(_SelectEdge[i].v[0].v);
      v1 := xf.Transform(_SelectEdge[i].v[1].v);
      pv0 := Display.CoordToScreen(v0);
      pv1 := Display.CoordToScreen(v1);
      pn := (pv1 - pv0).Perp.Norm * 2;
      n := Display.CoordToDisplay(pv0 + pn) - v0;
      Display.PrimQuad(v0 - n, v1 - n, v0 + n, v1 + n, $ff008800);
    end;
    if (_MOverEdge <> nil) then
    begin
      v0 := xf.Transform(_MOverEdge.v[0].v);
      v1 := xf.Transform(_MOverEdge.v[1].v);
      pv0 := Display.CoordToScreen(v0);
      pv1 := Display.CoordToScreen(v1);
      pn := (pv1 - pv0).Perp.Norm * 2;
      n := Display.CoordToDisplay(pv0 + pn) - v0;
      Display.PrimQuadHollowCol(v0 - n, v1 - n, v0 + n, v1 + n, $ffff0000, $ffff0000, $ffff0000, $ffff0000);
    end;
    if Sel then
    begin
      for i := 0 to _Component.Edges.Count - 1 do
      begin
        v0 := xf.Transform(_Component.Edges[i].v[0].v);
        v1 := xf.Transform(_Component.Edges[i].v[1].v);
        pv0 := Display.CoordToScreen(v0);
        pv1 := Display.CoordToScreen(v1);
        if G2Intersect2DSegmentVsRect(pv0, pv1, r, xp0, xp1) then
        begin
          pn := (pv1 - pv0).Perp.Norm * 2;
          n := Display.CoordToDisplay(pv0 + pn) - v0;
          Display.PrimQuadHollowCol(v0 - n, v1 - n, v0 + n, v1 + n, $ffff0000, $ffff0000, $ffff0000, $ffff0000);
        end;
      end;
    end;
  end;
  if (EditMode = em_face) then
  begin
    for i := 0 to _SelectFace.Count - 1 do
    begin
      varr[0] := xf.Transform(_SelectFace[i].v[0].v);
      varr[1] := xf.Transform(_SelectFace[i].v[1].v);
      varr[2] := xf.Transform(_SelectFace[i].v[2].v);
      Display.PrimTriCol(varr[0], varr[1], varr[2], $88008800, $88008800, $88008800);
    end;
    if (_MOverFace <> nil) then
    begin
      varr[0] := xf.Transform(_MOverFace.v[0].v);
      varr[1] := xf.Transform(_MOverFace.v[1].v);
      varr[2] := xf.Transform(_MOverFace.v[2].v);
      Display.PrimTriHollowCol(varr[0], varr[1], varr[2], $ffff0000, $ffff0000, $ffff0000);
    end;
    if Sel then
    begin
      for i := 0 to _Component.Faces.Count - 1 do
      begin
        varr[0] := Display.CoordToScreen(xf.Transform(_Component.Faces[i].v[0].v));
        varr[1] := Display.CoordToScreen(xf.Transform(_Component.Faces[i].v[1].v));
        varr[2] := Display.CoordToScreen(xf.Transform(_Component.Faces[i].v[2].v));
        if G2RectVsTri(r, @varr[0]) then
        begin
          g2.PrimTriHollowCol(varr[0], varr[1], varr[2], $ffff0000, $ffff0000, $ffff0000);
        end;
      end;
    end;
  end;
  if (EditMode = em_layer) then
  begin
    Display.PrimCircleHollow(mc, _BrushSize, $ffff0000, 32);
  end;
  if IsSelecting then
  begin
    sr.Left := G2Min(g2.MousePos.x, g2.MouseDownPos[G2MB_Left].x);
    sr.Top := G2Min(g2.MousePos.y, g2.MouseDownPos[G2MB_Left].y);
    sr.Right := G2Max(g2.MousePos.x, g2.MouseDownPos[G2MB_Left].x);
    sr.Bottom := G2Max(g2.MousePos.y, g2.MouseDownPos[G2MB_Left].y);
    tc[0] := 0 + G2TimeInterval();
    tc[1] := tc[0] + (sr.Right - sr.Left) * 0.05;
    tc[2] := tc[1] + (sr.Bottom - sr.Top) * 0.05;
    tc[3] := tc[2] + (sr.Right - sr.Left) * 0.05;
    tc[4] := tc[3] + (sr.Bottom - sr.Top) * 0.05;
    c := G2LerpColor($ffffffff, $ff80ff80, Sin(G2PiTime(400)) * 0.5 + 0.5);
    bm.AlphaDst := boOne;
    bm.AlphaSrc := boOne;
    bm.ColorDst := boInvSrcAlpha;
    bm.ColorSrc := boInvDstColor;
    g2.PolyBegin(ptLines, App.UI.TexDots, bm, tfLinear);
    g2.PolyAdd(sr.Right, sr.Top, tc[0], 0, c);
    g2.PolyAdd(sr.Left, sr.Top, tc[1], 0, c);
    g2.PolyAdd(sr.Left, sr.Top, tc[1], 0, c);
    g2.PolyAdd(sr.Left, sr.Bottom, tc[2], 0, c);
    g2.PolyAdd(sr.Left, sr.Bottom, tc[2], 0, c);
    g2.PolyAdd(sr.Right, sr.Bottom, tc[3], 0, c);
    g2.PolyAdd(sr.Right, sr.Bottom, tc[3], 0, c);
    g2.PolyAdd(sr.Right, sr.Top, tc[4], 0, c);
    g2.PolyEnd;
  end;
  if _BrushSizeVisible then
  begin
    r := _BrushSizeFrame;
    r.x := Display.ViewPort.Left + r.x;
    r.y := Display.ViewPort.Bottom + r.y;
    if r.Contains(g2.MousePos)
    and (App.UI.Overlay = nil) then
    begin
      c := $ffa0a0a0;
    end
    else
    begin
      c := $ff808080;
    end;
    App.UI.DrawSpotFrame(r, 8, c);
    str := 'brush size';
    App.UI.Font1.Print(
      Round(r.x + (r.w - App.UI.Font1.TextWidth(str)) * 0.5),
      Round(r.y + 4),
      1, 1, $ff000000, str, bmNormal, tfPoint
    );
    c := $ff404040;
    r.h := 8; r.y := r.y + 24; r.l := r.l + 8; r.r := r.r - 8;
    App.UI.DrawSpotFrame(r, 4, c);
    bs_min := 0.1 / Display.Zoom;
    bs_max := 10 / Display.Zoom;
    d := G2SmoothStep(_BrushSize, bs_min, bs_max);
    r.x := r.x + (r.w - r.h) * d;
    r.w := r.h;
    if (_BrushSize < bs_min) or (_BrushSize > bs_max) then
    c := G2LerpColor($ffc0c0c0, $ffff8080, Abs(Sin(G2PiTime(200))))
    else
    c := $ffc0c0c0;
    App.UI.DrawSpotFrame(r, 4, c);
  end;
  if _BtnColor.Visible then
  begin
    r := _BtnColor.Frame;
    r.x := Display.ViewPort.Left + r.x;
    r.y := Display.ViewPort.Bottom + r.y;
    if r.Contains(g2.MousePos)
    and (App.UI.Overlay = nil) then
    begin
      if _BtnColor.MdInButton then
      begin
        c := $ff404040;
      end
      else
      begin
        c := $ffa0a0a0;
      end;
    end
    else
    begin
      c := $ff808080;
    end;
    App.UI.DrawSpotFrame(r, 8, c);
    r := r.Expand(-8, -8);
    g2.PrimRect(r.x, r.y, r.w, r.h, _BrushColor);
  end;
  for i := 0 to High(Buttons) do
  if Buttons[i].Visible then
  begin
    r := Buttons[i].Frame;
    r.x := Display.ViewPort.Left + r.x;
    r.y := Display.ViewPort.Bottom + r.y;
    if r.Contains(g2.MousePos)
    and (App.UI.Overlay = nil) then
    begin
      if Buttons[i].MdInButton then
      begin
        c := $ff404040;
        c1 := $ffffffff;
      end
      else
      begin
        c := $ffa0a0a0;
        c1 := $ff000000;
      end;
    end
    else
    begin
      c := $ff808080;
      c1 := $ffe0e0e0;
    end;
    App.UI.DrawSpotFrame(r, 8, c);
    str := Buttons[i].Name;
    App.UI.Font1.Print(
      Round(r.x + (r.w - App.UI.Font1.TextWidth(str)) * 0.5),
      Round(r.y + (r.h - App.UI.Font1.TextHeight('A')) * 0.5),
      1, 1, c1, str, bmNormal, tfPoint
    );
  end;
end;

procedure TScene2DEditorPoly.MouseDown(const Display: TG2Display2D; const Button, x, y: Integer);
  var i: Integer;
  var r: TG2Rect;
  var mc: TG2Vec2;
  var xf: TG2Transform2;
begin
  if Button = G2MB_Left then
  begin
    _MdInButton := False;
    for i := 0 to High(Buttons) do
    if Buttons[i].Visible then
    begin
      r := Buttons[i].Frame;
      r.x := Display.ViewPort.Left + r.x;
      r.y := Display.ViewPort.Bottom + r.y;
      Buttons[i].MdInButton := r.Contains(x, y);
      _MdInButton := _MdInButton or Buttons[i].MdInButton;
    end;
    r := _BtnColor.Frame;
    r.x := Display.ViewPort.Left + r.x;
    r.y := Display.ViewPort.Bottom + r.y;
    _BtnColor.MdInButton := r.Contains(x, y);
    _MdInButton := _MdInButton or _BtnColor.MdInButton;
    r := _BrushSizeFrame;
    r.x := Display.ViewPort.Left + r.x;
    r.y := Display.ViewPort.Bottom + r.y;
    _BrushSizeMd := r.Contains(x, y);
    _MdInButton := _MdInButton or _BrushSizeMd;
    xf := Component.Component.Owner.Transform;
    if not _MdInButton then
    begin
      _MdInVertex := _MOverVertex;
      _MdInEdge := _MOverEdge;
      _MdInFace := _MOverFace;
      if (EditMode = em_vertex)
      or (EditMode = em_tex_coord) then
      begin
        if _MdInVertex <> nil then
        begin
          if _SelectVertex.Find(_MdInVertex) > -1 then
          begin
            StartDrag(xf.TransformInv(Display.CoordToDisplay(G2Vec2(x, y))));
          end
          else
          begin
            if not (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then _SelectVertex.Clear;
            _SelectVertex.Add(_MdInVertex);
          end;
        end
        else
        begin
          if not g2.KeyDown[G2K_CtrlL] and not g2.KeyDown[G2K_CtrlR] then _SelectVertex.Clear;
        end;
      end;
      if EditMode = em_edge then
      begin
        if _MdInEdge <> nil then
        begin
          if _SelectEdge.Find(_MdInEdge) > -1 then
          begin
            StartDrag(xf.TransformInv(Display.CoordToDisplay(G2Vec2(x, y))));
          end
          else
          begin
            if not (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then _SelectEdge.Clear;
            _SelectEdge.Add(_MdInEdge);
          end;
        end
        else
        begin
          if not g2.KeyDown[G2K_CtrlL] and not g2.KeyDown[G2K_CtrlR] then _SelectEdge.Clear;
        end;
      end;
      if EditMode = em_face then
      begin
        if (_MdInFace <> nil) then
        begin
          if _SelectFace.Find(_MdInFace) > -1 then
          begin
            StartDrag(xf.TransformInv(Display.CoordToDisplay(G2Vec2(x, y))));
          end
          else
          begin
            if not (g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR]) then _SelectFace.Clear;
            _SelectFace.Add(_MdInFace);
          end;
        end
        else
        begin
          if not g2.KeyDown[G2K_CtrlL] and not g2.KeyDown[G2K_CtrlR] then _SelectFace.Clear;
        end;
      end;
    end;
  end;
end;

procedure TScene2DEditorPoly.MouseUp(const Display: TG2Display2D; const Button, x, y: Integer);
  var i, j: Integer;
  var r: TG2Rect;
  var xf: TG2Transform2;
  var v0, v1, xp0, xp1: TG2Vec2;
  var varr: array[0..2] of TG2Vec2;
  var AddSelection: Boolean;
  var cd: TColorDialog;
begin
  if Button = G2MB_Left then
  begin
    _MdInButton := False;
    if not _Drag then
    begin
      if _BtnColor.Visible
      and _BtnColor.MdInButton then
      begin
        r := _BtnColor.Frame;
        r.x := Display.ViewPort.Left + r.x;
        r.y := Display.ViewPort.Bottom + r.y;
        if r.Contains(x, y) then
        begin
          cd := TColorDialog.Create(nil);
          cd.Color := G2ColorToSysColor(_BrushColor);
          if cd.Execute then
          begin
            _BrushColor := SysColorToG2Color(cd.Color);
          end;
          cd.Free;
        end;
      end;
      for i := 0 to High(Buttons) do
      if Buttons[i].Visible
      and Buttons[i].MdInButton
      and Assigned(Buttons[i].OnClick) then
      begin
        r := Buttons[i].Frame;
        r.x := Display.ViewPort.Left + r.x;
        r.y := Display.ViewPort.Bottom + r.y;
        if r.Contains(x, y) then Buttons[i].OnClick(Display);
      end;
      if (_MdInVertex <> nil)
      and (_MOverVertex = _MdInVertex) then
      begin

      end
      else if (_MdInEdge <> nil)
      and (_MOverEdge = _MdInEdge) then
      begin

      end
      else if (_MdInFace <> nil)
      and (_MOverFace = _MdInFace) then
      begin

      end;
    end;
    if IsSelecting and SelectRect(Display, r) then
    begin
      xf := _Component.Component.Owner.Transform;
      case EditMode of
        em_vertex,
        em_tex_coord:
        begin
          for i := 0 to _Component.Vertices.Count - 1 do
          begin
            v0 := _Component.Vertices[i].v;
            if EditMode = em_tex_coord then v0 := v0 + _Component.Vertices[i].t;
            v0 := xf.Transform(v0);
            v1 := Display.CoordToScreen(v0);
            if r.Contains(v1) then
            begin
              AddSelection := True;
              for j := 0 to _SelectVertex.Count - 1 do
              if _SelectVertex[j] = _Component.Vertices[i] then
              begin
                AddSelection := False;
                Break;
              end;
              if AddSelection then
              begin
                _SelectVertex.Add(_Component.Vertices[i]);
              end;
            end;
          end;
        end;
        em_edge:
        begin
          for i := 0 to _Component.Edges.Count - 1 do
          begin
            v0 := Display.CoordToScreen(xf.Transform(_Component.Edges[i].v[0].v));
            v1 := Display.CoordToScreen(xf.Transform(_Component.Edges[i].v[1].v));
            if G2Intersect2DSegmentVsRect(v0, v1, r, xp0, xp1) then
            begin
              AddSelection := True;
              for j := 0 to _SelectEdge.Count - 1 do
              if _SelectEdge[j] = _Component.Edges[i] then
              begin
                AddSelection := False;
                Break;
              end;
              if AddSelection then
              begin
                _SelectEdge.Add(_Component.Edges[i]);
              end;
            end;
          end;
        end;
        em_face:
        begin
          for i := 0 to _Component.Faces.Count - 1 do
          begin
            varr[0] := Display.CoordToScreen(xf.Transform(_Component.Faces[i].v[0].v));
            varr[1] := Display.CoordToScreen(xf.Transform(_Component.Faces[i].v[1].v));
            varr[2] := Display.CoordToScreen(xf.Transform(_Component.Faces[i].v[2].v));
            if G2RectVsTri(r, @varr[0]) then
            begin
              AddSelection := True;
              for j := 0 to _SelectFace.Count - 1 do
              if _SelectFace[j] = _Component.Faces[i] then
              begin
                AddSelection := False;
                Break;
              end;
              if AddSelection then
              begin
                _SelectFace.Add(_Component.Faces[i]);
              end;
            end;
          end;
        end;
      end;
    end;
    _Drag := False;
    _MdInVertex := nil;
    _MdInEdge := nil;
    _MdInFace := nil;
  end;
end;

procedure TScene2DEditorPoly.KeyDown(const Key: Integer);
begin
  if (Key = G2K_Delete)
  and (_BtnDelete.Visible) then
  OnDeleteClick(nil);
end;

procedure TScene2DEditorPoly.Initialize;
begin
  EditMode := em_vertex;
  EditLayer := -1;
  _MOverVertex := nil;
  _MOverEdge := nil;
  _MOverFace := nil;
  _MdInVertex := nil;
  _MdInEdge := nil;
  _MdInFace := nil;
  _SelectVertex.Clear;
  _SelectEdge.Clear;
  _SelectFace.Clear;
  _VDrag.Clear;
  _Drag := False;
  _BrushColor := $ffffffff;
  _BrushSize := 1;
  _BrushSizeMd := False;
  _PrevDebugRender := Component.Component.DebugRender;
  Component.Component.DebugRender := False;
  Component.Component.Visible := False;
end;

procedure TScene2DEditorPoly.Finalize;
begin
  Component.UpdateComponent;
  Component.Component.DebugRender := _PrevDebugRender;
  Component.Component.Visible := True;
  inherited Finalize;
end;
//TScene2DEditorPoly END

//TScene2DEditorJointDistance BEGIN
function TScene2DEditorJointDistance.GetJointDrawPos(const Display: TG2Display2D): TG2Vec2;
begin
  if (_Joint.RigidBodyA = nil)
  and (_Joint.RigidBodyB = nil) then
  begin
    Result := Display.CoordToScreen(_Joint.Position);
  end
  else if _Joint.RigidBodyB = nil then
  begin
    Result := Display.CoordToScreen(_Joint.RigidBodyA.GetWorldPoint(_Joint.AnchorA));
    Result.x := Result.x + 16;
  end
  else
  begin
    Result := Display.CoordToScreen(
      (_Joint.RigidBodyA.GetWorldPoint(_Joint.AnchorA) + _Joint.RigidBodyB.GetWorldPoint(_Joint.AnchorB)) * 0.5
    );
  end;
end;

procedure TScene2DEditorJointDistance.OnDeleteJoint;
  var j: TG2Scene2DJoint;
begin
  j := _Joint.Joint;
  App.Scene2DData.DeleteJoint(j);
  Joint := nil;
  App.Scene2DData.Editor := nil;
end;

procedure TScene2DEditorJointDistance.OnDetachA;
  var v: TG2Vec2;
begin
  if Joint.RigidBodyB <> nil then
  begin
    Joint.RigidBodyA := Joint.RigidBodyB;
    Joint.AnchorA := Joint.AnchorB;
    Joint.RigidBodyB := nil;
    Joint.AnchorB.SetZero;
  end
  else
  begin
    v := Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA);
    Joint.Position := v;
    Joint.RigidBodyA := nil;
    Joint.AnchorA.SetZero;
  end;
end;

procedure TScene2DEditorJointDistance.OnDetachB;
begin
  Joint.RigidBodyB := nil;
  Joint.AnchorB.SetZero;
end;

constructor TScene2DEditorJointDistance.Create;
begin
  inherited Create;
  Instance := Self;
  _PopUp := TOverlayPopUp.Create;
end;

destructor TScene2DEditorJointDistance.Destroy;
begin
  _PopUp.Free;
  Instance := nil;
  inherited Destroy;
end;

procedure TScene2DEditorJointDistance.Update(const Display: TG2Display2D);
  var v, v0: TG2Vec2;
  var e: TG2Scene2DEntity;
  var rb: TG2Scene2DComponentRigidBody;
  var i: Integer;
begin
  _CanConnect := False;
  case _ActionType of
    jdat_drag_joint:
    begin
      v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
      _Joint.Position := v;
      e := App.Scene2DData.Pick(v);
      if e <> nil then
      begin
        rb := TG2Scene2DComponentRigidBody(e.ComponentOfType[TG2Scene2DComponentRigidBody]);
        if rb <> nil then
        begin
          _CanConnect := (Joint.RigidBodyA = nil) or (Joint.RigidBodyA.Component <> rb);
        end;
      end;
      if not _CanConnect then
      for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
      begin
        e := App.Scene2DData.Scene.Entities[i];
        if e.ComponentOfType[TG2Scene2DComponentRigidBody] <> nil then
        begin
          v0 := Display.CoordToScreen(e.Transform.p);
          if (v0 - g2.MousePos).Len < 10 then
          begin
            _CanConnect := True;
            Break;
          end;
        end;
      end;
    end;
    jdat_drag_anchor_a:
    begin
      v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
      _Joint.AnchorA := _Joint.RigidBodyA.GetLocalPoint(v);
    end;
    jdat_drag_anchor_b:
    begin
      v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
      _Joint.AnchorB := _Joint.RigidBodyB.GetLocalPoint(v);
    end;
    else
    begin
      if (Joint.RigidBodyA = nil)
      and (Joint.RigidBodyB = nil) then
      begin
      end
      else if Joint.RigidBodyB = nil then
      begin
        Joint.Position := Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA);
      end
      else
      begin
        Joint.Position := (Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA) + Joint.RigidBodyB.GetWorldPoint(Joint.AnchorB)) * 0.5;
      end;
    end;
  end;
end;

procedure TScene2DEditorJointDistance.Render(const Display: TG2Display2D);
  var v, v0: TG2Vec2;
begin
  if (Joint.RigidBodyA = nil)
  and (Joint.RigidBodyB = nil) then
  begin
    v := Display.CoordToScreen(Joint.Position);
    if _ActionType = jdat_drag_joint then
    begin
      if _CanConnect then
      g2.PrimCircleHollow(v, 10, G2LerpColor($ff00ff00, $ff008800, Sin(G2PiTime(300)) * 0.5 + 0.5))
      else
      g2.PrimCircleHollow(v, 10, G2LerpColor($ffff0000, $ff880000, Sin(G2PiTime(300)) * 0.5 + 0.5));
    end
    else
    g2.PrimRectHollow(v.x - 10, v.y - 10, 20, 20, $ffff0000);
  end
  else if (Joint.RigidBodyB = nil) then
  begin
    if _ActionType = jdat_drag_joint then
    begin
      v0 := Display.CoordToScreen(Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA));
      v := Display.CoordToScreen(Joint.Position);
      g2.Gfx.Poly2D.PolyBegin(ptLines, App.UI.TexDots);
      g2.Gfx.Poly2D.PolyAdd(v0, G2Vec2(0, 0.5), $ffff0000);
      g2.Gfx.Poly2D.PolyAdd(v, G2Vec2((v0 - v).Len * 0.05, 0.5), $ffff0000);
      g2.Gfx.Poly2D.PolyEnd;
      if _CanConnect then
      g2.PrimCircleHollow(v, 10, G2LerpColor($ff00ff00, $ff008800, Sin(G2PiTime(300)) * 0.5 + 0.5))
      else
      g2.PrimCircleHollow(v, 10, G2LerpColor($ffff0000, $ff880000, Sin(G2PiTime(300)) * 0.5 + 0.5));
    end
    else
    begin
      v := Display.CoordToScreen(Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA));
      v.x := v.x + 16;
      g2.PrimRectHollow(v.x - 10, v.y - 10, 20, 20, $ffff0000);
    end;
  end
  else
  begin
    v := Display.CoordToScreen((Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA) + Joint.RigidBodyB.GetWorldPoint(Joint.AnchorB)) * 0.5);
    g2.PrimRectHollow(v.x - 10, v.y - 10, 20, 20, $ffff0000);
  end;
end;

procedure TScene2DEditorJointDistance.MouseDown(const Display: TG2Display2D; const Button, x, y: Integer);
  var v: TG2Vec2;
begin
  if Button <> G2MB_Left then Exit;
  if (
    (_Joint.RigidBodyA = nil)
    or (_Joint.RigidBodyB = nil)
  )
  and _Joint.Select(Display, x, y) then
  begin
    _ActionType := jdat_drag_joint;
    _CanConnect := False;
    Exit;
  end;
  if _Joint.RigidBodyA <> nil then
  begin
    v := Display.CoordToScreen(_Joint.RigidBodyA.GetWorldPoint(_Joint.AnchorA));
    if G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(x, y) then
    begin
      _ActionType := jdat_drag_anchor_a;
      Exit;
    end;
  end;
  if _Joint.RigidBodyB <> nil then
  begin
    v := Display.CoordToScreen(_Joint.RigidBodyB.GetWorldPoint(_Joint.AnchorB));
    if G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(x, y) then
    begin
      _ActionType := jdat_drag_anchor_b;
      Exit;
    end;
  end;
  App.Scene2DData.Editor := nil;
end;

procedure TScene2DEditorJointDistance.MouseUp(const Display: TG2Display2D; const Button, x, y: Integer);
  var rb: TG2Scene2DComponentRigidBody;
  var v, v0, v1: TG2Vec2;
  var e, e0: TG2Scene2DEntity;
  var i: Integer;
begin
  case Button of
    G2MB_Left:
    begin
      if _ActionType = jdat_drag_joint then
      begin
        v := Display.CoordToDisplay(g2.MousePos);
        _Joint.Position := v;
        e := App.Scene2DData.Pick(v);
        if e = nil then
        for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
        begin
          e0 := App.Scene2DData.Scene.Entities[i];
          if e0.ComponentOfType[TG2Scene2DComponentRigidBody] <> nil then
          begin
            v0 := Display.CoordToScreen(e0.Transform.p);
            if (v0 - g2.MousePos).Len < 10 then
            begin
              e := e0;
              Break;
            end;
          end;
        end;
        if e <> nil then
        begin
          rb := TG2Scene2DComponentRigidBody(e.ComponentOfType[TG2Scene2DComponentRigidBody]);
          if rb <> nil then
          begin
            if _Joint.RigidBodyA = nil then
            begin
              _Joint.RigidBodyA := TScene2DComponentDataRigidBody(rb.UserData);
              _Joint.AnchorA := _Joint.RigidBodyA.GetLocalPoint(v);
            end
            else if TScene2DComponentDataRigidBody(rb.UserData) <> _Joint.RigidBodyA then
            begin
              _Joint.RigidBodyB := TScene2DComponentDataRigidBody(rb.UserData);
              _Joint.AnchorB := _Joint.RigidBodyB.GetLocalPoint(v);
            end;
          end;
        end;
      end;
      _ActionType := jdat_idle;
    end;
    G2MB_Right:
    begin
      v := GetJointDrawPos(Display);
      if Joint.RigidBodyA <> nil then
      v0 := Display.CoordToScreen(Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA));
      if Joint.RigidBodyB <> nil then
      v1 := Display.CoordToScreen(Joint.RigidBodyB.GetWorldPoint(Joint.AnchorB));
      if G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(x, y) then
      begin
        _PopUp.Clear;
        _PopUp.AddButton('Delete', @OnDeleteJoint);
        _PopUp.Show(G2Vec2(x, y));
      end
      else if (Joint.RigidBodyA <> nil)
      and (G2Rect(v0.x - 8, v0.y - 8, 16, 16).Contains(x, y)) then
      begin
        _PopUp.Clear;
        _PopUp.AddButton('Detach', @OnDetachA);
        _PopUp.Show(G2Vec2(x, y));
      end
      else if (Joint.RigidBodyB <> nil)
      and (G2Rect(v1.x - 8, v1.y - 8, 16, 16).Contains(x, y)) then
      begin
        _PopUp.Clear;
        _PopUp.AddButton('Detach', @OnDetachB);
        _PopUp.Show(G2Vec2(x, y));
      end;
    end;
  end;
end;

procedure TScene2DEditorJointDistance.KeyDown(const Key: Integer);
begin
  if Key = G2K_Delete then OnDeleteJoint;
end;

procedure TScene2DEditorJointDistance.Initialize;
begin
  inherited Initialize;
  _ActionType := jdat_idle;
  _CanConnect := False;
end;
//TScene2DEditorJointDistance END

//TScene2DEditorJointRevolute BEGIN
function TScene2DEditorJointRevolute.GetJointDrawPos(const Display: TG2Display2D): TG2Vec2;
begin
  Result := Display.CoordToScreen(Joint.Position);
end;

procedure TScene2DEditorJointRevolute.OnDeleteJoint;
  var j: TG2Scene2DJoint;
begin
  j := _Joint.Joint;
  App.Scene2DData.DeleteJoint(j);
  Joint := nil;
  App.Scene2DData.Editor := nil;
end;

procedure TScene2DEditorJointRevolute.OnDetachA;
begin

end;

procedure TScene2DEditorJointRevolute.OnDetachB;
begin

end;

constructor TScene2DEditorJointRevolute.Create;
begin
  inherited Create;
  Instance := Self;
  _PopUp := TOverlayPopUp.Create;
end;

destructor TScene2DEditorJointRevolute.Destroy;
begin
  _PopUp.Free;
  Instance := nil;
  inherited Destroy;
end;

procedure TScene2DEditorJointRevolute.Update(const Display: TG2Display2D);
  var v, v0: TG2Vec2;
  var e: TG2Scene2DEntity;
  var rb: TG2Scene2DComponentRigidBody;
  var i: Integer;
begin
  _CanConnect := False;
  case _ActionType of
    jrat_drag_joint:
    begin
      v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
      _Joint.Position := v;
    end;
    jrat_drag_anchor_a,
    jrat_drag_anchor_b:
    begin
      v := App.Scene2DData.Scene.AdjustToGrid(Display.CoordToDisplay(g2.MousePos));
      e := App.Scene2DData.Pick(v);
      if e <> nil then
      begin
        rb := TG2Scene2DComponentRigidBody(e.ComponentOfType[TG2Scene2DComponentRigidBody]);
        if rb <> nil then
        begin
          _CanConnect := (Joint.RigidBodyA = nil) or (Joint.RigidBodyA.Component <> rb);
        end;
      end;
      if not _CanConnect then
      for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
      begin
        e := App.Scene2DData.Scene.Entities[i];
        if e.ComponentOfType[TG2Scene2DComponentRigidBody] <> nil then
        begin
          v0 := Display.CoordToScreen(e.Transform.p);
          if (v0 - g2.MousePos).Len < 10 then
          begin
            _CanConnect := True;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TScene2DEditorJointRevolute.Render(const Display: TG2Display2D);
  var v, v0: TG2Vec2;
  var c: TG2Color;
  function GetRigidBodyPos(const RigidBody: TScene2DComponentDataRigidBody): TG2Vec2;
    var xf, xfrb: TG2Transform2;
  begin
    xf := RigidBody.Component.Owner.Transform;
    xfrb := RigidBody.Component.Transform;
    G2Transform2Mul(@xf, @xfrb, @xf);
    Result := Display.CoordToScreen(xf.p);
  end;
begin
  v := Display.CoordToScreen(Joint.Position);
  if _ActionType = jrat_drag_anchor_a then
  begin
    v0 := g2.MousePos;
    if _CanConnect then
    g2.PrimCircleHollow(v0.x, v0.y, 10, G2LerpColor($ff00ff00, $ff008800, Sin(G2PiTime(300)) * 0.5 + 0.5))
    else
    g2.PrimCircleHollow(v0.x, v0.y, 10, G2LerpColor($ffff0000, $ff880000, Sin(G2PiTime(300)) * 0.5 + 0.5));
  end
  else
  begin
    v0 := v;
    v0.x := v0.x - 16;
  end;
  if Joint.RigidBodyA <> nil then
  begin
    c := $ff00ff00;
    g2.PrimLine(GetRigidBodyPos(Joint.RigidBodyA), v0, $ffff0000);
  end
  else
  c := $ffff0000;
  g2.PicRect(Round(v0.x - 8), Round(v0.y - 8), 16, 16, c, App.UI.TexPin);
  if _ActionType = jrat_drag_anchor_b then
  begin
    v0 := g2.MousePos;
    if _CanConnect then
    g2.PrimCircleHollow(v0.x, v0.y, 10, G2LerpColor($ff00ff00, $ff008800, Sin(G2PiTime(300)) * 0.5 + 0.5))
    else
    g2.PrimCircleHollow(v0.x, v0.y, 10, G2LerpColor($ffff0000, $ff880000, Sin(G2PiTime(300)) * 0.5 + 0.5));
  end
  else
  begin
    v0 := v;
    v0.x := v0.x + 16;
  end;
  if Joint.RigidBodyB <> nil then
  begin
    c := $ff00ff00;
    g2.PrimLine(GetRigidBodyPos(Joint.RigidBodyB), v0, $ffff0000);
  end
  else
  c := $ffff0000;
  g2.PicRect(Round(v0.x - 8), Round(v0.y - 8), 16, 16, c, App.UI.TexPin);
  if _ActionType = jrat_drag_joint then
  begin
    g2.PrimCircleHollow(v, 10, G2LerpColor($ff00ff00, $ff008800, Sin(G2PiTime(300)) * 0.5 + 0.5))
  end
  else
  g2.PrimRectHollow(v.x - 10, v.y - 10, 20, 20, $ffff0000);
end;

procedure TScene2DEditorJointRevolute.MouseDown(
  const Display: TG2Display2D;
  const Button, x, y: Integer
);
  var v, v0: TG2Vec2;
begin
  if Button <> G2MB_Left then Exit;
  if _Joint.Select(Display, x, y) then
  begin
    _ActionType := jrat_drag_joint;
    _CanConnect := False;
    Exit;
  end;
  v := Display.CoordToScreen(Joint.Position);
  v0 := v; v0.x := v0.x - 16;
  if G2Rect(v0.x - 8, v0.y - 8, 16, 16).Contains(x, y) then
  begin
    _ActionType := jrat_drag_anchor_a;
    _CanConnect := False;
    Exit;
  end;
  v0 := v; v0.x := v0.x + 16;
  if G2Rect(v0.x - 8, v0.y - 8, 16, 16).Contains(x, y) then
  begin
    _ActionType := jrat_drag_anchor_b;
    _CanConnect := False;
    Exit;
  end;
  App.Scene2DData.Editor := nil;
end;

procedure TScene2DEditorJointRevolute.MouseUp(
  const Display: TG2Display2D;
  const Button, x, y: Integer
);
  var rb: TG2Scene2DComponentRigidBody;
  var v, v0, v1: TG2Vec2;
  var e, e0: TG2Scene2DEntity;
  var i: Integer;
begin
  case Button of
    G2MB_Left:
    begin
      if (_ActionType = jrat_drag_joint) then
      begin
        v := Display.CoordToDisplay(g2.MousePos);
        _Joint.Position := v;
      end
      else if (_ActionType = jrat_drag_anchor_a)
      or (_ActionType = jrat_drag_anchor_b) then
      begin
        v := Display.CoordToDisplay(g2.MousePos);
        e := App.Scene2DData.Pick(v);
        if e = nil then
        for i := 0 to App.Scene2DData.Scene.EntityCount - 1 do
        begin
          e0 := App.Scene2DData.Scene.Entities[i];
          if e0.ComponentOfType[TG2Scene2DComponentRigidBody] <> nil then
          begin
            v0 := Display.CoordToScreen(e0.Transform.p);
            if (v0 - g2.MousePos).Len < 10 then
            begin
              e := e0;
              Break;
            end;
          end;
        end;
        if e <> nil then
        begin
          rb := TG2Scene2DComponentRigidBody(e.ComponentOfType[TG2Scene2DComponentRigidBody]);
          if rb <> nil then
          begin
            if _ActionType = jrat_drag_anchor_a then
            begin
              _Joint.RigidBodyA := TScene2DComponentDataRigidBody(rb.UserData);
            end
            else if _ActionType = jrat_drag_anchor_b then
            begin
              _Joint.RigidBodyB := TScene2DComponentDataRigidBody(rb.UserData);
            end;
          end;
        end;
      end;
      _ActionType := jrat_idle;
    end;
    G2MB_Right:
    begin
      v := GetJointDrawPos(Display);
      //if Joint.RigidBodyA <> nil then
      //v0 := Display.CoordToScreen(Joint.RigidBodyA.GetWorldPoint(Joint.AnchorA));
      //if Joint.RigidBodyB <> nil then
      //v1 := Display.CoordToScreen(Joint.RigidBodyB.GetWorldPoint(Joint.AnchorB));
      if G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(x, y) then
      begin
        _PopUp.Clear;
        _PopUp.AddButton('Delete', @OnDeleteJoint);
        _PopUp.Show(G2Vec2(x, y));
      end;
      //else if (Joint.RigidBodyA <> nil)
      //and (G2Rect(v0.x - 8, v0.y - 8, 16, 16).Contains(x, y)) then
      //begin
      //  _PopUp.Clear;
      //  _PopUp.AddButton('Detach', @OnDetachA);
      //  _PopUp.Show(G2Vec2(x, y));
      //end
      //else if (Joint.RigidBodyB <> nil)
      //and (G2Rect(v1.x - 8, v1.y - 8, 16, 16).Contains(x, y)) then
      //begin
      //  _PopUp.Clear;
      //  _PopUp.AddButton('Detach', @OnDetachB);
      //  _PopUp.Show(G2Vec2(x, y));
      //end;
    end;
  end;
end;

procedure TScene2DEditorJointRevolute.KeyDown(const Key: Integer);
begin
  inherited KeyDown(Key);
end;

procedure TScene2DEditorJointRevolute.Initialize;
begin
  inherited Initialize;
end;
//TScene2DEditorJointRevolute END

//TScene2DEntityData BEGIN
constructor TScene2DEntityData.Create(const AEntity: TG2Scene2DEntity);
  var Component: TG2Scene2DComponent;
  var ComponentData: TScene2DComponentData;
  var i: Integer;
begin
  inherited Create;
  Entity := AEntity;
  Selected := False;
  OpenStructure.Clear;
  Properties := TPropertySet.Create;
  SyncProperties;
  AEntity.UserData := Self;
  for i := 0 to Entity.ComponentCount - 1 do
  begin
    Component := Entity.Components[i];
    if Component is TG2Scene2DComponentSprite then
    begin
      ComponentData := TScene2DComponentDataSprite.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataSprite(ComponentData).Component := TG2Scene2DComponentSprite(Component);
    end
    else if Component is TG2Scene2DComponentText then
    begin
      ComponentData := TScene2DComponentDataText.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataText(ComponentData).Component := TG2Scene2DComponentText(Component);
    end
    else if Component is TG2Scene2DComponentBackground then
    begin
      ComponentData := TScene2DComponentDataBackground.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataBackground(ComponentData).Component := TG2Scene2DComponentBackground(Component);
    end
    else if Component is TG2Scene2DComponentSpineAnimation then
    begin
      ComponentData := TScene2DComponentDataSpineAnimation.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataSpineAnimation(ComponentData).Component := TG2Scene2DComponentSpineAnimation(Component);
    end
    else if Component is TG2Scene2DComponentEffect then
    begin
      ComponentData := TScene2DComponentDataEffect.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataEffect(ComponentData).Component := TG2Scene2DComponentEffect(Component);
      if TG2Scene2DComponentEffect(Component).EffectInst <> nil then
      TG2Scene2DComponentEffect(Component).EffectInst.Play;
    end
    else if Component is TG2Scene2DComponentCharacter then
    begin
      ComponentData := TScene2DComponentDataCharacter.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataCharacter(ComponentData).Component := TG2Scene2DComponentCharacter(Component);
    end
    else if Component is TG2Scene2DComponentRigidBody then
    begin
      ComponentData := TScene2DComponentDataRigidBody.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataRigidBody(ComponentData).Component := TG2Scene2DComponentRigidBody(Component);
    end
    else if Component is TG2Scene2DComponentCollisionShapeBox then
    begin
      ComponentData := TScene2DComponentDataShapeBox.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataShapeBox(ComponentData).Component := TG2Scene2DComponentCollisionShapeBox(Component);
    end
    else if Component is TG2Scene2DComponentCollisionShapeChain then
    begin
      ComponentData := TScene2DComponentDataShapeChain.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataShapeChain(ComponentData).Component := TG2Scene2DComponentCollisionShapeChain(Component);
    end
    else if Component is TG2Scene2DComponentCollisionShapeCircle then
    begin
      ComponentData := TScene2DComponentDataShapeCircle.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataShapeCircle(ComponentData).Component := TG2Scene2DComponentCollisionShapeCircle(Component);
    end
    else if Component is TG2Scene2DComponentCollisionShapeEdge then
    begin
      ComponentData := TScene2DComponentDataShapeEdge.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataShapeEdge(ComponentData).Component := TG2Scene2DComponentCollisionShapeEdge(Component);
    end
    else if Component is TG2Scene2DComponentCollisionShapePoly then
    begin
      ComponentData := TScene2DComponentDataShapePoly.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataShapePoly(ComponentData).Component := TG2Scene2DComponentCollisionShapePoly(Component);
    end
    else if Component is TG2Scene2DComponentPoly then
    begin
      ComponentData := TScene2DComponentDataPoly.Create;
      Component.UserData := ComponentData;
      TScene2DComponentDataPoly(ComponentData).Component := TG2Scene2DComponentPoly(Component);
      TScene2DComponentDataPoly(ComponentData).GenerateData;
    end;
  end;
  UpdateProperties;
end;

destructor TScene2DEntityData.Destroy;
begin
  if App.Scene2DData.PropertySet = Properties then
  App.Scene2DData.PropertySet := nil;
  if Selected then
  begin
    App.Scene2DData.SelectionUpdateStart;
    App.Scene2DData.Selection.Remove(Entity);
    App.Scene2DData.SelectionUpdateEnd;
  end;
  Properties.Free;
  inherited Destroy;
end;

procedure TScene2DEntityData.SyncTags;
  var i: Integer;
begin
  EditTags := '';
  for i := 0 to Entity.TagCount - 1 do
  begin
    if i > 0 then EditTags += ', ';
    EditTags += Entity.Tags[i];
  end;
end;

procedure TScene2DEntityData.SyncProperties;
begin
  EditName := Entity.Name;
  EditPosition := Entity.Transform.p;
  EditRotation := Entity.Transform.r.Angle * G2RadToDeg;
  SyncTags;
  if EditRotation < 0 then EditRotation := 360 + EditRotation;
end;

procedure TScene2DEntityData.OnNameChange(const Sender: Pointer);
begin
  Entity.Name := EditName;
end;

procedure TScene2DEntityData.OnPositionChange(const Sender: Pointer);
begin
  Entity.Transform := G2Transform2(EditPosition, Entity.Transform.r);
  App.Scene2DData.UpdateSelectionPos;
end;

procedure TScene2DEntityData.OnRotationChange(const Sender: Pointer);
begin
  Entity.Transform := G2Transform2(Entity.Transform.p, G2Rotation2(EditRotation * G2DegToRad));
  App.Scene2DData.UpdateSelectionPos;
end;

procedure TScene2DEntityData.OnTagsChange(const Sender: Pointer);
begin
  Entity.ParseTags(EditTags);
  SyncTags;
end;

procedure TScene2DEntityData.UpdateProperties;
  var i: Integer;
begin
  Properties.Clear;
  Properties.PropString('Name', @EditName, nil, @OnNameChange);
  Properties.PropString('GUID', @Entity.GUID, nil).Editable := False;
  Properties.PropVec2('Position', @EditPosition, nil, @OnPositionChange);
  Properties.PropFloat('Rotation', @EditRotation, nil, @OnRotationChange);
  Properties.PropString('Tags', @EditTags, nil, @OnTagsChange).AllowEmpty := True;
  for i := 0 to Entity.ComponentCount - 1 do
  TScene2DComponentData(Entity.Components[i].UserData).AddToProperties(Properties);
  Properties.PropButton('Add Component', @App.Scene2DData.BtnAddComponent);
end;
//TScene2DEntityData END

//TScene2DComponentData BEGIN
procedure TScene2DComponentData.SyncTags(const Cmp: TG2Scene2DComponent);
  var i: Integer;
begin
  Tags := '';
  for i := 0 to Cmp.TagCount - 1 do
  begin
    if i > 0 then Tags += ', ';
    Tags += Cmp.Tags[i];
  end;
end;

class function TScene2DComponentData.GetName: String;
begin
  Result := 'Component';
end;

constructor TScene2DComponentData.Create;
begin
  inherited Create;
end;

destructor TScene2DComponentData.Destroy;
begin
  inherited Destroy;
end;

function TScene2DComponentData.PickLayer: Integer;
begin
  Result := 0;
end;

function TScene2DComponentData.Pick(const x, y: TG2Float): Boolean;
begin
  Result := False;
end;

procedure TScene2DComponentData.DebugDraw(const Display: TG2Display2D);
begin

end;

function TScene2DComponentData.PtInComponent(const pt: TG2Vec2): Integer;
begin
  Result := -1;
end;

procedure TScene2DComponentData.AddToProperties(const PropertySet: TPropertySet);
begin

end;
//TScene2DComponentData END

//TScene2DComponentDataSpineAnimation BEGIN
procedure TScene2DComponentDataSpineAnimation.UpdateAnimList;
  var i: Integer;
  var Anim: TSpineAnimation;
begin
  AnimList.Clear;
  AnimList.AddValue('None', 0);
  if Assigned(Component.Skeleton) then
  begin
    for i := 0 to Component.Skeleton.Data.Animations.Count - 1 do
    begin
      Anim := Component.Skeleton.Data.Animations[i];
      AnimList.AddValue(Anim.Name, i + 1);
    end;
  end;
end;

class function TScene2DComponentDataSpineAnimation.GetName: String;
begin
  Result := 'Spine Animation';
end;

destructor TScene2DComponentDataSpineAnimation.Destroy;
begin
  inherited Destroy;
end;

function TScene2DComponentDataSpineAnimation.PickLayer: Integer;
begin
  Result := Component.Layer;
end;

function TScene2DComponentDataSpineAnimation.Pick(const x, y: TG2Float): Boolean;
begin
  Result := False;
end;

procedure TScene2DComponentDataSpineAnimation.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TPropertyComponent;
  var i: Integer;
  var Anim: TSpineAnimation;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Spine Animation', Component);
  Layer := Component.Layer;
  Offset := Component.Offset;
  Scale := Component.Scale;
  Loop := Component.Loop;
  TimeScale := Component.TimeScale;
  AnimIndex := 0;
  SkeletonPath := '';
  if Assigned(Component.Skeleton) then
  begin
    SkeletonPath := Component.Skeleton.Data.Name;
    for i := 0 to Component.Skeleton.Data.Animations.Count - 1 do
    begin
      Anim := Component.Skeleton.Data.Animations[i];
      if Anim.Name = Component.Animation then
      begin
        AnimIndex := i + 1;
        Break;
      end;
    end;
  end;
  PropertySet.PropPath('Skeleton', @SkeletonPath, TAssetAny, Group, @OnSkeletonPathChange);
  PropertySet.PropInt('Layer', @Layer, Group, @OnLayerChange);
  PropertySet.PropVec2('Offset', @Offset, Group, @OnOffsetChange);
  PropertySet.PropVec2('Scale', @Scale, Group, @OnScaleChange);
  AnimList := PropertySet.PropEnum('Animation', @AnimIndex, Group, @OnAnimationChange);
  PropertySet.PropBool('Loop', @Loop, Group, @OnLoopChange);
  PropertySet.PropBool('Flip X', @FlipX, Group, @OnFlipXChange);
  PropertySet.PropBool('Flip Y', @FlipY, Group, @OnFlipYChange);
  PropertySet.PropFloat('Speed', @TimeScale, Group, @OnTimeScaleChange);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  UpdateAnimList;
end;

procedure TScene2DComponentDataSpineAnimation.OnSkeletonPathChange(const Sender: Pointer);
  var AtlasPath: String;
  var Atlas: TSpineAtlas;
  var Skeleton: TSpineSkeleton;
  var sb: TSpineSkeletonBinary;
  var sd: TSpineSkeletonData;
  var al: TSpineAtlasList;
begin
  AtlasPath := G2PathNoExt(SkeletonPath) + '.atlas';
  Atlas := TSpineAtlas.Create(AtlasPath);
  al := TSpineAtlasList.Create;
  al.Add(Atlas);
  sb := TSpineSkeletonBinary.Create(al);
  sd := sb.ReadSkeletonData(SkeletonPath);
  Skeleton := TSpineSkeleton.Create(sd);
  Component.Skeleton := Skeleton;
  Skeleton.Free;
  sd.Free;
  sb.Free;
  al.Free;
  Atlas.Free;
  UpdateAnimList;
end;

procedure TScene2DComponentDataSpineAnimation.OnLayerChange(const Sender: Pointer);
begin
  Component.Layer := Layer;
end;

procedure TScene2DComponentDataSpineAnimation.OnOffsetChange(const Sender: Pointer);
begin
  Component.Offset := Offset;
end;

procedure TScene2DComponentDataSpineAnimation.OnScaleChange(const Sender: Pointer);
begin
  Component.Scale := Scale;
end;

procedure TScene2DComponentDataSpineAnimation.OnAnimationChange(const Sender: Pointer);
begin
  Component.Animation := AnimList[AnimIndex].Name;
end;

procedure TScene2DComponentDataSpineAnimation.OnLoopChange(const Sender: Pointer);
begin
  Component.Loop := Loop;
end;

procedure TScene2DComponentDataSpineAnimation.OnFlipXChange(const Sender: Pointer);
begin
  Component.FlipX := FlipX;
end;

procedure TScene2DComponentDataSpineAnimation.OnFlipYChange(const Sender: Pointer);
begin
  Component.FlipY := FlipY;
end;

procedure TScene2DComponentDataSpineAnimation.OnTimeScaleChange(const Sender: Pointer);
begin
  Component.TimeScale := TimeScale;
end;

procedure TScene2DComponentDataSpineAnimation.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataSpineAnimation END

//TScene2DComponentDataSprite BIEGIN
class function TScene2DComponentDataSprite.GetName: String;
begin
  Result := 'Sprite';
end;

destructor TScene2DComponentDataSprite.Destroy;
begin
  inherited Destroy;
end;

function TScene2DComponentDataSprite.PickLayer: Integer;
begin
  Result := Component.Layer;
end;

function TScene2DComponentDataSprite.Pick(const x, y: TG2Float): Boolean;
  var xf: TG2Transform2;
  var v: array[0..3] of TG2Vec2;
  var tx0, tx1, ty0, ty1: TG2Float;
  var i: Integer;
  var hw, hh: TG2Float;
begin
  if not Assigned(Component.Picture) then Exit(False);
  hw := Component.Width * Component.Scale * 0.5;
  hh := Component.Height * Component.Scale * 0.5;
  v[0].SetValue(-hw, -hh);
  v[1].SetValue(hw, -hh);
  v[2].SetValue(hw, hh);
  v[3].SetValue(-hw, hh);
  xf := Component.Owner.Transform;
  G2Transform2Mul(@xf, @Component.Transform, @xf);
  for i := 0 to High(v) do
  G2Vec2Transform2Mul(@v[i], @v[i], @xf);
  Result := G2Vec2InPoly(G2Vec2(x, y), @v, 4);
end;

procedure TScene2DComponentDataSprite.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var Enum: TPropertySet.TPropertyEnum;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Sprite', Component);
  Layer := Component.Layer;
  PropertySet.PropInt('Layer', @Layer, Group, @OnChangeLayer);
  if Assigned(Component.Picture) then
  ImagePath := Component.Picture.AssetName
  else
  ImagePath := '';
  PropertySet.PropPath('Image', @ImagePath, TAssetImage, Group, @OnChangeImage);
  PropertySet.PropFloat('Width', @Component.Width, Group);
  PropertySet.PropFloat('Height', @Component.Height, Group);
  PropertySet.PropFloat('Scale', @Component.Scale, Group);
  Position := Component.Transform.p;
  Rotation := Component.Transform.r.Angle * G2RadToDeg;
  if Rotation < 0 then Rotation := 360 + Rotation;
  PropertySet.PropVec2('Offset', @Position, Group, @OnChangePosition);
  PropertySet.PropFloat('Rotation', @Rotation, Group, @OnChangeRotation);
  PropertySet.PropBool('Flip X', @Component.FlipX, Group);
  PropertySet.PropBool('Flip Y', @Component.FlipY, Group);
  Enum := PropertySet.PropEnum('Filter', @Component.Filter, Group);
  Enum.AddValue('Point', Byte(tfPoint));
  Enum.AddValue('Linear', Byte(tfLinear));
  PropertySet.PropBlendMode('Blend Mode', @Component.BlendMode, Group);
  Enum.SetValue(Byte(Component.Filter));
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
end;

procedure TScene2DComponentDataSprite.OnChangeLayer(const Sender: Pointer);
begin
  Component.Layer := Layer;
end;

procedure TScene2DComponentDataSprite.OnChangeImage(const Sender: Pointer);
  var sw, sh, ss: Single;
begin
  Component.Picture := App.AssetManager.GetImage(ImagePath);
  if Assigned(Component.Picture) then
  begin
    if Component.Picture.Texture.Width > Component.Picture.Texture.Height then
    begin
      sw := 1;
      sh := Component.Picture.Texture.Height / Component.Picture.Texture.Width;
    end
    else
    begin
      sh := 1;
      sw := Component.Picture.Texture.Width / Component.Picture.Texture.Height;
    end;
    sw := Component.Picture.TexCoords.w * sw;
    sh := Component.Picture.TexCoords.h * sh;
    if sw > sh then
    ss := 1 / sw
    else
    ss := 1 / sh;
    Component.Width := ss * sw;
    Component.Height := ss * sh;
  end;
end;

procedure TScene2DComponentDataSprite.OnChangePosition(const Sender: Pointer);
begin
  Component.Transform.p := Position;
end;

procedure TScene2DComponentDataSprite.OnChangeRotation(const Sender: Pointer);
begin
  Component.Transform.r.Angle := Rotation * G2DegToRad;
end;

procedure TScene2DComponentDataSprite.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataSprite END

//TScene2DComponentDataText BEGIN
class function TScene2DComponentDataText.GetName: String;
begin
  Result := 'Text';
end;

destructor TScene2DComponentDataText.Destroy;
begin
  inherited Destroy;
end;

function TScene2DComponentDataText.PickLayer: Integer;
begin
  Result := Component.Layer;
end;

function TScene2DComponentDataText.Pick(const x, y: TG2Float): Boolean;
  var xf: TG2Transform2;
  var v: array[0..3] of TG2Vec2;
  var w, h: TG2Float;
  var j: Integer;
begin
  if not Assigned(Component.Font) or (Length(Component.Text) = 0) then Exit(False);
  xf := Component.Owner.Transform;
  G2Transform2Mul(@xf, @Component.Transform, @xf);
  w := Component.Width;
  h := Component.Height;
  case Component.AlignH of
    g2al_left: v[0].x := 0;
    g2al_right: v[0].x := -w;
    else v[0].x := -w * 0.5;
  end;
  case Component.AlignV of
    g2al_top: v[0].y := 0;
    g2al_bottom: v[0].y := -h;
    else v[0].y := -h * 0.5;
  end;
  v[2].x := v[0].x + w; v[2].y := v[0].y + h;
  v[1].x := v[2].x; v[1].y := v[0].y;
  v[3].x := v[0].x; v[3].y := v[2].y;
  for j := 0 to 3 do v[j] := xf.Transform(v[j]);
  Result := G2Vec2InPoly(G2Vec2(x, y), @v, 4);
end;

procedure TScene2DComponentDataText.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var Enum: TPropertySet.TPropertyEnum;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Text', Component);
  Layer := Component.Layer;
  PropertySet.PropInt('Layer', @Layer, Group, @OnChangeLayer);
  if Assigned(Component.Font) then
  FontPath := Component.Font.AssetName
  else
  FontPath := '';
  PropertySet.PropPath('Font', @FontPath, TAssetFont, Group, @OnChangeFont);
  PropertySet.PropString('Text', @Component.Text, Group).AllowEmpty := True;
  PropertySet.PropFloat('Scale X', @Component.ScaleX, Group);
  PropertySet.PropFloat('Scale Y', @Component.ScaleY, Group);
  Enum := PropertySet.PropEnum('Align H', @Component.AlignH, Group);
  Enum.AddValue('Left', Byte(g2al_left));
  Enum.AddValue('Center', Byte(g2al_center));
  Enum.AddValue('Right', Byte(g2al_right));
  Enum.SetValue(Byte(Component.AlignH));
  Enum := PropertySet.PropEnum('Align V', @Component.AlignV, Group);
  Enum.AddValue('Top', Byte(g2al_top));
  Enum.AddValue('Middle', Byte(g2al_middle));
  Enum.AddValue('Bottom', Byte(g2al_bottom));
  Enum.SetValue(Byte(Component.AlignV));
  Position := Component.Transform.p;
  Rotation := Component.Transform.r.Angle * G2RadToDeg;
  while Rotation < 0 do Rotation := 360 + Rotation;
  PropertySet.PropVec2('Offset', @Position, Group, @OnChangePosition);
  PropertySet.PropFloat('Rotation', @Rotation, Group, @OnChangeRotation);
  Enum := PropertySet.PropEnum('Filter', @Component.Filter, Group);
  Enum.AddValue('Point', Byte(tfPoint));
  Enum.AddValue('Linear', Byte(tfLinear));
  Enum.SetValue(Byte(Component.Filter));
  PropertySet.PropBlendMode('Blend Mode', @Component.BlendMode, Group);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
end;

procedure TScene2DComponentDataText.OnChangeLayer(const Sender: Pointer);
begin
  Component.Layer := Layer;
end;

procedure TScene2DComponentDataText.OnChangeFont(const Sender: Pointer);
begin
  Component.Font := App.AssetManager.GetFont(FontPath);
end;

procedure TScene2DComponentDataText.OnChangePosition(const Sender: Pointer);
begin
  Component.Transform.p := Position;
end;

procedure TScene2DComponentDataText.OnChangeRotation(const Sender: Pointer);
begin
  Component.Transform.r.Angle := Rotation * G2DegToRad;
end;

procedure TScene2DComponentDataText.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataText END

//TScene2DComponentDataBackground BEGIN
class function TScene2DComponentDataBackground.GetName: String;
begin
  Result := 'Background';
end;

destructor TScene2DComponentDataBackground.Destroy;
begin

end;

procedure TScene2DComponentDataBackground.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var Enum: TPropertySet.TPropertyEnum;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Background', Component);
  Layer := Component.Layer;
  PropertySet.PropInt('Layer', @Layer, Group, @OnChangeLayer);
  if Component.Texture <> nil then
  TexturePath := Component.Texture.AssetName
  else
  TexturePath := '';
  PropertySet.PropPath('Texture', @TexturePath, TAssetTexture, Group, @OnChangeTexture);
  PropertySet.PropVec2('Scale', @Component.Scale, Group);
  PropertySet.PropVec2('ScrollSpeed', @Component.ScrollSpeed, Group);
  PropertySet.PropBool('Flip X', @Component.FlipX, Group);
  PropertySet.PropBool('Flip Y', @Component.FlipY, Group);
  PropertySet.PropBool('Repeat X', @Component.RepeatX, Group);
  PropertySet.PropBool('Repeat Y', @Component.RepeatY, Group);
  Enum := PropertySet.PropEnum('Filter', @Component.Filter, Group);
  Enum.AddValue('Point', Byte(tfPoint));
  Enum.AddValue('Linear', Byte(tfLinear));
  Enum.SetValue(Byte(Component.Filter));
  PropertySet.PropBlendMode('Blend Mode', @Component.BlendMode, Group);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
end;

procedure TScene2DComponentDataBackground.OnChangeLayer(const Sender: Pointer);
begin
  Component.Layer := Layer;
end;

procedure TScene2DComponentDataBackground.OnChangeTexture(const Sender: Pointer);
begin
  Component.Texture := App.AssetManager.GetTexture(TexturePath);
end;

procedure TScene2DComponentDataBackground.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataBackground END

//TScene2DComponentDataPoly BEGIN
constructor TScene2DComponentDataPolyVertex.Create;
begin
  inherited Create;
  e.Clear;
  f.Clear;
  c.Clear;
  v := G2Vec2;
  t := G2Vec2;
  ind := 0;
end;

function TScene2DComponentDataPolyVertex.IsEnclosed: Boolean;
  var i, j: Integer;
begin
  for i := 0 to e.Count - 1 do
  for j := 0 to 1 do
  if e[i].f[j] = nil then
  begin
    Result := False;
    Exit;
  end;
  Result := True;
end;

constructor TScene2DComponentDataPolyEdge.Create;
begin
  inherited Create;
end;

function TScene2DComponentDataPolyEdge.Contains(const Vertex: TScene2DComponentDataPolyVertex): Boolean;
  var i: Integer;
begin
  for i := 0 to 1 do
  if v[i] = Vertex then Exit(True);
  Result := False;
end;

constructor TScene2DComponentDataPolyFace.Create;
begin
  inherited Create;
end;

function TScene2DComponentDataPolyFace.Contains(const Vertex: TScene2DComponentDataPolyVertex): Boolean;
  var i: Integer;
begin
  for i := 0 to 2 do
  if v[i] = Vertex then Exit(True);
  Result := False;
end;

function TScene2DComponentDataPolyFace.Contains(const Edge: TScene2DComponentDataPolyEdge): Boolean;
  var i: Integer;
begin
  for i := 0 to 2 do
  if e[i] = Edge then Exit(True);
  Result := False;
end;

function TScene2DComponentDataPolyFace.VertexOpposite(const Vertex0, Vertex1: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyVertex;
  var i: Integer;
begin
  if not Contains(Vertex0) or not Contains(Vertex0) then Exit(nil);
  for i := 0 to 2 do
  if (v[i] <> nil) and (v[i] <> Vertex0) and (v[i] <> Vertex1) then
  begin
    Result := v[i];
    Exit;
  end;
  Result := nil;
end;

function TScene2DComponentDataPolyFace.VertexOppositeEdge(const Edge: TScene2DComponentDataPolyEdge): TScene2DComponentDataPolyVertex;
begin
  Result := VertexOpposite(Edge.v[0], Edge.v[1]);
end;

procedure TScene2DComponentDataPolyLayer.SetTexture(const Value: TG2Texture2DBase);
begin
  if _Texture = Value then Exit;
  if Assigned(_Texture) then _Texture.RefDec;
  _Texture := Value;
  if Assigned(_Texture) then _Texture.RefInc;
end;

constructor TScene2DComponentDataPolyLayer.Create;
begin
  inherited Create;
  Scale := G2Vec2(1, 1);
  Layer := 0;
  _Texture := nil;
end;

function TScene2DComponentDataPoly.FindEdge(const v0, v1: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyEdge;
  var i: Integer;
begin
  for i := 0 to Edges.Count - 1 do
  if (
    (Edges[i].v[0] = v0) and (Edges[i].v[1] = v1)
  )
  or (
    (Edges[i].v[1] = v0) and (Edges[i].v[0] = v1)
  ) then
  begin
    Result := Edges[i];
    Exit;
  end;
  Result := nil;
end;

function TScene2DComponentDataPoly.FindFace(const v0, v1, v2: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyFace;
  var i, j, n: Integer;
  var VertexMatch, FaceMatch: Boolean;
  var va: array[0..2] of TScene2DComponentDataPolyVertex;
begin
  va[0] := v0; va[1] := v1; va[2] := v2;
  for i := 0 to Faces.Count - 1 do
  begin
    FaceMatch := True;
    for j := 0 to 2 do
    begin
      VertexMatch := False;
      for n := 0 to 2 do
      begin
        if Faces[i].v[j] = va[n] then
        begin
          VertexMatch := True;
          Break;
        end;
      end;
      if not VertexMatch then
      begin
        FaceMatch := False;
        Break;
      end;
    end;
    if FaceMatch then
    begin
      Result := Faces[i];
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TScene2DComponentDataPoly.UpdateGroup;
  var i: Integer;
  var Properties: TPropertySet;
  var LayerGroup: TPropertySet.TProperty;
begin
  SyncTags(Component);
  Properties := TScene2DEntityData(Component.Owner.UserData).Properties;
  Group.Clear;
  for i := 0 to Layers.Count - 1 do
  begin
    LayerGroup := Properties.PropGroup('Layer ' + IntToStr(i), Group);
    if Assigned(Component.Layers[i].Texture) then
    Layers[i].TexturePath := Component.Layers[i].Texture.AssetName
    else
    Layers[i].TexturePath := '';
    Layers[i].PathProp := Properties.PropPath('Texture', @Layers[i].TexturePath, TAssetTexture, LayerGroup, @OnChangeLayerTexture);
    Layers[i].ScaleProp := Properties.PropVec2('Scale', @Layers[i].Scale, LayerGroup, @OnChangeParam);
    Layers[i].LayerProp := Properties.PropInt('Layer', @Layers[i].Layer, LayerGroup, @OnChangeParam);
  end;
  Properties.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  Properties.PropButton('Add Layer', @OnAddLayer, Group);
  Properties.PropButton('Edit', @OnEdit, Group);
end;

procedure TScene2DComponentDataPoly.UpdateComponent;
  var i, j: Integer;
  var VertexData: array of TG2Vec4;
  var IndexData: array of TG2IntU16;
begin
  SetLength(VertexData, Vertices.Count);
  for i := 0 to Vertices.Count - 1 do
  begin
    Vertices[i].ind := TG2IntU16(i);
    VertexData[i].x := Vertices[i].v.x;
    VertexData[i].y := Vertices[i].v.y;
    VertexData[i].z := Vertices[i].t.x;
    VertexData[i].w := Vertices[i].t.y;
  end;
  SetLength(IndexData, Faces.Count * 3);
  for i := 0 to Faces.Count - 1 do
  begin
    IndexData[i * 3 + 0] := Faces[i].v[0].ind;
    IndexData[i * 3 + 1] := Faces[i].v[1].ind;
    IndexData[i * 3 + 2] := Faces[i].v[2].ind;
  end;
  Component.SetUp(
    @VertexData[0], Length(VertexData), SizeOf(TG2Vec4),
    @IndexData[0], Length(IndexData), SizeOf(TG2IntU16),
    @VertexData[0].z, SizeOf(TG2Vec4)
  );
  Component.LayerCount := Layers.Count;
  for i := 0 to Layers.Count - 1 do
  begin
    Component.Layers[i].Texture := Layers[i].Texture;
    for j := 0 to Vertices.Count - 1 do
    Component.Layers[i].Color[j] := Vertices[j].c[i];
    Component.Layers[i].Scale := Layers[i].Scale;
    Component.Layers[i].Layer := Layers[i].Layer;
    Component.Layers[i].Visible := True;
  end;
end;

class function TScene2DComponentDataPoly.GetName: String;
begin
  Result := 'Triangle Mesh';
end;

constructor TScene2DComponentDataPoly.Create;
  var v: array[0..3] of TScene2DComponentDataPolyVertex;
  var e: array[0..4] of TScene2DComponentDataPolyEdge;
  var f: array[0..1] of TScene2DComponentDataPolyFace;
  var i: Integer;
begin
  inherited Create;
  if TScene2DEditorPoly.Instance = nil then
  TScene2DEditorPoly.Instance := TScene2DEditorPoly.Create;
  TScene2DEditorPoly.Instance.RefInc;
  Vertices.Clear;
  Edges.Clear;
  Faces.Clear;
  Layers.Clear;
  for i := 0 to 3 do
  begin
    v[i] := TScene2DComponentDataPolyVertex.Create;
    Vertices.Add(v[i]);
  end;
  for i := 0 to 4 do
  begin
    e[i] := TScene2DComponentDataPolyEdge.Create;
    Edges.Add(e[i]);
  end;
  for i := 0 to 1 do
  begin
    f[i] := TScene2DComponentDataPolyFace.Create;
    Faces.Add(f[i]);
  end;
  v[0].v := G2Vec2(-1, -1);
  v[1].v := G2Vec2(1, -1);
  v[2].v := G2Vec2(-1, 1);
  v[3].v := G2Vec2(1, 1);
  e[0].v[0] := v[2]; e[0].v[1] := v[0];
  e[1].v[0] := v[0]; e[1].v[1] := v[1];
  e[2].v[0] := v[1]; e[2].v[1] := v[3];
  e[3].v[0] := v[3]; e[3].v[1] := v[2];
  e[4].v[0] := v[1]; e[4].v[1] := v[2];
  f[0].v[0] := v[2]; f[0].v[1] := v[0]; f[0].v[2] := v[1];
  f[1].v[0] := v[2]; f[1].v[1] := v[1]; f[1].v[2] := v[3];
  CompleteData;
end;

destructor TScene2DComponentDataPoly.Destroy;
begin
  TScene2DEditorPoly.Instance.RefDec;
  Clear;
  inherited Destroy;
end;

function TScene2DComponentDataPoly.PickLayer: Integer;
  var i: Integer;
begin
  Result := -1;
  for i := 0 to Layers.Count - 1 do
  if Layers[i].Layer > Result then Result := Layers[i].Layer;
end;

function TScene2DComponentDataPoly.Pick(const x, y: TG2Float): Boolean;
  var i, j: Integer;
  var v: TG2Vec2;
  var t: array[0..2] of TG2Vec2;
  var xf: TG2Transform2;
begin
  v := G2Vec2(x, y);
  xf := Component.Owner.Transform;
  v := xf.TransformInv(v);
  for i := 0 to Faces.Count - 1 do
  begin
    for j := 0 to 2 do
    t[j] := Faces[i].v[j].v;
    Result := G2Vec2InPoly(v, @t, 3);
    if Result then Exit;
  end;
  Result := False;
end;

procedure TScene2DComponentDataPoly.AddToProperties(const PropertySet: TPropertySet);
begin
  Group := PropertySet.PropComponent(GetName, Component);
  UpdateGroup;
end;

procedure TScene2DComponentDataPoly.OnAddLayer;
  var Layer: TScene2DComponentDataPolyLayer;
  var i: Integer;
begin
  Layer := TScene2DComponentDataPolyLayer.Create;
  Layers.Add(Layer);
  for i := 0 to Vertices.Count - 1 do
  Vertices[i].c.Add($00ffffff);
  for i := 0 to Layers.Count - 1 do
  Layers[i].Index := i;
  UpdateComponent;
  UpdateGroup;
end;

procedure TScene2DComponentDataPoly.OnEdit;
begin
  if App.Scene2DData.Editor = TScene2DEditorPoly.Instance then
  App.Scene2DData.Editor := nil
  else
  begin
    TScene2DEditorPoly.Instance.Component := Self;
    App.Scene2DData.Editor := TScene2DEditorPoly.Instance;
  end;
end;

procedure TScene2DComponentDataPoly.GenerateData;
  function CreateEdge(const v0, v1: TScene2DComponentDataPolyVertex): TScene2DComponentDataPolyEdge;
  begin
    Result := FindEdge(v0, v1);
    if Result = nil then
    begin
      Result := TScene2DComponentDataPolyEdge.Create;
      Result.v[0] := v0;
      Result.v[1] := v1;
      Edges.Add(Result);
    end;
  end;
  var i, j: Integer;
  var Layer: TScene2DComponentDataPolyLayer;
  var v: TScene2DComponentDataPolyVertex;
  var f: TScene2DComponentDataPolyFace;
begin
  Clear;
  for i := 0 to Component.LayerCount - 1 do
  begin
    Layer := TScene2DComponentDataPolyLayer.Create;
    Layer.Texture := Component.Layers[i].Texture;
    Layer.Layer := Component.Layers[i].Layer;
    Layer.Scale := Component.Layers[i].Scale;
    Layer.Index := i;
    Layers.Add(Layer);
  end;
  for i := 0 to Component.VertexCount - 1 do
  begin
    v := TScene2DComponentDataPolyVertex.Create;
    v.v.x := Component.Vertices[i]^.x;
    v.v.y := Component.Vertices[i]^.y;
    v.t.x := Component.Vertices[i]^.u;
    v.t.y := Component.Vertices[i]^.v;
    v.c.Allocate(Component.LayerCount);
    for j := 0 to Component.LayerCount - 1 do
    v.c[j] := Component.Layers[j].Color[i];
    Vertices.Add(v);
  end;
  for i := 0 to Component.FaceCount - 1 do
  begin
    f := TScene2DComponentDataPolyFace.Create;
    f.v[0] := Vertices[Component.Faces[i]^[0]];
    f.v[1] := Vertices[Component.Faces[i]^[1]];
    f.v[2] := Vertices[Component.Faces[i]^[2]];
    for j := 0 to 2 do
    CreateEdge(f.v[j], f.v[(j + 1) mod 3]);
    Faces.Add(f);
  end;
  CompleteData;
end;

procedure TScene2DComponentDataPoly.CompleteData;
  var i, j: Integer;
begin
  for i := 0 to Vertices.Count - 1 do
  begin
    Vertices[i].e.Clear;
    Vertices[i].f.Clear;
  end;
  for i := 0 to Faces.Count - 1 do
  begin
    for j := 0 to 2 do
    begin
      Faces[i].v[j].f.Add(Faces[i]);
      Faces[i].e[j] := FindEdge(Faces[i].v[j], Faces[i].v[(j + 1) mod 3]);
    end;
  end;
  for i := 0 to Edges.Count - 1 do
  begin
    for j := 0 to 1 do
    Edges[i].v[j].e.Add(Edges[i]);
    Edges[i].f[0] := nil;
    Edges[i].f[1] := nil;
    for j := 0 to Faces.Count - 1 do
    if Faces[j].Contains(Edges[i]) then
    begin
      if Edges[i].f[0] = nil then
      Edges[i].f[0] := Faces[j]
      else
      Edges[i].f[1] := Faces[j];
    end;
  end;
end;

procedure TScene2DComponentDataPoly.Clear;
  var i: Integer;
begin
  for i := 0 to Layers.Count - 1 do
  begin
    Layers[i].Texture := nil;
    Layers[i].Free;
  end;
  Layers.Clear;
  for i := 0 to Vertices.Count - 1 do
  Vertices[i].Free;
  Vertices.Clear;
  for i := 0 to Edges.Count - 1 do
  Edges[i].Free;
  Edges.Clear;
  for i := 0 to Faces.Count - 1 do
  Faces[i].Free;
  Faces.Clear;
end;

procedure TScene2DComponentDataPoly.OnChangeLayerTexture(const Sender: Pointer);
  var i, l: Integer;
  var Layer: TScene2DComponentDataPolyLayer;
begin
  Layer := nil;
  for i := 0 to Layers.Count - 1 do
  if Pointer(Layers[i].PathProp) = Sender then
  begin
    Layer := Layers[i];
    l := i;
    Break;
  end;
  if Layer = nil then Exit;
  Layer.Texture := App.AssetManager.GetTexture(Layer.TexturePath);
  UpdateComponent;
end;

procedure TScene2DComponentDataPoly.OnChangeParam(const Sender: Pointer);
begin
  UpdateComponent;
end;

procedure TScene2DComponentDataPoly.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataPoly END

//TScene2DComponentDataEffect BEGIN
class function TScene2DComponentDataEffect.GetName: String;
begin
  Result := 'Effect';
end;

destructor TScene2DComponentDataEffect.Destroy;
begin
  inherited Destroy;
end;

procedure TScene2DComponentDataEffect.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Effect', Component);
  if Component.Effect <> nil then
  EffectPath := Component.Effect.AssetName
  else
  EffectPath := '';
  PropertySet.PropPath('Effect', @EffectPath, TAssetEffect2D, Group, @OnChangeEffect);
  Layer := Component.Layer;
  LocalSpace := Component.LocalSpace;
  Scale := Component.Scale;
  Speed := Component.Speed;
  Repeating := Component.Repeating;
  FixedOrientation := Component.FixedOrientation;
  PropertySet.PropInt('Layer', @Layer, Group, @OnChangeLayer);
  PropertySet.PropFloat('Scale', @Scale, Group, @OnChangeScale);
  PropertySet.PropFloat('Speed', @Speed, Group, @OnChangeSpeed);
  PropertySet.PropBool('Repeat', @Repeating, Group, @OnChangeRepeating);
  PropertySet.PropBool('Local Space', @LocalSpace, Group, @OnChangeLocalSpace);
  PropertySet.PropBool('Fixed Orientation', @FixedOrientation, Group, @OnChangeFixedOrientation);
  PropertySet.PropBool('Auto Play', @Component.AutoPlay, Group);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  PropertySet.PropButton('Play', @OnPlay, Group);
  PropertySet.PropButton('Stop', @OnStop, Group);
end;

procedure TScene2DComponentDataEffect.OnChangeLayer(const Sender: Pointer);
begin
  Component.Layer := Layer;
end;

procedure TScene2DComponentDataEffect.OnChangeScale(const Sender: Pointer);
begin
  if Component.EffectInst <> nil then
  Component.EffectInst.Scale := Scale;
end;

procedure TScene2DComponentDataEffect.OnChangeSpeed(const Sender: Pointer);
begin
  if Component.EffectInst <> nil then
  Component.EffectInst.Speed := Speed;
end;

procedure TScene2DComponentDataEffect.OnChangeRepeating(const Sender: Pointer);
begin
  if Component.EffectInst <> nil then
  Component.EffectInst.Repeating := Repeating;
end;

procedure TScene2DComponentDataEffect.OnChangeLocalSpace(const Sender: Pointer);
begin
  Component.LocalSpace := LocalSpace;
end;

procedure TScene2DComponentDataEffect.OnChangeFixedOrientation(const Sender: Pointer);
begin
  Component.FixedOrientation := FixedOrientation;
end;

procedure TScene2DComponentDataEffect.OnChangeEffect(const Sender: Pointer);
begin
  Component.Effect := App.AssetManager.GetEffect(EffectPath);
  if Component.Effect <> nil then
  begin
    Component.Repeating := True;
    Speed := Component.Speed;
    Scale := Component.Scale;
    Repeating := Component.Repeating;
  end;
end;

procedure TScene2DComponentDataEffect.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;

procedure TScene2DComponentDataEffect.OnPlay;
begin
  Component.Play;
end;

procedure TScene2DComponentDataEffect.OnStop;
begin
  Component.Stop;
end;
//TScene2DComponentDataEffect END

//TScene2DComponentDataRigidBody BEGIN
class function TScene2DComponentDataRigidBody.GetName: String;
begin
  Result := 'Rigid Body';
end;

destructor TScene2DComponentDataRigidBody.Destroy;
begin
  inherited Destroy;
end;

procedure TScene2DComponentDataRigidBody.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var Enum: TPropertySet.TPropertyEnum;
begin
  SyncTags(Component);
  _Position := Component.Position;
  _Rotation := Component.Rotation * G2RadToDeg;
  _LinearDamping := Component.LinearDamping;
  _AngularDamping := Component.AngularDamping;
  _FixedRotation := Component.FixedRotation;
  _BodyType := Component.BodyType;
  Group := PropertySet.PropComponent('Rigid Body', Component);
  PropertySet.PropVec2('Position', @_Position, Group, @OnChangePosition);
  PropertySet.PropFloat('Rotation', @_Rotation, Group, @OnChangeRotation);
  PropertySet.PropFloat('Linear Damping', @_LinearDamping, Group, @OnChangeLinearDamping);
  PropertySet.PropFloat('Angular Damping', @_AngularDamping, Group, @OnChangeAngularDamping);
  PropertySet.PropBool('Fixed Rotation', @_FixedRotation, Group, @OnChangeFixedRotation);
  Enum := PropertySet.PropEnum('Type', @_BodyType, Group, @OnChangeBodyType);
  Enum.AddValue('Static', Byte(g2_s2d_rbt_static_body));
  Enum.AddValue('Kinematic', Byte(g2_s2d_rbt_kinematic_body));
  Enum.AddValue('Dynamic', Byte(g2_s2d_rbt_dynamic_body));
  Enum.SetValue(Byte(_BodyType));
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
end;

function TScene2DComponentDataRigidBody.GetLocalPoint(const WorldPoint: TG2Vec2): TG2Vec2;
  var xfrb, xf: TG2Transform2;
begin
  xfrb := Component.Transform;
  xf := Component.Owner.Transform;
  G2Transform2Mul(@xf, @xfrb, @xf);
  Result := xf.TransformInv(WorldPoint);
end;

function TScene2DComponentDataRigidBody.GetWorldPoint(const LocalPoint: TG2Vec2): TG2Vec2;
  var xfrb, xf: TG2Transform2;
begin
  xfrb := Component.Transform;
  xf := Component.Owner.Transform;
  G2Transform2Mul(@xf, @xfrb, @xf);
  Result := xf.Transform(LocalPoint);
end;

procedure TScene2DComponentDataRigidBody.OnChangePosition(const Sender: Pointer);
begin
  Component.Position := _Position;
end;

procedure TScene2DComponentDataRigidBody.OnChangeRotation(const Sender: Pointer);
begin
  Component.Rotation := _Rotation * G2DegToRad;
end;

procedure TScene2DComponentDataRigidBody.OnChangeLinearDamping(const Sender: Pointer);
begin
  Component.LinearDamping := _LinearDamping;
end;

procedure TScene2DComponentDataRigidBody.OnChangeAngularDamping(const Sender: Pointer);
begin
  Component.AngularDamping := _AngularDamping;
end;

procedure TScene2DComponentDataRigidBody.OnChangeFixedRotation(const Sender: Pointer);
begin
  Component.FixedRotation := _FixedRotation;
end;

procedure TScene2DComponentDataRigidBody.OnChangeBodyType(const Sender: Pointer);
begin
  Component.BodyType := _BodyType;
end;

procedure TScene2DComponentDataRigidBody.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataRigidBody END

//TScene2DComponentDataCharacter BEGIN
class function TScene2DComponentDataCharacter.GetName: String;
begin
  Result := 'Character';
end;

destructor TScene2DComponentDataCharacter.Destroy;
begin
  inherited Destroy;
end;

procedure TScene2DComponentDataCharacter.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TPropertyComponent;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Character', Component);
  PropertySet.PropFloat('Max Glide Speed', @Component.MaxGlideSpeed, Group);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
end;

procedure TScene2DComponentDataCharacter.DebugDraw(const Display: TG2Display2D);
  var v: array[0..15] of TG2Vec2;
  var r: TG2Rotation2;
  var d: TG2Vec2;
  var i: Integer;
  var xf: TG2Transform2;
  var hw, hh, qw: TG2Float;
begin
  hw := Component.Width * 0.5;
  hh := Component.Height * 0.5;
  qw := hw * 0.5;
  v[0] := b2_vec2(hw, hh - hw);
  v[1] := b2_vec2(hw, -hh + qw);
  v[2] := b2_vec2(hw - qw, -hh);
  v[3] := b2_vec2(-hw + qw, -hh);
  v[4] := b2_vec2(-hw, -hh + qw);
  v[5] := b2_vec2(-hw, hh - hw);
  r.Angle := -0.1 * Pi;
  d := G2Vec2(-hw, 0);
  for i := 6 to 15 do
  begin
    d := r.Transform(d);
    v[i] := G2Vec2(d.x, d.y + v[0].y);
  end;
  xf := Component.Owner.Transform;
  for i := 0 to High(v) do
  v[i] := xf.Transform(v[i]);
  for i := 0 to High(v) do
  Display.PrimLine(v[i], v[(i + 1) mod Length(v)], $ff0000ff);
end;

procedure TScene2DComponentDataCharacter.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataCharacter END

//TScene2DComponentDataShapePoly BEGIN
class function TScene2DComponentDataShapePoly.GetName: String;
begin
  Result := 'Collision Polygon';
end;

constructor TScene2DComponentDataShapePoly.Create;
begin
  inherited Create;
  if TScene2DEditorShapePoly.Instance = nil then
  TScene2DEditorShapePoly.Instance := TScene2DEditorShapePoly.Create;
  TScene2DEditorShapePoly.Instance.RefInc;
end;

destructor TScene2DComponentDataShapePoly.Destroy;
begin
  TScene2DEditorShapePoly.Instance.RefDec;
  inherited Destroy;
end;

function TScene2DComponentDataShapePoly.PickLayer: Integer;
begin
  Result := -1;
end;

function TScene2DComponentDataShapePoly.Pick(const x, y: TG2Float): Boolean;
  var rb: TG2Scene2DComponentRigidBody;
  var xf, xfrb: TG2Transform2;
  var i, c: Integer;
  var v: array[0..b2_max_polygon_vertices - 1] of TG2Vec2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit(False);
  xfrb := rb.Transform;
  G2Transform2Mul(@xf, @xfrb, @Component.Owner.Transform);
  c := Component.VertexCount;
  for i := 0 to c - 1 do
  v[i] := xf.Transform(Component.Vertices^[i]);
  Result := G2Vec2InPoly(G2Vec2(x, y), @v, c);
end;

procedure TScene2DComponentDataShapePoly.DebugDraw(const Display: TG2Display2D);
  var rb: TG2Scene2DComponentRigidBody;
  var xf, xfrb: TG2Transform2;
  var i, c: Integer;
  var v: array[0..b2_max_polygon_vertices - 1] of TG2Vec2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit;
  xfrb := rb.Transform;
  G2Transform2Mul(@xf, @xfrb, @Component.Owner.Transform);
  c := Component.VertexCount;
  for i := 0 to c - 1 do
  v[i] := xf.Transform(Component.Vertices^[i]);
  Display.PrimBegin(ptTriangles, bmNormal);
  for i := 1 to c - 2 do
  begin
    Display.PrimAdd(v[0], $4000ff00);
    Display.PrimAdd(v[i], $4000ff00);
    Display.PrimAdd(v[i + 1], $4000ff00);
  end;
  Display.PrimEnd;
  Display.PrimBegin(ptLines, bmNormal);
  for i := 0 to c - 1 do
  begin
    Display.PrimAdd(v[i], $ff80ff00);
    Display.PrimAdd(v[(i + 1) mod c], $ff80ff00);
  end;
  Display.PrimEnd;
end;

procedure TScene2DComponentDataShapePoly.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var EventGroup: TPropertySet.TProperty;
begin
  SyncTags(Component);
  Group := PropertySet.PropComponent('Collision Polygon', Component);
  _Friction := Component.Fricton;
  _Density := Component.Density;
  _Restitution := Component.Restitution;
  _Sensor := Component.IsSensor;
  PropertySet.PropFloat('Friction', @_Friction, Group, @OnChangeFriction);
  PropertySet.PropFloat('Density', @_Density, Group, @OnChangeDensity);
  PropertySet.PropFloat('Restitution', @_Restitution, Group, @OnChangeRestitution);
  PropertySet.PropBool('Sensor', @_Sensor, Group, @OnChangeSensor);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  PropertySet.PropButton('Edit', @OnEdit, Group);
  EventGroup := PropertySet.PropGroup('Events', Group);
  PropertySet.PropString('Event Contact Begin', @Component.EventBeginContact.Name, EventGroup);
  PropertySet.PropString('Event Contact End', @Component.EventEndContact.Name, EventGroup);
  PropertySet.PropString('Event Before Contact Solve', @Component.EventBeforeContactSolve.Name, EventGroup);
  PropertySet.PropString('Event After Contact Solve', @Component.EventAfterContactSolve.Name, EventGroup);
  //PropertySet.PropVec2('Position', @_Position, Group, @OnChangeWidth);
end;

procedure TScene2DComponentDataShapePoly.OnChangeFriction(const Sender: Pointer);
begin
  Component.Fricton := _Friction;
end;

procedure TScene2DComponentDataShapePoly.OnChangeDensity(const Sender: Pointer);
begin
  Component.Density := _Density;
end;

procedure TScene2DComponentDataShapePoly.OnChangeRestitution(const Sender: Pointer);
begin
  Component.Restitution := _Restitution;
end;

procedure TScene2DComponentDataShapePoly.OnChangeSensor(const Sender: Pointer);
begin
  Component.IsSensor := _Sensor;
end;

procedure TScene2DComponentDataShapePoly.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;

procedure TScene2DComponentDataShapePoly.OnEdit;
begin
  if App.Scene2DData.Editor = TScene2DEditorShapePoly.Instance then
  App.Scene2DData.Editor := nil
  else
  begin
    TScene2DEditorShapePoly.Instance.Component := Self;
    App.Scene2DData.Editor := TScene2DEditorShapePoly.Instance;
  end;
end;
//TScene2DComponentDataShapePoly END

//TScene2DComponentDataShapeBox BEGIN
class function TScene2DComponentDataShapeBox.GetName: String;
begin
  Result := 'Collision Box';
end;

constructor TScene2DComponentDataShapeBox.Create;
begin
  inherited Create;
  _Width := 1;
  _Height := 1;
  _Offset.SetZero;
  _Angle := 0;
end;

destructor TScene2DComponentDataShapeBox.Destroy;
begin
  inherited Destroy;
end;

function TScene2DComponentDataShapeBox.PickLayer: Integer;
begin
  Result := -1;
end;

function TScene2DComponentDataShapeBox.Pick(const x, y: TG2Float): Boolean;
  var rb: TG2Scene2DComponentRigidBody;
  var xf, rbxf: TG2Transform2;
  var i, c: Integer;
  var v: array[0..b2_max_polygon_vertices - 1] of TG2Vec2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit(False);
  rbxf := rb.Transform;
  G2Transform2Mul(@xf, @rbxf, @Component.Owner.Transform);
  c := Component.VertexCount;
  for i := 0 to c - 1 do
  v[i] := xf.Transform(Component.Vertices^[i]);
  Result := G2Vec2InPoly(G2Vec2(x, y), @v, c);
end;

procedure TScene2DComponentDataShapeBox.DebugDraw(const Display: TG2Display2D);
  var rb: TG2Scene2DComponentRigidBody;
  var xf, rbxf: TG2Transform2;
  var i, c: Integer;
  var v: array[0..b2_max_polygon_vertices - 1] of TG2Vec2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit;
  rbxf := rb.Transform;
  G2Transform2Mul(@xf, @rbxf, @Component.Owner.Transform);
  c := Component.VertexCount;
  for i := 0 to c - 1 do
  v[i] := xf.Transform(Component.Vertices^[i]);
  Display.PrimBegin(ptTriangles, bmNormal);
  for i := 1 to c - 2 do
  begin
    Display.PrimAdd(v[0], $4000ff00);
    Display.PrimAdd(v[i], $4000ff00);
    Display.PrimAdd(v[i + 1], $4000ff00);
  end;
  Display.PrimEnd;
  Display.PrimBegin(ptLines, bmNormal);
  for i := 0 to c - 1 do
  begin
    Display.PrimAdd(v[i], $ff80ff00);
    Display.PrimAdd(v[(i + 1) mod c], $ff80ff00);
  end;
  Display.PrimEnd;
end;

procedure TScene2DComponentDataShapeBox.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var EventGroup: TPropertySet.TProperty;
begin
  SyncTags(Component);
  _Width := Component.Width;
  _Height := Component.Height;
  _Offset := Component.Offset;
  _Angle := Component.Angle * G2RadToDeg;
  _Friction := Component.Fricton;
  _Density := Component.Density;
  _Restitution := Component.Restitution;
  _Sensor := Component.IsSensor;
  Group := PropertySet.PropComponent('Collision Box', Component);
  PropertySet.PropFloat('Width', @_Width, Group, @OnChangeWidth);
  PropertySet.PropFloat('Height', @_Height, Group, @OnChangeHeight);
  PropertySet.PropVec2('Offset', @_Offset, Group, @OnChangeOffset);
  PropertySet.PropFloat('Rotation', @_Angle, Group, @OnChangeAngle);
  PropertySet.PropFloat('Friction', @_Friction, Group, @OnChangeFriction);
  PropertySet.PropFloat('Density', @_Density, Group, @OnChangeDensity);
  PropertySet.PropFloat('Restitution', @_Restitution, Group, @OnChangeRestitution);
  PropertySet.PropBool('Sensor', @_Sensor, Group, @OnChangeSensor);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  EventGroup := PropertySet.PropGroup('Events', Group);
  PropertySet.PropString('Event Contact Begin', @Component.EventBeginContact.Name, EventGroup);
  PropertySet.PropString('Event Contact End', @Component.EventEndContact.Name, EventGroup);
  PropertySet.PropString('Event Before Contact Solve', @Component.EventBeforeContactSolve.Name, EventGroup);
  PropertySet.PropString('Event After Contact Solve', @Component.EventAfterContactSolve.Name, EventGroup);
end;

procedure TScene2DComponentDataShapeBox.OnChangeWidth(const Sender: Pointer);
begin
  Component.Width := _Width;
end;

procedure TScene2DComponentDataShapeBox.OnChangeHeight(const Sender: Pointer);
begin
  Component.Height := _Height;
end;

procedure TScene2DComponentDataShapeBox.OnChangeOffset(const Sender: Pointer);
begin
  Component.Offset := _Offset;
end;

procedure TScene2DComponentDataShapeBox.OnChangeAngle(const Sender: Pointer);
begin
  Component.Angle := _Angle * G2DegToRad;
end;

procedure TScene2DComponentDataShapeBox.OnChangeFriction(const Sender: Pointer);
begin
  Component.Fricton := _Friction;
end;

procedure TScene2DComponentDataShapeBox.OnChangeDensity(const Sender: Pointer);
begin
  Component.Density := _Density;
end;

procedure TScene2DComponentDataShapeBox.OnChangeRestitution(const Sender: Pointer);
begin
  Component.Restitution := _Restitution;
end;

procedure TScene2DComponentDataShapeBox.OnChangeSensor(const Sender: Pointer);
begin
  Component.IsSensor := _Sensor;
end;

procedure TScene2DComponentDataShapeBox.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataShapeBox END

//TScene2DComponentDataShapeCircle BEGIN
class function TScene2DComponentDataShapeCircle.GetName: String;
begin
  Result := 'Collision Circle';
end;

destructor TScene2DComponentDataShapeCircle.Destroy;
begin
  inherited Destroy;
end;

function TScene2DComponentDataShapeCircle.PickLayer: Integer;
begin
  Result := -1;
end;

function TScene2DComponentDataShapeCircle.Pick(const x, y: TG2Float): Boolean;
  var rb: TG2Scene2DComponentRigidBody;
  var v: TG2Vec2;
  var xf, rbxf: TG2Transform2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit(False);
  rbxf := rb.Transform;
  G2Transform2Mul(@xf, @rbxf, @Component.Owner.Transform);
  v := xf.Transform(Component.Center);
  Result := (v - G2Vec2(x, y)).Len <= Component.Radius;
end;

procedure TScene2DComponentDataShapeCircle.DebugDraw(const Display: TG2Display2D);
  var rb: TG2Scene2DComponentRigidBody;
  var v: TG2Vec2;
  var xf, rbxf: TG2Transform2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit;
  rbxf := rb.Transform;
  G2Transform2Mul(@xf, @rbxf, @Component.Owner.Transform);
  v := xf.Transform(Component.Center);
  Display.PrimCircleCol(
    v, Component.Radius,
    $4000ff00, $4000ff00,
    64
  );
  Display.PrimCircleHollow(
    v, Component.Radius,
    $ff80ff00, 64
  );
end;

procedure TScene2DComponentDataShapeCircle.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var EventGroup: TPropertySet.TProperty;
begin
  SyncTags(Component);
  _Offset := Component.Center;
  _Radius := Component.Radius;
  _Friction := Component.Fricton;
  _Density := Component.Density;
  _Restitution := Component.Restitution;
  _Sensor := Component.IsSensor;
  Group := PropertySet.PropComponent('Collision Circle', Component);
  PropertySet.PropVec2('Offset', @_Offset, Group, @OnChangeOffset);
  PropertySet.PropFloat('Radius', @_Radius, Group, @OnChangeRadius);
  PropertySet.PropFloat('Friction', @_Friction, Group, @OnChangeFriction);
  PropertySet.PropFloat('Density', @_Density, Group, @OnChangeDensity);
  PropertySet.PropFloat('Restitution', @_Restitution, Group, @OnChangeRestitution);
  PropertySet.PropBool('Sensor', @_Sensor, Group, @OnChangeSensor);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  EventGroup := PropertySet.PropGroup('Events', Group);
  PropertySet.PropString('Event Contact Begin', @Component.EventBeginContact.Name, EventGroup);
  PropertySet.PropString('Event Contact End', @Component.EventEndContact.Name, EventGroup);
  PropertySet.PropString('Event Before Contact Solve', @Component.EventBeforeContactSolve.Name, EventGroup);
  PropertySet.PropString('Event After Contact Solve', @Component.EventAfterContactSolve.Name, EventGroup);
end;

procedure TScene2DComponentDataShapeCircle.OnChangeOffset(const Sender: Pointer);
begin
  Component.Center := _Offset;
end;

procedure TScene2DComponentDataShapeCircle.OnChangeRadius(const Sender: Pointer);
begin
  component.Radius := _Radius;
end;

procedure TScene2DComponentDataShapeCircle.OnChangeFriction(const Sender: Pointer);
begin
  Component.Fricton := _Friction;
end;

procedure TScene2DComponentDataShapeCircle.OnChangeDensity(const Sender: Pointer);
begin
  Component.Density := _Density;
end;

procedure TScene2DComponentDataShapeCircle.OnChangeRestitution(const Sender: Pointer);
begin
  Component.Restitution := _Restitution;
end;

procedure TScene2DComponentDataShapeCircle.OnChangeSensor(const Sender: Pointer);
begin
  Component.IsSensor := _Sensor;
end;

procedure TScene2DComponentDataShapeCircle.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataShapeCircle END

//TScene2DComponentDataShapeEdge BEGIN
class function TScene2DComponentDataShapeEdge.GetName: String;
begin
  Result := 'Collision Edge';
end;

constructor TScene2DComponentDataShapeEdge.Create;
begin
  inherited Create;
  if TScene2DEditorEdge.Instance = nil then TScene2DEditorEdge.Create;
  TScene2DEditorEdge.Instance.RefInc;
end;

destructor TScene2DComponentDataShapeEdge.Destroy;
begin
  TScene2DEditorEdge.Instance.RefDec;
  inherited Destroy;
end;

procedure TScene2DComponentDataShapeEdge.DebugDraw(const Display: TG2Display2D);
  var rb: TG2Scene2DComponentRigidBody;
  var xf: TG2Transform2;
  var i, c: Integer;
  var v1, v2: TG2Vec2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit;
  xf := Component.Owner.Transform;
  v1 := xf.Transform(Component.Vertex1);
  v2 := xf.Transform(Component.Vertex2);
  Display.PrimLine(v1, v2, $ff80ff00);
end;

procedure TScene2DComponentDataShapeEdge.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var EventGroup: TPropertySet.TProperty;
begin
  SyncTags(Component);
  _Friction := Component.Fricton;
  _Density := Component.Density;
  _Restitution := Component.Restitution;
  _Sensor := Component.IsSensor;
  Group := PropertySet.PropComponent('Collision Edge', Component);
  PropertySet.PropFloat('Friction', @_Friction, Group, @OnChangeFriction);
  PropertySet.PropFloat('Density', @_Density, Group, @OnChangeDensity);
  PropertySet.PropFloat('Restitution', @_Restitution, Group, @OnChangeRestitution);
  PropertySet.PropBool('Sensor', @_Sensor, Group, @OnChangeSensor);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  PropertySet.PropButton('Edit', @OnEdit, Group);
  EventGroup := PropertySet.PropGroup('Events', Group);
  PropertySet.PropString('Event Contact Begin', @Component.EventBeginContact.Name, EventGroup);
  PropertySet.PropString('Event Contact End', @Component.EventEndContact.Name, EventGroup);
  PropertySet.PropString('Event Before Contact Solve', @Component.EventBeforeContactSolve.Name, EventGroup);
  PropertySet.PropString('Event After Contact Solve', @Component.EventAfterContactSolve.Name, EventGroup);
end;

procedure TScene2DComponentDataShapeEdge.OnEdit;
begin
  if App.Scene2DData.Editor = TScene2DEditorEdge.Instance then
  App.Scene2DData.Editor := nil
  else
  begin
    TScene2DEditorEdge.Instance.Component := Self;
    App.Scene2DData.Editor := TScene2DEditorEdge.Instance;
  end;
end;

procedure TScene2DComponentDataShapeEdge.OnChangeFriction(const Sender: Pointer);
begin
  Component.Fricton := _Friction;
end;

procedure TScene2DComponentDataShapeEdge.OnChangeDensity(const Sender: Pointer);
begin
  Component.Density := _Density;
end;

procedure TScene2DComponentDataShapeEdge.OnChangeRestitution(const Sender: Pointer);
begin
  Component.Restitution := _Restitution;
end;

procedure TScene2DComponentDataShapeEdge.OnChangeSensor(const Sender: Pointer);
begin
  Component.IsSensor := _Sensor;
end;

procedure TScene2DComponentDataShapeEdge.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataShapeEdge END

//TScene2DComponentDataShapeChain BEGIN
class function TScene2DComponentDataShapeChain.GetName: String;
begin
  Result := 'Collision Chain';
end;

constructor TScene2DComponentDataShapeChain.Create;
begin
  inherited Create;
  if TScene2DEditorChain.Instance = nil then TScene2DEditorChain.Create;
  TScene2DEditorChain.Instance.RefInc;
end;

destructor TScene2DComponentDataShapeChain.Destroy;
begin
  TScene2DEditorChain.Instance.RefDec;
  inherited Destroy;
end;

procedure TScene2DComponentDataShapeChain.DebugDraw(const Display: TG2Display2D);
  var rb: TG2Scene2DComponentRigidBody;
  var xf: TG2Transform2;
  var i, c: Integer;
  var v0, v1: TG2Vec2;
begin
  rb := TG2Scene2DComponentRigidBody(Component.Owner.ComponentOfType[TG2Scene2DComponentRigidBody]);
  if rb = nil then Exit;
  xf := Component.Owner.Transform;
  c := Component.VertexCount;
  if c = 0 then Exit;
  v0 := xf.Transform(Component.Vertices^[0]);
  Display.PrimBegin(ptLines, bmNormal);
  for i := 1 to c - 1 do
  begin
    v1 := xf.Transform(Component.Vertices^[i]);
    Display.PrimAdd(v0, $ff80ff00);
    Display.PrimAdd(v1, $ff80ff00);
    v0 := v1;
  end;
  Display.PrimEnd;
end;

procedure TScene2DComponentDataShapeChain.AddToProperties(const PropertySet: TPropertySet);
  var Group: TPropertySet.TProperty;
  var EventGroup: TPropertySet.TProperty;
begin
  SyncTags(Component);
  _Friction := Component.Fricton;
  _Density := Component.Density;
  _Restitution := Component.Restitution;
  _Sensor := Component.IsSensor;
  Group := PropertySet.PropComponent('Collision Chain', Component);
  PropertySet.PropFloat('Friction', @_Friction, Group, @OnChangeFriction);
  PropertySet.PropFloat('Density', @_Density, Group, @OnChangeDensity);
  PropertySet.PropFloat('Restitution', @_Restitution, Group, @OnChangeRestitution);
  PropertySet.PropBool('Sensor', @_Sensor, Group, @OnChangeSensor);
  PropertySet.PropString('Tags', @Tags, Group, @OnTagsChange).AllowEmpty := True;
  PropertySet.PropButton('Edit', @OnEdit, Group);
  EventGroup := PropertySet.PropGroup('Events', Group);
  PropertySet.PropString('Event Contact Begin', @Component.EventBeginContact.Name, EventGroup);
  PropertySet.PropString('Event Contact End', @Component.EventEndContact.Name, EventGroup);
  PropertySet.PropString('Event Before Contact Solve', @Component.EventBeforeContactSolve.Name, EventGroup);
  PropertySet.PropString('Event After Contact Solve', @Component.EventAfterContactSolve.Name, EventGroup);
end;

procedure TScene2DComponentDataShapeChain.OnEdit;
begin
  if App.Scene2DData.Editor = TScene2DEditorChain.Instance then
  App.Scene2DData.Editor := nil
  else
  begin
    TScene2DEditorChain.Instance.Component := Self;
    App.Scene2DData.Editor := TScene2DEditorChain.Instance;
  end;
end;

procedure TScene2DComponentDataShapeChain.OnChangeFriction(const Sender: Pointer);
begin
  Component.Fricton := _Friction;
end;

procedure TScene2DComponentDataShapeChain.OnChangeDensity(const Sender: Pointer);
begin
  Component.Density := _Density;
end;

procedure TScene2DComponentDataShapeChain.OnChangeRestitution(const Sender: Pointer);
begin
  Component.Restitution := _Restitution;
end;

procedure TScene2DComponentDataShapeChain.OnChangeSensor(const Sender: Pointer);
begin
  Component.IsSensor := _Sensor;
end;

procedure TScene2DComponentDataShapeChain.OnTagsChange(const Sender: Pointer);
begin
  Component.ParseTags(Tags);
  SyncTags(Component);
end;
//TScene2DComponentDataShapeChain END

//TScene2DJointData BEGIN
function TScene2DJointData.GetEditor: TScene2DEditor;
begin
  Result := nil;
end;

function TScene2DJointData.GetPosition: TG2Vec2;
begin
  Result := _Position;
end;

procedure TScene2DJointData.SetPosition(const Value: TG2Vec2);
begin
  _Position := Value;
end;

constructor TScene2DJointData.Create;
begin

end;

destructor TScene2DJointData.Destroy;
begin
  inherited Destroy;
end;

procedure TScene2DJointData.DebugDraw(const Display: TG2Display2D);
begin

end;

function TScene2DJointData.IsSelected: Boolean;
begin
  Result := App.Scene2DData.SelectJoint = Self;
end;

function TScene2DJointData.Select(const Display: TG2Display2D; const x, y: TG2Float): Boolean;
  var v: TG2Vec2;
begin
  v := Display.CoordToScreen(_Position);
  Result := G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(G2Vec2(x, y));
end;

procedure TScene2DJointData.AddToProperties(const PropertySet: TPropertySet);
begin

end;
//TScene2DJointData END

//TScene2DJointDataDistance BEGIN
function TScene2DJointDataDistance.GetJoint: TG2Scene2DDistanceJoint;
begin
  Result := TG2Scene2DDistanceJoint(_Joint);
end;

procedure TScene2DJointDataDistance.SetJoint(const Value: TG2Scene2DDistanceJoint);
begin
  _Joint := Value;
end;

function TScene2DJointDataDistance.GetRigidBodyA: TScene2DComponentDataRigidBody;
begin
  if Joint.RigidBodyA <> nil then
  Result := TScene2DComponentDataRigidBody(Joint.RigidBodyA.UserData)
  else
  Result := nil;
end;

procedure TScene2DJointDataDistance.SetRigidBodyA(const Value: TScene2DComponentDataRigidBody);
begin
  if Value <> nil then
  Joint.RigidBodyA := Value.Component
  else
  Joint.RigidBodyA := nil;
end;

function TScene2DJointDataDistance.GetRigidBodyB: TScene2DComponentDataRigidBody;
begin
  if Joint.RigidBodyB <> nil then
  Result := TScene2DComponentDataRigidBody(Joint.RigidBodyB.UserData)
  else
  Result := nil;
end;

procedure TScene2DJointDataDistance.SetRigidBodyB(const Value: TScene2DComponentDataRigidBody);
begin
  if Value <> nil then
  Joint.RigidBodyB := Value.Component
  else
  Joint.RigidBodyB := nil;
end;

function TScene2DJointDataDistance.GetAnchorA: TG2Vec2;
begin
  Result := Joint.AnchorA;
end;

procedure TScene2DJointDataDistance.SetAnchorA(const Value: TG2Vec2);
begin
  Joint.AnchorA := Value;
end;

function TScene2DJointDataDistance.GetAnchorB: TG2Vec2;
begin
  Result := Joint.AnchorB;
end;

procedure TScene2DJointDataDistance.SetAnchorB(const Value: TG2Vec2);
begin
  Joint.AnchorB := Value;
end;

function TScene2DJointDataDistance.GetEditor: TScene2DEditor;
begin
  Result := TScene2DEditorJointDistance.Instance;
  TScene2DEditorJointDistance.Instance.Joint := Self;
end;

constructor TScene2DJointDataDistance.Create;
begin
  inherited Create;
  _Position.SetZero;
  if TScene2DEditorJointDistance.Instance = nil then
  TScene2DEditorJointDistance.Instance := TScene2DEditorJointDistance.Create;
  TScene2DEditorJointDistance.Instance.RefInc;
end;

destructor TScene2DJointDataDistance.Destroy;
begin
  TScene2DEditorJointDistance.Instance.RefDec;
  inherited Destroy;
end;

function TScene2DJointDataDistance.Select(const Display: TG2Display2D; const x, y: TG2Float): Boolean;
  var v: TG2Vec2;
begin
  if (RigidBodyA = nil)
  and (RigidBodyB = nil) then
  begin
    Result := inherited Select(Display, x, y);
  end
  else if RigidBodyB = nil then
  begin
    v := Display.CoordToScreen(RigidBodyA.GetWorldPoint(AnchorA));
    v.x := v.x + 16;
    Result := G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(x, y);
  end
  else
  begin
    v := Display.CoordToScreen((RigidBodyA.GetWorldPoint(AnchorA) + RigidBodyB.GetWorldPoint(AnchorB)) * 0.5);
    Result := G2Rect(v.x - 8, v.y - 8, 16, 16).Contains(x, y);
  end;
end;

procedure TScene2DJointDataDistance.DebugDraw(const Display: TG2Display2D);
  var v, v1, a0, a1, rb0, rb1: TG2Vec2;
  var d: TG2Float;
  var Str: String;
  var xf, xfrb: TG2Transform2;
  var e: TG2Scene2DEntity;
begin
  if (RigidBodyA = nil)
  and (RigidBodyB = nil) then
  begin
    v := Display.CoordToScreen(_Position);
    g2.PicRect(
      Round(v.x - 8), Round(v.y - 8), 16, 16,
      G2LerpColor($ff000000, $ffff0000, Abs(Sin(G2PiTime(300)))),
      App.UI.TexLink, bmNormal, tfPoint
    );
    g2.PicRect(
      Round(v.x - 8), Round(v.y - 8), 16, 16,
      G2LerpColor($ff404040, $ffff0000, Abs(Sin(G2PiTime(300)))),
      App.UI.TexLink, bmNormal, tfPoint
    );
  end
  else if (RigidBodyB = nil) then
  begin
    xfrb := RigidBodyA.Component.Transform;
    xf := RigidBodyA.Component.Owner.Transform;
    G2Transform2Mul(@xf, @xfrb, @xf);
    e := RigidBodyA.Component.Owner;
    v := Display.CoordToScreen(RigidBodyA.GetWorldPoint(AnchorA));
    v1 := Display.CoordToScreen(e.Transform.Transform(RigidBodyA.Component.Position));
    d := (v - v1).Len;
    g2.Gfx.Poly2D.PolyBegin(ptLines, App.UI.TexDots, bmNormal, tfLinear);
    g2.Gfx.Poly2D.PolyAdd(v, G2Vec2(0, 0.5), $ffff0000);
    g2.Gfx.Poly2D.PolyAdd(v1, G2Vec2(d * 0.05, 0.5), $ffff0000);
    g2.Gfx.Poly2D.PolyEnd;
    g2.PrimCircleHollow(v1, 5, $ffff0000);
    if App.Scene2DData.SelectJoint = Self then
    begin
      g2.PicRect(
        Round(v.x - 8), Round(v.y - 8), 16, 16,
        $ff000000, App.UI.TexPin, bmNormal, tfPoint
      );
      g2.PicRect(
        Round(v.x - 8), Round(v.y - 8), 16, 16,
        $ff0000cc, App.UI.TexPin, bmNormal, tfPoint
      );
    end;
    if (App.Scene2DData.SelectJoint = Self)
    and (TScene2DEditorJointDistance(Editor).ActionType = jdat_drag_joint) then
    v := Display.CoordToScreen(_Position)
    else
    v.x := v.x + 16;
    g2.PicRect(
      Round(v.x - 8), Round(v.y - 8), 16, 16,
      $ff000000,
      App.UI.TexLink, bmNormal, tfPoint
    );
    g2.PicRect(
      Round(v.x - 8), Round(v.y - 8), 16, 16,
      G2LerpColor($ff404040, $ffff0000, Abs(Sin(G2PiTime(300)))),
      App.UI.TexLink, bmNormal, tfPoint
    );
  end
  else
  begin
    xfrb := RigidBodyA.Component.Transform;
    xf := RigidBodyA.Component.Owner.Transform;
    G2Transform2Mul(@xf, @xfrb, @xf);
    e := RigidBodyA.Component.Owner;
    a0 := Display.CoordToScreen(RigidBodyA.GetWorldPoint(AnchorA));
    rb0 := Display.CoordToScreen(e.Transform.Transform(RigidBodyA.Component.Position));
    xfrb := RigidBodyB.Component.Transform;
    xf := RigidBodyB.Component.Owner.Transform;
    G2Transform2Mul(@xf, @xfrb, @xf);
    e := RigidBodyB.Component.Owner;
    a1 := Display.CoordToScreen(RigidBodyB.GetWorldPoint(AnchorB));
    rb1 := Display.CoordToScreen(e.Transform.Transform(RigidBodyB.Component.Position));
    g2.Gfx.Poly2D.PolyBegin(ptLines, App.UI.TexDots, bmNormal, tfLinear);
    d := (a0 - rb0).Len;
    g2.Gfx.Poly2D.PolyAdd(a0, G2Vec2(0, 0.5), $ffff0000);
    g2.Gfx.Poly2D.PolyAdd(rb0, G2Vec2(d * 0.05, 0.5), $ffff0000);
    d := (a1 - rb1).Len;
    g2.Gfx.Poly2D.PolyAdd(a1, G2Vec2(0, 0.5), $ffff0000);
    g2.Gfx.Poly2D.PolyAdd(rb1, G2Vec2(d * 0.05, 0.5), $ffff0000);
    d := (a0 - a1).Len;
    g2.Gfx.Poly2D.PolyAdd(a0, G2Vec2(0, 0.5), $ffff0000);
    g2.Gfx.Poly2D.PolyAdd(a1, G2Vec2(d * 0.05, 0.5), $ffff0000);
    g2.Gfx.Poly2D.PolyEnd;
    g2.PrimCircleHollow(rb0, 5, $ffff0000);
    g2.PrimCircleHollow(rb1, 5, $ffff0000);
    if App.Scene2DData.SelectJoint = Self then
    begin
      g2.PicRect(
        Round(a0.x - 8), Round(a0.y - 8), 16, 16,
        $ff000000, App.UI.TexPin, bmNormal, tfPoint
      );
      g2.PicRect(
        Round(a0.x - 8), Round(a0.y - 8), 16, 16,
        $ff0000cc, App.UI.TexPin, bmNormal, tfPoint
      );
      g2.PicRect(
        Round(a1.x - 8), Round(a1.y - 8), 16, 16,
        $ff000000, App.UI.TexPin, bmNormal, tfPoint
      );
      g2.PicRect(
        Round(a1.x - 8), Round(a1.y - 8), 16, 16,
        $ff0000cc, App.UI.TexPin, bmNormal, tfPoint
      );
    end;
    v := (a0 + a1) * 0.5;
    g2.PicRect(
      Round(v.x - 8), Round(v.y - 8), 16, 16,
      $ff000000,
      App.UI.TexLink, bmNormal, tfPoint
    );
    g2.PicRect(
      Round(v.x - 8), Round(v.y - 8), 16, 16,
      $ff00cc00, App.UI.TexLink, bmNormal, tfPoint
    );
  end;
  if App.Scene2DData.SelectJoint = Self then
  begin
    Str := 'dist';
    App.UI.FontCode.Print(
      Round(v.x - App.UI.FontCode.TextWidth(Str) * 0.5),
      Round(v.y - App.UI.FontCode.TextHeight('A') - 8),
      1, 1, $ff000000, Str, bmNormal, tfPoint
    );
  end;
end;
//TScene2DJointDataDistance END

//TScene2DJointDataRevolute BEGIN
function TScene2DJointDataRevolute.GetJoint: TG2Scene2DRevoluteJoint;
begin
  Result := TG2Scene2DRevoluteJoint(_Joint);
end;

procedure TScene2DJointDataRevolute.SetJoint(const Value: TG2Scene2DRevoluteJoint);
begin
  _Joint := Value;
end;

function TScene2DJointDataRevolute.GetRigidBodyA: TScene2DComponentDataRigidBody;
begin
  if Joint.RigidBodyA <> nil then
  Result := TScene2DComponentDataRigidBody(Joint.RigidBodyA.UserData)
  else
  Result := nil;
end;

procedure TScene2DJointDataRevolute.SetRigidBodyA(const Value: TScene2DComponentDataRigidBody);
begin
  if Value <> nil then
  Joint.RigidBodyA := Value.Component
  else
  Joint.RigidBodyA := nil;
end;

function TScene2DJointDataRevolute.GetRigidBodyB: TScene2DComponentDataRigidBody;
begin
  if Joint.RigidBodyB <> nil then
  Result := TScene2DComponentDataRigidBody(Joint.RigidBodyB.UserData)
  else
  Result := nil;
end;

procedure TScene2DJointDataRevolute.SetRigidBodyB(const Value: TScene2DComponentDataRigidBody);
begin
  if Value <> nil then
  Joint.RigidBodyB := Value.Component
  else
  Joint.RigidBodyB := nil;
end;

function TScene2DJointDataRevolute.GetAnchor: TG2Vec2;
begin
  Result := Joint.Anchor;
end;

procedure TScene2DJointDataRevolute.SetAnchor(const Value: TG2Vec2);
begin
  Joint.Anchor := Value;
end;

function TScene2DJointDataRevolute.GetPosition: TG2Vec2;
begin
  if Joint <> nil then
  Result := Joint.Anchor
  else
  Result := _Position;
end;

procedure TScene2DJointDataRevolute.SetPosition(const Value: TG2Vec2);
begin
  _Position := Value;
  if Joint <> nil then Joint.Anchor := _Position;
end;

function TScene2DJointDataRevolute.GetEditor: TScene2DEditor;
begin
  Result := TScene2DEditorJointRevolute.Instance;
  TScene2DEditorJointRevolute.Instance.Joint := Self;
end;

constructor TScene2DJointDataRevolute.Create;
begin
  inherited Create;
  _Position.SetZero;
  if TScene2DEditorJointRevolute.Instance = nil then
  TScene2DEditorJointRevolute.Instance := TScene2DEditorJointRevolute.Create;
  TScene2DEditorJointRevolute.Instance.RefInc;
end;

destructor TScene2DJointDataRevolute.Destroy;
begin
  TScene2DEditorJointRevolute.Instance.RefDec;
  inherited Destroy;
end;

function TScene2DJointDataRevolute.Select(const Display: TG2Display2D; const x, y: TG2Float): Boolean;
begin
  Result := inherited Select(Display, x, y);
end;

procedure TScene2DJointDataRevolute.DebugDraw(const Display: TG2Display2D);
  var v, v1: TG2Vec2;
  var xf, xfrb: TG2Transform2;
  var Str: String;
  var c: TG2Color;
begin
  v := Display.CoordToScreen(Position);
  if App.Scene2DData.SelectJoint = Self then
  begin
    Str := 'rev';
    App.UI.FontCode.Print(
      Round(v.x - App.UI.FontCode.TextWidth(Str) * 0.5),
      Round(v.y - App.UI.FontCode.TextHeight('A') - 8),
      1, 1, $ff000000, Str, bmNormal, tfPoint
    );
  end
  else
  begin
    if RigidBodyA <> nil then
    begin
      xf := RigidBodyA.Component.Owner.Transform;
      xfrb := RigidBodyA.Component.Transform;
      G2Transform2Mul(@xf, @xfrb, @xf);
      v1 := Display.CoordToScreen(xf.p);
      g2.PolyBegin(ptLines, App.UI.TexDots);
      g2.PolyAdd(v, G2Vec2(0, 0.5), $ffff0000);
      g2.PolyAdd(v1, G2Vec2((v1 - v).Len * 0.05, 0.5), $ffff0000);
      g2.PolyEnd;
    end;
    if RigidBodyB <> nil then
    begin
      xf := RigidBodyB.Component.Owner.Transform;
      xfrb := RigidBodyB.Component.Transform;
      G2Transform2Mul(@xf, @xfrb, @xf);
      v1 := Display.CoordToScreen(xf.p);
      g2.PolyBegin(ptLines, App.UI.TexDots);
      g2.PolyAdd(v, G2Vec2(0, 0.5), $ffff0000);
      g2.PolyAdd(v1, G2Vec2((v1 - v).Len * 0.05, 0.5), $ffff0000);
      g2.PolyEnd;
    end;
  end;
  if (RigidBodyA = nil)
  or (RigidBodyB = nil) then
  c := G2LerpColor($ff404040, $ffff0000, Abs(Sin(G2PiTime(300))))
  else
  c := $ff00cc00;
  g2.PicRect(
    Round(v.x - 8), Round(v.y - 8), 16, 16,
    c,
    App.UI.TexLink, bmNormal, tfPoint
  );
end;
//TScene2DJointDataRevolute END

//TScene2DData BEIGN
procedure TScene2DData.UpdateProperties;
begin
  _PropGravity := Scene.Gravity;
  _GridSizeX := Scene.GridSizeX;
  _GridSizeY := Scene.GridSizeY;
end;

procedure TScene2DData.AddComponentTypePair(
  const ComponentClass: CG2Scene2DComponent;
  const ComponentDataClass: CScene2DComponentData;
  const AddProc: TG2ProcObj
);
  var Pair: PComponentTypePair;
begin
  New(Pair);
  Pair^.Component := ComponentClass;
  Pair^.ComponentData := ComponentDataClass;
  Pair^.AddProc := AddProc;
  ComponentList.Add(Pair);
end;

procedure TScene2DData.SetEditor(const Value: TScene2DEditor);
begin
  if _Editor = Value then Exit;
  if _Editor <> nil then
  _Editor.Finalize;
  _Editor := Value;
  if _Editor <> nil then
  _Editor.Initialize;
end;

procedure TScene2DData.OnGravityChange(const Sender: Pointer);
begin
  Scene.Gravity := _PropGravity;
end;

procedure TScene2DData.OnGridSizeXChange(const Sender: Pointer);
begin
  Scene.GridSizeX := _GridSizeX;
end;

procedure TScene2DData.OnGridSizeYChange(const Sender: Pointer);
begin
  Scene.GridSizeY := _GridSizeY;
end;

procedure TScene2DData.FindSelectedJoints(var JointList: TG2Scene2DJointList);
  function IsEntityInSelection(const e: TG2Scene2DEntity): Boolean;
    var Data: TScene2DEntityData;
  begin
    if not Assigned(e) then Exit(False);
    Data := TScene2DEntityData(e.UserData);
    if not Assigned(Data) then Exit(False);
    while Assigned(Data) do
    begin
      if Data.Selected then Exit(True);
      if Assigned(Data.Entity.Parent) then Data := TScene2DEntityData(Data.Entity.Parent.UserData)
      else Exit(False);
    end;
    Result := False;
  end;
  var Joint: TG2Scene2DJoint;
  var JointDistance: TG2Scene2DDistanceJoint absolute Joint;
  var JointRevolute: TG2Scene2DRevoluteJoint absolute Joint;
  var i: Integer;
begin
  JointList.Clear;
  for i := 0 to Scene.JointCount - 1 do
  begin
    Joint := Scene.Joints[i];
    if Joint is TG2Scene2DDistanceJoint then
    begin
      if (JointDistance.RigidBodyA <> nil)
      and (JointDistance.RigidBodyA.Owner <> nil)
      and (IsEntityInSelection(JointDistance.RigidBodyA.Owner))
      and (JointDistance.RigidBodyA <> nil)
      and (JointDistance.RigidBodyA.Owner <> nil)
      and (IsEntityInSelection(JointDistance.RigidBodyA.Owner)) then
      begin
        JointList.Add(Joint);
      end;
    end
    else if Joint is TG2Scene2DRevoluteJoint then
    begin
      if (JointRevolute.RigidBodyA <> nil)
      and (JointRevolute.RigidBodyA.Owner <> nil)
      and (IsEntityInSelection(JointRevolute.RigidBodyA.Owner))
      and (JointRevolute.RigidBodyA <> nil)
      and (JointRevolute.RigidBodyA.Owner <> nil)
      and (IsEntityInSelection(JointRevolute.RigidBodyA.Owner)) then
      begin
        JointList.Add(Joint);
      end;
    end;
  end;
end;

function TScene2DData.FindEntity(const Name: AnsiString; const IgnoreEntity: TG2Scene2DEntity): TG2Scene2DEntity;
  var i: Integer;
begin
  for i := 0 to _Scene.EntityCount - 1 do
  if _Scene.Entities[i] <> IgnoreEntity then
  begin
    if LowerCase(_Scene.Entities[i].Name) = LowerCase(Name) then
    Exit(_Scene.Entities[i]);
  end;
  Exit(nil);
end;

function TScene2DData.CreateEntity(
  const Transform: TG2Transform2
): TG2Scene2DEntity;
  var i: Integer;
  var NameBase, EntityName: AnsiString;
  var NameIndex: Integer;
  var EntityData: TScene2DEntityData;
begin
  NameBase := 'Entity';
  NameIndex := 0;
  EntityName := NameBase;
  while FindEntity(EntityName) <> nil do
  begin
    Inc(NameIndex);
    EntityName := NameBase + IntToStr(NameIndex);
  end;
  Result := TG2Scene2DEntity.Create(App.Scene2DData.Scene);
  Result.Transform := Transform;
  Result.Name := EntityName;
  EntityData := TScene2DEntityData.Create(Result);
  for i := 0 to TUIWorkspaceScene2DStructure.WorkspaceList.Count - 1 do
  TUIWorkspaceScene2DStructure.WorkspaceList[i].OnCreateEntity(Result);
end;

procedure TScene2DData.DeleteEntity(var Entity: TG2Scene2DEntity);
  var i: Integer;
  var EntityData: TScene2DEntityData;
  var Component: TG2Scene2DComponent;
begin
  for i := 0 to TUIWorkspaceScene2DStructure.WorkspaceList.Count - 1 do
  TUIWorkspaceScene2DStructure.WorkspaceList[i].OnDeleteEntity(Entity);
  for i := Entity.ComponentCount - 1 downto 0 do
  begin
    Component := Entity.Components[i];
    DeleteComponent(Component);
  end;
  EntityData := TScene2DEntityData(Entity.UserData);
  EntityData.Free;
  Entity.Free;
  Entity := nil;
end;

procedure TScene2DData.CopySelectedEntity;
  var GUIDList: TG2QuickListAnsiString;
  procedure BackupGUID(const e: TG2Scene2DEntity);
    var i: Integer;
  begin
    GUIDList.Add(e.GUID);
    e.NewGUID;
    for i := 0 to e.ChildCount - 1 do
    BackupGUID(e.Children[i]);
  end;
  var CurGUID: Integer;
  procedure RecoverGUID(const e: TG2Scene2DEntity);
    var i: Integer;
  begin
    e.GUID := GUIDList[CurGUID];
    Inc(CurGUID);
    for i := 0 to e.ChildCount - 1 do
    RecoverGUID(e.Children[i]);
  end;
  var CopyStream: TMemoryStream;
  var TopEntities: TG2Scene2DEntityList;
  var jl: TG2Scene2DJointList;
  var i, j: Integer;
  var b: Boolean;
  var dm: TG2DataManager;
begin
  if Selection.Count = 0 then Exit;
  CopyStream := TMemoryStream.Create;
  try
    TopEntities.Clear;
    for i := 0 to Selection.Count - 1 do
    begin
      if Selection[i].Parent = nil then
      TopEntities.Add(Selection[i])
      else
      begin
        b := True;
        for j := 0 to Selection.Count - 1 do
        if Selection[j] = Selection[i].Parent then
        begin
          b := False;
          Break;
        end;
        if b then
        begin
          TopEntities.Add(Selection[i]);
        end;
      end;
    end;
    jl.Clear;
    FindSelectedJoints(jl);
    dm := TG2DataManager.Create(CopyStream, dmWrite);
    dm.WriteIntS32(TopEntities.Count);
    GUIDList.Clear;
    for i := 0 to TopEntities.Count - 1 do
    BackupGUID(TopEntities[i]);
    for i := 0 to TopEntities.Count - 1 do
    TopEntities[i].Save(dm);
    dm.WriteIntS32(jl.Count);
    for i := 0 to jl.Count - 1 do
    jl[i].Save(dm);
    CurGUID := 0;
    for i := 0 to TopEntities.Count - 1 do
    RecoverGUID(TopEntities[i]);
    dm.Free;
    Clipboard.SetFormat(App.cbf_scene2d_object, CopyStream);
  finally
    CopyStream.Free;
  end;
end;

procedure TScene2DData.PasteEntity(const Pos: TG2Vec2);
  var NewEntities: TG2Scene2DEntityList;
  procedure CreateNewEntityData(const Entity: TG2Scene2DEntity);
    var i: Integer;
  begin
    Entity.NewGUID;
    VerifyEntityName(Entity);
    //NewEntities.Add(Entity);
    CreateEntityData(Entity);
    for i := 0 to Entity.ChildCount - 1 do
    CreateNewEntityData(Entity.Children[i]);
    for i := 0 to TUIWorkspaceScene2DStructure.WorkspaceList.Count - 1 do
    TUIWorkspaceScene2DStructure.WorkspaceList[i].OnCreateEntity(Entity);
  end;
  var PasteStream: TMemoryStream;
  var n, i: Integer;
  var dm: TG2DataManager;
  var Entity: TG2Scene2DEntity;
  var Joint: TG2Scene2DJoint;
  var v: TG2Vec2;
begin
  if not Clipboard.HasFormat(App.cbf_scene2d_object) then Exit;
  PasteStream := TMemoryStream.Create;
  Clipboard.GetFormat(App.cbf_scene2d_object, PasteStream);
  PasteStream.Position := 0;
  dm := TG2DataManager.Create(PasteStream);
  n := dm.ReadIntS32;
  NewEntities.Clear;
  for i := 0 to n - 1 do
  begin
    Entity := TG2Scene2DEntity.Create(_Scene);
    Entity.Load(dm);
    NewEntities.Add(Entity);
  end;
  n := dm.ReadIntS32;
  for i := 0 to n - 1 do
  begin
    Joint := TG2Scene2DJoint.LoadClass(dm, _Scene);
    CreateJointData(Joint);
  end;
  for i := 0 to NewEntities.Count - 1 do
  CreateNewEntityData(NewEntities[i]);
  if NewEntities.Count > 0 then
  begin
    v := NewEntities[0].Transform.p;
    for i := 1 to NewEntities.Count - 1 do
    v += NewEntities[i].Transform.p;
    v := Pos - (v * (1 / NewEntities.Count));
    for i := 0 to NewEntities.Count - 1 do
    NewEntities[i].Transform := G2Transform2(NewEntities[i].Transform.p + v, NewEntities[i].Transform.r);
  end;
  dm.Free;
  PasteStream.Free;
end;

procedure TScene2DData.SavePrefab;
  var GUIDList: TG2QuickListAnsiString;
  procedure BackupGUID(const e: TG2Scene2DEntity);
    var i: Integer;
  begin
    GUIDList.Add(e.GUID);
    e.NewGUID;
    for i := 0 to e.ChildCount - 1 do
    BackupGUID(e.Children[i]);
  end;
  var CurGUID: Integer;
  procedure RecoverGUID(const e: TG2Scene2DEntity);
    var i: Integer;
  begin
    e.GUID := GUIDList[CurGUID];
    Inc(CurGUID);
    for i := 0 to e.ChildCount - 1 do
    RecoverGUID(e.Children[i]);
  end;
  var sd: TSaveDialog;
  var dm: TG2DataManager;
  var jl: TG2Scene2DJointList;
  var i: Integer;
begin
  if Selection.Count <> 1 then Exit;
  sd := TSaveDialog.Create(nil);
  sd.DefaultExt := '.g2prefab2d';
  if sd.Execute then
  begin
    dm := TG2DataManager.Create(sd.FileName, dmWrite);
    try
      GUIDList.Clear;
      BackupGUID(Selection[0]);
      dm.WriteStringARaw('PF2D');
      Selection[0].Save(dm);
      jl.Clear;
      FindSelectedJoints(jl);
      dm.WriteIntS32(jl.Count);
      for i := 0 to jl.Count - 1 do
      jl[i].Save(dm);
      CurGUID := 0;
      RecoverGUID(Selection[0]);
    finally
      dm.Free;
    end;
  end;
  sd.Free;
end;

function TScene2DData.CreatePrefab(const Transform: TG2Transform2; const PrefabName: String): TG2Scene2DEntity;
  var jl: TG2Scene2DJointList;
  procedure ProcessEntity(const e: TG2Scene2DEntity);
    var i: Integer;
  begin
    CreateEntityData(e);
    e.NewGUID;
    VerifyEntityName(e);
    for i := 0 to e.ChildCount - 1 do
    ProcessEntity(e.Children[i]);
    for i := 0 to TUIWorkspaceScene2DStructure.WorkspaceList.Count - 1 do
    TUIWorkspaceScene2DStructure.WorkspaceList[i].OnCreateEntity(e);
  end;
  var dm: TG2DataManager;
  var Def: array[0..3] of AnsiChar;
  var n, i: Integer;
  var Shift: TG2Vec2;
  var Joint: TG2Scene2DJoint;
begin
  dm := TG2DataManager.Create(PrefabName, dmAsset);
  dm.ReadBuffer(@Def, 4);
  if Def = 'PF2D' then
  begin
    Result := App.Scene2DData.CreateEntity(Transform);
    Result.Load(dm);
    Shift := Transform.p - Result.Transform.p;
    n := dm.ReadIntS32;
    jl.Clear;
    for i := 0 to n - 1 do
    begin
      Joint := TG2Scene2DJoint.LoadClass(dm, Scene);
      //if Joint is TG2Scene2DDistanceJoint then
      //begin
      //  TG2Scene2DDistanceJoint(Joint).AnchorA := TG2Scene2DDistanceJoint(Joint).AnchorA + Shift;
      //  TG2Scene2DDistanceJoint(Joint).AnchorB := TG2Scene2DDistanceJoint(Joint).AnchorB + Shift;
      //end
      //else if Joint is TG2Scene2DRevoluteJoint then
      //begin
      //  TG2Scene2DRevoluteJoint(Joint).Anchor := TG2Scene2DRevoluteJoint(Joint).Anchor + Shift;
      //end;
      jl.Add(Joint);
    end;
    ProcessEntity(Result);
    for i := 0 to jl.Count - 1 do
    CreateJointData(jl[i]);
    Result.Transform := Transform;
    if Selection.Count = 0 then
    begin
      SelectJoint := nil;
      Editor := nil;
      SelectionUpdateStart;
      Selection.Add(Result);
      SelectionUpdateEnd;
    end;
  end;
  dm.Free;
end;

procedure TScene2DData.CreateEntityData(const Entity: TG2Scene2DEntity);
  var EntityData: TScene2DEntityData;
  var Component: TG2Scene2DComponent;
  var ComponentData: TScene2DComponentData;
  var j: Integer;
begin
  EntityData := TScene2DEntityData.Create(Entity);
end;

procedure TScene2DData.CreateJointData(const Joint: TG2Scene2DJoint);
  var JointData: TScene2DJointData;
begin
  if Joint is TG2Scene2DDistanceJoint then
  begin
    JointData := TScene2DJointDataDistance.Create;
    Joint.UserData := JointData;
    TScene2DJointDataDistance(JointData).Joint := TG2Scene2DDistanceJoint(Joint);
    TScene2DJointDataDistance(JointData).AnchorA := TG2Scene2DDistanceJoint(Joint).AnchorA;
    TScene2DJointDataDistance(JointData).AnchorB := TG2Scene2DDistanceJoint(Joint).AnchorB;
  end
  else if Joint is TG2Scene2DRevoluteJoint then
  begin
    JointData := TScene2DJointDataRevolute.Create;
    TScene2DJointDataRevolute(JointData).Position := TG2Scene2DRevoluteJoint(Joint).Anchor;
    Joint.UserData := JointData;
    TScene2DJointDataRevolute(JointData).Joint := TG2Scene2DRevoluteJoint(Joint);
    TScene2DJointDataRevolute(JointData).Anchor := TG2Scene2DRevoluteJoint(Joint).Anchor;
  end;
end;

procedure TScene2DData.VerifyEntityName(const Entity: TG2Scene2DEntity);
  var NameBase, EntityName, str: String;
  var NameIndex, n, i: Integer;
begin
  if Entity.Name <> '' then
  NameBase := Entity.Name
  else
  NameBase := 'Entity';
  n := Length(NameBase);
  while (n > 0) and (StrToIntDef(NameBase[n], 0) = StrToIntDef(NameBase[n], 1)) do Dec(n);
  if n < Length(NameBase) then
  begin
    str := '';
    for i := n + 1 to Length(NameBase) do
    str += NameBase[i];
    NameIndex := StrToIntDef(str, 0) + 1;
    Delete(NameBase, n + 1, Length(NameBase) - n);
  end
  else
  NameIndex := 0;
  EntityName := NameBase;
  while FindEntity(EntityName, Entity) <> nil do
  begin
    Inc(NameIndex);
    EntityName := NameBase + IntToStr(NameIndex);
  end;
  Entity.Name := EntityName;
end;

function TScene2DData.CreateJointDistance(const Position: TG2Vec2): TG2Scene2DDistanceJoint;
  var Data: TScene2DJointDataDistance;
begin
  Result := TG2Scene2DDistanceJoint.Create(_Scene);
  Data := TScene2DJointDataDistance.Create;
  Data.Position := Position;
  Data.Joint := Result;
  Result.UserData := Data;
end;

function TScene2DData.CreateJointRevolute(const Position: TG2Vec2): TG2Scene2DRevoluteJoint;
  var Data: TScene2DJointDataRevolute;
begin
  Result := TG2Scene2DRevoluteJoint.Create(_Scene);
  Data := TScene2DJointDataRevolute.Create;
  Data.Position := Position;
  Data.Joint := Result;
  Result.UserData := Data;
end;

procedure TScene2DData.DeleteJoint(var Joint: TG2Scene2DJoint);
  var Data: TScene2DJointData;
begin
  Data := TScene2DJointData(Joint.UserData);
  if Data = SelectJoint then
  SelectJoint := nil;
  Data.Free;
  Joint.Free;
  Joint := nil;
end;

function TScene2DData.CreateComponentSprite: TG2Scene2DComponentSprite;
begin
  Result := TG2Scene2DComponentSprite.Create(_Scene);
  Result.UserData := TScene2DComponentDataSprite.Create;
  TScene2DComponentDataSprite(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentText: TG2Scene2DComponentText;
begin
  Result := TG2Scene2DComponentText.Create(_Scene);
  Result.UserData := TScene2DComponentDataText.Create;
  TScene2DComponentDataText(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentBackground: TG2Scene2DComponentBackground;
begin
  Result := TG2Scene2DComponentBackground.Create(_Scene);
  Result.UserData := TScene2DComponentDataBackground.Create;
  TScene2DComponentDataBackground(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentSpineAnimation: TG2Scene2DComponentSpineAnimation;
begin
  Result := TG2Scene2DComponentSpineAnimation.Create(_Scene);
  Result.UserData := TScene2DComponentDataSpineAnimation.Create;
  TScene2DComponentDataSpineAnimation(Result.UserData).Component := Result;
  Result.Scale := G2Vec2(0.002, 0.002);
end;

function TScene2DData.CreateComponentEffect: TG2Scene2DComponentEffect;
begin
  Result := TG2Scene2DComponentEffect.Create(_Scene);
  Result.UserData := TScene2DComponentDataEffect.Create;
  TScene2DComponentDataEffect(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentRigidBody: TG2Scene2DComponentRigidBody;
begin
  Result := TG2Scene2DComponentRigidBody.Create(_Scene);
  Result.UserData := TScene2DComponentDataRigidBody.Create;
  TScene2DComponentDataRigidBody(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentCharacter: TG2Scene2DComponentCharacter;
begin
  Result := TG2Scene2DComponentCharacter.Create(_Scene);
  Result.UserData := TScene2DComponentDataCharacter.Create;
  TScene2DComponentDataCharacter(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentShapePoly: TG2Scene2DComponentCollisionShapePoly;
begin
  Result := TG2Scene2DComponentCollisionShapePoly.Create(_Scene);
  Result.UserData := TScene2DComponentDataShapePoly.Create;
  TScene2DComponentDataShapePoly(Result.UserData).Component := Result;
  Result.SetUpBox(1, 1);
end;

function TScene2DData.CreateComponentShapeBox: TG2Scene2DComponentCollisionShapeBox;
begin
  Result := TG2Scene2DComponentCollisionShapeBox.Create(_Scene);
  Result.UserData := TScene2DComponentDataShapeBox.Create;
  TScene2DComponentDataShapeBox(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentShapeCircle: TG2Scene2DComponentCollisionShapeCircle;
begin
  Result := TG2Scene2DComponentCollisionShapeCircle.Create(_Scene);
  Result.UserData := TScene2DComponentDataShapeCircle.Create;
  TScene2DComponentDataShapeCircle(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentShapeEdge: TG2Scene2DComponentCollisionShapeEdge;
begin
  Result := TG2Scene2DComponentCollisionShapeEdge.Create(_Scene);
  Result.UserData := TScene2DComponentDataShapeEdge.Create;
  TScene2DComponentDataShapeEdge(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentShapeChain: TG2Scene2DComponentCollisionShapeChain;
begin
  Result := TG2Scene2DComponentCollisionShapeChain.Create(_Scene);
  Result.UserData := TScene2DComponentDataShapeChain.Create;
  TScene2DComponentDataShapeChain(Result.UserData).Component := Result;
end;

function TScene2DData.CreateComponentPoly: TG2Scene2DComponentPoly;
begin
  Result := TG2Scene2DComponentPoly.Create(_Scene);
  Result.UserData := TScene2DComponentDataPoly.Create;
  TScene2DComponentDataPoly(Result.UserData).Component := Result;
  TScene2DComponentDataPoly(Result.UserData).UpdateComponent;
end;

function TScene2DData.Pick(const ScenePos: TG2Vec2): TG2Scene2DEntity;
  var Entity: TG2Scene2DEntity;
  var Component: TG2Scene2DComponent;
  var i, j, Layer, LayerPick: Integer;
begin
  Result := nil;
  LayerPick := 0;
  for i := 0 to _Scene.EntityCount - 1 do
  begin
    Entity := _Scene.Entities[i];
    for j := 0 to Entity.ComponentCount - 1 do
    if Result <> Entity then
    begin
      Component := Entity.Components[j];
      if TScene2DComponentData(Component.UserData).Pick(ScenePos.x, ScenePos.y) then
      begin
        Layer := TScene2DComponentData(Component.UserData).PickLayer;
        if (Result = nil)
        or (Layer > LayerPick) then
        begin
          Result := Entity;
          LayerPick := Layer;
        end;
      end;
    end;
  end;
end;

procedure TScene2DData.DeleteComponent(var Component: TG2Scene2DComponent);
begin
  Component.Detach;
  TScene2DComponentData(Component.UserData).Free;
  Component.UserData := nil;
  Component.Free;
  Component := nil;
end;

procedure TScene2DData.SelectionUpdateStart;
  var i: Integer;
begin
  for i := 0 to Selection.Count - 1 do
  TScene2DEntityData(Selection[i].UserData).Selected := False;
end;

procedure TScene2DData.SelectionUpdateEnd;
  var i: Integer;
  var xf: TG2Transform2;
begin
  if SelectJoint <> nil then
  Selection.Clear;
  for i := 0 to Selection.Count - 1 do
  TScene2DEntityData(Selection[i].UserData).Selected := True;
  UpdateSelectionPos;
  sxf.r := G2Rotation2;
  xf := G2Transform2(sxf.p, G2Rotation2);
  for i := 0 to Selection.Count - 1 do
  G2Transform2MulInv(
    @TScene2DEntityData(Selection[i].UserData).oxf,
    @Selection[i].Transform,
    @xf
  );
  if Selection.Count = 1 then
  begin
    TScene2DEntityData(Selection[0].UserData).UpdateProperties;
    PropertySet := TScene2DEntityData(Selection[0].UserData).Properties;
  end
  else
  begin
    UpdateProperties;
    PropertySet := SceneProperties;
  end;
end;

procedure TScene2DData.UpdateSelectionPos;
  var i: Integer;
begin
  if Selection.Count = 0 then Exit;
  sxf.p.SetZero;
  for i := 0 to Selection.Count - 1 do
  sxf.p += Selection[i].Transform.p;
  sxf.p *= 1 / Selection.Count;
end;

procedure TScene2DData.BtnAddComponent;
  var i: Integer;
begin
  if Selection.Count = 1 then
  begin
    _ComponentSet.Clear;
    for i := 0 to ComponentList.Count - 1 do
    if ComponentList[i]^.Component.CanAttach(Selection[0]) then
    _ComponentSet.PropButton(ComponentList[i]^.ComponentData.GetName, ComponentList[i]^.AddProc);
    _ComponentSet.PropButton('Cancel', @BtnComponentCancel);
    PropertySet := _ComponentSet;
  end;
end;

procedure TScene2DData.BtnComponentSprite;
  var Component: TG2Scene2DComponentSprite;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentSprite;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentText;
  var Component: TG2Scene2DComponentText;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentText;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentBackground;
  var Component: TG2Scene2DComponentBackground;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentBackground;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentSpineAnimation;
  var Component: TG2Scene2DComponentSpineAnimation;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentSpineAnimation;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentEffect;
  var Component: TG2Scene2DComponentEffect;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentEffect;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentRigidBody;
  var Component: TG2Scene2DComponentRigidBody;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentRigidBody;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentCharacter;
  var Component: TG2Scene2DComponentCharacter;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentCharacter;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentShapePoly;
  var Component: TG2Scene2DComponentCollisionShapePoly;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentShapePoly;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentShapeBox;
  var Component: TG2Scene2DComponentCollisionShapePoly;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentShapeBox;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentShapeCircle;
  var Component: TG2Scene2DComponentCollisionShapeCircle;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentShapeCircle;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentShapeEdge;
  var Component: TG2Scene2DComponentCollisionShapeEdge;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentShapeEdge;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentShapeChain;
  var Component: TG2Scene2DComponentCollisionShapeChain;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentShapeChain;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentPoly;
  var Component: TG2Scene2DComponentPoly;
begin
  if Selection.Count = 1 then
  begin
    Component := CreateComponentPoly;
    Component.Attach(Selection[0]);
    SelectionUpdateStart;
    SelectionUpdateEnd;
  end;
end;

procedure TScene2DData.BtnComponentCancel;
begin
  SelectionUpdateStart;
  SelectionUpdateEnd;
end;

procedure TScene2DData.LoadScene(const SceneName: String);
  var dm: TG2DataManager;
begin
  dm := TG2DataManager.Create(SceneName, dmAsset);
  try
    App.Scene2DData.ClearScene;
    App.Scene2DData.Scene.Load(dm);
    App.Scene2DData.OnLoad;
    ScenePath := SceneName;
  finally
    dm.Free;
  end;
end;

procedure TScene2DData.ClearScene;
  var i: Integer;
  var e: TG2Scene2DEntity;
  var j: TG2Scene2DJoint;
begin
  Editor := nil;
  Scene.Simulate := False;
  SelectJoint := nil;
  SelectionUpdateStart;
  Selection.Clear;
  SelectionUpdateEnd;
  for i := _Scene.JointCount - 1 downto 0 do
  begin
    j := _Scene.Joints[i];
    DeleteJoint(j);
  end;
  while _Scene.EntityCount > 0 do
  begin
    i := _Scene.EntityCount - 1;
    while (i > 0) and (_Scene.Entities[i].Parent <> nil) do Dec(i);
    e := _Scene.Entities[i];
    DeleteEntity(e);
  end;
  ScenePath := '';
end;

procedure TScene2DData.Simulate;
  var i: Integer;
  var rb: TG2Scene2DComponentRigidBody;
  var dm: TG2DataManager;
  var PathBackup: String;
begin
  if _Editor <> nil then _Editor := nil;
  PathBackup := ScenePath;
  if Scene.Simulate then
  begin
    Scene.Simulate := False;
    ClearScene;
    _SavedStream.Seek(0, soFromBeginning);
    dm := TG2DataManager.Create(_SavedStream, dmRead);
    Scene.Load(dm);
    dm.Free;
    OnLoad;
  end
  else
  begin
    SelectJoint := nil;
    SelectionUpdateStart;
    Selection.Clear;
    SelectionUpdateEnd;
    _SavedStream.Seek(0, soFromBeginning);
    dm := TG2DataManager.Create(_SavedStream, dmWrite);
    Scene.Save(dm);
    dm.Free;
    for i := 0 to Scene.EntityCount - 1 do
    begin
      rb := TG2Scene2DComponentRigidBody(Scene.Entities[i].ComponentOfType[TG2Scene2DComponentRigidBody]);
      if rb <> nil then rb.Enabled := True;
    end;
    for i := 0 to Scene.JointCount - 1 do
    begin
      Scene.Joints[i].Enabled := True;
    end;
    Scene.Simulate := True;
  end;
  ScenePath := PathBackup;
end;

procedure TScene2DData.OnLoad;
  var i, j: Integer;
  var Entity: TG2Scene2DEntity;
  var Joint: TG2Scene2DJoint;
  var JointData: TScene2DJointData;
begin
  for i := 0 to Scene.EntityCount - 1 do
  begin
    Entity := Scene.Entities[i];
    CreateEntityData(Entity);
    for j := 0 to TUIWorkspaceScene2DStructure.WorkspaceList.Count - 1 do
    TUIWorkspaceScene2DStructure.WorkspaceList[j].OnCreateEntity(Entity);
  end;
  for i := 0 to _Scene.JointCount - 1 do
  begin
    Joint := _Scene.Joints[i];
    CreateJointData(Joint);
  end;
  UpdateProperties;
end;

procedure TScene2DData.Initialize;
  var Prop: TPropertySet.TProperty;
begin
  Selection.Clear;
  SelectJoint := nil;
  _SavedStream := TMemoryStream.Create;
  _Scene := TG2Scene2D.Create;
  _ComponentSet := TPropertySet.Create;
  ComponentList.Clear;
  _Editor := nil;
  ScenePath := '';
  AddComponentTypePair(TG2Scene2DComponentSprite, TScene2DComponentDataSprite, @BtnComponentSprite);
  AddComponentTypePair(TG2Scene2DComponentText, TScene2DComponentDataText, @BtnComponentText);
  AddComponentTypePair(TG2Scene2DComponentBackground, TScene2DComponentDataBackground, @BtnComponentBackground);
  AddComponentTypePair(TG2Scene2DComponentSpineAnimation, TScene2DComponentDataSpineAnimation, @BtnComponentSpineAnimation);
  AddComponentTypePair(TG2Scene2DComponentEffect, TScene2DComponentDataEffect, @BtnComponentEffect);
  AddComponentTypePair(TG2Scene2DComponentPoly, TScene2DComponentDataPoly, @BtnComponentPoly);
  AddComponentTypePair(TG2Scene2DComponentRigidBody, TScene2DComponentDataRigidBody, @BtnComponentRigidBody);
  AddComponentTypePair(TG2Scene2DComponentCharacter, TScene2DComponentDataCharacter, @BtnComponentCharacter);
  AddComponentTypePair(TG2Scene2DComponentCollisionShapePoly, TScene2DComponentDataShapePoly, @BtnComponentShapePoly);
  AddComponentTypePair(TG2Scene2DComponentCollisionShapePoly, TScene2DComponentDataShapeBox, @BtnComponentShapeBox);
  AddComponentTypePair(TG2Scene2DComponentCollisionShapeCircle, TScene2DComponentDataShapeCircle, @BtnComponentShapeCircle);
  AddComponentTypePair(TG2Scene2DComponentCollisionShapeEdge, TScene2DComponentDataShapeEdge, @BtnComponentShapeEdge);
  AddComponentTypePair(TG2Scene2DComponentCollisionShapeChain, TScene2DComponentDataShapeChain, @BtnComponentShapeChain);
  SceneProperties := TPropertySet.Create;
  SceneProperties.PropVec2('Gravity', @_PropGravity, nil, @OnGravityChange);
  Prop := SceneProperties.PropGroup('Grid');
  SceneProperties.PropBool('Enable Grid', @_Scene.GridEnable, Prop, nil);
  SceneProperties.PropFloat('Size X', @_GridSizeX, Prop, @OnGridSizeXChange);
  SceneProperties.PropFloat('Size Y', @_GridSizeY, Prop, @OnGridSizeYChange);
  SceneProperties.PropFloat('Offset X', @_Scene.GridOffsetX, Prop, nil);
  SceneProperties.PropFloat('Offset Y', @_Scene.GridOffsetY, Prop, nil);
  _PropertySet := SceneProperties;
  UpdateProperties;
end;

procedure TScene2DData.Finalize;
  var i: Integer;
begin
  _PropertySet := nil;
  SceneProperties.Free;
  ClearScene;
  for i := 0 to ComponentList.Count - 1 do
  Dispose(ComponentList[i]);
  ComponentList.Clear;
  _Scene.Free;
  _Scene := nil;
  _ComponentSet.Free;
  _ComponentSet := nil;
  _SavedStream.Free;
end;

procedure TScene2DData.KeyDown(const Key: Integer);
  var i: Integer;
  var e: TG2Scene2DEntity;
begin
  if Editor <> nil then
  Editor.KeyDown(Key)
  else
  case Key of
    G2K_Delete:
    begin
      if (TUIWorkspace.Focus is TUIWorkspaceScene2D)
      or (TUIWorkspace.Focus is TUIWorkspaceScene2DStructure) then
      begin
        while Selection.Count > 0 do
        begin
          e := Selection.Last;
          DeleteEntity(e);
        end;
      end;
    end;
  end;
end;

procedure TScene2DData.KeyUp(const Key: Integer);
begin
  if Editor <> nil then
  Editor.KeyUp(Key);
end;

procedure TScene2DData.Update;
begin
  if Selection.Count = 1 then
  TScene2DEntityData(Selection[0].UserData).SyncProperties;
  if Assigned(_Editor) then Editor.Update;
end;

procedure TScene2DData.MouseClick(const Display: TG2Display2D; const Button: Integer; const x, y: TG2Float);
  var i: Integer;
  var EntityPick: TG2Scene2DEntity;
begin
  if _Scene.Simulate then Exit;
  EntityPick := Pick(Display.CoordToDisplay(G2Vec2(x, y)));
  SelectJoint := nil;
  SelectionUpdateStart;
  if g2.KeyDown[G2K_CtrlL] or g2.KeyDown[G2K_CtrlR] then
  begin
    if EntityPick <> nil then Selection.Add(EntityPick);
  end
  else
  begin
    Selection.Clear;
    if EntityPick <> nil then Selection.Add(EntityPick);
  end;
  for i := 0 to _Scene.JointCount - 1 do
  if TScene2DJointData(_Scene.Joints[i].UserData).Select(Display, x, y) then
  SelectJoint := TScene2DJointData(_Scene.Joints[i].UserData);
  SelectionUpdateEnd;
  if SelectJoint <> nil then
  Editor := SelectJoint.Editor;
end;

procedure TScene2DData.Render(const Display: TG2Display2D);
  var i, j: Integer;
begin
  if Scene.Simulate then Exit;
  for i := 0 to Scene.EntityCount - 1 do
  for j := 0 to Scene.Entities[i].ComponentCount - 1 do
  TScene2DComponentData(Scene.Entities[i].Components[j].UserData).DebugDraw(Display);
  for i := 0 to Scene.JointCount - 1 do
  TScene2DJointData(Scene.Joints[i].UserData).DebugDraw(Display);
  if _Editor <> nil then _Editor.Render(Display);
end;
//TScene2DData END

//TAsset BEGIN
procedure TAsset.OnInitialize;
begin

end;

procedure TAsset.OnFinalize;
begin

end;

class constructor TAsset.CreateClass;
begin
  List := nil;
end;

class destructor TAsset.DestroyClass;
  var AssetDelete: TAsset;
begin
  while List <> nil do
  begin
    AssetDelete := List;
    List := List.Prev;
    AssetDelete.Free;
  end;
end;

class function TAsset.GetAssetName: String;
begin
  Result := 'Asset';
end;

class function TAsset.CheckExtension(const Ext: String): Boolean;
begin
  Result := False;
end;

class function TAsset.ProcessFile(const FilePath: String): TG2QuickListString;
begin
  {$Warnings off}
  Result.Clear;
  {$Warnings on}
  Result.Add(FilePath);
end;

constructor TAsset.Create(const FileName: String);
begin
  inherited Create;
  _Path := ExpandFileName(FileName);
  _md5.SetValue(LowerCase(_Path));
  _Ref := 0;
  Prev := List;
  Next := nil;
  if List <> nil then
  List.Next := Self;
  List := Self;
  OnInitialize;
end;

destructor TAsset.Destroy;
begin
  OnFinalize;
  if Next <> nil then
  Next.Prev := Prev;
  if Prev <> nil then
  Prev.Next := Next;
  if List = Self then
  List := Self.Prev;
  inherited Destroy;
end;

procedure TAsset.RefInc;
begin
  Inc(_Ref);
end;

procedure TAsset.RefDec;
begin
  Dec(_Ref);
  if _Ref <= 0 then Free;
end;
//TAsset END

//TAssetAny BEGIN
class function TAssetAny.GetAssetName: String;
begin
  Result := 'All';
end;

class function TAssetAny.CheckExtension(const Ext: String): Boolean;
begin
  Result := True;
end;
//TAssetAny END

//TAssetTexture BEIGN
class function TAssetTexture.GetAssetName: String;
begin
  Result := 'Texture';
end;

class function TAssetTexture.CheckExtension(const Ext: String): Boolean;
begin
  Result := LowerCase(Ext) = 'png';
end;

class function TAssetTexture.ProcessFile(
  const FilePath: String
): TG2QuickListString;
begin
  {$Warnings off}
  Result.Clear;
  {$Warnings on}
  Result.Add(FilePath);
end;
//TAssetTexture END

//TAssetImage BIGIN
class function TAssetImage.GetAssetName: String;
begin
  Result := 'Image';
end;

class function TAssetImage.CheckExtension(const Ext: String): Boolean;
begin
  Result := (LowerCase(Ext) = 'png')
  or (LowerCase(Ext) = 'g2atlas');
end;

class function TAssetImage.ProcessFile(
  const FilePath: String
): TG2QuickListString;
  var Ext: String;
  var AtlasFile: AnsiString;
  var dm: TG2DataManager;
  var g2ml: TG2ML;
  var Root, n0, n1, n2, n3: PG2MLObject;
  var i0, i1, i2: Integer;
begin
  Ext := ExtractFileExt(FilePath);
  Delete(Ext, 1, 1);
  if LowerCase(Ext) = 'png' then
  begin
    {$Warnings off}
    Result.Clear;
    {$Warnings on}
    Result.Add(FilePath);
  end
  else if LowerCase(Ext) = 'g2atlas' then
  begin
    Result.Clear;
    g2ml := TG2ML.Create;
    dm := TG2DataManager.Create(FilePath, dmAsset);
    try
      SetLength(AtlasFile, dm.Size);
      dm.ReadBuffer(@AtlasFile[1], dm.Size);
      Root := g2ml.Read(AtlasFile);
      for i0 := 0 to Root^.Children.Count - 1 do
      begin
        n0 := Root^.Children[i0];
        if n0^.Name = 'g2af' then
        begin
          for i1 := 0 to n0^.Children.Count - 1 do
          begin
            n1 := n0^.Children[i1];
            if n1^.Name = 'page' then
            begin
              for i2 := 0 to n1^.Children.Count - 1 do
              begin
                n2 := n1^.Children[i2];
                if n2^.Name = 'frame' then
                begin
                  n3 := n2^.FindNode('name');
                  if n3 <> nil then
                  begin
                    Result.Add(FilePath + '#' + n3^.AsString);
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      g2ml.FreeObject(Root);
    finally
      dm.Free;
    end;
    g2ml.Free;
  end;
end;
//TAssetImage END

//TAssetFont BEGIN
class function TAssetFont.GetAssetName: String;
begin
  Result := 'Font';
end;

class function TAssetFont.CheckExtension(const Ext: String): Boolean;
begin
  Result := (LowerCase(Ext) = 'g2f');
end;

class function TAssetFont.ProcessFile(const FilePath: String): TG2QuickListString;
  var Ext: String;
begin
  Ext := ExtractFileExt(FilePath);
  Delete(Ext, 1, 1);
  if LowerCase(Ext) = 'g2f' then
  begin
    {$Warnings off}
    Result.Clear;
    {$Warnings on}
    Result.Add(FilePath);
  end;
end;
//TAssetFont END

//TAssetEffect2D BEGIN
class function TAssetEffect2D.GetAssetName: String;
begin
  Result := 'Effect 2D';
end;

class function TAssetEffect2D.CheckExtension(const Ext: String): Boolean;
begin
  Result := (LowerCase(Ext) = 'g2fx');
end;

class function TAssetEffect2D.ProcessFile(const FilePath: String): TG2QuickListString;
  var Ext: String;
begin
  Ext := ExtractFileExt(FilePath);
  Delete(Ext, 1, 1);
  if LowerCase(Ext) = 'g2fx' then
  begin
    {$Warnings off}
    Result.Clear;
    {$Warnings on}
    Result.Add(FilePath);
  end;
end;
//TAssetEffect2D END

//TAssetScene2D BEGIN
class function TAssetScene2D.GetAssetName: String;
begin
  Result := 'Scene 2D';
end;

class function TAssetScene2D.CheckExtension(const Ext: String): Boolean;
begin
  Result := (LowerCase(Ext) = 'g2s2d');
end;

class function TAssetScene2D.ProcessFile(const FilePath: String): TG2QuickListString;
  var Ext: String;
begin
  Ext := ExtractFileExt(FilePath);
  Delete(Ext, 1, 1);
  if LowerCase(Ext) = 'g2s2d' then
  begin
    {$Warnings off}
    Result.Clear;
    {$Warnings on}
    Result.Add(FilePath);
  end;
end;
//TAssetScene2D END

//TAssetPrefab2D BEGIN
class function TAssetPrefab2D.GetAssetName: String;
begin
  Result := 'Prefab 2D';
end;

class function TAssetPrefab2D.CheckExtension(const Ext: String): Boolean;
begin
  Result := (LowerCase(Ext) = 'g2prefab2d');
end;

class function TAssetPrefab2D.ProcessFile(const FilePath: String): TG2QuickListString;
  var Ext: String;
begin
  Ext := ExtractFileExt(FilePath);
  Delete(Ext, 1, 1);
  if LowerCase(Ext) = 'g2prefab2d' then
  begin
    {$Warnings off}
    Result.Clear;
    {$Warnings on}
    Result.Add(FilePath);
  end;
end;
//TAssetPrefab2D END

//TAssetManager BEIGN
function TAssetManager.VerifyPath(const Path: String): String;
begin
  if not FileExists(Path) and App.Project.Open then
  Result := App.Project.FilePath + G2PathSep + 'assets' + G2PathSep + Path
  else
  Result := ExpandFileName(Path);
end;

function TAssetManager.GetTexture(const Path: String): TG2Texture2D;
begin
  Result := TG2Texture2D.SharedAsset(Path);
end;

function TAssetManager.GetFont(const Path: String): TG2Font;
begin
  Result := TG2Font.SharedAsset(Path);
end;

function TAssetManager.GetImage(const Path: String): TG2Picture;
begin
  Result := TG2Picture.SharedAsset(Path);
end;

function TAssetManager.GetEffect(const Path: String): TG2Effect2D;
begin
  Result := TG2Effect2D.SharedAsset(Path);
end;

procedure TAssetManager.Initialize;
begin
  _AssetPaths.Clear;
end;

procedure TAssetManager.Finalize;
  var AssetDelete: TAsset;
begin
  while TAsset.List <> nil do
  begin
    AssetDelete := TAsset.List;
    TAsset.List := TAsset.List.Prev;
    AssetDelete.Free;
  end;
end;

procedure TAssetManager.Update;
begin

end;
//TAssetManager END

//TCodeInsightSymbol BEGIN
procedure TCodeInsightSymbol.SetPath(const Value: String);
begin
  _Path := Value;
end;

constructor TCodeInsightSymbol.Create;
begin
  _LineInterface := -1;
  _LineImplementation := -1;
  Children.Clear;
end;

procedure TCodeInsightSymbol.Initialize;
begin
  SymbolType := stNone;
end;

procedure TCodeInsightSymbol.Finalize;
begin

end;

procedure TCodeInsightSymbol.Clear;
  var i: Integer;
begin
  for i := 0 to Children.Count - 1 do
  begin
    Children[i].Clear;
    Children[i].Finalize;
    Children[i].Free;
  end;
  Children.Clear;
end;

function TCodeInsightSymbol.FindChild(const ChildName: String): TCodeInsightSymbol;
  var i: Integer;
begin
  for i := 0 to Children.Count - 1 do
  if LowerCase(Children[i].Name) = LowerCase(ChildName) then
  begin
    Result := Children[i];
    Exit;
  end;
  Result := nil;
end;
//TCodeInsightSymbol END

//TCodeInsightSymbolFile BEGIN
procedure TCodeInsightSymbolFile.SetModified(const Value: Boolean);
begin
  _Modified := Value;
  if (_Modified) then
  _ModifiedTime := G2Time;
end;

procedure TCodeInsightSymbolFile.Initialize;
begin
  _ModifiedTime := 0;
  _ParsedTime := 0;
  SymbolType := stFile;
end;

procedure TCodeInsightSymbolFile.Finalize;
begin

end;
//TCodeInsightSymbolFile END

//TCodeInsightSymbolFileLink BEIGN
procedure TCodeInsightSymbolFileLink.Initialize;
begin
  SymbolType := stFileLink;
end;

procedure TCodeInsightSymbolFileLink.Finalize;
begin

end;
//TCodeInsightSymbolFileLink END

//TCodeInsightScanThread BEGIN
procedure TCodeInsightScanThread.Execute;
begin
  App.CodeInsight.ScanFile(FileSymbol);
end;
//TCodeInsightScanThread END

//TCodeInsight BEGIN
function TCodeInsight.SearchFile(const f: String): String;
  var i: Integer;
begin
  for i := 0 to High(_SearchPaths) do
  begin
    if FileExists(_SearchPaths[i] + f) then
    begin
      Result := _SearchPaths[i] + f;
      Exit;
    end
    else if FileExists(_SearchPaths[i] + f + '.pas') then
    begin
      Result := _SearchPaths[i] + f + '.pas';
      Exit;
    end
    else if FileExists(_SearchPaths[i] + f + '.pp') then
    begin
      Result := _SearchPaths[i] + f + '.pp';
      Exit;
    end;
  end;
  Result := '';
end;

function TCodeInsight.FileLoaded(const f: String): Boolean;
  var i: Integer;
begin
  for i := 0 to _Files.Count - 1 do
  if _Files[i].Path = f then
  begin
    Result := True;
    Exit;
  end;
  Result := False;
end;

function TCodeInsight.FilesToParse: Integer;
  var i: Integer;
begin
  Result := 0;
  for i := 0 to _Files.Count - 1 do
  if TCodeInsightSymbolFile(_Files[i]).ParsedTime = 0 then
  Result += 1;
end;

procedure TCodeInsight.Initialize;
begin
  _ScanThread := nil;
  _Files.Clear;
  _CurCodeFile := nil;
  _Root := TCodeInsightSymbolFile.Create;
  _Root.Initialize;
  _Root.Name := 'root';
  _Parser := TG2Parser.Create;
  _Parser.AddComment('{', '}');
  _Parser.AddComment('(*', '*)');
  _Parser.AddCommentLine('//');
  _Parser.AddString('''');
  _Parser.AddSymbol(':=');
  _Parser.AddSymbol('+=');
  _Parser.AddSymbol('-=');
  _Parser.AddSymbol('/=');
  _Parser.AddSymbol('*=');
  _Parser.AddSymbol('(.');
  _Parser.AddSymbol('.)');
  _Parser.AddSymbol('.');
  _Parser.AddSymbol(';');
  _Parser.AddSymbol(',');
  _Parser.AddSymbol('(');
  _Parser.AddSymbol(')');
  _Parser.AddSymbol('[');
  _Parser.AddSymbol(']');
  _Parser.AddSymbol('+');
  _Parser.AddSymbol('-');
  _Parser.AddSymbol('*');
  _Parser.AddSymbol('/');
  _Parser.AddSymbol(':');
  _Parser.AddSymbol('=');
  _Parser.AddSymbol('@');
  _Parser.AddSymbol('#');
  _Parser.AddKeyWord('as');
  _Parser.AddKeyWord('dispinterface');
  _Parser.AddKeyWord('except');
  _Parser.AddKeyWord('exports');
  _Parser.AddKeyWord('finalization');
  _Parser.AddKeyWord('finally');
  _Parser.AddKeyWord('initialization');
  _Parser.AddKeyWord('inline');
  _Parser.AddKeyWord('library');
  _Parser.AddKeyWord('on');
  _Parser.AddKeyWord('out');
  _Parser.AddKeyWord('packed');
  _Parser.AddKeyWord('property');
  _Parser.AddKeyWord('raise');
  _Parser.AddKeyWord('resourcestring');
  _Parser.AddKeyWord('threadvar');
  _Parser.AddKeyWord('try');
  _Parser.AddKeyWord('absolute');
  _Parser.AddKeyWord('abstract');
  _Parser.AddKeyWord('alias');
  _Parser.AddKeyWord('assembler');
  _Parser.AddKeyWord('cdecl');
  _Parser.AddKeyWord('cppdecl');
  _Parser.AddKeyWord('default');
  _Parser.AddKeyWord('export');
  _Parser.AddKeyWord('external');
  _Parser.AddKeyWord('far');
  _Parser.AddKeyWord('far16');
  _Parser.AddKeyWord('forward');
  //_Parser.AddKeyWord('index');
  _Parser.AddKeyWord('local');
  _Parser.AddKeyWord('near');
  _Parser.AddKeyWord('nostackframe');
  _Parser.AddKeyWord('oldfpccall');
  _Parser.AddKeyWord('override');
  _Parser.AddKeyWord('overload');
  _Parser.AddKeyWord('pascal');
  _Parser.AddKeyWord('private');
  _Parser.AddKeyWord('protected');
  _Parser.AddKeyWord('public');
  _Parser.AddKeyWord('published');
  _Parser.AddKeyWord('read');
  _Parser.AddKeyWord('register');
  _Parser.AddKeyWord('reintroduce');
  _Parser.AddKeyWord('safecall');
  _Parser.AddKeyWord('softfloat');
  _Parser.AddKeyWord('stdcall');
  _Parser.AddKeyWord('virtual');
  _Parser.AddKeyWord('write');
  _Parser.AddKeyWord('and');
  _Parser.AddKeyWord('array');
  _Parser.AddKeyWord('asm');
  _Parser.AddKeyWord('div');
  _Parser.AddKeyWord('downto');
  _Parser.AddKeyWord('file');
  _Parser.AddKeyWord('goto');
  _Parser.AddKeyWord('implementation');
  _Parser.AddKeyWord('in');
  _Parser.AddKeyWord('inherited');
  _Parser.AddKeyWord('inline');
  _Parser.AddKeyWord('interface');
  _Parser.AddKeyWord('label');
  _Parser.AddKeyWord('mod');
  _Parser.AddKeyWord('nil');
  _Parser.AddKeyWord('not');
  _Parser.AddKeyWord('object');
  _Parser.AddKeyWord('operator');
  _Parser.AddKeyWord('or');
  _Parser.AddKeyWord('packed');
  _Parser.AddKeyWord('reintroduce');
  _Parser.AddKeyWord('repeat');
  _Parser.AddKeyWord('set');
  _Parser.AddKeyWord('shl');
  _Parser.AddKeyWord('shr');
  _Parser.AddKeyWord('type');
  _Parser.AddKeyWord('unit');
  _Parser.AddKeyWord('uses');
  _Parser.AddKeyWord('with');
  _Parser.AddKeyWord('xor');
  _Parser.AddKeyWord('begin');
  _Parser.AddKeyWord('end');
  _Parser.AddKeyWord('program');
  _Parser.AddKeyWord('procedure');
  _Parser.AddKeyWord('function');
  _Parser.AddKeyWord('class');
  _Parser.AddKeyWord('record');
  _Parser.AddKeyWord('object');
  _Parser.AddKeyWord('var');
  _Parser.AddKeyWord('const');
  _Parser.AddKeyWord('if');
  _Parser.AddKeyWord('then');
  _Parser.AddKeyWord('else');
  _Parser.AddKeyWord('while');
  _Parser.AddKeyWord('do');
  _Parser.AddKeyWord('for');
  _Parser.AddKeyWord('repeat');
  _Parser.AddKeyWord('until');
  _Parser.AddKeyWord('array');
  _Parser.AddKeyWord('of');
  _Parser.AddKeyWord('is');
  _Parser.AddKeyWord('to');
  _Parser.AddKeyWord('case');
  _Parser.AddKeyWord('constructor');
  _Parser.AddKeyWord('destructor');
  _Parser.AddKeyWord('objcclass');
  _Parser.AddKeyWord('message');
  _Parser.AddKeyWord('specialize');
end;

procedure TCodeInsight.Finalize;
begin
  Clear;
  _Parser.Free;
  _Root.Finalize;
  _Root.Free;
end;

procedure TCodeInsight.Update;
  var i: Integer;
  var f: TCodeInsightSymbolFile;
  var t: TG2IntU32;
begin
  t := G2Time;
  if _ScanThread = nil then
  begin
    for i := 0 to _Files.Count - 1 do
    begin
      f := TCodeInsightSymbolFile(_Files[i]);
      if f.Modified then
      //and (t - f.ModifiedTime > 500) then
      begin
        f.Modified := False;
        //_ScanThread := TCodeInsightScanThread.Create;
        //_ScanThread.FileSymbol := f;
        //_ScanThread.Start;
        ScanFile(f);
        Break;
      end;
    end;
  end
  else
  begin
    if _ScanThread.State = tsFinished then
    begin
      _ScanThread.Free;
      _ScanThread := nil;
    end;
  end;
end;

procedure TCodeInsight.AddSearchPath(const Path: String);
begin
  SetLength(_SearchPaths, Length(_SearchPaths) + 1);
  _SearchPaths[High(_SearchPaths)] := Path;
  if (Length(Path) > 0)
  and (Path[Length(Path)] <> '/')
  and (Path[Length(Path)] <> '\') then
  _SearchPaths[High(_SearchPaths)] += G2PathSep;
end;

procedure TCodeInsight.Clear;
  var i: Integer;
begin
  _SearchPaths := nil;
  for i := 0 to _Files.Count - 1 do
  _Files[i].Free;
  _Files.Clear;
  _Root.Clear;
  _Root.Name := 'root';
  _Root.Path := '';
end;

procedure TCodeInsight.ScanFile(const f: TCodeInsightSymbolFile);
  type TScanScope = (ssNone, ssProgram, ssUnit, ssInterface, ssImplementation, ssUses, ssNest, ssObject);
  type TScanSection = (stNone, stType, stVar, stConst);
  var Scope: array of TScanScope;
  var ScopeIndex: Integer;
  var Objects: array of record
    Symbol: TCodeInsightSymbol;
    Section: TScanSection;
  end;
  var ObjectIndex: Integer;
  procedure EnterScope(const NewScope: TScanScope);
  begin
    ScopeIndex += 1;
    if ScopeIndex >= Length(Scope) then
    SetLength(Scope, ScopeIndex + 1);
    Scope[ScopeIndex] := NewScope;
  end;
  procedure ExitScope;
  begin
    ScopeIndex -= 1;
  end;
  function CurScope: TScanScope;
  begin
    Result := Scope[ScopeIndex];
  end;
  function ParentScope: TScanScope;
  begin
    if ScopeIndex > 0 then
    Result := Scope[ScopeIndex - 1]
    else
    Result := ssNone;
  end;
  function CurObject: TCodeInsightSymbol;
  begin
    if Objects[ObjectIndex].Symbol = nil then
    Result := f
    else
    Result := Objects[ObjectIndex].Symbol;
  end;
  function GetCurObjectSection: TScanSection;
  begin
    Result := Objects[ObjectIndex].Section;
  end;
  procedure SetCurObjectSection(const Section: TScanSection);
  begin
    Objects[ObjectIndex].Section := Section;
  end;
  procedure EnterObject(const Obj: TCodeInsightSymbol);
  begin
    ObjectIndex += 1;
    if Length(Objects) <= ObjectIndex then
    SetLength(Objects, ObjectIndex + 1);
    Objects[ObjectIndex].Symbol := Obj;
    Objects[ObjectIndex].Section := stVar;
  end;
  procedure ExitObject;
  begin
    if ObjectIndex > 0 then
    ObjectIndex -= 1;
  end;
  function GetCurPath: AnsiString;
  begin
    if CurObject <> nil then
    Result := CurObject.Path
    else
    Result := f.Path;
  end;
  var Token, Code: AnsiString;
  var tt: TG2TokenType;
  procedure SkipParameters;
    var Bracket: Integer;
  begin
    while (tt <> ttEOF)
    and ((tt <> ttSymbol) or (Token <> ';')) do
    begin
      Bracket := 0;
      if (tt = ttSymbol)
      and (Token = '(') then
      begin
        Bracket := 1;
        repeat
          Token := _Parser.NextToken(tt);
          if tt = ttSymbol then
          begin
            if Token = '(' then
            Bracket += 1
            else if Token = ')' then
            Bracket -= 1;
          end;
        until (tt = ttEOF) or (Bracket = 0);
      end;
      Token := _Parser.NextToken(tt);
    end;
  end;
  procedure SkipArray;
    var Arr: Integer;
  begin
    while (tt <> ttEOF) and not ((tt = ttKeyword) and (Token = 'of')) do
    begin
      if (tt = ttSymbol) and (Token = '[') then
      begin
        Arr := 1;
        repeat
          Token := _Parser.NextToken(tt);
          if tt = ttSymbol then
          begin
            if Token = '[' then
            Arr += 1
            else if Token = ']' then
            Arr -= 1;
          end;
        until (tt = ttEOF) or (Arr = 0);
      end;
      Token := _Parser.NextToken(tt);
    end;
    if (tt = ttKeyword) and (Token = 'of') then
    Token := _Parser.NextToken(tt);
  end;
  procedure SkipToSemicolon;
  begin
    if not ((tt = ttSymbol) and (Token = ';')) then
    repeat
      Token := _Parser.NextToken(tt);
    until (tt = ttEOF) or ((tt = ttSymbol) and (Token = ';'));
  end;
  function ReadVar: Boolean;
    var s: TCodeInsightSymbol;
  begin
    Result := False;
    s := TCodeInsightSymbol.Create;
    s.Initialize;
    s.LineInterface := _Parser.Line;
    s.Name := Token;
    s.Path := GetCurPath + '#' + Token;
    CurObject.Children.Add(s);
    Token := _Parser.NextToken(tt);
    if tt = ttSymbol then
    begin
      if Token = ',' then
      begin

      end
      else if Token = ':' then
      begin
        Token := _Parser.NextToken(tt);
        while (tt = ttKeyword)
        and (Token = 'array') do
        begin
          SkipArray;
        end;
        if tt = ttWord then
        begin
          SkipToSemicolon;
        end
        else if tt = ttKeyword then
        begin
          if (Token = 'class')
          or (Token = 'objcclass')
          or (Token = 'object')
          or (Token = 'record') then
          begin
            EnterObject(s);
            EnterScope(ssObject);
          end
          else
          SkipToSemicolon;
        end
        else
        SkipToSemicolon;
      end
      else
      Exit;
    end
    else
    Exit;
    Result := True;
  end;
  var fs, SymbolPath, Tmp: String;
  var s: TCodeInsightSymbol;
  var sf: TCodeInsightSymbolFile;
  var sfl: TCodeInsightSymbolFileLink;
begin
  f.ParsedTime := G2Time;
  f.Clear;
  Code := App.LoadFile(f.Path);
  Code := G2StrReplace(Code, '{#project_name#}', App.Project.ProjectName);
  _Parser.Parse(Code);
  ScopeIndex := 0;
  SetLength(Scope, 1);
  Scope[0] := ssNone;
  SetLength(Objects, 1);
  ObjectIndex := 0;
  Objects[0].Symbol := f;
  Objects[0].Section := stNone;
  repeat
    Token := _Parser.NextToken(tt);
    case CurScope of
      ssNone:
      begin
        if (tt = ttKeyword) then
        begin
          if (Token = 'program') then
          begin
            Token := _Parser.NextToken(tt);
            if (tt = ttWord) then
            begin
              Token := _Parser.NextToken(tt);
              if (tt = ttSymbol)
              and (Token = ';') then
              begin
                EnterScope(ssProgram);
              end
              else
              Exit;
            end
            else
            Exit;
          end
          else if (Token = 'unit') then
          begin
            Token := _Parser.NextToken(tt);
            if (tt = ttWord) then
            begin
              Token := _Parser.NextToken(tt);
              if (tt = ttSymbol)
              and (Token = ';') then
              begin
                EnterScope(ssUnit);
              end
              else
              Exit;
            end
            else
            Exit;
          end
          else
          Exit;
        end
        else
        Exit;
      end;
      ssUnit:
      begin
        if (tt = ttKeyword) then
        begin
          if (Token = 'interface') then
          begin
            EnterScope(ssInterface);
          end
          else
          Exit;
        end
        else
        Exit;
      end;
      ssProgram, ssInterface, ssImplementation:
      begin
        if CurScope = ssInterface then
        begin
          if (tt = ttKeyword) then
          begin
            if (Token = 'implementation') then
            begin
              ExitScope;
              EnterScope(ssImplementation);
              Continue;
            end
            else if (Token = 'assembler')
            or (Token = 'overload')
            or (Token = 'default')
            or (Token = 'message')
            or (Token = 'cdecl')
            or (Token = 'stdcall') then
            begin
              SkipToSemicolon;
            end
            else if (Token = 'function')
            or (Token = 'procedure') then
            begin
              SetCurObjectSection(stVar);
              Token := _Parser.NextToken(tt);
              if tt = ttWord then
              begin
                s := TCodeInsightSymbol.Create;
                s.Initialize;
                s.LineInterface := _Parser.Line;
                s.Name := Token;
                s.Path := CurObject.Path + '#' + Token;
                CurObject.Children.Add(s);
                SkipParameters;
              end
              else
              Exit;
            end;
          end;
        end;
        if (CurScope = ssImplementation) or (CurScope = ssProgram) then
        begin
          if (tt = ttKeyword)
          and (Token = 'class') then
          begin
            Token := _Parser.NextToken(tt);
          end;
          if (tt = ttKeyword) then
          begin
            if (Token = 'begin')
            or (Token = 'asm') then
            begin
              EnterScope(ssNest);
              EnterObject(nil);
              Continue;
            end
            else if (Token = 'function')
            or (Token = 'procedure')
            or (Token = 'constructor')
            or (Token = 'destructor') then
            begin
              SymbolPath := GetCurPath;
              Tmp := '???';
              repeat
                Token := _Parser.NextToken(tt);
                if (tt = ttWord) then
                begin
                  SymbolPath += '#' + Token;
                  Tmp := Token;
                end;
              until (tt = ttEOF) or ((tt = ttSymbol) and ((Token = ':') or (Token = ';') or (Token = '(')));
              s := FindSymbol(SymbolPath);
              if s = nil then
              begin
                s := TCodeInsightSymbol.Create;
                s.Initialize;
                s.LineInterface := _Parser.Line;
                s.LineImplementation := -1;
                s.Name := Tmp;
                s.Path := SymbolPath;
                CurObject.Children.Add(s);
              end
              else
              begin
                s.LineImplementation := _Parser.Line;
              end;
              SkipParameters;
              EnterObject(s);
              Continue;
            end;
          end;
        end;
        if (tt = ttKeyword) then
        begin
          if (Token = 'uses') then
          begin
            EnterScope(ssUses);
          end
          else if (Token = 'type') then
          begin
            SetCurObjectSection(stType);
          end
          else if (Token = 'var') then
          begin
            SetCurObjectSection(stVar);
          end
          else if (Token = 'const') then
          begin
            SetCurObjectSection(stConst);
          end
          else if (Token = 'inline')
          or (Token = 'virtual')
          or (Token = 'default')
          or (Token = 'assembler')
          or (Token = 'abstract')
          or (Token = 'overload')
          or (Token = 'override')
          or (Token = 'message')
          or (Token = 'cdecl')
          or (Token = 'stdcall') then
          begin

          end
          else
          Exit;
        end
        else if (tt = ttWord) then
        begin
          if GetCurObjectSection = stVar then
          begin
            if not ReadVar then
            Exit;
          end
          else if GetCurObjectSection = stConst then
          begin
            s := TCodeInsightSymbol.Create;
            s.Initialize;
            s.LineInterface := _Parser.Line;
            s.Name := Token;
            s.Path := GetCurPath + '#' + Token;
            CurObject.Children.Add(s);
            Token := _Parser.NextToken(tt);
            if tt = ttSymbol then
            begin
              if Token = ',' then
              begin

              end
              else if (Token = ':') or (Token  = '=') then
              begin
                SkipToSemicolon;
              end
              else
              Exit;
            end
            else
            Exit;
          end
          else if GetCurObjectSection = stType then
          begin
            SymbolPath := GetCurPath + '#' + Token;
            s := CurObject.FindChild(Token);
            if s = nil then
            begin
              s := TCodeInsightSymbol.Create;
              s.Initialize;
              CurObject.Children.Add(s);
            end;
            s.LineInterface := _Parser.Line;
            s.Name := Token;
            s.Path := GetCurPath + '#' + Token;
            Token := _Parser.NextToken(tt);
            if (tt = ttSymbol)
            and (Token = '=') then
            begin
              Token := _Parser.NextToken(tt);
              while (tt = ttKeyword)
              and (Token = 'array') do
              begin
                SkipArray;
              end;
              if (tt = ttKeyword)
              and (
                (Token = 'type')
                or (Token = 'packed')
              ) then
              begin
                Token := _Parser.NextToken(tt);
              end;
              if (tt = ttWord) then
              begin
                SkipToSemicolon;
              end
              else if (tt = ttKeyword) then
              begin
                if (Token = 'specialize')
                or (Token = 'set') then
                begin
                  SkipToSemicolon;
                end
                else if (Token = 'procedure')
                or (Token = 'function') then
                begin
                  Token := _Parser.NextToken(tt);
                  SkipParameters;
                end
                else if (Token = 'class')
                or (Token = 'objcclass')
                or (Token = 'object')
                or (Token = 'record') then
                begin
                  EnterObject(s);
                  EnterScope(ssObject);
                end;
              end
              else
              begin
                SkipToSemicolon;
              end;
            end
            else
            Exit;
          end
          else
          Exit;
        end;
      end;
      ssUses:
      begin
        if (tt = ttWord) then
        begin
          fs := SearchFile(Token);
          if Length(fs) > 0 then
          begin
            if not FileLoaded(fs) then
            begin
              sf := TCodeInsightSymbolFile.Create;
              sf.Initialize;
              sf.Name := ExtractFileNameWithoutExt(ExtractFileName(fs));
              sf.Path := fs;
              _Files.Add(sf);
            end;
            sfl := TCodeInsightSymbolFileLink.Create;
            sfl.Initialize;
            sfl.LineInterface := _Parser.Line;
            sfl.Name := ExtractFileNameWithoutExt(ExtractFileName(fs));
            sfl.Path := fs;
            s := f.FindChild('uses');
            if s = nil then
            begin
              s := TCodeInsightSymbol.Create;
              s.Initialize;
              s.Name := 'uses';
              s.Path := f.Path + '#uses';
              f.Children.Add(s);
            end;
            s.Children.Add(sfl);
          end;
          Token := _Parser.NextToken(tt);
          if (tt = ttSymbol)
          and ((Token = ',') or (Token = ';')) then
          begin
            if Token = ';' then
            ExitScope;
          end
          else
          Exit;
        end
        else
        Exit;
      end;
      ssObject:
      begin
        if (tt = ttSymbol)
        and (Token = ';') then
        begin
          ExitObject;
          ExitScope;
        end
        else if (tt = ttKeyword)
        and (Token = 'of') then
        begin
          SkipToSemicolon;
          ExitObject;
          ExitScope;
        end
        else
        begin
          if (tt = ttSymbol)
          and (Token = '(') then
          begin
            repeat
              Token := _Parser.NextToken(tt);
              if (tt = ttWord) then
              begin
                Token := _Parser.NextToken(tt);
                if (tt = ttSymbol) then
                begin
                  if (Token = ',') then
                  begin

                  end
                  else if (Token = ')') then
                  begin
                    Token := _Parser.NextToken(tt);
                    Break;
                  end
                  else
                  Exit;
                end
                else
                Exit;
              end
              else
              Exit;
            until (tt = ttEOF);
          end;
          while (tt <> ttEOF) do
          begin
            if (tt = ttKeyword) then
            begin
              if Token = 'private' then
              begin

              end
              else if Token = 'protected' then
              begin

              end
              else if Token = 'public' then
              begin

              end
              else if Token = 'published' then
              begin

              end
              else if Token = 'class' then
              begin

              end
              else if Token = 'property' then
              begin
                Token := _Parser.NextToken(tt);
                if tt = ttWord then
                begin
                  s := TCodeInsightSymbol.Create;
                  s.Initialize;
                  s.LineInterface := _Parser.Line;
                  s.Name := Token;
                  s.Path := GetCurPath + '#' + Token;
                  CurObject.Children.Add(s);
                  SkipToSemicolon;
                end
                else
                Exit;
              end
              else if (Token = 'constructor')
              or (Token = 'destructor')
              or (Token = 'procedure')
              or (Token = 'function') then
              begin
                Token := _Parser.NextToken(tt);
                if tt = ttWord then
                begin
                  s := TCodeInsightSymbol.Create;
                  s.Initialize;
                  s.LineInterface := _Parser.Line;
                  s.Name := Token;
                  s.Path := GetCurPath + '#' + Token;
                  CurObject.Children.Add(s);
                  Token := _Parser.NextToken(tt);
                  SkipParameters;
                end
                else
                Exit;
              end
              else if Token = 'var' then
              begin
                SetCurObjectSection(stVar);
              end
              else if Token = 'const' then
              begin
                SetCurObjectSection(stConst);
              end
              else if Token = 'type' then
              begin
                SetCurObjectSection(stType);
              end
              else if (Token = 'inline')
              or (Token = 'virtual')
              or (Token = 'default')
              or (Token = 'assembler')
              or (Token = 'abstract')
              or (Token = 'overload')
              or (Token = 'override')
              or (Token = 'message')
              or (Token = 'cdecl')
              or (Token = 'stdcall') then
              begin
                SkipToSemicolon;
              end
              else if Token = 'end' then
              begin
                Token := _Parser.NextToken(tt);
                if (tt = ttSymbol) and (Token = ';') then
                begin
                  ExitObject;
                  ExitScope;
                  Break;
                end
                else
                Exit;
              end;
            end
            else if (tt = ttWord) then
            begin
              case GetCurObjectSection of
                stVar:
                begin
                  if not ReadVar then
                  Exit;
                end;
                stConst:
                begin
                  s := TCodeInsightSymbol.Create;
                  s.Initialize;
                  s.LineInterface := _Parser.Line;
                  s.Name := Token;
                  s.Path := GetCurPath + '#' + Token;
                  CurObject.Children.Add(s);
                  Token := _Parser.NextToken(tt);
                  if tt = ttSymbol then
                  begin
                    if Token = ',' then
                    begin

                    end
                    else if (Token = ':') or (Token  = '=') then
                    begin
                      SkipToSemicolon;
                    end
                    else
                    Exit;
                  end
                  else
                  Exit;
                end;
                stType:
                begin
                  s := TCodeInsightSymbol.Create;
                  s.Initialize;
                  s.LineInterface := _Parser.Line;
                  s.Name := Token;
                  s.Path := GetCurPath + '#' + Token;
                  CurObject.Children.Add(s);
                  Token := _Parser.NextToken(tt);
                  if (tt = ttSymbol)
                  and (Token = '=') then
                  begin
                    Token := _Parser.NextToken(tt);
                    if (tt = ttKeyword)
                    and (Token = 'type') then
                    begin
                      Token := _Parser.NextToken(tt);
                    end;
                    if (tt = ttWord) then
                    begin
                      SkipToSemicolon;
                      Continue;
                    end
                    else if (tt = ttKeyword) then
                    begin
                      if (Token = 'specialize')
                      or (Token = 'set') then
                      begin
                        SkipToSemicolon;
                      end
                      else if (Token = 'procedure')
                      or (Token = 'function') then
                      begin
                        Token := _Parser.NextToken(tt);
                        SkipParameters;
                      end
                      else if (Token = 'class')
                      or (Token = 'objcclass')
                      or (Token = 'object')
                      or (Token = 'record') then
                      begin
                        EnterObject(s);
                        EnterScope(ssObject);
                      end;
                    end
                    else
                    begin
                      SkipToSemicolon;
                    end;
                  end
                  else
                  Exit;
                end;
                else
                begin
                  Exit;
                end;
              end;
            end
            else
            Exit;
            Token := _Parser.NextToken(tt);
          end;
        end;
      end;
      ssNest:
      begin
        if (tt = ttKeyword) then
        begin
          if (Token = 'begin')
          or (Token = 'case')
          or (Token = 'asm')
          or (Token = 'try') then
          begin
            EnterScope(ssNest);
            EnterObject(nil);
          end
          else if (Token = 'end') then
          begin
            ExitObject;
            ExitScope;
            if CurObject <> nil then
            ExitObject;
          end;
        end;
      end;
    end;
  until tt = ttEOF;
end;

procedure TCodeInsight.Scan;
  var i: Integer;
begin
  Clear;
  AddSearchPath(g2.AppPath + 'fpc\i386-win32\rtl');
  AddSearchPath(g2.AppPath + 'fpc\i386-win32\winunits-base');
  AddSearchPath(g2.AppPath + 'fpc\i386-win32\paszlib');
  AddSearchPath(g2.AppPath + 'g2mp');
  for i := 0 to App.Project.ProjectIncludeSourceCount - 1 do
  AddSearchPath(G2StrReplace(App.Project.ProjectIncludeSource[i], '$(project_root)', App.Project.FilePath));
  if not App.Project.Open then Exit;
  _Root.Path := App.Project.GetProjectPath;
  _Root.Name := App.Project.GetProjectName;
  ScanFile(_Root);
  while FilesToParse > 0 do
  begin
    for i := 0 to _Files.Count - 1 do
    if TCodeInsightSymbolFile(_Files[i]).ParsedTime = 0 then
    begin
      ScanFile(TCodeInsightSymbolFile(_Files[i]));
      Break;
    end;
  end;
end;

function TCodeInsight.FindFile(const Path: String): TCodeInsightSymbolFile;
  var i: Integer;
begin
  for i := 0 to _Files.Count - 1 do
  if _Files[i].Path = Path then
  begin
    Result := TCodeInsightSymbolFile(_Files[i]);
    Exit;
  end;
  Result := nil;
end;

function TCodeInsight.FindSymbol(const Path: String): TCodeInsightSymbol;
  var StrArr: TG2StrArrA;
  var fs: String;
  var i, j: Integer;
begin
  StrArr := G2StrExplode(Path, '#');
  if Length(StrArr) > 0 then
  begin
    fs := StrArr[0];
    Result := FindFile(fs);
    if Result <> nil then
    begin
      for i := 1 to High(StrArr) do
      begin
        fs += '#' + StrArr[i];
        for j := 0 to Result.Children.Count - 1 do
        if Result.Children[j].Path = fs then
        begin
          Result := Result.Children[j];
          Break;
        end;
        if Result.Path <> fs then
        begin
          Result := nil;
          Exit;
        end;
      end;
    end;
    Exit;
  end;
  Result := nil;
end;
//TCodeInsight END

end.

