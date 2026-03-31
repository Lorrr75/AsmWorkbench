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

Editor_Init    	 		proto
Editor_Create   		proto :DWORD
Editor_Resize   		proto :DWORD, :DWORD
Editor_SetDefaultSettings 	proto

FileMgr_New			proto
FileMgr_Open			proto
FileMgr_LoadFile		proto :DWORD
FileMgr_Save      		proto
FileMgr_SaveAs    		proto
FileMgr_WriteFile 		proto :DWORD

