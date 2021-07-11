using ChordFinder
using MIDI: pitch_to_name, name_to_pitch
using Test

h1 = Harmony(["C4","E4","G4"])
h2 = Harmony(["C4","E4","G4","C5"])
h3 = Harmony(["E4","G4","C5"])
@testset "Harmony" begin
    @test trim(h1) == trim(h2)
    @test h1 ≈ h2 ≈ h3
end

c1 = Chord("C","",["C","E","G"])
@testset "Chord" begin
    @test name(c1) == "C"
    @test h1 ≈ h2 ≈ h3 ≈ c1
end
