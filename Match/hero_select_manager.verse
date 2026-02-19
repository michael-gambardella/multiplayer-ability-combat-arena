# Sprint 2 core: hero selection phase manager (timer + default fallback scaffold).

hero_select_manager := class:
    var HeroSelectDurationSeconds : float = 30.0
    var RemainingTime : float = 30.0
    var IsHeroSelectActive : logic = false
    var IsHeroSelectLocked : logic = false
    var DefaultHeroId : string = "Titan"
    var EligiblePlayers : []agent = array{}
    var SelectedPlayerList : []agent = array{}

    # agent -> hero id string
    var SelectedHeroes : [agent]string = map{}

    BeginHeroSelect() : void =
        set IsHeroSelectActive = true
        set IsHeroSelectLocked = false
        set RemainingTime = HeroSelectDurationSeconds

    RegisterEligiblePlayer(Player : agent) : void =
        if (not ContainsPlayer(EligiblePlayers, Player)):
            set EligiblePlayers += array{Player}

    RemoveEligiblePlayer(Player : agent) : void =
        set EligiblePlayers = FilterOutPlayer(EligiblePlayers, Player)
        set SelectedPlayerList = FilterOutPlayer(SelectedPlayerList, Player)

    Tick(DeltaTime : float) : logic =
        if (not IsHeroSelectActive):
            return false

        set RemainingTime = RemainingTime - DeltaTime
        if (RemainingTime <= 0.0):
            FinalizeHeroSelect()
            return true
        return false

    SelectHero(Player : agent, HeroId : string) : void =
        if (IsHeroSelectActive and not IsHeroSelectLocked):
            if (set SelectedHeroes[Player] = HeroId) {}
            if (not ContainsPlayer(SelectedPlayerList, Player)):
                set SelectedPlayerList += array{Player}

    ForceAssignDefaultHero(Player : agent) : void =
        if (set SelectedHeroes[Player] = DefaultHeroId) {}

    FinalizeHeroSelect() : void =
        # Ensure every eligible player has a hero assignment.
        for (Player : EligiblePlayers):
            if (not ContainsPlayer(SelectedPlayerList, Player)):
                ForceAssignDefaultHero(Player)

        set IsHeroSelectActive = false
        set IsHeroSelectLocked = true
        # TODO: emit finalized event for spawn systems.

    GetRemainingTime() : float =
        return RemainingTime

    ContainsPlayer(PlayerList : []agent, Player : agent) : logic =
        for (Existing : PlayerList):
            if (Existing = Player):
                return true
        return false

    FilterOutPlayer(PlayerList : []agent, Player : agent) : []agent =
        var Filtered : []agent = array{}
        for (Existing : PlayerList):
            if (Existing <> Player):
                set Filtered += array{Existing}
        return Filtered
