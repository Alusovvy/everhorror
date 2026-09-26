<!--
Szablon zadania dla agenta AI. Skopiuj jako task_XX.md (XX = kolejny numer) i wypełnij sekcję Requirements.
Reszta pliku należy do agenta: dopisuje swoje sekcje pod wymaganiami i kończy plik podsumowaniem.
Zasady pracy z folderem: zob. INFO.md.
-->

Wymagania:
1. Poszerzenie obozu i zrobienie tego bardziej jako obóz w jaskini z elementami drewna, a nie że wszystko zabudowane deskami. Więcej troche przestrzeni dla gracza i NPCów. Zweryfikuj tez ich ustawienie na końcu czy nie jest nic zbyt krzywo.


---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Plan (przed startem)
**Stan:** obóz to długi, niski korytarz z desek (ok. 32 × 9,5 m, strop ok. 4 m, 110 słupów, szyny przez środek). Hala jest w `mine.tscn`, a rekwizyty i postacie ustawia `gen_camp.gd`.

**Decyzje do podjęcia przed startem:** [decision-task-08](../human-tasks/done/decision-task-08.md) (skala przebudowy, wielkość, kwatera Racibora, szyny, układ stref).

**Plan w wariancie rekomendowanym:**
1. Nowa jaskinia obozu budowana w `gen_camp.gd`: skalne ściany i reliefy z zestawu, sklepienie ok. 6 m, szerokość ok. 16 m. Drewno tylko jako konstrukcje: zagroda Racibora, rusztowania, podesty, odrzwia przy wyjściach. Stara hala zostaje usunięta z `mine.tscn`, a wyjścia na wschód i zachód oraz korytarz do starego wejścia zostają w tych samych miejscach.
2. Strefy w tej samej kolejności, luźniej, z ogniskiem w środku. Znaczniki NPC przesunięte razem ze strefami.
3. Weryfikacja ustawienia postaci:
   - skrypt sprawdza, czy każdy znacznik stoi na podłodze, poziomo i bez kolizji,
   - zrzuty z oczu gracza rano, w dzień i wieczorem.
4. Testy:
   - pełny zestaw w porcjach,
   - test chodzenia do wszystkich wyjść,
   - aktualizacja współrzędnych w `CLAUDE.md`, specyfikacji i `docs_v2`,
   - factcheck.

## Co zostało zrobione

### 1. Obóz w jaskini, więcej przestrzeni, weryfikacja ustawienia postaci
Decyzje: wszystkie w wariancie rekomendowanym ([decision-task-08](../human-tasks/done/decision-task-08.md), 2026-09-26).

**Przebudowa**
- Ze starej kopii poziomu (`scene/levels/mine.tscn`) usunąłem całą halę: 209 elementów (19 ścian obitych deskami, 98 słupów i belek, 24 panele, 48 płyt podłogi i stropu, 14 szyn, 5 wózków, 1 kamień). Zostały odrzwia przy wyjściach i wszystkie korytarze.
- Nowa jaskinia jest generowana w `tools/generators/gen_camp.gd` (węzeł `Camp/Cave`):
  - wymiary ok. 32 × 16 m (x 0–32, z −9–7), sklepienie ok. 6 m (wcześniej ok. 32 × 9,5 m i strop na 4 m),
  - skalne ściany z elementów `Wall_Cave` zestawu Loafbrr w skali 1,3, przesuwane losowo tylko na zewnątrz, więc użyteczna podłoga ma zawsze x 0,9–31,1 i z −8,1–6,1,
  - sklepienie z tych samych elementów położonych licem w dół (jest tak samo nierówne jak ściany), a za ścianami i nad sklepieniem pełna skała, żeby nigdzie nie prześwitywała pustka,
  - skalny filar od podłogi do sklepienia, skały w narożnikach, półki skalne wysoko na ścianach.
- Drewno jest tylko w konstrukcjach:
  - **zagroda Racibora**: palisada ok. 2,2 m bez dachu, brama od strony obozu, chorągiew Kniazia na poprzeczce za Raciborem,
  - **rusztowanie nad magazynem**: podest na słupach, na nim skrzynia, worek i lina,
  - **odrzwia** (słupy z belką) przy trzech wyjściach,
  - **słupy z latarniami** przy straganie, w kąciku pisarza i w zachodniej części.
- **Jeden stary tor** biegnie od wschodniego korytarza do magazynu. Na jego końcu stoją dwa wózki, w jednym stary urobek (świeci, opis bez zmian).

**Strefy** są w tej samej kolejności z zachodu na wschód, luźniej:
- zachód: izba chorych (północny zachód), posłania gracza i Bolka z namiotem i beczką z wodą (południowy zachód), posłanie Mirosława osobno pod północną ścianą,
- środek: ognisko z kłodami z każdej strony i kącikiem kucharki, na północ od niego wspólny stół,
- magazyn pod rusztowaniem przy południowej ścianie, skład prochu przy północnej, jak najdalej od ognia,
- wschód: zagroda dowódcy, stragan Tekli przy torze, kącik Hagiwary między zagrodą a ścianą, Sobek przy wschodnim wyjściu.

Nazwy węzłów, których używa gra (`MapTable/MapTableUse`, `Cloth/Bedroll/BedUse`, `Campfire/SeatUse`), i nazwy wszystkich znaczników zostały, więc zapisy, rozkład dnia i testy działają bez zmian w logice. W `world.tscn` przesunąłem dwa ogólne światła i trzy dźwięki (skrzypienie drewna jest teraz przy rusztowaniu i zagrodzie, kapanie pod sklepieniem).

**Ustawienie postaci („czy nie jest nic zbyt krzywo”)**
- Każda postać przy pracy (woda, wózek, proch, księga, posłanie chorego, ognisko) jest obrócona do tego, przy czym pracuje. Kąt liczy generator (`face()`), więc nie zależy od ręcznie wpisanych liczb. Przy okazji wyszło, że w starym układzie Hagiwara przy herbacie siedział tyłem do swojej skrzyni.
- Nowy test **`places`** sprawdza każdy z 35 znaczników obozu:
  - czy pod znacznikiem jest płaska podłoga na jego wysokości,
  - czy człowiek się tam mieści bez dotykania skały i solidnych rekwizytów (u siedzących tylko tułów, bo nogi idą pod stół),
  - czy nie stoi wewnątrz skały,
  - czy nie patrzy nosem w ścianę (poza modlącym się Anzelmem i obrażonym Bolkiem),
  - czy jest w jaskini.

  Test ma też próby kontrolne: postać wstawiona w filar i promień w ścianę muszą zostać wykryte. Dzięki nim wyszło, że skały z zestawu są w środku puste i postać w całości wewnątrz skały niczego „nie dotyka”, więc test sprawdza też rdzeń każdej skały. Na starcie złapał Teklę o 5 cm za blisko straganu (poprawione).
- Nowy test **`camp_walk`**: gracz z prawdziwą fizyką i klawiszem ruchu idzie po ścieżce nawigacyjnej od posłania do ogniska, do stołu z mapą w zagrodzie, do straganu, do kącika Hagiwary, do wschodniej barykady, korytarzem do starego wejścia, do desek w zachodnim chodniku i z powrotem. Każdy odcinek zajmuje 1–8 s, nigdzie się nie zacina.
- Zrzuty z oczu gracza rano (śniadanie), w dzień i wieczorem (ognisko, zachodnie wyjścia, kącik pisarza) oraz jasne widoki kontrolne ścian i sklepienia. Nikt nie wisi w powietrzu ani nie wchodzi w rekwizyty.

**Teksty:** w narracji „hala” → „jaskinia”: karta dnia 1, wstęp, sen, sceny przy ognisku, opisy Anzelma, Mirosława, Sobka, Dobrawy × Sabiny i odejście Mirosława przy rozliczeniu. Zdanie o trzeszczącym stropie „jak deska” brzmi teraz: „Gdzieś w sklepieniu trzeszczy raz, cicho, jak stary stempel pod ciężarem”. Kwestie górników się nie zmieniły, więc gwara też nie. Tekst o kwaterze zarządcy „za drewnianą ścianką” pasuje do palisady i został.

**Narzędzia:** `tools/level_probe.gd` (lista elementów poziomu z pozycjami i wymiarami, pomiar elementów zestawu); `screenshot.gd` umie ukryć węzły (widok z góry pod sklepieniem) i oświetlić poziom na płasko (`bright`).

**Dokumentacja:** `CLAUDE.md` (współrzędne, opis poziomu, testy), `tools/README.md`, docs_v2 (`03_poziomy.md` z nową tabelą stref, oprawa, fabuła, karta Mirosława), specyfikacja (`04_tresc/miejsca.md` z tabelą stref i „Dla agenta”, świat, słowniczek, fabuła, tydzień, Mirosław, oprawa, technika oraz wpis w `WDROZENIA.md` → „Zmiany agenta poza specyfikacją”). Specyfikacji nie commitowałem.

## Decyzje i założenia
- **Ognisko** stoi w punkcie (14; 0,2), trochę na zachód od środka, żeby wspólny stół i magazyn zmieściły się między nim a zagrodą. Wokół ognia są dwie kłody jak dawniej i dwie nowe od północy, bo ogień nie stoi już pod ścianą.
- **Posłanie Mirosława** jest osobno pod północną ścianą, obok jego „ciemnego kąta”. Pasuje do tego, że siada jak najdalej od ognia.
- **Namiot** przy posłaniach i **latarnię na słupie** w zachodniej części dodałem sam, bo zachodnia połowa była za ciemna i za pusta.
- **Tor** kończy się przy magazynie. Poza obozem sięga tylko do barykady we wschodnim korytarzu.
- **„Hala” → „jaskinia”** w narracji to moja decyzja (w specyfikacji oznaczona [ROBOCZE]). Nie użyłem słowa „grota”, żeby obozu nie mylić z Grzybową grotą.

## Czego potrzebuję od Ciebie
- Przejdź [factcheck-test-08](../human-tasks/factcheck-test-08.md), szczególnie punkty o wrażeniu przestrzeni, świetle i ustawieniu postaci. Tego żaden test nie oceni.
- Build robię tylko na Twoją prośbę. Ta zmiana dotyczy wyglądu całego obozu, więc nadaje się na nową wersję dla zespołu (0.5 albo 0.4.2).

## Test
- Automatyczne: pełny zestaw w dwóch porcjach razem z nowymi testami, **16/16 zaliczonych**: unit, lint, dialogue, schedule, **places**, **camp_walk**, day1, save_load, rzapie, night1, day2, kaplica, day3, expedition, drudzy, week. Oba nowe testy są w domyślnym zestawie `tools/run_tests.sh`.
- Ręczne: [factcheck-test-08](../human-tasks/factcheck-test-08.md) (12 punktów, ok. 20 min).

## Podsumowanie
Obóz jest teraz naturalną jaskinią ok. 32 × 16 m ze sklepieniem ok. 6 m, a nie długim korytarzem z desek. Drewno zostało tylko w konstrukcjach: zagroda Racibora, rusztowanie nad magazynem, odrzwia, latarnie na słupach i jeden stary tor z wózkami. Strefy są w dawnej kolejności, ale luźniej, a ognisko stoi w środku. Wyjścia, nazwy węzłów, rozkład dnia i zapisy działają bez zmian. Ustawienie postaci sprawdzają dwa nowe testy: `places` (35 znaczników: podłoga, kolizje, kierunek, z próbami kontrolnymi) i `camp_walk` (gracz dochodzi do każdej strefy i każdego wyjścia). Na zrzutach rano, w dzień i wieczorem nic nie stoi krzywo. Pełny zestaw testów przechodzi (16/16). Zostało Twoje przejście factchecku. Build zrobię, jeśli o niego poprosisz.
