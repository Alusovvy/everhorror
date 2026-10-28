<!--
Szablon zadania dla agenta AI. Skopiuj jako task_XX.md (XX = kolejny numer) i wypełnij sekcję Wymagania.
Reszta pliku należy do agenta: dopisuje swoje sekcje pod wymaganiami i kończy plik podsumowaniem.
Zasady pracy z folderem: zob. INFO.md.
Część arkusza (D-38, tylko poziom „rozgrywka”): wdrożenie pisze ją w sekcji „## Część arkusza” poniżej, w TYM pliku, nigdy w docs/human-tasks/. Serwer przepisuje ją do arkusza cyklu `factcheck-cykl-NN.md` przy buildzie cyklu, dopisując puste kolumny człowieka „wynik” i „uwagi”; agent ich nie wypełnia. Poprawki aktualizują sekcję, gdy zmieniają to, co sprawdzić.
Tytuł (opcjonalny): linia „# task_XX: <krótki tytuł>” pod tym komentarzem; dashboard pokazuje ją jako nazwę zadania, a bez niej nazwą jest początek wymagań. Usuń ją, jeśli niepotrzebna.
Poziom (zalecany, D-36): linia „Poziom: tekst”, „Poziom: narzędzia” albo „Poziom: rozgrywka” (jedna wartość) w bloku metadanych pod Wymaganiami, obok „Rodzaj:”; bez niej zadanie jest „rozgrywka”. tekst = tylko teksty, dialogi, dokumenty (bez części arkusza); narzędzia = tools/, generatory, skille, dashboard, bez zmian w rozgrywce (bez części arkusza i bez testu eksportu); rozgrywka = wszystko, co zmienia to, co gracz przeżywa (część arkusza w tym pliku, patrz niżej; arkusz jest jeden na cykl oceny, D-38). Nadaje go /spec-tasks; zasady: INFO.md, „Poziom, pliki i ryzyko”.
Sekcja „## Plan” analizy (dopisuje ją agent, nie kopiuj jej tutaj pustej) kończy się dwiema liniami, każda w jednym wierszu: „Pliki: <ścieżki lub wzorce po przecinku, bez apostrofów>” (pliki i foldery, które ruszy wdrożenie) i „Ryzyko: niskie|średnie|wysokie”; zasady: INFO.md.
Rodzaj (opcjonalny): „Rodzaj: narzędzia” albo „Rodzaj: dokumentacja” oznacza zadanie narzędziowe lub dokumentacyjne, bez zmian w rozgrywce. Formularz „Nowe zadanie narzędziowe” w dashboardzie dopisuje tę linię sam, razem z „Zleca: <imię> (dashboard, <data>)”. Zmiana rozgrywki nie jest zadaniem narzędziowym: najpierw trafia do specyfikacji, a /spec-tasks robi z niej zadanie z linią „Źródło: specyfikacja <sha7>”.
-->

# task_XX: <krótki tytuł>

Wymagania:
1. <co ma być zrobione — jedno zadanie w punkcie, konkretnie>
2. <...>

<!-- Opcjonalne (usuń, jeśli niepotrzebne): -->
Rodzaj: <narzędzia / dokumentacja>
Poziom: <tekst / narzędzia / rozgrywka>

Kontekst:
- <po co to robimy / z czym się wiąże, np. ID i dokument w specyfikacji; źródła i pierwszeństwo: specification/WORKFLOW.md>

Kryteria akceptacji:
- <po czym poznam, że jest dobrze, np. "po [E] na skrzyni widać opis">

Poza zakresem:
- <czego NIE robić w tym zadaniu>

Priorytet: <niski / średni / wysoki> · Termin: <opcjonalnie>

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->

## Część arkusza
<!-- Tylko poziom „rozgrywka”. Opis dla człowieka, który zagra cykl oceny; agent nie wpisuje wyników. -->

### Co zostało dodane
- <co się zmieniło, językiem gracza; ID reguł ze specyfikacji>

### Test

| # | co sprawdzić | jak | oczekiwany wynik |
|---|---|---|---|
| 1 | <co sprawdzić> | <kroki w grze> | <co ma być widać> |

### Wyniki automatu (agent)
<!-- Testy uruchomione przez agenta, z prawdziwymi nazwami, poleceniami i wynikami. To nie jest weryfikacja człowieka. -->

## Test
<!-- Jeśli zadanie zawiera implementację: wyniki testów agenta; część do ogrania przez człowieka jest w „Części arkusza” powyżej (D-38) -->

## Podsumowanie
