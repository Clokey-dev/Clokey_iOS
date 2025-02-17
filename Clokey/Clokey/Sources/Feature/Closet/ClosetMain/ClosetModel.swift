import Foundation
import UIKit

struct ClosetModel: Equatable {
    let id: Int
    let image: String
    let count: Int
    let name: String
    
    static func == (lhs: ClosetModel, rhs: ClosetModel) -> Bool {
        return lhs.id == rhs.id  // id로 비교
    }
}
