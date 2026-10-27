<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zgłoszenia ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_35: Załamanie bohatera w nocy

Wymagania:
1. Zgłoszenie zgloszenia/2026-10-27_zalamanie-w-nocy.md (błąd), „Co”: „Gdy poczytalność bohatera spada do zera podczas rozliczenia nocy, załamanie nie następuje: bohater budzi się z poczytalnością 0 („załamany”), bez planszy „Ciemność” i bez powrotu do 20. [ZDR-10](../03_mechaniki/zdrowie_i_poczytalnosc.md) obiecuje scenę i powrót do 20, a [PET-10](../03_mechaniki/petla_i_sterowanie.md) mówi, że załamanie kończy dzień.”
2. To samo zgłoszenie, pytanie agenta i odpowiedź: „Czy w wariancie a) dzień po załamaniu ma się toczyć normalnie (rekomendacja), czy ma przepaść jak przy załamaniu w ciągu dnia (wtedy gracz traciłby cały następny dzień)?

- **Odpowiedź (Roland, 2026-10-27):** Tak, ma przepaść. Załamny i siedzi przy ognisku i odpoczywa cały dzień.”
3. ZDR-10 (03_mechaniki/zdrowie_i_poczytalnosc.md) ✅: „Załamanie przy zerze: plansza „Uciekasz przed czymś, czego nie ma”. Ktoś przynosi bohatera do obozu, wyprawa się kończy, reszta dnia przepada, a poczytalność wraca do 20.”
4. PET-10 (03_mechaniki/petla_i_sterowanie.md) ✅: „Załamanie (poczytalność bohatera spada do zera): reszta dnia przepada.”

Źródło: specyfikacja `67b762e` · ID: ZDR-10, PET-10 (reguły ✅) · Zgłoszenia: zgloszenia/2026-10-27_zalamanie-w-nocy.md
Poziom: rozgrywka

Priorytet: do ustalenia (zgłoszenie błędu z analizy K3; dziś rzadkie, ważne przed etapem 6, który doda nocne spadki) · Kolejność: po task_27, jeśli tamto już zmieni planszę poranka (oba dotykają `_sleep()` / poranka w `StoryDirector`); inaczej niezależne

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Poprawka przywraca regułę ✅ (ZDR-10, PET-10), więc nie wymaga nowej reguły ⬜ (D-23). Wariant a) ze zgłoszenia (załamanie rano), z odpowiedzią Rolanda: **następny dzień przepada**, bohater załamany siedzi przy ognisku i odpoczywa cały dzień.

**Systemy i pliki:** `script/story_director.gd`: `_sleep()` ustawia `_busy = true` i woła `_resolve_night()`, które zabiera poczytalność (−3 za noc, −3 za gorączkę); `_on_player_broke()` wychodzi przy `if _busy: return`, więc sygnał `player_broke` przepada (numery linii w zgłoszeniu, z master `c82a4dd`). Kierunek: zapamiętać załamanie w nocy i po śnie, zamiast zwykłego poranka, pokazać planszę z ZDR-10, ustawić poczytalność na 20 i przewinąć dzień (bohater przy ognisku, bez wypraw i rozmów) do snu i rozliczenia kolejnej nocy. Balans: wiersz „Załamanie” w `07_balans.md` (`_on_player_broke()`).

**Do ustalenia przez wykonawcę (odczytanie agenta, do zapisania w „Decyzje i założenia”):**
- Jak „przepada” dzień: najprościej plansza ZDR-10 + plansza o dniu przy ognisku, zegar do 22:00 (wpis „Załamanie” w dzienniku czasu, kategoria do CZAS-16), potem zwykły sen i rozliczenie nocy. Wieczór przy ogniu (−15% zmęczenia, poczytalność w górę) liczy się raz, nie za każdą godzinę.
- Noc 7 → dzień 8: dnia do stracenia nie ma, rano jest rozliczenie normy; wtedy tylko plansza i poczytalność 20.
- Zdarzenia dnia, który przepadł (np. ranny Welf bez pomocy, zakład z Sobkiem, upomnienie Racibora), toczą się jak przy dniu bez działania gracza.

**Test:** jednostkowy na gołym `StoryDirector` (wzór `_task14_arrival`): noc z poczytalnością ≤ 3 daje planszę załamania, 20 rano i przewinięty dzień. Przy domknięciu: zdanie o załamaniu w nocy w ZDR-10 / PET-10 lub w przypadkach brzegowych `czas.md` („Bohater się załamie → …”), żeby specyfikacja opisywała grę.

Pełna analiza: `/ai-task analyze 35`.

## Analiza

(`/ai-task analyze 35`, przebieg z dashboardu 2026-10-27, na podstawie master gry `f45b9b0` i specyfikacji `67b762e`.)

**Jak jest dziś.**
- `GameState.change_player_sanity()` (`script/game_state.gd:720–734`) emituje `player_broke` przy każdym wywołaniu, po którym poczytalność wynosi 0, także bez powodu i także kilka razy z rzędu.
- `StoryDirector._sleep()` (`script/story_director.gd:402–424`) ustawia `_busy = true`, loguje „Sen” i woła `_resolve_night()`. Ta zabiera bohaterowi −3 za wstrząs w noc 5 (`:462`), −3 za noc (`:472`) i −3 za gorączkę (`:477`). Każde zejście do 0 emituje `player_broke`, ale `_on_player_broke()` (`:579–600`) wychodzi przy `if _busy: return` (`:582`). Bohater budzi się więc w paśmie „załamany” i zostaje w nim, aż coś podniesie poczytalność. Potwierdza to opis zgłoszenia.
- Załamanie w ciągu dnia (`_on_player_broke()`): plansza „Ciemność” z tekstem ZDR-10, koniec wyprawy, poczytalność 20, zegar wprost na 22:00 (`:595`, bez wpisu w dzienniku czasu i bez zmęczenia), potem `await _sleep()`. Dla tego wzoru zrobimy wariant nocny.
- Za bohatera załamanego rano nie odpowiada nic innego: `_return_to_camp()` (−3 „Wracasz po nocy”, `:263`) i pierwsze wejście w miejsce (`:228`) działają po `_busy = false`, więc tam załamanie działa.

**Luki i ryzyka.**
1. **Wykrycie.** Najprościej i najpewniej: po `_resolve_night()` sprawdzić `GameState.player_sanity <= 0`, zamiast łapać sygnał (emitowany do trzech razy w jednej nocy). Przy okazji naprawi to stare zapisy z bohaterem „załamanym”: następna noc go podniesie.
2. **Kolejność ekranów.** Noc → sen (VN, CZAS-10) → `start_next_day()` (dzień N+1, zapis świtu) → plansza „Ciemność” → plansza dnia N+1 z nowinami i zdaniem o dniu przy ognisku → zegar 22:00 → druga noc (rozliczenie N+1, sen) → zwykły poranek dnia N+2. Tekst ZDR-10 „Budzisz się na posłaniu, ktoś cię przyniósł” nie pasuje do nocy, bo bohater już leży. Pierwsze zdanie zostaje („Uciekasz przed czymś, czego nie ma.”), reszta to nowy wariant nocny **[ROBOCZE]**, do sprawdzenia przez `lore-checker`.
3. **Przewinięcie dnia.** Gdyby wywołać `advance_time(16)`, doszłoby +32% zmęczenia (+2%/h w obozie) i mrugnięcia rozkładu. Rozwiązanie: wpis do dziennika `log_time(6.0, 16.0, "Załamanie")`, ustawienie `hour` wprost, bez `_tire()`. Wpis „Załamanie” musi mieć kategorię w `RunReport.LABEL_CATEGORY` (`script/run_report.gd:30–37`), bo inaczej `tools/data_lint.gd` zgłosi etykietę bez kategorii. Proponuję „obóz” **[ROBOCZE]**.
4. **Ognisko.** Roland: „siedzi przy ognisku i odpoczywa cały dzień”. Proponuję jeden raz `rest_by_fire()` (−15% zmęczenia) i `mark_today("campfire")`, bez bonusu poczytalności z `ognisko.dialogue`, bo ZDR-10 mówi wprost „wraca do 20” **[ROBOCZE]**. Noc po straconym dniu zabierze z tych 20 zwykłe −3 (z gorączką −6), czyli rano 17 (14). Tak samo jest dziś po załamaniu w dzień, więc oba warianty kończą się tak samo.
5. **Śniadanie dnia, który przepadł.** `_morning_events()` (`:543–554`) dla straconego dnia nie wołamy (nikt nie siedzi z bohaterem przy śniadaniu, Racibor nie upomina, `rep` bez zmian). Pułapka: gdy przepadnie **dzień 3**, ogłoszenie normy (`day == 3 and not announcement_done`) nie padnie nigdy, a w dniu 4 Racibor upomni o normę, której gracz nie usłyszał. Plan: warunek `day >= 3 and not has_flag("announcement_done")`, czyli ogłoszenie rano w dniu 4. Dla zwykłej gry nic to nie zmienia, bo w dniu 3 ogłoszenie zawsze pada **[ROBOCZE]**.
6. **Koniec tygodnia.** Załamanie w noc 7 → dzień 8: nie ma dnia do stracenia. Plansza „Ciemność”, poczytalność 20, potem `_week_end()` bez zmian. Załamanie w noc 6 zabiera dzień 7, czyli dzień normy. To surowe, ale wynika z odpowiedzi Rolanda; trzeba to opisać w przypadkach brzegowych.
7. **Zapis poranka.** `SaveManager.capture_morning()` dopiero rano w dniu N+2. „Powtórz dzień” po śmierci nie może cofać do straconego dnia, w którym nie da się nic zrobić. Zapis świtu (`record_dawn()`) powstaje dla obu dni, jak dziś, i raport przebiegu (ZAP-11) pokaże dzień N+1 z jednym wpisem „Załamanie”.
8. **Zdarzenia straconego dnia** (ranny Welf bez pomocy, Dobrawa, gorączka Nasira, Hrapek po nocy 5, wstrząs w noc 5) rozliczają się w drugiej nocy jak po dniu bez działania gracza. Nie trzeba tu nic dodawać, wystarczy test, że noc N+1 przechodzi przez `_resolve_night()`.
9. **Zbieżność z task_27.** Oba zadania zmieniają `_sleep()`: task_27 zmienia nowiny w listę i dodaje „Śniadanie” na planszy poranka, a task_35 wstawia gałąź załamania. task_27 (po task_26) zapowiada też, że „Załamanie i śmierć nie wywołują plansz” pory dnia. Najlepiej robić task_35 **po** scaleniu task_27, a jeśli task_35 pójdzie pierwsze, task_27 musi przy scalaniu objąć nową gałąź (plansza straconego dnia bez „Śniadania”).
10. **Test na gołym `StoryDirector`.** `_sleep()` używa `fade`, `markers` i `VN` (węzły `@onready`), więc w `unit_test.gd` nie da się go uruchomić. Stan trzeba przenieść do metod bez grafiki, które testuje się jak `_task14_arrival`. Plansze sprawdzi scenariusz w scenie `test_week.gd` (noc, VN snu, `start_next_day`).

Pytań do Rolanda nie ma: kierunek rozstrzygnęła odpowiedź w zgłoszeniu (wymaganie 2), a szczegóły 2–5 to wybory **[ROBOCZE]** do weta, do wpisania w „Decyzje i założenia”.

## Plan

1. **`script/story_director.gd`**
   - `_night_broke() -> bool`: `GameState.player_sanity <= 0`, sprawdzane w `_sleep()` zaraz po `_resolve_night()`.
   - `_lose_day_after_break() -> void` (sam stan, bez grafiki; testowalna): `player_sanity = 20` + `player_changed.emit()`, `note_event(...)` w notatce dnia, `log_time(DAY_START_HOUR, DAY_LENGTH_HOURS, "Załamanie")`, `hour = DAY_START_HOUR + DAY_LENGTH_HOURS`, `rest_by_fire()`, `mark_today("campfire")`. Dla dnia 8 (`day >= LAST_DAY`) tylko poczytalność 20.
   - W `_sleep()` po `start_next_day()`: przy załamaniu plansza „Ciemność” (wariant nocny), dla dnia 8 od razu `_week_end()`. W innym razie `_lose_day_after_break()`, plansza „Dzień N” ze zdaniem o dniu przy ognisku (nowiny z nocy przed nim), bez `_morning_events()` i bez `capture_morning()`, i drugi obieg nocy. Zamiast rekurencji pętla w `_sleep()` (np. `while true` z wyjściem na zwykłym poranku), żeby `_busy` i `push_modal()`/`pop_modal()` zostały w równowadze.
   - `_on_player_broke()`: zostaje dla dnia. Wspólny tekst pierwszego zdania planszy jako stała (`BREAK_TITLE`/`BREAK_LINE`), nowe zdania przez `tr()` (D-09).
   - `_morning_events()`: warunek ogłoszenia `day >= 3` (pkt 5 analizy).
2. **`script/run_report.gd`**: `"Załamanie": "obóz"` w `LABEL_CATEGORY`. Przy okazji sprawdzić, czy `_on_player_broke()` w dzień też loguje przeskok zegara. Dziś nie loguje (`:595`). Wpis dla dnia to osobna, mała zmiana tego samego wiersza balansu, więc wykonawca dopisze ją tylko wtedy, gdy nie rusza to `test_week` (inaczej zostaje uwagą w raporcie).
3. **Testy.**
   - `tools/unit_test.gd`, nowa sekcja `_task35_night_break()` na gołym `StoryDirector`: (a) `player_sanity = 3`, `day = 2`, `_resolve_night()` → `_night_broke()`; (b) `_lose_day_after_break()` → poczytalność 20, `hour == 22.0`, wpis „Załamanie” 960 min, `done_today("campfire")`, zmęczenie niższe o `FATIGUE_FIRE`; (c) gorączka + sanity 6 → załamanie; (d) `day = 8` → tylko 20, zegar bez zmian; (e) `RunReport.categorize("Załamanie") == "obóz"`.
   - `tools/tests/test_week.gd`: noc z poczytalnością 3 przez prawdziwe `_sleep()`: rano dzień N+2, poczytalność 17, dziennik dnia N+1 = jeden wpis „Załamanie”, `announcement_done` przy straconym dniu 3 ustawione rano w dniu 4.
   - Testy: serwer po wdrożeniu uruchamia `unit lint dialogue` oraz scenariusze `week night1 day3` (dialogi bez zmian, nowych `class_name` brak; agent robi krótki `--import` przed pierwszym testem).
4. **Lore.** `lore-checker` dla wariantu nocnego planszy „Ciemność” i zdania o dniu przy ognisku.
5. **Specyfikacja** (commit `[agent]` po lincie): ZDR-10 i PET-10 zostają (to reguły ✅, gra wraca do zgodności). Dopisać w przypadkach brzegowych `03_mechaniki/czas.md` („Bohater się załamie w nocy → rano plansza „Ciemność”, poczytalność 20, następny dzień przepada przy ognisku; po nocy 7 tylko plansza” **[ROBOCZE]** w szczegółach) i `03_mechaniki/zdrowie_i_poczytalnosc.md` („Załamanie w nocy → …”). W `07_balans.md` wiersz „Załamanie” uzupełnić o wariant nocny i `_lose_day_after_break()`. W „Dla agenta” ZDR dopisać nową metodę. Bez nowego wiersza w „Zmiany agenta poza specyfikacją” (D-23).
6. **Dokumentacja gry:** `docs/agent/README.md` (system nocy i załamania), `tools/README.md` (opis `test_week.gd`).
7. **Arkusz** (poziom `rozgrywka`): jedna część `## Część: task_35` arkusza builda (D-27): doprowadzić bohatera do niskiej głowy (gorączka z Zalanego + nocne spadki) i sprawdzić planszę, dzień przy ognisku i poranek z 17.

**Kolejność:** po task_27 (a ono po task_26). Wszystkie trzy zmieniają `_sleep()` / poranek w `StoryDirector`.

Pliki: script/story_director.gd, script/run_report.gd, tools/unit_test.gd, tools/tests/test_week.gd, docs/agent/README.md, tools/README.md
Ryzyko: średnie

## Przepływ (D-36)
Poziom `rozgrywka`: zmiana przebiegu nocy i planszy załamania, które gracz widzi. Arkusz tylko jako jedna część `## Część: task_35` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `średnie`: jeden skrypt przebiegu nocy (`_sleep()`) i dwa testy, a pętla nocy jest pilnowana przez `test_week`.

## Podsumowanie

Analiza gotowa. Załamanie w nocy przepada, bo `_on_player_broke()` ignoruje sygnał, gdy `_sleep()` trzyma `_busy`. Plan wykrywa je po rozliczeniu nocy, pokazuje planszę „Ciemność” w wariancie nocnym, ustawia poczytalność 20 i zgodnie z odpowiedzią Rolanda przewija następny dzień przy ognisku do drugiej nocy (po nocy 7 tylko plansza). Przy okazji naprawia ogłoszenie normy, które przy straconym dniu 3 nigdy by nie padło. Pytań do Rolanda nie ma: szczegóły (tekst planszy, kategoria „obóz”, jedno `rest_by_fire()` bez bonusu poczytalności, ogłoszenie w dniu 4) to **[ROBOCZE]** do weta. Wdrażać po task_27.
