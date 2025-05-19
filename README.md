# OTT Merger Data Analysis - LioCinema x Jotstar

This data analysis and visualization project is based on a mock business case by [Codebasics](https://codebasics.io/challenge/codebasics-resume-project-challenge). The goal was to provide strategic insights to support the merger of two OTT platforms, **LioCinema** and **Jotstar**, using real-world analytical techniques.

The project involves SQL-based data exploration and Power BI dashboard creation to analyze content libraries, user behaviour, subscription trends, watch time, and revenue impact.

## Problem Statement

Lio, a leading telecom provider in India, is planning a strategic merger with Jotstar, one of the country’s most prominent streaming platforms. The goal is to combine LioCinema’s subscriber base with Jotstar’s content library to become the dominant OTT player in India.

The management team at Lio wants to analyze platform performance, content consumption patterns, subscriber growth, upgrade/downgrade trends, and inactivity behaviour from **Jan–Nov 2024**.

As the assigned analyst, my task was to uncover business insights and make data-driven recommendations to help position **Lio-Jotstar** as the leading OTT platform post-merger.

You can view the official documents below:
- [Problem Statement](problem_statement.pdf)
- [Business Questions](primary_and_secondary_questions.pdf)

## Data Collection, Preparation & Transformation

All data was provided by [Codebasics](https://codebasics.io/challenge/codebasics-resume-project-challenge) as part of a case study project. Two SQL files, `LioCinema_db.sql` and `Jotstar_db.sql`, were used to create relational databases in MySQL.

### Databases:

- **LioCinema_db**: Contains tables for `subscribers`, `contents`, and `content_consumption`
- **Jotstar_db**: Contains a similar structure with `subscribers`, `contents`, and `content_consumption`

### Key Data Preparation Steps:

- Imported `.sql` files into **MySQL Workbench**

- Created SQL scripts for each business objective instead of combining all data upfront. This approach allowed focused analysis for different questions.
  
#### SQL scripts created
  - [Combined_content.sql](SQL%20scripts/Combined_content.sql): For content type, genre, and language comparisons
  - [Upgrade_trends.sql](SQL%20scripts/Upgrade_trends.sql) & [Downgrade_trends.sql](SQL%20scripts/Downgrade_trends.sql): To analyze plan transitions
  - [monthly_new_subscribers.sql](SQL%20scripts/monthly%20_new_subscribers.sql): To analyze growth trends from Jan–Nov 2024
  - [subscribers with content consumption.sql](SQL%20scripts/subscribers%20with%20content%20consumption.sql): Joined `subscribers` with `content_consumption` to analyze user activity & demographics, watch time & inactivity correlation, and paid users distribution. Created a new column `user_status` (Active vs. Inactive)

- Cleaned and exported specific query outputs as **CSV files** for Power BI visualization

#### Power Query Transformations
  - Converted watch time from minutes to hours (`total_watch_time_hrs`)
  - Appended and joined `Upgrade_trends` and `Downgrade_trends` tables to make `Upgrade and downgrade trends` table
  - Created `PlanPricing` table
  - Added `platform` column to each `LioCinema_db subscribers` and `Jotstar_db subscribers` table, and appended the tables to make the `AllSubscribers` table for revenue analysis. Created seven new columns and two DAX measures:

    a. Time spent on the original plan
       ```
       old plan = DATEDIFF('AllSubscribers'[subscription_date],'AllSubscribers'[plan_change_date], MONTH)
       ```
    b. Time spent on the new plan
       ```
       new plan = DATEDIFF('AllSubscribers'[plan_change_date], COALESCE('AllSubscribers'[last_active_date], TODAY()), MONTH)
       ```
    c. Look up price for the original plan
       ```
       old plan price = LOOKUPVALUE(PlanPricing[price], PlanPricing[subscription_plan], AllSubscribers[subscription_plan], PlanPricing[platform], AllSubscribers[platform])
       ```
    d. Look up price for the new plan
       ```
       new plan price = LOOKUPVALUE(PlanPricing[price], PlanPricing[subscription_plan], AllSubscribers[new_subscription_plan], PlanPricing[platform], AllSubscribers[platform])
       ```
    e. Original plan revenue
       ```
       old plan revenue = 'AllSubscribers'[old plan price] * 'AllSubscribers'[old plan]
       ```
    f. New plan revenue
       ```
       new plan revenue = AllSubscribers[new plan price] * AllSubscribers[new plan]
       ```
    g. Revenue per user
       ```
       revenue per user = AllSubscribers[old plan] * AllSubscribers[old plan price] + AllSubscribers[new plan] * AllSubscribers[new plan price]
       ```
    Total Revenue (Measure)
       ```
       Total Subscribers Revenue = SUM('AllSubscribers'[revenue per user])
       ```
    Average revenue per user (Measure)
      ```
      Avg Revenue Per User = DIVIDE(SUM('AllSubscribers'[revenue per user]), DISTINCTCOUNT('AllSubscribers'[user_id]), 0)
      ```
  - Made three DAX measures for the `monthly_new_subscribers` table:
      - Monthly growth rate %
        ```
        monthly growth rate % = 
        VAR currentmonth = MAX('monthly _new_subscribers'[month])
        VAR platform = SELECTEDVALUE('monthly _new_subscribers'[platform])
        VAR currentusers = SUM('monthly _new_subscribers'[new_users])
        VAR previoususers = CALCULATE(SUM('monthly _new_subscribers'[new_users]), 'monthly _new_subscribers'[month] = EDATE(currentmonth, -1), 'monthly _new_subscribers'[platform] = platform)
        RETURN DIVIDE(currentusers - previoususers, previoususers, 0)
        ```
      - Average growth rate %
        ```
        average growth rate % = AVERAGEX(VALUES('monthly _new_subscribers'[month]),'monthly _new_subscribers'[monthly growth rate %])
        ```
      - Cumulative users
        ```
        cumulative users = CALCULATE(SUM('monthly _new_subscribers'[new_users]), FILTER(ALLSELECTED('monthly _new_subscribers'), 'monthly _new_subscribers'[month] <= MAX('monthly _new_subscribers'[month]) && 'monthly _new_subscribers'[platform] = MAX('monthly _new_subscribers'[platform])))
        ```
        
  - Other DAX measures used for the analyses:
    - % Active users
      ```
      % Active Users = 
      VAR TotalUsers = CALCULATE(DISTINCTCOUNT('subscribers with content consumption'[user_id]))
      VAR ActiveUsers = CALCULATE(DISTINCTCOUNT('subscribers with content consumption'[user_id]), 'subscribers with content consumption'[user_status] = "Active")
      RETURN DIVIDE(ActiveUsers, TotalUsers, 0)
      ```
    - % Inactive users
      ```
      % Inactive Users = 
      VAR TotalUsers = CALCULATE(DISTINCTCOUNT('subscribers with content consumption'[user_id]))
      VAR InactiveUsers = CALCULATE(DISTINCTCOUNT('subscribers with content consumption'[user_id]), 'subscribers with content consumption'[user_status] = "Inactive")
      RETURN DIVIDE(InactiveUsers, TotalUsers, 0)
      ```
    - Average watch time (hours) per user
      ```
      average watch time (hrs) per user = DIVIDE(SUM('subscribers with content consumption'[total_watch_time_hrs]), DISTINCTCOUNT('subscribers with content consumption'[user_id]),0)
      ```
    - Upgrade rate %
      ```
      Upgrade rate % = DIVIDE(SUM('Upgrade and downgrade trends'[upgraded_users]),DISTINCTCOUNT('subscribers with content consumption'[user_id]),0)*100
      ```
    - Downgrade rate %
      ```
      Downgrade rate % = DIVIDE(SUM('Upgrade and downgrade trends'[downgraded_users]),DISTINCTCOUNT('subscribers with content consumption'[user_id]),0)*100
      ```
    - Paid users %
      ```
      Paid Users % = 
      VAR TotalUsers = DISTINCTCOUNT('subscribers with content consumption'[user_id])
      VAR PaidUsers = 
      CALCULATE(DISTINCTCOUNT('subscribers with content consumption'[user_id]), 'subscribers with content consumption'[subscription_plan] IN {"VIP", "Premium", "Basic"})
      RETURN DIVIDE(PaidUsers, TotalUsers, 0)
      ```
    - Total paid users
      ```
      Total Paid Users = 
      CALCULATE(DISTINCTCOUNT('subscribers with content consumption'[user_id]), 'subscribers with content consumption'[subscription_plan] IN {"VIP", "Premium", "Basic"})
      ```

## Data Analysis and Visualization

Business questions were grouped into thematic areas, each addressed on a dedicated Power BI page. Key takeaways are embedded within the dashboards.

#### 1. **Content Library Analysis**

![](Screenshots/Content_analysis.png)

- Total titles: Jotstar **2360** vs. LioCinema **1250**
- Jotstar has a larger content library and a stronger English/regional language mix, while LioCinema leans heavily on Hindi.

#### 2. **User Activity & Demographics**

![](Screenshots/User_activity_&_demographics.png)

- Active users: Jotstar **85%** vs. LioCinema **55%**. Higher activity on Jotstar suggests stronger engagement and retention.
- Majority of Jotstar active users **(43.5%)** are on the VIP plan, while LioCinema users, both active and inactive, mostly remain on the Free plan.

#### 3. **Watch Time Analysis & Inactivity Correlation**

![](Screenshots/watch_time_analysis_&_inactivity_correlation.png)

- Average watch time (hours): Jostar **352** vs. LioCInema **60**
- LioCinema shows a strong inverse link between engagement and retention; less engaged users (18–24) have the highest inactivity (49%).
- Jotstar users maintain high watch time (310–380 hrs) and consistent retention (~14%) across all age groups, indicating pricing or seasonal usage may influence user drop-off.

#### 4. **Upgrade and Downgrade Trends**

![](Screenshots/upgrade_&_downgrade_trends.png)

- Upgrade/Downgrade Rate: Jotstar – 1.9% / 1.2%, LioCinema – 1.8% / 9.1%
- Jotstar’s top upgrade: VIP → Premium
- LioCinema’s top upgrade: Free → Basic, but faces major downgrades from Premium/Basic → Free

#### 5. Paid Users Distribution

![](Screenshots/paid_users_distribution.png)

- Paid user share: Jotstar - 72.9%, LioCinema - 42.8%
- Jotstar splits across VIP (58.8%) and Premium (41.1%)
- LioCinema paid users: mostly on Basic (68%), followed by Premium (32%)

#### 6. Revenue Analysis

![](Screenshots/revenue_analysis.png)

- ARPU: Jotstar - **₹388** | LioCinema - lower, due to high downgrade volume
- Jotstar’s strong upgrade behaviour drives revenue, while LioCinema struggles with premium retention.

#### 7. Monthly User Growth Rate

![](Screenshots/monthly_users_growth_rate.png)

- Average Growth Rate (Jan–Nov 2024): LioCinema - **16.95%** | Jotstar - **0.73%**.
- LioCinema’s affordable plans and regional focus likely fueled faster user acquisition.

## Strategic Recommendations

Based on the detailed analysis of user behaviour, platform performance, content consumption, and revenue trends, the following strategic recommendations are proposed for the newly merged OTT platform **Lio-Jotstar**.

### 1. Increase Engagement Among Inactive Users
- **Personalized re-engagement:** Utilize data-driven insights to send tailored push notifications, emails, and in-app messages based on each user’s preferences and viewing history.
- **Incentives-based campaigns:** Reach out to inactive users with special offers, discounts, or free trials to encourage their return. 
- **UX improvements:** Enhance the app’s user interface for easy navigation and a simple search function.
- **Interactive and social features:** Introduce engaging content such as quizzes, polls, live chats, and Q&A sessions to boost viewer participation. Promote user-generated content (UGC) to foster a sense of community and belonging.

### 2. Launch Targeted Brand Campaigns
- **Leverage India’s Love for Cricket and Live Sports:** Roll out high-impact campaigns during IPL, ICC tournaments, and other cricket matches. Position the merged platform as the go-to destination for live sports streaming.
- **AI-driven personalized recommendations:** Create campaigns that highlight the platform’s capability to provide hyper-personalized content recommendations, making it easy for users to discover shows and movies they love.
- **Shoppable ads:** Introduce interactive ad formats that allow users to engage with shopping brands directly from the video content.
- **Festival & Seasonal Campaigns:** Align brand campaigns with major Indian festivals (Diwali, Holi, etc.) and seasonal events (summer vacations) to maintain cultural relevance.
- **OTT Bundling and Partnerships:** Offer bundled subscriptions with major telecom partners to provide budget-friendly options to viewers, especially those in tier 2 and tier 3 cities.
- **Influencer and celebrity campaigns:**  Collaborate with pan-India influencers, regional creators, and celebrities to drive engagement across various language segments.

### 3. Proposed pricing strategy
- **Tiered Subscription Model with clear differentiation:** Introduce three straightforward subscription plans that cater to various income levels:

| Plan | Target Audience | Key Features |
| ---- | --------------- | ------------ |
| Free (Ad-supported) |	First-time users, rural/Tier 3 viewers | Limited access, regional content, ads |
| Basic (Low-cost) | Mobile-first, Tier 2 users |	1 screen, regional + national shows, SD/HD |
| Premium |	Urban, multi-device households | 4 screens, sports, 4K content, exclusive originals |

Price points should remain competitive with existing OTT services, ranging from ₹99 to ₹149 for Basic and VIP plans, and starting at ₹299 for Premium.
- **Flexible Trials and Discounts:** Offer trial periods of 7 to 14 days, along with upgrade discounts for users who have been inactive or wish to downgrade.
- **Mobile-Only Plan Variant:** Introduce a Mobile-only plan (~₹49-₹59/month) to target younger audiences with budget constraints. This option is particularly effective in Tier 2 and Tier 3 cities, where smartphone viewership is prevalent.
- **Regional & Localized Pricing:** Adjust pricing based regional content and local purchasing power, taking into account user engagement and churn history.
- **Bundling & Family Plans:** Offer bundled subscriptions (multiple OTTs, telecom partnerships) and family plans for multi-user households. Bundling adds value and encourages long-term subscriptions.
- **Yearly Plans with Loyalty Rewards:** Promote annual subscriptions by offering pricing benefits and loyalty points redeemable for merchandise, early access to content, or premium events to boost retention and reduce churn.

### 4. Partnership with telecom companies
- **Bundle with Prepaid Recharge Packs:** Collaborate with major telecom companies to offer OTT subscriptions with recharge packs (e.g., ₹299/month with 1.5gb/day + OTT access). This will reduce entry barriers and increase convenience for users.
- **Recharge Vouchers:** Offer recharge vouchers during key event launches like IPL or movie premiers. 
- **Include Premium OTT in Broadband Plans:** Add OTT access to high-tier broadband plans, particularly targeting households in metro areas.
- **Family Access Plans:** Introduce family plans to encourage shared OTT access for multi-user households.
- **New SIM Activation Offers:** Offer three months of free OTT access for new SIM purchases.
- **Localized Regional Targeting:** Use telecoms’ regional insights to push language-specific content tailored for Tier 2/3 cities and older users.

### 5. Implement AI and machine learning
- **Hyper-Personalized Recommendations:** Generate content suggestions based on user behaviour, viewing history, preferences, and contextual cues like time of day or mood.
- **Dynamic Homepage Curation:** Customise homepage layout to prioritize genres, languages, or stars they watch. Highlight new episodes or soon-to-expire titles.
- **Voice & Smart Search in Regional Languages:** Implement voice recognition in regional languages and predictive search tailored to user viewing habits.
- **Ad Personalization:** Deliver targeted ads based on viewer behaviour and context (e.g., time of day, mood-based genres).
- **Streaming Optimization:** Adjust video quality based on real-time network strength using predictive buffering, which is crucial for Tier 2/3 mobile users.

### 6. Brand Ambassador Strategy
- Primary face: Shah Rukh Khan or Deepika Padukone for entertainment appeal.
- Sports face: Virat Kohli or Neeraj Chopra for sports audience.
- Include regional stars & creators to localize brand identity.

## Conclusion

This project provides a comprehensive analysis of two leading OTT platforms, **LioCinema** and **Jotstar**, in preparation for a potential merger. By combining SQL-driven data exploration with interactive Power BI dashboards, the goal is to help the merged platform optimize user retention, boost revenue, and strengthen its long-term position as India’s leading OTT destination.

## Thank you















    
