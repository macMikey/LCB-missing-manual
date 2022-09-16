script "button crawlFiles Behavior"
/*
# Bernd Niggemann, September 2022
# this stack searches for key words in LCB files that are located in folder "Extensions" in the LC app
# and in folder "Extensions" of the "My Livecode" folder.
# Type yor search in the field and hit return of click button "crawlFiles"
# Choose the type of match, default is "contains"
# use it to find examples of LCB code by searching for e.g. onMouseScroll to find the incoming parameters 
# which are omitted from the dictionary.
# Or to find examples of cade because LCB is best learned when looking at examples
# Click on a line of the results to open the LCB file as script of button "LCB-Script"
# if there are multiple line numbers at the end of a result clicking on the numbers opens the file at that
# line number.
# Button with label "reset Log of Extension Builder" (EB) sets the log of EB to empty if EB is visible
# That saves you reloading your LCB file when testing and logging
*/


local sHandlerA

on mouseUp pMouseBtnNo
   
   local tAllFiles, tallFilesForF1, tallFilesForF2, theEmptyFiles, tCollector, aTracker, doAllTheseFiles, tcounterForWatch
   
   put "" into field "fRes"
   lock screen
   local tOldDefault, tFolderRootSearch, tallFilesForF3, tTime, tFolderArray, tFoldersToSearch, tRootFolders, tSystemFolders, tUserExtensionFolder
   put the defaultfolder into tOldDefault
   
   put specialFolderpath("engine") into tFolderRootSearch
   set the itemDelimiter to "/"
   put "Tools/Extensions/" into item - 1 of tFolderRootSearch
   set the itemDelimiter to comma
   put tFolderRootSearch into tRootFolders
   
   
   put revIDESpecialFolderPath("user extensions") & slash into tFolderRootSearch
   
   put cr & tFolderRootSearch after tRootFolders
   
   put "" into tCollector
   put "" into tallFilesForF1
   put "" into tallFilesForF2
   put "" into tallFilesForF3
   put "" into doAllTheseFiles
   put "" into tAllFiles
   put "" into aTracker
   put "" into tcounterForWatch
   put "" into theEmptyFiles
   put "" into sHandlerA
   
   put the milliseconds into tTime
   repeat for each line aRootFolder in tRootFolders
      -- begin of search for subfolders
      --put "" into tFolderArray
      put 1 into tFolderArray[aRootFolder]
      
      local tLookForMoreFolders, tFoldersTemp, tSubTemp
      
      repeat -- will exit when no more folders are found
         put "" into tFoldersToSearch
         
         put the keys of tFolderArray into tLookForMoreFolders
         repeat for each line aFolder in tLookForMoreFolders
            if tFolderArray[aFolder] is not "" then put aFolder & cr after tFoldersToSearch
            put "" into tFolderArray[aFolder] -- so next time this path will not be searched
         end repeat
         
         if tFoldersToSearch is "" then exit repeat -- no folder found that has not been looked at
         
         repeat for each line aFolder in tFoldersToSearch
            set the defaultfolder to aFolder
            put "" into tFolderArray[aFolder] -- so next time this path will not be searched
            put the folders into tFoldersTemp
            
            -- filter out operating system folders on mac (like "..", or starting with "." to make it invisible)
            filter tFoldersTemp without ".*"
            -- filter without application folders, on the mac application may be pakages
            filter tFoldersTemp without "*.app"
            
            if tFoldersTemp is "" then next repeat
            
            repeat for each line aSubFolder in tFoldersTemp
               put aFolder & aSubFolder & "/" into tSubTemp
               put 1 into tFolderArray[tSubTemp] -- next time this path will be searched, at the same time the path is a new key in the array
            end repeat
         end repeat
      end repeat
      
      put the keys of tFolderArray & cr after tCollector
   end repeat
   
   delete char -1 of tCollector
   
   sort tCollector
   -- end of finding all subfolders
   -- tCollector contains now the path to all subfolders including the rootfolder
   
   -- now get all the files and the filepaths
   
   repeat for each line thePath in tCollector
      set the defaultfolder to thePath
      put the files into tAllFiles
      filter tAllFiles with "*.lcb"
      if tAllFiles is not "" then
         repeat for each line aFile in tAllFiles
            put thePath & aFile & return after doAllTheseFiles
         end repeat
      end if
   end repeat
   
   delete last char of doAllTheseFiles -- return
   
   local tData
   
   set the uAllTheseFiles of this card to doAllTheseFiles -- store long path for opening when clicking a hit line
   
   local tLastFound, tLineNumber, tHandlerName, tFileName
   local tOffset, tCharsToSkip, tTypeOfMatch
   
   put the label of button "typeOfMatch" into tTypeOfMatch
   put "" into tLastFound
   put "" into sHandlerA
   
   -- put "on ,command,function,private,before,after,getprop,setprop" into tHandlerStarts
   local tSearchString, tTheLine
   put field "fHandler" into tSearchString
   
   repeat for each line aFile in doAllTheseFiles
      set the itemDelimiter to slash
      if item -1 of aFile contains"defaultScript" then
         put item -3 to -1 of aFile into tFileName
      else
         put item -1 of aFile into tFileName
      end if
      set the itemDelimiter to comma
      
      put url("file:" & aFile) into tData
      if word 1 of tData is "script" then delete line 1 of tData
      
      repeat for each item aStart in tSearchString
         put 0 into tOffset
         put 0 into tCharsToSkip
         repeat
            put offset (aStart, tData, tCharsToSkip) into tOffset
            if tOffset > 0 then 
               put the number of lines of char 1 to tOffset + tCharsToSkip of tData into tLineNumber
               put line tLineNumber of tData into tTheLine
               if the number of tokens of tTheLine > 0 then
                  
                  --                  if token 1 of tTheLine is "end" then
                  --                     add tOffset to tCharsToSkip
                  --                     next repeat
                  --                  end if
                  ## determines how many words of the hit are displayed
                  put word 1 to 6 of tTheLine into tHandlerName
                  add 1 to sHandlerA[tFileName][tHandlerName][tLineNumber]
               end if
               add tOffset to tCharsToSkip
            else
               exit repeat
            end if
         end repeat
      end repeat -- for each item aStart in tSearchString
   end repeat --for each line aFile in doAllTheseFiles
   
   
   
   local tCollect, tNumberOfHandler, tHandlerKeyNo, tScriptKeys, tLookForHandler, tLineOfHandler
   
   put 0 into tHandlerKeyNo
   put the keys of sHandlerA into tScriptKeys
   put field "fHandler" into tLookForHandler
   
   repeat for each line aScript in tScriptKeys
      put the keys of sHandlerA[aScript] into tHandlerKeyNo
      add the number of lines of tHandlerKeyNo to tNumberOfHandler
      
      if tlookForHandler = "" then
         repeat for each key aHandler in sHandlerA[aScript]
            put the keys of sHandlerA[aScript][aHandler] into tLineOfHandler -- should only be one key but there are duplicate handlers in some Scripts
            sort tLineOfHandler numeric 
            replace cr with ", " in tLineOfHandler
            put aScript &": " &  "Handler: " & aHandler & " Line: " & tLineOfHandler & cr after tCollect 
         end repeat
      else
         if tTypeOfMatch = "Exact" then
            repeat for each key aHandler in sHandlerA[aScript]
               if tLookForHandler is among the trueWords of aHandler then
                  put the keys of sHandlerA[aScript][aHandler] into tLineOfHandler -- should only be one key but there are duplicate handlers in some Scripts
                  sort tLineOfHandler numeric 
                  replace cr with ", " in tLineOfHandler
                  put aScript &": " &  "Occurrence: " & aHandler & " -Line: " & tLineOfHandler & cr after tCollect 
               end if
            end repeat
         end if
         if tTypeOfMatch = "Contains" then
            repeat for each key aHandler in sHandlerA[aScript]
               if aHandler contains tLookForHandler  then
                  put the keys of sHandlerA[aScript][aHandler] into tLineOfHandler -- should only be one key but there are duplicate handlers in some Scripts
                  sort tLineOfHandler numeric 
                  replace cr with ", " in tLineOfHandler
                  put aScript &": " &  "Occurrence: " & aHandler & " -Line: " & tLineOfHandler & cr after tCollect 
               end if
            end repeat
         end if
         if tTypeOfMatch = "Starts with" then
            repeat for each key aHandler in sHandlerA[aScript]
               if word 2 of aHandler begins with tLookForHandler or word 3 of aHandler begins with tlookForHandler then
                  put the keys of sHandlerA[aScript][aHandler] into tLineOfHandler -- should only be one key but there are duplicate handlers in some Scripts
                  sort tLineOfHandler numeric 
                  replace cr with ", " in tLineOfHandler
                  put aScript &": " &  "Handler: " & aHandler & " -Line: " & tLineOfHandler & cr after tCollect 
               end if
            end repeat
         end if
         if tTypeOfMatch = "Ends with" then
            repeat for each key aHandler in sHandlerA[aScript]
               if word 2 of aHandler ends with tLookForHandler or word 3 of aHandler ends with tlookForHandler then
                  put the keys of sHandlerA[aScript][aHandler] into tLineOfHandler -- should only be one key but there are duplicate handlers in some Scripts
                  sort tLineOfHandler numeric 
                  replace cr with ", " in tLineOfHandler
                  put aScript &": " &  "Handler: " & aHandler & " -Line: " & tLineOfHandler & cr after tCollect 
               end if
            end repeat
         end if
      end if
   end repeat
   
   local tNumberOfMatches
   put the number of lines of tCollect into tNumberOfMatches
   
   ## clear path custom prop
   if tNumberOfMatches is 0 then
      set the uAllTheseFiles of this card to empty
   end if
   
   set the itemDelimiter to ":"
   sort tCollect numeric by word 1 of item -1 of each
   sort tCollect by item 1 of each
   
   
   ## for display grouped results by inserting empty line between files
   local tLastFile, tFinalDisplay
   
   put word 1 of tCollect into tLastFile
   repeat for each line aLine in tCollect
      if word 1 of aLine <> tLastFile then
         put cr & aLine & cr after tFinalDisplay
         put word 1 of aLine into tLastFile
      else 
         put aLine & cr after tFinalDisplay
         put word 1 of aLine into tLastFile
      end if
   end repeat
   delete char -1 of tFinalDisplay
   
   put tFinalDisplay into field "fRes"
   
   put cr & cr & cr & "Number of files scanned: " & the number of lines of doAllTheseFiles & \
         cr & "Occurences scanned: " & tNumberOfHandler & cr & "Matches: " & tNumberOfMatches  after field "fRes"
   put cr & "Milliseconds: " & the milliseconds - tTime after field "fRes"
   unlock screen
end mouseUp
