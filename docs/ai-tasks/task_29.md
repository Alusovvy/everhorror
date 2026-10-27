<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_29: Historia postaci w zakładce „Ludzie”

Wymagania:
1. ZAD-9 (03_mechaniki/zadania_i_notes.md) ⬜: „**[DECYZJA 2026-10-27]** Zakładka „Ludzie” pokazuje też **krótką historię postaci**, tyle, ile gracz poznał z rozmów, i rozwija ją w miarę poznawania kolejnych elementów jej fabuły (Roland, 2026-10-27: „może ona się rozwijać wraz z poznawaniem więcej elementów fabuły danej osoby”). Dziś zakładka ma tylko rolę i trzy zdania (ZAD-7). Historia pisana słowami, bez liczb (NPC-13); nie zdradza niepoznanych faktów. [ROBOCZE] Źródłem faktów są tabele „Informacje i lore do przekazania” na kartach postaci ([postacie](../02_postacie/README.md)), a teksty wpisów piszemy przy wdrożeniu.”

Źródło: specyfikacja `67b762e` · ID: ZAD-9 · Zgłoszenia: —
Poziom: rozgrywka

Priorytet: pozycja 7 w „Czeka na wdrożenie” · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
**Systemy i pliki:** `script/notebook.gd` (zakładka „Ludzie”, dziś rola + zdrowie, głowa, stosunek; ZAD-7, NPC-13), dane postaci `data/npc/*.tres` z `tools/generators/write_story_data.js` (nowe pole z wpisami historii: tekst + warunek odsłonięcia, najpewniej flaga albo wpis zadania, który dialog już ustawia), stan w `GameState` (flagi rozmów). Fakty: tabele „Informacje i lore do przekazania” na kartach w `specification/02_postacie/*.md`; dla każdego wpisu trzeba wskazać istniejącą flagę z dialogu, w którym gracz to słyszy (`dialogue/*.dialogue`).

**Kierunek:** wpis odsłania się tylko po fladze z rozmowy (nic nie zdradza z wyprzedzeniem), kilka krótkich zdań na postać, bez liczb; lint (`tools/data_lint.gd`) sprawdza, że każda flaga warunku istnieje w dialogach.

**Ryzyka:** teksty wpisów są [ROBOCZE] i dotykają kanonu (karty postaci, LoreDoc): przejście `lore-checker` przed arkuszem, weto Rolanda. Kanon z 2026-10-27 (dziadek, amulet, kryształ z kaplicy) obowiązuje; „ktoś” z kaplicy zostaje nienazwany do rozstrzygnięcia karty [Kim jest „ktoś”](../../../specification/zgloszenia/2026-10-27_kim-jest-ktos.md) (Hrapek kontra D-11). Forma męska bohatera bez zmian. Zakres treści (ile wpisów na postać, które postacie) ustala wykonawca w analizie; przy 15 postaciach to duża porcja tekstu, więc warto zacząć od kilku najbliższych (np. Mirosław, Bolko, Tekla, Racibor) i resztę dopisać w tym samym zadaniu albo zaproponować podział.

Pełna analiza: `/ai-task analyze 29`.

## Analiza

> Przebieg z dashboardu 20261027-204119-analyze-29-84472e (Opus 5.5), 2026-10-27. Kolejność: brak zadań poprzedzających.

**Jak jest dziś.**
- `script/notebook.gd:119–132` (`_show_person`): nagłówek z imieniem i rolą, potem trzy zdania (zdrowie, głowa, stosunek), albo „Nie żyje.” / „Nie ma go już w kopalni.”. Lista poznanych z flag `met_<id>` (Drudzy wspólnie przez `drudzy_met`, `_met()`).
- `script/data/npc_data.gd:22` ma pole `history` (`@export_multiline`), wypełniane przez `tools/generators/write_story_data.js` (od linii 68) do `data/npc/*.tres`. **Gra go nigdzie nie pokazuje.** To streszczenie z karty (GDD albo [ROBOCZE]) z faktami, których gracz w rozmowach nie słyszy, i z liczbami („Urodzony w 1490 roku”, „W wieku 16 lat”). Pokazanie go wprost łamałoby ZAD-9 („nie zdradza niepoznanych faktów”, „bez liczb”), więc nie nadaje się na historię w notesie.
- Dialogi ustawiają drobne flagi przy każdym temacie, np. Mirosław `mir_asked_past` („Skąd jesteś?”), `mir_saw_charge`, `mir_asked_racibor`; Bolko `bolko_asked_grandpa`, `bolko_knows_fate`, `bolko_told_chapel`, `bolko_tremor`. Kryteria odsłonięcia mają więc gotowe punkty zaczepienia; nowych flag w dialogach w zasadzie nie trzeba.
- Karty postaci mają tabelę **„Informacje do przekazania”** (Informacja | Warunek), a nie „Informacje i lore do przekazania”, jak pisze ZAD-9. To ta sama tabela, tylko inna nazwa w regule; nie blokuje (zgłaszam w „Czego potrzebuję”).
- `tools/data_lint.gd:226–250` sprawdza, że każda czytana flaga jest gdzieś ustawiana; wzorce odczytu obejmują `has_flag("…")`, `required_flag`, `hidden_by_flag`. Nowe pole z flagą odsłonięcia trzeba do nich dopisać, inaczej literówka w warunku przejdzie bez błędu.
- Zapis gry: flagi już się zapisują, więc historia nie potrzebuje nowego stanu.

**Luki.** Brak danych z wpisami historii i warunkami, brak wyświetlania, brak lintu warunków, brak testu.

**Ryzyka.**
- **Kanon.** Wpisy to nowy polski tekst o przeszłości 15 postaci. Każdy wpis może tylko powtórzyć to, co postać mówi w dialogu (źródło: linia w `dialogue/*.dialogue` za flagą), bez dopowiadania z karty czy LoreDoc. Przejście `lore-checker` obowiązkowe. Kanon z 2026-10-27 (dziadek, amulet, kryształ z kaplicy) obowiązuje; „ktoś” z kaplicy zostaje nienazwany ([karta](../../../specification/zgloszenia/2026-10-27_kim-jest-ktos.md)). Szczegóły tekstów to [ROBOCZE] z wetem Rolanda.
- **Liczby.** „Bez liczb” dotyczy też lat i wieku („od dziecka”, „jako chłopak”, nie „16 lat”); liczebniki zapisywać słowami tylko tam, gdzie nie da się inaczej (lint polskich tekstów z task_22 może je i tak łapać).
- **Eksport.** task_25 pokazał, że eksport gubił pola `PackedStringArray`. Wpisy trzymać jako podzasoby (`Array[NpcStoryEntry]`), nie jako równoległe tablice napisów, i sprawdzić w buildzie do ogrania, że historia się wyświetla.
- **Wspólne pliki.** `write_story_data.js`, `notebook.gd`, `data_lint.gd` dotyka też task_22, `notebook.gd` task_27, `write_story_data.js` task_33: nie wdrażać ich równolegle (wiersz `Pliki:` poniżej).

**Zakres (decyzja wykonawcy, [ROBOCZE], weto Rolanda).** Wszystkie 15 postaci w tym zadaniu, po 2–4 krótkie wpisy na postać (razem około 40–50 zdań). Podział na dwa zadania zostawiłby ZAD-9 jako 🟡 i drugi raz te same pliki; teksty są krótkie, a każdy ma gotowe źródło w dialogu. Pierwszy wpis odsłania `met_<id>` (to, co gracz słyszy przy powitaniu), następne po flagach tematów z tabeli „Informacje do przekazania”. Drudzy z `FieldSchedule.DRUDZY` (`script/field_schedule.gd:12`: Ottokar, Sabina, Hieronim, Welf) mają własne wpisy, choć pojawiają się na liście razem. Postać martwa albo nieobecna: zdanie o stanie zostaje, historia pod nim też (to, co gracz wie, nie znika).

**Brak pytań do Rolanda** wymagających karty: reguła sama wskazuje źródło faktów i zostawia teksty wdrożeniu; zakres i forma powyżej są [ROBOCZE].

## Plan

1. **Dane.** Nowa klasa `script/data/npc_story_entry.gd` (`class_name NpcStoryEntry extends Resource`: `reveal_flag: StringName`, `text: String`, `@export_multiline`). W `NpcData` pole `@export var story: Array[NpcStoryEntry]`. Pole `history` zostaje jako notatka projektowa (komentarz w `npc_data.gd`: nie dla gracza, ZAD-9).
2. **Generator.** `tools/generators/write_story_data.js`: przy każdej postaci lista `story: [{flag, text}, …]`, zapis jako `[sub_resource type="Resource" …]` z `reveal_flag = &"…"`; uruchomić generator, nie edytować `.tres` ręcznie. Teksty w głosie notesu (słowa bohatera o postaci, czas przeszły/teraźniejszy jak wpisy zadań), każdy wpis 1–2 zdania, bez liczb, bez faktów spoza dialogu; przy każdym wpisie w generatorze komentarz ze źródłem (`dialogue/miroslaw.dialogue:54`).
3. **Widok.** `script/notebook.gd` `_show_person`: pod trzema zdaniami (albo pod „Nie żyje.”) nagłówek `[color=#ffb861]Co o niej/nim wiem:[/color]` i odsłonięte wpisy w kolejności z danych, jako jeden akapit albo kilka linii; bez wpisów nagłówek pomija. Napis nagłówka przez `tr()` (D-09). Sprawdzić, czy `person_text` przewija się przy dłuższym tekście (`scene/notebook.tscn`, `scroll_active`, rozmiar panelu); w razie potrzeby włączyć przewijanie.
4. **Lint.** `tools/data_lint.gd`: wzorzec odczytu `reveal_flag = &"([^"]+)"` w `data/npc/*.tres` (upewnić się, że `all_sources` obejmuje te pliki, inaczej dodać), plus sprawdzenie: każda postać z `GameState.NPCS` ma co najmniej jeden wpis i pierwszy wpis odsłania `met_<id>` (albo `drudzy_met`); tekst wpisu nie zawiera cyfr.
5. **Testy:** `tools/unit_test.gd`: nowy blok „task_29”: helper w `notebook.gd` (np. `static func story_text(npc_id) -> String` albo metoda w `GameState`, żeby test nie potrzebował sceny) zwraca pusty tekst bez flag, jeden wpis po `met_miroslaw`, drugi po `mir_asked_past`, i nie zawiera tekstu wpisu z nieustawioną flagą. Serwer po wdrożeniu uruchamia `unit lint dialogue` (dialogi bez zmian, ale `dialogue_test` czyta dane NPC); agent przed testami robi `--import` (nowa `class_name`).
6. **Kanon.** `lore-checker` na wszystkie wpisy z parami (wpis ↔ linia dialogu); sprzeczności poprawić, otwarte pytania do Rolanda w raporcie.
7. **Specyfikacja.** ZAD-9: „Dla agenta” ze wskaźnikami (`write_story_data.js` pole `story`, `notebook.gd` `_show_person`, lint), teksty wpisów oznaczone [ROBOCZE] (źródłem tekstów jest generator, nie kopia w spec). Na kartach postaci nic nie przepisywać. Lint spec, `cli.ts commit`, ledger `set-branch` (🧪).
8. **Arkusz** (poziom `rozgrywka`): jedna część `## Część: task_29` arkusza builda (D-27): poznać 3–4 postacie, otworzyć notes przed i po pytaniu o przeszłość; czy historia nie zdradza niczego przed rozmową, czy brzmi jak postać.

Pliki: script/data/npc_story_entry.gd, script/data/npc_data.gd, tools/generators/write_story_data.js, data/npc, script/notebook.gd, scene/notebook.tscn, tools/data_lint.gd, tools/unit_test.gd, docs/agent/README.md
Ryzyko: średnie

## Czego potrzebuję od Ciebie

- Nic przed wdrożeniem. Przy przeglądzie: weto co do zakresu (wszystkie 15 postaci w jednym zadaniu) i tekstów wpisów ([ROBOCZE]).
- Drobna niezgodność w specyfikacji: ZAD-9 mówi o tabelach „Informacje i lore do przekazania”, karty mają nagłówek „Informacje do przekazania”. Do poprawienia w regule przy okazji (Twoja sekcja, nie zmieniam).

## Przepływ (D-36)
Poziom `rozgrywka`: nowa sekcja historii postaci w notesie (kod, dane NPC i teksty widoczne dla gracza). Arkusz tylko jako jedna część `## Część: task_29` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `średnie`: nowa klasa danych, regenerowane `data/npc`, widok notesu i lint; format zapisu bez zmian.

## Podsumowanie

Analiza gotowa: historia w zakładce „Ludzie” to nowe wpisy w danych postaci (tekst + flaga z rozmowy), wyświetlane pod trzema zdaniami stanu, sprawdzane lintem i testem `unit`. Istniejące pole `history` zostaje niewidoczne, bo zawiera niepoznane fakty i liczby. Zakres [ROBOCZE]: wszystkie 15 postaci, 2–4 wpisy na postać. Karta decyzji nie była potrzebna; zadanie czeka na wdrożenie, nie równolegle z task_22, task_27 i task_33 (wspólne pliki).
