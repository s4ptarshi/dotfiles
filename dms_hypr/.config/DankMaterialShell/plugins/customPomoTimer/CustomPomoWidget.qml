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
    property int longBreakDuration: pluginData.longBreakDuration || 15
    property bool autoStartBreaks: pluginData.autoStartBreaks ?? false
    property bool autoStartPomodoros: pluginData.autoStartPomodoros ?? false
    property bool autoSetDND: pluginData.autoSetDND ?? false
    property var last7DaysData: []
    property string currentDateKey: ""
    property string workSoundPath: pluginData.workSoundPath || ""
    property string breakSoundPath: pluginData.breakSoundPath || ""

    // --- New Task Properties ---
    property var taskList: []
    property string activeTaskId: ""
    
    // Helper to refresh the list view
    function refreshTaskList() {
        var temp = taskList
        taskList = []
        taskList = temp
    }
    // ---------------------------

    onPluginServiceChanged: {
        if (pluginService) {
            currentDateKey = formatDateKey(new Date())
            globalCompletedPomodoros.set(pluginService.loadPluginData("customPomoTimer", "completedPomodoros-" + currentDateKey, 0))
            loadLast7Days()
            loadTasks() // Load tasks on startup
        }
    }

    // --- Task Functions ---
    function loadTasks() {
        if (!pluginService) return
        var tasksJson = pluginService.loadPluginData("customPomoTimer", "tasks", "[]")
        try {
            taskList = JSON.parse(tasksJson)
        } catch (e) {
            taskList = []
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
                    loadLast7Days()
                }
            }
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

        let data = []
        const today = new Date()
        const todayKey = formatDateKey(today)

        for (let i = 6; i >= 0; i--) {
            const date = new Date(today)
            date.setDate(today.getDate() - i)
            const dateKey = formatDateKey(date)
            
            let count = 0
            if (dateKey === todayKey) {
                count = globalCompletedPomodoros.value
            } else {
                count = pluginService.loadPluginData("customPomoTimer", "completedPomodoros-" + dateKey, 0)
            }

            data.push({
                date: dateKey,
                count: count,
                dayLabel: i === 0 ? "Today" : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][date.getDay()]
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
        id: globalTimerOwnerId
        varName: "timerOwnerId"
        defaultValue: ""
    }

    property string instanceId: Math.random().toString(36).substring(2)

    Timer {
        id: pomodoroTimer
        interval: 1000
        repeat: true
        running: globalIsRunning.value && globalTimerOwnerId.value === root.instanceId
        onTriggered: {
            if (globalRemainingSeconds.value > 0) {
                globalRemainingSeconds.set(globalRemainingSeconds.value - 1)
            } else {
                root.timerComplete()
            }
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
            globalTimerOwnerId.set(root.instanceId)
        }
        globalIsRunning.set(autoStart ?? false)
    }

    function toggleTimer() {
        if (!globalIsRunning.value) {
            globalTimerOwnerId.set(root.instanceId)
        }
        globalIsRunning.set(!globalIsRunning.value)
        if (root.autoSetDND && globalTimerState.value === "work") {
            SessionData.setDoNotDisturb(globalIsRunning.value)
        }
    }

    function resetTimer() {
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
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

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
                                                    let maxCount = 1
                                                    for (let i = 0; i < root.last7DaysData.length; i++) {
                                                        if (root.last7DaysData[i].count > maxCount) {
                                                            maxCount = root.last7DaysData[i].count
                                                        }
                                                    }
                                                    const barHeight = (modelData.count / maxCount) * (parent.height - 2)
                                                    return Math.max(barHeight, modelData.count > 0 ? 4 : 0)
                                                }
                                                anchors.bottom: parent.bottom
                                                radius: 2
                                                color: modelData.dayLabel === "Today" ? root.getStateColor() : Qt.rgba(root.getStateColor().r, root.getStateColor().g, root.getStateColor().b, 0.6)

                                                StyledText {
                                                    text: modelData.count > 0 ? modelData.count : ""
                                                    font.pixelSize: Theme.fontSizeXSmall
                                                    color: Theme.surfaceText
                                                    anchors.centerIn: parent
                                                    visible: modelData.count > 0 && parent.height > 12
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
            }
        }
    }
}
