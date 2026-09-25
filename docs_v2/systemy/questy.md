# Questy i notes

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 1, 2, 3

## Cel
Dać graczowi pamięć tego, co obiecał, co wie i co mu ucieka, bez prowadzenia za rękę.

## Zasady
1. **Prosty notes z zapiskami questów** **[GDD]**.
2. [propozycja] Wpis zawiera: tytuł, zleceniodawcę (NPC), stan (*aktywny / ukończony / nieudany*), notatki dopisywane w miarę postępu i ewentualny termin.
3. [propozycja] Notes pisze bohater w pierwszej osobie, w tonie świata („Mirosław prosił, żebym…”), a nie jak lista zadań w grze RPG.
4. [propozycja] W notesie są też **znalezione notatki dziadka i dowódcy poprzedniej ekipy**. To jedno miejsce na całą wiedzę gracza.
5. Questy NPC nagradzają informacją, przedmiotem albo reputacją **[GDD]**.
6. Linie questów prowadzą do złożonych zakończeń (np. Drudzy na dnie kopalni) **[GDD]**.

## Zależności
[NPC](npc.md), [Czas](czas.md) (terminy), [Dialogi](dialogi_vn.md) (efekt: dodaj lub aktualizuj quest), [Fabuła](../swiat/fabula.md).

## Przypadki brzegowe
- Zleceniodawca ginie → quest „nieudany” z wpisem wyjaśniającym.
- Termin mija → „nieudany” albo inna konsekwencja (❓ zob. [Czas](czas.md)).

## Implementacja
⬜ Plan: `QuestData` (`Resource`) + stan questów w `GameState` + ekran notesu (np. pod klawiszem [J] albo [Tab]).

## Otwarte pytania
- ❓ Klawisz i forma notesu: przedmiot w świecie (bohater wyciąga notes) czy ekran UI?
