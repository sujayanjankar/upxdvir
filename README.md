# `{upxdvir}`

<!-- TODO: Switch to main. -->

[![{upxdvir} Package check](https://github.com/sujayanjankar/upxdvir/actions/workflows/package-check.yaml/badge.svg?branch=feature%2Ffirst-implementation)](https://github.com/sujayanjankar/upxdvir/actions/workflows/package-check.yaml)
  
`{upxdvir}` is an extension to [`{xdvir}`](https://cran.r-project.org/package=xdvir) to enable the use of Unicode, and vertically typeset text with `{grid}` and `{ggplot2}` objects.

# TODOs

- [x] Should upxdvir driver process DVIs generated from XeTeX/LuaTeX?
- [x] Are .pfb fonts okay?
- [x] Unusual font structures:
  - `test-luatex.dvi`: `fontname=[lmroman10-regular]:+tlig;`
  - `minimal-lualatexja-ltjt.dvi` - `fontname=file:HaranoAjiMincho-Regular.otf:-kern;jfm=ujisv`
- [x] Keep engines separate?
- [x] Bypass `tinytex::latexmk`?
- [x] Can fontspec be gotten rid of for upLaTeX?
- [x] `tinytex` and `knitr` both have `kpsewhich` functions, but do not export them.
- [x] How independent can upxdvir rendering be from xdvir?
- [x] GSUB based glyph rotation
- [x] PUT operations in DVI
- [x] Text wrapping?
  ```
  \setlength{\textheight}{40zw}
  \setlength{\textwidth}{1.5in}
  ```
- [ ] Fill out documentation files and DESCRIPTION file.
- [x] Exposed API will likely need cleanup, eventually, there will be no need to export `grid.uplatex` or `element_uplatex`. The same API is `{xdvir}` should be usable with just the `upLaTeX` engine.
- [x] Fix the bounding box to make sure `vjust` works as expected. Currently, the glyphs are drawn slightly higher up on the viewport than they should be.
- [x] Fix `tinytex::latexmk` args so that the `.fdb_latexmk` and `.aux` files are not created in the user's working directory.
- [x] Mixed fonts: `cmr10.pfb` type fonts cause a segmentation fault. Potential reason is the font can't be found, seems to work on Paul's desktop, but with weird broken positioning for text from a different font. Observed traceback:

  ```
  *** caught segfault ***
  address 0x0, cause 'invalid permissions'

  Traceback:
  1: grid.Call.graphics(C_glyph, as.integer(runs$lengths), x$glyphInfo,     gx, gy)
  2: drawDetails.glyphgrob(x, recording = FALSE)
  3: drawDetails(x, recording = FALSE)
  4: drawGrob(x)
  5: recordGraphics(drawGrob(x), list(x = x), getNamespace("grid"))
  6: grid.draw.grob(x$children[[i]], recording = FALSE)
  7: grid.draw(x$children[[i]], recording = FALSE)
  8: drawGTree(x)
  9: recordGraphics(drawGTree(x), list(x = x), getNamespace("grid"))
  10: grid.draw.gTree(x$children[[i]], recording = FALSE)
  11: grid.draw(x$children[[i]], recording = FALSE)
  12: drawGTree(x)
  13: recordGraphics(drawGTree(x), list(x = x), getNamespace("grid"))
  14: grid.draw.gTree(dviGrob(...))
  15: grid.draw(dviGrob(...))
  ```

- [x] Conditionally rotate glyphs for latin text.
- [x] Fine tune position of the rotated glyphs for latin text.
- [x] Naming convention? - [Google R Style Guide](https://google.github.io/styleguide/Rguide.html) - Camel-casing everywhere.
- [x] Honour `gp = gpar(fontsize = 20)` and other `gpar`s.
- [x] Include `documentClass` in engine options? - No, should be with `grid.??latex`.
- [ ] Extend `{xdvir}` documentation to include the supported script types.
- [ ] Support: `grid.uplatex("$\\frac{1}{2}$")`
- [x] Glyph indexer should be direction aware.
- [ ] Investigate `LuaHBTeX` failure.
- [x] Font face support in 0.2 `xdvir`?
- [x] Independent font library specification?
- [x] Font family changes with/without `gpar`s.
- [ ] Math fonts? `newtxmath`/`newpxmath` etc.
- [x] Should the Kanji default also control Latin font? - No, because `pxchfon` fonts are half-width, not proportional.
- [x] `element_latex(documentClass = "utarticle")` **_OR_** `element_latex(dir = 1)` which internally applies the classes/options?
- [ ] Is this supposed to work?
  ```
  gg +
      labs(subtitle = "En") +
      theme(text = element_latex(family = "menlo"))
  ```
- [x] Should the height gpar be allowed for vertical typesetting only? - No, get wrappers over uplatex to do that.
- [x] For user installed fonts, `OSFONTDIR` should be set so `kpsewhich` can find those fonts.
- [ ] Independent font file support should be provided.
- [x] Get rid of `minipagePackage` and `height` arg.

## Challenges

Specifying an absolute font can be done in two ways with `pxchfon`:
    - Directly set it as `\setminchofont{fontname.otf}` or `\setgothicfont{fontname.ttf}` in the preamble. This requires the file to be searchable by `kpsewhich`.
    - Use `systemfonts::matchfont`, which requires the font to be "installed", not just present at a path where `kpsewhich` can find it. Upside, can find bold weight fonts, if installed. Downside, if the CJK font could not be found with something like `systemfonts::matchfont('Source Han Sans')`, it returns a Latin font, `Helvetica` for MacOS.

- [x] Should the upLaTeX (+ grid) API determine whether a given font is serif or sans-serif? If a font file is given as `gp = gpar(fontfamily = "SourceHanSans-Bold.otf")`, how can it be decided whether this is the Gothic font or Mincho font?
- [x] Would specifying a font family for latin fonts also be allowed via the `uplatex` API? - No, just sans, serif & mono.
- Two potential font weight specifications:
    - When Mincho (serif) text is to be emphasised, it is shown as Gothic (sans-serif) instead
    - `pxchfon` can specify both the Mincho and Gothic fonts, but the `grid`/`uplatex` API allows for only 1.
- Solution: use `\mcfamily` in the fragment.
- [x] `.pfb` file support in MacOS?
- [x] Error handling for font family that is supported by `pxchon` (`ptex-fontmap`) presets, but the physical OTF files are not installed.
- [ ] `gdiff` unit tests
- [ ] Try the `ragg` / `cairo` package for png or pdf devices.