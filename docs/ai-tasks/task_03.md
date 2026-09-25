Requirements:
1. Poprawki z factcheck-test-01 (pkt 6): za ciemna podłoga w jaskini, przenikanie przez ściany jaskini, „czarna masa” pod kilofem.
2. Stan gry i czas: autoload `GameState` (dzień, godzina, flagi), dzień = 16 h, koszt czasu widoczny w podpowiedzi, zapis/odczyt całego stanu.
3. Tryb VN na Dialogue Manager: dialogi z warunkami (reputacja, flagi, przedmioty) i efektami (czas, reputacja, poczytalność, notatki); portret NPC renderowany z modelu 3D.
4. NPC: `NpcData` wg karty z GDD; Mirosław z Głuszy + drugi NPC (roboczo: stary górnik, który znał dziadka); modele i animacje Quaternius (CC0).
5. Stół z mapą i podróż: „Stara sztolnia (wschód)” (obecny korytarz + jaskinia) i „Zawalony chodnik (zachód)” — zablokowany, otwiera go pomoc Mirosława (wysadzenie).
6. Noc: posłanie → rozliczenie nocy (poczytalność, flagi) → sen w trybie VN (amulet) → „Dzień 2” → widoczne zmiany w obozie zależne od wyborów z dnia 1 → plansza „Koniec wersji demo”.
7. Notes pod [J]: aktywne zadania i znalezione notatki.
8. Szlif: obóz z rekwizytów w drewnianej hali (posłanie, ognisko, stół z mapą, skrzynie), prawdziwe dźwięki zamiast generowanych tam, gdzie się da (CC0), factcheck-test-03.

Kontekst:
- Najmniejszy vertical slice wg `docs/MECHANICS.md` §12 i `docs_v2/01_wizja.md`: obóz + jeden poziom tuneli + 2 NPC + pełny cykl dzień → noc → dzień, ok. 10–15 min gry, pokazuje trzy filary (czas, ludzie się kruszą, tajemnica w głąb).
- Nazwa gry wciąż w dyskusji — na razie wszędzie **Everhorror** (także na planszy końcowej).

Założenia (zaakceptowane):
- Dzień 16 h; rozmowa 1 h, podróż 2 h, pomoc NPC 4 h; po wyczerpaniu godzin trzeba iść spać.
- Poczytalność niewidoczna jako liczba — tylko objawy w dialogach.
- Teksty gry po polsku; imię i historia drugiego NPC robocze, do poprawki przez Rena.
- Brak śmierci gracza w FPP.
- Darmowe assety tylko z licencją CC0 lub równoważną (wpis do `docs_v2/05_oprawa.md`).

Kryteria akceptacji:
- Da się przejść cały scenariusz: obóz → rozmowy → mapa → wyprawa → powrót → sen → Dzień 2 → koniec demo, bez błędów.
- Wybory z dnia 1 (pomoc Mirosławowi / zadanie / wyprawa) dają widoczną różnicę w dniu 2.
- Zapis w dowolnym momencie FPP i odczyt przywraca dzień, godzinę, stan NPC, notes i pozycję.

Poza zakresem:
- Walka, ekwipunek z limitem miejsc, rany i leczenie, frakcje, więcej poziomów, zakończenia gry.

Priorytet: wysoki

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione

## Decyzje i założenia

## Czego potrzebuję od Ciebie

## Test

## Podsumowanie
