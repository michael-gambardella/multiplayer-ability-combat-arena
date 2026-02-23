using { /Verse.org/Simulation }

status_effect_manager<public> := class:
    var SlowRemainingByPlayer : [agent]float = map{}
    var SlowMagnitudeByPlayer : [agent]float = map{}
    var SlowSourceKeyByPlayer : [agent]int = map{}
    var StunRemainingByPlayer : [agent]float = map{}
    var StunSourceKeyByPlayer : [agent]int = map{}
    var InvisibilityRemainingByPlayer : [agent]float = map{}
    var InvisibilitySourceKeyByPlayer : [agent]int = map{}
    var MarkRemainingByPlayer : [agent]float = map{}
    var MarkAmplifyByPlayer : [agent]float = map{}
    var MarkSourceKeyByPlayer : [agent]int = map{}
    var SourceKeyByAgent : [agent]int = map{}
    var NextSourceKey : int = 1
    var StatusEventLog : []string = array{}

    ApplySlow<public>(Target : agent, DurationSeconds : float, Magnitude : float, Source : agent) : void =
        SourceKey := GetOrCreateSourceKey(Source)
        ApplySlowFromSourceKey(Target, DurationSeconds, Magnitude, SourceKey)

    ApplySlowFromSourceKey<public>(Target : agent, DurationSeconds : float, Magnitude : float, SourceKey : int) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        SafeMagnitude := ClampFloat(Magnitude, 0.0, 1.0)
        ExistingRemaining := GetSlowRemaining(Target)
        ExistingMagnitude := GetSlowMagnitude(Target)
        ExistingSource := GetSlowSourceKey(Target)

        if (ExistingRemaining <= 0.0):
            SetSlow(Target, SafeDuration, SafeMagnitude, SourceKey)
            set StatusEventLog += array{"ApplySlow"}
            return

        if (ExistingSource = SourceKey):
            SetSlow(Target, SafeDuration, SafeMagnitude, SourceKey)
            set StatusEventLog += array{"ApplySlowRefreshSameSource"}
            return

        if (SafeMagnitude > ExistingMagnitude):
            SetSlow(Target, SafeDuration, SafeMagnitude, SourceKey)
            set StatusEventLog += array{"ApplySlowReplaceStrongerSource"}
            return

        ExtendedDuration := MaxFloat(ExistingRemaining, SafeDuration)
        SetSlow(Target, ExtendedDuration, ExistingMagnitude, ExistingSource)
        set StatusEventLog += array{"ApplySlowKeepStrongest"}

    SetSlow(Target : agent, DurationSeconds : float, Magnitude : float, SourceKey : int) : void =
        if (set SlowRemainingByPlayer[Target] = DurationSeconds) {}
        if (set SlowMagnitudeByPlayer[Target] = Magnitude) {}
        if (set SlowSourceKeyByPlayer[Target] = SourceKey) {}
        set StatusEventLog += array{"ApplySlow"}

    ApplyStun<public>(Target : agent, DurationSeconds : float, Source : agent) : void =
        SourceKey := GetOrCreateSourceKey(Source)
        ApplyStunFromSourceKey(Target, DurationSeconds, SourceKey)

    ApplyStunFromSourceKey<public>(Target : agent, DurationSeconds : float, SourceKey : int) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        ExistingRemaining := GetStunRemaining(Target)
        ExistingSource := GetStunSourceKey(Target)

        if (ExistingRemaining <= 0.0 or ExistingSource = SourceKey):
            if (set StunRemainingByPlayer[Target] = SafeDuration) {}
            if (set StunSourceKeyByPlayer[Target] = SourceKey) {}
            set StatusEventLog += array{"ApplyStun"}
            return

        ExtendedDuration := MaxFloat(ExistingRemaining, SafeDuration)
        if (set StunRemainingByPlayer[Target] = ExtendedDuration) {}
        set StatusEventLog += array{"ApplyStunCrossSourceExtend"}

    ApplyInvisibility<public>(Target : agent, DurationSeconds : float, Source : agent) : void =
        SourceKey := GetOrCreateSourceKey(Source)
        ApplyInvisibilityFromSourceKey(Target, DurationSeconds, SourceKey)

    ApplyInvisibilityFromSourceKey<public>(Target : agent, DurationSeconds : float, SourceKey : int) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        ExistingSource := GetInvisibilitySourceKey(Target)
        ExistingRemaining := GetInvisibilityRemaining(Target)

        if (ExistingRemaining <= 0.0 or ExistingSource = SourceKey):
            if (set InvisibilityRemainingByPlayer[Target] = SafeDuration) {}
            if (set InvisibilitySourceKeyByPlayer[Target] = SourceKey) {}
            set StatusEventLog += array{"ApplyInvisibility"}
            return

        ExtendedDuration := MaxFloat(ExistingRemaining, SafeDuration)
        if (set InvisibilityRemainingByPlayer[Target] = ExtendedDuration) {}
        set StatusEventLog += array{"ApplyInvisibilityCrossSourceExtend"}

    ApplyDeathMark<public>(Target : agent, DurationSeconds : float, AmplifyMagnitude : float, Source : agent) : void =
        SourceKey := GetOrCreateSourceKey(Source)
        ApplyDeathMarkFromSourceKey(Target, DurationSeconds, AmplifyMagnitude, SourceKey)

    ApplyDeathMarkFromSourceKey<public>(Target : agent, DurationSeconds : float, AmplifyMagnitude : float, SourceKey : int) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        SafeAmplify := ClampFloat(AmplifyMagnitude, 0.0, 1.0)
        ExistingRemaining := GetMarkRemaining(Target)
        ExistingAmplify := GetMarkAmplify(Target)
        ExistingSource := GetMarkSourceKey(Target)

        if (ExistingRemaining <= 0.0):
            SetMark(Target, SafeDuration, SafeAmplify, SourceKey)
            set StatusEventLog += array{"ApplyDeathMark"}
            return

        if (ExistingSource = SourceKey):
            SetMark(Target, SafeDuration, SafeAmplify, SourceKey)
            set StatusEventLog += array{"ApplyDeathMarkRefreshSameSource"}
            return

        if (SafeAmplify > ExistingAmplify):
            SetMark(Target, SafeDuration, SafeAmplify, SourceKey)
            set StatusEventLog += array{"ApplyDeathMarkReplaceStrongerSource"}
            return

        ExtendedDuration := MaxFloat(ExistingRemaining, SafeDuration)
        SetMark(Target, ExtendedDuration, ExistingAmplify, ExistingSource)
        set StatusEventLog += array{"ApplyDeathMarkKeepStrongest"}

    SetMark(Target : agent, DurationSeconds : float, Amplify : float, SourceKey : int) : void =
        if (set MarkRemainingByPlayer[Target] = DurationSeconds) {}
        if (set MarkAmplifyByPlayer[Target] = Amplify) {}
        if (set MarkSourceKeyByPlayer[Target] = SourceKey) {}
        set StatusEventLog += array{"ApplyDeathMark"}

    PurgeNegativeEffects<public>(Target : agent) : void =
        if (set SlowRemainingByPlayer[Target] = 0.0) {}
        if (set SlowMagnitudeByPlayer[Target] = 0.0) {}
        if (set StunRemainingByPlayer[Target] = 0.0) {}
        if (set MarkRemainingByPlayer[Target] = 0.0) {}
        if (set MarkAmplifyByPlayer[Target] = 0.0) {}
        set StatusEventLog += array{"PurgeNegativeEffects"}

    Tick<public>(DeltaTime : float) : void =
        for (Player -> RemainingSlow : SlowRemainingByPlayer):
            NewSlow := RemainingSlow - DeltaTime
            if ((NewSlow <= 0.0)):
                if (set SlowRemainingByPlayer[Player] = 0.0) {}
                if (set SlowMagnitudeByPlayer[Player] = 0.0) {}
            else:
                if (set SlowRemainingByPlayer[Player] = NewSlow) {}

        for (Player -> RemainingStun : StunRemainingByPlayer):
            NewStun := RemainingStun - DeltaTime
            if ((NewStun <= 0.0)):
                if (set StunRemainingByPlayer[Player] = 0.0) {}
            else:
                if (set StunRemainingByPlayer[Player] = NewStun) {}

        for (Player -> RemainingInvisibility : InvisibilityRemainingByPlayer):
            NewInvisibility := RemainingInvisibility - DeltaTime
            if ((NewInvisibility <= 0.0)):
                if (set InvisibilityRemainingByPlayer[Player] = 0.0) {}
            else:
                if (set InvisibilityRemainingByPlayer[Player] = NewInvisibility) {}

        for (Player -> RemainingMark : MarkRemainingByPlayer):
            NewMark := RemainingMark - DeltaTime
            if ((NewMark <= 0.0)):
                if (set MarkRemainingByPlayer[Player] = 0.0) {}
                if (set MarkAmplifyByPlayer[Player] = 0.0) {}
            else:
                if (set MarkRemainingByPlayer[Player] = NewMark) {}

    IsStunned<public>(Player : agent) : logic =
        if (Remaining := StunRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return true
        return false

    IsInvisible<public>(Player : agent) : logic =
        if (Remaining := InvisibilityRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return true
        return false

    IsMarked<public>(Player : agent) : logic =
        if (Remaining := MarkRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return true
        return false

    GetSlowMagnitude<public>(Player : agent) : float =
        if (Remaining := SlowRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                if (Magnitude := SlowMagnitudeByPlayer[Player]):
                    return Magnitude
        return 0.0

    GetSlowRemaining<public>(Player : agent) : float =
        if (Remaining := SlowRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return Remaining
        return 0.0

    GetStunRemaining<public>(Player : agent) : float =
        if (Remaining := StunRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return Remaining
        return 0.0

    GetInvisibilityRemaining<public>(Player : agent) : float =
        if (Remaining := InvisibilityRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return Remaining
        return 0.0

    GetMarkRemaining<public>(Player : agent) : float =
        if (Remaining := MarkRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                return Remaining
        return 0.0

    GetMarkAmplify<public>(Player : agent) : float =
        if (Remaining := MarkRemainingByPlayer[Player]):
            if ((Remaining > 0.0)):
                if (Amplify := MarkAmplifyByPlayer[Player]):
                    return Amplify
        return 0.0

    GetDamageAmplifierFromMark<public>(Player : agent) : float =
        MarkAmplify := GetMarkAmplify(Player)
        return 1.0 + MarkAmplify

    GetSlowSourceKey(Player : agent) : int =
        if (Value := SlowSourceKeyByPlayer[Player]):
            return Value
        return 0

    GetStunSourceKey(Player : agent) : int =
        if (Value := StunSourceKeyByPlayer[Player]):
            return Value
        return 0

    GetInvisibilitySourceKey(Player : agent) : int =
        if (Value := InvisibilitySourceKeyByPlayer[Player]):
            return Value
        return 0

    GetMarkSourceKey(Player : agent) : int =
        if (Value := MarkSourceKeyByPlayer[Player]):
            return Value
        return 0

    GetOrCreateSourceKey(Source : agent) : int =
        if (Existing := SourceKeyByAgent[Source]):
            return Existing

        NewKey := NextSourceKey
        if (set SourceKeyByAgent[Source] = NewKey) {}
        set NextSourceKey = NextSourceKey + 1
        return NewKey

    ClampFloat(Value : float, MinValue : float, MaxValue : float) : float =
        if ((Value < MinValue)):
            return MinValue
        if ((Value > MaxValue)):
            return MaxValue
        return Value

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

