.data

szMainClassName 			db "LR_AW",0			; Nome della classe finestra principale
szAppName				db "Asm Workbench",0		; Nome dell'applicazione

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