# Zapis, menu i opcje

> Status: 🟢 zaimplementowane (podstawa) · Właściciel: programista · Aktualizacja: 2026-09-25

## Cel
Standardowe funkcje, których gracz oczekuje: start, wczytanie, pauza, ustawienia, wyjście.

## Zasady
1. **Menu główne** (scena startowa): START, OPTIONS, LOAD GAME, EXIT. LOAD GAME jest nieaktywne, dopóki nie ma żadnego zapisu. ✅
2. **Pauza** pod [Esc] w trakcie gry: RESUME, SAVE GAME, LOAD GAME, OPTIONS, MAIN MENU, EXIT. Świat stoi, kursor jest uwolniony. [Esc] w podmenu wraca poziom wyżej, a na głównej liście pauzy wznawia grę. ✅
3. **Zapis ręczny w 3 slotach.** Slot pokazuje datę i godzinę zapisu, zapis nadpisuje slot bez pytania. ✅
4. **Co jest zapisywane:** obecnie scena i pozycja gracza z kierunkiem patrzenia. ✅ W przyszłości: czas, NPC, questy, ekwipunek, flagi, czyli cały `GameState`. ⬜
5. **Opcje:** czułość myszy, głośność ogólna, pełny ekran. Zapamiętywane między sesjami. ✅
6. [propozycja] **Autozapis na początku każdego dnia** (po śnie) do osobnego slotu. Pasuje do pętli dnia i chroni przed utratą postępu.
7. [propozycja] Zapis tylko w FPP, nie w trakcie scen VN.
8. Język UI menu: angielski (decyzja zespołu, zob. [dziennik](../decyzje.md)). Tekst w świecie: polski.

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Liczba slotów | 3 | `SaveManager.SLOT_COUNT` |
| Czułość myszy | suwak 1–20, domyślnie 5 (= 0,001 rad/px) | `options_panel.gd` |
| Głośność | 0–1, domyślnie 0,8 | `Settings.master_volume` |

## Przypadki brzegowe
- Uszkodzony plik zapisu → slot pokazany jako pusty, ostrzeżenie w logu. ✅
- Zapis z nowszej wersji gry → ❓ pole `version` już istnieje, migracje do zaplanowania.

## Implementacja
✅ Zob. [TDD: zapis i ustawienia](../06_techniczne.md#zapis-gry).

## Otwarte pytania
- ❓ Potwierdzenie nadpisania slotu?
- ❓ Czy w grze z presją czasu zapis ręczny w dowolnym momencie nie osłabia decyzji (zapisz, sprawdź, wczytaj)? [propozycja] Rozważyć tylko autozapis na początku dnia oraz zapis przy posłaniu.
- ❓ Dodatkowe opcje: głośność muzyki i efektów osobno, odwrócenie osi Y, FOV, rozdzielczość, jasność (ważna w ciemnym horrorze).
