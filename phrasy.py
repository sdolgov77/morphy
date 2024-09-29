import pymorphy3
from pyphrasy.inflect import PhraseInflector

morph = pymorphy3.MorphAnalyzer()
inflector = PhraseInflector(morph)
form = 'gent'
phrase = 'Ольга'
print(inflector.inflect(phrase, form))