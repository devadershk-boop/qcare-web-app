const fs = require('fs');

const fixes = [
    { file: 'd:\\XBOX\\qcare\\hospital_queue_app\\lib\\screens\\token_status_screen.dart', line: 224 },
    { file: 'd:\\XBOX\\qcare\\hospital_queue_app\\lib\\screens\\my_appointments_screen.dart', line: 109 },
    { file: 'd:\\XBOX\\qcare\\hospital_queue_app\\lib\\screens\\book_appointment_screen.dart', line: 367 },
];

for (const { file, line } of fixes) {
    const content = fs.readFileSync(file, 'utf8');
    const lines = content.split(/\r?\n/);
    const removed = lines[line - 1];
    lines.splice(line - 1, 1);
    fs.writeFileSync(file, lines.join('\r\n'), 'utf8');
    const name = file.split('\\').pop();
    console.log(`OK: removed line ${line} from ${name}: [${removed.trim()}]`);
}
console.log('Done.');
