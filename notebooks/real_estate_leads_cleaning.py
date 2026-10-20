# %% [markdown]
# ## Importing Libraries & Dataset

# %%
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

%matplotlib inline
plt.style.use('fivethirtyeight')
sns.set_style('whitegrid')

# %%
lead=pd.read_csv("data/Leads1.csv")
lead.head()

# %%
sale=pd.read_csv("data/Sales1.csv")
sale.head()

# %%
property_type=pd.read_csv("data/property_type1.csv")
property_type.head()

# %%
lead_type=pd.read_csv("data/lead_type1.csv")
lead_type.head()

# %%
property_type

# %% [markdown]
# ## Data Inspection

# %%
# check if there is duplicated rows in lead and sale dataframes
duplicate_lead_row= lead[lead.duplicated()]
duplicate_lead_row

# %%
# found that no duplicated rows in sale df
duplicate_sale_row= sale[sale.duplicated()]
duplicate_sale_row

# %%
# making sure that other df don't have duplicated rows
# found duplicated nans
duplicate_property_type_row= property_type[property_type.duplicated()]
duplicate_property_type_row

# %%
# found duplicated nans
duplicate_lead_type_row= lead_type[lead_type.duplicated()]
duplicate_lead_type_row

# %%
lead.info()

# %%
sale.info()

# %% [markdown]
# ## Data Pre-porcessing

# %%
#first drop all duplicated rows
lead=lead.drop_duplicates()

# %%
property_type=property_type.drop_duplicates()

# %%
# for making sure we run the code of finding duplicate rows again and it should have empty dfs
lead_type=lead_type.drop_duplicates()

# %% [markdown]
# ### cleaning phase

# %%
for column in lead.columns:
    print(f"{column} : {lead[column].unique()}")
    print("====================================")

# %%
#change columns which datatype object  to datetime (needed ones only)
def cast_to_datetime(df, columns):
    for column in columns:
        df[column] = pd.to_datetime(df[column])
    return df

columns_to_cast_lead = ['date_of_last_request', 'created_at','updated_at','date_of_last_contact']  # List of columns to be casted in df1
columns_to_cast_sale= ['date_of_reservation', 'reservation_update_date','date_of_contraction']  # List of columns to be casted in df2

lead = cast_to_datetime(lead, columns_to_cast_lead)
sale = cast_to_datetime(sale, columns_to_cast_sale)


# %%

id_pk_lead = lead[lead.duplicated('id')]

# %%
#then id is pk
lead['id'].isnull().sum()

# %%
#checking for sale table
id_pk_sale = sale[sale.duplicated('id')]
sale['id'].isnull().sum()

# %%
#checking for property_type table
id_pk_property_type = property_type[property_type.duplicated('id')]
property_type['id'].isnull().sum()

# %%
property_type.dropna()

# %%
lead_type.dropna()

# %%
lead['merged'].isnull().sum()

# %%
lead.to_csv('data/leadpy.csv', index=False)

# %%
#change columns which datatype float  to int (needed ones only)
def cast_to_int(df, columns):
    for column in columns:
        df[column] = df[column].astype(int)
    return df

columns_to_cast_lead = ['user_id', 'area_id','compound_id','developer_id']  
columns_to_cast_sale= ['property_type_id', 'area_id','compound_id']  

lead = cast_to_int(lead, columns_to_cast_lead)
sale = cast_to_int(sale, columns_to_cast_sale)


# %%

def cast_to_nullable_int(df, columns):
    for column in columns:
        df[column] = pd.to_numeric(df[column], errors='coerce').astype('Int64')
    return df

# Example usage:
# Assuming lead is your DataFrame and columns_to_cast_lead is a list of column names
columns_to_cast_lead = ['user_id', 'area_id','compound_id','developer_id']
lead = cast_to_nullable_int(lead, columns_to_cast_lead)

# %%
lead.dtype

# %%

#sale.to_csv('data/salepy.csv', index=False)
#property_type.to_csv('data/property_typepy.csv', index=False)
#lead_type.to_csv('data/lead_typepy.csv', index=False)




