# Новый Пълдин-601

Это проект 8-битного компьютера, программно совместимого с Пълдин-601 на уровне приложений. 

[Видео на Youtube](https://www.youtube.com/watch?v=-_IdSySlPXs)

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/-_IdSySlPXs/0.jpg)](https://www.youtube.com/watch?v=-_IdSySlPXs)

Проект включает в себя не только аппаратную часть, но и BIOS, системные ПЗУ, операционную систему и утилиты для работы с обновленным железом.

## Устройство компьютера

Минимальная рабочая конфигурация требует только [плату процессора](cpu-mem.md), источник питания 5 вольт и последовательный порт (с пятивольтовыми уровнями). Для полноценной работы с возможностью использования клавиатуры, дисплея, sd карты, звука, необходима [плата периферии](ext-mod.md).

[Плата процессора](cpu-mem.md)

[Плата периферии](ext-mod.md)

## Программное обеспечение

### Средства разработки

#### Ассемблер

[UniAS](unias.md) является основным и главным системным ассемблером, поддерживающим новые команды процессора HD6303 и используется для сборки все системных прошивок ПЗУ, UniDOS и утилит.

[Ассемблер UniAS](unias.md)

[Ассемблер UniASM](https://pyldin.info/document/uniasm_rus.htm)

[Ассемблер UniCross](https://pyldin.info/document/unicross_rus.htm)

#### Интерпретатор Basic

[UniBASIC](https://pyldin.info/document/unibasic_rus.htm)

#### Компилятор Small-C

[Small-C](small-c.md)

#### Компилятор Паскаля

[UniPASCAL часть 1](https://pyldin.info/document/unipas_rus.htm)
[UniPASCAL часть 2](https://pyldin.info/document/unipas2_rus.htm)

