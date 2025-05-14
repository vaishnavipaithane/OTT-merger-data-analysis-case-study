# OTT Merger Data Analysis - LioCinema x Jotstar

This data analysis and visualization project is based on a mock business case by [Codebasics](https://codebasics.io/challenge/codebasics-resume-project-challenge). The goal was to provide strategic insights to support the merger of two OTT platforms, **LioCinema** and **Jotstar**, using real-world analytical techniques.

The project involves SQL-based data exploration and Power BI dashboard creation to analyze content libraries, user behaviour, subscription trends, watch time, and revenue impact.

## Problem Statement

Lio, a leading telecom provider in India, is planning a strategic merger with Jotstar, one of the country’s most prominent streaming platforms. The goal is to combine LioCinema’s subscriber base with Jotstar’s content library to become the dominant OTT player in India.

The management team at Lio wants to analyze platform performance, content consumption patterns, subscriber growth, upgrade/downgrade trends, and inactivity behaviour from **Jan–Nov 2024**.

As the assigned analyst, my task was to uncover business insights and make data-driven recommendations to help position **Lio-Jotstar** as the leading OTT platform post-merger.

## Data Collection & Preparation

All data was provided by [Codebasics](https://codebasics.io/challenge/codebasics-resume-project-challenge) as part of a case study project. Two SQL files, `LioCinema_db.sql` and `Jotstar_db.sql`, were used to create relational databases in MySQL.

### Databases:

- **LioCinema_db**: Contains tables for `subscribers`, `contents`, and `content_consumption`
- **Jotstar_db**: Contains a similar structure with `subscribers`, `contents`, and `content_consumption`

### Key Data Preparation Steps:

- Imported `.sql` files into **MySQL Workbench**

- Created SQL scripts for each business objective instead of combining all data upfront. This approach allowed focused analysis for different questions.
  
- SQL scripts created:
  - `combined_content.sql`: For content type, genre, and language comparisons
  - `Upgrade_trends.sql` & `Downgrade_trends.sql`: To analyze plan transitions
  - `monthly_new_subscribers.sql`: To analyze growth trends from Jan–Nov 2024
  - `subscribers with content consumption.sql`: Joined `subscribers` with `content_consumption` to analyze user activity & demographics, watch time & inactivity correlation, and paid users distribution 

- Cleaned and exported specific query outputs as **CSV files** for Power BI visualization

- In **Power BI**, performed transformations using Power Query:
  - Converted watch time from minutes to hours
  - Derived new columns (e.g. `user_status`, `revenue difference`, `monthly growth %`)



