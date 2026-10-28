# task_20: Pomiar przed etapami 5–7: tor bohatera w bocie, czas realny dnia, test „złoty tydzień”

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
„Wprowadz propozycje Fable, nastepnie odswiez dokumentacje.” (Roland, czat 2026-10-27)
Propozycje: G4, G5, K5 z analizy projektu (kontekst poniżej).

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)
Poziom: rozgrywka

Kontekst:
Źródło: przegląd projektu `docs/analizy/propozycje-projekt.md` (agent Fable 5.1, tylko odczyt, 2026-10-27). Ten plik zostaje usunięty po przeniesieniu propozycji do planu i zadań, więc cała treść potrzebna wykonawcy jest tutaj. Numery linii pochodzą z 2026-10-27 i mogą się przesunąć; trzeba je sprawdzić w kodzie. Wszystkie trzy pozycje to **narzędzia pomiaru bez zmiany rozgrywki**: nie zmieniają żadnej liczby balansu, kwestii ani sceny, więc nie wymagają reguły ⬜ w specyfikacji (zadanie narzędziowe, jak task_14 w części bota i raportu). Plan pozwala budować narzędzia pomiaru przed bramką PT0 (`docs/analizy/plan.md`, §1 Etapy, akapit pod tabelą po etapie 3). Etap planu: 4 (pomiar przed etapami 5–7). Koszt razem: S–M.

1. **G4. Bot balansu mierzy tor bohatera (poczytalność i zdrowie).**
   - *Problem.* Poczytalność bohatera startuje z 80 (`script/game_state.gd:38`), a pasmo „na krawędzi” zaczyna się poniżej 35 (`game_state.gd:638–645`). Noc kosztuje −3 (`script/story_director.gd:472`), gorączka −3 (`:477`), groza miejsc to łącznie 26 przy odwiedzeniu wszystkich (`07_balans.md:52` w specyfikacji), a ognisko oddaje +3…+6 co wieczór (`dialogue/ognisko.dialogue:38,55,75,92`). Żeby zejść poniżej 35, trzeba celowo zbierać każdą karę. Skutek: szepty (`story_director.gd:602–605`, tylko pasmo „na krawędzi” i tylko w tunelach) oraz winieta (`script/hud.gd:132–135`) to w praktyce martwy kod, więc jedyny element horroru poza tekstem nigdy nie startuje. Zdrowie podobnie: dwa źródła ran (−10 i −15), noc leczy +8, a śmierć wymaga wcześniejszej rany. Plan to wie (§8.1, D3 „najpierw pomiar”), ale bot (`tools/balance_sim.gd`) liczy tylko tempo żył i nie mierzy ani poczytalności, ani zdrowia bohatera (`07_balans.md:170` w specyfikacji, lista „Pominięte”).
   - *Propozycja.* Rozszerzyć bota o tor bohatera: groza odwiedzonych miejsc, noce, powrót po nocy, ognisko, przedmioty z trasy. Bot wypisuje linię w formacie istniejących `BALANCE[…]`, np. „BALANCE[styl, wariant]: poczytalność min. X w dniu D, pasmo …; zdrowie min. Y”. Dopiero z tą liczbą etap 6 stroi start i cenę nocy w `07_balans.md` (to zmiany istniejących liczb, nie nowe liczniki). Bot nadal **mierzy**: nie ma nowego progu, który psułby test (poza niezmiennikami, np. wartości w 0–100).
   - *Koszt:* S–M. *Priorytet analizy:* wysoki. *Etap:* 4, wyniki zasilają etap 6.

2. **G5. Raport przebiegu zapisuje czas realny dnia.**
   - *Problem.* Raport (`script/run_report.gd`, `GameState.time_log`) liczy minuty w grze, nie na zegarze ściennym. Ankieta sesji PT0 mówi „<1h” bez liczby dni; badanie z planu daje demu 15–60 min do punktu kulminacyjnego (`docs/analizy/plan.md`, etap 9 w §1; szczegóły w archiwum, do którego plan odsyła); `tools/release/CZYTAJ_MNIE.txt:43` obiecuje „1–3 godziny” na tydzień, ale to szacunek (`docs/human-tasks/playtest_template.md:8`). Cięcie dema (dni 1–3, D-13) będzie się odbywać bez wiedzy, ile to minut.
   - *Propozycja.* `GameState.record_dawn()` zapisuje `Time.get_ticks_msec()` i czas systemowy w nowym polu wpisu `dawn_log`; raport (Markdown i JSON) dodaje kolumnę „czas realny dnia” i sumę. To dane deweloperskie w pliku raportu, nie zegar w grze, więc zasada „bez zegara czasu rzeczywistego w grze” jej nie dotyczy, a gracz niczego nie widzi. Pole jest opcjonalne: wersja zapisu `SAVE_VERSION` (6) bez zmian, stary zapis i stary raport nadal się wczytują (kolumna pokazuje „brak danych”). Jedna linia w `dawn_log`.
   - *Koszt:* S. *Priorytet analizy:* wysoki. *Etap:* 4.

3. **K5. Test „złoty tydzień” teraz, przed etapami 5–7.**
   - *Problem.* Plan przewiduje test „złoty tydzień” dopiero w etapie 7, krok 1 (`docs/analizy/plan.md`, etap 7 w §1; kroki etapu opisuje archiwum, do którego plan odsyła), jako zabezpieczenie przepisania nocy na dane. Ale etap 5 (światło, dźwięk) i etap 6 (cena nocy, pokusa żył, norma etapami) też dotykają `_resolve_night()` i `_morning_events()`. Dziś `tools/tests/test_week.gd` sprawdza wybrane noce, nie całość, więc każda zmiana może po cichu przestawić losy ludzi.
   - *Propozycja.* Nowy scenariusz `golden_week` (`tools/tests/test_golden_week.gd`, dopisany do `tools/run_tests.sh` i do tabeli w `tools/README.md`): deterministyczne wejście (ziarno losowości, lista akcji dnia w stylu bota), siedem nocy przez `_resolve_night()` na gołym `StoryDirector` (jak `_task14_arrival` w `unit_test.gd`), a wynik (poczytalność, zdrowie, status i flagi każdej postaci po każdej nocy) porównany z plikiem `tools/tests/golden/week.json`. Zmiana zamierzona to świadome odświeżenie pliku złotego w tym samym commicie; różnica niezamierzona kończy test czerwono z listą rozbieżności (postać, noc, pole, było → jest).
   - *Koszt:* S–M. *Priorytet analizy:* wysoki. *Etap:* 4 (przeniesione z 7).

Kryteria akceptacji:
- `tools/run_tests.sh balance` wypisuje dla każdego stylu i wariantu linię z minimalną poczytalnością i dniem jej wystąpienia, pasmem oraz minimalnym zdrowiem; wynik jest powtarzalny między uruchomieniami. Żadna liczba balansu w grze się nie zmienia, a test balansu nadal tylko mierzy tempo.
- Raport przebiegu (`.md` i `.json`) ma kolumnę i sumę czasu realnego; `unit` sprawdza to na świeżym przebiegu oraz na starym zapisie (brak danych, bez błędu). `SAVE_VERSION` bez zmian.
- `tools/run_tests.sh golden_week` przechodzi dwa razy z rzędu na tym samym kodzie; umyślna zmiana jednej liczby nocy (próba robocza, cofnięta) daje czerwony wynik z czytelną listą rozbieżności. Plik `tools/tests/golden/week.json` jest w repozytorium, a sposób jego odświeżenia opisany w `tools/README.md`.
- Pole czasu realnego nie wchodzi do pliku złotego (inaczej test nigdy by nie był stały).
- Krótkie testy przechodzą: `unit lint dialogue balance golden_week`. Pełny zestaw tylko za zgodą Rolanda.
- `tools/README.md` opisuje nowe wyjście bota, kolumnę raportu i scenariusz `golden_week`; `docs/agent/README.md` (sekcja „Run report”) wspomina o czasie realnym.

Poza zakresem:
- Strojenie liczb (start poczytalności, cena nocy, norma): to etap 6, po pomiarze.
- Naprawa połkniętego załamania bohatera w nocy (K3), plansza z wieloma nowinami (G3), nowe podpowiedzi sterowania (G2).
- Powtórzenie sesji PT0 (G1/PT0b) i zmiany w szablonie sesji (osobne zadanie narzędziowe, P3).
- Jakakolwiek zmiana widoczna dla gracza; zegar czasu rzeczywistego w interfejsie gry.
- Zmiana `07_balans.md` w specyfikacji (lista „Pominięte” zaktualizuje się osobnym wpisem po wdrożeniu).

Priorytet: wysoki · Etap planu: 4 · Kolejność: najlepiej przed etapami 5–7; niezależne od task_16–19

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza
<!-- agent, /ai-task analyze 20, przebieg z dashboardu 2026-10-27 -->

**Kolejność.** Karta decyzji [2026-10-27_task20-pomiar.md](../../../specification/zgloszenia/2026-10-27_task20-pomiar.md) jest rozstrzygnięta (Roland, 2026-10-27, dashboard: 1: a, 2: a, 3: a). task_16 jest już scalone (✅ w „W zadaniach”), więc punktem odniesienia „linie tempa bez zmian” jest bieżący `master` gry. Stan z wznowienia (2026-10-27): `spec/2026-10-27-task17` jest już scalona, a D-33 pozwala na trzy otwarte gałęzie `spec/*` naraz, więc `implement 20` może ruszyć od razu. task_17 zmieniło tylko teksty wstępu, toru bohatera ani bota nie dotyka.

**G4: bot dziś.** `tools/balance_sim.gd` gra tydzień na gołym `GameState`: wyprawy (`_travel`, `_return_home`), żyły, bramki, ognisko w stylu „rozmowy” (`_fire` woła tylko `rest_by_fire()`, bez poczytalności). Noc to samo `gs.start_next_day()` (`balance_sim.gd:180`), bez `_resolve_night()`, więc ani noc, ani gorączka, ani leczenie bohatera nie działają. Źródła toru bohatera w grze (numery linii sprawdzone 2026-10-27):
- groza miejsca przy pierwszej wizycie: `story_director.gd:227–228`, `Expeditions.place(id).dread` (dane z `write_world_data.js`; bot może je czytać wprost);
- powrót po nocy −3: `story_director.gd:262–263` (warunek `is_day_over()`; bot wraca najpóźniej o 22:00, więc może go trafiać co dzień);
- noc: −3, wstrząs w nocy 5 −3, gorączka −12 zdrowia (dół 5) i −3, bez gorączki +8 zdrowia: `story_director.gd:460–480`, liczby wpisane wprost;
- gorączka: `mark_today("soaked")` przy wejściu do Zalanego chodnika (`story_director.gd:215–216`), nocą `set_fever(true)`; bot nie ma lekarstwa;
- ognisko +3…+6 zależnie od dnia i obecności Wszebora (`dialogue/ognisko.dialogue:38,44,55,75,92`); dialog da się przejść bez sceny przez DialogueManager, jak robi `tools/dialogue_test.gd`;
- obiekty w miejscach (`interactable.gd:180–194`, tylko pierwsze użycie): siedem z `sanity_change` i dwa z `wound` w `scene/levels/locations.tscn` (generator `gen_locations.gd:913–1223`); rana 10 „Poparzyła cię para” jest na samej żyle `VeinMark_szczelina_2`, więc bot ją weźmie przy zaznaczaniu. Węzły leżą pod węzłem miejsca (`Kostnica/…`, `Grota/…`), więc `PackedScene.get_state()` daje listę na miejsce bez tworzenia sceny;
- kwestie w dialogach (Ottokar, Hieronim, Welf, Nasir, Bolko −2…−8; Wszebor, Sobek, Hagiwara, Mirosław +2…+6; leczenie Sabiny i Anzelma) zostają poza botem, tak jak dziś spotkania z Drugimi; linia założeń to powie.
- `change_player_sanity` przy 0 wysyła `player_broke`; w bocie nikt go nie słucha, wartość zatrzyma się na 0 (to też wynik).

**G5: raport dziś.** `GameState.record_dawn()` (`game_state.gd:278–316`) zapisuje stan przy świcie; `RunReport._time_data()` (`run_report.gd:139–158`) liczy minuty gry z `time_log`, tabela w `_time_table()` (`run_report.gd:442`). Zapis gry przenosi `dawn_log` (`game_state.gd:1005`, wczytanie `:1041–1042`), `SAVE_VERSION` = 6 (`save_manager.gd:27`). Kłopot propozycji: `Time.get_ticks_msec()` zaczyna od zera po każdym uruchomieniu, czas systemowy liczy przerwy poza grą i pauzę; dzień przerwany zapisem i wyjściem nie ma sensownej liczby. Do tego `SaveManager.retry_morning()` przywraca poranek, a z nim stan liczników. Stąd pytanie 1 karty.

**K5: test nocy dziś.** `_resolve_night()` (`story_director.gd:428–495`) nie losuje niczego: wynik zależy tylko od flag, stanów ludzi i dnia, więc „ziarno” z propozycji nie jest potrzebne (losowe są tylko spotkania w miejscach, poza nocą). Goły `StoryDirector` działa w `unit_test.gd:307–359` (`Story.new()`, potem `free()`). `_morning_events()` czeka na `VN.play`, więc w teście bez sceny da się sprawdzić tylko jego czyste części (`_quota_lags()`, `_morning_subtitle()`). Wpis `dawn_log` ma już dokładnie to, co plik złoty ma porównywać (bohater, każda postać: poczytalność, zdrowie, zaufanie, status, gorączka, przybycie; nowe flagi), więc test porównuje wpisy świtu bez pól czasu realnego.

**Ryzyka.**
- Wywołanie całego `_resolve_night()` w bocie zmieniłoby tempo (załamany Mirosław kasuje `west_blasted`, `story_director.gd:526`); stąd pytanie 3 karty.
- Przepisanie liczb nocy do bota rozjedzie się po etapie 6; czytanie ogniska z dialogu chroni przed tym samym przy wariantach ogniska (kolejka „Czeka na wdrożenie”, poz. 4).
- Plik złoty z ułamkami (zmęczenie `float`) porównywać z tolerancją albo zaokrąglać przy zapisie.
- Odświeżanie pliku złotego zapisuje do `res://`; tylko na wyraźny argument, nigdy w zwykłym przebiegu testu.

**Sprawdzenie 2026-10-28** (przebieg z dashboardu `20261028-064316-analyze-20-cc6ac5`, kod `master` gry `7047cdd`). Od pierwszej analizy kod tych systemów zmienił się tylko w scaleniu task_16 i w commicie testów `c5e7fb3`. Numery linii w `story_director.gd` (`:215–216`, `:227–228`, `:262–263`, `:428–495`, `:462`, `:472–480`, `:526`), `game_state.gd` (`:38`, `:278–316`, `:638`, `:1005`, `:1041–1042`), `run_report.gd` (`:121`, `:139–158`, `:442`), `balance_sim.gd` (`:180`, `:237–241`) i `ognisko.dialogue` (`:38,44,55,75,92`) są dalej aktualne. Wyjątek: `SAVE_VERSION` stoi teraz w `save_manager.gd:34`. Lista obiektów w `locations.tscn` też się zgadza: 7 z `sanity_change`, 2 z `wound`. Nowe ustalenia dla wykonawcy:
- **Ognisko nie może dać odpoczynku dwa razy.** `ognisko.dialogue:5` samo woła `rest_by_fire()`, a `_fire()` w bocie (`balance_sim.gd:241`) woła je drugi raz, jeśli dialog dojdzie obok. Wtedy zmęczenie spadnie podwójnie i linia tempa się przesunie. Bot przechodzi więc dialog **zamiast** wołać `gs.rest_by_fire()`. Dialog nie ma odpowiedzi do wyboru (same gałęzie `if` i `=>`), więc wystarczy przejść go do końca. Wszebor jest w obozie od początku (`ARRIVAL_FLAG` go nie wymienia, `game_state.gd:127`), więc bot trafi na te same gałęzie co gracz.
- **Wstrząs w noc 5 leży poza blokiem bohatera.** Bohater traci wtedy −3 w `:462`, wewnątrz bloku wstrząsu (razem z ludźmi), a nie w `:471–480`. Wydzielona funkcja bohatera musi objąć też tę stratę, inaczej bot nie policzy −3 w noc 5. Między `:462` a `:472` nic nie czyta poczytalności bohatera, więc przeniesienie tej straty do nowej funkcji (`if night == 5`) nie zmienia wyniku. `golden_week` (tydzień z nocą 5) ma to potwierdzić bez odświeżania pliku.
- **Rana na żyle: szukać po fladze, nie po nazwie węzła.** task_31 przebuduje żyły na bryły rudy w generatorach, a węzeł `VeinMark_szczelina_2` może przy tym zmienić nazwę. Bot szuka w `locations.tscn` obiektów z `on_use_flag == "vein_<id>"` i z `wound` albo `sanity_change`.
- **Licznik czasu grania a testy bez świata.** Test G-E4 (`unit_test.gd:672–702`) wczytuje wzorce zapisów v3–v6 i sprawdza, że „wczytaj → zapisz → wczytaj → zapisz” nic nie zmienia (`:702`), a do tego `SAVE_VERSION == 6` (`:675`). Licznik rośnie tylko wtedy, gdy w drzewie jest świat (`StoryDirector`) i gra nie jest zapauzowana. W `unit`, `balance` i `golden_week` świata nie ma, więc licznik stoi i wynik jest powtarzalny. Wzorce zapisów bez tego pola dostają przy wczytaniu wartość „brak danych”. Wzorców nie trzeba zmieniać.
- **Plik złoty bez tekstów poranka.** `_morning_subtitle()` to tekst. task_26 (pula porannych zdań, C4) i task_27 (plansza poranka) i tak go zmienią, więc w pliku złotym wymuszałby odświeżanie przy każdej zmianie tekstu. Wymaganie K5 wymienia tylko poczytalność, zdrowie, status i flagi. Plik złoty bierze więc wpisy świtu (bez pól czasu), `_quota_lags()` i wiadomość nocy zwracaną przez `_resolve_night()`. `_morning_subtitle()` w nim nie ma.
- **Wspólne pliki z innymi zadaniami.** task_22 (wdrażane teraz, przebieg `20261028-063839-implement-22-2f950c`) ma w `Pliki:` także `script/game_state.gd`, `tools/unit_test.gd`, `tools/README.md` i `docs/agent/README.md`. Najbezpieczniej wdrażać task_20 po scaleniu `spec/2026-10-28-task22`; dashboard i tak wykryje wspólne pliki po wierszu `Pliki:`. `story_director.gd`, `game_state.gd` albo `run_report.gd` zmieniają też task_26, task_27, task_28 i task_35. task_20 powinno wejść przed nimi, bo `golden_week` ma pilnować właśnie ich. Zadanie, które po scaleniu task_20 umyślnie zmieni wynik nocy, musi dopisać `tools/tests/golden/week.json` do swojego wiersza `Pliki:` i odświeżyć plik w tym samym commicie. To uwaga dla ich analiz; tego pliku nie zmieniam. task_35 zmienia `_sleep()`, a nie `_resolve_night()`, więc `golden_week` zostanie po nim zielony. Jeśli task_28 podniesie `SAVE_VERSION` wcześniej, „bez zmian” znaczy tu, że task_20 wersji nie rusza.

## Plan
<!-- Warianty „1a/2a/3a” wybrał Roland w karcie 2026-10-27_task20-pomiar.md (2026-10-27, dashboard). Gałąź i drzewo robocze zakłada dashboard: `spec/<data>-task20` w `../everhorror-wt/<gałąź>`. -->

1. **K5 najpierw** (żeby osłonić krok 3): `tools/tests/test_golden_week.gd`, `extends SceneTree` jak `unit_test.gd` (bez świata, krótki). Kilka ustalonych tygodni jako tablica „dzień → flagi i zdarzenia dnia” (spokojny; „wszystko źle”: zawał bez pocieszenia, `tekla_reported`, przemoczenie w dniu 3, Dobrawa odchodzi, Nasir wywieziony, `drudzy_met` i `sabina_joined`, notatki `szyfr` i `klucz`). Siedem nocy: `log_time(…, "Sen")`, `_resolve_night()`, `start_next_day()`; wynik: wpisy `dawn_log` (bez pól czasu), `_quota_lags()` i wiadomość nocy; tekstu poranka `_morning_subtitle()` w pliku złotym nie ma (zob. „Sprawdzenie 2026-10-28”). Porównanie z `tools/tests/golden/week.json`, lista rozbieżności „tydzień, postać, noc, pole: było → jest”. Odświeżenie: `godot --headless --path . --script res://tools/tests/test_golden_week.gd -- --update-golden`. Dopisać `golden_week` do mapy w `tools/run_tests.sh` (nazwa pasuje do `test_<name>.gd`, więc wystarczy lista domyślna) i do tabeli w `tools/README.md`. Próba robocza: zmiana −3 na −4 w nocy, czerwony wynik, cofnięcie (opis w raporcie).
2. **G5** (wariant 1a): w `GameState` licznik czasu grania (rośnie w `_process` tylko przy działającym, niezapauzowanym świecie), w `record_dawn()` pole wpisu, np. `"played_ms"`; zapis i wczytanie jako pole opcjonalne (brak → brak danych), `SAVE_VERSION` bez zmian; powtórka poranka nie cofa licznika. Bez świata w drzewie (testy `unit`, `balance`, `golden_week`) licznik stoi, więc test wzorców zapisów G-E4 (`unit_test.gd:672–702`) przechodzi bez zmian wzorców. `run_report.gd`: w `_day_data()` czas dnia = różnica sąsiednich świtów (ostatni dzień: do chwili raportu), kolumna „czas realny” w `_time_table()` i suma; JSON: pole dnia i suma, `null` przy braku danych; Markdown: „brak danych”. `unit`: świeży przebieg (dwa świty, kolumna i suma), stary zapis bez pola (brak danych, bez błędu). `golden_week` pomija to pole.
3. **G4** (warianty 2a, 3a): wydzielić część bohatera z `_resolve_night()` do jednej funkcji wołanej z tego samego miejsca (ta sama kolejność). Funkcja obejmuje też −3 bohatera za wstrząs w noc 5 (dziś `:462`, w bloku wstrząsu). `golden_week` musi przejść bez odświeżania. Bot: groza z `Expeditions.place().dread` przy pierwszej wizycie, powrót po nocy (warunek jak w grze), noc przez nową funkcję. Ognisko idzie przez `ognisko.dialogue` w DialogueManagerze **zamiast** `gs.rest_by_fire()`, bo dialog sam je woła (`:5`). Rany i poczytalność obiektów bot czyta z `locations.tscn`, szukając po `on_use_flag`, nie po nazwie węzła. Żyła `vein_szczelina_2` liczy się zawsze, pozostałe obiekty tylko w liczbie „z oględzinami”, z `required_flag`. Śledzić min. poczytalności i dzień, pasmo (`mind_band_of`), min. zdrowia, dzień gorączki. Nowa linia `BALANCE[styl, wariant] bohater: poczytalność min. X w dniu D (pasmo); z oględzinami min. X2 (pasmo); zdrowie min. Y; gorączka od dnia G|bez gorączki`; dzisiejsza linia tempa bez zmian. Niezmienniki: wartości 0–100, ten sam wynik dwa razy, linia tempa identyczna z liczoną bez toru bohatera. Linia założeń wymienia, co nadal pominięte (kwestie dialogów, Drudzy, Hrapek). `run_tests.sh` już przepuszcza linie `^BALANCE`.
4. **Dokumentacja:** `tools/README.md` (nowa linia bota, kolumna raportu, `golden_week` i odświeżanie pliku złotego), `docs/agent/README.md` sekcja „Run report” (czas realny). `07_balans.md` („Pominięte”) poza zakresem: osobny wpis po wdrożeniu.
5. **Testy:** serwer po wdrożeniu uruchamia `unit lint dialogue` i scenariusze `balance golden_week`; w trakcie pracy agent uruchamia tylko to, czego potrzebuje (bez `.dialogue` i bez nowych `class_name`, chyba że wykonawca doda klasę: wtedy `--import`). Przegląd to osobny przebieg łańcucha. Arkusz (poziom `rozgrywka`, D-36 pkt 4): jedna część `## Część: task_20` arkusza builda, w niej: przeczytać linie bota, otworzyć raport z sesji z wyjściem w środku dnia.
6. **Gałąź i dziennik:** zadanie narzędziowe (rodzaj), więc w „Na gałęziach” `—` zamiast sha specyfikacji i `task_20` jako ID, bez wiersza „W zadaniach”.
7. **Kolejność wdrożenia** (2026-10-28): po scaleniu task_22 (wspólne pliki), przed task_26, task_27, task_28 i task_35 (`golden_week` ma je osłaniać).

Plan zależy od wyboru: nie

Pliki: tools/tests/test_golden_week.gd, tools/tests/golden/week.json, tools/run_tests.sh, tools/balance_sim.gd, tools/unit_test.gd, tools/README.md, script/game_state.gd, script/story_director.gd, script/run_report.gd, docs/agent/README.md
Ryzyko: wysokie

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->

- **Decyzje Rolanda** (karta [2026-10-27_task20-pomiar.md](../../../specification/zgloszenia/2026-10-27_task20-pomiar.md), 2026-10-27, dashboard: 1: a, 2: a, 3: a):
  1. „Czas realny dnia” to **czas grania**: licznik w `GameState` rośnie tylko przy działającym, niezapauzowanym świecie, zapisuje się w zapisie gry jako pole opcjonalne (`SAVE_VERSION` bez zmian); powtórka poranka po śmierci dolicza czas nieudanej próby do dnia. To odchodzi od propozycji G5 (`ticks` i czas systemowy przy świcie) z powodu opisanego w Analizie.
  2. Linia bota podaje **dwie liczby poczytalności**: drogę bota (żyły i to, co je spotyka, w tym rana na żyle `szczelina_2`) oraz najgorszy przypadek z oględzinami wszystkich obiektów dostępnych w odwiedzonych miejscach.
  3. Część bohatera z `_resolve_night()` zostaje **wydzielona do osobnej funkcji** (ten sam kod, ta sama kolejność), wołanej przez grę i bota; najpierw powstaje `golden_week`, który potwierdza brak zmiany zachowania.
- **Przepływ (D-36).** Poziom `rozgrywka`: mimo rodzaju „narzędzia” zadanie zmienia skrypty gry (`game_state.gd`, `story_director.gd`, `run_report.gd`) i dodaje opcjonalne pole zapisu, a poziom `narzędzia` nie obejmuje kodu gry; rodzaj „narzędzia” znaczy tu tylko brak reguły ⬜ w specyfikacji. Gra ma się zachowywać tak samo, co pilnuje `golden_week` i część arkusza builda. Ryzyko `wysokie`: dotyka formatu zapisu (pole opcjonalne), wydziela część `_resolve_night()` i kilka systemów, a błąd zablokowałby pomiar przed etapami 5–7.
- **Przyjęte przez agenta** (zapisane w karcie, do weta w przeglądzie): nowa linia `BALANCE[styl, wariant] bohater: …` obok dzisiejszej linii tempa, która się nie zmienia; ognisko przez prawdziwy `ognisko.dialogue`; bot nie ma lekarstwa, więc gorączka trwa do końca tygodnia, a linia podaje dzień jej początku; plik złoty to wpisy `dawn_log` po każdej nocy w kilku ustalonych tygodniach, bez pól czasu realnego; noc nie losuje, więc test nie potrzebuje ziarna.

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->

Pytania z karty [2026-10-27_task20-pomiar.md](../../../specification/zgloszenia/2026-10-27_task20-pomiar.md) są rozstrzygnięte (1: a, 2: a, 3: a). Nowej karty nie ma: ustalenia ze sprawdzenia 2026-10-28 to szczegóły wykonania w ramach tych wyborów. Jedna prośba co do kolejności: `implement 20` uruchom po scaleniu task_22 (wspólne `game_state.gd`, `unit_test.gd` i oba README), a przed task_26, task_27, task_28 i task_35.

## Test
Scenariusze zadania (uruchamia je serwer po wdrożeniu, poza zestawem podstawowym): `balance`, `golden_week`. Arkusz: część `## Część: task_20` arkusza builda.

## Podsumowanie

Analiza gotowa, wdrożenia jeszcze nie ma. Bot balansu nie przechodzi dziś przez noc (`start_next_day()` bez `_resolve_night()`), więc tor bohatera trzeba dobudować z kodu gry. Noc nie losuje niczego, więc test złotego tygodnia porówna wpisy `dawn_log` bez pól czasu realnego. Czas realny ze znaczników `ticks` gubi dzień przerwany wyjściem z gry. Roland rozstrzygnął kartę decyzji (1: a, 2: a, 3: a): czas grania zamiast zegara ściennego, dwie liczby poczytalności w linii bota, wspólna funkcja nocy bohatera dla gry i bota. Plan jest zgodny z tymi wyborami. Sprawdzenie 2026-10-28 potwierdziło numery linii na `master` `7047cdd` i dodało cztery pułapki dla wykonawcy: ognisko bez podwójnego `rest_by_fire()`, −3 za wstrząs w noc 5 w funkcji bohatera, ranę na żyle szukaną po fladze i licznik czasu grania, który w testach bez świata stoi. Z pliku złotego wypadł tekst poranka. Wdrożenie najlepiej po scaleniu task_22 (wspólne pliki), a przed task_26, task_27, task_28 i task_35.
