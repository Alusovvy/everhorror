<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 3f76c0f; nie edytować.
-->

# task_17: Palisada bez „niską” i komunikat stołu z mapą

Wymagania:
1. Wstęp (04_tresc/tydzien.md, dzień 1) ✅: „Pogadaj z ludźmi. Wyprawy planujesz przy stole z mapą w zagrodzie Racibora, za palisadą bez dachu. W chodnikach mapa [M] pokaże ci drogę dalej albo z powrotem. Na noc wracasz na posłanie.”
2. Wstęp (04_tresc/tydzien.md, dzień 1) ⬜: „**[ROBOCZE]** Bez słowa „niską”: wstęp mówi „…w zagrodzie Racibora, za palisadą bez dachu…”, a komunikat przy stole z mapą mówi „w zagrodzie Racibora” zamiast „w kwaterze Racibora” (Roland, dashboard 2026-10-27, wariant A w zgłoszeniu [niska palisada](../zgloszenia/2026-10-26_niska-palisada.md)).”

Źródło: specyfikacja `3f76c0f` · ID: wstęp (tydzień) · Zgłoszenia: zgloszenia/2026-10-26_niska-palisada.md (decyzja: A)

Priorytet: niski (jedno słowo w tekście) · Kolejność: po task_16 (najwyżej jedna otwarta gałąź `spec/*`; oba zadania mogą też iść razem na jednej gałęzi, jeśli Roland tak zdecyduje)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Lista miejsc pochodzi z karty decyzji („Skutki i sprawdzenie”):
- `dialogue/system.dialogue`, blok `intro`: skreślić „niską ”. To zdanie narratora, nie górnika, więc bez klucza gwary. Po zmianie `--import`.
- `script/map_screen.gd`, ok. linii 78: „Wyprawy planujesz przy stole z mapą, w kwaterze Racibora…” → „w zagrodzie Racibora”.
- `tools/release/CZYTAJ_MNIE.txt`: sekcja „CO NOWEGO W 0.5.3” i opis stołu. Historii wydania 0.5.3 nie przepisywać, poprawić tylko opis bieżący, a w notce nowej wersji wspomnieć zmianę.
- `tools/tests/test_day1.gd`: asercja z cytatem wstępu.
- Komentarz w `tools/generators/gen_camp.gd`: tylko komentarz, sceny nie regenerować.

Ryzyka: brak. Sceny i generatory bez zmian. Testy: `unit`, `lint`, `dialogue`, `day1`. Pełna analiza: `/ai-task analyze 17`.

## Analiza
(`/ai-task analyze 17`, przebieg z dashboardu 2026-10-27, Opus; tylko odczyt kodu i specyfikacji, bez uruchamiania gry.)

**Skąd zadanie.** Zgłoszenie `zgloszenia/2026-10-26_niska-palisada.md` (task_14): Roland wybrał wariant A („Skreślić niską, A”, dashboard 2026-10-27). Zgadza się z tym wiersz 2 arkusza PT0 (`docs/human-tasks/done/factcheck-test-14.md`): „No nie pasuje niska”. Specyfikacja (`04_tresc/tydzien.md:15–17`) ma już cytat wstępu bez „niską” i regułę ⬜ z wymagania 2.

**Jak jest dziś w grze (główna kopia, `master`).**
| Miejsce | Tekst dziś | Po zmianie |
|---|---|---|
| `dialogue/system.dialogue:107` (blok `intro`) | „…w zagrodzie Racibora, za niską palisadą bez dachu…” | „…w zagrodzie Racibora, za palisadą bez dachu…” (dosłownie jak w wymaganiu 1) |
| `script/map_screen.gd:78` (wciśnięcie [M] w obozie) | „Wyprawy planujesz przy stole z mapą, w kwaterze Racibora. [M] działa w chodnikach.” | „…przy stole z mapą, w zagrodzie Racibora. [M] działa w chodnikach.” |
| `tools/tests/test_day1.gd:12` | sprawdza „za niską palisadą bez dachu” | sprawdza „w zagrodzie Racibora, za palisadą bez dachu” i brak „niską” |
| `tools/release/CZYTAJ_MNIE.txt:28` | „…w zagrodzie Racibora (przycisk WYRUSZ).” | bez zmian (nie ma „niską” ani „kwatery”) |
| `tools/release/CZYTAJ_MNIE.txt:59–60` | notka 0.5.3 z „niską” | patrz niżej (historia wydania) |
| `tools/generators/gen_camp.gd:451–452` | komentarz: „a roofless palisade about 2 m high… a palisade without a roof” | bez zmian: komentarz już nie mówi „low”, więc analiza wstępna przesadziła |
| `CHANGELOG.md:13` | wpis 0.5.3 z „niską” | historii nie przepisywać; nowy wpis w następnej wersji |

Innych wystąpień nie ma: `grep` po `script/`, `dialogue/`, `tools/` (bez `docs/archiwum/`) nie znajduje innego „niską” o palisadzie ani „kwaterze Racibora”. Linia wstępu to narrator, nie górnik, więc w `dialogue/gwara_slaska.json` nie ma jej klucza; komunikat mapy idzie przez `GameState.message`, poza gwarą. Tekst „Zachodni chodnik jest otwarty. Wyprawę zaplanujesz przy stole z mapą.” (`script/story_director.gd:399`) i opis stempli w `gen_camp.gd:575` nie mówią o miejscu stołu: zostają.

**Luki i uwagi.**
- Żaden test nie sprawdza komunikatu z `map_screen.gd:78`. Warto dopisać sprawdzenie w `day1` (w obozie, po wstępie: zdarzenie akcji `field_map` przez `Input.parse_input_event` i przechwycenie `GameState.message`), żeby „kwatera” nie wróciła. Jeśli to w teście okaże się kruche (modalność po wstępie), wystarczy asercja na tekście komunikatu z sygnału po wywołaniu `_unhandled_input` na węźle mapy.
- Wymaganie 1 ma znacznik ✅, a jego cytat już nie ma „niską”, choć gra je ma. To nie sprzeczność do rozstrzygnięcia: ✅ dotyczy reguły z task_14 (stół w zagrodzie, nie w kwaterze zarządcy, `tydzien.md:16`), a cytat w `tydzien.md:15` poprawił `/spec-tasks` razem z regułą ⬜ (wymaganie 2). Po wdrożeniu gra i cytat znów się zgodzą.
- **Historia 0.5.3.** `CHANGELOG.md` i notka „CO NOWEGO W 0.5.3” w `CZYTAJ_MNIE.txt` opisują to, co weszło w 0.5.3, więc zostają. Zmiana idzie do nowej sekcji, w `CHANGELOG.md` jako „## [Nieopublikowane]” (lub numer następnej wersji, jeśli Roland ją ustali przy wydaniu, `tools/README.md#wydanie`). `CZYTAJ_MNIE.txt` przepisuje się przy wydaniu; do tego czasu notki 0.5.3 nie ruszać. Numeru wersji to zadanie nie podnosi.
- **Kolejność.** task_16 (`📋 czeka` w „W zadaniach”, „Na gałęziach” puste) jest przed tym zadaniem i ma ukończoną analizę. Zasada planu (§3 pkt 5): najwyżej jedna otwarta gałąź `spec/*`. Domyślnie task_17 czeka na scalenie gałęzi task_16. Wspólna gałąź jest dopuszczona w pliku zadania „jeśli Roland tak zdecyduje”: to wybór przy kliknięciu „Wdrażaj”, a nie pytanie do analizy, więc karty decyzji nie piszę.

**Ryzyka.** Małe. `--import` po zmianie `.dialogue` jest konieczny przed testami (inaczej `day1` czyta starą wersję zasobu). Scen i generatorów nie ruszamy.

## Plan
1. Kopia wdrożeniowa `C:/dev/gamedev/everhorror/everhorror-wdrozenie`, gałąź `spec/<data>-task17` od `master` (po scaleniu task_16), albo ta sama gałąź co task_16, jeśli Roland tak wskaże w uwagach przebiegu.
2. `dialogue/system.dialogue:107`: skreślić „niską ” (zdanie dosłownie jak w wymaganiu 1). Potem `--import` (`--headless --path C:/dev/gamedev/everhorror/everhorror-wdrozenie --import`).
3. `script/map_screen.gd:78`: „w kwaterze Racibora” → „w zagrodzie Racibora”.
4. `tools/tests/test_day1.gd:12–13`: asercja na „w zagrodzie Racibora, za palisadą bez dachu” oraz brak „niską palisadą”; opis kroku po angielsku bez „low” (np. „task_17: … behind the roofless palisade, not a low one”). Dopisać sprawdzenie komunikatu [M] w obozie („w zagrodzie Racibora”, bez „kwaterze”), jak w Analizie.
5. `CHANGELOG.md`: nowa sekcja na górze („Nieopublikowane”, task_17, zgodność ze spec `3f76c0f`) z wpisem w „Naprawione”. Wpisu 0.5.3 i notki 0.5.3 w `CZYTAJ_MNIE.txt` nie zmieniać. `gen_camp.gd` bez zmian.
6. `lore-checker` na dwóch zmienionych zdaniach (`system.dialogue:107`, `map_screen.gd:78`) i fakcie „stół z mapą w zagrodzie Racibora, palisada ok. 2 m bez dachu” wobec `04_tresc/miejsca.md` (Zagroda dowódcy).
7. Testy przez `test-runner` w kopii wdrożeniowej: `unit lint dialogue day1`, z informacją, że zmienił się plik `.dialogue` (najpierw `--import`), bez nowych `class_name`. Pełnego zestawu nie uruchamiać.
8. `convention-reviewer` na diffie gałęzi.
9. Arkusz `docs/human-tasks/factcheck-test-17.md` w głównej kopii (z `factcheck_template.md`, strefy człowieka puste), dwa wiersze: wstęp w nowej grze mówi „za palisadą bez dachu” i brzmi naturalnie; [M] w obozie pokazuje „…w zagrodzie Racibora…”.
10. Specyfikacja: „Na gałęziach” 🧪 i „W zadaniach” task_17 → 🧪, bez przełączania ⬜→✅ (robi to `/spec-sync finalize`) i bez wiersza w „Zmianach agenta poza specyfikacją”. Lint, commit `[agent]` z jawnymi ścieżkami, push. W zgłoszeniu `2026-10-26_niska-palisada.md` (pod „Odpowiedź agenta”) można dopisać gałąź, na której to weszło.

## Co zostało zrobione
Gałąź `spec/2026-10-27-task17` w kopii wdrożeniowej (od `master` po scaleniu task_16), commit `2ca7904`.

**Wymaganie 1 i 2 (wstęp, komunikat stołu).**
- `dialogue/system.dialogue:107`: „za niską palisadą” → „za palisadą”; zdanie dosłownie jak w wymaganiu 1 (po `--import`).
- `script/map_screen.gd:78`: „w kwaterze Racibora” → „w zagrodzie Racibora”.
- `tools/tests/test_day1.gd`: asercja na nowy wstęp i brak „niską”, a także nowe sprawdzenie komunikatu [M] w obozie (zdarzenie `field_map` podane do `MapScreen._unhandled_input`, przechwycenie `GameState.message`).
- `CHANGELOG.md`: nowa sekcja „[Nieopublikowane]”, wpis 0.5.3 i `CZYTAJ_MNIE.txt` bez zmian; `gen_camp.gd` bez zmian.

## Decyzje i założenia
Brak nowych. Wariant A wybrał Roland w zgłoszeniu. Numeru wersji nie podniesiono. W specyfikacji nie zmieniano reguł ani żadnego [ROBOCZE].

## Czego potrzebuję od Ciebie
Sprawdź dwa wiersze arkusza [factcheck-test-17](../human-tasks/factcheck-test-17.md), potem scal gałąź.

## Test
Arkusz: [factcheck-test-17](../human-tasks/factcheck-test-17.md). `lore-checker`: bez sprzeczności. `convention-reviewer`: bez błędów. Po `--import`:
- `unit`, `lint`, `dialogue`, `day1`: ALL PASSED.
- Pełny zestaw (`tools/run_tests.sh`, za zgodą Rolanda), 19 scenariuszy: wszystkie ALL PASSED (balance 1415 sprawdzeń).

## Podsumowanie analizy
Zadanie to dwie zmiany słów: „niską” znika ze wstępu (`dialogue/system.dialogue:107`), a komunikat [M] w obozie mówi „w zagrodzie Racibora” zamiast „w kwaterze” (`script/map_screen.gd:78`). Do tego poprawka testu `day1` z nowym sprawdzeniem komunikatu i wpis w `CHANGELOG.md` w nowej sekcji. Historia wydania 0.5.3 i komentarz w `gen_camp.gd` (już bez „low”) zostają bez zmian. Decyzja Rolanda zapadła w zgłoszeniu (wariant A), więc nie piszę karty. Zadanie czeka tylko na kolejność: domyślnie wdrażane po scaleniu task_16, albo razem z nim, jeśli Roland tak wskaże przy kliknięciu „Wdrażaj”.

## Podsumowanie
Wdrożone na gałęzi `spec/2026-10-27-task17` (`2ca7904`): wstęp bez „niską”, komunikat [M] „w zagrodzie Racibora”, test `day1` rozszerzony, wpis w `CHANGELOG.md`. Pełny zestaw testów przeszedł. Czeka na sprawdzenie arkusza przez człowieka i scalenie przez Rolanda.
