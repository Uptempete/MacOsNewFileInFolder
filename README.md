
# NewFileCreator

A macOS Finder extension that lets you create new empty files directly 
from the right-click context menu — just like on Windows.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- Right-click anywhere in Finder → **New File**
- Supports: `.txt`, `.md`
- Unique filenames (Untitled.txt, Untitled 2.txt, …)

## Installation

### Option A – Download (recommended)
1. Download `NewFileCreator.dmg` from [Releases](../../releases)
2. Open the DMG and drag `NewFileCreator.app` to `/Applications`
3. Launch the app and follow the onboarding

### Option B – Build from source
1. Clone the repo
```bash
   git clone https://github.com/YOUR_USERNAME/NewFileCreator.git
```
2. Open `NewFileCreator.xcodeproj` in Xcode
3. Select the `NewFileCreator` scheme → **Product → Archive**
4. Export and install

## Setup (first launch)

The app guides you through two steps:

1. **Full Disk Access** – required to create files anywhere
2. **Enable Finder Extension** – activates the right-click menu

## Requirements

- macOS 13 Ventura or later
- ~2 MB disk space

## License

MIT – see [LICENSE](LICENSE)
