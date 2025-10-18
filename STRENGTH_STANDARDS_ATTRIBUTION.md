# Strength Standards Data - Attribution & Legal Notice

## 📊 Data Sources

This application uses strength standards data for educational and reference purposes to help users estimate appropriate starting weights for exercises.

### Primary Sources

#### 1. **ExRx.net**
- **URL**: https://exrx.net/Testing/WeightLifting/StrengthStandards
- **Data Used**: Strength standards tables for Bench Press, Squat, Deadlift, and Overhead Press
- **Usage**: Manually transcribed tables (not scraped) from publicly available pages
- **License**:
  - Copyright © ExRx.net, LLC
  - Data used for educational reference only
  - Not for commercial redistribution
  - Attribution required
- **Attribution**: "Strength standards reference data from ExRx.net"

#### 2. **SymmetricStrength**
- **URL**: https://symmetricstrength.com/standards
- **Data Used**: Bodyweight multiplier ratios and level definitions
- **Usage**: Manual reference only (no API or automated access)
- **License**:
  - Copyright © Symmetric Strength
  - Data used for educational reference only
  - API usage prohibited without written permission
- **Attribution**: "Reference standards from SymmetricStrength.com"

---

## 🔒 Legal Compliance

### How We Use The Data

1. **Manual Transcription Only**: All data was manually copied from publicly available web pages. No automated scraping or API access was used.

2. **Educational Purpose**: Data is used solely to provide reference suggestions to users for workout planning.

3. **Attribution**: Full attribution is provided in this document and within the application.

4. **No Redistribution**: The raw data is not exposed via API or sold/redistributed.

5. **Transformative Use**: Data is processed and combined with user profiles to generate personalized suggestions (transformative use).

### What Users Should Know

- Strength standards are **reference estimates only**
- Individual capabilities vary based on many factors
- Users should always start conservatively and progress safely
- Data should not substitute for professional coaching or medical advice

---

## 📖 Data Structure

### Files Containing Standards Data

- `assets/data/strength_standards.json` - Core strength standards database
- Application uses this data to calculate suggested weights based on:
  - User bodyweight
  - Self-reported experience level
  - Exercise type and equipment

### Calculation Methodology

For exercises with complete data:
```
Suggested Weight = Standard 1RM for (bodyweight, level) × 0.70
```
Where 0.70 represents 70% of 1RM for hypertrophy training (8-12 reps).

For exercises with estimated data:
```
Suggested Weight = Bodyweight × Multiplier × Training Goal Factor
```

---

## 📝 Scientific References

### 1RM Calculation Formulas

- **Brzycki Formula**: `1RM = weight / (1.0278 - 0.0278 × reps)`
  - Accuracy: ±3kg for 3-10 reps
  - Source: Brzycki, M. (1993). "Strength testing—Predicting a one-rep max from reps-to-fatigue"

- **Epley Formula**: `1RM = weight × (1 + 0.0333 × reps)`
  - Accuracy: ±2.7kg for 3-10 reps
  - Source: Epley, B. (1985). "Poundage Chart"

### Level Definitions

Based on consensus from ExRx.net and SymmetricStrength:
- **Untrained**: 0 months training
- **Novice**: 2-6 months regular training
- **Intermediate**: 1-2 years regular training
- **Advanced**: 3-5 years structured training
- **Elite**: 5+ years competitive level

---

## ⚠️ Disclaimer

**IMPORTANT NOTICE:**

1. **Not Medical Advice**: This data and the suggestions derived from it are for informational and educational purposes only. They do not constitute medical, fitness, or professional advice.

2. **Individual Variation**: Actual strength levels vary significantly based on genetics, training history, technique, recovery, nutrition, and many other factors.

3. **Start Conservatively**: Users should always start with lighter weights than suggested and progress gradually.

4. **Consult Professionals**: Users should consult qualified fitness professionals or healthcare providers before beginning any strength training program.

5. **Liability**: The application developers and data providers assume no liability for injuries or damages resulting from use of this data.

---

## 🔄 Updates & Maintenance

### Data Accuracy
- Last manual review: January 2025
- Standards data updated from source websites as of January 2025
- Estimated multipliers based on common strength training benchmarks

### Future Updates
- Data will be periodically reviewed and updated
- User feedback may inform adjustments to estimation formulas
- New exercises may be added with community validation

---

## 📧 Contact & Questions

For questions about data usage or attribution:
- Open an issue on the GitHub repository
- Contact: [Your support email]

To request removal or modification of data:
- Please provide specific concerns
- We will respond within 48 hours

---

## ✅ Summary Checklist

- [x] Data manually transcribed (no scraping)
- [x] Attribution provided for all sources
- [x] Educational use only (not commercial redistribution)
- [x] Disclaimer and liability notice included
- [x] Users informed data is reference only
- [x] Transformative use (personalized calculations)
- [x] No direct API exposure of raw data
- [x] Periodic review and updates planned

---

**Last Updated**: January 15, 2025
**Document Version**: 1.0.0
