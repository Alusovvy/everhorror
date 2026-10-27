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

## Analiza
Analiza z 2026-10-27, przebieg z dashboardu `20261027-151905-analyze-22-050463`. Numery linii pochodzą z `master` gry z tego dnia.

**Kolejność i gdzie wdrażać.**
- Zadanie nie zależy od task_16–21.
- W „Na gałęziach” stoi jednak otwarta gałąź `spec/2026-10-27-task17` (🧪, arkusz już zamknięty). Obowiązuje zasada „najwyżej jedna otwarta gałąź `spec/*`”, więc wdrożenie task_22 zaczyna się dopiero po scaleniu task17 i `/spec-sync finalize`.
- Wdrożenie musi iść w terminalu (`/ai-task implement 22`), nie z dashboardu. Przebiegi z dashboardu mają zakaz zapisu w `.claude/**`, także w kopii wdrożeniowej (`buildSettings`, `dashboard/src/work/runs.ts:1037–1038`). Tak samo mówi `docs/ai-tasks/INFO.md`: zadania narzędziowe wdrażamy w terminalu.

**P1 (uprawnienia).** Jak jest dziś:
- `.claude/settings.json` ma `allow` z `Bash(git:*)`, `Bash(node:*)`, `tools/run_tests.sh`, Godotem i pomocnikami (`cp -r`, `mkdir`, `ls`, `cat`, `grep`, `head`, `tail`, `wc`, `diff`, `date`).
- `deny` blokuje force push, `reset --hard`, `clean`, `branch -D`, `worktree remove --force`, `checkout`, `stash` i `rebase`.

Najważniejsze ryzyka:
- **Przebiegi z dashboardu zależą od listy `allow` projektu.** Startują z `--permission-mode dontAsk --setting-sources project`. Ich własny `settings.json` dokłada tylko zapis w ścieżkach rodzaju i drobne polecenia powłoki (`SHELL_HELPER_ALLOW`, `runs.ts:937`). Komentarz w kodzie mówi wprost, że git, node, `ls`, `cat` itd. pochodzą z listy projektu. W trybie `dontAsk` każde polecenie spoza `allow` jest odrzucane bez pytania, więc luka w nowej liście zatrzyma kolejne przebiegi Rolanda. Dlatego zestawienie poleceń skilli to sedno P1, nie formalność.
- **Polecenia skilli i pomocników.** Zebrane z `.claude/skills/*/SKILL.md` i `.claude/agents/*.md`; wykonawca uzupełnia listę, a w raporcie stawia ją obok reguł:
  - git, tylko odczyt: `status` (też `--porcelain`, `-sb`), `log`, `diff` (też `master...<gałąź>`, `--stat`), `show`, `ls-files --error-unmatch`, `rev-parse`, `rev-list -n 1 v<wersja>`, `merge-base --is-ancestor`, `branch --list`, `branch --merged master --list "spec/*"`, `branch --show-current`, `worktree list`, `remote -v`;
  - git w specyfikacji: `add --`, `commit -m … --`, `fetch`, `pull --ff-only`, `push`;
  - git w kopii wdrożeniowej: `add`, `commit`, `mv`, `rm`, `restore`, `switch -c`, `switch <gałąź>` (`ai-task fix`), `switch --detach` (`spec-sync`), `push` gałęzi `spec/*`;
  - git w głównej kopii: `worktree add … -b spec/…`, `branch -d spec/…`, `mv` pliku zadania (`spec-sync`), `push <remote> --delete spec/…` (po zgodzie);
  - pozostałe: `node dashboard/cli.ts …` (forma względna, z katalogu specyfikacji), `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts …`, `node tools/check_doc_links.js`, `node tools/generators/*.js`, `node tools/release/stamp_build.js`, `tools/run_tests.sh <nazwy>`, Godot `--import` z przekierowaniem do pliku, `cp -r <gra>/.godot <worktree>/`.
- **Sprzeczności w propozycji.**
  - Zakaz `git switch*` „bez `-c`” łamie `ai-task fix` i `spec-sync`, które przełączają kopię wdrożeniową. Zakaz trzeba więc ograniczyć do głównej kopii; to drobny szczegół, który przyjmuję sam (karta, sekcja „Przyjęte”).
  - Zakaz `git tag*` i `git push * master` łamie stałą zgodę z planu §9 („tag wersji i push `master` gry po scaleniu przez Rolanda”) i krok tagu w `spec-sync`. To wymaga decyzji Rolanda (karta, pytanie 1).
- **Pułapki wzorców.**
  - `git merge*` bez spacji łapie też `git merge-base`, którego używa `spec-tasks`; dashboard pisze to celowo ze spacją (`runs.ts:939`).
  - Ogólne `git -C * push * master` zablokowałoby dozwolony push `master` specyfikacji, więc zakaz musi wskazywać repozytorium gry.
  - Reguły Bash nie są granicą bezpieczeństwa (`../specification/dashboard/ARCHITEKTURA.md`, „Profil przebiegu”): względne ścieżki i inne zapisy da się nimi obejść. Zawężenie chroni przed pomyłką, nie przed złą wolą.
- **Kiedy nowe reguły zaczynają działać.** Plik zmienia się na gałęzi w kopii wdrożeniowej, a każda sesja czyta `.claude/settings.json` ze swojego katalogu roboczego, czyli z głównej kopii. Reguły działają więc dopiero po scaleniu. Próba przed scaleniem wymaga sesji uruchomionej w kopii wdrożeniowej (karta, pytanie 2).

**P4 (skrypt wydania).** Jak jest dziś:
- Wydanie to sześć kroków z `tools/README.md#wydanie`.
- `stamp_build.js` ma już `--check` i `--spec <rev>`.
- `make_zip.sh` sam sprawdza wersję, a gdy brak `zip`, używa PowerShella (w terminalu to działa, w przebiegu z dashboardu nie, ale wydanie nie jest przebiegiem z dashboardu).

Luki i ryzyka:
- Konsolowy Godot potrafi zakończyć `--export-release` kodem 0 mimo błędu. Skrypt powinien więc sprawdzić, czy `build/windows/Everhorror.exe` istnieje i jest nowszy niż start skryptu.
- Argument `<wersja>` musi się równać wersji z `project.godot`; to pierwszy krok i najtańszy test zatrzymania („`release.sh 9.9.9`” kończy się błędem przed eksportem).
- Tag i push zostają wypisane, nie wykonane, zgodnie z wymaganiami.

**K4 (rejestr flag).**
- `tools/data_lint.gd:226–250` zbiera flagi ustawiane (`written`, bez ścieżek) i czytane (`read_flags`, tylko ostatnia ścieżka), potem je wyrzuca.
- Źródła: dialogi, trzy generatory `.gd`, `story_director.gd` i `script/*.gd`, ale tylko z poziomu katalogu: `script/data/` jest pominięty.
- Flagi z rodzin `vein_*` i `visited_*` składa się w czasie gry.
- `write_world_data.js` ma pola flag (`required_flag` itp.), a lint go nie czyta.
- `reports/` jest w `.gitignore`, więc `flags.tsv` nie trafi do repozytorium. Do repozytorium trafia tylko wygenerowany `docs/agent/flags.md`.
- Żeby powtórne uruchomienie dało identyczny plik, wynik musi być posortowany, bez daty i bez numerów linii (numery zmieniałyby plik przy każdej edycji dialogu).

**T7 (sztywna „dwunastka”).** Wyszukiwanie z 2026-10-27 znalazło więcej miejsc, niż wymienia zadanie:
- tekst normy: `dialogue/system.dialogue:105`; `dialogue/racibor.dialogue:43,50,69,144,186` (69 to „Do dwunastu jeszcze daleko.”, a 186 kończy się „Kniaź chce dwunastu.”, więc słowo „żył” nie zawsze stoi obok); `dialogue/miroslaw.dialogue:192` z kluczem gwary (`write_gwara.js:180–181`, `gwara_slaska.json:84`, gdzie wersja śląska też ma „Dwanaście żył”); `script/game_state.gd:581`; `tools/release/CZYTAJ_MNIE.txt:26`;
- notes: trzy wpisy zadania „Złoża” w `tools/generators/write_story_data.js:196,200,201` (→ `data/quests/`). Są poza trzema miejscami z wymagań (karta, pytanie 4);
- fałszywe trafienia: Nasir, „Dwanaście lat” i „dwunastu latach” (`dialogue/nasir.dialogue:45,46,107`, `write_story_data.js:106`). Prosta reguła na same słowa „dwanaście/dwunastu” je złapie, więc potrzebują komentarza-wyjątku.

Co ważne dla wykonawcy:
- **Kolejność w Dialogue Manager.** Najpierw tłumaczy linię po surowym tekście razem z `{{…}}` (`addons/dialogue_manager/dialogue_manager.gd:430`, `translate()` → `tr(data.text, "dialogue")`), dopiero potem wstawia wartości, szukając tego samego `{{…}}` w przetłumaczonym tekście (`:496–513`). Klucz i wartość w `gwara_slaska.json` muszą więc zawierać identyczne `{{…}}`. Dziś żaden klucz gwary go nie ma, więc to pierwszy taki przypadek i `dialogue` musi go sprawdzić.
- **Pomocnik `quota_words()`.** Musi znać dwa przypadki: mianownik/biernik („dwanaście żył”) i dopełniacz („dwunastu żył”, „dwunastu”). Musi też odmieniać rzeczownik razem z liczebnikiem, bo przy normie 4 z etapu 6 (D-05) będzie „cztery żyły”, a nie „cztery żył”. Do tego wielka litera na początku zdania (Mirosław, komunikat z `game_state.gd:581`).
- **CZYTAJ_MNIE.txt** to czysty tekst bez komentarzy i bez `{{…}}` (karta, pytanie 3).

**K6 (polskie literały).**
- W `script/` nie ma ani `tr()`, ani tabeli `Texts`.
- Wyszukiwanie łańcuchów z polskimi znakami daje 259 trafień w 20 plikach. Najwięcej mają `run_report.gd` (74), `story_director.gd` (65) i `game_state.gd` (27). Liczba obejmuje też komentarze z cudzysłowami, więc lint musi pomijać komentarze.
- Sama reguła „ma polski znak” nie widzi tekstów bez ogonków („Nowe kreski na mapie: %s”). Wykonawca dobiera krótką listę słów i opisuje sposób liczenia w `tools/README.md`.
- Kolejność ma znaczenie: T7 dodaje polskie słowa liczebników do `game_state.gd`, więc stan bazowy K6 zapisujemy po T7.

## Plan
Rodzaj „narzędzia”, wdrożenie w terminalu: gałąź `spec/<data>-task22` od `master` we własnym worktree `C:/dev/gamedev/everhorror/everhorror-wt/<gałąź>` (zasada z `CLAUDE.md` od 2026-10-27; `everhorror-wdrozenie` tylko dla starszych gałęzi). Warunki startu: task17 scalony i domknięty; karta [2026-10-27_task22-uprawnienia-i-norma](../../../specification/zgloszenia/2026-10-27_task22-uprawnienia-i-norma.md) jest rozstrzygnięta (Roland, 2026-10-27, dashboard: 1: a, 2: a, 3: a, 4: a). W „Na gałęziach” wiersz z `—` zamiast sha7 i z `task_22` jako ID, bez wiersza „W zadaniach”. Kroki:

1. **K4.**
   - `data_lint.gd` zbiera każdą ścieżkę, w której flagę ustawia się i czyta. Dochodzą źródła `script/data/*.gd` i `tools/generators/write_world_data.js`.
   - Lint zapisuje `reports/flags.tsv` z kolumnami: flaga, ustawiana w, czytana w, ładunek (tak, gdy drugi argument `set_flag` nie jest `true`, oraz `mark_today`), rodzina. Wynik jest posortowany, bez numerów linii.
   - Nowy `tools/generators/write_flags_doc.js` robi z niego `docs/agent/flags.md`: nagłówek „plik generowany”, rodziny `vein_*` i `visited_*` w osobnej części.
   - Sprawdzenie: dwa uruchomienia → `diff` bez różnic.
2. **T7.**
   - `GameState.quota_words(przypadek, wielka_litera)` zwraca liczebnik żeński z rzeczownikiem w dobrej formie. Tabela słów ma komentarz `lint-quota`; dla liczb spoza tabeli są cyfry z `plural()`.
   - Linie z sekcji T7 dostają `{{quota_words(…)}}`, a `game_state.gd:581` pomocnika. Klucz i wartość gwary Mirosława zmieniamy w `write_gwara.js` i uruchamiamy generator.
   - Kwestie Nasira dostają komentarz `lint-quota`.
   - **Notes (karta, 4a).** Trzy wpisy zadania „Złoża” w `write_story_data.js:196,200,201` dostają znaczniki normy (np. `{norma}` w mianowniku, `{norma_dop}` w dopełniaczu, `{Norma}` z wielkiej litery). Jeden pomocnik w `GameState` (np. `quest_entry_text(data, entry_id)`) zamienia je przez `quota_words()`. Używają go oba miejsca, które dziś pokazują wpis dosłownie: notes (`script/notebook.gd:59`) i sygnał `quest_updated` (`script/game_state.gd:821`). Potem `node tools/generators/write_story_data.js`, a `data/quests/` tylko z generatora. Tekst w notesie wygląda tak samo jak dziś; sprawdza to nowy przypadek w `unit` (wpisy `start`, `zdane`, `norma` po zamianie = dzisiejszy tekst).
   - **CZYTAJ_MNIE.txt (karta, 3a).** Tekst zostaje bez zmian. Dla tego pliku reguła lintu nie zabrania liczby słownie, tylko sprawdza, że „… żył błękitu” zgadza się z `quota_words()` dla `QUOTA`. Przy zmianie normy lint wskaże to zdanie.
   - Nowa reguła w `data_lint.gd`: w `dialogue/`, `script/` i `tools/generators/write_story_data.js` „dwanaście/dwunastu/12 żył” poza oznaczonymi miejscami to błąd; `CZYTAJ_MNIE.txt` jak wyżej.
   - Sprawdzenie: przed zmianą lint zgłasza wszystkie miejsca. Po zmianie `--import` (zmienione `.dialogue`), a potem `dialogue`; wykonawca porównuje wyświetlany tekst przed i po w obu wersjach, z gwarą i bez.
3. **K6.**
   - Reguła w `data_lint.gd` liczy polskie literały w `script/**/*.gd` dla każdego pliku. Pomija komentarze i łańcuchy w `tr("…")`. Liczy łańcuchy z polskimi znakami oraz łańcuchy z listy częstych słów bez ogonków.
   - Stan bazowy trafia do `tools/lint_baseline.json` (każdy plik osobno, żeby spadek w jednym pliku nie ukrył wzrostu w innym). Wzrost to błąd; spadek wypisuje przypomnienie o obniżeniu wartości bazowej.
   - Tabeli `Texts` nie dodajemy: konwencja z `CLAUDE.md` opiera się na `tr()`, a mechanizm per język i tak powstanie w etapie 9.
   - Próba robocza: dopisany i potem usunięty polski łańcuch → lint kończy się błędem.
4. **P4.**
   - `tools/release/release.sh <wersja> [--spec <rev>] [--dry-run]` wykonuje po kolei: zgodność argumentu z `project.godot` → `stamp_build.js --check` → `stamp_build.js [--spec]` → `--import` → `--export-release` (do pliku logu; potem sprawdzenie, czy `.exe` powstał i jest nowy) → `make_zip.sh`. Na końcu wypisuje `git commit`, `git tag v<wersja>`, `git push` oraz przypomnienie o tym samym commicie specyfikacji w `CHANGELOG.md` i `WDROZENIA.md`.
   - `set -e`; `--dry-run` tylko wypisuje kroki.
   - Sprawdzenie: `release.sh 0.5.3 --dry-run` oraz `release.sh 9.9.9`, który musi zatrzymać się na pierwszym kroku.
5. **P1.**
   - W `.claude/settings.json` lista `allow` z sekcji Analiza. W `deny`: `git merge *`, `git switch` w głównej kopii, `git worktree remove*`, wszystko w formach `git …` i `git -C * …`.
   - **Tag i push `master` gry (karta, 1a):** lista `ask` (`git tag *`, `git -C * tag *`, push `master` w repozytorium gry, w obu formach). W terminalu zawsze pytają Rolanda, w dashboardzie (`dontAsk`) są odrzucane. Stała zgoda z planu §9 i krok tagu w `spec-sync` zostają bez zmian.
   - `node` zawężony jak w karcie, ze ścieżką worktree `C:/dev/gamedev/everhorror/everhorror-wt/*/tools/*` zamiast `everhorror-wdrozenie` (a dla starszych gałęzi też ta druga). Dochodzi `tools/release/release.sh` do `allow`.
   - Sprawdzenie: plik jest poprawnym JSON (parsuje go `data_lint.gd` przez `JSON.parse_string` albo mały skrypt w `tools/`; `node -e` jest zakazane). Zestawienie „polecenie skilla → reguła” w raporcie.
   - **Próba (karta, 2a):** jeden krótki `claude -p` uruchomiony w worktree zadania, z `--setting-sources project --permission-mode dontAsk` i limitem `--max-budget-usd 0.5`. Próbuje nieszkodliwych wariantów zakazanych poleceń (merge nieistniejącej gałęzi, `switch` w głównej kopii na nieistniejącą gałąź, `git tag` z `ask` → odrzucony w `dontAsk`, `push --dry-run … master` w grze) oraz kilku poleceń skilli tylko do odczytu (`git -C … status`, `node dashboard/cli.ts lint` z katalogu specyfikacji, `tools/run_tests.sh lint`). Wynik każdego polecenia (odrzucone / przeszło) trafia do raportu.
   - Roland widzi diff przed zatwierdzeniem.
6. **Dokumentacja.**
   - `tools/README.md`: wiersz `release.sh` i sekcja Wydanie (sześć kroków zostaje jako opis tego, co robi skrypt), reguły lintu T7 i K6 z opisem liczenia, `write_flags_doc.js` w Generatorach.
   - `docs/agent/README.md`: odnośnik do `flags.md`.
   - W raporcie propozycja skrócenia `08_technika.md:37–54` do 15 flag z odnośnikiem; to zmiana w specyfikacji, poza zadaniem.
   - Plan §4 (wiersz task_22) bez zmian do scalenia.
7. **Testy i przegląd.** `test-runner`: `unit lint dialogue` (zmienione `.dialogue` i może nowy `class_name`, więc najpierw `--import`). Potem `convention-reviewer` na diff. Arkusz `docs/human-tasks/factcheck-test-22.md` w głównej kopii: wiersze na diff uprawnień, `release.sh --dry-run`, `flags.md` i jeden rzut oka na wstęp oraz Racibora w grze (tekst bez zmian).

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->
- Decyzje Rolanda: karta [2026-10-27_task22-uprawnienia-i-norma](../../../specification/zgloszenia/2026-10-27_task22-uprawnienia-i-norma.md), Roland, 2026-10-27 (dashboard): 1: a, 2: a, 3: a, 4: a.
- Przyjęte przez agenta bez pytania (do weta w przeglądzie; wymienione w karcie, sekcja „Przyjęte”):
  - zakaz `git switch` tylko w głównej kopii;
  - reguły zakazu ze spacją (`git merge *`), żeby nie łapały `merge-base`;
  - push `master` objęty regułą tylko w repozytorium gry;
  - `node` zawężony do narzędzi gry i `cli.ts`;
  - komentarz `lint-quota` przy Nasirze i tabeli liczebników;
  - bez tabeli `Texts`.
- Worktree: od 2026-10-27 każda gałąź zadania ma własny katalog w `everhorror-wt/` (`CLAUDE.md`), więc plan i reguły `node` biorą tę ścieżkę.

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->
Karta [2026-10-27_task22-uprawnienia-i-norma.md](../../../specification/zgloszenia/2026-10-27_task22-uprawnienia-i-norma.md) jest rozstrzygnięta (Roland, 2026-10-27, dashboard: 1: a, 2: a, 3: a, 4: a); plan wyżej ją uwzględnia. Zostały dwie rzeczy:
1. Scalić i domknąć task17 (`spec/2026-10-27-task17` stoi jeszcze w „Na gałęziach” jako 🧪), bo naraz może być otwarta tylko jedna gałąź `spec/*`.
2. Uruchomić wdrożenie w terminalu (`/ai-task implement 22`), bo przebiegi z dashboardu nie mogą zapisywać w `.claude/`. Ta sesja zrobi też płatną próbę uprawnień z pytania 2 (limit 0,5 USD).

## Test
<!-- Jeśli zadanie zawiera implementację: link do docs/human-tasks/factcheck-test-XX.md -->

## Podsumowanie
Analiza gotowa (2026-10-27), plan w siedmiu krokach powyżej. Karta decyzji jest rozstrzygnięta zgodnie z rekomendacjami: tag i push `master` gry trafiają na listę `ask`, uprawnienia sprawdza krótki przebieg w worktree zadania, `CZYTAJ_MNIE.txt` zostaje bez zmian (lint sprawdza zgodność z normą), a T7 obejmuje też wpisy notesu. Wdrożenie czeka tylko na domknięcie gałęzi task17 i idzie w terminalu, bo przebiegi z dashboardu nie mogą zapisywać w `.claude/`.
