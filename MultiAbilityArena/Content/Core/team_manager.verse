using { /Verse.org/Simulation }

team_id<public> := enum:
    Alpha
    Bravo

team_manager<public> := class:
    var AlphaRoster : []agent = array{}
    var BravoRoster : []agent = array{}

    AssignToSmallerTeam<public>(Player : agent) : team_id =
        if ((AlphaRoster.Length <= BravoRoster.Length)):
            set AlphaRoster += array{Player}
            return team_id.Alpha
        set BravoRoster += array{Player}
        return team_id.Bravo

    Remove<public>(Player : agent) : void =
        var NewAlpha : []agent = array{}
        for (RosterPlayer : AlphaRoster):
            if ((RosterPlayer <> Player)):
                set NewAlpha += array{RosterPlayer}

        var NewBravo : []agent = array{}
        for (RosterPlayer : BravoRoster):
            if ((RosterPlayer <> Player)):
                set NewBravo += array{RosterPlayer}

        set AlphaRoster = NewAlpha
        set BravoRoster = NewBravo

    GetTeamSize<public>(Team : team_id) : int =
        if ((Team = team_id.Alpha)):
            return AlphaRoster.Length
        return BravoRoster.Length

    GetTotalPlayers<public>() : int =
        return AlphaRoster.Length + BravoRoster.Length

