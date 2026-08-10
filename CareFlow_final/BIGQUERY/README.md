# BigQuery

## Overview

This folder contains the BigQuery-related components of the CareFlow data pipeline.

Google BigQuery is used as the cloud data warehouse for storing and querying the hospital event-log data.

## Data Flow

Raw CSV
   ↓
Google BigQuery
   ↓
raw_ehr_events
   ↓
dbt transformations
   ↓
Analytics-ready tables

## Dataset

The raw event data is loaded into a BigQuery table:

`raw_ehr_events`

The table contains the hospital event logs required for downstream transformation and process mining analysis.

## BigQuery Tasks

The following tasks are performed:

- Create BigQuery project/dataset
- Create the required tables
- Load raw event data
- Validate table structure
- Run SQL queries
- Check data quality
- Prepare data for dbt

## Example Queries

Count total events:

```sql
SELECT COUNT(*) AS total_events
FROM `project.dataset.raw_ehr_events`;
