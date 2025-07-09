import Foundation

struct Watch: Identifiable, Codable {
    var id: String // ← was let
    let brand: String
    let model: String
    let year: Int
    let value: Double
    var imageURL: String? // ← was let
    let movement: String? // e.g., Automatic, Quartz
    let complications: String? // e.g., Date, Chronograph
    let style: String? // e.g., Diver, Chronograph, Dress
    let material: String? // e.g., Steel, Gold
    let rarityScore: Double? // e.g., 0-100, optional for MVP

    enum CodingKeys: String, CodingKey {
        case id, brand, model, year, value, imageURL, movement, complications, style, material, rarityScore
    }
}

