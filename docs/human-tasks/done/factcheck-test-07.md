# Factcheck test 07: cztery warstwy testów i serwer `godot-runtime`

> Zadanie: [task_07](../../ai-tasks/done/task_07.md) · Przygotowano: 2026-09-25 · Czas: ~15 min
> To sprawdzenie narzędzi deweloperskich, nie gry — w grze jest tylko punkt 3.

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Nowe testy | W terminalu, w folderze gry: `tools/run_tests.sh unit lint schedule` | Trzy linie `RESULT: ALL PASSED`, razem poniżej 10 s | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) |
| 2 | Strażnik błędów | Otwórz `reports/tests/schedule.log` | Brak linii `SCRIPT ERROR`; log kończy się RESULT | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) |
| 3 | Wpis o wywiezieniu Nasira | W grze: zacznij zadanie „Gorączka Nasira” u Anzelma i NIE lecz Nasira do końca tygodnia | W noc, gdy go wywożą: zadanie w notesie „nieudane” z wpisem „Nasira wywieźli na górę w gorączce. Nie zdążyłem.” | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) |
| 4 | Serwer `godot-runtime` | Po restarcie Claude Code poproś agenta: „sprawdź połączenie godot-runtime i zrób dymny test: M otwiera mapę” | Agent uruchamia grę w tle, symuluje klawisz, pokazuje zrzut z otwartą mapą | ✅ (agent, 2026-09-26) | M w obozie: podpowiedź; M w Starej sztolni: mapa „Dokąd dalej?”; I/J też działają. Zrzuty w `.mcp/godot-runtime/screenshots/` |
> **Status:** zweryfikowane przez użytkownika 2026-09-26 (przegląd bez wpisanych uwag; puste wiersze uzupełnił agent).


## Twoje uwagi / propozycje

-
