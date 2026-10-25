import Foundation

@main
struct DeckChecks {
    struct Failure: Error { let message: String }

    @MainActor
    static func main() throws {
        var checks = 0
        func expect(_ condition: Bool, _ message: String) throws {
            guard condition else { throw Failure(message: message) }
            checks += 1
        }

        let cards = [Card(question: "Q1", answer: "A1"), Card(question: "Q2", answer: "A2"), Card(question: "Q3", answer: "A3")]
        var deck = StudyDeck(cards: cards)
        try expect(deck.remaining == cards && deck.progress == 0, "Initial deck")
        deck.classify(cards[0].id, as: .practice)
        deck.classify(cards[0].id, as: .memorized)
        try expect(deck.practiceIDs == [cards[0].id] && deck.memorizedIDs.isEmpty, "Duplicate callback ignored")
        let unfinished = deck
        deck.practiceAgain()
        try expect(deck == unfinished, "Practice reset cannot discard unreviewed cards")
        deck.classify(cards[1].id, as: .memorized)
        deck.classify(cards[2].id, as: .practice)
        try expect(deck.remaining.isEmpty && deck.progress == 1, "Round complete")
        deck.practiceAgain()
        try expect(deck.remainingIDs == [cards[0].id, cards[2].id], "Only practice cards return")
        try expect(deck.practiceIDs.isEmpty && deck.memorizedIDs == [cards[1].id], "Memorized pile preserved")
        deck.classify(cards[0].id, as: .memorized)
        deck.classify(cards[2].id, as: .memorized)
        try expect(deck.memorizedIDs.count == 3, "Practice cards can become memorized")
        let completed = deck
        deck.practiceAgain()
        try expect(deck == completed, "No practice cards is a safe no-op")
        deck.resetAll()
        deck.resetAll()
        try expect(deck.remaining == cards && deck.practiceIDs.isEmpty && deck.memorizedIDs.isEmpty, "Repeated reset restores all cards once")
        try expect(!deck.add(question: " \n", answer: "Valid"), "Whitespace question rejected")
        try expect(!deck.add(question: "Valid", answer: "\t "), "Whitespace answer rejected")
        try expect(deck.add(question: "  New Q\n", answer: " New A "), "Valid card accepted")
        let added = deck.remaining[0]
        try expect(added.question == "New Q" && added.answer == "New A", "Text trimmed and new card at front")
        deck.delete(added.id)
        try expect(deck.remaining == cards && deck.cards.count == 3, "Delete from active pile")
        deck.classify(cards[0].id, as: .practice)
        deck.classify(cards[1].id, as: .memorized)
        deck.delete(cards[0].id)
        deck.delete(cards[1].id)
        try expect(deck.practiceIDs.isEmpty && deck.memorizedIDs.isEmpty && deck.cards == [cards[2]], "Delete from both reviewed piles")
        let decoded = try JSONDecoder().decode(StudyDeck.self, from: JSONEncoder().encode(deck))
        try expect(decoded == deck, "JSON preserves card identity and piles")
        deck.delete(cards[2].id)
        deck.resetAll()
        try expect(deck.cards.isEmpty && deck.remaining.isEmpty && deck.progress == 0, "Empty deck reset and progress")
        try expect(deck.add(question: "Restart", answer: "Works"), "Create from empty deck")

        let suite = "Lab4Tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = CardStore(defaults: defaults)
        store.add(question: "Persistent Q", answer: "Persistent A")
        let savedID = store.deck.remaining[0].id
        store.classify(savedID, as: .practice)
        let reopened = CardStore(defaults: defaults)
        try expect(reopened.deck == store.deck, "Relaunch preserves custom cards and session state")
        reopened.delete(savedID)
        let reopenedAgain = CardStore(defaults: defaults)
        try expect(!reopenedAgain.deck.cards.contains { $0.id == savedID }, "Deletion persists")
        print("PASS: \(checks) deck and persistence checks")
    }
}
