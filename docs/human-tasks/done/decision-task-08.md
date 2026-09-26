# Decyzje do task 08: obóz jako jaskinia

> Zadanie: [task_08](../../ai-tasks/done/task_08.md) · Przygotowano: 2026-09-26
> **Status: rozstrzygnięte 2026-09-26** (odpowiedzi w czacie, wszystkie zgodne z rekomendacją). Prace ruszyły.

## Stan obecny (z przeglądu i zrzutów)
- Obóz to **długi, niski korytarz**: ok. 32 × 9,5 m, strop na ok. 4 m.
- **Wszystko jest z desek**: 85 ścian kopalnianych obitych deskami, drewniany strop, 32 panele i **110 słupów z zastrzałami**, które zjadają przestrzeń.
- **Szyny biegną przez środek** obozu, z wózkami między stołem a posłaniami.
- Hala leży w ręcznie edytowanej kopii poziomu z zestawu (`mine.tscn`), a rekwizyty i postacie ustawia generator (`gen_camp.gd`).
- Zestaw kopalni ma elementy jaskini (skalne ściany, filary, reliefy, podłoże jaskini), więc przebudowa nie wymaga nowych modeli.

## Decyzje

| # | Pytanie | Opcje | Rekomendacja | Twój wybór |
|---|---|---|---|---|
| 1 | **Skala przebudowy** | **A.** Nowa jaskinia w miejscu hali, zbudowana przez generator: skalne ściany, wyższe sklepienie, drewno tylko jako konstrukcje (zagroda, rusztowania, podesty, odrzwia przy wyjściach). Wyjścia na wschód i zachód oraz korytarz do starego wejścia zostają w tych samych miejscach. **B.** Szybka przeróbka: w obecnym obrysie wymienić deski na skałę i usunąć część słupów. Taniej, ale obóz dalej ma 9,5 m szerokości | **A**: tylko tak obóz przestaje być korytarzem | ✅ **A** (2026-09-26) |
| 2 | **Wielkość** | **a)** ok. 16 × 32 m, sklepienie ok. 6 m (1,7× więcej podłogi). **b)** ok. 20 × 36 m, sklepienie ok. 7–8 m (2,4× więcej). **c)** szerokość bez zmian, tylko wyżej | **a)**: wyraźnie przestronniej, a dalej do przejścia w kilkanaście sekund. Przy **b)** obóz robi się pusty i trzeba by dosypać rekwizytów | ✅ **a)** 16 × 32 m, sklepienie 6 m (2026-09-26) |
| 3 | **Kwatera Racibora** (dziś za drewnianą ścianką) | **a)** drewniana zagroda bez dachu (palisada ok. 2 m z wejściem) w jaskini: wstęp i dialogi mówią „za drewnianą ścianką”, więc teksty zostają. **b)** skalna wnęka zasłonięta płachtą | **a)**: kontrast drewna i skały, zero zmian w tekstach | ✅ **a)** drewniana zagroda (2026-09-26) |
| 4 | **Szyny i wózki** | **a)** zostaje jeden tor od wyjścia wschodniego do magazynu, z wózkami z urobkiem (przy nich pracują Bolko i Dobrawa). **b)** wszystko zostaje. **c)** usunąć wszystko | **a)**: ślad dawnej kopalni zostaje, środek obozu robi się wolny | ✅ **a)** jeden tor do magazynu (2026-09-26) |
| 5 | **Układ stref** | **a)** te same strefy w tej samej kolejności (zachód: posłania, kuchnia, magazyn, proch, izba chorych; wschód: dowódca, zaopatrzenie, pisarz), tylko luźniej, a ognisko w środku jako serce obozu. **b)** nowy układ od zera | **a)**: na tym układzie stoją teksty, rozkłady dnia i testy. Nowy układ to dużo pracy bez zysku dla gracza | ✅ **a)** te same strefy, luźniej (2026-09-26) |

## Czego nie trzeba decydować (zrobię tak)
- **Weryfikacja ustawienia postaci** (wymaganie z task_08): każdy znacznik NPC sprawdzę skryptem (czy stoi na podłodze, jest poziomo, nie wchodzi w rekwizyt ani w ścianę, patrzy w sensowną stronę) i na zrzutach z oczu gracza w kilku porach dnia. Test `schedule` pilnuje, żeby nikt nie stał na cudzym miejscu.
- **Nazwy węzłów** zostają (stół z mapą, posłanie, ognisko, siedzisko), więc zapisy, testy i dialogi działają bez zmian.
- Po przebudowie: pełny zestaw testów w porcjach, test chodzenia z punktu startu do każdego wyjścia i zrzuty. Build tylko na Twoją prośbę.
