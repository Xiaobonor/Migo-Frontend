import SwiftUI

// MARK: - Goals View
struct GoalsView: View {
    // MARK: - Properties
    @State private var showingNewGoal = false
    @State private var selectedFilter = 0
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Goals Overview
                    GoalsOverview()
                    
                    // Filter
                    Picker("", selection: $selectedFilter) {
                        Text(NSLocalizedString("goals.in_progress", comment: "In progress filter")).tag(0)
                        Text(NSLocalizedString("goals.completed", comment: "Completed filter")).tag(1)
                        Text(NSLocalizedString("goals.all", comment: "All filter")).tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Goals List
                    LazyVStack(spacing: 15) {
                        ForEach(0..<5) { _ in
                            GoalCard()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(NSLocalizedString("goals.title", comment: "Goals screen title"))
            .navigationBarItems(trailing: Button(action: {
                showingNewGoal = true
            }) {
                Image(systemName: "plus")
            }
            .accessibilityLabel(NSLocalizedString("goals.new", comment: "New goal button")))
            .sheet(isPresented: $showingNewGoal) {
                NewGoalView()
            }
        }
    }
}

// MARK: - Goals Overview
struct GoalsOverview: View {
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text(NSLocalizedString("goals.weekly_progress", comment: "Weekly progress title"))
                    .font(.headline)
                Spacer()
                Text(NSLocalizedString("goals.view_details", comment: "View details button"))
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                ProgressCircle(progress: 0.7, title: NSLocalizedString("goals.category.study", comment: "Study category"), color: .blue)
                ProgressCircle(progress: 0.5, title: NSLocalizedString("goals.category.exercise", comment: "Exercise category"), color: .green)
                ProgressCircle(progress: 0.3, title: NSLocalizedString("goals.category.reading", comment: "Reading category"), color: .orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

// MARK: - Progress Circle
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
                
                Text(String(format: NSLocalizedString("goals.progress_format", comment: "Progress percentage"), Int(progress * 100)))
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

// MARK: - Goal Card
struct GoalCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                
                Text(NSLocalizedString("goals.study_goal", comment: "Study goal title"))
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: NSLocalizedString("goals.days_remaining", comment: "Days remaining"), 7))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(NSLocalizedString("goals.sample_goal", comment: "Sample goal content"))
                .font(.title3)
                .fontWeight(.medium)
            
            // Progress Bar
            ProgressView(value: 0.6)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text(String(format: NSLocalizedString("goals.completion_percentage", comment: "Completion percentage"), 60))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Tags
                HStack {
                    ForEach([
                        NSLocalizedString("goals.tag.programming", comment: "Programming tag"),
                        NSLocalizedString("goals.tag.learning", comment: "Learning tag")
                    ], id: \.self) { tag in
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

// MARK: - New Goal View
struct NewGoalView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var endDate = Date()
    @State private var selectedCategory = 0
    @State private var selectedTags: Set<String> = []
    
    let categories = [
        NSLocalizedString("goals.category.study", comment: "Study category"),
        NSLocalizedString("goals.category.exercise", comment: "Exercise category"),
        NSLocalizedString("goals.category.reading", comment: "Reading category"),
        NSLocalizedString("goals.category.writing", comment: "Writing category"),
        NSLocalizedString("goals.category.other", comment: "Other category")
    ]
    
    let availableTags = [
        NSLocalizedString("goals.tag.programming", comment: "Programming tag"),
        NSLocalizedString("goals.tag.english", comment: "English tag"),
        NSLocalizedString("goals.tag.fitness", comment: "Fitness tag"),
        NSLocalizedString("goals.tag.reading", comment: "Reading tag"),
        NSLocalizedString("goals.tag.writing", comment: "Writing tag"),
        NSLocalizedString("goals.tag.focus", comment: "Focus tag")
    ]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("goals.section.basic_info", comment: "Basic info section"))) {
                    TextField(NSLocalizedString("goals.title_placeholder", comment: "Goal title placeholder"), text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text(NSLocalizedString("goals.section.category", comment: "Category section"))) {
                    Picker(NSLocalizedString("goals.select_category", comment: "Select category"), selection: $selectedCategory) {
                        ForEach(0..<categories.count) { index in
                            Text(categories[index]).tag(index)
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("goals.section.end_date", comment: "End date section"))) {
                    DatePicker(NSLocalizedString("goals.select_date", comment: "Select date"), selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text(NSLocalizedString("goals.section.tags", comment: "Tags section"))) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(availableTags, id: \.self) { tag in
                                TagButton(
                                    tag: tag,
                                    isSelected: selectedTags.contains(tag),
                                    action: {
                                        if selectedTags.contains(tag) {
                                            selectedTags.remove(tag)
                                        } else {
                                            selectedTags.insert(tag)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                
                Section(header: Text(NSLocalizedString("goals.section.reminders", comment: "Reminders section"))) {
                    Toggle(NSLocalizedString("goals.daily_reminder", comment: "Daily reminder toggle"), isOn: .constant(true))
                    Toggle(NSLocalizedString("goals.completion_reminder", comment: "Completion reminder toggle"), isOn: .constant(true))
                }
            }
            .navigationTitle(NSLocalizedString("goals.new", comment: "New goal screen title"))
            .navigationBarItems(
                leading: Button(NSLocalizedString("common.cancel", comment: "Cancel button")) { dismiss() },
                trailing: Button(NSLocalizedString("common.create", comment: "Create button")) { dismiss() }
            )
        }
    }
}

// MARK: - Preview Provider
#Preview {
    GoalsView()
} 