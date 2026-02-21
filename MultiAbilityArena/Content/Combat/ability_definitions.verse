# Sprint 4 ability framework: shared slot and execution result definitions.

ability_slot := enum:
    Primary
    Secondary
    Ultimate

ability_execution_result := struct:
    Succeeded : logic
    CooldownSeconds : float
    CooldownStartDelaySeconds : float
    AbilityLabel : string
