#!/bin/bash

# Hi!
# If you're reading this, you're probably interested in what's 
# going on within this script. We've provided what we hope are useful
# comments inline, as well as color-coded relevant shell output.
# We hope it's useful for you, but if you have any questions or suggestions
# please open an issue on https:/github.com/MicrosoftDocs/learn-aspnet-core.
#

## Start

# Module name
declare moduleName="secure-aspnet-core-identity"

# dotnet SDK version
declare -x dotnetSdkVersion="2.2.204"

# Any other declarations we need
declare -x gitBranch="authentication-stuff"
declare initScript=https://raw.githubusercontent.com/MicrosoftDocs/mslearn-aspnet-core/$gitBranch/infrastructure/scripts/initenvironment.sh
declare -x projectRootDirectory="ContosoPets.Api"

# If the script appears to have already been run, just set the vars and leave.
declare variableScript='variables.sh'
if [ -e ~/$variableScript ]
then
    . ~/$variableScript
    return 1
fi


# Write variables script
writeVariablesScript() {
    text="#!/bin/bash${newline}"
    text+="declare srcWorkingDirectory=$srcWorkingDirectory${newline}"
    text+="declare setupWorkingDirectory=$setupWorkingDirectory${newline}"
    text+="declare resourceGroupName=$resourceGroupName${newline}"
    text+="declare sqlServerName=$sqlServerName${newline}"
    text+="declare sqlHostName=$sqlHostName${newline}"
    text+="declare sqlUsername=$sqlUsername@$sqlServerName${newline}"
    text+="declare sqlPassword=$sqlPassword${newline}"
    text+="declare databaseName=$databaseName${newline}"
    text+="declare sqlConnectionString=\"$sqlConnectionString\"${newline}"
    text+="declare resourceGroupName=$resourceGroupName${newline}"
    text+="declare subscriptionId=$subscriptionId${newline}"
    text+="echo \"${headingStyle}The following variables are used in this module:\"${newline}"
    text+="echo \"${headingStyle}srcWorkingDirectory: ${defaultTextStyle}$srcWorkingDirectory\"${newline}"
    text+="echo \"${headingStyle}sqlConnectionString: ${defaultTextStyle}$sqlConnectionString\"${newline}"
    text+="echo \"${headingStyle}sqlUsername: ${defaultTextStyle}$sqlUsername\"${newline}"
    text+="echo \"${headingStyle}sqlPassword: ${defaultTextStyle}$sqlPassword\"${newline}"
    text+="if ! [ \$(echo \$PATH | grep ~/.dotnet/tools) ]; then export PATH=\$PATH:~/.dotnet/tools; fi${newline}"
    text+="echo ${newline}"
    text+="cd $srcWorkingDirectory/$projectRootDirectory${newline}"
    text+="code ..${newline}"
    echo "$text" > ~/$variableScript
    chmod +x ~/$variableScript
}

# Grab and run initenvironment.sh
. <(wget -q -O - $initScript)

# Download and build
downloadAndBuild

# Provision stuff here
setAzureCliDefaults
provisionResourceGroup

declare -x $webPlanName = plan$instanceId
(
set -x
az appservice plan create --name $webPlanName --sku D1
)

# API web app
declare -x webAppName=apiapp$instanceId
declare -x projectRootDirectory="ContosoPets.Api"
declare -x webAppLabel="Products Web API"
provisionAppService &

# UI web app
declare -x webAppName=webapp$instanceId
declare -x projectRootDirectory="ContosoPets.Ui"
declare -x webAppLabel="Products Web UI"
provisionAppService &

provisionAzSqlDatabase &
wait &>/dev/null

# Clean up
writeVariablesScript
addVariablesToStartup
resetAzureCliDefaults

# Switch to working directory and launch Cloud Shell Editor
# Open the parent directory in the file explorer
cd $srcWorkingDirectory/$projectRootDirectory
code .. 

# We're done! Summarize.
summarize

# Run the variables script to make sure everything is as expected
. ~/$variableScript
