<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_28: Zapis atomowy, migracje wersji, potwierdzenie nadpisania, autozapis przy posłaniu

Wymagania:
1. ZAP-13 (03_mechaniki/zapis_i_opcje.md) ⬜: „**[ROBOCZE]** Zapis atomowy: plik powstaje jako `*.tmp` i dopiero potem zastępuje właściwy (zmiana nazwy), więc awaria w trakcie zapisu nie niszczy slotu. Poprzedni `auto.json` zostaje obok jako kopia zapasowa `auto.prev.json`. Dziś gra pisze wprost do pliku i przerwany zapis świtu niszczy jedyny zapis „od rana”. (Źródło: analiza propozycji projektu, K2, 2026-10-27, rekomendacja agenta do weta Rolanda; łączy się z odpowiedzią Rolanda o migracjach, ZAP-14.)”
2. ZAP-14 (03_mechaniki/zapis_i_opcje.md) ⬜: „**[DECYZJA 2026-10-27]** Wersja zapisu i migracje: wczytanie czyta pole `version`. Zapis **starszej** wersji przechodzi migracje krok po kroku do bieżącej (każda zmiana wersji dodaje krok z wartościami domyślnymi i test), zamiast wczytywać się z lukami ad hoc jak dziś (ZAP-4, ZAP-8, ZAP-12). Slot z wersją **nowszą** niż gra jest pokazany jako „zapis z nowszej wersji gry” i się nie wczytuje, bez błędu i bez uszkodzenia pliku. (Roland, 2026-10-27: „No to zaplanuj i zmigruj”; szczegóły K2 z analizy propozycji projektu.)”
3. ZAP-15 (03_mechaniki/zapis_i_opcje.md) ⬜: „**[DECYZJA 2026-10-27]** Zapis do zajętego slotu ręcznego pyta „Nadpisać zapis z <data>?” (Tak / Nie); pusty slot zapisuje się bez pytania. AUTO nie pyta, bo nie jest ręcznym slotem (ZAP-9). (Roland, 2026-10-27: „Tak”.)”
4. ZAP-16 (03_mechaniki/zapis_i_opcje.md) ⬜: „**[DECYZJA 2026-10-27]** Autozapis do slotu AUTO jest o świcie (ZAP-9) i przy zasypianiu przy posłaniu, przed rozliczeniem nocy (odczytanie agenta: „zapis przy posłaniu” z pytania to autozapis). **Zapis ręczny w dowolnym momencie w FPP zostaje**, „bo póki co testujemy” (Roland, 2026-10-27: „Tak plus zapis ręczny w dowolnym momencie”). 💡 Dopiero etap 9 (demo publiczne): w buildzie dema można ukryć SAVE GAME i zostawić tylko AUTO, bo ręczny zapis przed rozmową znosi ciężar wyboru (filar 1); to pomysł, nie reguła (propozycja D4 z analizy propozycji projektu, Roland nie zdecydował).”
5. Przypadki brzegowe (03_mechaniki/zapis_i_opcje.md): „Zapis z nowszej wersji gry → ZAP-14 ⬜: pokazany jako nowszy i niewczytywany; starsze przechodzą migracje.”

Źródło: specyfikacja `67b762e` · ID: ZAP-13, ZAP-14, ZAP-15, ZAP-16 (dotyka ZAP-3, ZAP-4, ZAP-8, ZAP-9, ZAP-12) · Zgłoszenia: —
Poziom: rozgrywka

Priorytet: pozycja 6 w „Czeka na wdrożenie” · Kolejność: — (niezależne od task_25…task_27; jeśli inne zadanie w tym samym czasie podnosi wersję zapisu, migracje idą przez mechanizm z tego zadania)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
**Systemy i pliki** („Dla agenta” w `zapis_i_opcje.md`): autoload `SaveManager` (`SAVE_VERSION`, `save_game`, `load_game`, `restore_pending`, `capture_morning`, sloty i AUTO), `GameState.save_state()` / `load_state()` (dziś luki starszych wersji obsługiwane warunkami w miejscu), `scene/save_slots_panel.tscn` i jego skrypt (okno potwierdzenia nadpisania i etykieta slotu z nowszej wersji), `StoryDirector._sleep()` (autozapis przed `_resolve_night()`).

**Język:** sloty zapisu to menu, a menu jest po angielsku (UI-5, ZAP-6), więc polskie zdania w ZAP-14 i ZAP-15 opisują treść, a na ekranie stoi ich angielski odpowiednik (np. „Overwrite save from <date>?” YES / NO, „Saved by a newer version”). To odczytanie agenta; jeśli Roland chce polskich napisów w tym oknie, to wyjątek od UI-5.

**Kierunek:** zapis przez `*.tmp` + zmiana nazwy (`DirAccess.rename`), kopia `auto.prev.json` przed nadpisaniem AUTO; tabela migracji `version → version+1` (4→5, 5→6, …) zamiast warunków w `load_state()`, z testem `unit` dla każdego kroku (wczytanie przykładowego zapisu każdej wersji); slot nowszy niż gra pokazany i zablokowany.

**Ryzyka:** autozapis przy posłaniu nadpisuje AUTO ze świtu, więc „od rana” jest teraz w `auto.prev.json`, a ZAP-7 (powtórzenie dnia) korzysta z pamięci, nie z dysku: sprawdzić, że RETRY FROM MORNING dalej wraca do poranka. Zmiana wersji zapisu wymaga wpisu w ZAP-4 przy domknięciu.

Pełna analiza: `/ai-task analyze 28`.

## Analiza

Przebieg z dashboardu `20261027-203825-analyze-28-991a86` (2026-10-27). Kod czytany w głównej kopii (`master`, `f45b9b0`).

**Jak jest dziś**
- `script/save_manager.gd:70` `_write()` otwiera `slot_path(slot)` w trybie `WRITE` (to od razu obcina plik) i robi `store_string`; plik zamyka dopiero zwolnienie referencji. Awaria albo zabicie procesu między obcięciem a zapisem zostawia pusty lub urwany JSON, a `read_slot()` (`:48`) traktuje go jak „empty” z ostrzeżeniem. Kopii zapasowej nie ma. Wynik `store_string` (w 4.7 zwraca `bool`) nie jest sprawdzany.
- AUTO (`auto.json`) pisze tylko `capture_morning()` (`:90`), które zarazem ustawia poranek w pamięci `_morning` (ZAP-7). Wołają je: `StoryDirector._ready` po wczytaniu/starcie (`story_director.gd:79`), koniec intro (`:88`) i świt w `_sleep()` (`:422`).
- Wersja: `_collect()` wpisuje `"version": SAVE_VERSION` (6), ale **nikt jej nie czyta**. `load_game()` (`:79`) przekazuje `game_state` wprost do `GameState.load_state()` (`game_state.gd:1010`), a luki starszych wersji łata seria `data.get(..., domyślne)` z komentarzami „Saves before task_09/11/12/14” (`:1031`–`:1044`). Wyprawa sprzed wersji 5 (ZAP-4) jest łatana osobno w `script/expeditions.gd:90`. Zapis z wersją wyższą niż 6 wczytałby się bez ostrzeżenia, gubiąc nieznane pola.
- Najstarszy znany numer to 3 (`save_manager.gd:14`); zapisy 0.2 (ZAP-8) mogą mieć wersję 1–2 albo nie mieć wcale — brak pola trzeba czytać jako „najstarsza”.
- `script/save_slots_panel.gd:64` w trybie SAVE zapisuje od razu (ZAP-3 „bez pytania”). Panel siedzi w pauzie (`pause_menu.gd`), drzewo jest zapauzowane, pauza obsługuje Esc w `_unhandled_input` (`:31`: Esc w podmenu wraca do listy głównej).
- `_sleep()` (`story_director.gd:402`) jest wołane z posłania (akcja `sleep` po dialogu, `:177`) i po załamaniu poczytalności (`:600`, wymuszony sen).
- Testy: `unit` sprawdza `SAVE_VERSION == 6` i wczytanie zapisu bez dzienników (`tools/unit_test.gd:440`–`:450`); `save_load` zapisuje slot 3 i sprawdza wersję 6 (`tools/tests/test_save_load.gd:19`).

**Luki względem wymagań**
1. ZAP-13: brak zapisu przez `*.tmp` i brak `auto.prev.json`.
2. ZAP-14: brak odczytu `version`, brak łańcucha migracji, brak obsługi slotu nowszego.
3. ZAP-15: brak okna potwierdzenia.
4. ZAP-16: brak autozapisu przy zasypianiu. Ręczny zapis w FPP już działa i ma zostać (bez zmian).
5. Przypadek brzegowy: jak 2.

**Ryzyka**
- **`DirAccess.rename` na Windows przy istniejącym celu.** Nie mam pewności, że w Godot 4.7 zmiana nazwy nadpisuje istniejący plik w każdym sterowniku. Plan zakłada kolejność odporną na oba warianty: (1) zapisz `<slot>.tmp`, zamknij, sprawdź wynik; (2) dla AUTO: usuń stare `auto.prev.json`, przemianuj `auto.json` → `auto.prev.json`; dla slotu ręcznego: przemianuj stary → `<slot>.bak`; (3) przemianuj `.tmp` → właściwy; (4) usuń `.bak`. W każdej chwili na dysku jest co najmniej jedna pełna kopia. Test `unit` sprawdza drugi zapis do tego samego slotu (cel istnieje).
- **Autozapis przy posłaniu a ZAP-7.** Nowy autozapis wieczorny nie może ruszać `_morning`, bo RETRY FROM MORNING ma wracać do poranka. Potrzebna osobna funkcja (`autosave()`), a `capture_morning()` zostaje „pamięć + AUTO”. Po nocy świt i tak nadpisuje AUTO porankiem, więc w `auto.prev.json` ląduje wtedy zapis wieczorny — to zgodne z ZAP-13 (poprzedni `auto.json`), choć „poprzedni poranek” na dysku znika po kolejnym świcie.
- **Wczytanie autozapisu wieczornego**: bohater staje tam, gdzie stał (przy posłaniu, przed nocą), noc jeszcze nie rozliczona; trzeba znów się położyć. `StoryDirector._ready` po wczytaniu woła `capture_morning()`, więc „poranek w pamięci” staje się tym wieczorem aż do najbliższego świtu. Przy wdrożeniu sprawdzić, czy między zaśnięciem a świtem coś może zabić bohatera (`_resolve_night`); jeśli tak, RETRY wróci do wieczoru przy posłaniu, co jest akceptowalne. Oznaczam jako **[ROBOCZE]**.
- **Wymuszony sen po załamaniu** (`:600`) też przechodzi przez `_sleep()`; autozapis obejmie i jego. **[ROBOCZE]**: każde zaśnięcie autozapisuje, bo stan po załamaniu (bohater przy posłaniu, koniec dnia) jest spójny.
- **Migracje a `load_state()`.** Domyślne `.get(...)` w `load_state()` zostają jako siatka bezpieczeństwa (uszkodzone pole), ale znaczenie „starszej wersji” przechodzi do kroków migracji, a komentarze „Saves before task_…” wskazują na nie. Wersja zapisu **nie rośnie** (format się nie zmienia), więc ZAP-4 nie wymaga zmiany numeru.
- **Równoległe zadania.** task_20 (otwarte) dopisuje do `GameState.save_state()/load_state()` pole opcjonalne bez podnoszenia wersji: konflikt tekstowy w `game_state.gd` możliwy przy scalaniu, merytorycznie się nie gryzą. Jeśli któreś zadanie podniesie wersję, dopisuje krok migracji do tabeli z tego zadania (zgodnie z „Kolejność”).
- **Testy piszą do prawdziwego `user://saves`** (tak już jest: `capture_morning` w scenariuszach). Nowe testy `unit` używają osobnego katalogu (np. parametr katalogu w `SaveManager` albo slot testowy) i sprzątają po sobie `.tmp`, `.bak`, `prev`, żeby nie niszczyć zapisów testera.
- **Język okna**: menu po angielsku (UI-5, ZAP-6); polskie zdania z ZAP-14/ZAP-15 to treść, napis to „Overwrite the save from <data>?” YES / NO oraz „saved by a newer version”. To odczytanie agenta (jak w analizie wstępnej), bez karty: wynika wprost z ZAP-6.

**Pytania do Rolanda:** brak. Szczegóły, które spec zostawia otwarte, rozstrzygam jako **[ROBOCZE]** (lista w Planie, kroku 6); Roland może je wetować przy arkuszu.

## Plan

1. **Zapis atomowy (ZAP-13)** — `script/save_manager.gd`:
   - `_write()` pisze do `slot_path(slot) + ".tmp"`, sprawdza `store_string`, jawnie `close()`, potem podmiana w kolejności z Ryzyk (AUTO: stary → `auto.prev.json`; ręczny: stary → `.bak`, po sukcesie usunięty). Błąd na którymkolwiek kroku: `push_error`, `false`, stary plik nietknięty.
   - Stały `AUTO_BACKUP_PATH` (`auto.prev.json`). **[ROBOCZE]**: `read_slot(AUTO_SLOT)` przy uszkodzonym/brakującym `auto.json` i istniejącym `auto.prev.json` czyta kopię (rząd AUTO pokazuje wtedy dopisek „(backup)”), bo tylko tak kopia realnie chroni „od rana”. Osierocone `.tmp` są ignorowane przez `has_save`/`read_slot` i usuwane przy następnym zapisie.
2. **Wersje i migracje (ZAP-14, przypadek brzegowy)** — `script/save_manager.gd`:
   - `MIGRATIONS`: kroki na całym słowniku zapisu, `_migrate_to_4(data)` … `_migrate_to_6(data)` plus krok zbiorczy „≤3 → 3” (zdrowy bohater, bez wyprawy, amulet: ZAP-8). Każdy wpisuje wartości domyślne do `game_state` (`time_log {}`; `asked {}`, `player.fatigue 0`; `dawn_log []`, `vein_log []`) i podnosi `version`. Brak pola `version` = 1. Krok 4→5 przejmuje też łatkę wyprawy z `expeditions.gd:90` (jeśli da się ją wyrazić danymi; inaczej zostaje tam z odsyłaczem do kroku).
   - `migrate(data) -> Dictionary` woła kroki po kolei do `SAVE_VERSION`; `load_game()` i `retry_morning()` (dane z bieżącej wersji, bez kosztu) idą przez nią.
   - `slot_version(data)`, `is_newer(data)`; `load_game()` zwraca `false` dla nowszego bez dotykania pliku i bez `push_error` (tylko `push_warning`).
   - `GameState.load_state()` (`script/game_state.gd`): komentarze przy domyślnych wskazują na migracje; logika bez zmian.
   - Komentarz przy `SAVE_VERSION`: „podniesienie wersji = nowy krok w `MIGRATIONS` + test w `unit`”.
3. **Potwierdzenie nadpisania (ZAP-15)** — `script/save_slots_panel.gd`, `scene/save_slots_panel.tscn`:
   - W trybie SAVE zajęty slot otwiera `ConfirmationDialog` (dziecko panelu, `process_mode = ALWAYS`, bo drzewo zapauzowane): „Overwrite the save from <data>?” z datą z `_describe()`, przyciski YES / NO, fokus na NO **[ROBOCZE]** (bezpieczniejszy domyślny). Pusty slot zapisuje od razu. AUTO nie jest w trybie SAVE, więc nie pyta.
   - Esc przy otwartym oknie zamyka tylko okno: `pause_menu.gd` `_unhandled_input` nie cofa podmenu, gdy panel ma otwarte okno (np. `save_slots_panel.is_confirming()`).
   - Slot z nowszej wersji: tekst „SLOT n — saved by a newer version (v7)”, w LOAD wyłączony; w SAVE nadpisanie pyta jak każdy zajęty slot **[ROBOCZE]**. AUTO nowszy: wyłączony.
4. **Autozapis przy posłaniu (ZAP-16)** — `script/save_manager.gd`, `script/story_director.gd`:
   - `SaveManager.autosave()`: `_write(AUTO_SLOT, _collect())` bez ruszania `_morning`.
   - `_sleep()`: `SaveManager.autosave()` na początku, po `push_modal`, przed `fade_out`/`log_time`/`_resolve_night()` (stan „przy posłaniu, przed nocą”). Świt (`:422`) zostaje bez zmian. Ręczny zapis bez zmian.
5. **Testy**:
   - `tools/unit_test.gd`: nowa sekcja `_task28_saves()` — migracja syntetycznych zapisów bez wersji, v3, v4, v5 do 6 (pola domyślne, `version == 6`), zapis v7 → `load_game` `false`, plik bajt w bajt ten sam; zapis atomowy dwukrotnie do tego samego slotu (brak `.tmp`/`.bak`, poprawny JSON), AUTO dwa razy → `auto.prev.json` = pierwszy; uszkodzony `auto.json` → `read_slot(AUTO)` z kopii. Katalog testowy odseparowany od zapisów testera.
   - `tools/tests/test_save_load.gd`: zapis do zajętego slotu 3 otwiera okno; NO nie zmienia pliku, YES nadpisuje; pusty slot bez okna.
   - Scenariusz nocy (`night1`): po zaśnięciu `auto.prev.json` (albo AUTO przed świtem) ma godzinę wieczoru dnia 1; RETRY FROM MORNING nadal wraca do poranka (sprawdzić, czy istniejący scenariusz to obejmuje; jeśli nie, dopisać krok).
   - Testy: serwer po wdrożeniu uruchamia `unit lint dialogue` oraz scenariusze `save_load night1` (bez `.dialogue`, bez nowych `class_name`); agent w trakcie pracy uruchamia tylko potrzebne.
6. **Spec i dokumenty** (po wdrożeniu, na gałęzi i w spec): w `03_mechaniki/zapis_i_opcje.md` „Dla agenta”: `migrate`, `MIGRATIONS`, `autosave`, `AUTO_BACKUP_PATH`, okno w `save_slots_panel`; dopisać **[ROBOCZE]**: odczyt kopii przy uszkodzonym AUTO, fokus na NO, nadpisanie nowszego slotu z pytaniem, autozapis także po wymuszonym śnie, napisy po angielsku. ZAP-3/ZAP-8/ZAP-9 przeformułuje `/spec-sync finalize` przy ⬜→✅ (agent nie zmienia znaczników). `docs/agent/README.md` (system zapisu: migracje, atomowość), `CLAUDE.md` bez zmian (brak nowej konwencji poza komentarzem przy `SAVE_VERSION`; ewentualnie jedna linia „podniesienie wersji zapisu = krok migracji + test”).
7. Arkusz (poziom `rozgrywka`): jedna część `## Część: task_28` arkusza builda (D-27): nadpisanie z pytaniem (YES/NO, Esc), pusty slot bez pytania, AUTO po zaśnięciu i wczytanie go, RETRY FROM MORNING po nocy, (opcjonalnie) ręcznie podłożony plik z `"version": 99`.

Pliki: script/save_manager.gd, script/save_slots_panel.gd, scene/save_slots_panel.tscn, script/pause_menu.gd, script/story_director.gd, script/game_state.gd, script/expeditions.gd, tools/unit_test.gd, tools/tests/test_save_load.gd, tools/tests/test_night1.gd, docs/agent/README.md
Ryzyko: wysokie

## Przepływ (D-36)
Poziom `rozgrywka`: zapis i wczytywanie gry oraz okno potwierdzenia nadpisania, które gracz widzi. Arkusz tylko jako jedna część `## Część: task_28` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `wysokie`: dotyka formatu i zapisywania plików zapisu (atomowość, migracje); błąd mógłby zepsuć zapisy gracza i zablokować sesję gry.

## Podsumowanie

Zadanie dotyczy wyłącznie systemu zapisu: zapis przez `*.tmp` z kopią `auto.prev.json`, łańcuch migracji od pola `version` (dziś nieczytanego) z blokadą slotów z nowszej gry, okno „Overwrite the save from <data>?” dla zajętych slotów ręcznych i autozapis AUTO przy zasypianiu, który nie rusza poranka w pamięci (ZAP-7). Wersja zapisu zostaje 6. Pytań do Rolanda nie ma; otwarte szczegóły są w Planie jako [ROBOCZE]. Główne ryzyko techniczne to zachowanie `DirAccess.rename` przy istniejącym pliku na Windows; plan omija je kolejnością zmian nazw i sprawdza testem `unit`. Zadanie jest gotowe do `/ai-task implement 28`.
