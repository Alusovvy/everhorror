# Postacie

> Status: 🟡 szkic · Właściciel: zespół · Aktualizacja: 2026-09-25 (task_05) · Źródło: GDD §2.1, §5, task_03, task_04, task_05, LoreDoc
> Nowe postacie zaczynamy od [szablonu NPC](../szablony/npc.md). Zasady systemowe są w [NPC](../systemy/npc.md). Magia i Drudzy: [Magia](magia.md).

## Bohater (gracz)
- Wnuk zaginionego górnika. Członek ekspedycji górniczej, równy innym, a nie dowódca **[GDD]**.
- Zna mapy dziadka na pamięć i narysował własne **[GDD]**.
- Nosi amulet dziadka i ma obce sny **[GDD]**. W demie amulet grzeje się przy ścianie w kaplicy i parzy przy złej odpowiedzi.
- Ma zdrowie, poczytalność i może dostać gorączki. Opisane są słowami, zob. [Zdrowie i poczytalność](../systemy/zdrowie_i_poczytalnosc.md).
- GDD pisze o bohaterze w formie męskiej („zaciągnąłeś się”). Dialogi dema też używają form męskich. ❓ Czy to stała decyzja, czy wybór gracza?
- ❓ Imię.

## Dziadek
Przewodnik i kryptograf. Latami potajemnie wynosił błękitne żelazo i nigdy go nie złapano. Zaginął na szychcie 40 lat temu **[GDD]**. Jego szkielet i notatki mogą prowadzić do [prostego zakończenia](fabula.md#zakończenia) **[GDD]**.

[propozycja, zaimplementowane w demie] Dziadek widział Onych. Kupił u Hanusza z Mirosil (ojca Tekli) trzy beczki prochu, sam wysadził zejście do upadowej i został po tamtej stronie, żeby nikt nie poszedł jego śladem. W kaplicy zostawił list i kryształ ukryte za zagadką. Szczegóły w [Fabule](fabula.md#demo-tydzień-task_04-i-task_05).

## Obsada dema
| Postać | Frakcja | Rola | Od dnia | Karta |
|---|---|---|---|---|
| **Mirosław z Głuszy** | Ekspedycja | specjalista od materiałów wybuchowych | 1 | [miroslaw.md](postacie/miroslaw.md) **[GDD]** |
| **Stary Bolko** | Ekspedycja | najstarszy górnik, znał dziadka | 1 | [bolko.md](postacie/bolko.md) [ROBOCZE] |
| **Racibor**, zarządca | Ekspedycja | zarządca z nadania Kniazia, szef wyprawy | 1 | [racibor.md](postacie/racibor.md) [ROBOCZE] |
| **Tekla**, kwatermistrzyni | Inna (Konfraternia kupiecka) | zaopatrzenie i kuchnia | 1 | [tekla.md](postacie/tekla.md) [ROBOCZE] |
| **Dobrawa z Initium** | Drudzy | Druga, badaczka energii | 2 | [dobrawa.md](postacie/dobrawa.md) [ROBOCZE] |
| **Wszebor ze Śnieżnej Przystani** | Ekspedycja | rębacz i kowal, Hawiar | 1 | [wszebor.md](postacie/wszebor.md) [ROBOCZE] |
| **Nasir z Bakaszu** | Inna | pompiarz z Sułtanatu Nerdii | 1 (chory od 4) | [nasir.md](postacie/nasir.md) [ROBOCZE] |
| **Kiyoshi Hagiwara** | Inna | pisarz ekspedycji, wygnaniec z Cesarstwa | 1 | [hagiwara.md](postacie/hagiwara.md) [ROBOCZE] |
| **Sobek z Wielkiego Stepu** | Ekspedycja | Egzarcha, straż obozu | 1 | [sobek.md](postacie/sobek.md) [ROBOCZE] |
| **Brat Anzelm** | Inna | felczer, były zakonnik Niebiańskiego Płomienia | 1 | [anzelm.md](postacie/anzelm.md) [ROBOCZE] |
| **Sabina von Reuss** | Drudzy (Exitium) | Druga, uzdrowicielka, obserwatorka w obozie | 3 | [sabina.md](postacie/sabina.md) [ROBOCZE] |
| **Ottokar von Brühl** | Drudzy (Exitium) | szef wyprawy Drugich | 3, w tunelach | [ottokar.md](postacie/ottokar.md) [ROBOCZE] |
| **Hieronim z Grotthamu** | Drudzy (Exitium) | stary Drugi, szaleniec | 3, w tunelach | [hieronim.md](postacie/hieronim.md) [ROBOCZE] |
| **Welf von Hagen** | Drudzy (Exitium) | młody, wyniosły Drugi | 3, w tunelach | [welf.md](postacie/welf.md) [ROBOCZE] |
| **Hrapek** | Inna | rybak, potem górnik; mówi wierszem, bohatera nazywa Cesarzem | 3 (po wybuchu), przy powrotach z tuneli; ginie w nocy 5→6 | [hrapek.md](postacie/hrapek.md) (karta Rolanda, kwestie [ROBOCZE]) |

[ROBOCZE] oznacza postać wymyśloną na potrzeby dema. Czeka na przegląd Ren. Dane w grze: `data/npc/*.tres` (generuje `tools/generators/write_story_data.js`), dialogi: `dialogue/*.dialogue`.

**Jak wątki się łączą (demo):**
- Mirosław otwiera zachodni chodnik i rozpoznaje, że zawał w upadowej zrobił ładunek.
- Bolko zna zwyczaje dziadka i drogę do kaplicy.
- Racibor chce złóż i otworzenia upadowej.
- Tekla wie, komu jej ojciec sprzedał proch.
- Dobrawa szuka artefaktu i kryształu z kaplicy.
- List dziadka odpowiada wszystkim naraz.

**Nowi w task_05 (nieważni dla świata, każdy niesie kawałek LoreDoc):**
- Wszebor opowiada o Hawiarach, Śnieżnej Przystani i świętach Jaksaru i daje kilof.
- Nasir opowiada o Sułtanacie i Dżinach, uruchamia pompy, a w dniu 4 choruje (dylemat lekarstwa).
- Hagiwara opowiada o Cesarstwie i prowadzi księgi normy. Za grzyb daje wiersz i lekarstwo, ale ksiąg nie sfałszuje.
- Sobek opowiada o Egzarchach, stepie i Exitium i zakłada się o żyły.
- Anzelm opowiada o Zakonie Niebiańskiego Płomienia, leczy i warzy lekarstwo. Nie znosi Sabiny.
- Wyprawa Drugich z Exitium: Ottokar (zły, uprzejmy), Sabina (dobra, protekcjonalna, zostaje w obozie), Hieronim (szalony, mówi prawdę), Welf (wyniosły, do uratowania).

## Przykładowy górnik (szablon z GDD)
Frakcja: dowolna. Rola: górnik. Przy 0% poczytalności ucieka z kopalni. Służy jako wzór, to nie jest konkretna postać.
