# Компилятор Small-C

[Small-C](https://en.wikipedia.org/wiki/Small-C) является подмножеством языка C и оптимизирован для использования на системах
с ограниченными ресурсами. Он используется для сборки [ассемблера UniAS](unias.md) и самого себя.

## Запуск компилятора:

`unicc [-ctext] [-errstop] [-o outputfile] inputfile`

`-ctext` - включить строки программы в комментарии ассемблерного листинга

`-errstop` - останавливать компиляцию на ошибке

`-o outputfile` - название выходного файла

## Пример использования

С помощью редактора текста создайте программу hello.c следующего содержания:

```C
main()
{
  puts("Hello, world!");
}
```

Скомпилируйте программу:

`unicc hello.c`

Получившийся ассемблерный файл ассемблируйте в бинарный:

`unias hello.asm`

Запустите собранную программу:

`hello`

[Видео на Youtube](https://www.youtube.com/watch?v=PHO3cEp_rjQ)

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/PHO3cEp_rjQ/0.jpg)](https://www.youtube.com/watch?v=PHO3cEp_rjQ)
