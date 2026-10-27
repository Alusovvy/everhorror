<!--
Zadanie z czatu (2026-09-26). Wymagania to dosłowny cytat notatki użytkownika (akapit 3 z 3).
-->

Wymagania:
Dodanie zmęczenia, które narasta i jeżeli wejdzie nam na 100%, to koszt podróży do lokacji w czasie jest podwojony (poza powrotem do obozu, który zawsze powinien wynosić 50% tego ile zajelo dostanie sie czasu do obecnej lokacji)

Priorytet: do ustalenia · Kolejność: po task_09 (task_09 przelicza czas na minuty, dodaje dziennik czasu i spotkanie z Hrapkiem przy powrocie, a to zadanie zmienia koszt powrotu)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza
**Wymaganie to dwie zmiany:**
1. **Zmęczenie bohatera:** nowy wskaźnik 0–100%, który rośnie. Przy 100% podróż do miejsc kosztuje 2× więcej czasu.
2. **Nowa zasada powrotu, niezależna od zmęczenia:** powrót do obozu kosztuje zawsze 50% czasu, jaki zajęło dojście do obecnego miejsca. Dziś kosztuje tyle, co najkrótsza droga z tego miejsca do obozu, zwykle tyle samo co dojście.

**Stan w grze.**
- Bohater ma zdrowie, poczytalność i gorączkę, pokazywane słowami (w plecaku [I] i w linijce pod zegarem), bez liczb (NPC-13).
- Koszt drogi liczy `Expeditions.walk_hours()`: odcinki mapy, +1 h za odcinek, kiedy bohater jest ranny, +1 h rozpoznania przy pierwszej wizycie.
- `GameState.expedition` trzyma odwiedzone miejsca, zdarzenia i znalezione rzeczy, ale nie trzyma czasu dojścia. To trzeba dodać.

**Czego wymaganie nie mówi:** co podnosi zmęczenie, co je obniża, czy coś dzieje się poniżej 100%, co dokładnie się podwaja, jak liczyć „czas dojścia” i jak gracz widzi zmęczenie. Wszystko to jest w [decision-task-12](../../human-tasks/done/decision-task-12.md).

**Uwaga o balansie:**
- Powrót za 50% dojścia to duża ulga, bo wyprawa staje się tańsza o ok. 25%.
- Zmęczenie działa w drugą stronę.
- Wynik netto sprawdzę na scenariuszu tygodnia: ile żył da się zaznaczyć w typowym przejściu, dziś i po zmianie. Liczby zapiszę w `07_balans.md`.

## Plan (wariant rekomendowany)
1. **`GameState.player_fatigue`** (0–100), w zapisie gry. `SAVE_VERSION`: kolejny numer po task_09, a starsze zapisy wczytują się ze zmęczeniem 0.
2. **Wzrost i spadek** według decyzji 1–2. Każda zmiana czasu przechodzi przez `advance_time`, więc zmęczenie liczy się w jednym miejscu, z powodu i miejsca pobytu (obóz czy tunel).
3. **Koszt drogi** (`Expeditions`):
   - przy 100% odcinki mapy ×2 (decyzja 4),
   - mapa pokazuje to przy koszcie („4 h · zmęczenie ×2”),
   - `trip_hours` i `route_lock` liczą koszt tak samo jak podróż, więc godzina przybycia na mapie jest zgodna z tym, co się stanie.
4. **Powrót:**
   - `expedition["outbound_hours"]` sumuje czas faktycznie przebytych odcinków od wyjścia z obozu,
   - powrót kosztuje 50% tej sumy, zaokrąglone w górę do 5 minut, i nigdy nie jest podwajany,
   - zapis wyprawy sprzed zmiany: 50% najkrótszej drogi,
   - dziennik czasu (task_09) pokazuje „Powrót do obozu (połowa drogi)”.
5. **Widoczność** według decyzji 5:
   - słowo w plecaku [I] i w linijce stanu na HUD, kiedy zmęczenie jest wysokie („zmęczony”, „padasz z nóg”),
   - wpis przy zegarze w notesie.
6. **Testy:**
   - `unit`: przyrost i spadek, ×2 przy 100%, powrót = 50% sumy dojścia (także przy trasie z zawracaniem i z odcinkiem pokonanym po przekroczeniu 100%), zaokrąglenie,
   - scenariusz `expedition`: nowe oczekiwania co do godzin,
   - `week`: tydzień nadal jest do przejścia z normą,
   - factcheck `factcheck-test-12.md`.
7. **Specyfikacja:**
   - nowe reguły ZDR (zmęczenie) i WYP (koszt drogi, powrót),
   - CZAS-2 (tabela kosztów),
   - `07_balans.md`, `05_interfejs.md`,
   - wpis w `WDROZENIA.md`, docs_v2.

## Co zostało zrobione
### Zmęczenie
- **`GameState.player_fatigue`** (0–100%) jest w zapisie gry, wersja zapisu 5. Starsze zapisy zaczynają wypoczęte.
- **Wzrost** idzie przez każde przesunięcie zegara (`advance_time` i minuty rozmów):
  - +8% za godzinę w tunelach, także w drodze (flaga `travelling` na czas marszu, bo przy wyjściu z obozu miejsce nie jest jeszcze ustawione, a przy powrocie już jest skasowane),
  - +2% za godzinę w obozie.
- **Spadek:**
  - sen −60% (w `start_next_day`, więc zmęczenie po ciężkich dniach narasta),
  - wieczór przy ognisku −15% (`rest_by_fire()` na początku sceny ogniska).
- **Przy 100%** każdy odcinek drogi w głąb liczy się ×2 (`Expeditions.walk_hours`). Dodatek za ranę dochodzi po podwojeniu, a rozpoznanie osobno (decyzja 4a).
- **Widoczność, tylko słowami (decyzja 5a):**
  - w rogu ekranu od 75% „zmęczony”, od 90% „ledwo idziesz”, przy 100% „padasz z nóg”,
  - w plecaku [I] zdanie o zmęczeniu,
  - na mapie „· zmęczenie ×2” przy miejscach i „padasz z nóg: każdy odcinek idziesz dwa razy dłużej” w opisie trasy.
- Zmęczenie nie rusza zdrowia ani poczytalności (decyzja 6a).

### Powrót za połowę drogi
- **Suma dojścia:** wyprawa sumuje czas faktycznie przebytych odcinków (`expedition.outbound_hours`, także podwojonych i z ranami, bez rozpoznania).
- **Koszt powrotu:** `Expeditions.return_hours()` to połowa tej sumy, zaokrąglona w górę do 5 minut i nigdy nie podwajana. Tak liczą mapa, reżyser i spotkanie z Hrapkiem.
- **Mapa** przy „Obóz” pokazuje np. „1 h 30 min” i wyjaśnia „znaną drogą idzie się szybciej: połowa tego, co przeszedłeś od obozu”.
- **Zapis wyprawy sprzed task_12:** połowa najkrótszej drogi z bieżącego miejsca.

### Balans (szacunek z liczb [ROBOCZE], zapisany w `07_balans.md`)
- **Przyrost w ciągu dnia:** intensywny dzień (ok. 10 h w tunelach, 6 h w obozie) dodaje ok. 90% zmęczenia.
- **Poranek:** przy codziennym ognisku i śnie ustala się na ok. 25%, bez ogniska na ok. 40%.
- **Kiedy pojawia się 100%:** zwykle pod koniec drugiej długiej wyprawy tego samego dnia (po ok. 9 h w tunelach).
- **Netto:** powrót za połowę skraca typową wyprawę o ok. 25%, więc dzień jest luźniejszy niż wcześniej. **To idzie w przeciwną stronę niż wniosek z analizy rozgrywki** („norma za łatwa”). Do liczb wracamy po Twoim factchecku, z dziennikiem czasu w ręku.

### Specyfikacja i dokumentacja (bez commita)
- **Specyfikacja:**
  - nowa reguła **ZDR-12** (zmęczenie),
  - WYP-5 i WYP-8 (powrót, ×2),
  - CZAS-2, `07_balans.md` (liczby i szacunek),
  - wpis w `WDROZENIA.md`.
- **docs_v2:** `systemy/zdrowie_i_poczytalnosc.md`, `systemy/eksploracja_kopalni.md`.
- **CLAUDE.md**.

## Decyzje i założenia
- Powrót za 50% traktuję jako zmianę samodzielną: obowiązuje zawsze, niezależnie od zmęczenia (tak brzmi wymaganie).
- Zmęczenie nie zmienia zdrowia ani poczytalności, chyba że zdecydujesz inaczej (decyzja 6).
- **Decyzje (2026-09-26, [decision-task-12](../../human-tasks/done/decision-task-12.md)), wszystkie zgodnie z rekomendacją:**
  1. a) tunel +8%/h, obóz +2%/h,
  2. a) sen −60%, wieczór przy ognisku −15%,
  3. a) poniżej 100% tylko ostrzeżenia słowami (75%, 90%),
  4. a) podwaja się sam marsz; rozpoznanie i dodatek za ranę doliczane po podwojeniu,
  5. a) zmęczenie widać słowami (plecak, HUD od 75%, mapa „· zmęczenie ×2”),
  6. a) zmęczenie działa tylko na czas drogi.
- **Powrót:** do mojego opisu (50% faktycznie przebytej drogi od wyjścia z obozu, bez rozpoznania i czasu na miejscu, w górę do 5 minut, nigdy ×2) nie było uwag, więc wdrażam go w tej wersji.

## Czego potrzebuję od Ciebie
- **Przejścia [factcheck-test-12](../../human-tasks/done/factcheck-test-12.md)** w większym teście razem z 10 i 11, szczególnie punktu 12 (balans): czy powrót za połowę nie ułatwia za bardzo i czy zmęczenie jest odczuwalne.
- **Decyzji na później:** jeśli tydzień okaże się za łatwy, zmęczenie jest najprostszym pokrętłem. Mogę na przykład ustawić mniejszy spadek we śnie (−40%) albo wyższy przyrost w tunelach (+10%/h).

## Test
- **Pełny zestaw (za Twoją zgodą, 2026-09-26): 18/18 zaliczonych** (unit, lint, dialogue, schedule, places, camp_walk, hrapek, first_meet, day1, save_load, rzapie, night1, day2, kaplica, day3, expedition, drudzy, week).
- **Pierwszy przebieg:** 15/18. Trzy porażki to nieaktualne oczekiwania w testach, nie błędy gry:
  - `day1`: zła nazwa pożegnania Bolka (moja pomyłka z task_10) i godziny przeliczone w task_09, ale nigdy nieuruchomione (po „+1 h” było 7:15, czyli nadal rano),
  - `day2`: Dobrawa sprawdzana o 15:25, gdy od 12 do 16 jest w tunelach,
  - `expedition`: Wszebor w dniu 1 jest od task_10 na szychcie, więc scenariusz przeszedł na dzień 2.
- **Po task_12** godziny powrotu w `day1`, `day2`, `kaplica` i `expedition` są przeliczone na połowę drogi. `kaplica` startuje godzinę później, żeby dalej sprawdzać powrót po 22:00.
- **Nowe sprawdzenia:**
  - `unit`: 20 sprawdzeń zmęczenia i powrotu (przyrost w tunelu, w obozie i w drodze, ognisko, sen, pasma, ×2 z raną po podwojeniu, połowa drogi z zaokrągleniem, bez ×2, stary zapis, zapis i odczyt) oraz darmowa powtórzona opcja (3),
  - `day1`: po dniu z wyprawą zmęczenie jest wyraźne (> 25%), ale jeszcze bez słowa w rogu,
  - `kaplica`: powrót 1 h 30 min.
- **Ręczne:** [factcheck-test-12](../../human-tasks/done/factcheck-test-12.md) (12 punktów, ok. 30 min).

## Podsumowanie
- **Zmęczenie:** 8% za godzinę w tunelach i 2% w obozie; sen zdejmuje 60%, a ognisko 15%. Widać je tylko słowami: od 75% w rogu ekranu i w plecaku. Przy 100% każda droga w głąb trwa dwa razy dłużej, a mapa to pokazuje.
- **Powrót do obozu:** zawsze połowa drogi faktycznie przebytej od wyjścia z obozu, w górę do 5 minut, nigdy ×2.
- **Testy:** pełny zestaw przechodzi (18/18).
- **Balans:** z moich szacunków wynika, że tydzień zrobił się luźniejszy, bo powrót oszczędza więcej, niż zmęczenie zabiera. To odwrotnie niż wniosek z analizy rozgrywki (norma za łatwa), więc warto to sprawdzić w Twoim większym teście.
