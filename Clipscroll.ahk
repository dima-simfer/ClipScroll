#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force ;Не спрашивать о том, что может быть запущен только один инстанс.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

/*
Скрипт позволяет поочереди скопировать несколько строк, а затем так же поочереди их вставить. 
Удобно при переносе шлейфов или ответственных из документов в карточки объектов, когда нужно поочереди найти несколько ячеек или названий и т.д.
При копировании убираются пробелы и Табы в начале и в конце строки (Работает в момент копирования).
Добавить текст в список - Ctrl+Shift+c. 
Вставить текст из списка - Ctrl+Shift+v. После добавления новой строки вставка начнётся с самого начала, с первой строки.
Можно начать вставку с произвольной строки, дважды щёлкнув по ней ЛКМ. При этом содержимое строки также вставится в буфер обмена системы.
Очистить список - Ctrl+Shift+r или нажать на кнопку "Очистить".
Галка Добавить Tab в конце добавляет Tab после вставки строки. Работает в момент вставки. Можно одни строки вставить с Табом, потом снять галку и вставлять без таба.
Галка Добавить Enter в конце добавляет Enter после вставки строки (и после Таба, если стоит галка Добавить Tab). Работает в момент вставки. Можно одни строки вставить с Enter, потом снять галку и вставлять без Enter.
Галка "В одну строку" убирает переносы строк в тексте при вставке. Работает в момент вставки.
*/

Menu, Tray, Icon, Paste.ico
Gui, font, s9, Verdana  ; Set 9-point Verdana.
Gui, +AlwaysOnTop
Gui, Add, Text, , Добавить в список: Ctrl+Shift+c `nНачать поочереди вставлять: Ctrl+Shift+v `nДвойным щелчком по строке можно `nвыбрать начальную строку вставки.`nТакже строка скопируется в буфер.
Gui, Add, Text, , После добавления новой позиции `nвставка начнётся с первой строчки
Gui, Add, ListView, xs r10 w280 Grid gMyListView, Текст в буфере
Gui, Add, Text, , Очистить: Нажать на кнопку либо Ctrl+Shift+r
Gui, Add, Button, xs w100, Очистить 
Gui, Add, Checkbox, xp+120 yp+5 vAddTab, Добавить Tab в конце
Gui, Add, Checkbox, xp yp+25 vAddEnter, Добавить Enter в конце
Gui, Add, Checkbox, xp yp+25 vSingleLine Checked, В одну строку
Gui, Add, Button, xp-120 yp-10 w100, RELOAD
Gui, Show, % "x" A_ScreenWidth - 350 "y" A_ScreenHeight/2, ClipScroll
return

^Esc::
GuiClose: 
Gui, Minimize  ; Указываем, что при закрытии окна скрипт должен свернуться, а не закрыться.
;ExitApp, ; Указываем, что при закрытии окна скрипт должен закрыться.
return


ButtonRELOAD:         ;Кнопка быстрой перезагрузки для отладки, после введения в эксплуатацию закомментить.
Gui, Submit, NoHide
Reload
return

^+r::
ButtonОчистить:
LV_Delete() ; Очищаем список GUI.
return

^+c::
;OnClipboardChange: ; Можно добавлять на изменение буфера обмена. Тогда нужно закомментировать и строки Clipboard = , Send, ^c ниже.
gui, submit, NoHide
    Clipboard = 
    Send, ^c
    ClipWait,2
    NewLine := Clipboard
    LV_Add("", Trim(NewLine))
    Sleep, 50
    LV_ModifyCol()

    Loop % LV_GetCount()  ; После каждого добавления проверяем список и удаляем пустые строки. Нужно при копировании из экселя.
        {
        LV_GetText(RowText, A_Index,1) 
        ;MsgBox,,, В строке %A_Index% лежит %RowText%,1
        if ErrorLevel
            break
        if StrLen(RowText) = 0 
            {
                LV_Delete(A_Index)
            }
    
        }
RowNumber:=1
return

MyListView:
if A_GuiEvent = DoubleClick
{
    LV_GetText(TextToClipboard, A_EventInfo) 
    Clipboard:=TextToClipboard
    RowNumber:=LV_GetNext(0)
}
return

^+v::
gui, submit, NoHide
    {
    LV_GetText(TextToClipboard, RowNumber) 
    If (SingleLine)
    {
        TextToClipboard:=StrReplace(TextToClipboard, "`r`n", "")
    }
    SendInput {Raw}%TextToClipboard%
    if (AddTab)
        {
            SendInput {Tab}
        }
    if (AddEnter)
        {
            SendInput {Enter}
        }
    RowNumber:=RowNumber+1
    LV_Modify(RowNumber, "Focus ")
    LV_Modify(RowNumber, "Select")
    if RowNumber > % LV_GetCount()  ; The above returned zero, so there are no more selected rows.
        {
        ToolTip, Это была последняя строка
        Sleep, 1500
        ToolTip        
        }
    }
return


