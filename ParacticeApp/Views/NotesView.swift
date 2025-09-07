//
//  NotesView.swift
//  ParacticeApp
//
//  Created by Waseem Abbas on 06/09/2025.
//
import SwiftUI

struct NotesView: View {
    @StateObject private var vm = NoteViewmodel()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        TextField("Enter note title...", text: $vm.newTitle)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Add") {
                            Task { await vm.addNote() }
                        }
                    }
                    .padding()

                    Button("Download from API") {
                        Task { await vm.apiFetch() }
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    if !vm.validationMessage.isEmpty {
                        Text(vm.validationMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    List {
                        ForEach(vm.notes) { note in
                            HStack {
                                Button {
                                    Task { await vm.toggleCompletion(note) }
                                } label: {
                                    Image(systemName: note.completed ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(note.completed ? .green : .gray)
                                }

                                VStack(alignment: .leading) {
                                    Text(note.title)
                                        .strikethrough(note.completed, color: .black)

                                    Text(note.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if let path = note.imagePath,
                                   let image = FilemanagerService.shared.loadImage(filename: path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task { await vm.deleteNote(note) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                if vm.showSuccess, let message = vm.showSuccessMessage {
                    VStack {
                        Spacer()
                        Text(message)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.9))
                            .cornerRadius(12)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {
                                        vm.showSuccess = false
                                        vm.showSuccessMessage = nil
                                    }
                                }
                            }
                    }
                    .animation(.spring(), value: vm.showSuccess)
                }
            }
            .navigationTitle("My Notes")
            .onAppear {
                vm.setupValidation()
                Task { await vm.fetchNotes() }
            }
            .alert(isPresented: $vm.showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(vm.showErrorMessage ?? "Something went wrong"),
                    dismissButton: .default(Text("OK")) {
                        vm.showErrorMessage = nil
                    }
                )
            }
        }
    }
}



#Preview {
    NotesView()
}
