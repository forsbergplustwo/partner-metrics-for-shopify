=== 1.2.1 (Oct 01, 2017)
* Bug fix: Make sure to import the "shop" column as well, kinda important :(


=== 1.2.0 (Oct 01, 2017)
* New Feature: Show revenue by country of shop.
* Performance: Adds database indexes on lookup columns
* Bug fix: Shopify changed CSV file again, breaking things. This fixes + improves CSV importer to be specific about which columns to import, and ignore the rest

**Note** Make sure to `run rake db:migrate` to add the new shop_country column to the database and then reset metrics and re-import data to get shop country data correct.


=== 1.1.0 (April 14, 2017)

* New Feature: Performce improvements for importing of data. Much faster initial import and updates.
* New Feature: Include new charge types ApplicationCredit and ApplicationDowngradeAdjustment in refund metrics
* Bug fix: Fixes unclosed p tag in import form

=== 1.0.1 (April 14, 2017)

* Bug fix: Datepicker was firing change event and reloading page too early, and was not positioned correctly.

=== 1.0.0 (May 2, 2015)

* Initial Public Release
