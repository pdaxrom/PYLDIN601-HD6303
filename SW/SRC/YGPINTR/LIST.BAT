68 y1 y1.lst nul
@if errorlevel 1 goto error
68 y2 y2.lst nul
@if errorlevel 1 goto error
@goto end
:error
@echo ��� ������ �� ����� �� ����������
:end
