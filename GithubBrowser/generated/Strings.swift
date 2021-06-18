// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {

  internal enum Alert {
    internal enum Action {
      /// OK
      internal static let ok = L10n.tr("Localizable", "alert.action.ok")
    }
    internal enum Title {
      /// Error
      internal static let error = L10n.tr("Localizable", "alert.title.error")
    }
  }

  internal enum App {
    /// GithubBrowser
    internal static let title = L10n.tr("Localizable", "app.title")
  }

  internal enum Error {
    internal enum Disconnected {
      /// You are not connected to the Internet. Please, try again later.
      internal static let message = L10n.tr("Localizable", "error.disconnected.message")
    }
    internal enum ServiceUnavailable {
      /// The GitHub API is currently down. Please, try again later.
      internal static let message = L10n.tr("Localizable", "error.serviceUnavailable.message")
    }
    internal enum Unexpected {
      /// An unexpected error has occurred.
      internal static let message = L10n.tr("Localizable", "error.unexpected.message")
    }
  }

  internal enum Repositories {
    /// No repositories match your search criteria.
    internal static let emptyMessage = L10n.tr("Localizable", "repositories.emptyMessage")
    /// Enter your search criteria to find GitHub repositories.
    internal static let initialMessage = L10n.tr("Localizable", "repositories.initialMessage")
    /// Repositories
    internal static let title = L10n.tr("Localizable", "repositories.title")
    internal enum SearchBar {
      /// Enter search term
      internal static let placeholder = L10n.tr("Localizable", "repositories.searchBar.placeholder")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
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
