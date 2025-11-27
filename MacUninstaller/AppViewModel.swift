//
//  AppViewModel.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - App State
enum AppState {
    case idle
    case scanning
    case ready
    case deleting
    case completed
    case error(String)
}

// MARK: - ViewModel
@MainActor
class AppCleanerViewModel: ObservableObject {
    @Published var appInfo: AppInfo?
    @Published var relatedFiles: [RelatedFile] = []
    @Published var state: AppState = .idle
    @Published var isTargeted: Bool = false
    @Published var showConfirmation: Bool = false
    
    var totalSize: Int64 {
        relatedFiles.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
    }
    
    var formattedTotalSize: String {
        ByteCountFormatter.string(fromByteCount: totalSize, countStyle: .file)
    }
    
    var selectedCount: Int {
        relatedFiles.filter { $0.isSelected }.count
    }
    
    var groupedFiles: [FileCategory: [RelatedFile]] {
        Dictionary(grouping: relatedFiles) { $0.category }
    }
    
    // MARK: - Actions
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        if provider.hasItemConformingToTypeIdentifier("public.file-url") {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { [weak self] item, error in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else {
                    return
                }
                
                Task { @MainActor in
                    self?.processApp(at: url)
                }
            }
            return true
        }
        return false
    }
    
    func processApp(at url: URL) {
        state = .scanning
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // Visual feedback
            
            guard let info = AppScanner.getAppInfo(from: url) else {
                state = .error("Invalid application file")
                return
            }
            
            appInfo = info
            relatedFiles = AppScanner.findRelatedFiles(for: info)
            state = .ready
        }
    }
    
    func toggleFile(_ file: RelatedFile) {
        if let index = relatedFiles.firstIndex(where: { $0.id == file.id }) {
            relatedFiles[index].isSelected.toggle()
        }
    }
    
    func selectAll() {
        for index in relatedFiles.indices {
            relatedFiles[index].isSelected = true
        }
    }
    
    func deselectAll() {
        for index in relatedFiles.indices {
            relatedFiles[index].isSelected = false
        }
    }
    
    func deleteSelected() {
        showConfirmation = true
    }
    
    func confirmDelete() {
        state = .deleting
        
        AppScanner.deleteFiles(relatedFiles) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.state = .completed
                case .failure(let error):
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func reset() {
        appInfo = nil
        relatedFiles = []
        state = .idle
        showConfirmation = false
    }
}
