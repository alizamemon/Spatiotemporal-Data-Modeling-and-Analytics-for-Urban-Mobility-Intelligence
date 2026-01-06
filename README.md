# Urban Mobility Intelligence: NYC CitiBike Analytics Pipeline

## Project Overview
This project demonstrates an end-to-end Data Engineering pipeline for urban mobility data. I processed over 300,000+ trip records from NYC CitiBike (Feb 2025) to derive actionable insights into commuter behavior and station demand.

## Technical Competencies 
* **Database Modeling:** Transitioned from raw heterogeneous data to a **3NF Normalized Star Schema**.
* **Advanced SQL:** Utilized Joins, Aggregations, Window Functions, and **SQL Views** for KPI tracking.
* **Performance Tuning:** Implemented **Non-Clustered Indexing** (`idx_started_at`) to optimize temporal queries.
* **Geospatial Analytics:** Performed spatial distribution analysis using Latitude/Longitude coordinates.

## Data Architecture
I followed the **Medallion Architecture** to ensure data quality:
1. **Staging (Bronze):** Raw ingestion of multiple CSV files via `BULK INSERT`.
2. **Cleaned (Silver):** Data validation (handling NULLs, filtering logical errors like `ended_at <= started_at`).
3. **Star Schema (Gold):** Final analytical layer with Fact and Dimension tables for high-performance querying.

## 📊 Visual Insights & Business Intelligence

Through the processed data, I generated several key visualizations to understand urban mobility patterns in New York City.

### 1. Temporal Demand Analysis (Peak Hours)
<img width="815" height="444" alt="Peak Hour Analysis" src="https://github.com/user-attachments/assets/39958c29-9e0b-448a-b89c-ea2a28f602f9" />

* **Metric:** `Ride_hour` vs `Total_Trips`
* **Insight:** Identified clear bimodal peaks during 8:00 AM and 5:00 PM - 6:00 PM, confirming that the majority of users are daily commuters.

### 2. Station Load & Popularity
<img width="974" height="447" alt="Station Load Analysis" src="https://github.com/user-attachments/assets/2002b1a1-416b-40fc-8060-37197e1bf6f2" />

* **Metric:** `Station_Name` vs `Total_trips`
* **Insight:** Highlighted the top 10 high-traffic stations, providing critical data for bike redistribution and maintenance scheduling.

### 3. User Segmentation (Ridership Patterns)
<img width="431" height="338" alt="Member vs Casual Patterns" src="https://github.com/user-attachments/assets/9ecd056e-9406-4c2b-a22d-357c10d8965a" />

* **Metric:** `Member_Type` vs `Total_trips` & `Avg_Duration_Minutes`
* **Insight:** While "Members" take more trips, "Casual" riders have a significantly higher average trip duration, indicating recreational use versus commuter use.

### 4. Geospatial Heat Map (3D Visualization)
<img width="759" height="541" alt="Geospatial 3D Map" src="https://github.com/user-attachments/assets/6b329f18-6be4-46a1-ac0d-954e168c8bec" />

* **Metric:** `Station_Name`, `Latitude`, `Longitude` weighted by `Total_trips`
* **Insight:** A 3D geospatial distribution of trip density across NYC, showing concentrated demand in Manhattan and Brooklyn transit hubs.




## How to Run
1. Execute the `citibike_pipeline.sql` script in MS SQL Server.
2. Ensure the file paths in the `BULK INSERT` section match your local directory.
3. Open `Urban_Mobility_Analysis.xlsx` to view the connected Power Query dashboard.
