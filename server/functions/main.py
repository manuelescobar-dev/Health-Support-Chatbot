from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
from openai import OpenAI
from datetime import datetime
import json
from firebase_functions.params import SecretParam
import google.cloud.firestore

app = initialize_app()
OPENAI_API_KEY = SecretParam("OPENAI_API_KEY")


@https_fn.on_request(secrets=[OPENAI_API_KEY])
def get_response(req: https_fn.Request) -> https_fn.Response:
    try:
        client = OpenAI()
        # Parse the userId from the request body.
        user_id = req.args.get("userId")

        if not user_id:
            return https_fn.Response("Missing required parameter: userId", status=400)

        firestore_client: google.cloud.firestore.Client = firestore.client()
        # Query the appointments collection for documents matching the userId.
        appointments_query = firestore_client.collection("appointments").where(
            "userId", "==", user_id
        )

        # Fetch the results.
        appointments = [doc.to_dict() for doc in appointments_query.stream()]

        # Convert Firestore timestamp fields to ISO 8601 strings.
        for appointment in appointments:
            if "appointmentDate" in appointment and isinstance(
                appointment["appointmentDate"], datetime
            ):
                appointment["appointmentDate"] = appointment[
                    "appointmentDate"
                ].isoformat()
    except Exception as e:
        return https_fn.Response(f"Error fetching appointments: {str(e)}", status=500)

    try:
        # Parse the user's message from the request body.
        message = req.args.get("message")

        if not message:
            return https_fn.Response("Missing required parameter: message", status=400)

        # Call the GPT model for a response
        completion = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {
                    "role": "system",
                    "content": "You are a medical assistant in charge of enabling users to inquire about previous consultations and upcoming appointments. With each response, you must return the appointment associated with it. In case no appointment is associated, you must return an empty list.",
                },
                {
                    "role": "assistant",
                    "content": json.dumps(appointments),
                },
                {
                    "role": "user",
                    "content": message,
                },
            ],
        )

        # Extract the response from the model's output
        response_content = completion.choices[0].message.content

        # Return the response as JSON
        return https_fn.Response(
            response_content,
            status=200,
            mimetype="application/json",
        )

    except Exception as e:
        # Handle any unexpected errors and return an appropriate error response
        return https_fn.Response(
            f"An error occurred: {str(e)}",
            status=500,
        )


@https_fn.on_request()
def add_appointment(req: https_fn.Request) -> https_fn.Response:
    """Take the parameters passed to this HTTP endpoint and insert them into
    a new document in the appointments collection."""
    try:
        # Parse the JSON payload from the request body.
        appointment_data = req.get_json()

        # Validate required fields.
        required_fields = [
            "userId",
            "doctorId",
            "doctorName",
            "specialization",
            "appointmentDate",
            "location",
            "status",
            "notes",
        ]

        missing_fields = [
            field for field in required_fields if field not in appointment_data
        ]
        if missing_fields:
            return https_fn.Response(
                f"Missing required fields: {', '.join(missing_fields)}", status=400
            )

        # Convert appointmentDate to a Firestore-compatible timestamp if necessary.
        if isinstance(appointment_data["appointmentDate"], str):
            try:
                appointment_data["appointmentDate"] = datetime.fromisoformat(
                    appointment_data["appointmentDate"]
                )
            except ValueError:
                return https_fn.Response(
                    "Invalid date format for appointmentDate. Use ISO 8601 format.",
                    status=400,
                )

        firestore_client: google.cloud.firestore.Client = firestore.client()

        # Add the new appointment to the appointments collection.
        _, doc_ref = firestore_client.collection("appointments").add(appointment_data)

        # Return a success response.
        return https_fn.Response(f"Added appointment with ID {doc_ref.id}.", status=201)

    except Exception as e:
        return https_fn.Response(f"Error adding appointment: {str(e)}", status=500)


@https_fn.on_request()
def get_appointments_by_user(req: https_fn.Request) -> https_fn.Response:
    """Fetch appointments for a given userId."""
    try:
        # Parse the userId from the query parameters.
        user_id = req.args.get("userId")

        if not user_id:
            return https_fn.Response("Missing required parameter: userId", status=400)

        firestore_client: google.cloud.firestore.Client = firestore.client()

        # Query the appointments collection for documents matching the userId.
        appointments_query = (
            firestore_client.collection("appointments")
            .where("userId", "==", user_id)
            .order_by("appointmentDate")  # Optional: Order by appointmentDate.
        )

        # Fetch the results.
        appointments = [doc.to_dict() for doc in appointments_query.stream()]

        # Convert Firestore timestamp fields to ISO 8601 strings.
        for appointment in appointments:
            if "appointmentDate" in appointment and isinstance(
                appointment["appointmentDate"], datetime
            ):
                appointment["appointmentDate"] = appointment[
                    "appointmentDate"
                ].isoformat()

        # Return the appointments as a JSON response.
        return https_fn.Response(
            json.dumps(appointments), status=200, mimetype="application/json"
        )

    except Exception as e:
        return https_fn.Response(f"Error fetching appointments: {str(e)}", status=500)
