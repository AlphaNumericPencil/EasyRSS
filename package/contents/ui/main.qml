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
    //property int itemHeight: 10 // Define the height for each item in the list

    id: widget

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
            // if the feedUrl is atom, handle it differently
            if (feedUrl.endsWith(".atom")) {
                var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { \
        source: "' + feedUrl + '"; \
        query: "/feed/entry"; \
        XmlRole { name: "title"; query: "title/string()" } \
        XmlRole { name: "link"; query: "link/@href/string()" } \
        XmlRole { name: "description"; query: "summary/string()" } \
    }', widget);
                console.log("Adding feed:", feedUrl, feedName, feed);
                feedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                console.log("FeedsModel count:", feedsModel.count);
                return ;
            } else if (feedUrl.endsWith(".rss")) {
                var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { \
                source: "' + feedUrl + '"; \
                query: "/rss/channel/item"; \
                XmlRole { name: "title"; query: "title/string()" } \
                XmlRole { name: "link"; query: "link/string()" } \
                XmlRole { name: "description"; query: "description/string()" } \
            }', widget);
                console.log("Adding feed:", feedUrl, feedName, feed);
                feedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                console.log("FeedsModel count:", feedsModel.count);
                return ;
            } else {
                var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { \
                source: "' + feedUrl + '"; \
                query: "/rss/channel/item"; \
                XmlRole { name: "title"; query: "title/string()" } \
                XmlRole { name: "link"; query: "link/string()" } \
                XmlRole { name: "description"; query: "description/string()" } \
            }', widget);
                console.log("Adding feed:", feedUrl, feedName, feed);
                feedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                console.log("FeedsModel count:", feedsModel.count);
                return ;
            }
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

                PlasmaComponents.Button {
                    id: addPresetButton

                    text: "+"
                    onClicked: {
                        newPreset.visible = true;
                    }
                }

                ComboBox {
                    id: presetsComboBox

                    model: presetsModel
                    textRole: i18n("presetName")
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
                    height: contentItem.implicitHeight

                    ColumnLayout {
                        id: contentItem

                        width: parent.width
                        height: parent.height
                        spacing: 175

                        Repeater {
                            id: repeater

                            model: feedModel

                            delegate: Kirigami.Card {
                                width: parent.width
                                visible: feedModel.status === XmlListModel.Ready // Only display the card when the feed model is ready

                                MouseArea {
                                    id: cardMouseArea

                                    property bool isScrolling: false
                                    property real startX

                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onPressed: {
                                        isScrolling = false;
                                        startX = mouse.x;
                                    }
                                    onPositionChanged: {
                                        if (Math.abs(mouse.x - startX) > 10)
                                            isScrolling = true;

                                    }
                                }

                                Column {
                                    width: parent.width
                                    height: parent.height

                                    PlasmaComponents.Label {
                                        //spacing: 10

                                        id: titleText

                                        font.bold: true
                                        font.pointSize: 14
                                        text: model.title
                                        width: parent.width // Set width to the parent's width
                                        wrapMode: Text.WordWrap // Set word wrapping
                                    }

                                    PlasmaComponents.Label {
                                        //verticalAlignment: Text.AlignVCenter // Set vertical alignment
                                        //spacing: 10

                                        id: descriptionText

                                        height: implicitHeight
                                        text: model.description
                                        width: parent.width // Set width to the parent's width
                                        wrapMode: Text.WordWrap // Set word wrapping
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
            id: newPreset

            x: (parent.width - width) / 2 // This will position the Popup in the center of the parent Item horizontally
            y: (parent.height - height) / 2 // This will position the Popup in the center of the parent Item vertically
            visible: false

            ColumnLayout {
                spacing: 100

                PlasmaComponents.Label {
                    id: newPresetLabel

                    text: "Create a new preset by selecting your desired feeds, and entering a name."
                    width: parent.width // Set width to the parent's width
                    verticalAlignment: Text.AlignVCenter
                }

                // List of checkboxes for each feed
                ListView {
                    id: feedCheckboxesList

                    model: feedsModel
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    delegate: RowLayout {
                        spacing: 500

                        CheckBox {
                            id: feedCheckbox

                            text: model.feedName
                            checked: false // by default, none of the feeds are included in the new preset
                            onCheckedChanged: {
                                // Add or remove the feed from the preset when the checkbox is checked or unchecked
                                if (checked) {
                                    presetFeedsList.append(feedModel);
                                } else {
                                    for (var i = 0; i < presetFeedsList.length; i++) {
                                        if (presetFeedsList[i] === feedModel) {
                                            presetFeedsList.splice(i, 1);
                                            break;
                                        }
                                    }
                                }
                            }
                        }

                    }

                }

                RowLayout {
                    id: presetRow

                    TextField {
                        id: presetNameField

                        placeholderText: "Enter Preset Name"
                    }

                    PlasmaComponents.Button {
                        id: confirmAddPresetButton

                        text: "Add"
                        onClicked: {
                            fullRepresentation.addPreset(presetFeedsList, presetNameField.text);
                            newPreset.visible = false;
                        }
                    }

                }

            }

        }

    }

}
