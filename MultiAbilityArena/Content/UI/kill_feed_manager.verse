using { /Verse.org/Simulation }

kill_feed_manager<public> := class:
    var FeedEventLog : []string = array{}

    AddElimination<public>(Source : agent, Target : agent) : void =
        set FeedEventLog += array{"KillFeedElimination"}

    AddAssist<public>(Assistant : agent, Target : agent) : void =
        set FeedEventLog += array{"KillFeedAssist"}

    AddHit<public>(Source : agent, Target : agent) : void =
        set FeedEventLog += array{"KillFeedHit"}

    HasKillFeedEvent<public>(EventName : string) : logic =
        for (Logged : FeedEventLog):
            if ((Logged = EventName)):
                return true
        return false
