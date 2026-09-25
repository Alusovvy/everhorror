# Factcheck test 07: cztery warstwy testów i serwer `godot-runtime`

> Zadanie: [task_07](../ai-tasks/task_07.md) · Przygotowano: 2026-09-25 · Czas: ~15 min
> To sprawdzenie narzędzi deweloperskich, nie gry — w grze jest tylko punkt 3.

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Nowe testy | W terminalu, w folderze gry: `tools/run_tests.sh unit lint schedule` | Trzy linie `RESULT: ALL PASSED`, razem poniżej 10 s | | |
| 2 | Strażnik błędów | Otwórz `reports/tests/schedule.log` | Brak linii `SCRIPT ERROR`; log kończy się RESULT | | |
| 3 | Wpis o wywiezieniu Nasira | W grze: zacznij zadanie „Gorączka Nasira” u Anzelma i NIE lecz Nasira do końca tygodnia | W noc, gdy go wywożą: zadanie w notesie „nieudane” z wpisem „Nasira wywieźli na górę w gorączce. Nie zdążyłem.” | | |
| 4 | Serwer `godot-runtime` | Po restarcie Claude Code poproś agenta: „sprawdź połączenie godot-runtime i zrób dymny test: M otwiera mapę” | Agent uruchamia grę w tle, symuluje klawisz, pokazuje zrzut z otwartą mapą | | |

## Twoje uwagi / propozycje

-
