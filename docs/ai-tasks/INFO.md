This is an AI task folder, where I give you task as .md file, I give you requierments, and you can give me feedback what you did and what you might need from me. I require to keep section requierments as what I wrote, and I want to have summary in the end, if you need you can add some secitons. If tasks include some implementation aspect, then in folder human-tasks (create it if does not exists) you create me a factcheck-test-XX.md where you list what was added and I test it and list you results with bugs/changes propositions.

## Foldery
- Szablon zadania: [task_template.md](task_template.md).
- Zadania wykonane przechodzą do `ai-tasks/done/`, a ich arkusze do `human-tasks/done/`, gdy są wypełnione (od 2026-09-26). Główne foldery zawierają tylko to, co otwarte: zadania w toku albo czekające i arkusze do wypełnienia. Spis zrobionych zadań jest niżej w [Historii](#historia).

## Dashboard (2026-10-26)

Od 2026-10-26 Roland prowadzi zadania z dashboardu specyfikacji (widok **Praca**); obsługę klik po kliku opisuje [instrukcja dashboardu](../../../specification/dashboard/INSTRUKCJA.md). Zasady powyżej obowiązują z trzema poprawkami: decyzje to karty D-03 w specyfikacji (`zgloszenia/`), a nie pliki w `human-tasks/`; arkusze powstają z szablonów (`factcheck_template.md`, `playtest_template.md`); arkusze leżą w głównej kopii gry, nigdy na gałęzi `spec/*`.

- **Gdzie co leży.**
  - Zadania zostają tutaj, w `docs/ai-tasks/` (zrobione w `done/`). Arkusze dla człowieka leżą w `docs/human-tasks/` głównej kopii gry; zasady: [human-tasks/INFO.md](../human-tasks/INFO.md). Stare `decision-task-NN.md` w `human-tasks/done/` to historia.
  - Rejestrem zadań jest nadal `WDROZENIA.md` w specyfikacji. Dashboard nie ma własnej bazy: stan liczy z tych plików, z gita i z zapisów przebiegów agenta w `reports/dashboard-runs/` (poza gitem).
- **Kto co pisze.**
  - Wymagania zadania: Roland. Agent nie zmienia ich ani o bajt (pilnuje tego hook i audyt przebiegu).
  - Sekcje pod wymaganiami (analiza, raport, poprawki, podsumowanie): agent.
  - Pola człowieka w arkuszach: tylko człowiek. Co dokładnie nim jest, definiuje jedno miejsce: [Strefy człowieka](../human-tasks/INFO.md#strefy-człowieka). Każdy zapis z dashboardu to osobny commit tego jednego pliku, z podpisem osoby, która wpisuje (autor, committer i `Wpisał-Człowiek`).
- **Statusy zadania** (tablica Praca): Zaplanowane, Czeka na decyzję, W pracy, Na gałęzi (🧪), Scalone — do domknięcia, Czeka na człowieka, Sprawdzone albo Zamknięte, Odrzucone; Niespójne, gdy pliki i `WDROZENIA.md` się rozjeżdżają.
- **Rozgrywka zaczyna się w specyfikacji.** Prośba o nową mechanikę, postać albo tekst najpierw trafia do specyfikacji jako reguła ⬜, a zadanie z niej robi `/spec-tasks` (z linią `Źródło: specyfikacja`). Formularz „Nowe zadanie narzędziowe” (`/praca/nowe`) służy tylko do narzędzi i dokumentacji: zapisuje słowa Rolanda dosłownie w wymaganiach i dodaje linię `Rodzaj: narzędzia` albo `dokumentacja`. Takie zadania wdrażamy na razie w terminalu (`/ai-task`), nie z dashboardu.

## Historia

Zrobione zadania leżą w [done/](done/). Co zmieniło się w której wersji gry, mówi [CHANGELOG.md](../../CHANGELOG.md); zadania 01, 02 i 07 opisują same pliki. Arkusze: [human-tasks/done/](../human-tasks/done/).

| Zadanie | Temat | Wersja gry | Arkusz |
|---|---|---|---|
| [task_01](done/task_01.md) | rozbudowa kopalni z istniejących zasobów, światło i dźwięk, przegląd darmowych zasobów | przed 0.1 (brak wpisu w CHANGELOG) | [factcheck-test-01](../human-tasks/done/factcheck-test-01.md) |
| [task_02](done/task_02.md) | szablon zadania, plan automatycznego buildu z ogłoszeniem na Discordzie, logo w menu | przed 0.1 (brak wpisu w CHANGELOG) | [factcheck-test-02](../human-tasks/done/factcheck-test-02.md) |
| [task_03](done/task_03.md) | pierwszy grywalny kawałek: stan gry i czas, rozmowy VN, pierwsze postacie, noc i sen | 0.1 | [factcheck-test-03](../human-tasks/done/factcheck-test-03.md) |
| [task_04](done/task_04.md) | większy obóz, trzy nowe postacie i miejsca, ściana z zagadką, trzy dni | 0.2 | [factcheck-test-04](../human-tasks/done/factcheck-test-04.md) |
| [task_05](done/task_05.md) | tydzień zamiast trzech dni, ekwipunek, stół z mapą i wyprawy, dziewięć postaci | 0.3 | [factcheck-test-05](../human-tasks/done/factcheck-test-05.md) |
| [task_06](done/task_06.md) | plan usprawnień dema: wieczory przy ognisku, „Czternaście kresek”, autozapis, opcje dźwięku i jasności | 0.4 (drobne poprawki: 0.4.1) | [factcheck-test-06](../human-tasks/done/factcheck-test-06.md) |
| [task_07](done/task_07.md) | jakość testowania: nowe warstwy testów i serwer MCP do sterowania grą | bez zmian w grze | [factcheck-test-07](../human-tasks/done/factcheck-test-07.md) |
| [task_08](done/task_08.md) | obóz przebudowany na naturalną jaskinię | 0.5 | [factcheck-test-08](../human-tasks/done/factcheck-test-08.md) (decyzje: [decision-task-08](../human-tasks/done/decision-task-08.md)) |
| [task_09](done/task_09.md) | Hrapek i „Ryba dla Hrapka”, dziennik czasu w notesie, wyszarzone opcje, rozmowa 5 min za opcję | 0.5 | [factcheck-test-09](../human-tasks/done/factcheck-test-09.md) (decyzje: [decision-task-09](../human-tasks/done/decision-task-09.md)) |
| [task_10](done/task_10.md) | pierwszy dzień: w obozie tylko cztery osoby, reszta na szychcie | 0.5.1 | [factcheck-test-10](../human-tasks/done/factcheck-test-10.md) (decyzje: [decision-task-10](../human-tasks/done/decision-task-10.md)) |
| [task_11](done/task_11.md) | dialogi dopasowane do pierwszego spotkania, powtórzona opcja nic nie kosztuje | 0.5.1 | [factcheck-test-11](../human-tasks/done/factcheck-test-11.md) (decyzje: [decision-task-11](../human-tasks/done/decision-task-11.md)) |
| [task_12](done/task_12.md) | zmęczenie bohatera i powrót do obozu za połowę czasu | 0.5.1 | [factcheck-test-12](../human-tasks/done/factcheck-test-12.md) (decyzje: [decision-task-12](../human-tasks/done/decision-task-12.md)) |
| [task_13](done/task_13.md) | sny po odszyfrowaniu, kreski w nocy 7, ryba bez pomp i bandaż dla Wszebora | 0.5.2 | [factcheck-test-13](../human-tasks/done/factcheck-test-13.md) |
| [task_14](done/task_14.md) | poprawki, numer wersji w menu, raport przebiegu i bot balansu | 0.5.3 (tag `v0.5.3`) | [factcheck-test-14](../human-tasks/factcheck-test-14.md), sesja PT0, część A (otwarty) |
| [task_15](done/task_15.md) | orkiestracja zadań i arkuszy z dashboardu (zadanie narzędziowe) | bez zmian w grze | część B arkusza [factcheck-test-14](../human-tasks/factcheck-test-14.md) (otwarty); wcześniejszy [factcheck-test-15](../human-tasks/done/factcheck-test-15.md) jest zastąpiony |

Starsze raporty wspominają folder `docs_v2/`. Został usunięty w `bc68d01` (ostatnia treść: `git show 10074fc:docs_v2/<plik>`), a jego treści trafiły do specyfikacji; mapa „co gdzie trafiło” jest w [WORKFLOW.md#starsze-źródła](../../../specification/WORKFLOW.md#starsze-źródła) (np. `docs_v2/swiat/loredoc_niespojnosci.md` z [task_04](done/task_04.md) to dziś `01_swiat/niespojnosci_loredoc.md`).
