import UIKit
import SwiftUI
import SafariServices
import Foundation


//Allow beta to be freeform
public var BetaDoNotRelease: Bool {
    get {
        return UserDefaults.standard.bool(forKey: "BetaDoNotRelease")
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "BetaDoNotRelease")
    }
}

//Force Beta to be true

/*public var BetaDoNotRelease: Bool {
    get {
        return true // Forcefully returns true regardless of UserDefaults value
    }
    set {
        UserDefaults.standard.set(newValue, forKey: "BetaDoNotRelease")
    }
}*/


extension Color {
    static var nodedaBlue: Color {
        Color(red: 26.0 / 255.0, green: 145.0 / 255.0, blue: 205.0 / 255.0)
    }
    static var nodedaGreen: Color {
        Color(red: 168.0 / 255.0, green: 214.0 / 255.0, blue: 200.0 / 255.0)
    }
}
// Chips
public struct DetailChip: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let icon: String
    let text: String
    
    public init(icon: String = "none", text: String) {
        self.icon = icon
        self.text = text
    }
    
    private var glassBackground: some View {
        ZStack {
            Color.clear
            
            if colorScheme == .dark {
                Color.white.opacity(0.1)
            } else {
                Color.white.opacity(0.7)
            }
        }
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private var glassHighlight: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(colorScheme == .dark ? 0.3 : 0.5),
                        Color.white.opacity(0.0)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .padding(1)
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            if icon != "none" {
                Image(systemName: icon)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            Text(text)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
        .font(.system(size: 16, weight: .medium))
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(glassBackground)
        .overlay(glassHighlight)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}
//Legal
    struct LegalSection: View {
            @State private var isShowingPrivacy = false
            @State private var isShowingPrivacyChoices = false
            @State private var isShowingTOS = false
            
            var body: some View {
                    Section() {
                            Button(action: {
                                    isShowingPrivacyChoices = true
                                }) {
                                        HStack {
                                                Image(systemName: "hand.raised.fill")
                                                Text("Privacy Choices")
                                            }
                                    }
                                    .sheet(isPresented: $isShowingPrivacyChoices) {
                                            PrivacyChoicesView(isPresented: $isShowingPrivacyChoices)
                                        }
                            Button(action: {
                                    isShowingPrivacy = true
                                }) {
                                        HStack {
                                                Image(systemName: "lock.fill")
                                                Text("Privacy Policy")
                                            }
                                    }
                                    .sheet(isPresented: $isShowingPrivacy) {
                                            PrivacyView(isPresented: $isShowingPrivacy)
                                        }
                            
                            Button(action: {
                                    isShowingTOS = true
                                }) {
                                        HStack {
                                                Image(systemName: "text.word.spacing")
                                                Text("Terms of Use")
                                            }
                                    }
                            //.fullScreenCover
                                    .sheet(isPresented: $isShowingTOS) {
                                            TOSView(isPresented: self.$isShowingTOS)
                                        }
                            
                        }
                    
                    HStack {
                            Spacer() // Add a spacer to push the text to the center horizontally
                            Text("Copyright © 2024 NodeDa LLC")
                            Spacer() // Add another spacer to push the text to the center horizontally
                        }
                        .listRowBackground(Color.clear)
                    
                }
        }

public func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }

public func GoToURL(_ urlString: String) {
    if let url = URL(string: urlString) {
        let safariViewController = SFSafariViewController(url: url)
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(safariViewController, animated: true, completion: nil)
        }
    }
}
//Privacy Policy
// XML Parser for the terms of service
class PrivacyParser: NSObject, XMLParserDelegate {
    private var sections: [SectionModel] = []
    private var currentElement = ""
    private var currentHeader = ""
    private var currentParagraph = ""
    private var currentSectionID = ""
    
    func parse(data: Data) -> [SectionModel]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        return parser.parse() ? sections : nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "Section" {
            currentHeader = attributeDict["Header"] ?? ""
            currentParagraph = attributeDict["Paragraph"] ?? ""
            currentSectionID = attributeDict["SectionID"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Section" {
            let section = SectionModel(header: currentHeader, paragraph: currentParagraph)
            sections.append(section)
        }
    }
}

// SwiftUI View for displaying terms of service
struct PrivacyView: View {
    @State private var sections = [SectionModel]()
    @State private var isLoading = true
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(sections) { section in
                VStack(alignment: .leading) {
                    if !section.header.isEmpty {
                        Text(section.header)
                            .font(.headline)
                            .padding(.bottom, 1)
                    }
                    Text(section.paragraph)
                        .font(.body)
                }
                .padding(.vertical)
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle()) // Removes extra padding and separators
            .navigationBarTitle("Privacy Policy", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                // This will dismiss the view
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
            .onAppear(perform: loadData)
        }
        // This ensures that the NavigationView takes the full width
        // and the title bar does not switch to a large style on rotate.
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadData() {
        guard let url = URL(string: "https://assets.nodeda.com/privacy.xml") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let sections = PrivacyParser().parse(data: data) {
                    DispatchQueue.main.async {
                        self.sections = sections
                        self.isLoading = false
                    }
                } else {
                    print("XML parsing failed")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }.resume()
    }
}

//Privacy Choices
// XML Parser for the terms of service
class PrivacyChoicesParser: NSObject, XMLParserDelegate {
    private var sections: [SectionModel] = []
    private var currentElement = ""
    private var currentHeader = ""
    private var currentParagraph = ""
    private var currentSectionID = ""
    
    func parse(data: Data) -> [SectionModel]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        return parser.parse() ? sections : nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "Section" {
            currentHeader = attributeDict["Header"] ?? ""
            currentParagraph = attributeDict["Paragraph"] ?? ""
            currentSectionID = attributeDict["SectionID"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Section" {
            let section = SectionModel(header: currentHeader, paragraph: currentParagraph)
            sections.append(section)
        }
    }
}

// SwiftUI View for displaying terms of service
struct PrivacyChoicesView: View {
    @State private var sections = [SectionModel]()
    @State private var isLoading = true
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading...")
            } else {
                List(sections) { section in
                    VStack(alignment: .leading) {
                        if !section.header.isEmpty {
                            Text(section.header)
                                .font(.headline)
                                .padding(.bottom, 1)
                        }
                        Text(section.paragraph)
                            .font(.body)
                    }
                    .padding(.vertical)
                    .listRowBackground(Color.clear)
                }
                .listRowBackground(Color.clear)
                .navigationBarTitle("Privacy Choices", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                })
            }
        }
        .onAppear(perform: loadData)
        // This ensures that the NavigationView takes the full width
        // and the title bar does not switch to a large style on rotate.
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadData() {
        guard let url = URL(string: "https://assets.nodeda.com/privacyc.xml") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let sections = PrivacyChoicesParser().parse(data: data) {
                    DispatchQueue.main.async {
                        self.sections = sections
                        self.isLoading = false
                    }
                } else {
                    print("XML parsing failed")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }.resume()
    }
}


public func removeHTMLTags(_ html: String) -> String {
    return html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
}
// terms of use
struct SectionModel: Identifiable {
    let id = UUID()
    let header: String
    let paragraph: String
}

// XML Parser for the terms of service
class TOSParser: NSObject, XMLParserDelegate {
    private var sections: [SectionModel] = []
    private var currentElement = ""
    private var currentHeader = ""
    private var currentParagraph = ""
    private var currentSectionID = ""
    
    func parse(data: Data) -> [SectionModel]? {
        let parser = XMLParser(data: data)
        parser.delegate = self
        return parser.parse() ? sections : nil
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "Section" {
            currentHeader = attributeDict["Header"] ?? ""
            currentParagraph = attributeDict["Paragraph"] ?? ""
            currentSectionID = attributeDict["SectionID"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Section" {
            let section = SectionModel(header: currentHeader, paragraph: currentParagraph)
            sections.append(section)
        }
    }
}

// SwiftUI View for displaying terms of service
struct TOSView: View {
    @State private var sections = [SectionModel]()
    @State private var isLoading = true
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading...")
            } else {
                List(sections) { section in
                    VStack(alignment: .leading) {
                        if !section.header.isEmpty {
                            Text(section.header)
                                .font(.headline)
                                .padding(.bottom, 1)
                        }
                        Text(section.paragraph)
                            .font(.body)
                    }
                    .padding(.vertical)
                    .listRowBackground(Color.clear)
                }
                .listRowBackground(Color.clear)
                .navigationBarTitle("Terms of Use", displayMode: .inline)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                })
            }
        }
        .onAppear(perform: loadData)
        // This ensures that the NavigationView takes the full width
        // and the title bar does not switch to a large style on rotate.
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func loadData() {
        guard let url = URL(string: "https://assets.nodeda.com/terms.xml") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let sections = TOSParser().parse(data: data) {
                    DispatchQueue.main.async {
                        self.sections = sections
                        self.isLoading = false
                    }
                } else {
                    print("XML parsing failed")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
            }
        }.resume()
    }
}

//NodeDa ID Facts
struct NodeDaAccountInfoView: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                FactView(title: "Privacy First", description: [
                    "Your data is visible only to you",
                    "We never share your data with third parties",
                    "Robust security measures in place"
                ])
                .font(.headline)

                FactView(title: "Seamless Integration", description: [
                    "Enhanced compatibility with NodeDa apps",
                    "Smooth integration with NodeDa services"
                ])
                .font(.headline)

                FactView(title: "Access to More Online Services", description: [
                    "Expanding your online service options",
                    "One-stop access to a variety of services"
                ])
                .font(.headline)

                FactView(title: "Coming Soon", description: [
                    "Share NodeDa + across applications",
                    "Exciting features on the horizon"
                ])
                .font(.headline)

                Spacer() // Push content to the top
            }
            .padding()
            .navigationBarTitle("Account Benefits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                    .keyboardShortcut(.escape) // Optional: Add a keyboard shortcut
                }
            }
        }
    }
}

//Fact View
struct FactView: View {
    var title: String
    var description: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)

            ForEach(description, id: \.self) { item in
                Text("• " + item)
                    .font(.subheadline)
            }
        }
    }
}
public func clearCache() {
    let cache = URLCache.shared
    cache.removeAllCachedResponses()
    // Optionally, perform additional cache clearing logic if needed
    
    // Show a success message or perform any other necessary actions
    // For example:
    print("Cache cleared successfully")
}
public func restartApp() {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        if let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate {
            windowSceneDelegate.window??.rootViewController = UIHostingController(rootView: ContentView())
        }
    }
    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
}
//MARK: Share URL API
public struct ShareURL {
    
    public func shareURL(_ websiteURL: String) {
        guard let url = URL(string: websiteURL) else {
            print("Invalid URL")
            return
        }
        
        let activityView = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Unable to find the app window")
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityView.popoverPresentationController?.sourceView = window
            activityView.popoverPresentationController?.sourceRect = CGRect(
                x: 125,
                y: UIScreen.main.bounds.height / 3,
                width: 200,
                height: 200
            )
            activityView.popoverPresentationController?.permittedArrowDirections = .left
        }
        
        DispatchQueue.main.async {
            window.rootViewController?.present(activityView, animated: true, completion: nil)
        }
    }
}
