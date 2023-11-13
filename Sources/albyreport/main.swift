// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import Darwin
import ArgumentParser

private let alby = Alby()

struct AlbyReport: ParsableCommand {
    
    @Option(name: .shortAndLong, help: "The date of the oldest transaction to retrieve. Leave empty for last 7 days.", transform: parseDate(shortFormatter))
    var date: Date?
    
    @Flag(name: .shortAndLong, help: "Set this flag if you want verbose reporting.")
    var verbose: Bool = false
    
    @Flag(name: .shortAndLong, help: "Set this flag if you want to re-enter the Alby token.")
    var forgetToken: Bool = false
    
    mutating func run() throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let oldestDate = date ?? oneWeekAgo
        
        let defaults = UserDefaults.standard
        var token = defaults.value(forKey: "albytoken") as? String
        
        if forgetToken == true {
            token = nil
        }
        
        if token == nil {
            print("Please enter your Alby token")
            token = readLine()
            if let token {
                defaults.setValue(token, forKey: "albytoken")
            }
        }
        
        guard let token, !token.isEmpty else {
            print("A token is mandatory to access your transactions from Alby servers.")
            return
        }
        
        let verbose = verbose
        
        self.getAllTransactions(with: token, dateLimit: oldestDate) {  result in
            switch result {
                case .success(let response):
                    var users = [User]()
                    
                    for transaction in response {
                        guard let customRecord = transaction.boostagram else { continue }
                              
                        let amount = customRecord.valueMsatTotal.map({ Bitcoin(satoshis:  $0 / 1000) }) ?? Bitcoin(satoshis: transaction.amount)
                        
                        let date = dateFormatter.string(from: transaction.creationDate)
                        
                        let timestamp = customRecord.ts
                        
                        let payment = Payment(type: customRecord.action, amount: amount, date: transaction.creationDate, message: customRecord.message, timestamp: timestamp)
                        
                        let userName = customRecord.senderName ?? "Anonymous"
                        
                        let user: User
                        if let existingUser = users.first(where: { $0.name == userName }) {
                            user = existingUser
                        } else {
                            user = User(name: userName)
                            users.append(user)
                        }
                        
                        if let episode = user.episodes.first(where: { $0.guid == customRecord.episodeGuid || $0.title == customRecord.episode }) {
                            episode.payments.append(payment)
                        } else {
                            let newEpisode = Episode(title: customRecord.episode, guid: customRecord.episodeGuid ?? "No guid", date: transaction.creationDate);
                            newEpisode.payments.append(payment)
                            user.episodes.append(newEpisode)
                        }
                        
                        if verbose == true {
                            let time = customRecord.ts.map({ TimeInterval($0)})?.toHHMMSS() ?? "unknown"
                            print("Transaction \(date) - \(customRecord.action.rawValue) - \(amount.formattedSatoshiDescription) - from: \(customRecord.senderName ?? "?") - for episode: \(customRecord.episode ?? "?") - timestamp: \(time)")
                        }
                    }
                    
                    if verbose == true {
                        print("GENERAL REPORT\n")
                        for user in users {
                            print("\(user.name ?? "Anon")")
                            for episode in user.episodes {
                                print("\t\(episode.aggregatedStreamPayments.formattedSatoshiDescription) streamed - \(episode.title ?? episode.guid)")
                                if episode.boostPayments.count > 0 {
                                    for payment in episode.boostPayments {
                                        let time = payment.timestamp.map({ TimeInterval($0)})?.toHHMMSS() ?? "unknown"
                                        print("\tBoost: \(payment.amount) - \(payment.message ?? "No message") - timestamp: \(time)")
                                    }
                                }
                            }
                            print("\n")
                        }
                    }
                    
                    print("\nSTREAMERS\n")
                    for user in users {
                        print("\(user.name ?? "Anon")\t\(user.aggregatedStreamPayments)")
                    }
                    
                    print("\nBOOST")
                    for user in users {
                        if user.aggregatedBoostPayments > 0 {
                            print("\n\(user.name ?? "Anon")")
                            for episode in user.episodes {
                                if episode.boostPayments.count > 0 {
                                    print("\t\(episode.title ?? episode.guid)")
                                    for payment in episode.boostPayments {
                                        let time = payment.timestamp.map({ TimeInterval($0)})?.toHHMMSS() ?? "unknown"
                                        print("\t\t\(payment.amount) - \(payment.message ?? "No message") - timestamp: \(time)")
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    Darwin.exit(EXIT_SUCCESS)
                    
                case .failure(let error):
                    print(error)
                    Darwin.exit(EXIT_SUCCESS)
            }
        }
        
        dispatchMain()
    }
    
    private func getAllTransactions(with token: String, dateLimit: Date, completionHandler: @escaping(Result<[RequestInvoiceResponse], Error>)->Void) {
        DispatchQueue.global().async {
            var currentPage = 1
            var transactions = [RequestInvoiceResponse]()
            var bail: Bool = false
            
            let semaphore = DispatchSemaphore(value: 0)
            while bail == false {
                print("Loading more transactions... (page \(currentPage))")
                alby.requestInvoices(with: token, page: currentPage, resultsPerPage: 25, createdAfter: dateLimit) { result in
                    switch result {
                        case .success(let paginatedResponse):
                            if verbose == true {
                                for transaction in paginatedResponse.response {
                                    print("id: \(transaction.identifier) - created at: \(transaction.createdAt) - by: \(transaction.boostagram?.senderName ?? "?")")
                                }
                                print("-------------------")
                            }
                            transactions.append(contentsOf: paginatedResponse.response)
                            if paginatedResponse.response.count < 25 {
                                bail = true
                            }
                            currentPage += 1
                        case .failure(let error):
                            completionHandler(.failure(error))
                            bail = true
                    }
                    
                    semaphore.signal()
                }
                semaphore.wait()
            }
            
            completionHandler(.success(transactions))
        }
        
    }
    
}

func parseDate(_ formatter: DateFormatter) -> (String) throws -> Date {
    { arg in
        guard let date = formatter.date(from: arg) else {
            throw ValidationError("Invalid date")
        }
        return date
    }
}



let shortFormatter = DateFormatter()
shortFormatter.dateStyle = .short

AlbyReport.main()

extension TimeInterval {
    
    /// Converts a `TimeInterval` into a MM:SS formatted string.
    ///
    /// - Returns: A `String` representing the MM:SS formatted representation of the time interval.
    public func toMMSS() -> String {
        guard self < Double.greatestFiniteMagnitude else { return "00:00" }
        let ts = Int(self)
        let s = ts % 60
        let m = (ts / 60) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    public func toHHMMSS() -> String {
        guard self < Double.greatestFiniteMagnitude else { return "00:00:00" }
        let ts = Int(self)
        let s = ts % 60
        let m = (ts / 60) % 60
        let h = (ts / 60 / 60) % 24
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
}

