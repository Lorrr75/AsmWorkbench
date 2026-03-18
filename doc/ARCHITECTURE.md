# AsmWorkbench — Documento di Architettura

> Versione: 1.1  
> Stato: Progettazione iniziale  
> Lingua: Italiano (versione inglese prevista)  
> Licenza: EUPL v1.2

---

## Indice

1. [Visione del progetto](#1-visione-del-progetto)
2. [Stack tecnologico](#2-stack-tecnologico)
3. [Struttura del repository](#3-struttura-del-repository)
4. [Moduli e responsabilità](#4-moduli-e-responsabilità)
5. [Strutture dati](#5-strutture-dati)
6. [Sistema temi e colori](#6-sistema-temi-e-colori)
7. [Layout interfaccia utente](#7-layout-interfaccia-utente)
8. [Architettura della Tab Bar](#8-architettura-della-tab-bar)
9. [Syntax Highlighting e Validazione](#9-syntax-highlighting-e-validazione)
10. [AsmSense — Paragonabile a IntelliSense](#10-asmsense--paragonabile-a-intellisense)
11. [Resource Editor](#11-resource-editor)
12. [Integrazione Assembler](#12-integrazione-assembler)
13. [Integrazione Debugger](#13-integrazione-debugger)
14. [Flusso messaggi Win32](#14-flusso-messaggi-win32)
15. [Convenzioni di codice](#15-convenzioni-di-codice)
16. [Roadmap di sviluppo](#16-roadmap-di-sviluppo)
17. [Autori e partner](#17-autori-e-partner)

---

## 1. Visione del progetto

**AsmWorkbench** è un ambiente di sviluppo integrato (IDE) dedicato alla programmazione Assembly x86 su Windows, scritto interamente in Assembly x86 con MASM32.

### Obiettivi principali

- Offrire un unico strumento completo per chi programma in Assembly x86 su Windows
- Eliminare la necessità di usare un insieme eterogeneo di tool separati
- Ispirarsi all'esperienza utente di Visual Studio, adattandola al mondo Assembly
- Mantenere l'eseguibile leggero, autonomo e senza dipendenze esterne pesanti

### Cosa NON è AsmWorkbench

- Non è un IDE generico adattato all'Assembly
- Non è un wrapper attorno a tool esistenti
- Non è scritto in C, C++ o linguaggi di alto livello

### Tre progetti collegati

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   AsmWorkbench  │────▶│    Assembler     │────▶│    Debugger     │
│   (questo repo) │     │  (repo separato) │     │ (integrato qui) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
       IDE                  Compilatore              Step-by-step
```

---

## 2. Stack tecnologico

| Componente | Tecnologia |
|---|---|
| Linguaggio | Assembly x86 (MASM32) |
| Assembler di sviluppo | MASM32 SDK |
| GUI | Win32 API native |
| Editor di testo | RichEdit 4.1 (richiamato via Win32) |
| Astrazione GUI | Macro MASM condivise (`macros.inc`) |
| Build system | Script `make.bat` |
| Target OS | Windows 7 e superiore |
| Dipendenze runtime | Solo DLL standard di Windows |

### Perché RichEdit 4.1 specificamente

RichEdit 4.1 (disponibile da Windows XP in poi tramite `Msftedit.dll`) offre funzionalità fondamentali per AsmWorkbench non presenti nelle versioni precedenti:

- `CHARFORMAT2` con campo `bUnderlineType` — permette la sottolineatura ondulata (`CFU_UNDERLINEWAVE`) per i token non riconosciuti
- Colore di sottolineatura personalizzabile tramite `crUnderlineColor`
- Supporto Unicode nativo

### Perché Win32 + macro MASM

La Win32 API pura è verbosa in Assembly. Si usano **macro MASM** che astraggono i pattern ripetitivi mantenendo controllo totale, senza dipendenze esterne.

```nasm
; Senza macro — verboso
push MB_OK
push offset szTitle
push offset szMsg
push 0
call MessageBoxA

; Con macro — leggibile
MSG_BOX 0, szMsg, szTitle, MB_OK
```

---

## 3. Struttura del repository

```
AsmWorkbench/
│
├── src/                    ← Sorgenti Assembly
│   ├── main.asm            ← Entry point, WinMain, message loop
│   ├── mainwnd.asm         ← Finestra principale + WndProc
│   ├── tabbar.asm          ← Tab bar custom owner-draw
│   ├── editor.asm          ← Wrapper RichEdit
│   ├── syntax.asm          ← Syntax highlighting + validazione token
│   ├── toolbar.asm         ← Toolbar
│   ├── statusbar.asm       ← Barra di stato
│   ├── filemgr.asm         ← Gestione file (open/save/dialogs)
│   ├── project.asm         ← Gestione progetto .awb
│   ├── panelmgr.asm        ← Layout pannelli ridimensionabili
│   ├── config.asm          ← Configurazione (file INI)
│   ├── theme.asm           ← Sistema temi e colori            ← NUOVO
│   ├── symtable.asm        ← Parser e database simboli (AsmSense)
│   ├── asmsense.asm        ← UI autocomplete e parameter hints
│   ├── reseditor.asm       ← Resource editor visuale
│   └── macros.inc          ← Macro Win32 condivise
│
├── inc/                    ← File include condivisi
│   ├── globals.inc         ← Variabili globali condivise tra moduli
│   ├── structs.inc         ← Strutture dati custom
│   ├── constants.inc       ← ID menu, controlli, costanti IDE
│   ├── theme.inc           ← Strutture e costanti temi         ← NUOVO
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

---

## 4. Moduli e responsabilità

### `main.asm` — Entry point
- Contiene `WinMain`
- Inizializza le classi finestra
- Avvia il message loop principale
- Carica configurazione e tema all'avvio

### `mainwnd.asm` — Finestra principale
- Registra e crea la finestra principale
- Gestisce `WndProc` (procedura messaggi)
- Coordina il ridimensionamento dei sottocomponenti
- Gestisce `WM_CREATE`, `WM_SIZE`, `WM_CLOSE`, `WM_DESTROY`

### `theme.asm` — Sistema temi *(nuovo)*
- Carica il tema attivo dalla configurazione all'avvio
- Fornisce a tutti i moduli i colori correnti tramite la struttura globale `g_Theme`
- Implementa i due temi predefiniti: **Light** e **Dark**
- Espone `Theme_Load` e `Theme_Apply` come funzioni centralizzate
- Gestisce il cambio tema a runtime ridisegnando tutti i componenti

### `tabbar.asm` — Tab bar custom
- Disegna le tab interamente con `WM_DRAWITEM` (owner-draw)
- Usa i colori dal tema attivo — mai hardcoded
- Gestisce il simbolo `●` per file modificati
- Gestisce il pulsante `×` per chiusura tab
- Supporta click sinistro (attiva) e click centrale (chiude)
- Gestisce l'overflow con frecce di scorrimento

### `editor.asm` — Wrapper RichEdit
- Crea e gestisce il controllo RichEdit 4.1 (`Msftedit.dll`)
- Espone funzioni di alto livello: `GetCurrentLine`, `GetCurrentCol`, `GetText`, `SetText`
- Intercetta `EN_CHANGE` per notificare modifiche a `syntax.asm`
- Gestisce il flag `bModified` del documento corrente
- Imposta i colori di sfondo e testo dal tema attivo

### `syntax.asm` — Syntax highlighting + validazione
- **Passaggio 1 — Colorazione**: colora i token riconosciuti usando i colori del tema
- **Passaggio 2 — Validazione**: applica sottolineatura ondulata rossa ai token non riconosciuti
- Usa `CHARFORMAT2` di RichEdit 4.1 per entrambi i passaggi
- Opera solo sul paragrafo corrente per mantenere la reattività

### `toolbar.asm` — Barra degli strumenti
- Crea la toolbar con `CreateToolbarEx`
- Aggiorna lo stato abilitato/disabilitato in base al contesto corrente

### `statusbar.asm` — Barra di stato
- Mostra: numero riga, colonna, flag modificato, encoding, modalità (INS/OVR), nome file
- Si aggiorna ad ogni movimento del cursore via `EN_SELCHANGE`

### `filemgr.asm` — Gestione file
- Implementa: Nuovo, Apri, Salva, Salva con nome, Chiudi
- Gestisce i dialog standard (`GetOpenFileName`, `GetSaveFileName`)
- Controlla `bModified` prima di chiudere o sovrascrivere

### `project.asm` — Gestione progetto
- Gestisce il file `.awb` (formato INI esteso)
- Mantiene la lista dei file del progetto
- Visualizza il Project Tree nel pannello laterale

### `panelmgr.asm` — Gestione pannelli
- Gestisce il layout ridimensionabile con splitter trascinabili
- Pannelli: Project Tree (sinistra), Editor (centro), Output/Errori/Simboli (basso)

### `config.asm` — Configurazione
- Legge e scrive `AsmWorkbench.ini`
- Gestisce: tema attivo, font, tab size, percorsi, dimensioni finestra

### `symtable.asm` — Database simboli (AsmSense)
- Scansiona i file sorgente del progetto
- Riconosce: `PROC`, `ENDP`, label, `EQU`, variabili, macro
- Usato sia da `asmsense.asm` (autocomplete) che da `syntax.asm` (validazione)

### `asmsense.asm` — Autocomplete (AsmSense)
- Mostra un popup `ListBox` owner-draw sotto il cursore
- Attinge da: mnemonici x86, registri, `symtable`, `apidb.inc`

### `reseditor.asm` — Resource Editor
- Designer visuale per risorse Windows
- Genera il file `.rc` corrispondente

---

## 5. Strutture dati

Definite in `inc/structs.inc`:

```nasm
MAX_DOCS    equ 32

;---------------------------------------------------
; Documento aperto in una tab
;---------------------------------------------------
DOCUMENT struct
    szFilePath   db  MAX_PATH dup(0)  ; path completo su disco
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
    szName       db  256 dup(0)
    szRootPath   db  MAX_PATH dup(0)
    szMainFile   db  MAX_PATH dup(0)
    nDocCount    dd  0
    hDocs        dd  MAX_DOCS dup(0)
PROJECT ends

;---------------------------------------------------
; Simbolo nel database AsmSense
;---------------------------------------------------
SYM_PROC    equ 1
SYM_LABEL   equ 2
SYM_VAR     equ 3
SYM_MACRO   equ 4
SYM_API     equ 5
SYM_EQU     equ 6

SYMBOL struct
    szName       db  128 dup(0)
    nType        dd  0
    szFile       db  MAX_PATH dup(0)
    nLine        dd  0
    szSignature  db  256 dup(0)
SYMBOL ends

;---------------------------------------------------
; Voce nel database Win32 API (apidb.inc)
;---------------------------------------------------
APIENTRY struct
    szName       db  64 dup(0)
    nParams      dd  0
    szParams     db  256 dup(0)
APIENTRY ends
```

---

## 6. Sistema temi e colori

Il sistema temi è il modulo **trasversale** dell'IDE: tutti i moduli che disegnano qualcosa ottengono i propri colori esclusivamente da questo sistema, senza mai usare valori hardcoded. Questo garantisce che un cambio tema sia istantaneo e completo.

### Struttura THEME (in `inc/theme.inc`)

```nasm
;---------------------------------------------------
; Struttura tema colori
; Tutti i colori sono valori COLORREF (00BBGGRR)
;---------------------------------------------------
THEME struct

    ; --- Finestra principale e sfondo ---
    clrBackground        dd  0   ; sfondo editor
    clrForeground        dd  0   ; testo normale
    clrLineNumber        dd  0   ; colore numeri riga
    clrLineNumberBg      dd  0   ; sfondo colonna numeri riga
    clrCurrentLineBg     dd  0   ; evidenziazione riga corrente
    clrSelectionBg       dd  0   ; sfondo selezione testo
    clrSelectionFg       dd  0   ; testo selezionato

    ; --- Syntax highlighting ---
    clrMnemonic          dd  0   ; mnemonici (MOV, PUSH, CALL...)
    clrRegister          dd  0   ; registri (EAX, EBX, ESP...)
    clrDirective         dd  0   ; direttive MASM (.386, PROC, INVOKE...)
    clrComment           dd  0   ; commenti (;...)
    clrString            dd  0   ; stringhe ("testo")
    clrNumber            dd  0   ; costanti numeriche (1234, 0FFh, 1010b)
    clrOperator          dd  0   ; operatori ([, ], +, *, PTR...)
    clrLabel             dd  0   ; label definite nel codice

    ; --- Validazione token ---
    clrSquiggly          dd  0   ; sottolineatura ondulata (default: rosso)

    ; --- Tab bar ---
    clrTabActiveBg       dd  0   ; sfondo tab attiva
    clrTabActiveFg       dd  0   ; testo tab attiva
    clrTabInactiveBg     dd  0   ; sfondo tab inattiva
    clrTabInactiveFg     dd  0   ; testo tab inattiva
    clrTabModified       dd  0   ; colore simbolo ● (modificato)
    clrTabBorder         dd  0   ; bordo tab

    ; --- UI generale ---
    clrToolbarBg         dd  0   ; sfondo toolbar
    clrStatusbarBg       dd  0   ; sfondo statusbar
    clrStatusbarFg       dd  0   ; testo statusbar
    clrPanelBg           dd  0   ; sfondo pannelli (output, errori...)
    clrPanelFg           dd  0   ; testo pannelli
    clrSplitter          dd  0   ; colore divisori (splitter)
    clrProjectTreeBg     dd  0   ; sfondo project tree
    clrProjectTreeFg     dd  0   ; testo project tree

    ; --- Metadati ---
    szThemeName          db  64 dup(0)
    nThemeId             dd  0       ; THEME_LIGHT / THEME_DARK / THEME_CUSTOM

THEME ends

THEME_LIGHT   equ 0
THEME_DARK    equ 1
THEME_CUSTOM  equ 2
```

### Tema Light — valori predefiniti

Ispirato all'interfaccia classica di Windows / Visual Studio Light:

| Elemento | Colore | Note |
|---|---|---|
| Sfondo editor | `#FFFFFF` | Bianco |
| Testo normale | `#000000` | Nero |
| Mnemonici | `#0000FF` | Blu |
| Registri | `#8B0000` | Rosso scuro |
| Direttive | `#800080` | Viola |
| Commenti | `#008000` | Verde |
| Stringhe | `#A31515` | Rosso mattone |
| Costanti numeriche | `#098658` | Verde acqua |
| Squiggly | `#FF0000` | Rosso acceso |
| Tab attiva sfondo | `#FFFFFF` | |
| Tab inattiva sfondo | `#ECECEC` | Grigio chiaro |

### Tema Dark — valori predefiniti

Ottimizzato per ridurre l'affaticamento visivo in sessioni lunghe:

| Elemento | Colore | Note |
|---|---|---|
| Sfondo editor | `#1E1E1E` | Grigio molto scuro |
| Testo normale | `#D4D4D4` | Grigio chiaro |
| Mnemonici | `#569CD6` | Azzurro |
| Registri | `#9CDCFE` | Azzurro chiaro |
| Direttive | `#C586C0` | Viola chiaro |
| Commenti | `#6A9955` | Verde desaturato |
| Stringhe | `#CE9178` | Arancione salmone |
| Costanti numeriche | `#B5CEA8` | Verde chiaro |
| Squiggly | `#F44747` | Rosso brillante |
| Tab attiva sfondo | `#1E1E1E` | |
| Tab inattiva sfondo | `#2D2D2D` | Grigio scuro |

### Tema Custom

Quando l'utente sceglie *Strumenti → Personalizza tema*, si apre un dialog con un color picker per ogni campo della struttura `THEME`. Il tema custom viene salvato in `AsmWorkbench.ini` nella sezione `[Theme]`.

### Cambio tema a runtime

```
Utente seleziona nuovo tema
        │
        ▼
Theme_Load(nThemeId)       ; carica valori in g_Theme
        │
        ▼
Editor_ApplyTheme          ; aggiorna colori RichEdit + ri-esegue syntax
TabBar_Repaint             ; ridisegna tutte le tab
Toolbar_Repaint            ; ridisegna toolbar
StatusBar_Repaint          ; ridisegna statusbar
ProjectTree_Repaint        ; ridisegna project tree
Panel_Repaint              ; ridisegna pannelli inferiori
        │
        ▼
InvalidateRect(g_hMainWnd) ; forza ridisegno completo
```

### Regola fondamentale — mai hardcoded

```nasm
; ❌ VIETATO — colore hardcoded
mov  eax, 1E1E1Eh

; ✅ CORRETTO — sempre dal tema attivo
mov  eax, g_Theme.clrBackground
```

---

## 7. Layout interfaccia utente

```
┌──────────────────────────────────────────────────────────────────┐
│  File  Modifica  Visualizza  Progetto  Build  Strumenti  Aiuto   │  ← Menu
├──────────────────────────────────────────────────────────────────┤
│  [N][A][S][S+] │ [Build][Esegui][Stop] │ [AsmSense ON/OFF]      │  ← Toolbar
├──────────────────────────────────────────────────────────────────┤
│  [main.asm]  [utils.asm ●]  [resource.rc]  [+]                   │  ← Tab bar
├─────────────────────┬────────────────────────────────────────────┤
│                     │                                             │
│  Project Tree       │   Editor RichEdit                          │
│  ────────────────   │                                             │
│  ▼ MyProject        │   1  .386                                   │
│    ├ main.asm       │   2  .model flat, stdcall                   │
│    ├ utils.asm      │   3  option casemap:none                    │
│    └ resource.rc    │   4                                         │
│                     │   5  include windows.inc                    │
│                     │   6  mov eax, AEX     ← squiggly su AEX    │
│                     │                  ~~~                        │
├─────────────────────┴────────────────────────────────────────────┤
│  [ ▼ Output ] [ ▼ Errori ] [ ▼ Simboli ]                         │
│  Compilazione completata — 0 errori, 0 warning                   │
├──────────────────────────────────────────────────────────────────┤
│  Ln 6   Col 18  │  ANSI  │  x86  │  INS  │  main.asm            │  ← Statusbar
└──────────────────────────────────────────────────────────────────┘
```

Il menu *Visualizza → Tema* conterrà:

```
Visualizza
  └── Tema
        ├── ● Light
        ├──   Dark
        └──   Personalizza...
```

---

## 8. Architettura della Tab Bar

Implementata come controllo **owner-draw custom** senza usare `WC_TABCONTROL`. Tutti i colori vengono da `g_Theme`.

### Anatomia di una tab

```
┌─────────────────────────────┐
│  📄  utils.asm   ●   ×     │  ← tab attiva, file modificato
└─────────────────────────────┘

┌─────────────────────────────┐
│  📄  main.asm        ×     │  ← tab inattiva, file pulito
└─────────────────────────────┘
```

### Comportamenti

| Azione | Effetto |
|---|---|
| Click sinistro | Attiva il documento |
| Click sul `×` | Chiude (con dialogo se modificata) |
| Click centrale | Chiude la tab |
| Comparsa `●` | Quando `bModified = 1` |
| Scomparsa `●` | Dopo salvataggio |
| Click `[+]` | Nuovo documento vuoto |
| Overflow tab | Frecce di scorrimento |
| Drag (futuro) | Riordina le tab |

### Dialogo di chiusura con file modificato

```
┌────────────────────────────────────────────┐
│  AsmWorkbench                              │
│                                            │
│  Il file "utils.asm" è stato modificato.   │
│  Vuoi salvare le modifiche prima           │
│  di chiudere?                              │
│                                            │
│   [Salva]   [Non salvare]   [Annulla]      │
└────────────────────────────────────────────┘
```

---

## 9. Syntax Highlighting e Validazione

`syntax.asm` esegue **due passaggi distinti** ad ogni modifica del testo (`EN_CHANGE`), operando solo sul paragrafo corrente per mantenere la reattività anche su file lunghi.

### Passaggio 1 — Colorazione

Per ogni token riconosciuto, applica il colore corrispondente dal tema attivo tramite `EM_SETCHARFORMAT` con struttura `CHARFORMAT2`.

| Categoria | Esempi |
|---|---|
| Mnemonici x86 | `MOV`, `PUSH`, `POP`, `CALL`, `RET`, `JMP`, `JE`, `CMP`... |
| Registri | `EAX`, `EBX`, `ECX`, `EDX`, `ESI`, `EDI`, `ESP`, `EBP`, `AX`, `AL`... |
| Direttive MASM | `.386`, `.MODEL`, `PROC`, `ENDP`, `INVOKE`, `INCLUDE`, `EQU`... |
| Commenti | Tutto dopo `;` fino a fine riga |
| Stringhe | Testo racchiuso tra `"..."` |
| Costanti decimali | `1234`, `42` |
| Costanti esadecimali | `0FFh`, `0x1A00` |
| Costanti binarie | `1010b` |
| Operatori | `[`, `]`, `+`, `-`, `*`, `PTR`, `OFFSET`, `SIZEOF` |

### Passaggio 2 — Validazione (sottolineatura ondulata)

Per ogni token che non appartiene ad alcuna categoria riconosciuta e non è presente in `symtable`, viene applicata la sottolineatura ondulata tramite `CHARFORMAT2` di RichEdit 4.1:

```nasm
;---------------------------------------------------
; Syntax_ApplySquiggly
; Applica sottolineatura ondulata al range [nStart, nEnd]
; Input:  hRichEdit, nStart, nEnd
;---------------------------------------------------
Syntax_ApplySquiggly proc hRE:DWORD, nStart:DWORD, nEnd:DWORD
    LOCAL cf2:CHARFORMAT2

    ; Seleziona il range del token
    ; ...
    
    ; Configura CHARFORMAT2 per sottolineatura ondulata
    mov  cf2.cbSize,        sizeof CHARFORMAT2
    mov  cf2.dwMask,        CFM_UNDERLINETYPE or CFM_UNDERLINECOLOR
    mov  cf2.bUnderlineType, CFU_UNDERLINEWAVE   ; valore 3
    
    ; Colore dal tema attivo — mai hardcoded
    mov  eax, g_Theme.clrSquiggly
    mov  cf2.crUnderlineColor, eax

    invoke SendMessage, hRE, EM_SETCHARFORMAT, SCF_SELECTION, addr cf2
    ret
Syntax_ApplySquiggly endp
```

### Esempi visivi

```asm
mov  eax, ebx          ; tutto riconosciuto → colorato normalmente
mov  eax, AEX          ; "AEX" sconosciuto → ~~~~ rosso sotto AEX
push MyProc            ; "MyProc" è in symtable → ok, nessuna sottolineatura
push UnknownSym        ; non in symtable → ~~~~ rosso sotto UnknownSym
.386                   ; direttiva riconosciuta → colore direttiva
```

---

## 10. AsmSense — Paragonabile a IntelliSense

AsmSense è composto da tre livelli implementati in ordine crescente di complessità.

### Livello 1 — Autocomplete

Trigger: 2 o più caratteri alfanumerici digitati consecutivamente.

Fonti consultate in ordine:
1. Mnemonici x86 (hardcoded in `asmsense.asm`)
2. Registri x86 (hardcoded)
3. Simboli del progetto (`symtable.asm`)
4. API Win32 (`apidb.inc`)

```
Utente digita "CR"
       │
       ▼
┌─────────────────────┐
│  CALL               │
│  CMP                │
│  CreateWindowEx  ◀──┼── da apidb.inc
│  CreateFileA        │
│  ...                │
└─────────────────────┘
```

### Livello 2 — Parameter Hints

Trigger: spazio dopo `INVOKE`.

```
INVOKE CreateWindowEx, |
                       ▲
┌──────────────────────────────────────────────┐
│  CreateWindowEx(dwExStyle, lpClassName,      │
│                 lpWindowName, dwStyle,        │
│                 X, Y, nWidth, nHeight,        │
│                 hWndParent, hMenu,            │
│                 hInstance, lpParam)           │
└──────────────────────────────────────────────┘
```

### Livello 3 — Symbol Navigator

Pannello laterale con tutti i simboli del file corrente e navigazione diretta alla riga di definizione.

### Struttura `apidb.inc`

```nasm
APIENTRY <"MessageBox",      4, "hWnd, lpText, lpCaption, uType">
APIENTRY <"CreateWindowEx", 12, "dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam">
APIENTRY <"VirtualAlloc",    4, "lpAddress, dwSize, flAllocationType, flProtect">
```

---

## 11. Resource Editor

Il Resource Editor permette di progettare visualmente le risorse Windows e generare il file `.rc`.

| Tipo | Descrizione |
|---|---|
| `DIALOG` | Disegno visuale di finestre dialog |
| `MENU` | Editor albero del menu |
| `STRINGTABLE` | Tabella stringhe localizzabili |
| `ICON` | Gestione file `.ico` |
| `BITMAP` | Gestione file `.bmp` |

```
Designer visuale  ──▶  Generazione .rc  ──▶  Compilazione (rc.exe)  ──▶  .res
```

---

## 12. Integrazione Assembler

L'assembler è sviluppato in repository separato e integrato come tool di build esterno.

```
Menu Build → Esegui Build
       │
       ▼
Salva tutti i file modificati
       │
       ▼
Chiama Assembler.exe con parametri progetto
       │
       ├── Successo ──▶ "Build OK" nel pannello Output
       │                Abilita pulsante Esegui / Debugger
       │
       └── Errori  ──▶ Lista errori nel pannello Errori
                        Click su errore → salta alla riga nel file
```

Formato output errori:
```
nomefile.asm(42): errore E001: simbolo non definito 'MyProc'
nomefile.asm(87): avviso W003: istruzione non raggiungibile
```

---

## 13. Integrazione Debugger

Ultimo step della roadmap. Integrato come pannello aggiuntivo della finestra principale.

### Funzionalità previste
- Step In / Step Over / Step Out
- Breakpoint sulla riga sorgente
- Registri: EAX, EBX, ECX, EDX, ESI, EDI, ESP, EBP, EIP
- Flag: ZF, CF, OF, SF, PF
- Dump memoria esadecimale
- Visualizzazione stack
- Disassembly in tempo reale

### Layout con debugger attivo

```
├─────────────────────┬────────────────────────────────────────────┤
│  Registri           │   Editor (con freccia riga corrente)        │
│  EAX = 00000001     │  ▶  42  mov eax, [ebp+8]                   │
│  EBX = 00401000     │     43  push eax                            │
│  ...                │     44  call MyProc                         │
├─────────────────────┴────────────────────────────────────────────┤
│  Stack              │   Memoria (dump hex)                        │
│  0019FF80: ...      │   00401000: 55 8B EC 83 ...                 │
└──────────────────────────────────────────────────────────────────┘
```

---

## 14. Flusso messaggi Win32

```
WinMain
  │
  ├─► Theme_Load              (theme.asm)      ← prima di tutto
  ├─► RegisterClass           (mainwnd.asm)
  ├─► CreateMainWindow
  │     ├─► CreateToolbar     (toolbar.asm)
  │     ├─► CreateTabBar      (tabbar.asm)
  │     ├─► CreateRichEdit    (editor.asm)
  │     ├─► CreateStatusBar   (statusbar.asm)
  │     ├─► CreateProjectTree (project.asm)
  │     └─► CreatePanels      (panelmgr.asm)
  │
  └─► Message Loop
        ├─► WM_CREATE     → inizializza sottocomponenti
        ├─► WM_SIZE       → ridisegna layout
        ├─► WM_COMMAND    → menu e toolbar
        ├─► WM_NOTIFY     → eventi da RichEdit e Tab Bar
        ├─► WM_DRAWITEM   → ridisegna tab custom
        ├─► WM_KEYDOWN    → shortcut tastiera
        ├─► WM_CLOSE      → controlla file non salvati
        └─► WM_DESTROY    → cleanup + PostQuitMessage
```

---

## 15. Convenzioni di codice

```nasm
; Procedure: PascalCase con prefisso modulo
Editor_GetCurrentLine  proc
TabBar_DrawTab         proc
Theme_Load             proc
Syntax_ValidateToken   proc

; Variabili globali (globals.inc): prefisso g_
g_hMainWnd    dd  0
g_hRichEdit   dd  0
g_Theme       THEME <>    ; tema attivo corrente

; Variabili locali: prefisso lv_
lv_hDC        dd  0

; Costanti: UPPER_SNAKE_CASE
IDM_FILE_NEW       equ 1001
IDM_VIEW_LIGHT     equ 3001
IDM_VIEW_DARK      equ 3002
IDM_VIEW_CUSTOM    equ 3003
```

Struttura di ogni procedura:

```nasm
;---------------------------------------------------
; NomeModulo_NomeProcedura
; Descrizione: cosa fa questa procedura
; Input:  parametro1 = descrizione
;         parametro2 = descrizione
; Output: EAX = risultato / 0 se errore
; Modifica: EBX, ECX
;---------------------------------------------------
NomeModulo_NomeProcedura proc param1:DWORD, param2:DWORD
    LOCAL lv_temp:DWORD
    ret
NomeModulo_NomeProcedura endp
```

---

## 16. Roadmap di sviluppo

| Step | Modulo | Obiettivo | Stato |
|:----:|--------|-----------|:-----:|
| 1 | `main.asm` + `mainwnd.asm` | Finestra principale con menu base | ⬜ |
| 2 | `tabbar.asm` | Tab bar custom owner-draw con ● e × | ⬜ |
| 3 | `editor.asm` | RichEdit 4.1 embedded con gestione resize | ⬜ |
| 4 | `filemgr.asm` | New / Open / Save / Save As | ⬜ |
| 5 | `statusbar.asm` | Riga, colonna, flag modificato | ⬜ |
| 6 | `theme.asm` + `theme.inc` | Sistema temi Light / Dark / Custom | ⬜ |
| 7 | `syntax.asm` | Highlighting + sottolineatura ondulata | ⬜ |
| 8 | `toolbar.asm` | Toolbar con azioni principali | ⬜ |
| 9 | `project.asm` | Progetto `.awb` e project tree | ⬜ |
| 10 | `panelmgr.asm` | Pannelli Output / Errori / Simboli | ⬜ |
| 11 | Build | Integrazione assembler esterno | ⬜ |
| 12 | `symtable.asm` | Parser simboli del progetto | ⬜ |
| 13 | `asmsense.asm` | Autocomplete + Parameter Hints | ⬜ |
| 14 | Symbol Navigator | Pannello simboli con navigazione | ⬜ |
| 15 | `reseditor.asm` | Resource editor visuale | ⬜ |
| 16 | Debugger | Integrazione debugger step-by-step | ⬜ |

Legenda: ⬜ Da fare · 🔄 In corso · ✅ Completato

---

## 17. Autori e partner

**Ideazione, progettazione e sviluppo**
Sviluppatore principale e ideatore del progetto.

**Partner di progettazione e sviluppo**
**Claude** (Anthropic) — Partner AI coinvolto dall'inizio nella definizione dell'architettura, delle strutture dati, della roadmap e di tutte le scelte tecniche fondamentali. Partecipa attivamente alla scrittura del codice, alla revisione tecnica e alla stesura della documentazione.

---

## Note sulla licenza

Distribuito sotto **European Union Public Licence v. 1.2 (EUPL-1.2)**.

- Libero per uso, studio, modifica e distribuzione
- Versioni modificate devono essere rilasciate sotto la stessa licenza
- Il codice sorgente deve essere sempre disponibile
- Legge applicabile: **italiana** (paese del licenziante)

Testo completo: [https://eupl.eu/1.2/it/](https://eupl.eu/1.2/it/)

---

*Documento aggiornato: 2026 — AsmWorkbench è in sviluppo attivo*
