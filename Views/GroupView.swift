import SwiftUI

struct GroupView: View {
    @State private var selectedTab = 0
    @State private var showingCreateGroup = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 分段控制器
                Picker("", selection: $selectedTab) {
                    Text("我的小組").tag(0)
                    Text("探索").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 主要內容
                if selectedTab == 0 {
                    MyGroupsView()
                } else {
                    ExploreGroupsView()
                }
            }
            .navigationTitle("小組")
            .navigationBarItems(trailing: Button(action: {
                showingCreateGroup = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView()
            }
        }
        .searchable(text: $searchText, prompt: "搜尋小組...")
    }
}

struct MyGroupsView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                // 活躍小組
                VStack(alignment: .leading) {
                    Text("活躍小組")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                ActiveGroupCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 我的小組列表
                VStack(alignment: .leading) {
                    Text("所有小組")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<5) { _ in
                        GroupListItem()
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct ActiveGroupCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            // 小組頭像
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
            }
            
            Text("讀書小組")
                .font(.headline)
            
            Text("3人正在專注")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Text("加入專注")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .cornerRadius(15)
            }
        }
        .frame(width: 120)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

struct GroupListItem: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // 小組頭像
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading) {
                    Text("考研互助組")
                        .font(.headline)
                    
                    Text("今日專注總時長：4小時30分")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 成就徽章
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("5")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding()
            
            // 進度條
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * 0.7, height: 4)
                }
            }
            .frame(height: 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct ExploreGroupsView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                // 推薦小組
                VStack(alignment: .leading) {
                    Text("為你推薦")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<3) { _ in
                        RecommendedGroupCard()
                    }
                }
                
                // 熱門標籤
                VStack(alignment: .leading) {
                    Text("熱門標籤")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(["考研", "英語", "程式設計", "閱讀", "寫作"], id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.subheadline)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 最新小組
                VStack(alignment: .leading) {
                    Text("最新小組")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<5) { _ in
                        NewGroupCard()
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct RecommendedGroupCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading) {
                    Text("英語學習小組")
                        .font(.headline)
                    
                    Text("已有 128 人加入")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text("加入")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }
            
            Text("一起來提升英語能力吧！我們有專業的學習資源和互助系統...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)
            
            HStack {
                ForEach(["英語", "學習", "互助"], id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .foregroundColor(.blue)
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
        .padding(.horizontal)
    }
}

struct NewGroupCard: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text("程式設計交流組")
                    .font(.headline)
                
                Text("剛剛創建")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("加入")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 1)
        .padding(.horizontal)
    }
}

struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isPrivate = false
    @State private var selectedTags: Set<String> = []
    
    let availableTags = ["學習", "考研", "英語", "程式", "閱讀", "寫作", "互助"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本資訊")) {
                    TextField("小組名稱", text: $groupName)
                    TextEditor(text: $groupDescription)
                        .frame(height: 100)
                    Toggle("私密小組", isOn: $isPrivate)
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
            }
            .navigationTitle("創建小組")
            .navigationBarItems(
                leading: Button("取消") { dismiss() },
                trailing: Button("創建") { dismiss() }
            )
        }
    }
}

struct TagButton: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("#\(tag)")
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.blue.opacity(0.1))
                .foregroundColor(isSelected ? .white : .blue)
                .cornerRadius(15)
        }
    }
}

#Preview {
    GroupView()
} 