import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 18000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#0b120f"
        }

        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.76, 680)
            spacing: 22

            Image {
                source: "welcome.png"
                width: parent.width
                height: 240
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                width: parent.width
                text: qsTr("Install DebianMOSS with a darker field guide look, calm defaults, and a clean Debian base.")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: "#eef7e5"
                font.pixelSize: 24
            }

            Text {
                width: parent.width
                text: qsTr("The installer will prepare your disk, copy the live system, and configure the machine for first boot.")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: "#a8c1a4"
                font.pixelSize: 16
            }
        }
    }

    Slide {
        Rectangle {
            anchors.fill: parent
            color: "#08100d"
        }

        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.7, 620)
            spacing: 18

            Image {
                source: "logo.png"
                width: 120
                height: 120
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                width: parent.width
                text: qsTr("What you get")
                horizontalAlignment: Text.AlignHCenter
                color: "#7cff76"
                font.pixelSize: 22
                font.bold: true
            }

            Text {
                width: parent.width
                text: qsTr("- one installer entry that launches cleanly\n- moss-themed boot, login, and desktop defaults\n- a Debian base that stays familiar underneath the branding")
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: "#eef7e5"
                font.pixelSize: 16
            }
        }
    }

    function onActivate() {
        presentation.currentSlide = 0;
    }

    function onLeave() {
    }
}
