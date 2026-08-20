# Commercial fonts

This repository ships the `fontset=commercial` configuration but does not commit font
binaries. From the repository root, install the exact files used by the original
[`yuan-resume`](https://github.com/xyz-yuanhf/yuan-resume) template:

```bash
make fonts
```

The installer requires `curl` plus either `sha256sum` or `shasum`.

That runs `fonts/download.sh`, which downloads from the pinned upstream commit
[`29b3944`](https://github.com/xyz-yuanhf/yuan-resume/commit/29b39442a176410012c6454cf64493175a19289c),
verifies every SHA-256 checksum, and creates:

```text
fonts/
├── SabonLTStd/
│   ├── SabonLTStd-Regular.ttf
│   ├── SabonLTStd-Bold.ttf
│   ├── SabonLTStd-Italic.ttf
│   └── SabonLTStd-BoldItalic.ttf
├── Calluna/Calluna-Regular.otf
├── CronosProLT/CronosProLT-Regular.ttf
└── CourierNew/CourierNew-Regular.ttf
```

The generated directories remain ignored by Git. The fonts are local project assets;
the script does not install them into the operating system.

## Licensing

These font files are not covered by this repository's MIT License. The upstream
template likewise states that copyrighted fonts are outside its MIT License. Before
downloading, redistributing, or using them, make sure the applicable font licences
permit your use. You can instead supply properly licensed files with the same names or
add another local `configs/fonts-<name>.tex` configuration.
