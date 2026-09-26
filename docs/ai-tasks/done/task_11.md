<!--
Zadanie z czatu (2026-09-26). Wymagania to dosłowny cytat notatki użytkownika (akapit 2 z 3; nawiązuje do task_10).
-->

Wymagania:
Tutaj trzeba sprawdzić czy dialogi są dostosowane do pierwszego spotkania w obozie albo w jakiejś innej lokacji.

Priorytet: do ustalenia · Kolejność: po task_10 (task_10 zmienia, gdzie i kiedy gracz poznaje ludzi)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza
**Jak to działa dziś.** Każda rozmowa obozowa zaczyna się od bloku `if not has_flag("met_<id>")` z pierwszym powitaniem, a jego tekst zależy od `npc_place(<id>)`. Przykład: Wszebor przy ognisku śpiewa, w wyrobisku wali kilofem, a przy stole je za trzech.

**Luki, które widać już teraz:**
1. **Powitania nie obejmują wszystkich miejsc**, w których postać może stać przy pierwszej rozmowie. Wariant „w terenie” mają tylko Wszebor i Nasir. Pozostali, spotkani w pomieszczeniu z task_10, dostaliby powitanie „przy stole” albo „przy księdze”.
2. **Teksty zakładają, że gracz kogoś zna.** Sceny i rozmowy mówią o osobach, których gracz mógł jeszcze nie poznać:
   - ognisko w dniu 1,
   - kolacja,
   - poranne ogłoszenia,
   - wzmianki typu „Wszebor mówił…”.

   Część jest już pilnowana (np. Bolko pyta o Wszebora dopiero przy `met_wszebor`), część nie.
3. **Nikt tego nie sprawdza automatycznie.** Dodanie nowego miejsca w rozkładzie dnia może po cichu dać złe powitanie.

## Plan
1. **Tabela pokrycia** (dopiszę ją do tego pliku po przeglądzie): każda postać × każde miejsce, w którym może stać przy pierwszym spotkaniu (z `CampSchedule`, `FieldSchedule` i pomieszczeń z task_10) × czy powitanie do niego pasuje.
2. **Uzupełnienie powitań** w `dialogue/*.dialogue`. Zakres wariantów zależy od decyzji 1. Teksty oznaczam jako [ROBOCZE], do przeglądu przez Ren. Kwestie górników dostają wersję w gwarze (`write_gwara.js`).
3. **Przegląd wzmianek o innych osobach**: warunek `met_<id>` tam, gdzie to konieczne, albo neutralne sformułowanie („ten wielki rębacz”). Zależy od decyzji 2.
4. **Sceny dnia 1** (ognisko, kolacja, wstęp): tylko osoby, które są w obozie (spójne z task_10).
5. **Automatyczna kontrola:**
   - `data_lint` sprawdza, czy powitanie każdej postaci ma gałąź dla każdego miejsca, które może zwrócić rozkład dnia, albo świadomie wspólną gałąź `else`,
   - `dialogue_test` przechodzi pierwsze spotkanie w każdym miejscu.
6. **Specyfikacja:**
   - DIA/NPC: zasada „pierwsze spotkanie zna miejsce” (NPC-15 rozszerzone),
   - wpis w `WDROZENIA.md`,
   - factcheck `factcheck-test-11.md` (lista postaci i miejsc do sprawdzenia w grze).

## Co zostało zrobione
### Tabela pokrycia (przegląd pierwszych spotkań)
| Postać | Gdzie można ją poznać pierwszy raz | Powitanie przed zadaniem | Po zadaniu |
|---|---|---|---|
| Wszebor, Nasir, Hagiwara, Sobek, Anzelm | dzień 1: sztolnia, rząpie, za zawałem; od dnia 2: miejsca w obozie (Wszebor i Nasir też w pracy w terenie) | wariant „w terenie” z task_10, bez zdania o pomieszczeniu | + zdanie o pomieszczeniu (3 × 5) |
| Mirosław | proch, ognisko, **kąt** (na krawędzi, od dnia 2) | w kącie opis „przy ognisku”; **w dniu 2 i 3 bez powitania** | opis kąta; powitanie w każdy dzień |
| Bolko | stół, magazyn, posłanie, legowisko, odwrócony | **w dniu 2 i 3 bez powitania** (od razu kwestie „dnia 2/3”) | powitanie w każdy dzień |
| Nasir | chory (od nocy 3) | **bez powitania**: od razu scena choroby | Anzelm mówi, kto to jest |
| Racibor, Tekla, Dobrawa | stół / zagroda; kuchnia / stragan; zagroda / wózki / na uboczu | pasują (Dobrawa ma powitanie wspólne dla wszystkich miejsc) | bez zmian |
| Sabina, Drudzy, Hrapek | teren (scena spotkania), potem obóz | własne sceny | bez zmian |

### Zmiany w dialogach [ROBOCZE]
- **Zdanie o pomieszczeniu** na szychcie w dniu 1 dla całej piątki, po jednym na sztolnię, rząpie i przejście za zawał (decyzja 1a). Przykłady: Nasir w rząpiu „Słyszysz? Woda gada. Stary szyb pije z trzech stron, a oddaje tylko jedną.”, Sobek za zawałem „Miecz przeszedł pierwszy, ja za nim.”.
- **Trzy luki znalezione przy przeglądzie:**
  - Mirosław w kącie ma własny opis („W ciemnym kącie jaskini siedzi skulony mężczyzna i liczy coś szeptem…”),
  - Mirosław i Bolko przedstawiają się też wtedy, gdy pierwsza rozmowa wypada w dniu 2 albo 3 (wcześniej gra przeskakiwała od razu do kwestii „dnia 2/3”),
  - chory Nasir: przy pierwszej rozmowie Anzelm mówi, kto to jest.

  Kwestie górników w gwarze się nie zmieniły (nowe są tylko zdania narracji).
- **Wzmianki o niepoznanych osobach (decyzja 2a):** przejrzałem wszystkie opcje z imieniem innej postaci (12). Każda ma warunek poznania (`met_…`) albo zdarzenie, które je zakłada (np. „Tekla ukrywa coś…” dopiero z tobołkiem). Kwestie czwórki z dnia 1 nie wspominają piątki. Zmiany nie były potrzebne.

### Z factchecku 10: powtórzona opcja nic nie kosztuje
- Opcja wybrana już raz u tej samej osoby jest darmowa przy każdym kolejnym wybraniu (`GameState.asked`, w zapisie; `VN.response_picked`). Pierwsze wybranie kosztuje 5 minut, a akcje z własnym kosztem kosztują swoje.

### Automatyczna kontrola
- **`lint`:**
  - każde `npc_place("x") == "miejsce"` w dialogach i reżyserze to miejsce, które rozkład dnia naprawdę zwraca (29 warunków, czytane ze skryptu rozkładu),
  - każdy, kogo można poznać w tunelu, ma powitanie „w terenie”, a piątka z dnia 1 zdanie dla każdego z trzech pomieszczeń.
- **`dialogue`:**
  - pierwsze spotkanie każdej z piątki w każdym pomieszczeniu (15 przypadków, za zawałem także narracja o szparze),
  - w obozie w dniu 2 brak zdań o szychcie (5),
  - trzy luki z przeglądu (Mirosław w kącie, Bolko w dniu 2, chory Nasir).

### Specyfikacja i dokumentacja (bez commita)
- **Specyfikacja:**
  - NPC-15 (pierwsze spotkanie zna miejsce),
  - DIA-5 (darmowa powtórzona opcja),
  - `07_balans.md`,
  - wpis w `WDROZENIA.md`.
- **docs_v2:** `systemy/npc.md`, `systemy/dialogi_vn.md`.
- **CLAUDE.md**.

## Decyzje i założenia
- Zakładam, że dzisiejsze powitania obozowe są dobre, a zadanie je uzupełnia, a nie przepisuje.
- Hrapek (task_09) i Drudzy mają własne sceny spotkań, więc tu ich tylko sprawdzam.
- **Decyzje (2026-09-26, [decision-task-11](../../human-tasks/done/decision-task-11.md)), obie zgodnie z rekomendacją:**
  1. a) jedno powitanie „w terenie” na postać plus jedno zdanie zależne od pomieszczenia,
  2. a) wzmianki o osobach jeszcze niepoznanych mogą padać, ale opisowo; opcje „Co myślisz o X?” dopiero po poznaniu X.
- **„Ta sama opcja”** rozumiem jako ten sam tekst u tej samej osoby. Opcja, która w innym dniu brzmi tak samo, ale prowadzi dalej (np. „Jak tam mój kilof?”), też jest darmowa. U innej osoby ta sama opcja kosztuje.
- **Luki Mirosława, Bolka i Nasira** poprawiłem w ramach tego zadania, bo to dokładnie jego zakres: pierwsze spotkanie w każdym możliwym miejscu i dniu.

## Czego potrzebuję od Ciebie
- Przejrzenia przez Ren nowych zdań [ROBOCZE] (15 zdań o pomieszczeniach, opis Mirosława w kącie, zdanie Anzelma o Nasirze).
- Przejścia [factcheck-test-11](../../human-tasks/factcheck-test-11.md) razem z 10 i 12, w większym teście, tak jak ustaliliśmy.

## Test
Pełny zestaw po task_11 i task_12: **18/18 zaliczonych** (szczegóły w raporcie task_12). Nowe sprawdzenia: lint pokrycia powitań (29 warunków miejsca, powitania w terenie), 23 przypadki w `dialogue`, 3 w `unit` (powtórzona opcja). Ręczne: [factcheck-test-11](../../human-tasks/factcheck-test-11.md) (8 punktów, ok. 15 min).

## Podsumowanie
- **Zdanie o pomieszczeniu:** pierwsze spotkanie na szychcie w dniu 1 brzmi teraz na miejscu, z jednym zdaniem o sztolni, rząpiu albo przejściu za zawał.
- **Trzy luki z przeglądu poprawione:** Mirosław w kącie ma własny opis, Mirosław i Bolko przedstawiają się też w dniu 2 i 3, a przy chorym Nasirze Anzelm mówi, kto to jest.
- **Wzmianki o niepoznanych osobach:** nie wymagały zmian.
- **Darmowa powtórzona opcja** (Twoja uwaga z factchecku 10): opcja wybrana już raz u tej samej osoby nic nie kosztuje.
- **Testy:** lint i test dialogów pilnują, żeby każde miejsce z rozkładu dnia miało pasujące powitanie.
