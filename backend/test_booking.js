const http = require('http');

const data = JSON.stringify({
    patientName: "John Doe",
    department: "gyno",
    doctor: "John",
    date: "2026-03-01"
});

const options = {
    hostname: 'localhost',
    port: 5000,
    path: '/appointments',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

const req = http.request(options, res => {
    let body = '';
    res.on('data', chunk => body += chunk);
    res.on('end', () => console.log('Status:', res.statusCode, 'Body:', body));
});

req.on('error', error => console.error(error));
req.write(data);
req.end();
