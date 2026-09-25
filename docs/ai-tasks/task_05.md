<!--
Szablon zadania dla agenta AI. Skopiuj jako task_XX.md (XX = kolejny numer) i wypełnij sekcję Requirements.
Reszta pliku należy do agenta: dopisuje swoje sekcje pod wymaganiami i kończy plik podsumowaniem.
Zasady pracy z folderem: zob. INFO.md.
-->

Requirements:
1. Add inventory for the player character, to open it player will press I. 
2. Add items that can be interactable, they can be required for interactions/actions with locations/other object or NPCs, or be requried by quests, or be used to treat wound or heal us mentally. Some items will be interexchangble to be used by player or NPCs, like sick NPC might require medicine, but we might decide to keep it for player character.
3. Add quests or interactions that can get us items or require items to finish. Some location might require items to have in inventory to go to them from map table. 
4. Add to map table button "Onward" to go to expedition, it should also have information on how many nodes of blue ore were discovered and there should be a threshold how much we need to find till the end of the week or something, the leader of the expeditions can remind us about it if it's very low and the deadline is looming. 
5. Add some nodes to be found in the locations that we go. 
6. Maybe expedition summary?
7. If we are on the expedition, we should be able to press M to either continue to go to other location that will take time in travel + exploration, or to go back to the camp. 
8. Add 10 more locations to explore, but you can make them simple, just so they would increase time spent on expedition. 
9. Add 5 more NPCs with some stories, make them colorful and interesting characters based on a LoreDoc they can give player some lore, but they shouldn't be anybody important in the world. 
10. Make the game last at least a week, at day 3 player can meet mages ("Drudzy") expedition when he is exploring. Then one of the mages joins the camp, and the rest can be sometimes meet during exploration, they are very specific characters, looking down at peasnts with no magic, but some of them are good, some bad, some just crazy. 
11. Go again through everything and see if anything is not to robotic/AI made, give it some spriti, character and so on. 


---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Plan (instrukcje dla agenta, przed startem)
**Zanim zacznę:**
1. Przeczytać `CLAUDE.md`, raport `task_04.md` i wyniki w `factcheck-test-04.md` (jeśli są).
2. Domknąć zaległości z task_04:
   - nowy build z poprawką [E], jeśli użytkownik chce,
   - rysunek mapy z nowymi miejscami,
   - pełny zestaw scenariuszy tylko za zgodą.
3. Zadać użytkownikowi naraz trzy pytania:
   - limit ekwipunku (propozycja: brak limitu w demie),
   - czy zdrowie i poczytalność gracza pokazywać opisowo jak u NPC (propozycja: tak),
   - czy w tym zadaniu robić śmierć gracza (propozycja: nie, tylko rany).

**Kolejność prac (każdą fazę sprawdzić jednym krótkim scenariuszem):**
1. **Przedmioty i ekwipunek [I]** (pkt 1–2):
   - `ItemData` (`data/items/*.tres`: id, nazwa, opis, kategoria, efekt `heal`/`sanity`, cel gracz lub NPC, czy się zużywa) zamiast `GameState.ITEM_NAMES`,
   - ekran `scene/ui/inventory.tscn` (modalny jak notes, akcja `inventory` = I), przyciski „Użyj” / „Daj…”,
   - zdrowie, rany i poczytalność gracza w `GameState`,
   - przedmioty: bandaże, lekarstwo, nalewka, olej do lampy, łom, lina, kilof, świeca,
   - `Interactable.required_item` / `consume_item`, opcje dialogów „daj przedmiot NPC” (np. lekarstwo choremu albo zostaw sobie).
2. **Wyprawy** (pkt 4, 6, 7):
   - graf miejsc (krawędzie z godzinami) w danych zamiast listy celów w `MapScreen`,
   - stół z mapą: wybór celu, przycisk **„Wyrusz”** („Onward”), licznik złóż wobec tygodniowej normy,
   - [M] w terenie: dalej do sąsiedniego miejsca (podróż + czas) albo powrót do obozu,
   - podsumowanie wyprawy po powrocie: czas, odwiedzone miejsca, złoża, przedmioty, zdarzenia.
3. **Złoża i norma** (pkt 4–5):
   - uogólnić `VEINS` / `vein_*` na dane (1–3 złoża w każdym miejscu),
   - norma do końca tygodnia (propozycja: 12 złóż do dnia 7),
   - Racibor upomina rano, gdy wynik jest niski, a termin blisko. Koniec „wyprawa wyjeżdża bez ciebie” jako zakończenie przy przegranej normie (MECHANICS §13 pkt 2).
4. **10 prostych miejsc** (pkt 8):
   - szablon w `gen_locations.gd` (komora lub chodnik o zadanym rozmiarze, światła, 2–4 rekwizyty, 1–2 opisy, 0–2 złoża, wyjście),
   - rozłożone na grafie coraz głębiej,
   - teksty krótkie, ale z charakterem.
5. **5 barwnych NPC z LoreDoc** (pkt 9), nieważnych dla świata:
   - kandydaci: Hawiar ze Śnieżnej Przystani, Nerdyjczyk po kopalniach Sułtanatu, wygnaniec z Cesarstwa, najemny Egzarcha, były brat Zakonu Niebiańskiego Płomienia,
   - każdy ma lore do opowiedzenia (święta, zodiak, planety, kraje), własny rozkład dnia i miejsce w obozie (posłania, markery w `gen_camp.gd`),
   - modele z wariantów Quaterniusa (stroje, kolory, kaptury), a górnicy z gwarą.
6. **Tydzień i Drudzy** (pkt 10):
   - `LAST_DAY = 7` (albo 8 z porankiem końcowym), rozliczenia nocy na 7 dni, wydarzenia dnia,
   - w dniu 3 spotkanie wyprawy Drugich w terenie (VN),
   - jeden mag dołącza do obozu. Uzgodnić z Dobrawą: propozycja, że dochodzi w dniu 3 właśnie w ten sposób,
   - pozostali (3–4: dobry, zły, szalony, wszyscy wyniośli wobec „bezmagicznych”) pojawiają się losowo w miejscach wypraw.
7. **Zadania z przedmiotami** (pkt 3): nagrody przedmiotami, zadania „przynieś” i „wylecz”, miejsca na mapie wymagające przedmiotu (`item:` w wymaganiach już działa).
8. **Przegląd tekstów** (pkt 11): wszystkie dialogi, opisy, notatki i UI pod kątem naturalnej, żywej polszczyzny i głosu postaci. Gwara dla nowych górników (`write_gwara.js`, test pokrycia).
9. **Na koniec:**
   - nowe scenariusze testowe: ekwipunek, „Wyrusz” i [M], podsumowanie, norma i upomnienie, dzień 3 z Drugimi,
   - `factcheck-test-05.md`, docs_v2 (ekwipunek, eksploracja, czas, npc, karty postaci), `CLAUDE.md`,
   - `SAVE_VERSION` + zgodność starych zapisów,
   - build 0.3 za zgodą.

**Zasady pracy (z uwag użytkownika):**
- Pełnych testów nie uruchamiam bez zgody. Długich przebiegów nie puszczam przez grep, tylko log do pliku i linia `RESULT`.
- Dłuższe poprawki w JS i patche zapisuję do plików, nie wklejam w bashu (pułapka z apostrofami).
- Sceny generowane zmieniam tylko przez generatory. Rekwizyty, za którymi stoi NPC, nie dostają opisu [E].
- Raport piszę po polsku w tym pliku, na końcu sekcja Podsumowanie.

## Co zostało zrobione

### 1. Ekwipunek pod [I]
- Nowa akcja `inventory` (klawisz I) i ekran `scene/ui/inventory.tscn`, modalny jak notes. Zawiera:
  - na górze: stan bohatera opisany zdaniami („Poobijany: siniaki, zadrapania…”, „Niespokojny…”, „Masz gorączkę”) i postęp normy żył,
  - listę przedmiotów w grupach (leki, narzędzia, zapasy, sprawy, cenne) z opisem,
  - przycisk „UŻYJ” z czasem użycia albo z powodem, dla którego się nie da.
- Pod zegarem w HUD pojawia się krótki stan („ranny · gorączka”), ale tylko wtedy, gdy coś jest nie tak.

### 2. Przedmioty
- Przedmioty są teraz danymi `ItemData` (`data/items/*.tres`, generator `tools/generators/write_world_data.js`), zamiast słownika nazw w kodzie. 17 przedmiotów:
  - leki: bandaże, lekarstwo, nalewka,
  - narzędzia: lina, łom, kilof,
  - zapasy: świeca, olej,
  - sprawy: lonty, kwit, tobołek, obuch, świecący grzyb,
  - cenne: kryształ, odłamek błękitu, Daleki Klejnot, amulet dziadka.
- **Leczenie ran i głowy:** bandaże (+30 zdrowia, pół godziny), lekarstwo (zbija gorączkę), nalewka i świeca (poczytalność).
- **Wymienne między graczem a NPC:** lekarstwo działa na Nasira albo na gorączkę bohatera, nalewka na Mirosława albo na bohatera, bandaże na rannego Welfa albo na bohatera. W dialogu używam `give_to_npc`, która działa na postać tak samo jak `use_item` na bohatera.
- **Przedmioty potrzebne do akcji:**
  - łom otwiera skrzynię z zapasami w jaskini przy starym wejściu (ta „bez łomu nie ma co próbować”) i skrytkę sztygara Grabca,
  - kilof odkuwa żyły spod nacieku.
  `Interactable` dostał `required_item`, `consume_item` i `missing_text`. Bez przedmiotu [E] tylko mówi, czego brakuje, i nie zabiera czasu.

### 3. Zadania i interakcje z przedmiotami
Osiem nowych zadań:

| Zadanie | Przedmioty | Nagroda |
|---|---|---|
| Kilof dla przewodnika (Wszebor) | obuch ze Starego wyrobiska | kilof następnego dnia |
| Pompy Nasira | olej, potem 2 h przy korbie | Zalany chodnik dostępny |
| Gorączka Nasira (Anzelm) | lekarstwo z jednego z pięciu źródeł | Nasir żyje i daje Klejnot. Jeśli bez leku jego zdrowie spadnie do 10, wywożą go na górę |
| Wiersz o świetle (Hagiwara) | świecący grzyb | wiersz i lekarstwo |
| Zakład z Sobkiem | 3 nowe żyły do jutra wieczora | nalewka |
| Brat i czarownica (Anzelm i Sabina) | rozmowy | zgoda w obozie, Sabina pomaga przy chorych |
| Oferta z Exitium (Ottokar) | kryształ albo mapy dziadka | 2 albo 1 żyła na mapie |
| Odłamek dla Sabiny | odłamek z galerii | lekarstwo |

- Tekla ma stragan:
  - jedna świeca dziennie,
  - olej raz, za dług albo zaufanie,
  - jedyne lekarstwo raz, za dług albo w zamian za Klejnot lub nalewkę.
- **Miejsca wymagające przedmiotu przy stole z mapą:** Upadowa i Ślepy szyb (lina), Kryształowa galeria (olej).

### 4. Stół z mapą, przycisk „Onward” (WYRUSZ) i norma
- Nowy ekran mapy:
  - rysunek grafu dróg z trasą czerwonym atramentem, punktami żył i miejscem, gdzie jest bohater,
  - lista znanych miejsc z godzinami drogi i dopiskiem „nowe” albo „żyły 1/2”,
  - opis z godziną przybycia i powodem blokady,
  - przycisk **WYRUSZ**.
- U góry licznik: „Żyły błękitu: 5 z 12 · termin: koniec dnia 7, zostały 2 dni”.
- **Norma:** 12 żył do wieczora dnia 7.
- **Upomnienia:** Racibor upomina rano przy śniadaniu w dniach 4–7, jeśli żył przybywa za wolno, a w dniu 7 zawsze, gdy normy jeszcze nie ma. Każde upomnienie kosztuje trochę jego zaufania.
- **Rano w dniu 8 Racibor liczy żyły:**
  - z normą: koniec „Koniec tygodnia”,
  - bez normy: wyprawa wyjeżdża, a bohater zostaje sam w kopalni (MECHANICS §13 pkt 2).

### 5. Złoża do znalezienia
- 25 żył w 15 miejscach (1–3 w każdym). Każda to świecąca skała: „Zaznacz żyłę na mapie · 1 h”, potem palik, komunikat i kreska na mapie.
- W rząpiu, upadowej i kaplicy druga żyła kryje się pod białym naciekiem. Odkucie wymaga kilofa i trwa 2 h.
- Dwie żyły są w Starej sztolni, jedna w Zawalonym chodniku (otwartym przez wybuch Mirosława).

### 6. Podsumowanie wyprawy
Po powrocie do obozu wyskakuje okno z:
- godziną wyjścia i powrotu oraz czasem poza obozem,
- odwiedzonymi miejscami,
- nowymi żyłami i stanem normy,
- przyniesionymi rzeczami,
- zdarzeniami (spotkanie z Drugimi, uratowany Welf, skrytka Grabca, pompy),
- stanem bohatera,
- jednym zdaniem komentarza („Racibor spojrzy na mapę, potem na ciebie. Nic nie powie. Nie musi.”).

Zamyka się pod [E].

### 7. [M] w terenie
- W każdym miejscu wyprawy [M] (albo drogowskaz przy wejściu, który zamiast „Wróć do obozu” otwiera tę samą mapę) pyta: **Dokąd dalej?**
  - Droga do sąsiedniego miejsca kosztuje godziny marszu, a przy pierwszej wizycie jeszcze 1 h rozpoznania. Ranny bohater idzie wolniej.
  - **WRACAJ DO OBOZU** prowadzi najkrótszą otwartą drogą.
  - **ZOSTAŃ TUTAJ** zamyka mapę.
- Po 22:00 nie da się już iść dalej, ale powrót jest zawsze możliwy.

### 8. Dziesięć nowych miejsc
Wszystkie są zbudowane z jednego szablonu w `gen_locations.gd`: komora, wejście z drogowskazem, światła, rekwizyty, opisy, żyły, znaleziska.

| Miejsce | Co tam jest |
|---|---|
| Stare wyrobisko | filary z czternastoma kreskami, wywrócony wózek, obuch, Wszebor przy pracy |
| Komora pomp | koło pompy, rura, koryto, olej, Nasir |
| Kuźnia starej ekipy | zimne palenisko ze znakiem dziadka w popiele, łom na kowadle, nalewka za szufladą |
| Grzybowa grota | świecące grzyby, zarodniki, dwa grzyby do zabrania |
| Przekop Grabca | prosty chodnik z odrzwiami, skrytka sztygara (łom), a w niej jego zeszyt, który kończy się na „Dniu 14” |
| Zalany chodnik | woda po kolana, w nocy gorączka |
| Ślepy szyb | zejście na linie, wiatr znikąd, świece na półce, z której się spada |
| Kostnica | nisze z czaszkami, świece, świeży chleb dla zmarłych |
| Parująca szczelina | para i siarka, oparzenie przy żyle |
| Kryształowa galeria | najniżej, bez latarni, z kolumnami z błękitu |

Miejsca układają się w graf na czterech poziomach głębokości (zob. `docs_v2/03_poziomy.md`).

### 9. Pięć nowych postaci z LoreDoc
Żadna nie jest ważna dla świata. Każda niesie kawałek lore i ma własny głos, rozkład dnia, miejsce w obozie i zadanie:

| Postać | Kim jest | O czym opowiada |
|---|---|---|
| **Wszebor ze Śnieżnej Przystani** | Hawiar, rębacz, wielki i głośny | brat Bogdal zasypany pod Przystanią, Noc Onych i wypalony pierścień, Długa Noc i Wultany, Dzień Krwawego Nieba |
| **Nasir z Bakaszu** | pompiarz z Sułtanatu Nerdii, były niewolnik z kamieniołomów | rinust, który zabija, Gorejąca Palada, bazary Lajihar, Dżiny, „Daleki Klejnot” z Kinkenheimu |
| **Kiyoshi Hagiwara** | wygnaniec z Cesarstwa, prowadzi księgi Racibora | Nagate i Szarzy, Dzień Morza, życzenia z krwawym kciukiem, Sutāto. Stracił ojczyznę, bo nie chciał fałszować liczb, i tutaj też ich nie sfałszuje |
| **Sobek z Wielkiego Stepu** | Egzarcha, najemnik, straż obozu | zaklęty miecz („ja płacę mrówkami, oni płacą bólem”), banda Gniewomira, Exitium i jego Miecze |
| **Brat Anzelm** | felczer, były zakonnik Niebiańskiego Płomienia | służba pod Przemirem z Łask i dziewięcioletnia dziewczynka spalona na rynku w Bakaszu. Leczy, a magii nie znosi |

Modele zrobiłem z wariantów Quaterniusa: kolory strojów, skóra, kaptury, miecz w dłoni Sobka.

### 10. Tydzień i Drudzy
- **Gra trwa 7 dni.** Rozliczenie nocy obejmuje cały tydzień:
  - nowe dzienne straty poczytalności i sposoby, by ją podnieść,
  - gorączka Nasira od trzeciej nocy,
  - wstrząs w piątą noc,
  - śmierć Mirosława, gdy jego poczytalność spadnie do zera (zasypuje Zawalony chodnik na zawsze),
  - Dobrawa przy zerze schodzi na dno.
  Są też sny na kolejne noce i poranne plansze z nowiną.
- **Dzień 3.** Przy pierwszym przybyciu do dowolnego miejsca stoi tam wyprawa Drugich z **Exitium**, placówki Initium w starej kopalni po drugiej stronie Wąwozu (z LoreDoc). Scena VN:
  - Ottokar chce map dziadka albo kryształu,
  - Welf gardzi „kopaczami”,
  - Sabina tłumaczy się jak przed dzieckiem,
  - Hieronim słyszy, jak góra chrapie.
- **Sabina dołącza do obozu** po powrocie bohatera z tej wyprawy. Dobrawa (Initium) zostaje bez zmian: zna Sabinę i ma o Exitium własne zdanie.
- **Reszta w tunelach**, po jednej osobie, raz dziennie z szansą 40%:

| Mag | Charakter | Gdzie i co robi |
|---|---|---|
| Ottokar | zły | tylko głęboko. Składa ofertę, a po odmowie sięga po drugi krąg: sieje strach na siłę |
| Hieronim | szalony | wszędzie. Mówi zagadki, które są prawdą, daje świecę i bandaż „dla chłopca w czerwonym” |
| Welf | wyniosły, do uratowania | raz, ranny, w pierwszym głębokim miejscu. Z bandażami przeżyje i odda dług lekarstwem |

Wszyscy patrzą z góry na „bezmagicznych”.
- **Zdrowie i poczytalność bohatera:**
  - rany (para, upadek z półki), gorączka,
  - śmierć tylko wtedy, gdy bohater był już ranny (MECHANICS §13 pkt 3), z przyciskiem „RETRY FROM MORNING”,
  - załamanie przy zerze poczytalności,
  - szepty w tunelach, kiedy bohater jest na krawędzi.

### 11. Przegląd tekstów
- Przeczytałem teksty z task_02–04 i nowe. Poprawiłem to, co się zestarzało albo brzmiało jak instrukcja:
  - narzędzia w magazynie („Wszebor co rano mówi, że to miękkie jaksarskie żelazo”),
  - księga zarządcy (prowadzi ją Hagiwara),
  - poranny komunikat: zamiast „Ludzie są tam, gdzie zwykle o tej porze” pokazuje stan normy.
- Rozmowy trzeciego dnia (Mirosław, Bolko, Tekla, Dobrawa, Racibor) kończyły się pożegnaniem dema. Teraz mają powitania na kolejne dni i wracają do zwykłej rozmowy.
- Liczby w tekstach mają polską odmianę („mam 2 żyły”, „został jeden dzień”).
- Nowe kwestie Mirosława i Bolka mają wersję śląską (92 kwestie, test pokrycia przechodzi).
- Opis amuletu dziadka jest zgodny z GDD. Wcześniej był „mosiężnym krążkiem”, teraz jest złoty, z kawałkiem błękitnej stali.
- **Nowa zakładka „Ludzie” w notesie** opisuje słowami zdrowie, głowę i stosunek do bohatera (MECHANICS §13 pkt 4).

### Dokumentacja i narzędzia
- **docs_v2:**
  - przepisane: czas, NPC, ekwipunek, eksploracja,
  - nowy system `zdrowie_i_poczytalnosc.md`,
  - poprawione: zadania, interakcje, zapis, poziomy, jednostronicowy opis, rozgrywka, fabuła, UI, oprawa, README (wersja 2.2),
  - 9 nowych kart postaci w `swiat/postacie/`.
- **`MECHANICS.md`:** notatki „Stan w demie” i tabela z §12 opisują stan po task_05. Odpowiedzi zespołu z §13 są bez zmian.
- **Karty postaci z task_03–04** (Mirosław, Bolko, Racibor, Tekla, Dobrawa) mają dopisane zmiany z task_05 i obecne liczby.
- **CLAUDE.md i `tools/README.md`** zaktualizowane.
- **Nowe narzędzia:**
  - `tools/character_preview.gd` (modele postaci obok siebie),
  - scenariusze `expedition`, `drudzy`, `week`.

## Decyzje i założenia
- **Trzy pytania z planu zostały bez odpowiedzi**, więc przyjąłem:
  - brak limitu ekwipunku,
  - stan bohatera opisowo, jak u NPC.
  Śmierć bohatera zrobiłem jednak według odpowiedzi w MECHANICS §13 pkt 3, nie według mojej propozycji „bez śmierci”. Jest rzadka: tylko po wcześniejszych ranach. Żeby nie tracić całego postępu, jest „RETRY FROM MORNING”, czyli stan z poranka trzymany w pamięci, bez nowego slotu.
- **Przycisk „Onward” nazywa się „WYRUSZ”.** Ekran mapy jest po polsku, jak cały tekst w świecie. Menu główne i pauza zostają po angielsku, zgodnie z wcześniejszym ustaleniem.
- **Tydzień.** `LAST_DAY = 8`: rano w dniu 8 jest rozliczenie, więc gra trwa pełne 7 dni.
  - **Norma** to 12 z 25 żył. Za pierwsze dwie żyły nadal jest odpis z archiwum, ale zadanie zamyka się dopiero przy liczeniu.
  - **Ogłoszenie Racibora** zostało w dniu 3, ale upadową chce otworzyć „jak policzymy żyły”, nie jutro.
- **Dobrawa a mag z dnia 3.** Wymaganie mówi, że po spotkaniu w dniu 3 jeden mag dołącza do obozu. Dobrawa jest w obozie od dnia 2, a jej wątek (kaplica, słowniczek, kryształ) z task_04 zostawiłem bez zmian. Wyprawę z dnia 3 zrobiłem jako osobną grupę z **Exitium** (LoreDoc: satelita Initium w starej kopalni w Wąwozie Pierwszych). Dołącza Sabina. W planie proponowałem, żeby to Dobrawa dochodziła w dniu 3, ale to rozbiłoby cały dzień 2.
- **Postacie z LoreDoc** są wymyślone i poboczne. Znane postacie z LoreDoc (Nakamura, Przemir z Łask, Gniewomir) padają tylko w rozmowach i nie występują w grze.
- **Gorączka po Zalanym chodniku** przychodzi zawsze, bez losowania, żeby było czytelnie. W nocy gorączka nie zabija (zdrowie nie spada poniżej 5).
- **Mirosław przy zerze** robi to, co mówi GDD: wysadza się i zasypuje Zawalony chodnik na zawsze. Upadowa przepada, a do kuźni i Ślepego szybu da się zejść już tylko od dołu, przez galerię.
- **Gwara** jest tylko dla Mirosława i Bolka. Nowi to przyjezdni: Wszebor mówi z lekką góralską nutą („juści”, „ino”, „trza”), a Nasir wtrąca „habibi” i „yalla”.
- **Modele magów:** paczka strojów Quaterniusa ma tylko wieśniaka i zwiadowcę. Magów odróżnia kolor płaszcza, maski (srebrna, brązowa, ciemna) i kostury trzymane w pozie z pochodnią.

## Czego potrzebuję od Ciebie
1. **Factcheck:** przejść [factcheck-test-05](../human-tasks/factcheck-test-05.md) (skrócony tydzień to ok. 2–3 h).
2. **Balans normy:** czy 12 z 25 żył to dobra wartość? Czy upomnienia nie są za rzadkie albo za częste?
3. **Build 0.3 jest gotowy:** `build/Everhorror-demo-0.3-windows.zip` (113 MB, `Everhorror.exe` i `CZYTAJ_MNIE.txt` z nowym sterowaniem i listą zmian). Sprawdziłem go na tym komputerze: nowa gra startuje, świat i wszystkie nowe ekrany wczytują się bez błędów.
4. **Ren:** przegląd 9 nowych kart postaci i wyprawy z Exitium (to robocze postacie, oznaczone [ROBOCZE]).
5. **Limit ekwipunku:** czy w pełnej grze ma być wybór rzeczy przed wyprawą (GDD)? W demie limitu nie ma.

## Test
- Instrukcja: [factcheck-test-05](../human-tasks/factcheck-test-05.md) (33 wiersze).
- **Automatycznie (pełny zestaw uruchomiony za zgodą, w trzech porcjach):**
  - Wszystkie 11 scenariuszy przechodzi: `dialogue`, `day1`, `save_load`, `rzapie`, `night1`, `day2`, `kaplica`, `day3`, `expedition`, `drudzy`, `week`.
  - Zanim zestaw przeszedł w całości, poprawiłem dwa błędy w samych testach: `kaplica` miał zły próg zjazdu płyty, a `day3` złą kolejność czekania na rozmowy.
  - Test dialogów (69 sprawdzeń) obejmuje nowe postacie, zadania z przedmiotami, spotkanie z Drugimi, upomnienie, rozliczenie i zakończenie „Zostałeś sam”.
  - Stary test interakcji wykrył skrzynię bez kształtu. Poprawione.
- **Poprawka po pełnym zestawie:** przy sprawdzaniu raportu znalazłem błąd tras. Mapa wybierała najkrótszą drogę bez patrzenia na blokady, więc:
  - bez liny Kryształowa galeria wychodziła zablokowana przez Ślepy szyb, choć droga przez pompy była otwarta,
  - po śmierci Mirosława powrót mógł prowadzić przez zasypany chodnik.

  Teraz `Expeditions.path()` szuka najpierw drogi przez otwarte miejsca. Scenariusz `expedition` sprawdza to trzema nowymi punktami. Po poprawce scenariusze z mapą (`expedition`, `drudzy`, `week`, `day1`, `rzapie`, `kaplica`) przechodzą, w dwóch porcjach. Po zmianie opisu amuletu test dialogów też przechodzi.
- **Zrzuty ekranu:**
  - wszystkie nowe miejsca, obóz o czterech porach dnia, ekrany mapy, ekwipunku, notesu i podsumowania, nowe postacie,
  - poprawki wyglądu: latarnia na wysokości oczu, skały sterczące w szczelinie, naciek wyglądający jak jasny kwadrat, zbyt ciemna kostnica, nachodzące na siebie podpisy na mapie.

## Podsumowanie
Demo trwa teraz tydzień.
- Gracz planuje wyprawy przy stole z mapą (WYRUSZ), a w chodnikach [M] prowadzi go dalej w głąb 15 miejsc albo z powrotem.
- Szuka 25 żył, żeby do wieczora dnia 7 zrobić normę 12. Racibor upomina przy śniadaniu. Rano w dniu 8 bohater albo zostaje z wyprawą, albo wyprawa odjeżdża bez niego.
- Ma ekwipunek [I] z lekami i narzędziami, które przydają się jemu albo innym. Ma też własne rany, gorączkę, poczytalność i rzadką śmierć z powtórką od rana.
- Obóz ma pięć nowych, barwnych postaci z LoreDoc. W dniu 3 przychodzi wyprawa Drugich z Exitium: Sabina zostaje w obozie, a Ottokar, Hieronim i Welf krążą po tunelach.
- Wszystkie scenariusze testowe przechodzą.

Czekam na wyniki factchecku. Build 0.3 jest gotowy do wysłania testerom.
