<!--
Szablon zadania dla agenta AI. Skopiuj jako task_XX.md (XX = kolejny numer) i wypełnij sekcję Requirements.
Reszta pliku należy do agenta: dopisuje swoje sekcje pod wymaganiami i kończy plik podsumowaniem.
Zasady pracy z folderem: zob. INFO.md.
-->

Requirements:
1. Expand the camp to accommodate more NPCs, it should have this table with leader, some supplier area, some common area with table and fire when there is cooking and eating and some storage area. Each area will potentialy have NPCs thata are standing there for player interactions and it changes over time.
2. Preapre 3 more NPCs
3. Prepare 3 more locations
4. In one location include a VN novel like interaction with a wall that is a riddle, try to connect it to current story
5. Improve everything you think can be improved
6. Game should take now 1 day longer

<!-- Opcjonalne (usuń, jeśli niepotrzebne): -->
Kontekst:
Rozszerzamy demo po to żeby lepiej wybadać projekt 

Kryteria akceptacji:
1. The camp was expanded to accomodate listed locations and more NPCs.
2. There are 3 new NPCs with interactions and quests.
3. There are three new locations
4. Demo now takes 1 day longer 

Poza zakresem:


Priorytet: High

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione

### 1. Rozbudowany obóz ze strefami ✅
Hala jest podzielona drewnianą ścianką na dwie sale. Obóz generuje `tools/generators/gen_camp.gd`.
- **Zachodnia sala:**
  - **Posłania.** Twoje, Bolka i Mirosława.
  - **Kuchnia i wspólny stół.** Ognisko z rożnem i kociołkiem, kącik kucharki (skrzynki, wiadro, garnki), długi stół z ławami, talerzami, kubkami i świecą.
  - **Magazyn.** Skrzynie i beczki, stół z narzędziami, osełka, wózek ze starym urobkiem, który świeci na niebiesko.
  - **Skład prochu.** W najdalszym kącie, jak najdalej od ognia: beczki z prochem i skrzynia z lontami.
- **Wschodnia sala (kwatera zarządcy):**
  - **Stół dowódcy.** Stół z mapą, świecznik, zwoje, księga zarządcy na pulpicie, chorągiew Kniazia i jedyne w obozie łóżko.
  - **Zaopatrzenie.** Stragan kwatermistrzyni przy wyjściu na wschód, z linami, olejem, beczkami i półką z butelkami.
- **Obóz żyje według pory dnia** (`script/camp_schedule.gd`). Każdy NPC ma swoje miejsce na każdą porę:
  - rano (do 8:00) śniadanie: Tekla gotuje, Bolko i Racibor jedzą przy stole, Mirosław siedzi sam przy ognisku,
  - w dzień (8–18) każdy pracuje w swojej strefie: Racibor przy stole z mapą, Tekla za ladą, Bolko klęczy przy urobku, Mirosław kuca przy prochu,
  - 18–20 kolacja, potem wieczór.
- **Stan fabuły ma pierwszeństwo przed porą dnia:**
  - Mirosław na krawędzi siedzi w ciemnym kącie,
  - Bolko, który ci nie ufa, stoi odwrócony plecami,
  - wydana Raciborowi Tekla siedzi pod strażą przy jego stole,
  - Dobrawy nie ma w dniu 1 ani po wyjeździe z kryształem. W dniu 2 znika też w tunelach między 12 a 16.
- Kiedy godzina się zmienia, postacie przechodzą na swoje miejsca podczas krótkiego mrugnięcia ekranu. Dialogi mogą pytać, gdzie ktoś jest, i kwestia na powitanie zależy od miejsca.

### 2. Trzy nowe postacie ✅
Karty są w `data/npc/*.tres`, oznaczone jako robocze, do przeglądu przez Ren.

| Postać | Frakcja | Rola | Zadanie |
|---|---|---|---|
| **Racibor**, zarządca | Ekspedycja | zarządca z nadania Kniazia, stół dowódcy | **„Złoża dla Kniazia”:** zaznacz dwie żyły błękitu. Nagroda to odpis raportu z archiwum sprzed 40 lat. Daje kwit na linę. Można mu wydać Teklę. |
| **Tekla**, kwatermistrzyni | Inna (Konfraternia kupiecka) | wydaje liny i olej, gotuje | **„Tobołek Tekli”:** wyłów tobołek z rząpia. W środku jest list Konfraterni, bo Tekla skupuje błękit na lewo. Możesz jej go oddać (lina, dług wdzięczności i historia jej ojca, który sprzedał dziadkowi proch) albo wydać Raciborowi (Tekla trafia pod straż). |
| **Dobrawa z Initium** | Drudzy | Druga w żelaznej masce, przybywa w dniu 2 | **„Ściana w kaplicy”:** wskazuje kaplicę, daje słowniczek sanctinu, a potem prosi o kryształ z niszy. Jeśli go dostanie, wyjeżdża przed świtem. |

- Modele Quaterniusa (CC0), wszystkie z animacjami:
  - Racibor ma zielony strój zwiadowcy z naramiennikiem i brodę,
  - Tekla ma pierwszą w grze kobiecą postać (strój chłopski, koki),
  - Dobrawa ma ciemny płaszcz z kapturem i **żelazną maskę** wygenerowaną z kodu. W LoreDoc Drudzy noszą maski.
- Dochodzą **pozy przy pracy:** krzątanie się przy kociołku, klęczenie przy urobku, gest magii przy wózkach. Kiedy zaczynasz rozmowę, postać staje albo mówi na siedząco.
- **Mirosław i Bolko dostali nowe wątki:**
  - Mirosław rozpoznaje, że zawał w upadowej zrobił ładunek.
  - Bolko wskazuje kaplicę, mówi, co starzy gadali o Pierwszych (podpowiedź do zagadki), i przeżywa prawdę o dziadku.
  - Obaj mają nowe kwestie na dzień 2 i 3 oraz opinie o nowych ludziach.
- **Gwara:** wszystkie nowe kwestie górników mają wersję śląską, razem 78 linii.

### 3. Trzy nowe lokacje ✅
Generuje je `tools/generators/gen_locations.gd`. Jadę do nich od stołu z mapą, wracam przez drogowskaz.

| Lokacja | Kierunek, koszt | Warunek | Co tam jest |
|---|---|---|---|
| **Rząpie starego szybu** | północ, 2 h | brak | zalane dno szybu z pomostem, słup światła z góry, tobołek Tekli, żyła, kreski wydrapane na skale (14 dni), przecięta lina |
| **Upadowa** | zachód w dół, 3 h | wysadzony zawał + lina | stromy chodnik w dół po linie, na dnie zawał okopcony od prochu z klepkami beczki, znak dziadka „NIE KOPAĆ”, najgrubsza żyła, stukanie kilofa zza zawału |
| **Kaplica** | wschód w dół, 3 h | wiedza o kaplicy | stopnie w dół, ściana ze znakami sanctinu, trzy kamienne kręgi, ołtarzyki starych górników z palącą się lampką, nisza z listem dziadka i kryształem |

- **Znaczenie żyły** kosztuje 1 h. Przy zaznaczonej żyle pojawia się twój palik.
- **Mapa przy stole:**
  - pokazuje 5 celów,
  - przy zablokowanych podaje powód (np. „Bez liny nie zejdziesz”),
  - odwiedzone miejsca oznacza jako „byłeś tu”,
  - kaplica figuruje jako „Znak zapytania”, dopóki nie wiesz, czego szukać.
- **Do kaplicy prowadzą trzy drogi:** odszyfrowana wiadomość dziadka, Dobrawa albo Bolko (od dnia 2, gdy ci ufa).

### 4. Ściana z zagadką w trybie VN ✅
- W kaplicy „rozmawiasz” ze ścianą. Ma własny portret: świecące znaki.
- **Napis ma trzy wiersze z lukami.** Luki uzupełnia się, obracając trzy kamienne kręgi.
  - Bez słowniczka Dobrawy napis jest w pseudołacińskim sanctinie. Jest w nim słowo „priori”, którym LoreDoc nazywa Pierwszych.
  - Ze słowniczkiem gracz widzi tłumaczenie: „Zeszliśmy z ___ i daliśmy wam oczy” / „Tych, którzy nie słuchali, oddaliśmy ___” / „Kto zejdzie do nich, niech nie przerywa ich ___”.
  - Odpowiedzi to gwiazda, kamień i sen.
- **Podpowiedzi są rozsiane po grze:**
  - modlitewnik na ołtarzu (postacie z gwiazdami zamiast oczu),
  - Bolko („Pierwsi siedzą w skale”),
  - słowniczek („kamień: także więzienie”),
  - napis dziadka NIE BUDZIĆ,
  - wiadomość dziadka („kawałek Ich snu”).
- **Błędna próba kosztuje 1 h,** a amulet parzy. Po 2 i 3 próbach bohater przypomina sobie kolejne wskazówki.
- **Po rozwiązaniu, kiedy zamkniesz rozmowę:**
  - kręgi obracają się na odpowiedzi,
  - znaki gasną,
  - płyta zjeżdża w posadzkę,
  - w niszy leżą **ostatni list dziadka** i **kryształ**.
- **Powiązanie z historią:**
  - Dziadek pisze, że widział Onych, że błękit to Ich oddech i że sam zasypał upadową prochem kupionym u ojca Tekli.
  - Kryształu ma nie oddawać nikomu, „kto nosi maskę albo koronę”. Maska to Dobrawa, korona to Kniaź przez Racibora.
  - To spina wątki Tekli, Racibora, Mirosława, Bolka i Dobrawy w jedną zagadkę.

### 5. Ulepszenia 🟡
Poprawiłem:
- **Mapa** ma warunki z powodami, nazwy nieznanych miejsc i znaczniki odwiedzin.
- **Tryb VN** obsługuje statyczne portrety dla mówców, którzy nie są postaciami (ściana).
- **System postaci:**
  - kobiece ciało,
  - ukrywanie części stroju,
  - przedmioty na kości głowy (maska),
  - zapętlone pozy pracy,
  - wyłączanie NPC, którego nie ma w obozie.
- **Gwara** jest sprawdzana we wszystkich plikach dialogów, bo górnicy odzywają się też w porannym ogłoszeniu Racibora.
- **Oświetlenie** obozu (kwatera dowódcy, kąt z wózkami) i lokacji jest poprawione na podstawie zrzutów.
- **Z Twoich uwag w trakcie:**
  - usunąłem drewniany podest z poziomu testowego, który zasłaniał Racibora i stół,
  - stragan Tekli nie ma już opisu pod [E], bo przeszkadzał w rozmowie z nią,
  - **[E] zamyka każde okienko z opisem.** Działa to także dla przedmiotów, które znikają po podniesieniu, i nie używa obiektu drugi raz. Opis zaznaczonej żyły nie gaśnie już od razu. Ta poprawka jest w projekcie, ale jeszcze nie w buildzie 0.2.
- **Testy:**
  - test dialogów obejmuje nowe postacie, zagadkę, kryształ i ogłoszenie (49 sprawdzeń, przechodzi),
  - pełne przejście jest podzielone na 7 krótkich scenariuszy z limitem czasu (`tools/tests/`) i skryptem `tools/run_tests.sh`.
- **Build 0.2** i nowa instrukcja `CZYTAJ_MNIE.txt`.

Nie zrobione (zob. „Czego potrzebuję”):
- zakładka postaci w notesie,
- rysunek mapy dla nowych miejsc (lista celów działa),
- prawdziwe dźwięki.

### 6. Demo o dzień dłuższe ✅
- **Dzień 1:** obóz, lonty, wybuch, rząpie.
- **Dzień 2:** Dobrawa, upadowa, kaplica, raport.
- **Dzień 3, rano:** Racibor ogłasza przy śniadaniu, co dalej. Jeśli widziałeś żyłę w upadowej, każe Mirosławowi szykować ładunki, żeby otworzyć zawał. Na list dziadka możesz zaprotestować, a Mirosław, Bolko i Dobrawa reagują według tego, co się wydarzyło. Potem możesz porozmawiać z każdym, a stół z mapą kończy demo.
- **Druga noc ma nowy sen,** zależny od tego, czy masz kryształ albo widziałeś zawał.
- **Rozliczenie nocy obejmuje wszystkie postacie.** Wydana Tekla i Dobrawa w tym miejscu tracą więcej.
- **Podsumowanie końcowe:**
  - złoża,
  - wiadomość i list dziadka,
  - kryształ,
  - stan każdej postaci.

### Dodatkowo
- **Build do wysłania:** `build/Everhorror-demo-0.2-windows.zip` (113 MB). Uruchomiłem go na tym komputerze (nowa gra startuje bez błędów). Build 0.1 zostaje obok. Poprawka zamykania opisu pod [E] przyszła później, więc do buildu trafi przy następnym eksporcie.
- **Baza scenariuszy testowych:** szybki test poprawki [E] pokazał, że scenariusze padłyby na starcie, bo używały typów `Npc` i `Interactable` przed załadowaniem autoloadów. Poprawione. Szybki test przechodzi.
- **Zasada testów** (Twoja prośba) jest w `CLAUDE.md` i w mojej pamięci: pełny zestaw testów uruchamiam tylko za Twoją zgodą.

## Decyzje i założenia
- **Nowe postacie** dobrałem tak, żeby pokryć trzy frakcje z GDD: Ekspedycję (Racibor), Inną (Tekla z Konfraterni kupieckiej z LoreDoc) i Drudzy (Dobrawa). Imiona pasują do Jaksaru.
  - **Racibor** jest szefem wyprawy, który wymaga szukania złóż. To zgadza się z Twoją odpowiedzią w `MECHANICS.md` §13 pkt 2.
  - **Tekla** gotuje i prowadzi zaopatrzenie. Kucharz nie dostał osobnej postaci, bo w małej ekipie to naturalne połączenie.
- **Strefy obozu** wykorzystują podział hali ścianką:
  - posłania, kuchnia, magazyn i proch są w zachodniej sali,
  - dowództwo i zaopatrzenie są we wschodniej sali, przy wyjściu na wyprawy.
- **Zmiany postaci w czasie.** Postacie „przeskakują” na nowe miejsca podczas mrugnięcia ekranu. Nie ma chodzenia po obozie, bo przy tej skali przejście z animacją byłoby dużą pracą na małą wartość.
- **Zwrot fabularny.** Dziadek sam wysadził zejście do upadowej i został po tamtej stronie. To moja propozycja do przeglądu przez Ren. Pasuje do LoreDoc, gdzie górnicy sami zawalili szyb, żeby coś uwięzić (zob. [niespójności LoreDoc, pkt 18](../../../docs_v2/swiat/loredoc_niespojnosci.md)).
- **Zagadka** ma trzy kroki po cztery opcje. Błąd kosztuje czas, nie życie, więc można próbować do skutku, dopóki starcza godzin.
- **Koszty podróży.** Do „głębszych” miejsc (upadowa, kaplica) podróż trwa 3 h, do reszty 2 h. Powrót kosztuje tyle samo co droga tam i jest możliwy nawet po 22:00, zgodnie z Twoją odpowiedzią „zawsze wróci, ale może zmarnować dużo czasu”.
- **Podest z poziomu testowego** usunąłem z naszej kopii `scene/levels/mine.tscn`. Plików paczki nie ruszałem.

## Czego potrzebuję od Ciebie
1. **Zgody na pełny zestaw testów** (`tools/run_tests.sh`, ok. 5–8 min, jedna linia wyniku na scenariusz). Scenariusze są gotowe, ale jeszcze ich nie uruchamiałem. Stary, długi test się zawiesił i nie wiem jeszcze dlaczego, więc w przebiegu gry może siedzieć błąd.
2. **Zagraj** według [factcheck-test-04](../../human-tasks/done/factcheck-test-04.md) i wpisz wyniki.
3. **Ren:** przejrzyj karty i dialogi Racibora, Tekli i Dobrawy oraz zwrot z dziadkiem. Są też do rozstrzygnięcia niespójności z LoreDoc, przede wszystkim punkt 18 (w którym roku dzieje się gra).
4. **Następne kroki zgodne z Twoimi odpowiedziami w `MECHANICS.md` §13.** Mogę je zrobić w kolejnym zadaniu:
   - zakładka „Ludzie” w notesie z opisem zdrowia i poczytalności („ostatnio nerwowo się zachowuje”),
   - upomnienia od Racibora, kiedy gracz ignoruje złoża (a na końcu ekspedycja wyjeżdża bez niego),
   - rany, bandaże i leczenie,
   - ryzyko śmierci gracza przy ranach albo niskiej poczytalności.
5. **Dźwięki:** nadal potrzebny klucz Freesound albo paczka Sonniss.

## Test
Lista do sprawdzenia: [docs/human-tasks/factcheck-test-04.md](../../human-tasks/done/factcheck-test-04.md). Jest tam 33 punkty i proponowana kolejność przejścia na trzy dni.

Automatycznie:
- `tools/dialogue_test.gd` przechodzi (49 sprawdzeń: gwara, wszystkie nowe dialogi, zagadka, kryształ, ogłoszenie, obie ścieżki Tekli).
- Scenariusze w `tools/tests/` czekają na Twoją zgodę.

## Podsumowanie
Demo trwa teraz trzy dni (około 40–60 minut) i spełnia kryteria akceptacji:
1. **Obóz** ma strefy (stół dowódcy, zaopatrzenie, kuchnia ze wspólnym stołem, magazyn, posłania, skład prochu). Pięć postaci zmienia miejsca według pory dnia i wydarzeń.
2. **Trzy nowe postacie** (Racibor, Tekla, Dobrawa) mają własne modele, dialogi i zadania. Ich wątki łączą się z historią dziadka.
3. **Trzy nowe lokacje:** rząpie, upadowa i kaplica.
4. **Demo trwa o dzień dłużej:** noc 2, poranek dnia 3 z ogłoszeniem Racibora i koniec.

Do tego ściana z zagadką w trybie VN spina wątki w jedną tajemnicę: dziadek zasypał upadową, bo coś tam śpi, a Racibor właśnie chce ją otworzyć.

Otwarte zostały:
- pełny zestaw testów (czeka na zgodę),
- rysunek mapy dla nowych miejsc,
- zakładka postaci w notesie,
- prawdziwe dźwięki.

Build 0.2 jest gotowy do wysłania.
