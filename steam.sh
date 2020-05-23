#!/bin/sh
#-------------------------------------------------------------------------------
#-- External Steam Launch Option Config
#-- Mindi @ Mindinet.org
#-- GNU General Public License v3.0
#--
#-- Steam Launch Option usage:
#-- script/localtion/steam.sh %command%
#-- Example use:
#-- /home/mindi/.config/bspwm/scripts/steam.sh %command%
#--
#-- Dependencies:
#-- Mangohud: https://aur.archlinux.org/packages/mangohud/
#-- Feral Gamemode: https://aur.archlinux.org/packages/gamemode/
#-- Dunst (Optional for debug): https://www.archlinux.org/packages/community/x86_64/dunst/
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-- DEFAULT CONFIGS
#-------------------------------------------------------------------------------
HUD=1 # ENABLE MANGOHUD
GMD=0 # ENABLE FERAL GAMEMODE
NO_ESYNC=0 # DISABLE ESYNC
DEBUG=1 # DUNSTIFY DEBUG

#-------------------------------------------------------------------------------
#-- VAR INIT
#-------------------------------------------------------------------------------
WINECMD="$1"
STARTCMD="$2"
EXE="$3"
OPT=()

#-------------------------------------------------------------------------------
#-- FOLDER DETECTION
#-------------------------------------------------------------------------------
GAME=$(echo "$EXE" | grep -oP '(common\/).*?(?=\/)' | cut -d/ -f2-) # Games name from games folder used for custom settings for games
GAME_DIR=$(echo "$EXE" | grep -oP '(.*steamapps)') # Steam game dir
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # Scripts dir
LOG_FILE="${SCRIPT_DIR}/steam.log" # Log file localtion

if [ $DEBUG == 1 ]; then
    dunstify "Detected Game" "$GAME"
    echo "Game: $GAME" >> ${LOG_FILE}
    echo "Default: $@" >> ${LOG_FILE}
fi

#-------------------------------------------------------------------------------
#-- CUSTOM GAME SETTINGS & ENV VARS
#-------------------------------------------------------------------------------
if [ "$GAME" == "HITMAN2" ]; then
    HUD=1
    GMD=1
    
elif [ "$GAME" == "Mafia III" ]; then
    # Workaround to reset fullscreen mode to windowed on start because game can't start with it.
    echo "-1 -20 2560 1440 0 0 0 0 0" > '${GAME_DIR}/compatdata/360430/pfx/drive_c/users/steamuser/Local Settings/Application Data/2K Games/Mafia III/Saves/videoconfig.cfg'
    HUD=1
    GMD=1
    if [ $DEBUG == 1 ]; then
        echo "Script folder: ${DIR}" >> ${LOG_FILE}
    fi
    
elif [ "$GAME" == "KingdomComeDeliverance" ]; then
    HUD=1
    GMD=1
    
elif [ "$GAME" == "Yakuza Kiwami" ]; then
    HUD=1
    GMD=1
    NO_ESYNC=1
    
elif [ "$GAME" == "Homeworld" ]; then
    # Skipping broken homeworld lautcher.
    HomeWorld="0" #Select Game 1,2,r1,r2,0
    HomeWorldDir="${GAME_DIR}/common/Homeworld"
    # Game Select
    if [ $HomeWorld == "r1" ]; then
        EXE="$HomeWorldDir/HomeworldRM/Bin/Release/HomeworldRM.exe"
        OPT+=("-dlccampaign HW1Campaign.big")
        OPT+=("-campaign HomeworldClassic")
        OPT+=("-moviepath DataHW1Campaign")
        OPT+=("-windowed")
    elif [ $HomeWorld == "r2" ]; then
        EXE="$HomeWorldDir/HomeworldRM/Bin/Release/HomeworldRM.exe"
        OPT+=("-dlccampaign HW2Campaign.big")
        OPT+=("-campaign Ascension")
        OPT+=("-moviepath DataHW2Campaign")
        OPT+=("-windowed")
    elif [ $HomeWorld == "1" ]; then
        EXE="$HomeWorldDir/Homeworld1Classic/exe/Homeworld.exe"
        OPT+=("/noglddraw")
    elif [ $HomeWorld == "2" ]; then
        EXE="$HomeWorldDir/Homeworld2Classic/Bin/Release/Homeworld2.exe"
    fi
    HUD=1
    GMD=1
    NO_ESYNC=1
    # Run native if no game selected.
    if [ $HomeWorld != "0" ]; then
        PROTON_PATH="$(ls -d1 /mnt/games/SteamGames/steamapps/common/Proton\ 4.11/ |tail -1)"
        GAMEID=244160
        #WINECMD="${PROTON_PATH}dist/bin//wine64"
        #STARTCMD="start /unix"
        export WINEDEBUG="-all" 
        export WINEPREFIX="${GAME_DIR}/compatdata/${GAMEID}/pfx/" 
        export SteamGameId="${GAMEID}" 
        export SteamAppId="${GAMEID}" 
        export WINEDLLOVERRIDES="d3d11=n;dxgi=n" 
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="${HOME}/.steam/steam/" 
        if [ $DEBUG == 1 ]; then
            dunstify "$GAME" "Extra env vars enabled."
            echo "Game folder: ${GAME_DIR}" >> ${LOG_FILE}
        fi
    fi
fi

#-------------------------------------------------------------------------------
#-- WRAP UP
#-------------------------------------------------------------------------------
# Enabling Mangohud
if [ $HUD == 1 ]; then
    export MANGOHUD=1
    export MANGOHUD_CONFIG=cpu_temp,gpu_temp,ram=1,vram=1,frame_timing=0,core_load=0,font_size=19,background_alpha=0,toggle_hud=F10
    #export MANGOHUD_FONT=${SCRIPT_DIR}/steam-font.ttf
    #export MANGOHUD_OUTPUT=
    if [ $DEBUG == 1 ]; then
        dunstify "Mangohud" "Enabled."
    fi
fi
# Enabling Feral Game Mode
if [ $GMD == 1 ]; then
    GameMode="gamemoderun"
    if [ $DEBUG == 1 ]; then
        dunstify "Feral Game Mode" "Enabled."
    fi
fi
# Disabling Esync
if [ $NO_ESYNC == 1 ]; then
    export PROTON_NO_ESYNC=1
    if [ $DEBUG == 1 ]; then
        dunstify "Proton Esync" "Disabled."
    fi
fi

if [ $DEBUG == 1 ]; then
    echo "Result: $GameMode $WINECMD $STARTCMD $EXE ${OPT[@]}" >> ${LOG_FILE}
fi

# Run
$GameMode "$WINECMD" "$STARTCMD" "$EXE" "${OPT[@]}"
