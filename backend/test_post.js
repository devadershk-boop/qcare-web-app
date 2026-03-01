import fetch from 'node-fetch';

async function test() {
    try {
        const res = await fetch('http://localhost:8000/appointments', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                patientName: "TestUserNode",
                department: "gyno",
                doctor: "Dr. john",
                date: "2026-03-01"
            })
        });
        const text = await res.text();
        console.log("Status:", res.status);
        console.log("Response:", text);
    } catch (err) {
        console.error("Fetch failed", err);
    }
}
test();
