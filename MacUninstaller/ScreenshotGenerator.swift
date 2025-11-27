//
//  ScreenshotGenerator.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import SwiftUI
import AppKit

@MainActor
class ScreenshotGenerator: ObservableObject {
    
    enum AppState: String, CaseIterable {
        case idle = "idle"
        case scanning = "scanning"
        case fileList = "fileList"
        case deleting = "deleting"
        case completed = "completed"
        case error = "error"
        case permission = "permission"
        
        var displayName: String {
            switch self {
            case .idle: return "Drop Zone"
            case .scanning: return "Scanning"
            case .fileList: return "File List"
            case .deleting: return "Deleting"
            case .completed: return "Completed"
            case .error: return "Error"
            case .permission: return "Permission Request"
            }
        }
        
        var promptDescription: String {
            switch self {
            case .idle:
                return """
                Modern macOS app screenshot showing the main drop zone interface with:
                - Dark gradient background (deep blue to purple)
                - Glowing circular drop area with dashed border
                - Blue gradient arrow-down app icon in center
                - "Drag & Drop Applications Here" title
                - "Complete, Safe, Fast" info badges at bottom
                - Clean, minimal design with glass morphism effects
                """
            case .scanning:
                return """
                macOS app screenshot showing scanning progress with:
                - Same dark gradient background
                - Animated circular progress indicator in blue/purple gradient
                - Magnifying glass icon in center
                - "Scanning Application..." title
                - "Finding all related files" subtitle
                - Modern loading animation design
                """
            case .fileList:
                return """
                macOS app screenshot showing file list interface with:
                - Dark background with file browser layout
                - List of files and folders to be deleted
                - Checkboxes for selection
                - File sizes displayed
                - Total size summary at bottom
                - Delete button with warning styling
                - Professional file management interface
                """
            case .deleting:
                return """
                macOS app screenshot showing deletion progress with:
                - Dark gradient background
                - Circular progress bar in red/orange gradient
                - Trash can icon in center
                - "Deleting Files..." title
                - "Removing selected items" subtitle
                - Progress indicator showing deletion status
                """
            case .completed:
                return """
                macOS app screenshot showing completion state with:
                - Dark gradient background
                - Large green checkmark icon with glow effect
                - "Cleanup Complete!" title
                - Success message subtitle
                - "Clean Another App" button with blue gradient
                - Celebratory, positive completion design
                """
            case .error:
                return """
                macOS app screenshot showing error state with:
                - Dark gradient background
                - Red warning triangle icon
                - "Error Occurred" title
                - Error message description
                - "Try Again" button in red styling
                - Clear error state indication
                """
            case .permission:
                return """
                macOS app screenshot showing permission request with:
                - Dark gradient background
                - Security shield icon
                - Permission request explanation
                - "Grant Access" button
                - Privacy-focused permission interface
                - System security compliance design
                """
            }
        }
    }
    
    @Published var isGenerating = false
    @Published var generatedPrompts: [AppState: String] = [:]
    
    func generateAllPrompts() {
        isGenerating = true
        
        for state in AppState.allCases {
            let basePrompt = """
            Create a professional App Store screenshot for a macOS application called "MacUninstaller" showing the \(state.displayName.lowercased()) screen.
            
            \(state.promptDescription)
            
            Technical requirements:
            - macOS Big Sur/Monterey design language
            - 1280x800 resolution (16:10 aspect ratio)
            - High contrast for App Store visibility
            - Professional software appearance
            - Modern glassmorphism and gradient effects
            - Dark theme with blue/purple accent colors
            
            Style: Clean, modern, professional macOS application interface with attention to Apple's Human Interface Guidelines.
            """
            
            generatedPrompts[state] = basePrompt
        }
        
        isGenerating = false
    }
    
    func copyPromptToClipboard(_ state: AppState) {
        guard let prompt = generatedPrompts[state] else { return }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(prompt, forType: .string)
    }
    
    func savePromptsToFile() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "MacUninstaller_AppStore_Prompts.txt"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                let content = self.generateFileContent()
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    private func generateFileContent() -> String {
        var content = "MacUninstaller - App Store Screenshot Prompts\n"
        content += "Generated on \(Date().formatted(date: .abbreviated, time: .shortened))\n"
        content += String(repeating: "=", count: 60) + "\n\n"
        
        for state in AppState.allCases {
            content += "[\(state.displayName.uppercased())]\n"
            content += generatedPrompts[state] ?? "No prompt generated"
            content += "\n\n" + String(repeating: "-", count: 40) + "\n\n"
        }
        
        return content
    }
}

// MARK: - Preview Generator View
struct ScreenshotPreviewView: View {
    let state: ScreenshotGenerator.AppState
    @StateObject private var mockViewModel = MockAppCleanerViewModel()
    @StateObject private var mockPermissionManager = MockPermissionManager()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.12),
                    Color(red: 0.12, green: 0.10, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content based on state
            Group {
                switch state {
                case .idle:
                    DropZoneView(viewModel: mockViewModel)
                case .scanning:
                    ScanningView()
                case .fileList:
                    // Mock file list view - you'll need to create this
                    MockFileListView()
                case .deleting:
                    DeletingView()
                case .completed:
                    CompletedView(onReset: {})
                case .error:
                    ErrorView(message: "Permission denied. Please grant access to continue.", onReset: {})
                case .permission:
                    PermissionView(permissionManager: mockPermissionManager, onPermissionGranted: {})
                }
            }
        }
        .frame(width: 520, height: 620)
    }
}

// MARK: - Mock Classes for Preview
class MockAppCleanerViewModel: AppCleanerViewModel {
    override init() {
        super.init()
        // Set up mock data if needed
    }
}

class MockPermissionManager: PermissionManager {
    // Mock implementation
}

// MARK: - Mock File List View
struct MockFileListView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Files to be deleted")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("Total: 234 MB")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            
            // File list
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(mockFiles, id: \.name) { file in
                        MockFileRow(file: file)
                    }
                }
            }
            .background(Color.black.opacity(0.2))
            
            // Bottom action bar
            HStack {
                Text("\(mockFiles.count) items selected")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Button("Delete Selected") {
                    // Mock action
                }
                .buttonStyle(.borderedProminent)
                .controlProminence(.increased)
                .tint(.red)
            }
            .padding()
        }
    }
    
    private var mockFiles: [MockFile] {
        [
            MockFile(name: "~/Library/Application Support/TestApp", size: "45 MB", isSelected: true),
            MockFile(name: "~/Library/Preferences/com.test.app.plist", size: "2 KB", isSelected: true),
            MockFile(name: "~/Library/Caches/com.test.app", size: "123 MB", isSelected: true),
            MockFile(name: "~/Library/Logs/TestApp", size: "8 MB", isSelected: false),
            MockFile(name: "~/Documents/TestApp Documents", size: "56 MB", isSelected: true),
        ]
    }
}

struct MockFile {
    let name: String
    let size: String
    let isSelected: Bool
}

struct MockFileRow: View {
    let file: MockFile
    
    var body: some View {
        HStack {
            Image(systemName: file.isSelected ? "checkmark.square.fill" : "square")
                .foregroundColor(file.isSelected ? .blue : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(file.size)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(file.isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
    }
}