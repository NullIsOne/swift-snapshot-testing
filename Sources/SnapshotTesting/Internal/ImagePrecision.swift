import Foundation

func imagePrecisionFailureMessage(
  differentUnitCount: Int,
  unitCount: Int,
  precision: Float
) -> String? {
  let actualPrecision = 1 - Float(differentUnitCount) / Float(unitCount)
  let tolerance = max(Float.ulpOfOne, 1.0 / Float(unitCount))
  guard actualPrecision + tolerance < precision else { return nil }
  return "Actual image precision \(actualPrecision) is less than required \(precision)"
}
