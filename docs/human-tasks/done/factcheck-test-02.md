# Factcheck test 02: logo w menu i pauzie

> Zadanie: [task_02](../../ai-tasks/done/task_02.md) · Przygotowano: 2026-09-25
> Uruchom grę w VS Code (F5 → „Godot: main scene”) albo z edytora Godot.
> Wpisz w kolumnie **Wynik**: ✅ OK / ❌ błąd / 💬 propozycja zmiany i dopisz uwagi.

## Co zostało dodane
- Logo `assets/logo.png` w menu głównym (zamiast tekstu „EVERHORROR”), pojawia się płynnie przy starcie.
- Mniejsze logo w menu pauzy nad napisem „PAUSED”.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Logo w menu głównym | Uruchom grę | Na środku u góry logo EVEROLD, w ciągu ~1,5 s płynnie przechodzi z przezroczystości do pełnej widoczności | Spoko | |
| 2 | Jakość logo | Przyjrzyj się krawędziom liter | Brak białej obwódki czy tła, ostre krawędzie (szara poświata to element samego logo) | Spoko | |
| 3 | Menu pod logo | Najedź na przyciski, kliknij OPTIONS i LOAD GAME, potem BACK | Przyciski działają, logo zostaje na miejscu, nic na siebie nie nachodzi | Spoko | |
| 4 | Logo w pauzie | START → w grze [Esc] | Mniejsze logo nad „PAUSED”, wszystkie 6 przycisków mieści się na ekranie | Spoko | |
| 5 | Pauza: podekrany | W pauzie: SAVE GAME, LOAD GAME, OPTIONS | Lista slotów i opcje mieszczą się pod logo, nic nie wychodzi poza ekran | Spoko | |
| 6 | Pełny ekran | OPTIONS → Fullscreen: wł., powtórz 1 i 4 | Logo i menu skalują się poprawnie, bez rozciągnięcia | Spoko | |
| 7 | Małe okno | Zmniejsz okno gry (przeciągnij róg) | Menu nadal czytelne; zanotuj, od jakiego rozmiaru zaczyna się psuć | Ok | |
| 8 | Wrażenie | — | Czy logo pasuje do stylu menu (ciemne tło, bursztynowe przyciski)? | Ok | |

## Twoje uwagi / propozycje

-
