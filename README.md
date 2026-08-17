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
- [ ] Mixed fonts
- [ ] GSUB based glyph rotation
- [ ] PUT operations in DVI
- [ ] Text wrapping?

What further changes are required to:

1. typeset()
   - Engine args: output directory has a different quoting structure, and a different flag name. For example, `luatex` needs `--output-directory`, whereas `uptex` needs `-output-directory`.
2. render()
