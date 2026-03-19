.386

.code

;
; Funzione di gestione dei messaggi che provengono da windows
; 
;
MainWndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL	hdc:HDC
LOCAL	ps:PAINTSTRUCT
LOCAL	rect:RECT

	.IF uMsg == WM_DESTROY
		invoke PostQuitMessage, NULL

	.ELSEIF uMsg == WM_CREATE

	.ELSEIF uMsg == WM_PAINT
		invoke	BeginPaint, hWnd, ADDR ps
		invoke	EndPaint, hWnd, ADDR ps
		ret
		
	.ELSEIF uMsg == WM_COMMAND
	
	.ELSEIF uMsg == WM_CLOSE
		invoke	DestroyWindow, hWnd
	.ELSEIF uMsg == WM_SIZE
	.ELSEIF uMsg == WM_MOVE
	.ELSEIF uMsg == WM_MOUSEMOVE
	.ELSEIF uMsg == WM_LBUTTONDOWN
	.ELSEIF uMsg == WM_MBUTTONDOWN
	.ELSEIF uMsg == WM_RBUTTONDOWN
	.ELSEIF uMsg == WM_LBUTTONUP
	.ELSEIF uMsg == WM_MBUTTONUP
	.ELSEIF uMsg == WM_RBUTTONUP
	.ELSEIF uMsg == WM_KEYDOWN
	.ELSEIF uMsg == WM_KEYUP
	.ELSEIF uMsg == WM_CHAR
	.ELSEIF uMsg == WM_TIMER


	.ELSE
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
		ret
	.ENDIF

	xor	eax, eax
	ret
MainWndProc	endp