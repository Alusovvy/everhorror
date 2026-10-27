<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_32: Ludzie w miejscach: jedna osoba w pomieszczeniu, mniej osób na start, dalej od wejścia

Wymagania:
1. NPC-21 (03_mechaniki/npc.md) ⬜: „**[ROBOCZE]** Mniej ludzi na start, jedna osoba w pomieszczeniu (Roland, playtest 2026-10-27: „Rozważyłbym mniej osób na start, że część dociera wieczorem, bo robili już coś w kopalni, a część drugiego dnia, bo dopiero schodzą” oraz „Nasir i Anzelm pojawiają się razem, ale to lepiej zrobić osobno, chyba że jest jakaś konkretna grupa typu magowie z Initium czy tam Exitium”). **Zmienia NPC-17** w trzech punktach; reszta NPC-17 obowiązuje dalej:
  - **Szychta w dniu 1:** z piątki (Wszebor, Nasir, Hagiwara, Sobek, Anzelm) w pomieszczeniach pierwszego poziomu jest trzech, **po jednym** w Starej sztolni, w Rząpiu i w Zawalonym chodniku (kto trafi za zawał, czeka na wybuch, jak dotąd). Dziś mieści się dwoje w jednym (`GameState.FIRST_ROOM_CAPACITY = 2`), a przy pięciu osobach i trzech pomieszczeniach dwie pary są pewne; w zapisie Rolanda z 2026-10-27 Nasir i Anzelm trafili razem za zawał (`first_room_nasir` = `first_room_anzelm` = `west`).
  - **Wieczór dnia 1:** jeden z pozostałych dwóch wraca do obozu od 18:00 („był niżej w kopalni”) i od tej pory stoi według zwykłego rozkładu (18–20, wieczór); gracz poznaje go w obozie.
  - **Dzień 2:** ostatni zjeżdża szybem w nocy razem z Dobrawą („dopiero schodzi”) i jest w obozie od rana dnia 2. Do tej chwili nie dotarł, więc noc 1 nie zabiera mu poczytalności (NPC-18).
  - Kto gdzie: losowanie raz na nową grę, jak dziś (flagi `first_room_<id>`), z dwoma nowymi przydziałami „wieczór” i „dzień 2”. Zapis sprzed zmiany: kto ma już pokój z dawnego losowania, zostaje w nim (najwyżej dwoje razem), żeby wczytana gra się nie zmieniała [ROBOCZE].
  - **Ogólnie w terenie:** spotkana osoba stoi w miejscu sama. Razem stoi tylko grupa, która przybywa razem: dziś jedynie cała wyprawa z Exitium w dniu 3 (NPC-9). Pojedyncze spotkania Drugich (NPC-9) i górnicy przy pracy (WYP-13) już dziś są pojedynczo, więc reguła zmienia tylko dzień 1. Odległość od wejścia: [WYP-17](wyprawy.md).
  - **Konflikt z NPC-17** (**[DECYZJA 2026-09-26]**, task_10): tam „najwyżej dwoje w jednym” i „cała piątka do końca dnia 1 w pomieszczeniach, wieczorem w obozie ich nie ma”. Nowsza uwaga Rolanda ma pierwszeństwo, ale Roland napisał „rozważyłbym”, więc liczby (3 / 1 / 1) i wybór losowy to propozycja agenta do weta: wynikają z „osobno” (trzy pomieszczenia, więc najwyżej trzy osoby) i z dwóch pór dotarcia, które Roland podał.
  - **Teksty do zmiany razem z regułą** [ROBOCZE]: wstęp w [tygodniu](../04_tresc/tydzien.md#dzień-1) („Reszta ekipy od świtu kopie w chodnikach najbliżej obozu i wróci dopiero jutro”), np. „Trzech od świtu kopie w chodnikach najbliżej obozu, jeden zszedł niżej i wróci wieczorem, a ostatni zjedzie szybem dopiero tej nocy. Chcesz ich poznać, to ich poszukaj.”; zdanie przy ognisku w dniu 1 („połowa ekipy została na nocnej szychcie”); opis dnia 1 w tygodniu i wiersz „Pierwszy dzień” w [balansie](../07_balans.md#npc); powitanie w obozie wieczorem dnia 1 dla tego, kto wrócił (NPC-15: lint pilnuje powitań dla miejsc z rozkładu).
  - **Dla agenta:** `GameState.FIRST_MEET`, `FIRST_ROOMS`, `FIRST_ROOM_CAPACITY`, `roll_first_rooms()`, `first_room()`, `first_room_slot()`, `away_first_day()`, `in_camp_today()`, `has_arrived()` / `ARRIVAL_FLAG` (NPC-18), `script/camp_schedule.gd`, `FieldSchedule.FIRST_DAY_POSES`, wstęp w `dialogue/system.dialogue`, `dialogue/ognisko.dialogue`, powitania w dialogach piątki (`tools/data_lint.gd`), testy `tools/tests/test_first_meet.gd`, `test_schedule.gd`, `test_night1.gd` (rano dnia 2), `unit` (losowanie pokoi).
  - Roland, czat 2026-10-27: podział 3 / 1 / 1 i losowanie, kto gdzie — „tak, losowo”.”
2. WYP-17 (03_mechaniki/wyprawy.md) ⬜: „**[ROBOCZE]** Ludzie spotykani w miejscach stoją z dala od wejścia (Roland, playtest 2026-10-27: „Spawnpointy NPC, których spotyka się w eksploracji w jaskiniach, nie powinny być tak blisko spawnu postaci”). Każde miejsce spotkania (szychta dnia 1, NPC-17 / [NPC-21](npc.md); Drudzy, NPC-9; górnicy przy pracy, WYP-13) jest co najmniej tyle metrów od punktu, w którym gracz się pojawia, ile podaje [balans](../07_balans.md#miejsca), i w dalszej połowie pomieszczenia, tak żeby gracz najpierw zobaczył miejsce, a dopiero potem człowieka. Dziś (generatory w master `c82a4dd`) spotkani stoją 2,4–6,2 m od wejścia (miejsca 1 i 2, na których stają pojedyncze osoby i para z dnia 1): Upadowa 2,4 m, Zawalony chodnik 3,3 m, Stara sztolnia 3,5 m (w korytarzu za deskami, 30 m przed jaskinią), w pozostałych od 4,9 m (Kuźnia) do 6,2 m (Przekop); tylko Kaplica ma 8,6 m. Najpierw ustawić miejsca w Starej sztolni w jaskini za pochylnią, a w Zawalonym chodniku za żyłą. **Dla agenta:** markery `<Place>Spot1..4` w `tools/generators/gen_locations.gd` (`spots()`, wejście z `stub()`: `origin + (-2,3; 0; 0)`, własne wejścia Rząpia, Upadowej i Kaplicy), `EastSpot*` / `WestSpot*` i `EastEntry` / `WestEntry` w `tools/generators/gen_camp.gd:609–661`; `<Place>Work` przy pracy górników; sceny regenerować; `tools/tests/test_places.gd` sprawdza dziś markery obozu, a nowy krok sprawdzi odległość każdego `Spot` i `Work` od `Entry`.
  - Roland, czat 2026-10-27: co najmniej 7 m od wejścia — „Tak”.”
3. Tydzień, dzień 1 (04_tresc/tydzien.md) ⬜: „**[ROBOCZE]** Po [NPC-21](../03_mechaniki/npc.md) (Roland, playtest 2026-10-27): na szychcie trzech, po jednym w każdym pomieszczeniu, jeden wraca do obozu wieczorem dnia 1, a ostatni zjeżdża nocą z Dobrawą. Zdania wstępu i ogniska o „reszcie ekipy” i „połowie ekipy” zmieniają się razem z regułą (propozycja tekstu w NPC-21).”
4. Balans, NPC (07_balans.md) ⬜: „| ⬜ Pierwszy dzień po NPC-21 (zastąpi wiersz wyżej) | w pomieszczeniach 3 osoby, po 1 w każdym; 1 wraca do obozu o 18:00 w dniu 1; 1 zjeżdża nocą i jest w obozie od rana dnia 2; losowanie raz na nową grę [ROBOCZE] | `GameState.FIRST_ROOMS`, `FIRST_ROOM_CAPACITY`, `roll_first_rooms()` |”
5. Balans, miejsca (07_balans.md) ⬜: „⬜ **Odległość spotkanych od wejścia** (WYP-17): co najmniej **7 m** od punktu, w którym pojawia się gracz, w dalszej połowie pomieszczenia [ROBOCZE: szacunek agenta; najmniejsze pomieszczenie, Ślepy szyb, ma od wejścia do ściany ok. 8,8 m]. W grze: markery `<Place>Spot1..4` i `<Place>Work` w `gen_locations.gd`, `EastSpot*` / `WestSpot*` w `gen_camp.gd`.”

Źródło: specyfikacja `67b762e` · ID: NPC-21 (zmienia NPC-17), WYP-17; tydzień (dzień 1); balans (pierwszy dzień, odległość od wejścia) · Zgłoszenia: —
Poziom: rozgrywka

Priorytet: do ustalenia (uwagi z playtestu 2026-10-27, poza kolejką „Czeka na wdrożenie”) · Kolejność: — (generatory miejsc dotyka też task_31: przy równoległej pracy uzgodnić regenerację scen `locations` i `camp`)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Jedna funkcja: kto stoi w miejscach i gdzie. NPC-21 to logika rozkładu i teksty, WYP-17 to geometria markerów w generatorach.

**Systemy i pliki:** wypisane w „Dla agenta” obu reguł (wymagania 1 i 2). Do tego `StoryDirector._resolve_night()` (przybycie ostatniego nocą 1 razem z Dobrawą; „dotarł” jak w NPC-18 przez `has_arrived()`), raport przebiegu (`script/run_report.gd`: kreska dla tego, kto jeszcze nie dotarł, jak przy Sabinie) i zapis (flagi przydziału `first_room_<id>` z nowymi wartościami „wieczór” i „dzień 2”; zgodność wstecz opisana w regule).

**Ryzyka:** zmiana `FIRST_ROOM_CAPACITY` i losowania łamie testy `test_first_meet.gd`, `test_schedule.gd`, `test_night1.gd` (do aktualizacji, nie do wyłączenia). Kto wraca wieczorem, potrzebuje powitania w obozie dnia 1 (lint NPC-15), a kto zjeżdża nocą, nie może dostać nocnego spadku poczytalności za noc 1 (NPC-18). Nowe teksty wstępu i ogniska (kwestie Mirosława i Bolka przy ognisku: klucze gwary) są [ROBOCZE], do weta Rolanda. Po przesunięciu markerów sprawdzić, że nikt nie stoi w ścianie ani za zawałem przed wybuchem (zrzuty ekranu z `tools/` w raporcie); test odległości: każdy `Spot`/`Work` ≥ 7 m od `Entry` i w dalszej połowie pomieszczenia.

## Analiza
(`/ai-task analyze 32`, przebieg z dashboardu 2026-10-27, kod w master `f45b9b0`.)

**Jak jest dziś (NPC-17, task_10).**
- `GameState.roll_first_rooms()` (`script/game_state.gd:922`) wkłada piątkę `FIRST_MEET` do worka z `FIRST_ROOMS × FIRST_ROOM_CAPACITY` (3 × 2 = 6 miejsc), więc zawsze są dwie pary. Wynik leży we flagach `first_room_<id>` = `east` / `rzapie` / `west`; losuje `reset()` (`:217`), a zapis bez flag losuje przy pierwszym pytaniu `first_room()` (`:936`).
- `first_room_slot()` (`:944`) daje 1 albo 2 według kolejności `FIRST_MEET`, a `FieldSchedule.placement()` (`script/field_schedule.gd:36–39`) stawia osobę na markerze `<Place>Spot<slot>`.
- `away_first_day()` (`:955`) to po prostu `day == 1 and id in FIRST_MEET`: przez cały dzień 1, także wieczorem, `CampSchedule.placement()` (`script/camp_schedule.gd:18`) zwraca `{}`, a `in_camp_today()` (`:960`) daje fałsz. Od tego zależy ognisko (`dialogue/ognisko.dialogue:24–34`, `:42`, `:61–87`).
- Noc 1: `_resolve_new_people()` (`script/story_director.gd:499–502`) zdejmuje −2 każdemu, kogo `has_arrived()` uznaje za obecnego. Dziś cała piątka „dotarła” (nie ma jej w `ARRIVAL_FLAG`). Noc rozlicza się przy `day == 1`, a `start_next_day()` przychodzi dopiero potem (`:408–412`), więc wystarczy warunek „przydział dzień 2 i `day < 2`”.
- Raport przebiegu bierze `arrived` ze świtu (`game_state.gd:300`, `script/run_report.gd:182–188`, `:516`): kto jeszcze nie dotarł, dostaje kreskę jak Sabina. Po zmianie dzieje się to samo dla „dnia 2” o świcie dnia 1, bez nowego kodu.
- Teksty: wstęp `dialogue/system.dialogue:106` („Reszta ekipy od świtu kopie… wróci dopiero jutro”), ognisko `ognisko.dialogue:14` („Połowa ekipy została na nocnej szychcie”). Oba to narracja, bez kluczy gwary. Poranna karta dnia 2 (`story_director.gd:533`: „Nocą szybem zjechał ktoś nowy.”) zgadza się z nową regułą i może zostać.
- Powitania: lint (`tools/data_lint.gd:173–185`) wymaga od każdego z `FIELD_FIRST_MEET` gałęzi „teren” i zdania dla każdego pokoju z `FIRST_ROOMS`. O wieczorze dnia 1 lint nic nie wie. Jedyne powitanie w obozie, które wieczorem dnia 1 kłamie, to Sobka: „Widziałem cię przy śniadaniu.” (`dialogue/sobek.dialogue:23`). Pozostali witają się w obozie neutralnie, ale żaden nie mówi, że „był w kopalni”, czego chce NPC-21.

**Jak jest dziś (WYP-17).**
- Lokacje: `spots()` (`tools/generators/gen_locations.gd:769`) stawia `Spot1..4` względem `origin`, a wejście z `stub()` (`:692`) leży w `origin + (-2,3; 0; 0)`. Własne wejścia mają Rząpie (`:373`, to samo przesunięcie), Upadowa (`:459`, +1,2) i Kaplica (`:529`, +0,6). Spoty zaczynają się od x ≈ 2,4–3,8, czyli 2,4–6,2 m od wejścia. Wyjątkiem jest Kaplica (8,6 m). `Work`: Wyrobisko (9,5; −3,9) ma ok. 12 m, Pompy (6,3; −1,7) ok. 8,8 m. Oba już spełniają ≥ 7 m, ale trzeba to sprawdzić testem (dalsza połowa).
- Obóz: `EastEntry` (37,2; 0; 3,0) i `EastSpot1..4` przy x 40,6–43,3 (3,4 m, jeszcze w korytarzu). Pochylnia biegnie przy x 52–64, jaskinia przy x 68–82, z −4…10, podłoga `Y_CHAMBER` = −2,116, skrzynka z lontami stoi w (70,4; 7,4) (`docs/agent/README.md`, `gen_camp.gd:595`). `WestEntry` (−3,4; 0; 3,0) i `WestSpot1..4` przy x −6,6…−9,0 na zjeździe (`gen_camp.gd:660–661`). Żyła stoi przy x −12,2 (z 4,75), deska z kluczem w (−14,5; 1,45), bariera z połamanych stempli przy x ≈ −17,5, podłoga `Y_WEST_LOW` = −2,0. „Za żyłą” to więc pas x −13,4…−16,4, z dala od deski z kluczem.
- `tools/tests/test_places.gd:43` celowo pomija markery `Entry` i `*Spot*` (stoją poza jaskinią obozu), a markerów w lokacjach nie sprawdza wcale.
- Spotkanie wyprawy z Exitium w dniu 3 może wypaść w każdym miejscu, także w Starej sztolni i Zawalonym chodniku (`_roll_encounter()`, `story_director.gd:283`). Wszystkie cztery spoty każdego miejsca muszą więc spełniać ≥ 7 m i leżeć w dalszej połowie, a nie tylko spot 1.

**Luki i ryzyka.**
1. **Zgodność zapisu:** stary zapis ma pięć pokoi (najwyżej dwoje razem) i ma tak zostać (reguła). `first_room_slot()` musi więc dalej umieć zwrócić 2, a `<Place>Spot2` musi istnieć i spełniać WYP-17. Nowa gra daje zawsze slot 1.
2. **Nowe wartości flag:** `first_room_<id>` dostaje też `evening` i `day2` (identyfikatory w kodzie po angielsku, w regule „wieczór” i „dzień 2”). `first_room()` zwraca je bez zmian. `FieldSchedule` porównuje je z `place_id`, więc nikogo nie postawi w terenie, a lint i `test_schedule` iterują po `FIRST_ROOMS`, więc ich nie zobaczą. Test jednostkowy (`tools/unit_test.gd:77–80`) wymaga dziś `room in FIRST_ROOMS` dla wszystkich pięciu i trzeba go zmienić.
3. **18:00:** `away_first_day()` dla przydziału `evening` przestaje obowiązywać od `hour >= 18`. Od tej chwili rozkład obozu (kolacja 18–20, potem wieczór) bierze go sam. Zmiana miejsca idzie przez `_camp_will_change()` / mrugnięcie (NPC-16), więc nowego kodu w reżyserze nie trzeba. Sprawdzić w teście.
4. **Ognisko w dniu 1:** wróconego `in_camp_today()` uzna za obecnego, więc w dniu 1 mogą zagrać jego kwestie z `~ gawedy` (Wszebor, Nasir, Sobek). To pożądane. Zdanie z `:14` musi jednak mówić o „dwóch”, a nie o „połowie ekipy”, i nie może przeczyć temu, że jeden siedzi przy ogniu.
5. **Noc 1 i balans:** osoba z przydziałem `day2` nie traci −2 w nocy 1, więc zaczyna dzień 2 o 2 punkty wyżej. To zgodne z NPC-18, a z liczbami w `07_balans.md` nic się nie kłóci. `tools/tests/test_night1.gd:26` zakłada, że Wszebor traci 2. Przy losowaniu może wypaść jako `day2`, więc test musi ustalić przydziały.
6. **Lore:** propozycja powitania „był niżej w kopalni” może kłócić się z tym, że dalsze poziomy są dopiero do odkrycia (upadowa za połamanymi stemplami „bez liny nie ma tu czego szukać”, `gen_camp.gd:575`). Roland napisał „robili już coś w kopalni”, czyli niekoniecznie niżej. Rekomendacja [ROBOCZE]: „na dalszym przodku” albo „w chodniku pod szybem”. Wszystkie nowe zdania (wstęp, ognisko, pięć powitań) przejdą przez `lore-checker`.
7. **WYP-17, dalsza połowa:** w lokacjach nie ma tabeli rozmiarów pomieszczeń. Test zmierzy długość pomieszczenia promieniem z `Entry` wzdłuż jego kierunku do ściany (warstwa 1, bez NPC i gracza), a spot musi mieć rzut na tę oś ≥ max(7 m, L/2) [ROBOCZE]. W Ślepym szybie (ok. 8,8 m do ściany) cztery spoty muszą się zmieścić w pasie 7–8,3 m, a na stoku Upadowej spoty idą po `_slope_y()`. Do tego dochodzi kontrola podłogi i „nie w ścianie” jak w obecnym kroku dla obozu.
8. **Kolizja z task_31:** task_31 zmienia te same generatory i sceny (`gen_locations.gd`, `gen_camp.gd`, `locations.tscn`, `camp.tscn`), a w Zawalonym chodniku także żyłę `west_1`, za którą mają stanąć ludzie. Obu zadań nie wdrażać równolegle. Kolejność jest dowolna, ale drugie zadanie regeneruje sceny po scaleniu pierwszego i sprawdza, że spoty w Zawalonym chodniku nie wchodzą w nowe bryły rudy.

**Pytania do Rolanda:** brak. Liczby (3 / 1 / 1, losowo, ≥ 7 m) Roland potwierdził na czacie 2026-10-27 (cytaty w wymaganiach 1 i 2), a szczegóły zapisu i teksty reguła sama oznacza jako [ROBOCZE]. Karta decyzji nie jest potrzebna.

## Plan
1. **`script/game_state.gd`:**
   - stałe `FIRST_ROOM_CAPACITY := 1` (komentarz: stare zapisy mogą mieć dwoje), `FIRST_EVENING := &"evening"`, `FIRST_DAY2 := &"day2"`, `FIRST_EVENING_HOUR := 18.0` (liczba także w `07_balans.md`);
   - `roll_first_rooms(rng)`: tasowanie `FIRST_MEET` przez `rng`, pierwsi trzej dostają po jednym pokoju z `FIRST_ROOMS` w kolejności losowej, czwarty `evening`, piąty `day2`;
   - `first_room()` zostaje (zwraca `&""` poza piątką, a dla tamtych dwóch `evening` / `day2`). Nowe `first_day_in_room(id) -> bool`: przydział należy do `FIRST_ROOMS`;
   - `away_first_day(id)`: `day == 1` i (w pokoju, albo `day2`, albo `evening` przed 18:00);
   - `has_arrived(id)`: dodatkowo fałsz dla `day2`, dopóki `day < 2` (noc 1 i świt dnia 1, NPC-18; nic nie jest zapisywane);
   - komentarze przy `FIRST_MEET` i `ARRIVAL_FLAG` (NPC-21).
2. **`script/field_schedule.gd`:** bez zmian w logice (`first_room() != place_id` odrzuca `evening` / `day2`). Poprawić tylko komentarz przy `FIRST_DAY_POSES`. `script/camp_schedule.gd`: tylko komentarz w `:17`.
3. **Teksty [ROBOCZE]:**
   - `dialogue/system.dialogue:106`: tekst z NPC-21 (z poprawką z ryzyka 6);
   - `dialogue/ognisko.dialogue:14`: np. „Przy ogniu jest luźno. Dwóch z ekipy zostało na nocnej szychcie w chodnikach i wróci dopiero rano, a jeden zjedzie szybem dopiero w nocy.”;
   - pięć dialogów `dialogue/{wszebor,nasir,hagiwara,sobek,anzelm}.dialogue`: w pierwszym powitaniu gałąź obozowa `if day == 1` z jednym zdaniem „wróciłem z dalszego przodka”. U Sobka zamiast „przy śniadaniu”. Wszystkie odpowiedzi z tagami jak dotąd (`[#leave]`);
   - `--import` po zmianie `.dialogue`. Gwara nie dotyczy (żadna zmieniona kwestia nie należy do Mirosława ani Bolka).
4. **`tools/data_lint.gd`:** dla każdego z `FIRST_MEET` pierwsze powitanie ma też gałąź `day == 1` poza „teren” (powitanie wieczorne, NPC-15).
5. **WYP-17, generatory:**
   - `tools/generators/gen_locations.gd`: nowe `Spot1..4` w każdym miejscu ≥ 7 m od `<Place>Entry` i w dalszej połowie, z wolną podłogą (Ślepy szyb w pasie 7–8,3 m, Upadowa po `_slope_y`). `Work` zostaje, jeśli przejdzie test;
   - `tools/generators/gen_camp.gd:657–661`: `EastSpot1..4` w jaskini za pochylnią (ok. x 72–76, z 0–5, y `Y_CHAMBER`, z dala od skrzynki z lontami), `WestSpot1..4` za żyłą (x −13,4…−16,4, z 2,1 / 3,9, y `Y_WEST_LOW`, z dala od deski z kluczem i bariery), twarzą do wejścia;
   - regeneracja `scene/levels/locations.tscn` i `scene/levels/camp.tscn` generatorami (nie ręcznie).
6. **Testy:**
   - `tools/unit_test.gd:73–101`: losowanie daje 3 pokoje po jednym oraz po jednym `evening` i `day2`, to samo ziarno daje ten sam wynik, stary zapis z parą zachowuje sloty 1 i 2, `away_first_day` dla `evening` o 17:00 / 18:00, `has_arrived` dla `day2` w dniu 1 i 2. Poprawić `:311` (ustalić przydziały);
   - `tools/tests/test_first_meet.gd`: przydziały ustalone (np. Wszebor `east`, Nasir `rzapie`, Anzelm `west`, Sobek `evening`, Hagiwara `day2`), spoty `*Spot1`, wieczorem w obozie jest tylko Sobek z nowym powitaniem, w dniu 2 cała piątka;
   - `tools/tests/test_schedule.gd:70–105`: najwyżej jedna osoba w pokoju, dokładnie trzech w pokojach; o 20:30 w dniu 1 w obozie jest czterech plus jeden z przydziałem `evening`;
   - `tools/tests/test_night1.gd`: przydziały ustalone, `day2` nie traci w nocy 1;
   - `tools/tests/test_places.gd`: nowy krok, w którym każdy `*Spot*` / `*Work` w `Camp/Markers` i `Locations/Markers` ma ≥ 7 m od swojego `Entry`, rzut ≥ L/2 (promień z wejścia), podłogę i wolne miejsce na człowieka;
   - Testy: serwer po wdrożeniu uruchamia `unit lint dialogue` oraz scenariusze `first_meet`, `schedule`, `night1`, `places`, `expedition`, `day1` (nazwy według mapy w `tools/README.md`). Zrzuty ekranu Starej sztolni, Zawalonego chodnika i Ślepego szybu ze spotami do raportu.
7. **Spec i dokumenty:**
   - w `03_mechaniki/npc.md` wskaźniki „Dla agenta” (NPC-17/NPC-21: `FIRST_EVENING`, `FIRST_DAY2`, `first_day_in_room()`, `has_arrived()` także dla `day2`);
   - w `03_mechaniki/wyprawy.md` przy WYP-17 test `places` i pas spotów w obozie;
   - w `07_balans.md` godzina 18:00 przy wierszu „Pierwszy dzień”;
   - `docs/agent/README.md` (rozkład dnia 1, markery spotów);
   - ⬜→✅ przestawia dopiero `/spec-sync finalize`; arkusz (poziom `rozgrywka`): jedna część `## Część: task_32` arkusza builda (D-27).
8. **Kolejność:** nie wdrażać równolegle z task_31 (ryzyko 8).

Pliki: script/game_state.gd, script/field_schedule.gd, script/camp_schedule.gd, dialogue/system.dialogue, dialogue/ognisko.dialogue, dialogue/wszebor.dialogue, dialogue/nasir.dialogue, dialogue/hagiwara.dialogue, dialogue/sobek.dialogue, dialogue/anzelm.dialogue, tools/data_lint.gd, tools/unit_test.gd, tools/tests/test_first_meet.gd, tools/tests/test_schedule.gd, tools/tests/test_night1.gd, tools/tests/test_places.gd, tools/generators/gen_locations.gd, tools/generators/gen_camp.gd, scene/levels/locations.tscn, scene/levels/camp.tscn, docs/agent/README.md
Ryzyko: wysokie

## Przepływ (D-36)
Poziom `rozgrywka`: przydział pokoi, godziny powitań i pozycje postaci w scenach, które gracz widzi. Arkusz tylko jako jedna część `## Część: task_32` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `wysokie`: przegenerowanie scen `camp` i `locations`, logika `GameState` i zgodność ze starymi zapisami (para w pokoju).

## Podsumowanie
Analiza gotowa i decyzje nie są potrzebne. Część NPC-21 to mała zmiana logiki w `GameState`: nowe losowanie 3 / 1 / 1 z przydziałami `evening` i `day2`, `away_first_day()` z godziną 18:00, `has_arrived()` dla zjeżdżającego nocą. Do tego dochodzą teksty (wstęp, ognisko, wieczorne powitania piątki z rozszerzonym lintem) i aktualizacja czterech testów. Część WYP-17 to przestawienie wszystkich spotów w generatorach (obóz: jaskinia za pochylnią, za żyłą; lokacje ≥ 7 m i dalsza połowa), regeneracja scen i nowy krok w `test_places`. Jedyna przeszkoda kolejności: task_31 zmienia te same generatory i sceny, więc obu zadań nie wdraża się równolegle.
