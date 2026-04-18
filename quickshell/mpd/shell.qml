import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
ShellRoot {
    property color colBg: "#1d2021"           // Gruvbox Background (Hard)
    property color colFg: "#ebdbb2"           // Gruvbox Foreground
    property color colMuted: "#928374"        // Gruvbox Gray (Muted)
    property color colCyan: "#8ec07c"         // Gruvbox Aqua/Cyan
    property color colPurple: "#d3869b"       // Gruvbox Purple
    property color colRed: "#fb4934"          // Gruvbox Red (Bright)
    property color colYellow: "#fabd2f"       // Gruvbox Yellow (Bright)
    property color colBlue: "#83a598"         // Gruvbox Blue
    property color colGreen: "#b8bb26"        // Gruvbox Green
    property string fontFamily: "Iosevka NerdFont Propo"
    property int fontSize: 15
    property string mpd_title:    ""
    property string mpd_artist:   ""
    property string mpd_elapsed:  "0:00"
    property string mpd_duration: "0:00"
    property string mpd_file:     ""
    property real   mpd_progress: 0.0
    property bool   isPlaying:    false
    property bool   isPaused:     false
    property bool   isActive:     isPlaying || isPaused
    property bool   isSeeking:    false
    property bool   cardVisible:  false
    property bool   titleCardVisible:  false
    property string artPath:      "/tmp/mpdrop_art.png"
    property string artCache:     ""   
    property real seekStartProgress: 0
    property double seekStartTime: 0
    property int mpdVolume: 0
    function timeToSecs(t) {
        var p = t.split(":")
        if (p.length === 2) return parseInt(p[0]) * 60 + parseInt(p[1])
        if (p.length === 3) return parseInt(p[0]) * 3600 + parseInt(p[1]) * 60 + parseInt(p[2])
        return 0
    }
    Process {
        id: volProc
        command: ["sh", "-c", "echo idle"]
        running: false
    }
    Process {
        id: notifyProc
        property string title: ""
        property string artist: ""
        property string art: ""
        command : ["sh", "-c", "notify-send -u 'normal' -i '/tmp/mpdrop_art.png' -a 'MPD' 'Now Playing' '" + mpd_title.replace(/'/g, "") + (mpd_artist !== "" ? "\n" + mpd_artist.replace(/'/g, "") : "") + "'"
    ]
        running: false
    }

    Process {
        id: artProc
        property string filePath: ""
        command: ["sh", "-c",
            "ffmpeg -i \"/mnt/" + filePath + "\" -an -vcodec copy /tmp/mpdrop_art.png -y 2>/dev/null"]
        running: false
        onExited: {
            artCache = ""
            artCache = artPath
            notifyProc.running = false
            notifyProc.running = true
        }
    }
    Process {
        id: fileProc
        command: ["mpc", "--format", "%file%", "current"]
        stdout: StdioCollector {
            onStreamFinished: {
                var f = this.text.trim()
                if (f !== "" && f !== mpd_file) {
                    mpd_file = f
                    artProc.filePath = f
                    artProc.running = false
                    artProc.running = true
                }
            }
        }
    }
    Process {
        id: idleProc
        command: ["mpc", "idlewait"]
        running: true
        onExited: statusProc.running = true
    }
    Process {
        id: statusProc
        command: ["mpc", "status", "--format", "%title%||%artist%||%duration%"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 2) {
                    var meta = lines[0].split("||")
                    var newTitle = meta[0] || "Unknown"
                    var volMatch = this.text.match(/volume:\s*(\d+)%/)
                    if (volMatch) mpdVolume = parseInt(volMatch[1])
                    if (newTitle !== mpd_title) 
                    { 
                        fileProc.running = true
                    }
                    mpd_title    = newTitle
                    mpd_artist   = meta[1] || ""
                    var rawDuration = meta[2] ? meta[2].trim() : ""
                    var sl = lines[1]
                    isPlaying = sl.indexOf("[playing]") !== -1
                    isPaused  = sl.indexOf("[paused]")  !== -1
                    var tm = sl.match(/(\d+:\d+)\/(\d+:\d+)/)
                    if (tm) {
                        mpd_elapsed = tm[1]
                        mpd_duration = (rawDuration !== "" && rawDuration !== "0:00") ? rawDuration: tm [2]
                        var total   = timeToSecs(mpd_duration)
                        if (!isSeeking) {
                            mpd_progress = total > 0 ? timeToSecs(tm[1]) / total : 0
                            seekStartProgress = mpd_progress
                            seekStartTime = Date.now() / 1000
                        }
                    }
                } else {
                    mpd_title = ""; mpd_artist = ""
                    mpd_elapsed = "0:00"; mpd_duration = "0:00"
                    mpd_progress = 0; isPlaying = false; isPaused = false
                }
            }
        }
        onExited: idleRestartTimer.restart()
    }
    Timer {
        id: idleRestartTimer
        interval: 50
        repeat: false
        onTriggered: idleProc.running = true
    }
    Timer {
        id: progressTimer
        interval: 500
        running: isPlaying && !isSeeking && isActive
        repeat: true
        onTriggered: {
            var now = Date.now() / 1000
            var elapsed = now - seekStartTime
            var total = timeToSecs(mpd_duration)
            if (total <= 0) return

            var newProgress = Math.min(1.0, seekStartProgress + (elapsed / total))
            mpd_progress = newProgress
            var elapsedSecs = Math.round(newProgress * total)
            var m = Math.floor(elapsedSecs / 60)
            var s = elapsedSecs % 60
            mpd_elapsed = m + ":" + (s < 10 ? "0" + s : s)
        }
    }
    Timer {
        id: seekResetTimer
        interval: 1100
        repeat: false
        onTriggered: isSeeking = false
    }
    Timer {
        id: syncTimer
        interval: 5000
        running: isActive
        repeat: true
        onTriggered: statusProc.running = true
    }
    Process {
        id: ctrlProc
        property var args: ["toggle"]
        command: ["mpc"].concat(args)
        running: false
        onExited: statusProc.running = true
    }
    PanelWindow {
        visible: titleCardVisible && isActive
        screen: Quickshell.screens[0]
        exclusionMode: ExclusionMode.Ignore
        anchors { bottom: true; left: true }
        implicitHeight: 36
        color: "transparent"

        Rectangle {
            anchors.fill: titleCardText.implicitWidth + 24
            height: 28
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.left: parent.left
            anchors.leftMargin: 40
            radius: 8
            color: colBg
            border.color: colMuted
            border.width: 1
            opacity: titleCardVisible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Text {
                id: titleCardText
                anchors.centerIn: parent
                text: mpd_title
                color: colPurple
                font.pixelSize: fontSize
                font.family: fontFamily
                font.bold: true
            }
        }
    }
    PanelWindow {
        visible: cardVisible && isActive
        screen: Quickshell.screens[0]
        exclusionMode: ExclusionMode.Ignore
        anchors { bottom: true; right: true }
        implicitWidth: 280
        implicitHeight: artCardContent.implicitHeight + 24
        color: "transparent"

        Rectangle {
            id: artCardContent
            anchors.fill: parent
            anchors.margins: 12
            implicitHeight: cardCol.implicitHeight + 24
            radius: 12
            color: colBg
            border.color: colMuted
            border.width: 1
            opacity: cardVisible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Column {
                id: cardCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // Album art
                Rectangle {
                    width: parent.width
                    height: artImage.status === Image.Ready
                        ? parent.width * (artImage.implicitHeight / artImage.implicitWidth)
                        : parent.width
                    radius: 8
                    color: colMuted
                    clip: true
                    Image {
                        id: artImage
                        anchors.fill: parent
                        source: artCache !== "" ? "file://" + artCache : ""
                        fillMode: Image.PreserveAspectFit
                        cache: false
                        smooth: cardVisible
                        asynchronous: true
                        Text {
                            anchors.centerIn: parent
                            text: "󰎈"
                            font.pixelSize: 48
                            font.family: fontFamily
                            color: colMuted
                            visible: artImage.status !== Image.Ready
                        }
                    }
                }
                Text {
                    text: mpd_title
                    color: colFg
                    font.pixelSize: 13
                    font.family: fontFamily
                    font.bold: true
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: mpd_artist
                    color: colMuted
                    font.pixelSize: 12
                    font.family: fontFamily
                    elide: Text.ElideRight
                    width: parent.width
                    visible: mpd_artist !== ""
                }
                Rectangle {
                    width: parent.width
                    height: 3
                    radius: 2
                    color: colMuted
                    Rectangle {
                        width: parent.width * mpd_progress
                        height: parent.height
                        radius: 2
                        color: isPlaying ? colRed : colYellow
                        Behavior on width {
                            enabled: !isSeeking
                            NumberAnimation { duration: 950; easing.type: Easing.Linear }
                        }
                    }
                }
                RowLayout {
                    width: parent.width
                    Text {
                        text: mpd_elapsed
                        color: colFg
                        font.pixelSize: 11
                        font.family: fontFamily
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: mpd_duration
                        color: colMuted
                        font.pixelSize: 11
                        font.family: fontFamily
                    }
                }
            }
        }
    }
    PanelWindow {
        id: mainBar
        visible: isActive
        screen: Quickshell.screens[0]
        exclusionMode: ExclusionMode.Auto
        anchors { bottom: true; left: true; right: true }
        implicitHeight: 36
        color: colBg
        Rectangle {
            anchors.fill: parent
            color: colBg
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: colMuted
            }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 0
                Text {
                    text: isPaused ? "󰎊" : "󰎈"
                    color: isPaused ? colYellow : colCyan
                    font.pixelSize: fontSize + 3
                    font.family: fontFamily
                    font.bold: true

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Item { width: 8 }
                Text {
                    text: mpd_title || "Unknown"
                    color: colPurple
                    font.pixelSize: fontSize
                    font.family: fontFamily
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.maximumWidth: 220
                    HoverHandler {
                        onHoveredChanged: titleCardVisible = hovered 
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1; Layout.preferredHeight: 16
                    Layout.leftMargin: 8; Layout.rightMargin: 8
                    color: colMuted
                    visible: mpd_artist !== ""
                }
                Text {
                    text: mpd_artist
                    color: colCyan
                    font.pixelSize: fontSize
                    font.family: fontFamily
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.maximumWidth: 180
                    visible: mpd_artist !== ""
                }
                Rectangle {
                    Layout.preferredWidth: 1; Layout.preferredHeight: 16
                    Layout.leftMargin: 8; Layout.rightMargin: 8
                    color: colMuted
                }
                Text {
                    text: "󰒮"
                    color: prevH.containsMouse ? colCyan : colFg
                    font.pixelSize: fontSize + 3; font.family: fontFamily; font.bold: true
                    Layout.rightMargin: 10
                    HoverHandler { id: prevH }
                    TapHandler {
                        onTapped: {
                            if (!ctrlProc.running) {
                                ctrlProc.args = ["prev"]
                                ctrlProc.running = true
                            }
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Text {
                    text: isPlaying ? "󰏤" : "󰐊"
                    color: playH.containsMouse ? colPurple : colCyan
                    font.pixelSize: fontSize + 3; font.family: fontFamily; font.bold: true
                    Layout.rightMargin: 10
                    HoverHandler { id: playH }
                    TapHandler {
                        onTapped: {
                            if (!ctrlProc.running) {
                                ctrlProc.args = ["toggle"]
                                ctrlProc.running = true
                            }
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Text {
                    text: "󰒭"
                    color: nextH.containsMouse ? colCyan : colFg
                    font.pixelSize: fontSize + 3; font.family: fontFamily; font.bold: true
                    Layout.rightMargin: 10
                    HoverHandler { id: nextH }
                    TapHandler {
                        onTapped: {
                            if (!ctrlProc.running) {
                                ctrlProc.args = ["next"]
                                ctrlProc.running = true
                            }
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Text {
                    text: "󰓛"
                    color: stopH.containsMouse ? colRed : colMuted
                    font.pixelSize: fontSize + 3; font.family: fontFamily; font.bold: true
                    HoverHandler { id: stopH }
                    TapHandler {
                        onTapped: {
                            if (!ctrlProc.running) {
                                ctrlProc.args = ["stop"]
                                ctrlProc.running = true
                            }
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                Rectangle {
                    Layout.preferredWidth: 1; Layout.preferredHeight: 16
                    Layout.leftMargin: 8; Layout.rightMargin: 8
                    color: colMuted
                }
                Item {
                    implicitWidth: volIcon.implicitWidth + volText.implicitWidth + 4
                    implicitHeight: parent.height

                    Text {
                    id: volIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: mpdVolume <=0 ? "󰝟" : mpdVolume < 50 ? "󰕿" : "󰕾"
                    color: colBlue
                    font.pixelSize: fontSize + 3
                    font.family: fontFamily
                    font.bold: true
                }
                    Text {
                        id: volText
                        anchors.left: volIcon.right
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: mpdVolume + "%"
                        color: colBlue
                        font.pixelSize: fontSize
                        font.family: fontFamily
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill:  parent
                        onWheel: (wheel) => {
                            console.log("wheel fired: " + wheel.angleDelta.y)
                            volProc.command = wheel.angleDelta.y > 0
                            ? ["sh", "-c","mpc volume +5"]
                            : ["sh", "-c","mpc volume -5"]
                            volProc.running = false
                            volProc.running = true
                        }
                    }
                }


                Rectangle {
                    Layout.preferredWidth: 1; Layout.preferredHeight: 16
                    Layout.leftMargin: 8; Layout.rightMargin: 8
                    color: colMuted
                }
                Text {
                    text: mpd_elapsed
                    color: colFg
                    font.pixelSize: fontSize; font.family: fontFamily; font.bold: true
                    Layout.rightMargin: 8
                }
                Rectangle {
                    id: progressTrack
                    Layout.fillWidth: true
                    height: 4; radius: 2
                    color: colMuted
                    Rectangle {
                        id: progressFill
                        width: progressTrack.width * mpd_progress
                        height: parent.height; radius: 2
                        color: isPlaying ? colRed : colYellow
                        Behavior on width {
                            enabled: !isSeeking
                            NumberAnimation { duration: 950; easing.type: Easing.Linear }
                        }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        anchors.topMargin: -6
                        anchors.bottomMargin: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (!ctrlProc.running) {
                                var pct = Math.max(0, Math.min(1, mouse.x / progressTrack.width))
                                var pctInt = Math.round(pct * 100)
                                isSeeking = true
                                mpd_progress = pct
                                seekStartProgress = pct
                                seekStartTime = Date.now() / 1000
                                ctrlProc.args = ["seek", pctInt + "%"]
                                ctrlProc.running = true
                                seekResetTimer.restart()
                            }
                        }
                    }
                }
                Text {
                    text: mpd_duration
                    color: colMuted
                    font.pixelSize: fontSize; font.family: fontFamily; font.bold: true
                    Layout.leftMargin: 8
                }
                Rectangle {
                    Layout.preferredWidth: 1; Layout.preferredHeight: 16
                    Layout.leftMargin: 8; Layout.rightMargin: 8
                    color: colMuted
                }
                Text {
                    text: "󰜡"
                    color: colCyan
                    font.pixelSize: fontSize + 3
                    font.family: fontFamily
                    font.bold: true
                    HoverHandler {
                        id: iconHover
                        onHoveredChanged: cardVisible = iconHover.hovered
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                // Item { width: 8 }
            }
        }
    }
}
