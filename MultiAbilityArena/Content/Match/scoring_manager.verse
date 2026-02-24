using { /Verse.org/Simulation }

scoring_manager<public> := class:
    var ScoreByPlayer : [agent]int = map{}
    var AssistByPlayer : [agent]int = map{}
    var LastDamageTimeByTarget : [agent]float = map{}
    var LastDamageSourceByTarget : [agent]agent = map{}
    var AssistWindowSeconds : float = Core.AssistWindow
    var MatchDurationSeconds : float = Core.MatchDuration
    var ScoreLimit : int = Core.ScoreLimit
    var MatchTimerSeconds : float = 0.0
    var SuddenDeathActive : logic = false
    var MatchEnded : logic = false
    var ScoreEventLog : []string = array{}

    ConfigureMatch<public>(NewScoreLimit : int, NewMatchDuration : float, NewAssistWindow : float) : void =
        set ScoreLimit = MaxInt(NewScoreLimit, 1)
        set MatchDurationSeconds = MaxFloat(NewMatchDuration, 0.0)
        set AssistWindowSeconds = MaxFloat(NewAssistWindow, 0.0)
        set ScoreEventLog += array{"ConfigureMatch"}

    RegisterDamage<public>(Source : agent, Target : agent, TimeSeconds : float) : void =
        SafeTime := MaxFloat(TimeSeconds, 0.0)
        if (set LastDamageTimeByTarget[Target] = SafeTime) {}
        if (set LastDamageSourceByTarget[Target] = Source) {}
        set ScoreEventLog += array{"RegisterDamage"}

    RegisterElimination<public>(Source : agent, Target : agent, TimeSeconds : float) : void =
        AddScore(Source, 1)
        var AssistCandidatePresent : logic = false
        var AssistCandidate : agent = Source
        if (Candidate := LastDamageSourceByTarget[Target]):
            set AssistCandidate = Candidate
            set AssistCandidatePresent = true

        var AssistTimePresent : logic = false
        var AssistTime : float = 0.0
        if (Value := LastDamageTimeByTarget[Target]):
            set AssistTime = Value
            set AssistTimePresent = true

        if (AssistCandidatePresent = true and AssistTimePresent = true):
            if (AssistCandidate <> Source):
                Delta := MaxFloat(TimeSeconds - AssistTime, 0.0)
                if (Delta <= AssistWindowSeconds):
                    AddAssist(AssistCandidate, 1)

        set ScoreEventLog += array{"RegisterElimination"}
        CheckScoreLimit(Source)

    AddScore<public>(Player : agent, Amount : int) : void =
        SafeAmount := MaxInt(Amount, 0)
        Current := GetScore(Player)
        if (set ScoreByPlayer[Player] = Current + SafeAmount) {}
        set ScoreEventLog += array{"AddScore"}

    AddAssist<public>(Player : agent, Amount : int) : void =
        SafeAmount := MaxInt(Amount, 0)
        Current := GetAssistCount(Player)
        if (set AssistByPlayer[Player] = Current + SafeAmount) {}
        set ScoreEventLog += array{"AddAssist"}

    Tick<public>(DeltaTime : float) : void =
        if (MatchEnded = true):
            return
        set MatchTimerSeconds = MatchTimerSeconds + MaxFloat(DeltaTime, 0.0)
        if (MatchTimerSeconds >= MatchDurationSeconds and SuddenDeathActive = false):
            TieForTop := IsTieForTop()
            if (TieForTop = true):
                set SuddenDeathActive = true
                set ScoreEventLog += array{"SuddenDeathStart"}
                return
            set MatchEnded = true
            set ScoreEventLog += array{"MatchEndedTime"}

    EvaluateSuddenDeathForTest<public>(TieForTop : logic) : void =
        if (TieForTop = true):
            set SuddenDeathActive = true
            set ScoreEventLog += array{"SuddenDeathStart"}
        else:
            set SuddenDeathActive = false
            set ScoreEventLog += array{"SuddenDeathCleared"}

    GetScore<public>(Player : agent) : int =
        if (Value := ScoreByPlayer[Player]):
            return Value
        return 0

    GetAssistCount<public>(Player : agent) : int =
        if (Value := AssistByPlayer[Player]):
            return Value
        return 0

    GetMatchTimeSeconds<public>() : float =
        return MatchTimerSeconds

    GetMatchDurationSeconds<public>() : float =
        return MatchDurationSeconds

    IsSuddenDeathActive<public>() : logic =
        return SuddenDeathActive

    HasScoreEvent<public>(EventName : string) : logic =
        for (Logged : ScoreEventLog):
            if ((Logged = EventName)):
                return true
        return false

    CheckScoreLimit(Player : agent) : void =
        Score := GetScore(Player)
        if (Score >= ScoreLimit):
            set MatchEnded = true
            set ScoreEventLog += array{"MatchEndedScore"}

    IsMatchEnded<public>() : logic =
        return MatchEnded

    IsTieForTop() : logic =
        var TopScore : int = -1
        var TopCount : int = 0
        for (Player -> Score : ScoreByPlayer):
            if (Score > TopScore):
                set TopScore = Score
                set TopCount = 1
            else:
                if (Score = TopScore):
                    set TopCount = TopCount + 1
        if (TopCount > 1):
            return true
        return false

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

    MaxInt(A : int, B : int) : int =
        if ((A > B)):
            return A
        return B
