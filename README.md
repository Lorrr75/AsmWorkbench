# AsmWorkbench

> \*\*Un IDE professionale per Assembly x86 su Windows — scritto interamente in Assembly x86.\*\*

\---



## Lingua

Il progetto verrà sviluppato in italiano e poi tradotto appena raggiunto

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
* Numerazione delle righe
* Salvataggio automatico e ripristino sessione

### Syntax Highlighting

* Colorazione sintattica per mnemonici x86, registri, direttive MASM
* Evidenziazione commenti, stringhe, costanti numeriche
* Temi di colore configurabili

### AsmSense — Paragonabile a IntelliSense di Microsoft per Assembly

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
AsmWorkbench.asm          ← Entry point, include di tutto il progetto
src/
├── WinMain.asm           ← Corpo principale e message loop
├── MainWndProc.asm       ← Gestione messaggi finestra principale
├── RegisterWindowMainClass.asm ← Registrazione classe finestra
├── InitIde.asm           ← Inizializzazione componenti (WM_CREATE)
├── TabBar.asm            ← Tab bar custom owner-draw        ← IN CORSO
├── Editor.asm            ← Wrapper RichEdit                 [futuro]
├── Syntax.asm            ← Syntax highlighting              [futuro]
├── Toolbar.asm           ← Toolbar icone                    [futuro]
├── FileMgr.asm           ← Gestione file                    [futuro]
├── Project.asm           ← Gestione progetto .awb           [futuro]
├── PanelMgr.asm          ← Layout pannelli                  [futuro]
├── Theme.asm             ← Sistema temi e colori            [futuro]
├── SymTable.asm          ← Database simboli (AsmSense)      [futuro]
├── AsmSense.asm          ← Autocomplete e parameter hints   [futuro]
└── ResEditor.asm         ← Resource editor visuale          [futuro]
inc/
├── CommonHeader.inc      ← Header MASM32
├── CommonLib.inc         ← Librerie di sistema
├── Proto.inc             ← Prototipi funzioni
├── constants.inc         ← Costanti, stringhe, ID controlli
├── globals.inc           ← Variabili globali
└── structs.inc           ← Strutture dati custom
```

### Layout finestra principale

```
┌──────────────────────────────────────────────────────────┐
│  File  Modifica  Visualizza  Progetto  Build  Strumenti  │
├──────────────────────────────────────────────────────────┤
│  \[Nuovo]\[Apri]\[Salva]  |  \[Build]\[Esegui]\[Stop]    │
├──────────────────────────────────────────────────────────┤
│  \[main.asm]  \[utils.asm ●]  \[resource.rc]  \[+]       │
├──────────────────┬───────────────────────────────────────┤
│  Project Tree    │   Editor                              │
│                  │                                       │
│  ▼ AsmWorkbench  │   1  .386                             │
│    main.asm      │   2  .model flat, stdcall             │
│    utils.asm     │   3  option casemap:none              │
│    resource.rc   │   4                                   │
│                  │   5  include windows.inc              │
├──────────────────┴───────────────────────────────────────┤
│  ▼ Output     ▼ Errori     ▼ Simboli                     │
│  Build completato — 0 errori, 0 warning                  │
├──────────────────────────────────────────────────────────┤
│  Ln 5   Col 12  │  x86  │  INS  │  main.asm              │
└──────────────────────────────────────────────────────────┘
```

\---

## Roadmap

|Step|Modulo|Obiettivo|Stato|
|:-:|-|-|:-:|
|1|`AsmWorkbench.asm` + `WinMain.asm` + `RegisterWindowMainClass.asm`|Finestra principale funzionante|✅|
|2|`InitIde.asm` — StatusBar|StatusBar con 3 sezioni e testi|✅|
|3|`TabBar.asm`|Tab bar custom owner-draw con ● e ×|✅|
|4|`Editor.asm`|RichEdit 4.1 embedded con gestione resize|✅|
|5|`FileMgr.asm`|New / Open / Save / Save As|✅|
|6|`Theme.asm`|Sistema temi Light / Dark / Custom|✅|
|7|`Syntax.asm`|Syntax highlighting + sottolineatura ondulata|🔄|
|8|`IndentGuide.asm`|Linee guida indentazione blocchi|⬜|
|9|`Toolbar.asm`|Toolbar icone con azioni principali|⬜|
|10|`Search.asm`|Ricerca e sostituzione file/progetto|⬜|
|11|`Project.asm`|Progetto `.awb` e project tree|⬜|
|12|`PanelMgr.asm`|Pannelli Output / Errori / Simboli|⬜|
|13|`Updater.asm`|Notifica aggiornamenti disponibili|⬜|
|14|Build|Integrazione assembler esterno|⬜|
|15|`SymTable.asm`|Parser simboli del progetto|⬜|
|16|`AsmSense.asm`|Autocomplete + Parameter Hints|⬜|
|17|Symbol Navigator|Pannello simboli con navigazione|⬜|
|18|`ResEditor.asm`|Resource editor visuale|⬜|
|19|Debugger|Integrazione debugger step-by-step|⬜|

Legenda: ⬜ Da fare · 🔄 In corso · ✅ Completato

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
├── AsmWorkbench.asm  ← Entry point
├── src/              ← Sorgenti assembly
├── inc/              ← File include (globals, structs, constants)
├── res/              ← Risorse (icone)
├── docs/             ← Documentazione tecnica
├── make.bat          ← Script di build
├── README.md
└── LICENSE EUPL-1.2.txt
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

Questo progetto è distribuito sotto European Union Public Licence v. 1.2 (EUPL-1.2).

La EUPL 1.2 è una licenza copyleft approvata dalla Commissione Europea, disponibile in tutte le lingue ufficiali dell'UE. In sintesi:



* Sei libero di usare, studiare, modificare e distribuire il software
* Se distribuisci versioni modificate, devi farlo sotto la stessa licenza
* Il codice sorgente deve essere sempre disponibile
* La legge applicabile è quella italiana (paese del licenziante)



Testo completo: https://eupl.eu/1.2/it/

\---

> \*"Il modo migliore per capire una macchina è scrivere per lei nella sua lingua."\*

\---

*Progetto avviato nel 2026 — Sviluppo attivo — Step 1✅ 2✅ 3🔄*

