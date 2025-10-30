# Pocketly API Documentation

## Overview
Complete REST API for the Pocketly expense tracking application with JWT authentication.

## Base URL
```
http://localhost:8080
```

## Authentication
Most endpoints require JWT authentication. Include the token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

---

## Endpoints

### 🔐 Authentication Endpoints

#### POST /auth/register
Register a new user account.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123",
  "deviceId": "device-uuid"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2024-10-12T12:00:00Z",
      "updatedAt": "2024-10-12T12:00:00Z"
    },
    "accessToken": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  }
}
```

#### POST /auth/login
Login with existing credentials.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "SecurePass123",
  "deviceId": "device-uuid"
}
```

**Response (200):** Same as register

#### POST /auth/refresh
Refresh an expired access token.

**Request:**
```json
{
  "refreshToken": "jwt_refresh_token",
  "deviceId": "device-uuid",
  "rotateToken": false
}
```

#### POST /auth/logout
Logout from device(s).

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "deviceId": "device-uuid"  // Optional: omit to logout from all devices
}
```

#### GET /auth/user
Get current user profile details.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "isEmailVerified": true,
    "createdAt": "2024-10-12T12:00:00Z",
    "updatedAt": "2024-10-12T12:00:00Z"
  }
}
```

#### PUT /auth/user
Update user profile (name only).

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "name": "John Smith"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "John Smith",
    "email": "john@example.com",
    "isEmailVerified": true,
    "createdAt": "2024-10-12T12:00:00Z",
    "updatedAt": "2024-10-12T12:00:00Z"
  }
}
```

---

### 📁 Category Endpoints

#### GET /categories
Get all categories (predefined + user's custom categories).

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "food",
      "name": "Food",
      "icon": "utensils",
      "color": "#4CAF50",
      "isPredefined": true,
      "createdAt": "2024-10-12T12:00:00Z",
      "updatedAt": "2024-10-12T12:00:00Z"
    },
    {
      "id": "uuid",
      "name": "Gym",
      "icon": "dumbbell",
      "color": "#FF5722",
      "isPredefined": false,
      "userId": "user-uuid",
      "createdAt": "2024-10-12T12:00:00Z",
      "updatedAt": "2024-10-12T12:00:00Z"
    }
  ]
}
```

#### POST /categories
Create a custom category.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "name": "Gym",
  "icon": "dumbbell",
  "color": "#FF5722"
}
```

**Response (201):** Returns the created category object.

#### GET /categories/:categoryId
Get a specific category by ID.

**Headers:** `Authorization: Bearer <token>`

**Response (200):** Returns single category object.

#### PUT /categories/:categoryId
Update a custom category (predefined categories cannot be updated).

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "name": "Fitness",
  "icon": "activity",
  "color": "#FF0000"
}
```

**Response (200):** Returns updated category object.

#### DELETE /categories/:categoryId
Delete a custom category (predefined categories cannot be deleted).

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Category deleted successfully"
  }
}
```

---

### 💰 Expense Endpoints

#### GET /expenses
Get user's expenses with pagination and filters.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `limit` (optional): Number of results per page (default: 50)
- `offset` (optional): Pagination offset (default: 0)
- `categoryId` (optional): Filter by category ID
- `startDate` (optional): Filter by date range start (ISO 8601)
- `endDate` (optional): Filter by date range end (ISO 8601)
- `includeCategory` (optional): Include full category details (default: false)

**Examples:**
```
GET /expenses?limit=20&offset=0
GET /expenses?categoryId=food
GET /expenses?startDate=2024-10-01T00:00:00Z&endDate=2024-10-31T23:59:59Z
GET /expenses?includeCategory=true
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "expenses": [
      {
        "id": "expense-uuid",
        "name": "Lunch at Restaurant",
        "amount": 25.50,
        "date": "2024-10-12T12:00:00Z",
        "categoryId": "food",
        "category": {
          "id": "food",
          "name": "Food",
          "icon": "utensils",
          "color": "#4CAF50"
        },
        "description": "Pizza and drinks",
        "userId": "user-uuid",
        "createdAt": "2024-10-12T12:00:00Z",
        "updatedAt": "2024-10-12T12:00:00Z"
      }
    ],
    "total": 150,
    "page": 1,
    "limit": 50,
    "offset": 0,
    "hasMore": true
  }
}
```

#### POST /expenses
Create a new expense.

**Headers:** `Authorization: Bearer <token>`

**Request:**
```json
{
  "name": "Lunch at Restaurant",
  "amount": 25.50,
  "date": "2024-10-12T12:00:00Z",
  "categoryId": "food",
  "description": "Pizza and drinks"
}
```

**Response (201):** Returns the created expense with full category details.

#### GET /expenses/:expenseId
Get a specific expense by ID.

**Headers:** `Authorization: Bearer <token>`

**Response (200):** Returns single expense object with full category details.

#### PUT /expenses/:expenseId
Update an existing expense.

**Headers:** `Authorization: Bearer <token>`

**Request (all fields optional):**
```json
{
  "name": "Dinner at Restaurant",
  "amount": 35.00,
  "date": "2024-10-12T18:00:00Z",
  "categoryId": "food",
  "description": "Updated description"
}
```

**Response (200):** Returns updated expense with full category details.

#### DELETE /expenses/:expenseId
Delete an expense.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "message": "Expense deleted successfully"
  }
}
```

#### GET /expenses/stats
Get expense statistics and analytics.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `startDate` (optional): Stats for date range start (ISO 8601)
- `endDate` (optional): Stats for date range end (ISO 8601)

**Examples:**
```
GET /expenses/stats  // All-time stats
GET /expenses/stats?startDate=2024-10-01T00:00:00Z&endDate=2024-10-31T23:59:59Z  // Monthly stats
```

**Response (200) - All Time:**
```json
{
  "success": true,
  "data": {
    "total": 1250.00,
    "count": 42,
    "categoryBreakdown": {
      "food": 450.00,
      "transportation": 200.00,
      "entertainment": 150.00,
      "shopping": 300.00,
      "bills": 100.00,
      "healthcare": 50.00
    },
    "averagePerExpense": 29.76,
    "period": "all"
  }
}
```

**Response (200) - Date Range:**
```json
{
  "success": true,
  "data": {
    "total": 850.00,
    "count": 28,
    "categoryBreakdown": {
      "food": 300.00,
      "transportation": 150.00,
      "entertainment": 100.00,
      "shopping": 200.00,
      "bills": 100.00
    },
    "dailyAverage": 27.42,
    "startDate": "2024-10-01T00:00:00Z",
    "endDate": "2024-10-31T23:59:59Z",
    "period": "custom"
  }
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation error message",
  "errors": null
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Authorization token required",
  "errors": null
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "You do not have permission to access this resource",
  "errors": null
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found",
  "errors": null
}
```

### 405 Method Not Allowed
```json
{
  "success": false,
  "message": "Method not allowed",
  "errors": null
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "An internal error occurred",
  "errors": null
}
```

---

## Testing the API

### Using cURL

#### 1. Register a User
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "Password123",
    "deviceId": "test-device"
  }'
```

#### 2. Get Categories
```bash
TOKEN="your_jwt_token_here"

curl -X GET http://localhost:8080/categories \
  -H "Authorization: Bearer $TOKEN"
```

#### 3. Create Custom Category
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

#### 4. Create Expense
```bash
curl -X POST http://localhost:8080/expenses \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Lunch",
    "amount": 25.50,
    "date": "2024-10-12T12:00:00Z",
    "categoryId": "food",
    "description": "Pizza"
  }'
```

#### 5. Get Expenses with Pagination
```bash
curl -X GET "http://localhost:8080/expenses?limit=10&offset=0&includeCategory=true" \
  -H "Authorization: Bearer $TOKEN"
```

#### 6. Get Expense Stats
```bash
curl -X GET http://localhost:8080/expenses/stats \
  -H "Authorization: Bearer $TOKEN"
```

#### 7. Update Expense
```bash
EXPENSE_ID="your_expense_id_here"

curl -X PUT http://localhost:8080/expenses/$EXPENSE_ID \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 30.00
  }'
```

#### 8. Delete Expense
```bash
curl -X DELETE http://localhost:8080/expenses/$EXPENSE_ID \
  -H "Authorization: Bearer $TOKEN"
```

---

## Running the Server

```bash
cd backend/pocketly_api
dart_frog dev
```

The server will start on `http://localhost:8080`

---

## Implementation Details

### Architecture
- **Database**: Drift (SQLite)
- **Auth**: JWT tokens with refresh token rotation
- **Middleware**: Request logging, CORS, authentication
- **Response Format**: Consistent JSON structure across all endpoints

### Security Features
- Password hashing (bcrypt)
- JWT access tokens (15-minute expiry)
- Refresh tokens (30-day expiry)
- Device-specific logout
- User-scoped data access

### Performance Features
- Pagination for large datasets
- Efficient database queries with joins
- Optional category inclusion to reduce response size
- Indexed database queries

### Data Validation
- Required field validation
- Type validation
- Amount validation (must be > 0)
- Date format validation (ISO 8601)
- Category existence validation
- User ownership validation for updates/deletes

