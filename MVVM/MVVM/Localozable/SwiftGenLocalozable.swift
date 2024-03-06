// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Account
  internal static let account = L10n.tr("Localizable", "account", fallback: "Account")
  /// Add to Cart
  internal static let addToCart = L10n.tr("Localizable", "addToCart", fallback: "Add to Cart")
  /// Cart
  internal static let cart = L10n.tr("Localizable", "cart", fallback: "Cart")
  /// Location is not available
  internal static let cityError = L10n.tr("Localizable", "cityError", fallback: "Location is not available")
  /// Detailed information about the dish is not available
  internal static let detailError = L10n.tr("Localizable", "detailError", fallback: "Detailed information about the dish is not available")
  /// Localizable.strings
  ///   MVVM
  /// 
  ///   Created by Висент Щепетков on 23.02.2024.
  internal static let main = L10n.tr("Localizable", "main", fallback: "Main")
  /// There is no access to the Internet and local data.
  internal static let networkError = L10n.tr("Localizable", "networkError", fallback: "There is no access to the Internet and local data.")
  /// Search
  internal static let search = L10n.tr("Localizable", "search", fallback: "Search")
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
