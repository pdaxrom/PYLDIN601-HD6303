@echo Insert Back Up disk for Ycode interpreter in drive A:
@pause
@ChkVol a:Ycode 1.50+ > nul
@if ErrorLevel 1 goto hasError
@xcopy *.y      a: /v /m
@xcopy *.asm   a: /v /m
@xcopy *.     a: /v /m
@xcopy *.inc a: /v /m
@goto end
:hasError
@echo Volume label is not Ycode 1.50+
:end
