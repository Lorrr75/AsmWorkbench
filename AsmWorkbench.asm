.386

.model	flat, stdcall
option casemap:none

;
; sezione inclusione codice sorgente e "creare un unico file" da compilare
;
include	inc\CommonHeader.inc		; Qui ci saranno gli header che serviranno
include inc\CommonLib.inc		; Qui ci sono le librerie da importare
include inc\Proto.inc			; Qui inseriremo i prototipi di funzioni

include inc\constants.inc 		; Qui ci saranno le costanti (i tipi EQU ecc)
include inc\structs.inc			; Qui ci saranno tutte le strutture
					; per la gestione delle finestre
include inc\globals.inc			; Qui ci saranno tutte le variabili globali del programma

.code

; punto d'ingresso del programma
main:

	invoke	GetModuleHandle, NULL		; ottiene l'handle del programma 
	mov	hInstance, eax			; memorizziamo l'handle per sicurezza

	invoke	GetCommandLine			; ottiene la linea di comando. se il tuo programma non processa
	mov	CommandLine, eax		; la linea di comando puoi cancellare queste 2 linee

	
	; come per il c++ chiamaiamo il WinMain come corpo del programma principale
	invoke 	WinMain, hInstance, NULL, ADDR CommandLine, SW_SHOWNORMAL

	; programma terminato con risultato il eax, restituisce il controllo a Windows
	invoke	ExitProcess, eax

; alleghiamo altri file sorgente per la compilazione

include src\WinMain.asm			; corpo principale del programma
include src\MainWndProc.asm		; funzione callback gestione messaggi finestra principale
include src\RegisterWindowMainClass.asm	; funzione registrazione classe della finestra
include src\InitIde.asm			; funzione di inizializzazione 
;include src\DeInitIde.asm			; funzione di cancellazione dai inizializzati
include src\TabBar.asm			; funzione riguardanti la Tab Bar


; qui indichiamo la fine del file con il punto d'ingresso del programma
end	main