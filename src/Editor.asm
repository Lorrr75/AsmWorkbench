.code

;
; Editor_Init
;
; Carica Msftedit.dll e prepara il controllo RichEdit 4.1
;
; Out:	eax = 1 successo / 0 errore
;
Editor_Init	proc
	; carica Msftedit.dll - necessaria per richedit 4.1
	invoke	LoadLibrary, ADDR szMsfteditDll
	mov	g_hMsftedit, eax
	cmp	eax, 0
	je	Editor_Init_Error

	mov	eax, 1
	ret

Editor_Init_Error:
	mov	eax, 0
	ret
Editor_Init endp

;
; Editor_ApplySettings
;
; Applica font e tabstop ad un RichEdit
;
; In:	hRE = handle RichEdit
;
Editor_ApplySettings proc hRE:DWORD
LOCAL	cf:CHARFORMAT2
LOCAL	nTabStop:DWORD
	
	; azzera struttura
	lea	edi, cf
	mov	ecx, sizeof CHARFORMAT2
	xor	eax, eax
	rep	stosb

	mov	cf.cbSize, sizeof CHARFORMAT2
	mov	cf.dwMask, CFM_FACE or CFM_SIZE or CFM_CHARSET
	mov	cf.yHeight, 200
	mov	cf.bCharSet, ANSI_CHARSET
	invoke	lstrcpy, ADDR cf.szFaceName, ADDR szEditorFont
	invoke	SendMessage, hRE, EM_SETCHARFORMAT, SCF_ALL, ADDR cf

	; TODO: valore configurabile da Config.asm
	mov	nTabStop, 32
	invoke	SendMessage, hRE, EM_SETTABSTOPS, 1, ADDR nTabStop

	invoke	SendMessage, hRE, EM_LIMITTEXT, -1, 0
	invoke	SendMessage, hRE, EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_SELCHANGE
	ret
Editor_ApplySettings endp

;
; Editor_CreateForTab
;
; Crea un RichEdit nascosto per una tab
; 
; In:	hWndParent = handle della finestra principale
;
; Out: 	eax = handle del RichEdit / 0 = errore
;
Editor_CreateForTab proc hWndParent:DWORD
LOCAL	hRE:DWORD
LOCAL	nTop:DWORD
LOCAL	nH:DWORD

	; calcola posizione e dimensione usando le globali
	mov	eax, TABBAR_HEIGHT
	mov	nTop, eax
	mov	eax, g_nClientH
	sub	eax, TABBAR_HEIGHT
	sub 	eax, STATUSBAR_HEIGHT
	mov	nH, eax

	invoke	CreateWindowEx, WS_EX_CLIENTEDGE, ADDR szRichEdit41Class, NULL,
				WS_CHILD or WS_VSCROLL or WS_HSCROLL or ES_MULTILINE or \
				ES_AUTOVSCROLL or ES_AUTOHSCROLL or ES_NOHIDESEL, 0,
				nTop, g_nClientW, nH, hWndParent, 0, hInstance, NULL

	cmp	eax, 0
	je	Editor_CreateForTab_Error
	mov	hRE, eax

	invoke	Editor_ApplySettings, hRE
	invoke	Theme_ApplyToEditor, hRE

	; resta nascosto finché Editor_ActivateTab non lo mostrerà
	mov	eax, hRE
	ret

Editor_CreateForTab_Error:
	mov	eax, 0
	ret
Editor_CreateForTab endp

;
; Editor_ActivateTab
;
; Nasconde tutti i RichEdit, mostra e attiva quello
; della tab indicata, aggiorna g_hEditor
;
; Input: nIdx = indice tab da attivare
;
Editor_ActivateTab proc nIdx:DWORD
LOCAL i:DWORD
LOCAL pItem:DWORD
LOCAL hRE:DWORD

	; nasconde tutte le tab
	mov	i, 0
Editor_ActivateTab_HideLoop:
	mov	eax, i
	cmp	eax, g_nTabCount
	jge	Editor_Activate_Show

	mov	ecx, sizeof TABITEM
	mul	ecx
	add	eax, offset g_TabItems
	mov	edx, (TABITEM PTR [eax]).hRichEdit
	test	edx, edx
	jz	Editor_Activate_HideNext
	
	invoke	ShowWindow, edx, SW_HIDE

Editor_Activate_HideNext:
	inc	i
	jmp	Editor_ActivateTab_HideLoop

Editor_Activate_Show:
	; calcola puntatore TABITEM della tab da attivare
	mov	eax, nIdx
	mov	ecx, sizeof TABITEM
	mul 	ecx
	add	eax, offset g_TabItems	
	mov	pItem, eax

	; recupera handle RichEdit
	mov	eax, pItem
	mov	eax, (TABITEM PTR [eax]).hRichEdit
	test	eax, eax
	jz	Editor_Activate_End

	mov	hRE, eax
	mov	g_hEditor, eax			; aggiorna editor attivo

	;ridimensione con le dimensioni correnti
	invoke	Editor_Resize, g_nClientW, g_nClientH

	; mostra e porta il focus
	invoke	ShowWindow, hRE, SW_SHOW
	invoke	SetFocus, hRE
	invoke	Editor_RehighlightAll, hRE

Editor_Activate_End:
	ret
Editor_ActivateTab endp

;
; Editor_Resize
;
; Ridimensiona g_hEditor con le dimensioni date
;
; In: 	nWidth, nHeight = dimensioni client area
;
Editor_Resize proc nWidth:DWORD, nHeight:DWORD
LOCAL nTop:DWORD
LOCAL nH:DWORD

    	cmp	g_hEditor, 0
    	je   	Editor_Resize_End

   	mov  	eax, TABBAR_HEIGHT
   	mov  	nTop, eax
    	mov  	eax, nHeight
    	sub  	eax, TABBAR_HEIGHT
    	sub  	eax, STATUSBAR_HEIGHT
    	mov  	nH, eax

    	invoke 	MoveWindow, g_hEditor, 0, nTop, nWidth, nH, TRUE

Editor_Resize_End:
    ret
Editor_Resize endp

;
; Editor_RehighlightAll
;
; Riapplica systex highlighting a tutte le righe
;
; In:	hRE = handle RichEdit
;
Editor_RehighlightAll proc hRE:DWORD
LOCAL	nLines:DWORD
LOCAL	nCurrLine:DWORD

	invoke 	SendMessage, hRE, EM_GETLINECOUNT, 0, 0
	mov	nLines, eax
	mov	nCurrLine, 0

	mov	g_bHighlighting, 1

Editor_Rehighlight_Loop:
	mov	eax, nCurrLine
	cmp	eax, nLines
	jge	Editor_Rehighlight_Done

	invoke	Syntax_HighlightLine, hRE, nCurrLine
	inc	nCurrLine
	jmp	Editor_Rehighlight_Loop

Editor_Rehighlight_Done:
	mov	g_bHighlighting, 0
	ret

Editor_RehighlightAll endp
