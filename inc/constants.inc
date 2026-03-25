; questo file contiene costanti 


; valori costanti utili al programma funzionanti come macro

IDC_STATUSBAR		equ 100
IDC_TABBAR		equ 101


TABBAR_HEIGHT		equ 28


; valori provvisori del tema Light
TAB_COLOR_BG		equ 00f0f0f0h		; sfondo grigio chiaro della TabBar
TAB_COLOR_ACTIVE	equ 00ffffffh		; Tab attiva - colore bianco
TAB_COLOR_INACTIVE	equ 00d0d0d0h		; Tab inattiva - grigio
TAB_COLOR_TEXT		equ 00000000h		; testo - nero
TAB_COLOR_MODIFIED	equ 000000ffh		; pallino della modifica - blu
TAB_COLOR_BORDER	equ 00a0a0a0h		; bordo Tab - grigio scuro


.data

; dati costanti memorizzati in memoria per il funzionamento del programma

szMainClassName 		db "LR_AW",0			; Nome della classe finestra principale
szAppName			db "Asm Workbench",0		; Nome dell'applicazione
szStatusBarClass		db "msctls_statusbar32",0	; Nome della classe StatusBar
szStatusReady			db "Lin 1 Col 1",0		; testo iniziale della creazione della StatusBar
szStatusNoFile			db "Nessun File",0		; testo iniziale della creazione della StatusBar

; dati per la TabBar
szTabBarClass			db "AWB_TabBar",0
szTabClose			db "x",0
szTabCloseMsg			db "Chiudi tab (da implementare)", 0


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