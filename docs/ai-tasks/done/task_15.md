# task_15: Orkiestracja zadań i arkuszy z dashboardu

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-26; wymagania to jego słowa, nie edytować.
-->

Wymagania:
Te ai taski i human taski do przerobienia na już, wszystko chce orchiestrować z poziomu dashboardu. Przenalizuj wymagane zmiany i wprwoadź oraz przetestuj. Dodatkwo usprawnij dashboard, uzyj Opus 5.5 Max do analizy i potem do weryfikacji, ale zadania kodingowe deleguj do Sonnet 5.5 Max.

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-26)

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

> Odbiór człowieka: część B arkusza [factcheck-test-14](../../human-tasks/factcheck-test-14.md) (połączono 2026-10-27 na prośbę Rolanda). Wcześniejszy arkusz [factcheck-test-15](../../human-tasks/done/factcheck-test-15.md) jest zastąpiony. Kod dashboardu jest w master specyfikacji (`88edde0`).

## Co zostało zrobione

Kod powstał w osobnej kopii roboczej specyfikacji `C:\dev\gamedev\everhorror\specification-praca` (gałąź `agent/praca-dashboard`, 14 commitów po `07f21f8`, HEAD `8093753`), bo żywa kopia `specification` była używana i lintowana przez drugą sesję (task_14). W master specyfikacji nic jeszcze nie ma (zob. „Czego potrzebuję od Ciebie”, pkt 6). Po stronie gry zmieniły się tylko dokumenty i instrukcje agentów, wszystkie niezatwierdzone.

### Zadania z dashboardu (`docs/ai-tasks/`)
- Widok **Praca** (`/praca`, tylko tryb lokalny): zadania w etapach (zaplanowane, czeka na decyzję, w pracy, na gałęzi, scalone do domknięcia, czeka na człowieka, sprawdzone albo zamknięte; osobno odrzucone i niespójne), karta **Teraz**, „Do zaplanowania”, limity z planu (otwarte gałęzie 1, buildy do zagrania 2, karty decyzji 5) i pasek stanu trzech repozytoriów (specyfikacja, gra, kopia wdrożeniowa).
- Dashboard nie ma własnej bazy ani pliku stanu. Wszystko jest liczone przy odczycie z dokumentów głównej kopii gry, z gita trzech drzew, z `WDROZENIA.md` i z zapisów przebiegów w `reports/dashboard-runs/` (poza gitem). Rejestrem zadań zostaje `WDROZENIA.md`, bez zmian tabel.
- Strona zadania (`/praca/zadanie/task_NN`): etapy, Twoje wymagania tylko do odczytu, karty decyzji, arkusz, gałąź, werdykt przeglądu, raport agenta, przebiegi i przyciski. Przycisk, którego nie wolno teraz użyć, jest wyszarzony i podaje powód. Tę samą funkcję (`deriveWork`) uruchamia serwer przy żądaniach przebiegów, scalenia, odrzucenia, arkuszy i zapisu dokumentów i odmawia (412) tego, co przycisk ma zamknięte, więc przycisk i serwer nie mogą się rozjechać.
- Operacje bez modelu, na Twoje kliknięcie (zapisy to osobne, podpisane commity obejmujące tylko swoje pliki): nowe zadanie narzędziowe (`/praca/nowe`, Twoje słowa dosłownie), zapis dokumentów gry w historii, zatwierdzenie zmian specyfikacji po lincie bez błędów, scalenie `--no-ff` do master gry (z listą warunków), odrzucenie zadania, wypchnięcie specyfikacji i gry.

### Arkusze człowieka (`docs/human-tasks/`)
- Strefy człowieka mają jedną definicję składniową dla parsera, formularza, strażnika i audytu: kolumny `wynik`, `uwagi`, `ocena`, `twój wybór`, tabele pod nagłówkiem „wypełnia człowiek” albo pod linią `<!-- człowiek -->`, sekcje odpowiedzi i linie `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`. Wpis z „wpis agenta” nie liczy się jako dowód człowieka.
- Formularz arkusza (`/praca/arkusz`): ✅ ❌ 💬 ⏭ z tekstem i uwagami, skala 1–7, pola, wybory i odpowiedzi. Szkic zostaje w przeglądarce, **Zapisz wpisy** robi jeden commit jednego pliku na master gry (autor i committer to wybrana osoba, trailer `Wpisał-Człowiek`, w nagłówku linia `Wyniki człowieka`). **Zgłoś w specyfikacji** przy ❌ i 💬, **Zwolnij z testu** i **Przenieś do done/** (administrator).
- Stan arkusza: czeka, w trakcie, kompletny, zwolniony, zastąpiony, niesprawdzony (historyczny). Arkusze tylko na gałęzi są do odczytu.

### Karty decyzji (specyfikacja)
- Pytania agenta z analizy trafiają na karty D-03 w `zgloszenia/` (Rodzaj: decyzja, opcjonalne `Zadanie: task_NN`, opcjonalna tabela wyboru; wzór: `szablony/decyzja.md`), a nie do `decision-task-NN.md` (stare pliki zostają w `done/` jako historia).
- Limit 5 otwartych kart (ostrzeżenie w dashboardzie i w lincie, `ZA_DUZO_DECYZJI`). Panel **Rozstrzygnij decyzję** nad otwartą kartą wpisuje wybory, linię z Twoim imieniem, status i zatwierdza kartę w specyfikacji po lincie.

### Przebiegi agenta (Opus i Sonnet)
- Rodzaje i domyślne ustawienia (do zmiany w oknie uruchomienia, pamiętane osobno dla rodzaju): planowanie, analiza i przegląd to Opus z effort max (po 15 USD); wdrożenie (50 USD) i poprawki (25 USD) to Sonnet z effort max; domknięcie to Sonnet high (5 USD); próba to Sonnet low (1 USD).
- Przebieg to jedno wywołanie `claude -p` przez lokalny serwer, tylko na Twoje kliknięcie, jeden naraz (blokada `lock.json`). Profil: `--setting-sources project`, `--permission-mode dontAsk`, `--strict-mcp-config`, lista narzędzi i reguły zapisu per rodzaj, kontrakt po polsku, subskrypcja zamiast klucza API. Dziennik na żywo (co sekundę), **Przerwij** (zabija całe drzewo procesów), limity kosztu, tur i czasu, **Wznów z instrukcją**, **Popraw wg przeglądu**, **Zapisz dokumenty z tego przebiegu**.
- Trzy warstwy pilnowania: profil (uprawnienia i reguły zapisu), strażnik PreToolUse `runguard.ts` (strefy człowieka, sekcja Wymagania co do bajta, konserwatywny tokenizer poleceń, git tylko z `-C`, bez merge, rebase, reset, checkout, tag i force) oraz audyt po przebiegu, który porównuje stan trzech repozytoriów przed i po. Naruszenie kończy przebieg statusem „Naruszenie zasad”; nic nie jest cofane automatycznie.
- Przegląd i próba nie zmieniają kodu ani dokumentów (audyt to sprawdza). **Sprawdź agenta** to krótki przebieg próbny, w którym agent ma wykonać jedno polecenie (`git -c`), a strażnik musi je zablokować.

### Usprawnienia dashboardu (audyt)
- P1-1: strażnik żądań `/__spec` (loopback, dokładny Host, Origin, Sec-Fetch-Site, JSON przy zmianach, token sesji `X-Everhorror-Token` na każdy POST i na odczyty pod `/work` i `/runs`, limit treści 8 MiB, no-store i nosniff; Vite bez CORS i z zakazem ramek).
- P1-2: koszyk edytuje tylko jedna karta przeglądarki (Web Locks), a koszyka, którego nie da się odczytać, dashboard nie kasuje (kwarantanna, pobranie z paska ostrzeżenia).
- P1-3: lint porównuje ID z zatwierdzonym HEAD, również domyślnie w CLI (`node dashboard/cli.ts lint`).
- P2-4: **Zatwierdź** (`/praca/zatwierdz`) zatwierdza zmiany specyfikacji (błędy lintu blokują, wypchnięcie jest opcjonalne) oraz zapisuje dokumenty gry. P2-5: nawigacja w grupach „Praca” i „Specyfikacja”, Zespół w stopce, karta „Teraz”, tabela „W zadaniach” w Wdrożeniach. P2-6: karty decyzji z limitem 5. Części P2-1 i P2-2: liczby mnogie po polsku, uczciwsze teksty, brak niejawnego pobierania z sieci. P2-8: dokumenty procesu po stronie specyfikacji.

### Dokumenty procesu
- Specyfikacja (w commitach gałęzi `agent/praca-dashboard`): `WORKFLOW.md`, `README.md`, `09_produkcja.md` (wpis o zastąpieniu §8.3), `szablony/decyzja.md`, `dashboard/README.md`, `dashboard/ARCHITEKTURA.md`.
- Gra (niezatwierdzone w głównej kopii): skille `ai-task` (nowe tryby `review` i `fix`, sekcja „Dashboard runs”), `spec-tasks`, `spec-sync`, agent `convention-reviewer`, `CLAUDE.md` (skrócony blok o zadaniach), `docs/ai-tasks/INFO.md` (dopisek z datą, Twoje zdania bez zmian), `task_template.md`, `docs/human-tasks/INFO.md`, `factcheck_template.md`, `playtest_template.md`, `tools/README.md` i odsyłacz w planie końcowym (§8.3).

### Migracja i zapis tego zadania
- Bez przenoszenia plików: parsery przyjmują dawne formaty (`Requierments`, nagłówek H1 w task_14, korekta w arkuszach 01–07, arkusz 10 z wpisami człowieka, pliki decyzji, kartę decyzji planu). Zgodność sprawdzona na prawdziwych plikach skryptem tylko do odczytu (wyniki i 4 odchylenia: sekcja „Test”).
- Opcjonalny znacznik `<!-- człowiek -->` w PT0 **nie został dopisany**: PT0 nie leży na master gry ani w głównej kopii, tylko na gałęzi `spec/2026-10-26-task14` (dodany w `68de878`). Próba na kopii w katalogu tymczasowym zadziałała (zob. „Czego potrzebuję od Ciebie”, pkt 10).
- Ten plik i arkusz [factcheck-test-15.md](../../human-tasks/done/factcheck-test-15.md) (14 wierszy do oceny) leżą w głównej kopii **niezatwierdzone**. Zapiszesz je przyciskiem „Zapisz w historii gry” (Praca → Zatwierdź): to pierwsze prawdziwe użycie tej funkcji.

### Odłożone świadomie
- Deterministyczne domknięcie zamiast przebiegu agenta; zadania budowania (eksport, zip, tag); SSE zamiast odpytywania; bramki etapów (np. PT0 jako warunek wdrożenia); wdrażanie zadań narzędziowych i czatowych z dashboardu; zbiorcze zwalnianie i zastępowanie arkuszy; podgląd różnic gałęzi na stronie zadania.
- Z audytu: P2-3 (rebase koszyka przy konflikcie), P2-7 (skok do linii), P3 (dostępność, porządki w kodzie, podział paczki), reszta poprawek tekstów P2-2 w Przeglądzie, Pytaniach, ChangeRule, FileView i `suggest.ts`.
- Zawężenie `.claude/settings.json` gry (plan, etap 4) i `--all` dla pełnego zestawu testów w `tools/run_tests.sh`; zasilanie pollera liczbą „czeka na Ciebie”.

## Decyzje i założenia

Projekt wybrany z trzech niezależnych (każdy oceniony pod kątem pracy solo, bezpieczeństwa, ryzyka migracji, kosztu i kompletności). Za bazę posłużył projekt najmniejszej bezpiecznej zmiany, z dołożonymi: konwencjami danych, lokalizacją arkuszy, kartami D-03 i poprawionym strażnikiem (z projektu 2) oraz przeglądem Opusa ze schematem JSON, kontrolą startu, odbieraniem klucza API, oknem uruchomienia i osobną kopią roboczą specyfikacji (z projektu 1). Odrzucono rdzeń projektu 1, czyli katalog `specification/prace` (migracja około 40 plików w trakcie task_14, druga gałąź przy limicie jednej, dziennik „Prace” odłożony w §8.3). Przyjęty podział pracy (Twoje polecenie): analiza i weryfikacja Opus 5.5 Max, zadania kodowania Sonnet 5.5 Max, a przegląd całości robi Opus raz, po wszystkich falach.

Decyzje projektu (numeracja D1–D14 tego projektu różni się od D1–D10 planu):
- **D1.** Zadania zostają w `docs/ai-tasks/` (z `done/`), arkusze w `docs/human-tasks/` (z `done/`), rejestr w `WDROZENIA.md`. Bez bazy i bez nowego pliku stanu. Odrzucone: katalog `specification/prace` i magazyn JSON.
- **D2.** Arkusze człowieka żyją w głównej kopii gry (master), bo tam je wypełniasz, przed scaleniem albo po nim (PT0 gra się na scalonym buildzie 0.5.3). Agent tworzy je niezatwierdzone i nigdy na gałęziach `spec/*`. Każdy zapis z dashboardu to jeden commit jednego pliku, podpisany wybraną osobą, z trailerem `Wpisał-Człowiek` i linią `Wyniki człowieka`. Arkusz znaleziony tylko na gałęzi jest do odczytu. Odrzucone: wyniki na gałęzi, podpisy w komórkach.
- **D3.** Pytania z analizy to karty decyzji D-03 w `specification/zgloszenia/`, a nie `decision-task-NN.md`.
- **D4.** Strefy człowieka są składniowe (jedna funkcja dla parsera, formularza, strażnika i audytu). Agent nie może ich zapisać (hook), naruszenie wykrywa audyt, zapisuje tylko serwer na kliknięcie członka zespołu.
- **D5.** Przebiegi agenta to dzieci `claude -p` lokalnego serwera: kliknięcie, jeden naraz, API na loopbacku z tokenem, wąski profil, dziennik na żywo, przerwanie, limity, audyt i strażnik. Poller bez zmian, nadal tylko powiadamia. To nie jest orkiestrator wielu agentów.
- **D6.** Bez modelu: nowe zadanie, zapis, zwolnienie i zamknięcie arkusza, rozstrzygnięcie karty, zapis dokumentów, commit specyfikacji po lincie, wypchnięcie, scalenie, odrzucenie. Z modelem: planowanie, analiza, wdrożenie, poprawki, przegląd, domknięcie, próba. Domknięcie zostaje przebiegiem agenta, bo wymaga oceny (częściowe 🟡, znaczniki treści).
- **D7.** Opus (effort max): planowanie, analiza, przegląd. Sonnet (effort max): wdrożenie, poprawki. Sonnet high: domknięcie. Sonnet low: próba. Wszystko do zmiany przy uruchomieniu.
- **D8.** Profil przebiegu: `--setting-sources project` (ładuje CLAUDE.md, skille i uprawnienia projektu, nie ładuje wtyczek i hooków użytkownika), `dontAsk`, `--strict-mcp-config`, lista narzędzi, `--settings` per przebieg. Nigdy `--bare`, `--restricted`, `bypassPermissions`. Reguły Bash nie są granicą bezpieczeństwa; granicą są strażnik i audyt.
- **D9.** Agent commituje w specyfikacji jako `[agent] …` po lincie bez błędów, z jawnymi ścieżkami, i może wypychać jej master. Gry nie commituje, nie scala, nie wypycha, nie taguje i nie przełącza w niej gałęzi. Dokumenty gry zostają niezatwierdzone do Twojego kliknięcia. Tożsamość w przebiegach: `Claude (agent) <agent@everhorror.local>`.
- **D10.** Scalenie to deterministyczne `git merge --no-ff` w głównej kopii na Twoje kliknięcie. Warunki: brak plików w poczekalni, brak `MERGE_HEAD`, brak nakładania się zmian głównej kopii z różnicą gałęzi (identyczne niezatwierdzone kopie są usuwane i zgłaszane), czysta kopia wdrożeniowa, zaznaczone „edytor Godota zamknięty”. Push i tag opcjonalne, domknięcie osobnym kliknięciem.
- **D11.** Bezpieczeństwo przed wszystkim innym: strażnik żądań i token (P1-1) wchodzą przed jakimkolwiek punktem, który uruchamia agenta albo scala grę.
- **D12.** W tej rundzie: P1-1, P1-2, P1-3, P2-4, P2-5, P2-6 oraz części P2-1 i P2-2 (zob. „Co zostało zrobione”).
- **D13.** Nazwany konflikt z planem: Twoja prośba z 2026-10-26 zastępuje w tym zakresie §8.3 „Dalszy rozwój dashboardu: wstrzymany”. Bez zmian zostają: „nowy dziennik Prace: odkładamy”, §5 (bez bazy, przebudowy i orkiestratora wielu agentów), jedna otwarta gałąź `spec/*`, scalanie tylko przez Ciebie, pełny zestaw testów tylko za zgodą i brak wypełniania wyników człowieka przez agenta. Zapisane w `09_produkcja.md` i odsyłaczem w planie.
- **D14.** Izolacja pracy: kod specyfikacji w `specification-praca` na gałęzi `agent/praca-dashboard`; agenci kodujący nie commitują, a każdy przyjęty pakiet jest commitowany osobno; włączenie do master specyfikacji (rebase, potem tylko fast-forward) dopiero po weryfikacji, za Twoją zgodą i bez aktywnego przebiegu. To czasowy wyjątek od §8.3 („bez osobnej kopii roboczej specyfikacji”).

Założenia tego zadania:
- Stan git i pliki z chwili pisania (2026-10-27) różnią się od założeń projektu: sesja task_14 przeniosła arkusze 08–13 do `done/` i dodała PT0 w commitach na gałęzi `spec/2026-10-26-task14`, a w głównej kopii pozostał z jej pracy tylko niezatwierdzony `docs/ai-tasks/task_14.md`. Niczego tam nie ruszałem.
- Numer 15: `nextTaskNumber` po `docs/ai-tasks`, `done/` i wierszach „W zadaniach” (task_13 ✅, task_14 🧪) daje 15, a plik, gałąź i wiersz o tym numerze nie istnieją.
- Dokumenty mają końce linii CRLF jak reszta kopii roboczej gry; przy commicie `.gitattributes` (`text=auto eol=lf`) sprowadza je do LF.
- To zadanie narzędziowe bez gałęzi gry i bez wiersza w „W zadaniach” (to plik specyfikacji, nie ruszałem go). Plik leży w `docs/ai-tasks/`, nie w `done/`, więc tablica pokazuje je w etapie „Zaplanowane”, z arkuszem i przyciskiem „Analizuj (agent, Opus)”, którego nie ma po co uruchamiać. Etap „czeka na człowieka” dostanie dopiero po przeniesieniu pliku do `done/` (`git mv`, linki zyskują jedno `../`; tak skill `ai-task` każe postąpić z wdrożonym zadaniem niespecyfikacyjnym).

## Czego potrzebuję od Ciebie

Lista decyzji z projektu. Pozycje 1–7, 10 i 11 przyjęte jako rekomendowane w ramach Twojego stałego polecenia „Reszta też jak rekomendowane” (2026-10-26), do Twojego weta; to nie są Twoje decyzje wprost. Pozycje 8 i 9 czekają na Ciebie.

1. **Zmiany procesu** (rekomendacja: tak): (a) arkusze człowieka żyją tylko w głównej kopii gry (master), nie na gałęziach `spec/*`, a zapis z dashboardu to jeden commit tego pliku podpisany Twoim imieniem; (b) pytania z analizy zadań to karty decyzji w `specification/zgloszenia` (D-03), już nie `decision-task-NN.md`; (c) przebiegi agenta z dashboardu nie commitują ani nie wypychają gry, a dokumenty zadań zapisujesz przyciskiem. *Stan: przyjęte; opisane w skillach i INFO.md (niezatwierdzone w grze).*
2. **Zastąpienie §8.3 planu** („Dalszy rozwój dashboardu: wstrzymany”) Twoją prośbą z 2026-10-26, w tym zakresie. Wpis w `09_produkcja.md` i odsyłacz w planie; dziennik „Prace” nadal odłożony, §5 bez zmian. *Stan: przyjęte; wpis jest w commicie specyfikacji na gałęzi `agent/praca-dashboard`, odsyłacz w planie gry jest niezatwierdzony.*
3. **Domyślne modele przebiegów:** Opus z effort max dla planowania, analizy i przeglądu; Sonnet z effort max dla wdrożenia i poprawek; limity kosztu (szacunek klienta): plan, analiza i przegląd 15 USD, wdrożenie 50, poprawki 25, domknięcie 5. Potwierdzić albo zmienić. *Stan: przyjęte; zmienisz je w oknie uruchomienia.*
4. **Tożsamość agenta** w przebiegach: commity jako „Claude (agent) <agent@everhorror.local>” zamiast wspólnego konta. Rekomendacja: tak, decyzja odwracalna. *Stan: przyjęte.*
5. **Bez `ANTHROPIC_API_KEY`** w przebiegach (subskrypcja); płatne API tylko po `EVERHORROR_ALLOW_API_KEY=1`. *Stan: przyjęte.*
6. **Włączenie nowego dashboardu do master specyfikacji** (po weryfikacji, gdy żaden agent nie pracuje), potem restart `npm start`. *Stan: przyjęte, jeszcze niewykonane. Kod leży na gałęzi `agent/praca-dashboard` w `specification-praca` (HEAD `8093753`); do czasu włączenia zatwierdzanie zmian specyfikacji z tej kopii dashboard odmówi, bo nie jest na master.*
7. **Commit plików procesu po stronie gry** (skille, CLAUDE.md, INFO.md, szablony, `tools/README.md`, odsyłacz w planie) na master gry jako „[agent] proces: …”, dopiero gdy sesja task_14 zatwierdzi swoje zmiany w głównej kopii. Alternatywa: zatwierdzasz je sam. *Stan: przyjęte, jeszcze niewykonane; pliki leżą niezatwierdzone (lista w sekcji „Co zostało zrobione”). Dashboard zatwierdzi z nich tylko zadania i arkusze; `INFO.md`, szablony, skille, `CLAUDE.md` i `tools/README.md` trzeba zatwierdzić w terminalu.*
8. **Hasło administratora w Zespole.** Przyciski przebiegów, scalania i commitów są tylko dla administratora, a dziś hasło jest puste. *Do Twojej decyzji; nie ruszałem.*
9. **Pierwsze płatne kliknięcie** (grosze): „Sprawdź agenta”, test profilu i strażnika. Opcjonalnie później „Przegląd (Opus)” gałęzi task_14, tylko do odczytu (do 15 USD). *Do Twojej decyzji; nie uruchamiałem prawdziwego `claude`. To wiersze 6 i 7 arkusza.*
10. **Znacznik `<!-- człowiek -->` nad tabelą „Raport przebiegu: dołącz plik” w PT0**, żeby nazwy plików dało się wpisać w formularzu (bez niego wpisujesz je w kolumnie Uwagi). *Stan: pominięte, bo PT0 nie jest na master gry (leży tylko na gałęzi `spec/2026-10-26-task14`, niescalonej, z trzema commitami przed master). Próba na kopii w katalogu tymczasowym: znacznik w linii tuż nad tabelą zamienia jej kolumny `Plik .md`, `Plik .json` i `Uwagi` w pola formularza, strefy człowieka zostają nietknięte, a postęp arkusza bez zmian (0/26). Do dopisania po scaleniu task_14, jako jedna linia i osobny commit.*
11. **Scalanie task_14, jeśli PT0 byłby i w głównej kopii, i na gałęzi:** dashboard usunąłby identyczną kopię przed scaleniem, a różne wersje zablokowałyby scalenie z listą plików. *Stan: nie dotyczy teraz, bo w głównej kopii nie ma kopii PT0.*

Do zrobienia po Twojej stronie:
- **Scal task_14** (przycisk „Scal do master gry” na stronie zadania; opcjonalnie wcześniej „Przegląd (agent, Opus)”), żeby tablica Praca przestała pokazywać arkusze 08–13 jako czekające. Ich zastąpienie przez PT0 jest dziś tylko na gałęzi (zob. odchylenia w „Test”).
- **Zapisz oba dokumenty tego zadania** (Praca → Zatwierdź, sekcja „Gra — dokumenty zadań i arkusze”: zaznacz `task_15.md` i `factcheck-test-15.md`, zostaw resztę).
- **Wypełnij [factcheck-test-15.md](../../human-tasks/done/factcheck-test-15.md)** w formularzu arkusza (14 wierszy, ok. 1 h). Potem przenieś `task_15.md` do `done/` (albo poproś agenta) i zamknij arkusz przyciskiem „Przenieś do done/”.

## Test

Wszystko poniżej uruchomiłem sam, 2026-10-27, w kopii roboczej specyfikacji `C:\dev\gamedev\everhorror\specification-praca\dashboard` (gałąź `agent/praca-dashboard`, HEAD `8093753`, drzewo czyste), chyba że napisano inaczej. Wyniki są dosłownymi liniami z wyjścia poleceń. Skrypty pomocnicze (`compat.ts`, `marker-dryrun.ts`, `untouched-check.mjs`) są tymczasowe, leżą poza repozytoriami i niczego w nich nie zapisują, więc przepisałem ich wyniki w całości.

`npm test` (kod wyjścia 0, 64 s):

```
ℹ tests 1553
ℹ suites 16
ℹ pass 1553
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 63406.8612
```

`npm run build` (kod wyjścia 0; `tsc --noEmit` bez błędów, potem `vite build`; ostrzeżenie o rozmiarze paczki jest tylko informacją):

```
> everhorror-spec-dashboard@0.1.0 build
> tsc --noEmit && vite build

vite v8.3.1 building client environment for production...
transforming...
✓ 80 modules transformed.
rendering chunks...
computing gzip size...
dist/index.html                   0.65 kB │ gzip:   0.44 kB
dist/assets/index-I3GsvmAb.css   37.91 kB │ gzip:   7.90 kB
dist/assets/index-C5oJfLLP.js   713.58 kB │ gzip: 222.73 kB

[plugin builtin:vite-reporter] 
(!) Some chunks are larger than 500 kB after minification. Consider:
- Using dynamic import() to code-split the application
- Use build.rolldownOptions.output.codeSplitting to improve chunking: https://rolldown.rs/reference/OutputOptions.codeSplitting
- Adjust chunk size limit for this warning via build.chunkSizeWarningLimit.
✓ built in 177ms
```

`npm run e2e` (kod wyjścia 0, 68 s; pełny przepływ przez prawdziwe API, repozytoria tymczasowe, udawany `claude`, prawdziwy strażnik):

```
ℹ tests 19
ℹ suites 0
ℹ pass 19
ℹ fail 0
ℹ cancelled 0
ℹ skipped 0
ℹ todo 0
ℹ duration_ms 67332.6949
```

`npm run lint-spec` (kod wyjścia 0):

```
> everhorror-spec-dashboard@0.1.0 lint-spec
> node cli.ts lint

Porównanie ID z: HEAD (8093753)
Bez uwag.

0 błędów, 0 uwag.
```

`pwsh -NoProfile -File tools/test_spec_poll.ps1` (w głównej kopii gry, repozytoria tymczasowe, kod wyjścia 0):

```
RESULT: ALL PASSED (poller: DryRun, flags, notification, deduplication, CLI failure, merged-state change)
```

`node tools/check_doc_links.js docs/ai-tasks/task_15.md docs/human-tasks/factcheck-test-15.md` (po utworzeniu obu plików):

```
Document links: 5 file targets, 0 missing, 0 outside workspace (not checked). Fragments/remote URLs not checked.
```

Zgodność z prawdziwymi plikami (`node compat.ts`; skrypt importuje moduły `src/work` z kopii roboczej, czyta wszystkie pliki z `docs/ai-tasks/**` i `docs/human-tasks/**` głównej kopii gry oraz z `zgloszenia/**` żywej specyfikacji, a stan bierze z `GET /__spec/work/state` serwera deweloperskiego na porcie 5191, z tokenem sesji; tylko odczyt). Wynik: 8 z 12 oczekiwań zgodnych, 4 odchylenia (odchylenia dosłownie):

```
- DEVIATION sheets 01-07 niesprawdzony: 01=niesprawdzony, 02=kompletny, 03=niesprawdzony, 04=niesprawdzony, 05=niesprawdzony, 06=niesprawdzony, 07=niesprawdzony
- DEVIATION sheets 08-13 zastapiony: 08=czeka (docs/human-tasks/factcheck-test-08.md), 09=czeka (docs/human-tasks/factcheck-test-09.md), 10=w-trakcie (docs/human-tasks/factcheck-test-10.md), 11=czeka (docs/human-tasks/factcheck-test-11.md), 12=czeka (docs/human-tasks/factcheck-test-12.md), 13=czeka (docs/human-tasks/factcheck-test-13.md)
- DEVIATION factcheck-test-14 czeka 0/25, task task_14: czeka 0/26 task=task_14 [branch only (state.branchDocs)]
- DEVIATION tasks 01-13 history: 01=zamkniete/history, 02=sprawdzone/history, 03=zamkniete/history, 04=zamkniete/history, 05=zamkniete/history, 06=zamkniete/history, 07=zamkniete/history, 08=czeka-na-czlowieka/NOT-history, 09=czeka-na-czlowieka/NOT-history, 10=czeka-na-czlowieka/NOT-history, 11=czeka-na-czlowieka/NOT-history, 12=czeka-na-czlowieka/NOT-history, 13=czeka-na-czlowieka/NOT-history
```

Przyczyny odchyleń. Żadnego kodu nie poprawiałem; każde odchylenie wynika z danych, nie z parserów:
1. **Arkusz 02** jest naprawdę wypełniony przez człowieka (8 wyników „Spoko” i „Ok”, bez wpisów agenta), więc jest „kompletny”. „Niesprawdzone przez człowieka” dotyczy tylko arkuszy 01 i 03–07.
2. **Arkusze 08–13** w głównej kopii (master) leżą w `docs/human-tasks/` jako otwarte, bez nagłówka „zastąpione”. Nagłówki „zastąpione arkuszem PT0” i przeniesienie do `done/` są dopiero w commicie `68de878` na gałęzi `spec/2026-10-26-task14`. Parsowane z drzewa tej gałęzi (`everhorror-wdrozenie`) wszystkie sześć arkuszy to „zastapiony”.
3. **PT0** ma dziś 15 wierszy sprawdzeń i 11 wierszy ankiety, czyli 26 wymaganych wierszy. Projekt zakładał 14 + 11 = 25; wiersz 15 („Ekran końca tygodnia”) doszedł później. Arkusz leży tylko na gałęzi, więc dashboard pokazuje go jako arkusz tylko do odczytu przy task_14.
4. **Zadania 08–13** nie są „historią”, dopóki ich arkusze na master są otwarte (etap „czeka na człowieka”). W symulacji po scaleniu gałęzi task_14 (drzewo gałęzi plus niezatwierdzony `task_14.md`, gałąź oznaczona jako scalona) zadania 01–13 są historią, a task_14 ma etap „scalone” (do domknięcia). Do tego czasu tablica Praca liczy arkusze 08–13 jako buildy do zagrania (limit 2, jest 7).

Znacznik `<!-- człowiek -->` w PT0 sprawdziłem tylko na kopii w katalogu tymczasowym (`node marker-dryrun.ts`: tekst PT0 z gałęzi, znacznik w linii tuż nad tabelą „Raport przebiegu: dołącz plik”; prawdziwego pliku nie ruszałem):

```
last table before: kind=other, human columns=Uwagi
last table after : kind=form, human columns=Plik `.md`:pole | Plik `.json`:pole | Uwagi:pole, rows=1, row keys=1
humanZonesUntouched(before, after): ok=true
required rows unchanged (26 -> 26), parseError after: none
```

Sprawdzenie, że niczego nie zatwierdziłem ani nie ruszyłem poza dwoma nowymi plikami (`node untouched-check.mjs`, porównanie ze stanem sprzed zapisu):

```
master gry: 1c9c5c0 (na początku 1c9c5c0), gałąź spec/2026-10-26-task14: e1ba7ca (na początku e1ba7ca), kopia wdrożeniowa na e1ba7ca; brak nowych commitów
master specyfikacji: d8be04f (na początku d8be04f), agent/praca-dashboard: 8093753 (na początku 8093753)
poczekalnia głównej kopii gry: pusta
kopia robocza specyfikacji (specification-praca): czysta
żywa kopia specyfikacji (specification): czysta
13 niezatwierdzonych plików gry z początku pracy: 13 z 13 ma tę samą sumę SHA-256
git status gry względem początku pracy: nowe wpisy ?? docs/ai-tasks/task_15.md, ?? docs/human-tasks/factcheck-test-15.md; zniknęły: brak
```

Nie uruchamiałem (powody):
- **Prawdziwego `claude -p`** (w tym „Sprawdź agenta” i „Przegląd (Opus)”): płatne, decyzja Rolanda (pkt 9). Testy przebiegów używają udawanego `claude`.
- **Testów w przeglądarce** i sprawdzenia widoku 375 px: to wiersze arkusza factcheck-test-15, które ocenia człowiek.
- **Godota i testów gry** (w tym pełnego zestawu): to zadanie nie zmienia kodu ani zasobów gry, a pełny zestaw wymaga Twojej zgody.
- **Przeglądu końcowego całości przez Opus 5.5 Max**: wg Twojego polecenia robi się go raz, po wszystkich falach. W chwili pisania pierwszej wersji tego raportu jeszcze się nie odbył. Pierwsza runda przeglądu się odbyła, a jej poprawki (Sonnet 5.5 Max) opisuje sekcja „Poprawki po przeglądzie końcowym (runda 1)” niżej; drugi przegląd jeszcze się nie odbył.
- **Włączenia do master specyfikacji i commita czegokolwiek w grze**: poza zakresem tego zadania (pkt 6 i 7).

Arkusz do oceny: [factcheck-test-15.md](../../human-tasks/done/factcheck-test-15.md).

## Poprawki po przeglądzie końcowym (runda 1)

Przegląd końcowy (Opus 5.5 Max, runda 1) znalazł cztery usterki blokujące. Poprawiłem je na gałęzi `agent/praca-dashboard` w `specification-praca` (osobny commit po `8093753`), z testami, które na poprzednim kodzie nie przechodzą, i z opisem w `dashboard/ARCHITEKTURA.md` i `dashboard/README.md`:

1. **Strażnik przepuszczał `git log -m $'--output=<arkusz>'`.** Wyjątek od kontroli rozwinięć dla tekstu `-m` obejmował każde podpolecenie, a w `log`, `show` i `diff` `-m` jest flagą bez wartości, więc następne słowo stawało się opcją `--output=…` i git nadpisywał plik (nieśledzony arkusz byłby stracony). Teraz wyjątek dotyczy tylko `git commit` i tylko słowa, które git rzeczywiście czyta jako tekst `-m`. Przy okazji zamknięte obejście `git commit -m -m "${X:---amend}"`, które przepuszczało `--amend`.
2. **Audyt nie widział arkusza zamkniętego bez człowieka.** Linia w nagłówku („niesprawdzone przez człowieka”, „zastąpione …”, pusta „Zwolnienie:”) albo przemianowanie kolumny „wynik” na „Wynik automatu” nie zmienia żadnej komórki człowieka, więc ani strażnik, ani `HUMAN_ZONE` jej nie widziały, a zadanie z takim arkuszem zamykało się bez sprawdzenia. Snapshot zapisuje teraz stan każdego arkusza gry (`verify`, noty z nagłówka, liczbę pól do wypełnienia i sekcji odpowiedzi, kształt pliku), a audyt zgłasza zmianę jako błąd `SHEET_STATE` (przebieg dostaje status „Naruszenie zasad”). Dodawanie wierszy i sekcji niczego nie zgłasza.
3. **Skill `spec-sync` kazał przenosić zgłoszenia i karty, a strażnik to blokuje.** W przebiegu domknięcia z dashboardu agent zmienia tylko status zgłoszenia (Edit); pliki zostają w `zgloszenia/`, a lista tych do `zgloszenia/zamkniete/` idzie do `NASTĘPNY KROK` i przenosisz je Ty w terminalu. Zmienione: `spec-sync` (krok 1 domknięcia i sekcja „Dashboard runs”) oraz `ai-task` („Dashboard runs”); test strażnika spina oba końce.
4. **Fałszywe naruszenie po przełączeniu kopii wdrożeniowej.** `git switch -c spec/… master` (pierwszy krok wdrożenia) podmienia arkusze kopii wdrożeniowej na wersje z master, a Ty zapisujesz wyniki na master między zadaniami, więc audyt widział w `wt:` „wpisy agenta”. Teraz zmiana w kopii, która się ruszyła, jest pomijana tylko tam, gdzie główna kopia po przebiegu ma tę samą wartość; wartość, której główna kopia nie ma, nadal jest naruszeniem.

Noty w nagłówku arkusza i nazwy kolumn człowieka dopisałem też do reguł agenta: `docs/human-tasks/INFO.md`, skill `ai-task` i `convention-reviewer` (te pliki są, jak reszta dokumentów procesu, niezatwierdzone).

Wyniki po poprawkach (2026-10-27, `specification-praca/dashboard`): `npm test` 1614 testów (było 1553), 0 błędów; `npm run e2e` 21 testów (było 19), 0 błędów, dwa razy z rzędu; `npm run build` i `node dashboard/cli.ts lint` bez uwag. Czeka na drugi przegląd końcowy.

## Podsumowanie

Dashboard specyfikacji prowadzi teraz zadania, arkusze człowieka, karty decyzji i przebiegi agenta z jednego miejsca (widok Praca), bez własnej bazy: stan liczy z dokumentów gry, z gita i z `WDROZENIA.md`. Agent pracuje wyłącznie na Twoje kliknięcie, w wąskim profilu pilnowanym przez strażnika i audyt, a wszystko, co zapisuje człowiek (wyniki, scalenie, commity), robi serwer na Twoje kliknięcie jako podpisany commit jednego pliku. Zabezpieczenia lokalnego API, koszyk, lint względem HEAD, Zatwierdź i nawigacja z kartą „Teraz” to część poprawek dashboardu z audytu.

Sprawdzone przeze mnie (po poprawkach z przeglądu końcowego, runda 1): 1614 testów dashboardu (jednostkowych i na repozytoriach tymczasowych) oraz 21 testów end-to-end przeszło bez błędów, build, lint specyfikacji (0 błędów, 0 uwag) i test pollera też; skrypt zgodności potwierdził 8 z 12 oczekiwań, a 4 odchylenia wynikają z danych, nie z parserów (zob. „Test”). Prawdziwy agent i przeglądarka nie były uruchamiane; to wiersze arkusza i Twoje decyzje 8 i 9.

Stan do przejęcia: kod czeka na gałęzi `agent/praca-dashboard` (pkt 6), dokumenty procesu gry są niezatwierdzone (pkt 7), a PT0 i arkusze 08–13 zmienią się na tablicy dopiero po scaleniu task_14. Oba pliki tego zadania są niezatwierdzone i czekają na pierwszy zapis przyciskiem „Zapisz w historii gry”.
