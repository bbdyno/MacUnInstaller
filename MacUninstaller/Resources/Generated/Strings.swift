// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  public enum App {
    /// Mac App Uninstaller
    public static let title = L10n.tr("Localizable", "app.title", fallback: "Mac App Uninstaller")
  }
  public enum Category {
    /// Application
    public static let app = L10n.tr("Localizable", "category.app", fallback: "Application")
    /// Application Support
    public static let applicationSupport = L10n.tr("Localizable", "category.applicationSupport", fallback: "Application Support")
    /// Caches
    public static let caches = L10n.tr("Localizable", "category.caches", fallback: "Caches")
    /// Containers
    public static let containers = L10n.tr("Localizable", "category.containers", fallback: "Containers")
    /// Crash Reports
    public static let crashReports = L10n.tr("Localizable", "category.crashReports", fallback: "Crash Reports")
    /// Logs
    public static let logs = L10n.tr("Localizable", "category.logs", fallback: "Logs")
    /// Other
    public static let other = L10n.tr("Localizable", "category.other", fallback: "Other")
    /// Preferences
    public static let preferences = L10n.tr("Localizable", "category.preferences", fallback: "Preferences")
    /// Saved State
    public static let savedState = L10n.tr("Localizable", "category.savedState", fallback: "Saved State")
  }
  public enum Common {
    /// Localizable.strings
    ///   MacUninstaller
    /// 
    ///   Created by tngtng on 11/27/25.
    public static let cancel = L10n.tr("Localizable", "common.cancel", fallback: "Cancel")
    /// Confirm
    public static let confirm = L10n.tr("Localizable", "common.confirm", fallback: "Confirm")
    /// Delete
    public static let delete = L10n.tr("Localizable", "common.delete", fallback: "Delete")
    /// Deselect All
    public static let deselectAll = L10n.tr("Localizable", "common.deselectAll", fallback: "Deselect All")
    /// Select All
    public static let selectAll = L10n.tr("Localizable", "common.selectAll", fallback: "Select All")
  }
  public enum Completed {
    /// Clean Another App
    public static let button = L10n.tr("Localizable", "completed.button", fallback: "Clean Another App")
    /// All selected files have been moved to Trash
    public static let subtitle = L10n.tr("Localizable", "completed.subtitle", fallback: "All selected files have been moved to Trash")
    /// Completed!
    public static let title = L10n.tr("Localizable", "completed.title", fallback: "Completed!")
  }
  public enum Deleting {
    /// Moving files to Trash
    public static let subtitle = L10n.tr("Localizable", "deleting.subtitle", fallback: "Moving files to Trash")
    /// Deleting...
    public static let title = L10n.tr("Localizable", "deleting.title", fallback: "Deleting...")
  }
  public enum DropZone {
    /// Drag and drop .app file to scan for related files
    public static let subtitle = L10n.tr("Localizable", "dropZone.subtitle", fallback: "Drag and drop .app file to scan for related files")
    /// Drop Application Here
    public static let title = L10n.tr("Localizable", "dropZone.title", fallback: "Drop Application Here")
    public enum Badge {
      /// Complete Removal
      public static let complete = L10n.tr("Localizable", "dropZone.badge.complete", fallback: "Complete Removal")
      /// Fast Scan
      public static let fast = L10n.tr("Localizable", "dropZone.badge.fast", fallback: "Fast Scan")
      /// Safe Delete
      public static let safe = L10n.tr("Localizable", "dropZone.badge.safe", fallback: "Safe Delete")
    }
  }
  public enum Error {
    /// Try Again
    public static let button = L10n.tr("Localizable", "error.button", fallback: "Try Again")
    /// Invalid application file
    public static let invalidApp = L10n.tr("Localizable", "error.invalidApp", fallback: "Invalid application file")
    /// Error
    public static let title = L10n.tr("Localizable", "error.title", fallback: "Error")
  }
  public enum FileList {
    /// Are you sure you want to move %d items (%@) to Trash?
    public static func confirmMessage(_ p1: Int, _ p2: Any) -> String {
      return L10n.tr("Localizable", "fileList.confirmMessage", p1, String(describing: p2), fallback: "Are you sure you want to move %d items (%@) to Trash?")
    }
    /// Confirm Deletion
    public static let confirmTitle = L10n.tr("Localizable", "fileList.confirmTitle", fallback: "Confirm Deletion")
    /// %d items selected
    public static func itemsSelected(_ p1: Int) -> String {
      return L10n.tr("Localizable", "fileList.itemsSelected", p1, fallback: "%d items selected")
    }
  }
  public enum Permission {
    /// Full Disk Access
    public static let fullDiskAccess = L10n.tr("Localizable", "permission.fullDiskAccess", fallback: "Full Disk Access")
    /// Optional. Enables scanning of protected system folders for complete cleanup.
    public static let fullDiskAccessDesc = L10n.tr("Localizable", "permission.fullDiskAccessDesc", fallback: "Optional. Enables scanning of protected system folders for complete cleanup.")
    /// Grant Access
    public static let grantAccess = L10n.tr("Localizable", "permission.grantAccess", fallback: "Grant Access")
    /// Library Folder Access
    public static let libraryAccess = L10n.tr("Localizable", "permission.libraryAccess", fallback: "Library Folder Access")
    /// Required to scan for app caches, preferences, and support files.
    public static let libraryAccessDesc = L10n.tr("Localizable", "permission.libraryAccessDesc", fallback: "Required to scan for app caches, preferences, and support files.")
    /// App Cleaner needs access to your Library folder to find and remove app-related files.
    public static let message = L10n.tr("Localizable", "permission.message", fallback: "App Cleaner needs access to your Library folder to find and remove app-related files.")
    /// Open System Settings
    public static let openSettings = L10n.tr("Localizable", "permission.openSettings", fallback: "Open System Settings")
    /// Optional
    public static let `optional` = L10n.tr("Localizable", "permission.optional", fallback: "Optional")
    /// Permission Required
    public static let title = L10n.tr("Localizable", "permission.title", fallback: "Permission Required")
    public enum Panel {
      /// Please select your Library folder to grant access.
      public static let message = L10n.tr("Localizable", "permission.panel.message", fallback: "Please select your Library folder to grant access.")
      /// Grant Access
      public static let prompt = L10n.tr("Localizable", "permission.panel.prompt", fallback: "Grant Access")
    }
  }
  public enum Scanning {
    /// Finding related files and caches
    public static let subtitle = L10n.tr("Localizable", "scanning.subtitle", fallback: "Finding related files and caches")
    /// Scanning...
    public static let title = L10n.tr("Localizable", "scanning.title", fallback: "Scanning...")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
