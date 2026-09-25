# Factcheck test 01: rozbudowa kopalni, światło, dźwięk

> Zadanie: [task_01](../ai-tasks/task_01.md) · Przygotowano: 2026-09-25
> Uruchom grę (F5 → „Godot: main scene”) → START. Najlepiej na słuchawkach.
> Wpisz w kolumnie **Wynik**: ✅ OK / ❌ błąd / 💬 propozycja zmiany i dopisz uwagi.

## Co zostało dodane
- Nowa część kopalni na wschodzie: korytarz, pochylnia w dół, jaskinia z błękitnymi żyłami.
- Nowe oświetlenie (ciemność, mgła, lampa gracza, migoczące latarnie) i dźwięki (kapanie, skrzypienie, dudnienie, trzask latarni, stukanie kilofa).
- Węższa kolizja gracza: łatwiej przejść przez wąskie przejścia i szyny.
- 4 nowe obiekty do zbadania [E].

## Jak dojść do nowej części
Od startu idź do przodu wąską jaskinią aż do dużej, drewnianej hali. Tam skręć w prawo (na wschód) i idź długim korytarzem do końca, a potem w dół pochylnią. To około 25–30 s marszu.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Przejście z punktu startowego | Idź z miejsca startu do hali | Nigdzie się nie zacinasz, przejścia w jaskini da się pokonać | Prawidłowy | Brak |
| 2 | Szyny i progi | Chodź po szynach w hali i korytarzu | Postać przechodzi nad szynami bez blokowania się | Tak | |
| 3 | Pochylnia | Zejdź w dół i wróć na górę | Płynne schodzenie i wchodzenie, bez podskakiwania | OK | |
| 4 | Wózek na pochylni | Obejdź wózek z lewej i z prawej | Da się go ominąć z obu stron | OK | |
| 5 | Jaskinia | Obejdź całą jaskinię | Brak dziur w podłodze, nie da się wypaść poza mapę | OK | |
| 6 | Obiekty [E] | Zbadaj: wózek, żyłę (na ścianie jaskini), kilof, kartkę z szyfrem, a także 5 starych (worek, beczka, skrzynia, notatka, wiadro) | Podświetlenie, podpowiedź, opis; po odwróceniu wzroku żyła dalej świeci na niebiesko | Źle | Podłoga w jaskini jest za ciemna, da sie tam przenikać przez sciany, wyglada jakby kilof lezał na czarnej ciemnej masie. |

Niższe testy przenieść na dalszy etap
| 7 | Jasność ogólna | Chodź po całej mapie | Ciemno i klimatycznie, ale widać, gdzie iść. Zanotuj miejsca za ciemne albo za jasne |  | |
| 8 | Lampa gracza | Wejdź w ciemny fragment | Ciepłe światło wokół gracza, lekkie migotanie, cienie od belek | | |
| 9 | Latarnie | Podejdź do latarni w korytarzu | Migoczą jak płomień, cicho trzeszczą, nie rzucają dziwnych dużych cieni |  | |
| 10 | Błękit w jaskini | Z korytarza spójrz w stronę jaskini | Widać niebieską poświatę na końcu, żyły na filarach pulsują |  | |
| 11 | Dźwięki otoczenia | Postój w kilku miejscach po ~30 s | Kapanie, skrzypienie drewna, czasem dudnienie. Nic nie brzmi „cyfrowo” czy źle | | |
| 12 | Stukanie kilofa | Postój w jaskini 1–2 min | Co jakiś czas trzy stuknięcia zza ściany (niepokojące) | | |
| 13 | Pogłos | Mów „w głowie”, słuchaj kroków | Kroki i dźwięki mają pogłos jaskini | | |
| 14 | Ambient | Graj 3+ minuty | Tło dźwiękowe nie urywa się (zapętla) | | |
| 15 | Wydajność | Obserwuj płynność | Brak zauważalnych spadków klatek (ustawienia: mgła wolumetryczna, SSAO, SSIL) | | |
| 16 | Zapis i odczyt w nowej części | W jaskini [Esc] → SAVE GAME, potem MAIN MENU → LOAD GAME | Wracasz w to samo miejsce w jaskini | | |

## Twoje uwagi / propozycje
Póki co super jest.
