script "button About Behavior"
on mouseUp
   local tMessage, tScript
   put the script of button "crawlFiles" into tScript
   put line 1 to lineOffset("*/", tScript) of tScript into field "fRes"
end mouseUp
