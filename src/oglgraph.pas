unit oglgraph;
{$mode objfpc}
interface

uses gl, glu, sysutils
     {$if defined(win32)}, Windows{$endif}
     {$if defined(unix)}, x, xlib, glx14, iconvenc{$endif}
     ;


const InternalDriverName = 'OpenGLGraph';
{$i graphh.inc}
{$if defined(win32)}
 var
    { this procedure allows to hook keyboard messages }
    charmessagehandler : WndProc = nil;
{$endif}

CONST
  {$if defined(win32)}
  InputEncoding='CP1251';
  {$endif}
  {$if defined(unix)}
  InputEncoding='UTF8';
  {$endif}
  OutputEncoding='CP866';
     
  m640x200x16       = VGALo;
  m640x400x16       = VGAMed;
  m640x480x16       = VGAHi;

  { VESA Specific video modes. }
  m320x200x32k      = $10D;
  m320x200x64k      = $10E;

  m640x400x256      = $100;

  m640x480x256      = $101;
  m640x480x32k      = $110;
  m640x480x64k      = $111;

  m800x600x16       = $102;
  m800x600x256      = $103;
  m800x600x32k      = $113;
  m800x600x64k      = $114;

  m1024x768x16      = $104;
  m1024x768x256     = $105;
  m1024x768x32k     = $116;
  m1024x768x64k     = $117;

  m1280x1024x16     = $106;
  m1280x1024x256    = $107;
  m1280x1024x32k    = $119;
  m1280x1024x64k    = $11A;



procedure graphSwapBuffers;
function graphKeyPressed : boolean;
function graphReadKey : Word;
procedure SetDoubleBuffer(Enable : boolean);
//procedure SetPerspectiveDraw(Enable : boolean);
//procedure SetPerspectiveAttribute(alphaX, alphaY, alphaZ : Single);


implementation
uses crt, math;
var pal : array of RGBRec;
    gl_color : Word;
    keycode : integer;
    graphInited  : boolean = false;

    Doublebuffer : boolean = false;
    Perspective  : boolean = false;

{$i graph.inc}
  
{$if defined(win32)}
 var
    { this procedure allows to hook mouse messages }
    mousemessagehandler : WndProc = nil;
    { this procedure allows to wm_command messages }
    commandmessagehandler : WndProc = nil;
    NotifyMessageHandler : WndProc = nil;

    OnGraphWindowCreation : procedure = nil;

    GraphWindow,ParentWindow : HWnd;
    // this allows direct drawing to the window
    bitmapdc : hdc;
    windc : hdc;

    hWinDC:HDC;
    hWinRC:HGLRC;

  const
    { predefined window style }
    { we shouldn't set CS_DBLCLKS here }
    { because most dos applications    }
    { handle double clicks on it's own }
    graphwindowstyle : DWord = cs_hRedraw or cs_vRedraw;

    windowtitle : pchar = 'Graph window application';
    menu : hmenu = 0;
    icon : hicon = 0;
    drawtoscreen : boolean = true;
    drawtobitmap : boolean = true;

  var
   savedscreen : hbitmap;
   graphrunning : boolean;
   graphdrawing : tcriticalsection;
   oldbitmap : hgdiobj;
   MessageThreadHandle : Handle;
   MessageThreadID : DWord;


    const
       keybuffersize = 32;

    var
       keyboardhandling : TCriticalSection;
       keybuffer : array[1..keybuffersize] of char;
       nextfree,nexttoread : longint;

    procedure inccyclic(var i : longint);

      begin
         inc(i);
         if i>keybuffersize then
           i:=1;
      end;

    procedure addchar(c : char);

      begin
         EnterCriticalSection(keyboardhandling);
         keybuffer[nextfree]:=c;
         inccyclic(nextfree);
         { skip old chars }
         if nexttoread=nextfree then
           begin
              // special keys are started by #0
              // so we've to remove two chars
              if keybuffer[nexttoread]=#0 then
                inccyclic(nexttoread);
              inccyclic(nexttoread);
           end;
         LeaveCriticalSection(keyboardhandling);
      end;

    procedure addextchar(c : char);

      begin
         addchar(#0);
         addchar(c);
      end;

    const
       altkey : boolean = false;
       ctrlkey : boolean = false;
       shiftkey : boolean = false;

    function msghandler(Window: HWnd; AMessage:UInt; WParam : WParam; LParam: LParam): Longint; stdcall;

      begin
         case amessage of
           WM_CHAR:
             begin
                addchar(chr(wparam));
             end;
           WM_KEYDOWN:
             begin
                case wparam of
                   VK_LEFT:
                     addextchar(#75);
                   VK_RIGHT:
                     addextchar(#77);
                   VK_DOWN:
                     addextchar(#80);
                   VK_UP:
                     addextchar(#72);
                   VK_INSERT:
                     addextchar(#82);
                   VK_DELETE:
                     addextchar(#83);
                   VK_END:
                     addextchar(#79);
                   VK_HOME:
                     addextchar(#71);
                   VK_PRIOR:
                     addextchar(#73);
                   VK_NEXT:
                     addextchar(#81);
                   VK_F1..VK_F10:
                     begin
                        if ctrlkey then
                          addextchar(chr(wparam+24))
                        else if altkey then
                          addextchar(chr(wparam+34))
                        else
                          addextchar(chr(wparam-11));
                     end;
                   VK_CONTROL:
                     ctrlkey:=true;
                   VK_MENU:
                     altkey:=true;
                   VK_SHIFT:
                     shiftkey:=true;
                end;
             end;
           WM_KEYUP:
             begin
                case wparam of
                   VK_CONTROL:
                     ctrlkey:=false;
                   VK_MENU:
                     altkey:=false;
                   VK_SHIFT:
                     shiftkey:=false;
                end;
             end;
         end;
         msghandler:=0;
      end;

    var
       oldexitproc : pointer;

    procedure myexitproc;

      begin
         exitproc:=oldexitproc;
         charmessagehandler:=nil;
         DeleteCriticalSection(keyboardhandling);
      end;










procedure SetDCPixelFormat (dc: HDC);
  var pfd: TPixelFormatDescriptor;
      nPixelFormat: Integer;
  begin
    FillChar (pfd, SizeOf (pfd),0);
    with pfd do
      begin
        nSize:= sizeof (pfd);
        nVersion:= 1;
        dwFlags:= PFD_DRAW_TO_WINDOW or
                  PFD_SUPPORT_OPENGL or
                  PFD_DOUBLEBUFFER;
        iPixelType:= PFD_TYPE_RGBA;
        cColorBits:= 16;
        cDepthBits:= 64;
        iLayerType:= PFD_MAIN_PLANE;
      end;
    nPixelFormat:=ChoosePixelFormat (DC,@pfd);
    SetPixelFormat (DC, nPixelFormat,@pfd);
  end;




function WindowProcGraph(Window: HWnd; AMessage:UInt; WParam : WParam;
                    LParam: LParam): Longint; stdcall;

  var
     dc : hdc;
     ps : paintstruct;
     r : rect;
     oldbrush : hbrush;
     oldpen : hpen;
     i : longint;

begin
  WindowProcGraph := 0;

  case AMessage of
    wm_lbuttondown,
    wm_rbuttondown,
    wm_mbuttondown,
    wm_lbuttonup,
    wm_rbuttonup,
    wm_mbuttonup,
    wm_lbuttondblclk,
    wm_rbuttondblclk,
    wm_mbuttondblclk:
      begin
         if assigned(mousemessagehandler) then
           WindowProcGraph:=mousemessagehandler(window,amessage,wparam,lparam);
      end;
    wm_notify:
      begin
         if assigned(notifymessagehandler) then
           WindowProcGraph:=notifymessagehandler(window,amessage,wparam,lparam);
      end;
    wm_command:
      if assigned(commandmessagehandler) then
        WindowProcGraph:=commandmessagehandler(window,amessage,wparam,lparam);
    wm_keydown,
    wm_keyup,
    wm_char:
      begin
         if assigned(charmessagehandler) then
           WindowProcGraph:=charmessagehandler(window,amessage,wparam,lparam);
      end;
    wm_paint:
      begin
         graphrunning:=true;

{$ifdef DEBUG_WM_PAINT}
         inc(wm_paint_count);
{$endif DEBUG_WM_PAINT}
{$ifdef DEBUGCHILDS}
         writeln('Start child painting');
{$endif DEBUGCHILDS}
         if not GetUpdateRect(Window,@r,false) then
           exit;
         EnterCriticalSection(graphdrawing);
         graphrunning:=true;
         dc:=BeginPaint(Window,@ps);
{$ifdef DEBUG_WM_PAINT}
         Writeln(graphdebug,'WM_PAINT in ((',r.left,',',r.top,
           '),(',r.right,',',r.bottom,'))');
{$endif def DEBUG_WM_PAINT}
         if graphrunning then
           {BitBlt(dc,0,0,maxx+1,maxy+1,bitmapdc,0,0,SRCCOPY);}
           BitBlt(dc,r.left,r.top,r.right-r.left+1,r.bottom-r.top+1,bitmapdc,r.left,r.top,SRCCOPY);
         EndPaint(Window,ps);
         LeaveCriticalSection(graphdrawing);
         Exit;

      end;


    wm_create:
      begin
{$ifdef DEBUG_WM_PAINT}
         assign(graphdebug,'wingraph.log');
         rewrite(graphdebug);
{$endif DEBUG_WM_PAINT}
{$ifdef DEBUGCHILDS}
         writeln('Creating window (HWND: ',window,')... ');
{$endif DEBUGCHILDS}
         GraphWindow:=window;
         EnterCriticalSection(graphdrawing);
         dc:=GetDC(window);
{$ifdef DEBUGCHILDS}
         writeln('Window DC: ',dc);
{$endif DEBUGCHILDS}
         bitmapdc:=CreateCompatibleDC(dc);
         savedscreen:=CreateCompatibleBitmap(dc,maxx+1,maxy+1);
         ReleaseDC(window,dc);
         oldbitmap:=SelectObject(bitmapdc,savedscreen);
         windc:=GetDC(window);
         // clear everything
         oldpen:=SelectObject(bitmapdc,GetStockObject(BLACK_PEN));
         oldbrush:=SelectObject(bitmapdc,GetStockObject(BLACK_BRUSH));
         Windows.Rectangle(bitmapdc,0,0,maxx,maxy);
         SelectObject(bitmapdc,oldpen);
         SelectObject(bitmapdc,oldbrush);
         // ... the window too
         oldpen:=SelectObject(windc,GetStockObject(BLACK_PEN));
         oldbrush:=SelectObject(windc,GetStockObject(BLACK_BRUSH));
         Windows.Rectangle(windc,0,0,maxx,maxy);
         SelectObject(windc,oldpen);
         SelectObject(windc,oldbrush);

         if assigned(OnGraphWindowCreation) then
           OnGraphWindowCreation;
         LeaveCriticalSection(graphdrawing);
{$ifdef DEBUGCHILDS}
         writeln('done');
         GetClientRect(window,@r);
         writeln('Window size: ',r.right,',',r.bottom);
{$endif DEBUGCHILDS}
      end;
    wm_Destroy:
      begin
         EnterCriticalSection(graphdrawing);
         graphrunning:=false;
         ReleaseDC(GraphWindow,windc);
         SelectObject(bitmapdc,oldbitmap);
         DeleteObject(savedscreen);
         DeleteDC(bitmapdc);

         LeaveCriticalSection(graphdrawing);
{$ifdef DEBUG_WM_PAINT}
         close(graphdebug);
{$endif DEBUG_WM_PAINT}
         PostQuitMessage(0);
         Exit;
      end
    else
      WindowProcGraph := DefWindowProc(Window, AMessage, WParam, LParam);
  end;
end;


function WinRegister: Boolean;
var
  WindowClass: WndClass;
begin
  WindowClass.Style := graphwindowstyle;
  WindowClass.lpfnWndProc := WndProc(@WindowProcGraph);
  WindowClass.cbClsExtra := 0;
  WindowClass.cbWndExtra := 0;
  WindowClass.hInstance := system.MainInstance;
  if icon<>0 then
    WindowClass.hIcon := icon
  else
    WindowClass.hIcon := LoadIcon(0, idi_Application);
  WindowClass.hCursor := LoadCursor(0, idc_Arrow);
  WindowClass.hbrBackground := GetStockObject(BLACK_BRUSH);
  if menu<>0 then
    WindowClass.lpszMenuName := MAKEINTRESOURCE(menu)
  else
    WindowClass.lpszMenuName := nil;
  WindowClass.lpszClassName := 'FPCGraphWindow';

  winregister:=RegisterClass(WindowClass) <> 0;
end;


 { Create the Window Class }
function WinCreate : HWnd;
var
  hWindow: HWnd;
begin
  WinCreate:=0;
  hWindow:=CreateWindow('FPCGraphWindow', windowtitle,
            ws_OverlappedWindow, longint(CW_USEDEFAULT), 0,
            maxx+1+2*GetSystemMetrics(SM_CXFRAME),
            maxy+1+2*GetSystemMetrics(SM_CYFRAME)+
            GetSystemMetrics(SM_CYCAPTION),
            0, 0, system.MainInstance, nil);
  if hWindow <> 0 then
   begin
      ShowWindow(hWindow, SW_SHOW);
      UpdateWindow(hWindow);
      WinCreate:=hWindow;
   end;
end;

const
   winregistered : boolean = false;

function MessageHandleThread(p : pointer) : DWord;StdCall;

  var
     AMessage: Msg;

  begin
     if not(winregistered) then
       begin
         if not(WinRegister) then
           begin
              MessageBox(0, 'Window registration failed', nil, mb_Ok);
              ExitThread(1);
           end;
         winregistered:=true;
       end;
     GraphWindow:=WinCreate;
     if longint(GraphWindow) = 0 then begin
       MessageBox(0, 'Window creation failed', nil, mb_Ok);
       ExitThread(1);
     end;
     while longint(GetMessage(@AMessage, 0, 0, 0))=longint(true) do
       begin
          TranslateMessage(AMessage);
          DispatchMessage(AMessage);
       end;
     MessageHandleThread:=0;
  end;


procedure ogl_InitModeWin32;
  var
     threadexitcode : longint;
  begin
      { start graph subsystem }
     InitializeCriticalSection(graphdrawing);
     graphrunning:=false;
     MessageThreadHandle:=CreateThread(nil,0,@MessageHandleThread,
       nil,0,MessageThreadID);
     repeat
       GetExitCodeThread(MessageThreadHandle,@threadexitcode);
     until graphrunning or (threadexitcode<>STILL_ACTIVE);
     if threadexitcode<>STILL_ACTIVE then
        _graphresult := grerror;

         hWinDC:=GetDC(GraphWindow);
         SetDCPixelFormat (hWinDC);
         hWinRC:=wglCreateContext (hWinDC);
         wglMakeCurrent (hWinDC, hWinRC);
  end;

function ogl_ReadKeyWin32() : word;
  begin
     while true do
       begin
          EnterCriticalSection(keyboardhandling);
          if nexttoread<>nextfree then
            begin
               ogl_ReadKeyWin32:=ord(keybuffer[nexttoread]);
               inccyclic(nexttoread);
               LeaveCriticalSection(keyboardhandling);
               exit;
            end;
          LeaveCriticalSection(keyboardhandling);
          { give other threads a chance }
          delay(10);
       end;
  end;

function ogl_KeyPressedWin32() : boolean;
  begin
    EnterCriticalSection(keyboardhandling);
    ogl_KeyPressedWin32:=nexttoread<>nextfree;
    LeaveCriticalSection(keyboardhandling);
  end;


procedure ogl_CloseGraphWin32;
  begin
     If not isgraphmode then
       begin
         _graphresult := grnoinitgraph;
         exit
       end;
     wglMakeCurrent(0,0);
     wglDeleteContext(hWinRC);
     PostMessage(GraphWindow,wm_destroy,0,0);

     PostThreadMessage(MessageThreadHandle,wm_quit,0,0);
     WaitForSingleObject(MessageThreadHandle,Infinite);
     CloseHandle(MessageThreadHandle);
     DeleteCriticalSection(graphdrawing);
     setLength(pal,0);

     MessageThreadID := 0;
     MessageThreadHandle := 0;
     isgraphmode := false;
  end;



procedure ogl_GetScreenResolutionWin32(var Width, Height : Word);
  begin
     Width:=GetSystemMetrics(SM_CXSCREEN)-2*GetSystemMetrics(SM_CXFRAME);
     Height:=GetSystemMetrics(SM_CYSCREEN)-2*GetSystemMetrics(SM_CYFRAME)-GetSystemMetrics(SM_CYCAPTION);
  end;

procedure ogl_SwapBuffersWin32;
  begin
    SwapBuffers(hWinDC);
  end;



{$endif}


{$if defined(unix)}
var
  TheDisplay: PDisplay;
  TheScreen: Longint;
  TheDrawable: TDrawable;
  TheGLXContext: TGLXContext;
procedure ogl_InitModeX;
  var
    event: TXEvent;
    AttribParams: PInteger;//array[0..12] of integer;
    FBConfigs: PGLXFBConfig;
    nelem: integer;
  begin
    TheDisplay := XOpenDisplay(nil);
    if TheDisplay = nil then
      _graphResult:=grError;
    TheScreen := XDefaultScreen(TheDisplay);
    TheDrawable := XCreateSimpleWindow(TheDisplay, XDefaultRootWindow(TheDisplay),
                     0, 0, MaxX+1, MaxY+1,
                     0, XBlackPixel(TheDisplay, TheScreen), XBlackPixel(TheDisplay, TheScreen));
    XSelectInput(TheDisplay, TheDrawable, StructureNotifyMask + KeyPressMask + KeyReleaseMask);
    XMapWindow(TheDisplay, TheDrawable);
    repeat
      XNextEvent(TheDisplay, @event);
      if event._type = MapNotify then Break;
    until false;

    GetMem(AttribParams,SizeOf(integer)*13);
    AttribParams[0]:=GLX_DRAWABLE_TYPE;
    AttribParams[1]:={GLX_PBUFFER_BIT;}GLX_WINDOW_BIT;
    AttribParams[2]:=GLX_RENDER_TYPE;
    AttribParams[3]:=GLX_RGBA_BIT;
    // Request a double-buffered color buffer with
    AttribParams[4]:=GLX_DOUBLEBUFFER;
    AttribParams[5]:=1;
    // the maximum number of bits per component
    AttribParams[6]:=GLX_RED_SIZE;
    AttribParams[7]:=1;
    AttribParams[8]:=GLX_GREEN_SIZE;
    AttribParams[9]:=1;
    AttribParams[10]:=GLX_BLUE_SIZE;
    AttribParams[11]:=1;
    AttribParams[12]:=GLX_GL_NONE;

    FBConfigs:=glXChooseFBConfig(TheDisplay, TheScreen, AttribParams, nelem);
    TheGLXContext:=glXCreateNewContext(TheDisplay, FBConfigs[0], GLX_RGBA_TYPE, nil, true);
    glXMakeContextCurrent(TheDisplay, TheDrawable, TheDrawable, TheGLXContext);
  end;
procedure ogl_CloseGraphX;
  begin
    glFinish;
    glXDestroyContext(TheDisplay, TheGLXContext);
    XCloseDisplay(TheDisplay);
  end;
procedure ogl_SwapBuffersX;
  begin
    glXSwapBuffers(TheDisplay, TheDrawable);
  end;

function ogl_KeyPressedX: boolean;
var myevent: TXEvent;
begin
  ogl_KeyPressedX := False;
  while XPending(TheDisplay) > 0 do begin
    XNextEvent(TheDisplay, @myevent);
      if myevent._type = keypress then
        begin
          ogl_KeyPressedX := True;
          keycode:=myevent.xkey.keycode;
        end;

  end;
end;
function ogl_ReadKeyX : Word;
var myevent: TXEvent;
  begin
    while keycode<0 do
      begin
        ogl_KeyPressedX;
        delay(10);
      end;
    Result:=keycode;
    keycode:=-1;
  end;

procedure ogl_GetScreenResolutionX(var Width, Height : Word);
  var Display : PDisplay;
      Screen : PScreen;
  begin
    Display := XOpenDisplay(nil);
    if Display = nil then
      _graphResult:=grError;
    Screen := XDefaultScreenOfDisplay(Display);
    Width:=XWidthOfScreen(Screen);
    Height:=XHeightOfScreen(Screen);
    XCloseDisplay(Display);
  end;

{$endif}

function graphReadKey : Word;
  begin
    {$IFDEF WIN32}Result:=ogl_ReadKeyWin32;{$ENDIF}
    {$IFDEF UNIX}Result:=ogl_ReadKeyX;{$ENDIF}
  end;

procedure SetDoubleBuffer(Enable: boolean);
begin
  DoubleBuffer:=Enable;
  if graphInited then
    if Enable then
      glDrawBuffer(GL_BACK)
    else
      glDrawBuffer(GL_FRONT);
end;

procedure SetPerspectiveDraw(Enable: boolean);
begin
  Perspective:=Enable;
end;

function graphKeyPressed: boolean;
  begin
    {$IFDEF WIN32}Result:=ogl_KeyPressedWin32;{$ENDIF}
    {$IFDEF UNIX}Result:=ogl_KeyPressedX;{$ENDIF}
  end;

procedure graphSwapBuffers;
  begin
    if graphInited then
    {$IFDEF WIN32}ogl_SwapBuffersWin32;{$ENDIF}
    {$IFDEF UNIX}ogl_SwapBuffersX;{$ENDIF}
  end;

procedure GetScreenResolution(var Width, Height : Word);
  begin
    {$IFDEF WIN32}ogl_GetScreenResolutionWin32(Width, Height);{$ENDIF}
    {$IFDEF UNIX}ogl_GetScreenResolutionX(Width, Height);{$ENDIF}
  end;

procedure CheckColor;
  begin
    if (CurrentColor<>gl_color) and (CurrentColor>=0)  and (CurrentColor<=MaxColor) then
      begin
        glColor3f(pal[CurrentColor].Red/255, pal[CurrentColor].Green/255, pal[CurrentColor].Blue/255);
        gl_color:=CurrentColor;
      end;
  end;
procedure SetLogicOp;
  begin
     case CurrentWriteMode of
       XorPut:
         Begin
           glLogicOp(GL_XOR);
         End;
       AndPut:
         Begin
           glLogicOp(GL_AND);
         End;
       OrPut:
         Begin
           glLogicOp(GL_OR);
         End;
       NotPut:
         Begin
           glLogicOp(GL_INVERT);
         End;
       else
         Begin
           glLogicOp(GL_SET);
         End;
     end;

  end;
procedure SetLineStyle;
  begin
    case LineInfo.linestyle of
      SolidLn: glLineStipple (1, $ffff);
      DottedLn: glLineStipple (1, $cccc);
      CenterLn: glLineStipple (1, $FC78);
      DashedLn: glLineStipple (1, $f8f8);
      UserBitLn: glLineStipple (1, LineInfo.pattern);
    end;
    case LineInfo.thickness of
      NormWidth: glLineWidth(1);
      ThickWidth: glLineWidth(3);
    end;
  end;

function GetPaletteEntry(r,g,b : word) : word;

  var
     dist,i,index,currentdist : longint;

  begin
     dist:=$7fffffff;
     index:=0;
     for i:=0 to maxcolors do
       begin
          currentdist:=abs(r-pal[i].red)+abs(g-pal[i].green)+
            abs(b-pal[i].blue);
          if currentdist<dist then
            begin
               index:=i;
               dist:=currentdist;
               if dist=0 then
                 break;
            end;
       end;
     GetPaletteEntry:=index;
  end;
procedure ogl_DrawFlush;
begin
  if not Doublebuffer then glFlush;
end;

procedure ogl_DirectPutPixel(X,Y: smallint);
  begin
    SetLogicOp;
    CheckColor;
    glBegin(GL_POINTS);
      glVertex2i(X, MaxY-Y);
    glEnd();
    if not Doublebuffer then glFlush;
  end;

function ogl_GetPixel(X,Y: smallint): word;
  var rgbc : array[0..2] of byte;
  begin
    glReadPixels(X, MaxY-Y, 1,1, GL_RGB, GL_UNSIGNED_BYTE, @rgbc[0]);
    ogl_GetPixel:=GetPaletteEntry(rgbc[0],rgbc[1],rgbc[2]);
  end;
procedure ogl_GetScanLine(X1, X2, Y : smallint; var data);
  type Trgb = array [0..2] of byte;
  var buf : array of Trgb;
      i : integer;
      ScanlineData : Array [0..0] Of Word ABSOLUTE Data;

  begin
    if X2<X1 then
      begin
        X2:=X1+X2;
        X1:=X2-X1;
        X2:=X2-X1;
      end;
    SetLength(buf,X2-X1+1);
    glReadPixels(X1, MaxY-Y, X2-X1+1,1, GL_RGB, GL_UNSIGNED_BYTE, @buf[0][0]);
    for i:=0 to High(buf) do
      begin
        ScanlineData[i]:=GetPaletteEntry(buf[i][0],buf[i][1],buf[i][2]);
      end;
    SetLength(buf,0);
  end;

procedure ogl_PutPixel(X,Y: smallint; Color: Word);
  begin
    x:=x+startxviewport;
    y:=y+startyviewport;
    { convert to absolute coordinates and then verify clipping...}
    if clippixels then
      begin
         if (x<startxviewport) or (x>(startxviewport+viewwidth)) or
           (y<StartyViewPort) or (y>(startyviewport+viewheight)) then
           exit;
      end;
    if (Color<>gl_color) and (Color>=0)  and (Color<=MaxColor) then
      begin
        glColor3f(pal[Color].Red/255, pal[Color].Green/255, pal[Color].Blue/255);
        gl_color:=Color;
      end;
    glBegin(GL_POINTS);
      glVertex2i(X, MaxY-Y);
    glEnd();
    if not Doublebuffer then glFlush;
  end;
procedure ogl_SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue: smallint);
  begin
//    writeln('SetRGBPalette(ColorNum, RedValue, GreenValue, BlueValue: smallint)');
//    writeln(format('ColorNum: %d, RedValue: %d, GreenValue: %d, BlueValue: %d',[ColorNum, RedValue, GreenValue, BlueValue]));
    pal[ColorNum].Red:=RedValue;
    pal[ColorNum].Green:=GreenValue;
    pal[ColorNum].Blue:=BlueValue;
//    glColor3f(pal[CurrentColor].Red/255, pal[CurrentColor].Green/255, pal[CurrentColor].Blue/255);
//    gl_color:=CurrentColor;
  end;

procedure ogl_GetRGBPalette(ColorNum: smallint; var RedValue, GreenValue, BlueValue: smallint);
  begin
    writeln('GetRGBPalette(ColorNum: smallint; var RedValue, GreenValue, BlueValue: smallint)');
    writeln(format('ColorNum: %d, RedValue: %d, GreenValue: %d, BlueValue: %d',[ColorNum, RedValue, GreenValue, BlueValue]));
  end;

procedure ogl_SetAllPalette(const Palette:PaletteType);
  begin
    writeln('SetAllPalette(const Palette:PaletteType)');
  end;
procedure ogl_SaveVideoState;
  begin
//    writeln('SaveVideoState');
  end;
procedure ogl_RestoreVideoState;
  begin
//    writeln('RestoreVideoState');
  end;


procedure ogl_ClrView;
  begin
    glViewPort(0, 0, MaxX+1, MaxY+1);
    glClearColor(pal[0].Red/255, pal[0].Green/255, pal[0].Blue/255,1.0);

    glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity;

    if Perspective then
      begin
        gluPerspective( 0.0 {угол видимости в направлении оси Y},
                        (MaxX+1) / (MaxY+1) {угол видимости в направлении оси X},
                        1.0 {расстояние от наблюдателя до ближней плоскости отсечения},
                        35.0{расстояние от наблюдателя до дальней плоскости отсечения});
        glTranslatef (0.0, 0.0, 5.0); // перенос - ось Z
        glRotatef (30.0, 1.0, 0.0, 0.0); // поворот-ось X
        glRotatef (60.0, 0.0, 1.0, 0.0); // поворот-ось Y
      end
    else
      glOrtho(0, MaxX, 0, MaxY, 0, 0.1);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

    glEnable(GL_LOGIC_OP);
    glEnable  (GL_LINE_STIPPLE);

    DrawFlush;
  end;

procedure ogl_Line(X1, Y1, X2, Y2 : smallint);
  begin
    { Convert to global coordinates. }
    x1 := x1 + StartXViewPort;
    x2 := x2 + StartXViewPort;
    y1 := y1 + StartYViewPort;
    y2 := y2 + StartYViewPort;
    { if fully clipped then exit... }
    if ClipPixels then
       if LineClipped(x1,y1,x2,y2,StartXViewPort, StartYViewPort,
          StartXViewPort+ViewWidth, StartYViewPort+ViewHeight)
       then
         exit;
    SetLogicOp;
    SetLineStyle;
    CheckColor;
    glBegin(GL_LINES);
      glVertex2i(X1, MaxY-Y1);
      glVertex2i(X2, MaxY-Y2);
    glEnd();
    DrawFlush;
  end;
procedure ogl_HLine(x, x2,y : smallint);
  begin
    ogl_Line(x,y,x2,y);
  end;
procedure ogl_VLine(x,y,y2: smallint);
  begin
    ogl_Line(x,y,x,y2);
  end;

procedure ogl_PatternLineShift(x1,x2,y,shift: smallint);
  var LineColor : word;
      Pattern : Word;
      step : word;
  begin
    glLineWidth(1);
    case FillSettings.pattern of
      EmptyFill:
        begin
          CheckColor;
          glLineStipple (1, $0000);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      SolidFill:
        begin
          CheckColor;
          glLineStipple (1, $ffff);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      LineFill:
        begin
          LineColor:=CurrentColor;
          if y mod 4 <>1 then
            CurrentColor:=0;
          CheckColor;
          CurrentColor := LineColor;
          glLineStipple (1, $ffff);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      LtSlashFill:
        begin
          CheckColor;
          Pattern:=$8080;
          step:=(y-(shift mod 16)) mod 16;
          Pattern:=(Pattern shr step) or (Pattern shl (16 - step));
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      SlashFill:
        begin
          CheckColor;
          Pattern:=$E0E0;
          step:=(y-(shift mod 16)) mod 16;
          Pattern:=(Pattern shr step) or (Pattern shl (16 - step));
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      BkSlashFill:
        begin
          CheckColor;
          Pattern:=$E0E0;
          step:=(y+(shift mod 16)) mod 16;
          Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      LtBkSlashFill:
        begin
          CheckColor;
          Pattern:=$8080;
          step:=(y+(shift mod 16)) mod 16;
          Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      HatchFill:
        begin
          CheckColor;
          if y mod 4 <> 0 then
            begin
              Pattern:=$8888;
              step:=(shift mod 16);
              Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
              glLineStipple (1, Pattern);
            end
          else
            glLineStipple (1, $ffff);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      XHatchFill:
        begin
          CheckColor;
          Pattern:=$8080;
          step:=(y+(shift mod 16)) mod 16;
          Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
          Pattern:=$8080;
          step:=(y-(shift mod 16)) mod 16;
          Pattern:=(Pattern shr step) or (Pattern shl (16 - step));
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      InterleaveFill:
        begin
          CheckColor;
          Pattern:=0;
          if y mod 4 = 0  then
              Pattern:=$CCCC
          else if y mod 4 = 2 then
              Pattern:=$3333;
          if Pattern <>0 then
            begin
              step:=(shift mod 16);
              Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
            end;
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      WideDotFill:
        begin
          CheckColor;
          Pattern:=0;
          if y mod 8 = 2  then
              Pattern:=$8000
          else if y mod 8 = 6 then
              Pattern:=$0080;
          if Pattern <>0 then
            begin
              step:=(shift mod 16);
              Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
            end;
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      CloseDotFill:
        begin
          CheckColor;
          Pattern:=0;
          if y mod 4 = 1  then
              Pattern:=$8080
          else if y mod 4 = 3 then
              Pattern:=$0808;
          if Pattern <>0 then
            begin
              step:=(shift mod 16);
              Pattern:=(Pattern shl step) or (Pattern shr (16 - step));
            end;
          glLineStipple (1, Pattern);
          glBegin(GL_LINES);
            glVertex2i(X1, MaxY-Y);
            glVertex2i(X2, MaxY-Y);
          glEnd();
        end;
      UserFill:
        begin
          //writeln('UserFill');
          PatternLineDefault(X1,X2,Y);
        end;
    end;
  end;


procedure ogl_PatternLine(x1,x2,y: smallint);
  begin
     if x1 > x2 then
           Begin
             x1 := x1+x2;
             x2 := x1-x2;
             x1 := x1-x2;
           end;
    ogl_PatternLineShift(x1,x2,y,0);
  end;

procedure ogl_Ellipse(X,Y: smallint;XRadius: word; YRadius:word; stAngle,EndAngle: word; fp: PatternLineProc);
  const n = 36;
  var t, x1,x2, y1,y2:single;
      LineColor: Word;
      TmpAngle : word;
  begin
    inc(x,StartXViewPort);
    inc(y,StartYViewPort);

   If xradius = 0 then inc(xradius);
   if yradius = 0 then inc(yradius);
   { check for an ellipse with negligable x and y radius }
   If (xradius <= 1) and (yradius <= 1) then
     begin
       putpixel(x,y,CurrentColor);
       ArcCall.X := X;
       ArcCall.Y := Y;
       ArcCall.XStart := X;
       ArcCall.YStart := Y;
       ArcCall.XEnd := X;
       ArcCall.YEnd := Y;
       exit;
     end;

   { check if valid angles }
   stAngle := stAngle mod 361;
   EndAngle := EndAngle mod 361;
   { if impossible angles then swap them! }
   if Endangle < StAngle then
     Begin
       TmpAngle:=EndAngle;
       EndAngle:=StAngle;
       Stangle:=TmpAngle;
     end;

    ArcCall.X:= X;
    ArcCall.Y:= Y;
    t := EndAngle*PI/180;
    ArcCall.XEnd:=round(XRadius * cos(t))+ X;
    ArcCall.YEnd:=-round(YRadius * sin(t)) + Y;
    t := stAngle*PI/180;
    ArcCall.XStart:=round(XRadius * cos(t))+ X;
    ArcCall.YStart:=-round(YRadius * sin(t)) + Y;

    if fp<>@DummyPatternLine then
      case FillSettings.pattern of
        EmptyFill:
          begin
            LineColor:=CurrentColor;
            CurrentColor:=CurrentBkColor;
            CheckColor;
            CurrentColor := LineColor;
            glBegin(GL_TRIANGLE_FAN);
            glVertex2f( X, MaxY - Y);
            t := stAngle*PI/180;
            while t <= EndAngle*PI/180 do
              begin
                glVertex2f(XRadius * cos(t) + X,  YRadius * sin(t) + MaxY - Y);
                t := t + PI/n
              end;
            glEnd();
           end;
        SolidFill:
          begin
            LineColor:=CurrentColor;
            CurrentColor:=FillSettings.color;
            CheckColor;
            CurrentColor := LineColor;
            glBegin(GL_TRIANGLE_FAN);
            glVertex2f( X, MaxY - Y);
            t := stAngle*PI/180;
            while t <= EndAngle*PI/180 do
              begin
                glVertex2f(XRadius * cos(t) + X,  YRadius * sin(t) + MaxY - Y);
                t := t + PI/n
              end;
            glEnd();
           end;
        LineFill,
        LtSlashFill,
        SlashFill,
        BkSlashFill,
        LtBkSlashFill,
        HatchFill,
        XHatchFill,
        InterleaveFill,
        WideDotFill,
        CloseDotFill,
        UserFill:
          begin
            LineColor:=CurrentColor;
            CurrentColor:=FillSettings.color;
            CheckColor;
            
            y1:=-YRadius;
            y2:=YRadius;

            if (EndAngle-stAngle<=270) then
              if (ArcCall.YStart-Y>=0) and (ArcCall.YEnd-Y>=0) then
                y1:=0
              else
                if (ArcCall.YStart-Y<=0) and (ArcCall.YEnd-Y<=0) then
                  y2:=0
                else
                  if (ArcCall.YEnd-Y>=0) then
                    y2:=(ArcCall.YEnd-Y)
                  else
                    if (ArcCall.YStart-Y<=0) then
                      y1:=(ArcCall.YStart-Y);

            t:=y1;
            while t<=y2 do
              begin
                // вычисляем крайние точки элипса
                x1:=-abs(XRadius*cos(ArcSin(t/YRadius)));
                x2:=-x1;
                // вычисляем границы внутреннего сектора                
                if (EndAngle-stAngle>=180) and 
                   (((t<=0) and (ArcCall.YStart-Y>=0) and (ArcCall.YEnd-Y>=0)) or
                   ((t>0) and (ArcCall.YStart-Y<=0) and (ArcCall.YEnd-Y<=0))) then
                    // Вырез находится в другой половине элипса
                    ogl_PatternLineShift(round(x1+X), round(x2+X), round(t+Y), round(XRadius-x1))
                else
                  begin
                    if (t<=0) and (stAngle>0) and (stAngle<180) and (ArcCall.YStart-Y <=t) then
                        if stAngle=90 then
                            x2:=0
                        else
                            x2:= -t/Tan(stAngle*PI/180);
                    if (t>=0) and (stAngle>180) and (stAngle<360) and (ArcCall.YStart-Y >=t) then
                        if stAngle=270 then
                            x1:=0
                        else
                            x1:= -t/Tan(stAngle*PI/180);
                    if (t<=0) and (EndAngle>1) and (EndAngle<180) and (ArcCall.YEnd-Y <=t) then
                        if EndAngle=90 then
                            x1:=0
                        else
                            x1:= -t/Tan(EndAngle*PI/180);
                    if (t>=0) and (EndAngle>180) and (EndAngle<360) and (ArcCall.YEnd-Y >=t) then
                        if EndAngle=270 then
                            x2:=0
                        else
                            x2:=-t/Tan(EndAngle*PI/180);
                    ogl_PatternLineShift(round(x1+X), round(x2+X), round(t+Y), round(XRadius-x1))
                  end;
                t:=t+1;
              end;
            CurrentColor := LineColor;
          end;
      end;

    CheckColor;
    SetLogicOp;
    SetLineStyle;


    glLineStipple (1, $ffff);
    glBegin(GL_LINE_STRIP);
    t := stAngle*PI/180;
    while t <= EndAngle*PI/180 do
      begin
        glVertex2f(XRadius * cos(t) + X, YRadius * sin(t) + MaxY - Y);
        t := t+ PI/n
      end;
    t:= EndAngle*PI/180;
    glVertex2f(XRadius * cos(t) + X, YRadius * sin(t) + MaxY - Y);
    glEnd();
    DrawFlush;

  end;

procedure ogl_Circle(X, Y: smallint; Radius:Word);
  const n = 100;
  var t:single;
  begin
    inc(x,StartXViewPort);
    inc(y,StartYViewPort);
    CheckColor;
    SetLogicOp;
    SetLineStyle;
    glBegin(GL_LINE_LOOP);
    t := 0;
    while t <= 2*PI do
      begin
        glVertex2f(Radius * cos(t) + X, MaxY - (Radius * sin(t) + Y));
        t := t+ PI/n
      end;
    glEnd();
    DrawFlush;
  end;

procedure ogl_OutTextXY(X, Y: smallint; const text : string);
var oldDoubleBuffer : boolean;
    s : AnsiString;
    convres : integer;
begin
    oldDoubleBuffer:=DoubleBuffer;
    DoubleBuffer:=true;
    {$if defined(unix)}
	convres:=Iconvert(text,s,InputEncoding,OutputEncoding);
	if convres<>0  then
	{$endif}
		s:=text;
    OutTextXYDefault(X, Y, s);
    DoubleBuffer:=oldDoubleBuffer;
    if not Doublebuffer then glFlush;
end;

procedure ogl_PutImage(X,Y: smallint; var Bitmap; BitBlt: Word);
var oldDoubleBuffer : boolean;
begin
    oldDoubleBuffer:=DoubleBuffer;
    DoubleBuffer:=true;
    DefaultPutImage(X, Y, Bitmap, BitBlt);
    DoubleBuffer:=oldDoubleBuffer;
    DrawFlush;
end;

procedure ogl_InitMode;
  begin
//    writeln('InitMode');
    if graphInited then
      _graphResult:=grError
    else
      begin
        SetLength(pal,maxcolor);
        move(DefaultColors,pal[0],sizeof(RGBrec)*maxcolor);
        keycode:=-1;

        {$IFDEF WIN32}ogl_InitModeWin32;{$ENDIF}
        {$IFDEF UNIX}ogl_InitModeX;{$ENDIF}

        glReadBuffer(GL_FRONT);
        if not DoubleBuffer then
          glDrawBuffer(GL_FRONT);

        ogl_ClrView;
        graphInited:=true;
      end;
  end;



function queryadapterinfo : pmodeinfo;
  var
     mode: TModeInfo;
     ScreenWidth, ScreenHeight : Word;

    procedure DefaultModeParams;
      begin
        with mode do
          begin
            { necessary hooks ... }
            DirectPutPixel := @ogl_DirectPutPixel;
            GetPixel       := @ogl_GetPixel;
            PutPixel       := @ogl_PutPixel;
            SetRGBPalette  := @ogl_SetRGBPalette;
            GetRGBPalette  := @ogl_GetRGBPalette;
            SetAllPalette  := @ogl_SetAllPalette;
            { defaults possible ... }
    //        SetVisualPage  : SetVisualPageProc;
    //        SetActivePage  : SetActivePageProc;
            ClearViewPort  := @ogl_ClrView;
    //        PutImage       : PutImageProc;
    //        GetImage       : GetImageProc;
    //        ImageSize      : ImageSizeProc;
            GetScanLine    := @ogl_GetScanLine;
            Line           := @ogl_Line;
            InternalEllipse:= @ogl_Ellipse;
            PatternLine    := @ogl_PatternLine;
            HLine          := @ogl_HLine;
            VLine          := @ogl_VLine;
            Circle         := @ogl_Circle;

            InitMode       := @ogl_InitMode;
            OutTextXY      := @ogl_OutTextXY;
            DrawFlush      := @ogl_DrawFlush;
          end;
      end;{DefaultModeParams}

  begin
    SaveVideoState:=@ogl_SaveVideoState;
    RestoreVideoState:=@ogl_RestoreVideoState;
    QueryAdapterInfo := ModeList;
    if assigned(ModeList) then
      exit;
    GetScreenResolution(ScreenWidth, ScreenHeight);
     if (ScreenWidth>640) and (ScreenHeight>480) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VGA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=VGAHi;
          mode.ModeName:='640 x 480 x 16';
          mode.MaxColor := 16;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 639;
          mode.MaxY := 479;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     if (ScreenWidth>640) and (ScreenHeight>200) then
       begin
          InitMode(mode);
          { now add all standard VGA modes...       }
          mode.DriverNumber:= VGA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=VGALo;
          mode.ModeName:='640 x 200 x 16';
          mode.MaxColor := 16;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 639;
          mode.MaxY := 199;
          DefaultModeParams;
          mode.XAspect := 4500;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     if (ScreenWidth>640) and (ScreenHeight>350) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VGA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=VGAMed;
          mode.ModeName:='640 x 350 x 16';
          mode.MaxColor := 16;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 639;
          mode.MaxY := 349;
          DefaultModeParams;
          mode.XAspect := 7750;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     if (ScreenWidth>640) and (ScreenHeight>400) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m640x400x256;
          mode.ModeName:='640 x 400 x 256';
          mode.MaxColor := 256;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 639;
          mode.MaxY := 399;
          DefaultModeParams;
          mode.XAspect := 8333;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     if (ScreenWidth>640) and (ScreenHeight>480) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m640x480x256;
          mode.ModeName:='640 x 480 x 256';
          mode.MaxColor := 256;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 639;
          mode.MaxY := 479;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     { add 800x600 only if screen is large enough }
     If (ScreenWidth>800) and (ScreenHeight>600) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m800x600x16;
          mode.ModeName:='800 x 600 x 16';
          mode.MaxColor := 16;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 799;
          mode.MaxY := 599;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);
          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m800x600x256;
          mode.ModeName:='800 x 600 x 256';
          mode.MaxColor := 256;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 799;
          mode.MaxY := 599;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     { add 1024x768 only if screen is large enough }
     If (ScreenWidth>1024) and (ScreenHeight>768) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m1024x768x16;
          mode.ModeName:='1024 x 768 x 16';
          mode.MaxColor := 16;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 1023;
          mode.MaxY := 767;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);

          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m1024x768x256;
          mode.ModeName:='1024 x 768 x 256';
          mode.MaxColor := 256;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 1023;
          mode.MaxY := 767;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);
       end;
     { add 1280x1024 only if screen is large enough }
     If (ScreenWidth>1280) and (ScreenHeight>1024) then
       begin
          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m1280x1024x16;
          mode.ModeName:='1280 x 1024 x 16';
          mode.MaxColor := 16;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 1279;
          mode.MaxY := 1023;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);

          InitMode(mode);
          mode.DriverNumber:= VESA;
          mode.HardwarePages:= 0;
          mode.ModeNumber:=m1280x1024x256;
          mode.ModeName:='1280 x 1024 x 256';
          mode.MaxColor := 256;
          mode.PaletteSize := mode.MaxColor;
          mode.DirectColor := FALSE;
          mode.MaxX := 1279;
          mode.MaxY := 1023;
          DefaultModeParams;
          mode.XAspect := 10000;
          mode.YAspect := 10000;
          AddMode(mode);
       end;

 end;

Procedure CloseGraph;
  begin
//    writeln('CloseGraph');
    if graphInited then
      begin
        {$IFDEF WIN32}ogl_CloseGraphWin32;{$ENDIF}
        {$IFDEF UNIX }ogl_CloseGraphX;{$ENDIF}
        setLength(pal,0);
        graphInited:=false;
      end;
  end;

  var s : string;
initialization
  {$IFDEF UNIX}
  {$IFDEF LOADDYNAMIC}
  if not InitIconv(s) then
    begin
      Writeln('Iconv initialization failed:',s);
      halt;
    end ;
  {$ENDIF}
  {$ENDIF}

  InitializeGraph;
  {$IFDEF WIN32}
   charmessagehandler:=@msghandler;
   nextfree:=1;
   nexttoread:=1;
   InitializeCriticalSection(keyboardhandling);
   oldexitproc:=exitproc;
   exitproc:=@myexitproc;
   lastmode:=0;
  {$ENDIF}
  
  
finalization
  setLength(pal,0);
end.
