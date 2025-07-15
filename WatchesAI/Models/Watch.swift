import Foundation

struct Watch: Identifiable, Codable, Equatable {
    let id: String
    let brand: String
    let model: String
    let year: String
    let movement: String
    let material: String
    let style: String
    let value: Double
    let type: String
    let complications: String
    let imageURL: String?
    
    static func == (lhs: Watch, rhs: Watch) -> Bool {
        lhs.id == rhs.id
    }
}
