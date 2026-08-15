-- ============================================================
-- CAREFLOW - CLEANED HOSPITAL EVENT LOG VALIDATION
-- Project  : careflow
-- Dataset  : careflow_raw
-- Table    : hospital_event_log_cleaned
-- CSV Rows : 52,551
-- ============================================================


-- ============================================================
-- 1. CHECK TABLE EXISTS
-- ============================================================

SELECT
  table_name
FROM `careflow.careflow_raw.INFORMATION_SCHEMA.TABLES`
WHERE table_name = 'hospital_event_log_cleaned';


-- ============================================================
-- 2. CHECK TOTAL ROW COUNT
-- Expected: 52,551
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  52551 AS expected_csv_rows,
  COUNT(*) - 52551 AS difference
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 3. CHECK COLUMN NAMES AND DATA TYPES
-- Expected: 30 columns
-- ============================================================

SELECT
  ordinal_position,
  column_name,
  data_type,
  is_nullable
FROM `careflow.careflow_raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'hospital_event_log_cleaned'
ORDER BY ordinal_position;


-- ============================================================
-- 4. CHECK NUMBER OF COLUMNS
-- Expected: 30
-- ============================================================

SELECT
  COUNT(*) AS total_columns,
  30 AS expected_columns,
  COUNT(*) - 30 AS difference
FROM `careflow.careflow_raw.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'hospital_event_log_cleaned';


-- ============================================================
-- 5. CHECK NULL VALUES
-- ============================================================

SELECT
  COUNTIF(Event_ID IS NULL) AS Event_ID_NULL,
  COUNTIF(Patient_ID IS NULL) AS Patient_ID_NULL,
  COUNTIF(Patient_Name IS NULL) AS Patient_Name_NULL,
  COUNTIF(Age IS NULL) AS Age_NULL,
  COUNTIF(Gender IS NULL) AS Gender_NULL,
  COUNTIF(Disease IS NULL) AS Disease_NULL,
  COUNTIF(Severity IS NULL) AS Severity_NULL,
  COUNTIF(Patient_Type IS NULL) AS Patient_Type_NULL,
  COUNTIF(Department IS NULL) AS Department_NULL,
  COUNTIF(Activity IS NULL) AS Activity_NULL,
  COUNTIF(Activity_Status IS NULL) AS Activity_Status_NULL,
  COUNTIF(Timestamp IS NULL) AS Timestamp_NULL,
  COUNTIF(Event_Order IS NULL) AS Event_Order_NULL,
  COUNTIF(Doctor_ID IS NULL) AS Doctor_ID_NULL,
  COUNTIF(Doctor_Name IS NULL) AS Doctor_Name_NULL,
  COUNTIF(Shift IS NULL) AS Shift_NULL,
  COUNTIF(Wait_Time_Minutes IS NULL) AS Wait_Time_NULL,
  COUNTIF(Service_Time_Minutes IS NULL) AS Service_Time_NULL,
  COUNTIF(Total_Process_Time IS NULL) AS Total_Process_Time_NULL,
  COUNTIF(Rework_Flag IS NULL) AS Rework_Flag_NULL,
  COUNTIF(Previous_Activity IS NULL) AS Previous_Activity_NULL,
  COUNTIF(Next_Activity IS NULL) AS Next_Activity_NULL,
  COUNTIF(Delay_Reason IS NULL) AS Delay_Reason_NULL,
  COUNTIF(Resource IS NULL) AS Resource_NULL,
  COUNTIF(Ward IS NULL) AS Ward_NULL,
  COUNTIF(Bed_Number IS NULL) AS Bed_Number_NULL,
  COUNTIF(Admission_Date IS NULL) AS Admission_Date_NULL,
  COUNTIF(Discharge_Date IS NULL) AS Discharge_Date_NULL,
  COUNTIF(Outcome IS NULL) AS Outcome_NULL,
  COUNTIF(Total_Bill IS NULL) AS Total_Bill_NULL
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 6. CHECK DUPLICATE EVENT IDs
-- Expected: No rows
-- ============================================================

SELECT
  Event_ID,
  COUNT(*) AS duplicate_count
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
GROUP BY Event_ID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- ============================================================
-- 7. CHECK UNIQUE EVENTS AND PATIENTS
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Event_ID) AS unique_events,
  COUNT(DISTINCT Patient_ID) AS unique_patients
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 8. CHECK AGE RANGE
-- ============================================================

SELECT
  MIN(Age) AS minimum_age,
  MAX(Age) AS maximum_age,
  ROUND(AVG(Age), 2) AS average_age
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 9. CHECK WAIT AND SERVICE TIMES
-- ============================================================

SELECT
  MIN(Wait_Time_Minutes) AS minimum_wait_time,
  MAX(Wait_Time_Minutes) AS maximum_wait_time,
  ROUND(AVG(Wait_Time_Minutes), 2) AS average_wait_time,

  MIN(Service_Time_Minutes) AS minimum_service_time,
  MAX(Service_Time_Minutes) AS maximum_service_time,
  ROUND(AVG(Service_Time_Minutes), 2) AS average_service_time
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 10. CHECK TOTAL PROCESS TIME
-- ============================================================

SELECT
  MIN(Total_Process_Time) AS minimum_process_time,
  MAX(Total_Process_Time) AS maximum_process_time,
  ROUND(AVG(Total_Process_Time), 2) AS average_process_time
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 11. CHECK TOTAL BILL
-- ============================================================

SELECT
  MIN(Total_Bill) AS minimum_bill,
  MAX(Total_Bill) AS maximum_bill,
  ROUND(AVG(Total_Bill), 2) AS average_bill,
  ROUND(SUM(Total_Bill), 2) AS total_bill
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 12. CHECK EVENT DATE RANGE
-- ============================================================

SELECT
  MIN(Timestamp) AS first_event,
  MAX(Timestamp) AS last_event,
  MIN(Admission_Date) AS first_admission,
  MAX(Admission_Date) AS last_admission,
  MAX(Discharge_Date) AS last_discharge
FROM `careflow.careflow_raw.hospital_event_log_cleaned`;


-- ============================================================
-- 13. CHECK GENDER DISTRIBUTION
-- ============================================================

SELECT
  Gender,
  COUNT(*) AS total
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
GROUP BY Gender
ORDER BY total DESC;


-- ============================================================
-- 14. CHECK DEPARTMENT DISTRIBUTION
-- ============================================================

SELECT
  Department,
  COUNT(*) AS total_events
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
GROUP BY Department
ORDER BY total_events DESC;


-- ============================================================
-- 15. CHECK DISEASE DISTRIBUTION
-- ============================================================

SELECT
  Disease,
  COUNT(*) AS total_events
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
GROUP BY Disease
ORDER BY total_events DESC;


-- ============================================================
-- 16. CHECK OUTCOME DISTRIBUTION
-- ============================================================

SELECT
  Outcome,
  COUNT(*) AS total_events
FROM `careflow.careflow_raw.hospital_event_log_cleaned`
GROUP BY Outcome
ORDER BY total_events DESC;


-- ============================================================
-- 17. FINAL VALIDATION SUMMARY
-- ============================================================

SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT Event_ID) AS unique_event_ids,
  COUNT(DISTINCT Patient_ID) AS unique_patient_ids,
  COUNT(*) - COUNT(DISTINCT Event_ID) AS duplicate_event_count,

  MIN(Age) AS min_age,
  MAX(Age) AS max_age,

  ROUND(AVG(Wait_Time_Minutes), 2) AS avg_wait_time,
  ROUND(AVG(Service_Time_Minutes), 2) AS avg_service_time,
  ROUND(AVG(Total_Process_Time), 2) AS avg_process_time,

  ROUND(SUM(Total_Bill), 2) AS total_bill,
  ROUND(AVG(Total_Bill), 2) AS average_bill

FROM `careflow.careflow_raw.hospital_event_log_cleaned`;