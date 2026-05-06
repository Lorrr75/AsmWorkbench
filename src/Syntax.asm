.code

;
; Syntax_HighlightLine
;
; Applica syntax highlighting alla riga corrente
;
; In:	hRE = handle RichEdit
;	nLine = numero di riga
;
Syntax_HighlightLine proc hRE:DWORD, nLine:DWORD
LOCAL  	szLine[256]:BYTE
LOCAL 	tl:TEXTRANGE
LOCAL 	nLineStart:DWORD
LOCAL 	nLineEnd:DWORD
LOCAL 	nLineLen:DWORD
LOCAL	cr:CHARRANGE
LOCAL 	nSavedPos:DWORD

	; salva posizione cursore - solo il punto di inserimento
	invoke	SendMessage, hRE, EM_EXGETSEL, 0, ADDR cr
	mov	eax, cr.cpMax			; cpMax = posizione del cursore
	mov	nSavedPos, eax
	
	; calcola inizio riga
	invoke	SendMessage, hRE, EM_LINEINDEX, nLine, 0
	mov	nLineStart, eax

	; calcola lunghezza riga
	invoke	SendMessage, hRE, EM_LINELENGTH, nLineStart, 0
	mov	nLineLen, eax
	cmp	eax, 0
	je	Syntax_HL_Done
	
	cmp	eax, 254
	jle	Syntax_HL_LenOK

	mov	eax, 254

Syntax_HL_LenOK:
	mov	nLineLen, eax
	mov	eax, nLineStart
	add	eax, nLineLen
	mov	nLineEnd, eax

	; legge testo riga
	mov	eax, nLineStart
	mov	tl.chrg.cpMin, eax
	mov	eax, nLineEnd
	mov	tl.chrg.cpMax, eax
	lea	eax, szLine
	mov	tl.lpstrText, eax
	invoke	SendMessage, hRE, EM_GETTEXTRANGE, 0, ADDR tl

	; azzera terminatore per sicurezza
	lea	eax, szLine
	add	eax, nLineLen
	mov	byte ptr [eax], 0

	; colore base su tutta la linea
    	invoke 	Syntax_SetColor, hRE, nLineStart, nLineEnd, g_Theme.clrForeground

	; applica categoria in ordine
    	invoke 	Syntax_HighlightComment,  hRE, ADDR szLine, nLineStart, nLineLen
    	invoke 	Syntax_HighlightStrings,  hRE, ADDR szLine, nLineStart, nLineLen
    	invoke 	Syntax_HighlightNumbers,  hRE, ADDR szLine, nLineStart, nLineLen
	invoke 	Syntax_HighlightDotDirectives, hRE, ADDR szLine, nLineStart, nLineLen
    	invoke 	Syntax_HighlightKeywords, hRE, ADDR szLine, nLineStart, nLineLen

Syntax_HL_Done:
    	; ripristina cursore senza selezione (cpMin = cpMax = posizione salvata)
	mov	eax, nSavedPos
	mov	cr.cpMin, eax
	mov	cr.cpMax, eax
	invoke	SendMessage, hRE, EM_EXSETSEL, 0, ADDR cr
	
	ret
Syntax_HighlightLine endp

;
; Syntax_SetColor
;
; Applica un colore a un intervallo di testo
;
; In:	hRE = handle RichEdit
;	nStart, nEnd = intervallo caratteri
;	nColor = COLORREF
;
Syntax_SetColor proc hRE:DWORD, nStart:DWORD, nEnd:DWORD, nColor:DWORD
LOCAL cf:CHARFORMAT2
LOCAL cr:CHARRANGE

	; seleziona l'intervallo
	mov	eax, nStart
	mov	cr.cpMin, eax
	mov	eax, nEnd
	mov	cr.cpMax, eax
	invoke	SendMessage, hRE, EM_EXSETSEL, 0, ADDR cr

	; azzera struttura
	lea	edi, cf
	mov	ecx, sizeof CHARFORMAT2
	xor	eax, eax
	rep	stosb

	mov	cf.cbSize, sizeof CHARFORMAT2
	mov	cf.dwMask, CFM_COLOR
	mov	eax, nColor
	mov	cf.crTextColor, eax

	invoke	SendMessage, hRE, EM_SETCHARFORMAT, SCF_SELECTION, ADDR cf
	ret
Syntax_SetColor endp

;
; Syntax_HighlightComment
; 
; Colora tutto dopo il ; fino a fine riga
;
Syntax_HighlightComment proc hRE:DWORD, pszLine:DWORD, nLineStart:DWORD, nLineLen:DWORD
LOCAL i:DWORD
	
	mov	i, 0
	mov	esi, pszLine

Syntax_Comment_Loop:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_Comment_Done

	lodsb
	cmp	al,';'
	je	Syntax_Comment_Found
	inc 	i
	jmp	Syntax_Comment_Loop

Syntax_Comment_Found:
	; tovato il ; - colora da qui a fine riga
	mov	eax, nLineStart
	add	eax, i
	mov	ecx, nLineStart
	add	ecx, nLineLen
	invoke	Syntax_SetColor, hRE, eax, ecx, g_Theme.clrComment
	
Syntax_Comment_Done:
	ret
Syntax_HighlightComment endp

;
; Syntax_HighlightStrings
;
; Colora testo tra le "..."
;
Syntax_HighlightStrings proc hRE:DWORD, pszLine:DWORD, nLineStart:DWORD, nLineLen:DWORD
LOCAL i:DWORD
LOCAL nStrStart:DWORD
LOCAL bInString:DWORD
	
	mov	i, 0
	mov	bInString, 0
	mov	esi, pszLine

Syntax_Strings_Loop:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_Strings_Done

	lodsb

	; salta se siamo in un commento
	cmp	al, ';'
	je	Syntax_Strings_Next
	cmp	al, '"'
	jne	Syntax_Strings_Next
	
	cmp	bInString, 0
	jne	Syntax_Strings_End

	; inizio stringa
	mov	eax, nLineStart
	add	eax, i
	mov	nStrStart, eax
	mov	bInString, 1
	jmp	Syntax_Strings_Next

Syntax_Strings_End:
	; fine stringa - colora l'intervallo
	mov	bInString, 0
	mov	eax, nLineStart
	add	eax, i
	inc	eax			; include la virgoletta chiusa
	invoke	Syntax_SetColor, hRE, nStrStart, eax, g_Theme.clrString

Syntax_Strings_Next:
	inc	i
	jmp	Syntax_Strings_Loop

Syntax_Strings_Done:
	ret
Syntax_HighlightStrings endp

;
; Syntax_HighlightNumbers
;
; Colora costanti numeriche (decimali, esadecimali binari)
;
Syntax_HighlightNumbers proc hRE:DWORD, pszLine:DWORD, nLineStart:DWORD, nLineLen:DWORD
LOCAL 	i:DWORD
LOCAL 	nNumStart:DWORD
LOCAL 	bInNum:DWORD

	mov	i, 0
	mov	bInNum, 0

Syntax_Numbers_Loop:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_Numbers_Flush

	; legge carattere corrente senza usare lodsb
	mov	esi, pszLine
	add	esi, i
	mov	al, [esi]

	; salta i caratteri extended ASCII (accenti ecc.)
	test	al, 80h
	jnz	Syntax_Numbers_Next

	cmp	al, ';'
	je	Syntax_Numbers_Flush

	; cifra decimale o inizio esadecimale (0..9)
	cmp	al, '0'
	jl	Syntax_Numbers_NotDigit
	cmp	al, '9'
	jle	Syntax_Numbers_IsDigit

	; lettera esadecimale (A..F, a..f)
	cmp	bInNum, 1
	jne	Syntax_Numbers_NotDigit
	cmp	al, 'A'
	jl	Syntax_Numbers_CheckLower
	cmp	al, 'F'
	jle	Syntax_Numbers_IsDigit

Syntax_Numbers_CheckLower:

	cmp	al, 'a'
	jl	Syntax_Numbers_NotDigit
	cmp	al, 'f'
	jle	Syntax_Numbers_IsDigit

	; suffisso h o b - termina numero
	cmp	bInNum, 1
	jne	Syntax_Numbers_NotDigit
	cmp	al, 'h'
	je	Syntax_Numbers_Suffix
	cmp	al, 'H'
	je	Syntax_Numbers_Suffix
	cmp	al, 'b'
	je	Syntax_Numbers_Suffix
	cmp	al, 'B'
	je	Syntax_Numbers_Suffix
	jmp	Syntax_Numbers_NotDigit

Syntax_Numbers_Suffix:
	; includi il suffisso nel colore
	mov	eax, nLineStart
	add	eax, i
	inc 	eax
	invoke	Syntax_SetColor, hRE, nNumStart, eax, g_Theme.clrNumber
	mov	bInNum, 0
	inc	i
	jmp	Syntax_Numbers_Loop

Syntax_Numbers_IsDigit:
	cmp	bInNum, 1
	je	Syntax_Numbers_Next	; salta è già un numero

	; inizia nuovo numero
	mov	eax, nLineStart
	add	eax, i
	mov	nNumStart, eax
	mov	bInNum, 1
	jmp 	Syntax_Numbers_Next

Syntax_Numbers_NotDigit:
	cmp	bInNum, 1		; eravamo in un numero?
	jne	Syntax_Numbers_Next	; no, salta

	; fine numero senza suffisso
	mov	eax, nLineStart
	add	eax, i
	invoke	Syntax_SetColor, hRE, nNumStart, eax, g_Theme.clrNumber
	mov	bInNum, 0

Syntax_Numbers_Next:
	inc	i
	jmp	Syntax_Numbers_Loop

Syntax_Numbers_Flush:
	cmp	bInNum, 1
	jne	Syntax_Numbers_Done
	mov	eax, nLineStart
	add	eax, i
	invoke	Syntax_SetColor, hRE, nNumStart, eax, g_Theme.clrNumber

Syntax_Numbers_Done:	
	ret
Syntax_HighlightNumbers endp

;
; Syntax_HighlightKeywords
;
; colora mnemonici, registri e direttive
; (versione base - lista hardcoded, espandibile)
;
Syntax_HighlightKeywords proc hRE:DWORD, pszLine:DWORD, nLineStart:DWORD, nLineLen:DWORD
LOCAL 	szToken[64]:BYTE
LOCAL 	i:DWORD
LOCAL 	nTokStart:DWORD
LOCAL 	nTokLen:DWORD
LOCAL 	nTokAbsStart:DWORD

	mov	i, 0

Syntax_KW_Loop:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_KW_Done

	; legge carattere corrente
	mov	esi, pszLine
	add	esi, i
	mov	al, [esi]

	; salta caratteri extended ASCII
    	test 	al, 80h
    	jnz  	Syntax_KW_Skip
	
	; salta separatori incrementando i
   	cmp  	al, ' '
    	je   	Syntax_KW_Skip
   	cmp  	al, '.'
    	je   	Syntax_KW_Skip
    	cmp  	al, 9          ; tab ASCII 9
    	je   	Syntax_KW_Skip
    	cmp  	al, ','
    	je   	Syntax_KW_Skip
    	cmp  	al, '+'
    	je   	Syntax_KW_Skip
    	cmp  	al, '-'
    	je   	Syntax_KW_Skip
    	cmp  	al, '*'
    	je   	Syntax_KW_Skip
    	cmp  	al, '['
    	je   	Syntax_KW_Skip
    	cmp  	al, ']'
    	je   	Syntax_KW_Skip
    	cmp  	al, '('
    	je   	Syntax_KW_Skip
    	cmp  	al, ')'
    	je   	Syntax_KW_Skip
    	cmp  	al, ':'
    	je   	Syntax_KW_Skip
    	cmp  	al, ';'
    	je   	Syntax_KW_Done     ; resto è commento
    	cmp  	al, '"'
    	je   	Syntax_KW_Done     ; resto è stringa
	cmp	al, 39		   ; singolo apice
	je	Syntax_KW_Done

	; estrai i token - salva posizione assoluta
	mov	eax, nLineStart
	add	eax, i
	mov	nTokAbsStart, eax
	mov	nTokLen, 0

	; se è un punto - includiclo nel token (per .386, .IF ecc)
	cmp	al, '.'
	jne	Syntax_KW_Extract_Start
	mov	byte ptr [szToken], '.'
	mov	nTokLen, 1
	inc	i

	; estrai i token carattere per carattere
Syntax_KW_Extract_Start:
Syntax_KW_Extract:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_KW_GotToken

	mov	esi, pszLine
	add	esi, i
	mov	al, [esi]
	
	; salta caratteri extended ASCII
    	test 	al, 80h
    	jnz  	Syntax_KW_GotToken

	; fine token se separatore
	cmp	al, ' '
	je	Syntax_KW_GotToken
	cmp	al, 9			; tab
	je	Syntax_KW_GotToken
	cmp	al, ','
	je 	Syntax_KW_GotToken
	cmp	al, '.'
	je 	Syntax_KW_GotToken
	cmp	al, '+'
	je 	Syntax_KW_GotToken
	cmp	al, '-'
	je 	Syntax_KW_GotToken
	cmp	al, '*'
	je 	Syntax_KW_GotToken
	cmp	al, '['
	je 	Syntax_KW_GotToken
	cmp	al, ']'
	je 	Syntax_KW_GotToken
 	cmp  	al, '('
    	je   	Syntax_KW_GotToken
    	cmp  	al, ')'
    	je   	Syntax_KW_GotToken
    	cmp  	al, ':'
	je   	Syntax_KW_GotToken
	cmp	al, ';'
	je	Syntax_KW_GotToken		; il resto è commento
	cmp  	al, '"'
    	je   	Syntax_KW_GotToken
	cmp	al, 39
	je 	Syntax_KW_GotToken
    	cmp  	al, 0
	je	Syntax_KW_GotToken		

	; converti in maiuscolo per confronto
	cmp	al, 'a'
	jl	Syntax_KW_StoreChar
	cmp	al, 'z'
	jg	Syntax_KW_StoreChar
	sub 	al, 20h

Syntax_KW_StoreChar:
	; scrivi in szToken usando indice esplicito (no edi — viene corrotto)
	mov	ecx, nTokLen
	cmp	ecx, 63
	jge	Syntax_KW_GotToken
	lea	edx, szToken
	add	edx, ecx
	mov	[edx], al
	inc	nTokLen
	inc	i
	jmp	Syntax_KW_Extract

Syntax_KW_GotToken:
	; termina la stringa
	mov	ecx, nTokLen
	lea	edx, szToken
	add	edx, ecx
	mov	byte ptr [edx], 0

	; token vuoto?
	cmp	nTokLen, 0
	je	Syntax_KW_Skip

	; controlla se token è un registro
	invoke	Syntax_IsRegister, ADDR szToken
	cmp	eax, 1
	jne	Syntax_KW_CheckMnemonic
	mov	eax, nTokAbsStart
	add	eax, nTokLen
	invoke	Syntax_SetColor, hRE, nTokAbsStart, eax, g_Theme.clrRegister
	jmp	Syntax_KW_Loop

Syntax_KW_CheckMnemonic:
	invoke	Syntax_IsMnemonic, ADDR szToken
	cmp	eax, 1
	jne	Syntax_KW_CheckDirective
	mov	eax, nTokAbsStart
	add	eax, nTokLen
	invoke	Syntax_SetColor, hRE, nTokAbsStart, eax, g_Theme.clrMnemonic
	jmp	Syntax_KW_Loop

Syntax_KW_CheckDirective:
	invoke	Syntax_IsDirective, ADDR szToken
	cmp	eax, 1
	jne	Syntax_KW_Loop
	mov	eax, nTokAbsStart
	add	eax, nTokLen
	invoke	Syntax_SetColor, hRE, nTokAbsStart, eax, g_Theme.clrDirective
	jmp	Syntax_KW_Loop

Syntax_KW_Skip:
	inc	i
	jmp	Syntax_KW_Loop

Syntax_KW_Done:
	ret
Syntax_HighlightKeywords endp

;
; Syntax_IsRegister / Syntax_IsMnemonic / Syntax_IsDirective
;
; Controlla se un token appartiene alla categoria
;
; In:	pszToken = puntaotre alla stringa maiuscola
;
; Out:	eax = 1 trovato / 0 non trovato
;
Syntax_IsRegister proc pszToken:DWORD
	mov	edi, offset szRegisters

Syntax_IsReg_Loop:
	mov	al, [edi]
	test	al, al
	jz	Syntax_IsReg_No		; raggiunta la fine della lista
	
	push	edi
	invoke	lstrcmp, pszToken, edi
	pop	edi
	test	eax, eax
	jz	Syntax_IsReg_Yes
	
	; avanza al prossimo elemento
	add	edi, 16	
	jmp	Syntax_IsReg_Loop

Syntax_IsReg_Yes:
	mov	eax, 1
	ret

Syntax_IsReg_No:
	xor	eax, eax
	ret
Syntax_IsRegister endp

Syntax_IsMnemonic proc pszToken:DWORD
	mov	edi, offset szMnemonics 

Syntax_IsMnem_Loop:
	mov	al, [edi]
	test	al, al
	jz	Syntax_IsMnem_No		; raggiunta la fine della lista
	
	push	edi
	invoke	lstrcmp, pszToken, edi
	pop	edi
	test	eax, eax
	jz	Syntax_IsMnem_Yes
	
	; avanza al prossimo elemento
	add	edi, 16
	jmp	Syntax_IsMnem_Loop

Syntax_IsMnem_Yes:
	mov	eax, 1
	ret

Syntax_IsMnem_No:
	xor	eax, eax
	ret
Syntax_IsMnemonic endp

Syntax_IsDirective proc pszToken:DWORD
	mov	edi, offset szDirectives

Syntax_IsDir_Loop:
	mov	al, [edi]
	test	al, al
	jz	Syntax_IsDir_No		; raggiunta la fine della lista
	
	push	edi
	invoke	lstrcmp, pszToken, edi
	pop	edi	
	test	eax, eax
	jz	Syntax_IsDir_Yes
	
	; avanza al prossimo elemento
	add	edi, 16
	jmp	Syntax_IsDir_Loop

Syntax_IsDir_Yes:
	mov	eax, 1
	ret

Syntax_IsDir_No:
	xor	eax, eax
	ret
Syntax_IsDirective endp

;
; Syntax_HighlightDotDirectives
;
; Colora direttive che iniziano con il punto (.368, .IF ecc)
;
Syntax_HighlightDotDirectives proc hRE:DWORD, pszLine:DWORD, nLineStart:DWORD, nLineLen:DWORD
LOCAL 	i:DWORD
LOCAL	szToken[16]:BYTE
LOCAL 	nTokStart:DWORD
LOCAL	nTokLen:DWORD

	mov	i, 0

Syntax_Dot_Loop:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_Dot_Done

	mov	esi, pszLine
	add	esi, i
	mov	al, [esi]

	cmp	al, ';'
	je	Syntax_Dot_Done
	cmp	al, '.'
	jne 	Syntax_Dot_Skip

	; trovato il punto - salva posizione
	mov	eax, nLineStart
	add	eax, i
	mov	nTokStart, eax

	; metti il punto nel buffer
	mov	byte ptr [szToken], '.'
	mov	nTokLen, 1
	inc	i
	
	;estrai il resto del token
Syntax_Dot_Extract:
	mov	eax, i
	cmp	eax, nLineLen
	jge	Syntax_Dot_GotToken
	
	mov	esi, pszLine
	add	esi, i
	mov	al, [esi]

	; fine token
	cmp	al, ' '
	je	Syntax_Dot_GotToken
	cmp	al, 9
	je	Syntax_Dot_GotToken
	cmp	al, ','
	je	Syntax_Dot_GotToken
	cmp	al, ';'
	je	Syntax_Dot_GotToken
	cmp	al, 0
	je	Syntax_Dot_GotToken

	; converti maiuscolo
	cmp	al, 'a'
	jl	Syntax_Dot_Store
	cmp	al, 'z'
	jg	Syntax_Dot_Store
	sub	al, 20h

Syntax_Dot_Store:
	mov	ecx, nTokLen
	cmp	ecx, 15
	jge	Syntax_Dot_GotToken
	lea	edx, szToken
	add	edx, ecx
	mov	[edx], al
	inc	nTokLen
	inc	i
	jmp	Syntax_Dot_Extract

Syntax_Dot_GotToken:
	; termina stringa
	mov	ecx, nTokLen
	lea	edx, szToken
	add	edx, ecx
	mov	byte ptr [edx], 0
	
	; cerca nella lista delle direttive
	push	edi
	invoke	Syntax_IsDirective, ADDR szToken
	pop	edi
	cmp	eax, 1
	jne	Syntax_Dot_Loop

	; colorala
	mov	eax, nTokStart
	add	eax, nTokLen
	invoke	Syntax_SetColor, hRE, nTokStart, eax, g_Theme.clrDirective
	jmp	Syntax_Dot_Loop

Syntax_Dot_Skip:
	inc	i
	jmp	Syntax_Dot_Loop

Syntax_Dot_Done:
	ret
Syntax_HighlightDotDirectives endp
