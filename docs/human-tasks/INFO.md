# Arkusze dla człowieka

Arkusze, które wypełnia **człowiek**: factchecki (`factcheck-build-<sha7>.md`, starsze `factcheck-test-NN.md`), sesje gry (PT), odbiory. Od D-36 arkusz jest **jeden na build**, a tylko zadania na poziomie `rozgrywka` w ogóle go mają (zob. „Poziomy zadań i arkusz na build”). Agent tworzy arkusz w głównej kopii gry z `factcheck_build_template.md` (sesję gry z `playtest_template.md`) albo dopisuje część do otwartego, jeszcze niewypełnionego arkusza, nigdy na gałęzi `spec/*`. Arkusz przyjmuje wpisy w dashboardzie dopiero przy aktualnym buildzie do ogrania tej gałęzi (D-32, `build/do-ogrania/`). Decyzje to karty w specyfikacji (`zgloszenia/`); stare `decision-*.md` w `done/` to historia.

## Poziomy zadań i arkusz na build
Plik zadania (`docs/ai-tasks/task_NN.md`) ma linię `Poziom: tekst`, `Poziom: narzędzia` albo `Poziom: rozgrywka` (D-36; brak linii znaczy `rozgrywka`). Nadaje go `/spec-tasks`, a Roland może go zmienić. Poziom mówi, czego wymaga scalenie:

| Poziom | Co to jest | Arkusz | Scalenie |
|---|---|---|---|
| `tekst` | tylko teksty, dialogi, dokumenty | brak | przegląd kodu, testy serwera i build do ogrania |
| `narzędzia` | `tools/`, generatory, skille, dashboard, bez zmian w rozgrywce | brak | przegląd kodu i testy serwera (build nie jest potrzebny) |
| `rozgrywka` | wszystko, co zmienia to, co gracz przeżywa | **tak, jeden na build** | arkusz wypełniony przez człowieka bez ❌, zagrany w aktualnym buildzie, przegląd i testy serwera |

- **Zadanie `tekst` albo `narzędzia`** nie ma arkusza: przebieg wdrożenia nie tworzy w `docs/human-tasks/` niczego, a w wierszu „Na gałęziach” zapisuje `--sheet —`. Dowodem są testy serwera i przegląd; scalenie może być automatyczne (D-35). To nie łamie zasady „agent nie wpisuje wyników za człowieka”: takie zadanie nie ma pól człowieka. Jeśli człowiek mimo to założy i zacznie wypełniać arkusz takiego zadania, liczy się on jak każdy inny, a ❌ w nim wstrzymuje scalenie.
- **Arkusz na build** `docs/human-tasks/factcheck-build-<sha7>.md` zbiera **części wszystkich zadań `rozgrywka` z tego buildu** (rosnący arkusz z D-27). `<sha7>` to pierwsze 7 znaków commita głowy gałęzi po commitach wdrożenia (`git -C <kopia gałęzi> rev-parse --short=7 HEAD`); późniejsze poprawki nie zmieniają nazwy pliku. Człowiek gra raz i wypełnia wszystkie części.
- **Co robi przebieg wdrożenia zadania `rozgrywka`.** Jeśli w `docs/human-tasks/` leży otwarty arkusz, którego człowiek jeszcze nie zaczął wypełniać (zob. „Arkusz kilku zadań”), dopisuje na jego końcu `## Część: task_NN — <tytuł>`; w przeciwnym razie zakłada `factcheck-build-<sha7>.md` z `factcheck_build_template.md`. Wpisuje do `> Zadania:` numer zadania. Wiersz „Na gałęziach” dostaje `--sheet docs/human-tasks/factcheck-build-<sha7>.md`.
- **Co ustawia serwer, nie agent ani człowiek.** Linię `> Build: <sha7> (<zip>)` w nagłówku wpisuje dashboard przy zapisie wpisów człowieka (to build, w który człowiek grał; wybiera go na arkuszu z listy). Linia jest chroniona: agent, który ją wpisze, narusza arkusz (`SHEET_STATE`). Scalenie automatyczne wymaga, żeby `Build` równał się głowie gałęzi zadania.
- **Co wypełnia człowiek.** Wyniki i uwagi w tabelach każdej części, „Uwagi ogólne” i tabelę raportu przebiegu; reszta (opisy, kroki, oczekiwane wyniki) to agent.
- **Kiedy arkusz jest zamknięty.** Gdy zamknięta jest **każda część** (każdy wiersz do wypełnienia ma wynik; ⏭ i ❌ to też wynik), albo gdy Roland go zwolnił lub zamknął z pominięciem. Zamyka się go całego jednym przyciskiem; przenosi się do `done/` razem ze wszystkimi częściami, a wszystkie zadania z `> Zadania:` zamykają się razem z nim.
- **Starsze arkusze** `factcheck-test-NN.md` działają jak dotąd. Gdy zadanie ma i arkusz na build, i swój dawny arkusz, dashboard czyta arkusz na build, a dawny traktuje jako dodatkowy otwarty arkusz zadania (zamknij go albo zwolnij).

## Strefy człowieka
To **jedyna definicja** stref człowieka. `CLAUDE.md`, skille, agenci i szablony tylko tu linkują. W strefach pisze wyłącznie człowiek; hook i audyt przebiegu pilnują agenta. Parser to `dashboard/src/work/sheets.ts` w specyfikacji; ta lista ma go odzwierciedlać.
- **Kolumny tabel** (wielkość liter bez znaczenia): `wynik`, `wynik człowieka`, `wynik (1–7)`, `ocena`, `uwagi`, `uwagi człowieka`, `twój wybór`, `wybór`, `decyzja rolanda` oraz każda kolumna z końcówką `(człowiek)`. Przy tabeli z kolumną `skala` kolumna `wynik` to ocena 1–7.
- **Cała tabela** pod nagłówkiem z „wypełnia człowiek” albo pod linią `<!-- człowiek -->`. Tak samo tabela raportu przebiegu (kolumny „Plik .md” i „Plik .json”): pod `<!-- człowiek -->` albo z kolumnami „Plik .md (człowiek)” i „Plik .json (człowiek)”; nie liczy się do „kompletny”, a plik dołącza przycisk „Dołącz raport przebiegu” w dashboardzie (kopiuje parę z folderu raportów gry do `docs/human-tasks/raporty/` i wpisuje linki).
- **Sekcje odpowiedzi** (bez tabeli): nagłówek z „wypełnia człowiek”, nagłówek kończący się na „(człowiek)” albo jeden ze starych nagłówków: „Twoje uwagi / propozycje”, „Uwagi ogólne”, „Uwagi człowieka”, „Gdzie było nudno albo trudno się połapać?”, „Inne uwagi i błędy”. Strefą jest też treść między `<!-- odpowiedź człowieka -->` i `<!-- /odpowiedź człowieka -->`.
- **Linie nagłówka** `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie` oraz `Build` (tę ostatnią pisze serwer przy zapisie wpisów człowieka).
- **Poza strefą:** kolumny `oczekiwany wynik` i `wynik automatu` oraz tabele pod nagłówkiem z „automat” lub „(agent)”.

## Nazwy arkuszy
- `factcheck-build-<sha7>.md`: arkusz buildu (z `factcheck_build_template.md`), części wszystkich zadań `rozgrywka` z tego buildu.
- `factcheck-test-NN.md`: sprawdzenie zadania `task_NN` (z `factcheck_template.md`); tak nazywają się arkusze sprzed D-36.
- Sesja gry (PT0, PT1, …): z `playtest_template.md`. Plik też nazywa się `factcheck-test-NN.md`, gdzie NN to zadanie, którego build oceniamy, a numer sesji stoi w tytule. PT0 to [factcheck-test-14.md](done/factcheck-test-14.md) (build 0.5.3, zamknięty).

## Arkusz kilku zadań
Od D-36 to zwykły sposób: arkusz buildu jest arkuszem kilku zadań. Gdy otwarty arkusz nie jest jeszcze wypełniany (żadnego wyniku człowieka, żadnej linii `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`), kolejne zadania dopisują do niego część zamiast zakładać nowy arkusz: nagłówek `> Zadania: [task_16](…), [task_17](…)` (dawna linia `> Zadanie:` czyta się jak dotąd) i na KOŃCU pliku `## Część: task_NN — <tytuł>` z własnymi podsekcjami („Co zostało dodane”, „Test”, „Wyniki automatu (agent)”) i pustymi komórkami człowieka. Nigdy nie wstawia się części w środek pliku ani nie rusza istniejących wierszy. Część sięga do następnego nagłówka poziomu 1–2. Dashboard przypisuje arkusz każdemu z wymienionych zadań, pokazuje postęp każdej części, a zadania zamykają się razem z arkuszem. Arkusz, który człowiek zaczął wypełniać, się nie rozrasta.

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
