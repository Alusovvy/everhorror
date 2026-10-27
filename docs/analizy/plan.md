# Everhorror — plan

> 2026-10-27 · Przygotował: agent (Claude) · Dla: Rolanda
>
> To jedyny plan projektu: **co robimy, w jakiej kolejności, według jakich zasad**. Jest krótki celowo. Pełne uzasadnienia, szczegóły etapów, ocena poprzedniej pracy (§7), weryfikacja wcześniejszego planu (§8) i pełne teksty decyzji są w archiwum: [plan-historia-2026-10.md](../archiwum/plan-historia-2026-10.md) (`docs/archiwum/`: czytaj tylko przez odsyłacz z tego pliku). Numeracja paragrafów (§1, §3, §4, §5, §9) zgadza się z archiwum, bo odwołują się do niej skille i zadania.
>
> Decyzje (tabela w §9) obowiązują; pochodzą z 2026-10-26/27, każda ma źródło. Liczby w etapach 5–7 to wartości startowe, które sprawdzi pomiar. Skróty (PT, K, ⬜, `[ROBOCZE]`) objaśnia [słowniczek w archiwum](../archiwum/plan-historia-2026-10.md#10-słowniczek).

## Gdzie jesteśmy (2026-10-27)

- **Etapy 0–2 zrobione.** Wydanie **0.5.4** (tag `v0.5.4`, `c82a4dd`) jest w `master` gry: żyły w Starej sztolni (task_16) i palisada bez „niską” (task_17). Raport przebiegu i bot balansu weszły w 0.5.3 (task_14).
- **PT0 daje tylko kierunek** (krótka sesja, bez raportu). Punkt odniesienia K1–K5 da dopiero **PT0b**: pełny tydzień z raportem, 2–3 godziny, **od nowa na buildzie z poprawką eksportu** (każdy build z ZIP-a gubi listy tekstów w zasobach, więc licznik żył stoi na „0 z 12”; zgłoszenie `zgloszenia/2026-10-27_eksport-gubi-listy.md`).
- **Punkt odniesienia K1 z bota:** norma 12 żył pada między dniem 4, 13:00 (styl „żyły”) a dniem 5, 15:30 (styl „rozmowy”); cel to „nie wcześniej niż wieczorem dnia 6”.
- **Dashboard** prowadzi proces: przebiegi równolegle (do 3 analiz i do 3 wdrożeń, D-33), kolejka startów i scalanie automatyczne (D-35), build do ogrania przed arkuszem (D-32). Przebudowa według audytu 2026-10-27 (D-36) wchodzi etapami; reguły przebiegu: [docs/agent/run-rules.md](../agent/run-rules.md).
- **Otwarte zadania** (`docs/ai-tasks/`): task_18, task_20–22 (narzędzia gry: pomiar, porządek repozytorium, procesy) i task_25–35 (z reguł ⬜ z 2026-10-27). Na żywo: widok Praca. Przed task_20 idzie jedno krótkie zadanie narzędziowe: osobne foldery testów i czerwone `^ERROR:` (D-36 pkt 12).
- **Pokrycie reguł testami:** 31 ze 165 ID reguł pojawia się w kodzie lub testach (liczone 2026-10-27; lint pokrycia `reports/rule-coverage.json` ma to mierzyć, reguła ✅ bez odniesienia daje ostrzeżenie).
- **Odłożone:** źródło i licencja `assets/logo.png` (wraca najpóźniej przed demem publicznym); korekty specyfikacji do stanu gry czekają na jedną zgodę (archiwum, „Odłożone”).

## 1. Etapy

Czasy to szacunki, nie terminy. Etapy 4–9 zaczynają się dopiero na hasło Rolanda „start etapu N”. Szczegóły każdego etapu (zakres, „Kto”, „Gotowe, gdy”): kolumna „Opis”.

| Etap | Co | Stan | Opis |
|---|---|---|---|
| 0 | Zabezpieczyć pracę (commity, push, tag `v0.5.2`) | zrobione | [archiwum](../archiwum/plan-historia-2026-10.md#etap-0--zabezpieczyć-pracę) |
| 1 | Uczciwe zapisy i decyzje (korekta fałszywych potwierdzeń, decyzje w specyfikacji) | zrobione | [archiwum](../archiwum/plan-historia-2026-10.md#etap-1--uczciwe-zapisy-i-decyzje) |
| 2 | Drobne poprawki gry i wersja | zrobione, 0.5.3 | [archiwum](../archiwum/plan-historia-2026-10.md#etap-2--drobne-poprawki-gry-i-numer-wersji--053) |
| 3 | Sesja gry PT0 (bramka) | PT0 kierunek; **PT0b teraz** | [archiwum](../archiwum/plan-historia-2026-10.md#etap-3--sesja-gry-pt0-bramka) |
| 4 | Pomiar: raport, bot, tor bohatera, czas realny, „złoty tydzień” | raport i bot w 0.5.3; task_20 czeka | [archiwum](../archiwum/plan-historia-2026-10.md#etap-4--pomiar-raport-i-bot-weszły-do-053) |
| 5 | Odczucie: ruch 3,2 m/s, światło wg głębokości, dźwięk zamiast tekstu → PT1 | czeka | [archiwum](../archiwum/plan-historia-2026-10.md#etap-5--odczucie-horror-w-świecie-nie-w-tekście) |
| 6 | Presja: norma etapami, cena nocy, pokusa ponad normę → PT2 | czeka | [archiwum](../archiwum/plan-historia-2026-10.md#etap-6--presja-tygodnia) |
| 7 | Ludzie się kruszą: wstrząsy, załamania, zakończenie zależne od losów → PT3 | czeka | [archiwum](../archiwum/plan-historia-2026-10.md#etap-7--ludzie-się-kruszą) |
| 8 | Kręgosłup fabuły (rejestr kanonu, osie, zakończenia), tylko w specyfikacji | równolegle od etapu 5 | [archiwum](../archiwum/plan-historia-2026-10.md#etap-8--kręgosłup-fabuły-równolegle-tylko-w-specyfikacji) |
| 9 | Pierwsza godzina i demo publiczne (dni 1–3, klif) → PT4 | czeka | [archiwum](../archiwum/plan-historia-2026-10.md#etap-9--pierwsza-godzina-i-demo-publiczne) |

Jeśli sesja gry wypadnie źle, najpierw poprawiamy znalezione problemy. Dopóki PT0b nie jest wypełniony albo świadomie pominięty, agent nie zaczyna nowych funkcji rozgrywki (narzędzia pomiaru wolno, bo nie zmieniają gry).

## 3. Zasady, które obowiązują

1. **Trzy źródła prawdy:** specyfikacja mówi, co chcemy; kod mówi, co gra robi; arkusz człowieka mówi, co ktoś naprawdę sprawdził.
2. **Każda zmiana gry zaczyna się w specyfikacji.** Najpierw reguła ⬜, potem zadanie, gałąź i build. Prośba z czatu też najpierw trafia do specyfikacji.
3. **Decyzje: agent rekomenduje, Roland może zawetować.** Rzeczy odwracalne (liczby, UX, proces) obowiązują od zapisu. Kanon, nazwa i język obowiązują po najbliższym przeglądzie Rolanda. Pieniądze, bezpieczeństwo i wszystko publiczne wymagają **wyraźnego „tak”**. Każda rekomendacja podaje filar gry i wskazuje konflikt z wcześniejszą decyzją.
4. **Agent nigdy nie wpisuje wyników za człowieka.** Brak wpisu oznacza brak sprawdzenia. Decyzję z czatu zapisuje tylko jako „Roland, czat <data>: …”. Arkusz wymagany jest tylko tam, gdzie jest co zagrać: poziom `tekst` i `narzędzia` ma dowód w testach i zrzucie (D-36 pkt 4).
5. **Limity pracy (D-33, D-36):** do **3** otwartych gałęzi `spec/*` z kodem (do 3 wdrożeń i do 3 analiz naraz, rozłączne `Pliki:`); najwyżej **2** buildy czekające na zagranie (przy limicie agent proponuje sesję gry, poprawki wolno; liczy się też gałąź bez gotowego builda); najwyżej **5** otwartych kart decyzji.
6. **Pełny zestaw testów tylko za zgodą. Do `master` gry scala Roland, a od D-35/D-36 także serwer dashboardu**, gdy fakty z serwera się zgadzają (przegląd „gotowe” przypięty do HEAD, testy serwera zielone, build gałęzi = HEAD, brak konfliktu; dla poziomów tekst i narzędzia bez arkusza, dla rozgrywki z arkuszem bez ❌). Agent w przebiegu nigdy nie scala, nie wypycha gry ani nie tworzy tagu.
7. **Każde wydanie dostaje numer wersji i tag**; push po każdym scaleniu, według jednej reguły tagów i pushy (§9). Build do ogrania (D-32) wydaniem nie jest.
8. **Zasady projektowe dla każdej zmiany gry:** bez walki; bez nowych liczników; bez zegara czasu rzeczywistego; każdą nieodwracalną stratę zapowiadamy dzień wcześniej; słowa zamiast liczb; rzadkie, niepewne straszenie; każda dłuższa płatna rozmowa coś oddaje.

Codzienną drogę od pomysłu do sprawdzenia opisuje `specification/WORKFLOW.md`, a co wolno w przebiegu z dashboardu: [docs/agent/run-rules.md](../agent/run-rules.md).

## 4. Cele mierzalne

Sprawdzamy je botem, raportami przebiegu i pięcioma pytaniami z arkusza. Przy jednym testerze ankieta pokazuje kierunek, a nie dowód.

| Cel | Filar | Kiedy uznajemy, że działa |
|---|---|---|
| **K1** Presja | Czas to waluta | Bot „żyły” osiąga normę **nie wcześniej niż wieczorem dnia 6**. „Dziś zabrakło mi czasu” ≥ 4/7 w co najmniej 3 dniach. |
| **K2** Ludzie | Ludzie się kruszą | Do nocy 6 co najmniej 6 z 11 osób choć raz traci spokój; strata w co najmniej połowie przebiegów; ≥ 80% strat zapowiedzianych dzień wcześniej. |
| **K3** Głębia | Tajemnica w głąb | Bohater „na krawędzi” w co najmniej połowie przebiegów. Od dnia 2 co dzień coś niepokojącego poza tekstem. Napięcie na głębokości 3–4 ≥ 5/7, w obozie ≤ 3/7. |
| **K4** Czytelność | — | „Rozumiem, co kosztuje czas” ≥ 6/7. Żadna nieodwracalna strata bez ostrzeżenia. |
| **K5** Zakończenia | — | Co najmniej 3 rozróżnialne warianty zakończenia zależne od losów ludzi. |

## 5. Czego nie robimy

- **Narzędzia:** bez bazy danych zamiast Markdown i bez ręcznie edytowanego grafu relacji; **dozwolony jest graf tylko jako widok pochodny** specyfikacji i kodu, bez bazy i bez ręcznej edycji (D-36 pkt 1, `audyt-2026-10-27/widok-grafowy.md`). Orkiestrator wielu agentów istnieje tylko jako przebiegi równolegle z dashboardu pod strażnikiem i audytem (D-33; zmiana „bez orkiestratora” z 2026-09-26). Przebudowa dashboardu tylko w zakresie D-16, D-33, D-35 i D-36. Nowe integracje MCP tylko przy konkretnej potrzebie.
- **Gra:** bez walki, nowych liczników zasobów, zegara czasu rzeczywistego, wyborów na czas w rozmowach i skoku.
- **Platformy:** Unity, WebGL i multiplayer poza zakresem.
- **Publikacja:** bez publikacji, wydatków i strony w sklepie, dopóki Roland wyraźnie się nie zgodzi.

## 9. Decyzje i stałe zgody

### Modele i wysiłek (jedna tabela; D-36 pkt 7 zastępuje D-18)

Domyślne w `src/work/runs.ts` dashboardu zgodne z tą tabelą. `CLAUDE.md`, INSTRUKCJA i skille tylko tu odsyłają.

| Rodzaj przebiegu | Model | Wysiłek | Budżet (USD / tury) |
|---|---|---|---|
| planowanie | Opus 5.5 | medium | 8 / 120 |
| analiza | Opus 5.5 | medium | 4 / 80 |
| przegląd | Opus 5.5 | medium | 2 / 60 |
| wdrożenie | Sonnet 5.5 | high | 8 / 150 |
| poprawki | Sonnet 5.5 | high | 6 / 120 |
| domknięcie | Haiku 5.5 | max | 1 / 40 |
| próba („Sprawdź agenta”) | Haiku 5.5 | low | 0,5 / 4 |

W sesjach terminalowych: orkiestracja, przegląd, planowanie i analiza na Opus 5.5 medium; kod i poprawki na Sonnet 5.5 high, prostsze zadania na Haiku 5.5 max (Roland, D-29, 2026-10-27). Haiku eskalujemy do Sonnet high, gdy przegląd znajdzie jego błąd albo coś się psuje. Opus high tylko za zgodą Rolanda. Jedno zadanie = jeden wykonawca od początku do końca, co najwyżej jeden przegląd po nim.

### Tabela decyzji

Pełny tekst każdej decyzji (ze źródłem) jest w archiwum, w sekcji z kolumny „Gdzie”; karty z D-03 leżą w `specification/zgloszenia/` (D-01…D-15: `2026-10-26_decyzje-planu.md`).

| ID | Decyzja w jednej linii | Gdzie |
|---|---|---|
| D-01 | Nowy sposób pracy: zasady §3, krótki arkusz gry, uczciwość wpisów | [D-01…15](../archiwum/plan-historia-2026-10.md#decyzje-o-projekcie-i-procesie-d-01d-15) |
| D-02 | `MECHANICS.md` i `docs_v2/` do archiwum; LoreDoc i rejestr zasobów do specyfikacji (wykonane) | j.w. |
| D-03 | Karty decyzji w `specification/zgloszenia/` jako „Rodzaj: decyzja” | j.w. |
| D-04 | Pakiet odczucia (etap 5): ruch, światło, szepty 3D, łagodniejsze podświetlenie; bez próby w Kostnicy | j.w. |
| D-05 | Presja (etap 6): norma etapami, cena nocy, żyły ponad normę, rozmowy oddają czas | j.w. |
| D-06 | Ludzie (etap 7): wstrząsy, załamania Tekli, Racibora i Anzelma, zapowiedzi, jedna szansa | j.w. |
| D-07 | Zakończenie zależy od losów ludzi (tytuł i pierwszy akapit) | j.w. |
| D-08 | Nazwa wybrana przed stroną w sklepie; do tego czasu „Everhorror” | j.w. |
| D-09 | Angielski przy cięciu dema; nowe teksty przez `tr()` | j.w. |
| D-10 | `cave_ambient.mp3` i `steps.mp3` wymienić na CC0 | j.w. |
| D-11 | Kanon: rok 1518, 40 lat przerwy, Skarbnik, Czternasty nienazwany | j.w. |
| D-12 | Oś fabuły: 2–3 propozycje, agent rekomenduje jedną, obowiązuje po oknie weta | j.w. |
| D-13 | Demo publiczne: dni 1–3, koniec na spotkaniu z Exitium | j.w. |
| D-14 | „Wydarzenia jako dane”: tylko część 1, w etapie 7 | j.w. |
| D-15 | Poller tylko powiadamia; węższe uprawnienia; push po każdym scaleniu; CI opcjonalne | j.w. |
| D1–D10 | Decyzje o rozgrywce (presja, kruszenie, ruch, światło, powrót nocą, zakończenia, kolejność) | [D1–D10](../archiwum/plan-historia-2026-10.md#decyzje-o-rozgrywce-d1d10) |
| D-16 | Orkiestracja zadań z dashboardu (widok Praca), stan z dokumentów i gita, bez własnej bazy | [D-16…21](../archiwum/plan-historia-2026-10.md#decyzje-z-task_15-d-16d-21) |
| D-17 | Arkusze w `master` gry; pytania agenta to karty D-03; przebieg nie commituje w grze (część c doprecyzowana w D-36 pkt 6) | j.w. |
| D-18 | Modele przebiegów: **zastąpione D-36 pkt 7** (tabela wyżej) | j.w. |
| D-19 | Tożsamość agenta „Claude (agent)”; przebiegi na subskrypcji, API tylko po `EVERHORROR_ALLOW_API_KEY=1` | j.w. |
| D-20 | Dashboard w `master` specyfikacji, dokumenty procesu w grze (wykonane) | j.w. |
| D-21 | Odłożone: hasło administratora (wraca w D-36 pkt 3 jako sekret serwera), płatne „Sprawdź agenta”, licencja logo | j.w. |
| D-22 | Jednorazowy wyjątek: commity `[agent] proces: dokumentacja` w `master` gry | [D-22…26](../archiwum/plan-historia-2026-10.md#decyzje-z-porządkowania-dokumentacji-d-22d-26) |
| D-23 | „Zmiany agenta poza specyfikacją” nie rosną; pilna poprawka reguły bez wiersza, reszta najpierw jako ⬜ | j.w. |
| D-24 | Założenia task_05 w `09_produkcja.md` zostają do etapu 6 | j.w. |
| D-25 | Czas sesji gry „1–3 godziny” do PT0 | j.w. |
| D-26 | LoreDoc przeniesiony dosłownie; pytania o Savage Worlds i usterki eksportu czekają | j.w. |
| D-27 | Arkusz rośnie zamiast blokować (część „Część: task_NN”) | [D-27, 28](../archiwum/plan-historia-2026-10.md#decyzje-o-arkuszach-człowieka-d-27d-28) |
| D-28 | Zamknięcie arkusza z pominięciem (⏭), to nie dowód | j.w. |
| D-29 | Praca nad dashboardem: Opus koordynuje, Sonnet high albo Haiku max wykonują (modele: patrz tabela) | [D-29, 30](../archiwum/plan-historia-2026-10.md#decyzje-z-task_19-d-29d-30) |
| D-30 | Dashboard dwujęzyczny PL/EN; nowe napisy EN z zapasem PL (D-36 pkt 9) | j.w. |
| D-31 | Propozycje analizy projektu przyjęte i rozdzielone na reguły, zadania 20–22 i etapy | [D-31](../archiwum/plan-historia-2026-10.md#decyzje-z-analizy-projektu-d-31) |
| D-32 | Build do ogrania robi serwer po wdrożeniu i poprawkach; arkusz gałęzi czeka na aktualny build | [D-32](../archiwum/plan-historia-2026-10.md#build-do-ogrania-przed-arkuszem-d-32) |
| D-33 | Przebiegi równolegle: do 3 analiz i do 3 wdrożeń, każde w swojej kopii gałęzi (zastępuje „1 otwarta gałąź”) | [D-33, 34](../archiwum/plan-historia-2026-10.md#decyzje-z-task_23-d-33d-34) |
| D-34 | Reguła `master` gry w GitHubie: bez force push i usuwania | j.w. |
| D-35 | Scalanie automatyczne po przeglądzie, testach, braku konfliktu i arkuszu bez ❌; push tak, tag ręcznie; kolejka startów | [D-35](../archiwum/plan-historia-2026-10.md#decyzje-z-task_24-d-35) |
| D-36 | Przebudowa wg audytu 2026-10-27 (13 decyzji): 1 graf tylko jako widok pochodny · 2 fakty do scalania z serwera (testy, sha builda = HEAD) · 3 `node` tylko dla `cli.ts` i śledzonych skryptów, sekret serwera dla scalenia, pusha, przełącznika i wydania · 4 poziomy `tekst/narzędzia/rozgrywka`, arkusz tylko dla rozgrywki · 5 łańcuch bez kliknięć z zatrzymaniami (karta, czerwony test, „poprawki”, konflikt, plan poza `Pliki:` albo ryzyko wysokie) · 6 serwer zapisuje dokumenty gry po czystym audycie · 7 jedna tabela modeli · 8 zadania narzędziowe w dashboardzie · 9 EN z zapasem PL · 10 krótki `plan.md` · 11 sonda wydajności teraz · 12 foldery testów i `^ERROR:` przed task_20 · 13 graf wg `widok-grafowy.md` §8 | [D-36](../archiwum/plan-historia-2026-10.md#decyzje-z-audytu-2026-10-27-d-36); `docs/analizy/audyt-2026-10-27/` |

### Stałe zgody dla agenta (Roland, 2026-10-26, D-01 i D-15)

**Wolno bez pytania:** commity na gałęziach `spec/*` w kopii gałęzi; commity `[agent]` w specyfikacji po lincie z 0 błędów; tag wersji i push `master` gry po scaleniu (Rolanda albo automatycznym, D-35), według reguły poniżej; krótkie testy (`unit`, `lint`, `dialogue`, pojedynczy scenariusz). Bieżące polecenie może ten zakres zawęzić.

**Trzeba zapytać Rolanda:** scalanie do `master` gry (poza D-35); force push i przepisywanie historii; pełny zestaw testów; wszystko publiczne, płatne i dotyczące bezpieczeństwa.

**Commity:** prefiksy `task_NN: …`, `fix: …`, `build: vX.Y.Z`, `[agent] …` (specyfikacja), `[agent] proces: …` (zmiany procesu, nigdy w jednym commicie z pracą nad grą); żaden commit nie nazywa się „changes”.

**Reguła tagów i pushy:** tag `vX.Y.Z` stawia się na commicie, z którego zbudowano zip, i wypycha razem z `master` gry po scaleniu. Przebiegi z dashboardu nie commitują w grze, nie wypychają i nie tagują; opcja „tag i push” przy „Scal” robi to w imieniu Rolanda.
