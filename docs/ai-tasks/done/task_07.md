<!--
Zadanie zlecone w czacie (2026-09-25), nie przez plik. Requirements to dosłowny cytat prośby.
-->

Requirements:
Przeanalizuj obecne testy i sprawdź czy można usprawnić jakość testowania z poziomu twojego modelu i narzędzi MCP. DOciągnij ewentualnie sprawdzone i darmowe narzędzia MCP które mogą siie przydać i dołącz je do informacji dal agenta do claude.md i gdzie indziej potrzeba.

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza obecnych testów
Stan przed zadaniem (ok. 1500 linii w `tools/`):
- **Test dialogów** (85+ sprawdzeń) i **11 scenariuszy świata** z watchdogiem, wspólnym runnerem (`run_tests.sh`, linia RESULT na test, logi w `reports/tests/`) i świeżym strażnikiem SCRIPT ERROR — to solidny trzon.
- **Luki:**
  1. **Zero testów czystej logiki.** Trasy, polskie odmiany, pasma zdrowia, flagi z ładunkiem — testowane tylko „przy okazji” scenariuszy. Regresję tras z task_05 sprawdzał skrypt jednorazowy w brudnopisie.
  2. **Zero kontroli spójności danych.** Literówka w ID przedmiotu/zadania/notatki w rzadko odwiedzanej gałęzi dialogu przechodziła niezauważona, dopóki scenariusz nie wszedł dokładnie tam.
  3. **Rozkład dnia bez testu.** Marker sprawdzał się dopiero, gdy scenariusz trafił w konkretny dzień, godzinę i stan fabuły.
  4. **Prawdziwe wejście nietestowane.** Scenariusze sterują GameState/VN bezpośrednio — przypisania klawiszy (E, I, J, M), mysz i `ui_accept` nie przechodzą przez żaden test.
  5. GdUnit4 zainstalowany, ale martwy.

## Co zostało zrobione

### Trzy nowe warstwy testów (nasz wzorzec RESULT)
1. **`tools/unit_test.gd`** (~2 s, 29 sprawdzeń, bez świata): graf wypraw z kosztami (+rozpoznanie, +rana) i **utrwaloną regresją tras omijających zamknięte miejsca**, `plural`/`veins_acc`/`days_left_text`/`hours_text`, pasma i „podłoga” ran (zdrowy przeżywa z 1), flagi z ładunkiem (regresja wyjątku z dnia 3), licznik śladów Czternastego.
2. **`tools/data_lint.gd`** (~2 s): statyczny lint krzyżowy — każde ID przedmiotu, zadania, notatki, postaci i żyły użyte w dialogach, generatorach i reżyserze istnieje w rejestrach; każdy wpis zadania jest i zdefiniowany, i gdzieś logowany; każda rozmowa obozowa ma pożegnanie `[#leave]` (wyjątki: Welf i Hieronim, celowo).
3. **`tools/tests/test_schedule.gd`** (~3 s): cały tydzień rozstawień naraz — 7 dni × 5 pór × 5 stanów fabuły (baza, po Exitium, gorączka, Mirosław na krawędzi, odejścia) ≈ 2500 rozstawień: każdy marker istnieje, nikt nie stoi na cudzym; do tego stanowiska pracy w terenie i miejsce spotkania.

`run_tests.sh` mapuje nowe nazwy (`unit`, `lint`, `schedule`) i ma je w domyślnej liście przed scenariuszami (szybkie oblewają pierwsze).

### Błędy znalezione przez nowe testy w dniu ich powstania
- **Lint od razu zarobił na siebie:** wpis `goraczka/wywieziony` („Nasira wywieźli na górę…”) był zdefiniowany, ale **nigdy nielogowany** — gracz tracił wpis w notesie, a zadanie nie stawało się „nieudane”. Naprawione w rozliczeniu nocy + przykryte sprawdzeniem w scenariuszu `week`.
- **Test jednostkowy złapał moją własną wpadkę sprzed godziny:** toast czasu pokazywałby „−0,5 h h” (podwójne „h” po zmianie na `hours_text`). Naprawione.
- Lint wykrył też, że żyłę `west_1` obóz buduje inną ścieżką niż pozostałe — wykrywanie rozszerzone, spójność potwierdzona.

### Research narzędzi MCP (darmowe, sprawdzone)
- **Dołączony: [`godot-mcp-runtime`](https://github.com/Erodenn/godot-mcp-runtime)** (npm 3.8.1, MIT, TypeScript/Node — bezpieczny przy Smart App Control, 77★, aktywny). Wpisany do `.mcp.json` (`npx -y`, GODOT_PATH na okienkowy exe), paczka zweryfikowana i pobrana. **Zamyka lukę nr 4:** uruchamia prawdziwą grę (bez edytora i bez addonu — wstrzykuje tymczasowy autoload, po sobie sprząta), symuluje klawisze/mysz/kliknięcia w UI, robi zrzuty (podgląd inline + PNG), czyta żywe drzewo sceny, a w trybie `background` parkuje okno poza ekranem z zablokowanym fizycznym wejściem. Połączy się po restarcie sesji.
- **U już obecnego `godot-editor`** doprecyzowany toolset **`testing`** (asercje właściwości węzłów na żywo) obok `runtime`/`input`.
- **Odrzucone:** MCP dla GdUnit4 nie istnieje (jest tylko [propozycja](https://github.com/hi-godot/godot-ai/issues/776); headless CLI GdUnita ściga się z cache importu edytora — nie wpinam go do runnera, adnotacja w CLAUDE.md); serwery „computer-use”/automatyzacji pulpitu — niedojrzałe i ryzykowne przy Smart App Control; Playwright — tylko przeglądarki.

### Dokumentacja
`CLAUDE.md` (cztery warstwy testów, sekcja `godot-runtime`, `testing` w `godot-editor`, urealniona rola GdUnit4), `tools/README.md` (trzy nowe wiersze), specyfikacja (`08_technika.md` — warstwy + ścieżka E2E, wpis w `WDROZENIA.md`).

## Decyzje i założenia
- **Jeden wzorzec zamiast dwóch:** nie wpinam GdUnit4 do runnera — spójne skrypty RESULT są tym, co model prowadzi najpewniej, a GdUnit zostaje zespołowi do pracy w edytorze.
- **`godot-runtime` uzupełnia, nie zastępuje:** logika i regresje zostają w headless (szybkie, deterministyczne); MCP służy do wejścia, wizualiów i reprodukcji błędów sterowania.
- Lint traktuje Welfa i Hieronima jako wyjątki od `[#leave]` — w scenach terenowych każdy wybór ma kosztować (zgodnie z zasadą rozmów z task_06).

## Czego potrzebuję od Ciebie
1. **Restart sesji Claude Code**, żeby `godot-runtime` się połączył — wtedy mogę zrobić pierwszy dymny test wejścia (np. „M otwiera mapę w chodnikach”).
2. Factcheck: [factcheck-test-07](../../human-tasks/done/factcheck-test-07.md) (4 wiersze, ~15 min).

## Test
- `unit`: 29/29 · `lint`: 5/5 (po naprawie znalezisk) · `schedule`: 5/5 · `week` (rozszerzony o wywiezienie Nasira): przechodzi · `drudzy`: przechodzi. Pozostałych scenariuszy ta zmiana nie dotyka (mechanika gry bez zmian poza logowaniem `wywieziony`); pełny zestaw — przy następnej okazji za zgodą.
- Konfiguracja `.mcp.json` zwalidowana, paczka `godot-mcp-runtime` uruchomiona na stdio i zamknięta czysto.

## Test serwera godot-runtime (2026-09-26, po restarcie)
Pierwsza próba (25.09) padła: klient VS Code nie umie pokazać okna zgody MCP, więc serwer sam odrzucał `run_project`. Po ustawieniu `GODOT_MCP_DISABLE_ELICITATION=true` i restarcie test przeszedł, w trybie tła (okno poza ekranem, mysz i klawiatura użytkownika wolne):
- START kliknięty w menu → świat się wczytuje, wstęp przewija się Spacją, HUD wraca,
- Spacja w świecie nic nie robi (skoku nie ma),
- **M w obozie**: mapa się nie otwiera, tylko podpowiedź „[M] działa w chodnikach”,
- wyprawa do Starej sztolni (wywołanie jak z WYRUSZ) → dzień 1, 09:00,
- **M w chodniku**: mapa terenowa „Dokąd dalej?” z sąsiadami i czasem drogi; drugie M ją zamyka,
- I i J otwierają i zamykają ekwipunek i notes,
- log: zero błędów skryptów (tylko znane ostrzeżenia UID z zestawu kopalni); po zamknięciu serwer usunął swój autoload z `project.godot`.

## Build 0.4.1
Po zadaniu zbudowany **`build/Everhorror-demo-0.4.1-windows.zip`** (113 MB) z dwiema poprawkami znalezionymi przez nowe testy: komunikat czasu bez podwójnego „h” i nieudane zadanie „Gorączka Nasira” z wpisem w notesie po wywiezieniu. Test dymny exe: świat się wczytuje, zero błędów skryptów. 0.4 zostaje obok.

## Podsumowanie
Testowanie ma teraz cztery warstwy zamiast dwóch: logika (2 s), lint danych (2 s), dialogi i scenariusze — a lint pierwszego dnia znalazł prawdziwą dziurę w treści (przepadający wpis o wywiezieniu Nasira). Jedyną lukę, której headless nie pokryje — prawdziwe klawisze i mysz — zamyka dołączony darmowy serwer `godot-mcp-runtime` (Node/MIT, bez addonu, okno w tle); zacznie działać po restarcie sesji. Wszystko opisane w `CLAUDE.md`, `tools/README.md` i specyfikacji.

Źródła researchu: [godot-mcp-runtime (GitHub)](https://github.com/Erodenn/godot-mcp-runtime) · [mcpservers.org](https://mcpservers.org/servers/erodenn/godot-mcp-runtime) · [glama.ai — simulate_input](https://glama.ai/mcp/servers/Erodenn/godot-mcp-runtime/tools/simulate_input) · [propozycja GdUnit4-przez-MCP](https://github.com/hi-godot/godot-ai/issues/776) · [GdUnit4](https://github.com/godot-gdunit-labs/gdUnit4) · [hybridindie/godot-mcp](https://github.com/hybridindie/godot-mcp)
