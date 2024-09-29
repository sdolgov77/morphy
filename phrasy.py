import pymorphy3
from pyphrasy.inflect import PhraseInflector

morph = pymorphy3.MorphAnalyzer()
inflector = PhraseInflector(morph)
form = 'datv'
phrase = 'Уважаемая женщина'
print(inflector.inflect(phrase, form))