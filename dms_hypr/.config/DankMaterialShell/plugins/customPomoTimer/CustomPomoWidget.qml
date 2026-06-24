import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property int workDuration: pluginData.workDuration || 25
    property int shortBreakDuration: pluginData.shortBreakDuration || 5
    property int longBreakDuration: pluginData.longBreakDuration || 20
    property bool autoStartBreaks: pluginData.autoStartBreaks ?? false
    property bool autoStartPomodoros: pluginData.autoStartPomodoros ?? false
    property bool autoSetDND: pluginData.autoSetDND ?? false
    property var last7DaysData:[]
    property string currentDateKey: ""
    property string workSoundPath: pluginData.workSoundPath || ""
    property string breakSoundPath: pluginData.breakSoundPath || ""

    // --- New Task Properties ---
    property var taskList:[]
    property string activeTaskId: ""
    
    // Helper to refresh the list view
    function refreshTaskList() {
        var temp = taskList
        taskList =[]
        taskList = temp
    }
    // ---------------------------

    // --- Flexible Mode Properties ---
    property var flexLabels:[]                 // user-defined labels (Math, Physics, ...)
    property var flexSessions:[]               // recorded session history (state file)
    property string flexCurrentLabel: ""       // label of the in-progress session
    property int flexPlannedSeconds: 0         // target duration of current session
    property double flexStartTs: 0             // epoch ms when current session began
    property var flexInsights: ({ byLabel: {}, byPeriod: {} })  // computed aggregates
    property int flexHistoryCap: 500           // max retained session records
    property int flexRecencyHalfLifeDays: 15   // recency weighting half-life
    property int flexMinSamples: 5             // min sessions for a trusted suggestion
    property var flexRecommendation: ({ workMin: 0, breakMin: 0, basis: "default", sampleCount: 0, rationale: "" })

    function refreshFlexSessions() {
        var temp = flexSessions
        flexSessions =[]
        flexSessions = temp
    }
    // --------------------------------

    onPluginServiceChanged: {
        if (pluginService) {
            currentDateKey = formatDateKey(new Date())
            globalCompletedPomodoros.set(pluginService.loadPluginData("customPomoTimer", "completedPomodoros-" + currentDateKey, 0))
            globalWorkedSecondsToday.set(pluginService.loadPluginData("customPomoTimer", "workedSeconds-" + currentDateKey, 0)) // New line
            loadLast7Days()
            if (typeof loadTasks === "function") loadTasks()
            if (typeof loadFlexData === "function") loadFlexData()
        }
    }

    // Re-read labels when plugin settings change (e.g. added/removed in the
    // Settings page). Sessions are NOT reloaded here to avoid clobbering
    // in-progress insight state on every settings write.
    Connections {
        target: pluginService
        enabled: pluginService !== null
        function onPluginDataChanged(changedPluginId) {
            if (changedPluginId === "customPomoTimer" && typeof loadFlexLabels === "function") {
                loadFlexLabels()
            }
        }
    }

    // --- Task Functions ---
    function loadTasks() {
        if (!pluginService) return
        var tasksJson = pluginService.loadPluginData("customPomoTimer", "tasks", "[]")
        try {
            taskList = JSON.parse(tasksJson)
        } catch (e) {
            taskList =[]
        }
    }

    function saveTasks() {
        if (!pluginService) return
        pluginService.savePluginData("customPomoTimer", "tasks", JSON.stringify(taskList))
        refreshTaskList()
    }

    function addTask(name, estimated) {
        if (name.trim() === "") return
        var newTask = {
            id: Math.random().toString(36).substring(2),
            name: name,
            estimated: parseInt(estimated) || 1,
            completed: 0,
            isFinished: false
        }
        taskList.push(newTask)
        // If it's the first task, make it active automatically
        if (taskList.length === 1) {
            activeTaskId = newTask.id
        }
        saveTasks()
    }

    function deleteTask(index) {
        var task = taskList[index]
        if (task.id === activeTaskId) activeTaskId = ""
        taskList.splice(index, 1)
        saveTasks()
    }

    function updateTaskEstimate(index, delta) {
        var newEst = taskList[index].estimated + delta
        if (newEst > 0) { // Prevent the estimate from dropping below 1
            taskList[index].estimated = newEst
            saveTasks()
        }
    }

    function toggleTaskFinished(index) {
        taskList[index].isFinished = !taskList[index].isFinished
        saveTasks()
    }

    function setActiveTask(taskId) {
        activeTaskId = taskId
    }
    // ----------------------

    // --- Flexible Mode Functions ---
    function loadFlexLabels() {
        if (!pluginService) return
        // Labels live in settings so the Settings page and popout stay in sync
        var labelsJson = pluginService.loadPluginData("customPomoTimer", "flexLabels", "")
        if (labelsJson && labelsJson.length > 0) {
            try {
                flexLabels = JSON.parse(labelsJson)
            } catch (e) {
                flexLabels =["Math", "Physics", "Chemistry"]
            }
        } else {
            flexLabels =["Math", "Physics", "Chemistry"]
        }
        // Preserve the active selection if it still exists; otherwise fall back
        // to the first available label.
        if (flexCurrentLabel === "" || flexLabels.indexOf(flexCurrentLabel) === -1) {
            flexCurrentLabel = flexLabels.length > 0 ? flexLabels[0] : ""
        }
    }

    function loadFlexData() {
        if (!pluginService) return
        loadFlexLabels()
        // Session history lives in the dedicated plugin state file
        var sessions = pluginService.loadPluginState("customPomoTimer", "flexSessions", [])
        if (Array.isArray(sessions)) {
            flexSessions = sessions
        } else {
            flexSessions =[]
        }
        computeFlexInsights()
    }

    function saveFlexLabels() {
        if (!pluginService) return
        pluginService.savePluginData("customPomoTimer", "flexLabels", JSON.stringify(flexLabels))
    }

    function addFlexLabel(name) {
        var trimmed = (name || "").trim()
        if (trimmed === "") return
        if (flexLabels.indexOf(trimmed) !== -1) return
        flexLabels.push(trimmed)
        var temp = flexLabels
        flexLabels =[]
        flexLabels = temp
        saveFlexLabels()
    }

    function removeFlexLabel(name) {
        var idx = flexLabels.indexOf(name)
        if (idx === -1) return
        flexLabels.splice(idx, 1)
        var temp = flexLabels
        flexLabels =[]
        flexLabels = temp
        if (flexCurrentLabel === name) {
            flexCurrentLabel = flexLabels.length > 0 ? flexLabels[0] : ""
        }
        saveFlexLabels()
    }

    function periodForHour(hour) {
        if (hour >= 5 && hour < 12) return "Morning"
        if (hour >= 12 && hour < 17) return "Afternoon"
        if (hour >= 17 && hour < 22) return "Evening"
        return "Night"
    }

    // Begin a flexible session. type is "work" or "break".
    function startFlex(label, plannedMinutes, type) {
        var planned = Math.max(1, parseInt(plannedMinutes) || 0) * 60
        globalFlexType.set(type)
        globalFlexPlanned.set(planned)
        flexPlannedSeconds = planned
        globalFlexElapsed.set(0)
        flexCurrentLabel = (type === "work") ? (label || flexCurrentLabel || "") : ""
        flexStartTs = Date.now()
        globalFlexAwaiting.set(false)
        globalTimerOwnerId.set(root.instanceId)
        // Flex takes over the shared timer owner; ensure the classic timer is paused
        globalIsRunning.set(false)
        globalFlexRunning.set(true)
        if (root.autoSetDND && type === "work") {
            SessionData.setDoNotDisturb(true)
        }
    }

    function toggleFlex() {
        if (globalFlexType.value === "idle") return
        if (globalFlexRunning.value) {
            // Pausing: persist progress immediately (without ending the session)
            globalFlexRunning.set(false)
            root.saveWorkedSeconds()
            if (root.autoSetDND && globalFlexType.value === "work") {
                SessionData.setDoNotDisturb(false)
            }
        } else {
            globalTimerOwnerId.set(root.instanceId)
            globalIsRunning.set(false)
            globalFlexRunning.set(true)
            if (root.autoSetDND && globalFlexType.value === "work") {
                SessionData.setDoNotDisturb(true)
            }
        }
    }

    // Finalize the in-progress flex session into history.
    function recordFlexSession() {
        if (globalFlexType.value === "idle") return
        var type = globalFlexType.value
        var planned = flexPlannedSeconds > 0 ? flexPlannedSeconds : globalFlexPlanned.value
        var actual = globalFlexElapsed.value
        if (actual <= 0) return
        var overtime = Math.max(0, actual - planned)
        var now = new Date()
        var startDate = flexStartTs > 0 ? new Date(flexStartTs) : now
        var record = {
            type: type,
            label: type === "work" ? flexCurrentLabel : "",
            planned: planned,
            actual: actual,
            overtime: overtime,
            ranOver: overtime > 0,
            startTs: startDate.getTime(),
            endTs: now.getTime(),
            hour: startDate.getHours(),
            dateKey: formatDateKey(startDate)
        }
        flexSessions.push(record)
        // Bound the history size
        if (flexSessions.length > flexHistoryCap) {
            flexSessions.splice(0, flexSessions.length - flexHistoryCap)
        }
        if (pluginService) {
            pluginService.savePluginState("customPomoTimer", "flexSessions", flexSessions)
        }
        refreshFlexSessions()
        computeFlexInsights()
    }

    // Accept the end-of-session transition: record current, start the opposite type.
    function acceptFlexTransition() {
        var finishedType = globalFlexType.value
        recordFlexSession()
        globalFlexAwaiting.set(false)
        if (finishedType === "work") {
            // Suggest a break using the classic short-break length as default
            startFlex("", root.shortBreakDuration, "break")
        } else {
            startFlex(flexCurrentLabel, Math.round((flexPlannedSeconds || (root.workDuration * 60)) / 60), "work")
        }
    }

    // Decline the transition: keep the current timer running as overtime.
    function declineFlexTransition() {
        globalFlexAwaiting.set(false)
        // Timer keeps counting; nothing else to do.
    }

    // Stop the flex session entirely, recording whatever was done.
    function stopFlex() {
        recordFlexSession()
        globalFlexRunning.set(false)
        globalFlexAwaiting.set(false)
        globalFlexType.set("idle")
        globalFlexElapsed.set(0)
        globalFlexPlanned.set(0)
        flexPlannedSeconds = 0
        flexStartTs = 0
        if (root.autoSetDND) {
            SessionData.setDoNotDisturb(false)
        }
    }

    function fireFlexNotification(type) {
        var title = type === "work" ? "Focus session done" : "Break done"
        var body = type === "work" ? "Take a break? (declining keeps the timer running)" : "Back to work? (declining keeps the break running)"
        var soundPath = type === "work" ? root.workSoundPath : root.breakSoundPath
        var soundCmd = soundPath ? "paplay '" + soundPath + "' & " : ""
        Quickshell.execDetached([
            "sh", "-c",
            soundCmd + "notify-send '" + title + "' '" + body + "' -u normal"
        ])
    }

    // Compute per-label and per-period aggregates from the session history.
    function computeFlexInsights() {
        var byLabel = ({})
        var byPeriod = ({})
        function ensureBucket(map, key) {
            if (!map[key]) {
                map[key] = {
                    workCount: 0, workSeconds: 0, workOvertime: 0,
                    breakCount: 0, breakSeconds: 0
                }
            }
            return map[key]
        }
        for (var i = 0; i < flexSessions.length; i++) {
            var s = flexSessions[i]
            var period = periodForHour(s.hour != null ? s.hour : 12)
            var pb = ensureBucket(byPeriod, period)
            if (s.type === "work") {
                pb.workCount += 1
                pb.workSeconds += s.actual
                pb.workOvertime += (s.overtime || 0)
                var lbl = s.label && s.label.length > 0 ? s.label : "Unlabeled"
                var lb = ensureBucket(byLabel, lbl)
                lb.workCount += 1
                lb.workSeconds += s.actual
                lb.workOvertime += (s.overtime || 0)
            } else {
                pb.breakCount += 1
                pb.breakSeconds += s.actual
            }
        }
        flexInsights = { byLabel: byLabel, byPeriod: byPeriod }
    }

    function avgMinutes(totalSeconds, count) {
        if (!count || count <= 0) return 0
        return Math.round((totalSeconds / count) / 60)
    }

    // --- Recommendation Engine ---
    function flexMedian(values) {
        if (!values || values.length === 0) return 0
        var arr = values.slice().sort(function(a, b) { return a - b })
        var mid = Math.floor(arr.length / 2)
        return arr.length % 2 !== 0 ? arr[mid] : (arr[mid - 1] + arr[mid]) / 2
    }

    // Weighted median: sort by value, walk cumulative weight to the 50% mark.
    function flexWeightedMedian(values, weights) {
        if (!values || values.length === 0) return 0
        if (values.length === 1) return values[0]
        var pairs =[]
        var totalWeight = 0
        for (var i = 0; i < values.length; i++) {
            var w = (weights && weights[i] > 0) ? weights[i] : 0
            pairs.push({ v: values[i], w: w })
            totalWeight += w
        }
        if (totalWeight <= 0) return flexMedian(values)
        pairs.sort(function(a, b) { return a.v - b.v })
        var half = totalWeight / 2
        var cum = 0
        for (var j = 0; j < pairs.length; j++) {
            cum += pairs[j].w
            if (cum >= half) return pairs[j].v
        }
        return pairs[pairs.length - 1].v
    }

    // Exponential recency decay with a configurable half-life (in days).
    function recencyWeight(startTs, nowMs) {
        if (!startTs) return 0.1
        var ageDays = Math.max(0, (nowMs - startTs) / 86400000)
        var w = Math.pow(0.5, ageDays / root.flexRecencyHalfLifeDays)
        return Math.max(w, 0.05)   // floor so old data still counts a little
    }

    function clamp(value, lo, hi) {
        return Math.max(lo, Math.min(hi, value))
    }

    // Weighted-median minutes of "actual" seconds over a set of sessions.
    function flexSuggestMinutes(sessions, nowMs) {
        if (!sessions || sessions.length === 0) return 0
        var values =[]
        var weights =[]
        for (var i = 0; i < sessions.length; i++) {
            values.push(sessions[i].actual)
            weights.push(recencyWeight(sessions[i].startTs, nowMs))
        }
        return Math.round(flexWeightedMedian(values, weights) / 60)
    }

    // Resolve a recommendation for the given label + hour using a tiered
    // fallback cascade. Each tier needs at least flexMinSamples work sessions.
    function recommendFlex(label, hour) {
        var nowMs = Date.now()
        var period = periodForHour(hour)
        var workSessions =[]
        var breakSessions =[]
        for (var i = 0; i < flexSessions.length; i++) {
            var s = flexSessions[i]
            if (s.type === "work") workSessions.push(s)
            else breakSessions.push(s)
        }

        function filterWork(byLabel, byPeriod) {
            var out =[]
            for (var k = 0; k < workSessions.length; k++) {
                var ws = workSessions[k]
                var lbl = ws.label && ws.label.length > 0 ? ws.label : "Unlabeled"
                if (byLabel && lbl !== label) continue
                if (byPeriod && periodForHour(ws.hour != null ? ws.hour : 12) !== period) continue
                out.push(ws)
            }
            return out
        }

        // Tier cascade: [filtered sessions, basis label]
        var tiers =[
            { set: filterWork(true, true), basis: "label+period" },
            { set: filterWork(true, false), basis: "label" },
            { set: filterWork(false, true), basis: "period" },
            { set: workSessions, basis: "all" }
        ]

        var chosen = null
        for (var t = 0; t < tiers.length; t++) {
            if (tiers[t].set.length >= root.flexMinSamples) {
                chosen = tiers[t]
                break
            }
        }

        if (!chosen) {
            return {
                workMin: root.workDuration,
                breakMin: root.shortBreakDuration,
                basis: "default",
                sampleCount: workSessions.length,
                rationale: "Not enough data yet — using default. Log at least " + root.flexMinSamples + " sessions to unlock recommendations."
            }
        }

        var workMin = root.clamp(flexSuggestMinutes(chosen.set, nowMs), 5, 180)

        // Break length: prefer same-period breaks, then all breaks, else preset.
        var periodBreaks =[]
        for (var b = 0; b < breakSessions.length; b++) {
            if (periodForHour(breakSessions[b].hour != null ? breakSessions[b].hour : 12) === period) {
                periodBreaks.push(breakSessions[b])
            }
        }
        var breakMin
        if (periodBreaks.length >= root.flexMinSamples) {
            breakMin = root.clamp(flexSuggestMinutes(periodBreaks, nowMs), 1, 60)
        } else if (breakSessions.length >= root.flexMinSamples) {
            breakMin = root.clamp(flexSuggestMinutes(breakSessions, nowMs), 1, 60)
        } else {
            breakMin = root.shortBreakDuration
        }

        return {
            workMin: workMin,
            breakMin: breakMin,
            basis: chosen.basis,
            sampleCount: chosen.set.length,
            rationale: recommendationRationale(chosen.basis, chosen.set.length, label, period)
        }
    }

    function recommendationRationale(basis, count, label, period) {
        var lbl = (label && label.length > 0) ? label : "unlabeled"
        if (basis === "label+period")
            return "Based on " + count + " " + lbl + " sessions in the " + period.toLowerCase() + " (median)"
        if (basis === "label")
            return "Based on " + count + " " + lbl + " sessions (median)"
        if (basis === "period")
            return "Based on " + count + " sessions in the " + period.toLowerCase() + " (median)"
        if (basis === "all")
            return "Based on your overall average of " + count + " sessions (median)"
        return ""
    }

    function refreshFlexRecommendation() {
        flexRecommendation = recommendFlex(root.flexCurrentLabel, new Date().getHours())
    }

    onFlexCurrentLabelChanged: refreshFlexRecommendation()
    onFlexSessionsChanged: refreshFlexRecommendation()
    // --------------------------------

    Timer {
        id: dateCheckTimer
        interval: 60000
        repeat: true
        running: true
        onTriggered: {
            const newDateKey = formatDateKey(new Date())
            if (newDateKey !== root.currentDateKey) {
                root.currentDateKey = newDateKey
                if (pluginService) {
                    globalCompletedPomodoros.set(pluginService.loadPluginData("customPomoTimer", "completedPomodoros-" + newDateKey, 0))
                    globalWorkedSecondsToday.set(pluginService.loadPluginData("customPomoTimer", "workedSeconds-" + newDateKey, 0)) // New line
                    loadLast7Days()
                }
            }
            // Keep the recommendation aligned with the current time-of-day period
            refreshFlexRecommendation()
        }
    }

    function formatDateKey(date) {
        const year = date.getFullYear()
        const month = (date.getMonth() + 1).toString().padStart(2, '0')
        const day = date.getDate().toString().padStart(2, '0')
        return year + "-" + month + "-" + day
    }

    function loadLast7Days() {
        if (!pluginService) return

        let data =[]
        const today = new Date()
        const todayKey = formatDateKey(today)

        for (let i = 6; i >= 0; i--) {
            const date = new Date(today)
            date.setDate(today.getDate() - i)
            const dateKey = formatDateKey(date)
            
            let count = 0
            let workedSeconds = 0
            
            if (dateKey === todayKey) {
                count = globalCompletedPomodoros.value
                workedSeconds = globalWorkedSecondsToday.value
            } else {
                count = pluginService.loadPluginData("customPomoTimer", "completedPomodoros-" + dateKey, 0)
                workedSeconds = pluginService.loadPluginData("customPomoTimer", "workedSeconds-" + dateKey, 0)
            }

            // Calculate minutes based on EXACT seconds worked instead of fully completed pomodoros
            const totalMins = Math.floor(workedSeconds / 60)
            let timeStr = ""
            if (totalMins > 0) {
                timeStr = totalMins >= 60 ? parseFloat((totalMins / 60).toFixed(1)) + "h" : totalMins + "m"
            }

            data.push({
                date: dateKey,
                count: count,
                minutes: totalMins,
                timeLabel: timeStr,
                dayLabel: i === 0 ? "Today" :["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.getDay()]
            })
        }

        last7DaysData = data
        cleanupOldData()
    }

    function cleanupOldData() {
        if (!pluginService) return

        const today = new Date()
        const cutoffDate = new Date(today)
        cutoffDate.setDate(today.getDate() - 7)

        for (let daysAgo = 8; daysAgo <= 30; daysAgo++) {
            const date = new Date(today)
            date.setDate(today.getDate() - daysAgo)
            const dateKey = formatDateKey(date)
            
            const key = "completedPomodoros-" + dateKey
            const value = pluginService.loadPluginData("customPomoTimer", key, null)
            if (value !== null) {
                pluginService.savePluginData("customPomoTimer", key, undefined)
            }
            
            // Clean up exact seconds data
            const workedKey = "workedSeconds-" + dateKey
            const workedValue = pluginService.loadPluginData("customPomoTimer", workedKey, null)
            if (workedValue !== null) {
                pluginService.savePluginData("customPomoTimer", workedKey, undefined)
            }
        }
    }
    
    onWorkDurationChanged: {
        if (globalTimerState.value === "work" && globalTotalSeconds.value > 0) {
            const newTotal = workDuration * 60
            const elapsed = globalTotalSeconds.value - globalRemainingSeconds.value
            globalTotalSeconds.set(newTotal)
            globalRemainingSeconds.set(Math.max(1, newTotal - elapsed))
        }
    }

    onShortBreakDurationChanged: {
        if (globalTimerState.value === "shortBreak" && globalTotalSeconds.value > 0) {
            const newTotal = shortBreakDuration * 60
            const elapsed = globalTotalSeconds.value - globalRemainingSeconds.value
            globalTotalSeconds.set(newTotal)
            globalRemainingSeconds.set(Math.max(1, newTotal - elapsed))
        }
    }

    onLongBreakDurationChanged: {
        if (globalTimerState.value === "longBreak" && globalTotalSeconds.value > 0) {
            const newTotal = longBreakDuration * 60
            const elapsed = globalTotalSeconds.value - globalRemainingSeconds.value
            globalTotalSeconds.set(newTotal)
            globalRemainingSeconds.set(Math.max(1, newTotal - elapsed))
        }
    }

    PluginGlobalVar {
        id: globalRemainingSeconds
        varName: "remainingSeconds"
        defaultValue: 0
    }

    PluginGlobalVar {
        id: globalTotalSeconds
        varName: "totalSeconds"
        defaultValue: 0
    }

    PluginGlobalVar {
        id: globalIsRunning
        varName: "isRunning"
        defaultValue: false
    }

    PluginGlobalVar {
        id: globalTimerState
        varName: "timerState"
        defaultValue: "work"
    }

    PluginGlobalVar {
        id: globalCompletedPomodoros
        varName: "completedPomodoros"
        defaultValue: 0
    }
    
    PluginGlobalVar {
        id: globalWorkedSecondsToday
        varName: "workedSecondsToday"
        defaultValue: 0
    }

    PluginGlobalVar {
        id: globalTimerOwnerId
        varName: "timerOwnerId"
        defaultValue: ""
    }

    // --- Flexible Mode Globals ---
    PluginGlobalVar {
        id: globalFlexType
        varName: "flexType"
        defaultValue: "idle"   // idle | work | break
    }

    PluginGlobalVar {
        id: globalFlexElapsed
        varName: "flexElapsed"
        defaultValue: 0
    }

    PluginGlobalVar {
        id: globalFlexPlanned
        varName: "flexPlanned"
        defaultValue: 0
    }

    PluginGlobalVar {
        id: globalFlexRunning
        varName: "flexRunning"
        defaultValue: false
    }

    PluginGlobalVar {
        id: globalFlexAwaiting
        varName: "flexAwaiting"
        defaultValue: false   // true when planned mark reached, awaiting accept/decline
    }
    // -----------------------------

    property string instanceId: Math.random().toString(36).substring(2)

    // Flexible count-up timer
    Timer {
        id: flexTimer
        interval: 1000
        repeat: true
        running: globalFlexRunning.value && globalFlexType.value !== "idle" && globalTimerOwnerId.value === root.instanceId
        onTriggered: {
            globalFlexElapsed.set(globalFlexElapsed.value + 1)

            // Flex work time feeds the shared daily worked-seconds + chart
            if (globalFlexType.value === "work") {
                globalWorkedSecondsToday.set(globalWorkedSecondsToday.value + 1)
                if (globalWorkedSecondsToday.value % 10 === 0) {
                    root.saveWorkedSeconds()
                }
                if (globalWorkedSecondsToday.value % 60 === 0) {
                    root.loadLast7Days()
                }
            }

            // Fire the end-of-session prompt exactly once when planned mark is hit
            if (!globalFlexAwaiting.value && globalFlexElapsed.value === globalFlexPlanned.value) {
                globalFlexAwaiting.set(true)
                root.fireFlexNotification(globalFlexType.value)
            }
        }
    }

    Timer {
        id: pomodoroTimer
        interval: 1000
        repeat: true
        running: globalIsRunning.value && globalTimerOwnerId.value === root.instanceId
        onTriggered: {
            // Track real-time exact seconds worked
            if (globalTimerState.value === "work") {
                globalWorkedSecondsToday.set(globalWorkedSecondsToday.value + 1)
                // Persist the exact seconds to disk every 10 seconds to prevent data loss
                if (globalWorkedSecondsToday.value % 10 === 0) {
                    root.saveWorkedSeconds()
                }
                // Update the chart visually when a full new minute is reached
                if (globalWorkedSecondsToday.value % 60 === 0) {
                    root.loadLast7Days()
                }
            }

            if (globalRemainingSeconds.value > 0) {
                globalRemainingSeconds.set(globalRemainingSeconds.value - 1)
            } else {
                root.timerComplete()
            }
        }
    }

    function saveWorkedSeconds() {
        if (pluginService) {
            pluginService.savePluginData("customPomoTimer", "workedSeconds-" + root.currentDateKey, globalWorkedSecondsToday.value)
        }
    }

    function timerComplete() {
        globalIsRunning.set(false)

        if (globalTimerState.value === "work") {
            globalCompletedPomodoros.set(globalCompletedPomodoros.value + 1)
            
            // --- Update Active Task ---
            if (activeTaskId !== "") {
                for (var i = 0; i < taskList.length; i++) {
                    if (taskList[i].id === activeTaskId) {
                        taskList[i].completed += 1
                        saveTasks() // Save updated counts
                        break
                    }
                }
            }
            // --------------------------

            if (pluginService) {
                const dateKey = formatDateKey(new Date())
                pluginService.savePluginData("customPomoTimer", "completedPomodoros-" + dateKey, globalCompletedPomodoros.value)
                loadLast7Days()
            }
            const isLongBreak = globalCompletedPomodoros.value % 4 === 0
            let soundCmd = root.workSoundPath ? "paplay '" + root.workSoundPath + "' & " : ""
            Quickshell.execDetached([
                "sh", "-c", 
                soundCmd + "notify-send 'Pomodoro Complete' 'Time for a " + (isLongBreak ? "long" : "short") + " break!' -u normal"
            ])

            if (root.autoSetDND) {
                SessionData.setDoNotDisturb(false)
            }
            if (isLongBreak) {
                root.startLongBreak(root.autoStartBreaks)
            } else {
                root.startShortBreak(root.autoStartBreaks)
            }
        } else {
            let soundCmd = root.breakSoundPath ? "paplay '" + root.breakSoundPath + "' & " : ""
            Quickshell.execDetached([
                "sh", "-c", 
                soundCmd + "notify-send 'Break Complete' 'Ready for another pomodoro?' -u normal"
            ])
            root.startWork(root.autoStartPomodoros)
        }
    }

    function startWork(autoStart) {
        globalTimerState.set("work")
        globalTotalSeconds.set(root.workDuration * 60)
        globalRemainingSeconds.set(globalTotalSeconds.value)
        if (autoStart) {
            if (globalFlexRunning.value) {
                root.stopFlex()
            }
            globalTimerOwnerId.set(root.instanceId)

            if (root.autoSetDND) {
                SessionData.setDoNotDisturb(true)
            }
        }
        globalIsRunning.set(autoStart ?? false)
    }

    function startShortBreak(autoStart) {
        if (globalTimerState.value === "work" && root.autoSetDND) {
            SessionData.setDoNotDisturb(false)
        }
        globalTimerState.set("shortBreak")
        globalTotalSeconds.set(root.shortBreakDuration * 60)
        globalRemainingSeconds.set(globalTotalSeconds.value)
        if (autoStart) {
            if (globalFlexRunning.value) {
                root.stopFlex()
            }
            globalTimerOwnerId.set(root.instanceId)
        }
        globalIsRunning.set(autoStart ?? false)
    }

    function startLongBreak(autoStart) {
        if (globalTimerState.value === "work" && root.autoSetDND) {
            SessionData.setDoNotDisturb(false)
        }
        globalTimerState.set("longBreak")
        globalTotalSeconds.set(root.longBreakDuration * 60)
        globalRemainingSeconds.set(globalTotalSeconds.value)
        if (autoStart) {
            if (globalFlexRunning.value) {
                root.stopFlex()
            }
            globalTimerOwnerId.set(root.instanceId)
        }
        globalIsRunning.set(autoStart ?? false)
    }

    function skipSession() {
        if (globalTimerState.value === "work") {
            // Log exactly one full work duration regardless of elapsed time:
            // the ticking timer already added (total - remaining) seconds, so
            // adding the remaining seconds completes a full work duration.
            const remaining = Math.max(0, globalRemainingSeconds.value)
            globalWorkedSecondsToday.set(globalWorkedSecondsToday.value + remaining)
            root.saveWorkedSeconds()
            globalRemainingSeconds.set(0)
            // Reuse the normal completion path: increments count, credits the
            // active task, fires notification, refreshes chart, advances to break.
            root.timerComplete()
        } else {
            // On a break, just advance to the next work session without stats.
            root.startWork(false)
        }
    }

    function addManualWork(pomodoros, minutes) {
        const addPomodoros = Math.max(0, parseInt(pomodoros) || 0)
        const addMinutes = Math.max(0, parseInt(minutes) || 0)
        if (addPomodoros === 0 && addMinutes === 0) return

        if (addPomodoros > 0) {
            globalCompletedPomodoros.set(globalCompletedPomodoros.value + addPomodoros)
            if (pluginService) {
                pluginService.savePluginData("customPomoTimer", "completedPomodoros-" + root.currentDateKey, globalCompletedPomodoros.value)
            }
            // Credit the active task, mirroring timerComplete()
            if (activeTaskId !== "") {
                for (var i = 0; i < taskList.length; i++) {
                    if (taskList[i].id === activeTaskId) {
                        taskList[i].completed += addPomodoros
                        saveTasks()
                        break
                    }
                }
            }
        }

        if (addMinutes > 0) {
            globalWorkedSecondsToday.set(globalWorkedSecondsToday.value + addMinutes * 60)
            root.saveWorkedSeconds()
        }

        root.loadLast7Days()
    }

    function toggleTimer() {
        if (!globalIsRunning.value) {
            // Starting the classic timer: stop any running flexible session first
            // so the two timers can never tick simultaneously.
            if (globalFlexRunning.value) {
                root.stopFlex()
            }
            globalTimerOwnerId.set(root.instanceId)
        } else {
            // We are pausing the timer. Save exact progress instantly.
            if (globalTimerState.value === "work") {
                root.saveWorkedSeconds()
                root.loadLast7Days()
            }
        }
        globalIsRunning.set(!globalIsRunning.value)
        if (root.autoSetDND && globalTimerState.value === "work") {
            SessionData.setDoNotDisturb(globalIsRunning.value)
        }
    }

    function resetTimer() {
        // If resetting while running, capture the final seconds before it resets
        if (globalIsRunning.value && globalTimerState.value === "work") {
            root.saveWorkedSeconds()
            root.loadLast7Days()
        }
        globalIsRunning.set(false)
        if (root.autoSetDND && globalTimerState.value === "work") {
            SessionData.setDoNotDisturb(false)
        }
        globalRemainingSeconds.set(globalTotalSeconds.value)
    }

    function formatTime(seconds, isVertical = false) {
        const mins = Math.floor(seconds / 60)
        const secs = seconds % 60
        return isVertical ? mins + "\n" + (secs < 10 ? "0" : "") + secs : mins + " " + (secs < 10 ? "0" : "") + secs
    }

    function getStateColor() {
        if (globalTimerState.value === "work")
            return Theme.primary
        if (globalTimerState.value === "shortBreak")
            return Theme.info
        return Theme.warning
    }

    function getStateIcon() {
        if (globalTimerState.value === "work")
            return "work"
        return "coffee"
    }

    IpcHandler {
        function resetTimer(): string {
            root.resetTimer()
            return "POMDORO_TIME_RESET_SUCCESS"
        }

        function toggleTimer(): string {
            root.toggleTimer()
            return globalIsRunning.value ? "Timer is running" : "Timer is paused"
        }

        function startWork(): string {
            root.startWork(true)
            return "POMODORO_WORK_STARTED"
        }

        function startShortBreak(): string {
            root.startShortBreak(true)
            return "POMODORO_SHORT_BREAK_STARTED"
        }

        function startLongBreak(): string {
            root.startLongBreak(true)
            return "POMODORO_LONG_BREAK_STARTED"
        }

        target: "pomodoroTimer"
    }

    Timer {
        id: initTimer
        interval: 100
        repeat: false
        running: true
        onTriggered: {
            if (globalRemainingSeconds.value === 0 && globalTotalSeconds.value === 0) {
                root.startWork(false)
            }
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.getStateIcon()
                size: Theme.iconSize - 6
                color: root.getStateColor()
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.formatTime(globalRemainingSeconds.value)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.getStateIcon()
                size: Theme.iconSize - 6
                color: root.getStateColor()
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.formatTime(globalRemainingSeconds.value, true)
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: "Pomodoro Timer"
            detailsText: {
                if (globalTimerState.value === "work")
                    return "Focus session • " + globalCompletedPomodoros.value + " completed"
                if (globalTimerState.value === "shortBreak")
                    return "Short break"
                return "Long break"
            }
            showCloseButton: true

            Column {
                id: popoutContentColumn
                width: parent.width
                spacing: Theme.spacingM

                property int activeTab: 0

                DankTabBar {
                    width: parent.width
                    currentIndex: popoutContentColumn.activeTab
                    model:[
                        { text: "Timer", icon: "timer" },
                        { text: "Flexible", icon: "tune" }
                    ]
                    onTabClicked: function(index) { popoutContentColumn.activeTab = index }
                }

                Column {
                    id: timerTab
                    width: parent.width
                    spacing: Theme.spacingM
                    visible: popoutContentColumn.activeTab === 0

                Item {
                    width: parent.width
                    height: 180

                    Rectangle {
                        width: 180
                        height: 180
                        radius: 90
                        anchors.centerIn: parent
                        color: "transparent"
                        border.width: 8
                        border.color: Qt.rgba(root.getStateColor().r, root.getStateColor().g, root.getStateColor().b, 0.2)

                        Canvas {
                            id: progressCanvas
                            width: parent.width - 16
                            height: parent.height - 16
                            anchors.centerIn: parent

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.lineWidth = 8
                                ctx.strokeStyle = root.getStateColor()
                                ctx.beginPath()
                                const centerX = width / 2
                                const centerY = height / 2
                                const radius = (width - 8) / 2
                                const progress = globalRemainingSeconds.value / globalTotalSeconds.value
                                const startAngle = -Math.PI / 2
                                const endAngle = startAngle + (2 * Math.PI * progress)
                                ctx.arc(centerX, centerY, radius, startAngle, endAngle, false)
                                ctx.stroke()
                            }

                            Connections {
                                target: globalRemainingSeconds
                                function onValueChanged() {
                                    progressCanvas.requestPaint()
                                }
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacingXS

                            StyledText {
                                text: root.formatTime(globalRemainingSeconds.value)
                                font.pixelSize: 36
                                font.weight: Font.Bold
                                color: root.getStateColor()
                                anchors.horizontalCenter: parent.horizontalCenter
                                horizontalAlignment: Text.AlignHCenter
                                width: 120
                            }

                            StyledText {
                                text: {
                                    if (globalTimerState.value === "work") {
                                        // Show Active Task name if available
                                        if (root.activeTaskId !== "") {
                                            for(var i=0; i<root.taskList.length; i++) {
                                                if(root.taskList[i].id === root.activeTaskId) return root.taskList[i].name
                                            }
                                        }
                                        return "Work"
                                    }
                                    if (globalTimerState.value === "shortBreak")
                                        return "Short Break"
                                    return "Long Break"
                                }
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceVariantText
                                anchors.horizontalCenter: parent.horizontalCenter
                                elide: Text.ElideRight
                                width: 140
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spacingM

                    Rectangle {
                        width: 64
                        height: 64
                        radius: 32
                        color: playArea.containsMouse ? Qt.rgba(root.getStateColor().r, root.getStateColor().g, root.getStateColor().b, 0.2) : "transparent"

                        DankIcon {
                            anchors.centerIn: parent
                            name: globalIsRunning.value ? "pause" : "play_arrow"
                            size: 32
                            color: root.getStateColor()
                        }

                        MouseArea {
                            id: playArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleTimer()
                        }
                    }

                    Rectangle {
                        width: 64
                        height: 64
                        radius: 32
                        color: resetArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                        DankIcon {
                            anchors.centerIn: parent
                            name: "refresh"
                            size: 24
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: resetArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.resetTimer()
                        }
                    }

                    Rectangle {
                        width: 64
                        height: 64
                        radius: 32
                        color: skipArea.containsMouse ? Theme.surfaceContainerHighest : "transparent"

                        DankIcon {
                            anchors.centerIn: parent
                            name: "skip_next"
                            size: 24
                            color: Theme.surfaceText
                        }

                        MouseArea {
                            id: skipArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.skipSession()
                        }
                    }
                }

                // --- MANUAL ADD (LOG TIME ELSEWHERE) ---
                Column {
                    id: manualAddColumn
                    width: parent.width
                    spacing: Theme.spacingS

                    property bool showManualAdd: false

                    // Toggle row
                    Row {
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: "more_time"
                            size: 18
                            color: Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: "Log time manually"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DankIcon {
                            name: manualAddColumn.showManualAdd ? "expand_less" : "expand_more"
                            size: 18
                            color: Theme.surfaceVariantText
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manualAddColumn.showManualAdd = !manualAddColumn.showManualAdd
                        }
                    }

                    // Inputs (revealed when expanded)
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: manualAddColumn.showManualAdd

                        TextField {
                            id: manualPomodoros
                            Layout.fillWidth: true
                            placeholderText: "Pomodoros"
                            placeholderTextColor: Theme.surfaceVariantText
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            inputMethodHints: Qt.ImhDigitsOnly
                            horizontalAlignment: Text.AlignHCenter
                            background: Rectangle {
                                color: Theme.surfaceContainerHighest
                                radius: Theme.cornerRadiusSmall
                            }
                        }

                        TextField {
                            id: manualMinutes
                            Layout.fillWidth: true
                            placeholderText: "Minutes"
                            placeholderTextColor: Theme.surfaceVariantText
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceText
                            inputMethodHints: Qt.ImhDigitsOnly
                            horizontalAlignment: Text.AlignHCenter
                            background: Rectangle {
                                color: Theme.surfaceContainerHighest
                                radius: Theme.cornerRadiusSmall
                            }
                        }

                        DankButton {
                            text: "Add"
                            onClicked: {
                                root.addManualWork(manualPomodoros.text, manualMinutes.text)
                                manualPomodoros.text = ""
                                manualMinutes.text = ""
                                manualAddColumn.showManualAdd = false
                            }
                        }
                    }
                }
                // ----------------------------------------

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    // --- PRESETS ---
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingS

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            radius: Theme.cornerRadius
                            color: (root.workDuration === 25 && root.shortBreakDuration === 5) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Theme.surfaceContainerHighest
                            border.width: 1
                            border.color: (root.workDuration === 25 && root.shortBreakDuration === 5) ? Theme.primary : "transparent"

                            StyledText {
                                anchors.centerIn: parent
                                text: "Classic (25/5/20)"
                                color: (root.workDuration === 25 && root.shortBreakDuration === 5) ? Theme.primary : Theme.surfaceText
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: (root.workDuration === 25 && root.shortBreakDuration === 5) ? Font.Medium : Font.Normal
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.workDuration = 25
                                    root.shortBreakDuration = 5
                                    root.longBreakDuration = 20
                                    if (pluginService) {
                                        pluginService.savePluginData("customPomoTimer", "workDuration", "25")
                                        pluginService.savePluginData("customPomoTimer", "shortBreakDuration", "5")
                                        pluginService.savePluginData("customPomoTimer", "longBreakDuration", "20")
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 32
                            radius: Theme.cornerRadius
                            color: (root.workDuration === 52 && root.shortBreakDuration === 17) ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1) : Theme.surfaceContainerHighest
                            border.width: 1
                            border.color: (root.workDuration === 52 && root.shortBreakDuration === 17) ? Theme.primary : "transparent"

                            StyledText {
                                anchors.centerIn: parent
                                text: "52/17 Mode"
                                color: (root.workDuration === 52 && root.shortBreakDuration === 17) ? Theme.primary : Theme.surfaceText
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: (root.workDuration === 52 && root.shortBreakDuration === 17) ? Font.Medium : Font.Normal
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.workDuration = 52
                                    root.shortBreakDuration = 17
                                    root.longBreakDuration = 17
                                    if (pluginService) {
                                        pluginService.savePluginData("customPomoTimer", "workDuration", "52")
                                        pluginService.savePluginData("customPomoTimer", "shortBreakDuration", "17")
                                        pluginService.savePluginData("customPomoTimer", "longBreakDuration", "17")
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        id: quickActionsRow
                        width: parent.width
                        spacing: Theme.spacingS

                        // Check if durations match
                        property bool sameBreaks: root.shortBreakDuration === root.longBreakDuration

                        DankButton {
                            Layout.fillWidth: true
                            text: "Work"
                            iconName: "work"
                            onClicked: root.startWork(false)
                        }

                        DankButton {
                            Layout.fillWidth: true
                            visible: !quickActionsRow.sameBreaks
                            text: "Short Break"
                            iconName: "coffee"
                            onClicked: root.startShortBreak(false)
                        }

                        DankButton {
                            Layout.fillWidth: true
                            visible: !quickActionsRow.sameBreaks
                            text: "Long Break"
                            iconName: "weekend"
                            onClicked: root.startLongBreak(false)
                        }

                        DankButton {
                            Layout.fillWidth: true
                            visible: quickActionsRow.sameBreaks
                            text: "Break"
                            iconName: "coffee"
                            onClicked: {
                                // Keep the underlying Pomodoro logic intact when using the combined button
                                if (globalCompletedPomodoros.value > 0 && globalCompletedPomodoros.value % 4 === 0) {
                                    root.startLongBreak(false)
                                } else {
                                    root.startShortBreak(false)
                                }
                            }
                        }
                    }
                }

                // --- TASKS SECTION ---
                StyledRect {
                    width: parent.width
                    height: tasksColumn.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh

                    Column {
                        id: tasksColumn
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        // Add Task Input
                        RowLayout {
                            width: parent.width
                            spacing: Theme.spacingS
                            
                            TextField {
                                id: newTaskName
                                Layout.fillWidth: true
                                placeholderText: "Task Name"
                                placeholderTextColor: Theme.surfaceVariantText
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                background: Rectangle {
                                    color: Theme.surfaceContainerHighest
                                    radius: Theme.cornerRadiusSmall
                                }
                            }
                            
                            TextField {
                                id: newTaskEst
                                Layout.preferredWidth: 60
                                placeholderText: "#"
                                placeholderTextColor: Theme.surfaceVariantText
                                text: "1"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceText
                                inputMethodHints: Qt.ImhDigitsOnly
                                horizontalAlignment: Text.AlignHCenter
                                background: Rectangle {
                                    color: Theme.surfaceContainerHighest
                                    radius: Theme.cornerRadiusSmall
                                }
                            }

                            DankButton {
                                iconName: "add"
                                Layout.preferredWidth: 40
                                onClicked: {
                                    root.addTask(newTaskName.text, newTaskEst.text)
                                    newTaskName.text = ""
                                    newTaskEst.text = "1"
                                }
                            }
                        }

                        // Task List
                        Repeater {
                            model: root.taskList

                            Rectangle {
                                width: parent.width
                                height: 40
                                color: "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    spacing: Theme.spacingS

                                    // Active Task Radio/Indicator
                                    Rectangle {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        radius: 12
                                        color: "transparent"
                                        border.width: 2
                                        border.color: modelData.id === root.activeTaskId ? Theme.primary : Theme.outline

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 14
                                            height: 14
                                            radius: 7
                                            color: Theme.primary
                                            visible: modelData.id === root.activeTaskId
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.setActiveTask(modelData.id)
                                        }
                                    }

                                    // Task Name & Progress
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0
                                        
                                        StyledText {
                                            text: modelData.name
                                            font.pixelSize: Theme.fontSizeMedium
                                            font.weight: Font.Medium
                                            color: modelData.isFinished ? Theme.surfaceVariantText : Theme.surfaceText
                                            font.strikeout: modelData.isFinished
                                        }
                                        
                                        RowLayout {
                                            spacing: 4
                                            
                                            StyledText {
                                                text: modelData.completed + " /"
                                                font.pixelSize: Theme.fontSizeXSmall
                                                color: Theme.surfaceVariantText
                                            }
                                            
                                            // Decrease Estimate
                                            DankIcon {
                                                Layout.preferredWidth: 14
                                                Layout.preferredHeight: 14
                                                name: "remove"
                                                size: 14
                                                // Hide the icon if dropping below 1 isn't allowed
                                                color: modelData.estimated > 1 ? Theme.surfaceVariantText : "transparent"
                                                
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    enabled: modelData.estimated > 1
                                                    onClicked: root.updateTaskEstimate(index, -1)
                                                }
                                            }
                                            
                                            StyledText {
                                                text: modelData.estimated
                                                font.pixelSize: Theme.fontSizeXSmall
                                                color: Theme.surfaceText
                                                font.weight: Font.Medium
                                            }
                                            
                                            // Increase Estimate
                                            DankIcon {
                                                Layout.preferredWidth: 14
                                                Layout.preferredHeight: 14
                                                name: "add"
                                                size: 14
                                                color: Theme.surfaceVariantText
                                                
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: root.updateTaskEstimate(index, 1)
                                                }
                                            }
                                            
                                            StyledText {
                                                text: "Pomodoros"
                                                font.pixelSize: Theme.fontSizeXSmall
                                                color: Theme.surfaceVariantText
                                            }
                                        }
                                    }

                                    // Complete Button
                                    DankIcon {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        name: modelData.isFinished ? "check_box" : "check_box_outline_blank"
                                        color: modelData.isFinished ? Theme.primary : Theme.surfaceVariantText
                                        size: 20
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.toggleTaskFinished(index)
                                        }
                                    }

                                    // Delete Button
                                    DankIcon {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        name: "delete"
                                        color: Theme.error
                                        size: 20
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.deleteTask(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                // ---------------------

                StyledRect {
                    width: parent.width
                    height: statsColumn.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh

                    Column {
                        id: statsColumn
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingXS

                        Row {
                            spacing: Theme.spacingM

                            DankIcon {
                                name: "check_circle"
                                size: Theme.iconSize
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: globalCompletedPomodoros.value + " pomodoros completed"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        StyledText {
                            text: "Next long break after " + (4 - (globalCompletedPomodoros.value % 4)) + " more"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                            leftPadding: Theme.iconSize + Theme.spacingM

                            visible: root.shortBreakDuration !== root.longBreakDuration
                        }
                    }
                }

                StyledRect {
                    width: parent.width
                    height: last7DaysColumn.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: Theme.surfaceContainerHigh

                    Column {
                        id: last7DaysColumn
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Last 7 Days"
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.surfaceVariantText
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingXS
                            height: 60
                            Repeater {
                                model: root.last7DaysData

                                Item {
                                    width: (parent.width - (parent.spacing * 6)) / 7
                                    height: parent.height

                                    Column {
                                        anchors.fill: parent
                                        spacing: Theme.spacingXS

                                        Item {
                                            width: parent.width
                                            height: 40

                                            Rectangle {
                                                width: parent.width
                                                height: 2
                                                anchors.bottom: parent.bottom
                                                radius: 1
                                                color: Qt.rgba(root.getStateColor().r, root.getStateColor().g, root.getStateColor().b, 0.2)
                                            }

                                            Rectangle {
                                                width: parent.width
                                                height: {
                                                    let maxMins = 1
                                                    for (let i = 0; i < root.last7DaysData.length; i++) {
                                                        if (root.last7DaysData[i].minutes > maxMins) {
                                                            maxMins = root.last7DaysData[i].minutes
                                                        }
                                                    }
                                                    const barHeight = (modelData.minutes / maxMins) * (parent.height - 2)
                                                    return Math.max(barHeight, modelData.minutes > 0 ? 4 : 0)
                                                }
                                                anchors.bottom: parent.bottom
                                                radius: 2
                                                color: modelData.dayLabel === "Today" ? root.getStateColor() : Qt.rgba(root.getStateColor().r, root.getStateColor().g, root.getStateColor().b, 0.6)

                                                StyledText {
                                                    text: modelData.timeLabel
                                                    font.pixelSize: Theme.fontSizeXSmall
                                                    color: Theme.surfaceText
                                                    anchors.centerIn: parent
                                                    visible: modelData.minutes > 0 && parent.height > 12
                                                }
                                            }
                                        }

                                        StyledText {
                                            text: modelData.dayLabel
                                            font.pixelSize: Theme.fontSizeXSmall
                                            color: modelData.dayLabel === "Today" ? Theme.surfaceText : Theme.surfaceVariantText
                                            horizontalAlignment: Text.AlignHCenter
                                            width: parent.width
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                } // end timerTab

                // ===================== FLEXIBLE TAB =====================
                Column {
                    id: flexTab
                    width: parent.width
                    spacing: Theme.spacingM
                    visible: popoutContentColumn.activeTab === 1

                    // --- SETUP (idle) ---
                    StyledRect {
                        width: parent.width
                        height: flexSetupColumn.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        visible: globalFlexType.value === "idle"

                        Column {
                            id: flexSetupColumn
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Start a focus session"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            DankDropdown {
                                width: parent.width
                                text: "Label"
                                currentValue: root.flexCurrentLabel
                                options: root.flexLabels
                                enableFuzzySearch: true
                                onValueChanged: function(value) { root.flexCurrentLabel = value }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: Theme.spacingS

                                TextField {
                                    id: flexNewLabel
                                    Layout.fillWidth: true
                                    placeholderText: "Add new label"
                                    placeholderTextColor: Theme.surfaceVariantText
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    background: Rectangle {
                                        color: Theme.surfaceContainerHighest
                                        radius: Theme.cornerRadiusSmall
                                    }
                                }

                                DankButton {
                                    iconName: "add"
                                    Layout.preferredWidth: 40
                                    onClicked: {
                                        root.addFlexLabel(flexNewLabel.text)
                                        root.flexCurrentLabel = flexNewLabel.text.trim()
                                        flexNewLabel.text = ""
                                    }
                                }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: Theme.spacingS

                                StyledText {
                                    text: "Duration (min)"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    Layout.fillWidth: true
                                }

                                TextField {
                                    id: flexDuration
                                    Layout.preferredWidth: 70
                                    text: "25"
                                    placeholderText: "25"
                                    placeholderTextColor: Theme.surfaceVariantText
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceText
                                    inputMethodHints: Qt.ImhDigitsOnly
                                    horizontalAlignment: Text.AlignHCenter
                                    background: Rectangle {
                                        color: Theme.surfaceContainerHighest
                                        radius: Theme.cornerRadiusSmall
                                    }
                                }
                            }

                            DankButton {
                                width: parent.width
                                text: "Start Focus"
                                iconName: "play_arrow"
                                onClicked: root.startFlex(root.flexCurrentLabel, flexDuration.text, "work")
                            }
                        }
                    }

                    // --- ACTIVE SESSION ---
                    StyledRect {
                        width: parent.width
                        height: flexActiveColumn.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh
                        visible: globalFlexType.value !== "idle"

                        Column {
                            id: flexActiveColumn
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: globalFlexType.value === "work"
                                      ? (root.flexCurrentLabel.length > 0 ? root.flexCurrentLabel : "Focus")
                                      : "Break"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: globalFlexAwaiting.value ? Theme.warning
                                       : (globalFlexType.value === "work" ? Theme.primary : Theme.info)
                            }

                            StyledText {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: root.formatTime(globalFlexElapsed.value)
                                font.pixelSize: 40
                                font.weight: Font.Bold
                                color: globalFlexElapsed.value > globalFlexPlanned.value ? Theme.warning : Theme.surfaceText
                            }

                            StyledText {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: {
                                    var planned = Math.floor(globalFlexPlanned.value / 60)
                                    var over = globalFlexElapsed.value - globalFlexPlanned.value
                                    if (over > 0) return "Target " + planned + "m • +" + root.formatTime(over) + " overtime"
                                    return "Target " + planned + "m"
                                }
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }

                            // Decision prompt (planned mark reached)
                            RowLayout {
                                width: parent.width
                                spacing: Theme.spacingS
                                visible: globalFlexAwaiting.value

                                DankButton {
                                    Layout.fillWidth: true
                                    text: globalFlexType.value === "work" ? "Take Break" : "Back to Work"
                                    iconName: "check"
                                    onClicked: root.acceptFlexTransition()
                                }

                                DankButton {
                                    Layout.fillWidth: true
                                    text: "Keep Going"
                                    iconName: "fast_forward"
                                    onClicked: root.declineFlexTransition()
                                }
                            }

                            // Pause / Stop controls
                            RowLayout {
                                width: parent.width
                                spacing: Theme.spacingS
                                visible: !globalFlexAwaiting.value

                                DankButton {
                                    Layout.fillWidth: true
                                    text: globalFlexRunning.value ? "Pause" : "Resume"
                                    iconName: globalFlexRunning.value ? "pause" : "play_arrow"
                                    onClicked: root.toggleFlex()
                                }

                                DankButton {
                                    Layout.fillWidth: true
                                    text: "Stop"
                                    iconName: "stop"
                                    onClicked: root.stopFlex()
                                }
                            }
                        }
                    }

                    // --- INSIGHTS ---
                    StyledRect {
                        width: parent.width
                        height: flexInsightsColumn.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.surfaceContainerHigh

                        Column {
                            id: flexInsightsColumn
                            anchors.fill: parent
                            anchors.margins: Theme.spacingM
                            spacing: Theme.spacingS

                            StyledText {
                                text: "Insights"
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Medium
                                color: Theme.surfaceText
                            }

                            StyledText {
                                width: parent.width
                                text: "Complete a few flexible sessions to see your focus patterns by subject and time of day."
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                wrapMode: Text.WordWrap
                                visible: root.flexSessions.length === 0
                            }

                            // By label
                            StyledText {
                                text: "By subject"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceVariantText
                                visible: Object.keys(root.flexInsights.byLabel).length > 0
                            }

                            Repeater {
                                model: Object.keys(root.flexInsights.byLabel)

                                RowLayout {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    property var entry: root.flexInsights.byLabel[modelData]

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        elide: Text.ElideRight
                                    }

                                    StyledText {
                                        text: parent.entry.workCount + "x • avg " + root.avgMinutes(parent.entry.workSeconds, parent.entry.workCount) + "m"
                                        font.pixelSize: Theme.fontSizeXSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }

                            // By period of day
                            StyledText {
                                text: "By time of day"
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.surfaceVariantText
                                topPadding: Theme.spacingXS
                                visible: Object.keys(root.flexInsights.byPeriod).length > 0
                            }

                            Repeater {
                                model: Object.keys(root.flexInsights.byPeriod)

                                RowLayout {
                                    width: parent.width
                                    spacing: Theme.spacingS

                                    property var entry: root.flexInsights.byPeriod[modelData]

                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                    }

                                    StyledText {
                                        text: {
                                            var e = parent.entry
                                            var parts =[]
                                            if (e.workCount > 0) parts.push("focus avg " + root.avgMinutes(e.workSeconds, e.workCount) + "m")
                                            if (e.breakCount > 0) parts.push("break avg " + root.avgMinutes(e.breakSeconds, e.breakCount) + "m")
                                            return parts.join(" • ")
                                        }
                                        font.pixelSize: Theme.fontSizeXSmall
                                        color: Theme.surfaceVariantText
                                    }
                                }
                            }
                        }
                    }
                }
                // =================== END FLEXIBLE TAB ===================
            }
        }
    }
}
