import SwiftUI
import PhotosUI
import CoreLocation

struct QuickNoteView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @StateObject private var diaryService = DiaryService.shared
    @StateObject private var locationManager = LocationManager()
    
    @State private var content = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Image] = []
    @State private var contentType: QuickNote.NoteType = .text
    @State private var isRecording = false
    @State private var isDrawing = false
    @State private var isLoading = false
    @State private var error: String?
    @State private var showError = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Content Type Selector
                    Picker("", selection: $contentType) {
                        Label(NSLocalizedString("diary.note.text", comment: ""), systemImage: "text.justify")
                            .tag(QuickNote.NoteType.text)
                        
                        Label(NSLocalizedString("diary.note.voice", comment: ""), systemImage: "waveform")
                            .tag(QuickNote.NoteType.voice)
                        
                        Label(NSLocalizedString("diary.note.drawing", comment: ""), systemImage: "pencil.tip")
                            .tag(QuickNote.NoteType.drawing)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content Area
                    Group {
                        switch contentType {
                        case .text:
                            ZStack(alignment: .topLeading) {
                                if content.isEmpty {
                                    Text(NSLocalizedString("diary.note.placeholder", comment: ""))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                }
                                
                                TextEditor(text: $content)
                                    .frame(minHeight: 150)
                                    .padding(8)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            }
                            
                        case .voice:
                            VoiceRecorderView(isRecording: $isRecording)
                            
                        case .drawing:
                            DrawingCanvasView(isDrawing: $isDrawing)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Location
                    if let location = locationManager.currentLocation?.name {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            
                            Text(location)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                locationManager.requestLocation()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Media Picker (for text notes)
                    if contentType == .text {
                        MediaPicker(selectedItems: $selectedItems,
                                  selectedImages: $selectedImages)
                            .padding(.horizontal)
                    }
                    
                    // Mood Selector
                    MoodSelector(selectedEmotions: $selectedEmotions)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(NSLocalizedString("diary.quick_note", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(NSLocalizedString("common.cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("common.save", comment: "")) {
                        Task {
                            await saveQuickNote()
                        }
                    }
                    .disabled((contentType == .text && content.isEmpty) || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
        .alert(NSLocalizedString("error.title", comment: ""), isPresented: $showError) {
            Button(NSLocalizedString("common.ok", comment: ""), role: .cancel) {}
        } message: {
            Text(error ?? NSLocalizedString("error.unknown", comment: ""))
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    // MARK: - Methods
    private func saveQuickNote() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let note = QuickNote(
                id: UUID().uuidString,
                userId: "current_user_id", // TODO: Get from auth service
                content: content,
                type: contentType,
                emotions: Array(selectedEmotions),
                medias: [], // TODO: Upload media and get URLs
                location: locationManager.currentLocation,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            _ = try await diaryService.createQuickNote(note)
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            self.error = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Voice Recorder View
struct VoiceRecorderView: View {
    @Binding var isRecording: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Waveform Visualization
            ZStack {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 4, height: isRecording ? 40 : 10)
                        .offset(x: CGFloat(index * 10 - 20))
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.1),
                            value: isRecording
                        )
                }
            }
            .frame(height: 60)
            
            // Record Button
            Button(action: {
                withAnimation {
                    isRecording.toggle()
                }
            }) {
                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(isRecording ? .red : .blue)
            }
            
            Text(isRecording ?
                 NSLocalizedString("diary.note.recording", comment: "") :
                    NSLocalizedString("diary.note.tap_record", comment: ""))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - Drawing Canvas View
struct DrawingCanvasView: View {
    @Binding var isDrawing: Bool
    @State private var lines: [Line] = []
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 2
    
    var body: some View {
        VStack(spacing: 12) {
            // Canvas
            Canvas { context, size in
                for line in lines {
                    var path = Path()
                    path.addLines(line.points)
                    
                    context.stroke(
                        path,
                        with: .color(line.color),
                        lineWidth: line.width
                    )
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isDrawing = true
                        let position = value.location
                        
                        if value.translation == .zero {
                            lines.append(Line(points: [position],
                                           color: selectedColor,
                                           width: lineWidth))
                        } else {
                            guard let lastIdx = lines.indices.last else { return }
                            lines[lastIdx].points.append(position)
                        }
                    }
                    .onEnded { _ in
                        isDrawing = false
                    }
            )
            .frame(height: 300)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            // Tools
            HStack {
                // Colors
                HStack(spacing: 12) {
                    ForEach([Color.black, .blue, .red, .green], id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.blue : Color.clear,
                                           lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
                
                Spacer()
                
                // Clear Button
                Button(action: {
                    lines.removeAll()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct Line: Identifiable {
    let id = UUID()
    var points: [CGPoint]
    let color: Color
    let width: CGFloat
}

// MARK: - Location Manager
