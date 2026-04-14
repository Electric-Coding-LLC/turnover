#!/bin/zsh

set -euo pipefail

destination="platform=iOS Simulator,name=iPhone 17,OS=26.4"

xcodebuild test -scheme Turnover-Unit -destination "$destination"
