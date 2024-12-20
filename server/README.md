## Endpoints

### **Get Response (`/get_response`)**
- **Description:** This endpoint interacts with OpenAI's GPT model to provide a response to user inquiries about their appointments. It includes information about previous consultations and upcoming appointments.
- **Parameters:**
  - **Query Parameters:**
    - `userId` (required): The unique ID of the user.
    - `message` (required): The user's message or query.
- **Response:**
  - Status `200`: JSON string containing the GPT model's response and relevant appointments.
  - Status `400`: Missing `userId` or `message` parameter.
  - Status `500`: Error fetching appointments or calling GPT.
- **Example HTTP Request:**
  ```http
  GET /get_response?userId=12345&message=When is my next cardiology appointment?
  ```
- **Example Response:**
  ```json
  {
    "response": "Your next cardiology appointment is on 2024-12-22 at 10:00 AM.",
    "appointments": [
      {
        "doctorName": "Dr. John Doe",
        "specialization": "Cardiology",
        "appointmentDate": "2024-12-22T10:00:00Z",
        "location": "City Hospital",
        "status": "Scheduled",
        "notes": "Bring your lab results."
      }
    ]
  }
  ```

---

### **Add Appointment (`/add_appointment`)**
- **Description:** This endpoint adds a new appointment to the Firestore database.
- **Parameters:**
  - **Request Body (JSON):**
    - `userId` (required): Unique identifier for the user.
    - `doctorId` (required): Unique identifier for the doctor.
    - `doctorName` (required): Name of the doctor.
    - `specialization` (required): Doctor's specialization.
    - `appointmentDate` (required): Appointment date in ISO 8601 format.
    - `location` (required): Location of the appointment.
    - `status` (required): Appointment status (`Scheduled`, `Completed`, or `Cancelled`).
    - `notes` (required): Additional information or instructions.
- **Response:**
  - Status `201`: Appointment added successfully with document ID.
  - Status `400`: Missing required fields or invalid date format.
  - Status `500`: Error adding appointment.
- **Example HTTP Request:**
  ```http
  POST /add_appointment
  Content-Type: application/json

  {
    "userId": "12345",
    "doctorId": "67890",
    "doctorName": "Dr. Jane Smith",
    "specialization": "Dermatology",
    "appointmentDate": "2024-12-25T14:00:00Z",
    "location": "Downtown Clinic",
    "status": "Scheduled",
    "notes": "Follow-up visit for rash."
  }
  ```
- **Example Response:**
  ```json
  {
    "message": "Added appointment with ID abc123."
  }
  ```

---

### **Get Appointments by User (`/get_appointments_by_user`)**
- **Description:** Fetches all appointments for a given user, sorted by appointment date.
- **Parameters:**
  - **Query Parameters:**
    - `userId` (required): The unique ID of the user.
- **Response:**
  - Status `200`: A list of appointments for the user in JSON format.
  - Status `400`: Missing `userId` parameter.
  - Status `500`: Error fetching appointments.
- **Example HTTP Request:**
  ```http
  GET /get_appointments_by_user?userId=12345
  ```
- **Example Response:**
  ```json
  [
    {
      "doctorName": "Dr. John Doe",
      "specialization": "Cardiology",
      "appointmentDate": "2024-12-22T10:00:00Z",
      "location": "City Hospital",
      "status": "Scheduled",
      "notes": "Bring your lab results."
    },
    {
      "doctorName": "Dr. Jane Smith",
      "specialization": "Dermatology",
      "appointmentDate": "2024-12-25T14:00:00Z",
      "location": "Downtown Clinic",
      "status": "Scheduled",
      "notes": "Follow-up visit for rash."
    }
  ]
  ```