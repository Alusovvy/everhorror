<!--
Zadanie przygotowane przez agenta 2026-09-26 na prośbę z czatu („Przeanalizuj zmiany w specification i na ich bazie przygotuj task_09”).
Źródło: różnice w specyfikacji między commitem 54898e8 (punkt odniesienia z WDROZENIA.md) a bccb0d9 („changes v1”).
Decyzje zapadły 2026-09-26 (decision-task-09). Punkt 6 dopisany na prośbę z czatu tego samego dnia. Od startu prac wymagania zostają nietknięte, jak w każdym zadaniu.
-->

Wymagania:
1. Nowa postać **Hrapek** (`hrapek`) według karty `02_postacie/hrapek.md`:
   - spotkania w tunelach przy powrocie do obozu: od dnia 3 i dopiero po wysadzeniu zawału, w dniu 3 na pewno, potem 25%, co najmniej 2 spotkania do dnia 5,
   - mówi wierszem, jest wesoły, nazywa bohatera Cesarzem, rozmowy z nim nie kosztują czasu,
   - po trzech pytaniach z rzędu mówi „Czemu pyta? CO TYLE PYTA? Hrapek nie wie, Hrapek spróbuje się dowiedzieć” i ucieka,
   - poczytalność stała (20), nie spada i nie rośnie,
   - ginie w dniu 6: wracając do obozu, bohater znajduje ciało i pierścień niewidzialności.
2. Zadanie **„Ryba dla Hrapka”** (`ryba`) i przedmiot **Ryba** (`ryba`):
   - Hrapek jest głodny i prosi o rybę,
   - rybę daje Tekla, jeśli bohater oddał jej tobołek, a nie wydał go Raciborowi,
   - albo łowi się ją w stawie w jaskini: 4 h ze Wszeborem albo z Mirosławem,
   - nagroda: informacje o NIM (Pierwszym) i o tym, że bohater przypomina Hrapkowi dziadka.
3. **Zegar w notesie zamiast w rogu ekranu** oraz **dziennik czasu**: co danego dnia ile zajęło czasu.
4. **Wyszarzone opcje dialogowe (DIA-2, na testy i demo):** opcje ukryte z powodu braku zaufania albo przedmiotu są widoczne, wyszarzone, a w nawiasie jest powód. Nie dotyczy opcji, które czekają na dalszy etap historii.
5. **Porządki w specyfikacji po odpowiedziach zespołu:**
   - zamknąć pytania, na które padła odpowiedź (czas, dialogi, ekwipunek, interakcje, wyprawy),
   - poprawić zapis nowej karty, przedmiotu i zadania,
   - dopisać wpis w `WDROZENIA.md` i zsynchronizować `docs_v2`.
6. **Nowy koszt rozmów:** każda wybrana opcja dialogowa zużywa 5 minut, zamiast dzisiejszych 0,5 h naliczanych przy pierwszej odpowiedzi. Za darmo są pożegnania („Muszę już iść”) i proste przekazanie przedmiotu. Chodzi o to, żeby wejście w rozmowę i jedno zdanie nie zjadało aż 30 minut.

Kontekst:
- Diff specyfikacji `54898e8..bccb0d9`: nowa karta `02_postacie/hrapek.md` (autor: Roland), nowy wiersz w `04_tresc/przedmioty.md` i `04_tresc/zadania.md`, odpowiedzi dopisane do „Otwartych pytań” w `03_mechaniki/czas.md`, `dialogi.md`, `ekwipunek.md`, `interakcje.md`, `wyprawy.md`, oraz dopisek do reguły DIA-2.
- Pełna analiza i plan są niżej. Decyzje (podjęte 2026-09-26): [decision-task-09](../human-tasks/done/decision-task-09.md).

Kryteria akceptacji:
- W dniu 3, przy pierwszym powrocie z tunelu po wysadzeniu zawału, bohater spotyka Hrapka. Do końca dnia 5 spotyka go co najmniej dwa razy. W dniu 6 wraca i znajduje ciało.
- Rozmowa z Hrapkiem nie przesuwa zegara. Trzecie pytanie z rzędu kończy się ucieczką.
- W rozmowie z NPC każda wybrana opcja przesuwa zegar o 5 minut (dymek „−5 min”). Pożegnanie i samo oddanie przedmiotu nie kosztują nic. Jedno zdanie i wyjście to 5 minut, a nie 30.
- Ryba od Tekli (po oddanym tobołku) albo z łowienia (4 h). Po oddaniu jej Hrapkowi w notesie jest wpis o NIM i o dziadku.
- W rogu ekranu nie ma zegara. Notes [J] pokazuje godzinę i listę: dzień → co zajęło ile godzin.
- Opcja, do której brakuje zaufania albo przedmiotu, jest widoczna wyszarzona, np. „(potrzebna: lina)”. Opcje z dalszej części historii dalej są ukryte.
- Testy (unit, lint, dialogi, nowy scenariusz Hrapka) przechodzą. Specyfikacja ma markery ✅ i wpis w `WDROZENIA.md`.

Poza zakresem:
- Wybór rzeczy przed wyprawą i limit ekwipunku (EKW-9): zespół odpowiedział „na później”.
- Miejsca, które zmieniają się między wizytami, oraz przenoszenie obozu niżej. Zespół odpowiedział „tak, ale później”, więc tylko zapis w specyfikacji.
- Wybory z ograniczonym czasem: zespół odpowiedział „nie”.
- Rezygnacja z podświetlania obiektów: w demie zostaje.
- Build i wersja 0.5: tylko na prośbę.

Priorytet: średni (do potwierdzenia) · Termin: po zamknięciu task_08 (obóz), żeby nie mieszać niezacommitowanych zmian obozu z nowymi

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza zmian w specyfikacji (`54898e8` → `bccb0d9`)

| Plik | Zmiana | Co to znaczy dla gry | Punkt |
|---|---|---|---|
| `02_postacie/hrapek.md` (nowy) | Karta Hrapka: frakcja Inna, były rybak, uwięziony poziom niżej, żył na magicznych grzybach. Mówi wierszem, Cesarz, ucieka po 3 pytaniach. Tylko w tunelach, przy powrocie, ginie w dniu 6, zostawia pierścień niewidzialności | nowy NPC, nowy mechanizm spotkań przy powrocie, nowa scena śmierci | 1 |
| `04_tresc/przedmioty.md` | `ryba`: jedzenie, fabularna, od Tekli albo ze stawu | nowy przedmiot | 2 |
| `04_tresc/zadania.md` | `ryba` „Ryba dla Hrapka”: od Tekli (po oddanym tobołku) albo 4 h ze Wszeborem lub Mirosławem przy stawie | nowe zadanie, nowe opcje u Tekli, Wszebora i Mirosława | 2 |
| `03_mechaniki/czas.md` | ❓ zegar: „w notatniku zamiast w rogu, plus log czasu”. ❓ po tygodniu: „demo kończy się na podsumowaniu” | zmiana HUD i notesu. Podsumowanie końca tygodnia już jest (`_end_summary()`), więc tu wystarczy zamknąć pytanie i dopisać linijkę o Hrapku | 3, 5 |
| `03_mechaniki/dialogi.md` | DIA-2: na testy i demo wyszarzone opcje z powodem, tylko brak zaufania lub przedmiotu. ❓ wybory na czas: „Nie” | zmiana w oknie VN | 4, 5 |
| `03_mechaniki/ekwipunek.md` | ❓ EKW-9: „na później”. ❓ amulet: „już tak działa” | tylko specyfikacja (zob. uwagę o amulecie niżej) | 5 |
| `03_mechaniki/interakcje.md` | ❓ podświetlenie: „tak, ale w demie zostaje” | tylko specyfikacja | 5 |
| `03_mechaniki/wyprawy.md` | ❓ zmiany miejsc: „tak, uwzględnimy”. ❓ miejsca demo: „pewnie się zmienią”. ❓ obóz: „będzie się przenosił niżej, później” | tylko specyfikacja, pozycje „na później” | 5 |

`zgloszenia/` nie ma nowych plików (jest tylko README).

## Co już jest w grze (mniej pracy, niż wygląda)
- **Zegar w notesie już jest**: nagłówek notesu pokazuje „Dzień N · GG:MM”. Do zrobienia jest usunięcie zegara z rogu ekranu, wyraźniejszy zegar w notesie i dziennik.
- **Każde przesunięcie czasu ma już powód**: `GameState.advance_time(hours, reason)` dostaje go ze wszystkich miejsc („Rozmowa z Bolkiem”, „Powrót do obozu”, „Mirosław wysadza zawał”, opisy obiektów, akcje w dialogach). Dziennik czasu to zapisanie tych wywołań i dodanie ich do zapisu gry.
- **Demo kończy się podsumowaniem**: `StoryDirector._end_summary()` wypisuje żyły, dziadka, ścianę, ludzi. Dopiszę Hrapka.
- **Dialogue Manager 4.1 daje dane do wyszarzania**: każda odpowiedź ma `is_allowed` i `condition_as_text`, a menu odpowiedzi umie pokazywać zablokowane (`hide_failed_responses`, dziś ustawione na `true` w `vn_balloon.gd`). Warunki w naszych dialogach to koniunkcje (`has_flag(...) and not has_flag(...)`), więc da się sprawdzić każdy człon osobno i ustalić, czy blokuje tylko zaufanie (`rep`) albo przedmiot (`has_item`).
- **Tobołek**: zadanie `towar` ma stan `oddany` albo `wydany`, więc warunek na rybę od Tekli jest gotowy.
- **Uwaga na zawał**: flaga `west_blasted` jest **kasowana**, kiedy ginie Mirosław (zabiera ze sobą zachodni chodnik). Warunek pojawienia się Hrapka potrzebuje osobnej, trwałej flagi (np. `hrapek_free`), inaczej Hrapek znikałby po śmierci Mirosława.
- **Amulet nie ma działania mechanicznego.** Działa w tekstach: grzeje się we śnie, przy ścianie i przy Ottokarze, parzy przy złej odpowiedzi na ścianie. Nie podpowiada żył ani rozwiązań. Odpowiedź zespołu (2026-09-26): „może będzie podpowiadał, do ustalenia”. W specyfikacji opiszę dzisiejsze działanie jako fabularne, a podpowiedzi zostają pytaniem ❓. W tym zadaniu amulet się nie zmienia.
- **Koszt rozmowy** (do punktu 6): `VN.TALK_HOURS = 0.5` jest naliczane raz, przy pierwszej odpowiedzi bez `[#leave]` (`vn.gd`, `response_picked`). Sceny (`VN.play`: sny, ściana, ognisko, ogłoszenia) nic nie kosztują. Specyfikacja opisuje to w CZAS-2/3/4, DIA-5, NPC-14 i `07_balans.md`.

## Niespójności w karcie Hrapka (rozstrzygnięte 2026-09-26)
1. **Rybak czy górnik:** rybak, który potem został górnikiem. Na pytanie „Kim byłeś?” Hrapek odpowiada w stylu „Górnikiem… a nie, nie, nie, rybakiem!”. W karcie poprawię rolę.
2. **Dwa spotkania a śmierć w dniu 6:** minimum 2 spotkania do dnia 5 (gwarancja przy pierwszym powrocie w dniu 5).
3. **Dzień 3 a zawał:** pierwsze spotkanie przy pierwszym powrocie od dnia 3, jeśli zawał jest wysadzony, a jeśli nie, to przy pierwszym powrocie po wybuchu.
4. **Zapis w tabelach:** ID w apostrofach (`'ryba'` zamiast `` `ryba` ``), zepsute tabele (brak wiersza `|---|`), szablonowe „Stan na RRRR-MM-DD” i „[Imię i przydomek]”, ryba „nie zużywa się”, choć jest oddawana. Poprawię to przy aktualizacji specyfikacji.
5. **Kolizja z „Czternastoma kreskami”:** „na razie zostawiamy”. Hrapek w demie nie nawiązuje do chleba, lampy ani stukania. Kanon należy do Ren.

## Plan
**1. Hrapek**
- Dane:
  - karta `NpcData` w `write_story_data.js` (frakcja Inna, poczytalność 20, zdrowie 100),
  - model w `CharacterModel` z części Quaternius: łysy, blady, bez koszuli, w podartych portkach, skulony, trochę mniejszy,
  - wpis w „Ludziach” w notesie („głowa: wciąż ta sama, żyje we własnym pałacu”).
- Poczytalność: Hrapek jest wyłączony z nocnych spadków, z załamań i z odejść.
- Spotkanie (decyzja 1A): po wybraniu „Obóz” na mapie [M], zanim ekran się ściemni, słychać szuranie i otwiera się scena VN z żywym portretem Hrapka (`VN.play`, bez kosztu czasu). Po niej powrót idzie dalej.
- Terminy (decyzja 2a):
  - pierwsze spotkanie przy pierwszym powrocie od dnia 3, o ile jest flaga `hrapek_free` (inaczej przy pierwszym powrocie po wybuchu),
  - potem 25% przy każdym powrocie, najwyżej raz dziennie,
  - jeśli rano w dniu 5 bohater spotkał go mniej niż 2 razy, pierwszy powrót w dniu 5 daje spotkanie na pewno,
  - ziarno losowania jak u Drugich (dzień, miejsce, godzina), więc wczytanie gry nie zmienia wyniku.
- Dialog `dialogue/hrapek.dialogue`, cały wierszem, oznaczony [ROBOCZE] dla Rolanda i Ren:
  - 5–6 pytań: co tu robi, kim jest Cesarz, kim był („Górnikiem… a nie, nie, nie, rybakiem!”), co je, gdzie jest pałac, czy zna dziadka,
  - licznik pytań w jednej rozmowie; trzecie pytanie z rzędu → kwestia ucieczki i koniec rozmowy,
  - oddanie ryby i pożegnanie nie liczą się jako pytania.
- Śmierć (decyzja 3a): noc 5 → 6. Przy pierwszym powrocie w dniu 6 lub później scena VN: ciało w chodniku, opcje „Zabierz pierścień” / „Zostaw go”. Przyczyna śmierci niedopowiedziana („jakby coś go dopadło”).
  - Pierścień (`pierscien`, decyzja 4a) jest tylko fabularny: opis w plecaku i linijka w podsumowaniu tygodnia.
  - Tylko jeśli bohater spotkał go choć raz. Inaczej to ciało obcego człowieka, bez sensu dla gracza.
- Podsumowanie tygodnia: linijka o Hrapku.

**2. Ryba**
- Przedmiot `ryba` i zadanie `ryba` z wpisami: `start`, `od_tekli`, `zlowiona`, `oddana`, `za_pozno`.
- Tekla: nowa opcja przy `quest_state("towar") == "oddany"` i aktywnym zadaniu `ryba`.
- Wszebor i Mirosław (decyzja 5a): opcja „Chodź ze mną na ryby do stawu” przy aktywnym zadaniu. Kosztuje 4 h (`can_afford(4)`), ekran ściemnia się na krótką narrację i bohater dostaje rybę.
  - Staw leży w Zalanym chodniku (dopiszę opis w miejscu). To zgodne z NPC-11: pomoc NPC to czas, a nie chodzenie za graczem.
- Oddanie ryby Hrapkowi: informacje o NIM i dziadku oraz notatka. Zaufanie według karty (brak liczby, przyjmę +10 [ROBOCZE]).

**3. Zegar i dziennik czasu**
- HUD: bez zegara. Godzina zostaje tylko w notesie i w oknie rozmowy VN (decyzja 6a). Linijka stanu bohatera („ranny · gorączka”) i dymki z kosztem czasu zostają.
- `GameState.time_log`: dzień → lista wpisów (od, do, godziny, powód), w zapisie gry. `SAVE_VERSION` 4, starsze zapisy wczytują się z pustym dziennikiem.
- Notes: nowa zakładka **„Czas”**:
  - na górze duży zegar i „do nocy zostało 6 h”,
  - pod nim dni od najnowszego, np. „07:00–07:30 · Rozmowa z Bolkiem · 0,5 h”, i suma dnia,
  - noc jako jedna linijka („Noc: sen”).

**4. Wyszarzone opcje**
- `vn_balloon.gd`: `hide_failed_responses = false` i własna ocena każdej zablokowanej odpowiedzi:
  - dzielę `condition_as_text` na człony `and` i sprawdzam każdy (`Expression` z `GameState` jako bazą),
  - pokazuję opcję wyszarzoną tylko wtedy, gdy nie przechodzą **wyłącznie** człony `rep(...) >= N` albo `has_item(...)`,
  - warunki z `or` i wszystko inne (flagi, dzień, pora, zadania, poczytalność) zostają ukryte, tak jak dziś.
- Powód słowami, bez liczb (NPC-13): „(potrzebna: lina)”, „(Bolko jeszcze ci nie ufa)”. Zablokowanej opcji nie da się wybrać.
- Przegląd opcji, które wymagają samego przedmiotu, a byłyby spoilerem (np. „Mam twój tobołek” widoczne od dnia 1): dopiszę im warunek zadania, żeby pokazywały się dopiero wtedy, kiedy gracz wie, o co chodzi.
- Przełącznik w OPTIONS „Show locked choices”, domyślnie włączony na demo (`Settings`, decyzja 7a).

**6. Rozmowa: 5 minut za opcję**
- `vn.gd`: zamiast jednorazowego `TALK_HOURS = 0.5` każda wybrana odpowiedź w rozmowie z NPC kosztuje `TALK_MINUTES = 5` (5/60 h).
- Za darmo:
  - odpowiedzi z `[#leave]` (pożegnania),
  - odpowiedzi z nowym znacznikiem `[#free]` (proste oddanie przedmiotu, np. „Masz, twój tobołek”),
  - sceny przez `VN.play` (sny, ściana, ognisko, ogłoszenia, spotkania z Hrapkiem), bez zmian.
- Przejrzę wszystkie 18 plików `.dialogue` i oznaczę `[#free]` każde samo oddanie przedmiotu. Lint sprawdzi, czy `[#free]` stoi tylko przy odpowiedziach, które oddają przedmiot, a nie przy zwykłej rozmowie.
- Akcje z własnym kosztem w dialogach (np. „Praca przy pompach” 2 h, „Kości z Sobkiem” 1 h, łowienie 4 h) dalej kosztują swoje. Ich opcja nie dolicza 5 minut, żeby koszt był równy temu, co widać.
- Wyświetlanie:
  - zegar w oknie VN przesuwa się przy każdej opcji,
  - po zamknięciu rozmowy jeden dymek z sumą („−20 min · Rozmowa z Bolkiem”) zamiast dymka przy każdej opcji,
  - w dzienniku czasu jedna pozycja na rozmowę.
- Nowy format czasu: `GameState.duration_text()` pisze „5 min”, „1 h 20 min”, „2 h”. Czas liczony w minutach, żeby nie zbierać błędów zaokrągleń z 5/60 h.
- Balans: krótka wymiana (2–3 opcje) kosztuje 10–15 minut zamiast 30, a długa (8+ opcji) więcej niż dziś. Sprawdzę na scenariuszu tygodnia, ile godzin dziennie zjadają rozmowy, i wpiszę to do `07_balans.md`.

**5. Specyfikacja i docs_v2**
- Nowe reguły:
  - CZAS: zegar w notesie i dziennik czasu,
  - PET: koniec dema na podsumowaniu,
  - DIA-2: wyszarzone opcje.
- Zamknięte pytania: wybory na czas, podświetlenie.
- Amulet: dzisiejsze działanie opisane jako fabularne. Podpowiedzi zostają pytaniem ❓ („do ustalenia”).
- Koszt rozmowy: CZAS-2/3/4, DIA-5, NPC-14 i `07_balans.md` już przepisane na 5 minut za opcję z markerem ⬜ (2026-09-26). Po wdrożeniu ⬜ → ✅.
- „Na później” (⬜ z uwagą, bez wdrażania): EKW-9, zmiany miejsc między wizytami, obóz przenoszony niżej.
- Karta Hrapka poprawiona (rola: rybak, potem górnik; terminy spotkań; śmierć; pierścień), [ROBOCZE] przy wszystkim, co dopisałem sam. Liczby w `07_balans.md`: 25%, 4 h, zaufanie.
- `WDROZENIA.md`:
  - wpis z commitem `bccb0d9`,
  - aktualizacja pozycji 2 w „Czeka na wdrożenie” (EKW-9: na później, nie „czeka na odpowiedź”).
- docs_v2: NPC, questy, czas, HUD.

**Testy**
- `unit`: reguły spotkań Hrapka (dzień 3, 25%, gwarancja drugiego spotkania, śmierć w dniu 6), dziennik czasu, rozbiór warunków do wyszarzania.
- `unit`: `duration_text()` („5 min”, „1 h 20 min”), suma kosztu rozmowy.
- `lint`: nowe ID (`hrapek`, `ryba`, `pierscien`), `[#free]` tylko przy oddaniu przedmiotu.
- `dialogue` i scenariusze: dzisiejsze oczekiwania „0,5 h za rozmowę” przepisane na 5 minut za opcję.
- `dialogue`: Hrapek, ucieczka po 3 pytaniach, ryba u Tekli, Wszebora i Mirosława.
- Nowy scenariusz `hrapek`: tydzień powrotów, oddanie ryby, ciało w dniu 6.
- Krótki test E2E przez `godot-runtime` (w tle): [J] → zakładka „Czas”, brak zegara na HUD, wyszarzona opcja w rozmowie.
- Pełny zestaw tylko za Twoją zgodą. Na koniec factcheck `docs/human-tasks/factcheck-test-09.md`.

## Co zostało zrobione
Przygotowanie (wcześniej): analiza zmian, plan i [plik decyzji](../human-tasks/done/decision-task-09.md). Przed startem (2026-09-26) ustaliliśmy w czacie:
- najpierw commit task_08 (zrobiony: `d39bbb9`),
- kwestie Hrapka piszę sam jako [ROBOCZE],
- uruchamiam tylko unit, lint, dialogi i nowy scenariusz Hrapka.

### 1. Hrapek
- Karta w danych (`write_story_data.js`): frakcja Inna, rola „rybak, potem górnik”, poczytalność stała (20). `GameState.FIXED_SANITY` sprawia, że noc, wstrząs i rozmowy jej nie ruszają.
- Wygląd z części Quaternius (`scene/characters/hrapek_model.tscn`): łysy, blady, bez koszuli, w podartych portkach, skulony, mniejszy o 12%. Dodałem do `CharacterModel` opcję `keep_body`, która zostawia całe ciało bazowe, bo zwykle zostaje sama głowa pod ubraniem. Ciało bazowe jest muskularne, więc to nie jest prawdziwy „Golum”. Na demo wystarczy, lepszy wygląd wymaga własnego modelu.
- Spotkania (`StoryDirector.hrapek_due()`, `_hrapek_on_the_way_back()`):
  - po wybraniu „Obóz” na mapie [M], przed drogą, otwiera się scena VN,
  - pierwsza okazja: pierwszy powrót od dnia 3, jeśli zawał jest wysadzony (trwała flaga `hrapek_free`, żeby Hrapek nie znikał, kiedy Mirosław zabiera zachodni chodnik),
  - potem 25% raz dziennie, a drugie spotkanie na pewno przy pierwszym powrocie w dniu 5,
  - losowanie zależy od dnia, miejsca i godziny, więc wczytanie gry go nie zmienia.
- Dialog `dialogue/hrapek.dialogue`, cały wierszem [ROBOCZE]:
  - sześć pytań: co tu robi, kim jest Cesarz, kim był („Górnikiem… a nie, nie, nie! Rybakiem!”), co je, gdzie jest pałac, czy znał dziadka,
  - trzecie pytanie z rzędu → „Czemu pyta? CO TYLE PYTA?…” i ucieczka; oddanie ryby i pożegnanie nie są pytaniami,
  - rozmowa nic nie kosztuje.
- Śmierć: w nocy z dnia 5 na 6. Przy pierwszym powrocie w dniu 6+ scena z ciałem: „Zabierz pierścień” / „Zostaw go”. Scena jest tylko wtedy, gdy bohater spotkał Hrapka. Pierścień (`pierscien`) działa tylko fabularnie.
- Notes → Ludzie: „Wciąż ten sam. Żyje we własnym pałacu…”, po znalezieniu ciała „Nie żyje.”. Podsumowanie tygodnia i podsumowanie wyprawy wspominają Hrapka.

### 2. „Ryba dla Hrapka”
- Przedmiot `ryba` i zadanie `ryba` z wpisami `start`, `od_tekli`, `zlowiona`, `oddana`, `za_pozno`.
- Tekla: „Masz może jakąś rybę?”. Daje ją raz, jeśli bohater oddał jej tobołek; bez tego odmawia.
- Wszebor i Mirosław: „Chodź ze mną na ryby do stawu. (4 h)”. Staw jest w Zalanym chodniku, łowi się bez wyprawy (NPC-11). Wieczorem, gdy do nocy zostało mniej niż 4 h, odpowiadają „jutro”. Z Mirosławem wyprawa liczy się jak wieczór w towarzystwie (+5 poczytalności).
- Za rybę Hrapek mówi o NIM (bez rymów, cicho: „ON cię już raz dopadł…”) i o dziadku („byłeś starszy, broda siwa”), zaufanie +10. Wpis w notesie.
- Nowe kwestie Mirosława mają wersję w gwarze (3 linie).

### 3. Zegar w notesie i dziennik czasu
- HUD nie ma już zegara. Stan bohatera („ranny · gorączka”) jest w rogu, a dymki pokazują czas w minutach („−15 min · Rozmowa z Teklą”).
- Notes [J] ma nową zakładkę **„Czas”**:
  - duży zegar i „Do nocy zostało: …”,
  - pod nimi dni od najnowszego, z sumą: „07:00 · Rozmowa z Bolkiem · 15 min”, noc to linijka „Sen”.
- `GameState.time_log` zapisuje każde przesunięcie czasu, cała rozmowa to jedna pozycja. Dziennik jest w zapisie gry (wersja zapisu 4); starsze zapisy wczytują się z pustym dziennikiem.
- Godzina jest dalej w oknie VN i przesuwa się przy każdej opcji.

### 4. Wyszarzone opcje (DIA-2)
- `script/response_lock.gd` dzieli warunek opcji na człony „and”. Opcja jest szara z powodem tylko wtedy, gdy nie przechodzą **wyłącznie** człony `has_item(...)` albo `rep(...) >= N`: „(potrzebne: lina)”, „(Bolko jeszcze ci nie ufa)”. Wszystko inne (flagi, dzień, zadania, warunki z „albo”) zostaje ukryte. Szarej opcji nie da się wybrać.
- Przełącznik w OPTIONS: „Show locked choices”, domyślnie włączony.
- Przegląd wszystkich dialogów: 7 opcji dostało warunek zadania albo zdarzenia, żeby szarość nie zdradzała historii (tobołek dopiero po wyłowieniu, kryształ dopiero po otwarciu ściany, obuch przy zadaniu kilofa, grzyb przy gorączce) i nie wracała po oddaniu przedmiotu (lonty, obuch).

### 6. 5 minut za opcję
- `VN.TALK_MINUTES = 5` za każdą wybraną odpowiedź w rozmowie z NPC. Za darmo:
  - pożegnania `[#leave]`,
  - proste oddanie przedmiotu `[#free]` (14 odpowiedzi w 11 dialogach; lint pilnuje, żeby `[#free]` stało tylko tam, gdzie coś się oddaje),
  - odpowiedzi, które uruchamiają akcję z własnym kosztem. Ich 5 minut wraca, także gdy akcja wykonuje się po rozmowie (wysadzenie zawału), więc „(4 h)” kosztuje równo 4 h.
- Zegar w oknie VN przesuwa się przy każdej opcji. Po zamknięciu rozmowy jest jeden dymek z sumą i jedna pozycja w dzienniku.

### 5. Specyfikacja i docs_v2
Specyfikację zmieniłem, ale nie commitowałem:
- reguły ⬜ → ✅: CZAS-2, CZAS-4, DIA-2 (wyszarzanie), DIA-5, NPC-14,
- nowe reguły CZAS-14 (zegar tylko w notesie i VN) i CZAS-15 (dziennik czasu),
- UI-2 i ekrany HUD, VN, opcje, notes; ZAP-4 i ZAP-5; balans (koszt rozmowy, liczby Hrapka i ryby),
- zamknięte pytania: czas, koniec dema, wybory na czas,
- „na później”: EKW-9, zmiany miejsc między wizytami, obóz przenoszony niżej (⬜ z uwagą); podświetlenie jako 💡; amulet dalej ❓ („może będzie podpowiadał, do ustalenia”),
- karta Hrapka przepisana: treść Rolanda zostaje, poprawione tabele i szablonowe pola, dopisane terminy, śmierć i pierścień, [ROBOCZE] przy moich dodatkach,
- przedmioty `ryba` i `pierscien`, zadanie `ryba` z wpisami, staw w Zalanym chodniku,
- `WDROZENIA.md`: pozycje 3–6 zdjęte z „Czeka na wdrożenie”, wpis w „Zmiany agenta poza specyfikacją”.

Lint specyfikacji (`node dashboard/cli.ts lint`): 0 błędów, 0 uwag. Docs_v2 zsynchronizowane: czas, dialogi, NPC, zadania, postacie (plus krótka karta Hrapka), interfejs, zapis i opcje. CLAUDE.md i tools/README też.

## Decyzje i założenia
- **Pozostałe 5 minut przy akcjach:** zwrot działa na każde `advance_time` i każde `request()` wywołane przez odpowiedź, więc nowe akcje z ceną nie wymagają oznaczania.
- **Mieszane opcje:** jeśli opcja wymaga i przedmiotu, i np. flagi, a flagi brakuje, zostaje ukryta. Szara jest tylko wtedy, gdy brakuje samego przedmiotu albo zaufania.
- **Nazwy przedmiotów w nawiasie:** małą literą („lina”), nazwy własne bez zmian („Tobołek Tekli”, „Daleki Klejnot”). Forma „potrzebne:” pasuje do każdego rodzaju.
- **„Mam twój tobołek”** kosztuje 5 minut, bo sam tobołek oddaje się dopiero w następnym wyborze („Nikomu nie powiem” / „Nie. Masz swój tobołek”).
- **Hrapek i stukanie „Czternastego”:** zgodnie z odpowiedzią zespołu brak nawiązań.
- **Zaufanie Hrapka +10 za rybę** i **licznik pytań zerowany przez rybę** to moje liczby [ROBOCZE].
- **Balans:** typowa rozmowa (2–4 opcje) to 10–20 min zamiast 30, długa (8+ opcji) kosztuje więcej niż dotąd. To szacunek z dialogów. Pomiar na scenariuszu tygodnia wymaga pełnego zestawu testów, na który nie było zgody.

## Czego potrzebuję od Ciebie
- **Zgody na trzy scenariusze** `day1`, `day2`, `rzapie`: przeliczyłem w nich godziny na 5 minut za opcję (np. dzień 1: 06:15 zamiast 07:00), ale ich nie uruchamiałem. Najlepiej od razu cały zestaw w porcjach, bo nowy koszt dotyka każdej rozmowy.
- **Rolanda i Ren:** przejrzenie kwestii Hrapka (wiersze) i tego, co mówi o NIM i o dziadku.
- Przejście [factcheck-test-09](../human-tasks/factcheck-test-09.md).
- Build tylko na prośbę (proponuję 0.5 razem z obozem z task_08).

## Test
- Automatyczne (uruchomione, zgodnie z ustaleniem):
  - `unit`: 29 nowych sprawdzeń (czas trwania, dziennik i jego zapis, powody wyszarzenia, reguły spotkań Hrapka), wszystkie OK,
  - `lint`: nowa reguła `[#free]` (14 oznaczeń, 0 błędnych),
  - `dialogue`: nowa część task_09 (spotkanie, ucieczka po trzecim pytaniu, rozmowa bez kosztu, ryba u Tekli, Wszebora i Mirosława, zjedzenie ryby, ciało i pierścień, znaczniki `[#free]`/`[#leave]`),
  - nowy scenariusz `hrapek` w prawdziwym świecie: dwa spotkania, 5 minut za opcję z wpisem w dzienniku, szara opcja u Bolka, brak zegara, śmierć w nocy 5→6, ciało i pierścień w dniu 6.
  
  Wszystkie przechodzą.
- Nie uruchomione (czekają na zgodę): pełny zestaw, w tym przeliczone `day1`, `day2`, `rzapie`.
- Ręczne: [factcheck-test-09](../human-tasks/factcheck-test-09.md) (22 punkty, ok. 40 min).

## Podsumowanie
Wszystkie sześć punktów jest zrobionych:
- **Hrapek** spotyka bohatera przy powrotach z tuneli. Mówi wierszem, ucieka po trzech pytaniach, ginie w nocy z dnia 5 na 6 i zostawia pierścień.
- **„Ryba dla Hrapka”:** ryba od Tekli albo z łowienia. Za rybę Hrapek mówi o NIM i o dziadku.
- **Zegar** jest tylko w notesie (zakładka „Czas” z dziennikiem dni) i w oknie rozmowy.
- **Opcje zablokowane** przez zaufanie albo przedmiot są widoczne, szare, z powodem.
- **Rozmowa** kosztuje 5 minut za opcję. Pożegnanie, oddanie przedmiotu i akcje z własną ceną nie kosztują nic ekstra.
- **Specyfikacja i docs_v2** są zaktualizowane (bez commita).

Uruchomione testy (unit, lint, dialogi, nowy scenariusz `hrapek`) przechodzą. Stare scenariusze z przeliczonymi godzinami czekają na Twoją zgodę.
