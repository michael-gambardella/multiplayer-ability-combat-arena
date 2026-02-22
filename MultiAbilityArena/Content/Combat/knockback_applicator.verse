using { /Verse.org/Simulation }

knockback_applicator<public> := class:
    var LastKnockbackForceByPlayer : [agent]float = map{}
    var KnockbackEventLog : []string = array{}

    ApplyKnockback<public>(Source : agent, Target : agent, Force : float) : void =
        SafeForce := MaxFloat(Force, 0.0)
        if (set LastKnockbackForceByPlayer[Target] = SafeForce) {}
        set KnockbackEventLog += array{"ApplyKnockback"}

    GetLastAppliedForce<public>(Target : agent) : float =
        if (Value := LastKnockbackForceByPlayer[Target]):
            return Value
        return 0.0

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

