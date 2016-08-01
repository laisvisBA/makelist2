{/home/justas/makelistFromGit/ttAllFiles.i &name="ttAllFiles"}
{/home/justas/makelistFromGit/ttAllFiles.i &name="ttIncludesHasChanged"}
{/home/justas/makelistFromGit/ttAllFiles.i &name="ttMakeList"}
{/home/justas/makelistFromGit/ttXREF.i &name="ttXREF"}

/* List all files to be checked */
input through value("dir /home/justas/makelistFromGit/branch/1uzd/*.p /home/justas/makelistFromGit/branch/1uzd/*.cls /home/justas/makelistFromGit/branch/1uzd/*.i -S -B") no-echo.
repeat:
    create ttAllFiles.
    import unformatted ttAllFiles.pathAndFile.
    put unformatted ttAllFiles.pathAndFile skip.
end.
input close.

/* Check if file was changed */
def var vBranchDir as char no-undo.
def var vTrunkDir as char no-undo.
def var i as int no-undo init 0.
def var vCompared as char no-undo.

for each ttAllFiles where
         ttAllFiles.pathAndFile contains ".p" or
         ttAllFiles.pathAndFile contains ".cls" or
         ttAllFiles.pathAndFile contains ".i":
         
    vBranchDir = ttAllFiles.pathAndFile.
    vTrunkDir = replace(vBranchDir, "branch", "trunk").
    
    input through value(substitute("/home/justas/makelistFromGit/diff.sh &1 &2", vBranchDir, vTrunkDir)) no-echo.
    repeat:
        import unformatted vCompared.
        
            /* If file is different */
            if vCompared <> "same" then do:

                /* Check if File is an include, move to ttIncludesHasChanged */
                if substring(ttAllFiles.pathAndFile, length(ttAllFiles.pathAndFile) - 1, 2) = ".i" then do:
                    create ttIncludesHasChanged.
                    ttIncludesHasChanged.pathAndFile = ttAllFiles.pathAndFile.
                    delete ttAllFiles.
                end.
                
                /* File is not an include, move to ttMakeList */
                else do:
                    create ttMakeList.
                    ttMakeList.pathAndFile = ttAllFiles.pathAndFile.
                    delete ttAllFiles.
                end.
            end.
    end.
end.
input close.

temp-table ttAllFiles:write-xml("file", "ttallfiles.xml", true, ?, ?, false, false).
temp-table ttIncludesHasChanged:write-xml("file", "ttIncludesHasChanged.xml", true, ?, ?, false, false).
temp-table ttAllFiles:write-xml("file", "ttAllFiles.xml", true, ?, ?, false, false).