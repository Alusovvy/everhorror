# Dialogi (tryb Visual Novel)

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 2, 3

## Cel
Główny nośnik fabuły, relacji i decyzji. Tryb VN pozwala opowiadać gęsto (monologi, opisy zmysłowe), czego w FPP nie da się zrobić tanio.

## Doświadczenie gracza
Rozmowa jest wyborem z kosztem, a nie przerwą w grze. Gracz widzi, które opcje wymagają zaufania albo wiedzy, i czuje, że wcześniejsze decyzje mają znaczenie.

## Zasady
1. **Ekran VN:** postać NPC na tle, tekst i opcje dialogowe **[GDD]**.
2. **Opcje zależą od reputacji i wcześniejszych wyborów** **[GDD]**.
3. **VN służy też do narracji bez NPC:** wejście do kopalni, przejścia między segmentami tuneli, kluczowe eventy **[GDD]**.
4. [propozycja] Opcja dialogowa może mieć:
   - **warunki**: reputacja ≥ X, posiadany przedmiot, flaga fabularna, NPC obecny, poczytalność w progu;
   - **efekty**: ± reputacja lub poczytalność, dodanie przedmiotu, questa lub informacji, ustawienie flagi, koszt czasu, skok do innej sceny, prośba o pomoc NPC.
5. [propozycja] Niespełnione opcje są **widoczne, ale zablokowane**, z podpowiedzią („Wymaga zaufania”). Opcje ukryte zostawiamy dla sekretów.
6. [propozycja] Koszt czasu rozmowy liczy się **raz przy wejściu w rozmowę**, a nie za każdą kwestię. Wyjątek to opcje ze swoim kosztem, np. pomoc.

## Dane i strojenie
| Parametr | Wartość | Uwagi |
|---|---|---|
| Koszt rozmowy | zob. [Czas](czas.md#dane-i-strojenie) | |
| Tempo wyświetlania tekstu | [propozycja] ~40 znaków/s, pomijalne kliknięciem | do opcji |

## Zależności
[NPC](npc.md) (reputacja, poczytalność), [Czas](czas.md), [Questy](questy.md), [Ekwipunek](ekwipunek.md), stan gry (flagi).

## Przypadki brzegowe
- NPC traci poczytalność w trakcie rozmowy → [propozycja] rozmowa kończy się sceną objawu.
- Brak dostępnych opcji → zawsze istnieje opcja wyjścia.

## Implementacja
🟡 Prototyp UI: [visual_interaction.tscn](../scene/visual_interaction/visual_interaction.tscn) (obrazek, pole tekstu, lista opcji z tekstem zastępczym). Nie jest jeszcze podpięty do gry.
[propozycja] Dane dialogów jako `Resource` (`DialogueData`: lista węzłów z tekstem, mówcą, opcjami, warunkami i efektami). Alternatywa: gotowa wtyczka (np. Dialogue Manager dla Godot 4). Decyzja do [dziennika](../decyzje.md).

## Otwarte pytania
- ❓ Własny system dialogów czy wtyczka?
- ❓ Portrety NPC: ilustracje 2D czy rendery postaci 3D?
- ❓ Czy są wybory z ograniczonym czasem na odpowiedź?
