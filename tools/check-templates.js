#!/usr/bin/env node
'use strict';

/*
 * check-templates.js — the stencil check (Work 01M4X17C spec 04 §7): rules every
 * template in a published library file must pass before it is pushed.
 *
 * The engine holds the same rules in its own module and runs them over its
 * compiled-in sets; this is lekhboard's own copy (lekhboard depends on nothing
 * outside itself), and the two test suites share their fixtures by content
 * (tools/fixtures/check-templates/). It reads plain JSON and evaluates nothing.
 *
 * Failure codes:
 *
 *   port_without_id              a port with no or empty `id`
 *   port_duplicate_id            two ports with one `id`
 *   port_index_out_of_range      a port's `x` or `y` is not an index of `data`
 *   port_dir_unknown             `dir` is not left, right, up or down
 *   connect_value_unknown        `connect` is not outline, ports,
 *                                outline_and_ports or none
 *   connect_ports_without_ports  `connect: "ports"` with no valid port
 *   boundary_not_closed          `primitive_for_intersection` set, no `bound`,
 *                                and the first draw path is not closed — unless
 *                                the engine never connects to the template
 *                                (its effective connect is none: an open
 *                                polygon, an open path template or a Bézier
 *                                curve with no `connect` and no port, or
 *                                `connect: "none"`)
 *
 * Usage:
 *   node tools/check-templates.js [dir…]   (default: stencils/v6)
 *
 * Every *.json file of each folder is checked, except the generated `_*.json`
 * outputs. Exit 0 when nothing fails; else exit 1, one line per failure naming
 * the file, the template id and the code.
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const DEFAULT_DIRS = [path.join(REPO_ROOT, 'stencils', 'v6')];

const PORT_DIR_NAMES = ['left', 'right', 'up', 'down'];
const CONNECT_VALUES = ['outline', 'ports', 'outline_and_ports', 'none'];
const FLAG_PRIMITIVE_FOR_INTERSECT = 0x2;
const FLAG_CLOSED = 0x10;

const isObj = (v) => typeof v === 'object' && v !== null && !Array.isArray(v);
const isIndex = (v, len) => typeof v === 'number' && Number.isInteger(v) && v >= 0 && v < len;
const isInt = (v) => typeof v === 'number' && Number.isInteger(v);

/* `primitive_for_intersection` as the reader decides it: `flags` when present, else the boolean. */
function usesPathForIntersection(t) {
    if (isInt(t.flags)) { return (t.flags & FLAG_PRIMITIVE_FOR_INTERSECT) !== 0; }
    return t.primitive_for_intersection === true;
}

/* The first `draw` entry's path string (a string entry, or an object's `path`), or null. */
function firstDrawPath(t) {
    if (!Array.isArray(t.draw)) { return null; }
    for (const e of t.draw) {
        if (typeof e === 'string') {
            if (e !== '') { return e; }
        } else if (isObj(e) && typeof e.path === 'string' && e.path !== '') {
            return e.path;
        }
    }
    return null;
}

/* The template class the reader picks: by id for the four basic ids, else `polygon: true`. */
function templateClass(t) {
    switch (t.id) {
        case 'avabodh.basic.polygon': return 'polygon';
        case 'avabodh.basic.curve': return 'curve';
        case 'avabodh.basic.text': return 'text';
        case 'avabodh.basic.path': return 'path';
    }
    return t.polygon === true ? 'polygon' : 'shape';
}

/* The closed switch: `flags` 0x10 when present; else the `closed` boolean, read on a polygon only. */
function closedSwitch(t) {
    if (isInt(t.flags)) { return (t.flags & FLAG_CLOSED) !== 0; }
    return templateClass(t) === 'polygon' && t.closed === true;
}

/* A polygon template whose closed switch is on (it closes its own path). */
function isClosedPolygon(t) {
    return templateClass(t) === 'polygon' && closedSwitch(t);
}

/* The engine's hard-coded open kinds: an open polygon, an open path template, a Bézier curve. */
function isOpenKind(t) {
    const k = templateClass(t);
    if (k === 'curve') { return true; }
    return (k === 'polygon' || k === 'path') && !closedSwitch(t);
}

/*
 * The effective connect is `none` (spec 04 §4): `connect: "none"`; `connect:
 * "ports"` with no valid port; or no (or an unknown) `connect`, no valid port and
 * an open kind. Such a template is never a connector end.
 */
function isNotConnectable(t, validPorts) {
    const connect = t.connect;
    if (connect === 'none') { return true; }
    if (connect === 'ports') { return validPorts === 0; }
    if (connect === undefined || !CONNECT_VALUES.includes(connect)) { return validPorts === 0 && isOpenKind(t); }
    return false;
}

const ARITY = { m: 2, l: 2, h: 1, v: 1, c: 6, q: 4, a: 6, e: 5, r: 7, z: 0 };

/*
 * Whether a draw path (commands over `data` indices) is closed: every sub-path
 * ends with `Z`, is an ellipse (`E`) or rounded rectangle (`R`), or returns to
 * its `M`'s point with an absolute `L`, `C`, `Q` or `A`. "Its point" compares
 * the two indices' `data` expressions as written (white space ignored) when
 * `data` is given, else the indices. A path with no sub-path is not closed.
 */
function isDrawPathClosed(pathStr, data) {
    const expr = (k) => {
        if (k === undefined) { return ''; }
        const e = data ? data[Number(k)] : undefined;
        return typeof e === 'string' ? e.replace(/\s+/g, '') : typeof e === 'number' ? String(e) : '#' + k;
    };
    const tokens = pathStr.match(/[A-Za-z]|\d+/g) || [];
    const subs = [];
    let cur = null;
    const sub = () => {
        if (cur === null) {
            cur = { start: null, end: null, closed: false, drawn: false };
            subs.push(cur);
        }
        return cur;
    };
    let i = 0;
    while (i < tokens.length) {
        const ch = tokens[i++];
        const lower = ch.toLowerCase();
        const arity = ARITY[lower];
        if (arity === undefined) { continue; }
        const args = tokens.slice(i, i + arity);
        i += arity;
        const abs = ch !== lower;
        const pair = (a, b) => expr(args[a]) + ' ' + expr(args[b]);
        switch (lower) {
            case 'm':
                cur = { start: abs ? pair(0, 1) : null, end: null, closed: false, drawn: false };
                subs.push(cur);
                break;
            case 'z':
                sub().closed = true;
                cur = null;
                break;
            case 'e':
            case 'r':
                subs.push({ start: null, end: null, closed: true, drawn: true });
                cur = null;
                break;
            default: {
                const s = sub();
                s.drawn = true;
                if (!abs || lower === 'h' || lower === 'v') { s.end = null; }
                else if (lower === 'l') { s.end = pair(0, 1); }
                else if (lower === 'c' || lower === 'a') { s.end = pair(4, 5); }
                else if (lower === 'q') { s.end = pair(2, 3); }
                if (s.start !== null && s.end === s.start) { s.closed = true; }
                else if (s.closed) { s.closed = false; }
            }
        }
    }
    const drawn = subs.filter((s) => s.drawn || s.closed);
    return drawn.length > 0 && drawn.every((s) => s.closed);
}

/* The failures of one template body, as { templateId, code, detail }; a by-reference body has none. */
function checkTemplate(template) {
    if (!isObj(template)) { return []; }
    const id = typeof template.id === 'string' ? template.id : '';
    const keys = Object.keys(template);
    if (keys.length === 1 && keys[0] === 'id') { return []; }
    const out = [];
    const fail = (code, detail) => out.push({ templateId: id, code, detail });

    const data = Array.isArray(template.data) ? template.data : null;
    const dataLen = data ? data.length : 0;
    const ports = template.ports;
    let validPorts = 0;
    if (ports !== undefined) {
        if (!Array.isArray(ports)) {
            fail('port_without_id', 'ports is not an array');
        } else {
            const seen = new Set();
            ports.forEach((p, i) => {
                const at = 'port ' + i;
                const pid = isObj(p) ? p.id : undefined;
                let ok = true;
                if (typeof pid !== 'string' || pid === '') {
                    fail('port_without_id', at);
                    ok = false;
                } else if (seen.has(pid)) {
                    fail('port_duplicate_id', at + ' (' + pid + ')');
                    ok = false;
                } else {
                    seen.add(pid);
                }
                if (!isObj(p) || !isIndex(p.x, dataLen) || !isIndex(p.y, dataLen)) {
                    fail('port_index_out_of_range', at);
                    ok = false;
                }
                if (isObj(p) && p.dir !== undefined && !PORT_DIR_NAMES.includes(p.dir)) {
                    fail('port_dir_unknown', at);
                }
                if (ok) { validPorts++; }
            });
        }
    }

    const connect = template.connect;
    if (connect !== undefined && !(typeof connect === 'string' && CONNECT_VALUES.includes(connect))) {
        fail('connect_value_unknown', typeof connect === 'string' ? connect : typeof connect);
    }
    if (connect === 'ports' && validPorts === 0) { fail('connect_ports_without_ports', 'no valid port'); }

    const hasBound = typeof template.bound === 'string' && template.bound !== '';
    if (usesPathForIntersection(template) && !hasBound && !isNotConnectable(template, validPorts)) {
        const first = firstDrawPath(template);
        const closed = first === null || isClosedPolygon(template) || isDrawPathClosed(first, data || []);
        if (!closed) { fail('boundary_not_closed', 'first draw path'); }
    }
    return out;
}

/* Every template of a library file (`templates`, `arrows`, each `library[].objects[].template`), in file order. */
function checkLibraryFile(file) {
    if (!isObj(file)) { return []; }
    const out = [];
    const each = (list, pick) => {
        if (Array.isArray(list)) { for (const e of list) { out.push(...checkTemplate(pick(e))); } }
    };
    each(file.templates, (t) => t);
    each(file.arrows, (t) => t);
    if (Array.isArray(file.library)) {
        for (const cat of file.library) {
            if (isObj(cat)) { each(cat.objects, (o) => (isObj(o) ? o.template : undefined)); }
        }
    }
    return out;
}

/* Every failure of the library files in `dir` (sorted by name, `_*.json` skipped), each with its file. */
function checkDir(dir) {
    if (!fs.existsSync(dir) || !fs.statSync(dir).isDirectory()) {
        throw new Error('not a folder: ' + dir);
    }
    const out = [];
    const files = fs.readdirSync(dir).filter((f) => f.endsWith('.json') && !f.startsWith('_')).sort();
    for (const f of files) {
        const file = path.join(dir, f);
        let json;
        try {
            json = JSON.parse(fs.readFileSync(file, 'utf8'));
        } catch (e) {
            out.push({ file, templateId: '', code: 'not_json', detail: e.message });
            continue;
        }
        for (const x of checkLibraryFile(json)) { out.push(Object.assign({ file }, x)); }
    }
    return { files: files.length, failures: out };
}

function main(argv) {
    const dirs = argv.length > 0 ? argv.map((d) => path.resolve(d)) : DEFAULT_DIRS;
    let files = 0;
    const failures = [];
    for (const dir of dirs) {
        let r;
        try {
            r = checkDir(dir);
        } catch (e) {
            process.stderr.write('check-templates: ' + e.message + '\n');
            return 1;
        }
        files += r.files;
        failures.push(...r.failures);
    }
    const shown = dirs.map((d) => path.relative(REPO_ROOT, d) || '.').join(', ');
    if (failures.length > 0) {
        process.stderr.write('check-templates: FAILED — ' + failures.length + ' failure(s) in ' + shown + ':\n'
            + failures.map((f) => '  ' + path.relative(REPO_ROOT, f.file) + ' ' + (f.templateId || '(no id)') + ' '
                + f.code + (f.detail ? ' (' + f.detail + ')' : '')).join('\n') + '\n');
        return 1;
    }
    process.stdout.write('check-templates: ' + files + ' files in ' + shown + ', no template fails\n');
    return 0;
}

module.exports = { checkTemplate, checkLibraryFile, checkDir, isDrawPathClosed };

if (require.main === module) {
    process.exitCode = main(process.argv.slice(2));
}
