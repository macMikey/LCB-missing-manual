script "button BresetLog Behavior"
on mouseUp
   if there is a field "console" of card id 1002 of stack "revextensionbuilder" then
      put empty into field "console" of card id 1002 of stack "revextensionbuilder"
   else
      answer "Extension Builder is not open"
   end if
end mouseUp
