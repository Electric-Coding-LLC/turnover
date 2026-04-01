# Turnover - Step 3: Create Xcode Project

## Tasks

- Create a new iOS app project in Xcode
- Use Swift and SwiftUI
- Name the app `Turnover`
- Set the organization identifier
- Confirm the project builds and runs in the simulator

## Xcode Setup

1. Open Xcode and choose `File` -> `New` -> `Project...`
2. Under iOS, select `App`
3. Click `Next`

Use these values:

- Product Name: `Turnover`
- Team: leave as-is for now if signing is not needed yet
- Organization Identifier: `com.electriccoding`
- Interface: `SwiftUI`
- Language: `Swift`
- Testing System: keep the default
- Storage: leave unchecked unless SwiftData is intentionally needed now

Then:

1. Save the project inside the existing repo at `/Users/iamce/dev/electric/turnover`
2. If Xcode asks about source control, do not create a new repo
3. Wait for indexing to finish
4. Select an iPhone simulator
5. Press Run

## Verification

- The app builds successfully
- The simulator launches
- The default starter screen appears
- The generated files are inside the existing repo and not in a nested repo
