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
  /// All menu
  internal static let allMenu = L10n.tr("Localizable", "allMenu", fallback: "All menu")
  /// Cart
  internal static let cart = L10n.tr("Localizable", "cart", fallback: "Cart")
  /// Location is not available
  internal static let cityError = L10n.tr("Localizable", "cityError", fallback: "Location is not available")
  /// Failed to connect to the network. Please check your internet connection.
  internal static let connectionError = L10n.tr("Localizable", "connectionError", fallback: "Failed to connect to the network. Please check your internet connection.")
  /// Detailed information about the dish is not available
  internal static let detailError = L10n.tr("Localizable", "detailError", fallback: "Detailed information about the dish is not available")
  /// Error
  internal static let error = L10n.tr("Localizable", "Error", fallback: "Error")
  /// With fish
  internal static let fish = L10n.tr("Localizable", "fish", fallback: "With fish")
  /// Access to geolocation is prohibited.
  internal static let locationDenied = L10n.tr("Localizable", "locationDenied", fallback: "Access to geolocation is prohibited.")
  /// Localizable.strings
  ///   MVVM
  /// 
  ///   Created by Висент Щепетков on 23.02.2024.
  internal static let main = L10n.tr("Localizable", "main", fallback: "Main")
  /// There is no access to the Internet.
  internal static let networkError = L10n.tr("Localizable", "networkError", fallback: "There is no access to the Internet.")
  /// No internet access.
  internal static let noInternetAccess = L10n.tr("Localizable", "noInternetAccess", fallback: "No internet access.")
  /// With rice
  internal static let rice = L10n.tr("Localizable", "rice", fallback: "With rice")
  /// Salads
  internal static let salad = L10n.tr("Localizable", "salad", fallback: "Salads")
  /// Search
  internal static let search = L10n.tr("Localizable", "search", fallback: "Search")
  /// A server error has occurred. Please try again later.
  internal static let serverError = L10n.tr("Localizable", "serverError", fallback: "A server error has occurred. Please try again later.")
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
