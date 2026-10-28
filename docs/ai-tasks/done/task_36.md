# task_36: Another dashboard rework

<!--
Zadanie narzędziowe utworzone w dashboardzie (Roland, 2026-10-28). Sekcja „Wymagania” to tekst Rolanda; nie edytować. Zasady: INFO.md.
-->

Wymagania:
"Now" section in dashboard needs improvements. Since it's constantly changing and switching, it is annyoing. I want kanban board trello-like dynamic dashboard that is showing what is running or what needs to be run. I want tasks that I can send for analysys, implementatiaon and other steps in bulk or single, now only some can be send in bulk.

This dropdown list for tasks that I pick and then start is ridicolus. There should be just a list of those tasks with some oneliner description and task number and a checkbox, I checkbox tasks then press "Run" but there should be a pre-done crosscheck which tasks could be done in parallel. 
There should be a checkbox like "select all (parallel)" that just allows me to select checkbox of tasks that can run together. 

Things are appearing and disappearing in "Now" section, so as I said, I want kanban board like I described, and maybe lets split this "Now" section in like 2 or 3 panels horiznontal. Design it with Opus High. 

I want this all changes to be done as one task.

Rodzaj: narzędzia · Zleca: Roland (dashboard, 2026-10-28)
Poziom: narzędzia

Kontekst:
I still have hard time to see what we doing, what is going on in dev in "Work" section.

Kryteria akceptacji:
Work section contains clear and well design view of kanban board where I see flow of the tasks.

Work section allows for single or bulk operation on tasks.

Work section shows what can or can't be done in parallel.

Work section allows for adding new game dev task along the new tooling tasks. 

Dashboard default models to medium effort.

Priorytet: wysoki

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza

Stan kodu dashboardu: `specification/dashboard/` (ścieżki niżej względem tego folderu), stan na żywo: `reports/dashboard-runs/` gry, 2026-10-28. Zadanie nie ma linii `Kolejność:`; żadne otwarte zadanie nie zmienia dziś `dashboard/` (task_22 dotyka tylko `.claude/`).

### Jak to działa dziś

**Zakładka Teraz** (`src/views/Work.tsx:1168–1175`): pasek stanu, liczniki limitów, karta „Teraz” (`NowCard`), karta „Łańcuch zadania” (`ChainsCard`) i „Do zaplanowania”. Tablica kanban już istnieje, ale na zakładce Zadania (`Work.tsx:799–806`, `939–989`): sześć kolumn etapów z `STAGE_INFO` (`src/work/derive.ts:54`), karta bez przycisków, do 6 kart w kolumnie. Nie pokazuje, co trwa, co stoi w kolejce ani co robi łańcuch.

**Skąd biorą się wiersze „Teraz”.** `nextList()` (`src/work/derive.ts:1784–1926`) przy każdym odczycie układa od zera listę *kroków* (akcji), nie zadań: (1) wpis na każdy trwający przebieg i build, (2) naruszenie, (3) decyzje, …, (10) „Analizuj/Wdróż” zaplanowanych, (11) planowanie, (12) tylko gdy lista jest pusta: notatki o otwartych gałęziach. Potem `planNow()` (`src/work/now.ts:63`) sortuje po rodzaju, składa trzy i więcej takich samych kroków w jeden wiersz (`GROUP_FROM = 3`, `:13`) i pokazuje pięć (`NOW_LIMIT = 5`, `:10`). Gdy trwa przebieg, stan jest czytany co 4 s (`src/data/work.ts:63`), w spoczynku co 45 s.

**Dlaczego rzeczy pojawiają się i znikają** (konkretnie):
1. Krok znika, gdy rusza przebieg: „Analizuj zadanie” task_26 zamyka bramka `startGate` i `open()` go odfiltrowuje, a w innym miejscu (rodzaj `notice`, na dole) pojawia się „Trwa: analiza task_26 · 3 min”. Po końcu przebiegu ten wpis znika, a gdzie indziej pojawia się „Wdróż na gałęzi” albo „Wznów”.
2. Składanie: trzy analizy to jeden wiersz „3× Analizuj zadanie”; gdy jedna ruszy, wiersz rozpada się na dwa osobne.
3. Limit pięciu wierszy: nowa decyzja na górze wypycha ostatni wiersz pod „Pokaż wszystkie”.
4. Krok 12 działa tylko przy pustej liście, więc notatki o gałęziach pojawiają się i znikają zależnie od tego, czy na liście jest coś innego.
5. Zadanie w kolejce startów albo w łańcuchu dalej pokazuje „Analizuj zadanie (agent)” jako krok do kliknięcia (akcje zadania nie znają kolejki; `derive.ts` czyta kolejkę tylko w `queueAnalyzeAction`, `:1666`), a potem nagle znika, gdy kolejka je uruchomi.
6. Dopisek „· 12 min” zmienia się co minutę i zmienia szerokość wiersza.

Sedno: „Teraz” to ranking następnych kroków liczony od nowa przy każdym odczycie. Nic na ekranie nie ma stałej tożsamości, więc każda zmiana stanu wygląda jak zniknięcie jednego wiersza i pojawienie się innego.

**Start łańcucha** (`src/views/Chain.tsx:122–183`): `<select>` z pozycjami `task_NN — tytuł` (`:153`), jedno zadanie na kliknięcie i jedno wspólne pole „pliki są rozłączne” (`:168`), zaznaczane bez żadnej informacji. W `chains.json` widać skutek: 2026-10-28 między 05:37:33 a 05:37:59 Roland uruchomił po kolei cztery łańcuchy (task_18, 20, 21, 22), każdy z `acknowledgeOverlap: true`, czyli bez sprawdzenia plików.

**Operacje zbiorcze dziś.** Jest tylko „Analizuj wszystkie zaplanowane” (`derive.ts:1666`, okno `BulkAnalyzeDialog` w `src/views/Automation.tsx:187`): pola wyboru z samymi numerami zadań, wszystko idzie do kolejki. Serwer umie więcej: `POST /work/queue/add` przyjmuje do 50 pozycji dowolnego rodzaju (analiza, wdrożenie, poprawki, przegląd kodu, domknięcie, planowanie) i zwraca `added`/`failed` per pozycja (`node/queue.ts:242`, `node/work-api.ts:1272`). Łańcuch: `POST /work/chain` bierze jedno zadanie (`work-api.ts:1347`, `node/chain.ts:134`).

**Sprawdzenie równoległości dziś** (`src/work/parallel.ts`): `startConflict()` (to samo zadanie, ta sama gałąź, pełna klasa), `overlapCheck()` (pliki z `Pliki:` zadania albo z planu; nieznane liczą się jako wspólne; `git merge-tree` rozstrzyga, gdy obie gałęzie istnieją), limity D-33 (`DEFAULT_RUN_LIMITS`: 3 analizy i przeglądy, 3 wdrożenia i poprawki, po 1 planowanie, domknięcie, próba) i limit 3 otwartych gałęzi (`LIMITS.openBranches`, `derive.ts:87`). Wszystko to sprawdza *jeden* przebieg względem *trwających*; kandydatów między sobą nikt nie porównuje. Kolejka przy dodawaniu odmawia wdrożenia, które pokrywa się z pozycją wyżej, chyba że jest zgoda (`node/queue.ts:205–219`). Nie umie „poczekać, aż tamto się skończy”, choć przy samym starcie (`attempt`, `:313–331`) takie czekanie już działa.

**Okno startu i modele.** `RunDialog` (`src/views/Runs.tsx:696`) z polami z `runFields.tsx`; domyślne w `RUN_KINDS` (`src/work/runs.ts:544–645`): planowanie, analiza i przegląd kodu opus/medium; wdrożenie i poprawki sonnet/**high** (`:575`, `:587`); domknięcie haiku/**max**; próba haiku/low. Krótki przebieg po karcie decyzji: sonnet/**high** (`src/work/decisionnote.ts:180`). Okno pamięta ustawienia per rodzaj w przeglądarce razem z wersją domyślnych (`src/work/runprefs.ts`, `defaultsVersion`): zmiana domyślnych kasuje zapamiętane ustawienia tego rodzaju i mówi to jednym zdaniem. Analiza ma jednak medium już w kodzie, więc zapamiętane „max” zostaje; ostatnia analiza tego zadania (20261028-065208-analyze-36) ruszyła z `effort: max`. Łańcuch i kolejka biorą domyślne z kodu. `RunBrief` (`src/work/runindex.ts:51`) nie niesie modelu ani wysiłku, więc karta zadania nie ma skąd ich pokazać.

**Nowe zadanie.** „Nowe zadanie narzędziowe” (`/praca/nowe`, `src/views/NewTask.tsx:22`) zna tylko `narzędzia` i `dokumentacja` i tak ma zostać: zmiana gry zaczyna się w specyfikacji jako zasada ⬜ (CLAUDE.md „Hard rules”, INFO.md). Dashboard ma już drogę „nowa zasada”: `/zmien/nowa?plik=…` (`src/views/ChangeRule.tsx`, wejście tylko z `FileView.tsx:257`) dopisuje zasadę z kolejnym ID do koszyka; dalej Zmiany → „Zapisz na dysk” → „Zatwierdź zmiany” → „Zaplanuj zadania (agent)”. Z Pracy tej drogi nie widać. Zgłoszenie „pomysł” nie jest wyjściem: `/spec-tasks` robi zadania tylko ze zgłoszeń „błąd” i „zmiana tekstu”.

### Braki z punktu widzenia Rolanda
- Nie widać przepływu: Teraz to lista kroków, a tablica etapów leży na innej zakładce i nie mówi, co trwa i co czeka w kolejce.
- Zbiorczo da się tylko analizować; wdrożenie, przegląd kodu, poprawki, domknięcie i łańcuch idą po jednym.
- Lista rozwijana zamiast listy zadań z opisem; nic nie mówi, co może iść razem i dlaczego.
- Brak wejścia „zmiana w grze” obok „zadania narzędziowego”.
- Domyślny wysiłek nie jest wszędzie medium, a zapamiętane ustawienia mogą go po cichu przebić.

### Ryzyka i ograniczenia
- **To zadanie wdraża się w terminalu**, nie przebiegiem z dashboardu: `docs/agent/run-rules.md` blokuje zapis w `<spec>/dashboard/` także w profilu „narzędzia”. „Przeprowadź zadanie” dla task_36 zatrzymałby strażnik przy wdrożeniu; drogą jest ramka „Wdróż w terminalu” na stronie zadania.
- **Prawdziwe dane: równoległych wdrożeń gry będzie mało.** Prawie każde otwarte zadanie gry (task_26–29, 31–35) ma w swojej linii plików `tools/unit_test.gd` albo `docs/agent/README.md`, a task_26, 27, 28, 30, 32 i 33 także `script/game_state.gd`. Sprawdzenie powie więc uczciwie: wdrożenia jedno po drugim, analizy trzy naraz (analizy nie porównują plików). To skutek zakresów zadań, nie błąd widoku.
- Parser zakresu nie zna rozszerzeń `.tsx` i `.css` (`src/work/parallel.ts:108`, `src/work/chain.ts:176`): dla zadań dashboardu, jak to, zakres wychodzi niepełny.
- `Kolejność:` to wolny tekst; `dependsOn` bierze z niego każde `task_NN` (`src/work/tasks.ts:275–279`), także z „niezależne od task_16–19” (task_20). Zależność może być tylko ostrzeżeniem i wykluczeniem z zestawu równoległego, nie twardą blokadą.
- API: nowa trasa i tryb kolejki „po kolei” dokładają pole w pliku kolejki; stary plik musi się czytać bez zmian.
- Zgody: zamiast jednej zgody „pliki rozłączne” na cały łańcuch będzie zgoda per para zadań; to zmienia zachowanie, które Roland zna.
- Sekret administratora: start przebiegu, kolejka i łańcuch wymagają osoby z `admin`, ale nie sekretu (`ADMIN_SECRET_ROUTES`, `node/work-api.ts:185`); start zbiorczy ma te same zasady.
- Strona Start, polecenie `cli.ts teraz` i licznik przy „Praca” czytają `WorkView.next`; muszą działać dalej.
- i18n: nowe napisy przez `t()`; test `i18n.test.ts` pada na kluczu nieużywanym, więc stare klucze karty „Teraz” na Pracy, formularza łańcucha i okna analiz zbiorczych trzeba usunąć razem z kodem.
- e2e startuje prawdziwy serwer z udawanym claude (`node/e2e/automation.e2e.ts`); scenariusz zbiorczy czeka na miejsca, więc jest dłuższy.
- D-33 bez zmian: widok pokazuje i stosuje limity, nie zmienia ich.

## Plan

Plan zależy od wyboru: nie

**Układ docelowy zakładki Teraz** (pod cienkim paskiem stanu, trzy poziome panele na całą szerokość, jeden pod drugim):
1. **Czeka na Ciebie**: kroki, które robi tylko Roland (decyzje, zatrzymane łańcuchy, arkusze, scalenia, nieudane starty z kolejki, naruszenia, zapisy i wypchnięcia).
2. **Tablica zadań**: kanban Do zrobienia → W toku → Na gałęzi → Scalone → Zrobione.
3. **Uruchom zadania**: lista z polami wyboru, sprawdzeniem równoległości i przyciskiem „Uruchom zaznaczone”.

Wzorce: tablice Trello, Linear i GitHub Projects (stałe kolumny, karta z tożsamością, limit pracy w toku w nagłówku kolumny jako `n/3`, tory według rodzaju), pasek zaznaczenia z Gmaila i Lineara (pojawia się przy pierwszym zaznaczeniu, Shift+klik zaznacza zakres), wyciszone wiersze z powodem w wierszu i w podpowiedzi.

### A. Model tablicy (czysty moduł `dashboard/src/work/board.ts`)
1. `boardOf(view, state)` → kolumny, karty i kroki osoby. Jedna karta na zadanie, klucz = `task_NN`: karta przechodzi między kolumnami, nigdy nie znika z tablicy, dopóki zadanie nie jest zrobione. Kolumny są zawsze te same i zawsze widoczne (puste też):
   - **Do zrobienia** (📋): etapy „Zaplanowane” i „Czeka na decyzję”; na górze kolumny blok „Do zaplanowania” (liczba zmian ⬜ i zgłoszeń od ostatniego planowania, przycisk „Zaplanuj zadania (agent)”).
   - **W toku** (🔧): zadanie z trwającym przebiegiem, buildem albo testami serwera (grupa „Trwa”) oraz z pozycją w kolejce startów albo łańcuchem, który czeka na kolejkę (grupa „W kolejce”, z miejscem i powodem). Nagłówek: „Analizy i przeglądy kodu 2/3 · Wdrożenia i poprawki 1/3” (z `runLimits`).
   - **Na gałęzi** (🧪): etap „W pracy” bez przebiegu i etap „Na gałęzi”; nagłówek „Otwarte gałęzie 2/3 · buildy do ogrania 1/2”.
   - **Scalone** (⇢): czeka na domknięcie.
   - **Zrobione** (🟢): etapy końcowe bez `history`, zwinięte do liczby z „Pokaż”.
   Pierwszeństwo: trwa > w kolejce > etap. „Niespójne” zostaje banerem jak dziś.
2. Karta zwinięta ma zawsze trzy linie i stałą wysokość: `task_NN` · rodzaj i poziom · ikona etapu; tytuł w jednej linii (ucięty, cały w podpowiedzi); linia stanu w jednej z form: „🔧 Analiza · opus · medium · 12 min”, „⏳ W kolejce (2.): miejsca analiz 3/3”, „⛓ Łańcuch: wdrożenie”, „✋ Łańcuch zatrzymany: ryzyko wysokie”, „Następny krok: Wdróż na gałęzi (agent)”, „⚠ Testy czerwone”. Plakietka „✋ Twój ruch”, gdy zadanie ma krok w panelu „Czeka na Ciebie” (karta zostaje w swojej kolumnie przepływu). Rozwinięcie jak dziś (pamiętane per zadanie): identyfikatory, arkusz, gałąź, konflikty, decyzje i jeden przycisk kroku (`TaskCardActions`). Numer i tytuł prowadzą na stronę zadania.
3. Kroki osoby: wpisy `WorkView.next`, dla których `needsYou()` (z dashboard/src/work/nowlist.ts) albo zapis i wypchnięcie; bez składania, bez limitu pięciu, w stałej kolejności: rodzaj (decyzje, kroki osoby, zapisy) → numer zadania → plik. „Robię sam” zostaje.
4. `RunBrief` dostaje `model` i `effort` z ustawień przebiegu (`dashboard/src/work/runindex.ts`, `dashboard/src/work/model.ts`), żeby karta pokazała, z czym przebieg naprawdę trwa.
5. `boardMoves(prev, next)`: lista przejść („task_26: Do zrobienia → W toku (analiza)”) dla regionu `aria-live` i krótkiego podświetlenia karty.
6. Poprawka w `nextList()` (`dashboard/src/work/derive.ts`, krok 10): zadanie w kolejce startów albo w trwającym łańcuchu nie jest proponowane jako „Analizuj/Wdróż”, więc Start i `cli.ts teraz` przestają pokazywać krok, który już zlecono. `WorkView.next` zostaje dla Startu, licznika i CLI.

### B. Sprawdzenie równoległości (czysty moduł `dashboard/src/work/parallelplan.ts`)
7. Wejście: elementy widoku, trwające przebiegi z zakresami, kolejka, łańcuchy, `runLimits`, limit otwartych gałęzi, sondy `git merge-tree` ze stanu, wybrany krok: `next` (następny krok agenta każdego zadania), `analyze`, `implement`, `review`, `fix`, `finalize` albo `chain`.
8. Wynik per zadanie: stan `teraz`, `kolejka` albo `zablokowane`, powody i ostrzeżenia jako opisy `msg()` (tłumaczy je widok) oraz graf zgodności par z powodem niezgodności. Reguły:
   - **zablokowane**: brak akcji tego rodzaju albo akcja zamknięta z powodem, który sam nie minie (administrator, brak agenta, niezatwierdzona specyfikacja, otwarta karta, etap), ta sama pozycja już w kolejce, łańcuch już trwa (dla `chain`), zadanie z ramką „Wdróż w terminalu”; zawsze tym samym zdaniem co przy przycisku;
   - **kolejka**: pełna klasa D-33, przebieg na tym zadaniu albo gałęzi, limit 3 otwartych gałęzi przy nowym wdrożeniu, wspólne pliki z trwającym przebiegiem (ruszy po nim);
   - **niezgodne parami**: dwa przebiegi kodu (wdrożenie, poprawki, a także łańcuch, bo dojdzie do wdrożenia) na wspólnych plikach albo z nieznanym zakresem (chyba że `merge-tree` mówi „czysto”), prawdziwy konflikt z `merge-tree`, zależność z `Kolejność:`, gdy oba zadania są zaznaczone i poprzednik nie jest wdrożony;
   - **ostrzeżenia bez blokady**: zależność od niewdrożonego zadania spoza zaznaczenia, `Ryzyko: wysokie` (łańcuch zatrzyma się po analizie), limit buildów do ogrania.
9. `maximalParallelSet(plan)`: zachłannie w kolejności numerów zadań bierze zadanie w stanie `teraz`, gdy jest zgodne ze wszystkimi już wziętymi i ma wolne miejsce w swojej klasie (limit − trwające − już wzięte) i w limicie gałęzi. Zbiór jest maksymalny (nic więcej nie da się dołożyć), choć nie zawsze największy możliwy; za to przewidywalny i taki sam przy każdym odświeżeniu.
10. `selectionCheck(plan, zaznaczone)`: co ruszy od razu, co pójdzie do kolejki i za czym czeka (z powodem), które pary wymagają zgody, gdy Roland ręcznie zaznaczy niezgodne zadania.
11. Parser zakresu: rozszerzenia `tsx` i `css` w `dashboard/src/work/parallel.ts` i `dashboard/src/work/chain.ts` (jedna wspólna stała zamiast dwóch list).

### C. Interfejs
12. `dashboard/src/views/Work.tsx`: zakładka Teraz = pasek stanu + trzy panele. Zakładka Zadania traci starą tablicę etapów (jedna tablica, UI.md zasada 2) i zostaje z arkuszami bez zadania, buildami do ogrania, historią i pełną kartą „Do zaplanowania”; lista łańcuchów (`ChainsCard` bez formularza) przechodzi na Automat. Strona Start bez zmian, z linkiem „Otwórz tablicę zadań →”.
13. Panel „Czeka na Ciebie (N)” w `dashboard/src/views/Board.tsx`: karty kroków w rzędzie z zawijaniem, każda z jednym przyciskiem. Ponad dwa rzędy: panel przewija się sam, żeby tablica pod nim nie skakała. Pusty: „Nic nie czeka na Twój ruch. Tablica niżej pokazuje, co robi agent.”
14. Panel „Tablica zadań” w `dashboard/src/views/Board.tsx` (style w `dashboard/src/views/work.css`, tokeny kolorów z `styles.css`, bez nowych zależności): pięć kolumn o stałych proporcjach (na wąskim ekranie przewijanie w poziomie zamiast przeskoku), zarezerwowana minimalna wysokość kolumny, stała wysokość zwiniętych kart, czas cyframi o stałej szerokości (`tabular-nums`), więc start przebiegu nie przesuwa układu. Kolumna z ponad 6 kartami: „Pokaż wszystkie (N)” jak dziś. Opcjonalny przełącznik „Grupuj: rodzaj zadania” (tory „Rozgrywka” i „Narzędzia i tekst”, pamiętany w przeglądarce, domyślnie wyłączony). Region `aria-live` (uprzejmy) czyta przejścia kart; karta, która zmieniła kolumnę, jest podświetlona przez 2 s (bez ruchu przy `prefers-reduced-motion`). Kolumny to sekcje z nagłówkiem, karty to elementy listy z linkami; fokus widoczny.
15. Panel „Uruchom zadania” w `dashboard/src/views/RunList.tsx`, zamiast listy rozwijanej łańcucha i okna „Analizuj wszystkie zaplanowane”:
   - u góry „Krok:” jako przełączniki z `aria-pressed`: Następny krok · Analiza · Wdrożenie · Przegląd kodu · Poprawki · Domknięcie · Przeprowadź zadanie;
   - tabela: pole wyboru · `task_NN` (link) · tytuł w jednej linii (cały w podpowiedzi) · etap · krok, który ruszy, z cichym dopiskiem „sonnet · medium” · pliki („6 plików · ryzyko średnie”, lista w podpowiedzi) · wynik sprawdzenia: „✓ Może ruszyć teraz”, „⏳ Pójdzie do kolejki: wdrożenia 3/3”, „✕ Nie razem z task_26: script/game_state.gd, tools/unit_test.gd” (gdy task_26 jest zaznaczone), „— Niedostępne: karta decyzji otwarta”;
   - wiersz zablokowany jest wyciszony, pole wyboru wyłączone, powód stoi w wierszu (kolor wyciszony, UI.md zasada 5) i w podpowiedzi;
   - w nagłówku tabeli pole „Zaznacz wszystkie równoległe” (trzy stany): zaznacza dokładnie `maximalParallelSet`, drugie kliknięcie odznacza wszystko; Shift+klik zaznacza zakres; Spacja działa na polu;
   - pasek zaznaczenia w zarezerwowanym miejscu nad tabelą (nic się nie przesuwa i nic nie zasłania fokusu): przy zerze „Zaznacz zadania, żeby uruchomić je razem.”, przy co najmniej jednym „3 zaznaczone · 2 ruszą od razu · 1 do kolejki” + „Uruchom zaznaczone (3)” + „Wyczyść zaznaczenie”;
   - zmiana kroku przelicza listę i zdejmuje zaznaczenie z wierszy, które przestały się nadawać (komunikat `role="status"`).
16. „Uruchom zaznaczone” otwiera okno `dashboard/src/views/BulkRunDialog.tsx` (uogólnione `BulkAnalyzeDialog`): zadania z wynikiem („rusza teraz”, „czeka w kolejce za task_26”), ustawienia (jeden rodzaj: pola modelu i wysiłku jak w `RunDialog`; „Następny krok” z kilkoma rodzajami: jedna linia na rodzaj, np. „analiza: opus · medium”, zapamiętane albo domyślne), „Edytor Godota nie jest otwarty na kopiach gałęzi” (gdy któryś krok tego wymaga), zgoda per para tylko dla niezgodnych par zaznaczonych ręcznie („Potwierdzam, że task_27 i task_28 mogą pracować na wspólnych plikach”; bez zgody druga pozycja czeka na pierwszą), uwagi dla agenta, przyciski „Uruchom (3)” i „Anuluj”. Wynik na pasku powiadomień: „Dodano 3: 2 ruszyły, 1 czeka w kolejce” plus odmowy z powodami (UI.md zasada 7).
17. Pojedynczo: jeden zaznaczony wiersz działa tak samo. Przycisk na rozwiniętej karcie i na stronie zadania zostaje (zwykłe okno startu, także „Wznów”).
18. Nowe zadanie: w nagłówku Pracy przycisk „Dodaj zadanie” rozwija dwa wejścia:
   - **„Zadanie narzędziowe”** → `/praca/nowe` bez zmian (narzędzia, dokumentacja);
   - **„Zmiana w grze”** → `/praca/nowa-zmiana-gry` (`dashboard/src/views/NewGameChange.tsx`), trzy kroki na jednym ekranie: (1) wybór pliku specyfikacji z zasadami, pogrupowany jak menu (Mechaniki, Postacie, Świat, Treść…), z wyszukiwaniem; (2) „Napisz zasadę ⬜” otwiera istniejący edytor nowej zasady ze znacznikiem ⬜ ustawionym z góry i powrotem na Pracę (`dashboard/src/views/ChangeRule.tsx`: parametry `znacznik` i `wroc`); (3) dalsza droga opisana i widoczna na tablicy: „Zapisz na dysk” i „Zatwierdź zmiany” (Ty) → „Zaplanuj zadania (agent)” w bloku „Do zaplanowania” → karta `task_NN` w „Do zrobienia”.
   Tak formularz spełnia zasadę „każda zmiana gry zaczyna się w specyfikacji”: dashboard nie tworzy pliku zadania gry, tylko pomaga Rolandowi napisać jego własną zasadę ⬜, którą on zatwierdza; zadanie z linią `Źródło: specyfikacja` robi dopiero planowanie. Serwer dalej odmawia `kind: rozgrywka` w `POST /work/new-task` (test).

### D. Serwer
19. Nowa trasa `POST /work/batch` w `dashboard/node/work-api.ts`: kind, lista zadań (1–20), ustawienia, zgoda na edytor, lista potwierdzonych par, uwagi, who. Kolejno: `requireAdmin` (jak start przebiegu, kolejka i łańcuch; bez sekretu, bo startów nie ma na liście `ADMIN_SECRET_ROUTES`), widok z `deriveWork`, te same funkcje `parallelPlan` i `selectionCheck` co w widoku. Zablokowane zadania trafiają do `failed` tym samym zdaniem, które pokazuje widok; reszta w kolejności numerów: rodzaje przebiegów do kolejki startów, `chain` do startu łańcucha dla każdego zadania. Odpowiedź: dodane (z „rusza teraz” albo „czeka na …”) i odmowy z powodem. Pusta lista albo zły rodzaj: 400.
20. Kolejka „po kolei” (`dashboard/node/queue.ts`, `dashboard/src/work/queue.ts`, typ pozycji w `dashboard/src/work/automation.ts`): nowe pole pozycji `serial`. Pozycja kodu, która pokrywa się z pozycją wyżej albo z trwającym przebiegiem i nie ma zgody, nie jest odrzucana przy dodawaniu, tylko czeka, aż tamta ruszy i się skończy (to, co start w kolejce i tak już robi); powód „czeka na task_26 (wspólne pliki)”. „Dodaj do kolejki” z okna startu działa jak dotąd. Stary plik kolejki bez nowego pola czyta się jak dotąd.
21. Łańcuch dla wielu zadań (`dashboard/node/chain.ts`): start dostaje zadania, na które ma czekać przy wdrożeniu (pozycja `serial`), zamiast jednej zgody na wszystko; zgoda na wspólne pliki tylko dla par, które Roland potwierdził. `POST /work/chain` zostaje dla jednego zadania i „Kontynuuj”.
22. Idempotencja: ta sama para rodzaj + zadanie w kolejce albo trwający łańcuch to odmowa tego jednego zadania („jest już w kolejce”), nie błąd całej partii; przycisk jest wyłączony na czas wysyłania; ponowne wysłanie tej samej partii niczego nie podwaja.
23. Dziennik automatyki: jeden wpis o partii (ile dodano, ile odmów) w „Dashboard zrobił sam”.

### E. Domyślny wysiłek: medium
24. `dashboard/src/work/runs.ts`: wysiłek medium dla każdego rodzaju przebiegu (dziś wdrożenie i poprawki high, domknięcie max, próba low); modele, budżety i tury bez zmian. `dashboard/src/work/decisionnote.ts`: krótki przebieg po karcie sonnet/medium.
25. Zapamiętane ustawienia nie przebiją nowego domyślnego po cichu: `defaultsVersion` w `dashboard/src/work/runprefs.ts` dostaje stałą epoki ustawień (2026-10-28), więc wszystkie zapamiętane ustawienia (także „max” analizy) są raz pominięte, a okno mówi to istniejącym zdaniem o pominiętych ustawieniach sprzed zmiany domyślnych. Pozycje już stojące w kolejce zostają przy swoich ustawieniach (kolejka jest dziś pusta). Łańcuch i kolejka biorą domyślne z kodu, więc od razu medium.

### F. Napisy (PL źródło, EN od razu, bo to codzienna ścieżka; UI.md rozdz. 3)
26. Przestrzenie `workui` (widoki) i `work` (opisy `msg()` z modułów tablicy i sprawdzenia), wszystko przez `t()`, liczby przez formy mnogie:

| Klucz | PL | EN |
|---|---|---|
| `workui.panel.you` | Czeka na Ciebie ({count}) | Waiting for you ({count}) |
| `workui.panel.youEmpty` | Nic nie czeka na Twój ruch. Tablica niżej pokazuje, co robi agent. | Nothing is waiting for you. The board below shows what the agent is doing. |
| `workui.board.title` | Tablica zadań | Task board |
| `workui.board.col.todo` | Do zrobienia | To do |
| `workui.board.col.doing` | W toku | In progress |
| `workui.board.col.branch` | Na gałęzi | On a branch |
| `workui.board.col.merged` | Scalone | Merged |
| `workui.board.col.done` | Zrobione | Done |
| `workui.board.group.running` | Trwa | Running |
| `workui.board.group.queued` | W kolejce | Queued |
| `workui.board.yourMove` | Twój ruch | Your move |
| `workui.board.moved` | {task}: {from} → {to} | {task}: {from} → {to} |
| `workui.run.title` | Uruchom zadania | Run tasks |
| `workui.run.step` | Krok: | Step: |
| `workui.run.stepNext` | Następny krok | Next step |
| `workui.run.selectParallel` | Zaznacz wszystkie równoległe | Select all (parallel) |
| `workui.run.hintNone` | Zaznacz zadania, żeby uruchomić je razem. | Select tasks to run them together. |
| `workui.run.summary` | {count} zaznaczone · {now} ruszą od razu · {queued} do kolejki (formy mnogie) | {count} selected · {now} start now · {queued} queued |
| `workui.run.submit` | Uruchom zaznaczone ({count}) | Run selected ({count}) |
| `workui.run.clear` | Wyczyść zaznaczenie | Clear the selection |
| `work.parallel.now` | Może ruszyć teraz | Can start now |
| `work.parallel.queue` | Pójdzie do kolejki: {reason} | Goes to the queue: {reason} |
| `work.parallel.notWith` | Nie razem z {task}: {files} | Not together with {task}: {files} |
| `work.parallel.unknownFiles` | Nie razem z {task}: pliki nieznane (brak linii „Pliki:”) | Not together with {task}: files unknown (no "Pliki:" line) |
| `work.parallel.order` | Nie razem z {task}: kolejność z pliku zadania | Not together with {task}: order from the task file |
| `workui.newTask.button` | Dodaj zadanie | Add a task |
| `workui.newTask.tool` | Zadanie narzędziowe | Tooling task |
| `workui.newTask.game` | Zmiana w grze | Change in the game |
| `newtask.game.intro` | Zmiana w grze zaczyna się w specyfikacji: napisz zasadę ⬜, zatwierdź ją, a planowanie zrobi z niej zadanie. | A change in the game starts in the specification: write a ⬜ rule, commit it, and planning turns it into a task. |
| `newtask.game.write` | Napisz zasadę ⬜ | Write a ⬜ rule |

Stare klucze karty „Teraz” na Pracy, formularza łańcucha i okna „Analizuj wszystkie zaplanowane” znikają razem z kodem.

### G. Testy
27. Jednostkowe (`node --test`):
   - `dashboard/src/work/board.test.ts`: kolumna z pierwszeństwem (trwa > kolejka > etap), stały klucz karty, ten sam zbiór kart przed i po starcie przebiegu (karta tylko zmienia kolumnę), przejścia `boardMoves`, kolejność kroków osoby bez składania i limitu, plakietka „Twój ruch”.
   - `dashboard/src/work/parallelplan.test.ts` na zakresach task_26–35 (dane testowe z ich linii plików): wdrożenia — zestaw równoległy to samo task_26, a powody „Nie razem z…” wymieniają pliki; analizy — trzy „teraz”, reszta „kolejka”; nieznany zakres i czysty `merge-tree` = zgodne; zależność w zaznaczeniu = niezgodne; limit gałęzi 3/3; zadanie „w terminalu” zablokowane; `selectionCheck` przy ręcznym zaznaczeniu niezgodnych.
   - `dashboard/src/work/parallel.test.ts` i `dashboard/src/work/chain.test.ts`: pliki `.tsx` i `.css` w zakresie i w kontroli planu.
   - `dashboard/src/work/derive.test.ts`: zadanie w kolejce i w łańcuchu nie wraca w `next` jako „Analizuj/Wdróż”.
   - `dashboard/src/work/runs.test.ts`, `dashboard/src/work/runprefs.test.ts`, `dashboard/src/work/decisionnote.test.ts`, `dashboard/src/work/queue.test.ts`: medium wszędzie, epoka kasuje zapamiętane „max”, pole `serial` w pliku kolejki.
   - `dashboard/src/work/runindex.test.ts`: `model` i `effort` w `RunBrief`.
   - test i18n przechodzi (placeholdery PL/EN, brak nieużywanych kluczy).
28. Serwer: `dashboard/node/batch.test.ts` (tylko administrator, 400 przy pustej liście, częściowy wynik, odmowa zablokowanego tym samym zdaniem co widok, ponowne wysłanie nie podwaja, `chain` dla wielu zadań), `dashboard/node/queue.test.ts` (`serial`: pozycja czeka na wcześniejszą o wspólnych plikach i rusza po niej), `dashboard/node/chain.test.ts` (start wielu, zgoda tylko dla wskazanych par).
29. e2e w `dashboard/node/e2e/automation.e2e.ts`: przy limicie analiz 2 jedna partia z trzema analizami przez `POST /work/batch` → dwie ruszają od razu, trzecia czeka w kolejce z powodem „miejsca analiz 2/2” i rusza sama po zwolnieniu miejsca; do tego dwa wdrożenia o wspólnym pliku → drugie „czeka na task_NN” i rusza po pierwszym.
30. Na koniec: `npm test`, `npx tsc --noEmit`, `npm run e2e` (zestaw dashboardu, bez gry) i zrzut zakładki Teraz w 1366×768 po polsku i po angielsku do raportu (poziom „narzędzia”: bez arkusza).

### H. Dokumentacja
31. `dashboard/INSTRUKCJA.md`: rozdz. 3 (Teraz = trzy panele, tablica zadań, Zadania bez tablicy), rozdz. 4 (tabela modeli: medium wszędzie; zdanie o krótkim przebiegu po karcie; „Jednym kliknięciem” → panel „Uruchom zadania”; zmiana w grze z Pracy), rozdz. 7 (start zbiorczy, kolejka „po kolei”, zgody per para).
32. `dashboard/UI.md`: słowniczek — „Teraz” (nowa definicja), „tablica zadań”, „Czeka na Ciebie”, „Twój ruch”, „Uruchom zadania”, „Zaznacz wszystkie równoległe”, „sprawdzenie równoległości”, „W kolejce”, „zmiana w grze”, „Dodaj zadanie”; „karta zadania” na tablicy zadań; w rozdz. 4 tabela „Zmiany wyglądu 2026-10-28 (task_36)”.
33. `dashboard/ARCHITEKTURA.md`: rozdz. 3 (nowe moduły i widoki), rozdz. 13 (tabela modułów, „Kolejka startów”: pole `serial`, „Łańcuch przebiegów”: wiele zadań, trasa partii, „Przebiegi równolegle”: porównanie kandydatów między sobą).
34. Gra: `docs/analizy/plan.md` §9, tabela „Modele i wysiłek”: wysiłek medium we wszystkich rodzajach przebiegów dashboardu (Roland, dashboard 2026-10-28, task_36); akapit o sesjach terminalowych bez zmian. `CLAUDE.md`, Conventions → Delegation: domyślnie medium we wszystkich przebiegach dashboardu (plan §9), delegacja w terminalu bez zmian. `docs/ai-tasks/INFO.md`, sekcja Dashboard: zdanie o wejściu „Zmiana w grze” obok formularza narzędziowego. Commit dokumentów gry jako `[agent] proces: …`, osobno od zmian dashboardu.

Pliki: dashboard/src/work/board.ts, dashboard/src/work/board.test.ts, dashboard/src/work/parallelplan.ts, dashboard/src/work/parallelplan.test.ts, dashboard/src/work/parallel.ts, dashboard/src/work/parallel.test.ts, dashboard/src/work/chain.ts, dashboard/src/work/chain.test.ts, dashboard/src/work/derive.ts, dashboard/src/work/derive.test.ts, dashboard/src/work/model.ts, dashboard/src/work/automation.ts, dashboard/src/work/queue.ts, dashboard/src/work/queue.test.ts, dashboard/src/work/runs.ts, dashboard/src/work/runs.test.ts, dashboard/src/work/runprefs.ts, dashboard/src/work/runprefs.test.ts, dashboard/src/work/decisionnote.ts, dashboard/src/work/decisionnote.test.ts, dashboard/src/work/runindex.ts, dashboard/src/work/runindex.test.ts, dashboard/src/data/work.ts, dashboard/src/data/workView.ts, dashboard/src/App.tsx, dashboard/src/views/Work.tsx, dashboard/src/views/Board.tsx, dashboard/src/views/RunList.tsx, dashboard/src/views/BulkRunDialog.tsx, dashboard/src/views/NewGameChange.tsx, dashboard/src/views/NowCard.tsx, dashboard/src/views/Chain.tsx, dashboard/src/views/Automation.tsx, dashboard/src/views/ChangeRule.tsx, dashboard/src/views/Overview.tsx, dashboard/src/views/work.css, dashboard/src/i18n/messages/workui.ts, dashboard/src/i18n/messages/work.ts, dashboard/src/i18n/messages/newtask.ts, dashboard/src/i18n/messages/chain.ts, dashboard/src/i18n/messages/automation.ts, dashboard/src/i18n/messages/home.ts, dashboard/node/work-api.ts, dashboard/node/queue.ts, dashboard/node/queue.test.ts, dashboard/node/chain.ts, dashboard/node/chain.test.ts, dashboard/node/batch.test.ts, dashboard/node/e2e/automation.e2e.ts, dashboard/INSTRUKCJA.md, dashboard/UI.md, dashboard/ARCHITEKTURA.md, docs/analizy/plan.md, CLAUDE.md, docs/ai-tasks/INFO.md
Ryzyko: wysokie

## Decyzje i założenia (analiza)

Bez karty decyzji: każdy wybór poniżej wynika ze słów Rolanda albo z zasad, które już obowiązują, i da się go później cofnąć.

1. **„2 albo 3 panele poziome”** = trzy pasy na całą szerokość, jeden pod drugim (Czeka na Ciebie, Tablica zadań, Uruchom zadania). Powód: tablica potrzebuje szerokości na pięć kolumn, a „Czeka na Ciebie” jako osobny pas, a nie kolumna, pozwala karcie zostać w kolumnie przepływu, gdy zadanie potrzebuje Rolanda. Ułożenie paneli obok siebie to tylko zmiana CSS.
2. **Jedna tablica, na zakładce Teraz.** Roland mówi o sekcji „Now”; stara tablica etapów na zakładce Zadania znika, żeby nie było dwóch tablic (UI.md zasada 2). Nazwa zakładki „Teraz” zostaje, bo Roland ją zna.
3. **Zaznaczanie w panelu „Uruchom zadania”, nie na kartach tablicy**: Roland prosi o listę z numerem, jednym zdaniem i polem wyboru. Pojedynczy krok ma dalej przycisk na karcie.
4. **Wszystko z listy idzie przez kolejkę startów** (rusza od razu, gdy jest miejsce): jedna droga z tymi samymi bramkami co kliknięcie, a nadmiar ponad limity D-33 sam czeka.
5. **Kolejność zestawu równoległego = numery zadań rosnąco**: numer odpowiada kolejności planowania, a wynik jest ten sam przy każdym odświeżeniu.
6. **Niezgodne zadania zaznaczone ręcznie idą po kolei**, nie razem; razem tylko po zgodzie dla konkretnej pary. Powód: dziś jedna zgoda „pliki rozłączne” jest zaznaczana na ślepo (cztery łańcuchy z 2026-10-28).
7. **Zależność z `Kolejność:` jest miękka** (wyklucza z zestawu równoległego i ostrzega), bo parser czyta wolny tekst i myli „niezależne od” z „po”.
8. **Bez listy wyjątków dla plików wspólnych** (`tools/unit_test.gd`, `docs/agent/README.md`): wdrożenia gry pójdą wtedy prawie zawsze po kolei, ale bezpiecznie. Lista plików, które zwykle łączą się czysto, to pomysł na osobne zadanie.
9. **Zbiorczo tylko przebiegi agenta i łańcuch.** Scalenie, odrzucenie, arkusze i wypchnięcia zostają pojedyncze: są nieodwracalne albo wymagają sekretu administratora. „Wznów” też pojedynczo, bo potrzebuje okna z instrukcją.
10. **Medium dla każdego rodzaju przebiegu dashboardu**, także domknięcia (było max) i próby (było low), bo kryterium mówi „domyślnie medium”. Modele bez zmian. Sesje terminalowe (D-29: Sonnet high, Haiku max) bez zmian, bo kryterium dotyczy dashboardu.
11. **Epoka ustawień kasuje raz wszystkie zapamiętane ustawienia** (z komunikatem w oknie), bo inaczej zapamiętane „max” analizy dalej wygrywałoby po cichu.
12. **Start zbiorczy wymaga administratora, nie sekretu**, tak jak dzisiejszy start przebiegu, kolejka i łańcuch.
13. **Zmiana w grze prowadzi do edytora zasady ⬜**, a nie tworzy zadania ani zgłoszenia „pomysł” (takie zgłoszenie nie staje się zadaniem w `/spec-tasks`).
14. **Ryzyko wysokie**: zmienia się główny ekran codziennej pracy, zachowanie kolejki, domyślne ustawienia przebiegów i dochodzi nowa trasa API z testem e2e. Łańcuch i tak zatrzymałby się na wdrożeniu (zmiana w `dashboard/` tylko z terminala), a „wysokie” każe przeczytać plan przed startem.

## Przegląd planu i uzupełnienia koordynatora (Fable 5.1, 2026-10-28)

Plan wyżej przyjęty w całości. Poniższe punkty U1–U13 są wiążące dla wdrożenia i mają pierwszeństwo tam, gdzie doprecyzowują plan. Wzorce, na których się opierają: tablice Trello, Linear i GitHub Projects (stała tożsamość karty, stałe kolumny, limit pracy w toku w nagłówku), pasek zaznaczenia z Gmaila i Lineara (pojawia się przy zaznaczeniu, licznik widoczny cały czas, wynik częściowy raportowany per pozycja, „Cofnij” zamiast okna potwierdzenia dla odwracalnych operacji), tabele z wyciszonym wierszem i powodem w wierszu, a nie tylko w podpowiedzi.

1. **U1. Lista „Uruchom zadania” jest kompletna i stabilna.** Zawsze wszystkie otwarte zadania w kolejności numerów; wiersz nigdy nie znika. Zadanie trwające, w kolejce, w łańcuchu albo bez kroku danego rodzaju zostaje w tabeli jako wiersz wyłączony ze stanem w kolumnie wyniku („🔧 Trwa: analiza · 3 min”, „⏳ W kolejce (2.)”, „— Niedostępne: …”). Zmiana przełącznika „Krok” zmienia stany i powody, nie zestaw wierszy.
2. **U2. „Zaznacz wszystkie równoległe” — trzy stany, jedno znaczenie.** Puste zaznaczenie → zaznacza `maximalParallelSet`. Niepuste → *dopełnia* zaznaczenie zadaniami zgodnymi z już zaznaczonymi (ten sam algorytm zachłanny, zaczynający od zaznaczonych, w kolejności numerów). Gdy nic więcej nie da się dołożyć → odznacza wszystko. Obok pola dopisek „(3 z 9)” = ile zaznaczonych z ilu dostępnych teraz. Pole ma stan nieokreślony (`indeterminate`) przy zaznaczeniu częściowym.
3. **U3. Pasek zaznaczenia i wynik partii.** Pasek w zarezerwowanym miejscu (plan pkt 15). `Esc` przy fokusie w tabeli czyści zaznaczenie. Po wysłaniu partii okno zostaje otwarte i pokazuje wynik per zadanie (ruszyło · czeka w kolejce za … · odmowa: powód) z jednym przyciskiem „Zamknij”; w pasku powiadomień zostaje podsumowanie „Dodano 3: 2 ruszyły, 1 czeka w kolejce” z przyciskiem „Cofnij (usuń z kolejki)” dla pozycji, które jeszcze stoją w kolejce (trwających przebiegów nie dotyka; znika po użyciu albo gdy nic już nie stoi w kolejce z tej partii). Powiadomienie nie znika samo z czasem (Roland skarży się właśnie na znikające rzeczy).
4. **U4. Zero skoków układu.** W kolumnie sortowanie wyłącznie po numerze zadania (w „W toku” najpierw grupa „Trwa”, potem „W kolejce”, w każdej po numerze); nigdy po czasie. Karty z `key = task_NN`; odświeżenie co 4 s nie montuje panelu od nowa. Panel „Czeka na Ciebie” ma zarezerwowaną wysokość jednego rzędu także gdy pusty. Czas jako „12 min” / „1 h 05 min” z `font-variant-numeric: tabular-nums` i `min-width`. Kolumny mają stałe proporcje niezależnie od liczby kart (bez dzisiejszego `boardColumns()` zmieniającego szerokość od liczby kart).
5. **U5. Znaczenie przez kolor i ikonę, bez nowych tokenów.** Lewa krawędź karty w kolorze stanu z istniejących tokenów `styles.css`: trwa = akcent (kropka pulsuje tylko przy `prefers-reduced-motion: no-preference`), „Twój ruch” i zatrzymany łańcuch = ostrzeżenie, czerwone testy albo naruszenie = błąd. Liczniki w nagłówkach kolumn przez istniejące klasy `pill` (`pill-warn` przy pełnym limicie, `pill-bad` przy przekroczeniu). Ikony etapów z `STAGE_INFO` bez zmian. Puste kolumny pokazują kreskowane miejsce z „—”, nie znikają.
6. **U6. „Dodaj zadanie” — cztery wejścia, trzy z nich dla gry.** Przycisk rozwija menu: **Zadanie narzędziowe** (`/praca/nowe`, bez zmian), **Nowa zasada ⬜** (edytor zasady z planu pkt 18), **Zgłoszenie błędu** i **Zmiana tekstu** (istniejący formularz zgłoszenia z widoku Zgłoszenia z góry ustawionym rodzajem i powrotem na Pracę). Powód: `/spec-tasks` zamienia na zadania zgłoszenia rodzaju *błąd* i *zmiana tekstu* (skill spec-tasks, linia o rodzajach), a *pomysł* i *pytanie* nie, więc dla błędu w grze zgłoszenie jest krótszą drogą niż nowa zasada. Ekran „Zmiana w grze” (`/praca/nowa-zmiana-gry`) pokazuje te trzy drogi obok siebie, po jednym zdaniu każda, i wspólną dalszą drogę (Zapisz → Zatwierdź → „Zaplanuj zadania (agent)” → karta w „Do zrobienia”). Zadania gry nadal nie powstają z formularza (zasada „każda zmiana gry zaczyna się w specyfikacji”).
7. **U7. Okno zbiorcze = podgląd kolejki.** Pozycje w dokładnie tej kolejności, w jakiej trafią do kolejki, z zaznaczeniem par „po kolei” (strzałka „czeka na task_26”); jedna linia na rodzaj z modelem i wysiłkiem; zgoda per para tylko dla par niezgodnych zaznaczonych ręcznie. Bez zgody obie pozycje zostają, druga `serial`.
8. **U8. Medium wszędzie, jedno zdanie w dokumentach.** Tak jak plan pkt 24–25 (także domknięcie i próba). W `plan.md` §9 tabela modeli dostaje kolumnę wysiłku „medium” dla wszystkich rodzajów przebiegów dashboardu z podpisem „Roland, dashboard 2026-10-28, task_36”; akapit o sesjach terminalowych (D-29) bez zmian.
9. **U9. Wdrożenie w osobnej kopii roboczej specyfikacji.** Kod powstaje w `C:/dev/gamedev/everhorror/specification-task36` (git worktree, gałąź `agent/task36-dashboard`, `node_modules` jako junction do głównej kopii), żeby działający dashboard Rolanda nie przeładowywał się w pół pracy. Scalenie do `master` specyfikacji robi koordynator po przeglądzie. Po scaleniu dashboard trzeba uruchomić od nowa (`npm start`): trasa serwera jest wczytywana raz, przy starcie vite (`vite.config.ts` importuje `node/server.ts`).
10. **U10. Testy stabilności.** Oprócz planu pkt 27: test `board.test.ts`, który prowadzi jedno zadanie przez sekwencję stanów (zaplanowane → w kolejce → trwa → na gałęzi → scalone) i sprawdza, że zbiór kluczy kart jest stały, a zmieniają się tylko kolumny i linia stanu; test `parallelplan.test.ts` dla U2 (dopełnianie zaznaczenia); test, że `WorkView.next` dla Startu różni się od dzisiejszego wyłącznie krokiem 10 (zadanie w kolejce albo łańcuchu).
11. **U11. Dostępność.** Tabela „Uruchom zadania”: `<th scope="col">`, wyłączone pole wyboru z `aria-describedby` na komórkę powodu; kolumny tablicy jako `section` z `aria-labelledby` i `h3`; przejścia kart i pasek zaznaczenia w regionach `aria-live="polite"` / `role="status"`; każdy element z fokusem ma widoczny obrys z istniejącego stylu; menu „Dodaj zadanie” zamykane `Esc` i obsługiwane strzałkami.
12. **U12. Sprzątanie.** `NowCard` znika z Pracy (Start dalej używa `planNow` z `now.ts`), `BulkAnalyzeDialog` i formularz startu łańcucha znikają całkiem razem z kluczami napisów; żadnego martwego kodu i żadnych nieużywanych kluczy (test i18n).
13. **U13. Raport bez zrzutów ekranu.** W tej sesji nie ma przeglądarki; zamiast zrzutów raport opisuje układ słowami i daje wyniki `npm test`, `npx tsc --noEmit`, `npm run e2e`. Roland ogląda wynik na żywo po scaleniu i restarcie dashboardu.

## Co zostało zrobione

Kod powstał w osobnej kopii roboczej specyfikacji `C:/dev/gamedev/everhorror/specification-task36`, na gałęzi `agent/task36-dashboard` (U9), w pięciu commitach; działający dashboard Rolanda nie był ruszany. Ścieżki niżej są względem folderu `dashboard/` tej kopii.

### Kryterium 1: tablica zadań zamiast skaczącego „Teraz” (wymagania o „Now” i o 2–3 panelach)

- Zakładka **Teraz** Pracy to pasek stanu i trzy panele na całą szerokość, jeden pod drugim (`src/views/Work.tsx`, `NowPanels`): „Czeka na Ciebie”, „Tablica zadań”, „Uruchom zadania”. Stara tablica etapów z zakładki Zadania i karta `NowCard` zniknęły (jedna tablica, U12). Zadania mają pełną kartę „Do zaplanowania”, arkusze bez zadania, buildy i historię; lista łańcuchów przeszła na Automat.
- **Model tablicy** to czysty moduł `src/work/board.ts` (`boardOf`, `boardSteps`, `boardMoves`, `cardKeys`): pięć stałych kolumn Do zrobienia → W toku → Na gałęzi → Scalone → Zrobione i jedna karta na zadanie z kluczem `task_NN`. Kolumnę wybiera pierwszeństwo trwa > kolejka > etap; w „W toku” są grupy „Trwa” i „W kolejce”, w kolumnie zawsze po numerze, nigdy po czasie (U4). Linia stanu mówi, co się dzieje: „🔧 Analiza · opus · medium · 12 min” (model i wysiłek doszły do `RunBrief` w `src/work/runindex.ts`), „⏳ W kolejce (2.): powód”, „⛓ Łańcuch: wdrożenie czeka na task_26”, „✋ Łańcuch zatrzymany: …”, „Następny krok: …”.
- **Widok** w `src/views/Board.tsx` (style w `src/views/work.css`, tylko tokeny `styles.css`, bez nowych zależności): karta zwinięta ma trzy linie i stałą wysokość, czas jest cyframi o stałej szerokości, kolumny mają stałe proporcje (na wąskim ekranie tablica przewija się w poziomie), pusta kolumna ma kreskowane „—”. Lewa krawędź karty ma kolor stanu: akcent, gdy trwa (kropka pulsuje tylko bez `prefers-reduced-motion`), ostrzeżenie przy „Twoim ruchu” i zatrzymanym łańcuchu, błąd przy czerwonych testach albo naruszeniu (U5). Liczniki limitów stoją w nagłówkach kolumn (`pill-warn`, `pill-bad`), jest przełącznik „Grupuj: rodzaj zadania”, a karta, która zmieniła kolumnę, ma obwódkę przez 2 s; region `aria-live` czyta „task_26: Do zrobienia → W toku (analiza)”. Rozwinięta karta (pamiętana osobno dla każdego zadania) pokazuje szczegóły i jeden przycisk kroku (`TaskCardActions`, przeniesione z `Work.tsx`).
- **„Czeka na Ciebie”**: kroki, które robi tylko człowiek, każdy jako karta z jednym przyciskiem, w stałej kolejności, bez składania i bez limitu pięciu. Panel ma zarezerwowaną wysokość jednego rzędu także pusty, a ponad dwa rzędy przewija się sam; „Robię sam” zostało.
- **Krok 10 listy `next`** (`src/work/derive.ts`, `nextList`): zadanie, które stoi w kolejce startów albo ma niedokończony łańcuch, nie jest już proponowane jako „Analizuj/Wdróż”, więc Start i `cli.ts teraz` nie pokazują kroku, który już zlecono. Poza tym `next` jest taki jak dotąd (test U10 w `derive.test.ts`).

### Kryterium 2: pojedynczo i zbiorczo (wymaganie o liście zamiast listy rozwijanej)

- Panel **„Uruchom zadania”** (`src/views/RunList.tsx`) pokazuje wszystkie otwarte zadania w kolejności numerów; wiersz nie znika, a zadanie trwające, w kolejce albo w łańcuchu jest wyciszone z powodem (U1). „Krok:” to przełączniki z `aria-pressed` (Następny krok, Analiza, Wdrożenie, Przegląd kodu, Poprawki, Domknięcie, Przeprowadź zadanie; wybór pamiętany w przeglądarce). Kolumny: pole wyboru, numer (link), tytuł w jednej linii, etap, krok z cichym dopiskiem „sonnet · medium”, pliki z ryzykiem, wynik sprawdzenia. Shift+klik zaznacza zakres, Esc czyści zaznaczenie, a pasek zaznaczenia stoi w zarezerwowanym miejscu („3 zaznaczone · 2 ruszą od razu · 1 do kolejki”, „Uruchom zaznaczone (3)”, „Wyczyść zaznaczenie”). Gdy zmiana kroku zdejmie zaznaczenie z wierszy, mówi to komunikat `role="status"`. Lista rozwijana łańcucha i okno „Analizuj wszystkie zaplanowane” zniknęły razem z kodem i kluczami napisów.
- Okno **„Uruchom zaznaczone”** (`src/views/BulkRunDialog.tsx`) jest podglądem kolejki (U7): zadania w kolejności, w jakiej trafią do kolejki, przy każdym „rusza teraz”, „czeka w kolejce: …” albo „↳ czeka na task_26”. Ustawienia: przy jednym rodzaju pola okna startu z tą samą pamięcią, przy kilku jedna linia na rodzaj („analiza: opus · medium”), łańcuch bierze domyślne. Do tego „Edytor Godota nie jest otwarty na kopiach gałęzi” (gdy trzeba), zgoda tylko dla niezgodnych par zaznaczonych ręcznie i uwagi dla agenta; „Uruchom (N)” jest wyłączone na czas wysyłania. Po wysłaniu okno zostaje i pokazuje na żywo wynik każdego zadania z jednym przyciskiem „Zamknij” (U3), a nad stroną zostaje powiadomienie „Dodano 3: 2 rusza od razu, 1 czeka w kolejce” z odmowami i „Cofnij (usuń z kolejki)” (`BatchNotice`), które samo nie znika.
- Pojedynczo: jeden zaznaczony wiersz działa tak samo, a przycisk na rozwiniętej karcie i na stronie zadania zostaje (zwykłe okno startu, także „Wznów”).
- **Serwer**: nowa trasa `POST /work/batch` (`node/batch.ts`: `parseBatch`, `runBatch`; wpięta w `node/work-api.ts`). Kolejno: `requireAdmin` bez sekretu, widok z `deriveWork`, te same `parallelPlan` i `selectionCheck` co lista. Zablokowane zadanie dostaje odmowę tym samym zdaniem, które pokazuje lista; reszta w kolejności numerów idzie do kolejki startów (kod „po kolei”) albo do startu łańcucha. Zadanie, którego nie da się dodać, to odmowa tego jednego zadania; ponowne wysłanie niczego nie podwaja; pusta lista albo zły krok to 400. Partia to jeden wpis `batch` w dzienniku automatyki („Dashboard zrobił sam”).
- **Kolejka „po kolei”** (`node/queue.ts`, `src/work/queue.ts`, `src/work/automation.ts`): pozycja ma pola `serial`, `after` i `overlapOk`. Pozycja `serial`, która dzieli pliki z pozycją wyżej albo z trwającym przebiegiem, nie jest odrzucana, tylko czeka z powodem „Czeka na task_26 (wspólne pliki albo kolejność z partii); ruszy po nim.”. Zgoda pary idzie do blokady przebiegu (`node/runner.ts`, `StartContext.overlapAcknowledgedWith`). Stary `queue.json` czyta się jak dotąd, a „Dodaj do kolejki” z okna startu działa bez zmian.
- **Łańcuch dla wielu zadań** (`node/chain.ts`, `src/work/chain.ts`): start dostaje `after` (na czyje wdrożenie czeka), `overlapOk` (tylko potwierdzone pary) i uwagi dla agenta. Przed wdrożeniem łańcuch czeka (`kolejnosc`, z nazwami zadań), a jego kroki kodu idą do kolejki „po kolei”. `POST /work/chain` zostaje dla jednego zadania i „Kontynuuj”.

### Kryterium 3: co może iść równolegle („select all (parallel)”)

- Czysty moduł `src/work/parallelplan.ts` daje każdemu zadaniu stan `teraz`, `kolejka` albo `zablokowane` z powodem (opis `msg()`), pary niezgodne (wspólne pliki z „Pliki:”, nieznany zakres, konflikt z `git merge-tree`, kolejność z pliku zadania), `maximalParallelSet`, `parallelComplement` (U2) i `selectionCheck`. Kolumna „Sprawdzenie” mówi „✓ Może ruszyć teraz”, „⏳ Pójdzie do kolejki: miejsca wdrożeń 3/3”, „✕ Nie razem z task_26: script/game_state.gd, …” albo „— Niedostępne: …”.
- „Zaznacz wszystkie równoległe” ma trzy stany (U2): przy pustym zaznaczeniu zaznacza zestaw równoległy, przy częściowym dopełnia zaznaczenie zadaniami zgodnymi, a gdy nic więcej się nie mieści, odznacza wszystko; ma stan nieokreślony i dopisek „(3 z 9)”.
- Parser zakresu ma jedną stałą rozszerzeń `SCOPE_FILE_EXT` z `tsx` i `css` (`src/work/parallel.ts`; używa jej też `src/work/chain.ts`). Akcje, które zamyka tylko to, co minie samo (inny przebieg zadania, pełna klasa, limit gałęzi), mają w `derive.ts` znacznik `queueable`, więc lista mówi „Pójdzie do kolejki”, a nie „Niedostępne”.

### Kryterium 4: nowe zadanie gry obok narzędziowego

- W nagłówku Pracy jest przycisk **„Dodaj zadanie”** z menu (Esc zamyka, strzałki, Home i End przechodzą po wejściach): Zadanie narzędziowe (`/praca/nowe`, bez zmian; gdy formularz jest zamknięty, wejście mówi dlaczego), Nowa zasada ⬜, Zgłoszenie błędu, Zmiana tekstu (U6).
- Ekran **„Zmiana w grze”** (`src/views/NewGameChange.tsx`, trasa `/praca/nowa-zmiana-gry` w `src/App.tsx`) pokazuje trzy drogi obok siebie, po jednym zdaniu każda: plik specyfikacji z zasadami pogrupowany jak menu, z wyszukiwaniem (znajduje też bez polskich znaków), i „Napisz zasadę ⬜”; „Zgłoś błąd”; „Zgłoś zmianę tekstu”. Pod nimi jest wspólna dalsza droga (Zapisz na dysk → Zatwierdź zmiany → „Zaplanuj zadania (agent)” → karta w „Do zrobienia”) ze stanem koszyka i niezatwierdzonych plików. Edytor zasady przyjmuje parametry `znacznik` (⬜ ustawiony z góry) i `wroc` (`src/views/ChangeRule.tsx`), formularz zgłoszenia `rodzaj` (błąd albo zmiana tekstu) i `wroc` (`src/views/Tickets.tsx`); powrót wolno skierować tylko na ścieżkę Pracy (`safeReturn` w `src/nav.ts`). Dashboard nie tworzy pliku zadania gry, a serwer dalej odmawia `kind: rozgrywka` w `POST /work/new-task`.

### Kryterium 5: domyślnie wysiłek medium

- `src/work/runs.ts`: medium dla każdego rodzaju przebiegu (wdrożenie i poprawki miały high, domknięcie max, próba low); modele, budżety i tury bez zmian. `src/work/decisionnote.ts`: krótki przebieg po karcie to Sonnet medium. `src/work/runprefs.ts`: stała epoki `PREFS_EPOCH = '2026-10-28'` w `defaultsVersion`, więc wszystkie zapamiętane ustawienia (także „max” analizy) są raz pominięte, a okno mówi to istniejącym zdaniem. Łańcuch i kolejka biorą domyślne z kodu, więc od razu medium.
- Gra (niezatwierdzone, do commita koordynatora jako `[agent] proces: …`): `docs/analizy/plan.md` §9 (tabela: medium we wszystkich rodzajach, podpis „Roland, dashboard 2026-10-28, task_36”; akapit o sesjach terminalowych D-29 bez zmian), `CLAUDE.md` (Conventions → Delegation: domyślnie medium we wszystkich przebiegach dashboardu, delegacja w terminalu bez zmian), `docs/ai-tasks/INFO.md` (sekcja Dashboard: zdanie o wejściu „Zmiana w grze” obok formularza narzędziowego).

### Napisy i dokumentacja

- Napisy PL i EN w `src/i18n/messages/workui.ts`, `work.ts` (`work.parallel.*`), `automation.ts`, `chain.ts`, `newtask.ts` i `home.ts` (Start: „Otwórz tablicę zadań →”); klucze starej karty „Teraz” Pracy, formularza łańcucha i okna „Analizuj wszystkie zaplanowane” usunięte (test i18n: zero nieużywanych kluczy, te same placeholdery PL i EN).
- `INSTRUKCJA.md` rozdz. 3, 4 i 7 (przy okazji usunięty przypadkowy dopisek z końca kroku 9 i powtórzone zdanie o polu „Wysiłek”), `UI.md` (słowniczek: Teraz, Czeka na Ciebie, tablica zadań, Twój ruch, W kolejce, Uruchom zadania, Zaznacz wszystkie równoległe, sprawdzenie równoległości, po kolei, Dodaj zadanie, zmiana w grze, karta zadania; tabela „Zmiany wyglądu 2026-10-28 (task_36)”), `ARCHITEKTURA.md` (rozdz. 3, tabela tras, testy i rozdz. 13: moduły, profil z medium, kandydaci porównywani ze sobą, kolejka „po kolei”, start zbiorczy, łańcuch wielu zadań).

### Commity (gałąź `agent/task36-dashboard`, niewypchnięta)

- `360e8bf` [agent] dashboard: wysiłek medium we wszystkich przebiegach (task_36)
- `388573c` [agent] dashboard: model tablicy zadań i sprawdzenie równoległości (task_36)
- `cc8603b` [agent] dashboard: start zbiorczy na serwerze, kolejka „po kolei”, łańcuch wielu zadań (task_36)
- `0e0508e` [agent] dashboard: Praca: trzy panele Teraz, okno partii, „Dodaj zadanie” i „Zmiana w grze” (task_36)
- `22225ac` [agent] dashboard: dokumentacja tablicy zadań, startu zbiorczego i wysiłku medium (task_36)

## Decyzje i założenia

1. **Akcja `queue-analyze` usunięta całkiem** (z `derive.ts`, `ActionId` i `WorkAction.queueTasks`): po zniknięciu okna „Analizuj wszystkie zaplanowane” byłaby martwym kodem (U12). E2e kolejki bierze teraz zwykłą listę czterech zadań i sprawdza zamiast przycisku krok 10 listy `next`.
2. **Znacznik `WorkAction.queueable`** w `derive.ts` (plan go nie wymieniał): odróżnia bramki, które miną same, od tych, które wymagają człowieka, żeby lista mogła powiedzieć „Pójdzie do kolejki”. Domknięcie przed scaleniem nie jest `queueable`, czyli lista jest tu ostrożniejsza niż kolejka, która takie domknięcie przyjmuje.
3. **Pozycja kolejki ma też `after`** (zadania partii, na które czeka), obok planowanego `serial`, żeby podgląd „↳ czeka na task_26” w oknie zgadzał się z tym, co zrobi kolejka. Kroki kodu łańcucha idą zawsze `serial`.
4. **Zmieniony `node/runner.ts`** (nie było go na liście plików planu): zgoda dla pary musi dojść do blokady przebiegu, inaczej start z kolejki dostałby 412.
5. **Logika partii w osobnym `node/batch.ts`**, a `work-api.ts` ma tylko strażników i widok: dzięki temu `node/batch.test.ts` testuje partię bez serwera HTTP, a e2e sprawdza ją przez HTTP.
6. **„Czeka na Ciebie” pomija notatki kroku 12** (`!enabled && !notice`: pojawiały się i znikały zależnie od reszty listy) i sam składa krok odpowiedzi na kartę dla zadania, które czeka na decyzję; `boardOf` przyjmuje opcjonalny tłumacz `t`.
7. **Tekst powiadomienia partii to przewidywanie z chwili dodania** („2 rusza od razu”), bo serwer odpowiada, zanim kolejka coś uruchomi; prawdziwy stan pokazuje na żywo okno, które zostaje otwarte.
8. **Łańcuch zadania o wysokim ryzyku** ma w wierszu ostrzeżenie (zatrzyma się przed wdrożeniem), a nie blokadę. Łańcuchy zadań bez analizy (pliki nieznane) czekają przy wdrożeniu na wcześniejsze zadanie partii, zgodnie z decyzją 8 analizy (bez listy wyjątków); potwierdzona para idzie razem.
9. **Formularze wracają na ekran „Zmiana w grze”** (`wroc=/praca/nowa-zmiana-gry`), nie na samą Pracę: tam widać koszyk i dalszą drogę. `wroc` przyjmuje tylko ścieżki Pracy.
10. **Bez zrzutów ekranu** (U13, w sesji nie ma przeglądarki). Zamiast nich smoke test renderowania w folderze roboczym tej sesji (niżej, rozdz. „Test”); nie jest częścią repozytorium.
11. **Commity podzielone po plikach** (bez interaktywnego `git add -p`), więc pośrednie commity nie muszą się kompilować osobno; typy, testy i e2e sprawdzone na ostatnim. Gałąź scala się z dzisiejszym master specyfikacji bez konfliktów (`git merge-tree --write-tree master HEAD`: kod 0), choć master ma od punktu rozgałęzienia osiem nowych commitów (m.in. w `ARCHITEKTURA.md` i `node/e2e/automation.e2e.ts`); testy po scaleniu warto puścić jeszcze raz.

## Czego potrzebuję od Ciebie

1. Po scaleniu gałęzi `agent/task36-dashboard` do master specyfikacji uruchom dashboard od nowa (`npm start`): trasa `POST /work/batch` i zmiany kolejki wczytują się raz, przy starcie vite.
2. Obejrzyj zakładkę Teraz w 1366×768 po polsku i po angielsku (U13): układ trzech paneli, wysokość kart, przewijanie tablicy w wąskim oknie.
3. Zapamiętane ustawienia okna startu zostały raz pominięte (epoka 2026-10-28). Jeśli dla analizy dalej chcesz „max”, ustaw go ponownie w oknie startu.
4. Dokumenty gry (`docs/analizy/plan.md`, `CLAUDE.md`, `docs/ai-tasks/INFO.md`) i ten raport są niezatwierdzone w głównej kopii gry; commit `[agent] proces: …` robi koordynator.

## Test

Wszystko w kopii `specification-task36/dashboard`, Node v24.21.0, 2026-10-28.

- `npm test` na ostatnim commicie: `ℹ tests 2634`, `ℹ suites 62`, `ℹ pass 2634`, `ℹ fail 0`, `ℹ cancelled 0`, `ℹ skipped 0`, `ℹ todo 0`, `ℹ duration_ms 151795.3192`, `real 2m32.362s`, kod wyjścia 0. Przed zmianami: 2579 testów, 2579 zaliczonych, 0 błędów, `duration_ms 166390`, kod 0.
- `npx tsc --noEmit`: bez komunikatów, kod wyjścia 0. `npx vite build` (do folderu tymczasowego): „✓ 177 modules transformed”, „✓ built in 276ms”, tylko dawne ostrzeżenie o wielkości paczki.
- `npm run e2e` na ostatnim commicie (zestaw dashboardu, bez gry): `ℹ tests 57`, `ℹ suites 0`, `ℹ pass 57`, `ℹ fail 0`, `ℹ cancelled 0`, `ℹ skipped 0`, `ℹ todo 0`, `ℹ duration_ms 213769.62`, `real 3m34.323s`, kod wyjścia 0.
- Celowane w trakcie pracy: `node --test node/batch.test.ts` 8/8, `node/queue.test.ts` 23/23, `node/chain.test.ts` 18/18, `node/runner.test.ts` z filtrem `task_36|R4` 14/14, `src/nav.test.ts` 7/7, `node/e2e/automation.e2e.ts` 23/23 (`duration_ms 147995.9605`, `real 2m28.058s`, kod 0, z nowym scenariuszem: przy `read=2` partia trzech analiz przez `POST /work/batch` uruchamia dwie, trzecia czeka z powodem `automation.queue.wait.full` 2/2 i rusza sama po zwolnieniu miejsca; dwa wdrożenia o wspólnym pliku: drugie czeka z powodem `automation.queue.wait.serial` „task_05” i rusza po końcu pierwszego).
- Pierwsze pełne `npm run e2e` (przed poprawką) dało `ℹ tests 57`, `ℹ pass 55`, `ℹ fail 2`, kod 1: dwa stare oczekiwania „high” w `node/e2e/work.e2e.ts` (domyślny wysiłek wdrożenia w preflight i krótki przebieg po karcie). Zmienione na „medium”; oba testy osobno przeszły (3/3 z filtrem), potem cały zestaw (wyżej).
- Smoke renderowania bez przeglądarki (U13): `renderToString` paneli „Czeka na Ciebie”, „Tablica zadań”, „Uruchom zadania”, okna „Uruchom zaznaczone” i powiadomienia partii na widoku z syntetycznych zadań (trwająca analiza, pozycja w kolejce, łańcuch czekający na wdrożenie, para z tym samym plikiem): po polsku 19 639 i po angielsku 19 574 znaków HTML, bez wyjątków, wszystkie oczekiwane napisy obecne („Czeka na Ciebie”, „Analiza · opus · medium”, „↳ czeka na task_05”, „Potwierdzam, że task_05 i task_06 mogą pracować na wspólnych plikach”, „Cofnij (usuń z kolejki)” i odpowiedniki EN), żaden klucz napisu bez tłumaczenia.

## Podsumowanie

Zakładka Teraz w Pracy ma teraz trzy stałe panele: „Czeka na Ciebie” z Twoimi krokami, „Tablicę zadań” z pięcioma kolumnami, w której każde zadanie ma jedną kartę przesuwającą się między kolumnami zamiast znikać, oraz listę „Uruchom zadania” z polami wyboru i kolumną „Sprawdzenie”, która mówi, co może ruszyć razem, co pójdzie do kolejki i dlaczego. „Zaznacz wszystkie równoległe” i „Uruchom zaznaczone” zlecają naraz analizy, wdrożenia, przeglądy kodu, poprawki, domknięcia albo łańcuchy przez nową trasę `POST /work/batch`; nadmiar czeka w kolejce, a zadania na wspólnych plikach idą po kolei, chyba że potwierdzisz konkretną parę. „Dodaj zadanie” prowadzi obok zadania narzędziowego do ekranu „Zmiana w grze” (nowa zasada ⬜, zgłoszenie błędu, zmiana tekstu), a wszystkie przebiegi dashboardu ruszają domyślnie z wysiłkiem medium. Testy przechodzą: `npm test` 2634 z 2634, `npx tsc --noEmit` bez błędów, `npm run e2e` 57 z 57. Kod jest w pięciu commitach na gałęzi `agent/task36-dashboard` w kopii `specification-task36`; po scaleniu trzeba uruchomić dashboard od nowa (`npm start`).
