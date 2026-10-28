# Arkusze dla człowieka

Arkusze, które wypełnia **człowiek**: arkusz cyklu oceny (`factcheck-cykl-NN.md`), sesje gry (PT), odbiory. Starsze `factcheck-build-<sha7>.md` i `factcheck-test-NN.md` to historia i dalej się czytają. Od D-38 jest **jeden arkusz i jeden build na cykl oceny** (zob. „Cykl oceny”). Arkusz cyklu zakłada i składa serwer dashboardu razem z buildem, nie agent: agent opisuje swoją część w **pliku zadania** (sekcja `## Część arkusza`), nigdy w `docs/human-tasks/`. Rejestr buildów `BUILDY.md` też prowadzi tylko serwer. Decyzje to karty w specyfikacji (`zgloszenia/`); stare `decision-*.md` w `done/` to historia.

## Cykl oceny
Roland ocenia grę w **cyklach** (D-38, Roland, czat 2026-10-28). Cykl to jeden build `master` i jeden arkusz. Do zagrania jest zawsze najwyżej jeden cykl, a pliki mówią, co się dzieje: rejestr `BUILDY.md` i arkusz `factcheck-cykl-NN.md`.

**Stany.** `zbiera`: zadania scalone do `master` po commicie builda poprzedniego cyklu, jeszcze bez builda (zawsze dokładnie jeden cykl zbiera; nie ma wiersza w rejestrze, widać go w karcie „Cykl” w dashboardzie). `do zagrania`: build jest zrobiony, wiersz rejestru ma stan `bieżący`, arkusz leży w `docs/human-tasks/`. `stary`: wiersz ma stan `stary`, arkusz leży w `done/`.

**Przebieg.**
1. Wdrożenie zadania `rozgrywka` pisze w swoim pliku zadania sekcję `## Część arkusza` (co zostało dodane, tabela „Test”, wyniki automatu). Po przebiegu dashboard uruchamia testy serwera (dla `tekst` i `rozgrywka` także scenariusz `export`, czyli grę z wyeksportowanej paczki). Builda gałęzi i arkusza nie ma.
2. Zadanie scala się do `master` po przeglądzie kodu i zielonych testach serwera (Roland albo scalanie automatyczne, D-35). Arkusz nie jest warunkiem scalenia, więc do `master` może trafić niezagrana rozgrywka; `master` nie jest wydaniem.
3. Gdy zadania cyklu są scalone i domknięte, a żadne nie jest już w pracy (i zadania z oceny poprzedniego cyklu są scalone), serwer robi **jeden build `master`** (`build/do-ogrania/Everhorror-cykl-NN-<sha7>-windows.zip`) i **jeden arkusz** `factcheck-cykl-NN.md` z częściami wszystkich tych zadań w kolejności scalenia, a w rejestrze dopisuje wiersz cyklu. To jeden commit w `master` gry, bez pushu (push to krok „Wypchnij grę”). Build rusza sam, gdy nic go nie wstrzymuje; powody, dla których czeka, widać w karcie „Cykl”, a przycisk „Zbuduj build cyklu NN” buduje od razu.
4. Człowiek gra cały cykl na tym jednym buildzie i wypełnia jeden arkusz. Wpisy zapisują się w dashboardzie jako osobne commity tego pliku.
5. **Oddanie wyników = „Zamknij arkusz”.** Jedno kliknięcie przenosi arkusz do `done/` (puste pola dostają ⏭), zmienia wiersz rejestru na `stary` z wynikiem oceny i zamyka cykl. Okno zamknięcia proponuje przebieg planowania (`/spec-tasks`), który z ❌, 💬 i uwag robi zadania **następnego** cyklu (zgłoszenie albo reguła ⬜ w specyfikacji, potem zadanie). Następny build czeka, aż te zadania zostaną scalone i domknięte.

**Poziomy zadań** (`Poziom:` w pliku zadania, D-36; brak linii znaczy `rozgrywka`; nadaje go `/spec-tasks`, Roland może go zmienić):

| Poziom | Co to jest | Część arkusza | Scalenie |
|---|---|---|---|
| `tekst` | tylko teksty, dialogi, dokumenty | brak (wchodzi do buildu cyklu) | przegląd kodu i testy serwera z testem eksportu |
| `narzędzia` | `tools/`, generatory, skille, dashboard, bez zmian w rozgrywce | brak, nie buduje cyklu samo | przegląd kodu i testy serwera (bez eksportu) |
| `rozgrywka` | wszystko, co zmienia to, co gracz przeżywa | **tak**, w pliku zadania, a w arkuszu cyklu składa ją serwer | przegląd kodu i testy serwera z testem eksportu |

- **Zadanie `tekst` albo `narzędzia`** nie ma części: w wierszu „Na gałęziach” wdrożenie zapisuje `--sheet -`. Dowodem są testy serwera i przegląd. To nie łamie zasady „agent nie wpisuje wyników za człowieka”: takie zadanie nie ma pól człowieka. Arkusz cyklu wymienia je w linii `> W buildzie bez części`.
- **Zadanie `rozgrywka` bez sekcji `## Część arkusza`** dostaje w arkuszu część z jednym wierszem „Zagraj w zmianę z zadania”, a karta cyklu ostrzega.
- **Kod w rogu menu** (`BuildInfo.label()`, „wersja · spec sha7”) zmienia się tylko przy wydaniu, więc build cyklu pokazuje to samo co poprzednie buildy od wydania. Build rozpoznajesz po numerze cyklu i skrócie commita gry w nazwie ZIP-a; rejestr zapisuje kod w rogu taki, jaki gra naprawdę pokaże.
- **Pierwszy cykl bez rejestru** (D-38, po zwolnieniu starych arkuszy): zbiera zadania scalone po **późniejszym** z dwóch commitów: ostatniego, który przeniósł do `done/` arkusz starego rodzaju (wszystko przed nim było ocenione albo zwolnione przez Rolanda), i ostatniego tagu wydania; bez żadnego z nich od początku `master`. Gdy po zwolnieniu starych arkuszy nic nie zostanie scalone, cykl 1 po prostu zbiera i czeka na pierwsze scalone zadanie. Dalej punktem startu jest build poprzedniego cyklu (stopka `BUILDY.md`: „Cykl N zbiera zadania scalone do `master` gry po commicie …”).
- **Starsze arkusze** `factcheck-build-*` i `factcheck-test-*`, które jeszcze leżą otwarte, dashboard dalej czyta, zamyka i zwalnia. Dopóki leżą otwarte (także zwolnione, a niezamknięte), wstrzymują pierwszy build cyklu; „Przenieś otwarte arkusze do cyklu 1” w karcie cyklu przenosi je do cyklu 1, ale zwykle wystarczy je zwolnić i zamknąć.

## Rejestr buildów (BUILDY.md)
`BUILDY.md` pisze **tylko serwer**: nie edytuj go ręcznie, strażnik blokuje każdy przebieg agenta. Tabela ma jeden wiersz na cykl, najnowszy na dole: numer cyklu, stan (`bieżący` albo `stary`), commit gry builda, kod w rogu menu, data, ZIP, zadania i zmiany (linki do zadań, tytuły, ID reguł, „inne commity: N”), link do arkusza, wynik oceny (✅ a · ❌ b · 💬 c · ⏭ d, kto zamknął i kiedy) i zadania, które powstały z oceny. Kolumn i wierszy dopisanych ręcznie dashboard nie kasuje, ale pokazuje je jako problem rejestru („Uzgodnij rejestr”). Plik pojawia się razem z pierwszym buildem cyklu; do tego czasu go nie ma.

## Strefy człowieka
To **jedyna definicja** stref człowieka. `CLAUDE.md`, skille, agenci i szablony tylko tu linkują. W strefach pisze wyłącznie człowiek; hook i audyt przebiegu pilnują agenta. Parser to `dashboard/src/work/sheets.ts` w specyfikacji; ta lista ma go odzwierciedlać.
- **Kolumny tabel** (wielkość liter bez znaczenia): `wynik`, `wynik człowieka`, `wynik (1–7)`, `ocena`, `uwagi`, `uwagi człowieka`, `twój wybór`, `wybór`, `decyzja rolanda` oraz każda kolumna z końcówką `(człowiek)`. Przy tabeli z kolumną `skala` kolumna `wynik` to ocena 1–7.
- **Cała tabela** pod nagłówkiem z „wypełnia człowiek” albo pod linią `<!-- człowiek -->`. Tak samo tabela raportu przebiegu (kolumny „Plik .md” i „Plik .json”): pod `<!-- człowiek -->` albo z kolumnami „Plik .md (człowiek)” i „Plik .json (człowiek)”; nie liczy się do „kompletny”, a plik dołącza przycisk „Dołącz raport przebiegu” w dashboardzie (kopiuje parę z folderu raportów gry do `docs/human-tasks/raporty/` i wpisuje linki).
- **Sekcje odpowiedzi** (bez tabeli): nagłówek z „wypełnia człowiek”, nagłówek kończący się na „(człowiek)” albo jeden ze starych nagłówków: „Twoje uwagi / propozycje”, „Uwagi ogólne”, „Uwagi człowieka”, „Gdzie było nudno albo trudno się połapać?”, „Inne uwagi i błędy”. Strefą jest też treść między `<!-- odpowiedź człowieka -->` i `<!-- /odpowiedź człowieka -->`.
- **Linie nagłówka** `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie` oraz `Build` (tę ostatnią pisze serwer: w arkuszu cyklu przy jego tworzeniu, w dawnych arkuszach przy zapisie wpisów człowieka).
- **Poza strefą:** kolumny `oczekiwany wynik` i `wynik automatu` oraz tabele pod nagłówkiem z „automat” lub „(agent)”.

## Nazwy arkuszy
- `factcheck-cykl-NN.md`: arkusz cyklu oceny (D-38; z `factcheck_cykl_template.md`, składa go serwer), NN to numer cyklu i zarazem numer buildu; dwie cyfry co najmniej. Zamknięty leży w `done/`.
- `BUILDY.md`: rejestr buildów cyklu (nie jest arkuszem).
- Dawne nazwy, tylko historia: `factcheck-build-<sha7>.md` (arkusz buildu z D-36) i `factcheck-test-NN.md` (sprawdzenie zadania `task_NN`, z `factcheck_template.md`).
- Sesja gry (PT0, PT1, …): z `playtest_template.md`. Plik też nazywa się `factcheck-test-NN.md`, gdzie NN to zadanie, którego build oceniamy, a numer sesji stoi w tytule. PT0 to [factcheck-test-14.md](done/factcheck-test-14.md) (build 0.5.3, zamknięty).

## Minimum ważności sesji gry
Sesja gry liczy się do celów K z planu tylko wtedy, gdy ma wypełnione „Dotarcie do” i dołączony raport przebiegu (.md albo .json). Sesja bez nich daje tylko wskazówkę kierunku, nie pomiar, i tak ją opisujemy.
- Wiersze dni powyżej „Dotarcie do” zostają puste. Przy zamknięciu arkusza dashboard wpisze w nich ⏭ (decyzja D-28), więc nikt nie ocenia dni, których nie zagrał.
- W „Dane sesji” napis z menu głównego kopiujemy w całości (wersja i skrót specyfikacji), a nie tylko numer wersji. Build do ogrania pokazuje w menu numer ostatniego wydania, więc przy nim dopisz też numer cyklu z arkusza albo nazwę ZIP-a (numer cyklu i skrót commita).
- Łączny czas gry podajemy w rzeczywistych godzinach; wartość „<1h” przy wielu ocenionych dniach nie jest wiarygodna.
- Zamknięte arkusze leżą w [done/](done/), razem ze starszą historią: `decision-*.md`, `factcheck-foundation-2026-10-26.md` i zastąpionym `factcheck-test-15.md`. Tych plików nie edytujemy.

## Znaczniki wyniku
Komórka zaczyna się od ✅ ok, ❌ błąd, 💬 propozycja albo ⏭ pominięte, potem krótki opis. Skala to liczba 1–7. Wpis z „wpis agenta” nie jest dowodem człowieka. Znacznik `⏭ pominięte (zamknięcie bez wypełnienia)` wpisuje w puste pola sam dashboard przy zamknięciu arkusza z pominięciem; nie jest dowodem sprawdzenia.

## Kto co pisze
- Człowiek: strefy człowieka. W dashboardzie każdy zapis to osobny commit tego pliku, z podpisem osoby, która wpisuje (autor, committer, `Wpisał-Człowiek`).
- Agent: opis, kroki, oczekiwane wyniki i `## Wyniki automatu (agent)`, **w swoim pliku zadania** (sekcja `## Część arkusza`); nigdy wyniku ani „sprawdzone”. W `docs/human-tasks/` agent z przebiegu dashboardu nie zapisuje niczego.
- Serwer dashboardu: arkusz cyklu (składa go z części zadań razem z buildem), jego linię `> Build:`, rejestr `BUILDY.md` i przeniesienie arkusza do `done/` przy zamknięciu. Zamknięcie arkusza cyklu zamyka cykl.

## Zwolnij, zastąp, zamknij
- `Zwolnienie: <Imię> (dashboard, <data>): <powód>` to świadome pominięcie testu przez Rolanda.
- Nagłówek „zastąpione …” oznacza arkusz zastąpiony innym, „niesprawdzone przez człowieka” dawny arkusz bez wpisu człowieka. Takie noty zamykają zadanie bez sprawdzenia, więc dopisuje je człowiek (albo sesja w terminalu na jego polecenie). Agent w przebiegu z dashboardu ich nie dopisuje ani nie zmienia, nie zmienia nazw kolumn „wynik” i „uwagi” (np. na „Wynik automatu”), nie dopisuje „(agent)” do nagłówka tabeli człowieka i nie usuwa pustych wierszy: strażnik widzi to jako zwykły tekst, ale audyt zgłasza taką zmianę stanu arkusza jako naruszenie (`SHEET_STATE`).
- Zamknięcie: arkusz kompletny albo zwolniony przenosi się do `done/` bez zmian (`git mv`, linki dostają `../`); dla arkusza cyklu ten sam commit zmienia wiersz rejestru na `stary`. Arkusz jeszcze niewypełniony Roland może zamknąć w dashboardzie „z pominięciem”: w tym samym commicie każde puste pole do wypełnienia (wyniki, skale, pytania otwarte) dostaje `⏭ pominięte (zamknięcie bez wypełnienia)`, kolumna uwag zostaje pusta, a nagłówek dostaje `Zamknięcie: <Imię> (dashboard, <data>): pominięte N z M pól`. To wpis człowieka (agent go nie robi), a zadania z takiego arkusza zamykają się jako „zamknięte bez pełnego sprawdzenia”. Zwolnienie mówi „tego testu nie trzeba”, pominięcie „tego nie sprawdzono”. Pusta tabela raportu przebiegu wymaga w dashboardzie potwierdzenia „Zamykam bez raportu”. Do czasu zamknięcia arkusz leży tutaj.
