#!/bin/bash
set -euo pipefail

project_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$project_root"
output_dir="${1:-$project_root/dist}"
mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"
work_dir="$(mktemp -d "${PI_SCRATCH_DIR:-${RUNNER_TEMP:-${TMPDIR:-/tmp}}}/smbmounter-package.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT

xcodebuild -project SMBMounter.xcodeproj -scheme SMBMounter \
    -configuration Release -destination 'generic/platform=macOS' \
    -derivedDataPath "$work_dir/DerivedData" \
    ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO build

stage="$work_dir/stage"
mkdir -p "$stage"
app="$stage/SMBMounter.app"
ditto "$work_dir/DerivedData/Build/Products/Release/SMBMounter.app" "$app"
ln -s /Applications "$stage/Applications"
cp docs/安装说明.txt "$stage/安装说明.txt"
codesign --force --sign - --options runtime \
    --entitlements SMBMounter/SMBMounter.entitlements "$app"
codesign --verify --strict --verbose=2 "$app"

python3 - "$app" <<'PY'
import json
import plistlib
import subprocess
import sys
from pathlib import Path
app = Path(sys.argv[1])
architectures = subprocess.check_output(['lipo', '-archs', str(app / 'Contents/MacOS/SMBMounter')], text=True).split()
assert {'arm64', 'x86_64'}.issubset(architectures), '缺少通用架构'
info = plistlib.loads((app / 'Contents/Info.plist').read_bytes())
assert info.get('NSAppleEventsUsageDescription'), '缺少访达自动化用途说明'
result = subprocess.run(['codesign', '-d', '--entitlements', '-', '--xml', str(app)],
                        capture_output=True, check=True)
assert plistlib.loads(result.stdout).get('com.apple.security.automation.apple-events'), '缺少自动化签名权限'
tables = []
for language in ('en', 'zh-Hans'):
    resource = app / 'Contents/Resources' / (language + '.lproj') / 'Localizable.strings'
    tables.append(json.loads(subprocess.check_output(['plutil', '-convert', 'json', '-o', '-', str(resource)])))
assert tables[0].keys() == tables[1].keys(), '中英文文案键不一致'
assert tables[1]['Add Share'] == '添加共享', '中文资源未正确打包'
print('已验证通用架构、自动化权限和中英文资源。')
PY

version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist")"
dmg_name="SMBMounter-${version}-cn-universal.dmg"
hdiutil create -volname 'SMBMounter 中文版' -srcfolder "$stage" \
    -fs HFS+ -format UDZO "$work_dir/$dmg_name"
hdiutil verify "$work_dir/$dmg_name"
mv "$work_dir/$dmg_name" "$output_dir/$dmg_name"
(cd "$output_dir" && shasum -a 256 "$dmg_name" > "$dmg_name.sha256")
printf '安装包：%s\n' "$output_dir/$dmg_name"
