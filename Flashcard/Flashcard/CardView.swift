import SwiftUI

enum StudyStyle {
    static let accent = Color(red: 0.34, green: 0.29, blue: 0.72)
    static let paper = Color(uiColor: .systemGroupedBackground)
    static let practice = Color(red: 0.76, green: 0.23, blue: 0.24)
    static let memorized = Color(red: 0.10, green: 0.48, blue: 0.34)
}

struct CardView: View {
    let card: Card
    let onClassify: (StudyDeck.Result) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingAnswer = false
    @State private var offset: CGSize = .zero
    @State private var dismissing = false

    private var swipeColor: Color {
        offset.width < 0 ? StudyStyle.practice : StudyStyle.memorized
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Label(showingAnswer ? "ANSWER" : "QUESTION", systemImage: showingAnswer ? "lightbulb" : "questionmark.circle")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                Spacer()
                Image(systemName: "sparkle").font(.title3)
            }
            .foregroundStyle(StudyStyle.accent)
            Spacer(minLength: 0)
            ScrollView {
                Text(showingAnswer ? card.answer : card.question)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentTransition(.opacity)
            }
            .defaultScrollAnchor(.center)
            .scrollBounceBehavior(.basedOnSize)
            Spacer(minLength: 0)
            Label(showingAnswer ? "Tap to see question" : "Tap to reveal answer", systemImage: "hand.tap")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(swipeColor.opacity(min(abs(offset.width) / 230, 0.24)))
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(StudyStyle.accent.opacity(0.16), lineWidth: 1)
        }
        .overlay(alignment: .top) {
            if abs(offset.width) > 20 {
                Text(offset.width < 0 ? "MORE PRACTICE" : "MEMORIZED")
                    .font(.caption.weight(.heavy))
                    .tracking(1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundStyle(.white)
                    .background(swipeColor, in: Capsule())
                    .padding(.top, 66)
            }
        }
        .shadow(color: StudyStyle.accent.opacity(0.10), radius: 20, y: 10)
        .contentShape(RoundedRectangle(cornerRadius: 28))
        .offset(x: offset.width, y: offset.height * 0.12)
        .rotationEffect(.degrees(reduceMotion ? 0 : Double(offset.width / 24)))
        .onTapGesture {
            guard !dismissing else { return }
            withAnimation(.easeInOut(duration: reduceMotion ? 0 : 0.2)) { showingAnswer.toggle() }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 15)
                .onChanged { value in
                    guard !dismissing, abs(value.translation.width) > abs(value.translation.height) else { return }
                    offset = value.translation
                }
                .onEnded { value in
                    guard !dismissing else { return }
                    if abs(value.translation.width) > 100, abs(value.translation.width) > abs(value.translation.height) {
                        dismissing = true
                        let result: StudyDeck.Result = value.translation.width < 0 ? .practice : .memorized
                        withAnimation(.easeIn(duration: reduceMotion ? 0 : 0.2)) {
                            offset.width = value.translation.width < 0 ? -650 : 650
                        } completion: {
                            onClassify(result)
                        }
                    } else {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { offset = .zero }
                    }
                }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showingAnswer ? "Answer: \(card.answer)" : "Question: \(card.question)")
        .accessibilityHint("Double tap to flip. Use the buttons below or custom actions to sort this card.")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { showingAnswer.toggle() }
        .accessibilityAction(named: "More practice") { onClassify(.practice) }
        .accessibilityAction(named: "Memorized") { onClassify(.memorized) }
    }
}
