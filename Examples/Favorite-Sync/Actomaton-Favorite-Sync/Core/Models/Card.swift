import Foundation
import SwiftUI

struct Card: Hashable
{
    let id: ID
    var symbol: String
    var title: String
    var description: String

    typealias ID = String
}

@dynamicMemberLookup
struct CardWithFavorite: Hashable
{
    var card: Card
    var color: Color
    var isFavorite: Bool

    var id: Card.ID { card.id }

    subscript<T>(dynamicMember keyPath: WritableKeyPath<Card, T>) -> T
    {
        get { card[keyPath: keyPath] }
        set { card[keyPath: keyPath] = newValue }
    }
}
