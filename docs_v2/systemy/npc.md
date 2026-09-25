# Postacie niezależne (NPC)

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 2 (Ludzie się kruszą) · Źródło: GDD §4, §5

## Cel
Ekspedycja to drugi, obok czasu, zasób gry. Towarzysze dają informacje, przedmioty i umiejętności, ale sami się psują. Gracz nie dowodzi nimi, tylko zdobywa ich przychylność **[GDD]**.

## Doświadczenie gracza
„Znam tych ludzi. Widzę, że Mirosław jest coraz gorzej. Czy mam czas mu pomóc, skoro jutro muszę zejść niżej?”

## Zasady
1. **Każdy NPC ma kartę** według [szablonu NPC](../szablony/npc.md): frakcję, rolę, poczytalność, zdrowie, informacje, przedmioty, zadania, historię i efekt przy 0% poczytalności **[GDD]**.
2. **Frakcje:** Drudzy / Ekspedycja / Inna. Więcej nie dodajemy **[GDD]**.
3. **Rola** decyduje o umiejętnościach. Niektóre akcje wymagają obecności NPC o danej roli **[GDD]**.
4. **Poczytalność.** Gdy spadnie do 0, uruchamia się unikalny dla postaci efekt **[GDD]**, np.:
   - górnik (przykład z GDD): ucieka z kopalni,
   - Mirosław z Głuszy: wysadza się z beczką prochu, a z nim znika możliwość wysadzenia 2–3 tuneli.
5. **Maksymalna poczytalność zależy od postaci** (Mirosław: 50 zamiast 100) **[GDD]**.
6. **Zdrowie.** NPC odnoszą rany, gracz może próbować je leczyć, a NPC mogą umrzeć **[GDD]**.
7. **Obecność.** NPC pojawiają się w obozie i z niego znikają **[GDD]**. [propozycja] Każdy ma stan: *w obozie / w tunelach / zaginiony / uciekł / martwy*.
8. **Zadania** NPC nagradzają informacją, przedmiotem albo reputacją u tego NPC **[GDD]**.
9. **Pomoc w tunelach.** W panelu VN gracz wybiera np. *[Poproś Mirosława o pomoc, bo zna się na prochu]*. NPC nie idzie fizycznie z graczem, ale akcja kosztuje dużo czasu **[GDD]**. Warunki: NPC żyje, jest w obozie i [propozycja] ma wystarczającą reputację i poczytalność.
10. **Reputacja** [propozycja] jest liczona osobno u każdego NPC (np. −100..100). Odblokowuje informacje, opcje dialogowe i pomoc.
11. [propozycja] **Gracz nie widzi liczb poczytalności**, tylko objawy: zmiany w dialogach, zachowaniu, wyglądzie miejsca w obozie. Wspiera to horror i filar 2.

## Dane i strojenie
[propozycja]

| Parametr | Wartość | Uwagi |
|---|---|---|
| Poczytalność max | 100 (wyjątki w karcie) | |
| Zdrowie max | 100 | |
| Reputacja | −100..100, start 0 | |
| Progi objawów poczytalności | 75 / 50 / 25 / 0 | inne dialogi i zachowanie na każdym progu |
| Nocny spadek poczytalności | ❓ | zależny od głębokości, eventów, śmierci innych |

## Zależności
- **[Czas](czas.md)**: rozmowy i pomoc kosztują czas, noc rozlicza stany.
- **[Dialogi](dialogi_vn.md)**: warunki i efekty opcji zmieniają reputację i poczytalność.
- **[Eksploracja](eksploracja_kopalni.md)**: pomieszczenia wymagające roli.
- **[Fabuła](../swiat/fabula.md)**: zakończenia zależą od stanu NPC.

## Przypadki brzegowe
- NPC potrzebny do questa ginie → quest nieudany, informacja w notesie.
- 0% poczytalności w trakcie, gdy NPC jest „w tunelach” → [propozycja] efekt rozlicza się w nocy, gracz dowiaduje się rano.
- Jedyny NPC o danej roli znika → pomieszczenia wymagające roli są zablokowane na stałe. To zamierzona konsekwencja (przykład: Mirosław).

## Implementacja
⬜ Plan: `NpcData` (`Resource`) z polami karty + rejestr NPC w `GameState`. Zob. [TDD](../06_techniczne.md#planowane-systemy).

## Otwarte pytania
- ❓ Co obniża, a co podnosi poczytalność?
- ❓ Czym się leczy rany (przedmioty, czas, medyk)? Czy leczenie może się nie udać?
- ❓ Czy jest też reputacja u frakcji?
- ❓ Ilu NPC w pełnej grze, a ilu w pionowym wycinku?
