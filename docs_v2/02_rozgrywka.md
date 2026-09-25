# 02 Rozgrywka

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Źródło: GDD §1, §4

## Pętla główna (jeden dzień) **[GDD]**

| Krok | Miejsce | Co robi gracz | Kosztuje czas? | System |
|---|---|---|---|---|
| 1 | Obóz | rozmowy z NPC, questy, obserwacja zmian | rozmowy tak, chodzenie nie | [NPC](systemy/npc.md), [Dialogi](systemy/dialogi_vn.md) |
| 2 | Stół z mapą | wybór celu, WYRUSZ; licznik żył wobec normy | — | [Eksploracja](systemy/eksploracja_kopalni.md) |
| 3 | Ekwipunek [I] | leczenie, sprawdzenie kluczy (lina, olej, kilof, łom) | użycie czasem tak | [Ekwipunek](systemy/ekwipunek.md) |
| 4 | Tunele | podróż, [M] dalej, eksploracja FPP, znaczenie żył, znaleziska, spotkania | podróż, rozpoznanie i żyły tak, chodzenie nie | [Eksploracja](systemy/eksploracja_kopalni.md), [Interakcje](systemy/interakcje.md) |
| 5 | Obóz | powrót, podsumowanie wyprawy, oddanie przedmiotów, konsekwencje | — | |
| 6 | Posłanie | sen, czyli przejście do kolejnego dnia | tak | [Czas](systemy/czas.md) |

## Pętla meta (cała gra)
Schodzimy coraz głębiej: kopalnia → jaskinie → Świątynia Onych **[GDD]**. Postęp w dół odblokowują mapy dziadka, eksploracja i pomoc NPC. Z każdym dniem rośnie presja: termin, spadająca poczytalność ekspedycji, rany i zgony. Gra kończy się jednym z [zakończeń](swiat/fabula.md#zakończenia).

## Tryby gry

| Tryb | Kiedy | Sterowanie | Stan |
|---|---|---|---|
| **Eksploracja FPP** | obóz, segmenty tuneli **[GDD]** | ruch, rozglądanie, [E] | ✅ prototyp |
| **Visual Novel** | dialogi, eventy fabularne, sen, poranne ogłoszenie, ściana w kaplicy **[GDD]** | wybór opcji myszą / klawiaturą, [Spacja] dalej | ✅ |
| **Mapa / notes / ekwipunek** | stół z mapą (wyprawy), mapa [M] w chodnikach, notes [J] (zadania, notatki, ludzie), ekwipunek [I] | UI | ✅ |
| **Pauza** | [Esc] w dowolnym momencie gry | UI | ✅ |

Przejście FPP → VN następuje po interakcji z NPC lub przedmiotem albo po evencie. Po VN gracz wraca do FPP w tym samym miejscu. [propozycja] W trybie VN świat 3D stoi, a kursor jest uwolniony.

## Sterowanie (stan obecny)

| Akcja | Klawisz | Nazwa akcji w Godot |
|---|---|---|
| Ruch | W / A / S / D, strzałki | `move_forward`, `move_back`, `move_left`, `move_right` |
| Rozglądanie | mysz (pion: 40° w górę, 70° w dół) | — |
| Skok | Spacja | `jump` |
| Interakcja / zamknij opis | E | `interact` |
| Notes | J | `notebook` |
| Ekwipunek | I | `inventory` |
| Mapa w chodnikach | M | `field_map` |
| Dalej w rozmowie | Spacja / Enter / kliknięcie | `ui_accept`, `interact` |
| Pauza / wstecz w menu | Esc | `ui_cancel` |

❓ Czy skok zostaje? W grze bez walki i platformówki może pozwalać wychodzić poza zaplanowane ścieżki. [propozycja] Zamienić go na kucanie lub usunąć.

## Warunki porażki
- ✅ **Minięcie normy:** rano w dniu 8 wyprawa wyjeżdża bez gracza („Zostałeś sam”) **[decyzja 2026-09-25, MECHANICS §13 pkt 2]**.
- ✅ **Śmierć bohatera:** tylko gdy był już ranny, a coś go zrani znowu. Można powtórzyć dzień od rana **[decyzja 2026-09-25, MECHANICS §13 pkt 3]**. Zob. [Zdrowie i poczytalność](systemy/zdrowie_i_poczytalnosc.md).
- ✅ **Załamanie:** reszta dnia przepada.
- ❓ Śmierć kluczowych NPC i utrata wszystkich towarzyszy w pełnej grze.
