// File-target checks only; heading fragments and remote URLs are not fetched.
// Run from any directory: node tools/check_doc_links.js [file-or-directory ...]
const fs = require('node:fs');
const path = require('node:path');
const workspace = path.resolve(__dirname, '../..');
const ignored = new Set(['.git', '.godot', 'node_modules', 'dist', 'build', 'assets', 'addons']);

function collect(target, result) {
  if (!fs.existsSync(target)) throw new Error(`Input does not exist: ${target}`);
  const stat = fs.lstatSync(target);
  if (stat.isSymbolicLink()) return;
  if (stat.isDirectory()) {
    for (const item of fs.readdirSync(target)) if (!ignored.has(item)) collect(path.join(target, item), result);
  } else if (target.endsWith('.md')) result.add(target);
}

function checkLinks(files) {
  const missing = [];
  let checked = 0;
  let outside = 0;
  for (const file of files) {
    let fenced = false;
    const lines = fs.readFileSync(file, 'utf8').split(/\r?\n/);
    lines.forEach((line, i) => {
      if (/^\s*(```|~~~)/.test(line)) { fenced = !fenced; return; }
      if (fenced) return;
      for (const match of line.matchAll(/(?<!!)\[[^\]\n]+\]\((<[^>]+>|[^\s)]+)(?:\s+"[^"]*")?\)/g)) {
        const href = match[1].replace(/^<|>$/g, '');
        if (/^(?:[a-z][a-z\d+.-]*:|\/\/|#)/i.test(href)) continue;
        const part = href.split(/[?#]/)[0];
        if (!part) continue;
        const target = path.resolve(path.dirname(file), decodeURIComponent(part));
        const relative = path.relative(workspace, target);
        if (relative.startsWith('..') || path.isAbsolute(relative)) { outside++; continue; }
        checked++;
        if (!fs.existsSync(target)) missing.push(`${path.relative(workspace, file)}:${i + 1} -> ${part}`);
      }
    });
  }
  return { checked, outside, missing };
}

if (require.main === module) {
  try {
    const inputs = process.argv.slice(2);
    const files = new Set();
    for (const input of inputs.length ? inputs : [path.join(workspace, 'specification'), path.join(workspace, 'everhorror/CLAUDE.md')]) collect(path.resolve(input), files);
    const result = checkLinks(files);
    for (const issue of result.missing) console.error(issue);
    console.log(`Document links: ${result.checked} file targets, ${result.missing.length} missing, ${result.outside} outside workspace (not checked). Fragments/remote URLs not checked.`);
    process.exitCode = result.missing.length ? 1 : 0;
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
module.exports = { checkLinks };
