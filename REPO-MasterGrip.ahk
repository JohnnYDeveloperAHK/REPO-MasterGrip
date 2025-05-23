#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
#SingleInstance force
SetTitleMatchMode, 3  ; Exact match mode

; === GAME WINDOW CHECK ===
possibleTitles := ["REPO", "R.E.P.O."]
gamePID := ""

Loop, % possibleTitles.MaxIndex()
{
    title := possibleTitles[A_Index]
    WinGet, pid, PID, %title%
    if (pid)
    {
        gamePID := pid
        break
    }
}

if (!gamePID)
{
    MsgBox, 48, Game Not Running, The game "REPO" or "R.E.P.O." is not currently running. Exiting script.
    ExitApp
}

; === GUI SETUP ===
gui_controls_dir := "REPO-MasterGrip.png"
GUI, New, -Caption +SysMenu +ToolWindow
GUI, Add, Picture, x0 y0 w630 h229 vMyPic gGuiMove, %gui_controls_dir%

; Center GUI
SysGet, MonitorWidth, 78
SysGet, MonitorHeight, 79
xPos := (MonitorWidth // 2) - (630 // 2)
yPos := (MonitorHeight // 2) - (229 // 2)
GUI, Show, x%xPos% y%yPos% w630 h229, REPO-MasterGrip

; Start monitor for game process
SetTimer, CheckGameAlive, 500

; GUI Move Logic
GuiMove:
if (A_GuiEvent = "Normal" || A_GuiEvent = "DoubleClick")
{
    PostMessage, 0xA1, 2,,, A  ; WM_NCLBUTTONDOWN + HTCAPTION
}
Return

; === MAIN LOOP ===
Turnwize:
Loop
{
    GetKeyState, state1, XButton1, P
    if (state1 = "D")
    {
        Send, {WheelDown}
        continue
    }

    GetKeyState, state2, XButton2, P
    if (state2 = "D")
    {
        Send, {WheelUp}
        continue
    }

    GetKeyState, rbtn, RButton, P
    if (rbtn = "D")
    {
        GetKeyState, eKey, E, P
        if (eKey = "D")
        {
            DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", 100)
            continue
        }

        GetKeyState, qKey, Q, P
        if (qKey = "D")
        {
            DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", -100)
            continue
        }
    }

    Sleep, 10
}
Return

; === Process Checker ===
CheckGameAlive:
if !ProcessExist(gamePID)
{
    ExitApp
}
Return

; Helper function
ProcessExist(pid) {
    Process, Exist, %pid%
    return ErrorLevel
}

; === GUI CLOSE HANDLER ===
GuiClose:
GuiEscape:  ; Handles ALT+F4 and Escape
ExitApp

; Manual Exit Hotkey
F1::ExitApp
