.code

;
; Theme_Load
;
; Carica un tema predefinito nella struttura g_Theme
;
; In:	nThemeId = THEME_LIGHT / THEME_DARK
;
Theme_Load proc nThemeId:DWORD

	.IF nThemeId == THEME_DARK
		invoke	Theme_LoadDark
	.ELSE
		invoke	Theme_LoadLight		; tema di default
	.ENDIF

	mov	eax, nThemeId
	mov	g_Theme.nThemeId, eax
	ret
Theme_Load endp

;
; Theme_LoadLight
; 
; imposta i colori del tema Light
;
Theme_LoadLight proc
    ; Editor
    mov  g_Theme.clrBackground,    00FFFFFFh  	; bianco
    mov  g_Theme.clrForeground,    000000000h  	; nero
    mov  g_Theme.clrCurrentLineBg, 00FFF8DCh  	; giallo chiarissimo
    mov  g_Theme.clrSelectionBg,   000078D7h   	; blu selezione Windows

    ; Syntax highlighting
    mov  g_Theme.clrMnemonic,      000000FFh   	; blu
    mov  g_Theme.clrRegister,      0000008Bh   	; rosso scuro
    mov  g_Theme.clrDirective,     00800080h   	; viola
    mov  g_Theme.clrComment,       00008000h   	; verde
    mov  g_Theme.clrString,        001515A3h   	; rosso mattone
    mov  g_Theme.clrNumber,        00865609h   	; verde acqua
    mov  g_Theme.clrOperator,      00000000h   	; nero
    mov  g_Theme.clrLabel,         000000AAh   	; blu scuro

    ; Validazione e guide
    mov  g_Theme.clrSquiggly,      000000FFh   	; rosso
    mov  g_Theme.clrIndentGuide,   00D0D0D0h   	; grigio chiaro

    ; Tab bar
    mov  g_Theme.clrTabActiveBg,   00FFFFFFh   	; bianco
    mov  g_Theme.clrTabActiveFg,   000000000h  	; nero
    mov  g_Theme.clrTabInactiveBg, 00ECECECh   	; grigio chiaro
    mov  g_Theme.clrTabInactiveFg, 00606060h   	; grigio scuro
    mov  g_Theme.clrTabModified,   000000FFh   	; blu
    mov  g_Theme.clrTabBorder,     00A0A0A0h   	; grigio
    mov  g_Theme.clrTabBarBg,      00F0F0F0h   	; grigio molto chiaro

    ; UI
    mov  g_Theme.clrStatusbarBg,   00F0F0F0h
    mov  g_Theme.clrStatusbarFg,   000000000h
    mov  g_Theme.clrSplitter,      00C0C0C0h

    ; Nome tema
    invoke lstrcpy, ADDR g_Theme.szThemeName, ADDR szThemeLight
    ret
Theme_LoadLight endp

;
; Theme_LoadDark
; 
; imposta i colori del tema Dark
;
Theme_LoadDark proc
    ; Editor
    mov  g_Theme.clrBackground,    001E1E1Eh   	; grigio scuro
    mov  g_Theme.clrForeground,    00D4D4D4h   	; grigio chiaro
    mov  g_Theme.clrCurrentLineBg, 002A2A2Ah   	; grigio leggermente più chiaro
    mov  g_Theme.clrSelectionBg,   00264F78h   	; blu scuro selezione

    ; Syntax highlighting
    mov  g_Theme.clrMnemonic,      00D69C56h   	; azzurro
    mov  g_Theme.clrRegister,      00FE9CC9h   	; azzurro chiaro
    mov  g_Theme.clrDirective,     00C0C586h   	; viola chiaro
    mov  g_Theme.clrComment,       0055996Ah   	; verde desaturato
    mov  g_Theme.clrString,        007892CEh   	; arancione salmone
    mov  g_Theme.clrNumber,        000000FFh   	; rosso acceso
    mov  g_Theme.clrOperator,      00FF0000h   	; grigio chiaro
    mov  g_Theme.clrLabel,         00DCDCAAh   	; giallo chiaro

    ; Validazione e guide
    mov  g_Theme.clrSquiggly,      004747F4h   	; rosso brillante
    mov  g_Theme.clrIndentGuide,   00404040h   	; grigio scuro

    ; Tab bar
    mov  g_Theme.clrTabActiveBg,   001E1E1Eh   	; uguale sfondo editor
    mov  g_Theme.clrTabActiveFg,   00D4D4D4h   	; grigio chiaro
    mov  g_Theme.clrTabInactiveBg, 002D2D2Dh   	; grigio scuro
    mov  g_Theme.clrTabInactiveFg, 00808080h   	; grigio medio
    mov  g_Theme.clrTabModified,   004747F4h   	; rosso/arancione
    mov  g_Theme.clrTabBorder,     00454545h   	; grigio scuro
    mov  g_Theme.clrTabBarBg,      002D2D2Dh   	; grigio scuro

    ; UI
    mov  g_Theme.clrStatusbarBg,   00007ACCh  	; blu VS
    mov  g_Theme.clrStatusbarFg,   00FFFFFFh   	; bianco
    mov  g_Theme.clrSplitter,      00404040h

    ; Nome tema
    invoke lstrcpy, ADDR g_Theme.szThemeName, ADDR szThemeDark
    ret
Theme_LoadDark endp


;
; Theme_Apply
;
; Applica il tema corrente a tutti i componenti
; Da chiamare dopo Theme_Load o dopo cambio tema
;
Theme_Apply proc
LOCAL i:DWORD

	; applica sfondo a tutti i RichEdit aperti
	mov	i, 0
Theme_Apply_Loop:
	mov	eax, i
	cmp	eax, g_nTabCount
	jge	Theme_Apply_Done

	mov	ecx, sizeof TABITEM
	mul	ecx
	add	eax, offset g_TabItems
	mov	edx, (TABITEM PTR [eax]).hRichEdit
	test	edx, edx
	jz	Theme_Apply_Next
	invoke  Theme_ApplyToEditor, edx

Theme_Apply_Next:
	inc	i
	jmp	Theme_Apply_Loop
Theme_Apply_Done:
	invoke	InvalidateRect, g_hMainWnd, NULL, TRUE
    ret
Theme_Apply endp
	
;
; Theme_ApplyToEditor
; Applica colori tema a un singolo RichEdit
;
; Input: hRE = handle RichEdit
;
Theme_ApplyToEditor proc hRE:DWORD
LOCAL	cf:CHARFORMAT2

	invoke	SendMessage, hRE, EM_SETBKGNDCOLOR, 0, g_Theme.clrBackground

	; azzera struttura
	lea	edi, cf
	mov	ecx, sizeof CHARFORMAT2
	xor	eax, eax
	rep	stosb

	mov	cf.cbSize, sizeof CHARFORMAT2
	mov	cf.dwMask, CFM_COLOR
	mov	eax, g_Theme.clrForeground
	mov	cf.crTextColor, eax

	invoke	SendMessage, hRE, EM_SETCHARFORMAT, SCF_ALL, ADDR cf
	ret	
Theme_ApplyToEditor endp