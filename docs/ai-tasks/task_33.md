<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_33: Mapa: wybór miejsca kliknięciem w kółko i zadania przy miejscach

Wymagania:
1. WYP-18 (03_mechaniki/wyprawy.md) ⬜: „**[ROBOCZE]** Kliknięcie kółka miejsca na rysunku mapy (albo jego nazwy) wybiera to miejsce tak samo jak kliknięcie na liście „Dokąd wyruszyć” albo „Dokąd dalej?”: zaznacza je na liście, pokazuje opis, trasę czerwonym atramentem i przycisk WYRUSZ / IDŹ DALEJ (Roland, playtest 2026-10-27: „Kliknięcie na kółka na mapie powinno też selekcjonować te obszary, że jak kliknę kółko, to też się wybierze z listy docelowa lokacja”). Działa w obu trybach mapy (WYP-3, WYP-5); miejsce zamknięte też da się tak wybrać, a opis podaje powód blokady. Kółko, którego nie ma na liście (np. w terenie miejsce, które nie jest sąsiadem), tylko podświetla się bez wyboru [ROBOCZE]. Kursor nad kółkiem zmienia się na rękę. Dziś rysunek mapy (`script/map_drawing.gd`) nie reaguje na mysz, a wybór jest tylko z listy (`script/map_screen.gd:122`, `_select()`). **Dla agenta:** `_gui_input` w `map_drawing.gd` z trafieniem w kropkę i nazwę (`_point()`, prostokąty nazw z `_taken`), sygnał do `map_screen.gd` → `_select(id)` i zaznaczenie przycisku listy; obsługa klawiatury bez zmian (UI-4).”
2. WYP-19 (03_mechaniki/wyprawy.md) ⬜: „**[ROBOCZE]** Opis miejsca na mapie mówi, jakie zadania tam prowadzą (Roland, playtest 2026-10-27: „Cele na liście »Dokąd wyruszyć« w swoim opisie powinny też mieć osobną listę, jaki quest wiąże się z tym miejscem… albo jak masz lepszy pomysł, jak to tam dodać, to zrób”). W opisie wybranego miejsca, pod linią żył, jest osobny akapit „Zadania tutaj:” z tytułami zadań z notesu (ZAD-2), po jednym w wierszu. Bez zadań akapitu nie ma. Agent dodał dwie rzeczy, bo sama lista w opisie wymaga klikania każdego miejsca po kolei:
  - **Tylko aktywne zadania, których bieżący krok prowadzi właśnie tam.** Przypisanie zadań do miejsc z warunkiem „do którego wpisu” jest w tabeli [miejsca zadań](../04_tresc/zadania.md#miejsca-zadań). Tytuł znika z opisu, gdy krok jest zrobiony (np. „Lonty dla Mirosława” przy Starej sztolni do wpisu `znalezione`). Dzięki temu lista niczego nie zdradza: zadanie pojawia się dopiero wtedy, gdy gracz ma je w notesie.
  - **Znak na rysunku:** przy kółku miejsca, do którego prowadzi aktywne zadanie, stoi mały znak atramentem (np. kółko obwiedzione drugi raz albo krzyżyk), jak notatka bohatera na mapie dziadka. To nie łamie UI-1, bo jest na mapie przy stole, a nie w HUD. Na liście miejsc przy nazwie dochodzi dopisek „zadanie” obok „żyły 1/2”.
  - „Złoża dla Kniazia” i „Zakład z Sobkiem” nie trafiają na listę, bo żyły ma już linia żył; zadania rozgrywane w obozie (np. „Brat i czarownica”) też nie.
  - **Dla agenta:** `script/map_screen.gd` (`_details_text()`, `_button_text()`), `script/map_drawing.gd` (znak przy kropce, odstęp nazw z `_taken`), dane przypisania w `tools/generators/write_story_data.js` (`quest()`) → `data/quests/*.tres` (np. pole z miejscami i wpisem końcowym) albo w `write_world_data.js`; stan zadań: `GameState.quests`; test `unit`: dla kilku stanów zadań poprawne tytuły w opisie, `lint`: każde miejsce i każdy wpis z tabeli istnieje.”
3. Miejsca zadań (04_tresc/zadania.md) ⬜: „**[ROBOCZE]** Dane dla [WYP-19](../03_mechaniki/wyprawy.md) (Roland, playtest 2026-10-27; przypisanie zaproponował agent na podstawie przebiegów i wpisów wyżej, do weta Rolanda). Tytuł zadania stoi w opisie miejsca na mapie, gdy zadanie jest aktywne, wpis „od” jest już w notesie (puste = od początku zadania), a wpisu „do” jeszcze nie ma. Miejsca to ID z [miejsc](miejsca.md).” Tabela „Zadanie | Miejsce | Od wpisu | Do wpisu” w tej sekcji (13 wierszy, od `lonty` do `ryba`) oraz zdanie pod nią: „Bez miejsca: `zloza` i `zaklad` (żyły pokazuje linia żył), `pokoj` i `oferta` (obóz), `czternasty` (ślady są rozsiane, a tajemnica ma zostać niedopowiedziana). Gdy krok kończy się przedmiotem (`grzyb`, `odlamek`, `ryba`), tytuł znika też wtedy, gdy bohater ten przedmiot niesie, bo w miejscu nie ma już nic do zrobienia [ROBOCZE].”

Źródło: specyfikacja `67b762e` · ID: WYP-18, WYP-19; zadania (miejsca zadań) · Zgłoszenia: —
Poziom: rozgrywka

Priorytet: do ustalenia (uwagi z playtestu 2026-10-27, poza kolejką „Czeka na wdrożenie”) · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Obie reguły zmieniają ten sam ekran mapy (`scene/ui/map_screen.tscn`), w obu trybach (stół i [M] w terenie).

**Systemy i pliki:** jak w „Dla agenta” obu reguł. Dane przypisania: tabelę z `04_tresc/zadania.md#miejsca-zadań` przenieść do generatora (`write_story_data.js`, `quest()`), wynik w `data/quests/*.tres`, z polami miejsca, wpisu „od”, wpisu „do” i przedmiotu, który kończy krok. Warunek „bohater niesie przedmiot” przez `GameState` (ekwipunek). Uwaga na nowe pola typu lista w zasobach: task_25 pokazał, że eksport gubił `PackedStringArray`, więc po task_25 test eksportu powinien objąć też te pola.

**Ryzyka:** trafienie w kółko i w nazwę musi liczyć się w tym samym układzie, w którym `map_drawing.gd` rysuje (skalowanie okna); kółko poza listą tylko podświetla. Znak atramentem nie może nachodzić na nazwy i kreski żył (WYP-3: `_taken`). Dopisek „zadanie” na liście po polsku jak reszta tekstów mapy. Tytuły zadań w opisie nie mogą zdradzać zadań, których gracz nie ma w notesie (test `unit` na kilku stanach).

**Tabela z wymagania 3, dosłownie** (spec `67b762e`, `04_tresc/zadania.md`, sekcja „Miejsca zadań”; w wymaganiach jest tylko jej opis, bo planowanie nie wstawiło jej w całości, a sekcji wymagań nie wolno już zmieniać):

| Zadanie | Miejsce | Od wpisu | Do wpisu |
|---|---|---|---|
| `lonty` Lonty dla Mirosława | `east` Stara sztolnia | — | `znalezione` |
| `slady` Ślady dziadka | `east` Stara sztolnia | — | `szyfr` |
| `slady` Ślady dziadka | `west` Zawalony chodnik | `szyfr` | `klucz` |
| `slady` Ślady dziadka | `upadowa` Upadowa | `archiwum` | `zawal` |
| `slady` Ślady dziadka | `kaplica` Kaplica | `zawal` | `list` |
| `towar` Tobołek Tekli | `rzapie` Rząpie | — | `znaleziony` |
| `sciana` Ściana w kaplicy | `kaplica` Kaplica | — | `otwarta` |
| `kilof` Kilof dla przewodnika | `wyrobisko` Stare wyrobisko | — | `znaleziony` |
| `pompy` Pompy Nasira | `pompy` Komora pomp | — | `ruszyly` |
| `goraczka` Gorączka Nasira | `grota` Grzybowa grota | `grzyb` | `wyleczony` albo `wywieziony`, albo bohater niesie `grzyb` |
| `wiersz` Wiersz o świetle | `grota` Grzybowa grota | — | `oddany`, albo bohater niesie `grzyb` |
| `odlamek` Odłamek dla Sabiny | `galeria` Kryształowa galeria | — | `oddany`, albo bohater niesie `odlamek` |
| `ryba` Ryba dla Hrapka | `zalany` Zalany chodnik (staw) | — | `zlowiona`, `od_tekli`, `od_wszebora` albo `oddana`, albo bohater niesie `ryba` |

## Analiza

Analiza z 2026-10-27 (przebieg z dashboardu `20261027-204415-analyze-33-159a6c`). Kolejność: zadanie na nic nie czeka. Jest tylko jedna miękka zależność: task_25 (eksport gubi `PackedStringArray`) wciąż czeka (📋). Nie ma otwartej karty decyzji z `Zadanie: task_33`.

**Jak jest dziś.**
- `script/map_drawing.gd` (Control z własnym `_draw()`, bez `_gui_input`) rysuje mapę. Pozycję kropki liczy `_point(id)` = `MARGIN + map_pos * (size - 2*MARGIN)`, w lokalnym układzie kontrolki, więc trafienie myszą w `_gui_input` (`event.position` też jest lokalne) liczy się w tym samym układzie, także przy skalowaniu okna. Prostokąty nazw trafiają do `_taken` (`:160`), ale bez informacji, do którego miejsca należą: tablica jest wspólna dla kropek, kresek żył i nazw, a `_draw()` czyści ją na początku każdej klatki. Węzeł `Drawing` w `scene/ui/map_screen.tscn:94` ma domyślne `mouse_filter = STOP`, więc kliknięcia już do niego docierają.
- `script/map_screen.gd`: lista budowana jest w `_build()` (`:105`). Każdy przycisk ma `meta place`, a `pressed` i `focus_entered` wołają `_select(id)` (`:173`). Ten ustawia opis (`_details_text`, `:187`), przycisk WYRUSZ / IDŹ DALEJ / WRACAJ DO OBOZU oraz `selected` i `route` w rysunku. Na liście jest `_choices()` (`:84`): przy stole wszystkie znane miejsca, w terenie obóz i sąsiedzi. Dopisek na przycisku daje `_button_text()` (`:150`): „nowe” albo „żyły m/n”. Dla miejsca nieznanego, czyli zamkniętego z `unknown_name` (Kaplica „Znak zapytania”, Galeria „Przekreślona gwiazda”), opis miejsca jest ukryty (`:214`).
- Zadania: `GameState.quests` = `{id: {state, entries[]}}` (`script/game_state.gd:152`), dane w `QuestData` (`script/data/quest_data.gd`: `id`, `title`, `giver`, `entries: Dictionary`). Generator to `quest(id, title, giver, entries)` w `tools/generators/write_story_data.js:47`. Przedmioty sprawdza `GameState.has_item()`.
- Wszystkie ID z tabeli istnieją. Miejsca (`write_world_data.js:97–154`): `east`, `west`, `rzapie`, `upadowa`, `kaplica`, `wyrobisko`, `pompy`, `grota`, `zalany`, `galeria`. Wpisy (`write_story_data.js:177–285`): `lonty/znalezione`; `slady/szyfr, klucz, archiwum, zawal, list`; `towar/znaleziony`; `sciana/otwarta`; `kilof/znaleziony`; `pompy/ruszyly`; `goraczka/grzyb, wyleczony, wywieziony`; `wiersz/oddany`; `odlamek/oddany`; `ryba/zlowiona, od_tekli, od_wszebora, oddana`. Przedmioty: `grzyb`, `odlamek`, `ryba` (`game_state.gd:109–113`).
- Testy: żaden scenariusz nie sprawdza myszy na mapie. `tools/tests/test_expedition.gd:13` otwiera `MapScreen` i woła jego metody wprost, więc tak samo da się sprawdzić `_details_text` i `_button_text`. `tools/data_lint.gd` sprawdza już ID zadań i wpisów w `quest_log`, więc nowe dane łatwo tam dołożyć.

**Luki.** (1) Rysunek nie reaguje na mysz: brak trafienia w kropkę i nazwę, brak sygnału, brak podświetlenia i kursora. (2) Nie ma danych „zadanie → miejsce, od wpisu, do wpisu, przedmiot”. (3) `_details_text` nie ma akapitu „Zadania tutaj:”, a `_button_text` nie ma dopisku „zadanie”. (4) Na rysunku nie ma znaku zadania. (5) Brak testu `unit` i reguły `lint` dla tych danych.

**Ryzyka i szczegóły, które ustalam sam ([ROBOCZE], do weta Rolanda; żadne nie wymaga karty decyzji):**
- **Format danych a eksport (task_25).** Nie używam `PackedStringArray` ani tablic typowanych. Nowe pole `QuestData.map_places: Dictionary` ma postać `{"east": {"from": "", "until": "znalezione", "item": ""}}`: tylko słowniki i napisy, czyli ten sam rodzaj danych co `entries`, który w ZIP-ie działa. Kilka wpisów „do” zapisuję po przecinku. Każde zadanie z tabeli ma w niej każde miejsce najwyżej raz, więc kluczem może być miejsce. Gdy task_25 wejdzie wcześniej, jego test eksportu obejmie też to pole. Gdy wejdzie później, to pole i tak nie zależy od jego poprawki.
- **Warunek** (jedna funkcja, np. `GameState.quests_at(place) -> Array[String]` z tytułami): zadanie w stanie `active`, wpis „od” pusty albo już w `entries`, żaden z wpisów „do” jeszcze niezapisany i, gdy jest `item`, bohater go nie niesie. Kolejność tytułów jak w `QUESTS`. `goraczka` i `wiersz` dzielą `grota`: po oddaniu grzyba Hagiwarze tytuł „Gorączka Nasira” wraca przy grocie, bo krok wymaga nowego grzyba. To zgodne z regułą.
- **Miejsca nieznane** (Kaplica jako „Znak zapytania”, Galeria jako „Przekreślona gwiazda”): akapit „Zadania tutaj:” i znak pokazuję także tam, choć sam opis miejsca jest ukryty. Gracz ma już w notesie zadanie, które go tam kieruje („To pewnie tam.” w `sciana/start`, „najniżej na mapie” w `odlamek/start`), więc nic nie zdradzam.
- **Obóz** nie dostaje akapitu (WYP-19: zadania w obozie nie trafiają na listę).
- **Trafienie w kropkę i nazwę.** Promień kropki 12 px (rysowana ma 7, obwódka wyboru 12). Nazwy: w `_label()` zapisuję prostokąt nazwy z ID miejsca w osobnej tablicy (np. `_hits: Array[Dictionary]`), nie w `_taken`, bo tamta służy do układania nazw. Prostokąty z poprzedniej klatki wystarczają, bo mysz działa na tym, co już widać. Obóz też się trafia: w terenie jest na liście (WRACAJ DO OBOZU), przy stole go na liście nie ma, więc tylko się podświetla.
- **Sygnał.** `map_drawing.gd` emituje `place_clicked(id)`, a `map_screen.gd` sprawdza, czy `id` jest w `_choices()`. Jeśli jest, woła `_select(id)`, ustawia `button_pressed = true` i `grab_focus()` na przycisku z listy (fokus i tak woła `_select`, więc to jedna ścieżka, a klawiatura z UI-4 zostaje bez zmian). Jeśli nie jest, ustawia tylko podświetlenie. Podświetlenie (`hovered`) to cienka obwódka atramentem przy kropce pod myszą, dla każdego kółka. Klik w kółko spoza listy nic nie wybiera.
- **Kursor.** W `_gui_input` przy `InputEventMouseMotion` ustawiam `mouse_default_cursor_shape = CURSOR_POINTING_HAND` nad kropką lub nazwą, a w innym miejscu `CURSOR_ARROW`. Przy wyjściu z kontrolki (`NOTIFICATION_MOUSE_EXIT`) czyszczę podświetlenie.
- **Znak zadania.** Drugi, cieńszy okrąg atramentem (`BLOOD`, promień 10) wokół kropki miejsca z aktywnym zadaniem. Jest dopisany do `_taken` przed układaniem nazw, więc nazwy go omijają. Wybieram okrąg, a nie krzyżyk, bo krzyżyk z kropką to już znak dziadka w rogu mapy (`map_drawing.gd:94`). Pomarańczowa obwódka wyboru (12) i czerwony krąg „tu jesteś” (13) zostają czytelne obok niego, ale trzeba to obejrzeć na zrzucie.
- **Dopisek na liście.** `  ·  zadanie` na końcu tekstu przycisku, także przy „nowe”. Lista może się przez to wydłużyć: przycisk ma `alignment` w lewo i leży w `Scroll`, więc sprawdzam zrzutem, czy tekst się nie ucina przy 1280×720.
- **Teksty** idą przez `tr()`, jak każdy nowy tekst dla gracza w skrypcie (D-09): „Zadania tutaj:” i „zadanie”. Tytuły zadań biorę z `QuestData.title`.

## Plan

1. **Dane.** `script/data/quest_data.gd`: pole `@export var map_places: Dictionary = {}` z komentarzem formatu. `tools/generators/write_story_data.js`: `quest()` dostaje opcjonalny piąty argument `places` i zapisuje `map_places = {...}`. Do 10 zadań z tabeli dopisuję dane, dosłownie według tabeli (spec `67b762e`), w tym `item` dla `goraczka`, `wiersz` (`grzyb`), `odlamek` i `ryba`. Uruchamiam `node tools/generators/write_story_data.js` (w kopii gałęzi), co odnawia `data/quests/*.tres`. Ręcznie nie zmieniam niczego.
2. **Logika.** `script/game_state.gd` (region Notes and quests): `quests_at(place: StringName) -> Array[String]` z warunkiem opisanym w Analizie.
3. **Opis i lista.** `script/map_screen.gd`: w `_details_text()` po linii żył akapit `Zadania tutaj:` i tytuły po jednym w wierszu, tylko gdy lista nie jest pusta i nie chodzi o obóz. W `_button_text()` dopisek `  ·  zadanie`. Do tego obsługa sygnału `place_clicked` (wybór i zaznaczenie przycisku albo samo podświetlenie) i przekazanie do rysunku listy ID z `_choices()` oraz miejsc z zadaniem.
4. **Rysunek.** `script/map_drawing.gd`: `signal place_clicked(id)`, `_gui_input` (ruch: podświetlenie i kursor; lewy klik: sygnał), `_hit(pos) -> StringName` (kropki i prostokąty nazw z `_hits`), znak zadania przy kropce przed `_label()`, obwódka podświetlenia, czyszczenie przy `MOUSE_EXIT`.
5. **Testy:** `tools/unit_test.gd`: `quests_at` dla kilku stanów (brak zadania; `lonty` aktywne i potem `znalezione`; `slady` z `szyfr` → `west` tak, `east` nie; `goraczka` z `grzyb` i grzybem w plecaku → brak; zadanie `done` → brak), `_details_text` z akapitem i bez niego oraz `_button_text` z „zadanie”. `tools/data_lint.gd`: każdy klucz `map_places` jest miejscem z `Expeditions`, każdy wpis „od” i „do” istnieje w `entries` zadania, `item` jest w `ITEMS`. `tools/tests/test_expedition.gd`: klik myszą na rysunek (`InputEventMouseButton` w `_gui_input` z pozycją `_point(id)`) wybiera miejsce na liście przy stole i w terenie, miejsce zamknięte też (opis z powodem, WYRUSZ wyłączony), a kółko spoza listy w terenie nie zmienia `selected`. Serwer po wdrożeniu uruchamia `unit lint dialogue expedition`; ja najpierw robię `--import` (nowa wersja `QuestData` i `.tres`) i zrzut ekranu mapy (`tools/README.md`, zrzuty), żeby obejrzeć znak i dopiski.
6. **Spec i dokumenty.** WYP-18 i WYP-19 w `03_mechaniki/wyprawy.md`: szczegóły z Analizy jako [ROBOCZE] (okrąg jako znak, promień trafienia, podświetlenie, miejsca nieznane), wskaźniki „Dla agenta” na nowe funkcje. W `04_tresc/zadania.md#miejsca-zadań` wskaźnik na `map_places` w generatorze. `docs/agent/README.md`, sekcja mapy: mysz, `quests_at`. Arkusz (poziom `rozgrywka`): jedna część `## Część: task_33` arkusza builda (D-27): klik w kółka i nazwy w obu trybach, kursor, zamknięte miejsce, akapit zadań przy kilku stanach, znak na mapie i dopisek na liście.

Pliki: script/map_drawing.gd, script/map_screen.gd, script/game_state.gd, script/data/quest_data.gd, tools/generators/write_story_data.js, data/quests/, tools/unit_test.gd, tools/data_lint.gd, tools/tests/test_expedition.gd, docs/agent/README.md
Ryzyko: średnie

## Przepływ (D-36)
Poziom `rozgrywka`: wybór miejsca kliknięciem na mapie, znaki i akapit zadań w opisie miejsca, które gracz widzi. Arkusz tylko jako jedna część `## Część: task_33` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `średnie`: kilka skryptów mapy i regenerowane `data/quests`; format zapisu bez zmian.

## Podsumowanie

Analiza gotowa i bez pytań do Rolanda. Mapa dostaje wybór kliknięciem w kółko i nazwę, w obu trybach, z kursorem ręki i samym podświetleniem kółek spoza listy. Opis miejsca dostaje akapit „Zadania tutaj:”, rysunek okrąg atramentem przy miejscu z zadaniem, a lista dopisek „zadanie”. Dane przypisania (tabela z `04_tresc/zadania.md`) idą do generatora jako słownik napisów, bez `PackedStringArray`, więc nie zależą od poprawki eksportu z task_25. Wszystkie ID z tabeli istnieją w kodzie. Drobne szczegóły (okrąg zamiast krzyżyka, który już jest znakiem dziadka; akapit także przy miejscach nieznanych) ustalam jako [ROBOCZE] do weta Rolanda. Następny krok: `/ai-task implement 33`.
