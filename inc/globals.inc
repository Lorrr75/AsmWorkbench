;
; File delle variabili globali usate in tutti i punti necessari al funzionamento del programma
;

.data?

; Finestra principale
g_hMainWnd		HWND ?			; handle della finestra principale
hInstance    		HINSTANCE ?		; istanza del programma principale
CommandLine  		LPSTR ?			; puntatore alla linea di comando del programma
g_hStatusBar		HWND ?			; handle della status bar
g_hAccel		HANDLE ?		; handle acceleratori da tastiera

; TabBar
g_hTabBar		HWND ?			; handle della TabBar
g_nTabCount		dd ?			; numero di tab attualmente aperte
g_nActiveTab		dd ?			; indice tab attiva

; Editor
g_hEditor		HWND ?			; handle della finestra di edit
g_hMsftedit		HANDLE ?		; handle del componente RichEdit 4.1 caricato da .DLL
g_nClientW		dd ?			; larghezza area client aggiornata da WM_SIZE per finestra RichEdit
g_nClientH		dd ?			; altezza area client aggiornata da WM_SIZE per finestra RichEdit

.data
g_TabItems		TABITEM MAX_TABS dup (<>)	; array di tutte le tab

; Tema attivo
g_Theme			THEME<>			; struttura tema corrente 
