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
LOCAL	nClickX, nClickY:DWORD
LOCAL	nTabIdx:DWORD
LOCAL	nTabLeft:DWORD
LOCAL	bAct:DWORD
LOCAL	pTitle:DWORD
LOCAL	pCurItem:DWORD


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

		; aggiunge un tab iniziale di test
		mov	nTabIdx, 0
		mov	nTabLeft, 0

TabBar_Paint_Loop:
		mov	eax, nTabIdx
		cmp	eax, g_nTabCount
		jge	TabBar_Paint_Done
		
		; calcola RECT della tab corrente
		mov	eax, nTabLeft
		mov	rcTab.left, eax
		mov	rcTab.top, 0
		add	eax, 120			; larghezza della tab = 120px
		mov	rcTab.right, eax
		mov	rcTab.bottom, TABBAR_HEIGHT-1

		; calcola puntatore a TABITEM corrente
		mov	eax, nTabIdx
		mov	ecx, sizeof TABITEM
		mul	ecx
		add	eax, offset g_TabItems		
		mov	pCurItem, eax

		; bActive = 1 se indice corrente == g_nActiveTab
		mov	eax, nTabIdx
		mov	ecx, g_nActiveTab
		xor	edx, edx
		cmp	eax, ecx
		sete	dl
		mov	bAct, edx

		; punta al titolo (szTitle = dopo szFilePath = MAX_PATH in byte)
		mov	eax, pCurItem
		add	eax, MAX_PATH
		mov	pTitle, eax

		; leggi bModified dalla struttura
		mov	eax, pCurItem
		mov	ecx, (TABITEM PTR [eax]).bModified

		invoke TabBar_DrawTab, ps.hdc, ADDR rcTab, pTitle, bAct, ecx
	
		; avanza alla twab successiva
		mov	eax, rcTab.right
		mov	nTabLeft, eax
		inc	nTabIdx
		jmp	TabBar_Paint_Loop

TabBar_Paint_Done:
		
		invoke	EndPaint, hWnd, ADDR ps
		xor	eax, eax
		ret	
	.ELSEIF uMsg == WM_LBUTTONDOWN
		
		; estrae le coordinate del click da lParam
		mov	eax, lParam
		movzx	ecx, ax			; X del click
		mov	nClickX, ecx
		shr	eax, 16			; Y del click
		mov	nClickY, eax

		; controlla la zona della X
		; ora lo fa sull'unica presente il tab di test
		; quando avremo la sita di tab dinamica itereremo su tutte
		mov	ecx, nClickX
		cmp	ecx, 102		; 120 - 18 = 102 zona della X
		jl	TabBar_LBDown_notClose
		cmp	ecx, 116		; 120 - 4 = 116 zona della X
		jg	TabBar_LBDown_notClose 

		mov	ecx, nClickY
		cmp	ecx, 4			; zona della X
		jl	TabBar_LBDown_notClose
		cmp	ecx, 20			; zona della X
		jg	TabBar_LBDown_notClose 
		
		; se giunto fino a qui hai cliccato sulla X e mostra solo un messaggio
		invoke	MessageBox, hWnd, ADDR szTabCloseMsg, ADDR szCaptionWarning, MB_OK
TabBar_LBDown_notClose:
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

;
; TabBar_AddTab
;
; Aggiunge una nuova tab all'array g_TabItems
;
; In:	pszFilePath 	= puntatore al path (NULL se nuovo file)
;	pszTitle	= puntatore al titolo da mostrare
;	bNew		= 1 se file nuovo mai salvato
;
; Out:	eax	= indice della vuova tab / -1 se array pieno
;
TabBar_AddTab proc pszFilePath:DWORD, pszTitle:DWORD, bNew:DWORD
LOCAL	nIdx:DWORD
LOCAL	pItem:DWORD

	; controllo che l'array non sia pieno
	mov	eax, g_nTabCount
	cmp	eax, MAX_TABS
	jge	TabBar_AddrTab_Full

	; calcola puntatore all'elemento dell'array
	mov	nIdx, eax
	mov	ecx, sizeof TABITEM
	mul	ecx				; eax = nIdx * sizeof TABITEM
	add	eax, offset g_TabItems		; eax = offset g_TabItems[nIdx]
	mov	pItem, eax

	; azzera la struttura del nuovo tab
	mov	esi, pszTitle
	mov	edi, pItem
	add  	edi, MAX_PATH      ; szTitle è dopo szFilePath (MAX_PATH = 260 bytes)
	mov	ecx, 255
TabBar_AddrTab_CopyTitle:
	lodsb
	stosb
	test	al,al
	jz	TabBar_AddTab_TitleDone
	loop	TabBar_AddrTab_CopyTitle
TabBar_AddTab_TitleDone:

	; copia il path se diverso da NULL
	mov	eax, pszFilePath
	test	eax, eax
	jz	TabBar_AddTab_NoPath
	mov	esi, pszFilePath
	mov	edi, pItem			; punta a szFilePath (primo campo)
	mov	ecx, MAX_PATH-1
TabBar_AddrTab_CopyPath:
	lodsb
	stosb
	test	al, al
	jz	Tab_AddrTab_PathDone
	loop	TabBar_AddrTab_CopyPath
Tab_AddrTab_PathDone:
TabBar_AddTab_NoPath:

	; imposta bNew e bModified
	mov	edi, pItem
	mov	eax, bNew
	mov	(TABITEM PTR [edi]).bNew, eax
	mov	(TABITEM PTR [edi]).bModified, 0

	; aggiorna contatore e imposta come tab attiva
	mov	eax, nIdx
	mov	g_nActiveTab, eax
	inc	g_nTabCount

	; ridisegna la tabbar
	invoke	InvalidateRect, g_hTabBar, NULL, TRUE

	mov	eax,nIdx
	ret

TabBar_AddrTab_Full:
	mov	eax, -1
	ret
TabBar_AddTab endp
