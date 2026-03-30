import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // --- BLACKOUT THEME COLORS ---
    property color colBg: "#000000"           // True Black to match Ghostty
    property color colFg: "#ffffff"           // Pure White to match Oh-My-Posh
    property color colMuted: "#313244"        // Dark Grey (Surface1)
    property color colCyan: "#89dceb"         // Catppuccin Sky
    property color colPurple: "#cba6f7"       // Catppuccin Mauve
    property color colRed: "#f38ba8"          // Catppuccin Red
    property color colYellow: "#f9e2af"       // Catppuccin Yellow
    property color colBlue: "#89b4fa"         // Catppuccin Blue

    // Font
    property string fontFamily: "Iosevka Nerd Font Propo"
    property int fontSize: 16

    // System info properties
    property string kernelVersion: "Arch"
    property string powerProfile: ""
    property int cpuUsage: 0
    property string memUsage: ""
    property string diskUsage: ""
    property int volumeLevel: 0
    property string activeWindow: "Window"
    property string currentLayout: "Tile"
    property string cpuTemp: "0"
    property int cpuTempInt: parseInt(cpuTemp, 10)
    property string upTime: "0"
    
    property color tempColor: {
        if (cpuTempInt < 50 ) return "#a6e3a1" // Green
        else if (cpuTempInt < 70) return "#f9e2af" // Yellow
        else return "#f38ba8" // Red
    }
    
    property int notificationCount: 0    

    property string weatherTemp: "0"
    property string weatherIcon: ""
    property string weatherDesc: ""
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0



    function getWeatherIcon(desc) {
        if (!desc) return "❓";
        var hour = new Date().getHours();
        var isDay = (hour >= 6 && hour < 18);
        var d = desc.toLowerCase();
        if (d.includes("sun") || d.includes("clear")) {
            return isDay ? " " : " ";
        }
        if (d.includes("cloud") && d.includes("partly")) {
            return isDay ? " " : " ";
        }
        if (d.includes("cloud") || d.includes("overcast")) {
            return " ";
        }
        if (d.includes("rain") || d.includes("drizzle") || d.includes("showers")) {
            return " ";
        }

        if (d.includes("thunder") || d.includes("storm")) {
            return " ";
        }

        if (d.includes("snow") || d.includes("ice") || d.includes("sleet")) {
            return " ";
        }

        if (d.includes("fog") || d.includes("mist") || d.includes("haze")) {
            return "󰖑 ";
        }

        return " ";
    }
    // Kernel version
    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: data => { if (data) kernelVersion = data.trim() }
        }
        Component.onCompleted: running = true
    }

    // System UpTime
    Process {
        id: upTimeProc
        command: ["sh", "-c", "uptime|awk '{gsub(\",\",\"\");print $3}'"]
       // command: ["sh", "-c", "uptime"]
        stdout: SplitParser {
            onRead: data => { if (data) upTime = data.trim() }
        }
        Component.onCompleted: running = true
    }


    
    // CPU usage
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0
                var total = user + nice + system + idle + iowait + irq + softirq
                var idleTime = idle + iowait
                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal
                    var idleDiff = idleTime - lastCpuIdle
                    if (totalDiff > 0) cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                }
                lastCpuTotal = total
                lastCpuIdle = idleTime
            }
        }
        Component.onCompleted: running = true
    }

    // Notification monitor
    Process {
    id: notifListener
    command: ["sh", "-c", "dbus-monitor \"interface='org.freedesktop.Notifications',member='Notify'\" \"interface='org.freedesktop.Notifications',member='NotificationClosed'\""]
    running: true
    stdout: SplitParser {
        onRead: data => {
            countPoller.running = true
        }
    }
}
    // Notification Updater
    Process {
    id: countPoller
    command: ["sh", "-c", "dunstctl count | awk -F : '/History/ {print $2}'"]
    stdout: SplitParser {
        onRead: data => {
            if (data) notificationCount = parseInt(data.trim())
        }
    }
}	
	// show notification history
	Process {
    id: showHistoryProc
    command: ["sh", "-c", "count=$(dunstctl count history); for i in $(seq 1 $count); do dunstctl history-pop; done"]
	}
    
	// clear notifications
    Process {
        id: clearAllProc
        command: ["dunstctl", "history-clear"]
        onExited: {
            countPoller.running = true;
        }
    }

    // Memory usage
    Process {
        id: memProc
        command: ["sh", "-c", "free -h | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var used = parts[2] || "0"
                memUsage = used
            }
        }
        Component.onCompleted: running = true
    }

    // Weather
    Process {
        id: weatherProc
        command: ["sh", "-c", "curl -s 'https://wttr.in/prayagraj?format=j1' | jq -r '.current_condition[] | [.weatherDesc[0].value, .FeelsLikeC + \"°C\"] | join(\"|\")'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.trim() === "") return
                var parts = data.trim().split('|')
                if (parts.length >= 2) {
                    weatherDesc = parts[0]
                    weatherTemp = parts[1]

                    weatherIcon = getWeatherIcon(weatherDesc.toLowerCase())
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Disk usage
    Process {
        id: diskProc
        command: ["sh", "-c", "df -h / | tail -1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var StrInGB = parts[2] || "0G"
                diskUsage = StrInGB
            }
        }
        Component.onCompleted: running = true
    }

    // Volume level
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match) volumeLevel = Math.round(parseFloat(match[1]) * 100)
            }
        }
        Component.onCompleted: running = true
    }

    // Active window title
    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => { if (data && data.trim()) activeWindow = data.trim() }
        }
        Component.onCompleted: running = true
    }

    // Current layout
    Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        stdout: SplitParser {
            onRead: data => { if (data && data.trim()) currentLayout = data.trim() }
        }
        Component.onCompleted: running = true
    }

    // CPU Temp
    Process {
      id: cpuTempProc
      command: ["sh", "-c", "sensors | awk '/Tctl:/ {print $2}'"]
      stdout: SplitParser {
        onRead: data => { if (data && data.length > 0) cpuTemp = data.trim() }
      }
  }

    // Timers

    // UpTime Timer
    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: {
            upTimeProc.running = true
        }
    }
    // SysEssentials Timer
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: {
            cpuProc.running = true; memProc.running = true; diskProc.running = true
            volProc.running = true; cpuTempProc.running = true; powerProfileProc.running = true
        }
    }
    // Weather Timer
    Timer { interval: 1800000; running: true; repeat: true; onTriggered: weatherProc.running = true }

    Connections {
        target: Hyprland
        function onRawEvent(event) { windowProc.running = true; layoutProc.running = true }
    }

    Timer {
        interval: 200; running: true; repeat: true
        onTriggered: { windowProc.running = true; layoutProc.running = true }
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 30
            color: root.colBg

            Rectangle {
                anchors.fill: parent
                color: root.colBg

                RowLayout {
                    anchors.fill: parent; spacing: 0
                    Item { width: 8 }

                    // Arch Icon
                    Rectangle {
                        Layout.preferredWidth: 24; Layout.preferredHeight: 24; color: "transparent"
                        Image {
                            anchors.fill: parent
                            source: "file:///home/subh/.config/quickshell/icons/arch.png"
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    Item { width: 8 }

                    // Workspaces
                    Repeater {
                        model: 9
                        Rectangle {
                            Layout.preferredWidth: 20; Layout.preferredHeight: parent.height; color: "transparent"
                            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                            property bool hasWindows: workspace !== null

                            Text {
                                text: index + 1
                                color: parent.isActive ? root.colCyan : (parent.hasWindows ? root.colFg : root.colMuted)
                                font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true
                                anchors.centerIn: parent
                            }
                            Rectangle {
                                width: 20; height: 3
                                color: parent.isActive ? root.colPurple : "transparent"
                                anchors.horizontalCenter: parent.horizontalCenter; anchors.bottom: parent.bottom
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + (index + 1))
                            }
                        }
                    }

                    // Separator
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.leftMargin: 8; Layout.rightMargin: 8; color: root.colMuted }

                    // Layout
                    Text { text: currentLayout; color: root.colFg; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.leftMargin: 8; Layout.rightMargin: 8; color: root.colMuted }
                    Text { text: "󰦖 " + upTime; color: root.colCyan; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true }

                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.leftMargin: 8; Layout.rightMargin: 8; color: root.colMuted }

                    // Window Title
                    Text {
                        text: activeWindow; color: root.colPurple; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true
                        Layout.fillWidth: true; Layout.leftMargin: 8; elide: Text.ElideRight; maximumLineCount: 1
                    }

                    // System Stats (Right Side)
                    Text { text: "󰣇 " + kernelVersion; color: root.colCyan; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }

                    Text { text: weatherIcon + weatherTemp; color: root.colYellow; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }

                    Text { text: " " + cpuTemp; color: tempColor; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }

                    Text { text: " " + cpuUsage + "%"; color: root.colPurple; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }

                    Text { text: " " + memUsage; color: root.colCyan; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }

                    Text { text: " " + diskUsage; color: root.colBlue; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }

                    // netspeed
                    Text {
                        id: netSpeed
                        color: root.colRed
                        font.pixelSize: 15
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8

                            Process {
                                id: netProc
                                command: ["bash", "/opt/scripts/netspeed.sh", "wlp8s0"]
                                running: true
                                stdout: SplitParser {
                                    onRead: data => netSpeed.text = data.trim()
                                }
                            }
                        }

                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }
                    Text { text: " " + volumeLevel + "%"; color: root.colPurple; font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8 }
                    Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 16; Layout.rightMargin: 8; color: root.colMuted }


                    // Clock
                    Text {
                        id: clockText
                        text: Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm")
                        color: root.colFg 
                        font.pixelSize: root.fontSize; font.family: root.fontFamily; font.bold: true; Layout.rightMargin: 8
                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd - HH:mm:ss")
                        }
                    }
					RowLayout {
					id: notifRow
    				visible: root.notificationCount > 0
    				spacing: 0

    				Rectangle { 
        				Layout.preferredWidth: 1; Layout.preferredHeight: 16
        				Layout.leftMargin: 8; Layout.rightMargin: 8
        				color: root.colMuted 
    				}

    				Text {
        				text: "󰂚 " + root.notificationCount
        				color: root.colYellow
        				font.pixelSize: root.fontSize
        				font.family: root.fontFamily
        				font.bold: true
        
        			MouseArea {
            			anchors.fill: parent
            			cursorShape: Qt.PointingHandCursor
            
            			acceptedButtons: Qt.LeftButton | Qt.RightButton
            			onClicked: (mouse) => {
                			if (mouse.button === Qt.RightButton) {
                    			clearAllProc.running = true;
                			} else {
                    			showHistoryProc.running = true;
                				}
            				}
        				}
    				}
				}
                    Item { width: 8 }

                }
            }
        }
    }
}
