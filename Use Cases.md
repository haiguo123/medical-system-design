# MIMIC-IV Demo Use Cases (V2, 12 Tables)

This version keeps the scope to exactly 12 tables while still supporting four rich use cases. It is designed to align with the project requirement to describe applications and use cases, while keeping the schema surface area small and explainable.

## Project Requirements Context
This document supports the project requirement to describe the dataset, identify applications and use cases, and outline query ideas. It intentionally limits the working schema to 12 tables so the team can focus on clear, defensible use cases while still meeting the minimum complexity threshold. Additional requirements such as governance, alternative schema design, and logical query plans are addressed elsewhere, but the use cases here are written so they can be translated into queries and performance discussions.

## Dataset Context (Team Summary)
- The MIMIC-IV Demo is a de-identified clinical dataset representing a subset of 100 patients, but it preserves the full schema and relationships of MIMIC-IV.
- Data is split into hospital-level and ICU-level modules. Hospital data covers admissions, labs, medications, orders, and patient movement. ICU data includes high-frequency bedside measurements.
- Dates are consistently shifted per patient for privacy; identifiers are synthetic; free-text notes are excluded.
- The dataset is best used for structured analytics, cohort building, quality improvement, and prototyping.

## Table Set (12 Total)
1) patients: patient demographics (age, sex, death date).
2) admissions: admission timing and context (admit/discharge, insurance, race, admission type).
3) transfers: unit movement events (careunit, in/out times).
4) services: clinical service changes within an admission.
5) icustays: ICU stay timing and care unit type.
6) chartevents: bedside vitals and measurements in ICU.
7) d_items: dictionary for ICU item ids (labels and units).
8) labevents: laboratory results for admissions.
9) d_labitems: dictionary for lab item ids (labels and specimen types).
10) emar: medication administrations (what was given, when).
11) emar_detail: detailed administration fields (dose, route, infusion details).
12) prescriptions: medication orders (drug, dose, route, schedule).

## Terminology (Plain Language)
- ICU: Intensive Care Unit, a hospital unit for critically ill patients who need continuous monitoring and advanced support.
- MIMIC-IV: Medical Information Mart for Intensive Care, version IV; a de-identified clinical database built from real hospital care.
- eMAR: electronic medication administration record; the log of what was actually given to a patient.
- LOS: length of stay, the total time in a hospital or ICU.
- Hypotension: abnormally low blood pressure.
- Lactate: a blood marker of tissue oxygen stress; higher values can indicate poor perfusion.
- Fluid balance: the difference between fluid inputs and outputs over time.

---

## Use Case 1: Medication Administration Safety and Reconciliation

**Goal:** Detect missed doses, delays, and mismatches between ordered and administered medications.

**Tables used:** emar, emar_detail, prescriptions, admissions, patients.

### Column descriptions
**emar**
- `emar_id`: unique administration record.
- `subject_id`, `hadm_id`: patient and admission identifiers.
- `medication`: name of medication administered.
- `event_txt`: administration status text (given, not given, etc.).
- `scheduletime`, `charttime`, `storetime`: scheduled, documented, and stored times.

**emar_detail**
- `emar_id`: link to emar.
- `dose_due`, `dose_due_unit`: expected dose and unit.
- `dose_given`, `dose_given_unit`: actual dose and unit.
- `route`: route of administration (e.g., IV, oral).
- `infusion_rate`, `infusion_rate_unit`: infusion settings if applicable.
- `complete_dose_not_given`: indicates partial or missed doses.

**prescriptions**
- `subject_id`, `hadm_id`: patient and admission identifiers.
- `drug`, `drug_type`: ordered drug and category.
- `dose_val_rx`, `dose_unit_rx`: ordered dose and unit.
- `route`: ordered route.
- `starttime`, `stoptime`: order timing window.

**admissions**
- `hadm_id`: admission identifier.
- `admittime`, `dischtime`: admission window.
- `insurance`, `race`, `admission_type`: context for stratified safety analysis.

**patients**
- `subject_id`: patient identifier.
- `gender`, `anchor_age`: demographics used for subgroup comparisons.

### Example analyses
- Compare ordered dose (`dose_val_rx`) to administered dose (`dose_given`).
- Identify doses with `event_txt` showing omission or delay.
- Compute delay between `scheduletime` and `charttime` by unit or shift.

### Queries (plain English)
- For each admission, list medications where the administered dose differs from the ordered dose.
- Show all administrations marked as "not given" and group them by medication and admission type.

### Example outputs
- Medication safety dashboard by admission and by patient.
- List of high-risk meds with frequent deviations.

---

## Use Case 2: ICU Early Warning and Length-of-Stay Prediction

**Goal:** Use early ICU vitals and labs to flag patients at risk of prolonged ICU stays.

**Tables used:** icustays, chartevents, d_items, labevents, d_labitems, admissions, patients.

### Column descriptions
**icustays**
- `stay_id`: ICU stay identifier.
- `subject_id`, `hadm_id`: patient and admission identifiers.
- `intime`, `outtime`: ICU entry and exit times.
- `first_careunit`, `last_careunit`: ICU unit types.
- `los`: ICU length of stay in days.

**chartevents**
- `stay_id`: ICU stay identifier.
- `itemid`: measurement id (vital sign).
- `charttime`: measurement time.
- `value`, `valuenum`, `valueuom`: measurement value and unit.

**d_items**
- `itemid`: measurement id.
- `label`: human-readable name (e.g., Heart Rate).
- `unitname`: standard unit.

**labevents**
- `hadm_id`: admission identifier.
- `itemid`: lab test id.
- `charttime`: lab time.
- `value`, `valuenum`, `valueuom`: lab result.
- `ref_range_lower`, `ref_range_upper`: reference bounds.

**d_labitems**
- `itemid`: lab test id.
- `label`: lab test name.
- `fluid`: specimen type.

**admissions/patients**
- `admittime`, `dischtime`, `gender`, `anchor_age`: context and stratification.

### Example analyses
- Build early ICU features from first 6-24 hours of `chartevents`.
- Use labs (e.g., lactate, creatinine) to stratify risk of long LOS.
- Compare LOS by age group or admission type.

### Queries (plain English)
- For each ICU stay, compute the average heart rate in the first 24 hours and list the longest stays.
- Find ICU stays where first-day lactate is above the reference range and compare their LOS to others.

### Example outputs
- Risk tiers for ICU stays (short, medium, prolonged).
- Key early warning indicators with thresholds.

---

## Use Case 3: Utilization and Discharge Planning by Demographics

**Goal:** Explain how demographics and admission context relate to utilization patterns and discharge outcomes.

**Tables used:** patients, admissions, icustays, services, transfers.

### Column descriptions
**patients**
- `subject_id`: patient identifier.
- `gender`, `anchor_age`, `anchor_year_group`: demographics and cohorting.
- `dod`: date of death (if applicable).

**admissions**
- `hadm_id`: admission identifier.
- `admittime`, `dischtime`: admission window.
- `admission_type`, `admission_location`, `discharge_location`: admission and discharge context.
- `insurance`, `race`, `marital_status`: demographic and payer context.

**icustays**
- `stay_id`: ICU stay identifier.
- `intime`, `outtime`, `los`: ICU timing and length of stay.

**services**
- `transfertime`: time of service change.
- `prev_service`, `curr_service`: service transitions within an admission.

**transfers**
- `eventtype`, `careunit`, `intime`, `outtime`: movement between units.

### Example analyses
- Compare LOS by insurance type or admission type.
- Identify service lines with the highest ICU utilization rates.
- Summarize discharge locations by demographic segment.

### Queries (plain English)
- Compare average hospital length of stay by insurance type and age group.
- List discharge locations by race and admission type.

### Example outputs
- Utilization report by payer and age group.
- Discharge destination breakdown with ICU exposure.

---

## Use Case 4: Hospital Flow and Transfer Bottlenecks

**Goal:** Identify unit-level bottlenecks and delays in patient movement.

**Tables used:** admissions, transfers, services, icustays.

### Column descriptions
**admissions**
- `admittime`, `dischtime`: hospital stay window.
- `admission_type`, `admission_location`, `discharge_location`: context for flow analysis.

**transfers**
- `transfer_id`: transfer event identifier.
- `eventtype`: movement type.
- `careunit`: destination or source unit.
- `intime`, `outtime`: time in unit.

**services**
- `transfertime`: time of service change.
- `prev_service`, `curr_service`: service transitions.

**icustays**
- `intime`, `outtime`, `first_careunit`, `last_careunit`: ICU flow context.

### Example analyses
- Time from admission to ICU entry by admission type.
- Units with highest dwell time or frequent back-and-forth transfers.
- Service changes correlated with prolonged transfer delays.

### Queries (plain English)
- Compute the time from hospital admission to first ICU entry for each admission.
- Identify care units with the highest average dwell time and the most transfer events.

### Example outputs
- Flow map of transitions (ED -> ICU -> floor).
- Bottleneck report by careunit and service.

---

## Overview
These four use cases reuse core identifiers (`subject_id`, `hadm_id`, `stay_id`) and rely on a compact set of event, dictionary, and flow tables. This keeps the schema manageable while still enabling medication safety, ICU risk analysis, utilization planning, and flow optimization.
