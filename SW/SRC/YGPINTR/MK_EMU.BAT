@make -femu_make
@if ErrorLevel 1 goto HasErrors
cd \emulator
pyldin
cd \i
:HasErrors
@pause
@exit