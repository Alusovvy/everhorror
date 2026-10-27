# Gra: kod, dane, testy, wydajność, demo

> Audyt 2026-10-27 · część „gra” · autor: agent (Fable 5.1 high) z pomocnikiem do odczytu kodu (Opus 5.5), tylko odczyt · czytelnik: Roland
>
> Uruchomiono tylko `tools/run_tests.sh unit lint balance` (wszystkie przeszły, 7,5 s) i generatory danych do folderu tymczasowego (porównanie z repozytorium). Pełnego zestawu nie uruchamiano. **[Z]** oznacza założenie, którego nie sprawdzono w działającej grze.

## 1. Gdzie stoi kod gry

Kod jest w dobrym stanie jak na prototyp po miesiącu pracy z agentami: statyczne typowanie prawie wszędzie (dwie nietypowane zmienne: `player.gd:74`, `save_manager.gd:51`), generatory są źródłem danych i scen (sprawdzone: regeneracja `write_story_data.js`, `write_world_data.js`, `write_gwara.js` do folderu tymczasowego daje pliki identyczne z repozytorium; generatory scen zmieniały po ostatniej regeneracji tylko komentarze), lint pilnuje ID i flag „czytanych, a nigdy nieustawianych” (dziś 0), pięć warstw testów przechodzi.

Trzy pliki trzymają prawie całą logikę:

| Plik | Linie | Warunki (`if/elif/match`) | Rola i główny zapach |
|---|---|---|---|
| `script/game_state.gd` | 1053 | 111 | Obiekt-wszystko: zegar, dziennik czasu, flagi, przedmioty, żyły, bohater, zmęczenie, postacie, pokoje dnia 1, zapis, dzienniki raportu. Dialogi używają go jako API (`using GameState`), więc podział musi zostawić go jako fasadę. |
| `script/story_director.gd` | 710 | 132 (plan mówi „ok. 107”) | Reguły nocy i poranka zmieszane z prezentacją (fade, VN). `_resolve_night()` (428–495) to czysta logika stanu, którą da się testować osobno; `_morning_events()` (543–554), `_return_to_camp()` (239–267), `_arrive()` (197–229) mieszają reguły z efektami. |
| `script/run_report.gd` | 600 | 76 | Kategoryzuje czas po **polskim tekście etykiety** (`LABEL_CATEGORY`/`PREFIX_CATEGORY`, 22–45). Powtarza tabele słów pasm. |

Reszta (`interactable.gd`, `expeditions.gd`, `camp_schedule.gd`, `vn*.gd`, `save_manager.gd`) jest czysta i mała.

## 2. Ustalenia (G1…G10, potem drobniejsze)

Każde: dowód → skutek → propozycja → koszt (S/M/L) → ryzyko → czy wymaga reguły ⬜ w specyfikacji (każda zmiana gry zaczyna się w specyfikacji; czyste narzędzia i testy nie).

### G1. Testy dzielą jeden folder zapisów z grą i z każdą kopią gałęzi (wysokie)
- **Dowód.** `tools/tests/test_base.gd:20,43–61` zachowuje i przywraca `user://saves`; nazwa projektu jest stała (`project.godot:13`), więc główna kopia, **każda kopia gałęzi** (do 3 wdrożeń naraz, D-33) i eksportowana gra piszą do tego samego `%APPDATA%\Godot\app_userdata\Everhorror`. Każdy scenariusz świata nadpisuje `auto.json` przez `capture_morning` (`story_director.gd:79,88,422`). Przebieg zabity przez `timeout 180` (`tools/run_tests.sh:27`) nigdy nie przywraca zapisów.
- **Skutek.** Dwa wdrożenia naraz ścigają się o zapis i przywrócenie; po zabitym teście slot AUTO Rolanda jest nadpisany. To realne ryzyko przy D-33 i przy testach po stronie serwera (`proces.md` P5).
- **Propozycja.** `SaveManager.SAVE_DIR` i `RunReport.REPORT_DIR` stają się zmiennymi, które `test_base._boot()` ustawia na `user://test-runs/<pid>/`; po teście folder jest kasowany. **[Z]** Godot 4 nie ma przełącznika wiersza poleceń na folder użytkownika.
- **Koszt.** S. **Ryzyko.** Niskie. **⬜?** Nie (hak testowy, gra bez zmian).

### G2. Załamanie bohatera w nocy jest połykane: przyczyna znaleziona (wysokie; błąd znany ze zgłoszenia)
- **Dowód.** `_sleep()` ustawia `_busy = true` (`story_director.gd:403`); `_resolve_night()` obniża poczytalność (462, 472, 477); sygnał `player_broke` trafia do `_on_player_broke`, który wraca od razu przy `if _busy: return` (582–583). To samo w scenach VN prowadzonych przez fabułę, np. ciało Hrapka w `_return_to_camp` (242 → `hrapek.dialogue:106`). Żaden test nie dotyka `player_broke` (0 trafień w `tools/`). Zgłoszenie: `zgloszenia/2026-10-27_zalamanie-w-nocy.md`.
- **Skutek.** Etap 6 (−3 za godzinę po 22:00) zrobi z tego częsty przypadek.
- **Propozycja.** Kolejkować `player_broke`, gdy `_busy`, i rozstrzygać po sekwencji; scenariusz testowy „załamanie w nocy”. Zrobić **po** teście „złoty tydzień” (task_20), bo zmienia wynik nocy.
- **Koszt.** S. **Ryzyko.** Średnie. **⬜?** Tak albo rozstrzygnięcie karty zgłoszenia (zmienia przebieg nocy).

### G3. Trzy systemy używają polskiego tekstu jako klucza (wysokie dla wersji angielskiej)
- **Dowód.** `asked` ma klucz `"<npc>|<tekst odpowiedzi>"` (`game_state.gd:694–698`, `vn.gd:71–72`); kategorie czasu raportu to dokładne polskie etykiety (`run_report.gd:22–45`); gwara jest kluczowana dokładną linią (`settings.gd:73–75`, `write_gwara.js`). Dialogue Manager obsługuje stałe ID linii i tłumaczy po ID (`addons/dialogue_manager/dialogue_manager.gd:755–769`); w `dialogue/` nie ma dziś żadnego `[ID:`. W `script/` 0 wywołań `tr(`, brak tabeli `Texts`; generowanie POT jest już skonfigurowane dla 19 plików (`project.godot:97`); gwara to `Translation` z locale na stałe „pl” (`settings.gd:56–75`).
- **Skutek.** Przełączenie języka zepsuje zapisy (`asked`), raport i gwarę. Każda poprawka literówki w kwestii górnika wymaga edycji klucza w JS.
- **Propozycja.** Stałe ID: najpierw ID linii Dialogue Manager we wszystkich plikach i klucze gwary po ID (`write_gwara.js`), potem ID kategorii czasu i `asked` (ze zgodnością wstecz dla starych kluczy). To naprawia polską grę i otwiera angielską (D-09).
- **Koszt.** M. **Ryzyko.** Średnie (zgodność zapisów; potrzebne zapisy-wzorce z G-E4). **⬜?** Nie dla ID (narzędzia), tak dla opcji języka.

### G4. Testy dialogów idą jedną ścieżką, nie po gałęziach (średnie)
- **Dowód.** `tools/dialogue_test.gd:569–593` (`_talk()`) wybiera pierwszą dozwoloną odpowiedź o zadanym początku tekstu i nie eksploruje. Dopasowanie literałów z testów do 235 odpowiedzi: **ok. 67 (29 %)** jest kiedykolwiek wybieranych po nazwie (szacunek hojny). Najsłabiej: Tekla 17 niewybranych, Wszebor 16, Mirosław 14. `wait_idle()` w testach świata odpowiada pierwszą opcją i liczy to jako błąd.
- **Skutek.** Odpowiedź, której dalszy ciąg wywala błąd w `$>`, wychodzi dopiero u gracza.
- **Propozycja.** Eksplorator: dla każdego tytułu przejście wszerz z „pobłażliwym” `GameState` (każda odpowiedź dozwolona, mutacje na stanie jednorazowym), jedyna asercja to brak błędu silnika. Podnosi „wykonane choć raz” do blisko 100 % bez pisania ścieżek. Z czasem oprzeć lint dialogów o kompilator Dialogue Manager zamiast wyrażeń regularnych (daje tytuły, odpowiedzi, warunki, mutacje jako dane; to samo karmi widok grafowy).
- **Koszt.** M. **Ryzyko.** Niskie. **⬜?** Nie.

### G5. Bot balansu kopiuje reguły gry zamiast ich używać (średnie)
- **Dowód.** `tools/balance_sim.gd:193` „Mirrors StoryDirector._arrive”, `:215` „Mirrors StoryDirector._return_to_camp”; reguły marszu, zmęczenia i powrotu przepisane obok `story_director.gd:197–263`.
- **Skutek.** Zmiana w grze przestawia liczby K1 bez ostrzeżenia; etap 6 stroi normę „botem”, który może liczyć inną grę.
- **Propozycja.** Wyciągnąć czyste reguły marszu i powrotu do `Expeditions` i wołać je z obu miejsc; linie `BALANCE[…]` są własnym testem regresji.
- **Koszt.** S–M. **Ryzyko.** Niskie. **⬜?** Nie (zachowanie bez zmian). Można przed złotym tygodniem.

### G6. Wydajność: 91 świateł, 64 z cieniami, bez zasięgów, mgła wolumetryczna i SSIL (średnie)
- **Dowód.** `scene/world.tscn` ładuje naraz `mine`, `mine_deep`, `camp`, `locations` (linie 5, 16, 20, 27). Zliczone w `.tscn`: `locations.tscn` 63 Omni + 1 Spot, 47 z cieniami, 579 `MeshInstance3D`, 1413 węzłów; `camp.tscn` 15 świateł; `mine_deep.tscn` 7; `world.tscn` 5. Nigdzie `distance_fade`, `visibility_range` ani `OccluderInstance3D`; `project.godot` bez sekcji `[rendering]` poza sterownikiem D3D12 (139–140); środowisko z SSAO, SSIL, glow i mgłą wolumetryczną (`world.tscn:58–72`). `light_flicker.gd:28–34` zmienia energię co klatkę każdemu światłu, także w miejscach 200 m dalej. Światła żył mają `shadows = true` (`gen_locations.gd:146–147`).
- **Skutek.** Plan (K7) chce pomiaru przed mgłą i dźwiękiem 3D etapu 5; dziś nie ma czym mierzyć. **[Z]** Najprawdopodobniejszy koszt GPU: cienie świateł w obozie przeliczane co klatkę, bo ~10 animowanych postaci stoi w ich zasięgu.
- **Propozycja.** (1) `tools/perf_probe.gd` (okno jak `screenshot.gd`, kamery z `views_tour.json`: obóz przy ognisku, Kryształowa galeria, chodnik): 120 klatek rozgrzewki, 600 pomiaru, p50/p95/max z `Time.get_ticks_usec()`, `RenderingServer.get_rendering_info` (draw calls, obiekty, prymitywy); linie `PERF[obóz]: p50 9,8 ms p95 14,1 ms draws 812`; jak bot, **mierzy**, a czerwone tylko ponad budżet na tej maszynie (np. p95 > 16,7 ms albo 1,5× zapisanego odniesienia). (2) Tanie zyski w generatorach, po pomiarze przed i po: cienie wyłączone w 15 światłach żył; `distance_fade` (~25–30 m) dla świateł generowanych (lokacje są 60–200 m od obozu); niższy `light_volumetric_fog_energy` dla świateł pobocznych; `visibility_range_end` dla drobnych rekwizytów. (3) Później: wyłączanie przetwarzania i widoczności gałęzi lokacji, w których bohatera nie ma (`StoryDirector` zna `current_place()`; `story_director.gd:95–115`), plus zatrzymanie `LightFlicker._process` tam. Occlusion culling i LightmapGI nie teraz (sceny generowane i migotanie im przeszkadzają).
- **Koszt.** (1) S–M, (2) S, (3) M. **Ryzyko.** (2) wygląd: dlatego reguła w specyfikacji i zrzuty przed/po; (3) interaktywne obiekty, znaczniki i postacie w terenie żyją w tych gałęziach — cały zestaw świata musi przejść. **⬜?** (1) nie, (2) i (3) tak (`06_oprawa.md` / `08_technika.md`).

### G7. Eksport „wszystkie zasoby”: 235 MB exe, 118 MB zip, 341 MB cache kopiowany przy każdym buildzie (średnie)
- **Dowód.** `export_presets.cfg:9` `export_filter="all_resources"`; tylko 51 z 94 śledzonych glTF w `assets/prop_pack` jest gdziekolwiek użytych (sceny, skrypty, generatory). `.godot` głównej kopii 341 MB, `everhorror-wdrozenie/.godot` 340 MB; każdy build do ogrania kopiuje cały cache do tymczasowej kopii (`specification/dashboard/node/playbuild.ts:472–473`), potem importuje i eksportuje (ostatni build: 61 s, manifest `build/do-ogrania/…task17….json`). Repozytorium: pakiety `.git` 139 MB, `assets/` 259 MB bez LFS.
- **Skutek.** Przy 3 kopiach gałęzi i buildach to ok. 1–1,4 GB dysku i kopiowanie przy każdym buildzie; tester pobiera 118 MB.
- **Propozycja.** Próba eksportu „wybrane sceny i zależności” (`main_menu` + `world`) ze smoke testem `day1`; `.gdignore` w nieużywanych folderach pakietów (mniejszy cache i build); później: usunięcie nieużywanych glTF z HEAD (task_21 robi część). Nie ma w `script/` dynamicznych `load()` ze sklejanych ścieżek, więc eksport po zależnościach jest bezpieczny **[Z]**: zapis gry nie mierzony.
- **Koszt.** S. **Ryzyko.** Niskie (smoke test). **⬜?** Nie.

### G8. Demo (etap 9) nie ma przełącznika ani klifu w dniu 3 (średnie, na później)
- **Dowód.** `LAST_DAY = 8`, `QUOTA = 12`, `QUOTA_DAY = 7` (`game_state.gd:32–35`); koniec tylko z `_sleep` przy `day >= LAST_DAY` (`story_director.gd:413`). Spotkanie z Exitium odpala się przy pierwszym przybyciu gdziekolwiek w dniu ≥ 3 (`story_director.gd:285–288, 332–339`): gracz, który w dniu 3 zostaje w obozie, spotyka ich w dniu 4. `custom_features=""` (`export_presets.cfg:8`), nigdzie `OS.has_feature`. Zakończenie tygodnia już mówi „Tu kończy się wersja demo” (`story_director.gd:633,635`). D4 (w demie tylko autozapis) wymaga bramki na SAVE GAME w `pause_menu.gd`. Zapowiedź Racibora i poranny toast mówią o 7 dniach (`story_director.gd:544–547`).
- **Propozycja.** Teraz (narzędziowo): drugi preset eksportu „Windows Demo” z `custom_features="demo_cut"` i pomocnik `GameConfig.demo_cut()` bez zachowania. Przed etapem 9 (reguły ⬜): wymuszony wyzwalacz spotkania w dniu 3 (naturalny punkt: po `VN.play(DRUDZY_DIALOGUE, "meeting")`, linia 339), plansza końca dema, bramka zapisu.
- **Koszt.** S teraz, M przy etapie 9. **⬜?** Preset nie; zachowanie tak.

### G9. Liczby nocy i słowa pasm w kodzie, powtórzone 3–4 razy (średnie)
- **Dowód.** Reguły nocy jako literały (`story_director.gd:432–480, 507–520`), `_quota_lags` (560), −3 za późny powrót (263), poczytalność 20 po załamaniu (593); te same wartości ręcznie w `07_balans.md:81–106` specyfikacji, nic nie sprawdza zgodności. Słowa pasm: `game_state.gd:648,651`, `run_report.gd:50–51`, `story_director.gd:630`; formy żeńskie `run_report.gd:56–59` plus gałęzie `if female` w notesie. Gramatyka: `"Do wieczora dnia %d Kniaź chce %d żył…"` (`story_director.gd:547`) — rzeczownik po liczbie jest stały, więc norma etapami 4/8/14 da „4 żył”; lint T7 z task_22 tego nie złapie. Zmiany poczytalności bohatera rozsiane po dialogach (`ognisko.dialogue:38,44,55,75,92`, `ottokar`, `hieronim`) i generatorach (`sanity_change` w `gen_locations.gd`).
- **Propozycja.** Teraz: jedna tabela `Texts`/`Bands` (słowa pasm, formy żeńskie), czyli dom dla konwencji K6; lint na `%d <rzeczownik>`. Po złotym tygodniu: liczby nocy i poranka jako zasób `Balance` generowany z tabel `07_balans.md` („wydarzenia jako dane”, część 1, etap 7).
- **Koszt.** S teraz, L później. **Ryzyko.** Niskie teraz; wysokie później, dlatego tylko ze złotym tygodniem przed i po. **⬜?** Tabela nie; dane z balansu to zmiana procesu (D-14 już to przewiduje).

### G10. Drobne, ale prawdziwe (niskie–średnie)
- Płeć postaci z liczby magicznej: `female = ${o.eye === 1.57 ? "true" : "false"}` (`write_story_data.js:30`); zmiana wysokości oczu portretu zmienia płeć w notesie i raporcie. → jawne pole `female:` w tabeli (wynik ma zostać identyczny, co sprawdzi `check_generated`).
- Nic nie wymusza „generator = źródło”: dziś zgodne, ale sprawdzone tylko ręcznie. → `node tools/check_generated.js` (regeneracja do folderu tymczasowego i diff) w warstwie `lint`; dla scen diff z pominięciem `unique_id=` **[Z]**.
- 10 flag fabularnych tylko zapisywanych, nigdy nieczytanych: `bolko_day2_secret`, `got_rope`, `hrapek_left`, `ott_has_maps`, `ottokar_offer_open`, `wsz_told_brother`, `drudzy_met_at`, `welf_wounded_day`, a `ottokar_knows_crystal` i `reminder_day` czytają tylko testy. Lint sprawdza tylko odwrotny kierunek (`data_lint.gd:226–250`) i wyrzuca wynik. Spis flag: 233 literałów (225 zapisywanych, 196 czytanych) plus rodziny `vein_*`, `visited_*`, `fever_*`, `first_room_*`. → lint „zapisane, nigdy nieczytane” jako ostrzeżenie; rejestr z task_22 K4 ma raportować oba kierunki.
- Prawdopodobne naruszenie DIA-2 **[Z]**: `hrapek.dialogue:24` „Mam dla ciebie rybę” ma tylko `has_item("ryba")`, bez bramki questa, więc po oddaniu ryby opcja zostaje wyszarzona „(brak: ryba)” na każdym spotkaniu. → `quest_state("ryba") == "active" and has_item("ryba")`; to poprawka przywracająca istniejącą regułę (D-23: bez wiersza), do potwierdzenia na DIA-2.
- Zapisy bezpośrednio na pola z pominięciem API: `GameState.player_health = …` (`story_director.gd:476`), `player_sanity = 20` (593), `hour = …` (595), `GameState.hour -= TALK_MINUTES/60` (`vn.gd:83`, oddaje 5 minut, ale nie zmęczenie dodane w `add_quiet_time`, `game_state.gd:242–245`). → metody `fever_night_damage()`, `set_hour()`, `refund_quiet_time()`; po złotym tygodniu.
- `_roaming_drudzy()` ustawia `welf_wounded` i `welf_wounded_day` (`story_director.gd:313–318`), choć ma tylko wyliczać kandydatów. → przenieść skutek do `_roll_encounter`.
- Zapis: nieatomowy (`save_manager.gd:66–73`), `version` zapisywane (115), nigdy nie czytane; zapis z nowszej wersji wczytuje się po cichu; `npcs[key] = saved_npcs[key]` zastępuje cały wpis (`game_state.gd:1026–1029`), więc nowe pole postaci znika w starym zapisie. ZAP-13…16 ⬜ już to obejmują. → zapisy-wzorce `tools/tests/saves/v3…v6.json` i test wczytaj → zapisz → porównaj (S).
- `bump_flag()` nie emituje `flags_changed` (`game_state.gd:417–420`), inaczej niż `set_flag`. Dziś nieszkodliwe.
- `run_tests.sh:35` czerwieni tylko na `SCRIPT ERROR`; `push_error` („Could not read gwara”) przechodzi na zielono; autoload Beehave drukuje `ERROR: Capture not registered: 'beehave'` w każdym logu headless (task_21 go usuwa). → czerwone na `^ERROR:` z krótką listą wyjątków.
- Pełny zestaw: ok. 4 min sekwencyjnie (`reports/full_suite_3.txt`: suma ok. 242 s; najcięższe `hrapek` 35 s, `camp_walk` 27 s, `day1` 23 s, `week` 23 s). **[Z]** Większość to tweeny i timery w czasie rzeczywistym (`screen_fade.gd:27–44`: 0,7–1,2 s, karty 2,2–2,6 s). → po G1: `run_tests.sh -j 3` (jeden `--import`, shard czystych warstw + dwa shardy świata; szacunek 4 → 1,5 min **[Z]**) i opcjonalne `Engine.time_scale = 4` poza `camp_walk` i `places` (zmierzyć na jednym scenariuszu).
- Luki w testach: załamanie bohatera, szepty i winieta (0 testów; i tak prawie nie startują, plan §8.1), menu i sloty zapisu, zawartość notesu, noc jako całość (tylko wybrane noce w `test_week.gd`), wczytywanie prawdziwych starych zapisów (stare zapisy są budowane w teście: `unit_test.gd:433–450`), regresja wizualna, wydajność.
- GdUnit4: usunąć (zgodnie z task_21): brak zestawów, CLI ściga się z cache importu, wtyczka ładuje się w edytorze (`project.godot:42`).

## 3. Co ze „złotym tygodniem” (task_20, K5)

Zakres task_20 jest trafny. Uzupełnienia:
- **Zrzut `dawn_log`**, nie własna struktura: już zapisuje o świcie bohatera, każdej postaci poczytalność, zdrowie, zaufanie, status, gorączkę i przybycie oraz posortowane nowe flagi (`game_state.gd:278–316`). Plik złoty = `JSON.stringify(dawn_log, "\t", true)` + tekst nowin z każdego `_resolve_night()` + `_morning_subtitle()`. Bez pola czasu realnego (task_20 to mówi).
- **Pułapki determinizmu:** `reset()` losuje pokoje dnia 1 bez ziarna (`game_state.gd:217`, `922–932`) → ziarno albo ustawienie `first_room_*` po `reset()`; `_roll_encounter` i `hrapek_due` używają `hash()` tekstów (`story_director.gd:291,361`), stabilne w jednej wersji silnika **[Z]**; JSON zamienia int na float → porównywać przez `int()` albo w formie tekstowej.
- **Trzy–cztery tygodnie, nie jeden:** „zaniedbanie” (bez pocieszania, `tekla_reported`, bez leków, przemoczenie dnia 2), „opieka” (`mir_comforted`, `mir_company` co dzień, leki dla Nasira, Welf uratowany, ≥ 4 wskazówki Czternastego), „kryształ do Dobrawy” (`dobrawa_leaving`), tydzień bota „żyły”.
- **Także tabela `CampSchedule.placement()`** (7 dni × 5 godzin × postać): tanie, łapie regresje rozkładu.
- **Granica:** goły `StoryDirector` nie uruchomi `_morning_events` (otwiera VN) ani −3 za późny powrót i grozy przybycia; opisać tę lukę do czasu wydzielenia czystych `NightRules`/`MorningRules`.

Czego **nie** ruszać, zanim złoty tydzień istnieje: `_sleep`, `_resolve_night`, `_resolve_new_people`, `_morning_events`, `_morning_subtitle`, poprawka G2, zapisy na pola (G10), podział `StoryDirector`, liczby jako dane (G9).

## 4. Łatwe zyski gry (każdy do 2 h dla Haiku/Sonneta)

| ID | Co | Co Roland widzi albo przestaje robić | Koszt | Ryzyko | ⬜? |
|---|---|---|---|---|---|
| G-E1 | Osobny folder zapisów i raportów na przebieg testów (G1) | Testy nie nadpisują slotu AUTO i nie ścigają się między kopiami gałęzi | S | niskie | nie |
| G-E2 | Lint: flagi tylko zapisywane, `%d <rzeczownik>`, ostrzeżenie DIA-2 dla warunków tylko na przedmiot (złapie `hrapek.dialogue:24`) | Mniej arkuszy „czemu ta opcja jest szara” | S | niskie | nie |
| G-E3 | `run_tests.sh` czerwone na `^ERROR:` (wyjątek beehave do task_21) | Błąd wczytania gwary czy danych nie przechodzi na zielono | S | niskie | nie |
| G-E4 | Zapisy-wzorce v3…v6 i test w obie strony | Wiadomo, że stare zapisy testerów się wczytują | S | niskie | nie |
| G-E5 | `tools/check_generated.js` w warstwie `lint` | Ręczna edycja `.tres` jest wykrywana | S | niskie | nie |
| G-E6 | `tools/perf_probe.gd` z liniami `PERF[…]` (K7) | Liczba klatek przed mgłą i dźwiękiem etapu 5 | S–M | niskie | nie |
| G-E7 | Jawne pole `female:` w `write_story_data.js` | Nikt nie zmieni płci przypadkiem | S | niskie (wynik identyczny, G-E5 to udowodni) | nie |
| G-E8 | Preset „Windows Demo” z `demo_cut` i pusty `GameConfig.demo_cut()` | Przygotowanie D2 i D4 | S | niskie | preset nie |
| G-E9 | Bramka DIA-2 na rybie Hrapka | Opcja ryby nie jest szara na zawsze | S | niskie | poprawka reguły (bez wiersza, D-23) |
| G-E10 | Eksport po zależnościach scen + `.gdignore` nieużywanych pakietów (G7) | Mniejszy ZIP, szybszy build do ogrania | S | niskie (smoke `day1`) | nie |
| G-E11 | Cienie żył wyłączone i `distance_fade` w generatorach świateł, mierzone G-E6 (G6) | Więcej klatek, szczególnie na laptopach testerów | S | niskie–średnie | **tak** |
| G-E12 | Poprawka połykanego załamania (G2) | Zgłoszenie zamknięte; noce z ceną w etapie 6 bezpieczne | S | średnie | **tak**; po złotym tygodniu |

## 5. Zmiany długoterminowe gry (kolejność i warunki)

1. **Reguły nocy i poranka jako dane** (etap 7, część 1): złoty tydzień (task_20) → czyste `NightRules`/`MorningRules` (statyczne, tylko `GameState`, zwracają nowiny i rodzaj zdarzenia) + cienka warstwa prezentacji → liczby do zasobu `Balance` generowanego z tabel `07_balans.md` → złoty test dowodzi identycznych wyników. Warunki: task_20 scalone, zapisy na pola zastąpione metodami.
2. **Stałe ID treści wszędzie** (G3): ID linii DM + klucze gwary po ID → ID kategorii czasu i `asked` z migracją i zapisami-wzorcami → ścieżka angielska (POT → `en.po` jako szkic LLM do przeglądu Rolanda, opcja języka, locale z opcji, `Texts` z ID dla literałów skryptów (91 z polskimi znakami, ok. 125 z frazami; 41 w `run_report.gd`, które są dla dewelopera), CSV ID → pl/en z generatorów dla `.tres` i interaktywnych obiektów). Koszt razem M–L; kroki 1 i 3 najpierw, bo wzmacniają też polską grę.
3. **Rejestr flag jako dane:** `docs/agent/flags.md` z task_22 K4 → zadeklarowany rejestr (`data/flags.json`: nazwa, właściciel, typ ładunku, „do raportu”/„martwa”) sprawdzany przez lint w obie strony → opcjonalnie typowane ładunki. Nie przenosić flag do stałych w dialogach (19 plików zmian, mały zysk).
4. **Strumieniowanie scen:** najpierw wyłączanie gałęzi, w których bohatera nie ma (G6.3) → później `locations.tscn` podzielone na miejsca, ładowane w `_arrive` pod istniejącym fade (`story_director.gd:204–221`). Warunki: sonda K7, zielony cały zestaw świata, znaczniki rozwiązywane po załadowaniu (`_marker`, 117–125).
5. **Lint i eksplorator dialogów na kompilatorze DM** (G4): zamiast wyrażeń regularnych; z tych samych danych DIA-2, `[#free]`, liczby w tekście i węzły dla widoku grafowego.
6. **Eksport treści dla widoku grafowego:** źródła, które narzędzie może czytać bez parsera GDScriptu: `dialogue/*.dialogue` (tytuły, odpowiedzi, warunki, mutacje `set_flag`/`quest_log`/`give_item`/`change_*`), generatory `gen_locations/gen_camp/gen_mine_deep.gd` (interaktywne obiekty: `on_use_flag`, `required_flag`, `hidden_by_flag`, `required_item`, `on_use_item`, `on_use_quest(_entry)`, `wound`, `sanity_change`, żyły), `write_world_data.js` (graf miejsc, godziny, `requires` z `flag:`/`noflag:`/`item:`, żyły, groza), `write_story_data.js` (postacie, notatki, questy i wpisy), `camp_schedule.gd`/`field_schedule.gd`, stałe `game_state.gd` (`FIRST_MEET`, `FIRST_ROOMS`, `ARRIVAL_FLAG`, `FOURTEENTH_CLUES`, `FIXED_SANITY`), `run_report.gd` (kategorie), `gwara_slaska.json`, spec `07_balans.md` i `WDROZENIA.md`; `data_lint.gd` już ma wyrażenia do większości. Szczegóły i projekt: `widok-grafowy.md`.

## 6. Uwagi do zaplanowanych zadań narzędziowych

- **task_20:** trafne; dodać zrzut `dawn_log`, ziarno pokoi dnia 1, kilka tygodni skryptowanych; zapisać granicę (bez `_morning_events`, bez kary za późny powrót).
- **task_21:** pełna zgoda; linia `ERROR` Beehave w każdym logu to jeszcze jeden powód.
- **task_22:** K6 ma ok. 91–125 literałów, nie ~300 (40 z nich w raporcie dla dewelopera, można wyłączyć); K4 ma raportować także flagi tylko zapisywane; T7 ma łapać też `%d <rzeczownik>`.
- **Plan §8.1:** „3 ze 128 ID reguł” jest nieaktualne: 31 ID w `script/`, `tools/`, `dialogue/` (ok. 165 ID w specyfikacji).

## Źródła

`script/game_state.gd`, `story_director.gd`, `run_report.gd`, `save_manager.gd`, `vn.gd`, `vn_balloon.gd`, `interactable.gd`, `expeditions.gd`, `camp_schedule.gd`, `settings.gd`, `player.gd`, `light_flicker.gd`, `screen_fade.gd`; `scene/world.tscn`, `scene/levels/*.tscn`; `tools/run_tests.sh`, `tools/tests/test_base.gd`, `unit_test.gd`, `data_lint.gd`, `dialogue_test.gd`, `balance_sim.gd`, `tools/generators/*`; `dialogue/*.dialogue`, `dialogue/gwara_slaska.json`; `project.godot`, `export_presets.cfg`, `.gitattributes`; `addons/dialogue_manager/dialogue_manager.gd:755–769`; `reports/full_suite_3.txt`, `reports/tests/*.log`; `build/do-ogrania/*.json`; `specification/dashboard/node/playbuild.ts:472–473`; spec `07_balans.md`, `06_oprawa.md`, `zgloszenia/2026-10-27_zalamanie-w-nocy.md`; `docs/ai-tasks/task_20…22.md`; plan §8.1.
