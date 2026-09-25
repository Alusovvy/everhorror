# Dokumentacja gry — everhorror (v2)

> Tytuł roboczy: **everhorror** (w pierwotnym GDD: „XYZ”).
> Ostatnia aktualizacja: 2026-09-25 (po task_05) · Wersja dokumentacji: 2.2

Ten folder zastępuje monolityczny [docs/GDD.md](../docs/GDD.md) zestawem krótkich, modułowych dokumentów. Stare dokumenty zostają bez zmian jako materiał źródłowy.

> **Od 2026-09-25 źródłem prawdy o projekcie jest specyfikacja gry**: osobne repozytorium `specification` obok repozytorium gry (`C:\dev\gamedev\everhorror\specification`). Zespół zmienia ją na GitHubie, a agent wdraża zmiany. Ten folder opisuje stan implementacji i jest aktualizowany razem z grą. Dziennik decyzji, zbiorcze pytania, słowniczek i kamienie milowe są już tylko w specyfikacji.

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

## Zasady prowadzenia dokumentacji

1. **Dokumentacja żyje.** Aktualizujemy ją razem ze zmianą w grze, w tym samym commicie, jeśli to możliwe.
2. **Jeden temat, jeden plik.** Plik systemu ma najwyżej 2–3 ekrany. Jeśli rośnie, dzielimy go.
3. **Najpierw „po co”, potem „jak”.** Każdy system zaczyna się od celu i doświadczenia gracza.
4. **Liczby w jednym miejscu.** Wartości do balansu trzymamy w sekcji „Dane i strojenie” danego systemu, a w grze w plikach `Resource`, nie w kodzie.
5. **Decyzje zapisujemy.** Gdy propozycja zostaje przyjęta albo odrzucona, dopisujemy wpis w dzienniku decyzji (specyfikacja, `09_produkcja.md`) i usuwamy znacznik [propozycja].
6. **Nowe systemy i postacie** zaczynamy od [szablonów](szablony/).
7. **Język:** dokumentacja po polsku. Kod, nazwy w kodzie i komentarze po angielsku.
