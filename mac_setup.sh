#!/bin/bash
# 好有趣：Mac 端一次性设置。每 10 分钟从 GitHub 拉新文件，复制到 ~/Downloads/goodtime/
set -e
REPO="$HOME/goodtime-repo"
[ -d "$REPO/.git" ] || git clone https://github.com/ihodl8-rgb/goodtime.git "$REPO"
mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Downloads/goodtime/skill"
cat > "$REPO/pull.sh" <<'SH'
#!/bin/bash
cd "$HOME/goodtime-repo" || exit 0
git pull -q --ff-only || exit 0
rsync -a episodes/ "$HOME/Downloads/goodtime/"
[ -d skill ] && rsync -a skill/ "$HOME/Downloads/goodtime/skill/"
SH
chmod +x "$REPO/pull.sh"
PL="$HOME/Library/LaunchAgents/com.goodtime.pull.plist"
cat > "$PL" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>Label</key><string>com.goodtime.pull</string>
<key>ProgramArguments</key><array><string>/bin/bash</string><string>$REPO/pull.sh</string></array>
<key>StartInterval</key><integer>600</integer>
<key>RunAtLoad</key><true/>
</dict></plist>
PLIST
launchctl unload "$PL" 2>/dev/null || true
launchctl load "$PL"
"$REPO/pull.sh"
echo "好了：以后每 10 分钟自动同步到 ~/Downloads/goodtime/"
