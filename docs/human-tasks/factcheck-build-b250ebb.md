# Build b250ebb: arkusz do ogrania

> Zadania: [task_37](../ai-tasks/done/task_37.md) · Przygotowano: 2026-10-28 · Gałąź: `spec/2026-10-28-task37`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis. Każda część poniżej to jedno zadanie z tego buildu; arkusz jest zamknięty, gdy zamknięte są wszystkie części.
> Zwolnienie: Roland (dashboard, 2026-10-28): Roland, czat 2026-10-28: ocena buildu test-master-0c0df0f podana w czacie, poprawki w task_39 (arkusz zwolniony, bez wpisów)

## Raport przebiegu: dołącz plik
Po zakończeniu otwarcia (ekran „Koniec otwarcia”) kliknij w dashboardzie „Dołącz raport przebiegu”: para plików z folderu raportów gry trafia obok arkusza (`raporty/`), a linki do niej do tabeli. Jeśli raport nie powstał, zapisz to w uwagach.

<!-- człowiek -->
| Plik `.md` (człowiek) | Plik `.json` (człowiek) | Uwagi (człowiek) |
|---|---|---|
| | | |

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->

## Część: task_37 — Otwarcie na trzy dni

### Co zostało dodane
- START w menu zaczyna trzydniowe otwarcie (OTW-1). Pod spodem jest nowy przycisk FULL WEEK (OLD DEMO): stary tydzień bez zmian, np. do sesji PT0b. Zapisy sprzed tej zmiany wczytują się jako tydzień.
- W obozie są tylko Racibor, Bolko, Mirosław i Tekla. Nikogo innego nie ma ani w obozie, ani w chodnikach (OTW-2). Na mapie są tylko Stara sztolnia, Zawalony chodnik (po wybuchu) i Upadowa (z liną) (OTW-3).
- Nowy wstęp z pierwszym małym zadaniem: dwie żyły za odpis z archiwum (OTW-4). Inna plansza poranka w dniu 2, bez Dobrawy (OTW-5).
- Szyfr nie odczytuje się sam w nocy. Gdy masz kartkę i deskę z zawału, siadasz nad nimi z Bolkiem („Usiądźmy nad kartką dziadka. (1 h)”) albo sam przy posłaniu. Scena ma trzy kroki: jak czytać deskę, brakujące słowo i dokąd zszedł dziadek. Bolko przy tym przyznaje się do krzywego stempla. Po obejrzeniu zawału w upadowej możesz mu powiedzieć, że to nie był jego stempel (OTW-6).
- Po wybuchu „Jak się trzymasz?” daje trzy podejścia po 1 h: pytanie o robotę, cisza albo nazwanie tego, ile go to kosztowało. Rano następnego dnia Mirosław odpowiada inaczej po każdym z nich. Ta zmiana działa też w pełnym tygodniu (OTW-7).
- Od 18:00 do 20:00 u Tekli przy kuchni: „Siądę do kolacji.”. Bez nagrody. Tekla i inni krótko komentują, co się stało. Ognisko w otwarciu ma tylko tę czwórkę (OTW-8).
- W dniu 3 od 18:00 w obozie (albo wcześniej przy posłaniu) przychodzi Exitium po mapy dziadka. Wybierasz: pokazać, zapytać po co, albo odmówić. Potem jest klif i ekran „Koniec otwarcia” z raportem przebiegu (OTW-9, OTW-10).

### Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Menu i obsada | START, rozejrzyj się po obozie w dniu 1 | nowy wstęp z odpisem za dwie żyły; w obozie tylko Racibor, Bolko, Mirosław, Tekla; w menu jest też FULL WEEK (OLD DEMO) | | |
| 2 | Mapa otwarcia | stół z mapą w zagrodzie Racibora, potem w Starej sztolni [M] | widać tylko Starą sztolnię i zasypany zachodni chodnik; w chodnikach nikogo na szychcie | | |
| 3 | Dzień 1 | weź zlecenie Racibora i pytanie o zachodni chodnik od Mirosława, idź do Starej sztolni (żyły, lonty, szyfr), wróć | jedna wyprawa załatwia żyły, lonty i kartkę; Bolko rozpoznaje kartkę | | |
| 4 | Kolacja | po 18:00 przy kuchni, rozmowa z Teklą, „Siądę do kolacji.” | krótka scena, reakcje na to, co się dziś stało; nic nie rośnie ani nie spada | | |
| 5 | Noc bez odszyfrowania | idź spać z kartką (i deską, jeśli już masz) | rano wiadomość nadal nieodczytana; plansza dnia 2 to „Kocioł Tekli dymi od świtu…” | | |
| 6 | Wybuch i Mirosław | oddaj lonty, wysadź zawał, potem „Jak się trzymasz?” i jedno z trzech podejść | godzina z Mirosławem; następnego dnia pierwsze zdanie Mirosława nawiązuje do wybranego podejścia | | |
| 7 | Papiery z Bolkiem | z kartką i deską: „Usiądźmy nad kartką dziadka.”; spróbuj też złej odpowiedzi | trzy kroki; zła odpowiedź nic nie psuje; na końcu Bolko mówi o krzywym stemplu; w notesie wpis o upadowej | | |
| 8 | Papiery samemu | (osobna gra albo przy niskim zaufaniu Bolka) posłanie → „Usiądź sam nad kartką dziadka.” | te same trzy kroki bez Bolka; potem znowu pytanie o sen | | |
| 9 | Upadowa i Bolko | z liną do Upadowej, obejrzyj zawał; w obozie Mirosław („Byłem na dnie upadowej.”) i Bolko („To nie był twój stempel.”) | Mirosław mówi o ładunku; Bolko odpowiada inaczej niż dotąd | | |
| 10 | Koniec otwarcia | dzień 3: bądź w obozie po 18:00 albo połóż się wcześniej | przychodzi Exitium; trzy możliwości z natychmiastową reakcją; stukanie zza zawału; ekran „Koniec otwarcia” bez nocy | | |
| 11 | Stary tydzień | FULL WEEK (OLD DEMO), krótko dzień 1 | piątka na szychcie w chodnikach, jak dotąd | | |
| 12 | Hak (po pierwszym wieczorze) | odpowiedz w uwagach: kogo pamiętasz i czego chce? co chcesz jutro sprawdzić? z kim chętnie spędziłbyś więcej czasu? | — | | |
| 13 | Hak (po końcu) | odpowiedz w uwagach: co twoje działania dla kogoś zmieniły? dlaczego prośba Ottokara ma znaczenie? co chcesz odkryć dalej? | — | | |

### Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| unit | `tools/run_tests.sh unit` | ALL PASSED (z nowymi sprawdzeniami task_37) | `reports/tests/unit.log` |
| lint | `tools/run_tests.sh lint` | ALL PASSED, 20 ostrzeżeń (te same co przed zmianą) | `reports/tests/lint.log` |
| dialogue | `tools/run_tests.sh dialogue` | ALL PASSED (z `_task37`) | `reports/tests/dialogue.log` |
| opening (nowy) | `tools/run_tests.sh opening` | ALL PASSED | `reports/tests/opening.log` |
| day1 | `tools/run_tests.sh day1` | ALL PASSED | `reports/tests/day1.log` |
| balance, schedule, first_meet, night1, drudzy, day3, save_load | `tools/run_tests.sh -j 3 …` | ALL PASSED; bot balansu jak przed zmianą (norma: dzień 4, 13:00 … dzień 5, 15:30) | `reports/tests/<scenariusz>.log` |
