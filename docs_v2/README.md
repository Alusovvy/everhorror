# Dokumentacja gry — everhorror (v2)

> Tytuł roboczy: **everhorror** (w pierwotnym GDD: „XYZ”).
> Ostatnia aktualizacja: 2026-09-25 · Wersja dokumentacji: 2.0

Ten folder zastępuje monolityczny [docs/GDD.md](../docs/GDD.md) zestawem krótkich, modułowych dokumentów. Stare dokumenty zostają bez zmian jako materiał źródłowy.

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
| **Systemy** | [Upływ czasu](systemy/czas.md) | Roland | 🟡 szkic |
| | [Postacie niezależne](systemy/npc.md) | Roland | 🟡 szkic |
| | [Dialogi (tryb VN)](systemy/dialogi_vn.md) | Roland | 🟡 szkic |
| | [Eksploracja kopalni](systemy/eksploracja_kopalni.md) | Roland | 🟡 szkic |
| | [Interakcje z otoczeniem](systemy/interakcje.md) | Roland | 🟢 zaimplementowane (podstawa) |
| | [Ekwipunek](systemy/ekwipunek.md) | Roland | 🔴 do ustalenia |
| | [Questy i notes](systemy/questy.md) | Roland | 🟡 szkic |
| | [Zapis, menu i opcje](systemy/zapis_i_opcje.md) | programista | 🟢 zaimplementowane (podstawa) |
| **Świat** | [Świat i lore](swiat/lore.md) | Ren | 🟡 szkic |
| | [LoreDoc: pełny opis świata](swiat/LoreDoc.md) | Ren | 🔵 do przeglądu |
| | [Magia](swiat/magia.md) | Ren | 🟡 szkic |
| | [Niespójności w LoreDoc](swiat/loredoc_niespojnosci.md) | Ren | 🔵 do przeglądu |
| | [Fabuła, prolog, zakończenia](swiat/fabula.md) | Ren / Vitav | 🟡 szkic |
| | [Postacie](swiat/postacie.md) | zespół | 🟡 szkic |
| **Treść** | [03 Poziomy](03_poziomy.md) | — | 🔴 do ustalenia |
| | [04 UI / UX](04_ui_ux.md) | — | 🟡 szkic |
| | [05 Oprawa wizualna i dźwiękowa](05_oprawa.md) | — | 🟡 szkic |
| **Technika** | [06 Dokument techniczny (TDD)](06_techniczne.md) | programista | 🟢 aktualny |
| **Produkcja** | [07 Produkcja i roadmapa](07_produkcja.md) | zespół | 🟡 szkic |
| | [Dziennik decyzji](decyzje.md) | zespół | 🟢 prowadzony |
| | [Słownik](glosariusz.md) | zespół | 🟢 prowadzony |
| | [Historia zmian](CHANGELOG.md) | zespół | 🟢 prowadzony |
| **Szablony** | [Szablon systemu](szablony/system.md), [Szablon NPC](szablony/npc.md) | — | — |

## Oznaczenia

**Status dokumentu:** 🔴 do ustalenia · 🟡 szkic · 🔵 do przeglądu · 🟢 zatwierdzony / aktualny.

**W treści:**
- **[GDD]** — pochodzi z pierwotnego GDD, czyli jest ustalone przez zespół.
- **[propozycja]** — sugestia, która czeka na akceptację. Nie jest wiążąca, dopóki nie trafi do [dziennika decyzji](decyzje.md).
- **❓** — otwarte pytanie. Zbiorcza lista jest w [07 Produkcja](07_produkcja.md#otwarte-pytania).
- **✅ / 🟡 / ⬜** — stan implementacji: gotowe / częściowo / nie zaczęte.

## Zasady prowadzenia dokumentacji

1. **Dokumentacja żyje.** Aktualizujemy ją razem ze zmianą w grze, w tym samym commicie, jeśli to możliwe.
2. **Jeden temat, jeden plik.** Plik systemu ma najwyżej 2–3 ekrany. Jeśli rośnie, dzielimy go.
3. **Najpierw „po co”, potem „jak”.** Każdy system zaczyna się od celu i doświadczenia gracza.
4. **Liczby w jednym miejscu.** Wartości do balansu trzymamy w sekcji „Dane i strojenie” danego systemu, a w grze w plikach `Resource`, nie w kodzie.
5. **Decyzje zapisujemy.** Gdy propozycja zostaje przyjęta albo odrzucona, dopisujemy wpis w [dzienniku decyzji](decyzje.md) i usuwamy znacznik [propozycja].
6. **Nowe systemy i postacie** zaczynamy od [szablonów](szablony/).
7. **Język:** dokumentacja po polsku. Kod, nazwy w kodzie i komentarze po angielsku.
