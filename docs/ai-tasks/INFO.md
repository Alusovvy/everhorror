This is an AI task folder, where I give you task as .md file, I give you requierments, and you can give me feedback what you did and what you might need from me. I require to keep section requierments as what I wrote, and I want to have summary in the end, if you need you can add some secitons. If tasks include some implementation aspect, then in folder human-tasks (create it if does not exists) you create me a factcheck-test-XX.md where you list what was added and I test it and list you results with bugs/changes propositions.

Done folders (added 2026-09-26): implemented tasks move to `ai-tasks/done/`; their factchecks move to `human-tasks/done/` once filled in, and decision files once resolved. The main folders keep only work that is still open (tasks in progress or waiting, factchecks to fill in, decisions to make).

## Dashboard (2026-10-26)

Od 2026-10-26 Roland prowadzi zadania z dashboardu specyfikacji (widok **Praca**). Zasady powyżej obowiązują bez zmian.

- **Gdzie co leży.**
  - Zadania zostają tutaj, w `docs/ai-tasks/` (zrobione w `done/`). Arkusze dla człowieka leżą w `docs/human-tasks/` **głównej kopii gry**, nigdy na gałęzi `spec/*`; zasady: [human-tasks/INFO.md](../human-tasks/INFO.md). Decyzje to karty w specyfikacji (`zgloszenia/`); stare `decision-task-NN.md` w `human-tasks/done/` to historia.
  - Rejestrem zadań jest nadal `WDROZENIA.md` w specyfikacji. Dashboard nie ma własnej bazy: stan liczy z tych plików, z gita i z zapisów przebiegów agenta w `reports/dashboard-runs/` (poza gitem).
- **Kto co pisze.**
  - Wymagania zadania: Roland. Agent nie zmienia ich ani o bajt (pilnuje tego hook i audyt przebiegu).
  - Sekcje pod wymaganiami (analiza, raport, poprawki, podsumowanie): agent.
  - Pola człowieka w arkuszach (kolumny `wynik`, `uwagi`, `ocena`, wybory, odpowiedzi, linie `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`): tylko człowiek. Każdy zapis z dashboardu to osobny commit tego jednego pliku, podpisany przez zapisującego (autor, committer i `Wpisał-Człowiek`).
- **Statusy zadania** (tablica Praca): Zaplanowane, Czeka na decyzję, W pracy, Na gałęzi (🧪), Scalone — do domknięcia, Czeka na człowieka, Sprawdzone albo Zamknięte, Odrzucone; Niespójne, gdy pliki i `WDROZENIA.md` się rozjeżdżają.
- **Rozgrywka zaczyna się w specyfikacji.** Prośba o nową mechanikę, postać albo tekst najpierw trafia do specyfikacji jako reguła ⬜, a zadanie z niej robi `/spec-tasks` (z linią `Źródło: specyfikacja`). Formularz „Nowe zadanie narzędziowe” (`/praca/nowe`) służy tylko do narzędzi i dokumentacji: zapisuje słowa Rolanda dosłownie w wymaganiach i dodaje linię `Rodzaj: narzędzia` albo `dokumentacja`.
