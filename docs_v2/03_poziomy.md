# 03 Poziomy

> Status: 🟡 szkic (demo zaimplementowane, 15 miejsc) · Właściciel: — · Aktualizacja: 2026-09-25 (task_05)

## Struktura gry **[GDD]**
| Warstwa | Charakter | Zawartość |
|---|---|---|
| **Wejście / prolog** | zagajnik, wóz, wejście z pulsującym światłem | FPP, wstęp |
| **Obóz** | hub. Zmienia się z dnia na dzień | NPC, stół z mapą, ekwipunek, posłanie |
| **Kopalnia** | ludzka robota: szyny, podpory, wózki | pomieszczenia, złoża, notatki |
| **Jaskinie** | naturalne, obce | ❓ |
| **Świątynia Onych** | finał | Pierwszy |

❓ Czy obóz jest jeden, czy ekspedycja przenosi go niżej? GDD wspomina „pierwszy obóz”.

## Zasady projektowania segmentów
1. **Segment = osobna przestrzeń** z punktem wejścia i drogowskazem, który otwiera mapę [M] (dalej albo do obozu). W demie wszystkie leżą w jednej scenie świata (`scene/levels/locations.tscn`), daleko od siebie. Podróż to przejście przez czerń z planszą. Każdy segment ma punkty `<Miejsce>Spot1..4` dla spotkanych ludzi, a miejsca pracy górników `<Miejsce>Work`.
2. **Mały i gęsty:** 2–5 minut eksploracji, 3–6 obiektów interakcji, jeden „powód, by przyjść” (złoże, notatka, zagadka, odnoga).
3. **Czytelne drogi:** światło (lampy, żyły błękitnego żelaza) prowadzi gracza zamiast znaczników w interfejsie.
4. **Zablokowane przejścia są widoczne** (zawalisko, szyb bez liny), a mapa podaje powód blokady.
5. **Budujemy z modułowych zestawów** (Mine & Caves, prop_pack, Kenney) i własnych brył z materiałem skały. Nie edytujemy plików zestawów.
6. **Generujemy sceny skryptami** (`tools/generators/`), więc układ da się zmienić i odtworzyć. Poprawki robimy w generatorze, nie w scenie.

## Obóz (jaskinia, `scene/levels/camp.tscn`)
Naturalna jaskinia ok. 32 × 16 m ze sklepieniem ok. 6 m (x 0–32, z −9–7), w miejscu dawnej hali obitej deskami (task_08, [decyzja 2026-09-26]). Skała na ścianach i sklepieniu, drewno tylko jako konstrukcje: zagroda Racibora, rusztowanie nad magazynem, odrzwia przy wyjściach, słupy z latarniami. Wyjścia są tam, gdzie były: na zachodniej ścianie zachodni chodnik i korytarz do starego wejścia, na wschodniej korytarz, którym do obozu wjeżdża jedyny stary tor. Strefy w dawnej kolejności z zachodu na wschód, luźniej, a ognisko stoi w środku.

| Strefa | Część jaskini | Co tam jest | Kto i kiedy |
|---|---|---|---|
| Izba chorych | północny zachód | posłanie dla chorych, skrzynka Anzelma z ziołami i bandażami, świeca, skrzynka do siedzenia | Anzelm cały dzień, chory Nasir, Sabina przy chorych |
| Posłania | południowy zachód | posłania gracza i Bolka, namiot, worki, beczka z wodą; posłanie Mirosława osobno pod północną ścianą, filar skalny między nimi a izbą chorych | Bolko wieczorem, Nasir, Sabina i Dobrawa wieczorem przy zachodnich wyjściach, gracz śpi |
| Ognisko i kuchnia | środek | ognisko z rożnem i kociołkiem („Usiądź przy ogniu” po 20:00, scena wg dnia), kłody do siedzenia z każdej strony, kącik kucharki | Tekla rano i wieczorem, Mirosław i Wszebor wieczorem |
| Wspólny stół | środek, na północ od ogniska | długi stół z ławami, talerze, świeca | śniadanie (do 8:00) i kolacja (18–20) |
| Magazyn | południowa ściana, pod drewnianym rusztowaniem | skrzynie, beczki, stół z narzędziami, osełka; koniec starego toru z dwoma wózkami, w jednym stary urobek (świeci) | Bolko w dzień, Sabina, Dobrawa 9–12 przy wózkach |
| Skład prochu | północna ściana, jak najdalej od ognia | beczki z prochem, skrzynia z lontami | Mirosław w dzień |
| Zagroda dowódcy | północny wschód: drewniana palisada ok. 2 m bez dachu, z bramą od strony obozu | **stół z mapą** (wyprawy), świecznik, księga zarządcy, chorągiew Kniazia na poprzeczce, łóżko, skrzynia z żołdem | Racibor, Hagiwara w dzień przy księdze, Dobrawa rano w dniu 2, Tekla pod strażą |
| Zaopatrzenie | południowy wschód, przy torze | stragan z linami i olejem, beczki, latarnia na słupie | Tekla w dzień i wieczorem |
| Kącik pisarza | wschód, między zagrodą a ścianą | stołek, skrzynia z kubkiem, pędzelkiem i zeszytem wierszy | Hagiwara wieczorem |
| Wyjście na wschód | wschodnia ściana, tor wjeżdża w korytarz | — | Sobek z mieczem cały dzień, oprócz kolacji |

W jaskini przy starym wejściu stoi zabita skrzynia z zapasami ze znakiem Kniazia. Łom otwiera ją raz: bandaże, świece, nalewka.

Rozkład dnia opisuje [NPC](systemy/npc.md#rozkład-dnia).

## Miejsca wypraw (demo)

**Graf dróg** (godziny w jedną stronę; pierwsza wizyta +1 h rozpoznania):
```
obóz ─2─ Stara sztolnia ─1─ Stare wyrobisko ─1,5─ Grzybowa grota ─1─ Parująca szczelina
  │            └─1─ Kaplica ─1─ Kostnica          └─1─ Przekop Grabca ─1,5─┘
  ├─2─ Zawalony chodnik ─1─ Upadowa                       │
  │            └─1─ Kuźnia ─1─ Ślepy szyb ─1,5─┐          1,5
  └─2─ Rząpie ─1─ Komora pomp ─1─ Zalany chodnik ─1,5─ Kryształowa galeria
                       └───────────1,5──────────── Przekop Grabca
```
Dane: `data/locations/*.tres` (generator `tools/generators/write_world_data.js`).


### Stara sztolnia (wschód)
- Warstwa: kopalnia → jaskinia
- Koszt podróży z obozu: 2 h (powrót tyle samo)
- Wymaga: nic
- Zawartość: korytarz z szynami, pochylnia, jaskinia z żyłami, skrzynka lontów, kartka z szyfrem dziadka, porzucony kilof ze znakiem dziadka
- Odnogi: → Kaplica (wąskie przejście w dół, „znak zapytania” na mapie dziadka)

### Zawalony chodnik (zachód)
- Koszt: 2 h
- Wymaga: zawał wysadzony przez Mirosława
- Zawartość: gruz po wybuchu, deska z kluczem do szyfru, połamane stemple nad upadową
- Odnogi: → Upadowa (z liną)

### Rząpie starego szybu (północ)
- Koszt: 2 h
- Wymaga: nic
- Zawartość:
  - zalane dno szybu, pomost do podestu pod szybem,
  - blade światło z góry, urwana drabina, lina przecięta nożem,
  - tobołek Tekli z listem Konfraterni,
  - żyła do zaznaczenia,
  - czternaście kresek wydrapanych na skale
- Stan zmienia się: tobołek znika po zabraniu, przy zaznaczonej żyle staje palik

### Upadowa (zachód, w dół)
- Koszt: 3 h
- Wymaga: zawał wysadzony + lina
- Zawartość:
  - chodnik opadający pod kątem 20°, zejście po linie przywiązanej do stempla, dwie przygaszone latarnie,
  - na dnie zawał z sadzą, klepkami beczki i nadpalonymi belkami,
  - znak dziadka „NIE KOPAĆ”,
  - najgrubsza żyła,
  - stukanie kilofa zza zawału
- Stan zmienia się: po zaznaczeniu żyły staje palik. W dniu 3 Racibor chce tę upadową otworzyć

### Kaplica (wschód, w dół)
- Koszt: 3 h
- Wymaga: wiedza o kaplicy (odszyfrowana wiadomość dziadka, Dobrawa albo Bolko)
- Zawartość:
  - stopnie w dół, jaskinia z błękitnymi żyłami,
  - **ściana Onych**: gładki kamień ze świecącymi znakami sanctinu, trzy kamienne kręgi, zagadka w trybie VN,
  - dwa ołtarzyki starych górników (modlitewnik, kielich, paląca się lampka), ławka,
  - nisza z listem dziadka i kryształem
- Event VN: rozmowa ze ścianą ([Dialogi](systemy/dialogi_vn.md#zagadka-ściany))
- Stan zmienia się: po rozwiązaniu kręgi stoją w nowym położeniu, znaki są przygaszone, nisza otwarta

### Stare wyrobisko (wschód, poziom 2)
- Droga: Stara sztolnia 1 h
- Zawartość: niska komora na trzech filarach (na jednym czternaście kresek — ślad „Czternastu kresek”), wywrócony wózek, szyny, obuch hawiarskiego kilofa w gruzie, 2 żyły
- Zmiany: po wstrząsie (dzień 6+) środkowy filar jest pęknięty i „oddycha” pyłem
- Ludzie: za dnia kopie tu Wszebor
- Odnogi: → Grzybowa grota, → Przekop Grabca

### Komora pomp (północ, poziom 2)
- Droga: rząpie 1 h
- Zawartość: drewniane koło pompy między stemplami, rura w górę do rząpia, koryto z wodą, bańka oleju, 1 żyła nad korytem
- Ludzie: Nasir za dnia (od dnia po oleju)
- Stan zmienia się: po uruchomieniu pomp (Nasir, 2 h) opis pompy i dostęp do zalanego chodnika
- Odnogi: → Zalany chodnik (po pompach), → Przekop Grabca

### Kuźnia starej ekipy (zachód, poziom 2)
- Droga: zachodni chodnik 1 h
- Zawartość: zimne palenisko ze znakiem dziadka w popiele, kowadło z łomem, beczka, stojak na broń, łańcuch, butelka nalewki za szufladą, 1 żyła
- Odnogi: → Ślepy szyb (z liną)

### Grzybowa grota (wschód, poziom 3)
- Droga: stare wyrobisko 1,5 h · groza przy pierwszej wizycie
- Zawartość: jaskinia z filarami, kępy świecących na turkusowo grzybów (zarodniki: −poczytalność), 2 duże grzyby do zabrania, 2 żyły
- Odnogi: → Parująca szczelina

### Przekop Grabca (poziom 3)
- Droga: stare wyrobisko 1 h albo komora pomp 1,5 h
- Zawartość: prosty chodnik 24 m z odrzwiami i szynami, tabliczka sztygara, wózek, na końcu zabita deskami skrytka (łom: olej i zeszyt Grabca), 1 żyła
- Zmiany: po wstrząsie szczelina przy spągu odsłania zgnieciony medalik starej ekipy (ślad „Czternastu kresek”)
- Odnogi: → Parująca szczelina

### Zalany chodnik (północ, poziom 3)
- Droga: komora pomp 1 h · wymaga uruchomionych pomp
- Zawartość: chodnik z wodą po kolana (w nocy gorączka), pływające deski, zatopiony wózek, 2 żyły
- Odnogi: → Kryształowa galeria

### Ślepy szyb (zachód, poziom 3)
- Droga: kuźnia 1 h · wymaga liny · groza
- Zawartość: dno szybu bez wyjścia na powierzchnię, twoja lina z góry, wiatr znikąd, półka ze świecami (upadek: rana), 1 żyła pnąca się w ciemność
- Odnogi: → Kryształowa galeria

### Kostnica (wschód, poziom 3)
- Droga: kaplica 1 h · najstraszniejsze miejsce (groza 8)
- Zawartość: nisze z czaszkami (imiona starej ekipy, jedno nieczytelne), świece na posadzce, ołtarz ze świeżym chlebem, nowe świece do zabrania (kosztem poczytalności), 1 żyła

### Parująca szczelina (poziom 4)
- Droga: grota 1 h albo przekop 1,5 h
- Zawartość: wysoka, wąska szczelina, dwa wyloty pary z siarką i czerwonym żarem, 2 żyły (druga przy wylocie: oparzenie)
- Zmiany: po wstrząsie nowa, „oddychająca” szczelina o ostrych brzegach

### Kryształowa galeria (poziom 4, najniżej)
- Droga: zalany chodnik albo ślepy szyb 1,5 h · wymaga oleju do lampy · groza 6 · bez latarni
- Zawartość: ściany z błękitu, kryształowe kolumny pochylone w dół, odłamek czystego błękitu, 3 żyły, stukanie zza ściany
- Ludzie: najczęściej Ottokar albo Hieronim

## Szablon opisu segmentu
```
### [Nazwa pomieszczenia]
- Warstwa: kopalnia / jaskinie / świątynia
- Koszt podróży z obozu: X h
- Wymaga: (przedmiot / rola NPC / flaga)
- Zawartość: złoża, notatki, zagadka, obiekty interakcji
- Odnogi: → [pomieszczenia]
- Event VN przy wejściu: tak/nie
- Stan zmienia się, gdy: …
```

## Otwarte pytania
- ❓ Co jest za zawałem w upadowej (pełna gra: szkielet dziadka, głębsze chodniki, Świątynia Onych)?
- ❓ Czy miejsca wypraw mają się zmieniać między dniami (np. woda w rząpiu rośnie, wstrząs zasypuje przejście)?
- ❓ Czy 10 prostych miejsc z task_05 ma zostać w pełnej grze, czy to wypełniacz tygodnia?
- ✅ Obóz: jedna scena w jaskini (task_08: dawniej hala z desek), strefy jak wyżej.
