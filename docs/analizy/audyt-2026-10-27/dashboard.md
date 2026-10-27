# Dashboard: produkt, wygląd, kod, bezpieczeństwo, koszt

> Audyt 2026-10-27 · część „dashboard” · autor: agent (Fable 5.1 high) z pomocnikiem do odczytu kodu (Opus 5.5), tylko odczyt · czytelnik: Roland
>
> Stan: `specification/dashboard` na `master` **`205cf18`** (task_24 scalone w trakcie audytu: kolejka startów, scalanie automatyczne D-35, `git merge-tree`, cache importu w nowych kopiach gałęzi). Pomocnik uruchomił raz `npm test`, `cli.ts lint`, `cli.ts status --json`, `tsc --noEmit` i kilka syntetycznych wywołań strażnika (`node node/runguard.ts <polityka>` z polityką w folderze tymczasowym). Zrzuty ekranu zrobiłem z własnej, tylko do odczytu instancji (`vite --port 5197`, `EVERHORROR_RUNS_DIR` = świeża kopia zapisów przebiegów, `EVERHORROR_AUTO_MERGE=0`, `EVERHORROR_PLAYBUILD_AUTO=0`), bezgłowym Edge przez CDP, 1440 px szerokości, PL i EN; pliki w `zrzuty/`. W tym samym czasie w prawdziwym dashboardzie trwał przebieg planowania (widać go na zrzutach jako „Trwa przebieg: planowanie zadań”). Nic nie klikałem poza nawigacją. **[Z]** oznacza założenie.

## 1. Co Roland widzi i robi

### 1.1 Zrzuty

| Plik | Widok | Co widać |
|---|---|---|
| `zrzuty/pl-start.png`, `en-start.png` | Start / Home | „Teraz” (5 pozycji + „i jeszcze 7 kroków”), pięć liczników, tabela działów, otwarte zgłoszenia, spójność, legenda znaczników |
| `zrzuty/pl-praca.png` | Praca | pasek repozytoriów, „Teraz” z 9 identycznymi „Analizuj zadanie (agent)”, „Do zaplanowania”, „Scalanie automatyczne”, „Kolejka startów (0)”, tablica 13 kart „Zaplanowane”, „Buildy do ogrania”, „Historia (20)” |
| `zrzuty/pl-zadanie-task20.png` | Strona zadania | pasek etapów, „Co można zrobić” (Wdróż wyszarzone: „zadania narzędziowe wdraża się w terminalu”), ramka „Wdróż w terminalu”, Wymagania, Arkusz, „Co napisał agent”, „Przebiegi tego zadania: 2 przebiegi, 4,11 USD” |
| `zrzuty/pl-zadanie-task24.png` | Strona zadania (narzędzia, bez analizy) | jak wyżej, bez treści agenta |
| `zrzuty/pl-przebiegi.png` | Przebiegi | „Teraz działa: Planowanie”, „Zajęte miejsca: analizy 0/3, wdrożenia 0/3…”, „Kolejka startów (0)”, „Ostatnie przebiegi: Wczytuję przebiegi…” |
| `zrzuty/pl-arkusz-17.png` | Arkusz (zamknięty) | baner „tylko do odczytu”, pasek „kompletny 2 z 2”, wiersze z przyciskami ✅/❌/💬/⏭ i polami uwag, tabela wyników automatu |
| `zrzuty/pl-zgloszenia.png` | Zgłoszenia | tablica: nowe 3 · w pracy 0 · pytanie 1 · zrobione 10 · odrzucone 0 |
| `zrzuty/pl-zmiany.png` | Zmiany | pusty koszyk, karta „Do zatwierdzenia (gałęzie zmiana/*)” z „Sprawdź zdalne gałęzie (git fetch)” |
| `zrzuty/pl-zatwierdz.png` | Zatwierdź zmiany | specyfikacja: nic do zatwierdzenia, 2 do wypchnięcia; gra: 11 nowych plików zadań (`task_25…35`) do zapisania, „21 innych zmienionych plików w kopii gry” |

### 1.2 Co działa dobrze (żeby nie wylać dziecka z kąpielą)

- **Jedno „Teraz”** z gotową listą kroków i przyciskiem przy każdym; pasek etapów na stronie zadania; liczniki miejsc dla przebiegów równoległych; „Kolejka startów” z „Analizuj wszystkie zaplanowane (9)”; ramka „Build do ogrania” z „Otwórz folder”; kontekst opcji przy kartach decyzji; przełącznik PL/EN w zasięgu wzroku; czytelna, spokojna typografia, karty z cienką ramką, jedna rodzina ikon tekstowych.
- Stan jest **wyliczany z plików i gita**, bez bazy (D-16); `WDROZENIA.md` ma jednego pisarza (R3); strażnik i audyt istnieją i działają (np. `analyze-16` złapał zmianę poza zakresem, choć fałszywie, zob. D8).

### 1.3 Ustalenia o produkcie i wyglądzie (U1…U10)

- **U1. „Teraz” powtarza to samo dziewięć razy** (`pl-praca.png`): dziewięć wierszy „Analizuj zadanie (agent) · task_2N — …” z osobnym „Uruchom…”, a dopiero niżej karta kolejki z „Analizuj wszystkie zaplanowane (9)”. Na Starcie to samo w skrócie plus „i jeszcze 7 kroków”. Propozycja: pozycje tego samego rodzaju składać do jednego wiersza „Analizuj 9 zaplanowanych zadań” z rozwijaną listą i jednym przyciskiem; osobno tylko to, co wymaga wyboru. „Teraz” ma pokazywać **najwyżej 5 pozycji, z czego decyzje Rolanda na górze** (dziś na górze jest informacja o trwającym przebiegu i dwa zapisy mechaniczne).
- **U2. Tablica zadań powiela „Teraz”**: 13 kart w kolumnie „Zaplanowane”, każda z własnym przyciskiem „Analizuj zadanie (agent)”, pięć kolumn pustych (W pracy, Na gałęzi, Scalone, Czeka na człowieka, Sprawdzone). Ten sam przycisk jest więc w trzech miejscach (Teraz, karta, strona zadania). Propozycja: karty bez przycisków (akcja na stronie zadania i w „Teraz”), a tablica zwinięta do liczników, gdy kolumna ma więcej niż 6 kart.
- **U3. Strona Praca jest za długa na jeden ekran decyzji**: ponad 3 200 px (zrzut jest przycięty) — pasek repozytoriów, Teraz, Do zaplanowania, Scalanie automatyczne, Kolejka, tablica, Buildy, Historia. Roland szuka „co ode mnie teraz” przewijając. Propozycja: Praca = „Teraz” + liczniki; reszta jako zakładki (Zadania, Automatyka, Buildy, Historia) albo osobne wpisy w menu (Kolejka już tam jest, ale prowadzi do raportu).
- **U4. Mechaniczne kroki wyglądają jak decyzje**: „Zapisz dokumenty w historii gry (9)”, „Wypchnij specyfikację (↑1)” stoją w „Teraz” obok decyzji projektowych, z tym samym wyglądem. `pl-zatwierdz.png`: 11 plików zadań utworzonych przez przebieg planowania czeka na ręczne zaznaczenie i commit. Propozycja: serwer zapisuje dokumenty po przebiegu sam (`proces.md` P8), a „Teraz” dzieli się na „Decyzje” i „Robię sam (N)”.
- **U5. Start ma niską gęstość informacji**: tabela „Działy” to w większości kropki (10 wierszy, 7 kolumn, 9 niepustych komórek), legenda znaczników zajmuje jedną trzecią ekranu i jest zawsze taka sama; „Otwarte zgłoszenia” powtarza Zgłoszenia. Propozycja: Start = „Teraz” (decyzje) + 5 liczników + koszt/limit subskrypcji dnia; działy i legenda do Instrukcji albo pod „więcej”.
- **U6. Tekst nieaktualny po D-33**: `pl-przebiegi.png` mówi „Naraz działa tylko jeden”, a dwie linie niżej „Zajęte miejsca: analizy i przeglądy kodu 0/3 · wdrożenia i poprawki 0/3”. `WORKFLOW.md` „Praca równoległa i konflikty” nadal mówi „jeden otwarty `spec/*`”. Propozycja: poprawka napisu i dokumentu (S).
- **U7. „Ostatnie przebiegi: Wczytuję przebiegi…”** po 3 s od wejścia (`pl-przebiegi.png`). **[Z]** Lista czyta 18 folderów z `events.jsonl` po 100–150 KB; przy setkach przebiegów będzie wolniej. Propozycja: indeks `runs.jsonl` dopisywany na końcu przebiegu (zob. długoterminowe 3) i stronicowanie.
- **U8. Arkusz zamknięty wygląda jak otwarty**: `pl-arkusz-17.png` ma baner „tylko do odczytu”, ale wiersze mają aktywne przyciski ✅/❌/💬/⏭ i pola tekstowe. Propozycja: w trybie odczytu wiersze jako tekst (wynik, uwagi), bez kontrolek.
- **U9. Ślady trybu zespołowego w trybie solo**: `pl-zmiany.png` karta „Do zatwierdzenia (gałęzie zmiana/*)” z „Sprawdź zdalne gałęzie (git fetch)” i „Opiekun działu otwiera, sprawdza i scala”; w menu „Zespół”; w tabeli działów kolumna „Opiekun” = Roland w każdym wierszu. Propozycja: ukryć za ustawieniem „tryb zespołowy” (kod zostaje, README mówi „gdy zespół wróci”).
- **U10. Koszt na stronie zadania jest zawyżony**: `pl-zadanie-task20.png` „2 przebiegi, 4,11 USD” = 2,55 + 1,56, a 2,55 to suma skumulowana rodzica i wznowienia; naprawdę 1,56 + 0,99 = 2,55 USD (zob. D4). Propozycja: liczyć z przyrostów; pokazać też „czekało na Ciebie: 2 h 13 min” (`proces.md` P14).

Dwujęzyczność (D-30): EN jest kompletne i spójne (`en-start.png`); nazwy działów i treści zostają polskie, zgodnie z decyzją. Koszt: katalogi `src/i18n/messages/*` to 285 KB (ok. 15 % kodu produkcyjnego), `UI.md` 24 KB reguł, każdy nowy napis pisany dwa razy i sprawdzany testem kompletności. Dla jednej osoby pracującej po polsku to dziś czysty koszt; tańszy wariant: EN z zapasem PL dla nowych napisów (ostrzeżenie zamiast błędu testu). To decyzja Rolanda (D-30 jest jego).

### 1.4 Kliknięcia w życiu zadania (z INSTRUKCJA §4–6 i zrzutów)

Około **35–45 kliknięć na zadanie**, z czego **ok. 5 to prawdziwe decyzje**: zmiana w specyfikacji, odpowiedzi na kartach, „zrób” (start wdrożenia), gra i arkusz, wydanie. Reszta to okna startu (model, wysiłek, budżet, tury, minuty, zgody), zapisy dokumentów (3–4 razy na zadanie), wypchnięcia, ręczne starty kolejnych etapów (analiza → wdrożenie → przegląd → domknięcie), przeniesienie arkusza. Szczegóły i propozycja łańcucha: `proces.md` §1 i P1.

## 2. Kod

### 2.1 Rozmiary i granice

| Plik | Linie | Rola |
|---|---|---|
| `node/runguard.ts` | 3 222 | tokenizer powłoki, ~140 zablokowanych poleceń, sprawdzacze git/node/Godot/sed/cp, sprawdzenie narzędzi zapisu, CLI hooka |
| `node/workspace.ts` | 2 422 | fakty o repozytoriach, commity po stronie serwera, scalanie, migawki |
| `src/work/runs.ts` | 2 314 | rodzaje i opcje przebiegów, kontrakt, argumenty, ustawienia, polityka, zagęszczanie strumienia, wynik, audyt (`compareSnapshots` ~640 linii) |
| `node/runner.ts` | 2 272 | rejestr blokad, spawn, ogon logu, anulowanie, odzyskiwanie, audyt |
| `src/views/Runs.tsx` | 1 978 | ~20 komponentów, 21 `useState` |
| `src/work/derive.ts` | 1 862 | czyste wyliczanie etapów, akcji i „Teraz” |
| `src/views/SheetForm.tsx` | 1 500 | formularz arkusza |
| `src/work/sheets.ts` | 1 391 | parser i edycje arkuszy |
| `node/work-api.ts` | 1 359 | trasy API |
| `src/views/WorkItem.tsx` | 1 233 | strona zadania |

Razem ok. 43 tys. linii kodu produkcyjnego (1,9 MB, z czego `src/i18n/messages/*` 285 KB) i ok. 25 tys. linii testów (1,5 MB). Warstwy są czyste i trzymają się: `src/spec` i `src/work` bez zależności i bez skutków ubocznych; `node/*` importuje z `src/` (np. `work-api.ts` 16 importów); **nie ma podwójnego parsowania Markdownu** między `src/` a `node/` (serwer używa tego samego `deriveWork()`); drobne duplikaty `fenceFlags`/`oneLine` w `tasks.ts:58/365` i `sheets.ts:75/103`. TypeScript w trybie strict (`noUnusedLocals`, `erasableSyntaxOnly`, `verbatimModuleSyntax`), `tsc --noEmit` w 0,78 s. Zależności: 5 w czasie działania, 29 paczek w `node_modules`. Martwy kod znikomy (18 eksportów nieużywanych nigdzie). Kod trybu zespołowego (`github.ts` 249 linii, `Team.tsx`, gałęzie `zmiana/*`) uśpiony celowo. `store.tsx`: jeden kontekst z ~17 `useState`, każde naciśnięcie klawisza w szkicu przerysowuje wszystkich odbiorców; plan §7 mówi „poprawiać, gdy zacznie przeszkadzać” i nic nie wskazuje, że już przeszkadza.

### 2.2 Testy i CI

- `npm test`: **2 137 zaliczonych, 0 błędów, 27 zestawów, 167 s** (ARCHITEKTURA.md:275 mówi „około minuty”). Najwolniejsze budują prawdziwe repozytoria git na test: „a worktree per branch (R2)” 31,7 s, „snapshots” 26,6 s, zamknięcie arkusza z pominięciem 12,5 s, ledger wieloprocesowy 11,7 s.
- Nietestowane automatycznie: widoki (ani jednego testu UI; ARCHITEKTURA.md:273 to przyznaje), trasy serwera tylko przez `security.test.ts` i e2e (`work.e2e.ts`, 105 KB), którego nie ma w `npm test` ani w CI.
- **CI** (`.github/workflows/spec-lint.yml`) uruchamia tylko `spec.test.ts`, `git.test.ts`, lint i build: ok. 2 100 z 2 137 testów (strażnik, runner, workspace, ledger, audyt) nigdy nie biegnie w CI, choć agenci wypychają kod dashboardu wprost do `master` specyfikacji (task_24 wylądował w trakcie tego audytu).

### 2.3 Osiem porządków według wartości/kosztu

| # | Co | Wartość | Koszt | Ryzyko |
|---|---|---|---|---|
| 1 | **Jedna tabela polityki na rodzaj przebiegu** zasilająca korzenie zapisu strażnika, `buildSettings` allow/deny, tekst kontraktu i `permissionKeys` (dziś cztery miejsca: `runguard.ts:999`, `runs.ts` `buildSettings`, kontrakt, `permissionKeys`; D5 i D2 to objawy) | wysoka | M | średnie (testy są) |
| 2 | Podział `runs.ts` po istniejących znacznikach sekcji: rodzaje/opcje, kontrakt (739–900), argumenty/ustawienia/polityka (900–1255), strumień/wynik (1255–1622), audyt (1622–2266); agent edytujący ten plik płaci za 2,3 tys. linii kontekstu | wysoka | S | niskie |
| 3 | Podział `runguard.ts`: tokenizer (239–750), tabele reguł, sprawdzacze per polecenie (git 2301–2920, node, Godot, sed, cp), narzędzia zapisu, CLI hooka | wysoka | M | średnie |
| 4 | Zadanie CI na `windows-latest` z `npm test` (~3 min) | wysoka | S | niskie |
| 5 | Szybsze testy: jedno repozytorium-szablon kopiowane `fs.cpSync` zamiast `git init` + commity w każdym teście (szacunek 167 → ~80 s) | średnia | M | niskie |
| 6 | Czyste pomocniki poza `Runs.tsx`, `WorkItem.tsx`, `SheetForm.tsx` i jeden test renderowania na widok | średnia | M | niskie |
| 7 | Wspólne `md.ts` (płotki, komentarze, końce linii) dla `tasks.ts` i `sheets.ts` | niska–średnia | S | niskie |
| 8 | `store.tsx` na trzy konteksty (sesja/źródło, szkice, indeksy) albo reducer — dopiero gdy zacznie przeszkadzać (plan §7) | niska dziś | M | średnie |

## 3. Model bezpieczeństwa

### 3.1 Jak decyduje strażnik

Hook `PreToolUse` na `Bash|Edit|Write|MultiEdit|NotebookEdit` (`runs.ts` `GUARD_MATCHER`), zamknięty przy błędzie (`onFailure: block`, `runguard.ts:3118–3138`); wywołania podagentów też przez niego przechodzą (implement-17: 34 wpisy strażnika przy 29 wywołaniach głównego wątku). Bash to w praktyce lista pozytywna: zachowawczy tokenizer blokuje wszystko, czego nie umie przeczytać (zmienne, nawiasy, krótkie nazwy 8.3, ścieżki urządzeń); do tego tabela ~140 zablokowanych poleceń (`runguard.ts:1255–1406`: powłoki, sieć, menedżery pakietów, interpretery, archiwizery, `ln`, `kill`); sprawdzacze per polecenie dla git, node, Godota, `run_tests.sh`, cp/mv/sed/sort/przekierowań. Git: tylko `-C <pełna ścieżka>`, `--no-pager`, `-P` (`2309–2338`); `-c`, `--git-dir`, `--work-tree`, `--exec-path` odrzucane; push bez force, bez `+`, bez usuwania, tylko `master`/`HEAD:master` (`2564–2585`); push gry odrzucony (sprawdzone sondą). Nie znaleziono obejścia przez spreparowaną ścieżkę `-C` (tożsamość repozytorium po granicach katalogów; `$ \` * ? ~ {` odrzucane). `pwsh`, `powershell`, `cmd`, zmienne środowiskowe, `export`: zablokowane. Narzędzia zapisu: strefy człowieka, bajtowo identyczne Wymagania, strefy „nigdy” (`dashboard/`, `.github`, `.claude`, `addons`, `.git`, folder przebiegu), cudze pliki zadań (`1085–1141`).

Narzędzia udostępniane przez `--tools` (`runs.ts:484–487`): plan/analyze/implement/fix: Read, Glob, Grep, Bash, Edit, Write, Agent; review: bez Edit/Write (+ StructuredOutput); finalize: bez Agent; próba: Read, Bash. `--permission-mode dontAsk` + `--permission-prompts none`: wszystko niezatwierdzone jest po cichu odrzucane (bezpieczne, ale każda odmowa to stracona tura: **20 odmów uprawnień i 13 blokad strażnika w 18 przebiegach**).

### 3.2 Luki sprawdzone sondami

- **(a) Ucieczka przez `node`: w każdym rodzaju przebiegu da się uruchomić dowolny kod (wymaga decyzji).** `checkNode` (`runguard.ts:2183–2212`) pozwala na `node <skrypt>` dla każdego skryptu w głównej kopii, kopii gałęzi i specyfikacji; `.claude/settings.json:9` z góry zatwierdza `Bash(node:*)`, a przebiegi ładują ustawienia projektu (`--setting-sources project`). Każdy rodzaj z prawem zapisu może taki skrypt stworzyć. Sonda z polityką `analyze`: `Write …/specification/zgloszenia/x.mjs` dozwolone (ustawienia przebiegu pozwalają też na `Edit(…/zgloszenia/**)`), potem `node …/zgloszenia/x.mjs` dozwolone. Taki skrypt może: wołać sieć, pisać poza trzema korzeniami (np. `~/.claude/settings.json`), wypchnąć grę przez Git Credential Manager, pobrać token z `GET /__spec/session` i wywołać `POST /work/merge` jako `who: "Roland"` (`work-api.ts:542`), czyli scalić i wypchnąć albo przełączyć scalanie automatyczne. ARCHITEKTURA.md:392 zostawia „skrypt Node robi to, co napisał autor” audytowi, ale audyt nie widzi sieci ani skutków poza korzeniami. Dla implement/fix/review wykonanie dowolnego kodu jest nieuniknione (testy i Godot `--script` na kodzie gałęzi); dla plan/analyze/finalize/review nie ma żadnej potrzeby skryptów pisanych przez agenta.
- **(b) Narzędzia zapisu ignorują korzenie zapisu per rodzaj (prawdziwy błąd, niskie ryzyko dzięki drugiej warstwie).** ARCHITEKTURA.md:387 mówi, że zapisy są dozwolone tylko w folderach rodzaju; w kodzie `inWriteRoots` (`runguard.ts:999`) jest używane tylko dla zapisów z powłoki, a `checkWriteTool` pozwala na każdą ścieżkę w trzech korzeniach poza strefami „nigdy”. Sonda: `Write` z `analyze` do `everhorror/script/x.gd` **dozwolone**, podczas gdy `echo > …/script/x.gd` zablokowane. Zatrzymuje to tylko lista `Edit(...)` w ustawieniach przebiegu, a audyt `MAIN_CODE` złapałby to po fakcie.
- **(c) Warstwa uprawnień Bash jest szeroka, więc strażnik jest prawdziwą bramką.** Ustawienia przebiegu pozwalają tylko na `cd`, `echo`, `pwd`, `sort`, `uniq`, `cut`, `tr`, ale ustawienia projektu dodają `git:*`, `node:*`, Godota, `mkdir`, `cp -r`, `ls`, `cat`. Reguły `deny` w ustawieniach przebiegu (np. `Bash(git switch *)`) nie pasują do wymaganej formy `git -C <ścieżka> switch`; są ozdobne (ARCHITEKTURA.md:352 to przyznaje).
- **(d) Sprzeczności kontraktu i strażnika (prawdziwy problem teraz):** (1) kontrakt zabrania `cd … &&` (`runs.ts:863`), strażnik wymaga `cd <kopia> && tools/run_tests.sh <nazwy>` (`runguard.ts:2286`), a warstwa uprawnień odrzuca `cd … && mkdir … && Godot`; (2) kontrakt mówi „git push” (`runs.ts:795`), strażnik odrzuca goły push i podpowiada `origin` (`:2577`), a zdalne repozytorium nazywa się `everhorror-spec`: pięć z sześciu przebiegów z pushem straciło 1–2 tury (np. `finalize-16`: blokada, potem `fatal: 'origin' does not appear…`, potem sukces). Skutek: review-17 o 14:28 nie mógł uruchomić żadnego testu (`run.json` `result.structured.ustalenia[0]`: „Bash dla Godota i tools/run_tests.sh był zablokowany… również dla podagenta test-runner”) i mimo to dał **„gotowe”** ze wszystkimi wymaganiami „spełnione”.

### 3.3 Audyt po przebiegu (`workspace.ts:2320–2349`)

Obejmuje: na drzewo gałąź, HEAD i brudne ścieżki ze statusem; refy `spec/*`; rzuty stref człowieka i stan każdego arkusza i karty; Wymagania otwartych zadań; nowe commity specyfikacji i lint. Nie obejmuje: zmian treści plików brudnych już przed przebiegiem (tylko ścieżki, bez skrótów), ścieżek ignorowanych (`.godot/`, ZIP-y w `build/do-ogrania/`, `reports/`, folder raportów w `%APPDATA%`), niczego poza trzema korzeniami, stanu zdalnego (push nie rusza lokalnych refów), konfiguracji gita. Fałszywy alarm: `analyze-16` skończył jako „naruszenie” (`MAIN_CODE`), bo `docs/analizy/final-plan-human-readable.md` edytowała równolegle inna sesja; po D-35 taki alarm blokuje scalanie automatyczne, dopóki ktoś go nie wyjaśni.

### 3.4 Blokady, wyścigi, HTTP

- Blokady tworzone z `wx`; żywa tylko przy żywym pid i (Windows) zgodnej nazwie obrazu z `tasklist` (`runner.ts:664–679`); zakończony zapis nigdy nie jest żywy (`runner.ts:1165`). Pid odzyskany przez inny `claude.exe` (np. sesja interaktywna Rolanda) przechodzi test obrazu, a anulowanie albo timeout zabiłyby cudze drzewo procesów (`runner.ts:456–460` porównuje tylko nazwę obrazu). Mało prawdopodobne; poprawka: zapisywać i porównywać też czas utworzenia procesu.
- Blokada commitów specyfikacji i ledgera (`everhorror-ledger.lock` w `.git`, `O_EXCL`, nieświeża po 60 s albo martwym pid): dobra między pisarzami dashboardu; sesje terminalowe ją omijają (udokumentowane). `touched-spec.log` jest pisany tylko dla Edit/Write (`runguard.ts:3179`): zapis z powłoki do specyfikacji (dozwolony dla plan, implement, fix, finalize) nie jest logowany, więc `cli.ts commit` mógłby zabrać niedokończony plik innego przebiegu.
- HTTP: tylko loopback, dokładny `Host` (przeciw DNS rebinding), kontrola `Origin` i `Sec-Fetch-Site`, mutacje tylko JSON, token sesji do mutacji i odczytu `/work` i `/runs` (`security.ts:77–114`): CSRF z innej strony zamknięty. **Brak uwierzytelnienia użytkownika**: aktor to pole `who` w treści żądania (`work-api.ts:369ff`, `requireAdmin` `:542`), hasło administratora sprawdzane po stronie klienta i puste (D-21). Każdy lokalny proces, w tym skrypt node z przebiegu, może być „Rolandem”. Do przyjęcia dla narzędzia solo na localhost, poza połączeniem z luką (a). Przejście ścieżek sprawdzone wyrywkowo (`REV_PATTERN` `load.ts:70`, `isSpecPath` z odrzuceniem `..` `git.ts:148`, `isRunId` `runner.ts:1911, 2047, 2066`): dziur nie znaleziono.

### 3.5 Scalanie automatyczne (task_24, D-35)

Bramki w `src/work/automerge.ts`: przełącznik włączony; etap „na gałęzi”; brak przebiegu na zadaniu; przegląd „gotowe” przypięty do HEAD gałęzi, wszystkie wymagania spełnione, bez ustaleń „błąd”; ostatni przebieg kodu `STATUS: ok`; aktualny build HEAD; `git merge-tree` czysty; część arkusza wypełniona bez ❌/⏭/zwolnienia; znany podpisujący; brak niewyjaśnionego naruszenia; akcja scalania otwarta; brak uruchomionego edytora Godota. Potem push `master`. Co może scalić złą gałąź: (1) **„testy przeszły” pochodzi od modelu** (`automerge.ts:225–231`: `STATUS: ok` agenta plus JSON przeglądu; żadnego uruchomienia testów przez serwer; review-17 wyżej dał „gotowe” bez żadnego testu); (2) **arkusz nie jest związany z commitem, w który zagrano** (`automerge.ts:240–270` nie porównuje czasu podpisu arkusza ani builda z HEAD): arkusz ✅ → przegląd prosi o poprawki jakości → poprawki → nowy build → nowy przegląd „gotowe” → scalenie i push kodu, w który nikt nie grał; (3) skrypt node z przebiegu spełnia każdą bramkę (luka a).

### 3.6 Klasyfikacja

| Ustalenie | Klasa |
|---|---|
| Ucieczka przez node (a); bramka testów i związanie arkusza z commitem w scalaniu automatycznym | **wymaga decyzji Rolanda** |
| Błąd korzeni zapisu (b); sprzeczności kontrakt/strażnik (d); fałszywy `MAIN_CODE`; nielogowane zapisy z powłoki w specyfikacji | **prawdziwe teraz, tanie do naprawy** |
| Brak uwierzytelnienia w API; odzyskany pid; omijanie blokady ledgera przez terminal; push do `master` specyfikacji | **do przyjęcia dla narzędzia solo** |

## 4. Koszt działania (18 przebiegów, 2026-10-27)

Ceny użyte do rozliczenia co do centa z `costUSD` Claude Code: Opus 5.5 wejście 4 USD/MTok, wyjście 20, odczyt cache 0,20, zapis cache 1 h 8; Sonnet 5.5: 2 / 10 / 0,10 / 4. Każdy przebieg zapisuje cache z czasem życia **1 h**. `apiKeySource: none`: to przebiegi na subskrypcji, więc dolary są szacunkiem po cenniku; prawdziwym ograniczeniem jest limit (`rate_limit_event`: wykorzystanie 7-dniowe 0,27 → 0,39 w ciągu dnia, łącznie z pracą poza dashboardem).

| Rodzaj | n | Średnio USD (zakres) | Tury | Min | Odczyt cache | Zapis cache | Wyjście | Udział zapisu cache w koszcie | Udział „rozruchu” |
|---|---|---|---|---|---|---|---|---|---|
| plan | 2 | 2,02 (0,88–3,16) | 39 | 4,6 | 2,77 M | 145 k | 25 k | 48 % | 16 % |
| analyze (świeża) | 6 | 1,19 (0,55–2,21) | 33 | 3,2 | 1,16 M | 73 k | 18 k | 49 % | 19 % |
| analyze (wznowienie) | 3 | 0,93 (0,64–1,17) | 9 | 0,7 | ~0,3 M | ~96 k | 18 k | 82 % | **80 %** |
| implement | 2 | 0,72 (0,56–0,88) | 48 | 5,9 | 1,71 M | 106 k | 18 k | 51 % | 20 % |
| review | 3 | 0,59 (0,55–0,63) | 21 | 1,6 | 0,43 M | 56 k | 6 k | 66 % | 39 % |
| finalize | 2 | 0,22 | 25 | 0,7 | 0,31 M | 36 k | 4 k | 67 % | 40 % |

**Suma rzeczywista: 17,61 USD; dashboard pokazałby 22,32 USD (+27 %)**, bo dla przebiegów wznowionych (`--resume --fork-session`) zapisuje skumulowany `total_cost_usd` rodzica i dziecka (`runs.ts:1407/1572`; 1,56 + 0,99 = 2,55 itd.). „Rozruch” to prefiks pierwszego wywołania (17–24 tys. tokenów): kontrakt 3,7–4,7 KB (~1,3–1,6 tys. tokenów), `CLAUDE.md` 11,2 KB (~3,5 tys.), pełny `ai-task/SKILL.md` 22 KB rozwinięty przez polecenie skilla (~6,5 tys.), prompt systemowy Claude Code ze schematami narzędzi i listą skilli i agentów (~11 tys.; `init` nie niesie treści promptu, więc to szacunek). Między przebiegami wspólne jest tylko ok. 6,6 tys. tokenów prefiksu, i to tylko w ciągu godziny i z tym samym modelem i zestawem narzędzi. **Uwaga:** wszystkie zmierzone przebiegi szły na wysiłku *medium*, a domyślne są teraz *high* (`runs.ts` `defaults('opus','high',…)`, D-18); jedyna analiza na *high* kosztowała 2,21 USD.

Cykl zadania dziś: task_16 2,82 USD, task_17 2,49 USD (z drugim przeglądem); z udziałem planowania ~0,5 i kartą decyzji ~0,9 wychodzi **ok. 3,0–4,1 USD**.

| Kontrola kosztu | Oszczędność na cykl | Uwagi |
|---|---|---|
| Poprawne liczenie wznowień (suma przyrostów) | 0 realnie; sumy uczciwsze o 27 % | S |
| Bez `--resume` dla odpowiedzi z kart: serwer dopisuje decyzję przy „Rozstrzygnij”, albo świeży przebieg Sonnet low, który czyta kartę | ~0,6–0,9 na kartę | 16 % dnia |
| Domknięcie deterministyczne na serwerze (operacja `ledger finalize`, zdjęcie znaczników dla ID z wiersza, `git mv`) albo Haiku 5.5 | ~0,20 i jeden klik | |
| Pominięcie drugiego przeglądu, gdy `reviewedSha == head` i „gotowe” | ~0,6, gdy się zdarza | 1 z 2 zadań dziś |
| Analiza i przegląd na *medium*, chyba że Roland wybierze *high* | ~0,3–1 | niezmierzone; decyzja D-18 |
| Poprawki kontrakt/strażnik (nazwa zdalnego, forma `run_tests`) | 2–4 tury na przebieg zapisujący, ~0,05–0,1 | także czas |
| Skill `ai-task` podzielony na tryby (~5 tys. tokenów prefiksu mniej) | ~0,07 na przebieg Opusa, ~0,2 na cykl | |
| Cache 5 min dla `-p`, jeśli Claude Code to udostępnia (zapisy to 48–67 % kosztu; 1 h = 2× wejście, 5 min = 1,25×) | ~20 % sumy, ~0,6 | **[Z]** nie sprawdzono, czy da się ustawić |
| Zmienne linie kontraktu (id, czas, limity, uwaga) na koniec promptu | małe | prompt systemowy Claude Code i tak się zmienia |
| Budżet i limit tur per rodzaj ok. 3× obserwowanego maksimum: analyze 4 USD/80 tur, review 2/60, finalize 1/40, implement 8/150 (dziś 15–50 USD i 150–400 tur) | tylko ucina ucieczki | `--max-budget-usd` przy wznowieniu może liczyć kumulatywnie **[Z]** |
| Łączenie analiz w jeden przebieg | niezalecane | ~0,15 oszczędności prefiksu, a łamie „jeden wykonawca na zadanie” |

Już jest: kolumna kosztu (`Runs.tsx:1148`) i sumy dnia/7 dni (`RunTotals.tsx`). Brakuje: budżetu na zadanie, podziału zapis/odczyt/wyjście, procentu limitu subskrypcji z `rate_limit_event`. **Szacunek łączny:** cykl bez karty z ~3,2 do ~2,0–2,3 USD, z kartą z ~4,1 do ~2,2 USD (30–45 %).

## 5. Łatwe zyski dashboardu (każdy do 2 h dla Haiku/Sonneta)

| ID | Co | Wartość | Koszt | Ryzyko |
|---|---|---|---|---|
| D-E1 | Koszt wznowień: suma `model_usage_since_last_result` zamiast `total_cost_usd` (`runs.ts:1407/1572`) + test na dzisiejszych trzech `events.jsonl` | uczciwe sumy (−27 % dziś) | 30 min | niskie |
| D-E2 | Zgodność kontraktu i strażnika: kontrakt podaje prawdziwy push (`git -C <spec> push everhorror-spec master`, z `git remote`), strażnik podpowiada prawdziwą nazwę zdalnego; kontrakt wprost dopuszcza jeden łańcuch `cd <kopia> && tools/run_tests.sh <nazwy>`, a ustawienia przebiegu dodają na to regułę allow | mniej straconych tur; przeglądy naprawdę uruchamiają testy | 1 h | niskie |
| D-E3 | `checkWriteTool` też egzekwuje `inWriteRoots` (`runguard.ts:1085` z `:999`); ARCHITEKTURA.md:387 zgodna z kodem | zamyka lukę (b) | 1 h | niskie |
| D-E4 | W plan, analyze, finalize i review `node` tylko dla `<spec>/dashboard/cli.ts` i śledzonych, niezmienionych `tools/*.js` gry (`git ls-files` i `git diff --quiet`) | zamyka lukę (a) dla 4 z 7 rodzajów | 1,5 h | niskie–średnie |
| D-E5 | Domyślne budżety i limity tur per rodzaj ok. 3× obserwowanego maksimum | ucina ucieczki | 20 min | niskie |
| D-E6 | Bramka „Przegląd kodu”, gdy ostatni werdykt „gotowe” jest przypięty do bieżącego HEAD (z ręcznym nadpisaniem) | ~0,6 USD na uniknięty przegląd | 1 h | niskie |
| D-E7 | `node dashboard/cli.ts teraz [--json]`: `buildWorkState` + `deriveWork` przefiltrowane do `needs-you` | „co ode mnie” w terminalu i podstawa dla U1/U4 | 1,5 h | niskie |
| D-E8 | Wykorzystanie subskrypcji (5 h i 7 dni z `rate_limit_event`) w Przebiegach + suma kosztu na zadanie z miękkim budżetem (poprawia U10) | pokazuje prawdziwy limit | 1,5 h | niskie |
| D-E9 | Audyt: zmiany w głównej kopii pod `docs/**` poza ai-tasks/human-tasks jako ostrzeżenie, nie `MAIN_CODE` | koniec fałszywych „naruszeń” blokujących D-35 | 45 min | niskie |
| D-E10 | Logowanie zapisów z powłoki do specyfikacji w `touched-spec.log` (przekierowania, cp, mv, sed -i) | zamyka wyścig commitów równoległych | 1 h | niskie |
| D-E11 | Domknięcie domyślnie na Haiku 5.5 (deterministyczne domknięcie serwerowe jako większy krok) | −0,2 USD na cykl | 15 min | średnie (jakość operacji ledgera) |
| D-E12 | CI na `windows-latest` z `npm test` | łapie regresje strażnika i runnera | 30 min | niskie |
| D-E13 | Napis w Przebiegach po D-33 („naraz działa tylko jeden” → liczniki miejsc), `WORKFLOW.md` „jeden otwarty spec/*” (U6) | zgodność tekstu z kodem | 20 min | brak |
| D-E14 | Arkusz zamknięty w trybie odczytu bez kontrolek (U8) | mniej pomyłek | 1 h | niskie |

## 6. Zmiany długoterminowe dashboardu

1. **Strażnik jako dane polityki + silnik.** Jedna tabela per rodzaj (korzenie zapisu, dozwolone podpolecenia gita, operacje ledgera, skrypty node, prawa do Godota) generuje `buildSettings` allow/deny, decyzje strażnika, tekst kontraktu i `permissionKeys`; silnik (tokenizer, ścieżki, sprawdzacze) zostaje kodem. Dziś cztery źródła prawdy; D5 i D2 to objawy. Koszt M (1–2 dni), ryzyko średnie (krytyczne dla bezpieczeństwa; 2 963 linii testów strażnika już jest). Dotyka D-16, D-17, D-33.
2. **Granica systemu operacyjnego zamiast strażnika dla rodzajów z kodem.** `claude` dla implement/fix/review pod ograniczonym kontem Windows albo AppContainer (bez sieci, zapis tylko w kopii gałęzi, bez praw do głównej kopii, specyfikacji i profilu użytkownika) albo w WSL z podmontowaną kopią. Powód: wykonanie dowolnego kodu przez testy jest nieuniknione, a strażnik na wyrażeniach regularnych go nie powstrzyma. Koszt L, ryzyko wysokie (Godot, poświadczenia gita, eksport na GPU). Warunek: decyzja Rolanda o modelu zagrożeń. Dotyka D-16, D-19.
3. **Indeks przebiegów i panel kosztu.** Dopisywany `runs.jsonl` na końcu przebiegu: koszt przyrostowy, tokeny zapis/odczyt/wyjście, procent limitu, rodzaj, zadanie, model, wysiłek, stracone tury (odmowy i blokady). Zasila budżety na zadanie, domyślne per rodzaj dostrojone z danych, widok limitu dnia i szybką listę przebiegów (U7). Koszt S–M, ryzyko niskie. Dotyka D-18.
4. **Testy i wydanie po stronie serwera** (`proces.md` P5, P16): serwer uruchamia `tools/run_tests.sh` w tymczasowej kopii builda i zapisuje wynik w manifeście; zapis arkusza notuje sha builda, w który zagrano; scalanie automatyczne wymaga „sha arkusza = HEAD” i zielonego wyniku serwera (zamyka D3). Przycisk „Wydanie x.y.z”.
5. **Punkt danych dla widoku grafowego** (`cli.ts graph --json` / `GET /__spec/graph`): z istniejących `SpecIndex`, `WorkState` i ledgera serwer tanio wystawi węzły (zasady z id, znacznikiem, plikiem, sekcją; karty i zgłoszenia; zadania; gałęzie; arkusze; buildy) i krawędzie (wzmianki zasad — wyciąganie wzmianek już jest, `mentions.test.ts`; zadanie → ID z „W zadaniach”; karta → zadanie; zadanie → gałąź, arkusz, build; build → commit). Graf przepływu gry (sceny, gałęzie `.dialogue`, questy) wymaga nowego eksportera po stronie gry (M–L); projekt: `widok-grafowy.md`.
6. **Lekkie hooki projektu dla sesji terminalowych** w `.claude/settings.json` gry: tylko reguła jednego pisarza ledgera i ochrona stref człowieka, przełączane obecnością `EVERHORROR_DASHBOARD_RUN`. Zamyka lukę z ARCHITEKTURA.md:458 („w terminalu nic nie powstrzymuje”). Koszt S–M; ryzyko: spowolnienie pracy interaktywnej Rolanda (hook zamknięty przy błędzie). Dotyka „Hard rules” w `CLAUDE.md`.
7. **Kontrole w stylu CI dla specyfikacji i cache `.godot`.** Hook pre-commit w specyfikacji z `cli.ts lint` (0,34 s) i kontrolą linków; pełne `npm test` w CI. Osobno: kopie `.godot` per gałąź (ok. 340 MB każda, `everhorror/.godot` 341 MB, `everhorror-wdrozenie/.godot` 340 MB), a buildy kopiują je jeszcze raz; opcje: kopie blokowe na Dev Drive (ReFS) albo jeden wspólny import na commit master. Przenośność cache Godota między ścieżkami to założenie do sprawdzenia najpierw. Koszt M, ryzyko średnie.

## 7. Dziesięć najważniejszych ustaleń (D1…D10)

| ID | Waga | Dowód | Propozycja |
|---|---|---|---|
| **D1** | wysoka (decyzja) | `runguard.ts:2183–2212` pozwala na `node <skrypt>` dla każdego skryptu w trzech korzeniach; `.claude/settings.json:9` zatwierdza `Bash(node:*)`; sonda: analyze może zapisać `zgloszenia/x.mjs` i go uruchomić; skrypt dociera do `GET /session`, potem `POST /work/merge` jako `who: "Roland"` (`work-api.ts:542`), może wypchnąć grę albo pisać w `~/.claude` | D-E4 teraz; decyzja, czy scalanie, push i przełącznik scalania automatycznego mają wymagać sekretu po stronie serwera, którego agent nie przeczyta; długoterminowo opcja 2 |
| **D2** | wysoka (teraz) | kontrakt zabrania `cd … &&` (`runs.ts:863`), strażnik go wymaga dla `run_tests.sh` (`runguard.ts:2286`); kontrakt „git push”, strażnik wymaga zdalnego i gałęzi i podpowiada `origin` (`:2577`), a zdalne to `everhorror-spec`; 33 stracone wywołania w 18 przebiegach; review-17 (14:28) nie uruchomił testów i dał „gotowe” | D-E2 |
| **D3** | wysoka (decyzja) | D-35: „testy przeszły” pochodzi od modelu (`automerge.ts:225–231`), arkusz nie jest związany z commitem, w który zagrano (`:240–270`): poprawki + nowy przegląd po arkuszu = scalony i wypchnięty kod bez gry | serwer uruchamia `tools/run_tests.sh unit lint <scenariusze>` w tymczasowej kopii builda i zapisuje wynik w manifeście; zapis arkusza notuje sha builda; scalanie wymaga sha arkusza = HEAD |
| **D4** | średnia (teraz) | wznowione przebiegi zapisują skumulowany `total_cost_usd` (`runs.ts:1407/1572`); dzień pokazuje 22,32 USD wobec 17,61; strona zadania „4,11 USD” (`zrzuty/pl-zadanie-task20.png`) | D-E1 |
| **D5** | średnia (teraz) | narzędzia zapisu pomijają `inWriteRoots` (`runguard.ts:1085–1141` wobec `:999`), wbrew ARCHITEKTURA.md:387; sonda: Write z analyze do `script/x.gd` w głównej kopii przeszedł przez strażnika | D-E3, potem opcja 1 |
| **D6** | średnia (koszt) | wznowienia po kartach to ~80 % ponownego zapisu starej rozmowy: 62–105 tys. tokenów po 8 USD/MTok, bo przerwa > 1 h i nowy prompt systemowy; 2,80 z 17,61 USD dnia | odpowiedzi z kart dopisywane deterministycznie albo świeży przebieg Sonnet low; bez `--resume` |
| **D7** | średnia (koszt) | zapisy cache to 48–67 % kosztu każdego przebiegu, wszystkie z czasem życia 1 h; tylko 6,6 tys. z ~22 tys. tokenów prefiksu jest wspólne między przebiegami; domyślne przeszły na *high* | sprawdzić sterowanie czasem życia cache 5 min **[Z]**; skill per tryb; budżety per rodzaj; *medium* tam, gdzie jakość się trzyma (Roland, D-18) |
| **D8** | średnia (jakość) | `analyze-16` „naruszenie” z powodu pliku `docs/analizy/…` edytowanego przez człowieka (`run.json` audyt `MAIN_CODE`); migawka trzyma brudne ścieżki bez skrótu treści i pomija ścieżki ignorowane i spoza korzeni (`workspace.ts:2320–2349`); po D-35 naruszenie blokuje scalanie | D-E9; skróty brudnych plików w migawce (S) |
| **D9** | średnia (proces) | CI uruchamia tylko `spec.test.ts`, `git.test.ts` i build (`spec-lint.yml`); ~2 100 testów (strażnik, runner, workspace, ledger, audyt) nigdy w CI, a agenci wypychają kod do `master` specyfikacji; lokalne `npm test` 167 s, dokumentacja mówi „około minuty” | D-E12; repozytorium-szablon dla testów (porządek 5) |
| **D10** | niska–średnia (utrzymanie, tokeny agentów) | `runguard.ts` 3 222, `workspace.ts` 2 422, `runs.ts` 2 314, `runner.ts` 2 272, `Runs.tsx` 1 978 linii; agent czyta je przy każdej zmianie; hook strażnika ~240 ms na wywołanie (start node + zdejmowanie typów ze 142 KB) | podział po znacznikach sekcji (porządki 2 i 3); opcjonalnie gotowy `runguard.js` bez typów |

**Dokumentacja a kod rozjeżdżają się w czterech miejscach:** ARCHITEKTURA.md:387 (zapisy ograniczone per rodzaj; kod tego nie robi dla narzędzi zapisu), ARCHITEKTURA.md:275 (`npm test` „około minuty”; zmierzone 167 s), tekst kontraktu a reguły strażnika (`cd`, push), `WORKFLOW.md` „jeden otwarty `spec/*`” wobec D-33 (i napis w Przebiegach, U6).

## Źródła

`specification/dashboard/node/{runguard,runner,workspace,work-api,security,server,automerge,automation-base,queue,playbuild,speccommit,ledger,load,git}.ts`, `src/work/{runs,derive,sheets,tasks,automerge,parallel}.ts`, `src/views/{Runs,WorkItem,SheetForm,Work}.tsx`, `src/data/store.tsx`, `src/i18n/messages/*`, `package.json`, `vite.config.ts`, `.github/workflows/spec-lint.yml`; `dashboard/ARCHITEKTURA.md`, `INSTRUKCJA.md`, `UI.md`, `README.md`; `everhorror/reports/dashboard-runs/*/{run.json,events.jsonl,contract.md,guard.log,policy.json,settings.json}`; `everhorror/.claude/settings.json`; `docs/ai-tasks/done/task_19.md`, `done/task_23.md`, `task_24.md`; plan D-16…D-21, D-27, D-28, D-30, D-32…D-35, §7; zrzuty `zrzuty/*.png` (2026-10-27, ok. 20:30).
