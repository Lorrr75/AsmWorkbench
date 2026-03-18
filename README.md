# AsmWorkbench

> \*\*Un IDE professionale per Assembly x86 su Windows — scritto interamente in Assembly x86.\*\*

\---

## Indice

* [Panoramica](#panoramica)
* [Filosofia del progetto](#filosofia-del-progetto)
* [Funzionalità previste](#funzionalità-previste)
* [Architettura](#architettura)
* [Roadmap](#roadmap)
* [Requisiti](#requisiti)
* [Struttura del repository](#struttura-del-repository)
* [Come contribuire](#come-contribuire)
* [Autori e partner](#autori-e-partner)
* [Licenza](#licenza)

\---

## Panoramica

**AsmWorkbench** è un ambiente di sviluppo integrato (IDE) dedicato esclusivamente alla programmazione in Assembly x86 su piattaforma Windows. Il progetto nasce da un'idea semplice ma ambiziosa: offrire a chi programma in Assembly uno strumento moderno, completo e autonomo — senza dover ricorrere a un insieme di tool eterogenei come si era costretti a fare ai tempi del DOS.

A differenza degli IDE generici come Visual Studio o VS Code, AsmWorkbench è:

* **Scritto in Assembly x86** usando MASM32 — lo strumento parla la stessa lingua del codice che edita
* **Progettato specificamente per Assembly** — ogni funzionalità ha senso nel contesto dell'assembly x86
* **Completamente autonomo** — integra editor, assembler, debugger e resource editor in un unico eseguibile leggero

\---

## Filosofia del progetto

La programmazione in Assembly richiede precisione, consapevolezza e strumenti che non nascondano la realtà della macchina. AsmWorkbench abbraccia questa filosofia: nessun layer inutile, nessuna dipendenza esterna pesante, nessuna astrazione che nasconda quello che sta succedendo sotto.

L'obiettivo non è "fare come Visual Studio" — è offrire **lo stesso livello di comodità** a chi sceglie consapevolmente di programmare a basso livello.

\---

## Funzionalità previste

### Editor

* Editor di testo basato su RichEdit con gestione multi-file a **tab custom**
* Indicatore visivo di file modificato (`●`) e pulsante di chiusura (`×`) per ogni tab
* Chiusura con click centrale del mouse
* Numbering delle righe
* Salvataggio automatico e ripristino sessione

### Syntax Highlighting

* Colorazione sintattica per mnemonici x86, registri, direttive MASM
* Evidenziazione commenti, stringhe, costanti numeriche
* Temi di colore configurabili

### AsmSense — IntelliSense per Assembly

* **Autocomplete** per mnemonici x86, registri, simboli del progetto
* **Parameter hints** per `INVOKE` — mostra la firma completa delle API Win32
* **Database API Win32** precompilato e integrato
* **Symbol Navigator** — lista di tutte le proc/label del progetto con navigazione rapida

### Gestione Progetto

* File di progetto `.awb` (AsmWorkbench Project)
* Project tree nel pannello laterale
* Supporto multi-file con entry point configurabile

### Build integrato

* Integrazione con assembler custom (sviluppato in parallelo)
* Pannello Output con risultati di compilazione
* Pannello Errori con navigazione diretta alla riga incriminata

### Resource Editor

* Designer visuale per risorse Windows (dialog, menu, stringhe, icone)
* Generazione automatica del file `.rc`
* Anteprima in tempo reale

### Debugger integrato

* Step-by-step con visualizzazione registri e flag
* Breakpoint sulla sorgente
* Ispezione memoria e stack
* Visualizzazione disassembly in tempo reale

\---

## Architettura

AsmWorkbench è composto da moduli separati con responsabilità precise:

```
src/
├── main.asm          ← Entry point, WinMain, message loop
├── mainwnd.asm       ← Finestra principale + WndProc
├── tabbar.asm        ← Tab bar custom owner-draw
├── editor.asm        ← Wrapper RichEdit
├── syntax.asm        ← Syntax highlighting
├── toolbar.asm       ← Toolbar
├── statusbar.asm     ← Barra di stato (riga/colonna/modificato)
├── filemgr.asm       ← Gestione file (open/save/dialog)
├── project.asm       ← Gestione progetto .awb
├── panelmgr.asm      ← Layout pannelli ridimensionabili
├── config.asm        ← Configurazione (file INI)
├── symtable.asm      ← Parser e database simboli (AsmSense)
├── asmsense.asm      ← UI autocomplete e parameter hints
├── reseditor.asm     ← Resource editor visuale
└── macros.inc        ← Macro Win32 condivise
```

### Layout finestra principale

```
┌──────────────────────────────────────────────────────────┐
│  File  Modifica  Visualizza  Progetto  Build  Strumenti  │
├──────────────────────────────────────────────────────────┤
│  \[Nuovo]\[Apri]\[Salva]  |  \[Build]\[Esegui]\[Stop]          │
├──────────────────────────────────────────────────────────┤
│  \[main.asm]  \[utils.asm ●]  \[resource.rc]  \[+]           │
├──────────────────┬───────────────────────────────────────┤
│  Project Tree    │   Editor                               │
│                  │                                        │
│  ▼ AsmWorkbench  │   1  .386                              │
│    main.asm      │   2  .model flat, stdcall              │
│    utils.asm     │   3  option casemap:none               │
│    resource.rc   │   4                                    │
│                  │   5  include windows.inc               │
├──────────────────┴───────────────────────────────────────┤
│  ▼ Output     ▼ Errori     ▼ Simboli                      │
│  Build completato — 0 errori, 0 warning                   │
├──────────────────────────────────────────────────────────┤
│  Ln 5   Col 12  │  x86  │  INS  │  main.asm              │
└──────────────────────────────────────────────────────────┘
```

\---

## Roadmap

|Step|Modulo|Obiettivo|
|:-:|-|-|
|1|`main.asm` + `mainwnd.asm`|Finestra principale con menu base|
|2|`tabbar.asm`|Tab bar custom owner-draw con ● e ×|
|3|`editor.asm`|RichEdit embedded con gestione resize|
|4|`filemgr.asm`|New / Open / Save / Save As|
|5|`statusbar.asm`|Riga, colonna, flag modificato|
|6|`syntax.asm`|Syntax highlighting mnemonici e registri|
|7|`toolbar.asm`|Toolbar con azioni principali|
|8|`project.asm`|Progetto `.awb` e project tree|
|9|`panelmgr.asm`|Pannelli Output / Errori / Simboli|
|10|Build|Integrazione assembler esterno|
|11|`symtable.asm`|Parser simboli del progetto|
|12|`asmsense.asm`|Autocomplete + Parameter Hints|
|13|Symbol Navigator|Pannello simboli con navigazione|
|14|`reseditor.asm`|Resource editor visuale|
|15|Debugger|Integrazione debugger step-by-step|

\---

## Requisiti

### Per compilare AsmWorkbench

* **MASM32 SDK** — [www.masm32.com](http://www.masm32.com)
* **Windows XP o superiore** (target: Windows 7+)
* Nessuna dipendenza esterna — solo le DLL standard di Windows

### Per sviluppare

* MASM32 installato in `C:\\masm32`
* Un editor di testo (in attesa che AsmWorkbench editi se stesso 😄)
* `make.bat` incluso nel repository per la compilazione

\---

## Struttura del repository

```
AsmWorkbench/
├── src/          ← Sorgenti assembly
├── inc/          ← File include (globals, structs, constants, apidb)
├── res/          ← Risorse (RC, bitmap, icone)
├── build/        ← Output compilazione (non versionato)
├── docs/         ← Documentazione tecnica
├── make.bat      ← Script di build
└── README.md
```

\---

## Come contribuire

Il progetto è nelle fasi iniziali di progettazione. Ogni contributo è benvenuto:

* **Segnalazione di problemi** tramite la sezione Issues
* **Suggerimenti architetturali** tramite Discussions
* **Codice** tramite Pull Request, seguendo le convenzioni di stile del progetto

Le convenzioni di codice e le linee guida per i contributi saranno pubblicate nella cartella `docs/` con l'avanzare del progetto.

\---

## Autori e partner

**Ideazione, progettazione e sviluppo**

* Lorrr75 (Lorenzo Rosa) — Ideatore del progetto, sviluppatore principale

**Partner di progettazione e sviluppo**

* **Claude** (Anthropic) — Partner AI per la progettazione architetturale, la revisione del codice, la stesura della documentazione e lo sviluppo collaborativo dell'intero progetto. Coinvolto dall'inizio nella definizione di architettura, strutture dati, roadmap e scelte tecniche.

\---

## Licenza

Questo progetto sarà rilasciato sotto licenza **MIT** — libero per uso personale e commerciale, con obbligo di attribuzione.

La scelta definitiva della licenza verrà confermata prima della prima release pubblica.

\---

> \*"Il modo migliore per capire una macchina è scrivere per lei nella sua lingua."\*

\---

*Progetto avviato nel 2026 — Sviluppo attivo*

