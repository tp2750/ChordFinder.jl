module ChordFinder

import MIDI: pitch_to_name, name_to_pitch
#import Base: transpose

export Harmony, trim, pitch_to_name, name_to_pitch
export Chord, name, pitchclass, transpose, show_pc, chords, chordnames, modifier, isminor
export all_chords, modifier_symbols

struct Harmony
    pitches::Vector{Int}
end

Harmony(h::Vector{String}) = Harmony(name_to_pitch.(h))

"""
    transpose(h::Harmony,semitones)
    Transpose the harmony by the given amount of semitones
"""
Base.transpose(h::Harmony,semitones) = Harmony(h.pitches .+ semitones)

Base.length(h::Harmony) = length(h.pitches)
Base.:(==)(h1::Harmony, h2::Harmony) = h1.pitches == h2.pitches
pitch_to_name(h::Harmony) = pitch_to_name.(h.pitches)

function pitchclass(i)::String
    r = i % 12
    r == 10 && return("t")
    r == 11 && return("e")
    string(r)
end

pitchclass(h::Harmony) = pitchclass.(h.pitches)
pitchclass(s::String) = pitchclass(Harmony([s]))

"""
    trim(h::Harmony)
    Remove redundant notes in harmony. It preserves the order.
"""
function trim(h::Harmony)
    h1 = deepcopy(h)
    for i in 2:length(h)
        for j in 1:(i-1)
            if( h.pitches[i] % 12) == (h.pitches[j] % 12)
                h1.pitches[i] = -1 ## ith note already found
                continue
            end
        end
    end
    Harmony(h1.pitches[h1.pitches .>= 0])
end

Base.isapprox(h1::Harmony, h2::Harmony) = Set(h1.pitches .% 12) == Set(h2.pitches .% 12)

struct Chord
    name::Vector{String}
    harmony::Harmony
end

"""
    Chord(n::Vector{String},h::Vector{String})
    Short-hand to define Chord from name-vector and harmony vector.
"""
Chord(n::Vector{String},h::Vector{String}) = Chord(n, Harmony(h))

Base.length(c::Chord) = length(c.harmony)
Base.:(==)(c1::Chord, c2::Chord) = c1.harmony == c2.harmony
Base.isapprox(c1::Chord, c2::Chord) = c1.harmony ≈ c2.harmony

function name(c::Chord; pretty = true)
    c1 = deepcopy(c)
    if (pretty & hasmodifier(c))
        c1.name[end] = modifier_symbols[c1.name[end]]
    end
    join(c1.name,"")
end

function isminor(c::Chord)
    length(c.name) == 1 && return(false) ## plain major
    length(c.name) >= 2 && c.name[2] == "m" && return(true) ## minor
    false
end

function hasmodifier(c::Chord)
    length(c.name) == 1 && return(false) ## plain major
    length(c.name) == 2 && c.name[2] == "m" && return(false) ## plain minor
    true
end

function modifier(c::Chord)
    (! hasmodifier(c)) && return("")
    last(c.name)
end

Base.:(==)(c1::Chord, h2::Harmony) = c1.harmony == h2
Base.:(==)(h2::Harmony, c1::Chord) = c1 == h2

Base.isapprox(c1::Chord, h2::Harmony) = c1.harmony ≈ h2
Base.isapprox(h2::Harmony,c1::Chord) = c1 ≈ h2

"""
    transpose(c::Chord, semitones)
    transpose the chord by the given amount of semitones
    Example:
    ```{julia}
        transpose(Chord(["C"], ["C","E","G"]),1) == Chord(["C#"], ["C#","F","G#"])
    ```
"""
function Base.transpose(c::Chord,p)
    newharmony = transpose(c.harmony,p)
    newname = copy(c.name)
    newname[1] = pitch_to_name(newharmony.pitches[1]) |> chop
    Chord(newname, newharmony)    
end

pitchclass(c::Chord) = pitchclass(c.harmony)
show_pc(pc) = join(pc, " ")

trim(c::Chord) = trim(c.harmony)

## Chords from http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
## More systematic: http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers: mor esystematic, but less complete
## See also https://en.wikipedia.org/wiki/List_of_chords

## TODO: dictionary to translate long to short
## TODO: dictionary to translate 

## problem: "dim" == ["m","b5"], Lilypond uses "m7.5-" for "ø"

## From http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
const modifier_symbols = Dict(
    "aug" => "+", ## obs not superscript in Lilypond
    "dim" => "°",
    "7" => "⁷",
    "maj7" => "ᐞ", ## Δ looks better, but should be superscript
    "dim7" => "°⁷",
    "m7b5" => "ø", ## TODO superscript ø
    "maj7b5" => "ᐞ♭⁵", ## TODO: supercript ♭
    "aug7" => "⁷♯⁵", ## TODO: superscript ♯
    "6" => "⁶",
    "9" => "⁹",
    "maj9" => "ᐞ⁹", ## 7 is maj, not 9
    "7b5 9" => "⁷♭⁵⁹",
    "7b9" => "⁷♭⁹",
    "7#9" => "⁷♯⁹",
    "7#5#9" => "⁷♯⁵♯⁹",
    "maj9" => "ᐞ⁹", ## 7 is maj, not 9
    "11" => "¹¹",
    "7#11"=> "⁷♯¹¹",
    "7#9#11" => "⁷♯⁹♯¹¹",
    "maj7#11" => "ᐞ♯¹¹", ## 7 is maj, not 11
    "13" => "¹³",
    "7#11b13" => "⁷♯¹¹♭¹³",
    "7b13" => "⁷♭¹³",
    "7b9b13" => "⁷♭⁹♭¹³",
    "7b9 13" => "⁷♭⁹ ¹³",
    "maj13" => "ᐞ¹³", # 7 is maj, not 13
    "9 13" => "⁹ ¹³", 
    "sus4" => "ˢᵘˢ⁴",
    "7sus4" => "⁷ˢᵘˢ⁴",
    "9sus4" => "⁹ˢᵘˢ⁴",
    "add9" => "ᵃᵈᵈ⁹",
    "add11" => "ᵃᵈᵈ¹¹",
    "lyd" => "ˡʸᵈ",
    "alt" => "ᵃˡᵗ",    
    "sus2" => "ˢᵘˢ²",
    "P5" => "ᴾ⁵", # power chord
    
)

const c_chords=
    [
        ## Base
        Chord(["C"],     ["C","E","G"]),
        Chord(["C","m"], ["C","Eb","G"]),
        Chord(["C","aug"], ["C","E","G#"]), ## aug +
        Chord(["C","dim"], ["C","Eb","Gb"]), ## dim °
        ## 7ths
        Chord(["C","7"],     ["C","E","G","Bb"]),
        Chord(["C","m","7"], ["C","Eb","G","Bb"]),
        Chord(["C","maj7"],     ["C","E","G","B"]), ## maj7 ᐞ
        Chord(["C","m","maj7"], ["C","Eb","G","B"]), ## maj7
        Chord(["C","dim7"],    ["C","Eb","Gb","A"]), ## dim7 ## OBS: minor
        Chord(["C","m7b5"],     ["C","Eb","Gb","Bb"]), ## m7b5 ## OBS: minor ø
        Chord(["C","m","maj7b5"], ["C","Eb","Gb","B"]), ## maj7b5
        Chord(["C","aug7"],   ["C","E","G#","Bb"]), ## aug7
        Chord(["C","maj7#5"],   ["C","E","G#","B"]), ## maj7#5
        ## 6th
        Chord(["C","6"],     ["C","E","G","A"]),
        Chord(["C","m","6"],     ["C","Eb","G","A"]),
        ## 9th
        Chord(["C","9"],       ["C","E","G","Bb","D5"]),
        Chord(["C","m","9"],   ["C","Eb","G","Bb","D5"]),
        Chord(["C","m","7b5 9"],["C","Eb","Gb","Bb","D5"]),
        Chord(["C","7b9"],     ["C","E","G","Bb","Db5"]),
        Chord(["C","7#9"],     ["C","E","G","Bb","D#5"]),
        Chord(["C","7#5#9"],     ["C","E","G#","Bb","D#5"]),
        Chord(["C","maj9"],       ["C","E","G","B","D5"]), ## maj9 cf http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        ## 11th
        Chord(["C","11"],      ["C","E","G","Bb","D5","F5"]),
        Chord(["C","m","11"],  ["C","Eb","G","Bb","D5","F5"]),
        Chord(["C","7#11"],    ["C","E","G","Bb","D5","F#5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","7#9#11"],  ["C","E","G","Bb","D#5","F#5"]),
        Chord(["C","maj7#11"],    ["C","E","G","B","D5","F#5"]),
        ## 13th
        Chord(["C","13"],      ["C","E","G","Bb","D5","F5","A5"]),
        Chord(["C","m","13"],  ["C","Eb","G","Bb","D5","F5","A5"]),
        Chord(["C","7#11b13"], ["C","E","G","Bb","D5","F#5","Ab5"]),
        Chord(["C","7b13"],    ["C","E","G","Bb","D5","F5","Ab5"]),  ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","7b9b13"],  ["C","E","G","Bb","Db5","F5","Ab5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","7 b9 13"],   ["C","E","G","Bb","Db5","F5","A5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","maj13"],     ["C","E","G","B","D5","F5","A5"]), ## as maj9, it is the 7th that is maj
        Chord(["C","9 13"],    ["C","E","G","Bb","D5","A5"]), ## only http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
        ## sus4
        Chord(["C","sus4"],     ["C","F","G"]),
        Chord(["C","7sus4"],     ["C","F","G", "Bb"]),
        Chord(["C","9sus4"],     ["C","F","G", "Bb","D5"]),
        ## Other
        Chord(["C","add9"],     ["C","E","G", "D5"]), ## Lilypond: C⁹??
        Chord(["C","m","add11"],["C","Eb","G", "F5"]), ## Lilypond: Cm¹¹??
        Chord(["C","lyd"],     ["C","E","G", "B","F#5"]), 
        Chord(["C","alt"],     ["C","E","G", "Bb","Db5","Eb5","F#5","Ab5"]),
        Chord(["C","sus2"],    ["C","D","G"]), ## http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
        Chord(["C","P5"],     ["C","G","C5"]), ## Powerchord. Name from wikipedia. http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
    ]


## OBS: it looks like quite a lot of minors are missing?

"""
    all_chords
    Vector containing all chords
    all_chords[45]
    Chord(["C♯"], Harmony([61, 65, 68]))
"""
const all_chords = Chord[]

for p in 0:11
    for c in 1:length(c_chords)
        push!(all_chords,transpose(c_chords[c],p))
    end
end

"""
    chords(h::Harmony)
    Return chords matching harmony:
    If there is a chord matching the harmony, return that (as a 1-element vector).
    Else trim the chord to non-redundant pich-classes and return all matching
"""
function chords(h::Harmony)
    found = Chord[]
    for c in all_chords
        if c.harmony == h
            return([c])
        elseif c.harmony ≈ trim(h)
            push!(found, c)
        end
    end
    found
end

chords(h::Vector{String}) = chords(Harmony(h))

function chordnames(h::Harmony)
    cs = chords(h)
    names = String[]
    for c in cs
        n = name(c)
        if first(pitchclass(c.name[1])) != pitchclass(h)[1] ## alt bass
            n = n * "/" * chop(pitch_to_name(h.pitches[1]))
        end
        push!(names, n)
    end
    names
end
chordnames(s::Vector{String}) = chordnames(Harmony(s))
end
