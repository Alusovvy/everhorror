# Ekwipunek

> Status: 🔴 do ustalenia · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 1

## Cel
Przygotowanie do wyprawy jako decyzja: co zabrać, skoro nie da się zabrać wszystkiego.

## Zasady
1. Przed wyprawą gracz wybiera przedmioty, np. paliwo do lampy i liny **[GDD]**.
2. Przedmioty można dostać od NPC (za zadania, reputację) **[GDD]**.
3. [propozycja] Na wyprawę jest ograniczona liczba miejsc (np. 4).
4. [propozycja] **Paliwo do lampy** to zasób wyprawy. Bez światła część pomieszczeń jest niedostępna albo rośnie ryzyko.
5. [propozycja] Przedmioty są **kluczami**: lina → zejście w szyb, łom → skrzynia, proch (przez NPC) → zawalisko.
6. **Amulet dziadka** z kawałkiem błękitnej stali jest zawsze przy graczu (fabuła) **[GDD, §2.1]**. ❓ Czy ma działanie mechaniczne (sny, wizje, podpowiedzi przy zagadkach)?

## Dane i strojenie
| Parametr | Wartość | Uwagi |
|---|---|---|
| Miejsca na wyprawę | [propozycja] 4 | |
| Paliwo | ❓ | jednostki na wyprawę, zużycie |

## Zależności
[Eksploracja](eksploracja_kopalni.md), [NPC](npc.md), [Dialogi](dialogi_vn.md) (warunek: posiadany przedmiot), [Zapis](zapis_i_opcje.md).

## Implementacja
⬜ Plan: `ItemData` (`Resource`) + lista w `GameState` + UI wyboru przy wyjściu z obozu.

## Otwarte pytania
- ❓ Czy przedmioty się zużywają?
- ❓ Czy jest magazyn obozu (to, czego nie zabieramy)?
- ❓ Mechanika amuletu.
