# vhs script — generates demo/bootstrap.gif for README hero
# Shows /dotclaude:bootstrap full 7-layer flow.
# Run: vhs demo/bootstrap.tape
#
# Requires: brew install --cask font-jetbrains-mono

Output demo/bootstrap.gif

Set Shell "bash"
Set FontFamily "JetBrains Mono"
Set FontSize 16
Set Width 1200
Set Height 800
Set Theme "Catppuccin Mocha"
Set TypingSpeed 45ms
Set PlaybackSpeed 1.0
Set Padding 50
Set BorderRadius 12
Set Margin 0
Set LineHeight 1.25

# Clear + setup (hidden)
Hide
Type "clear"
Enter
Sleep 150ms
Show

Sleep 500ms

Type "bash demo/fake-bootstrap.sh"
Sleep 400ms
Enter

# fake-bootstrap.sh has ~35s of sleeps + content typing time
Sleep 38s
