import SwiftUI

extension Double {
    var currencyFormat: String {
        String(format: "%.2f", self)
    }
}
