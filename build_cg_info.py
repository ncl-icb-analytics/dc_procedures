#File to build the cg_info reference file

import pandas as pd
import ncl.sqlsnippets as snips

#Load recipe sheet from reference file 
#(since we need information from attribute for each time the codegroup is used)
def load_recipesheet (file):
    return pd.read_excel(file, sheet_name='Recipes')

#Get codegroups from a recipe sheet
def get_codegroups (df_rec):
    df_cg = df_rec[['Codegroup', 'Attribute']]

#Collate codegroup lists 

#Assign id values