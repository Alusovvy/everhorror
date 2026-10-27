# Proces: specyfikacja → zadanie → przebieg → gałąź → build → arkusz → scalenie → domknięcie

> Audyt 2026-10-27 · część „proces” · autor: agent (Fable 5.1 high), tylko odczyt · czytelnik: Roland
>
> Liczby pochodzą z zapisów przebiegów w `everhorror/reports/dashboard-runs/` (18 przebiegów z 2026-10-27, czasy w UTC), z gita obu repozytoriów i z plików procesu. Każde twierdzenie ma źródło; przypuszczenia są oznaczone „założenie”.

## 1. Jak wygląda jedno zadanie dziś

Ścieżka według `specification/dashboard/INSTRUKCJA.md` §4 i `WORKFLOW.md` „Od pomysłu do sprawdzenia”:

| Krok | Kto | Kliknięć Rolanda (ok.) | Model | Co powstaje |
|---|---|---|---|---|
| 1. Zmiana w specyfikacji | Roland | 5–6 (Zmień → Znacznik → Koszyk → Zapisz → Zatwierdź) | — | commit specyfikacji |
| 2. Zaplanuj zadania | klik + agent | 1 (+ okno startu) | Opus | `task_NN.md`, wiersz „W zadaniach”, commit ledgera |
| 3. Analizuj | klik + agent | 1 | Opus | „Analiza”, „Plan”, `Pliki:`; często karta decyzji |
| 3a. Rozstrzygnij kartę | Roland | 1–2 | — | commit karty |
| 3b. Wznów analizę | klik + agent | 1 | Opus | aktualizacja pliku zadania |
| 4. Wdróż na gałęzi | klik + agent | 1 (+ 2 pola w oknie) | Sonnet | commit na `spec/*`, arkusz, wiersz 🧪, build do ogrania (serwer) |
| 5. Zagraj i wypełnij arkusz | Roland | 2 + gra | — | commit arkusza |
| 6. Przegląd kodu | klik + agent | 1 | Opus | werdykt JSON |
| 7. Scal do master gry | Roland | 1 (+ 3 pola w oknie) | — | commit scalenia, push |
| 8. Domknij zadanie | klik + agent | 1 | Sonnet | ⬜→✅, wiersze ledgera, `done/` |
| 9. Zapisz dokumenty w historii gry, Wypchnij grę | Roland | 2 | — | commit dokumentów |
| 10. Wydanie (wersja, CHANGELOG, tag) | terminal | — | agent w terminalu | tag |

Razem: **12–15 kliknięć i 5–7 przebiegów modelu na jedno zadanie**, plus czytanie raportów i okien. Każdy klik otwiera okno z 3–6 polami (model, wysiłek, budżet, tury, minuty, zgody), które „pamięta ostatni wybór” (INSTRUKCJA §4).

### Gdzie idzie czas: model pracuje minuty, Roland czeka i decyduje godzinami

Z `run.json` 18 przebiegów (2026-10-27):

| Przebieg | Czas modelu | Przerwa przed nim (czas Rolanda) |
|---|---|---|
| plan 06:07 | 1,5 min | — |
| plan 07:44 | 7,8 min | 96 min |
| analyze 16, 17 | 2,7 + 1,6 min | 1 + 2 min |
| implement 16 | 4,9 min | 5 min |
| review 16 | 1,4 min | 1 min |
| analyze 18 | 2,3 min | 7 min |
| analyze 20 | 4,1 min | **348 min** |
| finalize 16, implement 17, review 17 | 0,7 + 7,0 + 0,9 min | 2 + 4 + 2 min |
| analyze 21, 22 | 2,4 + 6,4 min | 13 + 34 min |
| analyze 20/21/22 (wznowienia) | 0,7 + 0,6 + 0,9 min | 57 + 0 + 0 min |
| review 17 (drugi), finalize 17 | 2,5 + 0,7 min | 1 + 1 min |

Suma czasu modelu: **ok. 49 min**. Suma przerw: **ok. 9,5 h** (w tym jedna 5,8 h; bez niej 3,7 h). Wniosek: w dniu z 18 przebiegami agent pracował niecałą godzinę, a resztę zajmowały decyzje, czytanie, gra i inne zajęcia. **Skrócenie przebiegów nic nie da; liczy się liczba momentów, w których proces czeka na Rolanda, i ile trzeba wtedy przeczytać.**

Koszt dnia: **17,61 USD** za 18 przebiegów (suma przyrostów `model_usage_since_last_result` ze zdarzeń `result`; dashboard pokazuje 22,32 USD, bo dla przebiegów wznowionych zapisuje skumulowany `total_cost_usd` rodzica i dziecka, zob. `dashboard.md` D4). Jedno zadanie od analizy do domknięcia (task_17: analyze 0,55 + implement 0,56 + review 0,55 + finalize 0,22) kosztowało **1,9 USD**, a z drugim, zbędnym przeglądem 2,5 USD; z udziałem planowania i jedną kartą decyzji wychodzi ok. 3–4 USD. To tanio w dolarach; realnym limitem jest kwota subskrypcji (`rate_limit_event`: wykorzystanie 7-dniowe wzrosło w ciągu dnia z 0,27 do 0,39). Drogie względem pracy są analizy, które kończą się kartą i wznowieniem (poniżej, P2).

## 2. Ustalenia (P1…P16)

Każde: dowód → skutek → propozycja → koszt (S do 2 h pracy agenta, M do dnia, L więcej) → ryzyko → czego dotyka (reguła, decyzja).

### P1. Uwaga Rolanda jest wąskim gardłem, a proces mnoży momenty oczekiwania
- **Dowód.** Tabela wyżej: 49 min modelu wobec 9,5 h przerw. Każdy etap zadania kończy się stanem „czeka na klik” (INSTRUKCJA §4: 8 kroków, każdy osobnym przyciskiem; `WORKFLOW.md` „Każdy krok to kliknięcie Rolanda”).
- **Skutek.** Zadanie z pięcioma przebiegami po 2 min trwa pół dnia; trzy równoległe analizy (D-33) nie pomagają, gdy każda kończy się kartą decyzji, którą trzeba rozstrzygnąć osobno i osobno wznowić.
- **Propozycja.** Trzy momenty uwagi na zadanie zamiast ośmiu: **(a) decyzje projektowe** (specyfikacja, karty, wszystkie naraz w jednym ekranie „Do rozstrzygnięcia”), **(b) gra i arkusz** (tylko dla zadań, które zmieniają rozgrywkę, zob. P3), **(c) scalenie** (albo automat D-35). Reszta (analiza → wdrożenie → testy → build → przegląd → domknięcie) idzie jako łańcuch na serwerze bez kliknięć między etapami; kolejka startów z task_24 jest pierwszym krokiem, łańcuch „analiza → wdrożenie → przegląd” drugim. Przerwanie łańcucha tylko gdy: karta decyzji, czerwony test, werdykt „poprawki”, konflikt `merge-tree`.
- **Koszt.** M (po task_24: definicja łańcucha w `runner.ts`/`runs.ts`, jeden przycisk „Zrób zadanie do przeglądu”). **Ryzyko.** Przebieg wdrożenia startuje bez spojrzenia Rolanda na plan; dlatego łańcuch ma zatrzymać się po analizie, gdy plan dotyka plików spoza `Pliki:` zadania albo gdy analiza zgłasza ryzyko „wysokie”.
- **Dotyka.** `WORKFLOW.md` „Praca w dashboardzie” (każdy krok to klik), D-16 („jeden naraz”), D-33. Decyzja Rolanda: tak/nie dla łańcucha i gdzie ma się zatrzymywać.

### P2. Wznowienie analizy po karcie kosztuje 3–6 razy więcej niż sama analiza
- **Dowód.** `run.json` przebiegów `20261027-162255-analyze-20-980c6e`, `…-162400-analyze-21-874667`, `…-162453-analyze-22-ce6d53`: `resumeOf` wskazuje na poranne analizy; uwaga Rolanda to jedno zdanie („Karta … rozstrzygnięta: 1: a, 2: a, 3: a. Kontynuuj.”). Kontekst pierwszej tury (z `events.jsonl`, `usage` pierwszej odpowiedzi): **96 180, 68 362 i 111 431 tokenów** wobec 22–23 tys. w świeżym przebiegu. Rzeczywisty przyrost kosztu: **0,99, 0,64 i 1,17 USD** za 12, 5 i 11 tur (dashboard pokazuje 2,55, 1,55 i 3,38, bo dolicza rodzica), z czego ok. 80 % to ponowny zapis starego zapisu rozmowy do cache (62–105 tys. tokenów po 8 USD/MTok), bo przerwa 1–2 h przekroczyła godzinny czas życia cache, a nowy kontrakt (inny id, czas, uwaga) i tak unieważnia prefiks. Praca właściwa to 3–5 wywołań: 1–4 odczyty i 3–6 edycji pliku zadania. Dla porównania pierwotne analizy: 1,56, 0,91 i 2,21 USD.
- **Skutek.** Przebieg, który tylko przepisuje zdanie decyzji do pliku zadania, kosztuje tyle co cała analiza (razem 2,8 z 17,6 USD dnia).
- **Propozycja.** (1) „Wznów” nie wznawia sesji, tylko startuje **świeży, krótki przebieg** z plikiem zadania (analiza już w nim jest) i treścią karty; model Sonnet albo Haiku, limit 20 tur. (2) Jeszcze taniej: gdy każda opcja karty ma opis (lint `OPCJA_KOD_BEZ_OPISU` już tego pilnuje), serwer sam dopisuje do pliku zadania sekcję „Decyzje z karty: 1: a — …” bez modelu, a wdrożenie czyta ją jak zwykle; przebieg modelu tylko gdy analiza zaznaczyła „plan zależy od wyboru”. (3) Gdy wznowienie zostaje: wznawiać w ciągu godziny albo ustawić cache 1 h dla analiz, które kończą się kartą (`cacheCreationEphemeral1hInputTokens` pojawia się już w przeglądach).
- **Koszt.** S dla (1), M dla (2). **Ryzyko.** (2) pomija przemyślenie wyboru przez model; dlatego flaga „plan zależy od wyboru” w analizie.
- **Dotyka.** `src/work/runs.ts` (treść „Wznów”), `node/runner.ts` (`resumeOf`), INSTRUKCJA §4 krok 3.

### P3. Arkusz człowieka jest bramką także dla zmian, których nie da się „zagrać”
- **Dowód.** task_17 (dwa zdania tekstu): arkusz `docs/human-tasks/done/factcheck-test-17.md` ma „Wyniki człowieka: Roland (dashboard), 2026-10-27 14:28” i „Zamknięcie … 14:28”, a przebieg wdrożenia skończył się 13:26 UTC = 14:26 lokalnie. Pierwszy build do ogrania task_17 powstał o 15:23 UTC (`build/do-ogrania/Everhorror-test-task17-2ca7904-windows.json`: `trigger: "klik"`, `afterRun: null`), czyli godzinę po wypełnieniu arkusza. `WDROZENIA.md` mówi wprost przy task_16 i task_17: „scalone, **bez** zagrania człowieka; arkusz … zamknął Roland (wyniki wpisał sam)”. Założenie: Roland uznał, że dwóch zdań nie trzeba grać, i słusznie.
- **Skutek.** Reguła „arkusz dopiero przy buildzie” (D-32) została ominięta już przy pierwszym zadaniu, więc jako bramka automatycznego scalania (D-35: „arkusz wypełniony bez ❌”) będzie formalnością. Proces traktuje tak samo zmianę zdania we wstępie i nowy system poczytalności.
- **Propozycja.** **Poziomy zadań** zapisane w pliku zadania (`Poziom: tekst | narzędzia | rozgrywka`), nadawane przez `/spec-tasks` z rodzaju zmian (tylko `.dialogue`/teksty → tekst; `tools/`, `docs/`, dashboard → narzędzia; reszta → rozgrywka):
  - **tekst**: bez arkusza; dowodem jest test (`dialogue`, `unit`) i zrzut ekranu zmienionego miejsca (narzędzie `screenshot.gd` z `tools/README.md`) dołączony do raportu; w `WDROZENIA.md` dopisek „sprawdzenie: automat (poziom tekst)”; scalanie automatyczne po przeglądzie;
  - **narzędzia**: bez arkusza, bez builda do ogrania; testy i przegląd;
  - **rozgrywka**: jak dziś, arkusz rosnący (D-27) i build (D-32), ale **jeden arkusz na build**, nie na zadanie: wiersze kilku zadań na tej samej gałęzi albo kilku gałęzi scalonych do master trafiają do jednego arkusza „build z <sha7>”, a Roland gra raz.
  To nie łamie §3 pkt 4 („agent nie wpisuje wyników za człowieka”): poziom tekst nie ma pól człowieka, więc nic nie jest wpisywane w jego imieniu; „zwolnienie” jest decyzją reguły, nie wpisem.
- **Koszt.** M (skill `spec-tasks` i `ai-task`, `derive.ts` dla bramek, szablon arkusza na build). **Ryzyko.** Błąd klasyfikacji: zmiana w `.dialogue` z nową flagą to rozgrywka; dlatego klasyfikacja po plikach plus lista słów kluczowych (`set_flag`, `advance_time`, liczby) → „rozgrywka”.
- **Dotyka.** D-32, D-27, D-35 (bramka scalania), `docs/human-tasks/INFO.md`. Decyzja Rolanda: czy poziomy „tekst” i „narzędzia” mogą być scalane bez arkusza.

### P4. Powtórzony przegląd bez zmiany na gałęzi
- **Dowód.** `…-142852-review-17-ab55bc` i `…-162633-review-17-eb4fc1`: oba „gotowe”, między nimi żadnego przebiegu poprawek ani commita na gałęzi (gałąź `2ca7904` w obu buildach i w manifeście). Koszt drugiego: 0,61 USD i 2,5 min, plus klik.
- **Skutek.** Założenie: werdykt stał się „nieaktualny” po aktualizacji dashboardu (task_23 zmienił format zapisów) albo po ponownym kliknięciu; INSTRUKCJA §4 krok 5 unieważnia werdykt tylko przy nowym commicie.
- **Propozycja.** Serwer odmawia startu przeglądu, gdy `HEAD` gałęzi = commit ostatniego werdyktu „gotowe” i nie ma uwagi Rolanda; przycisk pokazuje „Przegląd aktualny (sha7)”. Gdy powód to migracja formatu, przepisać stare werdykty zamiast ich unieważniać.
- **Koszt.** S. **Ryzyko.** Brak. **Dotyka.** `derive.ts` (bramka przeglądu), `work-api.ts`.

### P5. Pełny zestaw testów w przebiegu modelu zamiast na serwerze
- **Dowód.** Kontrakt `…-141956-implement-17-373758/contract.md`, zasada 7: „Roland zaznaczył … zgodę na pełny zestaw testów”; `policy.json`: `fullSuite: true`. Pełny zestaw trwa ok. 4,5 min (`reports/full_suite_3.txt`: 19 scenariuszy, najdłuższe `hrapek` 35 s, `camp_walk` 27 s). Przebieg wdrożenia task_17 trwał 7 min, z czego ponad połowa to testy, w czasie których model czeka (i czyta logi za tokeny).
- **Skutek.** Testy są tak samo wiarygodne jak sprawozdanie modelu: przegląd „nie uruchomił testów ponownie (Bash zablokowany), więc opiera się na zielonych logach z gałęzi” (`…-142852-review-17-ab55bc`, `result.text`). Automatyczne scalanie (D-35) ma warunek „testy przeszły”, a dziś ten fakt pochodzi od modelu.
- **Propozycja.** **Testy po przebiegu robi serwer**, tak jak build do ogrania: po udanym wdrożeniu albo poprawkach `runner.ts` uruchamia `tools/run_tests.sh` w kopii gałęzi (bez modelu, bez tokenów), zapisuje `RESULT` do `run.json` i do ramki na stronie zadania („Testy serwera: 19/19, 4 min 31 s”), potem dopiero build. Przebieg modelu uruchamia tylko warstwy, których dotknął. Przegląd i D-35 czytają wynik serwera, nie zdanie modelu. Z czasem to samo z lintem specyfikacji i `check_doc_links.js`.
- **Koszt.** M (wzór już jest w `playbuild.ts`). **Ryzyko.** Testy świata dzielą folder danych gracza (`tools/README.md`); serwer musi odmawiać, gdy gra jest uruchomiona (ten sam warunek co dziś dla scenariuszy). **Dotyka.** D-35 (źródło „testy przeszły”), `CLAUDE.md` „Tests” (bez zmiany reguły: pełny zestaw dalej za zgodą, ale zgoda to ustawienie serwera, nie modelu).

### P6. Kontrakt i strażnik przeczą sobie, a każda odmowa to stracona tura
- **Dowód.** `contract.md` (ten sam przebieg): „Polecenia: jedno na wywołanie … bez `cd … &&`” oraz „Plików tymczasowych nie twórz … wynik czytaj wprost, w razie potrzeby przez `| head`, `| grep`”. `guard.log` 13:20:53: blokada z komunikatem „`tools/run_tests.sh` trzeba uruchamiać z katalogu kopii wdrożeniowej (`cd C:/… && tools/run_tests.sh <scenariusz>`)”, czyli strażnik każe użyć formy, której kontrakt zabrania. `CLAUDE.md` „Tests”: „Never pipe a long Godot run through `grep`/`head`: write the log to a file”, czego kontrakt zabrania („plików tymczasowych nie twórz”). Druga blokada 13:26:33: `>>` do pliku zadania (zasada słuszna, ale model jej nie znał z kontraktu).
- **Skutek.** Dwie odmowy w jednym 40-turowym przebiegu to 5 % tur; w przebiegach Opusa każda tura z 23 tys. tokenów kontekstu kosztuje.
- **Propozycja.** (1) Jedna lista „co wolno w przebiegu” w jednym pliku (zob. P15), z przykładem poprawnego wywołania testów (`tools/run_tests.sh` ma już logi w `reports/tests/`; wystarczy zezwolić na `bash <kopia>/tools/run_tests.sh …` z pełną ścieżką i zmienić skrypt tak, żeby sam ustawiał katalog). (2) Folder roboczy na przebieg: `reports/dashboard-runs/<id>/tmp/` dozwolony do zapisu; serwer kasuje go po audycie. (3) Komunikat blokady zawsze podaje dozwoloną formę zgodną z kontraktem; test w `runguard.test.ts`, który sprawdza, że każda forma z komunikatów blokad przechodzi przez strażnika.
- **Koszt.** S. **Ryzyko.** Brak. **Dotyka.** `node/runguard.ts`, `src/work/runs.ts` (treść kontraktu), `tools/run_tests.sh`.

### P7. Każdy przebieg nosi 22–23 tys. tokenów kontekstu, zanim zrobi cokolwiek
- **Dowód.** Pierwsza tura: 22 543–24 077 tokenów w analizach, przeglądach i wdrożeniach; 17 291–17 703 w domknięciach (`events.jsonl`, `usage` pierwszej odpowiedzi). Składniki: prompt systemowy Claude Code z listą narzędzi, agentów i **skilli z wtyczek użytkownika** (`init.slash_commands` wymienia m.in. `deep-research`, `design`, `dataviz`, `claude-api`, `workflow-authoring`; plan §9 „Odłożone” (h) już to zna), `CLAUDE.md` (9 KB), skill `ai-task` (ok. 12 KB), kontrakt (3,7 KB), potem pliki czytane na starcie: `docs/agent/README.md`, `tools/README.md`, plik zadania, `INFO.md`.
- **Skutek.** Stały koszt ok. 0,3–0,5 USD na przebieg Opusa zanim model przeczyta kod zadania; przy 7 przebiegach na zadanie to 2–3 USD na samym „rozruchu”.
- **Propozycja.** (1) Ten sam prefiks dla wszystkich przebiegów (prompt systemowy + `CLAUDE.md` + skill) i 1 h cache: przebiegi w dniu pracy idą jeden po drugim, więc prefiks czytany z cache kosztuje 10 % ceny. Sprawdzić w `runner.ts`, czy kolejność dołączania plików jest stała (kontrakt na końcu, nie na początku). (2) Wyłączyć wtyczki użytkownika w przebiegach (ustawienie w `settings.json` przebiegu; do sprawdzenia w dokumentacji Claude Code, które pole to robi; założenie: jest). (3) Skrócić skill `ai-task`: tryby `status`, `close` i reguły terminalowe do osobnych plików, bo przebieg z dashboardu ich nie używa, a czyta.
- **Koszt.** S. **Ryzyko.** Cache 1 h kosztuje 2× zapis; opłaca się od drugiego przebiegu w godzinie, co w dniu pracy jest regułą. **Dotyka.** `node/runner.ts` (argumenty `claude -p`), `.claude/skills/ai-task/SKILL.md`.

### P8. Dokumenty po przebiegu czekają na ręczny zapis w historii
- **Dowód.** Audyt każdego przebiegu analizy: „Dokumenty gry zmienione przez przebieg czekają na zapis w historii (1)” (`run.json`, `audit.findings[].code = INTRODUCED`). INSTRUKCJA §4 krok 2: „Pliki zadań zapiszesz przyciskiem »Zapisz dokumenty w historii gry«”. Dziś w głównej kopii leży niezatwierdzone `docs/ai-tasks/task_24.md` i zmiana planu (`git status`), a domknięcie odmawia przeniesienia pliku spoza historii (`spec-sync` „Dashboard runs”).
- **Skutek.** Jeszcze jeden klik na zadanie, a zapomniany zapis blokuje domknięcie („NASTĘPNY KROK: Roland najpierw zapisuje…”).
- **Propozycja.** Serwer (nie przebieg) zapisuje dokumenty gry sam po audycie bez naruszeń, jednym commitem `docs: dokumenty zadań i arkusze (dashboard, po przebiegu <id>)` podpisanym jak dziś wybraną osobą; przycisk zostaje dla przypadku z naruszeniem. D-17(c) mówi, że **przebieg** nie commituje w grze; serwer po przebiegu to inna rzecz, tak jak build.
- **Koszt.** S. **Ryzyko.** Commit dokumentu, którego Roland nie przeczytał; ale czyta go i tak na stronie zadania, a git pozwala poprawić. **Dotyka.** D-17(c) (doprecyzowanie), INSTRUKCJA §9.

### P9. Modele i wysiłek zapisane w trzech miejscach, trzema wartościami
- **Dowód.** `CLAUDE.md` „Delegation (Roland, 2026-10-27)”: analizy na Opus 5.5 **medium**, kod Sonnet 5.5 high, prostsze Haiku 5.5 max. Plan D-18: Opus **high** dla planowania, analizy i przeglądu. INSTRUKCJA §4 tabela: opus/high, sonnet/high. Faktyczne przebiegi dnia: 12 z 18 na `medium` (`run.json.options.effort`), jeden `xhigh`, trzy `high`, jeden `low`.
- **Skutek.** Niejasne, które ustawienie obowiązuje; okno startu „pamięta ostatnie”, więc wartość zależy od tego, kto klikał ostatnio.
- **Propozycja.** Jedna tabela modeli w planie §9 (D-18 zaktualizowane o słowa Rolanda z `CLAUDE.md`), a `CLAUDE.md` i INSTRUKCJA tylko do niej odsyłają. Domyślne w kodzie dashboardu (`src/work/runs.ts`, `defaults(...)`) zgodne z tabelą; zalecenie: Opus medium dla analizy i przeglądu, Sonnet high dla kodu, Haiku dla domknięcia i „Sprawdź agenta” (domknięcie to mechaniczne polecenia `ledger`).
- **Koszt.** S. **Ryzyko.** Brak. **Dotyka.** D-18, `CLAUDE.md`, INSTRUKCJA.

### P10. Plan mówi „3 ze 128 ID reguł w kodzie”; dziś jest 31 ze 165
- **Dowód.** `final-plan-human-readable.md` §8.1: „tylko 3 ze 128 ID reguł są w kodzie lub testach”. Wyszukiwanie 2026-10-27: 165 unikatowych ID w plikach reguł specyfikacji; 31 z nich pojawia się w `script/`, `tools/` albo `dialogue/` (CZAS-16, DIA-2, DIA-5, NPC-18, ZYL-1…, TECH-1…3, ZAP-11/12 i inne).
- **Skutek.** Plan jest w tym punkcie nieaktualny, a nikt nie liczy pokrycia reguł testami, choć to najprostsza miara „czy gra robi to, co specyfikacja”.
- **Propozycja.** Lint pokrycia: dla każdej reguły ✅ lista miejsc w kodzie i testach, które ją wymieniają; raport `reports/rule-coverage.json` (generowany, jak `flags.tsv` z task_22). Reguła ✅ bez żadnego odniesienia dostaje ostrzeżenie (nie błąd). Ten sam plik zasila widok grafowy (`widok-grafowy.md`). Konwencja dla wykonawców: test, który sprawdza regułę, ma jej ID w nazwie kroku (`check("ZYL-4: …")`), co już robi `test_day1.gd` dla task_17.
- **Koszt.** S. **Ryzyko.** Brak. **Dotyka.** `tools/data_lint.gd` albo nowy `tools/rule_coverage.js`, plan §8.1 (poprawka liczby).

### P11. Plan jest dokumentem roboczym i archiwum naraz (660 linii) i przeczy sobie co do limitu gałęzi
- **Dowód.** `final-plan-human-readable.md`: §3 pkt 5 „najwyżej **1** otwarta gałąź z kodem”, „Gdzie jesteśmy” („obowiązuje limit jednej gałęzi”), INSTRUKCJA §4 krok 4 („otwarta jest inna gałąź `spec/*` (limit 1)”) wobec D-33 („do 3 wdrożeń … zastępuje »najwyżej 1 otwarta gałąź«”). §7 i §8 (ocena poprzedniej pracy, weryfikacja wcześniejszego planu) to historia, ale `CLAUDE.md` odsyła do pliku jako do „the one plan” i skille każą go czytać.
- **Skutek.** Agent czyta 33 tys. tokenów, z czego połowa to historia; przy sprzeczności musi zgadywać, która linia jest nowsza.
- **Propozycja.** Podział na **`plan.md`** (≤ 200 linii: gdzie jesteśmy, etapy jako tabela, §3 zasady, §4 cele, §5 czego nie robimy, tabela decyzji D-xx jednym wierszem każda z odsyłaczem do karty w `zgloszenia/`) i **`docs/archiwum/plan-historia-2026-10.md`** (§7, §8, pełne uzasadnienia). Decyzje żyją w kartach specyfikacji (D-03 już tak mówi), plan je tylko wylicza. Przy okazji usunąć wszystkie zdania o „limicie 1 gałęzi” poza D-33.
- **Koszt.** S–M (jeden przebieg dokumentacji). **Ryzyko.** Zgubienie uzasadnienia: dlatego archiwum, nie kasowanie. **Dotyka.** zasada „jeden plan” z pamięci projektu (zostaje: jeden plan, ale krótki).

### P12. Zadania narzędziowe idą terminalem, czyli poza strażnikiem i audytem
- **Dowód.** `WORKFLOW.md` krok 4: „Zadania narzędziowe z `/praca/nowe` wdrażamy na razie w terminalu”; INSTRUKCJA §4 krok 4: „zadania narzędziowe tylko w terminalu: strona zadania podaje wtedy polecenie »Wdróż w terminalu«”; plan „Gdzie jesteśmy”: task_20–22 „wdrażamy w terminalu, po kolei”. Terminal ma tylko `.claude/settings.json` (`allow: git:*`, `node:*`), bez strażnika i audytu (task_22 ma to zawęzić).
- **Skutek.** Najwięcej zadań z ostatnich dni (task_15, 19, 20–24) to narzędzia; każde wymaga sesji z orkiestratorem w czacie (droższy kontekst, uwaga Rolanda przez cały czas trwania) i nie zostawia `run.json`, kosztu ani audytu.
- **Propozycja.** Dopuścić `Rodzaj: narzędzia` w przebiegu „Wdróż na gałęzi” z profilem „narzędzia”: te same kopie gałęzi, bez arkusza (P3), testy po stronie serwera (P5); dla zadań dashboardu kopia gałęzi specyfikacji (`specification-wt/<gałąź>`), jak dziś `specification-t24`. Terminal zostaje dla pracy, która zmienia sam dashboard w trakcie jego działania.
- **Koszt.** M. **Ryzyko.** Przebieg zmieniający `runguard.ts` pod strażnikiem z `runguard.ts`; dlatego zadania dashboardu w osobnej kopii i bez przeładowania serwera w trakcie. **Dotyka.** WORKFLOW krok 4, INSTRUKCJA §4.

### P13. Karty decyzji rozstrzygane pojedynczo, a analizy w trójkę
- **Dowód.** Trzy analizy 20/21/22 skończyły się trzema kartami (`zgloszenia/2026-10-27_task20-pomiar.md`, `…task21-…`, `…task22-…`); każda rozstrzygana osobno (commit karty z pushem każdorazowo, INSTRUKCJA §5) i osobno wznowiona (trzy przebiegi o 16:22–16:24).
- **Skutek.** D-33 daje równoległość modelom, ale nie Rolandowi.
- **Propozycja.** Ekran „Do rozstrzygnięcia” z wszystkimi otwartymi kartami, „Przyjmij rekomendacje” dla wszystkich, jeden commit, a kolejka z task_24 wznawia wszystkie zależne zadania. Karta rekomendacji „pewnej” (analiza zaznacza `rekomendacja: pewna`) mogłaby wchodzić bez pytania po oknie weta, jak reguła odwracalna z §3 pkt 3; to już jest zasada planu, tylko dashboard jej nie zna.
- **Koszt.** S–M. **Ryzyko.** Przyjęcie rekomendacji bez czytania; dlatego domyślnie zaznaczone, ale widoczne. **Dotyka.** §3 pkt 3, INSTRUKCJA §5.

### P14. Nikt nie liczy czasu człowieka ani kosztu na zadanie
- **Dowód.** `run.json` ma koszt przebiegu, Przebiegi pokazują koszt (task_19 „koszt i czytelny dziennik przebiegów”), ale nic nie sumuje kosztu na zadanie ani nie pokazuje przerw między przebiegami; arkusze mają tylko „Łączny czas gry”.
- **Propozycja.** Na stronie zadania: „Koszt: 2,51 USD w 5 przebiegach · czas modelu 11 min · czekało na Ciebie 3 h 10 min” (z `startedAt`/`endedAt` sąsiednich przebiegów tego zadania). W Pracy: suma dnia i tygodnia. To daje Rolandowi miarę, czy zmiany z tego audytu działają.
- **Koszt.** S. **Dotyka.** `src/work/runs.ts`, `views/WorkItem.tsx`.

### P15. Te same reguły przebiegu w czterech miejscach
- **Dowód.** Reguły „nie commituj w głównej kopii, `git -C` z pełną ścieżką, bez `git -c`/`bash -c`/`eval`/`node -e`, ledger tylko przez `cli.ts`, strefy człowieka” stoją w: `CLAUDE.md` „Hard rules” i „Dashboard lock”, `ai-task/SKILL.md` „Dashboard runs”, `spec-tasks/SKILL.md` i `spec-sync/SKILL.md` „Dashboard runs”, kontrakcie (`contract.md` „Zasady”) i w ARCHITEKTURA §13. Każda zmiana (np. task_23: `cli.ts commit`) musiała być wpisana we wszystkie (commit `db3b7a7`, `9484ffe`).
- **Skutek.** Rozjazdy jak w P6; kontekst przebiegu rośnie; każda zmiana procesu to przebieg dokumentacji za kilka dolarów.
- **Propozycja.** Jeden plik `docs/agent/run-rules.md` (reguły przebiegu, 1 strona) dołączany przez serwer do kontraktu zamiast przepisywania; skille i `CLAUDE.md` mają po jednym zdaniu z odsyłaczem. Strażnik czyta tę samą listę poleceń, którą pokazuje model (dane w JSON, z którego generowany jest i tekst reguł, i polityka strażnika; `runguard.ts` ma 3 222 linie, więc wydzielenie danych z silnika jest i tak potrzebne).
- **Koszt.** M. **Ryzyko.** Przebieg, który nie przeczyta dołączonego pliku; kontrakt jest w prompcie, więc czyta. **Dotyka.** `CLAUDE.md`, trzy skille, `runs.ts`, `runguard.ts`.

### P16. Wydanie jest osobnym, ręcznym krokiem bez miejsca w dashboardzie
- **Dowód.** `tools/README.md` „Wydanie”: sześć kroków w terminalu; `WDROZENIA.md` ostatni wiersz: „Wersji ani tagu nie wydano (tag `v0.5.3` zostaje najnowszy)”, choć `git tag` pokazuje już `v0.5.4` i `CHANGELOG.md` ma 0.5.4 (commit `c82a4dd`). Założenie: wydanie 0.5.4 zrobiono w terminalu po wpisie ledgera i ledger nie został uzupełniony.
- **Skutek.** Trzy źródła prawdy o wersji (tag, CHANGELOG, ledger) rozjeżdżają się po jednym dniu; task_22 planuje `release.sh`, ale nadal poza dashboardem.
- **Propozycja.** Przycisk „Wydanie x.y.z” w Pracy (serwer, bez modelu): `stamp_build.js --check`, stempel, import, eksport, zip, commit, tag, push, wpis w ledgerze przez `cli.ts ledger` (nowa operacja `release`), wszystko w tymczasowej kopii jak build do ogrania. Wpis CHANGELOG pisze model w domknięciu (jedyna część, która wymaga słów).
- **Koszt.** M (po `release.sh` z task_22: serwer tylko go woła). **Dotyka.** reguła tagów i pushy (§9; przycisk działa w imieniu Rolanda, jak „Scal”).

## 3. Co z tego jest łatwe (ten tydzień)

| ID | Co | Zysk | Koszt |
|---|---|---|---|
| P2(1) | „Wznów” jako świeży krótki przebieg zamiast wznowienia sesji | −1,5…3 USD na każdą kartę | S |
| P4 | Blokada powtórnego przeglądu tego samego commita | −0,6 USD i klik na zadanie | S |
| P6 | Spójne komunikaty strażnika + folder `tmp/` przebiegu | mniej straconych tur, mniej „blad” | S |
| P7(2,3) | Wtyczki użytkownika poza przebiegiem, krótszy skill `ai-task` | −2…4 tys. tokenów na przebieg | S |
| P9 | Jedna tabela modeli; Haiku dla domknięcia | jasność; −0,15 USD na domknięcie | S |
| P10 | Lint pokrycia reguł → `reports/rule-coverage.json`; poprawka §8.1 | pierwsza miara spec↔kod; dane dla grafu | S |
| P14 | Koszt i czas oczekiwania na stronie zadania | miara dla kolejnych zmian | S |
| P11 | Krótki `plan.md` + archiwum historii | −15 tys. tokenów na przebieg, koniec sprzeczności o limit gałęzi | S–M |

## 4. Co długoterminowo (kolejność)

1. **Łańcuch zamiast kliknięć** (P1, P13) po task_24: jeden przycisk „Zrób zadanie do przeglądu”, przerwa tylko na kartę, czerwony test, werdykt „poprawki” albo konflikt.
2. **Testy i wydanie po stronie serwera** (P5, P16): fakty o testach pochodzą z serwera, nie z modelu; D-35 opiera się na nich.
3. **Poziomy zadań i arkusz na build** (P3): Roland gra raz na build, a nie raz na zadanie; zadania tekstowe i narzędziowe bez arkusza.
4. **Jedne reguły przebiegu** (P15) i dane strażnika oddzielone od silnika.
5. **Zadania narzędziowe w dashboardzie** (P12).

## 5. Czego przestać robić

- Wznawiać sesje analiz po ponad godzinie (P2).
- Klikać przegląd, gdy gałąź się nie zmieniła (P4): niech dashboard sam odmówi.
- Pisać te same reguły w czterech miejscach (P15).
- Pełny zestaw testów w przebiegu modelu (P5): niech robi to serwer.
- Wymagać arkusza od zmiany dwóch zdań (P3).
- Trzymać historię planu w pliku, który czyta każdy przebieg (P11).

## Źródła

- `everhorror/reports/dashboard-runs/*/run.json`, `events.jsonl` (zdarzenia `result`: `total_cost_usd`, `num_turns`, `modelUsage`; pierwsza odpowiedź: `usage`), `contract.md`, `guard.log`, `policy.json` (18 przebiegów 2026-10-27).
- `everhorror/build/do-ogrania/*.json` (manifesty buildów), `everhorror/reports/full_suite_3.txt`.
- `specification/WORKFLOW.md`, `dashboard/INSTRUKCJA.md` §4–5, `WDROZENIA.md`, `zgloszenia/`.
- `everhorror/CLAUDE.md`, `.claude/skills/{ai-task,spec-tasks,spec-sync}/SKILL.md`, `.claude/settings.json`, `docs/analizy/final-plan-human-readable.md` (§3, §5, §8.1, §9 D-16…D-35), `docs/ai-tasks/task_18…24.md`, `docs/human-tasks/done/factcheck-test-14.md`, `factcheck-test-17.md`.
- `git log` obu repozytoriów (2026-10-27: 43 commity gry, 163 specyfikacji, w większości kod dashboardu z task_19/23).
