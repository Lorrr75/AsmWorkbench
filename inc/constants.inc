; questo file contiene costanti 


; valori costanti utili al programma funzionanti come macro

IDC_STATUSBAR		equ 100
IDC_TABBAR		equ 101
IDC_EDITOR		equ 102

IDM_FILE_NEW		equ 1001
IDM_FILE_OPEN		equ 1002
IDM_FILE_SAVE		equ 1003


TABBAR_HEIGHT		equ 28			; altezza TabBar
TAB_ARROW_WIDTH		equ 20			; larghezza di ogni freccia
STATUSBAR_HEIGHT	equ 22			; altezza status bar

; valori provvisori del tema Light
TAB_COLOR_BG		equ 00f0f0f0h		; sfondo grigio chiaro della TabBar
TAB_COLOR_ACTIVE	equ 00ffffffh		; Tab attiva - colore bianco
TAB_COLOR_INACTIVE	equ 00d0d0d0h		; Tab inattiva - grigio
TAB_COLOR_TEXT		equ 00000000h		; testo - nero
TAB_COLOR_MODIFIED	equ 000000ffh		; pallino della modifica - blu
TAB_COLOR_BORDER	equ 00a0a0a0h		; bordo Tab - grigio scuro
TAB_MIN_WIDTH		equ 80			; larghezza minima tab
TAB_MAX_WIDTH		equ 400			; larghezza massima tab
TAB_PADDING		equ 40			; spazio fisso per X e margini
TAB_DOT_WIDTH		equ 16			; spazio per il pallino ●


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
szArrowLeft     		db "<", 0
szArrowRight    		db ">", 0

; dati per l'Editor
szMsfteditDll			db "riched20.dll",0
szRichEdit41Class		db "RichEdit20A",0
szEditorFont			db "Courier New", 0

; dati per File Manager
szNewFileTitle			db "Senza nome %d",0
szFileFilter			db "File Assembly (*.asm)", 0, "*.asm", 0, "Tutti i file (*.*)", 0, "*.*", 0, 0
szDefExt			db "asm", 0

; dati per il tema visivo
szThemeLight    db "Light", 0
szThemeDark     db "Dark", 0

; Liste keyword per syntax highlighting
; Ogni entry è esattamente 16 byte — padding con 0
szRegisters db "EAX",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "EBX",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ECX",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "EDX",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ESI",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "EDI",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ESP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "EBP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "AX",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "BX",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "CX",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "DX",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "AH",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "AL",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "BH",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "BL",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "CH",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "CL",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "DH",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "DL",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "CS",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "DS",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ES",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "SS",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "FS",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "GS",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db 0    ; terminatore lista

szMnemonics db "MOV",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "PUSH",  0,0,0,0,0,0,0,0,0,0,0,0,0 
            db "POP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "CALL",  0,0,0,0,0,0,0,0,0,0,0,0,0
            db "RET",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JMP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JE",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JNE",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JZ",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JNZ",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JG",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JL",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JGE",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JLE",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JA",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JB",    0,0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JAE",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "JBE",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "CMP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ADD",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "SUB",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "MUL",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "DIV",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "IMUL",  0,0,0,0,0,0,0,0,0,0,0,0
            db "IDIV",  0,0,0,0,0,0,0,0,0,0,0,0
            db "INC",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "DEC",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "AND",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "OR",    0,0,0,0,0,0,0,0,0,0,0,0,0
            db "XOR",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "NOT",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "NEG",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "SHL",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "SHR",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "SAR",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ROL",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "ROR",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "LEA",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "TEST",  0,0,0,0,0,0,0,0,0,0,0,0
            db "XCHG",  0,0,0,0,0,0,0,0,0,0,0,0
            db "NOP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "INVOKE",0,0,0,0,0,0,0,0,0,0
            db "MOVZX", 0,0,0,0,0,0,0,0,0,0,0
            db "MOVSX", 0,0,0,0,0,0,0,0,0,0,0
            db "LODSB", 0,0,0,0,0,0,0,0,0,0,0
            db "STOSB", 0,0,0,0,0,0,0,0,0,0,0
            db "MOVSB", 0,0,0,0,0,0,0,0,0,0,0
            db "REP",   0,0,0,0,0,0,0,0,0,0,0,0,0
            db "REPNE", 0,0,0,0,0,0,0,0,0,0,0
            db "PUSHAD",0,0,0,0,0,0,0,0,0,0
            db "POPAD", 0,0,0,0,0,0,0,0,0,0,0
            db 0

szDirectives db "PROC", 0,0,0,0,0,0,0,0,0,0,0,0
             db "ENDP", 0,0,0,0,0,0,0,0,0,0,0,0
             db "LOCAL",    0,0,0,0,0,0,0,0,0,0,0
             db "INVOKE",   0,0,0,0,0,0,0,0,0,0
             db "INCLUDE",  0,0,0,0,0,0,0,0,0
             db "INCLUDELIB",   0,0,0,0,0,0
             db "EQU",      0,0,0,0,0,0,0,0,0,0,0,0,0
             db "STRUCT" ,0,0,0,0,0,0,0,0,0,0
             db "ENDS",0,0,0,0,0,0,0,0,0,0,0,0
             db "MACRO",0,0,0,0,0,0,0,0,0,0,0
             db "ENDM",0,0,0,0,0,0,0,0,0,0,0,0
             db "IF",0,0,0,0,0,0,0,0,0,0,0,0,0,0
             db "ENDIF",0,0,0,0,0,0,0,0,0,0,0
             db ".IF",0,0,0,0,0,0,0,0,0,0,0,0,0
             db ".ELSEIF",0,0,0,0,0,0,0,0,0
             db ".ELSE",0,0,0,0,0,0,0,0,0,0,0
             db ".ENDIF",0,0,0,0,0,0,0,0,0,0
             db ".WHILE",0,0,0,0,0,0,0,0,0,0
             db ".ENDW",0,0,0,0,0,0,0,0,0,0,0
             db ".REPEAT",0,0,0,0,0,0,0,0,0
             db ".UNTIL",0,0,0,0,0,0,0,0,0,0
             db ".BREAK",0,0,0,0,0,0,0,0,0,0
             db ".DATA",0,0,0,0,0,0,0,0,0,0,0
             db ".DATA?",0,0,0,0,0,0,0,0,0,0
             db ".CODE",0,0,0,0,0,0,0,0,0,0,0
             db ".MODEL",0,0,0,0,0,0,0,0,0,0
             db ".386",0,0,0,0,0,0,0,0,0,0,0,0
             db ".686",0,0,0,0,0,0,0,0,0,0,0,0
             db "ASSUME",0,0,0,0,0,0,0,0,0,0
             db "OPTION",0,0,0,0,0,0,0,0,0,0
             db "PROTO",0,0,0,0,0,0,0,0,0,0,0
             db "ADDR",0,0,0,0,0,0,0,0,0,0,0,0
             db "OFFSET",0,0,0,0,0,0,0,0,0,0
             db "PTR",0,0,0,0,0,0,0,0,0,0,0,0,0
             db "SIZEOF",0,0,0,0,0,0,0,0,0,0
             db "DWORD",0,0,0,0,0,0,0,0,0,0,0
             db "WORD",0,0,0,0,0,0,0,0,0,0,0,0
             db "BYTE",0,0,0,0,0,0,0,0,0,0,0,0
             db "DB",0,0,0,0,0,0,0,0,0,0,0,0,0,0
             db "DW",0,0,0,0,0,0,0,0,0,0,0,0,0,0
             db "DD",0,0,0,0,0,0,0,0,0,0,0,0,0,0
             db "DUP",0,0,0,0,0,0,0,0,0,0,0,0,0
    	     db "STDCALL",0,0,0,0,0,0,0,0,0
    	     db "FLAT",0,0,0,0,0,0,0,0,0,0,0
    	     db "NEAR",0,0,0,0,0,0,0,0,0,0,0
    	     db "FAR",0,0,0,0,0,0,0,0,0,0,0,0
             db 0

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