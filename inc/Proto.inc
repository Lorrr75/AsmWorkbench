; Prototipi di funzione

WinMain 			proto :DWORD, :DWORD, :DWORD, :DWORD
RegisterWindowMainClass 	proto
MainWndProc 			proto :DWORD, :DWORD, :DWORD, :DWORD
InitIde				proto :DWORD

TabBar_RegisterClass		proto
TabBar_Create			proto :DWORD
TabBar_WndProc			proto :DWORD, :DWORD, :DWORD, :DWORD
TabBar_DrawTab			proto :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
TabBar_AddTab 			proto :DWORD, :DWORD, :DWORD
TabBar_RemoveTab		proto :DWORD
TabBar_GetTabWidth 		proto :DWORD, :DWORD, :DWORD

Editor_Init             	proto
Editor_ApplySettings    	proto :DWORD
Editor_CreateForTab     	proto :DWORD
Editor_ActivateTab      	proto :DWORD
Editor_Resize           	proto :DWORD, :DWORD
Editor_RehighlightAll 		proto :DWORD

FileMgr_New			proto
FileMgr_Open			proto
FileMgr_LoadFile		proto :DWORD
FileMgr_Save      		proto
FileMgr_SaveAs    		proto
FileMgr_WriteFile 		proto :DWORD

Theme_Load      		proto :DWORD
Theme_LoadLight 		proto
Theme_LoadDark  		proto
Theme_Apply     		proto
Theme_ApplyToEditor 		proto :DWORD

Syntax_HighlightLine    	proto :DWORD, :DWORD
Syntax_SetColor         	proto :DWORD, :DWORD, :DWORD, :DWORD
Syntax_HighlightComment 	proto :DWORD, :DWORD, :DWORD, :DWORD
Syntax_HighlightStrings 	proto :DWORD, :DWORD, :DWORD, :DWORD
Syntax_HighlightNumbers 	proto :DWORD, :DWORD, :DWORD, :DWORD
Syntax_HighlightKeywords 	proto :DWORD, :DWORD, :DWORD, :DWORD
Syntax_IsRegister       	proto :DWORD
Syntax_IsMnemonic       	proto :DWORD
Syntax_IsDirective      	proto :DWORD
Syntax_HighlightDotDirectives proto :DWORD, :DWORD, :DWORD, :DWORD