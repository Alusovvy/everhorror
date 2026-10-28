# Build 333b147: arkusz do ogrania

> Zadania: [task_22](../ai-tasks/task_22.md) · Przygotowano: 2026-10-28 · Gałąź: `spec/2026-10-28-task22`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis. Każda część poniżej to jedno zadanie z tego buildu; arkusz jest zamknięty, gdy zamknięte są wszystkie części.

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->

## Część: task_22 — Narzędzia procesu: flagi, liczba żył w tekstach, lint polskich literałów, skrypt wydania

### Co zostało dodane
- Gra się nie zmienia: teksty o normie żył („dwanaście żył”) w intro, u Racibora, Mirosława (także gwara) i w notesie składa teraz `quota_words()` z jednej liczby `QUOTA`, ale wyglądają dokładnie jak przedtem.
- Lint zapisuje rejestr flag (`reports/flags.tsv`), z którego `write_flags_doc.js` robi `docs/agent/flags.md` (234 flagi).
- Lint pilnuje, żeby norma nie wracała do tekstów słowami (T7), i żeby liczba polskich literałów w `script/` tylko spadała (K6, `tools/lint_baseline.json`).
- `tools/release/release.sh <wersja> [--spec <rev>] [--dry-run]`: sześć kroków wydania w jednym skrypcie, bez tagu i pushu.
- Uprawnienia agenta (`.claude/settings.json`, P1) **nie są w tym buildzie**: przebieg z dashboardu nie może zapisywać w `.claude/`. Propozycja diffu jest w raporcie zadania.

### Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Wstęp do gry | nowa gra, przeczytać wstęp | „…Kniaź chce mieć na mapie dwanaście żył błękitu. Ósmego dnia rano przyjdzie po raport wóz.” bez zmian | | |
| 2 | Racibor, pierwsza rozmowa | „Po co właściwie tu jesteśmy?” i „Znam mapy dziadka…” | „…zobaczyć dwanaście żył na mapie” oraz „Kniaź chce dwunastu żył do wieczora siódmego dnia” | | |
| 3 | Wpis w notesie | po przyjęciu zadania otworzyć notes (J), zakładka zadań | wpis „Kniaź chce dwunastu żył błękitu na mapie do wieczora siódmego dnia…” | | |
| 4 | Mirosław, dzień 3 | porozmawiać z Mirosławem 3. dnia (gwara włączona i wyłączona) | „Tydzień, mówi Racibor. Dwanaście żył. A potem fedrujemy na całego.” (wersja śląska: „Tydziyń, godo Racibor…”) | | |
| 5 | `release.sh --dry-run` | w terminalu: `tools/release/release.sh 0.5.5 --dry-run` (wymaga bitu wykonywania: `git update-index --chmod=+x`) | wypisuje sześć kroków i polecenia git, niczego nie uruchamia | | |
| 6 | `docs/agent/flags.md` | otworzyć plik | tabela flag z kolumnami „ustawiana w / czytana w / ładunek”, część dla rodzin `vein_*`, `visited_*` | | |

### Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| unit | `tools/run_tests.sh unit` | ALL PASSED (w tym nowe przypadki `quota_words` i wpisów „zloza”) | `reports/tests/unit.log` |
| lint | `tools/run_tests.sh lint` | ALL PASSED (nowe reguły T7 i K6, zapis `flags.tsv`) | `reports/tests/lint.log` |
| dialogue | `tools/run_tests.sh dialogue` | ALL PASSED (w tym linia Mirosława z gwarą i bez) | `reports/tests/dialogue.log` |
