# task_37: Otwarcie na trzy dni

<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-28). Wymagania to cytat zasad ze specyfikacji w commicie 254e024; nie edytować.
-->

Wymagania:
1. OTW-1 (04_tresc/otwarcie.md) ⬜: „**Otwarcie to domyślna nowa gra.** „New game” w menu głównym zaczyna otwarcie: trzy dni, koniec wieczorem dnia 3 na spotkaniu z Exitium (OTW-9). Pełny tydzień zostaje w grze bez zmian jako druga pozycja menu „Full week (old demo)” (dla sesji PT0b, bota balansu i testów) i dla zapisów sprzed tej zmiany. Zasady [tygodnia](tydzien.md) dotyczą tylko tego wariantu. **[ROBOCZE]** Gra rozpoznaje otwarcie po fladze `opening` w zapisie; zapis bez niej to tydzień.”
2. OTW-2 (04_tresc/otwarcie.md) ⬜: „**Obsada otwarcia: czterech ludzi w obozie.** Racibor (daje robotę i dostęp; jego żądania biorą się z nacisku z góry), Bolko (znał dziadka; jego wspomnienia niosą winę i są niepełne), Mirosław (otwiera zasypany chodnik; ta robota go rani) i Tekla (dzięki niej obóz działa; pomaga, ale waży, co mówi). Każdego poznaje się przez bieżącą sprawę, nie przez cztery biografie z rzędu.
   - Wszebor, Nasir, Hagiwara, Sobek, brat Anzelm, Dobrawa i Hrapek **nie pojawiają się wcale**: ani w obozie, ani na szychcie w dniu 1, ani w scenach i kwestiach innych. Ich zadania (`kilof`, `pompy`, `goraczka`, `wiersz`, `zaklad`, `pokoj`, `sciana`, `ryba`, `odlamek`) nie startują. Ich ID, dane i dialogi zostają w grze na kolejne rozdziały.
   - Nieobecnym nic się nie dzieje w nocy: bez spadków poczytalności, bez gorączki Nasira, bez odejść i śmierci (rozszerza [NPC-18](../03_mechaniki/npc.md)).
   - W wariancie otwarcia nie obowiązują: szychta piątki w dniu 1 ([NPC-17](../03_mechaniki/npc.md), [NPC-21](../03_mechaniki/npc.md)), zjazd Dobrawy w nocy na dzień 2, Hrapek od dnia 3 i Sabina w obozie po spotkaniu ([tydzień](tydzien.md)).
   - Wyprawa z Exitium (Ottokar, Sabina, Hieronim, Welf) jest tylko w scenie końcowej (OTW-9). Mówi Ottokar; pozostali towarzyszą mu bez osobnych przedstawień i próśb **[ROBOCZE]**.
   - Reszta ekipy to bezimienni górnicy na zmianach: wspomina o nich wstęp i kolacja, nie mają własnych rozmów.”
3. OTW-3 (04_tresc/otwarcie.md) ⬜: „**Trzy miejsca.** Na mapie wypraw otwarcia są tylko Stara sztolnia, Zawalony chodnik (po wybuchu, [miejsca](miejsca.md)) i Upadowa (z liną, przez Zawalony chodnik). Inne miejsca nie pojawiają się na mapie ani na drogach. Dwie żyły do pierwszego raportu leżą w Starej sztolni i nie wymagają kilofa.”
4. OTW-4 (04_tresc/otwarcie.md) ⬜: „**Jedna obietnica, małe zadanie na start.** Norma tygodnia (12 żył) jest tłem. Bieżące zlecenie to dwie żyły za odpis raportu z archiwum (`zloza`, wpis `zdane`), obok lontów dla Mirosława (`lonty`) i śladów dziadka (`slady`). Tekla w otwarciu nie daje zadania tobołka (`towar`); wydaje linę za kwit od Racibora, świecę i kolację (OTW-8). Jej dylemat z tobołkiem czeka, aż gracz ją pozna. Tekst wstępu **[ROBOCZE]**:
   > Zeszliście szybem wczoraj po zmroku. Lina skrzypiała przez całą drogę w dół, a na górze został tylko pusty wóz.
   > Obóz rozbito w wielkiej jaskini na końcu starej kopalni. Dalej są już tylko chodniki, których od czterdziestu lat nikt nie sprawdzał. No i mapy dziadka.
   > Kniaź chce do końca tygodnia dwunastu żył błękitu na mapie. Zarządca Racibor najpierw sprawdzi, czy w ogóle jesteś coś wart. Za pierwsze dwie żyły obiecał odpis z archiwum, z czasów, kiedy przepadł dziadek.
   > Reszta ekipy kopie na zmiany w chodnikach przy obozie i na rozmowy nie ma czasu. Pogadać można z zarządcą, z kwatermistrzynią Teklą i z dwoma górnikami: starym Bolkiem, który znał dziadka, i Mirosławem od prochu.
   > Wyprawy planujesz przy stole z mapą w zagrodzie Racibora, za palisadą bez dachu. W chodnikach mapa [M] pokaże ci drogę dalej albo z powrotem. Na noc wracasz na posłanie.”
5. OTW-5 (04_tresc/otwarcie.md) ⬜: „**Poranki i ogłoszenie.** Plansza poranka dnia 2 w otwarciu **[ROBOCZE]**: „Kocioł Tekli dymi od świtu. Przy szybie ktoś już klnie na zimno.” (zamiast zdania o Dobrawie). Pierwszeństwo nowiny o Mirosławie (CZAS-19, [tydzień](tydzien.md#poranki)) zostaje. Ogłoszenie Racibora w dniu 3 zostaje (norma i plan otwarcia upadowej, jeśli zna żyłę w upadowej), bez kwestii Dobrawy. Pytania o Dobrawę i inne nieobecne osoby nie pojawiają się w rozmowach.”
6. OTW-6 (04_tresc/otwarcie.md) ⬜: „**Papiery dziadka z Bolkiem zamiast odszyfrowania we śnie.** W otwarciu kartka i klucz nie odszyfrowują się same w nocy. Gdy gracz ma obie notatki (`szyfr`, `klucz`), może usiąść nad nimi w obozie:
   - z Bolkiem: „Usiądźmy nad kartką dziadka. (1 h)”, gdy zaufanie Bolka ≥ 0 **[ROBOCZE]**;
   - sam, przy posłaniu: „Usiądź sam nad kartką dziadka. (1 h)”, zawsze, żeby niskie zaufanie albo pominięta rozmowa nie zatrzymały historii.
   - Scena VN ma trzy proste kroki **[ROBOCZE]**: (1) jak czytać deskę (litery z kartki szukasz w dolnym, przesuniętym rzędzie i czytasz górny), (2) zatarte słowo w zdaniu „…to kawałek Ich ___” (odpowiedź: snu), (3) dokąd dziadek „zszedł niżej” (odpowiedź: upadową). Zła odpowiedź nic nie kosztuje: Bolko albo własne notatki podpowiadają, gracz wybiera jeszcze raz. Bolko pomaga przy każdym kroku; sam gracz ma krótsze podpowiedzi.
   - Wynik jak dotąd: notatka `odszyfrowana`, wpis `slady`/`odszyfrowane`, flaga `deciphered`; do tego wpis `slady`/`niżej` **[ROBOCZE]**: „Dziadek pisze, że zszedł niżej. Wszystko wskazuje na upadową. Muszę ją obejrzeć.” Sen z kartką „twoim pismem” w otwarciu odpada, bo gracz pisał sam.
   - **Komplikacja Bolka [ROBOCZE]:** przy kroku 3 Bolko mówi, że przez czterdzieści lat myślał, że dziadka przygniótł jego źle postawiony stempel (dotąd to wyznanie było dopiero przy liście z kaplicy). Gdy gracz obejrzy zawał w upadowej (`saw_charge`), może wrócić do Bolka: „To nie był twój stempel.” Bolko odpowiada inaczej niż dotąd; następnego ranka wita gracza inaczej.”
7. OTW-7 (04_tresc/otwarcie.md) ⬜: „**Czas z Mirosławem po wybuchu (oba warianty).** „Jak się trzymasz?” po wybuchu zabiera 1 h **[ROBOCZE]** i daje trzy podejścia: zapytać o robotę, posiedzieć w ciszy albo powiedzieć wprost, że widać, ile go to kosztuje. Nie ma ukrytej „właściwej” odpowiedzi: każde z trzech liczy się jak dzisiejsze „Posiedzę z tobą chwilę” (ta sama zmiana poczytalności i zaufania, `mir_comforted`), a różni się tym, co Mirosław mówi teraz i rano następnego dnia (pierwsza rozmowa w późniejszym dniu ma kwestię zależną od podejścia). „Weź się w garść, robota czeka.” zostaje jako czwarta odpowiedź, bez godziny.”
8. OTW-8 (04_tresc/otwarcie.md) ⬜: „**Kolacja u Tekli (otwarcie).** Od 18:00 do 20:00, przy kuchni, rozmowa z Teklą ma odpowiedź „Siądę do kolacji.” (raz dziennie, bez nagrody i bez osobnej godziny poza zwykłymi 5 minutami odpowiedzi). Tekla i pozostali krótko reagują na to, co się dziś stało: pierwszy dzień, wybuch, szyfr, raport z archiwum, upadowa **[ROBOCZE]**. Ognisko po 20:00 zostaje; w otwarciu ma wersję tylko z tymi, którzy są w obozie (bez zdania o „połowie ekipy na nocnej szychcie”).”
9. OTW-9 (04_tresc/otwarcie.md) ⬜: „**Koniec otwarcia: Exitium przychodzi po mapy.** W dniu 3, gdy bohater jest w obozie od 18:00 **[ROBOCZE]** (po powrocie z wyprawy albo gdy czas w obozie minie 18:00), albo wcześniej, gdy w dniu 3 kładzie się spać, do palisady podchodzi wyprawa Drugich z Exitium. Ottokar chce map dziadka, które gracz już ma; kryształu w otwarciu nie ma.
   - Mała decyzja **[ROBOCZE]**: pokazać mapy, zapytać, po co mu one (Ottokar odpowiada, gracz wybiera dalej: pokazać, odmówić albo odłożyć), albo odmówić. Każda kończy się natychmiastową reakcją kogoś z obozu (Racibor, Bolko albo Mirosław) i Ottokara.
   - Potem klif: Ottokar zapowiada, że Sabina zostanie w obozie, a Hieronim szepcze ostrzeżenie; z głębi, zza zawału w upadowej, ktoś stuka **[ROBOCZE]**.
   - Spotkanie nie zależy od tego, czy gracz był w upadowej, miał żyły czy odczytał szyfr.”
10. OTW-10 (04_tresc/otwarcie.md) ⬜: „**Ekran końcowy otwarcia.** Tytuł „Koniec otwarcia”. Pierwszy akapit **[ROBOCZE]**: „Exitium przyszło po mapy dziadka. Tu kończy się otwarcie.” Dalej stan: żyły (bez „z 12 wymaganych”), raport z archiwum, wiadomość dziadka, upadowa, decyzja o mapach, Mirosław, Bolko, Tekla, Racibor. Raport przebiegu (ZAP-11) zapisuje się jak przy końcu tygodnia, z zakończeniem `koniec_otwarcia`.”
11. 07_balans.md#otwarcie ⬜: „Liczby [otwarcia](04_tresc/otwarcie.md) (OTW-6, OTW-7, OTW-9), wszystkie **[ROBOCZE]**, do weta Rolanda.”

Źródło: specyfikacja `254e024` · ID: OTW-1, OTW-2, OTW-3, OTW-4, OTW-5, OTW-6, OTW-7, OTW-8, OTW-9, OTW-10 · Zgłoszenia: —
Poziom: rozgrywka

Priorytet: polecenie Rolanda, czat 2026-10-28 („Implement this proposition as one task. I want this recommended thre-day openning built. Make it in one commit so it's easly reversible.”) · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Zadanie zakłada i wdraża jedna sesja terminalowa (planowanie i wdrożenie z czatu Rolanda). Systemy: `GameState` (flaga `opening`, obsada, `has_arrived`, `in_camp_today`), `CampSchedule`/`FieldSchedule` (nieobecni), `Expeditions` (trzy miejsca), `StoryDirector` (wstęp, noc bez odszyfrowania, poranek dnia 2, scena końcowa, ekran końcowy), `SaveManager.new_game`, menu główne (druga pozycja), dialogi Bolka, Mirosława, Tekli, Racibora, `system`, `ognisko`, `drudzy`, generator `write_story_data.js` (wpis `slady`/`niżej`), `RunReport` (zakończenie `koniec_otwarcia`). Ryzyka: wariant tygodnia ma zostać bez zmian (testy tygodnia startują go jawnie), konflikt z otwartymi zadaniami task_26, task_29, task_30 (ognisko, dialogi) przy scalaniu.

## Plan
Pliki: script/game_state.gd, script/save_manager.gd, script/main_menu.gd, scene/main_menu.tscn, script/camp_schedule.gd, script/field_schedule.gd, script/expeditions.gd, script/story_director.gd, script/run_report.gd, dialogue/*.dialogue, dialogue/gwara_slaska.json, tools/generators/write_story_data.js, tools/generators/write_gwara.js, data/quests/slady.tres, tools/tests/*, tools/unit_test.gd, tools/dialogue_test.gd, tools/data_lint.gd, tools/run_tests.sh, tools/README.md, docs/agent/README.md
Ryzyko: średnie

## Co zostało zrobione
Gałąź `spec/2026-10-28-task37`, kopia `../everhorror-wt/spec-2026-10-28-task37`, jeden commit gry `b250ebb` (polecenie Rolanda: jeden commit, łatwy do cofnięcia). Specyfikacja: `254e024` (zasady), `6d9bccf` („Dla agenta”), księga `3326185` (🧪).

1. **OTW-1.** START (`SaveManager.new_game()`) ustawia flagę `opening`. Nowy przycisk FULL WEEK (OLD DEMO) (`new_game(true)`) i zapisy bez flagi grają tydzień jak dotąd. Z wiersza poleceń: `-- --new-game`, dla tygodnia `-- --new-game --full-week`.
2. **OTW-2.** `GameState.deferred()` i `OPENING_DEFERRED` obejmują 11 osób. Nie stawia ich żaden rozkład (`CampSchedule`, `FieldSchedule`), a `has_arrived()` i `in_camp_today()` zwracają dla nich fałsz, więc noce ich nie ruszają. W otwarciu nie ma szychty w dniu 1, Dobrawy, gorączki Nasira, Hrapka (`hrapek_due`) ani losowania Drugich. Pytania o Dobrawę i zadanie tobołka są ukryte.
3. **OTW-3.** `Expeditions.in_chapter()` zostawia na mapie, w drogach i na mapie w polu tylko `east`, `west` i `upadowa`. Dwie żyły do raportu leżą w Starej sztolni i nie wymagają kilofa.
4. **OTW-4.** Wstęp `intro_opening` ma tekst ze specyfikacji. Tekla nie daje w otwarciu zadania tobołka; lina dalej idzie za kwit.
5. **OTW-5.** Plansza dnia 2: „Kocioł Tekli dymi od świtu. Przy szybie ktoś już klnie na zimno.” Racibor w dniu 2 nie mówi o gościu z Initium. Ogłoszenie w dniu 3 nie ma kwestii Dobrawy; po uldze Bolka ma jego nową kwestię.
6. **OTW-6.** W otwarciu noc nie odczytuje szyfru. Scena z Bolkiem (`papers`, zaufanie ≥ 0) albo sama przy posłaniu (`papers_alone`) ma trzy kroki, a zła odpowiedź wraca z podpowiedzią. Wynik to wpisy `odszyfrowane` i `nizej`. Bolko przyznaje się do krzywego stempla; po `saw_charge` gracz może mu powiedzieć „To nie był twój stempel.”, a Bolko ma też kwestie następnego ranka.
7. **OTW-7.** Trzy podejścia po 1 h, z tymi samymi liczbami co dawne „Posiedzę z tobą chwilę” (`mir_comforted`). `support_morning` daje osobną kwestię na każde podejście w późniejszym dniu. Zmiana działa w obu wariantach.
8. **OTW-8.** Kolacja u Tekli (`supper`, 18–20, raz dziennie, bez nagrody) ma jednorazowe reakcje na pierwszy wieczór, wybuch, szyfr, raport i upadową. Ognisko w otwarciu (`gawedy_otwarcie`) ma tylko czwórkę.
9. **OTW-9.** Spotkanie z Exitium przychodzi w dniu 3 od 18:00 w obozie albo przy posłaniu (`_opening_finale_due`). Gracz może pokazać mapy, zapytać po co (wtedy pokazać, odmówić albo się zastanowić) albo odmówić. Każda odpowiedź dostaje reakcję, po niej Sabina zostaje, Hieronim ostrzega i zza zawału słychać stukanie.
10. **OTW-10.** Ekran „Koniec otwarcia” ma podsumowanie bez „z 12 wymaganych”. Raport przebiegu zapisuje się z `koniec_otwarcia`, a noc po scenie nie następuje.
11. **07_balans „Otwarcie”.** Liczby w kodzie i dialogach są zgodne z tabelą: dzień 3, 18:00, 1 h, zaufanie ≥ 0, +5/+4, +8/+5.

## Decyzje i założenia
- Polecenie Rolanda z czatu 2026-10-28 zastąpiło tu `/spec-tasks` i `/ai-task` z dashboardu. Jedna sesja terminalowa zapisała zasady ⬜ (OTW), plik zadania, wiersz w księdze i wdrożenie.
- Pełny tydzień zostaje osiągalny z menu, bo plan §1 wymaga PT0b na pełnym tygodniu. Plan mówi też, że przed PT0b nie zaczyna się nowych funkcji, a etap 9 rusza na hasło Rolanda; nowsze polecenie Rolanda ma pierwszeństwo, a napięcie jest zapisane w `04_tresc/otwarcie.md` („Decyzja i dowody”).
- Nazwy w grze różnią się od tekstu specyfikacji w dwóch miejscach, oba opisane w „Dla agenta”: przycisk nazywa się START (nie „New game”), a klucz wpisu to `nizej` (ID bez polskich znaków).
- Poprawki po przeglądzie lore (`lore-checker`):
  - stemple Bolka stoją na dnie upadowej, bo wejście jest w specyfikacji „za połamanymi stemplami”;
  - Bolko nie utożsamia „Ich” z Pierwszymi („w skale ktoś śpi”);
  - Ottokar nie twierdzi, że Exitium „wie od dawna” („Nas to nie dziwi.”), więc nic nie przesądza, która wersja zawalenia jest prawdziwa;
  - dawny problem, że piwnica Mirosława to żadna tajemnica, poprawiony: tajemnicą jest to, co robi mu lont.
- Poprawki po przeglądzie konwencji (`convention-reviewer`): `TranslationServer.translate()` dla nowego tekstu w `Expeditions`, odpowiedzi Mirosława w pierwszej osobie, przeniesiony komentarz w `GameState`, zdanie w `CLAUDE.md` usunięte (plik i tak przekracza 10 KB, opis jest w `docs/agent/README.md`).
- Bez zmian zostają: raport przebiegu wymienia osoby odłożone wśród „jeszcze nie poznanych”, a wyznanie Bolka przy liście z kaplicy (tylko w tygodniu) po nowej scenie się powtarza; w otwarciu kaplicy nie ma.

## Czego potrzebuję od Ciebie
- Ogranie buildu według arkusza [factcheck-build-b250ebb.md](../../human-tasks/done/factcheck-build-b250ebb.md). Pytania o hak są w wierszach 12–13.
- Weto albo zgoda na teksty [ROBOCZE]: wstęp, papiery, Mirosław, kolacja, scena z Exitium, a także godzina 18:00 i sceny po 1 h (`07_balans.md` „Otwarcie”).
- Konflikty przy scalaniu są możliwe z otwartymi zadaniami, które dotykają tych samych dialogów i dni: task_26 (ognisko dni 2–4, poranki), task_29 (historia postaci), task_30 (ciągi kwestii), NPC-21 (szychta dnia 1; w otwarciu go nie ma).
- Kopia gałęzi task_21 (`spec/2026-10-28-task21`) ma niezacommitowaną pracę i nie ma wiersza w „Na gałęziach”. Licząc gałęzie gita, to czwarta otwarta gałąź `spec/*` (D-33: do trzech); według księgi trzecia.

## Test
Scenariusze dla serwera: `unit lint dialogue opening day1`.

Wyniki agenta (kopia gałęzi, po `--import`, na końcu po poprawkach z przeglądu):
- `unit` 3s RESULT: ALL PASSED
- `lint` 8s RESULT: ALL PASSED (WARNINGS: 20, te same co przed zmianą)
- `dialogue` 7s RESULT: ALL PASSED
- `opening` 28s RESULT: ALL PASSED
- `day1` 24s RESULT: ALL PASSED
- Przed poprawkami z przeglądu, sprawdzenie tygodnia: `balance` ALL PASSED (1415 checks, norma jak przed zmianą: dzień 4, 13:00 … dzień 5, 15:30), `schedule`, `first_meet`, `night1`, `drudzy`, `day3`, `save_load` ALL PASSED. Pełnego zestawu nie uruchamiano.

Arkusz: [factcheck-build-b250ebb.md](../../human-tasks/done/factcheck-build-b250ebb.md).

Build do ogrania (`node <spec>/dashboard/cli.ts build task_37`, 2026-10-28): **nie powstał**. Nowy krok „test eksportu” (dashboard `691ad9d`) przepuścił `day1`, ale nie `expedition`: `RESULT: 10 FAILED` (żyły 0 z 12, zachodni chodnik otwarty przed wybuchem). To znany błąd eksportu, który gubi listy w zasobach ([zgłoszenie](../../../../specification/zgloszenia/zamkniete/2026-10-27_eksport-gubi-listy.md)); poprawka leży na gałęzi task_25, jeszcze nie w `master`. Gałąź task_37 wyszła z `master` `7109aeb`, więc ma ten sam błąd. Grywalny build będzie po scaleniu task_25 i włączeniu `master` do tej gałęzi; tę decyzję podejmuje Roland, agent nie scala. Log: `build/do-ogrania/Everhorror-test-task37-b250ebb-windows.log`.

## Przegląd kodu i poprawki (2026-10-28)
Przegląd kodu: Opus 5.5, zlecenie: koordynator. Werdykt: **poprawki** (jeden błąd, reszta uwag). Poprawki wykonał Sonnet 5.5 na gałęzi, commit `e26bb9f`; przed nimi do gałęzi włączono `master` (commit scalenia `2e6dc5d`).

**Włączenie `master` do gałęzi.** `git merge master` przeszedł bez konfliktów (poprawka eksportu z task_25: `project.godot` `export/convert_text_resources_to_binary=false`; `tools/run_tests.sh` uruchamia w `lint` także `check_spec_data.js`, `tools/export_smoke.sh` jest ostrzejszy). Gałąź ma więc teraz trzy commity: `b250ebb` (otwarcie), `2e6dc5d` (scalenie), `e26bb9f` (poprawki).

| # | Ustalenie (kto) | Co dostało |
|---|---|---|
| 1 | **Błąd.** W dniu 3 posłanie od razu kończyło grę, bez pytania „Kładziesz się?”, a `papers_alone` było nieosiągalne; łamało OTW-6 („zawsze”) i przypadek zaufania Bolka < 0 (przegląd Opus 5.5) | Naprawione: `script/story_director.gd` (`_on_used` zawsze otwiera `sleep`; w `_on_dialogue_finished` odpowiedź „Tak, idę spać” w dniu 3 woła `_opening_finale()` zamiast `_sleep()`). Test w `tools/tests/test_opening.gd`: dzień 3, 10:00, zaufanie Bolka < 0, obie notatki: posłanie nie kończy gry, „Usiądź sam nad kartką dziadka” odszyfrowuje w godzinę, potem sen wywołuje finał bez nocy. Test 17:30 przy posłaniu też najpierw zadaje pytanie |
| 2 | Opisy przedmiotów obozu nazywają nieobecnych (Wszebor, Hagiwara, Anzelm), OTW-2 (przegląd Opus 5.5) | Naprawione: `Interactable` ma `opening_name` i `opening_description` (`shown_name()`, `shown_description()`, użyte w `script/hud.gd` i w podpowiedzi), `tools/generators/gen_camp.gd` ustawia neutralne wersje czterech przedmiotów („Narzędzia”, „Księga zarządcy”, „Skrzynka z ziołami”, „Skrzynia w kącie”). Scena `camp.tscn` odtworzona generatorem; po zamaskowaniu losowych `unique_id` różni się od poprzedniej tylko pięcioma nowymi liniami `opening_*`. Tydzień bez zmian. Zostają dwa opisy w `gen_locations.gd` (Wszebor przy kilofie, Nasir przy pompie), bo to miejsca spoza otwarcia (Wyrobisko, Pompy) |
| 3 | `opening_done` ustawiane przed VN, a ~1,2 s przed ekranem końcowym dało się wejść w Esc → SAVE GAME (przegląd Opus 5.5) | Naprawione: `_opening_finale()` robi `GameState.push_modal()` na samym początku (menu pauzy odmawia otwarcia przy modalu), bez pop, bo to koniec. Test w `test_opening.gd` pilnuje `is_modal()` w każdej klatce od sceny do ekranu końcowego |
| 4 | `~ day2`: wątek o stemplu połykał `bolko_day2_secret` (rep ≥ 10) (przegląd Opus 5.5) | Naprawione: `dialogue/bolko.dialogue`, po kwestiach o stemplu zagnieżdżone `if rep("bolko") >= 10` z tą samą kwestią sekretu i flagą (brak nowego tekstu, więc klucz gwary bez zmian). Test w `tools/dialogue_test.gd` |
| 5 | `#region task_37` wstawiony między komentarz a `_row_cells` (przegląd Opus 5.5) | Naprawione: `tools/unit_test.gd`, region przeniesiony za koniec regionu `task_14` |
| 6 | `docs/agent/README.md` nie wymienia FULL WEEK (przegląd Opus 5.5) | Naprawione; dopisane też zachowanie łóżka, modalu finału i `opening_name` |
| 7 | Luki w testach (przegląd Opus 5.5) | Dodane: przyciski menu (`unit_test.gd` sprawdza połączenia `start_button` → `new_game()` i `full_week_button` → `new_game(true)`), zapisy v3 do v6 bez flagi grają tydzień (`unit_test.gd`), plansza dnia 2 w otwarciu i w tygodniu (`unit_test.gd`), ogłoszenie dnia 3 bez Dobrawy i Initium (`dialogue_test.gd`), finał po powrocie z wyprawy po 18:00 (19:30) i po 22:00 (23:30) (`test_opening.gd`), brak kolacji po 20:00 (`unit_test.gd` rozkład Tekli, `dialogue_test.gd` brak odpowiedzi), Hrapek: w świecie nie ma jego węzła, więc test świata sprawdza `hrapek_due() == ""` przy fladze `hrapek_free` w dniu 3 |
| — | Pole `wariant: otwarcie|tydzien` w raporcie przebiegu (opcjonalne) | Dodane (`script/run_report.gd`, jedna linia; test w `unit_test.gd`). Markdown raportu bez zmian |
| — | Zostawione jak jest (napięcia projektowe do Rolanda): finał o 18:00 w dniu 3 wyprzedza kolację i ognisko; dodatkowa kwestia Hieronima „Śpi, śpi. Chrapie.”; raport przebiegu wymienia odłożone osoby jako jeszcze niepoznane | Bez zmian, zgodnie ze zleceniem |

Testy po poprawkach (kopia gałęzi, po `--import`, scalone `master`):
- `unit` 3s RESULT: ALL PASSED
- `lint` 9s RESULT: ALL PASSED (WARNINGS: 20, te same; `RULES: skipped`, bo w kopii gałęzi nie ma folderu specyfikacji)
- `dialogue` 6s RESULT: ALL PASSED
- `opening` 52s RESULT: ALL PASSED (50.5 s)
- `day1` 24s RESULT: ALL PASSED (22.4 s)
- `expedition` 15s RESULT: ALL PASSED (14.0 s)
- `week` 22s RESULT: ALL PASSED (21.3 s)
- `save_load` 13s RESULT: ALL PASSED (11.6 s)
- `tools/export_smoke.sh`: `export: 13s, game.pck 109 MB`, `day1 RESULT: ALL PASSED (21.8 s)`, `expedition RESULT: ALL PASSED (13.5 s)`, `RESULT: ALL PASSED (export smoke: day1 expedition ran from the exported pack)`. Po włączeniu `master` poprawka eksportu z task_25 działa na tej gałęzi, więc dashboard może zrobić grywalny build (wcześniejszy brak buildu z sekcji „Test” był skutkiem tego błędu).

## Podsumowanie
Otwarcie na trzy dni jest wdrożone na gałęzi `spec/2026-10-28-task37` w commicie `b250ebb`. Cofa się je jednym `git revert` (plus poprawki z przeglądu), a gałąź można też po prostu odrzucić. START daje czterech ludzi w obozie, trzy miejsca, papiery dziadka z Bolkiem, godzinę z Mirosławem, kolację u Tekli i koniec na Exitium wieczorem dnia 3. Pełny tydzień zostaje pod FULL WEEK (OLD DEMO). Po przeglądzie kodu doszły dwa commity (scalenie `master` `2e6dc5d` i poprawki `e26bb9f`), więc otwarcie to pierwszy commit `b250ebb` i poprawki; testy agenta są zielone, ale to nie jest ogranie: czeka arkusz i weto tekstów [ROBOCZE].
