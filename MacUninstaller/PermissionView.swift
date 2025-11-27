//
//  PermissionView.swift
//  MacUninstaller
//
//  Created by tngtng on 11/27/25.
//

import Combine
import SwiftUI

struct PermissionView: View {
    @ObservedObject var permissionManager: PermissionManager
    let onGranted: () -> Void
    
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.2),
                                Color.orange.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            // Text
            VStack(spacing: 12) {
                Text(L10n.Permission.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(L10n.Permission.message)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            // Required permissions list
            VStack(alignment: .leading, spacing: 12) {
                PermissionRow(
                    icon: "folder.fill",
                    title: L10n.Permission.libraryAccess,
                    description: L10n.Permission.libraryAccessDesc
                )
                
                PermissionRow(
                    icon: "externaldrive.fill",
                    title: L10n.Permission.fullDiskAccess,
                    description: L10n.Permission.fullDiskAccessDesc,
                    isOptional: true
                )
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal, 40)
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: requestAccess) {
                    HStack(spacing: 8) {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text(L10n.Permission.grantAccess)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
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
                .disabled(isRequesting)
                
                Button(action: openSettings) {
                    Text(L10n.Permission.openSettings)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private func requestAccess() {
        isRequesting = true
        
        permissionManager.requestLibraryAccess { granted in
            isRequesting = false
            if granted {
                onGranted()
            }
        }
    }
    
    private func openSettings() {
        permissionManager.openSecuritySettings()
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    var isOptional: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if isOptional {
                        Text(L10n.Permission.optional)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .lineSpacing(2)
            }
        }
    }
}

#Preview {
    ZStack {
        Color(red: 0.08, green: 0.08, blue: 0.12)
            .ignoresSafeArea()
        
        PermissionView(permissionManager: PermissionManager.shared) {
            print("Granted")
        }
    }
    .frame(width: 520, height: 580)
}
