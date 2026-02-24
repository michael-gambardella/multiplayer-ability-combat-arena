using { /Verse.org/Simulation }

hud_controller<public> := class:
    var LastScoreShown : int = 0
    var LastMatchTimeShown : float = 0.0
    var LastCooldownShown : float = 0.0
    var HUDStateLog : []string = array{}

    UpdateHUD<public>(
        Player : agent,
        ScoreManager : Match.scoring_manager,
        CooldownTracker : Combat.cooldown_tracker,
        HealthManager : Combat.health_manager,
        CurrentTimeSeconds : float
    ) : void =
        Score := ScoreManager.GetScore(Player)
        MatchTime := ScoreManager.GetMatchTimeSeconds()
        Cooldown := CooldownTracker.GetRemainingCooldown(Player, Combat.ability_slot.Primary, CurrentTimeSeconds)
        CurrentHP := HealthManager.GetCurrentHP(Player)

        set LastScoreShown = Score
        set LastMatchTimeShown = MatchTime
        set LastCooldownShown = Cooldown
        set HUDStateLog += array{"HUDUpdate"}

        if (CurrentHP >= 0.0):
            set HUDStateLog += array{"StatusIconsUpdate"}
        set HUDStateLog += array{"ScoreboardUpdate"}
        set HUDStateLog += array{"TimerUpdate"}
        set HUDStateLog += array{"AbilityBarUpdate"}

    RunStressUpdate<public>(
        Player : agent,
        Iterations : int,
        ScoreManager : Match.scoring_manager,
        CooldownTracker : Combat.cooldown_tracker,
        HealthManager : Combat.health_manager,
        CurrentTimeSeconds : float
    ) : void =
        SafeIterations := MaxInt(Iterations, 0)
        var Index : int = 0
        loop:
            if (Index >= SafeIterations):
                break
            UpdateHUD(Player, ScoreManager, CooldownTracker, HealthManager, CurrentTimeSeconds)
            set HUDStateLog += array{"HUDStressUpdate"}
            set Index = Index + 1

    HasHudEvent<public>(EventName : string) : logic =
        for (Logged : HUDStateLog):
            if ((Logged = EventName)):
                return true
        return false

    MaxInt(A : int, B : int) : int =
        if ((A > B)):
            return A
        return B
