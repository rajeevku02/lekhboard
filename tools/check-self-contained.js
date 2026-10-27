#!/usr/bin/env node
'use strict';

/*
 * check-self-contained.js — fail if a tool in this repository refers to the
 * retired C++ core repository.
 *
 * The stencil index generator's core set and Lua sources are committed under
 * tools/core-stencils/ (see tools/README.md), so no tool may read them from the
 * core repository any more: when it is archived, such a tool would break. This
 * scans every tool script and tool data file (not the committed copies under
 * tools/core-stencils/, which are stencil data) and every file at the
 * repository root that drives a build, and exits 1 naming each line that
 * mentions it.
 *
 * Usage: node tools/check-self-contained.js
 */

const fs = require('fs');
const path = require('path');

const REPO_ROOT = path.resolve(__dirname, '..');
const FORBIDDEN = /lekhcore/i;
const TOOL_EXT = /\.(js|cjs|mjs|json|sh|py)$/;
const ROOT_BUILD_FILES = ['Makefile', 'package.json', '.github'];

function walk(dir, out) {
    for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, e.name);
        if (e.isDirectory()) {
            if (p === path.join(__dirname, 'core-stencils')) { continue; }
            walk(p, out);
        } else if (TOOL_EXT.test(e.name) || e.name === 'Makefile') {
            out.push(p);
        }
    }
    return out;
}

const files = walk(__dirname, []);
for (const name of ROOT_BUILD_FILES) {
    const p = path.join(REPO_ROOT, name);
    if (!fs.existsSync(p)) { continue; }
    if (fs.statSync(p).isDirectory()) { walk(p, files); } else { files.push(p); }
}

const hits = [];
for (const f of files) {
    if (f === __filename) { continue; }
    fs.readFileSync(f, 'utf8').split('\n').forEach((line, i) => {
        if (FORBIDDEN.test(line)) { hits.push(path.relative(REPO_ROOT, f) + ':' + (i + 1) + ': ' + line.trim()); }
    });
}

if (hits.length) {
    process.stderr.write('check-self-contained: FAILED — a tool refers to lekhcore, which is being retired:\n  '
        + hits.join('\n  ') + '\nRead the input from tools/core-stencils/ instead.\n');
    process.exit(1);
}
process.stdout.write('check-self-contained: ' + files.length + ' tool files, none refers to lekhcore\n');
