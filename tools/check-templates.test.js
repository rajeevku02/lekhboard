'use strict';

/*
 * Tests of tools/check-templates.js (Work 01M4X17C spec 04 §7). Run with
 * `node --test tools/`. The fixtures in tools/fixtures/check-templates/ are
 * shared by content with the engine's own suite: one library file per failure
 * code, which fails with exactly that code, and pass.json (a ported template,
 * the open kinds the engine never connects to, and an open first path with a
 * closed `bound`), which passes.
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const { execFileSync, spawnSync } = require('child_process');
const { checkTemplate, checkLibraryFile, checkDir, isDrawPathClosed } = require('./check-templates');

const REPO_ROOT = path.resolve(__dirname, '..');
const FIXTURES = path.join(__dirname, 'fixtures', 'check-templates');
const TOOL = path.join(__dirname, 'check-templates.js');
const readJson = (f) => JSON.parse(fs.readFileSync(f, 'utf8'));

const CODES = [
    'port_without_id',
    'port_duplicate_id',
    'port_index_out_of_range',
    'port_dir_unknown',
    'connect_value_unknown',
    'connect_ports_without_ports',
    'boundary_not_closed',
];

test('the fixture folder holds one file per code and pass.json', () => {
    const files = fs.readdirSync(FIXTURES).filter((f) => f.endsWith('.json')).sort();
    assert.deepEqual(files, [...CODES.map((c) => c + '.json'), 'pass.json'].sort());
});

for (const code of CODES) {
    test(code + '.json fails with exactly that code', () => {
        const failures = checkLibraryFile(readJson(path.join(FIXTURES, code + '.json')));
        assert.ok(failures.length > 0);
        assert.deepEqual([...new Set(failures.map((f) => f.code))], [code]);
        assert.ok(failures.every((f) => f.templateId === 'test.check.' + code));
    });
}

test('pass.json passes; the failing port is named', () => {
    assert.deepEqual(checkLibraryFile(readJson(path.join(FIXTURES, 'pass.json'))), []);
    const failures = checkLibraryFile(readJson(path.join(FIXTURES, 'port_without_id.json')));
    assert.deepEqual(failures.map((f) => f.detail), ['port 0', 'port 1']);
});

test('boundary_not_closed: only with primitive_for_intersection and no bound; the exempt kinds', () => {
    const box = {
        id: 't',
        data: ['-w/2', '-h/2', 'w/2', '-h/2', 'w/2', 'h/2', '-w/2', 'h/2'],
        draw: ['M 0 1 L 2 3 L 4 5 L 6 7'],
    };
    const codes = (t) => checkTemplate(t).map((f) => f.code);
    assert.deepEqual(codes(box), []);
    assert.deepEqual(codes({ ...box, primitive_for_intersection: true }), ['boundary_not_closed']);
    assert.deepEqual(codes({ ...box, flags: 2 }), ['boundary_not_closed']);
    assert.deepEqual(codes({ ...box, flags: 5, primitive_for_intersection: true }), []);
    assert.deepEqual(codes({ ...box, flags: 2, bound: 'M 0 1 L 2 3 L 4 5 L 6 7 Z' }), []);
    assert.deepEqual(codes({ ...box, flags: 0x12, polygon: true }), []);
    assert.deepEqual(codes({ ...box, flags: 2, closed: true }), ['boundary_not_closed']);
    // Exempt: the effective connect is none.
    assert.deepEqual(codes({ ...box, flags: 2, polygon: true }), []);
    assert.deepEqual(codes({ ...box, flags: 2, polygon: true, closed: true }), []);
    assert.deepEqual(codes({ ...box, flags: 2, id: 'avabodh.basic.path' }), []);
    assert.deepEqual(codes({ ...box, flags: 7, id: 'avabodh.basic.curve' }), []);
    assert.deepEqual(codes({ ...box, flags: 2, connect: 'none' }), []);
    assert.deepEqual(codes({ ...box, flags: 2, connect: 'ports' }), ['connect_ports_without_ports']);
    assert.deepEqual(codes({ ...box, flags: 2, polygon: true, connect: 'x' }), ['connect_value_unknown']);
    assert.deepEqual(codes({ ...box, flags: 2, connect: 'x' }), ['connect_value_unknown', 'boundary_not_closed']);
    // Not exempt: an explicit outline connect or a valid port makes an open kind connectable.
    assert.deepEqual(codes({ ...box, flags: 2, polygon: true, connect: 'outline' }), ['boundary_not_closed']);
    assert.deepEqual(codes({ ...box, flags: 2, polygon: true, ports: [{ id: 'a', x: 0, y: 1 }] }),
        ['boundary_not_closed']);
    assert.deepEqual(codes({ ...box, flags: 0x12, id: 'avabodh.basic.path' }), ['boundary_not_closed']);
    assert.deepEqual(codes({ id: 'g', data: [], flags: 2, generator: { script: '' } }), []);
    assert.deepEqual(codes({ id: 'avabodh.basic.rectangle' }), []);
});

test('closed paths: Z, back to the start point, E and R; every sub-path', () => {
    const data = ['-w/2', '-h/2', 'w/2', '0', '-w / 2', '-h/2'];
    assert.equal(isDrawPathClosed('M 0 1 L 2 3 Z'), true);
    assert.equal(isDrawPathClosed('M 0 1 L 2 3 L 0 1'), true);
    assert.equal(isDrawPathClosed('M 0 1 L 2 3 L 4 5', data), true);
    assert.equal(isDrawPathClosed('M 0 1 L 2 3 L 4 5'), false);
    assert.equal(isDrawPathClosed('M 0 1 C 2 3 2 3 0 1'), true);
    assert.equal(isDrawPathClosed('E 0 1 2 3 4'), true);
    assert.equal(isDrawPathClosed('R 0 1 2 3 4 4 4'), true);
    assert.equal(isDrawPathClosed('M 0 1 L 2 3 Z M 4 5 L 2 3'), false);
    assert.equal(isDrawPathClosed('M 0 1 L 2 3 L 0 1 L 4 5'), false);
    assert.equal(isDrawPathClosed('M 0 1 l 2 3 l 4 5'), false);
    assert.equal(isDrawPathClosed(''), false);
});

test('a port may fail several codes', () => {
    const t = {
        id: 't',
        data: ['-w/2', '-h/2', 'w/2', '-h/2', 'w/2', 'h/2', '-w/2', 'h/2'],
        draw: ['M 0 1 L 2 3 L 4 5 L 6 7 Z'],
        ports: [{ id: 'a', x: 8, y: 0, dir: 'out' }, { id: 'a', x: 0, y: 1 }],
        connect: 'ports',
    };
    assert.deepEqual(checkTemplate(t).map((f) => f.code),
        ['port_index_out_of_range', 'port_dir_unknown', 'port_duplicate_id', 'connect_ports_without_ports']);
});

test('stencils/v6 passes', () => {
    const r = checkDir(path.join(REPO_ROOT, 'stencils', 'v6'));
    assert.ok(r.files > 100);
    assert.deepEqual(r.failures, []);
});

test('stencils/v5 (frozen, without the bounds) is flagged on the two templates v6 fixes', () => {
    const r = checkDir(path.join(REPO_ROOT, 'stencils', 'v5'));
    assert.deepEqual(r.failures.map((f) => path.basename(f.file) + ' ' + f.templateId + ' ' + f.code), [
        'flowchart.json avabodh.flowchart.multiple_documents boundary_not_closed',
        'misc.json avabodh.misc.component boundary_not_closed',
    ]);
});

test('the command: default stencils/v6 exits 0; a failing folder exits 1 naming file, id and code', () => {
    const ok = spawnSync(process.execPath, [TOOL], { cwd: REPO_ROOT, encoding: 'utf8' });
    assert.equal(ok.status, 0, ok.stderr);
    assert.match(ok.stdout, /stencils\/v6/);
    const bad = spawnSync(process.execPath, [TOOL, FIXTURES], { cwd: REPO_ROOT, encoding: 'utf8' });
    assert.equal(bad.status, 1);
    for (const code of CODES) {
        assert.ok(bad.stderr.includes('tools/fixtures/check-templates/' + code + '.json test.check.' + code + ' ' + code),
            code);
    }
    assert.ok(!bad.stderr.includes('pass.json'));
    const missing = spawnSync(process.execPath, [TOOL, path.join(FIXTURES, 'nope')], { encoding: 'utf8' });
    assert.equal(missing.status, 1);
});

test('check-self-contained.js still passes', () => {
    execFileSync(process.execPath, [path.join(__dirname, 'check-self-contained.js')], { encoding: 'utf8' });
});
