import SwiftUI

struct FocusView: View {
    @State private var timeRemaining: Int = 25 * 60 // 25分鐘
    @State private var isActive: Bool = false
    @State private var timer: Timer?
    @State private var showingGroupSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 計時器顯示
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
                        
                        Text(isActive ? "專注中" : "準備開始")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 300, height: 300)
                .padding()
                
                // 控制按鈕
                HStack(spacing: 30) {
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: toggleTimer) {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(isActive ? Color.red : Color.green)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showingGroupSheet = true }) {
                        Image(systemName: "person.3")
                            .font(.title)
                            .foregroundColor(.blue)
                            .frame(width: 60, height: 60)
                            .background(Color.blue.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .navigationTitle("專注")
            .navigationBarItems(trailing: Button(action: {
                // 打開設置
            }) {
                Image(systemName: "gear")
            })
            .sheet(isPresented: $showingGroupSheet) {
                GroupSelectionView()
            }
        }
    }
    
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

struct GroupSelectionView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("我的小組")) {
                    ForEach(0..<3) { _ in
                        GroupRowView()
                    }
                }
                
                Section(header: Text("推薦小組")) {
                    ForEach(0..<5) { _ in
                        GroupRowView()
                    }
                }
            }
            .navigationTitle("選擇小組")
            .navigationBarItems(trailing: Button("完成") {
                // 關閉sheet
            })
        }
    }
}

struct GroupRowView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text("讀書小組")
                    .font(.headline)
                Text("3人正在專注")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("加入")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    FocusView()
} 