# vhs script — generates demo/demo.gif for README hero
# Run: vhs demo/demo.tape
#
# Requires: brew install --cask font-jetbrains-mono

Output demo/demo.gif

Set Shell "bash"
Set FontFamily "JetBrains Mono"
Set FontSize 18
Set Width 1200
Set Height 720
Set Theme "Catppuccin Mocha"
Set TypingSpeed 50ms
Set PlaybackSpeed 1.0
Set Padding 50
Set BorderRadius 12
Set Margin 0
Set LineHeight 1.3

# Clear + setup (hidden from output)
Hide
Type "clear"
Enter
Sleep 150ms
Show

Sleep 600ms

# User types the demo invocation
Type "bash demo/fake-claude.sh"
Sleep 400ms
Enter

# Wait for the simulated /dotclaude:design flow (script has ~20s internal sleeps + tail padding)
Sleep 24s
