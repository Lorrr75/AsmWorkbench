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
; Editor_Create
;
; Crea il controllo RichEdit nella finestra principale
; 
; In:	hWndParent = handle della finestra principale
;
; Out:	eax = handle RichEdit / 0 = errore
;
Editor_Create	proc hWndParent:DWORD
	invoke	CreateWindowEx, WS_EX_CLIENTEDGE, ADDR szRichEdit41Class,
				NULL, WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_HSCROLL or \
				ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL or ES_NOHIDESEL,
				0, 0, 0, 0, hWndParent, IDC_EDITOR, hInstance, NULL

	mov	g_hEditor, eax
	cmp	eax, 0
	je	Editor_Create_Error

	;imposta il di testo al massimo
	invoke 	SendMessage, g_hEditor, EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_SELCHANGE

	mov	eax, g_hEditor
	ret

Editor_Create_Error:
	mov	eax, 0
	ret				
Editor_Create	endp

;
; Editor_Resize
;
; Ridimensiona il RichEdit in base alla finestra
;
; In:	nWidth  = larghezza della finestra
;	nHeight = altezza finestra
;
Editor_Resize	proc nWidth:DWORD, nHeight:DWORD
LOCAL	nTop:DWORD
LOCAL	nEditorHeight:DWORD

	; top = subito sotto la TabBar
	mov	eax, TABBAR_HEIGHT
	mov	nTop, eax

	; altezza = finestra - TabBar - StatusBar
	mov	eax, nHeight
	sub	eax, TABBAR_HEIGHT
	sub	eax, STATUSBAR_HEIGHT
	mov	nEditorHeight, eax

	invoke	MoveWindow, g_hEditor, 0, nTop, nWidth, nEditorHeight, TRUE
	ret
Editor_Resize	endp

;
; Editor_SetDefaultSettings
;
; Imposta font e impostazioni base del RichEdit
;
; In:	nessuno (usa g_hEditor)
;
Editor_SetDefaultSettings	proc
LOCAL	cf:CHARFORMAT2
LOCAL	nTabStop:DWORD

	; azzera la struttura
	mov	ecx, sizeof CHARFORMAT2
	lea	edi, cf
	xor	eax, eax
	rep	stosb

	; imposta il font di default - Currier New 10 pt
	mov	cf.cbSize, sizeof CHARFORMAT2
	mov	cf.dwMask, CFM_FACE or CFM_SIZE or CFM_CHARSET
	mov	cf.yHeight, 200				; 10pt = 200 twips ( 1pt = 20 twips)
	mov	cf.bCharSet, ANSI_CHARSET	

	; copia il nnome del font nella sgtruttura
	invoke	lstrcpy, ADDR cf.szFaceName, ADDR szEditorFont
	
	invoke	SendMessage, g_hEditor, EM_SETCHARFORMAT, SCF_ALL, ADDR cf

	; imposta tab stop a 4 caratteri (in twips: 4 * 240 = 960)
	mov	nTabStop, 960
	invoke	SendMessage, g_hEditor, EM_SETTABSTOPS, 1, ADDR nTabStop

	; disabilita il drag and drop di testo interno (più semplice da gestire)
	invoke	SendMessage, g_hEditor, EM_SETOPTIONS, ECOOP_OR, ECO_NOHIDESEL

	ret
Editor_SetDefaultSettings	endp