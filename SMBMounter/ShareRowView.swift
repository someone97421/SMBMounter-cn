import SwiftUI

struct ShareRowView: View {
    @Binding var share: SMBShare
    @EnvironmentObject var manager: ShareManager
    @EnvironmentObject var localization: AppLocalization
    
    var body: some View {
        HStack(spacing: 12) {
            statusIcon
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(share.name)
                        .font(.headline)
                    if share.autoMount {
                        Image(systemName: "bolt.fill")
                            .font(.caption2)
                            .foregroundColor(.accentColor)
                            .help(localization.text(.autoMountActive))
                    }
                }
                
                Text(share.connectionURL)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let error = share.lastError, share.status == .error || share.status == .disconnected {
                    Text(localizedError(error))
                        .font(.caption2)
                        .foregroundColor(.red)
                        .lineLimit(2)
                        .help(localizedError(error))
                } else if let date = share.lastConnected, share.status == .mounted {
                    Text(localization.format(.connectedSince, date.formatted(.dateTime.hour().minute().locale(localization.locale))))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(localization.text(share.status.textKey))
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(statusBackground)
                .cornerRadius(10)
            
            Button {
                if manager.isMounted(share) {
                    manager.unmount(share)
                } else {
                    manager.mount(share)
                }
            } label: {
                Image(systemName: manager.isMounted(share) ? "eject.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(manager.isMounted(share) ? .orange : .accentColor)
            }
            .buttonStyle(.plain)
            .help(localization.text(manager.isMounted(share) ? .disconnect : .connect))
            .disabled(share.status == .connecting)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
    }

    private func localizedError(_ error: String) -> String {
        guard let key = AppText(rawValue: error) else { return error }
        if key == .webDAVUnavailable {
            let port = share.port > 0 ? share.port : share.webDAVScheme.defaultPort
            return localization.format(key, port)
        }
        return localization.text(key)
    }
    
    @ViewBuilder
    var statusIcon: some View {
        switch share.status {
        case .mounted:
            Image(systemName: "externaldrive.fill.badge.checkmark")
                .foregroundColor(.green)
        case .disconnected:
            Image(systemName: "externaldrive.badge.minus")
                .foregroundColor(.secondary)
        case .connecting:
            ProgressView()
                .scaleEffect(0.6)
        case .error:
            Image(systemName: "externaldrive.badge.exclamationmark")
                .foregroundColor(.red)
        }
    }
    
    var statusBackground: Color {
        switch share.status {
        case .mounted: return Color.green.opacity(0.15)
        case .disconnected: return Color.secondary.opacity(0.1)
        case .connecting: return Color.yellow.opacity(0.15)
        case .error: return Color.red.opacity(0.15)
        }
    }
}
