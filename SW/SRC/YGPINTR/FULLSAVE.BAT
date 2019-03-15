@echo Insert Back Up disk for Ycode interpreter in drive A:
@pause
@ChkVol a:Ycode 1.65+ > nul
@if ErrorLevel 1 goto hasError
@xcopy *.y*         a: /v
@xcopy *.asm       a: /v
@xcopy *.         a: /v
@xcopy *.inc     a: /v
@xcopy *.bat	a: /v
@goto end
:hasError
@echo Volume label is not Ycode 1.50+
:end