using { /Verse.org/Simulation }
# Sprint 4 integration scaffold: knockback application for charge-based abilities.

knockback_applicator := class:
    var LastKnockbackForceByPlayer : [agent]float = map{}
    var KnockbackEventLog : []string = array{}

    ApplyKnockback(Source : agent, Target : agent, Force : float) : void =
        SafeForce := MaxFloat(Force, 0.0)
        if (set LastKnockbackForceByPlayer[Target] = SafeForce) {}
        set KnockbackEventLog += array{"ApplyKnockback: {Source}->{Target} Force={SafeForce}"}

    GetLastAppliedForce(Target : agent) : float =
        if (Value := LastKnockbackForceByPlayer[Target]):
            return Value
        return 0.0

    MaxFloat(A : float, B : float) : float =
        if (A > B):
            return A
        return B

