const fs = require('fs');

function formatDateToLocal(date) {
    const offset = date.getTimezoneOffset();
    const localDate = new Date(date.getTime() - (offset * 60 * 1000));
    return localDate.toISOString().split('T')[0];
}

async function testBookingLogic() {
    let logStr = "";
    const appendLog = (msg) => {
        logStr += msg + "\n";
        console.log(msg);
    }

    const date = '2026-03-03';
    const avgTime = 2; // cardiology avg
    const count = 1; // 1 person already in queue

    // Simulation: Time is 12:30 PM local
    const now = new Date();
    let baseTime = new Date(`${date}T09:00:00`);

    const todayStr = formatDateToLocal(now);

    appendLog(`todayStr: ${todayStr}`);
    appendLog(`now: ${now}`);
    appendLog(`now local: ${now.toString()}`);
    appendLog(`baseTime init: ${baseTime}`);

    if (date === todayStr && now > baseTime) {
        baseTime = now; // Shift base time to NOW
        appendLog(`Shifted baseTime to now: ${baseTime}`);
    }

    const expectedDateTime = new Date(baseTime.getTime() + (count * avgTime * 60000));
    appendLog(`expectedDateTime: ${expectedDateTime}`);

    const hours24 = expectedDateTime.getHours();
    const ampm = hours24 >= 12 ? 'PM' : 'AM';
    const hours12 = hours24 % 12 || 12;
    const mins = expectedDateTime.getMinutes().toString().padStart(2, '0');
    const expectedTimeStr = `${hours12}:${mins} ${ampm}`;

    appendLog(`Calculated Time Slot: ${expectedTimeStr}`);

    fs.writeFileSync('output_time.txt', logStr);
}

testBookingLogic();
