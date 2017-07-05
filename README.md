Partner Metrics - for Shopify Partners
================

This application was built to provide an easy way to see useful metrics of your apps, themes and affiliate revenue from the Shopify Partner program.. without needing to spend a week in Excel hell.

**Hosted version available** If you are not comfortable using Ruby on Rails, a free hosted version of this app is available at [www.partnermetrics.io](https://partnermetrics.io)

![Recurring Revenue Metrics](https://raw.githubusercontent.com/forsbergplustwo/partner-metrics-for-shopify/master/public/Partner_Metrics_RecurringRevenue.png)

Simply export your Payment History file from your Partner Dashboard and then import it within the application, and you'll be given many important metrics to see the health of your business.

It will automatically analyze and calculate all of the supported metrics. There are overviews for your apps (recurring and onetime), themes and affiliate revenue. You can also choose what date to look at, what timeframe (Monthly, Weekly, Daily) and allow you to filter by application/theme if you have more than one.

The application is intended to be run locally on your own machine, and is built using Rails 4.1.

**Disclaimer** I built this because I needed a better overview of my own business. I've been developing for about a year and used this as a learning opportunity. It was thrown together in about a week and is not intended as a commercial product, so there is a lot that could be improved, cleaned up and DRY'ed up.. pull requests are more than welcome to improve the code!

Supported Metrics
-----------------

- Overview
  - Total Revenue
  - Recurring Revenue
  - OneTime Revenue
  - Affiliate Revenue
  - Refunds
  - Avg. Revenue per User
- Recurring Revenue
  - Total Recurring Revenue
  - Number of Paying Users
  - Avg. Revenue per User
  - % User Churn
  - % Revenue Churn
  - Lifetime Value
- One-Time Revenue
  - Total OneTime Revenue
  - Avg. Revenue per Sale
  - Avg. Revenue per User
  - Number of Sales
  - Number of Repeat Customers
  - % Repeat vs New Customers
- Affiliate Revenue
  - Total Affiliate Revenue
  - Number of Affiliates
  - Avg. Revenue per User

**Note** User Churn, Revenue Churn and Lifetime Value have a 30 day lag. This is because we can only check to see who paid for the app 1 month ago, and then if they paid again now. Those that do not pay again are considered Churned. It's the best possible solution I've found, using only the PaymentHistory data available in the CSV file.

Installation
------------

Clone the app:

```
git clone https://github.com/forsbergplustwo/partner-metrics-for-shopify
```

Then run:

```
bundle install
```

Create a database.yml file with your database connection settings.

```
development:
  adapter:  postgresql
  host:     localhost
  encoding: unicode
  database: PartnerMetrics_development
  pool:     5
  username: Admin
  password:
  template: template0
```

Create the database and run migrations

```
rake db:create
rake db:migrate
```

And start your server

```
foreman start
```

Navigate http://localhost:5000 and start using the app.

**Note** I decided to run this app on port 5000, so that this app can be up and running while still developing and testing other apps on port 3000.

Importing Your Data
-------------------

Importing data is easy. Basically, export your payment data from Shopify Partners Dashobard, then choose that file in the import section of the app.

1. Firstly, login to your [Shopify Partner Dashboard](https://app.shopify.com/services/partners/payments) and on the **Payouts** page click the "Export payouts as CSV" link.
2. You'll receive an email with a zip file attached.
3. Start the Partner Metrics app, and click on the "Import Data" button
4. Drag the Zip file from your email and drop it on the area shown. You can also click and select the file manually if needed.
5. Go get a cup of coffee.. depending on how much data is in the file it could take a couple of minutes to import and calculate all of your metrics.

To update your data at anytime, just repeat the above process. Only new data will be imported, so updating your metrics is a lot faster than the initial import.

Feedback? Issues?
--------------------

If the application doesn't work as expected, please [report an issue](https://github.com/forsbergplustwo/partner-metrics-for-shopify/issues)
and include the diagnostics.

Or better yet, fix it yourself and create a pull request.

To-Do
--------
- DRY up the code to make it more readable and easier to follow.
- Add support for the EventHistory.csv file from apps, so metrics regarding conversion (Trial -> Paying) can be created.
- Add background processing for import/calculation
- Add Tests

Credits
----------

Originally created by [FORSBERG+two](http://www.forsbergplustwo.com) because baremetrics.com does not support importing Shopify Partner payment files ;)

License
----------

GNU GPLv2 "free software"- Please see the LICENSE file for more info.
