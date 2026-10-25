import SwiftUI

struct ContentView: View {
    @State private var store = CardStore()
    @State private var creatingCard = false
    @State private var showingLibrary = false
    @State private var sessionID = UUID()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    header
                    progress
                    deck
                        .frame(height: max(300, min(460, geometry.size.height - 330)))
                        .padding(.bottom, 12)
                    if let card = store.deck.remaining.first {
                        HStack(spacing: 14) {
                            sortButton("More practice", icon: "arrow.left", color: StudyStyle.practice) {
                                classify(card, as: .practice)
                            }
                            sortButton("Memorized", icon: "arrow.right", color: StudyStyle.memorized) {
                                classify(card, as: .memorized)
                            }
                        }
                        Text("Swipe left to practice · Swipe right if you know it")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, -10)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: 580)
                .frame(maxWidth: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(StudyStyle.paper)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 3) {
                Text("Diego Lopez · Z23661298").font(.footnote.weight(.medium))
                Text("FAU • Lab 4").font(.caption2)
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(StudyStyle.paper)
        }
        .tint(StudyStyle.accent)
        .sheet(isPresented: $creatingCard) {
            CreateFlashcardView { question, answer in store.add(question: question, answer: answer) }
        }
        .sheet(isPresented: $showingLibrary) { CardLibraryView(store: store) }
        .alert("Storage notice", isPresented: Binding(
            get: { store.storageMessage != nil },
            set: { if !$0 { store.storageMessage = nil } }
        )) {
            Button("OK") { store.storageMessage = nil }
        } message: {
            Text(store.storageMessage ?? "")
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Flashcards").font(.largeTitle.weight(.bold))
                Text("Swift fundamentals").font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button { showingLibrary = true } label: {
                Image(systemName: "rectangle.stack").font(.title3).frame(width: 44, height: 44)
            }
            .accessibilityLabel("Manage cards")
            Button { creatingCard = true } label: {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(StudyStyle.accent, in: Circle())
            }
            .accessibilityLabel("Add flashcard")
        }
    }

    private var progress: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(store.deck.remainingIDs.count) left").font(.headline)
                Spacer()
                Text("\(store.deck.cards.count) cards in your deck").font(.caption).foregroundStyle(.secondary)
            }
            ProgressView(value: store.deck.progress).accessibilityLabel("Deck progress")
            HStack {
                Label("\(store.deck.practiceIDs.count) More practice", systemImage: "arrow.counterclockwise")
                    .foregroundStyle(StudyStyle.practice)
                Spacer()
                Label("\(store.deck.memorizedIDs.count) Memorized", systemImage: "checkmark.circle")
                    .foregroundStyle(StudyStyle.memorized)
            }
            .font(.caption.weight(.semibold))
        }
    }

    private var deck: some View {
        ZStack {
            if let front = store.deck.remaining.first {
                ForEach(Array(store.deck.remaining.prefix(3).enumerated()).reversed(), id: \.element.id) { index, _ in
                    if index > 0 {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(StudyStyle.accent.opacity(index == 1 ? 0.12 : 0.07))
                            .padding(.horizontal, CGFloat(index) * 10)
                            .offset(y: CGFloat(index) * 9)
                            .accessibilityHidden(true)
                    }
                }
                CardView(card: front) { result in classify(front, as: result) }.id(front.id)
            } else {
                completedDeck
            }
        }
        // Reset the view even when a repeated round starts with the same card.
        .id(sessionID)
    }

    private var completedDeck: some View {
        VStack(spacing: 18) {
            Image(systemName: store.deck.cards.isEmpty ? "rectangle.stack.badge.plus" : "checkmark.seal")
                .font(.system(size: 54, weight: .light))
                .foregroundStyle(StudyStyle.accent)
            Text(store.deck.cards.isEmpty ? "Your deck starts here" : "Round complete!").font(.title2.bold())
            Text(store.deck.cards.isEmpty
                 ? "Tap + to add your first flashcard."
                 : "\(store.deck.memorizedIDs.count) memorized. \(store.deck.practiceIDs.count) ready for another look.")
                .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button("More Practice") {
                store.practiceAgain()
                sessionID = UUID()
            }
            .buttonStyle(.borderedProminent)
            .disabled(store.deck.practiceIDs.isEmpty)
            Button("Reset All Cards") {
                store.resetAll()
                sessionID = UUID()
            }
            .buttonStyle(.bordered)
            .disabled(store.deck.cards.isEmpty)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 28))
    }

    private func sortButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48)
                .foregroundStyle(color)
                .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func classify(_ card: Card, as result: StudyDeck.Result) {
        withAnimation(.easeInOut(duration: 0.2)) { store.classify(card.id, as: result) }
    }
}

#Preview { ContentView() }
