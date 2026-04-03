.code

;
; programma di inzizializzazione, ciclo principale, pulizia dati e uscita
;
WinMain proc hInst:DWORD, hPrevInst:DWORD, szCmdLine:DWORD, nCmdShow:DWORD
LOCAL	wc:WNDCLASSEX				;crea variabili locali sullo stack
LOCAL	msg:MSG
LOCAL	acc[3]:ACCEL
LOCAL	rc:RECT

	; chiama la registrazione della classe della finestra principale
	invoke	RegisterWindowMainClass

	; sopraggiunti errori durante la registrazione?
	cmp	eax, 0
	jne	RegisterWindowMainClass_OK

	; si, segnaliamo errore
	lea	eax, szErrorRegisterWindowMainClass
	jmp	WinMain_Error

	; no, continuiamo con il programma
RegisterWindowMainClass_OK:

	invoke	CreateWindowEx, WS_EX_ACCEPTFILES, ADDR szMainClassName, ADDR szAppName, WS_OVERLAPPEDWINDOW, \
				CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, \
				NULL, NULL, hInst, NULL

	; sopraggiunti errori durante la creazione?
	cmp	eax, 0
	jne	CreateWindowEx_OK

	; si, segnaliamo errore
	lea	eax, szErrorCreateWindow
	jmp	WinMain_Error

	; no, continuiamo con il programma
CreateWindowEx_OK:
	mov	g_hMainWnd, eax					; memorizziamo handle della finestra	

	; mostriamo la finestra
	invoke	ShowWindow, g_hMainWnd, nCmdShow
	invoke	UpdateWindow, g_hMainWnd
	
	; forza WM_SIZE iniziale + la finestra ora è visibile
	invoke	GetClientRect, g_hMainWnd, ADDR rc
	mov	eax, rc.bottom
	shl	eax, 16
	or	eax, rc.right
	invoke	SendMessage, g_hMainWnd, WM_SIZE, SIZE_RESTORED, eax

;	invoke	Theme_Load, THEME_LIGHT				; carica il tema LIGHT per default
;	invoke	Updater_CheckAsync				; thread controllo aggiornamenti

	mov	acc[0].fVirt, FVIRTKEY or FCONTROL
	mov	acc[0].key, 'N'
	mov	acc[0].cmd, IDM_FILE_NEW
	
	mov	acc[6].fVirt, FVIRTKEY or FCONTROL
	mov	acc[6].key, 'O'
	mov	acc[6].cmd, IDM_FILE_OPEN

	mov	acc[12].fVirt, FVIRTKEY or FCONTROL
	mov	acc[12].key, 'S'
	mov	acc[12].cmd, IDM_FILE_SAVE

	invoke	CreateAcceleratorTable, ADDR acc, 3
	mov	g_hAccel, eax

	;ciclo principale messaggi
	.WHILE TRUE
		invoke	GetMessage, ADDR msg, NULL, 0, 0	; preleva messaggio
		.BREAK .IF (!eax)				; se no eax interrompi ed esci
		invoke 	TranslateAccelerator, g_hMainWnd, g_hAccel, ADDR msg
		.IF eax == 0
			invoke	TranslateMessage, ADDR msg		; traduce messaggio
			invoke	DispatchMessage, ADDR msg		; smista messaggio
		.ENDIF
	.ENDW

	mov	eax, msg.wParam					; restituiamo messaggio paramentri ultimo messaggio ricevuto
WinMain_Exit:
	ret

WinMain_Error:
	; quando siamo qui, in eax c'è l'offset del messggio da inserire nella MessageBox e poi prosegue all'uscita
	invoke	MessageBox, NULL, eax, offset szCaptionError, MB_OK
	mov	eax, -1				; restituiamo errore "massimo"

	; dopo aver preso visione del messaggio d'errore irreversibile usciamo dal programma
	jmp	WinMain_Exit
WinMain	endp