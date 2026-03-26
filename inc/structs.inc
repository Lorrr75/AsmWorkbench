; numero massimo di tab aperte contemporaneamente
MAX_TABS	equ 32

;
; struttura di un singolo documento aperto in una tab
;
TABITEM	struct
	szFilePath  	db MAX_PATH dup(0)		; path completo su disco
	szTitle		db 256 dup(0)			; nome vosializzato nella tab
	hRichEdit	dd 0				; handle RichEdit ( futuro )
	bModified	dd 0				; 0 = immutato / 1 = modificato
	bNew		dd 0				; 1 = mai salvato su disco
	hScrollPos	dd 0				; posizione scroll salvata
TABITEM ends

