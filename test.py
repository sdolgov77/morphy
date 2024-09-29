from petrovich.main import Petrovich
from petrovich.enums import Gender
import csv
from morphy import Morphy, RegimeLength, Case, sex_convert, case_convert, length_convert

m = Morphy()
counter = 0
with open('result.csv', 'w') as csv_file:
    writer = csv.writer(csv_file, delimiter=';')
    with open('AGNLIST.csv', 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            is_cut, is_reverse = length_convert[row['R_LENGTH']]
            morth_name = m.fio_stub(row['FIZ_FAMILY'], row['FIZ_NAME'], row['FIZ_OTCH'], sex_convert[row['FIZ_SEX']], \
                                    case_convert[row['P_CASE']], cut=is_cut, reverse=is_reverse)
            if morth_name != row['RESULT']:
                # print(morth_name, ":::", row['RESULT'], ":::", row['P_CASE'])
                # print(row)
                writer.writerow([morth_name, row['RESULT'], row['P_CASE'], row['FIZ_FAMILY'], row['FIZ_NAME'], row['FIZ_OTCH']])
                counter += 1
print(counter)

# print(m.fio_stub('Иванов', 'Иван', 'Иванович', Gender.MALE, Case.DATIVE, cut=False, reverse=False))
# print(m.fio_stub_full('Иванов Иван', Gender.MALE, Case.DATIVE, cut=False, reverse=True))