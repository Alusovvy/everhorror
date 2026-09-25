Requirements:
1. Poprawki z factcheck-test-01 (pkt 6): za ciemna podłoga w jaskini, przenikanie przez ściany jaskini, „czarna masa” pod kilofem.
2. Stan gry i czas: autoload `GameState` (dzień, godzina, flagi), dzień = 16 h, koszt czasu widoczny w podpowiedzi, zapis/odczyt całego stanu.
3. Tryb VN na Dialogue Manager: dialogi z warunkami (reputacja, flagi, przedmioty) i efektami (czas, reputacja, poczytalność, notatki); portret NPC renderowany z modelu 3D.
4. NPC: `NpcData` wg karty z GDD; Mirosław z Głuszy + drugi NPC (roboczo: stary górnik, który znał dziadka); modele i animacje Quaternius (CC0).
5. Stół z mapą i podróż: „Stara sztolnia (wschód)” (obecny korytarz + jaskinia) i „Zawalony chodnik (zachód)” — zablokowany, otwiera go pomoc Mirosława (wysadzenie).
6. Noc: posłanie → rozliczenie nocy (poczytalność, flagi) → sen w trybie VN (amulet) → „Dzień 2” → widoczne zmiany w obozie zależne od wyborów z dnia 1 → plansza „Koniec wersji demo”.
7. Notes pod [J]: aktywne zadania i znalezione notatki.
8. Szlif: obóz z rekwizytów w drewnianej hali (posłanie, ognisko, stół z mapą, skrzynie), prawdziwe dźwięki zamiast generowanych tam, gdzie się da (CC0), factcheck-test-03.

Kontekst:
- Najmniejszy vertical slice wg `docs/MECHANICS.md` §12 i `docs_v2/01_wizja.md`: obóz + jeden poziom tuneli + 2 NPC + pełny cykl dzień → noc → dzień, ok. 10–15 min gry, pokazuje trzy filary (czas, ludzie się kruszą, tajemnica w głąb).
- Nazwa gry wciąż w dyskusji — na razie wszędzie **Everhorror** (także na planszy końcowej).

Założenia (zaakceptowane):
- Dzień 16 h; rozmowa 1 h, podróż 2 h, pomoc NPC 4 h; po wyczerpaniu godzin trzeba iść spać.
- Poczytalność niewidoczna jako liczba — tylko objawy w dialogach.
- Teksty gry po polsku; imię i historia drugiego NPC robocze, do poprawki przez Rena.
- Brak śmierci gracza w FPP.
- Darmowe assety tylko z licencją CC0 lub równoważną (wpis do `docs_v2/05_oprawa.md`).

Kryteria akceptacji:
- Da się przejść cały scenariusz: obóz → rozmowy → mapa → wyprawa → powrót → sen → Dzień 2 → koniec demo, bez błędów.
- Wybory z dnia 1 (pomoc Mirosławowi / zadanie / wyprawa) dają widoczną różnicę w dniu 2.
- Zapis w dowolnym momencie FPP i odczyt przywraca dzień, godzinę, stan NPC, notes i pozycję.

Poza zakresem:
- Walka, ekwipunek z limitem miejsc, rany i leczenie, frakcje, więcej poziomów, zakończenia gry.

Priorytet: wysoki

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione

### 1. Poprawki z factcheck-test-01 ✅
- **Podłoga jaskini** jest teraz jedną ciągłą powierzchnią z teksturą z zestawu kopalni. Wcześniej były tam osobne płyty z dziurami, pod którymi była pustka („czarna masa” pod kilofem). Kilof i kartka leżą na ziemi.
- **Przenikanie przez ściany:** ściany jaskini z zestawu kolidują tylko z jednej strony. Dodałem niewidzialne ściany wokół jaskini i sprawdziłem testem, że z żadnego z 16 kierunków nie da się wyjść.
- W jaskini przy wejściu wisi ciepła latarnia, a sufit nie ma już dziur.

### 2. Stan gry i czas ✅
- Autoload `GameState`: dzień, godzina, flagi, przedmioty, notatki, zadania, stan NPC (poczytalność, zdrowie, reputacja).
- Dzień trwa od 06:00 do 22:00. Rozmowa to 1 h, wyprawa i powrót po 2 h, wysadzenie zawału 4 h. Po 22:00 rozmowy i wyprawy są zablokowane, zostaje posłanie.
- Koszt widać w podpowiedzi („[E] Porozmawiaj z Mirosławem · 1 h”), a zegar w rogu ekranu. Po każdej akcji pojawia się komunikat „−1 h · Rozmowa z Mirosławem”.
- Zapis i odczyt obejmują cały stan. Sloty pokazują dzień i godzinę gry, a zabrane przedmioty i wysadzony zawał zostają po wczytaniu.

### 3. Tryb VN ✅
- Dialogue Manager i własny ekran rozmowy: rozmyty obraz gry w tle, **portret 3D postaci renderowany na żywo** (gestykuluje, kiedy mówi), imię, tekst wpisujący się literka po literce, odpowiedzi po prawej. Narracja jest w wyciszonym kolorze.
- Warunki (reputacja, flagi, przedmioty, poczytalność, czas) i efekty (czas, reputacja, poczytalność, notatki, zadania) są zapisane w plikach `dialogue/*.dialogue`. Można je edytować w zakładce **Dialogue** w edytorze Godota.
- **Teksty przepisałem na naturalną polszczyznę** (na Twoją prośbę): Mirosław jest mrukliwy i szorstki, Bolko to stary, zrzędliwy górnik. Mniej „literackich” zdań, więcej mowy potocznej.

### 4. NPC ✅
- Karty `NpcData` według szablonu z GDD (`data/npc/*.tres`): **Mirosław z Głuszy** (poczytalność 38/50) i **Stary Bolko** (roboczy, zna dziadka).
- Modele: Quaternius *Universal Base Characters* z *Modular Character Outfits – Fantasy* (strój chłopski, dwa warianty kolorystyczne) i animacje z *Universal Animation Library*, wszystko na licencji CC0. Animacje przeniosłem na postacie przez retargeting humanoidalny w Godocie. Mirosław siedzi przy ognisku na pniu, Bolko stoi przy stole z mapą.

### 5. Stół z mapą i podróż ✅
- Stół otwiera „mapę dziadka”: rysunek chodników i dwa kierunki z kosztem czasu.
- Przejścia z obozu są zabite deskami, więc na wyprawę idzie się tylko przez mapę (inaczej czas podróży nie miałby sensu). Powrót następuje przez drogowskaz przy deskach.
- **Stara sztolnia:** korytarz, pochylnia, jaskinia; tam skrzynka z lontami i kartka z szyfrem.
- **Zawalony chodnik:** otwiera się dopiero, gdy Mirosław go wysadzi (oddane lonty + 4 h). Za gruzem jest deska z kluczem do szyfru, a dalej połamane stemple (zaczepka na kolejne etapy).

### 6. Noc i dzień 2 ✅
- Posłanie prowadzi do snu (tekst na czerni, zależny od tego, gdzie byłeś i czy był wybuch), a potem do rozliczenia nocy:
  - Mirosław traci 6 pkt poczytalności. Jeśli był wybuch, traci dodatkowo 12, a jeśli z nim posiedziałeś, tylko 4.
  - Mając kartkę i klucz, rano masz odszyfrowaną wiadomość dziadka.
- **Dzień 2 zależy od wyborów:**
  - Mirosław siedzi przy ognisku albo skulony w ciemnym kącie.
  - Bolko czeka przy posłaniu, jeśli ci ufa; stoi odwrócony plecami, jeśli go obraziłeś; w pozostałych przypadkach stoi przy stole.
  - Rozmowy w dniu 2 są inne niż w dniu 1.
- Stół z mapą w dniu 2 kończy demo planszą z podsumowaniem Twoich wyborów.

### 7. Notes [J] ✅
- Zakładka **Zadania**: „Ślady dziadka” i „Lonty dla Mirosława”, pisane głosem bohatera.
- Zakładka **Notatki**: notatka dowódcy, kartka z szyfrem, klucz i odszyfrowana wiadomość.

### 8. Szlif 🟡
- **Obóz:** posłanie, ognisko (płomienie, migoczące światło, trzask), pnie do siedzenia, stół z mapą ze świecą, skrzynie z zapasami. Rekwizyty Kenney *Survival Kit* (CC0) dostały tekstury z zestawu kopalni, żeby nie wyglądały jak plastik.
- Nowy dźwięk: huk wybuchu (generowany, jak pozostałe).
- ❌ **Prawdziwych nagrań CC0 zamiast generowanych dźwięków nie zrobiłem.** Freesound wymaga Twojego klucza API, a paczkę Sonniss trzeba ręcznie pobrać (kilka GB). Wygenerowane dźwięki zostają na razie.
- [factcheck-test-03](../human-tasks/factcheck-test-03.md) jest gotowy.

### Dodatkowo (na Twoją prośbę w trakcie)
- **Build do wysłania znajomym:** `build/Everhorror-demo-0.1-windows.zip` (97 MB). W środku jest `Everhorror.exe` (jeden plik) i `CZYTAJ_MNIE.txt` z instrukcją. Build sprawdziłem na tym komputerze (menu i nowa gra uruchamiają się bez błędów).
- Do eksportu: szablony eksportu Godota 4.7.2, preset „Windows Desktop” (`export_presets.cfg`) oraz naprawione ścieżki `res://Assets/` w zestawie kopalni. Bez tej poprawki build nie miałby tekstur.
- **Testy automatyczne:** `tools/dialogue_test.gd` sprawdza logikę rozmów, a `tools/slice_test.gd` przechodzi **całe demo** (30+ sprawdzeń, w tym zapis i odczyt w środku dnia). Oba przechodzą.
- **Gwara śląska górników:** Mirosław (lżej) i Bolko (mocniej) mówią z elementami gwary, zrozumiałej dla każdego Polaka. Gwara jest domyślnie włączona. Przełącznik: **OPTIONS → Silesian dialect (miners)**, zapisywany w ustawieniach.
  - Oryginały zostały nietknięte w `dialogue/*.dialogue`.
  - Wersje śląskie (49 linii) są w `dialogue/gwara_slaska.json`, generowanym przez `tools/generators/write_gwara.js`. Gra wczytuje je jako tłumaczenie Dialogue Managera.
  - Narracja i odpowiedzi gracza zostają w zwykłej polszczyźnie.
  - `dialogue_test.gd` pilnuje, żeby każda linia górnika miała wersję śląską i żeby przełącznik działał w obie strony. **Uwaga:** zmiana oryginalnej linii w `.dialogue` wymaga poprawienia klucza w `write_gwara.js`, inaczej ta linia wraca do zwykłej polszczyzny (test to wyłapie).
  - Build i `CZYTAJ_MNIE.txt` są zaktualizowane.

## Decyzje i założenia
- **Fabuła wycinka** to moja propozycja do przejrzenia przez Rena i Vitava: szyfr dziadka na wschodzie, klucz na zachodzie, odszyfrowana wiadomość o „Nich” i błękicie. Bolko to postać robocza.
- **Obóz** to południowa część hali. Wyprawy są możliwe tylko przez mapę (deski na przejściach).
- **Poczytalność** ma pasma: spokojny ≥ 40, niespokojny ≥ 20, na krawędzi > 0. Gracz nie widzi liczby, tylko objawy w tekście i zachowaniu.
- **Portret VN** renderuje się z modelu 3D, więc na razie nie potrzeba żadnych rysunków 2D.
- **Nazwa:** „Everhorror” w tytule okna i na planszy końcowej. Logo nadal mówi EVEROLD.
- **Zmieniłem pliki zestawu kopalni** (tylko wielkość liter w ścieżkach), wbrew zasadzie „nie edytujemy paczek”. Bez tego nie da się zrobić buildu.
- Menu nadal jest po angielsku (START, OPTIONS…), a cały tekst w grze po polsku, zgodnie z wcześniejszą decyzją.

## Czego potrzebuję od Ciebie
1. **Zagraj** według [factcheck-test-03](../human-tasks/factcheck-test-03.md) i daj build znajomym.
2. **Wysyłka buildu:** ZIP ma 97 MB, więc Discord go nie przyjmie (limit 10 MB). Użyj Google Drive albo WeTransfer, albo wróćmy do automatycznych buildów z task_02 (itch.io lub GitHub Releases).
3. **Ren i Vitav:** przejrzyjcie Bolka i wątek szyfru. Teksty łatwo zmienić w `dialogue/*.dialogue` i `tools/generators/write_story_data.js`.
4. **Dźwięki:** klucz Freesound (`setx FREESOUND_API_KEY "..."`) albo pobrana paczka Sonniss. Wtedy podmienię wygenerowane dźwięki na prawdziwe.

## Test
Lista do sprawdzenia: [docs/human-tasks/factcheck-test-03.md](../human-tasks/factcheck-test-03.md) (26 punktów plus scenariusz pełnego przejścia).

## Podsumowanie
Vertical slice jest grywalny od początku do końca, w około 20 minutach:
- **Dzień 1:** wstęp, obóz z dwiema postaciami, rozmowy w trybie VN z portretami 3D, wyprawa na wschód po lonty i szyfr, wysadzenie zawału i wyprawa na zachód po klucz.
- **Noc:** sen, rozliczenie poczytalności, odszyfrowana wiadomość dziadka.
- **Dzień 2:** zmiany w obozie zależne od wyborów, potem plansza końca demo z podsumowaniem.

Pokazane są wszystkie trzy filary:
- **czas:** każda akcja kosztuje godziny, a dzień się kończy,
- **ludzie się kruszą:** poczytalność Mirosława, zaufanie Bolka,
- **tajemnica w głąb:** szyfr dziadka i „Oni”.

Poprawiłem błędy z testu 01 i przepisałem dialogi na naturalną polszczyznę. Automatyczny test całego demo przechodzi, a build dla znajomych jest gotowy. Brakuje tylko prawdziwych nagrań dźwięków.
