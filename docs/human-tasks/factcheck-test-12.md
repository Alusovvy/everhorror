# Factcheck test 12: zmęczenie i powrót za połowę drogi

> Zadanie: [task_12](../ai-tasks/done/task_12.md) · Decyzje: [decision-task-12](done/decision-task-12.md) · Przygotowano: 2026-09-26 · Czas: ~30 min
> Graj z edytora (F5). Najszybciej: nowa gra, dzień 1 i 2 z dalekimi wyprawami (sztolnia → wyrobisko → grota), potem noc.

## Co się zmieniło
- **Powrót do obozu** kosztuje zawsze **połowę drogi**, którą przeszedłeś od wyjścia z obozu:
  - bez rozpoznania i bez czasu spędzonego na miejscu,
  - w górę do 5 minut,
  - przykład: obóz → sztolnia (2 h) → wyrobisko (1 h) = 3 h drogi, powrót 1 h 30 min (wcześniej 3 h).
- **Zmęczenie bohatera** (0–100%, tylko słowami):
  - rośnie o 8% za godzinę w tunelach i o 2% za godzinę w obozie,
  - sen zdejmuje 60%, a wieczór przy ognisku 15%,
  - od 75% w rogu ekranu i w plecaku pojawia się „zmęczony”, od 90% „ledwo idziesz”, przy 100% „padasz z nóg”,
  - przy 100% każda droga w głąb trwa **dwa razy dłużej** (powrót nigdy), a mapa dopisuje „· zmęczenie ×2”.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Powrót za połowę | Obóz → Stara sztolnia → [M] Stare wyrobisko → [M] Obóz | Mapa przy „Obóz” pokazuje 1 h 30 min i opis „połowa tego, co przeszedłeś”. Zegar po powrocie się zgadza | | |
| 2 | Kluczenie | Sztolnia → Kaplica → z powrotem do sztolni → wyrobisko → obóz | Powrót dłuższy niż przy prostej trasie (liczy się każdy odcinek) | | |
| 3 | Rozpoznanie się nie liczy | Pierwsza wizyta w nowym miejscu (+1 h rozpoznania), potem powrót | Powrót to połowa samej drogi, bez godziny rozpoznania | | |
| 4 | Brak zmęczenia na starcie | Nowa gra, [I] | W plecaku nie ma zdania o zmęczeniu, w rogu ekranu nic | | |
| 5 | Narastanie | Dzień 1 dwie długie wyprawy (ok. 10 h w tunelach) | Pod koniec dnia w rogu ekranu „zmęczony” (od ok. 9–10 h w tunelach), w plecaku zdanie o zmęczeniu | | |
| 6 | Ognisko | Po 20:00 usiądź przy ognisku | Zmęczenie trochę spada (np. „ledwo idziesz” → „zmęczony”) | | |
| 7 | Sen | Prześpij noc | Rano zmęczenie wyraźnie mniejsze, zwykle bez słowa w rogu | | |
| 8 | 100% i ×2 | Kilka długich dni z rzędu, aż w rogu pojawi się „padasz z nóg” | Mapa: „· zmęczenie ×2” przy miejscach, w opisie „każdy odcinek idziesz dwa razy dłużej”, czas drogi podwojony | | |
| 9 | Powrót przy 100% | Przy „padasz z nóg” wróć do obozu | Powrót dalej to połowa drogi, bez podwojenia | | |
| 10 | Rana + zmęczenie | Ranny i przy 100% | Droga ×2, a potem +1 h za odcinek z powodu ran | | |
| 11 | Zapis | Zapisz przy „zmęczony”, wczytaj | Dalej „zmęczony” | | |
| 12 | Balans | Twoje odczucie po 2–3 dniach | Czy powrót za połowę nie ułatwia za bardzo? Czy zmęczenie jest odczuwalne, ale nie blokuje normy? | | |
