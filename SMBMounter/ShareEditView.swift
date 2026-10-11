import SwiftUI

enum EditMode {
    case add
    case edit(SMBShare)
}

struct ShareEditView: View {
    let mode: EditMode
    let onSave: (SMBShare, String) -> Void
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var localization: AppLocalization
    
    @State private var name: String = ""
    @State private var connectionProtocol: ShareProtocol = .smb
    @State private var webDAVScheme: WebDAVScheme = .https
    @State private var host: String = ""
    @State private var port: String = ""
    @State private var shareName: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var mountPoint: String = ""
    @State private var autoMount: Bool = true
    @State private var showPassword: Bool = false
    
    var title: String {
        switch mode {
        case .add: return localization.text(.addShare)
        case .edit: return localization.text(.editShare)
        }
    }
    
    var saveEnabled: Bool {
        !host.trimmingCharacters(in: .whitespaces).isEmpty &&
        !shareName.trimmingCharacters(in: .whitespaces).isEmpty &&
        portIsValid
    }

    var portIsValid: Bool {
        guard connectionProtocol == .webdav else { return true }
        let trimmed = port.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let value = Int(trimmed) else { return false }
        return (1...65535).contains(value)
    }
    
    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()
            
            Form {
                Section(localization.text(.general)) {
                    HStack {
                        Text(localization.text(.name))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        TextField(localization.text(.name), text: $name,
                                  prompt: Text(localization.text(.namePlaceholder)))
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text(localization.text(.connectionProtocol))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        Picker("", selection: $connectionProtocol) {
                            ForEach(ShareProtocol.allCases) { shareProtocol in
                                Text(shareProtocol.displayName).tag(shareProtocol)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.segmented)
                    }

                    HStack {
                        Text(localization.text(.host))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        TextField(localization.text(.host), text: $host,
                                  prompt: Text(localization.text(.hostPlaceholder)))
                            .labelsHidden()
                            .autocorrectionDisabled()
                    }

                    if connectionProtocol == .webdav {
                        HStack {
                            Text("WebDAV")
                                .frame(width: 100, alignment: .trailing)
                                .foregroundColor(.secondary)
                            Picker("", selection: $webDAVScheme) {
                                ForEach(WebDAVScheme.allCases) { scheme in
                                    Text(scheme.rawValue).tag(scheme)
                                }
                            }
                            .labelsHidden()
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }

                        HStack {
                            Text(localization.text(.port))
                                .frame(width: 100, alignment: .trailing)
                                .foregroundColor(.secondary)
                            TextField(localization.text(.port), text: $port,
                                      prompt: Text(defaultWebDAVPort))
                                .labelsHidden()
                        }
                    }
                    
                    HStack {
                        Text(localization.text(.shareName))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        TextField(localization.text(.shareName), text: $shareName,
                                  prompt: Text(localization.text(.shareNamePlaceholder)))
                            .labelsHidden()
                            .autocorrectionDisabled()
                    }
                    
                    HStack {
                        Text(localization.text(.mountPoint))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        Text(mountPoint.isEmpty ? "/Volumes/\(shareName.isEmpty ? localization.text(.mountPointPlaceholder) : shareName)" : mountPoint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    
                    HStack {
                        Text(localization.text(.autoMount))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        Toggle("", isOn: $autoMount)
                            .labelsHidden()
                        Text(localization.text(.autoMountHint))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(localization.text(.credentials)) {
                    HStack {
                        Text(localization.text(.username))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        TextField(localization.text(.username), text: $username,
                                  prompt: Text(localization.text(.usernamePlaceholder)))
                            .labelsHidden()
                            .autocorrectionDisabled()
                    }
                    
                    HStack {
                        Text(localization.text(.password))
                            .frame(width: 100, alignment: .trailing)
                            .foregroundColor(.secondary)
                        if showPassword {
                            TextField(localization.text(.password), text: $password,
                                      prompt: Text(localization.text(.password)))
                                .labelsHidden()
                                .autocorrectionDisabled()
                        } else {
                            SecureField(localization.text(.password), text: $password,
                                        prompt: Text(localization.text(.password)))
                                .labelsHidden()
                        }
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.secondary)
                        .help(localization.text(showPassword ? .hidePassword : .showPassword))
                        .accessibilityLabel(localization.text(showPassword ? .hidePassword : .showPassword))
                    }
                    
                    Text(localization.text(.keychainHint))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if !host.isEmpty && !shareName.isEmpty {
                    Section(localization.text(.preview)) {
                        Text(previewURL)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .formStyle(.grouped)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.leading)
            
            Divider()
            
            HStack {
                Button(localization.text(.cancel)) { dismiss() }
                    .keyboardShortcut(.escape)
                Spacer()
                Button(localization.text(.save)) {
                    save()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!saveEnabled)
                .keyboardShortcut(.return)
            }
            .padding()
        }
        .frame(width: 500, height: 540)
        .environment(\.locale, localization.locale)
        .onAppear(perform: loadExisting)
        .onChange(of: connectionProtocol) { _, newValue in
            if newValue == .webdav && port.trimmingCharacters(in: .whitespaces).isEmpty {
                port = defaultWebDAVPort
            }
        }
        .onChange(of: webDAVScheme) { oldValue, newValue in
            let trimmed = port.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed == "\(oldValue.defaultPort)" {
                port = "\(newValue.defaultPort)"
            }
        }
    }
    
    func loadExisting() {
        if case .edit(let share) = mode {
            name = share.name
            connectionProtocol = share.connectionProtocol
            webDAVScheme = share.webDAVScheme
            host = share.host
            port = share.port > 0 ? "\(share.port)" : (share.connectionProtocol == .webdav ? defaultWebDAVPort : "")
            shareName = share.shareName
            username = share.username
            mountPoint = share.mountPoint
            autoMount = share.autoMount
            password = KeychainHelper.shared.getPassword(for: share.id) ?? ""
        }
    }

    var previewURL: String {
        let scheme: String
        let displayHost: String

        scheme = connectionProtocol == .webdav ? webDAVScheme.urlScheme : connectionProtocol.urlScheme
        displayHost = connectionProtocol == .webdav ? "\(cleanHost):\(effectiveWebDAVPort)" : cleanHost

        return "\(scheme)://\(username.isEmpty ? "" : "\(username)@")\(displayHost)/\(shareName)"
    }

    var effectiveWebDAVPort: Int {
        Int(port.trimmingCharacters(in: .whitespaces)) ?? Int(defaultWebDAVPort) ?? 443
    }

    var defaultWebDAVPort: String {
        "\(webDAVScheme.defaultPort)"
    }

    var cleanHost: String {
        guard connectionProtocol == .webdav,
              let components = URLComponents(string: host),
              components.scheme != nil,
              let parsedHost = components.host else {
            return host
        }
        return parsedHost
    }
    
    func save() {
        let displayName = name.isEmpty ? "\(host)/\(shareName)" : name
        
        switch mode {
        case .add:
            let share = SMBShare(
                name: displayName,
                connectionProtocol: connectionProtocol,
                webDAVScheme: webDAVScheme,
                host: host,
                port: connectionProtocol == .webdav ? effectiveWebDAVPort : 0,
                shareName: shareName,
                username: username,
                mountPoint: mountPoint,
                autoMount: autoMount
            )
            onSave(share, password)
            
        case .edit(var share):
            share.name = displayName
            share.connectionProtocol = connectionProtocol
            share.webDAVScheme = webDAVScheme
            share.host = host
            share.port = connectionProtocol == .webdav ? effectiveWebDAVPort : 0
            share.shareName = shareName
            share.username = username
            share.mountPoint = mountPoint
            share.autoMount = autoMount
            onSave(share, password)
        }
    }
}

#Preview {
    ShareEditView(mode: .add) { _, _ in }
        .environmentObject(AppLocalization.shared)
}
