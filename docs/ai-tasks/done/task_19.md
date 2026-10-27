# task_19: Dashboard — czytelność, dwujęzyczność i propozycje z przeglądu

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
1. „W dashboardzie w przegladzie dostalem pytania i mam odpowiedzi typu a) B1 + B2 + B3
No tak nie moze byc, ja musze mieć kontekst do takich pytań przy proponowanym wyborze, bo inaczej skad mam wiedziec, dodaj to do planów do poprawy.”
2. „Dodajmy też mechanizm, że jak człowiek nie wypełni arkusza to może pchać kolejne elementy i po prostu arkusz sie rozrasta o nie. DOdatkowo powinna byc mozliwosc oddania arkusza do /done z niewypelnionymi polami, wtedy wszystko liczy sie jako pominiete.” — „No wpisujemy te pominiecie w kazda pusta komórke.”
3. „Dodatkowo puść w tle analize Opus 5.5 Max żeby zweryfikował czy można jeszcze jakoś funkcjonalnie/jakościowo/wizualnie usprawnić dashboard, niech zrobi liste propozycji w jakimś pliku .md. To ja sobie potem przejrze”
4. „No i jak on skonczy z ta porpozycja, to przeczytaj i dopisz tam też sekcje, żeby zrobić troche parallel to runowanie agentów i branche, żeby nie było tyle kolizji i konfliktów z branchami, zrobimy sobie golden-main na githubie, z którego robimy buildy i do niego wrzucamy rzeczy, ale on jest jakby golden-standardem, a wszystko inne pracuje na innych branchach, co myslisz?”
5. „Rozplanuj te propozycje na konkretne taski i zacznij delegować Sonnet 5.5 High do roboty jako subagenty albo Haiku 5.5 Max jezeli latwiejsze zadanie. Ty zostajesz koordynatorem. Dodatkowo chce też podneiść czytelność dashboardu, poczytaj o dobrmy projektowaniu UI/UX, o czytelnych nazwach, zrób to wgl dwujęzyczne.”

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Plan

Źródła: propozycje z przeglądu dashboardu `docs/analizy/propozycje-dashboard.md` (F1–F15, J1–J6, W1–W5, R1–R4) oraz punkty (a)–(k) z planu ([Odłożone](../../archiwum/plan-historia-2026-10.md#odłożone-bez-decyzji)) i decyzje [D-27…D-29](../../archiwum/plan-historia-2026-10.md#decyzje-o-arkuszach-człowieka-d-27d-28). Po zakończeniu zadania plik propozycji zostaje usunięty, a ten plik jest jedynym zapisem.

**Jak pracujemy.** Kod powstaje w osobnej kopii roboczej specyfikacji `C:\dev\gamedev\everhorror\specification-praca` na gałęzi `agent/dashboard-ux` (od `6436f80`), jak w task_15. Żywa kopia `specification` jest używana przez Rolanda i działający dashboard. Każde zadanie cząstkowe robi jeden agent od początku do końca we własnej kopii (`specification-praca-<id>`, gałąź `agent/dux-<id>` od `agent/dashboard-ux`). Koordynator (Opus 5.5) przegląda wynik i scala go do `agent/dashboard-ux`. Do master specyfikacji całość trafia dopiero po odbiorze Rolanda. Modele: Sonnet 5.5 high, a przy prostszych zadaniach Haiku 5.5 max.

**Zasada dla tekstów od fali 1.** Każdy nowy albo zmieniany napis w interfejsie idzie przez mechanizm tłumaczeń z fali 0, po polsku i po angielsku, według słowniczka z `dashboard/UI.md`. Pozostałe napisy tłumaczy fala 3.

| ID | Fala | Zakres | Model | Stan |
|---|---|---|---|---|
| T0-test | 0 | J1: testy nie dotykają prawdziwego folderu przebiegów | Sonnet high | scalone (`437a830`) |
| T0-ux | 0 | Zasady UI/UX i słowniczek PL/EN (`dashboard/UI.md`), mechanizm dwujęzyczności, przełącznik języka, nawigacja i nazwy (W2) | Sonnet high | scalone (`5a63369`, poprawka `5eb02f2`; tłumacz w `deriveWork`: `4705cab`) |
| T1-scal | 1 | F1, J2, F2: werdykt przeglądu w oknie scalania, werdykt przypięty do commita, commity i pliki gałęzi | Sonnet high | scalone (`9c0e962`) |
| T1-karty | 1 | F6, F7, J4 (karta), (j): pełne odpowiedzi, podgląd, panel bez pułapki statusu, kontekst opcji, szablon i skille | Sonnet high | scalone (`baaa16b`) |
| T1-przebiegi | 1 | F8, F9, F12, J6: koszt i zużycie, różnice od domyślnych, czytelny dziennik, nazwy modeli i Haiku | Sonnet high | scalone (`9c0e962`) |
| T1-zatwierdz | 1 | F13, F14: ze Zmian do Zatwierdź, podgląd planowania i opis commita | Haiku max | scalone (`9c0e962`) |
| T1-porzadki | 1 | J3, W4, J5, (e), (f), (g): stary silnik „co dalej”, liczebniki, dokumentacja, nawigacja instrukcji, etykiety i formy neutralne | Haiku max | scalone (`9c0e962`) |
| T2-arkusze | 2 | F3, W5, (k) = D-27 i D-28: raport przebiegu, nawigacja po pustych polach, arkusz rosnący, zamknięcie z ⏭ | Sonnet high | scalone (`08e0d02`) |
| T2-teraz | 2 | F4, F5, F10, F11, W1: wznowienie po decyzji, licznik planowania, „Wyjaśnione”, świeżość stanu, spokojne powody; [task_18](../task_18.md) („Zmiany do wdrożenia” pod przyciskiem „Zaplanuj zadania”) | Sonnet high | scalone (`d0706cf`) |
| T2-zadanie | 2 | W3, F15: kolejność kart strony zadania, polecenie dla zadań narzędziowych | Haiku max | scalone (`d0706cf`) |
| T2-diff | 2 | (a)–(d), (h), (i): fałszywe „do wdrożenia”, pliki redakcyjne, wtyczki w przebiegach, domknięcie; czerwony test e2e z `work.e2e.ts:1264` | Sonnet high | scalone (`d0706cf`; e2e 22/22) |
| T3-tlum | 3 | Tłumaczenie pozostałych napisów w czterech grupach: rdzeń (`derive.ts`, `workView.ts`, znaczniki, opisy zmian), przebiegi (`runs.ts`, `Runs.tsx`), widoki (Zgłoszenia, Wdrożenia, Nowe zadanie, Zespół, Logowanie i inne), części wspólne (`FileView`, komponenty, komunikaty danych) | Sonnet high ×2, Haiku max ×2 | scalone (`cc10bc2`); dopięcie tłumaczeń (Haiku max) scalone |
| T4-kopie | 4 | R2, R3: kopia robocza na przebieg, jeden pisarz buchalterii, blokada na zapis | Sonnet high | R2 scalone (`50b95ee`); R3 tylko jako plan w `ARCHITEKTURA.md` (zbyt ryzykowne bez próby na prawdziwym agencie) |
| T5-poprawki | 5 | Poprawki z przeglądu koordynatora: linki do zadań i arkuszy, rodzaj zgłoszenia, komunikaty lintu i parsowania w języku ekranu, klucze React, nazwy w dokumentach | Sonnet high | scalone (`e62f3a4`) |
| T4-rownolegle | 4 | R4: dwa wdrożenia naraz | Sonnet high | czeka na decyzję (plan §3 pkt 5, §5) |
| R1 | — | Reguła gałęzi `master` gry w GitHubie | koordynator | czeka na „tak” Rolanda (zmiana publiczna) |

## Co zostało zrobione

**Stan końcowy gałęzi `agent/dashboard-ux` (`e62f3a4`, wypchnięta do `everhorror-spec` jako kopia zapasowa):** typy bez błędów, `npm test` 1976/1976, `npm run e2e` 25/25, build, lint specyfikacji 0/0. Gałąź zawiera też aktualny master specyfikacji (zasady z 2026-10-27). Koordynator przejrzał osobiście strażnika przebiegów, scalanie, zamknięcie z ⏭ i zakładanie kopii roboczych, uruchomił gałąź na prawdziwych danych (tylko odczyt) i obejrzał 14 stron w PL i EN w przeglądarce bez okna: 0 wyjątków; usterki z tego przeglądu poprawił T5. Szczegóły fal są w tabeli wyżej i w commitach gałęzi; poniżej najważniejsze zapisy z pierwszych zadań.

**Co zostaje poza zadaniem:** R3 (jeden pisarz buchalterii, plan w `ARCHITEKTURA.md`), R4 (dwa wdrożenia naraz, czeka na decyzję), R1 (reguła gałęzi w GitHubie, czeka na „tak”). Teksty na ekranie, które celowo zostają po polsku: treść specyfikacji, zadań i arkuszy, wartości zapisywane do plików, kontrakt agenta, zapisane wyniki audytu i komunikaty serwera.

### T0-test (J1) — Sonnet 5.5 high, scalone `437a830`
- `node/security.test.ts`: każde `specApi()` dostaje katalogi gry, kopii i przebiegów w świeżym folderze tymczasowym, więc menedżer przebiegów w ogóle nie powstaje. Pozostałe testy już używały folderów tymczasowych (sprawdzone wszystkie).
- `node/runner.ts`: `getRunManager()` w procesie `node --test` odmawia (błąd), gdy folder przebiegów leży poza folderem tymczasowym systemu. Zwykły serwer działa bez zmian. Nowy test sprawdza to na wymyślonej ścieżce.
- `ARCHITEKTURA.md`: opis testów zgodny z kodem.
- Wynik (zawsze z folderami tymczasowymi): typy bez błędów, `npm test` 1724/1724, `npm run e2e` 20/21. Jedyny błąd e2e był już na `6436f80`: test „waive, close …, spec commit and its lint gate” (`node/e2e/work.e2e.ts:1264`) oczekuje 422 `lint`, a dostaje 409 `conflict` dla `03_mechaniki/czas.md`. Do zbadania w T2-diff.

### T1-karty ((j), F6, F7, J4) — Sonnet 5.5 high, scalone `baaa16b`
- Panel „Rozstrzygnij decyzję” pokazuje u góry „Kontekst opcji” (sekcja „Możliwości i rekomendacja” z karty), a pod każdym pytaniem „Co znaczą kody w tych opcjach” z definicjami z listy `- B1: …`.
- Lint: uwaga `OPCJA_KOD_BEZ_OPISU` dla otwartej karty decyzji, gdy opcja używa kodu (B1, A2…) bez definicji w karcie i bez opisu zaraz po kodzie. Opis po ostatnim kodzie nie objaśnia wcześniejszych („B1 + B2 (najmniejszy krok)” → uwaga o B1). ID zasad (CZAS-10) są zwolnione. Na prawdziwych kartach: 0 uwag.
- Szablon `szablony/decyzja.md` i `zgloszenia/README.md` opisują tę samą zasadę.
- Niepełne odpowiedzi: domyślny status ❔, zamknięcie ✅/❌ z brakami wymaga zaznaczenia „Zamykam z N pytaniami bez odpowiedzi”, linia decyzji wymienia braki. Zwijany „Podgląd zmiany karty” przed zatwierdzeniem.
- Ogólne pole statusu i edycja kolumny „Twój wybór” w tabeli są pod „Ręczna edycja (zwykle niepotrzebna)”.
- Zapis decyzji to czysta funkcja `src/work/decision.ts` z testami na prawdziwej karcie sprzed decyzji (`748b273^`), bez podwójnych pustych linii.
- Wynik: typy bez błędów, `npm test` 1765/1765 (po scaleniu), lint specyfikacji 0/0. Interfejsu nie oglądano w przeglądarce.

## Do zrobienia przy scaleniu do master specyfikacji

Skille gry, które piszą karty, mają odwoływać się do uwagi lintu dopiero wtedy, gdy żywy lint ją zna:
- `.claude/skills/ai-task/SKILL.md` (linia z tabelą `| # | Pytanie | Opcje | Rekomendacja | Twój wybór |`), dopisać po `` `## Decyzja` = "Do rozstrzygnięcia." ``: „Every option must be understandable without the rest of the card: it says in words what is chosen, and every code (B1, A2…) it uses is explained either by a list item `- B1: …` under "Możliwości i rekomendacja" (the dashboard shows it next to the question) or on the spot (`**a)** B1 (scena zaznaczenia żyły) + B2 (przyciemnienie przy pracy)`). A gloss after the last code only does not explain the earlier ones (`B1 + B2 (najmniejszy krok)` leaves B1 unexplained). A code with neither triggers the lint warning `OPCJA_KOD_BEZ_OPISU` (rule ids like CZAS-10 are exempt): fix it before committing.”
- `.claude/skills/spec-tasks/SKILL.md` (pytania z przebiegu bez nadzoru): zamiast „(quote its ID; options as `**a)** … **b)** …`, your recommendation first, `Twój wybór` empty)” wpisać: „(quote its ID; options as `**a)** … **b)** …`, each understandable on its own: every code (B1, A2…) is explained by a list item `- B1: …` under "Możliwości i rekomendacja" or on the spot (`B1 (scena zaznaczenia żyły)`), a gloss after the last code does not cover the earlier ones, and a code with neither triggers the lint warning `OPCJA_KOD_BEZ_OPISU` (rule ids like CZAS-10 are exempt); your recommendation first, `Twój wybór` empty)”.

Arkusz kilku zadań (D-27) i zamknięcie z ⏭ (D-28) wchodzą w grze dopiero razem z kodem dashboardu, bo dzisiejszy dashboard w master nie czyta części `## Część: task_NN` ani linii `> Zadania:`. Przy scaleniu (dokładne teksty w raporcie T2-arkusze, streszczenie tutaj):
- `.claude/skills/ai-task/SKILL.md`, implement krok 6, pierwszy punkt: otwarty arkusz, którego nikt nie zaczął wypełniać, rośnie zamiast nowego. Część `## Część: task_NN — <tytuł>` z podsekcjami „Co zostało dodane”, „Test”, „Wyniki automatu (agent)” dopisuje się wyłącznie na KOŃCU pliku, a zadanie trafia do linii `> Zadania: [task_16](…), [task_NN](…)` (dawną linię `> Zadanie:` najpierw zamienić). Wiersz „Na gałęziach” wskazuje wspólny arkusz. Arkusz zaczęty przez człowieka nigdy się nie rozrasta.
- Ten sam plik, `close NN`: arkusz kilku zadań czyta się i zamyka w całości. Zamknięcie z pominięciem robi tylko Roland w dashboardzie; to nie jest zwolnienie, a ⏭ nie jest dowodem.
- `docs/human-tasks/INFO.md`: nowy rozdział „Arkusz kilku zadań”, uzupełnienie wstępu, „Znaczników wyniku” (⏭ wpisany przez dashboard przy zamknięciu) i punktu „Zamknięcie” w „Zwolnij, zastąp, zamknij” (D-28, „Zamykam bez raportu”). Tabela raportu przebiegu jest strefą człowieka (`<!-- człowiek -->` albo kolumny „Plik .md (człowiek)”, „Plik .json (człowiek)”), a pliki dołącza przycisk „Dołącz raport przebiegu” do `docs/human-tasks/raporty/`.
- `docs/human-tasks/factcheck_template.md` i `playtest_template.md`: zdanie o dopisywaniu części do otwartego arkusza i sekcja „Raport przebiegu: dołącz plik” z tabelą pod `<!-- człowiek -->`.
- Prompt wdrożenia w `src/work/runs.ts` już to mówi (`6e7b7b7`), więc skill i dashboard zmieniają się w tej samej chwili.

Kopia robocza na gałąź (R2, T4-kopie) też wchodzi dopiero razem z kodem dashboardu:
- `ai-task/SKILL.md`, „Dashboard runs” (punkt o kodzie): zamiast stałej ścieżki `…/everhorror-wdrozenie` — „kopia wskazana w kontrakcie (dashboard zakłada jedną na gałąź w `C:/dev/gamedev/everhorror/everhorror-wt/`; starsze gałęzie mogą stać w `everhorror-wdrozenie`)”; Godot nadal tylko z `--path` na tę kopię.
- Ten sam plik, „Spec tasks / Where”: w przebiegu z dashboardu gałąź i jej kopia już istnieją i są przełączone, więc nic nie zakładać ani nie przełączać. W terminalu: `git -C <gra> worktree add -b spec/<data>-task<NN> C:/dev/gamedev/everhorror/everhorror-wt/spec-<data>-task<NN> master`, potem skopiować `.godot` albo `godot --headless --path <kopia> --import`. Usunąć zdanie „If it exists: `git switch -c`…”.
- Ten sam plik, „fix NN” krok 1: kopia gałęzi (z kontraktu) stoi na gałęzi i jest czysta; jeśli nie, stop i raport. Tylko starsza gałąź we wspólnej kopii może być odłączona i czysta, a potem `switch`.
- Ten sam plik, „implement” krok 4 i „review”: świeża kopia potrzebuje `--import` Godota przed testami.
- `spec-sync/SKILL.md` (domknięcie): dashboard usuwa kopię gałęzi przy scaleniu; `switch --detach` tylko wtedy, gdy kopia z kontraktu to stara wspólna kopia wciąż na gałęzi. Gdy `branch -d` odmawia, bo kopia wciąż trzyma gałąź (miała niezatwierdzone zmiany), nie wymuszać; zgłosić w `ZROBIONE`.
- `CLAUDE.md` gry, tabela „Places” i „Branches”: kopie wdrożeniowe w `C:/dev/gamedev/everhorror/everhorror-wt/<gałąź>`, `everhorror-wdrozenie` tylko dla gałęzi sprzed zmiany.

### Dokładne teksty do wklejenia (D-27, D-28)

1. `ai-task/SKILL.md`, implement krok 6, zamiast punktu „Sheet `docs/human-tasks/factcheck-test-NN.md` …”:
   > Sheet `docs/human-tasks/factcheck-test-NN.md` (Polish): in the **main copy**, never on the branch; from `factcheck_template.md`, or `playtest_template.md` for a play session (rules: `docs/human-tasks/INFO.md`). Human zones stay empty; in an existing sheet add rows and prose only. **An open sheet that nobody has started grows instead of a new one (D-27):** when the main copy already holds an open sheet whose human cells are all empty (no entry, no `Wyniki człowieka`, `Zwolnienie` or `Zamknięcie` line), do not create `factcheck-test-NN.md`. Append this task's part at the very END of that sheet (never in the middle: table numbers and answer ids of the entries above must stay put): a `## Część: task_NN — <title>` heading with its own "Co zostało dodane", "Test" and "Wyniki automatu (agent)", human cells empty. Add `task_NN` to the header line `> Zadania: [task_16](../ai-tasks/task_16.md), [task_NN](../ai-tasks/task_NN.md) · …` (turn the old `> Zadanie:` line into `> Zadania:` first). The "Na gałęziach" row of `WDROZENIA.md` then names that shared sheet. A sheet a person has started to fill in is never extended: create a new one as before.
2. `ai-task/SKILL.md`, `close NN`, po „Never move an unfilled sheet without Roland's waiver: …”:
   > A sheet that holds several tasks (`## Część: task_NN`) is read and closed as a whole: every part's `wynik` cell counts, and all its tasks close with it. Roland can also close an unfilled sheet in the dashboard ("Przenieś arkusz do done/" with a confirmation): the dashboard then writes `⏭ pominięte (zamknięcie bez wypełnienia)` into the empty fields and the `Zamknięcie: … pominięte N z M pól` line. That is closing without full verification, not a waiver, and ⏭ is never evidence; you never do it yourself.
3. `docs/human-tasks/INFO.md`:
   - wstęp, po „Agent tworzy je w głównej kopii gry z `factcheck_template.md` albo `playtest_template.md`”: „, albo dopisuje część do otwartego, jeszcze niewypełnionego arkusza (zob. „Arkusz kilku zadań”)”;
   - „Strefy człowieka → Cała tabela”, na końcu: „Tak samo tabela raportu przebiegu (kolumny „Plik .md” i „Plik .json”): pod `<!-- człowiek -->` albo z kolumnami „Plik .md (człowiek)” i „Plik .json (człowiek)”; nie liczy się do „kompletny”, a plik dołącza przycisk „Dołącz raport przebiegu” w dashboardzie (kopiuje parę z folderu raportów gry do `docs/human-tasks/raporty/` i wpisuje linki).”;
   - nowy rozdział po „Nazwy arkuszy”: „## Arkusz kilku zadań — Gdy otwarty arkusz nie jest jeszcze wypełniany (żadnego wyniku człowieka, żadnej linii `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`), kolejne zadania dopisują do niego część zamiast zakładać nowy arkusz: nagłówek `> Zadania: [task_16](…), [task_17](…)` (dawna linia `> Zadanie:` czyta się jak dotąd) i na KOŃCU pliku `## Część: task_NN — <tytuł>` z własnymi podsekcjami („Co zostało dodane”, „Test”, „Wyniki automatu (agent)”) i pustymi komórkami człowieka. Nigdy nie wstawia się części w środek pliku ani nie rusza istniejących wierszy. Część sięga do następnego nagłówka poziomu 1–2. Dashboard przypisuje arkusz każdemu z wymienionych zadań, pokazuje postęp każdej części, a zadania zamykają się razem z arkuszem. Arkusz, który człowiek zaczął wypełniać, się nie rozrasta.”;
   - „Znaczniki wyniku”, dopisać: „Znacznik `⏭ pominięte (zamknięcie bez wypełnienia)` wpisuje w puste pola sam dashboard przy zamknięciu arkusza z pominięciem; nie jest dowodem sprawdzenia.”;
   - ostatni punkt „Zwolnij, zastąp, zamknij” zastąpić: „Zamknięcie: arkusz kompletny albo zwolniony przenosi się do `done/` bez zmian (`git mv`, linki dostają `../`). Arkusz jeszcze niewypełniony Roland może zamknąć w dashboardzie „z pominięciem”: w tym samym commicie każde puste pole do wypełnienia (wyniki, skale, pytania otwarte) dostaje `⏭ pominięte (zamknięcie bez wypełnienia)`, kolumna uwag zostaje pusta, a nagłówek dostaje `Zamknięcie: <Imię> (dashboard, <data>): pominięte N z M pól`. To wpis człowieka (agent go nie robi), a zadania z takiego arkusza zamykają się jako „zamknięte bez pełnego sprawdzenia”. Zwolnienie mówi „tego testu nie trzeba”, pominięcie „tego nie sprawdzono”. Pusta tabela raportu przebiegu wymaga w dashboardzie potwierdzenia „Zamykam bez raportu”. Do czasu zamknięcia arkusz leży tutaj.”
4. `docs/human-tasks/factcheck_template.md`: w komentarzu u góry, po zdaniu kończącym się „…nigdy na gałęzi spec/*; arkusz zatwierdza dashboard.”: „Gdy otwarty arkusz innego zadania nie jest jeszcze wypełniany, nie kopiuj szablonu: dopisz na końcu tamtego arkusza część `## Część: task_NN — <tytuł>` (podsekcje „Co zostało dodane”, „Test”, „Wyniki automatu (agent)” poziomu `###`) i dopisz zadanie do linii `> Zadania:` (reguły: INFO.md, „Arkusz kilku zadań”).” Po „## Wyniki automatu (agent)”, przed „## Uwagi ogólne (wypełnia człowiek)”, opcjonalna sekcja (także w `playtest_template.md` zamiast zdania o „Raport przebiegu: dołącz plik”), z komentarzem „Sekcję „Raport przebiegu” dodaj tylko, gdy build zapisuje raport przebiegu (znacznik nad tabelą i dopisek „(człowiek)” w nagłówkach są obowiązkowe: bez nich formularz tabeli nie pokaże).”:
   ```
   ## Raport przebiegu: dołącz plik
   Po zakończeniu tygodnia kliknij w dashboardzie „Dołącz raport przebiegu”: para plików z folderu raportów gry trafia obok arkusza (`raporty/`), a linki do niej do tabeli. Jeśli raport nie powstał, zapisz to w uwagach.

   <!-- człowiek -->
   | Plik `.md` (człowiek) | Plik `.json` (człowiek) | Uwagi (człowiek) |
   |---|---|---|
   | | | |
   ```

### Build do ogrania przed arkuszem (D-32)

Wchodzi razem z kodem dashboardu z gałęzi `agent/dux-build` (dzisiejszy dashboard nie robi buildów i nie wstrzymuje arkuszy). Przebieg wdrożenia i poprawek dostaje już w kontrakcie zdanie, że build robi dashboard po przebiegu, więc skille i dashboard zmieniają się w tej samej chwili. Teksty do wklejenia:

1. `CLAUDE.md` gry, „Flow”, po zdaniu „`/ai-task implement NN` builds on the branch, … with an `[agent]` commit and push.”:
   > After an implement or fix run that ended well the dashboard server exports a playable build of the branch head (no model, no version stamp, no tag) into `build/do-ogrania/` (`Everhorror-test-task<NN>-<sha7>-windows.zip`); a sheet of a task on an open branch takes entries only while that build is current (D-32). A release (version, CHANGELOG, tag) stays a separate step after the merge.
2. `CLAUDE.md`, tabela „Places”, nowy wiersz po „Dashboard run records and lock”:
   > | Playable builds (git-ignored; made by the dashboard, or by `node <spec>/dashboard/cli.ts build task_NN` in a terminal) | `build/do-ogrania/` |
3. `ai-task/SKILL.md`, implement krok 6, na końcu punktu o arkuszu (po tekście D-27):
   > The dashboard offers the sheet for entries only once it has a current playable build of the branch (D-32). Never export, zip or stamp the game by hand (no `tools/release/stamp_build.js` on a task branch): in a dashboard run the dashboard makes the build after the run; in a terminal session without the dashboard, after the commit on the branch, run `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts build task_NN` (about a minute; it refuses while a dashboard run holds the lock).
4. `ai-task/SKILL.md`, „Spec tasks”, punkt „Report”, zamiast „with how to try it: the worktree in Godot, or merge from the dashboard ("Scal do master gry") or `git merge spec/…`”:
   > with how to try it: the playable build `build/do-ogrania/Everhorror-test-task<NN>-<sha7>-windows.zip` (the dashboard makes it after the run; in a terminal see step 6), then the sheet. Merging stays Roland's click ("Scal do master gry").
5. `ai-task/SKILL.md`, `fix NN` krok 5, na końcu:
   > The dashboard makes a new playable build of the branch head after the run (terminal: `cli.ts build task_NN`); the sheet waits for it.
6. `spec-sync/SKILL.md`, finalize, „Game repo”, nowy punkt po „Leave every human sheet …”:
   > Playable builds in `build/do-ogrania/` stay as they are (outside git; the dashboard keeps the two newest of a task).
7. `tools/README.md`, nowy rozdział przed „## Wydanie”, i zdanie na początku „Wydanie”:
   > ## Build do ogrania
   >
   > A playable build (D-32) is the game exported from one commit of a task branch (or master) without a version number, a CHANGELOG entry or a tag, so that a person plays the branch before the sheet. The spec dashboard makes it by itself after an implement or fix run that ended well, or on a click ("Zbuduj do ogrania"); in a terminal: `node ../specification/dashboard/cli.ts build task_NN` (or `master`), refused while a dashboard run holds the lock. It checks the commit out into a temporary worktree (`../everhorror-wt/_build-<sha7>-…`, removed afterwards) with the `.godot` import cache of the branch worktree (else of the main copy), runs `GODOT --headless --path <tmp> --import` and `--export-release "Windows Desktop" <out>`, and writes `build/do-ogrania/Everhorror-test-task<NN>-<sha7>-windows.zip` (Everhorror.exe, CZYTAJ_MNIE.txt, CHANGELOG.md, BUILD_DO_OGRANIA.txt) with a manifest `.json` and the Godot log `.log` next to it; the two newest builds of a task stay. It never runs `stamp_build.js`: the stamp would dirty a worktree and belongs to a release, so the main menu of a playable build shows the version of the last release. `EVERHORROR_GODOT`, `EVERHORROR_PLAYBUILDS_DIR` and `EVERHORROR_PLAYBUILD_AUTO=0` (no build after runs) change it. Details: `../specification/dashboard/ARCHITEKTURA.md`, "Build do ogrania (D-32)".

   W „## Wydanie”, po „Release steps (task_14; …)”: „A release is not a playable build (above): it has a version number, a CHANGELOG entry and a tag, and is made after the merge.”
8. `docs/human-tasks/INFO.md`:
   - wstęp, na końcu pierwszego akapitu: „Arkusz zadania z otwartą gałęzią przyjmuje wpisy w dashboardzie dopiero przy aktualnym buildzie do ogrania tej gałęzi (D-32, `build/do-ogrania/`); pisze go agent jak dotąd.”;
   - „Minimum ważności sesji gry”, punkt o „Dane sesji”, na końcu: „Build do ogrania pokazuje w menu numer ostatniego wydania, więc przy nim dopisz też nazwę ZIP-a (numer zadania i skrót commita).”

## Decyzje i założenia
- Kod powstawał w osobnej kopii `specification-praca` na gałęzi `agent/dashboard-ux`, z kopiami cząstkowymi na każde zadanie (D-29); koordynator przeglądał każdą gałąź i scalał ją sam. Do `master` specyfikacji całość weszła po odbiorze Rolanda (`2fc1858`, potem poprawka instrukcji `edb7932`).
- Polski jest językiem źródłowym; po polsku zostają treść specyfikacji, zadań i arkuszy, wartości zapisywane do plików, kontrakt agenta, zapisane wyniki audytu i komunikaty serwera (D-30, `dashboard/UI.md`).
- R3 (jeden pisarz buchalterii) zostało tylko planem w `dashboard/ARCHITEKTURA.md`: ścisła wersja zablokowałaby skille, gdyby polecenie nie objęło każdej edycji `WDROZENIA.md`, a tego nie da się sprawdzić bez prawdziwego agenta.
- Build do ogrania przed arkuszem (D-32) dołączył do zadania na prośbę Rolanda w trakcie prac (przez agenta T0-ux); przejrzany i scalony razem z resztą.
- Zmiany skilli i dokumentów gry, które zależały od nowego dashboardu, weszły dopiero po scaleniu do master (lista wyżej), żeby przebiegi nie odwoływały się do funkcji, których jeszcze nie było.

## Czego potrzebuję od Ciebie
- Decyzja: czy dopisać `../everhorror-wt` do `additionalDirectories` w `.claude/settings.json` gry (sesje terminalowe nie widzą dziś nowych kopii roboczych; to zmiana uprawnień, więc bez Twojego „tak” jej nie robię).
- Bez pośpiechu: R4 (dwa wdrożenia naraz) i R1 (reguła gałęzi `master` w GitHubie) czekają na Twoje decyzje.

## Test

Odbiór człowieka: arkusz [factcheck-test-19](../../human-tasks/done/factcheck-test-19.md): 15 × ✅, wiersz 3 💬 „Polskie nazwy można by poprawić, ale to low-priority” (zgłoszenie `zgloszenia/2026-10-27_czytelnosc-nazw.md`). Automat: `npm test` 2018/2018, `npm run e2e` 27/27, build, lint specyfikacji 0/0 (izolowane foldery tymczasowe).

## Podsumowanie
Dashboard jest dwujęzyczny (PL/EN) i ma jeden słowniczek nazw. Doszły do niego: werdykt przeglądu w oknie scalania, kontekst opcji w kartach decyzji, koszt i czytelny dziennik przebiegów, „Teraz” z wznawianiem i „Wyjaśnione”, arkusze kilku zadań i zamknięcie z ⏭, kopia robocza na każdą gałąź oraz build do ogrania przed arkuszem. Fałszywych „do wdrożenia” jest mniej, a testy nie dotykają prawdziwych przebiegów. Zostają: R3 (plan), R4 i R1 (decyzje Rolanda), zgłoszenie o czytelności polskich nazw (niski priorytet) i martwe zdanie zapasowe o `git switch -c` w kontrakcie wdrożenia (`src/work/runs.ts`), do usunięcia przy okazji task_22.
