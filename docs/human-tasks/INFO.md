# Arkusze dla człowieka

Arkusze, które wypełnia **człowiek**: factchecki (`factcheck-test-NN.md`), sesje gry (PT), odbiory. Agent tworzy je w głównej kopii gry z `factcheck_template.md` albo `playtest_template.md`, nigdy na gałęzi `spec/*`. Decyzje to karty w specyfikacji (`zgloszenia/`); stare `decision-*.md` w `done/` to historia.

## Strefy człowieka
Pisze w nich tylko człowiek; hook i audyt przebiegu pilnują agenta.
- Komórki kolumn `wynik`, `wynik człowieka`, `ocena`, `wynik (1–7)`, `uwagi`, `twój wybór`, `wybór`, `decyzja rolanda` i kolumn z końcówką `(człowiek)`. Przy kolumnie `skala` `wynik` to ocena 1–7.
- Cała tabela pod nagłówkiem „wypełnia człowiek” albo pod linią `<!-- człowiek -->`.
- Sekcje odpowiedzi: nagłówek „wypełnia człowiek” albo „(człowiek)” (bez tabeli) oraz treść między `<!-- odpowiedź człowieka -->` i `<!-- /odpowiedź człowieka -->`.
- Linie nagłówka `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`.
- Poza strefą: `oczekiwany wynik`, `wynik automatu` i tabele pod nagłówkiem z „automat” lub „(agent)”.

## Znaczniki wyniku
Komórka zaczyna się od ✅ ok, ❌ błąd, 💬 propozycja albo ⏭ pominięte, potem krótki opis. Skala to liczba 1–7. Wpis z „wpis agenta” nie jest dowodem człowieka.

## Kto co pisze
- Człowiek: strefy człowieka. W dashboardzie każdy zapis to osobny commit tego pliku, podpisany przez zapisującego (autor, committer, `Wpisał-Człowiek`).
- Agent: opis, kroki, oczekiwane wyniki i `## Wyniki automatu (agent)`; nigdy wyniku ani „sprawdzone”.

## Zwolnij, zastąp, zamknij
- `Zwolnienie: <Imię> (dashboard, <data>): <powód>` to świadome pominięcie testu przez Rolanda.
- Nagłówek „zastąpione …” oznacza arkusz zastąpiony innym, „niesprawdzone przez człowieka” dawny arkusz bez wpisu człowieka. Takie noty zamykają zadanie bez sprawdzenia, więc dopisuje je człowiek (albo sesja w terminalu na jego polecenie). Agent w przebiegu z dashboardu ich nie dopisuje ani nie zmienia, nie zmienia nazw kolumn „wynik” i „uwagi” (np. na „Wynik automatu”), nie dopisuje „(agent)” do nagłówka tabeli człowieka i nie usuwa pustych wierszy: strażnik widzi to jako zwykły tekst, ale audyt zgłasza taką zmianę stanu arkusza jako naruszenie (`SHEET_STATE`).
- Zamknięcie wymaga arkusza kompletnego albo zwolnionego: `git mv` do `done/` (linki dostają `../`). Do tego czasu leży tutaj.
