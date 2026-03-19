.code

;
; Registra la clase della finestra principale di AsmWorkBench
; Out: EAX = ATOM della classe registrata (o = errore)
;
RegisterWindowMainClass	proc
local	wc:WNDCLASSEX						;crea variabili locali sullo stack

	;riempe la struttura della classe con i dati
	mov	wc.cbSize, SIZEOF WNDCLASSEX		
								; della dimensione della struttura in byte
	mov	wc.style, CS_HREDRAW or CS_VREDRAW		; stile della finestra
	mov	wc.lpfnWndProc, OFFSET MainWndProc		; offset della funzione di gestioni dei messaggi della finestra
	mov	wc.cbClsExtra, NULL				; a NULL per win32 e superirori
	mov	wc.cbWndExtra, NULL				; a NULL per win32 e superirori
	push	hInstance					; usa lo stack per spostare hInstance nella struttura
	pop	wc.hInstance
	mov	wc.hbrBackground, COLOR_WINDOW+1		; colore dello sfondo della finestra
								; ToDo: gestire con theme.asm
	mov	wc.lpszMenuName, NULL				; nome del Menu che compare in cima alla finestra
								; ToDO: gestire il menu appena possibile
	mov	wc.lpszClassName, OFFSET szMainClassName	; nome della classe da registrare

	; ToDo: sostituire con icona AsmWorkbench da res/icons/
	invoke 	LoadIcon, NULL, IDI_APPLICATION			; icona della finestra standard
	mov	wc.hIcon, eax					; normale
	mov	wc.hIconSm, eax					; piccola
	invoke	LoadCursor, NULL, IDC_ARROW			; carica icona cursore mouse standard
	mov	wc.hCursor, eax

	; eax = ATOM (0 se fallisce) - valore controllato da WinMain
	invoke	RegisterClassEx, addr wc			; fa la registrazione della classe della finestra

	ret							; eax contiene l'ATOM (0 = errore)
								; WinMain fa il controllo cmp eax, 0
RegisterWindowMainClass	endp