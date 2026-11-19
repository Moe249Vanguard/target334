import SwiftUI
import AVKit
import SafariServices

struct ExerciseLibraryView: View {
    @State private var query = ""

    private func filtered(_ category: ExerciseCategory) -> [Exercise] {
        let list = ExerciseLibrary.exercises(in: category)
        guard !query.isEmpty else { return list }
        return list.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.muscles.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(ExerciseCategory.allCases) { category in
                    let items = filtered(category)
                    if !items.isEmpty {
                        Section {
                            ForEach(items) { ex in
                                NavigationLink {
                                    ExerciseDetailView(exercise: ex)
                                } label: {
                                    ExerciseRow(exercise: ex)
                                }
                            }
                        } header: {
                            Label(category.label, systemImage: category.icon)
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "Search drills or muscles")
            .navigationTitle("Drill Manual")
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name).font(.headline)
                Text(exercise.muscles.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            DifficultyView(level: exercise.difficulty)
        }
    }
}

struct DifficultyView: View {
    let level: Int
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= level ? "circle.fill" : "circle")
                    .font(.caption2.bold())
                    .foregroundStyle(i <= level ? Theme.olive : Color.secondary.opacity(0.3))
            }
        }
        .accessibilityLabel("Difficulty \(level) of 5")
    }
}

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var showVideo = false

    var body: some View {
        List {
            Section {
                videoSection
            }

            Section {
                HStack {
                    Label(exercise.category.label, systemImage: exercise.category.icon)
                        .foregroundStyle(Theme.categoryColor(exercise.category))
                    Spacer()
                    DifficultyView(level: exercise.difficulty)
                }
                Text(exercise.muscles.joined(separator: " · "))
                    .font(.callout)
                    .foregroundStyle(.secondary)
                if exercise.highImpact {
                    Label("High impact: jumping or landing", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            if let note = exercise.militaryNote {
                Section("Military context") {
                    Label(note, systemImage: "star.circle").font(.callout)
                }
            }

            Section("How to do it") {
                ForEach(Array(exercise.steps.enumerated()), id: \.offset) { i, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(i + 1)")
                            .font(.headline)
                            .frame(width: 26, height: 26)
                            .background(Theme.olive.opacity(0.15), in: Circle())
                        Text(step)
                    }
                }
            }

            Section("Coaching cues") {
                ForEach(exercise.cues, id: \.self) { cue in
                    Label(cue, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.primary, Theme.olive)
                }
            }

            Section("Common mistakes") {
                ForEach(exercise.mistakes, id: \.self) { m in
                    Label(m, systemImage: "xmark.octagon.fill")
                        .foregroundStyle(.primary, .red)
                }
            }

            if exercise.easier != nil || exercise.harder != nil {
                Section("Scale it") {
                    if let id = exercise.easier, let ex = ExerciseLibrary.byID[id] {
                        NavigationLink { ExerciseDetailView(exercise: ex) } label: {
                            Label("Easier: \(ex.name)", systemImage: "arrow.down.circle")
                        }
                    }
                    if let id = exercise.harder, let ex = ExerciseLibrary.byID[id] {
                        NavigationLink { ExerciseDetailView(exercise: ex) } label: {
                            Label("Harder: \(ex.name)", systemImage: "arrow.up.circle")
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVideo) {
            SafariView(url: exercise.videoSearchURL).ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var videoSection: some View {
        if let url = exercise.bundledVideoURL {
            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 220)
                .listRowInsets(EdgeInsets())
        } else {
            Button {
                showVideo = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.red)
                    VStack(alignment: .leading) {
                        Text("Watch form videos").font(.headline)
                        Text("Opens video tutorials for \(exercise.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController { SFSafariViewController(url: url) }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
