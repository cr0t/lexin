# Image Assets

In this directory we put original assets that can be used as sources for the rest of the website.

We used Inkscape to create the source icon, then we:

- exported it as Plain SVGs (adjusted File -> Document Properties... first, to set dimensions) as "full" and "square" versions
- optimized them using https://svgomg.net/ (non-default options: Precision 3, Prettify markup)
- used "square" version to create favicons set (following [How to Favicon in 2024: Six files that fit most needs](https://evilmartians.com/chronicles/how-to-favicon-in-2021-six-files-that-fit-most-needs) guide)

## OpenGraph Image Blueprint

The main structure of OG image card is this:

```
(bold)             - value         - dfn.value
(dimmed, optional) - transcription - dfn.base.phonetic.transcription
(dimmed, optional) - inflections   - Enum.join(inflections(@dfn), ", ")
(optional)         - meaning       - @dfn.base.meaning
(bold, optional)   - translation   - @dfn.target.translation
(dimmed, optional) - synonyms      - Enum.join(@dfn.target.synonyms, ", ")
```

For the fields reference see: ../../lib/lexin_web/components/cards/definition.html.heex
