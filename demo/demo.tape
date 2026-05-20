# vhs script — generates demo/demo.gif for README hero
# Run: vhs demo/demo.tape

Output demo/demo.gif

Set Shell "bash"
Set FontSize 13
Set Width 900
Set Height 580
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set PlaybackSpeed 1.0
Set Padding 22
Set BorderRadius 10
Set Margin 0
Set FontFamily "JetBrains Mono"

# Clear + setup (hidden from output)
Hide
Type "clear"
Enter
Sleep 100ms
Show

Sleep 400ms

# User types the demo invocation
Type "bash demo/fake-claude.sh"
Sleep 300ms
Enter

# Wait for the simulated /dotclaude:design flow to complete
# (the script has internal sleeps totaling ~20s, plus authoring + excerpt)
Sleep 23s
