import Foundation

struct Card: Identifiable, Codable, Equatable {
    let id: UUID
    let question: String
    let answer: String

    init(id: UUID = UUID(), question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }

    static let examples = [
        Card(question: "What does @State do in SwiftUI?", answer: "It stores a view’s local state. When that value changes, SwiftUI updates the views that depend on it."),
        Card(question: "Which stack arranges views vertically?", answer: "VStack arranges its child views from top to bottom."),
        Card(question: "What is a binding in SwiftUI?", answer: "A two-way connection to a value owned elsewhere. Use $ to pass a binding to a state property."),
        Card(question: "What does a ZStack do?", answer: "It layers views on top of one another. Later views appear in front of earlier ones."),
        Card(question: "How do you present a modal sheet?", answer: "Attach .sheet(isPresented:) to a view and pass a Boolean binding that controls its presentation.")
    ]
}

/// Every saved card belongs to exactly one pile: remaining, practice, or memorized.
struct StudyDeck: Codable, Equatable {
    private(set) var cards: [Card]
    private(set) var remainingIDs: [UUID]
    private(set) var practiceIDs: [UUID] = []
    private(set) var memorizedIDs: [UUID] = []

    enum Result { case practice, memorized }

    init(cards: [Card] = Card.examples) {
        self.cards = cards
        remainingIDs = cards.map(\.id)
    }

    var remaining: [Card] {
        let lookup = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) })
        return remainingIDs.compactMap { lookup[$0] }
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(cards.count - remainingIDs.count) / Double(cards.count)
    }

    mutating func classify(_ id: UUID, as result: Result) {
        // Ignore a stale callback from a card that has already left the front.
        guard remainingIDs.first == id else { return }
        remainingIDs.removeFirst()
        switch result {
        case .practice: practiceIDs.append(id)
        case .memorized: memorizedIDs.append(id)
        }
    }

    @discardableResult
    mutating func add(question: String, answer: String) -> Bool {
        let question = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let answer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !question.isEmpty, !answer.isEmpty else { return false }
        let card = Card(question: question, answer: answer)
        cards.append(card)
        remainingIDs.insert(card.id, at: 0)
        return true
    }

    mutating func resetAll() {
        remainingIDs = cards.map(\.id)
        practiceIDs.removeAll()
        memorizedIDs.removeAll()
    }

    mutating func practiceAgain() {
        guard remainingIDs.isEmpty else { return }
        remainingIDs = practiceIDs
        practiceIDs.removeAll()
    }

    mutating func delete(_ id: UUID) {
        cards.removeAll { $0.id == id }
        remainingIDs.removeAll { $0 == id }
        practiceIDs.removeAll { $0 == id }
        memorizedIDs.removeAll { $0 == id }
    }
}
