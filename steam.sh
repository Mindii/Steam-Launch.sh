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
MANGO=cpu_temp,gpu_temp,ram=1,vram=1,frame_timing=0,core_load=0,font_size=19,background_alpha=0,toggle_hud=F10 # MANGOHUD DEFAULT CONFIGS
GMD=0 # ENABLE FERAL GAMEMODE
NO_ESYNC=0 # DISABLE ESYNC
DEBUG=1 # DUNSTIFY DEBUG

#-------------------------------------------------------------------------------
#-- VAR INIT & FOLDER DETECTION
#-------------------------------------------------------------------------------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # Scripts dir
LOG_FILE="${SCRIPT_DIR}/steam.log" # Log file localtion
WINECMD="$1"
STARTCMD="$2"
EXE="$3"
OPT=()
# Check if game is running on proton or is it native and set variables accordingly
if [[ $1 =~ "proton" ]]; then
    GAME_STATE="Proton"
    GAME=$(echo "$EXE" | grep -oP '(?<=common\/)(.*)(?=\/)') # Games name from games folder used for custom settings for games
    GAME_DIR=$(echo "$EXE" | grep -oP '(.*steamapps)') # Steam game dir
    if [ $DEBUG == 1 ]; then
        dunstify "Detected as" "Proton Game"
    fi
else
    GAME_STATE="Native"
    GAME=$(echo "$WINECMD" | grep -oP '(?<=common\/)(.*)(?=\/)') # Games name from games folder used for custom settings for games
    GAME_DIR=$(echo "$WINECMD" | grep -oP '(.*steamapps)') # Steam game dir
    if [ $DEBUG == 1 ]; then
        dunstify "Detected as" "Native Game"
    fi
fi
# Random debug check
if [ $DEBUG == 1 ]; then
    dunstify "Detected Game" "$GAME"
    echo "Game: $GAME" >> ${LOG_FILE}
    echo "Default: $@" >> ${LOG_FILE}
fi

#-------------------------------------------------------------------------------
#-- CUSTOM GAME SETTINGS & ENV VARS (ADD GAMES HERE)
#-------------------------------------------------------------------------------
# Game name is Steam install folder name.
# HUD 0/1 - Enable mangohud.
# GMD 0/1 - Enable Feral Gamingmode.
# LIMIT 0/1 - FPS limitter.
# NO_ESYNC 0/1 - Disables esync.
# DEBUG 0/1 - Enable debug messages on start using dunsty.
#-------------------------------------------------------------------------------
if [ "$GAME" == "HITMAN2" ]; then
    LIMIT=60
    HUD=0 # Not necessary because limit autoenables hud, this is just for the example purposes.
    GMD=1
    
elif [ "$GAME" == "Mafia III" ]; then
    # Workaround to reset fullscreen mode to windowed on start because game can't start with it.
    echo "0 0 2560 1440 0 0 0 0 0" > "${GAME_DIR}/compatdata/360430/pfx/drive_c/users/steamuser/Local Settings/Application Data/2K Games/Mafia III/Saves/videoconfig.cfg"
    HUD=1
    GMD=1

elif [ "$GAME" == "Planet Coaster" ]; then
    LIMIT=60
    HUD=1
    GMD=1

elif [ "$GAME" == "KingdomComeDeliverance" ]; then
    HUD=1
    GMD=1

elif [ "$GAME" == "Yakuza Kiwami" ]; then
    HUD=1
    GMD=1
    NO_ESYNC=1

elif [ "$GAME" == "Party Hard 2" ]; then
    LIMIT=60
    HUD=1
    GMD=1

elif [ "$GAME" == "State of Mind" ]; then
    LIMIT=60
    HUD=1
    GMD=1

elif [ "$GAME" == "Batman The Telltale Series" ]; then
    LIMIT=60
    HUD=1
    GMD=1

elif [ "$GAME" == "tbs" ]; then
    LIMIT=60
    HUD=1
    GMD=1

elif [ "$GAME" == "Spelunky" ]; then
    LIMIT=60
    HUD=1
    GMD=1
    
# WIP Broken
# elif [ "$GAME" == "Homeworld" ]; then
#     # Skipping broken homeworld lautcher.
#     HomeWorld="0" #Select Game 1,2,r1,r2,0
#     HomeWorldDir="${GAME_DIR}/common/Homeworld"
#     # Game Select
#     if [ $HomeWorld == "r1" ]; then
#         EXE="$HomeWorldDir/HomeworldRM/Bin/Release/HomeworldRM.exe"
#         OPT+=("-dlccampaign HW1Campaign.big")
#         OPT+=("-campaign HomeworldClassic")
#         OPT+=("-moviepath DataHW1Campaign")
#         OPT+=("-windowed")
#     elif [ $HomeWorld == "r2" ]; then
#         EXE="$HomeWorldDir/HomeworldRM/Bin/Release/HomeworldRM.exe"
#         OPT+=("-dlccampaign HW2Campaign.big")
#         OPT+=("-campaign Ascension")
#         OPT+=("-moviepath DataHW2Campaign")
#         OPT+=("-windowed")
#     elif [ $HomeWorld == "1" ]; then
#         EXE="$HomeWorldDir/Homeworld1Classic/exe/Homeworld.exe"
#         OPT+=("/noglddraw")
#     elif [ $HomeWorld == "2" ]; then
#         EXE="$HomeWorldDir/Homeworld2Classic/Bin/Release/Homeworld2.exe"
#     fi
#     HUD=1
#     GMD=1
#     NO_ESYNC=1
#     # Run native if no game selected.
#     if [ $HomeWorld != "0" ]; then
#         PROTON_PATH="$(ls -d1 /mnt/games/SteamGames/steamapps/common/Proton\ 4.11/ |tail -1)"
#         GAMEID=244160
#         #WINECMD="${PROTON_PATH}dist/bin//wine64"
#         #STARTCMD="start /unix"
#         export WINEDEBUG="-all" 
#         export WINEPREFIX="${GAME_DIR}/compatdata/${GAMEID}/pfx/" 
#         export SteamGameId="${GAMEID}" 
#         export SteamAppId="${GAMEID}" 
#         export WINEDLLOVERRIDES="d3d11=n;dxgi=n" 
#         export STEAM_COMPAT_CLIENT_INSTALL_PATH="${HOME}/.steam/steam/" 
#         if [ $DEBUG == 1 ]; then
#             dunstify "$GAME" "Extra env vars enabled."
#             echo "Game folder: ${GAME_DIR}" >> ${LOG_FILE}
#         fi
#     fi
fi

#-------------------------------------------------------------------------------
#-- WRAP UP
#-------------------------------------------------------------------------------
# Auto enabling Mangohud if limit on.
if [ $LIMIT -gt 0 ]; then
    HUD=1
fi
# Enabling Mangohud
if [ $HUD == 1 ]; then
    export MANGOHUD=1
    if [ $GAME_STATE == "Native" ]; then
        export MANGOHUD_DLSYM=1
        #export LD_PRELOAD=/usr/lib/mangohud/lib64/
    fi
    if [ $LIMIT -gt 0 ]; then
        export MANGOHUD_CONFIG=$MANGO,fps_limit=$LIMIT
        if [ $DEBUG == 1 ]; then
            dunstify "FPS Limit" "$LIMIT fps"
        fi
    else
        export MANGOHUD_CONFIG=$MANGO
    fi
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
if [ $GAME_STATE == "Native" ]; then
    if [ $HUD == 1 ]; then
        mangohud $GameMode "$WINECMD" "$STARTCMD" "$EXE" "${OPT[@]}"
    else
        $GameMode "$WINECMD" "$STARTCMD" "$EXE" "${OPT[@]}"
    fi
else
    $GameMode "$WINECMD" "$STARTCMD" "$EXE" "${OPT[@]}"
fi
