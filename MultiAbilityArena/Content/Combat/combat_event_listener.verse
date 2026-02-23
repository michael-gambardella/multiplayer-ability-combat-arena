using { /Verse.org/Simulation }

combat_event_listener<public> := interface:
    OnDamageProcessed<public>(Source : agent, Target : agent, Amount : float, Type : damage_type) : void
    OnDamageBlockedByInvulnerability<public>(Source : agent, Target : agent, Type : damage_type) : void
    OnHealingProcessed<public>(Source : agent, Target : agent, Amount : float) : void
    OnElimination<public>(Source : agent, Target : agent) : void
    OnRespawnStarted<public>(Target : agent) : void
    OnRespawnFinalized<public>(Target : agent) : void
    OnRespawnInvulnerabilityExpired<public>(Target : agent) : void
