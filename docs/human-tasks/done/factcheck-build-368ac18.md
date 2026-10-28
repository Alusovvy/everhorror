# Build 368ac18: arkusz do ogrania

> Zadania: [task_20](../../ai-tasks/done/task_20.md) · Przygotowano: 2026-10-28 · Gałąź: `spec/2026-10-28-task20`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis. Każda część poniżej to jedno zadanie z tego buildu; arkusz jest zamknięty, gdy zamknięte są wszystkie części.
> Zwolnienie: Roland (dashboard, 2026-10-28): Roland, czat 2026-10-28: ocena buildu test-master-0c0df0f podana w czacie, poprawki w task_39 (arkusz zwolniony, bez wpisów)
> Zamknięcie: Roland (dashboard), 2026-10-28 18:40

## Raport przebiegu: dołącz plik
Po zakończeniu otwarcia lub tygodnia kliknij w dashboardzie „Dołącz raport przebiegu”: para plików z folderu raportów gry trafia obok arkusza (`raporty/`), a linki do niej do tabeli. Jeśli raport nie powstał, zapisz to w uwagach.

<!-- człowiek -->
| Plik `.md` (człowiek) | Plik `.json` (człowiek) | Uwagi (człowiek) |
|---|---|---|
| | | |

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->

## Część: task_20 — czas grania w raporcie przebiegu

### Co zostało dodane
- Gra liczy, ile naprawdę grasz w każdym dniu (czas z zegara, nie godziny w grze). Liczy się tylko, gdy świat działa: menu główne i pauza (Esc) nie liczą się, rozmowy, mapa i notes tak. Gracz niczego nowego w grze nie widzi.
- Raport przebiegu (`.md` i `.json`) ma w tabeli czasu nową ostatnią kolumnę „czas realny dnia” (mm:ss) i sumę pod tabelą („Razem: …”). To samo w raporcie „Koniec otwarcia” i „Koniec tygodnia”. Gdzie nie ma danych, jest „—”.
- Czas jest w zapisie gry jako pole opcjonalne; wersja zapisu bez zmian. Zapis z gry sprzed tej zmiany wczytuje się normalnie, a jego dzień w toku i dni wcześniejsze pokazują „—”. Po śmierci i powtórce poranka czas nieudanej próby dolicza się do dnia.

### Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Kolumna czasu w raporcie po rozegranym dniu | zagraj otwarcie (START) co najmniej dzień 1 z kilkoma minutami przerwy w menu pauzy (Esc), potem zapisz raport (pauza → SAVE REPORT) albo dograj do końca i dołącz raport; otwórz `.md` | w tabeli „Czas według kategorii” ostatnia kolumna „czas realny dnia” z wiarygodną wartością dla dnia 1 (zbliżoną do czasu, który faktycznie grałeś, bez czasu w pauzie) i linia „Razem: mm:ss” pod tabelą; w `.json` pola `played_ms` i `played_total_ms` | | |
| 2 | Stary zapis | wczytaj zapis zrobiony w grze sprzed tego buildu (LOAD GAME), zagraj chwilę, zapisz raport z pauzy | wczytanie bez błędu; w raporcie kolumna „czas realny dnia” ma „—” dla dni sprzed wczytania, a „Razem: —” albo sumę tylko z dni zagranych po wczytaniu | | |

### Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| unit | `tools/run_tests.sh unit` | ALL PASSED (z nowymi sprawdzeniami task_20 i bez zmian testem zapisów G-E4 v3…v6) | `reports/tests/unit.log` |
| lint | `tools/run_tests.sh lint` | ALL PASSED, 20 ostrzeżeń | `reports/tests/lint.log` |
| dialogue | `tools/run_tests.sh dialogue` | ALL PASSED | `reports/tests/dialogue.log` |
| opening | `tools/run_tests.sh opening` | ALL PASSED | `reports/tests/opening.log` |
| day1 | `tools/run_tests.sh day1` | ALL PASSED | `reports/tests/day1.log` |
| save_load | `tools/run_tests.sh save_load` | ALL PASSED (licznik rośnie w świecie, stoi przy pauzie) | `reports/tests/save_load.log` |
| week | `tools/run_tests.sh week` | ALL PASSED (powtórka poranka) | `reports/tests/week.log` |
