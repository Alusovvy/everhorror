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

Wszystko to jest w [decision-task-10](../../human-tasks/done/decision-task-10.md).

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
Decyzje (2026-09-26, [decision-task-10](../../human-tasks/done/decision-task-10.md)):
- 1A: pomieszczenia to miejsca głębokości 1 (Stara sztolnia, Rząpie, Zawalony chodnik),
- 2a: zawał też jest losowany, a kto tam trafi, czeka na wybuch,
- 3a: od rana w dniu 2 wszyscy są w obozie,
- 4a: czysto losowo (nie wybrałeś rekomendowanego „losowo z sensem”).

### Rozstawienie w dniu 1
- **Losowanie** (`GameState.roll_first_rooms()`):
  - przy każdej nowej grze każda z piątki (Wszebor, Nasir, Hagiwara, Sobek, Anzelm) dostaje pomieszczenie, najwyżej 2 osoby w jednym,
  - wynik trzymają flagi `first_room_<id>`, więc zapis i wczytanie go nie zmieniają,
  - zapis sprzed tej zmiany dostaje pomieszczenia przy pierwszym pytaniu.
- **Obóz** (`CampSchedule`): w dniu 1 piątki nie ma przez cały dzień, także wieczorem. Od rana w dniu 2 obowiązuje zwykły rozkład.
- **Teren** (`FieldSchedule`):
  - w dniu 1 każdy z piątki stoi w swoim pomieszczeniu na znaczniku `<Miejsce>Spot1`/`Spot2` (te same, których od dnia 3 używają Drudzy),
  - pozy: Wszebor, Nasir i Anzelm klęczą przy robocie, Hagiwara i Sobek stoją,
  - po rozmowie zostają na miejscu do końca dnia.
- Wszystko stoi w `GameState`: `FIRST_MEET`, `FIRST_ROOMS`, `FIRST_ROOM_CAPACITY`, `first_room()`, `first_room_slot()`, `away_first_day()` i `in_camp_today()` dla scen.

### Teksty dnia 1 [ROBOCZE]
- **Wstęp:** „W obozie zostali tylko zarządca, kwatermistrzyni i dwaj górnicy. Reszta ekipy od świtu kopie w chodnikach najbliżej obozu i wróci dopiero jutro. Chcesz ich poznać, to ich poszukaj.”
- **Powitania na szychcie** dla całej piątki (wariant „teren” w dniu 1):
  - opis pasuje do chodnika,
  - każdy mówi jednym zdaniem, co robi na szychcie i że wraca jutro,
  - Sobek nie mówi już „widziałem cię przy śniadaniu”,
  - za zawałem narracja wyjaśnia, jak tam weszli: szparą pod stropem, przez którą przeciśnie się człowiek bez plecaka.

  Dawne powitania Wszebora w wyrobisku i Nasira przy pompach (od dnia 2) zostały bez zmian. Zdania zależne od konkretnego pomieszczenia to task_11.
- **Ognisko:** wszystkie sprawdzenia „czy ta osoba jest w obozie” idą przez `in_camp_today()`, więc w dniu 1 przy ogniu nie śpiewa Wszebor, którego nie ma. W dniu 1 dochodzi linijka „Przy ogniu jest luźno. Połowa ekipy została na nocnej szychcie w chodnikach i wróci dopiero rano.”.
- Kwestie Bolka, Mirosława, Tekli i Racibora nie wspominają piątki w dniu 1 (poza „Co myślisz o Wszeborze?”, które było już zależne od poznania).

### Specyfikacja i dokumentacja (bez commita)
- **Specyfikacja:**
  - nowa reguła **NPC-17** (pierwszy dzień) i „Dla agenta”,
  - `04_tresc/tydzien.md` (dzień 1: wstęp i cztery osoby w obozie),
  - karty 5 postaci („Pojawia się”),
  - `07_balans.md` (pomieszczenia, pojemność, losowanie),
  - wpis w `WDROZENIA.md` → „Zmiany agenta poza specyfikacją”.
- **docs_v2:** `systemy/npc.md` (rozkład dnia 1) i karty 5 postaci.
- **CLAUDE.md:** reguła dnia 1 i nowy test.

## Decyzje i założenia
- Wymagania to dosłowny cytat z czatu. Moje doprecyzowania są w tym pliku i w pliku decyzji.
- Losowanie odbywa się raz, na starcie gry, a nie codziennie. Dzięki temu „spotkaj ludzi w pomieszczeniach” to zadanie pierwszego dnia, a nie loteria na cały tydzień.
- **Cały dzień 1, nie tylko „za dnia”:** piątka jest na szychcie od rana do nocy („nocna szychta”), zgodnie z „pierwszego dnia w obozie tylko…”.
- **Po poznaniu w dniu 1 nikt nie wraca do obozu tego samego dnia.** Wraca rano w dniu 2, jak wszyscy.
- **Szpara pod stropem:** moje wyjaśnienie, jak ktoś jest za zawałem, zanim Mirosław go wysadzi [ROBOCZE].
- **Pozy** dobrałem do roli (klęczą ci, którzy coś robią przy skale). Wszyscy stoją twarzą do wejścia, bo tak są obrócone znaczniki.

## Czego potrzebuję od Ciebie
- **Przejrzenia tekstów [ROBOCZE]** przez Ren: wstęp, powitania na szychcie i szpara pod stropem.
- **Factcheck 10:** przeszedłeś go w części, bez uwag poza jedną: „ta sama opcja nie powinna już zużywać 5 minut”. Zrobiłem to w task_11. Resztę sprawdzimy w większym teście.

## Test
- **Automatyczne (uruchomione):**
  - `unit`: 9 nowych sprawdzeń (200 losowań: każdy dostaje pomieszczenie, nigdy więcej niż 2; to samo ziarno daje ten sam wynik; miejsca 1 i 2; dzień 1 i 2; zapis bez pomieszczeń),
  - `lint`, `dialogue`,
  - nowy scenariusz **`first_meet`** w prawdziwym świecie: w dniu 1 czwórka w obozie, Wszebor i Sobek w sztolni na `EastSpot1/2` z powitaniem na szychcie (bez „Siadaj, siadaj” i bez „przy śniadaniu”), Nasir i Hagiwara w rząpiu, po rozmowie zostają, wieczorem piątki nie ma, rano w dniu 2 wszyscy w obozie, a Anzelm (za zawałem) dostaje powitanie obozowe.

  Wszystkie przechodzą.
- **Zrzut** Starej sztolni w dniu 1: Wszebor klęczy, a Sobek stoi w chodniku tuż za wejściem, nikt nie wchodzi w ścianę.
- **Pełny zestaw (za zgodą, 2026-09-26):** 18/18 po poprawieniu oczekiwań w testach (szczegóły w raporcie task_12). `first_meet` jest w domyślnej liście `run_tests.sh`.
- **Ręczne:** [factcheck-test-10](../../human-tasks/done/factcheck-test-10.md) (13 punktów, ok. 25 min).

## Podsumowanie
- **Obóz w dniu 1:** są w nim tylko Mirosław, Bolko, Tekla i Racibor.
- **Piątka na szychcie:** Wszebor, Nasir, Hagiwara, Sobek i Anzelm pracują w losowych pomieszczeniach pierwszego poziomu (Stara sztolnia, Rząpie, Zawalony chodnik), najwyżej dwoje w jednym, i witają bohatera po szychtowemu.
- **Wieczór i dzień 2:** wieczorem w dniu 1 piątki w obozie nie ma. Od rana w dniu 2 wszyscy są w obozie.
- **Spójność:** wstęp i ognisko mówią to samo, a losowanie przeżywa zapis.

Pełny zestaw testów przechodzi (18/18).
