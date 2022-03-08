{-# LANGUAGE ForeignFunctionInterface #-}


module Main where
import Lib

import System.Win32.DLL (getModuleHandle)
import Graphics.Win32
import System.Win32.Types
import Graphics.Win32.Message
import Graphics.Win32.Window
import Data.Int
import Data.Maybe
import Control.Monad
import Foreign.C.String
import Foreign
import Foreign.C
import Foreign.Marshal.Alloc
import Foreign.Marshal.Array
import System.Environment
import System.Environment.FindBin
wMJSMSG = wM_APP + 1
mAINwINDOWID = 0


foreign import stdcall "create_webview2" 
  win32_create_webview2 :: HWND -> Int -> LPTSTR -> IO Bool
foreign import stdcall "get_main_hwnd" 
  win32_get_main_hwnd :: Int -> IO HWND
foreign import stdcall "close_window" 
  win32_close_window :: HWND -> IO ()
foreign import stdcall "resize_webview" 
  win32_resize_webview :: HWND -> IO ()
foreign import stdcall "load_url" 
  win32_load_url :: HWND -> LPTSTR -> IO ()
foreign import stdcall "reload_page" 
  win32_reload_page :: HWND -> IO ()

foreign import stdcall "set_global_startup_script" 
  win32_set_global_startup_script :: LPTSTR -> IO ()
foreign import stdcall "set_startup_script" 
  win32_set_startup_script :: HWND -> LPTSTR -> IO ()
foreign import stdcall "exec_js" 
  win32_exec_js :: HWND -> LPTSTR -> IO ()
foreign import stdcall "send_json" 
  win32_send_json :: HWND -> LPTSTR -> IO ()

foreign import stdcall "get_msg_string" 
  win32_get_msg_string :: LPARAM -> IO LPTSTR


main = do
  hwnd <- createMainWindow
  statWebView hwnd
  hdc <- getDC (Just hwnd)
  allocaMessage pump


createMainWindow = do
  let clsName = mkClassName "Haskell_Window_Class"
  hinst       <- getModuleHandle Nothing
  whiteBrush  <- getStockBrush wHITE_BRUSH
  curArrow    <- loadCursor Nothing iDC_ARROW
  mAtom       <- registerClass (
      cS_OWNDC, --cS_DBLCLKS,
      hinst,          -- HINSTANCE
      Nothing,        -- Maybe HICON
      Just curArrow,  -- Maybe HCURSOR
      Just whiteBrush,-- Maybe HBRUSH
      Nothing,        -- Maybe LPCTSTR
      clsName)
  hwnd <- createWindow
      clsName
      ""
      (wS_THICKFRAME + wS_CAPTION + wS_SYSMENU)
      Nothing
      Nothing
      (Just 600)
      (Just 400)
      Nothing
      Nothing
      hinst
      wndProc
  showWindow hwnd sW_SHOWNORMAL
  return hwnd


pump lpmsg = do
  fContinue <- getMessage lpmsg Nothing
  when fContinue $ do
    translateMessage lpmsg
    dispatchMessage lpmsg
    pump lpmsg


wndProc
  :: HWND
  -> WindowMessage
  -> WPARAM
  -> LPARAM
  -> IO LRESULT
wndProc hwnd wm wp lp

  | wm == wM_DESTROY     = postQuitMessage 0 >> return 0
  | wm == wM_PAINT       = onPaint
  | wm == wMJSMSG       = onMSG
  | otherwise            = defWindowProc (Just hwnd) wm wp lp
  where
    doFinish = sendMessage hwnd wM_CLOSE 1 0 >> return 0
    onMSG    = onMessage hwnd lp >> return 0
    onPaint  = allocaPAINTSTRUCT $ \ lpps -> do      
      hdc <- beginPaint hwnd lpps
      endPaint hwnd lpps
      return 0


onMessage hwnd lp = do
  c_msg <- win32_get_msg_string lp
  msg <- peekTString c_msg
  print msg
  win32_exec_js hwnd (mkClassName "alert('Haskell: I Like JavaScript!');")
  win32_send_json hwnd (mkClassName "{\"msg\" : \"change_green_bgcolor\"}")
  return 0


statWebView hwnd = do
  cwd <- getProgPath
  -- win32_create_webview2 hwnd 0 (mkClassName "https://www.google.co.jp")
  win32_create_webview2 hwnd mAINwINDOWID (mkClassName (cwd ++ "\\html\\index.html"))
  -- win32_set_global_startup_script (mkClassName "alert('JavaScript: I Like Haskell!');")
  win32_set_startup_script hwnd (mkClassName "alert('JavaScript: I Like Haskell!');")
  
