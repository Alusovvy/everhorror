# Factcheck test 03: vertical slice (dzień 1 → noc → dzień 2)

> Zadanie: [task_03](../ai-tasks/task_03.md) · Przygotowano: 2026-09-25
> Uruchom: VS Code **F5** („Godot: main scene”) albo gotowy build `build/Everhorror-demo-0.1-windows.zip` → START.
> Wpisz w kolumnie **Wynik**: ✅ OK / ❌ błąd / 💬 propozycja zmiany i dopisz uwagi.

## Co zostało dodane
- Obóz w drewnianej hali: posłanie, ognisko, stół z mapą, dwie postacie (Mirosław z Głuszy, Stary Bolko) z animacjami.
- Czas: dzień 06:00–22:00. Rozmowa kosztuje 1 h, wyprawa 2 h, powrót 2 h, wysadzenie zawału 4 h. Zegar w lewym górnym rogu.
- Rozmowy w trybie VN: portret 3D postaci, odpowiedzi zależne od reputacji, stanu i wcześniejszych wyborów.
- Stół z mapą → wyprawa na wschód (Stara sztolnia + jaskinia) albo na zachód (po wysadzeniu zawału).
- Notes pod **[J]**: zadania i znalezione zapiski.
- Noc: sen, rozliczenie poczytalności, odszyfrowanie wiadomości dziadka, „Dzień 2” ze zmianami w obozie, plansza końca demo.
- Poprawki z testu 01: podłoga i ściany jaskini.
- Build dla znajomych (Windows, 97 MB).
- Gwara śląska w dialogach górników, z przełącznikiem w opcjach.

## Scenariusz „pełne przejście” (ok. 20 min)
Porozmawiaj z Mirosławem (zapytaj o zawał) → mapa: Stara sztolnia → w jaskini skrzynka z lontami i kartka z szyfrem → drogowskaz: powrót → oddaj lonty Mirosławowi i poproś o wysadzenie → „Jak się trzymasz?” → Bolko: zapytaj o dziadka (z szacunkiem), pokaż kartkę → mapa: zachód → deska z kluczem → powrót → posłanie → dzień 2 → stół z mapą.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Wstęp | START | Plansza „Dzień 1”, potem krótka narracja. Po niej podpowiedź sterowania | | |
| 2 | Obóz | Rozejrzyj się | Ognisko się pali, Mirosław siedzi na pniu, Bolko stoi przy stole. Nic nie lewituje, nic się nie przenika | | |
| 3 | Podpowiedź z kosztem | Najedź na Mirosława | „[E] Porozmawiaj z Mirosławem · 1 h” | | |
| 4 | Rozmowa (VN) | [E] na Mirosława | Rozmyte tło, portret, imię, tekst się wpisuje. Spacja/klik: dalej. Odpowiedzi po prawej | | |
| 5 | Czas | Po rozmowie | Zegar +1 h, komunikat „−1 h · Rozmowa z Mirosławem” | | |
| 6 | Jakość dialogów | Przeczytaj wszystkie rozmowy | Brzmi naturalnie, po polsku, każda postać ma swój charakter | | |
| 7 | Mapa | [E] na stole | Mapa dziadka, wschód dostępny, zachód zablokowany z wyjaśnieniem | | |
| 8 | Wyprawa na wschód | Wybierz Stara sztolnia | Wyciemnienie, plansza, +2 h, jesteś za deskami w korytarzu | | |
| 9 | Lonty | Skrzynka w jaskini (przy latarni) | Opis zostaje kilka sekund, skrzynka znika, komunikat „Zdobyto: Suche lonty” | | |
| 10 | Kartka z szyfrem | Kartka na ziemi w jaskini | Opis + „Nowa notatka w notesie” | | |
| 11 | Notes | [J] | Zakładki Zadania / Notatki. Wpisy mają sens, notatki się czytają | | |
| 12 | Powrót | Drogowskaz przy deskach | „Wróć do obozu · 2 h”, lądujesz przy stole z mapą | | |
| 13 | Wysadzenie | Oddaj lonty, poproś o wysadzenie | Huk, plansza, +4 h, komunikat, że zachodni chodnik otwarty | | |
| 14 | Pocieszenie | Znowu porozmawiaj z Mirosławem | Nowa opcja „Jak się trzymasz?” | | |
| 15 | Bolko: zaufanie | Zapytaj o dziadka i odpowiedz z szacunkiem, potem pokaż kartkę | Bolko daje wskazówkę o kluczu. Przy braku szacunku odmawia | | |
| 16 | Zachód | Mapa → Zawalony chodnik | Gruz po wybuchu na pochylni, deska z kluczem (niebieska poświata), dalej połamane stemple | | |
| 17 | Koniec dnia | Doprowadź do 22:00 | Komunikat „Robi się późno”. Rozmowy i wyprawy zablokowane | | |
| 18 | Sen | [E] na posłaniu → „Tak, idę spać” | Sen (tekst na czarnym), plansza „Dzień 2” | | |
| 19 | Dzień 2 | Rozejrzyj się, porozmawiaj z obojgiem | Zmiany zależne od wyborów (Mirosław w kącie albo przy ognisku, Bolko przy posłaniu / odwrócony / przy stole) | | |
| 20 | Szyfr | [J] rano | Jeśli masz kartkę i klucz: „Odszyfrowana wiadomość dziadka” | | |
| 21 | Koniec demo | Stół z mapą w dniu 2 | Plansza z podsumowaniem Twoich wyborów, MAIN MENU / EXIT działają | | |
| 22 | Zapis/odczyt | Zapisz w środku dnia (Esc), wczytaj | Godzina, notes, stan zawału i zabrane przedmioty wracają | | |
| 23 | Inna ścieżka | Nowa gra: nic nie rób, idź od razu spać | Dzień 2 wygląda inaczej, demo działa bez błędów | | |
| 24 | Build | Rozpakuj ZIP na innym komputerze (albo u znajomego) | Gra się uruchamia, plik CZYTAJ_MNIE.txt jest zrozumiały | | |
| 25 | Gwara śląska | Porozmawiaj z Mirosławem i Bolkiem (gwara jest domyślnie włączona) | Obaj mówią z elementami gwary (Bolko mocniej). Da się ich zrozumieć bez słownika. Narracja i Twoje odpowiedzi są w zwykłej polszczyźnie | | |
| 26 | Przełącznik gwary | Esc → OPTIONS → wyłącz „Silesian dialect (miners)”, porozmawiaj jeszcze raz | Wracają oryginalne dialogi. Po ponownym uruchomieniu gry ustawienie jest zapamiętane | | |

## Twoje uwagi / propozycje

-
