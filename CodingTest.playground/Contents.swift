import UIKit

func convertToDictionary(_ data: Data) -> [[String: Any]] {
    do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
    } catch {
        print(error.localizedDescription)
        return []
    }
}

func cleanString(_ input: Any?, defaultString: String) -> String {
    guard let input = input as? String else { return defaultString }
    if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        return defaultString
    } else {
        return input
    }
}

func execute() {
    guard let url = URL(string: "https://eacp.energyaustralia.com.au/codingtest/api/v1/festivals") else {
        return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else { return }

        // Process data
        var masterRecordLabel = [String: [String: [String: Bool]]]()
        let dictionary: [[String: Any]] = convertToDictionary(data)
        for festival in dictionary {
            let festivalName = cleanString(festival["name"],
                                           defaultString: "Unknown Festival")
            guard let festivalBands = festival["bands"] as? [[String: Any]] else {
                continue
            }

            for band in festivalBands {
                let bandName = cleanString(band["name"],
                                           defaultString: "Unknown Band")
                let recordLabelName = cleanString(band["recordLabel"],
                                                  defaultString: "Unknown Record Label")
                if masterRecordLabel[recordLabelName] == nil {
                    masterRecordLabel[recordLabelName] = [:]
                }
                if masterRecordLabel[recordLabelName]?[bandName] == nil {
                    masterRecordLabel[recordLabelName]?[bandName] = [:]
                }
                masterRecordLabel[recordLabelName]?[bandName]?[festivalName] = true
            }
        }

        // Output
        for recordLabelName in masterRecordLabel.keys.sorted() {
            print(recordLabelName)

            let dictBands = masterRecordLabel[recordLabelName] ?? [:]
            for bandName in dictBands.keys.sorted() {
                print("   " + bandName)

                let dictFestivals = dictBands[bandName] ?? [:]
                for festivalName in dictFestivals.keys.sorted() {
                    print("      " + festivalName)
                }
            }
        }
    }

    task.resume()
}

execute()
