# Dashboard specyfikacji: propozycje ulepszeń

> 2026-10-27 · Autor: agent (Claude), przegląd tylko do odczytu · Dla: Rolanda

Przejrzano widok Praca i resztę dashboardu (kod w `specification/dashboard/`: widoki, rdzeń `src/work/`, serwer `node/`, style) oraz `README.md`, `ARCHITEKTURA.md` i `INSTRUKCJA.md`, pod kątem tego, co pomaga szybko i bezpiecznie zrozumieć stan pracy i podjąć decyzję. Każde twierdzenie sprawdzono w kodzie; uruchomiono też `npx tsc --noEmit` (0 błędów) i `node --test "src/**/*.test.ts"` (583 z 583 testów), ale nie pełne `npm test` ani `npm run e2e` (powód w J1). Po przeglądzie Rolanda przyjęte pozycje trafiają do planu (`docs/analizy/final-plan-human-readable.md`, „Przyszłe zadanie narzędziowe dla dashboardu”), a ten plik zostaje usunięty.

**Jak czytać.** Znane pozycje (a)–(j) z planu nie są tu powtarzane; uzupełnienia do nich są na końcu. Odnośniki bez przedrostka dotyczą `specification/dashboard/`. Koszt: **S** — jedna funkcja lub widok z testem, **M** — serwer i widok, kilka plików, **L** — większa przebudowa (żadna pozycja nie jest L). Żadna propozycja z części F, J i W nie wymaga bazy danych, przebudowy dashboardu, grafu relacji ani orkiestratora wielu agentów (plan §5). Wyjątkiem jest część R (równoległe przebiegi), dopisana na prośbę Rolanda: jej ostatni krok zmienia §5 i §3 pkt 5 planu, więc wymaga decyzji.

## Najważniejsze 5

1. **F1. Okno scalania pokazuje werdykt przeglądu** (S, wysoki). Scalenie do master gry to najważniejsze kliknięcie, a okno nie mówi dziś, czy przegląd uznał gałąź za gotową.
2. **F3. Arkusz nie zamyka się po cichu bez raportu przebiegu** (S, wysoki). PT0 zamknięto bez plików raportu, choć plan opierał na nich pierwszy punkt odniesienia dla K1–K5.
3. **F4. Po decyzji „Teraz” prowadzi do wznowienia, nie do wdrożenia** (M, wysoki). Po rozstrzygnięciu karty dashboard podsuwa „Wdróż na gałęzi”, a instrukcja każe najpierw wznowić analizę.
4. **J1. `npm test` nie dotyka prawdziwych przebiegów** (S, wysoki). Test bezpieczeństwa tworzy menedżera przebiegów na prawdziwym folderze i może przejąć trwający przebieg.
5. **F5. „Do zaplanowania” po planowaniu, które nie dało zadań** (S–M, wysoki). Licznik i „Teraz” dalej proponują płatne planowanie, którego instrukcja radzi nie klikać.

Zaraz za nimi: F6 (rozstrzygnięcie karty przy niepełnych odpowiedziach) i J2 (werdykt przeglądu przypięty do commita gałęzi).

## Funkcjonalne

### F1. Okno scalania pokazuje werdykt przeglądu

- **Problem.** „Scal do master gry” jest otwarte także wtedy, gdy ostatni przegląd mówi „blokada: nie scalać” albo przeglądu nie było; werdykt zmienia tylko kolejność przycisków (`src/work/derive.ts:809-826`, `:878`). Jedyne ostrzeżenie scalania dotyczy arkusza (`derive.ts:825`), więc okno pyta tylko o edytor Godota, wypchnięcie i tag (`src/views/WorkItem.tsx:232-278`). Werdykt widać niżej na stronie zadania, w karcie „Przegląd”.
- **Propozycja.** W oknie scalania linia „Przegląd: gotowe (27.10, 10:12)” albo „poprawki / blokada / nieaktualny / brak”. Bez aktualnego „gotowe” wymagane pole „Scalam bez przeglądu „gotowe””, sprawdzane też przez serwer, tak jak dziś potwierdzenie niepełnego arkusza (`node/work-api.ts:18-21`).
- **Koszt:** S · **Priorytet:** wysoki · **Konflikt z §5:** nie.

### F2. Przed scaleniem widać, co jest na gałęzi

- **Problem.** Karta „Gałąź” i okno scalania podają nazwę, skrót commita i liczbę commitów przed master (`src/views/WorkItem.tsx:234-237`, `:544-584`; `src/work/model.ts:210-218`). Żeby zobaczyć, jakie commity są na gałęzi i które pliki zmienia, trzeba otworzyć terminal albo edytor.
- **Propozycja.** Serwer dodaje do faktów otwartej gałęzi listę commitów i zmienionych plików ze statystyką (`git log --oneline master..gałąź`, `git diff --stat master...gałąź`); karta „Gałąź” i okno scalania pokazują je zwinięte. Przy limicie jednej otwartej gałęzi to dwa tanie wywołania gita.
- **Koszt:** M · **Priorytet:** średni · **Konflikt z §5:** nie.

### F3. Arkusz nie zamyka się po cichu bez raportu przebiegu

- **Problem.** Arkusz jest „kompletny”, gdy wypełniono wiersze tabel sprawdzeń, skali i wyborów; tabele formularza i sekcje odpowiedzi się nie liczą (`src/work/sheets.ts:520-550`, `:592`), a „Przenieś do done/” niczego więcej nie sprawdza (`src/views/SheetForm.tsx:800-807`, `:883`). Tak zamknięto PT0: tabela „Raport przebiegu: dołącz plik” jest pusta (`everhorror/docs/human-tasks/done/factcheck-test-14.md:90-96`), a karta z 2026-10-27 stwierdza „PT0 nie ma raportu przebiegu” (`specification/zgloszenia/2026-10-27_dynamika-i-nagrody.md:44`), choć plan liczył, że właśnie ten raport da pierwszy punkt odniesienia dla K1–K5 (etap 4). Dołączenie raportu to dziś kopiowanie plików z folderu gry, wpisanie nazw w „Uwagi” i commit w terminalu (`INSTRUKCJA.md:70`), bo kolumn „Plik .md” i „Plik .json” formularz nie rozpoznaje (`src/work/sheets.ts:198-226`).
- **Propozycja.** (1) Podsumowanie arkusza i pytanie przed zamknięciem wymieniają puste pola, które nie liczą się do „kompletny” (np. „Raport przebiegu: brak plików”), a zamknięcie z nimi wymaga zaznaczenia „Zamykam bez raportu”. (2) Przycisk „Dołącz raport przebiegu”: serwer pokazuje najnowsze pary `przebieg-*.md` i `.json` z folderu raportów gry, kopiuje wybraną parę obok arkusza i zapisuje ją w tym samym commicie co wpisy; w szablonie arkusza kolumny plików dostają dopisek „(człowiek)”, żeby formularz je pokazał.
- **Koszt:** S (1), M (2) · **Priorytet:** wysoki (1), średni (2) · **Konflikt z §5:** nie.

### F4. Po decyzji i po przerwanym przebiegu „Teraz” proponuje wznowienie

- **Problem.** Analiza, która zatrzymała się na pytaniu, kończy się zielonym „Zakończony”, bo linia `STATUS: czeka-na-decyzje` nie zmienia statusu przebiegu (`src/work/runs.ts:1381-1388`, `:1426-1435`), a skrót przebiegu w stanie pracy tej linii nie niesie (`src/work/model.ts:229-239`, `node/work-api.ts:235-247`). Baner na stronie przebiegu odsyła ogólnie do Zgłoszeń (`src/views/Runs.tsx:1495-1499`), a panel po rozstrzygnięciu nie mówi, co dalej (`src/views/DecisionPanel.tsx:156-164`). Po rozstrzygnięciu zadanie wraca do „Zaplanowane”; jeśli analiza zdążyła zapisać sekcję „Analiza” albo „Plan” (`src/work/tasks.ts:301`), „Teraz” i strona zadania podsuwają „Wdróż na gałęzi” (`src/work/derive.ts:871`, `:1296-1303`), choć instrukcja każe wznowić analizę (`INSTRUKCJA.md:57`, `:73`). Wznowienie jest tylko na stronie przebiegu (`Runs.tsx:1662-1665`). Przerwane wdrożenie (gałąź bez 🧪) trafia do „Teraz” dopiero wtedy, gdy nic innego nie czeka (`derive.ts:1288-1295`, `:1311-1319`).
- **Propozycja.** Skrót przebiegu dostaje linię STATUS, a listy przebiegów pokazują „czeka na decyzję”. Gdy ostatni przebieg zadania czeka na decyzję i jego karty są już rozstrzygnięte, albo gdy skończył się przed czasem (błąd, anulowany, limit czasu, przerwany), pierwszym krokiem zadania i pozycją w „Teraz” jest „Wznów: analiza task_NN” z gotową instrukcją (np. „Karta X rozstrzygnięta: 1: a, 2: b. Kontynuuj.”). Baner przebiegu linkuje wprost do kart zadania, a panel po rozstrzygnięciu z powrotem do wznowienia.
- **Koszt:** M · **Priorytet:** wysoki · **Konflikt z §5:** nie (nadal jeden przebieg na kliknięcie Rolanda).

### F5. „Do zaplanowania” po planowaniu, które nie dało zadań

- **Problem.** Licznik liczy zmiany od ostatniego wiersza „W zadaniach” (`node/workspace.ts:726-749`). Planowanie, które uzna, że nic nie trzeba robić, wiersza nie dopisuje, więc licznik zostaje, a „Zaplanuj zadania (agent, Opus)” jest otwarte i stoi w „Teraz” (`src/work/derive.ts:910-923`, `:1304-1306`). Instrukcja opisuje tę pułapkę i prosi, żeby nie klikać (`INSTRUKCJA.md:118`). Fałszywe pozycje z domknięcia (znana pozycja (i)) jeszcze zawyżają licznik.
- **Propozycja.** Przebieg zapisuje w `run.json` HEAD specyfikacji z chwili startu (migawka `before.json` już go ma, `src/work/runs.ts:191`). Gdy ostatnie planowanie skończyło się poprawnie po ostatnim wierszu „W zadaniach”, liczenie zaczyna się od jego HEAD; karta mówi wtedy „Ostatnie planowanie (27.10, 07:44) nie znalazło nic do zrobienia”, a planowanie wraca do „Teraz” dopiero z nową zmianą. Prostsza alternatywa: skill planowania dopisuje wiersz „W zadaniach” z „— (bez zadań)”; serwer już bierze punkt startu z ostatniego wiersza z commitem (`node/workspace.ts:701-711`).
- **Koszt:** S–M · **Priorytet:** wysoki · **Konflikt z §5:** nie (korzysta z istniejącego dziennika przebiegów albo z `WDROZENIA.md`, bez nowego rejestru).

### F6. Rozstrzyganie karty: ostrzeżenie przy brakujących odpowiedziach i podgląd

- **Problem.** „Rozstrzygnij i zatwierdź” działa, gdy wybrano choćby jedną odpowiedź, a status domyślnie przechodzi na ✅ (`src/views/DecisionPanel.tsx:22`, `:186-200`). Brakujące odpowiedzi sygnalizuje tylko szary napis „Bez odpowiedzi: 5 z 6” (`:292-300`). Jedno kliknięcie zamyka kartę, robi commit i zawsze wypycha master (`:209-227`), bez podglądu tego, co trafi do pliku.
- **Propozycja.** Przy brakujących odpowiedziach domyślny status „❔ pytanie” albo wymagane pole „Zamykam z N pytaniami bez odpowiedzi”. Przed kliknięciem zwijany podgląd zmian karty: funkcja, która je buduje, jest czysta (`:118-140`), a widok różnic działa już w Zatwierdź.
- **Koszt:** S · **Priorytet:** wysoki · **Konflikt z §5:** nie.

### F7. Ogólne pole statusu chowa panel rozstrzygnięcia

- **Problem.** Nad panelem „Rozstrzygnij decyzję” stoi ogólne pole „Status” zgłoszenia, które od razu zmienia kartę w koszyku (`src/views/FileView.tsx:55-79`, `:249-250`). Wybór ✅ w tym polu chowa panel, bo widok liczy kartę razem z koszykiem jako rozstrzygniętą (`DecisionPanel.tsx:153-168`, `src/data/store.tsx:328-339`); po zapisaniu i zatwierdzeniu karta jest zamknięta bez linii decyzji i bez wyborów. Komórki „Twój wybór” da się też edytować wprost w tabeli (`src/components/TableEditor.tsx:56-60`), a wtedy panel odmawia do zapisania koszyka (`DecisionPanel.tsx:197`).
- **Propozycja.** Na otwartej karcie decyzji w trybie lokalnym ukryć ogólne pole statusu i edycję kolumny „Twój wybór” w tabeli albo zwinąć je pod „Ręczna edycja (zwykle niepotrzebna)”, tak żeby główną drogą był panel.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie (bez zmian w stanie zapisu w `store.tsx`, czyli długu z §7).

### F8. Koszt i zużycie w jednym miejscu

- **Problem.** Koszt widać tylko przy pojedynczym przebiegu (`src/views/Runs.tsx:990-1051`, `:1508-1511`). Nie ma sumy na dziś ani na tydzień, a strona zadania nie pokazuje kosztu ani czasu jego przebiegów, bo skrót przebiegu ich nie ma (`src/work/model.ts:229-239`, `src/views/WorkItem.tsx:707-731`). Interfejs nigdzie nie mówi, że „USD” to wyliczony koszt w ramach subskrypcji, a nie opłata; mówi to tylko FAQ instrukcji (`INSTRUKCJA.md:142`).
- **Propozycja.** Skrót przebiegu dostaje koszt i czas. Przebiegi pokazują wiersz „Dziś: 4 przebiegi, 12,40 USD (szacunek), 1 h 35 min · 7 dni: …”, strona zadania sumę dla zadania, a pole „Budżet (USD)” i kolumna „Koszt” podpowiedź „szacunek; zużywa limity subskrypcji”.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### F9. Okno startu mówi, gdy ustawienia różnią się od domyślnych

- **Problem.** Okno startu wczytuje z przeglądarki ostatnio użyte ustawienia danego rodzaju i to one wygrywają z domyślnymi (`src/views/Runs.tsx:682-683`). Linia „Domyślnie dla tego rodzaju” podaje tylko budżet, tury i minuty, bez modelu i wysiłku (`:867-872`). Instrukcja opisuje skutek zmiany domyślnych z D-18: okno pamięta stary wysiłek „max” i trzeba kliknąć „Przywróć domyślne” (`INSTRUKCJA.md:53`).
- **Propozycja.** Gdy zapamiętane ustawienia różnią się od domyślnych, wyraźna notka nad polami: „Ostatnie ustawienia: wysiłek max (domyślnie high), budżet 30 USD (domyślnie 15)”. Zapamiętane wartości zapisywać razem z wersją domyślnych i pomijać po ich zmianie w kodzie.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### F10. Fałszywy alarm naruszenia można oznaczyć jako wyjaśniony

- **Problem.** Czerwony baner i pozycja w „Teraz” znikają dopiero po zakończeniu kolejnego przebiegu; naruszenia nie da się oznaczyć jako wyjaśnionego (`src/work/derive.ts:1244-1252`, `src/views/Work.tsx:858-869`). Audyt nie odróżnia agenta od człowieka ani od innej sesji: nowy plik np. w `docs/analizy/` zapisany w czasie przebiegu daje błąd `MAIN_CODE` (`src/work/runs.ts:1764-1770`). Żeby zgasić fałszywy alarm, trzeba uruchomić następny przebieg, a stale czerwony baner uczy go pomijać.
- **Propozycja.** Przycisk „Wyjaśnione” (tylko administrator) z jednym zdaniem powodu; powód, osoba i czas trafiają do `run.json` tego przebiegu. Baner i pozycja w „Teraz” znikają, audyt zostaje w historii przebiegu.
- **Koszt:** S–M · **Priorytet:** średni · **Konflikt z §5:** nie (zapis w istniejącym dzienniku przebiegów poza gitem, nie nowa baza).

### F11. Praca mówi, z której chwili jest stan

- **Problem.** Bez trwającego przebiegu stan pracy odświeża się tylko po powrocie do karty, po „Odśwież” albo po zmianie zrobionej z dashboardu (`src/data/work.ts:373-376`, `:393-402`), a nagłówek mówi „Wszystko jest wyliczane z repozytoriów na bieżąco” (`src/views/Work.tsx:907`). Godziny odczytu nigdzie nie widać, więc gdy w terminalu pracuje inna sesja, tablica może pokazywać stan sprzed kilkunastu minut. „Odśwież” w stopce paska odświeża tylko specyfikację, a „Odśwież” w Pracy także stan pracy (`src/App.tsx:299`).
- **Propozycja.** Obok „Odśwież” napis „stan z 08:14:55” (serwer podaje już czas odczytu, `state.now`) i spokojne odświeżanie co 30–60 s, gdy karta jest widoczna. Przycisk w stopce nazwać „Odśwież specyfikację”.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### F12. Strona przebiegu: dziennik łatwiejszy do przejrzenia

- **Problem.** Dziennik ma jeden filtr („tylko wiadomości”), wpisy nie mają czasu (`src/views/Runs.tsx:1218-1293`, `src/work/runs.ts:257-264`), a wynik narzędzia jest ucinany do 300 znaków (`runs.ts:1245`). Decyzje strażnika trafiają do `guard.log`, którego dashboard nie pokazuje (czytają go tylko testy), więc przy „Sprawdź agenta” powodu blokady trzeba szukać w całym dzienniku. W czasie przebiegu nie widać, ile tur już zużyto; linia „NASTĘPNY KROK” stoi nisko, w tekście końcowym (`Runs.tsx:1535-1540`).
- **Propozycja.** Filtr „błędy i blokady”, czas od startu przy wpisie, sekcja „Strażnik zablokował (N)” z `guard.log`, pasek „12 z 45 min · ok. 30 ze 150 tur” w czasie przebiegu i ramka z „NASTĘPNY KROK” na górze wyniku.
- **Koszt:** S–M · **Priorytet:** średni · **Konflikt z §5:** nie.

### F13. Ze Zmian prosto do Zatwierdź, bez gubienia uzasadnienia

- **Problem.** W trybie solo Zmiany pokazują pola „Tytuł” i „Dlaczego (… agent przeniesie decyzję do dziennika)”, ale „Zapisz na dysk” ich nie używa (`src/views/Changes.tsx:138-145`, `:168-187`; `src/data/store.tsx:486`), więc wpisane uzasadnienie przepada. Komunikat po zapisie nie linkuje do Zatwierdź (`Changes.tsx:178`), gdzie opis commita trzeba wpisać od nowa.
- **Propozycja.** W trybie solo przenieść tytuł i uzasadnienie do Zatwierdź (np. jako podpowiedź opisu commita w adresie strony) i po zapisie na dysk pokazać przycisk „Zatwierdź teraz →”.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie (nie dotyka długu stanu zapisu w `store.tsx` z §7).

### F14. Zatwierdź pokazuje, co trafi do planowania, i podpowiada czytelny opis

- **Problem.** Przed commitem specyfikacji widać różnice linii, ale nie to, które zmiany staną się pozycjami „do wdrożenia”; semantyczny diff służy tylko do domyślnego opisu (`src/views/CommitPanel.tsx:107-114`). Ten opis to pierwsze podsumowanie ucięte do 70 znaków (`:28-32`); tak powstał tytuł commita specyfikacji `32e425b`: „zgloszenia/2026-10-27_dynamika-i-nagrody.md › Możliwości i rekomendac… (+6)”. Instrukcja ostrzega, że nawet poprawka brzmienia zasady staje się pozycją „do wdrożenia” (`INSTRUKCJA.md:125`), ale Zatwierdź tego nie pokazuje. Sekcja gry wymienia tylko ścieżki, bez linku do zadania lub arkusza (`CommitPanel.tsx:480-492`).
- **Propozycja.** Nad przyciskiem lista „Do planowania trafi: N zmian” z rozróżnieniem redakcyjne / do wdrożenia. Domyślny opis z tytułu pliku i liczby zmian (np. „Dynamika gry, nagrody i dialogi: 6 zmian w tabeli wyborów”). Przy dokumentach gry link do strony zadania lub arkusza.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### F15. Zadanie narzędziowe: gotowe polecenie do terminala

- **Problem.** „Nowe zadanie” w nagłówku Pracy tworzy zadanie narzędziowe, którego dashboard nie wdroży: przycisk wdrożenia jest szary z powodem „teraz w terminalu” (`src/work/derive.ts:65`, `:757`; `specification/WORKFLOW.md:50`). Strona zadania nie mówi, jak to zrobić. Dotyczy to też przyszłego zadania narzędziowego dla samego dashboardu.
- **Propozycja.** Na stronie takiego zadania ramka „Wdróż w terminalu” z poleceniem do skopiowania, jak „Wznów rozmowę ręcznie w terminalu” na stronie przebiegu (`src/views/Runs.tsx:1683-1689`).
- **Koszt:** S · **Priorytet:** niski · **Konflikt z §5:** nie.

## Jakość

### J1. `npm test` nie może dotykać prawdziwego folderu przebiegów

- **Problem.** `node/security.test.ts` woła `specApi()` bez opcji (`node/security.test.ts:258` i kolejne). Na komputerze Rolanda oznacza to prawdziwą grę i prawdziwy folder `reports/dashboard-runs` (`node/server.ts:146-163`, `node/workspace.ts:375-398`), więc proces testu tworzy menedżera przebiegów, który przy starcie przejmuje żywy przebieg albo rozlicza nieaktualny i zapisuje jego rekord (`node/runner.ts:1343-1366`, `:1308-1322`). Liczniki czasu przejętego przebiegu trzymają proces testu przy życiu (`runner.ts:1122-1129`), więc test uruchomiony w czasie przebiegu prawdopodobnie nie skończy się przed jego końcem. Dokumentacja twierdzi, że testy tworzą repozytoria wyłącznie w katalogu tymczasowym (`ARCHITEKTURA.md:244`), a dla agenta, który w terminalu poprawia dashboard, `npm test` to zwykły krok sprawdzenia (`ARCHITEKTURA.md:216`).
- **Propozycja.** W testach `specApi()` dostaje `env` z `EVERHORROR_GAME_ROOT` i `EVERHORROR_RUNS_DIR` w katalogu tymczasowym, a menedżer przebiegów w procesie testu nie przejmuje przebiegów z folderu spoza katalogu tymczasowego. Do czasu poprawki: zdanie „nie uruchamiaj `npm test`, gdy trwa przebieg” w `INSTRUKCJA.md` i w `CLAUDE.md` gry.
- **Koszt:** S · **Priorytet:** wysoki · **Konflikt z §5:** nie.

### J2. Werdykt przeglądu przypięty do commita gałęzi

- **Problem.** Werdykt jest uznawany za aktualny, dopóki po przeglądzie nie ruszył przebieg wdrożenia ani poprawek tego zadania; commitów gałęzi nikt nie porównuje (`src/work/derive.ts:151-163`). Instrukcja każe rozwiązać konflikt scalania w terminalu na gałęzi, a potem zrobić przegląd (`INSTRUKCJA.md:60`), ale po takim commicie stare „gotowe” dalej się liczy i „Teraz” stawia „Scal do master gry” wysoko na liście (`derive.ts:1255-1260`).
- **Propozycja.** Przebieg przeglądu zapisuje w `run.json` commit gałęzi, na którym pracował (migawka sprzed przebiegu już go zawiera, `src/work/runs.ts:189-190`), a werdykt jest aktualny tylko przy tym samym commicie. Razem z F1 okno scalania pokazuje wtedy prawdziwy stan.
- **Koszt:** M · **Priorytet:** wysoki · **Konflikt z §5:** nie.

### J3. Podsumowanie ma drugi, nieaktualny silnik „co dalej”

- **Problem.** Karta „Czym warto się teraz zająć” w Podsumowaniu (`src/views/Summary.tsx:138-142`) korzysta z `src/data/suggest.ts`, a nie z listy „Teraz”. Jej teksty powstały przed widokiem Praca i przeczą obecnemu procesowi: „bez tego agent nie zamknie wdrożenia” (`suggest.ts:57`), „poller albo /spec-tasks zrobi z nich zadania” (`:64`, a poller tylko informuje, D-15), „uruchom /ai-task implement” (`:69`), „wyślij do przeglądu albo odrzuć” (`:83`, choć w trybie solo zapisuje się na dysk). Karty decyzji liczy inaczej niż Praca: tylko ze statusem ❔ (`Summary.tsx:97`), a Praca każdą otwartą (`src/spec/model.ts:141-143`).
- **Propozycja.** Zastąpić tę kartę pierwszymi krokami z „Teraz” (jak w Przeglądzie) albo ją usunąć; `suggest.ts` i jego test (`src/spec/spec.test.ts:199-242`) skasować.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### J4. Testy rozstrzygania karty i pomocników formularza

- **Problem.** Funkcja, która wpisuje wybory, linię decyzji i status do karty (`src/views/DecisionPanel.tsx:118-140`), nie ma testu, choć dashboard od razu commituje jej wynik i wypycha master. Bez testów są też pomocniki formularza arkusza (`src/views/SheetForm.tsx:152-197`) i przepisywanie linków (`src/views/WorkItem.tsx:51-65`, `SheetForm.tsx:268-295`). Drobny ślad już jest: po rozstrzygnięciu pod linią decyzji zostają dwie puste linie (`specification/zgloszenia/2026-10-27_dynamika-i-nagrody.md:55-58`; przyczyna w `src/spec/edit.ts:182-195`).
- **Propozycja.** Przenieść te czyste funkcje do `src/work/` (tam są testy na prawdziwych plikach z `fixtures/`) i dodać testy: karta z szablonu, plik z CRLF, częściowe wybory, odpowiedź spoza liter; przy okazji usuwać zbędne puste linie w sekcji „Decyzja”.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### J5. Dokumentacja: miejsca nieaktualne albo sprzeczne z kodem

- **Problem.** (1) Rozdział „Stan teraz: PT0” (`INSTRUKCJA.md:107-118`) opisuje PT0 jako jedyny otwarty arkusz, a arkusz jest już w `done/` (commit gry `78ecb2b`) i w grze czekają `task_16`–`task_18`; rozdział z datą starzeje się po każdym kroku. (2) `ARCHITEKTURA.md:242` podaje wiersze PT0 „16–28”, instrukcja „16–29” (`INSTRUKCJA.md:111`). (3) `ARCHITEKTURA.md:244` obiecuje testy wyłącznie w katalogu tymczasowym (zob. J1). (4) Instrukcja opisuje dwie pułapki kodu zamiast ich poprawek: zapamiętany wysiłek „max” (`INSTRUKCJA.md:53`, zob. F9) i licznik „Do zaplanowania” (`:118`, zob. F5).
- **Propozycja.** Usunąć z instrukcji rozdział o bieżącym stanie (stan pokazuje „Teraz”, historię plan), poprawić numery wierszy, a po F5, F9 i J1 skreślić opisy pułapek.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### J6. Nazwy modeli na przyciskach i model Haiku

- **Problem.** Przyciski mają model na stałe w nazwie, np. „Wdróż na gałęzi (agent, Sonnet)” (`src/work/derive.ts:71-79`), a okno startu pamięta model wybrany ostatnio dla rodzaju (`src/views/Runs.tsx:682-683`), więc po zmianie modelu przycisk mówi nieprawdę. Haiku da się wybrać tylko jako pełny identyfikator (`Runs.tsx:822-826`; serwer przyjmuje `opus`, `sonnet` albo `claude-…`, `src/work/runs.ts:502`; D-18).
- **Propozycja.** Model na przycisku brać z ustawień, z którymi przebieg naprawdę ruszy, albo usunąć go z nazwy; dodać „haiku” do listy, jeśli Claude Code przyjmuje taki alias (do sprawdzenia).
- **Koszt:** S · **Priorytet:** niski · **Konflikt z §5:** nie.

## Wizualne

### W1. Zamknięte akcje spokojniej, ostrzeżenia wyraźniej

- **Problem.** Każdy powód zamkniętej akcji ma kolor ostrzeżenia (`src/views/work.css:27-29`, np. `src/views/Work.tsx:196`, `:560`), a strona zadania wypisuje wszystkie akcje, także zamknięte (`src/views/WorkItem.tsx:817-866`). W zwykłym stanie strona jest pełna bursztynowych zdań w rodzaju „Domknąć można gałąź, która jest już scalona”, więc prawdziwe ostrzeżenie ⚠ się nie wyróżnia. Zamknięte przyciski mają 50% przezroczystości (`src/styles.css:324-327`), co utrudnia odczytanie, co byłoby następne.
- **Propozycja.** Zwykły powód „nie teraz” w kolorze wyciszonym, kolor ostrzeżenia tylko dla ⚠ i dla powodu, który wymaga ruchu Rolanda. Zamknięte akcje poza pierwszą zwinąć pod „Niedostępne teraz (N)”. Zamknięty przycisk z pełnym tekstem i przerywaną ramką zamiast przezroczystości.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie.

### W2. Jedna nazwa na jedną rzecz

- **Problem.** Instrukcja musi tłumaczyć, że „Przegląd” znaczy cztery rzeczy, a „Zatwierdź” trzy (`INSTRUKCJA.md:148-152`), i że jedna czynność ma cztery nazwy (`:80`). „Domknij (agent)” w oknie scalania to na liście „Domknij po scaleniu (agent)” (`src/views/WorkItem.tsx:220`, `src/work/derive.ts:77`). Strona startowa „Przegląd” (`src/App.tsx:61`) powtarza część Pracy, a grupa „Praca” w pasku ma dziewięć pozycji (`App.tsx:53-69`).
- **Propozycja.** Stronę startową nazwać „Start” (albo w trybie lokalnym otwierać od razu Pracę), przycisk agenta „Przegląd kodu (agent)”, jedna etykieta „Zapisz dokumenty w historii gry” i jedna nazwa domknięcia. W pasku na górze Praca, Przebiegi, Zgłoszenia i Zmiany; Wdrożenia, Kolejka, Podsumowanie i Pytania w osobnej grupie „Raporty”.
- **Koszt:** S · **Priorytet:** średni · **Konflikt z §5:** nie (nazwy i kolejność, nie przebudowa).

### W3. Strona zadania: najpierw to, co ważne na danym etapie

- **Problem.** Kolejność kart jest stała: oś etapów, akcje, długie „Wymagania” (do 480 px, `src/views/work.css:589-600`), arkusz, gałąź, karty decyzji, przegląd, raport agenta, przebiegi (`src/views/WorkItem.tsx:799-877`). Na etapie „Na gałęzi” werdykt przeglądu jest pod wymaganiami. Karta „Przegląd” pojawia się też przy zadaniu bez gałęzi, z tekstem „Ta gałąź nie była jeszcze sprawdzana” (`WorkItem.tsx:640-649`), a lista przebiegów zadania nie ma czasu ani kosztu (`:707-731`).
- **Propozycja.** Na etapach „Na gałęzi” i „Scalone” przegląd i gałąź nad wymaganiami; wymagania po zaplanowaniu zwinięte do pierwszych linii z „Pokaż całość”; karta przeglądu tylko przy gałęzi; czas i koszt przy przebiegach (z F8).
- **Koszt:** S · **Priorytet:** niski · **Konflikt z §5:** nie.

### W4. Polskie liczebniki tam, gdzie ich brakuje

- **Problem.** Przegląd pokazuje „1 błędów” i „2 uwag” (`src/views/Overview.tsx:225-226`), widok działów „3 czeka na decyzję” (`src/views/Docs.tsx:145-146`), Podsumowanie „pliki(-ów)”, „N pytań” i „N błędów spójności” (`src/data/suggest.ts:77`, `:81`, `:83-84`). Projekt ma do tego `plural()` (`src/spec/plural.ts`).
- **Propozycja.** Użyć `plural()` w tych miejscach (w Podsumowaniu problem zniknie razem z J3).
- **Koszt:** S · **Priorytet:** niski · **Konflikt z §5:** nie.

### W5. Długi arkusz: przejście do następnego pustego pola

- **Problem.** Formularz pokazuje wszystkie bloki jeden pod drugim (`src/views/SheetForm.tsx:1034-1046`); PT0 miał 40 pól (`INSTRUKCJA.md:111`). Nie da się przeskoczyć do pustego pola ani ukryć wypełnionych. „Zgłoś w specyfikacji” przenosi do Zmian i miejsce w arkuszu przepada (`SheetForm.tsx:901-923`).
- **Propozycja.** W przyklejonym pasku zapisu (`src/views/work-forms.css:268-279`) przycisk „Następne puste ↓” i przełącznik „Tylko puste”; zgłoszenie z wiersza zakładać bez opuszczania arkusza, z notką „Szkic zgłoszenia jest w koszyku”.
- **Koszt:** S–M · **Priorytet:** niski · **Konflikt z §5:** nie.

## Równoległe przebiegi i gałęzie (prośba Rolanda)

Roland, czat 2026-10-27: „zrobić trochę parallel to runowanie agentów i branche, żeby nie było tyle kolizji i konfliktów z branchami, zrobimy sobie golden-main na githubie, z którego robimy buildy i do niego wrzucamy rzeczy, ale on jest jakby golden-standardem, a wszystko inne pracuje na innych branchach”.

**Ocena agenta.** Kierunek jest dobry, z jedną zmianą. Rolę „golden-main” pełni już `master` gry: tylko z niego powstają buildy i tagi i tylko Roland do niego scala. Brakuje mu ochrony po stronie GitHuba, a nie osobnej gałęzi. Same równoległe gałęzie nie zmniejszają konfliktów, tylko przenoszą je na chwilę scalania. Kolizje zmniejszają trzy rzeczy: osobna kopia robocza dla każdego przebiegu, jeden pisarz wspólnych plików buchalterii i blokada obejmująca tylko zapis, a nie cały przebieg. Dzisiejsze kolizje biorą się głównie z dwóch źródeł. Pierwsze to wspólna kopia wdrożeniowa `everhorror-wdrozenie`. Drugie to pliki, które zmieniają wszyscy: `WDROZENIA.md`, plan i pliki zadań. Przykład z 2026-10-27: edycja planu z sesji w terminalu dała w audycie przebiegu `MAIN_CODE` (zob. F10). Kroki R1–R3 pomagają już przy jednym przebiegu naraz. R4 włącza równoległość i jako jedyny zmienia ustalenia planu.

### R1. `master` gry chroniony w GitHubie („golden main”)

- **Problem.** Że `master` przyjmuje tylko scalenia Rolanda i że force push jest zakazany, pilnują dziś zasady w `CLAUDE.md`, plan §3 pkt 6 i strażnik przebiegów (`src/work/runs.ts:940-952`). Push z terminala albo z innego narzędzia tych zabezpieczeń nie przechodzi.
- **Propozycja.** Reguła gałęzi (ruleset) w GitHubie dla `master` gry: zakaz force pusha i usuwania, zmiany tylko przez PR, scalanie tylko przez Rolanda, opcjonalnie wymóg zielonego testu. Buildy i tagi `v*` tylko z `master`. Repo gry `Alusovvy/everhorror` jest **publiczne**, więc reguły są dostępne za darmo. Repo specyfikacji `Alusovvy/everhorror-specification` jest **prywatne**. Na darmowym planie GitHub nie egzekwuje w nim reguł gałęzi, tak jak CODEOWNERS (`ARCHITEKTURA.md`, opis `cli.ts codeowners`), więc tam zostaje strażnik dashboardu. Zapisy dashboardu do `master` gry (arkusze, dokumenty procesu, D-17a) musiałyby wtedy iść przez PR scalany automatycznie albo przez wyjątek w regule dla konta Rolanda. To do ustalenia przy wdrożeniu.
- **Koszt:** S · **Priorytet:** wysoki · **Konflikt z §5:** nie.

### R2. Osobna kopia robocza na każdy przebieg

- **Problem.** Wszystkie wdrożenia, poprawki i przeglądy pracują w jednej kopii `everhorror-wdrozenie`. Bramki „kopia brudna” i „brak kopii” zamykają wdrożenie dla wszystkich (`src/work/derive.ts:763-764`). Gałąź z kodem i kopia są w praktyce jednym zasobem.
- **Propozycja.** Serwer tworzy dla przebiegu kopię `everhorror-wt/<gałąź>` (`git worktree add`) i usuwa ją po scaleniu albo odrzuceniu gałęzi. Strażnik i audyt dostają ścieżkę kopii z polityki przebiegu, tak jak dziś `ctx.wt`. Nowa kopia potrzebuje jednego `--import` Godota (kilka minut), co dolicza się do czasu pierwszego przebiegu na gałęzi.
- **Koszt:** M · **Priorytet:** średni · **Konflikt z §5:** nie (nadal jeden przebieg naraz).

### R3. Jeden pisarz buchalterii, blokada na zapis

- **Problem.** Wspólne pliki (`WDROZENIA.md`, pliki zadań, arkusze, plan) zmieniają przebiegi, serwer i sesje w terminalu. Dlatego blokada `lock.json` trzyma oba repozytoria przez cały przebieg, a audyt przypisuje przebiegowi cudze zmiany (F10). Przeniesienie tych plików na gałęzie dałoby konflikty w tabelach `WDROZENIA.md` przy każdym scaleniu, więc to nie jest dobra droga.
- **Propozycja.** Buchalteria zostaje w `master` (gry i specyfikacji), ale zapisuje ją tylko serwer dashboardu, przez kolejkę: jeden krótki zapis i commit naraz. Przebieg zgłasza zapis (np. „dopisz wiersz Na gałęziach”) poleceniem CLI zamiast edytować plik. Blokada obejmuje tylko chwilę zapisu. Kod gry powstaje wyłącznie w kopii przebiegu (R2), więc nie potrzebuje blokady na całe repozytorium. Sesje w terminalu używają tego samego polecenia CLI.
- **Koszt:** M–L · **Priorytet:** średni · **Konflikt z §5:** nie (kolejka zapisów to nie orkiestrator wielu agentów i nie baza danych).

### R4. Dwa wdrożenia naraz, na rozłącznych plikach

- **Problem.** Dziś obowiązuje limit 1 otwartej gałęzi z kodem (plan §3 pkt 5, `derive.ts:758`) i jeden przebieg naraz (`ARCHITEKTURA.md`, „Jedno uruchomienie agenta naraz”). Niezależne zadania czekają w kolejce, np. dźwięki obok tekstów ogniska.
- **Propozycja.** Po R1–R3 najwyżej **2** przebiegi wdrożenia albo poprawek naraz, każdy w swojej kopii i na swojej gałęzi. Drugi startuje tylko wtedy, gdy zbiory plików i systemów z sekcji „Dla agenta” obu zadań są rozłączne. Dashboard sprawdza to przed startem i podaje powód odmowy. Planowanie, analiza i domknięcie piszą specyfikację, więc zostają pojedyncze. Scalanie dalej robi tylko Roland, jedno po drugim. Drugą gałąź po scaleniu pierwszej scala się z nowym `master` w terminalu (agentom `git merge` i `git rebase` są zablokowane, `runs.ts:946-947`), a potem robi się przegląd (J2).
- **Koszt:** M · **Priorytet:** niski (dopiero po R1–R3) · **Konflikt z §5:** **tak**. Zastępuje „najwyżej 1 otwarta gałąź z kodem” (§3 pkt 5) oraz w tym zakresie „bez orkiestratora wielu agentów” (§5, decyzja z 2026-09-26) i zasadę jednego przebiegu naraz. Wymaga zapisania nowej decyzji w planie §9. Dwa przebiegi naraz zużywają też dwa razy szybciej limit subskrypcji (F8).

## Uzupełnienia do znanych pozycji (a)–(j)

- **(g) rodzajowe stopki commitów.** Formy rodzajowe są też w interfejsie: „uruchomił” (`src/views/Runs.tsx:656`), „Uruchomił” (`:1116`, `:1704`), „gdy zacząłeś wpisywać” i „których jeszcze nie zapisałeś” (`src/views/SheetForm.tsx:1011`, `:1021`), „kto wprowadził zmianę i kto ją zatwierdził” (`src/views/Summary.tsx:147`). Neutralne wersje: „Start: Roland”, „od rozpoczęcia wpisywania”, „Niezapisane wpisy przepadną”, „autor i zatwierdzenie zmiany”.
- **(j) opcje w kartach decyzji bez kontekstu.** Przykładowa karta jest już uzupełniona, ale po decyzji: rozstrzygnięcie `748b273` (07:53) zapadło przy opcjach z samymi kodami, a opisy dopisał commit `32e425b` (08:03). Obecny plik nie pokazuje więc problemu, widać go w historii. Szablon `specification/szablony/decyzja.md` nadal nie wymaga opisu kodów (część pierwsza nie jest zrobiona). Panel stoi nad treścią karty (`src/views/FileView.tsx:250` i `:272-285`), więc najtańszy początek części drugiej to pokazanie sekcji „Możliwości i rekomendacja” obok tabeli wyborów.

## Czego nie sprawdzono

- Pełnego `npm test` i `npm run e2e` nie uruchomiono: w czasie przeglądu trwał przebieg analizy `task_17`, a z J1 wynika, że test bezpieczeństwa mógłby go przejąć. Zawieszenie testu w J1 wynika z kodu, nie z próby.
- Interfejsu nie oglądano w przeglądarce (bez drugiego serwera i bez wywołań API); uwagi wizualne opierają się na kodzie i stylach. Kontrast policzono tylko dla jasnego motywu: tekst wyciszony i ostrzeżenia mają ok. 5:1 i spełniają WCAG AA.
- Niesprawdzone w dokumentacji Claude Code: alias `haiku` (J6), znacznik czasu w zdarzeniach `stream-json` (F12) i treść komunikatu o wyczerpanym limicie subskrypcji (warto go rozpoznawać przy F8).
- Dokładne polecenie terminala dla zadań narzędziowych (F15) trzeba potwierdzić ze skillem `ai-task`.
- F4 zakłada, że analiza zapisuje sekcję „Analiza” albo „Plan”, zanim zada pytanie; tak opisuje to instrukcja (`INSTRUKCJA.md:57`), ale zależy to od skilla.

## Bez uwag

- Każdy zamknięty przycisk ma powód w słowach, a serwer sprawdza tę samą regułę, co przycisk (`node/work-api.ts:32`, `src/work/derive.ts`).
- Błędy są po polsku, także gdy serwer dashboardu nie odpowiada (`src/data/source.ts:133`).
- Okna to natywne `<dialog>` (fokus zostaje w oknie, Esc zamyka), a jasny i ciemny motyw korzystają z jednego zestawu kolorów (`src/styles.css:1-50`).
