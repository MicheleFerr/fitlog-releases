#!/usr/bin/env python3
"""
Script per debuggare le colonne del Google Sheet
"""
import gspread
from google.oauth2.service_account import Credentials
import sys

def setup_google_sheets():
    credentials_path = "/Users/michele/gymbro_flutter_new/scripts/service-account-key.json"
    scopes = [
        'https://www.googleapis.com/auth/spreadsheets',
        'https://www.googleapis.com/auth/drive'
    ]
    
    credentials = Credentials.from_service_account_file(credentials_path, scopes=scopes)
    return gspread.authorize(credentials)

def debug_sheet_columns(sheet_url):
    client = setup_google_sheets()
    sheet_id = sheet_url.split('/spreadsheets/d/')[1].split('/')[0] if '/spreadsheets/d/' in sheet_url else sheet_url
    
    spreadsheet = client.open_by_key(sheet_id)
    worksheet = spreadsheet.sheet1
    
    print(f"📋 Foglio: {worksheet.title}")
    print(f"📊 Dimensioni: {worksheet.row_count} righe x {worksheet.col_count} colonne")
    
    # Prime 5 righe per vedere la struttura
    print("\n🔍 Prime 5 righe del foglio:")
    data = worksheet.get_all_values()[:5]
    
    for i, row in enumerate(data):
        print(f"Riga {i+1}: {row[:10]}...")  # Prime 10 colonne
    
    # Headers (prima riga)
    print(f"\n📝 Headers (prima riga): {len(data[0])} colonne")
    headers = data[0]
    for i, header in enumerate(headers):
        print(f"  {i+1}. '{header}'")
    
    # Prova a prendere un record completo
    if len(data) > 1:
        print(f"\n📄 Esempio di record (riga 2):")
        record = dict(zip(headers, data[1]))
        for key, value in record.items():
            if value:  # Solo valori non vuoti
                print(f"  {key}: '{value}'")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        debug_sheet_columns(sys.argv[1])
    else:
        sheet_url = input("URL del Google Sheet: ")
        debug_sheet_columns(sheet_url)