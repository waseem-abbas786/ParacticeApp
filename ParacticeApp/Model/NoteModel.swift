import Foundation

struct NoteModel: Identifiable {
    let id: UUID
    var title: String
    var createdAt: Date
    var completed: Bool
    var imagePath: String?

    init(id: UUID = UUID(), title: String, createdAt: Date = Date(), completed: Bool = false, imagePath: String? = nil) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.completed = completed
        self.imagePath = imagePath
    }
}
