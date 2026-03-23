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
LOCAL ps:PAINTSTRUCT

	.IF uMsg == WM_PAINT
		invoke BeginPaint, hWnd, ADDR ps
		
		; per ora solo lo sfondo - disegnamo in seguto le tab
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