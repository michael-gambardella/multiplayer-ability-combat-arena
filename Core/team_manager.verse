# Sprint 2 core: team roster assignment and cleanup logic.

team_id := enum:
    Alpha
    Bravo

team_manager := class:
    var AlphaRoster : []agent = array{}
    var BravoRoster : []agent = array{}

    AssignToSmallerTeam(Player : agent) : team_id =
        if (AlphaRoster.Length <= BravoRoster.Length):
            set AlphaRoster += array{Player}
            return team_id.Alpha
        set BravoRoster += array{Player}
        return team_id.Bravo

    Remove(Player : agent) : void =
        var NewAlpha : []agent = array{}
        for (RosterPlayer : AlphaRoster):
            if (RosterPlayer <> Player):
                set NewAlpha += array{RosterPlayer}

        var NewBravo : []agent = array{}
        for (RosterPlayer : BravoRoster):
            if (RosterPlayer <> Player):
                set NewBravo += array{RosterPlayer}

        set AlphaRoster = NewAlpha
        set BravoRoster = NewBravo

    GetTeamSize(Team : team_id) : int =
        if (Team = team_id.Alpha):
            return AlphaRoster.Length
        return BravoRoster.Length

    GetTotalPlayers() : int =
        return AlphaRoster.Length + BravoRoster.Length
