import SwiftUI
import PhotosUI

struct DiaryView: View {
    // MARK: - Properties
    @StateObject private var diaryService = DiaryService.shared
    @State private var selectedDate = Date()
    @State private var showingQuickNote = false
    @State private var showingNewDiary = false
    @State private var showingDiaryDetail: DiaryEntry?
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    private let calendar = Calendar.current
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Calendar View
                        DatePickerView(selectedDate: $selectedDate)
                            .padding(.horizontal)
                        
                        // Today's Mood Card
                        if calendar.isDate(selectedDate, inSameDayAs: Date()) {
                            MoodCard()
                                .padding(.horizontal)
                        }
                        
                        // Quick Notes List
                        QuickNotesList(notes: diaryService.quickNotes, onNoteTap: { note in
                            // Handle quick note tap
                        })
                        .padding(.horizontal)
                        
                        // Diary List
                        DiaryList(entries: diaryService.diaries.flatMap { $0.entries }) { entry in
                            showingDiaryDetail = entry
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await refreshData()
                }
            }
            .navigationTitle(NSLocalizedString("diary.title", comment: ""))
            .navigationBarItems(
                leading: Button(action: { showingQuickNote = true }) {
                    Image(systemName: "square.and.pencil")
                        .imageScale(.large)
                }
                .accessibilityLabel(NSLocalizedString("diary.quick_note", comment: "")),
                trailing: Button(action: { showingNewDiary = true }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                .accessibilityLabel(NSLocalizedString("diary.new_diary", comment: ""))
            )
            .sheet(isPresented: $showingQuickNote) {
                QuickNoteView()
            }
            .sheet(isPresented: $showingNewDiary) {
                NewDiaryView()
            }
            .sheet(item: $showingDiaryDetail) { entry in
                DiaryDetailView(entry: entry)
            }
        }
        .searchable(text: $searchText,
                   placement: .navigationBarDrawer(displayMode: .always),
                   prompt: NSLocalizedString("diary.search", comment: ""))
        .onChange(of: selectedDate) { oldValue, newValue in
            Task {
                await loadDiaryForDate(newValue)
            }
        }
        .task {
            await refreshData()
        }
    }
    
    // MARK: - Methods
    private func refreshData() async {
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            async let diariesTask = diaryService.getDiaries()
            async let quickNotesTask = diaryService.getQuickNotes()
            
            let (diaries, quickNotes) = try await (diariesTask, quickNotesTask)
            
            await MainActor.run {
                withAnimation {
                    diaryService.diaries = diaries
                    diaryService.quickNotes = quickNotes
                }
            }
        } catch {
            print("Error refreshing data: \(error)")
        }
    }
    
    private func loadDiaryForDate(_ date: Date) async {
        do {
            let diary = try await diaryService.getDiaryByDate(date)
            await MainActor.run {
                withAnimation {
                    if let index = diaryService.diaries.firstIndex(where: { $0.date == date }) {
                        diaryService.diaries[index] = diary
                    } else {
                        diaryService.diaries.append(diary)
                    }
                }
            }
        } catch {
            print("Error loading diary for date: \(error)")
        }
    }
} 