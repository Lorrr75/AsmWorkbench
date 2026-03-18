# AsmWorkbench — Documento di Architettura

> Versione: 1.0  
> Stato: Progettazione iniziale  
> Lingua: Italiano (versione inglese prevista)  
> Licenza: EUPL v1.2

\---

## Indice

1. [Visione del progetto](#1-visione-del-progetto)
2. [Stack tecnologico](#2-stack-tecnologico)
3. [Struttura del repository](#3-struttura-del-repository)
4. [Moduli e responsabilità](#4-moduli-e-responsabilità)
5. [Strutture dati](#5-strutture-dati)
6. [Layout interfaccia utente](#6-layout-interfaccia-utente)
7. [Architettura della Tab Bar](#7-architettura-della-tab-bar)
8. [AsmSense — Paragonabile a IntelliSense per Assembly](#8-asmsense--intellisense-per-assembly)
9. [Resource Editor](#9-resource-editor)
10. [Integrazione Assembler](#10-integrazione-assembler)
11. [Integrazione Debugger](#11-integrazione-debugger)
12. [Flusso messaggi Win32](#12-flusso-messaggi-win32)
13. [Convenzioni di codice](#13-convenzioni-di-codice)
14. [Roadmap di sviluppo](#14-roadmap-di-sviluppo)
15. [Autori e partner](#15-autori-e-partner)

\---

## 1\. Visione del progetto

**AsmWorkbench** è un ambiente di sviluppo integrato (IDE) dedicato alla programmazione Assembly x86 su Windows, scritto interamente in Assembly x86 con MASM32.

### Obiettivi principali

* Offrire un unico strumento completo per chi programma in Assembly x86 su Windows
* Eliminare la necessità di usare un insieme eterogeneo di tool separati
* Ispirarsi all'esperienza utente di Visual Studio, adattandola al mondo Assembly
* Mantenere l'eseguibile leggero, autonomo e senza dipendenze esterne pesanti

### Cosa NON è AsmWorkbench

* Non è un IDE generico adattato all'Assembly
* Non è un wrapper attorno a tool esistenti
* Non è scritto in C, C++ o linguaggi di alto livello

### Tre progetti collegati

```
┌─────────────────┐       ┌─────────────────┐     ┌─────────────────┐
│   AsmWorkbench  │────▶│    Assembler   │──▶│    Debugger     │
│   (questo repo) │       │  (repo separato)│     │ (integrato qui) │
└─────────────────┘       └─────────────────┘     └─────────────────┘
       IDE                    Compilatore            Step-by-step
```

\---

## 2\. Stack tecnologico

|Componente|Tecnologia|
|-|-|
|Linguaggio|Assembly x86 (MASM32)|
|Assembler di sviluppo|MASM32 SDK|
|GUI|Win32 API native|
|Editor di testo|RichEdit (richiamato via Win32)|
|Astrazione GUI|Macro MASM condivise (`macros.inc`)|
|Build system|Script `make.bat`|
|Target OS|Windows 7 e superiore|
|Dipendenze runtime|Solo DLL standard di Windows|

### Perché Win32 + macro MASM

La Win32 API pura è verbosa in Assembly. Invece di costruire un framework completo (troppo lavoro) o usare un toolkit esterno (dipendenza), si usano **macro MASM** che astraggono i pattern ripetitivi mantenendo controllo totale. È l'approccio naturale per MASM32.

Esempio del principio:

```masm
; Senza macro — verboso
push MB\_OK
push offset szTitle
push offset szMsg
push 0
call MessageBoxA

; Con macro — leggibile
MSG\_BOX 0, szMsg, szTitle, MB\_OK
```

\---

## 3\. Struttura del repository

```
AsmWorkbench/
│
├── src/                    ← Sorgenti Assembly
│   ├── main.asm            ← Entry point, WinMain, message loop
│   ├── mainwnd.asm         ← Finestra principale + WndProc
│   ├── tabbar.asm          ← Tab bar custom owner-draw
│   ├── editor.asm          ← Wrapper RichEdit
│   ├── syntax.asm          ← Syntax highlighting
│   ├── toolbar.asm         ← Toolbar
│   ├── statusbar.asm       ← Barra di stato
│   ├── filemgr.asm         ← Gestione file (open/save/dialogs)
│   ├── project.asm         ← Gestione progetto .awb
│   ├── panelmgr.asm        ← Layout pannelli ridimensionabili
│   ├── config.asm          ← Configurazione (file INI)
│   ├── symtable.asm        ← Parser e database simboli (AsmSense)
│   ├── asmsense.asm        ← UI autocomplete e parameter hints
│   ├── reseditor.asm       ← Resource editor visuale
│   └── macros.inc          ← Macro Win32 condivise
│
├── inc/                    ← File include condivisi
│   ├── globals.inc         ← Variabili globali condivise tra moduli
│   ├── structs.inc         ← Strutture dati custom
│   ├── constants.inc       ← ID menu, controlli, costanti IDE
│   └── apidb.inc           ← Database Win32 API (AsmSense)
│
├── res/                    ← Risorse Windows
│   ├── resource.rc         ← Menu, dialogs, stringhe, icone
│   ├── toolbar.bmp         ← Bitmap pulsanti toolbar
│   └── icons/              ← File icone .ico
│
├── build/                  ← Output compilazione (non versionato)
│   ├── AsmWorkbench.exe
│   └── AsmWorkbench.res
│
├── docs/                   ← Documentazione tecnica
│   ├── ARCHITECTURE.md     ← Questo file
│   └── CONVENTIONS.md      ← Convenzioni di codice (futuro)
│
├── make.bat                ← Script di build
├── README.md               ← Presentazione del progetto
└── LICENSE                 ← Testo EUPL v1.2
```

\---

## 4\. Moduli e responsabilità

### `main.asm` — Entry point

* Contiene `WinMain`
* Inizializza le classi finestra
* Avvia il message loop principale
* Carica la configurazione all'avvio

### `mainwnd.asm` — Finestra principale

* Registra e crea la finestra principale
* Gestisce `WndProc` (procedura messaggi)
* Coordina il ridimensionamento dei sottocomponenti
* Gestisce `WM\_CREATE`, `WM\_SIZE`, `WM\_CLOSE`, `WM\_DESTROY`

### `tabbar.asm` — Tab bar custom

* Disegna le tab interamente con `WM\_DRAWITEM` (owner-draw)
* Gestisce il simbolo `●` per file modificati
* Gestisce il pulsante `×` per chiusura tab
* Supporta click sinistro (attiva), click centrale (chiude)
* Gestisce l'overflow con frecce di scorrimento

### `editor.asm` — Wrapper RichEdit

* Crea e gestisce il controllo RichEdit
* Espone funzioni di alto livello (GetText, SetText, GetLine, GetCol...)
* Intercetta `EN\_CHANGE` per notificare le modifiche
* Gestisce il flag `bModified` del documento corrente

### `syntax.asm` — Syntax highlighting

* Si aggancia a `EN\_CHANGE` via `editor.asm`
* Applica colori tramite `EM\_SETCHARFORMAT`
* Riconosce: mnemonici x86, registri, direttive MASM, commenti (`;`), stringhe, costanti numeriche (decimali, esadecimali, binarie)

### `toolbar.asm` — Barra degli strumenti

* Crea la toolbar con `CreateToolbarEx`
* Gestisce i pulsanti: Nuovo, Apri, Salva, Build, Esegui, Stop
* Aggiorna lo stato abilitato/disabilitato dei pulsanti in base al contesto

### `statusbar.asm` — Barra di stato

* Mostra: numero riga, colonna, flag modificato, encoding, modalità (INS/OVR), nome file
* Si aggiorna ad ogni movimento del cursore via `EN\_SELCHANGE`

### `filemgr.asm` — Gestione file

* Implementa: Nuovo, Apri, Salva, Salva con nome, Chiudi
* Gestisce i dialog standard (`GetOpenFileName`, `GetSaveFileName`)
* Controlla il flag `bModified` prima di chiudere o sovrascrivere
* Rileva la codifica del file (ANSI/UTF-8)

### `project.asm` — Gestione progetto

* Gestisce il file `.awb` (formato INI esteso)
* Mantiene la lista dei file del progetto
* Visualizza il Project Tree nel pannello laterale
* Ricorda i file aperti all'ultima sessione

### `panelmgr.asm` — Gestione pannelli

* Gestisce il layout ridimensionabile dei pannelli
* Pannelli principali: Project Tree (sinistra), Editor (centro), Output/Errori/Simboli (basso)
* Implementa i divisori (splitter) trascinabili

### `config.asm` — Configurazione

* Legge e scrive un file INI (`AsmWorkbench.ini`)
* Gestisce: tema colori, dimensione font, tab size, percorsi, dimensioni finestra

### `symtable.asm` — Database simboli (AsmSense)

* Scansiona i file sorgente del progetto
* Costruisce e aggiorna la tabella dei simboli
* Riconosce: `PROC`, `ENDP`, label, `EQU`, variabili (`.data`), macro

### `asmsense.asm` — Autocomplete (AsmSense)

* Mostra un popup `ListBox` owner-draw sotto il cursore
* Si attiva dopo 2+ caratteri alfanumerici
* Si attiva dopo `INVOKE ` per i parameter hints
* Attinge da: mnemonici x86 integrati, registri, `symtable`, `apidb.inc`

### `reseditor.asm` — Resource Editor

* Designer visuale per risorse Windows
* Supporta: Dialog, Menu, StringTable, icone
* Genera il file `.rc` corrispondente
* Anteprima in tempo reale del dialog

\---

## 5\. Strutture dati

Definite in `inc/structs.inc`:

```masm
MAX\_DOCS    equ 32          ; massimo documenti aperti simultaneamente

;---------------------------------------------------
; Documento aperto in una tab
;---------------------------------------------------
DOCUMENT struct
    szFilePath   db  MAX\_PATH dup(0)  ; path completo su disco
    szTitle      db  256 dup(0)       ; nome visualizzato nella tab
    hRichEdit    dd  0                 ; handle controllo RichEdit
    bModified    dd  0                 ; 0 = pulito / 1 = modificato (●)
    bNew         dd  0                 ; 1 = mai salvato su disco
    nCurLine     dd  0                 ; riga cursore corrente (1-based)
    nCurCol      dd  0                 ; colonna cursore corrente (1-based)
    nTabSize     dd  4                 ; dimensione tab (default 4)
    nScrollPos   dd  0                 ; posizione scroll salvata
    nEncoding    dd  0                 ; 0=ANSI, 1=UTF-8
DOCUMENT ends

;---------------------------------------------------
; Progetto corrente — file .awb
;---------------------------------------------------
PROJECT struct
    szName       db  256 dup(0)              ; nome progetto
    szRootPath   db  MAX\_PATH dup(0)         ; cartella root
    szMainFile   db  MAX\_PATH dup(0)         ; file entry point
    nDocCount    dd  0                        ; numero documenti aperti
    hDocs        dd  MAX\_DOCS dup(0)         ; array handle DOCUMENT
PROJECT ends

;---------------------------------------------------
; Simbolo nel database AsmSense
;---------------------------------------------------
SYM\_PROC    equ 1
SYM\_LABEL   equ 2
SYM\_VAR     equ 3
SYM\_MACRO   equ 4
SYM\_API     equ 5
SYM\_EQU     equ 6

SYMBOL struct
    szName       db  128 dup(0)       ; nome simbolo
    nType        dd  0                 ; tipo (costanti SYM\_\*)
    szFile       db  MAX\_PATH dup(0)  ; file di definizione
    nLine        dd  0                 ; riga di definizione
    szSignature  db  256 dup(0)       ; firma per PROC e API
SYMBOL ends

;---------------------------------------------------
; Voce nel database Win32 API (apidb.inc)
;---------------------------------------------------
APIENTRY struct
    szName       db  64 dup(0)        ; nome API (es. "CreateWindowEx")
    nParams      dd  0                 ; numero parametri
    szParams     db  256 dup(0)       ; lista param separata da virgola
APIENTRY ends
```

\---

## 6\. Layout interfaccia utente

```
┌──────────────────────────────────────────────────────────────────┐
│  File  Modifica  Visualizza  Progetto  Build  Strumenti  Aiuto   │  ← Menu
├──────────────────────────────────────────────────────────────────┤
│  \[N]\[A]\[S]\[S+] │ \[Build]\[Esegui]\[Stop] │ \[AsmSense ON/OFF]       │  ← Toolbar
├──────────────────────────────────────────────────────────────────┤
│  \[main.asm]  \[utils.asm ●]  \[resource.rc]  \[+]                   │  ← Tab bar
├─────────────────────┬────────────────────────────────────────────┤
│                     │                                            │
│  Project Tree       │   Editor RichEdit                          │
│  ────────────────   │                                            │
│  ▼ MyProject        │   1  .386                                  │
│    ├ main.asm       │   2  .model flat, stdcall                  │
│    ├ utils.asm      │   3  option casemap:none                   │
│    └ resource.rc    │   4                                        │
│                     │   5  include windows.inc                   │
│                     │   6  include user32.inc                    │
│                     │   7  includelib user32.lib                 │
│                     │                                            │
├─────────────────────┴────────────────────────────────────────────┤
│  \[ ▼ Output ] \[ ▼ Errori ] \[ ▼ Simboli ]                         │  ← Tab panel
│  Compilazione completata — 0 errori, 0 warning                   │
├──────────────────────────────────────────────────────────────────┤
│  Ln 5   Col 12  │  ANSI  │  x86  │  INS  │  main.asm             │  ← Statusbar
└──────────────────────────────────────────────────────────────────┘
```

### Pannelli ridimensionabili

Tutti i divisori (splitter) sono trascinabili con il mouse:

* **Splitter verticale** — tra Project Tree ed Editor
* **Splitter orizzontale** — tra Editor e Panel inferiore

\---

## 7\. Architettura della Tab Bar

La tab bar è implementata interamente come controllo **owner-draw custom**, senza usare `WC\_TABCONTROL`, per avere pieno controllo su aspetto e comportamento.

### Anatomia di una tab

```
┌─────────────────────────────┐
│  📄  utils.asm   ●   ×    │  ← tab attiva, file modificato
└─────────────────────────────┘

┌─────────────────────────────┐
│  📄  main.asm        ×     │  ← tab inattiva, file pulito
└─────────────────────────────┘
```

### Comportamenti implementati

|Azione|Effetto|
|-|-|
|Click sinistro su tab|Attiva il documento|
|Click sul `×`|Chiude la tab (con dialogo se modificata)|
|Click centrale (scroll wheel)|Chiude la tab|
|Comparsa `●`|Quando `bModified = 1`|
|Scomparsa `●`|Dopo salvataggio (`bModified = 0`)|
|Click su `\[+]`|Nuovo documento vuoto|
|Overflow tab|Frecce di scorrimento sinistra/destra|
|Drag (futuro)|Riordina le tab|

### Dialogo di chiusura con file modificato

```
┌────────────────────────────────────────────┐
│  AsmWorkbench                              │
│                                            │
│  Il file "utils.asm" è stato modificato.   │
│  Vuoi salvare le modifiche prima           │
│  di chiudere?                              │
│                                            │
│   \[Salva]   \[Non salvare]   \[Annulla]      │
└────────────────────────────────────────────┘
```

\---

## 8\. AsmSense — Paragonabile a IntelliSense per Assembly

AsmSense è composto da tre livelli implementati in ordine crescente di complessità.

### Livello 1 — Autocomplete

Trigger: l'utente digita 2 o più caratteri alfanumerici.

Fonti consultate in ordine:

1. Mnemonici x86 (hardcoded in `asmsense.asm`)
2. Registri x86 (hardcoded)
3. Simboli del progetto corrente (`symtable.asm`)
4. API Win32 (`apidb.inc`)

```
Utente digita "CR"
       │
       ▼
┌─────────────────────┐
│  CALL               │
│  CMP                │
│  CreateWindowEx ◀-─┼── da apidb.inc
│  CreateFileA        │
│  ...                │
└─────────────────────┘
```

### Livello 2 — Parameter Hints

Trigger: l'utente scrive `INVOKE ` (spazio dopo INVOKE).

```
INVOKE CreateWindowEx, |
                       ▲
┌──────────────────────────────────────────────┐
│  CreateWindowEx(dwExStyle, lpClassName,      │
│                 lpWindowName, dwStyle,       │
│                 X, Y, nWidth, nHeight,       │
│                 hWndParent, hMenu,           │
│                 hInstance, lpParam)          │
└──────────────────────────────────────────────┘
```

### Livello 3 — Symbol Navigator

Pannello laterale (tab dedicata) che mostra tutti i simboli del file corrente con navigazione diretta alla riga di definizione.

### Struttura `apidb.inc`

```nasm
; Formato: nome API, numero parametri, firma
APIENTRY <"MessageBox",      4, "hWnd, lpText, lpCaption, uType">
APIENTRY <"CreateWindowEx", 12, "dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam">
APIENTRY <"VirtualAlloc",    4, "lpAddress, dwSize, flAllocationType, flProtect">
; ... (centinaia di voci, ampliabile)
```

\---

## 9\. Resource Editor

Il Resource Editor permette di progettare visualmente le risorse Windows e generare il corrispondente file `.rc`.

### Risorse supportate

|Tipo|Descrizione|
|-|-|
|`DIALOG`|Disegno visuale di finestre dialog|
|`MENU`|Editor albero del menu|
|`STRINGTABLE`|Tabella stringhe localizzabili|
|`ICON`|Gestione file `.ico`|
|`BITMAP`|Gestione file `.bmp`|

### Flusso di lavoro

```
Designer visuale  ──▶  Generazione .rc  ──▶  Compilazione (rc.exe)  ──▶  .res
```

### Integrazione con il progetto

Il file `.rc` generato viene aggiunto automaticamente al progetto `.awb` e incluso nel processo di build.

\---

## 10\. Integrazione Assembler

L'assembler è sviluppato in un repository separato e integrato in AsmWorkbench come strumento di build esterno (EXE chiamato da `panelmgr.asm` / `project.asm`).

### Flusso di build

```
Menu Build → Esegui Build
       │
       ▼
Salva tutti i file modificati
       │
       ▼
Chiama Assembler.exe con parametri progetto
       │
       ├── Successo ──▶ Mostra "Build OK" nel pannello Output
       │                Abilita pulsante Esegui/Debugger
       │
       └── Errori  ──▶ Mostra lista errori nel pannello Errori
                        Click su errore → salta alla riga nel file
```

### Formato output errori (da definire con il repo Assembler)

```
nomefile.asm(42): errore E001: simbolo non definito 'MyProc'
nomefile.asm(87): avviso W003: istruzione non raggiungibile
```

\---

## 11\. Integrazione Debugger

Il debugger è l'ultimo step della roadmap. Verrà integrato direttamente nella finestra principale come pannello aggiuntivo.

### Funzionalità previste

* Esecuzione step-by-step (Step In, Step Over, Step Out)
* Breakpoint sulla riga sorgente
* Visualizzazione registri (EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP, EIP)
* Visualizzazione flag (ZF, CF, OF, SF, PF)
* Ispezione memoria con dump esadecimale
* Visualizzazione stack
* Disassembly in tempo reale

### Layout con debugger attivo

```
├─────────────────────┬────────────────────────────────────────────┤
│  Registri           │   Editor (con freccia riga corrente)       │
│  ────────────────   │                                            │
│  EAX = 00000001     │  ▶  42  mov eax, \[ebp+8]                  │
│  EBX = 00401000     │     43  push eax                           │
│  ECX = 0000000F     │     44  call MyProc                        │
│  ...                │                                            │
├─────────────────────┴────────────────────────────────────────────┤
│  Stack              │   Memoria (dump hex)                       │
│  0019FF80: ...      │   00401000: 55 8B EC 83 ...                │
└──────────────────────────────────────────────────────────────────┘
```

\---

## 12\. Flusso messaggi Win32

```
WinMain
  │
  ├─► RegisterClass    (mainwnd.asm)
  ├─► CreateMainWindow
  │     ├─► CreateToolbar      (toolbar.asm)
  │     ├─► CreateTabBar       (tabbar.asm)
  │     ├─► CreateRichEdit     (editor.asm)
  │     ├─► CreateStatusBar    (statusbar.asm)
  │     ├─► CreateProjectTree  (project.asm)
  │     └─► CreateOutputPanel  (panelmgr.asm)
  │
  └─► Message Loop
        │
        ├─► WM\_CREATE       → inizializza tutti i sottocomponenti
        ├─► WM\_SIZE         → ridisegna layout (panelmgr.asm)
        ├─► WM\_COMMAND      → menu e toolbar (mainwnd.asm)
        ├─► WM\_NOTIFY       → eventi da RichEdit e Tab Bar
        ├─► WM\_DRAWITEM     → ridisegna tab custom (tabbar.asm)
        ├─► WM\_KEYDOWN      → shortcut tastiera
        ├─► WM\_CLOSE        → controlla file non salvati
        └─► WM\_DESTROY      → cleanup + PostQuitMessage
```

\---

## 13\. Convenzioni di codice

### Nomenclatura

```nasm
; Procedure: PascalCase con prefisso modulo
Editor\_GetCurrentLine  proc
TabBar\_DrawTab         proc
AsmSense\_ShowPopup     proc

; Variabili globali (globals.inc): prefisso g\_
g\_hMainWnd     dd 0       ; handle finestra principale
g\_hRichEdit    dd 0       ; handle RichEdit corrente
g\_nDocCount    dd 0       ; numero documenti aperti

; Variabili locali: prefisso lv\_ (local var)
lv\_hDC         dd 0
lv\_nLen        dd 0

; Costanti (constants.inc): UPPER\_SNAKE\_CASE
IDM\_FILE\_NEW     equ 1001
IDM\_FILE\_OPEN    equ 1002
IDM\_BUILD\_BUILD  equ 2001
```

### Struttura di una procedura

```nasm
;---------------------------------------------------
; NomeModulo\_NomeProcedura
; Descrizione: cosa fa questa procedura
; Input:  parametro1 = descrizione
;         parametro2 = descrizione
; Output: EAX = risultato / 0 se errore
; Modifica: EBX, ECX (lista registri modificati)
;---------------------------------------------------
NomeModulo\_NomeProcedura proc param1:DWORD, param2:DWORD
    LOCAL lv\_temp:DWORD

    ; corpo della procedura

    ret
NomeModulo\_NomeProcedura endp
```

### Commenti

* Ogni file inizia con un'intestazione che descrive il modulo
* Ogni procedura ha l'intestazione standard sopra descritta
* I commenti inline spiegano il "perché", non il "cosa"
* La lingua dei commenti è **italiano** nella versione corrente

\---

## 14\. Roadmap di sviluppo

|Step|Modulo|Obiettivo|Stato|
|:-:|-|-|:-:|
|1|`main.asm` + `mainwnd.asm`|Finestra principale con menu base|⬜|
|2|`tabbar.asm`|Tab bar custom owner-draw con ● e ×|⬜|
|3|`editor.asm`|RichEdit embedded con gestione resize|⬜|
|4|`filemgr.asm`|New / Open / Save / Save As|⬜|
|5|`statusbar.asm`|Riga, colonna, flag modificato|⬜|
|6|`syntax.asm`|Syntax highlighting mnemonici e registri|⬜|
|7|`toolbar.asm`|Toolbar con azioni principali|⬜|
|8|`project.asm`|Progetto `.awb` e project tree|⬜|
|9|`panelmgr.asm`|Pannelli Output / Errori / Simboli|⬜|
|10|Build|Integrazione assembler esterno|⬜|
|11|`symtable.asm`|Parser simboli del progetto|⬜|
|12|`asmsense.asm`|Autocomplete + Parameter Hints|⬜|
|13|Symbol Navigator|Pannello simboli con navigazione|⬜|
|14|`reseditor.asm`|Resource editor visuale|⬜|
|15|Debugger|Integrazione debugger step-by-step|⬜|

Legenda: ⬜ Da fare · 🔄 In corso · ✅ Completato

\---

## 15\. Autori e partner

**Ideazione, progettazione e sviluppo**
Sviluppatore principale e ideatore del progetto Lorrr75 (Lorenzo Rosa).

**Partner di progettazione e sviluppo
Claude** (Anthropic) — Partner AI coinvolto dall'inizio nella definizione dell'architettura, delle strutture dati, della roadmap e di tutte le scelte tecniche fondamentali. Partecipa attivamente alla scrittura del codice, alla revisione tecnica e alla stesura della documentazione.

\---

## Note sulla licenza

Questo progetto è distribuito sotto **European Union Public Licence v. 1.2 (EUPL-1.2)**.

La EUPL 1.2 è una licenza copyleft approvata dalla Commissione Europea, disponibile in tutte le lingue ufficiali dell'UE. In sintesi:

* Sei libero di usare, studiare, modificare e distribuire il software
* Se distribuisci versioni modificate, devi farlo sotto la stessa licenza
* Il codice sorgente deve essere sempre disponibile
* La legge applicabile è quella **italiana** (paese del licenziante)

Testo completo: [https://eupl.eu/1.2/it/](https://eupl.eu/1.2/it/)

\---

*Documento aggiornato: 2026 — AsmWorkbench è in sviluppo attivo*

