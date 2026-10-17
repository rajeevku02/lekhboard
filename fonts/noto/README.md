# Noto script fonts for PDF export

The web board's vector PDF export (lekhjs `WebScriptFontProvider`) downloads one of these when a
text run's script is not covered by the bundled fonts (Noto Sans, Noto Serif, Noto Sans Mono,
Caveat), keeps it in Cache Storage (`lekh-pdf-fonts-v1`) and embeds it as a subset.

- `manifest.json` maps `<script>` / `<script>-bold` to `{file, weight, bytes, sha256}`; Han is
  `sc`, `tc`, `jp`, `kr`. A body whose SHA-256 differs from the manifest is never used.
- Static fonts only: hinted TTFs from notofonts/notofonts.github.io and the SubsetOTF (CFF) CJK
  fonts from notofonts/noto-cjk, at the commits named in the manifest.
- Licence: SIL Open Font License 1.1 (`OFL-notofonts.txt`, `OFL-noto-cjk.txt`).

Rebuild with `node tools/build-noto-fonts.js`; verify with `node tools/build-noto-fonts.js --check`.
Native apps never download these: they use the system fonts (`LekhPlugin.getFontData`).
