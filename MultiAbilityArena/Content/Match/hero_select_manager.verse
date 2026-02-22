using { /Verse.org/Simulation }

hero_select_manager<public> := class:
    var HeroSelectDurationSeconds : float = 30.0
    var RemainingTime : float = 30.0
    var IsHeroSelectActive : logic = false
    var IsHeroSelectLocked : logic = false
    var DefaultHeroId : string = "Titan"
    var EligiblePlayers : []agent = array{}
    var SelectedPlayerList : []agent = array{}
    var SelectedHeroes : [agent]string = map{}

    BeginHeroSelect<public>() : void =
        set IsHeroSelectActive = true
        set IsHeroSelectLocked = false
        set RemainingTime = HeroSelectDurationSeconds

    RegisterEligiblePlayer<public>(Player : agent) : void =
        AlreadyEligible := ContainsPlayer(EligiblePlayers, Player)
        if (AlreadyEligible = false):
            set EligiblePlayers += array{Player}

    RemoveEligiblePlayer<public>(Player : agent) : void =
        set EligiblePlayers = FilterOutPlayer(EligiblePlayers, Player)
        set SelectedPlayerList = FilterOutPlayer(SelectedPlayerList, Player)

    Tick<public>(DeltaTime : float) : logic =
        if (IsHeroSelectActive = false):
            return false

        set RemainingTime = RemainingTime - DeltaTime
        if ((RemainingTime <= 0.0)):
            FinalizeHeroSelect()
            return true
        return false

    SelectHero<public>(Player : agent, HeroId : string) : void =
        if ((IsHeroSelectActive = true)):
            if ((IsHeroSelectLocked = false)):
                if (set SelectedHeroes[Player] = HeroId) {}
                AlreadySelected := ContainsPlayer(SelectedPlayerList, Player)
                if (AlreadySelected = false):
                    set SelectedPlayerList += array{Player}

    ForceAssignDefaultHero<public>(Player : agent) : void =
        if (set SelectedHeroes[Player] = DefaultHeroId) {}

    FinalizeHeroSelect<public>() : void =
        for (Player : EligiblePlayers):
            HasSelection := ContainsPlayer(SelectedPlayerList, Player)
            if (HasSelection = false):
                ForceAssignDefaultHero(Player)

        set IsHeroSelectActive = false
        set IsHeroSelectLocked = true

    GetRemainingTime<public>() : float =
        return RemainingTime

    ContainsPlayer<public>(PlayerList : []agent, Player : agent) : logic =
        for (Existing : PlayerList):
            if ((Existing = Player)):
                return true
        return false

    FilterOutPlayer<public>(PlayerList : []agent, Player : agent) : []agent =
        var Filtered : []agent = array{}
        for (Existing : PlayerList):
            if ((Existing <> Player)):
                set Filtered += array{Existing}
        return Filtered

