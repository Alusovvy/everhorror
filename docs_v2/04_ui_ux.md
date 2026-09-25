# 04 UI / UX

> Status: 🟡 szkic · Właściciel: — · Aktualizacja: 2026-09-25

## Zasady
[propozycja]
1. **Minimum HUD w FPP.** Tylko mały celownik i kontekstowa podpowiedź. Żadnych pasków, minimapy ani znaczników celu. Horror potrzebuje pustego ekranu.
2. **Informacja w świecie przed interfejsem:** czas pokazany świecą lub zegarkiem, stan NPC widoczny w zachowaniu, mapa na stole.
3. **Spójny styl:** ciemne panele, ciepły bursztynowy akcent (jak światło lampy). Wspólny motyw: `theme/ui_theme.tres`.
4. **Pełna obsługa klawiaturą:** każde menu ma fokus na pierwszym przycisku, strzałki i Enter działają, a [Esc] zawsze cofa.
5. **Języki:** menu po angielsku, tekst w świecie i VN po polsku (zob. [dziennik decyzji](decyzje.md)). ❓ Docelowe wersje językowe gry.

## Ekrany

| Ekran | Zawartość | Stan |
|---|---|---|
| **HUD (FPP)** | celownik (biały, a na obiekcie bursztynowy), podpowiedź „[E] nazwa”, panel opisu na dole ekranu | ✅ |
| **Menu główne** | tytuł EVERHORROR, START / OPTIONS / LOAD GAME / EXIT | ✅ |
| **Pauza** | przyciemnienie, RESUME / SAVE GAME / LOAD GAME / OPTIONS / MAIN MENU / EXIT | ✅ |
| **Opcje** | czułość myszy, głośność, pełny ekran, BACK | ✅ |
| **Sloty zapisu** | 3 sloty z datą, komunikat o zapisie | ✅ |
| **Ekran VN** | tło, postać, tekst, opcje (zablokowane z podpowiedzią) | 🟡 prototyp |
| **Stół z mapą** | graf pomieszczeń, koszty podróży, złoża, odnogi | ⬜ |
| **Ekwipunek na wyprawę** | wybór przedmiotów do limitu | ⬜ |
| **Notes** | questy, notatki dziadka i dowódcy | ⬜ |
| **Ekran nowego dnia** | [propozycja] „Dzień N”, krótkie podsumowanie nocy | ⬜ |

## Przepływ ekranów
```
Menu główne ──START──▶ Gra (FPP) ◀──RESUME── Pauza
     │                   │  ▲                 │
     ├─LOAD GAME─▶ Sloty ┘  └──── [Esc] ──────┤
     ├─OPTIONS──▶ Opcje                      ├─SAVE/LOAD─▶ Sloty
     └─EXIT                                  ├─OPTIONS──▶ Opcje
                                             └─MAIN MENU─▶ Menu główne
```

## Dostępność
[propozycja] Do dodania w opcjach: suwak jasności lub gammy (ciemna gra), rozmiar tekstu VN, tempo tekstu, odwrócenie osi Y, osobne głośności (muzyka, efekty, ambient), zmiana przypisania klawiszy.
