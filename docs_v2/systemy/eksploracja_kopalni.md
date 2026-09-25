# Eksploracja kopalni

> Status: 🟡 szkic · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 1, 3 · Źródło: GDD §1, §4

## Cel
Dać graczowi poczucie schodzenia w nieznane: każde nowe pomieszczenie to nowa wiedza, zasoby i ryzyko, a dojście tam kosztuje czas.

## Doświadczenie gracza
Samotne, ciche przeszukiwanie tuneli w FPP. Mapa, którą gracz uzupełnia, i ślady dziadka, które się z nią pokrywają albo nie.

## Zasady
1. **Struktura:** kopalnia → jaskinie → Świątynia Onych **[GDD]**.
2. **Wybór celu przy stole z mapą w obozie** **[GDD]**. Podróż kosztuje czas, eksploracja w 3D już nie **[GDD]**.
3. **Mapa pokazuje** **[GDD]**:
   - odkryte pomieszczenia,
   - zmapowane złoża błękitnego żelaza,
   - niezbadane odnogi.
4. [propozycja] **Mapa to graf pomieszczeń.** Każde ma stan: *nieznane → widoczna odnoga → odkryte → (zablokowane)* oraz koszt podróży.
5. [propozycja] **Co odblokowuje pomieszczenia:** eksploracja sąsiednich, notatki i mapy dziadka, pomoc NPC (wysadzenie, podpory, lina), przedmioty.
6. **Zagadki:** proste, logiczne **[GDD]**. [propozycja] Motyw przewodni to szyfry i mapy, bo dziadek był kryptografem.
7. **Znaleziska:** błękitne żelazo i notatki dowódcy poprzedniej ekipy **[GDD]**.
8. [propozycja] Przejścia między segmentami tuneli czasem odbywają się w trybie VN (opis zejścia, decyzja), zgodnie z GDD §1.

## Dane i strojenie
| Parametr | Wartość | Uwagi |
|---|---|---|
| Liczba pomieszczeń w pionowym wycinku | [propozycja] 4–6 | |
| Liczba pomieszczeń w pełnej grze | ❓ | |
| Koszt podróży | zob. [Czas](czas.md#dane-i-strojenie) | |

## Zależności
[Czas](czas.md), [NPC](npc.md) (pomoc, role), [Ekwipunek](ekwipunek.md) (klucze do pomieszczeń), [Interakcje](interakcje.md), [Poziomy](../03_poziomy.md).

## Zagrożenie
❓ **Kluczowa decyzja projektowa.** Czy w tunelach jest bezpośrednie zagrożenie w FPP (pościg, śmierć gracza), czy horror opiera się na atmosferze i konsekwencjach w VN?
[propozycja] Brak bezpośredniej śmierci w FPP, bo pasuje to do zasady „eksploracja 3D nie kosztuje czasu”. Zagrożenie przychodzi przez eventy VN, rany NPC i spadek poczytalności.

## Wydobycie
❓ Po co gracz wydobywa błękitne żelazo? Możliwości: dzienna norma dla ekspedycji (reputacja), waluta wymiany z NPC, warunek zakończenia (dostawa dla Kniazia) albo tylko fabuła.

## Przypadki brzegowe
- Jedyna droga dalej wymaga NPC, który nie żyje → potrzebna jest alternatywna, droższa ścieżka, albo to świadomy koniec danej linii (do decyzji przy projektowaniu poziomów).
- Gracz nie ma paliwa do lampy → [propozycja] pomieszczenia „ciemne” są niedostępne.

## Implementacja
🟡 Chodzenie w FPP po testowym poziomie (`world.tscn`, zestaw Mine & Caves). Mapa, podróż i segmenty ⬜.

## Otwarte pytania
- ❓ Zagrożenie w FPP (wyżej).
- ❓ Rola wydobycia (wyżej).
- ❓ Czy pomieszczenia można odwiedzać wielokrotnie i czy się zmieniają?
