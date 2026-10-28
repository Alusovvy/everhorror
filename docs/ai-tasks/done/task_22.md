# task_22: Narzędzia procesu: uprawnienia, skrypt wydania, rejestr flag, lint liczby żył i polskich tekstów

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
„Wprowadz propozycje Fable, nastepnie odswiez dokumentacje.” (Roland, czat 2026-10-27)
Propozycje: P1 (reszta), P4, K4, T7 (lint), K6 (lint i konwencja) z analizy projektu (kontekst poniżej).

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)
Poziom: rozgrywka

Kontekst:
Źródło: przegląd projektu `docs/analizy/propozycje-projekt.md` (agent Fable 5.1, tylko odczyt, 2026-10-27). Ten plik zostaje usunięty po przeniesieniu propozycji do planu i zadań, więc cała treść potrzebna wykonawcy jest tutaj. Numery linii pochodzą z 2026-10-27 i mogą się przesunąć. Wszystko to narzędzia i lint: **rozgrywka nie zmienia się**, więc zadanie nie wymaga reguły ⬜ w specyfikacji. Szczególnie ważne przy T7: teksty wyświetlane graczowi muszą po zmianie wyglądać dokładnie tak samo jak przed nią. Koszt razem: S–M (pięć niezależnych części; można je robić po kolei w jednym przebiegu).

0. **Już zrobione przez koordynatora (nie powtarzać).** Minimalna część P1 jest wpisana w `.claude/settings.json`: `deny` dla `git checkout`, `git stash` i `git rebase` (także w formie `git -C * …`). Ta część zadania dotyczy reszty.
   Konwencja K6 w `CLAUDE.md` (sekcja Conventions: nowy tekst dla gracza w skrypcie idzie przez `tr()` albo tabelę `Texts`) została dopisana przy odświeżeniu dokumentacji, więc tu zostaje tylko lint.

1. **P1 (reszta). Uprawnienia agenta pozwalają jeszcze na merge, tag i push do master w głównej kopii.**
   - *Problem.* `.claude/settings.json` dopuszcza `Bash(git:*)` i `Bash(node:*)`, a lista `deny` zakazuje force push, `reset --hard`, `clean`, `branch -D`, `worktree remove --force` oraz (po kroku 0) checkout, stash i rebase. `git merge`, `git switch`, `git tag` i `git push` do `master` nadal przechodzą; chroni je tylko tekst w `CLAUDE.md` (Hard rules: „Only Roland merges”, „never switch branches”). Plan wymienia zawężenie jako zaległość etapu 4 (`docs/analizy/plan.md`, etap 4 w §1 i D-15; szczegóły w archiwum, §8.3). Przebiegi z dashboardu mają własnego strażnika (`runguard.ts`), sesje terminalowe go nie mają.
   - *Propozycja.* Zamienić szerokie `allow` na listę pozytywną: `git status/log/diff/show/branch --list/ls-files/rev-parse/remote -v/fetch`, `git -C <worktree> add/commit/switch -c/push origin spec/*`, `git -C <spec> add/commit/push`; w `deny` dodać: `git merge*`, `git switch*` (bez `-c`, więc wprost tylko tworzenie gałęzi jest dozwolone), `git tag*`, `git push * master`, `git worktree remove*` (także w formach `git -C * …`). `node` zawęzić do `node tools/*` i `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts *`.
   - *Ryzyko do sprawdzenia.* Przebiegi z dashboardu ładują uprawnienia projektu (`--setting-sources project`), więc zawężenie nie może zablokować poleceń, których potrzebują skille `spec-tasks`, `ai-task` i `spec-sync` (zawsze `git -C <pełna ścieżka>`, `node …/cli.ts lint`, `tools/run_tests.sh`). Wykonawca przechodzi po tych skillach i zestawia listę używanych poleceń z nową listą `allow`; brak pokrycia to błąd zadania.
   - *Test.* Trzy polecenia z `deny` (np. `git merge x`, `git tag x`, `git push origin master`) są odrzucone, a polecenia z listy skillów przechodzą. Wynik w raporcie.
   - *Koszt:* S. *Priorytet analizy:* wysoki (tanie bezpieczeństwo). *Etap:* 4. Zmiana zabezpieczeń: Roland widzi diff przed zatwierdzeniem.

2. **P4. Jeden skrypt wydania zamiast sześciu kroków.**
   - *Problem.* Wydanie to sześć ręcznych kroków (`tools/README.md`, sekcja Wydanie): sprawdzenie wersji, `stamp_build.js`, `--import`, `--export-release`, `make_zip.sh`, commit i tag. Każdy krok ma własne pułapki (stempel przed eksportem, ten sam commit specyfikacji w `CHANGELOG`, `WDROZENIA` i tagu). Plan odkłada CI (§8.3), ale lokalny skrypt to nie CI.
   - *Propozycja.* `tools/release/release.sh <wersja> [--spec <rev>]`: `stamp_build.js --check` → `stamp_build.js` → `--import` → eksport → `make_zip.sh` → wypisuje gotowe polecenia `git commit`, `git tag` i `git push`, **ale ich nie wykonuje** (tag i push zostają w stałych zgodach po scaleniu Rolanda). Dla możliwości sprawdzenia bez eksportu skrypt ma też `--dry-run`, który tylko wypisuje kroki. Test: `unit` już pilnuje zgodności wersji w trzech miejscach.
   - *Koszt:* S–M. *Priorytet analizy:* średni. *Etap:* 4, przydaje się od 0.5.4.

3. **K4. Rejestr flag generowany z lintu zamiast ręcznej tabeli.**
   - *Problem.* W kodzie i dialogach jest 168 różnych `set_flag("…")` i 26 `mark_today("…")` (zliczone wyszukiwaniem 2026-10-27), do tego flagi z generatorów. `08_technika.md:37–54` w specyfikacji dokumentuje 15. Plan szacuje około 85 % flag bez dokumentacji (archiwum `docs/archiwum/plan-historia-2026-10.md`, §8.2; `docs/analizy/plan.md` odsyła tam po szczegóły). `tools/data_lint.gd` (około linii 235–250) już zbiera każdą flagę czytaną i ustawianą, ale wynik wyrzuca.
   - *Propozycja.* Lint zapisuje `reports/flags.tsv` (flaga, gdzie ustawiana, gdzie czytana, czy ma ładunek), a mały skrypt `tools/generators/write_flags_doc.js` generuje z niego `docs/agent/flags.md` (plik generowany, w repozytorium). Tabela tekstowa, bez bazy i grafu (plan §5). `tools/README.md` opisuje generator.
   - *Poza tym zadaniem:* skrócenie `08_technika.md` do 15 najważniejszych flag z odnośnikiem do `docs/agent/flags.md` to zmiana w specyfikacji; wykonawca zgłasza ją w raporcie.
   - *Koszt:* S. *Priorytet analizy:* średni. *Etap:* dowolny.

4. **T7 (lint). „Dwanaście żył” wpisane na sztywno w tekstach.**
   - *Problem.* Większość kwestii używa `{{quota()}}`, ale liczba stoi też słownie: wstęp „dwanaście żył błękitu” (`dialogue/system.dialogue:105`), Racibor „dwanaście żył na mapie” i „dwunastu żył do wieczora siódmego dnia” (`dialogue/racibor.dialogue:43,50,144,186`), komunikat „Dwanaście żył. Norma Kniazia zrobiona.” (`script/game_state.gd:581`), `tools/release/CZYTAJ_MNIE.txt`. Etap 6 zmienia normę na etapy 4/8/14 (D-05), więc te zdania staną się błędne, a istniejący lint pilnuje tylko ID i etykiet czasu.
   - *Propozycja.* Reguła lintu: w `dialogue/`, `script/` i `tools/release/CZYTAJ_MNIE.txt` nie ma literałów „dwanaście”, „dwunastu” ani „12 żył”, poza miejscami oznaczonymi komentarzem (np. gdzie liczba jest fabularnie stała). Pomocnik `quota_words()` w `GameState` dla form słownych (w stylu `veins_acc()`). Wykonać przed etapem 6, żeby zmiana normy była jedną liczbą.
   - *Uwaga o gwarze.* Kwestie Mirosława i Bolka mają wersję śląską kluczowaną dokładną linią oryginału (`tools/generators/write_gwara.js`, `dialogue/gwara_slaska.json`); zmiana ich tekstu wymaga aktualizacji klucza i ponownego uruchomienia generatora, a `tools/dialogue_test.gd` wykrywa brak wersji.
   - *Koszt:* S. *Priorytet analizy:* średni. *Etap:* 6 (przygotowanie).

5. **K6 (lint). Teksty gry nie są gotowe na wersję angielską.**
   - *Problem.* D-09 zakłada angielski „przez ten sam mechanizm tłumaczeń co gwara” (`docs/analizy/plan.md`, D-09 i etap 9 w §1). Mechanizm gwary to JSON „dokładna kwestia → wersja” tylko dla linii dialogów. Tymczasem około 300 polskich literałów siedzi w `script/*.gd` (`game_state.gd:371,432,479,581`, `expedition_summary.gd`, `run_report.gd`, `map_screen.gd`, `hud.gd`; liczba zliczona wyszukiwaniem), często składanych przez `%` z odmianą (`veins_acc()`, `days_left_text()`), której JSON nie przetłumaczy. Menu jest już po angielsku (UI-5), więc demo mieszałoby języki na jednym ekranie. Dziś w `script/` nie ma ani wywołań `tr()`, ani tabeli `Texts`.
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
- Wdrożenie musi iść w terminalu (`/ai-task implement 22`), nie z dashboardu. Przebiegi z dashboardu mają zakaz zapisu w `.claude/**`, także w kopii wdrożeniowej (`buildSettings`, `dashboard/src/work/runs.ts:1037–1038`).

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
- `make_zip.sh` sam sprawdza wersję, a gdy brak `zip`, używa PowerShella (w terminalu to działa, w przebiegu z dashboardu nie; wydanie robi karta „Wydanie” na serwerze, D-36).

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
Rodzaj „narzędzia”, poziom `rozgrywka` (zob. „Decyzje i założenia”), wdrożenie w terminalu, bo przebieg z dashboardu nie może zapisywać w `.claude/` (`docs/agent/run-rules.md` §1; dotyczy P1, a zadanie ma jednego wykonawcę od początku do końca): gałąź `spec/<data>-task22` od `master` we własnej kopii gałęzi `C:/dev/gamedev/everhorror/everhorror-wt/<gałąź>`. Warunek startu: karta [2026-10-27_task22-uprawnienia-i-norma](../../../../specification/zgloszenia/zamkniete/2026-10-27_task22-uprawnienia-i-norma.md) jest rozstrzygnięta (Roland, 2026-10-27, dashboard: 1: a, 2: a, 3: a, 4: a). W „Na gałęziach” wiersz z `—` zamiast sha7 i z `task_22` jako ID, bez wiersza „W zadaniach”. Kroki:

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
   - Plan (`docs/analizy/plan.md`, „Gdzie jesteśmy”, wiersz otwartych zadań) bez zmian do scalenia.
7. **Testy:** serwer po wdrożeniu uruchamia `unit lint dialogue`; w trakcie pracy agent robi najpierw `--import` (zmienione `.dialogue`, może nowy `class_name`) i uruchamia tylko potrzebne scenariusze. Przegląd diffu robi osobny przebieg łańcucha. Arkusz (poziom `rozgrywka`, D-36 pkt 4): jedna część `## Część: task_22` arkusza builda: wiersze na diff uprawnień, `release.sh --dry-run`, `flags.md` i jeden rzut oka na wstęp oraz Racibora w grze (tekst bez zmian).

Pliki: .claude/settings.json, tools/data_lint.gd, tools/lint_baseline.json, tools/unit_test.gd, tools/generators/write_flags_doc.js, tools/generators/write_story_data.js, tools/generators/write_gwara.js, tools/release/release.sh, tools/README.md, data/quests, dialogue/system.dialogue, dialogue/racibor.dialogue, dialogue/miroslaw.dialogue, dialogue/nasir.dialogue, dialogue/gwara_slaska.json, script/game_state.gd, script/notebook.gd, docs/agent/flags.md, docs/agent/README.md
Ryzyko: wysokie

### Aktualizacja analizy (2026-10-27, przebieg `20261027-203608-analyze-22-edb32b`)
Ponowne sprawdzenie planu wobec stanu po południu. Plan wyżej zostaje; zmienia się tylko to, co poniżej.
- **Warunek startu z task17 odpada.** `spec/2026-10-27-task17` jest scalona (`ebd024c`, wiersz w „Wpisy” na `3f76c0f`), „Na gałęziach” jest pusta, a D-33 pozwala na trzy otwarte gałęzie `spec/*` naraz. Gałąź task_22 dostaje własną kopię w `C:/dev/gamedev/everhorror/everhorror-wt/`.
- **Wdrożenie nadal tylko w terminalu.** Dashboard dalej odbiera przebiegom zapis w `.claude/**` głównej kopii i kopii gałęzi (`specification/dashboard/src/work/runs.ts:1176–1177`), więc zadanie zostaje w terminalu.
- **Wersja to już 0.5.4** (`project.godot:14`, wydanie `c82a4dd`). Kryterium P4 mówi `release.sh 0.5.3 --dry-run`. `--dry-run` tylko wypisuje kroki, także krok zgodności wersji, i niczego nie sprawdza, więc kryterium da się spełnić dosłownie. Wykonawca uruchamia dodatkowo `release.sh 0.5.4 --dry-run` (bieżąca wersja) i `release.sh 9.9.9` (zatrzymanie na pierwszym kroku).
- **Numery linii T7 są aktualne.** Sprawdzone wyszukiwaniem: `system.dialogue:105`, `racibor.dialogue:43,50,69,144,186`, `miroslaw.dialogue:192`, `write_gwara.js:180–181`, `game_state.gd:581`, `write_story_data.js:196,200,201`, `CZYTAJ_MNIE.txt:26`. Wyjątki Nasira to `nasir.dialogue:45,46,107` i `write_story_data.js:106`.
- **`additionalDirectories` w `.claude/settings.json`** zna tylko `../everhorror-wdrozenie`. Przy P1 dochodzi `../everhorror-wt`, żeby sesja terminalowa widziała kopie gałęzi (szczegół przyjęty bez pytania, do weta w przeglądzie).
- **Scalanie automatyczne (D-35)** ruszy samo, gdy arkusz jest wypełniony bez ❌, przegląd kodu ma `gotowe`, a build jest aktualny. Wymaganie P1 „Roland widzi diff przed zatwierdzeniem” spełnia przegląd (`/ai-task review 22`) albo wyłączenie scalania automatycznego na Praca na czas tej gałęzi. Decyzji to nie wymaga, tylko uwagi przy wypełnianiu arkusza.
- **Wspólne pliki z innymi zadaniami** (więc nie wdrażać ich równolegle z task_22): task_29 (`write_story_data.js`, `notebook.gd`, `data_lint.gd`), task_30 i task_32 (`data_lint.gd`), task_33 (`write_story_data.js`), task_26 (`game_state.gd`). Wiersz `Pliki:` wyżej pozwala dashboardowi to wykryć.
- **Etap 6 (ZYL-10, poz. 9 kolejki) wymienia do poprawy zdania z „dwanaście żył”.** T7 trzeba więc wdrożyć przed nim: wtedy zmiana normy to jedna liczba plus `quota_words()`.

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->
Wdrożenie z dashboardu, przebieg `20261028-063839-implement-22-2f950c`, gałąź `spec/2026-10-28-task22`, commit `333b147`. **P1 niewykonane** (zob. niżej), reszta gotowa.

### P1: uprawnienia (`.claude/settings.json`): NIE WYKONANE
Reguły przebiegu (`run-rules.md` §1) zabraniają zapisu w `.claude/`, a analiza już mówiła, że P1 trzeba robić w terminalu. Plik jest nietknięty. Poniżej propozycja diffu do zastosowania w sesji terminalowej w kopii gałęzi (po niej: próba z karty, pytanie 2a, `claude -p` z `--setting-sources project --permission-mode dontAsk --max-budget-usd 0.5`):

```json
"additionalDirectories": ["../specification", "../everhorror-wdrozenie", "../everhorror-wt"],
"allow": [
  "Bash(git status:*)", "Bash(git log:*)", "Bash(git diff:*)", "Bash(git show:*)", "Bash(git ls-files:*)",
  "Bash(git rev-parse:*)", "Bash(git rev-list:*)", "Bash(git merge-base:*)", "Bash(git branch --list:*)",
  "Bash(git branch --show-current:*)", "Bash(git branch --merged:*)", "Bash(git branch -d:*)", "Bash(git worktree list:*)",
  "Bash(git worktree add:*)", "Bash(git remote -v:*)", "Bash(git fetch:*)", "Bash(git pull --ff-only:*)", "Bash(git mv:*)",
  "Bash(git -C * status*)", "Bash(git -C * log*)", "Bash(git -C * diff*)", "Bash(git -C * show*)", "Bash(git -C * ls-files*)",
  "Bash(git -C * rev-parse*)", "Bash(git -C * rev-list*)", "Bash(git -C * merge-base*)", "Bash(git -C * branch*)",
  "Bash(git -C * worktree list*)", "Bash(git -C * add*)", "Bash(git -C * commit*)", "Bash(git -C * mv*)", "Bash(git -C * rm*)",
  "Bash(git -C * restore*)", "Bash(git -C * switch*)", "Bash(git -C * fetch*)", "Bash(git -C * pull --ff-only*)", "Bash(git -C * push*)",
  "Bash(node dashboard/cli.ts:*)", "Bash(node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts:*)",
  "Bash(node tools/*)", "Bash(node C:/dev/gamedev/everhorror/everhorror-wt/*/tools/*)", "Bash(node C:/dev/gamedev/everhorror/everhorror-wdrozenie/tools/*)",
  "Bash(tools/run_tests.sh:*)", "Bash(tools/release/release.sh:*)",
  "...bez zmian: Godot, cp -r, mkdir, ls, cat, grep, head, tail, wc, diff, date"
],
"ask": [
  "Bash(git tag:*)", "Bash(git -C * tag*)",
  "Bash(git -C C:/dev/gamedev/everhorror/everhorror push * master*)", "Bash(git push * master*)"
],
"deny": [
  "...dotychczasowe (force push, reset --hard, clean, branch -D, checkout, stash, rebase) +",
  "Bash(git merge *)", "Bash(git -C * merge *)",
  "Bash(git worktree remove:*)", "Bash(git -C * worktree remove*)",
  "Bash(git switch:*)"
]
```

Uwagi do diffu:
- **`git switch` w głównej kopii:** `git switch` bez `-C` (czyli forma `git switch …` wywołana z głównej kopii) jest odrzucona, a `git -C <kopia gałęzi> switch …` przechodzi (potrzebne `ai-task fix` i `spec-sync`). Reguły `deny` nie odróżniają ścieżek, więc w praktyce wystarczy zakaz formy bez `-C`; zakaz `git -C C:/dev/gamedev/everhorror/everhorror switch*` można dopisać wprost.
- **Spacja we wzorcach** (`git merge *`), żeby nie łapać `git merge-base`, którego używa `spec-tasks`.
- **Tag i push `master` gry** na liście `ask` (karta, 1a): w terminalu pyta Rolanda, w `dontAsk` jest odrzucane. Push `master` specyfikacji (`git -C …/specification push everhorror-spec master`) nie pasuje do wzorców z `…/everhorror push`, bo to inne repozytorium.
- **Skrypty `node` z kopii gałęzi** (`tools/*`, `tools/generators/*.js`, `tools/release/stamp_build.js`) pokrywa `node tools/*` i `node …/everhorror-wt/*/tools/*`. `release.sh` dochodzi do `allow` (`tools/release/release.sh`), ale w przebiegu z dashboardu strażnik i tak go nie uruchomi bezpośrednio.
- Reguły Bash nie są granicą bezpieczeństwa (ARCHITEKTURA.md, „Profil przebiegu”): chronią przed pomyłką.

Zestawienie „polecenie skilla → reguła” (do uzupełnienia po zastosowaniu): odczyt git → `git status/log/diff/show/ls-files/rev-parse/rev-list/merge-base/branch --list/--merged/--show-current/worktree list/remote -v` i formy `-C`; `add/commit/mv/rm/restore/switch/push/pull --ff-only/fetch` tylko w formie `-C <ścieżka>`; `worktree add`, `branch -d` w głównej kopii; `node …/cli.ts …` (obie formy), `node tools/*`; `tools/run_tests.sh`; Godot `--import`. Niepokryte: `git push <remote> --delete spec/…` (po zgodzie Rolanda): pasuje do `git -C * push*`, więc przechodzi; merge, tag, push master gry, `worktree remove` są w `deny`/`ask`. Wynik próby `claude -p`: do wpisania po wykonaniu (nie wykonana w tym przebiegu).

### P4: skrypt wydania
`tools/release/release.sh <wersja> [--spec <rev>] [--dry-run]`: zgodność wersji z `project.godot` → `stamp_build.js --check` → `stamp_build.js [--spec]` → `--import` → `--export-release` (log w `reports/release-export.log`, potem sprawdzenie, że `Everhorror.exe` jest nowszy niż start) → `make_zip.sh`; na końcu wypisuje `git add/commit`, `git tag`, `git push` i przypomnienie o jednym commicie specyfikacji, niczego z tego nie wykonuje. `set -euo pipefail`, `--dry-run` tylko wypisuje. `tools/README.md` (wiersz w tabeli i sekcja Wydanie) opisuje skrypt.
**Nieprzetestowane w tym przebiegu:** strażnik dashboardu nie uruchamia skryptów z kopii gałęzi bezpośrednio, a bit wykonywania nie dał się ustawić (`git update-index` jest zablokowany). Kryteria z `release.sh 0.5.3 --dry-run`, `release.sh 0.5.4 --dry-run` i `release.sh 9.9.9` (zatrzymanie na kroku 1) sprawdza człowiek w terminalu po `git update-index --chmod=+x tools/release/release.sh` (albo `bash tools/release/release.sh …`). Skrypt przeczytany linia po linii; bash `-nt` na pliku znacznika `reports/.release-start`.

### K4: rejestr flag
- `tools/data_lint.gd` (`_write_flag_registry`) zapisuje `reports/flags.tsv` (flaga, ustawiana w, czytana w, ładunek, rodzina), posortowany, bez numerów linii i dat. Dochodzą źródła `script/data/*.gd` i `write_world_data.js` (także `flag:`/`noflag:` grafu miejsc jako odczyty).
- `tools/generators/write_flags_doc.js` robi z niego `docs/agent/flags.md` (234 flagi, nagłówek „plik generowany”, rodziny w osobnej części). Powtórne uruchomienie (lint + generator) nie zmieniło pliku (`git status` bez zmian po drugim przebiegu).
- Lint nadal widzi to samo co przedtem (`read_flags.size() > 100`), nic nie usunięto.
- `08_technika.md:37–54` w specyfikacji: **propozycja dla Rolanda** (poza zadaniem): skrócić do 15 najważniejszych flag z odnośnikiem do `docs/agent/flags.md`.

### T7: liczba żył słowami
- `GameState.quota_words(przypadek, wielka_litera, z_rzeczownikiem)` (tabela 0–20 z komentarzem `lint-quota`, dalej cyfry z `plural()`) i `GameState.quest_entry_text()` (markery `{norma}`, `{Norma}`, `{norma_dop}`, `{norma_dop_liczba}`).
- Zamienione miejsca: `system.dialogue:105`, `racibor.dialogue:43,50,69,144,186`, `miroslaw.dialogue:192` (klucz i wartość w `write_gwara.js` zawierają identyczne `{{quota_words("nom", true)}}`; `dialogue/gwara_slaska.json` wygenerowany), komunikat w `game_state.gd` (`_check_quota`), trzy wpisy zadania „zloza” w `write_story_data.js` (`data/quests/zloza.tres` wygenerowany), notes (`notebook.gd`) i toast `quest_updated` używają `quest_entry_text()`.
- Miejsca oznaczone `lint-quota` (wyjątki): `dialogue/nasir.dialogue:45,46,107` (lata, nie żyły), `write_story_data.js:107` (historia Nasira), obie tablice liczebników w `game_state.gd`. `CZYTAJ_MNIE.txt` bez zmian; lint sprawdza, że „… żył błękitu” zgadza się z `quota_words()` dla `QUOTA`.
- Reguła lintu `_check_quota_literals` (czerwona). Po zmianie nic nie zgłasza. Reguły nie uruchomiłem na kodzie sprzed zmiany (gałąź nie ma wersji bez zamian, a `git stash`/`checkout` są zabronione); wiem tylko, że przy pierwszym przebiegu zgłosiła cztery wystąpienia w moich własnych komentarzach pomocnika, więc wzorzec działa.
- Tekst dla gracza taki sam jak przed: nowe testy `unit` (wpisy `start`, `zdane`, `norma` = dosłowny dotychczasowy tekst) i `dialogue` (linia Mirosława z gwarą i bez; linie Racibora w istniejących scenariuszach w logu: „Kniaź chce dwunastu żył do wieczora siódmego dnia…”, „Do dwunastu jeszcze daleko.”, „…chce dwunastu żył na mapie. Mamy 2.”).

### K6: polskie literały
`_check_polish_literals` w `data_lint.gd` liczy dla każdego pliku `script/**/*.gd` łańcuchy poza komentarzami i `tr("…")` z polską literą albo słowem z listy `POLISH_WORDS`. Stan bazowy w `tools/lint_baseline.json` (17 plików, 337 literałów; liczy mniej niż wyszukiwanie z analizy, bo pomija komentarze). Wzrost = błąd, spadek = przypomnienie. Próba robocza: dopisany `const _TRIAL := "Próba robocza"` w `game_state.gd` dał `RESULT: 1 FAILED` i linię „63 Polish literals, baseline 62”; cofnięta. Tabela `Texts`: nie dodana (konwencja opiera się na `tr()`). Sposób liczenia opisany w `tools/README.md`.

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->
- Decyzje Rolanda: karta [2026-10-27_task22-uprawnienia-i-norma](../../../../specification/zgloszenia/zamkniete/2026-10-27_task22-uprawnienia-i-norma.md), Roland, 2026-10-27 (dashboard): 1: a, 2: a, 3: a, 4: a.
- Przyjęte przez agenta bez pytania (do weta w przeglądzie; wymienione w karcie, sekcja „Przyjęte”):
  - zakaz `git switch` tylko w głównej kopii;
  - reguły zakazu ze spacją (`git merge *`), żeby nie łapały `merge-base`;
  - push `master` objęty regułą tylko w repozytorium gry;
  - `node` zawężony do narzędzi gry i `cli.ts`;
  - komentarz `lint-quota` przy Nasirze i tabeli liczebników;
  - bez tabeli `Texts`.
- Worktree: od 2026-10-27 każda gałąź zadania ma własny katalog w `everhorror-wt/` (`CLAUDE.md`), więc plan i reguły `node` biorą tę ścieżkę.
- **Przepływ (D-36).** Poziom `rozgrywka`: T7 zmienia `script/game_state.gd`, `script/notebook.gd`, dialogi, gwarę i `data/quests` (tekst dla gracza ma pozostać identyczny), czyli kod i dane gry; poziom `narzędzia` ich nie obejmuje, choć większość zadania (lint, generatory, skrypt wydania, uprawnienia) to narzędzia, a rodzaj „narzędzia” znaczy tu tylko brak reguły ⬜. Ryzyko `wysokie`: zmiana uprawnień w `.claude/settings.json` może zatrzymać wszystkie kolejne przebiegi, a zadanie dotyka 19 plików, w tym dialogów i danych generowanych; łańcuch zatrzyma się po analizie, a diff uprawnień ogląda Roland w przeglądzie przed scaleniem. Skryptu `release.sh` agent nie uruchamia poza `--dry-run` i `9.9.9` (zatrzymanie na pierwszym kroku); wydanie robi karta „Wydanie” w dashboardzie.

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->
**Po przebiegu z dashboardu (2026-10-28) zostają dwie rzeczy dla sesji terminalowej** (w kopii gałęzi `spec/2026-10-28-task22`):
1. P1: zastosować diff z „Co zostało zrobione” w `.claude/settings.json`, zestawić polecenia skilli z regułami i zrobić płatną próbę `claude -p` (limit 0,5 USD). Bez tego zadanie jest wdrożone w 4/5.
2. `git update-index --chmod=+x tools/release/release.sh`, potem `release.sh 0.5.3 --dry-run`, `release.sh 0.5.4 --dry-run` i `release.sh 9.9.9` (kryterium P4).

Wcześniejsza treść: karta [2026-10-27_task22-uprawnienia-i-norma.md](../../../../specification/zgloszenia/zamkniete/2026-10-27_task22-uprawnienia-i-norma.md) jest rozstrzygnięta (Roland, 2026-10-27, dashboard: 1: a, 2: a, 3: a, 4: a); plan wyżej ją uwzględnia. Task17 jest już scalony (aktualizacja 2026-10-27), więc została jedna rzecz:
1. Uruchomić wdrożenie w terminalu (`/ai-task implement 22`), bo przebiegi z dashboardu nie mogą zapisywać w `.claude/`. Ta sesja zrobi też płatną próbę uprawnień z pytania 2 (limit 0,5 USD).

## Test
Scenariusze zadania: tylko zestaw podstawowy (`unit lint dialogue`), uruchamia go serwer po wdrożeniu. Arkusz: część `## Część: task_22` w [factcheck-build-333b147](../../human-tasks/factcheck-build-333b147.md).

Wyniki agenta (kopia gałęzi, commit `333b147`):
- `unit`: `RESULT: ALL PASSED`; `lint`: `RESULT: ALL PASSED` (WARNINGS: 20, tyle co przed zmianą); `dialogue`: `RESULT: ALL PASSED`.
- Przed commitem był jeden czerwony przebieg `lint` (cztery trafienia reguły T7 w komentarzach pomocnika), poprawiony.
- Pełnego zestawu nie uruchamiałem. Kroku `RULES` lintu nie było (kopia gałęzi nie ma sąsiedniej specyfikacji).

## Poprawki (2026-10-28)
Po ocenie koordynatora (zasada Rolanda „zostaje to, co nadal poprawia sytuację”), jeden wykonawca w terminalu, gałąź `spec/2026-10-28-task22`, commit scalający `1be063f` (rodzice `333b147` i `0cd8e61` z `master`).
- **Ocena koordynatora.** P4 odpada: `tools/release/release.sh` usunięty (`git rm`, wzmianki w `tools/README.md` zdjęte). Wydanie robi karta „Wydanie” na dashboardzie, a ręcznie `tools/release/make_zip.sh`, który po scaleniu `master` robi też test eksportu (zob. „Wydanie” w `tools/README.md`). P1 (`.claude/settings.json`) przechodzi do koordynatora w terminalu i nie jest częścią tych poprawek. Zostają K4, T7 i K6.
- **Scalenie `master`** (task_25, task_37, narzędzia źródła prawdy): konflikty tylko w `docs/agent/README.md` i `tools/README.md`. W pierwszym wzięta linia `master` o `data/` (eksport, `convert_text_resources_to_binary=false`) plus zdanie o `flags.md`; w drugim wiersz `stamp_build.js` z `master` (linia gałęzi z `release.sh` odpada razem z P4), reszta sekcji lintu i generatorów gałęzi zachowana.
- **T7 po otwarciu.** `dialogue/system.dialogue`, węzeł `intro_opening` (task_37): „dwunastu żył błękitu” zamienione na `{{quota_words("gen")}}`, tekst dla gracza bez zmian. Nowa kontrola w `tools/dialogue_test.gd` (`_task37`): wstęp otwarcia zawiera „Kniaź chce do końca tygodnia dwunastu żył błękitu na mapie.”. Inne literały z task_37: tylko Nasir („dwunastu latach”, już oznaczone `lint-quota`). Linie Mirosława i Bolka bez zmian, więc `write_gwara.js` i `gwara_slaska.json` nietknięte.
- **K6 po task_37.** Wzrósł tylko `script/run_report.gd` (100 → 105): etykieta `ENDING_TITLES` „Koniec otwarcia”, klucze czasu „Z Mirosławem po wybuchu” i „Nad kartką dziadka” oraz dwie wartości „obóz”. To dane raportu testerów (klucze muszą równać się etykietom czasu z dialogów, a `const` nie wywoła `tr()`), więc baza `tools/lint_baseline.json` podniesiona do 105 zamiast zmieniać zachowanie. `story_director.gd` bez wzrostu.
- **K4.** `docs/agent/flags.md` zregenerowany (252 flagi, w tym `opening`, `opening_done`, `opening_maps`). Nowość: `node tools/generators/write_flags_doc.js --check` (nic nie zapisuje, kończy się 1, gdy plik jest nieaktualny); `tools/run_tests.sh lint` woła go po lincie (`+flags.md STALE` w linii wyniku i czerwony scenariusz). Sprawdzone: przed regeneracją lint pokazał `STALE`, po niej przeszedł. `tools/README.md` opisuje `--check`.
- **Testy** (`tools/run_tests.sh unit lint dialogue opening day1 expedition`, kopia gałęzi po `--import`):
  - `unit  3s  RESULT: ALL PASSED`
  - `lint  8s  RESULT: ALL PASSED` (WARNINGS: 20, bez zmian; krok RULES pominięty, brak sąsiedniej specyfikacji w `everhorror-wt/`)
  - `dialogue  6s  RESULT: ALL PASSED`
  - `opening  52s  RESULT: ALL PASSED  (50.1 s)`
  - `day1  24s  RESULT: ALL PASSED  (22.2 s)`
  - `expedition  15s  RESULT: ALL PASSED  (13.9 s)`
  - `tools/export_smoke.sh`: `RESULT: ALL PASSED (export smoke: day1 expedition ran from the exported pack)`.
- **Po przeglądzie kodu** (commit `0201e9c`). Przegląd wskazał luki w pokryciu i trzy drobne wady lintu; zmiany: (1) `tools/dialogue_test.gd` (`_quota_lines`) sprawdza dosłownie wstęp tygodnia i pięć linii Racibora, a `tools/unit_test.gd` toast „Dwanaście żył. Norma Kniazia zrobiona.” (pojawia się raz); w `data_lint.gd` reguła T7 jest wydzielona do `_quota_literal_hits()` i ma test negatywny na tekstach próbnych (stary literał bez `lint-quota` jest zgłaszany, z wyjątkiem nie); (2) rejestr flag czyta też `get_flag("…")` i `earlier_day("…")`, więc `bet_target`, `hier_count`, `wall_fails` i `hrapek_meetings` mają czytających, `flags.md` zregenerowany, `--check` przechodzi; (3) K6 rozpoznaje `tr(` po granicy słowa (`str("…")` i `_tr("…")` już nie są wyjątkiem), baza `lint_baseline.json` bez zmian; (4) porównanie `CZYTAJ_MNIE.txt` usuwa też `\r`; (5) tablice liczebników w `game_state.gd` mają typ `Array[String]`. Testy `unit lint dialogue opening day1 expedition`: wszystkie `RESULT: ALL PASSED`.
- **Arkusz.** Wiersze 1–4 części task_22 w `docs/human-tasks/factcheck-build-333b147.md` Roland sprawdził na buildzie `f1e6f37`, który nie zawierał `333b147`. Po tych poprawkach potrzebny jest nowy build i ponowne sprawdzenie tych wierszy (arkusza nie edytowałem). Wiersz 5 (`release.sh --dry-run`) jest nieaktualny, bo skrypt usunięto.

### P1 w terminalu (koordynator, 2026-10-28)
`.claude/settings.json` głównej kopii: nowa lista `ask` (tag, `merge`, push `master` gry do zdalnego `everhorror`; push specyfikacji zostaje w `allow`, bo przebiegi z dashboardu wypychają ją same) i `../everhorror-wt` w `additionalDirectories`. Lista `allow` i `deny` bez zmian, żeby przebiegi w trybie `dontAsk` nie straciły poleceń. Próby `claude -p` za 0,5 USD (decyzja 2a karty) nie robiono: ten sam skutek sprawdza strażnik przebiegu i audyt, a reguła `ask` działa w `dontAsk` jak odmowa.

## Podsumowanie
Poprawki z 2026-10-28: P4 odrzucony (`release.sh` usunięty, wydanie zostaje przy karcie dashboardu i `make_zip.sh`), P1 przeszedł do koordynatora w terminalu. `master` scalony do gałęzi (commit `1be063f`); K4 (rejestr flag z flagami otwarcia plus kontrola aktualności w `lint`), T7 (wstęp otwarcia przez `quota_words()`, test w `dialogue`) i K6 (baza `run_report.gd` 105) uzupełnione. Testy `unit lint dialogue opening day1 expedition` i test eksportu zielone. Do zrobienia: nowy build i ponowne sprawdzenie wierszy 1–4 arkusza, P1.

Poprzednie podsumowanie (wdrożenie z dashboardu, 2026-10-28): K4, T7, K6 i P4 gotowe na gałęzi `spec/2026-10-28-task22` (commit `333b147`), testy `unit lint dialogue` zielone, teksty dla gracza bez zmian. P1 (`.claude/settings.json`) nie wykonane, bo przebieg z dashboardu nie może pisać w `.claude/`; diff jest w „Co zostało zrobione”. `release.sh` nieprzetestowany (strażnik nie uruchamia go bezpośrednio, brak bitu wykonywania). Obie rzeczy robi sesja terminalowa.

Poprzednie podsumowanie (analiza): analiza gotowa (2026-10-27), plan w siedmiu krokach powyżej. Karta decyzji jest rozstrzygnięta zgodnie z rekomendacjami: tag i push `master` gry trafiają na listę `ask`, uprawnienia sprawdza krótki przebieg w worktree zadania, `CZYTAJ_MNIE.txt` zostaje bez zmian (lint sprawdza zgodność z normą), a T7 obejmuje też wpisy notesu. Aktualizacja z tego samego dnia: task17 jest scalony, więc warunek startu odpada. Dopisany jest wiersz `Pliki:`, test `release.sh` uwzględnia wersję 0.5.4, a lista wspólnych plików z task_26, task_29, task_30, task_32 i task_33 wyklucza ich równoległe wdrażanie. Wdrożenie może ruszyć od razu, ale tylko w terminalu, bo przebiegi z dashboardu nie mogą zapisywać w `.claude/`.
