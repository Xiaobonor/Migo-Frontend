import SwiftUI

// MARK: - Group View
struct GroupView: View {
    // MARK: - Properties
    @State private var selectedTab = 0
    @State private var showingCreateGroup = false
    @State private var searchText = ""
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment Control
                Picker("", selection: $selectedTab) {
                    Text(NSLocalizedString("group.my_groups", comment: "My groups tab")).tag(0)
                    Text(NSLocalizedString("group.explore", comment: "Explore tab")).tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Main Content
                if selectedTab == 0 {
                    MyGroupsView()
                } else {
                    ExploreGroupsView()
                }
            }
            .navigationTitle(NSLocalizedString("group.title", comment: "Group screen title"))
            .navigationBarItems(trailing: Button(action: {
                showingCreateGroup = true
            }) {
                Image(systemName: "plus")
            }
            .accessibilityLabel(NSLocalizedString("group.create", comment: "Create group button")))
            .sheet(isPresented: $showingCreateGroup) {
                CreateGroupView()
            }
        }
        .searchable(text: $searchText, prompt: NSLocalizedString("group.search", comment: "Search groups prompt"))
    }
}

// MARK: - My Groups View
struct MyGroupsView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                // Active Groups
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("group.active", comment: "Active groups section"))
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
                
                // All Groups List
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("group.all", comment: "All groups section"))
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

// MARK: - Active Group Card
struct ActiveGroupCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Group Avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "person.3.fill")
                    .foregroundColor(.blue)
            }
            
            Text(NSLocalizedString("group.study_group", comment: "Study group name"))
                .font(.headline)
            
            Text(NSLocalizedString("group.members_focusing", comment: "Members focusing"))
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Text(NSLocalizedString("group.join_focus", comment: "Join focus button"))
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

// MARK: - Group List Item
struct GroupListItem: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Group Avatar
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("group.exam_prep", comment: "Exam preparation group"))
                        .font(.headline)
                    
                    Text(String(format: NSLocalizedString("group.focus_duration", comment: "Today's focus duration"), "4:30"))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Achievement Badge
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("5")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding()
            
            // Progress Bar
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

// MARK: - Explore Groups View
struct ExploreGroupsView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                // Recommended Groups
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("group.recommended", comment: "Recommended groups section"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<3) { _ in
                        RecommendedGroupCard()
                    }
                }
                
                // Popular Tags
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("group.popular_tags", comment: "Popular tags section"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach([
                                NSLocalizedString("group.tag.exam", comment: "Exam tag"),
                                NSLocalizedString("group.tag.english", comment: "English tag"),
                                NSLocalizedString("group.tag.programming", comment: "Programming tag"),
                                NSLocalizedString("group.tag.reading", comment: "Reading tag"),
                                NSLocalizedString("group.tag.writing", comment: "Writing tag")
                            ], id: \.self) { tag in
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
                
                // New Groups
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("group.new", comment: "New groups section"))
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

// MARK: - Recommended Group Card
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
                    Text(NSLocalizedString("group.english_study", comment: "English study group"))
                        .font(.headline)
                    
                    Text(String(format: NSLocalizedString("group.members_count", comment: "Members count"), 128))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text(NSLocalizedString("group.join", comment: "Join button"))
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

// MARK: - New Group Card
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
                Text(NSLocalizedString("group.new_group_name", comment: "New group name"))
                    .font(.headline)
                
                Text(NSLocalizedString("group.new_group_description", comment: "New group description"))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text(NSLocalizedString("group.join", comment: "Join button"))
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

// MARK: - Create Group View
struct CreateGroupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isPublic = true
    @State private var selectedTags: Set<String> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("group.section.basic_info", comment: "Basic info section"))) {
                    TextField(NSLocalizedString("group.name_placeholder", comment: "Group name placeholder"), text: $groupName)
                    TextEditor(text: $groupDescription)
                        .frame(height: 100)
                }
                
                Section(header: Text(NSLocalizedString("group.section.privacy", comment: "Privacy section"))) {
                    Toggle(NSLocalizedString("group.is_public", comment: "Public group toggle"), isOn: $isPublic)
                }
                
                Section(header: Text(NSLocalizedString("group.section.tags", comment: "Tags section"))) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach([
                                NSLocalizedString("group.tag.exam", comment: "Exam tag"),
                                NSLocalizedString("group.tag.english", comment: "English tag"),
                                NSLocalizedString("group.tag.programming", comment: "Programming tag"),
                                NSLocalizedString("group.tag.reading", comment: "Reading tag"),
                                NSLocalizedString("group.tag.writing", comment: "Writing tag")
                            ], id: \.self) { tag in
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
            .navigationTitle(NSLocalizedString("group.create", comment: "Create group screen title"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("common.cancel", comment: "Cancel button")) { dismiss() },
                trailing: Button(NSLocalizedString("common.create", comment: "Create button")) { dismiss() }
            )
        }
    }
}

// MARK: - Preview Provider
#Preview {
    GroupView()
} 