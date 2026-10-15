import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    // synced | syncing | failed | paused | stale | unknown
    property string syncState: "unknown"
    property string report: ""

    readonly property var icons: ({
            "synced": "cloud_done",
            "syncing": "cloud_sync",
            "failed": "cloud_off",
            "paused": "pause_circle",
            "stale": "cloud_alert",
            "unknown": "cloud_queue"
        })

    ccWidgetIcon: icons[syncState] ?? icons.unknown
    ccWidgetPrimaryText: "Drive sync"
    ccWidgetSecondaryText: syncState.charAt(0).toUpperCase() + syncState.slice(1)
    ccWidgetIsActive: syncState === "synced" || syncState === "syncing"

    ccDetailHeight: 220
    onCcWidgetExpanded: refreshReport()

    function refresh() {
        if (!stateProc.running)
            stateProc.running = true;
    }

    function refreshReport() {
        refresh();
        if (!reportProc.running)
            reportProc.running = true;
    }

    Process {
        id: stateProc
        command: ["rclone-status", "--state"]
        stdout: StdioCollector {
            onStreamFinished: root.syncState = text.trim() || "unknown"
        }
    }

    Process {
        id: reportProc
        command: ["rclone-status"]
        stdout: StdioCollector {
            onStreamFinished: root.report = text.trim()
        }
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    ccDetailContent: Component {
        Column {
            width: parent.width
            spacing: Theme.spacingS

            // DMS builds this panel from a fresh plugin instance, so its report starts
            // empty and ccWidgetExpanded never fires on it. Load immediately.
            Component.onCompleted: root.refreshReport()

            StyledText {
                visible: root.report === ""
                text: "Loading…"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            // Keep the report fresh while the panel is open.
            Timer {
                interval: 5000
                running: true
                repeat: true
                onTriggered: root.refreshReport()
            }

            StyledText {
                width: parent.width
                text: root.report
                wrapMode: Text.Wrap
                font.family: "monospace"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
            }
        }
    }
}
