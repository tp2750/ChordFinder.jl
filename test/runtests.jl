using ChordFinder
using MIDI: pitch_to_name, name_to_pitch
using Test

h1 = Harmony(["C4","E4","G4"])
h2 = Harmony(["C4","E4","G4","C5"])
h3 = Harmony(["E4","G4","C5"])
h4 = Harmony(["E0","C1","G2"])
@testset "Harmony" begin
    @test trim(h1) == trim(h2)
    @test h1 ≈ h2 ≈ h3 ≈ h4
end

c1 = Chord(["C"],["C","E","G"])
@testset "Chord" begin
    @test name(c1) == "C"
    @test h1 ≈ h2 ≈ h3 ≈ c1
end

@testset "Chordnames" begin
    ## all increasing:
    for c in ChordFinder.c_chords
        @test all(diff(c.harmony.pitches) .> 0)
    end
end

@testset "Chord uniqueness" begin
    ## all increasing:
    for i in 2:length(ChordFinder.c_chords)
        for j in 1:(i-1)
            c = ChordFinder.c_chords[i]
            c1 = ChordFinder.c_chords[j]
            if ( c ≈ c1 )
                @info "$(name(c)) and $(name(c1)) are similar."
            else
                @test  !( c ≈ c1 )
            end
        end
    end
end

