# Zapis, menu i opcje

> Status: 🟢 zaimplementowane · Właściciel: programista · Aktualizacja: 2026-09-25 (task_05)

## Cel
Standardowe funkcje, których gracz oczekuje: start, wczytanie, pauza, ustawienia, wyjście.

## Zasady
1. **Menu główne** (scena startowa): START, OPTIONS, LOAD GAME, EXIT. LOAD GAME jest nieaktywne, dopóki nie ma żadnego zapisu. ✅
2. **Pauza** pod [Esc] w trakcie gry: RESUME, SAVE GAME, LOAD GAME, OPTIONS, MAIN MENU, EXIT. Świat stoi, kursor jest uwolniony. [Esc] w podmenu wraca poziom wyżej, a na głównej liście pauzy wznawia grę. ✅
3. **Zapis ręczny w 3 slotach.** Slot pokazuje datę i godzinę zapisu, zapis nadpisuje slot bez pytania. ✅
4. **Co jest zapisywane:** scena, pozycja gracza z kierunkiem patrzenia i cały `GameState`: dzień, godzina, flagi (w tym miejsce wyprawy, spotkanie w tunelach, otwarta ściana, zabrane przedmioty), przedmioty, notatki, zadania, stan NPC (poczytalność, zdrowie, reputacja, status), zdrowie, poczytalność i gorączka bohatera, trwająca wyprawa. ✅ Rozstawienie postaci liczy się po wczytaniu od nowa z pory dnia.
5. **Opcje:** czułość myszy, głośność ogólna, pełny ekran, **gwara śląska górników** (domyślnie włączona). Zapamiętywane między sesjami. ✅
6. [propozycja] **Autozapis na początku każdego dnia** (po śnie) do osobnego slotu na dysku. W pamięci już jest (pkt 9).
7. [propozycja] Zapis tylko w FPP, nie w trakcie scen VN.
8. Język UI menu: angielski (decyzja zespołu, zob. dziennik decyzji w specyfikacji). Tekst w świecie: polski.
9. **Poranek w pamięci** ✅: na początku każdego dnia (i po wczytaniu) `SaveManager` zapamiętuje stan. Po śmierci ekran końca ma przycisk „RETRY FROM MORNING”, który wraca do tego stanu. To nie jest slot na dysku.
10. **Wersja zapisu 3** (task_05) ✅. Zapisy z wersji 2 wczytują się: bohater zdrowy, bez wyprawy, amulet dopisany.

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Liczba slotów | 3 | `SaveManager.SLOT_COUNT` |
| Czułość myszy | suwak 1–20, domyślnie 5 (= 0,001 rad/px) | `options_panel.gd` |
| Głośność | 0–1, domyślnie 0,8 | `Settings.master_volume` |
| Gwara śląska | wł. / wył., domyślnie wł. | `Settings.silesian_dialect` (`user://settings.cfg`) |

## Przypadki brzegowe
- Uszkodzony plik zapisu → slot pokazany jako pusty, ostrzeżenie w logu. ✅
- Zapis z nowszej wersji gry → ❓ pole `version` już istnieje, migracje do zaplanowania.

## Implementacja
✅ Autoloady `SaveManager` i `Settings` (zob. `CLAUDE.md`, sekcja Systems).

## Otwarte pytania
- ❓ Potwierdzenie nadpisania slotu?
- ❓ Czy w grze z presją czasu zapis ręczny w dowolnym momencie nie osłabia decyzji (zapisz, sprawdź, wczytaj)? [propozycja] Rozważyć tylko autozapis na początku dnia oraz zapis przy posłaniu.
- ❓ Dodatkowe opcje: głośność muzyki i efektów osobno, odwrócenie osi Y, FOV, rozdzielczość, jasność (ważna w ciemnym horrorze).
