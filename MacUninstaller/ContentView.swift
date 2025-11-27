//
//  ContentView.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppCleanerViewModel()
    @StateObject private var permissionManager = PermissionManager.shared
    
    @State private var hasPermission = false
    
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
            
            if hasPermission {
                mainContent
            } else {
                PermissionView(permissionManager: permissionManager) {
                    withAnimation {
                        hasPermission = true
                    }
                }
            }
        }
        .navigationTitle(L10n.App.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: viewModel.reset) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .help("Reset")
            }
        }
        .frame(width: 520, height: 620)
        .alert(L10n.FileList.confirmTitle, isPresented: $viewModel.showConfirmation) {
            Button(L10n.Common.cancel, role: .cancel) { }
            Button(L10n.Common.delete, role: .destructive) {
                viewModel.confirmDelete()
            }
        } message: {
            Text(L10n.FileList.confirmMessage(viewModel.selectedCount, viewModel.formattedTotalSize))
        }
        .onAppear {
            checkPermission()
        }
    }
    
    private var mainContent: some View {
        Group {
            switch viewModel.state {
            case .idle:
                DropZoneView(viewModel: viewModel)
            case .scanning:
                ScanningView()
            case .ready:
                FileListView(viewModel: viewModel)
            case .deleting:
                DeletingView()
            case .completed:
                CompletedView(onReset: viewModel.reset)
            case .error(let message):
                ErrorView(message: message, onReset: viewModel.reset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func checkPermission() {
        // 저장된 bookmark 복원 시도
        if permissionManager.startAccessingSecurityScopedResource() {
            hasPermission = true
            print("true")
            return
        }
        
        // 직접 접근 가능 여부 확인
        let status = permissionManager.checkLibraryAccess()
        hasPermission = (status == .granted)
        print("\(status == .granted)")
    }
}

// MARK: - Drop Zone
struct DropZoneView: View {
    @ObservedObject var viewModel: AppCleanerViewModel
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Drop Area
            ZStack {
                // Outer glow
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.blue.opacity(viewModel.isTargeted ? 0.3 : 0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                
                // Border
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(viewModel.isTargeted ? 0.8 : 0.3),
                                Color.purple.opacity(viewModel.isTargeted ? 0.6 : 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                    )
                
                // Content
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.2),
                                        Color.purple.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "arrow.down.app.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .offset(y: pulseAnimation ? 5 : -5)
                    }
                    
                    VStack(spacing: 8) {
                        Text(L10n.DropZone.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text(L10n.DropZone.subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .frame(width: 360, height: 280)
            .onDrop(of: ["public.file-url"], isTargeted: $viewModel.isTargeted) { providers in
                viewModel.handleDrop(providers: providers)
            }
            
            // Info
            HStack(spacing: 16) {
                InfoBadge(icon: "trash.fill", text: L10n.DropZone.Badge.complete)
                InfoBadge(icon: "shield.fill", text: L10n.DropZone.Badge.safe)
                InfoBadge(icon: "bolt.fill", text: L10n.DropZone.Badge.fast)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.blue)
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

// MARK: - Scanning View
struct ScanningView: View {
    @State private var rotation = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text(L10n.Scanning.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(L10n.Scanning.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Deleting View
struct DeletingView: View {
    @State private var progress = 0.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(Color.red.opacity(0.2), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "trash.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text(L10n.Deleting.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(L10n.Deleting.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                progress = 1.0
            }
        }
    }
}

// MARK: - Completed View
struct CompletedView: View {
    let onReset: () -> Void
    @State private var showCheck = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.2),
                                Color.green.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.green)
                    .scaleEffect(showCheck ? 1 : 0.5)
                    .opacity(showCheck ? 1 : 0)
            }
            
            VStack(spacing: 8) {
                Text(L10n.Completed.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(L10n.Completed.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Button(action: onReset) {
                Text(L10n.Completed.button)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showCheck = true
            }
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text(L10n.Error.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onReset) {
                Text(L10n.Error.button)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.8))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
