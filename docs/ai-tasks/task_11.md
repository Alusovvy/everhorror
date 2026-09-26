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
Na razie analiza i plan. Implementacja po task_10 i decyzjach.

## Decyzje i założenia
- Zakładam, że dzisiejsze powitania obozowe są dobre, a zadanie je uzupełnia, a nie przepisuje.
- Hrapek (task_09) i Drudzy mają własne sceny spotkań, więc tu ich tylko sprawdzam.

## Czego potrzebuję od Ciebie
- Odpowiedzi w [decision-task-11](../human-tasks/decision-task-11.md) (2 pytania).

## Test
Po implementacji: `docs/human-tasks/factcheck-test-11.md`.

## Podsumowanie
Dialogi mają już mechanizm pierwszego spotkania zależny od miejsca, ale obejmuje on tylko obóz. Po task_10, kiedy ludzie będą poznawani w pomieszczeniach kopalni, trzeba dopisać powitania „w terenie”, pilnować wzmianek o osobach jeszcze nieznanych i dodać test, który przy każdej zmianie rozkładu dnia wyłapie brakujące powitanie. **Status: czeka na task_10 i decyzje.**
