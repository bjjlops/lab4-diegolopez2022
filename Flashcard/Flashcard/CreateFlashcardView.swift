import SwiftUI

struct CreateFlashcardView: View {
    let onCreate: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var question = ""
    @State private var answer = ""

    private var canSave: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextField("Add a question…", text: $question, axis: .vertical)
                        .lineLimit(3...8)
                        .accessibilityLabel("Question")
                }
                Section("Answer") {
                    TextField("Add an answer…", text: $answer, axis: .vertical)
                        .lineLimit(3...8)
                        .accessibilityLabel("Answer")
                }
                Section {
                    Label("Your new card goes to the front of the deck.", systemImage: "rectangle.stack.badge.plus")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Flashcard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard canSave else { return }
                        onCreate(question, answer)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
        .tint(StudyStyle.accent)
    }
}
