<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 3f76c0f; nie edytować.
-->

# task_16: Żyły w Starej sztolni i licznik żył

Wymagania:
1. ZYL-1 (03_mechaniki/zyly_i_norma.md) ✅: „W demie jest **25 żył** w 15 miejscach, od 1 do 3 w każdym. Lista: [miejsca](../04_tresc/miejsca.md).”
2. ZYL-2 (03_mechaniki/zyly_i_norma.md) ✅: „Żyła to świecąca, pulsująca błękitem skała. [E] „Zaznacz żyłę na mapie · 1 h”. Potem stoi przy niej palik, pojawia się komunikat, a na rysunku mapy przybywa niebieska kreska.”
3. ZYL-4 (03_mechaniki/zyly_i_norma.md) ✅: „**[DECYZJA 2026-09-25]** Norma Kniazia: **12 żył do wieczora dnia 7**. Licznik jest na mapie, w ekwipunku, w notesie przy zadaniu „Złoża dla Kniazia” i w podsumowaniu wyprawy.”
4. Zgłoszenie zgloszenia/2026-10-27_zyly-stara-sztolnia.md, „Co”: „Roland, dashboard 2026-10-27: „W starej sztolni te żyły nie do końca dają się zaznaczyc, a licznik żył zaczął od 0 jak zaznaczyłem zyłe, a nie od jednego.””

Źródło: specyfikacja `3f76c0f` · ID: ZYL-1, ZYL-2, ZYL-4, `east` (`east_1`, `east_2`) · Zgłoszenia: zgloszenia/2026-10-27_zyly-stara-sztolnia.md

Priorytet: wysoki (błąd zgłoszony przez Rolanda z gry; reguły ✅ już obowiązują) · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Błąd przywraca zgodność z istniejącymi regułami ✅, więc specyfikacja się nie zmienia (D-23).

**Systemy i pliki** („Dla agenta” w `zyly_i_norma.md` i `miejsca.md`):
- `tools/generators/gen_mine_deep.gd`, ok. linii 281–299: grupa `BlueIronVeins` dostaje nakładkę `shader/blue_iron_vein.gdshader` na **sześć** skał (2 filary i 4 skały ścienne), ale `vein_mark` stoi tylko przy dzieciach 3 (`east_1`) i 5 (`east_2`). Dziecko 2 ma sam opis „Żyła błękitnego żelaza” bez zaznaczania, a pozostałe nie mają nic. Gracz widzi kilka „żył”, których nie da się zaznaczyć, a to przeczy ZYL-2. Scena `mine_deep` jest generowana: zmieniamy generator i regenerujemy, bez ręcznej edycji.
- Licznik: `GameState.set_flag` (`script/game_state.gd:364–372`) emituje „Żyła na mapie. %s.” z `quota_text()` już po ustawieniu flagi, więc z kodu wynika 1, nie 0. Najpierw trzeba odtworzyć, który licznik pokazał 0. Kandydaci: komunikat po zaznaczeniu, HUD/mapa (`script/map_screen.gd`, `script/hud.gd`), podsumowanie wyprawy (`script/expedition_summary.gd:53`: „znalezione na tej wyprawie” = różnica z zapisem startu wyprawy) i notes. Sprawdzić też, czy `LOCATIONS` zawiera `east` z `east_1`/`east_2` w chwili zaznaczenia (`data/locations/east.tres`), oraz kolejność `advance_time` → `set_flag` w `script/interactable.gd:136–183`.

**Kierunek:** w Starej sztolni zostają dokładnie 2 żyły (ZYL-1, lista w `miejsca.md`). Skały bez żyły nie świecą jak żyła albo świecą wyraźnie inaczej (np. kamień bez pulsu), a opis-pułapka „Żyła błękitnego żelaza” bez zaznaczania znika lub dostaje inną nazwę. Wybór sposobu należy do wykonawcy; wizualnie potwierdza go arkusz.

**Ryzyka:** regeneracja `mine_deep` przesuwa losowe obroty palików (`randf()` w `vein_mark`); testy `places`/`camp_walk` dotyczą obozu, a dla sztolni warto dopisać sprawdzenie w teście logiki (np. każda skała z nakładką żyły ma `VeinMark`). Po zmianie generatora `--import`.

**Testy (krótkie):** `unit`, `lint` oraz scenariusz, który zaznacza `east_1` i sprawdza komunikat „1 z 12”. Pełna analiza: `/ai-task analyze 16`.

## Analiza
(`/ai-task analyze 16`, przebieg z dashboardu 2026-10-27, Opus; tylko odczyt kodu, bez uruchamiania gry.)

**Jak jest dziś (`scene/levels/mine_deep.tscn`, z `tools/generators/gen_mine_deep.gd:281–313`).** Grupa `BlueIronVeins` ma skrypt `overlay_applier.gd`, więc nakładka `blue_iron_vein.gdshader` (błękitny puls) trafia na **wszystkie sześć** skał w grupie:

| Dziecko | Węzeł | Gdzie | Co ma |
|---|---|---|---|
| 0 | `cave_pillar_b_1` | filar na środku jaskini (75,5 / 0,2) | tylko świecenie |
| 1 | `cave_pillar_c_1` | filar na środku (78,2 / 7,2) | tylko świecenie |
| 2 | `cave_wall_rocks_c_1` | ściana wschodnia (81,7 / 1,2) | świecenie i `Interactable` (DESCRIBE) o nazwie **„Żyła błękitnego żelaza”**, bez zaznaczania |
| 3 | `cave_wall_rocks_e_1` | ściana wschodnia (81,7 / 5,4) | **`east_1`** (`VeinMark`) |
| 4 | `cave_wall_rocks_d_1` | ściana północna (76,4 / −3,6) | tylko świecenie |
| 5 | `cave_wall_rocks_f_1` | ściana południowa (72,0 / 9,6) | **`east_2`** (`@Area3D@2`) |

Do tego 4 niebieskie światła `VeinLights`, z których dwa (76,4 / −2,2 przy skale d i 76,8 / 3,8 między filarami) oświetlają skały bez żył. Gracz widzi sześć „żył”, zaznaczy dwie. Najbardziej rzucają się w oczy filary na środku, a nie da się ich zaznaczyć. To wprost łamie ZYL-2 („żyła to świecąca, pulsująca błękitem skała … [E] Zaznacz”) i opis miejsca („jaskinia z dwiema żyłami”, `04_tresc/miejsca.md`, Stara sztolnia ✅).

**Licznik „0”.** Kod liczy poprawnie:
- `Interactable.interact()` (`script/interactable.gd:127–146`) najpierw przesuwa czas, potem `_apply_effects()` → `GameState.set_flag("vein_east_1")`.
- `set_flag` (`script/game_state.gd:364–372`) ustawia flagę, a dopiero potem emituje „Żyła na mapie. Żyły błękitu: 1 z 12 · …” (`quota_text()` → `veins_mapped()` liczy po flagach z `LOCATIONS`, gdzie `east` ma `east_1`, `east_2`).
- Mapa (`map_screen.gd:58`), ekwipunek (`inventory_screen.gd:106`), notes (`notebook.gd:61`) i podsumowanie wyprawy (`expedition_summary.gd:53–55`) liczą przy każdym otwarciu na nowo, bez pamięci podręcznej. Dziennik żył (`_log_vein`, `run_report.gd`) numeruje od `n = veins_mapped()` po ustawieniu flagi, czyli od 1.

Najbardziej prawdopodobne wyjaśnienie wynika z pierwszej części błędu. Skała c nosi tę samą nazwę „Żyła błękitnego żelaza” co prawdziwe żyły, a [E] pokazuje przy niej tylko opis („… Jakby ktoś oddychał.”). Gracz „zaznacza” ją, licznik stoi na 0, a dopiero następna, prawdziwa żyła daje 1. Z punktu widzenia gracza pierwsza żyła liczy się więc jako zero. Ta hipoteza jest **niepotwierdzona**. Wykonawca musi to odtworzyć testem na prawdziwej scenie (plan, krok 3). Jeśli komunikat po `east_1` pokaże 1, a na mapie, w notesie i w podsumowaniu też jest 1, przyczyną była fałszywa żyła. Jeśli gdzieś wyjdzie 0, trzeba szukać dalej w tym widoku, a nie w `GameState`.

**Inne usterki przy okazji.**
- Drugi `VeinMark` nie ma nazwy (`@Area3D@2` w scenie): `vein_mark()` w `gen_mine_deep.gd:157` zawsze nazywa węzeł „VeinMark”, a oba trafiają pod tego samego rodzica. Działa, ale nazwa jest krucha (ścieżki w testach, zapisy). Wzorzec z `gen_locations.gd:193` to `VeinMark_<id>`.
- Testy: w `tools/interact_test.gd:7` cel `MineDeep/BlueIronVeins/cave_wall_rocks_c_1` jest właśnie fałszywą żyłą. To starszy test spoza `run_tests.sh`, ale po zmianie trzeba go poprawić. `find_interactable(under, "Żyła błękitnego żelaza")` (`tools/tests/test_base.gd:160`) bierze pierwszy pasujący węzeł, więc w `MineDeep` trafiłby dziś na skałę c.
- Żadne zadanie z „Kolejności” nie blokuje tego zadania (`Kolejność: —`). W `WDROZENIA.md` → „W zadaniach” jest `📋 czeka`. Przed wdrożeniem trzeba sprawdzić „Na gałęziach”: wolno mieć najwyżej jedną otwartą gałąź `spec/*` (task_17 ma ten sam commit specyfikacji, ale jest niezależny).

**Ryzyka.**
- Regeneracja `mine_deep` losuje na nowo obroty palików i filarów (`randf()`), a w scenie zmienią się `unique_id`. To kosmetyka, ale diff sceny będzie duży.
- Jaskinia straci część błękitnego klimatu. Światła trzeba przenieść do dwóch prawdziwych żył, nie po prostu usunąć. Ocenia to człowiek w arkuszu.
- Usunięcie albo zmiana opisu skały c to zmiana tekstu w świecie (polski). Jeśli tekst zostaje przy innej nazwie, przechodzi przez `lore-checker`.

## Plan
Kierunek z analizy wstępnej obowiązuje: w jaskini świecą i dają się zaznaczyć **dokładnie dwie** żyły. Specyfikacja się nie zmienia (przywracamy zgodność z ZYL-1/ZYL-2 i opisem `east`; D-23: bez wiersza w „Zmianach agenta poza specyfikacją”). Nie widzę pytania do Rolanda, więc nie ma karty decyzji. Wybór „zwykła skała zamiast fałszywej żyły” wynika wprost ze ZYL-2, a ostatecznie ocenia go arkusz.

1. **Generator `tools/generators/gen_mine_deep.gd`** (w kopii wdrożeniowej, gałąź `spec/2026-10-27-task16` od `master`):
   - W grupie `BlueIronVeins` zostają tylko skały e (`east_1`) i f (`east_2`). Filary b, c i skały ścienne c, d przenieść do `Chamber` jako zwykłe skały, bez nakładki. Indeksy `get_child(3/5)` zastąpić odwołaniem do zwróconych węzłów (`add()` zwraca węzeł), żeby nie zależeć od kolejności.
   - Opis-pułapkę na skale c usunąć. Rekomendacja wykonawcy: zachować nastrój tekstu przy jednej z dwóch prawdziwych żył albo zrezygnować z niego. Nie zostawiać go przy skale bez żyły pod nazwą „Żyła…”. Nowa nazwa lub tekst idzie do `lore-checker`.
   - `vein_mark()`: węzeł nazywać `VeinMark_<id>` (jak w `gen_locations.gd`).
   - `VeinLights`: ustawić dwa lub trzy światła przy skałach e i f (dla klimatu może zostać słabsze światło ogólne), żadnego przy skale bez żyły.
2. **Regeneracja** `--headless --path C:/dev/gamedev/everhorror/everhorror-wdrozenie --script res://tools/generators/gen_mine_deep.gd`, potem `--import`. Sceny nie edytować ręcznie.
3. **Test odtwarzający** (rozszerzyć `tools/tests/test_expedition.gd` albo dopisać krok w `test_day1.gd`, który i tak idzie na wschód): w `MineDeep` użyć `VeinMark_east_1` i sprawdzić, że komunikat zawiera „Żyły błękitu: 1 z 12”, `veins_mapped() == 1`, `quota_text()` na mapie polowej zaczyna się od „Żyły błękitu: 1”, a `Expeditions.veins_text(&"east")` to „żyły: 1 z 2 zaznaczone”. Po powrocie podsumowanie ma zawierać „Nowe żyły na mapie: 1”. Do tego test strukturalny w `unit` albo w tym scenariuszu: każda skała pod `BlueIronVeins` ma przy sobie `VeinMark_*`, a w `MineDeep` nie ma `Interactable` o nazwie „Żyła błękitnego żelaza” bez `on_use_flag`. Gdyby test pokazał 0 w którymś widoku, naprawić ten widok i opisać przyczynę w raporcie.
4. **`tools/interact_test.gd:7`**: zamienić cel `cave_wall_rocks_c_1` na `MineDeep/BlueIronVeins/VeinMark_east_1` (albo na samą skałę e).
5. **Testy** przez `test-runner` w kopii wdrożeniowej: `unit lint dialogue expedition day1` (z `--import`, bo zmienia się scena generowana; plików `.dialogue` i nowych `class_name` nie ma). Pełnego zestawu nie uruchamiać.
6. **Przegląd** `convention-reviewer` na diffie gałęzi.
7. **Dokumenty:** arkusz `docs/human-tasks/factcheck-test-16.md` w głównej kopii (z `factcheck_template.md`; puste strefy człowieka). Wiersze: w jaskini świecą dokładnie dwie skały; obie da się zaznaczyć [E] (1 h, palik); po pierwszej komunikat „1 z 12”; mapa, ekwipunek, notes i podsumowanie pokazują 1; jaskinia nadal wygląda niepokojąco (światło). W specyfikacji: tylko wskaźnik w „Dla agenta” (`zyly_i_norma.md`: obiekty sztolni w `gen_mine_deep.gd`, `vein_mark()`), jeśli go brakuje. Poza tym wiersz „Na gałęziach” 🧪 i „W zadaniach” 🧪, lint, commit `[agent]`, push. W `tools/README.md` poprawić opis `interact_test.gd`, jeśli zmieni się cel.

## Podsumowanie
Przyczyna pierwszej części błędu jest pewna. Generator Starej sztolni nakłada świecenie żyły na sześć skał, a zaznaczyć da się tylko dwie (`east_1`, `east_2`). Jedna ze skał bez żyły nosi nawet nazwę „Żyła błękitnego żelaza” i ma tylko opis. Licznik w kodzie liczy od 1 w komunikacie, na mapie, w ekwipunku, w notesie i w podsumowaniu. Najpewniej „0” wzięło się z próby zaznaczenia tej fałszywej żyły, ale to potwierdzi dopiero test odtwarzający. Plan: w generatorze zostają dwie świecące żyły, fałszywa żyła i zbędne światła znikają, scena jest regenerowana, dochodzi test na liczniku i strukturze jaskini, a potem arkusz do sprawdzenia w grze. Decyzja Rolanda nie jest potrzebna, a specyfikacja się nie zmienia.
