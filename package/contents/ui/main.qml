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

    function addPreset(presetFeeds, presetName) {
        presetsModel.append({
            "presetFeeds": presetFeeds,
            "presetName": presetName
        });
    }

    Plasmoid.icon: 'starred-symbolic'
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    // ListModel to hold multiple XmlListModel's
    ListModel {
        id: feedsModel
    }

    ListModel {
        id: presetsModel
    }

    Plasmoid.fullRepresentation: Item {
        id: fullRepresentation

        function addFeed(feedUrl, feedName) {
            var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { source: "' + feedUrl + '"; query: "/rss/channel/item"; XmlRole { name: "title"; query: "title/string()" } XmlRole { name: "link"; query: "link/string()" } XmlRole { name: "description"; query: "description/string()" } }', widget);
            console.log("Adding feed:", feedUrl, feedName, feed);
            feedsModel.append({
                "feedModel": feed,
                "feedName": feedName
            });
            console.log("FeedsModel count:", feedsModel.count);
        }

        Layout.minimumWidth: label.implicitWidth
        Layout.minimumHeight: label.implicitHeight
        Layout.preferredWidth: 1000 * PlasmaCore.Units.devicePixelRatio
        Layout.preferredHeight: 1000 * PlasmaCore.Units.devicePixelRatio

        ColumnLayout {
            id: columnLayout

            height: parent.height
            anchors.fill: parent
            spacing: 10

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

                ComboBox {
                    id: presetsComboBox

                    model: presetsModel
                    textRole: "presetName"
                    onCurrentIndexChanged: {
                        feedsListView.model = model[presetsComboBox.currentIndex].presetFeeds;
                    }
                }

            }

            ListView {
                id: feedsListView

                model: feedsModel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: parent.height - addFeedRow.height
                spacing: 10

                delegate: Item {
                    property var feedModel: model ? model.feedModel : null

                    width: parent.width
                    height: contentItem.implicitHeight // Set Item height based on the ColumnLayout's implicit height

                    ColumnLayout {
                        id: contentItem

                        width: parent.width
                        spacing: 500 // Added this line to include spacing between items
                        height: 500 

                        Repeater {
                            id: repeater

                            model: feedModel && feedModel.status === XmlListModel.Ready ? feedModel : []

                            delegate: Kirigami.Card {
                                width: parent.width

                                Column {
                                    width: parent.width
                                    height: parent.height

                                    PlasmaComponents.Label {
                                        id: titleText

                                        text: model.title
                                        width: parent.width // Set width to the parent's width
                                        wrapMode: Text.WordWrap // Set word wrapping
                                    }

                                    PlasmaComponents.Label {
                                        id: descriptionText

                                        text: model.description
                                        width: parent.width // Set width to the parent's width
                                        wrapMode: Text.WordWrap // Set word wrapping
                                        verticalAlignment: Text.AlignVCenter // Set vertical alignment
                                    }

                                }

                            }

                        }

                    }

                }

            }

            Text {
                text: feedsModel.count === 0 ? i18n("Add a feed!") : "" // Show "Add a feed!" message if the list is empty
                font.bold: true
                font.pointSize: 14
                color: "black" // Provide a fallback color
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                visible: feedsModel.count === 0
            }

        }

        Popup {
            id: newRSS

            height: 100
            width: 500
            x: (parent.width - width) / 2 // This will position the Popup in the center of the parent Item horizontally
            y: (parent.height - height) / 2 // This will position the Popup in the center of the parent Item vertically
            visible: false

            RowLayout {
                anchors.fill: parent
                spacing: 0

                ColumnLayout {
                    TextField {
                        //Layout.preferredWidth

                        id: dialogNameField

                        placeholderText: "Enter Feed Name"
                    }

                    TextField {
                        //Layout.preferredWidth: parent.width * 0.7

                        id: dialogUrlField

                        placeholderText: "Enter RSS feed URL"
                    }

                }

                PlasmaComponents.Button {
                    id: addUrlButton

                    text: "Add"
                    onClicked: {
                        fullRepresentation.addFeed(dialogUrlField.text, dialogNameField.text); // Add a new feed when the button is clicked
                        newRSS.visible = false;
                    }
                }

            }

        }

        Popup {
            // ... Dimensions and position ...
            //haha funny new comment
            id: newPreset

            RowLayout {
                anchors.fill: parent
                spacing: 0

                ComboBox {
                    id: presetFeedsComboBox

                    model: feedsModel
                    textRole: "feedName"
                }

                TextField {
                    id: presetNameField

                    placeholderText: "Enter Preset Name"
                }

                PlasmaComponents.Button {
                    id: addPresetButton

                    text: "Add"
                    onClicked: {
                        fullRepresentation.addPreset(presetFeedsComboBox.selectedItems, presetNameField.text);
                        newPreset.visible = false;
                    }
                }

            }

        }

    }

}
