<!--
Szablon zadania dla agenta AI. Skopiuj jako task_XX.md (XX = kolejny numer) i wypełnij sekcję Wymagania.
Reszta pliku należy do agenta: dopisuje swoje sekcje pod wymaganiami i kończy plik podsumowaniem.
Zasady pracy z folderem: zob. INFO.md.
Tytuł (opcjonalny): linia „# task_XX: <krótki tytuł>” pod tym komentarzem; dashboard pokazuje ją jako nazwę zadania, a bez niej nazwą jest początek wymagań. Usuń ją, jeśli niepotrzebna.
Poziom (zalecany, D-36): linia „Poziom: tekst”, „Poziom: narzędzia” albo „Poziom: rozgrywka” (jedna wartość) w bloku metadanych pod Wymaganiami, obok „Rodzaj:”; bez niej zadanie jest „rozgrywka”. tekst = tylko teksty, dialogi, dokumenty (bez arkusza); narzędzia = tools/, generatory, skille, dashboard, bez zmian w rozgrywce (bez arkusza i bez builda); rozgrywka = wszystko, co zmienia to, co gracz przeżywa (arkusz dla człowieka, jeden na build). Nadaje go /spec-tasks; zasady: INFO.md, „Poziom, pliki i ryzyko”.
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

## Test
<!-- Jeśli zadanie zawiera implementację: link do docs/human-tasks/factcheck-test-XX.md -->

## Podsumowanie
