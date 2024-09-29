import os
from petrovich.main import Petrovich
from petrovich.enums import Gender
from .settings import c_respected_male, c_respected_female, RegimeLength, Case

# Текущая директория
CURRENT_PATH = os.path.abspath(os.path.dirname(__file__))
# Путь до файла с правилами округления
DEFAULT_RULES_PATH = os.path.join(CURRENT_PATH, 'rules.json')

class Morphy:
    def __init__(self):
        self._p = Petrovich(DEFAULT_RULES_PATH)

    def get_fio(self, last_name, first_name, middle_name, sex, phrase_case=Case.NOMINATIVE, cut=False, reverse=False):
        return self.fio(last_name, first_name, middle_name, sex, phrase_case)

    def fio_stub(self, last_name, first_name, middle_name, sex, phrase_case=Case.NOMINATIVE, cut=False, reverse=False):
        if phrase_case == Case.NOMINATIVE:
            last_name_form = last_name.strip()
        else:
            last_name_form = self._p.lastname(last_name.strip(), phrase_case, sex)

        if cut:
            name_form = first_name[0] + '.' 
            if middle_name:
                name_form = name_form + middle_name[0] + '.'
        else:
            if phrase_case == Case.NOMINATIVE:
                name_form = first_name.strip() 
                if middle_name:
                    name_form = name_form + ' ' + middle_name.strip()
            else:
                name_form = self._p.firstname(first_name.strip(), phrase_case, sex)
                if middle_name:
                    name_form = name_form + ' ' + self._p.middlename(middle_name.strip(), phrase_case, sex)

        if reverse:
            return (name_form + ' ' + last_name_form).title()
        else:
            return (last_name_form + ' ' + name_form).title()
    
    def fio_stub_full(self, full_name, sex, phrase_case=Case.NOMINATIVE, cut=False, reverse=False):
        if len(full_name_row := full_name.split(' ')) == 3:
            last_name, first_name, middle_name = full_name_row
        elif len(full_name_row) == 2:
            last_name, first_name = full_name_row
            middle_name = ''
        else:
            raise Exception('Invalid full name: ' + full_name)
        return self.fio_stub(last_name, first_name, middle_name, sex, phrase_case, cut, reverse)
    
    def prefix_fio(self, sex, phrase_case, regime_length):
        return ""

    def fio(self, last_name, first_name, middle_name, sex, phrase_case=Case.NOMINATIVE, regime_length="short"):
        return self.prefix_fio(sex, phrase_case, regime_length) + last_name + ' ' + first_name + ' ' + middle_name
