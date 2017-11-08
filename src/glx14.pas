{

  Translation of the Mesa GLX headers for FreePascal
  Copyright (C) 1999 Sebastian Guenther

  Mesa 3-D graphics library
  Version:  6.5
  
  Copyright (C) 1999-2006  Brian Paul   All Rights Reserved.
  
  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom the
  Software is furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
  BRIAN PAUL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

}

{$MODE delphi}  // objfpc would not work because of direct proc var assignments

{You have to enable Macros (compiler switch "-Sm") for compiling this unit!
 This is necessary for supporting different platforms with different calling
 conventions via a single unit.}

unit GLX14;

interface

{$MACRO ON}

{$IFDEF Unix}
  uses
    X, XLib, XUtil;
  {$DEFINE HasGLX}  // Activate GLX stuff
{$ELSE}
  {$MESSAGE Unsupported platform.}
{$ENDIF}

{$IFNDEF HasGLX}
  {$MESSAGE GLX not present on this platform.}
{$ENDIF}


// =======================================================
//   Unit specific extensions
// =======================================================

// Note: Requires that the GL library has already been initialized
function InitGLX: Boolean;

var
  GLXDumpUnresolvedFunctions,
  GLXInitialized: Boolean;


// =======================================================
//   GLX consts, types and functions
// =======================================================

// Tokens for glXChooseVisual and glXGetConfig:
const
  GLX_GL_NONE                           = 0;
  GLX_USE_GL                            = 1;
  GLX_BUFFER_SIZE                       = 2;
  GLX_LEVEL                             = 3;
  GLX_RGBA                              = 4;
  GLX_DOUBLEBUFFER                      = 5;
  GLX_STEREO                            = 6;
  GLX_AUX_BUFFERS                       = 7;
  GLX_RED_SIZE                          = 8;
  GLX_GREEN_SIZE                        = 9;
  GLX_BLUE_SIZE                         = 10;
  GLX_ALPHA_SIZE                        = 11;
  GLX_DEPTH_SIZE                        = 12;
  GLX_STENCIL_SIZE                      = 13;
  GLX_ACCUM_RED_SIZE                    = 14;
  GLX_ACCUM_GREEN_SIZE                  = 15;
  GLX_ACCUM_BLUE_SIZE                   = 16;
  GLX_ACCUM_ALPHA_SIZE                  = 17;

  // GLX_EXT_visual_info extension
  GLX_X_VISUAL_TYPE_EXT                 = $22;
  GLX_TRANSPARENT_TYPE_EXT              = $23;
  GLX_TRANSPARENT_INDEX_VALUE_EXT       = $24;
  GLX_TRANSPARENT_RED_VALUE_EXT         = $25;
  GLX_TRANSPARENT_GREEN_VALUE_EXT       = $26;
  GLX_TRANSPARENT_BLUE_VALUE_EXT        = $27;
  GLX_TRANSPARENT_ALPHA_VALUE_EXT       = $28;


  // Error codes returned by glXGetConfig:
  GLX_BAD_SCREEN                        = 1;
  GLX_BAD_ATTRIBUTE                     = 2;
  GLX_NO_EXTENSION                      = 3;
  GLX_BAD_VISUAL                        = 4;
  GLX_BAD_CONTEXT                       = 5;
  GLX_BAD_VALUE                         = 6;
  GLX_BAD_ENUM                          = 7;

  // GLX 1.1 and later:
  GLX_VENDOR                            = 1;
  GLX_VERSION                           = 2;
  GLX_EXTENSIONS                        = 3;

  // GLX 1.3 and later:
  GLX_CONFIG_CAVEAT = $20;     
  GLX_DONT_CARE = $FFFFFFFF;     
  GLX_X_VISUAL_TYPE = $22;     
  GLX_TRANSPARENT_TYPE = $23;     
  GLX_TRANSPARENT_INDEX_VALUE = $24;     
  GLX_TRANSPARENT_RED_VALUE = $25;     
  GLX_TRANSPARENT_GREEN_VALUE = $26;     
  GLX_TRANSPARENT_BLUE_VALUE = $27;     
  GLX_TRANSPARENT_ALPHA_VALUE = $28;     
  GLX_WINDOW_BIT = $00000001;     
  GLX_PIXMAP_BIT = $00000002;     
  GLX_PBUFFER_BIT = $00000004;     
  GLX_AUX_BUFFERS_BIT = $00000010;     
  GLX_FRONT_LEFT_BUFFER_BIT = $00000001;     
  GLX_FRONT_RIGHT_BUFFER_BIT = $00000002;     
  GLX_BACK_LEFT_BUFFER_BIT = $00000004;     
  GLX_BACK_RIGHT_BUFFER_BIT = $00000008;     
  GLX_DEPTH_BUFFER_BIT = $00000020;     
  GLX_STENCIL_BUFFER_BIT = $00000040;     
  GLX_ACCUM_BUFFER_BIT = $00000080;     
  GLX_NONE = $8000;     
  GLX_SLOW_CONFIG = $8001;     
  GLX_TRUE_COLOR = $8002;     
  GLX_DIRECT_COLOR = $8003;     
  GLX_PSEUDO_COLOR = $8004;     
  GLX_STATIC_COLOR = $8005;     
  GLX_GRAY_SCALE = $8006;     
  GLX_STATIC_GRAY = $8007;     
  GLX_TRANSPARENT_RGB = $8008;     
  GLX_TRANSPARENT_INDEX = $8009;     
  GLX_VISUAL_ID = $800B;     
  GLX_SCREEN = $800C;     
  GLX_NON_CONFORMANT_CONFIG = $800D;     
  GLX_DRAWABLE_TYPE = $8010;     
  GLX_RENDER_TYPE = $8011;     
  GLX_X_RENDERABLE = $8012;     
  GLX_FBCONFIG_ID = $8013;     
  GLX_RGBA_TYPE = $8014;     
  GLX_COLOR_INDEX_TYPE = $8015;     
  GLX_MAX_PBUFFER_WIDTH = $8016;     
  GLX_MAX_PBUFFER_HEIGHT = $8017;     
  GLX_MAX_PBUFFER_PIXELS = $8018;     
  GLX_PRESERVED_CONTENTS = $801B;     
  GLX_LARGEST_PBUFFER = $801C;     
  GLX_WIDTH = $801D;     
  GLX_HEIGHT = $801E;     
  GLX_EVENT_MASK = $801F;     
  GLX_DAMAGED = $8020;     
  GLX_SAVED = $8021;     
  GLX_WINDOW = $8022;     
  GLX_PBUFFER = $8023;     
  GLX_PBUFFER_HEIGHT = $8040;     
  GLX_PBUFFER_WIDTH = $8041;     
  GLX_RGBA_BIT = $00000001;     
  GLX_COLOR_INDEX_BIT = $00000002;     
  GLX_PBUFFER_CLOBBER_MASK = $08000000;     

  // GLX 1.4 and later:
  GLX_SAMPLE_BUFFERS = $186a0;     
  GLX_SAMPLES = $186a1;     


  // GLX_visual_info extension
  GLX_TRUE_COLOR_EXT                    = $8002;
  GLX_DIRECT_COLOR_EXT                  = $8003;
  GLX_PSEUDO_COLOR_EXT                  = $8004;
  GLX_STATIC_COLOR_EXT                  = $8005;
  GLX_GRAY_SCALE_EXT                    = $8006;
  GLX_STATIC_GRAY_EXT                   = $8007;
  GLX_NONE_EXT                          = $8000;
  GLX_TRANSPARENT_RGB_EXT               = $8008;
  GLX_TRANSPARENT_INDEX_EXT             = $8009;

type
  // From XLib:
  XPixmap = TXID;
  XFont = TXID;
  XColormap = TXID;

  GLXContext = Pointer;
  GLXPixmap = TXID;
  GLXDrawable = TXID;
  GLXContextID = TXID;
  
  TXPixmap = XPixmap;
  TXFont = XFont;
  TXColormap = XColormap;

  TGLXContext = GLXContext;
  TGLXPixmap = GLXPixmap;
  TGLXDrawable = GLXDrawable;
  TGLXContextID = GLXContextID;

  //From GLX
  //GLX 1.3 and later
  GLXFBConfig = pointer;
  GLXFBConfigID = TXID;
  GLXWindow = TXID;
  GLXPbuffer = TXID;

  PGLXFBConfig = ^ GLXFBConfig;
  
  TGdkGLContextPrivate = record
    xdisplay: PDisplay;
    glxcontext: TGLXContext;
    ref_count: {gint}integer;
  end;
  PGdkGLContextPrivate = ^TGdkGLContextPrivate;


var
  glXChooseVisual: function(dpy: PDisplay; screen: Integer; attribList: PInteger): PXVisualInfo; cdecl;
  glXCreateContext: function(dpy: PDisplay; vis: PXVisualInfo; shareList: GLXContext; direct: Boolean): GLXContext; cdecl;
  glXDestroyContext: procedure(dpy: PDisplay; ctx: GLXContext); cdecl;
  glXMakeCurrent: function(dpy: PDisplay; drawable: GLXDrawable; ctx: GLXContext): Boolean; cdecl;
  glXCopyContext: procedure(dpy: PDisplay; src, dst: GLXContext; mask: LongWord); cdecl;
  glXSwapBuffers: procedure(dpy: PDisplay; drawable: GLXDrawable); cdecl;
  glXCreateGLXPixmap: function(dpy: PDisplay; visual: PXVisualInfo; pixmap: XPixmap): GLXPixmap; cdecl;
  glXDestroyGLXPixmap: procedure(dpy: PDisplay; pixmap: GLXPixmap); cdecl;
  glXQueryExtension: function(dpy: PDisplay; var errorb, event: Integer): Boolean; cdecl;
  glXQueryVersion: function(dpy: PDisplay; var maj, min: Integer): Boolean; cdecl;
  glXIsDirect: function(dpy: PDisplay; ctx: GLXContext): Boolean; cdecl;
  glXGetConfig: function(dpy: PDisplay; visual: PXVisualInfo; attrib: Integer; var value: Integer): Integer; cdecl;
  glXGetCurrentContext: function: GLXContext; cdecl;
  glXGetCurrentDrawable: function: GLXDrawable; cdecl;
  glXWaitGL: procedure; cdecl;
  glXWaitX: procedure; cdecl;
  glXUseXFont: procedure(font: XFont; first, count, list: Integer); cdecl;

  // GLX 1.1 and later
  glXQueryExtensionsString: function(dpy: PDisplay; screen: Integer): PChar; cdecl;
  glXQueryServerString: function(dpy: PDisplay; screen, name: Integer): PChar; cdecl;
  glXGetClientString: function(dpy: PDisplay; name: Integer): PChar; cdecl;

  // GLX 1.2 and later
  glXGetCurrentDisplay : function(): PDisplay;cdecl;

  //GLX 1.3 and later
  glXChooseFBConfig : function (dpy:PDisplay; screen:longint; attribList:PLongInt; var nitems:longint):PGLXFBConfig;cdecl;
  glXGetFBConfigAttrib : function (dpy:PDisplay; config:GLXFBConfig; attribute:longint; var value:longint):longint;cdecl;
  glXGetFBConfigs : function (dpy:PDisplay; screen:longint; var nelements:longint):PGLXFBConfig;cdecl;
  glXGetVisualFromFBConfig : function (dpy:PDisplay; config:GLXFBConfig):PXVisualInfo;cdecl;
  glXCreateWindow : function (dpy:PDisplay; config:GLXFBConfig; win:TWindow; attribList:Plongint):GLXWindow;cdecl;
  glXDestroyWindow : procedure (dpy:PDisplay; window:GLXWindow);cdecl;
  glXCreatePixmap : function (dpy:PDisplay; config:GLXFBConfig; pixmap:TPixmap; attribList:Plongint):TGLXPixmap;cdecl;
  glXDestroyPixmap : procedure (dpy:PDisplay; pixmap:TGLXPixmap);cdecl;
  glXCreatePbuffer : function (dpy:PDisplay; config:GLXFBConfig; attribList:Plongint):GLXPbuffer;cdecl;
  glXDestroyPbuffer : procedure (dpy:PDisplay; pbuf:GLXPbuffer);cdecl;
  glXQueryDrawable : procedure (dpy:PDisplay; draw:GLXDrawable; attribute:longint; value:Pdword);cdecl;

  glXCreateNewContext : function (dpy:PDisplay; config:GLXFBConfig; renderType:longint; shareList:GLXContext; direct:boolean):GLXContext;cdecl;
  glXMakeContextCurrent : function (dpy:PDisplay; draw:GLXDrawable; read:GLXDrawable; ctx:GLXContext):boolean;cdecl;
  glXGetCurrentReadDrawable : function :GLXDrawable;cdecl;
  glXQueryContext : function (dpy:PDisplay; ctx:GLXContext; attribute:longint; var value:longint):longint;cdecl;
  glXSelectEvent : procedure (dpy:PDisplay; drawable:GLXDrawable; mask:dword);cdecl;
  glXGetSelectedEvent : procedure (dpy:PDisplay; drawable:GLXDrawable; var mask:dword);cdecl;


  // Mesa GLX Extensions
  glXCreateGLXPixmapMESA: function(dpy: PDisplay; visual: PXVisualInfo; pixmap: XPixmap; cmap: XColormap): GLXPixmap; cdecl;
  glXReleaseBufferMESA: function(dpy: PDisplay; d: GLXDrawable): Boolean; cdecl;
  glXCopySubBufferMESA: procedure(dpy: PDisplay; drawbale: GLXDrawable; x, y, width, height: Integer); cdecl;
  glXGetVideoSyncSGI: function(var counter: LongWord): Integer; cdecl;
  glXWaitVideoSyncSGI: function(divisor, remainder: Integer; var count: LongWord): Integer; cdecl;


// =======================================================
//
// =======================================================

implementation

uses GL, dynlibs;

{$LINKLIB m}

function GetProc(handle: PtrInt; name: PChar): Pointer;
begin
  Result := GetProcAddress(handle, name);
  if (Result = nil) and GLXDumpUnresolvedFunctions then
    WriteLn('Unresolved: ', name);
end;

function InitGLX: Boolean;
var
  OurLibGL: TLibHandle;
begin
  Result := False;

{$ifndef darwin}
  OurLibGL := libGl;
{$else darwin}
  OurLibGL := LoadLibrary('/usr/X11R6/lib/libGL.dylib');
{$endif darwin}

  if OurLibGL = 0 then
    exit;

  glXChooseVisual := GetProc(OurLibGL, 'glXChooseVisual');
  glXCreateContext := GetProc(OurLibGL, 'glXCreateContext');
  glXDestroyContext := GetProc(OurLibGL, 'glXDestroyContext');
  glXMakeCurrent := GetProc(OurLibGL, 'glXMakeCurrent');
  glXCopyContext := GetProc(OurLibGL, 'glXCopyContext');
  glXSwapBuffers := GetProc(OurLibGL, 'glXSwapBuffers');
  glXCreateGLXPixmap := GetProc(OurLibGL, 'glXCreateGLXPixmap');
  glXDestroyGLXPixmap := GetProc(OurLibGL, 'glXDestroyGLXPixmap');
  glXQueryExtension := GetProc(OurLibGL, 'glXQueryExtension');
  glXQueryVersion := GetProc(OurLibGL, 'glXQueryVersion');
  glXIsDirect := GetProc(OurLibGL, 'glXIsDirect');
  glXGetConfig := GetProc(OurLibGL, 'glXGetConfig');
  glXGetCurrentContext := GetProc(OurLibGL, 'glXGetCurrentContext');
  glXGetCurrentDrawable := GetProc(OurLibGL, 'glXGetCurrentDrawable');
  glXWaitGL := GetProc(OurLibGL, 'glXWaitGL');
  glXWaitX := GetProc(OurLibGL, 'glXWaitX');
  glXUseXFont := GetProc(OurLibGL, 'glXUseXFont');
  // GLX 1.1 and later
  glXQueryExtensionsString := GetProc(OurLibGL, 'glXQueryExtensionsString');
  glXQueryServerString := GetProc(OurLibGL, 'glXQueryServerString');
  glXGetClientString := GetProc(OurLibGL, 'glXGetClientString');
  // Mesa GLX Extensions
  glXCreateGLXPixmapMESA := GetProc(OurLibGL, 'glXCreateGLXPixmapMESA');
  glXReleaseBufferMESA := GetProc(OurLibGL, 'glXReleaseBufferMESA');
  glXCopySubBufferMESA := GetProc(OurLibGL, 'glXCopySubBufferMESA');
  glXGetVideoSyncSGI := GetProc(OurLibGL, 'glXGetVideoSyncSGI');
  glXWaitVideoSyncSGI := GetProc(OurLibGL, 'glXWaitVideoSyncSGI');



  // GLX 1.2 and later
  glXGetCurrentDisplay := GetProc(OurLibGL, 'glXGetCurrentDisplay');

  //GLX 1.3 and later
  glXChooseFBConfig := GetProc(OurLibGL, 'glXChooseFBConfig');
  glXGetFBConfigAttrib := GetProc(OurLibGL, 'glXGetFBConfigAttrib');
  glXGetFBConfigs := GetProc(OurLibGL, 'glXGetFBConfigs');
  glXGetVisualFromFBConfig := GetProc(OurLibGL, 'glXGetVisualFromFBConfig');
  glXCreateWindow := GetProc(OurLibGL, 'glXCreateWindow');
  glXDestroyWindow := GetProc(OurLibGL, 'glXDestroyWindow');
  glXCreatePixmap := GetProc(OurLibGL, 'glXCreatePixmap');
  glXDestroyPixmap := GetProc(OurLibGL, 'glXDestroyPixmap');
  glXCreatePbuffer := GetProc(OurLibGL, 'glXCreatePbuffer');
  glXDestroyPbuffer := GetProc(OurLibGL, 'glXDestroyPbuffer');
  glXQueryDrawable := GetProc(OurLibGL, 'glXQueryDrawable');
  glXCreateNewContext := GetProc(OurLibGL, 'glXCreateNewContext');
  glXMakeContextCurrent := GetProc(OurLibGL, 'glXMakeContextCurrent');
  glXGetCurrentReadDrawable := GetProc(OurLibGL, 'glXGetCurrentReadDrawable');
  glXQueryContext := GetProc(OurLibGL, 'glXQueryContext');
  glXSelectEvent := GetProc(OurLibGL, 'glXSelectEvent');
  glXGetSelectedEvent := GetProc(OurLibGL, 'glXGetSelectedEvent');


  GLXInitialized := True;
  Result := True;
end;

initialization
  InitGLX;
end.
