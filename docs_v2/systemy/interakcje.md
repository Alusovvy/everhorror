# Interakcje z otoczeniem

> Status: 🟢 zaimplementowane (podstawa) · Właściciel: Roland · Aktualizacja: 2026-09-25 · Filary: 3

## Cel
Pozwolić graczowi „czytać” świat: przedmioty dają opis, informację albo prowadzą do sceny VN **[GDD]**. To główny sposób odkrywania lore w FPP.

## Doświadczenie gracza
Podchodzę bliżej, przedmiot delikatnie się rozjarza (ciepłe światło jak od lampy), widzę „[E] Beczka”, naciskam i czytam krótki opis w klimacie świata.

## Zasady
1. Gracz celuje w obiekt z odległości **do 2,5 m**. Obiekt się podświetla, pojawia się podpowiedź „[E] nazwa”, a celownik zmienia kolor.
2. **[E]** otwiera panel z nazwą i opisem. Ponowne **[E]** albo odwrócenie wzroku go zamyka.
3. Ściany zasłaniają obiekty, więc przez skałę nie da się wejść w interakcję.
4. Rodzaje efektów **[GDD]**:
   - **opis / informacja** ✅,
   - **przejście do VN** ⬜,
   - [propozycja] **koszt czasu** ⬜: pokazany w podpowiedzi,
   - [propozycja] **podniesienie przedmiotu, ustawienie flagi** ⬜.
5. **Obóz się zmienia** **[GDD]**: te same miejsca mogą mieć inny opis albo inne obiekty w kolejnych dniach. [propozycja] Opis może zależeć od dnia lub flagi.

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Zasięg interakcji | 2,5 m | `InteractRay` w `player.tscn` |
| Kolor podświetlenia | ciepły bursztyn (1.0, 0.72, 0.38) | `interact_highlight.gdshader` |
| Pulsowanie | 3,0 | shader, `pulse_speed` |
| Margines strefy interakcji | 0,05 m (małe przedmioty: 0,12 m) | `Interactable.padding` |

## Obecne obiekty (poziom testowy)
| Obiekt | Nazwa w grze |
|---|---|
| Bag2 | Worek z prowiantem |
| Barrel2 | Beczka |
| Crate | Skrzynia z zapasami |
| Note | Zwinięta notatka (fragment notatek dowódcy poprzedniej ekipy) |
| Bucket | Wiadro |

Teksty są zastępcze, ale pisane w tonie świata. Do przeglądu przez Rena.

## Jak dodać obiekt (dla zespołu)
1. Wstaw model (np. z `assets/prop_pack/Exports/glTF`) do sceny.
2. Dodaj mu dziecko **Area3D** ze skryptem `interactable.gd`.
3. Wpisz `display_name` i `description` w inspektorze.
4. Kształt kolizji dopasuje się sam do modelu przy starcie. `solid = true` dodaje też blokadę ruchu.

## Implementacja
✅ `script/interactable.gd`, `script/player.gd` (promień, sygnały), `scene/hud.tscn`. Szczegóły w [TDD](../06_techniczne.md#interakcje).

## Otwarte pytania
- ❓ Czy podświetlenie ma się pojawiać przy samym zbliżeniu (bez celowania)? Obecnie trzeba celować, żeby przy kilku obiektach obok siebie było jasne, który zostanie użyty.
- ❓ Czy podświetlenie nie jest zbyt „growe” dla horroru? Alternatywa to sama podpowiedź tekstowa.
