# Retail Sales and Load-Shedding Analysis

## Project overview

This project evaluates the relationship between load shedding and
retail business performance during 2023. SQL was used in Databricks
to clean, transform and aggregate the data, while Power BI was used
to develop an interactive executive dashboard.

## Business problem

Management needed to understand:

- How sales and profit performed throughout the year
- Whether load shedding reduced daily sales or profit
- The financial effect of diesel-generator expenditure
- Which regions and categories generated the most profit
- Where management should focus future attention

## Tools used

- Databricks
- SQL
- Power BI
- DAX
- Power Query
- Git and GitHub

## Analytical workflow

1. Imported retail sales and load-shedding data
2. Cleaned and validated the datasets
3. Joined sales dates to load-shedding information
4. Engineered outage, day-type and time-period variables
5. Created a dashboard-ready SQL view
6. Developed DAX measures and interactive Power BI visuals
7. Evaluated trends, operational impact and profit drivers

## Dashboard preview

### Executive summary

<img width="1280" height="1024" alt="Screenshot (59)" src="https://github.com/user-attachments/assets/e54cc021-a6d3-4daf-97c6-b5f2862b46f7" />

### Sales trends

<img width="1280" height="1024" alt="Screenshot (60)" src="https://github.com/user-attachments/assets/f08ea28e-2e6b-46df-93e2-411843e71817" />

### Load-shedding impact

<img width="1280" height="1024" alt="Screenshot (61)" src="https://github.com/user-attachments/assets/bdaeb1ff-5fb4-41e6-b802-58769856359e" />

### Regional and category performance

<img width="1280" height="1024" alt="Screenshot (62)" src="https://github.com/user-attachments/assets/c7917d49-bedf-4227-b966-94c2ceea1573" />

## Key findings

- The business generated approximately R1.8 million in sales.
- Total reported profit was approximately R453.9 thousand.
- Sales remained relatively stable across the reporting period.
- Average sales appeared similar between outage and normal days.
- Diesel expenditure created an additional operating cost.
- Regional and product-category mix were important profit drivers.

## Recommendations

- Monitor diesel expenditure separately from ordinary operating costs.
- Prioritize high-profit region-category combinations.
- Investigate weaker category performance by region.
- Continue monitoring outage duration, not only whether an outage occurred.
- Validate the diesel-cost calculation before using it for decisions.

## Repository contents

- `sql/` – SQL cleaning, transformation and analysis scripts
- `notebooks/` – Exported Databricks analysis
- `dashboard/` – Power BI report and PDF export
- `images/` – Dashboard previews
- `docs/` – Measures, methodology and data definitions

## Author

Lulu Qupe  
Data & Business Analyst  
[LinkedIn profile](www.linkedin.com/in/lulu-qupe-b497823b2)
