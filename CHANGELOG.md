# Dziennik zmian

Co się zmieniło w kolejnych wersjach Everhorror, od najnowszej. Przy każdej wersji jest „Zgodność ze spec”: skrót commita specyfikacji (repozytorium `specification`), z którą ta wersja jest zgodna. Numer wersji jest w ustawieniach projektu (`application/config/version`), w nagłówku `tools/release/CZYTAJ_MNIE.txt` i w prawym dolnym rogu menu głównego gry (TECH-1, TECH-2). Ten plik trafia do archiwum ZIP obok `CZYTAJ_MNIE.txt`.

## [0.5.3] - 2026-10-26

Zgodność ze spec: `8e46253` · zadanie: task_14 · gałąź: `spec/2026-10-26-task14`

W tej wersji razem: trzy poprawki, numer wersji w menu głównym, raport przebiegu i bot balansu. Plan końcowy przewidywał raport i bota dopiero na 0.5.4 (etap 4), ale wchodzą już teraz, żeby sesja gry PT0 (etap 3) dała pierwsze liczby. Wpis w dzienniku decyzji `09_produkcja.md` z 2026-10-26 to rekomendacja agenta według zasady planu (§3 pkt 3), obowiązująca do weta Rolanda. Bot balansu jest narzędziem programisty (`tools/balance_sim.gd`), więc w samej grze go nie ma.

### Naprawione
- Kto jeszcze nie dotarł, nie traci poczytalności (NPC-18). Sabina nie traci już 2 punktów co noc od pierwszej nocy, tylko od nocy po wprowadzeniu się do obozu. Ottokar, Hieronim i Welf nie dostają wstrząsu w piątą noc, dopóki nie spotkasz wyprawy z Exitium. Po spotkaniu wstrząs dotyka ich tak samo jak pozostałych (−2). Piątka z szychty w dniu 1 i Dobrawa są w rozliczeniu jak dotąd.
- Wstęp mówi, że stół z mapą stoi w zagrodzie Racibora, za niską palisadą bez dachu (było: „w kwaterze zarządcy, za drewnianą ścianką”, jak w hali sprzed 0.5). To samo poprawiono w `CZYTAJ_MNIE.txt`.
- Z kodu zniknął martwy warunek odejścia Hieronima (`hieronim_gone`; żadna część gry nigdy nie ustawiała tej flagi). W rozgrywce bez zmian: Hieronim nie ma odejścia przy 0% poczytalności.

### Dodane
- Numer wersji i skrót commita specyfikacji w prawym dolnym rogu menu głównego, np. „0.5.3 · spec 8e46253” (UI-6, TECH-1). W pauzie go nie ma. Skrót wpisuje do `script/build_info.gd` skrypt `tools/release/stamp_build.js` tuż przed eksportem.
- Raport przebiegu (ZAP-11, UI-7): na końcu tygodnia (oba zakończenia) i po naciśnięciu SAVE REPORT w pauzie gra zapisuje lokalnie dwa pliki, `przebieg-<data>_<godzina>.md` (do czytania) i `.json` (do liczenia), w folderze `raporty` w danych użytkownika (`%APPDATA%\Godot\app_userdata\Everhorror\raporty`). Zawartość: czas według kategorii dla każdego dnia (CZAS-16) i niewykorzystany czas przed snem, żyły o świcie, stan bohatera i poznanych postaci o świcie, kiedy zaznaczono każdą żyłę i kiedy osiągnięto normę, kluczowe wybory, zakończenie. Po śmierci raport nie powstaje sam. Nic nie jest wysyłane przez sieć.
- `CHANGELOG.md` (ten plik) w archiwum ZIP obok `CZYTAJ_MNIE.txt` (TECH-2).
- Poza grą: bot balansu (`tools/balance_sim.gd`, test `balance`, TECH-3) „gra” tydzień bez świata gry na prawdziwych kosztach z gry i podaje, kiedy osiągnięto normę; skrypty wydania `tools/release/stamp_build.js` i `tools/release/make_zip.sh`; piąta warstwa testów w `tools/run_tests.sh`.

### Zmienione
- Zapis gry ma wersję 6 (ZAP-12): dziennik świtów i dziennik zaznaczonych żył dla raportu. Zapisy z wcześniejszych wersji, także z 0.5.x, nadal się wczytują, z pustymi dziennikami; raport oznacza wtedy dni sprzed wczytania jako „brak danych”.
- Cztery warstwy testów stały się pięcioma (dodano `balance`).

## [0.5.2] - 2026-09-26

Zgodność ze spec: `1494bf4` · zadanie: task_13

### Zmienione
- Sen z odszyfrowanym listem dziadka przychodzi pierwszej nocy po odszyfrowaniu, obojętnie której, a sen ostatniej nocy ma końcówkę dla tych, którzy liczyli kreski („Czternaście kresek”).
- Staw w Zalanym chodniku jest pod wodą, dopóki nie ruszą pompy, więc łowić da się dopiero potem. Jest za to inny sposób na rybę dla Hrapka: bandaż dla Wszebora, który rano przynosi rybę z rząpia.

### Naprawione
- „Muszę iść.” u Ottokara nie zabiera już 5 minut.

## [0.5.1] - 2026-09-26

Zgodność ze spec: `df2b9fd` · zadania: task_10, task_11, task_12

### Zmienione
- Pierwszy dzień: w obozie są tylko zarządca, kwatermistrzyni i dwaj górnicy. Reszta ekipy jest na szychcie w Starej sztolni, w rząpiu albo za zachodnim zawałem (za każdym razem gdzie indziej) i wita się „po szychtowemu”. Od drugiego dnia wszyscy są w obozie. Zacznij nową grę.
- Zmęczenie bohatera: długie chodzenie po tunelach męczy, sen i wieczór przy ognisku odpoczywają. Kto padnie z nóg, idzie w głąb dwa razy dłużej.
- Powrót do obozu trwa połowę drogi, którą przeszedłeś od wyjścia.
- Ta sama odpowiedź w rozmowie z tą samą osobą kosztuje czas tylko raz.
- Zapis gry w wersji 5.

## [0.5] - 2026-09-26

Zgodność ze spec: `bccb0d9` · zadania: task_08, task_09

### Dodane
- Hrapek i zadanie „Ryba dla Hrapka”.
- Dziennik czasu w notesie (zakładka „Czas”); zegara nie ma już w rogu ekranu.
- Wyszarzone odpowiedzi w rozmowach z powodem (opcja „Show locked choices”).

### Zmienione
- Obóz to naturalna jaskinia, nie hala z desek. Zacznij nową grę.
- Rozmowa kosztuje 5 minut za każdą wybraną odpowiedź zamiast pół godziny; pożegnanie i samo oddanie przedmiotu nic nie kosztują.
- Mapa: nazwy miejsc nie nachodzą na siebie, plansza przybycia mówi, przez które miejsca prowadziła droga.

## [0.4.1] - 2026-09-25

Zgodność ze spec: — (specyfikacja powstała później)

### Naprawione
- Komunikat o upływie czasu nie ma podwójnego „h”.
- Gdy Nasira wywiozą bez lekarstwa, zadanie „Gorączka Nasira” kończy się jako nieudane, z wpisem w notesie.

## [0.4] - 2026-09-25

Zgodność ze spec: — (specyfikacja powstała później) · zadanie: task_06

### Dodane
- Wieczory przy ognisku, zagadka „Czternaście kresek”, ślady nocnego wstrząsu w chodnikach, autozapis każdego świtu (slot AUTO), opcje jasności i osobnej głośności tła i efektów, winieta, gdy bohaterowi pęka głowa.

### Zmienione
- Rozmowy kosztują pół godziny zamiast godziny i tylko wtedy, gdy naprawdę rozmawiasz. Usunięto skok.

## [0.3] - 2026-09-25

Zgodność ze spec: — (specyfikacja powstała później) · zadanie: task_05

### Dodane
- Tydzień zamiast trzech dni: norma 12 żył do wieczora siódmego dnia i rozliczenie rano w dniu 8.
- Stół z mapą, wyprawy dalej w głąb pod klawiszem M, podsumowanie wyprawy, 10 nowych miejsc i 25 żył.
- Dziewięć nowych postaci: pięć osób w obozie i wyprawa Drugich z Exitium.
- Ekwipunek (I), zdrowie, rany, gorączka i poczytalność bohatera, zakładka „Ludzie” w notesie.

## [0.2] - 2026-09-25

Zgodność ze spec: — (specyfikacja powstała później) · zadanie: task_04

### Dodane
- Demo trwa trzy dni. Obóz ma strefy, są trzy nowe postacie (Racibor, Tekla, Dobrawa) i trzy nowe miejsca (rząpie, upadowa, kaplica) oraz ściana z zagadką.

## [0.1] - 2026-09-25

Zgodność ze spec: — (specyfikacja powstała później) · zadanie: task_03

### Dodane
- Pierwszy grywalny kawałek od początku do końca (około 20 minut): wstęp, obóz z dwiema postaciami, rozmowy z portretami 3D, wyprawa na wschód i na zachód, noc z odszyfrowaną wiadomością dziadka, plansza końca.
