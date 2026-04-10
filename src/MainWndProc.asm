.386

.code

;
; Funzione di gestione dei messaggi che provengono da windows
; 
;
MainWndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL	hdc:HDC
LOCAL	ps:PAINTSTRUCT
LOCAL	rect:RECT
LOCAL	nWidth:DWORD
LOCAL	nHeight:DWORD

	.IF uMsg == WM_DESTROY				; messaggio di chiusura della finestra
		invoke PostQuitMessage, NULL

	.ELSEIF uMsg == WM_CREATE			; messaggio di creazione della finestra
		invoke	InitIde, hWnd

	.ELSEIF uMsg == WM_PAINT			; messaggio di ridisegno della finestra
		invoke	BeginPaint, hWnd, ADDR ps
		invoke	EndPaint, hWnd, ADDR ps
		ret
		
	.ELSEIF uMsg == WM_COMMAND			; messaggio comandi della finestra
		mov	eax, wParam
		and	eax, 0FFFFh			; PRENDI SOLO IL LOW WORD (id COMANDO)

		.IF	eax == IDM_FILE_NEW
			invoke	FileMgr_New
		.ELSEIF eax == IDM_FILE_OPEN
			invoke	FileMgr_Open
		.ELSEIF eax == IDM_FILE_SAVE
			invoke	FileMgr_Save
		.ELSE
			; controlla se è una notifica EN_CHANGE dal RichEdit
			mov	eax, wParam
			shr	eax, 16			; high word = codice notifica
			cmp	eax, EN_CHANGE
			jne	MainWnd_Command_Done
	
			; testo modificato - aggiorna bModified tab Attiva
			mov	eax, g_nActiveTab
			mov	ecx, sizeof TABITEM
			mul	ecx
			add	eax, offset g_TabItems
			mov	(TABITEM PTR [eax]).bModified, 1
			invoke	InvalidateRect, g_hTabBar, NULL, TRUE
MainWnd_Command_Done:
		.ENDIF
	.ELSEIF uMsg == WM_CLOSE
		invoke	DestroyWindow, hWnd

	.ELSEIF uMsg == WM_SIZE
		mov	eax, lParam
		movzx	ecx, ax				; copia la larghezza in ECX
		shr	eax, 16				; in eax rimane l'altezza

		mov	nWidth, ecx			;memorizza valori appena trovati
		mov	nHeight, eax
		mov	g_nClientW, ecx			;salva sempre le dimensioni per la creazione della RichEdit
		mov	g_nClientH, eax

		; posiziona la TabBar in cina alla finestra
		invoke	MoveWindow, g_hTabBar, 0, 0, ecx, TABBAR_HEIGHT, TRUE

		; ridimensiona la finestra di editor
		invoke 	Editor_Resize, nWidth, nHeight

		; posiziona StatusBar in fondo alla finestra (ha già la proprietà di auto ridimensionarsi con SBAR_SIZEGRIP)
		invoke	SendMessage, g_hStatusBar, WM_SIZE, 0, 0
			
	.ELSEIF uMsg == WM_NOTIFY
	.ELSEIF uMsg == WM_MOVE
	.ELSEIF uMsg == WM_MOUSEMOVE
	.ELSEIF uMsg == WM_LBUTTONDOWN
	.ELSEIF uMsg == WM_MBUTTONDOWN
	.ELSEIF uMsg == WM_RBUTTONDOWN
	.ELSEIF uMsg == WM_LBUTTONUP
	.ELSEIF uMsg == WM_MBUTTONUP
	.ELSEIF uMsg == WM_RBUTTONUP
	.ELSEIF uMsg == WM_KEYDOWN
	.ELSEIF uMsg == WM_KEYUP
	.ELSEIF uMsg == WM_CHAR
	.ELSEIF uMsg == WM_TIMER


	.ELSE
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.ENDIF

	xor	eax, eax
	ret
MainWndProc	endp