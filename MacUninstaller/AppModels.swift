//
//  AppModels.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import Foundation
import AppKit

// MARK: - App Info Model
struct AppInfo: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let path: URL
    let icon: NSImage?
    let size: Int64
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
}

// MARK: - Related File Model
struct RelatedFile: Identifiable, Hashable {
    let id = UUID()
    let path: URL
    let size: Int64
    let category: FileCategory
    var isSelected: Bool = true
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var fileName: String {
        path.lastPathComponent
    }
    
    var relativePath: String {
        path.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}

// MARK: - File Category
// AppModels.swift 수정
enum FileCategory: String, CaseIterable {
    case app, preferences, applicationSupport, caches
    case logs, containers, savedState, crashReports, other
    
    var localizedName: String {
        switch self {
        case .app: return L10n.Category.app
        case .preferences: return L10n.Category.preferences
        case .applicationSupport: return L10n.Category.applicationSupport
        case .caches: return L10n.Category.caches
        case .logs: return L10n.Category.logs
        case .containers: return L10n.Category.containers
        case .savedState: return L10n.Category.savedState
        case .crashReports: return L10n.Category.crashReports
        case .other: return L10n.Category.other
        }
    }
    
    var icon: String {
        switch self {
        case .app: return "app.fill"
        case .preferences: return "gearshape.fill"
        case .applicationSupport: return "folder.fill"
        case .caches: return "internaldrive.fill"
        case .logs: return "doc.text.fill"
        case .containers: return "shippingbox.fill"
        case .savedState: return "clock.arrow.circlepath"
        case .crashReports: return "exclamationmark.triangle.fill"
        case .other: return "questionmark.folder.fill"
        }
    }
    
    var color: String {
        switch self {
        case .app: return "blue"
        case .preferences: return "orange"
        case .applicationSupport: return "purple"
        case .caches: return "green"
        case .logs: return "gray"
        case .containers: return "pink"
        case .savedState: return "cyan"
        case .crashReports: return "red"
        case .other: return "brown"
        }
    }
}

// MARK: - App Scanner
class AppScanner {
    
    static func getAppInfo(from url: URL) -> AppInfo? {
        guard url.pathExtension == "app" else { return nil }
        
        let bundle = Bundle(url: url)
        let bundleIdentifier = bundle?.bundleIdentifier ?? url.deletingPathExtension().lastPathComponent
        let appName = bundle?.infoDictionary?["CFBundleName"] as? String ?? url.deletingPathExtension().lastPathComponent
        
        // Get app icon
        var icon: NSImage? = nil
        if let iconFile = bundle?.infoDictionary?["CFBundleIconFile"] as? String {
            var iconPath = iconFile
            if !iconPath.hasSuffix(".icns") {
                iconPath += ".icns"
            }
            if let iconURL = bundle?.url(forResource: iconPath.replacingOccurrences(of: ".icns", with: ""), withExtension: "icns") {
                icon = NSImage(contentsOf: iconURL)
            }
        }
        
        if icon == nil {
            icon = NSWorkspace.shared.icon(forFile: url.path)
        }
        
        // Calculate app size
        let size = calculateDirectorySize(url)
        
        return AppInfo(
            name: appName,
            bundleIdentifier: bundleIdentifier,
            path: url,
            icon: icon,
            size: size
        )
    }
    
    static func findRelatedFiles(for app: AppInfo) -> [RelatedFile] {
        var files: [RelatedFile] = []
        let fileManager = FileManager.default
        let homeDir = NSHomeDirectory()
        
        // Security scoped resource 시작
        let hasAccess = PermissionManager.shared.startAccessingSecurityScopedResource()
        defer {
            if hasAccess {
                PermissionManager.shared.stopAccessingSecurityScopedResource()
            }
        }
        
        // App itself
        files.append(RelatedFile(
            path: app.path,
            size: app.size,
            category: .app
        ))
        
        // Search paths
        let searchPaths: [(String, FileCategory)] = [
            ("\(homeDir)/Library/Preferences", .preferences),
            ("\(homeDir)/Library/Application Support", .applicationSupport),
            ("\(homeDir)/Library/Caches", .caches),
            ("\(homeDir)/Library/Logs", .logs),
            ("\(homeDir)/Library/Containers", .containers),
            ("\(homeDir)/Library/Group Containers", .containers),
            ("\(homeDir)/Library/Saved Application State", .savedState),
            ("\(homeDir)/Library/Logs/DiagnosticReports", .crashReports),
            ("\(homeDir)/Library/LaunchAgents", .other),
            ("\(homeDir)/Library/HTTPStorages", .caches),
            ("\(homeDir)/Library/WebKit", .caches),
        ]
        
        let appName = app.name
        let bundleId = app.bundleIdentifier
        let appNameLower = appName.lowercased()
        
        for (path, category) in searchPaths {
            guard fileManager.fileExists(atPath: path),
                  fileManager.isReadableFile(atPath: path) else { continue }
            
            do {
                let contents = try fileManager.contentsOfDirectory(atPath: path)
                
                for item in contents {
                    let itemLower = item.lowercased()
                    let fullPath = URL(fileURLWithPath: path).appendingPathComponent(item)
                    
                    if itemLower.contains(bundleId.lowercased()) ||
                       itemLower.contains(appNameLower) ||
                       item.contains(bundleId) ||
                       item.contains(appName) {
                        
                        let size = calculateDirectorySize(fullPath)
                        files.append(RelatedFile(
                            path: fullPath,
                            size: size,
                            category: category
                        ))
                    }
                }
            } catch {
                print("Cannot access \(path): \(error.localizedDescription)")
                continue
            }
        }
        
        return files
    }
    
    static func calculateDirectorySize(_ url: URL) -> Int64 {
        let fileManager = FileManager.default
        var totalSize: Int64 = 0
        
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                if resourceValues.isDirectory == false {
                    totalSize += Int64(resourceValues.fileSize ?? 0)
                }
            } catch {
                continue
            }
        }
        
        return totalSize
    }
    
    static func deleteFiles(_ files: [RelatedFile], completion: @escaping (Result<Void, Error>) -> Void) {
        let selectedFiles = files.filter { $0.isSelected }
        let urls = selectedFiles.map { $0.path }
        
        guard !urls.isEmpty else {
            completion(.success(()))
            return
        }
        
        // Security scoped resource 시작
        let hasAccess = PermissionManager.shared.startAccessingSecurityScopedResource()
        
        NSWorkspace.shared.recycle(urls) { trashedURLs, error in
            if hasAccess {
                PermissionManager.shared.stopAccessingSecurityScopedResource()
            }
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
