# Factcheck test 09: Hrapek, ryba, zegar w notesie, wyszarzone opcje, 5 minut za opcję

> **2026-10-26:** zastąpione arkuszem PT0 [factcheck-test-14.md](../factcheck-test-14.md) (decyzja planu końcowego, etap 3). Kolumny człowieka zostają puste.

> Zadanie: [task_09](../../ai-tasks/done/task_09.md) · Decyzje: [decision-task-09](decision-task-09.md) · Przygotowano: 2026-09-26 · Czas: ~40 min
> Graj z edytora (F5) albo z builda (build tylko na Twoją prośbę). Najszybciej: nowa gra, dzień 1 lonty i wybuch u Mirosława, potem kilka powrotów z tuneli w dniach 3–6.

## Co się zmieniło
- **Hrapek** (karta Rolanda, kwestie wierszem [ROBOCZE]):
  - spotkania tylko przy powrocie do obozu, od dnia 3, po wysadzeniu zawału; potem 25%, drugie spotkanie na pewno w dniu 5,
  - rozmowy z nim nie kosztują czasu, po trzecim pytaniu z rzędu ucieka,
  - ginie w nocy z dnia 5 na 6; w dniu 6 przy powrocie leży jego ciało i pierścień.
- **„Ryba dla Hrapka”:** rybę daje Tekla (jeśli oddałeś jej tobołek) albo łowisz ją 4 h ze Wszeborem lub Mirosławem. Za rybę Hrapek mówi o NIM i o dziadku.
- **Zegar:** zniknął z rogu ekranu. Godzina jest w notesie (nowa zakładka „Czas” z dziennikiem dni) i w oknie rozmowy.
- **Rozmowy:** 5 minut za każdą wybraną opcję. Za darmo: pożegnanie, samo oddanie przedmiotu i opcje, które mają własny koszt (np. „Wysadź zawał · 4 h” kosztuje równo 4 h).
- **Wyszarzone opcje:** opcja, do której brakuje tylko zaufania albo przedmiotu, jest widoczna, szara, z powodem w nawiasie. Przełącznik w OPTIONS: „Show locked choices”.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Brak zegara na ekranie | Nowa gra, rozejrzyj się | W rogu nie ma „Dzień N · GG:MM”. Jeśli jesteś ranny, w rogu jest tylko „ranny” | | |
| 2 | Zakładka „Czas” | [J] → zakładka „Czas” po kilku akcjach | Duży zegar, „Do nocy zostało: …”, lista dnia: „06:00 · Rozmowa z Mirosławem · 10 min” itd., suma dnia. Po nocy linijka „Sen” | | |
| 3 | 5 minut za opcję | Porozmawiaj z kimś: jedna opcja i „Muszę iść” | Zegar w oknie rozmowy przesuwa się o 5 min przy opcji. Po wyjściu jeden dymek „−5 min · Rozmowa z …” | | |
| 4 | Pożegnanie za darmo | Zagadaj i od razu „Muszę iść” | Czas stoi, żadnego dymka | | |
| 5 | Oddanie przedmiotu za darmo | Oddaj Mirosławowi lonty („Mam dla ciebie lonty”) | Oddanie nic nie kosztuje | | |
| 6 | Akcja z własnym kosztem | „Wysadź zawał na zachodzie. (4 h)” | Dokładnie 4 h, bez dodatkowych 5 min | | |
| 7 | Wyszarzona opcja: zaufanie | Dzień 2+, Bolko, zanim cię polubi | „Była tu kiedyś jakaś kaplica? (Bolko jeszcze ci nie ufa)”, szara, nie da się wybrać | | |
| 8 | Wyszarzona opcja: przedmiot | Weź zadanie „Pompy Nasira” bez oleju, porozmawiaj z Nasirem | „Mam olej do tłoków. (potrzebne: olej do lampy)”, szara | | |
| 9 | Brak spoilerów | Dzień 1: Tekla, Racibor, Dobrawa | Nie ma szarych „Mam twój tobołek”, „Tekla ukrywa coś…”, „Znalazłem w kaplicy kryształ” | | |
| 10 | Przełącznik | OPTIONS → „Show locked choices” wyłącz, wróć do Bolka | Szara opcja znika | | |
| 11 | Pierwsze spotkanie z Hrapkiem | Dzień 3 (zawał wysadzony), wyprawa i [M] → Obóz | Szuranie, scena z Hrapkiem przed drogą. Mówi wierszem, nazywa cię Cesarzem, prosi o rybę (zadanie w notesie) | | |
| 12 | Ucieczka | Zadaj mu trzy pytania z rzędu | Na trzecie: „Czemu pyta? CO TYLE PYTA?…” i znika | | |
| 13 | Rozmowa z Hrapkiem nie kosztuje | Porównaj godzinę przed i po scenie | Bez zmian (powrót kosztuje tylko drogę) | | |
| 14 | Ryba od Tekli | Po oddanym jej tobołku: „Masz może jakąś rybę?” | Suszona ryba, wpis w notesie. Bez tobołka: odmowa | | |
| 15 | Ryba z łowienia | Wszebor albo Mirosław: „Chodź ze mną na ryby do stawu. (4 h)” | 4 h, ryba, wpis. Wieczorem po 18:00: „jutro” | | |
| 16 | Ryba dla Hrapka | Przy kolejnym spotkaniu: „Mam dla ciebie rybę.” | Zjada ją, mówi o NIM (bez rymów) i że cię zna, „tylko byłeś starszy”. Wpis w notesie, zadanie zakończone | | |
| 17 | Dwa spotkania do dnia 5 | Wracaj z tuneli w dniach 3–5 | Najpóźniej przy pierwszym powrocie w dniu 5 drugie spotkanie | | |
| 18 | Śmierć i pierścień | Dzień 6, powrót z tunelu | Ciało Hrapka w chodniku. „Zabierz pierścień” daje pierścień w plecaku. Jeśli nie dałeś ryby: wpis „Nie zdążyłem z rybą” | | |
| 19 | Notes → Ludzie | Po spotkaniu: [J] → Ludzie → Hrapek | „Głowa: Wciąż ten sam. Żyje we własnym pałacu…”. Po znalezieniu ciała: „Nie żyje.” | | |
| 20 | Podsumowanie tygodnia | Dograj do końca | Linijka „Hrapek: …” (ryba, śmierć, pierścień) | | |
| 21 | Wygląd Hrapka | Portret w scenie | Blady, łysy, bez koszuli, w podartych portkach. Ciało jest muskularne, bo to baza Quaternius; jeśli razi, zgłoś | | |
| 22 | Stare zapisy | Wczytaj zapis sprzed tej wersji | Wczytuje się. Zakładka „Czas” pusta dla wcześniejszych dni | | |

## Twoje uwagi / propozycje

-
