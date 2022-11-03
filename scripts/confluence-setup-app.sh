#!/usr/bin/env bash

# Version Selection
VERSION=$( zenity  --title "Select Confluence Version" --list --ok-label "Submit" --cancel-label "I wanna set my own" \
                    --column="Confluence Version" \
                     "7.20.1" \
                     "7.20.0" \
                     "7.19.2" \
                     "7.19.1" \
                     "7.19.0" \
                     "7.18.3" \
                     "7.18.2" \
                     "7.18.1" \
                     "7.18.0" \
                     "7.17.5" \
                     "7.17.4" \
                     "7.17.3" \
                     "7.17.2" \
                     "7.17.1" \
                     "7.17.0" \
                     "7.16.5" \
                     "7.16.4" \
                     "7.16.3" \
                     "7.16.2" \
                     "7.16.1" \
                     "7.16.0" \
                     "7.15.3" \
                     "7.15.2" \
                     "7.15.1" \
                     "7.15.0" \
                     "7.14.4" \
                     "7.14.3" \
                     "7.14.2" \
                     "7.14.1" \
                     "7.14.0" \
                     "7.13.11"\
                     "7.13.9" \
                     "7.13.8" \
                     "7.13.7" \
                     "7.13.6" \
                     "7.13.5" \
                     "7.13.4" \
                     "7.13.3" \
                     "7.13.2" \
                     "7.13.1" \
                     "7.13.0" \
                     "7.12.5" \
                     "7.12.4" \
                     "7.12.3" \
                     "7.12.2" \
                     "7.12.1" \
                     "7.12.0" \
                     "7.11.6" \
                     "7.11.3" \
                     "7.11.2" \
                     "7.11.1" \
                     "7.11.0" \
                     "7.10.2" \
                     "7.10.1" \
                     "7.10.0" \
                     "7.9.3" \
                     "7.9.1" \
                     "7.9.0" \
                     )

if [ $? = 0 ] && [ -n "$VERSION" ] # check if ok or cancel clicked or var is empty
then
    VERSION_FLAG="-v $VERSION"
    echo "Selected version is: $VERSION"
else
    # Manual Version Selection
    VERSION=$( zenity  --title "Select Confluence Version" --entry --text "Introduce a valid Confluence version in the 'x.y.z' format:" --ok-label "Submit" --cancel-label "Set default 7.9.0 version")
    if [ $? = 0 ] && [ -n "$VERSION" ] # check if ok or cancel clicked or var is empty
    then
        VERSION_FLAG="-v $VERSION"
        echo "Selected version is: $VERSION"
    else
        VERSION_FLAG="-v 7.9.0"
        echo "Default version will be used"
    fi
fi

# Custom Name
ALIAS=$( zenity  --title "Select an Alias" --entry --text "Set a name to your Confluence (e.g. 'testing1') to easily identify it (one word only without special characters):" --ok-label "Submit" --cancel-label "Ignore")

if [ $? = 0 ] && [ -n "$ALIAS" ] # check if ok or cancel clicked or var is empty
then
    ALIAS_FLAG="-a $ALIAS"
    echo "Selected alias: $ALIAS"
else
    ALIAS_FLAG=""
    echo "No alias selected"
fi

# Confluence Setup
zenity --title "Confluence Set up" --question --text "Would you like to get your Confluence automatically set up? This includes the following main steps: License setup, Database configuration, Admin user configuration, Disabling on boarding module, User directory configuration" --ok-label "Yes" --cancel-label "No"

if [ $? = 0 ] # check if ok or cancel clicked
then
    ENV_FLAG="-e"
    ENV_FLAG="$ENV_FLAG PPTR_LDAP_CONFIG=true"
    echo "Confluence set up selected"

    LICENSE=$( zenity  --title "Confluence License" --entry --text "Provide a valid Confluence license. It can either be a Server or DC license. If none is provided the default Atlassian 3h DC timebomb license will be used" --ok-label "Submit license" --cancel-label "Use default")

    if [ $? = 0 ] && [ -n "$LICENSE" ] # check if ok or cancel clicked or var is empty
    then
        ENV_FLAG="$ENV_FLAG PPTR_CONFLUENCE_LICENSE=$LICENSE"
        echo "Provided Confluence license: $LICENSE"
    else
        echo "No Confluence license provided, default will be used"
    fi

    COMMAND="${BASH_SOURCE%/*}/run-confluence-container.sh $VERSION_FLAG $ALIAS_FLAG $ENV_FLAG"

else
    echo "Confluence set up not chosen"

    COMMAND="${BASH_SOURCE%/*}/run-confluence-container-no-setup.sh $VERSION_FLAG $ALIAS_FLAG"
fi


# Confirmation
CONFIRMATION=$(zenity --title "Configuration Ready" --question --text "Everything ready, your Confluence will be started, running the following command, do you wish to proceed? $COMMAND" --ok-label "Start up Confluence" --cancel-label "Cancel")
if [ $? = 0 ] # check if ok or cancel clicked
then
  echo "command to run: $COMMAND"
  source $COMMAND
else
  echo "Confluence launch cancelled"
fi