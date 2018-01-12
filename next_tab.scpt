tell application "Safari"
   tell window 1
       set i to index of current tab
       set i to i + 1
       if i > (count tabs) then set i to 1
       set current tab to tab i
   end tell
end tell