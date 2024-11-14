.LOG
:: auth: wolf-li
:: date: 2024-11-14
:: version: v0.0.1
:: description: rename multi files in current directory

@echo off
:: file add prefix
set Prefix=first
for /r %%a in (*.docx) do ren "%%a" "%Prefix%%%~na"

:: file add subfix
set Subfix=last
for /r %%a in (*.docx) do ren "%%a" "%%~na%Subfix%"

