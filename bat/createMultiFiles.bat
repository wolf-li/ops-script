.LOG
:: auth: wolf-li
:: date: 2024-11-14
:: version: v0.0.1
:: description: create mulit file such as 1.docx 2.docx ...

for /l %%y in (0,1,10) do echo "" 2> %%y".docx"
