module ChordFinder

import MIDI: pitch_to_name, name_to_pitch

export Harmony, trim, pitch_to_name, name_to_pitch
export Chord, name

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


end
