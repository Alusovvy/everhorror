# Widok grafowy przepływu gry i logiki: research i projekt

> Audyt 2026-10-27 · Przygotował: agent (Fable 5.1), tylko odczyt · Dla: Rolanda
>
> Prośba (Roland, czat 2026-10-27): „I think I should have like graph representation of the game-flow and logic, so it's easy to track changes and stuff, but it should research how it would look like.”
> Ten plik jest researchem i projektem. Niczego nie wdraża i nie zmienia planu; decyzje są w §8.

## W skrócie

1. **Co:** jeden widok „Graf” w dashboardzie specyfikacji, który pokazuje węzły (zasady, questy, flagi, przedmioty, postacie, miejsca, dni, rozmowy, zadania, karty decyzji) i krawędzie między nimi (ustawia, czyta, wymaga, odblokowuje, wdraża), z podświetleniem tego, co zmienia zadanie albo gałąź.
2. **Dlaczego:** dziś te powiązania istnieją tylko w głowie i w ~107–131 warunkach `story_director.gd` oraz w ~200 flagach, z których około 85 % nie ma opisu (plan §8.2); `WORKFLOW.md:15` mówi wprost „opisany przebieg nie jest jeszcze formalnym grafem zależności”, a `ARCHITEKTURA.md:255` „jawne linki w widoku pliku nie stanowią pełnego grafu zależności”.
3. **Jak, bez łamania zasad:** graf jest **widokiem pochodnym**, liczonym z tych samych plików i gita co widok Praca (D-16: „stan liczy się z dokumentów i gita bez własnej bazy”, plan §9). Żadnej bazy, żadnego ręcznie edytowanego pliku grafu, generatory i specyfikacja zostają źródłami.
4. **Dane:** strona specyfikacji jest już sparsowana (`SpecIndex`, `semanticDiff`); strona gry wymaga małego eksportera w Godocie (`tools/graph_export.gd`, wzorowany na `tools/data_lint.gd`, ~2 s), który zapisuje JSON do `reports/graph/` (poza gitem).
5. **Technologia:** własny SVG w React z układem warstwowym z `@dagrejs/dagre` (MIT, jedna zależność, układ liczony w Web Workerze). Zapas: układ warstwowy napisany ręcznie (bez zależności), gdyby Roland nie chciał nowej paczki.
6. **Skala:** pełny graf to około 600–1000 węzłów i 800–1300 krawędzi; pojedynczy podsystem 100–300 węzłów, co SVG rysuje bez wirtualizacji.
7. **Etapy:** faza 0 (jeden wieczór: JSON z eksportera i widok listy/drzewa), faza 1 (graf questy + flagi + postacie z podświetleniem zadania), faza 2 (oś tygodnia i różnica między rewizjami), faza 3 (zasady ↔ kod ↔ testy).
8. **Koszt:** faza 0 to jeden przebieg Haiku (wieczór), fazy 1–2 po dwa–trzy przebiegi Sonnet z jednym przeglądem Opus (po dniu każda), faza 3 podobnie. To zadania narzędziowe (dashboard i `tools/`), więc nie dotykają bramki PT0 (plan, etap 3: narzędzia można budować, bo nie zmieniają rozgrywki).
9. **Najważniejsza decyzja Rolanda:** zmiana zdania w planie §5 „bez … grafu relacji” na „graf relacji tylko jako widok pochodny, bez bazy i bez ręcznej edycji” (§8, decyzja 1). Bez tej zmiany ten projekt zostaje w szufladzie.
10. **Czego nie proponuję:** osobnej bazy grafowej, ręcznie rysowanych diagramów do pielęgnowania, pełnego parsera GDScriptu i przebudowy dashboardu.

---

## 1. Co przedstawiać: węzły, krawędzie, źródła

Zasada: każdy węzeł ma **jedno** źródło prawdy i wskazuje `plik:linia`, z którego pochodzi. Graf niczego nie dopisuje; jeśli czegoś w źródłach nie ma, w grafie tego nie ma.

### 1.1 Typy węzłów

| Typ (PL / EN) | Źródło (plik, co czytać) | Ile dziś | Koszt pozyskania |
|---|---|---|---|
| zasada / rule | `SpecIndex.rules` z parsera (`dashboard/src/spec/model.ts:80–100`: `id`, `markers`, `tags`, `file`, `line`, `heading`) | ok. 162 zasad w 13 prefiksach (NPC 21, CZAS 20, WYP 19, ZAP 16, ZDR 13, DIA 13, ZYL 11, ZAD 10, PET 10, EKW 10, INT 9, UI 7, TECH 3); 132 z pierwszym znacznikiem ✅, 15 ⬜ (zliczone `rg` po `- **PREFIX-N**`, 2026-10-27) | **tanie**: już sparsowane |
| quest / quest i jego wpisy | `tools/generators/write_story_data.js:177–285` (`quest(id, title, giver, entries)`) albo rejestr `GameState.QUESTS` (`script/game_state.gd:77–92`) | 15 questów, 71 wpisów (policzone z generatora) | **tanie**: tabela w JS; w Godocie `QUESTS[id].entries` |
| flaga / flag | literały `set_flag`, `has_flag`, `mark_today`, `done_today`, `bump_flag`, `"on_use_flag"` w `dialogue/*.dialogue`, `script/*.gd`, `tools/generators/*.gd`; wzorce już są w `tools/data_lint.gd:227–228` | 207 różnych nazw (168 ustawianych, 158 czytanych; rodziny `vein_*`, `visited_*` liczone jako jedna, `data_lint.gd:29`) | **średnie**: wyrażenia regularne po tekście; lint już to robi (`data_lint.gd:226–250`) |
| flaga z ładunkiem / payload flag | `GameState.has_flag` (`script/game_state.gd:394–404`: String, int, Array liczą się jako „ustawione”) | np. `encounter_place`, `nasir_at_pumps`, `first_room_<id>` | jak wyżej, z dopiskiem „ładunek” |
| przedmiot / item | `write_world_data.js:34–79` (`item({id, cat, heal, sanity …})`), `GameState.ITEMS` (`game_state.gd:94–114`) | 20 | **tanie** |
| notatka / note | `write_story_data.js:154–174`, `GameState.NOTES` (`game_state.gd:65–75`) | 10 | **tanie** |
| postać / character | `write_story_data.js:65–151, 271–276` (`npc({id, faction, max_sanity, start_sanity, zero})`), karty `02_postacie/*.md` (`SpecIndex.cards`, `model.ts:148–154`) | 15 | **tanie** |
| stan postaci / character state | pasma poczytalności (`GameState.sanity_band`), przybycie (`ARRIVAL_FLAG`, `game_state.gd:127`: `sabina_joined`, `drudzy_met`), odejścia i śmierć (`set_npc_status(… "gone"/"dead")` w `story_director.gd:454, 468–470`), `FIXED_SANITY` (`game_state.gd:117`) | 15 postaci × 4 statusy (`camp`/`field`/`gone`/`dead`, `camp_schedule.gd:11`) | **średnie**: statusy z kodu przez regex |
| dzień, noc / day, night | `04_tresc/tydzien.md` (kalendarz dzień po dniu, `:9–69`) kontra `StoryDirector._resolve_night()` (`story_director.gd:428–495`), `_resolve_new_people()` (`:499`), `_morning_events()` (`:543`), `_week_end()` (`:613`) | 8 dni, 7 nocy; `LAST_DAY = 8`, `QUOTA_DAY = 7` (`game_state.gd:32–35`) | **tanie** dla kalendarza ze spec (nagłówki `### Dzień N`); **drogie** dla kodu nocy (warunki w GDScript, zob. §1.3) |
| miejsce / place i droga / road | `write_world_data.js:83–94` (`EDGES`, 17 krawędzi z godzinami) i `:96–159` (`PLACES`: `depth`, `dread`, `requires` jak `item:lina`, `flag:pump_running`, `noflag:mir_dead`, `veins`) | 15 miejsc + obóz, 25 żył (log generatora `:200–201`) | **tanie**: tabela w JS; w Godocie `GameState.LOCATIONS[id].links/requires/veins` |
| żyła / vein | `PLACES[*].veins`, flagi `vein_<id>` (`game_state.gd:364–372` loguje do `vein_log`) | 25, 3 pod naciekiem (kilof) | **tanie** |
| rozmowa / dialogue i jej gałęzie | `dialogue/*.dialogue` (19 plików, 2243 linie, 235 odpowiedzi, 121 warunków `[if`, 165 `set_flag`, 41 `quest_log`, 14 `start_quest`, 17 `take_item`, 26 `give_item`, 44 `change_rep`, ~73 tytułów `~`) | jak obok | **średnie**: zamiast własnego parsera użyć skompilowanego zasobu Dialogue Managera: `DialogueResource.lines` (`addons/dialogue_manager/dialogue_resource.gd:21`) daje dla każdej linii `type`, `text`, `responses`, `condition`, `next_id`, `next_id_after` (`compiler/compiled_line.gd:10–40`) |
| scena / scene | sceny VN i zdarzenia dnia: `VN.play`, `request("sleep"/"blast")`, posłanie, ognisko (`dialogue/ognisko.dialogue`), spotkanie z Exitium (`drudzy.dialogue`) | kilkanaście | **średnie**: lista ręcznie wskazanych punktów wejścia w kodzie (regex po `VN.play(` i `preload(".dialogue")`, `story_director.gd:11–14`) |
| zadanie / task | `docs/ai-tasks/task_NN.md` i `done/` (parser `dashboard/src/work/tasks.ts`), wiersz „W zadaniach” w `WDROZENIA.md` (zadanie ↔ commit specyfikacji ↔ ID, `model.ts:217–218`), gałąź `spec/<data>-taskNN`, arkusz, build do ogrania (`src/work/playbuild.ts`) | 25 zadań (6 otwartych, 19 w `done/`); 39 różnych ID zasad cytowanych w zadaniach | **tanie**: widok Praca już to liczy (`src/work/derive.ts:1–9`) |
| karta decyzji / decision card | `zgloszenia/*.md` (`SpecIndex.tickets`, `model.ts:156–168`, `isDecisionTicket`), opcje z `src/spec/options.ts` | 13 otwartych plików + `zamkniete/` | **tanie** |
| commit / commit | `git log` obu repozytoriów (specyfikacja 188 commitów, gra 68 na `master`, stan 2026-10-27) | jak obok | **tanie i leniwe**: `git log -S "NPC-18" -- 03_mechaniki/npc.md` zwraca od ręki 2 commity (sprawdzone) |
| test / test | `tools/tests/test_*.gd`, `tools/unit_test.gd`, `dialogue_test.gd`, `balance_sim.gd`; tabela w `tools/README.md:24–46` | 17 scenariuszy + 4 warstwy | **tanie** jako węzły; **średnie** jako krawędzie „test dotyka X” (regex po flagach, questach i miejscach w pliku testu) |

### 1.2 Typy krawędzi

| Krawędź | Z → do | Źródło |
|---|---|---|
| **ustawia** / sets | rozmowa, scena, noc, interakcja → flaga | `set_flag(`, `mark_today(`, `"on_use_flag"` (`data_lint.gd:228`) |
| **czyta** / reads | flaga → rozmowa, scena, noc, miejsce | `has_flag(`, `done_today(`, `[if … /]`, `"required_flag"`, `requires: {"flag:…"}` (`data_lint.gd:227`, `write_world_data.js:118, 147`) |
| **daje / zabiera** | rozmowa, interakcja → przedmiot | `give_item`, `take_item`, `give_to_npc` (`data_lint.gd:55–56`) |
| **wpis questu** | rozmowa, scena → wpis questu | `quest_log("ryba", "od_tekli")` (`data_lint.gd:85`) |
| **zaczyna / kończy** | → quest | `start_quest`, `complete_quest`, `fail_quest` (`data_lint.gd:57`) |
| **zaufanie / poczytalność** | rozmowa, noc → postać (z liczbą) | `change_rep`, `change_sanity`, `change_player_sanity` (`story_director.gd:441–449`) |
| **droga (h)** | miejsce ↔ miejsce | `EDGES` (`write_world_data.js:83–94`) |
| **wymaga** | miejsce → przedmiot / flaga | `requires` (`write_world_data.js:101–103, 110, 118, 130, 147, 156`) |
| **jest w (dzień, godzina)** | postać → miejsce obozu | `CampSchedule._at("kuchnia", …)` (`camp_schedule.gd:42`; lint czyta to regexem w `data_lint.gd:257–277`) |
| **dzieje się w dniu** | zdarzenie → dzień | `tydzien.md` (nagłówki) i `night == 5`, `day >= 3` w kodzie |
| **opisuje** / **wdraża** | zasada → kod, zasada → zadanie, zadanie → gałąź → build | sekcje „Dla agenta” (25 plików spec je ma, np. `03_mechaniki/npc.md:80, 94`), ID cytowane w `task_NN.md`, „W zadaniach” i „Na gałęziach” w `WDROZENIA.md` |
| **rozstrzyga** | karta decyzji → zasada | ID w treści karty (`pending.ts` już tak łączy, `ARCHITEKTURA.md:217`) |
| **zmienia** | commit → węzeł | leniwie, `git log -S <id> -- <plik>` |

### 1.3 Co jest tanie, a co drogie, i co z drogim

- **Tanie (już ustrukturyzowane):** zasady, znaczniki, karty, zgłoszenia, księga wdrożeń, zadania, arkusze, gałęzie, buildy (wszystko w `SpecIndex` i `WorkState`); przedmioty, miejsca, drogi, wymagania, żyły, questy z wpisami, notatki, postacie (tabele w dwóch generatorach JS, `tools/README.md:69–70`).
- **Średnie (wyrażenia regularne po tekście, już sprawdzone w lincie):** flagi ustawiane i czytane, ID używane w rozmowach i generatorach, miejsca rozkładu, etykiety czasu. `tools/data_lint.gd` ma gotowe wzorce (`:55–60, 227–228`) i działa około 2 s (`tools/README.md:28`). Eksporter grafu to ten sam skrypt z innym wyjściem: zamiast `LINT …` wypisuje JSON z `plik:linia`.
- **Drogie (semantyka GDScriptu):** warunki nocy i poranków w `story_director.gd` (131 linii `if`/`elif`, plan §8.1 mówi o ~107 warunkach, inna metoda liczenia), które mieszają flagi, dzień, poczytalność i status. Pełny parser GDScriptu jest poza zasięgiem i byłby kruchy. Dwa wyjścia, oba tanie:
  1. **Teraz:** krawędź „noc N → czyta flagę / zmienia postać” z regexa po linii i jej najbliższym `if` (`story_director.gd:433–452` jest tak regularny, że regex daje poprawny wynik dla większości linii); w grafie takie krawędzie noszą oznaczenie „przybliżenie z kodu”, nigdy „reguła”.
  2. **Docelowo:** etap 7 planu, „wydarzenia jako dane” część 1 (D-14): nocne zmiany poczytalności i poranne zdania przechodzą z kodu do tabel w specyfikacji i generatora. Od tej chwili węzły nocy są tanie i dokładne, a graf nic nie musi zgadywać.
- **Rozmowy:** nie pisać własnego parsera składni `.dialogue`. Godot po `--import` ma skompilowany zasób z gotowym grafem linii (`DialogueResource.lines`), więc eksporter w Godocie bierze tytuły (`~ hub`), odpowiedzi, warunki i mutacje wprost z pól `DMCompiledLine` (`compiled_line.gd:10–40`). Warunek `[if has_flag("took_bundle") and … /]` (`dialogue/tekla.dialogue:27`) rozbijamy regexem na flagi, przedmioty i questy (jak lint).
- **Wyjście JSON eksportera gry** (poza gitem, `reports/graph/game-graph.json`): `{ "rev": "<sha>", "dirty": bool, "generatedAt": …, "nodes": [{id, type, label, file, line, meta}], "edges": [{from, to, kind, file, line, note}] }`. Identyfikatory węzłów są stabilne i czytelne (`flag:west_blasted`, `quest:ryba/od_tekli`, `place:zalany`, `npc:tekla`, `dialogue:tekla/hub`, `night:5`), bo od nich zależy różnica między rewizjami (§3).

---

## 2. Jak to budować i odświeżać: widok pochodny, nigdy drugie źródło

Zasady, które graf musi spełniać:

- **Plan §3 pkt 1 i §5:** trzy źródła prawdy, bez bazy danych zamiast Markdownu. Graf nie jest czwartym źródłem: nie ma pliku, który ktoś edytuje ręcznie, i nie ma bazy. Dokładnie tak działa dziś widok Praca (`derive.ts:1–4`: „Nothing is stored: the view is recomputed on every request”) i wyszukiwarka (`WORKFLOW.md:21`: „Nie edytujemy osobnego indeksu ani bazy; odświeżenie odtwarza wyniki”).
- **`CLAUDE.md:14`:** dane i sceny tylko przez generatory. Eksporter grafu niczego nie generuje do `data/` ani `scene/`; czyta.
- **`ARCHITEKTURA.md:38`:** dashboard i agent są bezstanowe, „można je wyrzucić i odtworzyć z repozytoriów”. Plik JSON w `reports/graph/` jest pamięcią podręczną, nie stanem: skasowany odtwarza się jednym poleceniem.

### 2.1 Pipeline

```
 specyfikacja (git)                       gra (główna kopia + kopie gałęzi)
   │ loadRevision(rev)                      │ GODOT --headless --script tools/graph_export.gd
   │ (node/load.ts:39–63, cat-file --batch) │ (jak data_lint.gd, ~2–5 s, bez sceny świata)
   ▼                                        ▼
 buildIndex → SpecIndex                   reports/graph/game-graph.json  (poza gitem)
   │                                        │
   └────────────┬───────────────────────────┘
                ▼
   src/graph/build.ts  (czysty TS, bez zależności, testowany jak derive.ts)
     specGraph(index) + gameGraph(json) + workGraph(WorkState) + links()
                ▼
   Graph { nodes, edges, rev: {spec, game}, stale: {…} }
                ▼
   GET /work/graph?game=master|spec/2026-10-27-task20  (node/work-api.ts, pamięć ≤ 1 s jak /work/state)
                ▼
   widok Graf (React, SVG) · układ w Web Workerze (dagre) · panel węzła · podświetlenie zmian
```

- **Strona specyfikacji** nie potrzebuje niczego nowego poza `src/graph/build.ts`: `index(rev)` z `cli.ts:34–36` daje `SpecIndex` dla dowolnej rewizji, a `WorkState` (`/work/state`, `ARCHITEKTURA.md:174`) ma zadania, gałęzie, arkusze i buildy.
- **Strona gry:** `tools/graph_export.gd` (nowy, `extends SceneTree`, wzór `data_lint.gd:41–52`) ładuje te same źródła co lint, do tego `DialogueResource.lines` każdego pliku `dialogue/*.dialogue`, `GameState.QUESTS/ITEMS/NOTES/NPCS/LOCATIONS` i `CampSchedule` (regex jak `data_lint.gd:255–277`). Wymaga `--import` tak jak lint (`CLAUDE.md:37`); serwer dashboardu już umie uruchamiać Godota bez modelu dla buildów (`tools/README.md:76`, `EVERHORROR_GODOT` w `dashboard/README.md:25`).
- **Nowe polecenie CLI:** `node dashboard/cli.ts graph [--spec REV] [--game master|task_NN] [--json|--md]` obok `status --json` (`cli.ts:94–117`). `--md` wypisuje listę węzłów i sąsiadów (faza 0), `--json` pełny graf. `cli.ts graph diff <A> <B>` to §3.
- **Kiedy liczyć:**
  - specyfikacja: przy każdym wczytaniu widoku, jak diff od baseline (`src/data/hooks.ts:40–66`); rewizje są niezmienne, więc `loadRevision` już je buforuje (`store.tsx:537`, `ARCHITEKTURA.md:211`);
  - gra: (a) na kliknięcie „Odśwież graf gry”, (b) automatycznie po zakończonym przebiegu wdrożenia albo poprawek, dokładnie tam, gdzie dziś rusza build do ogrania (plan §3 „Build do ogrania przed arkuszem”, D-32), (c) opcjonalnie przy starcie serwera, jeśli JSON jest starszy niż HEAD. Nigdy w pętli obserwowania plików: Godot w tle gryzłby się z otwartym edytorem i z importem (`WORKFLOW.md:72`).
- **Pamięć podręczna i nieaktualność:** JSON gry niesie `rev` i `dirty`. Widok porównuje je z HEAD kopii i pokazuje w nagłówku „graf gry z `c82a4dd`, 2026-10-27 18:02; HEAD to `c82a4dd`” albo plakietkę **„Nieaktualny: HEAD `f1e2d3c`”** z przyciskiem „Odśwież graf gry”. To ten sam wzorzec co „stan z 08:14:55” w widoku Praca (`INSTRUKCJA.md:28`) i zasada 11 w `UI.md` (pusty i stary stan mówi, dlaczego). Graf specyfikacji nie bywa nieaktualny, bo liczy się z rewizji na żądanie; kopia robocza jest oddzielną warstwą „Tylko u Ciebie na dysku”, jak w Zmianach (`ARCHITEKTURA.md:43`).
- **Kopie gałęzi:** dashboard ma już folder na każdą otwartą gałąź `spec/*` (`everhorror-wt/<gałąź>`, `CLAUDE.md:9`). Eksporter uruchomiony w kopii gałęzi daje graf gry „po zadaniu”, a w głównej kopii „przed”; bez żadnego `checkout` (zakazany, `CLAUDE.md:9`).

---

## 3. Śledzenie zmian

Trzy pytania, które graf ma zadawać za Rolanda: **co zmieniło się od wdrożenia**, **co zmienia to zadanie / ta gałąź** i **skąd się wziął ten węzeł**.

### 3.1 Różnica grafów między rewizjami

- Wejście: dwa grafy o stabilnych identyfikatorach węzłów (§1.3). Wynik: `GraphDiff { added: Node[], removed: Node[], changed: {node, fields}[], edgesAdded, edgesRemoved }`.
- **Specyfikacja:** nie liczymy niczego od zera. `semanticDiff(a, b)` (`src/spec/diff.ts:415`) zwraca `Change` z `kind` (`zasada-znacznik`, `zasada-tekst`, `tabela-komorka` …, `:10–26`), `subject` (ID zasady albo klucz wiersza) i `actionable` (`:28–49`). Mapowanie na graf: `subject` → węzeł, `kind` → rodzaj zmiany, `actionable` → kolor (zmiana redakcyjna szara, polecenie dla agenta wyróżnione). Pary rewizji, które już mają nazwę w dashboardzie: **baseline → master** (kolejka, `ARCHITEKTURA.md:41`), **master → kopia robocza** („Tylko u Ciebie na dysku”), **merge-base → gałąź `zmiana/*`** (`/branches`, `:169`).
- **Gra:** różnica dwóch JSON-ów eksportera. W fazach 1–2 tylko dla rewizji, które są na dysku: `master` (główna kopia) i każda otwarta gałąź (jej kopia). To wystarcza na „co zmienia task_NN” (zob. §3.2). Historyczne rewizje gry (np. `v0.5.3` kontra `v0.5.4`) wymagałyby tymczasowej kopii i `--import` na każdą, czyli ~1 min jak build do ogrania (plan: pierwszy build trwał 42 s). Proponuję to dopiero w fazie 3 i tylko przy wydaniu: `tools/release/stamp_build.js` dokłada eksport grafu do commita wydania, tak jak dziś generuje się i commituje `dialogue/gwara_slaska.json` (`CLAUDE.md:40`). Wtedy tagi wersji mają graf w historii i porównanie `v0.5.3..v0.5.4` jest zwykłym diffem dwóch plików.
- **Układ przy różnicy:** węzły wspólne obu stron dostają pozycje z układu strony „po”; usunięte dorysowujemy obok ostatniego sąsiada, żeby obraz nie „skakał”. To argument za układem warstwowym, a przeciw układowi siłowemu (§5).

### 3.2 „Co zmienia task_NN / ta gałąź”

Trzy warstwy, każda z innego źródła, nakładane na jeden graf:

1. **Zamiar:** ID zasad cytowanych w `task_NN.md` i w wierszu „W zadaniach” (`WDROZENIA.md`, kolumna ID; `model.ts:217`). Węzły zasad podświetlone, ich krawędzie „opisuje” prowadzą do kodu.
2. **Zakres plików:** linia `Pliki:` z planu zadania albo ścieżki w backtickach z sekcji „Plan” (tak liczy to już `src/work/parallel.ts:5–6` dla przebiegów równoległych). Pliki → węzły, których `file` pasuje (rozmowy, generatory, skrypty).
3. **Fakt:** diff grafu gry master → kopia gałęzi (§3.1). Pokazuje, co naprawdę się zmieniło: nowe flagi, zmienione warunki, nowe wpisy questów.

Rozjazd między warstwą 1 a 3 jest sam w sobie informacją („zadanie cytuje NPC-20, ale gałąź nie dotknęła niczego, co NPC-20 opisuje”) i dobrze pasuje do przeglądu kodu.

### 3.3 Historia węzła

Leniwie, po otwarciu panelu węzła (jak szczegóły pozycji w Podsumowaniu, `ARCHITEKTURA.md:223`):

- zasada: `git log --format=%h%x09%s -S "<ID>" -- <plik>` w specyfikacji (dla NPC-18: `56bffc8`, `8e46253`, sprawdzone); wiersze „W zadaniach” i „Wpisy” z tym ID; karty decyzji, które je wymieniają;
- flaga, quest, miejsce: `git log -S "<nazwa>" -- dialogue script tools/generators` w grze; zadania, których „Plan” wymienia plik, w którym flaga jest ustawiana;
- zadanie: gałąź, commity gałęzi, arkusz, build, przebiegi (`WorkItem` już to ma, `src/views/WorkItem.tsx`).

Nic z tego nie jest zapisywane; wynik `git log` jest buforowany w pamięci serwera na czas sesji, z kluczem `(repo, HEAD, zapytanie)`.

---

## 4. Projekt interakcji

### 4.1 Gdzie to mieszka

- **Nowy widok „Graf” / „Graph”** w grupie **Raporty** paska bocznego (obok Wdrożeń, Kolejki, Podsumowania, Pytań; `ARCHITEKTURA.md:221`, trasa `#/graf` dopisana do `src/App.tsx:353–385`). Nazwa idzie do słowniczka `UI.md` (zasada 2: jedna nazwa na jedną rzecz; „mapa” jest zajęta przez mapę w grze, a „powiązania” jest ogólne). Angielski: „Graph”.
- **Dwa wejścia z istniejących stron,** bez nowych widoków: na stronie zadania (`/praca/zadanie/:id`) karta „Co zmienia to zadanie” z miniaturą grafu i linkiem „Otwórz w Grafie”; na karcie zasady (`RuleCard`) link „Pokaż w Grafie” z adresem `#/graf?focus=rule:NPC-18`. Odwrotnie: każdy węzeł w panelu ma link do swojego miejsca (`routeFor(plik, linia)`, `src/nav.ts:138–143`, dla zasad; dla plików gry tekst ze ścieżką, jak w `gameLinks.ts`).
- Adres niesie cały stan widoku (`?lod=system&sub=questy&focus=flag:west_blasted&since=baseline&task=task_20`), żeby link dało się wkleić do karty decyzji albo zadania.

### 4.2 Poziomy szczegółu

1. **Przegląd (overview):** 8–10 „superwęzłów” podsystemów (Zasady, Questy, Flagi, Postacie, Przedmioty, Miejsca, Rozmowy, Tydzień, Zadania, Decyzje) z licznikami i grubością krawędzi = liczba powiązań. Na każdym plakietka: ile węzłów zmienionych od wybranego punktu („od baseline”, „od ostatniego wdrożenia”, „na gałęzi task_NN”).
2. **System:** jeden podsystem rozwinięty (np. questy + ich wpisy + flagi, które je bramkują + postacie-zleceniodawcy), sąsiednie podsystemy jako zwinięte superwęzły na brzegu.
3. **Węzeł:** panel z prawej strony (źródło `plik:linia`, krawędzie pogrupowane po rodzaju, historia, zadania, karty), a graf przechodzi w tryb skupienia (§4.4).

### 4.3 Filtry (pasek nad grafem, wszystkie jako plakietki z liczbą)

- **Typ** węzła (wielokrotny wybór), **znacznik** zasady (✅🟡⬜💡❓❌ zawsze z nazwą słowną, `UI.md` zasada 15), **dzień** 1–8 (zdarzenia i rozkład tego dnia), **postać**, **zadanie** (warstwy z §3.2), **„zmienione od”** (baseline / commit / gałąź / „ostatnia wizyta”), **„tylko przybliżenia z kodu”** (żeby zobaczyć, czego graf nie jest pewien).
- Filtry nie usuwają węzłów z układu, tylko je wyciszają; układ zostaje stabilny i oko nie gubi miejsca.

### 4.4 Skupienie, wyszukiwanie, klawiatura

- **Skupienie:** sąsiedztwo węzła w promieniu 1 (domyślnie) lub 2; reszta wygaszona na 15 %. Krawędzie wchodzące i wychodzące w dwóch kolorach (ustawia/czyta).
- **Wyszukiwanie:** to samo `src/spec/search.ts` dla zasad, kart i tabel, rozszerzone o identyfikatory z grafu gry (`flag:`, `quest:`, `place:`, `npc:`). Skrót `/`.
- **Klawiatura:** `/` szukaj, `↑↓` po liście sąsiadów w panelu, `Enter` przejdź do sąsiada, `F` skupienie, `Esc` wyjdź o poziom, `+ −` powiększenie, `1 2 3` poziomy szczegółu, `[ ]` poprzednia/następna zmiana z listy „zmienione od”. Fokus zawsze widoczny (WCAG 2.4.11, `UI.md` zasada 16), każdy węzeł ma `role="button"` i nazwę dostępną z typem i etykietą.
- **PL/EN:** wszystkie napisy przez `t()` (`UI.md` §3), identyfikatory i treść węzłów bez tłumaczenia (zasada 15).

### 4.5 Pierwszy ekran dla osoby z pięcioma minutami

Nie pusty graf. Nagłówek: „Od ostatniego wdrożenia (`3f76c0f`) zmieniło się **14 węzłów**; na gałęzi task_20 **5**.” Pod spodem przegląd z plakietkami zmian, a po prawej lista zmian posortowana jak „Teraz” (najpierw ⬜ i to, co zadanie zmienia). Jedno kliknięcie prowadzi do skupienia na pierwszej zmianie. Bez zmian: „Graf zgadza się z wdrożeniem `3f76c0f`. Nic nie czeka.”

### 4.6 Makiety

**Makieta 1: przegląd (poziom 1), z plakietkami zmian od baseline**

```
┌ Graf ──────────────────────────────────────────────────── PL | EN ┐
│ Zmienione od: [baseline 3f76c0f ▾]  Zadanie: [brak ▾]  Poziom: [1] 2 3 │
│ spec HEAD c10bbda · graf gry z c82a4dd 18:02 ✓ aktualny              │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│        ┌─────────┐  opisuje 48  ┌──────────┐   bramkuje  ┌───────┐ │
│        │ Zasady  │═════════════▶│ Rozmowy  │◀───────────▶│ Flagi │ │
│        │ 162 ·⬜15│              │ 19 · 235 │   165/121   │ 207   │ │
│        │ ▲ 14    │              │ ▲ 0      │             │ ▲ 2   │ │
│        └────┬────┘              └────┬─────┘             └───┬───┘ │
│   wdraża 6  │                        │ wpis 41                │     │
│        ┌────▼────┐              ┌────▼─────┐             ┌────▼──┐ │
│        │ Zadania │              │ Questy   │   zleca     │Postaci│ │
│        │ 25 · 6  │              │ 15 · 71  │◀────────────│ 15    │ │
│        │ ▲ 1     │              │ ▲ 0      │             │ ▲ 0   │ │
│        └─────────┘              └────┬─────┘             └───────┘ │
│                                      │ wymaga                      │
│        ┌─────────┐              ┌────▼─────┐             ┌───────┐ │
│        │ Decyzje │              │ Przedm.  │   droga 17  │Miejsca│ │
│        │ 13 · ❔2 │              │ 20       │◀───────────▶│ 16·25 │ │
│        └─────────┘              └──────────┘             └───────┘ │
│                                                                    │
│   ▲ N = węzły zmienione od baseline   ═ grube = > 30 powiązań      │
├────────────────────────────────────────────────────────────────────┤
│ Zmienione od baseline (14): ⬜ ZYL-9 · ⬜ CZAS-17 · ⬜ NPC-20 · ⬜ ZDR-13 │
│ · ⬜ CZAS-18 · ⬜ UI-8 · ⬜ CZAS-19 · ⬜ ZAP-13…16 · ⬜ ZAD-9 · ⬜ DIA-13   │
└────────────────────────────────────────────────────────────────────┘
```

**Makieta 2: skupienie na queście `ryba` (poziom 3), panel węzła po prawej**

```
┌ Graf › Questy › ryba ──────────────────────────────────┬ Węzeł ─────────────────┐
│                                                        │ quest · Ryba dla Hrapka│
│  npc:hrapek ──zleca──▶ ┌────────────┐                  │ id `ryba`              │
│                        │ quest:ryba │                  │ Źródła                 │
│  scena:hrapek_spotkanie│  7 wpisów  │                  │ • write_story_data.js  │
│   ──start_quest──────▶ └─┬──┬──┬──┬─┘                  │   :277–285             │
│                          │  │  │  └─ za_pozno ◀─ noc:5 (hrapek_dead)            │
│   dialogue:tekla/bundle ─┘  │  │       ▲ czyta flag:hrapek_dead                │
│    └ czyta flag:took_bundle │  │                       │ • 04_tresc/zadania.md  │
│      czyta quest:towar=done │  │                       │   wiersz `ryba`        │
│   dialogue:wszebor ─────────┘  └─ zlowiona ◀─ scena:staw                        │
│    └ daje item:bandaze           └ czyta flag:pump_running                      │
│      ustawia flag:wszebor_fish                         │ Zasady: ZAD-?, NPC-9   │
│                                                        │ Zadania: task_09,      │
│   wpis oddana ──▶ dialogue:hrapek/ryba                 │   task_13 (scalone)    │
│      └ ustawia flag:hrapek_fed · change_rep hrapek +   │ Historia (git -S ryba) │
│                                                        │ • f56d146 task_13      │
│  ─── wygaszone: item:ryba · place:zalany · npc:tekla   │ • 8d8c550 spec         │
│                                                        │ [Otwórz w Treści →]    │
│  [F] promień 1 ▸ 2   [Esc] wróć   [ ] [ ] zmiany       │ [Pokaż w zadaniu →]    │
└────────────────────────────────────────────────────────┴────────────────────────┘
```
(Wpisy i flagi w tej makiecie pochodzą z `write_story_data.js:277–285`, `tydzien.md:40–48` i `story_director.gd:468–470`; nazwy flag `wszebor_fish`, `hrapek_fed` są przykładowe i wymagają sprawdzenia w `dialogue/`.)

**Makieta 3: „co zmienia task_20” (warstwy zamiar / pliki / fakt)**

```
┌ Graf › Zadanie: task_20 (narzędzia, gałąź spec/2026-10-27-task20) ────────────┐
│ Warstwy: [✓] zamiar (ID z zadania)  [✓] pliki z Planu  [✓] fakt (diff gałęzi) │
│ graf gry: master c82a4dd ⇄ kopia gałęzi 9a1b2c3 (18:40)                       │
├───────────────────────────────────────────────────────────────────────────────┤
│  zamiar: brak ID zasad (zadanie narzędziowe, bez ⬜; task_20.md:13–14)        │
│                                                                               │
│  pliki z Planu:                      fakt (diff gałęzi):                      │
│  ┌ tools/balance_sim.gd ┐  ─────▶   + węzeł test:golden_week                  │
│  ┌ script/run_report.gd ┐  ─────▶   ~ node:dawn_log  (+pole played_ms)        │
│  ┌ script/game_state.gd ┐  ─────▶   ~ edge noc:N ─▶ dawn_log (bez zmian)      │
│  ┌ tools/tests/test_golden_week.gd   + edge test:golden_week ─▶ noc:1…7       │
│                                      + edge test:golden_week ─▶ npc:* (sanity)│
│                                                                               │
│  nietknięte, a cytowane w kontekście zadania: story_director.gd:428–495       │
│   (noc), ognisko.dialogue:38–92  → „bot czyta, nie zmienia”                   │
├───────────────────────────────────────────────────────────────────────────────┤
│ Rozjazdy: 0 · Przybliżenia z kodu: 3 (warunki nocy)  [Otwórz zadanie →]       │
└───────────────────────────────────────────────────────────────────────────────┘
```

**Makieta 4: oś tygodnia (dni × zdarzenia; spec kontra kod)**

```
┌ Graf › Tydzień ──────────────────────────────────────────────────────────────┐
│ Filtr: postać [wszystkie ▾]  pokaż: [✓] spec (tydzien.md) [✓] kod (director) │
├────────┬───────┬───────┬───────┬───────┬───────┬───────┬───────┬─────────────┤
│        │ D1    │ D2    │ D3    │ D4    │ D5    │ D6    │ D7    │ D8 rano     │
├────────┼───────┼───────┼───────┼───────┼───────┼───────┼───────┼─────────────┤
│ poranek│ wstęp │Dobrawa│ norma │ Nasir │       │wstrząs│ostatni│ liczenie /  │
│        │ (VN)  │ ◆     │ ogł. ◆│ kaszle│       │ ślady │ dzień │ pusty obóz  │
│ dzień  │ szych-│       │Exitium│Drudzy │       │ ciało │       │             │
│        │ ta ×5 │       │ ◆●    │ 40 %  │       │Hrapka │       │             │
│ wieczór│ognisko│ opow. │ opow. │ opow. │ pieśń │ po    │ „co   │             │
│        │ luźno │  ⬜C4  │  ⬜C4  │  ⬜C4  │       │wstrząs│ kto”  │             │
│ noc    │ −3 ●  │ −3 ●  │gorącz.│ −3 ●  │drżenie│ −3 ●  │ sny   │             │
│        │szyfr+ │       │Nasira │       │ −2/−3 │       │ kreski│             │
│        │klucz? │       │ ◆●    │       │Hrapek†│       │       │             │
├────────┴───────┴───────┴───────┴───────┴───────┴───────┴───────┴─────────────┤
│ ◆ = tydzien.md  ● = story_director.gd (przybliżenie)  ⬜ = czeka na wdrożenie  │
│ Rozjazdy spec↔kod: 1 → „upomnienia Racibora dni 4–7” (spec) a `_quota_lags()` │
│ (kod, :557) — do sprawdzenia                                                  │
└──────────────────────────────────────────────────────────────────────────────┘
```
(Komórki z `tydzien.md:9–69`; noce z `story_director.gd:428–495`; „rozjazd” jest przykładem, jak widok ma zgłaszać różnicę, a nie stwierdzeniem, że ten rozjazd istnieje.)

**Makieta 5: panel węzła dla flagi `west_blasted`**

```
┌ Węzeł: flaga `west_blasted` ───────────────────────────────────────────┐
│ Znaczy: zawał na zachodzie wysadzony        (08_technika.md:41)        │
│ Ładunek: nie (bool)                                                    │
├────────────────────────────────────────────────────────────────────────┤
│ Ustawia (1)                                                            │
│  • scena:blast  story_director.gd:383 (_blast)                          │
│ Czyta (6, w tym 2 przybliżenia z kodu)                                  │
│  • miejsce:west  wymaga flag:west_blasted   write_world_data.js:103     │
│  • noc:*  miroslaw_loss +3/+10            story_director.gd:433–435 ●   │
│  • dialogue:miroslaw/…  [if has_flag("west_blasted")]  miroslaw.dialogue│
│  • dialogue:system  (stukanie za zawałem)  system.dialogue:48           │
│  • scena:hrapek_on_the_way_back           story_director.gd:364 ●       │
│ Kasuje (1)                                                             │
│  • _miroslaw_breaks()  story_director.gd:526 (wg task_20.md, Ryzyka)    │
├────────────────────────────────────────────────────────────────────────┤
│ Zasady, które o tym mówią: WYP-?, NPC-? („Dla agenta” w wyprawy.md)     │
│ Zadania: task_03 (blast), task_09 (Hrapek), task_20 (ryzyko w analizie) │
│ Historia: git log -S west_blasted → 4 commity (leniwie)                 │
│ Testy: test_day1 (blast), test_hrapek, lint (flaga czytana i ustawiana) │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Technologia

Warunki: Vite + React 19 + react-router 7, bez ciężkich zależności (`dashboard/package.json`: dziś pięć zależności: react, react-dom, react-router-dom, marked, dompurify), rdzeń `src/spec` i `src/work` bez żadnych zależności (`ARCHITEKTURA.md:64, 134`), praca offline, Windows ze Smart App Control (czysty JS jest bezpieczny, `docs/agent/README.md:65`). Liczby „unpacked” poniżej są z `npm view` (2026-10-27) i mówią o rozmiarze paczki na dysku, nie o rozmiarze w bundlu; rozmiar w bundlu podaję szacunkowo (z pamięci, niesprawdzone u źródła) i trzeba go zmierzyć `vite build` przed decyzją.

| Opcja | Wersja · licencja · unpacked | Układ 200–800 węzłów | Interakcja | Utrzymanie | Werdykt |
|---|---|---|---|---|---|
| **Własny SVG + `@dagrejs/dagre`** | 3.1.3 · MIT · 1,4 MB (bundle ok. 30–40 KB gz, szacunek) | warstwowy (Sugiyama), dobry dla DAG-ów z cyklami zrywanymi; 800 węzłów w < 1 s, w Workerze bez blokowania UI | wszystko nasze: pan/zoom przez `transform`, podświetlenia, panel; pełne `t()` i WCAG | jedna mała zależność bez React-owych API; rysowanie w naszym kodzie (~600–900 linii TSX) | **rekomendacja** |
| Własny SVG + układ warstwowy ręczny | 0 zależności | prosty Sugiyama (warstwy najdłuższą ścieżką, porządek barycentrum) ~200–300 linii TS; gorsze krzyżowania niż dagre | jak wyżej | nasz kod, testowalny jak `derive.ts` | **zapas**, gdy decyzja „bez zależności” |
| `@xyflow/react` (React Flow) | 12.12.0 · MIT · 1,2 MB (bundle ok. 50–60 KB gz, szacunek) | brak własnego układu (potrzebuje dagre/elk i tak) | gotowe: przeciąganie, minimapa, kontrolki; własne style CSS do pogodzenia z `styles.css` | większa powierzchnia API, wersje główne zmieniają się co rok | nie teraz; fallback, jeśli własny pan/zoom okaże się zbyt kosztowny |
| `elkjs` | 0.12.0 · EPL-2.0 lub GPL-3.0 · 8 MB | najlepszy układ warstwowy (porty, grupy); działa w Workerze | jak dagre (sam układ) | ciężki (GWT → JS), wolniejszy start, licencja EPL do odnotowania w `06_oprawa.md` | nie: przerost |
| `cytoscape` | 3.34.4 · MIT · 5,7 MB (bundle ok. 120 KB gz, szacunek) | wiele układów (dagre przez rozszerzenie) | własny Canvas i własny model zdarzeń, poza Reactem i poza `t()` | duży, własny styl; trudniej o dostępność klawiaturą | nie |
| `d3-force` / `d3-dag` | 3.0.0 ISC 90 KB / 1.2.2 MIT 596 KB | siłowy: niestabilny między odświeżeniami (zły do różnic); d3-dag: warstwowy, mniej dojrzały niż dagre | SVG własny | d3-dag ma niewielu opiekunów | nie (siłowy); d3-dag jako trzecia opcja |
| `sigma` + `graphology` | 4.0.4 MIT 3,4 MB + 2,7 MB | WebGL, 10 000+ węzłów | własny Canvas/WebGL | przerost dla 1000 węzłów | nie |
| Mermaid (render tekstu) | 12.2.0 · MIT · 122 MB | tylko statyczny obraz, brak filtrów, skupienia, zmian | brak | ogromna paczka | nie; co najwyżej eksport `--md` z `cli.ts graph` dla czatu |

**Rekomendacja:** własny SVG w React z układem `@dagrejs/dagre` liczonym w Web Workerze (`new Worker(new URL('./layout.worker.ts', import.meta.url), { type: 'module' })` jest naturalne w Vite). Powody: stabilny układ (ważny przy różnicach i filtrach), pełna kontrola nad dostępnością i językiem (UI.md), jedna zależność MIT, brak własnego CSS obcej biblioteki. **Zapas:** ręczny układ warstwowy bez zależności, przy decyzji 4 „nie” (§8), kosztem gorszych krzyżowań.

Granice warstw kodu: `src/graph/build.ts` i `src/graph/diff.ts` to czysty TS bez zależności (jak `src/spec` i `src/work`; testowalne w Node), `src/graph/layout.worker.ts` importuje dagre, `src/views/Graph.tsx` rysuje. Serwer (`node/work-api.ts`) dodaje `GET /work/graph` i `POST /work/graph/refresh` (uruchamia Godota jak build, 202 i praca w tle).

---

## 6. Wydajność

Szacunki z danych policzonych 2026-10-27 (§1.1):

| Warstwa | Węzły | Krawędzie (szac.) |
|---|---|---|
| zasady + karty + decyzje + zadania | 162 + 15 + 13 + 25 ≈ 215 | „opisuje”, „wdraża”, „rozstrzyga”: 150–250 |
| questy + wpisy + flagi + przedmioty + notatki + postacie | 15 + 71 + 207 + 20 + 10 + 15 ≈ 340 | ustawia/czyta/daje/wpis: 400–600 (165 `set_flag` i 121 `[if` w rozmowach plus skrypty) |
| miejsca + żyły + drogi | 16 + 25 ≈ 41 | 17 dróg + 25 żył + ~8 wymagań ≈ 50 |
| tydzień | 8 dni + 7 nocy + ~20 zdarzeń ≈ 35 | 80–150 (przybliżenia z kodu) |
| rozmowy: tytuły | ~73 | przejścia `=>` ~150 |
| rozmowy: odpowiedzi (tylko poziom 3) | 235 | 235 + warunki 121 |
| **razem bez odpowiedzi i commitów** | **≈ 700** | **≈ 900–1200** |
| z odpowiedziami | ≈ 950 | ≈ 1300–1500 |

- **Budżet:** SVG w Reakcie rysuje 1000 węzłów (jeden `<g>` z `<rect>` i `<text>`) i 1500 krawędzi (po jednym `<path>`) w kilkadziesiąt ms na współczesnym komputerze, pod warunkiem, że pan/zoom to zmiana jednego atrybutu `transform` na grupie nadrzędnej, a nie ponowny render listy. Węzły jako komponenty `memo`, klucze stabilne (identyfikatory z §1.3).
- **Układ:** dagre dla 700 węzłów i 1000 krawędzi liczy się w ułamku sekundy do ~2 s; zawsze w Workerze, z komunikatem „Układam…” i poprzednim układem na ekranie (zasada 11 UI.md).
- **Poziomy szczegółu zamiast wirtualizacji:** przegląd ma 10 węzłów, system 100–350, odpowiedzi rozmów pokazujemy tylko w skupieniu. Wirtualizacja (rysowanie tylko tego, co w oknie) nie jest potrzebna poniżej ~2000 elementów; zostawiam ją jako prosty filtr po prostokącie widoku, gdyby pełny graf z odpowiedziami okazał się potrzebny.
- **Dane:** JSON grafu gry ma rzędu 200–400 KB; `GET /work/graph` zwraca go z `ETag` = sha rewizji, więc przeglądarka nie pobiera go powtórnie.
- **Eksporter:** jak `data_lint.gd`, około 2 s plus start Godota; po `--import` (kilka–kilkanaście sekund, jeśli pamięć importu jest zimna). Uruchamiany na żądanie i po przebiegu, nigdy ciągle.

---

## 7. Etapy dostarczenia

Każdy etap to zadanie narzędziowe (dashboard i `tools/`), wdrażane w terminalu, jak task_19–24 (`WORKFLOW.md:50`), jeden wykonawca od początku do końca i najwyżej jeden przegląd Opus (reguła z `CLAUDE.md:45`). Żaden etap nie zmienia rozgrywki, więc nie potrzebuje reguły ⬜ (analogia: `task_20.md:13–14`), ale każdy dostaje plik `task_NN.md` i wiersz w planie. Koszty w tokenach to szacunek rzędu wielkości na podstawie dotychczasowych zadań dashboardu, nie pomiar.

### Faza 0: jeden wieczór, bez grafiki

- **Zakres:** `tools/graph_export.gd` (JSON gry: rejestry, flagi ustawia/czyta z `plik:linia`, wpisy questów, miejsca, drogi, żyły, rozkład obozu; rozmowy tylko jako tytuły i przejścia); `node dashboard/cli.ts graph --md|--json` (łączy `SpecIndex` z JSON-em gry: zasady, karty, zadania, księga); widok „Graf” jako **lista i drzewo** (typ → węzeł → sąsiedzi, z filtrem tekstowym i linkami do źródeł), bez rysunku.
- **Dane:** tylko to, co tanie i średnie z §1.3; przybliżenia z kodu nocy pominięte.
- **Koszt:** 1 przebieg Haiku 5.5 max (2–4 h pracy agenta, szacunek 0,5–1,5 mln tokenów), 1 przegląd Opus medium. Testy: `lint` i `unit` gry bez zmian, nowy test dashboardu `src/graph/build.test.ts` na prawdziwych plikach jak `src/work/fixtures/`.
- **Co widzi Roland:** „flaga `west_blasted`: ustawia 1, czyta 6” z linkami; „quest `ryba`: 7 wpisów, każdy z miejscem w rozmowie”; od razu lista flag czytanych przez nikogo nieopisanych (dziś ~85 %, plan §8.2) jako kandydaci do tabeli w `08_technika.md:34–54`.
- **Ryzyka:** eksporter wymaga `--import`; przy zimnej pamięci importu pierwsze uruchomienie trwa dłużej. Rozwiązanie już istnieje w buildach (kopiowanie `.godot` z kopii gałęzi, `tools/README.md:76`).
- **Strażniki:** tylko odczyt repozytoriów; JSON w `reports/graph/` dopisany do `.gitignore` (folder `reports/` już jest poza gitem, `docs/agent/README.md:36`); zero zmian w `data/`, `scene/`, generatorach.

### Faza 1: graf jednego podsystemu z podświetleniem zadania

- **Zakres:** `src/graph/build.ts` (model), `layout.worker.ts` (dagre), `views/Graph.tsx` (SVG, pan/zoom, filtry typ/znacznik/postać, skupienie, panel węzła, klawiatura, PL/EN); podsystem **questy + flagi + postacie + przedmioty**; warstwy „zamiar” i „pliki” z §3.2 dla wybranego zadania; wejścia ze strony zadania i karty zasady.
- **Dane:** JSON z fazy 0 + `WorkState`.
- **Koszt:** 2–3 przebiegi Sonnet 5.5 high (łącznie 1–2 dni agenta, 2–4 mln tokenów), 1 przegląd Opus. Testy: `build.test.ts`, `diff.test.ts`, test układu (deterministyczny wynik dla stałego wejścia), `npm run build` i `npm test` dashboardu.
- **Co widzi Roland:** makiety 1, 2 i 5; „co zadanie cytuje i dotyka” dla task_NN w jednym obrazie.
- **Ryzyka:** rozrost widoku (Runs.tsx ma już 2025 linii); trzymać `Graph.tsx` poniżej ~600 linii, resztę w `src/graph/`. Decyzja o zależności (§8, 4) przed startem.
- **Strażniki:** jak faza 0; dagre jako jedyna nowa zależność, wpis o licencji MIT w `06_oprawa.md` nie jest potrzebny (kod narzędzia, nie zasób gry), ale `package.json` go pokaże.

### Faza 2: oś tygodnia i różnica między rewizjami

- **Zakres:** `src/graph/diff.ts` (różnica dwóch grafów; strona spec z `semanticDiff`), `cli.ts graph diff A B`, widok osi tygodnia (makieta 4) z kalendarzem z `tydzien.md` i przybliżeniami z `story_director.gd` (regex po `night ==`, `day >=`, `change_sanity`), warstwa „fakt” z §3.2 (graf gry master ⇄ kopia gałęzi), automatyczne odświeżenie po przebiegu (tam, gdzie rusza build do ogrania), plakietka nieaktualności.
- **Dane:** eksporter uruchamiany w kopii gałęzi; `semanticDiff` dla spec.
- **Koszt:** 2 przebiegi Sonnet (1–1,5 dnia, 2–3 mln tokenów), 1 przegląd Opus.
- **Co widzi Roland:** „co zmieniło się od baseline” i „co naprawdę zmieniła gałąź task_NN” (makieta 3); rozjazdy spec ↔ kod w tygodniu jako lista do kart decyzji.
- **Ryzyka:** przybliżenia z kodu mogą mylić; każdy taki węzeł jest oznaczony i da się go odfiltrować. Kiedy etap 7 (D-14) przeniesie noce do danych, przybliżenia znikają same.
- **Strażniki:** eksporter w kopii gałęzi tylko czyta (żadnego `checkout`, `CLAUDE.md:9`); nie uruchamia się, gdy trwa przebieg na tym zadaniu (ta sama blokada co `cli.ts build`, `cli.ts:143–157`).

### Faza 3: zasady ↔ kod ↔ testy

- **Zakres:** krawędzie „opisuje” z sekcji „Dla agenta” (ścieżki i nazwy funkcji w backtickach), „test dotyka” z plików `tools/tests/*.gd`, pokrycie: zasada bez kodu, kod bez zasady, zasada bez testu; eksport grafu przy wydaniu (`stamp_build.js`), żeby tagi wersji dały się porównać; opcjonalnie nakładka z raportu przebiegu (`dawn_log`, `vein_log`, `game_state.gd:278–320`): ścieżka, którą gracz naprawdę przeszedł.
- **Dane:** regex po „Dla agenta”; `tools/README.md:24–46` jako mapa testów.
- **Koszt:** 2–3 przebiegi Sonnet, 1 przegląd Opus.
- **Co widzi Roland:** która z ~162 zasad nie ma śladu w kodzie ani w testach (dziś plan §8.1 mówi „3 ze 128 ID w kodzie lub testach”; moje `rg` po `script/` i `tools/` znajduje 31 różnych ID, bo liczy też komentarze; rozbieżność do wyjaśnienia przy tej fazie).
- **Ryzyka:** fałszywe „pokryte” przez samo wspomnienie ID w komentarzu; dlatego krawędź „opisuje” ma wagę (komentarz / nazwa funkcji / test), a nie tylko istnienie.
- **Strażniki:** eksport przy wydaniu idzie w commicie wydania, jak stempel i CHANGELOG (`tools/README.md:82–89`), czyli po scaleniu i za stałą zgodą na tag.

---

## 8. Decyzje dla Rolanda

| # | Pytanie | Opcje | Rekomendacja |
|---|---|---|---|
| 1 | **Plan §5 mówi „bez … grafu relacji”.** Czy zmienić? | **a)** zostawić §5 bez zmian: ten dokument idzie do szuflady · **b)** zmienić zdanie na „bez bazy danych i bez ręcznie edytowanego grafu relacji; graf tylko jako widok pochodny z plików i gita” · **c)** skreślić zakaz całkiem | **b)**. Zachowuje intencję §5 (żadnego drugiego źródła prawdy) i ma precedens: D-16 i D-33 już zmieniły §5 i §8.3 „w tym zakresie” (plan §9). Zapis jako karta decyzji w `zgloszenia/` (D-03) i jedna linia w §5. |
| 2 | **Gdzie widok mieszka?** | **a)** nowy widok „Graf” w grupie Raporty + karta na stronie zadania + link na karcie zasady · **b)** tylko panel w stronie zadania · **c)** tylko w Zmianach | **a)**. Panel w zadaniu nie pomieści przeglądu ani tygodnia; Zmiany są o koszyku i gałęziach `zmiana/*`. |
| 3 | **Który podsystem pierwszy?** | **a)** questy + flagi + postacie + przedmioty · **b)** miejsca i drogi · **c)** zasady ↔ kod | **a)**. Tam są warunki, flagi bez opisu i klasa błędów `hieronim_gone`; miejsca już mają rysunek w grze (`map_drawing.gd`) i w `miejsca.md:21–29`; zasady ↔ kod to faza 3. |
| 4 | **Nowa zależność?** | **a)** tak, `@dagrejs/dagre` (MIT, jedna paczka) · **b)** nie, ręczny układ warstwowy · **c)** React Flow (większa) | **a)**. Jedna mała paczka MIT za znacznie lepsze krzyżowania; zapas b) zostaje opisany. |
| 5 | **Eksporter strony gry: Godot czy Node?** | **a)** Godot (`tools/graph_export.gd`, rejestry i skompilowane rozmowy) + Node dla spec i gita · **b)** wszystko w Node (regex po `.gd` i własny parser `.dialogue`) | **a)**. Godot ma rejestry i kompilator Dialogue Managera za darmo; Node musiałby udawać oba. Koszt: `--import` i 2–5 s, już obsłużone przez buildy. |
| 6 | **Czy JSON grafu gry commitować?** | **a)** nie, `reports/graph/` poza gitem, odtwarzany na żądanie · **b)** commitować przy każdym zadaniu · **c)** a) + eksport tylko przy wydaniu (faza 3) | **c)**. Poza gitem na co dzień (widok pochodny, zasada 1 §3), a przy wydaniu jeden plik przy tagu, jak `gwara_slaska.json`, żeby wersje dało się porównać. |
| 7 | **Warunki nocy z kodu: przybliżenie czy czekać na „wydarzenia jako dane”?** | **a)** przybliżenie regexem, oznaczone i filtrowalne, od fazy 2 · **b)** czekać na etap 7 (D-14) | **a)**. Tydzień bez nocy jest mało wart, a oznaczenie „przybliżenie z kodu” nie udaje reguły. Etap 7 zastąpi je dokładnymi danymi bez zmiany widoku. |
| 8 | **Historia węzła: leniwie czy z góry?** | **a)** leniwie, `git log -S` po otwarciu panelu, bufor w pamięci serwera · **b)** z góry dla wszystkich węzłów przy każdym wczytaniu | **a)**. Setki wywołań gita z góry spowolniłyby wczytanie; panel otwiera się dla jednego węzła naraz. |
| 9 | **Kiedy zacząć?** | **a)** faza 0 teraz, obok PT0b · **b)** po PT0b · **c)** po etapie 4 | **a)** dla fazy 0 (jeden wieczór, narzędzie bez zmiany gry, zgodne z bramką PT0 z etapu 3), fazy 1–2 po PT0b, żeby nie powtórzyć „więcej procesu niż gry” (plan §6). |

**Filar, któremu to służy:** „czas to waluta” i „ludzie się kruszą” pośrednio, przez to, że etapy 6–7 zmienią dziesiątki warunków nocy i flag, a graf z różnicą pokaże, co naprawdę się zmieniło, zanim „złoty tydzień” powie, że coś pękło. **Konflikt z wcześniejszą decyzją:** §5 „bez grafu relacji” (decyzja 1). Inne zasady planu (bez bazy, generatory jako źródło, agent nie wpisuje wyników za człowieka, jedna gałąź z kodem w limicie D-33) zostają bez zmian.

---

## 9. Dopasowanie do obecnego wyglądu (zrzuty)

Zrzuty z działającego dashboardu (spec master `205cf18`, odczyt) leżą w `zrzuty/`; poniżej, co z nich wynika dla §4 i fazy 0.

**Pasek boczny** (`zrzuty/pl-start.png`, `zrzuty/en-start.png`). Układ to: logo, przełącznik PL | EN (dwa przyciski, aktywny niebieski), grupa główna bez nagłówka (Start, Praca z licznikiem, Przebiegi z kropką, Zgłoszenia z licznikiem, Zmiany), nagłówek wersalikami **RAPORTY** (Wdrożenia, Kolejka, Podsumowanie, Pytania), nagłówek **SPECYFIKACJA** (Szukaj, Mechaniki, Interfejs, Postacie, Świat, Treść, Balans, Pozostałe), stopka (Zespół, Instrukcja, tryb, ⇣ Pobierz zmiany, Odśwież specyfikację, Wyloguj). Pozycja „Graf” / „Graph” wchodzi jako **piąta w grupie RAPORTY, po „Pytania”**, z ikoną w stylu istniejących znaków (np. `⌬` albo `⋔`), bez licznika; opcjonalna plakietka liczbowa (jak „2” przy Pracy) tylko dla liczby węzłów zmienionych od baseline, gdy jest większa od zera. Widok działa też w trybie GitHub dla strony specyfikacji, ale eksporter gry jest tylko lokalny, więc, jak Praca i Przebiegi, część „gra” pokazuje się wyłącznie w trybie lokalnym (`ARCHITEKTURA.md:221`).

**Strona zadania** (`zrzuty/pl-zadanie-task20.png`). Kolejność kart: tytuł i plakietki („narzędzie”, „Zaplanowane”), pasek etapów (Zaplanowane → Decyzja → W pracy → Na gałęzi → Scalone → Czeka na człowieka → Sprawdzone), karta **Co można zrobić** (przyciski z cichym dopiskiem modelu „sonnet · high” i powodem), ramka „Wdróż w terminalu” (szary blok z lewą niebieską krawędzią), karta **Wymagania — tekst nie do edycji** (z metadanymi Źródło / ID / Zgłoszenia / Kolejność), **Arkusz człowieka**, **Co napisał agent** (rozwijane sekcje Analiza, Plan, Co zostało zrobione, …, Podsumowanie), **Przebiegi tego zadania** (lista z plakietką „Zakończony”, data, osoba, czas, koszt). Karta **„Co zmienia to zadanie”** z §4.1 wchodzi **między „Wymagania” a „Arkusz człowieka”**: po wymaganiach, bo warstwa „zamiar” bierze ID z pola „ID” tej karty (dla task_20 jest tam „—”, więc karta mówi „Zadanie narzędziowe: bez ID zasad; zakres z plików Planu”), i przed arkuszem, bo arkusz jest o testowaniu tego, co karta pokazuje. Treść karty: trzy wiersze liczników (ID zasad · pliki z Planu · zmienione węzły na gałęzi), miniatura skupienia (SVG do ~240 px wysokości) i link „Otwórz w Grafie →” w stylu istniejących odnośników ze strzałką („Otwórz Pracę →”, „Podgląd na żywo →”). Na etapie „Zaplanowane” miniatura jest pusta i karta pokazuje tylko zamiar i pliki; diff gałęzi pojawia się od etapu „Na gałęzi”, tak jak dziś karta wyniku przeglądu (`INSTRUKCJA.md:30`).

**Konwencje do powtórzenia w makietach** (`zrzuty/pl-start.png`, `zrzuty/pl-praca.png`, `zrzuty/pl-przebiegi.png`):
- karty białe z ramką 1 px i lekko zaokrąglonymi rogami, pogrubiony tytuł w lewym górnym rogu, treść pod poziomą linią; filtry grafu i nagłówek „graf gry z `c82a4dd`” idą do takiej karty nad rysunkiem, a panel węzła jest kolejną kartą po prawej;
- rząd liczników (pięć kafelków: duża liczba, pod nią podpis szarym) ze Startu to gotowy wzór na przegląd z makiety 1: zamiast ośmiu „superwęzłów” rysowanych ręcznie rząd kafelków „162 zasad · 207 flag · 15 questów · 25 zadań” z plakietką zmian, a graf podsystemów dopiero pod nim;
- plakietki stanu: szare z obramowaniem („narzędzie”, „spec”), kolorowe wypełnione („Zaplanowane” niebieskie, „Zakończony” zielone, „bez błędów” zielone, „W toku” z kropką); węzły grafu dostają tę samą rodzinę kolorów: ⬜ fiolet jak w kafelku „zasad ⬜ do wdrożenia”, ✅ zielony, przybliżenie z kodu szare z przerywaną ramką jak zamknięty przycisk „Odrzuć”;
- przyciski: pierwszorzędny niebieski wypełniony (jeden na kartę: „Analizuj zadanie (agent)”, „Podgląd na żywo →”), drugorzędne białe z ramką („Przerwij przebieg”, „Kopiuj polecenie”); w Grafie jedyny niebieski to „Odśwież graf gry”, reszta (poziomy, promień, filtry) jako przyciski drugorzędne i plakietki-przełączniki z `aria-pressed`;
- kolumny tablicy Praca (Zaplanowane / W pracy / Na gałęzi / Scalone / Czeka na człowieka / Sprawdzone) z kartami zadań, na których ID zasad są drobnym tekstem w `monospace` (np. `ZYL-9 CZAS-17 NPC-20`): ten sam zapis ID w panelu węzła;
- ostrzeżenia ⚠ bursztynowe, powody „nie teraz” szare (zasada 5 `UI.md`): plakietka „Nieaktualny: HEAD `f1e2d3c`” jest ostrzeżeniem, a „graf gry z … ✓ aktualny” informacją szarą.

**Korekty makiet i fazy 0.** (1) Makieta 1 traci ramkę „superwęzłów” na rzecz rzędu kafelków plus graf pod nimi; lista „Zmienione od baseline” wygląda jak lista „Teraz” (ikona, pogrubiony link, szary opis pod spodem). (2) Makieta 3 (zadanie) jest kartą na stronie zadania, a nie osobnym ekranem; pełny ekran otwiera „Otwórz w Grafie →”. (3) Makieta 5 (panel węzła) używa układu etykieta–wartość z karty „Wymagania” (Źródło / ID / Zgłoszenia / Kolejność) dla pól Znaczy / Ładunek / Źródło. (4) Faza 0 ma pokazać listę i drzewo w istniejącym szkielecie: tytuł widoku i szary podtytuł jak „Przebieg to jedno uruchomienie agenta…”, jedna karta z polem filtra i listą typów z licznikami, rozwijane sekcje jak w „Co napisał agent”; to zero nowego CSS poza `src/views/graph.css` na SVG w fazie 1. (5) Angielska wersja (`zrzuty/en-start.png`) tłumaczy tylko interfejs („Home”, „Work”, „Implementations”, „rules ⬜ to implement”), identyfikatory i nazwy plików zostają, co potwierdza zasadę 15 `UI.md` dla etykiet węzłów.

## Źródła

Przeczytane 2026-10-27, tylko odczyt. Numery linii z tej daty.

Gra (`C:/dev/gamedev/everhorror/everhorror`):
- `CLAUDE.md` (1–57): zasady 6, 7, 9, 14, 15, 37, 40, 45.
- `docs/analizy/final-plan-human-readable.md` (1–660): §3 (329–366), §5 (384–390), §6 (393–404), §8.1–8.3 (427–457), §9 D-14 (482), D-16 (515), D-29/D-30 (547–548), D-32 (573), D-33 (560); etap 3 (160), etap 4 (183–189).
- `docs/agent/README.md` (1–102): 9, 13, 14, 16, 34, 36, 65.
- `tools/README.md` (1–103): 20, 24–46, 59–72, 76, 82–89.
- `script/game_state.gd` (1053 linii): 29–46, 48–145, 117–127, 278–320, 364–372, 394–404, 802–830.
- `script/story_director.gd` (710 linii): 11–24, lista funkcji 50–703, 428–500, 523–529, 557.
- `script/camp_schedule.gd` (172): 1–60. `script/expeditions.gd` (197): 1–50.
- `tools/data_lint.gd` (303): 20–36, 44–60, 83–119, 193–250, 255–277.
- `tools/generators/write_story_data.js` (287): 6–62, 65–151, 154–174, 177–285. `tools/generators/write_world_data.js` (201): 12–30, 34–79, 83–159, 200–201.
- `dialogue/tekla.dialogue` (1–70); liczniki po `dialogue/*.dialogue` (19 plików).
- `addons/dialogue_manager/dialogue_resource.gd:21`, `compiler/compiled_line.gd:10–40`.
- `docs/ai-tasks/task_20.md` (1–80), `docs/ai-tasks/INFO.md:9–23`, lista `docs/ai-tasks/` i `done/`.
- `git log` (68 commitów na `master`), `git worktree list`.

Specyfikacja (`C:/dev/gamedev/everhorror/specification`):
- `README.md` (1–79), `WORKFLOW.md` (1–94): 15, 19, 21, 50, 72.
- `WDROZENIA.md` (1–60): Wpisy, Na gałęziach, Czeka na wdrożenie (13 pozycji), W zadaniach.
- `04_tresc/tydzien.md` (1–70), `04_tresc/zadania.md` (1–60), `04_tresc/miejsca.md` (1–50), `03_mechaniki/npc.md` (69–95), `03_mechaniki/czas.md` (78, 90–91), `08_technika.md` (12–56, 78–95).
- `zgloszenia/2026-10-27_kim-jest-ktos.md` (1–60); lista `zgloszenia/`.
- `dashboard/README.md` (1–50), `dashboard/UI.md` (1–175), `dashboard/INSTRUKCJA.md` (nagłówki, 26–40).
- `dashboard/ARCHITEKTURA.md` (1–260): 5–45, 47–60, 62–134, 136–157, 159–203, 209–225, 227–255.
- `dashboard/package.json`, `dashboard/cli.ts` (1–191), `dashboard/node/load.ts` (1–109), `dashboard/src/nav.ts` (1–143), `dashboard/src/App.tsx:353–385`, `dashboard/src/spec/model.ts` (1–236), `dashboard/src/spec/diff.ts` (1–60, eksporty), `dashboard/src/work/derive.ts` (1–50), `dashboard/src/work/gameLinks.ts` (1–80), `dashboard/src/work/parallel.ts` (1–6), `dashboard/src/data/hooks.ts` (1–82), `dashboard/src/data/store.tsx:137, 537`; rozmiary plików `wc -l`.
- `git log` (188 commitów), `git log -S "NPC-18" -- 03_mechaniki/npc.md`.

Zewnętrzne: `npm view` dla `@dagrejs/dagre`, `elkjs`, `cytoscape`, `@xyflow/react`, `d3-force`, `d3-dag`, `sigma`, `graphology`, `mermaid`, `d3-hierarchy` (wersja, licencja, `dist.unpackedSize`; 2026-10-27). Rozmiary w bundlu nie były mierzone: założenie do sprawdzenia przy fazie 1.
