<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_30: Poprawki tekstów 2026-10-27: najwyżej dwie kwestie pod rząd

Wymagania:
1. DIA-13 (03_mechaniki/dialogi.md) ⬜: „**[ROBOCZE]** Najwyżej **dwie kwestie** pod rząd przed wyborem gracza albo reakcją; dłuższa opowieść idzie do notesu jako wpis (C3, [karta dynamiki](../zgloszenia/2026-10-27_dynamika-i-nagrody.md), Roland, dashboard 2026-10-27, wybór 5a). Dziś zdarzają się wykłady po trzy kwestie pod rząd, płatne 5 minut (`dialogue/nasir.dialogue:44–52`). Zasada obowiązuje nowe i poprawiane kwestie; poprawienie istniejących (`nasir`, `racibor`, `hagiwara`, przejście `lore-checker`, klucze gwary) to osobne zadanie tekstowe. Dotyka kanonu i gwary, więc teksty przechodzą przez weto Rolanda.”
2. Zasady pisania kwestii ⬜ (03_mechaniki/dialogi.md): „- Krótkie zdania. Jedna myśl na linijkę.
- Postać mówi swoim głosem (zob. kartę), a nie głosem narratora.
- Informacja o świecie wynika z rozmowy, a nie z wykładu.
- Opcje gracza to krótkie zdania, które można powiedzieć na głos.”
3. Tamże: „Cztery zasady powyżej zespół zapisał jako 💡; ta sekcja jest teraz ⬜ razem z DIA-13 (Roland, dashboard 2026-10-27, wybór 5a).”

Źródło: specyfikacja `67b762e` · ID: DIA-13, zasady pisania kwestii (dialogi) · Zgłoszenia: zgloszenia/2026-10-27_dynamika-i-nagrody.md (wybór 5a)
Poziom: rozgrywka

Priorytet: pozycja 8 w „Czeka na wdrożenie” · Kolejność: — (zbiorcze zadanie tekstowe; zmienia tylko pliki `.dialogue`, klucze gwary i wpisy notesu)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Zbiorcze zadanie tekstowe („poprawki tekstów 2026-10-27”): osobne zadanie tekstowe, o którym mówi DIA-13.

**Systemy i pliki:** `dialogue/nasir.dialogue` (wykład w `:44–52`), `dialogue/racibor.dialogue`, `dialogue/hagiwara.dialogue`, a w drugiej kolejności przegląd reszty `dialogue/*.dialogue` pod kątem ciągów ≥ 3 kwestii tej samej postaci bez wyboru. Dłuższa opowieść jako wpis notatki (`notes` w `GameState`, generator notatek) zamiast trzeciej kwestii. Kwestie Mirosława i Bolka: klucze w `tools/generators/write_gwara.js` → `dialogue/gwara_slaska.json` (test `dialogue` oblewa bez wersji śląskiej). Po każdej zmianie `.dialogue`: `--import` przed testami.

**Kierunek:** prosty sprawdzacz w `tools/data_lint.gd` (np. ostrzeżenie przy trzech kolejnych liniach postaci bez odpowiedzi) pomaga utrzymać zasadę w nowych tekstach; czy ma być błędem, czy ostrzeżeniem, ustala wykonawca (przy istniejących wyjątkach, np. scenach snu, lepiej ostrzeżenie).

**Ryzyka:** teksty dotykają kanonu i gwary, więc przejście `lore-checker` i weto Rolanda w arkuszu. Skracanie kwestii zmienia czas rozmów (5 minut za opcję), a nie liczbę opcji; nie wolno przy tym zgubić flag ani `quest_log`. Kanon 2026-10-27 (dziadek, amulet, dwie wersje zawalenia celowo niejednoznaczne) obowiązuje.

Pełna analiza: `/ai-task analyze 30`.

## Analiza
(agent, `/ai-task analyze 30`, 2026-10-27; spec `67b762e`, kod `master` f45b9b0)

**Wymagania.** 1 to sama zasada DIA-13 (wchodzi do gry jako zasada pisania, plus poprawienie istniejących wykładów: to zadanie jest tym „osobnym zadaniem tekstowym”). 2 to cztery zasady pisania kwestii, które w kodzie nie mają własnego mechanizmu: obowiązują przy każdej poprawianej linijce. 3 to tylko zmiana znacznika 💡 → ⬜ w specyfikacji; w grze nic nie wymaga, po scaleniu `/spec-sync finalize` zmieni ⬜ na ✅.

**Jak jest dziś.** Każda odpowiedź gracza w rozmowie z osobą kosztuje 5 minut (`script/vn.gd:62–72`, DIA-5); wolne są tylko `[#leave]`, `[#free]` (przekazanie przedmiotu, pilnowane przez `tools/data_lint.gd:132–155`) i odpowiedź już raz wybrana. Długa opowieść po jednej odpowiedzi to więc wykład, za który gracz płaci, nie mając nic do powiedzenia. Przegląd wszystkich `dialogue/*.dialogue` (wyszukanie trzech kolejnych linii `Postać: …`) dał około 38 trafień w 14 plikach:
- wykłady jednej osoby (cel DIA-13): `nasir.dialogue:22–24` (powitanie dnia 1 przez gałęzie `if`), `44–46`, `50–52`, `60–62`, `67–69`; `racibor.dialogue:42–44`, `49–51`, `67–69`, `109–111`, `115–117`; `hagiwara.dialogue:67–69`, `104–106`; `wszebor.dialogue:49–51`, `60–62`, `70–72`, `82–84`, `88–90`; `anzelm.dialogue:57–59`, `67–69`; `tekla.dialogue:39–41`, `112–114`; `sobek.dialogue:89–91`; `sabina.dialogue:58–60`; `dobrawa.dialogue:21–23`; `welf.dialogue:21–23`; `miroslaw.dialogue:30–32`, `90–92`; `bolko.dialogue:60–62`;
- sceny kilku głosów i napis: `drudzy.dialogue:13–21`, `dobrawa.dialogue:94–110` (Dobrawa z Sabiną), `racibor.dialogue:178–180`, `sciana.dialogue:14–21` (trzy wersy zagadki, celowo).
Wyszukiwanie liczy tylko linie `Postać:` stojące bezpośrednio pod sobą; ciągi przerwane narracją wykonawca dolicza, przeglądając pliki.

**Notes.** Notatki to zasoby `data/notes/*.tres` z generatora `tools/generators/write_story_data.js`, rejestrowane w `GameState.NOTES` (`script/game_state.gd:65–76`) i dodawane z dialogu przez `add_note("…")` (np. `racibor.dialogue:71`, `hagiwara.dialogue:86`), z komunikatem „Nowa notatka w notesie” (`game_state.gd:784–789`). `note_event` to co innego (podsumowanie wyprawy) i do opowieści się nie nadaje.

**Luki i ryzyka.**
- Zakres: DIA-13 wymienia z nazwy tylko Nasira, Racibora i Hagiwarę, a wspomina klucze gwary, czyli Mirosława i Bolka; wykładów jest w grze dużo więcej. To pytanie 1 karty.
- Co z resztą treści: skrócić, przenieść do notesu czy przerwać reakcją (płatną 5 minut według DIA-5). Dodanie reakcji podraża rozmowę wbrew karcie dynamiki; dodanie kilkunastu notatek zaśmieca notes. Pytanie 2 karty.
- Kanon: skracanie wykładów łatwo gubi fakty o świecie (Sułtanat, Dżiny, Cesarz, Hawiarowie, przewodnik z prochem u Tekli, zawał u Mirosława). Każda zmiana idzie przez `lore-checker`; kanon 2026-10-27 (dziadek, amulet, dwie wersje zawalenia celowo niejednoznaczne) obowiązuje. Weto Rolanda w arkuszu.
- Gwara: zmieniona linijka Mirosława lub Bolka wymaga nowego klucza w `tools/generators/write_gwara.js` i przegenerowania `dialogue/gwara_slaska.json`, inaczej `dialogue` oblewa.
- Mechanika: w poprawianych gałęziach nie wolno zgubić `set_flag`, `quest_log`, `start_quest`, `change_rep`, `change_player_sanity` ani `add_note`; testy `dialogue` sprawdzają część tekstów dosłownie (`tools/dialogue_test.gd`, `tools/tests/test_day2.gd`), więc zmienione linie mogą wymagać poprawki asercji.
- Sprawdzacz: zasada „nowe kwestie” utrzyma się tylko z ostrzeżeniem w `tools/data_lint.gd`; błąd lintu zablokowałby testy przez sceny i wyjątki. Pytanie 3 karty.

## Pytania
Karta decyzji: [`zgloszenia/2026-10-27_task30-dwie-kwestie.md`](../../../specification/zgloszenia/2026-10-27_task30-dwie-kwestie.md) (spec `a031ea8`): 1) zakres poprawek, 2) skrócenie, notes czy reakcja, 3) sprawdzacz w lincie jako uwaga czy błąd. Plan poniżej zakłada rekomendacje (1a, 2a, 3a); po innym wyborze zmienia się lista plików i liczba notatek.

## Plan
1. **Sprawdzacz** w `tools/data_lint.gd`: sekcja „najwyżej dwie kwestie pod rząd”: w każdym bloku (te same wcięcie, bez odpowiedzi `- …` między liniami) liczy kolejne linie tej samej postaci, narrację pomija; przy trzech i więcej wypisuje `LINT … uwaga` z plikiem i linią. Wyjątki: `sciana.dialogue`, `drudzy.dialogue`, sceny kilku postaci (ciąg wielu różnych mówców nie jest ciągiem jednej osoby), sny i ognisko (`ognisko.dialogue`, `system.dialogue`) jako lista w kodzie z komentarzem. Szczegół **[ROBOCZE]** w DIA-13 („Dla agenta”).
2. **Poprawki tekstów**, plik po pliku (lista z Analizy, zakres według pytania 1): z trzech kwestii zostają najwyżej dwie (krótkie zdania, jedna myśl na linijkę, głos postaci według karty postaci w spec `02_postacie/`). Tam, gdzie opowieść niesie wiedzę o świecie lub śledztwie, reszta trafia do notatki: kandydaci `historia_nasira`, `sultanat`, `obrzedy_hagiwary`, `przewodnik_tekli`, `zawal_miroslawa` (nazwy [ROBOCZE]). Reakcja gracza w środku tylko tam, gdzie wybór coś zmienia. Wszystkie `$>` i warunki zostają.
3. **Notatki:** nowe wpisy w `tools/generators/write_story_data.js`, przegenerować `data/notes/`, dopisać je do `GameState.NOTES` (`script/game_state.gd`), w dialogu `$> add_note("…")` w tej samej gałęzi.
4. **Gwara:** każda zmieniona linijka Mirosława i Bolka: nowy klucz i tekst w `tools/generators/write_gwara.js`, przegenerować `dialogue/gwara_slaska.json`.
5. **Lore:** `lore-checker` z listą zmienionych linii (`plik:linia`) i faktów, które z nich zniknęły lub przeszły do notesu; sprzeczności poprawić, otwarty kanon do Rolanda.
6. **Testy:** po zmianach jedno `--import` (nowych plików `.dialogue` nie ma, więc druga runda nie jest potrzebna); serwer po wdrożeniu uruchamia `unit lint dialogue` (zmienione `.dialogue` i nowe notatki) oraz scenariusz `day2`; agent poprawia asercje oparte na starych tekstach w `tools/dialogue_test.gd` i `tools/tests/test_day2.gd`, jeśli dotyczą zmienionych linii.
7. **Spec:** w DIA-13 „Dla agenta”: wskazanie sprawdzacza (`tools/data_lint.gd`) i listy wyjątków [ROBOCZE]; nowe notatki w rejestrze notatek specyfikacji, jeśli taki jest (sprawdzić `01_swiat/` i `05_tresc/`). Lint spec, `cli.ts commit`, ledger `set-branch`.
8. **Arkusz** (poziom `rozgrywka`): jedna część `## Część: task_30` arkusza builda (D-27): tabela „przed / po” dla każdej zmienionej rozmowy, kolumna weta Rolanda (strefa człowieka pusta), notatki do przeczytania w notesie, linie gwary.

Plan zależy od wyboru: tak

Pliki: dialogue/nasir.dialogue, dialogue/racibor.dialogue, dialogue/hagiwara.dialogue, dialogue/wszebor.dialogue, dialogue/anzelm.dialogue, dialogue/tekla.dialogue, dialogue/sobek.dialogue, dialogue/sabina.dialogue, dialogue/dobrawa.dialogue, dialogue/welf.dialogue, dialogue/miroslaw.dialogue, dialogue/bolko.dialogue, dialogue/gwara_slaska.json, tools/generators/write_gwara.js, tools/generators/write_story_data.js, data/notes, script/game_state.gd, tools/data_lint.gd, tools/dialogue_test.gd, tools/tests/test_day2.gd
Ryzyko: średnie

## Przepływ (D-36)
Poziom `rozgrywka`: to nie sam `tekst`: oprócz dialogów zadanie dopisuje notatki (`data/notes`, rejestr `NOTES` w `script/game_state.gd`) i sprawdzacz w lincie (narzędzia), a najwyższy poziom wygrywa; arkusz zachowuje tabelę „przed / po” z wetem Rolanda. Arkusz tylko jako jedna część `## Część: task_30` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `średnie`: 12 plików dialogów, gwara, nowe notatki i lint, bez zmiany formatu zapisu.

## Podsumowanie
Analiza gotowa: DIA-13 łamie około 30 wykładów jednej osoby w 12 plikach dialogów, nie tylko trzy nazwane w zasadzie. Przed wdrożeniem Roland rozstrzyga kartę [`2026-10-27_task30-dwie-kwestie.md`](../../../specification/zgloszenia/2026-10-27_task30-dwie-kwestie.md): zakres, los treści ponad dwie kwestie (skrót, notes, reakcja) i rodzaj sprawdzacza w lincie. Plan i lista plików zakładają rekomendacje karty.
