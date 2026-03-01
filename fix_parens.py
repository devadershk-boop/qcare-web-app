import sys

fixes = [
    (r'd:\XBOX\qcare\hospital_queue_app\lib\screens\token_status_screen.dart', 224),
    (r'd:\XBOX\qcare\hospital_queue_app\lib\screens\my_appointments_screen.dart', 109),
    (r'd:\XBOX\qcare\hospital_queue_app\lib\screens\book_appointment_screen.dart', 367),
]

for path, bad_line in fixes:
    with open(path, 'r', encoding='utf-8-sig') as f:
        lines = f.readlines()
    removed = lines[bad_line - 1].rstrip()
    del lines[bad_line - 1]
    with open(path, 'w', encoding='utf-8', newline='') as f:
        f.writelines(lines)
    print(f'OK: removed line {bad_line} from {path.split(chr(92))[-1]}  [{repr(removed)}]')

print('Done.')
