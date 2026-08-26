# `{upxdvir}`

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
- [ ] Exposed API will likely need cleanup, eventually, there will be no need to export `grid.uplatex` or `element_uplatex`. The same API is `{xdvir}` should be usable with just the `upLaTeX` engine.
- [ ] Fix the bounding box to make sure `vjust` works as expected. Currently, the glyphs are drawn slightly higher up on the viewport than they should be.
- [ ] Fix `tinytex::latexmk` args so that the `.fdb_latexmk` and `.aux` files are not created in the user's working directory.
- [ ] Mixed fonts: `cmr10.pfb` type fonts cause a segmentation fault. Potential reason is the font can't be found, seems to work on Paul's desktop, but with weird broken positioning for text from a different font. Observed traceback:
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
- [ ] Conditionally rotate glyphs for latin text.
- [ ] Naming convention? - [Google R Style Guide](https://google.github.io/styleguide/Rguide.html)

## Integration

Currently, a custom implementation is only needed for `xdvir::typeset`. `xdvir::author` and `xdvir::render` are used as-is in `grid.uplatex`.
`xdvir::typeset` needs to be different because engine args for `tinytex::latexmk` slightly differ when with `uplatex`. Output directory has a different quoting structure, and a different flag name. For example, `luatex` needs `--output-directory`, whereas `uptex` needs `-output-directory`.

What works:

```
## Options: -latex="uplatex -output-comment='R package xdvir_0.2.0; engine name: upTeX; engine version: e-upTeX 3.141592653-p4.1.2-u2.02-251130-2.6 (utf8.uptex) (TeX Live 2026); packages: ' '-output-directory=/var/folders/22/gfrffpq13pn5_6bym06gmwgr0000gn/T//RtmpM7w7VD'"
```

What `xdvir::typeset` produces:
```
## -latex=uplatex--output-comment="R package xdvir_0.2.0; engine name: upTeX; engine version: e-upTeX 3.141592653-p4.1.2-u2.02-251130-2.6 (utf8.uptex) (TeX Live 2026); packages: "'-output-directory=/var/folders/22/gfrffpq13pn5_6bym06gmwgr0000gn/T//RtmpXjRDC5'
```