# Haskell-Webview2
## Create HTML User Interface using WinWebV2 in Haskell

<br><br>

Windows  
Webview2 Runtime (required)  
https://developer.microsoft.com/en-us/microsoft-edge/webview2/#download-section  

<br><br><br><br><br><br>

<pre>
chcp 65001
stack ghc -- -Lapp -lWebV2dll app\Main.hs  
app\Main.exe
</pre>

or

<br><br>

<pre>
chcp 65001
stack build
</pre>
copy  
app/WebView2Loader.dll  
app/WebV2dll.dll
app/html  
<br><br><br><br><br><br><br><br><br>






# WebV2dll
VC++  
https://github.com/kxkx5150/WebV2dll
## API

<pre>

bool create_webview2(HWND hWnd, int createid, const TCHAR* url);

HWND get_main_hwnd(int createid);
void close_window(HWND hWnd);
void resize_webview(HWND hWnd);
void load_url(HWND hWnd, const TCHAR* url);
void reload_page(HWND hWnd);

void set_global_startup_script(const TCHAR* script);
void set_startup_script(HWND hWnd, const TCHAR* script);
void exec_js(HWND hWnd, const TCHAR* script);
void send_json(HWND hWnd, const TCHAR* jsonstr);

LPTSTR get_msg_string(LPARAM lp);

</pre>