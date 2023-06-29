//import org.kde.metadatamodels 0.1 as MetadataModels
//import org.kde.runnermodel 0.1 as RunnerModels

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

    function addFeed(feedUrl) {
        var xmlListModel = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { source: "' + feedUrl + '", query: "/rss/channel/item", XmlRole { name: "title"; query: "title/string()" }, XmlRole { name: "link"; query: "link/string()" }, XmlRole { name: "description"; query: "description/string()" } }', widget);
        feedsModel.append({
            "feedModel": xmlListModel
        });
    }

    Plasmoid.icon: 'starred-symbolic'
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    // ListModel to hold multiple XmlListModel's
    ListModel {
        id: feedsModel
    }

   Plasmoid.fullRepresentation: Item {
    id: fullRepresentation

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
                //color: PlasmaComponents.Theme.textColor
                //font: PlasmaComponents.Theme.defaultFont

                id: label

                text: i18n("Currently showing ______ feeds")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

        }

        ListView {
            id: feedsListView

            model: feedsModel
            Layout.fillWidth: true
            Layout.fillHeight: true

            delegate: ListView {
                model: model.feedModel
                width: parent.width
                height: widget.itemHeight * model.feedModel.count

                delegate: Text {
                    text: model.title + "\n" + model.description
                    width: parent.width
                    height: widget.itemHeight
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

                } // Close TextField

                PlasmaComponents.Button {
                    id: addUrlButton

                    text: "Add"
                    onClicked: {
                        addFeed(dialogUrlField.text); // Add a new feed when the button is clicked
                        newRSS.visible = false;
                    }
                }

            } // Close RowLayout

        } // Close Popup

    } // Close Plasmoid.fullRepresentation

} // Close Item