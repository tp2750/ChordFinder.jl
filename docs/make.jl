using ChordFinder
using Documenter

DocMeta.setdocmeta!(ChordFinder, :DocTestSetup, :(using ChordFinder); recursive=true)

makedocs(;
    modules=[ChordFinder],
    authors="Thomas Poulsen",
    repo="https://github.com/tp2750/ChordFinder.jl/blob/{commit}{path}#{line}",
    sitename="ChordFinder.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tp2750.github.io/ChordFinder.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tp2750/ChordFinder.jl",
)
