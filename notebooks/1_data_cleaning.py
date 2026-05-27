import os
import pandas as pd
import numpy as np

def cleaned_amazon_data(file_path, output_path):
    df = pd.read_csv(file_path, low_memory=False)
    print(df.head())
    #Stripping whitespaces to make all the column names standardized.
    df.columns = df.columns.str.strip().str.replace('-', '_').str.replace(' ', '_').str.lower()
    #Dropping index as it is redundant
    if 'index' in df.columns:
        df.drop(columns=['index'], inplace=True)

    df['order_id'] = df['order_id'].astype(str).str.strip()

    #Date time formatting
    df['date'] = pd.to_datetime(df['date'], errors='coerce')
    df.dropna(subset=['date'], inplace=True)

    #df['Qty'] = df['Qty'].fillna(0).astype(int) - As there are no blanks

    df['amount'] = pd.to_numeric(df['amount'], errors='coerce').fillna(0)

    df['currency'] = df['currency'].fillna('INR').str.strip().str.upper()

    df['b2b'] = df['b2b'].astype(bool)

    df['courier_status'] = df['courier_status'].fillna('Unknown').str.strip()
    df['fulfilled_by'] = df['fulfilled_by'].fillna('Amazon').str.strip()
    for col in ["ship_city", "ship_state", "ship_country"]:
        df[col] = df[col].fillna('Unknown').astype(str).str.strip().str.title()

    df['ship_postal_code'] = df['ship_postal_code'].fillna(0).astype(str).str.split('.').str[0].str.zfill(6)

    print(def_metrics_summary(df))

    df.to_csv(output_path, index=False)
    print(f"Cleaned data saved to: {output_path}")

def def_metrics_summary(df):
    return f"""
    --- DATA CLEANING SUMMARY REPORT ---
    Total Row Count:     {df.shape[0]}
    Total Columns:       {df.shape[1]}
    Date Boundaries:     {df['date'].min().strftime('%Y-%m-%d')} to {df['date'].max().strftime('%Y-%m-%d')}
    Total Gross Amount:  {df['amount'].sum():,.2f} {df['currency'].iloc[0]}
    B2B Transactions:    {df['b2b'].sum()} rows
    ------------------------------------
    """
    
if __name__ == "__main__":
    # Update these paths based on where your raw csv is stored
    RAW_DATA_PATH = "C:/Users/Artophilic/Analysis Projects/amazon-sales-analytics/Data/Amazon Sale Report.csv"
    CLEANED_DATA_OUTPUT = "C:/Users/Artophilic/Analysis Projects/amazon-sales-analytics/Data/cleaned_amazon_sales.csv"
    
    if os.path.exists(RAW_DATA_PATH):
        cleaned_amazon_data(RAW_DATA_PATH, CLEANED_DATA_OUTPUT)
    else:
        print(f"Error: Could not find raw file at {RAW_DATA_PATH}. Place your file there or update paths.")

    
    
