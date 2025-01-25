import SwiftUI

struct GoalsView: View {
    @State private var showingNewGoal = false
    @State private var selectedFilter = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 目標進度概覽
                    GoalsOverview()
                    
                    // 篩選器
                    Picker("", selection: $selectedFilter) {
                        Text("進行中").tag(0)
                        Text("已完成").tag(1)
                        Text("全部").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // 目標列表
                    LazyVStack(spacing: 15) {
                        ForEach(0..<5) { _ in
                            GoalCard()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("目標")
            .navigationBarItems(trailing: Button(action: {
                showingNewGoal = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingNewGoal) {
                NewGoalView()
            }
        }
    }
}

struct GoalsOverview: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("本週進度")
                    .font(.headline)
                Spacer()
                Text("查看詳情")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                ProgressCircle(progress: 0.7, title: "學習", color: .blue)
                ProgressCircle(progress: 0.5, title: "運動", color: .green)
                ProgressCircle(progress: 0.3, title: "閱讀", color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct ProgressCircle: View {
    let progress: Double
    let title: String
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0))
                
                Text("\(Int(progress * 100))%")
                    .font(.system(.title3, design: .rounded))
                    .bold()
            }
            .frame(width: 80, height: 80)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct GoalCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                
                Text("學習目標")
                    .font(.headline)
                
                Spacer()
                
                Text("剩餘 7 天")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("完成 Swift UI 課程學習")
                .font(.title3)
                .fontWeight(.medium)
            
            // 進度條
            ProgressView(value: 0.6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("60% 完成")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // 標籤
                HStack {
                    ForEach(["程式", "學習"], id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
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

struct NewGoalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var endDate = Date()
    @State private var selectedCategory = 0
    @State private var selectedTags: Set<String> = []
    
    let categories = ["學習", "運動", "閱讀", "寫作", "其他"]
    let availableTags = ["程式", "英語", "健身", "閱讀", "寫作", "專注"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本資訊")) {
                    TextField("目標標題", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("類別")) {
                    Picker("選擇類別", selection: $selectedCategory) {
                        ForEach(0..<categories.count) { index in
                            Text(categories[index]).tag(index)
                        }
                    }
                }
                
                Section(header: Text("截止日期")) {
                    DatePicker("選擇日期", selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text("標籤")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableTags, id: \.self) { tag in
                                TagButton(tag: tag, isSelected: selectedTags.contains(tag)) {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag)
                                    } else {
                                        selectedTags.insert(tag)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("提醒")) {
                    Toggle("每日提醒", isOn: .constant(true))
                    Toggle("完成提醒", isOn: .constant(true))
                }
            }
            .navigationTitle("新增目標")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("創建") { dismiss() }
            )
        }
    }
}

#Preview {
    GoalsView()
} 