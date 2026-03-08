const db = require('./backend/db'); // ensure it connects

function formatDateToLocal(date) {
    const offset = date.getTimezoneOffset();
    date = new Date(date.getTime() - (offset * 60 * 1000));
    return date.toISOString().split('T')[0];
}

async function testBookingLogic() {
    const date = '2026-03-03';
    const avgTime = 2; // cardiology avg
    const count = 1; // 1 person already in queue

    const now = new Date(); // Right now = e.g., 12:30 PM
    let baseTime = new Date(`${date}T09:00:00`);

    const todayStr = formatDateToLocal(now);
    if (date === todayStr && now > baseTime) {
        baseTime = now; // Shift base time to NOW
    }

    console.log("Base time set to:", baseTime);

    const expectedDateTime = new Date(baseTime.getTime() + (count * avgTime * 60000));

    const hours24 = expectedDateTime.getHours();
    const ampm = hours24 >= 12 ? 'PM' : 'AM';
    const hours12 = hours24 % 12 || 12;
    const mins = expectedDateTime.getMinutes().toString().padStart(2, '0');
    const expectedTimeStr = `${hours12}:${mins} ${ampm}`;

    console.log("Calculated Time Slot:", expectedTimeStr);
    console.log("---");
    console.log(`If Token 1 is 12:24 PM, they were booked at ~12:24 PM. If Token 2 is booked at 12:30 PM (now), count=1, expectedTime is 12:32 PM.`);
    console.log(`But the screenshot shows Token 2 is booked as 6:46 PM. Where is 6 hours coming from?`);
}

testBookingLogic();
