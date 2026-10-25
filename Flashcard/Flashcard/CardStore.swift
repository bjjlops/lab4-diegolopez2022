import Foundation
import Observation

@Observable
final class CardStore {
    private(set) var deck: StudyDeck
    var storageMessage: String?
    private let defaults: UserDefaults
    private let storageKey = "flashcards.studyDeck.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: storageKey) {
            do {
                deck = try JSONDecoder().decode(StudyDeck.self, from: data)
            } catch {
                deck = StudyDeck()
                storageMessage = "The saved deck could not be read. The sample deck is available for this session."
            }
        } else {
            deck = StudyDeck()
        }
    }

    func classify(_ id: UUID, as result: StudyDeck.Result) {
        deck.classify(id, as: result)
        save()
    }

    func add(question: String, answer: String) {
        guard deck.add(question: question, answer: answer) else { return }
        save()
    }

    func resetAll() { deck.resetAll(); save() }
    func practiceAgain() { deck.practiceAgain(); save() }
    func delete(_ id: UUID) { deck.delete(id); save() }

    private func save() {
        do {
            defaults.set(try JSONEncoder().encode(deck), forKey: storageKey)
        } catch {
            storageMessage = "Your changes are available now, but could not be saved for the next launch."
        }
    }
}
