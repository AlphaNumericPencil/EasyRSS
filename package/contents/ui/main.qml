import Qt.labs.platform 1.1
import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.0
import QtQuick.XmlListModel 2.0
import org.kde.kirigami 2.10 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

Item {
    id: widget

    property int itemHeight: 10 // Define the height for each item in the list

    Plasmoid.icon: 'starred-symbolic'
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    // ListModel to hold multiple XmlListModel's
    ListModel {
        id: feedsModel
    }

Plasmoid.fullRepresentation: Item {
    id: fullRepresentation

    function addFeed(feedUrl) {
        var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { source: "' + feedUrl + '"; query: "/rss/channel/item"; XmlRole { name: "title"; query: "title/string()" } XmlRole { name: "link"; query: "link/string()" } XmlRole { name: "description"; query: "description/string()" } }', widget);
        feedsModel.append({"feedModel": feed});
    }

    Layout.minimumWidth: label.implicitWidth
    Layout.minimumHeight: label.implicitHeight
    Layout.preferredWidth: 1000 * PlasmaCore.Units.devicePixelRatio
    Layout.preferredHeight: 500 * PlasmaCore.Units.devicePixelRatio

    ColumnLayout {
        id: columnLayout
        anchors.fill: parent
        spacing: 0

        RowLayout {
            id: addFeedRow
            Layout.fillWidth: true

            PlasmaComponents.Button {
                id: addFeedButton

                text: i18n("Add new Feed")
                onClicked: {
                    console.log("addFeedButton clicked"); // Log a message when the button is clicked
                    newRSS.visible = true;
                }
            }

            PlasmaComponents.Label {
                id: label

                text: feedsModel.count > 0 ? i18n("Currently showing %1 feeds", feedsModel.count) : i18n("Add a feed!")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

ListView {
    id: feedsListView
    model: feedsModel.get(0).feedModel // Access the feedModel directly from the ListModel
    Layout.fillWidth: true
    Layout.fillHeight: true

    delegate: Item {
        width: parent.width
        height: widget.itemHeight * model.count // Update to model.count

        Repeater {
            model: model // Bind to the feedModel directly

            delegate: Text {
                text: model.title + "\n" + model.description
                width: parent.width
                height: widget.itemHeight
            }
        }

        Text {
            text: feedsModel.count === 0 ? i18n("Add a feed!") : "" // Show "Add a feed!" message if the list is empty
            font.bold: true
            font.pointSize: 14
            color: "black" // Provide a fallback color
            anchors.centerIn: parent
            visible: feedsModel.count === 0
        }
    }
}
    }

    Popup {
        id: newRSS

        height: 75
        width: 500
        x: (parent.width - width) / 2 // This will position the Popup in the center of the parent Item horizontally
        y: (parent.height - height) / 2 // This will position the Popup in the center of the parent Item vertically
        visible: false

        RowLayout {
            anchors.fill: parent
            spacing: 0

            TextField {
                id: dialogUrlField

                placeholderText: "Enter RSS feed URL"
                Layout.preferredWidth: parent.width * 0.7
            }

            PlasmaComponents.Button {
                id: addUrlButton

                text: "Add"
                onClicked: {
                    fullRepresentation.addFeed(dialogUrlField.text); // Add a new feed whenthe button is clicked
                    newRSS.visible = false;
                }
            }
        }
    }
}
}
