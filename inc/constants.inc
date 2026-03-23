; questo file contiene costanti 


; valori costanti utili al programma funzionanti come macro

IDC_STATUSBAR		equ 100
IDC_TABBAR		equ 101


TABBAR_HEIGHT		equ 28


.data

; dati costanti memorizzati in memoria per il funzionamento del programma

szMainClassName 		db "LR_AW",0			; Nome della classe finestra principale
szAppName			db "Asm Workbench",0		; Nome dell'applicazione
szStatusBarClass		db "msctls_statusbar32",0	; Nome della classe StatusBar
szStatusReady			db "Lin 1 Col 1",0		; testo iniziale della creazione della StatusBar
szStatusNoFile			db "Nessun File",0		; testo iniziale della creazione della StatusBar

; dati per la TabBar
szTabBarClass			db "AWB_TabBar",0




;
; Messaggi di Attenzione per Message Box
;
szCaptionWarning			db "ATTENZIONE",0


;
; Messaggi di errore per Message Box
;
szCaptionError				db "ERRORE",0			; titolo della Message Box
szErrorRegisterWindowMainClass		db "Impossibile registrare la classe della finestra.", 0ah, 0dh, "Programma terminato",0
szErrorCreateWindow			db "Impossibile creare la finesta.", 0ah, 0dh, "Programma terminato",0