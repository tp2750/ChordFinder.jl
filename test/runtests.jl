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
    @test pitchclass(trim(Harmony(["G2","E3","G3","C","G"]))) == ["7","4","0"]
end

c1 = Chord(["C"],["C","E","G"])
@testset "Chord" begin
    @test name(c1) == "C"
    @test h1 ≈ h2 ≈ h3 ≈ c1
    @test isminor(Chord("Cm")) ## ["C","m"],["C","Eb","G"]))
    @test ! isminor(c1)
    @test ! isminor(Chord("C7")) ## ["C","7"],["C","E","G","Bb"]))
    @test isminor(Chord("Cm7")) 
end

@testset "Chordnames" begin
    ## all increasing:
    for c in ChordFinder.c_chords
        @test all(diff(c.harmony.pitches) .> 0)
    end
end

@testset "C-Chord local uniqueness" begin
    ## all increasing:
    similar = 0
    for i in 2:length(ChordFinder.c_chords)
        for j in 1:(i-1)
            c = ChordFinder.c_chords[i]
            c1 = ChordFinder.c_chords[j]
            if ( c ≈ c1 )
                @warn "$(name(c)) and $(name(c1)) are similar."
                similar += 1
            else
                @test  !( c ≈ c1 )
            end
        end
    end
    @test similar == 0 ## C-chords are non-similar
end

@testset "Transpose chord" begin
    @test transpose(Chord(["C"], ["C","E","G"]),1) == Chord(["C#"], ["C#","F","G#"])
end

# @testset "Global Chord uniqueness" begin
#     ## all increasing:
#     similar = 0
#     for i in 2:length(all_chords)
#         for j in 1:(i-1)
#             c = all_chords[i]
#             c1 = all_chords[j]
#             if ( c ≈ c1 )
#                 @info "$(name(c)) and $(name(c1)) are similar: $(show_pc(pitchclass(c))) ≈ $(show_pc(pitchclass(c1)))"
#                 similar += 1
#             else
#                 @test  !( c ≈ c1 )
#             end
#         end
#     end
#     @info "Found $similar out of $(length(all_chords)) chords to be similar ($(round(100*similar/length(all_chords),digits=1))%)"
# end

@testset "C-Chord global non-uniqueness" begin
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
                @test !( c ≈ c1 )
            end
        end
    end
    @info "Found $similar to one of the $(length((ChordFinder.c_chords))) C-chords."
    @info "Found $(length(synonyms)) of the C-chords to have at least one synonym."
    @info sort(collect(synonyms), by = x -> -length(x[2]))
    ## Note 17*12/2 = 102
    @test similar == 17
end

@testset "C-chords are Nonredundant" begin
    ## How many chords has repeated pich-classes?
    redundant = 0
    for c in ChordFinder.c_chords
        if !(c.harmony ≈ trim(c))
            @warn "$(name(c)) is redundant: $(show_pc(pitchclass(c)))"
            redundant += 1
        else
            @test c.harmony ≈ trim(c)
        end
    end
    @info "Found $redundant redundnat C-chords"
    @test redundant == 0
end

@testset "Bach" begin
    prae = (
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
        ["C2","C3","E","G","C5"]
    )

    @test chordnames.(prae) == (["C"], ["Dm⁷/C", "F⁶/C"], ["G⁷/B"], ["C"], ["Am/C"], ["D⁷/C"], ["G/B"], ["Cᐞ/B"], ["C⁶/A", "Am⁷"], ["D⁷"], ["G"], ["C♯°⁷/G", "E°⁷/G", "G°⁷", "A♯°⁷/G"], ["Dm/F"], ["D°⁷/F", "F°⁷", "G♯°⁷/F", "B°⁷/F"], ["C/E"], ["Fᐞ/E"], ["Dm⁷", "F⁶/D"], ["G⁷"], ["C"], ["C⁷"], ["Fᐞ"], ["C°⁷/F♯", "D♯°⁷/F♯", "F♯°⁷", "A°⁷/F♯"], ["A♯⁹/G♯"], ["G⁷"], ["C/G"], ["G⁷ˢᵘˢ⁴"], ["G⁷"], String[], ["C/G"], ["G⁷ˢᵘˢ⁴"], ["G⁷"], ["C⁷"], ["F/C"], ["Dm⁷/C", "F⁶/C"], String[], String[], ["C"])
end
