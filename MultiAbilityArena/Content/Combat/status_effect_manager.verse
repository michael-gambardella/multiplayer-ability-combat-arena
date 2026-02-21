using { /Verse.org/Simulation }
# Sprint 4 integration scaffold: status effect tracking for Titan ability interactions.

status_effect_manager := class:
    var SlowRemainingByPlayer : [agent]float = map{}
    var SlowMagnitudeByPlayer : [agent]float = map{}
    var StunRemainingByPlayer : [agent]float = map{}
    var StatusEventLog : []string = array{}

    ApplySlow(Target : agent, DurationSeconds : float, Magnitude : float, Source : agent) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        SafeMagnitude := ClampFloat(Magnitude, 0.0, 1.0)

        if (set SlowRemainingByPlayer[Target] = SafeDuration) {}
        if (set SlowMagnitudeByPlayer[Target] = SafeMagnitude) {}
        set StatusEventLog += array{"ApplySlow: {Source}->{Target} Duration={SafeDuration} Magnitude={SafeMagnitude}"}

    ApplyStun(Target : agent, DurationSeconds : float, Source : agent) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        if (set StunRemainingByPlayer[Target] = SafeDuration) {}
        set StatusEventLog += array{"ApplyStun: {Source}->{Target} Duration={SafeDuration}"}

    Tick(DeltaTime : float) : void =
        for (Player -> RemainingSlow : SlowRemainingByPlayer):
            NewSlow := RemainingSlow - DeltaTime
            if (NewSlow <= 0.0):
                if (set SlowRemainingByPlayer[Player] = 0.0) {}
                if (set SlowMagnitudeByPlayer[Player] = 0.0) {}
            else:
                if (set SlowRemainingByPlayer[Player] = NewSlow) {}

        for (Player -> RemainingStun : StunRemainingByPlayer):
            NewStun := RemainingStun - DeltaTime
            if (NewStun <= 0.0):
                if (set StunRemainingByPlayer[Player] = 0.0) {}
            else:
                if (set StunRemainingByPlayer[Player] = NewStun) {}

    IsStunned(Player : agent) : logic =
        if (Remaining := StunRemainingByPlayer[Player]):
            return Remaining > 0.0
        return false

    GetSlowMagnitude(Player : agent) : float =
        if (Remaining := SlowRemainingByPlayer[Player]):
            if (Remaining > 0.0):
                if (Magnitude := SlowMagnitudeByPlayer[Player]):
                    return Magnitude
        return 0.0

    ClampFloat(Value : float, MinValue : float, MaxValue : float) : float =
        if (Value < MinValue):
            return MinValue
        if (Value > MaxValue):
            return MaxValue
        return Value

    MaxFloat(A : float, B : float) : float =
        if (A > B):
            return A
        return B

