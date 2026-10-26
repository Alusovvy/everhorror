# Dokumentacja gry — everhorror (v2)

> **Materiały odniesienia od 2026-10-26.** Bieżąca specyfikacja i proces są w sąsiednim repo `specification` (`WORKFLOW.md`). Zduplikowanych opisów nie synchronizujemy z kodem. Oryginały zostają do sprawdzonej migracji M5; nagłówki i statusy niżej są historyczne. Pełny `swiat/LoreDoc.md` i szczegóły rejestru/licencji `05_oprawa.md` nadal są potrzebnymi źródłami uzupełniającymi — nie zostały przeniesione ani usunięte.

> Tytuł roboczy: **everhorror** (w pierwotnym GDD: „XYZ”).
> Ostatnia aktualizacja: 2026-09-25 (po task_05) · Wersja dokumentacji: 2.2

Ten folder powstał jako modularizacja [docs/GDD.md](../docs/GDD.md). Obecnie oba są materiałem źródłowym; nowe decyzje, liczby i opisy zmieniamy w specyfikacji, bez dwóch niezależnie edytowanych kopii.

> **Źródłem prawdy o projekcie jest specyfikacja gry**: osobne repozytorium `specification` obok repozytorium gry (`C:\dev\gamedev\everhorror\specification`). Dziennik decyzji, zbiorcze pytania, słowniczek i kamienie milowe są tam. W razie rozbieżności obowiązuje nowsza przyjęta decyzja; kod pokazuje zachowanie, a test tylko sprawdzony zakres. Pełną mapę podaje `specification/WORKFLOW.md`.

## Jak czytać

1. Zacznij od **[jednostronicowego opisu](00_jednostronicowy.md)**. To cała gra na jednej stronie.
2. **[Wizja i filary](01_wizja.md)** pokazują, czym gra ma być i czym nie ma być. Według nich oceniamy każdą nową funkcję.
3. **[Rozgrywka](02_rozgrywka.md)** opisuje pętle, tryby i sterowanie.
4. Potem wybierz konkretny system, świat albo temat techniczny z mapy poniżej.

## Mapa dokumentów

| Obszar | Dokument | Właściciel | Status |
|---|---|---|---|
| **Całość** | [00 Jednostronicowy opis](00_jednostronicowy.md) | zespół | 🟡 szkic |
| | [01 Wizja i filary](01_wizja.md) | Vitav | 🟡 szkic |
| | [02 Rozgrywka](02_rozgrywka.md) | Roland | 🟡 szkic |
| **Systemy** | [Upływ czasu](systemy/czas.md) | Roland | 🟢 zaimplementowane (tydzień) |
| | [Postacie niezależne](systemy/npc.md) | Roland | 🟢 zaimplementowane (14 postaci, spotkania w tunelach) |
| | [Dialogi (tryb VN)](systemy/dialogi_vn.md) | Roland | 🟢 zaimplementowane (demo) |
| | [Eksploracja kopalni](systemy/eksploracja_kopalni.md) | Roland | 🟢 zaimplementowane (15 miejsc, [M], norma) |
| | [Interakcje z otoczeniem](systemy/interakcje.md) | Roland | 🟢 zaimplementowane |
| | [Ekwipunek](systemy/ekwipunek.md) | Roland | 🟢 zaimplementowane ([I], 17 przedmiotów) |
| | [Zdrowie i poczytalność bohatera](systemy/zdrowie_i_poczytalnosc.md) | Roland | 🟢 zaimplementowane |
| | [Questy i notes](systemy/questy.md) | Roland | 🟢 zaimplementowane (demo) |
| | [Zapis, menu i opcje](systemy/zapis_i_opcje.md) | programista | 🟢 zaimplementowane |
| **Świat** | [Świat i lore](swiat/lore.md) | Ren | 🟡 szkic |
| | [LoreDoc: pełny opis świata](swiat/LoreDoc.md) | Ren | 🔵 do przeglądu |
| | [Magia](swiat/magia.md) | Ren | 🟡 szkic |
| | [Niespójności w LoreDoc](swiat/loredoc_niespojnosci.md) | Ren | 🔵 do przeglądu |
| | [Fabuła, prolog, zakończenia](swiat/fabula.md) | Ren / Vitav | 🟡 szkic |
| | [Postacie](swiat/postacie.md) (+ karty w `swiat/postacie/`) | zespół | 🟡 szkic, 12 roboczych do przeglądu |
| **Treść** | [03 Poziomy](03_poziomy.md) | — | 🟡 obóz i 15 miejsc wypraw w demie |
| | [04 UI / UX](04_ui_ux.md) | — | 🟡 szkic |
| | [05 Oprawa wizualna i dźwiękowa](05_oprawa.md) | — | 🟡 szkic |
| **Technika** | 06 Dokument techniczny (TDD) | programista | 🔴 do napisania (skrót: specyfikacja, `08_technika.md`, i `CLAUDE.md`) |
| **Produkcja** | Produkcja i roadmapa | zespół | w specyfikacji (`09_produkcja.md`) |
| | Dziennik decyzji | zespół | w specyfikacji (`09_produkcja.md`) |
| | Słownik | zespół | w specyfikacji (`01_swiat/slowniczek.md`) |
| | Historia zmian | zespół | raporty w [docs/ai-tasks](../docs/ai-tasks/INFO.md) i `WDROZENIA.md` w specyfikacji |
| **Szablony** | [Szablon systemu](szablony/system.md), [Szablon NPC](szablony/npc.md) | — | — |

## Oznaczenia

**Status dokumentu:** 🔴 do ustalenia · 🟡 szkic · 🔵 do przeglądu · 🟢 zatwierdzony / aktualny.

**W treści:**
- **[GDD]** — pochodzi z pierwotnego GDD, czyli jest ustalone przez zespół.
- **[propozycja]** — sugestia, która czeka na akceptację. Nie jest wiążąca, dopóki nie trafi do dziennika decyzji (specyfikacja, `09_produkcja.md`).
- **❓** — otwarte pytanie. Zbiorcza lista jest w specyfikacji (`09_produkcja.md`, „Otwarte pytania”).
- **✅ / 🟡 / ⬜** — stan implementacji: gotowe / częściowo / nie zaczęte.

## Historyczne zasady i obecne miejsce edycji

1. **Bieżąca dokumentacja jest w specyfikacji.** Zmiana gry aktualizuje odpowiednie zasady i dowody tam; ten folder nie wymaga synchronizacji.
2. **Jeden temat, jeden plik.** Plik systemu ma najwyżej 2–3 ekrany. Jeśli rośnie, dzielimy go.
3. **Najpierw „po co”, potem „jak”.** Każdy system zaczyna się od celu i doświadczenia gracza.
4. **Liczby w jednym miejscu.** Autorytatywny balans projektu to `specification/07_balans.md`. Dane i stałe gry są implementacją, nie nowym niezależnym źródłem projektu.
5. **Decyzje zapisujemy.** Gdy propozycja zostaje przyjęta albo odrzucona, dopisujemy wpis w dzienniku decyzji (specyfikacja, `09_produkcja.md`) i usuwamy znacznik [propozycja].
6. **Nowe systemy i postacie** opisujemy opcjonalnymi szablonami w `specification/szablony/`; tutejsze wzory są historyczne.
7. **Język:** dokumentacja po polsku. Kod, nazwy w kodzie i komentarze po angielsku.
