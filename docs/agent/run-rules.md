# Reguły przebiegu z dashboardu

To jedyna lista tego, co wolno w przebiegu uruchomionym z dashboardu. Kontrakt przebiegu dołącza ją do siebie, a skille i `CLAUDE.md` tylko na nią wskazują. Strażnik odrzuca niedozwolone polecenie bez pytania (odrzucone wywołanie to stracona tura, więc używaj form z tej listy), a audyt po przebiegu oznacza naruszenia i niczego nie cofa. Surowszy zapis w kontrakcie wygrywa z tym plikiem. `<spec>` to repozytorium specyfikacji, `<kopia>` to kopia gałęzi zadania (worktree), `<gra>` to główna kopia gry; prawdziwe ścieżki podaje kontrakt.

## 1. Gdzie wolno pisać
Korzenie zapisu obowiązują `Edit`, `Write`, `MultiEdit` i powłokę tak samo.

| Rodzaj | Zapis tylko w |
|---|---|
| planowanie | `<gra>/docs/ai-tasks/` i `<spec>` |
| analiza | własny plik zadania i `<spec>/zgloszenia/` |
| wdrożenie, poprawki | `<kopia>` (bez `.git`), własny plik zadania, własny arkusz w `<gra>/docs/human-tasks/` i `<spec>` |
| przegląd | `reports/` w `<kopia>` |
| domknięcie | `<spec>` (oraz przeniesienie własnego pliku zadania do `done/`, zob. kontrakt) |
| każdy rodzaj | `<gra>/reports/dashboard-runs/<id przebiegu>/tmp/`: folder roboczy na pliki tymczasowe, serwer kasuje go po audycie |

Nigdy: strefy człowieka (wyniki, oceny, uwagi i wybory w arkuszach i kartach, linie „Wyniki człowieka”, „Zwolnienie”, „Zamknięcie”), linia `> Build:` w nagłówku arkusza (ustawia ją serwer po buildzie), pliki cudzych zadań, `<spec>/dashboard/`, `.claude/`, `.github/`, `.git/`, `addons/`. Sekcja „Wymagania” zadania zostaje identyczna co do bajta. Głównej kopii gry nie przełączasz na inną gałąź i nie commitujesz w niej; dokumenty, które w niej zmieniasz, zostają niezatwierdzone (zapisze je serwer po czystym audycie).

## 2. Polecenia
- **Jedno polecenie na wywołanie.** Jedyny dozwolony łańcuch to `cd <kopia> && tools/run_tests.sh unit lint` (nazwy scenariuszy po spacji) oraz `cd <kopia> && C:/dev/gamedev/Godot_v4.7.2-stable_win64_console.exe --headless --path . --import`.
- Logi testów trafiają do `reports/tests/` kopii; czytaj linie `RESULT`. Nie przepuszczasz Godota przez `head` ani `grep`.
- Zawsze `git -C <pełna ścieżka> …`. Bez `git -c`, `bash -c`, `eval`, `node -e`, zmiennych środowiskowych i `$(…)`. Merge, rebase, reset, checkout, stash, clean, tag i force push są zablokowane; sieć, MCP, PowerShell, npm i npx też.
- Plików tymczasowych nie kładziesz w `%TEMP%` ani `/tmp`, tylko w `tmp/` przebiegu (punkt 1).

## 3. Specyfikacja: commity, księga, push
- Księgę `WDROZENIA.md` zmieniasz wyłącznie tak (polecenie samo commituje): `node <spec>/dashboard/cli.ts ledger <operacja> … --message "[agent] …"`. Operacje: `node <spec>/dashboard/cli.ts ledger help`.
- Inne pliki specyfikacji commitujesz tylko po lincie z 0 błędów (`node <spec>/dashboard/cli.ts lint`) i tak: `node <spec>/dashboard/cli.ts commit --message "[agent] …" -- <plik> […]`. Pliki wymieniasz jawnie, nigdy folderu ani `WDROZENIA.md`. `git add` i `git commit` w specyfikacji są zablokowane.
- Push specyfikacji: `git -C <spec> push everhorror-spec master`. Prawdziwa nazwa zdalnego repozytorium to `everhorror-spec`, kontrakt podaje ją wprost; bez `--force`. Gry (`<gra>`) nie wypychasz.
- Karty i zgłoszenia w `zgloszenia/` edytujesz przez `Edit` i `Write`; nie przenosisz ich (`git mv`, `mv`, `cp`, `rm` są zablokowane).

## 4. `node`
- Planowanie, analiza, przegląd i domknięcie uruchamiają tylko `<spec>/dashboard/cli.ts` oraz śledzone, niezmienione `tools/*.js` z `<gra>`.
- Wdrożenie i poprawki mogą dodatkowo uruchamiać skrypty z własnej `<kopia>` (testy, generatory).
- Scalenie, push gry, przełącznik scalania automatycznego, wydanie i odrzucenie wymagają sekretu administratora, którego przebieg nie ma i nie szuka.

## 5. Czego nie robisz ręcznie
- Nie eksportujesz, nie pakujesz i nie stemplujesz gry (`tools/release/stamp_build.js` odpada). Serwer sam uruchamia testy po wdrożeniu i poprawkach, robi build do ogrania i zapisuje dokumenty gry po czystym audycie.
- Po wdrożeniu i poprawkach serwer sam uruchamia `unit lint dialogue` oraz scenariusze z sekcji „Test” pliku zadania i zapisuje wynik w przebiegu (pełny zestaw na serwerze: `EVERHORROR_SERVER_TESTS=full`). Ty uruchamiasz w trakcie pracy tylko scenariusze, których potrzebujesz; pełnego zestawu nie uruchamiasz, chyba że kontrakt mówi „user approved full suite”.
- Nie ma pytań w trakcie: gdy Roland musi coś rozstrzygnąć, piszesz kartę decyzji (D-03) w `<spec>/zgloszenia/` i kończysz `STATUS: czeka-na-decyzje`. Analiza zostawia w sekcji Plan pliku zadania linię `Plan zależy od wyboru: tak|nie`. Po odpowiedzi serwer sam dopisuje do pliku zadania sekcję `## Decyzje z karty <plik>` (przy „tak” krótki przebieg uaktualnia Plan); ta sekcja jest wiążąca dla kolejnych przebiegów i nie jest wznowieniem rozmowy.

## 6. Zakończenie
Trzy linie po polsku, nic po nich: `STATUS: ok|czeka-na-decyzje|blad`, `ZROBIONE: <jedno zdanie>`, `NASTĘPNY KROK: <co robi człowiek albo następny przebieg>`. Przegląd kończy się wyłącznie obiektem JSON z werdyktem (bez linii `STATUS`).
