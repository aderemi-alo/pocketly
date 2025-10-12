# Quick Start Guide - Pocketly Backend API

## 🚀 Start the Server

```bash
cd backend/pocketly_api
dart_frog dev
```

Server will run on: **http://localhost:8080**

---

## 🧪 Quick Test Flow

### 1. Register a User
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "Password123",
    "deviceId": "test-device-123"
  }'
```

**Save the `accessToken` from the response!**

---

### 2. Get Categories (Using Your Token)
```bash
# Replace YOUR_TOKEN with the actual token from step 1
export TOKEN="YOUR_TOKEN"

curl -X GET http://localhost:8080/categories \
  -H "Authorization: Bearer $TOKEN"
```

**Expected:** List of 7 predefined categories (food, transportation, entertainment, etc.)

---

### 3. Create a Custom Category
```bash
curl -X POST http://localhost:8080/categories \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Gym",
    "icon": "dumbbell",
    "color": "#FF5722"
  }'
```

---

### 4. Create Your First Expense
```bash
curl -X POST http://localhost:8080/expenses \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Lunch at Cafe",
    "amount": 25.50,
    "date": "2024-10-12T12:00:00Z",
    "categoryId": "food",
    "description": "Pizza and coffee"
  }'
```

**Save the expense `id` from the response!**

---

### 5. Get All Expenses (with Category Details)
```bash
curl -X GET "http://localhost:8080/expenses?includeCategory=true" \
  -H "Authorization: Bearer $TOKEN"
```

---

### 6. Get Expense Statistics
```bash
curl -X GET http://localhost:8080/expenses/stats \
  -H "Authorization: Bearer $TOKEN"
```

**Expected:** Total spending, count, and category breakdown

---

### 7. Update an Expense
```bash
# Replace EXPENSE_ID with the ID from step 4
export EXPENSE_ID="your-expense-id"

curl -X PUT http://localhost:8080/expenses/$EXPENSE_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 30.00,
    "description": "Updated: Pizza, coffee, and dessert"
  }'
```

---

### 8. Filter Expenses by Date Range
```bash
curl -X GET "http://localhost:8080/expenses?startDate=2024-10-01T00:00:00Z&endDate=2024-10-31T23:59:59Z&includeCategory=true" \
  -H "Authorization: Bearer $TOKEN"
```

---

### 9. Get Stats for Date Range
```bash
curl -X GET "http://localhost:8080/expenses/stats?startDate=2024-10-01T00:00:00Z&endDate=2024-10-31T23:59:59Z" \
  -H "Authorization: Bearer $TOKEN"
```

---

### 10. Delete an Expense
```bash
curl -X DELETE http://localhost:8080/expenses/$EXPENSE_ID \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📚 Full Documentation

See `API_DOCUMENTATION.md` for complete API reference with all endpoints, parameters, and response formats.

---

## ✅ What's Implemented

### ✨ Features
- ✅ User authentication (register, login, logout, refresh token)
- ✅ Category management (CRUD operations)
- ✅ Expense management (CRUD operations)
- ✅ Expense filtering (by date, category)
- ✅ Pagination support
- ✅ Analytics & statistics
- ✅ JWT authentication
- ✅ User-scoped data access

### 🔒 Security
- ✅ Password hashing
- ✅ JWT access & refresh tokens
- ✅ Protected routes
- ✅ User ownership validation
- ✅ CORS headers

### 📊 API Endpoints
- ✅ 6 Auth endpoints
- ✅ 5 Category endpoints
- ✅ 6 Expense endpoints
- **Total: 17 fully functional endpoints**

---

## 🎯 Ready for Frontend Integration!

The backend is complete and ready to be integrated with your Flutter frontend. See `BACKEND_IMPLEMENTATION_SUMMARY.md` for details on the implementation.

