# Interakcje z otoczeniem

> Status: 🟢 zaimplementowane · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 3

## Cel
Pozwolić graczowi „czytać” świat: przedmioty dają opis, informację albo prowadzą do sceny VN **[GDD]**. To główny sposób odkrywania lore w FPP.

## Doświadczenie gracza
Podchodzę bliżej, przedmiot delikatnie się rozjarza (ciepłe światło jak od lampy), widzę „[E] Stół z mapą · Zaplanuj wyprawę”, naciskam i coś się dzieje.

## Zasady
1. Gracz celuje w obiekt z odległości **do 2,5 m**. Obiekt się podświetla, pojawia się podpowiedź „[E] …”, a celownik zmienia kolor.
2. Ściany zasłaniają obiekty, więc przez skałę nie da się wejść w interakcję.
3. **Rodzaje działania** ✅:
   - **opis** (panel na dole ekranu, znaleziska zostają widoczne dłużej),
   - **rozmowa VN** (NPC, ściana w kaplicy),
   - **użycie** (stół z mapą, posłanie, drogowskazy w miejscach wypraw, które otwierają mapę [M]).
4. **Efekty przy użyciu** ✅: flaga, notatka, przedmiot (także kilka naraz: `bandaze:2,swieca`), wpis zadania, koszt czasu (w podpowiedzi „· 1 h”), zniknięcie po podniesieniu, rana (`wound`), zmiana poczytalności (`sanity_change`) i wpis do podsumowania wyprawy (`expedition_event`). Rana i poczytalność działają tylko przy pierwszym użyciu, jeśli obiekt ma flagę.
9. **Wymagany przedmiot** ✅ (`required_item`): podpowiedź dopisuje „(potrzebny: łom)”, a [E] bez przedmiotu tylko mówi, czego brakuje (`missing_text`). Nie kosztuje wtedy czasu i nie otwiera opisu. Przedmiot może się zużyć (`consume_item`).
5. **Panel opisu zamyka [E] albo odwrócenie wzroku** ✅. Przy otwartym opisie [E] tylko zamyka panel i nigdy nie używa obiektu drugi raz, więc nie ma podwójnego kosztu czasu. Opis przedmiotu, który znika po użyciu (podniesienie, zaznaczona żyła), jest przypięty na 12 s albo do [E] **[poprawka po zgłoszeniu, 2026-09-25]**.
6. **Dostępność** ✅: obiekt może pojawić się dopiero po fladze (np. palik przy zaznaczonej żyle, nisza w kaplicy) albo zniknąć po niej (np. ściana z zagadką po rozwiązaniu). Kod może też wyłączyć obiekt, np. NPC, którego nie ma w obozie.
7. **Obóz się zmienia** **[GDD]**: postacie zmieniają miejsca według pory dnia, pojawiają się i znikają przedmioty (tobołek, kryształ, palik).
8. **Nie dajemy opisu [E] rekwizytom, za którymi albo przy których stoi postać** (lada Tekli, stół z mapą zasłania tylko do wysokości blatu). Opis przechwytuje celowanie i utrudnia rozmowę **[uwaga z testu, 2026-09-25]**. Taki rekwizyt dostaje samą kolizję.

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Zasięg interakcji | 2,5 m | `InteractRay` w `player.tscn` |
| Kolor podświetlenia | ciepły bursztyn (1.0, 0.72, 0.38) | `interact_highlight.gdshader` |
| Margines strefy interakcji | 0,05 m (małe przedmioty 0,1–0,2 m) | `Interactable.padding` |

## Jak dodać obiekt (dla zespołu)
1. W generatorze sceny (`tools/generators/gen_*.gd`) użyj `interactable()` albo `look()` przy danym rekwizycie. W scenie ręcznej dodaj **Area3D** ze skryptem `interactable.gd`.
2. Wpisz `display_name` i `description` (albo `action`, `dialogue`, efekty).
3. Kształt kolizji dopasuje się sam do modelu przy starcie. `solid = true` dodaje blokadę ruchu. `highlight_target` wskazuje, co ma się podświetlać, jeśli nie rodzic.

## Implementacja
✅ `script/interactable.gd` (akcje DESCRIBE / DIALOGUE / USE, efekty, warunki flag i przedmiotów, `blocked_reason()`, `set_enabled`), `script/player.gd` (promień, sygnały), `scene/hud.tscn`.

## Otwarte pytania
- ❓ Czy podświetlenie nie jest zbyt „growe” dla horroru? Alternatywa to sama podpowiedź tekstowa.
