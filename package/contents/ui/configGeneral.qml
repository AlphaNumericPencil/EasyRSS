// // All the checkboxes and textboxes for settings.

// import QtQuick 2.0
// import QtQuick.Controls 2.5 as QQC2
// import org.kde.kirigami 2.4 as Kirigami

// Kirigami.FormLayout {  //Launch in the center of the page
//     id: page
  
// //   By default, all values are copied to the top level Item of the file prefixed with cfg_ like page.cfg_variableName. 
// //   This is so the user can hit discard or apply the changes. You will need to define each cfg_ property 
// //   so you can bind the value with a QML control.

//     property alias cfg_showLabel: showLabel.checked
//     property alias cfg_showIcon: showIcon.checked
//     property alias cfg_labelText: labelText.text

//     QQC2.CheckBox {
//         id: showLabel
//         Kirigami.FormData.label: i18n("Section:")
//         text: i18n("Show label")
//     }
//     QQC2.CheckBox {
//         id: showIcon
//         text: i18n("Show icon")
//     }
//     QQC2.TextField {
//         id: labelText
//         Kirigami.FormData.label: i18n("Label:")
//         placeholderText: i18n("Placeholder")
//     }
// }

/*
    SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.ksvg 1.0 as KSvg
import org.kde.iconthemes as KIconThemes
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM
import org.kde.config as KConfig

import "code/tools.js" as Tools

ColumnLayout {

    property string cfg_menuLabel: menuLabel.text
    property string cfg_icon: plasmoid.configuration.icon
    property int cfg_favoritesDisplay: plasmoid.configuration.favoritesDisplay
    property int cfg_applicationsDisplay: plasmoid.configuration.applicationsDisplay
    property alias cfg_alphaSort: alphaSort.checked
    property var cfg_systemFavorites: String(plasmoid.configuration.systemFavorites)
    property int cfg_primaryActions: plasmoid.configuration.primaryActions
    property alias cfg_showActionButtonCaptions: showActionButtonCaptions.checked
    property alias cfg_compactMode: compactModeCheckbox.checked

    Kirigami.FormLayout {
        Button {
            id: iconButton

            Kirigami.FormData.label: i18n("Icon:")

            implicitWidth: previewFrame.width + Kirigami.Units.smallSpacing * 2
            implicitHeight: previewFrame.height + Kirigami.Units.smallSpacing * 2
            hoverEnabled: true

            Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
            Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_icon)
            Accessible.role: Accessible.ButtonMenu

            ToolTip.delay: Kirigami.Units.toolTipDelay
            ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_icon)
            ToolTip.visible: iconButton.hovered && cfg_icon.length > 0

            KIconThemes.IconDialog {
                id: iconDialog
                onIconNameChanged: cfg_icon = iconName || Tools.defaultIconName
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: plasmoid.formFactor === PlasmaCore.Types.Vertical || plasmoid.formFactor === PlasmaCore.Types.Horizontal
                        ? "widgets/panel-background" : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

                PlasmaCore.IconItem {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: Tools.iconOrDefault(plasmoid.formFactor, cfg_icon)
                }
            }

            Menu {
                id: iconMenu

                // Appear below the button
                y: +parent.height

                MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                    onClicked: iconDialog.open()
                }
                MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                    icon.name: "edit-clear"
                    enabled: cfg_icon !== Tools.defaultIconName
                    onClicked: cfg_icon = Tools.defaultIconName
                }
                MenuItem {
                    text: i18nc("@action:inmenu", "Remove icon")
                    icon.name: "delete"
                    enabled: cfg_icon !== "" && menuLabel.text && plasmoid.formFactor !== PlasmaCore.Types.Vertical
                    onClicked: cfg_icon = ""
                }
            }
        }

        Kirigami.ActionTextField {
            id: menuLabel
            enabled: plasmoid.formFactor !== PlasmaCore.Types.Vertical
            Kirigami.FormData.label: i18nc("@label:textbox", "Text label:")
            text: plasmoid.configuration.menuLabel
            placeholderText: i18nc("@info:placeholder", "Type here to add a text label")
            onTextEdited: {
                cfg_menuLabel = menuLabel.text

                // This is to make sure that we always have a icon if there is no text.
                // If the user remove the icon and remove the text, without this, we'll have no icon and no text.
                // This is to force the icon to be there.
                if (!menuLabel.text) {
                    cfg_icon = cfg_icon || Tools.defaultIconName
                }
            }
            rightActions: [
                Action {
                    icon.name: "edit-clear"
                    enabled: menuLabel.text !== ""
                    text: i18nc("@action:button", "Reset menu label")
                    onTriggered: {
                        menuLabel.clear()
                        cfg_menuLabel = ''
                        cfg_icon = cfg_icon || Tools.defaultIconName
                    }
                }
            ]
        }

        Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            visible: plasmoid.formFactor === PlasmaCore.Types.Vertical
            text: i18nc("@info", "A text label cannot be set when the Panel is vertical.")
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: alphaSort
            Kirigami.FormData.label: i18nc("General options", "General:")
            text: i18n("Always sort applications alphabetically")
        }

        CheckBox {
            id: compactModeCheckbox
            text: i18n("Use compact list item style")
            checked: Kirigami.Settings.tabletMode ? true : plasmoid.configuration.compactMode
            enabled: !Kirigami.Settings.tabletMode
        }
        Label {
            visible: Kirigami.Settings.tabletMode
            text: i18nc("@info:usagetip under a checkbox when Touch Mode is on", "Automatically disabled when in Touch Mode")
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
        }

        Button {
            enabled: KConfig.KAuthorized.authorizeControlModule("kcm_plasmasearch")
            icon.name: "settings-configure"
            text: i18nc("@action:button", "Configure Enabled Search Plugins…")
            onClicked: KCM.KCMLauncher.openSystemSettings("kcm_plasmasearch")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RadioButton {
            id: showFavoritesInGrid
            Kirigami.FormData.label: i18n("Show favorites:")
            text: i18nc("Part of a sentence: 'Show favorites in a grid'", "In a grid")
            ButtonGroup.group: favoritesDisplayGroup
            property int index: 0
            checked: plasmoid.configuration.favoritesDisplay === index
        }

        RadioButton {
            id: showFavoritesInList
            text: i18nc("Part of a sentence: 'Show favorites in a list'", "In a list")
            ButtonGroup.group: favoritesDisplayGroup
            property int index: 1
            checked: plasmoid.configuration.favoritesDisplay === index
        }

        RadioButton {
            id: showAppsInGrid
            Kirigami.FormData.label: i18n("Show other applications:")
            text: i18nc("Part of a sentence: 'Show other applications in a grid'", "In a grid")
            ButtonGroup.group: applicationsDisplayGroup
            property int index: 0
            checked: plasmoid.configuration.applicationsDisplay === index
        }

        RadioButton {
            id: showAppsInList
            text: i18nc("Part of a sentence: 'Show other applications in a list'", "In a list")
            ButtonGroup.group: applicationsDisplayGroup
            property int index: 1
            checked: plasmoid.configuration.applicationsDisplay === index
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RadioButton {
            id: powerActionsButton
            Kirigami.FormData.label: i18n("Show buttons for:")
            text: i18n("Power")
            ButtonGroup.group: radioGroup
            property string actions: "suspend,hibernate,reboot,shutdown"
            property int index: 0
            checked: plasmoid.configuration.primaryActions === index
        }

        RadioButton {
            id: sessionActionsButton
            text: i18n("Session")
            ButtonGroup.group: radioGroup
            property string actions: "lock-screen,logout,save-session,switch-user"
            property int index: 1
            checked: plasmoid.configuration.primaryActions === index
        }

        RadioButton {
            id: allActionsButton
            text: i18n("Power and session")
            ButtonGroup.group: radioGroup
            property string actions: "lock-screen,logout,save-session,switch-user,suspend,hibernate,reboot,shutdown"
            property int index: 3
            checked: plasmoid.configuration.primaryActions === index
        }

        CheckBox {
            id: showActionButtonCaptions
            text: i18n("Show action button captions")
        }
    }

    ButtonGroup {
        id: favoritesDisplayGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_favoritesDisplay = checkedButton.index
            }
        }
    }

    ButtonGroup {
        id: applicationsDisplayGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_applicationsDisplay = checkedButton.index
            }
        }
    }

    ButtonGroup {
        id: radioGroup
        onCheckedButtonChanged: {
            if (checkedButton) {
                cfg_primaryActions = checkedButton.index
                cfg_systemFavorites = checkedButton.actions
            }
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
