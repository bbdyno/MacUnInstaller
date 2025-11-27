//
//  FileListView.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import Combine
import SwiftUI

struct FileListView: View {
    @ObservedObject var viewModel: AppCleanerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // App Header
            if let app = viewModel.appInfo {
                AppHeaderView(app: app)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // File List
            ScrollView {
                LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                    ForEach(FileCategory.allCases, id: \.self) { category in
                        if let files = viewModel.groupedFiles[category], !files.isEmpty {
                            Section {
                                ForEach(files) { file in
                                    FileRowView(
                                        file: file,
                                        onToggle: { viewModel.toggleFile(file) }
                                    )
                                }
                            } header: {
                                CategoryHeaderView(
                                    category: category,
                                    count: files.count,
                                    size: files.reduce(0) { $0 + $1.size }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
                .background(Color.white.opacity(0.1))
            
            // Footer
            FooterView(viewModel: viewModel)
        }
    }
}

// MARK: - App Header
struct AppHeaderView: View {
    let app: AppInfo
    
    var body: some View {
        HStack(spacing: 16) {
            // App Icon
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "app.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.5))
                    )
            }
            
            // App Info
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(app.bundleIdentifier)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(1)
                
                Text(app.formattedSize)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white.opacity(0.03))
    }
}

// MARK: - Category Header
struct CategoryHeaderView: View {
    let category: FileCategory
    let count: Int
    let size: Int64
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(categoryColor)
            
            Text(category.localizedName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(count)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.white.opacity(0.1))
                .cornerRadius(4)
            
            Spacer()
            
            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(red: 0.1, green: 0.1, blue: 0.14))
    }
    
    var categoryColor: Color {
        switch category {
        case .app: return .blue
        case .preferences: return .orange
        case .applicationSupport: return .purple
        case .caches: return .green
        case .logs: return .gray
        case .containers: return .pink
        case .savedState: return .cyan
        case .crashReports: return .red
        case .other: return .brown
        }
    }
}

// MARK: - File Row
struct FileRowView: View {
    let file: RelatedFile
    let onToggle: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(file.isSelected ? Color.blue : Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    
                    if file.isSelected {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: 18, height: 18)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // File Icon
            Image(systemName: fileIcon)
                .font(.system(size: 14))
                .foregroundColor(file.isSelected ? .white.opacity(0.7) : .white.opacity(0.3))
                .frame(width: 20)
            
            // File Info
            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(file.isSelected ? .white : .white.opacity(0.4))
                    .lineLimit(1)
                
                Text(file.relativePath)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Size
            Text(file.formattedSize)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(file.isSelected ? .white.opacity(0.6) : .white.opacity(0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color.white.opacity(0.05) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
    
    var fileIcon: String {
        switch file.category {
        case .app: return "app.fill"
        case .preferences: return "doc.text.fill"
        case .applicationSupport: return "folder.fill"
        case .caches: return "cylinder.fill"
        case .logs: return "doc.plaintext.fill"
        case .containers: return "shippingbox.fill"
        case .savedState: return "clock.fill"
        case .crashReports: return "exclamationmark.triangle.fill"
        case .other: return "doc.fill"
        }
    }
}

// MARK: - Footer
struct FooterView: View {
    @ObservedObject var viewModel: AppCleanerViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Select buttons
            HStack(spacing: 8) {
                Button(L10n.Common.selectAll) {
                    viewModel.selectAll()
                }
                .buttonStyle(SecondaryButtonStyle())
                
                Button(L10n.Common.deselectAll) {
                    viewModel.deselectAll()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            // Summary
            VStack(alignment: .trailing, spacing: 2) {
                Text(L10n.FileList.itemsSelected(viewModel.selectedCount))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(viewModel.formattedTotalSize)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Delete button
            Button(action: viewModel.deleteSelected) {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text(L10n.Common.delete)
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [.red.opacity(0.9), .red.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.selectedCount == 0)
            .opacity(viewModel.selectedCount == 0 ? 0.5 : 1)
        }
        .padding(16)
        .background(Color.white.opacity(0.03))
    }
}

// MARK: - Button Styles
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(configuration.isPressed ? 0.1 : 0.05))
            .cornerRadius(6)
    }
}

#Preview {
    ContentView()
}
