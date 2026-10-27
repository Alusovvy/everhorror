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

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->

## Test
<!-- Jeśli zadanie zawiera implementację: link do docs/human-tasks/factcheck-test-XX.md -->

## Podsumowanie
