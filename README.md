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

## 📊 Visual Insights
### 1. Spatial Demand (3D Map)
![Geospatial Map](path_to_your_map_screenshot.png)
*Visualizing high-density trip start points across NYC.*

### 2. Peak Hour Analysis
![Peak Hours Chart](path_to_your_bar_chart_screenshot.png)
*Identifying morning and evening commuter surges.*

### 3. Member vs. Casual Ridership
![Member Pie Chart](path_to_your_pie_chart_screenshot.png)
*Analyzing the subscription-based business model efficiency.*

## How to Run
1. Execute the `citibike_pipeline.sql` script in MS SQL Server.
2. Ensure the file paths in the `BULK INSERT` section match your local directory.
3. Open `Urban_Mobility_Analysis.xlsx` to view the connected Power Query dashboard.
