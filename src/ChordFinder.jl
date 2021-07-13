module ChordFinder

import MIDI: pitch_to_name, name_to_pitch

export Harmony, trim, pitch_to_name, name_to_pitch
export Chord, name, pitchclass

struct Harmony
    pitches::Vector{Int}
end

Harmony(h::Vector{String}) = Harmony(name_to_pitch.(h))

Base.length(h::Harmony) = length(h.pitches)
Base.:(==)(h1::Harmony, h2::Harmony) = h1.pitches == h2.pitches
pitch_to_name(h::Harmony) = pitch_to_name.(h.pitches)

"""
    trim(h::Harmony)
    Remove redundant notes in harmony
"""
function trim(h::Harmony)
    h1 = deepcopy(h)
    for i in 2:length(h)
        for j in 1:(i-1)
            if( h.pitches[i] % 12) == (h.pitches[j] % 12)
                deleteat!(h1.pitches,i) ## ith note already found
                continue
            end
        end
    end
    h1
end

Base.isapprox(h1::Harmony, h2::Harmony) = Set(h1.pitches .% 12) == Set(h2.pitches .% 12)

struct Chord
    name::Vector{String}
    harmony::Harmony
end

Chord(n::Vector{String},h::Vector{String}) = Chord(n, Harmony(h))

Base.length(c::Chord) = length(c.harmony)
Base.:(==)(c1::Chord, c2::Chord) = c1.harmony == c2.harmony
Base.isapprox(c1::Chord, c2::Chord) = c1.harmony ≈ c2.harmony

name(c::Chord) = join(c.name,"")

Base.:(==)(c1::Chord, h2::Harmony) = c1.harmony == h2
Base.:(==)(h2::Harmony, c1::Chord) = c1 == h2

Base.isapprox(c1::Chord, h2::Harmony) = c1.harmony ≈ h2
Base.isapprox(h2::Harmony,c1::Chord) = c1 ≈ h2

function pitchclass(i)::String
    r = i % 12
    r == 10 && return("t")
    r == 11 && return("e")
    string(r)
end

pitchclass(h::Harmony) = pitchclass.(h.pitches)
pitchclass(c::Chord) = pitchclass(c.harmony)

    
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
    "maj7" => "ᐞ",
    "dim7" => "°⁷",
    "maj7b5" => "ᐞ♭⁵", ## TODO: supercript ♭
    "aug7" => "⁷♯⁵", ## TODO: superscript ♯
    "m7b5" => "ø", ## TODO superscript ø
    "6" => "⁶",
    "maj9" => "Δ⁹", ## 7 is maj, not 9
    "sus4" => "ˢᵘˢ⁴",
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

## OBS: quite a lot of minors are missing


end
