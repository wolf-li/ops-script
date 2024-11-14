Rem auth: wolf-li
Rem date: 2024-11-15
Rem version: v0.0.1
Rem description: text reading
Rem OS: windows

Message=InputBox("请在下方输入文字")
Set Speak=CreateObject("sapi.spvoice")
Speak.Speak Message
