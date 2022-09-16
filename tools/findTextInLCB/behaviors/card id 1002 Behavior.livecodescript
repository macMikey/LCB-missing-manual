script "card id 1002 Behavior"
on preOpenCard
   set the label of button "typeOfMatch" of me to "Contains"
   set the behavior of button "LCB-Script" to the long id of button "behaviorOfBtnLCB-Script"
end preOpenCard
