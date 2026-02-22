using { /Verse.org/Simulation }

damage_pipeline<public> := class:
    var InvulnerablePlayers : [agent]logic = map{}
    var DamageModifierByPlayer : [agent]float = map{}
    var DamageEventLog : []string = array{}

    SetInvulnerable<public>(Player : agent, Enabled : logic) : void =
        if (set InvulnerablePlayers[Player] = Enabled) {}
        set DamageEventLog += array{"SetInvulnerable"}

    SetDamageModifier<public>(Player : agent, Multiplier : float) : void =
        SafeMultiplier := MaxFloat(Multiplier, 0.0)
        if (set DamageModifierByPlayer[Player] = SafeMultiplier) {}
        set DamageEventLog += array{"SetDamageModifier"}

    ProcessDamage<public>(
        Source : agent,
        Target : agent,
        IncomingAmount : float,
        Type : damage_type,
        HealthManager : Combat.health_manager
    ) : float =
        TargetInvulnerable := IsInvulnerable(Target)
        if (TargetInvulnerable = true):
            set DamageEventLog += array{"BlockedByInvulnerability"}
            return 0.0

        BaseAmount := MaxFloat(IncomingAmount, 0.0)
        ModifiedAmount := BaseAmount * GetDamageModifier(Target)
        Applied := HealthManager.ApplyDamage(Target, ModifiedAmount, Type)

        set DamageEventLog += array{"ProcessDamage"}
        return Applied

    ProcessHealing<public>(Source : agent, Target : agent, IncomingAmount : float, HealthManager : Combat.health_manager) : float =
        BaseAmount := MaxFloat(IncomingAmount, 0.0)
        Applied := HealthManager.ApplyHealing(Target, BaseAmount)
        set DamageEventLog += array{"ProcessHealing"}
        return Applied

    IsInvulnerable<public>(Player : agent) : logic =
        if (Value := InvulnerablePlayers[Player]):
            return Value
        return false

    GetDamageModifier<public>(Player : agent) : float =
        if (Value := DamageModifierByPlayer[Player]):
            return Value
        return 1.0

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

