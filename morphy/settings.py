from enum import Enum
from petrovich.enums import Gender

c_respected_male = "Уважаемый"
c_respected_female = "Уважаемая"

class RegimeInit:
    """Режимы начала имени"""
    AS_IS = 'init_as_is'              # Выводить как есть
    LOWER = 'init_lower'              # Приводить первую букву к нижнему регистру
    UPPER = 'init_upper'              # Приводить первую букву к верхнему регистру

class RegimeLength:
  """Режимы длины имени"""
  SHORT           = 'short'           # Фамилия И.О.
  REVERSE_SHORT   = 'reverse_short'   # И.О. Фамилия
  LONG            = 'long'            # Фамилия Имя Отчество
  RESPECTED_LONG  = 'respected_long'  # Уважаемый Фамилия Имя Отчество
  RESPECTED_SHORT = 'respected_short' # Уважаемый Имя Отчество

class Case:
    """Перечисление падежей"""
    # Родительный
    GENITIVE = 0
    # Дательный
    DATIVE = 1
    # Винительный
    ACCUSATIVE = 2
    # Творительный
    INSTRUMENTAL = 3
    # Предложный
    PREPOSITIONAL = 4
    # Именительный
    NOMINATIVE = 5

    CASES = (
        DATIVE,
        GENITIVE,
        ACCUSATIVE,
        INSTRUMENTAL,
        PREPOSITIONAL,
    )

sex_convert = {
    '1': Gender.MALE,
    '0': Gender.FEMALE
}    

case_convert = {
   '1': Case.NOMINATIVE,
   '2': Case.GENITIVE,
   '3': Case.DATIVE,
   '4': Case.ACCUSATIVE,
   '5': Case.INSTRUMENTAL,
   '6': Case.PREPOSITIONAL
}

length_convert = {
   RegimeLength.SHORT: (True, False),
   RegimeLength.REVERSE_SHORT: (True, True),
   RegimeLength.LONG: (False, False)
}