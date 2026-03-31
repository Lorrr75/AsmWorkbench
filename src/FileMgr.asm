.code

;
; FileMgr_New
;
; Crea una nuovo documento vuoto e aggiunge la tab
;
; Out:	eax = 1 successo / 0 errore
;
FileMgr_New	proc
LOCAL	szTitle[256]:BYTE
	
	; costruisce il titolo "Senza nome N"
	invoke	wsprintf, ADDR szTitle, ADDR szNewFileTitle, g_nTabCount

	; aggiunge la tab
	invoke	TabBar_AddTab, NULL, ADDR szTitle, 1
	cmp	eax, -1
	je	FileMgr_New_Error
	
	; svuota l'editor
	invoke	SetWindowText, g_hEditor, NULL

	; porta il focus sull'editor
	invoke	SetFocus, g_hEditor

	mov	eax, 1
	ret

FileMgr_New_Error:
	ret
FileMgr_New	endp

;
; FileMgr_Opoen
;
; Apre un file esistente con dialog standard
;
; Out:	eax = 1 successo / 0 errore
;
FileMgr_Open	proc
LOCAL	ofn:OPENFILENAME
LOCAL	szFilePath[MAX_PATH]:BYTE
LOCAL	szTitle[256]:BYTE

	; azzera la struttura
	lea	edi, ofn
	mov	ecx, sizeof OPENFILENAME
	xor	eax, eax
	rep	stosb

	; azzera il buffer path
	lea	edi, szFilePath
	mov	ecx, MAX_PATH
	rep	stosb

	; riempe la struttura OPENFILENAME
	mov	ofn.lStructSize, sizeof OPENFILENAME
	mov	eax, g_hMainWnd
	mov	ofn.hwndOwner, eax
	lea	eax, szFilePath
	mov	ofn.lpstrFile, eax
	mov	ofn.nMaxFile, MAX_PATH
	mov	ofn.lpstrFilter, offset szFileFilter
	mov	ofn.nFilterIndex, 1
	mov	ofn.Flags, OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST

	; mostra il dialog
	invoke	GetOpenFileName, ADDR ofn
	cmp	eax, 0
	je 	FileMgr_Open_Cancel
	
	; estrae solo il nmome file per il titolo della tab
	invoke	lstrcpy, ADDR szTitle, ADDR szFilePath
	invoke	PathFindFileName, ADDR szTitle
	; eax, punta al nome file dentro szTitle - lo usiamo come titolo tab

	; aggiunge la tab
	invoke	TabBar_AddTab, ADDR szFilePath, eax, 0

	; carica il contenuto del file RichEdit
	invoke	FileMgr_LoadFile, ADDR szFilePath

	invoke	SetFocus, g_hEditor

	mov	eax, 1
	ret

FileMgr_Open_Cancel:	
	mov	eax, 0
	ret
FileMgr_Open	endp

;
; FileMgr_Load
;
; Carica un file dal disco nel RichEdit
;
; In:	pszPath = path completo del file
;
; Out:	eax = 1 successo / 0 errore
;
FileMgr_LoadFile proc pszPath:DWORD
LOCAL	hFile:HANDLE
LOCAL	dwSize:DWORD
LOCAL	hMem:HANDLE
LOCAL	pMem:DWORD

	invoke	CreateFile, pszPath, GENERIC_READ, FILE_SHARE_READ, NULL, \
			    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL

	cmp	eax, INVALID_HANDLE_VALUE
	je	FileMgr_LoadFile_Error
	mov	hFile, eax

	; dimensione del file
	invoke	GetFileSize, hFile, NULL
	mov	dwSize, eax

	; alloca la memoria
	invoke	GlobalAlloc, GMEM_MOVEABLE, dwSize
	mov	hMem, eax
	invoke	GlobalLock, hMem
	mov	pMem, eax

	; legge il file
	invoke	ReadFile, hFile, pMem, dwSize, ADDR dwSize, NULL
	invoke	CloseHandle, hFile

	; invia il testo al RichEdit
	invoke	SetWindowText, g_hEditor, pMem

	invoke	GlobalUnlock, hMem
	invoke	GlobalFree, hMem

	mov	eax, 1
	ret

FileMgr_LoadFile_Error:
	mov	eax, 0
	ret
FileMgr_LoadFile endp

;
; FileMgr_Save
;
; Salva il documento corrente
;
; Out:	eax = 1 successo / 0 errore/annullato
;
FileMgr_Save	proc
LOCAL	nIdx:DWORD

	; recupera indice tab attiva
	mov	eax, g_nActiveTab
	mov	nIdx, eax

	; controlla puntatore al TABITEM corrente
	mov	ecx, sizeof TABITEM
	mul	ecx
	add	eax, offset g_TabItems
	mov	edx,eax				; edx = puntatore TABITEM

	; è un nuovo file (mai salvato?)
	mov	eax, (TABITEM PTR [edx]).bNew
	cmp	eax, 1
	je	FileMgr_Save_AsNew

	; ha un path? (salvataggio diretto)
	lea	eax, (TABITEM PTR[edx]).szFilePath
	mov	ecx, [eax]
	cmp	ecx, 0
	je	FileMgr_Save_AsNew

	; salva direttamente sul path esistente
	invoke	FileMgr_WriteFile, edx
	jmp	FileMgr_Save_Done

FileMgr_Save_AsNew:
	; nessun path - apri la dialog Salva con nome
	invoke	FileMgr_SaveAs
	ret

FileMgr_Save_Done:
	ret
FileMgr_Save	endp

;
; FileMgr_SaveAs
;
; Salva con nome - mostra dialog
;
; Out:	eax = 1 successo / 0 annullato
;
FileMgr_SaveAs	proc
LOCAL	ofn:OPENFILENAME
LOCAL	szFilePath[MAX_PATH]:BYTE
LOCAL	nIdx:DWORD

	; azzera struttura e buffer
	lea	edi, ofn
	mov	ecx, sizeof OPENFILENAME
	xor	eax, eax
	rep	stosb
	
	lea 	edi, szFilePath
	mov	ecx, MAX_PATH
	rep	stosb

	mov	ofn.lStructSize, sizeof OPENFILENAME
	mov	eax, g_hMainWnd
	mov	ofn.hwndOwner, eax
	lea	eax, szFilePath
	mov	ofn.lpstrFile, eax
	mov	ofn.nMaxFile, MAX_PATH
	mov	ofn.lpstrFilter, offset szFileFilter
	mov	ofn.nFilterIndex, 1
	mov	ofn.lpstrDefExt, offset szDefExt
	mov	ofn.Flags, OFN_OVERWRITEPROMPT or OFN_PATHMUSTEXIST

	invoke	GetSaveFileName, ADDR ofn
	cmp	eax, 0
	je	FileMgr_SaveAs_Cancel

	; ricalcola il puntatore TABITEM - edx potrebbe essere corrotto da chiamate precedenti
	mov	eax, g_nActiveTab
	mov	ecx, sizeof TABITEM
	mul	ecx
	add	eax, offset g_TabItems
	mov	edx, eax			; edx = puntatore TABITEM sicuro

	; copia path nella struttura
	invoke	lstrcpy, edx, ADDR szFilePath

	; ricalcola edx - lstrcpy lo ha corrotto
	mov	eax, g_nActiveTab
	mov	ecx, sizeof TABITEM
	mul	ecx
	add	eax, offset g_TabItems
	mov	edx, eax
 
	; aggiorna titolo tab con solo il nome file
	invoke	lstrcpy, ADDR szFilePath, edx
	invoke	PathFindFileName, ADDR szFilePath
	
	; estrai solo nome e file e aggiorna szTitle
	invoke	PathFindFileName, edx		; eax = puntatore al nome del file dentro szFilePath
	lea	ecx, (TABITEM PTR [edx]).szTitle
	invoke	lstrcpy, ecx, eax

	; ricalcola edx ancora - lstrcpy potrebbe averlo corrotto di nuovo
	mov	eax, g_nActiveTab
	mov	ecx, sizeof TABITEM
	mul	ecx
	add	eax, offset g_TabItems
	mov	edx, eax

	; non è più un nuovo file
	mov	(TABITEM PTR [edx]).bNew, 0
	
	; salva il file
	invoke	FileMgr_WriteFile, edx
	
	; ridisegna le tab per aggiornare il titolo
	invoke	InvalidateRect, g_hTabBar, NULL, TRUE

	mov	eax, 1
	ret

FileMgr_SaveAs_Cancel:
	mov	eax, 0	
	ret
FileMgr_SaveAs	endp

;
; FileMgr_WriteFile
;
; Scrive il contenuto del RichEdit su disco
;
; IN:	pItem = puntatore al TABITEM
;
; Out:	eax = 1 successo / 0 errore
;
FileMgr_WriteFile	proc pItem:DWORD
LOCAL	hFile:HANDLE
LOCAL	dwSize:DWORD
LOCAL	hMem:HANDLE
LOCAL	pMem:DWORD

	; recupera dimensione testo
	invoke	SendMessage, g_hEditor, WM_GETTEXTLENGTH, 0, 0
	mov	dwSize, eax
	inc	eax				; aggiunge spazione per il terminatore

	; alloca memoria
	invoke	GlobalAlloc, GMEM_MOVEABLE, eax
	mov	hMem, eax
	invoke	GlobalLock, hMem
	mov	pMem, eax

	; legge il testo dal RichEdit
	invoke	SendMessage, g_hEditor, WM_GETTEXT, dwSize, pMem

	; apre / crea il file
	invoke	CreateFile, pItem, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
	cmp	eax, INVALID_HANDLE_VALUE
	je	FileMgr_WriteFile_Error
	mov	hFile, eax
	
	; TODO: convertire da UTF-16 a ANSI/UTF-8 prima di scrivere
    	; per ora scrittura diretta — causa caratteri Unicode su disco
	invoke 	WriteFile, hFile, pMem, dwSize, ADDR dwSize, NULL
	invoke	CloseHandle, hFile

	; segna il documento come non modificato
	mov	eax, pItem
	mov	(TABITEM PTR [eax]).bModified, 0
	invoke	InvalidateRect, g_hTabBar, NULL, TRUE

	invoke	GlobalUnlock, hMem
	invoke	GlobalFree, hMem
	
	mov	eax, 1
	ret

FileMgr_WriteFile_Error:
	invoke	GlobalUnlock, hMem
	invoke	GlobalFree, hMem

	mov	eax, 0
	ret
	
FileMgr_WriteFile	endp