# Factcheck test 19: Dashboard — czytelność, dwujęzyczność i propozycje z przeglądu

> Zadanie: [task_19](../ai-tasks/task_19.md) · Przygotowano: 2026-10-27 · Gałąź: `agent/dashboard-ux` w repozytorium specyfikacji (kopia `C:\dev\gamedev\everhorror\specification-praca`)
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis.

## Co zostało dodane
- **Dwa języki.** Przełącznik „PL | EN” w pasku bocznym i na ekranie logowania. Polski jest domyślny; tłumaczy się interfejs, a nie treść specyfikacji, zadań, arkuszy i commitów (D-30). Nazwy według słowniczka `dashboard/UI.md`: jedna nazwa na jedną rzecz („Start”, „Przegląd kodu (agent)”, „Zatwierdź zmiany”, „Domknij zadanie (agent)”).
- **Nawigacja:** Start, Praca, Przebiegi, Zgłoszenia, Zmiany; grupa „Raporty”; „Instrukcja” w stopce.
- **Karty decyzji:** przy pytaniach „Kontekst opcji” i „Co znaczą kody w tych opcjach”; lint ostrzega o kodzie bez opisu; zamknięcie z brakującymi odpowiedziami wymaga potwierdzenia; podgląd zmiany karty.
- **Scalanie:** okno pokazuje werdykt przeglądu kodu (przypięty do commita gałęzi), listę commitów i plików; bez aktualnego „gotowe” trzeba zaznaczyć zgodę.
- **Przebiegi:** koszt i czas („Dziś: …”), różnice od domyślnych ustawień, filtr „Błędy i blokady”, czas przy wpisach, „Strażnik zablokował (N)”, ramka „NASTĘPNY KROK”, przyciski bez nazw modeli, Haiku w oknie startu.
- **Praca i „Teraz”:** „stan z HH:MM:SS” i odświeżanie co ok. 45 s, „Wznów: …” po decyzji albo przerwanym przebiegu, licznik planowania po pustym planowaniu, „Wyjaśnione…” dla fałszywego alarmu, spokojne powody i czytelne nieaktywne przyciski, „Zmiany do wdrożenia” pod przyciskiem planowania (task_18).
- **Strona zadania:** kolejność kart według etapu, zwinięte wymagania, czas i koszt przebiegów, podpowiedź „sonnet · high” przy przyciskach agenta, polecenie „Wdróż w terminalu” dla zadań narzędziowych.
- **Arkusze:** arkusz kilku zadań (D-27), zamknięcie z ⏭ w pustych polach (D-28), „Dołącz raport przebiegu”, „Następne puste ↓” i „Tylko puste”.
- **Specyfikacja:** bez fałszywych „do wdrożenia” (linie „Stan na”, LoreDoc, przełączenia znaczników po domknięciu), TECH-1…3 widoczne dla planowania, ❓ w listach numerowanych.
- **Kopia robocza na gałąź (R2):** nowa gałąź dostaje własny folder w `C:\dev\gamedev\everhorror\everhorror-wt\`; task_16 zostaje w `everhorror-wdrozenie` do scalenia.

**Jak uruchomić.** Zamknij okno z działającym dashboardem (`npm start` w `specification\dashboard`). W PowerShell: `cd C:\dev\gamedev\everhorror\specification-praca\dashboard`, potem `npm start` (ten sam port 5174, te same repozytoria). Po odbiorze wróć do starego okna. W czasie odbioru nie uruchamiaj przebiegów agenta poza „Sprawdź agenta”: skille gry dostaną nowe zasady dopiero przy scaleniu do master.

## Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | Przełącznik języka | w pasku bocznym kliknij „EN”, odśwież stronę, wyloguj się | interfejs po angielsku, wybór zostaje po odświeżeniu; na ekranie logowania też jest „PL \| EN” | | |
| 2 | Angielski bez polskich resztek | w EN przejdź Start, Praca, stronę task_16, arkusz task_16, Przebiegi, Zgłoszenia, Zmiany, Zatwierdź zmiany | po polsku są tylko treści (tytuły zadań, zasady, teksty arkuszy, karty), nie przyciski, nagłówki ani komunikaty | | |
| 3 | Czytelność nazw | przejdź nawigację po polsku | jedna nazwa na jedną rzecz; nie ma trzech różnych „Przegląd” ani „Zatwierdź”; „Instrukcja” w stopce otwiera instrukcję | | |
| 4 | Kontekst opcji w karcie | Zgłoszenia → „Kim jest „ktoś”…” | nad pytaniem „Kontekst opcji” z wariantami a), b), c); każdą opcję da się zrozumieć bez czytania reszty pliku | | |
| 5 | Rozstrzygnięcie z brakami | w karcie zaznacz odpowiedź tylko na część pytań (jeśli karta ma jedno pytanie, zrób to w drugiej karcie) i rozwiń „Podgląd zmiany karty” | status domyślnie ❔; zamknięcie jako ✅ wymaga zaznaczenia „Zamykam z N pytaniami bez odpowiedzi”; podgląd pokazuje zmianę. Prawdziwe rozstrzygnięcie kart możesz od razu zrobić | | |
| 6 | Okno scalania | strona task_16 → „Scal do master gry” (otwórz i zamknij bez scalania, chyba że chcesz scalić) | linia „Przegląd kodu: gotowe (27 paź, 08:10)”; zwinięte „Pokaż commity (N) i pliki (M)”; ostrzeżenie o niewypełnionym arkuszu | | |
| 7 | Przebiegi: koszt i dziennik | Przebiegi → otwórz przebieg analizy task_16 z 07:53 | na liście „Dziś: … USD (szacunek)”; w przebiegu filtr „Błędy i blokady”, czasy przy wpisach, ramka wyniku | | |
| 8 | Wyjaśnienie fałszywego alarmu | na czerwonym banerze naruszenia przy tym przebiegu kliknij „Wyjaśnione…”, wpisz powód (np. „plan edytowała sesja z terminala”) | baner i pozycja w „Teraz” znikają, a audyt zostaje w historii przebiegu | | |
| 9 | Okno startu przebiegu | strona task_20 → „Analizuj (agent)” → otwórz okno i zamknij bez startu | przycisk bez nazwy modelu; jeśli zapamiętane ustawienia różnią się od domyślnych, notka nad polami; na liście modeli jest Haiku | | |
| 10 | „Teraz” i stan | Praca | obok „Odśwież” napis „stan z HH:MM:SS”; powody „nie teraz” są szare, ostrzeżenia ⚠ wyraźne; nieaktywne przyciski czytelne; „Zmiany do wdrożenia” pod przyciskiem „Zaplanuj zadania” | | |
| 11 | Strona zadania | otwórz task_16 (na gałęzi) i task_20 (narzędziowe) | task_16: wynik przeglądu i gałąź nad wymaganiami; task_20: ramka „Wdróż w terminalu” z poleceniem i „Kopiuj polecenie”; przy przyciskach agenta cichy dopisek modelu | | |
| 12 | Arkusz: nawigacja | arkusz task_16 → „Następne puste ↓”, „Tylko puste” | przewija do kolejnego pustego pola; tryb pokazuje tylko puste wiersze | | |
| 13 | Arkusz: raport przebiegu i zamknięcie | w arkuszu task_16 otwórz „Dołącz raport przebiegu”, potem „Przenieś arkusz do done/” i ANULUJ | lista ostatnich raportów z gry; okno zamknięcia mówi „Puste pola: N z M” i wymaga potwierdzenia (nie zamykaj naprawdę, chyba że zagrałeś) | | |
| 14 | Zmiany → Zatwierdź zmiany | zmień zasadę z „Tytułem” i „Dlaczego”, „Zapisz na dysk”, potem „Zatwierdź zmiany →” (możesz cofnąć zmianę przed zatwierdzeniem) | opis commita wypełniony z tytułu i uzasadnienia; nad przyciskiem „Do planowania trafi: N zmian” z podziałem | | |
| 15 | Podsumowanie i liczebniki | Raporty → Podsumowanie, Start | karta „Teraz” zamiast starego „co dalej”; poprawne formy („1 błąd”, „2 błędy”, „5 błędów”) | | |
| 16 | Ogólne wrażenie | cała sesja | dashboard jest czytelniejszy niż przed zmianami; wpisz w uwagach, co nadal przeszkadza | | |

## Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| typy | `npx tsc --noEmit` | bez błędów | — |
| testy jednostkowe | `npm test` (foldery gry i przebiegów w katalogu tymczasowym) | 1976/1976 | — |
| przepływ HTTP | `npm run e2e` (jak wyżej) | 25/25 | — |
| build | `npx vite build` | OK | — |
| lint specyfikacji | `node dashboard/cli.ts lint` | 0 błędów, 0 uwag | — |
| przeglądarka bez okna | Edge, zrzuty 14 stron w PL i EN na prawdziwych danych, tylko odczyt | 0 wyjątków; po angielsku po polsku zostają tylko treści (po poprawkach T5 sprawdzone ponownie) | zrzuty w katalogu tymczasowym sesji |

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->
