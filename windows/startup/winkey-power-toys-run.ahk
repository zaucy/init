#SingleInstance, Force
#NoEnv
#NoTrayIcon
SendMode Input

*LWin::SendInput, {Blind}{vk00}{LAlt Down}
return

*LWin Up::
    if (A_PriorKey = "LWin") {
        SendInput {vk00}{LAlt Down}{Space Down}{vk00}{LAlt Up}{Space Up}
        SendInput, {vk00}{LAlt Up}
    } else {
        if GetKeyState("LWin" "P") {
            SendInput, {Blind}{vk00}{Lwin Down} ; If user still pressing win, stay down
        } Else {
            SendInput, {Blind}{vk00}{Lwin Up} ; Else, the release adds a null({vk00}) key to prevent the start menu from opening.
        }
    }
return

LWin & Space::
    SendInput !{Space}
return