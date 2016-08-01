#SingleInstance ignore

; Read registry to get Steam's install location and set working directory there 
RegRead, steamPath, HKEY_CURRENT_USER\SOFTWARE\Valve\Steam, SteamPath
SetWorkingDir, %steamPath%/steamapps

; Open libraryfolders.vdf so we can read from it 
libraryConfig := FileOpen("libraryfolders.vdf", "r")

; Count lines in libraryconfig.vdf and put each line into an array
numLines := 0
libraryLines := Array()
while !libraryConfig.AtEOF
{
    line := libraryConfig.ReadLine()
    libraryLines.Push(line)
    numLines++
}

; Close file
libraryConfig.Close()

; Calculate number of extra library folders based on numbers of lines in libraryfolders.vdf 
numLibraries := (numLines - 5)

; If numLibraries is at least 1 loop through all of them and look for RelicCoH.exe
path := ""
found := 0
if (numLibraries > 0)
{
    for index, value in libraryLines
    {
        bound := numLibraries+4
        if index between 5 and %bound%
        {
            lineArray := Array()
            lineArray := StrSplit(value, [" ", "`t"])

            ; Clean up the library path from the .vdf file
            path := StrReplace(lineArray[4], "\\", "\")
            path := StrReplace(path, """", "") ; Remove double-quotes
            path := StrReplace(path, "`n", "") ; Remove newlines
            path .= "\steamapps\common\Company of Heroes Relaunch"
            game := path . "\RelicCoH.exe"
            
            IfExist, %game%
                found++
        }

        if (found > 0)
            break
    }
}
; If what we're looking for isn't in a library check the default location
if (found == 0)
{
    path := %A_WorkingDir% . "\common\Company of Heroes Relaunch"
    game := path . "\RelicCoH.exe"

    IfExist, %game%
        found++
}
; If what we're looking for still hasn't been found, admit defeat.
if (found == 0)
{
    MsgBox, I couldn't find RelicCoH.exe. You might not have it installed.
} else {
    ; TO DO LATER: Run the installers, insert found path into them
    clipboard = %path%
    MsgBox, I found your Company of Heroes install path. It is %clipboard%. I also copied it to your clipboard for your convenience.
}

; We'll quit when we're done.
ExitApp