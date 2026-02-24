using { /Verse.org/Simulation }

knockback_applicator<public> := class:
    var LastKnockbackForceByPlayer : [agent]float = map{}
    var LastEasedKnockbackForceByPlayer : [agent]float = map{}
    var LastEaseSecondsByPlayer : [agent]float = map{}
    var DefaultEaseWindowSeconds : float = 0.35
    var KnockbackEventLog : []string = array{}

    ApplyKnockback<public>(Source : agent, Target : agent, Force : float) : void =
        SafeForce := MaxFloat(Force, 0.0)
        if (set LastKnockbackForceByPlayer[Target] = SafeForce) {}
        if (set LastEasedKnockbackForceByPlayer[Target] = SafeForce) {}
        if (set LastEaseSecondsByPlayer[Target] = 0.0) {}
        set KnockbackEventLog += array{"ApplyKnockback"}

    ApplyKnockbackEased<public>(Source : agent, Target : agent, Force : float, EaseSeconds : float, MaxForce : float) : void =
        SafeForce := MaxFloat(Force, 0.0)
        SafeMax := MaxFloat(MaxForce, 0.0)
        SafeEase := MaxFloat(EaseSeconds, 0.0)
        ClampedForce := MinFloat(SafeForce, SafeMax)
        EaseFactor := ClampFloat(SafeEase / DefaultEaseWindowSeconds, 0.0, 1.0)
        EasedForce := ClampedForce * EaseFactor
        if (set LastKnockbackForceByPlayer[Target] = ClampedForce) {}
        if (set LastEasedKnockbackForceByPlayer[Target] = EasedForce) {}
        if (set LastEaseSecondsByPlayer[Target] = SafeEase) {}
        set KnockbackEventLog += array{"ApplyKnockbackEased"}

    GetLastAppliedForce<public>(Target : agent) : float =
        if (Value := LastKnockbackForceByPlayer[Target]):
            return Value
        return 0.0

    GetLastEasedAppliedForce<public>(Target : agent) : float =
        if (Value := LastEasedKnockbackForceByPlayer[Target]):
            return Value
        return 0.0

    GetLastEaseSeconds<public>(Target : agent) : float =
        if (Value := LastEaseSecondsByPlayer[Target]):
            return Value
        return 0.0

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

    MinFloat(A : float, B : float) : float =
        if ((A < B)):
            return A
        return B

    ClampFloat(Value : float, MinValue : float, MaxValue : float) : float =
        if ((Value < MinValue)):
            return MinValue
        if ((Value > MaxValue)):
            return MaxValue
        return Value

