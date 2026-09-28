# tools

This repository has no build step — publishing is a push — with one exception:
the generated files in `stencils/v4/`, the current published folder.

```sh
node tools/generate-stencil-index.js          # rewrite stencils/v4/_index.json and _text_syntax.json
node tools/generate-stencil-index.js --check  # fail if they are out of date
```

`--published <dir>` indexes another folder (default `stencils/v4`); `--out`
defaults to the same folder. `stencils/v3/_index.json` and
`stencils/v3/_text_syntax.json` are **frozen**: v3 is what already-published
apps fetch, and they are not regenerated.

| File | What it is |
|---|---|
| `stencils/v4/_index.json` | One row per library placement — `id`, `name`, `category`, `group`, `library`, `file`, `source`, `default_size`, `generated`, `interpret_text`, `has_params`, `text_slots`, `has_title`. `has_title` is true when the template has a title: the first `texts` entry whose `external` is one of the strings `"bottom"`, `"top"`, `"left"`, `"right"`. A title is not counted in `text_slots`. The backend holds it in memory and every stencil search filters it. |
| `stencils/v4/_text_syntax.json` | For each template whose generator parses its own text: the separator, the markers, an authored one-line note and a worked example. |
| `tools/text-syntax-notes.json` | **Hand-authored input.** One short line per interpreting template. |

Regenerate in the same commit that changes a stencil. Files beginning with `_`
are outputs and are never themselves indexed; nothing in `lekhcore` requests
them, so no app fetches them.

## The AWS files are generated — do not hand-edit them

The 28 `stencils/v4/aws_*.json` files (813 shapes, library ids `aws.groups`,
`aws.categories` and `aws.services.*`) are the output of `svg2lekh`. Regenerate
them with

```sh
make -C svg2lekh lekhboard      # writes ../lekhboard/stencils/v4/aws_*.json
```

(`LEKHBOARD_V4=<dir>` overrides the destination), then rerun the index
generator in the same commit. A hand edit is lost at the next regeneration.
Every other file in `stencils/v4/` is a byte-identical copy of its `stencils/v3/`
namesake and is hand-maintained as before. v3's own 21 `aws_*.json` files are
the old icon set and are not in v4.

## Two things worth knowing before changing this

**The catalogue has two sources.** `stencils/v4/` is 105 files and 5,110 template
ids (77 copied from v3 plus the 28 generated AWS files; v3 was 98 files and 4,622
ids); together with the 13 core library files the index is 118 files and 5,212
rows; `lekhcore/stencils/core/` adds 27 ids this repository does not carry at all,
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
