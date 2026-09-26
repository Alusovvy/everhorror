<!--
Zadanie z czatu (2026-09-26). Wymagania to dosłowny cytat notatki użytkownika (akapit 1 z 3; akapity 2 i 3 to task_11 i task_12).
-->

Wymagania:
Spotykanie NPCów można zrobić na pierwszym piętrze w pomieszczeniach, w sensie pierwszego dnia w obozie tylko Mirosław, Bolko, Tekla i Raciborz. Reszta do spotkania losowo w pomieszczeniach, ale nie więcej niz 2 osoby w jednym.

Priorytet: do ustalenia · Kolejność: po task_09 (oba zmieniają rozkład dnia i powrót do obozu), przed task_11

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza
**Kogo to dotyczy.** Pierwszego dnia w obozie są tylko **Mirosław, Bolko, Tekla i Racibor**. Do spotkania w pomieszczeniach zostaje piątka z task_05: **Wszebor, Nasir, Hagiwara, Sobek i brat Anzelm**. Dobrawa przychodzi w dniu 2, a Sabina dołącza po spotkaniu z Exitium, więc u nich nic się nie zmienia.

**Stan w grze.**
- `CampSchedule` stawia całą dziesiątkę w obozie od dnia 1. Wszebor w dzień rąbie w Starym wyrobisku (głębokość 2), a Nasir po oleju pracuje przy pompach (`FieldSchedule`).
- Każda z postaci ma pierwsze powitanie (`met_<id>`) z wariantami zależnymi od miejsca w obozie. Tylko Wszebor i Nasir mają wariant „w terenie”.
- Znaczniki na postacie w terenie już są: `EastSpot1..4`, `WestSpot1..4`, `RzapieSpot1..4`. Dziś używają ich Drudzy od dnia 3.

**Co jest niejasne:**
- **„Pierwsze piętro”** nie pojawia się w specyfikacji. Najbliżej są miejsca o głębokości 1 na mapie:
  - Stara sztolnia,
  - Rząpie starego szybu,
  - Zawalony chodnik, ale on jest zamknięty do wysadzenia zawału.
- **Pojemność:** pierwszego dnia otwarte są tylko 2 miejsca głębokości 1. Przy „najwyżej 2 w jednym” mieszczą 4 osoby, a spotkać trzeba 5.
- **Co dalej z postacią, której gracz nie spotkał:** czy wieczorem wraca do obozu, czy czeka w tunelu, aż ją znajdzie?

Wszystko to jest w [decision-task-10](../human-tasks/decision-task-10.md).

## Plan (wariant rekomendowany)
1. **Losowanie na starcie nowej gry**:
   - ziarno losowania jest zapisywane w stanie gry, więc zapis i wczytanie nie zmieniają wyniku,
   - każda z 5 postaci dostaje pomieszczenie, najwyżej 2 osoby na pomieszczenie,
   - flaga `first_room_<id>` trzyma to miejsce.
2. **`CampSchedule`**: w dniu 1 niespotkana postać z tej piątki nie ma miejsca w obozie. Od rana dnia 2 obowiązuje zwykły rozkład (decyzja 3).
3. **`FieldSchedule`**: w dniu 1 niespotkana postać stoi w swoim pomieszczeniu na znaczniku `<Place>Spot<n>`, w pozie pracy. Po rozmowie zostaje tam do końca wizyty (nie znika bohaterowi sprzed nosa).
4. **Pierwsze powitania w terenie** dla całej piątki. Pełny przegląd dialogów to task_11, a tu tylko tyle, żeby rozmowa w pomieszczeniu nie mówiła „przy stole”.
5. **Sceny dnia 1** z udziałem tej piątki: ognisko w dniu 1, wstęp i kolacja. Sprawdzę je i poprawię tak, żeby przy ogniu nie siedział ktoś, kogo w obozie nie ma. Pełny przegląd tekstów to task_11.
6. **Testy:**
   - `unit`: losowanie (najwyżej 2 w pomieszczeniu, wszyscy przydzieleni, ten sam wynik z tym samym ziarnem),
   - `schedule`: w dniu 1 obóz ma 4 osoby, a znaczniki w terenie istnieją,
   - nowy scenariusz `first_meet`: dzień 1, wyprawa, rozmowa w pomieszczeniu, rano w dniu 2 wszyscy w obozie,
   - factcheck `factcheck-test-10.md`.
7. **Specyfikacja:**
   - NPC-16 (rozkład dnia) i karty 5 postaci („Pojawia się”),
   - `04_tresc/tydzien.md` (dzień 1),
   - `07_balans.md` (losowanie),
   - wpis w `WDROZENIA.md`, docs_v2.

## Co zostało zrobione
Na razie analiza i plan. Implementacja po decyzjach.

## Decyzje i założenia
- Wymagania to dosłowny cytat z czatu. Moje doprecyzowania są w tym pliku i w pliku decyzji.
- Losowanie odbywa się raz, na starcie gry, a nie codziennie. Dzięki temu „spotkaj ludzi w pomieszczeniach” to zadanie pierwszego dnia, a nie loteria na cały tydzień.

## Czego potrzebuję od Ciebie
- Odpowiedzi w [decision-task-10](../human-tasks/decision-task-10.md) (4 pytania).

## Test
Po implementacji: `docs/human-tasks/factcheck-test-10.md`.

## Podsumowanie
Pierwszego dnia obóz ma tylko czterech mieszkańców, a pozostałą piątkę gracz spotyka w pomieszczeniach kopalni, najwyżej dwie osoby w jednym. Większość elementów już jest: znaczniki w terenie, powitania zależne od miejsca, rozkład dnia z miejscami poza obozem. Przed startem trzeba ustalić, co znaczy „pierwsze piętro”, bo pierwszego dnia otwarte miejsca mieszczą tylko 4 z 5 osób, oraz co dzieje się z kimś, kogo gracz nie spotkał. **Status: czeka na decyzje.**
