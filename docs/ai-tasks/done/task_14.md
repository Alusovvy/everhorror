<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-26; etap 2 planu końcowego). Wymagania to cytat zasad ze specyfikacji w commicie 8e46253; nie edytować.
Odnośniki w cytatach wskazują pliki specyfikacji względem tego pliku (../../../../specification/…); tekst reguł jest bez zmian.
-->

# 0.5.3: poprawki, wersja, raport przebiegu i bot balansu

Wymagania:
1. NPC-18 (03_mechaniki/npc.md) ⬜: „Kto jeszcze nie dotarł, nie traci poczytalności. Sabina do chwili, gdy wprowadzi się do obozu (NPC-9), oraz Ottokar, Hieronim i Welf do pierwszego spotkania z Exitium nie podlegają nocnym spadkom poczytalności ([balans](../../../../specification/07_balans.md#noc)) ani wstrząsowi w piątą noc ([CZAS-9](../../../../specification/03_mechaniki/czas.md)). Pozostali, także piątka z szychty w dniu 1 (NPC-17) i Dobrawa od dnia 2, są w rozliczeniu normalnie. Po spotkaniu wstrząs dotyka Drugich z Exitium tak samo jak pozostałych (−2) [ROBOCZE]. Przy okazji: Hieronim nie ma odejścia przy 0% poczytalności, bo to tylko propozycja z karty (NPC-4), więc gra nie sprawdza, czy Hieronim odszedł [ROBOCZE].”
2. CZAS-16 (03_mechaniki/czas.md) ⬜: „Kategorie czasu: każdy wpis dziennika (CZAS-15) należy do jednej z poniższych kategorii. Służą raportowi przebiegu ([ZAP-11](../../../../specification/03_mechaniki/zapis_i_opcje.md)); w notesie ich nie widać, gracz czyta te same linijki co dotąd. Przypisanie idzie po etykiecie wpisu, a lint pilnuje, żeby nowe etykiety nie trafiały do „inne” [ROBOCZE].” Tabela kategorii z tej samej reguły:

   | Kategoria | Co tu trafia |
   |---|---|
   | rozmowy | rozmowy z postaciami |
   | drogi | wyprawy, przejścia dalej przez [M], powroty do obozu |
   | żyły | zaznaczanie żył, odkuwanie spod nacieku |
   | pomoc | wysadzenie zawału, praca przy pompach, opatrywanie, mapy dla Ottokara, łowienie ryb |
   | obóz | wieczór przy ogniu, kości z Sobkiem, posiedzenie z Mirosławem |
   | eksploracja | pozostałe akcje przy rzeczach w miejscach (kręgi, skrytki) |
   | przedmioty | użycie przedmiotu (bandaże, świeca) |
   | sen | sen (0 minut) |
   | inne | wszystko, czego nie rozpoznano |
3. UI-6 (05_interfejs.md) ⬜: „Wersja gry w prawym dolnym rogu menu głównego: „0.5.3 · spec a1b2c3d” (numer wersji z ustawień projektu, a po nim skrót commita specyfikacji, z którą zbudowano grę, zob. [TECH-1](../../../../specification/08_technika.md)). Napis jest przyciemniony i nie reaguje na mysz ani klawisze. Tylko w menu głównym, w pauzie go nie ma [ROBOCZE].”
4. UI-7 (05_interfejs.md) ⬜: „Pauza ma przycisk SAVE REPORT (angielska etykieta, zob. UI-5), który zapisuje raport przebiegu ([ZAP-11](../../../../specification/03_mechaniki/zapis_i_opcje.md)) i pokazuje w samym menu pauzy ścieżkę pliku, po angielsku jak reszta menu, bo komunikaty HUD są w pauzie niewidoczne [ROBOCZE].”
5. ZAP-11 (03_mechaniki/zapis_i_opcje.md) ⬜: „Raport przebiegu [ROBOCZE]: na końcu tygodnia (oba zakończenia) i na żądanie z pauzy ([UI-7](../../../../specification/05_interfejs.md)) gra zapisuje lokalnie dwa pliki, `przebieg-<data>_<godzina>.md` (do czytania) i `.json` (do liczenia), w folderze `raporty` w danych użytkownika (w Windows `%APPDATA%\Godot\app_userdata\Everhorror\raporty`). Po śmierci raport nie powstaje sam, bo każde powtórzenie dnia dałoby kolejny plik. Nic nie jest wysyłane przez sieć. Zawartość:
   - wersja gry i skrót specyfikacji ([UI-6](../../../../specification/05_interfejs.md)),
   - dla każdego dnia: czas według kategorii ([CZAS-16](../../../../specification/03_mechaniki/czas.md)) i niewykorzystany czas przed snem, liczba żył o świcie, stan bohatera i każdej poznanej postaci o świcie (w pasmach, jak w notesie; kto jeszcze nie dotarł, ma kreskę, zob. [NPC-18](../../../../specification/03_mechaniki/npc.md); plik `.json` może mieć też surowe wartości),
   - kiedy zaznaczono każdą żyłę i kiedy osiągnięto normę,
   - kluczowe wybory: komu oddano kryształ, los Tekli, los Welfa, los Nasira, a także śmierć Mirosława, odejście Dobrawy i inne rozstrzygnięcia tygodnia,
   - zakończenie („Koniec tygodnia”, „Zostałeś sam”) albo „w trakcie”, gdy raport zapisano z pauzy.”
6. ZAP-12 (03_mechaniki/zapis_i_opcje.md) ⬜: „Zapis w wersji 6 zawiera dziennik świtów (stan bohatera i postaci oraz liczba żył na początku każdego dnia) i dziennik zaznaczonych żył (która, którego dnia i o której godzinie), potrzebne raportowi (ZAP-11). Zapisy ze starszych wersji wczytują się z pustymi dziennikami, a raport oznacza brakujące dni jako „brak danych”. Powtórzenie dnia po śmierci (ZAP-7) przywraca dzienniki z tamtego poranka, więc raport nie zawiera nieudanych prób tego dnia [ROBOCZE].”
7. TECH-1 (08_technika.md) ⬜: „Wersja gry. Numer wersji jest w ustawieniach projektu (`application/config/version`). Skrót commita specyfikacji, z którą zbudowano grę, wpisuje do `script/build_info.gd` skrypt `tools/release/stamp_build.js` tuż przed eksportem. Gdy w specyfikacji są niezatwierdzone zmiany, skrót kończy się znakiem „+”, a w drzewie, które nigdy nie było stemplowane, zamiast skrótu jest „unknown”. Zbudowana gra nie wywołuje gita [ROBOCZE].”
8. TECH-2 (08_technika.md) ⬜: „`CHANGELOG.md` leży w katalogu głównym repozytorium gry, jest po polsku, od najnowszej wersji, a przy każdej wersji podaje zgodność ze specyfikacją („Zgodność ze spec: a1b2c3d”). Trafia do archiwum ZIP obok `CZYTAJ_MNIE.txt`. Nagłówek najnowszej wersji w `CHANGELOG.md`, `config/version` i nagłówek `CZYTAJ_MNIE.txt` muszą się zgadzać: sprawdza to test, a `stamp_build.js` odmawia pracy przy rozbieżności [ROBOCZE].”
9. TECH-3 (08_technika.md) ⬜: „Bot balansu (`tools/balance_sim.gd`, test `balance`): narzędzie, które „gra” tydzień bez świata gry, na prawdziwych kosztach z gry (graf wypraw i jego godziny, zmęczenie, godziny dnia, norma). Gra w dwóch stylach, „żyły” i „rozmowy”, w wariancie optymistycznym i opóźnionym, i dla każdego przebiegu wypisuje wynik w postaci „BALANCE[żyły]: norma 12 → dzień X, HH:MM (żyły po dniu 7: N)” albo, gdy normy nie osiągnął, „norma 12 → nie osiągnięta (N żył po dniu 7)”. Bramki fabularne (zawał, lina, olej, pompy, kilof, kaplica) zastępuje uproszczona tabela z [balansu](../../../../specification/07_balans.md#pomiar), którą bot wypisuje razem z wynikiem. To pomiar, nie test zaliczenia: tempo nigdy nie oblewa testu, a sprawdzane są tylko niezmienniki [ROBOCZE].”
10. Wstęp (04_tresc/tydzien.md) ⬜: „Pogadaj z ludźmi. Wyprawy planujesz przy stole z mapą w zagrodzie Racibora, za niską palisadą bez dachu. W chodnikach mapa [M] pokaże ci drogę dalej albo z powrotem. Na noc wracasz na posłanie.” Uwaga przy tym zdaniu: „**[ROBOCZE]** Zdanie o stole z mapą w ostatnim akapicie wstępu jest poprawione (task_14): stół stoi w zagrodzie dowódcy, za palisadą bez dachu ([miejsca](../../../../specification/04_tresc/miejsca.md)), a nie „w kwaterze zarządcy, za drewnianą ścianką”, jak w hali sprzed task_08. Gra ma jeszcze stary tekst w `dialogue/system.dialogue`.”
11. Poprawka błędu (plan końcowy, etap 2; rozstrzygnięcie w NPC-18, pkt 1): martwy warunek `hieronim_gone` w `script/story_director.gd`, `_roaming_drudzy()`, linia 307: `if npcs.has(&"hieronim") and not GameState.has_flag("hieronim_gone"):`. Żaden `.gd`, `.dialogue` ani generator nie ustawia tej flagi. Plan końcowy: „martwy warunek `hieronim_gone` usunąć albo zacząć tę flagę ustawiać”. NPC-18 rozstrzyga: „Hieronim nie ma odejścia przy 0% poczytalności, bo to tylko propozycja z karty (NPC-4), więc gra nie sprawdza, czy Hieronim odszedł [ROBOCZE]”. Do zrobienia: usunąć sprawdzanie `hieronim_gone`, bez wprowadzania odejścia.

Źródło: specyfikacja `8e46253` · ID: NPC-18, CZAS-16, UI-6, UI-7, ZAP-11, ZAP-12, TECH-1, TECH-2, TECH-3, wstęp (tydzień), `hieronim_gone` · Zgłoszenia: —

Kontekst:
- Etap 2 planu końcowego ([final-plan-human-readable.md](../../analizy/final-plan-human-readable.md), §1): trzy poprawki, wersja w menu głównym i `CHANGELOG.md` w zipie, czyli czysty build 0.5.3 do sesji gry PT0 (etap 3). Arkusz dla człowieka: [factcheck-test-14.md](../../human-tasks/factcheck-test-14.md) (PT0, jeden arkusz zamiast otwartych factchecków 08–13).
- Decyzje już podjęte (zasada planu, §3 pkt 3: rekomendacja obowiązuje, dopóki Roland jej nie zawetuje):
  - do 0.5.3 wchodzą razem: trzy poprawki, wersja w menu głównym, raport przebiegu (ZAP-11, ZAP-12, UI-7) i bot balansu (TECH-3), które plan końcowy przewidywał w 0.5.4 (etap 4); `CHANGELOG.md` ma to podać wprost (wpis w dzienniku decyzji `09_produkcja.md` z 2026-10-26);
  - Drudzy z Exitium po spotkaniu podlegają wstrząsowi w piątą noc (−2) jak pozostali (NPC-18);
  - wersja jest tylko w menu głównym, nie w pauzie (UI-6).
- Powiązane zapisy z tego samego commita specyfikacji (bez osobnych wymagań, ale wiążące razem z regułami): CZAS-9 pkt 1 i 4 („wstrząs w piątą noc: poczytalność wszystkich obecnych w dół (zob. NPC-18)”), ZAP-2 (przycisk SAVE REPORT po OPTIONS), ZAP-4 (wersja zapisu 6), `07_balans.md` → „Noc” (dwa wiersze z odnośnikiem do NPC-18) i „Pomiar” (założenia bota i tabela bramek fabularnych, część TECH-3), `08_technika.md` → „Testy” (piąta warstwa `balance`), `05_interfejs.md` → wiersze „Menu główne” i „Pauza”, `02_postacie/sabina.md` i `03_mechaniki/npc.md` („w zagrodzie dowódcy”).

Kryteria akceptacji:
- Menu główne pokazuje napis „<wersja> · spec <skrót>”, a archiwum `build/Everhorror-demo-0.5.3-windows.zip` (z `CHANGELOG.md` i `CZYTAJ_MNIE.txt`) leży w `build/` (etap 2, „Gotowe, gdy”).
- Bot balansu podaje dzień osiągnięcia normy, a gra zapisuje raport przebiegu na koniec tygodnia i z pauzy (etap 4, „Gotowe, gdy”).
- Sabina przed wprowadzeniem się do obozu oraz Ottokar, Hieronim i Welf przed spotkaniem z Exitium nie tracą poczytalności w nocy ani we wstrząsie; po spotkaniu wstrząs dotyka Drugich z Exitium tak samo jak pozostałych (NPC-18).
- `_roaming_drudzy()` nie sprawdza już `hieronim_gone`; wstęp (`dialogue/system.dialogue`), `tools/release/CZYTAJ_MNIE.txt` i komentarz w `tools/generators/gen_camp.gd` mówią o zagrodzie Racibora, nie o „kwaterze zarządcy” ani „drewnianej ściance”.
- Testy: `unit`, `lint`, `dialogue`, nowa warstwa `balance` i krótkie scenariusze dotkniętych systemów, bez SCRIPT ERROR w logach.

Poza zakresem:
- Zmiany rozgrywki i liczb balansu (etapy 5–7): bot balansu tylko mierzy.
- Odejście Hieronima przy 0% poczytalności (spec: 💡, „nie ma w grze”).
- Pełny zestaw testów (tylko za zgodą Rolanda), scalanie do `master` gry (tylko Roland), publikacja i wydatki.
- Wpisywanie czegokolwiek w kolumnach „wynik” i „uwagi” arkusza PT0.

Priorytet: wysoki (etap 2 planu końcowego; sesja gry PT0 czeka na ten build) · Kolejność: — (buduje na `master` po task_13, build 0.5.2)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Wskazówki do kodu według stanu drzewa z 2026-10-26; do sprawdzenia przy implementacji. Kolejność prac: reguły w specyfikacji (są, ⬜ w `8e46253`), potem B1, B2, B3, wersja i `CHANGELOG.md`, raport przebiegu, bot balansu, testy.
- **B1 (NPC-18).** `GameState.reset()` (`game_state.gd:195–197`) ustawia status `camp` każdemu z `NPCS`, także Sabinie, Ottokarowi, Hieronimowi i Welfowi. `StoryDirector._resolve_new_people()` (`story_director.gd:496–498`) odejmuje Sabinie 2 co noc bezwarunkowo, a wstrząs w nocy 5 (`story_director.gd:460–462`) trafia każdego ze statusem `camp`/`field`, także niepoznanych Drugich. „Dotarł” to flagi `sabina_joined` (Sabina) i `drudzy_met` (Ottokar, Hieronim, Welf), więc wystarczy predykat pochodny bez zmiany zapisu; nowy status początkowy ruszyłby `in_camp_today()`, ognisko i warunki Dobrawy.
- **B2.** `story_director.gd:307` (`_roaming_drudzy()`): usunąć `not GameState.has_flag("hieronim_gone")`. Opcjonalnie reguła lintu „flaga czytana, ale nigdy nieustawiana”, która by to złapała.
- **B3.** `dialogue/system.dialogue:107` (blok `intro`); po zmianie `--import`. Do poprawy też `tools/release/CZYTAJ_MNIE.txt:28` („w kwaterze zarządcy”) i komentarz w `tools/generators/gen_camp.gd:452` (sam komentarz, bez regeneracji sceny). Linia nie jest kwestią górnika, więc nie ma jej w `gwara_slaska.json`.
- **Wersja i `CHANGELOG.md` (UI-6, TECH-1, TECH-2).** `project.godot` nie ma jeszcze `config/version`. Nowe: `script/build_info.gd`, `tools/release/stamp_build.js`, `CHANGELOG.md` w katalogu głównym i w zipie, napis w `scene/main_menu.tscn` + `script/main_menu.gd`. Plik `.gd` trafia do eksportu bez zmiany filtrów (`export_filter="all_resources"`), luźny `.json`/`.cfg` nie.
- **Raport przebiegu (ZAP-11, ZAP-12, UI-7, CZAS-16).** Dziś `GameState.time_log` ma tylko wolny tekst `why`, a dziennika świtów ani zaznaczeń żył nie ma. Nowe: `dawn_log` i `vein_log` w `GameState`, `SaveManager.SAVE_VERSION` 5 → 6, `script/run_report.gd`, przycisk w `scene/pause_menu.tscn` + `script/pause_menu.gd`, wywołanie na początku `StoryDirector._week_end()`, katalog `user://raporty`.
- **Bot (TECH-3).** `tools/balance_sim.gd` w stylu `unit_test.gd` (bez świata, koszty z `Expeditions` i `GameState`), wpis `balance` w `tools/run_tests.sh` i `tools/README.md`.
- **Ryzyka.** Nowe skrypty z `class_name` (`BuildInfo`, `RunReport`) rejestrują się dopiero po `--import`. Pełnego zestawu testów nie uruchamiać bez zgody Rolanda. Arkusz PT0 (`factcheck-test-14.md`) jest już gotowy; implementujący tylko sprawdza, czy jego opis zgadza się z buildem (napis wersji, SAVE REPORT, miejsce plików), a kolumn człowieka nie rusza.

## Co zostało zrobione
Gałąź `spec/2026-10-26-task14` w worktree `../everhorror-wdrozenie`, trzy commity wysłane na remote `everhorror`: `085913b` (kod 0.5.3), `68de878` (arkusz PT0 `docs/human-tasks/factcheck-test-14.md`, przeniesienie factchecków 08–13 do `done/` i poprawione odnośniki w `done/task_08–13.md`; same dokumenty, bez zmian w grze) i `e1ba7ca` („poprawki po weryfikacji”, zob. niżej). Zbudowana ze specyfikacji `27e91e7` (reguły z `8e46253`, szczegóły [ROBOCZE] dopisane po weryfikacji). Archiwum: `build/Everhorror-demo-0.5.3-windows.zip` (118 533 236 B, SHA-256 `472a6db8…c2887f`: `Everhorror.exe`, `CZYTAJ_MNIE.txt`, `CHANGELOG.md`), zbudowane od nowa po poprawkach, w worktree i w głównej kopii (`C:\dev\gamedev\everhorror\everhorror\build\`), napis w menu „0.5.3 · spec 27e91e7”. Ten plik (raport) zostaje w głównej kopii do scalenia gałęzi; arkusz PT0 leży na gałęzi i pojawi się w głównej kopii po scaleniu (z głównej kopii usunięto jego niezatwierdzoną kopię i niezatwierdzone przeniesienia, żeby scalenie nie zderzyło się z plikami nieśledzonymi).

### 1. NPC-18: kto jeszcze nie dotarł, nie traci poczytalności (B1)
- `GameState.ARRIVAL_FLAG` i `has_arrived(id)`: Sabina od `sabina_joined`, Ottokar, Hieronim i Welf od `drudzy_met`, reszta zawsze (także piątka z szychty i Dobrawa). Predykat pochodny z flag: bez nowego statusu, bez zmiany zapisu, `in_camp_today()`, ognisko i warunki Dobrawy nietknięte.
- `StoryDirector._resolve_new_people()` (Sabina) i wstrząs w nocy 5 (`_resolve_night()`) pomijają tych, którzy nie dotarli. Po spotkaniu Drudzy z Exitium dostają wstrząs −2 jak inni; Sabina −2 co noc dopiero od nocy po wprowadzeniu się.
- Test, że reguła naprawdę działa: z cofniętą poprawką `unit` daje 8 FAILED, z poprawką ALL PASSED.

### 2. Martwy `hieronim_gone` (B2)
Warunek usunięty z `_roaming_drudzy()`, bez wprowadzania odejścia (NPC-18). Dodałem regułę lintu „flaga czytana, ale nigdzie nieustawiana” (poza rodzinami `vein_*` i `visited_*`, budowanymi w czasie działania): z przywróconym `has_flag("hieronim_gone")` lint pada, bez niego przechodzi (185 czytanych flag, żadna bez ustawienia; 186 było z przywróconym `hieronim_gone`).

### 3. Wstęp (B3)
`dialogue/system.dialogue`, blok `intro`, dokładnie tekst z wymagania 10: „…przy stole z mapą w zagrodzie Racibora, za niską palisadą bez dachu…”. Poprawione też `CZYTAJ_MNIE.txt` i komentarz w `gen_camp.gd` (sceny nie regenerowałem). To zdanie narratora, nie kwestia górnika, więc klucza gwary nie ma. `day1` sprawdza w prawdziwym świecie, że wstęp mówi o zagrodzie i nie mówi o „kwaterze zarządcy” ani „drewnianej ściance”.

### 4. Wersja, CHANGELOG, archiwum (UI-6, TECH-1, TECH-2)
- `application/config/version="0.5.3"` w `project.godot`; `script/build_info.gd` (`BuildInfo.version()`, `SPEC_SHA`, `label()` = „0.5.3 · spec 27e91e7”); napis `VersionLabel` w prawym dolnym rogu `scene/main_menu.tscn` (przyciemniony, `mouse_filter` ignoruje myszkę, bez fokusu), ustawiany w `main_menu.gd`. W pauzie go nie ma.
- `tools/release/stamp_build.js`: sprawdza, że wersja jest ta sama w `project.godot`, nagłówku `CHANGELOG.md` i pierwszej linii `CZYTAJ_MNIE.txt` (inaczej odmawia, kod 1), wpisuje skrót do `build_info.gd` (domyślnie HEAD specyfikacji, „+” przy niezatwierdzonych zmianach; `--spec <rev>` wpisuje podany commit; `--check` tylko sprawdza). Sprawdziłem ścieżki: rozbieżność wersji, brak commita, „+”, `--spec`, `--check`.
- `CHANGELOG.md` (po polsku, od 0.5.3 do 0.1, przy każdej wersji „Zgodność ze spec”); wpis 0.5.3 podaje wprost, że raport i bot wchodzą już do 0.5.3 razem z poprawkami i wersją (decyzja orkiestratora, rekomendacja do weta Rolanda).
- `tools/release/make_zip.sh` (nie było skryptu): odmawia przy rozbieżności wersji, składa `Everhorror.exe`, `CZYTAJ_MNIE.txt` i `CHANGELOG.md` na górze archiwum (`zip`, a gdy go nie ma, `Compress-Archive`). `CZYTAJ_MNIE.txt` ma nagłówek 0.5.3 i sekcję „CO NOWEGO W 0.5.3”.
- Eksport `--export-release "Windows Desktop"` (14 s, bez błędów); skrypty `build_info`, `run_report`, `pause_menu`, `main_menu` są w paczce. Wyjęty z archiwum `Everhorror.exe` ma ten sam skrót SHA-256 co zbudowany. Dymny test wyeksportowanego exe (`--headless`, menu i `--new-game`): kod 0, w logu tylko nagłówek, bez błędów.

### 5. Raport przebiegu (CZAS-16, ZAP-11, ZAP-12, UI-7)
- `GameState.dawn_log` (wpis co świt: żyły, bohater, każda postać z poczytalnością, zdrowiem, zaufaniem, statusem, gorączką i „dotarł”, flagi nowe od poprzedniego świtu; dzień 1 z `reset()`, kolejne ze `start_next_day()` po rozliczeniu nocy) i `vein_log` (każda żyła z dniem, godziną zakończenia i polem `n`, czyli ile żył było na mapie razem z nią; także żyły zaznaczone przez Ottokara, z polem `via`). Zapis w **wersji 6**; starszy zapis wczytuje się z pustymi dziennikami, a pierwszy świt po jego wczytaniu ma znacznik `partial`.
- `script/run_report.gd` (`RunReport`): `categorize()` (9 kategorii z CZAS-16), `collect()`, `to_markdown()`, `to_json()`, `write()`. Pliki `przebieg-<data>_<godzina>.md` i `.json` w `user://raporty` (Windows: `%APPDATA%\Godot\app_userdata\Everhorror\raporty`), z końcówką `-2`, gdy w tej samej sekundzie powstał już raport. Treść: czas według kategorii i niewykorzystany czas przed snem dla każdego dnia, żyły i bohater o świcie, trzy tabele ludzi o świcie (głowa, zdrowie, stosunek; słowa pasm według płci postaci, w tabeli zdrowia „gorączka” zamiast pasma, kreska dla kogoś, kto jeszcze nie dotarł), tabela żył z dniem i godziną (numer = liczba żył na mapie), kiedy osiągnięto normę (z tej liczby, nie z miejsca w dzienniku), 13 „kluczowych wyborów” (kryształ, Tekla, Welf, Nasir, Mirosław, Dobrawa, Sabina, Upadowa, wiadomość dziadka, ściana, Hrapek, Czternasty, wstrząs) i zakończenie. JSON ma też surowe liczby.
- Wyzwalacze: koniec tygodnia (`_week_end()`, przed ekranem końca, w obu zakończeniach; ekran podaje nazwę pliku) i przycisk **SAVE REPORT** w pauzie, między OPTIONS a MAIN MENU („w trakcie”; ścieżka po angielsku obok przycisków). Po śmierci raport sam nie powstaje.
- Nowe pomocnicze funkcje pasm w `GameState` (`*_band_of`, `trust_band_of`), z których korzysta też notes (jedne progi).

### 6. Bot balansu (TECH-3)
`tools/balance_sim.gd` i warstwa `balance` w `tools/run_tests.sh` (w domyślnej liście, jej linie `BALANCE` wypisuje pod linią RESULT). Gra tydzień bez świata na prawdziwych kosztach z gry (graf `Expeditions`, `advance_time`, zmęczenie, `QUOTA`, `BLAST_HOURS`, `VN.TALK_MINUTES`), w stylach „żyły” i „rozmowy” i w wariantach „optymistyczny” i „opóźniony”; bramki z tabeli „Pomiar” (wypisywane razem z wynikiem). Sprawdza tylko niezmienniki (1406 sprawdzeń: powrót do 22:00, zmęczenie 0–100, żadna żyła dwa razy, dziennik żył zgodny z licznikiem, ten sam wynik dwa razy, raport czyta tydzień bota); tempo to pomiar. `-- --timeline` wypisuje dziennik czasu każdego dnia.

Pierwszy pomiar (górna granica tempa: bez zdrowia, poczytalności, spotkań i wątków fabularnych, trasa zachłanna):

| Styl, wariant | Norma 12 żył osiągnięta | Żyły po dniu 7 |
|---|---|---|
| żyły, optymistyczny | dzień 4, 13:00 | 23 |
| żyły, opóźniony | dzień 4, 17:00 | 22 |
| rozmowy, optymistyczny | dzień 4, 18:30 | 19 |
| rozmowy, opóźniony | dzień 5, 15:30 | 17 |

### 7. Testy i dokumentacja
- `unit`: sekcje task_14 (NPC-18 na gołym `StoryDirector`, pasma, wersja = `CHANGELOG.md` = `CZYTAJ_MNIE.txt` i kształt etykiety, kategorie, dziennik świtów i żył z zapisem i starym zapisem, raport: Markdown, JSON, `write()`). `lint`: etykiety czasu mają kategorię inną niż „inne”, ukryte żyły bota = `hidden_vein()` w generatorze (sprawdziłem, że lint pada po usunięciu etykiety z tabeli), flagi czytane = ustawiane. Scenariusze: `day1` (wstęp), `night1` i `drudzy` (NPC-18 w prawdziwym świecie), `save_load` (wersja 6, dzienniki), `week` (SAVE REPORT, raport na końcu tygodnia, brak raportu po śmierci, dzienniki po powtórzeniu dnia, przyciski ekranu końca na ekranie).
- `tools/README.md` (tabela testów, warstwa `balance`, paragraf „Release” ze `stamp_build.js` i `make_zip.sh`) oraz `CLAUDE.md` (systemy, pięć warstw testów, `SAVE_VERSION` 6, linia „Build” z krokami wydania i wersją 0.5.3).

### 8. Poza wymaganiami, ale potrzebne
Zrzut z prawdziwego okna (1152×648, jak w grze) pokazał dwie rzeczy: (a) kolumna przycisków pauzy zajmuje już 636 z 648 px, więc linia statusu pod nią wychodziła poza ekran: tekst stoi więc **obok** przycisków; (b) **ekran końca tygodnia był już przed task_14 wyższy niż ekran** (z podsumowaniem o 17–20 liniach logo i przyciski wypadały poza krawędź, bo układ się centruje). Dodałem `ScreenFade._fit_end_panel()`: gdy się nie mieści, chowa logo, potem zmniejsza czcionkę i odstępy; krótkie ekrany (śmierć) bez zmian. Bez tego linia o raporcie i przyciski MAIN MENU / EXIT byłyby niewidoczne. Zrzuty sprawdzone.

### 9. Poprawki po weryfikacji (gra `e1ba7ca`, specyfikacja `27e91e7`)
Weryfikacja zgłosiła jedno ustalenie poważne i dziesięć drobnych. Co z nimi zrobiono:
- **Arkusz PT0 poza gitem (poważne).** `factcheck-test-14.md` był tylko niezatwierdzonym plikiem w głównej kopii, a przeniesienia factchecków 08–13 siedziały w jej indeksie (każdy zwykły `git commit` innej sesji wciągnąłby je do obcego commita). Arkusz, przeniesienia, banery i poprawione odnośniki są teraz w commicie `68de878` na gałęzi, osobno od kodu. Z głównej kopii zdjęto je z indeksu i usunięto ich kopie, po sprawdzeniu, że gałąź ma te same pliki (poza dwoma nowszymi na gałęzi); kopia zapasowa jest w katalogu roboczym sesji. Próbne scalenie gałęzi z `master` (`git merge-tree`) wychodzi bez konfliktów, a w głównej kopii zostaje tylko ten plik zadania (nieśledzony, do finalizacji). `WDROZENIA.md` mówi, gdzie leży arkusz.
- **Czas normy i numeracja żył w zapisie sprzed wersji 6 (drobne).** Wpis dziennika żył ma pole `n` (ile żył było na mapie razem z nią). Norma i numer w tabeli idą z `n`, nie z miejsca w dzienniku. Zapis z pięcioma żyłami i dwunastoma dalszymi, zaznaczanymi co godzinę od 06:00 w dniu 4, daje teraz „norma osiągnięta: dzień 4, 13:00” i numerację 6–17 z uwagą, że żyły 1–5 nie mają daty (wcześniej: 18:00 i numeracja od 1). Gdy norma była osiągnięta jeszcze przed wczytaniem, raport pisze „brak danych”. Dopisane sprawdzenia w `unit` (próba mutacyjna: bez `n` pada 5 sprawdzeń) i w bocie.
- **Pasma ludzi w raporcie (drobne).** Słowa odmieniają się według płci postaci (`NpcData.female`, jak w notesie: „spokojna”, „zdrowa”, „odeszła”); w tabeli zdrowia „gorączka” zastępuje pasmo, jak w notesie (JSON zachowuje pasmo obok gorączki); legenda kreski mówi, kogo dotyczy: Sabinę do wprowadzenia się do obozu, Ottokara, Hieronima i Welfa do pierwszego spotkania z Exitium. Próba mutacyjna: bez form żeńskich i gorączki pada 4 sprawdzenia.
- **Reguły w specyfikacji (drobne).** Commit `[agent]` `27e91e7` (lint 0 błędów): TECH-1 (`--spec`, `--check`), TECH-3 (linia `BALANCE[styl, wariant]`), „Pomiar” (powrót o 21:00 w stylu „rozmowy”, kaplica nie wcześniej niż w dniu 2, jak bot czyta tabelę), ZAP-11 (szczegóły wdrożenia), wiersz ekranu końca w `05_interfejs.md` jako ⬜ [ROBOCZE] z `_fit_end_panel`, wskaźniki kodu w „Dla agenta”. W `CHANGELOG.md` jest linia o ekranie końca, a skrót w menu to `27e91e7`. Finalizacja zmienia już tylko znaczniki.
- **Formy neutralne (drobne).** „Powrót do obozu trwa połowę drogi przebytej od wyjścia” (`CHANGELOG.md`), „Jeszcze nikogo nie poznano.” (raport).
- **Lint etykiet czasu (drobne).** Skanuje też każdy `script/*.gd`, próg to „jest choć jedna etykieta” (wcześniej „więcej niż 15”, co przy 16 etykietach padałoby z mylącym komunikatem), a przy zerze mówi, że wyrażenia przestały pasować. Próba: etykieta dopisana do `script/hud.gd` oblewa lint.
- **Bramka kaplicy w bocie (drobne).** Wiedza o kaplicy nie wcześniej niż w dniu 2 w żadnym stylu (Bolko opowiada od dnia 2, Dobrawa przychodzi w dniu 2, odszyfrowanie jest w nocy). Cztery wyniki `BALANCE` bez zmian (sprawdzone przed i po).
- **„Niska” palisada (drobne, pytanie do Rolanda).** Specyfikacja mówi o palisadzie raz „niska” (wstęp), raz „ok. 2 m” (miejsca.md) i raz „za palisadą bez dachu” (notka pod wstępem). Gra ma tekst ze wstępu dosłownie, bo to wymaganie 10. Nie zmieniałem tekstu (język czeka na przegląd Rolanda); opis wariantów i rekomendacja (skreślić „niską”, komunikat mapy: „w zagrodzie Racibora”) jest w karcie `specification/zgloszenia/2026-10-26_niska-palisada.md`, a wiersz 2 arkusza PT0 prosi o ocenę na żywo. Komentarz w `gen_camp.gd` nie zestawia już „niską” z „ok. 2 m”.
- **Banner FC10 (drobne).** „Wpisy człowieka (wiersze 1–2 i uwaga „Reszta spoko”) zostają bez zmian; pozostałe kolumny człowieka są puste”; sprawdziłem, że w factcheckach 08, 09, 11, 12 i 13 człowiek niczego nie wpisał.
- **Ten plik (drobne).** 185 zamiast 186 czytanych flag (wyżej). Pięć scenariuszy ze światem z pierwszego podejścia (`day1`, `night1`, `drudzy`, `save_load`, `week`) wynikało z planu orkiestratora §8, a §9 i `CLAUDE.md` pozwalają bez zgody Rolanda na jeden krótki: to zaznaczam jako odstępstwo, w poprawkach uruchomiłem tylko `week`.
- **Zapisy gry a testy ze światem (drobne).** Scenariusze ze światem nadpisują `saves\auto.json` (a `save_load` także slot 3), czyli w folderze, z którego korzysta wyeksportowana gra i z którego skorzysta Roland w PT0. Zamiast samej prośby o wstrzymanie testów `tools/tests/test_base.gd` trzyma teraz zapisy z `user://saves` w pamięci i przywraca je po przebiegu (też po przekroczeniu czasu). Sprawdzone na prawdziwych zapisach: po `week` i po próbnym skrypcie (nadpisanie, skasowanie i dodanie pliku) skróty SHA-256 trzech plików w `saves` bez zmian. Arkusz PT0 ostrzega i tak, że na czas sesji nie uruchamiamy scenariuszy ze światem.
- **Stopka współautora (drobne).** Zostaje „Claude Sonnet 5.5”, w poprawkach też (powód niżej). Historii nie przepisywałem (§9: za zgodą Rolanda).

## Decyzje i założenia
- **Skrót w buildzie to `27e91e7`** (commit specyfikacji z regułami `8e46253` i szczegółami [ROBOCZE] dopisanymi po weryfikacji; ten sam w `CHANGELOG.md` i we wpisie `WDROZENIA.md`), nie HEAD specyfikacji w chwili budowania (po nim przybywają commity „wdrożone na gałęzi”). Domyślnie skrypt stempluje HEAD (zgodnie z TECH-1); wpisanie podanego commita (`--spec`) to moje rozszerzenie, żeby napis w menu, `CHANGELOG.md` i `WDROZENIA.md` mówiły to samo [ROBOCZE, zapisane w TECH-1].
- **Raport pisany tuż przed ekranem końca**, po scenach rozliczenia, a nie na początku `_week_end()`: łapie stan z samego końca. Ekran końca podaje krótko „raporty/przebieg-….md” (cała ścieżka nie mieści się w ekranie, pełną podaje pauza i arkusz PT0) [ROBOCZE].
- **Pasma jak w notesie**; zdrowie postaci w raporcie ma pięć pasm bohatera (notes ma trzy zdania, te same progi 75/45). Poczytalność Hrapka (stała) opisana jako „stała”. Markdown pokazuje tylko poznane postacie (jak notes), niepoznane wymienia pod tabelami; JSON ma wszystkie z polem `met` [ROBOCZE].
- Dziennik świtów ma też `flags_new` (flagi nowe od poprzedniego świtu, do odtworzenia przebiegu) [ROBOCZE].
- **Bot: interpretacje tabeli „Pomiar”.** Bramki otwierają się przy pierwszej okazji w obozie (zawał: 4 h zaraz po pierwszej wizycie w Starej sztolni, także rano następnego dnia, jeśli wieczorem nie starcza godzin); pompy (2 h) i obuch (0,5 h) przy pierwszej wizycie w Komorze pomp / Starym wyrobisku po dniu bramki; Wszebor jest w obozie od dnia 2 (NPC-17), więc kilof jest najwcześniej w dniu 3; w stylu „rozmowy” o dzień wcześniej otwierają się lina, olej i kaplica (pompy idą za olejem); godziny bramek bot płaci, ale nie wlicza do wyniku trasy; powrót w stylu „rozmowy” do 21:00 (żeby zmieściło się ognisko od 20:00), w stylu „żyły” do 22:00. Linia wyniku ma wariant w nawiasie: `BALANCE[żyły, optymistyczny]` zamiast `BALANCE[żyły]`, bo są po dwa przebiegi na styl [ROBOCZE, do TECH-3 i „Pomiar”].
- **Pauza:** napis ze ścieżką stoi po prawej od przycisków (kolumna wypełnia ekran), z niewidocznymi spacjami po ukośnikach, żeby długa ścieżka łamała się między folderami; w Windows ukośniki wsteczne.
- Nie ruszałem komunikatu `map_screen.gd` „…przy stole z mapą, w kwaterze Racibora. [M] działa w chodnikach.” (żaden z trzech tekstów z kryteriów go nie dotyczy, a „kwatera Racibora” nie jest błędem). Razem z „niską” palisadą trafił do karty pytania dla Rolanda (`specification/zgloszenia/2026-10-26_niska-palisada.md`).
- Stopka współautora we wszystkich commitach na gałęzi (także w poprawkach) to „Claude Sonnet 5.5” i `Claude-Session`, czyli stopka, którą środowisko tej sesji wskazuje dla modelu, który faktycznie pracuje. Polecenie orkiestratora mówi „Claude Opus 5.5”, ale nie chcę wpisywać do historii innego modelu niż ten, który pisał. Odstępstwo od polecenia jest świadome i zapisane tu; jeśli Roland woli „Opus 5.5”, to zmiana już wysłanej historii wymaga jego zgody (§9).

## Czego potrzebuję od Ciebie
- **Merge:** gałąź `spec/2026-10-26-task14` (`e1ba7ca`) jest gotowa i wysłana; do `master` scala tylko Roland (`git merge spec/2026-10-26-task14`, próbne scalenie bez konfliktów). W głównej kopii nic nie czeka w indeksie, więc nic nie blokuje scalenia. Po scaleniu: push `master`, tag `v0.5.3` i `/spec-sync finalize` (⬜→✅ dla NPC-18, CZAS-16, UI-6, UI-7, ZAP-11, ZAP-12, TECH-1…TECH-3, wstępu i wiersza ekranu końca, przeniesienie wiersza z „Na gałęziach” do „Wpisów”, wpis skrótu `27e91e7`, task do `done/`). Szczegóły [ROBOCZE] są już w specyfikacji, więc finalizacja tylko zmienia znaczniki.
- **PT0 (etap 3):** zagraj w build z `build/Everhorror-demo-0.5.3-windows.zip` i wypełnij `docs/human-tasks/factcheck-test-14.md` (leży na gałęzi, w głównej kopii pojawi się po scaleniu; do tego czasu w worktree `../everhorror-wdrozenie`). Jego opis zgadza się z buildem (napis „0.5.3 · spec 27e91e7” w prawym dolnym rogu menu głównego, SAVE REPORT między OPTIONS a MAIN MENU, folder `%APPDATA%\Godot\app_userdata\Everhorror\raporty\`, ekran końca w wierszu 15). Kolumn „wynik” i „uwagi” nie ruszałem. **Na czas sesji PT0 nie uruchamiam na tym komputerze scenariuszy ze światem** (zapisy i raporty leżą w jednym folderze danych; od tej wersji testy przywracają zapisy po sobie, ale sesja nie powinna się z nimi zbiegać).
- **Do rozstrzygnięcia:** (1) „niska” palisada i słowo „kwatera” w komunikacie mapy: karta `specification/zgloszenia/2026-10-26_niska-palisada.md`, rekomendacja A (skreślić „niską”), kanon i język czekają na przegląd Rolanda; (2) czy ekran końca bez logo przy długim podsumowaniu (poprawka `_fit_end_panel`) jest ok, czy wolisz przewijane podsumowanie (wiersz 15 arkusza).

## Test
**Po poprawkach (`e1ba7ca`, po `--import`)**, logi w `reports/tests/` i `reports/fix/` worktree, żaden bez SCRIPT ERROR (runner by go oblał):

```
unit          3s  RESULT: ALL PASSED   (223 sprawdzenia OK, 0 FAIL)
lint          2s  RESULT: ALL PASSED   (16 etykiet czasu, 0 bez kategorii; 185 czytanych flag, 0 bez ustawienia)
dialogue      6s  RESULT: ALL PASSED
balance       3s  RESULT: ALL PASSED (1415 checks)
week         24s  RESULT: ALL PASSED  (21.7 s)
BALANCE[żyły, optymistyczny]: norma 12 → dzień 4, 13:00 (żyły po dniu 7: 23)
BALANCE[żyły, opóźniony]: norma 12 → dzień 4, 17:00 (żyły po dniu 7: 22)
BALANCE[rozmowy, optymistyczny]: norma 12 → dzień 4, 18:30 (żyły po dniu 7: 19)
BALANCE[rozmowy, opóźniony]: norma 12 → dzień 5, 15:30 (żyły po dniu 7: 17)
```
Jeden scenariusz ze światem (`week`: raport na końcu tygodnia, SAVE REPORT, śmierć i powtórzenie dnia), bo tyle wolno bez zgody Rolanda (§9). Wyniki `BALANCE` takie same jak przed poprawką bramki kaplicy. Próby mutacyjne: czas normy po miejscu w dzienniku (`unit`: 5 FAILED), brak form żeńskich i gorączki (`unit`: 4 FAILED), etykieta czasu w `script/hud.gd` (`lint`: FAILED); po przywróceniu kodu wszystko ALL PASSED. Zapisy gry: po `week` i po próbnym skrypcie (nadpisanie, skasowanie i dodanie pliku w `saves`) SHA-256 trzech plików (`auto.json`, `slot_1.json`, `slot_2.json`) bez zmian. Eksport 0.5.3 bez błędów, archiwum z trzema plikami, dymny test exe w trybie menu (kod 0, jedyny komunikat to znany `Capture not registered: 'beehave'`). Nie uruchamiałem po poprawkach: `night1`, `drudzy`, `save_load`, `day1` (zmiany ich nie dotykają poza `test_base.gd`, sprawdzonym na `week`), więc warto je puścić przy pełnym zestawie (za zgodą).

**Pierwsze podejście (`085913b`)**, w tym pięć scenariuszy ze światem (więcej, niż wolno bez zgody Rolanda; wynikało z planu orkiestratora §8, pełnego zestawu nie uruchamiałem):

```
unit          2s  RESULT: ALL PASSED
lint          2s  RESULT: ALL PASSED
dialogue      5s  RESULT: ALL PASSED
balance       2s  RESULT: ALL PASSED (1406 checks)
night1       10s  RESULT: ALL PASSED  (8.5 s)
drudzy       21s  RESULT: ALL PASSED  (18.7 s)
save_load     8s  RESULT: ALL PASSED  (7.2 s)
week         23s  RESULT: ALL PASSED  (21.0 s)
day1         24s  RESULT: ALL PASSED  (22.7 s)
BALANCE[żyły, optymistyczny]: norma 12 → dzień 4, 13:00 (żyły po dniu 7: 23)
BALANCE[żyły, opóźniony]: norma 12 → dzień 4, 17:00 (żyły po dniu 7: 22)
BALANCE[rozmowy, optymistyczny]: norma 12 → dzień 4, 18:30 (żyły po dniu 7: 19)
BALANCE[rozmowy, opóźniony]: norma 12 → dzień 5, 15:30 (żyły po dniu 7: 17)
```
Żaden log nie ma SCRIPT ERROR (runner by go oblał). Dodatkowo: próby mutacyjne (cofnięta poprawka B1: `unit` 8 FAILED; usunięta etykieta z `RunReport`: `lint` FAILED; przywrócony `hieronim_gone`: `lint` FAILED; po przywróceniu kodu wszystko ALL PASSED), `stamp_build.js` w pięciu scenariuszach, zrzuty okna (menu główne, pauza po SAVE REPORT, ekran końca z najdłuższym podsumowaniem), eksport, rozpakowanie archiwum, dymny test exe. Nie uruchamiałem: pozostałych scenariuszy (`schedule`, `places`, `camp_walk`, `hrapek`, `first_meet`, `rzapie`, `day2`, `kaplica`, `day3`, `expedition`) ani pełnego zestawu; `hrapek`, `expedition` i `first_meet` dotykają systemów, w których zmieniłem tylko kod pasm i dzienniki, więc warto je puścić przy pełnym zestawie (za zgodą). Nikt nie sprawdził rozgrywki na żywo: to zadanie PT0.

## Podsumowanie
Build 0.5.3 jest gotowy i czeka na Rolanda na gałęzi `spec/2026-10-26-task14` (`e1ba7ca`, po weryfikacji): Sabina i Drudzy z Exitium nie tracą poczytalności, zanim dotrą (NPC-18), wstęp mówi o zagrodzie Racibora, martwy warunek `hieronim_gone` zniknął, menu główne pokazuje „0.5.3 · spec 27e91e7”, a gra zapisuje raport przebiegu na końcu tygodnia i z pauzy (SAVE REPORT; zapis w wersji 6, starsze zapisy działają, a czas normy w takim zapisie nie jest już zgadywany). Po weryfikacji arkusz PT0 leży na gałęzi (a nie w nieśledzonym pliku w głównej kopii, którą oczyszczono), raport odmienia pasma według płci i pokazuje gorączkę, szczegóły z implementacji są w specyfikacji (`27e91e7`), a testy ze światem nie nadpisują już zapisów gry. Bot balansu daje pierwszy pomiar: norma 12 żył najwcześniej w dniu 4, w stylu „rozmowy” w dniu 4–5, jako górna granica tempa. Testy `unit`, `lint`, `dialogue`, `balance` i `week` przechodzą, archiwum `build/Everhorror-demo-0.5.3-windows.zip` zbudowano od nowa i leży w worktree i w głównej kopii. Do rozstrzygnięcia przez Rolanda zostają: „niska” palisada (karta w specyfikacji) i ekran końca bez logo. Czeka scalenie, sesja PT0 i finalizacja znaczników ⬜.
