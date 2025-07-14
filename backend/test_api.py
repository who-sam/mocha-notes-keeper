#!/usr/bin/env python3
"""
Simple test script to verify the Notes API is working
Run this after starting the server to test all endpoints
"""

import requests
import json
import sys

BASE_URL = "http://localhost:8000"

def test_health():
    """Test the health check endpoint"""
    print("🔍 Testing health check...")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to server. Is it running?")
        return False

def test_notes_crud():
    """Test the complete CRUD flow for notes"""
    print("\n🔍 Testing Notes CRUD operations...")
    
    # 1. Get all notes (should be empty initially)
    print("1️⃣  Testing GET /api/notes...")
    response = requests.get(f"{BASE_URL}/api/notes")
    if response.status_code == 200:
        data = response.json()
        if data["success"]:
            print(f"✅ GET notes successful - found {len(data['data'] or [])} notes")
        else:
            print(f"❌ GET notes failed: {data.get('error')}")
            return False
    else:
        print(f"❌ GET notes failed: {response.status_code}")
        return False
    
    # 2. Create a new note
    print("2️⃣  Testing POST /api/notes...")
    new_note = {
        "title": "Test Note",
        "content": "This is a test note created by the API test script",
        "color": "#ff6b6b"
    }
    response = requests.post(
        f"{BASE_URL}/api/notes",
        json=new_note,
        headers={"Content-Type": "application/json"}
    )
    
    if response.status_code == 200:
        data = response.json()
        if data["success"] and data["data"]:
            note_id = data["data"]["id"]
            print(f"✅ POST note successful - created note with ID: {note_id}")
        else:
            print(f"❌ POST note failed: {data.get('error')}")
            return False
    else:
        print(f"❌ POST note failed: {response.status_code}")
        return False
    
    # 3. Update the note
    print("3️⃣  Testing PUT /api/notes/{id}...")
    update_data = {
        "title": "Updated Test Note",
        "content": "This note has been updated by the test script"
    }
    response = requests.put(
        f"{BASE_URL}/api/notes/{note_id}",
        json=update_data,
        headers={"Content-Type": "application/json"}
    )
    
    if response.status_code == 200:
        data = response.json()
        if data["success"]:
            print("✅ PUT note successful")
        else:
            print(f"❌ PUT note failed: {data.get('error')}")
            return False
    else:
        print(f"❌ PUT note failed: {response.status_code}")
        return False
    
    # 4. Get the specific note
    print("4️⃣  Testing GET /api/notes/{id}...")
    response = requests.get(f"{BASE_URL}/api/notes/{note_id}")
    if response.status_code == 200:
        data = response.json()
        if data["success"] and data["data"]["title"] == "Updated Test Note":
            print("✅ GET specific note successful")
        else:
            print(f"❌ GET specific note failed: {data.get('error')}")
            return False
    else:
        print(f"❌ GET specific note failed: {response.status_code}")
        return False
    
    # 5. Delete the note
    print("5️⃣  Testing DELETE /api/notes/{id}...")
    response = requests.delete(f"{BASE_URL}/api/notes/{note_id}")
    if response.status_code == 200:
        data = response.json()
        if data["success"]:
            print("✅ DELETE note successful")
        else:
            print(f"❌ DELETE note failed: {data.get('error')}")
            return False
    else:
        print(f"❌ DELETE note failed: {response.status_code}")
        return False
    
    return True

def main():
    print("🧪 Notes API Test Suite")
    print("=" * 50)
    
    # Test health check first
    if not test_health():
        print("\n❌ Health check failed. Make sure the server is running:")
        print("   cd backend && python run.py")
        sys.exit(1)
    
    # Test CRUD operations
    if test_notes_crud():
        print("\n🎉 All tests passed! Your API is working correctly.")
        print(f"🌐 Visit {BASE_URL}/docs to explore the API documentation")
    else:
        print("\n❌ Some tests failed. Check the server logs for details.")
        sys.exit(1)

if __name__ == "__main__":
    main()