import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 2.0
import Qt.labs.platform 1.1
import QtQuick.Dialogs 1.2

Item {
    id: widget
    Plasmoid.icon: 'starred-symbolic'
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    XmlListModel {
        id: rssModel
        source: "http://example.com/rss"
        query: "/rss/channel/item"

        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "link"; query: "link/string()" }
        XmlRole { name: "description"; query: "description/string()" }
    }

    Plasmoid.fullRepresentation: Item {
        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight
        Layout.preferredWidth: 500 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 500 * PlasmaCore.Units.devicePixelRatio

        RowLayout {
            anchors.fill: parent
            spacing: 0 

            TextField {
                id: urlField
            }

            PlasmaComponents.Button {
                id: addFeedButton
                text: i18n("Add new Feed")
                onClicked: dialog.visible = true
            }

            // StandardDialog {
            //     id: dialog
            //     title: "Add new feed"
            //     visible: false

            //     TextField {
            //         id: dialogUrlField
            //         placeholderText: "Enter RSS feed URL"
            //     }

            //     onAccepted: {
            //         rssModel.source = dialogUrlField.text;
            //     }
            // }

PlasmaCore.Dialog {
    visible: false
    id: dialog
    mainItem: Item {
        width: 200
        height: 100

        TextField {
            id: dialogUrlField
            placeholderText: "Enter RSS feed URL"
        }

        PlasmaComponents.Button {
            id: addUrlButton
            text: "Add"
            onClicked: {
                rssModel.source = dialogUrlField.text;
                dialog.visible = false;
            }
        }
    }
}

            PlasmaComponents.Label {
                id: label
                text: i18n("Currently showing ______ feeds")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        ListView {
            model: rssModel
            delegate: Text { text: title + "\n" + description }
        }
    }
}