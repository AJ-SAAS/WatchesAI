import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case brand = "Brand"
    case value = "Value"
    case year = "Year"
    var id: String { rawValue }
}
