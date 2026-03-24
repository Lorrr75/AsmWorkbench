.code

;
; TabBar_RegisterClass
;
; Registra la classe della finestra TabBar
;
; Out:	eax = ATOM (o = errore)
;
TabBar_RegisterClass	proc
LOCAL	wc:WNDCLASSEX

	; come per la finestra principale dobbismo creare un classe da registrare per crearla
	; ora rempiamo i campi della struttura
	mov	wc.cbSize, sizeof WNDCLASSEX
	mov	wc.style, CS_HREDRAW or CS_VREDRAW
	mov	wc.lpfnWndProc, offset TabBar_WndProc
	mov	wc.cbClsExtra, NULL
	mov	wc.cbWndExtra, NULL
	push	hInstance
	pop	wc.hInstance
	mov	wc.hbrBackground, COLOR_BTNFACE+1
	mov	wc.lpszMenuName, NULL
	mov	wc.lpszClassName, offset szTabBarClass
	invoke LoadIcon,   NULL, IDI_APPLICATION
	mov	wc.hIcon, eax
	mov	wc.hIconSm, eax
	invoke	LoadCursor, NULL, IDC_ARROW
	mov	wc.hCursor, eax

	; struttura riempita, ora registriamo la classe
	invoke RegisterClassEx, ADDR wc

	ret
TabBar_RegisterClass endp

;
; TabBar_Create
;
; Crea la finestra TabBar
;
; In:  	hWndParent = handle finestra principale
; Out:	EAX = handle TabBar (0 = errore)
;
TabBar_Create proc hWndParent:DWORD

	invoke CreateWindowEx, NULL, ADDR szTabBarClass, NULL, WS_CHILD or WS_VISIBLE,
           		       0, 0, 0, TABBAR_HEIGHT, hWndParent, IDC_TABBAR,
           		       hInstance, NULL

	ret
TabBar_Create endp

;
; TabBar_WndProc
;
; Gestione messaggi della TabBar
;
TabBar_WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL 	ps:PAINTSTRUCT
LOCAL	rc:RECT
LOCAL	hBrush:DWORD
LOCAL	rcTab:RECT

	.IF uMsg == WM_PAINT
		invoke BeginPaint, hWnd, ADDR ps
		
		; imposta lo sfondo della TabBar
		invoke	GetClientRect, hWnd, ADDR rc
		invoke	CreateSolidBrush, TAB_COLOR_BG
		mov	hBrush, eax
		invoke	FillRect, ps.hdc, ADDR rc, hBrush
		invoke	DeleteObject, hBrush

		; disegna la linea di separazione in fondo alla TabBar
		invoke	MoveToEx, ps.hdc, 0 ,TABBAR_HEIGHT-1, NULL
		invoke	LineTo, ps.hdc, rc.right, TABBAR_HEIGHT-1

		; crea il Tab di test
		mov	rcTab.left, 0
		mov	rcTab.top, 0
		mov	rcTab.right, 120
		mov	rcTab.bottom, TABBAR_HEIGHT-1
		invoke	TabBar_DrawTab, ps.hdc, ADDR rcTab, ADDR szTabTest, 1, 1

		invoke	EndPaint, hWnd, ADDR ps
		xor	eax, eax
		ret	
	.ELSEIF
		invoke	DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.ENDIF

	xor	eax, eax
	ret
TabBar_WndProc endp

;
; TabBar_DrawTab
; 
; Disegna una singola Tab
;
; In:	hDC	 = handle context device
;	pRect	 = puntaotre alla RECT della tab
;	pszTitle = puntatore al titolo
;	bActive	 = 1 se Tab attiva
;	bModified= 1 se file modificato
;
TabBar_DrawTab	proc	hDC:DWORD, pRect:DWORD, pszTitle:DWORD, bActive:DWORD, bModified:DWORD
LOCAL	hBrush:DWORD
local 	hOldFont:DWORD
local 	rcText:RECT
LOCAL	rcClose:RECT
LOCAL	hDotBrush:DWORD
LOCAL	hDotPen:DWORD
LOCAL	nDotX:DWORD
LOCAL 	hOldBrush:DWORD
LOCAL 	hOldPen:DWORD
LOCAL	nDotX2:DWORD


	; sfondo del tab
	.IF bActive == 1
		invoke 	CreateSolidBrush, TAB_COLOR_ACTIVE
	.ELSE
		invoke	CreateSolidBrush, TAB_COLOR_INACTIVE
	.ENDIF
	
	mov	hBrush, eax
	invoke	FillRect, hDC, pRect, hBrush
	invoke	DeleteObject, hBrush

	; bordo del tab
	invoke	CreateSolidBrush, TAB_COLOR_BORDER
	mov	hBrush, eax
	invoke	FrameRect, hDC, pRect, hBrush
	invoke	DeleteObject, hBrush

	; aggiunge il testo del titolo
	mov	eax, pRect
	mov	ecx, (RECT PTR [eax]).left
	mov	edx, (RECT PTR [eax]).top
	add	ecx, 8				; margine sinistro 
	mov	rcText.left, ecx
	mov	rcText.top, edx
	mov	ecx, (RECT PTR [eax]).right
	sub	ecx, 20				; spazio per la x della chiusura
	mov	edx, (RECT PTR [eax]).bottom
	mov	rcText.right, ecx
	mov	rcText.bottom, edx

	invoke	SetBkMode, hDC, TRANSPARENT
	invoke	SetTextColor, hDC, TAB_COLOR_TEXT
	invoke	DrawText, hDC, pszTitle, -1, ADDR rcText, DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS

	; disegna il simbolo X di chiusura a destra nel Tab
	mov	eax, pRect
	mov	ecx, (RECT PTR [eax]).right
	sub 	ecx, 18
	mov	rcClose.left, ecx
	mov	rcClose.top, 4
	mov	ecx, (RECT PTR [eax]).right
	sub	ecx, 4
	mov	rcClose.right, ecx
	mov	rcClose.bottom, 20

	invoke	SetTextColor, hDC, TAB_COLOR_BORDER
	invoke	DrawText, hDC, ADDR szTabClose, -1, ADDR rcClose, DT_CENTER or DT_VCENTER or DT_SINGLELINE	

	; disegna il pallino modificato dopo il testo
	
	.IF bModified == 1
		; calcola posizione X del pallino (a sinistra della X)
        	mov 	eax, pRect
        	mov 	ecx, (RECT PTR [eax]).right
        	sub 	ecx, 34
        	mov 	nDotX, ecx
		add	ecx, 8
		mov	nDotX2, ecx

		invoke 	CreateSolidBrush, TAB_COLOR_MODIFIED
       		mov    	hDotBrush, eax
        	invoke  CreatePen, PS_NULL, 0, TAB_COLOR_MODIFIED
        	mov    	hDotPen, eax

        	invoke 	SelectObject, hDC, hDotBrush
		mov	hOldBrush, eax
	        invoke 	SelectObject, hDC, hDotPen
		mov	hOldPen, eax

        	; disegna cerchio pieno 8x8 pixel centrato verticalmente
      	        invoke 	Ellipse, hDC, nDotX, 9, nDotX2, 17

        	invoke	SelectObject, hDC, hOldBrush
		invoke	SelectObject, hDC, hOldPen
		invoke 	DeleteObject, hDotBrush
        	invoke 	DeleteObject, hDotPen	

	.ENDIF
	
	ret
TabBar_DrawTab	endp