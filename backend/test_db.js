const mysql = require('mysql2');

const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '', // Add your DB password here
    database: 'qcare_db'
}).promise();

async function test() {
    try {
        const [rows] = await db.query('SHOW TABLES');
        console.log('Tables in qcare_db:', rows);
        process.exit(0);
    } catch (err) {
        console.error('Database connection failed:', err.message);
        process.exit(1);
    }
}

test();
