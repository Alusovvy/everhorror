# Factcheck test 17: palisada bez „niską” i komunikat stołu z mapą

> Zadanie: [task_17](../ai-tasks/task_17.md) · Przygotowano: 2026-10-27 · Gałąź: `spec/2026-10-27-task17`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis.
> Wyniki człowieka: Roland (dashboard), 2026-10-27 14:28

## Co zostało dodane
- Wstęp pierwszego dnia nie nazywa już palisady „niską”: „…przy stole z mapą w zagrodzie Racibora, za palisadą bez dachu…” (wstęp w `tydzien.md`, wariant A ze zgłoszenia o niskiej palisadzie).
- Komunikat po naciśnięciu [M] w obozie mówi „w zagrodzie Racibora” zamiast „w kwaterze Racibora”.

## Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Wstęp w nowej grze | Zacznij nową grę i przeczytaj wstęp do końca | Zdanie brzmi: „Wyprawy planujesz przy stole z mapą w zagrodzie Racibora, za palisadą bez dachu.” Bez słowa „niską”; brzmi naturalnie | ✅ |  |
| 2 | [M] w obozie | W obozie, poza rozmową i menu, naciśnij [M] | Komunikat: „Wyprawy planujesz przy stole z mapą, w zagrodzie Racibora. [M] działa w chodnikach.” (bez „kwatery”) | ✅ |  |

## Wyniki automatu (agent)
Testy uruchomione przez agenta w kopii wdrożeniowej, na gałęzi `spec/2026-10-27-task17`. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| unit, lint, dialogue, day1 (po `--import`) | `tools/run_tests.sh unit lint dialogue day1` | ALL PASSED | `reports/tests/` |
| pełny zestaw (19 scenariuszy) | `tools/run_tests.sh` | ALL PASSED (m.in. day1 23,0 s, week 21,2 s, balance 1415 sprawdzeń) | `reports/tests/` |

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->
