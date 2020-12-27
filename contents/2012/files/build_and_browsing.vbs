Option Explicit

Dim objWshShell
Dim objFso
Dim objFile
Dim inFileName
Dim objParentFolder
Dim parentfolder
Dim makebat
Dim objFolder
Dim bat
Dim WshScriptExec

Set objWshShell = CreateObject("WScript.Shell")
Set objFso = CreateObject("Scripting.FileSystemObject")

Function getParentFolder()
    inFileName = ExpandParameter("$F")
    If objFso.FileExists(inFileName) = True Then
        Set objFile = objFso.GetFile(inFileName)
        getParentFolder = objFile.ParentFolder
    End If
End Function


Function existsMakebat(parentfolder)
    bat = true
    Do until (bat = false)
        makebat = parentfolder & "\make.bat"
        set objFolder = objFso.GetFolder(parentfolder)
        If objFso.FileExists(makebat) Then
            objWshShell.CurrentDirectory = parentfolder
            existsMakebat = makebat
            exit function
        ElseIf objFolder.IsRootFolder Then
            existsMakebat = false
            bat = false
            exit function
        Else
            parentfolder = objFolder.ParentFolder
        End If
    loop
End Function


Function main()
    parentfolder = getParentFolder
    makebat = existsMakebat(parentfolder)
    if makebat = false Then
        msgbox "make‚ÉŽ¸”s‚µ‚Ü‚µ‚½", 16, "Result"
    Elseif makebat = null Then
        msgbox "make‚ÉŽ¸”s‚µ‚Ü‚µ‚½", 16, "Result"
    Else
        Set WshScriptExec = objWshShell.Exec("make.bat html")
        Do While (WshScriptExec.Status = 0)
            objWshShell.run "ping -n 2 localhost", 0, True
        loop
        objWshShell.run("_build\html\" & ExpandParameter("$g") & ".html")
        msgbox WshScriptExec.StdOut.ReadAll, 64, "Result"
    End If
End Function


main


Set objWshShell = nothing
Set objFso = nothing
Set objFile = nothing
Set objFolder = nothing
Set WshScriptExec = nothing
