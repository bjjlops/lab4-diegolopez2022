import SwiftUI

struct CardLibraryView: View {
    let store: CardStore
    @Environment(\.dismiss) private var dismiss
    @State private var cardToDelete: Card?

    var body: some View {
        NavigationStack {
            List {
                if store.deck.cards.isEmpty {
                    ContentUnavailableView("No cards yet", systemImage: "rectangle.stack", description: Text("Close this sheet and tap + to create a flashcard."))
                }
                ForEach(store.deck.cards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.question).font(.headline)
                        Text(card.answer).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 5)
                    .swipeActions {
                        Button("Delete", role: .destructive) { cardToDelete = card }
                    }
                    .contextMenu {
                        Button("Delete card", systemImage: "trash", role: .destructive) { cardToDelete = card }
                    }
                }
            }
            .navigationTitle("Your Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Delete this flashcard?", isPresented: Binding(
                get: { cardToDelete != nil },
                set: { if !$0 { cardToDelete = nil } }
            ), titleVisibility: .visible) {
                Button("Delete Card", role: .destructive) {
                    if let card = cardToDelete { store.delete(card.id) }
                    cardToDelete = nil
                }
                Button("Cancel", role: .cancel) { cardToDelete = nil }
            } message: {
                Text("This removes the card from your saved deck and all practice piles.")
            }
        }
        .tint(StudyStyle.accent)
    }
}
