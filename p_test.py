from petrovich.enums import Case, Gender
from petrovich.main import Petrovich
import os

# Текущая директория
CURRENT_PATH = os.path.abspath(os.path.dirname(__file__))
# Путь до файла с правилами округления
DEFAULT_RULES_PATH = os.path.join(CURRENT_PATH, 'morphy','rules.json')


if __name__ == '__main__':
    rows = [
        # (u'Черных', u'Алексей', u'Давыдович'),
        # (u'Матвеев', u'Денис', u'Евгеньевич'),
        # (u'Алимова', u'Алия', u'Маратовна'),
        # (u'Шурша', u'Альфия', u'Александровна', Gender.FEMALE),
        (u'Ганцгорн', u'Махач', u'Милошев', Gender.MALE),
        # (u'Коломиец', u'Данила', u'Олегович', Gender.MALE),
        # (u'Тарлюн', u'Данила', u'Борисович', Gender.MALE),
    ]

    petro = Petrovich(DEFAULT_RULES_PATH)

    for segments in rows:
        gender = None

        if len(segments) == 4:
            fname, iname, oname, gender = segments
        elif len(segments) == 3:
            fname, iname, oname = segments
        else:
            raise ValueError

        for case in Case.CASES:
            print(u'{} {} {}'.format(
                petro.lastname(fname, case, gender),
                petro.firstname(iname, case, gender),
                petro.middlename(oname, case, gender),
            ))