# AsmWorkbench — Documento di Architettura

> Versione: 1.4  
> Stato: Sviluppo in corso — Step 3 completato  
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
10. [Indent Guides](#10-indent-guides)
11. [Ricerca nel progetto](#11-ricerca-nel-progetto)
12. [AsmSense — Paragonabile a IntelliSense](#12-asmsense--paragonabile-a-intellisense)
13. [Resource Editor](#13-resource-editor)
14. [Sistema di notifica aggiornamenti](#14-sistema-di-notifica-aggiornamenti)
15. [Integrazione Assembler](#15-integrazione-assembler)
16. [Integrazione Debugger](#16-integrazione-debugger)
17. [Flusso messaggi Win32](#17-flusso-messaggi-win32)
18. [Convenzioni di codice](#18-convenzioni-di-codice)
19. [Roadmap di sviluppo](#19-roadmap-di-sviluppo)
20. [Autori e partner](#20-autori-e-partner)

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
| Editor di testo | RichEdit 4.1 (`Msftedit.dll`) |
| Astrazione GUI | Macro MASM condivise (`macros.inc`) |
| Rete (notifiche) | `wininet.dll` (già presente su Windows) |
| Build system | Script `make.bat` |
| Target OS | Windows 7 e superiore |
| Dipendenze runtime | Solo DLL standard di Windows |

### Perché RichEdit 4.1 specificamente

RichEdit 4.1 (disponibile da Windows XP in poi tramite `Msftedit.dll`) offre funzionalità fondamentali non presenti nelle versioni precedenti:

- `CHARFORMAT2` con `bUnderlineType` — sottolineatura ondulata (`CFU_UNDERLINEWAVE`) per i token non riconosciuti
- `crUnderlineColor` — colore della sottolineatura personalizzabile
- `EM_FINDTEXT` / `EM_FINDTEXTEX` — ricerca testo nativa
- Supporto Unicode nativo

### Perché Win32 + macro MASM

La Win32 API pura è verbosa in Assembly. Si usano **macro MASM** che astraggono i pattern ripetitivi mantenendo controllo totale, senza dipendenze esterne.

```asm
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
├── AsmWorkbench.asm        ← Entry point, WinMain, include di tutto il progetto
│
├── src/                    ← Sorgenti Assembly
│   ├── WinMain.asm         ← Corpo principale, message loop, gestione errori
│   ├── MainWndProc.asm     ← WndProc — gestione messaggi finestra principale
│   ├── RegisterWindowMainClass.asm ← Registrazione classe finestra principale
│   ├── InitIde.asm         ← Creazione e init di tutti i componenti (WM_CREATE)
│   ├── TabBar.asm          ← Tab bar custom owner-draw              ✅ COMPLETATO
│   ├── DeInitIde.asm       ← Pulizia risorse (WM_DESTROY)          [futuro]
│   ├── Editor.asm          ← Wrapper RichEdit                       [futuro]
│   ├── Syntax.asm          ← Syntax highlighting + validazione      [futuro]
│   ├── IndentGuide.asm     ← Linee guida indentazione blocchi       [futuro]
│   ├── Search.asm          ← Ricerca file corrente e progetto       [futuro]
│   ├── Toolbar.asm         ← Toolbar icone sotto il menu            [futuro]
│   ├── FileMgr.asm         ← Gestione file (open/save/dialogs)      [futuro]
│   ├── Project.asm         ← Gestione progetto .awb                 [futuro]
│   ├── PanelMgr.asm        ← Layout pannelli ridimensionabili       [futuro]
│   ├── Config.asm          ← Configurazione (file INI)              [futuro]
│   ├── Theme.asm           ← Sistema temi e colori                  [futuro]
│   ├── Updater.asm         ← Notifica aggiornamenti disponibili     [futuro]
│   ├── SymTable.asm        ← Parser e database simboli (AsmSense)   [futuro]
│   ├── AsmSense.asm        ← UI autocomplete e parameter hints      [futuro]
│   └── ResEditor.asm       ← Resource editor visuale                [futuro]
│
├── inc/                    ← File include condivisi
│   ├── CommonHeader.inc    ← Include Windows.inc e altri header MASM32
│   ├── CommonLib.inc       ← Includelib per le librerie di sistema
│   ├── Proto.inc           ← Prototipi di tutte le funzioni
│   ├── constants.inc       ← Costanti EQU, stringhe, ID controlli, colori tema
│   ├── globals.inc         ← Variabili globali .data? condivise tra moduli
│   ├── structs.inc         ← Strutture dati custom (DOCUMENT, PROJECT...)
│   ├── theme.inc           ← Struttura THEME e costanti temi        [futuro]
│   └── apidb.inc           ← Database Win32 API per AsmSense        [futuro]
│
├── res/                    ← Risorse Windows
│   └── icons/              ← File icone .ico
│
├── docs/                   ← Documentazione tecnica
│   └── ARCHITECTURE.md     ← Questo file
│
├── make.bat                ← Script di build (ml + link)
├── AsmWorkbench.exe        ← Eseguibile compilato (non versionato)
├── AsmWorkbench.obj        ← File oggetto (non versionato)
├── README.md               ← Presentazione del progetto (italiano)
├── ReadMe_Eng.md           ← Presentazione del progetto (inglese)
└── LICENSE EUPL-1.2.txt    ← Testo EUPL v1.2
```

> **Nota sul .gitignore**: aggiungere `*.exe`, `*.obj`, `*.res` per escludere i file compilati dal versionamento.

---

## 4. Moduli e responsabilità

### `main.asm` — Entry point
- Contiene `WinMain`
- Inizializza le classi finestra
- Avvia il message loop principale
- Carica configurazione e tema all'avvio
- Lancia il controllo aggiornamenti in background

### `mainwnd.asm` — Finestra principale
- Registra e crea la finestra principale
- Gestisce `WndProc` (procedura messaggi)
- Coordina il ridimensionamento dei sottocomponenti
- Gestisce `WM_CREATE`, `WM_SIZE`, `WM_CLOSE`, `WM_DESTROY`

### `theme.asm` — Sistema temi
- Carica il tema attivo dalla configurazione all'avvio
- Fornisce a tutti i moduli i colori correnti tramite `g_Theme`
- Implementa i due temi predefiniti: **Light** e **Dark**
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
- Intercetta `EN_CHANGE` per notificare `syntax.asm` e `indentguide.asm`
- Gestisce il flag `bModified` del documento corrente
- Imposta colori di sfondo e testo dal tema attivo

### `syntax.asm` — Syntax highlighting + validazione
- **Passaggio 1 — Colorazione**: colora i token riconosciuti con i colori del tema
- **Passaggio 2 — Validazione**: applica sottolineatura ondulata rossa ai token non riconosciuti
- Usa `CHARFORMAT2` di RichEdit 4.1 per entrambi i passaggi
- Opera solo sul paragrafo corrente per mantenere la reattività

### `indentguide.asm` — Linee guida indentazione *(nuovo)*
- Disegna linee verticali tratteggiate sottili che collegano blocchi apertura/chiusura
- Coppia di blocchi riconosciuti:

| Apertura | Chiusura |
|---|---|
| `.IF` | `.ENDIF` |
| `.WHILE` | `.ENDW` |
| `.REPEAT` | `.UNTIL` |
| `STRUCT` | `ENDS` |
| `MACRO` | `ENDM` |
| `PROC` | `ENDP` |

- Implementato intercettando `WM_PAINT` del RichEdit e aggiungendo il disegno delle linee in coda, tramite un layer sovrapposto trasparente
- Colore configurabile nel tema (`clrIndentGuide`), disattivabile dalle impostazioni

### `search.asm` — Ricerca nel progetto *(nuovo)*
- Dialog floating **non modale** — rimane aperto durante la navigazione
- Tre modalità operative:
  - **File corrente** — usa `EM_FINDTEXTEX` nativo di RichEdit
  - **Progetto completo** — scansiona tutti i file `.asm` del progetto
  - **Sostituisci** — Replace e Replace All su file corrente o progetto
- Opzioni: maiuscole/minuscole, parola intera
- I risultati del progetto appaiono nel pannello inferiore come lista cliccabile — click sulla voce apre il file e salta alla riga

### `toolbar.asm` — Barra degli strumenti
- Barra icone posizionata sotto il menu, creata con `CreateToolbarEx`
- Pulsanti previsti: Nuovo, Apri, Salva, Salva tutto, Separatore, Build, Esegui, Stop, Separatore, Cerca, AsmSense ON/OFF
- Aggiorna lo stato abilitato/disabilitato in base al contesto corrente

### `statusbar.asm` — Barra di stato
- Mostra: numero riga, colonna, flag modificato, encoding, modalità (INS/OVR), nome file
- Mostra notifica aggiornamento disponibile nella sezione destra (discreta, cliccabile)
- Si aggiorna ad ogni movimento del cursore via `EN_SELCHANGE`

### `filemgr.asm` — Gestione file
- Implementa: Nuovo, Apri, Salva, Salva con nome, Chiudi, Salva tutto
- Gestisce i dialog standard (`GetOpenFileName`, `GetSaveFileName`)
- Controlla `bModified` prima di chiudere o sovrascrivere

### `project.asm` — Gestione progetto
- Gestisce il file `.awb` (formato INI esteso)
- Mantiene la lista dei file del progetto
- Visualizza il Project Tree nel pannello laterale

### `panelmgr.asm` — Gestione pannelli
- Gestisce il layout ridimensionabile con splitter trascinabili
- Pannelli: Project Tree (sinistra), Editor (centro), Output/Errori/Simboli/Ricerca (basso)

### `config.asm` — Configurazione
- Legge e scrive `AsmWorkbench.ini`
- Gestisce: tema attivo, font, tab size, indent guides on/off, aggiornamenti on/off, percorsi, dimensioni finestra

### `updater.asm` — Notifica aggiornamenti *(nuovo)*
- Eseguito in background all'avvio tramite un thread separato
- Interroga GitHub API: `api.github.com/repos/<owner>/AsmWorkbench/releases/latest`
- Confronta il tag della release remota con la versione corrente dell'eseguibile
- Se disponibile una versione più recente: mostra notifica discreta nella statusbar
- Click sulla notifica: apre il browser sulla pagina release di GitHub
- Il download e l'installazione restano manuali — l'utente sceglie quando aggiornare
- Funzionalità disattivabile dalle impostazioni (`CheckUpdates=0` in INI)
- Usa `wininet.dll` — già presente su Windows, nessuna dipendenza esterna

### `symtable.asm` — Database simboli (AsmSense)
- Scansiona i file sorgente del progetto
- Riconosce: `PROC`, `ENDP`, label, `EQU`, variabili, macro
- Usato da `asmsense.asm` (autocomplete) e `syntax.asm` (validazione token)

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
MAX_TABS    equ 32

;---------------------------------------------------
; Documento aperto in una tab
;---------------------------------------------------
TABITEM struct
    szFilePath   db  MAX_PATH dup(0)  ; path completo su disco
    szTitle      db  256 dup(0)       ; nome visualizzato nella tab
    hRichEdit    dd  0                 ; handle RichEdit (futuro)
    bModified    dd  0                 ; 0 = pulito / 1 = modificato (●)
    bNew         dd  0                 ; 1 = mai salvato su disco
    hScrollPos   dd  0                 ; posizione scroll salvata
TABITEM ends

;---------------------------------------------------
; Progetto corrente — file .awb (futuro)
;---------------------------------------------------
PROJECT struct
    szName       db  256 dup(0)
    szRootPath   db  MAX_PATH dup(0)
    szMainFile   db  MAX_PATH dup(0)
    nDocCount    dd  0
    hDocs        dd  MAX_TABS dup(0)
PROJECT ends

;---------------------------------------------------
; Risultato di ricerca nel progetto (futuro)
;---------------------------------------------------
SEARCHRESULT struct
    szFilePath   db  MAX_PATH dup(0)
    nLine        dd  0
    nCol         dd  0
    szContext    db  256 dup(0)
SEARCHRESULT ends

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

Il sistema temi è il modulo **trasversale** dell'IDE: tutti i moduli che disegnano qualcosa ottengono i propri colori esclusivamente da questo sistema, senza mai usare valori hardcoded.

### Struttura THEME (in `inc/theme.inc`)

```asm
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

    ; --- Indent guides ---
    clrIndentGuide       dd  0   ; colore linee guida indentazione

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
| Indent guides | `#D0D0D0` | Grigio molto chiaro |
| Tab attiva sfondo | `#FFFFFF` | |
| Tab inattiva sfondo | `#ECECEC` | Grigio chiaro |

### Tema Dark — valori predefiniti

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
| Indent guides | `#404040` | Grigio scuro appena visibile |
| Tab attiva sfondo | `#1E1E1E` | |
| Tab inattiva sfondo | `#2D2D2D` | Grigio scuro |

### Tema Custom

Dialog accessibile da *Strumenti → Personalizza tema* con color picker per ogni campo. Salvato in `AsmWorkbench.ini` sezione `[Theme]`.

### Regola fondamentale — mai hardcoded

```asm
; ❌ VIETATO
mov  eax, 1E1E1Eh

; ✅ CORRETTO
mov  eax, g_Theme.clrBackground
```

---

## 7. Layout interfaccia utente

```
┌──────────────────────────────────────────────────────────────────┐
│  File  Modifica  Visualizza  Progetto  Build  Strumenti  Aiuto   │  ← Menu
├──────────────────────────────────────────────────────────────────┤
│  [N][A][S][S+] │ [Build][Esegui][Stop] │ [Cerca] [AsmSense]     │  ← Toolbar
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
│                     │   5  .IF eax == 0          ← indent guide  │
│                     │   6  │  mov ebx, 1                         │
│                     │   7  │  mov ecx, 2                         │
│                     │   8  .ENDIF                                 │
│                     │   9                                         │
│                     │  10  mov eax, AEX    ← squiggly su AEX     │
│                     │                 ~~~                         │
├─────────────────────┴────────────────────────────────────────────┤
│ [▼ Output] [▼ Errori] [▼ Simboli] [▼ Ricerca]                    │  ← Pannelli
│  Trovate 3 corrispondenze per "MyProc" in 2 file                 │
│  main.asm(12):   call MyProc                                      │
│  utils.asm(45):  MyProc proc                                      │
├──────────────────────────────────────────────────────────────────┤
│  Ln 10  Col 14  │  ANSI  │  x86  │  INS  │  main.asm  ║ ⬆ v1.1  │  ← Statusbar
└──────────────────────────────────────────────────────────────────┘
                                                         ↑
                                              notifica aggiornamento
```

Il menu *Visualizza → Tema*:
```
Visualizza
  ├── Tema
  │     ├── ● Light
  │     ├──   Dark
  │     └──   Personalizza...
  └── Indent Guides  ✓
```

---

## 8. Architettura della Tab Bar

Implementata come controllo **owner-draw custom**. Tutti i colori vengono da `g_Theme`.

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

`syntax.asm` esegue **due passaggi distinti** ad ogni `EN_CHANGE`, operando solo sul paragrafo corrente per mantenere la reattività.

### Passaggio 1 — Colorazione

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

```asm
;---------------------------------------------------
; Syntax_ApplySquiggly
; Applica sottolineatura ondulata al range [nStart, nEnd]
;---------------------------------------------------
Syntax_ApplySquiggly proc hRE:DWORD, nStart:DWORD, nEnd:DWORD
    LOCAL cf2:CHARFORMAT2

    mov  cf2.cbSize,         sizeof CHARFORMAT2
    mov  cf2.dwMask,         CFM_UNDERLINETYPE or CFM_UNDERLINECOLOR
    mov  cf2.bUnderlineType, CFU_UNDERLINEWAVE      ; valore 3
    mov  eax, g_Theme.clrSquiggly
    mov  cf2.crUnderlineColor, eax

    invoke SendMessage, hRE, EM_SETCHARFORMAT, SCF_SELECTION, addr cf2
    ret
Syntax_ApplySquiggly endp
```

### Esempi visivi

```asm
mov  eax, ebx       ; tutto riconosciuto → colorato normalmente
mov  eax, AEX       ; "AEX" sconosciuto → ~~~~ rosso sotto AEX
push MyProc         ; "MyProc" è in symtable → nessuna sottolineatura
push UnknownSym     ; non in symtable → ~~~~ rosso sotto UnknownSym
```

---

## 10. Indent Guides

`indentguide.asm` disegna linee verticali tratteggiate sottili che collegano visivamente i blocchi di apertura e chiusura, facilitando la lettura del codice profondamente indentato.

### Blocchi riconosciuti

| Apertura | Chiusura |
|---|---|
| `.IF` | `.ENDIF` |
| `.WHILE` | `.ENDW` |
| `.REPEAT` | `.UNTIL` / `.UNTILCXZ` |
| `STRUCT` | `ENDS` |
| `MACRO` | `ENDM` |
| `PROC` | `ENDP` |

### Implementazione tecnica

Le linee vengono disegnate intercettando `WM_PAINT` del RichEdit e aggiungendo il disegno al termine del ciclo di pittura standard, su un layer sovrapposto trasparente. Questo approccio non interferisce con il contenuto del testo.

### Esempio visivo

```asm
5  .IF eax == 0
6  │  mov ebx, 1
7  │  .IF ecx == 2
8  │  │  push edx
9  │  .ENDIF
10 .ENDIF
```

- Colore configurabile nel tema (`clrIndentGuide`) — discreto nel Light, appena visibile nel Dark
- Attivabile/disattivabile da *Visualizza → Indent Guides* e dalle impostazioni

---

## 11. Ricerca nel progetto

`search.asm` fornisce un dialog floating **non modale** che rimane aperto durante la navigazione tra i risultati.

### Modalità operative

```
┌─────────────────────────────────────────────────┐
│  🔍 Cerca in AsmWorkbench                       │
│                                                  │
│  Cerca:    [________________]  [Cerca]           │
│  Sostituisci: [____________]  [Sostituisci]      │
│                               [Sostituisci tutto]│
│                                                  │
│  ◉ File corrente  ○ Progetto completo            │
│                                                  │
│  [ ] Maiuscole/minuscole   [ ] Parola intera     │
└─────────────────────────────────────────────────┘
```

### Flusso di ricerca sul progetto

```
Utente avvia ricerca su "Progetto completo"
        │
        ▼
Per ogni file .asm nel progetto
        │
        ├── Apri file in memoria
        ├── Scansiona con EM_FINDTEXTEX
        ├── Raccogli risultati in lista SEARCHRESULT
        └── Chiudi buffer temporaneo
        │
        ▼
Mostra risultati nel pannello [▼ Ricerca]
  main.asm(12):   call MyProc
  utils.asm(45):  MyProc proc
        │
        ▼
Click su risultato → apre file nella tab + salta alla riga
```

### Shortcut tastiera

| Shortcut | Azione |
|---|---|
| `Ctrl+F` | Apre dialog ricerca (file corrente) |
| `Ctrl+Shift+F` | Apre dialog ricerca (progetto completo) |
| `Ctrl+H` | Apre dialog con tab Sostituisci attiva |
| `F3` | Prossima corrispondenza |
| `Shift+F3` | Corrispondenza precedente |
| `Esc` | Chiude il dialog |

---

## 12. AsmSense — Paragonabile a IntelliSense

### Livello 1 — Autocomplete

Trigger: 2 o più caratteri alfanumerici digitati consecutivamente.

Fonti in ordine: mnemonici x86 → registri → `symtable` → `apidb.inc`.

```
Utente digita "CR"
┌─────────────────────┐
│  CALL               │
│  CMP                │
│  CreateWindowEx     │ ← da apidb.inc
│  CreateFileA        │
└─────────────────────┘
```

### Livello 2 — Parameter Hints

Trigger: spazio dopo `INVOKE`.

```
INVOKE CreateWindowEx, |
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

```asm
APIENTRY <"MessageBox",      4, "hWnd, lpText, lpCaption, uType">
APIENTRY <"CreateWindowEx", 12, "dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y, nWidth, nHeight, hWndParent, hMenu, hInstance, lpParam">
APIENTRY <"VirtualAlloc",    4, "lpAddress, dwSize, flAllocationType, flProtect">
```

---

## 13. Resource Editor

Designer visuale per risorse Windows con generazione automatica del file `.rc`.

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

## 14. Sistema di notifica aggiornamenti

`updater.asm` gestisce il controllo silenzioso degli aggiornamenti disponibili.

### Comportamento

- Eseguito in un thread separato all'avvio — non blocca l'interfaccia
- Interroga l'API GitHub: `GET https://api.github.com/repos/<owner>/AsmWorkbench/releases/latest`
- Confronta il campo `tag_name` della risposta con la versione corrente dell'eseguibile
- Se disponibile una versione più recente: mostra una notifica discreta nella **statusbar** (`⬆ v1.x disponibile`)
- Click sulla notifica: apre il browser sulla pagina delle release GitHub
- Il download e l'installazione restano **manuali** — l'utente decide quando aggiornare
- Disattivabile con `CheckUpdates=0` nel file INI

### Tecnologia

Usa esclusivamente `wininet.dll`, già presente su ogni installazione Windows. Nessuna dipendenza esterna.

### Perché non aggiornamento automatico

Un eseguibile non può sostituire se stesso mentre è in esecuzione. La soluzione (un `Updater.exe` esterno separato) aggiunge complessità non necessaria nelle fasi attuali del progetto. La notifica con download manuale è la scelta corretta per un tool di sviluppo, dove l'utente vuole sempre sapere cosa cambia prima di aggiornare.

---

## 15. Integrazione Assembler

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

## 16. Integrazione Debugger

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

## 17. Flusso messaggi Win32

```
WinMain
  │
  ├─► Theme_Load               (theme.asm)      ← prima di tutto
  ├─► RegisterClass            (mainwnd.asm)
  ├─► CreateMainWindow
  │     ├─► CreateToolbar      (toolbar.asm)
  │     ├─► CreateTabBar       (tabbar.asm)
  │     ├─► CreateRichEdit     (editor.asm)
  │     ├─► CreateStatusBar    (statusbar.asm)
  │     ├─► CreateProjectTree  (project.asm)
  │     └─► CreatePanels       (panelmgr.asm)
  │
  ├─► Updater_CheckAsync       (updater.asm)    ← thread separato
  │
  └─► Message Loop
        ├─► WM_CREATE       → inizializza sottocomponenti
        ├─► WM_SIZE         → ridisegna layout
        ├─► WM_COMMAND      → menu e toolbar
        ├─► WM_NOTIFY       → eventi da RichEdit e Tab Bar
        ├─► WM_DRAWITEM     → ridisegna tab custom
        ├─► WM_KEYDOWN      → shortcut tastiera
        ├─► WM_CLOSE        → controlla file non salvati
        └─► WM_DESTROY      → cleanup + PostQuitMessage
```

---

## 18. Convenzioni di codice

```asm
; Procedure: PascalCase con prefisso modulo
Editor_GetCurrentLine  proc
TabBar_DrawTab         proc
Theme_Load             proc
Syntax_ValidateToken   proc
Search_FindInProject   proc
IndentGuide_Repaint    proc

; Variabili globali (globals.inc): prefisso g_
g_hMainWnd    dd  0
g_hRichEdit   dd  0
g_Theme       THEME <>

; Variabili locali: prefisso lv_
lv_hDC        dd  0

; Costanti: UPPER_SNAKE_CASE
IDM_FILE_NEW        equ 1001
IDM_EDIT_FIND       equ 1101
IDM_EDIT_FINDALL    equ 1102
IDM_EDIT_REPLACE    equ 1103
IDM_VIEW_LIGHT      equ 3001
IDM_VIEW_DARK       equ 3002
IDM_VIEW_CUSTOM     equ 3003
IDM_VIEW_INDENT     equ 3004
```

Struttura di ogni procedura:

```asm
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

## 19. Roadmap di sviluppo

| Step | Modulo | Obiettivo | Stato |
|:----:|--------|-----------|:-----:|
| 1 | `AsmWorkbench.asm` + `WinMain.asm` + `RegisterWindowMainClass.asm` | Finestra principale funzionante | ✅ |
| 2 | `InitIde.asm` — StatusBar | StatusBar con 3 sezioni e testi | ✅ |
| 3 | `TabBar.asm` | Tab bar custom owner-draw con ● e × | ✅ |
| 4 | `Editor.asm` | RichEdit 4.1 embedded con gestione resize | ⬜ |
| 5 | `FileMgr.asm` | New / Open / Save / Save As / Save All | ⬜ |
| 6 | `Theme.asm` + `theme.inc` | Sistema temi Light / Dark / Custom | ⬜ |
| 7 | `Syntax.asm` | Highlighting + sottolineatura ondulata | ⬜ |
| 8 | `IndentGuide.asm` | Linee guida indentazione blocchi | ⬜ |
| 9 | `Toolbar.asm` | Toolbar icone con azioni principali | ⬜ |
| 10 | `Search.asm` | Ricerca e sostituzione file/progetto | ⬜ |
| 11 | `Project.asm` | Progetto `.awb` e project tree | ⬜ |
| 12 | `PanelMgr.asm` | Pannelli Output / Errori / Simboli / Ricerca | ⬜ |
| 13 | `Updater.asm` | Notifica aggiornamenti disponibili | ⬜ |
| 14 | Build | Integrazione assembler esterno | ⬜ |
| 15 | `SymTable.asm` | Parser simboli del progetto | ⬜ |
| 16 | `AsmSense.asm` | Autocomplete + Parameter Hints | ⬜ |
| 17 | Symbol Navigator | Pannello simboli con navigazione | ⬜ |
| 18 | `ResEditor.asm` | Resource editor visuale | ⬜ |
| 19 | Debugger | Integrazione debugger step-by-step | ⬜ |

Legenda: ⬜ Da fare · 🔄 In corso · ✅ Completato

---

## 20. Autori e partner

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

*Documento aggiornato: 2026 — AsmWorkbench è in sviluppo attivo — Step 1✅ 2✅ 3✅*
