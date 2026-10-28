<!--
Szablon arkusza cyklu oceny (D-38), tylko dla serwera dashboardu. Agent go NIE kopiuje i nie zakłada arkusza: część arkusza pisze w własnym pliku zadania (sekcja „## Część arkusza”, zob. docs/ai-tasks/task_template.md), a arkusz `factcheck-cykl-NN.md` składa serwer razem z buildem cyklu. Zasady: INFO.md w tym folderze (sekcja „Cykl oceny”).
Serwer podstawia: {{cykl}} i {{n}} (numer cyklu), {{data}}, {{kod}} (kod w rogu menu), {{zadania}} (linki do zadań z częścią), {{bez-czesci}} (zadania poziomów tekst i narzędzia, które weszły do buildu bez części) i {{build}} (`<sha7> (<zip>)`). Wymagane są {{n}}, {{zadania}} i {{build}}; bez nich serwer używa wbudowanego wzorca. Ten komentarz serwer pomija.
Za nagłówkiem serwer dopisuje na KOŃCU części zadań w kolejności scalenia do `master` (`## Część: task_NN — <tytuł>`, z podsekcjami „Co zostało dodane”, „Test”, „Wyniki automatu (agent)”). Do tabel bez kolumn człowieka dopisuje puste „wynik” i „uwagi”. Linię `> Build:` pisze serwer przy tworzeniu arkusza; agent jej nie rusza.
Kolumny „wynik” i „uwagi” oraz sekcję „Uwagi ogólne” wypełnia człowiek. Sekcja „Raport przebiegu” jest zawsze (gra zapisuje raport przebiegu od 0.5.3); znacznik nad tabelą i dopisek „(człowiek)” w nagłówkach są obowiązkowe, bez nich formularz tabeli się nie pokaże.
-->

# Cykl {{cykl}}: arkusz do ogrania

> Cykl: {{n}} · Przygotowano: {{data}} · Kod w rogu menu: {{kod}}
> Zadania: {{zadania}}
> W buildzie bez części (poziomy tekst i narzędzia): {{bez-czesci}}
> Build: {{build}}
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis. Każda część poniżej to jedno zadanie z tego cyklu, a wszystkie grasz na jednym buildzie. „Zamknij arkusz” oddaje wyniki i zamyka cykl: ❌, 💬 i uwagi stają się zadaniami następnego cyklu.

## Raport przebiegu: dołącz plik
Po zakończeniu otwarcia lub tygodnia kliknij w dashboardzie „Dołącz raport przebiegu”: para plików z folderu raportów gry trafia obok arkusza (`raporty/`), a linki do niej do tabeli. Jeśli raport nie powstał, zapisz to w uwagach.

<!-- człowiek -->
| Plik `.md` (człowiek) | Plik `.json` (człowiek) | Uwagi (człowiek) |
|---|---|---|
| | | |

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->
