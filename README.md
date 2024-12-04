# BudgetBuddy

[![Flutter Windows CI](https://github.com/blucas6/BudgetBuddy/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/blucas6/BudgetBuddy/actions/workflows/main.yml)

## About
BudgetBuddy is a free, simple, easy-to-use personal finance software application that lets you view all your expenses in one unified view.


## Test Plan
### Adding and Removing an Account
1. Click the "Add Account" button
2. Verify that the native file picker window pops up
3. Select a valid file (.csv, .CSV)
4. Verify that all transaction data lines from the *.csv file are presented in the main transaction data table widget
5. Verify that the pie chart shows data
6. Verify that the bar chart shows data
7. Verify that the account name corresponding to the *.csv file is added under the Account section of the GUI
8. Click the trash icon next to the account name
9. Verify that the account name is removed
10. Verify that the transaction widget is empty
11. Verify that the pie chart shows no data
12. Verify that the bar chart shows no data

### Incorrect Data
1. Click the "Add Account" button
2. Select a file that is not a *.csv or a *.CSV
3. Verify that a dialogue pops up claiming that it is not a valid file
4. Verify that no data was populated in the GUI
5. Verify that no data was added to the database
6. Click the "Add Account" button
7. Select a corrupted *.csv
8. Verify that a dialogue pops up claiming that it is not a valid file
9. Verify that no data was populated in the GUI
10. Verify that no data was added to the database

### Tagging Transactions
1. Click on the "Add Account" button
2. Load an appropriate *.csv
3. Wait for the GUI to populate widgets with data
4. Click on a transaction in the transaction data table widget
5. Verify that a dialogue box pops up with options to add or remove tags
6. Choose one of the tags from the dropdown menu
7. Verify that the selected tag was added to the corresponding transaction
8. Click the same transaction again
9. Click the trash can icon next to the dropdown
10. Verify that the tag has now been removed from its respective transaction

### Filtering Transactions
1. Click on the "Add Account" button
2. Load a *.csv file
3. Wait for the transactions to load
4. Click on the first dropdown menu above the transaction table widget
5. Verify that the years populated in the dropdown reflect all years present in the *.csv file
6. Select a year, repeat steps 7,8,9,10 once for each year present, then skip to step 14
7. Click on the second dropdown menu above the transaction table widget
9. Verify the months populated are present in the *.csv
10. Select a month, repeat step 11 for each month available
11. Verify that the transaction data table is only populated with transactions from the above filtering dates
12. Verify that the pie chart slices reflect the data available in the transaction data table
13. Verify that the bar in the bar chart corresponding to the selected month is highlighted in yellow
14. Verify that the *.csv does not contain any dates not reflected in the filtering dropdowns

