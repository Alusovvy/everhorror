// Usage (from project root): node tools/generators/write_gwara.js
// Writes dialogue/gwara_slaska.json: original miner line -> the same line with Silesian flavour.
// Keys must match the text after "Name: " in dialogue/*.dialogue exactly (tags included);
// the script checks that and lists miner lines that still have no Silesian version.
// The game loads the file as a translation (script/settings.gd), so the .dialogue files keep the
// original lines and the "Silesian dialect" option only swaps them at runtime.
const fs = require("fs");

const gwara = {
  // --- Mirosław (lżejsza gwara) ---
  "Ty nowy? Siadaj, jak chcesz. Byle mi nad głową nie stać.":
    "Ty nowy? Siadej, jak chcesz. Ino mi nad gowom niy stój.",
  "Mirosław jestem. Z Głuszy. Robię przy prochu, więc jak trzeba coś rozwalić, to do mnie.":
    "Jo je Mirosław. Z Głuszy. Robia przy prochu, to jak trza cosik rozwalić, to do mie.",
  "[[No?|Czego?|Gadaj.]]":
    "[[No?|Czego?|Godej.]]",
  "Zawaliło się. Ze czterdzieści lat temu. Stemple były do niczego, albo i żadnych nie postawili.":
    "Zawaliło sie. Bydzie ze czterdzieści lot. Stymple były do niczego, abo i żodnych niy postawili.",
  "Rozwaliłbym to w parę godzin, tylko czym? Lonty mi zamokły, jak nas spuszczali szybem. Wszystkie co do jednego.":
    "Rozwalił bych to za pora godzin, ino czym? Lonty mi zamokły, jak nos spuszczali szachtom. Wszyjske co do jednego.",
  "Stara ekipa miała skład w Starej sztolni, na wschodzie. Może coś tam zostało. Jak znajdziesz suche lonty, to przynieś.":
    "Staro ekipa miała skład w Starej sztolni, na wschodzie. Może cosik tam ostało. Jak znojdziesz suche lonty, to przinieś.",
  "Czekaj no... A to co ci z torby wystaje? Lonty?":
    "Czekej no... A to co ci z torby wystawo? Lonty?",
  "Pokaż.[wait=0.4] No proszę. Stare, ale suche. Ktoś je porządnie zawinął.":
    "Pokoż.[wait=0.4] No, gryfnie. Stare, ale suche. Ftoś je porządnie zawinął.",
  "Z tym to mogę ten zawał wysadzić. Tylko trochę to potrwa i huknie tak, że wszystkim w uszach zadzwoni.":
    "Z tym to moga tyn zawał wysadzić. Ino to trocha potrwo i pierdyknie tak, że wszystkim w uszach zadzwoni.",
  "Teraz?[wait=0.4] Niech będzie. Tylko trzymaj się z daleka. I od ognia też.":
    "Teraz?[wait=0.4] Niech bydzie. Ino trzimej sie z daleka. I od ognia tyż.",
  "Dzisiaj już nie. Po ciemku z prochem się nie baluje. Jutro z rana.":
    "Dzisiej już niy. Po ciymku z prochym sie niy baluje. Jutro z rana.",
  "Z Głuszy. Tyle że Głuszy już nie ma. Pierwsi przyszli, jak miałem dziesięć lat.":
    "Z Głuszy. Ino że Głuszy już niy ma. Pierwsi przyszli, jak żech mioł dziesięć lot.",
  "Dwa miesiące przesiedziałem w piwnicy pod karczmą. Jadłem, co się dało złapać. Nie pytaj co.":
    "Dwa miesiące żech przesiedzioł w piwnicy pod karczmom. Jod żech, co sie dało chycić. Niy pytej co.",
  "Mnie też. Dawno to było.":
    "Mie tyż. Downo to było.",
  "A czym miałem? Proch przynajmniej robi, co mu każesz. Z ludźmi bywa różnie.":
    "A czym żech mioł? Proch przinajmnij robi, co mu kożesz. Z ludźmi to różnie bywo.",
  "Ten huk... Ciągle go słyszę. Jakbym znowu siedział w tej piwnicy.":
    "Tyn huk... Dycki go słysza. Jakbych zaś siedzioł w tej piwnicy.",
  "Żyję. W uszach mi dzwoni, ale żyję.":
    "Żyja. W uszach mi dzwoni, ale żyja.",
  "...Dzięki.":
    "...Dziynki.",
  "Jasne. Robota.":
    "No ja. Robota.",
  "To idź. Tylko nie zabłądź.":
    "To idź. Ino niy zabłądź.",
  "Nie podchodź z tą lampą. Proszę cię.":
    "Niy podchodź z tom lampom. Prosza cie.",
  "Całą noc słyszałem wybuchy. Jeden za drugim. A przecież był tylko jeden.":
    "Cołko noc żech słyszoł wybuchy. Jedyn za drugim. A przeca był ino jedyn.",
  "...[wait=0.5] Jeszcze chwilę. Potem wrócę do roboty.":
    "...[wait=0.5] Jeszcze chwila. Potym wróca do roboty.",
  "No i proszę, zachodni chodnik stoi otworem. Mówiłem, że dam radę.":
    "No i widzisz, zachodni chodnik je otwarty. Godoł żech, że dom rada.",
  "I... dzięki za wczoraj. Że posiedziałeś.":
    "I... dziynki za wczoraj. Że żeś posiedzioł.",
  "Lonty mam. Powiedz tylko słowo, a zawał pójdzie w powietrze.":
    "Lonty mom. Powiydz ino słowo, a zawał pójdzie w luft.",
  "Mówiłem ci, bez suchych lontów nic nie wysadzę. Szukaj w Starej sztolni.":
    "Godoł żech ci, bez suchych lontów nic niy wysadza. Szukej w Starej sztolni.",
  // task_04: Racibor, the charge in the decline, the last day
  "Zarządca jak zarządca. Liczy wozy. Ludzi liczy dopiero wtedy, jak któregoś brakuje.":
    "Zarządca jak zarządca. Liczy wozy. Ludzi liczy dopiero wtedy, jak kerego brakuje.",
  "Ale proch mi dał porządny. To już coś.":
    "Ale proch mi doł porządny. To już cosik.",
  "I co tam?":
    "No i co tam?",
  "Okopcone, mówisz. A stemple całe.":
    "Okopcone, godosz. A stymple cołe.",
  "To nie strop. Ktoś tam odpalił ładunek. I znał się na rzeczy, postawił go tak, żeby zasypało zejście, a stropu nie ruszyło.":
    "To niy strop. Ftoś tam odpolił ładunek. I znoł sie na rzeczy, postawił go tak, coby zasypało zejście, a stropu niy ruszyło.",
  "Czterdzieści lat temu mało kto tak umiał.":
    "Czterdzieści lot tymu mało fto tak umioł.",
  "Trzy beczki, dobrze położone... To by się zgadzało. Twój dziadek nie był zwykłym przewodnikiem, co?":
    "Trzy beczki, dobrze położone... To by sie zgadzało. Twój starzik niy był zwykłym przewodnikiym, co?",
  "Coś wiesz. Widzę po tobie. Ale nie moja sprawa.":
    "Cosik wiysz. Widza po tobie. Ale niy moja sprawa.",
  "Trzy beczki. Liczę i liczę, i zawsze wychodzą trzy.":
    "Trzy beczki. Licza i licza, i dycki wychodzą trzy.",
  "Ktoś już raz ją wysadził, żeby nikt tamtędy nie przeszedł. A my ją otworzymy. Mądrzy ludzie.":
    "Ftoś już roz jom wysadził, coby nikt tamtędy niy przeszoł. A my jom otworzymy. Mądrzy ludzie.",
  "Proch jest, lonty są. Tylko ręce mi się jakoś nie chcą rwać do tej roboty.":
    "Proch je, lonty som. Ino rynce mi sie jakoś niy chcom rwać do tej roboty.",
  "Wysadzić zawał, który ktoś już raz wysadził, żeby nikt tam nie wlazł? Wysadzę. Ale nie mówcie potem, że nikt was nie ostrzegał.":
    "Wysadzić zawał, kery ftoś już roz wysadził, coby nikt tam niy wlazł? Wysadza. Ale niy godejcie potym, że nikt wos niy ostrzegoł.",
  "Jak trzeba, to wysadzę. Tylko niech mi nikt z ogniem nie łazi koło beczek.":
    "Jak trza, to wysadza. Ino niech mi nikt z ogniym niy łazi kole beczek.",

  // --- Stary Bolko (mocniejsza gwara) ---
  "Hę? Aaa, to ty jesteś ten wnuk. Poznałbym cię wszędzie, oczy masz po nim.":
    "Hę? Aaa, to ty bydziesz tyn wnuk. Poznoł bych cie wszyndzie, łoczy mosz po nim.",
  "Bolko jestem. Fedrowałem tu, jak ciebie jeszcze na świecie nie było. Z twoim dziadkiem też.":
    "Jo je Bolko. Fedrowoł żech tu, jak ciebie jeszcze na świecie niy było. Z twoim starzikym tyż.",
  "[[No?|Czego ci trzeba?|Pytaj, póki mam cierpliwość.]]":
    "[[No?|Czego ci trza?|Pytej, póki mom cierpliwość.]]",
  "Cichy. Za cichy jak na przewodnika. Wszystko zapisywał, ale tak, że nikt poza nim nie umiał tego przeczytać.":
    "Cichy był. Za cichy jak na przewodnika. Wszystko se zapisywoł, ale tak, że żodyn poza nim niy umioł tego przeczytać.",
  "Mówił, że to dla bezpieczeństwa. Czyjego, tego już nie powiedział.":
    "Godoł, że to dlo bezpieczyństwa. Czyjego, tego już niy pedzioł.",
  "Miał. Tylko zabrał je ze sobą.":
    "Mioł. Ino je zabroł ze sobom.",
  "Uważaj, co gadasz. To on cię wykarmił, chłopcze.":
    "Uwożej, co godosz. To łon cie wykarmił, synek.",
  "Bo następca tronu szykuje się do wojny, a na wojnę trzeba błękitnego żelaza. Ostrze z błękitu latami się nie tępi.":
    "Bo następca tronu szykuje sie do wojny, a na wojna trza błękitnego żelaza. Ostrze z błękitu latami sie niy tympi.",
  "Starzy gadali, że błękit nie rośnie w skale sam z siebie. Że coś go robi. Gdzieś głęboko pod nami.":
    "Starzi godali, że błękit niy rośnie w skale sam z sia. Że cosik go robi. Kajś głęboko pod nami.",
  "Ja wierzę w porządny stempel nad głową. Reszta to bajki z Wąwozu.":
    "Jo wierza w porządny stympel nad gowom. Reszta to bojki z Wąwozu.",
  "Pewnie. Bajki.":
    "Pewnie. Bojki.",
  "Dawaj.[wait=0.4] Jego ręka, nie ma dwóch zdań.":
    "Dej sam.[wait=0.4] Jego rynka, niy ma dwóch zdań.",
  "Klucz zawsze chował gdzie indziej niż wiadomość. Mawiał: wiadomość idzie w głąb, klucz zostaje przy drodze.":
    "Klucz dycki chowoł kaj indzij niż wiadomość. Godoł: wiadomość idzie w głąb, klucz ostaje przy drodze.",
  "Skoro kartka była na wschodzie, klucza szukaj na zachodzie. Za zawałem. O ile go do reszty nie zasypało.":
    "Jak kartka była na wschodzie, to klucza szukej na zachodzie. Za zawałem. Jak go do reszty niy zasypało.",
  "Nie wiem, o czym mówisz.":
    "Niy wiym, o czym godosz.",
  "Mirosław wysadziłby i samego Kniazia, gdyby mu dać dość prochu.[wait=0.3] Porządny z niego chłop, tylko z ogniem ma na pieńku.":
    "Mirosław wysadziłby i samego Kniazia, jakby mu dać dość prochu.[wait=0.3] Porządny z niego chop, ino z ogniym mo na pieńku.",
  "Jak już huknie, posiedź z nim potem trochę. Wiem, co mówię.":
    "Jak już pierdyknie, to posiedź potym z nim trocha. Wiym, co godom.",
  "Idź. I patrz na strop, nie pod nogi.":
    "Idź. I kukej na strop, niy pod nogi.",
  "Wstałeś? To dobrze. Całą noc oka nie zmrużyłem, dziadek twój mi po głowie chodził.":
    "Wstołeś? To dobrze. Cołko noc żech oka niy zmrużył, starzik twój mi po gowie chodził.",
  "Ostatniego dnia, zanim zszedł, powiedział mi: jak wnuk tu kiedyś trafi, niech za błękitem nie idzie. Myślałem, że żartuje.":
    "Ostatniego dnia, zanim zlazł na dół, pedzioł mi: jak wnuk tu kejś trefi, niech za błękitem niy idzie. Myśloł żech, że sie wygłupio.",
  "Nie mam ci nic do powiedzenia.":
    "Niy mom ci nic do godanio.",
  "Nowy dzień, ta sama dziura. Uważaj dziś na siebie.":
    "Nowy dziyń, ta sama dziura. Dej dzisiej pozór na sia.",
  // task_04: the First, the chapel, the new people, the grandfather's fate, the last day
  "Że siedzą w skale. Zamknięci jak chleb w piecu, co się nigdy nie dopiecze.":
    "Że siedzom w skale. Zamkniynci jak chlyb w piecu, co sie nigdy niy dopiecze.",
  "I że jak ich kto obudzi, to lepiej, żeby był już daleko stąd.":
    "I że jak ich fto obudzi, to lepij, coby był już daleko stond.",
  "Była. Pod jaskinią za Starą sztolnią, za wąskim przejściem. Chodziło się tam zapalić lampkę przed szychtą.":
    "Była. Pod jaskiniom za Starą sztolnią, za wąskim przejściym. Chodziło sie tam zapolić lampka przed szychtom.",
  "Twój dziadek chodził częściej niż inni. Mówił, że ściana w kaplicy gada. Myślałem, że żartuje.":
    "Twój starzik łaził czynścij niż inni. Godoł, że ściana w kaplicy godo. Myśloł żech, że sie wygłupio.",
  "Dobra baba. Kaszę gotuje taką, że łyżka w niej stoi. Tylko wszystko liczy dwa razy, a sprzedaje trzy.":
    "Dobro baba. Kasza warzy tako, że łyżka w nij stoi. Ino wszystko liczy dwa razy, a przedowo trzy.",
  "Maska, rękawice, a oczy jak u topielca. Drudzy w kopalni to nigdy nic dobrego.":
    "Maska, rynkawice, a ślypia jak u topielca. Drudzy na grubie to nigdy nic dobrego.",
  "Nie podchodź do niej, synek. I nie dawaj jej niczego, co znajdziesz na dole.":
    "Niy podchodź do nij, synek. I niy dowej jij niczego, co znojdziesz na dole.",
  "Co ty gadasz?":
    "Co ty godosz?",
  "Czterdzieści lat myślałem, że to przez mój stempel. Że źle go postawiłem i strop go przygniótł.":
    "Czterdzieści lot żech myśloł, że to bez mój stympel. Że źle żech go postawił i strop go przygniół.",
  "A on sam... Stary głupiec. Stary, mądry głupiec.":
    "A łon sam... Stary gupielok. Stary, mądry gupielok.",
  "Całą noc myślałem o twoim dziadku. Zapalę mu lampkę w kaplicy. Tak się kiedyś robiło.":
    "Cołko noc żech myśloł ło twoim starziku. Zapola mu lampka w kaplicy. Tak sie kiedyś robiło.",
  "Upadową chcą otwierać. Stare chodniki powinny spać, ale kto by słuchał starego.":
    "Upadową chcom łotwiyrać. Stare chodniki powinny spać, ale fto by słuchoł starego.",
  "Trzeci dzień. Jak tak dalej pójdzie, to się tu zestarzeję drugi raz.":
    "Trzeci dziyń. Jak tak dalij pódzie, to sie tu zestarza drugi roz.",
  "Nad grobem przewodnika kopać nie będziesz, panie zarządco. Po moim trupie.":
    "Nad grobym przewodnika kopać niy bydziesz, panie zarządco. Po moim trupie.",
  // --- task_05: the week (Mirosław) ---
  "Dobrze, że ktoś siedzi. Jak jestem sam, to ogień zaczyna gadać.":
    "Dobrze, że ftoś siedzi. Jak żech je sam, to łogiyń zaczyno godać.",
  "Pali. Dobrze, że pali. Jak pali, to znaczy, że jeszcze coś czuję.":
    "Pali. Dobrze, że pali. Jak pali, to znaczy, że jeszcze cosik czuja.",
  "Jak Pierwsi przyszli do Głuszy, to magowie przyjechali trzy dni później. Obejrzeli, co zostało, zapisali coś w księgach i pojechali.":
    "Jak Pierwsi przyszli do Głuszy, to magowie przijechali trzy dni niyskorzij. Pozaglądali, co ostało, zapisali cosik w ksiyngach i pojechali.",
  "Mnie z tej piwnicy wyciągnęła baba spod Mirosila, co wiozła rzepę na targ. Nie mag.":
    "Mie z tej piwnicy wyciongła baba spod Mirosila, co wiozła rzepa na targ. Niy mag.",
  "Nie idź jeszcze. Jak ktoś siedzi obok, to wybuchy są ciszej.":
    "Niy idź jeszcze. Jak ftoś siedzi łobok, to wybuchy som cisze.",
  "Słyszałeś Racibora. Jak policzy żyły, mam wysadzić upadową.":
    "Słyszołeś Racibora. Jak porachuje żyły, mom wysadzić upadowo.",
  "Tydzień, mówi Racibor. Dwanaście żył. A potem fedrujemy na całego.":
    "Tydziyń, godo Racibor. Dwanaście żył. A potym fedrujymy na cołego.",
  "Dziś Racibor liczy. Jakby nie liczył, to i tak wszyscy liczymy. Dni, beczki, kto jeszcze śpi spokojnie.":
    "Dzisiej Racibor rachuje. A choćby niy rachowoł, to i tak wszyscy rachujymy. Dni, beczki, fto jeszcze śpi spokojnie.",
  "Znowu mi się śniło, że wszystko wybucha. Tym razem po cichu. To było najgorsze.":
    "Zaś mi sie śniło, że wszystko wybucho. Tym razym po cichu. To było nojgorsze.",
  "[[Żyjesz? No to dobrze.|Proch suchy, ręce trzęsą się mniej. Dobry dzień.|Uważaj dziś na siebie. Ja uważam na beczki.]]":
    "[[Żyjesz? No to dobrze.|Proch suchy, rynce trzynsom sie mnij. Dobry dziyń.|Uwożej dzisiej na sia. Jo uwożom na beczki.]]",
  // --- task_05: the week (Bolko) ---
  "Hawiar. Kopie za trzech, gada za pięciu, a śpiewa za całą Przystań. Dobry chłop.":
    "Hawiar. Fedruje za trzech, godo za piyńciu, a śpiywo za cołko Przystań. Dobry chop.",
  "Tylko w ciasne chodniki nie wlezie. Widziałem, jak stoi przed szczeliną i patrzy. Tak patrzy człowiek, co już raz kogoś odkopywał.":
    "Ino w ciasne chodniki niy wlezie. Widzioł żech, jak stoi przed szczelinom i zaglądo. Tak zaglądo chop, co już roz kogoś odkopywoł.",
  "Widziałem. Jedna czarownica w obozie to był znak. Dwie to już zwyczaj.":
    "Widzioł żech. Jedna czarownica w łobozie to boł znak. Dwie to już zwyk.",
  "Ta nowa przynajmniej mówi „dzień dobry”. Jak do psa, ale mówi.":
    "Ta nowo przinajmnij godo „dziyń dobry”. Jak do psa, ale godo.",
  "Ostatni dzień przed liczeniem. Racibor chodzi jak struty. Znam to. Twój dziadek też miał taki dzień. Ostatni.":
    "Ostatni dziyń przed rachowaniym. Racibor łazi jak struty. Znom to. Twój starzik tyż mioł taki dziyń. Ostatni.",
  "[[Żyjesz jeszcze? To dobrze.|Nie łaź dziś za daleko, coś mi w kościach strzyka.|Znowu ty. Siadaj, jak chcesz.]]":
    "[[Żyjesz jeszcze? To dobrze.|Niy łaź dzisiej za daleko, cosik mi w kościach strzyko.|Zaś ty. Siadej, jak chcesz.]]",
};

// Collect the miners' spoken lines from every dialogue file (they also speak in other scenes).
const minerLines = new Set();
for (const file of fs.readdirSync("dialogue").filter((f) => f.endsWith(".dialogue")).map((f) => "dialogue/" + f)) {
  for (const raw of fs.readFileSync(file, "utf8").split(/\r?\n/)) {
    const m = raw.trim().match(/^(Mirosław|Bolko): (.*)$/);
    if (m) minerLines.add(m[2]);
  }
}
const unknown = Object.keys(gwara).filter((k) => !minerLines.has(k));
const missing = [...minerLines].filter((l) => !(l in gwara));
fs.writeFileSync("dialogue/gwara_slaska.json", JSON.stringify(gwara, null, "\t") + "\n");
console.log(`gwara: ${Object.keys(gwara).length} lines written`);
if (unknown.length) console.log("!! keys not found in dialogues:\n  " + unknown.join("\n  "));
if (missing.length) console.log("!! miner lines without Silesian version:\n  " + missing.join("\n  "));
if (!unknown.length && !missing.length) console.log("all miner lines covered, all keys match");
