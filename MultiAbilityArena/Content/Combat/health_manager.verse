using { /Verse.org/Simulation }

damage_type<public> := enum:
    Physical
    Ability
    Ultimate
    Environmental

health_record<public> := struct:
    MaxHP<public> : float
    CurrentHP<public> : float
    IsAlive<public> : logic

health_manager<public> := class:
    var HealthByPlayer : [agent]health_record = map{}
    var LastDamageTypeByPlayer : [agent]damage_type = map{}
    var LastHealthEventLog : []string = array{}

    RegisterPlayer<public>(Player : agent, MaxHP : float) : void =
        if (set HealthByPlayer[Player] = health_record{MaxHP := MaxHP, CurrentHP := MaxHP, IsAlive := true}) {}
        if (set LastDamageTypeByPlayer[Player] = damage_type.Physical) {}
        set LastHealthEventLog += array{"RegisterPlayer"}

    GetCurrentHP<public>(Player : agent) : float =
        if (Health := HealthByPlayer[Player]):
            return Health.CurrentHP
        return 0.0

    GetMaxHP<public>(Player : agent) : float =
        if (Health := HealthByPlayer[Player]):
            return Health.MaxHP
        return 0.0

    IsAlive<public>(Player : agent) : logic =
        if (Health := HealthByPlayer[Player]):
            return Health.IsAlive
        return false

    ApplyDamage<public>(Player : agent, Amount : float, Type : damage_type) : float =
        if (Health := HealthByPlayer[Player]):
            ClampedDamage := ClampFloat(Amount, 0.0, Health.CurrentHP)
            NewHP := Health.CurrentHP - ClampedDamage
            var NewAlive : logic = false
            if ((NewHP > 0.0)):
                set NewAlive = true
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := NewHP, IsAlive := NewAlive}) {}
            if (set LastDamageTypeByPlayer[Player] = Type) {}
            set LastHealthEventLog += array{"ApplyDamage"}
            return ClampedDamage
        return 0.0

    ApplyHealing<public>(Player : agent, Amount : float) : float =
        if (Health := HealthByPlayer[Player]):
            if (Health.IsAlive = false):
                return 0.0
            TargetHP := Health.CurrentHP + Amount
            NewHP := ClampFloat(TargetHP, 0.0, Health.MaxHP)
            AppliedHealing := NewHP - Health.CurrentHP
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := NewHP, IsAlive := true}) {}
            set LastHealthEventLog += array{"ApplyHealing"}
            return AppliedHealing
        return 0.0

    SetAliveState<public>(Player : agent, Alive : logic) : void =
        if (Health := HealthByPlayer[Player]):
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := Health.CurrentHP, IsAlive := Alive}) {}

    ResetToFullHealth<public>(Player : agent) : void =
        if (Health := HealthByPlayer[Player]):
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := Health.MaxHP, IsAlive := true}) {}
            set LastHealthEventLog += array{"ResetToFullHealth"}

    ClampFloat(Value : float, MinValue : float, MaxValue : float) : float =
        if ((Value < MinValue)):
            return MinValue
        if ((Value > MaxValue)):
            return MaxValue
        return Value

