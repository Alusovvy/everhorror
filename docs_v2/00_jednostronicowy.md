# everhorror — jednostronicowy opis

> Status: 🟡 szkic · Właściciel: zespół · Aktualizacja: 2026-09-25 (task_05)

**W jednym zdaniu:** Schodzisz w głąb przeklętej kopalni błękitnego żelaza śladami zaginionego dziadka. Masz ograniczony czas, a ekspedycja wokół ciebie powoli traci zmysły.

| | |
|---|---|
| **Gatunek** | przygodówka + visual novel + horror mystery **[GDD]** |
| **Perspektywa** | FPP (eksploracja) + ekrany VN (dialogi, sceny) **[GDD]** |
| **Silnik** | Godot 4.7 (GDScript) |
| **Platforma** | PC (Windows) [propozycja] |
| **Czas gry** | pełna gra ❓; demo po task_05: tydzień (7 dni), ok. 2–3 h |
| **Gracz docelowy** | [propozycja] fani narracyjnego horroru i gier decyzyjnych pod presją czasu (Pathologic, Darkest Dungeon, Frostpunk), którzy wolą budowanie napięcia od walki |

## Premisa **[GDD]**
Czterdzieści lat temu twój dziadek, przewodnik, kryptograf i cichy przemytnik kruszcu, zaginął w kopalni. Wkrótce potem zawaliło się zejście do głębszych tuneli. Teraz następca tronu potrzebuje błękitnego żelaza na wojnę i kopalnię otwarto ponownie. Zaciągasz się do ekspedycji górniczej z mapami dziadka i jego amuletem, który zsyła ci obce sny.

## Filary (szczegóły w [01 Wizja](01_wizja.md))
1. **Czas to waluta.** Każda rozmowa i każda wyprawa coś kosztuje. Nie zdążysz zrobić wszystkiego.
2. **Ludzie się kruszą.** Towarzysze mają swoją poczytalność, zdrowie i historię. Mogą uciec, oszaleć albo zginąć, a to zmienia grę.
3. **Tajemnica w głąb.** Każdy poziom niżej odkrywa więcej prawdy o kopalni, dziadku i Pierwszym.

## Pętla rozgrywki (szczegóły w [02 Rozgrywka](02_rozgrywka.md))
```
Obóz (rozmowy, relacje, leczenie) → Stół z mapą (dokąd? WYRUSZ) → Wyprawa (tunele FPP, żyły, znaleziska)
      ↑                                                                   ↓   [M] dalej albo z powrotem
   Sen (noc: stany ludzi, gorączka)  ←  Podsumowanie wyprawy  ←  Powrót do obozu
   Termin tygodnia: 12 żył błękitu do wieczora dnia 7, rozliczenie rano w dniu 8
```

## Struktura świata
Kopalnia → jaskinie → Świątynia Onych, gdzie czeka **Pierwszy** **[GDD]**.

## Zakończenia
Kilka zakończeń. Proste wynikają z jednej decyzji (np. ucieczka po znalezieniu szkieletu dziadka), złożone z ukończonych linii questów (np. Drudzy pokonują Pierwszego) **[GDD]**.

## Stan projektu (2026-09-25)
Grywalne demo (task_03–task_05):
- **tydzień** w obozie ekspedycji: dziesięć postaci obozu z rozkładem dnia i czworo Drugich z Exitium spotykanych w tunelach, rozmowy VN z portretami 3D, gwara śląska górników,
- **15 miejsc wypraw** w grafie dróg: stół z mapą (WYRUSZ), mapa [M] w chodnikach, podsumowanie każdej wyprawy,
- **25 żył błękitu** i norma Kniazia (12 do dnia 7), upomnienia Racibora, dwa zakończenia tygodnia,
- **ekwipunek [I]** z przedmiotami do użycia i do oddania NPC; zdrowie, poczytalność i gorączka bohatera, śmierć z „od rana”,
- zadania i notes (z zakładką „Ludzie”), szyfr dziadka, ściana z zagadką, zapis całego stanu gry.

Nie ma jeszcze prologu na powierzchni ani zakończeń pełnej gry. Szczegóły w [task_05](../docs/ai-tasks/done/task_05.md).
