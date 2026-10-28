# Build 333b147: arkusz do ogrania

> Zadania: [task_22](../ai-tasks/task_22.md), [task_25](../ai-tasks/done/task_25.md) · Przygotowano: 2026-10-28 · Gałąź: `spec/2026-10-28-task22`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis. Każda część poniżej to jedno zadanie z tego buildu; arkusz jest zamknięty, gdy zamknięte są wszystkie części.
> Wyniki człowieka: Roland (dashboard), 2026-10-28 06:52
> Build: f1e6f37 (Everhorror-test-task25-f1e6f37-windows.zip)

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
| 1 | Wstęp do gry | nowa gra, przeczytać wstęp | „…Kniaź chce mieć na mapie dwanaście żył błękitu. Ósmego dnia rano przyjdzie po raport wóz.” bez zmian | ✅ |  |
| 2 | Racibor, pierwsza rozmowa | „Po co właściwie tu jesteśmy?” i „Znam mapy dziadka…” | „…zobaczyć dwanaście żył na mapie” oraz „Kniaź chce dwunastu żył do wieczora siódmego dnia” | ✅ |  |
| 3 | Wpis w notesie | po przyjęciu zadania otworzyć notes (J), zakładka zadań | wpis „Kniaź chce dwunastu żył błękitu na mapie do wieczora siódmego dnia…” | ✅ |  |
| 4 | Mirosław, dzień 3 | porozmawiać z Mirosławem 3. dnia (gwara włączona i wyłączona) | „Tydzień, mówi Racibor. Dwanaście żył. A potem fedrujemy na całego.” (wersja śląska: „Tydziyń, godo Racibor…”) | ✅ |  |
| 5 | `release.sh --dry-run` | w terminalu: `tools/release/release.sh 0.5.5 --dry-run` (wymaga bitu wykonywania: `git update-index --chmod=+x`) | wypisuje sześć kroków i polecenia git, niczego nie uruchamia | ✅ |  |
| 6 | `docs/agent/flags.md` | otworzyć plik | tabela flag z kolumnami „ustawiana w / czytana w / ładunek”, część dla rodzin `vein_*`, `visited_*` | ✅ |  |

### Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| unit | `tools/run_tests.sh unit` | ALL PASSED (w tym nowe przypadki `quota_words` i wpisów „zloza”) | `reports/tests/unit.log` |
| lint | `tools/run_tests.sh lint` | ALL PASSED (nowe reguły T7 i K6, zapis `flags.tsv`) | `reports/tests/lint.log` |
| dialogue | `tools/run_tests.sh dialogue` | ALL PASSED (w tym linia Mirosława z gwarą i bez) | `reports/tests/dialogue.log` |

## Część: task_25 — Eksport gubi listy (licznik żył 0, warunki dróg)

### Co zostało dodane
- Gra z ZIP-a znów zna żyły i warunki wejścia do miejsc: eksport nie zamienia już zasobów tekstowych na binarne i nie gubi list tekstów (ZYL-2, ZYL-4, ZYL-5, WYP-3, WYP-4, WYP-7, ZAP-11). Wszystkie wiersze poniżej sprawdzaj na ZIP-ie buildu do ogrania, nie w edytorze.
- Wróciły też schowane części modeli postaci (kaptur Racibora, Sobka i Welfa, części modelu Hrapka).

### Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Komunikat po pierwszej żyle | zaznaczyć pierwszą żyłę błękitu | komunikat „1 z 12”, nie „0 z 12” | | |
| 2 | Licznik żył | po pierwszej żyle sprawdzić mapę, ekwipunek (I) i notes (J) | wszędzie „1 z 12” | | |
| 3 | Mapa i lista miejsc | otworzyć mapę (M) po zaznaczeniu żyły | na rysunku przybywa niebieska kreska, lista miejsc pokazuje „żyły 1/2” | | |
| 4 | Upadowa i Ślepy szyb | iść tam bez liny | miejsca zamknięte | | |
| 5 | Zawalony chodnik, Kaplica | iść do chodnika przed wybuchem, do Kaplicy przed jej odkryciem | zamknięte | | |
| 6 | Zalany chodnik, Galeria | iść do chodnika przy stojących pompach, do Galerii bez oleju | zamknięte | | |
| 7 | Kaptury i Hrapek | obejrzeć Racibora, Sobka, Welfa i Hrapka | brak kaptura u trzech pierwszych, poprawny model Hrapka | | |
| 8 | Obrys żyły | podejść do żyły | obrys żyły świeci przy zbliżeniu | | |
| 9 | Raport przebiegu | po tygodniu otworzyć raport przebiegu | przy żyłach `n` różne od 0 | | |

### Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| export | `tools/run_tests.sh export` | ALL PASSED (day1 expedition z wyeksportowanej paczki, 53 s; przed poprawką czerwony, wg tools/README.md) | `reports/tests/export.log` |
| unit | `tools/run_tests.sh unit` | ALL PASSED | `reports/tests/unit.log` |
| lint | `tools/run_tests.sh lint` | ALL PASSED | `reports/tests/lint.log` |
