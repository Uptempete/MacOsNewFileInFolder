//
//  FinderSync.swift
//  NewFileCreatorExtension
//
//  Created by Peter on 26.03.26.
//

import Cocoa
import FinderSync

/// A Finder Sync extension that adds a "New File" context menu to Finder,
/// allowing users to create empty files of various types directly in the
/// current directory.
class FinderSync: FIFinderSync {

    // MARK: - Properties

    /// The supported file types, each consisting of a display label and file extension.
    let fileTypes: [(label: String, ext: String)] = [
        (label: "Text File",       ext: "txt"),
        (label: "Markdown File",   ext: "md"),
    ]

    // MARK: - Lifecycle

    override init() {
        super.init()
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        // Monitor the entire file system
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
        requestFullDiskAccessIfNeeded()
        
    }

    // MARK: - FIFinderSync Menu

    /// Builds the context menu displayed when the user right-clicks in Finder.
    ///
    /// Returns an empty menu for any menu kind other than item or container clicks.
    ///
    /// - Parameter menuKind: The context in which the menu was requested.
    /// - Returns: An ``NSMenu`` containing a "New File" submenu, or an empty menu.
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        guard menuKind == .contextualMenuForItems ||
              menuKind == .contextualMenuForContainer else {
            return NSMenu()
        }

        let menu = NSMenu(title: "")

        // Top-level item acts as a container for the submenu only — no action
        let topItem = menu.addItem(
            withTitle: "New File",
            action: nil,
            keyEquivalent: ""
        )

        // Populate the submenu with one entry per file type
        let submenu = NSMenu(title: "New File")
        for (index, fileType) in fileTypes.enumerated() {
            let item = NSMenuItem(
                title: fileType.label,
                action: #selector(createFile(_:)),
                keyEquivalent: ""
            )
            // Store the index in tag so createFile(_:) can look up the correct type
            item.tag = index
            item.target = self
            submenu.addItem(item)
        }

        menu.setSubmenu(submenu, for: topItem)
        return menu
    }

    // MARK: - Actions

    /// Creates an empty file of the selected type in the current Finder directory.
    ///
    /// The file is named "Untitled" with an incrementing number suffix if a file
    /// with that name already exists (e.g. `Untitled 2.txt`). After creation,
    /// the new file is selected in Finder.
    ///
    /// - Parameter sender: The menu item that was clicked. Its `tag` is used
    ///   as an index into ``fileTypes``.
    @objc func createFile(_ sender: NSMenuItem) {
        let fileType = fileTypes[sender.tag]

        guard let targetURL = FIFinderSyncController.default().targetedURL() else { return }

        let fileURL = uniqueURL(in: targetURL, baseName: "Untitled", ext: fileType.ext)

        FileManager.default.createFile(atPath: fileURL.path, contents: Data(), attributes: nil)
        NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: targetURL.path)
    }

    // MARK: - Helpers

    /// Returns a URL that does not yet exist in the given directory.
    ///
    /// If `baseName.ext` is already taken, a numeric suffix is appended until
    /// a free name is found:
    /// ```
    /// Untitled.txt
    /// Untitled 2.txt
    /// Untitled 3.txt
    /// ```
    ///
    /// - Parameters:
    ///   - directory: The directory in which the file will be created.
    ///   - baseName: The desired filename without extension.
    ///   - ext: The file extension without a leading dot.
    /// - Returns: A non-existing ``URL`` inside `directory`.
    private func uniqueURL(in directory: URL, baseName: String, ext: String) -> URL {
        let fm = FileManager.default
        var candidate = directory.appendingPathComponent("\(baseName).\(ext)")
        var counter = 2
        while fm.fileExists(atPath: candidate.path) {
            candidate = directory.appendingPathComponent("\(baseName) \(counter).\(ext)")
            counter += 1
        }
        return candidate
    }
    
    
    
    
    private func requestFullDiskAccessIfNeeded() {
        // Versuche eine geschützte Datei zu lesen
        let testURL = URL(fileURLWithPath: "/Library/Application Support")
        if !FileManager.default.isReadableFile(atPath: testURL.path) {
            // Kein Zugriff – User zu den Einstellungen leiten
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Full Disk Access Required"
                alert.informativeText = "NewFileCreator needs Full Disk Access to create files anywhere on your Mac. Please grant access in System Settings."
                alert.addButton(withTitle: "Open System Settings")
                alert.addButton(withTitle: "Later")
                
                if alert.runModal() == .alertFirstButtonReturn {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
                }
            }
        }
    }
}
