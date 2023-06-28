import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0

Item {
    // Always display the compact view.
    // Never show the full popup view even if there is space for it.
    id: widget
    Plasmoid.icon: 'starred-symbolic'

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight
        Layout.preferredWidth: 640 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 480 * PlasmaCore.Units.devicePixelRatio
        
        ColumnLayout {
            PlasmaComponents.Label {
                id: label
                anchors.fill: parent
                text: i18n("Hello World!")
                horizontalAlignment: Text.AlignHCenter

                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            PlasmaComponents.Button {
                id: widget
                Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
                Layout.minimumWidth: implicitWidth

                property int num: 1
                onNumChanged: console.log('num', num)

                text: i18n("Add 1")
                onClicked: num += 1

                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}