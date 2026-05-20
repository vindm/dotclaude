# vhs script — generates demo/demo.gif for README hero
# Run: vhs demo/demo.tape

Output demo/demo.gif

Set Shell "bash"
Set FontSize 18
Set Width 1100
Set Height 720
Set Theme "Catppuccin Mocha"
Set TypingSpeed 70ms
Set PlaybackSpeed 1.0
Set Padding 30
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
# (the script has internal sleeps totaling ~14s)
Sleep 16s
