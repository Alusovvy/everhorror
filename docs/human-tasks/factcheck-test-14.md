# PT0: sesja gry na buildzie 0.5.3

> Zadanie: [task_14](../ai-tasks/task_14.md) · Przygotowano: 2026-10-26 · Czas: 1–2 h
> Jeden arkusz zamiast sześciu otwartych factchecków: [08](done/factcheck-test-08.md), [09](done/factcheck-test-09.md), [10](done/factcheck-test-10.md), [11](done/factcheck-test-11.md), [12](done/factcheck-test-12.md), [13](done/factcheck-test-13.md) (78 wierszy; decyzja [planu końcowego](../analizy/final-plan-human-readable.md), etap 3). Zostały tylko rzeczy, które ocenia człowiek: odczucie, czytelność, ton i obraz.
> Kolumny „wynik” i „uwagi” oraz pola ankiety wypełnia człowiek. Agent niczego tu nie wpisuje: puste pole znaczy „nie sprawdzono”.

## Co nowego w 0.5.3
- **Poprawki.** Sabina oraz Ottokar, Hieronim i Welf nie tracą poczytalności, zanim dotrą (NPC-18). Wstęp mówi, że stół z mapą stoi w zagrodzie Racibora, za niską palisadą bez dachu. Z kodu zniknął martwy warunek odejścia Hieronima (w grze bez zmian).
- **Wersja** w prawym dolnym rogu menu głównego: „0.5.3 · spec …” ze skrótem commita specyfikacji (UI-6).
- **Raport przebiegu** (ZAP-11, UI-7): na końcu tygodnia i po naciśnięciu SAVE REPORT w pauzie gra zapisuje lokalnie plik `.md` i `.json`. Nic nie jest wysyłane przez sieć. Zapis gry ma teraz wersję 6 (ZAP-12); starsze zapisy nadal się wczytują.
- **Ekran końca tygodnia** mieści się w oknie: gdy podsumowanie jest długie, znika logo, a tekst robi się mniejszy, żeby przyciski MAIN MENU i EXIT były widoczne. Pod podsumowaniem stoi nazwa zapisanego raportu.
- Poza grą: bot balansu (narzędzie programisty) i `CHANGELOG.md` w archiwum.

## Jak zdobyć build
- Archiwum: `build/Everhorror-demo-0.5.3-windows.zip` (w folderze gry, `C:\dev\gamedev\everhorror\everhorror\build\`). Rozpakuj do dowolnego folderu i uruchom `Everhorror.exe`. W archiwum leżą też `CZYTAJ_MNIE.txt` i `CHANGELOG.md`.
- Na ekranie menu głównego sprawdź napis w prawym dolnym rogu i wpisz go niżej, żeby było wiadomo, jaki build oceniono.

## Gdzie ląduje raport przebiegu
- Folder: `%APPDATA%\Godot\app_userdata\Everhorror\raporty\` (Win+R, wklej adres i Enter; folder powstaje przy pierwszym zapisie raportu). Nazwa `Everhorror` to nazwa projektu z `project.godot`.
- Pliki: `przebieg-<data>_<godzina>.md` (do czytania) i `.json` (do liczenia). Powstają na końcu tygodnia (oba zakończenia) i po naciśnięciu SAVE REPORT w pauzie. Po śmierci bohatera same nie powstają.
- Zapisy gry (`saves\`) leżą w tym samym folderze danych, z którego korzystają też testy agenta na tym komputerze. Na czas sesji PT0 agent nie uruchamia scenariuszy ze światem (od tej wersji przywracają one zapisy po sobie, ale sesja nie powinna się z nimi zbiegać).

## Dane sesji (wypełnia człowiek)

| Data sesji | Napis z menu głównego | Łączny czas gry | Dotarcie do (dzień albo zakończenie) |
|---|---|---|---|
| | | | |

## Jak grać
Zacznij nową grę (START) i graj normalnie, najlepiej cały tydzień (dni 1–7). Nie trzeba szukać błędów na siłę: ważne, co czuć, co jest jasne, a co nie. Wiersze poniżej idą mniej więcej w kolejności, w jakiej się na nie trafia, więc nie trzeba ich robić osobno. Wieczorem każdego dnia, tuż przed snem, wpisz liczbę do tabeli „dziś zabrakło mi czasu” (niżej, pytanie 3).

## Sprawdzenia (tylko to, co ocenia człowiek)

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Wersja w menu głównym (UI-6) | Uruchom grę i popatrz na prawy dolny róg menu głównego. Potem START i [Esc] w grze | Napis „0.5.3 · spec …” ze skrótem commita jest przyciemniony, czytelny i niczego nie zasłania. W menu pauzy go nie ma | | |
| 2 | Wstęp: stół z mapą | Nowa gra, przeczytaj wstęp do końca. Potem wejdź do zagrody Racibora i podejdź do stołu z mapą | Ostatnie zdanie wstępu mówi o stole z mapą w zagrodzie Racibora, za niską palisadą bez dachu, i zgadza się z tym, co widać w obozie. Brzmi naturalnie. Palisada ma ok. 2 m: jeśli „niską” do niej nie pasuje, wpisz to w uwagach (pytanie czeka w karcie `zgloszenia/2026-10-26_niska-palisada.md` w specyfikacji) | | |
| 3 | Obóz: wrażenie, przestrzeń, światło | Po obudzeniu rozejrzyj się, potem przejdź obóz wzdłuż i wszerz, rano i wieczorem (jasność 1.0) | Skalna jaskinia z wysokim sklepieniem, nie hala z desek. Dużo miejsca między strefami, nigdzie nie trzeba się przeciskać. Wszystkie strefy da się rozpoznać, nigdzie nie jest całkiem czarno | | |
| 4 | Obóz: postaci wyglądają naturalnie | Obejdź obóz rano (6–8), w dzień (10–14) i wieczorem (po 20:00). Przy każdej postaci popatrz, jak stoi albo siedzi | Każdy robi coś wiarygodnego i pasującego do pory dnia. Nikt nie tkwi w skale ani w rekwizycie, nie jest przekrzywiony i nie patrzy nosem w ścianę (poza modlącym się Anzelmem) | | |
| 5 | Dzień 1: ludzie na szychcie | W dniu 1 idź do Starej sztolni, do rząpia i (po wysadzeniu zawału) do Zawalonego chodnika. Porozmawiaj z każdym spotkanym | Spotkani stoją przy robocie, nikt nie tkwi w ścianie ani w drugiej osobie. Opis i pierwsze zdanie pasują do miejsca (sztolnia, rząpie, szczelina za zawałem) i do postaci, nic nie brzmi dziwnie. Po rozmowie postać zostaje na miejscu | | |
| 6 | Dzień 1 wieczorem i dzień 2 rano | Wróć do obozu po 20:00, usiądź przy ognisku, prześpij noc. W dniu 2 zagadaj do kogoś, kogo jeszcze nie ma w notesie | Wieczorem dnia 1 piątki z szychty nie ma w obozie, a przy ogniu pada, że połowa ekipy została na nocnej szychcie. Rano w dniu 2 wszyscy są w obozie na swoich miejscach, a nowo poznana osoba wita się zwyczajnie, bez zdań o szychcie | | |
| 7 | Czas: czy wiadomo, na co idzie | Po kilku rozmowach i wyprawach otwórz notes [J] → „Czas”. Zwróć uwagę na dymki po rozmowach (np. „−5 min · Rozmowa z …”) i na koszt dróg na mapie | Bez instrukcji da się powiedzieć, na co poszedł czas dnia. Lista dnia, suma i „Do nocy zostało…” są zrozumiałe, dymki nie zaskakują, nic nie zjada czasu po cichu | | |
| 8 | Wyszarzone opcje w rozmowach | W dniu 1: Tekla, Racibor, Dobrawa. Od dnia 2: Bolko, zanim zacznie ufać (opcja o kaplicy), i Nasir przy zadaniu o pompach, ale bez oleju | Szara opcja mówi, czego brakuje (zaufania albo przedmiotu). W dniu 1 nie ma szarych opcji, które zdradzają fabułę (tobołek, ukryty towar, kryształ z kaplicy) | | |
| 9 | „Ryba dla Hrapka”: czy wiadomo, co robić | Gdy Hrapek poprosi o rybę, zdobądź ją dowolną drogą: od Tekli, przy stawie ze Wszeborem albo Mirosławem (gdy pompy działają), albo za bandaż dla Wszebora (gdy pompy stoją). Oddaj rybę Hrapkowi | Z notesu i rozmów wiadomo, co robić i skąd wziąć rybę. Odmowa łowienia przy zalanym stawie mówi dlaczego i podsuwa wymianę za bandaż. Ton Wszebora i Mirosława (gwara) pasuje do postaci. Po oddaniu ryby Hrapek mówi o NIM, bez rymów, i zadanie się zamyka | | |
| 10 | Hrapek: ton, wygląd, śmierć | Od dnia 3, po wysadzeniu zawału, wracaj z wypraw do obozu aż do spotkania z Hrapkiem i porozmawiaj. W dniu 6 wróć z tunelu | Scena zaczyna się od szurania, Hrapek mówi wierszem i nazywa bohatera Cesarzem: dziwnie i intrygująco, nie śmiesznie. Wygląd (blady, łysy, bez koszuli) nie razi. Jeśli przeszkadza muskularne ciało z bazy modelu, zapisz to w uwagach. Ciało i pierścień w dniu 6 robią wrażenie, a wpis w notesie i linijka w podsumowaniu tygodnia są zrozumiałe | | |
| 11 | Sny: list dziadka i liczenie kresek | Odszyfruj wiadomość dziadka i prześpij noc. Jeśli zadanie „Czternaście kresek” jest aktywne, prześpij też ostatnią noc (po dniu 7) | Sen po pierwszej nocy po odszyfrowaniu kończy się kartką dziadka z odszyfrowanymi zdaniami „twoim pismem”, tylko raz. W ostatnim śnie ktoś liczy szeptem do czternastu i nigdy nie mówi „piętnaście”: niepokoi, nie śmieszy | | |
| 12 | Tempo i zmęczenie | W dniach 2–4 rób dalekie wyprawy (np. sztolnia → wyrobisko → grota), z ogniskiem wieczorem i snem. Po 2–3 dniach oceń odczucie | Zmęczenie jest odczuwalne (słowo w rogu ekranu i w plecaku), ale nie blokuje normy. Powrót za połowę drogi nie ułatwia za bardzo. Mapa czytelnie pokazuje koszt dróg | | |
| 13 | SAVE REPORT w pauzie (UI-7) | W trakcie gry (dzień 2 lub później) naciśnij [Esc] i SAVE REPORT. Potem otwórz folder raportów (adres wyżej) | Przycisk stoi w pauzie między OPTIONS a MAIN MENU. Po naciśnięciu menu pokazuje po angielsku ścieżkę zapisanego pliku, czytelną bez przewijania. W folderze leżą oba pliki: `przebieg-….md` i `.json`. Gra nie zawiesza się ani nie wychodzi z pauzy | | |
| 14 | Raport przebiegu: czytelność (ZAP-11) | Po końcu tygodnia (wtedy raport ma dni 1–7 i zakończenie) otwórz `przebieg-….md` w zwykłym edytorze tekstu | Widać, gdzie uciekł czas (rozmowy, drogi, żyły itd.), ile żył było o świcie każdego dnia, jaki jest zapisany stan bohatera i poznanych postaci oraz jakie zapisano kluczowe wybory i zakończenie. Postacie, które jeszcze nie dotarły, mają kreskę zamiast stanu. Niczego nie brakuje i nic nie myli | | |
| 15 | Ekran końca tygodnia (ZAP-11) | Na końcu tygodnia (albo przy „Zostałeś sam”) popatrz na ekran końca w oknie gry, nie na pełnym ekranie | Podsumowanie i przyciski MAIN MENU / EXIT są widoczne w całości. Przy długim podsumowaniu nie ma logo, a tekst jest mniejszy, lecz czytelny. Pod tekstem stoi nazwa zapisanego raportu („raporty/przebieg-….md”). Brak logo nie przeszkadza; jeśli wolisz przewijane podsumowanie z logo, wpisz to w uwagach | | |

Źródło tematów (to nie jest zaliczenie starych arkuszy): wiersz 2 z FC 08 nr 11; 3 z FC 08 nr 1, 2, 10; 4 z FC 08 nr 6–9; 5 z FC 10 nr 3–7 i FC 11 nr 1–4; 6 z FC 10 nr 8–10; 7 z FC 09 nr 2, 3; 8 z FC 09 nr 7–9; 9 z FC 09 nr 14–16 i FC 13 nr 4–9; 10 z FC 09 nr 11, 18–21; 11 z FC 13 nr 1–3; 12 z FC 12 nr 5, 12. Wiersze 1, 13, 14 i 15 są nowe w 0.5.3. Pozostałe wiersze starych arkuszy to mechanika (koszty czasu, flagi, zapis, kolejność zdarzeń): nie wchodzą do PT0 i nie są przez to sprawdzone przez człowieka. Część z nich pilnują testy automatyczne, ale to nie jest weryfikacja człowieka. Wpisy człowieka w starych arkuszach (factcheck 10, wiersze 1–2) zostają bez zmian.

## Ankieta (skala 1–7)
Pytania 1, 2, 4 i 5 wypełnij raz, po zakończeniu gry (albo po ostatnim dniu, do którego udało się dotrzeć). Pytanie 3 wypełniaj po każdym dniu. Jedna liczba w polu, uwagi są dowolne. Przy jednym testerze ankieta pokazuje tylko kierunek, nie dowód.

| # | pytanie | skala | wynik | uwagi |
|---|---|---|---|---|
| 1 | Napięcie w tunelach | 1 = brak napięcia, 7 = bardzo silne | | |
| 2 | Rozumiem, co kosztuje czas | 1 = zupełnie nie, 7 = w pełni | | |

**3. „Dziś zabrakło mi czasu”.** Wpisz liczbę wieczorem, tuż przed snem, po każdym dniu gry. 1 = czasu było aż nadto, 7 = zabrakło wyraźnie. W uwagach można zapisać, co zjadło czas.

| Dzień | wynik (1–7) | uwagi |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |

| # | pytanie | skala | wynik | uwagi |
|---|---|---|---|---|
| 4 | Przywiązanie do ludzi z obozu | 1 = obojętni, 7 = bardzo mi na nich zależy | | |
| 5 | Ciekawość „co niżej” | 1 = żadna, 7 = bardzo chcę wiedzieć | | |

## Gdzie było nudno albo trudno się połapać?

-

## Inne uwagi i błędy

-

## Raport przebiegu: dołącz plik
Po zakończeniu tygodnia skopiuj z folderu raportów (adres wyżej) najnowsze `przebieg-….md` i `.json`, dołącz je do tego arkusza (np. obok niego, w tym folderze) i wpisz niżej ich nazwy. Jeśli raport nie powstał, zapisz to w uwagach.

| Plik `.md` | Plik `.json` | Uwagi |
|---|---|---|
| | | |
