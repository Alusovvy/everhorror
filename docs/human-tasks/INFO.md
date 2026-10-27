# Arkusze dla człowieka

Arkusze, które wypełnia **człowiek**: factchecki (`factcheck-test-NN.md`), sesje gry (PT), odbiory. Agent tworzy je w głównej kopii gry z `factcheck_template.md` albo `playtest_template.md`, albo dopisuje część do otwartego, jeszcze niewypełnionego arkusza (zob. „Arkusz kilku zadań”), nigdy na gałęzi `spec/*`. Arkusz zadania z otwartą gałęzią przyjmuje wpisy w dashboardzie dopiero przy aktualnym buildzie do ogrania tej gałęzi (D-32, `build/do-ogrania/`); pisze go agent jak dotąd. Decyzje to karty w specyfikacji (`zgloszenia/`); stare `decision-*.md` w `done/` to historia.

## Strefy człowieka
To **jedyna definicja** stref człowieka. `CLAUDE.md`, skille, agenci i szablony tylko tu linkują. W strefach pisze wyłącznie człowiek; hook i audyt przebiegu pilnują agenta. Parser to `dashboard/src/work/sheets.ts` w specyfikacji; ta lista ma go odzwierciedlać.
- **Kolumny tabel** (wielkość liter bez znaczenia): `wynik`, `wynik człowieka`, `wynik (1–7)`, `ocena`, `uwagi`, `uwagi człowieka`, `twój wybór`, `wybór`, `decyzja rolanda` oraz każda kolumna z końcówką `(człowiek)`. Przy tabeli z kolumną `skala` kolumna `wynik` to ocena 1–7.
- **Cała tabela** pod nagłówkiem z „wypełnia człowiek” albo pod linią `<!-- człowiek -->`. Tak samo tabela raportu przebiegu (kolumny „Plik .md” i „Plik .json”): pod `<!-- człowiek -->` albo z kolumnami „Plik .md (człowiek)” i „Plik .json (człowiek)”; nie liczy się do „kompletny”, a plik dołącza przycisk „Dołącz raport przebiegu” w dashboardzie (kopiuje parę z folderu raportów gry do `docs/human-tasks/raporty/` i wpisuje linki).
- **Sekcje odpowiedzi** (bez tabeli): nagłówek z „wypełnia człowiek”, nagłówek kończący się na „(człowiek)” albo jeden ze starych nagłówków: „Twoje uwagi / propozycje”, „Uwagi ogólne”, „Uwagi człowieka”, „Gdzie było nudno albo trudno się połapać?”, „Inne uwagi i błędy”. Strefą jest też treść między `<!-- odpowiedź człowieka -->` i `<!-- /odpowiedź człowieka -->`.
- **Linie nagłówka** `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`.
- **Poza strefą:** kolumny `oczekiwany wynik` i `wynik automatu` oraz tabele pod nagłówkiem z „automat” lub „(agent)”.

## Nazwy arkuszy
- `factcheck-test-NN.md`: sprawdzenie zadania `task_NN` (z `factcheck_template.md`).
- Sesja gry (PT0, PT1, …): z `playtest_template.md`. Plik też nazywa się `factcheck-test-NN.md`, gdzie NN to zadanie, którego build oceniamy, a numer sesji stoi w tytule. PT0 to [factcheck-test-14.md](done/factcheck-test-14.md) (build 0.5.3, zamknięty).

## Arkusz kilku zadań
Gdy otwarty arkusz nie jest jeszcze wypełniany (żadnego wyniku człowieka, żadnej linii `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`), kolejne zadania dopisują do niego część zamiast zakładać nowy arkusz: nagłówek `> Zadania: [task_16](…), [task_17](…)` (dawna linia `> Zadanie:` czyta się jak dotąd) i na KOŃCU pliku `## Część: task_NN — <tytuł>` z własnymi podsekcjami („Co zostało dodane”, „Test”, „Wyniki automatu (agent)”) i pustymi komórkami człowieka. Nigdy nie wstawia się części w środek pliku ani nie rusza istniejących wierszy. Część sięga do następnego nagłówka poziomu 1–2. Dashboard przypisuje arkusz każdemu z wymienionych zadań, pokazuje postęp każdej części, a zadania zamykają się razem z arkuszem. Arkusz, który człowiek zaczął wypełniać, się nie rozrasta.

## Minimum ważności sesji gry
Sesja gry liczy się do celów K z planu tylko wtedy, gdy ma wypełnione „Dotarcie do” i dołączony raport przebiegu (.md albo .json). Sesja bez nich daje tylko wskazówkę kierunku, nie pomiar, i tak ją opisujemy.
- Wiersze dni powyżej „Dotarcie do” zostają puste. Przy zamknięciu arkusza dashboard wpisze w nich ⏭ (decyzja D-28), więc nikt nie ocenia dni, których nie zagrał.
- W „Dane sesji” napis z menu głównego kopiujemy w całości (wersja i skrót specyfikacji), a nie tylko numer wersji. Build do ogrania pokazuje w menu numer ostatniego wydania, więc przy nim dopisz też nazwę ZIP-a (numer zadania i skrót commita).
- Łączny czas gry podajemy w rzeczywistych godzinach; wartość „<1h” przy wielu ocenionych dniach nie jest wiarygodna.
- Zamknięte arkusze leżą w [done/](done/), razem ze starszą historią: `decision-*.md`, `factcheck-foundation-2026-10-26.md` i zastąpionym `factcheck-test-15.md`. Tych plików nie edytujemy.

## Znaczniki wyniku
Komórka zaczyna się od ✅ ok, ❌ błąd, 💬 propozycja albo ⏭ pominięte, potem krótki opis. Skala to liczba 1–7. Wpis z „wpis agenta” nie jest dowodem człowieka. Znacznik `⏭ pominięte (zamknięcie bez wypełnienia)` wpisuje w puste pola sam dashboard przy zamknięciu arkusza z pominięciem; nie jest dowodem sprawdzenia.

## Kto co pisze
- Człowiek: strefy człowieka. W dashboardzie każdy zapis to osobny commit tego pliku, z podpisem osoby, która wpisuje (autor, committer, `Wpisał-Człowiek`).
- Agent: opis, kroki, oczekiwane wyniki i `## Wyniki automatu (agent)`; nigdy wyniku ani „sprawdzone”.

## Zwolnij, zastąp, zamknij
- `Zwolnienie: <Imię> (dashboard, <data>): <powód>` to świadome pominięcie testu przez Rolanda.
- Nagłówek „zastąpione …” oznacza arkusz zastąpiony innym, „niesprawdzone przez człowieka” dawny arkusz bez wpisu człowieka. Takie noty zamykają zadanie bez sprawdzenia, więc dopisuje je człowiek (albo sesja w terminalu na jego polecenie). Agent w przebiegu z dashboardu ich nie dopisuje ani nie zmienia, nie zmienia nazw kolumn „wynik” i „uwagi” (np. na „Wynik automatu”), nie dopisuje „(agent)” do nagłówka tabeli człowieka i nie usuwa pustych wierszy: strażnik widzi to jako zwykły tekst, ale audyt zgłasza taką zmianę stanu arkusza jako naruszenie (`SHEET_STATE`).
- Zamknięcie: arkusz kompletny albo zwolniony przenosi się do `done/` bez zmian (`git mv`, linki dostają `../`). Arkusz jeszcze niewypełniony Roland może zamknąć w dashboardzie „z pominięciem”: w tym samym commicie każde puste pole do wypełnienia (wyniki, skale, pytania otwarte) dostaje `⏭ pominięte (zamknięcie bez wypełnienia)`, kolumna uwag zostaje pusta, a nagłówek dostaje `Zamknięcie: <Imię> (dashboard, <data>): pominięte N z M pól`. To wpis człowieka (agent go nie robi), a zadania z takiego arkusza zamykają się jako „zamknięte bez pełnego sprawdzenia”. Zwolnienie mówi „tego testu nie trzeba”, pominięcie „tego nie sprawdzono”. Pusta tabela raportu przebiegu wymaga w dashboardzie potwierdzenia „Zamykam bez raportu”. Do czasu zamknięcia arkusz leży tutaj.
