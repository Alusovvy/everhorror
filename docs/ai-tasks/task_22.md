# task_22: Narzędzia procesu: uprawnienia, skrypt wydania, rejestr flag, lint liczby żył i polskich tekstów

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
„Wprowadz propozycje Fable, nastepnie odswiez dokumentacje.” (Roland, czat 2026-10-27)
Propozycje: P1 (reszta), P4, K4, T7 (lint), K6 (lint i konwencja) z analizy projektu (kontekst poniżej).

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

Kontekst:
Źródło: przegląd projektu `docs/analizy/propozycje-projekt.md` (agent Fable 5.1, tylko odczyt, 2026-10-27). Ten plik zostaje usunięty po przeniesieniu propozycji do planu i zadań, więc cała treść potrzebna wykonawcy jest tutaj. Numery linii pochodzą z 2026-10-27 i mogą się przesunąć. Wszystko to narzędzia i lint: **rozgrywka nie zmienia się**, więc zadanie nie wymaga reguły ⬜ w specyfikacji. Szczególnie ważne przy T7: teksty wyświetlane graczowi muszą po zmianie wyglądać dokładnie tak samo jak przed nią. Koszt razem: S–M (pięć niezależnych części; można je robić po kolei w jednym przebiegu).

0. **Już zrobione przez koordynatora (nie powtarzać).** Minimalna część P1 jest wpisana w `.claude/settings.json`: `deny` dla `git checkout`, `git stash` i `git rebase` (także w formie `git -C * …`). Ta część zadania dotyczy reszty.
   Konwencja K6 w `CLAUDE.md` (sekcja Conventions: nowy tekst dla gracza w skrypcie idzie przez `tr()` albo tabelę `Texts`) została dopisana przy odświeżeniu dokumentacji, więc tu zostaje tylko lint.

1. **P1 (reszta). Uprawnienia agenta pozwalają jeszcze na merge, tag i push do master w głównej kopii.**
   - *Problem.* `.claude/settings.json` dopuszcza `Bash(git:*)` i `Bash(node:*)`, a lista `deny` zakazuje force push, `reset --hard`, `clean`, `branch -D`, `worktree remove --force` oraz (po kroku 0) checkout, stash i rebase. `git merge`, `git switch`, `git tag` i `git push` do `master` nadal przechodzą; chroni je tylko tekst w `CLAUDE.md` (Hard rules: „Only Roland merges”, „never switch branches”). Plan wymienia zawężenie jako zaległość etapu 4 (`final-plan-human-readable.md:179`). Przebiegi z dashboardu mają własnego strażnika (`runguard.ts`), sesje terminalowe go nie mają.
   - *Propozycja.* Zamienić szerokie `allow` na listę pozytywną: `git status/log/diff/show/branch --list/ls-files/rev-parse/remote -v/fetch`, `git -C <worktree> add/commit/switch -c/push origin spec/*`, `git -C <spec> add/commit/push`; w `deny` dodać: `git merge*`, `git switch*` (bez `-c`, więc wprost tylko tworzenie gałęzi jest dozwolone), `git tag*`, `git push * master`, `git worktree remove*` (także w formach `git -C * …`). `node` zawęzić do `node tools/*` i `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts *`.
   - *Ryzyko do sprawdzenia.* Przebiegi z dashboardu ładują uprawnienia projektu (`--setting-sources project`), więc zawężenie nie może zablokować poleceń, których potrzebują skille `spec-tasks`, `ai-task` i `spec-sync` (zawsze `git -C <pełna ścieżka>`, `node …/cli.ts lint`, `tools/run_tests.sh`). Wykonawca przechodzi po tych skillach i zestawia listę używanych poleceń z nową listą `allow`; brak pokrycia to błąd zadania.
   - *Test.* Trzy polecenia z `deny` (np. `git merge x`, `git tag x`, `git push origin master`) są odrzucone, a polecenia z listy skillów przechodzą. Wynik w raporcie.
   - *Koszt:* S. *Priorytet analizy:* wysoki (tanie bezpieczeństwo). *Etap:* 4. Zmiana zabezpieczeń: Roland widzi diff przed zatwierdzeniem.

2. **P4. Jeden skrypt wydania zamiast sześciu kroków.**
   - *Problem.* Wydanie to sześć ręcznych kroków (`tools/README.md`, sekcja Wydanie): sprawdzenie wersji, `stamp_build.js`, `--import`, `--export-release`, `make_zip.sh`, commit i tag. Każdy krok ma własne pułapki (stempel przed eksportem, ten sam commit specyfikacji w `CHANGELOG`, `WDROZENIA` i tagu). Plan odkłada CI (§8.3), ale lokalny skrypt to nie CI.
   - *Propozycja.* `tools/release/release.sh <wersja> [--spec <rev>]`: `stamp_build.js --check` → `stamp_build.js` → `--import` → eksport → `make_zip.sh` → wypisuje gotowe polecenia `git commit`, `git tag` i `git push`, **ale ich nie wykonuje** (tag i push zostają w stałych zgodach po scaleniu Rolanda). Dla możliwości sprawdzenia bez eksportu skrypt ma też `--dry-run`, który tylko wypisuje kroki. Test: `unit` już pilnuje zgodności wersji w trzech miejscach.
   - *Koszt:* S–M. *Priorytet analizy:* średni. *Etap:* 4, przydaje się od 0.5.4.

3. **K4. Rejestr flag generowany z lintu zamiast ręcznej tabeli.**
   - *Problem.* W kodzie i dialogach jest 168 różnych `set_flag("…")` i 26 `mark_today("…")` (zliczone wyszukiwaniem 2026-10-27), do tego flagi z generatorów. `08_technika.md:37–54` w specyfikacji dokumentuje 15. Plan szacuje około 85 % flag bez dokumentacji (`final-plan-human-readable.md:405`). `tools/data_lint.gd` (około linii 235–250) już zbiera każdą flagę czytaną i ustawianą, ale wynik wyrzuca.
   - *Propozycja.* Lint zapisuje `reports/flags.tsv` (flaga, gdzie ustawiana, gdzie czytana, czy ma ładunek), a mały skrypt `tools/generators/write_flags_doc.js` generuje z niego `docs/agent/flags.md` (plik generowany, w repozytorium). Tabela tekstowa, bez bazy i grafu (plan §5). `tools/README.md` opisuje generator.
   - *Poza tym zadaniem:* skrócenie `08_technika.md` do 15 najważniejszych flag z odnośnikiem do `docs/agent/flags.md` to zmiana w specyfikacji; wykonawca zgłasza ją w raporcie.
   - *Koszt:* S. *Priorytet analizy:* średni. *Etap:* dowolny.

4. **T7 (lint). „Dwanaście żył” wpisane na sztywno w tekstach.**
   - *Problem.* Większość kwestii używa `{{quota()}}`, ale liczba stoi też słownie: wstęp „dwanaście żył błękitu” (`dialogue/system.dialogue:105`), Racibor „dwanaście żył na mapie” i „dwunastu żył do wieczora siódmego dnia” (`dialogue/racibor.dialogue:43,50,144,186`), komunikat „Dwanaście żył. Norma Kniazia zrobiona.” (`script/game_state.gd:581`), `tools/release/CZYTAJ_MNIE.txt`. Etap 6 zmienia normę na etapy 4/8/14 (D-05), więc te zdania staną się błędne, a istniejący lint pilnuje tylko ID i etykiet czasu.
   - *Propozycja.* Reguła lintu: w `dialogue/`, `script/` i `tools/release/CZYTAJ_MNIE.txt` nie ma literałów „dwanaście”, „dwunastu” ani „12 żył”, poza miejscami oznaczonymi komentarzem (np. gdzie liczba jest fabularnie stała). Pomocnik `quota_words()` w `GameState` dla form słownych (w stylu `veins_acc()`). Wykonać przed etapem 6, żeby zmiana normy była jedną liczbą.
   - *Uwaga o gwarze.* Kwestie Mirosława i Bolka mają wersję śląską kluczowaną dokładną linią oryginału (`tools/generators/write_gwara.js`, `dialogue/gwara_slaska.json`); zmiana ich tekstu wymaga aktualizacji klucza i ponownego uruchomienia generatora, a `tools/dialogue_test.gd` wykrywa brak wersji.
   - *Koszt:* S. *Priorytet analizy:* średni. *Etap:* 6 (przygotowanie).

5. **K6 (lint). Teksty gry nie są gotowe na wersję angielską.**
   - *Problem.* D-09 zakłada angielski „przez ten sam mechanizm tłumaczeń co gwara” (`final-plan-human-readable.md:278`). Mechanizm gwary to JSON „dokładna kwestia → wersja” tylko dla linii dialogów. Tymczasem około 300 polskich literałów siedzi w `script/*.gd` (`game_state.gd:371,432,479,581`, `expedition_summary.gd`, `run_report.gd`, `map_screen.gd`, `hud.gd`; liczba zliczona wyszukiwaniem), często składanych przez `%` z odmianą (`veins_acc()`, `days_left_text()`), której JSON nie przetłumaczy. Menu jest już po angielsku (UI-5), więc demo mieszałoby języki na jednym ekranie. Dziś w `script/` nie ma ani wywołań `tr()`, ani tabeli `Texts`.
   - *Propozycja na teraz.* Lint liczący polskie literały w `script/` (np. łańcuchy z polskimi znakami diakrytycznymi lub z listy słów; sposób liczenia opisać w `tools/README.md`). Liczba **może tylko spadać**: aktualny stan zapisany w pliku bazowym w repozytorium (np. `tools/lint_baseline.json`); lint kończy się błędem, gdy liczba wzrośnie, a przy spadku przypomina o obniżeniu wartości bazowej. Nie przenosimy istniejących tekstów masowo (to przed etapem 9: `translations/pl.csv` + `en.csv` dla skryptów, dialogi przez rozszerzony mechanizm gwary, odmiany przez funkcje per język; koszt M–L). Wykonawca ocenia, czy dodać minimalną tabelę `Texts`, żeby konwencja z `CLAUDE.md` miała dokąd prowadzić; jeśli nie, konwencja opiera się na `tr()`.
   - *Koszt:* S na start. *Priorytet analizy:* średni, wysoki przed etapem 9. *Etap:* 9 (przygotowanie od teraz).

Kryteria akceptacji:
- **P1:** `.claude/settings.json` ma listę pozytywną `allow` i rozszerzone `deny`; trzy polecenia z `deny` są odrzucone (wynik próby w raporcie); wszystkie polecenia wymagane przez skille `spec-tasks`, `ai-task` i `spec-sync` są dozwolone (lista zestawiona w raporcie). Plik jest poprawnym JSON.
- **P4:** `tools/release/release.sh 0.5.3 --dry-run` wypisuje wszystkie kroki w kolejności i nic nie wykonuje; bez `--dry-run` zatrzymuje się przy pierwszym błędzie (np. niezgodna wersja) i kończy się wypisaniem poleceń `git commit`, `git tag`, `git push` bez ich uruchamiania. `tools/README.md` (sekcja Wydanie) opisuje skrypt; sześć ręcznych kroków zostaje jako opis tego, co skrypt robi.
- **K4:** `tools/run_tests.sh lint` zapisuje `reports/flags.tsv`; `node tools/generators/write_flags_doc.js` tworzy `docs/agent/flags.md` z co najmniej wszystkimi flagami, które lint dziś widzi; powtórne uruchomienie daje identyczny plik.
- **T7:** lint zgłasza literał „dwanaście/dwunastu/12 żył” w trzech wskazanych miejscach, a po zmianie nie zgłasza nic. **Wyświetlany graczowi tekst jest taki sam jak przed zmianą** (potwierdza `tools/run_tests.sh dialogue`, w tym wersja śląska). Miejsca oznaczone komentarzem są wymienione w raporcie.
- **K6:** lint liczy polskie literały w `script/` i zapisuje stan bazowy; sztuczne dodanie jednego polskiego łańcucha w skrypcie (próba robocza, cofnięta) kończy lint błędem.
- Krótkie testy przechodzą: `unit lint dialogue`. Pełny zestaw tylko za zgodą Rolanda.
- `tools/README.md` opisuje wszystkie nowe narzędzia i reguły lintu; `docs/agent/README.md` wspomina o `flags.md`.

Poza zakresem:
- Przeniesienie istniejących polskich tekstów do tłumaczeń, angielska wersja gry, przełącznik języka (etap 9).
- Zmiana normy żył (etap 6, D-05); ten lint tylko przygotowuje grunt.
- Wykonywanie tagu i pushu przez `release.sh` oraz jakiekolwiek wydanie. Przepisywanie `08_technika.md` w specyfikacji.
- Uprawnienia dashboardu i jego strażnik (`runguard.ts`); CI (plan §8.3); Git LFS (P5).
- Zmiany w treści dialogów inne niż zastąpienie sztywnej liczby tym samym tekstem.

Priorytet: średni · Etap planu: 4 (P1, P4, K4), 6 (T7), 9 (K6) · Kolejność: niezależne od task_16–21

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->

## Test
<!-- Jeśli zadanie zawiera implementację: link do docs/human-tasks/factcheck-test-XX.md -->

## Podsumowanie
