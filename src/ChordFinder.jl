module ChordFinder

import MIDI: pitch_to_name, name_to_pitch
#import Base: transpose

export Harmony, trim, pitch_to_name, name_to_pitch
export Chord, name, pitchclass, transpose, show_pc, chords, chordnames
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

name(c::Chord) = join(c.name,"")

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
    "maj7b5" => "ᐞ♭⁵", ## TODO: supercript ♭
    "aug7" => "⁷♯⁵", ## TODO: superscript ♯
    "m7b5" => "ø", ## TODO superscript ø
    "6" => "⁶",
    "maj9" => "ᐞ⁹", ## 7 is maj, not 9
    "sus4" => "ˢᵘˢ⁴",
    "sus2" => "ˢᵘˢ²",
)

const c_chords =
    [
        ## Base
        Chord(["C"],     ["C","E","G"]),
        Chord(["C","m"], ["C","Eb","G"]),
        Chord(["C","+"], ["C","E","G#"]), ## aug
        Chord(["C","°"], ["C","Eb","Gb"]), ## dim
        ## 7ths
        Chord(["C","⁷"],     ["C","E","G","Bb"]),
        Chord(["C","m","⁷"], ["C","Eb","G","Bb"]),
        Chord(["C","ᐞ"],     ["C","E","G","B"]), ## maj7
        Chord(["C","m","ᐞ"], ["C","Eb","G","B"]), ## maj7
        Chord(["C","°⁷"],    ["C","Eb","Gb","A"]), ## dim7 ## OBS: minor
        Chord(["C","ø"],     ["C","Eb","Gb","Bb"]), ## m7b5 ## OBS: minor
        Chord(["C","m","ᐞ♭⁵"], ["C","Eb","Gb","B"]), ## maj7b5
        Chord(["C","⁷♯⁵"],   ["C","E","G#","Bb"]), ## aug7
        Chord(["C","ᐞ♯⁵"],   ["C","E","G#","B"]), ## maj7#5
        ## 6th
        Chord(["C","⁶"],     ["C","E","G","A"]),
        Chord(["C","m","⁶"],     ["C","Eb","G","A"]),
        ## 9th
        Chord(["C","⁹"],       ["C","E","G","Bb","D5"]),
        Chord(["C","m","⁹"],   ["C","Eb","G","Bb","D5"]),
        Chord(["C","m","⁷♭⁵⁹"],["C","Eb","Gb","Bb","D5"]),
        Chord(["C","⁷♭⁹"],     ["C","E","G","Bb","Db5"]),
        Chord(["C","⁷♯⁹"],     ["C","E","G","Bb","D#5"]),
        Chord(["C","⁷♯⁵♯⁹"],     ["C","E","G#","Bb","D#5"]),
        Chord(["C","Δ⁹"],       ["C","E","G","B","D5"]), ## maj9 cf http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        ## 11th
        Chord(["C","¹¹"],      ["C","E","G","Bb","D5","F5"]),
        Chord(["C","m","¹¹"],  ["C","Eb","G","Bb","D5","F5"]),
        Chord(["C","⁷♯¹¹"],    ["C","E","G","Bb","D5","F#5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","⁷♯⁹♯¹¹"],  ["C","E","G","Bb","D#5","F#5"]),
        Chord(["C","Δ♯¹¹"],    ["C","E","G","B","D5","F#5"]),
        ## 13th
        Chord(["C","¹³"],      ["C","E","G","Bb","D5","F5","A5"]),
        Chord(["C","m","¹³"],  ["C","Eb","G","Bb","D5","F5","A5"]),
        Chord(["C","⁷♯¹¹♭¹³"], ["C","E","G","Bb","D5","F#5","Ab5"]),
        Chord(["C","⁷♭¹³"],    ["C","E","G","Bb","D5","F5","Ab5"]),  ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","⁷♭⁹♭¹³"],  ["C","E","G","Bb","Db5","F5","Ab5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","⁷♭⁹¹³"],   ["C","E","G","Bb","Db5","F5","A5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","Δ¹³"],     ["C","E","G","B","D5","F5","A5"]), ## as maj9, it is the 7th that is maj
        Chord(["C","⁹ ¹³"],    ["C","E","G","Bb","D5","A5"]), ## only http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
        ## sus4
        Chord(["C","ˢᵘˢ⁴"],     ["C","F","G"]),
        Chord(["C","⁷ˢᵘˢ⁴"],     ["C","F","G", "Bb"]),
        Chord(["C","⁹ˢᵘˢ⁴"],     ["C","F","G", "Bb","D5"]),
        ## Other
        Chord(["C","ᵃᵈᵈ⁹"],     ["C","E","G", "D5"]), ## Lilypond: C⁹??
        Chord(["C","m","ᵃᵈᵈ¹¹"],["C","Eb","G", "F5"]), ## Lilypond: Cm¹¹??
        Chord(["C","ˡʸᵈ"],     ["C","E","G", "B","F#5"]), 
        Chord(["C","ᵃˡᵗ"],     ["C","E","G", "Bb","Db5","Eb5","F#5","Ab5"]),
        Chord(["C","ˢᵘˢ²"],    ["C","D","G"]), ## http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
        Chord(["C","ᴾ⁵"],     ["C","G","C5"]), ## Powerchord. Name from wikipedia. http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers
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
