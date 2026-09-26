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

**Czego wymaganie nie mówi:** co podnosi zmęczenie, co je obniża, czy coś dzieje się poniżej 100%, co dokładnie się podwaja, jak liczyć „czas dojścia” i jak gracz widzi zmęczenie. Wszystko to jest w [decision-task-12](../human-tasks/decision-task-12.md).

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
Na razie analiza i plan. Implementacja po task_09 i decyzjach.

## Decyzje i założenia
- Powrót za 50% traktuję jako zmianę samodzielną: obowiązuje zawsze, niezależnie od zmęczenia (tak brzmi wymaganie).
- Zmęczenie nie zmienia zdrowia ani poczytalności, chyba że zdecydujesz inaczej (decyzja 6).

## Czego potrzebuję od Ciebie
- Odpowiedzi w [decision-task-12](../human-tasks/decision-task-12.md) (6 pytań).

## Test
Po implementacji: `docs/human-tasks/factcheck-test-12.md`.

## Podsumowanie
Zadanie wprowadza zmęczenie, które przy 100% podwaja czas drogi, oraz nową, stałą zasadę: powrót do obozu kosztuje połowę czasu dojścia. Druga część to spora ulga dla gracza, a pierwsza to nowa presja pod koniec dnia albo tygodnia. Przed startem trzeba ustalić, co męczy, co pozwala odpocząć i jak gracz to widzi. **Status: czeka na decyzje i na task_09.**
