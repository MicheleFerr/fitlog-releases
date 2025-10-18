#!/usr/bin/env python3
"""
Test Azure Translator API connection
Quick test before running full translation
"""

import requests
import uuid

# Your Azure config
AZURE_KEY = "YOUR_KEY_HERE"  # Replace with your KEY 1
AZURE_ENDPOINT = "https://api.cognitive.microsofttranslator.com"
AZURE_LOCATION = "global"  # Or your region

def test_translation():
    print("🧪 Testing Azure Translator API...")
    print("=" * 50)

    # Check key
    if AZURE_KEY == "YOUR_KEY_HERE":
        print("\n❌ Please configure AZURE_KEY first!")
        print("   Edit this file and add your KEY 1 from Azure Portal")
        return False

    # Test translation
    path = '/translate'
    url = AZURE_ENDPOINT + path

    params = {
        'api-version': '3.0',
        'from': 'en',
        'to': 'it'
    }

    headers = {
        'Ocp-Apim-Subscription-Key': AZURE_KEY,
        'Ocp-Apim-Subscription-Region': AZURE_LOCATION,
        'Content-type': 'application/json',
        'X-ClientTraceId': str(uuid.uuid4())
    }

    body = [
        {'text': 'Hello, World!'},
        {'text': 'barbell row'},
        {'text': 'Pull your chest towards the bar'}
    ]

    try:
        print("\n🔌 Connecting to Azure...")
        response = requests.post(url, params=params, headers=headers, json=body, timeout=10)
        response.raise_for_status()

        results = response.json()

        print("✅ Connection successful!")
        print("\n📝 Test translations:")
        for original, result in zip(body, results):
            translation = result['translations'][0]['text']
            print(f"   EN: {original['text']}")
            print(f"   IT: {translation}")
            print()

        print("✅ Azure Translator is working correctly!")
        print("\n🚀 Ready to translate all 1,500 exercises")
        print("   Run: python3 scripts/translate_with_azure.py")
        return True

    except requests.exceptions.HTTPError as e:
        print(f"\n❌ HTTP Error: {e}")
        print(f"   Response: {e.response.text if e.response else 'No response'}")
        print("\n💡 Check:")
        print("   - AZURE_KEY is correct (KEY 1 from Azure Portal)")
        print("   - AZURE_LOCATION matches your resource region")
        return False

    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\n💡 Check your internet connection and Azure credentials")
        return False


if __name__ == "__main__":
    test_translation()
