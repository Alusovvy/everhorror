# Mechaniki

Dokument rozwija sekcję 4 [GDD](GDD.md) do poziomu, na którym da się je zaimplementować. Opisuje, jak ma działać gra; historia i postacie zostają w GDD.

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

❓ Czy gracz może nie wrócić na noc, np. utknąć w tunelach? Jaka jest wtedy konsekwencja?

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

❓ Ile trwa dzień i ile kosztują poszczególne akcje?
❓ Jakie są terminy? Jeden globalny (np. dostawa dla Kniazia), czy osobne dla questów?
❓ Co się dzieje, gdy termin minie? Przegrana, gorsze zakończenie, czy utrata questu?

## 5. Eksploracja kopalni

### 5.1 Struktura **[GDD]**
Kopalnia → jaskinie → Świątynia Onych. Im niżej, tym groźniej. Każdy poziom składa się z **segmentów tuneli / pomieszczeń**, do których gracz przechodzi ze stołu z mapą.

### 5.2 Mapa **[GDD]**
- Mapa pokazuje **odkryte pomieszczenia**.
- **Lista zmapowanych złóż** błękitnego żelaza.
- **Niezbadane odnogi**, czyli miejsca, dokąd można pójść dalej.

**[propozycja]** Mapa to graf pomieszczeń. Każde pomieszczenie ma stan (nieznane / widoczna odnoga / odkryte / zablokowane) i koszt podróży w godzinach. Kolejne pomieszczenia odblokowuje eksploracja, notatki dziadka (jego mapy gracz zna „na pamięć”) albo pomoc NPC (np. wysadzenie zawaliska).

### 5.3 Wydobycie
Gracz wydobywa błękitne żelazo i znajduje notatki dowódcy poprzedniej ekipy **[GDD]**.

❓ Po co wydobywać? Czy to waluta, reputacja w Ekspedycji, dzienna norma, czy tylko fabuła?

### 5.4 Zagadki
Proste zagadki logiczne w pomieszczeniach **[GDD]**. Dziadek był kryptografem, więc naturalne są zagadki oparte na szyfrach i mapach **[propozycja]**.

### 5.5 Zagrożenie
❓ Czy w tunelach jest bezpośrednie zagrożenie w FPP (pościg, śmierć gracza), czy horror opiera się na atmosferze i konsekwencjach w VN? Brak takiego zagrożenia w FPP pasuje do zasady, że eksploracja 3D nie zajmuje czasu.

## 6. Ekwipunek

Przed wyprawą gracz wybiera, co bierze ze sobą **[GDD]**, np. paliwo do lampy i liny. Przedmioty mogą też pochodzić od NPC (rozdz. 7).

**[propozycja]**
- Ograniczona liczba miejsc na wyprawę, co wymusza wybór.
- Paliwo do lampy działa jak zasób wyprawy: bez światła nie da się wejść do niektórych pomieszczeń albo rośnie ryzyko.
- Przedmioty są kluczami do pomieszczeń i zagadek (lina → zejście w szyb).

❓ Czy przedmioty się zużywają? Czy jest amulet z błękitną stalą i czy ma działanie mechaniczne (sny, wizje, podpowiedzi)?

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

❓ Co obniża i co podnosi poczytalność (eventy, wyprawy, rozmowy z graczem, śmierć innych NPC)? Czy gracz widzi pasek, czy tylko objawy w dialogach? **[propozycja]** Tylko objawy, bo to bardziej horror.

### 7.3 Zdrowie, rany, śmierć **[GDD]**
- NPC mogą odnosić rany, a gracz może próbować je leczyć.
- NPC mogą umrzeć.

❓ Czym się leczy (przedmioty, czas, NPC o roli medyka)? Czy leczenie może się nie udać?

### 7.4 Obecność w obozie **[GDD]**
NPC mogą pojawiać się w obozie i znikać z niego (wyprawy, ucieczka, śmierć, przybycie nowych).

**[propozycja]** Każdy NPC ma stan: *w obozie / w tunelach / zaginiony / uciekł / martwy*.

### 7.5 Pomoc NPC w pomieszczeniach **[GDD]**
Niektóre pomieszczenia wymagają specjalisty. Gracz nie idzie z nim fizycznie. W panelu VN wybiera opcję typu *[Poproś XYZ o pomoc, bo się na tym zna]*. To kosztuje dużo czasu, bo trzeba po niego pójść i wrócić.

Opcja jest dostępna tylko wtedy, gdy NPC o danej roli żyje, jest w obozie i (**[propozycja]**) ma wystarczającą reputację lub poczytalność.

### 7.6 Reputacja
Przychylność części towarzyszy trzeba sobie zasłużyć, bo gracz jest równorzędnym członkiem ekspedycji, a nie dowódcą **[GDD]**. Reputacja odblokowuje informacje, opcje dialogowe i pomoc.

❓ Czy jest też reputacja u frakcji, czy tylko u poszczególnych NPC?

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
| 2 | Interakcja (raycast + `Interactable`) | komponent / `Area3D` + podpowiedź w UI | ✅ podświetlenie, [E] opis |
| 3 | Tryb VN (dialog, opcje) | scena UI + dane dialogów jako `Resource` | 🟡 prototyp UI w `visual_interaction.tscn` |
| 4 | Stan gry (flagi, czas, dzień) | autoload `GameState` | ⬜ |
| 5 | Upływ czasu i sen | w `GameState` + sygnały | ⬜ |
| 6 | NPC (dane, reputacja, poczytalność, zdrowie, stan) | `NpcData` (`Resource`) + autoload/rejestr | ⬜ |
| 7 | Warunki i efekty opcji dialogowych | w danych dialogów, wykonywane przez `GameState` | ⬜ |
| 8 | Notes questów | `QuestData` + UI | ⬜ |
| 9 | Mapa kopalni i podróż | graf pomieszczeń + UI stołu z mapą, ładowanie scen segmentów | ⬜ |
| 10 | Ekwipunek na wyprawę | `ItemData` + UI | ⬜ |
| 11 | Zapis / odczyt | `SaveManager` + grupa `persist` | 🟡 3 sloty, zapis pozycji gracza; stan gry dojdzie z krokiem 4 |
| 12 | Menu główne, pauza, opcje | `main_menu.tscn`, `pause_menu.tscn` | ✅ |

**Minimalny grywalny wycinek:** kroki 1–5 oraz jeden NPC z kroku 6. Chodzimy po obozie, rozmawiamy z NPC w VN (co zajmuje czas), idziemy spać, a następnego dnia widać zmianę.

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
