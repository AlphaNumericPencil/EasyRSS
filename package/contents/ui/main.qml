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

    //property var presetsModel // A list to store the presets
    property var presetFeedsList: [] // A list to store the feeds in the current preset
    property string atomNamespace: "http://www.w3.org/2005/Atom"
    property string currentPreset: "All"
    property var articlesModel // A list to store the articles to be shown in the card listview
   
   //ListModel for current feeds
    ListModel {
        id: feedsModel
    }

//  ListModel for all feeds
    ListModel {
        id: allFeedsModel
    }

    // ListModel for presets
    ListModel {
        id: presetsModel
    }

    //This function will sort articles into the card listview based on the date and which preset is chosen
    function sortArticles(rssList) {
        // Clear the list of articles from the repea
        //feedsListView.clear();
        
        // If the current preset is "All", show all articles using the repeater
        if (currentPreset === "All") {
            // set feedsModel as the model for the feedsListView
            rssList.model = allFeedsModel;
            //refresh the listview
        } else {
            rssList.model = feedsModel;
            //feedsListView.model = feedsModel;
        }
        //add 
    }
    
    function isAtomFeed(feedUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", feedUrl, false);
        request.send();
        var xmlContent = request.responseText;
        if (xmlContent.includes('xmlns="')) {
            // Extract the xmlns field from the atom feed
            var startIndex = xmlContent.indexOf('xmlns="') + 7;
            var endIndex = xmlContent.indexOf('"', startIndex);
            var atomNamespace = xmlContent.slice(startIndex, endIndex);
            // Set the atomNamespace as the default element namespace
            XmlListModel.defaultElementNamespace = atomNamespace;
            return true;
        }
        return false;
    }

    function addPreset(presetFeeds, presetName) { 
        var presetFeedModels = [];
        for (var i = 0; i < presetFeeds.length; i++) {
            presetFeedModels.push(presetFeeds[i].feedModel);
        }
        presetsModel.insert(presetFeeds.length-1, {
            "presetFeeds": presetFeedModels,
            "presetName": presetName
        });
    }

    function removePreset(presetName) {
        for (var i = 0; i < presetsModel.count; i++) {
            if (presetsModel.get(i).presetName === presetName) {
                presetsModel.remove(i);
                break;
            }
        }
    }



    Plasmoid.icon: "preferences-web-feed-reader"
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

 
    Plasmoid.fullRepresentation: Item {
        id: fullRepresentation

        function addFeed(feedUrl, feedName) {
            // if the feedUrl is atom, handle it differently
            if (isAtomFeed(feedUrl)) {
                var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { \
                source: "' + feedUrl + '"; \
                namespaceDeclarations: "declare default element namespace \'' + atomNamespace + '\';"; \
                query: "/feed/entry"; \
                XmlRole { name: "title"; query: "title/string()" } \
                    XmlRole { name: "link"; query: "link/@href/string()" } \
                        XmlRole { name: "description"; query: "summary/string()" } \
                            XmlRole { name: "date"; query: "published/string()" } \
                                XmlRole { name: "author"; query: "author/name/string()" } \
                                XmlRole { name: "content"; query: "content/string()" } \
                                XmlRole { name: "thumbnail"; query: "media:thumbnail/@url/string()" } \
                                }', widget);
                                
                console.log("Adding feed:", feedUrl, feedName, feed);
                feedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                allFeedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                console.log("FeedsModel count:", allFeedsModel.count);
                return ;
            } else if (feedUrl.endsWith(".rss")) {
                var feed = Qt.createQmlObject('import QtQuick.XmlListModel 2.0; XmlListModel { \
                        source: "' + feedUrl + '"; \
                        query: "/rss/channel/item"; \
                        XmlRole { name: "title"; query: "title/string()" } \
                            XmlRole { name: "link"; query: "link/string()" } \
                                XmlRole { name: "description"; query: "description/string()" } \
                                    XmlRole { name: "date"; query: "pubDate/string()" } \
                                        XmlRole { name: "author"; query: "author/string()" } \
                                        }', widget);
                console.log("Adding feed:", feedUrl, feedName, feed);
                feedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                allFeedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                console.log("FeedsModel count:", allFeedsModel.count);
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
                allFeedsModel.append({
                    "feedModel": feed,
                    "feedName": feedName
                });
                console.log("FeedsModel count:", allFeedsModel.count);
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
                //When we're done making a new preset button, make a new "All" preset by default.
                Component.onCompleted: {
            addPreset(feedsModel, "All");
        }

                ComboBox {
                    id: presetsComboBox

                    height: addFeedButton.height
                    model: presetsModel
                    textRole: "presetName"
                    //Set All to be the default preset
                    currentIndex: 0

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < presetsModel.count) {
                            
                            // Provide the feed name here, as it is not available in the preset
                            var preset = presetsModel.get(currentIndex);
                            var presetFeeds = preset.presetFeeds;
                            feedsModel.clear();
                            for (var i = 0; i < presetFeeds.length; i++) {
                                feedsModel.append({
                                    "feedModel": presetFeeds[i],
                                    "feedName": ""
                                });
                            }
                        }
                    }
                }

            }

            ListView {
                id: feedsListView

                model: allFeedsModel
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: parent.height - addFeedRow.height
                spacing: 10

                delegate: Item {
                    property var feedModel: model ? model.feedModel : null

                    width: contentItem.implicitHeight //parent.width
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
                                height: parent.height
                                visible: feedModel.count > 0 // Only display the card when the feed model has data
                                showClickFeedback: true

                                MouseArea {
                                    id: cardMouseArea

                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onClicked: {
                                        // Open the URL of the article when the card is clicked
                                        Qt.openUrlExternally(model.link);
                                    }
                                }

                                Column {
                                    width: parent.width
                                    height: parent.height

                                    RowLayout {
                                        PlasmaComponents.Label {
                                            id: titleText

                                            font.bold: true
                                            font.pointSize: 14
                                            text: model.title
                                            width: parent.width // Set width to the parent's width
                                            wrapMode: Text.WordWrap // Set word wrapping

                                            MouseArea {
                                                id: cardMouseArea2

                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                hoverEnabled: true
                                                onClicked: {
                                                    // Open the URL of the article when the card is clicked
                                                    Qt.openUrlExternally(model.link);
                                                }
                                            }

                                        }

                                        PlasmaComponents.Label {
                                            id: authorText

                                            text: model.author ? model.author : "No author given"
                                            width: parent.width
                                        }

                                    }

                                    PlasmaComponents.Label {
                                        id: dateText

                                        text: model.date ? model.date : "No date given"
                                        width: parent.width
                                    }

                                    PlasmaComponents.Label {
                                        id: descriptionText

                                        height: implicitHeight
                                        text: model.description
                                        width: parent.width // Set width to the parent's width
                                        wrapMode: Text.WordWrap // Set word wrapping

                                        //verticalAlignment: Text.AlignVCenter // Set vertical alignment
                                        //spacing: 10
                                        MouseArea {
                                            id: cardMouseArea3

                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            hoverEnabled: true
                                            onClicked: {
                                                // Open the URL of the article when the card is clicked
                                                Qt.openUrlExternally(model.link);
                                            }
                                        }

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
                        dialogUrlField.remove(0, dialogUrlField.length);
                        dialogNameField.remove(0, dialogNameField.length);
                    }
                }

            }

        }

        Popup {
            id: newPreset

            height: 900
            width: 600
            x: (parent.width - width) / 2 // This will position the Popup in the center of the parent Item horizontally
            y: (parent.height - height) / 2 // This will position the Popup in the center of the parent Item vertically
            visible: false

            ColumnLayout {
                spacing: 50

                PlasmaComponents.Label {
                    id: newPresetLabel

                    text: "Create a new preset by selecting your desired feeds, and entering a name."
                    width: parent.width // Set width to the parent's width
                    verticalAlignment: Text.AlignVCenter
                }

                // List of checkboxes for each feed
                ListView {
                    id: feedCheckboxesList

                    model: allFeedsModel
                    Layout.fillWidth: true
                    height: 500 //Layout.fillHeight: true doesn't work for some reason
                    spacing: 10

                    delegate: CheckBox {
                        id: feedCheckbox

                        text: model.feedName
                        checked: false // by default, none of the feeds are included in the new preset
                        onCheckedChanged: {
                            // Add or remove the feed from the preset when the checkbox is checked or unchecked
                            if (checked) {
                                presetFeedsList.push({
                                    "feedModel": feedModel,
                                    "feedName": model.feedName
                                });
                            } else {
                                for (var i = 0; i < presetFeedsList.length; i++) {
                                    if (presetFeedsList[i].feedModel === feedModel) {
                                        presetFeedsList.splice(i, 1);
                                        break;
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
                            var selectedFeeds = [];
                            for (var i = 0; i < presetFeedsList.length; i++) {
                                selectedFeeds.push(presetFeedsList[i].feedModel);
                            }
                            for (var j = 0; j < feedsModel.count; j++) {
                                var feed = feedsModel.get(j);
                                if (!selectedFeeds.includes(feed.feedModel))
                                    selectedFeeds.push(feed.feedModel);

                            }
                            addPreset(selectedFeeds, presetNameField.text);
                            newPreset.visible = false;
                            presetNameField.remove(0, presetNameField.length);
                            sortArticles(feedsListView);
                        }
                    }

                }

            }

        }

    }

}
