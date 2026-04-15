;
; Struttura tema colori
; Tutti i colori sono COLORREF (00BBGGRR)
;
THEME struct
	; Editor
	clrBackground		dd 0
	clrForeground		dd 0
	clrCurrentLineBg	dd 0
	clrSelectionBg		dd 0

	; Syntax highlighting
	clrMnemonic		dd 0
	clrRegister		dd 0
	clrDirective		dd 0
	clrComment		dd 0
	clrString		dd 0
	clrNumber		dd 0
	clrOperator		dd 0
	clrLabel		dd 0

	; token validazione
	clrSquiggly		dd 0
	
	; Guide identazione
	clrIndentGuide		dd 0
	
	; Tab bar
	clrTabActiveBg		dd 0
	clrTabActiveFg		dd 0
	clrTabInactiveBg	dd 0
	clrTabInactiveFg	dd 0
	clrTabModified		dd 0
	clrTabBorder		dd 0
	clrTabBarBg		dd 0

	; UI generale
	clrStatusbarBg		dd 0
	clrStatusbarFg		dd 0
	clrSplitter		dd 0

	; Metadati
	szThemeName		dd 64 dup (0)
	nThemeId		dd 0
THEME ends

THEME_LIGHT	equ 0
THEME_DARK	equ 1
THEME_CUSTOM	equ 2
