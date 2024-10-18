
--[[

    https://github.com/stax76/mpv-scripts

    This script consist of various small unrelated features.

    Not used code sections can be removed.

    Bindings must be added manually to input.conf.



    Show media info on screen
    -------------------------
    Prints detailed media info on the screen.
    
    Depends on the CLI tool 'mediainfo':
    https://mediaarea.net/en/MediaInfo/Download

    In input.conf add:
    i script-message-to misc print-media-info



    Load files/URLs from clipboard
    ------------------------------
    Loads one or multiple files/URLs from the clipboard.
    The clipboard format can be of type string or file object.
    Allows appending to the playlist.
    On Linux requires xclip being installed.

    In input.conf add:
    ctrl+v script-message-to misc load-from-clipboard
    ctrl+V script-message-to misc append-from-clipboard



    Cycle audio and subtitle tracks
    -------------------------------
    If there are 20+ subtitle tracks, it's annoying cycling through all
    of them. This feature allows you to cycle only through languages
    you actually know.

    In mpv.conf define your known languages:
    alang = de,deu,ger,en,eng #German/English
    slang = en,eng,de,deu,ger #English/German

    If you don't know the language IDs, use the terminal,
    mpv prints the language IDs there whenever a video file is loaded.

    In input.conf add:
    SHARP script-message-to misc cycle-known-tracks audio
    j     script-message-to misc cycle-known-tracks sub up
    J     script-message-to misc cycle-known-tracks sub down

    ~~/script-opts/misc.conf:
    #include_no_audio=no
    #include_no_sub=yes

    ## If more than 5 tracks exist, only known are cycled,
    ## define 0 to always cycle only known tracks.
    #max_audio_track_count=5
    #max_sub_track_count=5

    If you prefer a menu:
    https://github.com/stax76/mpv-scripts?tab=readme-ov-file#command_palette
    https://github.com/stax76/mpv-scripts#search-menu
    https://github.com/dyphire/mpv-scripts/blob/main/track-list.lua
    https://codeberg.org/NRK/mpv-toolbox/src/branch/master/mdmenu
    https://github.com/tomasklaen/uosc

    The code was originally written by stax76, it was later
    greatly improved by kaoneko making it much shorter.


    Jump to a random position in the playlist
    -----------------------------------------
    In input.conf add:
    ctrl+r script-message-to misc playlist-random

    If pos=last it jumps to first instead of random.



    Quick Bookmark
    --------------
    Creates or restores a bookmark. Supports one bookmark per video.

    Usage:
    Create a folder in the following location:
    ~~/script-settings/quick-bookmark/
    Or create it somewhere else, config at:
    ~~/script-opts/misc.conf:
    quick_bookmark_folder=<folder path>

    In input.conf add:
    ctrl+q script-message-to misc quick-bookmark

 

    Playlist Next/Prev
    ------------------
    Like the regular playlist-next/playlist-prev, but does not restart playback
    of the first or last file, in case the first or last track already plays,
    instead shows a OSD message.

    F11 script-message-to misc playlist-prev # Go to previous file in playlist
    F12 script-message-to misc playlist-next # Go to next file in playlist



    Playlist First/Last
    -------------------
    Navigates to the first or last track in the playlist,
    in case the first or last track already plays, it does not
    restart playback, instead shows a OSD message.

    Home script-message-to misc playlist-first # Go to first file in playlist
    End  script-message-to misc playlist-last  # Go to last file in playlist



    Restart mpv
    -----------
    Restarts mpv restoring the properties path, time-pos,
    pause and volume, the playlist is not restored.

    r script-message-to misc restart-mpv



    Execute Lua code
    ----------------
    Allows to execute Lua Code directly from input.conf.

    It's necessary to add a binding to input.conf:
    #Navigates to the last file in the playlist
    END script-message-to misc execute-lua-code "mp.set_property_number('playlist-pos', mp.get_property_number('playlist-count') - 1)"



    When seeking displays position and duration like so:
    ----------------------------------------------------
    70:00 / 80:00

    Which is different from most players which use:

    01:10:00 / 01:20:00

    input.conf:
    Right no-osd seek 5; script-message-to misc show-position

]]--

----- options

local o = {
    -- Cycle audio and subtitle tracks
    include_no_audio = false,
    include_no_sub = true,
    max_audio_track_count = 5,
    max_sub_track_count = 5,
    -- Quick Bookmark
    quick_bookmark_folder = "~~/script-settings/quick-bookmark/",
}

local opt = require "mp.options"
opt.read_options(o)

----- string

function is_empty(input)
    if input == nil or input == "" then
        return true
    end
end

function contains(input, find)
    if not is_empty(input) and not is_empty(find) then
        return input:find(find, 1, true)
    end
end

function trim(input)
    if not is_empty(input) then
        return input:match "^%s*(.-)%s*$"
    end
end

function split(input, sep)
    local tbl = {}

    if not is_empty(input) then
        for str in string.gmatch(input, "([^" .. sep .. "]+)") do
            table.insert(tbl, str)
        end
    end

    return tbl
end

----- list

function list_contains(list, value)
    for _, v in pairs(list) do
        if v == value then
            return true
        end
    end

    return false
end

----- math

function round(value)
    return value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
end

----- file

function file_exists(path)
    if is_empty(path) then return false end
    local file = io.open(path, "r")

    if file ~= nil then
        io.close(file)
        return true
    end
end

function file_read(file_path)
    local file = assert(io.open(file_path, "r"))
    local content = file:read("*all")
    file:close()
    return content
end

function file_write(path, content)
    local file = assert(io.open(path, "w"))
    file:write(content)
    file:close()
end

----- shared

local is_windows = package.config:sub(1,1) == "\\"
local msg = require "mp.msg"
local utils = require "mp.utils"

function get_temp_dir()
    if is_windows then
        return os.getenv("TEMP") .. "\\"
    else
        return "/tmp/"
    end
end

----- Jump to a random position in the playlist

mp.register_script_message("playlist-random", function ()
    local count = mp.get_property_number("playlist-count")
    math.randomseed(os.time())
    local new_pos = math.random(0, count - 1)
    local current_pos = mp.get_property_number("playlist-pos")

    if current_pos == count - 1 then
        new_pos = 0
    end

    mp.set_property_number("playlist-pos", new_pos)
end)

----- Execute Lua code

mp.register_script_message("execute-lua-code", function (code)
    loadstring(code)()
end)

----- Alternative seek OSD message

function pad_zero(value)
    local value = round(value)

    if value > 9 then
        return "" .. value
    else
        return "0" .. value
    end
end

function format_pos(value)
    local seconds = round(value)

    if seconds < 0 then
        seconds = 0
    end

    local pos_min_floor = math.floor(seconds / 60)
    local sec_rest = seconds - pos_min_floor * 60

    return pad_zero(pos_min_floor) .. ":" .. pad_zero(sec_rest)
end

function show_pos()
    local position = mp.get_property_number("time-pos")
    local duration = mp.get_property_number("duration")

    if position > duration then
        position = duration
    end

    if position ~= 0 then
        mp.osd_message(format_pos(position) .. " / " .. format_pos(duration))
    end
end

mp.register_script_message("show-position", function (mode)
    mp.add_timeout(0.05, show_pos)
end)

----- Print media info on screen

local media_info_cache = {}

function show_text(text, duration, font_size)
    mp.command('show-text "${osd-ass-cc/0}{\\\\fs' .. font_size ..
        '}${osd-ass-cc/1}' .. text .. '" ' .. duration)
end

function get_media_info()
    local path = mp.get_property("path")

    if media_info_cache[path] then
        return media_info_cache[path]
    end

    local media_info_format = [[General;N: %FileNameExtension%\\nG: %Format%, %FileSize/String%, %Duration/String%, %OverallBitRate/String%, %Recorded_Date%\\n
Video;V: %Format%, %Format_Profile%, %Width%x%Height%, %BitRate/String%, %FrameRate% FPS\\n
Audio;A: %Language/String%, %Format%, %Format_Profile%, %BitRate/String%, %Channel(s)% ch, %SamplingRate/String%, %Title%\\n
Text;S: %Language/String%, %Format%, %Format_Profile%, %Title%\\n]]

    local format_file = get_temp_dir() .. "media-info-format-2.txt"

    if not file_exists(format_file) then
        file_write(format_file, media_info_format)
    end

    if contains(path, "://") or not file_exists(path) then
        return
    end

    local proc_result = mp.command_native({
        name = "subprocess",
        playback_only = false,
        capture_stdout = true,
        args = {"mediainfo", "--inform=file://" .. format_file, path},
    })

    if proc_result.status == 0 then
        local output = proc_result.stdout

        output = string.gsub(output, ", , ,", ",")
        output = string.gsub(output, ", ,", ",")
        output = string.gsub(output, ": , ", ": ")
        output = string.gsub(output, ", \\n\r*\n", "\\n")
        output = string.gsub(output, "\\n\r*\n", "\\n")
        output = string.gsub(output, ", \\n", "\\n")
        output = string.gsub(output, "%.000 FPS", " FPS")
        output = string.gsub(output, "MPEG Audio, Layer 3", "MP3")

        media_info_cache[path] = output

        return output
    end
end

mp.register_script_message("print-media-info", function ()
    show_text(get_media_info(), 5000, 16)
end)

----- Playlist Next/Prev

mp.register_script_message("playlist-next", function ()
    local count = mp.get_property_number("playlist-count")
    if count == 0 then return end
    local pos = mp.get_property_number("playlist-pos")

    if pos == count - 1 then
        mp.osd_message("Already last track")
        return
    end

    mp.set_property_number("playlist-pos", pos + 1)
end)

mp.register_script_message("playlist-prev", function ()
    local count = mp.get_property_number("playlist-count")
    if count == 0 then return end
    local pos = mp.get_property_number("playlist-pos")

    if pos == 0 then
        mp.osd_message("Already first track")
        return
    end

    mp.set_property_number("playlist-pos", pos - 1)
end)

----- Playlist First/Last

mp.register_script_message("playlist-first", function ()
    local count = mp.get_property_number("playlist-count")
    if count == 0 then return end
    local pos = mp.get_property_number("playlist-pos")

    if pos == 0 then
        mp.osd_message("Already first track")
        return
    end

    mp.set_property_number("playlist-pos", 0)
end)

mp.register_script_message("playlist-last", function ()
    local count = mp.get_property_number("playlist-count")
    if count == 0 then return end
    local pos = mp.get_property_number("playlist-pos")

    if pos == count - 1 then
        mp.osd_message("Already last track")
        return
    end

    mp.set_property_number("playlist-pos", count - 1)
end)

----- Load files from clipboard

function loadfiles(mode)
    if is_windows then
        local ps_code = [[
            Add-Type -AssemblyName System.Windows.Forms
            $containsFiles = [Windows.Forms.Clipboard]::ContainsFileDropList()
            
            if ($containsFiles) {
                [Windows.Forms.Clipboard]::GetFileDropList() -join [Environment]::NewLine
            } else {
                Get-Clipboard
            }
        ]]

        proc_args = { "powershell", "-command", ps_code }
    else
        proc_args = { "xclip", "-o", "-selection", "clipboard" }
    end

    subprocess = {
        name = "subprocess",
        args = proc_args,
        playback_only = false,
        capture_stdout = true,
        capture_stderr = true
    }

    proc_result = mp.command_native(subprocess)

    if proc_result.status < 0 then
        msg.error("Error string: " .. proc_result.error_string)
        msg.error("Error stderr: " .. proc_result.stderr)
        return
    end

    proc_output = trim(proc_result.stdout)

    if is_empty(proc_output) then return end

    if contains(proc_output, "\n") then
        mp.commandv("loadlist", "memory://" .. proc_output, mode)
    else
        mp.commandv("loadfile", proc_output, mode)
    end
end

mp.register_script_message("load-from-clipboard", function ()
    loadfiles("replace")
end)

mp.register_script_message("append-from-clipboard", function ()
    loadfiles("append")
end)

----- Restart mpv

mp.register_script_message("restart-mpv", function ()
    local restart_args = {
        "mpv",
        "--pause=" .. mp.get_property("pause"),
        "--volume=" .. mp.get_property("volume"),
    }

    local playlist_pos = mp.get_property_number("playlist-pos")

    if playlist_pos > -1 then
        table.insert(restart_args, "--start=" .. mp.get_property("time-pos"))
        table.insert(restart_args, mp.get_property("path"))
    end

    mp.command_native({
        name = "subprocess",
        playback_only = false,
        detach = true,
        args = restart_args,
    })

    mp.command("quit")
end)

----- Cycle audio and subtitle tracks

mp.register_script_message("cycle-known-tracks", function (mode, dir)
    local m = mode:sub(1,1)
    local lang_list = {}
    for _,lang in pairs(mp.get_property_native(m.."lang")) do
        lang_list[lang:gsub(" ", "")] = true
    end
    local track_list = mp.get_property_native("track-list")
    local id_list = {o["include_no_"..mode] and "no" or nil}
    local count = 0
    local max_count = o["max_"..mode.."_track_count"]

    for _,track in pairs(track_list) do
        if track.type == mode then
            count = count + 1
            if lang_list[track.lang] or not track.lang or
                track.selected or not next(lang_list)
            then table.insert(id_list, track.id) end
        end
    end

    if #id_list < 2 then
        return
    elseif count <= max_count then
       mp.command("cycle "..mode.." "..(dir or ""))
    else
        mp.command("cycle-values "..(dir == "down" and "!reverse " or "")..
                    m.."id "..table.concat(id_list, " "))
    end
end)

----- Quick Bookmark

mp.register_script_message("quick-bookmark", function ()
    local path = mp.get_property("path")

    if is_empty(path) then
        return
    end

    local folder = mp.command_native({"expand-path", o.quick_bookmark_folder})

    if utils.file_info(folder) == nil then
        msg.error("Bookmark folder not found, create it at:\n" .. folder)
        return
    end

    if file_exists(path) then
        _, path = utils.split_path(path)
        path = utils.join_path(folder, path)
    else
        path = utils.join_path(folder, string.gsub(path, "[/\\:]", ""))
    end

    if file_exists(path) then
        mp.set_property_number("time-pos", tonumber(file_read(path)))
        os.remove(path)
    else
        file_write(path, mp.get_property("time-pos"))
        mp.osd_message("Bookmark saved")
    end
end)
