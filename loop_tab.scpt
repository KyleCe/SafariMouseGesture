tell application "Safari"
    repeat
        repeat with i from (count of tabs of window 1) to 1 by -1
            set thisTab to tab i of window 1
            set current tab of window 1 to thisTab
            delay 1
        end repeat
    end repeat
end tell