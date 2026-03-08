console.log('--- DB Connection Test ---');
const { Pool } = require('pg');
const db = new Pool({
    connectionString: 'postgresql://postgres.kkhyyhqlsrsayainqgwj:YvDJrjQVRuHLoAVU@aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres',
    ssl: { rejectUnauthorized: false },
    connectionTimeoutMillis: 5000,
});

db.on('error', (err) => {
    console.error('Unexpected pool error:', err.message);
});

console.log('Testing connection to Supabase...');
db.query('SELECT 1')
    .then(res => {
        console.log('✅ Connection Successful!');
        process.exit(0);
    })
    .catch(err => {
        console.error('❌ Connection Failed:', err.message);
        process.exit(1);
    });
