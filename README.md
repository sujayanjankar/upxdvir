# `{upxdvir}`

`{upxdvir}` is an extension to [`{xdvir}`](https://cran.r-project.org/package=xdvir) to enable the use of Unicode, and vertically typeset text with `{grid}` and `{ggplot2}` objects.

# TODOs

- [ ] Should upxdvir driver process DVIs generated from XeTeX/LuaTeX?
- [ ] Are .pfb fonts okay?
- [ ] Unusual font structures:
    - `test-luatex.dvi`: `fontname=[lmroman10-regular]:+tlig;`
    - `minimal-lualatexja-ltjt.dvi` - `fontname=file:HaranoAjiMincho-Regular.otf:-kern;jfm=ujisv`
- [ ] Keep engines separate?
- [ ] Bypass `tinytex::latexmk`?
- [ ] Can fontspec be gotten rid of for upLaTeX?