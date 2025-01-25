import SwiftUI

// MARK: - Diary View
struct DiaryView: View {
    // MARK: - Properties
    @State private var selectedDate = Date()
    @State private var showingQuickNote = false
    @State private var showingNewDiary = false
    @State private var searchText = ""
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar View
                DatePickerView(selectedDate: $selectedDate)
                    .frame(height: 100)
                    .padding(.horizontal)
                
                // Diary List
                ScrollView {
                    LazyVStack(spacing: 15) {
                        // Today's Mood Card
                        if calendar.isDate(selectedDate, inSameDayAs: Date()) {
                            MoodCard()
                                .padding(.horizontal)
                        }
                        
                        // Quick Notes List
                        QuickNotesList()
                            .padding(.horizontal)
                        
                        // Diary List
                        DiaryList()
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle(NSLocalizedString("diary.title", comment: "Diary screen title"))
            .navigationBarItems(
                leading: Button(action: { showingQuickNote = true }) {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel(NSLocalizedString("diary.quick_note", comment: "Quick note button")),
                trailing: Button(action: { showingNewDiary = true }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(NSLocalizedString("diary.new_diary", comment: "New diary button"))
            )
            .sheet(isPresented: $showingQuickNote) {
                QuickNoteView()
            }
            .sheet(isPresented: $showingNewDiary) {
                NewDiaryView()
            }
        }
        .searchable(text: $searchText, prompt: NSLocalizedString("diary.search", comment: "Search diary prompt"))
    }
}

// MARK: - Date Picker View
struct DatePickerView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(-3...3, id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                    DateCell(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate))
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Date Cell View
struct DateCell: View {
    let date: Date
    let isSelected: Bool
    
    private let calendar = Calendar.current
    private let weekDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text(weekDayFormatter.string(from: date))
                .font(.caption)
                .foregroundColor(.gray)
            
            Text("\(calendar.component(.day, from: date))")
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(width: 45, height: 60)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Mood Card View
struct MoodCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("diary.mood", comment: "Today's mood section"))
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(["😊", "😐", "😢", "😡", "🤔"], id: \.self) { emoji in
                    Button(action: {}) {
                        Text(emoji)
                            .font(.system(size: 30))
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Quick Notes List View
struct QuickNotesList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("diary.quick_note", comment: "Quick notes section"))
                .font(.headline)
            
            ForEach(0..<2) { _ in
                QuickNoteCard()
            }
        }
    }
}

// MARK: - Quick Note Card View
struct QuickNoteCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(NSLocalizedString("diary.time_format", comment: "3:30 PM"))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                Text(NSLocalizedString("diary.location.library", comment: "Library location"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(NSLocalizedString("diary.sample_note", comment: "Sample quick note content"))
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

// MARK: - Diary List View
struct DiaryList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(NSLocalizedString("diary.title", comment: "Diary section"))
                .font(.headline)
            
            ForEach(0..<2) { _ in
                DiaryCard()
            }
        }
    }
}

// MARK: - Diary Card View
struct DiaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(NSLocalizedString("diary.study_diary", comment: "Study diary title"))
                    .font(.headline)
                
                Spacer()
                
                Text("😊")
            }
            
            Text(NSLocalizedString("diary.sample_content", comment: "Sample diary content"))
                .lineLimit(3)
                .font(.subheadline)
            
            HStack {
                ForEach([
                    NSLocalizedString("diary.tag.study", comment: "Study tag"),
                    NSLocalizedString("diary.tag.reflection", comment: "Reflection tag")
                ], id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Quick Note View
struct QuickNoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var noteText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $noteText)
                    .padding()
                    .background(Color(.systemBackground))
            }
            .navigationTitle(NSLocalizedString("diary.quick_note", comment: "Quick note screen title"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("common.cancel", comment: "Cancel button")) { dismiss() },
                trailing: Button(NSLocalizedString("common.save", comment: "Save button")) { dismiss() }
            )
        }
    }
}

// MARK: - New Diary View
struct NewDiaryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var diaryText = ""
    @State private var selectedMood = "😊"
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField(NSLocalizedString("diary.title_placeholder", comment: "Diary title placeholder"), text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $diaryText)
                    .padding()
                    .background(Color(.systemBackground))
            }
            .navigationTitle(NSLocalizedString("diary.new_diary", comment: "New diary screen title"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("common.cancel", comment: "Cancel button")) { dismiss() },
                trailing: Button(NSLocalizedString("common.save", comment: "Save button")) { dismiss() }
            )
        }
    }
}

#Preview {
    DiaryView()
} 