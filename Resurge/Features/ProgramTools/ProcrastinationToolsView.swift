import SwiftUI
import Combine

// MARK: - Procrastination Tools View

struct ProcrastinationToolsView: View {
    @State private var selectedTab = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Section", selection: $selectedTab) {
                    Text("5-Min Start").tag(0)
                    Text("Chunker").tag(1)
                    Text("Focus Log").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                switch selectedTab {
                case 0: FiveMinuteStartCard()
                case 1: TaskChunkerCard()
                default: FocusSessionCard()
                }
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Procrastination Tools")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Five Minute Start Timer

private struct FiveMinuteStartCard: View {
    @State private var remainingSeconds: Int = 300
    @State private var isRunning = false
    @State private var completed = false
    @State private var timerCancellable: AnyCancellable?

    private let totalSeconds = 300

    var body: some View {
        VStack(spacing: 20) {
            Label("5-Minute Start", systemImage: "bolt.fill")
                .font(.headline)
                .foregroundColor(Color.neonOrange)

            if completed {
                VStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 56))
                        .foregroundColor(Color.neonOrange)
                    Text("You did 5 minutes!")
                        .font(Font.title2.weight(.bold))
                        .foregroundColor(Color.neonCyan)
                    Text("Most people keep going once they start. Want to continue or take a break?")
                        .font(.subheadline)
                        .foregroundColor(Color.subtleText)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        Button {
                            remainingSeconds = 300
                            completed = false
                            startTimer()
                        } label: {
                            Text("Another 5 min")
                                .font(Font.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.neonCyan)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button {
                            remainingSeconds = 300
                            completed = false
                        } label: {
                            Text("Done")
                                .font(Font.body.weight(.semibold))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 24)
                                .background(Color.appBackground)
                                .foregroundColor(Color.subtleText)
                                .cornerRadius(12)
                        }
                    }
                }
            } else {
                Text("You do not have to finish. You just have to start. Commit to 5 minutes.")
                    .font(.subheadline)
                    .foregroundColor(Color.subtleText)
                    .multilineTextAlignment(.center)

                // Timer circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 14)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: CGFloat(remainingSeconds) / CGFloat(totalSeconds))
                        .stroke(
                            LinearGradient(
                                colors: [Color.neonOrange, Color.neonGold],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: remainingSeconds)

                    VStack(spacing: 4) {
                        Text(timeString(remainingSeconds))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Color.neonOrange)
                        Text(isRunning ? "Keep going" : "Ready?")
                            .font(.caption)
                            .foregroundColor(Color.subtleText)
                    }
                }

                if isRunning {
                    HStack(spacing: 16) {
                        Button {
                            stopTimer()
                        } label: {
                            Text("Pause")
                                .font(Font.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.appBackground)
                                .foregroundColor(Color.subtleText)
                                .cornerRadius(12)
                        }

                        Button {
                            stopTimer()
                            remainingSeconds = totalSeconds
                        } label: {
                            Text("Reset")
                                .font(Font.body.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.appBackground)
                                .foregroundColor(Color.subtleText)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Button {
                        startTimer()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Just 5 Minutes")
                                .font(Font.body.weight(.bold))
                        }
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.neonOrange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        isRunning = true
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    stopTimer()
                    completed = true
                }
            }
    }

    private func stopTimer() {
        isRunning = false
        timerCancellable?.cancel()
    }
}

// MARK: - Task Chunker

private struct TaskChunk: Identifiable {
    let id = UUID()
    var text: String
    var completed: Bool = false
}

private struct ChunkedTask: Identifiable {
    let id = UUID()
    var name: String
    var chunks: [TaskChunk]
}

private struct TaskChunkerCard: View {
    @State private var taskName = ""
    @State private var newChunkText = ""
    @State private var currentChunks: [TaskChunk] = []
    @State private var savedTasks: [ChunkedTask] = [
        ChunkedTask(name: "Write essay", chunks: [
            TaskChunk(text: "Create outline with 3 main points", completed: true),
            TaskChunk(text: "Write introduction paragraph", completed: true),
            TaskChunk(text: "Write body paragraph 1", completed: false),
            TaskChunk(text: "Write body paragraph 2", completed: false),
            TaskChunk(text: "Write conclusion", completed: false),
        ]),
    ]
    @State private var showForm = true

    private var completedChunks: Int {
        currentChunks.filter(\.completed).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Task Chunker", systemImage: "square.split.2x2.fill")
                .font(.headline)
                .foregroundColor(Color.neonBlue)

            Text("Big tasks feel impossible. Break them into tiny pieces and check them off.")
                .font(.subheadline)
                .foregroundColor(Color.subtleText)

            if showForm {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(Color.neonCyan)
                        TextField("What is the task?", text: $taskName)
                            .font(.subheadline)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)

                    HStack {
                        Image(systemName: "scissors")
                            .foregroundColor(Color.neonOrange)
                        TextField("Add a chunk...", text: $newChunkText)
                            .font(.subheadline)
                            .onSubmit { addChunk() }
                        Button {
                            addChunk()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(newChunkText.isEmpty ? Color.gray.opacity(0.3) : Color.neonCyan)
                        }
                        .disabled(newChunkText.isEmpty)
                    }
                    .padding(12)
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }

                // Current chunks
                if !currentChunks.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Chunks (\(completedChunks)/\(currentChunks.count))")
                                .font(Font.caption.weight(.semibold))
                                .foregroundColor(Color.neonCyan)
                            Spacer()
                        }

                        ForEach($currentChunks) { $chunk in
                            Button {
                                withAnimation { chunk.completed.toggle() }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: chunk.completed ? "checkmark.square.fill" : "square")
                                        .foregroundColor(chunk.completed ? Color.neonCyan : Color.gray.opacity(0.4))
                                    Text(chunk.text)
                                        .font(.subheadline)
                                        .foregroundColor(chunk.completed ? Color.subtleText : Color.appText)
                                        .strikethrough(chunk.completed)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        guard !taskName.isEmpty, !currentChunks.isEmpty else { return }
                        let task = ChunkedTask(name: taskName, chunks: currentChunks)
                        withAnimation {
                            savedTasks.insert(task, at: 0)
                            taskName = ""
                            currentChunks = []
                        }
                    } label: {
                        Text("Save Task")
                            .font(Font.body.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(taskName.isEmpty ? Color.gray.opacity(0.3) : Color.neonCyan)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(taskName.isEmpty)
                }
            }

            // Saved tasks
            if !savedTasks.isEmpty {
                Divider()
                Text("Saved Tasks")
                    .font(Font.subheadline.weight(.semibold))

                ForEach($savedTasks) { $task in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(task.name)
                                .font(Font.subheadline.weight(.medium))
                            Spacer()
                            let done = task.chunks.filter(\.completed).count
                            Text("\(done)/\(task.chunks.count)")
                                .font(.caption)
                                .foregroundColor(done == task.chunks.count ? Color.neonCyan : Color.neonOrange)
                        }

                        ForEach($task.chunks) { $chunk in
                            Button {
                                withAnimation { chunk.completed.toggle() }
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: chunk.completed ? "checkmark.square.fill" : "square")
                                        .font(.caption)
                                        .foregroundColor(chunk.completed ? Color.neonCyan : Color.gray.opacity(0.4))
                                    Text(chunk.text)
                                        .font(.caption)
                                        .foregroundColor(chunk.completed ? Color.subtleText : Color.appText)
                                        .strikethrough(chunk.completed)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(Color.appBackground)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private func addChunk() {
        guard !newChunkText.isEmpty else { return }
        withAnimation {
            currentChunks.append(TaskChunk(text: newChunkText))
            newChunkText = ""
        }
    }
}

// MARK: - Focus Session Tracker

private struct FocusSession: Identifiable {
    let id = UUID()
    let date: Date
    let duration: Int // minutes
    let task: String
}

private struct FocusSessionCard: View {
    @State private var sessions: [FocusSession] = [
        FocusSession(date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(), duration: 25, task: "Study chapter 4"),
        FocusSession(date: Calendar.current.date(byAdding: .hour, value: -5, to: Date()) ?? Date(), duration: 50, task: "Code review"),
        FocusSession(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), duration: 25, task: "Email responses"),
    ]
    @State private var isTracking = false
    @State private var trackingTask = ""
    @State private var elapsedSeconds = 0
    @State private var timerCancellable: AnyCancellable?

    private var totalMinutesToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return sessions
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Focus Sessions", systemImage: "brain.head.profile")
                    .font(.headline)
                    .foregroundColor(Color.neonPurple)
                Spacer()
                Text("\(totalMinutesToday) min today")
                    .font(Font.caption.weight(.bold))
                    .foregroundColor(Color.neonGold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.neonGold.opacity(0.15))
                    .cornerRadius(8)
            }

            if isTracking {
                VStack(spacing: 12) {
                    Text(trackingTask.isEmpty ? "Focused Work" : trackingTask)
                        .font(Font.subheadline.weight(.medium))

                    Text(timeString(elapsedSeconds))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(Color.neonCyan)

                    Button {
                        stopTracking()
                    } label: {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                            Text("End Session")
                                .font(Font.body.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.neonOrange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.neonCyan.opacity(0.08))
                .cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "pencil")
                        .foregroundColor(Color.neonCyan)
                    TextField("What are you working on?", text: $trackingTask)
                        .font(.subheadline)
                }
                .padding(12)
                .background(Color.appBackground)
                .cornerRadius(10)

                Button {
                    startTracking()
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Focus Session")
                            .font(Font.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.neonCyan)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }

            if !sessions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Sessions")
                        .font(Font.subheadline.weight(.semibold))

                    ForEach(sessions.prefix(5)) { session in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color.neonCyan)
                                .font(.caption)
                            Text(session.task)
                                .font(.subheadline)
                            Spacer()
                            Text("\(session.duration) min")
                                .font(.caption)
                                .foregroundColor(Color.subtleText)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(colors: [.neonCyan, .neonBlue, .neonPurple, .neonMagenta, .neonOrange, .neonGold], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
                    .opacity(0.4)
            )
            .shadow(color: Color.neonPurple.opacity(0.12), radius: 12)
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTracking() {
        isTracking = true
        elapsedSeconds = 0
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                elapsedSeconds += 1
            }
    }

    private func stopTracking() {
        isTracking = false
        timerCancellable?.cancel()
        let minutes = max(elapsedSeconds / 60, 1)
        let session = FocusSession(date: Date(), duration: minutes, task: trackingTask.isEmpty ? "Focused Work" : trackingTask)
        withAnimation {
            sessions.insert(session, at: 0)
            trackingTask = ""
        }
    }
}

// MARK: - Preview

struct ProcrastinationToolsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProcrastinationToolsView()
        }
    }
}
