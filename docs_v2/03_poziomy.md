# 03 Poziomy

> Status: 🔴 do ustalenia · Właściciel: — · Aktualizacja: 2026-09-25

## Struktura gry **[GDD]**
| Warstwa | Charakter | Zawartość |
|---|---|---|
| **Wejście / prolog** | zagajnik, wóz, wejście z pulsującym światłem | FPP, wstęp |
| **Obóz** | hub. Zmienia się z dnia na dzień | NPC, stół z mapą, ekwipunek, posłanie |
| **Kopalnia** | ludzka robota: szyny, podpory, wózki | pomieszczenia, złoża, notatki |
| **Jaskinie** | naturalne, obce | ❓ |
| **Świątynia Onych** | finał | Pierwszy |

❓ Czy obóz jest jeden, czy ekspedycja przenosi go niżej? GDD wspomina „pierwszy obóz”.

## Zasady projektowania segmentów
[propozycja]
1. **Segment = jedna scena Godot** wczytywana po wyborze na mapie. Ma punkt wejścia i wyjścia z powrotem do obozu.
2. **Mały i gęsty:** 2–5 minut eksploracji, 3–6 obiektów interakcji, jeden „powód, by przyjść” (złoże, notatka, zagadka, odnoga).
3. **Czytelne drogi:** światło (lampy, żyły błękitnego żelaza) prowadzi gracza zamiast znaczników w interfejsie.
4. **Zablokowane przejścia są widoczne** (zawalisko, szyb bez liny), żeby gracz wiedział, czego szukać albo kogo poprosić.
5. **Budujemy z modułowych zestawów** (Mine & Caves, Sewer, prop_pack). Nie edytujemy plików zestawów, tylko wstawiamy ich instancje.

## Obecny poziom testowy
`scene/world.tscn`: przykładowy poziom z zestawu Mine & Caves (tunel ze skalną podłogą), kilka rekwizytów, ambient jaskini, 5 obiektów interakcji ([Interakcje](systemy/interakcje.md#obecne-obiekty-poziom-testowy)). Służy do testów mechanik, nie jest docelowym poziomem.

## Szablon opisu segmentu
```
### [Nazwa pomieszczenia]
- Warstwa: kopalnia / jaskinie / świątynia
- Koszt podróży z obozu: X h
- Wymaga: (przedmiot / rola NPC / flaga)
- Zawartość: złoża, notatki, zagadka, obiekty interakcji
- Odnogi: → [pomieszczenia]
- Event VN przy wejściu: tak/nie
- Stan zmienia się, gdy: …
```

## Otwarte pytania
- ❓ Lista pomieszczeń do pionowego wycinka.
- ❓ Obóz: osobna scena, jak wygląda, gdzie stoją NPC.
