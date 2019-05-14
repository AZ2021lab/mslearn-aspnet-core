# Downloads and installs sqlite3 command-line shell in the Cloud Shell

# Depends on gitBranch variable
if ! [ -z ${gitBranch+x} ]; then
    echo "${errorStyle}\$gitBranch is not set."
    return 0;
fi

declare sqlitePath=~/.sqlite3
declare sqliteUrl=https://raw.githubusercontent.com/MicrosoftDocs/mslearn-aspnet-core/$gitBranch/infrastructure/binaries/sqlite3
echo "${newline}${headingStyle}Installing SQLite3 command-line shell...${newline}${defaultTextStyle}"
# Bug out if it's already installed
if [ -d "${sqlitePath}" ]; then
    if [ -f "${sqlitePath}/sqlite3" ]; then
        echo "${warningStyle}SQLite3 command-line shell already installed."
        return 1;
    fi
fi

# Download and install the binary
mkdir $sqlitePath
wget -q -O $sqlitePath/sqlite3 $sqliteUrl
chmod +x $sqlitePath/sqlite3

# Resource file (default values)
if ! [ -f "~/.sqliterc" ]; then
    echo ".mode columns" > ~/.sqliterc
    echo ".headers on" >> ~/.sqliterc
    echo ".nullvalue NULL" >> ~/.sqliterc
fi

# Add the path
if ! [ $(echo $PATH | grep $sqlitePath) ]; then 
    export PATH=$PATH:$sqlitePath
    echo "# SQLite 3 CLI tool path" >> ~/.bashrc
    echo "export PATH=\$PATH:$sqlitePath" >> ~/.bashrc
fi
echo