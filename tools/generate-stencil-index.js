#!/usr/bin/env node
'use strict';

/*
 * generate-stencil-index.js — build stencils/v3/_index.json and
 * stencils/v3/_text_syntax.json from BOTH catalogue sources.
 *
 * The catalogue is two sets, not one:
 *
 *   published  lekhboard/stencils/v3/*.json          98 files
 *   core       lekhcore/stencils/core/*.json         the files that carry a
 *                                                    `library` array (13 today)
 *
 * Three whole categories — Basic, Container and Arrow — exist ONLY in the core
 * set. `avabodh.basic.rectangle` and `avabodh.container.slv` are core-only, so
 * an index built from the published set alone leaves an agent unable to place a
 * plain box or a swimlane. This script therefore READS lekhcore; it does not
 * copy it, because a copy is the hand-refreshed duplicate the workspace's
 * source-of-truth rules warn about. If the core source has moved it FAILS
 * rather than publishing a catalogue without a rectangle.
 *
 * Where an id is in both sources the PUBLISHED definition wins, because that is
 * the one the apps' pickers serve.
 *
 * Usage:
 *   node tools/generate-stencil-index.js [options]
 *
 *     --core <dir>   lekhcore/stencils/core  (default: ../lekhcore/stencils/core)
 *     --lua  <dir>   lekhcore/stencils/lua   (default: <core>/../lua)
 *     --out  <dir>   where to write          (default: stencils/v3)
 *     --check        regenerate and diff against what is committed; write
 *                    nothing and exit non-zero if they differ
 *     --quiet        only print the summary
 *
 * Environment: LEKHCORE_STENCILS may supply the core directory instead of --core.
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const PUBLISHED_DIR = path.join(REPO_ROOT, 'stencils', 'v3');
const NOTES_FILE = path.join(__dirname, 'text-syntax-notes.json');

/* The core files that are NOT catalogues. They carry no `library` array and are
 * listed by name so that a core file which unexpectedly loses its library is a
 * failure rather than a silent omission. */
const CORE_NON_CATALOGUE = new Set([
    'connection_arrows.json', // the arrowhead set
    'templates.json',         // the text and image primitives
    'libnames.json',          // the search-alias map
]);

/* Core files without which the catalogue is missing something an agent reaches
 * for first. Their absence is fatal, not a warning. */
const CORE_REQUIRED = ['basic.json', 'container.json', 'arrow.json'];

/* Post-build invariants. These are the shapes AC-40c exists to protect. */
const REQUIRED_CATEGORIES = ['Basic', 'Container', 'Arrow'];
const REQUIRED_IDS = ['avabodh.basic.rectangle', 'avabodh.container.slv'];

// ---------------------------------------------------------------------------

function fail(message) {
    process.stderr.write('generate-stencil-index: FAILED\n  ' + message.replace(/\n/g, '\n  ') + '\n');
    process.exit(1);
}

function parseArgs(argv) {
    const opts = {
        core: process.env.LEKHCORE_STENCILS || path.resolve(REPO_ROOT, '..', 'lekhcore', 'stencils', 'core'),
        lua: null,
        out: PUBLISHED_DIR,
        check: false,
        quiet: false,
    };
    for (let i = 0; i < argv.length; i++) {
        const a = argv[i];
        if (a === '--core') { opts.core = argv[++i]; }
        else if (a === '--lua') { opts.lua = argv[++i]; }
        else if (a === '--out') { opts.out = argv[++i]; }
        else if (a === '--check') { opts.check = true; }
        else if (a === '--quiet') { opts.quiet = true; }
        else if (a === '-h' || a === '--help') {
            process.stdout.write(fs.readFileSync(__filename, 'utf8').split('*/')[0].replace(/^\/\*|^ \* ?/gm, '') + '\n');
            process.exit(0);
        } else { fail('unknown argument: ' + a); }
    }
    if (!opts.core) { fail('no core directory'); }
    opts.core = path.resolve(opts.core);
    opts.lua = opts.lua ? path.resolve(opts.lua) : path.resolve(opts.core, '..', 'lua');
    opts.out = path.resolve(opts.out);
    return opts;
}

function readJson(file) {
    let text;
    try {
        text = fs.readFileSync(file, 'utf8');
    } catch (e) {
        fail('cannot read ' + file + '\n' + e.message);
    }
    try {
        return JSON.parse(text);
    } catch (e) {
        fail(file + ' is not valid JSON\n' + e.message);
    }
}

/* Stencil files only. Anything beginning with `_` is one of this script's own
 * outputs and must never be indexed. */
function stencilFiles(dir) {
    return fs.readdirSync(dir)
        .filter((f) => f.endsWith('.json') && !f.startsWith('_'))
        .sort();
}

// --- the catalogue ---------------------------------------------------------

/*
 * A placement is either an inline object — { template: {...}, params: {...} } —
 * or a bare template id resolved against the file's top-level `templates[]`.
 * An id that resolves to nothing is skipped, exactly as
 * LibraryObjectStore::initObjects does (`if (tobj == nullptr) continue;`):
 * such a shape is not placeable in the apps either, and an index row with no
 * body would be offered to an agent and then fail as `unknown_stencil`.
 */
function collectPlacements(dir, source, files, dangling) {
    const rows = [];
    let libraryFiles = 0;
    for (const name of files) {
        const doc = readJson(path.join(dir, name));
        const library = doc.library;
        if (!Array.isArray(library)) { continue; }
        libraryFiles++;
        const byId = new Map();
        if (Array.isArray(doc.templates)) {
            for (const t of doc.templates) {
                if (t && typeof t.id === 'string') { byId.set(t.id, t); }
            }
        }
        const file = name.replace(/\.json$/, '');
        for (const categ of library) {
            const objects = Array.isArray(categ.objects) ? categ.objects : [];
            for (const obj of objects) {
                let template = null;
                let placementParams = null;
                if (typeof obj === 'string') {
                    template = byId.get(obj) || null;
                    if (!template) {
                        dangling.push({ id: obj, file: file, source: source, library: categ.id });
                        continue;
                    }
                } else if (obj && typeof obj === 'object') {
                    template = obj.template || null;
                    placementParams = obj.params || null;
                    if (!template || typeof template.id !== 'string') { continue; }
                } else {
                    continue;
                }
                rows.push(row(template, placementParams, categ, file, source));
            }
        }
    }
    return { rows: rows, libraryFiles: libraryFiles };
}

function defaultSize(template, placementParams) {
    const from = (o) => {
        if (!o || typeof o !== 'object') { return null; }
        const w = numeric(o.width);
        const h = numeric(o.height);
        return (w === null || h === null) ? null : [w, h];
    };
    return from(placementParams)
        || from(template.params)
        || from(template.libraryview)
        || null;
}

function numeric(v) {
    if (typeof v === 'number' && isFinite(v)) { return v; }
    // A template-level param is { value, order, editor } rather than a bare number.
    if (v && typeof v === 'object' && typeof v.value === 'number' && isFinite(v.value)) { return v.value; }
    return null;
}

/*
 * Text slots, from the body the generator already has open.
 *   texts: []           — a list of slots, one entry each
 *   texts: "default"    — one slot, placed at the shape's default location
 *   texts: "16 17 18.." — one slot, placed at those data points
 *   texts: ""           — none
 * A Lua generator carries its single text in generator.text rather than in
 * `texts` (spec/stencils.md §5), so that counts as one slot.
 */
function textSlots(template) {
    const tx = template.texts;
    if (Array.isArray(tx)) {
        if (tx.length > 0) { return tx.length; }
    } else if (typeof tx === 'string') {
        if (tx.trim() !== '') { return 1; }
    }
    const g = template.generator;
    if (g && typeof g === 'object' && typeof g.text === 'string' && g.text !== '') { return 1; }
    return 0;
}

function hasParams(template) {
    const p = template.params;
    return !!(p && typeof p === 'object' && !Array.isArray(p) && Object.keys(p).length > 0);
}

function generatorOf(template) {
    const g = template.generator;
    return (g && typeof g === 'object') ? g : null;
}

function row(template, placementParams, categ, file, source) {
    const g = generatorOf(template);
    return {
        id: template.id,
        name: typeof template.name === 'string' ? template.name : template.id,
        category: categ.category || categ.name || '',
        group: categ.group || '',
        library: categ.id || '',
        file: file,
        source: source,
        default_size: defaultSize(template, placementParams),
        generated: !!g,
        interpret_text: !!(g && g.interprettext),
        has_params: hasParams(template),
        text_slots: textSlots(template),
        _template: template,
    };
}

// --- text syntax -----------------------------------------------------------

const SEPARATOR_NAMES = { '\n': 'newline', ',': 'comma', '/': 'slash', ' ': 'space', '|': 'pipe', ';': 'semicolon' };

function separatorName(ch) {
    return SEPARATOR_NAMES[ch] || ch;
}

/*
 * The flags the script passes to the host's split() are what the C++ lua_split
 * actually honours (LuaShapeGenerator.cpp), so a marker list derived from them
 * cannot claim a syntax the host does not implement. checkWidth, checkHeight,
 * widthPad and heightPad are sizing, not syntax, and produce no marker.
 */
const SPLIT_FLAGS = ['by', 'checkSelection', 'checkDisabled', 'checkStartIcon', 'checkEndIcon',
    'checkEndText', 'checkIndent', 'checkEscapeNewLine'];

function parseSplitCalls(luaSource) {
    const calls = [];
    const re = /\bsplit\s*\(/g;
    let m;
    while ((m = re.exec(luaSource)) !== null) {
        // Find the option table literal — the `{ ... }` inside this call.
        const open = luaSource.indexOf('{', m.index);
        if (open === -1) { continue; }
        let depth = 0;
        let end = -1;
        for (let i = open; i < luaSource.length; i++) {
            if (luaSource[i] === '{') { depth++; }
            else if (luaSource[i] === '}') { depth--; if (depth === 0) { end = i; break; } }
        }
        if (end === -1) { continue; }
        const body = luaSource.slice(open + 1, end);
        const flags = {};
        const byMatch = /\bby\s*=\s*'((?:\\.|[^'])*)'/.exec(body) || /\bby\s*=\s*"((?:\\.|[^"])*)"/.exec(body);
        if (byMatch) {
            flags.by = byMatch[1].replace(/\\n/g, '\n').replace(/\\t/g, '\t').replace(/\\\\/g, '\\');
        }
        for (const f of SPLIT_FLAGS) {
            if (f === 'by') { continue; }
            const fm = new RegExp('\\b' + f + '\\s*=\\s*(true|false)').exec(body);
            if (fm) { flags[f] = fm[1] === 'true'; }
        }
        calls.push(flags);
    }
    return calls;
}

function markersFor(flags) {
    const markers = [];
    if (flags.checkSelection) { markers.push({ syntax: '*item', means: 'selected' }); }
    if (flags.checkDisabled) { markers.push({ syntax: '-item', means: 'disabled' }); }
    if (flags.checkSelection && flags.checkDisabled) {
        markers.push({ syntax: '*-item', means: 'selected and disabled; -* is the same' });
    }
    if (flags.checkStartIcon) { markers.push({ syntax: '[icon]item', means: 'leading icon, by icon name' }); }
    if (flags.checkEndIcon) { markers.push({ syntax: 'item[icon]', means: 'trailing icon, by icon name' }); }
    if (flags.checkEndText) { markers.push({ syntax: 'item,suffix', means: 'right-aligned trailing text' }); }
    if (flags.checkIndent) { markers.push({ syntax: '  item', means: 'leading spaces set the nesting level' }); }
    if (flags.checkSelection && flags.checkDisabled) {
        markers.push({ syntax: '\\*item', means: 'a literal * or - at the start of the item' });
    } else if (flags.checkSelection) {
        markers.push({ syntax: '\\*item', means: 'a literal * at the start of the item' });
    } else if (flags.checkDisabled) {
        markers.push({ syntax: '\\-item', means: 'a literal - at the start of the item' });
    }
    if (flags.checkEscapeNewLine) { markers.push({ syntax: '\\n', means: 'a line break inside the item' }); }
    return markers;
}

function luaSourceFor(luaRoot, scriptFile) {
    // "wireframe/menu_min.lua" is the minified copy the pack is built from.
    // Each script is in stencils/lua/ twice; scan the SOURCE.
    const base = path.basename(scriptFile).replace(/_min\.lua$/, '.lua');
    return path.join(luaRoot, 'wireframe_src', base);
}

function buildTextSyntax(interpreting, luaRoot, notes, warn) {
    const out = {};
    const missing = [];
    for (const r of interpreting) {
        const g = generatorOf(r._template);
        const example = typeof g.text === 'string' ? g.text : '';
        let separator = 'none';
        let markers = [];

        if (g.scriptfile) {
            const src = luaSourceFor(luaRoot, g.scriptfile);
            if (!fs.existsSync(src)) {
                fail('the Lua source for ' + r.id + ' is missing: ' + src + '\n'
                    + 'stencils/lua/ holds each script twice, as a source and as the minified copy '
                    + 'named by the template. The derived syntax is scanned from the source.');
            }
            const source = fs.readFileSync(src, 'utf8');
            const calls = parseSplitCalls(source);
            const splitsLines = /\bsplitLines\s*\(\s*shapeText\s*\)/.test(source);
            if (calls.length === 0) {
                separator = splitsLines ? 'newline' : 'none';
            } else {
                // The call that consumes shapeText decides the top-level separator;
                // a script that splits lines first and then each line is two levels.
                const outer = splitsLines ? '\n' : calls[0].by;
                separator = separatorName(outer);
                const flags = {};
                for (const c of calls) {
                    for (const f of SPLIT_FLAGS) {
                        if (f !== 'by' && c[f]) { flags[f] = true; }
                    }
                }
                markers = markersFor(flags);
                if (splitsLines) {
                    const inner = calls.find((c) => c.by && c.by !== '\n');
                    if (inner) {
                        markers.unshift({
                            syntax: 'cell' + inner.by + 'cell',
                            means: 'a ' + separatorName(inner.by) + ' starts the next column; the markers below apply per cell',
                        });
                    }
                }
            }
        } else if (g.script) {
            warn('template ' + r.id + ' interprets its text from an INLINE script; '
                + 'separator and markers could not be derived and are reported as none.');
        }

        const note = notes[r.id];
        if (typeof note !== 'string' || note.trim() === '') {
            missing.push(r.id);
            continue;
        }
        out[r.id] = {
            separator: separator,
            markers: markers,
            note: note,
            example: example,
        };
    }
    if (missing.length) {
        fail('every template with interprettext: true needs an authored one-line note in\n'
            + NOTES_FILE + '\nMissing for ' + missing.length + ':\n  ' + missing.join('\n  ')
            + '\nThe flags give the separator and the markers; the note is for the syntax '
            + 'that lives in the script body rather than in the flags, and a derived list '
            + 'alone would be confidently incomplete.');
    }
    return out;
}

// --- output ----------------------------------------------------------------

function serialiseIndex(rows) {
    if (rows.length === 0) { return '[]\n'; }
    return '[\n' + rows.map((r) => JSON.stringify(r)).join(',\n') + '\n]\n';
}

function serialiseTextSyntax(map) {
    const keys = Object.keys(map).sort();
    const parts = keys.map((k) => JSON.stringify(k) + ': ' + JSON.stringify(map[k], null, 2)
        .split('\n').map((l, i) => (i === 0 ? l : '  ' + l)).join('\n'));
    return '{\n  ' + parts.join(',\n  ') + '\n}\n';
}

function writeOrCheck(file, content, check, results) {
    const existing = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
    if (check) {
        if (existing !== content) {
            results.stale.push(file);
        }
        return;
    }
    if (existing === content) { results.unchanged.push(file); return; }
    fs.writeFileSync(file, content);
    results.written.push(file);
}

// --- main ------------------------------------------------------------------

function main() {
    const opts = parseArgs(process.argv.slice(2));
    const log = opts.quiet ? () => {} : (s) => process.stdout.write(s + '\n');
    const warnings = [];
    const warn = (s) => { warnings.push(s); };

    if (!fs.existsSync(PUBLISHED_DIR) || !fs.statSync(PUBLISHED_DIR).isDirectory()) {
        fail('the published catalogue is missing: ' + PUBLISHED_DIR);
    }
    if (!fs.existsSync(opts.core) || !fs.statSync(opts.core).isDirectory()) {
        fail('the core catalogue is missing: ' + opts.core + '\n'
            + 'The index covers BOTH sources. Basic, Container and Arrow — a plain rectangle, '
            + 'a swimlane, a standalone arrow — exist only in lekhcore/stencils/core, so an index '
            + 'built without it would be published missing the shapes a model reaches for first.\n'
            + 'Point --core (or LEKHCORE_STENCILS) at lekhcore/stencils/core.');
    }
    for (const required of CORE_REQUIRED) {
        if (!fs.existsSync(path.join(opts.core, required))) {
            fail('the core catalogue at ' + opts.core + ' has no ' + required + '.\n'
                + 'That file carries one of the three core-only categories. Refusing to publish '
                + 'a catalogue without it.');
        }
    }
    if (!fs.existsSync(path.join(opts.lua, 'wireframe_src'))) {
        fail('the Lua sources are missing: ' + path.join(opts.lua, 'wireframe_src') + '\n'
            + 'The interpreted-text syntax is derived from the split() flags in those sources.');
    }

    const publishedFiles = stencilFiles(PUBLISHED_DIR);
    const coreFiles = stencilFiles(opts.core);
    const dangling = [];

    const published = collectPlacements(PUBLISHED_DIR, 'published', publishedFiles, dangling);
    const core = collectPlacements(opts.core, 'core', coreFiles, dangling);

    for (const name of coreFiles) {
        const isCatalogue = !CORE_NON_CATALOGUE.has(name);
        const doc = readJson(path.join(opts.core, name));
        if (isCatalogue && !Array.isArray(doc.library)) {
            fail(name + ' is in ' + opts.core + ' and carries no `library` array, and it is not one '
                + 'of the three known non-catalogues (' + [...CORE_NON_CATALOGUE].join(', ') + ').\n'
                + 'Either it lost its library or this script needs teaching about it.');
        }
    }
    if (core.libraryFiles === 0) {
        fail('no file in ' + opts.core + ' carries a `library` array.');
    }

    // Published wins where an id is in both sources.
    const publishedIds = new Set(published.rows.map((r) => r.id));
    const coreOnlyRows = core.rows.filter((r) => !publishedIds.has(r.id));
    const rows = published.rows.concat(coreOnlyRows);

    rows.sort((a, b) => (a.id < b.id ? -1 : a.id > b.id ? 1
        : a.source < b.source ? -1 : a.source > b.source ? 1
        : a.file < b.file ? -1 : a.file > b.file ? 1
        : a.library < b.library ? -1 : a.library > b.library ? 1 : 0));

    // Post-build invariants: the shapes an index built from one source would lose.
    const categories = new Set(rows.map((r) => r.category));
    const groups = new Set(rows.map((r) => r.group));
    const ids = new Set(rows.map((r) => r.id));
    for (const c of REQUIRED_CATEGORIES) {
        if (!categories.has(c)) {
            fail('the category "' + c + '" is not in the index. It is core-only, so this means the '
                + 'core source was not read. Refusing to publish the catalogue.');
        }
    }
    for (const id of REQUIRED_IDS) {
        if (!ids.has(id)) {
            fail(id + ' is not in the index. It is core-only, so this means the core source was not '
                + 'read. Refusing to publish a catalogue an agent cannot place a box with.');
        }
    }

    /*
     * One row per distinct id for the interpreted-text pass. Rows are sorted, so
     * the first row for an id is the same one on every run, and a consumer that
     * wants a single definition per id can take it. Where two files define the
     * same id differently, say so: silently picking one would be a body that
     * disagrees with the row an agent searched.
     */
    const firstById = new Map();
    const byId = new Map();
    for (const r of rows) {
        if (!firstById.has(r.id)) { firstById.set(r.id, r); byId.set(r.id, []); }
        byId.get(r.id).push(r);
    }
    for (const [id, group] of byId) {
        if (group.length < 2) { continue; }
        const shapes = new Set(group.map((r) => JSON.stringify([r.generated, r.interpret_text, r.has_params, r.text_slots, r.default_size])));
        if (shapes.size > 1) {
            warn(id + ' is defined differently by ' + [...new Set(group.map((r) => r.source + '/' + r.file + '.json'))].join(' and ')
                + '. The first row, from ' + firstById.get(id).source + '/' + firstById.get(id).file + '.json, is the one to resolve a body from.');
        }
    }
    const interpreting = [...firstById.values()].filter((r) => r.interpret_text);

    const notes = readJson(NOTES_FILE);
    for (const id of Object.keys(notes)) {
        if (id.startsWith('_')) { continue; } // commentary, not a note
        if (!firstById.has(id)) { warn('note for an id that is not in the catalogue: ' + id); }
        else if (!firstById.get(id).interpret_text) { warn('note for a template that does not interpret its text: ' + id); }
    }
    const textSyntax = buildTextSyntax(interpreting, opts.lua, notes, warn);

    const indexRows = rows.map((r) => {
        const o = Object.assign({}, r);
        delete o._template;
        return o;
    });

    const results = { written: [], unchanged: [], stale: [] };
    writeOrCheck(path.join(opts.out, '_index.json'), serialiseIndex(indexRows), opts.check, results);
    writeOrCheck(path.join(opts.out, '_text_syntax.json'), serialiseTextSyntax(textSyntax), opts.check, results);

    // --- summary ---
    const firstRows = [...firstById.values()];
    const generated = firstRows.filter((r) => r.generated).length;
    const withParams = firstRows.filter((r) => r.has_params).length;
    const multiSlot = firstRows.filter((r) => r.text_slots > 1).length;
    log('published  ' + publishedFiles.length + ' files, ' + published.rows.length + ' placements, '
        + new Set(published.rows.map((r) => r.id)).size + ' ids, '
        + new Set(published.rows.map((r) => r.category)).size + ' categories');
    log('core       ' + core.libraryFiles + ' library files of ' + coreFiles.length + ', '
        + core.rows.length + ' placements, ' + new Set(core.rows.map((r) => r.id)).size + ' ids, '
        + new Set(core.rows.map((r) => r.category)).size + ' categories');
    log('union      ' + (publishedFiles.length + core.libraryFiles) + ' library files, '
        + indexRows.length + ' rows, ' + ids.size + ' ids, '
        + categories.size + ' categories, ' + groups.size + ' groups');
    log('core-only  ' + new Set(coreOnlyRows.map((r) => r.id)).size + ' ids in '
        + [...new Set(coreOnlyRows.map((r) => r.category))].sort().join(', '));
    log('ids        ' + generated + ' carry a generator, ' + interpreting.length + ' interpret their text, '
        + withParams + ' declare parameters, ' + multiSlot + ' have more than one text slot');

    for (const d of dangling) {
        warn('placement "' + d.id + '" in ' + d.source + '/' + d.file + '.json (' + d.library + ') '
            + 'references a template that file does not define. It is NOT in the index: the apps skip '
            + 'it too (LibraryObjectStore::initObjects), and an index row with no body would be offered '
            + 'and then fail as unknown_stencil.');
    }
    for (const w of warnings) { process.stderr.write('generate-stencil-index: warning: ' + w + '\n'); }

    if (opts.check) {
        if (results.stale.length) {
            process.stderr.write('generate-stencil-index: out of date:\n  '
                + results.stale.join('\n  ') + '\nRun tools/generate-stencil-index.js and commit the result.\n');
            process.exit(1);
        }
        log('check      up to date');
        return;
    }
    for (const f of results.written) { log('wrote      ' + path.relative(REPO_ROOT, f)); }
    for (const f of results.unchanged) { log('unchanged  ' + path.relative(REPO_ROOT, f)); }
}

main();
