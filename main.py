import os
import pycountry
import pandas as pd



def read_csv_files_and_merge(folder):     # reading files from the path
    cw = os.getcwd()
    fullpath = os.path.join(cw, folder)    
    if os.path.exists(fullpath):
        invoice = pd.read_csv(os.path.join(fullpath, 'Invoiced_item.csv'),  dtype = {'INVOICE_DATE':str})
        product_invoice = pd.read_csv(os.path.join(fullpath, 'Product_invoice.csv'))
        fulldata = pd.merge(invoice, product_invoice, how='left', on='INVOICE_NO') 
    else:
        print(f'{fullpath} does not exists')
    return fulldata


def get_country_code(country_name):       # coutnries are messy and not ISO alpha standard, so will map it to 2 letters (Sweden - SE)
    try:
        return pycountry.countries.lookup(country_name).alpha_2
    except LookupError:
        return None

def map_status(status):     # categorizing the statuses under one unique selection /we can also use mapping for each individual like {'canceled': 'cancelled'}
    return (
        'Cancelled' if status in ['cancelled', 'cancelled during production', 'canceled'] else
        'Shipped' if status in ['shipped', 'dispatched - shipped', 'ordershipped'] else
        'In Production' if status in ['in_production', 'in production', 'processing', 'printed'] else
        'On Hold' if status in ['on_hold', 'hold', 'on-hold'] else
        'Completed' if status in ['completed', 'fullfilled', 'packaged', 'picked'] else
        'New' if status in ['new', 'order'] else
        'Other'
    )  

def transform_data(fulldata): # mappings and geenric conversions
    
    fulldata['INVOICE_AMOUNT'] = fulldata['INVOICE_AMOUNT'].fillna(0).astype(float) # other digits are similar to float, first na zero imputation and converting to float
    # fulldata['HANDLING_COST'] = fulldata['HANDLING_COST'].fillna(0.0).astype(float)
    fulldata['TAX_RATE'] = fulldata['TAX_RATE'].fillna(0).astype(float) #tax rate is filled with zero to avoid na 
    fulldata['ORDER_CREATED_DATE'] = fulldata['ORDER_CREATED_DATE'].fillna('00:00.0') #it is probable minues and seconds format, filled to accroding format
    fulldata['SHIP_DATE'] = fulldata['SHIP_DATE'].fillna('00:00.0').astype(str) #converted to string
    fulldata['INVOICE_NO'] = fulldata['INVOICE_NO'].str.strip("'") #avoided "'" from invoice_no
    fulldata['TOTAL_PRODUCT_COSTS_WITH_TAX'] = fulldata['TOTAL_PRODUCT_COSTS_WITH_TAX'].fillna(0).astype(float) # na was filled with zero and converted to float
    fulldata['INVOICE_DATE'] = pd.to_datetime(fulldata['INVOICE_DATE'])
    fulldata['Date Index'] = fulldata['INVOICE_DATE'].dt.year * 100 + fulldata['INVOICE_DATE'].dt.month
    fulldata['refund_flag'] = fulldata['INVOICE_AMOUNT'].apply(lambda x: 'refund' if x < 0 else 'no_refund') #  better to flag it 
    
    return fulldata


def deduplicate_data(fulldata):    # deduplicate the data in order to avoid the situation of duplicate population 
    final_data = fulldata[~fulldata['ID'].duplicated()]
    return final_data


def main():
    try:
        read_files = read_csv_files_and_merge('data')
        fulldata = transform_data(read_files)
        fulldata['COUNTRY'] = fulldata['COUNTRY'].apply(get_country_code)  # Mapping country codes
        fulldata['COUNTRY'] = fulldata.apply(
            lambda x: 'US' if x['CURRENCY_y'] == 'USD'
            else ('UK' if x['CURRENCY_y'] == 'GBP' else x['COUNTRY']), axis=1
        )  # Adjusting country codes based on currency

        fulldata['Mapped_Status'] = fulldata['STATUS'].apply(map_status)     # Mapping Status
        final_data = deduplicate_data(fulldata)
        # final_data.to_excel('{}.testdata.xlsx'.format(os.getcwd()))
        # print(final_data)
        final_data.to_pickle('validate_data.pickle')

    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    main()
