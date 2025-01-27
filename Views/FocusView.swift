import SwiftUI

// MARK: - Focus View
struct FocusView: View {
    // MARK: - Properties
    @State private var elapsedTime: TimeInterval = 0
    @State private var startTime: Date?
    @State private var isActive: Bool = false
    @State private var showingBreakAlert = false
    @State private var showingGroupSheet = false
    @State private var showingResetAlert = false
    @State private var showingTimeSettings = false
    @State private var animateBackground = false
    @State private var focusSegments: [TimeSegment] = []
    @State private var currentSegmentStartTime: Date?
    @State private var showingStats = false
    @State private var circleMinutes: Int = 25 // 一圈代表的分鐘數
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var isGroupModeEnabled: Bool = false // 新增：群組模式開關
    @State private var groupMembers: [GroupMember] = []
    @State private var isSimulationEnabled: Bool = true // 新增：模擬開關
    @State private var currentUser: GroupMember = GroupMember(
        id: UUID(),
        name: "我",
        totalSeconds: 0,
        isActive: false,
        avatar: ""
    )
    
    // 更改更新頻率為每秒更新一次
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 新增：模擬用戶數據
    private let simulatedMembers: [GroupMember] = [
        GroupMember(id: UUID(), name: "小明", totalSeconds: 6, isActive: false, avatar: ""), 
        GroupMember(id: UUID(), name: "小華", totalSeconds: 33, isActive: false, avatar: ""), 
        GroupMember(id: UUID(), name: "小美", totalSeconds: 3608, isActive: true, avatar: ""), 
        GroupMember(id: UUID(), name: "小強", totalSeconds: 70, isActive: true, avatar: ""),  
        GroupMember(id: UUID(), name: "小芳", totalSeconds: 11, isActive: true, avatar: "")  
    ]
    
    // 格式化時間顯示
    private var timeDisplay: String {
        let totalSeconds = Int(elapsedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if minutes >= 60 {
            return String(format: "%d:%02d", hours, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // 計算當前專注時長（分鐘）
    private var currentFocusDuration: Int {
        Int(elapsedTime / 60)
    }
    
    // 計算完整圈數
    private var completedCircles: Int {
        Int(elapsedTime / (Double(circleMinutes) * 60))
    }
    
    // 當前圈的進度
    private var currentProgress: CGFloat {
        CGFloat(elapsedTime.truncatingRemainder(dividingBy: Double(circleMinutes) * 60)) / (Double(circleMinutes) * 60)
    }
    
    // 進度條顏色
    private func circleColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.33, green: 0.43, blue: 0.96), // 主藍色
            Color(red: 0.20, green: 0.80, blue: 0.67), // 青綠色
            Color(red: 0.95, green: 0.61, blue: 0.07), // 金橙色
            Color(red: 0.82, green: 0.38, blue: 0.96), // 紫色
            Color(red: 0.96, green: 0.26, blue: 0.47)  // 粉紅色
        ]
        return colors[index % colors.count]
    }
    
    // 計算所有圈的進度
    private func progressForCircle(at index: Int) -> CGFloat {
        let totalSeconds = Double(circleMinutes * 60)
        let circleStartTime = Double(index) * totalSeconds
        let circleEndTime = circleStartTime + totalSeconds
        
        if elapsedTime <= circleStartTime {
            return 0
        } else if elapsedTime >= circleEndTime {
            return 1
        } else {
            return CGFloat((elapsedTime - circleStartTime) / totalSeconds)
        }
    }
    
    // 漸變色背景
    private var gradientBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.95, green: 0.95, blue: 0.97),
                Color(red: 0.97, green: 0.97, blue: 0.99)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Animated Background
                gradientBackground
                    .overlay(
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.05))
                                .frame(width: 300)
                                .blur(radius: 30)
                                .offset(y: animateBackground ? 50 : -50)
                            
                            Circle()
                                .fill(Color.purple.opacity(0.05))
                                .frame(width: 250)
                                .blur(radius: 30)
                                .offset(x: animateBackground ? -30 : 30)
                        }
                    )
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Timer Display
                    TimelineView(.animation(minimumInterval: 0.016)) { timeline in
                        ZStack {
                            // Background Circle
                            Circle()
                                .stroke(lineWidth: 15)
                                .opacity(0.05)
                                .foregroundColor(.gray)
                            
                            // All Progress Circles
                            ForEach(0...completedCircles, id: \.self) { index in
                                Circle()
                                    .trim(from: 0.0, to: progressForCircle(at: index))
                                    .stroke(
                                        style: StrokeStyle(
                                            lineWidth: 15,
                                            lineCap: .round,
                                            lineJoin: .round
                                        )
                                    )
                                    .foregroundColor(circleColor(for: index))
                                    .opacity(index == completedCircles ? 1 : 0.15)
                                    .rotationEffect(Angle(degrees: 270.0))
                                    .shadow(color: circleColor(for: index).opacity(index == completedCircles ? 0.3 : 0), radius: 5)
                                    .animation(.easeInOut(duration: 0.5), value: progressForCircle(at: index))
                                    .animation(.easeInOut(duration: 0.3), value: circleColor(for: index))
                            }
                            
                            // Inner Shadow Ring
                            Circle()
                                .stroke(lineWidth: 1)
                                .opacity(0.1)
                                .shadow(color: .white, radius: 3)
                                .padding(2)
                            
                            VStack(spacing: 15) {
                                // Time Display
                                Button(action: { 
                                    if !isActive {
                                        showingTimeSettings = true
                                    }
                                }) {
                                    Text(timeDisplay)
                                        .font(.system(size: 72, weight: .bold, design: .rounded))
                                        .foregroundColor(isActive ? .primary : .secondary)
                                        .contentTransition(.numericText())
                                        .monospacedDigit()
                                }
                                .disabled(isActive)
                                
                                // Status Text
                                Text(isActive ? "專注中" : "準備開始")
                                    .font(.title3.weight(.medium))
                                    .foregroundColor(.secondary)
                                
                                if isActive {
                                    Text("已專注 \(currentFocusDuration) 分鐘")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)
                                        .opacity(0.8)
                                } else if !focusSegments.isEmpty {
                                    Text("一圈 \(circleMinutes) 分鐘")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundColor(.secondary)
                                        .opacity(0.8)
                                }
                            }
                        }
                        .onChange(of: timeline.date) { oldValue, newDate in
                            if isActive, let startTime = startTime {
                                withAnimation(.linear(duration: 0.016)) {
                                    elapsedTime = newDate.timeIntervalSince(startTime)
                                }
                            }
                        }
                    }
                    .frame(width: 300, height: 300)
                    .padding()
                    
                    // Control Buttons
                    HStack(spacing: 30) {
                        // Stats Button
                        Button(action: { showingStats = true }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(isActive)
                        .opacity(isActive ? 0.5 : 1)
                        
                        // Start/Pause Button
                        Button(action: toggleTimer) {
                            Image(systemName: isActive ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(isActive ? Color.red : Color.green)
                                .clipShape(Circle())
                                .shadow(color: (isActive ? Color.red : Color.green).opacity(0.3),
                                       radius: 10, x: 0, y: 5)
                        }
                        .scaleEffect(isActive ? 1.1 : 1.0)
                        
                        // Break Button
                        Button(action: { showingBreakAlert = true }) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 60, height: 60)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .disabled(!isActive)
                        .opacity(!isActive ? 0.5 : 1)
                    }
                    
                    // Focus Stats
                    if !focusSegments.isEmpty && !isActive {
                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                StatCard(
                                    title: "總專注",
                                    value: "\(totalFocusTime)分鐘",
                                    icon: "clock.fill"
                                )
                                StatCard(
                                    title: "專注次數",
                                    value: "\(focusSegments.count)次",
                                    icon: "number.circle.fill"
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 群組模式顯示
                    if isGroupModeEnabled && isActive {
                        VStack(spacing: 15) {
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    let allMembers = ([currentUser] + groupMembers)
                                        .sorted { $0.totalSeconds > $1.totalSeconds }
                                    
                                    ForEach(allMembers) { member in
                                        GroupMemberRow(member: member)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.vertical, 30)
            }
            .navigationTitle("專注")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        if !focusSegments.isEmpty {
                            Button(action: { showingResetAlert = true }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.secondary)
                            }
                            .disabled(isActive)
                        }
                        
                        // 修改：群組模式開關（移除點點）
                        Button(action: { 
                            isGroupModeEnabled.toggle()
                            if isGroupModeEnabled && isSimulationEnabled {
                                groupMembers = simulatedMembers
                            } else {
                                groupMembers = []
                            }
                        }) {
                            Image(systemName: "person.3")
                                .foregroundColor(isGroupModeEnabled ? .blue : .secondary)
                        }
                        .disabled(isActive)
                    }
                }
            }
            .sheet(isPresented: $showingGroupSheet) {
                GroupSelectionView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingStats) {
                FocusStatsView(segments: focusSegments)
                    .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingTimeSettings) {
                TimeSettingsView(circleMinutes: $circleMinutes) { newMinutes in
                    toastMessage = "已設定為 \(newMinutes) 分鐘"
                    withAnimation {
                        showToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }
                .presentationDetents([.height(300)])
            }
            .overlay(alignment: .top) {
                if showToast {
                    Text(toastMessage)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 10)
                }
            }
            .alert("需要休息嗎？", isPresented: $showingBreakAlert) {
                Button("繼續專注", role: .cancel) { }
                Button("開始休息") { startBreak() }
            } message: {
                Text("您已經專注了 \(currentFocusDuration) 分鐘")
            }
            .alert("確定要重置嗎？", isPresented: $showingResetAlert) {
                Button("取消", role: .cancel) { }
                Button("重置", role: .destructive) { resetAll() }
            } message: {
                Text("這將清除所有專注記錄")
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateBackground = true
                }
            }
            .onReceive(timer) { _ in
                if isGroupModeEnabled && isSimulationEnabled {
                    // 更新當前用戶狀態 - 使用歷史記錄總時間加上當前專注時間
                    let userTotalSeconds = focusSegments.reduce(0) { $0 + $1.duration } + Int(elapsedTime)
                    currentUser = GroupMember(
                        id: currentUser.id,
                        name: currentUser.name,
                        totalSeconds: userTotalSeconds,
                        isActive: isActive,
                        avatar: currentUser.avatar
                    )
                    
                    // 更新模擬用戶的狀態和時間
                    var updatedMembers = groupMembers
                    for i in 0..<updatedMembers.count {
                        let member = updatedMembers[i]
                        let isCurrentlyActive = member.isActive
                        
                        // 每30秒有20%的機率改變狀態
                        let shouldChangeStatus = Int.random(in: 1...30) == 1
                        let newIsActive = shouldChangeStatus ? !isCurrentlyActive : isCurrentlyActive
                        
                        // 如果是活躍狀態，每秒增加0.5-2秒（模擬不同人的專注效率）
                        let incrementSeconds = isCurrentlyActive ? Double.random(in: 0.5...2.0) : 0
                        let newSeconds = member.totalSeconds + Int(incrementSeconds)
                        
                        updatedMembers[i] = GroupMember(
                            id: member.id,
                            name: member.name,
                            totalSeconds: newSeconds,
                            isActive: newIsActive,
                            avatar: member.avatar
                        )
                    }
                    groupMembers = updatedMembers
                }
            }
        }
    }
    
    // MARK: - Methods
    private func toggleTimer() {
        withAnimation {
            if isActive {
                // 暫停計時
                if let start = currentSegmentStartTime {
                    let segment = TimeSegment(
                        startTime: start,
                        endTime: Date(),
                        duration: Int(Date().timeIntervalSince(start))
                    )
                    focusSegments.append(segment)
                }
                startTime = nil
                currentSegmentStartTime = nil
            } else {
                // 開始計時
                startTime = Date()
                currentSegmentStartTime = Date()
                if elapsedTime == 0 {
                    focusSegments = [] // 如果是重新開始，清空之前的記錄
                }
            }
            isActive.toggle()
        }
    }
    
    private func startBreak() {
        if let start = currentSegmentStartTime {
            let segment = TimeSegment(
                startTime: start,
                endTime: Date(),
                duration: Int(Date().timeIntervalSince(start))
            )
            focusSegments.append(segment)
        }
        withAnimation {
            isActive = false
            startTime = nil
            currentSegmentStartTime = nil
            elapsedTime = 0
        }
    }
    
    private var totalFocusTime: Int {
        focusSegments.reduce(0) { $0 + ($1.duration / 60) }
    }
    
    private func resetAll() {
        withAnimation {
            if isActive {
                // 如果正在計時，先停止
                toggleTimer()
            }
            focusSegments = []
            elapsedTime = 0
            startTime = nil
            currentSegmentStartTime = nil
        }
    }
}

// MARK: - Time Segment Model
struct TimeSegment: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
    let duration: Int // 秒
}

// MARK: - Focus Segment Card
struct FocusSegmentCard: View {
    let segment: TimeSegment
    
    private var durationText: String {
        let minutes = segment.duration / 60
        return "\(minutes)分鐘"
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: segment.startTime)) - \(formatter.string(from: segment.endTime))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(durationText)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(timeText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}

// MARK: - Focus Stats View
struct FocusStatsView: View {
    let segments: [TimeSegment]
    @Environment(\.dismiss) var dismiss
    
    private var totalFocusTime: Int {
        segments.reduce(0) { $0 + ($1.duration / 60) }
    }
    
    private var averageFocusTime: Int {
        guard !segments.isEmpty else { return 0 }
        return totalFocusTime / segments.count
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("今日統計") {
                    StatRow(title: "總專注時間", value: "\(totalFocusTime) 分鐘")
                    StatRow(title: "專注次數", value: "\(segments.count) 次")
                    StatRow(title: "平均時長", value: "\(averageFocusTime) 分鐘")
                }
                
                Section("專注記錄") {
                    ForEach(segments.reversed()) { segment in
                        FocusSegmentRow(segment: segment)
                    }
                }
            }
            .navigationTitle("專注統計")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct FocusSegmentRow: View {
    let segment: TimeSegment
    
    var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(timeFormatter.string(from: segment.startTime)) - \(timeFormatter.string(from: segment.endTime))")
                .font(.subheadline)
            
            Text("專注了 \(segment.duration / 60) 分鐘")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
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

// MARK: - Time Settings View
struct TimeSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var circleMinutes: Int
    @State private var tempMinutes: Int
    let onTimeSelected: (Int) -> Void
    
    private let presetMinutes = [15, 25, 30, 45, 60]
    
    init(circleMinutes: Binding<Int>, onTimeSelected: @escaping (Int) -> Void = { _ in }) {
        self._circleMinutes = circleMinutes
        self._tempMinutes = State(initialValue: circleMinutes.wrappedValue)
        self.onTimeSelected = onTimeSelected
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("設定一圈時間")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // 預設時間選項
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(presetMinutes, id: \.self) { minutes in
                            Button(action: { tempMinutes = minutes }) {
                                Text("\(minutes)分鐘")
                                    .font(.subheadline)
                                    .foregroundColor(tempMinutes == minutes ? .white : .blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(tempMinutes == minutes ? Color.blue : Color.blue.opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 自定義時間選擇器
                Picker("", selection: $tempMinutes) {
                    ForEach(1...120, id: \.self) { minute in
                        Text("\(minute) 分鐘").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("確定") {
                        circleMinutes = tempMinutes
                        onTimeSelected(tempMinutes)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Group Member Model
struct GroupMember: Identifiable {
    let id: UUID
    let name: String
    let totalSeconds: Int  // 改用秒來計算
    let isActive: Bool
    var avatar: String
    
    var displayTime: String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

// MARK: - Group Member Row
struct GroupMemberRow: View {
    let member: GroupMember
    
    var body: some View {
        HStack(spacing: 12) {
            // 頭像
            if !member.avatar.isEmpty {
                AsyncImage(url: URL(string: member.avatar)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            // 用戶資訊
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.name)
                        .font(.headline)
                    if member.isActive {
                        Text("專注中")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                Text("今日總專注：\(member.displayTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Spacer()
            
            // 狀態指示
            Circle()
                .fill(member.isActive ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .opacity(member.isActive ? 1 : 0.7)
    }
}

// MARK: - Preview Provider
#Preview {
    FocusView()
} 