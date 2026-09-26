# 04 UI / UX

> Status: 🟡 szkic · Właściciel: — · Aktualizacja: 2026-09-25

## Zasady
[propozycja]
1. **Minimum HUD w FPP.** Tylko mały celownik i kontekstowa podpowiedź. Żadnych pasków, minimapy ani znaczników celu. Horror potrzebuje pustego ekranu.
2. **Informacja w świecie przed interfejsem:** stan NPC widoczny w zachowaniu, mapa na stole. Zegara nie ma w rogu ekranu: godzina jest w notesie i w oknie rozmowy **[decyzja 2026-09-26]**.
3. **Spójny styl:** ciemne panele, ciepły bursztynowy akcent (jak światło lampy). Wspólny motyw: `theme/ui_theme.tres`.
4. **Pełna obsługa klawiaturą:** każde menu ma fokus na pierwszym przycisku, strzałki i Enter działają, a [Esc] zawsze cofa.
5. **Języki:** menu po angielsku, tekst w świecie i VN po polsku (zob. dziennik decyzji w specyfikacji, `09_produkcja.md`). ❓ Docelowe wersje językowe gry.

## Ekrany

| Ekran | Zawartość | Stan |
|---|---|---|
| **HUD (FPP)** | celownik (biały, a na obiekcie bursztynowy), podpowiedź „[E] nazwa · koszt (potrzebny: …)”, panel opisu na dole ekranu, bez zegara (task_09), pod nim stan bohatera tylko gdy coś jest nie tak („ranny · gorączka”), komunikaty (czas, przedmioty, notatki, zadania, żyły, szepty), winieta na brzegach przy „na krawędzi” | ✅ |
| **Menu główne** | tytuł EVERHORROR, START / OPTIONS / LOAD GAME / EXIT | ✅ |
| **Pauza** | przyciemnienie, RESUME / SAVE GAME / LOAD GAME / OPTIONS / MAIN MENU / EXIT | ✅ |
| **Opcje** | czułość myszy, jasność, głośność ogólna + osobno tło i efekty, pełny ekran, gwara śląska górników, „Show locked choices”, BACK | ✅ |
| **Sloty zapisu** | rząd AUTO (świt, tylko wczytanie) + 3 sloty ręczne z datą | ✅ |
| **Ekran VN** | rozmyte tło gry, portret 3D postaci (albo statyczny obraz, np. ściana Onych), imię, tekst, opcje (zablokowane przez zaufanie albo przedmiot: szare, z powodem), zegar (+5 min za opcję) | ✅ |
| **Stół z mapą** | rysunek grafu dróg (trasa, gdzie jesteś, kreski żył), licznik żył i termin, lista znanych miejsc z kosztem, opis, powód blokady, WYRUSZ | ✅ |
| **Mapa w terenie [M]** | ten sam ekran: sąsiednie miejsca i powrót do obozu, IDŹ DALEJ / WRACAJ DO OBOZU / ZOSTAŃ TUTAJ | ✅ |
| **Podsumowanie wyprawy** | czas, miejsca, żyły i norma, przyniesione rzeczy, zdarzenia, stan bohatera, komentarz; DALEJ [E] | ✅ |
| **Ekwipunek [I]** | stan bohatera słowami, norma, lista przedmiotów, opis, UŻYJ z czasem i powodem, gdy się nie da | ✅ |
| **Ekwipunek na wyprawę** | wybór przedmiotów do limitu | ⬜ (brak limitu w demie) |
| **Notes** | zakładki Zadania (z normą), Notatki, Ludzie (zdrowie, głowa, stosunek do bohatera, słowami) i Czas (zegar, do nocy, dziennik dni) [J] | ✅ |
| **Ekran nowego dnia** | plansza „Dzień N” z jednym zdaniem o poranku, przed nią sen (VN) | ✅ |
| **Koniec tygodnia / śmierć** | logo, tytuł („Koniec tygodnia”, „Zostałeś sam”, „Nie żyjesz”), podsumowanie wyborów, RETRY FROM MORNING (po śmierci) / MAIN MENU / EXIT | ✅ |

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
✅ Jasność i osobne głośności tła/efektów są (task_06). [propozycja] Do dodania: rozmiar i tempo tekstu VN, odwrócenie osi Y, zmiana przypisania klawiszy.
