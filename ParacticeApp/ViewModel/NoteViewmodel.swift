import Foundation
import CoreData
import Combine
import UIKit

@MainActor
class NoteViewmodel: ObservableObject {
    @Published var notes : [NoteModel] = []
    @Published var newTitle : String = ""
    @Published var validationMessage : String = ""

    @Published var showErrorMessage : String?
    @Published var showError : Bool = false

    @Published var showSuccessMessage : String?
    @Published var showSuccess : Bool  = false

    private let filemanger = FilemanagerService.shared
    private let context : NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init (context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.context = context
        setupValidation()
        Task { await fetchNotes() }
        Task {
            await apiFetch()
        }
      
    }

    func setupValidation () {
        $newTitle
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)    // fixed debounce signature
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).count >= 4
                   ? ""
                   : "Title must be at least 4 characters" }           // fixed logic & message
            .receive(on: RunLoop.main)
            .assign(to: \.validationMessage, on: self)
            .store(in: &cancellables)
    }

    private func handleError (_ appError : AppError) {
        showErrorMessage = appError.localizedDescription
        showError = true
    }
    private func handleSucess (_ meessage : String) {
        showSuccessMessage = meessage
        showSuccess = true
    }


    func fetchNotes () async {
        let request : NSFetchRequest <CDNotes> = CDNotes.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDNotes.createdAt, ascending: false)]
        do {
            let result = try context.fetch(request)
            notes = result.compactMap({ cdnotes in
                NoteModel(
                    id: cdnotes.id ?? UUID(),
                    title: cdnotes.title ?? "",
                    createdAt: cdnotes.createdAt ?? .now,
                    completed: cdnotes.completed,
                    imagePath: cdnotes.imagePath
                )
            })
        } catch  {
            handleError(.coreDataFetch)
        }
    }

    func addNote(image: UIImage? = nil) async {

        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 4 else {
            validationMessage = "Title must be at least 4 characters"
            return
        }

        let note = NoteModel(title: trimmed)
        let cdNote = CDNotes(context: context)
        cdNote.id = note.id
        cdNote.title = note.title
        cdNote.createdAt = note.createdAt
        cdNote.completed = note.completed

        if let image {
            if let path = filemanger.saveImage(image, id: note.id) {
                cdNote.imagePath = path
            } else {
                handleError(.imageSave)
            }
        }

        await PersistenceController.shared.save()
        await fetchNotes()
        handleSucess("Note added successfully ✅")
        newTitle = ""
    }

    func deleteNote (_ note: NoteModel) async {
        let request : NSFetchRequest<CDNotes> = CDNotes.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)  // correct predicate spacing

        do {
            if let cdnote = try context.fetch(request).first {
                if let path = cdnote.imagePath {
                    filemanger.deleteImage(filename: path)
                }
                context.delete(cdnote)
                await PersistenceController.shared.save()
                await fetchNotes()
                handleSucess("Successfully deleted the item")
            }
        } catch  {
            handleError(.coreDataDelete)
        }
    }

    func toggleCompletion (_ note : NoteModel) async {
        let request : NSFetchRequest<CDNotes> = CDNotes.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg) // FIXED: space and placeholder

        do {
            if let cdnote = try context.fetch(request).first {
                cdnote.completed.toggle()
                await PersistenceController.shared.save()
                await fetchNotes()
                handleSucess(cdnote.completed  ? "Marked as Completed" : "Marked as Pending")
            }
        } catch  {
            handleError(.toggleError)
        }
    }

    func apiFetch () async {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos?_limit=5") else { return }
        do {
            let (data,_) =  try await URLSession.shared.data(from: url)
            let apinotes = try JSONDecoder().decode([NoteApiModel].self, from: data)
            for apinote in apinotes {
                let request : NSFetchRequest <CDNotes> = CDNotes.fetchRequest()
                request.predicate = NSPredicate(format: "title == %@", apinote.title)
                let existing = try context.fetch(request).first
                if existing == nil {
                    let note = CDNotes(context: context)
                    note.id = UUID()
                    note.title = apinote.title
                    note.createdAt = .now
                    note.completed = apinote.completed
                }
            }
            await PersistenceController.shared.save()
            await fetchNotes()
            handleSucess("Downloaded notes from API")
        } catch  {
            handleError(.apiError)
        }
    }
}
