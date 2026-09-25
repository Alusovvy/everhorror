// Usage (from project root): node tools/generators/write_world_data.js
// -> data/items/*.tres (ItemData) and data/locations/*.tres (LocationData).
// Items: docs_v2/systemy/ekwipunek.md. Places and the travel graph: docs_v2/systemy/eksploracja_kopalni.md.
const fs = require("fs");
const esc = (s) => s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n");
fs.mkdirSync("data/items", { recursive: true });
fs.mkdirSync("data/locations", { recursive: true });

// category: 0 TOOL, 1 MEDICINE, 2 SUPPLY, 3 QUEST, 4 VALUABLE (script/data/item_data.gd)
const CATEGORY = { tool: 0, medicine: 1, supply: 2, quest: 3, valuable: 4 };

function item(o) {
  fs.writeFileSync(`data/items/${o.id}.tres`, `[gd_resource type="Resource" script_class="ItemData" format=3]

[ext_resource type="Script" path="res://script/data/item_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = &"${o.id}"
display_name = "${esc(o.name)}"
name_accusative = "${esc(o.acc)}"
description = "${esc(o.text)}"
category = ${CATEGORY[o.cat]}
heal = ${o.heal ?? 0}
sanity = ${o.sanity ?? 0}
cures_fever = ${o.fever ? "true" : "false"}
consumable = ${o.consumable === false ? "false" : "true"}
use_hours = ${o.hours ?? 0.0}
use_text = "${esc(o.use ?? "")}"
`);
}

// --- Items ---
item({ id: "amulet", name: "Amulet dziadka", acc: "amulet dziadka", cat: "valuable", consumable: false,
  text: "Mosiężny krążek na rzemieniu, z wyrytą gwiazdą przeciętą kreską. Dziadek nigdy go nie zdejmował. Nagrzewa się przy błękicie, a czasem wtedy, kiedy nie powinien." });
item({ id: "lonty", name: "Suche lonty", acc: "lonty", cat: "quest",
  text: "Lonty ze składu starej ekipy, owinięte w natłuszczone płótno. Suche. Mirosław na nie czeka." });
item({ id: "lina", name: "Lina", acc: "linę", cat: "tool", consumable: false,
  text: "Konopna lina, trzydzieści sążni. Tekla liczy ją jak srebro. Bez niej nie zejdziesz ani w stromy chodnik, ani w pionowy szyb." });
item({ id: "kwit", name: "Kwit od Racibora", acc: "kwit", cat: "quest",
  text: "Kartka z pieczęcią zarządcy: „Wydać okazicielowi, co potrzebne do rozpoznania”. Tekla go uzna, choć się skrzywi." });
item({ id: "tobolek", name: "Tobołek Tekli", acc: "tobołek", cat: "quest",
  text: "Tobołek z wyszytym T. W środku ciężka sakiewka srebra i list z pieczęcią Konfraterni kupieckiej." });
item({ id: "krysztal", name: "Kryształ z kaplicy", acc: "kryształ", cat: "valuable", consumable: false,
  text: "Kryształ długości palca, z błękitnym światłem w środku. Zawsze ciepły. Kiedy go trzymasz, amulet dziadka też się nagrzewa." });
item({ id: "bandaze", name: "Bandaże", acc: "bandaże", cat: "medicine", heal: 30, hours: 0.5,
  text: "Czyste płótno pocięte w pasy. Anzelm wygotowuje je we wrzątku, zanim komukolwiek da.",
  use: "Przemywasz rany i obwiązujesz je ciasno. Piecze, aż zgrzytasz zębami, ale krew przestaje ciec." });
item({ id: "lekarstwo", name: "Lekarstwo", acc: "lekarstwo", cat: "medicine", heal: 15, fever: true,
  text: "Gliniana buteleczka gorzkiego wywaru. Zbija gorączkę i stawia na nogi. Jest go mało, a chorych w kopalni nie brakuje.",
  use: "Gorzkie jak piołun. Po chwili gorąco w głowie przygasa, a ręce przestają drżeć." });
item({ id: "nalewka", name: "Nalewka", acc: "nalewkę", cat: "medicine", sanity: 15,
  text: "Piersiówka mocnej nalewki na korzeniach. Na strach, na zimno i na złe sny.",
  use: "Pociągasz łyk. Pali w gardle, potem rozlewa się ciepło i na chwilę ciemność robi się mniej ciemna." });
item({ id: "swieca", name: "Świeca", acc: "świecę", cat: "supply", sanity: 6, hours: 0.5,
  text: "Łojowa świeca. Kopci, śmierdzi i daje odrobinę spokoju.",
  use: "Zapalasz świecę i patrzysz w płomień, aż przestają ci drżeć ręce." });
item({ id: "olej", name: "Olej do lampy", acc: "olej", cat: "supply",
  text: "Bańka oleju do lampy. Z takim zapasem dojdziesz tam, gdzie nie wisi już żadna latarnia." });
item({ id: "lom", name: "Łom", acc: "łom", cat: "tool", consumable: false,
  text: "Ciężki żelazny łom. Podważy wieko, kratę albo obluzowany kamień." });
item({ id: "obuch", name: "Obuch kilofa", acc: "obuch", cat: "quest",
  text: "Zardzewiały obuch bez trzonka. Stal dobra, hawiarska robota. Ktoś, kto zna się na kuźni, zrobiłby z tego kilof." });
item({ id: "kilof", name: "Kilof", acc: "kilof", cat: "tool", consumable: false,
  text: "Hawiarski kilof na nowym trzonku od Wszebora. Odkujesz nim naciek, pod którym chowa się żyła." });
item({ id: "grzyb", name: "Świecący grzyb", acc: "świecący grzyb", cat: "quest",
  text: "Blady grzyb z groty, z niebieską poświatą pod kapeluszem. Anzelm mówił, że z takich warzy się lekarstwo. Hagiwara chciałby go zobaczyć." });
item({ id: "odlamek", name: "Odłamek błękitu", acc: "odłamek błękitu", cat: "valuable",
  text: "Odłamek z Kryształowej galerii, czysty błękit bez grama skały. Buczy cicho, kiedy przyłożysz go do ucha. Sabina bardzo chciała taki mieć." });
item({ id: "klejnot", name: "Daleki Klejnot", acc: "Daleki Klejnot", cat: "valuable", consumable: false,
  text: "Szklany paciorek w mosiężnej oprawce. Na bazarach w Lajihar sprzedają takie jako kawałek planety Kinkenheim. Nasir twierdzi, że ten jest prawdziwy." });

// --- Places and the travel graph ---
// Edges: [a, b, hours]. The camp is "oboz".
const EDGES = [
  ["oboz", "east", 2], ["oboz", "west", 2], ["oboz", "rzapie", 2],
  ["east", "wyrobisko", 1], ["east", "kaplica", 1],
  ["west", "upadowa", 1], ["west", "kuznia", 1],
  ["rzapie", "pompy", 1],
  ["wyrobisko", "grota", 1.5], ["wyrobisko", "przekop", 1],
  ["pompy", "zalany", 1], ["pompy", "przekop", 1.5],
  ["kuznia", "szyb", 1],
  ["kaplica", "kostnica", 1],
  ["grota", "szczelina", 1], ["przekop", "szczelina", 1.5],
  ["zalany", "galeria", 1.5], ["szyb", "galeria", 1.5],
];

const PLACES = [
  { id: "east", name: "Stara sztolnia", dir: "wschód", entry: "EastEntry", depth: 1, pos: [0.76, 0.24],
    veins: ["east_1", "east_2"],
    text: "Sztolnia po starej ekipie. Pochylnia prowadzi w dół, do jaskini. Mirosław mówił, że gdzieś tam mieli skład." },
  { id: "west", name: "Zawalony chodnik", dir: "zachód", entry: "WestEntry", depth: 1, pos: [0.24, 0.24],
    veins: ["west_1"], requires: {
      "noflag:mir_dead": "Mirosław zasypał ten chodnik razem ze sobą. Tej drogi już nie ma.",
      "flag:west_blasted": "Zasypane. Bez prochu się nie przebijesz, może Mirosław coś poradzi." },
    text: "Ulubiona droga dziadka. Na jego mapach zaznaczona podwójną kreską." },
  { id: "rzapie", name: "Rząpie starego szybu", dir: "północ", entry: "RzapieEntry", depth: 1, pos: [0.5, 0.33],
    veins: ["rzapie", "rzapie_2"],
    text: "Dno starego szybu. Tędy spuszczano zapasy, zanim na dole zebrała się woda." },
  { id: "upadowa", name: "Upadowa", dir: "zachód, w dół", entry: "UpadowaEntry", depth: 2, pos: [0.08, 0.46], dread: 3,
    veins: ["upadowa", "upadowa_2"],
    requires: { "item:lina": "Za połamanymi stemplami chodnik stromo opada w ciemność. Bez liny nie zejdziesz." },
    text: "Stromy chodnik za połamanymi stemplami. Na mapie dziadka trzy grube kreski i nic więcej." },
  { id: "kuznia", name: "Kuźnia starej ekipy", dir: "zachód", entry: "KuzniaEntry", depth: 2, pos: [0.3, 0.5],
    veins: ["kuznia_1"],
    text: "Kuźnia przy zachodnim chodniku. Tu ostrzono kilofy i kuto okucia do stempli.",
    arrival: "Kowadło pod warstwą rdzy i pyłu. W palenisku nikt nie palił od czterdziestu lat." },
  { id: "kaplica", name: "Kaplica", unknown: "Znak zapytania", dir: "wschód, w dół", entry: "KaplicaEntry", depth: 2, pos: [0.92, 0.47],
    veins: ["kaplica", "kaplica_2"],
    requires: { "flag:kaplica_known": "Na mapie dziadka pod jaskinią jest tylko znak zapytania. Nie wiesz, czego tam szukać." },
    text: "Znak zapytania z mapy dziadka, pod jaskinią. W dół prowadzi wąskie przejście z wykutymi stopniami." },
  { id: "wyrobisko", name: "Stare wyrobisko", dir: "wschód", entry: "WyrobiskoEntry", depth: 2, pos: [0.68, 0.47],
    veins: ["wyrobisko_1", "wyrobisko_2"],
    text: "Wyrobisko za jaskinią. Dziadek zaznaczył je krzyżykiem: wybrane do cna. Tyle że wtedy nikt nie szukał błękitu.",
    arrival: "Filary zostawione przez starą ekipę trzymają strop chyba tylko z przyzwyczajenia." },
  { id: "pompy", name: "Komora pomp", dir: "północ, w dół", entry: "PompyEntry", depth: 2, pos: [0.5, 0.55],
    veins: ["pompy_1"],
    text: "Komora, w której stara ekipa trzymała pompy. Dopóki chodziły, rząpie było suche.",
    arrival: "Pompy stoją. Drewno spuchło od wilgoci, ale żelazo jeszcze się trzyma." },
  { id: "szyb", name: "Ślepy szyb", dir: "zachód, w dół", entry: "SzybEntry", depth: 3, pos: [0.2, 0.72], dread: 3,
    veins: ["szyb_1"],
    requires: { "item:lina": "Szyb idzie pionowo w dół. Bez liny nawet nie podchodź do krawędzi." },
    text: "Szyb wykuty z chodnika w dół, bez wyjścia na powierzchnię. Dziadek dopisał obok jedno słowo: „wiatr”.",
    arrival: "Z dołu ciągnie zimne powietrze. Szyb oddycha." },
  { id: "kostnica", name: "Kostnica", dir: "wschód, w dół", entry: "KostnicaEntry", depth: 3, pos: [0.93, 0.72], dread: 8,
    veins: ["kostnica_1"],
    text: "Boczna komora za kaplicą, gdzie stara ekipa chowała swoich. Dziadek narysował tam małą czaszkę, jakby od niechcenia.",
    arrival: "Czaszki patrzą na ciebie z nisz. Ktoś zostawił im chleb. Świeży." },
  { id: "grota", name: "Grzybowa grota", dir: "wschód, w dół", entry: "GrotaEntry", depth: 3, pos: [0.74, 0.7], dread: 4,
    veins: ["grota_1", "grota_2"],
    text: "Grota za wyrobiskiem. Dziadek narysował tam coś jak grzyby i postawił trzy wykrzykniki.",
    arrival: "Grzyby świecą na niebiesko. Powietrze jest gęste i słodkawe, aż kręci się w głowie." },
  { id: "przekop", name: "Przekop Grabca", dir: "w dół", entry: "PrzekopEntry", depth: 3, pos: [0.58, 0.72],
    veins: ["przekop_1"],
    text: "Przekop prosty jak strzelił. Sztygar Grabiec chciał nim połączyć wyrobisko z pompami. Nie zdążył.",
    arrival: "Równy jak od sznurka. Grabiec znał się na robocie, to trzeba mu przyznać." },
  { id: "zalany", name: "Zalany chodnik", dir: "północ, w dół", entry: "ZalanyEntry", depth: 3, pos: [0.4, 0.74],
    veins: ["zalany_1", "zalany_2"],
    requires: { "flag:pump_running": "Woda stoi tam po sam strop. Póki pompy nie ruszą, nie ma przejścia." },
    text: "Chodnik pod komorą pomp. Odkąd pompy stanęły, stoi w nim woda.",
    arrival: "Woda sięga ci do kolan i jest lodowata. Długo tu nie wytrzymasz." },
  { id: "szczelina", name: "Parująca szczelina", dir: "w dół", entry: "SzczelinaEntry", depth: 4, pos: [0.68, 0.9], dread: 2,
    veins: ["szczelina_1", "szczelina_2"],
    text: "Szczelina, z której bucha para. Dziadek zapisał obok: „ciepło, siarka, nie siedzieć długo”.",
    arrival: "Gorąco. Para szczypie w oczy, a w gardle czuć siarkę." },
  { id: "galeria", name: "Kryształowa galeria", unknown: "Przekreślona gwiazda", dir: "najniżej", entry: "GaleriaEntry", depth: 4, pos: [0.33, 0.91], dread: 6,
    veins: ["galeria_1", "galeria_2", "galeria_3"],
    requires: { "item:olej": "Tam nie wisi już żadna latarnia. Bez zapasu oleju lampa zgaśnie ci w połowie drogi." },
    text: "Najniżej, dokąd sięga mapa. Dziadek narysował tam gwiazdę, a potem ją przekreślił.",
    arrival: "Ściany świecą tak jasno, że mógłbyś zgasić lampę. Nie gasisz." },
];

const links = {};
for (const [a, b, h] of EDGES) {
  (links[a] ??= {})[b] = h;
  (links[b] ??= {})[a] = h;
}

const dict = (o) => "{\n" + Object.entries(o).map(([k, v]) => `"${esc(k)}": ${typeof v === "number" ? v.toFixed(1) : `"${esc(v)}"`}`).join(",\n") + "\n}";
const strings = (a) => `PackedStringArray(${a.map((s) => `"${esc(s)}"`).join(", ")})`;

for (const p of PLACES) {
  const req = p.requires ?? {};
  fs.writeFileSync(`data/locations/${p.id}.tres`, `[gd_resource type="Resource" script_class="LocationData" format=3]

[ext_resource type="Script" path="res://script/data/location_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = &"${p.id}"
display_name = "${esc(p.name)}"
unknown_name = "${esc(p.unknown ?? "")}"
direction = "${esc(p.dir)}"
text = "${esc(p.text)}"
links = ${dict(links[p.id] ?? {})}
requires = ${strings(Object.keys(req))}
locked = ${dict(req)}
entry = "${p.entry}"
veins = ${strings(p.veins)}
depth = ${p.depth}
map_pos = Vector2(${p.pos[0]}, ${p.pos[1]})
dread = ${p.dread ?? 0}
arrival_text = "${esc(p.arrival ?? "")}"
`);
}
const ids = PLACES.map((p) => p.id);
for (const [a, b] of EDGES) {
  for (const id of [a, b]) {
    if (id !== "oboz" && !ids.includes(id)) console.log("UNKNOWN PLACE IN EDGES: " + id);
  }
}
const veinCount = PLACES.reduce((n, p) => n + p.veins.length, 0);
console.log(`items and ${PLACES.length} places written (${veinCount} veins)`);
