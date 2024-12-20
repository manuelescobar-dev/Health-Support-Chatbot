from datetime import datetime
import requests


def appointment_form():
    # Ask user for appointment details
    user_id = input("Enter user ID: ")
    doctor_id = input("Enter doctor ID: ")
    doctor_name = input("Enter doctor name: ")
    specialization = input("Enter specialization: ")
    appointment_date = input("Enter appointment date (YYYY-MM-DD HH:MM): ")
    location = input("Enter location: ")
    status = input("Enter status (Scheduled/Completed/Cancelled): ")
    notes = input("Enter notes: ")

    # Prepare the payload
    payload = {
        "userId": user_id,
        "doctorId": doctor_id,
        "doctorName": doctor_name,
        "specialization": specialization,
        "appointmentDate": appointment_date,
        "location": location,
        "status": status,
        "notes": notes,
    }

    return payload


def add_appointment(endpoint, payload):
    # Headers
    headers = {"Content-Type": "application/json"}

    # Make the POST request
    response = requests.post(endpoint, json=payload, headers=headers)

    # Print the response
    if response.status_code == 201:
        print("Appointment added successfully")
    else:
        print("Error:", response.status_code, response.text)


if __name__ == "__main__":
    # User ID
    user_id = "gnNsC2QB4ST5J87rSUixWtzh8f72"

    # Appointment data
    appointments = [
        {
            "userId": user_id,
            "doctorId": "doc456",
            "doctorName": "Dr. Jane Smith",
            "specialization": "Cardiology",
            "appointmentDate": datetime(
                2024, 11, 20, 10, 30
            ).isoformat(),  # Use datetime for timestamp
            "location": "Health Clinic, Room 305",
            "status": "Completed",
            "notes": "Follow-up appointment for hypertension management. Patient reported mild dizziness in the morning but no chest pain. Blood pressure: 130/85 mmHg. ECG results showed no abnormalities. Adjusted medication to 10 mg Amlodipine daily. Advised lifestyle changes: reduce sodium intake, engage in 30 minutes of aerobic exercise 5 days a week, and monitor blood pressure twice daily. Next follow-up scheduled for 2025-01-15.",
        },
        {
            "userId": user_id,
            "doctorId": "doc123",
            "doctorName": "Dr. James Brown",
            "specialization": "General Medicine",
            "appointmentDate": datetime(
                2024, 10, 15, 9, 0
            ).isoformat(),  # Use datetime for timestamp
            "location": "Main Hospital, Building A, Room 10",
            "status": "Completed",
            "notes": "Routine check-up. Patient complaints included occasional headaches and fatigue. Blood test results: Hemoglobin 13.5 g/dL, WBC count 6,800/mcL, Fasting blood glucose 92 mg/dL. Physical exam findings were normal. Diagnosed tension headaches, likely stress-related. Advised proper hydration, regular sleep schedule, and stress management techniques such as yoga. Prescribed acetaminophen 500 mg as needed for pain. Recommended follow-up if symptoms persist beyond 6 weeks.",
        },
        {
            "userId": user_id,
            "doctorId": "doc789",
            "doctorName": "Dr. Emily Johnson",
            "specialization": "Dermatology",
            "appointmentDate": datetime(
                2024, 12, 22, 14, 0
            ).isoformat(),  # Use datetime for timestamp
            "location": "Dermatology Center, Room 102",
            "status": "Scheduled",
            "notes": "Scheduled for skin rash evaluation. Patient reports an itchy rash on the forearms that has persisted for 2 weeks. No prior history of allergies or similar symptoms. Advised to bring any creams or medications they’ve applied for review. Doctor to assess for potential eczema or allergic dermatitis.",
        },
        {
            "userId": user_id,
            "doctorId": "doc654",
            "doctorName": "Dr. Anna Lee",
            "specialization": "Neurology",
            "appointmentDate": datetime(
                2024, 11, 10, 13, 30
            ).isoformat(),  # Use datetime for timestamp
            "location": "City Hospital, Neurology Wing, Room 5",
            "status": "Completed",
            "notes": "Patient presented with persistent migraines for 3 months, exacerbated by stress and screen time. MRI scan ruled out structural abnormalities. Neurological exam was unremarkable. Diagnosis: chronic migraine with stress as a trigger. Prescribed Sumatriptan 50 mg as needed for acute migraine attacks and Amitriptyline 10 mg daily for prophylaxis. Advised to maintain a headache diary, avoid known triggers, and incorporate relaxation techniques. Follow-up scheduled for 2025-02-01 to assess treatment effectiveness.",
        },
        {
            "userId": user_id,
            "doctorId": "doc321",
            "doctorName": "Dr. Michael Green",
            "specialization": "Orthopedics",
            "appointmentDate": datetime(
                2024, 12, 18, 16, 0
            ).isoformat(),  # Use datetime for timestamp
            "location": "Ortho Clinic, Room 22",
            "status": "Scheduled",
            "notes": "Patient reports knee pain after running, particularly on the left side, persisting for 3 weeks. No prior injuries reported. Doctor to evaluate for potential patellofemoral pain syndrome or ligament strain. Advised to bring running shoes for gait analysis during the consultation.",
        },
    ]

    for i in appointments:
        add_appointment(
            "https://us-central1-telepatia-1677c.cloudfunctions.net/add_appointment", i
        )
