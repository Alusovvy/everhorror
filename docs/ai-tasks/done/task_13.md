<!--
Zadanie ze specyfikacji (spec-tasks, 2026-09-26). Wymagania to cytat zasad ze specyfikacji w commicie 8d8c550; nie edytować.
-->

Wymagania:
1. Sny (04_tresc/tydzien.md) ⬜: „**[DECYZJA 2026-09-26]** Pierwszej nocy po odszyfrowaniu — obojętnie której — sen kończy się kartką dziadka z odszyfrowanymi zdaniami „twoim pismem”. (Dziś gra ma tę końcówkę tylko w snach po dniu 1 i 2 — [zgłoszenie](../zgloszenia/2026-09-26_niedociagniecia-z-wyrownania.md).)”
2. Sny (04_tresc/tydzien.md) ⬜: „**[DECYZJA 2026-09-26]** Z aktywnymi „Czternastoma kreskami” w snach nocy 5–7 ktoś liczy szeptem do czternastu i nigdy nie mówi „piętnaście”. (Dziś tylko noce 5–6.)”
3. `ryba` (04_tresc/zadania.md, Przebieg): „pierwsze spotkanie z Hrapkiem → ryba od Tekli (jeśli bohater oddał jej tobołek, a nie wydał go Raciborowi) albo 4 h ze Wszeborem lub Mirosławem przy stawie w Zalanym chodniku (⬜ dopiero gdy pompy działają) albo ⬜ bandaż dla Wszebora, który następnego ranka przynosi rybę z rząpia **[DECYZJA 2026-09-26]** → oddać Hrapkowi przed jego śmiercią (noc 5→6)”
4. Wpisy zadania `ryba` (04_tresc/zadania.md) ⬜:
   - „`wymiana`: „Dałem Wszeborowi bandaż. Rano ma przynieść rybę, mówi, że w rząpiu też stoją, tylko trzeba umieć.” [ROBOCZE]”
   - „`od_wszebora`: „Wszebor przyniósł rybę z rząpia. Ślepa, jak tamte ze stawu.” [ROBOCZE]”
5. Balans (07_balans.md) ⬜:
   - „Ryba: łowienie ze Wszeborem albo Mirosławem | 4 h (Mirosław: +5 poczytalności, liczy się jak wieczór w towarzystwie); ⬜ tylko gdy pompy działają (`pump_running`) **[DECYZJA 2026-09-26]**”
   - „Ryba od Wszebora | ⬜ 1 bandaż, ryba następnego ranka **[DECYZJA 2026-09-26]**”
6. Wszebor (02_postacie/wszebor.md, Przedmioty) ⬜: „Ryba (dla Hrapka) | ⬜ za bandaż, następnego ranka: łowi ją w rząpiu, bo Hawiar wie jak (gracz sam tam nie złowi) **[DECYZJA 2026-09-26]**, szczegóły [ROBOCZE]”
7. Rząpie (04_tresc/miejsca.md) ⬜: „w wodzie na dnie szybu stoją ślepe ryby; Wszebor umie je wyciągnąć, bohater sam nie złowi (zob. [ryba](zadania.md)) **[DECYZJA 2026-09-26]** [ROBOCZE].”
8. Hrapek (02_postacie/hrapek.md, Zadania, koszt czasu): „rozmowy z nim nic nie kosztują; ryba: od Tekli za darmo, 4 h łowienia (⬜ gdy pompy działają) albo ⬜ bandaż dla Wszebora (ryba następnego ranka)”
9. Zgłoszenie `2026-09-26_niedociagniecia-z-wyrownania.md` (Co): „1. **Sen z odszyfrowanym listem gra tylko po nocach 1–2.** […] 2. **Sen „liczenia kresek” nie gra w noc 7.** […] 3. **Łowienie ryby nie sprawdza pomp.** […]” — decyzja Rolanda w „Odpowiedź agenta”.

Źródło: specyfikacja `8d8c550` · ID: sny (tydzień), `ryba`, `wszebor`, `rzapie`, `hrapek` · Zgłoszenia: `zgloszenia/2026-09-26_niedociagniecia-z-wyrownania.md`

Priorytet: wysoki (decyzja z bieżącego zgłoszenia) · Kolejność: — (nawiązuje do [task_09](task_09.md): Hrapek i „Ryba dla Hrapka”)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
- **Jedno zadanie, dwie rzeczy.** Sny i ryba to różne mechaniki, ale jedna decyzja z jednego zgłoszenia, a naraz może być otwarta tylko jedna gałąź `spec/*` — więc jedno zadanie zamiast dwóch kolejnych.
- **Sny** (`dialogue/system.dialogue`): końcówka z listem stoi w `~ dream` i `~ dream2` pod warunkiem `has_note("odszyfrowana") and not has_flag("dream_decipher_seen")` — powielić ją w `~ dream3`, `~ dream4` i `~ dream_last`. Liczenie kresek stoi w `~ dream4` (`quest_state("czternasty") == "active" or has_flag("fourteenth_gift")`) — dopisać do `~ dream_last`. Sprawdzić, czy odszyfrowanie w `story_director.gd` dzieje się przed snem tej samej nocy (inaczej końcówka przyjdzie dzień później).
- **Ryba** (`dialogue/wszebor.dialogue`, `dialogue/miroslaw.dialogue`): opcja „Chodź ze mną na ryby do stawu. (4 h)” ma dostać warunek `pump_running` (flaga z `nasir.dialogue`). Bez pomp postać odmawia i — u Wszebora — podsuwa wymianę za bandaż. Linia Mirosława wymaga klucza gwary (`tools/generators/write_gwara.js`).
- **Wymiana za bandaż**: wzór jak kilof (flaga z dniem, odbiór od następnego dnia). Opcja oddania to `[#free]` z `take_item`, z warunkiem zadania (DIA-2: inaczej wyszarzy się od dnia 1). Nowe wpisy `wymiana`, `od_wszebora` w `tools/generators/write_story_data.js` (lint sprawdza, że każdy wpis jest zdefiniowany i logowany).
- Ryzyka: `dialogue_test.gd` przechodzi opcje łowienia — z nowym warunkiem pomp test może wymagać ustawienia `pump_running`. Odbiór po śmierci Hrapka (noc 5→6): zadanie jest wtedy zamknięte wpisem `za_pozno`, więc odbiór musi się nie pojawiać albo nie ruszać zadania.
- Pełna analiza: `/ai-task analyze 13`; plan jest na tyle prosty, że można od razu `/ai-task implement 13`.

## Co zostało zrobione
Gałąź `spec/2026-09-26-task13` w worktree `../everhorror-wdrozenie`, commit `f56d146`.

### 1. Sen z listem po każdej nocy odszyfrowania
`dialogue/system.dialogue`: blok `has_note("odszyfrowana") and not has_flag("dream_decipher_seen")` (ten sam tekst co w śnie nocy 1) dopisany na koniec `~ dream3`, `~ dream4` i `~ dream_last`. Odszyfrowanie dzieje się w `_resolve_night()` przed snem (`story_director.gd` `_sleep()`), więc kartka przychodzi tej samej nocy. Raz na grę (flaga).

### 2. Liczenie do czternastu w noc 7
`~ dream_last`: linia liczenia (warunek jak w `~ dream4`) zaraz po „Pyta tylko, czy policzyłeś.”

### 3, 5, 8. Łowienie tylko przy pompach
`wszebor.dialogue`, `miroslaw.dialogue`: opcja „Chodź ze mną na ryby do stawu. (4 h)” najpierw sprawdza `pump_running`; bez pomp postać odmawia („woda stoi po sam strop”) i nic nie łowi. Nowa kwestia Mirosława ma klucz gwary (`write_gwara.js` → `gwara_slaska.json`).

### 3, 4, 6, 7. Bandaż dla Wszebora, ryba z rząpia rano
- Przy odmowie Wszebor pokazuje rozharataną dłoń i proponuje wymianę (flaga `wsz_fish_offer`).
- „Masz, bandaż na rękę. Za rybę.” — `[#free]`, `give_to_npc("bandaze", "wszebor")`, flaga `wsz_fish_day`, wpis `wymiana`. Bez bandaża wyszarzona z powodem (DIA-2), dopiero po propozycji.
- „Jak tam ryba z rząpia?” — od następnego dnia ryba i wpis `od_wszebora` (wzór kilofa: `get_flag("wsz_fish_day", 99)`); tego samego dnia „Rano, mówiłem…”.
- Nowe wpisy w `write_story_data.js` → `data/quests/ryba.tres`.

### 9. Zgłoszenie
Wszystkie trzy punkty zrobione; w spec status 🔧 do finalizacji.

## Decyzje i założenia
- Wymianę proponuje Wszebor, **gdy odmawia łowienia** (pompy stoją) — spec nie mówi, skąd gracz ma się o niej dowiedzieć [ROBOCZE]. Po propozycji wymiana działa też po uruchomieniu pomp (spec jej nie ogranicza).
- Wszebor łowi przed świtem, poza czasem gracza — nic nie kosztuje ani jego, ani bohatera [ROBOCZE, do karty Wszebora].
- Bandaż trafia do Wszebora przez `give_to_npc` (leczy mu rękę), nie znika bez śladu.
- Rano w dniu 6 rybę da się jeszcze odebrać: zadanie zamyka dopiero znalezienie ciała Hrapka (wpis `za_pozno`). Wtedy bohater zostaje z bezużyteczną rybą — zgodne z „Nie zdążyłem z rybą”.
- Ta sama linia liczenia w snach nocy 5–6 i 7 — celowo (spec i wzór z `~ dream4`); lore-checker zwrócił uwagę tylko stylistycznie.

## Czego potrzebuję od Ciebie
- Stan na 2026-10-26: gałąź została scalona do `master` (`f56d146`, build 0.5.2 `e4c5edc`). Zostaje ręczne sprawdzenie: zagraj i wypełnij [factcheck-test-13](../../human-tasks/done/factcheck-test-13.md) — nadal czeka na człowieka. (Pierwotnie: `git merge spec/2026-09-26-task13` na `master`, potem `/spec-sync finalize`.)
- Ren: fakt „w rząpiu stoją ślepe ryby, Wszebor umie je wyciągnąć” jest [ROBOCZE] do przeglądu kanonu.

## Test
- `test-runner` w worktree: **unit, lint, dialogue, hrapek — ALL PASSED**, bez SCRIPT ERROR.
- `dialogue_test.gd` dopisany: sen z listem po nocach 3, 5, 7 (i tylko raz), liczenie w noc 7, odmowa łowienia u obu postaci bez pomp, propozycja, oddanie bandaża, odbiór tego samego dnia (odmowa) i następnego (ryba + wpis); dotychczasowe łowienie działa po ustawieniu `pump_running`.
- `lore-checker`: bez sprzeczności z kanonem. `convention-reviewer`: bez usterek.
- Factcheck do ręcznego sprawdzenia: [factcheck-test-13](../../human-tasks/done/factcheck-test-13.md) (obecnie na `master`, czeka na człowieka).

## Podsumowanie
Trzy niedociągnięcia z wyrównania naprawione w grze zgodnie z decyzją Rolanda: sen z listem gra po każdej nocy odszyfrowania, liczenie kresek słychać też w noc 7, a staw w Zalanym chodniku czeka na pompy — zamiast niego Wszebor za bandaż przynosi rano rybę z rząpia. Zmiana była na gałęzi `spec/2026-09-26-task13`, testy zielone. **Aktualizacja 2026-10-26:** scalona do `master` (`f56d146`, build 0.5.2 `e4c5edc`); factcheck-test-13 nadal czeka na sprawdzenie przez człowieka.
