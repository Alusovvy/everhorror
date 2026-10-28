<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zgłoszenia ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_25: Eksport gubi listy (licznik żył 0, warunki dróg) i test eksportu

Wymagania:
1. Zgłoszenie zgloszenia/2026-10-27_eksport-gubi-listy.md (błąd), „Co”: „Roland, czat 2026-10-27: „Żyły błękitu przy zaznaczeniu dalej się nie naliczają, wyskakuje u góry 0 z 12.”

Przyczyna jest inna, niż zakładał task_16. Kod licznika jest dobry, ale **eksport gry gubi wszystkie listy tekstów** (`PackedStringArray`) w zasobach i scenach. W grze uruchamianej z edytora (tam biegną wszystkie testy) listy są pełne, a w spakowanej grze z ZIP-a są puste. Gra z ZIP-a nie zna więc żadnej żyły ani żadnego warunku wejścia do miejsc.”
2. To samo zgłoszenie, łamane reguły ✅: „- [ZYL-4](../03_mechaniki/zyly_i_norma.md): licznik żył na mapie, w ekwipunku, w notesie, w podsumowaniu i w komunikacie zawsze „0 z 12”; normy nie da się osiągnąć, a rano w dniach 4–7 Racibor upomina zawsze ([ZYL-5](../03_mechaniki/zyly_i_norma.md)).
- [ZYL-2](../03_mechaniki/zyly_i_norma.md) i [WYP-3](../03_mechaniki/wyprawy.md): na rysunku mapy nie przybywają niebieskie kreski, a lista miejsc nie pokazuje „żyły 1/2”.
- [WYP-7](../03_mechaniki/wyprawy.md), [WYP-4](../03_mechaniki/wyprawy.md): warunki wejścia są puste, więc miejsca się nie zamykają (sprawdzone w zapisie Rolanda dla Zawalonego chodnika i Upadowej, wynika z danych dla reszty). Do Upadowej i Ślepego szybu idzie się bez liny, do Zawalonego chodnika przed wybuchem, do Kaplicy przed jej odkryciem, do Zalanego chodnika przy stojących pompach, do Galerii bez oleju.
- [ZAP-11](../03_mechaniki/zapis_i_opcje.md): raport przebiegu ma przy każdej żyle „n = 0”, więc nie poda, kiedy padła norma.
- Wygląd postaci ([oprawa](../06_oprawa.md#kierunek-wizualny)): części modelu, które scena chowa (`hidden_meshes`: kaptur Racibora, Sobka i Welfa, części modelu Hrapka), w wydanej grze są widoczne.”

Źródło: specyfikacja `67b762e` · ID: ZYL-2, ZYL-4, ZYL-5, WYP-3, WYP-4, WYP-7, ZAP-11 (reguły ✅, bez zmian) · Zgłoszenia: zgloszenia/2026-10-27_eksport-gubi-listy.md
Poziom: rozgrywka

Priorytet: najwyższy (plan gry: PT0b zaczyna się od nowa dopiero na buildzie z tą poprawką; Roland, czat 2026-10-27: „ok”) · Kolejność: pierwsze, przed resztą uwag z playtestu 2026-10-27

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Błąd łamie istniejące reguły ✅, więc nowej reguły nie trzeba (D-23). Zgłoszenie ma pełną diagnozę i sprawdzoną poprawkę (sekcje „Dowody” i „Odpowiedź agenta”).

**Systemy i pliki:**
- `project.godot`: `[editor]` `export/convert_text_resources_to_binary=false`. Sprawdzone sondą na czystej kopii `c82a4dd`: z tym ustawieniem eksport ma pełne `LocationData.veins`, `requires` i `hidden_meshes`. Alternatywa (typowane `Array[String]` w `script/data/location_data.gd`, `tools/generators/write_world_data.js`, `script/character_model.gd`) jest niesprawdzona; wybrać ją tylko po tej samej sondzie.
- Nowa krótka warstwa testu eksportu (propozycja z „Odpowiedzi agenta”, np. `tools/export_smoke`): eksport debug kopii gałęzi do folderu tymczasowego ze sceną-sondą i odczyt linii `RESULT` z gry spakowanej: liczba żył 25, każda lista `requires` jak w `data/locations`, `veins_mapped()` po ustawieniu flagi = 1, niepuste `hidden_meshes` modeli, `PackedColorArray` w `camp.tscn` (`colors =`). Opis w `tools/README.md#testy`; build do ogrania (D-32, `cli.ts build`) i kroki wydania (`tools/README.md#wydanie`) powinny ją uruchamiać przed spakowaniem ZIP-a (zmiana po stronie dashboardu to osobna rzecz w repo specyfikacji, nie w tym zadaniu, chyba że Roland postanowi inaczej).

**Ryzyka:** eksport wymaga szablonów eksportu Godota 4.7.2 na tym komputerze; test eksportu trwa dłużej niż `unit`, więc nie dokładać go do każdego scenariusza. Zasoby tekstowe w eksporcie są większe niż binarne (rozmiar ZIP-a do zanotowania). Arkusz: wiersze o „1 z 12”, warunkach dróg (lina, wybuch, pompy, olej) i kapturach sprawdzane **na ZIP-ie**, nie w edytorze; `factcheck-test-16` potwierdzał tylko edytor.

**Niejasne:** pytanie agenta w zgłoszeniu (PT0b od nowa) rozstrzygnął plan gry („PT0b zaczynamy od nowa na buildzie z poprawką”, Roland, czat 2026-10-27: „ok”).

## Analiza
(agent, przebieg analyze 2026-10-27; kod czytany w głównej kopii na `f45b9b0`)

**Kolejność:** zadanie jest pierwsze; nie czeka na żadne inne. Nie ma otwartej karty decyzji z `Zadanie: task_25`.

**Jak jest dziś.**
- `project.godot` nie ma sekcji `[editor]`, więc obowiązuje domyślne `editor/export/convert_text_resources_to_binary=true`: każdy `.tres`/`.tscn` trafia do paczki jako binarny `.res`/`.scn` z plikiem `.remap`.
- Listy tekstów żyją w trzech miejscach danych: `script/data/location_data.gd:19` (`requires: PackedStringArray`) i `:25` (`veins: PackedStringArray`), wypełniane przez generator `tools/generators/write_world_data.js` (15 plików `data/locations/*.tres`, po 2 listy w każdym); `script/character_model.gd:24` (`hidden_meshes`, ustawiane w `scene/characters/{racibor,sobek,welf,hrapek}_model.tscn`). Z tych list czytają `GameState.vein_ids()` / `veins_mapped()` / `quota_text()` (`script/game_state.gd:503`, `:511`, `:584`) i `Expeditions.veins_marked()` (`script/expeditions.gd:183`), czyli cały licznik ZYL-4, kreski ZYL-2/WYP-3, warunki WYP-4/WYP-7 i raport ZAP-11.
- Ta sama postać `PackedStringArray(...)` jest też w metadanych scen: `node_paths=PackedStringArray("highlight_target")` przy każdym `VeinMark` (`camp.tscn:1400`, `mine_deep.tscn:566`, `:579`, 24 w `locations.tscn`) i `ResponsesMenu` w `scene/vn/vn_balloon.tscn:179` (`response_template`). Zgłoszenie tego nie sprawdzało. Jeśli w eksporcie gubi się i to, w wydanej grze nie świeci obrys żyły i może nie działać szablon odpowiedzi VN (choć VN w ZIP-ie działał, więc ta część najpewniej przechodzi). Poprawka globalna (ustawienie projektu) obejmuje oba przypadki naraz; test eksportu ma to rozstrzygnąć.
- `PackedColorArray` jest w `camp.tscn:132`, `:157` i w `locations.tscn` (gradienty światła i cząstek); nie sprawdzone.
- Żaden test nie dotyka eksportu: `tools/run_tests.sh` uruchamia każdy scenariusz z `--path .` (edytor). Preset `Windows Desktop` w `export_presets.cfg` wyklucza `tools/*`, więc scena-sonda w `tools/` nie trafi do zwykłego eksportu.

**Luki.** (1) Ustawienie projektu, które naprawia eksport. (2) Brak warstwy testu, która uruchamia grę spakowaną. (3) Dokumentacja wydania i buildu do ogrania nie wspomina o tej pułapce.

**Wybór poprawki.** Ustawienie `[editor] export/convert_text_resources_to_binary=false` (sprawdzone sondą, nie zmienia danych ani generatorów, działa też dla `node_paths` i każdego przyszłego zasobu). Droga przez typowane `Array[String]` naprawiałaby tylko trzy znane pola, wymagałaby zmiany generatora i regeneracji, a i tak nie obejmuje `node_paths`; nie wybieram jej. Koszt: większy ZIP i odrobinę wolniejsze ładowanie zasobów tekstowych (zanotować rozmiar ZIP-a przed i po w raporcie).

**Ryzyka.**
- Szablony eksportu Godota 4.7.2 muszą być zainstalowane (dashboard już eksportuje buildy do ogrania, więc są).
- Uruchomienie sondy w grze spakowanej: plan zakłada argument wiersza poleceń `--scene res://…` binarki debug z `--headless`. Jeśli szablon eksportu go nie przyjmie, wykonawca zamiast tego dodaje do `scene/main_menu.tscn`/jego skryptu obsługę argumentu użytkownika (np. `-- --export-smoke`, tak jak istniejące `--new-game`), który przełącza na scenę-sondę; to zmiana kodu gry, opisać ją w raporcie.
- Sonda w osobnym presecie (`Windows Smoke`) musi mieć te same filtry co `Windows Desktop`, poza dopuszczeniem `tools/export_smoke/*`, inaczej test sprawdza inny eksport niż ten, który dostaje gracz.
- Eksport trwa około minuty; scenariusz `export` nie jest „krótki” w rozumieniu `tools/README.md#testy` i nie wchodzi do zestawu `unit lint dialogue` przy każdej zmianie.
- Pliki `.tres` w paczce są `.remap`-owane albo nie (zależnie od ustawienia): sonda ma wczytywać zasoby przez `load()`/`ResourceLoader.list_directory()`, nie przez `DirAccess` z rozszerzeniem.
- Dane użytkownika: sonda nie zapisuje gry ani raportu (wspólny folder `%APPDATA%\Godot\app_userdata\Everhorror` z graczem).

## Plan
1. **Poprawka.** `project.godot`: sekcja `[editor]` z `export/convert_text_resources_to_binary=false` (z komentarzem w raporcie, nie w pliku, bo Godot nadpisuje komentarze).
2. **Sonda.** `tools/export_smoke/probe.tscn` + `probe.gd` (Node, `_ready()`, statyczne typy): drukuje linie `DUMP` i na końcu `RESULT: ALL PASSED` albo `RESULT: FAILED n` i wychodzi `get_tree().quit()`. Sprawdza:
   - każde z 15 miejsc w `data/locations`: `veins` i `requires` (wypisane w linii `DUMP loc <id> veins=[…] requires=[…]`), suma żył = liczba żył z generatora (25 według zgłoszenia; liczbę wziąć z `write_world_data.js`, nie wpisywać na ślepo), `upadowa.requires` zawiera `item:lina`;
   - `GameState.vein_ids().size()`, po ustawieniu jednej flagi żyły `veins_mapped() == 1`, `quota_text()` zawiera „1 z”, `Expeditions.veins_marked(&"west") == 1` dla `vein_west_1` (flagi czyszczone po sprawdzeniu);
   - `hidden_meshes` niepuste w czterech modelach postaci (instancja sceny, odczyt pola) i jeden schowany węzeł faktycznie `visible == false`;
   - `highlight_target` niepusty i rozwiązywalny w `VeinMark_west_1` z `camp.tscn` (instancja sceny bez wstawiania do świata albo z wstawieniem i zwolnieniem), oraz `response_template` w `vn_balloon.tscn`;
   - `PackedColorArray` z `camp.tscn` (`colors` gradientu ma 2 kolory).
3. **Preset.** `export_presets.cfg`: drugi preset `Windows Smoke` (kopia `Windows Desktop`, `export_path` w `build/export_smoke/`, `exclude_filter` bez `tools/*`, za to z `tools/tests/*, tools/generators/*, tools/release/*` itd., żeby do paczki weszło tylko `tools/export_smoke/*` z narzędzi). Preset `Windows Desktop` bez zmian.
4. **Uruchamianie.** `tools/run_tests.sh`: nazwany scenariusz `export` (osobna gałąź w pętli): `--headless --path . --export-debug "Windows Smoke" build/export_smoke/Everhorror.exe`, potem sonda raz w edytorze (`--path . --scene res://tools/export_smoke/probe.tscn`) i raz w grze spakowanej (`build/export_smoke/Everhorror.exe --headless --scene …`), log do `reports/tests/export.log`; wynik to `RESULT` z gry spakowanej plus porównanie linii `DUMP` z obu przebiegów (różnica = porażka, z pierwszą różniącą się linią w wyniku). Dopisać `export` na koniec domyślnej listy pełnego zestawu. Timeout eksportu dłuższy niż 180 s (np. 300 s).
5. **Kontrola poprawki.** Na gałęzi przed krokiem 1 uruchomić `export` (oczekiwane: FAILED, puste listy), po kroku 1 (oczekiwane: ALL PASSED); obie linie `RESULT` do raportu. To dowodzi, że test łapie błąd. Scenariusz `export` to warstwa testu, nie build do ogrania ani wydanie; pakowanie ZIP-a robi serwer.
6. **Testy:** serwer po wdrożeniu uruchamia `unit lint dialogue` i scenariusze `export expedition` (licznik żył i warunki dróg w edytorze bez zmian); w trakcie pracy agent uruchamia tylko to, czego potrzebuje. Pełnego zestawu nie uruchamiać.
7. **Dokumentacja.** `tools/README.md`: wiersz `export` w tabeli „Testy” (co sprawdza, czas), w „Wydanie” krok `tools/run_tests.sh export` przed eksportem, i zdanie o ustawieniu `convert_text_resources_to_binary=false` (dlaczego nie wolno go przywracać); w „Build do ogrania” notka, że dashboard powinien uruchamiać `export` przed spakowaniem (zmiana w `dashboard/` repo specyfikacji to osobna rzecz, nie w tym zadaniu; wykonawca proponuje ją w raporcie albo zgłoszeniu narzędziowym). `docs/agent/README.md`: jedno zdanie o pułapce eksportu przy systemie danych miejsc. Spec: w regułach nic się nie zmienia (reguły ✅ są dobre); w „Dla agenta” w `03_mechaniki/zyly_i_norma.md` wolno dopisać tylko wskaźnik na test `export`; `07_balans.md` bez zmian.
8. **Arkusz** (poziom `rozgrywka`, D-36 pkt 4): jedna część `## Część: task_25` arkusza builda (D-27): wiersze sprawdzane **na ZIP-ie buildu do ogrania**: komunikat „1 z 12” po pierwszej żyle i licznik na mapie, w ekwipunku i w notesie; kreski na rysunku mapy i „żyły 1/2” na liście miejsc; Upadowa i Ślepy szyb zamknięte bez liny, Zawalony chodnik przed wybuchem, Kaplica przed odkryciem, Zalany chodnik przy stojących pompach, Galeria bez oleju; brak kaptura u Racibora, Sobka i Welfa i poprawny model Hrapka; obrys żyły świeci przy zbliżeniu; raport przebiegu ma `n` żył różne od 0. Nowe linie po polsku: brak (zadanie nie dodaje tekstu w grze), więc `lore-checker` niepotrzebny.

Pliki: project.godot, export_presets.cfg, tools/export_smoke/, tools/export_smoke.sh, tools/run_tests.sh, tools/README.md, docs/agent/README.md
Ryzyko: średnie

## Czego potrzebuję od Ciebie
Nic przed wdrożeniem. Po wdrożeniu: zdecydować, czy dashboard (`cli.ts build`, buildy do ogrania D-32) ma uruchamiać scenariusz `export` przed spakowaniem ZIP-a; to zmiana w repo specyfikacji, poza tym zadaniem.

## Przepływ (D-36)
Poziom `rozgrywka`: poprawka zmienia ustawienie eksportu projektu i tym samym to, co gracz widzi w wydanej grze (licznik żył, warunki dróg, kaptury); sonda i scenariusz `export` to narzędzia. Arkusz tylko jako jedna część `## Część: task_25` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `średnie`: jedno ustawienie w `project.godot` (sprawdzone sondą) i warstwa testu w kilku plikach narzędziowych, a nowy test łapie regresję.
Stan po przebudowie procesu (commit `c5e7fb3`): scenariusz `export` i `tools/export_smoke.sh` (preset „Test Pack”, `day1` i `expedition` uruchamiane z wyeksportowanej paczki) już istnieją i są czerwone do tej poprawki. Kroki 2–4 planu czytaj więc tak: nie tworzyć drugiego presetu „Windows Smoke” ani drugiego scenariusza `export`; poprawka z kroku 1 ma zazielenić istniejący `tools/run_tests.sh export`, a dodatkowe sprawdzenia (`requires`, `hidden_meshes`, `node_paths`, `PackedColorArray`) wchodzą jako sonda albo dodatkowe scenariusze uruchamiane tym samym skryptem; wykonawca wybiera mniejszą zmianę i opisuje wybór w raporcie.

## Co zostało zrobione
**Wymagania 1 i 2 (ZYL-2/4/5, WYP-3/4/7, ZAP-11, kaptury).** `project.godot`: sekcja `[editor]` z `export/convert_text_resources_to_binary=false` (commit `f1e6f37` na `spec/2026-10-28-task25`). Dokumentacja: `tools/README.md` (sekcja „Eksport”: ustawienia nie wolno usuwać, `export` przed wydaniem), `docs/agent/README.md` (zdanie o pułapce przy danych miejsc).

## Decyzje i założenia
- Zgodnie z sekcją „Przepływ”: istniejący scenariusz `export` (`tools/export_smoke.sh`, preset „Test Pack”, `day1 expedition`) wystarcza; nie dodałem drugiego presetu ani osobnej sondy (mniejsza zmiana). Nie sprawdzałem osobno `node_paths` ani `PackedColorArray`: ustawienie jest globalne, a `expedition` z paczki przechodzi.
- Nie uruchamiałem scenariusza `export` przed poprawką (czerwony według `tools/README.md` z poprzedniego przebiegu).
- Rozmiaru ZIP-a przed i po nie mierzyłem (ZIP robi serwer).
- Spec: bez zmian w regułach; wskaźnika w „Dla agenta” `03_mechaniki/zyly_i_norma.md` nie dopisałem.

## Czego potrzebuję od Ciebie (po wdrożeniu)
Czy dashboard (`cli.ts build`) ma uruchamiać `tools/run_tests.sh export` przed spakowaniem ZIP-a (zmiana w repo specyfikacji, poza tym zadaniem).

## Test
Arkusz: część task_25 w [factcheck-build-333b147](../../human-tasks/done/factcheck-build-333b147.md).
- `tools/run_tests.sh export` → `RESULT: ALL PASSED (export smoke: day1 expedition ran from the exported pack)`
- `tools/run_tests.sh unit lint` → unit ALL PASSED, lint ALL PASSED (20 ostrzeżeń, reguły spec pominięte: brak folderu specyfikacji w kopii)

## Podsumowanie
Wdrożone na gałęzi: jedno ustawienie eksportu (`convert_text_resources_to_binary=false`) naprawia listy tekstów w grze z ZIP-a, a scenariusz `export` jest zielony. Analiza (wcześniej): winne jest domyślne przekształcanie zasobów tekstowych na binarne przy eksporcie, a poprawka to jedno ustawienie w `project.godot` (sprawdzone sondą) i nowy scenariusz testu `export`, który eksportuje grę i porównuje dane w edytorze i w grze spakowanej. Plan dokłada sprawdzenie `node_paths` przy obrysach żył i `PackedColorArray`, których zgłoszenie nie badało. Pytań do Rolanda nie ma; zadanie czeka na wdrożenie (`/ai-task implement 25`).
