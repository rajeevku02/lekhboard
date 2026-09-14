# tools

This repository has no build step — publishing is a push — with one exception:
the two generated files in `stencils/v3/`.

```sh
node tools/generate-stencil-index.js          # rewrite them
node tools/generate-stencil-index.js --check  # fail if they are out of date
```

| File | What it is |
|---|---|
| `stencils/v3/_index.json` | One row per library placement — `id`, `name`, `category`, `group`, `library`, `file`, `source`, `default_size`, `generated`, `interpret_text`, `has_params`, `text_slots`. The backend holds it in memory and every stencil search filters it. |
| `stencils/v3/_text_syntax.json` | For each template whose generator parses its own text: the separator, the markers, an authored one-line note and a worked example. |
| `tools/text-syntax-notes.json` | **Hand-authored input.** One short line per interpreting template. |

Regenerate in the same commit that changes a stencil. Files beginning with `_`
are outputs and are never themselves indexed; nothing in `lekhcore` requests
them, so they are published but never fetched by an app.

## Two things worth knowing before changing this

**The catalogue has two sources.** `stencils/v3/` is 98 files and 4,622 template
ids; `lekhcore/stencils/core/` adds 27 ids this repository does not carry at all,
and they are three whole categories — **Basic**, **Container** and **Arrow**.
`avabodh.basic.rectangle` and `avabodh.container.slv` are core-only, so an index
built from this repository alone leaves an agent unable to place a plain box or a
swimlane. The generator therefore **reads** `../lekhcore/stencils/core` (override
with `--core`, or `LEKHCORE_STENCILS`) and **does not copy it**, and it **fails**
rather than writing a catalogue without those shapes. Where an id is in both
sources the published definition wins.

**A note is not optional.** The separator and the markers are derived from the
flags the Lua script passes to the host's `split()` — the only syntax the C++
`lua_split` actually honours — and the example is the template's own
`generator.text`. Neither can see the syntax that lives in the script body: the
menu's `---` separator row, the tree's icon names, the datagrid's column spec. So
the generator **fails** when a template has `interprettext: true` and no entry in
`tools/text-syntax-notes.json`.
