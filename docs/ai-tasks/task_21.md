# task_21: Porządek repozytorium i licencje w HEAD

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
„Wprowadz propozycje Fable, nastepnie odswiez dokumentacje.” (Roland, czat 2026-10-27)
Propozycje: K1, K8, D1 (część bez przepisywania historii) z analizy projektu (kontekst poniżej).

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

Kontekst:
Źródło: przegląd projektu `docs/analizy/propozycje-projekt.md` (agent Fable 5.1, tylko odczyt, 2026-10-27). Ten plik zostaje usunięty po przeniesieniu propozycji do planu i zadań, więc cała treść potrzebna wykonawcy jest tutaj. Numery linii pochodzą z 2026-10-27 i mogą się przesunąć. Zadanie nie zmienia rozgrywki (tylko usuwa nieużywane rzeczy i porządkuje pliki), więc nie wymaga reguły ⬜ w specyfikacji. Etap planu: „można teraz” (K1, K8), pierwsza część D1 teraz, reszta przy etapie 5 i 9. Koszt razem: S (około godziny pracy).

1. **K1. Beehave i Phantom Camera nie są używane, a jadą w buildzie.**
   - *Problem.* Wyszukiwanie po `script/` i `scene/` nie znajduje żadnego `Beehave*` ani `PhantomCamera*`. Oba dodatki mają autoloady (`BeehaveGlobalMetrics`, `BeehaveGlobalDebugger`, `PhantomCameraManager`; `project.godot` sekcja `[autoload]`, `docs/agent/README.md` tabela „Addons”), które startują w każdym eksporcie, a `export_presets.cfg` (linia `exclude_filter`) wyklucza tylko `addons/gdUnit4/*`. GdUnit4 jest „installed for editor-side authoring only” i też nie ma żadnych testów (zestaw agenta to skrypty z linią `RESULT` w `tools/`). `addons/godot_mcp` (autor `hybridindie`, wersja 2026.09.23, autoload `MCPRuntimeProbe`) nie ma pliku LICENSE, choć leży w publicznym repozytorium; pozostałe dodatki mają LICENSE.
   - *Propozycja.* Usunąć Beehave i Phantom Camera: foldery `addons/beehave`, `addons/phantom_camera`, ich wpisy w `[editor_plugins]` i `[autoload]` w `project.godot` (obie listy trzeba utrzymywać razem; `_enable_plugin()` działa tylko po przełączeniu w edytorze). Zdecydować o GdUnit4: usunąć albo zacząć używać (rekomendacja analizy: usunąć, bo nie ma testów, a jego CLI ściga się z pamięcią podręczną importu, więc nie wejdzie do `run_tests.sh`; jeśli decyzja nie jest oczywista, wykonawca zgłasza ją Rolandowi zamiast zgadywać). Dla `godot_mcp` ustalić licencję w upstreamie: wkleić jej tekst jako `addons/godot_mcp/LICENSE` (dodanie pliku licencji nie jest edycją kodu dodatku) i zapisać ją w rejestrze zasobów `06_oprawa.md` (specyfikacja: wpis zgłasza wykonawca w raporcie, Roland albo `/spec-tasks` zatwierdza), albo wykluczyć folder z eksportu i z repozytorium (`.gitignore`) i zostawić go lokalnie. Nie wymyślać licencji: jeśli upstream jej nie podaje, to decyzja Rolanda.
   - *Test.* `--import`, potem `unit lint dialogue day1`.
   - *Koszt:* S. *Priorytet analizy:* wysoki (etap 9, ale można teraz). Zasada „bez nowych integracji” (plan §5) nie zakazuje usuwania.

2. **K8. Martwe pliki w repozytorium.**
   - *Problem.* `tools/_ui_shot_tmp.gd` jest opisany jako „throwaway script (kept in the repo)” (`tools/README.md`, sekcja Screenshots); `tools/interact_test.gd` i `tools/nav_walk_test.gd` leżą poza `run_tests.sh`; `script/visual_interaction.gd` i scena `scene/visual_interaction/visual_interaction.tscn` to nieużywany prototyp (zastąpił go balon VN; `docs/agent/README.md` wspomina o nim w „Systems”); `assets/Sewer` jest nieużywany i bez licencji (`06_oprawa.md:29`), `assets/pics/sample-pic.jpg` też (`06_oprawa.md:32`). Repozytorium ma około 142 MB w `.git` przy 259 MB zasobów, bez LFS (`.gitattributes` ustawia tylko końce linii).
   - *Propozycja.* Usunąć z HEAD: `assets/Sewer` (razem z wpisem `assets/Sewer/*` w `exclude_filter` i z uwagami w `tools/README.md` i `docs/agent/README.md`), `assets/pics/sample-pic.jpg` (z plikiem `.import`; sprawdzić, czy `assets/pics` zostaje puste), `script/visual_interaction.*` i `scene/visual_interaction/`. `interact_test` i `nav_walk_test`: włączyć do `tools/run_tests.sh` jako scenariusze (z wpisem w tabeli `tools/README.md`) **albo** skasować; wykonawca wybiera jedno po sprawdzeniu, czy testy w ogóle jeszcze przechodzą (uwaga: task_16 poprawia cel w `interact_test.gd:7`, więc to zadanie powinno iść po task_16 albo po nim scalić zmianę). `tools/_ui_shot_tmp.gd` przemianować na `tools/ui_shots.gd` (razem z plikiem `.uid`), opisać w `tools/README.md` jako narzędzie, nie „throwaway”.
   - *Koszt:* S. *Priorytet analizy:* niski–średni (brak licencji Sewer podnosi go, zob. D1).

3. **D1 (część bez przepisywania historii). Publiczne repozytorium już rozpowszechnia pliki bez licencji.**
   - *Problem.* Zdalne repozytorium to `github.com/Alusovvy/everhorror`; plan nazywa je publicznym (`final-plan-human-readable.md:511`, D-29; widoczności w GitHubie nie sprawdzono). W HEAD leżą: `assets/Sewer` (brak pliku licencji), `assets/sounds/cave_ambient.mp3` i `steps.mp3` (oba w buildzie), `assets/pics/sample-pic.jpg`, `assets/logo.png` („EVEROLD”, `06_oprawa.md:29–33,42,52`) oraz `addons/godot_mcp` bez LICENSE. D-10 i D-21 planują porządek „przed demem publicznym”, ale rozpowszechnianie trwa od pierwszego pusha.
   - *Propozycja na teraz.* Usunąć `Sewer` i `sample-pic.jpg` z HEAD (pkt 2), rozstrzygnąć `godot_mcp` (pkt 1). Logo zostaje do decyzji D-21 (warto wiedzieć, że jest publiczne). Wymiana obu plików `.mp3` na nagrania CC0 to etap 5 (D-10), nie to zadanie.
   - *Koszt:* S. *Priorytet analizy:* wysoki.

Kryteria akceptacji:
- Po zmianach `--import` kończy się bez błędów i ostrzeżeń o brakujących zasobach; `unit lint dialogue day1` przechodzą. Gra startuje w menu (krótki test uruchomienia, np. `day1`).
- `project.godot` nie zawiera autoloadów ani wtyczek usuniętych dodatków; `grep` po repozytorium (poza `docs/archiwum/`, `docs/analizy/` i historią) nie znajduje `Beehave`, `PhantomCamera`, `Sewer`, `sample-pic`, `visual_interaction`, `_ui_shot_tmp`.
- Decyzja o GdUnit4 jest wykonana albo zgłoszona Rolandowi z jednym zdaniem rekomendacji; tabela „Addons” w `docs/agent/README.md` odpowiada folderowi `addons/`.
- `addons/godot_mcp` ma albo prawdziwy plik LICENSE z upstreamu (z podanym adresem źródła w raporcie), albo jest wykluczony z repozytorium i eksportu; w raporcie jest dokładne zdanie, co wpisać w `06_oprawa.md`.
- `interact_test` i `nav_walk_test` są albo w `run_tests.sh` i tabeli `tools/README.md` (przechodzą), albo usunięte razem z wpisem w README. `tools/ui_shots.gd` działa pod nową nazwą (jeden zrzut próbny) i jest opisany.
- `export_presets.cfg` nie ma martwych wpisów wykluczeń; eksport próbny nie jest wymagany (pełny build tylko za zgodą).
- Dokumenty (`CLAUDE.md` nie wymaga zmiany; `docs/agent/README.md` i `tools/README.md` tak) są spójne z nowym stanem.

Poza zakresem:
- Przepisanie historii (`git filter-repo`), force push, usuwanie plików z historii: tylko po wyraźnym „tak” Rolanda.
- Wymiana plików `cave_ambient.mp3` i `steps.mp3` (etap 5, D-10) oraz decyzja o logo (D-21).
- Decyzja o Git LFS (P5, etap 5).
- Ręczna edycja treści dodatków (poza dodaniem pliku LICENSE) i dodawanie nowych dodatków.
- Zmiany w rozgrywce, scenach generowanych i `data/`.

Priorytet: wysoki · Etap planu: teraz (część D1), reszta etapy 5 i 9 · Kolejność: po task_16 (ten sam plik `interact_test.gd`)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza
<!-- agent, /ai-task analyze 21, przebieg z dashboardu 2026-10-27 -->

**Kolejność.** task_16 jest w `docs/ai-tasks/done/`, a jego poprawka już jest w `master`: `tools/interact_test.gd:7` celuje w `MineDeep/BlueIronVeins/VeinMark_east_1`. Zależność jest spełniona, konfliktu w `interact_test.gd` nie będzie.

**Stan dzisiaj (główna kopia, `master` df27308):**
- `project.godot:26–29` rejestruje autoloady `PhantomCameraManager`, `BeehaveGlobalMetrics`, `BeehaveGlobalDebugger` i `MCPRuntimeProbe`. W `project.godot:42` jest pięć wtyczek: beehave, dialogue_manager, gdUnit4, godot_mcp i phantom_camera. Poza `addons/` i dokumentacją nic nie odwołuje się do Beehave, Phantom Camera ani GdUnit4: grep po kodzie, scenach i `tools/` nic nie znajduje, w repozytorium nie ma żadnego `GdUnitTestSuite`.
- `export_presets.cfg:11` (`exclude_filter`) ma dwa martwe wpisy: `docs_v2/*` (folder usunięty przy D-02, nie ma go w `git ls-files`) i `assets/Sewer/*` (martwy po tym zadaniu). `addons/gdUnit4/*` będzie martwy, jeśli GdUnit4 zostanie usunięty. `*.cs` nie pasuje dziś do żadnego pliku, ale chroni przed przypadkowym C# (CLAUDE.md), więc **zostaje** [założenie wykonawcy, do potwierdzenia w raporcie].
- `assets/Sewer` (52 śledzone pliki z `.import`) nie ma żadnych odwołań poza `export_presets.cfg`, `tools/README.md:81` i `docs/agent/README.md:33`.
- Jedynym odwołaniem do `assets/pics/sample-pic.jpg` jest `scene/visual_interaction/visual_interaction.tscn:3`, a tę scenę nic nie instancjonuje. Po usunięciu obu folder `assets/pics/` będzie pusty, więc trzeba go usunąć w całości. `docs/agent/README.md:33` wymienia `pics/`, a `:20` prototyp `visual_interaction.tscn`; oba wpisy do usunięcia.
- `tools/_ui_shot_tmp.gd` (+ `.uid`) jest opisany w `tools/README.md:57`. `interact_test.gd` i `nav_walk_test.gd` mają wiersz w `tools/README.md:46` i wzmiankę w `docs/agent/README.md:29`. Nie są zbudowane na `test_base.gd` (własne `extends SceneTree`) i nie wypisują linii `RESULT`. Żeby wejść do `run_tests.sh`, musiałyby zostać przepisane na wzorzec `scenario()`.
- `addons/godot_mcp` (`plugin.cfg`: autor `hybridindie`, wersja 2026.09.23) nie ma pliku licencji. Dodatek **jest używany**: to most serwera MCP `godot-editor` (`docs/agent/README.md`, sekcja „MCP servers”), więc nie można go po prostu usunąć. Sieć w tym przebiegu jest wyłączona, więc nie sprawdziłem licencji upstreamu (`https://github.com/hybridindie/godot-mcp`, link z `done/task_07.md:72`). Nie wiem więc, czy i jaką licencję podaje upstream.
- Specyfikacja: Sewer, `sample-pic.jpg` i ich ryzyko licencyjne wymieniają `06_oprawa.md:30`, `:33`, `:43` i `:53`. Dodatków rejestr zasobów nie obejmuje wcale (ani `dialogue_manager`, ani `godot_mcp`). W pozostałych plikach specyfikacji nie ma żadnych wzmianek o usuwanych rzeczach (fixture dashboardu `dashboard/src/work/fixtures/task_01.md` to kopia historyczna i zostaje).

**Rozbieżności i ryzyka:**
1. **GdUnit4.** task_07 (`done/task_07.md:44`) celowo go zostawił („GdUnit zostaje zespołowi do pracy w edytorze”), a propozycja K1 rekomenduje usunięcie. Te dwa wcześniejsze ustalenia są sprzeczne, więc decyzja należy do Rolanda (karta, pyt. 1).
2. **Licencja `godot_mcp`.** Wariant „wykluczyć z repozytorium i eksportu” ma ukryty koszt. `project.godot` dalej rejestruje wtyczkę i autoload `MCPRuntimeProbe`, a worktree `everhorror-wdrozenie` i każdy świeży klon dostają pliki tylko z gita. Bez folderu `--import` i testy zgłaszają błąd brakującego autoloadu, a eksport z wykluczonym folderem nie załaduje autoloadu na starcie. Ten wariant wymaga więc także usunięcia `MCPRuntimeProbe` z `project.godot` (inspekcja w czasie gry przez MCP znika, wtyczka edytora dalej działa lokalnie, jeśli jest w `[editor_plugins]` tylko u Rolanda; w praktyce trzeba by ją włączać ręcznie). Licencji nie wolno wymyślać, a ja nie mam sieci (karta, pyt. 2).
3. **`interact_test`/`nav_walk_test`.** Wymaganie zostawia ten wybór wykonawcy. Rekomenduję **usunąć oba**. `interact_test` pokrywają już `tests/test_expedition.gd` i `test_base.find_interactable`, `nav_walk_test` pokrywa `tests/test_camp_walk.gd` (ten sam wypiek navmeshu i marsz fizyką, tyle że po obozie). Przepisanie obu na `test_base` to praca ponad koszt S. Najpierw jednak wykonawca uruchamia każdy raz (`--headless --script`, log do pliku) i zapisuje wynik w raporcie. Jeśli któryś wykrywa coś, czego nie łapią scenariusze (np. podświetlenie każdego interaktywnego obiektu w `MineDeep`), zostaje i dostaje opakowanie w `run_tests.sh` z wierszem w tabeli.
4. Usunięcie dodatków zmienia `project.godot` i może przebudować `.godot/` w worktree. Przed testami potrzebny jest `--import`, a później sprawdzenie, że w logu nie ma `res://addons/beehave` ani `phantom_camera`. `global_script_class_cache.cfg` odświeży się sam.
5. To zadanie nie usuwa niczego z historii gita (poza zakresem). Pliki bez licencji pozostają publiczne w starych commitach. Raport ma to powiedzieć wprost.

## Plan
Rodzaj „narzędzia”: worktree `C:/dev/gamedev/everhorror/everhorror-wdrozenie`, gałąź `spec/<data>-task21` od `master` (najpierw trzeba sprawdzić, czy w „Na gałęziach” nie ma otwartego wiersza 🔧/🧪). Bez commita reguł w specyfikacji, wiersz w „Na gałęziach” z `—` zamiast sha7. Kroki po rozstrzygnięciu karty [2026-10-27_task21-dodatki-licencje](../../../specification/zgloszenia/2026-10-27_task21-dodatki-licencje.md):
1. **K1.** Usunąć `addons/beehave`, `addons/phantom_camera` (i `addons/gdUnit4`, jeśli wybór 1a). W `project.godot` usunąć ich wpisy z `[autoload]` i `[editor_plugins]` razem. W `export_presets.cfg` usunąć `docs_v2/*`, `assets/Sewer/*` (i `addons/gdUnit4/*` przy 1a).
2. **godot_mcp** według pyt. 2: (a) `addons/godot_mcp/LICENSE` z tekstem upstreamu i adresem źródła w raporcie; (b) `git rm -r --cached addons/godot_mcp`, wpis w `.gitignore` i `exclude_filter`, usunięcie `MCPRuntimeProbe` i wtyczki z `project.godot`, folder skopiowany ręcznie do worktree, nota w `docs/agent/README.md` („MCP servers”); (c) bez zmian, punkt w raporcie jako otwarty do dema.
3. **K8.** Usunąć `assets/Sewer/`, `assets/pics/` (cały, będzie pusty), `script/visual_interaction.gd` (+ `.uid`), `scene/visual_interaction/`. Przemianować `tools/_ui_shot_tmp.gd` → `tools/ui_shots.gd` razem z `.uid` (`git mv`, uid się nie zmienia). `interact_test`/`nav_walk_test` według punktu 3 analizy.
4. **Dokumenty.** `docs/agent/README.md`: autoloady (:24), `visual_interaction` (:20), testy (:29), `assets/` (:33), tabela „Addons” zgodna z `addons/`. `tools/README.md`: wiersz :46, wiersz `ui_shots.gd` jako narzędzie (:57), lista wykluczeń w krokach wydania (:81). `CLAUDE.md` bez zmian (zgodnie z wymaganiem; wymienia tylko „addon autoloads” ogólnie). W raporcie gotowe zdania do `06_oprawa.md`: skreślić wiersze Sewer i `sample-pic.jpg` (:30, :33), poprawić :43 i :53, a przy 2a dopisać wiersz „Godot MCP (hybridindie) | <adres> | <licencja> | narzędzie edytora, w repo”. Spec zatwierdza Roland albo `/spec-tasks`; wykonawca go nie zmienia.
5. **Testy** (worktree): `--import` (log do pliku: zero błędów i zero brakujących zasobów), potem `test-runner`: `unit lint dialogue day1`. Do tego jeden zrzut `tools/ui_shots.gd` (okno GPU, krótki) i raz `interact_test`/`nav_walk_test` przed decyzją z punktu 3. Pełnego zestawu nie uruchamiać.
6. **Sprawdzenie kryteriów:** grep (poza `docs/archiwum/`, `docs/analizy/`, `docs/ai-tasks/`) bez `Beehave`, `PhantomCamera`, `Sewer`, `sample-pic`, `visual_interaction`, `_ui_shot_tmp`. Uwaga: zakończone pliki `docs/ai-tasks/done/` (task_01, task_16) i ten plik zadania z natury je zawierają, a wymaganie ich nie wyłącza. Traktuję je jako historię i nie edytuję [założenie]. Potem `convention-reviewer` na diff.
7. **Arkusz** `docs/human-tasks/factcheck-test-21.md` w głównej kopii: gra startuje do menu, edytor otwiera projekt bez błędów brakujących wtyczek, most MCP łączy się (przy 2a/2c).

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->
Rozstrzygnięcia karty [2026-10-27_task21-dodatki-licencje.md](../../../specification/zgloszenia/2026-10-27_task21-dodatki-licencje.md): (1) czy usunąć GdUnit4; (2) co z licencją `addons/godot_mcp`. Przy wyborze 2a potrzebny jest też adres i tekst licencji z upstreamu, bo przebieg nie ma sieci.

## Test
<!-- Jeśli zadanie zawiera implementację: link do docs/human-tasks/factcheck-test-XX.md -->

## Podsumowanie
Analiza gotowa (2026-10-27): zależność od task_16 spełniona, plan w siedmiu krokach powyżej. Wdrożenie czeka na kartę decyzji (GdUnit4, licencja `godot_mcp`); reszta sprzątania nie wymaga decyzji.
