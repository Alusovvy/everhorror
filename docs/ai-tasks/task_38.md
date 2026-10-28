# task_38: Jeden arkusz i jeden build na cykl oceny, rejestr buildów

<!--
Zadanie narzędziowe z czatu Rolanda (2026-10-28, sesja koordynatora Fable 5.1). Sekcja „Wymagania” to słowa Rolanda i potwierdzone przez niego streszczenie; nie edytować. Zasady: INFO.md.
-->

Wymagania:
Roland, czat 2026-10-28 (dosłownie):
„I want a change to be made that factchecks are appended so I only have one factcheck sheet to review and builds are also appended when tasks are being made. Then when I give feedback from factcheck from which we will build new tasks, you put existing build as old one, and start tasks as for the new build, including fixes or new features or changes, doesn't matter, new build is made when factcheck is done and feedback retuern.”

Streszczenie koordynatora potwierdzone przez Rolanda („Dobra, to jedziesz.”):
1. Arkusz factcheck jest jeden, wspólny: każde wdrażane zadanie dopisuje swoją część na końcu tego samego otwartego arkusza; do oddania wyników Roland ma do przejrzenia dokładnie jeden plik.
2. Build też jest jeden, wspólny: kolejne scalone zadania nie dostają osobnych buildów; jest jeden bieżący build, który obejmuje wszystko od ostatniej oceny Rolanda, i na nim sprawdza się cały wspólny arkusz.
3. Ocena Rolanda zamyka cykl: po wypełnieniu arkusza i oddaniu wyników (❌, 💬, nowe prośby) z tego feedbacku powstają nowe zadania: poprawki, zmiany, nowe funkcje, bez znaczenia jakiego rodzaju.
4. Przełączenie na nowy cykl: dotychczasowy build i jego arkusz stają się „stare” (zamknięte, zostają jako historia), a nowe zadania są od razu przypisane do następnego buildu i następnego wspólnego arkusza.
5. Nowy build powstaje dopiero wtedy, gdy poprzedni factcheck jest skończony, feedback wrócił, a zadania z tego feedbacku są wdrożone i scalone; wtedy dashboard robi jeden nowy build, otwiera jeden nowy arkusz z częściami wszystkich tych zadań i cykl zaczyna się od nowa.
Założenia przyjęte przez koordynatora (Roland nie zaprzeczył): (a) zadania poziomu „tekst” i „narzędzia” nadal nie dodają wierszy do arkusza, ale wchodzą do wspólnego buildu; (b) scalanie zadania do `master` zostaje jak dziś (przegląd + testy), tylko build i arkusz przestają być „na zadanie”, a stają się „na cykl”.

Roland, czat 2026-10-28 (dosłownie, uzupełnienie):
„Tak, warto tez trzymać .md file ktory bedzie miał numery buildów z ich tymi hasszhami czy co to tam jest za kod w rogu, i liste zmian/tasków ktore weszly. Dobra, to jedziesz.”

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-28)
Poziom: narzędzia

Kontekst:
Dziś arkusz i build są „na zadanie” (D-27 dopuszcza dopisywanie części do otwartego arkusza, D-32 wiąże arkusz z buildem gałęzi). Po dzisiejszych scaleniach (task_20, 22, 25, 37) Roland ma trzy arkusze (`factcheck-build-333b147`, `-b250ebb`, `-368ac18`) i kilka buildów, a część wierszy sprawdził na buildzie, który nie zawierał zmiany. Kod w rogu menu to `BuildInfo.label()` („wersja · spec sha7”), a nazwa ZIP-a niesie sha7 commita gry.

Kryteria akceptacji:
1. W danym momencie istnieje najwyżej jeden otwarty arkusz factcheck; wdrożenia dopisują do niego części (także te uruchamiane z dashboardu), zamiast zakładać nowe pliki.
2. Build do ogrania jest jeden na cykl: powstaje z `master` po scaleniu zadań cyklu, a nie po każdym zadaniu; dashboard i arkusz wskazują ten sam, bieżący build.
3. Oddanie wyników arkusza przez Rolanda zamyka cykl: arkusz i build dostają status „stary” (historia), a zadania z feedbacku (poprawki, zmiany, nowe funkcje) są przypisane do następnego cyklu; następny build i następny arkusz powstają po ich scaleniu.
4. Plik `.md` w repozytorium gry z rejestrem buildów: numer buildu, kod z rogu menu (wersja · spec sha7) i sha7 gry, data, lista zadań i zmian, które weszły, stan (bieżący / stary) i link do arkusza; dashboard uzupełnia go sam.
5. Dokumentacja i skille (`docs/human-tasks/INFO.md`, `docs/ai-tasks/INFO.md`, `.claude/skills/ai-task`, `spec-sync`, dashboard `INSTRUKCJA.md`, plan §9: nowa decyzja) opisują cykl zamiast „arkusz na build zadania”.

Priorytet: wysoki

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->
