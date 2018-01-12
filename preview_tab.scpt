tell application "Safari"
   tell window 1
       set i to index of current tab
       set i to i - 1
       if i < 1 then set i to (count tabs)
       set current tab to tab i
   end tell
end tell