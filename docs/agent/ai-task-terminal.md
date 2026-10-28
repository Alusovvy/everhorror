# ai-task: tylko sesja terminalowa

Ten plik uzupełnia skill [`ai-task`](../../.claude/skills/ai-task/SKILL.md) o to, co robi wyłącznie sesja w terminalu (bez `EVERHORROR_DASHBOARD_RUN`). Przebieg z dashboardu go nie czyta: jego reguły są w [run-rules.md](run-rules.md). Zasady o strefach człowieka, wymaganiach zadania i blokadzie dashboardu obowiązują tak samo.

## Różnice wobec przebiegu z dashboardu
- **Pytania.** Można pytać Rolanda wprost (AskUserQuestion) zamiast pisać kartę decyzji; kartę i tak pisze się dla decyzji, które mają przetrwać sesję.
- **Commity w głównej kopii** tylko na wyraźną prośbę Rolanda (`[agent] proces: …`). Dokumenty gry zwykle zapisuje serwer dashboardu albo Roland przyciskiem „Zapisz dokumenty w historii gry”.
- **Zadania narzędziowe** idą teraz przebiegiem „Wdróż” w dashboardzie; terminal zostaje na prośbę Rolanda.

## Kopia gałęzi w terminalu
Przebieg z dashboardu dostaje kopię gotową. W terminalu: `git -C <gra> worktree add -b spec/<data>-task<NN> C:/dev/gamedev/everhorror/everhorror-wt/spec-<data>-task<NN> master`, potem skopiuj pamięć importu (`cp -r <gra>/.godot <kopia>/`) albo uruchom `godot --headless --path <kopia> --import`. Starsze gałęzie mogą stać w `everhorror-wdrozenie`; odłączona i czysta kopia: `git -C <kopia> switch <gałąź>`.

Build podglądu gałęzi (tylko do debugowania, nie do arkusza): po commicie na gałęzi `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts build task_NN` (około minuty; odmawia, gdy przebieg dashboardu trzyma blokadę). Build do oceny robi serwer raz na cykl z `master` (D-38): stan i powody czekania pokazuje `node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts cycle`, a `cycle build` robi go od razu. Część arkusza zadania piszesz w jego pliku (`## Część arkusza`), nigdy w `docs/human-tasks/`; arkusz cyklu i rejestr `BUILDY.md` pisze tylko serwer. Wydania nie robisz ręcznym stemplem na gałęzi zadania.

## Zadanie z czatu: zamknięcie pliku
Po wdrożeniu zadania spoza specyfikacji (bez gałęzi `spec/*`) przenieś plik zadania do `docs/ai-tasks/done/`: najpierw `git ls-files --error-unmatch docs/ai-tasks/task_NN.md` (plik spoza historii najpierw zapisz: przycisk Rolanda albo commit `[agent] proces`), potem `git mv`. Linki w cytowanych wymaganiach zostają bez zmian (np. `done/task_13.md`), pozostałe względne linki pliku dostają jedno `../`. Popraw linki przychodzące (link do zadania w nagłówku arkusza → `../ai-tasks/done/task_NN.md`). Zadanie specyfikacji zostaje w `docs/ai-tasks/` do scalenia gałęzi i `/spec-sync finalize`.

## status
Jedna linia na każdy `docs/ai-tasks/task_*.md` (bez `done/`): tytuł albo pierwsze wymaganie, źródło (specyfikacja albo czat; dla zadania ze specyfikacji jego gałąź i status w „W zadaniach”) i na co czeka: analizę; decyzję (otwarta karta z `Zadanie: task_NN` albo starszy `decision-task-NN.md`); inne zadanie („Kolejność”); wdrożenie; przegląd lub poprawki gałęzi; arkusz człowieka; zamknięcie. Wypisz też arkusze z wypełnioną kolumną `wynik` (gotowe do `close`) i stan cyklu (`cli.ts cycle`). Niczego nie zmieniaj.

## close NN
Zwykła droga to dashboard (Praca → arkusz): człowiek wypełnia go („Wypełnij arkusz”), potem „Zamknij arkusz” („Oddaj wyniki i zamknij cykl NN”: przenosi arkusz cyklu `factcheck-cykl-NN.md` do `done/`, zmienia wiersz rejestru na `stary` i zamyka cykl), albo zwalnia go („Zwolnij z testu”), każde to kliknięcie i jeden podpisany commit. Arkusza cyklu nie zamykasz z terminala. Ten tryb jest dla sesji terminalowej na prośbę Rolanda, nigdy dla przebiegu z dashboardu.
1. Przeczytaj `docs/human-tasks/factcheck-test-NN.md`: każdą komórkę `wynik`/`uwagi`.
2. Każdy błąd i każda propozycja trafia najpierw do specyfikacji: reguła ⬜ albo zgłoszenie w `zgloszenia/`. ❌ na wciąż otwartej gałęzi oznacza `fix NN`, nie nowy `task_NN.md`. Zapytaj Rolanda, co wybrać; niczego nie poprawiaj po cichu.
3. Gdy nic nie zostaje otwarte, `git mv` arkusza do `docs/human-tasks/done/` (po `git ls-files --error-unmatch`) i popraw jego względne linki.

Nigdy nie przenoś niewypełnionego arkusza bez zwolnienia Rolanda: linii `Zwolnienie:`, którą zapisuje dashboard po jego kliknięciu. Jeśli zwolni w czacie, zacytuj go w raporcie zadania (`Roland, czat <data>: …`), poproś o „Zwolnij z testu” i przenieś arkusz dopiero, gdy linia istnieje. Linii `Wyniki człowieka`, `Zwolnienie` i `Zamknięcie` nigdy nie piszesz.

Arkusz kilku zadań (`## Część: task_NN`) czyta się i zamyka w całości: liczy się komórka `wynik` każdej części, a zamykają się wszystkie jego zadania. Roland może też zamknąć niewypełniony arkusz w dashboardzie („Przenieś arkusz do done/” z potwierdzeniem): dashboard wpisuje wtedy `⏭ pominięte (zamknięcie bez wypełnienia)` w puste pola i linię `Zamknięcie: … pominięte N z M pól`. To zamknięcie bez pełnego sprawdzenia, nie zwolnienie; ⏭ nie jest dowodem i nigdy tego nie robisz sam.
