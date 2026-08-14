# CareFlow – CSV vs BigQuery Comparison Documentation

## 1. Purpose

This document records the Member 4 Day 5 comparison between the CareFlow cleaned CSV event log and the schema expected for the BigQuery event-log table.
The uploaded file is the CSV side of the comparison. No BigQuery query result or export was supplied, so live BigQuery values are not invented.

## 2. CSV Dataset Reviewed

- CSV records: **9,751**
- CSV columns: **12**
- Exact duplicate rows: **0**
- Duplicate Event_ID values: **38**

## 3. Schema Comparison

| Check | Result |
|---|---|
| Expected business columns present | **11/11** |
| Missing expected columns | **0** |
| Extra columns | **1** |
| Missing columns | **None** |
| Extra columns | **Event_ID** |

## 4. CSV Data-Quality Checks

| Check | CSV Result |
|---|---:|
| Total records | 9,751 |
| Missing values | 290 |
| Unique Case_ID values | 1,000 |
| Unique Patient_ID values | 1,000 |
| Unique activities | 17 |
| Invalid/missing timestamps | 50 |
| Negative waiting times | 80 |

## 5. BigQuery Comparison Status

| Comparison | Status |
|---|---|
| CSV row count = BigQuery row count | **NOT VERIFIED** |
| CSV column count = BigQuery column count | **NOT VERIFIED** |
| CSV schema = BigQuery schema | **NOT VERIFIED** |
| CSV Case_ID values = BigQuery Case_ID values | **NOT VERIFIED** |
| CSV Activity values = BigQuery Activity values | **NOT VERIFIED** |
| CSV timestamps = BigQuery timestamps | **NOT VERIFIED** |
| CSV duplicate count = BigQuery duplicate count | **NOT VERIFIED** |

## 6. Comparison Procedure

1. Load the cleaned CSV into the BigQuery raw/staging table.
2. Compare total row counts.
3. Compare column names and data types.
4. Compare distinct Case_ID and Event_ID counts.
5. Compare null counts for each column.
6. Compare activity frequencies.
7. Compare minimum and maximum timestamps.
8. Compare duplicate records.
9. Investigate mismatches before sending the data to PM4Py.

## 7. Conclusion

The uploaded CSV is the source-side dataset for the comparison. The actual BigQuery table/export is still required to confirm that CSV and BigQuery contain identical records and values. This report therefore distinguishes verified CSV results from comparisons that cannot yet be verified.