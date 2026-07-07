# Example Queries

The  following are example queries based on a few of the outlined use cases that were presented. For the relational schema, example SQL formatted queries are written and for the NoSQL schema, an overview of the query is provided.

## Dose Deviation Detection 
This query would run automated daily as part of operation analysis procedures that would seek to identify and rectify issues with under/over dosing before it becomes a widespread issue. Additionally, it could also be requested on-demand by someone with appropriate clearance to check for issues even before EOD procedures. It returns a list of all anomalies between ordered and administered medications that are charted.

### Relational Schema:

SELECT p.subject_id,
    a.hadm_id,
    pr.drug,
    pr.dose_val_rx AS ordered_dose,
    pr.dose_unit_rx AS ordered_unit,
    ed.dose_given,
    ed.dose_given_unit,
    e.charttime
FROM Prescriptions AS pr
JOIN Admissions AS a
    ON pr.hadm_id = a.hadm_id
JOIN Patients AS p
    ON pr.subject_id = p.subject_id
JOIN Emar AS e
    ON e.hadm_id = pr.hadm_id
    AND e.medication = pr.drug
JOIN Emar_Detail AS ed
    ON ed.emar_id = e.emar_id
WHERE ed.dose_given IS NOT NULL
    AND pr.dose_val_rx IS NOT NULL
    AND ed.dose_given <> pr.dose_val_rx
ORDER BY a.hadm_id, e.charttime;

### NoSQL Schema:

The NoSQL traversal from our schema would iterate the `admissions` array within each file, looking for pairs of `prescription.drug = emar.medication` and `emar.hamd_id = prescription.hamd_id` for each `hamd_id`. From there, for each match it would check the `emar` entries and checks `emar_detail.dose_given` and `prescription.dose_val_rx` being not null and if all conditions are fulfilled, spits out all the values that it checked along with `dose_given_unit` and `charttime`.

## Omitted & Delayed Doses

This query would run in the same batch of analytics daily or on demand that the above query would run in, this time identifying delays and omitted doses of medications, grouped by medications..

### Relational Schema:

SELECT e.medication,
    a.admission_type,
    e.event_txt,
    COUNT(*) AS occurrences,
FROM Emar AS e
JOIN Admissions AS a
    ON e.hadm_id = a.hadm_id
WHERE e.event_txt LIKE '%not given%'
    OR e.charttime - e.scheduletime > INTERVAL '30 minutes'
GROUP BY e.medication,
    a.admission_type,
    e.event_txt
ORDER BY occurrences DESC;

### NoSQL Schema:

Within each document it would again iterate on `admissions`, reading `admission_type` and `hadm_id` and then iterate through the `emar` arrays. It checks the equivalent of the SQL `WHERE` clause and if it meets the criteria outlined above, it would emit the occurrences of corresponding tuples in descending order. 

# Alternative Relational Algebra Tree Analysis

The alternate RA tree that is presented offers processing benefits as it pushes the `WHERE` clause before the `JOIN`, eliminating the unnecessary rows before going into the join. Compared to filtering after joining with `Admissions`, if we eliminate rows that are irrelevant to our query before we perform the expensive join rather than after, it saves us processing time. 
