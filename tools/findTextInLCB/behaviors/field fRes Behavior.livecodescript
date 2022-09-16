script "field fRes Behavior"
on mouseUp
   local tClickLine, tStack, tLineNo, tClickLineNo, tLongFiles, tLineNumber, tOffset, tText
   put the clickline into tClickLine
   if tClickLine <> "" then
      put word 2 of tClickLine into tClickLineNo
      set the itemDelimiter to ":"
      if the number of items of line tClickLineNo of me < 3 then exit mouseUp
      
      put item 1 of line tClickLineNo of me into tStack
      put the uAllTheseFiles of this card into tLongFiles
      put Offset(tStack, tLongFiles) into tOffset
      if tOffset = 0 then exit mouseUp
      put the number of lines of char 1 to tOffset of tLongFiles into tLineNumber
      
      put line tLineNumber of tLongFiles into tStack
      --      set the itemDelimiter to "."
      --      put item 1 to - 2 of tStack into tStack
      --      set the itemDelimiter to ":"
      local tChunk, tStart, tEnd, tTest
      put the clickChunk into tChunk
      put word 2 of tChunk into tStart
      put word 4 of tChunk into tEnd
      put char tStart to tEnd of me into tTest
      replace space with empty in tTest
      --if trueWord 1 of (char tStart to tEnd of of line tClickLineNo of me) is a number then
      if tTest is a number then
         put tTest into tLineNo
      else
         put trueWord 1 of item - 1 of line tClickLineNo of me into tLineNo
      end if
      put URL ("file:" & tStack) into tText
      set the script of button "LCB-Script" to empty
      set the script button "LCB-Script" to tText
      set the itemDelimiter to slash
      --set the label of button "scriptButton" to item -1 of tStack
      edit script of button "LCB-Script" at tLineNo
      
   end if
end mouseUp




