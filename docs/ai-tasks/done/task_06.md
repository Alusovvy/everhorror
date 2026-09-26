<!--
Zadanie zlecone w czacie (2026-09-25), nie przez plik. Requirements to dosłowny cytat prośby.
-->

Requirements:
Przenalizuj projekt, napisz plan usprawnień i poprawek do obecnego demo, ulepszenia historii, questów, flow etc. Po zatwierdzeniu wykonasz prace.

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza (skąd wziął się plan)
Factchecki 03–05 były puste, więc plan powstał z przeglądu kodu, dialogów i specyfikacji. Główne słabości dema po task_05:
1. **Pusty środek tygodnia.** Dni 5–6 nie miały żadnych wydarzeń, a pięciu nowych postaci obozu miało statyczne rozmowy: od drugiego dnia brzmiały identycznie.
2. **Wątek „kogoś na dole”** (świeży chleb w kostnicy, paląca się lampka w kaplicy, stukanie kilofa, dwa razy po czternaście kresek, zeszyt Grabca urwany na „Dniu 14”, nieczytelna nisza) był rozsypany po świecie bez spięcia i bez nagrody za spostrzegawczość.
3. **Wstrząs z piątej nocy** nie zostawiał śladu w świecie.
4. **Dobrawa i Sabina** (Initium vs Exitium!) stały wieczorami obok siebie i milczały.
5. Poza ogłoszeniem i Exitium **nie było scen zbiorowych**.
6. **QoL:** brak suwaka jasności w ciemnym horrorze, jedna wspólna głośność, poranek do powtórki tylko w pamięci (wyjście z gry = strata dnia), skok pozwalał psuć sekwencje, poczytalność bez śladu na obrazie.

Zatwierdzone decyzje (2026-09-25): finał tajemnicy zagadkowy (bez zdradzania, kto liczy — kanon dla Ren), skok usunięty, autozapis świtu na dysk, winieta poczytalności.

## Co zostało zrobione

### Historia i questy
1. **Nowy quest „Czternaście kresek”** (`czternasty`, „Moja sprawa”) [ROBOCZE]:
   - Trzy mocne ślady zakładają quest: kreski w rząpiu, kreski na filarze w Starym wyrobisku, zeszyt Grabca. Cztery słabsze dopisują się tylko, gdy quest już trwa: chleb, lampka, pusta nisza, medalik (nowy, zob. niżej).
   - Wpisy w notesie pisane głosem bohatera („Zmarli nie jedzą. Więc kto tu je?”).
   - **Finał:** od piątej nocy, przy co najmniej czterech śladach, ktoś zostawia przy posłaniu **starą lampę przewodnika** ze znakiem dziadka i czternastoma kreskami na szkle (nowy przedmiot, cenne). Plansza poranka, wpis, quest zamknięty. Kim jest — demo nie mówi.
   - Do tego: akapit w snach nocy 5–7 (ktoś liczy do czternastu i nigdy nie mówi „piętnaście”), wiersz „Czternasty: …” w podsumowaniach obu zakończeń, a w „Zostałeś sam” lampa stoi przy bohaterze, dolana po brzegi.
2. **Wieczory przy ognisku** — nowe siedzisko „Usiądź przy ogniu · 1 h” (od 20:00, raz dziennie) otwiera scenę zbiorową zależną od dnia i od tego, kto żyje i jest w obozie:
   - dni 2–4: opowieści (Wszebor o ogniu-gościu, Sobek o stepie, Nasir o ogniskach na dachach Bakaszu, wrzątek Tekli),
   - dzień 5: pełna kołysanka o Długiej Nocy i Wultanach; Bolko poznaje melodię starej ekipy,
   - dzień 6: wieczór po wstrząsie, Hagiwara czyta swój wiersz („teraz boimy się razem, a nie osobno”),
   - dzień 7: każdy mówi, co zrobi na górze, a milczenie o liczeniu „siedzi przy ogniu na najlepszym miejscu”.
   Scena podnosi poczytalność bohatera, a obecność Mirosława przy ogniu liczy się jak posiedzenie z nim (łagodniejsza noc).
3. **Świat po wstrząsie** (od poranka dnia 6): pęknięty, „oddychający” filar w Starym wyrobisku, świeża szczelina z oddechem pary w Parującej szczelinie i szczelina w Przekopie ze **zgniecionym medalikiem** starej ekipy (ślad do questu). Bolko pamięta, że czterdzieści lat temu też tak drżało. Wszebor o wstrząsie mówił już wcześniej.
4. **Dobrawa × Sabina** — jednorazowa wieczorna scena (dzień 4+, obie w obozie): Initium kontra Exitium, ból, „dom, w którym nie wolno dotykać pytań”. Jeśli bohater nosi kryształ, obie odwracają głowy w tej samej chwili.
5. **Rozliczenie domyka upadową:** jeśli gracz ma list dziadka, a nigdy nie zaprotestował, przy liczeniu dostaje **ostatnią szansę** podania listu Raciborowi („Niech to będzie decyzja Kniazia. Ja podpisuję się tylko pod liczbami.”).
6. **Powitania dnia** dla Wszebora, Nasira, Hagiwary, Sobka, Anzelma i Sabiny: krótkie, zmienne otwarcia zależne od dnia, normy, gorączki i ran bohatera, więc tydzień przestaje brzmieć jak jeden dzień.

### Mechanika i QoL
6a. **Rozmowy: 0,5 h zamiast 1 h, płatne dopiero za treść** (dopisek z czatu, po buildzie): otwarcie rozmowy jest darmowe, a pół godziny nalicza się raz, przy pierwszej odpowiedzi, która nie jest pożegnaniem (pożegnania w plikach dialogów mają znacznik `[#leave]`, 16 opcji otagowanych). Zagadać i wyjść — za darmo. Sceny fabularne (sny, ogłoszenia, ściana, ognisko) nie naliczają tego kosztu. Naliczenie widać toastem „−0,5 h · Rozmowa z…”.
6b. **Poprawka błędu z Twojego zgłoszenia** (wyjątek w `has_flag` przy powrocie trzeciego dnia): flaga miejsca spotkania Drugich trzyma tekst, a `has_flag` robił z niej `bool()` i wybuchał. Teraz flagi z ładunkiem (tekst, liczba, lista) liczą się jako ustawione, gdy ładunek jest niepusty. Do tego `run_tests.sh` oblewa scenariusz, jeśli w logu jest jakikolwiek SCRIPT ERROR — ta klasa błędów nie prześlizgnie się już przez „ALL PASSED” (w starym logu `drudzy` siedziały trzy takie błędy).
7. **Skok usunięty** (decyzja: gra bez walki nie potrzebuje wychodzenia poza ścieżki). Spacja zostaje jako „dalej” w rozmowie.
8. **Opcje:** suwak **Brightness** (0.6–1.4, działa na obraz świata) i osobne głośności **Ambience** i **Sound effects** (Master zostaje). Wszystko zapamiętywane.
9. **Autozapis AUTO:** każdy świt (i chwila po wczytaniu) zapisuje się też na dysk. W LOAD GAME jest rząd **AUTO** — tylko do wczytania, ręczne zapisy go nie ruszają. Po wyjściu z gry albo awarii tester traci najwyżej bieżący dzień.
10. **Winieta poczytalności:** przy pasmie „na krawędzi” brzegi ekranu ciemnieją i powoli pulsują, tym mocniej, im bliżej załamania. Znika w rozmowach i na ekranach.
11. Narzędzie zrzutów ekranu umie teraz ustawić poczytalność bohatera i zostawić HUD (`player_sanity`, `keep_hud`), więc winietę widać na renderach.

### Spójność
12. Gwara śląska dla trzech nowych kwestii Bolka (95 kwestii, pokrycie pełne). Nowe postacie mówią bez gwary, swoimi głosami.
13. `CZYTAJ_MNIE.txt` opisuje sterowanie bez skoku i zmiany przyszłego builda 0.4.

## Decyzje i założenia
- **Finał „Czternastego” niczego nie przesądza.** Lampa, liczenie w snach i dolana oliwa mówią tylko: ktoś tam jest i liczy. Czy to dziadek, ktoś ze starej ekipy, czy coś innego — zostaje dla Ren (fabuła główna). Wszystkie nowe teksty mają [ROBOCZE].
- **Ognisko daje mniej poczytalności niż osobne rytuały** (+4…+6 wobec pieśni +6 i kości +5), ale kosztuje tylko godzinę i działa co wieczór — to „tani rytuał wieczorny”, nie zamiennik rozmów.
- **Autozapis nie jest slotem ręcznym:** nie da się go nadpisać z pauzy, żeby nikt nie stracił świtu przez odruch „SAVE”.
- **Winieta jest celowo subtelna** (bez drżenia kamery i dźwięków) — horror gry siedzi w tekstach, obraz tylko dopowiada.
- **Skok wyleciał razem z akcją wejścia**, nie tylko z obsługą — żaden pad/klawisz go nie przywoła.

## Czego potrzebuję od Ciebie
1. **Factcheck:** [factcheck-test-06](../../human-tasks/done/factcheck-test-06.md) (ok. 1–1,5 h, można łączyć z factcheckiem 05).
2. **Ren:** przegląd questu „Czternaście kresek” i sceny Dobrawa × Sabina (oba [ROBOCZE], oba dotykają kanonu).
3. **Build 0.4 jest gotowy:** `build/Everhorror-demo-0.4-windows.zip` (113 MB). Uruchomiony na tym komputerze: nowa gra startuje bez błędów.
4. Otwarte z task_05 bez zmian: balans normy, limit ekwipunku, klucz Freesound do prawdziwych dźwięków.

## Test
- Instrukcja: [factcheck-test-06](../../human-tasks/done/factcheck-test-06.md).
- **Test dialogów:** 84 sprawdzenia (nowe: powitania, cztery wieczory przy ognisku, Bolko o wstrząsie, quest „Czternaście kresek” ze snem i lampą, ostatnia szansa z listem, scena dwóch Drugich z kryształem). Przechodzi.
- **Rozmowy 0,5 h:** `day1` sprawdza wprost, że dwie rozmowy = 1 h i że zagadnięcie Sobka z samym „Muszę iść.” nic nie kosztuje; test dialogów sprawdza, że znacznik `[#leave]` się parsuje, a tekst opcji zostaje czysty. `drive()` w testach przechodzi teraz przez tę samą ścieżkę co klik gracza.
- **Scenariusz `week`** rozszerzony: autozapis na dysku po świcie, trzy ślady wstrząsu aktywne w świecie, siedzisko przy ogniu włącza się o 20:00 i znika po scenie, prawdziwe rozegranie wieczoru (+5 poczytalności, −1 h), lampa i wiersz „Czternasty” w zakończeniu „Zostałeś sam”. Przechodzi.
- **Pełny zestaw scenariuszy** (za zgodą z planu, w trzech porcjach): wszystkie 11 przechodzi — `dialogue` 4 s, `day1` 21 s, `save_load` 7 s, `rzapie` 10 s, `night1` 8 s, `day2` 11 s, `kaplica` 13 s, `day3` 9 s, `expedition` 14 s, `drudzy` 18 s, `week` 21 s.
- **Zrzut ekranu:** winieta przy poczytalności 10 („na krawędzi” pod zegarem, ciemniejsze rogi) sprawdzona na renderze 1280×720.

## Podsumowanie
Środek tygodnia przestał być pusty: co wieczór jest dokąd usiąść, ludzie witają się po swojemu, wstrząs zostawia ślady, a najciekawsza tajemnica dema — kto zostawia chleb zmarłym i liczy do czternastu — jest teraz questem z cichym, zagadkowym finałem. Rozliczenie tygodnia domyka wątek upadowej ostatnią szansą z listem dziadka. Do tego cztery rzeczy, o które prosili testerzy zanim zdążyli poprosić: jasność, osobne głośności, autozapis świtu i czytelny na ekranie stan głowy. Skoku nie ma.

Czekam na factcheck (05 i 06 można przejść razem) i na przegląd Ren. Build 0.4 leży w `build/` i jest gotowy do wysłania testerom (przebudowany po zmianie kosztu rozmów i poprawce `has_flag`).
