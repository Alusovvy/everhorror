<!--
Zadanie narzędziowe z uwag Rolanda do przebiegu planowania w dashboardzie (spec-tasks, 2026-10-27). Wymagania to cytat słów Rolanda; nie edytować.
-->

# task_18: Dashboard — „Zmiany do wdrożenia” pod przyciskiem „Zaplanuj zadania”

Wymagania:
1. Roland, dashboard 2026-10-27: „Dodatkowo w zakładce Praca "Zmiany do wdrożenia" dałbym pod panelem "do zaplanowania i pod "zapalnuj zadania" bo inaczej to sugeruje że będzimy planować to co jest do wdrożenia.”

Rodzaj: narzędzia
Poziom: narzędzia
Zleca: Roland (dashboard, 2026-10-27)

Kontekst:
- Kod dashboardu leży w repozytorium specyfikacji (`C:/dev/gamedev/everhorror/specification/dashboard`), tak jak przy task_15. Zadanie nie zmienia rozgrywki, więc nie dostaje wiersza w „W zadaniach” w `WDROZENIA.md`.

Kryteria akceptacji:
- W widoku Praca karta „Do zaplanowania” pokazuje najpierw liczniki, potem przycisk „Zaplanuj zadania (agent, Opus)”, a dopiero pod nim zwijaną listę „Zmiany do wdrożenia”.

Poza zakresem:
- Logika liczenia zmian (`derive.ts`, `semanticDiff`) i treść przycisku.

Priorytet: niski · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
- `dashboard/src/views/Work.tsx`, funkcja `PlanCard` (ok. linii 600–659): `<details className="wk-changes">` z listą „Zmiany do wdrożenia” stoi dziś przed `<ActionRow action={plan} …/>`. Wystarczy zamienić kolejność tych dwóch elementów; ewentualnie dopasować odstęp w `dashboard/src/views/work.css` (sekcja „Do zaplanowania”, ok. linii 290).
- Niejasność: „pod panelem "do zaplanowania" i pod "zaplanuj zadania"” czytam jako „pod licznikami karty i pod przyciskiem”. Gdyby Roland chciał osobnej karty pod całą kartą „Do zaplanowania”, to też drobna zmiana. Wykonawca wybiera pierwsze odczytanie i opisuje je w raporcie.
- Opcjonalnie, w duchu uwagi: nagłówek listy mógłby brzmieć „Zmiany w specyfikacji od ostatniego planowania”, ale wymaganie mówi tylko o położeniu, więc tekst zostaje, chyba że Roland poprosi.
- Sprawdzenie: testy dashboardu, które dotyczą widoku Praca (bez sieci i bez npm; uruchomić tylko to, co działa lokalnie), oraz zrzut albo opis widoku. Commit w specyfikacji po lincie, z komunikatem `[agent] proces: dashboard — …`.

## Analiza (agent, 2026-10-27, przebieg `20261027-081849-analyze-18-fcb20b`)

**Jak jest dziś.** Kartę „Do zaplanowania” rysuje `PlanCard` w `dashboard/src/views/Work.tsx:600-659` (repozytorium specyfikacji). Kolejność elementów:
1. nagłówek „Do zaplanowania” (`:615`);
2. liczniki `ul.wk-counts`: zmiany w specyfikacji do wdrożenia, nowe zgłoszenia, pozycje kolejki bez zadania; albo zdanie „Nic nowego w specyfikacji od ostatniego planowania.” (`:616-644`);
3. „Liczone od … (`sha7`)” (`:645-649`);
4. zwijana lista `details.wk-changes` „Zmiany do wdrożenia (N)” z `ChangeList`; jest tylko przy `up.actionable > 0` i sama się otwiera przy najwyżej 6 pozycjach (`:650-655`);
5. `ActionRow` z przyciskiem „Zaplanuj zadania (agent, Opus)” i powodem obok (`:656`).

Lista stoi więc między licznikami a przyciskiem i czyta się jak „to zaplanuje przycisk”. A liczy od ostatniego wpisu w „W zadaniach” (albo od ostatniego wdrożenia) i może pokazywać zmiany, które planowanie już uznało za niewymagające zadań (`dashboard/INSTRUKCJA.md:118`). Na to wskazuje uwaga Rolanda.

**Co trzeba zmienić.** Przenieść blok z pkt 4 za `ActionRow` z pkt 5. Liczniki i „Liczone od…” zostają nad przyciskiem, bo opisują to, na co przycisk patrzy; jego powód też jest zbudowany z liczników (`dashboard/src/work/derive.ts:922`). Obliczanie listy (`useAsync`, `semanticDiff`), warunek `open` i teksty się nie zmieniają (poza zakresem).

**Jak czytam wymaganie.** „pod panelem "do zaplanowania" i pod "zapalnuj zadania"” da się odczytać na dwa sposoby:
- (A) w tej samej karcie, pod licznikami i pod przyciskiem;
- (B) jako osobną kartę pod całą kartą „Do zaplanowania”.

Kryterium akceptacji w tym pliku wybiera A, a Roland zapisał plik w historii gry (`acd2ee2`). Dlatego nie piszę karty decyzji. B to też kilka linii: nowa sekcja `card` z własnym `h2` między `<PlanCard>` a `<Board>` (`Work.tsx:946-947`). Gdyby Roland wolał B, wystarczy uwaga do przebiegu wdrożenia.

**Ryzyka i luki.**
- **Wygląd.** `.wk-action` ma `padding: 8px 0` (`dashboard/src/views/work.css:264-270`), a `summary` listy `margin: 6px 0` (`work.css:300-304`). Po zamianie lista przylgnie do przycisku bez żadnego oddzielenia. Proponuję cienką linię nad listą, w stylu już używanym między akcjami (`.wk-action + .wk-action`, `work.css:271-273`). Wtedy lista wygląda na osobną informację, a nie na część akcji.
- **Licznik.** Pierwszy licznik nad przyciskiem nadal brzmi „N zmian w specyfikacji do wdrożenia”, więc może sugerować to samo, o czym pisze Roland. Wymaganie dotyczy tylko listy, a teksty są poza zakresem. Odnotowuję to jako możliwe osobne zadanie; w tym nic nie zmieniam.
- **Testy.** Widok nie ma testów. Testy dashboardu (`node --test`) obejmują `derive`, `tasks`, `sheets`, `runs`, `spec`, `data`, ale nie komponenty React. Kolejność elementów sprawdzą tylko typowanie i człowiek.
- **Commit.** Kod leży w master specyfikacji, a tam Roland ma teraz niezatwierdzone zmiany w 11 plikach rozdziałów 01–03 (`git status`, 2026-10-27). Commit tego zadania obejmuje tylko `dashboard/src/views/Work.tsx`, `dashboard/src/views/work.css` (i `dashboard/INSTRUKCJA.md`, jeśli się zmieni), podane jawnie.
- **Kolejność i limity.** Zadanie od niczego nie zależy (`Kolejność: —`). Nie zajmuje miejsca jedynej otwartej gałęzi `spec/*` (kod jest w specyfikacji, a nie w grze), więc nie koliduje z task_16 i task_17.
- **Gdzie wdrażać.** Zadanie narzędziowe idzie przez ten sam łańcuch z dashboardu co każde inne (D-36 pkt 8), na poziomie `narzędzia`: bez arkusza i bez builda do ogrania. Zastrzeżenie: cała zmiana leży w `<spec>/dashboard/`, a `docs/agent/run-rules.md` §1 odbiera przebiegowi zapis w tym folderze (zob. „Przepływ (D-36)”).

## Plan
1. `dashboard/src/views/Work.tsx`, `PlanCard`: przenieść `{up.actionable > 0 && (<details className="wk-changes" …>…</details>)}` za `{plan && <ActionRow action={plan} … />}`. Poza kolejnością nic się nie zmienia.
2. `dashboard/src/views/work.css`, sekcja `/* Do zaplanowania */`: dodać regułę `.wk-changes` z `border-top: 1px solid var(--border)` i małym `padding-top`. Bez nowych klas.
3. Sprawdzenie lokalne, bez sieci i npm:
   - `node C:/dev/gamedev/everhorror/specification/dashboard/node_modules/typescript/bin/tsc --noEmit -p C:/dev/gamedev/everhorror/specification/dashboard/tsconfig.json`;
   - `node --test C:/dev/gamedev/everhorror/specification/dashboard/src/work/derive.test.ts` jako kontrola, że obok nic nie pękło.

   Gry ani Godota to nie dotyczy. Opis widoku w raporcie obejmie trzy stany: nic nowego (bez listy), same zgłoszenia bez zmian (bez listy), ponad 6 zmian (lista zwinięta pod przyciskiem).
4. `dashboard/INSTRUKCJA.md:56` (krok 2): jedno zdanie, że pod przyciskiem jest zwijana lista „Zmiany do wdrożenia”: różnice od ostatniego wpisu w „W zadaniach”, a nie lista tego, co planowanie zaplanuje. Innych dokumentów zmiana nie dotyka.
5. Lint (`node C:/dev/gamedev/everhorror/specification/dashboard/cli.ts lint`, 0 błędów). Potem commit w specyfikacji z jawnymi ścieżkami: `[agent] proces: dashboard — lista „Zmiany do wdrożenia” pod przyciskiem „Zaplanuj zadania” (task_18)`, i push master specyfikacji. Bez gałęzi gry i bez wierszy w `WDROZENIA.md`: zadanie narzędziowe nie dostaje wiersza „W zadaniach”, a „Na gałęziach” nie ma czego wpisać, bo nie powstaje żadna gałąź `spec/*`.
6. Bez arkusza (poziom `narzędzia`, D-36 pkt 4). Dowodem są sprawdzenia z kroku 3 i opis w raporcie, że:
   - kolejność w karcie to liczniki, przycisk, lista;
   - lista nadal się zwija i rozwija, a przy najwyżej 6 zmianach otwiera się sama;
   - stan „Nic nowego…” jest bez listy.
7. Raport w tym pliku („Co zostało zrobione”, „Decyzje i założenia”, „Czego potrzebuję od Ciebie”, „Test”, „Podsumowanie”). Plik zadania przenosi do `done/` domknięcie po scaleniu, nie wykonawca.

Pliki: dashboard/src/views/Work.tsx, dashboard/src/views/work.css, dashboard/INSTRUKCJA.md
Ryzyko: niskie

## Pytania do Rolanda
Brak. Jedyną niejasność (A czy B) rozstrzyga kryterium akceptacji; karty decyzji nie ma.

## Przepływ (D-36)
Poziom `narzędzia`: zmiana widoku dashboardu (kod w repozytorium specyfikacji, ścieżki w `Pliki:` liczone od jego korzenia) bez wpływu na grę, więc bez arkusza i bez builda do ogrania; po przeglądzie i testach scala się bez sprawdzenia człowieka.
Ryzyko `niskie`: dwa pliki interfejsu i jedno zdanie dokumentacji.
Do rozstrzygnięcia przed wdrożeniem: `docs/agent/run-rules.md` §1 zabrania przebiegowi zapisu w `<spec>/dashboard/`, a ta zmiana leży tylko tam; potrzebny wyjątek w regułach albo wykonanie przez koordynatora.

## Podsumowanie
Zmiana jest drobna: w `PlanCard` (`Work.tsx`) zwijana lista „Zmiany do wdrożenia” przechodzi spod liczników pod przycisk „Zaplanuj zadania”. Do tego cienka linia oddzielająca w `work.css` i jedno zdanie w `INSTRUKCJA.md`. Logika i teksty bez zmian. Wdrożenie z dashboardu na poziomie `narzędzia`, commit `[agent] proces: …` w specyfikacji, bez arkusza (dowód w sprawdzeniach i raporcie). Gry, Godota ani `WDROZENIA.md` zadanie nie dotyka. Możliwe osobne zadanie: licznik „N zmian w specyfikacji do wdrożenia” nad przyciskiem może dawać to samo wrażenie co lista.
