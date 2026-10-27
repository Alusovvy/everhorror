# Mechaniki

> **Materiał odniesienia od 2026-10-26.** Bieżące zasady są w specyfikacji (`C:/dev/gamedev/everhorror/specification`), a proces i pierwszeństwo źródeł w jej `WORKFLOW.md`. Nie synchronizować tego dokumentu z nowymi zmianami kodu. Oryginalna treść pozostaje jako źródło historyczne do zweryfikowanej migracji D-02; starsze instrukcje poniżej nie są aktualnym procesem. Plik leży w `docs/archiwum/` (D-02); agenci go pomijają.

Dokument rozwija sekcję 4 [GDD](../GDD.md) do poziomu, na którym da się je zaimplementować. Opisuje, jak ma działać gra; historia i postacie zostają w GDD.

**Oznaczenia:**
- **[GDD]** — ustalone w GDD.
- **[propozycja]** — sugestia do akceptacji albo zmiany przez zespół.
- **❓** — otwarte pytanie, na które potrzebna jest decyzja.

---

## 1. Pętla rozgrywki

Gra dzieli się na dni. Jeden dzień wygląda tak **[GDD, sekcja 1]**:

1. **Obóz.** Rozmowy z NPC (questy, relacje), obserwacja zmian w obozie.
2. **Stół z mapą.** Wybór kierunku eksploracji.
3. **Ekwipunek.** Wybór przedmiotów na wyprawę (paliwo do lampy, liny itd.).
4. **Wyprawa.** Przejście do segmentów tuneli, eksploracja w FPP, zagadki, wydobycie, notatki.
5. **Powrót do obozu.**
6. **Sen.** Przejście do kolejnego dnia.

Cele trzeba osiągać **w wyznaczonym czasie** **[GDD]**, więc każda decyzja o tym, jak spędzić czas, ma swoją cenę (zob. rozdział 4).

✅ **Gracz zawsze wraca na noc do obozu**, ale może przy tym zmarnować dużo czasu (odpowiedź w §13 pkt 8). W demie powrót z wyprawy jest możliwy nawet po 22:00.

## 2. Tryby gry

| Tryb | Kiedy | Sterowanie |
|---|---|---|
| **Eksploracja FPP** | obóz, segmenty tuneli | ruch, rozglądanie się, interakcja |
| **Visual Novel (VN)** | dialogi z NPC, kluczowe eventy fabularne, czasem przejścia między segmentami tuneli **[GDD]** | wybór opcji |
| **Mapa / notes** [propozycja] | stół z mapą, podgląd questów | interfejs (UI) |

Przejście FPP → VN: gracz wchodzi w interakcję z NPC albo przedmiotem, albo uruchamia się event. Po zakończeniu sekwencji VN gracz wraca do FPP w tym samym miejscu.

**[propozycja]** Na czas trybu VN świat 3D zatrzymuje się: gracz nie może się ruszać, a kursor myszy zostaje uwolniony.

## 3. Eksploracja obozu **[GDD]**

- Poruszanie się w FPP.
- Interakcja z NPC otwiera dialog w trybie VN.
- Interakcja z przedmiotami daje jeden z dwóch efektów:
  - **opis / informację** (krótki tekst na ekranie, bez VN),
  - **przejście do VN** (dłuższa scena).
- Obóz zmienia się z czasem: NPC przychodzą i odchodzą, pojawiają się ranni, przedmioty, ślady wydarzeń. Gracz powinien móc te zmiany zauważyć.

**[propozycja]** Wszystko, z czym można wejść w interakcję, ma wspólny komponent `Interactable` z podpowiedzią („[E] Porozmawiaj”, „[E] Zbadaj”) i informacją, czy akcja zajmuje czas.

## 4. Upływ czasu **[GDD]**

| Akcja | Zajmuje czas? |
|---|---|
| Chodzenie po obozie | nie |
| Rozmowa z NPC | **tak** |
| Podróż do pomieszczenia do eksploracji | **tak** |
| Eksploracja pomieszczeń w 3D | nie |
| Badanie niektórych rzeczy w pomieszczeniach | **czasami** |
| Eventy | **tak** |
| Prośba o pomoc NPC w pomieszczeniu (rozdz. 7.5) | **tak, dużo** (trzeba po niego pójść i wrócić) |
| Sen | **tak** (kolejny dzień) |

Czas płynie więc tylko wtedy, gdy gracz podejmuje decyzję, a nie w czasie rzeczywistym. Nie ma presji zegara w trakcie chodzenia.

**[propozycja] Jednostka czasu:** dzień dzieli się na określoną liczbę **godzin**, np. 16 godzin aktywności. Każda akcja ma koszt w godzinach, a gdy godziny się skończą, gracz musi iść spać (albo ponosi karę). Czas widać na zegarku lub świecy w obozie oraz w interfejsie VN.

**Stan w demie (task_05):**
- dzień trwa 16 h (06:00–22:00),
- rozmowa kosztuje 0,5 h, naliczane przy pierwszej odpowiedzi innej niż pożegnanie (otwarcie i „Muszę iść” za darmo; task_06),
- podróż idzie po grafie miejsc: 2 h z obozu do sąsiednich miejsc, 1–1,5 h dalej, +1 h rozpoznania przy pierwszej wizycie, +1 h na każdy odcinek, gdy bohater jest ranny,
- wysadzenie zawału kosztuje 4 h, zaznaczenie żyły 1 h (spod nacieku 2 h), błędna próba przy ścianie w kaplicy 1 h, praca przy pompach 2 h, bandaże i świeca 0,5 h,
- demo trwa tydzień (7 dni), rozliczenie jest rano w dniu 8.

Szczegóły w specyfikacji: `03_mechaniki/czas.md` (CZAS-1…CZAS-16).
✅ Terminy (odpowiedź w §13 pkt 2): w demie jest jeden termin, norma Kniazia (12 żył do wieczora dnia 7). Kiedy się spóźnia, Racibor upomina, a bez normy wyprawa wyjeżdża bez gracza.
❓ Czy w pełnej grze są też osobne terminy questów?

## 5. Eksploracja kopalni

### 5.1 Struktura **[GDD]**
Kopalnia → jaskinie → Świątynia Onych. Im niżej, tym groźniej. Każdy poziom składa się z **segmentów tuneli / pomieszczeń**, do których gracz przechodzi ze stołu z mapą.

### 5.2 Mapa **[GDD]**
- Mapa pokazuje **odkryte pomieszczenia**.
- **Lista zmapowanych złóż** błękitnego żelaza.
- **Niezbadane odnogi**, czyli miejsca, dokąd można pójść dalej.

**[propozycja]** Mapa to graf pomieszczeń. Każde pomieszczenie ma stan (nieznane / widoczna odnoga / odkryte / zablokowane) i koszt podróży w godzinach. Kolejne pomieszczenia odblokowuje eksploracja, notatki dziadka (jego mapy gracz zna „na pamięć”) albo pomoc NPC (np. wysadzenie zawaliska).

**Stan w demie (task_05):**
- stół z mapą: graf 15 miejsc z trasą, licznik żył wobec normy, przycisk WYRUSZ,
- w tunelach mapa [M]: dalej do sąsiedniego miejsca albo powrót do obozu,
- po powrocie podsumowanie wyprawy.

Zob. specyfikacja: `03_mechaniki/wyprawy.md` (WYP-1…WYP-15) i `04_tresc/miejsca.md`.

### 5.3 Wydobycie
Gracz wydobywa błękitne żelazo i znajduje notatki dowódcy poprzedniej ekipy **[GDD]**.

✅ Szef wyprawy wymaga szukania złóż. Kto to długo ignoruje, dostaje upomnienia, a na końcu wyprawa wyjeżdża bez niego (§13 pkt 2). **Stan w demie (task_05):**
- 25 żył w 15 miejscach, norma 12 do wieczora dnia 7,
- upomnienia Racibora rano w dniach 4–7,
- rozliczenie rano w dniu 8: z normą „Koniec tygodnia”, bez normy „Zostałeś sam”.

### 5.4 Zagadki
Proste zagadki logiczne w pomieszczeniach **[GDD]**. Dziadek był kryptografem, więc naturalne są zagadki oparte na szyfrach i mapach **[propozycja]**.

### 5.5 Zagrożenie
✅ Gracz może zginąć, ale raczej przy ranach albo niskiej poczytalności, kiedy jakaś interakcja źle na niego wpłynie (§13 pkt 3). **Stan w demie (task_05):**
- rany (para w szczelinie, upadek z półki w szybie) i gorączka po zalanym chodniku,
- śmierć tylko wtedy, gdy bohater był już ranny, z przyciskiem „RETRY FROM MORNING”,
- załamanie przy zerze poczytalności.

Zob. specyfikacja: `03_mechaniki/zdrowie_i_poczytalnosc.md` (ZDR-1…ZDR-12).

## 6. Ekwipunek

Przed wyprawą gracz wybiera, co bierze ze sobą **[GDD]**, np. paliwo do lampy i liny. Przedmioty mogą też pochodzić od NPC (rozdz. 7).

**[propozycja]**
- Ograniczona liczba miejsc na wyprawę, co wymusza wybór.
- Paliwo do lampy działa jak zasób wyprawy: bez światła nie da się wejść do niektórych pomieszczeń albo rośnie ryzyko.
- Przedmioty są kluczami do pomieszczeń i zagadek (lina → zejście w szyb).

❓ Czy przedmioty się zużywają? Czy jest amulet z błękitną stalą i czy ma działanie mechaniczne (sny, wizje, podpowiedzi)?

**Stan w demie (task_05):**
- ekwipunek [I] bez limitu, 17 przedmiotów,
- leki działają na bohatera i na NPC,
- przedmioty-klucze do miejsc (lina, olej) i obiektów (łom, kilof),
- zużywają się leki, świece i nalewka, narzędzia nie,
- amulet nie ma działania mechanicznego.

Zob. specyfikacja: `03_mechaniki/ekwipunek.md` (EKW-1…EKW-9).

## 7. Postacie niezależne (NPC)

### 7.1 Schemat NPC **[GDD, sekcja 5]**
| Pole | Opis |
|---|---|
| Nazwa | |
| Frakcja | Drudzy / Ekspedycja / Inna |
| Rola | np. górnik, specjalista od materiałów wybuchowych. Niektóre akcje wymagają NPC o danej roli w obozie. |
| Poczytalność | aktualna / maksymalna. Maksimum zależy od postaci (Mirosław: 50). |
| Zdrowie | aktualne / maksymalne |
| Informacje | co może przekazać graczowi: za quest albo od danego poziomu reputacji |
| Przedmioty | co posiada i może dać |
| Zadania | questy; nagroda to informacja, przedmiot albo reputacja u tego NPC |
| Historia | tło fabularne |
| Efekt przy 0% poczytalności | unikalna konsekwencja |

**[propozycja]** Dodać pole **Reputacja** (osobno u każdego NPC), bo zależą od niej informacje i dialogi.

### 7.2 Poczytalność **[GDD]**
- Pasek poczytalności każdego NPC. Po wyczerpaniu uruchamia się **unikalny dla danego NPC efekt**, np.:
  - górnik (szablon z GDD): ucieka z kopalni,
  - Mirosław z Głuszy: wysadza się z beczką prochu w tunelu. Z nim znika możliwość wysadzenia 2–3 dodatkowych tuneli.

✅ Poczytalność zmieniają wydarzenia, przedmioty i postęp w głąb, u każdego trochę inaczej. Gracz nie widzi paska: w notatkach o NPC ma osobne opisy zdrowia i poczytalności („wygląda na zdrowego”, „ostatnio nerwowo się zachowuje”) (§13 pkt 4). **Stan w demie:** objawy w dialogach i miejscu postaci. Zakładka „Ludzie” w notesie opisuje słowami zdrowie, głowę i stosunek do bohatera (task_05).

### 7.3 Zdrowie, rany, śmierć **[GDD]**
- NPC mogą odnosić rany, a gracz może próbować je leczyć.
- NPC mogą umrzeć.

✅ Bandaże i NPC, który może pomóc. Ryzyko do ustalenia później (§13 pkt 5).

**Stan w demie (task_05):**
- bandaże i lekarstwo,
- Anzelm opatruje ziołami raz dziennie,
- Sabina leczy magią, a płaci za to poczytalnością,
- gorączka Nasira od trzeciej nocy,
- ranny Welf w tunelach,
- Mirosław może zginąć (§7.2).

### 7.4 Obecność w obozie **[GDD]**
NPC mogą pojawiać się w obozie i znikać z niego (wyprawy, ucieczka, śmierć, przybycie nowych).

**[propozycja]** Każdy NPC ma stan: *w obozie / w tunelach / zaginiony / uciekł / martwy*.

**Stan w demie:** każdy NPC ma **rozkład dnia**: rano śniadanie, 8–18 praca w swojej strefie obozu, 18–20 kolacja, potem wieczór. Stan fabuły ma pierwszeństwo, np. Mirosław na krawędzi siedzi w kącie, a wydana Tekla pod strażą. Dobrawa przyjeżdża w dniu 2 i znika w tunelach w południe.

Od task_05:
- 14 postaci,
- górnicy pracują za dnia w miejscach wypraw,
- Drudzy z Exitium spotykani w tunelach,
- Sabina dołącza do obozu w dniu 3.

Zob. specyfikacja: `03_mechaniki/npc.md` (NPC-16, NPC-17).

### 7.5 Pomoc NPC w pomieszczeniach **[GDD]**
Niektóre pomieszczenia wymagają specjalisty. Gracz nie idzie z nim fizycznie. W panelu VN wybiera opcję typu *[Poproś XYZ o pomoc, bo się na tym zna]*. To kosztuje dużo czasu, bo trzeba po niego pójść i wrócić.

Opcja jest dostępna tylko wtedy, gdy NPC o danej roli żyje, jest w obozie i (**[propozycja]**) ma wystarczającą reputację lub poczytalność.

### 7.6 Reputacja
Przychylność części towarzyszy trzeba sobie zasłużyć, bo gracz jest równorzędnym członkiem ekspedycji, a nie dowódcą **[GDD]**. Reputacja odblokowuje informacje, opcje dialogowe i pomoc.

✅ Tylko u poszczególnych NPC, nie u frakcji (§13 pkt 6). Zaimplementowane: −100..100, start 0.

## 8. Dialogi (tryb VN) **[GDD]**

- Postać NPC na tle, tekst i opcje dialogowe.
- Opcje mogą zależeć od reputacji i wcześniejszych wyborów.
- Tryb VN służy też do narracji bez NPC (wejście do kopalni, przejścia między segmentami, monolog bohatera).

**[propozycja]** Opcja dialogowa może mieć:
- **warunki** (reputacja ≥ X, posiadany przedmiot, flaga fabularna, NPC w obozie),
- **efekty** (zmiana reputacji / poczytalności, dodanie przedmiotu, questa lub informacji, ustawienie flagi, koszt czasu, przejście do innej sceny).

Niespełnione opcje mogą być ukryte albo widoczne, ale zablokowane.

## 9. Questy **[GDD]**

- Prosty **notes** z zapiskami questów.

**[propozycja]** Wpis w notesie to tytuł, zleceniodawca, stan (aktywny / ukończony / nieudany), krótkie notatki dopisywane w miarę postępu i ewentualny termin. W notesie mogą się też znaleźć odnalezione notatki dziadka i dowódcy.

## 10. Zakończenia **[GDD, sekcja 1]**

Jest kilka zakończeń zależnych od decyzji gracza:
- **proste**, czyli jednorazowa akcja (np. ucieczka z kopalni po znalezieniu szkieletu i notatek dziadka),
- **złożone**, czyli ukończenie linii questów (np. Drudzy docierają na dno kopalni i pokonują Pierwszego).

**[propozycja]** Zakończenia uruchamiają się na podstawie flag fabularnych i stanu NPC, bez osobnego systemu. Dlatego od początku wszystkie decyzje zapisujemy jako flagi w jednym stanie gry.

## 11. Prolog (sekwencja otwierająca) **[GDD, sekcja 2.1]**

Prolog uczy mechanik po kolei:
1. FPP: ścieżka przez zagajnik o zmierzchu, wstęp w polach tekstowych na ekranie. Gracz tylko idzie.
2. Przejście przez czerń, a potem wejście do kopalni w nocy.
3. Pierwszy tryb VN: zejście, prosta decyzja.
4. Obóz: pierwsze rozmowy z kluczowymi NPC.
5. Sen: początek właściwej gry.

---

## 12. Implementacja w Godot [propozycja]

Systemy i ich kolejność. Każdy krok da się zagrać i sprawdzić osobno.

| # | System | Forma w Godot | Stan |
|---|---|---|---|
| 1 | Kontroler FPP | `player.gd` | ✅ WASD, skok, kroki |
| 2 | Interakcja (raycast + `Interactable`) | `Area3D` + podpowiedź w HUD | ✅ opis, rozmowa, użycie, koszt czasu, przedmioty, flagi |
| 3 | Tryb VN (dialog, opcje) | Dialogue Manager + `vn_balloon.tscn`, portrety 3D | ✅ |
| 4 | Stan gry (flagi, czas, dzień) | autoload `GameState` | ✅ |
| 5 | Upływ czasu i sen | `GameState` + `StoryDirector` (rozliczenie nocy, sny) | ✅ |
| 6 | NPC (dane, reputacja, poczytalność, zdrowie, stan) | `NpcData`, `Npc`, `CharacterModel`, rozkład dnia `CampSchedule` i `FieldSchedule` | ✅ 14 postaci (10 w obozie, 4 Drugich z Exitium), rany i gorączka, efekty przy 0% u Mirosława i Dobrawy. ⬜ efekty przy 0% u pozostałych |
| 7 | Warunki i efekty opcji dialogowych | w plikach `.dialogue`, wykonywane przez `GameState` | ✅ |
| 8 | Notes questów | `QuestData`, `NoteData`, notes [J] | ✅ z zakładką „Ludzie” |
| 9 | Mapa kopalni i podróż | `LocationData`, `Expeditions`, `MapScreen`, miejsca w `locations.tscn` / `mine_deep.tscn` | ✅ graf 15 miejsc, stół z mapą (WYRUSZ), [M] w terenie, rysunek mapy, podsumowanie wyprawy |
| 10 | Ekwipunek na wyprawę | `ItemData` + ekran [I] | ✅ ekran [I], 17 przedmiotów. ⬜ wybór rzeczy przed wyprawą (limit) |
| 11 | Zapis / odczyt | `SaveManager` + grupa `persist` + `GameState` | ✅ cały stan gry |
| 12 | Menu główne, pauza, opcje | `main_menu.tscn`, `pause_menu.tscn` | ✅ + gwara śląska |
| 13 | Zdrowie i poczytalność bohatera | `GameState`, HUD, ekwipunek, ekran końca | ✅ rany, gorączka, śmierć z „od rana”, załamanie |

**Minimalny grywalny wycinek:** kroki 1–5 oraz jeden NPC z kroku 6. ✅ Zrobiony w task_03 i rozbudowany w task_04 do demo na 3 dni (obóz ze strefami, 5 NPC, 5 miejsc wypraw, zagadka ściany). Opis: [task_04](../ai-tasks/done/task_04.md). W task_05 demo urosło do tygodnia: 15 miejsc, 14 postaci, ekwipunek i norma żył ([task_05](../ai-tasks/done/task_05.md)).

## 13. Otwarte pytania (zbiorczo)

Na część dostarczono odpowiedz 25.09.2029
1. Jednostka czasu, długość dnia, koszty akcji. Terminy i kara za ich przekroczenie. 
2. Rola wydobycia błękitnego żelaza w mechanice. Znajdowanie złóż które później beda wydobywane jest wymagane przez szefa wyprawy, jezeli gracz za dlugo to ignoruje, to ma upomnienia, a finalnie endgame ze wyprawa wychodzi a on zostaje sam w jaskiniach i wariuje czy cos takeigo.
3. Zagrożenie w FPP: czy gracz może zginąć? Tak, ale to raczej jak juz ma jakies rany albo niska poczytalnosc i interakcja z jakims przedmiotem/innym obiektem na niego zle wplynie.
4. Co zmienia poczytalność NPC i czy gracz widzi pasek? Wydarzenia, przedmioty, postep wglab jaskiń, u kazdeog moze troche inaczej. Gracz ma miec w notatkach o NPCach inforamcje z ich zdrowiem oraz poczytalnoscia jako osobne takie sekcje z notatkami na zasdazie "wygląda na zdrowego" a w poczytalnosc "ostatnio nerwowo sie zachowuje" etc. 
5. Leczenie ran: czym i z jakim ryzykiem. -Bandaże, NPC ktory moze pomoc, ryzyko do ustalenia pozniej.
6. Reputacja: u poszczególnych NPC czy także u frakcji? U npc, u frkacji nie
7. Limity ekwipunku, zużywanie się przedmiotów, działanie amuletu.
8. Czy gracz może nie wrócić do obozu na noc? Nie, zawsze wróci, ale może zmarnować dużo czasu.
