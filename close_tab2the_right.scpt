tell window 1 of application "Safari"
    close (tabs where index > (get index of current tab))
end