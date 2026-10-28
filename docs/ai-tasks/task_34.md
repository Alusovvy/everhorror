<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_34: Paski zmęczenia i poczytalności (opcja „Show condition bars”)

Wymagania:
1. UI-9 (05_interfejs.md) ⬜: „**[ROBOCZE]** Paski stanu bohatera, na razie (Roland, playtest 2026-10-27: „Dodać pasek zmęczenia i sanity i podpisać, niech póki co to będzie widoczne”). W rogu ekranu FPP, tam gdzie dziś stan bohatera słowami, stoją dwa cienkie, podpisane paski: **„Zmęczenie”** (zmęczenie z ZDR-12, pełny pasek = „padasz z nóg”) i **„Poczytalność”** (poczytalność bohatera z ZDR-6, pełny pasek = 100). Bez liczb i procentów; słowa pasm zostają tam, gdzie są dziś („zmęczony”, „ledwo idziesz”, winieta na krawędzi). Paski znikają w rozmowach i na ekranach, jak winieta (ZDR-11).
  - **„Póki co”:** paski włącza opcja w OPTIONS „Show condition bars” (menu po angielsku, UI-5), **domyślnie włączona** w buildach do ogrania i w wydaniach 0.5.x. Co z nimi dalej (wyłączyć domyślnie przed demem, usunąć, zostawić), rozstrzyga [karta „paski stanu”](zgloszenia/2026-10-27_paski-stanu.md); do tego czasu obowiązuje ta reguła.
  - **Konflikt, nazwany wprost:** UI-1 ✅ („Żadnych pasków”), zasady projektowe planu (`everhorror/docs/analizy/final-plan-human-readable.md` §3 pkt 8: „słowa zamiast liczb”, „bez nowych liczników”) i ZDR-12 (zmęczenie tylko słowami, od 75%). Pasek nie dodaje licznika, bo zmęczenie i poczytalność już są w grze, ale pokazuje ilość zamiast słowa. Roland poprosił o to wyraźnie i na razie, więc reguła jest opcją z domyślnym „włączone”, a UI-1 się nie zmienia, dopóki karta nie rozstrzygnie inaczej.
  - **Pomiar:** paski mogą podnieść odpowiedź „rozumiem, co kosztuje czas” (K4) i zmienić odczucie grozy (K3). Arkusz sesji zapisuje w „Dane sesji”, czy paski były włączone [ROBOCZE].
  - **Dla agenta:** `scene/hud.tscn` (węzeł `Condition`), `script/hud.gd`, `GameState.player_fatigue`, `player_sanity`, `fatigue_band()`, `mind_band()`; opcja jak `show_locked_choices`: `Settings` (`user://settings.cfg`), `scene/options_panel.tscn`, `script/options_panel.gd`; domyślna wartość w [balansie](07_balans.md#interfejs-i-zapis). Test `unit`: opcja zapisuje się i wczytuje; scenariusz: oba paski widać w FPP, nie widać w VN. Podpisy po polsku przez `tr()` / tabelę `Texts` (D-09).”
2. Balans, interfejs i zapis (07_balans.md) ⬜: „| ⬜ Paski stanu bohatera (UI-9) | domyślnie włączone („póki co”, Roland, playtest 2026-10-27); dalszy los: karta „paski stanu” | `Settings` (opcja „Show condition bars”) |”

Źródło: specyfikacja `67b762e` · ID: UI-9; balans (paski stanu) · Zgłoszenia: zgloszenia/2026-10-27_paski-stanu.md (karta decyzji; pytanie 1 rozstrzygnięte: a, pytanie 2 bez odpowiedzi; reguła wdraża się niezależnie od karty)
Poziom: rozgrywka

Priorytet: do ustalenia (uwaga z playtestu 2026-10-27, poza kolejką „Czeka na wdrożenie”; mała zmiana, dobra przed PT0b) · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
**Systemy i pliki:** jak w „Dla agenta” reguły. Paski w tym samym kontenerze co stan słowami (`Condition` w `scene/hud.tscn`), ukrywane tam, gdzie winieta (VN, notes, mapa, pauza, ekrany końca). Opcja wzorem `show_locked_choices` (zapis w `user://settings.cfg`, domyślnie `true`), etykieta w OPTIONS po angielsku, podpisy pasków po polsku przez `tr()`/`Texts`.

**Karta „paski stanu”:** Roland wybrał 1a (opcja zostaje, przed demem publicznym domyślnie wyłączona); to zmiana na etap 9, nie w tym zadaniu. Pytanie 2 (PT0b z paskami czy bez) jest otwarte i nie blokuje wdrożenia; arkusz sesji ma tylko zapisać stan opcji („Dane sesji”).

**Ryzyka:** UI-1 i ZDR-12 zostają bez zmian (wyjątek przez opcję, nazwany w regule). Pełny pasek zmęczenia = „padasz z nóg” (100%), poczytalność = 100; paski bez liczb i procentów. Kolory i grubość zgodne z motywem (`theme/ui_theme.tres`, bursztynowy akcent, UI-3). Pasek nie może zasłaniać podpowiedzi przy obiekcie ani przypiętych podpowiedzi z UI-8 (task_27).

Pełna analiza: `/ai-task analyze 34`.

## Analiza

(agent, `/ai-task analyze 34`, 2026-10-27; kod głównej kopii na `f45b9b0`, specyfikacja na `67b762e`)

**Jak jest dziś.**
- `scene/hud.tscn:111`: `Condition` to zwykły `Label` w lewym górnym rogu (offset 24/18, 15 px, czerwonawy), bez kontenera. `script/hud.gd:116` składa w nim słowa („ranny · na krawędzi · gorączka · zmęczony”) w `_update_condition()`, wołanym na `GameState.player_changed` i `state_replaced`. `_process()` (`hud.gd:38`) chowa `condition`, celownik i winietę, gdy `GameState.is_modal()` (VN, notes, mapa, ekwipunek, podsumowanie wyprawy, przejścia `screen_fade`, sceny `StoryDirector`). Pauza zatrzymuje `_process` HUD-u, więc winieta i stan zostają pod menu pauzy tak jak dziś; paski zachowają się identycznie („jak winieta”).
- Zmęczenie: `GameState.player_fatigue` 0..`FATIGUE_MAX` (100), pasma w `fatigue_band_of()` (`game_state.gd:678`: 75 / 90 / 100, przy 100 „padasz z nóg”). Poczytalność: `player_sanity` 0..`PLAYER_MAX` (100). Pełny pasek zmęczenia = `player_fatigue / FATIGUE_MAX` = 1, poczytalności = `player_sanity / PLAYER_MAX` = 1, czyli dokładnie to, co mówi UI-9.
- Opcja-wzór: `Settings.show_locked_choices` (`settings.gd:25`, zapis w sekcji `dialogue` pliku `user://settings.cfg`, `:87`/`:103`), przełącznik `LockedToggle` w siatce `scene/options_panel.tscn:114-126` (etykieta po angielsku, podpowiedź po polsku), obsługa w `options_panel.gd:40`/`:72`. `Settings.changed` jest emitowany w `apply()`.

**Luki.**
1. **Zmęczenie nie odświeża HUD-u między pasmami.** `change_fatigue()` (`game_state.gd:660`) emituje `player_changed` tylko przy zmianie pasma, a zmęczenie rośnie co godzinę (`_tire`). Pasek odświeżany tylko na sygnał stałby w miejscu od 0 do 75. Rozwiązanie bez ruszania `game_state.gd` (dotykają go task_26, 27, 28, 33): HUD odczytuje dwie liczby w `_process()` i ustawia `value` pasków (koszt pomijalny). Poczytalność emituje sygnał przy każdej zmianie, ale dla prostoty oba paski idą tą samą drogą.
2. **Brak `tr()`/`Texts` w kodzie.** W `script/` nie ma ani jednego `tr("…")` ani tabeli `Texts`. Najprostsza zgodna z D-09 droga: podpisy „Zmęczenie” i „Poczytalność” jako `text` etykiet w `hud.tscn` (Godot tłumaczy teksty węzłów sam, `auto_translate_mode` domyślnie dziedziczone), bez literału w skrypcie. Nowej tabeli `Texts` nie zakładam.
3. **Brak testu opcji.** `tools/unit_test.gd` nie testuje dziś `Settings`. Test zapisu i wczytania pisze do prawdziwego `user://settings.cfg` gracza, więc musi zachować i przywrócić jego zawartość (albo brak pliku).
4. **Układ rogu.** Słowa „zostają tam, gdzie są dziś”, paski stoją obok. Gdy słów nie ma (zdrowy, spokojny, wypoczęty: większość gry), pusta etykieta nie może zostawić dziury nad paskami.

**Ryzyka.**
- **Konflikty plików z innymi zadaniami:** `script/hud.gd` i `scene/hud.tscn` zmienia też task_27 (panel podpowiedzi UI-8, stawiany u dołu nad toastami, więc bez zderzenia w rogu), `script/hud.gd` task_26 (kolejka toastów). Różne fragmenty pliku, ale równoległe wdrożenie da konflikt w scalaniu; kolejność dowolna, byle nie równolegle (wiersz `Pliki:`).
- `tools/screenshot.gd` z `keep_hud` pokaże paski na zrzutach; to pożądane, nie błąd.
- UI-1, ZDR-12 i plan §3 pkt 8 zostają bez zmian (wyjątek nazwany w UI-9). Karta „paski stanu”: pytanie 1 rozstrzygnięte (a, zmiana domyślnej wartości dopiero przed demem, etap 9, nie tutaj), pytanie 2 nie blokuje wdrożenia. **Nowej karty decyzji nie trzeba.**
- Arkusz sesji (PT0b) ma w „Dane sesji” wiersz o stanie opcji (UI-9, „Pomiar”). Szablon `playtest_template.md` tego wiersza dziś nie ma; to zmiana dokumentu procesu, zgłaszana w raporcie przy wdrożeniu (dokument, nie kod gry; szablon zmienia koordynator).

## Plan

1. **`script/settings.gd`:** `var show_condition_bars: bool = true` z komentarzem (UI-9, „póki co”, domyślna wartość z `07_balans.md`); zapis i odczyt w nowej sekcji `config.set_value("hud", "show_condition_bars", …)` / `get_value` z bieżącą wartością jako domyślną (stary `settings.cfg` bez klucza daje `true`).
2. **`scene/options_panel.tscn` + `script/options_panel.gd`:** para `BarsLabel` („Show condition bars”) + `BarsToggle` (`CheckButton`, `button_pressed = true`) na końcu siatki `Grid`, podpowiedź po polsku jak przy `LockedToggle` (np. „W rogu ekranu dwa paski: zmęczenie i poczytalność bohatera.”); `@onready var bars_toggle`, `set_pressed_no_signal(Settings.show_condition_bars)` w `open()`, `_on_bars_toggled(on)` → `Settings.show_condition_bars = on`, `Settings.apply()`.
3. **`scene/hud.tscn`:** zamiast luźnego `Condition` kontener `ConditionBox` (`VBoxContainer`, ten sam róg: offset 24/18, szerokość ok. 220 px, `mouse_filter = 2`) z dziećmi: `Condition` (`Label`, bez zmian stylu, ukryty, gdy pusty) i `Bars` (`GridContainer`, 2 kolumny): `FatigueLabel` „Zmęczenie”, `FatigueBar`, `SanityLabel` „Poczytalność”, `SanityBar`. Paski: `ProgressBar`, `min_value 0`, `max_value 1`, `step 0`, `show_percentage = false`, wysokość ok. 6 px, szerokość ok. 120 px, `StyleBoxFlat` tła (ciemne, półprzezroczyste) i wypełnienia (bursztynowy akcent motywu, UI-3); podpisy 13 px, kolor jak podpowiedź „[E] zamknij” (`0.6, 0.56, 0.5`) z obwódką. **[ROBOCZE]** kolejność: słowa nad paskami, a bez słów paski wchodzą na ich miejsce; rozmiary i kolory do oceny na zrzucie.
4. **`script/hud.gd`:** `@onready` dla `ConditionBox`, `Condition` (nowa ścieżka), `Bars`, `FatigueBar`, `SanityBar`; w `_process()`: `bars.visible = not modal and Settings.show_condition_bars`, `condition.visible = not modal and condition.text != ""`, wartości `fatigue_bar.value = GameState.player_fatigue / GameState.FATIGUE_MAX`, `sanity_bar.value = float(GameState.player_sanity) / GameState.PLAYER_MAX`. Komentarz nagłówka HUD-u dopisuje paski (UI-9). Żadnych liczb ani procentów w tekście.
5. **Testy:** `tools/unit_test.gd`: nowa sekcja „settings: show_condition_bars” (domyślnie `true`; zachowanie bajtów `user://settings.cfg` albo braku pliku → `false`, `save_settings()`, `true`, `load_settings()` → `false`; przywrócenie pliku). Scenariusz: `tools/tests/test_hrapek.gd` już sprawdza HUD przy starcie świata i otwiera okno rozmowy (`use(talk("Bolko"))`, `:49`): po kroku startu `check(hud.bars.visible …)` (oba paski w FPP, opcja włączona), w kroku z wyszarzoną odpowiedzią przy otwartym VN `check(not hud.bars.visible …)`. Serwer po wdrożeniu uruchamia `unit lint dialogue` i scenariusz `hrapek` (bez zmian `.dialogue`, bez nowych `class_name`). Zrzut z `keep_hud` w `tools/screenshot.gd` do raportu (wygląd rogu).
6. **Dokumenty.** `docs/agent/README.md` (HUD: paski UI-9, opcja `show_condition_bars`); spec: „Dla agenta” UI-9 z faktycznymi węzłami (`ConditionBox/Bars`) i **[ROBOCZE]** z pkt 3, `07_balans.md` bez zmian (domyślnie włączone); lint, `cli.ts commit`, `ledger set-branch` jak w skillu. Arkusz (poziom `rozgrywka`): jedna część `## Część: task_34` arkusza builda: wiersze FPP (oba paski, podpisy, brak liczb, pasek zmęczenia rośnie z godzinami, poczytalność spada po strasznym miejscu), VN/notes/mapa (brak pasków), OPTIONS (wyłączenie chowa paski, stan przetrwa restart). Wiersz „paski stanu: włączone / wyłączone” do „Dane sesji” w szablonie `playtest_template.md` agent zgłasza w raporcie (szablon to dokument procesu: zmienia go koordynator, nie przebieg).

Plan zależy od wyboru: nie

Pliki: script/settings.gd, script/options_panel.gd, scene/options_panel.tscn, script/hud.gd, scene/hud.tscn, tools/unit_test.gd, tools/tests/test_hrapek.gd, docs/agent/README.md
Ryzyko: średnie

## Przepływ (D-36)
Poziom `rozgrywka`: nowy element interfejsu gry (paski stanu) i opcja w menu. Arkusz tylko jako jedna część `## Część: task_34` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `średnie`: opcja w `settings.cfg`, HUD i panel opcji: kilka skryptów i scen interfejsu.
Odniesienie do planu w wymaganiu 1 (dawny plik, §3 pkt 8) zostaje bez zmian, bo wymagania są niezmienne; te zasady projektowe są dziś w `docs/analizy/plan.md` §3 pkt 8.

## Zmiana w specyfikacji a166db2
(spec-tasks, 2026-10-28) UI-9 (05_interfejs.md) ⬜ zmienił się tylko redakcyjnie: w punkcie „Konflikt, nazwany wprost” odnośnik do planu brzmi teraz „zasady projektowe planu (`everhorror/docs/analizy/plan.md (historia: docs/archiwum/plan-historia-2026-10.md)` §3 pkt 8: „słowa zamiast liczb”, „bez nowych liczników”)”. Treść reguły i plan bez zmian.

Karta [„paski stanu”](../../../specification/zgloszenia/2026-10-27_paski-stanu.md) ma teraz obie odpowiedzi: „**Roland, 2026-10-28 (dashboard):** 1: a, 2: a”. Pytanie 2a (PT0b z włączonymi paskami, arkusz zapisuje to w „Dane sesji”) potwierdza to, co już zakłada plan (pkt 6), więc nic się w nim nie zmienia.

## Podsumowanie

Zadanie jest małe i gotowe do wdrożenia, bez nowych pytań: karta „paski stanu” ma rozstrzygnięte pytanie 1, a otwarte pytanie 2 (PT0b z paskami czy bez) wdrożenia nie blokuje. Plan: opcja `Settings.show_condition_bars` (domyślnie włączona) z przełącznikiem w OPTIONS, dwa cienkie podpisane paski w kontenerze rogu HUD-u pod słowami stanu, odświeżane w `_process()` (bo zmęczenie emituje sygnał tylko przy zmianie pasma), ukrywane przy `is_modal()` jak winieta; test `unit` opcji i sprawdzenie widoczności w `hrapek`. Uwaga na kolejność: `hud.gd`/`hud.tscn` zmieniają też task_26 i task_27, więc nie wdrażać ich równolegle z tym.
