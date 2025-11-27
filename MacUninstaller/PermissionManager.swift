//
//  PermissionManager.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import AppKit
import Combine
import Foundation

enum PermissionStatus {
    case notDetermined
    case granted
    case denied
}

class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    
    @Published var libraryAccessStatus: PermissionStatus = .notDetermined
    
    private let fileManager = FileManager.default
    private let libraryPath = NSHomeDirectory() + "/Library"
    
    // MARK: - Check Permission
    func checkLibraryAccess() -> PermissionStatus {
        let testPaths = [
            "\(libraryPath)/Preferences",
            "\(libraryPath)/Application Support",
            "\(libraryPath)/Caches"
        ]
        
        for path in testPaths {
            if !fileManager.isReadableFile(atPath: path) {
                libraryAccessStatus = .denied
                return .denied
            }
        }
        
        libraryAccessStatus = .granted
        return .granted
    }
    
    // MARK: - Request Permission via Open Panel
    func requestLibraryAccess(completion: @escaping (Bool) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.message = NSLocalizedString("permission.panel.message", comment: "")
        openPanel.prompt = NSLocalizedString("permission.panel.prompt", comment: "")
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.directoryURL = URL(fileURLWithPath: libraryPath)
        
        openPanel.begin { [weak self] response in
            DispatchQueue.main.async {
                if response == .OK, let url = openPanel.url {
                    // Security-scoped bookmark 저장
                    self?.saveBookmark(for: url)
                    self?.libraryAccessStatus = .granted
                    completion(true)
                } else {
                    self?.libraryAccessStatus = .denied
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Security Scoped Bookmark
    private var bookmarkKey: String { "LibraryAccessBookmark" }
    
    private func saveBookmark(for url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(
                options: .withSecurityScope,
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            UserDefaults.standard.set(bookmarkData, forKey: bookmarkKey)
        } catch {
            print("Failed to save bookmark: \(error)")
        }
    }
    
    func restoreBookmark() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
            return nil
        }
        
        do {
            var isStale = false
            let url = try URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            
            if isStale {
                saveBookmark(for: url)
            }
            
            return url
        } catch {
            print("Failed to restore bookmark: \(error)")
            return nil
        }
    }
    
    func startAccessingSecurityScopedResource() -> Bool {
        guard let url = restoreBookmark() else { return false }
        return url.startAccessingSecurityScopedResource()
    }
    
    func stopAccessingSecurityScopedResource() {
        guard let url = restoreBookmark() else { return }
        url.stopAccessingSecurityScopedResource()
    }
    
    // MARK: - Full Disk Access Check
    var hasFullDiskAccess: Bool {
        let testPath = "\(libraryPath)/Mail"
        return fileManager.isReadableFile(atPath: testPath)
    }
    
    func openFullDiskAccessSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!
        NSWorkspace.shared.open(url)
    }
    
    func openSecuritySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy")!
        NSWorkspace.shared.open(url)
    }
}
