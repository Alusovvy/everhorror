#!/usr/bin/env node
// Generates docs/agent/flags.md from reports/flags.tsv (written by `tools/run_tests.sh lint`).
// Usage: node tools/generators/write_flags_doc.js [--check]
// --check writes nothing: it exits 1 when docs/agent/flags.md is not what the current flags.tsv gives
// (the `lint` scenario runs it, so the registry cannot go stale).
// The output is sorted and carries no dates or line numbers, so a second run gives the same file.
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..", "..");
const tsvPath = path.join(root, "reports", "flags.tsv");
const outPath = path.join(root, "docs", "agent", "flags.md");

if (!fs.existsSync(tsvPath)) {
	console.error("reports/flags.tsv is missing: run `tools/run_tests.sh lint` first");
	process.exit(1);
}

const lines = fs.readFileSync(tsvPath, "utf8").split("\n").filter((l) => l.trim() !== "");
const rows = lines.slice(1).map((l) => {
	const [flag, setIn, readIn, payload, family] = l.split("\t");
	return { flag, setIn: setIn || "", readIn: readIn || "", payload: payload === "yes", family: family || "" };
});

const cell = (list) => (list === "" ? "—" : list.split(",").map((p) => "`" + p + "`").join(", "));
const table = (items) => {
	const out = ["| Flaga | Ustawiana w | Czytana w | Ładunek |", "|---|---|---|---|"];
	for (const r of items) {
		out.push(`| \`${r.flag}\` | ${cell(r.setIn)} | ${cell(r.readIn)} | ${r.payload ? "tak" : "nie"} |`);
	}
	return out.join("\n");
};

const plain = rows.filter((r) => r.family === "");
const families = rows.filter((r) => r.family !== "");

const out = [];
out.push("# Rejestr flag");
out.push("");
out.push("> Plik generowany: nie edytować ręcznie. Źródło: `reports/flags.tsv` (zapisuje `tools/run_tests.sh lint`), generator: `node tools/generators/write_flags_doc.js`.");
out.push("");
out.push(`Flag z literalną nazwą w źródłach: ${plain.length}, z rodzin składanych w czasie gry: ${families.length}. „Ładunek: tak” znaczy, że flaga trzyma wartość inną niż \`true\` (miejsce, dzień, listę; \`mark_today\` i \`bump_flag\` zawsze). Brak „Czytana w” to flaga tylko zapisywana (ostrzeżenie lintu) albo czytana wyłącznie z nazwy składanej w czasie gry.`);
out.push("");
out.push("## Flagi");
out.push("");
out.push(table(plain));
out.push("");
out.push("## Rodziny składane w czasie gry (`vein_*`, `visited_*`, `first_room_*`, `fever_*`)");
out.push("");
out.push("Poniżej tylko te, których nazwa występuje w źródłach literalnie.");
out.push("");
out.push(table(families));
out.push("");

const text = out.join("\n");
if (process.argv.includes("--check")) {
	const current = fs.existsSync(outPath) ? fs.readFileSync(outPath, "utf8").replace(/\r\n/g, "\n") : "";
	if (current !== text) {
		console.error("docs/agent/flags.md is out of date: run `node tools/generators/write_flags_doc.js` and commit it");
		process.exit(1);
	}
	console.log(`docs/agent/flags.md is current (${rows.length} flags)`);
} else {
	fs.writeFileSync(outPath, text);
	console.log(`docs/agent/flags.md: ${rows.length} flags`);
}
