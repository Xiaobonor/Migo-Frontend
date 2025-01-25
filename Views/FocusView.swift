import SwiftUI

// MARK: - Focus View
struct FocusView: View {
    // MARK: - Properties
    @State private var timeRemaining: Int = 25 * 60 // 25 minutes
    @State private var isActive: Bool = false
    @State private var timer: Timer?
    @State private var showingGroupSheet = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Timer Display
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(timeRemaining) / (25.0 * 60.0))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: timeRemaining)
                    
                    VStack {
                        Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                        
                        Text(isActive ? NSLocalizedString("focus.status.focusing", comment: "Status when timer is running") : NSLocalizedString("focus.status.ready", comment: "Status when timer is ready"))
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 300, height: 300)
                .padding()
                
                // Control Buttons
                HStack(spacing: 30) {
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(NSLocalizedString("focus.button.reset", comment: "Reset timer button"))
                    
                    Button(action: toggleTimer) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(isActive ? Color.red : Color.green)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(isActive ? NSLocalizedString("focus.button.pause", comment: "Pause timer button") : NSLocalizedString("focus.button.start", comment: "Start timer button"))
                    
                    Button(action: { showingGroupSheet = true }) {
                        Image(systemName: "person.3")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(NSLocalizedString("focus.button.join_group", comment: "Join group button"))
                }
            }
            .navigationTitle(NSLocalizedString("focus.title", comment: "Focus screen title"))
            .navigationBarItems(trailing: Button(action: {
                // Open settings
            }) {
                Image(systemName: "gear")
            })
            .sheet(isPresented: $showingGroupSheet) {
                GroupSelectionView()
            }
        }
    }
    
    // MARK: - Timer Methods
    private func toggleTimer() {
        if isActive {
            timer?.invalidate()
            timer = nil
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    timer?.invalidate()
                    timer = nil
                    isActive = false
                }
            }
        }
        isActive.toggle()
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        timeRemaining = 25 * 60
        isActive = false
    }
}

// MARK: - Group Selection View
struct GroupSelectionView: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("focus.groups.my_groups", comment: "My groups section"))) {
                    ForEach(0..<3) { _ in
                        GroupRowView()
                    }
                }
                
                Section(header: Text(NSLocalizedString("focus.groups.recommended", comment: "Recommended groups section"))) {
                    ForEach(0..<5) { _ in
                        GroupRowView()
                    }
                }
            }
            .navigationTitle(NSLocalizedString("focus.groups.select", comment: "Select group screen title"))
            .navigationBarItems(trailing: Button(NSLocalizedString("common.done", comment: "Done button")) {
                dismiss()
            })
        }
    }
}

// MARK: - Group Row View
struct GroupRowView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString("focus.groups.study_group", comment: "Study group name"))
                    .font(.headline)
                Text(NSLocalizedString("focus.groups.members_focusing", comment: "Number of members focusing"))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(NSLocalizedString("focus.groups.join", comment: "Join group button")) {
                // Join group action
            }
            .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview Provider
#Preview {
    FocusView()
} 