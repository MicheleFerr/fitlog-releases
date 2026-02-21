/// Calculates estimated 1RM using the Brzycki formula.
///
/// Returns `null` when the inputs are invalid (weight <= 0, reps <= 0,
/// or reps > 36 where the formula breaks down).
double? calculate1RM(double weight, int reps) {
  if (weight <= 0) return null;
  if (reps <= 0) return null;
  if (reps == 1) return weight;
  if (reps > 36) return null; // Formula breaks down above 36 reps

  return weight * (36 / (37 - reps));
}
