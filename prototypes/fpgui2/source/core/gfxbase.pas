unit gfxbase;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  SysUtils;

type
  TfpgCoord = integer;     // we might use floating point coordinates in the future...
  TfpgColor = longword;    // Always in RRGGBB (Alpha, Red, Green, Blue) format!!
  
  TRGBTriple = record
    Red: word;
    Green: word;
    Blue: word;
    Alpha: word;
  end;

  TWindowType = (wtChild, wtWindow, wtModalForm, wtPopup);

  TWindowAttribute = (waSizeable, waAutoPos, waScreenCenterPos);
  TWindowAttributes = set of TWindowAttribute;

  TMouseCursor = (mcDefault, mcArrow, mcCross, mcIBeam, mcSizeEW, mcSizeNS,
      mcSizeNWSE, mcSizeNESW, mcMove, mcHourGlass);

const
  MOUSE_LEFT       = 1;
  MOUSE_RIGHT      = 2;
  MOUSE_MIDDLE     = 4;


  ss_Shift         = $0001;
  ss_Control       = $0004;
  ss_Alt           = $0008;
  ss_CapsLock      = $0002;
  ss_NumLock       = $0010;
  ss_ScrollLock    = $0080;

  // Platform independent messages used by fpGUI (TfpgWidget)
  FPGM_PAINT       = 1;
  FPGM_ACTIVATE    = 2;
  FPGM_DEACTIVATE  = 3;
  FPGM_KEYPRESS    = 4;
  FPGM_KEYRELEASE  = 5;
  FPGM_KEYCHAR     = 6;
  FPGM_MOUSEDOWN   = 7;
  FPGM_MOUSEUP     = 8;
  FPGM_MOUSEMOVE   = 9;
  FPGM_DOUBLECLICK = 10;
  FPGM_MOUSEENTER  = 11;
  FPGM_MOUSEEXIT   = 12;
  FPGM_CLOSE       = 13;
  FPGM_SCROLL      = 14;
  FPGM_RESIZE      = 15;
  FPGM_MOVE        = 16;
  FPGM_POPUPCLOSE  = 17;
  FPGM_KILLME      = 9999;


  // The special keys, based on the well-known keyboard scan codes
  KEY_LEFT         = $FF4B;
  KEY_RIGHT        = $FF4D;
  KEY_DOWN         = $FF50;
  KEY_UP           = $FF48;
  KEY_END          = $FF4F;
  KEY_HOME         = $FF47;
  KEY_PGUP         = $FF49;
  KEY_PGDN         = $FF51;
  KEY_INSERT       = $FF52;
  KEY_DELETE       = $FF53;
  KEY_F1           = $FF3B;
  KEY_F2           = KEY_F1 + 1;
  KEY_F3           = KEY_F1 + 2;
  KEY_F4           = KEY_F1 + 3;
  KEY_F5           = KEY_F1 + 4;
  KEY_F6           = KEY_F1 + 5;
  KEY_F7           = KEY_F1 + 6;
  KEY_F8           = KEY_F1 + 7;
  KEY_F9           = KEY_F1 + 8;
  KEY_F10          = KEY_F1 + 9;
  KEY_F11          = $FF57;
  KEY_F12          = $FF58;
  // some general keys
  KEY_TAB          = $0009;
  KEY_ENTER        = $000D;
  KEY_SPACE        = $0020;
  KEY_ESC          = $001B;
  KEY_BACKSPACE    = $0008;


  // scan codes for KeyPress/KeyRelease
  KEYSC_ENTER      = $1C;
  KEYSC_SPACE      = $39;


  FPG_DEFAULT_FONT_DESC = 'Arial-10';
  UserNamedColorStart   = 128;

  {$I predefinedcolors.inc}

type
  TfpgRect = object  // not class for static allocations
    Top: TfpgCoord;
    Left: TfpgCoord;
    Width: TfpgCoord;
    Height: TfpgCoord;
    procedure SetRect(aleft, atop, awidth, aheight: TfpgCoord);
    function  Bottom: TfpgCoord;
    function  Right: TfpgCoord;
    procedure SetBottom(Value: TfpgCoord);
    procedure SetRight(Value: TfpgCoord);
  end;


  TfpgMsgParmMouse = record
    x: TfpgCoord;
    y: TfpgCoord;
    Buttons: word;
    shiftstate: word;
    delta: word;
  end;


  TfpgMsgParmKeyboard = record
    keycode: word;
    shiftstate: word;
  end;
  

  TfpgMessageParams = record
    case integer of
      0: (mouse: TfpgMsgParmMouse);
      1: (keyboard: TfpgMsgParmKeyboard);
      2: (rect: TfpgRect);
  end;
  

  TfpgMessageRec = record
    MsgCode: integer;
    Sender: TObject;
    Dest: TObject;
    Params: TfpgMessageParams;
  end;
  PfpgMessageRec = ^TfpgMessageRec;


  TfpgLineStyle = (lsSolid, lsDash, lsDot);


  // forward declaration
  TfpgWindowBase = class;
  TfpgCanvasBase = class;


  TfpgImageBase = class(TObject)
  private
    function    GetColor(x, y: TfpgCoord): TfpgColor;
    procedure   SetColor(x, y: TfpgCoord; const AValue: TfpgColor);
  protected
    FWidth: integer;
    FHeight: integer;
    FColorDepth: integer;
    FMasked: boolean;
    FImageData: pointer;
    FImageDataSize: integer;
    FMaskData: pointer;
    FMaskDataSize: integer;
    procedure   DoFreeImage; virtual; abstract;
    procedure   DoInitImage(acolordepth, awidth, aheight: integer; aimgdata: Pointer); virtual; abstract;
    procedure   DoInitImageMask(awidth, aheight: integer; aimgdata: Pointer); virtual; abstract;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   Invert;
    procedure   FreeImage;
    procedure   AllocateImage(acolordepth, awidth, aheight: integer);
    procedure   AllocateMask;
    procedure   CreateMaskFromSample(x, y: TfpgCoord);
    procedure   UpdateImage;
    property    ImageData: pointer read FImageData;
    property    ImageDataSize: integer read FImageDataSize;
    property    MaskData: pointer read FMaskData;
    property    MaskDataSize: integer read FMaskDataSize;
    property    Width: integer read FWidth;
    property    Height: integer read FHeight;
    property    ColorDepth: integer read FColorDepth;
    property    Masked: boolean read FMasked;
    property    Colors[x, y: TfpgCoord]: TfpgColor read GetColor write SetColor;
  end;


  TfpgFontResourceBase = class(TObject)
  public
    function    GetAscent: integer; virtual; abstract;
    function    GetDescent: integer; virtual; abstract;
    function    GetHeight: integer; virtual; abstract;
    function    GetTextWidth(const txt: string): integer; virtual; abstract;
  end;


  TfpgFontBase = class(TObject)
  protected
    FFontDesc: string;
    FFontRes: TfpgFontResourceBase;
  public
    function    TextWidth(const txt: string): integer;
    function    Ascent: integer;
    function    Descent: integer;
    function    Height: integer;
    property    FontDesc: string read FFontDesc;
    property    FontRes: TfpgFontResourceBase read FFontRes;
    property    Handle: TfpgFontResourceBase read FFontRes;
  end;


  TfpgCustomInterpolation = class(TObject)
  private
    FCanvas: TfpgCanvasBase;
    FImage: TfpgImageBase;
  protected
    procedure   Initialize(AImage: TfpgImageBase; ACanvas: TfpgCanvasBase); virtual;
    procedure   Execute(x, y, w, h: integer); virtual; abstract;
  public
    property    Canvas: TfpgCanvasBase read FCanvas;
    property    Image: TfpgImageBase read FImage;
  end;
  
  
  TfpgBaseInterpolation = class(TfpgCustomInterpolation)
  private
    xfactor: double;
    yfactor: double;
    xsupport: double;
    ysupport: double;
    tempimage: TfpgImageBase;
    procedure   Horizontal(width: integer);
    procedure   Vertical(dx, dy, width, height: integer);
  protected
    procedure   Execute(x, y, w, h: integer); override;
    function    Filter(x : double): double; virtual; abstract;
    function    MaxSupport: double; virtual; abstract;
  public
    destructor  Destroy; override;
  end;


  TfpgMitchelInterpolation = class(TfpgBaseInterpolation)
  protected
    function    Filter(x: double): double; override;
    function    MaxSupport: double; override;
  end;


  TfpgCanvasBase = class(TObject)
  private
    FInterpolation: TfpgCustomInterpolation;
  protected
    FBufferedDraw: boolean;
    FBeginDrawCount: integer;
    FWindow: TfpgWindowBase;
    FColor: TfpgColor;
    FTextColor: TfpgColor;
    FLineWidth: integer;
    FLineStyle: TfpgLineStyle;
    FFont: TfpgFontBase;
    FPersistentResources: boolean;
    procedure   DoSetFontRes(fntres: TfpgFontResourceBase); virtual; abstract;
    procedure   DoSetTextColor(cl: TfpgColor); virtual; abstract;
    procedure   DoSetColor(cl: TfpgColor); virtual; abstract;
    procedure   DoSetLineStyle(awidth: integer; astyle: TfpgLineStyle); virtual; abstract;
    procedure   DoGetWinRect(var r: TfpgRect); virtual; abstract;
    procedure   DoFillRectangle(x, y, w, h: TfpgCoord); virtual; abstract;
    procedure   DoXORFillRectangle(col: TfpgColor; x, y, w, h: TfpgCoord); virtual; abstract;
    procedure   DoFillTriangle(x1, y1, x2, y2, x3, y3: TfpgCoord); virtual; abstract;
    procedure   DoDrawRectangle(x, y, w, h: TfpgCoord); virtual; abstract;
    procedure   DoDrawLine(x1, y1, x2, y2: TfpgCoord); virtual; abstract;
    procedure   DoDrawImagePart(x, y: TfpgCoord; img: TfpgImageBase; xi, yi, w, h: integer); virtual; abstract;
    procedure   DoDrawString(x, y: TfpgCoord; const txt: string); virtual; abstract;
    procedure   DoSetClipRect(const rect: TfpgRect); virtual; abstract;
    function    DoGetClipRect: TfpgRect; virtual; abstract;
    procedure   DoAddClipRect(const rect: TfpgRect); virtual; abstract;
    procedure   DoClearClipRect; virtual; abstract;
    procedure   DoBeginDraw(awin: TfpgWindowBase; buffered: boolean); virtual; abstract;
    procedure   DoPutBufferToScreen(x, y, w, h: TfpgCoord); virtual; abstract;
    procedure   DoEndDraw; virtual; abstract;
    function    GetPixel(X, Y: integer): TfpgColor; virtual; abstract;
    procedure   SetPixel(X, Y: integer; const AValue: TfpgColor); virtual; abstract;
  public
    constructor Create; virtual;
    procedure   DrawRectangle(x, y, w, h: TfpgCoord); overload;
    procedure   DrawRectangle(r: TfpgRect); overload;
    procedure   DrawLine(x1, y1, x2, y2: TfpgCoord);
    procedure   DrawImage(x, y: TfpgCoord; img: TfpgImageBase);
    procedure   DrawImagePart(x, y: TfpgCoord; img: TfpgImageBase; xi, yi, w, h: integer);
    procedure   StretchDraw (x, y, w, h: TfpgCoord; ASource: TfpgImageBase);
    procedure   DrawString(x, y: TfpgCoord; const txt: string);
    procedure   FillRectangle(x, y, w, h: TfpgCoord); overload;
    procedure   FillRectangle(r: TfpgRect); overload;
    procedure   FillTriangle(x1, y1, x2, y2, x3, y3: TfpgCoord);
    procedure   XORFillRectangle(col: TfpgColor; x, y, w, h: TfpgCoord); overload;
    procedure   XORFillRectangle(col: TfpgColor; r: TfpgRect); overload;
    procedure   SetClipRect(const rect: TfpgRect);
    function    GetClipRect: TfpgRect;
    procedure   AddClipRect(const rect: TfpgRect);
    procedure   ClearClipRect;
    procedure   Clear(AColor: TfpgColor);
    procedure   GetWinRect(var r: TfpgRect);
    procedure   SetColor(AColor: TfpgColor);
    procedure   SetTextColor(AColor: TfpgColor);
    procedure   SetLineStyle(AWidth: integer; AStyle: TfpgLineStyle);
    procedure   SetFont(AFont: TfpgFontBase);
    procedure   BeginDraw; overload;
    procedure   BeginDraw(ABuffered: boolean); overload;
    procedure   EndDraw(x, y, w, h: TfpgCoord); overload;
    procedure   EndDraw; overload;
    procedure   FreeResources;
    property    Color: TfpgColor read FColor;
    property    TextColor: TfpgColor read FTextColor;
    property    Font: TfpgFontBase read FFont write SetFont;
    property    Pixels[X, Y: integer]: TfpgColor read GetPixel write SetPixel;
  end;


  { TfpgWindowBase }

  TfpgWindowBase = class(TComponent)
  private
    FParent: TfpgWindowBase;
  protected
    FWindowType: TWindowType;
    FWindowAttributes: TWindowAttributes;
    FTop: TfpgCoord;
    FLeft: TfpgCoord;
    FWidth: TfpgCoord;
    FHeight: TfpgCoord;
    FMinWidth: TfpgCoord;
    FMinHeight: TfpgCoord;
    FCanvas: TfpgCanvasBase;
    function    HandleIsValid: boolean; virtual; abstract;
    procedure   DoUpdateWindowPosition(aleft, atop, awidth, aheight: TfpgCoord); virtual; abstract;
    procedure   DoAllocateWindowHandle(AParent: TfpgWindowBase); virtual; abstract;
    procedure   DoReleaseWindowHandle; virtual; abstract;
    procedure   DoMoveWindow(const x: TfpgCoord; const y: TfpgCoord); virtual; abstract;
    function    DoWindowToScreen(ASource: TfpgWindowBase; const AScreenPos: TPoint): TPoint; virtual; abstract;
    procedure   DoSetWindowTitle(const ATitle: string); virtual; abstract;
    procedure   SetParent(const AValue: TfpgWindowBase); virtual;
    function    GetParent: TfpgWindowBase; virtual;
    function    GetCanvas: TfpgCanvasBase; virtual;
    procedure   AllocateWindowHandle;
    procedure   ReleaseWindowHandle;
    procedure   SetWindowTitle(const ATitle: string); virtual;
  public
    // make some setup before the window shows
    procedure   AdjustWindowStyle; virtual;    // forms modify the window creation parameters
    procedure   SetWindowParameters; virtual;  // invoked after the window is created
    // general properties and functions
    function    Right: TfpgCoord;
    function    Bottom: TfpgCoord;
    procedure   UpdateWindowPosition;
    procedure   MoveWindow(const x: TfpgCoord; const y: TfpgCoord);
    function    WindowToScreen(ASource: TfpgWindowBase; const AScreenPos: TPoint): TPoint;
    property    HasHandle: boolean read HandleIsValid;
    property    WindowType: TWindowType read FWindowType write FWindowType;
    property    WindowAttributes: TWindowAttributes read FWindowAttributes write FWindowAttributes;
    property    Left: TfpgCoord read FLeft write FLeft;
    property    Top: TfpgCoord read FTop write FTop;
    property    Width: TfpgCoord read FWidth write FWidth;
    property    Height: TfpgCoord read FHeight write FHeight;
    property    MinWidth: TfpgCoord read FMinWidth write FMinWidth;
    property    MinHeight: TfpgCoord read FMinHeight write FMinHeight;
    property    Canvas: TfpgCanvasBase read GetCanvas;
    property    Parent: TfpgWindowBase read GetParent write SetParent;
  end;


  TfpgApplicationBase = class(TObject)
  protected
    FIsInitialized: Boolean;
  public
    constructor Create(const AParams: string); virtual; abstract;
    property    IsInitialized: boolean read FIsInitialized;
  end;


{ ********  Helper functions  ******** }
{ Keyboard }
function GetKeyboardShiftState(AShiftState: word): TShiftState;
function KeycodeToText(AKey: Word; AShiftState: TShiftState): string;

{ Color }
function fpgColorToRGBTriple(const AColor: TfpgColor): TRGBTriple;
function RGBTripleTofpgColor(const AColor: TRGBTriple): TfpgColor;
function fpgGetRed(const AColor: TfpgColor): word;
function fpgGetGreen(const AColor: TfpgColor): word;
function fpgGetBlue(const AColor: TfpgColor): word;
function fpgGetAlpha(const AColor: TfpgColor): word;

implementation

uses
  fpgfx;  // needed for fpgApplication

function GetKeyboardShiftState(AShiftState: word): TShiftState;
begin
  Result := [];
  if (AShiftState and ss_shift) <> 0 then
    Include(result, ssShift);

  if (AShiftState and ss_Control) <> 0 then
    Include(result, ssCtrl);

  if (AShiftState and ss_Alt) <> 0 then
    Include(result, ssAlt);

  if (AShiftState and ss_CapsLock) <> 0 then
    Include(result, ssCaps);

  if (AShiftState and ss_NumLock) <> 0 then
    Include(result, ssNum);

  if (AShiftState and ss_ScrollLock) <> 0 then
    Include(result, ssScroll);
end;

function KeycodeToText(AKey: Word; AShiftState: TShiftState): string;
begin
  Result := 'not implemented yet';
end;

function fpgColorToRGBTriple(const AColor: TfpgColor): TRGBTriple;
begin
  with Result do
  begin
    Red   := fpgGetRed(AColor);
    Green := fpgGetGreen(AColor);
    Blue  := fpgGetBlue(AColor);
//    Alpha := fpgGetAlpha(AColor);
  end
end;

function RGBTripleTofpgColor(const AColor: TRGBTriple): TfpgColor;
begin
  Result := AColor.Blue or (AColor.Green shl 8) or (AColor.Red shl 16);// or (AColor.Alpha shl 32);
end;

function fpgGetRed(const AColor: TfpgColor): word;
begin
  // AARRGGBB format
  Result := Word((AColor shr 16) and $FF);
end;

function fpgGetGreen(const AColor: TfpgColor): word;
begin
  // AARRGGBB format
  Result := Word((AColor shr 8) and $FF);
end;

function fpgGetBlue(const AColor: TfpgColor): word;
begin
  // AARRGGBB format
  Result := Word(AColor and $FF);
end;

function fpgGetAlpha(const AColor: TfpgColor): word;
begin
  // AARRGGBB format
  Result := Word((AColor shr 32) and $FF);
end;

{ TfpgRect }

procedure TfpgRect.SetRect(aleft, atop, awidth, aheight: TfpgCoord);
begin
  Left   := aleft;
  Top    := atop;
  Width  := awidth;
  Height := aheight;
end;

function TfpgRect.Bottom: TfpgCoord;
begin
  Result := Top + Height - 1;
end;

function TfpgRect.Right: TfpgCoord;
begin
  Result := Left + Width - 1;
end;

procedure TfpgRect.SetBottom(Value: TfpgCoord);
begin
  Height := Value - Top + 1;
end;

procedure TfpgRect.SetRight(Value: TfpgCoord);
begin
  Width := Value - Left + 1;
end;

{ TfpgWindowBase }

procedure TfpgWindowBase.SetParent(const AValue: TfpgWindowBase);
begin
  FParent := AValue;
end;

function TfpgWindowBase.GetParent: TfpgWindowBase;
begin
  result := FParent;
end;

function TfpgWindowBase.GetCanvas: TfpgCanvasBase;
begin
  Result := FCanvas;
end;

procedure TfpgWindowBase.AllocateWindowHandle;
begin
  DoAllocateWindowHandle(FParent);
end;

procedure TfpgWindowBase.ReleaseWindowHandle;
begin
  if HasHandle then
  begin
    Canvas.FreeResources;
    DoReleaseWindowHandle;
  end;
end;

procedure TfpgWindowBase.SetWindowTitle(const ATitle: string);
begin
  DoSetWindowTitle(ATitle);
end;

procedure TfpgWindowBase.AdjustWindowStyle;
begin
  // does nothing here
end;

procedure TfpgWindowBase.SetWindowParameters;
begin
  // does nothing
end;

function TfpgWindowBase.Right: TfpgCoord;
begin
  Result := FLeft + FWidth - 1;
end;

function TfpgWindowBase.Bottom: TfpgCoord;
begin
  Result := FTop + FHeight - 1;
end;

procedure TfpgWindowBase.UpdateWindowPosition;
begin
  if HasHandle then
    DoUpdateWindowPosition(FLeft, FTop, FWidth, FHeight);
end;

procedure TfpgWindowBase.MoveWindow(const x: TfpgCoord; const y: TfpgCoord);
begin
  DoMoveWindow(x, y);
end;

function TfpgWindowBase.WindowToScreen(ASource: TfpgWindowBase;
  const AScreenPos: TPoint): TPoint;
begin
  Result := DoWindowToScreen(ASource, AScreenPos);
end;

{ TfpgCanvasBase }

constructor TfpgCanvasBase.Create;
begin
  FBufferedDraw := True;
end;

procedure TfpgCanvasBase.DrawRectangle(x, y, w, h: TfpgCoord);
begin
  DoDrawRectangle(x, y, w, h);
end;

procedure TfpgCanvasBase.DrawRectangle(r: TfpgRect);
begin
  DoDrawRectangle(r.Left, r.Top, r.Width, r.Height);
end;

procedure TfpgCanvasBase.DrawLine(x1, y1, x2, y2: TfpgCoord);
begin
  DoDrawLine(x1, y1, x2, y2);
end;

procedure TfpgCanvasBase.DrawImage(x, y: TfpgCoord; img: TfpgImageBase);
begin
  if img = nil then
    Exit; //==>
  DrawImagePart(x, y, img, 0, 0, img.Width, img.Height);
end;

procedure TfpgCanvasBase.DrawImagePart(x, y: TfpgCoord; img: TfpgImageBase; xi,
  yi, w, h: integer);
begin
  DoDrawImagePart(x, y, img, xi, yi, w, h);
end;

procedure TfpgCanvasBase.StretchDraw(x, y, w, h: TfpgCoord; ASource: TfpgImageBase);
var
  i: TfpgCustomInterpolation;
  FreeInterpolation: boolean;
  IP: TfpgCustomInterpolation;
begin
  FreeInterpolation := not Assigned(FInterpolation);
  if FreeInterpolation then
    IP := TfpgMitchelInterpolation.Create
  else
    IP := FInterpolation;
  try
    IP.Initialize(ASource, self);
    IP.Execute(x, y, w, h);
  finally
    if FreeInterpolation then
      IP.Free;
  end;
end;

procedure TfpgCanvasBase.DrawString(x, y: TfpgCoord; const txt: string);
begin
  DoDrawString(x, y, txt);
end;

procedure TfpgCanvasBase.FillRectangle(x, y, w, h: TfpgCoord);
begin
  DoFillRectangle(x, y, w, h);
end;

procedure TfpgCanvasBase.FillRectangle(r: TfpgRect);
begin
  DoFillRectangle(r.Left, r.Top, r.Width, r.Height);
end;

procedure TfpgCanvasBase.FillTriangle(x1, y1, x2, y2, x3, y3: TfpgCoord);
begin
  DoFillTriangle(x1, y1, x2, y2, x3, y3);
end;

procedure TfpgCanvasBase.XORFillRectangle(col: TfpgColor; x, y, w, h: TfpgCoord);
begin
  DoXORFillRectangle(col, x, y, w, h);
end;

procedure TfpgCanvasBase.XORFillRectangle(col: TfpgColor; r: TfpgRect);
begin
  DoXORFillRectangle(col, r.Left, r.Top, r.Width, r.Height);
end;

procedure TfpgCanvasBase.SetClipRect(const rect: TfpgRect);
begin
  DoSetClipRect(rect);
end;

function TfpgCanvasBase.GetClipRect: TfpgRect;
begin
  Result := DoGetClipRect;
end;

procedure TfpgCanvasBase.AddClipRect(const rect: TfpgRect);
begin
  DoAddClipRect(rect);
end;

procedure TfpgCanvasBase.ClearClipRect;
begin
  DoClearClipRect;
end;

procedure TfpgCanvasBase.Clear(AColor: TfpgColor);
var
  lCol:     TfpgColor;
  lWinRect: TfpgRect;
begin
  lCol := FColor;
  DoSetColor(AColor);
  DoGetWinRect(lWinRect);
  DoFillRectangle(0, 0, lWinRect.Width, lWinRect.Height);
  DoSetColor(lCol);
end;

procedure TfpgCanvasBase.GetWinRect(var r: TfpgRect);
begin
  DoGetWinRect(r);
end;

procedure TfpgCanvasBase.SetColor(AColor: TfpgColor);
begin
  FColor := AColor;
  DoSetColor(FColor);
end;

procedure TfpgCanvasBase.SetTextColor(AColor: TfpgColor);
begin
  FTextColor := AColor;
  DoSetTextColor(FTextColor);
end;

procedure TfpgCanvasBase.SetLineStyle(AWidth: integer; AStyle: TfpgLineStyle);
begin
  FLineWidth := AWidth;
  FLineStyle := AStyle;
  DoSetLineStyle(FLineWidth, FLineStyle);
end;

procedure TfpgCanvasBase.SetFont(AFont: TfpgFontBase);
begin
  FFont := AFont;
  DoSetFontRes(AFont.FFontRes);
end;

procedure TfpgCanvasBase.BeginDraw;
begin
  BeginDraw(FBufferedDraw);
end;

procedure TfpgCanvasBase.BeginDraw(ABuffered: boolean);
begin
  if FBeginDrawCount < 1 then
  begin
    DoBeginDraw(FWindow, ABuffered);

    SetColor(clText1);
    SetTextColor(clText1);
    SetFont(fpgApplication.DefaultFont);
    SetLineStyle(0, lsSolid);

    FBeginDrawCount := 0;
  end;
  Inc(FBeginDrawCount);
end;

procedure TfpgCanvasBase.EndDraw(x, y, w, h: TfpgCoord);
begin
  if FBeginDrawCount > 0 then
  begin
    Dec(FBeginDrawCount);
    if FBeginDrawCount = 0 then
    begin
      DoPutBufferToScreen(x, y, w, h);

      if not FPersistentResources then
        DoEndDraw;
    end;
  end;  { if }
end;

procedure TfpgCanvasBase.EndDraw;
begin
  EndDraw(0, 0, FWindow.Width, FWindow.Height);
end;

procedure TfpgCanvasBase.FreeResources;
begin
  DoEndDraw;
  FBeginDrawCount := 0;
end;

{ TfpgFontBase }

function TfpgFontBase.TextWidth(const txt: string): integer;
begin
  Result := FFontRes.GetTextWidth(txt);
end;

function TfpgFontBase.Ascent: integer;
begin
  Result := FFontRes.GetAscent;
end;

function TfpgFontBase.Descent: integer;
begin
  Result := FFontRes.GetDescent;
end;

function TfpgFontBase.Height: integer;
begin
  Result := FFontRes.GetHeight;
end;

{ TfpgCustomInterpolation }

procedure TfpgCustomInterpolation.Initialize(AImage: TfpgImageBase;
  ACanvas: TfpgCanvasBase);
begin
  FImage  := AImage;
  FCanvas := ACanvas;
end;

{ TfpgBaseInterpolation }

type
  TfpgInterpolationContribution = record
    weight: double;
    place: integer;
  end;

function ColorRound(c: double): word;
begin
  if c > $FFFF then
    result := $FFFF
  else if c < 0.0 then
    result := 0
  else
    result := round(c);
end;


procedure TfpgBaseInterpolation.Horizontal(width: integer);
var
  x, y, r: integer;
  start, stop, maxcontribs: integer;
  center, re, gr, bl, density: double;
  contributions: array[0..10] of TfpgInterpolationContribution;
  dif, w, gamma, a: double;
  c: TfpgColor;
  rgb: TRGBTriple;
begin
  for x := 0 to Width - 1 do
  begin
    center := x * xfactor;
    start  := round(center - xsupport);
    if start < 0 then
      start := 0;
    stop := round(center + xsupport);
    if stop >= image.Width then
      stop := image.Width - 1;
    density     := 0.0;
    maxcontribs := -1;
    for r := start to stop do
    begin
      dif := r - center;
      w   := Filter(dif);
      if w > 0.0 then
      begin
        Inc(maxcontribs);
        with contributions[maxcontribs] do
        begin
          weight  := w;
          density := density + w;
          place   := r;
        end;
      end;
    end;
    if (density <> 0.0) and (density <> 1.0) then
    begin
      density := 1.0 / density;
      for r := 0 to maxcontribs do
        contributions[r].weight := contributions[r].weight * density;
    end;
    for y := 0 to image.Height - 1 do
    begin
      gamma := 0.0;
      re    := 0.0;
      gr    := 0.0;
      bl    := 0.0;
      for r := 0 to maxcontribs do
        with contributions[r] do
        begin
          c   := image.colors[place, y];
          rgb := fpgColorToRGBTriple(c);
          a     := weight; // * rgb.Alpha / $FFFF;
          re    := re + a * rgb.Red;
          gr    := gr + a * rgb.Green;
          bl    := bl + a * rgb.Blue;
          gamma := gamma + a;
        end;  { with }
      with rgb do
      begin
        red   := ColorRound(re);
        green := ColorRound(gr);
        blue  := ColorRound(bl);
//        alpha := ColorRound(gamma * $FFFF);
      end;
      tempimage.colors[x, y] := RGBTripleTofpgColor(rgb);
    end;
  end;
end;

procedure TfpgBaseInterpolation.Vertical(dx, dy, width, height: integer);
var
  x, y, r: integer;
  start, stop, maxcontribs: integer;
  center, re, gr, bl, density: double;
  contributions: array[0..10] of TfpgInterpolationContribution;
  dif, w, gamma, a: double;
  c: TfpgColor;
  rgb: TRGBTriple;
begin
  for y := 0 to Height - 1 do
  begin
    center := y * yfactor;
    start  := round(center - ysupport);
    if start < 0 then
      start := 0;
    stop := round(center + ysupport);
    if stop >= tempimage.Height then
      stop := tempimage.Height - 1;
    density     := 0.0;
    maxcontribs := -1;
    for r := start to stop do
    begin
      dif := r - center;
      w   := Filter(dif);
      if w > 0.0 then
      begin
        Inc(maxcontribs);
        with contributions[maxcontribs] do
        begin
          weight  := w;
          density := density + w;
          place   := r;
        end;
      end;
    end;
    if (density <> 0.0) and (density <> 1.0) then
    begin
      density := 1.0 / density;
      for r := 0 to maxcontribs do
        contributions[r].weight := contributions[r].weight * density;
    end;
    for x := 0 to Width - 1 do
    begin
      gamma := 0.0;
      re    := 0.0;
      gr    := 0.0;
      bl    := 0.0;
      for r := 0 to maxcontribs do
        with contributions[r] do
        begin
          c := tempimage.colors[x, place];
          rgb := fpgColorToRGBTriple(c);
          a     := weight;// * rgb.alpha / $FFFF;
          re    := re + a * rgb.red;
          gr    := gr + a * rgb.green;
          bl    := bl + a * rgb.blue;
          gamma := gamma + a;
        end;  { width }
      with rgb do
      begin
        red   := ColorRound(re);
        green := ColorRound(gr);
        blue  := ColorRound(bl);
//        alpha := ColorRound(gamma * $FFFF);
      end;
      Canvas.Pixels[x + dx, y + dy] := RGBTripleTofpgColor(rgb);
    end;
  end;
end;

procedure TfpgBaseInterpolation.Execute(x, y, w, h: integer);
var
  maxy: integer;
  rx, ry: integer;
begin
  tempimage := TfpgImageBase.Create;
  tempimage.AllocateImage(image.ColorDepth, w, image.Height);

  xfactor   := image.Width / w;
  yfactor   := image.Height / h;
  if xfactor > 1.0 then
    xsupport := MaxSupport
  else
    xsupport := xfactor * MaxSupport;
  if yfactor > 1.0 then
    ysupport := MaxSupport
  else
    ysupport := yfactor * MaxSupport;
  Horizontal(w);
  Vertical(x, y, w, h);
end;

destructor TfpgBaseInterpolation.Destroy;
begin
  tempimage.Free;
  inherited Destroy;
end;

{ TfpgImageBase }

function TfpgImageBase.GetColor(x, y: TfpgCoord): TfpgColor;
var
  p: Plongword;
begin
  p := FImageData;
  Inc(p, (FWidth * y) + x);
  Result := TfpgColor(p^);
//  write(IntToHex(Result, 6) + ' ');
end;

procedure TfpgImageBase.SetColor(x, y: TfpgCoord; const AValue: TfpgColor);
var
  p: Plongword;
begin
  p := FImageData;
  Inc(p, (FWidth * y) + x);
  p^ := longword(AValue);
//  write(IntToHex(AValue, 6) + ' ');
end;

constructor TfpgImageBase.Create;
begin
  FWidth      := 0;
  FHeight     := 0;
  FColorDepth := 0;

  FImageData     := nil;
  FImageDataSize := 0;
  FMaskData      := nil;
  FMaskDataSize  := 0;
  FMasked        := False;
end;

destructor TfpgImageBase.Destroy;
begin
  FreeImage;
  inherited Destroy;
end;

procedure TfpgImageBase.Invert;
var
  p: ^byte;
  n: integer;
begin
  if FImageData = nil then
    Exit; //==>

  p := FImageData;
  for n := 1 to FImageDataSize do
  begin
    p^ := p^ xor $FF;
    Inc(p);
  end;

  if FMaskData <> nil then
  begin
    p := FMaskData;
    for n := 1 to FMaskDataSize do
    begin
      p^ := p^ xor $FF;
      Inc(p);
    end;
  end;
end;

procedure TfpgImageBase.FreeImage;
begin
  if FImageData <> nil then
    FreeMem(FImageData);
  FImageData     := nil;
  FImageDataSize := 0;
  if FMaskData <> nil then
    FreeMem(FMaskData);
  FMaskData     := nil;
  FMaskDataSize := 0;
  FMasked       := False;
  FWidth        := 0;
  FHeight       := 0;
//  DoFreeImage;
end;

procedure TfpgImageBase.AllocateImage(acolordepth, awidth, aheight: integer);
var
  dww: integer;
begin
  FreeImage;
  FWidth      := awidth;
  FHeight     := aheight;
  FColorDepth := acolordepth;

  // Real bitmap
  if FColorDepth = 1 then
    dww := (awidth + 31) div 32
  else
    dww := FWidth;

  FImageDataSize := dww * FHeight * 4;
  GetMem(FImageData, FImageDataSize);
end;

procedure TfpgImageBase.AllocateMask;
var
  dww: integer;
begin
  if (FWidth < 1) or (FHeight < 1) then
    Exit; //==>

  FMasked := True;
  if FMaskData <> nil then
    FreeMem(FMaskData);

  dww           := (FWidth + 31) div 32;
  FMaskDataSize := dww * FHeight * 4;
  GetMem(FMaskData, FMaskDataSize);
end;

procedure TfpgImageBase.CreateMaskFromSample(x, y: TfpgCoord);
var
  p: ^longword;
  pmsk: ^byte;
  c: longword;
  linecnt: integer;
  pixelcnt: integer;
  bit: byte;
  msklinelen: integer;
begin
  if FColorDepth = 1 then
    Exit; //==>

  if (FImageData = nil) then
    Exit; //==>

  AllocateMask;

  p := FImageData;
  if x < 0 then
    Inc(p, FWidth - 1)
  else
    Inc(p, x);
  if y < 0 then
    Inc(p, FWidth * (FHeight - 1))
  else
    Inc(p, FWidth * y);

  c := p^;  // the sample

  msklinelen := FWidth div 32;
  if (FWidth and $1F) > 0 then
    Inc(msklinelen);

  msklinelen := msklinelen shl 2;

  p       := FImageData;
  linecnt := 0;

  repeat
    pixelcnt := 0;
    bit      := $80;
    pmsk     := FMaskData;
    Inc(pmsk, linecnt * msklinelen);

    repeat
      if bit = $80 then
        pmsk^ := 0;

      if p^ <> c then
        pmsk^ := pmsk^ or bit;

      Inc(p);
      Inc(pixelcnt);

      if bit = 1 then
      begin
        bit := $80;
        Inc(pmsk);
      end
      else
        bit := bit shr 1;
    until pixelcnt >= FWidth;

    Inc(linecnt);
  until linecnt >= FHeight;
end;

procedure TfpgImageBase.UpdateImage;
begin
  if FImageData <> nil then
    DoInitImage(FColorDepth, FWidth, FHeight, FImageData);

  if FMaskData <> nil then
    DoInitImageMask(FWidth, FHeight, FMaskData);
end;

{ TfpgMitchelInterpolation }

function TfpgMitchelInterpolation.Filter(x: double): double;
const
  B  = (1.0/3.0);
  C  = (1.0/3.0);
  P0 = ((  6.0- 2.0*B       )/6.0);
  P2 = ((-18.0+12.0*B+ 6.0*C)/6.0);
  P3 = (( 12.0- 9.0*B- 6.0*C)/6.0);
  Q0 = ((       8.0*B+24.0*C)/6.0);
  Q1 = ((     -12.0*B-48.0*C)/6.0);
  Q2 = ((       6.0*B+30.0*C)/6.0);
  Q3 = ((     - 1.0*B- 6.0*C)/6.0);
begin
  if (x < -2.0) then
    result := 0.0
  else if (x < -1.0) then
    result := Q0-x*(Q1-x*(Q2-x*Q3))
  else if (x < 0.0) then
    result := P0+x*x*(P2-x*P3)
  else if (x < 1.0) then
    result := P0+x*x*(P2+x*P3)
  else if (x < 2.0) then
    result := Q0+x*(Q1+x*(Q2+x*Q3))
  else
  result := 0.0;
end;

function TfpgMitchelInterpolation.MaxSupport: double;
begin
  result := 2.0;
end;

end.

