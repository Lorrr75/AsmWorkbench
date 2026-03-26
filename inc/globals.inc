;
; File delle variabili globali usate in tutti i punti necessari al funzionamento del programma
;

.data?

; Finestra principale
g_hMainWnd		HWND ?			; handle della finestra principale
hInstance    		HINSTANCE ?		; istanza del programma principale
CommandLine  		LPSTR ?			; puntatore alla linea di comando del programma
g_hStatusBar		HWND ?			; handle della status bar

; TabBar
g_hTabBar		HWND ?			; handle della TabBar
g_nTabCount		dd ?			; numero di tab attualmente aperte
g_nActiveTab		dd ?			; indice tab attiva


.data
g_TabItems		TABITEM MAX_TABS dup (<>)	; array di tutte le tab