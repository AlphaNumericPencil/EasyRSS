#!/bin/sh

DIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
plasmoidName=`kreadconfig5 --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Name"`
widgetName="${plasmoidName##*.}" # Strip namespace
website=`kreadconfig5 --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Website"`
bugAddress="$website"
packageRoot=".." # Root of translatable sources
projectName="plasma_applet_${plasmoidName}" # project name

#---
if [ -z "$plasmoidName" ]; then
    echo "[merge] Error: Couldn't read plasmoidName."
    exit
fi

#---
echo "[merge] Extracting messages"
find "${packageRoot}" -name '*.cpp' -o -name '*.h' -o -name '*.c' -o -name '*.qml' -o -name '*.js' | sort > "${DIR}/infiles.list"

xgettext \
    --files-from=infiles.list \
    --from-code=UTF-8 \
    --width=400 \
    --add-location=file \
    -C -kde -ci18n -ki18n:1 -ki18nc:1c,2 -ki18np:1,2 -ki18ncp:1c,2,3 -ktr2i18n:1 -kI18N_NOOP:1 \
    -kI18N_NOOP2:1c,2  -kN_:1 -kaliasLocale -kki18n:1 -kki18nc:1c,2 -kki18np:1,2 -kki18ncp:1c,2,3 \
    --package-name="${widgetName}" \
    --msgid-bugs-address="${bugAddress}" \
    -D "${packageRoot}" \
    -D "${DIR}" \
    -o "template.pot.new" \
    || \
    { echo "[merge] error while calling xgettext. aborting."; exit 1; }

sed -i 's/"Content-Type: text\/plain; charset=CHARSET\\n"/"Content-Type: text\/plain; charset=UTF-8\\n"/' "template.pot.new"
sed -i 's/# SOME DESCRIPTIVE TITLE./'"# Translation of ${widgetName} in LANGUAGE"'/' "template.pot.new"
sed -i 's/# Copyright (C) YEAR THE PACKAGE'"'"'S COPYRIGHT HOLDER/'"# Copyright (C) $(date +%Y)"'/' "template.pot.new"

if [ -f "template.pot" ]; then
    newPotDate=`grep "POT-Creation-Date:" template.pot.new | sed 's/.\{3\}$//'`
    oldPotDate=`grep "POT-Creation-Date:" template.pot | sed 's/.\{3\}$//'`
    sed -i 's/'"${newPotDate}"'/'"${oldPotDate}"'/' "template.pot.new"
    changes=`diff "template.pot" "template.pot.new"`
    if [ ! -z "$changes" ]; then
        # There's been changes
        sed -i 's/'"${oldPotDate}"'/'"${newPotDate}"'/' "template.pot.new"
        mv "template.pot.new" "template.pot"

        addedKeys=`echo "$changes" | grep "> msgid" | cut -c 9- | sort`
        removedKeys=`echo "$changes" | grep "< msgid" | cut -c 9- | sort`
        echo ""
        echo "Added Keys:"
        echo "$addedKeys"
        echo ""
        echo "Removed Keys:"
        echo "$removedKeys"
        echo ""

    else
        # No changes
        rm "template.pot.new"
    fi
else
    # template.pot didn't already exist
    mv "template.pot.new" "template.pot"
fi

rm "${DIR}/infiles.list"
echo "[merge] Done extracting messages"
