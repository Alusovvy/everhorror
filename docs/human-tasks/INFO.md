# Arkusze dla człowieka

Arkusze, które wypełnia **człowiek**: factchecki (`factcheck-test-NN.md`), sesje gry (PT), odbiory. Agent tworzy je w głównej kopii gry z `factcheck_template.md` albo `playtest_template.md`, nigdy na gałęzi `spec/*`. Decyzje to karty w specyfikacji (`zgloszenia/`); stare `decision-*.md` w `done/` to historia.

## Strefy człowieka
To **jedyna definicja** stref człowieka. `CLAUDE.md`, skille, agenci i szablony tylko tu linkują. W strefach pisze wyłącznie człowiek; hook i audyt przebiegu pilnują agenta. Parser to `dashboard/src/work/sheets.ts` w specyfikacji; ta lista ma go odzwierciedlać.
- **Kolumny tabel** (wielkość liter bez znaczenia): `wynik`, `wynik człowieka`, `wynik (1–7)`, `ocena`, `uwagi`, `uwagi człowieka`, `twój wybór`, `wybór`, `decyzja rolanda` oraz każda kolumna z końcówką `(człowiek)`. Przy tabeli z kolumną `skala` kolumna `wynik` to ocena 1–7.
- **Cała tabela** pod nagłówkiem z „wypełnia człowiek” albo pod linią `<!-- człowiek -->`.
- **Sekcje odpowiedzi** (bez tabeli): nagłówek z „wypełnia człowiek”, nagłówek kończący się na „(człowiek)” albo jeden ze starych nagłówków: „Twoje uwagi / propozycje”, „Uwagi ogólne”, „Uwagi człowieka”, „Gdzie było nudno albo trudno się połapać?”, „Inne uwagi i błędy”. Strefą jest też treść między `<!-- odpowiedź człowieka -->` i `<!-- /odpowiedź człowieka -->`.
- **Linie nagłówka** `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`.
- **Poza strefą:** kolumny `oczekiwany wynik` i `wynik automatu` oraz tabele pod nagłówkiem z „automat” lub „(agent)”.

## Nazwy arkuszy
- `factcheck-test-NN.md`: sprawdzenie zadania `task_NN` (z `factcheck_template.md`).
- Sesja gry (PT0, PT1, …): z `playtest_template.md`. Plik też nazywa się `factcheck-test-NN.md`, gdzie NN to zadanie, którego build oceniamy, a numer sesji stoi w tytule. PT0 to [factcheck-test-14.md](done/factcheck-test-14.md) (build 0.5.3, zamknięty).

## Minimum ważności sesji gry
Sesja gry liczy się do celów K z planu tylko wtedy, gdy ma wypełnione „Dotarcie do” i dołączony raport przebiegu (.md albo .json). Sesja bez nich daje tylko wskazówkę kierunku, nie pomiar, i tak ją opisujemy.
- Wiersze dni powyżej „Dotarcie do” zostają puste. Przy zamknięciu arkusza dashboard wpisze w nich ⏭ (decyzja D-28), więc nikt nie ocenia dni, których nie zagrał.
- W „Dane sesji” napis z menu głównego kopiujemy w całości (wersja i skrót specyfikacji), a nie tylko numer wersji.
- Łączny czas gry podajemy w rzeczywistych godzinach; wartość „<1h” przy wielu ocenionych dniach nie jest wiarygodna.
- Zamknięte arkusze leżą w [done/](done/), razem ze starszą historią: `decision-*.md`, `factcheck-foundation-2026-10-26.md` i zastąpionym `factcheck-test-15.md`. Tych plików nie edytujemy.

## Znaczniki wyniku
Komórka zaczyna się od ✅ ok, ❌ błąd, 💬 propozycja albo ⏭ pominięte, potem krótki opis. Skala to liczba 1–7. Wpis z „wpis agenta” nie jest dowodem człowieka.

## Kto co pisze
- Człowiek: strefy człowieka. W dashboardzie każdy zapis to osobny commit tego pliku, z podpisem osoby, która wpisuje (autor, committer, `Wpisał-Człowiek`).
- Agent: opis, kroki, oczekiwane wyniki i `## Wyniki automatu (agent)`; nigdy wyniku ani „sprawdzone”.

## Zwolnij, zastąp, zamknij
- `Zwolnienie: <Imię> (dashboard, <data>): <powód>` to świadome pominięcie testu przez Rolanda.
- Nagłówek „zastąpione …” oznacza arkusz zastąpiony innym, „niesprawdzone przez człowieka” dawny arkusz bez wpisu człowieka. Takie noty zamykają zadanie bez sprawdzenia, więc dopisuje je człowiek (albo sesja w terminalu na jego polecenie). Agent w przebiegu z dashboardu ich nie dopisuje ani nie zmienia, nie zmienia nazw kolumn „wynik” i „uwagi” (np. na „Wynik automatu”), nie dopisuje „(agent)” do nagłówka tabeli człowieka i nie usuwa pustych wierszy: strażnik widzi to jako zwykły tekst, ale audyt zgłasza taką zmianę stanu arkusza jako naruszenie (`SHEET_STATE`).
- Zamknięcie wymaga arkusza kompletnego albo zwolnionego: `git mv` do `done/` (linki dostają `../`). Do tego czasu leży tutaj.
