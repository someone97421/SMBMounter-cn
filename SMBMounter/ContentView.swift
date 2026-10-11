import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: ShareManager
    @EnvironmentObject var localization: AppLocalization
    @State private var showAddSheet = false
    @State private var editingShare: SMBShare? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "externaldrive.fill.badge.wifi")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text("SMBMounter")
                    .font(.headline)
                Spacer()
                Menu {
                    Picker(localization.text(.language), selection: $localization.language) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                } label: {
                    Image(systemName: "globe")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .help(localization.text(.language))
                .accessibilityLabel(localization.text(.language))

                Button {
                    manager.mountAllAutoShares()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .help(localization.text(.connectAutoShares))
                
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help(localization.text(.addShare))
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            if manager.shares.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "externaldrive.badge.wifi")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(localization.text(.noShares))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(localization.text(.addShareHint))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button(localization.text(.addShare)) {
                        showAddSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach($manager.shares) { $share in
                        ShareRowView(share: $share)
                            .contextMenu {
                                Button(localization.text(.edit)) { editingShare = share }
                                Divider()
                                Button(localization.text(.connectNow)) { manager.mount(share) }
                                Button(localization.text(.disconnect)) { manager.unmount(share) }
                                Divider()
                                Button(localization.text(.openInFinder)) { openInFinder(share) }
                                Divider()
                                Button(localization.text(.delete), role: .destructive) { manager.removeShare(share) }
                            }
                    }
                    .onDelete { indices in
                        indices.forEach { manager.removeShare(manager.shares[$0]) }
                    }
                    .onMove { source, destination in
                        manager.moveShares(from: source, to: destination)
                    }
                }
                .listStyle(.plain)
            }
            
            Divider()
            
            HStack {
                Circle()
                    .fill(overallStatusColor)
                    .frame(width: 8, height: 8)
                Text(overallStatusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(localization.text(.quit)) {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.bordered)
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: 400, height: 480)
        .environment(\.locale, localization.locale)
        .sheet(isPresented: $showAddSheet) {
            ShareEditView(mode: .add) { share, password in
                manager.addShare(share, password: password)
            }
        }
        .sheet(item: $editingShare) { share in
            ShareEditView(mode: .edit(share)) { updatedShare, password in
                manager.updateShare(updatedShare, password: password)
            }
        }
        .onAppear {
            manager.updateMountStatuses()
        }
    }
    
    var overallStatusColor: Color {
        if manager.shares.allSatisfy({ $0.status == .mounted || !$0.autoMount }) { return .green }
        if manager.shares.contains(where: { $0.status == .error }) { return .red }
        if manager.shares.contains(where: { $0.status == .connecting }) { return .yellow }
        return .orange
    }
    
    var overallStatusText: String {
        let mounted = manager.shares.filter { $0.status == .mounted }.count
        let total = manager.shares.count
        return localization.format(.connectedCount, mounted, total)
    }
    
    func openInFinder(_ share: SMBShare) {
        NSWorkspace.shared.open(URL(fileURLWithPath: share.resolvedMountPoint))
    }
}
