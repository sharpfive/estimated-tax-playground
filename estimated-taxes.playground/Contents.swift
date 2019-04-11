import UIKit

// This is a playground. It is not intended for tax advice or to replace the work of an accountant.
// As in life, free accounting advice is worth what you pay for it.
// This playground does things like assume you pay your employment taxes through a payroll provider

// Note this doesn't handle the top tax bracket, if you need this functionality you can affort to pay someone to write the feature :p
struct TaxBracket {
    let upperBound: Int
    let percentage: Double

    var decimalValue: Double {
        return Double(percentage) / 100.0
    }
}

struct ExpandedTaxBracket {
    let percentage: Double
    let lowerBound: Int
    let upperBound: Int

    var decimalValue: Double {
        return Double(percentage) / 100.0
    }
}

// EDIT total estimated personal income
var estimatedGrossIncome = 100000

// EDIT how much federal tax is taken out of your paycheck per month
let monthlyFederalTaxPaid = 500.0

// EDIT monthly Salary (not currently used)
let monthlySalaryPaid = 5000.0

// EDIT how much state tax is taken out of your paycheck per month
let monthlyStateTaxPaid = 240.0

// EDIT above the line deductions (HSA, retirement, student loan interest)
// https://en.wikipedia.org/wiki/Above-the-line_deduction#List_of_the_above-the-line_deductions
let aboveTheLineDeductions = 3500

// EDIT Any deductions (or leave blank to use standard deduction)
let itemizedDeductions = 0

// The standard deduction (for 2019)
let standardDeduction = 24400

// Both sides of the employment tax Rate (not using any of these calculations)
let selfEmploymentTaxRate = 15.3

let yearlySalary = monthlySalaryPaid * 12

let employmentTaxDue = yearlySalary * selfEmploymentTaxRate

// EDIT US Federal Tax Brackets
let usMarried2019TaxBrackets = [
    TaxBracket(upperBound: 19400, percentage: 10),
    TaxBracket(upperBound: 78950, percentage: 12),
    TaxBracket(upperBound: 168400, percentage: 22),
    TaxBracket(upperBound: 321450, percentage: 24),
    TaxBracket(upperBound: 408200, percentage: 32),
    TaxBracket(upperBound: 612350, percentage: 35),
]

// EDIT for your state
let mnMarried2019TaxBrackets = [
    TaxBracket(upperBound: 38770, percentage: 5.35),
    TaxBracket(upperBound: 154020, percentage: 7.05),
    TaxBracket(upperBound: 168400, percentage: 7.85),
    TaxBracket(upperBound: 273150, percentage: 9.85),
]

let estimatedAdjustedGrossIncome = max(estimatedGrossIncome - aboveTheLineDeductions, 0)

let deductions = (min(itemizedDeductions, standardDeduction))

let taxableIncome = max(estimatedAdjustedGrossIncome - deductions, 0)

// Turns Taxbracket into a more usable ExpandedTaxBracket
func expand(taxBrackets: [TaxBracket]) -> [ExpandedTaxBracket] {
    var lastUpperBound = 0
    return taxBrackets.map {
        let expandedTaxBracket = ExpandedTaxBracket(percentage: $0.percentage, lowerBound: lastUpperBound, upperBound: $0.upperBound)
        lastUpperBound = $0.upperBound
        return expandedTaxBracket
    }
}

func incomeTaxDue(for income: Int, taxBrackets: [TaxBracket]) -> Double {
    let expandedTaxBrackets = expand(taxBrackets: taxBrackets)
    return incomeTaxDue(for: income, expandedTaxBrackets: expandedTaxBrackets)
}

func incomeTaxDue(for income: Int, expandedTaxBrackets: [ExpandedTaxBracket]) -> Double {
    return expandedTaxBrackets.reduce(0.0) { (previousResult, bracket) -> Double in
        if income <= bracket.lowerBound {
            return previousResult
        }

        let upperBound = min(income, bracket.upperBound)
        let taxRange = upperBound - bracket.lowerBound
        return previousResult + Double(taxRange) * bracket.decimalValue
    }
}

let federalTaxAlreadyPaid = monthlyFederalTaxPaid * 12
let federalTaxDue = incomeTaxDue(for: taxableIncome, taxBrackets: usMarried2019TaxBrackets)
let estimatedFederalTaxDue = (federalTaxDue - federalTaxAlreadyPaid) / 4

let mnTaxAlreadyPaid = monthlyStateTaxPaid * 12
let mnTaxDue = incomeTaxDue(for: taxableIncome, taxBrackets: mnMarried2019TaxBrackets)
let estimatedMNTaxDue = (mnTaxDue - mnTaxAlreadyPaid) / 4


