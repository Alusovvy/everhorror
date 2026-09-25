# 02 Rozgrywka

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 · Źródło: GDD §1, §4

## Pętla główna (jeden dzień) **[GDD]**

| Krok | Miejsce | Co robi gracz | Kosztuje czas? | System |
|---|---|---|---|---|
| 1 | Obóz | rozmowy z NPC, questy, obserwacja zmian | rozmowy tak, chodzenie nie | [NPC](systemy/npc.md), [Dialogi](systemy/dialogi_vn.md) |
| 2 | Stół z mapą | wybór kierunku eksploracji | — | [Eksploracja](systemy/eksploracja_kopalni.md) |
| 3 | Ekwipunek | wybór przedmiotów (paliwo, liny…) | — | [Ekwipunek](systemy/ekwipunek.md) |
| 4 | Tunele | podróż, eksploracja FPP, zagadki, wydobycie, notatki | podróż tak, chodzenie nie | [Eksploracja](systemy/eksploracja_kopalni.md), [Interakcje](systemy/interakcje.md) |
| 5 | Obóz | powrót, konsekwencje wyprawy | — | |
| 6 | Posłanie | sen, czyli przejście do kolejnego dnia | tak | [Czas](systemy/czas.md) |

## Pętla meta (cała gra)
Schodzimy coraz głębiej: kopalnia → jaskinie → Świątynia Onych **[GDD]**. Postęp w dół odblokowują mapy dziadka, eksploracja i pomoc NPC. Z każdym dniem rośnie presja: termin, spadająca poczytalność ekspedycji, rany i zgony. Gra kończy się jednym z [zakończeń](swiat/fabula.md#zakończenia).

## Tryby gry

| Tryb | Kiedy | Sterowanie | Stan |
|---|---|---|---|
| **Eksploracja FPP** | obóz, segmenty tuneli **[GDD]** | ruch, rozglądanie, [E] | ✅ prototyp |
| **Visual Novel** | dialogi, eventy fabularne, niektóre przejścia między segmentami **[GDD]** | wybór opcji myszą / klawiaturą | 🟡 prototyp UI |
| **Mapa / notes** [propozycja] | stół z mapą, podgląd questów | UI | ⬜ |
| **Pauza** | [Esc] w dowolnym momencie gry | UI | ✅ |

Przejście FPP → VN następuje po interakcji z NPC lub przedmiotem albo po evencie. Po VN gracz wraca do FPP w tym samym miejscu. [propozycja] W trybie VN świat 3D stoi, a kursor jest uwolniony.

## Sterowanie (stan obecny)

| Akcja | Klawisz | Nazwa akcji w Godot |
|---|---|---|
| Ruch | W / A / S / D, strzałki | `move_forward`, `move_back`, `move_left`, `move_right` |
| Rozglądanie | mysz (pion: 40° w górę, 70° w dół) | — |
| Skok | Spacja | `jump` |
| Interakcja / zamknij opis | E | `interact` |
| Pauza / wstecz w menu | Esc | `ui_cancel` |

❓ Czy skok zostaje? W grze bez walki i platformówki może pozwalać wychodzić poza zaplanowane ścieżki. [propozycja] Zamienić go na kucanie lub usunąć.

## Warunki porażki
❓ Do ustalenia. Kandydaci: minięcie terminu, śmierć kluczowych NPC, utrata wszystkich towarzyszy. Czy gracz sam może zginąć? Zob. [Eksploracja: zagrożenie](systemy/eksploracja_kopalni.md#zagrożenie).
