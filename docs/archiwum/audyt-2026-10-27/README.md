# Audyt Everhorror 2026-10-27: gra, dashboard, proces — i plan na następny poziom

> Dla: Rolanda · Przygotował: agent (Fable 5.1 high) z trzema pomocnikami do odczytu (Opus 5.5 ×2, Fable 5.1 ×1) · tylko odczyt wszystkich repozytoriów; jedyny zapis to ten folder.
>
> Pliki: **ten plan** · [gra.md](gra.md) (kod, dane, testy, wydajność, demo; G1…G10, G-E1…12) · [dashboard.md](dashboard.md) (produkt i wygląd U1…U10, kod, bezpieczeństwo D1…D10, koszt, D-E1…14) · [proces.md](proces.md) (ścieżka zadania, czas i uwaga Rolanda, P1…P16) · [widok-grafowy.md](widok-grafowy.md) (research i projekt grafu przepływu gry) · `zrzuty/` (18 zrzutów dashboardu PL/EN).
>
> W trakcie audytu dashboard był w użyciu (przebieg planowania o 20:26 utworzył task_25…35; task_24 trafiło do `master` specyfikacji `205cf18`; `CLAUDE.md` gry dostał zapis o D-35). Liczby i numery linii są z 2026-10-27 wieczorem. **[Z]** w plikach szczegółowych oznacza założenie.

## Jeden ekran

| Obszar | Stan | Najważniejsze | Pierwszy krok |
|---|---|---|---|
| **Gra** | 0.5.4, 5 warstw testów zielone, generatory = źródło (sprawdzone), 31/165 ID reguł w kodzie | logika nocy i poranka w 710-liniowym `story_director.gd` bez testu całości; 3 systemy kluczowane polskim tekstem (blokada EN); 91 świateł bez zasięgów; testy dzielą folder zapisów z grą | G-E1 osobny folder zapisów dla testów; task_20 „złoty tydzień” z poprawkami z `gra.md` §3 |
| **Dashboard** | 43 tys. linii, 2 137 testów zielonych, strażnik + audyt, kolejka i scalanie automatyczne (D-35) od dziś | 35–45 kliknięć na zadanie, ~5 to decyzje; „testy przeszły” w D-35 mówi model, nie serwer; kontrakt i strażnik przeczą sobie (33 stracone tury); ucieczka przez `node` | D-E2 zgodność kontraktu i strażnika; D-E4 `node` tylko dla śledzonych skryptów; testy po stronie serwera |
| **Proces** | 18 przebiegów dnia: 49 min modelu, 9,5 h przerw; 17,61 USD (dashboard pokazuje 22,32) | uwaga Rolanda jest wąskim gardłem; wznowienie po karcie kosztuje tyle co analiza; arkusz wymagany od zmiany dwóch zdań; reguły przebiegu w 4 miejscach | P2 „Wznów” bez `--resume`; P3 poziomy zadań; P11 krótki plan |
| **Widok grafowy** | niema; plan §5 mówi „bez grafu relacji” | da się zrobić jako widok pochodny (bez bazy, bez ręcznej edycji) z istniejących parserów + eksporter Godota ~2 s; ~700 węzłów | decyzja o §5, potem faza 0 (jeden wieczór) |

## Gdzie stoi projekt (jedna strona)

- **Gra** ma spójną pętlę tygodnia, 15 postaci, 15 questów, 25 żył, 19 plików dialogów (~1 540 linii), 15 scenariuszy świata i 4 warstwy czystych testów; wszystkie zielone, pełny zestaw ~4 min. Dane i sceny są generowane i zgodne z generatorami (sprawdzone regeneracją do folderu tymczasowego). Słabości są znane z planu i potwierdzone w kodzie: bohater prawie nie schodzi „na krawędź”, horror jest w tekście, noce to literały w kodzie. Nowe w tym audycie: przyczyna połykanego załamania w nocy (`_busy` w `_sleep` zjada sygnał, `gra.md` G2), trzy systemy kluczowane polskim tekstem (G3), bot balansu kopiujący reguły gry (G5), testy dzielące folder zapisów z grą i z kopiami gałęzi (G1), 91 świateł bez zasięgów (G6), eksport „wszystkie zasoby” z 43 nieużywanymi modelami (G7).
- **Dashboard** zrobił w dwa dni (task_19, 23, 24) skok od edytora specyfikacji do orkiestratora: przebiegi równoległe, build do ogrania, arkusze rosnące, kolejka, scalanie automatyczne. Kod jest czysty i dobrze podzielony na warstwy, testy liczne, strażnik solidny w tym, co sprawdza. Rośnie dług dwóch rodzajów: wielkość plików (pięć po 2–3 tys. linii, które każdy agent czyta przy zmianie) i cztery źródła prawdy o tym, co wolno w przebiegu (strażnik, ustawienia, kontrakt, skille), stąd sprzeczności i stracone tury. Bezpieczeństwo: dla narzędzia solo na localhost w porządku, z jednym wyjątkiem wartym decyzji (`node` uruchomi każdy skrypt, który przebieg sam napisze, `dashboard.md` D1) i jedną bramką D-35 do dopięcia (testy i arkusz sprawdzane przez serwer, D3).
- **Proces** jest zdyscyplinowany (trzy źródła prawdy, spec → zadanie → gałąź → build → arkusz, strefy człowieka) i to jest jego siła. Koszt tej dyscypliny ponosi głównie Roland: 12–15 kliknięć i 5–7 przebiegów na zadanie, z oknami do wypełnienia przy każdym, a między przebiegami godziny czekania. W dolarach jest tanio (ok. 2–4 USD na zadanie); limitem jest subskrypcja i uwaga.
- **Dokumenty** mówią prawdę, ale są długie i miejscami nieaktualne: plan ma 660 linii z historią w środku i wciąż „limit jednej gałęzi” w trzech miejscach; §8.1 „3 ze 128 ID” wobec 31/165 dziś; INSTRUKCJA i widok Przebiegi mówią „naraz jeden”.

## Wizja: następny poziom

**Roland dotyka procesu w trzech miejscach: decyduje w specyfikacji i na kartach, gra w build, i (rzadko) scala ręcznie. Wszystko pomiędzy robi serwer bez pytania, a każdy fakt, na którym opiera się scalenie, pochodzi z serwera, nie ze zdania modelu.** Konkretnie:

1. **Łańcuch zamiast kliknięć.** Po zatwierdzeniu specyfikacji: planowanie → analizy → wdrożenia → testy serwera → build → przegląd idą same (kolejka z task_24 + łańcuch), a zatrzymują się tylko na karcie decyzji, czerwonym teście, werdykcie „poprawki” albo konflikcie. Jeden ekran „Do rozstrzygnięcia” zbiera wszystkie karty naraz.
2. **Fakty z serwera.** Testy, lint, build, `merge-tree`, sha builda zagranego w arkuszu — serwer je wykonuje i zapisuje; przegląd i scalanie automatyczne je czytają. Model nie jest już świadkiem we własnej sprawie.
3. **Poziomy zadań.** Tekst i narzędzia bez arkusza (test + zrzut jako dowód); rozgrywka z arkuszem **na build**, nie na zadanie: Roland gra raz na kilka zadań.
4. **Tanie przebiegi.** Świeży krótki przebieg zamiast wznowienia; jeden plik reguł przebiegu zamiast czterech; krótki plan; skill per tryb; stały prefiks z cache; Haiku do domknięcia. Cel: 2 USD za cykl bez spadku jakości i o połowę mniej straconych tur.
5. **Mapa gry.** Widok grafowy jako pochodna specyfikacji i kodu, z podświetleniem „co zmienia to zadanie” — żeby decyzje projektowe zapadały na mapie, a nie w pamięci.
6. **Gra gotowa na pomiar i na demo.** Złoty tydzień, osobny folder testów, sonda FPS, stałe ID treści (otwiera EN), preset `demo_cut`.

Miary, po których poznamy, że działa (do pokazania w dashboardzie, P14): kliknięć na zadanie (dziś 35–45 → cel ≤ 10), przebiegów na zadanie (5–7 → 3–4 widoczne, reszta w łańcuchu), USD na cykl (3–4 → ~2), straconych tur na przebieg (~2 → ~0), czasu Rolanda na zadanie poza grą (nieznany → mierzony).

## Najpierw: łatwe zyski (ten tydzień, każdy do 2 h dla Haiku/Sonneta, bez reguły ⬜ chyba że zaznaczono)

Kolejność według zysku na godzinę pracy; ID odsyłają do plików szczegółowych.

| # | Co | Efekt | Koszt | Gdzie |
|---|---|---|---|---|
| 1 | **Kontrakt zgodny ze strażnikiem**: prawdziwa nazwa zdalnego (`everhorror-spec`), jawnie dozwolony łańcuch `cd <kopia> && tools/run_tests.sh <nazwy>`, folder `tmp/` przebiegu; komunikaty blokad podają formę, która przechodzi | koniec 33 straconych tur dziennie; przeglądy naprawdę uruchamiają testy | S | `dashboard.md` D2, D-E2; `proces.md` P6 |
| 2 | **„Wznów” jako świeży krótki przebieg** (Sonnet/Haiku, limit 20 tur) albo decyzja dopisywana przez serwer bez modelu | −0,6…0,9 USD na każdą kartę (16 % kosztu dnia) | S | `proces.md` P2; `dashboard.md` D6 |
| 3 | **Koszt liczony z przyrostów**, nie z `total_cost_usd` wznowień; procent limitu subskrypcji i „czekało na Ciebie” na stronie zadania | uczciwe liczby (dziś +27 %), miara dla kolejnych zmian | S | `dashboard.md` D4, D-E1, D-E8; `proces.md` P14 |
| 4 | **Blokada powtórnego przeglądu** tego samego commita | −0,6 USD i klik, gdy się zdarza | S | `proces.md` P4; `dashboard.md` D-E6 |
| 5 | **`node` tylko dla `cli.ts` i śledzonych, niezmienionych `tools/*.js`** w plan/analyze/finalize/review; narzędzia zapisu egzekwują korzenie per rodzaj | zamyka lukę D1 dla 4 z 7 rodzajów i błąd D5 | S | `dashboard.md` D-E3, D-E4 |
| 6 | **Osobny folder zapisów i raportów dla testów** (`user://test-runs/<pid>/`) | testy nie kasują slotu AUTO i nie ścigają się między kopiami gałęzi; warunek testów po stronie serwera | S | `gra.md` G1, G-E1 |
| 7 | **Lint rozszerzony**: flagi tylko zapisywane, `%d <rzeczownik>`, ostrzeżenie DIA-2 dla warunków tylko na przedmiot; `run_tests.sh` czerwone na `^ERROR:`; `check_generated.js` | łapie klasę błędów, które dziś wychodzą u gracza; 10 martwych flag na start | S | `gra.md` G-E2, G-E3, G-E5 |
| 8 | **Lint pokrycia reguł** (`reports/rule-coverage.json`) + poprawka §8.1 | pierwsza miara spec ↔ kod; dane dla grafu | S | `proces.md` P10 |
| 9 | **Jedna tabela modeli** (plan §9); Haiku do domknięcia; budżety per rodzaj ~3× obserwowanego maksimum | jasność; −0,2 USD na cykl; ucina ucieczki | S | `proces.md` P9; `dashboard.md` D-E5, D-E11 |
| 10 | **Krótki plan**: `plan.md` ≤ 200 linii + historia w `docs/archiwum/`; usunięte zdania o „limicie 1 gałęzi” | −15 tys. tokenów na każdy przebieg, który czyta plan; koniec sprzeczności | S–M | `proces.md` P11 |
| 11 | **Wygląd**: „Teraz” składa pozycje tego samego rodzaju w jeden wiersz i pokazuje decyzje na górze; tablica bez przycisków na kartach; napis „naraz jeden” poprawiony; arkusz zamknięty bez kontrolek | mniej przewijania i powtórzeń na Pracy i Starcie | S | `dashboard.md` U1, U2, U6, U8, D-E13, D-E14 |
| 12 | **Sonda wydajności** `tools/perf_probe.gd` z liniami `PERF[…]` (K7) | liczba klatek przed mgłą i dźwiękiem etapu 5 | S–M | `gra.md` G6, G-E6 |
| 13 | **Zapisy-wzorce v3…v6** i test w obie strony; jawne pole `female:` w generatorze | stare zapisy testerów się wczytują; nikt nie zmieni płci przypadkiem | S | `gra.md` G-E4, G-E7 |
| 14 | **CI** na `windows-latest` z `npm test` dashboardu | ~2 100 testów, które dziś nigdy nie biegną w CI | S | `dashboard.md` D9, D-E12 |
| 15 | **Eksport po zależnościach scen** + `.gdignore` nieużywanych pakietów (smoke `day1`) | mniejszy ZIP i szybszy build do ogrania | S | `gra.md` G7, G-E10 |

Wymagają reguły ⬜ albo rozstrzygnięcia karty (więc nie „ten tydzień” bez Twojej decyzji): poprawka połykanego załamania (G2, po złotym tygodniu), cienie i zasięgi świateł (G-E11), bramka DIA-2 na rybie Hrapka (G-E9, prawdopodobnie poprawka przywracająca regułę).

## Potem: zmiany długoterminowe (fazy)

**Faza A — fakty z serwera i łańcuch (po task_24; 1–2 tygodnie pracy agentów, kilka decyzji Rolanda).**
- Testy po przebiegu uruchamia serwer w kopii gałęzi i zapisuje wynik w manifeście; przegląd i D-35 czytają ten wynik; zapis arkusza notuje sha builda, scalanie automatyczne wymaga „sha arkusza = HEAD” (`proces.md` P5; `dashboard.md` D3).
- Łańcuch „analiza → wdrożenie → testy → build → przegląd” jednym przyciskiem, z zatrzymaniem na karcie, czerwonym teście, „poprawkach” i konflikcie; ekran „Do rozstrzygnięcia” dla wszystkich kart naraz (P1, P13).
- Serwer zapisuje dokumenty gry po przebiegu bez naruszeń (P8) i robi wydanie przyciskiem po `release.sh` z task_22 (P16).
- Jeden plik reguł przebiegu dołączany do kontraktu; skille i `CLAUDE.md` tylko odsyłają; strażnik jako dane polityki + silnik (P15; `dashboard.md` porządek 1).

**Faza B — poziomy zadań i zadania narzędziowe w dashboardzie (po A).**
- `Poziom: tekst | narzędzia | rozgrywka` nadawany przez `/spec-tasks`; tekst i narzędzia bez arkusza (dowód: testy + zrzut); rozgrywka z jednym arkuszem na build (P3).
- `Rodzaj: narzędzia` wdrażane przebiegiem dashboardu w kopii gałęzi (dla dashboardu: kopia gałęzi specyfikacji), nie terminalem (P12).

**Faza C — gra gotowa na pomiar i stałe ID (równolegle z A/B, po task_20–22).**
- Złoty tydzień z uzupełnieniami (`gra.md` §3), potem czyste `NightRules`/`MorningRules`, potem liczby nocy jako zasób generowany z `07_balans.md` (etap 7 planu, część 1).
- Stałe ID: linie Dialogue Manager, klucze gwary po ID, kategorie czasu i `asked` z migracją (G3) — fundament pod EN (D-09) i mocniejszą polską grę.
- Reguły marszu wspólne dla gry i bota (G5); rejestr flag jako dane (task_22 K4 → `data/flags.json`).
- Wydajność: po sondzie K7 zasięgi świateł w generatorach, potem wyłączanie gałęzi lokacji poza bohaterem, dopiero potem ewentualne strumieniowanie (G6).

**Faza D — mapa gry (widok grafowy; fazy 0–3 z `widok-grafowy.md`).** Faza 0 (jeden wieczór) może iść już w A; fazy 1–2 po PT0b.

**Faza E — porządki, które opłacą się przy każdej kolejnej zmianie.** Podział `runs.ts`, `runguard.ts` (dashboard porządki 2–3), szybsze testy dashboardu (167 → ~80 s), `.godot` współdzielony albo kopie blokowe (`dashboard.md` długoterminowe 7), lekkie hooki dla sesji terminalowych (6).

## Narzędzia do wdrożenia (N1…N9)

| ID | Narzędzie | Po co | Koszt | Ryzyko | Jak mieści się w zasadach |
|---|---|---|---|---|---|
| N1 | **Testy serwerowe po przebiegu** (`runner.ts` → `tools/run_tests.sh` w kopii gałęzi, wynik w manifeście) | D-35 i przegląd opierają się na fakcie, nie na zdaniu modelu; model nie czeka na 4 min testów | M | testy świata dzielą folder gracza → najpierw N3 | pełny zestaw dalej „za zgodą”, ale zgoda to ustawienie serwera (CLAUDE.md „Tests”) |
| N2 | **Golden week** (task_20 K5 z uzupełnieniami: `dawn_log`, ziarno pokoi, 3–4 tygodnie skryptowane, tabela rozkładu) | zabezpiecza przepisanie nocy (etapy 5–7) | S–M | determinizm (`hash()`, RNG) | narzędzie, bez ⬜ |
| N3 | **Osobne foldery testów** + `run_tests.sh -j 3` + opcjonalne `time_scale` | testy równoległe i 4 → ~1,5 min; bezpieczny slot AUTO | S | założenia czasowe w scenariuszach | narzędzie |
| N4 | **Eksplorator dialogów** (BFS po tytułach z „pobłażliwym” `GameState`, błąd silnika jako jedyna asercja), docelowo lint na kompilatorze Dialogue Manager | pokrycie gałęzi z ~29 % do ~100 % „wykonane choć raz”; dane dla grafu | M | — | narzędzie |
| N5 | **Sonda wydajności K7** (`perf_probe.gd`, `PERF[…]`, budżet per maszyna) | liczby przed etapem 5 | S–M | — | narzędzie; zmiany świateł potem wymagają ⬜ |
| N6 | **Bot gracza** = bot balansu z torem bohatera (task_20 G4) + eksplorator (N4) + scenariusze `test_base` | „automatyczny playtest” logiki bez okna; pomiar K1–K5 bez człowieka | S (jest fundament) | bot ≠ gracz: tylko kierunek | narzędzie; plan już to przewiduje |
| N7 | **Regresja wizualna** (`screenshot.gd` + `views_tour.json` → PNG odniesienia + diff z tolerancją, tylko na maszynie Rolanda, okno GPU) | łapie regresje światła i układu po etapie 5 | S–M | nigdy headless/CI; czułe na sterownik | narzędzie |
| N8 | **Indeks przebiegów `runs.jsonl` + panel kosztu/limitu** | budżety na zadanie, domyślne z danych, szybka lista przebiegów | S–M | — | narzędzie |
| N9 | **CI**: `npm test` dashboardu na `windows-latest`; hook pre-commit specyfikacji z lintem i kontrolą linków | regresje strażnika i runnera łapane przed `master` | S | plan §8.3 mówi „CI opcjonalne” — to zmiana rekomendacji | narzędzie; bez wydatków (GitHub Actions w publicznym repo) |

Nie polecam teraz: GdUnit4 (usunąć, task_21), bazy danych, orkiestratora wielu agentów poza dashboardem, LFS przed pełną grą (plan D-31), sandboxu systemowego dla przebiegów (opcja na później, `dashboard.md` długoterminowe 2).

## Widok grafowy (streszczenie; całość w `widok-grafowy.md`)

- **Co:** jeden widok „Graf” w grupie Raporty, karta „Co zmienia to zadanie” na stronie zadania, „Pokaż w Grafie” przy regule. Węzły: zasady, questy i wpisy, flagi (ustawia/czyta, ładunek), przedmioty, notatki, postacie i ich stany, dni i noce, miejsca i drogi, rozmowy i odpowiedzi, zadania, karty, buildy. Krawędzie: ustawia, czyta, wymaga, odblokowuje, wdraża, zmienia.
- **Jak:** tylko widok pochodny (D-16, plan §3 pkt 1): strona specyfikacji z istniejących `SpecIndex`/`semanticDiff`/`WorkState`; strona gry z nowego eksportera `tools/graph_export.gd` (na wzór `data_lint.gd`, ~2 s) do `reports/graph/game-graph.json` poza gitem. Bez bazy, bez ręcznie edytowanego pliku grafu; generatory i specyfikacja zostają źródłami. Tylko noce i poranki z `story_director.gd` są „przybliżeniem z kodu” (oznaczonym), dopóki etap 7 nie zrobi z nich danych.
- **Zmiany:** diff grafu między rewizjami (baseline vs HEAD, master vs gałąź) z podświetleniem; historia węzła przez `git log -S <id>`.
- **Skala i technologia:** ~700 węzłów (950 z odpowiedziami), podsystemy 100–350; własny SVG w React + `@dagrejs/dagre` (MIT, jedna paczka) w Web Workerze; zapas: ręczny układ warstwowy bez zależności.
- **Fazy:** 0 — jeden wieczór (eksporter + `cli.ts graph --json` + lista/drzewo w istniejącym szkielecie kart; od razu lista nieudokumentowanych flag z miejscami); 1 — graf questy + flagi + postacie + przedmioty z podświetleniem zadania (2–3 przebiegi Sonnet); 2 — oś tygodnia, diff rewizji, odświeżanie po przebiegach; 3 — zasady ↔ kod ↔ testy i eksport przy wydaniu.
- **Dopasowanie do obecnego wyglądu:** §9 tamtego pliku, na podstawie zrzutów.
- **Warunek:** zmiana zdania w planie §5 (decyzja 1 poniżej).

## Decyzje dla Rolanda

| # | Decyzja | Opcje | Rekomendacja |
|---|---|---|---|
| 1 | **Plan §5 „bez grafu relacji”** | a) zostaje; b) „graf tylko jako widok pochodny, bez bazy i bez ręcznej edycji”; c) bez ograniczeń | **b** (precedens: D-16 i D-33 też zmieniły §5 „w tym zakresie”) |
| 2 | **Fakty do scalania automatycznego** (`dashboard.md` D3) | a) jak dziś (zdanie modelu + arkusz); b) testy przez serwer + sha builda w arkuszu = HEAD; c) b + scalanie automatyczne tylko dla poziomu tekst/narzędzia | **b** teraz, **c** gdy będą poziomy |
| 3 | **`node` w przebiegach** (`dashboard.md` D1) | a) jak dziś; b) `node` tylko dla `cli.ts` i śledzonych skryptów w plan/analyze/finalize/review (implement/fix/review i tak uruchamiają kod gałęzi); c) b + sekret serwera dla scalania/pusha/przełącznika, którego agent nie czyta; d) sandbox OS dla rodzajów z kodem | **c**; **d** dopiero przy wielu wykonawcach albo zewnętrznych współpracownikach |
| 4 | **Poziomy zadań i arkusz na build** (`proces.md` P3) | a) arkusz na każde zadanie jak dziś; b) tekst i narzędzia bez arkusza (test + zrzut), rozgrywka z arkuszem na build | **b**; zmienia D-32/D-27 w tym zakresie, nie zmienia §3 pkt 4 |
| 5 | **Łańcuch bez kliknięć** (P1) | a) każdy krok klikiem jak dziś; b) łańcuch z przerwami na kartę, czerwony test, „poprawki”, konflikt; c) b + zatrzymanie po analizie, gdy plan dotyka plików spoza `Pliki:` albo ryzyko „wysokie” | **c** |
| 6 | **Serwer zapisuje dokumenty gry po przebiegu** (P8; doprecyzowanie D-17c) | a) ręcznie jak dziś; b) serwer po audycie bez naruszeń, podpisane osobą, która kliknęła start | **b** |
| 7 | **Modele i wysiłek** (P9, D-18) | a) Opus high / Sonnet high jak w INSTRUKCJA; b) Opus medium do analizy i przeglądu, Sonnet high do kodu, Haiku do domknięcia, high na życzenie | **b** (zgodnie z Twoim zapisem w `CLAUDE.md`), z jedną tabelą w planie §9 |
| 8 | **Zadania narzędziowe w dashboardzie** (P12) | a) terminal jak dziś; b) przebieg „Wdróż” z profilem narzędzia | **b** po fazie A |
| 9 | **Dwujęzyczność** (D-30) | a) pełna jak dziś; b) EN z zapasem PL dla nowych napisów (ostrzeżenie zamiast błędu) | **b**, dopóki pracuje jedna osoba po polsku; a, gdy wróci zespół |
| 10 | **Krótki plan** (P11) | a) jeden plik jak dziś; b) `plan.md` ≤ 200 linii + historia w archiwum | **b** (nadal jeden plan, tylko krótki) |
| 11 | **Wydajność: światła** (`gra.md` G6) | a) nic do etapu 5; b) sonda K7 teraz, zasięgi i cienie w generatorach po pomiarze (⬜ w `06_oprawa`/`08_technika`) | **b** |
| 12 | **Kolejność najbliższych zadań gry** | a) task_20 → 21 → 22 jak w planie; b) G-E1 (folder testów) i G-E3 (`^ERROR:`) przed task_20, bo złoty tydzień i testy serwerowe na nich stoją | **b** (jedno krótkie zadanie narzędziowe przed task_20) |
| 13 | Dziewięć decyzji o grafie (miejsce, pierwszy podsystem, `dagre`, eksporter w Godocie, JSON poza gitem, przybliżenia nocy, historia leniwa, start fazy 0) | w `widok-grafowy.md` §8 | przyjąć rekomendacje tam zapisane |

Każda z tych decyzji jest odwracalna (proces, narzędzia, UX), więc według §3 pkt 3 może obowiązywać od zapisu jako rekomendacja agenta z Twoim wetem; wyjątek: 3c/3d (bezpieczeństwo) i N9 (publiczne repozytorium, choć bez wydatków) wymagają wyraźnego „tak”.

## Czego przestajemy robić

- Wznawiać sesje analiz po ponad godzinie i płacić za ponowne wczytanie rozmowy (P2).
- Klikać przegląd, gdy gałąź się nie zmieniła (P4).
- Pisać reguły przebiegu w czterech miejscach i naprawiać je czterema commitami (P15).
- Uruchamiać pełny zestaw testów w przebiegu modelu (P5).
- Wymagać arkusza i builda od zmiany dwóch zdań tekstu (P3).
- Trzymać historię planu w pliku, który czyta każdy przebieg (P11).
- Uznawać „gotowe” przeglądu, który nie mógł uruchomić testów (D2).
- Pokazywać skumulowany koszt wznowień jako koszt przebiegu (D4).
- Wdrażać zadania narzędziowe terminalem bez strażnika i audytu (P12), gdy faza A będzie gotowa.

## Jak zrobiono ten audyt

- Przeczytano: `CLAUDE.md`, `docs/agent/README.md`, `tools/README.md`, plan (cały), `WORKFLOW.md`, `WDROZENIA.md`, INSTRUKCJA, skille, task_18–24, arkusze 14 i 17, 18 zapisów przebiegów (`run.json`, `events.jsonl`, kontrakt, strażnik), kod gry i dashboardu w zakresie opisanym w plikach szczegółowych.
- Uruchomiono tylko: `tools/run_tests.sh unit lint balance` (zielone, 7,5 s), generatory danych do folderu tymczasowego (diff: identyczne), `npm test` dashboardu raz (2 137/2 137, 167 s), `cli.ts lint`, `cli.ts status --json`, `tsc --noEmit`, sondy strażnika na polityce w folderze tymczasowym, własna instancja dashboardu tylko do odczytu na porcie 5197 (zapisy przebiegów z kopii, scalanie i buildy automatyczne wyłączone) i bezgłowy Edge do zrzutów; oba procesy zatrzymane.
- Nie uruchomiono pełnego zestawu testów gry ani e2e dashboardu; nie dotknięto `reports/dashboard-runs/` (tylko odczyt i kopia), blokad, gałęzi, commitów.
- Pomocnicy: jeden do kodu gry (Opus 5.5), jeden do kodu dashboardu (Opus 5.5), jeden do widoku grafowego (Fable 5.1 high, pisał własny plik). Ich twierdzenia sprawdziłem wyrywkowo w kodzie (m.in. `_busy` w `story_director.gd:403/582`, `hrapek.dialogue:24`, „Mirrors StoryDirector” w `balance_sim.gd:193/215`, `checkRunTests` w `runguard.ts`, `resumeOf` i koszty w `run.json`).
