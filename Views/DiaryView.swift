import SwiftUI

struct DiaryView: View {
    @State private var selectedDate = Date()
    @State private var showingQuickNote = false
    @State private var showingNewDiary = false
    @State private var searchText = ""
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 日曆視圖
                DatePickerView(selectedDate: $selectedDate)
                    .frame(height: 100)
                    .padding(.horizontal)
                
                // 日記列表
                ScrollView {
                    LazyVStack(spacing: 15) {
                        // 今日心情卡片
                        if calendar.isDate(selectedDate, inSameDayAs: Date()) {
                            MoodCard()
                                .padding(.horizontal)
                        }
                        
                        // 隨手記列表
                        QuickNotesList()
                            .padding(.horizontal)
                        
                        // 日記列表
                        DiaryList()
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("日記")
            .navigationBarItems(
                leading: Button(action: { showingQuickNote = true }) {
                    Image(systemName: "square.and.pencil")
                },
                trailing: Button(action: { showingNewDiary = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingQuickNote) {
                QuickNoteView()
            }
            .sheet(isPresented: $showingNewDiary) {
                NewDiaryView()
            }
        }
        .searchable(text: $searchText, prompt: "搜尋日記...")
    }
}

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

struct MoodCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今日心情")
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

struct QuickNotesList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("隨手記")
                .font(.headline)
            
            ForEach(0..<2) { _ in
                QuickNoteCard()
            }
        }
    }
}

struct QuickNoteCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("下午 3:30")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                Text("圖書館")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("今天在圖書館學習了新的概念，感覺收穫很多...")
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct DiaryList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("日記")
                .font(.headline)
            
            ForEach(0..<2) { _ in
                DiaryCard()
            }
        }
    }
}

struct DiaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("學習日記")
                    .font(.headline)
                
                Spacer()
                
                Text("😊")
            }
            
            Text("今天的學習計劃完成得不錯，雖然遇到了一些困難...")
                .lineLimit(3)
                .font(.subheadline)
            
            HStack {
                ForEach(["學習", "反思"], id: \.self) { tag in
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
            .navigationTitle("隨手記")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("儲存") { dismiss() }
            )
        }
    }
}

struct NewDiaryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var diaryText = ""
    @State private var selectedMood = "😊"
    @State private var title = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("標題")) {
                    TextField("輸入標題", text: $title)
                }
                
                Section(header: Text("心情")) {
                    HStack {
                        ForEach(["😊", "😐", "😢", "😡", "🤔"], id: \.self) { mood in
                            Button(action: { selectedMood = mood }) {
                                Text(mood)
                                    .font(.system(size: 25))
                                    .opacity(selectedMood == mood ? 1 : 0.5)
                            }
                        }
                    }
                }
                
                Section(header: Text("內容")) {
                    TextEditor(text: $diaryText)
                        .frame(height: 200)
                }
            }
            .navigationTitle("新增日記")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("儲存") { dismiss() }
            )
        }
    }
}

#Preview {
    DiaryView()
} 