.code

;
; InitIde
; Crea e inizializza tutti i componenti della finestra
;
; In:	hWnd = handle della finestra principale
;
; Out:	eax = 1 successo / 0 errore
;
InitIde	proc hWnd:DWORD
LOCAL	aParts[3]:DWORD			; numero di parti della StatusBar

	; carica Msftedit.dll
	invoke	Editor_Init
	cmp	eax, 0
	je	InitIde_Error

	; Partimamo con la creazione della TabBar
	invoke	TabBar_RegisterClass
	cmp	eax, 0			; ci sono stati degli errori?
	je 	InitIde_Error		; si, vai a comunicarlo

	; nessun errore per cui possiamo crearla
	invoke	TabBar_Create, hWnd
	mov	g_hTabBar, eax		;salva handle della tab bar
	cmp	eax, 0			; ci sono stati degli errori?
	je 	InitIde_Error		; si, vai a comunicarlo

	; ora creaiamo la StatusBar
	invoke CreateWindowEx, NULL, ADDR szStatusBarClass, NULL, WS_CHILD or WS_VISIBLE or SBARS_SIZEGRIP,
				0, 0, 0, 0, hWnd, IDC_STATUSBAR, hInstance, NULL

	mov	g_hStatusBar, eax		; salva valore di ritorno della creazione

	; divide la StatusBar in 3 parti
	mov	aParts[0], 200			; prima sezione larga 200px (visualizza riga/colonna)
	mov	aParts[4], 400			; seconda sezione fino a 400px (nome del file)
	mov	aParts[8], -1			; terza sezione resto della StatusBar (messaggi)

	; crea la divisione
	invoke	SendMessage, g_hStatusBar, SB_SETPARTS, 3, ADDR aParts

	; riempe gli spazi con un testo iniziale
	invoke	SendMessage, g_hStatusBar, SB_SETTEXT, 0, offset szStatusReady
	invoke	SendMessage, g_hStatusBar, SB_SETTEXT, 1, ADDR szStatusNoFile
	invoke	SendMessage, g_hStatusBar, SB_SETTEXT, 2, NULL

	mov	eax, 1				; comunica che è tutto OK
	ret

InitIde_Error:
	mov	eax, 0				; siamo certi che eax contenga 0
	ret
InitIde	endp