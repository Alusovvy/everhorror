# task_38: Jeden arkusz i jeden build na cykl oceny, rejestr buildów

<!--
Zadanie narzędziowe z czatu Rolanda (2026-10-28, sesja koordynatora Fable 5.1). Sekcja „Wymagania” to słowa Rolanda i potwierdzone przez niego streszczenie; nie edytować. Zasady: INFO.md.
-->

Wymagania:
Roland, czat 2026-10-28 (dosłownie):
„I want a change to be made that factchecks are appended so I only have one factcheck sheet to review and builds are also appended when tasks are being made. Then when I give feedback from factcheck from which we will build new tasks, you put existing build as old one, and start tasks as for the new build, including fixes or new features or changes, doesn't matter, new build is made when factcheck is done and feedback retuern.”

Streszczenie koordynatora potwierdzone przez Rolanda („Dobra, to jedziesz.”):
1. Arkusz factcheck jest jeden, wspólny: każde wdrażane zadanie dopisuje swoją część na końcu tego samego otwartego arkusza; do oddania wyników Roland ma do przejrzenia dokładnie jeden plik.
2. Build też jest jeden, wspólny: kolejne scalone zadania nie dostają osobnych buildów; jest jeden bieżący build, który obejmuje wszystko od ostatniej oceny Rolanda, i na nim sprawdza się cały wspólny arkusz.
3. Ocena Rolanda zamyka cykl: po wypełnieniu arkusza i oddaniu wyników (❌, 💬, nowe prośby) z tego feedbacku powstają nowe zadania: poprawki, zmiany, nowe funkcje, bez znaczenia jakiego rodzaju.
4. Przełączenie na nowy cykl: dotychczasowy build i jego arkusz stają się „stare” (zamknięte, zostają jako historia), a nowe zadania są od razu przypisane do następnego buildu i następnego wspólnego arkusza.
5. Nowy build powstaje dopiero wtedy, gdy poprzedni factcheck jest skończony, feedback wrócił, a zadania z tego feedbacku są wdrożone i scalone; wtedy dashboard robi jeden nowy build, otwiera jeden nowy arkusz z częściami wszystkich tych zadań i cykl zaczyna się od nowa.
Założenia przyjęte przez koordynatora (Roland nie zaprzeczył): (a) zadania poziomu „tekst” i „narzędzia” nadal nie dodają wierszy do arkusza, ale wchodzą do wspólnego buildu; (b) scalanie zadania do `master` zostaje jak dziś (przegląd + testy), tylko build i arkusz przestają być „na zadanie”, a stają się „na cykl”.

Roland, czat 2026-10-28 (dosłownie, uzupełnienie):
„Tak, warto tez trzymać .md file ktory bedzie miał numery buildów z ich tymi hasszhami czy co to tam jest za kod w rogu, i liste zmian/tasków ktore weszly. Dobra, to jedziesz.”

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-28)
Poziom: narzędzia

Kontekst:
Dziś arkusz i build są „na zadanie” (D-27 dopuszcza dopisywanie części do otwartego arkusza, D-32 wiąże arkusz z buildem gałęzi). Po dzisiejszych scaleniach (task_20, 22, 25, 37) Roland ma trzy arkusze (`factcheck-build-333b147`, `-b250ebb`, `-368ac18`) i kilka buildów, a część wierszy sprawdził na buildzie, który nie zawierał zmiany. Kod w rogu menu to `BuildInfo.label()` („wersja · spec sha7”), a nazwa ZIP-a niesie sha7 commita gry.

Kryteria akceptacji:
1. W danym momencie istnieje najwyżej jeden otwarty arkusz factcheck; wdrożenia dopisują do niego części (także te uruchamiane z dashboardu), zamiast zakładać nowe pliki.
2. Build do ogrania jest jeden na cykl: powstaje z `master` po scaleniu zadań cyklu, a nie po każdym zadaniu; dashboard i arkusz wskazują ten sam, bieżący build.
3. Oddanie wyników arkusza przez Rolanda zamyka cykl: arkusz i build dostają status „stary” (historia), a zadania z feedbacku (poprawki, zmiany, nowe funkcje) są przypisane do następnego cyklu; następny build i następny arkusz powstają po ich scaleniu.
4. Plik `.md` w repozytorium gry z rejestrem buildów: numer buildu, kod z rogu menu (wersja · spec sha7) i sha7 gry, data, lista zadań i zmian, które weszły, stan (bieżący / stary) i link do arkusza; dashboard uzupełnia go sam.
5. Dokumentacja i skille (`docs/human-tasks/INFO.md`, `docs/ai-tasks/INFO.md`, `.claude/skills/ai-task`, `spec-sync`, dashboard `INSTRUKCJA.md`, plan §9: nowa decyzja) opisują cykl zamiast „arkusz na build zadania”.

Priorytet: wysoki

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza

Analiza: Opus 5.5 (agent planujący koordynatora Fable 5.1), 2026-10-28. Kod i dokumenty czytane w stanie: gra `master` 5249209, dashboard w `master` specyfikacji.

### Jak to działa dziś

**Arkusz „na build zadania” (D-27, D-36).**
- Przebieg wdrożenia zadania `rozgrywka` sam pisze arkusz w głównej kopii: dopisuje część `## Część: task_NN` na końcu otwartego arkusza, którego nikt jeszcze nie zaczął wypełniać, a gdy takiego nie ma, zakłada `factcheck-build-<sha7>.md`, gdzie `<sha7>` to głowa **gałęzi** tego zadania (`.claude/skills/ai-task/SKILL.md` krok 6, w. 40; `docs/human-tasks/INFO.md` „Poziomy zadań i arkusz na build”, „Arkusz kilku zadań”; kontrakt w `dashboard/src/work/runs.ts:1040`). Arkusz, w którym człowiek coś wpisał, już nie rośnie, więc następne zadanie zakłada nowy plik.
- Dashboard wybiera „arkusz, który może rosnąć” (`growableSheet()`, `derive.ts:218`) i dopisuje go do zakresu plików wdrożenia (`derive.ts:1086-1090`). Skutek uboczny: dwa wdrożenia `rozgrywka` naraz mają wspólny plik w zakresie, więc kolejka uznaje je za nakładające się i puszcza po kolei.
- Linię `> Build: <sha7> (<zip>)` wpisuje serwer przy zapisie, zwolnieniu i zamknięciu (`workspace.ts:1455` `saveSheet`, `1515` `waiveSheet`, `1650` `closeSheet`; `sheets.ts:1071` `setBuildLine`). Build wybiera człowiek z listy buildów zadań arkusza (`SheetForm.tsx:898-901`, `playbuild.ts:284` `buildsOfSheet`). Linia jest strefą serwera (`sheets.ts:44` `HUMAN_META_KEYS`).
- Zamknięcie to jedno kliknięcie Rolanda: `git mv` do `done/`, puste pola dostają ⏭ (D-28), linki w plikach zadań idą za plikiem, wszystko w jednym commicie (`workspace.ts:1650-1726`). Zadania z `> Zadania:` zamykają się razem z arkuszem (`derive.ts:642-672`).

**Build „na gałąź” (D-32).**
- Po udanym wdrożeniu i po poprawkach serwer uruchamia testy, a potem eksportuje głowę **gałęzi** (`node/postrun.ts:84-89` → `PlayBuildManager.afterRun`). ZIP: `Everhorror-test-task<NN>-<sha7>-windows.zip`, zostają dwa najnowsze na zadanie (`src/work/playbuild.ts:24`, `314`). Build `master` robi się tylko ręcznie (`derive.ts:1375-1392`, `cli.ts build master`).
- Arkusz, w którym nikt nic nie wpisał, czeka, aż któreś z jego zadań ma aktualny build swojej gałęzi (`playbuild.ts:261` `playBuildCheck`, `301` `sheetPlayable`, `derive.ts:896-920` `sheetPlay`). Zadanie scalone nie czeka na nic, więc arkusz scalonego zadania można wypełnić na dowolnym buildzie z listy.
- Krok „Zbuduj do ogrania” gałęzi stoi w „Czeka na Ciebie” (`derive.ts:1228-1246`, `1890-1893`).

**Scalanie automatyczne (D-35, D-36 pkt 2).** `autoMergeCheck()` (`src/work/automerge.ts:194`) wymaga dla `rozgrywka`: aktualnego udanego builda gałęzi (`automerge.ts:258-263`, kod `build`), części zadania w arkuszu wypełnionej bez ❌, linii `Build` równej głowie gałęzi (`sheetNoBuild`, `sheetBuildStale`, `automerge.ts:272-313`) i podpisu osoby z „Wyniki człowieka” (`signer`). Dla `tekst` i `narzędzia` arkusz odpada, a podpisuje osoba, która uruchomiła ostatni przebieg kodu. Przy ręcznym scaleniu `rozgrywka` bez arkusza widok ostrzega (`derive.ts:1193`, `status.warn.sheetIncomplete`).

**Limit „2 buildy do ogrania” (plan §3 pkt 5).** `LIMITS.awaitingPlay = 2` (`derive.ts:88`); licznik to zadania „Czeka na człowieka” plus zadania `rozgrywka` na gałęzi lub scalone bez zagranego arkusza (`derive.ts:1591`). Przy limicie wdrożenie dostaje tylko ostrzeżenie (`derive.ts:1036`, `parallelplan.ts:315`), a tablica pokazuje licznik (`board.ts:282`).

**Łańcuch.** Po przeglądzie czeka na scalenie z opisem „czeka na arkusz i scalenie” (`src/work/chain.ts:522`, `node/chain.ts:83`). Po scaleniu uruchamia domknięcie i się kończy.

**Domknięcie i księga.** `/spec-sync finalize` dopisuje wiersz „Wpisy” (bez kolumny arkusza, arkusz bywa tylko w „Uwagach”) i wpis w `CHANGELOG.md` → „Nieopublikowane”, arkuszy nie rusza (`.claude/skills/spec-sync/SKILL.md` w. 35-47). Wiersz „Na gałęziach” ma kolumnę „Factcheck” (`--sheet`, `src/spec/ledgerOps.ts:177-181`).

**Kod w rogu menu.** `BuildInfo.label()` = „wersja · spec sha7” (`script/build_info.gd`). `SPEC_SHA` stempluje tylko wydanie (`tools/release/stamp_build.js`), a build do ogrania nie stempluje (ARCHITEKTURA §13 „Build do ogrania”). Każdy build od wydania 0.5.4 pokazuje więc w rogu ten sam napis „0.5.4 · spec 3f76c0f”. Build odróżnia tylko nazwa ZIP-a (sha7 commita gry) i kartka `BUILD_DO_OGRANIA.txt`. Format napisu pilnuje test `tools/unit_test.gd:413` i reguła UI-6 ✅ (`05_interfejs.md`).

### Co psuje Rolandowi pracę (stan 2026-10-28)
- **Trzy otwarte arkusze naraz:** `factcheck-build-333b147` (task_22, task_25), `-b250ebb` (task_37), `-368ac18` (task_20), a wszystkie cztery zadania są już scalone i domknięte.
- **Wiersze sprawdzone na złym buildzie.** W arkuszu 333b147 Roland wpisał ✅ w wierszach 1-6 części task_22, ale linia `> Build: f1e6f37` to build gałęzi task_25, w którym task_22 nie było (wiersz „Wpisy” task_22: „do powtórki na nowym buildzie”). Automat odnotował to jako `sheetBuildStale` (`reports/dashboard-runs/automation.jsonl`, `auto-merge-skip` task_22).
- **Buildy rozsiane po gałęziach.** `build/do-ogrania/` ma buildy task17, task25, task37 (nieudany: test eksportu) i dwa buildy master (f1cfb0c, 0c0df0f). Build 0c0df0f (ręczny, 15:33) zawiera wszystkie cztery zadania, ale żaden arkusz go nie wskazuje.
- **Nie ma rejestru.** Nie widać, który build był oceniany, co w nim było i czy jest jeszcze bieżący. Kod w rogu menu tego nie mówi, bo między wydaniami się nie zmienia.
- **Kierunek procesu jest odwrotny do słów Rolanda.** Dziś najpierw jest arkusz na gałęzi, a scalenie potem. Roland chce najpierw scalić wszystko z cyklu, potem zbudować jeden build `master`, a na końcu ocenić całość.

### Ryzyka i co zmiana dotyka
1. **Scalanie automatyczne `rozgrywka` (D-35).** Dziś scalenie czeka na arkusz zadania. W cyklu arkusz powstaje dopiero po scaleniu wszystkich zadań cyklu, więc warunek „arkusz bez ❌” przed scaleniem nie może zostać. Ocena przenosi się na koniec cyklu: ❌ i 💬 stają się nowymi zadaniami następnego cyklu, a nie bramką scalenia. Ta zmiana idzie wbrew słowom Rolanda z D-35 („Po grze i arkuszu”, czat 2026-10-27). Nowsze słowa (2026-10-28, założenie b) wygrywają; nazywa to nowa decyzja D-38. Skutek: do `master` trafia niezagrana rozgrywka. `master` nie jest wydaniem, a karta „Wydanie” dostaje ostrzeżenie, póki cykl nie jest oceniony.
2. **Dowód, że gra się eksportuje.** Build gałęzi był też dowodem, że eksport działa (task_37: build nieudany na teście eksportu). Bez buildów gałęzi trzeba ten fakt dostać inaczej, inaczej zepsuty eksport wyjdzie dopiero przy buildzie cyklu. Rozwiązanie: scenariusz `export` w testach serwera dla poziomów `tekst` i `rozgrywka`.
3. **Kiedy budować.** Zbyt wcześnie: build bez zadania, które zaraz będzie scalone. Zbyt późno: zatrzymany łańcuch albo zapomniane domknięcie trzyma cykl bez końca. Warunki muszą być jawne, widoczne na ekranie (jak powody scalania automatycznego), z przyciskiem „Zbuduj teraz”.
4. **Kontrakt przebiegu i skille.** Tekst o arkuszu stoi w `runs.ts:827` (korzenie zapisu), `runs.ts:1040` (wdrożenie), `runs.ts:1043` (poprawki), `runs.ts:1300` (reguła edycji `docs/human-tasks/**`), w strażniku (`node/runguard.ts:1055`, `1074`), w `docs/agent/run-rules.md` w. 12, 17, 38, w skillu `ai-task` krok 6, w `spec-sync`, w `CLAUDE.md` („Flow”) i w obu `INFO.md`. Jedno przeoczone miejsce znaczy agenta, który dalej dopisuje części do arkusza; strażnik musi to zablokować, a nie tylko dokument zabronić.
5. **Testy serwera i e2e.** Zmiana dotyka `automerge.test.ts`, `derive*.test.ts`, `runs*.test.ts`, `playbuild*.test.ts`, `postrun.test.ts`, `runguard.test.ts` i trzech e2e (`playbuild.e2e.ts` testuje „implement → build gałęzi → arkusz czeka”, czyli dokładnie to, co odpada). CI dashboardu uruchamia `npm run e2e` (`node/e2e/**/*.e2e.ts`), więc nowy e2e wchodzi do CI sam.
6. **Migracja trzech arkuszy.** Zamknięcie arkusza to czynność człowieka (CLAUDE.md, human-tasks INFO). Migracja nie może więc być krokiem agenta: to jedno kliknięcie Rolanda, które serwer wykonuje w jego imieniu.
7. **Co to jest „oddanie wyników”.** Mechanicznie to musi być jedno zdarzenie. Kompletny arkusz nie wystarczy, bo Roland może jeszcze dopisywać „Uwagi ogólne”. Zdarzeniem jest kliknięcie „Zamknij arkusz” (dziś `closeSheet`, z ⏭ dla pustych pól).
8. **Limit `awaitingPlay`.** Przy jednym buildzie na cykl „2 buildy czekają na zagranie” nie ma już sensu: do zagrania jest zawsze najwyżej jeden build cyklu. Ostrzeżenie przy wdrożeniu też odpada, bo wdrażanie w czasie gry jest dozwolone (zadanie wchodzi do następnego cyklu).
9. **Zapis serwera w głównej kopii.** Build cyklu commituje arkusz i rejestr w `master` gry. Brudna kopia główna albo trwające scalanie musi wstrzymać zapis, ale nie może zgubić builda: build robi się na nowo dopiero przy następnej próbie.
10. **Kod w rogu.** Nie da się go zmienić bez zmiany reguły UI-6 ✅ (specyfikacja jest Rolanda, test `unit_test.gd:413` pilnuje formatu). Rejestr zapisze napis taki, jaki jest, i powie wprost, że między wydaniami się nie zmienia.

## Plan

Cel: **cykl oceny** = jeden build `master` + jeden arkusz. Do zagrania jest zawsze najwyżej jeden cykl. Cykl jest zrozumiały z dwóch plików Markdown: rejestru `docs/human-tasks/BUILDY.md` i arkusza `docs/human-tasks/factcheck-cykl-NN.md`. Dashboard tylko automatyzuje, a każdy jego krok ma linię w dzienniku automatyki. Roland tylko wypełnia arkusz i klika „Zamknij”. Bez nowych zależności. Wdrożenie w terminalu (zmiany w `dashboard/` i `.claude/`; ai-tasks INFO „Dashboard”), jeden wykonawca Sonnet high, przegląd Opus.

**Stany cyklu** (z plików, nie z bazy):
- `zbiera`: numer = ostatni numer w rejestrze + 1; cyklu nie ma jeszcze w rejestrze. Należy do niego wszystko, co trafiło do `master` gry po commicie builda poprzedniego cyklu. W danej chwili zbiera dokładnie jeden cykl.
- `do zagrania`: wiersz rejestru ma stan `bieżący`, arkusz leży w `docs/human-tasks/`. Najwyżej jeden.
- `stary`: wiersz ma stan `stary`, arkusz leży w `docs/human-tasks/done/`.

### A. Model danych (czysty moduł `dashboard/src/work/cycles.ts`)
1. **Rejestr `docs/human-tasks/BUILDY.md`** (po polsku, w głównej kopii gry, pisze go tylko serwer). Zawartość:
   - nagłówek z dwoma liniami `>`. Pierwsza: „Prowadzi go dashboard: wiersz przy buildzie cyklu, stan przy zamknięciu arkusza; nie edytuj ręcznie; zasady: INFO.md#cykl-oceny”. Druga: „Kod w rogu menu (`BuildInfo.label()`, „wersja · spec sha7”) jest taki sam we wszystkich buildach od ostatniego wydania; build rozpoznasz po numerze cyklu i skrócie commita gry w nazwie ZIP-a”;
   - tabela `| Cykl | Stan | Build (commit gry) | Kod w rogu menu | Zbudowano | ZIP | Zadania i zmiany | Arkusz | Wynik oceny | Z oceny powstały |`, jeden wiersz na cykl, najnowszy na dole;
   - stopka „Cykl N+1 zbiera zadania scalone do `master` gry po commicie `<sha7>`”.

   Kolumny: `Stan` = `bieżący` albo `stary`. `Kod w rogu menu` liczy serwer z commita builda (`git show <sha>:project.godot` → `config/version` i `git show <sha>:script/build_info.gd` → `SPEC_SHA`, w formacie `BuildInfo.label()`). `Zadania i zmiany`: link do zadania, tytuł, ID reguł z wiersza „Wpisy” (np. `[task_37](../ai-tasks/done/task_37.md) otwarcie na trzy dni (OTW-1…OTW-10)`), plus „inne commity: N”. `Wynik oceny` = „✅ a · ❌ b · 💬 c · ⏭ d, zamknął <kto> <data>”. `Z oceny powstały` = zadania z planowania po zamknięciu (krok 13). Funkcje: `parseRegister(text)` (tolerancyjny parser: nieznane kolumny i wiersze dopisane ręcznie trafiają do problemów, nie wywracają widoku), `registerWithRow(text, row)` i `registerWithClose(text, n, result)`, które zmieniają tylko wiersz swojego cyklu.
2. **Arkusz cyklu `docs/human-tasks/factcheck-cykl-NN.md`** (NN dwucyfrowe, parser przyjmuje `\d{2,}`). Nazwa po numerze cyklu, nie po sha, bo numer jest kluczem rejestru i łatwiej go zapamiętać, a sha stoi w nagłówku.
   - Arkusz **powstaje razem z buildem**, więc nigdy nie istnieje bez builda (D-32 spełnia się sam) i nigdy nie rośnie po utworzeniu.
   - Nagłówek:
     ```
     # Cykl NN: arkusz do ogrania
     > Cykl: NN · Przygotowano: RRRR-MM-DD · Kod w rogu menu: 0.5.4 · spec 3f76c0f
     > Zadania: [task_41](../ai-tasks/done/task_41.md), …
     > W buildzie bez części (poziomy tekst i narzędzia): task_40, …
     > Build: <sha7> (Everhorror-cykl-NN-<sha7>-windows.zip)
     > (zdanie o kolumnach „wynik” i „uwagi” z szablonu)
     ```
   - Linię `Build` pisze serwer **przy tworzeniu** i jest dalej chroniona (`HUMAN_META_KEYS`). Linia `Zadania` wymienia tylko zadania z częścią, więc `pickSheet` (`derive.ts:601`) nie przypnie arkusza zadaniom `tekst` i `narzędzia`.
   - Dalej: „Raport przebiegu: dołącz plik” (zawsze, bo gra zapisuje raport od 0.5.3), „Uwagi ogólne (wypełnia człowiek)”, a na końcu części `## Część: task_NN — <tytuł>` w kolejności scalenia do `master`.
   - Szkielet bierze serwer z nowego szablonu `docs/human-tasks/factcheck_cykl_template.md` (zastępuje `factcheck_build_template.md`, `git mv`). Gdy szablonu brak, wzorzec jest wbudowany w kod.
   - W `sheets.ts`: `cycleSheetPath(n)`, `cycleOfSheetPath(path)`, `isCycleSheet()`. `isGameSheetPath` (`sheets.ts:58`) wyklucza `buildy.md` (jak `info.md`). `Sheet.cycle` przychodzi z nazwy pliku.
3. **Część w pliku zadania, nie w arkuszu.** Wdrożenie `rozgrywka` pisze w **swoim pliku zadania** sekcję `## Część arkusza` z podsekcjami `### Co zostało dodane`, `### Test` (tabela `| # | co sprawdzić | jak | oczekiwany wynik |`, bez kolumn człowieka) i `### Wyniki automatu (agent)`. Poprawki uzupełniają tę sekcję, gdy zmieniają, co sprawdzić.
   - `assembleCycleSheet(skeleton, parts, meta)` przepisuje sekcję do arkusza. Tabelom bez kolumn człowieka dopisuje puste `wynik` i `uwagi`. Tabele, które już je mają (np. ankieta ze skalą 1-7 dla sesji gry), przepisuje z pustymi komórkami człowieka. Linki względne przestawia na `docs/human-tasks/`.
   - Zadanie `rozgrywka` bez sekcji dostaje część z jednym wierszem „Zagraj w zmianę z zadania (opis: link do raportu)” i trafia do ostrzeżenia w karcie cyklu.
   - `taskPartOf(taskText)` czyta sekcję i zwraca tytuł z nagłówka `# task_NN: …`.
4. **Fakty i widok.**
   - `WorkState.cycles` = tekst rejestru, lista pierwszorzędnych commitów `master` od commita builda ostatniego cyklu (`git log --first-parent --format=%H%x00%s%x00%b <sha>..master`; scalenia rozpoznaje temat „Scalenie spec/…-taskNN”) i ostatnie próby builda cyklu. Czyta je `buildWorkState` w `node/workspace.ts`.
   - `deriveCycles()` → `WorkView.cycle`: `{ current: { n, state, build, sheet, tasks, progress } | null, collecting: { n, tasks, inFlight }, history: [...], check: CycleBuildCheck, problems }`.
   - Przynależność zadania jest **liczona**: zadanie wymienione w wierszu rejestru należy do tego cyklu, a każde inne (scalone po ostatnim buildzie albo jeszcze otwarte) do cyklu, który zbiera. Pliki zadań nie dostają linii `Cykl:` (Decyzje, pkt 4).
   - Niespójności idą do problemów widoku, z akcją „Uzgodnij rejestr”: wiersz `bieżący` przy arkuszu w `done/`, dwa wiersze `bieżący`, arkusz cyklu bez wiersza.
5. **`cycleBuildCheck(view)`**: czysta funkcja, wspólna dla serwera i ekranu, tak jak `autoMergeCheck`. Zwraca wszystkie niespełnione warunki naraz, z kodami:
   - `off`: przełącznik, `EVERHORROR_PLAYBUILD_AUTO=0`;
   - `doZagrania`: poprzedni cykl nie jest zamknięty;
   - `brakZmian`: od ostatniego builda nie scalono zadania `tekst` ani `rozgrywka`. Same `narzędzia` nie budują same, przycisk działa;
   - `zOceny`: zadania z kolumny „Z oceny powstały” poprzedniego cyklu nie są jeszcze scalone i domknięte ani odrzucone;
   - `wToku`: jest zadanie na etapie „W pracy” albo „Na gałęzi”, niedokończony łańcuch (także zatrzymany), wdrożenie, poprawki albo planowanie w toku lub w kolejce. Ekran wymienia te zadania;
   - `domkniecie`: zadanie scalone, ale niedomknięte (etap „Scalone”);
   - `kopia`: główna kopia nie stoi na `master`, brudny rejestr albo plik arkusza, scalanie w toku;
   - `godot`, `trwa`: brak Godota albo inny build w toku;
   - `ponowienie`: nieudana próba na tym samym commicie `master` mniej niż 5 min temu.

### B. Serwer
6. **Wdrożenie i poprawki bez arkusza w `docs/human-tasks/`.**
   - Kontrakt (`runs.ts:1040`, `1043`, `827`) i `docs/agent/run-rules.md`: część arkusza pisze się w pliku zadania (krok 3), nigdy w `docs/human-tasks/`.
   - Kontrakt podaje numer cyklu, który zbiera, i ścieżkę jego arkusza. W `ledger set-branch` wdrożenie `rozgrywka` daje `--sheet docs/human-tasks/factcheck-cykl-NN.md`, a `tekst` i `narzędzia` dają `--sheet -`.
   - Strażnik (`runguard.ts:1055`, `1074`) i `settings.json` przebiegu (`runs.ts:1300`): wdrożenie i poprawki nie mają już prawa zapisu w `docs/human-tasks/**`, a `BUILDY.md` jest zablokowany dla każdego rodzaju przebiegu (komunikat: „rejestr buildów prowadzi serwer”).
   - Z `derive.ts` znikają `growableSheet` i dopisywanie arkusza do zakresu (`derive.ts:218`, `1086-1090`), więc wdrożenia `rozgrywka` przestają się nakładać przez wspólny plik.
7. **Po przebiegu bez builda gałęzi** (`node/postrun.ts:84-89`). Testy serwera zostają.
   - Dla poziomów `tekst` i `rozgrywka` `node/servertests.ts` dokłada scenariusz `export` (`tools/run_tests.sh export`: eksport i day1 + expedition z paczki). Dopisuje go do znanych scenariuszy, bo nie jest plikiem `test_*.gd`, i nie liczy go do limitu 6 nazwanych scenariuszy.
   - Ręczny build gałęzi zostaje jako „Zbuduj podgląd gałęzi” na stronie zadania: tylko do debugowania. Nie ma go w „Teraz”, nie jest proponowany na arkuszu i nie trafia do rejestru (manifest `purpose: "podglad"`).
8. **Build cyklu** (`node/cycles.ts`, nowy; `PlayBuildManager.start({ task: null, cycle: N })` w `node/playbuild.ts`).
   - Eksport głowy `master` jak dziś. Stem `Everhorror-cykl-NN-<sha7>-windows`; `playBuildStem`, `isPlayBuildStem` i `parseManifest` w `src/work/playbuild.ts` przyjmują pole `cycle`.
   - `BUILD_DO_OGRANIA.txt` (`playBuildNote`) mówi „Cykl NN, commit gry <sha7>, kod w rogu menu …, arkusz docs/human-tasks/factcheck-cykl-NN.md”.
   - Zostają ZIP-y dwóch ostatnich cykli; manifesty i dzienniki starszych też idą, bo historię trzyma rejestr.
   - Po udanym eksporcie serwer robi **jeden commit** w `master` gry, bez pushu, jak inne commity dokumentów serwera (push to dalej krok „Wypchnij grę”): nowy arkusz (krok 2) i wiersz rejestru `bieżący` (krok 1).
   - Temat commita: `docs: cykl NN — build <sha7> i arkusz do ogrania (dashboard)`, trailery `Cykl: NN`, `Build: <sha7>`. Podpis: osoba, która scaliła najnowsze zadanie cyklu (trailer `Scalenie:`); bez niej odmowa z kodem `signer`.
   - Commit trafia do dziennika commitów serwera, żeby audyt trwających przebiegów go nie przypisał agentom.
   - Nieudany eksport: nic się nie zapisuje, dziennik `cycle-build-failed` z błędem, „Czeka na Ciebie” pokazuje „Build cyklu NN nie wyszedł: …” z „Spróbuj ponownie”. Zepsuty eksport `master` to zadanie poprawki.
9. **Kiedy rusza.** `node/automation.ts` woła ocenę cyklu po tych samych zdarzeniach co scalanie automatyczne (koniec przebiegu, scalenie, zamknięcie arkusza, koniec builda, zegar 15 s). Gdy `cycleBuildCheck` nie ma powodów, build rusza sam.
   - Zmiana zestawu powodów to jedna linia `cycle-build-skip`; start to `cycle-build-start`, sukces to `cycle-build`.
   - Przełącznik „Build cyklu automatycznie” stoi obok przełącznika scalania (administrator, `automation.json` → `cycleBuild.enabled`, domyślnie włączony); `EVERHORROR_PLAYBUILD_AUTO=0` ma pierwszeństwo.
   - Przycisk **„Zbuduj build cyklu NN”** (administrator, `POST /work/cycle/build`): wymaga tylko `doZagrania`, `kopia`, `godot`, `trwa` i co najmniej jednego commitu od ostatniego builda. Okno wymienia, co zostanie poza buildem (np. „task_42 na gałęzi wejdzie do cyklu NN+1”).
   - W terminalu: `node dashboard/cli.ts cycle` (stan i powody) oraz `cycle build` (z tą samą odmową przy blokadzie przebiegu co `build`). `build master` zostaje jako build bez cyklu.
10. **Zamknięcie cyklu = „Zamknij arkusz” na arkuszu cyklu** (`closeSheet`, `workspace.ts:1650`), bez nowego zdarzenia. Ten sam commit:
    - przenosi arkusz do `done/` (⏭ w pustych polach, D-28, jak dziś);
    - zmienia wiersz rejestru na `stary`, przepina link na `done/factcheck-cykl-NN.md` i wpisuje „Wynik oceny” (liczby z `classifyResult` po wierszach części);
    - przenosi linki w plikach zadań.

    Okno ma tytuł „Oddaj wyniki i zamknij cykl NN”. Dziennik: `cycle-close`. Od tej chwili jedynym cyklem jest ten, który zbiera. Zwolnienie z testu też działa: cykl zamyka się wtedy jako „zwolniony”.
11. **Zapis wpisów na arkuszu cyklu** (`saveSheet`, `waiveSheet`) nie zmienia linii `Build`. Serwer odrzuca pole `build` dla arkusza cyklu, a lista wyboru builda zostaje tylko dla dawnych arkuszy.
12. **Scalanie automatyczne (`src/work/automerge.ts`).**
    - Punkt 6 (arkusz) znika dla wszystkich poziomów: zostaje tylko „❌ w części zadania w arkuszu, który człowiek zaczął, wstrzymuje” (`sheetProblems`). W cyklu zadanie na gałęzi nie ma jeszcze części w żadnym arkuszu, więc to dotyczy tylko dawnych arkuszy.
    - Kod `build` (`automerge.ts:258-263`) zastępuje `testsNoExport`: zielone testy serwera dla `tekst` i `rozgrywka` muszą zawierać scenariusz `export`.
    - Podpis dla każdego poziomu: osoba, która uruchomiła ostatni przebieg kodu (administrator).
    - Znikają kody `sheetNone`, `sheetEmpty`, `sheetOpen`, `sheetNoBuild`, `sheetBuildStale`, `sheetOther`, `sheetWaived`, `sheetClosedSkipping`, `sheetReplaced`, `sheetSkipped`, `sheetAgent`, `sheetBranchOnly` w ścieżce scalania; ich napisy usuwa się z katalogu.
    - Ostrzeżenie `status.warn.sheetIncomplete` przy ręcznym scalaniu (`derive.ts:1193`) zastępuje informacja „Ocena w arkuszu cyklu NN po buildzie”.
    - Wynik arkusza cyklu nie bramkuje scalenia. Bramkuje **następny build** (warunek `zOceny`, krok 5).
13. **Ocena → zadania następnego cyklu.**
    - Okno zamknięcia ma pole „Zaplanuj zadania z oceny (przebieg planowania)”. Jest zaznaczone, gdy arkusz ma ❌, 💬 albo tekst w „Uwagach ogólnych”. Zaznaczone dodaje do kolejki startów przebieg planowania (`/spec-tasks unattended`) z opcją `cycle: NN` i uwagą „Ocena cyklu NN: docs/human-tasks/done/factcheck-cykl-NN.md”; dziennik `cycle-plan`. Ten sam przycisk „Zaplanuj z oceny cyklu NN” stoi w karcie cyklu, póki planowania nie było.
    - Skill `spec-tasks` dostaje sekcję „Z oceny cyklu”:
      - ❌ przy zachowaniu, które opisuje reguła ✅: zgłoszenie `Rodzaj: błąd` z cytatem wiersza dosłownie („Roland, arkusz cyklu NN, task_NN #3: «…»”) i zadanie poprawki. Przywraca regułę, więc według D-23 nie potrzebuje ⬜.
      - 💬 albo uwaga o czymś nowym lub innym: najpierw specyfikacja. Reguła ⬜ z przypisaniem „Roland, arkusz cyklu NN (data): …” tylko wtedy, gdy prośba jest jednoznaczna; inaczej karta decyzji D-03 z klasą `odwracalna`, gdzie się da (D-37 może ją wtedy rozstrzygnąć). Zadanie powstaje z linią `Zgłoszenia:`.
      - Każde takie zadanie ma w „Kontekście” zdanie „Z oceny cyklu NN: …”.
    - Po czystym końcu tego przebiegu serwer w tym samym commicie dokumentów (`commitRunDocs`, `node/postrun.ts`) wpisuje w kolumnie „Z oceny powstały” wiersza NN zadania, które przebieg założył (`audit.introducedDocs`). Te zadania należą do cyklu, który zbiera (krok 4), a następny build czeka na ich scalenie (`zOceny`).
14. **Łańcuch.** Opis czekania `scalenie` zmienia się na „czeka na scalenie” (`node/chain.ts:83`, katalog `chain.*`); kroki bez zmian. Po domknięciu łańcuch się kończy, a dalej prowadzi go cykl.
15. **Domknięcie.** Kontrakt domknięcia podaje cykl zadania: wiersz rejestru, w którym zadanie jest, a gdy go nie ma, cykl, który zbiera. `/spec-sync finalize` pisze w „Uwagach” wiersza „Wpisy”: „cykl NN (arkusz factcheck-cykl-NN.md)”. Wpis w `CHANGELOG.md` → „Nieopublikowane” bez zmian.
16. **Limit `awaitingPlay`** (`derive.ts:88`, `1591`): `LIMITS.awaitingPlay = 1`, a licznik to liczba cykli `do zagrania`, więc 0 albo 1. Ostrzeżenie przy wdrożeniu (`derive.ts:1036`, `parallelplan.ts:315`) znika. Plan §3 pkt 5 dostaje brzmienie: „najwyżej jeden build do ogrania naraz: build cyklu; następny powstaje po zamknięciu arkusza i scaleniu zadań z oceny”.
17. **Etapy zadań** (`derive.ts:627-690`):
    - zadanie `rozgrywka` scalone i domknięte w cyklu, który zbiera: etap „Czeka na człowieka” z uwagą „wejdzie do buildu cyklu NN”;
    - w cyklu `do zagrania`: „Czeka na człowieka” przez arkusz cyklu, jak dziś;
    - po zamknięciu: „Sprawdzone” albo „Zamknięte”, jak dziś, z uwagą o ❌ w jego części i o zadaniach z oceny.

    Zadania `tekst` i `narzędzia` zamykają się po domknięciu jak dziś, a ich karta pokazuje „w buildzie cyklu NN”.
18. **Wydanie** (`src/work/release.ts`, `node/release.ts`): miękkie ostrzeżenie „Cykl NN nie jest oceniony (arkusz otwarty)” albo „Zmiany po buildzie cyklu NN nie były grane”. Wydania nie blokuje.

### C. Interfejs
19. **Teraz: karta „Cykl”** (`dashboard/src/views/CycleCard.tsx`, nad „Czeka na Ciebie” w `Work.tsx`). Zawartość:
    - numer i stan cyklu;
    - build: commit, ZIP, kod w rogu menu, „Otwórz folder”, ścieżka do skopiowania;
    - arkusz z postępem części;
    - zadania cyklu: scalone, a osobno „wejdą, gdy zostaną scalone” z etapem;
    - lista powodów, dla których build czeka (z `cycleBuildCheck`);
    - przyciski „Zbuduj build cyklu NN”, „Oddaj wyniki i zamknij cykl NN”, „Zaplanuj z oceny cyklu NN”, „Uzgodnij rejestr”, a przed migracją „Przenieś otwarte arkusze do cyklu 1” (krok 22);
    - link do `BUILDY.md` w podglądzie pliku.
20. **„Czeka na Ciebie”** (`derive.ts` lista `next`). Nowe kroki: „Zagraj w build cyklu NN i wypełnij arkusz” (`fill-sheet` arkusza cyklu), a przy komplecie „Zamknij cykl NN (oddaj wyniki)”. „Zbuduj build cyklu” pojawia się tylko, gdy automat jest wyłączony albo build się nie udał. Krok 5b „Zbuduj do ogrania” gałęzi znika (`derive.ts:1890-1893`). Dawne arkusze dalej mają swoje kroki, dopóki istnieją.
21. **Pozostałe ekrany.**
    - Tablica (`Board.tsx`, `board.ts:282`): znaczek „cykl NN” na karcie zadania; licznik kolumny „Czeka na człowieka” to „cykl NN do ogrania 1/1”.
    - Strona zadania (`WorkItem.tsx`, `PlayBuildBox` w `PlayBuild.tsx`): build cyklu z tym zadaniem albo „wejdzie do cyklu NN”; podgląd gałęzi osobno, z dopiskiem „nie do arkusza”.
    - Zadania: lista buildów (`PlayBuildList`) w trzech grupach: „Build bieżącego cyklu”, „Stare cykle” (z rejestru, z „ZIP usunięty”, gdy go nie ma), „Podglądy gałęzi”.
    - Automat (`Automation.tsx`): przełącznik „Build cyklu automatycznie” i nowe rodzaje wpisów w dzienniku.
    - Arkusz (`SheetForm.tsx:898-901`): na arkuszu cyklu zamiast listy „Build, w który grałeś” stała ramka „Build cyklu NN: <zip>” z „Otwórz folder”.
    - Wydanie (`Release.tsx`): ostrzeżenie z kroku 18.

### D. Migracja (jedno kliknięcie Rolanda, serwer w jego imieniu)
22. **„Przenieś otwarte arkusze do cyklu 1”** (`POST /work/cycle/migrate`, administrator; w terminalu `cli.ts cycle migrate --who Roland`). Działa, gdy nie ma rejestru, a w `docs/human-tasks/` leżą otwarte arkusze `factcheck-build-*` albo `factcheck-test-*`. Kroki:
    - (a) build cyklu 1 z głowy `master`. Zawiera task_20, 21, 22, 25 i 37 (sprawdza `git merge-base --is-ancestor` dla scaleń zadań z arkuszy) oraz zmiany z task_38;
    - (b) po udanym eksporcie **jeden commit** w imieniu Rolanda (trailery `Zamknięcie: Roland` i `Wpisał-Człowiek: Roland`, bo to jego czynność). W commicie:
      - nowy `BUILDY.md` z wierszem cyklu 1;
      - `factcheck-cykl-01.md` z częściami task_37, task_25, task_22 i task_20, przepisanymi z dawnych arkuszy dosłownie (tekst agenta), z **pustymi** komórkami człowieka: wpisy w 333b147 dotyczą buildu f1e6f37 bez task_22, więc nie są ważne, a reszta była pusta;
      - trzy dawne arkusze w `done/`, z ⏭ w pustych polach i linią `Zamknięcie: Roland (dashboard, <data>): przeniesione do arkusza cyklu 1 (factcheck-cykl-01.md), pominięte N z M pól`. Wpisy Rolanda zostają w nich jako historia;
      - przepięte linki w plikach zadań;
    - (c) dziennik `cycle-migrate`.

    Nieudany build niczego nie przenosi. Dawne ZIP-y w `build/do-ogrania/` zostają, póki nie usunie ich zwykłe sprzątanie, i nie trafiają do rejestru (nie były buildami cyklu).
23. Po migracji sesja wdrożenia (terminal, commit `[agent] proces`) poprawia tabelę „Historia” w `docs/ai-tasks/INFO.md`: kolumna „Arkusz” dla task_20, 22, 25 i 37 → `factcheck-cykl-01`. Uwagi w „Wpisy” `WDROZENIA.md` zostają jako historia.

### E. Dokumenty i skille (jedno brzmienie: „cykl oceny”)
24. Game:
    - `docs/human-tasks/INFO.md`: nowa sekcja „Cykl oceny” zamiast „Poziomy zadań i arkusz na build” i „Arkusz kilku zadań”, z tabelą poziomów (`rozgrywka`: część w arkuszu cyklu, scalenie po przeglądzie i testach serwera z testem eksportu; `tekst`: bez części, testy z eksportem; `narzędzia`: bez części, bez eksportu). Do tego „Nazwy arkuszy” (`factcheck-cykl-NN.md`, `BUILDY.md`; dawne nazwy jako historia), „Kto co pisze” (serwer: arkusz cyklu, linia `Build`, rejestr) i to, że zamknięcie arkusza cyklu zamyka cykl;
    - `factcheck_cykl_template.md` z komentarzem dla serwera;
    - `docs/ai-tasks/INFO.md` („Dashboard”, „Poziom, pliki i ryzyko”) i `docs/ai-tasks/task_template.md` (sekcja `## Część arkusza`);
    - `.claude/skills/ai-task/SKILL.md`: krok 6 (część w pliku zadania, bez D-27 „rośnie”, bez arkusza w `docs/human-tasks/`), „Spec tasks” (`--sheet` cyklu), „fix” (część aktualizuje się w pliku zadania; nowy build robi cykl, nie przebieg);
    - `.claude/skills/spec-sync/SKILL.md` (finalize: „Uwagi” z cyklem; nadal nigdy nie rusza arkusza ani rejestru);
    - `.claude/skills/spec-tasks/SKILL.md` (sekcja „Z oceny cyklu”, krok 13);
    - `docs/agent/run-rules.md` (korzenie zapisu, `> Build:` i `BUILDY.md` pisze serwer, brak builda po przebiegu);
    - `docs/agent/ai-task-terminal.md`;
    - `CLAUDE.md` („Flow”: część w pliku zadania, build cyklu z `master`, arkusz razem z buildem, D-38 zamiast D-32 w tej linii; „Branches”: D-35 bez arkusza);
    - `tools/README.md` („Build do ogrania”: build cyklu, podgląd gałęzi, `cli.ts cycle`).
25. Dashboard:
    - `ARCHITEKTURA.md` §13: nowa podsekcja „Cykl oceny (D-38)”, poprawione „Build do ogrania (D-32)”, „Scalenie automatyczne (D-35)” (punkty 4 i 6, ryzyko 2 o jednej linii `Build` znika), „Fakty z serwera” (scenariusz `export`, krok 4 bez builda), „Łańcuch”, „Profil narzędzia”, tabela modułów (`work/cycles.ts`, `node/cycles.ts`);
    - `INSTRUKCJA.md` §4 (kroki 4, 6, 7, 8: bez builda gałęzi i arkusza przed scaleniem, nowy krok „Build cyklu” i „Oceń cykl”) i §5 („Arkusz”, „Build, w który grałeś” tylko dla dawnych arkuszy, nowy akapit „Cykl i rejestr buildów”);
    - `UI.md` słowniczek (krok 28);
    - spec `WORKFLOW.md` (wiersz 5 tabeli i punkty o buildzie do ogrania).
26. `docs/analizy/plan.md`: nowe brzmienie „Gdzie jesteśmy” (dashboard), §3 pkt 5 i 6, nowa decyzja w tabeli §9:
    > | D-38 | **Cykl oceny**: jeden arkusz i jeden build na cykl. Wdrożenia `rozgrywka` piszą część w pliku zadania; zadania scalają się po przeglądzie i testach serwera (z testem eksportu; arkusz nie jest już warunkiem scalenia automatycznego, zmienia D-35 pkt 6); po scaleniu i domknięciu zadań cyklu serwer robi jeden build `master` i jeden arkusz `factcheck-cykl-NN.md` z częściami wszystkich tych zadań; zamknięcie arkusza przez Rolanda zamyka cykl (build i arkusz „stare”), a ❌, 💬 i uwagi stają się zadaniami następnego cyklu, którego build czeka na ich scalenie; rejestr `docs/human-tasks/BUILDY.md` (numer, kod w rogu menu, commit gry, data, zadania, stan, arkusz) prowadzi serwer; zastępuje D-27 i D-32 dla nowych arkuszy, limit „2 buildy do ogrania” → 1 cykl | Roland, czat 2026-10-28: „factchecks are appended so I only have one factcheck sheet … new build is made when factcheck is done and feedback retuern”; „trzymać .md file ktory bedzie miał numery buildów …” |

    Wpisy D-27, D-32 i D-35 w tabeli dostają dopisek „(dla nowych arkuszy zastąpione D-38)”.

### F. Testy (bez prawdziwego Godota i bez prawdziwego `claude`)
27. Przypadki:
    - **Jednostkowe** (`node --test`): `src/work/cycles.test.ts` (parser i zapis rejestru, także `|` w tytułach i wiersze dopisane ręcznie; stany, numeracja, niespójności; przynależność zadań; `cycleBuildCheck`: każdy kod osobno i kilka naraz; `assembleCycleSheet`: kolejność scalenia, nagłówek, linki, dopisane kolumny człowieka, zadania bez części, parser arkusza widzi części z pustymi strefami i `buildSha`; `registerWithClose`: liczby ✅/❌/💬/⏭);
    - `src/work/sheets.test.ts`: nazwy cyklu, `BUILDY.md` nie jest arkuszem;
    - `src/work/automerge.test.ts`: `rozgrywka` scala się bez arkusza, `testsNoExport`, podpis, ❌ w zaczętym dawnym arkuszu wstrzymuje;
    - `derive*.test.ts`: etapy w cyklu, kroki „Czeka na Ciebie”, `awaitingPlay` 0/1, brak `growSheet` w zakresie, brak kroku builda gałęzi;
    - `runs.test.ts` i `runs-playbuild.test.ts`: kontrakt bez `docs/human-tasks` dla wdrożenia, `--sheet` cyklu;
    - `src/work/servertests.test.ts`: `export` dla `tekst` i `rozgrywka`;
    - `chain.test.ts`: tekst czekania.
    - **Serwer:**
      - `node/cycles.test.ts`: build cyklu na udawanym `PlayBuildManager` → jeden commit z arkuszem i rejestrem, wpisy w dzienniku; nieudany eksport nic nie zapisuje; brudna kopia → `kopia`; ponowienie po 5 min; zamknięcie → wiersz `stary` w tym samym commicie co przeniesienie; migracja na fixturze z trzema dawnymi arkuszami (`node/fixtures/`);
      - `node/runguard.test.ts`: zapis do `docs/human-tasks/*` przy wdrożeniu i poprawkach zablokowany, `BUILDY.md` zablokowany wszędzie;
      - `node/postrun.test.ts`: brak builda po wdrożeniu, kolumna „Z oceny powstały” po planowaniu z `cycle`;
      - `node/playbuild.test.ts`: stem i manifest cyklu, sprzątanie dwóch ostatnich cykli;
      - `node/workspace-sheets.test.ts`: zapis bez linii `Build` na arkuszu cyklu.
    - **e2e:**
      - nowy `node/e2e/cycle.e2e.ts`: dwa wdrożenia (udawany agent pisze sekcje `## Część arkusza`) → w `docs/human-tasks/` nie powstaje żaden plik → przegląd „gotowe” i zielone testy (z `export`) → dwa scalenia automatyczne → dwa domknięcia → sam rusza build cyklu 1 (udawany Godot jak w `playbuild.e2e.ts`) → jeden arkusz z dwiema częściami i wiersz `bieżący` → zapis wpisów z ❌ → zamknięcie z planowaniem → wiersz `stary`, arkusz w `done/`, przebieg planowania w kolejce, widok mówi „cykl 2 zbiera”, a build cyklu 2 czeka z `zOceny`;
      - `playbuild.e2e.ts` przepisany na podgląd gałęzi i build `master`;
      - `work.e2e.ts` i `automation.e2e.ts` bez arkusza jako warunku scalenia.

      CI łapie nowy plik przez wzorzec `node/e2e/**/*.e2e.ts`.
    - **Na koniec:** `npm test`, `npm run e2e` i `node cli.ts lint` w `dashboard/`. W grze tylko `tools/check_doc_links.js` dla zmienionych dokumentów, bez Godota.

### G. Napisy (PL źródło, EN od razu; UI.md rozdz. 3)
28. Nowy katalog `src/i18n/messages/cycle.ts` (karta cyklu, powody `cycle.why.*`, akcje, dziennik `automation.event.cycle*`, okna zamknięcia i migracji, ostrzeżenie wydania) zarejestrowany w `catalog.ts`. Zmiany w `build.ts` (podgląd gałęzi, notka ZIP-a), `automation.ts` (nowe i usunięte `merge.why.*`, przełącznik), `chain.ts` (czekanie) i w katalogu arkusza (ramka builda cyklu).
    - Słowniczek `UI.md`: cykl oceny / review cycle; build cyklu / cycle build; arkusz cyklu / cycle sheet (zastępuje „arkusz builda”); rejestr buildów / build register; podgląd gałęzi / branch preview; część arkusza (teraz najpierw w pliku zadania); nowe brzmienie „build do ogrania” i „scalanie automatyczne”; „build, w który grałeś” tylko dla dawnych arkuszy.
    - Każdy nowy napis od razu z angielskim.

Plan zależy od wyboru: nie

Pliki: dashboard/src/work/cycles.ts, dashboard/src/work/cycles.test.ts, dashboard/src/work/sheets.ts, dashboard/src/work/sheets.test.ts, dashboard/src/work/derive.ts, dashboard/src/work/derive.test.ts, dashboard/src/work/derive-playbuild.test.ts, dashboard/src/work/derive-tiers.test.ts, dashboard/src/work/derive-automation.test.ts, dashboard/src/work/derive-chain.test.ts, dashboard/src/work/automerge.ts, dashboard/src/work/automerge.test.ts, dashboard/src/work/playbuild.ts, dashboard/src/work/playbuild.test.ts, dashboard/src/work/runs.ts, dashboard/src/work/runs.test.ts, dashboard/src/work/runs-playbuild.test.ts, dashboard/src/work/chain.ts, dashboard/src/work/chain.test.ts, dashboard/src/work/servertests.ts, dashboard/src/work/servertests.test.ts, dashboard/src/work/board.ts, dashboard/src/work/board.test.ts, dashboard/src/work/parallelplan.ts, dashboard/src/work/parallelplan.test.ts, dashboard/src/work/model.ts, dashboard/src/work/automation.ts, dashboard/src/work/release.ts, dashboard/src/work/release.test.ts, dashboard/node/cycles.ts, dashboard/node/cycles.test.ts, dashboard/node/fixtures/, dashboard/node/playbuild.ts, dashboard/node/playbuild.test.ts, dashboard/node/postrun.ts, dashboard/node/postrun.test.ts, dashboard/node/servertests.ts, dashboard/node/servertests.test.ts, dashboard/node/automation.ts, dashboard/node/automation-base.ts, dashboard/node/automation.test.ts, dashboard/node/automerge.ts, dashboard/node/chain.ts, dashboard/node/release.ts, dashboard/node/workspace.ts, dashboard/node/workspace-sheets.test.ts, dashboard/node/work-api.ts, dashboard/node/runguard.ts, dashboard/node/runguard.test.ts, dashboard/node/server.ts, dashboard/node/e2e/cycle.e2e.ts, dashboard/node/e2e/playbuild.e2e.ts, dashboard/node/e2e/work.e2e.ts, dashboard/node/e2e/automation.e2e.ts, dashboard/cli.ts, dashboard/src/views/CycleCard.tsx, dashboard/src/views/Work.tsx, dashboard/src/views/Board.tsx, dashboard/src/views/WorkItem.tsx, dashboard/src/views/PlayBuild.tsx, dashboard/src/views/SheetForm.tsx, dashboard/src/views/Automation.tsx, dashboard/src/views/Release.tsx, dashboard/src/views/work.css, dashboard/src/i18n/messages/, dashboard/src/i18n/catalog.ts, dashboard/ARCHITEKTURA.md, dashboard/INSTRUKCJA.md, dashboard/UI.md, WORKFLOW.md, docs/human-tasks/INFO.md, docs/human-tasks/factcheck_build_template.md, docs/human-tasks/factcheck_cykl_template.md, docs/ai-tasks/INFO.md, docs/ai-tasks/task_template.md, docs/agent/run-rules.md, docs/agent/ai-task-terminal.md, docs/analizy/plan.md, CLAUDE.md, tools/README.md, .claude/skills/ai-task/SKILL.md, .claude/skills/spec-sync/SKILL.md, .claude/skills/spec-tasks/SKILL.md
Ryzyko: wysokie

## Decyzje i założenia (analiza)

Wybory, które Roland zostawił otwarte. Agent wybrał wariant najbliższy jego słowom; wszystkie są odwracalne (proces).

1. **Część arkusza najpierw w pliku zadania, a arkusz składa serwer przy buildzie cyklu** (zamiast dopisywania części do otwartego pliku od razu przy wdrożeniu). Powody:
   - kryterium 1 jest spełnione dosłownie: w `docs/human-tasks/` leży zawsze najwyżej jeden otwarty arkusz, także wtedy, gdy Roland gra w cykl N, a zadania cyklu N+1 już się wdrażają;
   - streszczenie pkt 5 mówi „dashboard … otwiera jeden nowy arkusz z częściami wszystkich tych zadań”;
   - arkusz nigdy nie istnieje bez builda, więc D-32 jest spełnione bez bramki;
   - zadanie odrzucone albo niescalone nie zostawia części w arkuszu;
   - poprawki mogą zmienić część przed scaleniem;
   - równoległe wdrożenia nie dzielą jednego pliku, więc znika sztuczne nakładanie się zakresów (`derive.ts:1086-1090`).

   Pkt 1 streszczenia („wdrażane zadanie dopisuje swoją część na końcu tego samego otwartego arkusza”) jest spełniony co do skutku: każda część trafia na koniec jednego arkusza cyklu, tylko robi to serwer, a nie przebieg.
2. **Nazwa `factcheck-cykl-NN.md`**, nie `factcheck-build-<sha7>.md`. Klucz rejestru to numer cyklu, a Roland mówi o „numerach buildów”. Numer buildu = numer cyklu. Sha stoi w nagłówku (`> Build:`) i w rejestrze. Dawne `factcheck-build-*` i `factcheck-test-*` czyta się dalej jak dziś.
3. **Rejestr `docs/human-tasks/BUILDY.md`, pisze go tylko serwer.** Leży obok arkuszy, do których linkuje, i w ścieżkach, które dashboard i tak commituje. Wiersze ma tylko cykle zbudowane. Cykl, który zbiera, opisuje stopka i karta „Cykl”, bo jego lista zadań zmienia się przy każdym scaleniu. „Zbiera” nie jest stanem z rejestru; stany z kryterium 4 to `bieżący` i `stary`.
4. **Bez linii `Cykl:` w plikach zadań.** Przynależność do cyklu wynika z gita: zadanie scalone między buildem N-1 a buildem N należy do cyklu N. Zadanie otwarte należy do cyklu, który zbiera, a takiego jest zawsze dokładnie jeden. Linia zapisana przy planowaniu zestarzałaby się, gdy zadanie nie zdąży przed buildem. Zadania z oceny są „przypisane do następnego cyklu” z definicji, a jawnie widać to w kolumnie rejestru „Z oceny powstały” i w zdaniu „Z oceny cyklu NN” w ich kontekście.
5. **„Oddanie wyników” = kliknięcie Rolanda „Zamknij arkusz”** na arkuszu cyklu (z ⏭ dla pustych pól, D-28), a nie samo wypełnienie wszystkich wierszy: Roland może chcieć jeszcze dopisać „Uwagi ogólne”. Kompletny arkusz tylko podnosi krok „Zamknij cykl NN” w „Czeka na Ciebie”.
6. **Scalanie zostaje „przegląd + testy” (założenie b), arkusz przestaje być warunkiem scalenia automatycznego także dla `rozgrywka`.** Sprzeczność z D-35 („Po grze i arkuszu”, Roland, czat 2026-10-27) jest jawna. Nowsze słowa Rolanda (2026-10-28) wygrywają i nazywa to D-38. Dowód eksportu, który dawał build gałęzi, przejmuje scenariusz `export` w testach serwera dla `tekst` i `rozgrywka`. Podpis scalenia to osoba, która uruchomiła ostatni przebieg kodu, jak dziś dla `tekst` i `narzędzia`.
7. **Bez automatycznych buildów gałęzi.** Ręczny „Zbuduj podgląd gałęzi” zostaje do debugowania (kod już jest), ale nie łączy się z arkuszem, nie stoi w „Teraz” i nie trafia do rejestru.
8. **Build cyklu robi się sam**, gdy `cycleBuildCheck` nie ma powodów. Zatrzymany łańcuch i niedomknięte zadanie wstrzymują build, bo Roland chce jednego buildu ze wszystkimi zadaniami z oceny. Przycisk „Zbuduj build cyklu NN” buduje mimo tego i mówi, co zostanie poza buildem. Same zadania `narzędzia` nie budują automatycznie (nie ma czego grać), przycisk działa.
9. **Kod w rogu menu bez zmian.** UI-6 ✅ i TECH-1 to reguły Rolanda, a zmiana gry zaczyna się w specyfikacji. Rejestr zapisuje napis, który gra naprawdę pokaże (liczony z commita builda), i mówi wprost, że między wydaniami jest taki sam; build rozpoznaje się po numerze cyklu i sha w nazwie ZIP-a. Propozycja na później (💡, decyzja Rolanda): build do ogrania stempluje w tymczasowej kopii dopisek „cykl NN” w rogu menu. Wymaga zmiany UI-6 i testu `unit_test.gd:413`.
10. **Otwartego cyklu nie przebudowuje się.** Gdy build cyklu jest zepsuty (gra nie startuje), Roland zamyka arkusz z uwagą, poprawka idzie do następnego cyklu, a rejestr uczciwie pokazuje cykl „stary” z wynikiem „⏭”. To zgodne z „nowy build powstaje, gdy factcheck jest skończony”.
11. **Migracja przez jedno kliknięcie Rolanda.** Cykl 1 dostaje świeży build `master` (zawiera task_20, 21, 22, 25, 37) i części czterech zadań z pustymi komórkami człowieka. Jedyne wpisy w dawnych arkuszach (✅ w części task_22 w 333b147) zrobiono na buildzie f1e6f37, w którym task_22 nie było, więc nie są dowodem i zostają tylko jako historia w `done/`. Część task_22 przechodzi cała, także wiersze 5-6 (`release.sh`, `flags.md`); `release.sh` usunięto w P4, więc Roland zaznaczy wiersz 5 jako ⏭. Agent nie wycina wierszy z cudzego arkusza.
12. **Limit „buildy do ogrania” = 1 (build cyklu).** Wdrażanie w czasie gry jest dozwolone bez ostrzeżenia, bo trafia do następnego cyklu.
13. **Planowanie z oceny to zaznaczone domyślnie pole w oknie zamknięcia**, nie osobny obowiązkowy krok. Jedno kliknięcie Rolanda (zamknięcie) wystarczy, a koszt przebiegu planowania widać w oknie.
14. **Commity serwera (build cyklu, zamknięcie, migracja) nie są wypychane same**, jak dzisiejsze commity dokumentów serwera; push zostaje krokiem „Wypchnij grę”.
15. **Zmienna `EVERHORROR_PLAYBUILD_AUTO=0`** wyłącza teraz automatyczny build cyklu, zamiast wprowadzać nową zmienną.
16. **Plik `WORKFLOW.md` w „Pliki:”** to plik specyfikacji (`C:/dev/gamedev/everhorror/specification/WORKFLOW.md`). Gra nie ma pliku o tej nazwie, więc wpis jest jednoznaczny.

## Przegląd planu i uzupełnienia koordynatora (Fable 5.1, 2026-10-28)

Plan przyjęty w całości, łącznie z decyzją 1 (część arkusza najpierw w pliku zadania, arkusz cyklu składa serwer przy buildzie) i decyzją 5 (arkusz nie jest już warunkiem scalania; to założenie (b) z Wymagań, które Roland przyjął). Punkty U1–U9 są wiążące i mają pierwszeństwo tam, gdzie doprecyzowują plan.

1. **U1. Podpis automatycznego builda cyklu.** Bez odmowy `signer`. Podpisuje osoba z `automation.json` (`cycleBuild.by`, czyli administrator, który włączył przełącznik; domyślnie ta sama osoba co przy scalaniu automatycznym), a gdy jej nie ma, `Dashboard`. Trailer `Scalenie:` może być wskazówką, nie warunkiem: scalenia z terminala (koordynator) go nie mają.
2. **U2. Scenariusz `export` w testach serwera.** Przed oparciem warunku `build` na `tools/run_tests.sh export` sprawdź, czy ten scenariusz działa z `EVERHORROR_TEST_DIR` przebiegu i bez okna. Jeśli nie, serwer uruchamia `tools/export_smoke.sh` tak, jak robi to build (`runExportSmoke` z `node/playbuild.ts`), i zapisuje wynik w tym samym rekordzie testów serwera. Warunek D-35 `build` ma jeden sens: „eksport tego commita przeszedł test z paczki”.
3. **U3. Rejestr `docs/human-tasks/BUILDY.md`.** Dokładnie to, o co prosił Roland: numer buildu (= numer cyklu), kod z rogu menu, sha7 gry, data, lista zadań i zmian, stan, arkusz, wynik oceny, zadania z oceny. Najnowszy wiersz na dole, jak w planie. Plik ma być czytelny bez dashboardu i linkowany z `docs/human-tasks/INFO.md`, `tools/README.md` i karty cyklu.
4. **U4. Migracja uruchamia koordynator z terminala** (`cli.ts cycle migrate --who Roland`) zaraz po scaleniu i restarcie dashboardu, żeby Roland dostał gotowy stan: cykl 1 z buildem `master`, jeden arkusz `factcheck-cykl-01.md` z częściami task_37, 25, 22 i 20 (puste komórki człowieka), trzy dawne arkusze w `done/`. Przycisk w karcie cyklu zostaje na wypadek, gdyby migracja nie zaszła.
5. **U5. Zero skoków i jedna prawda na ekranie.** Karta „Cykl” stoi na górze zakładki Teraz, nad „Czeka na Ciebie”, ma stałą wysokość nagłówka i pokazuje powody z `cycleBuildCheck` jako listę (bez składania); te same powody serwer pisze do dziennika. Tablica task_36 dostaje znaczek cyklu na karcie bez zmiany wysokości karty.
6. **U6. Wdrożenie w kopii roboczej specyfikacji** `C:/dev/gamedev/everhorror/specification-task38` (gałąź `agent/task38-cycle`, `node_modules` jako junction); dokumenty gry (skille, INFO, szablony, `run-rules.md`, `CLAUDE.md`, `tools/README.md`, `plan.md`) w głównej kopii gry, niezatwierdzone, commit `[agent] proces: …` robi koordynator po przeglądzie. Dashboard Rolanda nie jest ruszany do scalenia; po scaleniu restart.
7. **U7. Testy.** `npm test`, `npx tsc --noEmit`, `npm run e2e` zielone na końcu; nowy `cycle.e2e.ts` z udawanym Godotem i udawanym agentem; bez prawdziwego Godota. W grze tylko `node tools/check_doc_links.js` dla zmienionych dokumentów.
8. **U8. Kompatybilność.** Dawne arkusze `factcheck-build-*` i `factcheck-test-*` dalej się parsują, zamykają i pokazują (historia); stare manifesty buildów bez pola `cycle` czytają się jak dotąd; `build master` z CLI zostaje.
9. **U9. Raport.** W pliku zadania: „Co zostało zrobione” po kryteriach 1–5, „Decyzje i założenia”, „Czego potrzebuję od Ciebie” (restart, migracja, co kliknąć pierwszy raz), „Test” z liczbami, „Podsumowanie” ostatnie.

## Podsumowanie planu (analiza)

Dziś arkusz i build powstają na gałąź zadania, więc po jednym dniu Roland ma trzy arkusze, kilka buildów i wiersze sprawdzone na buildzie, w którym zmiany nie było. Plan wprowadza cykl oceny: wdrożenie zapisuje swoją część arkusza w pliku zadania, zadania scalają się po przeglądzie i testach serwera (z testem eksportu), a po scaleniu i domknięciu zadań cyklu serwer robi jeden build `master` i jeden arkusz `factcheck-cykl-NN.md` z częściami ich wszystkich. Kliknięcie „Zamknij arkusz” zamyka cykl: arkusz idzie do `done/`, wiersz rejestru `docs/human-tasks/BUILDY.md` dostaje stan „stary” i wynik oceny, a przebieg planowania robi z ❌, 💬 i uwag zadania następnego cyklu, którego build czeka na ich scalenie. Rejestr prowadzi serwer: numer cyklu, kod z rogu menu (uczciwie: między wydaniami ten sam), commit gry, data, zadania, stan i link do arkusza. Trzy obecne arkusze przenosi jedno kliknięcie Rolanda do arkusza cyklu 1 na świeżym buildzie `master`. Ryzyko jest wysokie, bo zmiana zmienia D-35 (arkusz przestaje bramkować scalenie) i dotyka kontraktu przebiegów, strażnika, scalania automatycznego, łańcucha, skilli i trzech e2e; dlatego łańcuch zatrzyma się tu, żeby Roland zobaczył plan.

## Co zostało zrobione

Wdrożenie: Sonnet 5.5 high (sesja terminalowa, dokończenie przerwanej pracy poprzedniego wykonawcy), 2026-10-28. Kod w kopii roboczej specyfikacji `specification-task38` (gałąź `agent/task38-cycle`, cztery commity `[agent] dashboard: …`), dokumenty gry w głównej kopii (niezatwierdzone). Plan A–G wykonany z poprawkami U1–U9 i z jedną zmianą po planie (migracja, niżej w „Decyzjach i założeniach”).

### Kryterium 1: najwyżej jeden otwarty arkusz
- Wdrożenie `rozgrywka` nie zapisuje nic w `docs/human-tasks/` (korzenie zapisu w `runs.ts`, strażnik w `runguard.ts`, kontrakt i `run-rules.md`); część arkusza pisze w sekcji `## Część arkusza` swojego pliku zadania. `growableSheet()` i dopisywanie arkusza do zakresu wdrożenia zniknęły, więc wdrożenia nie nakładają się przez wspólny plik.
- Arkusz `factcheck-cykl-NN.md` składa serwer (`assembleCycleSheet()`, `node/cycles.ts`) razem z buildem cyklu, w kolejności scaleń, z pustymi kolumnami człowieka. Powstaje raz i nie rośnie.
- Dowód: `node/e2e/cycle.e2e.ts` (dwa wdrożenia: w `docs/human-tasks/` nic; po buildzie dokładnie jeden `factcheck-cykl-01.md` z dwiema częściami), `src/work/cycles.test.ts`, `node/cycles.test.ts`, `node/runguard.test.ts`.

### Kryterium 2: jeden build na cykl, dashboard i arkusz wskazują ten sam
- Po przebiegu nie ma builda gałęzi (`node/postrun.ts`); dowodem eksportu jest scenariusz `export` w testach serwera dla `tekst` i `rozgrywka` (`tools/run_tests.sh export` już istnieje w grze, U2 sprawdzone).
- `cycleBuildCheck()` (czysta, wspólna dla serwera i ekranu) zbiera powody czekania; gdy ich nie ma, `createCycleEngine()` (budzony przez automatykę) uruchamia build `master` (`Everhorror-cykl-NN-<sha7>-windows.zip`), a po udanym eksporcie `registerCycleBuild()` robi **jeden commit** z arkuszem i wierszem rejestru (U1: podpis z przełącznika albo „Dashboard”, bez odmowy). Karta „Cykl” na Pracy i arkusz pokazują ten sam build. Podgląd gałęzi to osobny, ręczny przycisk, bez związku z arkuszem i rejestrem.
- Scalanie automatyczne nie wymaga arkusza (D-35 pkt 6 zmieniony): przegląd „gotowe”, testy serwera zielone z `export`, brak konfliktu, podpis osoby, która uruchomiła ostatni przebieg kodu; ❌ w zaczętym dawnym arkuszu nadal wstrzymuje (`sheetProblems`). Limit „buildy do ogrania” to 1 cykl.

### Kryterium 3: oddanie wyników zamyka cykl
- „Zamknij arkusz” na arkuszu cyklu (`closeSheet()`) w jednym commicie przenosi arkusz do `done/` (⏭ w pustych polach), zmienia wiersz rejestru na `stary` z wynikiem (✅ a · ❌ b · 💬 c · ⏭ d) i przepina linki. Okno ma pole „Zaplanuj zadania z oceny”: kolejkuje przebieg planowania z `options.cycle` i notą „Ocena cyklu NN”; po jego czystym końcu `postrun.ts` wpisuje założone zadania w kolumnie „Z oceny powstały”. Następny build czeka (`zOceny`) na ich scalenie i domknięcie. Skill `spec-tasks` ma sekcję „Z oceny cyklu” (❌ → zgłoszenie błędu i zadanie poprawki, 💬 → reguła ⬜ albo karta decyzji).
- Przy dowodzie e2e znaleziono i naprawiono błąd: `parseSheetClose` w `work-api.ts` gubił pole `planFromReview`, więc zaznaczone pole planowania nie zlecało przebiegu.
- Dowód: `cycle.e2e.ts` (zapis z ❌; zamknięcie z planowaniem: wiersz `stary`, arkusz w `done/`, przebieg planowania, „cykl 2 zbiera”, build cyklu 2 czeka z `zOceny`).

### Kryterium 4: rejestr buildów `.md`
- `docs/human-tasks/BUILDY.md` pisze tylko serwer (strażnik blokuje go w każdym rodzaju przebiegu): numer cyklu, stan (`bieżący`/`stary`), commit gry builda, kod w rogu menu (liczony z commita: `config/version` i `SPEC_SHA`), data, ZIP, zadania i zmiany (linki, tytuły, ID reguł, „inne commity: N”), link do arkusza, wynik oceny, zadania z oceny. Parser jest tolerancyjny, „Uzgodnij rejestr” naprawia rozjazdy (`reconcileRegister()`). Stopka mówi, po którym commicie zbiera następny cykl.
- Czytelny bez dashboardu; opisany w `docs/human-tasks/INFO.md` (sekcja „Rejestr buildów”) i `tools/README.md`, a w karcie cyklu jest link do niego. W INFO i README plik jest wymieniony jako kod, nie link, bo powstaje dopiero z pierwszym buildem cyklu (martwy link zgłosiłby `check_doc_links.js`).

### Kryterium 5: dokumentacja i skille
- Gra (niezatwierdzone): `docs/human-tasks/INFO.md` (nowa sekcja „Cykl oceny”, „Rejestr buildów”, nazwy arkuszy, kto co pisze), `factcheck_cykl_template.md` (`git mv` z `factcheck_build_template.md`, bez commita) i komentarz w `factcheck_template.md`, `docs/ai-tasks/INFO.md`, `task_template.md` (sekcja `## Część arkusza`), skille `ai-task`, `spec-sync`, `spec-tasks`, `docs/agent/run-rules.md`, `docs/agent/ai-task-terminal.md`, `CLAUDE.md`, `tools/README.md` i `docs/analizy/plan.md` (decyzja **D-38** dokładnie według brzmienia z planu, dopiski przy D-27, D-32 i D-35, §3 pkt 5–7, „Gdzie jesteśmy”).
- Specyfikacja (w kopii roboczej): `dashboard/ARCHITEKTURA.md` §13 (nowa podsekcja „Cykl oceny (D-38)”, poprawione „Build do ogrania”, „Scalenie automatyczne”, „Fakty z serwera”, łańcuch, tabela modułów), `INSTRUKCJA.md` §4 i §5, `UI.md` (słowniczek), `WORKFLOW.md`.
- `node tools/check_doc_links.js` na zmienionych dokumentach gry (CLAUDE.md, docs/agent, INFO, szablony, plan, tools/README.md, skille): 122 cele, 0 brakujących. Uruchomiony bez argumentów skanuje cały obszar roboczy i zgłasza 492 brakujące linki w zagnieżdżonym folderze `specification/` (poza zakresem zadania).

## Decyzje i założenia (wdrożenie)

1. **Migracja zastąpiona zwolnieniem.** Po planie Roland (czat 2026-10-28) zdecydował, że trzy otwarte arkusze `factcheck-build-333b147`, `-368ac18` i `-b250ebb` mają zniknąć z jego listy od razu, a swoją ocenę dał w czacie (z niej powstaje task_39). Koordynator zwolni i zamknie te arkusze po scaleniu, przed jakimkolwiek buildem cyklu, więc ścieżka migracji (plan D, pkt 22–23, U4) nie będzie użyta. Kod migracji (`cli.ts cycle migrate`, przycisk w karcie) zostaje bez zmian jako zapas; pkt 23 (kolumna „Historia” w `docs/ai-tasks/INFO.md`) odpada. **Cykl 1 startuje pusty („zbiera”)** i bierze pierwsze zadanie scalone do `master` po zamknięciu starych arkuszy.
2. **Punkt startu pierwszego cyklu bez rejestru** (`cycleBase()` w `node/workspace.ts`, test w `node/cycles.test.ts`): późniejszy z dwóch commitów, ostatniego, który przeniósł plik `factcheck-*.md` do `docs/human-tasks/done/` (wszystko przed nim było ocenione albo zwolnione przez Rolanda), i ostatniego tagu wydania; bez żadnego z nich cały `master`. Dotychczasowy kod brał tylko ostatni tag (`v0.5.4`), co wciągnęłoby do cyklu 1 task_20, 21, 22, 25 i 37, które Roland już ocenił w czacie. Po zamknięciu trzech starych arkuszy punktem startu jest właśnie ten commit zamknięcia, więc cykl 1 zbiera od zera. Opisane w `docs/human-tasks/INFO.md` („Pierwszy cykl bez rejestru”), `ARCHITEKTURA.md` i `INSTRUKCJA.md`. Stopka `BUILDY.md` („Cykl N zbiera zadania scalone do `master` gry po commicie …”) pojawia się razem z pierwszym wierszem rejestru; do tego czasu pliku nie ma, a punkt startu pokazuje karta „Cykl”.
3. **Zwolniony, ale otwarty arkusz starego rodzaju wstrzymuje pierwszy build** (powód `migracja`). Samo zwolnienie nie przenosi arkusza do `done/`, więc stare arkusze trzeba **zwolnić i zamknąć** („Zamknij arkusz” z pominięciem pól), nie tylko zwolnić. Tego wymaga też reguła z pkt 2.
4. **Scenariusz `export`** w testach serwera: `tools/run_tests.sh export` (eksport oraz `day1` i `expedition` z paczki) istnieje w grze i działa bez okna z `EVERHORROR_TEST_DIR` przebiegu (U2), więc obejście przez `export_smoke.sh` nie było potrzebne.
5. **Dawny arkusz w `work.e2e.ts` zostaje.** Fixture ma dawny `factcheck-test-01.md`; kroki zapisu i zamknięcia na nim sprawdzają zgodność (U8), a nowy przepływ pokrywa `cycle.e2e.ts`. Plan przewidywał osobny test „zapis bez linii `Build` na arkuszu cyklu”: pokrywa go `cycle.e2e.ts` (krok 4: odmowa wyboru builda i brak zmiany linii) i `node/cycles.test.ts`.
6. Reszta decyzji z analizy (część arkusza w pliku zadania, nazwa `factcheck-cykl-NN.md`, rejestr tylko od serwera, brak linii `Cykl:` w plikach zadań, „oddanie wyników” = „Zamknij arkusz”, kod w rogu menu bez zmian) wdrożona tak, jak w planie.

## Czego potrzebuję od Ciebie

1. **Po scaleniu: restart dashboardu**, żeby wczytał nowe trasy (`/work/cycle/*`, `/work/cyclebuild`) i silnik cyklu.
2. **Zwolnić i zamknąć trzy stare arkusze** (`factcheck-build-333b147`, `-368ac18`, `-b250ebb`): „Zwolnij z testu”, potem „Zamknij arkusz” (czynność człowieka; koordynator robi ją w imieniu Rolanda). Dopóki leżą otwarte, pierwszy build cyklu czeka z powodem „Przenieś otwarte arkusze do cyklu 1”.
3. **Zapisać dokumenty gry w historii** (`[agent] proces: …`, robi koordynator po przeglądzie): skille, INFO, szablony (w tym `git mv` szablonu), `run-rules.md`, `CLAUDE.md`, `tools/README.md`, `plan.md`.
4. Pierwszy build cyklu rusza sam, gdy pierwsze zadanie po zamknięciu starych arkuszy będzie scalone i domknięte (albo kliknięciem „Zbuduj build cyklu 1”). Podpis: „Dashboard”, dopóki przełącznik „Build cyklu automatycznie” nie ma ustawionej osoby.
5. Na później (💡, decyzja Rolanda): stempel „cykl NN” w rogu menu gry wymaga zmiany UI-6 i testu `unit_test.gd:413`; rejestr zapisuje kod w rogu taki, jaki gra pokaże.

## Test

Dashboard (`C:/dev/gamedev/everhorror/specification-task38/dashboard`):
- `npx tsc --noEmit`: clean
- `npm test`: 2700/2700 przechodzi (node --test, 0 niepowodzeń, 0 pominiętych)
- `npm run e2e`: 62/62 przechodzi (w tym 6 testów cycle.e2e.ts), 0 niepowodzeń, 0 pominiętych
- `node cli.ts lint`: 0 błędów, 0 uwag
- Nowy przepływ: `node/e2e/cycle.e2e.ts` (dwa wdrożenia, dwa scalenia automatyczne, dwa domknięcia, build cyklu 1 sam, jeden arkusz z dwiema częściami i wiersz `bieżący`, zapis z ❌, zamknięcie z planowaniem, cykl 2 czeka z `zOceny`).
- Zaktualizowane: `playbuild.e2e.ts` (brak builda po przebiegu, podgląd gałęzi na klik, build `master`), `work.e2e.ts`, `automation.e2e.ts` (scalenie bez bramki arkusza i bez builda, ❌ w dawnym arkuszu, łańcuch czeka na scalenie), `scenario.mjs` (część arkusza, planowanie).
- Nowe testy jednostkowe: punkt startu bez rejestru, scenariusz `export` i `exportProvedFor`, nazwy arkuszy cyklu i `BUILDY.md`.
- Gra: `node tools/check_doc_links.js` na zmienionych dokumentach: 122 cele, 0 brakujących. Godot i zestaw testów gry nie były uruchamiane.

## Podsumowanie

Cykl oceny (D-38) jest wdrożony i przetestowany: zadania `rozgrywka` piszą część arkusza w swoim pliku, scalają się po przeglądzie i testach serwera z testem eksportu, a po scaleniu i domknięciu zadań cyklu serwer sam robi jeden build `master`, jeden arkusz `factcheck-cykl-NN.md` i wiersz rejestru `BUILDY.md` w jednym commicie. „Zamknij arkusz” zamyka cykl i zleca planowanie zadań z oceny, a następny build czeka na ich scalenie. Dokumenty i skille mówią o cyklu zamiast „arkuszu na build”. Migracja trzech starych arkuszy jest zbędna (Roland je zwolnił, ocena poszła do task_39): cykl 1 zbiera od zera, od commitu zamknięcia starych arkuszy. Po scaleniu: restart dashboardu, zwolnienie i zamknięcie trzech starych arkuszy, zapis dokumentów gry.
