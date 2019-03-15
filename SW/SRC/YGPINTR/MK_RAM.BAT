@make -fram_make
@if ErrorLevel 1 goto HasErrors
@xcopy *.cmd f:
@xcopy *.ram f:
:HasErrors
@pause
@exit