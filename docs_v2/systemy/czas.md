# Upływ czasu

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 1 (Czas to waluta)

## Cel
Sprawić, by każda decyzja miała koszt. Gracz nie zdąży zrobić wszystkiego, więc musi wybierać między rozmową, wyprawą, leczeniem a snem.

## Doświadczenie gracza
Spokojna eksploracja bez stopera, ale z ciągłą świadomością, że *ta rozmowa* odbierze czas na *tamtą wyprawę*. Presja rośnie z dnia na dzień.

## Zasady
1. **Czas płynie tylko po akcjach, nie w czasie rzeczywistym.** **[GDD]**
2. Koszty akcji **[GDD]**:

| Akcja | Kosztuje czas? |
|---|---|
| Chodzenie po obozie | nie |
| Rozmowa z NPC | **tak** |
| Podróż do pomieszczenia | **tak** |
| Eksploracja pomieszczenia w 3D | nie |
| Badanie niektórych rzeczy w pomieszczeniu | **czasami** |
| Eventy | **tak** |
| Prośba o pomoc NPC w pomieszczeniu | **tak, dużo** (ktoś musi po niego iść i wrócić) |
| Sen | **tak**, kończy dzień |

3. [propozycja] **Dzień ma budżet godzin** (np. 16). Każda akcja ma koszt w godzinach. Gdy budżet się wyczerpie, gracz musi iść spać. Jeśli jest w tunelach, wraca automatycznie, a zmęczenie obniża poczytalność ekspedycji.
4. [propozycja] **Przed każdą akcją, która kosztuje czas, gracz widzi jej koszt** (np. „[E] Porozmawiaj · 1 h”). Uczciwość wobec gracza wzmacnia ciężar wyboru.
5. [propozycja] Sen uruchamia **rozliczenie nocy**: zmiany poczytalności i zdrowia NPC, eventy nocne, przyjścia i odejścia NPC, sny bohatera (amulet).

## Dane i strojenie
[propozycja] Wartości startowe do testów w pionowym wycinku:

| Parametr | Wartość | Uwagi |
|---|---|---|
| Godziny w dniu | 16 | od pobudki do snu |
| Rozmowa z NPC | 1 h | dłuższe sceny fabularne: 2 h |
| Podróż do pomieszczenia | 1–4 h | zależnie od odległości na mapie |
| Badanie „kosztownego” obiektu | 1 h | oznaczone w `Interactable` |
| Prośba o pomoc NPC | 2 × koszt podróży | tam i z powrotem |
| Termin główny | ❓ dni | |

## Zależności
- **[NPC](npc.md)**: rozliczenie nocy, dostępność NPC o określonych porach.
- **[Eksploracja](eksploracja_kopalni.md)**: koszty podróży z mapy.
- **[Interakcje](interakcje.md)**: pole `time_cost` w obiektach [propozycja].
- **[Questy](questy.md)**: terminy questów.
- **[Zapis](zapis_i_opcje.md)**: dzień i godzina są częścią zapisu.

## Przypadki brzegowe
- Akcja kosztuje więcej, niż zostało w dniu → [propozycja] akcja jest niedostępna, z podpowiedzią „Za późno — jutro”.
- Termin mija w trakcie wyprawy → ❓
- Zapis w nocy albo w trakcie sceny VN → [propozycja] zapis tylko w FPP.

## Implementacja
⬜ Nie zaczęte. Plan: autoload `GameState` z `day`, `hour` i sygnałem `time_advanced`. Zob. [TDD](../06_techniczne.md#planowane-systemy).

## Otwarte pytania
- ❓ Jeden globalny termin (dostawa dla Kniazia?) czy osobne terminy dla questów?
- ❓ Co się dzieje po przekroczeniu terminu: porażka, gorsze zakończenie czy utrata questu?
- ❓ Czy gracz może nie wrócić na noc do obozu?
- ❓ Jak pokazać czas w świecie? [propozycja] Świeca w obozie, zegarek kieszonkowy dziadka.
