using { /Verse.org/Simulation }

point3<public> := struct:
    X<public> : float
    Y<public> : float
    Z<public> : float

spawn_candidate<public> := struct:
    Name<public> : string
    Position<public> : Map.point3
    DistanceToNearestEnemy<public> : float

spawn_point<public> := struct:
    Name<public> : string
    Position<public> : Map.point3
    TeamIndex<public> : int

spawn_selector<public> := class:
    var SpawnEventLog : []string = array{}

    SelectSpawnByDistance<public>(Candidates : []Map.spawn_candidate) : string =
        var BestName : string = ""
        var BestDistance : float = -1.0
        for (Candidate : Candidates):
            SafeDistance := MaxFloat(Candidate.DistanceToNearestEnemy, 0.0)
            if (SafeDistance > BestDistance):
                set BestDistance = SafeDistance
                set BestName = Candidate.Name

        set SpawnEventLog += array{"SelectSpawnByDistance"}
        return BestName

    SelectSpawnForTeam<public>(TeamIndex : int, EnemyPositions : []Map.point3) : string =
        Candidates := BuildCandidatesForTeam(TeamIndex, EnemyPositions)
        return SelectSpawnByDistance(Candidates)

    BuildCandidatesForTeam(TeamIndex : int, EnemyPositions : []Map.point3) : []Map.spawn_candidate =
        var Candidates : []Map.spawn_candidate = array{}
        Points := GetSpawnPoints()
        for (Point : Points):
            if (Point.TeamIndex = TeamIndex):
                Nearest := GetNearestEnemyDistance(Point.Position, EnemyPositions)
                set Candidates += array{
                    Map.spawn_candidate{Name := Point.Name, Position := Point.Position, DistanceToNearestEnemy := Nearest}
                }
        return Candidates

    GetSpawnPoints<public>() : []Map.spawn_point =
        var Points : []Map.spawn_point = array{}
        set Points += array{Map.spawn_point{Name := "SP_Alpha_1", Position := Map.point3{X := 0.0, Y := 0.0, Z := -250.0}, TeamIndex := 1}}
        set Points += array{Map.spawn_point{Name := "SP_Alpha_2", Position := Map.point3{X := 0.0, Y := 0.0, Z := 250.0}, TeamIndex := 1}}
        set Points += array{Map.spawn_point{Name := "SP_Alpha_3", Position := Map.point3{X := 255.9, Y := 0.0, Z := 4.0}, TeamIndex := 1}}
        set Points += array{Map.spawn_point{Name := "SP_Bravo_1", Position := Map.point3{X := 130.0, Y := 0.0, Z := 2375.0}, TeamIndex := 2}}
        set Points += array{Map.spawn_point{Name := "SP_Bravo_2", Position := Map.point3{X := 400.0, Y := 0.0, Z := 2585.0}, TeamIndex := 2}}
        set Points += array{Map.spawn_point{Name := "SP_Bravo_3", Position := Map.point3{X := 430.0, Y := 0.0, Z := 2235.0}, TeamIndex := 2}}
        return Points

    HasSpawnEvent<public>(EventName : string) : logic =
        for (Logged : SpawnEventLog):
            if ((Logged = EventName)):
                return true
        return false

    GetNearestEnemyDistance(Origin : Map.point3, EnemyPositions : []Map.point3) : float =
        var BestDistance : float = -1.0
        for (EnemyPos : EnemyPositions):
            Candidate := DistanceSquared(Origin, EnemyPos)
            if (BestDistance < 0.0):
                set BestDistance = Candidate
            else:
                if (Candidate < BestDistance):
                    set BestDistance = Candidate
        if (BestDistance < 0.0):
            return 0.0
        return BestDistance

    DistanceSquared(A : Map.point3, B : Map.point3) : float =
        Dx := A.X - B.X
        Dy := A.Y - B.Y
        Dz := A.Z - B.Z
        return Dx * Dx + Dy * Dy + Dz * Dz

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B
