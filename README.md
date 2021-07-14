# ChordFinder

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tp2750.github.io/ChordFinder.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tp2750.github.io/ChordFinder.jl/dev)
[![Build Status](https://github.com/tp2750/ChordFinder.jl/workflows/CI/badge.svg)](https://github.com/tp2750/ChordFinder.jl/actions)
[![Coverage](https://codecov.io/gh/tp2750/ChordFinder.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tp2750/ChordFinder.jl)

Find the chord that best matches a harmony.

# Background
This package grew out of my attempt to annotate chords to Bach's [Praeludium I](https://www.mutopiaproject.org/cgibin/piece-info.cgi?id=5) of Das Wohltemperierte Clavier.

Along the way I expanded my understanding of harmonies a bit.

# How many chords are there?

To get a list of chords, I started with [this list](http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart) and [this list](http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers) from Lilypond.
Lilypond knows a lot about music and notation, so that looked like a good place to start.

Wikipedia also has a [list of chords](https://en.wikipedia.org/wiki/List_of_chords), and I'll need to cross reference the lists at some point.

For notation, I use names based on [Lilypond](http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers) and try to replicate the notation as well as possible in Unicode. I still need to find superscripted versions of ♭, ♯ and ø.

The [wikipedia list](https://en.wikipedia.org/wiki/List_of_chords) introduces "pitch classes" as a notation of pitch mod 12: 0, 1, ..., 9, t, e.
This is a useful way of printing chords.

## When are chords equal

I define chords to be identical (=) if their vector of pich-plasses are identical (same order of notes), and I call the _similar_ (≈) if the _set_ of pich classes are identical (not considering order).

With this in place, we can take all 44 chords from Lilypond, and make all 11 transpositions by semitones, and check how many are similar:

```{julia}
    similar = 0
    for i in 2:length(all_chords)
        for j in 1:(i-1)
            c = all_chords[i]
            c1 = all_chords[j]
            if ( c ≈ c1 )
                @info "$(name(c)) and $(name(c1)) are similar: $(show_pc(pitchclass(c))) ≈ $(show_pc(pitchclass(c1)))"
                similar += 1
            else
                @test  !( c ≈ c1 )
            end
        end
    end
    @info "Found $similar out of $(length(all_chords)) chords to be similar ($(round(100*similar/length(all_chords),digits=1))%)"
```

Note that all the 44*12 = 528 chords are different, as the 44 c-based ones from Lilypond are different, and the transpositions give a new root note.

The result is at  102 out of 528 chords are similar (19.3%).

Here are the examples similar to the original 44 c-chords:

```{julia}
    similar = 0
    synonyms = Dict{String,Vector{String}}()
    for i in 1:length(ChordFinder.c_chords)
        for j in length(ChordFinder.c_chords)+1:length(all_chords) ## c_chords are first
            c = ChordFinder.c_chords[i]
            c1 = all_chords[j]
            if ( c ≈ c1 )
                @info "$(name(c)) and $(name(c1)) are similar: $(show_pc(pitchclass(c))) ≈ $(show_pc(pitchclass(c1)))"
                similar += 1
                push!(synonyms, name(c) => push!(get(synonyms,name(c),String[]),name(c1)))
            else
                @assert  !( c ≈ c1 )
            end
        end
    end
    @info "Found $similar to one of the $(length((ChordFinder.c_chords))) C-chords."
    @info "Found $(length(synonyms)) of the C-chords to have at least one synonym."
    sort(collect(synonyms), by = x -> -length(x[2]))
[ Info: C+ and E+ are similar: 0 4 8 ≈ 4 8 0
[ Info: C+ and G♯+ are similar: 0 4 8 ≈ 8 0 4
[ Info: Cm⁷ and D♯⁶ are similar: 0 3 7 t ≈ 3 7 t 0
[ Info: C°⁷ and D♯°⁷ are similar: 0 3 6 9 ≈ 3 6 9 0
[ Info: C°⁷ and F♯°⁷ are similar: 0 3 6 9 ≈ 6 9 0 3
[ Info: C°⁷ and A°⁷ are similar: 0 3 6 9 ≈ 9 0 3 6
[ Info: Cø and D♯m⁶ are similar: 0 3 6 t ≈ 3 6 t 0
[ Info: C⁶ and Am⁷ are similar: 0 4 7 9 ≈ 9 0 4 7
[ Info: Cm⁶ and Aø are similar: 0 3 7 9 ≈ 9 0 3 7
[ Info: C¹³ and FΔ¹³ are similar: 0 4 7 t 2 5 9 ≈ 5 9 0 4 7 t 2
[ Info: C¹³ and Gm¹³ are similar: 0 4 7 t 2 5 9 ≈ 7 t 2 5 9 0 4
[ Info: Cm¹³ and F¹³ are similar: 0 3 7 t 2 5 9 ≈ 5 9 0 3 7 t 2
[ Info: Cm¹³ and A♯Δ¹³ are similar: 0 3 7 t 2 5 9 ≈ t 2 5 9 0 3 7
[ Info: CΔ¹³ and Dm¹³ are similar: 0 4 7 e 2 5 9 ≈ 2 5 9 0 4 7 e
[ Info: CΔ¹³ and G¹³ are similar: 0 4 7 e 2 5 9 ≈ 7 e 2 5 9 0 4
[ Info: Cˢᵘˢ⁴ and Fˢᵘˢ² are similar: 0 5 7 ≈ 5 7 0
[ Info: Cˢᵘˢ² and Gˢᵘˢ⁴ are similar: 0 2 7 ≈ 7 0 2
[ Info: Found 17 to one of the 44 C-chords.
[ Info: Found 11 of the C-chords to have at least one synonym.
11-element Vector{Pair{String, Vector{String}}}:
   "C°⁷" => ["D♯°⁷", "F♯°⁷", "A°⁷"]
  "Cm¹³" => ["F¹³", "A♯Δ¹³"]
    "C+" => ["E+", "G♯+"]
   "C¹³" => ["FΔ¹³", "Gm¹³"]
  "CΔ¹³" => ["Dm¹³", "G¹³"]
 "Cˢᵘˢ⁴" => ["Fˢᵘˢ²"]
    "C⁶" => ["Am⁷"]
   "Cm⁷" => ["D♯⁶"]
 "Cˢᵘˢ²" => ["Gˢᵘˢ⁴"]
    "Cø" => ["D♯m⁶"]
   "Cm⁶" => ["Aø"]
```

We note that C+ is the "4-table" in our "pitch-class numbers", and E+ and G#+ are the "rotations".
Similarly, C°⁷ is the "3-table" and D♯°⁷, F♯°⁷, A°⁷ are the "rotations".

# Das Wohltemperierte Clavier

Now I have enugh to find the chords in Bach's preludium.

Below, I have typed in the the broken chords from Praeludium I Das Wohltemperierte Clavier as vectors of notes.
Then run the `chordnames` function to get the corresponding chords.

```{julia}
prae = [
        ["C","E","G","C5","E5"],
        ["C","D","A","D5","F5"],
        ["B3","D","G","D5","F5"],
        ["C","E","G","C5","E5"],
        ["C","E","A","E5","A5"],
        ["C","D","F#","A","D5"],
        ["B3","D","G","D5","G5"],
        ["B3","C","E","G","C5"],
        ["A3","C","E","G","C5"],
        ["D3","A3","D","F#","C5"],
        ["G3","B3","D","G","B"],
        ["G3","Bb3","E","G","C#5"], ## 12 "C♯°⁷/G, E°⁷/G, G°⁷, A♯°⁷/G"
        ["F3","A3","D","A","D5"],
        ["F3","Ab3","D","F","B"],
        ["E3","G3","C","G","C5"],
        ["E3","F3","A3","C","F"],
        ["D3","F3","A3","C","F"],
        ["G2","D3","G3","B3","F"],
        ["C3","E3","G3","C","E"],
        ["C3","G3","Bb3","C","E"],
        ["F2","F3","A3","C","E"],
        ["F#2","C3","A3","C","Eb"],
        ["Ab2","F3","Bb3","C","D"], ## 23  "A♯⁹/G♯"
        ["G2","F3","G3","B3","D"],
        ["G2","E3","G3","C","E"],
        ["G2","D3","G3","C","F"],
        ["G2","D3","G3","B","F"],
        ["G2","Eb3","A3","C","F#"], ## 28 []
        ["G2","E3","G3","C","G"], 
        ["G2","D3","G3","C","F"],
        ["G2","D3","G3","B3","F"],
        ["C2","C3","G3","Bb3","E"],
        ["C2","C3","F3","A3","C","F"],
        ["C2","C3","C","A3","F3","D3"], ## 33.2
        ["C2","B3","G","B","D5","F5"], ## 34.1 [] ??
        ["C2","B2","D5","B","G","D","F","E"], ## 34.2 []
        ["C2","C3","E","G","C5"],
		]
d = DataFrame(Bar = string.(1:length(prae)), Harmony = prae, Chord = chordnames.(prae));
d[33:37,"Bar"] = ["33.1", "33.2", "34.1", "34.2", "35"];
julia> show(d;allcols = true, truncate = 0)
37×3 DataFrame
 Row │ Bar     Harmony                                      Chord                                   
     │ String  Array…                                       Array…                                  
─────┼──────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 1       ["C", "E", "G", "C5", "E5"]                  ["C"]
   2 │ 2       ["C", "D", "A", "D5", "F5"]                  ["Dm⁷/C", "F⁶/C"]
   3 │ 3       ["B3", "D", "G", "D5", "F5"]                 ["G⁷/B"]
   4 │ 4       ["C", "E", "G", "C5", "E5"]                  ["C"]
   5 │ 5       ["C", "E", "A", "E5", "A5"]                  ["Am/C"]
   6 │ 6       ["C", "D", "F#", "A", "D5"]                  ["D⁷/C"]
   7 │ 7       ["B3", "D", "G", "D5", "G5"]                 ["G/B"]
   8 │ 8       ["B3", "C", "E", "G", "C5"]                  ["Cᐞ/B"]
   9 │ 9       ["A3", "C", "E", "G", "C5"]                  ["C⁶/A", "Am⁷"]
  10 │ 10      ["D3", "A3", "D", "F#", "C5"]                ["D⁷"]
  11 │ 11      ["G3", "B3", "D", "G", "B"]                  ["G"]
  12 │ 12      ["G3", "Bb3", "E", "G", "C#5"]               ["C♯°⁷/G", "E°⁷/G", "G°⁷", "A♯°⁷/G"]
  13 │ 13      ["F3", "A3", "D", "A", "D5"]                 ["Dm/F"]
  14 │ 14      ["F3", "Ab3", "D", "F", "B"]                 ["D°⁷/F", "F°⁷", "G♯°⁷/F", "B°⁷/F"]
  15 │ 15      ["E3", "G3", "C", "G", "C5"]                 ["C/E"]
  16 │ 16      ["E3", "F3", "A3", "C", "F"]                 ["Fᐞ/E"]
  17 │ 17      ["D3", "F3", "A3", "C", "F"]                 ["Dm⁷", "F⁶/D"]
  18 │ 18      ["G2", "D3", "G3", "B3", "F"]                ["G⁷"]
  19 │ 19      ["C3", "E3", "G3", "C", "E"]                 ["C"]
  20 │ 20      ["C3", "G3", "Bb3", "C", "E"]                ["C⁷"]
  21 │ 21      ["F2", "F3", "A3", "C", "E"]                 ["Fᐞ"]
  22 │ 22      ["F#2", "C3", "A3", "C", "Eb"]               ["C°⁷/F♯", "D♯°⁷/F♯", "F♯°⁷", "A°⁷/F♯"]
  23 │ 23      ["Ab2", "F3", "Bb3", "C", "D"]               ["A♯⁹/G♯"]
  24 │ 24      ["G2", "F3", "G3", "B3", "D"]                ["G⁷"]
  25 │ 25      ["G2", "E3", "G3", "C", "E"]                 ["C/G"]
  26 │ 26      ["G2", "D3", "G3", "C", "F"]                 ["G⁷ˢᵘˢ⁴"]
  27 │ 27      ["G2", "D3", "G3", "B", "F"]                 ["G⁷"]
  28 │ 28      ["G2", "Eb3", "A3", "C", "F#"]               String[]
  29 │ 29      ["G2", "E3", "G3", "C", "G"]                 ["C/G"]
  30 │ 30      ["G2", "D3", "G3", "C", "F"]                 ["G⁷ˢᵘˢ⁴"]
  31 │ 31      ["G2", "D3", "G3", "B3", "F"]                ["G⁷"]
  32 │ 32      ["C2", "C3", "G3", "Bb3", "E"]               ["C⁷"]
  33 │ 33.1    ["C2", "C3", "F3", "A3", "C", "F"]           ["F/C"]
  34 │ 33.2    ["C2", "C3", "C", "A3", "F3", "D3"]          ["Dm⁷/C", "F⁶/C"]
  35 │ 34.1    ["C2", "B3", "G", "B", "D5", "F5"]           String[]
  36 │ 34.2    ["C2", "B2", "D5", "B", "G", "D", "F", "E"]  String[]
  37 │ 35      ["C2", "C3", "E", "G", "C5"]                 ["C"]

```

We can see that good old Bach is actually quite imaginative, and is using a could of chords not covered this far!
