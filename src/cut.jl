## From ChordFinder.jl
const c_chords_mod = ## these can be deleted
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
        Chord(["C","ᐞ⁹"],       ["C","E","G","B","D5"]), ## maj9 cf http://lilypond.org/doc/v2.20/Documentation/notation/common-chord-modifiers ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        ## 11th
        Chord(["C","¹¹"],      ["C","E","G","Bb","D5","F5"]),
        Chord(["C","m","¹¹"],  ["C","Eb","G","Bb","D5","F5"]),
        Chord(["C","⁷♯¹¹"],    ["C","E","G","Bb","D5","F#5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","⁷♯⁹♯¹¹"],  ["C","E","G","Bb","D#5","F#5"]),
        Chord(["C","ᐞ♯¹¹"],    ["C","E","G","B","D5","F#5"]),
        ## 13th
        Chord(["C","¹³"],      ["C","E","G","Bb","D5","F5","A5"]),
        Chord(["C","m","¹³"],  ["C","Eb","G","Bb","D5","F5","A5"]),
        Chord(["C","⁷♯¹¹♭¹³"], ["C","E","G","Bb","D5","F#5","Ab5"]),
        Chord(["C","⁷♭¹³"],    ["C","E","G","Bb","D5","F5","Ab5"]),  ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","⁷♭⁹♭¹³"],  ["C","E","G","Bb","Db5","F5","Ab5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","⁷♭⁹ ¹³"],   ["C","E","G","Bb","Db5","F5","A5"]), ## repeated in http://lilypond.org/doc/v2.20/Documentation/notation/chord-name-chart
        Chord(["C","ᐞ¹³"],     ["C","E","G","B","D5","F5","A5"]), ## as maj9, it is the 7th that is maj
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

