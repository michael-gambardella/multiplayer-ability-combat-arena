using { /Verse.org/Simulation }

hazard_manager<public> := class:
    var MaxFairKnockbackForce : float = 900.0
    var TelegraphWindowSeconds : float = 1.0
    var HazardEventLog : []string = array{}

    IsKnockbackFair<public>(Force : float, IsTelegraphed : logic) : logic =
        SafeForce := MaxFloat(Force, 0.0)
        if (IsTelegraphed = false):
            set HazardEventLog += array{"KnockbackUntelegraphed"}
            return false

        if (SafeForce <= MaxFairKnockbackForce):
            set HazardEventLog += array{"KnockbackFair"}
            return true

        set HazardEventLog += array{"KnockbackTooStrong"}
        return false

    RegisterTelegraph<public>(DurationSeconds : float) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        set TelegraphWindowSeconds = SafeDuration
        set HazardEventLog += array{"HazardTelegraphStart"}

    EvaluateTelegraphWindow<public>(ElapsedSeconds : float) : logic =
        SafeElapsed := MaxFloat(ElapsedSeconds, 0.0)
        if (SafeElapsed <= TelegraphWindowSeconds):
            set HazardEventLog += array{"HazardTelegraphValid"}
            return true
        set HazardEventLog += array{"HazardTelegraphExpired"}
        return false

    HasHazardEvent<public>(EventName : string) : logic =
        for (Logged : HazardEventLog):
            if ((Logged = EventName)):
                return true
        return false

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B
